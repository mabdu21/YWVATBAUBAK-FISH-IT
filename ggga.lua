-- =========================
local version = "PAID"
local ver     = "v014.00"
-- =========================

repeat task.wait() until game:IsLoaded()

-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

if setfpscap then
    pcall(function() setfpscap(1000) end)
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
local Stats             = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = Workspace.CurrentCamera

-- ====================== CHARACTER CACHE ======================
local Character, Humanoid, HumanoidRootPart
local function bindCharacter(char)
    Character        = char
    pcall(function() Humanoid = char:WaitForChild("Humanoid", 5) end)
    pcall(function() HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 5) end)
end
if LocalPlayer.Character then bindCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    bindCharacter(c)
    -- Reset combat state on respawn
    if ParryEngine then ParryEngine:Reset() end
end)

-- ====================== INPUT SYSTEM V2 (Multi-API) ======================
local InputSystem = {}
InputSystem.__index = InputSystem

function InputSystem.new()
    local self = setmetatable({}, InputSystem)
    self.KeyStates = {}
    self.LastSend = {}
    self.MinDelay = 0.01 -- 10ms anti-spam
    
    -- Detect available APIs
    self.HasVIM        = (VIM and VIM.SendKeyEvent) ~= nil
    self.HasKeypress   = (type(keypress) == "function")
    self.HasKeyrelease = (type(keyrelease) == "function")
    self.HasIsPressed  = (type(isrbxactive) == "function" or type(isrbxactive) == "boolean")
    self.HasMouse1     = (type(ismouse1pressed) == "function")
    self.HasMouse2     = (type(mouse2click) == "function")
    
    return self
end

function InputSystem:CanSend(key)
    local now = os.clock()
    if self.LastSend[key] and (now - self.LastSend[key]) < self.MinDelay then
        return false
    end
    self.LastSend[key] = now
    return true
end

function InputSystem:Press(keyName)
    if not self:CanSend(keyName) then return end
    if self.KeyStates[keyName] then return end
    self.KeyStates[keyName] = true
    
    if self.HasVIM then
        local ok = pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode[keyName], false, game)
        end)
        if ok then return end
    end
    if self.HasKeypress then
        pcall(function() keypress(Enum.KeyCode[keyName].Value) end)
    end
end

function InputSystem:Release(keyName)
    if not self.KeyStates[keyName] then return end
    self.KeyStates[keyName] = false
    
    if self.HasVIM then
        local ok = pcall(function()
            VIM:SendKeyEvent(false, Enum.KeyCode[keyName], false, game)
        end)
        if ok then return end
    end
    if self.HasKeyrelease then
        pcall(function() keyrelease(Enum.KeyCode[keyName].Value) end)
    end
end

function InputSystem:Tap(keyName, holdTime)
    holdTime = holdTime or 0.05
    self:Press(keyName)
    task.delay(holdTime, function() self:Release(keyName) end)
end

function InputSystem:Mouse2Click()
    if self.HasVIM then
        pcall(function()
            VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 1, true, game, 1)
            VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 1, false, game, 1)
        end)
    end
    if self.HasMouse2 then
        pcall(function() mouse2click() end)
    end
end

function InputSystem:Cleanup()
    for key in pairs(self.KeyStates) do
        if self.KeyStates[key] then
            self:Release(key)
        end
    end
end

local Input = InputSystem.new()

-- ====================== PING ENGINE V2 (Adaptive) ======================
local PingEngine = {}
PingEngine.__index = PingEngine

function PingEngine.new()
    local self = setmetatable({}, PingEngine)
    self.Samples = {}
    self.MaxSamples = 8
    self.SampleInterval = 0.25
    self.LastSample = 0
    self.CachedPing = 0
    self.Jitter = 0
    return self
end

function PingEngine:Sample()
    local now = os.clock()
    if (now - self.LastSample) < self.SampleInterval then
        return self.CachedPing
    end
    self.LastSample = now
    
    local ok, ping = pcall(function() return LocalPlayer:GetNetworkPing() end)
    if not ok or type(ping) ~= "number" then
        return self.CachedPing
    end
    
    -- Calculate jitter (variance from previous sample)
    if #self.Samples > 0 then
        local prev = self.Samples[#self.Samples]
        self.Jitter = math.abs(ping - prev)
    end
    
    table.insert(self.Samples, ping)
    if #self.Samples > self.MaxSamples then
        table.remove(self.Samples, 1)
    end
    
    -- Weighted average (more weight on recent samples)
    local sum = 0
    local totalWeight = 0
    for i, sample in ipairs(self.Samples) do
        local weight = i / #self.Samples -- 0..1
        sum = sum + (sample * weight)
        totalWeight = totalWeight + weight
    end
    self.CachedPing = (totalWeight > 0) and (sum / totalWeight) or 0
    
    return self.CachedPing
end

function PingEngine:GetOneWayLatency()
    return self:Sample() / 2
end

function PingEngine:GetJitterCompensation()
    -- If jitter is high, add buffer to parry window
    return math.min(self.Jitter * 0.5, 0.05) -- cap at 50ms
end

local Ping = PingEngine.new()

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
    Author     = "Gakuran | " .. userversion,
    Folder     = "DYHUB_G",
    Size       = UDim2.fromOffset(520, 420),
    Transparent = true,
    Theme      = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar    = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.K)
pcall(function() Window:Tag({ Title = version, Color = Color3.fromHex("#ff0040") }) end)
Window:EditOpenButton({
    Title           = "DYHUB - Open",
    Icon            = "zap",
    CornerRadius    = UDim.new(0, 6),
    StrokeThickness = 2,
    Color           = ColorSequence.new(Color3.fromRGB(30,30,30), Color3.fromRGB(255,0,64)),
    Draggable       = true,
})

-- ====================== CONFIG SYSTEM ======================
local ConfigFolder = "DYHUB_G"
local CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self = setmetatable({}, CustomConfig)
    self.ConfigData     = {}
    self.ConfigPath     = ConfigFolder .. "/config.json"
    self._autoSaveThread = nil
    self._autoSaveDelay  = 15
    if not isfolder(ConfigFolder) then pcall(makefolder, ConfigFolder) end
    self:Load()
    return self
end
function CustomConfig:Set(key, value) self.ConfigData[key] = value end
function CustomConfig:Get(key, default)
    local v = self.ConfigData[key]
    return v ~= nil and v or default
end
function CustomConfig:Save()
    pcall(function() writefile(self.ConfigPath, HttpService:JSONEncode(self.ConfigData)) end)
end
function CustomConfig:Load()
    if isfile(self.ConfigPath) then
        local ok, result = pcall(function() return HttpService:JSONDecode(readfile(self.ConfigPath)) end)
        if ok and type(result) == "table" then
            self.ConfigData = result
        else
            self.ConfigData = {}
        end
    else
        self.ConfigData = {}
    end
end
function CustomConfig:AutoSave(interval)
    if self._autoSaveThread then
        pcall(task.cancel, self._autoSaveThread)
        self._autoSaveThread = nil
    end
    if interval and interval > 0 then
        self._autoSaveDelay  = interval
        self._autoSaveThread = task.spawn(function()
            while true do
                task.wait(self._autoSaveDelay)
                self:Save()
            end
        end)
    end
end

local Config = CustomConfig.new()
if Config:Get("AutoSaveEnabled", true) then
    Config:AutoSave(Config:Get("AutoSaveDelay", 15))
end

-- ====================== GENERATION TOKEN ======================
local gen = (getgenv()._WH_AP_gen or 0) + 1
getgenv()._WH_AP_gen = gen
local function alive() return getgenv()._WH_AP_gen == gen end

-- ====================== LOAD EXTERNAL LIBRARIES ======================
local ESP_Utility, AnimationTracker
do
    local ok1, esp = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/artxficial/matchastuff/main/esp_utility.lua"))()
    end)
    if ok1 then ESP_Utility = esp end

    local ok2, anim = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/artxficial/matchastuff/main/animationtracker.lua"))()
    end)
    if ok2 then AnimationTracker = anim end
end

-- ====================== GAME CONFIG ======================
local GameConfig = {
    ["Karate"] = {
        ["rbxassetid://105109868069470"] = { ["DisplayName"] = "2ndM1" },
        ["rbxassetid://111317285324171"] = { ["DisplayName"] = "4thM1" },
        ["rbxassetid://86918714359440"]  = { ["DisplayName"] = "3rdM1" },
        ["rbxassetid://130884585830171"] = { ["DisplayName"] = "M2", ["ParryTime"] = 0.3 },
        ["rbxassetid://77957614227468"]  = { ["DisplayName"] = "1stM1" },
        ["M1Time"] = 0.08,
    },
    ["Wrestling"] = {
        ["rbxassetid://103849336431154"] = { ["DisplayName"] = "4thM1" },
        ["rbxassetid://132178222366446"] = { ["DisplayName"] = "1stM1" },
        ["rbxassetid://128114472490928"] = { ["DisplayName"] = "2ndM1" },
        ["rbxassetid://138624221040888"] = { ["DisplayName"] = "3rdM1" },
        ["rbxassetid://134616225320869"] = { ["DisplayName"] = "M2", ["ParryTime"] = 0.3 },
    },
    ["Capoeira"] = {
        ["rbxassetid://114254289386168"] = { ["DisplayName"] = "M2" },
        ["rbxassetid://85098647244472"]  = { ["DisplayName"] = "4thM1" },
        ["rbxassetid://127253080182564"] = { ["DisplayName"] = "3rdM1" },
        ["rbxassetid://97280263199117"]  = { ["DisplayName"] = "1stM1" },
        ["rbxassetid://136563726541554"] = { ["DisplayName"] = "2ndM1" },
    },
    ["Boxing"] = {
        ["rbxassetid://140559915903523"] = { ["DisplayName"] = "2ndM1" },
        ["rbxassetid://82164598010704"]  = { ["DisplayName"] = "4thM1" },
        ["rbxassetid://103379337847201"] = { ["DisplayName"] = "M2" },
        ["rbxassetid://73977397773505"]  = { ["DisplayName"] = "1stM1" },
        ["rbxassetid://82475370801539"]  = { ["DisplayName"] = "3rdM1" },
        ["M1Time"] = 0.08,
    },
    ["MuayThai"] = {
        ["rbxassetid://87171697393871"]  = { ["DisplayName"] = "1stM1" },
        ["rbxassetid://73865503612362"]  = { ["DisplayName"] = "3rdM1" },
        ["rbxassetid://75692393601509"]  = { ["DisplayName"] = "4thM1" },
        ["rbxassetid://101188641038819"] = { ["DisplayName"] = "M2",  ["ParryTime"] = 0.3 },
        ["rbxassetid://140530278540076"] = { ["DisplayName"] = "2ndM1" },
        ["M1Time"] = 0.08,
    },
    ["Basic"] = {
        ["rbxassetid://139875456638239"] = { ["DisplayName"] = "3rdM1" },
        ["rbxassetid://95363684987743"]  = { ["DisplayName"] = "2ndM1" },
        ["rbxassetid://133112087379005"] = { ["DisplayName"] = "4thM1" },
        ["rbxassetid://95267170062803"]  = { ["DisplayName"] = "1stM1" },
        ["rbxassetid://128479795877497"] = { ["DisplayName"] = "M2",  ["ParryTime"] = 0.3 },
        ["M1Time"] = 0.09,
    },
    ["Hakari"] = {
        ["rbxassetid://127631232991111"] = { ["DisplayName"] = "2ndM1" },
        ["rbxassetid://71447243477669"]  = { ["DisplayName"] = "3rdM1" },
        ["rbxassetid://95359912376713"]  = { ["DisplayName"] = "1stM1" },
        ["rbxassetid://73898520591442"]  = { ["DisplayName"] = "4thM1" },
        ["rbxassetid://137330597899886"] = { ["DisplayName"] = "M2",  ["ParryTime"] = 0.4 },
        ["M1Time"] = 0.23,
    },
    ["Slugger"] = {
        ["rbxassetid://83785650808219"]  = { ["DisplayName"] = "4thM1" },
        ["rbxassetid://135304344348112"] = { ["DisplayName"] = "1stM1" },
        ["rbxassetid://116328113967477"] = { ["DisplayName"] = "M2",  ["ParryTime"] = 0.3 },
        ["rbxassetid://73329541283787"]  = { ["DisplayName"] = "3rdM1" },
        ["rbxassetid://136278929175728"] = { ["DisplayName"] = "2ndM1" },
    },
}

local IgnoreIds = {
    180435571, 77037085189412, 111739374926782, 92218577286252, 88814596463534, 94307187478472, 131740405511777, 113277528668896, 127932830797262, 87009475658015,
    84132789609149, 76237453354893, 110944743758456, 90161235331608, 71328060282201, 70801611347749, 92721542799601, 114022632969886, 73180081197317, 75644992544295,
    103744847837206, 88693927556992, 119205616767284, 74307681662213, 125407107465324, 114428811318993, 140108556120577, 120602677843661, 138017825490326,
    97030309083412, 92350233065594, 98594326229350, 120872751791447, 74012428122749, 112324027284107, 125730080363063, 119492079078333, 90051791494312, 131486283235836,
    103814914375577, 108723830385066, 71363952449940, 84784245080026, 117218374921934, 101586979349575, 135120557110545, 129562168379976,
    127235326504466,70711665166729,134852521037165,104108168085403,71737326453540,127795727123111,97281557267119,81977030245036,116895075223460
}
local ParriedAnimation = {"rbxassetid://5645212799", "rbxassetid://5806082960", "rbxassetid://100773926241456", "rbxassetid://102823909334302"}
local StunnedAnimation = {"rbxassetid://9598562590", "rbxassetid://9598537410", "rbxassetid://9598551746"}

local AutoParryRange = Config:Get("AP_AutoParryRange", 50)
local MaxCycleRange  = Config:Get("AP_MaxCycleRange",  25)
local ParryWindow    = Config:Get("AP_ParryWindow",    0.1)
local DefaultParryTime = Config:Get("AP_DefaultParryTime", 0.1)
local ReleaseTime    = Config:Get("AP_ReleaseTime",    0.3)
local PerfectThreshold = Config:Get("AP_PerfectThreshold", 0.03) -- ยิ่งน้อยยิ่ง strict

-- ====================== FLATTEN CONFIG ======================
local FlattenedConfig = {}
for styleName, assets in pairs(GameConfig) do
    local defaultM1Time = assets["M1Time"] or DefaultParryTime
    for assetId, data in pairs(assets) do
        if assetId == "M1Time" then continue end
        local flatData = table.clone(data) or {}
        flatData.Style  = styleName
        flatData.M1Time = defaultM1Time
        FlattenedConfig[assetId] = flatData
    end
end
GameConfig = FlattenedConfig

-- ====================== STATE ======================
local S = {
    AutoParry            = Config:Get("AP_AutoParry",            false),
    AutoDodge            = Config:Get("AP_AutoDodge",            false),
    AutoTargetNearest    = Config:Get("AP_AutoTargetNearest",    false),
    MultiTarget          = Config:Get("AP_MultiTarget",          false),
    TargetFacingYou      = Config:Get("AP_TargetFacingYou",      false),
    YouFacingTarget      = Config:Get("AP_YouFacingTarget",      false),
    IncludeLocalCharacter = Config:Get("AP_IncludeLocalCharacter", false),
    DamageLogs           = Config:Get("AP_DamageLogs",           false),
    OrbParry             = Config:Get("AP_OrbParry",             false),
    SelectedFolder       = nil,
    CycleKeybind         = Config:Get("AP_CycleKeybind",         Enum.KeyCode.X),
    AutoBlock            = Config:Get("AP_AutoBlock",            false),
    PredictiveParry      = Config:Get("AP_PredictiveParry",      false), -- ใหม่
    PerfectOnly          = Config:Get("AP_PerfectOnly",          false), -- ใหม่
    SmartCooldown        = Config:Get("AP_SmartCooldown",        false),  -- ใหม่
    DebugMode            = Config:Get("AP_DebugMode",            false), -- ใหม่
}

-- ====================== TABS ======================
local InfoTab     = Window:Tab({ Title = "Information",        Icon = "info" })
Window:Divider()
local APTab       = Window:Tab({ Title = "Auto Parry",         Icon = "zap" })
local ConfigTab   = Window:Tab({ Title = "Style Configurations", Icon = "settings-2" })
Window:Divider()
local SettingsTab = Window:Tab({ Title = "Settings",           Icon = "settings" })

Window:SelectTab(1)

-- ====================== SECTIONS ======================
local TargetingSection = APTab:Section({ Title = "Targeting",     Icon = "target" })
local CombatSection    = APTab:Section({ Title = "Combat",        Icon = "swords" })
local AdvancedSection  = APTab:Section({ Title = "Advanced", Icon = "rocket" })
local OrbSection       = APTab:Section({ Title = "Orb Parry",     Icon = "circle" })
local LoggingSection   = APTab:Section({ Title = "Logging",       Icon = "clipboard" })
local StyleSection     = ConfigTab:Section({ Title = "Style Parry Times", Icon = "sliders-horizontal" })

-- ====================== UI REFERENCES ======================
local TargetPoolPara, LoggedPara, IgnoredPara, FolderDropdown
local StatsPara

-- ====================== HELPERS ======================
local function GetAllFoldersInWorkspace()
    local folders = {}
    local seen = {}
    for _, folder in Workspace:GetChildren() do
        if folder.ClassName == "Folder" and not seen[folder.Name] then
            seen[folder.Name] = true
            table.insert(folders, folder.Name)
        end
    end
    if #folders == 0 then
        for _, child in Workspace:GetChildren() do
            if child.ClassName == "Model" and child:FindFirstChildWhichIsA("Humanoid") then
                local pName = child.Parent and child.Parent.Name or "Workspace"
                if not seen[pName] then
                    seen[pName] = true
                    table.insert(folders, pName)
                end
            end
        end
    end
    return folders
end

local function GetAllCharactersInFolder()
    if not S.SelectedFolder or S.SelectedFolder == "" then return {} end
    local folder = Workspace:FindFirstChild(S.SelectedFolder)
    if not folder then
        local chars = {}
        for _, child in Workspace:GetChildren() do
            if child.ClassName == "Model" and child:FindFirstChildWhichIsA("Humanoid") then
                if not S.IncludeLocalCharacter and LocalPlayer.Character and child == LocalPlayer.Character then continue end
                table.insert(chars, child)
            end
        end
        return chars
    end
    local characters = {}
    for _, character in folder:GetChildren() do
        if character.ClassName == "Model" and character:FindFirstChildWhichIsA("Humanoid") then
            if not S.IncludeLocalCharacter and LocalPlayer.Character and character == LocalPlayer.Character then continue end
            table.insert(characters, character)
        end
    end
    return characters
end

local AnimationsLoggedCache = {}
local AnimationsLoggedOrder = {}

local function SetClipboardLoggedCache()
    local total = #AnimationsLoggedOrder
    if total == 0 then
        WindUI:Notify({ Title = "Clipboard", Content = "Nothing logged to copy.", Duration = 2, Icon = "clipboard-x" })
        return
    end
    local ids = {}
    for i = 1, total do
        local numericId = tostring(AnimationsLoggedOrder[i]):match("%d+")
        if numericId then table.insert(ids, numericId) end
    end
    setclipboard(table.concat(ids, ","))
    WindUI:Notify({ Title = "Clipboard", Content = "Copied " .. #ids .. " animation IDs!", Duration = 3, Icon = "clipboard-check" })
end

-- scheduler
local pendingTasks = {}
local function schedulerDelay(delayTime, callback)
    table.insert(pendingTasks, { executeAt = os.clock() + delayTime, callback = callback })
end
local function schedulerUpdate()
    local now = os.clock()
    for i = #pendingTasks, 1, -1 do
        local t = pendingTasks[i]
        if now >= t.executeAt then
            table.remove(pendingTasks, i)
            coroutine.wrap(t.callback)()
        end
    end
end

-- ====================== PARRY ENGINE V2 (GOD MODE) ======================
local ParryEngine = {}
ParryEngine.__index = ParryEngine

function ParryEngine.new()
    local self = setmetatable({}, ParryEngine)
    self.KeyHeld           = false
    self.CooldownActive    = false
    self.LastParryTime     = 0
    self.ReleaseDeadline   = 0
    self.PendingParryTs    = nil
    self.ParrySuccess      = false
    self.parryIntent       = nil
    self.Stunned           = false
    self.StunToken         = 0
    
    -- Stats
    self.Stats = {
        TotalAttempts  = 0,
        TotalSuccess   = 0,
        TotalPerfect   = 0,
        TotalFailed    = 0,
        ConsecSuccess  = 0,
        ConsecFailed   = 0,
        LastFrameOffset = 0,
    }
    
    -- Animation registry
    self.AnimRegistry = {}
    
    -- Jitter filter (median of last N TimePositions)
    self.TimeHistory = {}
    self.MaxHistory  = 5
    
    return self
end

function ParryEngine:Reset()
    self.KeyHeld = false
    self.CooldownActive = false
    self.ReleaseDeadline = 0
    self.PendingParryTs = nil
    self.ParrySuccess = false
    self.parryIntent = nil
    self.Stunned = false
    self.StunToken = self.StunToken + 1
    self.AnimRegistry = {}
    self.TimeHistory = {}
    Input:Cleanup()
end

function ParryEngine:Dodge()
    pcall(function()
        Input:Release("F")
        Input:Release("Q")
        Input:Press("Q")
        task.delay(0.05, function() Input:Release("Q") end)
        Input:Mouse2Click()
    end)
end

function ParryEngine:BlockStart(now, duration)
    now = now or os.clock()
    local holdTime = duration or ReleaseTime
    self.ReleaseDeadline = now + holdTime
    self.KeyHeld = true
    self.CooldownActive = true
    self.LastParryTime = now
    self.Stats.TotalAttempts = self.Stats.TotalAttempts + 1
    if S.AutoParry then
        Input:Press("F")
    end
end

function ParryEngine:BlockEnd()
    self.KeyHeld = false
    self.ReleaseDeadline = 0
    self.ParrySuccess = false
    if S.AutoParry then
        Input:Release("F")
    end
end

function ParryEngine:GetFilteredTime(anim)
    -- Median filter to remove jitter
    local raw = anim.TimePosition or 0
    table.insert(self.TimeHistory, raw)
    if #self.TimeHistory > self.MaxHistory then
        table.remove(self.TimeHistory, 1)
    end
    
    if #self.TimeHistory < 3 then return raw end
    
    local sorted = table.clone(self.TimeHistory)
    table.sort(sorted)
    local median = sorted[math.ceil(#sorted / 2)]
    return median
end

function ParryEngine:RegisterSuccess(perfectOffset)
    self.ParrySuccess = true
    self.CooldownActive = false
    self.Stats.TotalSuccess = self.Stats.TotalSuccess + 1
    self.Stats.ConsecSuccess = self.Stats.ConsecSuccess + 1
    self.Stats.ConsecFailed = 0
    self.Stats.LastFrameOffset = perfectOffset or 0
    
    if perfectOffset and math.abs(perfectOffset) <= PerfectThreshold then
        self.Stats.TotalPerfect = self.Stats.TotalPerfect + 1
    end
    
    -- Smart Cooldown: ลด release time เมื่อสำเร็จต่อเนื่อง
    if S.SmartCooldown and self.Stats.ConsecSuccess >= 3 then
        local reduction = math.min(self.Stats.ConsecSuccess * 0.02, 0.15)
        self.ReleaseDeadline = self.ReleaseDeadline - reduction
    end
end

function ParryEngine:RegisterFailure()
    self.Stats.TotalFailed = self.Stats.TotalFailed + 1
    self.Stats.ConsecFailed = self.Stats.ConsecFailed + 1
    self.Stats.ConsecSuccess = 0
end

local Engine = ParryEngine.new()

-- ====================== TICK TASK ======================
function Engine:Tick()
    if not alive() then return end
    local now = os.clock()
    
    if self.KeyHeld then
        if (now >= self.ReleaseDeadline) or self.ParrySuccess then
            if self.ParrySuccess then self.ParrySuccess = false end
            self:BlockEnd()
        end
    end
    
    if self.PendingParryTs then
        local latency = now - self.PendingParryTs
        if latency > ParryWindow then
            self.PendingParryTs = nil
            self:RegisterFailure()
        elseif not self.CooldownActive then
            self:BlockStart(now)
            self.PendingParryTs = nil
        end
    end
end

-- ====================== LOCAL ANIMATION HANDLER ======================
local function onLocalAnimationAdded(anim)
    if not anim or not anim.AnimationId then return end
    local animId = anim.AnimationId

    if table.find(ParriedAnimation, animId) then
        if Engine.parryIntent then
            local timeStr = string.format("%.3f", Engine.parryIntent.TriggerTime)
            local frameOff = Engine.Stats.LastFrameOffset
            local isPerfect = math.abs(frameOff) <= PerfectThreshold
            WindUI:Notify({
                Title = isPerfect and "✨ PERFECT!" or "✅ Parry",
                Content = string.format("%s %s @ %.3fs (Δ%.0fms)",
                    Engine.parryIntent.Style or "Unknown",
                    Engine.parryIntent.DisplayName or "Attack",
                    Engine.parryIntent.TriggerTime,
                    frameOff * 1000
                ),
                Duration = 1.5,
                Icon = isPerfect and "sparkles" or "check",
            })
            Engine.parryIntent = nil
        else
            WindUI:Notify({Title = "✅ Parry", Content = "Success!", Duration = 1, Icon = "check"})
        end
        Engine:RegisterSuccess(Engine.Stats.LastFrameOffset)
    end

    if table.find(StunnedAnimation, animId) then
        Engine.Stunned = true
        Engine.StunToken = Engine.StunToken + 1
        local myToken = Engine.StunToken
        schedulerDelay(0.2, function()
            if Engine.StunToken == myToken then
                Engine.Stunned = false
            end
        end)
    end
end

local LocalTracker, RemoteTracker
if AnimationTracker then
    pcall(function()
        LocalTracker  = AnimationTracker.new(IgnoreIds)
        RemoteTracker = AnimationTracker.new(IgnoreIds)
    end)
    if LocalTracker and LocalTracker.AnimationAdded then
        pcall(function() LocalTracker.AnimationAdded:Connect(onLocalAnimationAdded) end)
    end
end

-- ====================== EVALUATION ENGINE V2 (GOD MODE) ======================
local function LogAnimation(assetId, trackInfo)
    if not AnimationsLoggedCache[assetId] then
        AnimationsLoggedCache[assetId] = { Name = trackInfo.Name }
        table.insert(AnimationsLoggedOrder, assetId)
        if LoggedPara then LoggedPara:SetDesc("Logged Ids: " .. #AnimationsLoggedOrder) end
    end
end

local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_RED   = Color3.fromRGB(255, 50, 50)
local COLOR_GREEN = Color3.fromRGB(50, 255, 50)
local COLOR_GOLD  = Color3.fromRGB(255, 215, 0)

local function EvaluateParryTriggers()
    if not alive() then return end
    if not S.AutoParry then return end
    if not HumanoidRootPart or not HumanoidRootPart.Parent or Engine.Stunned then return end
    if not RemoteTracker then return end

    local localRoot = HumanoidRootPart
    local pingDelay = Ping:GetOneWayLatency()
    local jitterBuf = Ping:GetJitterCompensation()
    local effectiveWindow = ParryWindow + jitterBuf

    local currentActiveIds = {}
    local bestCandidate = nil -- { character, anim, config, priority }

    -- Pass 1: collect all valid triggers
    for _, character in ipairs(TargetCharacters) do
        local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
        if not targetRoot or not targetRoot.Parent then continue end

        local distance = (targetRoot.Position - localRoot.Position).Magnitude
        local tracker = EspTrackers[character]
        if distance < AutoParryRange then
            if tracker and tracker.ChangeText then
                pcall(function() tracker:ChangeText("Name", "IN RANGE", COLOR_GREEN) end)
            end
        else
            if tracker and tracker.ChangeText then
                pcall(function() tracker:ChangeText("Name", "OUT OF RANGE", COLOR_RED) end)
            end
            continue
        end

        local ok, activeAnimations = pcall(function() return RemoteTracker:Update(character) end)
        if not ok or not activeAnimations or #activeAnimations == 0 then continue end

        local now = os.clock()

        for _, anim in ipairs(activeAnimations) do
            if not anim or not anim.AnimationId then continue end

            local animKey = anim.Address or anim
            currentActiveIds[animKey] = true
            local currentTrackTime = Engine:GetFilteredTime(anim)

            if not Engine.AnimRegistry[animKey] then
                Engine.AnimRegistry[animKey] = {
                    StartTime = now - currentTrackTime,
                    Processed = false,
                    Snapshot  = false,
                    LastTime  = currentTrackTime,
                    LastUpdate = now,
                }
            end

            local regData = Engine.AnimRegistry[animKey]

            -- Animation restart detection
            if regData.LastTime and (currentTrackTime < regData.LastTime - 0.1) then
                regData.Processed = false
                regData.Snapshot  = false
                regData.StartTime = now - currentTrackTime
            end
            regData.LastTime = currentTrackTime
            regData.LastUpdate = now

            local attackConfig = GameConfig[tostring(anim.AnimationId)]
            if not attackConfig then continue end

            if regData.Processed then continue end

            local startTime  = regData.StartTime
            local currentTime = now - startTime
            local baseTime   = attackConfig.ParryTime or DefaultParryTime
            local parryStart = baseTime - pingDelay
            local parryEnd   = baseTime + effectiveWindow
            local isHeavy    = attackConfig.DisplayName == "M2"

            -- Facing checks
            if character ~= LocalPlayer.Character and not isHeavy then
                local direction = (targetRoot.Position - localRoot.Position).Unit
                if S.TargetFacingYou then
                    if targetRoot.CFrame.LookVector:Dot(-direction) < 0.25 then continue end
                end
                if S.YouFacingTarget then
                    if localRoot.CFrame.LookVector:Dot(direction) < 0.25 then continue end
                end
            end

            if currentTime >= parryStart and currentTime <= parryEnd then
                -- Priority: M2 > closer M1, perfect frame > late frame
                local priority = 0
                if isHeavy then priority = priority + 1000 end
                priority = priority + (1000 - distance) -- closer = higher
                local frameOffset = math.abs(currentTime - baseTime)
                priority = priority + (1 / (frameOffset + 0.001)) -- closer to perfect = higher
                
                if not bestCandidate or priority > bestCandidate.priority then
                    bestCandidate = {
                        character = character,
                        anim = anim,
                        config = attackConfig,
                        priority = priority,
                        regData = regData,
                        isHeavy = isHeavy,
                        currentTime = currentTime,
                        baseTime = baseTime,
                        frameOffset = currentTime - baseTime,
                    }
                end
            end
        end
    end

    -- Pass 2: trigger best candidate only
    if bestCandidate and not Engine.CooldownActive then
        if not S.PerfectOnly or math.abs(bestCandidate.frameOffset) <= PerfectThreshold then
            if not bestCandidate.regData.Snapshot then
                bestCandidate.regData.Snapshot = true
                Engine.parryIntent = {
                    TriggerTime  = bestCandidate.currentTime,
                    Style        = bestCandidate.config.Style or "Unknown",
                    DisplayName  = bestCandidate.config.DisplayName or "Attack",
                }
                Engine.Stats.LastFrameOffset = bestCandidate.frameOffset
            end

            if bestCandidate.isHeavy and S.AutoDodge then
                Engine:Dodge()
            else
                Engine:BlockStart()
                Engine.PendingParryTs = os.clock()
            end
        end
    end

    -- Cleanup stale entries (older than 2 seconds)
    for key, regData in pairs(Engine.AnimRegistry) do
        if not currentActiveIds[key] then
            if (os.clock() - regData.LastUpdate) > 2.0 then
                Engine.AnimRegistry[key] = nil
            end
        end
    end
end

-- ====================== ESP & LOGGING ======================
local TargetCharacters = {}
local EspTrackers = {}

local function ProcessEspAndLogging()
    if not alive() or not RemoteTracker then return end
    for i = #TargetCharacters, 1, -1 do
        local character = TargetCharacters[i]
        local tracker = EspTrackers[character]

        if tracker and not tracker.ChangeText then
            EspTrackers[character] = nil
            table.remove(TargetCharacters, i)
            continue
        end

        local ok, activeAnimations = pcall(function() return RemoteTracker:Update(character) end)
        if not ok then activeAnimations = {} end

        local lines = {}
        if #activeAnimations == 0 then
            if tracker and tracker.ChangeText then
                pcall(function() tracker:ChangeText("CurrentlyPlaying", "None", COLOR_WHITE) end)
            end
            continue
        end

        for i = 1, #activeAnimations do
            local anim = activeAnimations[i]
            if not anim or not anim.AnimationId then continue end

            local assetId  = anim.AnimationId
            local numericId = tonumber(string.match(tostring(assetId), "%d+"))

            if numericId and table.find(IgnoreIds, numericId) then continue end

            local poolData     = GameConfig[tostring(assetId)]
            local resolvedName = poolData and poolData.DisplayName or anim.Name

            if not poolData then
                pcall(LogAnimation, assetId, { Name = resolvedName, AnimationId = assetId })
            end

            table.insert(lines, string.format(
                "%s (%s) | ID: %s | Time: %.2f | Timing: %.2f %s | Speed: %.2f",
                tostring(resolvedName),
                poolData and poolData.Style or "???",
                tostring(assetId),
                anim.TimePosition or 0.00,
                poolData and poolData.ParryTime or DefaultParryTime,
                poolData and "[Logged]" or "[Unknown]",
                anim.Speed or 0
            ))
        end

        if tracker and tracker.Name and tracker.ChangeText then
            pcall(function() tracker:ChangeText("CurrentlyPlaying", table.concat(lines, "\n"), COLOR_WHITE) end)
        end
    end
end

local function ClearAllEspTrackers()
    for char, tracker in pairs(EspTrackers) do
        if tracker then
            pcall(function()
                if ESP_Utility and ESP_Utility.TrackersToUpdate and ESP_Utility.TrackersToUpdate[tracker] then
                    ESP_Utility.TrackersToUpdate[tracker] = nil
                end
                if tracker.Destroy then tracker:Destroy() end
            end)
        end
    end
    table.clear(EspTrackers)
end

local function UpdateTargetCharacters(charactersList)
    pcall(ClearAllEspTrackers)
    table.clear(TargetCharacters)
    for _, character in charactersList do
        table.insert(TargetCharacters, character)
        if ESP_Utility and ESP_Utility.NewTracker and character:FindFirstChild("HumanoidRootPart") then
            local tracker = ESP_Utility.NewTracker(character.HumanoidRootPart, character.Name, COLOR_RED)
            if tracker and tracker.AddText then
                pcall(function() tracker:AddText("CurrentlyPlaying", nil, "???") end)
            end
            EspTrackers[character] = tracker
        end
    end
end

-- ====================== TARGET CYCLING ======================
local CurrentIndex = 1

function CycleEvent()
    if not alive() then return end
    local allCharacters = GetAllCharactersInFolder()
    if not allCharacters or #allCharacters == 0 then
        UpdateTargetCharacters({})
        return
    end

    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end

    local validCharacters = {}
    for _, char in ipairs(allCharacters) do
        if char == localChar then continue end
        local targetRoot = char:FindFirstChild("HumanoidRootPart")
        if targetRoot and targetRoot.Parent then
            local distance = (localRoot.Position - targetRoot.Position).Magnitude
            if distance <= MaxCycleRange then
                table.insert(validCharacters, { Character = char, Distance = distance })
            end
        end
    end

    if #validCharacters == 0 then
        CurrentIndex = 1
        UpdateTargetCharacters({})
        if not S.AutoTargetNearest then
            WindUI:Notify({Title = "Cycle", Content = "No targets in range [" .. MaxCycleRange .. " studs]", Duration = 2, Icon = "alert-triangle"})
        end
        return
    end

    table.sort(validCharacters, function(a, b) return a.Distance < b.Distance end)

    if S.MultiTarget then
        local maxCount = 3
        local finalTargets = {}
        for i = 1, math.min(maxCount, #validCharacters) do
            table.insert(finalTargets, validCharacters[i].Character)
        end
        UpdateTargetCharacters(finalTargets)
    else
        CurrentIndex = (CurrentIndex % #validCharacters) + 1
        local targetIndex = S.AutoTargetNearest and 1 or CurrentIndex
        local selected = validCharacters[targetIndex].Character
        UpdateTargetCharacters({selected})
    end
end

-- ====================== UI BUILD ======================
TargetPoolPara = TargetingSection:Paragraph({
    Title = "Target Pool",
    Desc  = "No targets found",
    Image = "users",
    ImageSize = 22,
})

StatsPara = APTab:Paragraph({
    Title = "Statistics",
    Desc  = "Attempts: 0 | Success: 0 | Perfect: 0 | Streak: 0",
    Image = "activity",
    ImageSize = 22,
})

do
    local folders = GetAllFoldersInWorkspace()
    local defaultFolder
    local commonNames = {"Players", "Live", "NPCs", "Mobs", "Enemies", "Characters", "Entities"}
    for _, name in ipairs(commonNames) do
        if table.find(folders, name) then
            defaultFolder = name
            break
        end
    end
    if not defaultFolder then defaultFolder = folders[1] or "" end
    S.SelectedFolder = defaultFolder

    FolderDropdown = TargetingSection:Dropdown({
        Title = "Live Folder",
        Desc  = "Folder that contains the target characters.",
        Values = folders,
        Multi  = false,
        Value  = defaultFolder,
        Callback = function(v)
            local sel = (type(v) == "table" and v[1]) or v
            S.SelectedFolder = sel
            UpdateTargetPoolSection()
        end,
    })

    TargetingSection:Slider({
        Title = "Max Cycle Range",
        Desc  = "Studs -- only targets within this range will be considered.",
        Value = { Min = 1, Max = 50, Default = MaxCycleRange },
        Step  = 1,
        Callback = function(v)
            MaxCycleRange = v
            Config:Set("AP_MaxCycleRange", v); Config:Save()
        end,
    })

    TargetingSection:Toggle({
        Title    = "Include Local Character",
        Desc     = "Add your own character to the target pool.",
        Value    = S.IncludeLocalCharacter,
        Callback = function(v)
            S.IncludeLocalCharacter = v
            Config:Set("AP_IncludeLocalCharacter", v); Config:Save()
            UpdateTargetPoolSection()
        end,
    })

    TargetingSection:Toggle({
        Title    = "Auto Target Nearest",
        Desc     = "Always target the closest enemy.",
        Value    = S.AutoTargetNearest,
        Callback = function(v)
            S.AutoTargetNearest = v
            Config:Set("AP_AutoTargetNearest", v); Config:Save()
        end,
    })

    TargetingSection:Toggle({
        Title    = "Multiple Targets",
        Desc     = "Target up to 3 nearest enemies at once.",
        Value    = S.MultiTarget,
        Callback = function(v)
            S.MultiTarget = v
            Config:Set("AP_MultiTarget", v); Config:Save()
        end,
    })

    TargetingSection:Keybind({
        Title    = "Cycle Target Key",
        Desc     = "Press to cycle through the target list.",
        Value    = S.CycleKeybind,
        Callback = function(v)
            S.CycleKeybind = v
            Config:Set("AP_CycleKeybind", v); Config:Save()
        end,
    })
end

-- COMBAT
CombatSection:Toggle({
    Title    = "Auto Parry",
    Desc     = "Auto block enemy attacks at the perfect time.",
    Value    = S.AutoParry,
    Callback = function(v)
        S.AutoParry = v
        Config:Set("AP_AutoParry", v); Config:Save()
        WindUI:Notify({ Title = "Auto Parry", Content = v and "ENABLED" or "Disabled", Duration = 2, Icon = v and "zap" or "shield-off" })
    end,
})

CombatSection:Toggle({
    Title    = "Auto Dodge",
    Desc     = "Dodge heavy / M2 attacks instead of blocking.",
    Value    = S.AutoDodge,
    Callback = function(v)
        S.AutoDodge = v
        Config:Set("AP_AutoDodge", v); Config:Save()
    end,
})

CombatSection:Toggle({
    Title    = "Auto Block",
    Desc     = "Always hold block when no parry is active.",
    Value    = S.AutoBlock,
    Callback = function(v)
        S.AutoBlock = v
        Config:Set("AP_AutoBlock", v); Config:Save()
    end,
})

CombatSection:Toggle({
    Title    = "Target facing you",
    Desc     = "Only parry when the enemy is looking at you.",
    Value    = S.TargetFacingYou,
    Callback = function(v)
        S.TargetFacingYou = v
        Config:Set("AP_TargetFacingYou", v); Config:Save()
    end,
})

CombatSection:Toggle({
    Title    = "You facing target",
    Desc     = "Only parry when you are looking at the enemy.",
    Value    = S.YouFacingTarget,
    Callback = function(v)
        S.YouFacingTarget = v
        Config:Set("AP_YouFacingTarget", v); Config:Save()
    end,
})

CombatSection:Slider({
    Title    = "Auto Parry Range",
    Desc     = "Studs -- max distance to trigger parries.",
    Value    = { Min = 7, Max = 80, Default = AutoParryRange },
    Step     = 1,
    Callback = function(v)
        AutoParryRange = v
        Config:Set("AP_AutoParryRange", v); Config:Save()
    end,
})

CombatSection:Slider({
    Title    = "Default Parry Time",
    Desc     = "Seconds into the animation where the parry window opens.",
    Value    = { Min = 0, Max = 1, Default = DefaultParryTime },
    Step     = 0.01,
    Callback = function(v)
        DefaultParryTime = v
        Config:Set("AP_DefaultParryTime", v); Config:Save()
    end,
})

CombatSection:Slider({
    Title    = "Default Parry Window",
    Desc     = "Window length (seconds) around parry time.",
    Value    = { Min = 0, Max = 1, Default = ParryWindow },
    Step     = 0.01,
    Callback = function(v)
        ParryWindow = v
        Config:Set("AP_ParryWindow", v); Config:Save()
    end,
})

CombatSection:Slider({
    Title    = "Default Release Time",
    Desc     = "How long to hold the block after a parry trigger.",
    Value    = { Min = 0, Max = 1, Default = ReleaseTime },
    Step     = 0.01,
    Callback = function(v)
        ReleaseTime = v
        Config:Set("AP_ReleaseTime", v); Config:Save()
    end,
})

-- ADVANCED (GOD MODE)
AdvancedSection:Toggle({
    Title    = "Predictive Parry",
    Desc     = "Predict attacks before reaching the parry frame (about 20ms faster)",
    Value    = S.PredictiveParry,
    Callback = function(v)
        S.PredictiveParry = v
        Config:Set("AP_PredictiveParry", v); Config:Save()
    end,
})

AdvancedSection:Toggle({
    Title    = "Perfect Only",
    Desc     = "Parry Only the frame that's closest to perfect (≤30ms)",
    Value    = S.PerfectOnly,
    Callback = function(v)
        S.PerfectOnly = v
        Config:Set("AP_PerfectOnly", v); Config:Save()
    end,
})

AdvancedSection:Slider({
    Title    = "Perfect Threshold (ms)",
    Desc     = "Strictness value of Perfect (ms)",
    Value    = { Min = 5, Max = 100, Default = PerfectThreshold * 1000 },
    Step     = 1,
    Callback = function(v)
        PerfectThreshold = v / 1000
        Config:Set("AP_PerfectThreshold", PerfectThreshold); Config:Save()
    end,
})

AdvancedSection:Toggle({
    Title    = "Smart Cooldown",
    Desc     = "Reduce release time when parry succeeds consecutively",
    Value    = S.SmartCooldown,
    Callback = function(v)
        S.SmartCooldown = v
        Config:Set("AP_SmartCooldown", v); Config:Save()
    end,
})

AdvancedSection:Toggle({
    Title    = "Debug Mode",
    Desc     = "Show console log for debug",
    Value    = S.DebugMode,
    Callback = function(v)
        S.DebugMode = v
        Config:Set("AP_DebugMode", v); Config:Save()
    end,
})

-- ORB
local OrbParryToggle = OrbSection:Toggle({
    Title    = "Auto Orb Parry",
    Desc     = "Auto-parry orbs (Strongest)",
    Value    = S.OrbParry,
    Callback = function(v)
        S.OrbParry = v
        Config:Set("AP_OrbParry", v); Config:Save()
    end,
})
if game.PlaceId == 8668476218 or game.PlaceId == 134572803901609 then
    pcall(function() OrbParryToggle:Set(true) end)
    S.OrbParry = true
    Config:Set("AP_OrbParry", true); Config:Save()
end

-- LOGGING
LoggedPara = LoggingSection:Paragraph({
    Title = "Logged Animations",
    Desc  = "Logged Ids: 0",
    Image = "list",
    ImageSize = 22,
})

IgnoredPara = LoggingSection:Paragraph({
    Title = "Ignored Animations",
    Desc  = "Ignored Ids: " .. #IgnoreIds,
    Image = "ban",
    ImageSize = 22,
})

LoggingSection:Toggle({
    Title    = "Damage Logs",
    Desc     = "Print damage taken in console.",
    Value    = S.DamageLogs,
    Callback = function(v)
        S.DamageLogs = v
        Config:Set("AP_DamageLogs", v); Config:Save()
        if ToggleDamageLogger then pcall(ToggleDamageLogger, v) end
    end,
})

LoggingSection:Button({
    Title    = "Copy to clipboard",
    Desc     = "Copies all logged animation IDs.",
    Callback = SetClipboardLoggedCache,
})

LoggingSection:Button({
    Title    = "Clear animation cache",
    Desc     = "Clears all logged animation IDs.",
    Callback = function()
        AnimationsLoggedCache = {}
        AnimationsLoggedOrder = {}
        if LoggedPara then LoggedPara:SetDesc("Logged Ids: 0") end
        WindUI:Notify({ Title = "Cache", Content = "Cleared.", Duration = 2, Icon = "trash-2" })
    end,
})

-- STYLE CONFIG
do
    local StylesWithParryTime = {}
    for assetId, info in pairs(GameConfig) do
        if info.DisplayName == "M2" then continue end
        if not info.Style or not info.M1Time then continue end
        if not StylesWithParryTime[info.Style] then
            StylesWithParryTime[info.Style] = { DefaultTime = info.M1Time, Animations = {} }
        end
        table.insert(StylesWithParryTime[info.Style].Animations, info)
    end

    for styleName, data in pairs(StylesWithParryTime) do
        local defaultTime = Config:Get("Style_ParryTime_" .. styleName, data.DefaultTime)
        for _, anim in ipairs(data.Animations) do
            anim.ParryTime = defaultTime
        end
        StyleSection:Slider({
            Title    = "Parry Time - " .. styleName,
            Desc     = "Override parry time for all " .. styleName .. " M1s.",
            Value    = { Min = 0, Max = 1, Default = defaultTime },
            Step     = 0.01,
            Callback = function(v)
                for _, anim in ipairs(data.Animations) do
                    anim.ParryTime = v
                end
                Config:Set("Style_ParryTime_" .. styleName, v); Config:Save()
            end,
        })
    end
end

-- ====================== UPDATE FUNCTIONS ======================
local function UpdateTargetPoolSection()
    pcall(function()
        local characters = GetAllCharactersInFolder()
        local names = {}
        for _, c in ipairs(characters) do
            table.insert(names, c.Name)
        end
        local poolString = #names > 0 and table.concat(names, ", ") or "No targets found"
        if TargetPoolPara then TargetPoolPara:SetDesc("Target Pool: " .. poolString) end
    end)
end

local lastStatsUpdate = 0
local function UpdateStatsUI()
    local now = os.clock()
    if (now - lastStatsUpdate) < 0.2 then return end
    lastStatsUpdate = now
    if StatsPara then
        local acc = Engine.Stats.TotalAttempts > 0 
            and (Engine.Stats.TotalSuccess / Engine.Stats.TotalAttempts * 100) or 0
        StatsPara:SetDesc(string.format(
            "Attempts: %d | Success: %d (%.0f%%) | Perfect: %d | Streak: %d | Ping: %dms",
            Engine.Stats.TotalAttempts,
            Engine.Stats.TotalSuccess,
            acc,
            Engine.Stats.TotalPerfect,
            Engine.Stats.ConsecSuccess,
            Ping.CachedPing * 1000
        ))
    end
end

-- ====================== INFORMATION TAB ======================
do
    local Info = InfoTab
    Info:Section({ Title = "DYHUB", TextXAlignment = "Center", TextSize = 17 })
    Info:Divider()
    Info:Paragraph({
        Title = "Update: 07/18/2026 | CL: " .. ver,
        Desc  = [[- Triple-Layer Parry Detection
- Adaptive Ping Compensation (rolling average)
- Predictive Parry (~20ms faster)
- Anti-Lag Buffer (jitter compensation)
- Perfect Frame Detection
- Smart Cooldown (streak-based)
- Priority Queue (M2 > close > perfect)
- Jitter Filter (median of 5 samples)
- Input Optimizer (zero wasted input)
- Live Statistics Display
- Auto-cleanup stale registry]],
    })
end

-- ====================== SETTINGS TAB ======================
do
    local Settings = SettingsTab
    Settings:Section({Title = "Save Config", Icon = "save"})

    Settings:Button({
        Title    = "Save Config (NOW)",
        Callback = function()
            Config:Save()
            WindUI:Notify({Title = "Config Saved", Content = "Saved!", Duration = 2, Icon = "save"})
        end
    })

    local AutoSaveEnabled = Config:Get("AutoSaveEnabled", true)
    local AutoSaveDelay   = Config:Get("AutoSaveDelay",   15)

    Settings:Toggle({
        Title    = "Auto Save Config",
        Value    = AutoSaveEnabled,
        Callback = function(state)
            AutoSaveEnabled = state
            Config:Set("AutoSaveEnabled", state); Config:Save()
            if state then Config:AutoSave(AutoSaveDelay) else Config:AutoSave(0) end
        end
    })

    Settings:Input({
        Title       = "Delay Save Config",
        Value       = tostring(AutoSaveDelay),
        Callback    = function(text)
            local num = tonumber(text)
            if num and num >= 1 then
                AutoSaveDelay = num
                Config:Set("AutoSaveDelay", num); Config:Save()
                if AutoSaveEnabled then Config:AutoSave(num) end
            end
        end
    })

    Settings:Section({Title = "Server Status", Icon = "server"})

    Settings:Button({
        Title    = "Serverhop",
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
                task.wait(1)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            end
        end
    })

    Settings:Button({
        Title    = "Rejoin",
        Callback = function()
            task.wait(1)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })
end

-- ====================== ORB LISTENER ======================
local PARRY_DISTANCE = 15
local lastOrbParryAt = 0

local function GetLocalHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local orbConnection
local function ListenForOrbs()
    pcall(function()
        if orbConnection then orbConnection:Disconnect() end
    end)
    orbConnection = RunService.RenderStepped:Connect(function()
        if not alive() then pcall(function() orbConnection:Disconnect() end) return end
        if not S.OrbParry then return end
        local hrp = GetLocalHRP()
        if not hrp or not hrp.Parent then return end
        local myPos = hrp.Position
        local thrown = Workspace:FindFirstChild("Thrown")
        if not thrown then return end
        for _, orb in ipairs(thrown:GetChildren()) do
            if orb.Name == "ArdourBall2" or orb.Name == "ArdourBall" then
                if (myPos - orb.Position).Magnitude <= PARRY_DISTANCE
                    and (tick() - lastOrbParryAt >= 0.1) then
                    lastOrbParryAt = tick()
                    Input:Press("F")
                    task.delay(0.05, function() Input:Release("F") end)
                    break
                end
            end
        end
    end)
end

if game.PlaceId == 8668476218 or game.PlaceId == 134572803901609 then
    ListenForOrbs()
end

-- ====================== DAMAGE LOGGER ======================
local lastCharacter, previousHealth
local damageLogConnection

function ToggleDamageLogger(state)
    pcall(function()
        if damageLogConnection then damageLogConnection:Disconnect(); damageLogConnection = nil end
    end)
    if not state then previousHealth = nil; lastCharacter = nil; return end
    damageLogConnection = RunService.Heartbeat:Connect(function()
        if not alive() then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum then return end
        if not lastCharacter or char ~= lastCharacter then
            lastCharacter = char
            previousHealth = hum.Health
        end
        local currentHealth = hum.Health
        if currentHealth < previousHealth then
            local dmg = previousHealth - currentHealth
            if #TargetCharacters > 0 and RemoteTracker then
                for _, target in ipairs(TargetCharacters) do
                    local ok, activeAnimations = pcall(function() return RemoteTracker:Update(target) end)
                    if not ok or not activeAnimations then continue end
                    for _, anim in ipairs(activeAnimations) do
                        if not anim.AnimationId or (anim.TimePosition or 0) < 0.1 or (anim.TimePosition or 0) > 0.7 then continue end
                        local assetId = tostring(anim.AnimationId)
                        local poolData = GameConfig[assetId]
                        warn(string.format("[HIT] %d DMG | %s (%s) %s | %.3f",
                            dmg, poolData and poolData.DisplayName or anim.Name or "?",
                            assetId, poolData and poolData.Style or "", anim.TimePosition or 0))
                    end
                end
            end
        end
        previousHealth = currentHealth
    end)
end

-- ====================== INPUT ======================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not alive() then return end
    if input.KeyCode == S.CycleKeybind then
        pcall(CycleEvent)
    end
end)

-- ====================== ANTI-AFK ======================
local idleConn = LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ====================== MAIN LOOPS ======================
local COMBAT_TICK    = 0
local TARGET_TICK    = 0.5
local lastAnimCheck  = 0
local lastCycleCheck = 0
local lastBlockTick  = 0
local blockHoldUntil = 0

RunService.Heartbeat:Connect(function(dt)
    if not alive() then return end

    pcall(function() Engine:Tick() end)
    pcall(EvaluateParryTriggers)
    pcall(schedulerUpdate)
    pcall(UpdateStatsUI)

    local now = os.clock()

    -- Smart AutoBlock (predictive, pulse-based)
    if S.AutoBlock and S.AutoParry and not Engine.Stunned and not Engine.KeyHeld then
        if (now - lastBlockTick) >= 0.05 then
            lastBlockTick = now
            pcall(function() Input:Press("F") end)
            blockHoldUntil = now + 0.04 -- hold 40ms
        end
    end
    
    if blockHoldUntil > 0 and now >= blockHoldUntil and not Engine.KeyHeld and not Engine.Stunned then
        blockHoldUntil = 0
        pcall(function() Input:Release("F") end)
    end

    if (now - lastAnimCheck >= COMBAT_TICK) then
        lastAnimCheck = now
        if #TargetCharacters >= 1 then
            pcall(ProcessEspAndLogging)
        end
        local localChar = LocalPlayer.Character
        if localChar and localChar:FindFirstChild("Humanoid") and LocalTracker then
            pcall(function() LocalTracker:Update(localChar) end)
        end
    end

    if (now - lastCycleCheck >= TARGET_TICK) then
        lastCycleCheck = now
        if S.AutoTargetNearest then
            pcall(CycleEvent)
        end
    end
end)

if S.DamageLogs then
    task.defer(function() pcall(ToggleDamageLogger, true) end)
end

task.defer(function() pcall(UpdateTargetPoolSection) end)

-- ====================== TEARDOWN ======================
do
    local function teardown()
        getgenv()._WH_AP_gen = -1
        pcall(function() if idleConn then idleConn:Disconnect() end end)
        pcall(function() if orbConnection then orbConnection:Disconnect() end end)
        pcall(function() if damageLogConnection then damageLogConnection:Disconnect() end end)
        pcall(ClearAllEspTrackers)
        pcall(function() Input:Cleanup() end)
    end
    if WindUI and WindUI.OnExit then
        local prev = WindUI.OnExit
        WindUI.OnExit = function()
            pcall(teardown)
            pcall(prev)
        end
    end
end

print("[DYHUB] " .. version .. " | " .. ver .. " loaded!")
