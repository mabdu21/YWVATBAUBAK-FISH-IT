-- =========================
local version = "BETA"
local ver     = "v013.21"
-- =========================

repeat task.wait() until game:IsLoaded()

-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

if setfpscap then
    setfpscap(1000000)
    WindUI:Notify({ Title = "Service", Content = "FPS Unlocked! | " .. ver, Duration = 3, Icon = "cpu" })
else
    WindUI:Notify({ Title = "Not Working", Content = "Your exploit does not support setfpscap.", Duration = 3, Icon = "ban" })
end

-- ====================== SERVICES ======================
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local StarterGui        = game:GetService("StarterGui")
local TeleportService   = game:GetService("TeleportService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local VIM               = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = Workspace.CurrentCamera

-- ====================== CHARACTER CACHE ======================
local Character        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid         = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character        = char
    Humanoid         = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- ====================== VERSION CHECK ======================
local FreeVersion    = "Free Version"
local PremiumVersion = "Premium Version"

local function checkVersion(playerName)
    local url = "https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua"
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then return FreeVersion end
    local func = loadstring(response)
    if not func then return FreeVersion end
    local ok, premiumData = pcall(func)
    if not ok then return FreeVersion end
    return premiumData and premiumData[playerName] and PremiumVersion or FreeVersion
end

local userversion = checkVersion(LocalPlayer.Name)
local isPremium   = (userversion == PremiumVersion)

-- ====================== WINDOW ======================
local Window = WindUI:CreateWindow({
    Title      = "DYHUB",
    IconThemed = true,
    Icon       = "rbxassetid://104487529937663",
    Author     = "Animal Hospital | " .. userversion,
    Folder     = "DYHUB_AH",
    Size       = UDim2.fromOffset(500, 400),
    Transparent = true,
    Theme      = "Dark",
    BackgroundImageTransparency = 0.8,
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

-- ====================== CONFIG SYSTEM ======================
local ConfigFolder = "DYHUB_AH"
local CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self      = setmetatable({}, CustomConfig)
    self.ConfigData = {}
    self.ConfigPath = ConfigFolder .. "/config_AH.json"
    self._autoSaveThread = nil
    self._autoSaveDelay  = 15
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    self:Load()
    return self
end
function CustomConfig:Set(key, value) self.ConfigData[key] = value end
function CustomConfig:Get(key, default)
    local v = self.ConfigData[key]
    return v ~= nil and v or default
end
function CustomConfig:Save()
    local ok, err = pcall(function()
        writefile(self.ConfigPath, HttpService:JSONEncode(self.ConfigData))
    end)
    if not ok then warn("[DYHUB] Save failed:", err) end
end
function CustomConfig:Load()
    if isfile(self.ConfigPath) then
        local ok, result = pcall(function()
            return HttpService:JSONDecode(readfile(self.ConfigPath))
        end)
        if ok and type(result) == "table" then
            self.ConfigData = result
            print("[DYHUB] Config loaded!")
        else
            warn("[DYHUB] Failed to load config, using defaults")
            self.ConfigData = {}
        end
    else
        print("[DYHUB] No config found, creating new one")
        self.ConfigData = {}
    end
end
function CustomConfig:AutoSave(interval)
    if self._autoSaveThread then
        task.cancel(self._autoSaveThread)
        self._autoSaveThread = nil
    end
    if interval and interval > 0 then
        self._autoSaveDelay  = interval
        self._autoSaveThread = task.spawn(function()
            while true do
                task.wait(self._autoSaveDelay or 15)
                self:Save()
            end
        end)
    end
end

local Config = CustomConfig.new()
if Config:Get("AutoSaveEnabled", true) then
    Config:AutoSave(Config:Get("AutoSaveDelay", 15))
end

-- ====================== SETTINGS TABLE (รวม state ทั้งหมด) ======================
local settings = {
    AutoTreat       = Config:Get("AutoTreat",       false),
    AutoCoffee      = Config:Get("AutoCoffee",      false),
    AutoCheckIn     = Config:Get("AutoCheckIn",     false),
    EspEnabled      = Config:Get("EspEnabled",      false),
    AutoMedicine    = Config:Get("AutoMedicine",    false),
    AutoSlime       = Config:Get("AutoSlime",       false),
    AutoFire        = Config:Get("AutoFire",        false),
    AutoTaser       = Config:Get("AutoTaser",       false),
    AutoSaveEnabled = Config:Get("AutoSaveEnabled", true),
    AutoSaveDelay   = Config:Get("AutoSaveDelay",   15),
}

-- ====================== SHARED UTILITIES ======================
local ProcessedNPCs = {}

local function firePromptIn(instance)
    if not instance then return end
    local prompt = instance:FindFirstChild("PP") or instance:FindFirstChildOfClass("ProximityPrompt")
    if prompt then fireproximityprompt(prompt) end
end

local function normalizeString(str)
    if not str then return "" end
    return string.gsub(string.lower(str), "%s+", "")
end

local function hasTool(parentFolder, itemName)
    if not parentFolder then return false end
    local normName = normalizeString(itemName)
    for _, tool in ipairs(parentFolder:GetChildren()) do
        if tool:IsA("Tool") and normalizeString(tool.Name) == normName then
            return true
        end
    end
    return false
end

local function getActivePatientInfo()
    local misc = Workspace:FindFirstChild("Misc")
    if not misc then return nil, nil, nil end

    local deskNames = {"CheckIn", "CheckIn2"}
    for _, deskName in ipairs(deskNames) do
        local desk = misc:FindFirstChild(deskName)
        if desk then
            local bell = desk:FindFirstChild("Bell")
            if bell then
                local bellPos
                if bell:IsA("BasePart") then
                    bellPos = bell.Position
                else
                    local actualPart = bell:FindFirstChildOfClass("BasePart") or (bell:IsA("Model") and bell.PrimaryPart)
                    if actualPart then bellPos = actualPart.Position end
                end

                if bellPos then
                    for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
                        if npc:GetAttribute("IsPatient") == true then
                            local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                            if root then
                                local distance = (root.Position - bellPos).Magnitude
                                if distance <= 5 then
                                    return npc, desk, bellPos
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil, nil, nil
end

if Workspace:FindFirstChild("NPCs") then
    Workspace.NPCs.ChildRemoved:Connect(function(child)
        if ProcessedNPCs[child] then ProcessedNPCs[child] = nil end
    end)
end

-- ====================== TABS ======================
local InfoTab     = Window:Tab({ Title = "Information", Icon = "info" })
local _D2         = Window:Divider()
local MainTab     = Window:Tab({ Title = "Main",        Icon = "rocket" })
local EspTab      = Window:Tab({ Title = "Esp",         Icon = "eye" })
local TeleportTab = Window:Tab({ Title = "Collect",     Icon = "package" })
local _D3         = Window:Divider()
local Main3       = Window:Tab({ Title = "Settings",    Icon = "settings" })

Window:SelectTab(1)

-- ====================== MAIN TAB ======================
MainTab:Divider()
MainTab:Section({ Title = "Hospital Automation", Icon = "activity" })

-- FEATURE: Auto Treating Patients
do
    -- Supply item -> pickup position lookup (fixed world positions)
    local ItemPositions = {
        Herbs           = Vector3.new(-137, 3, -59),
        Medicine        = Vector3.new(-137, 3, -62),
        ["Eye Drops"]   = Vector3.new(-153, 3, -57),
        ["IV Drops"]    = Vector3.new(-153, 3, -60),
        ["Cough Syrup"] = Vector3.new(-137, 3, -79),
        ["Maple Syrup"] = Vector3.new(-137, 3, -82),
        Bandages        = Vector3.new(-153, 3, -83),
        Ointment        = Vector3.new(-153, 3, -80),
        Thermo          = Vector3.new(-153, 3, -71),
        Medkit          = Vector3.new(-153, 3, -69),
    }

    local ProcessedTreatment = {}

    MainTab:Paragraph({
        Title = "Auto Treating Patients",
        Desc  = "Runs the full treatment sequence per patient: DNA Sample → Analyzer → Monitor → fetch the reported item → Apply Treatment. Supports every Medical room automatically.",
        Image = "stethoscope", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Treating Patients",
        Desc     = "You must be standing in the same room as the patient for a step to work.",
        Value    = settings.AutoTreat,
        Callback = function(v)
            settings.AutoTreat = v
            Config:Set("AutoTreat", v); Config:Save()
            if not v then table.clear(ProcessedTreatment) end
            WindUI:Notify({ Title="Auto Treating Patients", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "stethoscope" or "ban" })
        end
    })

    -- Point-in-box test using a Model's bounding box, with a small margin
    local function isPositionInModel(position, model, margin)
        local ok, cf, size = pcall(function() return model:GetBoundingBox() end)
        if not ok or not cf then return false end
        local relative = cf:PointToObjectSpace(position)
        local half = size / 2
        margin = margin or 2
        return math.abs(relative.X) <= half.X + margin
           and math.abs(relative.Y) <= half.Y + margin
           and math.abs(relative.Z) <= half.Z + margin
    end

    -- Finds which RoomN model (under Rooms.Medical) the patient NPC is physically inside
    local function findPatientRoom(npc)
        local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        if not root then return nil end
        local rooms   = Workspace:FindFirstChild("Rooms")
        local medical = rooms and rooms:FindFirstChild("Medical")
        if not medical then return nil end

        for _, room in ipairs(medical:GetChildren()) do
            if room:IsA("Model") and string.match(room.Name, "^Room%d+$") then
                if isPositionInModel(root.Position, room) then
                    return room
                end
            end
        end
        return nil
    end

    local function playerInRoom(room)
        if not room or not HumanoidRootPart then return false end
        return isPositionInModel(HumanoidRootPart.Position, room)
    end

    local function getActionText(prompt)
        if not prompt then return "" end
        return prompt.ActionText or ""
    end

    -- Looks for the nearest ProximityPrompt to a world position, first inside `scope`, then falling back to the whole Workspace
    local function findNearestPromptTo(position, scope, maxDist)
        maxDist = maxDist or 15
        local nearestPrompt, nearestDist = nil, maxDist

        local function scan(container)
            for _, desc in ipairs(container:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    local part = desc.Parent
                    if part and part:IsA("BasePart") then
                        local dist = (part.Position - position).Magnitude
                        if dist < nearestDist then
                            nearestDist    = dist
                            nearestPrompt  = desc
                        end
                    end
                end
            end
        end

        if scope then scan(scope) end
        if not nearestPrompt then scan(Workspace) end
        return nearestPrompt
    end

    local function runTreatmentSequence(npc, room)
        if ProcessedTreatment[npc] then return end
        ProcessedTreatment[npc] = true

        task.spawn(function()
            local minigame = room:FindFirstChild("Minigame")

            while npc and npc.Parent and room and room.Parent and settings.AutoTreat
                  and npc:GetAttribute("IsPatient") == true do

                if not playerInRoom(room) then
                    WindUI:Notify({ Title="Auto Treating Patients", Content="โปรดไปที่ห้อง "..room.Name.." ที่ผู้ป่วยอยู่ ถึงสคริปจะทำงาน", Duration=3, Icon="alert-triangle" })
                    task.wait(1.5)
                else
                    local handled = false

                    pcall(function()
                        local npcPP = npc:FindFirstChild("PP")
                        if npcPP and npcPP:IsA("ProximityPrompt") and getActionText(npcPP) == "Take DNA Sample" then
                            fireproximityprompt(npcPP)
                            handled = true
                        end
                    end)

                    if not handled then
                        pcall(function()
                            local analyzerPP = minigame and minigame:FindFirstChild("Analyzer") and minigame.Analyzer:FindFirstChild("PP")
                            if analyzerPP and analyzerPP.Enabled == true then
                                fireproximityprompt(analyzerPP)
                                handled = true
                            end
                        end)
                    end

                    if not handled then
                        pcall(function()
                            local monitorPP2 = minigame and minigame:FindFirstChild("Monitor") and minigame.Monitor:FindFirstChild("PP2")
                            if monitorPP2 and monitorPP2.Enabled == true then
                                fireproximityprompt(monitorPP2)
                                handled = true
                            end
                        end)
                    end

                    if not handled then
                        local isApplyTreatment = false
                        pcall(function()
                            local npcPP = npc:FindFirstChild("PP")
                            if npcPP and getActionText(npcPP) == "Apply Treatment" then
                                isApplyTreatment = true
                            end
                        end)

                        if isApplyTreatment then
                            pcall(function()
                                local tvInv = minigame and minigame:FindFirstChild("TV")
                                    and minigame.TV:FindFirstChild("Screen")
                                    and minigame.TV.Screen:FindFirstChild("UI")
                                    and minigame.TV.Screen.UI:FindFirstChild("Report")
                                    and minigame.TV.Screen.UI.Report:FindFirstChild("inv")

                                local itemName = nil
                                if tvInv then
                                    for _, child in ipairs(tvInv:GetChildren()) do
                                        if ItemPositions[child.Name] then
                                            itemName = child.Name
                                            break
                                        end
                                    end
                                end

                                if itemName and HumanoidRootPart then
                                    local originalCFrame = HumanoidRootPart.CFrame
                                    local targetPos       = ItemPositions[itemName]

                                    HumanoidRootPart.CFrame = CFrame.new(targetPos)
                                    task.wait(0.5)

                                    local nearestPrompt = findNearestPromptTo(targetPos, room)
                                    if nearestPrompt then
                                        fireproximityprompt(nearestPrompt)
                                        task.wait(0.5)
                                    end

                                    HumanoidRootPart.CFrame = originalCFrame
                                    task.wait(0.5)

                                    local npcPP = npc:FindFirstChild("PP")
                                    if npcPP and getActionText(npcPP) == "Apply Treatment" then
                                        fireproximityprompt(npcPP)
                                        handled = true
                                    end
                                end
                            end)
                            task.wait(1.5)
                        end
                    end

                    task.wait(0.3)
                end
            end

            ProcessedTreatment[npc] = nil
        end)
    end

    task.spawn(function()
        while task.wait(1) do
            if settings.AutoTreat and Workspace:FindFirstChild("NPCs") then
                for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
                    if npc:GetAttribute("IsPatient") == true and not ProcessedTreatment[npc] then
                        local room = findPatientRoom(npc)
                        if room then runTreatmentSequence(npc, room) end
                    end
                end
            end
        end
    end)
end

-- FEATURE: Auto Coffee Machine
do
    MainTab:Paragraph({
        Title = "Auto Coffee Machine",
        Desc  = "Automatically brews and grabs coffee when the machine is ready.",
        Image = "coffee", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Coffee Machine",
        Desc     = "Automatically operates the coffee machine.",
        Value    = settings.AutoCoffee,
        Callback = function(v)
            settings.AutoCoffee = v
            Config:Set("AutoCoffee", v); Config:Save()
            WindUI:Notify({ Title="Auto Coffee", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "coffee" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(0.5) do
            if settings.AutoCoffee then
                pcall(function()
                    local coffeeMachine = Workspace:FindFirstChild("CoffeeMachine") or (Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("CoffeeMachine"))
                    if coffeeMachine then
                        local statusUI = coffeeMachine:FindFirstChild("Attachment") and coffeeMachine.Attachment:FindFirstChild("UI")
                        local statusLabel = statusUI and statusUI:FindFirstChild("status")
                        if statusLabel and string.find(statusLabel.Text:lower(), "ready") then
                            firePromptIn(coffeeMachine:FindFirstChild("Coffee"))
                        end
                    end
                end)
            end
        end
    end)
end

-- FEATURE: Auto Check-In (Normal Only)
do
    MainTab:Paragraph({
        Title = "Auto Check-In (Normal Only)",
        Desc  = "Automatically checks in normal patients. Skips anomalies (Skinwalkers).",
        Image = "clipboard-check", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Check-In (Normal Only)",
        Desc     = "Automatically checks in normal patients at the front desk.",
        Value    = settings.AutoCheckIn,
        Callback = function(v)
            settings.AutoCheckIn = v
            Config:Set("AutoCheckIn", v); Config:Save()
            if not v then table.clear(ProcessedNPCs) end
            WindUI:Notify({ Title="Auto Check-In", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "clipboard-check" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(1) do
            if settings.AutoCheckIn then
                local activeNPC, activeDesk, bellPos = getActivePatientInfo()

                if activeNPC and activeDesk and bellPos and not ProcessedNPCs[activeNPC] then
                    local isSkinwalker = activeNPC:GetAttribute("Skinwalker")

                    if isSkinwalker == true then
                        ProcessedNPCs[activeNPC] = true
                    else
                        ProcessedNPCs[activeNPC] = true

                        task.spawn(function()
                            local mainCheckIn = Workspace.Misc:FindFirstChild("CheckIn")

                            if mainCheckIn then
                                while activeNPC and activeNPC.Parent and settings.AutoCheckIn do
                                    local root = activeNPC:FindFirstChild("HumanoidRootPart") or activeNPC.PrimaryPart
                                    if not root or (root.Position - bellPos).Magnitude > 5 then
                                        break
                                    end

                                    pcall(function()
                                        local form = activeDesk:FindFirstChild("Form")
                                        firePromptIn(form)
                                        task.wait(0.7)

                                        local camera = activeDesk:FindFirstChild("Camera")
                                        firePromptIn(camera)
                                        task.wait(0.7)

                                        local computer = mainCheckIn:FindFirstChild("Computer")
                                        firePromptIn(computer)
                                        task.wait(0.7)

                                        local printer = mainCheckIn:FindFirstChild("Printer")
                                        firePromptIn(printer)
                                        task.wait(0.7)

                                        local printedBadge = activeDesk:FindFirstChild("PrintedBadge")
                                        firePromptIn(printedBadge)
                                        task.wait(0.7)

                                        firePromptIn(activeNPC)
                                    end)

                                    task.wait(0.1)
                                end
                            end
                        end)
                    end
                end
            end
        end
    end)
end

-- FEATURE: Auto Clean Slime
do
    MainTab:Paragraph({
        Title = "Auto Clean Slime",
        Desc  = "Automatically cleans up slime spills.",
        Image = "droplet", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Clean Slime",
        Desc     = "Automatically cleans slime around the hospital.",
        Value    = settings.AutoSlime,
        Callback = function(v)
            settings.AutoSlime = v
            Config:Set("AutoSlime", v); Config:Save()
            WindUI:Notify({ Title="Auto Clean Slime", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "droplet" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(1) do
            if settings.AutoSlime then
                pcall(function()
                    local slime = Workspace:FindFirstChild("Slime") or (Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("Slime"))
                    if slime then firePromptIn(slime) end
                end)
            end
        end
    end)
end

-- FEATURE: Auto Extinguish Fire
do
    MainTab:Paragraph({
        Title = "Auto Extinguish Fire",
        Desc  = "Automatically extinguishes fires in rooms.",
        Image = "flame", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Extinguish Fire",
        Desc     = "Automatically finds and extinguishes fires.",
        Value    = settings.AutoFire,
        Callback = function(v)
            settings.AutoFire = v
            Config:Set("AutoFire", v); Config:Save()
            WindUI:Notify({ Title="Auto Extinguish Fire", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "flame" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(1) do
            if settings.AutoFire then
                pcall(function()
                    local rooms = Workspace:FindFirstChild("Rooms")
                    if rooms then
                        for _, desc in ipairs(rooms:GetDescendants()) do
                            if desc.Name == "Fire" then
                                for _, pp in ipairs(desc:GetDescendants()) do
                                    if pp.Name == "PP" or pp:IsA("ProximityPrompt") then
                                        fireproximityprompt(pp)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

-- FEATURE: Auto Taser Anomaly
do
    MainTab:Paragraph({
        Title = "Auto Taser Anomaly",
        Desc  = "Automatically grabs a taser and fires it at an active anomaly (Skinwalker).",
        Image = "zap", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Taser Anomaly",
        Desc     = "Automatically tasers anomalies when detected.",
        Value    = settings.AutoTaser,
        Callback = function(v)
            settings.AutoTaser = v
            Config:Set("AutoTaser", v); Config:Save()
            WindUI:Notify({ Title="Auto Taser Anomaly", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "zap" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(0.5) do
            if settings.AutoTaser then
                pcall(function()
                    local hasSkinwalker = false
                    local targetNPC = nil

                    for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
                        if npc:GetAttribute("Skinwalker") == true then
                            hasSkinwalker = true
                            targetNPC = npc
                            break
                        end
                    end

                    if hasSkinwalker and targetNPC then
                        local char = LocalPlayer.Character
                        local backpack = LocalPlayer:FindFirstChild("Backpack")

                        local hasTaser = false
                        if backpack and backpack:FindFirstChild("Taser") then hasTaser = true end
                        if char and char:FindFirstChild("Taser") then hasTaser = true end

                        if not hasTaser then
                            local taserStation = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("TaserStation")
                            local mainPart = taserStation and taserStation:FindFirstChild("Main")

                            if mainPart then
                                local statusUI = mainPart:FindFirstChild("Attachment") and mainPart.Attachment:FindFirstChild("UI")
                                local statusLabel = statusUI and statusUI:FindFirstChild("status")

                                if statusLabel and statusLabel.Text and string.find(string.lower(statusLabel.Text), "ready") then
                                    local taserPrompt = mainPart:FindFirstChild("PP")

                                    if taserPrompt and taserPrompt:IsA("ProximityPrompt") then
                                        local oldDist = taserPrompt.MaxActivationDistance
                                        local oldLOS = taserPrompt.RequiresLineOfSight

                                        taserPrompt.MaxActivationDistance = 9e9
                                        taserPrompt.RequiresLineOfSight = false

                                        fireproximityprompt(taserPrompt)

                                        task.spawn(function()
                                            task.wait(0.5)
                                            taserPrompt.MaxActivationDistance = oldDist
                                            taserPrompt.RequiresLineOfSight = oldLOS
                                        end)

                                        task.wait(0.8)
                                    end
                                end
                            end
                        end

                        local hasTaserNow = false
                        if backpack and backpack:FindFirstChild("Taser") then hasTaserNow = true end
                        if char and char:FindFirstChild("Taser") then hasTaserNow = true end

                        if hasTaserNow then
                            local args = { targetNPC }
                            ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net"):WaitForChild("RE/TaserFired"):FireServer(unpack(args))
                            task.wait(1)
                        end
                    end
                end)
            end
        end
    end)
end

-- ====================== ESP TAB ======================
EspTab:Divider()
EspTab:Section({ Title = "NPC Detection", Icon = "eye" })

do
    EspTab:Paragraph({
        Title = "NPC Anomaly ESP",
        Desc  = "Highlights all NPCs and tags whether they are a normal patient or an anomaly (Skinwalker).",
        Image = "eye", ImageSize = 30,
    })
    EspTab:Toggle({
        Title    = "NPC Anomaly ESP",
        Desc     = "Shows highlight + tag on all NPCs.",
        Value    = settings.EspEnabled,
        Callback = function(v)
            settings.EspEnabled = v
            Config:Set("EspEnabled", v); Config:Save()
            if not v and Workspace:FindFirstChild("NPCs") then
                for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
                    if npc:FindFirstChild("AnomalyHighlight") then npc.AnomalyHighlight:Destroy() end
                    if npc:FindFirstChild("AnomalyTag") then npc.AnomalyTag:Destroy() end
                end
            end
            WindUI:Notify({ Title="NPC ESP", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "eye" or "eye-off" })
        end
    })

    local function applyESP(npc)
        if not settings.EspEnabled then return end
        local isSkinwalker = npc:GetAttribute("Skinwalker")
        local color = isSkinwalker == true and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

        local highlight = npc:FindFirstChild("AnomalyHighlight") or Instance.new("Highlight", npc)
        highlight.Name, highlight.FillColor, highlight.FillTransparency, highlight.OutlineColor, highlight.OutlineTransparency, highlight.Enabled = "AnomalyHighlight", color, 0.5, color, 0, true

        local root = npc:FindFirstChild("HumanoidRootPart")
        if root then
            local tag = npc:FindFirstChild("AnomalyTag") or Instance.new("BillboardGui", npc)
            tag.Name, tag.Size, tag.AlwaysOnTop, tag.StudsOffset = "AnomalyTag", UDim2.new(0, 200, 0, 50), true, Vector3.new(0, 3, 0)
            local label = tag:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel", tag)
            label.Size, label.BackgroundTransparency, label.Font, label.TextSize = UDim2.new(1, 0, 1, 0), 1, Enum.Font.GothamBold, 14

            tag.Enabled = true
            label.Text = npc.Name .. "\n" .. (isSkinwalker == true and "[ANOMALY]" or "[NORMAL]")
            label.TextColor3 = color
        end
    end
    task.spawn(function()
        while task.wait(1) do
            if settings.EspEnabled and Workspace:FindFirstChild("NPCs") then
                for _, npc in ipairs(Workspace.NPCs:GetChildren()) do pcall(applyESP, npc) end
            end
        end
    end)
end

-- ====================== COLLECT TAB ======================
TeleportTab:Divider()
TeleportTab:Section({ Title = "Auto Collect", Icon = "package" })

do
    TeleportTab:Paragraph({
        Title = "Auto Collect Medicine (Room 8)",
        Desc  = "Reads the TV checklist in Room 8 and grabs only the medicine items still needed.",
        Image = "package", ImageSize = 30,
    })
    TeleportTab:Toggle({
        Title    = "Auto Collect Medicine (Room 8)",
        Desc     = "Automatically grabs required medicine based on the Room 8 checklist.",
        Value    = settings.AutoMedicine,
        Callback = function(v)
            settings.AutoMedicine = v
            Config:Set("AutoMedicine", v); Config:Save()
            WindUI:Notify({ Title="Auto Collect Medicine", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "package" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(0.5) do
            if settings.AutoMedicine then
                pcall(function()
                    local rooms = Workspace:FindFirstChild("Rooms")
                    if not rooms then return end
                    local emergency = rooms:FindFirstChild("Emergency")
                    if not emergency then return end
                    local room8 = emergency:FindFirstChild("Room8")
                    if not room8 then return end
                    local minigame = room8:FindFirstChild("Minigame")
                    if not minigame then return end

                    local tv = minigame:FindFirstChild("TV")
                    local medicineFolder = minigame:FindFirstChild("Medicine")
                    if not tv or not medicineFolder then return end

                    local itemsNeeded = {}

                    for _, desc in ipairs(tv:GetDescendants()) do
                        if desc.Name == "inv" then
                            for _, uiItem in ipairs(desc:GetChildren()) do
                                if uiItem:IsA("GuiObject") and not uiItem:IsA("UIListLayout") and not uiItem:IsA("UIPadding") and not uiItem:IsA("UICorner") then
                                    local checkMark = uiItem:FindFirstChild("check")
                                    if checkMark and checkMark.Visible == true then
                                        -- already checked off, skip
                                    else
                                        itemsNeeded[uiItem.Name] = true
                                    end
                                end
                            end
                        end
                    end

                    local grabbedSomething = false

                    for itemName, _ in pairs(itemsNeeded) do
                        local normItemName = normalizeString(itemName)
                        local char = LocalPlayer.Character

                        if not hasTool(LocalPlayer.Backpack, itemName) and not hasTool(char, itemName) then
                            for _, desc in ipairs(medicineFolder:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    local parentName = desc.Parent and desc.Parent.Name or ""
                                    if normalizeString(parentName) == normItemName or normalizeString(desc.ObjectText) == normItemName then

                                        local oldDist = desc.MaxActivationDistance
                                        local oldLOS = desc.RequiresLineOfSight

                                        desc.MaxActivationDistance = 9e9
                                        desc.RequiresLineOfSight = false

                                        fireproximityprompt(desc)

                                        task.spawn(function()
                                            task.wait(0.5)
                                            desc.MaxActivationDistance = oldDist
                                            desc.RequiresLineOfSight = oldLOS
                                        end)

                                        grabbedSomething = true
                                        task.wait(0.3)
                                        break
                                    end
                                end
                            end
                        end
                    end

                    if grabbedSomething then
                        task.wait(5)
                    end
                end)
            end
        end
    end)
end

-- ====================== INFO TAB ======================
local Info = InfoTab
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

Info:Section({ Title = "Latest Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({
    Title = "Update: 07/09/2026 | CL: " .. ver,
    Desc  = [[• [ Added ] Auto Treating Patients (DNA Sample → Analyzer → Monitor → Fetch Item → Apply Treatment, multi-room)
• [ Added ] Auto Coffee Machine
• [ Added ] Auto Check-In (Normal Only)
• [ Added ] Auto Collect Medicine (Room 8)
• [ Added ] Auto Clean Slime
• [ Added ] Auto Extinguish Fire
• [ Added ] Auto Taser Anomaly
• [ Added ] NPC Anomaly ESP
• [ Changed ] Rebuilt UI on WindUI with full auto-save config
• [ Changed ] Renamed target game to Animal Hospital ]],
})
Info:Divider()

-- ====================== SETTINGS TAB ======================
do
Main3:Divider()
Main3:Section({Title="Save Config",Icon="save"})
Main3:Button({Title="Save Config (NOW)", Desc = "Saves all current settings immediately.",Callback=function()
    Config:Save(); WindUI:Notify({Title="Config Saved",Content="Config saved successfully!",Duration=2,Icon="save"})
end})
Main3:Toggle({Title="Auto Save Config", Desc = "Automatically saves config at set interval.",Value=settings.AutoSaveEnabled,Callback=function(state)
    settings.AutoSaveEnabled=state; Config:Set("AutoSaveEnabled",state); Config:Save()
    if state then Config:AutoSave(settings.AutoSaveDelay) else Config:AutoSave(0) end
end})
Main3:Input({Title="Delay Save Config",Value=tostring(settings.AutoSaveDelay),Placeholder="Default: 15",Callback=function(text)
    local num=tonumber(text)
    if num and num>=1 then
        settings.AutoSaveDelay=num; Config:Set("AutoSaveDelay",num); Config:Save()
        if settings.AutoSaveEnabled then Config:AutoSave(num) end
    else warn("[DYHUB] Invalid delay value!") end
end})

Main3:Section({Title="Server Status",Icon="server"})
Main3:Button({Title="Serverhop", Desc = "Teleports you to a different random server.",Callback=function()
    local servers={}
    local success,result=pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
    end)
    if success and result and result.data then
        for _,server in ipairs(result.data) do
            if server.id~=game.JobId and server.playing<server.maxPlayers then table.insert(servers,server.id) end
        end
    end
    if #servers>0 then
        WindUI:Notify({Title="Serverhop",Content="Teleporting...",Duration=2,Icon="server"}); task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId,servers[math.random(1,#servers)],LocalPlayer)
    else WindUI:Notify({Title="Serverhop Failed",Content="No available servers.",Duration=3,Icon="alert-triangle"}) end
end})
Main3:Button({Title="Rejoin", Desc = "Rejoins the current game server.",Callback=function()
    WindUI:Notify({Title="Rejoin",Content="Rejoining...",Duration=2,Icon="refresh-cw"}); task.wait(1)
    TeleportService:Teleport(game.PlaceId,LocalPlayer)
end})
end -- SETTINGS TAB do-scope

-- ====================== INFORMATION TAB (Discord + Owner) ======================
do
ui.Creator.Request=function(requestData)
    local success,result=pcall(function()
        if HttpService.RequestAsync then
            local response=HttpService:RequestAsync({Url=requestData.Url,Method=requestData.Method or "GET",Headers=requestData.Headers or {}})
            return {Body=response.Body,StatusCode=response.StatusCode,Success=response.Success}
        else local body=HttpService:GetAsync(requestData.Url); return {Body=body,StatusCode=200,Success=true} end
    end)
    if success then return result else error("HTTP Request failed: "..tostring(result)) end
end

local InviteCode="jWNDPNMmyB"
local DiscordAPI="https://discord.com/api/v10/invites/"..InviteCode.."?with_counts=true&with_expiration=true"
local function LoadDiscordInfo()
    local success,result=pcall(function()
        return HttpService:JSONDecode(ui.Creator.Request({Url=DiscordAPI,Method="GET",Headers={["User-Agent"]="RobloxBot/1.0",["Accept"]="application/json"}}).Body)
    end)
    if success and result and result.guild then
        local DiscordInfo=Info:Paragraph({
            Title=result.guild.name,
            Desc=' <font color="#52525b">●</font> Member Count : '..tostring(result.approximate_member_count)..'\n <font color="#16a34a">●</font> Online Count : '..tostring(result.approximate_presence_count),
            Image="https://cdn.discordapp.com/icons/"..result.guild.id.."/"..result.guild.icon..".png?size=1024",ImageSize=42,
        })
        Info:Button({Title="Update Info",Callback=function()
            local ok,r=pcall(function() return HttpService:JSONDecode(ui.Creator.Request({Url=DiscordAPI,Method="GET"}).Body) end)
            if ok and r and r.guild then
                DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : '..tostring(r.approximate_member_count)..'\n <font color="#16a34a">●</font> Online Count : '..tostring(r.approximate_presence_count))
                WindUI:Notify({Title="Discord Info Updated",Content="Refreshed!",Duration=2,Icon="refresh-cw"})
            else WindUI:Notify({Title="Update Failed",Content="Could not refresh.",Duration=3,Icon="alert-triangle"}) end
        end})
        Info:Button({Title="Copy Discord Invite",Callback=function()
            setclipboard("https://discord.gg/"..InviteCode); WindUI:Notify({Title="Copied!",Content="Discord invite copied!",Duration=2,Icon="clipboard-check"})
        end})
    else Info:Paragraph({Title="Error fetching Discord Info",Desc="Unable to load.",Image="triangle-alert",ImageSize=26,Color="Red"}) end
end
LoadDiscordInfo()

Info:Divider()
Info:Section({Title="DYHUB Information",TextXAlignment="Center",TextSize=17})
Info:Divider()
Info:Paragraph({Title="Main Owner",Desc="@dyumraisgoodguy#8888",Image="rbxassetid://119789418015420",ImageSize=30})
Info:Paragraph({Title="Social",Desc="Copy link social media for follow!",Image="rbxassetid://104487529937663",ImageSize=30,
    Buttons={{Icon="copy",Title="Copy Link",Callback=function() setclipboard("https://guns.lol/DYHUB") end}}})
Info:Paragraph({Title="Discord",Desc="Join our discord for more scripts!",Image="rbxassetid://104487529937663",ImageSize=30,
    Buttons={{Icon="copy",Title="Copy Link",Callback=function() setclipboard("https://discord.gg/jWNDPNMmyB") end}}})
end -- INFORMATION TAB do-scope

print("[DYHUB] "..version.." | "..ver.." loaded successfully! | Target: Animal Hospital")
print("[DYHUB] Config active | Auto saving every "..tostring(settings.AutoSaveDelay).."s")
