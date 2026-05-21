-- Powered by GPT 5 | v114
-- =========================
local version = "Rework"
local ver = "v011.7"
-- =========================

repeat task.wait() until game:IsLoaded()

-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- FPS Unlock
if setfpscap then
    setfpscap(1000000)
    WindUI:Notify({ Title = "Service", Content = "FPS Unlocked! | " .. ver, Duration = 3, Icon = "cpu" })
    warn("FPS Unlocked!")
else
    WindUI:Notify({ Title = "Not Working", Content = "Your exploit does not support setfpscap.", Duration = 3, Icon = "ban" })
end

-- Services (declare once at top)
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local LocalPlayer      = Players.LocalPlayer
local Character        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid         = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ====================== VERSION CHECK ======================
local FreeVersion    = "Free Version"
local PremiumVersion = "Premium Version"

local function checkVersion(playerName)
    local url = "https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua"
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then return FreeVersion end
    local func = loadstring(response)
    if not func then return FreeVersion end
    local premiumData = func()
    return premiumData and premiumData[playerName] and PremiumVersion or FreeVersion
end

local userversion = checkVersion(LocalPlayer.Name)

-- ====================== WINDOW ======================
local Window = WindUI:CreateWindow({
    Title = "DYHUB",
    IconThemed = true,
    Icon = "rbxassetid://104487529937663",
    Author = "Violence District | " .. userversion,
    Folder = "DYHUB_VD",
    Size = UDim2.fromOffset(500, 400),
    Transparent = true,
    Theme = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.K)

pcall(function()
    Window:Tag({ Title = version, Color = Color3.fromHex("#db7093") })
end)

Window:EditOpenButton({
    Title = "DYHUB - Open",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 255, 255)),
    Draggable = true,
})

-- ====================== CONFIG ======================
local ConfigData = {}
local ConfigPath = "DYHUB_VD/config.json"

local Config = {}

function Config:Get(key, default)
    return ConfigData[key] ~= nil and ConfigData[key] or default
end

function Config:Set(key, value)
    ConfigData[key] = value
end

function Config:Save()
    pcall(function()
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONEncode(ConfigData)
        end)
        if ok then writefile(ConfigPath, data) end
    end)
end

pcall(function()
    if isfile and isfile(ConfigPath) then
        local raw = readfile(ConfigPath)
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(raw)
        end)
        if ok and type(data) == "table" then
            ConfigData = data
        end
    end
end)

-- Tabs
local InfoTab      = Window:Tab({ Title = "Information",  Icon = "info" })
local Main1Divider = Window:Divider()
local SurTab       = Window:Tab({ Title = "Survivor",     Icon = "user-check" })
local killerTab    = Window:Tab({ Title = "Killer",       Icon = "swords" })
local Main2Divider = Window:Divider()
local MainTab      = Window:Tab({ Title = "Main",         Icon = "rocket" })
local EspTab       = Window:Tab({ Title = "Esp",          Icon = "eye" })
local PlayerTab    = Window:Tab({ Title = "Player",       Icon = "user" })
local Hitbox       = Window:Tab({ Title = "Hitbox",       Icon = "package" })
local TeleportTab  = Window:Tab({ Title = "Teleport",     Icon = "map-pin" })
local Main3Divider = Window:Divider()
local Main3        = Window:Tab({ Title = "Settings",     Icon = "settings" })

Window:SelectTab(1)

-- ====================== ESP SYSTEM (UPGRADED) ======================
-- Color config
local COLOR_SURVIVOR       = Color3.fromRGB(0, 0, 255)
local COLOR_MURDERER       = Color3.fromRGB(255, 0, 0)
local COLOR_GENERATOR      = Color3.fromRGB(255, 255, 255)
local COLOR_GENERATOR_DONE = Color3.fromRGB(0, 255, 0)
local COLOR_GATE           = Color3.fromRGB(255, 255, 255)
local COLOR_PALLET         = Color3.fromRGB(255, 255, 0)
local COLOR_OUTLINE        = Color3.fromRGB(0, 0, 0)
local COLOR_WINDOW         = Color3.fromRGB(175, 215, 230)
local COLOR_HOOK           = Color3.fromRGB(255, 0, 0)

-- State flags
local espEnabled        = false
local espSurvivor       = false
local espMurder         = false
local espGenerator      = false
local espGate           = false
local espHook           = false
local espPallet         = false
local espWindowEnabled  = false
local ShowName          = true
local ShowDistance      = true
local ShowHP            = true
local ShowHighlight     = true
local ShowPercent       = true

-- ESP object pool (cache)
local espObjects = {}

-- ── Optimised cache: scan workspace once, invalidate on DescendantAdded/Removing ──
local _cachedMapFolders    = nil
local _cachedGenFolders    = nil
local _cacheVersion        = 0   -- bump to force re-scan

local function _invalidateCache()
    _cachedMapFolders = nil
    _cachedGenFolders = nil
    _cacheVersion    += 1
end

-- Auto-invalidate when workspace changes
Workspace.DescendantAdded:Connect(_invalidateCache)
Workspace.DescendantRemoving:Connect(_invalidateCache)

-- Get every folder/model in workspace that contains named objects (lazy cache)
local function getMapFolders()
    if _cachedMapFolders then return _cachedMapFolders end

    local folders = {}

    -- Recursive: collect any Instance that has named game-objects as direct children
    local function scanContainer(container, depth)
        if depth > 6 then return end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Folder") or child:IsA("Model") then
                table.insert(folders, child)
                scanContainer(child, depth + 1)
            end
        end
    end

    scanContainer(Workspace, 0)
    _cachedMapFolders = folders
    return folders
end

-- Generator search: scan all workspace descendants (cached)
local function getFolderGenerator()
    if _cachedGenFolders then return _cachedGenFolders end

    local list = {}
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "Generator" and desc:IsA("Model") then
            table.insert(list, desc)
        end
    end
    _cachedGenFolders = list
    return list
end

-- Remove ESP from object
local function removeESP(obj)
    local data = espObjects[obj]
    if not data then return end
    if data.highlight then pcall(function() data.highlight:Destroy() end) end
    if data.bill then pcall(function() data.bill:Destroy() end) end
    espObjects[obj] = nil
end

-- Create / update ESP (lightweight: reuse existing instances)
local function createESP(obj, baseColor)
    if not obj or not obj.Parent then return end
    if obj.Name == "Lobby" then return end

    local data = espObjects[obj]
    if data then
        -- Just update color if already exists
        if data.highlight then
            data.highlight.FillColor    = baseColor
            data.highlight.OutlineColor = baseColor
            data.highlight.Enabled      = ShowHighlight
        end
        data.nameLabel.TextColor3 = baseColor
        data.hpLabel.TextColor3   = baseColor
        data.distLabel.TextColor3 = baseColor
        data.color = baseColor
        return
    end

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Adornee            = obj
    highlight.FillColor          = baseColor
    highlight.FillTransparency   = 0.8
    highlight.OutlineColor       = baseColor
    highlight.OutlineTransparency = 0.1
    highlight.Enabled            = ShowHighlight
    highlight.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
    pcall(function() highlight.Parent = obj end)

    -- BillboardGui
    local bill = Instance.new("BillboardGui")
    bill.Size        = UDim2.new(0, 200, 0, 50)
    bill.Adornee     = obj
    bill.AlwaysOnTop = true
    pcall(function() bill.Parent = obj end)

    local frame = Instance.new("Frame")
    frame.Size                 = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent               = bill

    local function makeLabel(ypos)
        local lbl = Instance.new("TextLabel")
        lbl.Size                    = UDim2.new(1, 0, 0.33, 0)
        lbl.Position                = UDim2.new(0, 0, ypos, 0)
        lbl.BackgroundTransparency  = 1
        lbl.Font                    = Enum.Font.SourceSansBold
        lbl.TextSize                = 14
        lbl.TextColor3              = baseColor
        lbl.TextStrokeColor3        = COLOR_OUTLINE
        lbl.TextStrokeTransparency  = 0
        lbl.Text                    = ""
        lbl.Parent                  = frame
        return lbl
    end

    local nameLabel = makeLabel(0)
    nameLabel.Text = obj.Name

    local hpLabel   = makeLabel(0.33)
    local distLabel = makeLabel(0.66)

    espObjects[obj] = {
        highlight = highlight,
        bill      = bill,
        nameLabel = nameLabel,
        hpLabel   = hpLabel,
        distLabel = distLabel,
        color     = baseColor,
    }
end

-- Generator progress helpers
local function getGeneratorProgress(gen)
    local progress = 0
    if gen:GetAttribute("Progress") then
        progress = gen:GetAttribute("Progress")
    elseif gen:GetAttribute("RepairProgress") then
        progress = gen:GetAttribute("RepairProgress")
    else
        for _, child in ipairs(gen:GetDescendants()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local n = child.Name:lower()
                if n:find("progress") or n:find("repair") or n:find("percent") then
                    progress = child.Value
                    break
                end
            end
        end
    end
    progress = (progress > 1) and progress / 100 or progress
    return math.clamp(progress, 0, 1)
end

local function getProgressColor(p)
    if p < 0.5 then
        local t = p / 0.5
        return Color3.fromRGB(math.floor(255 - (255 - 153) * t), 255, math.floor(255 - (255 - 153) * t))
    else
        local t = (p - 0.5) / 0.5
        return Color3.fromRGB(math.floor(153 * (1 - t)), 255, math.floor(153 * (1 - t)))
    end
end

local function generatorFinished(gen)
    return getGeneratorProgress(gen) >= 0.99 or gen:FindFirstChild("Finished") or gen:FindFirstChild("Repaired")
end

-- ── Main ESP update (runs on a throttled heartbeat, NOT RenderStepped) ──
local _espAccum = 0
local ESP_INTERVAL = 0.5   -- 2 Hz – plenty for labels, no lag

local function updateESP()
    if not espEnabled then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- ── Players ──
    for _, player in pairs(Players:GetPlayers()) do
        local char = player.Character
        if char and char ~= LocalPlayer.Character and char.Name ~= "Lobby" then
            local isMurderer = char:FindFirstChild("Weapon") ~= nil
            if isMurderer then
                if espMurder then createESP(char, COLOR_MURDERER)
                else removeESP(char) end
            else
                if espSurvivor then createESP(char, COLOR_SURVIVOR)
                else removeESP(char) end
            end
        end
    end

    -- ── World objects: scan workspace descendants (uses cache) ──
    -- We categorise by name for max flexibility (no hardcoded folder paths)
    local scanned = {}
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("Model") and not scanned[desc] then
            local n = desc.Name

            if n == "Generator" then
                scanned[desc] = true
                if espGenerator then
                    local progress  = getGeneratorProgress(desc)
                    local isFinished = generatorFinished(desc)
                    local col = isFinished and COLOR_GENERATOR_DONE or getProgressColor(progress)
                    createESP(desc, col)
                    -- Update percent label immediately
                    local data = espObjects[desc]
                    if data then
                        local part = desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local dist = math.floor((hrp.Position - part.Position).Magnitude)
                            if ShowName and ShowPercent then
                                data.nameLabel.Text    = n .. " | " .. math.floor(progress * 100) .. "%"
                                data.nameLabel.Visible = true
                            elseif ShowName then
                                data.nameLabel.Text    = n
                                data.nameLabel.Visible = true
                            else
                                data.nameLabel.Visible = false
                            end
                            if ShowDistance then
                                data.distLabel.Text    = "[ " .. dist .. " MM ]"
                                data.distLabel.Visible = true
                            else
                                data.distLabel.Visible = false
                            end
                            data.hpLabel.Visible = false
                            data.nameLabel.TextColor3 = col
                            data.distLabel.TextColor3 = col
                        end
                    end
                else
                    removeESP(desc)
                end

            elseif n == "Gate" then
                scanned[desc] = true
                if espGate then createESP(desc, COLOR_GATE)
                else removeESP(desc) end

            elseif n == "Hook" then
                scanned[desc] = true
                local mdl = desc:FindFirstChild("Model")
                if mdl then
                    if espHook then createESP(mdl, COLOR_HOOK)
                    else removeESP(mdl) end
                end

            elseif n == "Palletwrong" then
                scanned[desc] = true
                if espPallet then createESP(desc, COLOR_PALLET)
                else removeESP(desc) end

            elseif n == "Window" then
                scanned[desc] = true
                if espWindowEnabled then createESP(desc, COLOR_WINDOW)
                else removeESP(desc) end
            end
        end
    end

    -- ── Update labels for all tracked objects ──
    for obj, data in pairs(espObjects) do
        if not obj or not obj.Parent then
            removeESP(obj)
            continue
        end
        if obj.Name == "Lobby" then continue end

        local part = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if not part then continue end

        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        local isPlayer = humanoid ~= nil

        -- Name
        if not data.nameLabel.Text:find("|") then   -- don't overwrite percent label for generators
            data.nameLabel.Visible = ShowName
        end

        if isPlayer then
            -- HP
            if ShowHP and humanoid then
                data.hpLabel.Text    = "[ " .. math.floor(humanoid.Health) .. " HP ]"
                data.hpLabel.Visible = true
                data.hpLabel.Position = UDim2.new(0, 0, 0.33, 0)
                data.distLabel.Position = UDim2.new(0, 0, 0.66, 0)
            else
                data.hpLabel.Text    = ""
                data.hpLabel.Visible = false
                data.distLabel.Position = UDim2.new(0, 0, 0.33, 0)
            end
            -- Distance
            if ShowDistance then
                local dist = math.floor((hrp.Position - part.Position).Magnitude)
                data.distLabel.Text    = "[ " .. dist .. " MM ]"
                data.distLabel.Visible = true
            else
                data.distLabel.Text    = ""
                data.distLabel.Visible = false
            end
        else
            data.hpLabel.Text    = ""
            data.hpLabel.Visible = false
            if ShowDistance then
                local dist = math.floor((hrp.Position - part.Position).Magnitude)
                data.distLabel.Text     = "[ " .. dist .. " MM ]"
                data.distLabel.Visible  = true
                data.distLabel.Position = UDim2.new(0, 0, 0.33, 0)
            else
                data.distLabel.Text    = ""
                data.distLabel.Visible = false
            end
        end

        if data.highlight then
            data.highlight.Enabled = ShowHighlight
        end
    end
end

-- ── Heartbeat throttle (no RenderStepped for world ESP = less lag) ──
RunService.Heartbeat:Connect(function(dt)
    _espAccum += dt
    if _espAccum >= ESP_INTERVAL then
        _espAccum = 0
        pcall(updateESP)
    end
end)

-- Clean up on player leave
Players.PlayerRemoving:Connect(function(player)
    if player.Character then removeESP(player.Character) end
end)

-- ====================== ESP UI ======================
EspTab:Section({ Title = "Feature Esp", Icon = "eye" })
EspTab:Toggle({ Title = "Enable ESP", Value = false, Callback = function(v)
    espEnabled = v
    if not espEnabled then
        for obj in pairs(espObjects) do removeESP(obj) end
    end
end })

EspTab:Section({ Title = "Esp Role", Icon = "user" })
EspTab:Toggle({ Title = "ESP Survivor", Value = false, Callback = function(v) espSurvivor = v end })
EspTab:Toggle({ Title = "ESP Killer",   Value = false, Callback = function(v) espMurder   = v end })

EspTab:Section({ Title = "Esp Engine", Icon = "biceps-flexed" })
EspTab:Toggle({ Title = "ESP Generator", Value = false, Callback = function(v) espGenerator = v end })
EspTab:Toggle({ Title = "ESP Gate",      Value = false, Callback = function(v) espGate      = v end })

EspTab:Section({ Title = "Esp Object", Icon = "package" })
EspTab:Toggle({ Title = "ESP Pallet", Value = false, Callback = function(v) espPallet        = v end })
EspTab:Toggle({ Title = "ESP Hook",   Value = false, Callback = function(v) espHook          = v end })
EspTab:Toggle({ Title = "ESP Window", Value = false, Callback = function(v) espWindowEnabled = v end })

EspTab:Section({ Title = "Esp Settings", Icon = "settings" })
EspTab:Toggle({ Title = "Show Name",      Value = ShowName,      Callback = function(v) ShowName      = v end })
EspTab:Toggle({ Title = "Show Distance",  Value = ShowDistance,  Callback = function(v) ShowDistance  = v end })
EspTab:Toggle({ Title = "Show Health",    Value = ShowHP,        Callback = function(v) ShowHP        = v end })
EspTab:Toggle({ Title = "Show Highlight", Value = ShowHighlight, Callback = function(v) ShowHighlight = v end })
EspTab:Toggle({ Title = "Show Percent",   Value = ShowPercent,   Callback = function(v) ShowPercent   = v end })

-- ====================== MAIN TAB ======================
MainTab:Section({ Title = "Feature Gameplay", Icon = "target" })

MainTab:Button({
    Title = "Aimbot (NEW)",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/Y6ui9r3d/raw"))()
    end
})

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CrosshairEnabled = false
local Crosshair

local function CreateCrosshair()
    if PlayerGui:FindFirstChild("CrosshairGUI") then return end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrosshairGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui
    local Frame = Instance.new("Frame")
    Frame.Name = "Crosshair"
    Frame.Size = UDim2.new(0, 5, 0, 5)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.BackgroundColor3 = Color3.new(1, 1, 1)
    Frame.BackgroundTransparency = 0.3
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 999
    Frame.Parent = ScreenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = Frame
    Crosshair = Frame
    Frame:GetPropertyChangedSignal("Visible"):Connect(function()
        if CrosshairEnabled and not Frame.Visible then Frame.Visible = true end
    end)
end

local function RemoveCrosshair()
    local gui = PlayerGui:FindFirstChild("CrosshairGUI")
    if gui then gui:Destroy() end
end

PlayerGui.ChildRemoved:Connect(function(child)
    if child.Name == "CrosshairGUI" and CrosshairEnabled then
        task.defer(CreateCrosshair)
    end
end)

MainTab:Toggle({
    Title = "Enable Cursor (Recommended)",
    Value = false,
    Callback = function(state)
        CrosshairEnabled = state
        if state then CreateCrosshair() else RemoveCrosshair() end
    end
})

-- Bypass Gate
local bypassGateEnabled = false

local function gatherGates()
    local gates = {}
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "Gate" and desc:IsA("Model") then
            table.insert(gates, desc)
        end
    end
    return gates
end

local function setGateState(enabled)
    for _, gate in pairs(gatherGates()) do
        local leftGate  = gate:FindFirstChild("LeftGate")
        local rightGate = gate:FindFirstChild("RightGate")
        local leftEnd   = gate:FindFirstChild("LeftGate-end")
        local rightEnd  = gate:FindFirstChild("RightGate-end")
        local box       = gate:FindFirstChild("Box")
        if enabled then
            if leftGate  then leftGate.Transparency  = 1; leftGate.CanCollide  = false end
            if rightGate then rightGate.Transparency = 1; rightGate.CanCollide = false end
            if leftEnd   then leftEnd.Transparency   = 0; leftEnd.CanCollide   = true  end
            if rightEnd  then rightEnd.Transparency  = 0; rightEnd.CanCollide  = true  end
            if box       then box.CanCollide         = false end
        else
            if leftGate  then leftGate.Transparency  = 0; leftGate.CanCollide  = true  end
            if rightGate then rightGate.Transparency = 0; rightGate.CanCollide = true  end
            if leftEnd   then leftEnd.Transparency   = 1; leftEnd.CanCollide   = true  end
            if rightEnd  then rightEnd.Transparency  = 1; rightEnd.CanCollide  = true  end
            if box       then box.CanCollide         = true  end
        end
    end
end

MainTab:Section({ Title = "Feature Bypass", Icon = "lock-open" })
MainTab:Toggle({
    Title = "Bypass Gate (Open Gate)",
    Value = false,
    Callback = function(state)
        bypassGateEnabled = state
        setGateState(state)
    end
})

-- Visual
local fullBrightEnabled = false
local noFogEnabled      = false

MainTab:Section({ Title = "Feature Visual", Icon = "lightbulb" })
MainTab:Toggle({
    Title = "Full Bright",
    Value = false,
    Callback = function(v)
        fullBrightEnabled = v
        if v then
            task.spawn(function()
                while fullBrightEnabled do
                    if Lighting.Brightness ~= 2 then Lighting.Brightness = 2 end
                    if Lighting.ClockTime  ~= 14 then Lighting.ClockTime  = 14 end
                    if Lighting.Ambient    ~= Color3.fromRGB(255,255,255) then Lighting.Ambient = Color3.fromRGB(255,255,255) end
                    task.wait(0.5)
                end
            end)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime  = 12
            Lighting.Ambient    = Color3.fromRGB(128,128,128)
        end
    end
})
MainTab:Toggle({
    Title = "No Fog",
    Value = false,
    Callback = function(v)
        noFogEnabled = v
        if v then
            task.spawn(function()
                while noFogEnabled do
                    local atm = Lighting:FindFirstChild("Atmosphere")
                    if atm and atm.Density ~= 0 then atm.Density = 0 end
                    task.wait(0.5)
                end
            end)
        else
            local atm = Lighting:FindFirstChild("Atmosphere")
            if atm then atm.Density = 0.5 end
        end
    end
})

MainTab:Section({ Title = "Misc", Icon = "settings" })
local AntiAFK = false
MainTab:Toggle({
    Title = "Anti AFK",
    Value = true,
    Callback = function(state)
        AntiAFK = state
        task.spawn(function()
            local vu = game:GetService("VirtualUser")
            while AntiAFK do
                vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(math.random(150, 270))
                vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(math.random(150, 270))
            end
        end)
    end
})

-- ====================== SURVIVOR TAB ======================
SurTab:Section({ Title = "Feature Survivor", Icon = "user" })

local autoShoot = false
SurTab:Toggle({
    Title = "Auto Shoot (STILL BUG)",
    Value = false,
    Callback = function(v)
        autoShoot = v
        if autoShoot then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Parrying Dagger"):WaitForChild("parry")
                while autoShoot do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Weapon") then
                                local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                                if tr and (root.Position - tr.Position).Magnitude <= 10 then
                                    remote:FireServer()
                                end
                            end
                        end
                    end
                    task.wait(0.001)
                end
            end)
        end
    end
})

local autoparry = false
SurTab:Toggle({
    Title = "Auto Parry (STILL BUG)",
    Value = false,
    Callback = function(v)
        autoparry = v
        if autoparry then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Parrying Dagger"):WaitForChild("parry")
                while autoparry do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Weapon") then
                                local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                                if tr and (root.Position - tr.Position).Magnitude <= 10 then
                                    remote:FireServer()
                                end
                            end
                        end
                    end
                    task.wait(0.001)
                end
            end)
        end
    end
})

-- Generator Section
SurTab:Section({ Title = "Feature Generator", Icon = "zap" })

-- Helper: find closest generator point
local function getClosestGeneratorPoint(root, maxDist)
    local gens = getFolderGenerator()
    local bestGen, bestPt, bestDist = nil, nil, maxDist or 10
    for _, gen in ipairs(gens) do
        for i = 1, 4 do
            local pt = gen:FindFirstChild("GeneratorPoint" .. i)
            if pt then
                local d = (root.Position - pt.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    bestGen  = gen
                    bestPt   = pt
                end
            end
        end
    end
    return bestGen, bestPt, bestDist
end

-- Auto SkillCheck Perfect
local autoGeneratorEnabledtest = false
SurTab:Toggle({
    Title = "Auto SkillCheck (Perfect)",
    Value = false,
    Callback = function(v)
        autoGeneratorEnabledtest = v
        if autoGeneratorEnabledtest then
            task.spawn(function()
                local playerGui  = LocalPlayer:WaitForChild("PlayerGui")
                local skillRemote  = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("SkillCheckResultEvent")
                local repairRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("RepairEvent")
                local lastGenPoint, lastGenModel = nil, nil

                while autoGeneratorEnabledtest do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum  = char and char:FindFirstChild("Humanoid")
                    if root and hum then
                        local isMoving = hum.MoveDirection.Magnitude > 0.05
                        local genModel, genPoint = getClosestGeneratorPoint(root)
                        if not lastGenPoint and genPoint then
                            lastGenModel = genModel
                            lastGenPoint = genPoint
                        end
                        if isMoving and lastGenPoint then
                            repairRemote:FireServer(lastGenPoint, false)
                            task.wait(0.2)
                            lastGenPoint = nil; lastGenModel = nil
                        end
                        local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                        if gui then
                            local check = gui:FindFirstChild("Check")
                            if check and check.Visible and lastGenPoint then
                                local d = (root.Position - lastGenPoint.Position).Magnitude
                                if d < 6 and lastGenModel then
                                    skillRemote:FireServer("success", 1, lastGenModel, lastGenPoint)
                                    check.Visible = false
                                end
                            end
                        end
                    end
                    task.wait(0.15)
                end
            end)
        end
    end
})

-- Auto SkillCheck Not Perfect
local autoGeneratorEnabled = false
SurTab:Toggle({
    Title = "Auto SkillCheck (Not Perfect)",
    Value = false,
    Callback = function(v)
        autoGeneratorEnabled = v
        if autoGeneratorEnabled then
            task.spawn(function()
                local playerGui    = LocalPlayer:WaitForChild("PlayerGui")
                local skillRemote  = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("SkillCheckResultEvent")
                local repairRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("RepairEvent")
                local lastGenPoint, lastGenModel = nil, nil

                while autoGeneratorEnabled do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum  = char and char:FindFirstChild("Humanoid")
                    if root and hum then
                        local isMoving = hum.MoveDirection.Magnitude > 0.05
                        local genModel, genPoint = getClosestGeneratorPoint(root)
                        if not lastGenPoint and genPoint then
                            lastGenModel = genModel
                            lastGenPoint = genPoint
                        end
                        if isMoving and lastGenPoint then
                            repairRemote:FireServer(lastGenPoint, false)
                            task.wait(0.2)
                            lastGenPoint = nil; lastGenModel = nil
                        end
                        local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                        if gui then
                            local check = gui:FindFirstChild("Check")
                            if check and check.Visible and lastGenPoint then
                                local d = (root.Position - lastGenPoint.Position).Magnitude
                                if d < 6 and lastGenModel then
                                    skillRemote:FireServer("neutral", 0, lastGenModel, lastGenPoint)
                                    check.Visible = false
                                end
                            end
                        end
                    end
                    task.wait(0.15)
                end
            end)
        end
    end
})

-- ── Auto Generator (Auto Repair / Teleport to gen) ──
local autoGenRepairEnabled = false
SurTab:Toggle({
    Title = "Auto Generator (Teleport + Repair)",
    Value = false,
    Callback = function(v)
        autoGenRepairEnabled = v
        if autoGenRepairEnabled then
            task.spawn(function()
                local repairRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("RepairEvent")
                while autoGenRepairEnabled do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- Find unfinished generator
                        local gens = getFolderGenerator()
                        local target, targetPt = nil, nil
                        local minDist = math.huge
                        for _, gen in ipairs(gens) do
                            if not generatorFinished(gen) then
                                for i = 1, 4 do
                                    local pt = gen:FindFirstChild("GeneratorPoint" .. i)
                                    if pt then
                                        local d = (root.Position - pt.Position).Magnitude
                                        if d < minDist then
                                            minDist = d
                                            target  = gen
                                            targetPt = pt
                                        end
                                    end
                                end
                            end
                        end
                        if target and targetPt then
                            -- Teleport close to gen
                            root.CFrame = CFrame.new(targetPt.Position + Vector3.new(0, 2, 0))
                            task.wait(0.1)
                            repairRemote:FireServer(targetPt, true)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

SurTab:Section({ Title = "Feature Exit", Icon = "door-open" })

local autoLeverEnabled = false
SurTab:Toggle({
    Title = "Auto Lever (No Hold)",
    Value = false,
    Callback = function(v)
        autoLeverEnabled = v
        if autoLeverEnabled then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Exit"):WaitForChild("LeverEvent")
                local isTouching = false
                local _tc = UserInputService.TouchStarted:Connect(function() isTouching = true end)
                local _te = UserInputService.TouchEnded:Connect(function() isTouching = false end)
                local lastPos = nil

                while autoLeverEnabled do
                    local char     = LocalPlayer.Character
                    local root     = char and char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    if root and humanoid then
                        local closestMain, shortestDist = nil, nil
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj.Name == "ExitLever" then
                                local main = obj:FindFirstChild("Main")
                                if main then
                                    local d = (root.Position - main.Position).Magnitude
                                    if not shortestDist or d < shortestDist then
                                        shortestDist = d
                                        closestMain  = main
                                    end
                                end
                            end
                        end
                        local moved = lastPos and (root.Position - lastPos).Magnitude > 0.5
                        local tryMove = false
                        if UserInputService.KeyboardEnabled then
                            for _, key in ipairs({ Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space }) do
                                if UserInputService:IsKeyDown(key) then tryMove = true; break end
                            end
                        end
                        if UserInputService.TouchEnabled and isTouching then tryMove = true end
                        if (moved or tryMove) and closestMain then
                            remote:FireServer(closestMain, false)
                        elseif closestMain and shortestDist and shortestDist <= 10 then
                            remote:FireServer(closestMain, true)
                        end
                        lastPos = root.Position
                    end
                    task.wait(0.2)
                end
                _tc:Disconnect(); _te:Disconnect()
            end)
        end
    end
})

SurTab:Section({ Title = "Feature Heal", Icon = "cross" })

local function getHealth(plr)
    if not plr.Character then return 100 end
    local hum = plr.Character:FindFirstChild("Humanoid")
    if hum then return hum.Health end
    local h = plr.Character:FindFirstChild("Health")
    if h and h.Value then return h.Value end
    return 100
end

local function getClosestLowHPPlayer(root, maxDist)
    local closest, closestDist = nil, maxDist or 6
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp and getHealth(plr) <= 60 then
                local d = (root.Position - hrp.Position).Magnitude
                if d < closestDist then closest = plr; closestDist = d end
            end
        end
    end
    return closest
end

local autoHealEnabled = false
SurTab:Toggle({
    Title = "Auto Heal SkillCheck (STILL BUG)",
    Value = false,
    Callback = function(v)
        autoHealEnabled = v
        if autoHealEnabled then
            task.spawn(function()
                local playerGui  = LocalPlayer:WaitForChild("PlayerGui")
                local healRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Healing"):WaitForChild("SkillCheckResultEvent")
                local lastHealTarget = nil
                while autoHealEnabled do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum  = char and char:FindFirstChild("Humanoid")
                    if root and hum then
                        local isMoving = hum.MoveDirection.Magnitude > 0.05
                        local target = getClosestLowHPPlayer(root)
                        if not lastHealTarget and target then lastHealTarget = target end
                        if isMoving then lastHealTarget = nil end
                        local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                        if gui then
                            local check = gui:FindFirstChild("Check")
                            if check and check.Visible and lastHealTarget then
                                if getHealth(lastHealTarget) <= 60 and lastHealTarget.Character then
                                    healRemote:FireServer("success", 1, lastHealTarget.Character)
                                    check.Visible = false
                                end
                            end
                        end
                    end
                    task.wait(0.15)
                end
            end)
        end
    end
})

local autoHealEnabled2 = false
SurTab:Toggle({
    Title = "Auto Heal SkillCheck v2 (STILL BUG)",
    Value = false,
    Callback = function(v)
        autoHealEnabled2 = v
        if autoHealEnabled2 then
            task.spawn(function()
                local playerGui  = LocalPlayer:WaitForChild("PlayerGui")
                local healRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Healing"):WaitForChild("SkillCheckResultEvent")
                local lastHealTarget = nil
                while autoHealEnabled2 do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum  = char and char:FindFirstChild("Humanoid")
                    if root and hum then
                        local isMoving = hum.MoveDirection.Magnitude > 0.05
                        local target = getClosestLowHPPlayer(root)
                        if not lastHealTarget and target then lastHealTarget = target end
                        if isMoving then lastHealTarget = nil end
                        local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                        if gui then
                            local check = gui:FindFirstChild("Check")
                            if check and check.Visible and lastHealTarget then
                                if getHealth(lastHealTarget) <= 60 and lastHealTarget.Character then
                                    healRemote:FireServer("success", 1, lastHealTarget.Character)
                                    check.Visible = false
                                end
                            end
                        end
                    end
                    task.wait(0.15)
                end
            end)
        end
    end
})

SurTab:Section({ Title = "Feature Cheat", Icon = "bug" })

-- Fling
SurTab:Button({
    Title = "Fling Killer (Spam if doesn't fling)",
    Callback = function()
        local Targets = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Weapon") then
                table.insert(Targets, plr.Name)
            end
        end

        local AllBool = false
        local function GetPlayer(Name)
            Name = Name:lower()
            if Name == "all" or Name == "others" then AllBool = true; return end
            if Name == "random" then
                local pl = Players:GetPlayers()
                if table.find(pl, LocalPlayer) then table.remove(pl, table.find(pl, LocalPlayer)) end
                return pl[math.random(#pl)]
            end
            for _, x in next, Players:GetPlayers() do
                if x ~= LocalPlayer then
                    if x.Name:lower():match("^" .. Name) or x.DisplayName:lower():match("^" .. Name) then return x end
                end
            end
        end
        local function Message(_T, _t, t) game:GetService("StarterGui"):SetCore("SendNotification", { Title = _T, Text = _t, Duration = t }) end
        local function SkidFling(TargetPlayer)
            local Character = LocalPlayer.Character
            local Humanoid  = Character and Character:FindFirstChildOfClass("Humanoid")
            local RootPart  = Humanoid and Humanoid.RootPart
            local TCharacter = TargetPlayer.Character
            local THumanoid  = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")
            local TRootPart  = TCharacter and TCharacter:FindFirstChild("HumanoidRootPart")
            local THead      = TCharacter and TCharacter:FindFirstChild("Head")
            local Accessory  = TCharacter and TCharacter:FindFirstChildOfClass("Accessory")
            local Handle     = Accessory and Accessory:FindFirstChild("Handle")
            if not (Character and Humanoid and RootPart) then return Message("Error", "Script Failed", 5) end
            if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
            if THumanoid and THumanoid.Sit and not AllBool then return Message("Error", "Target is sitting", 5) end
            if THead then Workspace.CurrentCamera.CameraSubject = THead
            elseif Handle then Workspace.CurrentCamera.CameraSubject = Handle
            elseif THumanoid then Workspace.CurrentCamera.CameraSubject = THumanoid end
            if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
            local FPos = function(BasePart, Pos, Ang)
                RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                RootPart.Velocity    = Vector3.new(9e7, 9e7 * 10, 9e7)
                RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end
            local SFBasePart = function(BasePart)
                local Time, Angle = tick(), 0
                repeat
                    if RootPart and THumanoid then
                        if BasePart.Velocity.Magnitude < 50 then
                            Angle += 100
                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                        else
                            FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                        end
                    else break end
                until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + 2
            end
            Workspace.FallenPartsDestroyHeight = 0 / 0
            local BV = Instance.new("BodyVelocity")
            BV.Name = "DYHUB-YES"; BV.Parent = RootPart
            BV.Velocity = Vector3.new(9e9, 9e9, 9e9)
            BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            if TRootPart and THead then
                if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end
            elseif TRootPart then SFBasePart(TRootPart)
            elseif THead then SFBasePart(THead)
            elseif Handle then SFBasePart(Handle)
            else return Message("Error", "Target missing everything", 5) end
            BV:Destroy()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            Workspace.CurrentCamera.CameraSubject = Humanoid
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, x in ipairs(Character:GetChildren()) do
                    if x:IsA("BasePart") then x.Velocity = Vector3.new(); x.RotVelocity = Vector3.new() end
                end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            Workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
        if not getgenv().Welcome then Message("DYHUB | FLING", "THANK FOR USING", 6) end
        getgenv().Welcome = true
        if AllBool then for _, x in next, Players:GetPlayers() do SkidFling(x) end end
        for _, x in next, Targets do
            local TPlayer = GetPlayer(x)
            if TPlayer and TPlayer ~= LocalPlayer then
                if TPlayer.UserId ~= 4340578793 then SkidFling(TPlayer)
                else Message("ERROR", "CANT FLING OWNER", 8) end
            end
        end
    end
})

SurTab:Button({
    Title = "Invisible (Not Visual)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/mabdu21/kjandsaddjadbhahayenajhsjbdwa/refs/heads/main/INV.lua"))()
    end
})

SurTab:Button({
    Title = "Self UnHook (Not 100%)",
    Callback = function()
        ReplicatedStorage.Remotes.Carry.SelfUnHookEvent:FireServer()
    end
})

-- ====================== KILLER TAB ======================
local DYHUB_AimbotEnabled        = false
local DYHUB_Aimbot28Enabled      = false
local DYHUB_LockedTarget         = nil
local DYHUB_CloseDistance        = 10
local DYHUB_PredictionTime       = 0.14
local DYHUB_MIN_DISTANCE         = 1
local DYHUB_MAX_DISTANCE         = 250
local DYHUB_MIN_PITCH            = -1
local DYHUB_MAX_PITCH            = 30
local DYHUB_LOW_HP_IGNORE        = 20
local DYHUB_ToughWall            = true
local DYHUB_AimbotToggleGUIVisible   = false
local DYHUB_Aimbot28ToggleGUIVisible = false
local DYHUB_crosshair, DYHUB_mobileButton, DYHUB_mobileButton28, DYHUB_guiFolder

local DYHUB_Settings = {
    Aimbot = {
        DragUI = false,
        MobileButtonPosition   = UDim2.new(1, -40, 1, -40),
        MobileButton28Position = UDim2.new(1, -140, 1, -40),
        SetKeybindLock   = "Z",
        SetKeybindLock28 = "X"
    }
}

local Camera = Workspace.CurrentCamera

killerTab:Section({ Title = "Killer: The Veil", Icon = "target" })
killerTab:Paragraph({
    Title = "Information: The Veil",
    Desc  = "• Aimbot is currently in BETA.\n• There is a chance of missing.\n• Aimbot will not support people at high places.",
    Image = "rbxassetid://104487529937663",
    ImageSize = 50,
    Locked = false
})

killerTab:Toggle({
    Title = "Enable Aimbot (The Veil)", Default = false,
    Callback = function(state)
        if state and DYHUB_Aimbot28Enabled then
            DYHUB_Aimbot28Enabled = false
            if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        DYHUB_AimbotEnabled = state
        if DYHUB_mobileButton then
            DYHUB_mobileButton.BackgroundColor3 = DYHUB_AimbotEnabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
        end
    end
})

killerTab:Toggle({
    Title = "Enable Aimbot Charge (The Veil)", Default = false,
    Callback = function(state)
        if state and DYHUB_AimbotEnabled then
            DYHUB_AimbotEnabled = false
            if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        DYHUB_Aimbot28Enabled = state
        if DYHUB_mobileButton28 then
            DYHUB_mobileButton28.BackgroundColor3 = DYHUB_Aimbot28Enabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
        end
    end
})

killerTab:Section({ Title = "Killer: The Veil Setting", Icon = "settings" })
killerTab:Input({ Title = "Set Pitch Min", Default = tostring(DYHUB_MIN_PITCH), Placeholder = "Ex: -1", Callback = function(v) local n = tonumber(v) if n then DYHUB_MIN_PITCH = n end end })
killerTab:Input({ Title = "Set Pitch Max", Default = tostring(DYHUB_MAX_PITCH), Placeholder = "Ex: 30",  Callback = function(v) local n = tonumber(v) if n then DYHUB_MAX_PITCH = n end end })
killerTab:Toggle({ Title = "Tough Wall (The Veil)", Value = true, Callback = function(v) DYHUB_ToughWall = v end })
killerTab:Input({ Title = "Set Keybind Aimbot (PC)", Default = DYHUB_Settings.Aimbot.SetKeybindLock, Placeholder = "Ex: Z", Callback = function(v) if #v == 1 then DYHUB_Settings.Aimbot.SetKeybindLock = v:upper() end end })
killerTab:Input({ Title = "Set Keybind Aimbot Charge (PC)", Default = DYHUB_Settings.Aimbot.SetKeybindLock28, Placeholder = "Ex: X", Callback = function(v) if #v == 1 then DYHUB_Settings.Aimbot.SetKeybindLock28 = v:upper() end end })

killerTab:Section({ Title = "Killer: The Veil GUI", Icon = "settings" })
killerTab:Toggle({
    Title = "Enable Aimbot (Toggle GUI)", Default = DYHUB_AimbotToggleGUIVisible,
    Callback = function(v)
        DYHUB_AimbotToggleGUIVisible = v
        if DYHUB_mobileButton then DYHUB_mobileButton.Visible = v end
    end
})
killerTab:Toggle({
    Title = "Enable Aimbot Charge (Toggle GUI)", Default = DYHUB_Aimbot28ToggleGUIVisible,
    Callback = function(v)
        DYHUB_Aimbot28ToggleGUIVisible = v
        if DYHUB_mobileButton28 then DYHUB_mobileButton28.Visible = v end
    end
})
killerTab:Toggle({
    Title = "Custom Position Drag (Toggle GUI)", Default = DYHUB_Settings.Aimbot.DragUI,
    Callback = function(state)
        DYHUB_Settings.Aimbot.DragUI = state
        -- drag logic handled in DYHUB_EnableDrag below
    end
})

-- Helper functions
local function DYHUB_GetLocalRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function DYHUB_HP_OK(plr)
    local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
    return hum and hum.Health > DYHUB_LOW_HP_IGNORE
end
local function DYHUB_GetClosestInScreen()
    local closest, minDist = nil, math.huge
    local mouse = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and DYHUB_HP_OK(plr) then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                    if d < minDist then minDist = d; closest = plr end
                end
            end
        end
    end
    return closest
end
local function DYHUB_GetClosestByDistance()
    local root = DYHUB_GetLocalRoot()
    if not root then return nil end
    local closest, distMin = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and DYHUB_HP_OK(plr) then
            local r = plr.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (root.Position - r.Position).Magnitude
                if d < distMin then distMin = d; closest = plr end
            end
        end
    end
    return closest, distMin
end
local function DYHUB_CanSeeTarget(target)
    if DYHUB_ToughWall then return true end
    local head = target.Character and target.Character:FindFirstChild("Head")
    local root = DYHUB_GetLocalRoot()
    if not head or not root then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LocalPlayer.Character or {}, target.Character }
    local result = Workspace:Raycast(root.Position + Vector3.new(0, 2, 0), head.Position - root.Position, params)
    return not result
end
local function DYHUB_GetAutoPitchMax(dist)
    if dist >= 190 then return 45.5
    elseif dist >= 150 then return 40.5
    elseif dist >= 90  then return 36.5
    else return 30.5 end
end

-- Aim functions
local function DYHUB_AimAt_Normal(target)
    if not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    local hrp  = target.Character:FindFirstChild("HumanoidRootPart")
    local lr   = DYHUB_GetLocalRoot()
    if not head or not hrp or not lr then return end
    local pred    = head.Position + (hrp.Velocity * DYHUB_PredictionTime)
    local dist    = (lr.Position - pred).Magnitude
    local pitchMax = DYHUB_GetAutoPitchMax(dist)
    local alpha   = math.clamp((dist - DYHUB_MIN_DISTANCE) / (DYHUB_MAX_DISTANCE - DYHUB_MIN_DISTANCE), 0, 1)
    local pitch   = DYHUB_MIN_PITCH + (pitchMax - DYHUB_MIN_PITCH) * alpha
    local dir     = (pred - Camera.CFrame.Position).Unit
    local yaw     = math.atan2(dir.X, dir.Z)
    local pr      = math.rad(pitch)
    local look    = Vector3.new(math.sin(yaw)*math.cos(pr), math.sin(pr), math.cos(yaw)*math.cos(pr))
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + look)
end

local function DYHUB_GetPitchByDistance(d)
    local t = { {1,0.09},{10,0.9},{20,1.9},{30,2.9},{40,3.9},{50,4.9},{60,5.9},{70,6.9},{80,7.9},{90,8.9},{100,10.9},{110,11.9},{120,12.9},{130,13.9},{140,14.9},{150,15.9},{160,16.9},{170,17.9},{180,18.9},{190,20.3},{200,22.3} }
    for _, v in ipairs(t) do if d < v[1] then return v[2] end end
    return 23.3
end
local function DYHUB_AimAt_28(target)
    if not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    local hrp  = target.Character:FindFirstChild("HumanoidRootPart")
    local lr   = DYHUB_GetLocalRoot()
    if not head or not hrp or not lr then return end
    local pred  = head.Position + (hrp.Velocity * DYHUB_PredictionTime)
    local dist  = (pred - Camera.CFrame.Position).Magnitude
    local pitch = DYHUB_GetPitchByDistance(dist)
    local dir   = (pred - Camera.CFrame.Position).Unit
    local yaw   = math.atan2(dir.X, dir.Z)
    local pr    = math.rad(pitch)
    local look  = Vector3.new(math.sin(yaw)*math.cos(pr), math.sin(pr), math.cos(yaw)*math.cos(pr))
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + look)
end

-- Keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local key = input.KeyCode.Name
    if key == DYHUB_Settings.Aimbot.SetKeybindLock then
        DYHUB_AimbotEnabled = not DYHUB_AimbotEnabled
        if DYHUB_AimbotEnabled and DYHUB_Aimbot28Enabled then
            DYHUB_Aimbot28Enabled = false
            if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        if DYHUB_mobileButton then
            DYHUB_mobileButton.BackgroundColor3 = DYHUB_AimbotEnabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
        end
    end
    if key == DYHUB_Settings.Aimbot.SetKeybindLock28 then
        DYHUB_Aimbot28Enabled = not DYHUB_Aimbot28Enabled
        if DYHUB_Aimbot28Enabled and DYHUB_AimbotEnabled then
            DYHUB_AimbotEnabled = false
            if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        if DYHUB_mobileButton28 then
            DYHUB_mobileButton28.BackgroundColor3 = DYHUB_Aimbot28Enabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
        end
    end
end)

-- Mobile buttons
local DYHUB_DragConnNormal, DYHUB_DragConn28, DYHUB_DragMoveConn, DYHUB_DragMoveConn28

local function DYHUB_ClearDragConnections()
    if DYHUB_DragConnNormal  then DYHUB_DragConnNormal:Disconnect();  DYHUB_DragConnNormal  = nil end
    if DYHUB_DragConn28      then DYHUB_DragConn28:Disconnect();      DYHUB_DragConn28      = nil end
    if DYHUB_DragMoveConn    then DYHUB_DragMoveConn:Disconnect();    DYHUB_DragMoveConn    = nil end
    if DYHUB_DragMoveConn28  then DYHUB_DragMoveConn28:Disconnect();  DYHUB_DragMoveConn28  = nil end
end

function DYHUB_EnableDrag(state)
    DYHUB_ClearDragConnections()
    if not state then
        if DYHUB_mobileButton   then DYHUB_Settings.Aimbot.MobileButtonPosition   = DYHUB_mobileButton.Position end
        if DYHUB_mobileButton28 then DYHUB_Settings.Aimbot.MobileButton28Position = DYHUB_mobileButton28.Position end
        return
    end
    local function makeDrag(btn, settingKey, connStore, moveConnStore)
        if not btn then return end
        local dragging, startPos, startInput = false, nil, nil
        connStore = btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; startInput = input.Position; startPos = btn.Position
                local ce; ce = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false; DYHUB_Settings.Aimbot[settingKey] = btn.Position; ce:Disconnect()
                    end
                end)
            end
        end)
        moveConnStore = UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - startInput
                btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    makeDrag(DYHUB_mobileButton,   "MobileButtonPosition",   DYHUB_DragConnNormal, DYHUB_DragMoveConn)
    makeDrag(DYHUB_mobileButton28, "MobileButton28Position", DYHUB_DragConn28,     DYHUB_DragMoveConn28)
end

local function DYHUB_EnsureGUIFolder()
    if not DYHUB_guiFolder or not DYHUB_guiFolder.Parent then
        DYHUB_guiFolder = Instance.new("ScreenGui")
        DYHUB_guiFolder.Name = "DYHUB_AimbotGUI"
        DYHUB_guiFolder.ResetOnSpawn = false
        DYHUB_guiFolder.Parent = PlayerGui
    end
end

local function DYHUB_CreateMobileButtons()
    if DYHUB_mobileButton   then pcall(function() DYHUB_mobileButton:Destroy() end) end
    if DYHUB_mobileButton28 then pcall(function() DYHUB_mobileButton28:Destroy() end) end

    local function makeBtn(text, pos, isEnabled)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 0, 90)
        btn.Position = pos
        btn.AnchorPoint = Vector2.new(1, 1)
        btn.BackgroundColor3 = isEnabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
        btn.Text = text
        btn.TextSize = 36
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Visible = false
        btn.Parent = DYHUB_guiFolder
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 45)
        c.Parent = btn
        return btn
    end

    DYHUB_mobileButton   = makeBtn("🗡️", DYHUB_Settings.Aimbot.MobileButtonPosition, DYHUB_AimbotEnabled)
    DYHUB_mobileButton28 = makeBtn("⚔️", DYHUB_Settings.Aimbot.MobileButton28Position, DYHUB_Aimbot28Enabled)
    DYHUB_mobileButton.Visible   = DYHUB_AimbotToggleGUIVisible
    DYHUB_mobileButton28.Visible = DYHUB_Aimbot28ToggleGUIVisible

    DYHUB_mobileButton.MouseButton1Click:Connect(function()
        DYHUB_AimbotEnabled = not DYHUB_AimbotEnabled
        if DYHUB_AimbotEnabled and DYHUB_Aimbot28Enabled then
            DYHUB_Aimbot28Enabled = false
            if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        DYHUB_mobileButton.BackgroundColor3 = DYHUB_AimbotEnabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
    end)
    DYHUB_mobileButton28.MouseButton1Click:Connect(function()
        DYHUB_Aimbot28Enabled = not DYHUB_Aimbot28Enabled
        if DYHUB_Aimbot28Enabled and DYHUB_AimbotEnabled then
            DYHUB_AimbotEnabled = false
            if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        DYHUB_mobileButton28.BackgroundColor3 = DYHUB_Aimbot28Enabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
    end)

    DYHUB_EnableDrag(DYHUB_Settings.Aimbot.DragUI)
end

task.spawn(function()
    DYHUB_EnsureGUIFolder()
    DYHUB_CreateMobileButtons()
    -- Keep GUI alive
    while task.wait(3) do
        DYHUB_EnsureGUIFolder()
        local gui = PlayerGui:FindFirstChild("DYHUB_AimbotGUI")
        if gui and not gui.Enabled then gui.Enabled = true end
    end
end)

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if DYHUB_AimbotEnabled then
        DYHUB_LockedTarget = DYHUB_GetClosestInScreen()
        if DYHUB_LockedTarget and DYHUB_CanSeeTarget(DYHUB_LockedTarget) then
            DYHUB_AimAt_Normal(DYHUB_LockedTarget)
        end
    elseif DYHUB_Aimbot28Enabled then
        DYHUB_LockedTarget = DYHUB_GetClosestByDistance()
        if DYHUB_LockedTarget and DYHUB_CanSeeTarget(DYHUB_LockedTarget) then
            DYHUB_AimAt_28(DYHUB_LockedTarget)
        end
    end
end)

-- The Masked
killerTab:Section({ Title = "Killer: The Masked", Icon = "venetian-mask" })
killerTab:Paragraph({
    Title = "Information: The Masked",
    Desc  = "• Richard (No Abilities)\n• Tony (One Shot, No hold)\n• Brandon (Speed Boost)\n• Jake (Lunge Range)\n• Richter (Removes terror radius)\n• Graham (Faster Vault)\n• Alex (Chainsaw, One Shot)",
    Image = "rbxassetid://104487529937663",
    ImageSize = 50,
    Locked = false
})

local Killer = { TheMasked = { Mask = {"Richard","Tony","Brandon","Jake","Richter","Graham","Alex"} } }
local selectedMasks = {}

killerTab:Dropdown({
    Title  = "Select Mask",
    Values = Killer.TheMasked.Mask,
    Multi  = false,
    Callback = function(values) selectedMasks = values end
})
killerTab:Button({
    Title = "Choose Mask (Selected)",
    Callback = function()
        ReplicatedStorage.Remotes.Killers.Masked.Activatepower:FireServer(selectedMasks)
    end
})
killerTab:Button({
    Title = "Random Mask (Legit Mode)",
    Callback = function()
        local masks = {"Richard","Tony","Brandon","Jake","Richter","Graham","Alex"}
        ReplicatedStorage.Remotes.Killers.Masked.Activatepower:FireServer(masks[math.random(#masks)])
    end
})

-- The Stalker
killerTab:Section({ Title = "Killer: The Stalker", Icon = "eye-off" })

local Stalker = false
killerTab:Toggle({
    Title = "Start Stalker (Raycast / Remote)",
    Value = false,
    Callback = function(v)
        Stalker = v
        task.spawn(function()
            while Stalker do
                task.wait(0.2)
                local lp   = LocalPlayer
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                local weapon = char:FindFirstChild("Weapon")
                if not weapon then continue end
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= lp and plr.Character then
                        local hrp      = plr.Character:FindFirstChild("HumanoidRootPart")
                        local humanoid = plr.Character:FindFirstChild("Humanoid")
                        if hrp and humanoid then
                            local dist = (root.Position - hrp.Position).Magnitude
                            if dist >= 30 and dist <= 70 and humanoid.Health > 20 then
                                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Stalker"):WaitForChild("StartStalking"):FireServer(plr)
                            end
                        end
                    end
                end
            end
        end)
    end
})

killerTab:Section({ Title = "Feature Killer", Icon = "swords" })

local killallEnabled = false
killerTab:Toggle({
    Title = "Kill All (Warning: Get Ban)",
    Value = false,
    Callback = function(v)
        killallEnabled = v
        if killallEnabled then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
                local startCFrame = nil
                while killallEnabled do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        if not startCFrame then startCFrame = root.CFrame end
                        local targets = {}
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                                local hm = plr.Character:FindFirstChildOfClass("Humanoid")
                                if tr and hm then table.insert(targets, { root = tr, humanoid = hm }) end
                            end
                        end
                        for _, entry in ipairs(targets) do
                            if not killallEnabled then break end
                            if entry.humanoid.Health > 20 then
                                pcall(function()
                                    root.CFrame = entry.root.CFrame * CFrame.new(0, 0, 2)
                                    remote:FireServer()
                                end)
                                task.wait(0.15)
                            end
                        end
                        local allLow = true
                        for _, entry in ipairs(targets) do
                            if entry.humanoid.Health > 20 then allLow = false; break end
                        end
                        if allLow and startCFrame then root.CFrame = startCFrame; task.wait(1)
                        else task.wait(0.2) end
                    else task.wait(0.2) end
                end
            end)
        end
    end
})

local Autocarry = false
killerTab:Toggle({
    Title = "Auto Carry (Nearby Survivor / 2.5s)",
    Value = false,
    Callback = function(v)
        Autocarry = v
        task.spawn(function()
            while Autocarry do
                task.wait(2.5)
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                local candidates = {}
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local hum = plr.Character:FindFirstChild("Humanoid")
                        local oHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hum and oHrp and hum.Health == 20 and (hrp.Position - oHrp.Position).Magnitude <= 10 then
                            table.insert(candidates, plr)
                        end
                    end
                end
                if #candidates ~= 1 then continue end
                local target = candidates[1]
                if target and target.Character then
                    local tHum = target.Character:FindFirstChild("Humanoid")
                    if tHum and tHum.Health == 20 then
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("CarrySurvivorEvent"):FireServer(target.Character)
                        task.wait(5)
                    end
                end
            end
        end)
    end
})

local AutoHook = false
killerTab:Toggle({
    Title = "Auto Hook (Nearby Hook / 2.5s)",
    Value = false,
    Callback = function(v)
        AutoHook = v
        task.spawn(function()
            while AutoHook do
                task.wait(2.5)
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                local candidates = {}
                for _, target in ipairs(Players:GetPlayers()) do
                    if target ~= LocalPlayer and target.Character then
                        local hum  = target.Character:FindFirstChild("Humanoid")
                        local thrp = target.Character:FindFirstChild("HumanoidRootPart")
                        if hum and thrp and hum.Health == 20 and (hrp.Position - thrp.Position).Magnitude <= 10 then
                            table.insert(candidates, target)
                        end
                    end
                end
                if #candidates ~= 1 then continue end
                -- find nearest hook anywhere in workspace
                local nearestHook, nearestDist = nil, 10
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc.Name == "HookPoint" then
                        local d = (hrp.Position - desc.Position).Magnitude
                        if d <= nearestDist then nearestDist = d; nearestHook = desc end
                    end
                end
                if not nearestHook then continue end
                ReplicatedStorage.Remotes.Carry.HookEvent:FireServer(nearestHook)
                task.wait(5)
            end
        end)
    end
})

killerTab:Section({ Title = "Feature Fun", Icon = "crown" })

local GrabKey = "C"
killerTab:Input({
    Title = "Set Keybind Grab (PC ONLY)",
    Default = GrabKey,
    Placeholder = "Grab (Ex: C)",
    Callback = function(text)
        if typeof(text) == "string" and #text > 0 then GrabKey = text:upper() end
    end
})

local function DoGrab()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local candidates = {}
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and target.Character then
            local hum  = target.Character:FindFirstChild("Humanoid")
            local thrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hum and thrp and (hrp.Position - thrp.Position).Magnitude <= 20 and hum.Health ~= 20 then
                table.insert(candidates, target)
            end
        end
    end
    if #candidates ~= 1 then return end
    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Stalker"):WaitForChild("grab"):FireServer(candidates[1].Character)
end

killerTab:Button({ Title = "Grab (Nearby Survivor/Killer)", Callback = DoGrab })

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not GrabKey then return end
    if input.KeyCode == Enum.KeyCode[GrabKey] then DoGrab() end
end)

local nocooldownskillEnabled = false
killerTab:Toggle({
    Title = "Auto Attack (No Animation)",
    Value = false,
    Callback = function(v)
        nocooldownskillEnabled = v
        if nocooldownskillEnabled then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
                while nocooldownskillEnabled do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local closest, closestDist = nil, 10
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                                local hm = plr.Character:FindFirstChildOfClass("Humanoid")
                                if tr and hm then
                                    local d = (root.Position - tr.Position).Magnitude
                                    if d <= closestDist and hm.Health > 20 then closestDist = d; closest = plr.Character end
                                end
                            end
                        end
                        if closest then remote:FireServer() end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

killerTab:Section({ Title = "Feature Cheat", Icon = "bug" })

local noFlashlightEnabled = false
killerTab:Toggle({
    Title = "No Flashlight",
    Value = false,
    Callback = function(state) noFlashlightEnabled = state end
})
task.spawn(function()
    while true do
        task.wait(0.5)
        if noFlashlightEnabled then
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                for _, desc in pairs(pg:GetDescendants()) do
                    if desc:IsA("GuiObject") and desc.Name == "Blind" then desc:Destroy() end
                end
            end
        end
    end
end)

local destroyPalletwrong = false
killerTab:Toggle({
    Title = "Remove Palletwrong (All)",
    Value = false,
    Callback = function(v)
        destroyPalletwrong = v
        if destroyPalletwrong then
            task.spawn(function()
                while destroyPalletwrong do
                    for _, desc in ipairs(Workspace:GetDescendants()) do
                        if desc:IsA("Model") and desc.Name == "Palletwrong" then
                            desc:Destroy()
                        end
                    end
                    task.wait(0.69)
                end
            end)
        end
    end
})

killerTab:Button({
    Title = "Fix Cam (3rd Person Camera)",
    Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid  = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Camera.CameraType = Enum.CameraType.Custom
            Camera.CameraSubject = humanoid
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 400
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            local head = character:FindFirstChild("Head")
            if head then head.Anchored = false end
        end
    end
})

-- ====================== PLAYER TAB ======================
local speedEnabled, flyNoclipSpeed = false, 3
local speedConnection, noclipConnection

PlayerTab:Section({ Title = "Feature Player", Icon = "rabbit" })
PlayerTab:Slider({ Title = "Set Speed (Legit = 3)", Value = { Min = 1, Max = 999, Default = 5 }, Step = 1, Callback = function(val) flyNoclipSpeed = val end })
PlayerTab:Toggle({
    Title = "Enable Speed", Value = false,
    Callback = function(v)
        speedEnabled = v
        if speedEnabled then
            if speedConnection then speedConnection:Disconnect() end
            speedConnection = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.MoveDirection.Magnitude > 0 then
                    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + char.Humanoid.MoveDirection * flyNoclipSpeed * 0.004
                end
            end)
        else
            if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        end
    end
})

PlayerTab:Section({ Title = "Feature Power", Icon = "flame" })
PlayerTab:Toggle({
    Title = "No Clip", Value = false,
    Callback = function(state)
        if state then
            noclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end
})

local NoFallEnabled = false
local FallRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("Fall")

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if NoFallEnabled and self == FallRemote and method == "FireServer" then return nil end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

PlayerTab:Toggle({
    Title = "No Fall (Beta)", Value = false,
    Callback = function(v) NoFallEnabled = v end
})

-- ====================== HITBOX TAB ======================
local transparency = 0.95
local hitboxSize   = 10
local hitboxEnabled    = false
local hitboxConnection

Hitbox:Paragraph({
    Title = "Hitbox System (Patched)",
    Desc  = "• Universal Killer Support\n• Precision Slash Modules\n• Optimized Range Handler",
    Image = "rbxassetid://104487529937663",
    ImageSize = 45,
    Locked = false
})

Hitbox:Section({ Title = "Feature Hitbox", Icon = "package" })
Hitbox:Input({
    Title = "Set Transparency (Visible)", Value = tostring(transparency), Placeholder = "Ex: 0.95",
    Callback = function(text)
        local num = tonumber(text)
        if num then transparency = math.clamp(num, 0, 1) else warn("Invalid number!") end
    end
})
Hitbox:Input({
    Title = "Set Hitbox (Size)", Value = tostring(hitboxSize), Placeholder = "Ex: 10",
    Callback = function(text)
        local num = tonumber(text)
        if num then hitboxSize = num else warn("Invalid number!") end
    end
})
Hitbox:Toggle({
    Title = "Enable Hitbox", Value = false,
    Callback = function(v)
        hitboxEnabled = v
        if hitboxConnection then hitboxConnection:Disconnect(); hitboxConnection = nil end
        if hitboxEnabled then
            hitboxConnection = RunService.RenderStepped:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local part = player.Character.HumanoidRootPart
                        pcall(function()
                            part.Size        = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                            part.Transparency = transparency
                            part.BrickColor  = BrickColor.new("Really red")
                            part.Material    = Enum.Material.Neon
                            part.CanCollide  = false
                        end)
                    end
                end
            end)
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local part = player.Character.HumanoidRootPart
                    pcall(function()
                        part.Size        = Vector3.new(2, 2, 1)
                        part.Transparency = 1
                        part.Material    = Enum.Material.Plastic
                    end)
                end
            end
        end
    end
})

-- ====================== TELEPORT TAB ======================
local TELEPORT_OFFSET = 10

local function getCFrame(obj)
    if obj:IsA("BasePart") then return obj.CFrame
    elseif obj:IsA("Model") then
        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        return part and part.CFrame
    end
end

local function getAllGenerators()
    local list, count = {}, 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Generator" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            count += 1
            table.insert(list, { Name = "Generator " .. count, Object = obj })
        end
    end
    return list
end

TeleportTab:Section({ Title = "Teleport: Place", Icon = "map" })
local Place
TeleportTab:Dropdown({
    Title = "Select Place",
    Values = {"Lobby", "Game"},
    Callback = function(v) Place = v end
})
TeleportTab:Button({
    Title = "Teleport",
    Callback = function()
        if Place == "Lobby" then
            local spawn = Workspace:FindFirstChild("SpawnLocation")
            if spawn and LocalPlayer.Character then
                LocalPlayer.Character:PivotTo(spawn.CFrame + Vector3.new(0, 1, 0))
            end
        elseif Place == "Game" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Weapon") then
                    LocalPlayer.Character:PivotTo(p.Character.PrimaryPart.CFrame * CFrame.new(0, 0, 200))
                    break
                end
            end
        end
    end
})

TeleportTab:Section({ Title = "Teleport: Generator", Icon = "zap" })
local generatorList = getAllGenerators()
local GenTarget

local GenDropdown = TeleportTab:Dropdown({
    Title = "Select Generator",
    Values = (function()
        local t = {}
        for _, g in ipairs(generatorList) do table.insert(t, g.Name) end
        return t
    end)(),
    Callback = function(v)
        for _, g in ipairs(generatorList) do
            if g.Name == v then GenTarget = g.Object end
        end
    end
})

TeleportTab:Button({
    Title = "Teleport",
    Callback = function()
        if GenTarget then LocalPlayer.Character:PivotTo(getCFrame(GenTarget)) end
    end
})

TeleportTab:Button({
    Title = "Refresh Generator",
    Callback = function()
        generatorList = getAllGenerators()
        local t = {}
        for _, g in ipairs(generatorList) do table.insert(t, g.Name) end
        GenDropdown:Update(t)
    end
})

TeleportTab:Section({ Title = "Teleport: Refresh", Icon = "loader" })
TeleportTab:Button({
    Title = "Refresh All",
    Callback = function()
        generatorList = getAllGenerators()
        if GenDropdown then
            local t = {}
            for _, g in ipairs(generatorList) do table.insert(t, g.Name) end
            GenDropdown:Update(t)
        end
        GenTarget = nil
        print("[DYHUB] Refresh All completed")
    end
})

-- ====================== SETTINGS TAB (Main3) ======================
Main3:Section({ Title = "Save Config", Icon = "save" })

Main3:Button({
    Title = "Save Config (NOW)",
    Desc  = "Saves all current settings to config file immediately.",
    Callback = function()
        Config:Save()
        WindUI:Notify({ Title = "Config Saved", Content = "Config saved successfully!", Duration = 2, Icon = "save" })
    end
})

local AutoSaveEnabled = Config:Get("AutoSaveEnabled", true)
local AutoSaveDelay   = Config:Get("AutoSaveDelay", 15)
local AutoSaveThread  = nil

local function RestartAutoSave()
    if AutoSaveThread then task.cancel(AutoSaveThread); AutoSaveThread = nil end
    if AutoSaveEnabled then
        AutoSaveThread = task.spawn(function()
            while AutoSaveEnabled do
                task.wait(AutoSaveDelay)
                Config:Save()
            end
        end)
    end
end

Main3:Toggle({
    Title = "Auto Save Config",
    Value = AutoSaveEnabled,
    Desc  = "Automatically saves your config at the set interval.",
    Callback = function(state)
        AutoSaveEnabled = state
        Config:Set("AutoSaveEnabled", state)
        Config:Save()
        RestartAutoSave()
    end
})

Main3:Input({
    Title       = "Delay Save Config",
    Default     = tostring(AutoSaveDelay),
    Placeholder = "Default: 15",
    Callback    = function(text)
        local num = tonumber(text)
        if num and num >= 1 then
            AutoSaveDelay = num
            Config:Set("AutoSaveDelay", num)
            Config:Save()
            RestartAutoSave()
        else
            warn("[DYHUB] Invalid delay value!")
        end
    end
})

Main3:Section({ Title = "Server Status", Icon = "server" })

Main3:Button({
    Title = "Serverhop",
    Desc  = "Teleports you to a different random server of this game.",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local servers = {}
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end
        end
        if #servers > 0 then
            WindUI:Notify({ Title = "Serverhop", Content = "Teleporting to another server...", Duration = 2, Icon = "server" })
            task.wait(1)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            WindUI:Notify({ Title = "Serverhop Failed", Content = "No available servers found.", Duration = 3, Icon = "alert-triangle" })
        end
    end
})

Main3:Button({
    Title = "Rejoin",
    Desc  = "Rejoins the current game server.",
    Callback = function()
        WindUI:Notify({ Title = "Rejoin", Content = "Rejoining server...", Duration = 2, Icon = "refresh-cw" })
        task.wait(1)
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

-- Start auto save on load
RestartAutoSave()

-- ====================== INFORMATION TAB ======================
local Info = InfoTab

if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

ui.Creator.Request = function(requestData)
    local success, result = pcall(function()
        if HttpService.RequestAsync then
            local response = HttpService:RequestAsync({
                Url    = requestData.Url,
                Method = requestData.Method or "GET",
                Headers = requestData.Headers or {}
            })
            return { Body = response.Body, StatusCode = response.StatusCode, Success = response.Success }
        else
            local body = HttpService:GetAsync(requestData.Url)
            return { Body = body, StatusCode = 200, Success = true }
        end
    end)
    if success then return result
    else error("HTTP Request failed: " .. tostring(result)) end
end

local InviteCode = "jWNDPNMmyB"
local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local function LoadDiscordInfo()
    local success, result = pcall(function()
        return HttpService:JSONDecode(ui.Creator.Request({
            Url = DiscordAPI, Method = "GET",
            Headers = { ["User-Agent"] = "RobloxBot/1.0", ["Accept"] = "application/json" }
        }).Body)
    end)

    if success and result and result.guild then
        local DiscordInfo = Info:Paragraph({
            Title = result.guild.name,
            Desc  = ' <font color="#52525b">●</font> Member Count : ' .. tostring(result.approximate_member_count) ..
                    '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(result.approximate_presence_count),
            Image = "https://cdn.discordapp.com/icons/" .. result.guild.id .. "/" .. result.guild.icon .. ".png?size=1024",
            ImageSize = 42,
        })

        Info:Button({
            Title = "Update Info",
            Callback = function()
                local ok, r = pcall(function()
                    return HttpService:JSONDecode(ui.Creator.Request({ Url = DiscordAPI, Method = "GET" }).Body)
                end)
                if ok and r and r.guild then
                    DiscordInfo:SetDesc(
                        ' <font color="#52525b">●</font> Member Count : ' .. tostring(r.approximate_member_count) ..
                        '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(r.approximate_presence_count)
                    )
                    WindUI:Notify({ Title = "Discord Info Updated", Content = "Refreshed!", Duration = 2, Icon = "refresh-cw" })
                else
                    WindUI:Notify({ Title = "Update Failed", Content = "Could not refresh Discord info", Duration = 3, Icon = "alert-triangle" })
                end
            end
        })

        Info:Button({
            Title = "Copy Discord Invite",
            Callback = function()
                setclipboard("https://discord.gg/" .. InviteCode)
                WindUI:Notify({ Title = "Copied!", Content = "Discord invite copied to clipboard", Duration = 2, Icon = "clipboard-check" })
            end
        })
    else
        Info:Paragraph({
            Title = "Error fetching Discord Info",
            Desc  = "Unable to load Discord information.",
            Image = "triangle-alert",
            ImageSize = 26,
            Color = "Red",
        })
    end
end

LoadDiscordInfo()

Info:Divider()
Info:Section({ Title = "DYHUB Information", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()

Info:Paragraph({
    Title = "Main Owner",
    Desc  = "@dyumraisgoodguy#8888",
    Image = "rbxassetid://119789418015420",
    ImageSize = 30,
    Locked = false,
})

Info:Paragraph({
    Title = "Social",
    Desc  = "Copy link social media for follow!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Locked = false,
    Buttons = {{
        Icon  = "copy",
        Title = "Copy Link",
        Callback = function()
            setclipboard("https://guns.lol/DYHUB")
        end
    }}
})

Info:Paragraph({
    Title = "Discord",
    Desc  = "Join our discord for more scripts!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Locked = false,
    Buttons = {{
        Icon  = "copy",
        Title = "Copy Link",
        Callback = function()
            setclipboard("https://discord.gg/jWNDPNMmyB")
        end
    }}
})
