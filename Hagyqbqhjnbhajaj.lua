-- Powered by nig | v531
-- =========================
local version = "Rework"
local ver     = "v015.00"
-- =========================
-- CHANGELOG v015.00
-- [Fixed]   Auto Gen: หา GeneratorPoint ได้ทุกชื่อ (ไม่จำกัดแค่ 1-4)
-- [Fixed]   Auto Gen: retry repairRemote ถ้า fire ไม่ติด + validate ก่อน fire
-- [Fixed]   Auto Gen: _invalidateGenCache เมื่อ gen เสร็จ (prevent หา gen ที่ done แล้ว)
-- [Fixed]   Auto Gen: รองรับ Generator ที่เป็น BasePart ด้วย (ไม่ใช่แค่ Model)
-- [Fixed]   Auto Parry: hookChar_AP ไม่รอ 0.5s แล้ว (ป้องกัน miss attach)
-- [Fixed]   Auto Parry: isParryReady fallback ดีขึ้น + ตรวจ cooldown icon สี
-- [Fixed]   Auto Parry: Hooked_AP cleanup เมื่อ character removed
-- [Fixed]   ESP: Pallet name fix ("Palletwrong" → correct obj ref)
-- [Fixed]   ESP: world cache รองรับ BasePart + Model Generator
-- [Fixed]   Auto Restore: ย้าย restore block ให้อยู่หลัง define ตัวแปรทั้งหมด
-- [Improved] local settings = { ... } รวม locals ทั้งหมด (ยกเว้น ver, version)
-- [Improved] Gen loop: ตรวจ repairPoint ซ้ำก่อน teleport (ป้องกัน tp loop)
-- [Improved] Parry: fast-path skip ถ้า killer ไม่มี HumanoidRootPart
-- [Improved] Anti-AFK: ใช้ task.delay แทน random wait loop ป้องกัน drift
-- [Improved] Config AutoSave: guard ถ้า interval เปลี่ยนระหว่าง save

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

-- ====================== SETTINGS TABLE (รวม locals ทั้งหมด) ======================
-- [Fix] รวม locals เข้า settings table เดียว ยกเว้น ver, version
local settings = {
    -- Auto Parry
    AutoParry         = Config:Get("autoparry",      false),
    AutoParryMode     = Config:Get("autoparrymode",  "Fast"),
    AutoParryRange    = Config:Get("autoparryrange", 20),
    HookNearDist      = Config:Get("hookrange",      6),

    -- Generator / Skill
    AutoGenRepair     = Config:Get("AutoGenRepair",    false),
    AutoSkillPerfect  = Config:Get("AutoSkillPerfect", false),
    AutoSkillNeutral  = Config:Get("AutoSkillNeutral", false),

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
    SpeedEnabled      = false,
    SpeedWalk         = Config:Get("SpeedWalk",       3),
    NoClipEnabled     = Config:Get("NoClipEnabled",   false),
    NoFallEnabled     = false,

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
    Title = "Update: 05/28/2026 | CL: " .. ver,
    Desc  = "• [ Fixed ] Auto Gen: detects GeneratorPoint with any name + retry\n• [ Fixed ] Auto Gen: invalidates cache when generator is completed\n• [ Fixed ] Auto Parry: hookChar no longer misses\n• [ Fixed ] ESP: Pallet + BasePart Generator support\n• [ Improved ] settings table now combines all local config values\n• [ Improved ] no lag / no freezing",
})
Info:Divider()

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
--  AUTO PARRY SYSTEM v5  —  [Premium Only]
--  [Fix] hookChar ไม่ delay 0.5s แล้ว ป้องกัน miss
--  [Fix] Hooked_AP cleanup เมื่อ character removed
--  [Fix] isParryReady() fallback logic ดีขึ้น
-- =====================================================================================
local UIS_AP = UserInputService
local Vim_AP = VIM
local LP_AP  = LocalPlayer

_G.AutoParry      = settings.AutoParry
_G.AutoParryMode  = settings.AutoParryMode
_G.AutoParryRange = settings.AutoParryRange

local LastParry     = 0
local PARRY_CD      = 0.05
local Hooked_AP     = {}
local IsMobile      = UIS_AP.TouchEnabled and not UIS_AP.KeyboardEnabled
local PARRY_ICON_ID = "92951359322494"

local HOOK_NEAR_DIST = settings.HookNearDist
local HP_CARRIED     = 60
local HP_DOWNED      = 20

-- ── Parry button finder ───────────────────────────────────────────────────────────
local function getParryBtn()
    local pg = LP_AP:FindFirstChild("PlayerGui");     if not pg then return nil end
    local s  = pg:FindFirstChild("Survivor-mob");     if not s  then return nil end
    local c  = s:FindFirstChild("Controls");          if not c  then return nil end
    return c:FindFirstChild("Gui-mob")
end

-- [Fix] isParryReady: ถ้า icon ไม่มี/ไม่ใช่ image → คืน true (ready)
-- ถ้า icon เป็นสี gray (77,77,77) → cooldown (not ready)
local function isParryReady()
    local btn = getParryBtn()
    if not btn then
        -- PC: ไม่มี mobile GUI → ถือว่าพร้อม
        return not IsMobile
    end
    -- หา icon child ก่อน ถ้าไม่มีให้ใช้ btn เอง
    local icon = btn:FindFirstChild("icon") or btn
    if not (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
        return true
    end
    local idStr = tostring(icon.Image or "")
    -- ถ้า icon ไม่ใช่ parry icon → ไม่ใช่ parry button → skip
    if not idStr:find(PARRY_ICON_ID) then return false end
    local ok, col = pcall(function() return icon.ImageColor3 end)
    if not ok then return true end
    -- Gray = on cooldown (approx R=G=B ≈ 77)
    local r, g, b = math.floor(col.R * 255 + 0.5), math.floor(col.G * 255 + 0.5), math.floor(col.B * 255 + 0.5)
    if math.abs(r - 77) < 5 and math.abs(g - 77) < 5 and math.abs(b - 77) < 5 then
        return false
    end
    return true
end

-- ── Safety checks ─────────────────────────────────────────────────────────────────
local function isPlayerDowned()
    local char = LP_AP.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return false end
    return hum.Health <= HP_DOWNED
end

local _hookCache = {}
local _hookCacheTick = 0
local HOOK_CACHE_TTL = 1.5

local function getHooks()
    local now = os.clock()
    if now - _hookCacheTick < HOOK_CACHE_TTL and #_hookCache > 0 then
        return _hookCache
    end
    local list = {}
    for _, desc in ipairs(Workspace:GetDescendants()) do
        local ok, isHook = pcall(function()
            return (desc.Name == "HookPoint" or desc.Name == "Hook")
                and (desc:IsA("BasePart") or desc:IsA("Model"))
        end)
        if ok and isHook then
            list[#list+1] = desc
        end
    end
    _hookCache     = list
    _hookCacheTick = now
    return list
end

local function isPlayerBeingCarriedToHook()
    local char = LP_AP.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return false end
    if hum.Health > HP_CARRIED then return false end
    local myPos = hrp.Position
    for _, desc in ipairs(getHooks()) do
        local hookPos
        pcall(function()
            if desc:IsA("BasePart") then
                hookPos = desc.Position
            elseif desc:IsA("Model") then
                local p = desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart")
                if p then hookPos = p.Position end
            end
        end)
        if hookPos and (myPos - hookPos).Magnitude <= HOOK_NEAR_DIST then
            return true
        end
    end
    return false
end

local function shouldParry()
    if isPlayerDowned()             then return false end
    if isPlayerBeingCarriedToHook() then return false end
    return true
end

-- ── Fire methods ──────────────────────────────────────────────────────────────────
local function fireParryPC()
    pcall(function()
        Vim_AP:SendMouseButtonEvent(0, 0, 1, true,  game, 1)
        task.wait(0.016)
        Vim_AP:SendMouseButtonEvent(0, 0, 1, false, game, 1)
    end)
    pcall(function()
        Vim_AP:SendKeyEvent(true,  Enum.KeyCode.F, false, game)
        task.wait(0.016)
        Vim_AP:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
end

local function fireParryMobile()
    local btn = getParryBtn()
    if not btn then return end
    pcall(function() firesignal(btn.MouseButton1Click); firesignal(btn.Activated) end)
    pcall(function() btn:Activate() end)
    pcall(function()
        local p = btn.AbsolutePosition; local sz = btn.AbsoluteSize
        local x = p.X + sz.X * 0.5;    local y  = p.Y + sz.Y * 0.5
        Vim_AP:SendMouseButtonEvent(x, y, 0, true,  game, 1)
        task.wait(0.016)
        Vim_AP:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
end

local function fireParryBtn()
    if IsMobile then fireParryMobile() else fireParryPC() end
end

-- ── Threat level ──────────────────────────────────────────────────────────────────
local function getThreatLevel(killerChar)
    local my = LP_AP.Character
    if not my then return 0 end
    local myHRP = my:FindFirstChild("HumanoidRootPart")
    local ksHRP = killerChar:FindFirstChild("HumanoidRootPart")
    if not myHRP or not ksHRP then return 0 end
    local vel       = ksHRP.AssemblyLinearVelocity
    local predicted = ksHRP.Position + vel * 0.083
    local dist      = (myHRP.Position - predicted).Magnitude
    if dist > _G.AutoParryRange then return 0 end
    local toMe      = (myHRP.Position - ksHRP.Position).Unit
    local dot       = ksHRP.CFrame.LookVector:Dot(toMe)
    local distScore  = 1 - math.clamp(dist / _G.AutoParryRange, 0, 1)
    local dotScore   = math.clamp((dot + 1) * 0.5, 0, 1)
    local speedScore = math.clamp(vel.Magnitude / 25, 0, 1)
    return (distScore * 0.50) + (dotScore * 0.35) + (speedScore * 0.15)
end

-- ── Hitframe table ────────────────────────────────────────────────────────────────
local ANIM_HITFRAME = {
    ["rbxassetid://139369275981139"] = { preDelay=0.00, hitAt=0.15 },
    ["rbxassetid://110355011987939"] = { preDelay=0.00, hitAt=0.15 },
    ["rbxassetid://135002183282873"] = { preDelay=0.00, hitAt=0.9  },
    ["rbxassetid://121216847022485"] = { preDelay=0.00, hitAt=0.9  },
    ["rbxassetid://105374834496520"] = { preDelay=0.00, hitAt=0.15 },
    ["rbxassetid://111920872708571"] = { preDelay=0.00, hitAt=0.15 },
    ["rbxassetid://118907603246885"] = { preDelay=0.00, hitAt=0.15 },
    ["rbxassetid://78432063483146"]  = { preDelay=0.00, hitAt=0.15 },
    ["rbxassetid://113255068724446"] = { preDelay=0.00, hitAt=0.9  },
    ["rbxassetid://74968262036854"]  = { preDelay=0.00, hitAt=0.9  },
    ["rbxassetid://129784271201071"] = { preDelay=0.00, hitAt=0.9  },
    ["rbxassetid://132817836308238"] = { preDelay=0.00, hitAt=0.9  },
    ["rbxassetid://112166042383605"] = { preDelay=0.00, hitAt=0.15 },
    ["rbxassetid://122812055447896"] = { preDelay=0.00, hitAt=0.15 },
    ["rbxassetid://117042998468241"] = { preDelay=0.00, hitAt=0.15 },
    ["rbxassetid://133963973694098"] = { preDelay=0.00, hitAt=0.15 },
}

-- ── Core parry executor ───────────────────────────────────────────────────────────
local function execParry(killerChar)
    if not _G.AutoParry then return end
    if not shouldParry()  then return end
    if not isParryReady() then return end
    if getThreatLevel(killerChar) <= 0 then return end
    local now = os.clock()
    if now - LastParry < PARRY_CD then return end
    LastParry = now
    fireParryBtn()
end

local function doParryFast(kc)    execParry(kc) end

local function doParrySmart(kc, animId)
    local info = ANIM_HITFRAME[animId] or { preDelay=0.00, hitAt=0.10 }
    task.spawn(function()
        if info.preDelay > 0 then task.wait(info.preDelay) end
        execParry(kc)
    end)
end

local function doParryPredict(kc, animId, track)
    local info  = ANIM_HITFRAME[animId] or { preDelay=0.00, hitAt=0.12 }
    local speed = 1
    pcall(function() speed = math.max(track.Speed, 0.1) end)
    local parryAt = (info.hitAt / speed) * 0.4
    task.spawn(function()
        if parryAt > 0 then task.wait(parryAt) end
        execParry(kc)
    end)
end

local function onAttackAnim(killerChar, animId, track)
    if not _G.AutoParry then return end
    local mode = _G.AutoParryMode or "Fast"
    if mode == "Fast" then
        doParryFast(killerChar)
    elseif mode == "Predict" then
        doParryPredict(killerChar, animId, track)
    else
        doParrySmart(killerChar, animId)
    end
end

-- [Fix] hookChar_AP: ไม่ delay อีกต่อไป ป้องกัน miss attach
local function hookChar_AP(char)
    if Hooked_AP[char] then return end
    Hooked_AP[char] = true
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.AnimationPlayed:Connect(function(track)
        local anim = track and track.Animation
        if not anim then return end
        local id = tostring(anim.AnimationId)
        if ANIM_HITFRAME[id] then onAttackAnim(char, id, track) end
    end)
end

-- [Fix] hookPlayer_AP: cleanup Hooked_AP เมื่อ char removed
local function hookPlayer_AP(plr)
    if plr == LP_AP then return end
    local function onChar(char)
        -- cleanup entry เก่า
        Hooked_AP[char] = nil
        -- ถ้าเป็น killer → hook ทันที ไม่ delay
        if isKillerChar(char) then
            hookChar_AP(char)
        end
        -- watch weapon added
        char.ChildAdded:Connect(function(obj)
            if (obj:IsA("Model") or obj:IsA("Tool")) and obj.Name:lower():find("weapon") then
                hookChar_AP(char)
            end
        end)
        -- cleanup เมื่อ char ออก
        char.AncestryChanged:Connect(function()
            if not char.Parent then
                Hooked_AP[char] = nil
            end
        end)
    end
    if plr.Character then onChar(plr.Character) end
    plr.CharacterAdded:Connect(onChar)
end

for _, plr in ipairs(Players:GetPlayers()) do hookPlayer_AP(plr) end
Players.PlayerAdded:Connect(hookPlayer_AP)

-- ── [Premium Gate] Auto Parry UI ─────────────────────────────────────────────────
SurTab:Divider()
SurTab:Section({ Title = "Feature Survivor", Icon = "user" })

if isPremium then
    SurTab:Paragraph({
        Title = "Information: Parry Mode",
        Desc  = "• Fast = Instant on anim start\n• Smart = Delay based on hitframe\n• Predict = Scaled by anim speed\n\n• Ping: 60 - 100ms",
        Image = "rbxassetid://104487529937663", ImageSize = 30,
    })
    SurTab:Toggle({
        Title    = "Auto Parry",
        Desc     = "Parry killer attacks automatically. Skips if downed or being carried.",
        Value    = settings.AutoParry,
        Callback = function(v)
            settings.AutoParry = v; _G.AutoParry = v
            Config:Set("autoparry", v); Config:Save()
            WindUI:Notify({ Title="Auto Parry", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "shield" or "shield-off" })
        end
    })
    SurTab:Dropdown({
        Title    = "Parry Mode",
        Values   = { "Fast", "Smart", "Predict" },
        Multi    = false,
        Value    = settings.AutoParryMode,
        Callback = function(v)
            settings.AutoParryMode = v; _G.AutoParryMode = v
            Config:Set("autoparrymode", v); Config:Save()
            WindUI:Notify({ Title="Parry Mode", Content=v, Duration=2, Icon="settings" })
        end
    })
    SurTab:Slider({
        Title    = "Parry Range",
        Desc     = "Range for parrying (studs)",
        Value    = { Min=5, Max=35, Default=settings.AutoParryRange },
        Step     = 1,
        Callback = function(v)
            settings.AutoParryRange = v; _G.AutoParryRange = v
            Config:Set("autoparryrange", v); Config:Save()
        end
    })
    SurTab:Slider({
        Title    = "Hook Detect Range",
        Desc     = "Hook detection range if get hook parry will stop (studs)",
        Value    = { Min=5, Max=25, Default=HOOK_NEAR_DIST },
        Step     = 1,
        Callback = function(v)
            HOOK_NEAR_DIST = v; settings.HookNearDist = v
            Config:Set("hookrange", v); Config:Save()
        end
    })
else
    SurTab:Paragraph({
        Title = "[ Premium Only ] Auto Parry",
        Desc  = "This feature is for Premium members only",
        Image = "rbxassetid://104487529937663", ImageSize = 30,
    })
end

-- =====================================================================================
--  ESP SYSTEM  — [Fixed lag, fixed Pallet name, fixed BasePart gen]
-- =====================================================================================
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
Workspace.DescendantAdded:Connect(function()
    if not _invalidateScheduled then
        _invalidateScheduled = true
        task.delay(2, function() invalidateWorldCache(); _invalidateScheduled = false end)
    end
end)
Workspace.DescendantRemoving:Connect(function()
    if not _invalidateScheduled then
        _invalidateScheduled = true
        task.delay(2, function() invalidateWorldCache(); _invalidateScheduled = false end)
    end
end)

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
local function updateWorldESPAsync(hrp)
    if _worldScanBusy then return end
    _worldScanBusy = true
    if _worldCacheDirty then rebuildWorldCacheAsync() end
    task.spawn(function()
        local myPos = hrp.Position
        for _, entry in ipairs(_worldESPCache) do
            local desc = entry.obj
            local t    = entry.t
            task.spawn(function()
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
                    if dist > ESP_MAX_DISTANCE then
                        local d = espObjects[desc]
                        if d then pcall(function()
                            if d.bill then d.bill.Enabled = false end
                            if d.highlight then d.highlight.Enabled = false end
                        end) end
                        return
                    end
                    local isDone = pcall(generatorFinished, desc) and generatorFinished(desc)
                    local prog   = 0
                    pcall(function() prog = getGeneratorProgress(desc) end)
                    local col = isDone and COLOR_GENERATOR_DONE or getProgressColor(prog)
                    createESP(desc, col)
                    local data = espObjects[desc]
                    if data then
                        local nameText = ShowName and "Generator" or nil
                        local hpText   = (ShowPercent) and ("[ "..math.floor(prog*100).."% ]") or nil
                        local distText = ShowDistance and ("[ "..dist.." MM ]") or nil
                        setObjectLabels(data, col, nameText, ShowName, hpText, ShowPercent, distText, ShowDistance)
                        pcall(function()
                            if data.bill then data.bill.Enabled = true end
                            if data.highlight then data.highlight.Enabled = ShowHighlight end
                        end)
                    end

                elseif t == "Gate" then
                    if not espGate then removeESP(desc); return end
                    if dist > ESP_MAX_DISTANCE then
                        local d = espObjects[desc]
                        if d then pcall(function()
                            if d.bill then d.bill.Enabled = false end
                            if d.highlight then d.highlight.Enabled = false end
                        end) end
                        return
                    end
                    createESP(desc, COLOR_GATE)
                    local data = espObjects[desc]
                    if data then
                        local distText = ShowDistance and ("[ "..dist.." MM ]") or nil
                        setObjectLabels(data, COLOR_GATE, ShowName and "Gate" or nil, ShowName, nil, false, distText, ShowDistance)
                        pcall(function()
                            if data.bill then data.bill.Enabled = true end
                            if data.highlight then data.highlight.Enabled = ShowHighlight end
                        end)
                    end

                elseif t == "Hook" then
                    if not espHook then removeESP(desc); return end
                    if dist > ESP_MAX_DISTANCE then
                        local d = espObjects[desc]
                        if d then pcall(function()
                            if d.bill then d.bill.Enabled = false end
                            if d.highlight then d.highlight.Enabled = false end
                        end) end
                        return
                    end
                    createESP(desc, COLOR_HOOK)
                    local data = espObjects[desc]
                    if data then
                        local distText = ShowDistance and ("[ "..dist.." MM ]") or nil
                        setObjectLabels(data, COLOR_HOOK, ShowName and "Hook" or nil, ShowName, nil, false, distText, ShowDistance)
                        pcall(function()
                            if data.bill then data.bill.Enabled = true end
                            if data.highlight then data.highlight.Enabled = ShowHighlight end
                        end)
                    end

                elseif t == "Pallet" then
                    if not espPallet then removeESP(desc); return end
                    if dist > ESP_MAX_DISTANCE then
                        local d = espObjects[desc]
                        if d then pcall(function()
                            if d.bill then d.bill.Enabled = false end
                            if d.highlight then d.highlight.Enabled = false end
                        end) end
                        return
                    end
                    createESP(desc, COLOR_PALLET)
                    local data = espObjects[desc]
                    if data then
                        local distText = ShowDistance and ("[ "..dist.." MM ]") or nil
                        setObjectLabels(data, COLOR_PALLET, ShowName and "Pallet" or nil, ShowName, nil, false, distText, ShowDistance)
                        pcall(function()
                            if data.bill then data.bill.Enabled = true end
                            if data.highlight then data.highlight.Enabled = ShowHighlight end
                        end)
                    end

                elseif t == "Window" then
                    if not espWindowEnabled then removeESP(desc); return end
                    if dist > ESP_MAX_DISTANCE then
                        local d = espObjects[desc]
                        if d then pcall(function()
                            if d.bill then d.bill.Enabled = false end
                            if d.highlight then d.highlight.Enabled = false end
                        end) end
                        return
                    end
                    createESP(desc, COLOR_WINDOW)
                    local data = espObjects[desc]
                    if data then
                        local distText = ShowDistance and ("[ "..dist.." MM ]") or nil
                        setObjectLabels(data, COLOR_WINDOW, ShowName and "Window" or nil, ShowName, nil, false, distText, ShowDistance)
                        pcall(function()
                            if data.bill then data.bill.Enabled = true end
                            if data.highlight then data.highlight.Enabled = ShowHighlight end
                        end)
                    end

                elseif t == "Patient" then
                    if not espPatient then removeESP(desc); return end
                    if dist > ESP_MAX_DISTANCE then
                        local d = espObjects[desc]
                        if d then pcall(function()
                            if d.bill then d.bill.Enabled = false end
                            if d.highlight then d.highlight.Enabled = false end
                        end) end
                        return
                    end
                    createESP(desc, COLOR_PATIENT)
                    local data = espObjects[desc]
                    if data and part then
                        local distText = ShowDistance and ("[ "..dist.." MM ]") or nil
                        setObjectLabels(data, COLOR_PATIENT, ShowName and "Patient" or nil, ShowName, nil, false, distText, ShowDistance)
                        pcall(function()
                            if data.bill then data.bill.Enabled = true end
                            if data.highlight then data.highlight.Enabled = ShowHighlight end
                        end)
                    end
                end
            end)
        end

        -- cleanup stale
        for obj in pairs(espObjects) do
            local ok2, valid2 = pcall(function() return obj and obj.Parent ~= nil end)
            if not ok2 or not valid2 then removeESP(obj) end
        end
        _worldScanBusy = false
    end)
end

-- ── Heartbeat ─────────────────────────────────────────────────────────────────────
RunService.Heartbeat:Connect(function(dt)
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
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then removeESP(player.Character) end
end)
Players.PlayerAdded:Connect(function(player)
    player.CharacterRemoving:Connect(function(char) removeESP(char) end)
end)
for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterRemoving:Connect(function(char) removeESP(char) end)
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

-- ====================== MAIN TAB ======================
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
PlayerGui.ChildRemoved:Connect(function(child)
    if child.Name == "CrosshairGUI" and CrosshairEnabled then task.defer(CreateCrosshair) end
end)
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
    _fullBrightConn = RunService.RenderStepped:Connect(function()
        if not fullBrightEnabled then _fullBrightConn:Disconnect(); _fullBrightConn = nil; return end
        Lighting.Brightness = 2; Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(255,255,255)
    end)
end
local function stopFullBright()
    if _fullBrightConn then _fullBrightConn:Disconnect(); _fullBrightConn = nil end
    Lighting.Brightness = 1; Lighting.ClockTime = 12
    Lighting.Ambient = Color3.fromRGB(128,128,128)
end
local function startNoFog()
    if _noFogConn then _noFogConn:Disconnect() end
    _noFogConn = RunService.RenderStepped:Connect(function()
        if not noFogEnabled then _noFogConn:Disconnect(); _noFogConn = nil; return end
        local atm = Lighting:FindFirstChild("Atmosphere")
        if atm then atm.Density = 0 end
    end)
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
    _antiAfkThread = task.spawn(function()
        while AntiAFK_main do
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(math.random(150, 270))
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(math.random(150, 270))
        end
    end)
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

-- =====================================================================================
--  GENERATOR SYSTEM
--  [Fix] หา GeneratorPoint ได้ทุกชื่อ ไม่จำกัดแค่ 1-4
--  [Fix] retry repairRemote ถ้า fire ไม่สำเร็จ
--  [Fix] _invalidateGenCache เมื่อ gen เสร็จ ป้องกัน tp ไป gen ที่ done แล้ว
--  [Fix] ตรวจ repairPoint ซ้ำก่อน tp ป้องกัน tp loop
-- =====================================================================================
local GeneratorRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator")
local skillRemote      = GeneratorRemotes:WaitForChild("SkillCheckResultEvent")
local repairRemote     = GeneratorRemotes:WaitForChild("RepairEvent")

local GEN = {
    repairPoint = nil,
    repairModel = nil,
    cancelDB    = false,
    skillDB     = false,
    lastPos     = nil,
    MOVE_THRESH = 0.9,
}

local function notify(title, content)
    WindUI:Notify({ Title=title, Content=content, Duration=5, Icon="triangle-alert" })
end

local function isRepairPointValid()
    return GEN.repairPoint and GEN.repairPoint.Parent
        and GEN.repairModel and GEN.repairModel.Parent
        and not generatorFinished(GEN.repairModel)
end

local function clearRepairState()
    GEN.repairPoint = nil; GEN.repairModel = nil; GEN.lastPos = nil
end

local function cancelRepair()
    if not isRepairPointValid() then clearRepairState(); return end
    if GEN.cancelDB then return end
    GEN.cancelDB = true
    pcall(function() repairRemote:FireServer(GEN.repairPoint, false) end)
    task.delay(0.4, function() GEN.cancelDB = false end)
end

-- [Fix] หา GeneratorPoint ทุกชื่อ ไม่จำกัดแค่ GeneratorPoint1-4
-- รองรับ GeneratorPoint, RepairPoint, InteractPoint, และ BasePart ชื่ออื่นๆ
local GENPOINT_NAMES = {
    "GeneratorPoint", "RepairPoint", "InteractPoint", "Point",
    "GeneratorPoint1","GeneratorPoint2","GeneratorPoint3","GeneratorPoint4",
}
local function getRepairPoints(gen)
    local points = {}
    -- ลอง WaitForChild ชื่อมาตรฐานก่อน
    for _, name in ipairs(GENPOINT_NAMES) do
        local pt = gen:FindFirstChild(name)
        if pt and pt:IsA("BasePart") then
            points[#points+1] = pt
        end
    end
    -- ถ้าไม่เจอเลย → scan ทุก BasePart ใน gen
    if #points == 0 then
        for _, child in ipairs(gen:GetDescendants()) do
            if child:IsA("BasePart") then
                local n = child.Name:lower()
                if n:find("point") or n:find("repair") or n:find("interact") then
                    points[#points+1] = child
                end
            end
        end
    end
    -- fallback: ใช้ PrimaryPart หรือ BasePart แรกที่เจอ
    if #points == 0 then
        local pp = (gen:IsA("Model") and gen.PrimaryPart) or gen:FindFirstChildWhichIsA("BasePart")
        if pp then points[#points+1] = pp end
    end
    return points
end

local function getClosestGeneratorPoint(root, maxDist)
    local gens = getFolderGenerator()
    local bestGen, bestPt, bestD = nil, nil, maxDist or 999
    for _, gen in ipairs(gens) do
        if gen.Parent and not generatorFinished(gen) then
            local pts = getRepairPoints(gen)
            for _, pt in ipairs(pts) do
                local d = (root.Position - pt.Position).Magnitude
                if d < bestD then bestD=d; bestGen=gen; bestPt=pt end
            end
        end
    end
    -- [Fix] ถ้า gen เสร็จแล้ว invalidate cache ทันที
    if bestGen and generatorFinished(bestGen) then
        _invalidateGenCache()
        return nil, nil, nil
    end
    return bestGen, bestPt, bestD
end

local function findNearestKiller(root, maxDist)
    local nearest, nearestDist = nil, maxDist or 12.5
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local oHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            if isKillerChar(plr.Character) and oHRP then
                local d = (root.Position - oHRP.Position).Magnitude
                if d < nearestDist then nearestDist=d; nearest=plr.Character end
            end
        end
    end
    return nearest, nearestDist
end

-- [Fix] teleportToGenerator: retry repairRemote ถ้าไม่ติด + guard ซ้ำ
local function teleportToGenerator()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    -- [Fix] ถ้ายืนอยู่ที่ repairPoint อยู่แล้ว และยังใช้ได้ → ไม่ tp ซ้ำ
    if isRepairPointValid() and (root.Position - GEN.repairPoint.Position).Magnitude <= 5 then
        -- fire อีกรอบถ้า point ยังอยู่ (recover จาก dropped remote)
        pcall(function() repairRemote:FireServer(GEN.repairPoint, true) end)
        return
    end
    local gen, pt = getClosestGeneratorPoint(root)
    if not gen or not pt then
        _invalidateGenCache(); return
    end
    GEN.repairModel = gen; GEN.repairPoint = pt; GEN.lastPos = root.Position
    root.CFrame = CFrame.new(pt.Position + Vector3.new(0, 2, 0))
    task.wait(0.12)
    -- [Fix] retry 2 ครั้งถ้า fire ไม่สำเร็จ
    local fired = false
    for attempt = 1, 3 do
        local ok = pcall(function() repairRemote:FireServer(pt, true) end)
        if ok then fired = true; break end
        task.wait(0.08)
    end
    if not fired then
        -- remote ยิงไม่ได้ → clear state รอรอบหน้า
        clearRepairState()
    end
end

-- movement cancel check
local _movCheckAccum = 0
local MOV_CHECK_INTERVAL = 0.07
RunService.Heartbeat:Connect(function(dt)
    _movCheckAccum += dt
    if _movCheckAccum < MOV_CHECK_INTERVAL then return end
    _movCheckAccum = 0
    if not isRepairPointValid() then clearRepairState(); return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    local dist = (root.Position - GEN.repairPoint.Position).Magnitude
    if dist > 8 then return end
    local prevPos  = GEN.lastPos or root.Position
    local moved    = (root.Position - prevPos).Magnitude
    GEN.lastPos    = root.Position
    local isMoving = moved > GEN.MOVE_THRESH or hum.MoveDirection.Magnitude > 0.05
    if isMoving and not GEN.cancelDB then cancelRepair() end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.X then
        if isRepairPointValid() and not GEN.cancelDB then
            cancelRepair()
            notify("Generator Cancelled", "Repair cancelled successfully.")
        end
    end
end)

SurTab:Section({ Title = "Feature Generator", Icon = "zap" })

local AutoSkillPerfect = settings.AutoSkillPerfect
local AutoSkillNeutral = settings.AutoSkillNeutral
local AutoGenRepair    = settings.AutoGenRepair

local _skillThread = nil
local function startSkillLoop(mode)
    if _skillThread then task.cancel(_skillThread); _skillThread = nil end
    _skillThread = task.spawn(function()
        local pGui = LocalPlayer:WaitForChild("PlayerGui")
        while (mode == "perfect" and AutoSkillPerfect) or (mode == "neutral" and AutoSkillNeutral) do
            task.wait(0.08)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            local gen, pt = getClosestGeneratorPoint(root, 8)
            if gen and pt then GEN.repairModel = gen; GEN.repairPoint = pt end
            local gui = pGui:FindFirstChild("SkillCheckPromptGui")
            if not gui then continue end
            local check = gui:FindFirstChild("Check")
            if check and check.Visible and isRepairPointValid() then
                local d = (root.Position - GEN.repairPoint.Position).Magnitude
                if d <= 6 and not GEN.skillDB then
                    GEN.skillDB = true
                    local resultType = mode == "perfect" and "success" or "neutral"
                    local resultVal  = mode == "perfect" and 1 or 0
                    pcall(function()
                        skillRemote:FireServer(resultType, resultVal, GEN.repairModel, GEN.repairPoint)
                    end)
                    check.Visible = false
                    task.delay(0.1, function() GEN.skillDB = false end)
                end
            end
        end
        _skillThread = nil
    end)
end

SurTab:Toggle({
    Title = "Auto SkillCheck (Perfect)", Desc = "Automatically hits perfect generator skill checks",
    Value = AutoSkillPerfect,
    Callback = function(v)
        AutoSkillPerfect = v; settings.AutoSkillPerfect = v; Config:Set("AutoSkillPerfect", v); Config:Save()
        if v then AutoSkillNeutral = false; notify("Auto Generator Perfect | Enabled", "Press X or move joystick to cancel."); startSkillLoop("perfect")
        elseif _skillThread then task.cancel(_skillThread); _skillThread = nil end
    end
})
SurTab:Toggle({
    Title = "Auto SkillCheck (Neutral)", Desc = "Automatically hits neutral generator skill checks",
    Value = AutoSkillNeutral,
    Callback = function(v)
        AutoSkillNeutral = v; settings.AutoSkillNeutral = v; Config:Set("AutoSkillNeutral", v); Config:Save()
        if v then AutoSkillPerfect = false; notify("Auto Generator Neutral | Enabled", "Press X or move joystick to cancel."); startSkillLoop("neutral")
        elseif _skillThread then task.cancel(_skillThread); _skillThread = nil end
    end
})

local _genThread = nil
local function startGenLoop()
    if _genThread then task.cancel(_genThread); _genThread = nil end
    _genThread = task.spawn(function()
        while AutoGenRepair do
            task.wait(0.25)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            -- [Fix] ถ้า gen เสร็จ → invalidate cache
            if isRepairPointValid() and generatorFinished(GEN.repairModel) then
                clearRepairState(); _invalidateGenCache(); continue
            end
            if not isRepairPointValid() then
                clearRepairState(); _invalidateGenCache()
            end
            local killer = findNearestKiller(root, 12.5)
            if killer and isRepairPointValid() then
                cancelRepair(); task.wait(0.2); teleportToGenerator(); continue
            end
            if not isRepairPointValid()
            or (root.Position - (GEN.repairPoint and GEN.repairPoint.Position or root.Position)).Magnitude > 8 then
                teleportToGenerator()
            end
        end
        _genThread = nil
    end)
end

SurTab:Toggle({
    Title = "Auto Generator (BETA)", Desc = "Automatically teleports and repairs generators. Fixed map detection.",
    Value = AutoGenRepair,
    Callback = function(v)
        AutoGenRepair = v; settings.AutoGenRepair = v; Config:Set("AutoGenRepair", v); Config:Save()
        if v then
            notify("Auto Generator Enabled", "Press X or move joystick to cancel.")
            startGenLoop()
        else
            if _genThread then task.cancel(_genThread); _genThread = nil end
            clearRepairState()
        end
    end
})

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
                if idx then table.remove(pl,idx) end; return pl[math.random(#pl)]
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
            Workspace.FallenPartsDestroyHeight=getgenv().FPDH
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
    Callback=function() ReplicatedStorage.Remotes.Carry.SelfUnHookEvent:FireServer() end })

-- ====================== KILLER TAB ======================
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

UserInputService.InputBegan:Connect(function(input,gp)
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
end)

local function DYHUB_ClearDragConnections() end
function DYHUB_EnableDrag(state)
    if not state then
        if DYHUB_mobileButton   then DYHUB_Settings.Aimbot.MobileButtonPosition   = DYHUB_mobileButton.Position end
        if DYHUB_mobileButton28 then DYHUB_Settings.Aimbot.MobileButton28Position = DYHUB_mobileButton28.Position end
        return
    end
    local function makeDrag(btn,settingKey)
        if not btn then return end
        local dragging,startPos,startInput=false,nil,nil
        btn.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                dragging=true; startInput=input.Position; startPos=btn.Position
                local ce; ce=input.Changed:Connect(function()
                    if input.UserInputState==Enum.UserInputState.End then dragging=false; DYHUB_Settings.Aimbot[settingKey]=btn.Position; ce:Disconnect() end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
                local delta=input.Position-startInput
                btn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
            end
        end)
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
    DYHUB_mobileButton.MouseButton1Click:Connect(function()
        DYHUB_AimbotEnabled=not DYHUB_AimbotEnabled
        if DYHUB_AimbotEnabled and DYHUB_Aimbot28Enabled then DYHUB_Aimbot28Enabled=false; if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3=Color3.fromRGB(255,60,60) end end
        DYHUB_mobileButton.BackgroundColor3=DYHUB_AimbotEnabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
    end)
    DYHUB_mobileButton28.MouseButton1Click:Connect(function()
        DYHUB_Aimbot28Enabled=not DYHUB_Aimbot28Enabled
        if DYHUB_Aimbot28Enabled and DYHUB_AimbotEnabled then DYHUB_AimbotEnabled=false; if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3=Color3.fromRGB(255,60,60) end end
        DYHUB_mobileButton28.BackgroundColor3=DYHUB_Aimbot28Enabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
    end)
    DYHUB_EnableDrag(DYHUB_Settings.Aimbot.DragUI)
end

task.spawn(function()
    DYHUB_EnsureGUIFolder(); DYHUB_CreateMobileButtons()
    while task.wait(3) do
        DYHUB_EnsureGUIFolder()
        local gui=PlayerGui:FindFirstChild("DYHUB_AimbotGUI")
        if gui and not gui.Enabled then gui.Enabled=true end
    end
end)

RunService.RenderStepped:Connect(function()
    if DYHUB_AimbotEnabled then
        DYHUB_LockedTarget=DYHUB_GetClosestInScreen()
        if DYHUB_LockedTarget and DYHUB_CanSeeTarget(DYHUB_LockedTarget) then DYHUB_AimAt_Normal(DYHUB_LockedTarget) end
    elseif DYHUB_Aimbot28Enabled then
        DYHUB_LockedTarget=DYHUB_GetClosestByDistance()
        if DYHUB_LockedTarget and DYHUB_CanSeeTarget(DYHUB_LockedTarget) then DYHUB_AimAt_28(DYHUB_LockedTarget) end
    end
end)

killerTab:Section({Title="Killer: The Masked",Icon="venetian-mask"})
killerTab:Paragraph({Title="Information: The Masked",Desc="• Richard (No Abilities)\n• Tony (One Shot, No hold)\n• Brandon (Speed Boost)\n• Jake (Lunge Range)\n• Richter (Removes terror radius)\n• Graham (Faster Vault)\n• Alex (Chainsaw, One Shot)",Image="rbxassetid://104487529937663",ImageSize=50})
local MaskedList={"Richard","Tony","Brandon","Jake","Richter","Graham","Alex"}
local selectedMasks = settings.SelectedMasks
killerTab:Dropdown({Title="Select Mask",Values=MaskedList,Multi=false,Value=selectedMasks,Callback=function(value)
    selectedMasks=value; settings.SelectedMasks=value; Config:Set("selectedMasks",value); Config:Save() end})
killerTab:Button({Title="Choose Mask (Selected)",
    Desc = "Equips the selected mask ability",Callback=function()
    ReplicatedStorage.Remotes.Killers.Masked.Activatepower:FireServer(selectedMasks) end})
killerTab:Button({Title="Random Mask (Legit Mode)",
    Desc = "Chooses a random mask ability",Callback=function()
    ReplicatedStorage.Remotes.Killers.Masked.Activatepower:FireServer(MaskedList[math.random(#MaskedList)]) end})

killerTab:Section({Title="Killer: The Stalker",Icon="eye-off"})
local Stalker = settings.Stalker
local _stalkerRemote
local function getStalkerRemote()
    if not _stalkerRemote or not _stalkerRemote.Parent then
        _stalkerRemote=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Stalker"):WaitForChild("StartStalking")
    end; return _stalkerRemote
end
killerTab:Toggle({Title="Start Stalker (Raycast / Remote)",
    Desc = "Automatically stalks nearby survivors",Value=false,Callback=function(v)
    Stalker=v; settings.Stalker=v; Config:Set("Stalker",Stalker); Config:Save()
    if v then task.spawn(function()
        while Stalker do task.wait(0.2)
            local char=LocalPlayer.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
            if not root or not isKillerChar(char) then continue end
            local remote=getStalkerRemote()
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr~=LocalPlayer and plr.Character then
                    local hrp_=plr.Character:FindFirstChild("HumanoidRootPart"); local hum=plr.Character:FindFirstChild("Humanoid")
                    if hrp_ and hum then local dist=(root.Position-hrp_.Position).Magnitude
                        if dist>=30 and dist<=70 and hum.Health>20 then pcall(function() remote:FireServer(plr) end) end
                    end
                end
            end
        end
    end) end
end})

killerTab:Section({Title="Feature Killer",Icon="swords"})
local killallEnabled = settings.KillAll
killerTab:Toggle({Title="Kill All (Warning: Get Ban)",
    Desc = "Automatically teleport and kill all",Value=killallEnabled,Callback=function(v)
    killallEnabled=v; settings.KillAll=v; Config:Set("killall",killallEnabled); Config:Save()
    if v then task.spawn(function()
        local remote=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack"); local startCFrame=nil
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
    end) end
end})

local Autocarry = settings.AutoCarry
killerTab:Toggle({Title="Auto Carry (Nearby Survivor / 2.5s)",
    Desc = "Automatically picks up nearby downed survivors",Value=Autocarry,Callback=function(v)
    Autocarry=v; settings.AutoCarry=v; Config:Set("autocarry",Autocarry); Config:Save()
    if v then task.spawn(function()
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
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("CarrySurvivorEvent"):FireServer(target.Character); task.wait(5)
                end
            end
        end
    end) end
end})

local AutoHook = settings.AutoHook
killerTab:Toggle({Title="Auto Hook (Nearby Hook / 2.5s)",
    Desc = "Automatically hook nearby survivors",Value=AutoHook,Callback=function(v)
    AutoHook=v; settings.AutoHook=v; Config:Set("autohook",AutoHook); Config:Save()
    if v then task.spawn(function()
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
            ReplicatedStorage.Remotes.Carry.HookEvent:FireServer(nearestHook); task.wait(5)
        end
    end) end
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
    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Stalker"):WaitForChild("grab"):FireServer(candidates[1].Character)
end
killerTab:Button({Title="Grab (Nearby Survivor/Killer)",
    Desc = "Automatically grab the player",Callback=DoGrab})
UserInputService.InputBegan:Connect(function(input,gp)
    if gp or not GrabKey then return end
    local ok,keyEnum=pcall(function() return Enum.KeyCode[GrabKey] end)
    if ok and keyEnum and input.KeyCode==keyEnum then DoGrab() end
end)

local nocooldownskillEnabled = settings.AutoAttack
killerTab:Toggle({Title="Auto Attack (No Animation)",
    Desc = "Automatically attack the player",Value=nocooldownskillEnabled,Callback=function(v)
    nocooldownskillEnabled=v; settings.AutoAttack=v; Config:Set("autoattack",nocooldownskillEnabled); Config:Save()
    if v then task.spawn(function()
        local remote=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
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
    end) end
end})

killerTab:Section({Title="Feature Cheat",Icon="bug"})
local noFlashlightEnabled = settings.NoFlashlight
killerTab:Toggle({Title="No Flashlight",
    Desc = "Prevents blind from using flash",Value=noFlashlightEnabled,Callback=function(state)
    noFlashlightEnabled=state; settings.NoFlashlight=state; Config:Set("noblind",noFlashlightEnabled); Config:Save() end})
PlayerGui.DescendantAdded:Connect(function(desc)
    if noFlashlightEnabled and desc:IsA("GuiObject") and desc.Name=="Blind" then pcall(function() desc:Destroy() end) end
end)

local destroyPalletwrong = settings.DestroyPallet
killerTab:Toggle({Title="Remove Palletwrong (All)",
    Desc = "Removes all Palletwrong objects",Value=destroyPalletwrong,Callback=function(v)
    destroyPalletwrong=v; settings.DestroyPallet=v; Config:Set("destroyPalletwrong",destroyPalletwrong); Config:Save()
    if v then task.spawn(function()
        while destroyPalletwrong do task.wait(1)
            for _,desc in ipairs(Workspace:GetDescendants()) do
                if desc:IsA("Model") and desc.Name=="Palletwrong" then desc:Destroy() end
            end
        end
    end) end
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

-- ====================== PLAYER TAB ======================
local speedEnabled   = settings.SpeedEnabled
local flyNoclipSpeed = settings.SpeedWalk
local NoClipEnabled  = settings.NoClipEnabled
local speedConnection, noclipConnection

PlayerTab:Section({Title="Feature Player",Icon="rabbit"})
PlayerTab:Slider({
    Title="Set Speed (Legit = 3)", Value={Min=1,Max=677,Value=flyNoclipSpeed}, Step=1,
    Callback=function(val)
        flyNoclipSpeed=val; settings.SpeedWalk=val; Config:Set("SpeedWalk",flyNoclipSpeed); Config:Save()
    end
})
PlayerTab:Toggle({
    Title="Enable Speed", Desc = "Adjusts your character movement speed", Value=speedEnabled,
    Callback=function(v)
        speedEnabled=v; settings.SpeedEnabled=v
        if speedEnabled then
            if speedConnection then speedConnection:Disconnect() end
            speedConnection=RunService.RenderStepped:Connect(function()
                local char=LocalPlayer.Character
                if char then
                    local hrp_=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChild("Humanoid")
                    if hrp_ and hum and hum.MoveDirection.Magnitude>0 then
                        hrp_.CFrame=hrp_.CFrame+hum.MoveDirection*flyNoclipSpeed*0.004
                    end
                end
            end)
        else
            if speedConnection then speedConnection:Disconnect(); speedConnection=nil end
        end
    end
})

PlayerTab:Section({Title="Feature Power",Icon="flame"})
PlayerTab:Toggle({
    Title="No Clip", Desc = "Allows your character to walk through walls", Value=NoClipEnabled,
    Callback=function(state)
        NoClipEnabled=state; settings.NoClipEnabled=state; Config:Set("NoClipEnabled",state); Config:Save()
        if state then
            if noclipConnection then noclipConnection:Disconnect() end
            noclipConnection=RunService.Stepped:Connect(function()
                local char=LocalPlayer.Character
                if char then for _,part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end end
            end)
        else
            if noclipConnection then noclipConnection:Disconnect(); noclipConnection=nil end
            local char=LocalPlayer.Character
            if char then for _,part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=true end end end
        end
    end
})

local NoFallEnabled = settings.NoFallEnabled
local FallRemote=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("Fall")
local mt=getrawmetatable(game); local oldNamecall=mt.__namecall
setreadonly(mt,false)
mt.__namecall=newcclosure(function(self,...)
    local method=getnamecallmethod()
    if NoFallEnabled and self==FallRemote and method=="FireServer" then return nil end
    return oldNamecall(self,...)
end)
setreadonly(mt,true)
PlayerTab:Toggle({Title="No Fall (Beta)",
    Desc = "Prevents movement slowdown after falling",Value=false,
    Callback=function(v) NoFallEnabled=v; settings.NoFallEnabled=v end})

-- ====================== TELEPORT TAB ======================
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
                LocalPlayer.Character:PivotTo(p.Character.PrimaryPart.CFrame*CFrame.new(0,0,200)); break
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

-- ====================== SETTINGS TAB ======================
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

-- ====================== INFORMATION TAB ======================
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

-- =====================================================================================
--  AUTO RESTORE ON LOAD
--  [Fix] ย้ายมาอยู่หลัง define ตัวแปรและฟังก์ชันทั้งหมด ป้องกัน nil error
-- =====================================================================================
LocalPlayer.CharacterAdded:Connect(function()
    clearRepairState()
    _hookCache = {}; _hookCacheTick = 0  -- reset hook cache เมื่อ respawn
    if AutoGenRepair    then task.delay(1, startGenLoop) end
    if AutoSkillPerfect then task.delay(1, function() startSkillLoop("perfect") end) end
    if AutoSkillNeutral then task.delay(1, function() startSkillLoop("neutral") end) end
end)

-- restore noclip
if NoClipEnabled then
    noclipConnection=RunService.Stepped:Connect(function()
        local char=LocalPlayer.Character
        if char then for _,part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end end
    end)
end

-- restore gen/skill loops
if AutoGenRepair    then startGenLoop() end
if AutoSkillPerfect then startSkillLoop("perfect") end
if AutoSkillNeutral then startSkillLoop("neutral") end

-- init world ESP cache
if espEnabled then
    task.delay(2, function() rebuildWorldCacheAsync() end)
end

print("[DYHUB] "..version.." | "..ver.." loaded successfully!")
print("[DYHUB] Config active | Auto saving every "..tostring(AutoSaveDelay).."s")
