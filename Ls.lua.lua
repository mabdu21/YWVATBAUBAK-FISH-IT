repeat task.wait() until game:IsLoaded()

--// Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// Services
local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--// Window
local Window = Rayfield:CreateWindow({
   Name = "DYHUB | Sell Lemons",
   Icon = 104487529937663,
   LoadingTitle = "DYHUB Loaded! - Sell Lemons",
   LoadingSubtitle = "by dyumra",
   ShowText = "DYHUB",
   Theme = "Default",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "DYHUB_sl"
   },

   Discord = {
      Enabled = true,
      Invite = "jWNDPNMmyB",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "DYHUB",
      Subtitle = "Key System",
      Note = "idk",
      FileName = "idk",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"ifff"}
   }
})

local MainTab     = Window:CreateTab("Main",     4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- ============================================================
-- Config
-- ============================================================
local Config = {
    AutoBuy       = false,
    AutoUpgrade   = false,
    AutoFruit     = false,
    AutoClicker   = false,
    AutoCashDrops = false,

    BuyDelay         = 0.3,
    BuyScanInterval  = 0.5,
    UpgradeDelay     = 2.5,
    FruitDelay       = 0.2,
    ClickerDelay     = 0.5,

    CashDropWait             = 1,
    CashDropTeleportYOffset  = 2.25,
    CashDropScanInterval     = 0.25,

    MaxUpgradeLevel      = 100,
    FruitTeleportYOffset = 3,
}

-- ============================================================
-- State
-- ============================================================
local State = {
    Running    = true,
    UserTycoon = nil,

    Trees        = {},
    ClickParts   = {},
    ClickedParts = {},

    CashDrops     = {},
    CashDropConns = {},

    PurchaseEntries = {},

    Buying        = false,
    Upgrading     = false,
    FruitBusy     = false,
    CashDropsBusy = false,
}

local INCOME_STREAMS = {
    "LemonStand",
    "LemonDash",
    "LemonDepot",
    "LemonTrading",
    "LemonLabs",
    "LemonRobotics",
}

-- ============================================================
-- Utility
-- ============================================================
local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
    })
end

local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if not hrp or not hum or hum.Health <= 0 then
        return nil
    end

    return hrp
end

local function isAlive(obj)
    if not obj then return false end

    local ok, res = pcall(function()
        return obj:IsDescendantOf(Workspace)
    end)

    return ok and res
end

local function safeInvoke(remote, ...)
    if not isAlive(remote) then return false end

    local args = { ... }

    local ok, err = pcall(function()
        remote:InvokeServer(unpack(args))
    end)

    if not ok then
        warn("[LemonSells] InvokeServer:", err)
    end

    return ok
end

local function fireCD(cd)
    if not isAlive(cd) then return end

    if fireclickdetector then
        pcall(fireclickdetector, cd)
    else
        pcall(function()
            cd.MouseClick:Fire(LocalPlayer)
        end)
    end
end

local function safeStopVelocity(part)
    if not part or not part:IsA("BasePart") then return end

    pcall(function()
        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)
end

-- ============================================================
-- Tycoon finder
-- ============================================================
local function findUserTycoon()
    for _, v in ipairs(Workspace:GetChildren()) do
        local owner = v:FindFirstChild("Owner")
        if owner and owner.Value == LocalPlayer then
            return v
        end
    end

    return nil
end

local function refreshTycoon()
    State.UserTycoon = findUserTycoon()

    if not State.UserTycoon then
        notify("Error", "Tycoon not found!", 5)
        return false
    end

    return true
end

local function isValidTycoon()
    return State.UserTycoon ~= nil and State.UserTycoon.Parent ~= nil
end

-- ============================================================
-- Auto Buy
-- ============================================================
local function findButtonPart(remote)
    local parent = remote.Parent
    if not parent then return nil end

    local btn = parent:FindFirstChild("Button")
    if btn and btn:IsA("BasePart") then
        return btn
    end

    local gp = parent.Parent
    if gp then
        btn = gp:FindFirstChild("Button")
        if btn and btn:IsA("BasePart") then
            return btn
        end
    end

    for _, obj in ipairs(parent:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Button" then
            return obj
        end
    end

    return nil
end

local function isAffordable(entry)
    local btn = entry.buttonPart
    if not btn then return false end
    if not isAlive(btn) then return false end

    return btn.Transparency == 0
end

local function removeEntry(remote)
    local entry = State.PurchaseEntries[remote]
    if not entry then return end

    if entry.propConn then
        pcall(function()
            entry.propConn:Disconnect()
        end)
    end

    if entry.rmConn then
        pcall(function()
            entry.rmConn:Disconnect()
        end)
    end

    State.PurchaseEntries[remote] = nil
end

local function registerPurchaseRemote(remote)
    if not remote or not isAlive(remote) then return end
    if State.PurchaseEntries[remote] then return end

    local btn = findButtonPart(remote)

    local entry = {
        remote     = remote,
        buttonPart = btn,
        propConn   = nil,
        rmConn     = nil,
    }

    State.PurchaseEntries[remote] = entry

    if btn then
        local ok, conn = pcall(function()
            return btn:GetPropertyChangedSignal("Transparency"):Connect(function()
                if Config.AutoBuy and not State.Buying then
                    task.defer(function()
                        if not isAlive(remote) then
                            removeEntry(remote)
                            return
                        end

                        local e = State.PurchaseEntries[remote]
                        if not e then return end

                        if isAffordable(e) then
                            safeInvoke(remote, false)
                        end
                    end)
                end
            end)
        end)

        if ok then
            entry.propConn = conn
        end
    end

    local ok2, conn2 = pcall(function()
        return remote.AncestryChanged:Connect(function()
            if not isAlive(remote) then
                removeEntry(remote)
            end
        end)
    end)

    if ok2 then
        entry.rmConn = conn2
    end
end

local watchConn_Added   = nil
local watchConn_Removed = nil

local function scanPurchaseRemotes()
    for remote in pairs(State.PurchaseEntries) do
        if not isAlive(remote) then
            removeEntry(remote)
        end
    end

    if not isValidTycoon() then return 0 end

    local scanRoot = State.UserTycoon:FindFirstChild("Purchases", true) or State.UserTycoon

    for _, obj in ipairs(scanRoot:GetDescendants()) do
        if obj:IsA("RemoteFunction") and obj.Name == "Purchase" then
            if isAlive(obj) and obj:IsDescendantOf(State.UserTycoon) then
                registerPurchaseRemote(obj)
            end
        end
    end

    local cnt = 0
    for _ in pairs(State.PurchaseEntries) do
        cnt = cnt + 1
    end

    return cnt
end

local function watchPurchaseRemotes()
    if not isValidTycoon() then return end

    if watchConn_Added then
        pcall(function()
            watchConn_Added:Disconnect()
        end)
    end

    if watchConn_Removed then
        pcall(function()
            watchConn_Removed:Disconnect()
        end)
    end

    watchConn_Added = State.UserTycoon.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteFunction") and obj.Name == "Purchase" then
            task.defer(function()
                if isAlive(obj) and obj:IsDescendantOf(State.UserTycoon) then
                    registerPurchaseRemote(obj)
                end
            end)
        end
    end)

    watchConn_Removed = State.UserTycoon.DescendantRemoving:Connect(function(obj)
        if obj:IsA("RemoteFunction") and obj.Name == "Purchase" then
            removeEntry(obj)
        end
    end)
end

task.spawn(function()
    while State.Running do
        task.wait(Config.BuyScanInterval)

        if not Config.AutoBuy then continue end
        if State.Buying then continue end

        if not isValidTycoon() then
            refreshTycoon()
            continue
        end

        State.Buying = true

        for remote, entry in pairs(State.PurchaseEntries) do
            if not Config.AutoBuy or not State.Running then break end

            if not isAlive(remote) then
                removeEntry(remote)
                continue
            end

            if not isAffordable(entry) then
                continue
            end

            safeInvoke(remote, false)
            task.wait(Config.BuyDelay)
        end

        State.Buying = false
    end
end)

-- ============================================================
-- Auto Clicker
-- ============================================================
local function getWakeRemote()
    if not isValidTycoon() then return nil end

    local remotes = State.UserTycoon:FindFirstChild("Remotes")
    if not remotes then return nil end

    local wake = remotes:FindFirstChild("WakeIncomeStream")
    if not wake or not wake:IsA("RemoteFunction") then
        return nil
    end

    return wake
end

task.spawn(function()
    while State.Running do
        task.wait(Config.ClickerDelay)

        if not Config.AutoClicker then continue end

        if not isValidTycoon() then
            refreshTycoon()
            continue
        end

        local wake = getWakeRemote()
        if not wake then continue end

        for _, streamName in ipairs(INCOME_STREAMS) do
            if not Config.AutoClicker or not State.Running then break end

            safeInvoke(wake, streamName)
            task.wait(0.05)
        end
    end
end)

-- ============================================================
-- Auto Upgrade
-- ============================================================
local function getUpgradeRemotes()
    local result = {}

    if not isValidTycoon() then
        return result
    end

    for _, obj in ipairs(State.UserTycoon:GetDescendants()) do
        if obj.Name == "Upgrade" then
            if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                table.insert(result, obj)
            end
        end
    end

    return result
end

local function upgradeMachines()
    if State.Upgrading then return end

    State.Upgrading = true

    for _, remote in ipairs(getUpgradeRemotes()) do
        if not Config.AutoUpgrade or not State.Running then break end

        pcall(function()
            for level = 1, Config.MaxUpgradeLevel do
                if not Config.AutoUpgrade or not State.Running then break end

                if remote:IsA("RemoteFunction") then
                    remote:InvokeServer(level)
                else
                    remote:FireServer(level)
                end

                task.wait(0.05)
            end
        end)

        task.wait(0.2)
    end

    task.wait(Config.UpgradeDelay)
    State.Upgrading = false
end

task.spawn(function()
    while State.Running do
        task.wait(Config.UpgradeDelay)

        if Config.AutoUpgrade then
            upgradeMachines()
        end
    end
end)

-- ============================================================
-- CashDrops Tracker
-- ============================================================
local function getCashDropsFolder()
    return Workspace:FindFirstChild("CashDrops")
end

local function isCashDrop(obj)
    local folder = getCashDropsFolder()
    if not folder then return false end
    if not obj then return false end
    if obj.Name ~= "CashDrop" then return false end
    if not (obj:IsA("BasePart") or obj:IsA("Model")) then return false end

    return obj:IsDescendantOf(folder)
end

local function removeCashDrop(obj)
    if State.CashDropConns[obj] then
        pcall(function()
            State.CashDropConns[obj]:Disconnect()
        end)
    end

    State.CashDropConns[obj] = nil
    State.CashDrops[obj] = nil
end

local function clearCashDrops()
    for obj in pairs(State.CashDrops) do
        removeCashDrop(obj)
    end

    State.CashDrops = {}
    State.CashDropConns = {}
end

local function registerCashDrop(obj)
    if not isCashDrop(obj) then return end
    if State.CashDrops[obj] then return end

    State.CashDrops[obj] = true

    local ok, conn = pcall(function()
        return obj.AncestryChanged:Connect(function()
            if not obj:IsDescendantOf(Workspace) then
                removeCashDrop(obj)
            end
        end)
    end)

    if ok then
        State.CashDropConns[obj] = conn
    end
end

local function scanCashDrops()
    clearCashDrops()

    local folder = getCashDropsFolder()
    if not folder then return 0 end

    for _, obj in ipairs(folder:GetDescendants()) do
        registerCashDrop(obj)
    end

    for _, obj in ipairs(folder:GetChildren()) do
        registerCashDrop(obj)
    end

    local cnt = 0
    for _ in pairs(State.CashDrops) do
        cnt = cnt + 1
    end

    return cnt
end

local function countCashDrops()
    local cnt = 0

    for obj in pairs(State.CashDrops) do
        if isCashDrop(obj) and isAlive(obj) then
            cnt = cnt + 1
        else
            removeCashDrop(obj)
        end
    end

    return cnt
end

local function getCashDropCFrame(obj)
    if not isCashDrop(obj) then return nil end

    if obj:IsA("BasePart") then
        return obj.CFrame
    end

    local ok, cf = pcall(function()
        return obj:GetPivot()
    end)

    if ok then
        return cf
    end

    return nil
end

local function getCashDropList()
    local list = {}

    for obj in pairs(State.CashDrops) do
        if isCashDrop(obj) and isAlive(obj) then
            table.insert(list, obj)
        else
            removeCashDrop(obj)
        end
    end

    local hrp = getHRP()
    local basePos = hrp and hrp.Position or Vector3.new(0, 0, 0)

    table.sort(list, function(a, b)
        local cfa = getCashDropCFrame(a)
        local cfb = getCashDropCFrame(b)

        local da = cfa and (cfa.Position - basePos).Magnitude or math.huge
        local db = cfb and (cfb.Position - basePos).Magnitude or math.huge

        if math.abs(da - db) <= 0.01 then
            return a:GetFullName() < b:GetFullName()
        end

        return da < db
    end)

    return list
end

local function teleportToCashDrop(drop)
    local hrp = getHRP()
    if not hrp then return false end

    local cf = getCashDropCFrame(drop)
    if not cf then return false end

    local yOffset = Config.CashDropTeleportYOffset

    if drop:IsA("BasePart") then
        yOffset = math.max(yOffset, (drop.Size.Y / 2) + 1.75)
    end

    safeStopVelocity(hrp)
    hrp.CFrame = CFrame.new(cf.Position + Vector3.new(0, yOffset, 0))

    return true
end

local function collectCashDropsOnce()
    local list = getCashDropList()
    if #list <= 0 then return end

    for _, drop in ipairs(list) do
        if not State.Running or not Config.AutoCashDrops then break end

        if not isCashDrop(drop) or not isAlive(drop) then
            removeCashDrop(drop)
            continue
        end

        teleportToCashDrop(drop)
        task.wait(Config.CashDropWait)

        if not isAlive(drop) or not isCashDrop(drop) then
            removeCashDrop(drop)
        end
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if obj.Name == "CashDrops" then
            task.wait(0.1)
            scanCashDrops()
            return
        end

        if obj.Name == "CashDrop" then
            registerCashDrop(obj)
        end
    end)
end)

Workspace.DescendantRemoving:Connect(function(obj)
    if obj.Name == "CashDrop" then
        removeCashDrop(obj)
    end
end)

task.spawn(function()
    while State.Running do
        task.wait(Config.CashDropScanInterval)

        if not Config.AutoCashDrops then continue end
        if State.CashDropsBusy then continue end
        if State.FruitBusy then continue end

        if countCashDrops() <= 0 then
            continue
        end

        State.CashDropsBusy = true
        collectCashDropsOnce()
        State.CashDropsBusy = false
    end
end)

-- ============================================================
-- ClickPart / Tree Tracker
-- ============================================================
local function isFruitClickPart(part)
    if not part or not part:IsA("BasePart") then return false end
    if part.Name ~= "ClickPart" then return false end
    if not part:FindFirstChildOfClass("ClickDetector") then return false end

    local p = part.Parent
    if not p or p.Name ~= "Fruit" then return false end

    return true
end

local function registerClickPart(part)
    if not isFruitClickPart(part) then return end
    if State.ClickParts[part] then return end

    State.ClickParts[part] = true

    part.AncestryChanged:Connect(function()
        if not part:IsDescendantOf(Workspace) then
            State.ClickParts[part]   = nil
            State.ClickedParts[part] = nil
        end
    end)
end

local function scanClickParts()
    State.ClickParts   = {}
    State.ClickedParts = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        registerClickPart(obj)
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        registerClickPart(obj)

        if obj:IsA("ClickDetector") then
            local p = obj.Parent
            if p then
                registerClickPart(p)
            end
        end
    end)
end)

Workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Name == "ClickPart" then
        State.ClickParts[obj]   = nil
        State.ClickedParts[obj] = nil
    end
end)

local function addTree(obj)
    if not (obj:IsA("Model") and obj.Name == "LemonTree") then return end
    if State.Trees[obj] then return end

    State.Trees[obj] = true

    obj.AncestryChanged:Connect(function()
        if not obj:IsDescendantOf(Workspace) then
            State.Trees[obj] = nil
        end
    end)

    task.defer(function()
        for _, child in ipairs(obj:GetDescendants()) do
            registerClickPart(child)
        end
    end)

    obj.DescendantAdded:Connect(function(child)
        task.defer(function()
            registerClickPart(child)

            if child:IsA("ClickDetector") then
                local p = child.Parent
                if p then
                    registerClickPart(p)
                end
            end
        end)
    end)
end

local function scanTrees()
    State.Trees = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        addTree(obj)
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") and obj.Name == "LemonTree" then
        addTree(obj)
    end
end)

-- ============================================================
-- Auto Fruit
-- ============================================================
local function setNoCollision(model)
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false
        end
    end
end

local function teleportTo(cf)
    local hrp = getHRP()
    if not hrp then return false end

    safeStopVelocity(hrp)
    hrp.CFrame = CFrame.new(cf.Position + Vector3.new(0, Config.FruitTeleportYOffset, 0))

    return true
end

local function shouldCashDropsTakePriority()
    return Config.AutoCashDrops and countCashDrops() > 0
end

local function collectTree(tree)
    if not tree or not tree.Parent then return end

    if shouldCashDropsTakePriority() then
        return
    end

    setNoCollision(tree)

    if not teleportTo(tree:GetPivot()) then
        return
    end

    task.wait(0.12)

    for _, obj in ipairs(tree:GetDescendants()) do
        if not Config.AutoFruit or not State.Running then break end

        if shouldCashDropsTakePriority() then
            break
        end

        if not (obj:IsA("BasePart") and obj.Name == "ClickPart") then
            continue
        end

        if State.ClickedParts[obj] then
            continue
        end

        local cd = obj:FindFirstChildOfClass("ClickDetector")
        if not cd then
            continue
        end

        obj.CanCollide = false
        State.ClickedParts[obj] = true

        fireCD(cd)

        task.wait(Config.FruitDelay)
    end
end

task.spawn(function()
    while State.Running do
        task.wait(1)

        if not Config.AutoFruit then continue end
        if State.FruitBusy then continue end
        if State.CashDropsBusy then continue end

        if shouldCashDropsTakePriority() then
            continue
        end

        State.FruitBusy = true

        for tree in pairs(State.Trees) do
            if not Config.AutoFruit or not State.Running then break end

            if shouldCashDropsTakePriority() then
                break
            end

            collectTree(tree)
        end

        State.FruitBusy = false
    end
end)

-- ============================================================
-- UI — Main Tab
-- ============================================================
MainTab:CreateToggle({
    Name = "Auto Buy (All)",
    CurrentValue = false,
    Flag = "AutoBuy",
    Callback = function(v)
        Config.AutoBuy = v

        if v then
            refreshTycoon()
            local cnt = scanPurchaseRemotes()
            watchPurchaseRemotes()
            notify("Auto Buy", "Enabled | Remotes: " .. cnt)
        else
            notify("Auto Buy", "Disabled")
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Clicker (WakeStream)",
    CurrentValue = false,
    Flag = "AutoClicker",
    Callback = function(v)
        Config.AutoClicker = v

        if v then
            refreshTycoon()
        end

        notify("Auto Clicker", v and "Enabled" or "Disabled")
    end,
})

MainTab:CreateToggle({
    Name = "Auto Upgrade",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Callback = function(v)
        Config.AutoUpgrade = v
        notify("Auto Upgrade", v and "Enabled" or "Disabled")
    end,
})

MainTab:CreateToggle({
    Name = "Auto CashDrops (TP)",
    CurrentValue = false,
    Flag = "AutoCashDrops",
    Callback = function(v)
        Config.AutoCashDrops = v

        if v then
            local cnt = scanCashDrops()
            notify("Auto CashDrops", "Enabled | Drops: " .. cnt)
        else
            State.CashDropsBusy = false
            notify("Auto CashDrops", "Disabled")
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Fruit (TP)",
    CurrentValue = false,
    Flag = "AutoFruit",
    Callback = function(v)
        Config.AutoFruit = v
        notify("Auto Fruit (TP)", v and "Enabled" or "Disabled")
    end,
})

MainTab:CreateButton({
    Name = "Refresh Tycoon",
    Callback = function()
        refreshTycoon()

        if State.UserTycoon then
            local cnt = scanPurchaseRemotes()
            watchPurchaseRemotes()

            notify(
                "Refresh",
                "Tycoon: " .. State.UserTycoon.Name .. " | Remotes: " .. cnt
            )
        else
            notify("Refresh", "Not found.", 5)
        end
    end,
})

MainTab:CreateButton({
    Name = "Rescan CashDrops",
    Callback = function()
        local cnt = scanCashDrops()
        notify("CashDrops Scan", "Drops: " .. cnt)
    end,
})

MainTab:CreateButton({
    Name = "Rescan Trees & Fruits",
    Callback = function()
        scanTrees()
        scanClickParts()

        local tc, cc = 0, 0

        for _ in pairs(State.Trees) do
            tc = tc + 1
        end

        for _ in pairs(State.ClickParts) do
            cc = cc + 1
        end

        notify("Scan", "Trees: " .. tc .. " | ClickParts: " .. cc)
    end,
})

MainTab:CreateButton({
    Name = "Rescan Purchase Remotes",
    Callback = function()
        local cnt = scanPurchaseRemotes()
        watchPurchaseRemotes()
        notify("Purchase Scan", "Found " .. cnt .. " remote(s)")
    end,
})

MainTab:CreateButton({
    Name = "Debug: Affordable Now",
    Callback = function()
        local total, ready = 0, 0

        for _, entry in pairs(State.PurchaseEntries) do
            total = total + 1

            if isAffordable(entry) then
                ready = ready + 1
            end
        end

        notify("Debug Buy", "Total: " .. total .. " | Affordable (T=0): " .. ready)
    end,
})

MainTab:CreateButton({
    Name = "Clear Fruit Cache",
    Callback = function()
        State.ClickedParts = {}
        notify("Cache", "Fruit cache cleared.")
    end,
})

-- ============================================================
-- UI — Settings Tab
-- ============================================================
SettingsTab:CreateSlider({
    Name = "Buy Scan Interval",
    Range = {0.1, 3},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = Config.BuyScanInterval,
    Flag = "BuyScanInterval",
    Callback = function(v)
        Config.BuyScanInterval = v
    end,
})

SettingsTab:CreateSlider({
    Name = "Buy Fire Delay",
    Range = {0.1, 3},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = Config.BuyDelay,
    Flag = "BuyDelay",
    Callback = function(v)
        Config.BuyDelay = v
    end,
})

SettingsTab:CreateSlider({
    Name = "Clicker Delay",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = Config.ClickerDelay,
    Flag = "ClickerDelay",
    Callback = function(v)
        Config.ClickerDelay = v
    end,
})

SettingsTab:CreateSlider({
    Name = "Upgrade Delay",
    Range = {0.5, 10},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = Config.UpgradeDelay,
    Flag = "UpgradeDelay",
    Callback = function(v)
        Config.UpgradeDelay = v
    end,
})

SettingsTab:CreateSlider({
    Name = "Fruit Delay",
    Range = {0.05, 3},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = Config.FruitDelay,
    Flag = "FruitDelay",
    Callback = function(v)
        Config.FruitDelay = v
    end,
})

SettingsTab:CreateSlider({
    Name = "CashDrop Wait",
    Range = {0.3, 3},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = Config.CashDropWait,
    Flag = "CashDropWait",
    Callback = function(v)
        Config.CashDropWait = v
    end,
})

SettingsTab:CreateSlider({
    Name = "CashDrop TP Y Offset",
    Range = {0, 6},
    Increment = 0.05,
    Suffix = "Y",
    CurrentValue = Config.CashDropTeleportYOffset,
    Flag = "CashDropTeleportYOffset",
    Callback = function(v)
        Config.CashDropTeleportYOffset = v
    end,
})

SettingsTab:CreateSlider({
    Name = "Max Upgrade Level",
    Range = {1, 250},
    Increment = 1,
    Suffix = "Lv",
    CurrentValue = Config.MaxUpgradeLevel,
    Flag = "MaxUpgradeLevel",
    Callback = function(v)
        Config.MaxUpgradeLevel = v
    end,
})

SettingsTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        State.Running = false

        Config.AutoBuy       = false
        Config.AutoClicker   = false
        Config.AutoUpgrade   = false
        Config.AutoFruit     = false
        Config.AutoCashDrops = false

        if watchConn_Added then
            pcall(function()
                watchConn_Added:Disconnect()
            end)
        end

        if watchConn_Removed then
            pcall(function()
                watchConn_Removed:Disconnect()
            end)
        end

        for remote in pairs(State.PurchaseEntries) do
            removeEntry(remote)
        end

        clearCashDrops()

        Rayfield:Destroy()
    end,
})

-- ============================================================
-- Init
-- ============================================================
refreshTycoon()
scanTrees()
scanClickParts()

local cashCnt = scanCashDrops()
local initCnt = scanPurchaseRemotes()

watchPurchaseRemotes()

local tc, cc = 0, 0

for _ in pairs(State.Trees) do
    tc = tc + 1
end

for _ in pairs(State.ClickParts) do
    cc = cc + 1
end

notify(
    "Loaded",
    "Tycoon: " .. (State.UserTycoon and State.UserTycoon.Name or "?")
        .. " | Purchase: " .. initCnt
        .. " | Trees: " .. tc
        .. " | Fruits: " .. cc
        .. " | CashDrops: " .. cashCnt,
    6
)
