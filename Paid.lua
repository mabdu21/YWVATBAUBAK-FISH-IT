-- v191 | [Local Register Fix]
-- =========================
version = "Rework"
ver = "v023.93"
-- =========================

-- ====================== LOAD UI ======================
WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ====================== GameLoad ======================
repeat task.wait() until game:IsLoaded()

-- ====================== LoadingGui ======================
p = game:GetService("Players").LocalPlayer
pg = p:WaitForChild("PlayerGui")

function waitLoadingGone(maxWait)
    maxWait = tonumber(maxWait) or 18
    local gui = pg:FindFirstChild("LoadingGui")
    if not gui then return true end

    WindUI:Notify({ Title = "Initialization", Content = "Game is loading, Please wait.", Duration = 3, Icon = "download" })

    local startedAt = tick()
    while gui and gui.Parent and tick() - startedAt < maxWait do
        task.wait(0.1)
    end

    if gui and gui.Parent then
        warn("[DYHUB] LoadingGui did not disappear in time, continuing safely.")
        return false
    end

    return true
end

waitLoadingGone(18)

WindUI:Notify({ Title = "Initialization", Content = "Load complete, Starting in 2 seconds.", Duration = 2, Icon = "shield-check" })
task.wait(2)

-- ====================== WAITING PART / FPS UNLOCK ======================
DYHUB_WAITING_PART_NAME = "DYHUB_WAITING_PART"
iddyhub = "rbxassetid://104487529937663"
DYHUB_WAITING_STAND_CF = CFrame.new(-23.3435822, 67, 0.341766357)
DYHUB_WAITING_PART_CF = CFrame.new(-23.3435822, 63.95, 0.341766357)
DYHUB_WAITING_PART_SIZE = Vector3.new(16, 1, 16)
-- Keep it visible enough to stand on, but avoid expensive decals/textures.
DYHUB_WAITING_PART_VISIBLE_TRANSPARENCY = 1

function GetDYHUBWaitingStandCFrame()
    return DYHUB_WAITING_STAND_CF
end

function EnsureDYHUBWaitingPartImages(waitingPart)
    if not waitingPart or not waitingPart:IsA("BasePart") then return end

    local usedFaces = {}

    for _, obj in ipairs(waitingPart:GetChildren()) do
        if obj:IsA("Decal") and obj.Name == "dyhub_image" then
            if usedFaces[obj.Face] then
                obj:Destroy()
            else
                usedFaces[obj.Face] = obj
                obj.Texture = iddyhub
                obj.Transparency = 0
            end
        end
    end

    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
        if not usedFaces[face] then
            local decal = Instance.new("Decal")
            decal.Name = "dyhub_image"
            decal.Texture = iddyhub
            decal.Face = face
            decal.Transparency = 0
            decal.Parent = waitingPart
        end
    end
end

function ConfigureDYHUBWaitingPart(waitingPart)
    if not waitingPart or not waitingPart:IsA("BasePart") then return nil end

    waitingPart.Name = DYHUB_WAITING_PART_NAME
    waitingPart.Size = DYHUB_WAITING_PART_SIZE
    waitingPart.CFrame = DYHUB_WAITING_PART_CF
    waitingPart.Anchored = true
    waitingPart.CanTouch = false
    waitingPart.CanQuery = false
    waitingPart.CastShadow = false
    waitingPart.Material = Enum.Material.SmoothPlastic
    waitingPart.Color = Color3.fromRGB(45, 130, 255)
    waitingPart.TopSurface = Enum.SurfaceType.Smooth
    waitingPart.BottomSurface = Enum.SurfaceType.Smooth

    local active = AutoFarmEnabled == true
    waitingPart.CanCollide = active
    waitingPart.Transparency = active and DYHUB_WAITING_PART_VISIBLE_TRANSPARENCY or 1

	EnsureDYHUBWaitingPartImages(waitingPart)
	
	return waitingPart
end

function GetDYHUBWaitingPart()
    local keep = nil
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == DYHUB_WAITING_PART_NAME and obj:IsA("BasePart") then
            if not keep then
                keep = obj
            else
                pcall(function() obj:Destroy() end)
            end
        end
    end
    return keep
end

function DestroyDYHUBWaitingPart()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == DYHUB_WAITING_PART_NAME and obj:IsA("BasePart") then
            pcall(function() obj:Destroy() end)
        end
    end
end

function EnsureDYHUBWaitingPart()
    local waitingPart = GetDYHUBWaitingPart()
    if not waitingPart then
        waitingPart = Instance.new("Part")
        waitingPart.Name = DYHUB_WAITING_PART_NAME
        waitingPart.Parent = workspace
    end
    return ConfigureDYHUBWaitingPart(waitingPart)
end

-- Do not create the waiting part while Auto Farm is off.
-- UpdateDYHUBWaitingPartCollision() will create/destroy it after config loads.

if setfpscap then
    setfpscap(240) -- 1000000 can max CPU/GPU and cause stutter
    WindUI:Notify({ Title = "Service", Content = "FPS Unlocked! | " .. ver, Duration = 3, Icon = "cpu" })
    warn("FPS Unlocked!")
else
    WindUI:Notify({ Title = "Not Working", Content = "Your exploit does not support setfpscap.", Duration = 3, Icon = "ban" })
end

-- ====================== CUSTOM CONFIG SYSTEM ======================
HttpService = game:GetService("HttpService")
ConfigFolder = "DYHUB_STBB"

CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self = setmetatable({}, CustomConfig)
    self.ConfigData = {}
    self.ConfigPath = ConfigFolder .. "/STBB_config.json"
    if isfolder and makefolder and not isfolder(ConfigFolder) then
        pcall(function() makefolder(ConfigFolder) end)
    end
    self:Load()
    return self
end

function CustomConfig:Set(key, value) self.ConfigData[key] = value end

function CustomConfig:Get(key, default)
    if self.ConfigData[key] ~= nil then return self.ConfigData[key] end
    return default
end

function CustomConfig:Save(force)
    if not writefile then return false end

    local now = tick()
    if not force and self._LastSaveAt and now - self._LastSaveAt < 0.75 then
        if not self._SaveQueued then
            self._SaveQueued = true
            task.delay(0.85, function()
                self._SaveQueued = false
                self:Save(true)
            end)
        end
        return true
    end

    local success, err = pcall(function()
        writefile(self.ConfigPath, HttpService:JSONEncode(self.ConfigData))
    end)

    if success then
        self._LastSaveAt = now
        return true
    else
        warn("[DYHUB] Save failed:", err)
        return false
    end
end

function CustomConfig:Load()
    if isfile and readfile and isfile(self.ConfigPath) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(self.ConfigPath))
        end)
        if success and type(result) == "table" then
            self.ConfigData = result
        else
            warn("[DYHUB] Failed to load config, using defaults")
            self.ConfigData = {}
        end
    else
        self.ConfigData = {}
    end
end

function CustomConfig:AutoSave(interval)
    if self._AutoSaveThread then
        pcall(function() task.cancel(self._AutoSaveThread) end)
        self._AutoSaveThread = nil
    end
    self._AutoSaveThread = task.spawn(function()
        while true do
            task.wait(interval or 15)
            self:Save()
        end
    end)
end

Config = CustomConfig.new()
-- Auto save is started later from the Setting tab, so only one save loop exists.

-- ====================== WINDOW 2 ======================
Players = game:GetService("Players")

FreeVersion    = "Free Version"
PremiumVersion = "Premium Version"
ExtraVersion   = "Extra Version"

function getData(url)
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then return nil end
    local func = loadstring(response)
    if func then return func() end
    return nil
end

function checkVersion(playerName)
    local extraData = getData("https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/STBBList.lua")
    if extraData and extraData[playerName] then return ExtraVersion end
    local premiumData = getData("https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua")
    if premiumData and premiumData[playerName] then return PremiumVersion end
    return FreeVersion
end

player    = Players.LocalPlayer
userversion = checkVersion(player.Name)

-- ====================== WINDOW ======================
Window = WindUI:CreateWindow({
    Title = "DYHUB",
    IconThemed = true,
    Icon = "rbxassetid://104487529937663",
    Author = "STBB | " .. userversion,
    Folder = "DYHUB",
    Size = UDim2.fromOffset(550, 380),
    Transparent = true,
    Theme = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.K)

Window:Tag({ Title = version, Color = Color3.fromHex("#db7093") })

Window:EditOpenButton({
    Title = "DYHUB - Open",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 255, 255)),
    Draggable = true
})

-- ====================== TABS ======================
Info   = Window:Tab({ Title = "Information", Icon = "info" })
MainDivider  = Window:Divider()
Main   = Window:Tab({ Title = "Main", Icon = "rocket" })
Main4  = Window:Tab({ Title = "Esp", Icon = "eye" })
Main2  = Window:Tab({ Title = "Player", Icon = "user" })
MainDivider1 = Window:Divider()
Main5  = Window:Tab({ Title = "Shop", Icon = "shopping-cart" })
Main6  = Window:Tab({ Title = "Collect", Icon = "hand" })
Main7  = Window:Tab({ Title = "Gamemode", Icon = "gamepad-2" })
MainDivider2 = Window:Divider()
Main3  = Window:Tab({ Title = "Setting", Icon = "settings" })
Window:SelectTab(1)

-- ======================== INFO ========================
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

Info:Section({ Title = "Lasted Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({
    Title = "Update: 07/03/2026 | CL: " .. ver,
    Desc = [[• [ Added ] Auto Farm support for zombie act 2
• [ Added ] New Mode, New Item Collect
• [ Fixed ] Auto Collect failed descendant scan.
• [ Optimized ] Check list for collect descendant scan.]],
})
Info:Divider()
Info:Section({ Title = "Discord Information", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()

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

InviteCode = "jWNDPNMmyB"
DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

function LoadDiscordInfo()
    local success, result = pcall(function()
        local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
        if not httpRequest then return nil end
        local response = httpRequest({ Url = DiscordAPI, Method = "GET", Headers = { ["User-Agent"] = "RobloxBot/1.0", ["Accept"] = "application/json" } })
        if response and response.Body then return game:GetService("HttpService"):JSONDecode(response.Body) end
        return nil
    end)

    if success and result and result.guild then
        local DiscordInfo = Info:Paragraph({
            Title = result.guild.name,
            Desc = ' <font color="#52525b">●</font> Member Count : ' .. tostring(result.approximate_member_count) ..
                   '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(result.approximate_presence_count),
            Image = "https://cdn.discordapp.com/icons/" .. result.guild.id .. "/" .. result.guild.icon .. ".png?size=1024",
            ImageSize = 42,
        })

        Info:Button({
            Title = "Update Info",
            Callback = function()
                local updated, updatedResult = pcall(function()
                    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
                    if not httpRequest then return nil end
                    local response = httpRequest({ Url = DiscordAPI, Method = "GET" })
                    if response and response.Body then return game:GetService("HttpService"):JSONDecode(response.Body) end
                    return nil
                end)
                if updated and updatedResult and updatedResult.guild then
                    DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : ' .. tostring(updatedResult.approximate_member_count) .. '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(updatedResult.approximate_presence_count))
                    WindUI:Notify({ Title = "Discord Info Updated", Content = "Successfully refreshed Discord statistics", Duration = 2, Icon = "refresh-cw" })
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
        Info:Paragraph({ Title = "Error fetching Discord Info", Desc = "Unable to load Discord information.", Image = "triangle-alert", ImageSize = 26, Color = "Red" })
    end
end

LoadDiscordInfo()

Info:Divider()
Info:Section({ Title = "DYHUB Information", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()

Info:Paragraph({ Title = "Main Owner", Desc = "@dyumraisgoodguy#8888", Image = "rbxassetid://119789418015420", ImageSize = 30 })

Info:Paragraph({
    Title = "Social",
    Desc = "Copy link social media for follow!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Buttons = { { Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://guns.lol/DYHUB") end } }
})

Info:Paragraph({
    Title = "Discord",
    Desc = "Join our discord for more scripts!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Buttons = { { Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://discord.gg/jWNDPNMmyB") end } }
})

-- ====================== SERVICES ======================
TweenService        = game:GetService("TweenService")
ReplicatedStorage   = game:GetService("ReplicatedStorage")
ReplicatedFirst     = game:GetService("ReplicatedFirst")
VirtualInputManager = game:GetService("VirtualInputManager")
RunService          = game:GetService("RunService")
UserInputService    = game:GetService("UserInputService")
Lighting            = game:GetService("Lighting")

-- ====================== PLAYER ======================
LocalPlayer    = Players.LocalPlayer
Client         = LocalPlayer
Character      = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ====================== GLOBAL TABLES ======================
GlobalTables = {
    redeemCodes = { "100MVisit2", "100MVisit1", "CamArmada", "CCTVBase", "ADelayedGameIsEventuallyGoodButRushedGameIsForeverBad" },
    Weapon   = { "Stungun", "Flamethrower", "Harpoon Gun", "Shot Gun", "Pulse Rifle", "Shot Harpoon Gun", "EPD", "Small Laser Gun" },
    MiscShop = { "HeadPhone", "Grenade", "Jetpack", "Lens" },
    RequestTitanSpeaker = { "Titan-Request", "SpecialTitan-Request", "Speaker-Request" },
    Gamepasst = { "All", "LuckyBoost", "RareLuckyBoost", "LegendaryLuckyBoost" },
    Gamepassts = {},
}

-- ====================== CONFIG VARIABLES ======================
skillList          = { "Q", "E", "R", "T", "Y", "G", "H", "Z", "X", "C", "V", "B", "U", "F" }
skillDropdownValues = { "All", "Q", "E", "R", "T", "Y", "G", "H", "Z", "X", "C", "V", "B", "U", "F" }

-- ====================== FARM  HELPERS ======================
function NormalizeFarmMode(mode)
    mode = tostring(mode or "Tween")
    if mode == "tp" or mode == "Tp" or mode == "tp1" then
        return "Teleport"
    end
    if mode ~= "Teleport" and mode ~= "Tween" then
        return "Tween"
    end
    return mode
end

function NormalizeFarmTargetMode(mode)
    mode = tostring(mode or "Normal Mode")
    if mode ~= "Normal Mode" and mode ~= "Astro Holdout Mode" and mode ~= "Dark Dimension Mode" then
        return "Normal Mode"
    end
    return mode
end

function NormalizeCollectMovement(mode)
    mode = tostring(mode or "Tween")
    if mode ~= "Teleport" and mode ~= "Tween" then
        return "Tween"
    end
    return mode
end

function IsPaidUserVersion()
    return userversion == PremiumVersion or userversion == ExtraVersion
end

-- ====================== CAMERA MODE HELPERS ======================
function NormalizeCameraMode(mode)
    mode = tostring(mode or "Manual")
    if mode == "Manuel" or mode:lower() == "manual" then
        return "Manual"
    end
    if mode:lower() == "classic" then
        return "Classic"
    end
    return "Manual"
end

-- ====================== STATE VARIABLES ======================
AutoFarmEnabled        = Config:Get("AutoFarmEnabled", false)
FarmPosition           = Config:Get("FarmPosition", "Above")
FarmMode               = NormalizeFarmMode(Config:Get("FarmMode", "Tween"))
FarmTargetMode         = NormalizeFarmTargetMode(Config:Get("FarmTargetMode", "Normal Mode"))
if not IsPaidUserVersion() then FarmTargetMode = "Normal Mode" end
DarkDimensionCollecting = false
DarkDimensionLowValue   = 0.900
DarkDimensionSafeValue  = 0.950
DarkDimensionLastWarnAt = 0
DarkDimensionCollectToken = 0
DarkDimensionOrbSearchCooldown = 0
DarkDimensionJeffreyAvoidRange = 70
JeffreyTargetBlockUntil = {}
JeffreyLastUnsafeTargetAt = 0
JeffreySafeHoldUntil = 0
JeffreySafeRetargetDelay = 0.85
AntiJeffreyEnabled     = Config:Get("AntiJeffreyEnabled", false)
AntiJeffreyRange       = Config:Get("AntiJeffreyRange", 50)
BypassJeffreyEnabled   = Config:Get("BypassJeffreyEnabled", false)
BypassJeffreyLoopRunning = false
BypassJeffreyLastFullScanAt = 0
BypassJeffreyFullScanDelay = 3
AntiJeffreyLoopRunning = false
AntiJeffreyGuardLoopRunning = false
AntiJeffreyLastPushAt  = 0
JeffreyCacheList       = {}
JeffreyCacheAt         = 0
JeffreyCacheTTL        = 0.55
AntiJeffreyEscapeBusy  = false
AntiJeffreyLastEscapeAt = 0
AntiJeffreyEscapeCooldown = 0.32
AntiJeffreyEscapeStep  = 70
AntiJeffreyDangerRange = 20
AntiJeffreyKillZoneRange = 5
AntiJeffreyHardEscapeStep = 70
AntiJeffreyCriticalEscapeStep = 90
AntiJeffreyEscapePauseUntil = 0
AntiJeffreyForceRetargetUntil = 0
AstroModeDoorTopCF      = CFrame.new(-23.3435822, 67, 0.341766357)
AstroModeDoorBottomCF   = CFrame.new(-23.3435822, 3, 0.341766357)
AstroModeFinalRunning   = false
AstroModeLastFinalAt    = 0
MiscOptions            = Config:Get("MiscOptions", {})
SyncFarmOnly           = Config:Get("SyncFarmOnly", true)
FarmAstroTokenEnabled  = Config:Get("FarmAstroTokenEnabled", false)
FarmAstroTokenRunning  = false
FarmAstroTokenPart     = nil
FarmAstroTokenTween    = nil
FarmAstroTokenNoClipConnection = nil
FarmAstroTokenPauseCollect = false
FarmAstroTokenLastCleanNotify = 0
FarmAstroTokenLastAutoFarmNotify = 0
FarmAstroTokenTimerHold = false
FarmAstroTokenTimerIgnoreUntil = 0
FarmAstroTokenRespawnCounter = 0
FarmAstroGodModePaused = false
FarmAstroReviveGodTriggered = false
FarmAstroFinalLockActive = false
FarmAstroTimerDropping = false
FarmAstroBottomGodTriggered = false
FarmAstroWaveTimerArmed = false
FarmAstroLastWaveTimer = nil
FarmAstroReviveTimerArmed = false
FarmAstroLastReviveTimer = nil
AutoAttackEnabled      = false
AutoSkillEnabled       = false
AutoSkipHeliEnabled    = false
BoostFPS_Active_dummy  = false -- managed by BoostFPS system
AutoStartEnabled       = Config:Get("AutoStartEnabled", table.find(MiscOptions, "Auto Start") ~= nil)
AutoVoteinGameEnabled = Config:Get("AutoVoteinGameEnabled", false)
AutoVoteValue         = Config:Get("AutoVoteValue", "Christmas")
AutoVoteLoopRunning   = false
AutoVoteLastFireAt    = 0
AutoStartLastReadyAt  = 0
AutoFillUpEnabled      = false
SelectedSkills         = Config:Get("SelectedSkills", { "All" })
SafeModeEnabled        = false
SafeValue              = Config:Get("SafeValue", 50)
GodModeEnabled         = false
GodModeValue           = Config:Get("GodModeValue", 50)
GodModeTriggered       = false
ResetWaveEnabled       = false
ResetWaveValue         = Config:Get("ResetWaveValue", 10)
ResetWaveLoopRunning   = false
ResetWaveTeleporting   = false
ResetWaveTargetCF      = CFrame.new(1250, 500, 1250)
ResetWaveHoldTime      = 2
ResetWaveToken         = 0
ResetWaveLastTriggeredWave = nil
ResetWaveLastTriggeredKey  = nil
ResetWaveLastTeleportAt = 0
WaitingRespawn         = false
IdlePosition           = GetDYHUBWaitingStandCFrame() * CFrame.Angles(math.rad(0), 0, 0)
IdleHoldDistance       = 12       -- distance allowed before re-teleporting to idle
IdleTeleportCooldown   = 1.25     -- prevents repeated idle teleport / camera shake
LastIdleTeleportAt     = 0
IdlePositionReached    = false
SkillDelay             = Config:Get("SkillDelay", 1)
LoopDelay              = 0.5
TweenSpeed             = 1
HeightValue            = Config:Get("HeightValue", 3)
NeedNoClip             = false
LockActive             = false
AutoStartConnection    = nil
noBarrierConnection    = nil
noBarrierActive        = Config:Get("NoBarrier", false)
CameraMode             = NormalizeCameraMode(Config:Get("CameraMode", "Manual"))
if Config:Get("CameraMode", "Manual") ~= CameraMode then
    Config:Set("CameraMode", CameraMode)
end
FarmLoopRunning        = false
AutoAttackLoopRunning  = false
AutoSkillLoopRunning   = false
FarmForceRetarget      = false
FarmCollecting         = false
CombatDebugEnabled     = Config:Get("CombatDebugEnabled", false)
CombatDebugCooldowns   = {}

function UpdateDYHUBWaitingPartCollision()
    if AutoFarmEnabled ~= true then
        if DestroyDYHUBWaitingPart then DestroyDYHUBWaitingPart() end
        part = nil
        return
    end

    local waitingPart = EnsureDYHUBWaitingPart and EnsureDYHUBWaitingPart() or GetDYHUBWaitingPart()
    if not waitingPart then return end

    part = waitingPart
    pcall(function()
        ConfigureDYHUBWaitingPart(waitingPart)
    end)
end

UpdateDYHUBWaitingPartCollision()

workspace.ChildRemoved:Connect(function(obj)
    if obj and obj.Name == DYHUB_WAITING_PART_NAME and AutoFarmEnabled == true then
        task.defer(function()
            UpdateDYHUBWaitingPartCollision()
        end)
    end
end)

function CombatDebug(tag, message, cooldown, showNotify)
    if not CombatDebugEnabled then return end
    cooldown = cooldown or 3
    local now = tick()
    local key = tostring(tag or "Debug")

    if CombatDebugCooldowns[key] and now - CombatDebugCooldowns[key] < cooldown then return end
    CombatDebugCooldowns[key] = now

    local text = "[DYHUB][" .. key .. "] " .. tostring(message or "")
    print(text)

    if showNotify and WindUI then
        pcall(function()
            WindUI:Notify({
                Title = "Combat Debug",
                Content = tostring(message or ""),
                Duration = 3,
                Icon = "bug"
            })
        end)
    end
end

function IsMiscFarmAllowed()
	if FarmAstroTokenEnabled and SyncFarmOnly then return false end
	return AutoFarmEnabled or not SyncFarmOnly
end

function StopMiscFarmRuntime(reason)
    -- Runtime-only stop. It does not remove saved MiscOptions, so systems can resume when Auto Farm is enabled again.
    AutoAttackEnabled = false
    AutoSkillEnabled = false
    AutoSkipHeliEnabled = false
    AutoFillUpEnabled = false
    SafeModeEnabled = false
    GodModeEnabled = false
    ResetWaveEnabled = false
    ResetWaveTeleporting = false
    ResetWaveToken = (ResetWaveToken or 0) + 1
    ResetWaveLastTriggeredWave = nil
    ResetWaveLastTriggeredKey = nil
    FillUpRunning = false

    if AutoStartEnabled then
        StopAutoStart()
    end

    pcall(function() TriggerAutoSkipHeli(false) end)

    if BoostFPS_Active then
        RestoreBoostFPS()
    end

    CombatDebug("MiscGate", "Misc Farm runtime stopped: " .. tostring(reason or "sync gate"), 3)
end

function ApplyMiscFarmGate(reason)
    if SyncFarmOnly and not AutoFarmEnabled then
        StopMiscFarmRuntime(reason or "Auto Farm is off")
        return false
    end
    HandleMiscOptions(MiscOptions)
    return true
end

CameraLastApplyAt = 0
CameraApplyCooldown = 0.22
CameraSyncToken = 0

function GetCameraTargetForMode(char)
    if not char or not char.Parent then return nil, nil end

    local humanoid = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")

    if CameraMode == "Classic" then
        return char:FindFirstChild("Head") or humanoid or char:FindFirstChild("HumanoidRootPart"), humanoid
    end

    -- Manual: Roblox default-feel camera. This avoids shake while farm/tween systems move the character.
    return humanoid or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"), humanoid
end

function ApplyCameraMode(force)
    local now = tick()
    if force ~= true and now - (CameraLastApplyAt or 0) < (CameraApplyCooldown or 0.22) then return end
    CameraLastApplyAt = now

    pcall(function()
        local cam = workspace.CurrentCamera
        local char = LocalPlayer.Character or Character
        if not cam or not char then return end

        CameraMode = NormalizeCameraMode(CameraMode)
        local target, humanoid = GetCameraTargetForMode(char)
        if not target then return end

        -- Do not fight farming movement. Only restore autorotate when the farm lock is not controlling it.
        if humanoid and not AutoFarmEnabled and not LockActive and not FarmCollecting then
            humanoid.AutoRotate = true
        end

        if cam.CameraType ~= Enum.CameraType.Custom then
            cam.CameraType = Enum.CameraType.Custom
        end

        -- Write only when needed so the camera will not reset/flicker and will not lag from spam writes.
        if cam.CameraSubject ~= target then
            cam.CameraSubject = target
        end
    end)
end

function RequestCameraSync(force)
    CameraSyncToken = (CameraSyncToken or 0) + 1
    local token = CameraSyncToken
    task.delay(force and 0 or 0.05, function()
        if token == CameraSyncToken then
            ApplyCameraMode(force == true)
        end
    end)
end

LastFarmCameraStabilize = 0

function StabilizeFarmCamera()
    local now = tick()
    if now - (LastFarmCameraStabilize or 0) < 0.35 then return end
    LastFarmCameraStabilize = now

    -- Keep every camera rewrite synced with the Setting tab instead of forcing Humanoid every time.
    if AutoFarmEnabled then
        ApplyCameraMode(false)
    end
end

function RestoreFarmCameraAndMovement()
    pcall(function()
        local char = LocalPlayer.Character or Character
        local humanoid = char and (char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid"))
        if humanoid then humanoid.AutoRotate = true end
        ApplyCameraMode(true)
    end)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    RequestCameraSync(true)
end)

MissingRemoteWarnAt = {}

function GetRemote(name)
    local remote = ReplicatedStorage and ReplicatedStorage:FindFirstChild(name)
    if not remote then
        local now = tick()
        if not MissingRemoteWarnAt[name] or now - MissingRemoteWarnAt[name] >= 10 then
            MissingRemoteWarnAt[name] = now
            warn("[DYHUB] Missing remote: " .. tostring(name))
        end
        return nil
    end
    return remote
end

-- ====================== AUTO VOTE CORE / AUTO START SYNC ======================
function GetVoteUIFrame()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    local voteGui = playerGui:FindFirstChild("OpenVoteUI")
    if not voteGui then return nil end

    return voteGui:FindFirstChild("OPEN UI")
end

function IsVoteUIOpen()
    local frame = GetVoteUIFrame()
    return frame and frame.Visible == true
end

function HideVoteUI()
    local frame = GetVoteUIFrame()
    if frame then
        pcall(function() frame.Visible = false end)
    end
end

function FireAutoVote(force)
    if not force and not IsVoteUIOpen() then return false end

    local now = tick()
    if now - AutoVoteLastFireAt < 0.25 then return false end
    AutoVoteLastFireAt = now

    local remote = GetRemote("Vote")
    if not remote then
        pcall(function() remote = ReplicatedStorage:WaitForChild("Vote", 3) end)
    end
    if not remote then return false end

    local ok, err = pcall(function()
        remote:FireServer(AutoVoteValue)
    end)

    if ok then
        HideVoteUI()
        print("[DYHUB] Auto Vote fired:", tostring(AutoVoteValue))
        return true
    else
        warn("[DYHUB] Auto Vote failed:", err)
        return false
    end
end

function StartAutoVoteLoop()
    if AutoVoteLoopRunning then return end
    AutoVoteLoopRunning = true

    task.spawn(function()
        while AutoVoteinGameEnabled do
            if IsVoteUIOpen() then
                if AutoStartEnabled and IsMiscFarmAllowed() then
                    -- Auto Start always calls Auto Vote first when both systems are enabled.
                    FireGetReady(0)
                else
                    FireAutoVote(false)
                end
            end
            task.wait(0.2)
        end

        AutoVoteLoopRunning = false
    end)
end

-- ====================== NEW PRIORITY SYSTEM CONFIG ======================
-- มอนที่เลือดสูงสุดต่ำกว่า HighHPThreshold จะถูกข้ามไป → ไปฆ่ามอนปกติที่ใกล้ที่สุดแทน
HighHPThreshold        = Config:Get("HighHPThreshold", 200)
-- สัญญาณ interrupt: เมื่อ priority mob ระดับสูงกว่าปรากฏ ให้หยุดมอนปัจจุบันทันที
_currentTargetPriority = 0   -- 0=idle 1=NearMob 2=HighHP 3=Heli 4=GiantST
_interruptSignal       = false

VirtualUser = game:GetService("VirtualUser")
AntiAFK = Config:Get("AntiAfk", true)

AutoBuyWeaponEnabled   = Config:Get("AutoBuyWeaponEnabled", false)
AutoBuyMiscEnabled     = Config:Get("AutoBuyMiscEnabled", false)
SelectedWeapon         = Config:Get("SelectedWeapon", "Stungun")
SelectedMiscItem       = Config:Get("SelectedMiscItem", "HeadPhone")

-- ====================== FILL UP PART CONFIG ======================
FILLUP_PART_PATH   = { "HelicopterShop", "ShopXDD", "PartForShop" }
FILLUP_TARGET_POS  = Vector3.new(44.2756729, 26.3595276, -32.7318268)
FILLUP_POS_THRESHOLD = 0.5
FillUpRunning = false

function GetFillUpPart()
    local obj = workspace
    for _, key in ipairs(FILLUP_PART_PATH) do
        obj = obj:FindFirstChild(key)
        if not obj then return nil end
    end
    return obj
end

function IsFillUpPartReady()
    local p = GetFillUpPart()
    if not p then return false end
    return (p.CFrame.Position - FILLUP_TARGET_POS).Magnitude < FILLUP_POS_THRESHOLD
end

-- ====================== ALLY SYSTEM ======================
AllyNames = {
    ["Heavy Soldier Toilet V2"]  = true,
    ["Quad Laser Toilet"]        = true,
    ["Strider Rocket Laser"]     = true,
    ["Helicopter Camera"]        = true,
    ["Heavy Soldier Toilet V1"]  = true,
    ["Rocket Heli v2"]           = true,
    ["Gunner Camera man"]        = true,
    ["Attack Helicopter"]        = true,
    ["Swat Mutant"]              = true,
    ["Huge DJ Toilet"]           = true,
}

function IsAlly(mob)
    return AllyNames[mob.Name] ~= nil
end

-- ====================== TP SYSTEM ======================
function tp(pu79)
    pcall(function()
        if not pu79 or not pu79.Target then return end
        local v80 = Client and Client.Character
        if not v80 then return end
        local hum = v80:FindFirstChildOfClass("Humanoid") or v80:FindFirstChild("Humanoid")
        local hrp = v80:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hum and hum.Sit == true then hum.Sit = false end
        NeedNoClip = true
        hrp.CFrame = pu79.Target * (pu79.Mod or CFrame.new(0, 0, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

function Tp(p82)
    pcall(function()
        if not p82 then return end
        local char = Client and Client.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hum and hum.Sit == true then hum.Sit = false end
        for _, v86 in ipairs(char:GetDescendants()) do
            if v86:IsA("BasePart") then v86.CanCollide = false end
        end
        if not hrp:FindFirstChild("BodyClip") then
            local v87 = Instance.new("BodyVelocity")
            v87.Parent = hrp
            v87.Name = "BodyClip"
            v87.Velocity = Vector3.new(0, 0, 0)
            v87.MaxForce = Vector3.new(5, math.huge, 5)
        end
        hrp.CFrame = p82
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

function tp1(p89)
    local v90 = game.Players.LocalPlayer
    if v90 and v90.Character and v90.Character:FindFirstChild("HumanoidRootPart") then
        v90.Character:FindFirstChild("HumanoidRootPart").CFrame = p89
    else
        warn("Player's character or HumanoidRootPart not found!")
    end
end

-- ====================== UTILITY FUNCTIONS ======================
function IsValidMob(obj)
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
        if Players:GetPlayerFromCharacter(obj) then return false end
        if IsAlly(obj) then return false end
        local humanoid = obj:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then return true end
    end
    return false
end

function IsMobDead(mob)
    if not mob or not mob.Parent then return true end
    local humanoid = mob:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return true end
    return false
end

function GetObjectRootPart(obj)
    if not obj or not obj.Parent then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

function IsJeffreyName(name)
    local n = tostring(name or ""):lower()
    return n == "jeffrey" or n == "jeffery"
end

function IsValidJeffreyObject(obj)
    if not obj or not IsJeffreyName(obj.Name) then return false end
    if obj:IsA("Model") then
        local hum = obj:FindFirstChildOfClass("Humanoid") or obj:FindFirstChild("Humanoid")
        if hum and hum.Health <= 0 then return false end
        return GetObjectRootPart(obj) ~= nil
    end
    return obj:IsA("BasePart") and obj.Parent ~= nil
end

function AddJeffreyRootFromObject(obj, list, seen)
    if obj and IsJeffreyName(obj.Name) and IsValidJeffreyObject(obj) then
        local root = GetObjectRootPart(obj)
        if root and not seen[root] then
            seen[root] = true
            table.insert(list, root)
        end
    end
end

function GetJeffreyRoots(forceRefresh)
    local now = tick()
    if not forceRefresh and now - JeffreyCacheAt <= JeffreyCacheTTL then return JeffreyCacheList end

    local list, seen = {}, {}
    pcall(function()
        for _, obj in ipairs(workspace:GetChildren()) do
            AddJeffreyRootFromObject(obj, list, seen)
        end

        local living = workspace:FindFirstChild("Living")
        if living then
            for _, obj in ipairs(living:GetDescendants()) do
                AddJeffreyRootFromObject(obj, list, seen)
            end
        end

        -- Fallback only when common locations did not find Jeffrey/Jeffery.
        if #list == 0 then
            for _, obj in ipairs(workspace:GetDescendants()) do
                AddJeffreyRootFromObject(obj, list, seen)
            end
        end
    end)

    JeffreyCacheList = list
    JeffreyCacheAt = now
    return JeffreyCacheList
end

function GetNearestJeffreyRoot(pos, range, forceRefresh)
    if not pos then return nil, math.huge end
    local best, bestDist = nil, math.huge
    for _, root in ipairs(GetJeffreyRoots(forceRefresh == true)) do
        if root and root.Parent then
            local dist = (root.Position - pos).Magnitude
            if dist < bestDist then
                best = root
                bestDist = dist
            end
        end
    end
    if range and bestDist > range then return nil, bestDist end
    return best, bestDist
end

function IsJeffreyNearPosition(pos, range, forceRefresh)
    local root = GetNearestJeffreyRoot(pos, range or AntiJeffreyRange, forceRefresh == true)
    return root ~= nil
end

function GetMobRootPart(mob)
    if not mob or not mob.Parent then return nil end
    return mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart", true)
end

function IsMobBlockedByJeffrey(mob, range)
    if not mob or not mob.Parent then return true end
    if IsJeffreyName(mob.Name) or IsMobTemporarilyBlocked(mob) then return true end
    local root = GetMobRootPart(mob)
    if not root then return true end
    range = math.max(range or DarkDimensionJeffreyAvoidRange, 65)
    if IsPositionBlockedByJeffrey(root.Position, range, false) then
        MarkMobUnsafeByJeffrey(mob, 2.5)
        return true
    end
    local cf = nil
    pcall(function() cf = GetTargetCFrame(mob, FarmPosition) end)
    if cf and IsPositionBlockedByJeffrey(cf.Position, range, false) then
        MarkMobUnsafeByJeffrey(mob, 2.5)
        return true
    end
    return false
end

function IsFarmJeffreyAvoidActive()
    if FarmTargetMode == "Dark Dimension Mode" then return AutoFarmEnabled == true end
    if FarmTargetMode == "Normal Mode" then return AutoFarmEnabled == true and AntiJeffreyEnabled == true end
    return false
end

function GetFarmJeffreyAvoidRange()
    if AntiJeffreyEnabled then return AntiJeffreyRange end
    return DarkDimensionJeffreyAvoidRange
end

function IsAntiJeffreyEscapePauseActive()
    return tick() < (AntiJeffreyEscapePauseUntil or 0)
end

function BreakFarmLockForJeffrey(reason, pauseTime)
    pauseTime = pauseTime or 0.35
    AntiJeffreyEscapePauseUntil = math.max(AntiJeffreyEscapePauseUntil or 0, tick() + pauseTime)
    AntiJeffreyForceRetargetUntil = math.max(AntiJeffreyForceRetargetUntil or 0, tick() + pauseTime + 0.2)
    FarmForceRetarget = true
    LockActive = false
    _interruptSignal = true
    WaitingRespawn = false

    pcall(function()
        RefreshCombatCharacter()
        if Character then
            local humanoid = Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Sit = false
                humanoid.AutoRotate = false
            end
        end
        if HumanoidRootPart then
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    task.delay(pauseTime + 0.25, function()
        if tick() >= (AntiJeffreyForceRetargetUntil or 0) and not FarmCollecting and not DarkDimensionCollecting then
            FarmForceRetarget = false
            _interruptSignal = false
        end
    end)
end

function GetMinJeffreyDistanceAt(pos, forceRefresh)
    local minDist = math.huge
    for _, root in ipairs(GetJeffreyRoots(forceRefresh == true)) do
        if root and root.Parent then
            local d = (root.Position - pos).Magnitude
            if d < minDist then minDist = d end
        end
    end
    return minDist
end

function GetHorizontalDistance(a, b)
    if not a or not b then return math.huge end
    local dx = a.X - b.X
    local dz = a.Z - b.Z
    return math.sqrt(dx * dx + dz * dz)
end

function GetMinJeffreyHorizontalDistanceAt(pos, forceRefresh)
    local minDist = math.huge
    for _, root in ipairs(GetJeffreyRoots(forceRefresh == true)) do
        if root and root.Parent then
            local d = GetHorizontalDistance(root.Position, pos)
            if d < minDist then minDist = d end
        end
    end
    return minDist
end

function IsPositionBlockedByJeffrey(pos, range, forceRefresh)
    if not pos then return true end
    range = range or GetFarmJeffreyAvoidRange()
    return GetMinJeffreyHorizontalDistanceAt(pos, forceRefresh == true) <= range
end

function MarkMobUnsafeByJeffrey(mob, duration)
    if not mob then return end
    JeffreyTargetBlockUntil[mob] = tick() + (duration or 2.5)
    JeffreyLastUnsafeTargetAt = tick()
end

function IsMobTemporarilyBlocked(mob)
    if not mob then return true end
    local untilTime = JeffreyTargetBlockUntil[mob]
    if untilTime and tick() < untilTime then return true end
    if untilTime then JeffreyTargetBlockUntil[mob] = nil end
    return false
end

function HasAnyJeffreyRoot()
    local roots = GetJeffreyRoots(false)
    return roots and #roots > 0
end

function GetFarmTargetDangerRange()
    local base = GetFarmJeffreyAvoidRange and GetFarmJeffreyAvoidRange() or 50
    return math.max(base, DarkDimensionJeffreyAvoidRange or 70, 65)
end

function IsFarmTargetSafeFromJeffrey(mob, forceRefresh)
    if not IsFarmJeffreyAvoidActive or not IsFarmJeffreyAvoidActive() then return true end
    if not mob or not mob.Parent then return false end
    if IsJeffreyName(mob.Name) or IsMobTemporarilyBlocked(mob) then return false end

    local root = GetMobRootPart(mob)
    if not root then return false end

    local range = GetFarmTargetDangerRange()
    if IsPositionBlockedByJeffrey(root.Position, range, forceRefresh == true) then
        MarkMobUnsafeByJeffrey(mob, 2.5)
        return false
    end

    local cf = nil
    pcall(function() cf = GetTargetCFrame(mob, FarmPosition) end)
    if cf and IsPositionBlockedByJeffrey(cf.Position, range, forceRefresh == true) then
        MarkMobUnsafeByJeffrey(mob, 2.5)
        return false
    end

    return true
end


-- ============================================================
-- =============== BARRIER SAFE ESCAPE SYSTEM ==================
-- Keeps Jeffrey escape inside workspace.Map.Barrier.
-- The Barrier model can contain many BaseParts with the same name.
-- ============================================================
BarrierCacheParts = {}
BarrierCacheAt = 0
BarrierCacheTTL = 1.25
BarrierBoundsCache = nil
BarrierBoundsAt = 0
BarrierInsetPadding = 8
BarrierRayPadding = 7

function GetMapBarrierModel()
    local map = workspace:FindFirstChild("Map")
    if not map then return nil end
    return map:FindFirstChild("Barrier")
end

function GetBarrierParts(forceRefresh)
    local now = tick()
    if not forceRefresh and now - (BarrierCacheAt or 0) <= (BarrierCacheTTL or 1.25) then
        return BarrierCacheParts or {}
    end

    local parts = {}
    local model = GetMapBarrierModel()
    if model then
        for _, obj in ipairs(model:GetDescendants()) do
            if obj:IsA("BasePart") then
                table.insert(parts, obj)
            end
        end
        if model:IsA("BasePart") then
            table.insert(parts, model)
        end
    end

    BarrierCacheParts = parts
    BarrierCacheAt = now
    BarrierBoundsCache = nil
    return BarrierCacheParts
end

function AddBarrierCornerToBounds(pos, bounds)
    if not pos then return end
    if pos.X < bounds.minX then bounds.minX = pos.X end
    if pos.X > bounds.maxX then bounds.maxX = pos.X end
    if pos.Z < bounds.minZ then bounds.minZ = pos.Z end
    if pos.Z > bounds.maxZ then bounds.maxZ = pos.Z end
end

function GetBarrierBounds(forceRefresh)
    local now = tick()
    if not forceRefresh and BarrierBoundsCache and now - (BarrierBoundsAt or 0) <= (BarrierCacheTTL or 1.25) then
        return BarrierBoundsCache
    end

    local parts = GetBarrierParts(forceRefresh == true)
    if not parts or #parts == 0 then
        BarrierBoundsCache = nil
        return nil
    end

    local bounds = { minX = math.huge, maxX = -math.huge, minZ = math.huge, maxZ = -math.huge }
    for _, part in ipairs(parts) do
        if part and part.Parent and part:IsA("BasePart") then
            local sx, sy, sz = part.Size.X * 0.5, part.Size.Y * 0.5, part.Size.Z * 0.5
            local xs = { -sx, sx }
            local ys = { -sy, sy }
            local zs = { -sz, sz }
            for _, x in ipairs(xs) do
                for _, y in ipairs(ys) do
                    for _, z in ipairs(zs) do
                        AddBarrierCornerToBounds((part.CFrame * CFrame.new(x, y, z)).Position, bounds)
                    end
                end
            end
        end
    end

    if bounds.minX == math.huge or bounds.maxX == -math.huge or bounds.minZ == math.huge or bounds.maxZ == -math.huge then
        BarrierBoundsCache = nil
        return nil
    end

    BarrierBoundsCache = bounds
    BarrierBoundsAt = now
    return BarrierBoundsCache
end

function ClampValue(v, mn, mx)
    if mn > mx then
        local mid = (mn + mx) * 0.5
        return mid
    end
    if v < mn then return mn end
    if v > mx then return mx end
    return v
end

function ClampPositionInsideBarrier(pos, padding, forceRefresh)
    if not pos then return nil, false end
    local bounds = GetBarrierBounds(forceRefresh == true)
    if not bounds then return pos, false end

    padding = padding or BarrierInsetPadding or 8
    local minX, maxX = bounds.minX + padding, bounds.maxX - padding
    local minZ, maxZ = bounds.minZ + padding, bounds.maxZ - padding
    local x = ClampValue(pos.X, minX, maxX)
    local z = ClampValue(pos.Z, minZ, maxZ)
    local clamped = Vector3.new(x, pos.Y, z)
    return clamped, (math.abs(x - pos.X) > 0.05 or math.abs(z - pos.Z) > 0.05)
end

function IsPositionInsideBarrier(pos, padding, forceRefresh)
    if not pos then return false end
    local bounds = GetBarrierBounds(forceRefresh == true)
    if not bounds then return true end
    padding = padding or BarrierInsetPadding or 8
    return pos.X >= bounds.minX + padding and pos.X <= bounds.maxX - padding
        and pos.Z >= bounds.minZ + padding and pos.Z <= bounds.maxZ - padding
end

function RaycastBarrierPath(fromPos, toPos, forceRefresh)
    if not fromPos or not toPos then return nil end
    local parts = GetBarrierParts(forceRefresh == true)
    if not parts or #parts == 0 then return nil end

    local direction = toPos - fromPos
    if direction.Magnitude <= 0.1 then return nil end

    local params = RaycastParams.new()
    pcall(function() params.FilterType = Enum.RaycastFilterType.Include end)
    if tostring(params.FilterType):find("Include") == nil then
        pcall(function() params.FilterType = Enum.RaycastFilterType.Whitelist end)
    end
    params.FilterDescendantsInstances = parts
    params.IgnoreWater = true

    local ok, result = pcall(function()
        return workspace:Raycast(fromPos, direction, params)
    end)
    if ok then return result end
    return nil
end

function GetBarrierSafeEscapePosition(fromPos, wantedPos, forceRefresh)
    if not fromPos or not wantedPos then return nil, false end

    local adjusted = false
    local safePos, wasClamped = ClampPositionInsideBarrier(wantedPos, BarrierInsetPadding, forceRefresh == true)
    if wasClamped then adjusted = true end

    local hit = RaycastBarrierPath(fromPos, safePos, forceRefresh == true)
    if hit and hit.Position then
        local dir = safePos - fromPos
        if dir.Magnitude > 0.1 then
            safePos = hit.Position - dir.Unit * (BarrierRayPadding or 7)
            adjusted = true
        end
    end

    local safePos2, wasClamped2 = ClampPositionInsideBarrier(safePos, BarrierInsetPadding, false)
    if wasClamped2 then adjusted = true end
    safePos = safePos2

    -- Last guard: if the point still looks outside, stay inside current arena instead of crossing the wall.
    if not IsPositionInsideBarrier(safePos, BarrierInsetPadding, false) then
        safePos = ClampPositionInsideBarrier(fromPos, BarrierInsetPadding, false)
        adjusted = true
    end

    return safePos, adjusted
end

workspace.DescendantAdded:Connect(function(obj)
    if obj and obj:IsA("BasePart") and obj.Name == "Barrier" then
        BarrierCacheAt = 0
        BarrierBoundsCache = nil
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    if obj and obj:IsA("BasePart") and obj.Name == "Barrier" then
        BarrierCacheAt = 0
        BarrierBoundsCache = nil
    end
end)

function MoveToJeffreySafeHold(reason)
    if not HasAnyJeffreyRoot() then return false end
    BreakFarmLockForJeffrey(reason or "Jeffrey safe hold", 0.55)
    local cf = GetBestJeffreyEscapeCFrame(math.max(AntiJeffreyHardEscapeStep or 70, 85), true)
    if not cf then return false end
    JeffreySafeHoldUntil = tick() + 0.7
    return MoveFarmSpecialCFrame(cf, 0.18)
end

function ValidateFarmTargetBeforeMove(mob, reason)
    if IsFarmTargetSafeFromJeffrey(mob, true) then return true end
    BreakFarmLockForJeffrey(reason or "unsafe target near Jeffrey", 0.55)
    MoveToJeffreySafeHold(reason or "unsafe target safe hold")
    return false
end

function GetBestJeffreyEscapeCFrame(step, forceRefresh)
    RefreshCombatCharacter()
    if not Character or not HumanoidRootPart then return nil end

    step = step or AntiJeffreyHardEscapeStep or 70
    local base = HumanoidRootPart.Position
    local look = HumanoidRootPart.CFrame.LookVector
    local dirs = {
        Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1), Vector3.new(0,0,-1),
        Vector3.new(1,0,1), Vector3.new(1,0,-1), Vector3.new(-1,0,1), Vector3.new(-1,0,-1),
    }
    local steps = { step, step * 0.75, step * 0.5, step * 0.32 }

    local bestPos, bestScore = nil, -math.huge
    for _, tryStep in ipairs(steps) do
        for _, dir in ipairs(dirs) do
            local unit = dir.Unit
            local wanted = Vector3.new(base.X + unit.X * tryStep, base.Y, base.Z + unit.Z * tryStep)
            local pos, adjusted = GetBarrierSafeEscapePosition(base, wanted, forceRefresh == true)
            if pos then
                local moveDist = (pos - base).Magnitude
                if moveDist >= 2 then
                    local score = GetMinJeffreyHorizontalDistanceAt(pos, forceRefresh == true) + math.min(moveDist, step) * 0.03
                    if adjusted then score = score - 6 end
                    if score > bestScore then
                        bestScore = score
                        bestPos = pos
                    end
                end
            end
        end
    end

    if not bestPos then
        bestPos = ClampPositionInsideBarrier(base, BarrierInsetPadding, true)
    end
    if not bestPos then return nil end
    return CFrame.new(bestPos, bestPos + look)
end

function GetJeffreyEscapeCFrame(range, step, forceRefresh)
    RefreshCombatCharacter()
    if not Character or not HumanoidRootPart then return nil end
    range = range or GetFarmJeffreyAvoidRange()
    step = step or AntiJeffreyEscapeStep or 70

    local jeffrey = GetNearestJeffreyRoot(HumanoidRootPart.Position, range, forceRefresh == true)
    if not jeffrey then return nil end

    return GetBestJeffreyEscapeCFrame(step, forceRefresh == true)
end

function MoveAwayFromJeffrey(range, step, tweenTime, forceCritical)
    RefreshCombatCharacter()
    if not Character or not HumanoidRootPart then return false end

    range = range or GetFarmJeffreyAvoidRange()
    local scanRange = math.max(range, AntiJeffreyDangerRange or 20)
    local jeffrey, dist = GetNearestJeffreyRoot(HumanoidRootPart.Position, scanRange, forceCritical == true)
    if not jeffrey then return false end

    local now = tick()
    local isKillZone = dist <= (AntiJeffreyKillZoneRange or 5)
    local isDanger = dist <= (AntiJeffreyDangerRange or 20)

    if AntiJeffreyEscapeBusy and not isKillZone then return true end
    if not isKillZone and now - AntiJeffreyLastEscapeAt < AntiJeffreyEscapeCooldown then return true end

    if isKillZone then
        step = math.max(step or 0, AntiJeffreyCriticalEscapeStep or 90)
        tweenTime = 0.08
    elseif isDanger then
        step = math.max(step or 0, AntiJeffreyHardEscapeStep or 70)
        tweenTime = tweenTime or 0.16
    else
        step = math.max(step or 0, AntiJeffreyEscapeStep or 70)
        tweenTime = tweenTime or 0.28
    end

    local cf = GetBestJeffreyEscapeCFrame(step, true)
    if not cf then return false end

    AntiJeffreyEscapeBusy = true
    AntiJeffreyLastEscapeAt = now
    BreakFarmLockForJeffrey("Jeffrey escape", isKillZone and 0.65 or 0.45)

    local ok = false
    if MoveFarmSpecialCFrame then
        ok = MoveFarmSpecialCFrame(cf, tweenTime)
    else
        pcall(function() Character:PivotTo(cf) end)
        ok = true
    end

    task.wait(0.03)
    pcall(function()
        if HumanoidRootPart then
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    AntiJeffreyEscapeBusy = false
    return ok
end

function HandleFarmJeffreyEmergency(mob)
    RefreshCombatCharacter()
    if not Character or not HumanoidRootPart then return false end

    local active = IsFarmJeffreyAvoidActive()
    if not active and not AntiJeffreyEnabled then return false end

    local range = math.max(GetFarmJeffreyAvoidRange(), DarkDimensionJeffreyAvoidRange or 70, AntiJeffreyDangerRange or 20)
    local scanRange = math.max(range, AntiJeffreyDangerRange or 20)
    local jeffrey, dist = GetNearestJeffreyRoot(HumanoidRootPart.Position, scanRange, true)

    if jeffrey and dist <= (AntiJeffreyKillZoneRange or 5) then
        MoveAwayFromJeffrey(scanRange, AntiJeffreyCriticalEscapeStep, 0.08, true)
        return true
    end

    if jeffrey and dist <= (AntiJeffreyDangerRange or 20) then
        MoveAwayFromJeffrey(scanRange, AntiJeffreyHardEscapeStep, 0.16, true)
        return true
    end

    if active and mob and not IsFarmTargetSafeFromJeffrey(mob, true) then
        MarkMobUnsafeByJeffrey(mob, 3)
        BreakFarmLockForJeffrey("target blocked by Jeffrey", 0.55)
        MoveToJeffreySafeHold("target blocked by Jeffrey")
        return true
    end

    if active and not mob and HasAnyJeffreyRoot() and tick() < (JeffreySafeHoldUntil or 0) then
        BreakFarmLockForJeffrey("Jeffrey safe hold wait", 0.35)
        return true
    end

    if active and not mob and HasAnyJeffreyRoot() and tick() - (JeffreyLastUnsafeTargetAt or 0) <= 2 then
        MoveToJeffreySafeHold("all targets unsafe near Jeffrey")
        return true
    end

    if active and not mob and jeffrey and dist <= range then
        MoveAwayFromJeffrey(scanRange, AntiJeffreyHardEscapeStep, 0.22, true)
        return true
    end

    return false
end

function ShouldFarmRetargetFromJeffrey(mob)
    return HandleFarmJeffreyEmergency(mob)
end

function ShouldDarkDimensionRetargetFromJeffrey(mob)
    return HandleFarmJeffreyEmergency(mob)
end

function PushAwayFromJeffrey()
    if not AntiJeffreyEnabled then return false end
    RefreshCombatCharacter()
    if not Character or not HumanoidRootPart then return false end

    local jeffrey, dist = GetNearestJeffreyRoot(HumanoidRootPart.Position, math.max(AntiJeffreyRange, AntiJeffreyDangerRange or 20), false)
    if not jeffrey then return false end

    local now = tick()
    if dist > (AntiJeffreyDangerRange or 20) and now - AntiJeffreyLastPushAt < 0.25 then return true end
    AntiJeffreyLastPushAt = now

    if dist <= (AntiJeffreyDangerRange or 20) or AutoFarmEnabled then
        return MoveAwayFromJeffrey(math.max(AntiJeffreyRange, AntiJeffreyDangerRange or 20), AntiJeffreyHardEscapeStep, 0.16, dist <= 20)
    end

    local pushSize = math.clamp(((AntiJeffreyRange - dist) / math.max(AntiJeffreyRange, 1)) * 18, 5, 28)
    local targetCF = GetBestJeffreyEscapeCFrame(pushSize, false)
    if not targetCF then return false end

    if MoveFarmSpecialCFrame then
        return MoveFarmSpecialCFrame(targetCF, 0.18)
    end

    pcall(function()
        Character:PivotTo(targetCF)
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end)
    return true
end

function StartAntiJeffreyLoop()
    if AntiJeffreyLoopRunning then return end
    AntiJeffreyLoopRunning = true
    task.spawn(function()
        while AntiJeffreyEnabled do
            pcall(PushAwayFromJeffrey)
            task.wait(0.18)
        end
        AntiJeffreyLoopRunning = false
    end)
end

function IsJeffreyGuardActive()
    return (AutoFarmEnabled == true and IsFarmJeffreyAvoidActive and IsFarmJeffreyAvoidActive()) or AntiJeffreyEnabled == true
end

function StartJeffreyGuardLoop()
    if AntiJeffreyGuardLoopRunning then return end
    AntiJeffreyGuardLoopRunning = true
    task.spawn(function()
        while AutoFarmEnabled or AntiJeffreyEnabled do
            if IsJeffreyGuardActive() then
                pcall(function()
                    RefreshCombatCharacter()
                    if Character and HumanoidRootPart then
                        local range = math.max(GetFarmJeffreyAvoidRange and GetFarmJeffreyAvoidRange() or 50, AntiJeffreyDangerRange or 20)
                        local root, dist = GetNearestJeffreyRoot(HumanoidRootPart.Position, range, true)
                        if root and dist <= (AntiJeffreyDangerRange or 20) then
                            HandleFarmJeffreyEmergency(nil)
                        elseif AntiJeffreyEnabled and root and dist <= AntiJeffreyRange then
                            PushAwayFromJeffrey()
                        end
                    end
                end)
            end
            task.wait(IsAntiJeffreyEscapePauseActive() and 0.08 or 0.16)
        end
        AntiJeffreyGuardLoopRunning = false
    end)
end


-- ============================================================
-- ====================== BYPASS JEFFREY ======================
-- Makes every Jeffrey/Jeffery NotHumanoid sit. Uses event hooks +
-- slow fallback scan so it will not spam GetDescendants every frame.
-- ============================================================
function GetBypassJeffreyObject(obj)
    if not obj then return nil end
    if IsJeffreyName(obj.Name) then return obj end

    local cur = obj.Parent
    while cur and cur ~= workspace do
        if IsJeffreyName(cur.Name) then return cur end
        cur = cur.Parent
    end

    return nil
end

function SetBypassJeffreySit(jeffrey)
    if not BypassJeffreyEnabled then return false end
    if not jeffrey or not jeffrey.Parent then return false end

    local target = GetBypassJeffreyObject(jeffrey)
    if not target or not target.Parent then return false end

    local notHumanoid = nil
    pcall(function()
        notHumanoid = target:FindFirstChild("NotHumanoid") or target:FindFirstChild("NotHumanoid", true)
    end)
    if not notHumanoid then return false end

    local ok = pcall(function()
        if notHumanoid.Sit ~= true then
            notHumanoid.Sit = true
        end
    end)

    return ok
end

function ScanBypassJeffreys(forceFullScan)
    if not BypassJeffreyEnabled then return 0 end

    local count = 0
    local seen = {}

    local function try(obj)
        local target = GetBypassJeffreyObject(obj)
        if target and not seen[target] then
            seen[target] = true
            if SetBypassJeffreySit(target) then
                count = count + 1
            end
        end
    end

    pcall(function()
        for _, obj in ipairs(workspace:GetChildren()) do
            if IsJeffreyName(obj.Name) then try(obj) end
        end

        local living = workspace:FindFirstChild("Living")
        if living then
            for _, obj in ipairs(living:GetChildren()) do
                if IsJeffreyName(obj.Name) then try(obj) end
            end
            for _, obj in ipairs(living:GetDescendants()) do
                if obj.Name == "NotHumanoid" then try(obj) end
            end
        end

        local now = tick()
        if forceFullScan or now - (BypassJeffreyLastFullScanAt or 0) >= (BypassJeffreyFullScanDelay or 3) then
            BypassJeffreyLastFullScanAt = now
            for _, obj in ipairs(workspace:GetDescendants()) do
                if IsJeffreyName(obj.Name) or obj.Name == "NotHumanoid" then
                    try(obj)
                end
            end
        end
    end)

    return count
end

function StartBypassJeffreyLoop()
    if BypassJeffreyLoopRunning then return end
    BypassJeffreyLoopRunning = true

    task.spawn(function()
        while BypassJeffreyEnabled do
            pcall(function()
                ScanBypassJeffreys(false)
            end)
            task.wait(0.75)
        end

        BypassJeffreyLoopRunning = false
    end)
end

function HandleBypassJeffreyObject(obj)
    if not BypassJeffreyEnabled or not obj then return end

    if IsJeffreyName(obj.Name) or obj.Name == "NotHumanoid" or GetBypassJeffreyObject(obj) then
        task.defer(function()
            if BypassJeffreyEnabled then
                SetBypassJeffreySit(obj)
                task.wait(0.15)
                SetBypassJeffreySit(obj)
            end
        end)
    end
end


workspace.DescendantAdded:Connect(function(obj)
    if obj and IsJeffreyName(obj.Name) then
        JeffreyCacheAt = 0
        HandleBypassJeffreyObject(obj)
        if IsFarmJeffreyAvoidActive and IsFarmJeffreyAvoidActive() then
            FarmForceRetarget = true
            task.delay(0.25, function()
                if not IsAntiJeffreyEscapePauseActive() then FarmForceRetarget = false end
            end)
            StartJeffreyGuardLoop()
        end
    elseif obj and obj.Name == "NotHumanoid" then
        HandleBypassJeffreyObject(obj)
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    if obj and IsJeffreyName(obj.Name) then
        JeffreyCacheAt = 0
        if BypassJeffreyEnabled then
            task.delay(0.15, function()
                if BypassJeffreyEnabled then ScanBypassJeffreys(false) end
            end)
        end
    end
end)

function GetMobMaxHP(mob)
    local humanoid = mob and mob:FindFirstChild("Humanoid")
    if not humanoid then return 0 end
    return humanoid.MaxHealth or 0
end

-- ====================== MOB CACHE SYSTEM ======================
MobCacheList = {}
MobCacheDirty = true
MobCacheFolder = nil
MobCacheLastRebuild = 0
MobCacheChildAddedConnection = nil
MobCacheChildRemovedConnection = nil
MobCacheWorkspaceAddedConnection = nil
MobCacheWorkspaceRemovedConnection = nil

function InvalidateMobCache(reason)
    MobCacheDirty = true
    CombatDebug("MobCache", "Cache invalidated: " .. tostring(reason or "unknown"), 2)
end

function DisconnectMobCacheFolderHooks()
    if MobCacheChildAddedConnection then
        MobCacheChildAddedConnection:Disconnect()
        MobCacheChildAddedConnection = nil
    end
    if MobCacheChildRemovedConnection then
        MobCacheChildRemovedConnection:Disconnect()
        MobCacheChildRemovedConnection = nil
    end
end

function RestartCombatLoopsIfNeeded(reason)
    if AutoAttackEnabled and IsMiscFarmAllowed() and StartAutoAttack then
        CombatDebug("AutoAttackRestart", "Restart check: " .. tostring(reason or "unknown"), 3)
        StartAutoAttack()
    end
    if AutoSkillEnabled and IsMiscFarmAllowed() and StartAutoSkill then
        CombatDebug("AutoSkillRestart", "Restart check: " .. tostring(reason or "unknown"), 3)
        StartAutoSkill()
    end
end

function HookMobCacheFolder(folder)
    if MobCacheFolder == folder and MobCacheChildAddedConnection and MobCacheChildRemovedConnection then return end

    DisconnectMobCacheFolderHooks()
    MobCacheFolder = folder
    MobCacheList = {}
    MobCacheDirty = true

    if not folder then
        CombatDebug("MobCache", "Living folder not found yet.", 5)
        return
    end

    MobCacheChildAddedConnection = folder.ChildAdded:Connect(function(obj)
        InvalidateMobCache("mob added")
        CombatDebug("MobCacheAdded", "Mob appeared: " .. tostring(obj and obj.Name or "nil"), 2)
        task.delay(0.15, function()
            InvalidateMobCache("mob added delayed scan")
            RestartCombatLoopsIfNeeded("mob added")
        end)
        task.delay(0.75, function()
            InvalidateMobCache("mob loaded delayed scan")
            RestartCombatLoopsIfNeeded("mob loaded")
        end)
    end)

    MobCacheChildRemovedConnection = folder.ChildRemoved:Connect(function(obj)
        InvalidateMobCache("mob removed")
        CombatDebug("MobCacheRemoved", "Mob removed: " .. tostring(obj and obj.Name or "nil"), 2)
        task.delay(0.05, function() RestartCombatLoopsIfNeeded("mob removed") end)
    end)

    CombatDebug("MobCache", "Living folder hooked.", 5)
end

function SetupMobCacheWorkspaceHooks()
    if MobCacheWorkspaceAddedConnection then return end

    MobCacheWorkspaceAddedConnection = workspace.ChildAdded:Connect(function(obj)
        if obj and obj.Name == "Living" then
            HookMobCacheFolder(obj)
            InvalidateMobCache("Living folder added")
            task.delay(0.25, function() RestartCombatLoopsIfNeeded("Living folder added") end)
        end
    end)

    MobCacheWorkspaceRemovedConnection = workspace.ChildRemoved:Connect(function(obj)
        if obj and obj == MobCacheFolder then
            HookMobCacheFolder(nil)
            InvalidateMobCache("Living folder removed")
        end
    end)
end

function RebuildMobCache()
    local folder = workspace:FindFirstChild("Living")
    if folder ~= MobCacheFolder then
        HookMobCacheFolder(folder)
    end

    MobCacheList = {}

    if folder then
        for _, mob in ipairs(folder:GetChildren()) do
            if IsValidMob(mob) then
                table.insert(MobCacheList, mob)
            end
        end
    end

    MobCacheDirty = false
    MobCacheLastRebuild = tick()
    CombatDebug("MobCacheRebuild", "Cached valid mobs: " .. tostring(#MobCacheList), 3)
end

function GetCachedLivingMobs(forceRefresh)
    local folder = workspace:FindFirstChild("Living")
    if folder ~= MobCacheFolder then
        HookMobCacheFolder(folder)
    end

    if forceRefresh or MobCacheDirty or tick() - MobCacheLastRebuild > 2 then
        RebuildMobCache()
    end

    local alive = {}
    for _, mob in ipairs(MobCacheList) do
        if IsValidMob(mob) then
            table.insert(alive, mob)
        else
            MobCacheDirty = true
        end
    end

    -- Fallback: if the cache is empty but Living has children, rebuild once immediately.
    if #alive == 0 and folder and #folder:GetChildren() > 0 and not forceRefresh then
        CombatDebug("MobCacheFallback", "Cache empty while Living has children, rebuilding once.", 3)
        RebuildMobCache()
        alive = {}
        for _, mob in ipairs(MobCacheList) do
            if IsValidMob(mob) then table.insert(alive, mob) end
        end
    end

    return alive
end

SetupMobCacheWorkspaceHooks()

-- ====================== MOB SELECTION ======================
function IsAstroMob(mob)
    return mob and mob.Name and mob.Name:lower():find("astro", 1, true) ~= nil
end

function IsFarmMobAllowedByMode(mob)
    if FarmTargetMode == "Astro Holdout Mode" then
        return IsAstroMob(mob)
    end
    return true
end

function GetFarmCandidateMobs(forceRefresh)
    local source = GetCachedLivingMobs(forceRefresh == true)
    local useJeffreyAvoid = IsFarmJeffreyAvoidActive and IsFarmJeffreyAvoidActive()

    if FarmTargetMode ~= "Astro Holdout Mode" and not useJeffreyAvoid then
        return source
    end

    local filtered = {}
    local range = GetFarmTargetDangerRange and GetFarmTargetDangerRange() or (GetFarmJeffreyAvoidRange and GetFarmJeffreyAvoidRange() or DarkDimensionJeffreyAvoidRange)

    for _, mob in ipairs(source) do
        if IsFarmMobAllowedByMode(mob) then
            if useJeffreyAvoid and IsMobBlockedByJeffrey(mob, range) then
                -- Skip mobs standing inside Jeffrey danger range. If every mob is unsafe, the farm loop uses an escape fallback.
            else
                table.insert(filtered, mob)
            end
        end
    end

    return filtered
end

function GetNearestMob()
    if RefreshCombatCharacter then RefreshCombatCharacter() end
    if not HumanoidRootPart then return nil end

    local nearestMob, nearestDist = nil, math.huge
    for _, mob in ipairs(GetFarmCandidateMobs(false)) do
        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
        if mobRoot then
            local d = (HumanoidRootPart.Position - mobRoot.Position).Magnitude
            if d < nearestDist then
                nearestDist = d
                nearestMob = mob
            end
        end
    end
    return nearestMob
end

function GetHighestMob()
    if RefreshCombatCharacter then RefreshCombatCharacter() end

    local highestMob, highestY = nil, -math.huge
    local myY = HumanoidRootPart and HumanoidRootPart.Position.Y or 0

    for _, mob in ipairs(GetFarmCandidateMobs(false)) do
        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
        if mobRoot then
            local mobY = mobRoot.Position.Y
            if mobY > myY and mobY > highestY then
                highestY = mobY
                highestMob = mob
            end
        end
    end

    return highestMob
end

-- ============================================================
-- ====================== PRIORITY SYSTEM =====================
-- Normal Mode: GiantST(4) → Heli(3) → HighHP(2) → Nearest(1)
-- Astro Holdout Mode: only mobs with "Astro" in the name are allowed.
-- ============================================================

function GetHelicopter()
    for _, mob in ipairs(GetFarmCandidateMobs(false)) do
        if mob.Name:lower():find("helicopter") then
            return mob
        end
    end
    return nil
end

function GetGiantSTToilet()
    if FarmTargetMode == "Astro Holdout Mode" then return nil, nil end
    for _, mob in ipairs(GetFarmCandidateMobs(false)) do
        if mob.Name == "Giant ST toilet" then
            local lever = mob:FindFirstChild("lever")
            if lever then
                local prompt = lever:FindFirstChildOfClass("ProximityPrompt")
                if prompt then return mob, prompt end
            end
        end
    end
    return nil, nil
end

function GetHighHPMob()
    local bestMob, bestHP = nil, HighHPThreshold
    for _, mob in ipairs(GetFarmCandidateMobs(false)) do
        local hp = GetMobMaxHP(mob)
        if hp > bestHP then
            bestHP = hp
            bestMob = mob
        end
    end
    return bestMob
end

function GetPriorityMob()
    if RefreshCombatCharacter then RefreshCombatCharacter() end
    if not HumanoidRootPart then return nil, nil, nil, 0 end

    local giant, prompt = nil, nil
    local heli, highMob, nearMob = nil, nil, nil
    local bestHP, nearDist = HighHPThreshold, math.huge
    local candidates = GetFarmCandidateMobs(false)

    for _, mob in ipairs(candidates) do
        if not giant and FarmTargetMode ~= "Astro Holdout Mode" and mob.Name == "Giant ST toilet" then
            local lever = mob:FindFirstChild("lever")
            if lever then
                local pr = lever:FindFirstChildOfClass("ProximityPrompt")
                if pr then giant = mob; prompt = pr end
            end
        end

        if not heli and mob.Name:lower():find("helicopter") then
            heli = mob
        end

        local hp = GetMobMaxHP(mob)
        if hp > bestHP then
            bestHP = hp
            highMob = mob
        end

        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
        if mobRoot and HumanoidRootPart then
            local d = (HumanoidRootPart.Position - mobRoot.Position).Magnitude
            if d < nearDist then
                nearDist = d
                nearMob = mob
            end
        end
    end

    if giant and prompt then return giant, "GiantST", prompt, 4 end
    if heli then return heli, "Helicopter", nil, 3 end
    if highMob then return highMob, "HighHP", nil, 2 end
    if nearMob then return nearMob, "NearestMob", nil, 1 end

    return nil, nil, nil, 0
end

function CheckInterrupt(currentPriority)
    local mob, _, _, newPriority = GetPriorityMob()
    if mob and newPriority > (currentPriority or 0) then
        return true, newPriority
    end
    return false, currentPriority
end

-- ============================================================
-- ====================== MOB VISUAL BOUNDS ===================
-- ============================================================

MobBoundsCache = {}
MobBoundsCacheAt = {}
MobBoundsCacheTTL = 0.25

function ClearMobBoundsCache(mob)
    if mob then
        MobBoundsCache[mob] = nil
        MobBoundsCacheAt[mob] = nil
    else
        MobBoundsCache = {}
        MobBoundsCacheAt = {}
    end
end

function ComputeMobVisualBounds(mob)
    local minY, maxY = math.huge, -math.huge
    local centerX, centerZ, count = 0, 0, 0

    for _, part in ipairs(mob:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.9 and part.Size.Y > 0.1 then
            local pos = part.Position
            local hy  = part.Size.Y * 0.5
            if pos.Y - hy < minY then minY = pos.Y - hy end
            if pos.Y + hy > maxY then maxY = pos.Y + hy end
            centerX = centerX + pos.X
            centerZ = centerZ + pos.Z
            count   = count + 1
        end
    end

    if count == 0 then
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hrp then
            return hrp.Position, hrp.Position.Y - 2, hrp.Position.Y + 2
        end
        return Vector3.new(0, 0, 0), 0, 4
    end

    local cx = centerX / count
    local cz = centerZ / count
    local cy = (minY + maxY) * 0.5
    return Vector3.new(cx, cy, cz), minY, maxY
end

function GetMobVisualBounds(mob)
    if not mob then return Vector3.new(0, 0, 0), 0, 4 end

    local now = tick()
    local cached = MobBoundsCache[mob]
    if cached and MobBoundsCacheAt[mob] and now - MobBoundsCacheAt[mob] <= MobBoundsCacheTTL then
        return cached[1], cached[2], cached[3]
    end

    local center, minY, maxY = ComputeMobVisualBounds(mob)
    MobBoundsCache[mob] = { center, minY, maxY }
    MobBoundsCacheAt[mob] = now
    return center, minY, maxY
end

-- ============================================================
-- ====================== MOB HEIGHT OVERRIDE =================
-- ============================================================

PADDING_REDUCE_STEP    = Config:Get("PaddingReduceStep", 2)
PADDING_SAFE_MIN       = Config:Get("PaddingSafeMin", -30)
DMG_THRESHOLD          = Config:Get("DmgThreshold", 40)
ANTI_CLIP_MARGIN       = Config:Get("AntiClipMargin", 3)
PLAYER_HALF_HEIGHT     = 3

MobHeightOverride   = {}
MobConfirmedPadding = {}
MobLastHealth       = {}
MobCheckerCancelled = {}

function GetAntiClipFloor(mob, position)
    local _, minY, maxY = GetMobVisualBounds(mob)
    local visualHeight = maxY - minY
    return -(visualHeight) + PLAYER_HALF_HEIGHT + ANTI_CLIP_MARGIN
end

function GetEffectivePadding(mob)
    if MobConfirmedPadding[mob] ~= nil then return MobConfirmedPadding[mob] end
    if MobHeightOverride[mob] ~= nil then return MobHeightOverride[mob] end
    return HeightValue
end

function ClampPaddingToAntiClip(mob, padding)
    local antiFloor = GetAntiClipFloor(mob, FarmPosition)
    local clamped = math.max(padding, antiFloor)
    clamped = math.max(clamped, PADDING_SAFE_MIN)
    return clamped
end

function StartDamageChecker(mob)
    MobCheckerCancelled[mob] = false
    task.spawn(function()
        local humanoid = mob and mob:FindFirstChild("Humanoid")
        if not humanoid then return end
        if MobConfirmedPadding[mob] ~= nil then return end

        MobLastHealth[mob]     = humanoid.Health
        MobHeightOverride[mob] = ClampPaddingToAntiClip(mob, MobHeightOverride[mob] or HeightValue)

        local lastDamageTime = tick()
        local noDamageTimer  = 0
        local hitStreak      = 0
        local lastWasHit     = false
        local reducedOnce    = false

        while mob and mob.Parent and not IsMobDead(mob) and AutoFarmEnabled do
            task.wait(0.3)
            if MobCheckerCancelled[mob] then break end  -- ★ เช็ค cancel
            if not mob or not mob.Parent or IsMobDead(mob) then break end
            humanoid = mob:FindFirstChild("Humanoid")
            if not humanoid then break end

            local currentHP = humanoid.Health
            local lastHP    = MobLastHealth[mob] or currentHP
            local dmgDealt  = lastHP - currentHP
            local gotHit    = dmgDealt > 0

            if gotHit then
                lastDamageTime = tick()
                noDamageTimer  = 0
                reducedOnce    = false
                if lastWasHit then hitStreak = hitStreak + 1 else hitStreak = 1 end
                lastWasHit = true
                local curPad = GetEffectivePadding(mob)
                if dmgDealt >= DMG_THRESHOLD and MobConfirmedPadding[mob] == nil then
                    if not MobCheckerCancelled[mob] then  -- ★ เช็คก่อน save
                        MobConfirmedPadding[mob] = curPad
                        MobHeightOverride[mob]   = curPad
                    end
                    break
                end
                if hitStreak >= 2 and MobConfirmedPadding[mob] == nil then
                    if not MobCheckerCancelled[mob] then  -- ★ เช็คก่อน save
                        MobConfirmedPadding[mob] = curPad
                        MobHeightOverride[mob]   = curPad
                    end
                    break
                end
            else
                lastWasHit    = false
                hitStreak     = 0
                noDamageTimer = tick() - lastDamageTime
            end

            if noDamageTimer >= 3 and not reducedOnce then
                reducedOnce = true
                local curPad = GetEffectivePadding(mob)
                local newPad = ClampPaddingToAntiClip(mob, curPad - PADDING_REDUCE_STEP)
                if newPad ~= curPad then MobHeightOverride[mob] = newPad end
            end

            if noDamageTimer >= 6 then
                lastDamageTime = tick()
                reducedOnce    = false
                local curPad   = GetEffectivePadding(mob)
                local newPad   = ClampPaddingToAntiClip(mob, curPad - PADDING_REDUCE_STEP)
                if newPad ~= curPad then MobHeightOverride[mob] = newPad end
            end

            MobLastHealth[mob] = currentHP
        end

        if not MobCheckerCancelled[mob] then  -- ★ เช็คก่อน clear
            MobHeightOverride[mob] = nil
            MobLastHealth[mob]     = nil
        end
    end)
end

function ResetMobOverride(mob)
    MobCheckerCancelled[mob] = true  -- บอกให้ DamageChecker หยุด
    MobHeightOverride[mob]   = nil
    MobConfirmedPadding[mob] = nil
    MobLastHealth[mob]       = nil
    task.delay(0.5, function()
        MobCheckerCancelled[mob] = nil
    end)
end

-- ============================================================
-- ====================== TARGET CFRAME =======================
-- ============================================================
function GetTargetCFrame(mob, position)
    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return nil end

    local padding = GetEffectivePadding(mob)
    local center, minY, maxY = GetMobVisualBounds(mob)

    if position == "Above" then
        -- ★ อยู่เหนือมอน + ก้มมองหัว/ตัวมอน เพื่อให้ตีโดนเหมือนระบบเดิม
        local safeTargetY = math.max(maxY + padding, maxY + 0.5)
        local targetPos   = Vector3.new(center.X, safeTargetY, center.Z)
        local lookAtPos   = Vector3.new(center.X, maxY, center.Z)
        local lookCF      = CFrame.new(targetPos, lookAtPos)
        return lookCF * CFrame.Angles(math.rad(-10), 0, 0)

    elseif position == "Under" then
        -- ★ อยู่ใต้มอน + เงยมองเท้า/ตัวมอน เพื่อให้ตีโดนเหมือนระบบเดิม
        local safeTargetY = math.min(minY - padding, minY - 0.5)
        local targetPos   = Vector3.new(center.X, safeTargetY, center.Z)
        local lookAtPos   = Vector3.new(center.X, minY, center.Z)
        local lookCF      = CFrame.new(targetPos, lookAtPos)
        return lookCF * CFrame.Angles(math.rad(10), 0, 0)
    end
end

function GetStableFarmCFrame(cf)
    -- Keep the target aim angle from GetTargetCFrame.
    -- This is required so Above looks down at the mob and Under looks up at the mob.
    return cf
end

function WaitTweenWithTimeout(tween, timeout)
    if not tween then return false end
    timeout = tonumber(timeout) or 2

    local completed = false
    local conn
    conn = tween.Completed:Connect(function()
        completed = true
    end)

    local startedAt = tick()
    while not completed and tick() - startedAt < timeout do
        if ResetWaveTeleporting then break end
        if not AutoFarmEnabled and not FarmAstroTokenEnabled and not DarkDimensionCollecting then break end
        task.wait(0.03)
    end

    if conn then pcall(function() conn:Disconnect() end) end
    if not completed then pcall(function() tween:Cancel() end) end
    return completed
end

function MoveCharacterToFarmCFrame(cf)
    if ResetWaveTeleporting then return end
    if not Character or not HumanoidRootPart or not cf then return end

    local targetCF = GetStableFarmCFrame(cf)
    pcall(function()
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Sit = false
            humanoid.AutoRotate = false
        end

        Character:PivotTo(targetCF)
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        StabilizeFarmCamera()
    end)
end

function TeleportToMob(mob)
    local cf = GetTargetCFrame(mob, FarmPosition)
    if not cf then return end

    if FarmMode == "Tween" then
        local tweenInfo = TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(HumanoidRootPart, tweenInfo, { CFrame = GetStableFarmCFrame(cf) })
        tween:Play()
        WaitTweenWithTimeout(tween, (TweenSpeed or 1) + 0.45)
        if not ResetWaveTeleporting and not FarmForceRetarget then
            MoveCharacterToFarmCFrame(cf)
        end
    else
        -- Teleport mode: instant move with stable camera-safe CFrame.
        MoveCharacterToFarmCFrame(cf)
    end
end

-- ============================================================
-- =========== DARK DIMENSION / Astro Holdout Mode MOVEMENT ===========
-- ============================================================

function MoveSpecialCharacterCFrame(cf)
    if ResetWaveTeleporting then return false end
    RefreshCombatCharacter()
    if not Character or not HumanoidRootPart or not cf then return false end

    local ok = pcall(function()
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Sit = false
            humanoid.AutoRotate = false
        end
        Character:PivotTo(cf)
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        StabilizeFarmCamera()
    end)

    return ok
end

function MoveFarmSpecialCFrame(cf, tweenTime)
    RefreshCombatCharacter()
    if not Character or not HumanoidRootPart or not cf then return false end

    if FarmMode == "Tween" then
        local ok = pcall(function()
            local tween = TweenService:Create(
                HumanoidRootPart,
                TweenInfo.new(tweenTime or TweenSpeed or 0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                { CFrame = cf }
            )
            tween:Play()
            WaitTweenWithTimeout(tween, (tweenTime or TweenSpeed or 0.35) + 0.45)
            if not ResetWaveTeleporting then
                MoveSpecialCharacterCFrame(cf)
            end
        end)
        return ok
    end

    return MoveSpecialCharacterCFrame(cf)
end

function StopFarmLockForSanityCollect(reason)
    DarkDimensionCollectToken = (DarkDimensionCollectToken or 0) + 1
    DarkDimensionCollecting = true
    FarmCollecting = true
    FarmForceRetarget = true
    LockActive = false
    _interruptSignal = true

    pcall(function()
        RefreshCombatCharacter()
        if Character then
            local humanoid = Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Sit = false
                humanoid.AutoRotate = false
            end
        end
        if HumanoidRootPart then
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    -- Give old mob-lock Heartbeat connections one tick to see LockActive/FarmCollecting and disconnect.
    pcall(function() RunService.Heartbeat:Wait() end)
    task.wait(0.03)
    return DarkDimensionCollectToken
end

function GetSanityImageLabel()
    local gui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return nil end
    local sanity = gui:FindFirstChild("SanityUI")
    if not sanity then return nil end
    return sanity:FindFirstChild("ImageLabel")
end

function GetSanityTransparency()
    local label = GetSanityImageLabel()
    if not label then return nil end
    local ok, value = pcall(function() return label.ImageTransparency end)
    if ok and type(value) == "number" then return value end
    return nil
end

function HasSanityTouchInterest(part)
    if not part or not part.Parent then return false end
    if part:FindFirstChild("TouchInterest") then return true end
    local ok, found = pcall(function() return part:FindFirstChildOfClass("TouchTransmitter") end)
    return ok and found ~= nil
end

function IsValidSanityTouchPart(part)
    return part and part:IsA("BasePart") and part.Parent and HasSanityTouchInterest(part)
end

function GetSanityTouchPart(orb)
    if not orb or not orb.Parent then return nil end
    if IsValidSanityTouchPart(orb) then return orb end

    local touch = orb:FindFirstChild("TouchInterest", true)
    if touch and touch.Parent and touch.Parent:IsA("BasePart") then
        return touch.Parent
    end

    for _, obj in ipairs(orb:GetDescendants()) do
        if IsValidSanityTouchPart(obj) then
            return obj
        end
    end

    return nil
end

function ScanSanityOrbContainer(container, bestPart, bestDist)
    if not container then return bestPart, bestDist end

    if container.Name == "OrbSanity" then
        local directPart = GetSanityTouchPart(container)
        if directPart then
            local directDist = (HumanoidRootPart.Position - directPart.Position).Magnitude
            if directDist < bestDist then
                bestPart = directPart
                bestDist = directDist
            end
        end
    end

    for _, obj in ipairs(container:GetDescendants()) do
        if obj.Name == "OrbSanity" then
            local part = GetSanityTouchPart(obj)
            if part then
                local dist = (HumanoidRootPart.Position - part.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestPart = part
                end
            end
        end
    end

    return bestPart, bestDist
end

function GetNearestSanityOrbPart()
    RefreshCombatCharacter()
    if not HumanoidRootPart then return nil end

    local bestPart, bestDist = nil, math.huge
    local living = workspace:FindFirstChild("Living")
    bestPart, bestDist = ScanSanityOrbContainer(living, bestPart, bestDist)

    -- Fallback for maps that move OrbSanity outside Living after round changes.
    if not bestPart and tick() - (DarkDimensionOrbSearchCooldown or 0) > 0.4 then
        DarkDimensionOrbSearchCooldown = tick()
        bestPart, bestDist = ScanSanityOrbContainer(workspace, bestPart, bestDist)
    end

    return bestPart
end

function TouchSanityOrb(part)
    RefreshCombatCharacter()
    if not part or not part.Parent or not HumanoidRootPart then return false end

    local touchCF = part.CFrame + Vector3.new(0, 2, 0)
    MoveSpecialCharacterCFrame(touchCF)

    local ok = pcall(function()
        if firetouchinterest and HasSanityTouchInterest(part) then
            for _ = 1, 3 do
                if not HasSanityTouchInterest(part) then break end
                firetouchinterest(HumanoidRootPart, part, 0)
                task.wait(0.08)
                firetouchinterest(HumanoidRootPart, part, 1)
                task.wait(0.08)
            end
        else
            -- Normal touch fallback: keep the character body intersecting the orb briefly.
            MoveSpecialCharacterCFrame(touchCF)
            task.wait(0.2)
        end
    end)

    return ok
end

function MoveToSanityOrb(part)
    if not part or not part.Parent then return false end
    local topCF = part.CFrame + Vector3.new(0, 2, 0)
    local ok = MoveFarmSpecialCFrame(topCF, 0.35)
    if ok then
        -- Re-apply once after the tween/teleport so old velocity or late mob-lock cannot pull us back.
        task.wait(0.05)
        MoveSpecialCharacterCFrame(topCF)
    end
    return ok
end

function WarnDarkDimensionMissingOrb()
    local now = tick()
    if now - DarkDimensionLastWarnAt < 4 then return end
    DarkDimensionLastWarnAt = now
    CombatDebug("DarkDimension", "Sanity is low but no OrbSanity with TouchInterest was found.", 4, false)
end

function IsDarkDimensionSanityLow()
    if FarmTargetMode ~= "Dark Dimension Mode" or DarkDimensionCollecting or not AutoFarmEnabled then return false end
    local sanity = GetSanityTransparency()
    return sanity ~= nil and sanity < DarkDimensionLowValue
end

function HandleDarkDimensionSanityEmergency()
    if not IsDarkDimensionSanityLow() then return false end
    FarmForceRetarget = true
    LockActive = false
    return HandleDarkDimensionSanity()
end

function HandleDarkDimensionSanity()
    if FarmTargetMode ~= "Dark Dimension Mode" or DarkDimensionCollecting or not AutoFarmEnabled then return false end

    local sanity = GetSanityTransparency()
    if not sanity or sanity >= DarkDimensionLowValue then return false end

    local collectToken = StopFarmLockForSanityCollect("low sanity")

    local didCollect = false
    pcall(function()
        while AutoFarmEnabled and FarmTargetMode == "Dark Dimension Mode" and DarkDimensionCollectToken == collectToken do
            RefreshCombatCharacter()
            if not Character or not HumanoidRootPart then break end
            LockActive = false
            FarmCollecting = true
            FarmForceRetarget = true

            sanity = GetSanityTransparency()
            if not sanity then break end
            if sanity >= DarkDimensionSafeValue then break end

            local part = GetNearestSanityOrbPart()
            if not part then
                WarnDarkDimensionMissingOrb()
                break
            end

            if MoveToSanityOrb(part) then
                task.wait(1.25)
                if DarkDimensionCollectToken ~= collectToken then break end
                MoveSpecialCharacterCFrame(part.CFrame + Vector3.new(0, 2, 0))
                TouchSanityOrb(part)
                didCollect = true
            end

            local waited = 0
            repeat
                task.wait(0.12)
                waited = waited + 0.12
                sanity = GetSanityTransparency()
            until not AutoFarmEnabled or FarmTargetMode ~= "Dark Dimension Mode" or not sanity or sanity >= DarkDimensionSafeValue or not part.Parent or not HasSanityTouchInterest(part) or waited >= 3
        end
    end)

    if DarkDimensionCollectToken == collectToken then
        DarkDimensionCollecting = false
        FarmCollecting = false
        _interruptSignal = false
        if AutoFarmEnabled then
            WaitingRespawn = false
            FarmForceRetarget = true
            if HandleFarmJeffreyEmergency then pcall(function() HandleFarmJeffreyEmergency(nil) end) end
            task.delay(JeffreySafeRetargetDelay or 0.85, function()
                if not DarkDimensionCollecting and not IsAntiJeffreyEscapePauseActive() then FarmForceRetarget = false end
            end)
        else
            FarmForceRetarget = false
        end
    end

    return didCollect
end

function DoAstroModeFinalDoor()
    if FarmTargetMode ~= "Astro Holdout Mode" or AstroModeFinalRunning then return false end

    local now = tick()
    if now - AstroModeLastFinalAt < 2 then return false end
    AstroModeLastFinalAt = now
    AstroModeFinalRunning = true

    local ok = pcall(function()
        RefreshCombatCharacter()
        if not Character or not HumanoidRootPart then return end
        LockActive = false
        WaitingRespawn = true
        FarmForceRetarget = true

        MoveCharacterToFarmCFrame(AstroModeDoorTopCF)
        task.wait(0.12)

        if FarmMode == "Tween" then
            MoveFarmSpecialCFrame(AstroModeDoorBottomCF, 0.45)
        else
            MoveCharacterToFarmCFrame(AstroModeDoorBottomCF)
        end

        task.wait(0.15)
        FarmForceRetarget = false
    end)

    AstroModeFinalRunning = false
    return ok
end

function LockToMob(mob)
    LockActive = true
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not AutoFarmEnabled or IsMobDead(mob) or not LockActive or FarmForceRetarget or (IsAntiJeffreyEscapePauseActive and IsAntiJeffreyEscapePauseActive()) then
            connection:Disconnect()
            LockActive = false
            return
        end
        if not Character or not HumanoidRootPart then return end
        local cf = GetTargetCFrame(mob, FarmPosition)
        if cf then
            MoveCharacterToFarmCFrame(cf)
        end
    end)
end

-- ====================== AUTO LOOPS ======================
function RefreshCombatCharacter()
    if not Character or not Character.Parent then
        Character = LocalPlayer.Character
    end

    if Character and (not HumanoidRootPart or HumanoidRootPart.Parent ~= Character) then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    end

    Client = LocalPlayer
    return Character, HumanoidRootPart
end

function SafeGetPriorityMob()
    RefreshCombatCharacter()
    if not Character or not HumanoidRootPart then
        CombatDebug("CombatCharacter", "Character or HumanoidRootPart is not ready.", 4)
        return nil, nil, nil, 0
    end

    local ok, mob, mobType, extraData, priority = pcall(function()
        return GetPriorityMob()
    end)

    if ok then
        if mob then
            return mob, mobType, extraData, priority
        end

        if tick() - MobCacheLastRebuild > 0.6 then
            InvalidateMobCache("priority returned nil")
            local ok2, mob2, mobType2, extraData2, priority2 = pcall(function()
                RebuildMobCache()
                return GetPriorityMob()
            end)

            if ok2 and mob2 then
                CombatDebug("PriorityRecovered", "Priority mob recovered after cache rebuild: " .. tostring(mob2.Name), 3)
                return mob2, mobType2, extraData2, priority2
            end
        end

        CombatDebug("PriorityNoMob", "No valid mob found yet.", 4)
        return nil, nil, nil, 0
    end

    CombatDebug("PriorityError", "GetPriorityMob failed: " .. tostring(mob), 3, true)
    warn("[DYHUB] GetPriorityMob failed:", tostring(mob))
    InvalidateMobCache("priority error")
    return nil, nil, nil, 0
end

function StartAutoAttack()
    if AutoAttackLoopRunning then return end
    AutoAttackLoopRunning = true

    task.spawn(function()
        while AutoAttackEnabled do
            if FarmCollecting then
                task.wait(0.2)
            elseif IsAntiJeffreyEscapePauseActive and IsAntiJeffreyEscapePauseActive() then
                task.wait(0.08)
            elseif IsDarkDimensionSanityLow and IsDarkDimensionSanityLow() then
                task.wait(0.1)
            elseif IsMiscFarmAllowed() then
                local mob = SafeGetPriorityMob()
                if mob then
                    WaitingRespawn = false
                    local remote = GetRemote("LMB")
                    if remote then
                        pcall(function() remote:FireServer() end)
                    else
                        CombatDebug("AutoAttackRemote", "LMB remote is missing.", 5, true)
                    end
                else
                    CombatDebug("AutoAttackNoMob", "Auto Attack is waiting for a valid mob.", 5)
                end
                task.wait(0.12)
            else
                CombatDebug("AutoAttackPaused", "Auto Attack paused by Sync Farm Only / Farm Astro Token.", 5)
                task.wait(0.25)
            end
        end

        AutoAttackLoopRunning = false
    end)
end

function StartAutoSkill()
    if AutoSkillLoopRunning then return end
    AutoSkillLoopRunning = true

    task.spawn(function()
        while AutoSkillEnabled do
            if FarmCollecting then
                task.wait(0.2)
            elseif IsAntiJeffreyEscapePauseActive and IsAntiJeffreyEscapePauseActive() then
                task.wait(0.08)
            elseif IsDarkDimensionSanityLow and IsDarkDimensionSanityLow() then
                task.wait(0.1)
            elseif IsMiscFarmAllowed() then
                local mob = SafeGetPriorityMob()
                if mob then
                    WaitingRespawn = false

                    local keysToPress = {}
                    if table.find(SelectedSkills, "All") then
                        keysToPress = skillList
                    else
                        keysToPress = SelectedSkills
                    end

                    for _, key in ipairs(keysToPress) do
                        if not AutoSkillEnabled or not IsMiscFarmAllowed() or FarmCollecting or (IsAntiJeffreyEscapePauseActive and IsAntiJeffreyEscapePauseActive()) or (IsDarkDimensionSanityLow and IsDarkDimensionSanityLow()) then break end

                        local keyCode = Enum.KeyCode[key]
                        if keyCode then
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                                task.wait(0.05)
                                VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                            end)
                            task.wait(SkillDelay)
                        else
                            CombatDebug("AutoSkillKey", "Invalid skill key: " .. tostring(key), 5)
                        end
                    end
                else
                    CombatDebug("AutoSkillNoMob", "Auto Skill is waiting for a valid mob.", 5)
                    task.wait(0.25)
                end
            else
                CombatDebug("AutoSkillPaused", "Auto Skill paused by Sync Farm Only / Farm Astro Token.", 5)
                task.wait(0.25)
            end
            task.wait(0.05)
        end

        AutoSkillLoopRunning = false
    end)
end

function TriggerAutoSkipHeli(state)
    local remote = GetRemote("SetSettingAutoSkipWave")
    if remote then pcall(function() remote:FireServer(state) end) end
end

function HasHumanoid(obj)
    if obj:IsA("Model") then
        return obj:FindFirstChildOfClass("Humanoid") ~= nil
    end
    return false
end

function IsLivingDescendant(obj)
    local current = obj
    while current and current ~= workspace do
        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
            return true
        end
        current = current.Parent
    end
    return false
end

-- ====================== Delete Map (Delete Map) SYSTEM ======================
BoostFPS_OriginalData = {}
BoostFPS_Active = false
BoostFPS_RestoreConnection = nil
BoostFPS_LightingData = {}

function SaveAndBoostFPS()
    if BoostFPS_Active then return end
    BoostFPS_Active = true
    BoostFPS_OriginalData = {}
    BoostFPS_LightingData = {}

    -- บันทึกและปิด Lighting effects
    local Lighting = game:GetService("Lighting")
    BoostFPS_LightingData = {
        Brightness        = Lighting.Brightness,
        GlobalShadows     = Lighting.GlobalShadows,
        FogEnd            = Lighting.FogEnd,
        FogStart          = Lighting.FogStart,
    }
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness    = 1
        Lighting.FogEnd        = 100000
        Lighting.FogStart      = 100000
    end)
    -- ลบ Atmosphere, Bloom, ColorCorrection, DepthOfField, SunRays, Sky
    for _, effect in ipairs(Lighting:GetChildren()) do
        pcall(function()
            if effect:IsA("Atmosphere") or effect:IsA("BloomEffect") or
               effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") or
               effect:IsA("SunRaysEffect") or effect:IsA("Sky") then
                BoostFPS_LightingData["effect_" .. effect.Name] = { class = effect.ClassName, inst = effect }
                effect.Parent = nil
            end
        end)
    end

    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            -- ข้ามสิ่งมีชีวิต (มี Humanoid)
            if IsLivingDescendant(obj) then continue end

            if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") or obj:IsA("SpecialMesh") then
                if not IsLivingDescendant(obj) then
                    if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                        BoostFPS_OriginalData[obj] = {
                            Transparency = obj.Transparency,
                            CastShadow   = obj.CastShadow,
                            Material     = obj.Material,
                        }
                        obj.Transparency = 1
                        obj.CastShadow   = false
                        pcall(function() obj.Material = Enum.Material.SmoothPlastic end)
                    end
                end
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                BoostFPS_OriginalData[obj] = { Transparency = obj.Transparency }
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
                   obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("SelectionBox") then
                BoostFPS_OriginalData[obj] = { Enabled = obj.Enabled }
                pcall(function() obj.Enabled = false end)
            elseif obj:IsA("SpecialMesh") then
                BoostFPS_OriginalData[obj] = { TextureId = obj.TextureId }
                obj.TextureId = ""
            end
        end
    end)

    -- เฝ้าดูถ้าแมพ respawn (DescendantAdded) แล้วทำ transparency ทันที
    BoostFPS_RestoreConnection = workspace.DescendantAdded:Connect(function(obj)
        if not BoostFPS_Active then return end
        if IsLivingDescendant(obj) then return end
        task.wait(0.05)
        pcall(function()
            if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                if not IsLivingDescendant(obj) then
                    obj.Transparency = 1
                    obj.CastShadow   = false
                end
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
                   obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                pcall(function() obj.Enabled = false end)
            end
        end)
    end)

    print("[DYHUB] Delete Map: ON")
end

function RestoreBoostFPS()
    if not BoostFPS_Active then return end
    BoostFPS_Active = false

    if BoostFPS_RestoreConnection then
        BoostFPS_RestoreConnection:Disconnect()
        BoostFPS_RestoreConnection = nil
    end

    -- คืน Lighting
    local Lighting = game:GetService("Lighting")
    pcall(function()
        if BoostFPS_LightingData.Brightness        ~= nil then Lighting.Brightness        = BoostFPS_LightingData.Brightness end
        if BoostFPS_LightingData.GlobalShadows     ~= nil then Lighting.GlobalShadows     = BoostFPS_LightingData.GlobalShadows end
        if BoostFPS_LightingData.FogEnd            ~= nil then Lighting.FogEnd            = BoostFPS_LightingData.FogEnd end
        if BoostFPS_LightingData.FogStart          ~= nil then Lighting.FogStart          = BoostFPS_LightingData.FogStart end
    end)
    for key, data in pairs(BoostFPS_LightingData) do
        if type(key) == "string" and key:sub(1, 7) == "effect_" then
            pcall(function()
                if data.inst then data.inst.Parent = Lighting end
            end)
        end
    end

    -- คืนค่าทุก object
    for obj, data in pairs(BoostFPS_OriginalData) do
        pcall(function()
            if not obj or not obj.Parent then return end
            if data.Transparency ~= nil and (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") or obj:IsA("Decal") or obj:IsA("Texture")) then
                obj.Transparency = data.Transparency
            end
            if data.CastShadow ~= nil then obj.CastShadow = data.CastShadow end
            if data.Material   ~= nil then pcall(function() obj.Material = data.Material end) end
            if data.Enabled    ~= nil then pcall(function() obj.Enabled  = data.Enabled  end) end
            if data.TextureId  ~= nil then obj.TextureId = data.TextureId end
        end)
    end

    BoostFPS_OriginalData = {}
    BoostFPS_LightingData = {}
    print("[DYHUB] Delete Map: OFF (restored)")
end

-- ตรวจสอบแบบ loop ว่าถ้า Delete Map เปิดอยู่แต่แมพ reset แล้ว ให้ re-apply
task.spawn(function()
    while true do
        task.wait(3)
        if BoostFPS_Active then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if IsLivingDescendant(obj) then continue end
                    if (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) then
                        if not IsLivingDescendant(obj) then
                            if obj.Transparency < 0.99 and not BoostFPS_OriginalData[obj] then
                                -- object ใหม่ที่ยังไม่ถูก process
                                obj.Transparency = 1
                                obj.CastShadow   = false
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================== PLAYER HP HELPERS ======================
function GetPlayerHPInfo()
    local humanoid = Character and Character:FindFirstChild("Humanoid")
    if not humanoid then return 100, 100 end
    return humanoid.Health, humanoid.MaxHealth
end

function IsPlayerHPFull()
    local hp, maxHp = GetPlayerHPInfo()
    if maxHp <= 0 then return true end
    return hp >= maxHp
end

function GetPlayerHealthPercent()
    local humanoid = Character and Character:FindFirstChild("Humanoid")
    if not humanoid then return 100 end
    if humanoid.MaxHealth <= 0 then return 100 end
    return (humanoid.Health / humanoid.MaxHealth) * 100
end

-- ====================== GOD MODE CORE ======================
function IsCharacterDeadForGodMode(char, humanoid)
    return not char
        or not char.Parent
        or not humanoid
        or not humanoid.Parent
        or humanoid.Health <= 0
        or humanoid:GetState() == Enum.HumanoidStateType.Dead
end

function ForceGodModeOnce(reason)
    local ok, result = pcall(function()
        local char = LocalPlayer.Character
        if not char then return false end

        local humanoid = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
        if not humanoid then return false end
        if IsCharacterDeadForGodMode(char, humanoid) then return false end

        local destroyed = false

        local head = char:FindFirstChild("Head")
        if head then
            head:Destroy()
            destroyed = true
        end

        task.wait(0.05)

        if IsCharacterDeadForGodMode(char, humanoid) then
            CombatDebug("GodMode", "Triggered once: " .. tostring(reason or "manual"), 2)
            return true
        end

        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if torso then
            torso:Destroy()
            destroyed = true
        end

        if not destroyed and not IsCharacterDeadForGodMode(char, humanoid) then
            humanoid.Health = 0
        end

        CombatDebug("GodMode", "Triggered once: " .. tostring(reason or "manual"), 2)
        return true
    end)

    return ok and result == true
end

function ShouldBlockFarmAstroGodModePercent()
    -- Farm Astro Token uses ReviveUI TIMER : 5 as the only God Mode trigger.
    -- This blocks the normal HP percent loop so it cannot fire instantly when downed at 1 HP.
    return FarmAstroTokenEnabled == true
        and SyncFarmOnly == false
        and table.find(MiscOptions or {}, "God Mode") ~= nil
end

-- ====================== GOD MODE LOOP ======================
task.spawn(function()
    while true do
        task.wait(0.1)

        if GodModeEnabled and not FarmAstroGodModePaused and IsMiscFarmAllowed() and not ShouldBlockFarmAstroGodModePercent() then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end

                local humanoid = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
                if not humanoid then return end
                if humanoid.MaxHealth <= 0 then return end

                local hpPercent = (humanoid.Health / humanoid.MaxHealth) * 100

                if hpPercent < GodModeValue then
                    ForceGodModeOnce("HP below GodModeValue")
                end
            end)
        end
    end
end)

-- ====================== AUTO FILL UP ======================
function DoFillUp()
    local remote = GetRemote("ShopSystem")
    if not remote then return end
    for i = 1, 2 do
        pcall(function() remote:FireServer("Buy", "FillHP") end)
        if i < 2 then task.wait(0.3) end
    end
end

function StartAutoFillUpLoop()
    if FillUpRunning then return end
    FillUpRunning = true
    task.spawn(function()
        while AutoFillUpEnabled and IsMiscFarmAllowed() do
            if not IsPlayerHPFull() then
                if AutoSkipHeliEnabled then TriggerAutoSkipHeli(false) end
                local waited = 0
                while not IsFillUpPartReady() and AutoFillUpEnabled do
                    waited = waited + 0.2
                    if waited >= 30 then break end
                    task.wait(0.2)
                end
                if IsFillUpPartReady() and AutoFillUpEnabled then DoFillUp(); task.wait(1) end
                if AutoSkipHeliEnabled then TriggerAutoSkipHeli(true) end
            end
            task.wait(1)
        end
        FillUpRunning = false
    end)
end

-- ====================== BARRIER BYPASS ======================
function startNoBarrier()
    if noBarrierConnection then return end
    noBarrierConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local pos = hrp.Position
            if math.abs(pos.X) > 1000 or math.abs(pos.Y) > 1000 or math.abs(pos.Z) > 1000 then
                hrp.CFrame = CFrame.new(Vector3.new(0, 50, 0))
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.Health = humanoid.MaxHealth end
            end
        end)
    end)
end

function stopNoBarrier()
    if noBarrierConnection then
        noBarrierConnection:Disconnect()
        noBarrierConnection = nil
    end
end

-- ============================================================
-- ====================== AUTO START MODE ======================
function FireGetReady(delayBefore)
    if delayBefore == nil then delayBefore = 0 end
    if delayBefore > 0 then task.wait(delayBefore) end

    local now = tick()
    if now - (AutoStartLastReadyAt or 0) < 0.85 then return false end
    AutoStartLastReadyAt = now

    if AutoVoteinGameEnabled then
        FireAutoVote(true)
        task.wait(0.2)
    end

    local remote = GetRemote("GetReadyRemote")
    if not remote then return false end

    local ok, err = pcall(function()
        remote:FireServer("1", true)
        task.wait(0.2)
        remote:FireServer("1", false)
        task.wait(0.2)
        remote:FireServer("2", false)
        task.wait(0.2)
        remote:FireServer("3", false)
        task.wait(0.2)
        remote:FireServer("1", true)
    end)

    if not ok then warn("[DYHUB] GetReadyRemote failed:", err) end
    return ok
end

function SetupAutoStartOnly(enabled)
    if AutoStartConnection then
        AutoStartConnection:Disconnect()
        AutoStartConnection = nil
    end

    if not enabled then return end

    FireGetReady(0)

    AutoStartConnection = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if AutoStartEnabled then
            task.spawn(function() FireGetReady(1) end)
        end
    end)
end

function StartAutoStart()
    AutoStartEnabled = true
    SetupAutoStartOnly(true)
end

function StopAutoStart()
    AutoStartEnabled = false
    SetupAutoStartOnly(false)
end

-- ====================== TELEPORT TO IDLE ======================
function StopIdleVelocity()
    pcall(function()
        if HumanoidRootPart then
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

function IsNearIdlePosition()
    if not HumanoidRootPart then return false end
    return (HumanoidRootPart.Position - IdlePosition.Position).Magnitude <= IdleHoldDistance
end

function TeleportToIdle(force)
    LockActive = false
    WaitingRespawn = true
    IdlePosition = GetDYHUBWaitingStandCFrame() * CFrame.Angles(math.rad(0), 0, 0)
    UpdateDYHUBWaitingPartCollision()

    if not Character or not Character.Parent or not HumanoidRootPart then return end

    local now = tick()

    -- Already at idle: do NOT PivotTo again. This fixes camera shake.
    if not force and IsNearIdlePosition() then
        IdlePositionReached = true
        StopIdleVelocity()
        return
    end

    -- Anti-spam: if the loop calls this many times, teleport only after cooldown.
    if not force and (now - LastIdleTeleportAt) < IdleTeleportCooldown then
        StopIdleVelocity()
        return
    end

    LastIdleTeleportAt = now
    IdlePositionReached = true

    pcall(function()
        Character:PivotTo(IdlePosition)
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end)
end

-- ====================== PROXIMITY PROMPT HELPERS ======================
function ActivateProximityPrompt(prompt)
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 50
        if fireproximityprompt then fireproximityprompt(prompt) end
        prompt:InputHoldBegin()
        task.wait(0.03)
        prompt:InputHoldEnd()
    end)
end

FlushPromptCache = {}
FlushPromptCacheDirty = true
FlushPromptCacheLastScan = 0
FlushPromptCacheTTL = 8

function IsFlushPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    local actionText = tostring(prompt.ActionText or ""):lower()
    local objectText = tostring(prompt.ObjectText or ""):lower()
    local combined = actionText .. " " .. objectText .. " " .. tostring(prompt.Name or ""):lower()
    return combined:find("flush", 1, true) ~= nil
        or combined:find("flash", 1, true) ~= nil
        or combined:find("dragon", 1, true) ~= nil
end

function RegisterFlushPrompt(obj)
    if obj and obj:IsA("ProximityPrompt") and IsFlushPrompt(obj) then
        FlushPromptCache[obj] = true
    end
end

function RebuildFlushPromptCache()
    FlushPromptCache = {}
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            RegisterFlushPrompt(obj)
        end
    end)
    FlushPromptCacheDirty = false
    FlushPromptCacheLastScan = tick()
end

workspace.DescendantAdded:Connect(function(obj)
    if obj and obj:IsA("ProximityPrompt") then
        task.defer(function() RegisterFlushPrompt(obj) end)
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    if obj and FlushPromptCache[obj] then
        FlushPromptCache[obj] = nil
    end
end)

LastFlushPromptActivateAllAt = 0

function ActivateAllFlushPrompts()
    local now = tick()
    if now - (LastFlushPromptActivateAllAt or 0) < 0.35 then return end
    LastFlushPromptActivateAllAt = now

    pcall(function()
        if FlushPromptCacheDirty or tick() - (FlushPromptCacheLastScan or 0) > (FlushPromptCacheTTL or 8) then
            RebuildFlushPromptCache()
        end

        for prompt in pairs(FlushPromptCache) do
            if prompt and prompt.Parent and IsFlushPrompt(prompt) then
                ActivateProximityPrompt(prompt)
            else
                FlushPromptCache[prompt] = nil
            end
        end
    end)
end

-- ============================================================
-- ====================== COLLECT SYSTEM ======================
-- ============================================================

CollectItems = {
    "Clock Spider", "X-18 Core", "Weird Transmitter",
    "Astro Samples", "Weird Prism", "Key Card", "Zombie Core",
    "Flash Drives", "Presents","Genesis Core","Green Core Energy",
}

CollectGroupMap = {
    ["Astro Samples"] = {
        "Trooper Blast","Trooper Spinner","Specialist Blaster","Specialist Spinner",
        "Specialist Sword Arm","Strider Leg","Interceptor Wing","Interceptor Goggles",
        "Interceptor Spinner","Impactor Cannon","Impactor Laser","High Impactor Cannon",
        "High Impactor Laser","Destructor Laser","Destructor Blaster","Destructor Core",
        "Obliterator Blaster","Obliterator Spinner",
    },
    ["Presents"] = {
        "Gacha Capsule",
    },
}

AutoCollectEnabled   = Config:Get("AutoCollectEnabled", false)
SelectedCollectItems = Config:Get("SelectedCollectItems", {})
CollectMode          = Config:Get("CollectMode", "Clean")
CollectMovementMode  = NormalizeCollectMovement(Config:Get("CollectMovementMode", "Tween"))

KnownCollectItems = {}
CollectRunning    = false
CollectCandidateCache = {}
CollectCacheDirty = true
CollectLastFullScan = 0

-- ============================================================
-- ====================== FARM ASTRO TOKEN ====================
-- ============================================================
FARM_ASTRO_TOKEN_IMAGE = "rbxassetid://104487529937663"
FARM_ASTRO_TOP_A       = CFrame.new(-680, 167, 505)
FARM_ASTRO_TOP_B       = CFrame.new(495, 167, 505)

FARM_ASTRO_LOW_A       = CFrame.new(-680, -15, -555)
FARM_ASTRO_LOW_B       = CFrame.new(500, -15, -555)
FARM_ASTRO_TIMER_TOP_CF = CFrame.new(-23.3435822, 67, 0.341766357)
FARM_ASTRO_TIMER_BOTTOM_CF = CFrame.new(-23.3435822, 2, 0.341766357)
FARM_ASTRO_TIMER_SAFE_CF = FARM_ASTRO_TIMER_BOTTOM_CF
FARM_ASTRO_TIMER_PART_OFFSET = CFrame.new(0, -4, 0)
FARM_ASTRO_TWEEN_TIME  = 0.3
FARM_ASTRO_TIMER_DROP_TIME = 0.35

function NotifyFarmAstroAutoFarm()
    local now = tick()
    if now - FarmAstroTokenLastAutoFarmNotify < 3 then return end
    FarmAstroTokenLastAutoFarmNotify = now
    WindUI:Notify({
        Title = "Farm Astro Token",
        Content = "Please turn off Auto Farm first before using Farm Astro Token.",
        Duration = 4,
        Icon = "triangle-alert"
    })
end

function NotifyFarmAstroCleanMode()
    local now = tick()
    if now - FarmAstroTokenLastCleanNotify < 5 then return end
    FarmAstroTokenLastCleanNotify = now
    WindUI:Notify({
        Title = "Farm Astro Token",
        Content = "Farm Astro Token will not kill mobs, so Clean mode cannot collect items. Please select IDGF mode.",
        Duration = 5,
        Icon = "triangle-alert"
    })
end

function CheckFarmAstroCollectMode()
    if FarmAstroTokenEnabled and AutoCollectEnabled and CollectMode == "Clean" then
        NotifyFarmAstroCleanMode()
        return false
    end
    return true
end

function GetFarmAstroTimerLabel()
    local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local wavesGui = playerGui:FindFirstChild("WavesGui")
    if not wavesGui then return nil end
    local frame = wavesGui:FindFirstChild("Frame")
    if not frame then return nil end
    return frame:FindFirstChild("Timer")
end

function GetFarmAstroTimerValue()
    local timerLabel = GetFarmAstroTimerLabel()
    if not timerLabel then return nil end
    local textValue = tostring(timerLabel.Text or "")
    local numberText = textValue:match("(%d+)%s*$") or textValue:match("(%d+)")
    if numberText then return tonumber(numberText) end
    return nil
end

function UpdateFarmAstroWaveTimerArmed(timerValue)
    FarmAstroLastWaveTimer = timerValue
    if timerValue ~= nil and timerValue > 10 then
        FarmAstroWaveTimerArmed = true
    end
end

function IsFarmAstroTimerEnding()
    if tick() < FarmAstroTokenTimerIgnoreUntil then return false end
    local timerValue = GetFarmAstroTimerValue()
    UpdateFarmAstroWaveTimerArmed(timerValue)
    return timerValue ~= nil and timerValue <= 10 and FarmAstroWaveTimerArmed == true
end

function IsFarmAstroTimerResetForNextWave()
    local timerValue = GetFarmAstroTimerValue()
    -- After the final bottom lock, do not resume the A/B token path until the wave timer has reset.
    return timerValue ~= nil and timerValue > 10
end

function ShouldKeepFarmAstroFinalLock()
    if not FarmAstroTokenEnabled then return false end
    if FarmAstroFinalLockActive or FarmAstroTokenTimerHold or FarmAstroTimerDropping then return true end
    local timerValue = GetFarmAstroTimerValue()
    return timerValue ~= nil and timerValue <= 3 and FarmAstroWaveTimerArmed == true
end

function HoldFarmAstroBottomLockOnce()
    pcall(function()
        local char, hrp, hum = GetFarmAstroCharacter()
        if not char or not hrp then return end
        if hum then
            hum.Sit = false
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
        char:PivotTo(FARM_ASTRO_TIMER_BOTTOM_CF)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

function IsFarmAstroGodModeSelected()
    return table.find(MiscOptions or {}, "God Mode") ~= nil
end

function PauseFarmAstroGodModeForTimer()
    if not FarmAstroTokenEnabled then return false end
    if SyncFarmOnly then return false end
    if not IsFarmAstroGodModeSelected() then return false end
    if FarmAstroGodModePaused then return true end
    if tick() < FarmAstroTokenTimerIgnoreUntil then return false end

    local timerValue = GetFarmAstroTimerValue()
    UpdateFarmAstroWaveTimerArmed(timerValue)
    if timerValue ~= nil and timerValue <= 10 and FarmAstroWaveTimerArmed == true then
        FarmAstroGodModePaused = true
        GodModeTriggered = false
        CombatDebug("FarmAstroGodSync", "God Mode percentage paused at wave timer " .. tostring(timerValue), 2, false)
        return true
    end

    return false
end

function ResumeFarmAstroGodModeAfterRespawn(reason)
    local wasPaused = FarmAstroGodModePaused
    FarmAstroGodModePaused = false
    FarmAstroReviveGodTriggered = false
    FarmAstroReviveTimerArmed = false
    FarmAstroLastReviveTimer = nil
    FarmAstroFinalLockActive = false
    FarmAstroTimerDropping = false
    FarmAstroBottomGodTriggered = false
    FarmAstroReviveTimerArmed = false
    FarmAstroLastReviveTimer = nil
    FarmAstroWaveTimerArmed = false
    FarmAstroLastWaveTimer = nil

    if wasPaused and IsFarmAstroGodModeSelected() then
        CombatDebug("FarmAstroGodSync", "God Mode resume after " .. tostring(reason or "respawn"), 2, false)
        task.defer(function()
            HandleMiscOptions(MiscOptions)
        end)
    end
end

function IsFarmAstroReviveState()
    local char, hrp, humanoid = GetFarmAstroCharacter()
    if not char or not hrp or not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    -- ReviveUI is only trusted after the player is downed at 1 HP.
    -- Do not read old/stale UI while normal God Mode percentage is blocked.
    return humanoid.Health <= 1.05
end

function GetFarmAstroReviveTimerLabel()
    if not IsFarmAstroReviveState() then return nil end
    local char, hrp = GetFarmAstroCharacter()
    if not char or not hrp then return nil end
    local reviveUI = hrp:FindFirstChild("ReviveUI")
    if not reviveUI then return nil end
    if reviveUI.Enabled == false then return nil end
    local frame = reviveUI:FindFirstChild("Frame")
    if not frame then return nil end
    if frame:IsA("GuiObject") and frame.Visible == false then return nil end
    local label = frame:FindFirstChild("TextLabel")
    if not label then return nil end
    if label:IsA("GuiObject") and label.Visible == false then return nil end
    return label
end

function GetFarmAstroReviveTimerValue()
    local label = GetFarmAstroReviveTimerLabel()
    if not label then return nil end
    local textValue = tostring(label.Text or "")
    local numberText = textValue:match("^%s*[Tt][Ii][Mm][Ee][Rr]%s*:%s*(%d+)%s*$")
    if numberText then return tonumber(numberText) end
    return nil
end

function UpdateFarmAstroReviveTimerArmed(timerValue)
    FarmAstroLastReviveTimer = timerValue
    if not IsFarmAstroReviveState() then
        FarmAstroReviveTimerArmed = false
        return
    end
    if timerValue ~= nil and timerValue > 5 then
        FarmAstroReviveTimerArmed = true
    end
end

function CheckFarmAstroReviveGodModeOnce()
    if not FarmAstroTokenEnabled or not ShouldBlockFarmAstroGodModePercent() then
        FarmAstroReviveGodTriggered = false
        FarmAstroReviveTimerArmed = false
        FarmAstroLastReviveTimer = nil
        return
    end

    local reviveTimer = GetFarmAstroReviveTimerValue()
    UpdateFarmAstroReviveTimerArmed(reviveTimer)

    -- Required flow: downed at 1 HP -> UI shows TIMER : 30 -> wait until TIMER : 5 -> God Mode one-shot.
    -- FarmAstroReviveTimerArmed becomes true only after this same ReviveUI was seen above 5.
    if reviveTimer == 5 and FarmAstroReviveTimerArmed == true then
        if not FarmAstroReviveGodTriggered then
            if ForceGodModeOnce("Farm Astro Revive Timer") then
                FarmAstroReviveGodTriggered = true
                FarmAstroReviveTimerArmed = false
            end
        end
    elseif reviveTimer == nil then
        FarmAstroReviveGodTriggered = false
        FarmAstroReviveTimerArmed = false
        FarmAstroLastReviveTimer = nil
    elseif reviveTimer > 5 then
        FarmAstroReviveGodTriggered = false
    end
end

function CheckFarmAstroBottomGodMode()
    if not FarmAstroTokenEnabled or not ShouldBlockFarmAstroGodModePercent() then return end
    if not FarmAstroFinalLockActive then return end
    if FarmAstroBottomGodTriggered then return end

    local reviveTimer = GetFarmAstroReviveTimerValue()
    UpdateFarmAstroReviveTimerArmed(reviveTimer)

    -- ต้องเลือดเหลือ 1 ก่อน และต้องเห็น TIMER มากกว่า 5 ใน ReviveUI รอบนี้ก่อน
    -- จากนั้นรอให้ TIMER ลงมาถึง 5 จริง ๆ เท่านั้น
    if reviveTimer == 5 and FarmAstroReviveTimerArmed == true then
        if ForceGodModeOnce("Farm Astro bottom lock Revive Timer") then
            FarmAstroBottomGodTriggered = true
            FarmAstroReviveGodTriggered = true
            FarmAstroReviveTimerArmed = false
        end
    elseif reviveTimer == nil then
        FarmAstroBottomGodTriggered = false
        FarmAstroReviveTimerArmed = false
        FarmAstroLastReviveTimer = nil
    elseif reviveTimer > 5 then
        FarmAstroBottomGodTriggered = false
    end
end

function FarmAstroRuntimeChecks()
    if not FarmAstroTokenEnabled then return end
    PauseFarmAstroGodModeForTimer()
    CheckFarmAstroReviveGodModeOnce()
    CheckFarmAstroBottomGodMode()
end


function GetFarmAstroCharacter()
    local char = LocalPlayer.Character or Character
    if (not char or not char.Parent) and workspace:FindFirstChild("Living") then
        char = workspace.Living:FindFirstChild(LocalPlayer.Name) or workspace.Living:FindFirstChild(LocalPlayer.DisplayName)
    end
    if char and char ~= Character then Character = char end
    if char and (not HumanoidRootPart or HumanoidRootPart.Parent ~= char) then
        HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    end
    return char, HumanoidRootPart, char and (char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid"))
end

function CreateFarmAstroTokenPart()
    if FarmAstroTokenPart and FarmAstroTokenPart.Parent then return FarmAstroTokenPart end

    local part = Instance.new("Part")
    part.Name = "farm_astro_token"
    part.Size = Vector3.new(10, 1, 10)
    part.Anchored = true
    part.CanCollide = true
    part.CanTouch = false
    part.CanQuery = false
    part.Material = Enum.Material.Neon
    part.Transparency = 1
    part.CFrame = FARM_ASTRO_TOP_A
    part.Parent = workspace

    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
        local decal = Instance.new("Decal")
        decal.Name = "farm_astro_token_image"
        decal.Texture = FARM_ASTRO_TOKEN_IMAGE
        decal.Face = face
        decal.Transparency = 0
        decal.Parent = part
    end

    FarmAstroTokenPart = part
    return part
end

function FarmAstroSnapCharacterToPart()
    if not FarmAstroTokenPart or FarmAstroTokenPauseCollect then return end
    pcall(function()
        local char, hrp, hum = GetFarmAstroCharacter()
        if not char or not hrp then return end
        if hum then
            hum.Sit = false
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
        char:PivotTo(FarmAstroTokenPart.CFrame * CFrame.new(0, 4, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

function CancelFarmAstroTween()
    if FarmAstroTokenTween then
        pcall(function() FarmAstroTokenTween:Cancel() end)
        FarmAstroTokenTween = nil
    end
end

function MoveFarmAstroToTimerSafe()
    if FarmAstroFinalLockActive then return end

    CancelFarmAstroTween()
    CreateFarmAstroTokenPart()

    FarmAstroTokenTimerHold = false
    FarmAstroTimerDropping = true
    FarmAstroFinalLockActive = false
    FarmAstroBottomGodTriggered = false
    FarmAstroReviveTimerArmed = false
    FarmAstroLastReviveTimer = nil
    FarmAstroWaveTimerArmed = false
    FarmAstroLastWaveTimer = nil

    pcall(function()
        if FarmAstroTokenPart and FarmAstroTokenPart.Parent then
            FarmAstroTokenPart.CFrame = FARM_ASTRO_TIMER_BOTTOM_CF * FARM_ASTRO_TIMER_PART_OFFSET
        end
    end)

    pcall(function()
        local char, hrp, hum = GetFarmAstroCharacter()
        if not char or not hrp then return end
        if hum then
            hum.Sit = false
            hum.PlatformStand = false
            hum.AutoRotate = true
        end

        char:PivotTo(FARM_ASTRO_TIMER_TOP_CF)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)

    pcall(function()
        local char, hrp, hum = GetFarmAstroCharacter()
        if not char or not hrp then return end
        local tween = TweenService:Create(
            hrp,
            TweenInfo.new(FARM_ASTRO_TIMER_DROP_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { CFrame = FARM_ASTRO_TIMER_BOTTOM_CF }
        )
        tween:Play()
        WaitTweenWithTimeout(tween, (FARM_ASTRO_TIMER_DROP_TIME or 0.35) + 0.45)
        if hum then
            hum.Sit = false
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
        char:PivotTo(FARM_ASTRO_TIMER_BOTTOM_CF)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)

    FarmAstroTimerDropping = false
    FarmAstroTokenTimerHold = true
    FarmAstroFinalLockActive = true
    CheckFarmAstroBottomGodMode()
end

function WaitFarmAstroRespawnAfterTimer()
    MoveFarmAstroToTimerSafe()
    local lockStartedAt = tick()

    -- Keep the player locked at the final bottom point even if God Mode causes CharacterAdded/respawn.
    -- The farm route may resume only after the wave timer comes back above 1 for the next wave.
    while FarmAstroTokenEnabled do
        FarmAstroRuntimeChecks()
        if FarmAstroFinalLockActive or FarmAstroTokenTimerHold then
            HoldFarmAstroBottomLockOnce()
        end

        if tick() - lockStartedAt >= 0.25 and IsFarmAstroTimerResetForNextWave() then
            break
        end

        task.wait(0.1)
    end

    FarmAstroTokenTimerHold = false
    FarmAstroFinalLockActive = false
    FarmAstroTimerDropping = false
    FarmAstroBottomGodTriggered = false
    FarmAstroReviveGodTriggered = false
    FarmAstroReviveTimerArmed = false
    FarmAstroLastReviveTimer = nil
    FarmAstroWaveTimerArmed = false
    FarmAstroLastWaveTimer = nil
    FarmAstroTokenTimerIgnoreUntil = tick() + 2
    ResumeFarmAstroGodModeAfterRespawn("Farm Astro timer reset")
end

FarmAstroNoClipParts = FarmAstroNoClipParts or {}
FarmAstroNoClipChar = nil
FarmAstroNoClipPartsAt = 0

function RebuildFarmAstroNoClipParts(char)
    FarmAstroNoClipParts = {}
    FarmAstroNoClipChar = char
    FarmAstroNoClipPartsAt = tick()
    if not char then return end

    pcall(function()
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                table.insert(FarmAstroNoClipParts, obj)
            end
        end
    end)
end

function ApplyFarmAstroNoClipToCharacter(char)
    if not char then return end
    if FarmAstroNoClipChar ~= char or tick() - (FarmAstroNoClipPartsAt or 0) > 1.25 then
        RebuildFarmAstroNoClipParts(char)
    end

    for i = #FarmAstroNoClipParts, 1, -1 do
        local obj = FarmAstroNoClipParts[i]
        if obj and obj.Parent then
            obj.CanCollide = false
        else
            table.remove(FarmAstroNoClipParts, i)
        end
    end
end

function StartFarmAstroNoClip()
    if FarmAstroTokenNoClipConnection then return end
    FarmAstroTokenNoClipConnection = RunService.Heartbeat:Connect(function()
        if not FarmAstroTokenEnabled then return end
        pcall(function()
            local char, hrp, hum = GetFarmAstroCharacter()
            if not char then return end
            ApplyFarmAstroNoClipToCharacter(char)
            if hum then hum.Sit = false; hum.PlatformStand = false end
            if not FarmAstroTokenPauseCollect and hrp then
                if FarmAstroTimerDropping then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                elseif FarmAstroFinalLockActive or FarmAstroTokenTimerHold then
                    char:PivotTo(FARM_ASTRO_TIMER_BOTTOM_CF)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                elseif FarmAstroTokenPart and FarmAstroTokenPart.Parent then
                    char:PivotTo(FarmAstroTokenPart.CFrame * CFrame.new(0, 4, 0))
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end)
    end)
end

function StopFarmAstroNoClip()
    if FarmAstroTokenNoClipConnection then
        FarmAstroTokenNoClipConnection:Disconnect()
        FarmAstroTokenNoClipConnection = nil
    end
end

function SetFarmAstroCollectPause(state)
    FarmAstroTokenPauseCollect = state == true
    CancelFarmAstroTween()
end

function TweenFarmAstroTokenTo(cf, duration)
    if not FarmAstroTokenPart or not FarmAstroTokenPart.Parent then return false end
    FarmAstroRuntimeChecks()
    if IsFarmAstroTimerEnding() then
        MoveFarmAstroToTimerSafe()
        return "timer_end"
    end
    CancelFarmAstroTween()

    FarmAstroTokenTween = TweenService:Create(
        FarmAstroTokenPart,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        { CFrame = cf }
    )
    FarmAstroTokenTween:Play()

    while FarmAstroTokenEnabled do
        FarmAstroRuntimeChecks()
        if IsFarmAstroTimerEnding() then
            MoveFarmAstroToTimerSafe()
            return "timer_end"
        end
        if FarmAstroTokenPauseCollect then
            CancelFarmAstroTween()
            return true
        end
        if not FarmAstroTokenTween or FarmAstroTokenTween.PlaybackState ~= Enum.PlaybackState.Playing then break end
        task.wait(0.05)
    end

    if not FarmAstroTokenEnabled then
        CancelFarmAstroTween()
        return false
    end

    FarmAstroTokenTween = nil
    pcall(function() FarmAstroTokenPart.CFrame = cf end)
    return true
end

function StartFarmAstroToken()
    if FarmAstroTokenRunning then return end
    if AutoFarmEnabled then
        FarmAstroTokenEnabled = false
        Config:Set("FarmAstroTokenEnabled", false)
        Config:Save()
        NotifyFarmAstroAutoFarm()
        return
    end

    FarmAstroTokenRunning = true
    NeedNoClip = true
    LockActive = false
    AutoAttackEnabled = false
    AutoSkillEnabled = false
    FarmAstroTokenTimerHold = false
    FarmAstroWaveTimerArmed = false
    FarmAstroLastWaveTimer = nil
    CreateFarmAstroTokenPart()
    StartFarmAstroNoClip()
    CheckFarmAstroCollectMode()
    HandleMiscOptions(MiscOptions)

    task.spawn(function()
        while FarmAstroTokenEnabled do
            if FarmAstroTokenPauseCollect then
                repeat task.wait(0.2) until not FarmAstroTokenPauseCollect or not FarmAstroTokenEnabled
            end
            if not FarmAstroTokenEnabled then break end

            FarmAstroRuntimeChecks()

            if FarmAstroFinalLockActive or FarmAstroTokenTimerHold then
                WaitFarmAstroRespawnAfterTimer()
                continue
            end

            if IsFarmAstroTimerEnding() then
                WaitFarmAstroRespawnAfterTimer()
                continue
            end

            CreateFarmAstroTokenPart()
            FarmAstroTokenPart.CFrame = FARM_ASTRO_TOP_A
            FarmAstroSnapCharacterToPart()

            local topResult = TweenFarmAstroTokenTo(FARM_ASTRO_TOP_B, FARM_ASTRO_TWEEN_TIME)
            if topResult == "timer_end" then
                WaitFarmAstroRespawnAfterTimer()
                continue
            end
            if not topResult then break end

            if FarmAstroTokenPauseCollect then continue end
            if IsFarmAstroTimerEnding() then
                WaitFarmAstroRespawnAfterTimer()
                continue
            end

            FarmAstroTokenPart.CFrame = FARM_ASTRO_LOW_A
            FarmAstroSnapCharacterToPart()

            local lowResult = TweenFarmAstroTokenTo(FARM_ASTRO_LOW_B, FARM_ASTRO_TWEEN_TIME)
            if lowResult == "timer_end" then
                WaitFarmAstroRespawnAfterTimer()
                continue
            end
            if not lowResult then break end
        end

        CancelFarmAstroTween()
        StopFarmAstroNoClip()
        if FarmAstroTokenPart then pcall(function() FarmAstroTokenPart:Destroy() end) end
        FarmAstroTokenPart = nil
        FarmAstroTokenPauseCollect = false
        FarmAstroTokenTimerHold = false
        FarmAstroFinalLockActive = false
        FarmAstroTimerDropping = false
        FarmAstroBottomGodTriggered = false
        FarmAstroReviveGodTriggered = false
        FarmAstroWaveTimerArmed = false
        FarmAstroLastWaveTimer = nil
        FarmAstroTokenRunning = false
        RestoreFarmCameraAndMovement()
        ResumeFarmAstroGodModeAfterRespawn("Farm Astro stopped")
        HandleMiscOptions(MiscOptions)
    end)
end

function StopFarmAstroToken(saveState)
    FarmAstroTokenEnabled = false
    FarmAstroTokenTimerHold = false
    FarmAstroFinalLockActive = false
    FarmAstroTimerDropping = false
    FarmAstroBottomGodTriggered = false
    FarmAstroReviveGodTriggered = false
    FarmAstroReviveTimerArmed = false
    FarmAstroLastReviveTimer = nil
    FarmAstroWaveTimerArmed = false
    FarmAstroLastWaveTimer = nil
    ResumeFarmAstroGodModeAfterRespawn("Farm Astro disabled")
    if saveState then
        Config:Set("FarmAstroTokenEnabled", false)
        Config:Save()
    end
    CancelFarmAstroTween()
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if FarmAstroTokenEnabled then
            FarmAstroRuntimeChecks()
        else
            FarmAstroReviveGodTriggered = false
            FarmAstroBottomGodTriggered = false
            FarmAstroWaveTimerArmed = false
            FarmAstroLastWaveTimer = nil
        end
    end
end)


function MatchesPattern(objectName, pattern)
    local objL, patL = tostring(objectName or ""):lower(), tostring(pattern or ""):lower()
    if objL == patL then return true end
    if #objL > #patL and objL:sub(1, #patL) == patL then
        local nc = objL:sub(#patL + 1, #patL + 1)
        if nc == " " or nc == "#" or nc == "_" or nc == "-" then return true end
    end
    if CollectGroupMap[pattern] then
        for _, gName in ipairs(CollectGroupMap[pattern]) do
            if objL == gName:lower() then return true end
        end
    end
    return false
end

function IsCollectTarget(objectName)
    for _, pattern in ipairs(SelectedCollectItems) do
        if MatchesPattern(objectName, pattern) then return true end
    end
    return false
end

function IsCollectObject(obj)
    return obj and obj.Parent and (obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("BasePart"))
end

function AddCollectCandidate(obj)
    if IsCollectObject(obj) and IsCollectTarget(obj.Name) then
        CollectCandidateCache[obj] = true
        return true
    end
    return false
end

function RebuildCollectCache()
    CollectCandidateCache = {}
    if #SelectedCollectItems > 0 then
        for _, obj in ipairs(workspace:GetDescendants()) do
            AddCollectCandidate(obj)
        end
    end
    CollectCacheDirty = false
    CollectLastFullScan = tick()
end

function FindNewCollectItems()
    if CollectCacheDirty or tick() - CollectLastFullScan > 5 then
        RebuildCollectCache()
    end

    local found = {}
    for obj, _ in pairs(CollectCandidateCache) do
        if not obj or not obj.Parent or not IsCollectTarget(obj.Name) then
            CollectCandidateCache[obj] = nil
            KnownCollectItems[obj] = nil
        elseif not KnownCollectItems[obj] and IsCollectObject(obj) then
            table.insert(found, obj)
        end
    end
    return found
end

function GetItemRootPart(obj)
    if obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
    elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then return obj end
    return nil
end

function GetItemTargetCFrame(itemRoot)
    if not itemRoot then return nil end
    return CFrame.new(itemRoot.Position + Vector3.new(0, 3, 0), itemRoot.Position)
end

function MoveToItem(itemRoot)
    RefreshCombatCharacter()
    if not itemRoot or not Character or not HumanoidRootPart then return false end

    local targetCF = GetItemTargetCFrame(itemRoot)
    if not targetCF then return false end

    if CollectMovementMode == "Teleport" then
        pcall(function()
            Character:PivotTo(targetCF)
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end)
        return true
    end

    local ok = pcall(function()
        local tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear), { CFrame = targetCF })
        tween:Play()
        local started = tick()
        repeat
            task.wait(0.05)
            if not AutoCollectEnabled or IsItemGone(itemRoot) then
                pcall(function() tween:Cancel() end)
                break
            end
        until tween.PlaybackState ~= Enum.PlaybackState.Playing or tick() - started > math.max(TweenSpeed + 1, 3)
        pcall(function()
            Character:PivotTo(targetCF)
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end)
    end)

    return ok
end

function ActivateItemPrompts(obj)
    pcall(function()
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                child.HoldDuration = 0
                child.MaxActivationDistance = 50
                if fireproximityprompt then fireproximityprompt(child) end
                child:InputHoldBegin()
                task.wait(0.04)
                child:InputHoldEnd()
            end
        end
    end)
end

function IsItemGone(obj) return not obj or not obj.Parent end

function BeginCollectPause()
    FarmCollecting = true
    FarmForceRetarget = true
    LockActive = false
    if FarmAstroTokenEnabled then SetFarmAstroCollectPause(true) end
    task.wait(0.08)
end

function EndCollectPause()
    if FarmAstroTokenEnabled then SetFarmAstroCollectPause(false) end
    FarmCollecting = false
    FarmForceRetarget = true
    if AutoFarmEnabled then
        WaitingRespawn = false
        StartFarmLoop()
    end
    HandleMiscOptions(MiscOptions)
    task.delay(0.6, function()
        FarmForceRetarget = false
    end)
end

function CollectSingleItem(obj)
    if IsItemGone(obj) then return end
    local itemRoot = GetItemRootPart(obj)
    if not itemRoot then return end

    MoveToItem(itemRoot)

    local timeout = 0
    while AutoCollectEnabled and not IsItemGone(obj) and timeout < 8 do
        itemRoot = GetItemRootPart(obj)
        if not itemRoot then break end

        if timeout == 0 or timeout % 0.3 < 0.16 then
            local targetCF = GetItemTargetCFrame(itemRoot)
            pcall(function()
                if targetCF and Character and HumanoidRootPart then
                    Character:PivotTo(targetCF)
                    HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                    HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                end
            end)
        end

        ActivateItemPrompts(obj)
        task.wait(0.15)
        timeout = timeout + 0.15
    end

    KnownCollectItems[obj] = true
end

function AllMobsDead()
    return #GetFarmCandidateMobs(false) == 0
end

function StartAutoCollectLoop()
    if CollectRunning then return end
    CollectRunning = true
    task.spawn(function()
        while AutoCollectEnabled do
            if FarmAstroTokenEnabled and CollectMode == "Clean" then
                NotifyFarmAstroCleanMode()
                task.wait(1)
                continue
            end

            if #SelectedCollectItems > 0 then
                local itemsToCollect = FindNewCollectItems()
                if #itemsToCollect > 0 then
                    if CollectMode == "IDGF" then
                        BeginCollectPause()
                        for _, obj in ipairs(itemsToCollect) do
                            if not AutoCollectEnabled then break end
                            if not IsItemGone(obj) then CollectSingleItem(obj) else KnownCollectItems[obj] = true end
                        end
                        EndCollectPause()

                    elseif CollectMode == "Clean" then
                        local waitedClean = 0
                        while not AllMobsDead() and AutoCollectEnabled do
                            task.wait(0.5)
                            waitedClean = waitedClean + 0.5
                            if waitedClean >= 120 then break end
                        end
                        if not AutoCollectEnabled then break end

                        if AutoSkipHeliEnabled then TriggerAutoSkipHeli(false) end
                        BeginCollectPause()
                        for _, obj in ipairs(FindNewCollectItems()) do
                            if not AutoCollectEnabled then break end
                            if not IsItemGone(obj) then CollectSingleItem(obj) else KnownCollectItems[obj] = true end
                        end
                        EndCollectPause()
                        if AutoSkipHeliEnabled then TriggerAutoSkipHeli(true) end

                        if not IsPlayerHPFull() and AutoFillUpEnabled then
                            local fw = 0
                            while not IsPlayerHPFull() and AutoFillUpEnabled and AutoCollectEnabled do
                                task.wait(0.5)
                                fw = fw + 0.5
                                if fw >= 60 then break end
                            end
                        end
                    end
                else
                    for obj, _ in pairs(KnownCollectItems) do
                        if IsItemGone(obj) then KnownCollectItems[obj] = nil end
                    end
                end
            end
            task.wait(0.65)
        end
        FarmCollecting = false
        CollectRunning = false
    end)
end

workspace.DescendantAdded:Connect(function(obj)
    if not AutoCollectEnabled or #SelectedCollectItems == 0 then return end
    if AddCollectCandidate(obj) then
        CombatDebug("CollectItem", "New item cached: " .. tostring(obj.Name), 3)
    end
end)

-- ============================================================
-- ====================== MAIN FARM LOOP (NEW SYSTEM) =========
-- Priority: GiantST(4) → Heli(3) → HighHP>threshold(2) → Nearest(1)
-- Interrupt: ถ้ากำลังตีมอนระดับต่ำ และมอบระดับสูงกว่าปรากฏ → หยุดทันที
-- ============================================================
FarmLoopToken = FarmLoopToken or 0

function StartFarmLoop()
    if FarmLoopRunning then return end
    FarmLoopRunning = true
    FarmLoopToken = (FarmLoopToken or 0) + 1
    local thisFarmLoopToken = FarmLoopToken

    task.spawn(function()
        local ok, err = pcall(function()
            task.spawn(function()
                while AutoFarmEnabled and FarmLoopRunning and FarmLoopToken == thisFarmLoopToken do
                    if WaitingRespawn and not LockActive and not FarmCollecting then
                        pcall(function()
                            RefreshCombatCharacter()
                            UpdateDYHUBWaitingPartCollision()
                            if Character and HumanoidRootPart then
                                if IsNearIdlePosition() then
                                    IdlePositionReached = true
                                    HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                    HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                                else
                                    TeleportToIdle(false)
                                end
                            end
                        end)
                    else
                        IdlePositionReached = false
                    end
                    task.wait(0.35)
                end
            end)

            while AutoFarmEnabled and FarmLoopToken == thisFarmLoopToken do
                RefreshCombatCharacter()

                if ResetWaveTeleporting then
                    LockActive = false
                    FarmForceRetarget = true
                    _interruptSignal = true
                    task.wait(0.12)
                    continue
                end

                if not Character or not HumanoidRootPart then
                    task.wait(0.5)
                    continue
                end

                if FarmCollecting then
                    task.wait(0.2)
                    continue
                end

                if FarmTargetMode == "Dark Dimension Mode" and HandleDarkDimensionSanity() then
                    task.wait(0.1)
                    continue
                end

                if HandleFarmJeffreyEmergency and HandleFarmJeffreyEmergency(nil) then
                    task.wait(0.12)
                    continue
                end

                local mob, mobType, extraData, priority = SafeGetPriorityMob()

                if mob and ValidateFarmTargetBeforeMove and not ValidateFarmTargetBeforeMove(mob, "pre target gate") then
                    task.wait(0.18)
                    continue
                end

                if mob then
                    if FarmTargetMode == "Astro Holdout Mode" then AstroModeFinalRunning = false end
                    WaitingRespawn = false
                    IdlePositionReached = false
                    _currentTargetPriority = priority

                    if mobType == "GiantST" and extraData then
                        if ValidateFarmTargetBeforeMove and not ValidateFarmTargetBeforeMove(mob, "giant target gate") then
                            task.wait(0.18)
                            continue
                        end
                        TeleportToMob(mob)
                        if ValidateFarmTargetBeforeMove and not ValidateFarmTargetBeforeMove(mob, "giant post move gate") then
                            task.wait(0.18)
                            continue
                        end
                        if HandleFarmJeffreyEmergency and HandleFarmJeffreyEmergency(mob) then
                            task.wait(0.12)
                            continue
                        end

                        local giantLockConn
                        giantLockConn = RunService.Heartbeat:Connect(function()
                            if IsMobDead(mob) or not mob.Parent or not AutoFarmEnabled or FarmCollecting or FarmForceRetarget or (IsAntiJeffreyEscapePauseActive and IsAntiJeffreyEscapePauseActive()) or IsDarkDimensionSanityLow() or (IsFarmJeffreyAvoidActive and IsFarmJeffreyAvoidActive() and IsMobBlockedByJeffrey(mob, GetFarmTargetDangerRange and GetFarmTargetDangerRange() or 70)) then
                                if giantLockConn then giantLockConn:Disconnect() end
                                return
                            end
                            local lockCF = GetTargetCFrame(mob, FarmPosition)
                            if lockCF and Character and HumanoidRootPart then
                                MoveCharacterToFarmCFrame(lockCF)
                            end
                        end)

                        repeat
                            task.wait(0.2)
                            if HandleDarkDimensionSanityEmergency and HandleDarkDimensionSanityEmergency() then break end
                            if FarmCollecting or FarmForceRetarget then break end
                            if HandleFarmJeffreyEmergency and HandleFarmJeffreyEmergency(mob) then
                                break
                            end
                            ActivateProximityPrompt(extraData)
                            ActivateAllFlushPrompts()
                        until IsMobDead(mob) or not mob.Parent or not AutoFarmEnabled

                        if giantLockConn then pcall(function() giantLockConn:Disconnect() end) end

                    else
                        if SafeModeEnabled and GetPlayerHealthPercent() < SafeValue then
                            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                            if mobRoot then
                                local safePos = mobRoot.Position + Vector3.new(0, 111, 0)
                                pcall(function()
                                    Character:PivotTo(CFrame.new(safePos))
                                    HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                    HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                                end)
                            end
                            task.wait(0.5)
                        else
                            if ValidateFarmTargetBeforeMove and not ValidateFarmTargetBeforeMove(mob, "normal target gate") then
                                task.wait(0.18)
                                ResetMobOverride(mob)
                                ClearMobBoundsCache(mob)
                                continue
                            end
                            StartDamageChecker(mob)
                            TeleportToMob(mob)
                            if ValidateFarmTargetBeforeMove and not ValidateFarmTargetBeforeMove(mob, "normal post move gate") then
                                task.wait(0.18)
                                ResetMobOverride(mob)
                                ClearMobBoundsCache(mob)
                                continue
                            end
                            if HandleFarmJeffreyEmergency and HandleFarmJeffreyEmergency(mob) then
                                task.wait(0.12)
                                ResetMobOverride(mob)
                                ClearMobBoundsCache(mob)
                                continue
                            end

                            LockActive = true
                            local lockConn
                            lockConn = RunService.Heartbeat:Connect(function()
                                if not AutoFarmEnabled or IsMobDead(mob) or not LockActive or FarmCollecting or FarmForceRetarget or (IsAntiJeffreyEscapePauseActive and IsAntiJeffreyEscapePauseActive()) or IsDarkDimensionSanityLow() or (IsFarmJeffreyAvoidActive and IsFarmJeffreyAvoidActive() and IsMobBlockedByJeffrey(mob, GetFarmTargetDangerRange and GetFarmTargetDangerRange() or 70)) then
                                    if lockConn then lockConn:Disconnect() end
                                    LockActive = false
                                    return
                                end
                                if not Character or not HumanoidRootPart then return end
                                local cf = GetTargetCFrame(mob, FarmPosition)
                                if cf then
                                    MoveCharacterToFarmCFrame(cf)
                                end
                            end)

                            repeat
                                task.wait(0.15)
                                if HandleDarkDimensionSanityEmergency and HandleDarkDimensionSanityEmergency() then break end
                                if FarmCollecting or FarmForceRetarget then break end
                                if HandleFarmJeffreyEmergency and HandleFarmJeffreyEmergency(mob) then
                                    break
                                end

                                local shouldInterrupt, newPriority = CheckInterrupt(priority)
                                if shouldInterrupt then
                                    _interruptSignal = true
                                    break
                                end
                            until IsMobDead(mob) or not AutoFarmEnabled

                            if lockConn then pcall(function() lockConn:Disconnect() end) end
                            LockActive = false
                            if ResetWaveTeleporting then
                                FarmForceRetarget = true
                                _interruptSignal = true
                            else
                                _interruptSignal = false
                                FarmForceRetarget = false
                            end
                            ResetMobOverride(mob)
                            ClearMobBoundsCache(mob)
                        end
                    end

                else
                    _currentTargetPriority = 0
                    if HandleFarmJeffreyEmergency and HandleFarmJeffreyEmergency(nil) then
                        task.wait(0.25)
                    elseif IsFarmJeffreyAvoidActive and IsFarmJeffreyAvoidActive() and HasAnyJeffreyRoot and HasAnyJeffreyRoot() and tick() - (JeffreyLastUnsafeTargetAt or 0) <= 2.5 then
                        MoveToJeffreySafeHold("no safe farm targets")
                        task.wait(0.25)
                    elseif FarmTargetMode == "Astro Holdout Mode" then
                        CombatDebug("AstroMode", "No Astro mobs found. Entering final door.", 5)
                        DoAstroModeFinalDoor()
                    else
                        TeleportToIdle()
                    end
                    repeat
                        task.wait(0.5)
                        if HandleFarmJeffreyEmergency and HandleFarmJeffreyEmergency(nil) then break end
                    until ResetWaveTeleporting or FarmCollecting or SafeGetPriorityMob() ~= nil or not AutoFarmEnabled
                    WaitingRespawn = false
                end

                task.wait(0.12)
            end
        end)

        if not ok then
            warn("[DYHUB] Farm loop error:", tostring(err))
            CombatDebug("FarmLoopError", tostring(err), 3, true)
        end

        WaitingRespawn = false
        FarmCollecting = false
        if ResetWaveTeleporting then
            FarmForceRetarget = true
            _interruptSignal = true
        else
            FarmForceRetarget = false
            _interruptSignal = false
            RestoreFarmCameraAndMovement()
        end
        _currentTargetPriority = 0
        FarmLoopRunning = false

        if AutoFarmEnabled and not ResetWaveTeleporting then
            task.delay(0.5, function()
                if AutoFarmEnabled and not ResetWaveTeleporting then StartFarmLoop() end
            end)
        end
    end)
end


-- ====================== RESET WAVE SYSTEM ======================
function GetResetWaveLabel()
    local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    local wavesGui = playerGui:FindFirstChild("WavesGui")
    if not wavesGui then return nil end

    local frame = wavesGui:FindFirstChild("Frame")
    if not frame then return nil end

    return frame:FindFirstChild("TextLabel")
end

function GetCurrentResetWave()
    local label = GetResetWaveLabel()
    if not label then return nil end

    local ok, textValue = pcall(function()
        return tostring(label.Text or "")
    end)
    if not ok then return nil end

    local waveText = textValue:match("[Ww]ave%s*=?%s*(%d+)")
    if not waveText then
        waveText = textValue:match("(%d+)")
    end

    return tonumber(waveText)
end

function GetResetWaveTargetValue()
    local value = tonumber(ResetWaveValue) or 10
    value = math.floor(value)
    if value < 1 then value = 1 end
    return value
end

function GetResetWaveTriggerKey(currentWave, targetWave)
    return tostring(tonumber(currentWave) or "nil") .. ":" .. tostring(tonumber(targetWave) or "nil")
end

function ClearResetWaveTrigger(reason)
    ResetWaveLastTriggeredWave = nil
    ResetWaveLastTriggeredKey = nil
    CombatDebug("ResetWave", "Trigger cleared: " .. tostring(reason or "reset"), 3, false)
end

function IsResetWaveCharacterReady()
    RefreshCombatCharacter()
    if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
        return false
    end

    local humanoid = Character:FindFirstChildOfClass("Humanoid") or Character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health <= 0 then
        return false
    end

    return true
end

function BreakFarmLockForResetWave()
    ResetWaveTeleporting = true
    FarmForceRetarget = true
    FarmCollecting = false
    LockActive = false
    _interruptSignal = true
    WaitingRespawn = false
    _currentTargetPriority = 0

    pcall(function()
        RefreshCombatCharacter()
        if Character then
            local humanoid = Character:FindFirstChildOfClass("Humanoid") or Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Sit = false
                humanoid.PlatformStand = false
                humanoid.AutoRotate = true
            end
        end
        if HumanoidRootPart then
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    -- Give active mob-lock / tween heartbeat connections one tick to see FarmForceRetarget and stop.
    pcall(function() RunService.Heartbeat:Wait() end)
end

function HoldResetWavePosition(token)
    local holdUntil = tick() + (ResetWaveHoldTime or 2)

    while ResetWaveEnabled and ResetWaveTeleporting and token == ResetWaveToken and tick() < holdUntil do
        if not IsMiscFarmAllowed() then return false end
        if not IsResetWaveCharacterReady() then return false end

        pcall(function()
            local humanoid = Character:FindFirstChildOfClass("Humanoid") or Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Sit = false
                humanoid.PlatformStand = false
                humanoid.AutoRotate = true
            end

            NeedNoClip = true
            Character:PivotTo(ResetWaveTargetCF)
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
            StabilizeFarmCamera()
        end)

        task.wait(0.1)
    end

    return ResetWaveEnabled and token == ResetWaveToken and IsResetWaveCharacterReady()
end

function FinishResetWaveTeleport(token, completed, currentWave, targetWave)
    if token ~= ResetWaveToken then return end

    ResetWaveTeleporting = false

    if completed then
        ResetWaveLastTriggeredWave = currentWave
        ResetWaveLastTriggeredKey = GetResetWaveTriggerKey(currentWave, targetWave)
        CombatDebug("ResetWave", "Held reset point for " .. tostring(ResetWaveHoldTime or 2) .. "s at wave " .. tostring(currentWave), 2, false)
    else
        ClearResetWaveTrigger("teleport interrupted")
    end

    FarmForceRetarget = false
    _interruptSignal = false
    LockActive = false

    if completed and ResetWaveEnabled and AutoFarmEnabled and StartFarmLoop then
        task.defer(function()
            if ResetWaveEnabled and AutoFarmEnabled and not ResetWaveTeleporting then
                StartFarmLoop()
            end
        end)
    end
end

function TeleportResetWave(currentWave, targetWave, force, reason)
    if ResetWaveTeleporting then return false end

    local now = tick()
    if not force and now - (ResetWaveLastTeleportAt or 0) < 0.6 then return false end
    ResetWaveLastTeleportAt = now

    currentWave = tonumber(currentWave) or GetCurrentResetWave()
    targetWave = tonumber(targetWave) or GetResetWaveTargetValue()
    if not currentWave or currentWave < targetWave then return false end

    ResetWaveToken = (ResetWaveToken or 0) + 1
    local token = ResetWaveToken

    BreakFarmLockForResetWave()

    local ok, completed = pcall(function()
        if not IsResetWaveCharacterReady() then return false end

        pcall(function()
            NeedNoClip = true
            Character:PivotTo(ResetWaveTargetCF)
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end)

        return HoldResetWavePosition(token)
    end)

    FinishResetWaveTeleport(token, ok and completed == true, currentWave, targetWave)
    return ok and completed == true
end

function EvaluateResetWaveNow(reason, force)
    if not ResetWaveEnabled or not IsMiscFarmAllowed() or ResetWaveTeleporting then return false end

    local currentWave = GetCurrentResetWave()
    local targetWave = GetResetWaveTargetValue()

    if currentWave == nil then return false end

    if currentWave >= targetWave then
        local key = GetResetWaveTriggerKey(currentWave, targetWave)
        if force or ResetWaveLastTriggeredKey ~= key then
            return TeleportResetWave(currentWave, targetWave, force == true, reason)
        end
    else
        ClearResetWaveTrigger("wave below target")
    end

    return false
end

function StartResetWaveLoop()
    if ResetWaveLoopRunning then return end
    ResetWaveLoopRunning = true

    task.spawn(function()
        while ResetWaveEnabled do
            pcall(function()
                EvaluateResetWaveNow("loop", false)
            end)

            task.wait(ResetWaveTeleporting and 0.1 or 0.25)
        end

        ResetWaveLoopRunning = false
    end)
end


-- ====================== MISC OPTIONS HANDLER ======================
-- SyncFarmOnly is loaded near the main state variables so earlier loops can use it.

function HandleMiscOptions(selectedOptions)
    selectedOptions = selectedOptions or {}
    MiscOptions = selectedOptions

    -- ถ้า Sync Farm Only ปิด: ระบบทำงานได้แม้ AutoFarm ปิด
    -- ถ้า Sync Farm Only เปิด: ต้องเปิด AutoFarm ก่อนถึงจะทำงาน
    -- ถ้า AutoFarm ปิดและ Sync Farm Only ปิด: ระบบใน MiscFarm ยังทำงาน
    -- ถ้า AutoFarm ปิดและ Sync Farm Only เปิด: ระบบหยุดทำงาน

    local canRun = IsMiscFarmAllowed()

    local hasAutoAttack = table.find(selectedOptions, "Auto Attack") ~= nil
    if hasAutoAttack and canRun then
        -- Always call StartAutoAttack so a stopped loop can restart after Sync Farm Only changes.
        AutoAttackEnabled = true
        StartAutoAttack()
    else
        AutoAttackEnabled = false
    end

    local hasAutoSkill = table.find(selectedOptions, "Auto Skill") ~= nil
    if hasAutoSkill and canRun then
        -- Always call StartAutoSkill so a stopped loop can restart after Sync Farm Only changes.
        AutoSkillEnabled = true
        StartAutoSkill()
    else
        AutoSkillEnabled = false
    end

    local hasAutoSkipHeli = table.find(selectedOptions, "Auto Skip Helicopter")
    if hasAutoSkipHeli and canRun then
        if not AutoSkipHeliEnabled then AutoSkipHeliEnabled = true; TriggerAutoSkipHeli(true) end
    else
        if AutoSkipHeliEnabled then TriggerAutoSkipHeli(false) end
        AutoSkipHeliEnabled = false
    end

    local hasBoostFPS = table.find(selectedOptions, "Delete Map")
    if hasBoostFPS and canRun then
        if not BoostFPS_Active then SaveAndBoostFPS() end
    elseif BoostFPS_Active then
        RestoreBoostFPS()
    end

    SafeModeEnabled = table.find(selectedOptions, "Safe Mode") ~= nil and canRun
    GodModeEnabled  = table.find(selectedOptions, "God Mode") ~= nil and canRun

    local hasResetWave = table.find(selectedOptions, "Reset Wave")
    if hasResetWave and canRun then
        if not ResetWaveEnabled then
            ClearResetWaveTrigger("enabled")
        end
        ResetWaveEnabled = true
        StartResetWaveLoop()
        task.defer(function()
            EvaluateResetWaveNow("enabled", true)
        end)
    else
        ResetWaveEnabled = false
        ResetWaveTeleporting = false
        ResetWaveToken = (ResetWaveToken or 0) + 1
        ClearResetWaveTrigger("disabled")
    end

    local hasAutoStart = table.find(selectedOptions, "Auto Start")
    if hasAutoStart and canRun then
        if not AutoStartEnabled then StartAutoStart() end
    else
        if AutoStartEnabled then StopAutoStart() end
    end

    local hasAutoFillUp = table.find(selectedOptions, "Auto Fill Up")
    if hasAutoFillUp and canRun then
        if not AutoFillUpEnabled then AutoFillUpEnabled = true; StartAutoFillUpLoop() end
    else
        AutoFillUpEnabled = false
        FillUpRunning = false
    end

    Config:Set("MiscOptions", selectedOptions)
    Config:Set("AutoStartEnabled", hasAutoStart ~= nil)
    Config:Save()
end

-- ====================== CHARACTER RESPAWN HANDLER ======================
LocalPlayer.CharacterAdded:Connect(function(char)
    local keepFarmAstroBottomLock = ShouldKeepFarmAstroFinalLock and ShouldKeepFarmAstroFinalLock()

    Character        = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Client           = LocalPlayer
    FarmAstroTokenRespawnCounter = FarmAstroTokenRespawnCounter + 1

    -- Reset Wave must stop on death/respawn and be allowed to trigger again if the wave is still at/above target.
    ResetWaveToken = (ResetWaveToken or 0) + 1
    ResetWaveTeleporting = false
    ClearResetWaveTrigger("character respawn")

    if keepFarmAstroBottomLock then
        FarmAstroTokenTimerHold = true
        FarmAstroFinalLockActive = true
        FarmAstroTimerDropping = false
        FarmAstroReviveGodTriggered = false
        FarmAstroReviveTimerArmed = false
        FarmAstroLastReviveTimer = nil
        FarmAstroTokenTimerIgnoreUntil = 0
        if FarmAstroTokenEnabled then CancelFarmAstroTween() end
        task.defer(function()
            for _ = 1, 25 do
                if not FarmAstroTokenEnabled then break end
                if not (FarmAstroFinalLockActive or FarmAstroTokenTimerHold) then break end
                HoldFarmAstroBottomLockOnce()
                task.wait(0.05)
            end
        end)
    else
        FarmAstroTokenTimerHold = false
        FarmAstroFinalLockActive = false
        FarmAstroTimerDropping = false
        FarmAstroBottomGodTriggered = false
        FarmAstroReviveGodTriggered = false
        FarmAstroReviveTimerArmed = false
        FarmAstroLastReviveTimer = nil
        FarmAstroWaveTimerArmed = false
        FarmAstroLastWaveTimer = nil
        FarmAstroTokenTimerIgnoreUntil = tick() + 2
        ResumeFarmAstroGodModeAfterRespawn("character respawn")
        if FarmAstroTokenEnabled then CancelFarmAstroTween() end
    end

    JeffreyCacheAt = 0
    UpdateDYHUBWaitingPartCollision()
    MobHeightOverride   = {}
    MobConfirmedPadding = {}
    MobLastHealth       = {}
    IdlePositionReached = false
    LastIdleTeleportAt  = 0
    InvalidateMobCache("character respawn")
    ClearMobBoundsCache()
    FarmForceRetarget = true
    FarmCollecting = false
    task.delay(0.25, function()
        RestartCombatLoopsIfNeeded("character respawn")
        if AutoFarmEnabled and not ResetWaveTeleporting then StartFarmLoop(); StartJeffreyGuardLoop() end
        if ResetWaveEnabled then
            StartResetWaveLoop()
            EvaluateResetWaveNow("character respawn", true)
        end
        if BypassJeffreyEnabled then StartBypassJeffreyLoop(); ScanBypassJeffreys(true) end
    end)
    task.delay(0.8, function()
        if not ResetWaveTeleporting then
            FarmForceRetarget = false
        end
    end)
    task.wait(1)
    ApplyCameraMode(true)
end)

-- ====================== UI: MAIN ======================
Main:Section({ Title = "Auto Farm", Icon = "package" })

AutoFarmToggle = Main:Toggle({
    Title = "Auto Farm",
    Desc = "Automatically farms mobs based on priority system.",
    Value = AutoFarmEnabled,
    Callback = function(state)
        if state and FarmAstroTokenEnabled then
            AutoFarmEnabled = false
            UpdateDYHUBWaitingPartCollision()
            Config:Set("AutoFarmEnabled", false)
            Config:Save()
            NotifyFarmAstroAutoFarm()
            return
        end
        AutoFarmEnabled = state
        UpdateDYHUBWaitingPartCollision()
        if state then
            StartFarmLoop()
            StartJeffreyGuardLoop()
            HandleMiscOptions(MiscOptions)
            WindUI:Notify({ Title = "Auto Farm", Content = "Enabled, Auto Farm now!", Duration = 2, Icon = "play" })
        else
            FarmLoopToken = (FarmLoopToken or 0) + 1
            WaitingRespawn = false
            LockActive = false
            RestoreFarmCameraAndMovement()
            UpdateDYHUBWaitingPartCollision()
            if SyncFarmOnly then
                StopMiscFarmRuntime("Auto Farm turned off while Sync Farm Only is ON")
                WindUI:Notify({ Title = "Auto Farm", Content = "Turn off Auto Farm: Misc Farm system stops working (Sync Farm Only)", Duration = 3, Icon = "square" })
            else
                HandleMiscOptions(MiscOptions)
                WindUI:Notify({ Title = "Auto Farm", Content = "Auto Farm is turned off. Misc Farm keeps running because Sync Farm Only is OFF.", Duration = 3, Icon = "unlink" })
            end
        end
        Config:Set("AutoFarmEnabled", state); Config:Save()
    end
})

if IsPaidUserVersion() then
    FarmTargetModeDropdown = Main:Dropdown({
        Title = "Mode Farm",
        Desc = "Different farming modes.",
        Values = { "Normal Mode", "Astro Holdout Mode", "Dark Dimension Mode" },
        Multi = false,
        Value = FarmTargetMode,
        Callback = function(value)
            FarmTargetMode = NormalizeFarmTargetMode(value)
            Config:Set("FarmTargetMode", FarmTargetMode)
            Config:Save()
            InvalidateMobCache("farm target mode changed")
            FarmForceRetarget = true
            if AutoFarmEnabled then StartFarmLoop(); StartJeffreyGuardLoop() end
            task.delay(0.4, function() if not IsAntiJeffreyEscapePauseActive() then FarmForceRetarget = false end end)
            WindUI:Notify({ Title = "Mode Farm", Content = "Selected: " .. tostring(FarmTargetMode), Duration = 2, Icon = "target" })
        end
    })
else
    FarmTargetMode = "Normal Mode"
    Main:Paragraph({
        Title = "[ Paid Only ] Mode Farm",
        Desc  = "This feature is for Paid members only",
        Image = "rbxassetid://104487529937663", ImageSize = 30,
    })
end

Main:Section({ Title = "Farm Settings", Icon = "settings" })

PositionDropdown = Main:Dropdown({
    Title = "Position Farm",
    Desc = "Selects where your character stays around the target.",
    Values = { "Above", "Under" },
    Multi = false,
    Value = FarmPosition,
    Callback = function(value) FarmPosition = value; Config:Set("FarmPosition", value); Config:Save() end
})

ModeDropdown = Main:Dropdown({
    Title = "Movement Farm",
    Desc = "Selects how your character moves to each target.",
    Values = { "Teleport", "Tween" },
    Multi = false,
    Value = FarmMode,
    Callback = function(value)
        FarmMode = NormalizeFarmMode(value)
        Config:Set("FarmMode", FarmMode)
        Config:Save()
        WindUI:Notify({ Title = "Mode Farm", Content = "Selected: " .. tostring(FarmMode), Duration = 2, Icon = "mouse-pointer-click" })
    end
})

MiscDropdown = Main:Dropdown({
    Title = "Misc Farm",
    Desc = "Selects extra systems to run with Auto Farm.",
    Values = { "Auto Attack", "Auto Skill", "Auto Start", "Auto Skip Helicopter", "Auto Fill Up", "Safe Mode", "God Mode", "Reset Wave", "Delete Map" },
    Multi = true,
    Value = MiscOptions,
    Callback = function(values)
        MiscOptions = values
        -- ถ้า Misc Farm ไม่เปิด AutoFarm และ SyncFarmOnly เปิด → notify เตือน
        if not AutoFarmEnabled and SyncFarmOnly and #values > 0 then
            WindUI:Notify({
                Title = "Misc Farm",
                Content = "You must turn on Auto Farm first (Sync Farm Only is on)",
                Duration = 3, Icon = "triangle-alert"
            })
        end
        HandleMiscOptions(values)
    end
})

Main:Toggle({
    Title = "Sync Farm Only",
    Desc = "When enabled, all Misc Farm features require Auto Farm to be active.",
    Value = SyncFarmOnly,
    Callback = function(state)
        SyncFarmOnly = state
        Config:Set("SyncFarmOnly", state)
        Config:Save()
        if state then
            WindUI:Notify({ Title = "Sync Farm Only", Content = "ON: Misc Farm system must have Auto Farm enabled first", Duration = 3, Icon = "link" })
        else
            WindUI:Notify({ Title = "Sync Farm Only", Content = "OFF: Misc Farm system works without needing Auto Farm.", Duration = 3, Icon = "unlink" })
        end

        -- Re-apply on both ON/OFF. When ON and Auto Farm is OFF, every Misc Farm runtime is stopped.
        ApplyMiscFarmGate("Sync Farm Only changed")
    end
})


Main:Section({ Title = "Farm Astro", Icon = "flame" })

FarmAstroTokenToggle = Main:Toggle({
    Title = "Farm Astro Token (Holdout)",
    Desc = "Avoid all monsters to prevent yourself from dying, when time runs out go to the center",
    Value = FarmAstroTokenEnabled,
    Callback = function(state)
        if state and AutoFarmEnabled then
            FarmAstroTokenEnabled = false
            Config:Set("FarmAstroTokenEnabled", false)
            Config:Save()
            NotifyFarmAstroAutoFarm()
            pcall(function()
                if FarmAstroTokenToggle and FarmAstroTokenToggle.Set then
                    FarmAstroTokenToggle:Set(false)
                end
            end)
            return
        end

        FarmAstroTokenEnabled = state
        Config:Set("FarmAstroTokenEnabled", state)
        Config:Save()

        if state then
            StartFarmAstroToken()
            WindUI:Notify({
                Title = "Farm Astro Token",
                Content = "Enabled. Astro route started.",
                Duration = 3,
                Icon = "sparkles"
            })
        else
            StopFarmAstroToken(false)
            WindUI:Notify({
                Title = "Farm Astro Token",
                Content = "Disabled. Astro route stopped.",
                Duration = 3,
                Icon = "square"
            })
        end
    end
})

Main:Section({ Title = "General Settings", Icon = "zap" })

SkillDropdown = Main:Dropdown({
    Title = "Auto Skill (Keys)",
    Desc = "Selects which keyboard skill keys Auto Skill will press.",
    Values = skillDropdownValues,
    Multi = true,
    Value = SelectedSkills,
    Callback = function(values) SelectedSkills = values; Config:Set("SelectedSkills", values); Config:Save() end
})

SkillDelaySlider = Main:Slider({
    Title = "Skill Delay (Sec)",
    Desc = "Sets the delay between each Auto Skill key press in seconds.",
    Value = { Min = 1, Max = 60, Default = SkillDelay },
    Step = 1,
    Callback = function(value) SkillDelay = value; Config:Set("SkillDelay", value); Config:Save() end
})

FarmHeightSlider = Main:Slider({
    Title = "Farm Height (+/-Y)",
    Desc = "Adjusts the vertical offset used while farming above or under mobs.",
    Value = { Min = -150, Max = 150, Default = HeightValue },
    Step = 1,
    Callback = function(value)
        HeightValue = value; Config:Set("HeightValue", value); Config:Save()
        for mob, _ in pairs(MobHeightOverride) do
            if MobConfirmedPadding[mob] == nil then MobHeightOverride[mob] = nil end
        end
    end
})

Main:Slider({
    Title = "Safe Mode HP (%)",
    Desc = "Sets the HP percent that Safe Mode uses before retreating.",
    Value = { Min = 1, Max = 99, Default = SafeValue },
    Step = 1,
    Callback = function(value) SafeValue = value; Config:Set("SafeValue", value); Config:Save() end
})

Main:Slider({
    Title = "God Mode HP (%)",
    Desc = "Sets the HP percent threshold for normal God Mode. Blocked during Farm Astro Token when Sync Farm Only is OFF; Revive controls it instead.",
    Value = { Min = 1, Max = 99, Default = GodModeValue },
    Step = 1,
    Callback = function(value)
        GodModeValue = value
        Config:Set("GodModeValue", value)
        Config:Save()
    end
})

Main:Slider({
    Title = "Reset Wave (Val)",
    Desc = "If it reaches the designated wave, it will reset immediately",
    Value = { Min = 1, Max = 100, Default = ResetWaveValue },
    Step = 1,
    Callback = function(value)
        ResetWaveValue = tonumber(value) or 10
        ClearResetWaveTrigger("slider changed")
        Config:Set("ResetWaveValue", ResetWaveValue)
        Config:Save()

        if ResetWaveEnabled and IsMiscFarmAllowed() then
            StartResetWaveLoop()
            task.defer(function()
                EvaluateResetWaveNow("slider changed", true)
            end)
        end
    end
})

Main:Divider()

BypassJeffreyToggle = Main:Toggle({
    Title = "Bypass Jeffrey",
    Desc = "This feature will make Jeffrey bother you.",
    Value = BypassJeffreyEnabled,
    Callback = function(state)
        BypassJeffreyEnabled = state
        Config:Set("BypassJeffreyEnabled", state)
        Config:Save()
        if state then
            StartBypassJeffreyLoop()
            ScanBypassJeffreys(true)
        end
    end
})

AntiJeffreyToggle = Main:Toggle({
    Title = "Anti Jeffrey",
    Desc = "Free feature: creates a soft invisible barrier. If any Jeffrey is inside the range, you will be pushed away little by little.",
    Value = AntiJeffreyEnabled,
    Callback = function(state)
        AntiJeffreyEnabled = state
        Config:Set("AntiJeffreyEnabled", state)
        Config:Save()
        if state then StartAntiJeffreyLoop(); StartJeffreyGuardLoop() end
    end
})

Main:Slider({
    Title = "Anti Jeffrey Range (Stud)",
    Desc = "Sets the distance used by Anti Jeffrey. Default is 50 studs.",
    Value = { Min = 10, Max = 200, Default = AntiJeffreyRange },
    Step = 1,
    Callback = function(value)
        AntiJeffreyRange = value
        Config:Set("AntiJeffreyRange", value)
        Config:Save()
    end
})

if AntiJeffreyEnabled then StartAntiJeffreyLoop(); StartJeffreyGuardLoop() end
if BypassJeffreyEnabled then StartBypassJeffreyLoop(); ScanBypassJeffreys(true) end

-- ====================== UI: PRIORITY SETTINGS ======================
Main:Section({ Title = "Priority Settings", Icon = "list-ordered" })

Main:Paragraph({
    Title = "Priority Order",
    Desc = "Interrupt: If attacking a low-maxhp mob and a higher-maxhp mob appears to switch immediately",
    Image = "rbxassetid://104487529937663",
    ImageSize = 26,
})

Main:Slider({
    Title = "HighHP Threshold (MaxHP)",
    Desc = "Sets the MaxHP value needed for a mob to become HighHP priority.",
    Value = { Min = 1, Max = 100000, Default = HighHPThreshold },
    Step = 100,
    Callback = function(value)
        HighHPThreshold = value
        Config:Set("HighHPThreshold", value)
        Config:Save()
        print("[DYHUB] HighHP Threshold set to " .. value)
    end
})

-- ====================== UI: OVERRIDE SETTINGS ======================
Main:Section({ Title = "Override Settings", Icon = "ruler" })

PaddingReduceInput = Main:Input({
    Title = "Set Padding Reduce",
    Default = tostring(PADDING_REDUCE_STEP),
    Placeholder = "Default: 2",
    Callback = function(text)
        local num = tonumber(text)
        if num then PADDING_REDUCE_STEP = num; Config:Set("PaddingReduceStep", num); Config:Save()
        else warn("Entered an incorrect number!") end
    end
})

PaddingSafeInput = Main:Input({
    Title = "Set Padding Safe Min (Global Floor)",
    Default = tostring(PADDING_SAFE_MIN),
    Placeholder = "Default: -30",
    Callback = function(text)
        local num = tonumber(text)
        if num then PADDING_SAFE_MIN = num; Config:Set("PaddingSafeMin", num); Config:Save()
        else warn("Entered an incorrect number!") end
    end
})

Main:Slider({
    Title = "Anti-Clip Margin (studs)",
    Desc = "Adds extra spacing to reduce clipping when farming near mob bodies.",
    Value = { Min = -10, Max = 10, Default = ANTI_CLIP_MARGIN },
    Step = 1,
    Callback = function(value)
        ANTI_CLIP_MARGIN = value; Config:Set("AntiClipMargin", value); Config:Save()
    end
})

Main:Slider({
    Title = "Damage Threshold (confirm lock)",
    Desc = "Sets how much damage confirms the current farm position as valid.",
    Value = { Min = 1, Max = 500, Default = DMG_THRESHOLD },
    Step = 1,
    Callback = function(value)
        DMG_THRESHOLD = value; Config:Set("DmgThreshold", value); Config:Save()
    end
})

Main:Button({
    Title = "Reset All Confirmed Positions",
    Desc = "Clears all saved mob height positions and resets to default.",
    Callback = function()
        MobConfirmedPadding = {}
        MobHeightOverride   = {}
        WindUI:Notify({ Title = "Override Reset", Content = "All confirmed mob positions cleared.", Duration = 2, Icon = "refresh-cw" })
    end
})

Main:Section({ Title = "Flush Settings", Icon = "toilet" })

Flushaura      = Config:Get("flushaura", false)
FlushAuraValue = Config:Get("FlushAuraValue", 5)

Main:Slider({
    Title = "Flush Aura (stud)",
    Desc = "Sets the distance used by Flush Aura to activate nearby prompts.",
    Value = { Min = 1, Max = 15, Default = FlushAuraValue },
    Step = 1,
    Callback = function(value) FlushAuraValue = value; Config:Set("FlushAuraValue", value); Config:Save() end
})

Main:Toggle({
    Title = "Flush Aura",
    Desc = "Automatically flushes nearby flush prompts within the set radius.",
    Value = Flushaura,
    Callback = function(enabled)
        Flushaura = enabled; Config:Set("flushaura", enabled); Config:Save()
        if enabled then
            task.spawn(function()
                while Flushaura do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if not char then return end
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        if FlushPromptCacheDirty or tick() - (FlushPromptCacheLastScan or 0) > (FlushPromptCacheTTL or 8) then
                            RebuildFlushPromptCache()
                        end
                        for prompt in pairs(FlushPromptCache) do
                            if prompt and prompt.Parent and IsFlushPrompt(prompt) then
                                local parent = prompt.Parent
                                local part = parent:IsA("BasePart") and parent or parent:FindFirstAncestorWhichIsA("BasePart")
                                if part and (root.Position - part.Position).Magnitude <= FlushAuraValue then
                                    ActivateProximityPrompt(prompt)
                                end
                            else
                                FlushPromptCache[prompt] = nil
                            end
                        end
                    end)
                    task.wait(0.25)
                end
            end)
        end
    end
})

-- ============================================================
-- ====================== ESP SYSTEM =========================
-- ============================================================

ESP = {
    Enabled       = Config:Get("EspEnabled", false),
    MobEnabled    = Config:Get("EspMobEnabled", true),
    PlayerEnabled = Config:Get("EspPlayerEnabled", true),
    ItemEnabled   = Config:Get("EspItemEnabled", true),
    Settings      = Config:Get("EspSettings", { "Highlight", "Distance", "Health", "Name" }),
    SelectedItems = Config:Get("EspSelectedItems", {}),
    MaxDistance   = 1500,
    _mobHighlights    = {},
    _playerHighlights = {},
    _itemHighlights   = {},
    ItemList = {
        "Clock Spider","X-18 Core","Green Core Energy","Weird Transmitter",
        "Presents","Weird Prism","Key Card","Zombie Core","Flash Drives","Astro Samples","Genesis Core",
    },
}

function IsESPItemTarget(objectName, selectedList)
    for _, pattern in ipairs(selectedList) do
        if objectName:lower() == pattern:lower() then return true end
        if #objectName > #pattern then
            if objectName:lower():sub(1, #pattern) == pattern:lower() then
                local nc = objectName:lower():sub(#pattern + 1, #pattern + 1)
                if nc == " " or nc == "#" or nc == "_" or nc == "-" then return true end
            end
        end
        if CollectGroupMap[pattern] then
            for _, gName in ipairs(CollectGroupMap[pattern]) do
                if objectName:lower() == gName:lower() then return true end
            end
        end
    end
    return false
end

function CreateESPLabel(parent, labelText)
    local existing = parent:FindFirstChild("DYHUB_ESP_LABEL")
    if existing then existing:Destroy() end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DYHUB_ESP_LABEL"; billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false; billboard.Adornee = parent; billboard.Parent = parent
    local frame = Instance.new("Frame"); frame.BackgroundTransparency = 1
    frame.Size = UDim2.fromScale(1, 1); frame.Parent = billboard
    local label = Instance.new("TextLabel"); label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1); label.Font = Enum.Font.GothamBold
    label.TextSize = 11; label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.4; label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Text = labelText; label.Parent = frame
    return billboard, label
end

function CreateHighlight(model, outlineColor, fillColor, fillTransparency)
    local existing = model:FindFirstChild("DYHUB_ESP_HIGHLIGHT")
    if existing then existing:Destroy() end
    local hl = Instance.new("Highlight")
    hl.Name = "DYHUB_ESP_HIGHLIGHT"; hl.OutlineColor = outlineColor
    hl.FillColor = fillColor; hl.FillTransparency = fillTransparency or 0.9
    hl.OutlineTransparency = 0; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model; hl.Parent = model
    return hl
end

function RemoveESP(model)
    pcall(function()
        local hl = model:FindFirstChild("DYHUB_ESP_HIGHLIGHT"); if hl then hl:Destroy() end
        local hb = model:FindFirstChild("DYHUB_ESP_LABEL"); if hb then hb:Destroy() end
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp then local lb = hrp:FindFirstChild("DYHUB_ESP_LABEL"); if lb then lb:Destroy() end end
    end)
end

function IsInRange(targetPart)
    if not targetPart or not HumanoidRootPart then return false end
    return (HumanoidRootPart.Position - targetPart.Position).Magnitude <= ESP.MaxDistance
end

function BuildLabelText(model, showName, showHealth, showDistance)
    local parts = {}
    if showName then table.insert(parts, model.Name) end
    if showHealth then
        local humanoid = model:FindFirstChild("Humanoid")
        if humanoid then table.insert(parts, "❤ " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)) end
    end
    if showDistance then
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp and HumanoidRootPart then table.insert(parts, "📏 " .. math.floor((HumanoidRootPart.Position - hrp.Position).Magnitude) .. "m") end
    end
    return table.concat(parts, "\n")
end

function BuildItemLabelText(obj, showName, showDistance)
    local parts = {}
    if showName then table.insert(parts, obj.Name) end
    if showDistance then
        local root = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or (obj:IsA("BasePart") and obj or nil)
        if root and HumanoidRootPart then table.insert(parts, "📏 " .. math.floor((HumanoidRootPart.Position - root.Position).Magnitude) .. "m") end
    end
    return table.concat(parts, "\n")
end

function GetESPSettings()
    local s = ESP.Settings
    return {
        highlight = table.find(s, "Highlight") ~= nil,
        distance  = table.find(s, "Distance") ~= nil,
        health    = table.find(s, "Health") ~= nil,
        name      = table.find(s, "Name") ~= nil,
    }
end

function ApplyMobESP(mob)
    if not mob or not mob.Parent then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local settings = GetESPSettings()
    if settings.highlight then CreateHighlight(mob, Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 255, 255), 0.9) end
    if settings.name or settings.health or settings.distance then
        local _, label = CreateESPLabel(hrp, "")
        task.spawn(function()
            while mob and mob.Parent and ESP.Enabled and ESP.MobEnabled do
                local humanoid = mob:FindFirstChild("Humanoid")
                if not humanoid or humanoid.Health <= 0 then break end
                if not IsInRange(hrp) then label.Visible = false; task.wait(0.5)
                else label.Visible = true; label.Text = BuildLabelText(mob, settings.name, settings.health, settings.distance); task.wait(0.35) end
            end
            RemoveESP(mob); ESP._mobHighlights[mob] = nil
        end)
    end
    ESP._mobHighlights[mob] = true
end

function ScanMobs()
    local livingFolder = workspace:FindFirstChild("Living"); if not livingFolder then return end
    for _, mob in ipairs(livingFolder:GetChildren()) do
        if IsValidMob(mob) and not ESP._mobHighlights[mob] then
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hrp and IsInRange(hrp) then ApplyMobESP(mob) end
        end
    end
end

function ApplyPlayerESP(playerChar)
    if not playerChar or not playerChar.Parent then return end
    local hrp = playerChar:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if playerChar == LocalPlayer.Character then return end
    local settings = GetESPSettings()
    if settings.highlight then CreateHighlight(playerChar, Color3.fromRGB(50, 255, 50), Color3.fromRGB(255, 255, 255), 0.9) end
    if settings.name or settings.health or settings.distance then
        local _, label = CreateESPLabel(hrp, "")
        task.spawn(function()
            while playerChar and playerChar.Parent and ESP.Enabled and ESP.PlayerEnabled do
                local humanoid = playerChar:FindFirstChild("Humanoid")
                if not humanoid or humanoid.Health <= 0 then break end
                if not IsInRange(hrp) then label.Visible = false; task.wait(0.5)
                else label.Visible = true; label.Text = BuildLabelText(playerChar, settings.name, settings.health, settings.distance); task.wait(0.35) end
            end
            RemoveESP(playerChar); ESP._playerHighlights[playerChar] = nil
        end)
    end
    ESP._playerHighlights[playerChar] = true
end

function ScanPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            if not ESP._playerHighlights[char] then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and IsInRange(hrp) then ApplyPlayerESP(char) end
            end
        end
    end
end

function GetItemRoot(obj)
    if obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
    elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then return obj end
    return nil
end

function ApplyItemESP(obj)
    if not obj or not obj.Parent then return end
    local root = GetItemRoot(obj); if not root then return end
    local settings = GetESPSettings()
    if settings.highlight then CreateHighlight(obj, Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 255, 255), 0.9) end
    if settings.name or settings.distance then
        local _, label = CreateESPLabel(root, "")
        task.spawn(function()
            while obj and obj.Parent and ESP.Enabled and ESP.ItemEnabled do
                local currentRoot = GetItemRoot(obj); if not currentRoot then break end
                if not IsInRange(currentRoot) then label.Visible = false; task.wait(0.5)
                else label.Visible = true; label.Text = BuildItemLabelText(obj, settings.name, settings.distance); task.wait(0.5) end
            end
            RemoveESP(obj); ESP._itemHighlights[obj] = nil
        end)
    end
    ESP._itemHighlights[obj] = true
end

function ScanItems()
    if #ESP.SelectedItems == 0 then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not ESP._itemHighlights[obj] and IsESPItemTarget(obj.Name, ESP.SelectedItems) then
            local root = GetItemRoot(obj)
            if root and IsInRange(root) then ApplyItemESP(obj) end
        end
    end
end

function ClearAllESP()
    for mob, _ in pairs(ESP._mobHighlights) do RemoveESP(mob) end
    ESP._mobHighlights = {}
    for char, _ in pairs(ESP._playerHighlights) do RemoveESP(char) end
    ESP._playerHighlights = {}
    for obj, _ in pairs(ESP._itemHighlights) do RemoveESP(obj) end
    ESP._itemHighlights = {}
end

ESPConnection = nil

function StartESPLoop()
    if ESPConnection then ESPConnection:Disconnect(); ESPConnection = nil end
    local lastMobScan, lastPlayerScan, lastItemScan = 0, 0, 0
    ESPConnection = RunService.Heartbeat:Connect(function()
        if not ESP.Enabled then return end
        local now = tick()
        if ESP.MobEnabled and now - lastMobScan >= 0.8 then
            lastMobScan = now
            pcall(ScanMobs)
        end
        if ESP.PlayerEnabled and now - lastPlayerScan >= 1.0 then
            lastPlayerScan = now
            pcall(ScanPlayers)
        end
        if ESP.ItemEnabled and now - lastItemScan >= 4.0 then
            lastItemScan = now
            pcall(ScanItems)
        end
    end)
end

function StopESPLoop()
    if ESPConnection then ESPConnection:Disconnect(); ESPConnection = nil end
    ClearAllESP()
end

workspace.DescendantAdded:Connect(function(obj)
    if not ESP.Enabled or not ESP.ItemEnabled or #ESP.SelectedItems == 0 then return end
    task.wait(0.1)
    if IsESPItemTarget(obj.Name, ESP.SelectedItems) and not ESP._itemHighlights[obj] then
        local root = GetItemRoot(obj)
        if root and IsInRange(root) then ApplyItemESP(obj) end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if not ESP.Enabled or not ESP.PlayerEnabled then return end
        task.wait(1)
        if not ESP._playerHighlights[char] then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and IsInRange(hrp) then ApplyPlayerESP(char) end
        end
    end)
end)

function WatchLivingFolder()
    local living = workspace:FindFirstChild("Living")
    if living then
        living.ChildAdded:Connect(function(obj)
            if not ESP.Enabled or not ESP.MobEnabled then return end
            task.wait(0.2)
            if IsValidMob(obj) and not ESP._mobHighlights[obj] then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hrp and IsInRange(hrp) then ApplyMobESP(obj) end
            end
        end)
    end
end

task.spawn(function()
    if not workspace:FindFirstChild("Living") then
        workspace.ChildAdded:Connect(function(child)
            if child.Name == "Living" then WatchLivingFolder() end
        end)
    else
        WatchLivingFolder()
    end
end)

-- ====================== UI: ESP TAB ======================
Main4:Section({ Title = "Esp Visual", Icon = "eye" })

EspEnableToggle = Main4:Toggle({
    Title = "Enable ESP", Value = ESP.Enabled,
    Desc = "Enable ESP for all ESP visuals.",
    Callback = function(state)
        ESP.Enabled = state; Config:Set("EspEnabled", state); Config:Save()
        if state then StartESPLoop() else StopESPLoop() end
    end
})

EspMobToggle = Main4:Toggle({
    Title = "Mob ESP", Value = ESP.MobEnabled,
    Desc = "Shows highlights and info labels above enemy mobs.",
    Callback = function(state)
        ESP.MobEnabled = state; Config:Set("EspMobEnabled", state); Config:Save()
        if not state then for mob, _ in pairs(ESP._mobHighlights) do RemoveESP(mob) end; ESP._mobHighlights = {} end
    end
})

EspPlayerToggle = Main4:Toggle({
    Title = "Player ESP", Value = ESP.PlayerEnabled,
    Desc = "Shows highlights and info labels above other players.",
    Callback = function(state)
        ESP.PlayerEnabled = state; Config:Set("EspPlayerEnabled", state); Config:Save()
        if not state then for char, _ in pairs(ESP._playerHighlights) do RemoveESP(char) end; ESP._playerHighlights = {} end
    end
})

EspItemToggle = Main4:Toggle({
    Title = "Item ESP", Value = ESP.ItemEnabled,
    Desc = "Shows highlights and info labels on collectible items.",
    Callback = function(state)
        ESP.ItemEnabled = state; Config:Set("EspItemEnabled", state); Config:Save()
        if not state then for obj, _ in pairs(ESP._itemHighlights) do RemoveESP(obj) end; ESP._itemHighlights = {} end
    end
})

Main4:Section({ Title = "Esp Settings", Icon = "settings" })

EspSettingsDropdown = Main4:Dropdown({
    Title = "ESP Options",
    Desc = "Selects which extra ESP labels and visuals are shown.",
    Multi = true,
    Values = { "Highlight", "Distance", "Health", "Name" },
    Value = ESP.Settings,
    Callback = function(value)
        ESP.Settings = value or {}; Config:Set("EspSettings", value); Config:Save()
        if ESP.Enabled then ClearAllESP() end
    end,
})

EspItemDropdown = Main4:Dropdown({
    Title = "ESP Items",
    Desc = "Selects which collectible item names should receive Item ESP.",
    Multi = true,
    Values = ESP.ItemList,
    Value = ESP.SelectedItems,
    Callback = function(value)
        ESP.SelectedItems = value or {}; Config:Set("EspSelectedItems", value); Config:Save()
        for obj, _ in pairs(ESP._itemHighlights) do RemoveESP(obj) end
        ESP._itemHighlights = {}
        if ESP.Enabled and ESP.ItemEnabled then pcall(ScanItems) end
    end,
})

-- ====================== UI: PLAYER TAB ======================
Main2:Section({ Title = "Local Player", Icon = "user" })

WSValue = Config:Get("WSValue", 16)
JPValue = Config:Get("JPValue", 50)
NoClip  = Config:Get("NoClip", false)
LockMovementStats = Config:Get("LockMovementStats", true)
FlyEnabled = Config:Get("FlyEnabled", false)
FlySpeed = Config:Get("FlySpeed", 1)
InfiniteJumpEnabled = Config:Get("InfiniteJumpEnabled", false)
FullBrightEnabled = Config:Get("FullBrightEnabled", false)
NoFogEnabled = Config:Get("NoFogEnabled", false)

LastMovementStatApply = 0
MovementStatInterval  = 0.25
FlyBodyVelocity = nil
FlyBodyGyro = nil
FlyRenderConnection = nil
LastVisualApply = 0
FullBrightOriginal = nil
NoFogOriginal = nil

function GetLocalHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

function GetLocalRootPart()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

function updatePlayerStats(force)
    local humanoid = GetLocalHumanoid()
    if not humanoid then return end

    pcall(function()
        if humanoid.UseJumpPower ~= nil then
            humanoid.UseJumpPower = true
        end
    end)

    if force or humanoid.WalkSpeed ~= WSValue then
        humanoid.WalkSpeed = WSValue
    end

    if force or humanoid.JumpPower ~= JPValue then
        humanoid.JumpPower = JPValue
    end
end

function ProtectMovementStats()
    if not LockMovementStats then return end

    local now = tick()
    if now - LastMovementStatApply < MovementStatInterval then return end
    LastMovementStatApply = now

    local humanoid = GetLocalHumanoid()
    if not humanoid then return end

    pcall(function()
        if humanoid.UseJumpPower ~= nil then
            humanoid.UseJumpPower = true
        end
    end)

    -- Anti-reduce mode: restore only when the game lowers the saved values.
    if humanoid.WalkSpeed < WSValue then
        humanoid.WalkSpeed = WSValue
    end

    if humanoid.JumpPower < JPValue then
        humanoid.JumpPower = JPValue
    end
end

function CleanupFlyForces()
    if FlyBodyVelocity then
        pcall(function() FlyBodyVelocity:Destroy() end)
        FlyBodyVelocity = nil
    end
    if FlyBodyGyro then
        pcall(function() FlyBodyGyro:Destroy() end)
        FlyBodyGyro = nil
    end
end

function StartFly()
    local humanoid = GetLocalHumanoid()
    local root = GetLocalRootPart()
    if not humanoid or not root then return end

    CleanupFlyForces()

    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Name = "DYHUB_FlyVelocity"
    FlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.Parent = root

    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.Name = "DYHUB_FlyGyro"
    FlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    FlyBodyGyro.P = 10000
    FlyBodyGyro.CFrame = root.CFrame
    FlyBodyGyro.Parent = root

    humanoid.PlatformStand = true
end

function StopFly()
    CleanupFlyForces()
    local humanoid = GetLocalHumanoid()
    if humanoid then
        humanoid.PlatformStand = false
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
end

function GetFlyVerticalInput()
    local vertical = 0
    pcall(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
            vertical = vertical + 1
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            vertical = vertical - 1
        end
    end)
    return vertical
end

function UpdateFly()
    if not FlyEnabled then return end

    local humanoid = GetLocalHumanoid()
    local root = GetLocalRootPart()
    local cam = workspace.CurrentCamera
    if not humanoid or not root or not cam then return end

    if not FlyBodyVelocity or FlyBodyVelocity.Parent ~= root or not FlyBodyGyro or FlyBodyGyro.Parent ~= root then
        StartFly()
        return
    end

    humanoid.PlatformStand = true

    local move = humanoid.MoveDirection
    local vertical = GetFlyVerticalInput()
    local velocity = move + Vector3.new(0, vertical, 0)

    if velocity.Magnitude > 0 then
        velocity = velocity.Unit
    end

    FlyBodyVelocity.Velocity = velocity * ((tonumber(FlySpeed) or 1) * 20)
    FlyBodyGyro.CFrame = cam.CFrame
end

function EnsureFlyRenderLoop()
    if FlyRenderConnection then return end
    FlyRenderConnection = RunService.RenderStepped:Connect(UpdateFly)
end

function CaptureFullBrightOriginal()
    if FullBrightOriginal then return end
    FullBrightOriginal = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ExposureCompensation = Lighting.ExposureCompensation,
    }
end

function ApplyFullBright()
    CaptureFullBrightOriginal()
    pcall(function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.ExposureCompensation = 0
    end)
end

function RestoreFullBright()
    if not FullBrightOriginal then return end
    pcall(function()
        Lighting.Brightness = FullBrightOriginal.Brightness
        Lighting.ClockTime = FullBrightOriginal.ClockTime
        Lighting.GlobalShadows = FullBrightOriginal.GlobalShadows
        Lighting.Ambient = FullBrightOriginal.Ambient
        Lighting.OutdoorAmbient = FullBrightOriginal.OutdoorAmbient
        Lighting.ExposureCompensation = FullBrightOriginal.ExposureCompensation
    end)
    FullBrightOriginal = nil
end

function CaptureNoFogOriginal()
    if NoFogOriginal then return end
    NoFogOriginal = {
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor,
        Atmospheres = {},
    }
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Atmosphere") then
            table.insert(NoFogOriginal.Atmospheres, {
                Instance = obj,
                Density = obj.Density,
                Haze = obj.Haze,
                Glare = obj.Glare,
                Offset = obj.Offset,
            })
        end
    end
end

function ApplyNoFog()
    CaptureNoFogOriginal()
    pcall(function()
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
    end)
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Atmosphere") then
            pcall(function()
                obj.Density = 0
                obj.Haze = 0
                obj.Glare = 0
                obj.Offset = 0
            end)
        end
    end
end

function RestoreNoFog()
    if not NoFogOriginal then return end
    pcall(function()
        Lighting.FogStart = NoFogOriginal.FogStart
        Lighting.FogEnd = NoFogOriginal.FogEnd
        Lighting.FogColor = NoFogOriginal.FogColor
    end)
    for _, data in ipairs(NoFogOriginal.Atmospheres or {}) do
        local obj = data.Instance
        if obj and obj.Parent then
            pcall(function()
                obj.Density = data.Density
                obj.Haze = data.Haze
                obj.Glare = data.Glare
                obj.Offset = data.Offset
            end)
        end
    end
    NoFogOriginal = nil
end

RunService.Heartbeat:Connect(function()
    ProtectMovementStats()

    local now = tick()
    if now - LastVisualApply >= 1 then
        LastVisualApply = now
        if FullBrightEnabled then ApplyFullBright() end
        if NoFogEnabled then ApplyNoFog() end
    end
end)

EnsureFlyRenderLoop()

UserInputService.JumpRequest:Connect(function()
    if not InfiniteJumpEnabled then return end
    local humanoid = GetLocalHumanoid()
    if humanoid then
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end)

RunService.Stepped:Connect(function()
    if NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    updatePlayerStats(true)
    if FlyEnabled then StartFly() end
end)

Main2:Slider({
    Title = "Set Walkspeed",
    Desc = "Sets your saved movement speed value.",
    Value = { Min = 1, Max = 200, Default = WSValue },
    Step = 1,
    Callback = function(value)
        WSValue = value
        Config:Set("WSValue", value)
        Config:Save()
        updatePlayerStats(true)
    end
})

Main2:Slider({
    Title = "Set Jumppower",
    Desc = "Sets your saved jump power value.",
    Value = { Min = 1, Max = 500, Default = JPValue },
    Step = 1,
    Callback = function(value)
        JPValue = value
        Config:Set("JPValue", value)
        Config:Save()
        updatePlayerStats(true)
    end
})

Main2:Toggle({
    Title = "Lock Movement Stats",
    Desc = "Restores WalkSpeed and JumpPower when the game lowers them.",
    Value = LockMovementStats,
    Callback = function(state)
        LockMovementStats = state
        Config:Set("LockMovementStats", state)
        Config:Save()
        if state then updatePlayerStats(true) end
    end
})

nocliptoggle = Main2:Toggle({
    Title = "No Clip",
    Value = NoClip,
    Desc = "Allows your character to pass through walls and parts.",
    Callback = function(state) NoClip = state; Config:Set("NoClip", state); Config:Save() end
})

Main2:Section({ Title = "Fly Movement", Icon = "plane" })

Main2:Slider({
    Title = "Fly Speed",
    Desc = "Adjusts flight speed while Fly is enabled.",
    Value = { Min = 1, Max = 20, Default = FlySpeed },
    Step = 1,
    Callback = function(value)
        FlySpeed = value
        Config:Set("FlySpeed", value)
        Config:Save()
    end
})

Main2:Toggle({
    Title = "Fly",
    Desc = "Enables flight movement. Use Space/E to rise and Ctrl/Q to descend.",
    Value = FlyEnabled,
    Callback = function(state)
        FlyEnabled = state
        Config:Set("FlyEnabled", state)
        Config:Save()
        if state then StartFly() else StopFly() end
    end
})

Main2:Section({ Title = "Visual & Utility", Icon = "sun" })

Main2:Toggle({
    Title = "Infinite Jump",
    Desc = "Allows repeated jumping while airborne.",
    Value = InfiniteJumpEnabled,
    Callback = function(state)
        InfiniteJumpEnabled = state
        Config:Set("InfiniteJumpEnabled", state)
        Config:Save()
    end
})

Main2:Toggle({
    Title = "Full Bright",
    Desc = "Improves map brightness and restores old lighting when disabled.",
    Value = FullBrightEnabled,
    Callback = function(state)
        FullBrightEnabled = state
        Config:Set("FullBrightEnabled", state)
        Config:Save()
        if state then ApplyFullBright() else RestoreFullBright() end
    end
})

Main2:Toggle({
    Title = "No Fog",
    Desc = "Removes distance fog and restores old fog settings when disabled.",
    Value = NoFogEnabled,
    Callback = function(state)
        NoFogEnabled = state
        Config:Set("NoFogEnabled", state)
        Config:Save()
        if state then ApplyNoFog() else RestoreNoFog() end
    end
})

Main2:Section({ Title = "Redeem Codes", Icon = "bird" })

SelectedCodes = Config:Get("SelectedCodes", {})

CodeDropdown = Main2:Dropdown({
    Title = "Select Redeem Codes",
    Desc = "Selects which codes will be redeemed.",
    Multi = true,
    Values = GlobalTables.redeemCodes, Value = SelectedCodes,
    Callback = function(value) SelectedCodes = value or {}; Config:Set("SelectedCodes", value); Config:Save() end,
})

Main2:Button({
    Title = "Redeem Codes",
    Desc = "Redeems only the codes you have selected in the dropdown.",
    Callback = function()
        for _, code in ipairs(SelectedCodes or {}) do
            pcall(function() local remote = GetRemote("RedeemCode"); if remote then remote:FireServer(code) end; task.wait(0.2) end)
        end
    end,
})

Main2:Button({
    Title = "Redeem Code All",
    Desc = "Redeems all available codes at once.",
    Callback = function()
        for _, code in ipairs(GlobalTables.redeemCodes or {}) do
            pcall(function() local remote = GetRemote("RedeemCode"); if remote then remote:FireServer(code) end; task.wait(0.5) end)
        end
    end,
})

-- ====================== UI: UNLOCK GAMEPASS ======================
Main2:Section({ Title = "Unlock Gamepass", Icon = "badge-dollar-sign" })

SelectedGamepass = Config:Get("SelectedGamepass", {})
GlobalTables.Gamepassts = SelectedGamepass

GamepassDropdown = Main2:Dropdown({
    Title = "Select Gamepass",
    Desc = "Selects which local gamepass flags to unlock.",
    Multi = true,
    Values = GlobalTables.Gamepasst,
    Value = SelectedGamepass,
    Callback = function(value)
        GlobalTables.Gamepassts = value or {}
        SelectedGamepass = value or {}
        Config:Set("SelectedGamepass", value)
        Config:Save()
    end,
})

Main2:Button({
    Title = "Unlock Gamepass",
    Desc = "Unlocks the selected gamepasses locally for free.",
    Callback = function()
        local gachaData = LocalPlayer:FindFirstChild("GachaData")
        if not gachaData then
            gachaData = Instance.new("Folder")
            gachaData.Name = "GachaData"
            gachaData.Parent = LocalPlayer
        end
        local toUnlock = {}
        for _, v in ipairs(GlobalTables.Gamepassts) do
            if v == "All" then
                toUnlock = {"LuckyBoost", "RareLuckyBoost", "LegendaryLuckyBoost"}
                break
            else
                table.insert(toUnlock, v)
            end
        end
        if #toUnlock == 0 then
            WindUI:Notify({ Title = "Unlock Gamepass", Content = "Choose Gamepass first!", Duration = 3, Icon = "alert-triangle" })
            return
        end
        local successCount = 0
        for _, gamepassName in ipairs(toUnlock) do
            pcall(function()
                local boolValue = gachaData:FindFirstChild(gamepassName)
                if not boolValue then
                    boolValue = Instance.new("BoolValue")
                    boolValue.Name = gamepassName
                    boolValue.Parent = gachaData
                end
                boolValue.Value = true
                successCount = successCount + 1
                task.wait(0.2)
            end)
        end
        WindUI:Notify({
            Title = "Unlock Gamepass",
            Content = "Unlocked " .. successCount .. "/" .. #toUnlock .. " gamepass(es) Done!",
            Duration = 3,
            Icon = "badge-check"
        })
    end,
})

-- ====================== UI: GAMEMODE TAB ======================
GlobalTables2 = {
    Votes2 = {
        "Normal", "VeryHard", "Hard", "Insane", "Nightmare", "BossRush",
        "DarkDimension", "Hell", "ThunderStorm", "Christmas", "Zombie",
        "AstroV2", "Astro", "100MVisit","ZombieV2"
    }
}

Main7:Section({ Title = "Vote Information", TextXAlignment = "Center", TextSize = 17 })
Main7:Divider()
Main7:Paragraph({
    Title = "Auto Vote: Game Mode",
    Desc = "- [ Step 1 ] Click Restore Vote System \n- [ Step 2 ] Stay in the Lobby (inside a game)\n- [ Step 3 ] Set Auto Vote & Wait",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})
Main7:Divider()
Main7:Section({ Title = "Vote Mode", Icon = "gamepad-2" })

Main7:Button({
    Title = "Restore Vote System",
    Desc = "⚠️ Press this once before using Auto Vote Mode for the first time.",
    Callback = function()
        pcall(function()
            ReplicatedStorage.GetReadyRemote:FireServer("1", true)
            task.wait(0.5)
            ReplicatedStorage.GetReadyRemote:FireServer("1", false)
            task.wait(0.5)
            ReplicatedStorage.GetReadyRemote:FireServer("2", false)
            task.wait(0.5)
            ReplicatedStorage.GetReadyRemote:FireServer("3", false)
            task.wait(0.5)
            ReplicatedStorage.GetReadyRemote:FireServer("1", true)
        end)
        WindUI:Notify({
            Title = "Restore Loading...",
            Content = "Ready, Restore Vote System...",
            Duration = 6,
            Icon = "loader-circle"
        })
        task.wait(6)
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(-220, -10, -600)
            end
        end)
        WindUI:Notify({
            Title = "Restore Loading...",
            Content = "Restore Vote System, please wait...",
            Duration = 10,
            Icon = "loader-circle"
        })
        task.wait(10)
        WindUI:Notify({
            Title = "Restore Complete",
            Content = "Vote System restored! You can now use Auto Vote Mode.",
            Duration = 5,
            Icon = "check"
        })
    end
})

GameModeDropdown2 = Main7:Dropdown({
    Title = "Set Vote Mode",
    Desc = "Selects which game mode Auto Vote will vote for.",
    Values = GlobalTables2.Votes2,
    Multi = false,
    Value = AutoVoteValue,
    Callback = function(value)
        AutoVoteValue = value
        Config:Set("AutoVoteValue", value)
        Config:Save()

        print("[DYHUB] Vote Mode selected:", tostring(value))
    end
})

AutoVoteIGToggle = Main7:Toggle({
    Title = "Auto Vote Mode (In-Game)",
    Desc = "Automatically votes for the selected mode each round.",
    Value = AutoVoteinGameEnabled,
    Callback = function(enabled)
        AutoVoteinGameEnabled = enabled
        Config:Set("AutoVoteinGameEnabled", enabled)
        Config:Save()

        if enabled then
            if AutoStartEnabled and IsMiscFarmAllowed() then
                FireGetReady(0)
            else
                FireAutoVote(true)
            end
            StartAutoVoteLoop()
        else
            print("[DYHUB] Auto Vote Mode disabled")
        end
    end
})

if AutoVoteinGameEnabled then
    StartAutoVoteLoop()
end

Main7:Divider()
Main7:Section({ Title = "Casual Information", TextXAlignment = "Center", TextSize = 17 })
Main7:Divider()
Main7:Paragraph({
    Title = "Casual: Mission Selection",
    Desc = "- [ Step 1 ] Stay in the Lobby (not inside a game)\n- [ Step 2 ] Press Play and go to the Classic gamemode selection screen\n- [ Step 3 ] Select Casual and finish teleporting\n- [ Step 4 ] Run the script",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})
Main7:Divider()
Main7:Section({ Title = "Game Mode", Icon = "gamepad-2" })

GameModeDropdown = Main7:Dropdown({
    Title = "Set Game Mode",
    Desc = "Selects which game mode Auto Create will create.",
    Values = GlobalTables.Mode,
    Multi = false,
    Value = AutoGameValue,
    Callback = function(value)
        AutoGameValue = value; Config:Set("AutoGameValue", value); Config:Save()
        print("[DYHUB] Game Mode selected: " .. tostring(value))
    end
})

-- PLAY SYSTEM (auto-navigate to Classic/Casual on load)
--// PLAY + LOBBY SYSTEM
DELAY = 1

function click_btn(btn)
    if btn and (btn:IsA("ImageButton") or btn:IsA("TextButton")) then
        pcall(function()
            if firesignal then
                firesignal(btn.MouseButton1Click)
                firesignal(btn.Activated)
            else
                btn:Activate()
            end
        end)
    end
end

function notify(title, content, icon)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = 3,
        Icon = "check"
    })
end

--// PLAY SYSTEM
task.spawn(function()
    local playBtn =
        workspace:FindFirstChild("ForGui") and
        workspace.ForGui:FindFirstChild("SurfaceGui") and
        workspace.ForGui.SurfaceGui:FindFirstChild("Frame") and
        workspace.ForGui.SurfaceGui.Frame:FindFirstChild("Play")

    if playBtn then
        notify("Auto Play", "Detected Play button, auto starting...")
        task.wait(DELAY)

        local playGui = pg:FindFirstChild("Play")

        -- ถ้ายังไม่เปิด GUI Play แปลว่ายังไม่ได้กด
        if not (playGui and playGui.Enabled) then
            click_btn(playBtn)
            notify("Auto Play", "Pressed Play button")
        else
            notify("Auto Play", "Play GUI already opened")
        end
    end

    task.wait(DELAY)

    local playGui = pg:FindFirstChild("Play")
    if not (playGui and playGui.Enabled) then
        return
    end

    local classicBtn = playGui:FindFirstChild("Classic")

    if classicBtn then
        notify("Auto Play", "Selecting Classic mode...")
        task.wait(DELAY)
        click_btn(classicBtn)
    end

    task.wait(DELAY)

    local modeGui = pg:FindFirstChild("mode select2")

    if modeGui and modeGui.Enabled then
        local diffBtn =
            modeGui:FindFirstChild("MainFrame") and
            modeGui.MainFrame:FindFirstChild("DiffMode")

        if diffBtn then
            notify("Auto Play", "Selecting difficulty...")
            task.wait(DELAY)
            click_btn(diffBtn)
        end
    end
end)

--// NEW LOBBY SYSTEM
task.spawn(function()
    while true do
        task.wait(0.5)

        local loadingGui = pg:FindFirstChild("LoadingScreen")

        -- ลบ LoadingScreen ถ้ามี
        if loadingGui then
            notify("Lobby System", "Removing LoadingScreen...")
            pcall(function()
                loadingGui:Destroy()
            end)
        end

        local lobby = pg:FindFirstChild("Lobby")

        -- รอจน Lobby เปิด
        if lobby and lobby.Enabled then
            notify("Lobby System", "Lobby detected, preparing auto setup...")

            local btn =
                lobby:FindFirstChild("MainFrame") and
                lobby.MainFrame:FindFirstChild("Frame") and
                lobby.MainFrame.Frame:FindFirstChild("Create") and
                lobby.MainFrame.Frame.Create:FindFirstChild("TrackQuestButton")

            if btn and btn.Visible then
                notify("Lobby System", "Pressing TrackQuestButton...")
                click_btn(btn)

                task.wait(0.5)

                -- ยิง Remote เฉพาะตอนเปิด Toggle
                if AutoVoteEnabled then
                    notify("Lobby System", "Creating game mode...")

                    ReplicatedStorage.MainHandler:FireServer({
                        [1] = "StartSolo",
                        [2] = AutoGameValue
                    })

                    notify("Lobby System", "Gamemode created successfully!")
                else
                    notify("Lobby System", "Use with Auto Game Mode!")
                end

                break
            end
        end
    end
end)

--// AUTO GAME MODE TOGGLE
AutoVoteToggle = Main7:Toggle({
    Title = "Auto Game Mode (Lobby)",
    Desc = "Automatically creates the selected game mode when in the lobby.",
    Value = AutoVoteEnabled,

    Callback = function(enabled)
        AutoVoteEnabled = enabled

        Config:Set("AutoVoteEnabled", enabled)
        Config:Save()

        if enabled then
            notify("Auto Game Mode", "Enabled")
        else
            notify("Auto Game Mode", "Disabled", "x")
        end
    end
})


-- ====================== REQUEST / SKILL TREE HELPERS ======================
RequestWaveNotifyAt = 0
AutoSkillTreeNotifyAt = 0

function SafeWindNotify(title, content, duration, icon)
    if WindUI and WindUI.Notify then
        pcall(function()
            WindUI:Notify({
                Title = tostring(title or "DYHUB"),
                Content = tostring(content or ""),
                Duration = duration or 3,
                Icon = icon or "info"
            })
        end)
    end
end

function GetCurrentWaveText()
    local ok, result = pcall(function()
        local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return nil end

        local wavesGui = playerGui:FindFirstChild("WavesGui")
        if not wavesGui then return nil end

        local frame = wavesGui:FindFirstChild("Frame")
        if not frame then return nil end

        local label = frame:FindFirstChild("TextLabel")
        if not label then return nil end

        return tostring(label.Text or "")
    end)

    if ok then return result end
    return nil
end

function GetCurrentWaveNumber()
    local text = GetCurrentWaveText()
    if not text then return nil end

    local numberText = tostring(text):match("(%d+)")
    if not numberText then return nil end

    return tonumber(numberText)
end

function IsRequestWaveReady()
    local wave = GetCurrentWaveNumber()
    return wave ~= nil and wave >= 10
end

function NotifyRequestWaveNotReady()
    local now = tick()
    if now - RequestWaveNotifyAt < 4 then return end
    RequestWaveNotifyAt = now

    if GetCurrentWaveNumber() == nil then
        SafeWindNotify("Auto Request", "Cannot request yet. Wave UI is not ready.", 3, "triangle-alert")
    else
        SafeWindNotify("Auto Request", "Cannot request yet. Required Wave 10 or higher.", 3, "triangle-alert")
    end
end

function GetCurrentCharacterValue()
    local ok, result = pcall(function()
        local playerValues = LocalPlayer and LocalPlayer:FindFirstChild("PlayerValues")
        if not playerValues then return nil end

        local charValue = playerValues:FindFirstChild("Character")
        if not charValue then return nil end

        return tostring(charValue.Value or "")
    end)

    if ok then return result end
    return nil
end

function GetSkillTreeUIFolder()
    local characterName = GetCurrentCharacterValue()
    if not characterName or characterName == "" then return nil, characterName end

    local ok, result = pcall(function()
        local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return nil end

        local skillGui = playerGui:FindFirstChild("003-A")
        if not skillGui then return nil end

        local main = skillGui:FindFirstChild("Main")
        if not main then return nil end

        local scrolling = main:FindFirstChild("ScrollingFrame")
        if not scrolling then return nil end

        local direct = scrolling:FindFirstChild("Skills " .. characterName)
        if direct then return direct end

        local loweredName = characterName:lower()
        for _, child in ipairs(scrolling:GetChildren()) do
            local childName = tostring(child.Name or ""):lower()
            if childName:find("skills", 1, true) and childName:find(loweredName, 1, true) then
                return child
            end
        end

        return nil
    end)

    if ok then return result, characterName end
    return nil, characterName
end

function HasOwnedSkillTree(skillName)
    local folder = LocalPlayer and LocalPlayer:FindFirstChild("SkillTreesFolder")
    if not folder then return false end

    if folder:FindFirstChild(skillName) then return true end

    local loweredName = tostring(skillName or ""):lower()
    for _, child in ipairs(folder:GetChildren()) do
        if tostring(child.Name or ""):lower() == loweredName then
            return true
        end
    end

    return false
end

function IsSkillTreeBuyObject(obj)
    if not obj or not obj.Name then return false end

    local loweredName = tostring(obj.Name):lower()
    if loweredName == "" then return false end
    if loweredName:find("layout", 1, true) then return false end
    if loweredName:find("padding", 1, true) then return false end
    if loweredName:find("stroke", 1, true) then return false end
    if loweredName:find("corner", 1, true) then return false end

    if obj:IsA("GuiObject") or obj:IsA("Folder") or obj:IsA("Model") then
        return true
    end

    return false
end

function GetSkillTreesRemote()
    local remote = GetRemote("skilltrees")
    if remote then return remote end

    pcall(function()
        remote = ReplicatedStorage:FindFirstChild("SkillTrees") or ReplicatedStorage:FindFirstChild("SkillTree") or ReplicatedStorage:WaitForChild("skilltrees", 2)
    end)

    return remote
end

function NotifyAutoSkillTree(message)
    local now = tick()
    if now - AutoSkillTreeNotifyAt < 5 then return end
    AutoSkillTreeNotifyAt = now
    SafeWindNotify("Auto Skill Tree", tostring(message or "Skill tree is not ready."), 3, "triangle-alert")
end

function FireAutoSkillTrees()
    local remote = GetSkillTreesRemote()
    if not remote then
        NotifyAutoSkillTree("Skill tree remote was not found.")
        return false
    end

    local folder, characterName = GetSkillTreeUIFolder()
    if not characterName or characterName == "" then
        NotifyAutoSkillTree("Cannot read your current character.")
        return false
    end

    if not folder then
        NotifyAutoSkillTree("Skill tree UI for " .. tostring(characterName) .. " was not found.")
        return false
    end

    local fired = 0
    for _, skillObj in ipairs(folder:GetChildren()) do
        if IsSkillTreeBuyObject(skillObj) and not HasOwnedSkillTree(skillObj.Name) then
            local remoteArg = tostring(skillObj.Name):lower()
            local ok, err = pcall(function()
                remote:FireServer(remoteArg)
            end)

            if ok then
                fired = fired + 1
                print("[DYHUB] Auto Skill Tree fired:", remoteArg)
            else
                warn("[DYHUB] Auto Skill Tree failed:", remoteArg, err)
            end

            task.wait(0.35)
        end
    end

    return true
end


-- ====================== UI: SHOP SYSTEMS ======================
Main5:Section({ Title = "Auto Gacha", Icon = "sparkles" })

-- Run the whole Shop UI/state setup inside its own block scope.
-- This avoids Luau's 200-local-register limit in the main chunk.
_G.__DYHUB_ShopSystems = function()
    local gachaArgs = { "1Spin", "10Spins", "100Spins", "1SpinLucky", "10SpinLucky" }

    local autoGachaCharacterEnabled = Config:Get("AutoGachaCharacterEnabled", false)
    local autoGachaSkinEnabled      = Config:Get("AutoGachaSkinEnabled", false)
    local selectedGachaCharacterArg = Config:Get("SelectedGachaCharacterArg", "1Spin")
    local selectedGachaSkinArg      = Config:Get("SelectedGachaSkinArg", "1Spin")
    local characterGachaRunning     = false
    local skinGachaRunning          = false

    local autoUseItemEnabled        = Config:Get("AutoUseItemEnabled", false)
    local selectedUseItem           = Config:Get("SelectedUseItem", "Presents")
    local useItemRunning            = false

    local selectedRequestItem       = Config:Get("SelectedRequestItem", "Titan-Request")
    local autoRequestEnabled        = Config:Get("AutoRequestEnabled", false)
    local autoSkillTreeEnabled      = Config:Get("AutoSkillTreeEnabled", false)

    local function EnsureList(value, fallback)
        if type(value) == "table" then
            return value
        end
        if value ~= nil then
            return { value }
        end
        return fallback or {}
    end

    local function WaitWhileEnabled(seconds, enabledFn)
        local elapsed = 0
        while elapsed < seconds do
            if enabledFn and not enabledFn() then
                return false
            end
            task.wait(0.5)
            elapsed = elapsed + 0.25
        end
        return true
    end

    local function FireShopRemote(remoteName, ...)
        local remote = GetRemote(remoteName)
        if not remote then return false end

        local args = { ... }
        local ok, err = pcall(function()
            remote:FireServer(unpack(args))
        end)

        if not ok then
            warn("[DYHUB] Shop remote failed:", tostring(remoteName), err)
        end

        return ok
    end

    local function ShouldShopSyncWithHeli()
        -- Sync only when Auto Skip Helicopter is active.
        -- This prevents skipping before shop/upgrade remotes finish.
        return AutoSkipHeliEnabled and IsMiscFarmAllowed()
    end

    local function StartAutoGachaCharacter()
        if characterGachaRunning then return end
        characterGachaRunning = true
        task.spawn(function()
            while autoGachaCharacterEnabled do
                FireShopRemote("GachaCharacter", selectedGachaCharacterArg)
                task.wait(1)
            end
            characterGachaRunning = false
        end)
    end

    local function StartAutoGachaSkin()
        if skinGachaRunning then return end
        skinGachaRunning = true
        task.spawn(function()
            while autoGachaSkinEnabled do
                FireShopRemote("GachaSkins", selectedGachaSkinArg)
                task.wait(1)
            end
            skinGachaRunning = false
        end)
    end

    local function StartAutoUseItem()
        if useItemRunning then return end
        useItemRunning = true
        task.spawn(function()
            while autoUseItemEnabled do
                if selectedUseItem == "Presents" then
                    FireShopRemote("GachaCapsule")
                end
                task.wait(1.5)
            end
            useItemRunning = false
        end)
    end

    Main5:Dropdown({
        Title = "Gacha Character",
        Desc = "Selects the spin type used for character gacha.",
        Values = gachaArgs,
        Multi = false,
        Value = selectedGachaCharacterArg,
        Callback = function(value)
            selectedGachaCharacterArg = value or "1Spin"
            Config:Set("SelectedGachaCharacterArg", selectedGachaCharacterArg)
            Config:Save()
        end
    })

    Main5:Toggle({
        Title = "Auto Gacha Character",
        Value = autoGachaCharacterEnabled,
        Desc = "Automatically spins character gacha using the selected option.",
        Callback = function(enabled)
            autoGachaCharacterEnabled = enabled
            Config:Set("AutoGachaCharacterEnabled", enabled)
            Config:Save()
            if enabled then StartAutoGachaCharacter() end
        end
    })

    Main5:Dropdown({
        Title = "Gacha Skin",
        Desc = "Selects the spin type used for skin gacha.",
        Values = gachaArgs,
        Multi = false,
        Value = selectedGachaSkinArg,
        Callback = function(value)
            selectedGachaSkinArg = value or "1Spin"
            Config:Set("SelectedGachaSkinArg", selectedGachaSkinArg)
            Config:Save()
        end
    })

    Main5:Toggle({
        Title = "Auto Gacha Skin",
        Value = autoGachaSkinEnabled,
        Desc = "Automatically spins skin gacha using the selected option.",
        Callback = function(enabled)
            autoGachaSkinEnabled = enabled
            Config:Set("AutoGachaSkinEnabled", enabled)
            Config:Save()
            if enabled then StartAutoGachaSkin() end
        end
    })

    Main5:Section({ Title = "Auto Use Item", Icon = "package-open" })

    Main5:Dropdown({
        Title = "Use Item",
        Desc = "Selects the item that Auto Use Item will activate.",
        Values = { "Presents" },
        Multi = false,
        Value = selectedUseItem,
        Callback = function(value)
            selectedUseItem = value or "Presents"
            Config:Set("SelectedUseItem", selectedUseItem)
            Config:Save()
        end
    })

    Main5:Toggle({
        Title = "Auto Use Item",
        Value = autoUseItemEnabled,
        Desc = "Automatically uses the selected item with a safe delay.",
        Callback = function(enabled)
            autoUseItemEnabled = enabled
            Config:Set("AutoUseItemEnabled", enabled)
            Config:Save()
            if enabled then StartAutoUseItem() end
        end
    })

    -- ====================== SYNC SHOP BUY / UPGRADE SYSTEM ======================
    Main5:Section({ Title = "Shop Upgrade", Icon = "arrow-big-up-dash" })

    local titanSpeakerUpgradeValues = { "Jetpack", "OverCharge", "SoundBooster", "Core", "Upgrade" }
    local utcmUpgradeValues         = { "Shield", "Blaster", "Lens", "Heat", "Armor" }
    local tvUpgradeValues           = { "Absorb", "ShareOverCharge", "Shield", "AstroArm" }

    local selectedTitanSpeakerUpgrades = EnsureList(Config:Get("SelectedTitanSpeakerUpgrades", { "Jetpack" }), { "Jetpack" })
    local selectedUTCMUpgrades         = EnsureList(Config:Get("SelectedUTCMUpgrades", { "Shield" }), { "Shield" })
    local selectedTVUpgrades           = EnsureList(Config:Get("SelectedTVUpgrades", { "Absorb" }), { "Absorb" })

    local upgradeTitanSpeakerEnabled = Config:Get("UpgradeTitanSpeakerEnabled", false)
    local upgradeUTCMEnabled         = Config:Get("UpgradeUTCMEnabled", false)
    local upgradeTVEnabled           = Config:Get("UpgradeTVEnabled", false)

    local StartAutoSyncedShopLoop = function() end

    Main5:Dropdown({
        Title = "Select Titan Speaker Upgrade",
        Desc = "Selects which Titan Speaker upgrades will be requested.",
        Values = titanSpeakerUpgradeValues,
        Multi = true,
        Value = selectedTitanSpeakerUpgrades,
        Callback = function(values)
            selectedTitanSpeakerUpgrades = values or {}
            Config:Set("SelectedTitanSpeakerUpgrades", selectedTitanSpeakerUpgrades)
            Config:Save()
        end
    })

    Main5:Toggle({
        Title = "Upgrade Titan Speaker",
        Desc = "Automatically requests the selected Titan Speaker upgrades.",
        Value = upgradeTitanSpeakerEnabled,
        Callback = function(enabled)
            upgradeTitanSpeakerEnabled = enabled
            Config:Set("UpgradeTitanSpeakerEnabled", enabled)
            Config:Save()
            if enabled then StartAutoSyncedShopLoop() end
        end
    })

    Main5:Dropdown({
        Title = "Select UTCM Upgrade",
        Desc = "Selects which UTCM upgrades will be requested.",
        Values = utcmUpgradeValues,
        Multi = true,
        Value = selectedUTCMUpgrades,
        Callback = function(values)
            selectedUTCMUpgrades = values or {}
            Config:Set("SelectedUTCMUpgrades", selectedUTCMUpgrades)
            Config:Save()
        end
    })

    Main5:Toggle({
        Title = "Upgrade UTCM",
        Desc = "Automatically requests the selected UTCM upgrades.",
        Value = upgradeUTCMEnabled,
        Callback = function(enabled)
            upgradeUTCMEnabled = enabled
            Config:Set("UpgradeUTCMEnabled", enabled)
            Config:Save()
            if enabled then StartAutoSyncedShopLoop() end
        end
    })

    Main5:Dropdown({
        Title = "Select TV Upgrade",
        Desc = "Selects which TV upgrades will be requested.",
        Values = tvUpgradeValues,
        Multi = true,
        Value = selectedTVUpgrades,
        Callback = function(values)
            selectedTVUpgrades = values or {}
            Config:Set("SelectedTVUpgrades", selectedTVUpgrades)
            Config:Save()
        end
    })

    Main5:Toggle({
        Title = "Upgrade TV",
        Desc = "Automatically requests the selected TV upgrades.",
        Value = upgradeTVEnabled,
        Callback = function(enabled)
            upgradeTVEnabled = enabled
            Config:Set("UpgradeTVEnabled", enabled)
            Config:Save()
            if enabled then StartAutoSyncedShopLoop() end
        end
    })

    Main5:Section({ Title = "Shop Weapon", Icon = "helicopter" })

    local autoBuyWeaponValue   = Config:Get("AutoBuyWeaponValue", "Stungun")
    local autoBuyWeaponEnabled = Config:Get("AutoBuyWeaponEnabled", false)

    WeaponDropdown = Main5:Dropdown({
        Title = "Select Weapon",
        Desc = "Selects the weapon that will be bought automatically.",
        Values = GlobalTables.Weapon,
        Multi = false,
        Value = autoBuyWeaponValue,
        Callback = function(value)
            autoBuyWeaponValue = value
            Config:Set("AutoBuyWeaponValue", value)
            Config:Save()
        end
    })

    AutoBuyWeaponToggle = Main5:Toggle({
        Title = "Buy Weapon",
        Desc = "Automatically buys the selected weapon during shop cycles.",
        Value = autoBuyWeaponEnabled,
        Callback = function(enabled)
            autoBuyWeaponEnabled = enabled
            Config:Set("AutoBuyWeaponEnabled", enabled)
            Config:Save()
            if enabled then StartAutoSyncedShopLoop() end
        end
    })

    Main5:Button({
        Title = "Buy Weapon (Once)",
        Desc = "Buys the selected weapon one time.",
        Callback = function()
            if autoBuyWeaponValue then
                FireShopRemote("ShopSystem", "Buy", autoBuyWeaponValue)
            end
        end
    })

    Main5:Section({ Title = "Shop Misc", Icon = "helicopter" })

    local autoBuyMiscValue   = Config:Get("AutoBuyMiscValue", "HeadPhone")
    local autoBuyMiscEnabled = Config:Get("AutoBuyMiscEnabled", false)

    if table.find(GlobalTables.RequestTitanSpeaker, autoBuyMiscValue) or not table.find(GlobalTables.MiscShop, autoBuyMiscValue) then
        autoBuyMiscValue = "HeadPhone"
        Config:Set("AutoBuyMiscValue", autoBuyMiscValue)
        Config:Save()
    end

    if not table.find(GlobalTables.RequestTitanSpeaker, selectedRequestItem) then
        selectedRequestItem = "Titan-Request"
        Config:Set("SelectedRequestItem", selectedRequestItem)
        Config:Save()
    end

    MiscShopDropdown = Main5:Dropdown({
        Title = "Select Misc",
        Desc = "Selects the misc item that will be bought automatically.",
        Values = GlobalTables.MiscShop,
        Multi = false,
        Value = autoBuyMiscValue,
        Callback = function(value)
            autoBuyMiscValue = value
            Config:Set("AutoBuyMiscValue", value)
            Config:Save()
        end
    })

    AutoBuyMiscToggle = Main5:Toggle({
        Title = "Buy Misc",
        Value = autoBuyMiscEnabled,
        Desc = "Automatically buys the selected misc item during shop cycles.",
        Callback = function(enabled)
            autoBuyMiscEnabled = enabled
            Config:Set("AutoBuyMiscEnabled", enabled)
            Config:Save()
            if enabled then StartAutoSyncedShopLoop() end
        end
    })

    Main5:Button({
        Title = "Buy Misc (Once)",
        Desc = "Buys the selected misc item one time.",
        Callback = function()
            if autoBuyMiscValue then
                FireShopRemote("ShopSystem", "Buy", autoBuyMiscValue)
            end
        end
    })

    Main5:Section({ Title = "Request Titan / Speaker", Icon = "send" })

    RequestTitanSpeakerDropdown = Main5:Dropdown({
        Title = "Select Request",
        Desc = "Selects which Titan/Speaker request will be bought automatically.",
        Values = GlobalTables.RequestTitanSpeaker,
        Multi = false,
        Value = selectedRequestItem,
        Callback = function(value)
            selectedRequestItem = value or "Titan-Request"
            Config:Set("SelectedRequestItem", selectedRequestItem)
            Config:Save()
        end
    })

    AutoRequestToggle = Main5:Toggle({
        Title = "Auto Request",
        Desc = "Automatically requests the selected Titan/Speaker when Wave 10+.",
        Value = autoRequestEnabled,
        Callback = function(enabled)
            autoRequestEnabled = enabled
            Config:Set("AutoRequestEnabled", enabled)
            Config:Save()

            if enabled then
                if not IsRequestWaveReady() then
                    NotifyRequestWaveNotReady()
                end
                StartAutoSyncedShopLoop()
            end
        end
    })

    Main5:Section({ Title = "Skill Tree", Icon = "git-branch-plus" })

    AutoSkillTreeToggle = Main5:Toggle({
        Title = "Auto Skill Tree",
        Desc = "Automatically unlocks missing skill trees for your current character.",
        Value = autoSkillTreeEnabled,
        Callback = function(enabled)
            autoSkillTreeEnabled = enabled
            Config:Set("AutoSkillTreeEnabled", enabled)
            Config:Save()

            if enabled then
                StartAutoSyncedShopLoop()
            end
        end
    })

    local autoSyncedShopRunning = false

    local function IsHeavySyncedShopEnabled()
        return autoBuyWeaponEnabled
            or autoBuyMiscEnabled
            or upgradeTitanSpeakerEnabled
            or upgradeUTCMEnabled
            or upgradeTVEnabled
    end

    local function IsAnySyncedShopEnabled()
        return IsHeavySyncedShopEnabled()
            or autoRequestEnabled
            or autoSkillTreeEnabled
    end

    local function GetSyncedShopPreDelay()
        if not IsHeavySyncedShopEnabled() and (autoRequestEnabled or autoSkillTreeEnabled) then
            return 0
        end
        return 30
    end

    local function GetSyncedShopPostDelay()
        if not IsHeavySyncedShopEnabled() then
            if autoRequestEnabled then return 2 end
            if autoSkillTreeEnabled then return 5 end
        end
        return 10
    end

    local function FireSyncedShopBatch()
        if autoBuyWeaponEnabled and autoBuyWeaponValue then
            FireShopRemote("ShopSystem", "Buy", autoBuyWeaponValue)
            task.wait(0.35)
        end

        if autoBuyMiscEnabled and autoBuyMiscValue then
            FireShopRemote("ShopSystem", "Buy", autoBuyMiscValue)
            task.wait(0.35)
        end

        if autoRequestEnabled and selectedRequestItem then
            if IsRequestWaveReady() then
                FireShopRemote("ShopSystem", "Buy", selectedRequestItem)
            else
                NotifyRequestWaveNotReady()
            end
            task.wait(0.35)
        end

        if autoSkillTreeEnabled then
            FireAutoSkillTrees()
            task.wait(0.35)
        end

        if upgradeTitanSpeakerEnabled then
            for _, upgradeName in ipairs(selectedTitanSpeakerUpgrades or {}) do
                FireShopRemote("ChangeUpgradedTitanSpeaker", upgradeName)
                task.wait(0.35)
            end
        end

        if upgradeUTCMEnabled then
            for _, upgradeName in ipairs(selectedUTCMUpgrades or {}) do
                FireShopRemote("ForUpgradeUTCM", upgradeName)
                task.wait(0.35)
            end
        end

        if upgradeTVEnabled then
            for _, upgradeName in ipairs(selectedTVUpgrades or {}) do
                FireShopRemote("ForUpgradeTV", upgradeName)
                task.wait(0.35)
            end
        end
    end

    StartAutoSyncedShopLoop = function()
        if autoSyncedShopRunning then return end
        autoSyncedShopRunning = true

        task.spawn(function()
            local firstCycle = true

            while IsAnySyncedShopEnabled() do
                if not firstCycle then
                    if not WaitWhileEnabled(GetSyncedShopPreDelay(), IsAnySyncedShopEnabled) then break end
                end
                firstCycle = false

                local shouldSyncHeli = ShouldShopSyncWithHeli()
                if shouldSyncHeli then
                    TriggerAutoSkipHeli(false)
                    task.wait(0.5)
                end

                FireSyncedShopBatch()

                if shouldSyncHeli then
                    task.wait(0.5)
                    TriggerAutoSkipHeli(true)
                end

                if not WaitWhileEnabled(GetSyncedShopPostDelay(), IsAnySyncedShopEnabled) then break end
            end

            autoSyncedShopRunning = false
        end)
    end

    -- ====================== SHOP HOURLY SYSTEM ======================
    Main5:Section({ Title = "Shop Hourly", Icon = "clock" })

    local ShopHourlyFixedItems = {
        "LuckPotionI",
        "LuckPotionII",
        "LuckPotionIII",
        "S-Ember",
        "BSX2:30",
        "BSX2:60",
        "BSX2:360",
        "FlashDrive#1",
        "FlashDrive#2",
        "FlashDrive#3",
        "FlashDrive#4",
        "FlashDrive#5",
        "FlashDrive#6",
        "MasterCard:Normal",
        "MasterCard:NormalTitan",
        "MasterCard:SpecialTitan",
    }

    local function GetShopHourlyItems()
        local results = {}
        for _, itemName in ipairs(ShopHourlyFixedItems) do
            table.insert(results, itemName)
        end
        return results
    end

    local ShopHourlyAllowed = {}
    for _, itemName in ipairs(ShopHourlyFixedItems) do
        ShopHourlyAllowed[itemName] = true
    end

    local function SanitizeShopHourlySelection(values, fallback)
        local clean = {}
        local seen = {}

        for _, itemName in ipairs(EnsureList(values, fallback or {})) do
            itemName = tostring(itemName or "")
            if ShopHourlyAllowed[itemName] and not seen[itemName] then
                seen[itemName] = true
                table.insert(clean, itemName)
            end
        end

        if #clean == 0 and type(fallback) == "table" then
            for _, itemName in ipairs(fallback) do
                itemName = tostring(itemName or "")
                if ShopHourlyAllowed[itemName] and not seen[itemName] then
                    seen[itemName] = true
                    table.insert(clean, itemName)
                    break
                end
            end
        end

        return clean
    end

    local shopHourlyValues          = GetShopHourlyItems()
    local selectedShopHourlyItems   = SanitizeShopHourlySelection(Config:Get("SelectedShopHourlyItems", { shopHourlyValues[1] }), { shopHourlyValues[1] })
    local shopHourlyItemAmount      = Config:Get("ShopHourlyItemAmount", 1)
    local buyItemHourlyEnabled      = Config:Get("BuyItemHourlyEnabled", false)
    local buyItemHourlyRunning      = false

    local function IsBuyItemHourlyEnabled()
        return buyItemHourlyEnabled
    end

    local function FireShopHourlyBatch()
        local amount = tonumber(shopHourlyItemAmount) or 1
        amount = math.max(1, math.floor(amount))

        for _, itemName in ipairs(selectedShopHourlyItems or {}) do
            if itemName and itemName ~= "" then
                FireShopRemote("BuyItemFromShopHourly", itemName, amount)
                task.wait(0.35)
            end
        end
    end

    local function StartBuyItemHourlyLoop()
        if buyItemHourlyRunning then return end
        buyItemHourlyRunning = true

        task.spawn(function()
            local firstCycle = true

            while buyItemHourlyEnabled do
                if not firstCycle then
                    if not WaitWhileEnabled(30, IsBuyItemHourlyEnabled) then break end
                end
                firstCycle = false

                FireShopHourlyBatch()

                if not WaitWhileEnabled(10, IsBuyItemHourlyEnabled) then break end
            end

            buyItemHourlyRunning = false
        end)
    end

    Main5:Dropdown({
        Title = "Select Shop Hourly",
        Desc = "Selects fixed hourly shop items.",
        Values = shopHourlyValues,
        Multi = true,
        Value = selectedShopHourlyItems,
        Callback = function(values)
            selectedShopHourlyItems = SanitizeShopHourlySelection(values or {}, {})
            Config:Set("SelectedShopHourlyItems", selectedShopHourlyItems)
            Config:Save()
        end
    })

    Main5:Slider({
        Title = "Item Amount",
        Desc = "Sets how many of each selected hourly item to buy.",
        Value = { Min = 1, Max = 100, Default = shopHourlyItemAmount },
        Step = 1,
        Callback = function(value)
            shopHourlyItemAmount = value
            Config:Set("ShopHourlyItemAmount", value)
            Config:Save()
        end
    })

    Main5:Toggle({
        Title = "Buy Item",
        Desc = "Automatically buys selected hourly shop items on a timed loop.",
        Value = buyItemHourlyEnabled,
        Callback = function(enabled)
            buyItemHourlyEnabled = enabled
            Config:Set("BuyItemHourlyEnabled", enabled)
            Config:Save()
            if enabled then StartBuyItemHourlyLoop() end
        end
    })

    if autoGachaCharacterEnabled then StartAutoGachaCharacter() end
    if autoGachaSkinEnabled then StartAutoGachaSkin() end
    if autoUseItemEnabled then StartAutoUseItem() end
    if IsAnySyncedShopEnabled() then StartAutoSyncedShopLoop() end
    if buyItemHourlyEnabled then StartBuyItemHourlyLoop() end
end
_G.__DYHUB_ShopSystems()
_G.__DYHUB_ShopSystems = nil

-- ====================== UI: COLLECT TAB ======================
Main6:Section({ Title = "Collect Item", Icon = "package" })

AutoCollectToggle = Main6:Toggle({
    Title = "Auto Collect", Value = AutoCollectEnabled,
    Desc = "Automatically collects selected items that appear in the map.",
    Callback = function(state)
        AutoCollectEnabled = state; Config:Set("AutoCollectEnabled", state); Config:Save()
        if state then
            KnownCollectItems = {}
            CollectCandidateCache = {}
            CollectCacheDirty = true
            CheckFarmAstroCollectMode()
            StartAutoCollectLoop()
        else
            CollectRunning = false
            FarmCollecting = false
        end
    end
})

Main6:Section({ Title = "Collect Settings", Icon = "settings" })

CollectItemDropdown = Main6:Dropdown({
    Title = "Item Collect",
    Desc = "Selects which collectible items Auto Collect will target.",
    Values = CollectItems, Multi = true, Value = SelectedCollectItems,
    Callback = function(values)
        SelectedCollectItems = values or {}
        CollectCandidateCache = {}
        CollectCacheDirty = true
        KnownCollectItems = {}
        Config:Set("SelectedCollectItems", SelectedCollectItems)
        Config:Save()
    end
})

CollectModeDropdown = Main6:Dropdown({
    Title = "Mode Collect",
    Desc = "Selects when Auto Collect should collect items.",
    Values = { "Clean", "IDGF" }, Multi = false, Value = CollectMode,
    Callback = function(value)
        CollectMode = value
        Config:Set("CollectMode", value)
        Config:Save()
        CheckFarmAstroCollectMode()
    end
})

CollectMovementDropdown = Main6:Dropdown({
    Title = "Movement Collect",
    Desc = "Selects how your character moves to collectible items.",
    Values = { "Teleport", "Tween" },
    Multi = false,
    Value = CollectMovementMode,
    Callback = function(value)
        CollectMovementMode = NormalizeCollectMovement(value)
        Config:Set("CollectMovementMode", CollectMovementMode)
        Config:Save()
        WindUI:Notify({ Title = "Movement Collect", Content = "Selected: " .. tostring(CollectMovementMode), Duration = 2, Icon = "move" })
    end
})

-- ====================== UI: SETTING TAB ======================
Main3:Section({ Title = "Save Config", Icon = "save" })

Main3:Button({
    Title = "Save Config (NOW)",
    Desc = "Saves all current settings to config file immediately.",
    Callback = function()
        Config:Save()
        WindUI:Notify({ Title = "Config Saved", Content = "Config saved successfully!", Duration = 2, Icon = "save" })
    end
})

AutoSaveEnabled = Config:Get("AutoSaveEnabled", true)
AutoSaveDelay   = Config:Get("AutoSaveDelay", 15)
AutoSaveThread  = nil

function RestartAutoSave()
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
    Title = "Auto Save Config", Value = AutoSaveEnabled,
    Desc = "Automatically saves your config at the set interval.",
    Callback = function(state) AutoSaveEnabled = state; Config:Set("AutoSaveEnabled", state); Config:Save(); RestartAutoSave() end
})

Main3:Input({
    Title = "Delay Save Config",
    Desc = "Sets the auto-save interval in seconds.",
    Default = tostring(AutoSaveDelay), Placeholder = "Default: 15",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 then AutoSaveDelay = num; Config:Set("AutoSaveDelay", num); Config:Save(); RestartAutoSave()
        else warn("[DYHUB] Invalid delay value!") end
    end
})

RestartAutoSave()

Main3:Section({ Title = "Server Status", Icon = "server" })

Main3:Button({
    Title = "Serverhop",
    Desc = "Teleports you to a different random server of this game.",
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
    Desc = "Rejoins the current game server.",
    Callback = function()
        WindUI:Notify({ Title = "Rejoin", Content = "Rejoining server...", Duration = 2, Icon = "refresh-cw" })
        task.wait(1)
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

Main3:Section({ Title = "Miscellaneous", Icon = "settings" })

CameraDropdown = Main3:Dropdown({
    Title = "Camera Mode",
    Desc = "Select how the camera should follow your character.",
    Values = { "Classic", "Manual" },
    Multi = false,
    Value = NormalizeCameraMode(CameraMode),
    Callback = function(value)
        CameraMode = NormalizeCameraMode(value)
        Config:Set("CameraMode", CameraMode)
        Config:Save()
        ApplyCameraMode(true)
        WindUI:Notify({ Title = "Camera Mode", Content = "Selected: " .. tostring(CameraMode), Duration = 2, Icon = "camera" })
    end
})

NoBarrierToggle = Main3:Toggle({
    Title = "Bypass Barrier (PATCHED)", Value = noBarrierActive,
    Desc = "Attempts to bypass invisible barriers.",
    Callback = function(value)
        noBarrierActive = value; Config:Set("NoBarrier", value); Config:Save()
        if value then startNoBarrier() else stopNoBarrier() end
    end
})

CombatDebugToggle = Main3:Toggle({
    Title = "Combat Debug",
    Value = CombatDebugEnabled,
    Desc = "Prints cooldown-based Auto Attack/Skill and mob-cache debug logs.",
    Callback = function(value)
        CombatDebugEnabled = value
        Config:Set("CombatDebugEnabled", value)
        Config:Save()
        if value then
            WindUI:Notify({ Title = "Combat Debug", Content = "Combat debug logs enabled.", Duration = 2, Icon = "bug" })
        else
            WindUI:Notify({ Title = "Combat Debug", Content = "Combat debug logs disabled.", Duration = 2, Icon = "square" })
        end
    end
})

AntiAFKConnection = nil
AntiAFKThread = nil
AntiAFKDisabledConnections = false

function StartAntiAFK()
    AntiAFK = true

    -- Priority method: disable/disconnect Roblox idle connections if the executor supports getconnections.
    if getconnections and not AntiAFKDisabledConnections then
        pcall(function()
            for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
                if connection.Disable then
                    connection:Disable()
                elseif connection.Disconnect then
                    connection:Disconnect()
                end
            end
        end)
        AntiAFKDisabledConnections = true
    end

    -- Fallback method: simulate input when Roblox fires Idled.
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end

    AntiAFKConnection = LocalPlayer.Idled:Connect(function()
        if not AntiAFK then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)

    -- Backup pulse for executors/games where Idled does not fire reliably.
    if AntiAFKThread then
        pcall(function() task.cancel(AntiAFKThread) end)
        AntiAFKThread = nil
    end

    AntiAFKThread = task.spawn(function()
        while AntiAFK do
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            task.wait(60)
        end
        AntiAFKThread = nil
    end)
end

function StopAntiAFK()
    AntiAFK = false

    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end

    if AntiAFKThread then
        pcall(function() task.cancel(AntiAFKThread) end)
        AntiAFKThread = nil
    end
end

antiafk = Main3:Toggle({
    Title = "Anti AFK", Value = AntiAFK,
    Desc = "Prevents Roblox from kicking you for being idle.",
    Callback = function(enabled)
        AntiAFK = enabled
        Config:Set("AntiAfk", enabled)
        Config:Save()
        if enabled then
            StartAntiAFK()
            WindUI:Notify({ Title = "Anti AFK", Content = "Anti idle is enabled.", Duration = 2, Icon = "shield-check" })
        else
            StopAntiAFK()
            WindUI:Notify({ Title = "Anti AFK", Content = "Anti idle is disabled.", Duration = 2, Icon = "square" })
        end
    end
})

if AntiAFK then StartAntiAFK() end

-- ====================== APPLY SAVED CONFIG ON LOAD ======================
function ApplySavedConfigOnStartup()
    task.wait(1)
    updatePlayerStats()
    ApplyCameraMode(true)
    UpdateDYHUBWaitingPartCollision()
    if FullBrightEnabled then ApplyFullBright() end
    if NoFogEnabled then ApplyNoFog() end
    if FlyEnabled then StartFly() end

    if FarmAstroTokenEnabled and AutoFarmEnabled then
        FarmAstroTokenEnabled = false
        Config:Set("FarmAstroTokenEnabled", false)
        Config:Save()
        NotifyFarmAstroAutoFarm()
    end

    if AutoFarmEnabled then
        StartFarmLoop()
        StartJeffreyGuardLoop()
    end

    if FarmAstroTokenEnabled then
        StartFarmAstroToken()
    end

    -- Apply MiscOptions even when Auto Farm is off, so Sync Farm Only OFF works immediately.
    HandleMiscOptions(MiscOptions)

    if noBarrierActive then startNoBarrier() end

    if ESP.Enabled then
        StartESPLoop()
    end

    if AutoCollectEnabled then
        KnownCollectItems = {}
        CollectCandidateCache = {}
        CollectCacheDirty = true
        StartAutoCollectLoop()
    end

    if AutoStartEnabled and IsMiscFarmAllowed() then
        SetupAutoStartOnly(true)
    elseif AutoStartEnabled then
        StopAutoStart()
    end
end

ApplySavedConfigOnStartup()

print("[DYHUB] Version: " .. version .. " | Changelog: " .. ver .. " loaded successfully!")
print("[DYHUB] Config system active | Auto saving every " .. tostring(AutoSaveDelay) .. " seconds")
