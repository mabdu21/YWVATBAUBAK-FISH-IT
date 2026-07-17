-- =========================
local version = "PAID"
local ver     = "v013.00"
-- =========================

repeat task.wait() until game:IsLoaded()

-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

if setfpscap then
    pcall(function() setfpscap(1000000) end)
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
end)

-- ====================== INPUT SYSTEM (FIXED) ======================
local VIM_KeyMap = {
    F = Enum.KeyCode.F,
    Q = Enum.KeyCode.Q,
    E = Enum.KeyCode.E,
}

local function pressKey(keyChar)
    local keyCode = VIM_KeyMap[keyChar] or Enum.KeyCode[keyChar]
    -- Try VIM first
    local ok = pcall(function()
        VIM:SendKeyEvent(true, keyCode, false, game)
    end)
    -- Fallback to keypress (some exploits)
    if not ok then
        pcall(function() keypress(Enum.KeyCode[keyChar].Value) end)
    end
end

local function releaseKey(keyChar)
    local keyCode = VIM_KeyMap[keyChar] or Enum.KeyCode[keyChar]
    local ok = pcall(function()
        VIM:SendKeyEvent(false, keyCode, false, game)
    end)
    if not ok then
        pcall(function() keyrelease(Enum.KeyCode[keyChar].Value) end)
    end
end

local function mouseRightClick()
    pcall(function() VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 1, true, game, 1) end)
    pcall(function() VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 1, false, game, 1) end)
    pcall(function() if mouse2click then mouse2click() end end)
end

-- ====================== PING CALCULATION (FIXED) ======================
local function GetPingSeconds()
    local ok, ping = pcall(function() return LocalPlayer:GetNetworkPing() end)
    if ok and type(ping) == "number" then
        return ping / 2 -- one-way latency
    end
    return 0
end

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
    Size       = UDim2.fromOffset(500, 400),
    Transparent = true,
    Theme      = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar    = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.RightControl) -- เปลี่ยนเป็น RightControl กันชน cycle
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
local ConfigFolder = "DYHUB_G"
local CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self = setmetatable({}, CustomConfig)
    self.ConfigData     = {}
    self.ConfigPath     = ConfigFolder .. "/gakuran_config.json"
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
        pcall(task.cancel, self._autoSaveThread)
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

local AutoParryRange = Config:Get("AP_AutoParryRange", 40)
local MaxCycleRange  = Config:Get("AP_MaxCycleRange",  20)
local ParryWindow    = Config:Get("AP_ParryWindow",    0.1)
local DefaultParryTime = Config:Get("AP_DefaultParryTime", 0.1)
local ReleaseTime    = Config:Get("AP_ReleaseTime",    0.3)
local CooldownTime   = 0.1

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

-- ====================== STATE (FIXED) ======================
local S = {
    AutoParry            = Config:Get("AP_AutoParry",            true),
    AutoDodge            = Config:Get("AP_AutoDodge",            true),
    AutoTargetNearest    = Config:Get("AP_AutoTargetNearest",    false),
    MultiTarget          = Config:Get("AP_MultiTarget",          true),
    TargetFacingYou      = Config:Get("AP_TargetFacingYou",      false),
    YouFacingTarget      = Config:Get("AP_YouFacingTarget",      true),
    IncludeLocalCharacter = Config:Get("AP_IncludeLocalCharacter", false),
    DamageLogs           = Config:Get("AP_DamageLogs",           false),
    OrbParry             = Config:Get("AP_OrbParry",             false),
    SelectedFolder       = nil,
    CycleKeybind         = Config:Get("AP_CycleKeybind",         Enum.KeyCode.X), -- เปลี่ยนเป็น X
    AutoBlock            = Config:Get("AP_AutoBlock",            true),
}

-- ====================== TABS ======================
local InfoTab     = Window:Tab({ Title = "Information",        Icon = "info" })
Window:Divider()
local APTab       = Window:Tab({ Title = "Auto Parry",         Icon = "swords" })
local ConfigTab   = Window:Tab({ Title = "Style Configurations", Icon = "settings-2" })
Window:Divider()
local SettingsTab = Window:Tab({ Title = "Settings",           Icon = "settings" })

Window:SelectTab(1)

-- ====================== SECTIONS ======================
local TargetingSection = APTab:Section({ Title = "Targeting",     Icon = "target" })
local CombatSection    = APTab:Section({ Title = "Combat",        Icon = "swords" })
local OrbSection       = APTab:Section({ Title = "Orb Parry",     Icon = "circle" })
local LoggingSection   = APTab:Section({ Title = "Logging",       Icon = "clipboard" })
local StyleSection     = ConfigTab:Section({ Title = "Style Parry Times", Icon = "sliders-horizontal" })

-- ====================== UI REFERENCES ======================
local TargetPoolPara, LoggedPara, IgnoredPara, FolderDropdown
local AutoParryToggle, AutoDodgeToggle, AutoTargetNearestToggle
local TargetFacingYouToggle, YouFacingTargetToggle

-- ====================== HELPERS ======================
local function GetAllFoldersInWorkspace()
    local folders = {}
    local seen = {}
    local function addFolder(name)
        if not seen[name] then
            seen[name] = true
            table.insert(folders, name)
        end
    end
    for _, folder in Workspace:GetChildren() do
        if folder.ClassName == "Folder" then
            addFolder(folder.Name)
        end
    end
    -- ถ้าไม่เจอ ให้หา folder ที่มี character
    if #folders == 0 then
        for _, child in Workspace:GetChildren() do
            if child.ClassName == "Model" and child:FindFirstChildWhichIsA("Humanoid") then
                addFolder(child.Parent and child.Parent.Name or "Workspace")
            end
        end
    end
    return folders
end

local function GetAllCharactersInFolder()
    if not S.SelectedFolder or S.SelectedFolder == "" then return {} end
    local folder = Workspace:FindFirstChild(S.SelectedFolder)
    if not folder then
        -- fallback: ดู child ของ Workspace ทั้งหมดที่เป็น Model + Humanoid
        local chars = {}
        for _, child in Workspace:GetChildren() do
            if child.ClassName == "Model" and child:FindFirstChildWhichIsA("Humanoid") then
                if not S.IncludeLocalCharacter and LocalPlayer.Character and child == LocalPlayer.Character then
                    continue
                end
                table.insert(chars, child)
            end
        end
        return chars
    end
    local characters = {}
    for _, character in folder:GetChildren() do
        if character.ClassName == "Model" and character:FindFirstChildWhichIsA("Humanoid") then
            if not S.IncludeLocalCharacter then
                if LocalPlayer.Character and character == LocalPlayer.Character then continue end
            end
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

local function UpdateClipboardSection()
    pcall(function()
        if LoggedPara then
            LoggedPara:SetDesc("Logged Ids: " .. #AnimationsLoggedOrder)
        end
        if IgnoredPara then
            IgnoredPara:SetDesc("Ignored Ids: " .. #IgnoreIds)
        end
    end)
end

-- ====================== BUILD UI : TARGETING ======================
TargetPoolPara = TargetingSection:Paragraph({
    Title = "Target Pool",
    Desc  = "No targets found",
    Image = "users",
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
        Desc     = "Always target the closest enemy (skips manual cycle).",
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

-- ====================== BUILD UI : COMBAT ======================
AutoParryToggle = CombatSection:Toggle({
    Title    = "Auto Parry",
    Desc     = "Auto block enemy attacks at the perfect time.",
    Value    = S.AutoParry,
    Callback = function(v)
        S.AutoParry = v
        Config:Set("AP_AutoParry", v); Config:Save()
        WindUI:Notify({ Title = "Auto Parry", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = v and "shield" or "shield-off" })
    end,
})
pcall(function() AutoParryToggle:Keybind(Enum.KeyCode.G) end)

AutoDodgeToggle = CombatSection:Toggle({
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
    Desc     = "Always hold block when no parry is active (safer).",
    Value    = S.AutoBlock,
    Callback = function(v)
        S.AutoBlock = v
        Config:Set("AP_AutoBlock", v); Config:Save()
    end,
})

TargetFacingYouToggle = CombatSection:Toggle({
    Title    = "Target facing you",
    Desc     = "Only parry when the enemy is looking at you.",
    Value    = S.TargetFacingYou,
    Callback = function(v)
        S.TargetFacingYou = v
        Config:Set("AP_TargetFacingYou", v); Config:Save()
    end,
})

YouFacingTargetToggle = CombatSection:Toggle({
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

-- ====================== BUILD UI : ORB ======================
local OrbParryToggle = OrbSection:Toggle({
    Title    = "Auto Orb Parry",
    Desc     = "Auto-parry orbs (The Strongest Battlegrounds & others).",
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

-- ====================== BUILD UI : LOGGING ======================
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

local DamageLogToggle = LoggingSection:Toggle({
    Title    = "Damage Logs",
    Desc     = "Print damage taken in console with attack info.",
    Value    = S.DamageLogs,
    Callback = function(v)
        S.DamageLogs = v
        Config:Set("AP_DamageLogs", v); Config:Save()
        if ToggleDamageLogger then pcall(ToggleDamageLogger, v) end
    end,
})

LoggingSection:Button({
    Title    = "Copy to clipboard",
    Desc     = "Copies all logged animation IDs to clipboard.",
    Callback = SetClipboardLoggedCache,
})

LoggingSection:Button({
    Title    = "Clear animation cache",
    Desc     = "Clears all logged animation IDs.",
    Callback = function()
        AnimationsLoggedCache = {}
        AnimationsLoggedOrder = {}
        UpdateClipboardSection()
        WindUI:Notify({ Title = "Cache", Content = "Cleared.", Duration = 2, Icon = "trash-2" })
    end,
})

-- ====================== BUILD UI : STYLE CONFIG ======================
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

-- ====================== INFORMATION TAB ======================
do
    local Info = InfoTab

    Info:Section({ Title = "DYHUB | Gakuran", TextXAlignment = "Center", TextSize = 17 })
    Info:Divider()
    Info:Paragraph({
        Title = "Update: 07/02/2026 | CL: " .. ver,
        Desc  = [[
• [ Fixed ] keypress/keyrelease ใช้ VIM แทน globals
• [ Fixed ] GetPingValue ใช้ GetNetworkPing ของ Roblox
• [ Fixed ] Toggle conflict (K -> RightControl/X)
• [ Fixed ] Folder detection ค้นหาแบบ recursive + fallback
• [ Fixed ] AutoBlock ระหว่างรอ parry
• [ Added ] Folder auto-search (Players, Live, NPCs, Mobs, ...)
• [ Added ] Parry success/stun visual feedback
• [ Added ] Connection teardown ป้องกัน dup]],
        Image = "rbxassetid://104487529937663", ImageSize = 30,
    })
    Info:Divider()

    if not ui then ui = {} end
    if not ui.Creator then ui.Creator = {} end
    ui.Creator.Request = function(requestData)
        local success, result = pcall(function()
            if HttpService.RequestAsync then
                local response = HttpService:RequestAsync({
                    Url = requestData.Url,
                    Method = requestData.Method or "GET",
                    Headers = requestData.Headers or {}
                })
                return {Body = response.Body, StatusCode = response.StatusCode, Success = response.Success}
            else
                local body = HttpService:GetAsync(requestData.Url)
                return {Body = body, StatusCode = 200, Success = true}
            end
        end)
        if success then return result else error("HTTP Request failed: " .. tostring(result)) end
    end

    local InviteCode = "jWNDPNMmyB"
    local DiscordAPI  = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"
    local function LoadDiscordInfo()
        local success, result = pcall(function()
            return HttpService:JSONDecode(ui.Creator.Request({
                Url = DiscordAPI, Method = "GET",
                Headers = {["User-Agent"] = "RobloxBot/1.0", ["Accept"] = "application/json"}
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
            Info:Button({Title = "Update Info", Callback = function()
                local ok, r = pcall(function()
                    return HttpService:JSONDecode(ui.Creator.Request({Url = DiscordAPI, Method = "GET"}).Body)
                end)
                if ok and r and r.guild then
                    DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : ' .. tostring(r.approximate_member_count) ..
                                        '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(r.approximate_presence_count))
                    WindUI:Notify({Title = "Discord Info Updated", Content = "Refreshed!", Duration = 2, Icon = "refresh-cw"})
                else
                    WindUI:Notify({Title = "Update Failed", Content = "Could not refresh.", Duration = 3, Icon = "alert-triangle"})
                end
            end})
            Info:Button({Title = "Copy Discord Invite", Callback = function()
                setclipboard("https://discord.gg/" .. InviteCode)
                WindUI:Notify({Title = "Copied!", Content = "Discord invite copied!", Duration = 2, Icon = "clipboard-check"})
            end})
        else
            Info:Paragraph({Title = "Error fetching Discord Info", Desc = "Unable to load.", Image = "triangle-alert", ImageSize = 26, Color = "Red"})
        end
    end
    LoadDiscordInfo()

    Info:Divider()
    Info:Section({Title = "DYHUB Information", TextXAlignment = "Center", TextSize = 17})
    Info:Divider()
    Info:Paragraph({Title = "Main Owner", Desc = "@dyumraisgoodguy#8888", Image = "rbxassetid://119789418015420", ImageSize = 30})
    Info:Paragraph({
        Title = "Social", Desc = "Copy link social media for follow!",
        Image = "rbxassetid://104487529937663", ImageSize = 30,
        Buttons = {{Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://guns.lol/DYHUB") end}}
    })
    Info:Paragraph({
        Title = "Discord", Desc = "Join our discord for more scripts!",
        Image = "rbxassetid://104487529937663", ImageSize = 30,
        Buttons = {{Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://discord.gg/jWNDPNMmyB") end}}
    })
end

-- ====================== SETTINGS TAB ======================
do
    local Settings = SettingsTab

    Settings:Divider()
    Settings:Section({Title = "Save Config", Icon = "save"})

    Settings:Button({
        Title    = "Save Config (NOW)",
        Desc     = "Saves all current settings immediately.",
        Callback = function()
            Config:Save()
            WindUI:Notify({Title = "Config Saved", Content = "Config saved successfully!", Duration = 2, Icon = "save"})
        end
    })

    local AutoSaveEnabled = Config:Get("AutoSaveEnabled", true)
    local AutoSaveDelay   = Config:Get("AutoSaveDelay",   15)

    Settings:Toggle({
        Title    = "Auto Save Config",
        Desc     = "Automatically saves config at set interval.",
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
        Placeholder = "Default: 15",
        Callback    = function(text)
            local num = tonumber(text)
            if num and num >= 1 then
                AutoSaveDelay = num
                Config:Set("AutoSaveDelay", num); Config:Save()
                if AutoSaveEnabled then Config:AutoSave(num) end
                WindUI:Notify({Title = "Config Delay", Content = "Set to " .. num .. "s", Duration = 2, Icon = "clock"})
            else
                WindUI:Notify({Title = "Invalid", Content = "Enter a number >= 1", Duration = 3, Icon = "alert-triangle"})
            end
        end
    })

    Settings:Section({Title = "Server Status", Icon = "server"})

    Settings:Button({
        Title    = "Serverhop",
        Desc     = "Teleports you to a different random server.",
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
                WindUI:Notify({Title = "Serverhop", Content = "Teleporting...", Duration = 2, Icon = "server"})
                task.wait(1)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            else
                WindUI:Notify({Title = "Serverhop Failed", Content = "No available servers.", Duration = 3, Icon = "alert-triangle"})
            end
        end
    })

    Settings:Button({
        Title    = "Rejoin",
        Desc     = "Rejoins the current game server.",
        Callback = function()
            WindUI:Notify({Title = "Rejoin", Content = "Rejoining...", Duration = 2, Icon = "refresh-cw"})
            task.wait(1)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })
end

-- ====================== ORB LISTENER (FIXED) ======================
local PARRY_DISTANCE = 15
local lastParryAt = 0

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
                    and (tick() - lastParryAt >= 0.1) then
                    lastParryAt = tick()
                    BlockStart()
                    BlockEnd()
                    break
                end
            end
        end
    end)
end

if game.PlaceId == 8668476218 or game.PlaceId == 134572803901609 then
    ListenForOrbs()
end

-- ====================== COMBAT CORE (FIXED) ======================
local ParryKey = "F"
local DodgeKey = "Q"

local KeyHeld = false
local CooldownActive = false
local LastParryTime = 0
local ReleaseDeadline = 0
local PendingParryTimestamp = nil
local ParrySuccess = false
local parryIntentSnapshot = nil

local Stunned = false
local currentStunToken = 0

local LocalTracker, RemoteTracker
if AnimationTracker then
    pcall(function()
        LocalTracker  = AnimationTracker.new(IgnoreIds)
        RemoteTracker = AnimationTracker.new(IgnoreIds)
    end)
end

local lastCharacter, previousHealth
local damageLogConnection

function Dodge()
    pcall(function()
        releaseKey(DodgeKey)
        releaseKey(ParryKey)
        pressKey(DodgeKey)
        releaseKey(DodgeKey)
        mouseRightClick()
    end)
end

function BlockStart(now, duration)
    now = now or os.clock()
    local holdTime = duration or ReleaseTime
    ReleaseDeadline = now + holdTime
    KeyHeld = true
    CooldownActive = true
    LastParryTime = now

    if S.AutoParry then
        pcall(function()
            pressKey(ParryKey)
        end)
    end
end

function BlockEnd()
    KeyHeld = false
    ReleaseDeadline = 0
    ParrySuccess = false
    if S.AutoParry then
        pcall(function() releaseKey(ParryKey) end)
    end
end

local function ParryTask()
    if not alive() then return end
    local now = os.clock()

    if KeyHeld then
        if (now >= ReleaseDeadline) or ParrySuccess then
            if ParrySuccess then ParrySuccess = false end
            BlockEnd()
        end
    end

    if PendingParryTimestamp then
        local latency = now - PendingParryTimestamp
        local isExpired = latency > ParryWindow
        if isExpired then
            PendingParryTimestamp = nil
        elseif not CooldownActive then
            BlockStart(now)
            PendingParryTimestamp = nil
        end
    end
end

local function onLocalAnimationAdded(anim)
    if not anim or not anim.AnimationId then return end
    local animId = anim.AnimationId

    if table.find(ParriedAnimation, animId) then
        if parryIntentSnapshot then
            local timeStr = string.format("%.3f", parryIntentSnapshot.TriggerTime)
            WindUI:Notify({
                Title = "Parry status",
                Content = "success! " .. parryIntentSnapshot.Style .. " " .. parryIntentSnapshot.DisplayName .. " @ " .. timeStr,
                Duration = 2, Icon = "check",
            })
            parryIntentSnapshot = nil
        else
            WindUI:Notify({Title = "Parry status", Content = "success", Duration = 1, Icon = "check"})
        end
        ParrySuccess = true
        CooldownActive = false
    end

    if table.find(StunnedAnimation, animId) then
        Stunned = true
        currentStunToken = currentStunToken + 1
        local myToken = currentStunToken
        schedulerDelay(0.2, function()
            if currentStunToken == myToken then
                Stunned = false
            end
        end)
    end
end

if LocalTracker and LocalTracker.AnimationAdded then
    pcall(function()
        LocalTracker.AnimationAdded:Connect(onLocalAnimationAdded)
    end)
end

-- ====================== EVALUATION (FIXED) ======================
local AnimationRegistry = {}

local function LogAnimation(assetId, trackInfo)
    if not AnimationsLoggedCache[assetId] then
        AnimationsLoggedCache[assetId] = { Name = trackInfo.Name }
        table.insert(AnimationsLoggedOrder, assetId)
        UpdateClipboardSection()
    end
end

local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_RED   = Color3.fromRGB(255, 50, 50)
local COLOR_GREEN = Color3.fromRGB(50, 255, 50)

local function EvaluateParryTriggers()
    if not alive() then return end
    if not S.AutoParry then return end
    if not HumanoidRootPart or not HumanoidRootPart.Parent or Stunned then return end
    if not RemoteTracker then return end

    local localRoot = HumanoidRootPart
    local pingDelay = GetPingSeconds()

    local currentActiveIds = {}

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
            local currentTrackTime = anim.TimePosition or 0

            if not AnimationRegistry[animKey] then
                AnimationRegistry[animKey] = {
                    StartTime = now - currentTrackTime,
                    Processed = false,
                    Snapshot  = false,
                    LastTime  = currentTrackTime,
                }
            end

            local regData = AnimationRegistry[animKey]

            -- animation restart detection (loop / new attack)
            if regData.LastTime and (currentTrackTime < regData.LastTime - 0.1) then
                regData.Processed = false
                regData.Snapshot  = false
                regData.StartTime = now - currentTrackTime
            end
            regData.LastTime = currentTrackTime

            local attackConfig = GameConfig[tostring(anim.AnimationId)]
            if not attackConfig then continue end

            local startTime  = regData.StartTime
            local currentTime = now - startTime
            local baseTime   = attackConfig.ParryTime or DefaultParryTime
            local parryStart = baseTime - pingDelay
            local parryEnd   = baseTime + ParryWindow
            local isHeavy    = attackConfig.DisplayName == "M2"

            if regData.Processed then continue end

            if character ~= LocalPlayer.Character then
                local direction = (targetRoot.Position - localRoot.Position).Unit
                if not isHeavy then
                    if S.TargetFacingYou then
                        if targetRoot.CFrame.LookVector:Dot(-direction) < 0.25 then continue end
                    end
                    if S.YouFacingTarget then
                        if localRoot.CFrame.LookVector:Dot(direction) < 0.25 then continue end
                    end
                end
            end

            if currentTime >= parryStart and currentTime <= parryEnd then
                if not regData.Snapshot then
                    regData.Snapshot = true
                    parryIntentSnapshot = {
                        TriggerTime  = currentTime,
                        Style        = attackConfig.Style or "Unknown",
                        DisplayName  = attackConfig.DisplayName or "Attack",
                    }
                end

                if isHeavy and S.AutoDodge then
                    Dodge()
                else
                    BlockStart()
                    PendingParryTimestamp = now
                end
            end
        end
    end

    for key in pairs(AnimationRegistry) do
        if not currentActiveIds[key] then
            AnimationRegistry[key] = nil
        end
    end
end

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
local TargetCharacters = {}
local EspTrackers = {}
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

-- ====================== DAMAGE LOGGER ======================
function ToggleDamageLogger(state)
    pcall(function()
        if damageLogConnection then
            damageLogConnection:Disconnect()
            damageLogConnection = nil
        end
    end)
    if not state then
        previousHealth = nil
        lastCharacter = nil
        return
    end

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
                            dmg,
                            poolData and poolData.DisplayName or anim.Name or "Unknown",
                            assetId,
                            poolData and poolData.Style or "",
                            anim.TimePosition or 0
                        ))
                    end
                end
            end
        end
        previousHealth = currentHealth
    end)
end

-- ====================== INPUT (FIXED) ======================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not alive() then return end
    if input.KeyCode == S.CycleKeybind then
        pcall(CycleEvent)
    end
end)

-- ====================== ANTI-AFK ======================
local idleConn = LocalPlayer.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)

-- ====================== LOOPS (FIXED) ======================
local COMBAT_TICK    = 0
local TARGET_TICK    = 0.5
local lastAnimCheck  = 0
local lastCycleCheck = 0
local lastBlockTick  = 0

RunService.Heartbeat:Connect(function()
    if not alive() then return end

    pcall(ParryTask)
    pcall(EvaluateParryTriggers)
    pcall(schedulerUpdate)

    local now = os.clock()

    -- Auto Block: hold F ตลอดเวลาที่ยังไม่ parry (ช่วยให้ parry ติดบ่อยขึ้น)
    if S.AutoBlock and S.AutoParry and not Stunned and not KeyHeld then
        if (now - lastBlockTick) >= 0.1 then
            lastBlockTick = now
            pcall(function() pressKey(ParryKey) end)
            task.delay(0.08, function()
                if not KeyHeld and not Stunned then
                    pcall(function() releaseKey(ParryKey) end)
                end
            end)
        end
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
        pcall(function() releaseKey(ParryKey) end)
    end

    if WindUI and WindUI.OnExit then
        local prev = WindUI.OnExit
        WindUI.OnExit = function()
            pcall(teardown)
            pcall(prev)
        end
    end
end

print("[DYHUB] " .. version .. " | " .. ver .. " loaded successfully!")
print("[DYHUB] Config active | Auto saving every " .. tostring(Config:Get("AutoSaveDelay", 15)) .. "s")
