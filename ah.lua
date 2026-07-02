-- [[

   UI Kit (WindUI) + Animal Hospital automation system merged.
   Base UI/config/tab framework: original WindUI kit.
   Feature logic (Auto Bed / Analyzer / Heal / Heart Scan / X-Ray / Trash /
   StandIV / Button / Jumpscares / Sanity items / ESP): ported from the
   Rayfield "BELLE.SG | Animal Hospital" script into WindUI components,
   with config load/save wired through the kit's CustomConfig system.

-- ]]
-- =========================
local version = "BETA"
local ver     = "v002.00"
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
    self.ConfigPath = ConfigFolder .. "/AH_config.json"
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

-- ====================== ANIMAL HOSPITAL: STATE ======================
-- Ported from the BELLE.SG Animal Hospital script, restored from Config on load.
local State = {
    AutoBed        = Config:Get("AutoBed", false),
    AutoAnalyzer   = Config:Get("AutoAnalyzer", false),
    AutoHeal       = Config:Get("AutoHeal", false),
    AutoHeartScan  = Config:Get("AutoHeartScan", false),
    AutoXray       = Config:Get("AutoXray", false),
    AutoTrash      = Config:Get("AutoTrash", false),
    AutoCoffee     = Config:Get("AutoCoffee", false),
    AutoMaple      = Config:Get("AutoMaple", false),
    AutoButton     = Config:Get("AutoButton", false),
    AutoStandIV    = Config:Get("AutoStandIV", false),
    AutoJumpscares = Config:Get("AutoJumpscares", false),
    PatientESP     = Config:Get("PatientESP", false),
    AnomalyESP     = Config:Get("AnomalyESP", false),
    ESPRange       = Config:Get("ESPRange", 500),
}

local settings = {
    AutoSaveEnabled = Config:Get("AutoSaveEnabled", true),
    AutoSaveDelay   = Config:Get("AutoSaveDelay", 15),
}

-- ====================== ANIMAL HOSPITAL: HELPERS ======================

local function firePrompt(prompt)
    if not prompt then return end
    if prompt:IsA("ProximityPrompt") then
        fireproximityprompt(prompt)
    elseif prompt:IsA("ClickDetector") then
        fireclickdetector(prompt)
    end
end

local function findPromptByName(name)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == name and (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) then
            return obj
        end
    end
end

local function findAllPromptsByName(name)
    local found = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == name and (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) then
            table.insert(found, obj)
        end
    end
    return found
end

local function getPartPosition(prompt)
    local p = prompt.Parent
    if p and p:IsA("BasePart") then return p.Position end
    if p and p.Parent and p.Parent:IsA("BasePart") then return p.Parent.Position end
    return nil
end

local function distanceTo(pos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return math.huge end
    return (char.HumanoidRootPart.Position - pos).Magnitude
end

local function goTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function loopUntil(stateKey, fn)
    task.spawn(function()
        while State[stateKey] do
            pcall(fn)
            task.wait(1.5)
        end
    end)
end

-- ====================== ANIMAL HOSPITAL: FEATURE FUNCTIONS ======================

local function doAutoBed()
    local prompts = findAllPromptsByName("InBed")
    for _, prompt in ipairs(prompts) do
        if not State.AutoBed then break end
        local pos = getPartPosition(prompt)
        if pos then goTo(pos) end
        task.wait(0.4)
        firePrompt(prompt)
        task.wait(0.5)
    end
end

local function doAutoAnalyzer()
    local analyzer = findPromptByName("Analyzer")
    if analyzer then
        local pos = getPartPosition(analyzer)
        if pos then goTo(pos) end
        task.wait(0.4)
        firePrompt(analyzer)
        task.wait(1)
    end
    local xresult = findPromptByName("xresult")
    if xresult then
        local pos = getPartPosition(xresult)
        if pos then goTo(pos) end
        task.wait(0.4)
        firePrompt(xresult)
        task.wait(0.5)
    end
    local printer = findPromptByName("Printer")
    if printer then
        local pos = getPartPosition(printer)
        if pos then goTo(pos) end
        task.wait(0.4)
        firePrompt(printer)
        task.wait(0.5)
    end
end

local CURE_NAMES = {
    "Thermo", "Bandages", "Ointment", "IV Drops", "Medkit",
    "Medicine", "Cough Syrup", "Herbs", "Eye Drops", "Antibiotics",
    "Organ", "Scissors", "Transplant", "Scalpel", "Spine", "Rocky Acorns"
}

local function doAutoHeal()
    for _, name in ipairs(CURE_NAMES) do
        if not State.AutoHeal then break end
        local prompts = findAllPromptsByName(name)
        for _, prompt in ipairs(prompts) do
            local pos = getPartPosition(prompt)
            if pos then goTo(pos) end
            task.wait(0.3)
            firePrompt(prompt)
            task.wait(0.3)
        end
    end
end

local function doAutoHeartScan()
    local prompt = findPromptByName("HeartMonitor")
    if prompt then
        local pos = getPartPosition(prompt)
        if pos then goTo(pos) end
        task.wait(0.4)
        firePrompt(prompt)
    end
end

local function doAutoXray()
    local xray = findPromptByName("xrayMonitor")
    if xray then
        local pos = getPartPosition(xray)
        if pos then goTo(pos) end
        task.wait(0.4)
        firePrompt(xray)
        task.wait(1)
    end
    local xresult = findPromptByName("xresult")
    if xresult then
        local pos = getPartPosition(xresult)
        if pos then goTo(pos) end
        task.wait(0.4)
        firePrompt(xresult)
    end
end

local function doAutoTrash()
    local prompts = findAllPromptsByName("Trash")
    for _, prompt in ipairs(prompts) do
        if not State.AutoTrash then break end
        local pos = getPartPosition(prompt)
        if pos then goTo(pos) end
        task.wait(0.3)
        firePrompt(prompt)
        task.wait(0.3)
    end
end

local function doAutoCoffee()
    local sanity = LocalPlayer:FindFirstChild("Sanity")
    if sanity and sanity.Value > 60 then return end
    local prompt = findPromptByName("Coffee") or findPromptByName("CoffeePot")
    if prompt then
        local pos = getPartPosition(prompt)
        if pos then goTo(pos) end
        task.wait(0.4)
        firePrompt(prompt)
    end
end

local function doAutoMaple()
    local sanity = LocalPlayer:FindFirstChild("Sanity")
    if sanity and sanity.Value > 60 then return end
    local prompt = findPromptByName("Maple Syrup")
    if prompt then
        local pos = getPartPosition(prompt)
        if pos then goTo(pos) end
        task.wait(0.4)
        firePrompt(prompt)
    end
end

local function doAutoButton()
    local prompts = findAllPromptsByName("Button")
    for _, prompt in ipairs(prompts) do
        if not State.AutoButton then break end
        local pos = getPartPosition(prompt)
        if pos then goTo(pos) end
        task.wait(0.3)
        firePrompt(prompt)
        task.wait(0.3)
    end
end

local function doAutoStandIV()
    local prompts = findAllPromptsByName("StandIV")
    for _, prompt in ipairs(prompts) do
        if not State.AutoStandIV then break end
        local pos = getPartPosition(prompt)
        if pos then goTo(pos) end
        task.wait(0.3)
        firePrompt(prompt)
        task.wait(0.5)
    end
end

local function doAutoJumpscares()
    local prompts = findAllPromptsByName("JumpscareMask")
    for _, prompt in ipairs(prompts) do
        if not State.AutoJumpscares then break end
        local pos = getPartPosition(prompt)
        if pos then goTo(pos) end
        task.wait(0.3)
        firePrompt(prompt)
        task.wait(0.5)
    end
end

-- ====================== ANIMAL HOSPITAL: ANOMALY ESP (Drawing-based) ======================

local ANOMALY_NAMES = {
    "Skinwalker", "Shadow", "Monster", "Ghost",
    "Zombie", "BrokenBabyDoll", "Fire", "Flame"
}

local ESPObjects = {}

local function clearESP()
    for _, label in ipairs(ESPObjects) do
        pcall(function() label:Remove() end)
    end
    ESPObjects = {}
end

local function updateESP()
    clearESP()
    if not State.AnomalyESP then return end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, aName in ipairs(ANOMALY_NAMES) do
                if obj.Name:find(aName) then
                    local dist = distanceTo(obj.Position)
                    if dist <= State.ESPRange then
                        local label = Drawing.new("Text")
                        label.Visible  = true
                        label.Center   = true
                        label.Outline  = true
                        label.Font     = 2
                        label.Size     = 15
                        label.Color    = Color3.fromRGB(255, 50, 50)

                        local screenPos, onScreen = Camera:WorldToViewportPoint(obj.Position)
                        if onScreen then
                            label.Position = Vector2.new(screenPos.X, screenPos.Y)
                            label.Text = obj.Name .. " [" .. math.floor(dist) .. "m]"
                            table.insert(ESPObjects, label)
                        else
                            label:Remove()
                        end
                    end
                    break
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if State.AnomalyESP then
        pcall(updateESP)
    end
end)

-- ====================== ANIMAL HOSPITAL: PATIENT ESP (Drawing-based) ======================

local PatientESPObjects = {}
local PATIENT_NAMES = { "Patient", "NPC", "Animal", "Dog", "Cat", "Bird", "Rabbit", "Hamster" }

local function clearPatientESP()
    for _, label in ipairs(PatientESPObjects) do
        pcall(function() label:Remove() end)
    end
    PatientESPObjects = {}
end

RunService.RenderStepped:Connect(function()
    if not State.PatientESP then
        if #PatientESPObjects > 0 then clearPatientESP() end
        return
    end
    clearPatientESP()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            for _, pName in ipairs(PATIENT_NAMES) do
                if obj.Name:find(pName) then
                    local root = obj:FindFirstChild("HumanoidRootPart")
                        or obj:FindFirstChildOfClass("BasePart")
                    if root then
                        local dist = distanceTo(root.Position)
                        if dist <= State.ESPRange then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                            if onScreen then
                                local label = Drawing.new("Text")
                                label.Visible  = true
                                label.Center   = true
                                label.Outline  = true
                                label.Font     = 2
                                label.Size     = 14
                                label.Color    = Color3.fromRGB(100, 220, 255)
                                label.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                                label.Text     = obj.Name .. " [" .. math.floor(dist) .. "m]"
                                table.insert(PatientESPObjects, label)
                            end
                        end
                    end
                    break
                end
            end
        end
    end
end)

-- ====================== TABS ======================
local InfoTab     = Window:Tab({ Title = "Information", Icon = "info" })
local _D2         = Window:Divider()
local MainTab     = Window:Tab({ Title = "Auto Work",   Icon = "rocket" })
local EspTab      = Window:Tab({ Title = "Esp",         Icon = "eye" })
local PlayerTab   = Window:Tab({ Title = "Safety",      Icon = "user" })
local TeleportTab = Window:Tab({ Title = "Collect",     Icon = "package" })
local _D3         = Window:Divider()
local Main3       = Window:Tab({ Title = "Settings",    Icon = "settings" })

Window:SelectTab(1)

-- ====================== AUTO WORK TAB ======================

MainTab:Divider()
MainTab:Section({ Title = "Auto Work", Icon = "heart-pulse" })

MainTab:Paragraph({
    Title = "Auto Work",
    Desc  = "Automates the core Animal Hospital tasks. All features use real ProximityPrompt names.",
    Image = "rbxassetid://104487529937663", ImageSize = 30,
})

MainTab:Toggle({
    Title    = "Auto Bed",
    Desc     = "Teleports to each patient bed and admits them.",
    Value    = State.AutoBed,
    Callback = function(v)
        State.AutoBed = v
        Config:Set("AutoBed", v); Config:Save()
        if v then loopUntil("AutoBed", doAutoBed) end
        WindUI:Notify({ Title = "Auto Bed", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "toggle-right" or "toggle-left" })
    end
})

MainTab:Toggle({
    Title    = "Auto Analyzer",
    Desc     = "Runs Analyzer -> xresult -> Printer automatically.",
    Value    = State.AutoAnalyzer,
    Callback = function(v)
        State.AutoAnalyzer = v
        Config:Set("AutoAnalyzer", v); Config:Save()
        if v then loopUntil("AutoAnalyzer", doAutoAnalyzer) end
        WindUI:Notify({ Title = "Auto Analyzer", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "toggle-right" or "toggle-left" })
    end
})

MainTab:Toggle({
    Title    = "Auto Heal",
    Desc     = "Fires every cure item prompt (Bandages, Medkit, Antibiotics, etc.).",
    Value    = State.AutoHeal,
    Callback = function(v)
        State.AutoHeal = v
        Config:Set("AutoHeal", v); Config:Save()
        if v then loopUntil("AutoHeal", doAutoHeal) end
        WindUI:Notify({ Title = "Auto Heal", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "toggle-right" or "toggle-left" })
    end
})

MainTab:Toggle({
    Title    = "Auto Heart Scan",
    Desc     = "Fires the HeartMonitor prompt.",
    Value    = State.AutoHeartScan,
    Callback = function(v)
        State.AutoHeartScan = v
        Config:Set("AutoHeartScan", v); Config:Save()
        if v then loopUntil("AutoHeartScan", doAutoHeartScan) end
        WindUI:Notify({ Title = "Auto Heart Scan", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "toggle-right" or "toggle-left" })
    end
})

MainTab:Toggle({
    Title    = "Auto X-Ray",
    Desc     = "Fires xrayMonitor then xresult.",
    Value    = State.AutoXray,
    Callback = function(v)
        State.AutoXray = v
        Config:Set("AutoXray", v); Config:Save()
        if v then loopUntil("AutoXray", doAutoXray) end
        WindUI:Notify({ Title = "Auto X-Ray", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "toggle-right" or "toggle-left" })
    end
})

MainTab:Toggle({
    Title    = "Auto Trash",
    Desc     = "Clears every Trash prompt.",
    Value    = State.AutoTrash,
    Callback = function(v)
        State.AutoTrash = v
        Config:Set("AutoTrash", v); Config:Save()
        if v then loopUntil("AutoTrash", doAutoTrash) end
        WindUI:Notify({ Title = "Auto Trash", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "toggle-right" or "toggle-left" })
    end
})

MainTab:Toggle({
    Title    = "Auto StandIV",
    Desc     = "Fires every StandIV prompt.",
    Value    = State.AutoStandIV,
    Callback = function(v)
        State.AutoStandIV = v
        Config:Set("AutoStandIV", v); Config:Save()
        if v then loopUntil("AutoStandIV", doAutoStandIV) end
        WindUI:Notify({ Title = "Auto StandIV", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "toggle-right" or "toggle-left" })
    end
})

MainTab:Toggle({
    Title    = "Auto Button (Register/Desk)",
    Desc     = "Fires every Button prompt.",
    Value    = State.AutoButton,
    Callback = function(v)
        State.AutoButton = v
        Config:Set("AutoButton", v); Config:Save()
        if v then loopUntil("AutoButton", doAutoButton) end
        WindUI:Notify({ Title = "Auto Button", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "toggle-right" or "toggle-left" })
    end
})

MainTab:Toggle({
    Title    = "Auto Jumpscares",
    Desc     = "Fires JumpscareMask prompts during anomaly events.",
    Value    = State.AutoJumpscares,
    Callback = function(v)
        State.AutoJumpscares = v
        Config:Set("AutoJumpscares", v); Config:Save()
        if v then loopUntil("AutoJumpscares", doAutoJumpscares) end
        WindUI:Notify({ Title = "Auto Jumpscares", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "toggle-right" or "toggle-left" })
    end
})

-- ====================== SAFETY TAB (sanity management) ======================

PlayerTab:Divider()
PlayerTab:Section({ Title = "Sanity", Icon = "shield" })

PlayerTab:Toggle({
    Title    = "Auto Coffee (Sanity)",
    Desc     = "Drinks Coffee/CoffeePot when Sanity drops below 60.",
    Value    = State.AutoCoffee,
    Callback = function(v)
        State.AutoCoffee = v
        Config:Set("AutoCoffee", v); Config:Save()
        if v then loopUntil("AutoCoffee", doAutoCoffee) end
        WindUI:Notify({ Title = "Auto Coffee", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "toggle-right" or "toggle-left" })
    end
})

PlayerTab:Toggle({
    Title    = "Auto Maple Syrup (Sanity)",
    Desc     = "Eats Maple Syrup when Sanity drops below 60.",
    Value    = State.AutoMaple,
    Callback = function(v)
        State.AutoMaple = v
        Config:Set("AutoMaple", v); Config:Save()
        if v then loopUntil("AutoMaple", doAutoMaple) end
        WindUI:Notify({ Title = "Auto Maple Syrup", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "toggle-right" or "toggle-left" })
    end
})

-- ====================== ESP TAB ======================

EspTab:Divider()
EspTab:Section({ Title = "Anomaly ESP", Icon = "triangle-alert" })

EspTab:Toggle({
    Title    = "Anomaly ESP",
    Desc     = "Highlights Skinwalker/Shadow/Monster/Ghost/Zombie/Fire type parts.",
    Value    = State.AnomalyESP,
    Callback = function(v)
        State.AnomalyESP = v
        Config:Set("AnomalyESP", v); Config:Save()
        if not v then clearESP() end
        WindUI:Notify({ Title = "Anomaly ESP", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "eye" or "eye-off" })
    end
})

EspTab:Section({ Title = "Patient ESP", Icon = "eye" })

EspTab:Toggle({
    Title    = "Patient ESP",
    Desc     = "Highlights Patient/NPC/Animal models with distance.",
    Value    = State.PatientESP,
    Callback = function(v)
        State.PatientESP = v
        Config:Set("PatientESP", v); Config:Save()
        if not v then clearPatientESP() end
        WindUI:Notify({ Title = "Patient ESP", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "eye" or "eye-off" })
    end
})

EspTab:Slider({
    Title    = "ESP Range",
    Desc     = "Max distance (studs) for both ESP types.",
    Value    = { Min = 50, Max = 1000, Default = State.ESPRange },
    Step     = 50,
    Callback = function(v)
        State.ESPRange = v
        Config:Set("ESPRange", v); Config:Save()
    end
})

-- info ==================================================================

local Info = InfoTab
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

Info:Section({ Title = "Latest Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({
    Title = "Update: 07/02/2026 | CL: " .. ver,
    Desc  = [[• [ Added ] Animal Hospital automation system (Auto Bed, Analyzer, Heal, Heart Scan, X-Ray, Trash, StandIV, Button, Jumpscares)
• [ Added ] Sanity management (Auto Coffee / Auto Maple Syrup)
• [ Added ] Anomaly ESP + Patient ESP with adjustable range
• [ Fixed ] All toggles now persist through the config system ]],
})
Info:Divider()

-- ====================== SETTINGS TAB ======================
do
Main3:Divider()
Main3:Section({Title="Save Config",Icon="save"})
Main3:Button({Title="Save Config (NOW)", Desc = "Saves all current settings immediately.",Callback=function()
    Config:Save(); WindUI:Notify({Title="Config Saved",Content="Config saved successfully!",Duration=2,Icon="save"})
end})
local AutoSaveEnabled = settings.AutoSaveEnabled
local AutoSaveDelay   = settings.AutoSaveDelay
Main3:Toggle({Title="Auto Save Config", Desc = "Automatically saves config at set interval.",Value=AutoSaveEnabled,Callback=function(state)
    AutoSaveEnabled=state; settings.AutoSaveEnabled=state; Config:Set("AutoSaveEnabled",state); Config:Save()
    if state then Config:AutoSave(AutoSaveDelay) else Config:AutoSave(0) end
end})
Main3:Input({Title="Delay Save Config",Value=tostring(AutoSaveDelay),Placeholder="Default: 15",Callback=function(text)
    local num=tonumber(text)
    if num and num>=1 then
        AutoSaveDelay=num; settings.AutoSaveDelay=num; Config:Set("AutoSaveDelay",num); Config:Save()
        if AutoSaveEnabled then Config:AutoSave(num) end
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

-- ====================== INFORMATION TAB ======================
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

-- ====================== AUTO-RESUME ENABLED LOOPS ON LOAD ======================
-- If a toggle was saved as true from a previous session, kick its loop off now.
if State.AutoBed        then loopUntil("AutoBed", doAutoBed) end
if State.AutoAnalyzer   then loopUntil("AutoAnalyzer", doAutoAnalyzer) end
if State.AutoHeal       then loopUntil("AutoHeal", doAutoHeal) end
if State.AutoHeartScan  then loopUntil("AutoHeartScan", doAutoHeartScan) end
if State.AutoXray       then loopUntil("AutoXray", doAutoXray) end
if State.AutoTrash      then loopUntil("AutoTrash", doAutoTrash) end
if State.AutoStandIV    then loopUntil("AutoStandIV", doAutoStandIV) end
if State.AutoButton     then loopUntil("AutoButton", doAutoButton) end
if State.AutoJumpscares then loopUntil("AutoJumpscares", doAutoJumpscares) end
if State.AutoCoffee     then loopUntil("AutoCoffee", doAutoCoffee) end
if State.AutoMaple      then loopUntil("AutoMaple", doAutoMaple) end

print("[DYHUB] "..version.." | "..ver.." loaded successfully!")
print("[DYHUB] Config active | Auto saving every "..tostring(settings.AutoSaveDelay).."s")
