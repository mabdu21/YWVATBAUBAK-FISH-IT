local version = "BETA"
local ver     = "v014.45"

repeat task.wait() until game:IsLoaded()

-- ====================== SERVICES ======================
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = Workspace.CurrentCamera

-- ====================== LOAD WINDUI ======================
local WindUI
pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not WindUI then
    warn("[DYHUB] Failed to load WindUI!")
    return
end

if setfpscap then
    pcall(function()
        setfpscap(1000000)
        WindUI:Notify({ Title = "DYHUB", Content = "FPS Unlocked! | " .. ver, Duration = 3, Icon = "cpu" })
    end)
end

-- ====================== CHARACTER CACHE ======================
local Character, Humanoid, HumanoidRootPart

local function bindCharacter(char)
    Character = char
    pcall(function() Humanoid = char:WaitForChild("Humanoid", 10) end)
    pcall(function() HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 10) end)

    task.delay(1, function()
        pcall(function()
            if Humanoid and getgenv().Settings then
                if getgenv().Settings.SpeedEnabled then
                    Humanoid.WalkSpeed = getgenv().Settings.SpeedValue
                end
                if getgenv().Settings.JumpEnabled then
                    Humanoid.UseJumpPower = true
                    Humanoid.JumpPower = getgenv().Settings.JumpValue
                end
            end
        end)
    end)
end

bindCharacter(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(bindCharacter)

-- ====================== REMOTES ======================
local verdantRemotes
pcall(function() verdantRemotes = ReplicatedStorage:WaitForChild("VerdantRemotes", 10) end)

local useBucket, pourBucket, takeToken, skillTreePurchase
if verdantRemotes then
    pcall(function() useBucket = verdantRemotes:WaitForChild("VDT_Bucket.Used", 5) end)
    pcall(function() pourBucket = verdantRemotes:WaitForChild("VDT_Bucket.Poured", 5) end)
    pcall(function() takeToken = verdantRemotes:WaitForChild("VDT_Tokens.Take", 5) end)
    pcall(function() skillTreePurchase = verdantRemotes:WaitForChild("VDT_SkillTree.Purchase", 5) end)
end

-- ====================== SETTINGS ======================
getgenv().Settings = getgenv().Settings or {
    -- Main
    AutoFarm     = false,
    AutoDrain    = false,
    AutoStor     = false,
    AutoToken    = false,
    AutoChest    = false,
    AutoPhone    = false,
    AutoUpgrade  = false,

    -- ESP
    ESP_Player   = false,
    ESP_Chest    = false,
    ESP_Phone    = false,
    ESP_Drain    = false,
    ESP_TokenOrb = false,
    ESP_Box      = true,
    ESP_Name     = true,
    ESP_Distance = true,
    ESP_Tracer   = false,

    -- Player
    SpeedEnabled   = false,
    SpeedValue     = 16,
    JumpEnabled    = false,
    JumpValue      = 50,
    Noclip         = false,
    InfiniteJump   = false,
    InstantPrompt  = false,
    AntiAFK        = false,

    -- Config
    AutoSaveEnabled = true,
    AutoSaveDelay   = 15,
}
local Settings = getgenv().Settings

-- ====================== CONFIG SYSTEM ======================
local Config = {}
local ConfigFolder = "DYHUB_DTL"
local ConfigPath   = ConfigFolder .. "/config.json"

if not isfolder(ConfigFolder) then pcall(function() makefolder(ConfigFolder) end) end

function Config.Save()
    pcall(function()
        writefile(ConfigPath, HttpService:JSONEncode(Settings))
    end)
end

function Config.Load()
    pcall(function()
        if isfile and isfile(ConfigPath) then
            local data = HttpService:JSONDecode(readfile(ConfigPath))
            if type(data) == "table" then
                for k, v in pairs(data) do
                    if Settings[k] ~= nil then
                        Settings[k] = v
                    end
                end
            end
        end
    end)
end

Config.Load()

local autoSaveThread
function Config.AutoSave(interval)
    if autoSaveThread then
        pcall(function() task.cancel(autoSaveThread) end)
        autoSaveThread = nil
    end
    if interval and interval > 0 then
        autoSaveThread = task.spawn(function()
            while true do
                task.wait(interval)
                Config.Save()
            end
        end)
    end
end

if Settings.AutoSaveEnabled then
    Config.AutoSave(Settings.AutoSaveDelay)
end

-- ====================== VERSION CHECK ======================
local function checkVersion(playerName)
    local url = "https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua"
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then return "Free Version" end
    local func = loadstring(response)
    if not func then return "Free Version" end
    local ok, premiumData = pcall(func)
    if not ok then return "Free Version" end
    return premiumData and premiumData[playerName] and "Premium Version" or "Free Version"
end

local userversion = checkVersion(LocalPlayer.Name)

-- ====================== WINDOW ======================
local Window = WindUI:CreateWindow({
    Title      = "DYHUB",
    IconThemed = true,
    Icon       = "rbxassetid://104487529937663",
    Author     = "Drain the Lake | " .. userversion,
    Folder     = "DYHUB_DTL",
    Size       = UDim2.fromOffset(500, 400),
    Transparent = true,
    Theme      = "Dark",
    HasOutline = false,
    HideSearchBar    = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.K)
pcall(function() Window:Tag({ Title = version, Color = Color3.fromHex("#db7093") }) end)
Window:EditOpenButton({
    Title           = "DYHUB - Open",
    Icon            = "monitor",
    CornerRadius    = UDim.new(0, 6),
    StrokeThickness = 2,
    Color           = ColorSequence.new(Color3.fromRGB(30,30,30), Color3.fromRGB(255,255,255)),
    Draggable       = true,
})

-- ====================== TABS ======================
local InfoTab     = Window:Tab({ Title = "Information", Icon = "info" })
Window:Divider()
local MainTab     = Window:Tab({ Title = "Main",        Icon = "rocket" })
local EspTab      = Window:Tab({ Title = "Esp",         Icon = "eye" })
local PlayerTab   = Window:Tab({ Title = "Player",      Icon = "user" })
local TeleportTab = Window:Tab({ Title = "Collect",     Icon = "package" })
Window:Divider()
local SettingsTab = Window:Tab({ Title = "Settings",    Icon = "settings" })

Window:SelectTab(1)

-- =====================================================
-- ESP SYSTEM
-- =====================================================
local ESPObjects = {}
local ESPTracers = {}
local tracerFolder = Instance.new("Folder")
tracerFolder.Name = "DYHUB_Tracers"
tracerFolder.Parent = CoreGui

local function removeESP(target)
    if not target then return end
    pcall(function()
        if target:FindFirstChild("DYHUB_HL") then target.DYHUB_HL:Destroy() end
        if target:FindFirstChild("DYHUB_BILL") then target.DYHUB_BILL:Destroy() end
    end)
    ESPObjects[target] = nil
end

local function applyESP(target, text, color)
    if not target then return end
    if not (target:IsA("BasePart") or target:IsA("Model") or target:IsA("Attachment")) then return end

    pcall(function()
        if Settings.ESP_Box then
            local hl = target:FindFirstChild("DYHUB_HL")
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "DYHUB_HL"
                hl.FillColor = color
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.Adornee = target
                hl.Parent = target
            else
                hl.FillColor = color
            end
        else
            if target:FindFirstChild("DYHUB_HL") then target.DYHUB_HL:Destroy() end
        end
    end)

    pcall(function()
        if Settings.ESP_Name or Settings.ESP_Distance then
            local bill = target:FindFirstChild("DYHUB_BILL")
            if not bill then
                bill = Instance.new("BillboardGui")
                bill.Name = "DYHUB_BILL"
                bill.Size = UDim2.new(0, 200, 0, 50)
                bill.StudsOffset = Vector3.new(0, 3, 0)
                bill.AlwaysOnTop = true
                bill.LightInfluence = 0
                bill.Parent = target

                local tl = Instance.new("TextLabel")
                tl.Name = "TextLabel"
                tl.Parent = bill
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.BackgroundTransparency = 1
                tl.Text = text
                tl.TextColor3 = color
                tl.TextStrokeTransparency = 0
                tl.Font = Enum.Font.GothamBold
                tl.TextSize = 12
                tl.TextScaled = false
            else
                bill.TextLabel.Text = text
                bill.TextLabel.TextColor3 = color
            end
        else
            if target:FindFirstChild("DYHUB_BILL") then target.DYHUB_BILL:Destroy() end
        end
    end)

    pcall(function()
        if Settings.ESP_Tracer then
            local tracer = ESPTracers[target]
            if not tracer then
                tracer = Instance.new("Frame")
                tracer.Name = "DYHUB_TRACER"
                tracer.BorderSizePixel = 0
                tracer.BackgroundColor3 = color
                tracer.AnchorPoint = Vector2.new(0, 0.5)
                tracer.Parent = tracerFolder
            end
            ESPTracers[target] = tracer
        else
            if ESPTracers[target] then
                ESPTracers[target]:Destroy()
                ESPTracers[target] = nil
            end
        end
    end)

    ESPObjects[target] = true
end

local function getDist(pos)
    if not pos or not HumanoidRootPart or not HumanoidRootPart.Parent then return "?" end
    return tostring(math.floor((HumanoidRootPart.Position - pos).Magnitude)) .. "m"
end

-- ====================== ESP UPDATE LOOP ======================
task.spawn(function()
    while task.wait(0.5) do
        for obj, _ in pairs(ESPObjects) do
            pcall(function()
                if not obj.Parent or not obj:IsDescendantOf(Workspace) then
                    ESPObjects[obj] = nil
                    if ESPTracers[obj] then
                        ESPTracers[obj]:Destroy()
                        ESPTracers[obj] = nil
                    end
                end
            end)
        end

        if Settings.ESP_Player then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(function()
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local dist = getDist(char.HumanoidRootPart.Position)
                            local txt = (Settings.ESP_Name and player.DisplayName or "")
                            if Settings.ESP_Distance then txt = txt .. "\n[" .. dist .. "]" end
                            applyESP(char, txt, Color3.fromRGB(0, 255, 100))
                        end
                    end)
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    removeESP(player.Character)
                end
            end
        end

        pcall(function()
            local scripted = Workspace:FindFirstChild("Scripted")
            if scripted then
                local chests = scripted:FindFirstChild("Chests")
                if chests then
                    if Settings.ESP_Chest then
                        for _, chest in ipairs(chests:GetChildren()) do
                            local pos
                            if chest:IsA("BasePart") then pos = chest.Position
                            elseif chest:IsA("Model") then
                                local p = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
                                if p then pos = p.Position end
                            end
                            local txt = (Settings.ESP_Name and "Chest" or "")
                            if Settings.ESP_Distance then txt = txt .. "\n[" .. getDist(pos) .. "]" end
                            applyESP(chest, txt, Color3.fromRGB(255, 215, 0))
                        end
                    else
                        for _, chest in ipairs(chests:GetChildren()) do
                            removeESP(chest)
                        end
                    end
                end
            end
        end)

        if Settings.ESP_Phone then
            pcall(function()
                local phone = Workspace:FindFirstChild("Phone")
                if phone then
                    local pos
                    if phone:IsA("BasePart") then pos = phone.Position
                    elseif phone:IsA("Model") then
                        local p = phone.PrimaryPart or phone:FindFirstChildWhichIsA("BasePart")
                        if p then pos = p.Position end
                    end
                    local txt = (Settings.ESP_Name and "Phone" or "")
                    if Settings.ESP_Distance then txt = txt .. "\n[" .. getDist(pos) .. "]" end
                    applyESP(phone, txt, Color3.fromRGB(100, 200, 255))
                end
            end)
        else
            pcall(function()
                local phone = Workspace:FindFirstChild("Phone")
                if phone then removeESP(phone) end
            end)
        end

        local function processDrains(enabled, color, label, subfolder)
            pcall(function()
                local scripted = Workspace:FindFirstChild("Scripted")
                if not scripted then return end
                local targets = {}
                for _, obj in ipairs(scripted:GetChildren()) do
                    if obj.Name == "Drain" then table.insert(targets, obj) end
                end
                if subfolder then
                    local cp = scripted:FindFirstChild("CheckpointParts")
                    if cp then
                        local cp1 = cp:FindFirstChild("1")
                        if cp1 then
                            for _, obj in ipairs(cp1:GetChildren()) do
                                if obj.Name == "Drain" then table.insert(targets, obj) end
                            end
                        end
                    end
                end
                for _, drain in ipairs(targets) do
                    if enabled then
                        local pos
                        if drain:IsA("BasePart") then pos = drain.Position
                        elseif drain:IsA("Model") then
                            local p = drain.PrimaryPart or drain:FindFirstChildWhichIsA("BasePart")
                            if p then pos = p.Position end
                        end
                        local txt = (Settings.ESP_Name and label or "")
                        if Settings.ESP_Distance then txt = txt .. "\n[" .. getDist(pos) .. "]" end
                        applyESP(drain, txt, color)
                    else
                        removeESP(drain)
                    end
                end
            end)
        end

        processDrains(Settings.ESP_Drain, Color3.fromRGB(255, 100, 255), "Drain", true)

        if Settings.ESP_TokenOrb then
            pcall(function()
                local scripted = Workspace:FindFirstChild("Scripted")
                if not scripted then return end
                local targets = {}
                for _, obj in ipairs(scripted:GetChildren()) do
                    if obj.Name == "Drain" then table.insert(targets, obj) end
                end
                local cp = scripted:FindFirstChild("CheckpointParts")
                if cp then
                    local cp1 = cp:FindFirstChild("1")
                    if cp1 then
                        for _, obj in ipairs(cp1:GetChildren()) do
                            if obj.Name == "Drain" then table.insert(targets, obj) end
                        end
                    end
                end
                for _, drain in ipairs(targets) do
                    pcall(function()
                        local s = drain:FindFirstChild("Scripted")
                        if s then
                            local tt = s:FindFirstChild("TakeTokens")
                            if tt then
                                local pos
                                if drain:IsA("BasePart") then pos = drain.Position
                                elseif drain:IsA("Model") then
                                    local p = drain.PrimaryPart or drain:FindFirstChildWhichIsA("BasePart")
                                    if p then pos = p.Position end
                                end
                                local txt = (Settings.ESP_Name and "Token" or "")
                                if Settings.ESP_Distance then txt = txt .. "\n[" .. getDist(pos) .. "]" end
                                applyESP(tt, txt, Color3.fromRGB(255, 255, 0))
                            end
                        end
                    end)
                end
            end)
        else
            pcall(function()
                local scripted = Workspace:FindFirstChild("Scripted")
                if scripted then
                    for _, obj in ipairs(scripted:GetChildren()) do
                        if obj.Name == "Drain" then
                            pcall(function()
                                local s = obj:FindFirstChild("Scripted")
                                if s then
                                    local tt = s:FindFirstChild("TakeTokens")
                                    if tt then removeESP(tt) end
                                end
                            end)
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================== TRACER RENDER LOOP ======================
RunService.RenderStepped:Connect(function()
    if not Settings.ESP_Tracer then
        for _, line in pairs(ESPTracers) do
            if line and line.Visible then line.Visible = false end
        end
        return
    end

    local screenSize = Camera.ViewportSize
    local startVec  = Vector2.new(screenSize.X / 2, screenSize.Y)

    for target, line in pairs(ESPTracers) do
        pcall(function()
            if not target or not target.Parent then
                line.Visible = false
                return
            end

            local pos
            if target:IsA("BasePart") then
                pos = target.Position
            elseif target:IsA("Model") then
                local p = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
                if p then pos = p.Position else line.Visible = false return end
            elseif target:IsA("Attachment") then
                pos = target.WorldPosition
            else
                line.Visible = false
                return
            end

            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            if not onScreen then
                line.Visible = false
                return
            end

            local finish = Vector2.new(screenPos.X, screenPos.Y)
            local diff   = finish - startVec
            local length = diff.Magnitude
            if length < 5 then
                line.Visible = false
                return
            end
            local angle = math.atan2(diff.Y, diff.X)

            line.Visible   = true
            line.Size      = UDim2.new(0, length, 0, 2)
            line.Position  = UDim2.new(0, startVec.X, 0, startVec.Y)
            line.Rotation  = math.deg(angle)
        end)
    end
end)

-- =====================================================
-- MAIN FARMING LOOP
-- =====================================================
task.spawn(function()
    while task.wait(0.1) do
        if not HumanoidRootPart or not HumanoidRootPart.Parent then continue end

        local farming = Settings.AutoFarm or Settings.AutoDrain or Settings.AutoStor or
                        Settings.AutoToken or Settings.AutoChest or Settings.AutoPhone
        if not farming then continue end

        local isFull = false
        pcall(function()
            local interface = PlayerGui:FindFirstChild("Interface")
            if interface then
                local holder = interface:FindFirstChild("Holder")
                if holder then
                    local bf = holder:FindFirstChild("BucketFill")
                    if bf then
                        local bar = bf:FindFirstChild("Bar")
                        if bar then
                            local prog = bar:FindFirstChild("Progress")
                            if prog and prog.Text == "100% Full" then
                                isFull = true
                            end
                        end
                    end
                end
            end
        end)

        if (Settings.AutoDrain or Settings.AutoFarm) and not isFull then
            pcall(function() if useBucket then useBucket:FireServer() end end)
        end

        if Settings.AutoPhone or Settings.AutoFarm then
            pcall(function()
                local phone = Workspace:FindFirstChild("Phone")
                if phone then
                    local handle = phone:FindFirstChild("PhoneHandle")
                    if handle then
                        local prompt = handle:FindFirstChild("ProximityPrompt")
                        if prompt and prompt.Enabled then
                            pcall(function() fireproximityprompt(prompt) end)
                        end
                    end
                end
            end)
        end

        local scripted = Workspace:FindFirstChild("Scripted")
        if scripted then
            if Settings.AutoChest or Settings.AutoFarm then
                pcall(function()
                    local chests = scripted:FindFirstChild("Chests")
                    if chests then
                        for _, prompt in ipairs(chests:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                pcall(function() fireproximityprompt(prompt) end)
                            end
                        end
                    end
                end)
            end

            local targetDrains = {}
            pcall(function()
                for _, obj in ipairs(scripted:GetChildren()) do
                    if obj.Name == "Drain" then table.insert(targetDrains, obj) end
                end
            end)
            pcall(function()
                local cp = scripted:FindFirstChild("CheckpointParts")
                if cp then
                    local cp1 = cp:FindFirstChild("1")
                    if cp1 then
                        for _, obj in ipairs(cp1:GetChildren()) do
                            if obj.Name == "Drain" then table.insert(targetDrains, obj) end
                        end
                    end
                end
            end)

            for _, drainObj in ipairs(targetDrains) do
                pcall(function()
                    local s = drainObj:FindFirstChild("Scripted")
                    if not s then return end

                    local mainPrompt
                    pcall(function()
                        local pp = s:FindFirstChild("ProximityPosition")
                        if pp then mainPrompt = pp:FindFirstChild("ProximityPrompt") end
                    end)

                    local visualTokenPrompt
                    pcall(function()
                        local tt = s:FindFirstChild("TakeTokens")
                        if tt then visualTokenPrompt = tt:FindFirstChild("ProximityPrompt") end
                    end)

                    if (Settings.AutoStor or Settings.AutoFarm) and isFull and mainPrompt then
                        pcall(function() if pourBucket then pourBucket:FireServer(mainPrompt) end end)
                    end

                    if Settings.AutoToken or Settings.AutoFarm then
                        if mainPrompt and takeToken then
                            pcall(function() takeToken:FireServer(mainPrompt) end)
                        end
                        if visualTokenPrompt and visualTokenPrompt.Enabled then
                            pcall(function() fireproximityprompt(visualTokenPrompt) end)
                        end
                    end
                end)
            end
        end
    end
end)

-- =====================================================
-- AUTO UPGRADE LOOP
-- =====================================================
task.spawn(function()
    local categories = {"buckets", "root", "diamonds", "character"}

    local coords = {}
    for x = -10, 10 do
        for y = -10, 10 do
            table.insert(coords, {x, y})
        end
    end

    table.sort(coords, function(a, b)
        return (math.abs(a[1]) + math.abs(a[2])) < (math.abs(b[1]) + math.abs(b[2]))
    end)

    while task.wait(2) do
        if Settings.AutoUpgrade or Settings.AutoFarm then
            for _, category in ipairs(categories) do
                if not (Settings.AutoUpgrade or Settings.AutoFarm) then break end
                for _, coord in ipairs(coords) do
                    if not (Settings.AutoUpgrade or Settings.AutoFarm) then break end
                    pcall(function()
                        if skillTreePurchase then
                            skillTreePurchase:InvokeServer(category, coord[1], coord[2])
                        end
                    end)
                    task.wait(0.01)
                end
            end
        end
    end
end)

-- =====================================================
-- NOCLIP
-- =====================================================
RunService.Stepped:Connect(function()
    if Settings.Noclip and Character then
        pcall(function()
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- =====================================================
-- INFINITE JUMP
-- =====================================================
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and Humanoid then
        pcall(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

-- =====================================================
-- INSTANT PROMPT (always scanning)
-- =====================================================
local instantPromptConn
local function startInstantPrompt()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.HoldDuration > 0 then
                obj.HoldDuration = 0
            end
        end
    end)
    if not instantPromptConn then
        instantPromptConn = Workspace.DescendantAdded:Connect(function(obj)
            if Settings.InstantPrompt and obj:IsA("ProximityPrompt") then
                pcall(function() obj.HoldDuration = 0 end)
            end
        end)
    end
end
local function stopInstantPrompt()
    if instantPromptConn then
        pcall(function() instantPromptConn:Disconnect() end)
        instantPromptConn = nil
    end
end

task.spawn(function()
    while task.wait(2) do
        if Settings.InstantPrompt then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.HoldDuration > 0 then
                        obj.HoldDuration = 0
                    end
                end
            end)
        end
    end
end)

-- =====================================================
-- ANTI AFK
-- =====================================================
task.spawn(function()
    while task.wait(60) do
        if Settings.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- =====================================================
-- MAIN TAB
-- =====================================================
MainTab:Divider()
MainTab:Section({ Title = "Auto Farm Features", Icon = "rocket" })
MainTab:Paragraph({
    Title = "Drain The Lake - Auto Farm",
    Desc  = "Enable 'Auto Farm' to run all features, or toggle them individually.",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})

MainTab:Toggle({
    Title    = "Auto Farm (All-In-One)",
    Desc     = "Enable all farming systems at once",
    Value    = Settings.AutoFarm,
    Callback = function(v)
        Settings.AutoFarm = v
        Config.Save()
        WindUI:Notify({ Title = "Auto Farm", Content = v and "Enabled" or "Disabled", Duration = 3, Icon = v and "zap" or "zap-off" })
    end
})

MainTab:Divider()
MainTab:Section({ Title = "Individual Features", Icon = "settings" })

MainTab:Toggle({
    Title    = "Auto Drain",
    Desc     = "Use the bucket to drain water automatically",
    Value    = Settings.AutoDrain,
    Callback = function(v) Settings.AutoDrain = v; Config.Save() end
})
MainTab:Toggle({
    Title    = "Auto Stor",
    Desc     = "Pour water automatically when bucket is full",
    Value    = Settings.AutoStor,
    Callback = function(v) Settings.AutoStor = v; Config.Save() end
})
MainTab:Toggle({
    Title    = "Auto Token",
    Desc     = "Collect tokens automatically",
    Value    = Settings.AutoToken,
    Callback = function(v) Settings.AutoToken = v; Config.Save() end
})
MainTab:Toggle({
    Title    = "Auto Chest",
    Desc     = "Open chests automatically",
    Value    = Settings.AutoChest,
    Callback = function(v) Settings.AutoChest = v; Config.Save() end
})
MainTab:Toggle({
    Title    = "Auto Phone",
    Desc     = "Interact with phone automatically",
    Value    = Settings.AutoPhone,
    Callback = function(v) Settings.AutoPhone = v; Config.Save() end
})
MainTab:Toggle({
    Title    = "Auto Upgrade",
    Desc     = "Upgrade skill tree automatically",
    Value    = Settings.AutoUpgrade,
    Callback = function(v) Settings.AutoUpgrade = v; Config.Save() end
})

-- =====================================================
-- ESP TAB
-- =====================================================
EspTab:Divider()
EspTab:Section({ Title = "ESP Types", Icon = "eye" })
EspTab:Paragraph({
    Title = "ESP Features",
    Desc  = "Enable ESP to see objects through walls. Customize below.",
    Image = "eye",
})

EspTab:Toggle({
    Title    = "ESP Player",
    Desc     = "Show ESP on other players",
    Value    = Settings.ESP_Player,
    Callback = function(v) Settings.ESP_Player = v; Config.Save() end
})
EspTab:Toggle({
    Title    = "ESP Chest",
    Desc     = "Show ESP on chests",
    Value    = Settings.ESP_Chest,
    Callback = function(v) Settings.ESP_Chest = v; Config.Save() end
})
EspTab:Toggle({
    Title    = "ESP Phone",
    Desc     = "Show ESP on phone",
    Value    = Settings.ESP_Phone,
    Callback = function(v) Settings.ESP_Phone = v; Config.Save() end
})
EspTab:Toggle({
    Title    = "ESP Drain",
    Desc     = "Show ESP on drain points",
    Value    = Settings.ESP_Drain,
    Callback = function(v) Settings.ESP_Drain = v; Config.Save() end
})
EspTab:Toggle({
    Title    = "ESP Token Orbs",
    Desc     = "Show ESP on tokens",
    Value    = Settings.ESP_TokenOrb,
    Callback = function(v) Settings.ESP_TokenOrb = v; Config.Save() end
})

EspTab:Divider()
EspTab:Section({ Title = "ESP Settings", Icon = "sliders" })

EspTab:Toggle({
    Title    = "Show Box",
    Desc     = "Draw a box around the target",
    Value    = Settings.ESP_Box,
    Callback = function(v) Settings.ESP_Box = v; Config.Save() end
})
EspTab:Toggle({
    Title    = "Show Name",
    Desc     = "Display the target name",
    Value    = Settings.ESP_Name,
    Callback = function(v) Settings.ESP_Name = v; Config.Save() end
})
EspTab:Toggle({
    Title    = "Show Distance",
    Desc     = "Display distance to the target",
    Value    = Settings.ESP_Distance,
    Callback = function(v) Settings.ESP_Distance = v; Config.Save() end
})
EspTab:Toggle({
    Title    = "Show Tracer",
    Desc     = "Draw a line from screen to target",
    Value    = Settings.ESP_Tracer,
    Callback = function(v) Settings.ESP_Tracer = v; Config.Save() end
})

-- =====================================================
-- PLAYER TAB
-- =====================================================
PlayerTab:Divider()
PlayerTab:Section({ Title = "Movement", Icon = "user" })
PlayerTab:Paragraph({
    Title = "Player Modifications",
    Desc  = "Adjust your character's movement and abilities.",
    Image = "user",
})

local movementMaster = Settings.SpeedEnabled or Settings.JumpEnabled

PlayerTab:Toggle({
    Title    = "Movement Enabled",
    Desc     = "Toggle all movement modifications",
    Value    = movementMaster,
    Callback = function(v)
        Settings.SpeedEnabled = v
        Settings.JumpEnabled  = v
        Config.Save()
        if Humanoid then
            pcall(function() Humanoid.WalkSpeed = v and Settings.SpeedValue or 16 end)
            pcall(function()
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = v and Settings.JumpValue or 50
            end)
        end
        WindUI:Notify({ Title = "Movement", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = "user" })
    end
})

PlayerTab:Slider({
    Title    = "Walk Speed",
    Desc     = "Adjust walking speed",
    Step     = 1,
    Value    = { Min = 0, Max = 500, Default = Settings.SpeedValue },
    Callback = function(v)
        Settings.SpeedValue = v
        Config.Save()
        if Settings.SpeedEnabled and Humanoid then
            pcall(function() Humanoid.WalkSpeed = v end)
        end
    end
})

PlayerTab:Dropdown({
    Title    = "Speed Preset",
    Desc     = "Quick speed selection",
    Values   = { "Default (16)", "Fast (50)", "Very Fast (100)", "Extreme (250)", "Custom" },
    Value    = "Default (16)",
    Callback = function(v)
        local val = 16
        if v == "Fast (50)" then val = 50
        elseif v == "Very Fast (100)" then val = 100
        elseif v == "Extreme (250)" then val = 250 end
        Settings.SpeedValue = val
        if Settings.SpeedEnabled and Humanoid then
            pcall(function() Humanoid.WalkSpeed = val end)
        end
        WindUI:Notify({ Title = "Speed", Content = "Set to " .. val, Duration = 2, Icon = "gauge" })
    end
})

PlayerTab:Slider({
    Title    = "Jump Power",
    Desc     = "Adjust jump height",
    Step     = 1,
    Value    = { Min = 0, Max = 500, Default = Settings.JumpValue },
    Callback = function(v)
        Settings.JumpValue = v
        Config.Save()
        if Settings.JumpEnabled and Humanoid then
            pcall(function()
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = v
            end)
        end
    end
})

PlayerTab:Dropdown({
    Title    = "Jump Preset",
    Desc     = "Quick jump height selection",
    Values   = { "Default (50)", "High (100)", "Very High (150)", "Extreme (250)", "Custom" },
    Value    = "Default (50)",
    Callback = function(v)
        local val = 50
        if v == "High (100)" then val = 100
        elseif v == "Very High (150)" then val = 150
        elseif v == "Extreme (250)" then val = 250 end
        Settings.JumpValue = val
        if Settings.JumpEnabled and Humanoid then
            pcall(function()
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = val
            end)
        end
        WindUI:Notify({ Title = "Jump", Content = "Set to " .. val, Duration = 2, Icon = "arrow-up" })
    end
})

PlayerTab:Divider()
PlayerTab:Section({ Title = "Abilities", Icon = "zap" })

PlayerTab:Toggle({
    Title    = "Noclip",
    Desc     = "Walk through walls and objects",
    Value    = Settings.Noclip,
    Callback = function(v)
        Settings.Noclip = v
        Config.Save()
        WindUI:Notify({ Title = "Noclip", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "eye-off" or "eye" })
    end
})

PlayerTab:Toggle({
    Title    = "Infinite Jump",
    Desc     = "Jump unlimitedly while in the air",
    Value    = Settings.InfiniteJump,
    Callback = function(v) Settings.InfiniteJump = v; Config.Save() end
})

PlayerTab:Toggle({
    Title    = "Instant Prompt",
    Desc     = "Remove hold delay from all prompts",
    Value    = Settings.InstantPrompt,
    Callback = function(v)
        Settings.InstantPrompt = v
        Config.Save()
        if v then
            startInstantPrompt()
        else
            stopInstantPrompt()
        end
        WindUI:Notify({ Title = "Instant Prompt", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = "zap" })
    end
})

PlayerTab:Divider()
PlayerTab:Section({ Title = "Misc", Icon = "shield" })

PlayerTab:Toggle({
    Title    = "Anti AFK",
    Desc     = "Prevent idle kick from the server",
    Value    = Settings.AntiAFK,
    Callback = function(v) Settings.AntiAFK = v; Config.Save() end
})

-- =====================================================
-- COLLECT (TELEPORT) TAB
-- =====================================================
TeleportTab:Divider()
TeleportTab:Section({ Title = "Quick Teleport", Icon = "package" })
TeleportTab:Paragraph({
    Title = "Teleport",
    Desc  = "Warp to key locations in the game",
    Image = "package",
})

local function findNearestAndTeleport(getChildrenFunc, label)
    pcall(function()
        if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
        local children = getChildrenFunc()
        if not children then return end

        local nearest, nearestDist = nil, math.huge
        for _, target in ipairs(children) do
            local pos
            if target:IsA("BasePart") then pos = target.Position
            elseif target:IsA("Model") then
                local p = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
                if p then pos = p.Position end
            end
            if pos then
                local dist = (HumanoidRootPart.Position - pos).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = target
                end
            end
        end

        if nearest then
            local pos
            if nearest:IsA("BasePart") then pos = nearest.Position + Vector3.new(0, 3, 0)
            else
                local p = nearest.PrimaryPart or nearest:FindFirstChildWhichIsA("BasePart")
                if p then pos = p.Position + Vector3.new(0, 3, 0) end
            end
            if pos then
                HumanoidRootPart.CFrame = CFrame.new(pos)
                WindUI:Notify({ Title = "Teleport", Content = "Teleported to " .. label .. "!", Duration = 2, Icon = "map-pin" })
            end
        end
    end)
end

TeleportTab:Button({
    Title = "Teleport to Nearest Drain",
    Desc  = "Warp to the closest drain point",
    Callback = function()
        findNearestAndTeleport(function()
            local scripted = Workspace:FindFirstChild("Scripted")
            if not scripted then return nil end
            local targets = {}
            for _, obj in ipairs(scripted:GetChildren()) do
                if obj.Name == "Drain" then table.insert(targets, obj) end
            end
            local cp = scripted:FindFirstChild("CheckpointParts")
            if cp then
                local cp1 = cp:FindFirstChild("1")
                if cp1 then
                    for _, obj in ipairs(cp1:GetChildren()) do
                        if obj.Name == "Drain" then table.insert(targets, obj) end
                    end
                end
            end
            return targets
        end, "Drain")
    end
})

TeleportTab:Button({
    Title = "Teleport to Chest",
    Desc  = "Warp to the closest chest",
    Callback = function()
        findNearestAndTeleport(function()
            local scripted = Workspace:FindFirstChild("Scripted")
            if not scripted then return nil end
            local chests = scripted:FindFirstChild("Chests")
            return chests and chests:GetChildren() or nil
        end, "Chest")
    end
})

TeleportTab:Button({
    Title = "Teleport to Phone",
    Desc  = "Warp to the phone",
    Callback = function()
        findNearestAndTeleport(function()
            local phone = Workspace:FindFirstChild("Phone")
            return phone and {phone} or nil
        end, "Phone")
    end
})

TeleportTab:Button({
    Title = "Teleport to Spawn",
    Desc  = "Warp to the spawn point",
    Callback = function()
        pcall(function()
            if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
            HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
            WindUI:Notify({ Title = "Teleport", Content = "Teleported to spawn!", Duration = 2, Icon = "home" })
        end)
    end
})

-- =====================================================
-- SETTINGS TAB
-- =====================================================
do
    SettingsTab:Divider()
    SettingsTab:Section({ Title = "Save Config", Icon = "save" })

    SettingsTab:Button({
        Title = "Save Config (NOW)",
        Desc  = "Save all settings immediately",
        Callback = function()
            Config.Save()
            WindUI:Notify({ Title = "Config Saved", Content = "Settings saved successfully!", Duration = 2, Icon = "save" })
        end
    })

    SettingsTab:Toggle({
        Title = "Auto Save Config",
        Desc  = "Automatically save settings",
        Value = Settings.AutoSaveEnabled,
        Callback = function(state)
            Settings.AutoSaveEnabled = state
            Config.Save()
            if state then Config.AutoSave(Settings.AutoSaveDelay) else Config.AutoSave(0) end
        end
    })

    SettingsTab:Input({
        Title       = "Delay Save Config",
        Value       = tostring(Settings.AutoSaveDelay),
        Placeholder = "Default: 15",
        Callback    = function(text)
            local num = tonumber(text)
            if num and num >= 1 then
                Settings.AutoSaveDelay = num
                Config.Save()
                if Settings.AutoSaveEnabled then Config.AutoSave(num) end
            else
                warn("[DYHUB] Invalid delay value!")
            end
        end
    })

    SettingsTab:Section({ Title = "Server", Icon = "server" })

    SettingsTab:Button({
        Title    = "Serverhop",
        Desc     = "Join a different available server",
        Callback = function()
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
                WindUI:Notify({ Title = "Serverhop", Content = "Switching server...", Duration = 2, Icon = "server" })
                task.wait(1)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            else
                WindUI:Notify({ Title = "Serverhop Failed", Content = "No available servers", Duration = 3, Icon = "alert-triangle" })
            end
        end
    })

    SettingsTab:Button({
        Title    = "Rejoin",
        Desc     = "Rejoin the current server",
        Callback = function()
            WindUI:Notify({ Title = "Rejoin", Content = "Rejoining...", Duration = 2, Icon = "refresh-cw" })
            task.wait(1)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })

    SettingsTab:Section({ Title = "Script", Icon = "code" })

    SettingsTab:Button({
        Title    = "Disable All Features",
        Desc     = "Turn off all features at once",
        Callback = function()
            for k, v in pairs(Settings) do
                if type(v) == "boolean" and v == true then
                    Settings[k] = false
                end
            end
            if Humanoid then
                pcall(function() Humanoid.WalkSpeed = 16 end)
                pcall(function()
                    Humanoid.UseJumpPower = true
                    Humanoid.JumpPower = 50
                end)
            end
            for obj, _ in pairs(ESPObjects) do removeESP(obj) end
            for _, line in pairs(ESPTracers) do
                pcall(function() line:Destroy() end)
            end
            stopInstantPrompt()
            Config.Save()
            WindUI:Notify({ Title = "DYHUB", Content = "All features disabled!", Duration = 2, Icon = "power" })
        end
    })
end

-- =====================================================
-- INFO TAB
-- =====================================================
do
    InfoTab:Section({ Title = "Latest Update", TextXAlignment = "Center", TextSize = 17 })
    InfoTab:Divider()
    InfoTab:Paragraph({
        Title = "Update: 07/16/2026 | CL: " .. ver,
        Desc  = [[• [ Added ] Full-featured Auto Farm system (Drain, Store, Token, Chest, Phone, Upgrade)
• [ Added ] ESP system (Player, Chest, Phone, Drain, Token Orbs)
• [ Added ] Player Mods (Speed, Jump, Noclip, Infinite Jump, Instant Prompt)
• [ Added ] Quick Teleport (Drain, Chest, Phone, Spawn)
• [ Added ] Auto-Save Config System
• [ Added ] Anti AFK
• [ Fixed ] Performance improvements, fixed respawn bug]],
    })
    InfoTab:Divider()

    if not ui then ui = {} end
    if not ui.Creator then ui.Creator = {} end

    ui.Creator.Request = function(requestData)
        local success, result = pcall(function()
            if HttpService.RequestAsync then
                local response = HttpService:RequestAsync({ Url = requestData.Url, Method = requestData.Method or "GET", Headers = requestData.Headers or {} })
                return { Body = response.Body, StatusCode = response.StatusCode, Success = response.Success }
            else
                local body = HttpService:GetAsync(requestData.Url)
                return { Body = body, StatusCode = 200, Success = true }
            end
        end)
        if success then return result else error("HTTP Request failed: " .. tostring(result)) end
    end

    local InviteCode = "jWNDPNMmyB"
    local DiscordAPI  = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

    local function LoadDiscordInfo()
        local success, result = pcall(function()
            return HttpService:JSONDecode(ui.Creator.Request({ Url = DiscordAPI, Method = "GET", Headers = { ["User-Agent"] = "RobloxBot/1.0", ["Accept"] = "application/json" } }).Body)
        end)
        if success and result and result.guild then
            local DiscordInfo = InfoTab:Paragraph({
                Title     = result.guild.name,
                Desc      = ' <font color="#52525b">●</font> Member Count : ' .. tostring(result.approximate_member_count) .. '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(result.approximate_presence_count),
                Image     = "https://cdn.discordapp.com/icons/" .. result.guild.id .. "/" .. result.guild.icon .. ".png?size=1024",
                ImageSize = 42,
            })
            InfoTab:Button({
                Title    = "Update Info",
                Callback = function()
                    local ok, r = pcall(function() return HttpService:JSONDecode(ui.Creator.Request({ Url = DiscordAPI, Method = "GET" }).Body) end)
                    if ok and r and r.guild then
                        DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : ' .. tostring(r.approximate_member_count) .. '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(r.approximate_presence_count))
                        WindUI:Notify({ Title = "Discord Info Updated", Content = "Refreshed!", Duration = 2, Icon = "refresh-cw" })
                    else
                        WindUI:Notify({ Title = "Update Failed", Content = "Could not refresh.", Duration = 3, Icon = "alert-triangle" })
                    end
                end
            })
            InfoTab:Button({
                Title    = "Copy Discord Invite",
                Callback = function()
                    setclipboard("https://discord.gg/" .. InviteCode)
                    WindUI:Notify({ Title = "Copied!", Content = "Discord invite copied!", Duration = 2, Icon = "clipboard-check" })
                end
            })
        else
            InfoTab:Paragraph({ Title = "Error fetching Discord Info", Desc = "Unable to load.", Image = "triangle-alert", ImageSize = 26, Color = "Red" })
        end
    end
    LoadDiscordInfo()

    InfoTab:Divider()
    InfoTab:Section({ Title = "DYHUB Information", TextXAlignment = "Center", TextSize = 17 })
    InfoTab:Divider()
    InfoTab:Paragraph({Title="Main Owner",Desc="@dyumraisgoodguy#8888",Image="rbxassetid://119789418015420",ImageSize=30})
    InfoTab:Paragraph({
        Title     = "Social",
        Desc      = "Copy social link to follow us",
        Image     = "rbxassetid://104487529937663",
        ImageSize = 30,
        Buttons   = { { Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://guns.lol/DYHUB") end } },
    })
    InfoTab:Paragraph({
        Title     = "Discord",
        Desc      = "Join our Discord for more scripts",
        Image     = "rbxassetid://104487529937663",
        ImageSize = 30,
        Buttons   = { { Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://discord.gg/jWNDPNMmyB") end } },
    })
end

-- Start instant prompt if loaded setting is true
if Settings.InstantPrompt then startInstantPrompt() end

print("[DYHUB] " .. version .. " | " .. ver .. " loaded successfully!")
print("[DYHUB] Config active | Auto saving every " .. tostring(Settings.AutoSaveDelay) .. "s")
