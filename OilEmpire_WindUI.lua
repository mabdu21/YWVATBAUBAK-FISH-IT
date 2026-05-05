--[[
    🛢️ Oil Empire - WindUI Edition
    Upgraded by Claude | Original by dekxonn
    
    Features:
    - Refinery Auto Pickup (with tween speed slider)
    - Auto Sell (with min gas price & min gasoline sliders)
    - Anti-AFK toggle
    - Live gas price / sell price display
    - Status paragraph updates every second
--]]

-- ─── Services ───────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local lp       = Players.LocalPlayer
local username = lp.Name

-- ─── State ──────────────────────────────────────────────────────────────────
local enabled      = false
local sellEnabled  = false
local tweenSpeed   = 0.1
local useTween     = true
local farmThread   = nil
local sellThread   = nil
local antiAfkOn    = false
local antiAfkConn  = nil
local sellPrice    = 10
local minGasoline  = 10000

-- ─── Sell cache ─────────────────────────────────────────────────────────────
local sellStore, sellPrompt, sellRemote

-- ─── Anti-AFK ───────────────────────────────────────────────────────────────
local function setAntiAfk(on)
    antiAfkOn = on
    if antiAfkConn then
        antiAfkConn:Disconnect()
        antiAfkConn = nil
    end
    if on then
        antiAfkConn = lp.Idled:Connect(function()
            local vp = game:GetService("VirtualInputManager")
            vp:SendKeyEvent(true,  Enum.KeyCode.W, false, game)
            task.wait(0.1)
            vp:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        end)
    end
end

-- ─── Plot / Buildings helpers ────────────────────────────────────────────────
local function getPlayerPlot()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local ok, label = pcall(function()
            return plot.OwnerTag.BillboardGui.Main.TextLabel
        end)
        if ok and label then
            local owner = label.Text:match("^(.+)'s")
            if owner == username then return plot end
        end
    end
    return nil
end

local function getBuildings()
    local plot = getPlayerPlot()
    return plot and plot:FindFirstChild("Buildings") or nil
end

local function getRefineries(buildings)
    local list = {}
    for _, m in ipairs(buildings:GetChildren()) do
        if m:IsA("Model") and m:GetAttribute("Type") == "Refinery" then
            list[#list + 1] = m
        end
    end
    return list
end

local function getValues(model)
    local ok, obj = pcall(function() return model.Primary.Info.Main.Value end)
    if not ok or not obj then return 0, 0 end
    local text = (obj.Text or obj.Value or "")
    local c, m = text:match("^(%d+)/(%d+)$")
    return tonumber(c) or 0, tonumber(m) or 0
end

local function getPrimary(model)
    local p = model:FindFirstChild("Primary")
    if p and p:IsA("BasePart") then return p end
    return model.PrimaryPart
end

-- ─── Teleport ────────────────────────────────────────────────────────────────
local function teleport(targetCF)
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    hrp.Anchored = true
    if hum then hum.PlatformStand = true end
    if useTween and tweenSpeed > 0.05 then
        local startCF  = hrp.CFrame
        local elapsed  = 0
        local duration = tweenSpeed
        repeat
            local dt = task.wait()
            elapsed  = elapsed + dt
            local a  = math.min(elapsed / duration, 1)
            hrp.CFrame = startCF:Lerp(targetCF, 1 - (1 - a) ^ 3)
        until elapsed >= duration or not enabled or not hrp.Parent
    end
    if hrp.Parent then hrp.CFrame = targetCF end
    hrp.Anchored = false
    if hum then hum.PlatformStand = false end
end

-- ─── Farm Loop ───────────────────────────────────────────────────────────────
local function farmLoop()
    while enabled do
        local buildings = getBuildings()
        if not buildings then task.wait(1) continue end
        local list = getRefineries(buildings)
        if #list == 0 then task.wait(1) continue end
        table.sort(list, function(a, b)
            local ca, ma = getValues(a)
            local cb, mb = getValues(b)
            local fa = (ma > 0) and (ca / ma) or 0
            local fb = (mb > 0) and (cb / mb) or 0
            return fa > fb
        end)
        local visited = 0
        for _, model in ipairs(list) do
            if not enabled then break end
            if not model.Parent then continue end
            local cur, max = getValues(model)
            if max > 0 and cur == max then
                local primary = getPrimary(model)
                if primary then
                    teleport(primary.CFrame)
                    visited = visited + 1
                    task.wait(0.05)
                end
            end
        end
        if visited == 0 then
            task.wait(0.5)
        end
    end
end

-- ─── Sell helpers ────────────────────────────────────────────────────────────
local function cacheSellAssets()
    local stores = workspace:FindFirstChild("Stores")
    if not stores then return false end
    sellStore = stores:FindFirstChild("Sell")
    if not sellStore then return false end
    local prompt = sellStore:FindFirstChild("SellGas", true)
    if not prompt then
        for _, v in ipairs(sellStore:GetDescendants()) do
            if v:IsA("ProximityPrompt") then prompt = v; break end
        end
    end
    sellPrompt = prompt
    for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find("sell") then
            sellRemote = v; break
        end
    end
    if not sellRemote then
        for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") and (
                v.Name:lower():find("gas") or
                v.Name:lower():find("store") or
                v.Name:lower():find("shop")
            ) then
                sellRemote = v; break
            end
        end
    end
    return true
end

local function vimClick(btn)
    local vp  = game:GetService("VirtualInputManager")
    local pos = btn.AbsolutePosition + btn.AbsoluteSize * 0.5
    vp:SendMouseButtonEvent(pos.X, pos.Y, 0, true,  game, 0)
    task.wait(0.08)
    vp:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

local function closeGui()
    pcall(function()
        local sellGui = lp.PlayerGui.Main.SellGas
        local closeBtn = sellGui.Close
        local oldZ = closeBtn.ZIndex
        closeBtn.ZIndex = 9999
        task.wait()
        vimClick(closeBtn)
        closeBtn.ZIndex = oldZ
    end)
    task.wait(0.3)
    pcall(function()
        local sellGui = lp.PlayerGui.Main.SellGas
        if sellGui.Visible then
            sellGui.Visible = false
            local lighting = game:GetService("Lighting")
            for _, v in ipairs(lighting:GetChildren()) do
                if v:IsA("BlurEffect") then
                    v.Enabled = false
                    task.delay(2, function() v.Enabled = true end)
                end
            end
        end
    end)
end

local function trySell()
    if sellRemote then
        local ok = pcall(function() sellRemote:FireServer() end)
        if ok then return true end
    end
    pcall(function()
        local sellBtn = lp.PlayerGui.Main.SellGas.Main.Sell
        vimClick(sellBtn)
    end)
    return true
end

local function sellLoop()
    if not sellStore then
        if not cacheSellAssets() then
            sellEnabled = false
            return
        end
    end
    while sellEnabled do
        local okP, price = pcall(function()
            return game:GetService("ReplicatedStorage").GasPrice.Value
        end)
        if not okP or type(price) ~= "number" then task.wait(2); continue end
        local okG, gasoline = pcall(function()
            return lp.leaderstats.Gasoline.Value
        end)
        local hasEnoughGas = okG and type(gasoline) == "number" and gasoline >= minGasoline
        if price >= sellPrice and hasEnoughGas then
            local wasEnabled = enabled
            if wasEnabled then
                enabled = false
                if farmThread then task.cancel(farmThread); farmThread = nil end
            end
            if sellPrompt then
                pcall(function() fireproximityprompt(sellPrompt) end)
                task.wait(0.6)
            end
            trySell()
            closeGui()
            if wasEnabled then
                enabled = true
                farmThread = task.spawn(farmLoop)
            end
            task.wait(5)
        else
            task.wait(1)
        end
    end
end

-- ─── Format helpers ──────────────────────────────────────────────────────────
local function formatGas(v)
    if v >= 1000000 then return string.format("%.1fM", v / 1000000)
    elseif v >= 1000 then return string.format("%dK", math.floor(v / 1000))
    else return tostring(v) end
end

-- ════════════════════════════════════════════════════════════════════════════
--  WindUI
-- ════════════════════════════════════════════════════════════════════════════
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- ─── Window ──────────────────────────────────────────────────────────────────
local Window = WindUI:CreateWindow({
    Title        = "Oil Empire 🛢️",
    Icon         = "fuel",
    Author       = "by dekxonn",
    Folder       = "OilEmpire",
    Size         = UDim2.fromOffset(560, 460),
    ToggleKey    = Enum.KeyCode.RightShift,
    Transparent  = true,
    Theme        = "Dark",
    Resizable    = false,
})

-- ─── Tabs ─────────────────────────────────────────────────────────────────────
local FarmTab   = Window:Tab({ Title = "Auto Farm",  Icon = "pickaxe" })
local SellTab   = Window:Tab({ Title = "Auto Sell",  Icon = "dollar-sign" })
local MiscTab   = Window:Tab({ Title = "Misc",       Icon = "settings" })

-- ════════════════════════════════════════════════════════════════════════════
--  FARM TAB
-- ════════════════════════════════════════════════════════════════════════════

-- Status paragraph (updated every second by a loop)
local StatusPara = FarmTab:Paragraph({
    Title = "Status",
    Desc  = "INACTIVE — 0 refineries found",
    Color = "Red",
})

FarmTab:Divider()

-- Auto Pickup toggle
local FarmToggle = FarmTab:Toggle({
    Title = "Auto Pickup",
    Desc  = "Automatically collects full refineries on your plot",
    Icon  = "zap",
    Value = false,
    Callback = function(state)
        enabled = state
        if enabled then
            if farmThread then task.cancel(farmThread) end
            farmThread = task.spawn(farmLoop)
        else
            if farmThread then task.cancel(farmThread); farmThread = nil end
        end
    end,
})

-- Tween Speed slider
local SpeedSlider = FarmTab:Slider({
    Title = "Tween Speed",
    Desc  = "Teleport animation duration (seconds)",
    Icon  = "gauge",
    Step  = 0.1,
    Value = {
        Min     = 0.1,
        Max     = 1.0,
        Default = 0.1,
    },
    Callback = function(value)
        tweenSpeed = value
    end,
})

FarmTab:Divider()

-- Refinery counter paragraph (updated by hookCounter loop)
local RefineryPara = FarmTab:Paragraph({
    Title = "Refineries",
    Desc  = "Scanning your plot...",
    Color = "Blue",
})

-- ════════════════════════════════════════════════════════════════════════════
--  SELL TAB
-- ════════════════════════════════════════════════════════════════════════════

-- Live gas price paragraph
local GasPricePara = SellTab:Paragraph({
    Title = "Live Gas Price",
    Desc  = "Gas: $—  |  Sell: $—  |  Next: —",
    Color = "Blue",
})

SellTab:Divider()

-- Auto Sell toggle
local SellToggle = SellTab:Toggle({
    Title = "Auto Sell",
    Desc  = "Sells gasoline when market price ≥ target",
    Icon  = "shopping-cart",
    Value = false,
    Callback = function(state)
        sellEnabled = state
        if sellEnabled then
            if sellThread then task.cancel(sellThread) end
            sellThread = task.spawn(sellLoop)
        else
            if sellThread then task.cancel(sellThread); sellThread = nil end
        end
    end,
})

SellTab:Divider()

-- Min Sell Price slider (1–30)
local MinPriceSlider = SellTab:Slider({
    Title = "Min Gas Price",
    Desc  = "Only sell when market price reaches this value",
    Icon  = "trending-up",
    Step  = 1,
    Value = {
        Min     = 1,
        Max     = 30,
        Default = 10,
    },
    Callback = function(value)
        sellPrice = value
    end,
})

-- Min Gasoline slider (logarithmic zones via integer steps)
-- We use a regular 1K–10M integer-step slider with 3 zones:
-- Zone 1: 1K  – 100K  step 1K
-- Zone 2: 100K – 1M   step 25K
-- Zone 3: 1M  – 10M   step 100K
-- WindUI Slider doesn't natively do log scale, so we use a helper.
-- We expose it as a linear 1–395 step=1 slider and convert internally.
local GAS_ZONES = {
    { min = 1000,    max = 100000,   step = 1000,   steps = 99 },
    { min = 100000,  max = 1000000,  step = 25000,  steps = 36 },
    { min = 1000000, max = 10000000, step = 100000, steps = 90 },
}
local GAS_TOTAL = 99 + 36 + 90 -- 225 steps total

local function gasStepToValue(step)
    step = math.clamp(step, 1, GAS_TOTAL)
    if step <= 99 then
        return GAS_ZONES[1].min + (step - 1) * GAS_ZONES[1].step
    elseif step <= 99 + 36 then
        return GAS_ZONES[2].min + (step - 99 - 1) * GAS_ZONES[2].step
    else
        return GAS_ZONES[3].min + (step - 99 - 36 - 1) * GAS_ZONES[3].step
    end
end

local function gasValueToStep(v)
    if v <= GAS_ZONES[1].max then
        return 1 + math.floor((v - GAS_ZONES[1].min) / GAS_ZONES[1].step)
    elseif v <= GAS_ZONES[2].max then
        return 100 + math.floor((v - GAS_ZONES[2].min) / GAS_ZONES[2].step)
    else
        return 136 + math.floor((v - GAS_ZONES[3].min) / GAS_ZONES[3].step)
    end
end

local MinGasSlider = SellTab:Slider({
    Title = "Min Gasoline",
    Desc  = string.format("Minimum gasoline before selling (current: %s)", formatGas(minGasoline)),
    Icon  = "flask-conical",
    Step  = 1,
    Value = {
        Min     = 1,
        Max     = GAS_TOTAL,
        Default = gasValueToStep(minGasoline),
    },
    Callback = function(step)
        minGasoline = gasStepToValue(step)
        MinGasSlider:SetDesc(string.format("Minimum gasoline before selling (current: %s)", formatGas(minGasoline)))
    end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  MISC TAB
-- ════════════════════════════════════════════════════════════════════════════

-- Anti-AFK toggle
local AfkToggle = MiscTab:Toggle({
    Title = "Anti-AFK",
    Desc  = "Prevents the idle-kick disconnect",
    Icon  = "shield-check",
    Type  = "Checkbox",
    Value = false,
    Callback = function(state)
        antiAfkOn = state
        setAntiAfk(state)
    end,
})

MiscTab:Divider()

-- Info paragraph
MiscTab:Paragraph({
    Title = "About",
    Desc  = "Oil Empire WindUI Edition\nOriginal script by dekxonn\nUI upgraded with WindUI v1.6+\n\nToggle GUI: RightShift",
    Color = "Blue",
})

-- ════════════════════════════════════════════════════════════════════════════
--  Background loops (status, price ticker, refinery counter)
-- ════════════════════════════════════════════════════════════════════════════

-- Refinery counter + status updater
task.spawn(function()
    local counterConn1, counterConn2
    local function hookCounter()
        if counterConn1 then counterConn1:Disconnect() end
        if counterConn2 then counterConn2:Disconnect() end
        local buildings = getBuildings()
        if not buildings then
            RefineryPara:SetDesc("Plot not found — make sure you own a plot")
            return
        end
        local function refresh()
            local n = #getRefineries(buildings)
            RefineryPara:SetDesc(n .. " refiner" .. (n == 1 and "y" or "ies") .. " found on your plot")
        end
        counterConn1 = buildings.ChildAdded:Connect(refresh)
        counterConn2 = buildings.ChildRemoved:Connect(refresh)
        refresh()
    end
    while true do
        hookCounter()
        task.wait(5)
    end
end)

-- Live price + status ticker
task.spawn(function()
    while true do
        -- Status paragraph
        if enabled then
            local buildings = getBuildings()
            local n = buildings and #getRefineries(buildings) or 0
            StatusPara:SetTitle("Status: ACTIVE ✅")
            StatusPara:SetDesc("Auto Pickup running — " .. n .. " refiner" .. (n == 1 and "y" or "ies") .. " on plot")
        else
            StatusPara:SetTitle("Status: INACTIVE ⏸")
            StatusPara:SetDesc("Auto Pickup is OFF. Toggle it to start collecting.")
        end

        -- Gas price display
        local okP, price = pcall(function()
            return game:GetService("ReplicatedStorage").GasPrice.Value
        end)
        local okT, timerTxt = pcall(function()
            return lp.PlayerGui.Main.SellGas.NextStock.Text
        end)
        local okS, spRaw = pcall(function()
            return lp.PlayerGui.Main.SellGas.Main.Sell.TextLabel.Text
        end)

        local priceStr   = (okP and price) and ("$" .. tostring(price)) or "$—"
        local sellStr    = (okS and spRaw) and (spRaw:match("%$[%d,]+") or "—") or "—"
        local timerStr   = (okT and timerTxt and tostring(timerTxt) ~= "") and tostring(timerTxt) or "—"
        local aboveTarget = okP and type(price) == "number" and price >= sellPrice

        GasPricePara:SetTitle("Live Gas Price" .. (sellEnabled and " 🟢 AutoSell ON" or " ⏸ AutoSell OFF"))
        GasPricePara:SetDesc(
            "Market: " .. priceStr ..
            "  |  Sell GUI: " .. sellStr ..
            "  |  Next change: " .. timerStr ..
            "\nTarget ≥ $" .. tostring(sellPrice) ..
            "  |  Min gas: " .. formatGas(minGasoline) ..
            (aboveTarget and "  ✅ SELL NOW" or "  ⏳ waiting")
        )

        task.wait(1)
    end
end)
