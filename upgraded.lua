-- Powered by nig | v523
-- =========================
local version = "Rework"
local ver     = "v015.08"
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
local VirtualUser       = game:GetService("VirtualUser")
local VIM               = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = Workspace.CurrentCamera


-- ====================== RERUN / CLEANUP SAFETY ======================
-- เก็บ connection/thread สำคัญไว้ที่ runtime table เพื่อลดบัคตอน execute ซ้ำ
local DYHUB_RUNTIME = _G.DYHUB_RUNTIME or {}
if DYHUB_RUNTIME.Cleanup then pcall(DYHUB_RUNTIME.Cleanup) end
_G.DYHUB_RUNTIME = DYHUB_RUNTIME
DYHUB_RUNTIME._connections = {}
DYHUB_RUNTIME._threads = {}

local function DYHUB_Disconnect(c)
    pcall(function()
        if c and typeof(c) == "RBXScriptConnection" then c:Disconnect() end
    end)
end

local function DYHUB_AddConnection(c)
    if c and typeof(c) == "RBXScriptConnection" then
        DYHUB_RUNTIME._connections[#DYHUB_RUNTIME._connections + 1] = c
    end
    return c
end

local function DYHUB_TrackThread(t)
    if t then DYHUB_RUNTIME._threads[#DYHUB_RUNTIME._threads + 1] = t end
    return t
end

local function DYHUB_ClearList(t)
    for k in pairs(t or {}) do t[k] = nil end
end

function DYHUB_RUNTIME.Cleanup()
    for _, c in ipairs(DYHUB_RUNTIME._connections or {}) do DYHUB_Disconnect(c) end
    for _, t in ipairs(DYHUB_RUNTIME._threads or {}) do pcall(function() task.cancel(t) end) end
    DYHUB_ClearList(DYHUB_RUNTIME._connections)
    DYHUB_ClearList(DYHUB_RUNTIME._threads)
    if _G.DYHUB_AP and _G.DYHUB_AP.Shutdown then pcall(_G.DYHUB_AP.Shutdown) end
end

local function DYHUB_FindPath(root, ...)
    local cur = root
    for _, name in ipairs({...}) do
        if not cur then return nil end
        cur = cur:FindFirstChild(name)
    end
    return cur
end

local function DYHUB_GetRemote(...)
    local r = DYHUB_FindPath(ReplicatedStorage, ...)
    return (r and r:IsA("RemoteEvent")) and r or nil
end

-- ====================== CHARACTER CACHE ======================
local Character        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid         = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

DYHUB_AddConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    Character        = char
    Humanoid         = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end))

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
    Author     = "Violence District | " .. userversion,
    Folder     = "DYHUB_VD",
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
local ConfigFolder = "DYHUB_VD"
local CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self      = setmetatable({}, CustomConfig)
    self.ConfigData = {}
    self.ConfigPath = ConfigFolder .. "/config_main_02.json"
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
        self._autoSaveThread = DYHUB_TrackThread(task.spawn(function()
            while true do
                task.wait(self._autoSaveDelay or 15)
                self:Save()
            end
        end))
    end
end

local Config = CustomConfig.new()
if Config:Get("AutoSaveEnabled", true) then
    Config:AutoSave(Config:Get("AutoSaveDelay", 15))
end

-- ====================== SETTINGS TABLE (รวม locals ทั้งหมด) ======================
-- [Fix] รวม locals เข้า settings table เดียว ยกเว้น ver, version
local settings = {
    -- Auto Parry
    AutoParry         = Config:Get("autoparry",      false),
    AutoParryMode     = Config:Get("autoparrymode",  "Fast"),
    AutoParryRange    = Config:Get("autoparryrange", 20),
    HookNearDist      = Config:Get("hookrange",      6),

    -- Generator / Skill
    AutoSkillPerfect  = Config:Get("AutoSkillPerfect", false),
    AutoSkillNeutral  = Config:Get("AutoSkillNeutral", false),
    AutoGenRepair     = Config:Get("AutoGenRepair",    false),

    -- ESP master + roles
    EspEnabled        = Config:Get("espEnabled",       false),
    EspSurvivor       = Config:Get("espSurvivor",      false),
    EspMurder         = Config:Get("espMurder",        false),
    EspGenerator      = Config:Get("espGenerator",     false),
    EspGate           = Config:Get("espGate",          false),
    EspHook           = Config:Get("espHook",          false),
    EspPallet         = Config:Get("espPallet",        false),
    EspWindow         = Config:Get("espWindow",        false),
    EspPatient        = Config:Get("espPatient",       false),
    ShowName          = Config:Get("ShowName",         true),
    ShowDistance      = Config:Get("ShowDistance",     true),
    ShowHP            = Config:Get("ShowHP",           true),
    ShowHighlight     = Config:Get("ShowHighlight",    true),
    ShowPercent       = Config:Get("ShowPercent",      true),
    EspMaxDistance    = Config:Get("ESP_MAX_DISTANCE", 1500),

    -- Player
    SpeedEnabled      = Config:Get("SpeedEnabled",   false),
    SpeedWalk         = Config:Get("SpeedWalk",       3),
    NoClipEnabled     = Config:Get("NoClipEnabled",   false),
    NoFallEnabled     = Config:Get("NoFallEnabled",  false),

    -- Visual
    FullBrightEnabled = Config:Get("fullBrightEnabled", false),
    NoFogEnabled      = Config:Get("noFogEnabled",      false),

    -- Bypass
    BypassGateEnabled = Config:Get("bypassGateEnabled", false),

    -- Misc
    CrosshairEnabled  = Config:Get("CrosshairEnabled",  false),
    AntiAFK           = Config:Get("AntiAFK_main",      true),
    AutoSaveEnabled   = Config:Get("AutoSaveEnabled",   true),
    AutoSaveDelay     = Config:Get("AutoSaveDelay",     15),

    -- Killer
    DYHUB_MIN_PITCH       = Config:Get("DYHUB_MIN_PITCH",   -1),
    DYHUB_MAX_PITCH       = Config:Get("DYHUB_MAX_PITCH",   30),
    DYHUB_ToughWall       = Config:Get("DYHUB_ToughWall",   true),
    DYHUB_PredictionTime  = 0.14,
    DYHUB_MIN_DISTANCE    = 1,
    DYHUB_MAX_DISTANCE    = 250,
    DYHUB_LOW_HP_IGNORE   = 20,
    AimbotKey             = Config:Get("AimbotKey",   "Z"),
    AimbotKey28           = Config:Get("AimbotKey28", "V"),
    GrabKey               = Config:Get("GrabKey",     "C"),

    -- Killer features
    SelectedMasks         = Config:Get("selectedMasks", "Richard"),
    Stalker               = Config:Get("Stalker",        false),
    KillAll               = Config:Get("killall",        false),
    AutoCarry             = Config:Get("autocarry",      false),
    AutoHook              = Config:Get("autohook",       false),
    AutoAttack            = Config:Get("autoattack",     false),
    NoFlashlight          = Config:Get("noblind",        false),
    DestroyPallet         = Config:Get("destroyPalletwrong", false),
}

-- ====================== TABS ======================
local InfoTab     = Window:Tab({ Title = "Information", Icon = "info" })
local _D1         = Window:Divider()
local SurTab      = Window:Tab({ Title = "Survivor",    Icon = "user-check" })
local killerTab   = Window:Tab({ Title = "Killer",      Icon = "swords" })
local _D2         = Window:Divider()
local MainTab     = Window:Tab({ Title = "Main",        Icon = "rocket" })
local EspTab      = Window:Tab({ Title = "Esp",         Icon = "eye" })
local PlayerTab   = Window:Tab({ Title = "Player",      Icon = "user" })
local TeleportTab = Window:Tab({ Title = "Teleport",    Icon = "map-pin" })
local _D3         = Window:Divider()
local Main3       = Window:Tab({ Title = "Settings",    Icon = "settings" })

Window:SelectTab(1)

local Info = InfoTab
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

Info:Section({ Title = "Latest Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({
    Title = "Update: 05/30/2026 | CL: " .. ver,
    Desc  = [[• [ Reword ] Speed Walk description changed to a cleaner CFrame movement description
• [ Reword ] Auto Parry description and mode info simplified for easier understanding
• [ Reword ] Latest Update text updated to match the new v015.05 generator optimization changes

• [ New ] Auto Parry v6 with rehook system for killer, weapon, and character changes
• [ New ] Auto Parry heartbeat fallback scan if AnimationPlayed does not fire
• [ New ] Recursive mobile parry button finder with PC fallback support
• [ New ] Runtime bridge for sharing functions across do-scope safely

• [ Added ] Auto Generator v4 Lite system
• [ Added ] Cached generator list, repair point cache, and progress cache
• [ Added ] Cached SkillCheck GUI / Check object lookup
• [ Added ] Debounced generator cache invalidation when map objects change
• [ Added ] Movement cancel support using X, WASD, arrow keys, space, and mobile joystick
• [ Added ] Auto Generator restore after respawn / character reload

• [ Fixed ] Auto Generator lag/freeze when enabled
• [ Fixed ] SkillCheck loop no longer scans all generators every tick
• [ Fixed ] Generator scan now prioritizes workspace.Map before fallback workspace scan
• [ Fixed ] Repair loop no longer repeatedly teleports to the same point too fast
• [ Fixed ] Generator cache clears when generators / repair points are added or removed
• [ Fixed ] Auto Parry missing hooks after killer or weapon changes
• [ Fixed ] Mobile parry button detection is more reliable

• [ Improved ] Auto Generator now supports more generator and repair point names
• [ Improved ] Teleport + Repair now avoids generators near the killer
• [ Improved ] Repair retry timing is slower and safer to reduce lag
• [ Improved ] Auto SkillCheck Perfect / Neutral now share one optimized system
• [ Improved ] Settings now use a centralized settings table
• [ Improved ] Anti-AFK toggle now updates settings table before saving
• [ Improved ] Speed Walk slider now saves through settings table

• [ Optimized ] Removed repeated full GetDescendants scans from active generator loops
• [ Optimized ] Generator scan is cached and debounced
• [ Optimized ] Repair point lookup is cached per generator
• [ Optimized ] Generator progress check is cached briefly
• [ Optimized ] GUI scan is throttled instead of checking deeply every tick
• [ Optimized ] Auto Generator loop delay increased to reduce freezing

• [ Kept ] Auto SkillCheck Perfect mode
• [ Kept ] Auto SkillCheck Neutral mode
• [ Kept ] Auto Generator teleport + repair
• [ Kept ] Cancel by X, movement keys, and mobile joystick
• [ Kept ] Premium-only Auto Parry system
• [ Kept ] ESP cached world scan system
• [ Kept ] No Clip, No Fall, Speed Walk, Teleport, and other existing features]],
})
Info:Divider()

-- Runtime bridge: ใช้แชร์ฟังก์ชันข้าม do-scope เพื่อลด local register ไม่ให้เกิน 200
-- DYHUB_RUNTIME is initialized at the top for cleanup/rerun safety

-- =====================================================================================
--  HELPER: isKillerChar (shared, defined early)
-- =====================================================================================
local function isKillerChar(char)
    if not char then return false end
    if char:FindFirstChild("Weapon") then return true end
    for _, obj in ipairs(char:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Tool")) and obj.Name:lower():find("weapon") then
            return true
        end
    end
    return false
end

-- =====================================================================================
-- =====================================================================================
--  AUTO PARRY SYSTEM v9  —  [Premium Only]
--  Logic: killer / non-local character attack animation starts -> parry instantly.
--  No distance-only parry. Rehooks after new round / new map / new killer / respawn.
--  Kept compact in one runtime table to avoid local register limit 200.
-- =====================================================================================
do
local _AP = _G.DYHUB_AP or {}
_G.DYHUB_AP = _AP

if _AP.Shutdown then pcall(_AP.Shutdown) end

_AP.UIS = UserInputService
_AP.VIM = VIM
_AP.Players = Players
_AP.RunService = RunService
_AP.Workspace = Workspace
_AP.LP = LocalPlayer
_AP.PG = PlayerGui
_AP.IconId = "92951359322494"
_AP.ParryCD = 0.095
_AP.BtnTTL = 0.20
_AP.ScanEvery = 0.035
_AP.RehookEvery = 0.55
_AP.HookTTL = 1.50
_AP.HookNearDist = settings.HookNearDist or 6
_AP.HPCarried = 60
_AP.HPDowned = 20
_AP.IsMobile = _AP.UIS.TouchEnabled and not _AP.UIS.KeyboardEnabled
_AP.cons = {}
_AP.charCons = {}
_AP.playerCons = {}
_AP.bound = setmetatable({}, { __mode = "k" })
_AP.seenTracks = setmetatable({}, { __mode = "k" })
_AP.lastAttack = setmetatable({}, { __mode = "k" })
_AP.btn = nil
_AP.btnAt = 0
_AP.hooks = {}
_AP.hooksAt = 0
_AP.scanTick = 0
_AP.rehookTick = 0
_AP.lastParry = 0
_AP._firing = false

_G.AutoParry = settings.AutoParry
_G.AutoParryMode = settings.AutoParryMode or "Fast"
_G.AutoParryRange = settings.AutoParryRange or 20

_AP.AnimIds = {
    ["139369275981139"] = true, ["110355011987939"] = true,
    ["135002183282873"] = true, ["121216847022485"] = true,
    ["105374834496520"] = true, ["111920872708571"] = true,
    ["118907603246885"] = true, ["78432063483146"]  = true,
    ["113255068724446"] = true, ["74968262036854"]  = true,
    ["129784271201071"] = true, ["132817836308238"] = true,
    ["112166042383605"] = true, ["122812055447896"] = true,
    ["117042998468241"] = true, ["133963973694098"] = true,
}

function _AP:disconnect(c)
    pcall(function() if c then c:Disconnect() end end)
end

function _AP:clearList(t)
    for k, v in pairs(t or {}) do
        if typeof(v) == "RBXScriptConnection" then self:disconnect(v) end
        t[k] = nil
    end
end

function _AP.Shutdown()
    local self = _G.DYHUB_AP
    if not self then return end
    self:clearList(self.cons)
    for _, t in pairs(self.charCons or {}) do self:clearList(t) end
    for _, t in pairs(self.playerCons or {}) do self:clearList(t) end
    self.charCons = {}
    self.playerCons = {}
    self.bound = setmetatable({}, { __mode = "k" })
    self.seenTracks = setmetatable({}, { __mode = "k" })
    self.lastAttack = setmetatable({}, { __mode = "k" })
    self.btn = nil
end

function _AP:addCon(c)
    self.cons[#self.cons + 1] = c
    return c
end

function _AP:addCharCon(char, key, c)
    self.charCons[char] = self.charCons[char] or {}
    if self.charCons[char][key] then self:disconnect(self.charCons[char][key]) end
    self.charCons[char][key] = c
    return c
end

function _AP:getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
end

function _AP:getOwner(char)
    return char and self.Players:GetPlayerFromCharacter(char) or nil
end

function _AP:isEnemyChar(char)
    local owner = self:getOwner(char)
    return owner and owner ~= self.LP
end

function _AP:getObjPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
        return p and p.Position or nil
    end
    local p = obj:FindFirstChildWhichIsA("BasePart", true)
    return p and p.Position or nil
end

function _AP:distToChar(char)
    local mr = self:getRoot(self.LP.Character)
    local kr = self:getRoot(char)
    if not mr or not kr then return math.huge end
    return (mr.Position - kr.Position).Magnitude
end

function _AP:visible(obj)
    local cur = obj
    while cur and cur ~= self.PG do
        if cur:IsA("GuiObject") and cur.Visible == false then return false end
        cur = cur.Parent
    end
    return true
end

function _AP:clickable(obj)
    local pg = self.LP:FindFirstChild("PlayerGui")
    if not obj or not pg then return nil end
    if obj:IsA("GuiButton") and self:visible(obj) then return obj end
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("GuiButton") and self:visible(d) then return d end
    end
    local cur, hop = obj.Parent, 0
    while cur and cur ~= pg and hop < 7 do
        if cur:IsA("GuiButton") and self:visible(cur) then return cur end
        cur = cur.Parent
        hop += 1
    end
    return obj:IsA("GuiObject") and self:visible(obj) and obj or nil
end

function _AP:getBtn()
    local now = os.clock()
    if self.btn and self.btn.Parent and now - self.btnAt < self.BtnTTL then return self.btn end
    self.btn, self.btnAt = nil, now

    local pg = self.LP:FindFirstChild("PlayerGui")
    if not pg then return nil end

    local s = pg:FindFirstChild("Survivor-mob")
    local c = s and s:FindFirstChild("Controls")
    local b = c and c:FindFirstChild("Gui-mob")
    local cb = self:clickable(b)
    if cb then self.btn = cb return cb end

    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("GuiButton") or d:IsA("ImageButton") or d:IsA("ImageLabel") then
            local n, img = string.lower(d.Name or ""), ""
            pcall(function() img = tostring(d.Image or "") end)
            if n:find("parry", 1, true) or n:find("block", 1, true) or n:find("guard", 1, true) or img:find(self.IconId, 1, true) then
                cb = self:clickable(d)
                if cb then self.btn = cb return cb end
            end
        end
    end
    return nil
end

function _AP:hasStateFlag(obj, words)
    if not obj then return false end
    for _, w in ipairs(words) do
        local ok, attr = pcall(function() return obj:GetAttribute(w) end)
        if ok and attr then return true end
    end
    for _, d in ipairs(obj:GetDescendants()) do
        local n = string.lower(d.Name or "")
        for _, w in ipairs(words) do
            if n:find(string.lower(w), 1, true) then
                if d:IsA("BoolValue") and d.Value then return true end
                if d:IsA("StringValue") and tostring(d.Value):lower():find("true", 1, true) then return true end
            end
        end
    end
    return false
end

function _AP:getHooks()
    local now = os.clock()
    if now - self.hooksAt < self.HookTTL and #self.hooks > 0 then return self.hooks end
    local list = {}
    for _, d in ipairs(self.Workspace:GetDescendants()) do
        if (d.Name == "HookPoint" or d.Name == "Hook") and (d:IsA("BasePart") or d:IsA("Model")) then
            list[#list + 1] = d
        end
    end
    self.hooks, self.hooksAt = list, now
    return list
end

function _AP:nearHook(hrp)
    if not hrp then return false end
    for _, h in ipairs(self:getHooks()) do
        local pos = self:getObjPos(h)
        if pos and (hrp.Position - pos).Magnitude <= self.HookNearDist then return true end
    end
    return false
end

function _AP:canParry()
    local char = self.LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = self:getRoot(char)
    if not char or not hum or not hrp then return false end
    if hum.Health <= self.HPDowned then return false end
    if self:hasStateFlag(char, { "Downed", "IsDowned", "Knocked", "Carried", "BeingCarried", "Grabbed", "Hooked" }) then return false end
    if hum.Health <= self.HPCarried and self:nearHook(hrp) then return false end
    return true
end

function _AP:pressGui(btn)
    if not btn or not btn.Parent then return false end
    local p, s = btn.AbsolutePosition, btn.AbsoluteSize
    local x, y = p.X + s.X * 0.5, p.Y + s.Y * 0.5

    if btn:IsA("GuiButton") then
        pcall(function() if firesignal and btn.MouseButton1Click then firesignal(btn.MouseButton1Click) end end)
        pcall(function() if firesignal and btn.Activated then firesignal(btn.Activated) end end)
        pcall(function() btn:Activate() end)
    end

    if self.IsMobile then
        local didTouch = false
        pcall(function()
            if self.VIM.SendTouchEvent then
                self.VIM:SendTouchEvent(0, Enum.UserInputState.Begin, Vector2.new(x, y))
                task.wait(0.006)
                self.VIM:SendTouchEvent(0, Enum.UserInputState.End, Vector2.new(x, y))
                didTouch = true
            end
        end)
        if not didTouch then
            pcall(function()
                self.VIM:SendTouchEvent(0, Enum.UserInputState.Begin, x, y)
                task.wait(0.006)
                self.VIM:SendTouchEvent(0, Enum.UserInputState.End, x, y)
                didTouch = true
            end)
        end
        if not didTouch then
            pcall(function()
                self.VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
                task.wait(0.006)
                self.VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
            end)
        end
    else
        pcall(function()
            self.VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.006)
            self.VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
        end)
    end
    return true
end

function _AP:pressPC()
    pcall(function()
        self.VIM:SendMouseButtonEvent(0, 0, 1, true, game, 1)
        task.wait(0.006)
        self.VIM:SendMouseButtonEvent(0, 0, 1, false, game, 1)
    end)
    pcall(function()
        self.VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.006)
        self.VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
end

function _AP:fire()
    if self._firing then return end
    self._firing = true
    task.spawn(function()
        local btn = self:getBtn()
        if btn then self:pressGui(btn) end
        if not self.IsMobile then self:pressPC() end
        task.wait(self.IsMobile and 0.030 or 0.018)
        self._firing = false
    end)
end

function _AP:getAnimId(track)
    local anim = track and track.Animation
    local id = anim and tostring(anim.AnimationId or "") or ""
    return id:match("%d+") or id
end

function _AP:looksAttackName(track)
    local anim = track and track.Animation
    local n = string.lower(tostring((track and track.Name) or "") .. " " .. tostring((anim and anim.Name) or ""))
    if n == "" then return false end
    if n:find("idle", 1, true) or n:find("walk", 1, true) or n:find("run", 1, true)
        or n:find("jump", 1, true) or n:find("fall", 1, true) or n:find("stun", 1, true)
        or n:find("hurt", 1, true) or n:find("react", 1, true) or n:find("down", 1, true)
        or n:find("carry", 1, true) or n:find("hook", 1, true) or n:find("dead", 1, true) then
        return false
    end
    return n:find("attack", 1, true) or n:find("slash", 1, true) or n:find("swing", 1, true)
        or n:find("lunge", 1, true) or n:find("stab", 1, true) or n:find("melee", 1, true)
        or n:find("m1", 1, true) or n:find("basic", 1, true) or n:find("knife", 1, true)
        or n:find("hit", 1, true)
end

function _AP:isAttackTrack(track)
    if not track then return false end
    local id = self:getAnimId(track)
    if id ~= "" and self.AnimIds[id] then return true end
    return self:looksAttackName(track)
end

function _AP:parryNow(char, tag)
    if not _G.AutoParry then return false end
    if not self:canParry() then return false end
    if char and not self:isEnemyChar(char) then return false end
    local range = _G.AutoParryRange or 20
    if char and self:distToChar(char) > range + 8 then return false end
    local now = os.clock()
    if now - self.lastParry < self.ParryCD then return false end
    self.lastParry = now
    self:fire()
    return true
end

function _AP:onAnim(char, track)
    if not char or not track then return end
    if not self:isEnemyChar(char) then return end
    if self.seenTracks[track] then return end
    if not self:isAttackTrack(track) then return end
    self.seenTracks[track] = true
    self.lastAttack[char] = os.clock()

    -- สำคัญ: animation เริ่ม -> parry ทันที ไม่มี threat score / ไม่ใช้ระยะอย่างเดียว
    self:parryNow(char, "anim")

    local mode = _G.AutoParryMode or "Fast"
    if mode == "Smart" or mode == "Predict" then
        local d = mode == "Predict" and 0.035 or 0.055
        task.delay(d, function()
            if _G.AutoParry and self.lastAttack[char] and os.clock() - self.lastAttack[char] <= 0.25 then
                self:parryNow(char, "retry")
            end
        end)
    end
end

function _AP:isHitbox(obj)
    local n = string.lower(obj and obj.Name or "")
    return n:find("wallhitboxcollider", 1, true) or n:find("attackhitbox", 1, true)
        or n:find("slashhitbox", 1, true) or n:find("weaponhitbox", 1, true)
end

function _AP:nearestEnemy(pos)
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(self.Players:GetPlayers()) do
        local char = plr ~= self.LP and plr.Character or nil
        local r = self:getRoot(char)
        if r then
            local d = (r.Position - pos).Magnitude
            if d < bestDist then best, bestDist = char, d end
        end
    end
    return best, bestDist
end

function _AP:onHitbox(obj)
    if not self:isHitbox(obj) then return end
    task.defer(function()
        if not _G.AutoParry then return end
        local pos = self:getObjPos(obj)
        local mr = self:getRoot(self.LP.Character)
        if not pos or not mr then return end
        if (mr.Position - pos).Magnitude > (_G.AutoParryRange or 20) + 8 then return end
        local kc, kd = self:nearestEnemy(pos)
        if kc and kd <= 18 then
            self.lastAttack[kc] = os.clock()
            self:parryNow(kc, "hitbox")
        end
    end)
end

function _AP:bindAnimObject(char, obj)
    if not char or not obj or self.bound[obj] then return end
    if not (obj:IsA("Humanoid") or obj:IsA("Animator")) then return end
    self.bound[obj] = true
    local ok, con = pcall(function()
        return obj.AnimationPlayed:Connect(function(track)
            self:onAnim(char, track)
        end)
    end)
    if ok and con then self:addCharCon(char, "Anim_" .. tostring(obj), con) end
end

function _AP:hookChar(char)
    if not char or not char.Parent or not self:isEnemyChar(char) then return end
    if not self.charCons[char] then
        self.charCons[char] = {}
        self:addCharCon(char, "Desc", char.DescendantAdded:Connect(function(obj)
            if obj:IsA("Humanoid") or obj:IsA("Animator") then
                self:bindAnimObject(char, obj)
            elseif self:isHitbox(obj) then
                self:onHitbox(obj)
            end
        end))
        self:addCharCon(char, "Gone", char.AncestryChanged:Connect(function(_, parent)
            if not parent then self:cleanChar(char) end
        end))
    end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Humanoid") or d:IsA("Animator") then self:bindAnimObject(char, d) end
    end
end

function _AP:cleanChar(char)
    self:clearList(self.charCons[char])
    self.charCons[char] = nil
    self.lastAttack[char] = nil
end

function _AP:hookPlayer(plr)
    if not plr or plr == self.LP or self.playerCons[plr] then return end
    self.playerCons[plr] = {}
    self.playerCons[plr].CharAdded = plr.CharacterAdded:Connect(function(char)
        task.wait(0.03)
        self:hookChar(char)
    end)
    self.playerCons[plr].CharRemoving = plr.CharacterRemoving:Connect(function(char)
        self:cleanChar(char)
    end)
    if plr.Character then self:hookChar(plr.Character) end
end

function _AP:scan()
    for _, plr in ipairs(self.Players:GetPlayers()) do
        if plr ~= self.LP then
            self:hookPlayer(plr)
            if plr.Character then self:hookChar(plr.Character) end
        end
    end
end

function _AP:scanTracks(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            for _, tr in ipairs(hum:GetPlayingAnimationTracks()) do
                if tr.IsPlaying and not self.seenTracks[tr] and self:isAttackTrack(tr) then
                    self:onAnim(char, tr)
                    return
                end
            end
        end)
    end
    for _, an in ipairs(char:GetDescendants()) do
        if an:IsA("Animator") then
            pcall(function()
                for _, tr in ipairs(an:GetPlayingAnimationTracks()) do
                    if tr.IsPlaying and not self.seenTracks[tr] and self:isAttackTrack(tr) then
                        self:onAnim(char, tr)
                        return
                    end
                end
            end)
        end
    end
end

function _AP:heartbeat(dt)
    if not _G.AutoParry then return end
    self.rehookTick += dt
    self.scanTick += dt
    if self.rehookTick >= self.RehookEvery then
        self.rehookTick = 0
        self:scan()
        self:getBtn()
    end
    if self.scanTick < self.ScanEvery then return end
    self.scanTick = 0
    for _, plr in ipairs(self.Players:GetPlayers()) do
        local char = plr ~= self.LP and plr.Character or nil
        if char and char.Parent then
            self:hookChar(char)
            self:scanTracks(char)
        end
    end
end

_AP:addCon(_AP.Players.PlayerAdded:Connect(function(plr) _AP:hookPlayer(plr) end))
_AP:addCon(_AP.Players.PlayerRemoving:Connect(function(plr)
    if _AP.playerCons[plr] then _AP:clearList(_AP.playerCons[plr]); _AP.playerCons[plr] = nil end
    if plr.Character then _AP:cleanChar(plr.Character) end
end))
_AP:addCon(_AP.Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Humanoid") or obj:IsA("Animator") then
        local char = obj:FindFirstAncestorOfClass("Model")
        if char then _AP:hookChar(char) end
    elseif _AP:isHitbox(obj) then
        _AP:onHitbox(obj)
    end
end))
_AP:addCon(_AP.RunService.Heartbeat:Connect(function(dt) _AP:heartbeat(dt) end))

task.defer(function() _AP:scan() end)

SurTab:Divider()
SurTab:Section({ Title = "Feature Survivor", Icon = "user" })

if isPremium then
    SurTab:Paragraph({
        Title = "Information: Parry Mode",
        Desc  = "• Fast = killer attack animation starts -> parry instantly\n• Smart = instant + one safe retry\n• Predict = instant + faster retry",
        Image = "rbxassetid://104487529937663", ImageSize = 30,
    })
    SurTab:Toggle({
        Title    = "Auto Parry",
        Desc     = "Parries instantly when killer attack animation starts. Rehooks every round/map/killer change.",
        Value    = settings.AutoParry,
        Callback = function(v)
            settings.AutoParry = v
            _G.AutoParry = v
            Config:Set("autoparry", v)
            Config:Save()
            if v then _AP:scan(); _AP:getBtn() end
            WindUI:Notify({ Title="Auto Parry", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "shield" or "shield-off" })
        end
    })
    SurTab:Dropdown({
        Title    = "Parry Mode",
        Values   = { "Fast", "Smart", "Predict" },
        Multi    = false,
        Value    = settings.AutoParryMode,
        Callback = function(v)
            settings.AutoParryMode = v
            _G.AutoParryMode = v
            Config:Set("autoparrymode", v)
            Config:Save()
            WindUI:Notify({ Title="Parry Mode", Content=v, Duration=2, Icon="settings" })
        end
    })
    SurTab:Slider({
        Title    = "Parry Range",
        Desc     = "Range for animation-trigger parry (studs)",
        Value    = { Min=5, Max=40, Default=settings.AutoParryRange },
        Step     = 1,
        Callback = function(v)
            settings.AutoParryRange = v
            _G.AutoParryRange = v
            Config:Set("autoparryrange", v)
            Config:Save()
        end
    })
else
    SurTab:Paragraph({
        Title = "[ Premium Only ] Auto Parry",
        Desc  = "This feature is for Premium members only",
        Image = "rbxassetid://104487529937663", ImageSize = 30,
    })
end

DYHUB_RUNTIME.ResetHookCache = function()
    if _G.DYHUB_AP then
        _G.DYHUB_AP.hooks = {}
        _G.DYHUB_AP.hooksAt = 0
        task.defer(function() _G.DYHUB_AP:scan(); _G.DYHUB_AP:getBtn() end)
    end
end
end -- AUTO PARRY do-scope

-- =====================================================================================
--  ESP SYSTEM  — [Fixed lag, fixed Pallet name, fixed BasePart gen]
-- =====================================================================================
do
local COLOR_SURVIVOR       = Color3.fromRGB(0,     0,  255)
local COLOR_MURDERER       = Color3.fromRGB(255,   0,    0)
local COLOR_GENERATOR_DONE = Color3.fromRGB(0,   255,    0)
local COLOR_GATE           = Color3.fromRGB(255, 255,  255)
local COLOR_PALLET         = Color3.fromRGB(255, 255,    0)
local COLOR_OUTLINE        = Color3.fromRGB(0,     0,    0)
local COLOR_WINDOW         = Color3.fromRGB(175, 215,  230)
local COLOR_HOOK           = Color3.fromRGB(255,   0,    0)
local COLOR_PATIENT        = Color3.fromRGB(255, 165,    0)

local espEnabled       = settings.EspEnabled
local espSurvivor      = settings.EspSurvivor
local espMurder        = settings.EspMurder
local espGenerator     = settings.EspGenerator
local espGate          = settings.EspGate
local espHook          = settings.EspHook
local espPallet        = settings.EspPallet
local espWindowEnabled = settings.EspWindow
local espPatient       = settings.EspPatient
local ShowName         = settings.ShowName
local ShowDistance     = settings.ShowDistance
local ShowHP           = settings.ShowHP
local ShowHighlight    = settings.ShowHighlight
local ShowPercent      = settings.ShowPercent
local ESP_MAX_DISTANCE = settings.EspMaxDistance

local espObjects = {}

-- ── world cache ───────────────────────────────────────────────────────────────────
local _worldESPCache      = {}
local _worldCacheDirty    = true
local _worldCacheScanBusy = false

local function invalidateWorldCache()
    _worldCacheDirty = true
end

local _invalidateScheduled = false
DYHUB_AddConnection(Workspace.DescendantAdded:Connect(function()
    if not _invalidateScheduled then
        _invalidateScheduled = true
        task.delay(2, function() invalidateWorldCache(); _invalidateScheduled = false end)
    end
end))
DYHUB_AddConnection(Workspace.DescendantRemoving:Connect(function()
    if not _invalidateScheduled then
        _invalidateScheduled = true
        task.delay(2, function() invalidateWorldCache(); _invalidateScheduled = false end)
    end
end))

-- [Fix] rebuildWorldCacheAsync: รองรับ BasePart Generator ด้วย + fix Pallet name
local function rebuildWorldCacheAsync()
    if _worldCacheScanBusy then return end
    _worldCacheScanBusy = true
    _worldCacheDirty    = false
    task.spawn(function()
        local newCache = {}
        local ok = pcall(function()
            for _, desc in ipairs(Workspace:GetDescendants()) do
                -- รองรับทั้ง Model และ BasePart
                local isModel    = desc:IsA("Model")
                local isBasePart = desc:IsA("BasePart")
                if not isModel and not isBasePart then continue end
                local parentOk, hasParent = pcall(function() return desc.Parent ~= nil end)
                if not parentOk or not hasParent then continue end
                local n = desc.Name
                local t = nil
                if n == "Generator"                   then t = "Generator"
                elseif n == "Gate"                    then t = "Gate"
                elseif n == "Hook"                    then t = "Hook"
                elseif n == "Palletwrong"             then t = "Pallet"   -- [Fix] name ถูกต้อง
                elseif n == "Window"                  then t = "Window"
                elseif n:match("^[Ss][Cc][Pp]%d*$")  then t = "Patient"
                end
                if t then table.insert(newCache, { obj=desc, t=t }) end
            end
        end)
        if ok then _worldESPCache = newCache end
        _worldCacheScanBusy = false
    end)
end

-- ── Generator helpers ─────────────────────────────────────────────────────────────
local _cachedGenFolders = nil
local function _invalidateGenCache() _cachedGenFolders = nil end

-- [Fix] รองรับ BasePart generator ด้วย
local function getFolderGenerator()
    if _cachedGenFolders then return _cachedGenFolders end
    local list = {}
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "Generator" and (desc:IsA("Model") or desc:IsA("BasePart")) then
            list[#list+1] = desc
        end
    end
    _cachedGenFolders = list
    return list
end

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
                    progress = child.Value; break
                end
            end
        end
    end
    progress = progress > 1 and progress / 100 or progress
    return math.clamp(progress, 0, 1)
end

local function getProgressColor(p)
    if p < 0.5 then
        local t = p / 0.5
        return Color3.fromRGB(math.floor(255-(255-153)*t), 255, math.floor(255-(255-153)*t))
    else
        local t = (p-0.5)/0.5
        return Color3.fromRGB(math.floor(153*(1-t)), 255, math.floor(153*(1-t)))
    end
end

local function generatorFinished(gen)
    return getGeneratorProgress(gen) >= 0.99
        or gen:FindFirstChild("Finished") ~= nil
        or gen:FindFirstChild("Repaired") ~= nil
end

-- ── ESP instance helpers ───────────────────────────────────────────────────────────
local function removeESP(obj)
    local data = espObjects[obj]
    if not data then return end
    pcall(function() if data.highlight and data.highlight.Parent then data.highlight:Destroy() end end)
    pcall(function() if data.bill and data.bill.Parent then data.bill:Destroy() end end)
    espObjects[obj] = nil
end

local function createESP(obj, baseColor)
    if not obj then return end
    local ok, hasParent = pcall(function() return obj.Parent ~= nil end)
    if not ok or not hasParent then return end
    if obj.Name == "Lobby" then return end

    local data = espObjects[obj]
    if data then
        pcall(function()
            if data.highlight then
                data.highlight.FillColor    = baseColor
                data.highlight.OutlineColor = baseColor
                data.highlight.Enabled      = ShowHighlight
            end
            data.nameLabel.TextColor3 = baseColor
            data.hpLabel.TextColor3   = baseColor
            data.distLabel.TextColor3 = baseColor
            data.color = baseColor
        end)
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Adornee             = obj
    highlight.FillColor           = baseColor
    highlight.FillTransparency    = 0.8
    highlight.OutlineColor        = baseColor
    highlight.OutlineTransparency = 0.1
    highlight.Enabled             = ShowHighlight
    highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    pcall(function() highlight.Parent = obj end)

    local bill = Instance.new("BillboardGui")
    bill.Size        = UDim2.new(0, 200, 0, 60)
    bill.Adornee     = obj
    bill.AlwaysOnTop = true
    bill.StudsOffset = Vector3.new(0, 2, 0)
    pcall(function() bill.Parent = obj end)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 1
    frame.Parent = bill

    local function makeLabel(ypos)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,0.33,0)
        lbl.Position = UDim2.new(0,0,ypos,0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextSize = 14
        lbl.TextColor3 = baseColor
        lbl.TextStrokeColor3 = COLOR_OUTLINE
        lbl.TextStrokeTransparency = 0
        lbl.Text = ""
        lbl.Parent = frame
        return lbl
    end

    espObjects[obj] = {
        highlight = highlight,
        bill      = bill,
        nameLabel = makeLabel(0),
        hpLabel   = makeLabel(0.33),
        distLabel = makeLabel(0.66),
        color     = baseColor,
    }
end

local function setObjectLabels(data, col, nameText, showName, hpText, showHp, distText, showDist)
    if not data then return end
    pcall(function()
        data.nameLabel.Text    = showName and (nameText or "") or ""
        data.nameLabel.Visible = showName and nameText ~= nil and nameText ~= ""
        data.nameLabel.TextColor3 = col
        data.hpLabel.Text    = showHp and (hpText or "") or ""
        data.hpLabel.Visible = showHp and hpText ~= nil and hpText ~= ""
        data.hpLabel.TextColor3 = col
        data.distLabel.Text    = showDist and (distText or "") or ""
        data.distLabel.Visible = showDist and distText ~= nil and distText ~= ""
        data.distLabel.TextColor3 = col
        local row = 0
        if data.nameLabel.Visible then data.nameLabel.Position = UDim2.new(0,0,row*0.33,0); row+=1 end
        if data.hpLabel.Visible   then data.hpLabel.Position   = UDim2.new(0,0,row*0.33,0); row+=1 end
        if data.distLabel.Visible then data.distLabel.Position = UDim2.new(0,0,row*0.33,0) end
    end)
end

-- ── Player ESP ─────────────────────────────────────────────────────────────────────
local _playerESPAccum = 0
local _worldESPAccum  = 0
local PLAYER_ESP_INTERVAL = 0.5
local WORLD_ESP_INTERVAL  = 2.0
local _worldScanBusy = false

local function updatePlayerESP(hrp)
    if not espEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local pChar = player.Character
        if not pChar then continue end
        local ok, isValid = pcall(function() return pChar.Parent ~= nil end)
        if not ok or not isValid then continue end
        if pChar.Name == "Lobby" then continue end

        local pRoot = pChar:FindFirstChild("HumanoidRootPart")
        local pHum  = pChar:FindFirstChildOfClass("Humanoid")
        local dist  = pRoot and math.floor((hrp.Position - pRoot.Position).Magnitude) or math.huge
        local isMurderer = isKillerChar(pChar)
        local shouldShow = (isMurderer and espMurder) or (not isMurderer and espSurvivor)

        if not shouldShow or dist > ESP_MAX_DISTANCE then
            local data = espObjects[pChar]
            if data then
                pcall(function()
                    if data.bill      then data.bill.Enabled      = false end
                    if data.highlight then data.highlight.Enabled = false end
                end)
            end
            if not shouldShow then removeESP(pChar) end
            continue
        end

        local col = isMurderer and COLOR_MURDERER or COLOR_SURVIVOR
        createESP(pChar, col)
        local data = espObjects[pChar]
        if data then
            local nameText = ShowName and player.Name or nil
            local hpText   = (ShowHP and pHum) and ("[ "..math.floor(pHum.Health).." HP ]") or nil
            local distText = ShowDistance and ("[ "..dist.." MM ]") or nil
            setObjectLabels(data, col, nameText, ShowName, hpText, ShowHP and pHum ~= nil, distText, ShowDistance)
            pcall(function()
                if data.bill      then data.bill.Enabled      = true end
                if data.highlight then data.highlight.Enabled = ShowHighlight end
            end)
        end
    end
end

-- ── World ESP (off-thread) ────────────────────────────────────────────────────────
local function hideESPData(desc)
    local d = espObjects[desc]
    if d then
        pcall(function()
            if d.bill then d.bill.Enabled = false end
            if d.highlight then d.highlight.Enabled = false end
        end)
    end
end

local function processWorldESPEntry(entry, myPos)
    local desc = entry and entry.obj
    local t = entry and entry.t
    local ok2, valid2 = pcall(function() return desc and desc.Parent ~= nil end)
    if not ok2 or not valid2 then removeESP(desc); return end

    local part = nil
    pcall(function()
        if desc:IsA("BasePart") then
            part = desc
        elseif desc:IsA("Model") then
            part = desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart")
        end
    end)
    if not part then return end

    local dist = math.floor((myPos - part.Position).Magnitude)
    if t == "Generator" then
        if not espGenerator then removeESP(desc); return end
        if dist > ESP_MAX_DISTANCE then hideESPData(desc); return end

        local okDone, isDone = pcall(generatorFinished, desc)
        isDone = okDone and isDone or false
        local prog = 0
        pcall(function() prog = getGeneratorProgress(desc) end)
        local col = isDone and COLOR_GENERATOR_DONE or getProgressColor(prog)
        createESP(desc, col)
        local data = espObjects[desc]
        if data then
            setObjectLabels(data, col, ShowName and "Generator" or nil, ShowName, ShowPercent and ("[ "..math.floor(prog*100).."% ]") or nil, ShowPercent, ShowDistance and ("[ "..dist.." MM ]") or nil, ShowDistance)
            pcall(function()
                if data.bill then data.bill.Enabled = true end
                if data.highlight then data.highlight.Enabled = ShowHighlight end
            end)
        end

    elseif t == "Gate" then
        if not espGate then removeESP(desc); return end
        if dist > ESP_MAX_DISTANCE then hideESPData(desc); return end
        createESP(desc, COLOR_GATE)
        local data = espObjects[desc]
        if data then
            setObjectLabels(data, COLOR_GATE, ShowName and "Gate" or nil, ShowName, nil, false, ShowDistance and ("[ "..dist.." MM ]") or nil, ShowDistance)
            pcall(function() if data.bill then data.bill.Enabled = true end; if data.highlight then data.highlight.Enabled = ShowHighlight end end)
        end

    elseif t == "Hook" then
        if not espHook then removeESP(desc); return end
        if dist > ESP_MAX_DISTANCE then hideESPData(desc); return end
        createESP(desc, COLOR_HOOK)
        local data = espObjects[desc]
        if data then
            setObjectLabels(data, COLOR_HOOK, ShowName and "Hook" or nil, ShowName, nil, false, ShowDistance and ("[ "..dist.." MM ]") or nil, ShowDistance)
            pcall(function() if data.bill then data.bill.Enabled = true end; if data.highlight then data.highlight.Enabled = ShowHighlight end end)
        end

    elseif t == "Pallet" then
        if not espPallet then removeESP(desc); return end
        if dist > ESP_MAX_DISTANCE then hideESPData(desc); return end
        createESP(desc, COLOR_PALLET)
        local data = espObjects[desc]
        if data then
            setObjectLabels(data, COLOR_PALLET, ShowName and "Pallet" or nil, ShowName, nil, false, ShowDistance and ("[ "..dist.." MM ]") or nil, ShowDistance)
            pcall(function() if data.bill then data.bill.Enabled = true end; if data.highlight then data.highlight.Enabled = ShowHighlight end end)
        end

    elseif t == "Window" then
        if not espWindowEnabled then removeESP(desc); return end
        if dist > ESP_MAX_DISTANCE then hideESPData(desc); return end
        createESP(desc, COLOR_WINDOW)
        local data = espObjects[desc]
        if data then
            setObjectLabels(data, COLOR_WINDOW, ShowName and "Window" or nil, ShowName, nil, false, ShowDistance and ("[ "..dist.." MM ]") or nil, ShowDistance)
            pcall(function() if data.bill then data.bill.Enabled = true end; if data.highlight then data.highlight.Enabled = ShowHighlight end end)
        end

    elseif t == "Patient" then
        if not espPatient then removeESP(desc); return end
        if dist > ESP_MAX_DISTANCE then hideESPData(desc); return end
        createESP(desc, COLOR_PATIENT)
        local data = espObjects[desc]
        if data then
            setObjectLabels(data, COLOR_PATIENT, ShowName and "Patient" or nil, ShowName, nil, false, ShowDistance and ("[ "..dist.." MM ]") or nil, ShowDistance)
            pcall(function() if data.bill then data.bill.Enabled = true end; if data.highlight then data.highlight.Enabled = ShowHighlight end end)
        end
    end
end

local function updateWorldESPAsync(hrp)
    if _worldScanBusy then return end
    _worldScanBusy = true
    if _worldCacheDirty then rebuildWorldCacheAsync() end
    task.spawn(function()
        local myPos = hrp.Position
        local processed = 0

        for _, entry in ipairs(_worldESPCache) do
            processWorldESPEntry(entry, myPos)
            processed += 1
            if processed % 35 == 0 then task.wait() end
        end

        for obj in pairs(espObjects) do
            local ok2, valid2 = pcall(function() return obj and obj.Parent ~= nil end)
            if not ok2 or not valid2 then removeESP(obj) end
        end
        _worldScanBusy = false
    end)
end

-- ── Heartbeat ─────────────────────────────────────────────────────────────────────
DYHUB_AddConnection(RunService.Heartbeat:Connect(function(dt)
    if not espEnabled then return end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    _playerESPAccum += dt
    if _playerESPAccum >= PLAYER_ESP_INTERVAL then
        _playerESPAccum = 0
        pcall(updatePlayerESP, hrp)
    end
    _worldESPAccum += dt
    if _worldESPAccum >= WORLD_ESP_INTERVAL then
        _worldESPAccum = 0
        pcall(updateWorldESPAsync, hrp)
    end
end))

DYHUB_AddConnection(Players.PlayerRemoving:Connect(function(player)
    if player.Character then removeESP(player.Character) end
end))
DYHUB_AddConnection(Players.PlayerAdded:Connect(function(player)
    DYHUB_AddConnection(player.CharacterRemoving:Connect(function(char) removeESP(char) end))
end))
for _, player in ipairs(Players:GetPlayers()) do
    DYHUB_AddConnection(player.CharacterRemoving:Connect(function(char) removeESP(char) end))
end

local function clearAllESP()
    for obj in pairs(espObjects) do removeESP(obj) end
    _worldESPCache   = {}
    _worldCacheDirty = true
end

-- ====================== ESP UI ======================
EspTab:Section({ Title = "Feature Esp", Icon = "eye" })
EspTab:Toggle({
    Title = "Enable ESP", Desc = "Master toggle for all ESP (low-lag design)", Value = espEnabled,
    Callback = function(v)
        espEnabled = v; settings.EspEnabled = v; Config:Set("espEnabled", v); Config:Save()
        if not espEnabled then clearAllESP()
        else _worldCacheDirty = true end
    end
})
EspTab:Input({
    Title = "Set ESP Distance", Default = tostring(ESP_MAX_DISTANCE), Placeholder = "Default: 1500",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            ESP_MAX_DISTANCE = num; settings.EspMaxDistance = num
            Config:Set("ESP_MAX_DISTANCE", num); Config:Save()
        else warn("Invalid number!") end
    end
})

EspTab:Section({ Title = "Esp Role", Icon = "user" })
EspTab:Toggle({ Title = "ESP Survivor", Desc = "ESP the Survivor locations through walls", Value = espSurvivor,
    Callback = function(v) espSurvivor = v; settings.EspSurvivor = v; Config:Set("espSurvivor", v); Config:Save() end })
EspTab:Toggle({ Title = "ESP Killer", Desc = "ESP the Killer location through walls", Value = espMurder,
    Callback = function(v) espMurder = v; settings.EspMurder = v; Config:Set("espMurder", v); Config:Save() end })

EspTab:Section({ Title = "Esp Engine", Icon = "biceps-flexed" })
EspTab:Toggle({ Title = "ESP Generator", Desc = "ESP the Generator location through walls", Value = espGenerator,
    Callback = function(v)
        espGenerator = v; settings.EspGenerator = v; Config:Set("espGenerator", v); Config:Save()
        if not v then for obj in pairs(espObjects) do if obj.Name == "Generator" then removeESP(obj) end end end
    end })
EspTab:Toggle({ Title = "ESP Gate", Desc = "ESP the Gate locations through walls", Value = espGate,
    Callback = function(v)
        espGate = v; settings.EspGate = v; Config:Set("espGate", v); Config:Save()
        if not v then for obj in pairs(espObjects) do if obj.Name == "Gate" then removeESP(obj) end end end
    end })

EspTab:Section({ Title = "Esp Object", Icon = "package" })
EspTab:Toggle({ Title = "ESP Pallet", Desc = "ESP the Pallet locations through walls", Value = espPallet,
    Callback = function(v)
        espPallet = v; settings.EspPallet = v; Config:Set("espPallet", v); Config:Save()
        if not v then for obj in pairs(espObjects) do if obj.Name == "Palletwrong" then removeESP(obj) end end end
    end })
EspTab:Toggle({ Title = "ESP Hook", Desc = "ESP the Hook locations through walls", Value = espHook,
    Callback = function(v)
        espHook = v; settings.EspHook = v; Config:Set("espHook", v); Config:Save()
        if not v then for obj in pairs(espObjects) do if obj.Name == "Hook" then removeESP(obj) end end end
    end })
EspTab:Toggle({ Title = "ESP Window", Desc = "ESP the Window locations through walls", Value = espWindowEnabled,
    Callback = function(v)
        espWindowEnabled = v; settings.EspWindow = v; Config:Set("espWindow", v); Config:Save()
        if not v then for obj in pairs(espObjects) do if obj.Name == "Window" then removeESP(obj) end end end
    end })
EspTab:Toggle({ Title = "ESP Patient", Desc = "ESP the Patient (SCP) locations through walls", Value = espPatient,
    Callback = function(v)
        espPatient = v; settings.EspPatient = v; Config:Set("espPatient", v); Config:Save()
        if not v then for obj in pairs(espObjects) do if obj.Name:match("^[Ss][Cc][Pp]%d*$") then removeESP(obj) end end end
    end })

EspTab:Section({ Title = "Esp Settings", Icon = "settings" })
EspTab:Toggle({ Title = "Show Name", Desc = "Displays object and player names", Value = ShowName,
    Callback = function(v) ShowName = v; settings.ShowName = v; Config:Set("ShowName", v); Config:Save() end })
EspTab:Toggle({ Title = "Show Distance", Desc = "Shows the distance between you and ESP targets", Value = ShowDistance,
    Callback = function(v) ShowDistance = v; settings.ShowDistance = v; Config:Set("ShowDistance", v); Config:Save() end })
EspTab:Toggle({ Title = "Show Health", Desc = "Displays player health values", Value = ShowHP,
    Callback = function(v) ShowHP = v; settings.ShowHP = v; Config:Set("ShowHP", v); Config:Save() end })
EspTab:Toggle({ Title = "Show Highlight", Desc = "Adds highlights around ESP targets", Value = ShowHighlight,
    Callback = function(v)
        ShowHighlight = v; settings.ShowHighlight = v; Config:Set("ShowHighlight", v); Config:Save()
        for _, data in pairs(espObjects) do
            pcall(function() if data.highlight then data.highlight.Enabled = v end end)
        end
    end })
EspTab:Toggle({ Title = "Show Percent (Generator)", Desc = "Displays generator percent values", Value = ShowPercent,
    Callback = function(v) ShowPercent = v; settings.ShowPercent = v; Config:Set("ShowPercent", v); Config:Save() end })

DYHUB_RUNTIME.InvalidateGenCache = _invalidateGenCache
DYHUB_RUNTIME.InvalidateWorldCache = invalidateWorldCache
DYHUB_RUNTIME.GetFolderGenerator = getFolderGenerator
DYHUB_RUNTIME.GetGeneratorProgress = getGeneratorProgress
DYHUB_RUNTIME.GeneratorFinished = generatorFinished
DYHUB_RUNTIME.RebuildWorldCacheAsync = rebuildWorldCacheAsync
DYHUB_RUNTIME.IsEspEnabled = function()
    return espEnabled
end
end -- ESP SYSTEM do-scope

local function _invalidateGenCache()
    if DYHUB_RUNTIME.InvalidateGenCache then return DYHUB_RUNTIME.InvalidateGenCache() end
end
local function invalidateWorldCache()
    if DYHUB_RUNTIME.InvalidateWorldCache then return DYHUB_RUNTIME.InvalidateWorldCache() end
end
local function getFolderGenerator()
    if DYHUB_RUNTIME.GetFolderGenerator then return DYHUB_RUNTIME.GetFolderGenerator() end
    return {}
end
local function getGeneratorProgress(gen)
    if DYHUB_RUNTIME.GetGeneratorProgress then return DYHUB_RUNTIME.GetGeneratorProgress(gen) end
    return 0
end
local function generatorFinished(gen)
    if DYHUB_RUNTIME.GeneratorFinished then return DYHUB_RUNTIME.GeneratorFinished(gen) end
    return false
end
local function rebuildWorldCacheAsync()
    if DYHUB_RUNTIME.RebuildWorldCacheAsync then return DYHUB_RUNTIME.RebuildWorldCacheAsync() end
end

-- ====================== MAIN TAB ======================
do
MainTab:Section({ Title = "Feature Gameplay", Icon = "target" })
MainTab:Button({
    Title = "Aimbot (NEW)", Desc = "Advanced survivor aimbot settings and lock",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/Y6ui9r3d/raw"))()
    end
})

local CrosshairEnabled = settings.CrosshairEnabled
local function CreateCrosshair()
    if PlayerGui:FindFirstChild("CrosshairGUI") then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "CrosshairGUI"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true; sg.Parent = PlayerGui
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0,5,0,5); f.AnchorPoint = Vector2.new(0.5,0.5)
    f.Position = UDim2.new(0.5,0,0.5,0); f.BackgroundColor3 = Color3.new(1,1,1)
    f.BackgroundTransparency = 0.3; f.BorderSizePixel = 0; f.ZIndex = 999; f.Parent = sg
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = f
end
local function RemoveCrosshair()
    local gui = PlayerGui:FindFirstChild("CrosshairGUI")
    if gui then gui:Destroy() end
end
DYHUB_AddConnection(PlayerGui.ChildRemoved:Connect(function(child)
    if child.Name == "CrosshairGUI" and CrosshairEnabled then task.defer(CreateCrosshair) end
end))
if CrosshairEnabled then CreateCrosshair() end

MainTab:Toggle({
    Title = "Enable Cursor (Recommended)", Desc = "Creates a center screen cursor for aiming",
    Value = CrosshairEnabled,
    Callback = function(state)
        CrosshairEnabled = state; settings.CrosshairEnabled = state
        Config:Set("CrosshairEnabled", state); Config:Save()
        if state then CreateCrosshair() else RemoveCrosshair() end
    end
})

local bypassGateEnabled = settings.BypassGateEnabled
local function gatherGates()
    local gates = {}
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "Gate" and desc:IsA("Model") then gates[#gates+1] = desc end
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
            if box       then box.CanCollide         = true end
        end
    end
end
if bypassGateEnabled then setGateState(true) end

MainTab:Section({ Title = "Feature Bypass", Icon = "lock-open" })
MainTab:Toggle({
    Title = "Bypass Gate (Open Gate)", Desc = "Lets you walk through opened gates",
    Value = bypassGateEnabled,
    Callback = function(state)
        bypassGateEnabled = state; settings.BypassGateEnabled = state
        Config:Set("bypassGateEnabled", state); Config:Save()
        setGateState(state)
    end
})

local fullBrightEnabled = settings.FullBrightEnabled
local noFogEnabled      = settings.NoFogEnabled
local _fullBrightConn, _noFogConn

local function startFullBright()
    if _fullBrightConn then _fullBrightConn:Disconnect() end
    _fullBrightConn = DYHUB_AddConnection(RunService.RenderStepped:Connect(function()
        if not fullBrightEnabled then _fullBrightConn:Disconnect(); _fullBrightConn = nil; return end
        Lighting.Brightness = 2; Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(255,255,255)
    end))
end
local function stopFullBright()
    if _fullBrightConn then _fullBrightConn:Disconnect(); _fullBrightConn = nil end
    Lighting.Brightness = 1; Lighting.ClockTime = 12
    Lighting.Ambient = Color3.fromRGB(128,128,128)
end
local function startNoFog()
    if _noFogConn then _noFogConn:Disconnect() end
    _noFogConn = DYHUB_AddConnection(RunService.RenderStepped:Connect(function()
        if not noFogEnabled then _noFogConn:Disconnect(); _noFogConn = nil; return end
        local atm = Lighting:FindFirstChild("Atmosphere")
        if atm then atm.Density = 0 end
    end))
end
local function stopNoFog()
    if _noFogConn then _noFogConn:Disconnect(); _noFogConn = nil end
    local atm = Lighting:FindFirstChild("Atmosphere")
    if atm then atm.Density = 0.5 end
end
if fullBrightEnabled then startFullBright() end
if noFogEnabled      then startNoFog() end

MainTab:Section({ Title = "Feature Visual", Icon = "lightbulb" })
MainTab:Toggle({
    Title = "Full Bright", Desc = "Brightens the entire map for better visibility",
    Value = fullBrightEnabled,
    Callback = function(v)
        fullBrightEnabled = v; settings.FullBrightEnabled = v
        Config:Set("fullBrightEnabled", v); Config:Save()
        if v then startFullBright() else stopFullBright() end
    end
})
MainTab:Toggle({
    Title = "No Fog", Desc = "Removes fog and improves map clarity",
    Value = noFogEnabled,
    Callback = function(v)
        noFogEnabled = v; settings.NoFogEnabled = v
        Config:Set("noFogEnabled", v); Config:Save()
        if v then startNoFog() else stopNoFog() end
    end
})

MainTab:Section({ Title = "Misc", Icon = "settings" })
local AntiAFK_main    = settings.AntiAFK
local _antiAfkThread
local function startAntiAFK()
    if _antiAfkThread then task.cancel(_antiAfkThread); _antiAfkThread = nil end
    _antiAfkThread = DYHUB_TrackThread(task.spawn(function()
        while AntiAFK_main do
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(math.random(150, 270))
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(math.random(150, 270))
        end
    end))
end
if AntiAFK_main then startAntiAFK() end
MainTab:Toggle({
    Title = "Anti AFK", Desc = "Prevents automatic AFK disconnection.", Value = AntiAFK_main,
    Callback = function(state)
        AntiAFK_main = state; settings.AntiAFK = state
        Config:Set("AntiAFK_main", state); Config:Save()
        if state then startAntiAFK()
        elseif _antiAfkThread then task.cancel(_antiAfkThread); _antiAfkThread = nil end
    end
})
end -- MAIN TAB do-scope

-- =====================================================================================
-- =====================================================================================
--  GENERATOR SYSTEM v4 LITE
--  [Fixed] lag/freeze by removing repeated full GetDescendants scans from active loops
--  [Improved] cached generator list, cached repair points, cached progress, throttled GUI scan
--  [Improved] debounced map invalidation, slower repair loop, no point scan every skill tick
-- =====================================================================================
do
SurTab:Section({ Title = "Feature Generator", Icon = "zap" })

settings.AutoGenRepair     = Config:Get("AutoGenRepair", settings.AutoGenRepair or false)
settings.AutoSkillPerfect  = Config:Get("AutoSkillPerfect", settings.AutoSkillPerfect or false)
settings.AutoSkillNeutral  = Config:Get("AutoSkillNeutral", settings.AutoSkillNeutral or false)

local GEN = {
    repairPoint       = nil,
    repairModel       = nil,
    lastRootPos       = nil,
    lastTeleportAt    = 0,
    lastRepairAt      = 0,
    lastScanAt        = 0,
    lastSkillAt       = 0,
    lastPickAt        = 0,
    lastActiveScanAt  = 0,
    lastGuiScanAt     = 0,
    lastMoveCheckAt   = 0,

    cancelDB          = false,
    skillDB           = false,
    repairThread      = nil,
    skillThread       = nil,

    cache             = {},
    pointCache        = {},
    progressCache     = {},
    cacheDirty        = true,
    invalidateQueued  = false,

    cachedSkillGui    = nil,
    cachedSkillCheck  = nil,

    lastPickGen       = nil,
    lastPickPoint     = nil,
    lastPickDist      = math.huge,

    ignoreMoveUntil   = 0,
    safeDistance      = 30,
    repairRetryDelay  = 1.75,
    scanDelay         = 4.00,
    pickCooldown      = 0.65,
    activeScanDelay   = 0.70,
    repairLoopDelay   = 0.35,
    skillLoopDelay    = 0.085,
    guiScanDelay      = 0.25,
    nearDistance      = 8,
}

local skillRemote, repairRemote

local function notify(title, content, icon)
    pcall(function()
        WindUI:Notify({ Title = title, Content = content, Duration = 4, Icon = icon or "zap" })
    end)
end

local function clearTable(t)
    for k in pairs(t) do t[k] = nil end
end

local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function getAnyBasePart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    return obj:FindFirstChildWhichIsA("BasePart", true)
end

local function lowerName(obj)
    return obj and tostring(obj.Name or ""):lower() or ""
end

local function isGenName(n)
    return n == "generator" or n:find("generator", 1, true) ~= nil
end

local function isPointName(n)
    return n:find("generatorpoint", 1, true) ~= nil
        or n:find("repairpoint", 1, true) ~= nil
        or n:find("repair", 1, true) ~= nil
        or n:match("^point%d*$") ~= nil
        or n:find("prompt", 1, true) ~= nil
end

local function resolveRemotes()
    if skillRemote and skillRemote.Parent and repairRemote and repairRemote.Parent then
        return true
    end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local genFolder = remotes and remotes:FindFirstChild("Generator")

    skillRemote = genFolder and genFolder:FindFirstChild("SkillCheckResultEvent")
    repairRemote = genFolder and genFolder:FindFirstChild("RepairEvent")

    if not skillRemote or not repairRemote then
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            if d.Name == "SkillCheckResultEvent" and d:IsA("RemoteEvent") then skillRemote = d end
            if d.Name == "RepairEvent" and d:IsA("RemoteEvent") then repairRemote = d end
        end
    end

    return skillRemote ~= nil and repairRemote ~= nil
end

local function invalidateGenCache()
    GEN.cacheDirty = true
    clearTable(GEN.cache)
    clearTable(GEN.pointCache)
    clearTable(GEN.progressCache)
    GEN.lastPickGen = nil
    GEN.lastPickPoint = nil
    GEN.lastPickDist = math.huge

    if _invalidateGenCache then pcall(_invalidateGenCache) end
    if DYHUB_RUNTIME.IsEspEnabled and DYHUB_RUNTIME.IsEspEnabled() and invalidateWorldCache then
        pcall(invalidateWorldCache)
    end
end

local function scheduleGenInvalidate()
    if GEN.invalidateQueued then return end
    GEN.invalidateQueued = true
    task.delay(1.25, function()
        GEN.invalidateQueued = false
        invalidateGenCache()
    end)
end

local function findGenAncestor(obj)
    local cur = obj
    while cur and cur ~= Workspace do
        if cur:IsA("Model") and isGenName(lowerName(cur)) then
            return cur
        end
        cur = cur.Parent
    end
    return nil
end

local function addGen(list, seen, gen)
    if gen and gen.Parent and not seen[gen] then
        seen[gen] = true
        list[#list+1] = gen
    end
end

local function addPoint(gen, point)
    if not gen or not point or not point.Parent then return end
    local points = GEN.pointCache[gen]
    if not points then
        points = {}
        GEN.pointCache[gen] = points
    end
    for _, p in ipairs(points) do
        if p == point then return end
    end
    points[#points+1] = point
end

local function scanRootForGenerators(rootObj, found, seen)
    if not rootObj then return end
    local count = 0

    for _, obj in ipairs(rootObj:GetDescendants()) do
        count += 1

        local isModel = obj:IsA("Model")
        local isPart  = obj:IsA("BasePart")
        if isModel or isPart then
            local n = lowerName(obj)

            if isModel and isGenName(n) then
                addGen(found, seen, obj)

            elseif isPart and isGenName(n) then
                local gen = findGenAncestor(obj) or obj
                addGen(found, seen, gen)

            elseif isPart and isPointName(n) then
                local gen = findGenAncestor(obj)
                if gen then
                    addGen(found, seen, gen)
                    addPoint(gen, obj)
                end
            end
        end

        if count % 300 == 0 then
            task.wait()
        end
    end
end

local function getGeneratorList(force)
    local now = os.clock()
    if not force and not GEN.cacheDirty and (now - GEN.lastScanAt) < GEN.scanDelay and #GEN.cache > 0 then
        return GEN.cache
    end

    GEN.lastScanAt = now
    GEN.cacheDirty = false
    clearTable(GEN.cache)
    clearTable(GEN.pointCache)
    clearTable(GEN.progressCache)

    local found, seen = {}, {}

    -- ใช้ cache จาก ESP ก่อน ถ้ามี จะเบากว่า scan Workspace เอง
    local ok, external = pcall(getFolderGenerator)
    if ok and type(external) == "table" then
        for _, gen in ipairs(external) do
            if gen and gen.Parent then
                addGen(found, seen, gen)
            end
        end
    end

    -- scan เฉพาะ Map ก่อน ลด freeze ใน workspace ใหญ่
    local map = Workspace:FindFirstChild("Map")
    if map then
        scanRootForGenerators(map, found, seen)
    end

    -- fallback เฉพาะตอน Map ไม่มี gen
    if #found == 0 then
        scanRootForGenerators(Workspace, found, seen)
    end

    GEN.cache = found
    return GEN.cache
end

local function getRepairPoints(gen)
    if not gen or not gen.Parent then return {} end

    local cached = GEN.pointCache[gen]
    if cached and #cached > 0 then
        local alive = {}
        for _, p in ipairs(cached) do
            if p and p.Parent then
                alive[#alive+1] = p
            end
        end
        if #alive > 0 then
            GEN.pointCache[gen] = alive
            return alive
        end
    end

    local points = {}
    if gen:IsA("BasePart") then
        points[1] = gen
        GEN.pointCache[gen] = points
        return points
    end

    local count = 0
    for _, d in ipairs(gen:GetDescendants()) do
        count += 1
        if d:IsA("BasePart") and isPointName(lowerName(d)) then
            points[#points+1] = d
        end
        if count % 120 == 0 then task.wait() end
    end

    if #points == 0 then
        local p = getAnyBasePart(gen)
        if p then points[#points+1] = p end
    end

    table.sort(points, function(a, b)
        local na = tonumber(a.Name:match("%d+")) or 99
        local nb = tonumber(b.Name:match("%d+")) or 99
        return na < nb
    end)

    GEN.pointCache[gen] = points
    return points
end

local function isFinished(gen)
    if not gen or not gen.Parent then return true end

    local now = os.clock()
    local cached = GEN.progressCache[gen]
    if cached and (now - cached.t) < 1.35 then
        return cached.done
    end

    local done = false

    if gen:GetAttribute("Finished") == true or gen:GetAttribute("Repaired") == true then
        done = true
    else
        local ok, result = pcall(function()
            if generatorFinished then return generatorFinished(gen) end
            return false
        end)
        if ok and result then
            done = true
        else
            local p = 0
            pcall(function() p = getGeneratorProgress(gen) end)
            done = p >= 0.99
        end
    end

    GEN.progressCache[gen] = { t = now, done = done }
    return done
end

local function getKillerPositions()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and isKillerChar(plr.Character) then
            local r = getRoot(plr.Character)
            if r then
                list[#list+1] = r.Position
            end
        end
    end
    return list
end

local function killerNearPosition(pos, killers, maxDist)
    for _, kpos in ipairs(killers) do
        if (pos - kpos).Magnitude <= maxDist then
            return true
        end
    end
    return false
end

local function findNearestKiller(pos, maxDist)
    for _, kpos in ipairs(getKillerPositions()) do
        if (pos - kpos).Magnitude <= (maxDist or GEN.safeDistance) then
            return true
        end
    end
    return false
end

local function pickGenerator(root, avoidCurrent, force)
    if not root then return nil, nil, math.huge end

    local now = os.clock()
    if not force and not avoidCurrent and GEN.lastPickGen and GEN.lastPickPoint
        and GEN.lastPickGen.Parent and GEN.lastPickPoint.Parent
        and (now - GEN.lastPickAt) < GEN.pickCooldown
        and not isFinished(GEN.lastPickGen) then

        return GEN.lastPickGen, GEN.lastPickPoint, (root.Position - GEN.lastPickPoint.Position).Magnitude
    end

    GEN.lastPickAt = now

    local bestGen, bestPoint, bestDist = nil, nil, math.huge
    local fallbackGen, fallbackPoint, fallbackDist = nil, nil, math.huge
    local killers = getKillerPositions()

    for _, gen in ipairs(getGeneratorList(false)) do
        if gen and gen.Parent and gen ~= avoidCurrent and not isFinished(gen) then
            for _, point in ipairs(getRepairPoints(gen)) do
                if point and point.Parent then
                    local dist = (root.Position - point.Position).Magnitude

                    if dist < fallbackDist then
                        fallbackGen, fallbackPoint, fallbackDist = gen, point, dist
                    end

                    if dist < bestDist and not killerNearPosition(point.Position, killers, GEN.safeDistance) then
                        bestGen, bestPoint, bestDist = gen, point, dist
                    end
                end
            end
        end
    end

    local gen, point, dist = bestGen or fallbackGen, bestPoint or fallbackPoint, bestDist ~= math.huge and bestDist or fallbackDist
    GEN.lastPickGen, GEN.lastPickPoint, GEN.lastPickDist = gen, point, dist
    return gen, point, dist
end

local function isRepairValid()
    return GEN.repairPoint and GEN.repairPoint.Parent and GEN.repairModel and GEN.repairModel.Parent and not isFinished(GEN.repairModel)
end

local function clearRepairState()
    GEN.repairPoint = nil
    GEN.repairModel = nil
    GEN.lastRootPos = nil
    GEN.lastRepairAt = 0
end

local function fireRepair(point, state)
    if not resolveRemotes() or not point then return false end
    local ok = pcall(function()
        repairRemote:FireServer(point, state)
    end)
    return ok
end

local function cancelRepair(reason)
    if GEN.cancelDB then return end
    GEN.cancelDB = true

    if isRepairValid() then
        fireRepair(GEN.repairPoint, false)
    end

    clearRepairState()
    task.delay(0.35, function() GEN.cancelDB = false end)

    if reason == "manual" then
        notify("Generator Cancelled", "Repair cancelled.", "x")
    end
end

local function startRepairOn(gen, point)
    if not gen or not point then return false end
    GEN.repairModel = gen
    GEN.repairPoint = point
    GEN.lastRepairAt = os.clock()
    return fireRepair(point, true)
end

local function teleportToGenerator(forceNew)
    local char = LocalPlayer.Character
    local root = getRoot(char)
    if not root then return false end

    local oldGen = forceNew and GEN.repairModel or nil
    local gen, point = pickGenerator(root, oldGen, forceNew)
    if not gen or not point then
        scheduleGenInvalidate()
        return false
    end

    GEN.lastTeleportAt = os.clock()
    GEN.ignoreMoveUntil = os.clock() + 0.95

    pcall(function()
        root.CFrame = CFrame.new(point.Position + Vector3.new(0, 2.6, 0), point.Position + root.CFrame.LookVector)
    end)

    task.delay(0.16, function()
        if LocalPlayer.Character then
            local r = getRoot(LocalPlayer.Character)
            if r then GEN.lastRootPos = r.Position end
        end
        startRepairOn(gen, point)
    end)

    return true
end

local function ensureRepair()
    if not settings.AutoGenRepair then return end

    local char = LocalPlayer.Character
    local root = getRoot(char)
    if not root then return end

    if findNearestKiller(root.Position, GEN.safeDistance) and isRepairValid() then
        cancelRepair("killer")
        task.wait(0.15)
        teleportToGenerator(true)
        return
    end

    if not isRepairValid() then
        clearRepairState()
        teleportToGenerator(false)
        return
    end

    local dist = (root.Position - GEN.repairPoint.Position).Magnitude
    if dist > GEN.nearDistance then
        teleportToGenerator(false)
        return
    end

    if os.clock() - GEN.lastRepairAt >= GEN.repairRetryDelay then
        GEN.lastRepairAt = os.clock()
        fireRepair(GEN.repairPoint, true)
    end
end

local function getSkillCheck()
    local now = os.clock()

    if GEN.cachedSkillCheck and GEN.cachedSkillCheck.Parent then
        local ok, visible = pcall(function() return GEN.cachedSkillCheck.Visible end)
        if ok and visible then return GEN.cachedSkillCheck end
    end

    if now - GEN.lastGuiScanAt < GEN.guiScanDelay then
        return nil
    end
    GEN.lastGuiScanAt = now

    local gui = PlayerGui:FindFirstChild("SkillCheckPromptGui")
    if not gui then
        gui = PlayerGui:FindFirstChild("SkillCheckPromptGui", true)
    end

    local check = gui and (gui:FindFirstChild("Check") or gui:FindFirstChild("Check", true))
    GEN.cachedSkillGui = gui
    GEN.cachedSkillCheck = check

    if check then
        local ok, visible = pcall(function() return check.Visible end)
        if ok and visible then return check end
    end

    return nil
end

local function detectMovementIntent()
    local now = os.clock()
    if now < GEN.ignoreMoveUntil then return false end
    if now - GEN.lastMoveCheckAt < 0.08 then return false end
    GEN.lastMoveCheckAt = now

    local char = LocalPlayer.Character
    local root = getRoot(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return false end

    if hum.MoveDirection.Magnitude > 0.05 then
        return true
    end

    local prev = GEN.lastRootPos
    GEN.lastRootPos = root.Position
    if prev and (root.Position - prev).Magnitude > 1.25 and os.clock() - GEN.lastTeleportAt > 0.95 then
        return true
    end

    return false
end

local function updateActivePointNearPlayer(force)
    local now = os.clock()
    if not force and now - GEN.lastActiveScanAt < GEN.activeScanDelay then return end
    GEN.lastActiveScanAt = now

    local char = LocalPlayer.Character
    local root = getRoot(char)
    if not root then return end

    if isRepairValid() and (root.Position - GEN.repairPoint.Position).Magnitude <= 12 then
        return
    end

    local gen, point, dist = pickGenerator(root, nil, false)
    if gen and point and dist <= 12 then
        GEN.repairModel = gen
        GEN.repairPoint = point
    end
end

local function fireSkill(mode)
    if GEN.skillDB then return end
    if not resolveRemotes() then return end

    updateActivePointNearPlayer(true)
    if not isRepairValid() then return end

    local char = LocalPlayer.Character
    local root = getRoot(char)
    if not root or (root.Position - GEN.repairPoint.Position).Magnitude > 12 then return end

    GEN.skillDB = true
    GEN.lastSkillAt = os.clock()

    local resultName = mode == "perfect" and "success" or "neutral"
    local resultValue = mode == "perfect" and 1 or 0

    pcall(function()
        skillRemote:FireServer(resultName, resultValue, GEN.repairModel, GEN.repairPoint)
    end)

    local check = getSkillCheck()
    if check then pcall(function() check.Visible = false end) end

    task.delay(0.12, function() GEN.skillDB = false end)
end

local function startSkillLoop()
    if GEN.skillThread then task.cancel(GEN.skillThread); GEN.skillThread = nil end
    GEN.skillThread = DYHUB_TrackThread(task.spawn(function()
        while settings.AutoSkillPerfect or settings.AutoSkillNeutral do
            task.wait(GEN.skillLoopDelay)

            if detectMovementIntent() and isRepairValid() then
                cancelRepair("move")
                continue
            end

            local check = getSkillCheck()
            if check then
                if settings.AutoSkillPerfect then
                    fireSkill("perfect")
                elseif settings.AutoSkillNeutral then
                    fireSkill("neutral")
                end
            else
                -- สำคัญ: ไม่ scan generator ทุก tick แล้ว ลดค้างหนัก
                updateActivePointNearPlayer(false)
            end
        end
        GEN.skillThread = nil
    end))
end

local function startRepairLoop()
    if GEN.repairThread then task.cancel(GEN.repairThread); GEN.repairThread = nil end
    GEN.repairThread = DYHUB_TrackThread(task.spawn(function()
        while settings.AutoGenRepair do
            task.wait(GEN.repairLoopDelay)

            if detectMovementIntent() and isRepairValid() then
                cancelRepair("move")
                continue
            end

            ensureRepair()
        end
        GEN.repairThread = nil
    end))
end

local function stopRepairLoop()
    if GEN.repairThread then task.cancel(GEN.repairThread); GEN.repairThread = nil end
    cancelRepair("off")
end

local function stopSkillLoopIfNeeded()
    if not settings.AutoSkillPerfect and not settings.AutoSkillNeutral and GEN.skillThread then
        task.cancel(GEN.skillThread)
        GEN.skillThread = nil
    end
end

DYHUB_AddConnection(Workspace.DescendantAdded:Connect(function(obj)
    local n = lowerName(obj)
    if n:find("generator", 1, true) or n:find("generatorpoint", 1, true) or n:find("repairpoint", 1, true) then
        scheduleGenInvalidate()
    end
end))

DYHUB_AddConnection(Workspace.DescendantRemoving:Connect(function(obj)
    local n = lowerName(obj)
    if n:find("generator", 1, true) or n:find("generatorpoint", 1, true) or n:find("repairpoint", 1, true) then
        scheduleGenInvalidate()
    end
end))

DYHUB_AddConnection(PlayerGui.DescendantAdded:Connect(function(obj)
    if obj.Name == "SkillCheckPromptGui" or obj.Name == "Check" then
        GEN.cachedSkillGui = nil
        GEN.cachedSkillCheck = nil
        GEN.lastGuiScanAt = 0
    end
end))

DYHUB_AddConnection(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.X then
        cancelRepair("manual")
        return
    end

    local moveKeys = {
        [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
        [Enum.KeyCode.Up] = true, [Enum.KeyCode.Down] = true, [Enum.KeyCode.Left] = true, [Enum.KeyCode.Right] = true,
        [Enum.KeyCode.Space] = true,
    }

    if moveKeys[input.KeyCode] and isRepairValid() and os.clock() >= GEN.ignoreMoveUntil then
        cancelRepair("move")
    end
end))

SurTab:Toggle({
    Title = "Auto SkillCheck (Perfect)",
    Desc  = "Auto hits perfect generator skill checks.",
    Value = settings.AutoSkillPerfect,
    Callback = function(v)
        settings.AutoSkillPerfect = v
        Config:Set("AutoSkillPerfect", v)

        if v then
            settings.AutoSkillNeutral = false
            Config:Set("AutoSkillNeutral", false)
            startSkillLoop()
            notify("Auto SkillCheck | Perfect", "Move joystick/WASD or press X to cancel repair.", "check")
        else
            stopSkillLoopIfNeeded()
        end

        Config:Save()
    end
})

SurTab:Toggle({
    Title = "Auto SkillCheck (Neutral)",
    Desc  = "Auto hits neutral generator skill checks.",
    Value = settings.AutoSkillNeutral,
    Callback = function(v)
        settings.AutoSkillNeutral = v
        Config:Set("AutoSkillNeutral", v)

        if v then
            settings.AutoSkillPerfect = false
            Config:Set("AutoSkillPerfect", false)
            startSkillLoop()
            notify("Auto SkillCheck | Neutral", "Move joystick/WASD or press X to cancel repair.", "check")
        else
            stopSkillLoopIfNeeded()
        end

        Config:Save()
    end
})

SurTab:Toggle({
    Title = "Auto Generator (BETA)",
    Desc  = "Teleports to generators and retries.",
    Value = settings.AutoGenRepair,
    Callback = function(v)
        settings.AutoGenRepair = v
        Config:Set("AutoGenRepair", v)
        Config:Save()

        if v then
            invalidateGenCache()
            notify("Auto Generator | Enabled", "Move joystick/WASD or press X to cancel repair.", "zap")
            startRepairLoop()
            if settings.AutoSkillPerfect or settings.AutoSkillNeutral then startSkillLoop() end
        else
            stopRepairLoop()
            notify("Auto Generator | Disabled", "Move joystick/WASD or press X to cancel repair.", "zap-off")
        end
    end
})

DYHUB_RUNTIME.OnCharacterAdded_Generator = function()
    clearRepairState()
    scheduleGenInvalidate()
    GEN.ignoreMoveUntil = os.clock() + 1.35

    task.delay(1, function()
        if settings.AutoGenRepair then startRepairLoop() end
        if settings.AutoSkillPerfect or settings.AutoSkillNeutral then startSkillLoop() end
    end)
end

DYHUB_RUNTIME.CancelGeneratorRepair = function()
    cancelRepair("manual")
end

DYHUB_RUNTIME.StartGeneratorLoops = function()
    if settings.AutoGenRepair then startRepairLoop() end
    if settings.AutoSkillPerfect or settings.AutoSkillNeutral then startSkillLoop() end
end

if settings.AutoGenRepair then
    task.delay(1, startRepairLoop)
end
if settings.AutoSkillPerfect or settings.AutoSkillNeutral then
    task.delay(1, startSkillLoop)
end
end -- GENERATOR SYSTEM do-scope

-- Feature Cheat (Survivor)
SurTab:Section({ Title = "Feature Cheat", Icon = "bug" })
SurTab:Button({
    Title = "Fling Killer (Spam if doesn't fling)", Desc = "Attempts to fling the killer",
    Callback = function()
        local Targets = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and isKillerChar(plr.Character) then
                table.insert(Targets, plr.Name)
            end
        end
        local AllBool = false
        local function GetPlayer(Name)
            Name = Name:lower()
            if Name=="all" or Name=="others" then AllBool=true; return end
            if Name=="random" then
                local pl=Players:GetPlayers(); local idx=table.find(pl,LocalPlayer)
                if idx then table.remove(pl,idx) end
                if #pl == 0 then return nil end
                return pl[math.random(#pl)]
            end
            for _,x in next,Players:GetPlayers() do
                if x~=LocalPlayer and (x.Name:lower():match("^"..Name) or x.DisplayName:lower():match("^"..Name)) then return x end
            end
        end
        local function Message(_T,_t,t) StarterGui:SetCore("SendNotification",{Title=_T,Text=_t,Duration=t}) end
        local function SkidFling(TargetPlayer)
            local Char=LocalPlayer.Character; local Hum=Char and Char:FindFirstChildOfClass("Humanoid")
            local Root=Hum and Hum.RootPart; local TC=TargetPlayer.Character
            local TH=TC and TC:FindFirstChildOfClass("Humanoid"); local TR=TC and TC:FindFirstChild("HumanoidRootPart")
            local THead=TC and TC:FindFirstChild("Head"); local Acc=TC and TC:FindFirstChildOfClass("Accessory")
            local Hand=Acc and Acc:FindFirstChild("Handle")
            if not(Char and Hum and Root) then return Message("Error","Script Failed",5) end
            if Root.Velocity.Magnitude<50 then getgenv().OldPos=Root.CFrame end
            if TH and TH.Sit and not AllBool then return Message("Error","Target is sitting",5) end
            if THead then Workspace.CurrentCamera.CameraSubject=THead
            elseif Hand then Workspace.CurrentCamera.CameraSubject=Hand
            elseif TH then Workspace.CurrentCamera.CameraSubject=TH end
            if not TC:FindFirstChildWhichIsA("BasePart") then return end
            local FPos=function(BP,Pos,Ang)
                Root.CFrame=CFrame.new(BP.Position)*Pos*Ang
                Char:SetPrimaryPartCFrame(CFrame.new(BP.Position)*Pos*Ang)
                Root.Velocity=Vector3.new(9e7,9e7*10,9e7); Root.RotVelocity=Vector3.new(9e8,9e8,9e8)
            end
            local SFBasePart=function(BP)
                local Time,Angle=tick(),0
                repeat
                    if Root and TH then
                        if BP.Velocity.Magnitude<50 then
                            Angle+=100
                            FPos(BP,CFrame.new(0,1.5,0)+TH.MoveDirection*BP.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0))
                            task.wait()
                            FPos(BP,CFrame.new(0,-1.5,0)+TH.MoveDirection*BP.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0))
                            task.wait()
                        else
                            FPos(BP,CFrame.new(0,1.5,TR.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0))
                            task.wait()
                        end
                    else break end
                until BP.Velocity.Magnitude>500 or BP.Parent~=TargetPlayer.Character or TH.Sit or Hum.Health<=0 or tick()>Time+2
            end
            getgenv().FPDH = getgenv().FPDH or Workspace.FallenPartsDestroyHeight
            Workspace.FallenPartsDestroyHeight=0/0
            local BV=Instance.new("BodyVelocity"); BV.Name="DYHUB-YES"; BV.Parent=Root
            BV.Velocity=Vector3.new(9e9,9e9,9e9); BV.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
            if TR and THead then
                if(TR.CFrame.p-THead.CFrame.p).Magnitude>5 then SFBasePart(THead) else SFBasePart(TR) end
            elseif TR then SFBasePart(TR) elseif THead then SFBasePart(THead) elseif Hand then SFBasePart(Hand)
            else return Message("Error","Target missing everything",5) end
            BV:Destroy(); Hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
            Workspace.CurrentCamera.CameraSubject=Hum
            repeat
                Root.CFrame=getgenv().OldPos*CFrame.new(0,0.5,0)
                Char:SetPrimaryPartCFrame(getgenv().OldPos*CFrame.new(0,0.5,0))
                Hum:ChangeState("GettingUp")
                for _,x in ipairs(Char:GetChildren()) do
                    if x:IsA("BasePart") then x.Velocity=Vector3.new(); x.RotVelocity=Vector3.new() end
                end
                task.wait()
            until(Root.Position-getgenv().OldPos.p).Magnitude<25
            pcall(function()
                Workspace.FallenPartsDestroyHeight = getgenv().FPDH or -500
            end)
        end
        if not getgenv().Welcome then Message("DYHUB | FLING","THANK FOR USING",6) end
        getgenv().Welcome=true
        if AllBool then for _,x in next,Players:GetPlayers() do SkidFling(x) end end
        for _,x in next,Targets do
            local TPlayer=GetPlayer(x)
            if TPlayer and TPlayer~=LocalPlayer then
                if TPlayer.UserId~=4340578793 then SkidFling(TPlayer)
                else Message("ERROR","CANT FLING OWNER",8) end
            end
        end
    end
})
SurTab:Button({ Title="Invisible (Not Visual)",
    Desc = "Makes your character invisible to others",
    Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/mabdu21/kjandsaddjadbhahayenajhsjbdwa/refs/heads/main/INV.lua"))() end })
SurTab:Button({ Title="Self UnHook (Not 100%)",
    Desc = "Attempts to free yourself from hooks",
    Callback=function() local r=DYHUB_GetRemote("Remotes", "Carry", "SelfUnHookEvent"); if r then r:FireServer() end end })

-- ====================== KILLER TAB ======================
do
local DYHUB_AimbotEnabled         = false
local DYHUB_Aimbot28Enabled       = false
local DYHUB_LockedTarget          = nil
local DYHUB_PredictionTime        = settings.DYHUB_PredictionTime
local DYHUB_MIN_DISTANCE          = settings.DYHUB_MIN_DISTANCE
local DYHUB_MAX_DISTANCE          = settings.DYHUB_MAX_DISTANCE
local DYHUB_MIN_PITCH             = settings.DYHUB_MIN_PITCH
local DYHUB_MAX_PITCH             = settings.DYHUB_MAX_PITCH
local DYHUB_LOW_HP_IGNORE         = settings.DYHUB_LOW_HP_IGNORE
local DYHUB_ToughWall             = settings.DYHUB_ToughWall
local DYHUB_AimbotToggleGUIVisible   = false
local DYHUB_Aimbot28ToggleGUIVisible = false
local DYHUB_mobileButton, DYHUB_mobileButton28, DYHUB_guiFolder
local DYHUB_Settings = {
    Aimbot = {
        DragUI               = false,
        MobileButtonPosition = UDim2.new(1,-40,1,-40),
        MobileButton28Position = UDim2.new(1,-140,1,-40),
        SetKeybindLock       = settings.AimbotKey,
        SetKeybindLock28     = settings.AimbotKey28,
    }
}

killerTab:Section({Title="Killer: The Veil",Icon="target"})
killerTab:Paragraph({Title="Information: The Veil",Desc="• Aimbot is currently in BETA.\n• There is a chance of missing.\n• Aimbot will not support people at high places.",Image="rbxassetid://104487529937663",ImageSize=50})
killerTab:Toggle({Title="Enable Aimbot (The Veil)",
    Desc = "Automatically locks aim onto nearby survivors",Value=false,Callback=function(state)
    if state and DYHUB_Aimbot28Enabled then DYHUB_Aimbot28Enabled=false; if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3=Color3.fromRGB(255,60,60) end end
    DYHUB_AimbotEnabled=state; if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3=state and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60) end
end})
killerTab:Toggle({Title="Enable Aimbot Charge (The Veil)",
    Desc = "Charge-based aimbot for The Veil",Value=false,Callback=function(state)
    if state and DYHUB_AimbotEnabled then DYHUB_AimbotEnabled=false; if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3=Color3.fromRGB(255,60,60) end end
    DYHUB_Aimbot28Enabled=state; if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3=state and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60) end
end})
killerTab:Section({Title="Killer: The Veil Setting",Icon="settings"})
killerTab:Input({Title="Set Pitch Min",Value=tostring(DYHUB_MIN_PITCH),Placeholder="Default: -1",Callback=function(v) local n=tonumber(v); if n then DYHUB_MIN_PITCH=n; settings.DYHUB_MIN_PITCH=n; Config:Set("DYHUB_MIN_PITCH",n); Config:Save() end end})
killerTab:Input({Title="Set Pitch Max",Value=tostring(DYHUB_MAX_PITCH),Placeholder="Default: 30",Callback=function(v) local n=tonumber(v); if n then DYHUB_MAX_PITCH=n; settings.DYHUB_MAX_PITCH=n; Config:Set("DYHUB_MAX_PITCH",n); Config:Save() end end})
killerTab:Toggle({Title="Tough Wall (The Veil)",
    Desc = "Allows aiming through walls",Value=DYHUB_ToughWall,Callback=function(v)
    DYHUB_ToughWall=v; settings.DYHUB_ToughWall=v; Config:Set("DYHUB_ToughWall",v); Config:Save() end})
killerTab:Input({Title="Set Keybind Aimbot (PC)",Value=DYHUB_Settings.Aimbot.SetKeybindLock,Placeholder="Default: Z",Callback=function(v)
    if #v==1 then DYHUB_Settings.Aimbot.SetKeybindLock=v:upper(); settings.AimbotKey=v:upper(); Config:Set("AimbotKey",v:upper()); Config:Save() end end})
killerTab:Input({Title="Set Keybind Aimbot Charge (PC)",Value=DYHUB_Settings.Aimbot.SetKeybindLock28,Placeholder="Default: V",Callback=function(v)
    if #v==1 then DYHUB_Settings.Aimbot.SetKeybindLock28=v:upper(); settings.AimbotKey28=v:upper(); Config:Set("AimbotKey28",v:upper()); Config:Save() end end})
killerTab:Section({Title="Killer: The Veil GUI",Icon="settings"})
killerTab:Toggle({Title="Enable Aimbot (Toggle GUI)",
    Desc = "Shows mobile toggle button for aimbot",Value=false,Callback=function(v)
    DYHUB_AimbotToggleGUIVisible=v; if DYHUB_mobileButton then DYHUB_mobileButton.Visible=v end end})
killerTab:Toggle({Title="Enable Aimbot Charge (Toggle GUI)",
    Desc = "Shows mobile toggle for aimbot charge",Value=false,Callback=function(v)
    DYHUB_Aimbot28ToggleGUIVisible=v; if DYHUB_mobileButton28 then DYHUB_mobileButton28.Visible=v end end})
killerTab:Toggle({Title="Custom Position Drag (Toggle GUI)",
    Desc = "Allows dragging the mobile aimbot buttons",Value=false,Callback=function(state)
    DYHUB_Settings.Aimbot.DragUI=state; DYHUB_EnableDrag(state) end})

local function DYHUB_GetLocalRoot() local c=LocalPlayer.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function DYHUB_HP_OK(plr) local hum=plr.Character and plr.Character:FindFirstChild("Humanoid"); return hum and hum.Health>DYHUB_LOW_HP_IGNORE end
local function DYHUB_GetClosestInScreen()
    local closest,minDist=nil,math.huge; local mouse=UserInputService:GetMouseLocation()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character and DYHUB_HP_OK(plr) then
            local head=plr.Character:FindFirstChild("Head")
            if head then local pos,onScreen=Camera:WorldToViewportPoint(head.Position)
                if onScreen then local d=(Vector2.new(pos.X,pos.Y)-mouse).Magnitude; if d<minDist then minDist=d; closest=plr end end
            end
        end
    end; return closest
end
local function DYHUB_GetClosestByDistance()
    local root=DYHUB_GetLocalRoot(); if not root then return nil end
    local closest,distMin=nil,math.huge
    for _,plr in pairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character and DYHUB_HP_OK(plr) then
            local r=plr.Character:FindFirstChild("HumanoidRootPart")
            if r then local d=(root.Position-r.Position).Magnitude; if d<distMin then distMin=d; closest=plr end end
        end
    end; return closest,distMin
end
local function DYHUB_CanSeeTarget(target)
    if DYHUB_ToughWall then return true end
    local head=target.Character and target.Character:FindFirstChild("Head"); local root=DYHUB_GetLocalRoot()
    if not head or not root then return false end
    local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances={LocalPlayer.Character or {},target.Character}
    return not Workspace:Raycast(root.Position+Vector3.new(0,2,0),head.Position-root.Position,params)
end
local function DYHUB_GetAutoPitchMax(dist) if dist>=190 then return 45.5 elseif dist>=150 then return 40.5 elseif dist>=90 then return 36.5 else return 30.5 end end
local function DYHUB_AimAt_Normal(target)
    if not target.Character then return end
    local head=target.Character:FindFirstChild("Head"); local hrp_=target.Character:FindFirstChild("HumanoidRootPart")
    local lr=DYHUB_GetLocalRoot(); if not head or not hrp_ or not lr then return end
    local pred=head.Position+(hrp_.Velocity*DYHUB_PredictionTime); local dist=(lr.Position-pred).Magnitude
    local alpha=math.clamp((dist-DYHUB_MIN_DISTANCE)/(DYHUB_MAX_DISTANCE-DYHUB_MIN_DISTANCE),0,1)
    local pitch=DYHUB_MIN_PITCH+(DYHUB_GetAutoPitchMax(dist)-DYHUB_MIN_PITCH)*alpha
    local dir=(pred-Camera.CFrame.Position).Unit; local yaw=math.atan2(dir.X,dir.Z); local pr=math.rad(pitch)
    Camera.CFrame=CFrame.new(Camera.CFrame.Position,Camera.CFrame.Position+Vector3.new(math.sin(yaw)*math.cos(pr),math.sin(pr),math.cos(yaw)*math.cos(pr)))
end
local _pitchTable={{1,0.09},{10,0.9},{20,1.9},{30,2.9},{40,3.9},{50,4.9},{60,5.9},{70,6.9},{80,7.9},{90,8.9},{100,10.9},{110,11.9},{120,12.9},{130,13.9},{140,14.9},{150,15.9},{160,16.9},{170,17.9},{180,18.9},{190,20.3},{200,22.3}}
local function DYHUB_GetPitchByDistance(d) for _,v in ipairs(_pitchTable) do if d<v[1] then return v[2] end end; return 23.3 end
local function DYHUB_AimAt_28(target)
    if not target.Character then return end
    local head=target.Character:FindFirstChild("Head"); local hrp_=target.Character:FindFirstChild("HumanoidRootPart")
    local lr=DYHUB_GetLocalRoot(); if not head or not hrp_ or not lr then return end
    local pred=head.Position+(hrp_.Velocity*DYHUB_PredictionTime); local dist=(pred-Camera.CFrame.Position).Magnitude
    local pitch=DYHUB_GetPitchByDistance(dist); local dir=(pred-Camera.CFrame.Position).Unit
    local yaw=math.atan2(dir.X,dir.Z); local pr=math.rad(pitch)
    Camera.CFrame=CFrame.new(Camera.CFrame.Position,Camera.CFrame.Position+Vector3.new(math.sin(yaw)*math.cos(pr),math.sin(pr),math.cos(yaw)*math.cos(pr)))
end

DYHUB_AddConnection(UserInputService.InputBegan:Connect(function(input,gp)
    if gp or input.UserInputType~=Enum.UserInputType.Keyboard then return end
    local key=input.KeyCode.Name
    if key==DYHUB_Settings.Aimbot.SetKeybindLock then
        DYHUB_AimbotEnabled=not DYHUB_AimbotEnabled
        if DYHUB_AimbotEnabled and DYHUB_Aimbot28Enabled then DYHUB_Aimbot28Enabled=false; if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3=Color3.fromRGB(255,60,60) end end
        if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3=DYHUB_AimbotEnabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60) end
    end
    if key==DYHUB_Settings.Aimbot.SetKeybindLock28 then
        DYHUB_Aimbot28Enabled=not DYHUB_Aimbot28Enabled
        if DYHUB_Aimbot28Enabled and DYHUB_AimbotEnabled then DYHUB_AimbotEnabled=false; if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3=Color3.fromRGB(255,60,60) end end
        if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3=DYHUB_Aimbot28Enabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60) end
    end
end))

local DYHUB_DragConnections = {}
local function DYHUB_ClearDragConnections()
    for _, c in ipairs(DYHUB_DragConnections) do DYHUB_Disconnect(c) end
    DYHUB_ClearList(DYHUB_DragConnections)
end
function DYHUB_EnableDrag(state)
    DYHUB_ClearDragConnections()
    if not state then
        if DYHUB_mobileButton   then DYHUB_Settings.Aimbot.MobileButtonPosition   = DYHUB_mobileButton.Position end
        if DYHUB_mobileButton28 then DYHUB_Settings.Aimbot.MobileButton28Position = DYHUB_mobileButton28.Position end
        return
    end
    local function addDragCon(c)
        DYHUB_DragConnections[#DYHUB_DragConnections + 1] = c
        return DYHUB_AddConnection(c)
    end
    local function makeDrag(btn,settingKey)
        if not btn then return end
        local dragging,startPos,startInput=false,nil,nil
        addDragCon(btn.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                dragging=true; startInput=input.Position; startPos=btn.Position
                local ce
                ce=input.Changed:Connect(function()
                    if input.UserInputState==Enum.UserInputState.End then
                        dragging=false
                        DYHUB_Settings.Aimbot[settingKey]=btn.Position
                        DYHUB_Disconnect(ce)
                    end
                end)
                addDragCon(ce)
            end
        end))
        addDragCon(UserInputService.InputChanged:Connect(function(input)
            if dragging and startInput and startPos and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
                local delta=input.Position-startInput
                btn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
            end
        end))
    end
    makeDrag(DYHUB_mobileButton,"MobileButtonPosition"); makeDrag(DYHUB_mobileButton28,"MobileButton28Position")
end

local function DYHUB_EnsureGUIFolder()
    if not DYHUB_guiFolder or not DYHUB_guiFolder.Parent then
        DYHUB_guiFolder=Instance.new("ScreenGui"); DYHUB_guiFolder.Name="DYHUB_AimbotGUI"
        DYHUB_guiFolder.ResetOnSpawn=false; DYHUB_guiFolder.Parent=PlayerGui
    end
end
local function DYHUB_CreateMobileButtons()
    pcall(function() if DYHUB_mobileButton   then DYHUB_mobileButton:Destroy()   end end)
    pcall(function() if DYHUB_mobileButton28 then DYHUB_mobileButton28:Destroy() end end)
    local function makeBtn(text,pos,isEnabled)
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,90,0,90); btn.Position=pos; btn.AnchorPoint=Vector2.new(1,1)
        btn.BackgroundColor3=isEnabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
        btn.Text=text; btn.TextSize=36; btn.Font=Enum.Font.GothamBold; btn.TextColor3=Color3.new(1,1,1)
        btn.Visible=false; btn.Parent=DYHUB_guiFolder
        local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,45); c.Parent=btn; return btn
    end
    DYHUB_mobileButton   = makeBtn("🗡️",DYHUB_Settings.Aimbot.MobileButtonPosition,DYHUB_AimbotEnabled)
    DYHUB_mobileButton28 = makeBtn("⚔️",DYHUB_Settings.Aimbot.MobileButton28Position,DYHUB_Aimbot28Enabled)
    DYHUB_mobileButton.Visible=DYHUB_AimbotToggleGUIVisible; DYHUB_mobileButton28.Visible=DYHUB_Aimbot28ToggleGUIVisible
    DYHUB_AddConnection(DYHUB_mobileButton.MouseButton1Click:Connect(function()
        DYHUB_AimbotEnabled=not DYHUB_AimbotEnabled
        if DYHUB_AimbotEnabled and DYHUB_Aimbot28Enabled then DYHUB_Aimbot28Enabled=false; if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3=Color3.fromRGB(255,60,60) end end
        DYHUB_mobileButton.BackgroundColor3=DYHUB_AimbotEnabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
    end))
    DYHUB_AddConnection(DYHUB_mobileButton28.MouseButton1Click:Connect(function()
        DYHUB_Aimbot28Enabled=not DYHUB_Aimbot28Enabled
        if DYHUB_Aimbot28Enabled and DYHUB_AimbotEnabled then DYHUB_AimbotEnabled=false; if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3=Color3.fromRGB(255,60,60) end end
        DYHUB_mobileButton28.BackgroundColor3=DYHUB_Aimbot28Enabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
    end))
    DYHUB_EnableDrag(DYHUB_Settings.Aimbot.DragUI)
end

DYHUB_TrackThread(task.spawn(function()
    DYHUB_EnsureGUIFolder(); DYHUB_CreateMobileButtons()
    while task.wait(3) do
        DYHUB_EnsureGUIFolder()
        local gui=PlayerGui:FindFirstChild("DYHUB_AimbotGUI")
        if gui and not gui.Enabled then gui.Enabled=true end
    end
end))

DYHUB_AddConnection(RunService.RenderStepped:Connect(function()
    if DYHUB_AimbotEnabled then
        DYHUB_LockedTarget=DYHUB_GetClosestInScreen()
        if DYHUB_LockedTarget and DYHUB_CanSeeTarget(DYHUB_LockedTarget) then DYHUB_AimAt_Normal(DYHUB_LockedTarget) end
    elseif DYHUB_Aimbot28Enabled then
        DYHUB_LockedTarget=DYHUB_GetClosestByDistance()
        if DYHUB_LockedTarget and DYHUB_CanSeeTarget(DYHUB_LockedTarget) then DYHUB_AimAt_28(DYHUB_LockedTarget) end
    end
end))

killerTab:Section({Title="Killer: The Masked",Icon="venetian-mask"})
killerTab:Paragraph({Title="Information: The Masked",Desc="• Richard (No Abilities)\n• Tony (One Shot, No hold)\n• Brandon (Speed Boost)\n• Jake (Lunge Range)\n• Richter (Removes terror radius)\n• Graham (Faster Vault)\n• Alex (Chainsaw, One Shot)",Image="rbxassetid://104487529937663",ImageSize=50})
local MaskedList={"Richard","Tony","Brandon","Jake","Richter","Graham","Alex"}
local selectedMasks = settings.SelectedMasks
killerTab:Dropdown({Title="Select Mask",Values=MaskedList,Multi=false,Value=selectedMasks,Callback=function(value)
    selectedMasks=value; settings.SelectedMasks=value; Config:Set("selectedMasks",value); Config:Save() end})
killerTab:Button({Title="Choose Mask (Selected)",
    Desc = "Equips the selected mask ability",Callback=function()
    local r=DYHUB_GetRemote("Remotes", "Killers", "Masked", "Activatepower"); if r then r:FireServer(selectedMasks) end end})
killerTab:Button({Title="Random Mask (Legit Mode)",
    Desc = "Chooses a random mask ability",Callback=function()
    local r=DYHUB_GetRemote("Remotes", "Killers", "Masked", "Activatepower"); if r then r:FireServer(MaskedList[math.random(#MaskedList)]) end end})

killerTab:Section({Title="Killer: The Stalker",Icon="eye-off"})
local Stalker = settings.Stalker
local _stalkerRemote
local function getStalkerRemote()
    if not _stalkerRemote or not _stalkerRemote.Parent then
        _stalkerRemote=DYHUB_GetRemote("Remotes", "Killers", "Stalker", "StartStalking")
    end; return _stalkerRemote
end
killerTab:Toggle({Title="Start Stalker (Raycast / Remote)",
    Desc = "Automatically stalks nearby survivors",Value=false,Callback=function(v)
    Stalker=v; settings.Stalker=v; Config:Set("Stalker",Stalker); Config:Save()
    if v then DYHUB_TrackThread(task.spawn(function()
        while Stalker do task.wait(0.2)
            local char=LocalPlayer.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
            if not root or not isKillerChar(char) then continue end
            local remote=getStalkerRemote()
            if not remote then continue end
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr~=LocalPlayer and plr.Character then
                    local hrp_=plr.Character:FindFirstChild("HumanoidRootPart"); local hum=plr.Character:FindFirstChild("Humanoid")
                    if hrp_ and hum then local dist=(root.Position-hrp_.Position).Magnitude
                        if dist>=30 and dist<=70 and hum.Health>20 then pcall(function() remote:FireServer(plr) end) end
                    end
                end
            end
        end
    end)) end
end})

killerTab:Section({Title="Feature Killer",Icon="swords"})
local killallEnabled = settings.KillAll
killerTab:Toggle({Title="Kill All (Warning: Get Ban)",
    Desc = "Automatically teleport and kill all",Value=killallEnabled,Callback=function(v)
    killallEnabled=v; settings.KillAll=v; Config:Set("killall",killallEnabled); Config:Save()
    if v then DYHUB_TrackThread(task.spawn(function()
        local remote=DYHUB_GetRemote("Remotes", "Attacks", "BasicAttack"); local startCFrame=nil
        if not remote then WindUI:Notify({Title="Kill All",Content="BasicAttack remote not found.",Duration=3,Icon="alert-triangle"}); killallEnabled=false; return end
        while killallEnabled do task.wait(0.2)
            local char=LocalPlayer.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); if not root then continue end
            if not startCFrame then startCFrame=root.CFrame end
            local targets={}
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr~=LocalPlayer and plr.Character then
                    local tr=plr.Character:FindFirstChild("HumanoidRootPart"); local hm=plr.Character:FindFirstChildOfClass("Humanoid")
                    if tr and hm then table.insert(targets,{root=tr,humanoid=hm}) end
                end
            end
            for _,entry in ipairs(targets) do
                if not killallEnabled then break end
                if entry.humanoid.Health>20 then pcall(function() root.CFrame=entry.root.CFrame*CFrame.new(0,0,2); remote:FireServer() end); task.wait(0.15) end
            end
            local allLow=true; for _,entry in ipairs(targets) do if entry.humanoid.Health>20 then allLow=false; break end end
            if allLow and startCFrame then root.CFrame=startCFrame; task.wait(1) end
        end
    end)) end
end})

local Autocarry = settings.AutoCarry
killerTab:Toggle({Title="Auto Carry (Nearby Survivor / 2.5s)",
    Desc = "Automatically picks up nearby downed survivors",Value=Autocarry,Callback=function(v)
    Autocarry=v; settings.AutoCarry=v; Config:Set("autocarry",Autocarry); Config:Save()
    if v then DYHUB_TrackThread(task.spawn(function()
        while Autocarry do task.wait(2.5)
            local char=LocalPlayer.Character; local hrp_=char and char:FindFirstChild("HumanoidRootPart"); if not hrp_ then continue end
            local candidates={}
            for _,plr in pairs(Players:GetPlayers()) do
                if plr~=LocalPlayer and plr.Character then
                    local hum=plr.Character:FindFirstChild("Humanoid"); local oHrp=plr.Character:FindFirstChild("HumanoidRootPart")
                    if hum and oHrp and hum.Health==20 and (hrp_.Position-oHrp.Position).Magnitude<=10 then table.insert(candidates,plr) end
                end
            end
            if #candidates~=1 then continue end
            local target=candidates[1]
            if target and target.Character then
                local tHum=target.Character:FindFirstChild("Humanoid")
                if tHum and tHum.Health==20 then
                    local r=DYHUB_GetRemote("Remotes", "Carry", "CarrySurvivorEvent")
                    if r then r:FireServer(target.Character) end
                    task.wait(5)
                end
            end
        end
    end)) end
end})

local AutoHook = settings.AutoHook
killerTab:Toggle({Title="Auto Hook (Nearby Hook / 2.5s)",
    Desc = "Automatically hook nearby survivors",Value=AutoHook,Callback=function(v)
    AutoHook=v; settings.AutoHook=v; Config:Set("autohook",AutoHook); Config:Save()
    if v then DYHUB_TrackThread(task.spawn(function()
        while AutoHook do task.wait(2.5)
            local char=LocalPlayer.Character; local hrp_=char and char:FindFirstChild("HumanoidRootPart"); if not hrp_ then continue end
            local candidates={}
            for _,target in ipairs(Players:GetPlayers()) do
                if target~=LocalPlayer and target.Character then
                    local hum=target.Character:FindFirstChild("Humanoid"); local thrp=target.Character:FindFirstChild("HumanoidRootPart")
                    if hum and thrp and hum.Health==20 and (hrp_.Position-thrp.Position).Magnitude<=10 then table.insert(candidates,target) end
                end
            end
            if #candidates~=1 then continue end
            local nearestHook,nearestDist=nil,10
            for _,desc in ipairs(Workspace:GetDescendants()) do
                if desc.Name=="HookPoint" then local d=(hrp_.Position-desc.Position).Magnitude; if d<=nearestDist then nearestDist=d; nearestHook=desc end end
            end
            if not nearestHook then continue end
            local r=DYHUB_GetRemote("Remotes", "Carry", "HookEvent")
            if r then r:FireServer(nearestHook) end
            task.wait(5)
        end
    end)) end
end})

killerTab:Section({Title="Feature Fun",Icon="crown"})
local GrabKey = settings.GrabKey
killerTab:Input({Title="Set Keybind Grab (PC ONLY)",Value=GrabKey,Placeholder="Grab (Default: C)",Callback=function(text)
    if type(text)=="string" and #text>0 then GrabKey=text:upper(); settings.GrabKey=GrabKey; Config:Set("GrabKey",GrabKey); Config:Save() end
end})
local function DoGrab()
    local char=LocalPlayer.Character; local hrp_=char and char:FindFirstChild("HumanoidRootPart"); if not hrp_ then return end
    local candidates={}
    for _,target in ipairs(Players:GetPlayers()) do
        if target~=LocalPlayer and target.Character then
            local hum=target.Character:FindFirstChild("Humanoid"); local thrp=target.Character:FindFirstChild("HumanoidRootPart")
            if hum and thrp and (hrp_.Position-thrp.Position).Magnitude<=20 and hum.Health~=20 then table.insert(candidates,target) end
        end
    end
    if #candidates~=1 then return end
    local r=DYHUB_GetRemote("Remotes", "Killers", "Stalker", "grab")
    if r then r:FireServer(candidates[1].Character) end
end
killerTab:Button({Title="Grab (Nearby Survivor/Killer)",
    Desc = "Automatically grab the player",Callback=DoGrab})
DYHUB_AddConnection(UserInputService.InputBegan:Connect(function(input,gp)
    if gp or not GrabKey then return end
    local ok,keyEnum=pcall(function() return Enum.KeyCode[GrabKey] end)
    if ok and keyEnum and input.KeyCode==keyEnum then DoGrab() end
end))

local nocooldownskillEnabled = settings.AutoAttack
killerTab:Toggle({Title="Auto Attack (No Animation)",
    Desc = "Automatically attack the player",Value=nocooldownskillEnabled,Callback=function(v)
    nocooldownskillEnabled=v; settings.AutoAttack=v; Config:Set("autoattack",nocooldownskillEnabled); Config:Save()
    if v then DYHUB_TrackThread(task.spawn(function()
        local remote=DYHUB_GetRemote("Remotes", "Attacks", "BasicAttack")
        if not remote then WindUI:Notify({Title="Auto Attack",Content="BasicAttack remote not found.",Duration=3,Icon="alert-triangle"}); nocooldownskillEnabled=false; return end
        while nocooldownskillEnabled do task.wait(0.1)
            local char=LocalPlayer.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); if not root then continue end
            local closest,closestDist=nil,10
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr~=LocalPlayer and plr.Character then
                    local tr=plr.Character:FindFirstChild("HumanoidRootPart"); local hm=plr.Character:FindFirstChildOfClass("Humanoid")
                    if tr and hm then local d=(root.Position-tr.Position).Magnitude
                        if d<=closestDist and hm.Health>20 then closestDist=d; closest=plr.Character end
                    end
                end
            end
            if closest then remote:FireServer() end
        end
    end)) end
end})

killerTab:Section({Title="Feature Cheat",Icon="bug"})
local noFlashlightEnabled = settings.NoFlashlight
killerTab:Toggle({Title="No Flashlight",
    Desc = "Prevents blind from using flash",Value=noFlashlightEnabled,Callback=function(state)
    noFlashlightEnabled=state; settings.NoFlashlight=state; Config:Set("noblind",noFlashlightEnabled); Config:Save() end})
DYHUB_AddConnection(PlayerGui.DescendantAdded:Connect(function(desc)
    if noFlashlightEnabled and desc:IsA("GuiObject") and desc.Name=="Blind" then pcall(function() desc:Destroy() end) end
end))

local destroyPalletwrong = settings.DestroyPallet
killerTab:Toggle({Title="Remove Palletwrong (All)",
    Desc = "Removes all Palletwrong objects",Value=destroyPalletwrong,Callback=function(v)
    destroyPalletwrong=v; settings.DestroyPallet=v; Config:Set("destroyPalletwrong",destroyPalletwrong); Config:Save()
    if v then DYHUB_TrackThread(task.spawn(function()
        while destroyPalletwrong do task.wait(1)
            for _,desc in ipairs(Workspace:GetDescendants()) do
                if desc:IsA("Model") and desc.Name=="Palletwrong" then desc:Destroy() end
            end
        end
    end)) end
end})

killerTab:Button({Title="Fix Cam (3rd Person Camera)",
    Desc = "Changes the camera to third person view",Callback=function()
    local character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        Camera.CameraType=Enum.CameraType.Custom; Camera.CameraSubject=humanoid
        LocalPlayer.CameraMinZoomDistance=0.5; LocalPlayer.CameraMaxZoomDistance=400
        LocalPlayer.CameraMode=Enum.CameraMode.Classic
        local head=character:FindFirstChild("Head"); if head then head.Anchored=false end
    end
end})
end -- KILLER TAB do-scope

-- ====================== PLAYER TAB ======================
do
local speedEnabled   = settings.SpeedEnabled
local flyNoclipSpeed = settings.SpeedWalk
local NoClipEnabled  = settings.NoClipEnabled
local speedConnection, noclipConnection
local noclipOriginal = setmetatable({}, { __mode = "k" })

local function setNoClipChar(char, enabled)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if enabled then
                if noclipOriginal[part] == nil then noclipOriginal[part] = part.CanCollide end
                part.CanCollide = false
            else
                if noclipOriginal[part] ~= nil then
                    part.CanCollide = noclipOriginal[part]
                    noclipOriginal[part] = nil
                end
            end
        end
    end
end

local function stopSpeed()
    DYHUB_Disconnect(speedConnection)
    speedConnection = nil
end

local function startSpeed()
    stopSpeed()
    speedConnection = DYHUB_AddConnection(RunService.RenderStepped:Connect(function(dt)
        local char=LocalPlayer.Character
        local hrp_=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hrp_ and hum and hum.MoveDirection.Magnitude>0 then
            hrp_.CFrame = hrp_.CFrame + hum.MoveDirection * flyNoclipSpeed * dt
        end
    end))
end

local function stopNoClip()
    DYHUB_Disconnect(noclipConnection)
    noclipConnection = nil
    setNoClipChar(LocalPlayer.Character, false)
end

local function startNoClip()
    DYHUB_Disconnect(noclipConnection)
    noclipConnection = DYHUB_AddConnection(RunService.Stepped:Connect(function()
        setNoClipChar(LocalPlayer.Character, true)
    end))
end

PlayerTab:Section({Title="Feature Player",Icon="rabbit"})
PlayerTab:Slider({
    Title    = "Set Speed Walk",
    Desc     = "Adjust your walking speed with smooth movement. (CFrame)",
    Value    = { Min=1, Max=677, Default=settings.SpeedWalk },
    Step     = 1,
    Callback = function(v)
        flyNoclipSpeed = v; settings.SpeedWalk = v
        Config:Set("SpeedWalk", v); Config:Save()
    end
})
PlayerTab:Toggle({
    Title="Enable Speed", Desc = "Adjusts your character movement speed (FPS-safe dt movement)", Value=speedEnabled,
    Callback=function(v)
        speedEnabled=v; settings.SpeedEnabled=v
        Config:Set("SpeedEnabled", v); Config:Save()
        if speedEnabled then startSpeed() else stopSpeed() end
    end
})

PlayerTab:Section({Title="Feature Power",Icon="flame"})
PlayerTab:Toggle({
    Title="No Clip", Desc = "Allows your character to walk through walls", Value=NoClipEnabled,
    Callback=function(state)
        NoClipEnabled=state; settings.NoClipEnabled=state; Config:Set("NoClipEnabled",state); Config:Save()
        if state then startNoClip() else stopNoClip() end
    end
})

local NoFallEnabled = settings.NoFallEnabled
DYHUB_RUNTIME.NoFallEnabled = NoFallEnabled
DYHUB_RUNTIME.FallRemote = DYHUB_RUNTIME.FallRemote or DYHUB_GetRemote("Remotes", "Mechanics", "Fall")

if getrawmetatable and setreadonly and newcclosure and getnamecallmethod and not DYHUB_RUNTIME.NoFallHooked then
    local okHook, errHook = pcall(function()
        local mt=getrawmetatable(game)
        local oldNamecall=mt.__namecall
        setreadonly(mt,false)
        mt.__namecall=newcclosure(function(self,...)
            local method=getnamecallmethod()
            if DYHUB_RUNTIME.NoFallEnabled and method=="FireServer" then
                if not DYHUB_RUNTIME.FallRemote or not DYHUB_RUNTIME.FallRemote.Parent then
                    DYHUB_RUNTIME.FallRemote = DYHUB_GetRemote("Remotes", "Mechanics", "Fall")
                end
                if self == DYHUB_RUNTIME.FallRemote then return nil end
            end
            return oldNamecall(self,...)
        end)
        setreadonly(mt,true)
        DYHUB_RUNTIME.NoFallHooked = true
    end)
    if not okHook then warn("[DYHUB] NoFall hook failed:", errHook) end
end

PlayerTab:Toggle({Title="No Fall (Beta)",
    Desc = "Prevents movement slowdown after falling",Value=NoFallEnabled,
    Callback=function(v)
        NoFallEnabled=v; settings.NoFallEnabled=v; DYHUB_RUNTIME.NoFallEnabled=v
        Config:Set("NoFallEnabled", v); Config:Save()
    end})

DYHUB_RUNTIME.RestoreNoClip = function()
    if speedEnabled then startSpeed() end
    if NoClipEnabled then startNoClip() end
end

if speedEnabled then task.defer(startSpeed) end
if NoClipEnabled then task.defer(startNoClip) end
end -- PLAYER TAB do-scope

-- ====================== TELEPORT TAB ======================
do
local function getCFrame(obj)
    if obj:IsA("BasePart") then return obj.CFrame
    elseif obj:IsA("Model") then
        local part=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        return part and part.CFrame
    end
end

local function getAllGenerators()
    local list,count={},0
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name=="Generator" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            count+=1; table.insert(list,{Name="Generator "..count,Object=obj})
        end
    end; return list
end

TeleportTab:Section({Title="Teleport: Place",Icon="map"})
local SelectedPlace
TeleportTab:Dropdown({Title="Select Place",Values={"Lobby","Game"},Callback=function(v) SelectedPlace=v end})
TeleportTab:Button({Title="Teleport", Desc = "Teleports to selected place",Callback=function()
    if SelectedPlace=="Lobby" then
        local spawn=Workspace:FindFirstChild("SpawnLocation")
        if spawn and LocalPlayer.Character then LocalPlayer.Character:PivotTo(spawn.CFrame+Vector3.new(0,1,0)) end
    elseif SelectedPlace=="Game" then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character and isKillerChar(p.Character) then
                local cf=getCFrame(p.Character)
                if cf and LocalPlayer.Character then LocalPlayer.Character:PivotTo(cf*CFrame.new(0,0,200)); break end
            end
        end
    end
end})

TeleportTab:Section({Title="Teleport: Generator",Icon="zap"})
local generatorList=getAllGenerators(); local GenTarget
local GenDropdown=TeleportTab:Dropdown({
    Title="Select Generator",
    Values=(function() local t={}; for _,g in ipairs(generatorList) do table.insert(t,g.Name) end; return t end)(),
    Callback=function(v) for _,g in ipairs(generatorList) do if g.Name==v then GenTarget=g.Object end end end
})
TeleportTab:Button({Title="Teleport", Desc = "Teleports to selected generator",
    Callback=function() if GenTarget then local cf=getCFrame(GenTarget); if cf then LocalPlayer.Character:PivotTo(cf) end end end})
TeleportTab:Button({Title="Refresh Generator", Desc = "Updates generator list",Callback=function()
    generatorList=getAllGenerators(); local t={}; for _,g in ipairs(generatorList) do table.insert(t,g.Name) end; GenDropdown:Update(t)
end})
TeleportTab:Section({Title="Teleport: Refresh",Icon="loader"})
TeleportTab:Button({Title="Refresh All", Desc = "Updates all dropdowns",Callback=function()
    generatorList=getAllGenerators()
    if GenDropdown then local t={}; for _,g in ipairs(generatorList) do table.insert(t,g.Name) end; GenDropdown:Update(t) end
    GenTarget=nil; _invalidateGenCache(); invalidateWorldCache()
    print("[DYHUB] Refresh All completed")
end})
end -- TELEPORT TAB do-scope

-- ====================== SETTINGS TAB ======================
do
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

local InviteCode="dyhub"
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
            setclipboard("https://dsc.gg/"..InviteCode); WindUI:Notify({Title="Copied!",Content="Discord invite copied!",Duration=2,Icon="clipboard-check"})
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
    Buttons={{Icon="copy",Title="Copy Link",Callback=function() setclipboard("https://dsc.gg/dyhub") end}}})
end -- INFORMATION TAB do-scope

-- =====================================================================================
--  AUTO RESTORE ON LOAD
--  [Fix] ย้ายมาอยู่หลัง define ตัวแปรและฟังก์ชันทั้งหมด ป้องกัน nil error
-- =====================================================================================
DYHUB_AddConnection(LocalPlayer.CharacterAdded:Connect(function()
    if DYHUB_RUNTIME.ResetHookCache then DYHUB_RUNTIME.ResetHookCache() end
    if DYHUB_RUNTIME.OnCharacterAdded_Generator then DYHUB_RUNTIME.OnCharacterAdded_Generator() end
    if DYHUB_RUNTIME.RestoreNoClip then DYHUB_RUNTIME.RestoreNoClip() end
end))

-- restore noclip
if DYHUB_RUNTIME.RestoreNoClip then DYHUB_RUNTIME.RestoreNoClip() end

-- init world ESP cache
if DYHUB_RUNTIME.IsEspEnabled and DYHUB_RUNTIME.IsEspEnabled() then
    task.delay(2, function() rebuildWorldCacheAsync() end)
end

print("[DYHUB] "..version.." | "..ver.." loaded successfully!")
print("[DYHUB] Config active | Auto saving every "..tostring(settings.AutoSaveDelay).."s")
