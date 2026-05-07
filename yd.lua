-- v023.6
-- =========================
local version = "Rework"
local ver     = "v023.7"
-- =========================

-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ====================== GameLoad ======================
repeat task.wait() until game:IsLoaded()

-- ====================== LoadingGui ======================
local p  = game:GetService("Players").LocalPlayer
local pg = p:WaitForChild("PlayerGui")

local function waitLoadingGone()
    local gui = pg:FindFirstChild("LoadingGui")
    if gui then
        WindUI:Notify({ Title = "Initialization", Content = "Game is loading, Please wait.", Duration = 3, Icon = "download" })
        gui.AncestryChanged:Wait()
    end
end
waitLoadingGone()

WindUI:Notify({ Title = "Initialization", Content = "Load complete, Starting in 3s.", Duration = 3, Icon = "shield-check" })
task.wait(3)

-- ====================== FPS UNLOCK ======================
local fpspart = Instance.new("Part")
fpspart.Size = Vector3.new(10, 1, 10)
fpspart.Position = Vector3.new(-23.3435822, 61, 0.341766357)
fpspart.Transparency = 1
fpspart.Anchored = true
fpspart.CanCollide = true
fpspart.Material = Enum.Material.Neon
fpspart.BrickColor = BrickColor.new("Bright blue")
fpspart.Name = "DYHUB_WAITING_PART"
fpspart.Parent = workspace

if setfpscap then
    setfpscap(1000000)
    WindUI:Notify({ Title = "Service", Content = "FPS Unlocked! | " .. ver, Duration = 3, Icon = "cpu" })
else
    WindUI:Notify({ Title = "Not Working", Content = "Your exploit does not support setfpscap.", Duration = 3, Icon = "ban" })
end

-- ====================== SERVICES ======================
local HttpService         = game:GetService("HttpService")
local TweenService        = game:GetService("TweenService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService          = game:GetService("RunService")
local Players             = game:GetService("Players")
local TeleportService     = game:GetService("TeleportService")
local VirtualUser         = game:GetService("VirtualUser")
local StatsService        = game:GetService("Stats")

-- ====================== CUSTOM CONFIG SYSTEM ======================
local ConfigFolder = "DYHUB_REWORK_V2_STBB"

local CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self = setmetatable({}, CustomConfig)
    self.ConfigData = {}
    self.ConfigPath = ConfigFolder .. "/config.json"
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    self:Load()
    return self
end

function CustomConfig:Set(key, value) self.ConfigData[key] = value end

function CustomConfig:Get(key, default)
    if self.ConfigData[key] ~= nil then return self.ConfigData[key] end
    return default
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

local Config = CustomConfig.new()

-- ====================== VERSION CHECK ======================
local FreeVersion    = "Free Version"
local PremiumVersion = "Premium Version"
local ExtraVersion   = "Extra Version"

local function getData(url)
    local ok, resp = pcall(function() return game:HttpGet(url) end)
    if not ok then return nil end
    local fn = loadstring(resp)
    if fn then return fn() end
    return nil
end

local function checkVersion(playerName)
    local extraData = getData("https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/STBBList.lua")
    if extraData and extraData[playerName] then return ExtraVersion end
    local premiumData = getData("https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua")
    if premiumData and premiumData[playerName] then return PremiumVersion end
    return FreeVersion
end

local LocalPlayer  = Players.LocalPlayer
local userversion  = checkVersion(LocalPlayer.Name)

-- ====================== WINDOW ======================
local Window = WindUI:CreateWindow({
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
local Info   = Window:Tab({ Title = "Information", Icon = "info" })
Window:Divider()
local Main   = Window:Tab({ Title = "Main",        Icon = "rocket" })
local Main4  = Window:Tab({ Title = "Esp",         Icon = "eye" })
local Main2  = Window:Tab({ Title = "Player",      Icon = "user" })
Window:Divider()
local Main5  = Window:Tab({ Title = "Shop",        Icon = "shopping-cart" })
local Main6  = Window:Tab({ Title = "Collect",     Icon = "hand" })
local Main7  = Window:Tab({ Title = "Gamemode",    Icon = "gamepad-2" })
Window:Divider()
local Main3  = Window:Tab({ Title = "Setting",     Icon = "settings" })
Window:SelectTab(1)

-- ======================== INFO TAB ========================
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

Info:Section({ Title = "Lasted Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({
    Title = "Update: 07/05/2026 | " .. ver,
    Desc =  "- [ Fix ] AutoBuy duplicate thread (Auto Start on Load)\n"
         .. "- [ Fix ] StartWatchdog() ไม่ถูกเรียก — fixed call order\n"
         .. "- [ Fix ] FarmLog_Push ถูก define หลัง call — reorganized\n"
         .. "- [ New ] Notification Throttle — ป้องกัน notify spam\n"
         .. "- [ New ] Smart Rejoin — นับ error → rejoin อัตโนมัติ\n"
         .. "- [ New ] Discord Webhook Logger — ส่ง stats ไป Discord\n"
         .. "- [ New ] Skill Cooldown Rotation — track cooldown จริงๆ\n"
         .. "- [ New ] Death Recovery — restart farm หลัง die อัตโนมัติ\n"
         .. "- [ New ] Farm Log Panel real-time ใน Main tab\n"
         .. "- [ New ] Server Stats Panel auto-refresh ใน Setting tab\n"
         .. "- [ Improve ] Memory Cleanup + Watchdog ครบทุกจุด",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})
Info:Divider()
Info:Section({ Title = "Discord Information", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()

ui.Creator.Request = function(requestData)
    local ok, result = pcall(function()
        if HttpService.RequestAsync then
            local resp = HttpService:RequestAsync({ Url = requestData.Url, Method = requestData.Method or "GET", Headers = requestData.Headers or {} })
            return { Body = resp.Body, StatusCode = resp.StatusCode, Success = resp.Success }
        else
            local body = HttpService:GetAsync(requestData.Url)
            return { Body = body, StatusCode = 200, Success = true }
        end
    end)
    if ok then return result else error("HTTP Request failed: " .. tostring(result)) end
end

local InviteCode = "jWNDPNMmyB"
local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local function LoadDiscordInfo()
    local ok, result = pcall(function()
        local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
        if not httpRequest then return nil end
        local resp = httpRequest({ Url = DiscordAPI, Method = "GET", Headers = { ["User-Agent"] = "RobloxBot/1.0", ["Accept"] = "application/json" } })
        if resp and resp.Body then return HttpService:JSONDecode(resp.Body) end
        return nil
    end)
    if ok and result and result.guild then
        local DiscordInfo = Info:Paragraph({
            Title = result.guild.name,
            Desc  = ' <font color="#52525b">●</font> Member Count : ' .. tostring(result.approximate_member_count)
                 .. '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(result.approximate_presence_count),
            Image = "https://cdn.discordapp.com/icons/" .. result.guild.id .. "/" .. result.guild.icon .. ".png?size=1024",
            ImageSize = 42,
        })
        Info:Button({
            Title = "Update Info",
            Callback = function()
                local ok2, r2 = pcall(function()
                    local hr = (syn and syn.request) or (http and http.request) or http_request or request
                    if not hr then return nil end
                    local resp2 = hr({ Url = DiscordAPI, Method = "GET" })
                    if resp2 and resp2.Body then return HttpService:JSONDecode(resp2.Body) end
                    return nil
                end)
                if ok2 and r2 and r2.guild then
                    DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : ' .. tostring(r2.approximate_member_count)
                                     .. '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(r2.approximate_presence_count))
                    WindUI:Notify({ Title = "Discord Info Updated", Content = "Successfully refreshed.", Duration = 2, Icon = "refresh-cw" })
                else
                    WindUI:Notify({ Title = "Update Failed", Content = "Could not refresh Discord info.", Duration = 3, Icon = "alert-triangle" })
                end
            end
        })
        Info:Button({
            Title = "Copy Discord Invite",
            Callback = function()
                setclipboard("https://discord.gg/" .. InviteCode)
                WindUI:Notify({ Title = "Copied!", Content = "Discord invite copied to clipboard.", Duration = 2, Icon = "clipboard-check" })
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
    Title = "Social", Desc = "Copy link social media for follow!",
    Image = "rbxassetid://104487529937663", ImageSize = 30,
    Buttons = { { Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://guns.lol/DYHUB") end } }
})
Info:Paragraph({
    Title = "Discord", Desc = "Join our discord for more scripts!",
    Image = "rbxassetid://104487529937663", ImageSize = 30,
    Buttons = { { Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://discord.gg/jWNDPNMmyB") end } }
})

-- ============================================================
-- ====================== PLAYER / CHARACTER ==================
-- ============================================================
local Client         = LocalPlayer
local Character      = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ====================== GLOBAL TABLES ======================
GlobalTables = {
    redeemCodes = { "100MVisit2", "100MVisit1", "CamArmada", "CCTVBase", "ADelayedGameIsEventuallyGoodButRushedGameIsForeverBad" },
    Mode  = { "Normal Mode","Vague Memory","Extreme Mode","Hard Mode","Insane Mode","Nightmare Mode","Boss Rush","Dark Dimension","Hell","Mist","Christmas Act 1","Zombie Act 1","Holdout","Invasion" },
    Votes = { "Normal","VeryHard","Hard","Insane","Nightmare","BossRush","DarkDimension","Hell","ThunderStorm","Christmas","Zombie","AstroV2","Astro","100MVisit" },
    Weapon   = { "Stungun","Flamethrower","Harpoon Gun","Shot Gun","Pulse Rifle","Shot Harpoon Gun","EPD","Small Laser Gun" },
    MiscShop = { "HeadPhone","Titan-Request","SpecialTitan-Request","Speaker-Request","Grenade","Jetpack","Lens" },
}

-- ====================== CONFIG VARIABLES ======================
local skillList          = { "Q","E","R","T","Y","G","H","Z","X","C","V","B","U" }
local skillDropdownValues = { "All","Q","E","R","T","Y","G","H","Z","X","C","V","B","U" }

-- ====================== STATE VARIABLES ======================
local AutoFarmEnabled      = Config:Get("AutoFarmEnabled", false)
local FarmPosition         = Config:Get("FarmPosition", "Above")
local FarmMode             = Config:Get("FarmMode", "Tween")
local MiscOptions          = Config:Get("MiscOptions", {})
local AutoAttackEnabled    = false
local AutoSkillEnabled     = false
local AutoSkipHeliEnabled  = false
local DeleteMapEnabled     = false
local AutoStartEnabled     = false
local AutoFillUpEnabled    = false
local SelectedSkills       = Config:Get("SelectedSkills", { "All" })
local SafeModeEnabled      = false
local SafeValue            = Config:Get("SafeValue", 30)
local WaitingRespawn       = false
local IdlePosition         = CFrame.new(-23.3435822, 67, 0.341766357)
local SkillDelay           = Config:Get("SkillDelay", 1)
local LoopDelay            = 0.5
local TweenSpeed           = 1
local HeightValue          = Config:Get("HeightValue", 3)
local NeedNoClip           = false
local LockActive           = false
local FarmInterrupt        = false
local FarmLoopRunning      = false
local AutoStartConnection  = nil
local noBarrierConnection  = nil
local noBarrierActive      = Config:Get("NoBarrier", false)

-- AntiAFK
local hi1             = Config:Get("antiafk_enabled", true)
local AntiAFKConnection = nil

-- AutoBuy thread handles  [FIX v023.6] — ใช้ handle เดียว ป้องกัน duplicate
local AutoBuyWeaponThread = nil
local AutoBuyMiscThread   = nil

-- ====================== NOTIFICATION THROTTLE ======================
-- [NEW v023.6] ป้องกัน notify spam — throttle ต่อ key
local _notifyLastTime = {}
local _notifyThrottleSec = 8  -- วินาที minimum ระหว่าง notify เดียวกัน

local function Notify(title, content, duration, icon, key)
    local k = key or title
    local now = tick()
    if _notifyLastTime[k] and (now - _notifyLastTime[k]) < _notifyThrottleSec then return end
    _notifyLastTime[k] = now
    WindUI:Notify({ Title = title, Content = content, Duration = duration or 3, Icon = icon or "info" })
end

-- ====================== FARM LOG SYSTEM ======================
-- [FIX v023.6] define ก่อน StartFarmLoop ทุกอย่าง
local FarmLog = {
    Lines    = {},
    MaxLines = 24,
    Panel    = nil,
}

local _FarmLogIcons = {
    Info    = "»", Success = "✔", Error = "✘", Warn = "⚠",
    Kill    = "☠", Wave    = "〜", Sys = "◈", Target = "⊕",
    HP      = "♥", Dist    = "⇢",
}

local function FarmLog_Push(msg, kind)
    local icon = _FarmLogIcons[kind] or _FarmLogIcons.Info
    local s  = math.floor(tick() % 86400)
    local ts = string.format("%02d:%02d:%02d", math.floor(s/3600), math.floor((s%3600)/60), s%60)
    local line = string.format("[%s] %s %s", ts, icon, msg)
    table.insert(FarmLog.Lines, 1, line)
    if #FarmLog.Lines > FarmLog.MaxLines then table.remove(FarmLog.Lines) end
    if FarmLog.Panel then
        pcall(function()
            FarmLog.Panel:Set({ Title = "[ Farm Log ]  ·  " .. ver, Content = table.concat(FarmLog.Lines, "\n") })
        end)
    end
end

local function FarmLog_Clear()
    FarmLog.Lines = {}
    if FarmLog.Panel then
        pcall(function()
            FarmLog.Panel:Set({ Title = "[ Farm Log ]  ·  " .. ver, Content = "— Log cleared —" })
        end)
    end
end

-- ====================== FARM STATS SYSTEM ======================
local FarmStats = {
    SessionStart   = tick(),
    KillCount      = 0,
    InterruptCount = 0,
    WaveCount      = 0,
    LastKillTime   = tick(),
    DeathCount     = 0,
    RejoinCount    = 0,
    KPMHistory     = {},  -- { time, kpm } สำหรับ graph
}

local function FarmStats_Reset()
    FarmStats.SessionStart   = tick()
    FarmStats.KillCount      = 0
    FarmStats.InterruptCount = 0
    FarmStats.WaveCount      = 0
    FarmStats.LastKillTime   = tick()
    FarmStats.DeathCount     = 0
    FarmStats.KPMHistory     = {}
end

local function FarmStats_GetUptime()
    local s = math.floor(tick() - FarmStats.SessionStart)
    return string.format("%02d:%02d:%02d", math.floor(s/3600), math.floor((s%3600)/60), s%60)
end

local function FarmStats_GetKPM()
    local elapsed = math.max(1, tick() - FarmStats.SessionStart)
    return string.format("%.2f", (FarmStats.KillCount / elapsed) * 60)
end

-- ====================== WATCHDOG SYSTEM ======================
local WatchdogEnabled  = Config:Get("WatchdogEnabled", true)
local WatchdogLastBeat = tick()
local WatchdogThread   = nil
local WATCHDOG_TIMEOUT = 30

local function WatchdogHeartbeat()
    WatchdogLastBeat = tick()
end

-- forward declare — define ด้านล่าง
local StartFarmLoop
local HandleMiscOptions

-- ====================== SMART REJOIN SYSTEM ======================
-- [NEW v023.6] นับ error loop → rejoin อัตโนมัติ
local AutoRejoinEnabled   = Config:Get("AutoRejoinEnabled", false)
local SmartRejoinEnabled  = Config:Get("SmartRejoinEnabled", false)
local SmartRejoinMax      = Config:Get("SmartRejoinMax", 5)
local _rejoinErrorCount   = 0
local _rejoinLastTime     = 0
local REJOIN_COOLDOWN     = 60  -- วินาที

local function SmartRejoin_ResetCount()
    _rejoinErrorCount = 0
end

local function SmartRejoin_Trigger(reason)
    if not SmartRejoinEnabled then return end
    local now = tick()
    if (now - _rejoinLastTime) < REJOIN_COOLDOWN then return end
    _rejoinErrorCount = _rejoinErrorCount + 1
    FarmLog_Push(string.format("⚠ SmartRejoin: error #%d/%d (%s)", _rejoinErrorCount, SmartRejoinMax, reason), "Warn")
    if _rejoinErrorCount >= SmartRejoinMax then
        FarmStats.RejoinCount = FarmStats.RejoinCount + 1
        _rejoinLastTime = now
        _rejoinErrorCount = 0
        FarmLog_Push("✘ SmartRejoin: Max errors reached — Rejoining server...", "Error")
        Notify("SmartRejoin", "Max errors reached — Rejoining!", 4, "refresh-cw", "smartrejoin")
        task.wait(2)
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end
end

local function SetupAutoRejoin()
    LocalPlayer.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Failed and AutoRejoinEnabled then
            warn("[DYHUB] Teleport failed, retrying rejoin...")
            FarmLog_Push("⚠ Teleport failed — retrying rejoin...", "Warn")
            task.wait(3)
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end
    end)
end

-- ====================== DISCORD WEBHOOK LOGGER ======================
-- [NEW v023.6]
local WebhookEnabled    = Config:Get("WebhookEnabled", false)
local WebhookURL        = Config:Get("WebhookURL", "")
local WebhookInterval   = Config:Get("WebhookInterval", 30)  -- นาที
local WebhookThread     = nil

local function SendWebhookLog()
    if not WebhookEnabled or WebhookURL == "" then return end
    pcall(function()
        local hp, maxHp = 100, 100
        if Character and Character:FindFirstChild("Humanoid") then
            hp = math.floor(Character.Humanoid.Health)
            maxHp = math.floor(Character.Humanoid.MaxHealth)
        end
        local payload = HttpService:JSONEncode({
            embeds = {{
                title       = "DYHUB Farm Report | " .. ver,
                color       = 0xdb7093,
                description = string.format(
                    "**Player:** %s\n**Uptime:** %s\n**Kills:** %d\n**KPM:** %s\n**Waves:** %d\n**Deaths:** %d\n**Rejoins:** %d\n**HP:** %d/%d",
                    LocalPlayer.Name,
                    FarmStats_GetUptime(),
                    FarmStats.KillCount,
                    FarmStats_GetKPM(),
                    FarmStats.WaveCount,
                    FarmStats.DeathCount,
                    FarmStats.RejoinCount,
                    hp, maxHp
                ),
                footer = { text = "DYHUB Auto Farm Logger" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        })
        local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
        if httpRequest then
            httpRequest({ Url = WebhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = payload })
        end
    end)
end

local function StartWebhookLoop()
    if WebhookThread then task.cancel(WebhookThread); WebhookThread = nil end
    if not WebhookEnabled or WebhookURL == "" then return end
    WebhookThread = task.spawn(function()
        while WebhookEnabled do
            task.wait(WebhookInterval * 60)
            if WebhookEnabled then
                SendWebhookLog()
                FarmLog_Push(string.format("◈ Webhook: Stats sent to Discord (%s)", os.date("%H:%M")), "Sys")
            end
        end
        WebhookThread = nil
    end)
end

-- ====================== FILL UP CONFIG ======================
local FILLUP_PART_PATH    = { "HelicopterShop", "ShopXDD", "PartForShop" }
local FILLUP_TARGET_POS   = Vector3.new(44.2756729, 26.3595276, -32.7318268)
local FILLUP_POS_THRESHOLD = 0.5
local FillUpRunning       = false

local function GetFillUpPart()
    local obj = workspace
    for _, key in ipairs(FILLUP_PART_PATH) do
        obj = obj:FindFirstChild(key)
        if not obj then return nil end
    end
    return obj
end

local function IsFillUpPartReady()
    local fp = GetFillUpPart()
    if not fp then return false end
    return (fp.CFrame.Position - FILLUP_TARGET_POS).Magnitude < FILLUP_POS_THRESHOLD
end

-- ====================== ALLY SYSTEM ======================
local AllyNames = {
    ["Heavy Soldier Toilet V2"] = true, ["Quad Laser Toilet"]     = true,
    ["Strider Rocket Laser"]    = true, ["Helicopter Camera"]     = true,
    ["Heavy Soldier Toilet V1"] = true, ["Rocket Heli v2"]        = true,
    ["Gunner Camera man"]       = true, ["Attack Helicopter"]     = true,
    ["Swat Mutant"]             = true, ["Huge DJ Toilet"]        = true,
}
local function IsAlly(mob) return AllyNames[mob.Name] ~= nil end

-- ====================== TP SYSTEM ======================
function tp(pu79)
    pcall(function()
        local v80 = Client
        if v80 then v80 = Client.Character end
        if v80:FindFirstChild("Humanoid") and v80.Humanoid.Sit then v80.Humanoid.Sit = false end
        NeedNoClip = true
        local v81 = { Target = pu79.Target, Mod = pu79.Mod or CFrame.new(0,0,0) }
        v80:FindFirstChild("HumanoidRootPart").CFrame = v81.Target * v81.Mod
    end)
end

function Tp(p82)
    if Client.Character.Humanoid.Sit then Client.Character.Humanoid.Sit = false end
    for _, v86 in pairs(Client.Character:GetDescendants()) do
        if v86:IsA("BasePart") then v86.CanCollide = false end
    end
    if not Client.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
        local bv = Instance.new("BodyVelocity")
        bv.Parent = Client.Character.HumanoidRootPart; bv.Name = "BodyClip"
        bv.Velocity = Vector3.new(0,0,0); bv.MaxForce = Vector3.new(5, math.huge, 5)
    end
    Client.Character.HumanoidRootPart.CFrame = p82
end

function tp1(p89)
    local v90 = LocalPlayer
    if v90 and v90.Character and v90.Character:FindFirstChild("HumanoidRootPart") then
        v90.Character.HumanoidRootPart.CFrame = p89
    end
end

-- ====================== UTILITY FUNCTIONS ======================
local function IsValidMob(obj)
    if not obj:IsA("Model") then return false end
    if not obj:FindFirstChild("Humanoid") or not obj:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(obj) then return false end
    if IsAlly(obj) then return false end
    local h = obj:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function IsMobDead(mob)
    if not mob or not mob.Parent then return true end
    local h = mob:FindFirstChild("Humanoid")
    return not h or h.Health <= 0
end

local function GetMobSize(mob)
    local mr = mob:FindFirstChild("HumanoidRootPart")
    if not mr then return 4 end
    local _, size = mob:GetBoundingBox()
    return size.Y
end

-- ====================== PLAYER HP HELPERS ======================
local function GetPlayerHPInfo()
    local h = Character and Character:FindFirstChild("Humanoid")
    if not h then return 100, 100 end
    return h.Health, h.MaxHealth
end

local function IsPlayerHPFull()
    local hp, maxHp = GetPlayerHPInfo()
    if maxHp <= 0 then return true end
    return hp >= maxHp
end

local function GetPlayerHealthPercent()
    local hp, maxHp = GetPlayerHPInfo()
    if maxHp <= 0 then return 100 end
    return (hp / maxHp) * 100
end

-- ====================== MOB SELECTION ======================
local function GetNearestMob()
    local nearestMob, nearestDist = nil, math.huge
    local living = workspace:FindFirstChild("Living")
    if not living then return nil end
    for _, mob in ipairs(living:GetChildren()) do
        if IsValidMob(mob) then
            local mr = mob:FindFirstChild("HumanoidRootPart")
            if mr and HumanoidRootPart then
                local d = (HumanoidRootPart.Position - mr.Position).Magnitude
                if d < nearestDist then nearestDist = d; nearestMob = mob end
            end
        end
    end
    return nearestMob
end

local function GetHighestHPMob()
    local bestMob, bestHP = nil, -math.huge
    local living = workspace:FindFirstChild("Living")
    if not living then return nil end
    for _, mob in ipairs(living:GetChildren()) do
        if IsValidMob(mob) then
            local h = mob:FindFirstChild("Humanoid")
            if h and h.MaxHealth > bestHP then bestHP = h.MaxHealth; bestMob = mob end
        end
    end
    return bestMob
end

local function GetHelicopter()
    local living = workspace:FindFirstChild("Living")
    if not living then return nil end
    for _, obj in ipairs(living:GetChildren()) do
        if obj.Name == "Helicopter" and IsValidMob(obj) then return obj end
    end
    return nil
end

local function GetGiantSTToilet()
    local living = workspace:FindFirstChild("Living")
    if not living then return nil, nil end
    local giant = living:FindFirstChild("Giant ST toilet")
    if giant and IsValidMob(giant) then
        local lever = giant:FindFirstChild("lever")
        if lever then
            local prompt = lever:FindFirstChildOfClass("ProximityPrompt")
            if prompt then return giant, prompt end
        end
    end
    return nil, nil
end

local function GetMobRank(mobType)
    if mobType == "Helicopter" or mobType == "GiantST" then return 0
    elseif mobType == "HighHP"     then return 1
    elseif mobType == "NearestMob" then return 2
    end
    return 99
end

local function GetPriorityMob()
    local heli = GetHelicopter()
    if heli then return heli, "Helicopter" end
    local giant, prompt = GetGiantSTToilet()
    if giant and prompt then return giant, "GiantST", prompt end
    local highHP = GetHighestHPMob()
    if highHP then return highHP, "HighHP" end
    local near = GetNearestMob()
    if near then return near, "NearestMob" end
    return nil, nil
end

-- ====================== MOB VISUAL BOUNDS ======================
local function GetMobVisualBounds(mob)
    local minY, maxY = math.huge, -math.huge
    local centerX, centerZ, count = 0, 0, 0
    for _, part in ipairs(mob:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.9 and part.Size.Y > 0.1 then
            local pos = part.Position
            local hy  = part.Size.Y * 0.5
            if pos.Y - hy < minY then minY = pos.Y - hy end
            if pos.Y + hy > maxY then maxY = pos.Y + hy end
            centerX = centerX + pos.X; centerZ = centerZ + pos.Z; count = count + 1
        end
    end
    if count == 0 then
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp.Position, hrp.Position.Y - 2, hrp.Position.Y + 2 end
        return Vector3.new(0,0,0), 0, 4
    end
    local cx = centerX / count; local cz = centerZ / count
    return Vector3.new(cx, (minY+maxY)*0.5, cz), minY, maxY
end

-- ====================== MOB HEIGHT OVERRIDE ======================
local PADDING_REDUCE_STEP    = Config:Get("PaddingReduceStep", 2)
local PADDING_SAFE_MIN       = Config:Get("PaddingSafeMin", -30)
local PADDING_CHECK_INTERVAL = Config:Get("PaddingCheckInterval", 1)
local DMG_THRESHOLD          = Config:Get("DmgThreshold", 100)
local ANTI_CLIP_MARGIN       = Config:Get("AntiClipMargin", 3)
local PLAYER_HALF_HEIGHT     = 3

local MobHeightOverride   = {}
local MobConfirmedPadding = {}
local MobLastHealth       = {}

local function GetAntiClipFloor(mob, position)
    local _, minY, maxY = GetMobVisualBounds(mob)
    local visualHeight = maxY - minY
    return -(visualHeight) + PLAYER_HALF_HEIGHT + ANTI_CLIP_MARGIN
end

local function GetEffectivePadding(mob)
    if MobConfirmedPadding[mob] ~= nil then return MobConfirmedPadding[mob] end
    if MobHeightOverride[mob]   ~= nil then return MobHeightOverride[mob] end
    return HeightValue
end

local function ClampPaddingToAntiClip(mob, padding)
    local antiFloor = GetAntiClipFloor(mob, FarmPosition)
    return math.max(math.max(padding, antiFloor), PADDING_SAFE_MIN)
end

local function StartDamageChecker(mob)
    task.spawn(function()
        local humanoid = mob and mob:FindFirstChild("Humanoid")
        if not humanoid then return end
        if MobConfirmedPadding[mob] ~= nil then return end
        MobLastHealth[mob]     = humanoid.Health
        MobHeightOverride[mob] = ClampPaddingToAntiClip(mob, MobHeightOverride[mob] or HeightValue)
        local lastDamageTime   = tick()
        local noDamageTimer    = 0
        local hitStreak        = 0
        local lastWasHit       = false
        local reducedOnce      = false
        while mob and mob.Parent and not IsMobDead(mob) and AutoFarmEnabled do
            task.wait(0.3)
            if not mob or not mob.Parent or IsMobDead(mob) then break end
            humanoid = mob:FindFirstChild("Humanoid")
            if not humanoid then break end
            local currentHP = humanoid.Health
            local dmgDealt  = (MobLastHealth[mob] or currentHP) - currentHP
            local gotHit    = dmgDealt > 0
            if gotHit then
                lastDamageTime = tick(); noDamageTimer = 0; reducedOnce = false
                hitStreak = lastWasHit and hitStreak + 1 or 1
                lastWasHit = true
                local curPad = GetEffectivePadding(mob)
                if dmgDealt >= DMG_THRESHOLD and MobConfirmedPadding[mob] == nil then
                    MobConfirmedPadding[mob] = curPad; MobHeightOverride[mob] = curPad; break
                end
                if hitStreak >= 2 and MobConfirmedPadding[mob] == nil then
                    MobConfirmedPadding[mob] = curPad; MobHeightOverride[mob] = curPad; break
                end
            else
                lastWasHit = false; hitStreak = 0
                noDamageTimer = tick() - lastDamageTime
            end
            if noDamageTimer >= 3 and not reducedOnce then
                reducedOnce = true
                local newPad = ClampPaddingToAntiClip(mob, GetEffectivePadding(mob) - PADDING_REDUCE_STEP)
                MobHeightOverride[mob] = newPad
            end
            if noDamageTimer >= 6 then
                lastDamageTime = tick(); reducedOnce = false
                local newPad = ClampPaddingToAntiClip(mob, GetEffectivePadding(mob) - PADDING_REDUCE_STEP)
                MobHeightOverride[mob] = newPad
            end
            MobLastHealth[mob] = currentHP
        end
        MobHeightOverride[mob] = nil; MobLastHealth[mob] = nil
    end)
end

local function ResetMobOverride(mob)
    MobHeightOverride[mob]   = nil
    MobConfirmedPadding[mob] = nil
    MobLastHealth[mob]       = nil
end

-- ====================== TARGET CFRAME ======================
local function GetTargetCFrame(mob, position)
    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return nil end
    local padding = GetEffectivePadding(mob)
    local center, minY, maxY = GetMobVisualBounds(mob)
    if position == "Above" then
        local targetPos = Vector3.new(center.X, maxY + padding, center.Z)
        local lookCF    = CFrame.new(targetPos, Vector3.new(center.X, maxY, center.Z))
        return lookCF * CFrame.Angles(math.rad(-10), 0, 0)
    elseif position == "Under" then
        local targetPos = Vector3.new(center.X, minY - padding, center.Z)
        local lookCF    = CFrame.new(targetPos, Vector3.new(center.X, minY, center.Z))
        return lookCF * CFrame.Angles(math.rad(10), 0, 0)
    end
end

-- ====================== SMART TWEEN SPEED ======================
local TWEEN_SPEED_MIN = 0.15
local TWEEN_SPEED_MAX = 1.5
local TWEEN_DIST_MAX  = 200

local function SmartTweenSpeed(dist)
    if not dist or dist <= 0 then return TWEEN_SPEED_MIN end
    local ratio = math.min(dist / TWEEN_DIST_MAX, 1)
    return TWEEN_SPEED_MIN + ratio * (TWEEN_SPEED_MAX - TWEEN_SPEED_MIN)
end

local function TeleportToMob(mob)
    local cf = GetTargetCFrame(mob, FarmPosition)
    if not cf then return end
    if FarmMode == "Tween" then
        local dist = HumanoidRootPart and (HumanoidRootPart.Position - cf.Position).Magnitude or 10
        local spd  = SmartTweenSpeed(dist)
        local tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(spd, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { CFrame = cf })
        tween:Play(); tween.Completed:Wait()
    elseif FarmMode == "tp"  then tp({ Target = cf, Mod = CFrame.new(0,0,0) })
    elseif FarmMode == "Tp"  then Tp(cf)
    elseif FarmMode == "tp1" then tp1(cf)
    end
end

local function LockToMob(mob)
    LockActive = true
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not AutoFarmEnabled or IsMobDead(mob) or not LockActive or FarmInterrupt then
            conn:Disconnect(); LockActive = false; return
        end
        if not Character or not HumanoidRootPart then return end
        local cf = GetTargetCFrame(mob, FarmPosition)
        if cf then
            Character:PivotTo(cf)
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

-- ====================== AUTO ATTACK & SKILL ======================
local AutoAttackThread = nil
local AutoSkillThread  = nil

-- [NEW v023.6] Skill Cooldown Rotation — track cooldown per-key
local SkillCooldowns    = {}  -- [key] = lastUsedTick
local SkillCooldownSec  = Config:Get("SkillCooldownSec", 0)  -- 0 = ใช้ SkillDelay

local function StartAutoAttack()
    if AutoAttackThread then return end
    AutoAttackThread = task.spawn(function()
        while AutoAttackEnabled and AutoFarmEnabled do
            local mob = GetPriorityMob()
            if mob and not WaitingRespawn then
                pcall(function() ReplicatedStorage.LMB:FireServer() end)
            end
            task.wait(0.05)
        end
        AutoAttackThread = nil
    end)
end

local function StartAutoSkill()
    if AutoSkillThread then return end
    AutoSkillThread = task.spawn(function()
        while AutoSkillEnabled and AutoFarmEnabled do
            local mob = GetPriorityMob()
            if mob and not WaitingRespawn then
                local keysToPress = table.find(SelectedSkills, "All") and skillList or SelectedSkills
                for _, key in ipairs(keysToPress) do
                    if not AutoSkillEnabled or not AutoFarmEnabled then break end
                    local keyCode = Enum.KeyCode[key]
                    if keyCode then
                        -- [NEW] Cooldown rotation per key
                        local cd = SkillCooldownSec > 0 and SkillCooldownSec or SkillDelay
                        local lastUsed = SkillCooldowns[key] or 0
                        if (tick() - lastUsed) >= cd then
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(true,  keyCode, false, game)
                                task.wait(0.05)
                                VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                            end)
                            SkillCooldowns[key] = tick()
                        end
                        task.wait(0.1)
                    end
                end
            end
            task.wait(LoopDelay)
        end
        AutoSkillThread = nil
    end)
end

local function TriggerAutoSkipHeli(state)
    pcall(function() ReplicatedStorage.SetSettingAutoSkipWave:FireServer(state) end)
end

local function DeleteMapTextures()
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy()
            elseif obj:IsA("MeshPart")    then obj.TextureID = ""
            elseif obj:IsA("SpecialMesh") then obj.TextureId = ""
            elseif obj:IsA("Part") or obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic
            end
        end
    end)
end

-- ====================== AUTO FILL UP ======================
local function DoFillUp()
    for i = 1, 2 do
        pcall(function() ReplicatedStorage.ShopSystem:FireServer("Buy", "FillHP") end)
        if i < 2 then task.wait(0.3) end
    end
end

local function StartAutoFillUpLoop()
    if FillUpRunning then return end
    FillUpRunning = true
    task.spawn(function()
        while AutoFillUpEnabled and AutoFarmEnabled do
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
local function startNoBarrier()
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
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = hum.MaxHealth end
            end
        end)
    end)
end

local function stopNoBarrier()
    if noBarrierConnection then noBarrierConnection:Disconnect(); noBarrierConnection = nil end
end

-- ====================== FLUSH SYSTEM ======================
local function ActivateProximityPrompt(prompt)
    pcall(function()
        prompt.HoldDuration = 0; prompt.MaxActivationDistance = 50
        if fireproximityprompt then fireproximityprompt(prompt) end
        prompt:InputHoldBegin(); task.wait(0.05); prompt:InputHoldEnd()
    end)
end

local function ActivateAllFlushPrompts()
    pcall(function()
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Model") then
                local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    local at = prompt.ActionText:lower()
                    if at:find("flush") or at:find("flash") or at:find("dragon") then
                        ActivateProximityPrompt(prompt)
                    end
                end
            end
        end
    end)
end

-- ====================== AUTO VOTE SYSTEM ======================
local AutoVoteEnabled       = Config:Get("AutoVoteEnabled", false)
local AutoVoteValue         = Config:Get("AutoVoteValue", "Normal Mode")
local AutoVoteinGameEnabled = Config:Get("AutoVoteinGameEnabled", false)
local AutoVoteValue2        = Config:Get("AutoVoteValue2", "Normal")

local _voteRespawnConn   = nil
local _voteIGRespawnConn = nil
local _syncRespawnConn   = nil

local function FireVote_Solo()
    if not AutoVoteValue then return end
    pcall(function() ReplicatedStorage.MainHandler:FireServer({ [1] = "StartSolo", [2] = AutoVoteValue }) end)
end

local function FireGetReady()
    task.wait(2.5)
    pcall(function() ReplicatedStorage.GetReadyRemote:FireServer("1", true) end)
end

local function FireVote_InGame()
    if not AutoVoteValue2 then return end
    pcall(function() ReplicatedStorage.Vote:FireServer(AutoVoteValue2) end)
end

local function SetupSyncVoteAndStart()
    if _voteRespawnConn then _voteRespawnConn:Disconnect(); _voteRespawnConn = nil end
    if _syncRespawnConn then _syncRespawnConn:Disconnect(); _syncRespawnConn = nil end
    FireVote_Solo()
    task.spawn(function() task.wait(2.5); if AutoVoteEnabled and AutoStartEnabled then FireGetReady() end end)
    _syncRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1.5)
        if AutoVoteEnabled and AutoStartEnabled then
            FireVote_Solo()
            task.spawn(function() task.wait(2.5); if AutoVoteEnabled and AutoStartEnabled then FireGetReady() end end)
        end
    end)
end

local function SetupAutoVote_SoloOnly(enabled)
    if _voteRespawnConn then _voteRespawnConn:Disconnect(); _voteRespawnConn = nil end
    if not enabled then return end
    FireVote_Solo()
    _voteRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1.5)
        if AutoVoteEnabled and not AutoStartEnabled then FireVote_Solo() end
    end)
end

local function SetupAutoStartOnly(enabled)
    if AutoStartConnection then AutoStartConnection:Disconnect(); AutoStartConnection = nil end
    if not enabled then return end
    FireGetReady()
    AutoStartConnection = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if AutoStartEnabled and not AutoVoteEnabled then task.spawn(FireGetReady) end
    end)
end

local function RefreshVoteAndStartSetup()
    if _voteRespawnConn    then _voteRespawnConn:Disconnect();    _voteRespawnConn    = nil end
    if _syncRespawnConn    then _syncRespawnConn:Disconnect();    _syncRespawnConn    = nil end
    if AutoStartConnection then AutoStartConnection:Disconnect(); AutoStartConnection = nil end
    if AutoVoteEnabled and AutoStartEnabled then
        SetupSyncVoteAndStart()
    elseif AutoVoteEnabled then
        SetupAutoVote_SoloOnly(true)
    elseif AutoStartEnabled then
        SetupAutoStartOnly(true)
    end
end

local function SetupAutoVote_InGame(enabled)
    if _voteIGRespawnConn then _voteIGRespawnConn:Disconnect(); _voteIGRespawnConn = nil end
    if not enabled then return end
    FireVote_InGame()
    _voteIGRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1.5)
        if AutoVoteinGameEnabled then FireVote_InGame() end
    end)
end

local function StartAutoStart()  AutoStartEnabled = true;  RefreshVoteAndStartSetup() end
local function StopAutoStart()   AutoStartEnabled = false; RefreshVoteAndStartSetup() end

-- ====================== TELEPORT TO IDLE ======================
local function TeleportToIdle()
    LockActive = false; task.wait(0.1); WaitingRespawn = true
    pcall(function()
        Character:PivotTo(IdlePosition)
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end)
end

-- ====================== COLLECT SYSTEM ======================
local CollectItems = {
    "Clock Spider","X-18 Core","Green Energy Core","Weird Transmitter",
    "Presents","Weird Prism","Key Card","Zombie Core","Flash Drives","Astro Samples",
}

local CollectGroupMap = {
    ["Astro Samples"] = {
        "Trooper Blast","Trooper Spinner","Specialist Blaster","Specialist Spinner",
        "Specialist Sword Arm","Strider Leg","Interceptor Wing","Interceptor Goggles",
        "Interceptor Spinner","Impactor Cannon","Impactor Laser","High Impactor Cannon",
        "High Impactor Laser","Destructor Laser","Destructor Blaster","Destructor Core",
        "Obliterator Blaster","Obliterator Spinner",
    },
}

local AutoCollectEnabled   = Config:Get("AutoCollectEnabled", false)
local SelectedCollectItems = Config:Get("SelectedCollectItems", {})
local CollectMode          = Config:Get("CollectMode", "Clean")
local KnownCollectItems    = {}
local CollectRunning       = false

local function MatchesPattern(objectName, pattern)
    local objL, patL = objectName:lower(), pattern:lower()
    if objL == patL then return true end
    if #objL > #patL and objL:sub(1, #patL) == patL then
        local nc = objL:sub(#patL+1, #patL+1)
        if nc == " " or nc == "#" or nc == "_" or nc == "-" then return true end
    end
    if CollectGroupMap[pattern] then
        for _, gName in ipairs(CollectGroupMap[pattern]) do
            if objL == gName:lower() then return true end
        end
    end
    return false
end

local function IsCollectTarget(objectName)
    for _, pattern in ipairs(SelectedCollectItems) do
        if MatchesPattern(objectName, pattern) then return true end
    end
    return false
end

local function FindNewCollectItems()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj and obj.Parent and IsCollectTarget(obj.Name) then
            if obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("BasePart") then
                if not KnownCollectItems[obj] then table.insert(found, obj) end
            end
        end
    end
    return found
end

local function GetItemRootPart(obj)
    if obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
    elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then return obj end
    return nil
end

local function TweenToItem(itemRoot)
    if not itemRoot or not HumanoidRootPart then return end
    local targetPos = itemRoot.Position + Vector3.new(0, 3, 0)
    local tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear), { CFrame = CFrame.new(targetPos, itemRoot.Position) })
    tween:Play(); tween.Completed:Wait()
end

local function ActivateItemPrompts(obj)
    pcall(function()
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                child.HoldDuration = 0; child.MaxActivationDistance = 50
                if fireproximityprompt then fireproximityprompt(child) end
                child:InputHoldBegin(); task.wait(0.05); child:InputHoldEnd()
            end
        end
    end)
end

local function IsItemGone(obj) return not obj or not obj.Parent end

local function CollectSingleItem(obj)
    if IsItemGone(obj) then return end
    local itemRoot = GetItemRootPart(obj)
    if not itemRoot then return end
    TweenToItem(itemRoot)
    local lockConn
    lockConn = RunService.RenderStepped:Connect(function()
        if IsItemGone(obj) or not AutoCollectEnabled then lockConn:Disconnect(); return end
        if not itemRoot or not itemRoot.Parent then lockConn:Disconnect(); return end
        if Character and HumanoidRootPart then
            Character:PivotTo(CFrame.new(itemRoot.Position + Vector3.new(0,3,0), itemRoot.Position))
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end)
    local timeout = 0
    repeat
        ActivateItemPrompts(obj); task.wait(0.1); timeout = timeout + 0.1
        if timeout > 10 then break end
    until IsItemGone(obj) or not AutoCollectEnabled
    lockConn:Disconnect()
    KnownCollectItems[obj] = true
end

local function AllMobsDead()
    local living = workspace:FindFirstChild("Living")
    if not living then return true end
    for _, mob in ipairs(living:GetChildren()) do
        if IsValidMob(mob) then return false end
    end
    return true
end

local function StartAutoCollectLoop()
    if CollectRunning then return end
    CollectRunning = true
    task.spawn(function()
        while AutoCollectEnabled do
            if #SelectedCollectItems > 0 then
                local itemsToCollect = FindNewCollectItems()
                if #itemsToCollect > 0 then
                    if CollectMode == "IDGF" then
                        LockActive = false; task.wait(0.1)
                        for _, obj in ipairs(itemsToCollect) do
                            if not AutoCollectEnabled then break end
                            if not IsItemGone(obj) then CollectSingleItem(obj) else KnownCollectItems[obj] = true end
                        end
                        if AutoFarmEnabled then TeleportToIdle(); WaitingRespawn = false end
                    elseif CollectMode == "Clean" then
                        local waitedClean = 0
                        while not AllMobsDead() and AutoCollectEnabled do
                            task.wait(0.5); waitedClean = waitedClean + 0.5
                            if waitedClean >= 120 then break end
                        end
                        if not AutoCollectEnabled then break end
                        if AutoSkipHeliEnabled then TriggerAutoSkipHeli(false) end
                        LockActive = false; task.wait(0.1)
                        for _, obj in ipairs(FindNewCollectItems()) do
                            if not AutoCollectEnabled then break end
                            if not IsItemGone(obj) then CollectSingleItem(obj) else KnownCollectItems[obj] = true end
                        end
                        if AutoSkipHeliEnabled then TriggerAutoSkipHeli(true) end
                        if not IsPlayerHPFull() and AutoFillUpEnabled then
                            local fw = 0
                            while not IsPlayerHPFull() and AutoFillUpEnabled and AutoCollectEnabled do
                                task.wait(0.5); fw = fw + 0.5; if fw >= 60 then break end
                            end
                        end
                        if AutoFarmEnabled then TeleportToIdle(); WaitingRespawn = false end
                    end
                else
                    for obj, _ in pairs(KnownCollectItems) do
                        if IsItemGone(obj) then KnownCollectItems[obj] = nil end
                    end
                end
            end
            task.wait(0.5)
        end
        CollectRunning = false
    end)
end

workspace.DescendantAdded:Connect(function(obj)
    if not AutoCollectEnabled or #SelectedCollectItems == 0 then return end
    if not IsCollectTarget(obj.Name) then return end
    if not (obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("BasePart")) then return end
    FarmLog_Push("» Collect: New item appeared — " .. obj.Name, "Info")
end)

-- ============================================================
-- ====================== MAIN FARM LOOP ======================
-- ============================================================
StartFarmLoop = function()
    if FarmLoopRunning then return end
    FarmLoopRunning = true
    FarmStats_Reset()
    SmartRejoin_ResetCount()

    FarmLog_Push("◈ Farm Loop: Started | Mode=" .. FarmMode .. " | Pos=" .. FarmPosition, "Sys")
    FarmLog_Push("» Uptime: 00:00:00 | Kills: 0 | KPM: 0.00", "Info")

    task.spawn(function()
        -- idle keeper
        task.spawn(function()
            while AutoFarmEnabled do
                if WaitingRespawn and not LockActive then
                    pcall(function()
                        local t = TweenService:Create(HumanoidRootPart, TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear), { CFrame = IdlePosition })
                        t:Play(); t.Completed:Wait()
                        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                    end)
                end
                task.wait(0.1)
            end
        end)

        -- periodic status log (ทุก 30s)
        task.spawn(function()
            while AutoFarmEnabled do
                task.wait(30)
                if not AutoFarmEnabled then break end
                local hp, maxHp = GetPlayerHPInfo()
                local hpPct = maxHp > 0 and math.floor((hp/maxHp)*100) or 0
                FarmLog_Push(string.format("» Status | Up: %s | Kills: %d | KPM: %s | HP: %d/%d (%d%%) | Wave: %d",
                    FarmStats_GetUptime(), FarmStats.KillCount, FarmStats_GetKPM(),
                    math.floor(hp), math.floor(maxHp), hpPct, FarmStats.WaveCount), "Info")
            end
        end)

        local currentMob     = nil
        local currentMobType = nil
        local lastLoggedMob  = nil

        while AutoFarmEnabled do
            WatchdogHeartbeat()

            -- character refresh
            if not Character or not Character.Parent then
                Character        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                Client           = LocalPlayer
                FarmLog_Push("⚠ Character refreshed — resuming...", "Warn")
            end

            local mob, mobType, extraData = GetPriorityMob()

            if mob then
                WaitingRespawn = false

                local newRank     = GetMobRank(mobType)
                local currentRank = GetMobRank(currentMobType or "")
                local shouldSwitch = (mob ~= currentMob) and
                    (newRank < currentRank or currentMob == nil or IsMobDead(currentMob))

                if shouldSwitch then
                    FarmInterrupt = true; LockActive = false; task.wait(0.05); FarmInterrupt = false
                    if currentMob then ResetMobOverride(currentMob) end
                    currentMob = mob; currentMobType = mobType
                    if newRank < currentRank and currentMobType ~= nil then
                        FarmStats.InterruptCount = FarmStats.InterruptCount + 1
                    end

                    -- [LOG] target details
                    if mob ~= lastLoggedMob then
                        lastLoggedMob = mob
                        local mh   = mob:FindFirstChild("Humanoid")
                        local mr   = mob:FindFirstChild("HumanoidRootPart")
                        local mHP  = mh and math.floor(mh.Health)    or 0
                        local mMax = mh and math.floor(mh.MaxHealth)  or 0
                        local mDist= (mr and HumanoidRootPart) and math.floor((HumanoidRootPart.Position - mr.Position).Magnitude) or 0
                        local hpPct= mMax > 0 and math.floor((mHP/mMax)*100) or 0
                        FarmLog_Push(string.format("⊕ Target: %s  [%s]", mob.Name, mobType), "Target")
                        FarmLog_Push(string.format("  ♥ HP: %d / %d  (%d%%)", mHP, mMax, hpPct), "HP")
                        FarmLog_Push(string.format("  ⇢ Distance: %dm  |  Position: %s", mDist, FarmPosition), "Dist")
                        FarmLog_Push(string.format("  ◈ Mode: %s  |  Height Padding: %s", FarmMode, tostring(GetEffectivePadding(mob))), "Sys")
                    end
                end

                -- ── GiantST ──────────────────────────────────────────────
                if mobType == "GiantST" and extraData then
                    local cf = GetTargetCFrame(mob, FarmPosition)
                    if cf then
                        if FarmMode == "Tween" then
                            local dist = HumanoidRootPart and (HumanoidRootPart.Position - cf.Position).Magnitude or 10
                            local spd = SmartTweenSpeed(dist)
                            local tw = TweenService:Create(HumanoidRootPart, TweenInfo.new(spd, Enum.EasingStyle.Linear), { CFrame = cf })
                            tw:Play(); tw.Completed:Wait()
                        else tp1(cf) end
                    end
                    local giantConn
                    giantConn = RunService.RenderStepped:Connect(function()
                        if IsMobDead(mob) or not mob.Parent or not AutoFarmEnabled or FarmInterrupt then
                            giantConn:Disconnect(); return
                        end
                        local lockCF = GetTargetCFrame(mob, FarmPosition)
                        if lockCF and Character and HumanoidRootPart then
                            Character:PivotTo(lockCF)
                            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                        end
                    end)
                    repeat
                        task.wait(0.2); WatchdogHeartbeat()
                        ActivateProximityPrompt(extraData)
                        ActivateAllFlushPrompts()
                        local cm, ct = GetPriorityMob()
                        if cm and cm ~= mob and GetMobRank(ct) < GetMobRank(mobType) then
                            FarmInterrupt = true; break
                        end
                    until IsMobDead(mob) or not mob.Parent or not AutoFarmEnabled or FarmInterrupt
                    giantConn:Disconnect()
                    if IsMobDead(mob) and not FarmInterrupt then
                        FarmStats.KillCount = FarmStats.KillCount + 1
                        lastLoggedMob = nil
                        FarmLog_Push(string.format("☠ Killed: %s  |  Total: %d  |  KPM: %s  |  Wave: %d",
                            mob.Name, FarmStats.KillCount, FarmStats_GetKPM(), FarmStats.WaveCount), "Kill")
                    end
                    if FarmInterrupt then FarmInterrupt = false end

                -- ── Normal / Helicopter / HighHP / Nearest ────────────────
                else
                    -- [Health Guard] SafeMode
                    if SafeModeEnabled and GetPlayerHealthPercent() < SafeValue then
                        local mr = mob:FindFirstChild("HumanoidRootPart")
                        if mr then
                            local safePos = mr.Position + Vector3.new(0, 111 + GetMobSize(mob), 0)
                            pcall(function()
                                Character:PivotTo(CFrame.new(safePos))
                                HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                            end)
                            FarmLog_Push(string.format("⚠ SafeMode: HP %.0f%% < %d%% — retreating!", GetPlayerHealthPercent(), SafeValue), "Warn")
                        end
                        task.wait(0.5)
                    else
                        StartDamageChecker(mob)
                        TeleportToMob(mob)
                        LockToMob(mob)

                        repeat
                            task.wait(0.1); WatchdogHeartbeat()
                            if not AutoFarmEnabled then break end
                            local nextMob, nextType = GetPriorityMob()
                            if nextMob and nextMob ~= mob then
                                if GetMobRank(nextType) < GetMobRank(mobType) then
                                    FarmLog_Push(string.format("% Interrupt: %s → %s (higher priority)", mobType, nextType), "Warn")
                                    FarmInterrupt = true
                                    FarmStats.InterruptCount = FarmStats.InterruptCount + 1
                                    break
                                end
                            end
                        until IsMobDead(mob) or not AutoFarmEnabled or FarmInterrupt

                        if IsMobDead(mob) and not FarmInterrupt then
                            FarmStats.KillCount    = FarmStats.KillCount + 1
                            FarmStats.LastKillTime = tick()
                            lastLoggedMob = nil
                            -- KPM history for graph
                            table.insert(FarmStats.KPMHistory, { t = tick(), kpm = tonumber(FarmStats_GetKPM()) })
                            if #FarmStats.KPMHistory > 60 then table.remove(FarmStats.KPMHistory, 1) end
                            FarmLog_Push(string.format("☠ Killed: %s  |  Total: %d  |  KPM: %s  |  Wave: %d",
                                mob.Name, FarmStats.KillCount, FarmStats_GetKPM(), FarmStats.WaveCount), "Kill")
                        end

                        LockActive = false
                        ResetMobOverride(mob)
                        if FarmInterrupt then
                            FarmInterrupt = false; currentMob = nil; currentMobType = nil
                        end
                    end
                end

            else
                -- ไม่มีมอน → idle รอ wave ใหม่
                currentMob = nil; currentMobType = nil; lastLoggedMob = nil
                FarmStats.WaveCount = FarmStats.WaveCount + 1
                FarmLog_Push(string.format("〜 Wave %d cleared — going idle, waiting for next wave...", FarmStats.WaveCount), "Wave")
                FarmLog_Push(string.format("  ◈ Session | Up: %s  Kills: %d  KPM: %s  Deaths: %d",
                    FarmStats_GetUptime(), FarmStats.KillCount, FarmStats_GetKPM(), FarmStats.DeathCount), "Sys")
                TeleportToIdle()
                local waitTick = tick()
                repeat
                    task.wait(0.5); WatchdogHeartbeat()
                    -- SmartRejoin: ถ้ารอนานเกิน 3 นาทีโดยไม่มีมอนเลย → error count
                    if tick() - waitTick > 180 then
                        SmartRejoin_Trigger("No mobs for 3 minutes")
                        waitTick = tick()
                    end
                until GetPriorityMob() ~= nil or not AutoFarmEnabled
                WaitingRespawn = false
                if AutoFarmEnabled then
                    FarmLog_Push("✔ New wave detected — resuming farm!", "Success")
                end
            end

            task.wait(0.1)
        end

        FarmLog_Push("⚠ Farm Loop: Stopped", "Warn")
        WaitingRespawn  = false
        FarmLoopRunning = false
    end)
end

-- ====================== MISC OPTIONS HANDLER ======================
HandleMiscOptions = function(selectedOptions)
    MiscOptions = selectedOptions

    local hasAutoAttack = table.find(selectedOptions, "Auto Attack")
    if hasAutoAttack and not AutoAttackEnabled then
        AutoAttackEnabled = true; StartAutoAttack()
    elseif not hasAutoAttack then
        AutoAttackEnabled = false; AutoAttackThread = nil
    end

    local hasAutoSkill = table.find(selectedOptions, "Auto Skill")
    if hasAutoSkill and not AutoSkillEnabled then
        AutoSkillEnabled = true; StartAutoSkill()
    elseif not hasAutoSkill then
        AutoSkillEnabled = false; AutoSkillThread = nil
    end

    local hasSkipHeli = table.find(selectedOptions, "Auto Skip Helicopter")
    if hasSkipHeli and not AutoSkipHeliEnabled then AutoSkipHeliEnabled = true; TriggerAutoSkipHeli(true)
    elseif not hasSkipHeli and AutoSkipHeliEnabled then AutoSkipHeliEnabled = false; TriggerAutoSkipHeli(false) end

    local hasDeleteMap = table.find(selectedOptions, "Delete Map")
    if hasDeleteMap and not DeleteMapEnabled then DeleteMapEnabled = true; DeleteMapTextures() end

    SafeModeEnabled = table.find(selectedOptions, "Safe Mode") ~= nil

    local hasAutoStart = table.find(selectedOptions, "Auto Start")
    if hasAutoStart and not AutoStartEnabled then StartAutoStart()
    elseif not hasAutoStart and AutoStartEnabled then StopAutoStart() end

    local hasAutoFillUp = table.find(selectedOptions, "Auto Fill Up")
    if hasAutoFillUp and not AutoFillUpEnabled then
        if AutoFarmEnabled then AutoFillUpEnabled = true; StartAutoFillUpLoop() end
    elseif not hasAutoFillUp then
        AutoFillUpEnabled = false; FillUpRunning = false
    end

    Config:Set("MiscOptions", selectedOptions); Config:Save()
end

-- ====================== WATCHDOG ======================
local function StartWatchdog()
    if WatchdogThread then task.cancel(WatchdogThread); WatchdogThread = nil end
    if not WatchdogEnabled then return end
    WatchdogThread = task.spawn(function()
        while WatchdogEnabled do
            task.wait(WATCHDOG_TIMEOUT)
            if not AutoFarmEnabled then continue end
            local elapsed = tick() - WatchdogLastBeat
            if elapsed >= WATCHDOG_TIMEOUT then
                warn("[DYHUB] Watchdog: Farm loop frozen " .. math.floor(elapsed) .. "s → Restarting")
                FarmLog_Push(string.format("⚠ Watchdog: Loop frozen %ds → Restarting...", math.floor(elapsed)), "Warn")
                Notify("⚠ Watchdog", "Farm loop restarted automatically!", 4, "refresh-cw", "watchdog")
                FarmLoopRunning = false; FarmInterrupt = false; LockActive = false; WaitingRespawn = false
                WatchdogLastBeat = tick()
                task.wait(0.5)
                if AutoFarmEnabled then
                    FarmLog_Push("◈ Farm loop restarted by Watchdog — resuming...", "Sys")
                    StartFarmLoop(); HandleMiscOptions(MiscOptions)
                end
            end
        end
        WatchdogThread = nil
    end)
end

-- ====================== MEMORY CLEANUP ======================
local function StartMemoryCleanup()
    task.spawn(function()
        while true do
            task.wait(300)
            local cleaned = 0
            for mob, _ in pairs(MobHeightOverride) do
                if not mob or not mob.Parent or IsMobDead(mob) then
                    MobHeightOverride[mob] = nil; MobConfirmedPadding[mob] = nil; MobLastHealth[mob] = nil
                    cleaned = cleaned + 1
                end
            end
            local cleanedCollect = 0
            for obj, _ in pairs(KnownCollectItems) do
                if not obj or not obj.Parent then KnownCollectItems[obj] = nil; cleanedCollect = cleanedCollect + 1 end
            end
            if cleaned > 0 or cleanedCollect > 0 then
                FarmLog_Push(string.format("◈ Memory Cleanup: %d mob cache, %d collect cleared", cleaned, cleanedCollect), "Sys")
            end
        end
    end)
end

-- ====================== CHARACTER RESPAWN HANDLER ======================
-- [FIX v023.6] Death Recovery — restart farm loop หลัง respawn อัตโนมัติ
LocalPlayer.CharacterAdded:Connect(function(char)
    Character        = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Client           = LocalPlayer
    MobHeightOverride   = {}
    MobConfirmedPadding = {}
    MobLastHealth       = {}
    FarmStats.DeathCount = FarmStats.DeathCount + 1
    task.wait(1)
    local cam = workspace.CurrentCamera
    cam.CameraSubject = HumanoidRootPart
    cam.CameraType    = Enum.CameraType.Custom

    if AutoFarmEnabled then
        FarmLog_Push(string.format("⚠ Death #%d detected — restarting farm loop in 2s...", FarmStats.DeathCount), "Warn")
        task.wait(2)
        -- [Death Recovery] reset loop flag แล้ว restart
        FarmLoopRunning = false
        FarmInterrupt   = false
        LockActive      = false
        WaitingRespawn  = false
        if AutoFarmEnabled then
            FarmLog_Push("✔ Death Recovery: Farm loop restarted!", "Success")
            StartFarmLoop()
            HandleMiscOptions(MiscOptions)
        end
    end
end)

-- ====================== ESP SYSTEM ======================
local ESP = {
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
    ItemList = { "Clock Spider","X-18 Core","Green Energy Core","Weird Transmitter","Presents","Weird Prism","Key Card","Zombie Core","Flash Drives","Astro Samples" },
    MobList  = {},
}

local function IsESPItemTarget(objectName, selectedList)
    for _, pattern in ipairs(selectedList) do
        if objectName:lower() == pattern:lower() then return true end
        if #objectName > #pattern and objectName:lower():sub(1, #pattern) == pattern:lower() then
            local nc = objectName:lower():sub(#pattern+1, #pattern+1)
            if nc == " " or nc == "#" or nc == "_" or nc == "-" then return true end
        end
        if CollectGroupMap[pattern] then
            for _, gName in ipairs(CollectGroupMap[pattern]) do
                if objectName:lower() == gName:lower() then return true end
            end
        end
    end
    return false
end

local function CreateESPLabel(parent, labelText)
    local existing = parent:FindFirstChild("DYHUB_ESP_LABEL")
    if existing then existing:Destroy() end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DYHUB_ESP_LABEL"; billboard.Size = UDim2.new(0,120,0,40)
    billboard.StudsOffset = Vector3.new(0,3,0); billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false; billboard.Adornee = parent; billboard.Parent = parent
    local frame = Instance.new("Frame"); frame.BackgroundTransparency = 1; frame.Size = UDim2.fromScale(1,1); frame.Parent = billboard
    local label = Instance.new("TextLabel"); label.BackgroundTransparency = 1; label.Size = UDim2.fromScale(1,1)
    label.Font = Enum.Font.GothamBold; label.TextSize = 11; label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextStrokeTransparency = 0.4; label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    label.Text = labelText; label.Parent = frame
    return billboard, label
end

local function CreateHighlight(model, outlineColor, fillColor, fillTransparency)
    local existing = model:FindFirstChild("DYHUB_ESP_HIGHLIGHT")
    if existing then existing:Destroy() end
    local hl = Instance.new("Highlight")
    hl.Name = "DYHUB_ESP_HIGHLIGHT"; hl.OutlineColor = outlineColor
    hl.FillColor = fillColor; hl.FillTransparency = fillTransparency or 0.9
    hl.OutlineTransparency = 0; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model; hl.Parent = model
    return hl
end

local function RemoveESP(model)
    pcall(function()
        local hl = model:FindFirstChild("DYHUB_ESP_HIGHLIGHT"); if hl then hl:Destroy() end
        local hb = model:FindFirstChild("DYHUB_ESP_LABEL"); if hb then hb:Destroy() end
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp then local lb = hrp:FindFirstChild("DYHUB_ESP_LABEL"); if lb then lb:Destroy() end end
    end)
end

local function IsInRange(targetPart)
    if not targetPart or not HumanoidRootPart then return false end
    return (HumanoidRootPart.Position - targetPart.Position).Magnitude <= ESP.MaxDistance
end

local function GetESPSettings()
    local s = ESP.Settings
    return {
        highlight = table.find(s, "Highlight") ~= nil,
        distance  = table.find(s, "Distance")  ~= nil,
        health    = table.find(s, "Health")    ~= nil,
        name      = table.find(s, "Name")      ~= nil,
    }
end

local function BuildLabelText(model, showName, showHealth, showDistance)
    local parts = {}
    if showName then table.insert(parts, model.Name) end
    if showHealth then
        local h = model:FindFirstChild("Humanoid")
        if h then table.insert(parts, "❤ " .. math.floor(h.Health) .. "/" .. math.floor(h.MaxHealth)) end
    end
    if showDistance then
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp and HumanoidRootPart then table.insert(parts, "📏 " .. math.floor((HumanoidRootPart.Position - hrp.Position).Magnitude) .. "m") end
    end
    return table.concat(parts, "\n")
end

local function BuildItemLabelText(obj, showName, showDistance)
    local parts = {}
    if showName then table.insert(parts, obj.Name) end
    if showDistance then
        local root = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or (obj:IsA("BasePart") and obj or nil)
        if root and HumanoidRootPart then table.insert(parts, "📏 " .. math.floor((HumanoidRootPart.Position - root.Position).Magnitude) .. "m") end
    end
    return table.concat(parts, "\n")
end

local function ApplyMobESP(mob)
    if not mob or not mob.Parent then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local s = GetESPSettings()
    if s.highlight then CreateHighlight(mob, Color3.fromRGB(255,50,50), Color3.fromRGB(255,255,255), 0.9) end
    if s.name or s.health or s.distance then
        local _, label = CreateESPLabel(hrp, "")
        task.spawn(function()
            while mob and mob.Parent and ESP.Enabled and ESP.MobEnabled do
                local h = mob:FindFirstChild("Humanoid")
                if not h or h.Health <= 0 then break end
                if not IsInRange(hrp) then label.Visible = false; task.wait(0.5)
                else label.Visible = true; label.Text = BuildLabelText(mob, s.name, s.health, s.distance); task.wait(0.15) end
            end
            RemoveESP(mob); ESP._mobHighlights[mob] = nil
        end)
    end
    ESP._mobHighlights[mob] = true
end

local function ScanMobs()
    local living = workspace:FindFirstChild("Living"); if not living then return end
    for _, mob in ipairs(living:GetChildren()) do
        if IsValidMob(mob) and not ESP._mobHighlights[mob] then
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hrp and IsInRange(hrp) then ApplyMobESP(mob) end
        end
    end
end

local function ApplyPlayerESP(playerChar)
    if not playerChar or not playerChar.Parent then return end
    local hrp = playerChar:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if playerChar == LocalPlayer.Character then return end
    local s = GetESPSettings()
    if s.highlight then CreateHighlight(playerChar, Color3.fromRGB(50,255,50), Color3.fromRGB(255,255,255), 0.9) end
    if s.name or s.health or s.distance then
        local _, label = CreateESPLabel(hrp, "")
        task.spawn(function()
            while playerChar and playerChar.Parent and ESP.Enabled and ESP.PlayerEnabled do
                local h = playerChar:FindFirstChild("Humanoid")
                if not h or h.Health <= 0 then break end
                if not IsInRange(hrp) then label.Visible = false; task.wait(0.5)
                else label.Visible = true; label.Text = BuildLabelText(playerChar, s.name, s.health, s.distance); task.wait(0.15) end
            end
            RemoveESP(playerChar); ESP._playerHighlights[playerChar] = nil
        end)
    end
    ESP._playerHighlights[playerChar] = true
end

local function ScanPlayers()
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

local function GetItemRoot(obj)
    if obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
    elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then return obj end
    return nil
end

local function ApplyItemESP(obj)
    if not obj or not obj.Parent then return end
    local root = GetItemRoot(obj); if not root then return end
    local s = GetESPSettings()
    if s.highlight then CreateHighlight(obj, Color3.fromRGB(255,215,0), Color3.fromRGB(255,255,255), 0.9) end
    if s.name or s.distance then
        local _, label = CreateESPLabel(root, "")
        task.spawn(function()
            while obj and obj.Parent and ESP.Enabled and ESP.ItemEnabled do
                local cr = GetItemRoot(obj); if not cr then break end
                if not IsInRange(cr) then label.Visible = false; task.wait(0.5)
                else label.Visible = true; label.Text = BuildItemLabelText(obj, s.name, s.distance); task.wait(0.25) end
            end
            RemoveESP(obj); ESP._itemHighlights[obj] = nil
        end)
    end
    ESP._itemHighlights[obj] = true
end

local function ScanItems()
    if #ESP.SelectedItems == 0 then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not ESP._itemHighlights[obj] and IsESPItemTarget(obj.Name, ESP.SelectedItems) then
            local root = GetItemRoot(obj)
            if root and IsInRange(root) then ApplyItemESP(obj) end
        end
    end
end

local function ClearAllESP()
    for mob, _ in pairs(ESP._mobHighlights) do RemoveESP(mob) end; ESP._mobHighlights = {}
    for char, _ in pairs(ESP._playerHighlights) do RemoveESP(char) end; ESP._playerHighlights = {}
    for obj, _ in pairs(ESP._itemHighlights) do RemoveESP(obj) end; ESP._itemHighlights = {}
end

local ESPConnection = nil
local function StartESPLoop()
    if ESPConnection then ESPConnection:Disconnect(); ESPConnection = nil end
    local tickCounter = 0
    ESPConnection = RunService.Heartbeat:Connect(function()
        tickCounter = tickCounter + 1
        if tickCounter % 30 == 0 and ESP.Enabled and ESP.MobEnabled    then pcall(ScanMobs) end
        if tickCounter % 47 == 0 and ESP.Enabled and ESP.PlayerEnabled then pcall(ScanPlayers) end
        if tickCounter % 61 == 0 and ESP.Enabled and ESP.ItemEnabled   then pcall(ScanItems) end
        if tickCounter >= 3660 then tickCounter = 0 end
    end)
end

local function StopESPLoop()
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

-- WatchLivingFolder
local livingWatchConn = nil
local function WatchLivingFolder()
    if livingWatchConn then livingWatchConn:Disconnect(); livingWatchConn = nil end
    local living = workspace:FindFirstChild("Living")
    if not living then return end
    livingWatchConn = living.ChildAdded:Connect(function(obj)
        if not ESP.Enabled or not ESP.MobEnabled then return end
        task.wait(0.2)
        if IsValidMob(obj) and not ESP._mobHighlights[obj] then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hrp and IsInRange(hrp) then ApplyMobESP(obj) end
        end
    end)
    living.AncestryChanged:Connect(function(_, parent)
        if parent == nil then livingWatchConn = nil end
    end)
end

task.spawn(function()
    if not workspace:FindFirstChild("Living") then
        workspace.ChildAdded:Connect(function(child) if child.Name == "Living" then task.wait(0.1); WatchLivingFolder() end end)
    else
        WatchLivingFolder()
    end
    workspace.ChildAdded:Connect(function(child) if child.Name == "Living" then task.wait(0.1); WatchLivingFolder() end end)
end)

-- ============================================================
-- ==================== START BACKGROUND SYSTEMS ==============
-- ============================================================
StartMemoryCleanup()
SetupAutoRejoin()

-- ============================================================
-- ====================== UI: MAIN TAB ========================
-- ============================================================
Main:Section({ Title = "Auto Farm", Icon = "package" })

AutoFarmToggle = Main:Toggle({
    Title = "Auto Farm",
    Value = AutoFarmEnabled,
    Callback = function(state)
        AutoFarmEnabled = state
        if state then
            FarmLog_Push("◈ Auto Farm: Enabled by user", "Sys")
            FarmLog_Push("» Session starting — waiting for mobs...", "Info")
            StartFarmLoop()
            HandleMiscOptions(MiscOptions)
            -- [FIX v023.6] Start Watchdog เมื่อ farm เปิด
            StartWatchdog()
        else
            FarmLog_Push("⚠ Auto Farm: Disabled by user", "Warn")
            AutoAttackEnabled = false; AutoSkillEnabled = false
            AutoSkipHeliEnabled = false; AutoFillUpEnabled = false
            FillUpRunning = false
            if AutoStartEnabled then StopAutoStart() end
            if WatchdogThread then task.cancel(WatchdogThread); WatchdogThread = nil end
        end
        Config:Set("AutoFarmEnabled", state); Config:Save()
    end
})

Main:Section({ Title = "Farm Settings", Icon = "settings" })

PositionDropdown = Main:Dropdown({
    Title = "Position Farm", Values = { "Above", "Under" }, Multi = false, Value = FarmPosition,
    Callback = function(value) FarmPosition = value; Config:Set("FarmPosition", value); Config:Save() end
})

ModeDropdown = Main:Dropdown({
    Title = "Mode Farm", Values = { "Tween" }, Multi = false, Value = FarmMode,
    Callback = function(value) FarmMode = value; Config:Set("FarmMode", value); Config:Save() end
})

MiscDropdown = Main:Dropdown({
    Title = "Misc Farm",
    Values = { "Auto Attack", "Auto Skill", "Auto Start", "Auto Skip Helicopter", "Auto Fill Up", "Safe Mode", "Delete Map" },
    Multi = true, Value = MiscOptions,
    Callback = function(values) MiscOptions = values; HandleMiscOptions(values) end
})

Main:Section({ Title = "Override Settings", Icon = "ruler" })

PaddingReduceInput = Main:Input({
    Title = "Set Padding Reduce", Default = tostring(PADDING_REDUCE_STEP), Placeholder = "Default: 2",
    Callback = function(text)
        local num = tonumber(text)
        if num then PADDING_REDUCE_STEP = num; Config:Set("PaddingReduceStep", num); Config:Save() end
    end
})

PaddingSafeInput = Main:Input({
    Title = "Set Padding Safe Min (Global Floor)", Default = tostring(PADDING_SAFE_MIN), Placeholder = "Default: -30",
    Callback = function(text)
        local num = tonumber(text)
        if num then PADDING_SAFE_MIN = num; Config:Set("PaddingSafeMin", num); Config:Save() end
    end
})

Main:Slider({
    Title = "Anti-Clip Margin (studs)", Value = { Min = 0, Max = 10, Default = ANTI_CLIP_MARGIN }, Step = 1,
    Callback = function(value) ANTI_CLIP_MARGIN = value; Config:Set("AntiClipMargin", value); Config:Save() end
})

Main:Slider({
    Title = "Damage Threshold (confirm lock)", Value = { Min = 1, Max = 500, Default = DMG_THRESHOLD }, Step = 1,
    Callback = function(value) DMG_THRESHOLD = value; Config:Set("DmgThreshold", value); Config:Save() end
})

Main:Button({
    Title = "Reset All Confirmed Positions",
    Callback = function()
        MobConfirmedPadding = {}; MobHeightOverride = {}
        Notify("Override Reset", "All confirmed mob positions cleared.", 2, "refresh-cw", "override_reset")
    end
})

Main:Section({ Title = "General Settings", Icon = "zap" })

SkillDropdown = Main:Dropdown({
    Title = "Auto Skill (Keys)", Values = skillDropdownValues, Multi = true, Value = SelectedSkills,
    Callback = function(values) SelectedSkills = values; Config:Set("SelectedSkills", values); Config:Save() end
})

SkillDelaySlider = Main:Slider({
    Title = "Skill Delay (S)", Value = { Min = 1, Max = 30, Default = SkillDelay }, Step = 1,
    Callback = function(value) SkillDelay = value; Config:Set("SkillDelay", value); Config:Save() end
})

-- [NEW v023.6] Skill Cooldown per-key
Main:Slider({
    Title = "Skill Cooldown Override (0 = use Delay)", Value = { Min = 0, Max = 30, Default = SkillCooldownSec }, Step = 1,
    Callback = function(value)
        SkillCooldownSec = value; Config:Set("SkillCooldownSec", value); Config:Save()
        SkillCooldowns = {}  -- reset cooldowns เมื่อเปลี่ยนค่า
    end
})

SafeModeSlider = Main:Slider({
    Title = "Safe Mode HP (%)", Value = { Min = 1, Max = 100, Default = SafeValue }, Step = 1,
    Callback = function(value) SafeValue = value; Config:Set("SafeValue", value); Config:Save() end
})

FarmHeightSlider = Main:Slider({
    Title = "Farm Height (+Y)", Value = { Min = -30, Max = 30, Default = HeightValue }, Step = 1,
    Callback = function(value)
        HeightValue = value; Config:Set("HeightValue", value); Config:Save()
        for mob, _ in pairs(MobHeightOverride) do
            if MobConfirmedPadding[mob] == nil then MobHeightOverride[mob] = nil end
        end
    end
})

Main:Section({ Title = "Flush Settings", Icon = "toilet" })

local Flushaura      = Config:Get("flushaura", false)
local FlushAuraValue = Config:Get("FlushAuraValue", 5)
local FlushAuraThread = nil

Main:Slider({
    Title = "Flush Aura (stud)", Value = { Min = 1, Max = 15, Default = FlushAuraValue }, Step = 1,
    Callback = function(value) FlushAuraValue = value; Config:Set("FlushAuraValue", value); Config:Save() end
})

Main:Toggle({
    Title = "Flush Aura", Value = Flushaura,
    Callback = function(enabled)
        Flushaura = enabled; Config:Set("flushaura", enabled); Config:Save()
        if FlushAuraThread then task.cancel(FlushAuraThread); FlushAuraThread = nil end
        if enabled then
            FlushAuraThread = task.spawn(function()
                while Flushaura do
                    pcall(function()
                        local char = LocalPlayer.Character
                        if not char then return end
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        for _, prompt in pairs(workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                local at = prompt.ActionText
                                if at == "Flush" or at == "Dragon Flash" or at == "flush" or at == "Flash" then
                                    local part = prompt.Parent
                                    if part and part:IsA("BasePart") then
                                        if (root.Position - part.Position).Magnitude <= FlushAuraValue then
                                            prompt.HoldDuration = 0; prompt.MaxActivationDistance = FlushAuraValue
                                            if fireproximityprompt then fireproximityprompt(prompt)
                                            else prompt:InputHoldBegin(); task.wait(); prompt:InputHoldEnd() end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
                FlushAuraThread = nil
            end)
        end
    end
})

-- ====================== UI: FARM LOG PANEL ======================
Main:Divider()
Main:Section({ Title = "Farm Log", Icon = "terminal" })

-- [FIX v023.6] Panel assign ที่นี่ — FarmLog_Push พร้อมใช้แล้ว
FarmLog.Panel = Main:Paragraph({
    Title   = "[ Farm Log ]  ·  " .. ver,
    Content = "— Waiting for Auto Farm —",
})

Main:Button({
    Title = "Clear Log",
    Callback = function() FarmLog_Clear() end
})

-- ============================================================
-- ====================== UI: ESP TAB =========================
-- ============================================================
Main4:Section({ Title = "Esp Visual", Icon = "eye" })

EspEnableToggle = Main4:Toggle({
    Title = "Enable ESP", Value = ESP.Enabled,
    Callback = function(state)
        ESP.Enabled = state; Config:Set("EspEnabled", state); Config:Save()
        if state then StartESPLoop() else StopESPLoop() end
    end
})

EspMobToggle = Main4:Toggle({
    Title = "Mob ESP", Value = ESP.MobEnabled,
    Callback = function(state)
        ESP.MobEnabled = state; Config:Set("EspMobEnabled", state); Config:Save()
        if not state then for mob, _ in pairs(ESP._mobHighlights) do RemoveESP(mob) end; ESP._mobHighlights = {} end
    end
})

EspPlayerToggle = Main4:Toggle({
    Title = "Player ESP", Value = ESP.PlayerEnabled,
    Callback = function(state)
        ESP.PlayerEnabled = state; Config:Set("EspPlayerEnabled", state); Config:Save()
        if not state then for char, _ in pairs(ESP._playerHighlights) do RemoveESP(char) end; ESP._playerHighlights = {} end
    end
})

EspItemToggle = Main4:Toggle({
    Title = "Item ESP", Value = ESP.ItemEnabled,
    Callback = function(state)
        ESP.ItemEnabled = state; Config:Set("EspItemEnabled", state); Config:Save()
        if not state then for obj, _ in pairs(ESP._itemHighlights) do RemoveESP(obj) end; ESP._itemHighlights = {} end
    end
})

Main4:Section({ Title = "Esp Settings", Icon = "settings" })

EspSettingsDropdown = Main4:Dropdown({
    Title = "ESP Options", Multi = true,
    Values = { "Highlight", "Distance", "Health", "Name" }, Value = ESP.Settings,
    Callback = function(value)
        ESP.Settings = value or {}; Config:Set("EspSettings", value); Config:Save()
        if ESP.Enabled then ClearAllESP() end
    end
})

EspItemDropdown = Main4:Dropdown({
    Title = "ESP Items", Multi = true, Values = ESP.ItemList, Value = ESP.SelectedItems,
    Callback = function(value)
        ESP.SelectedItems = value or {}; Config:Set("EspSelectedItems", value); Config:Save()
        for obj, _ in pairs(ESP._itemHighlights) do RemoveESP(obj) end; ESP._itemHighlights = {}
        if ESP.Enabled and ESP.ItemEnabled then pcall(ScanItems) end
    end
})

-- ============================================================
-- ====================== UI: PLAYER TAB ======================
-- ============================================================
Main2:Section({ Title = "Local Player", Icon = "user" })

local WSValue = Config:Get("WSValue", 16)
local JPValue = Config:Get("JPValue", 50)
local NoClip  = Config:Get("NoClip", false)

local function updatePlayerStats()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WSValue
        LocalPlayer.Character.Humanoid.JumpPower = JPValue
    end
end

RunService.Stepped:Connect(function()
    if NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1); updatePlayerStats()
end)

Main2:Slider({
    Title = "Set Walkspeed", Value = { Min = 1, Max = 200, Default = WSValue }, Step = 1,
    Callback = function(value) WSValue = value; Config:Set("WSValue", value); Config:Save(); updatePlayerStats() end
})

Main2:Slider({
    Title = "Set Jumppower", Value = { Min = 1, Max = 500, Default = JPValue }, Step = 1,
    Callback = function(value) JPValue = value; Config:Set("JPValue", value); Config:Save(); updatePlayerStats() end
})

nocliptoggle = Main2:Toggle({
    Title = "No Clip", Value = NoClip,
    Callback = function(state) NoClip = state; Config:Set("NoClip", state); Config:Save() end
})

Main2:Section({ Title = "Redeem Codes", Icon = "bird" })
local SelectedCodes = Config:Get("SelectedCodes", {})

CodeDropdown = Main2:Dropdown({
    Title = "Select Redeem Codes", Multi = true, Values = GlobalTables.redeemCodes, Value = SelectedCodes,
    Callback = function(value) SelectedCodes = value or {}; Config:Set("SelectedCodes", value); Config:Save() end
})

Main2:Button({
    Title = "Redeem Codes (Selected)",
    Callback = function()
        for _, code in ipairs(SelectedCodes or {}) do
            pcall(function() ReplicatedStorage:WaitForChild("RedeemCode"):FireServer(code) end); task.wait(0.2)
        end
    end
})

Main2:Button({
    Title = "Redeem Code (All)",
    Callback = function()
        for _, code in ipairs(GlobalTables.redeemCodes or {}) do
            pcall(function() ReplicatedStorage:WaitForChild("RedeemCode"):FireServer(code) end); task.wait(0.5)
        end
    end
})

-- ============================================================
-- ====================== UI: GAMEMODE TAB ====================
-- ============================================================
Main7:Section({ Title = "Casual Information", TextXAlignment = "Center", TextSize = 17 })
Main7:Divider()
Main7:Paragraph({
    Title = "Casual: Mission Selection",
    Desc = "- [ Step 1 ] Stay in the Lobby (not inside a game)\n- [ Step 2 ] Press Play and go to the Classic gamemode selection screen\n- [ Step 3 ] Select Casual and finish teleporting\n- [ Step 4 ] Run the script",
    Image = "rbxassetid://104487529937663", ImageSize = 30,
})
Main7:Divider()
Main7:Section({ Title = "Game Mode", Icon = "gamepad-2" })

GameModeDropdown = Main7:Dropdown({
    Title = "Set Game Mode", Values = GlobalTables.Mode, Multi = false, Value = AutoVoteValue,
    Callback = function(value) AutoVoteValue = value; Config:Set("AutoVoteValue", value); Config:Save() end
})

AutoVoteToggle = Main7:Toggle({
    Title = "Auto Game Mode (Lobby)", Value = AutoVoteEnabled,
    Callback = function(enabled)
        AutoVoteEnabled = enabled; Config:Set("AutoVoteEnabled", enabled); Config:Save()
        RefreshVoteAndStartSetup()
    end
})

Main7:Divider()
Main7:Section({ Title = "Vote Information", TextXAlignment = "Center", TextSize = 17 })
Main7:Divider()
Main7:Paragraph({
    Title = "Auto Vote: Game Mode",
    Desc = "- [ Step 1 ] Stay in the Lobby (inside a game)\n- [ Step 2 ] Set Auto Vote & Wait",
    Image = "rbxassetid://104487529937663", ImageSize = 30,
})
Main7:Divider()
Main7:Section({ Title = "Vote Mode", Icon = "gamepad-2" })

GameModeDropdown2 = Main7:Dropdown({
    Title = "Set Vote Mode", Values = GlobalTables.Votes, Multi = false, Value = AutoVoteValue2,
    Callback = function(value) AutoVoteValue2 = value; Config:Set("AutoVoteValue2", value); Config:Save() end
})

AutoVoteIGToggle = Main7:Toggle({
    Title = "Auto Vote Mode (In-Game)", Value = AutoVoteinGameEnabled,
    Callback = function(enabled)
        AutoVoteinGameEnabled = enabled; Config:Set("AutoVoteinGameEnabled", enabled); Config:Save()
        SetupAutoVote_InGame(enabled)
    end
})

-- ============================================================
-- ====================== UI: SHOP TAB ========================
-- ============================================================
Main5:Section({ Title = "Shop Weapon", Icon = "helicopter" })

local AutoBuyWeaponValue         = Config:Get("AutoBuyWeaponValue", "Stungun")
local AutoBuyWeaponToggleEnabled = Config:Get("AutoBuyWeaponEnabled", false)

WeaponDropdown = Main5:Dropdown({
    Title = "Select Buy (Weapon)", Values = GlobalTables.Weapon, Multi = false, Value = AutoBuyWeaponValue,
    Callback = function(value) AutoBuyWeaponValue = value; Config:Set("AutoBuyWeaponValue", value); Config:Save() end
})

-- [FIX v023.6] helper ป้องกัน duplicate thread
local function StartAutoBuyWeapon()
    if AutoBuyWeaponThread then return end  -- guard
    AutoBuyWeaponThread = task.spawn(function()
        while AutoBuyWeaponToggleEnabled do
            if AutoBuyWeaponValue then
                pcall(function() ReplicatedStorage.ShopSystem:FireServer("Buy", AutoBuyWeaponValue) end)
            end
            task.wait(10)
        end
        AutoBuyWeaponThread = nil
    end)
end

AutoBuyWeaponToggle = Main5:Toggle({
    Title = "Auto Buy (Weapon)", Value = AutoBuyWeaponToggleEnabled,
    Callback = function(enabled)
        AutoBuyWeaponToggleEnabled = enabled; Config:Set("AutoBuyWeaponEnabled", enabled); Config:Save()
        if AutoBuyWeaponThread then task.cancel(AutoBuyWeaponThread); AutoBuyWeaponThread = nil end
        if enabled then StartAutoBuyWeapon() end
    end
})

Main5:Button({
    Title = "Buy Weapon (Once)",
    Callback = function()
        if AutoBuyWeaponValue then pcall(function() ReplicatedStorage.ShopSystem:FireServer("Buy", AutoBuyWeaponValue) end) end
    end
})

Main5:Section({ Title = "Shop Misc", Icon = "helicopter" })

local AutoBuyMiscValue         = Config:Get("AutoBuyMiscValue", "HeadPhone")
local AutoBuyMiscToggleEnabled = Config:Get("AutoBuyMiscEnabled", false)

MiscShopDropdown = Main5:Dropdown({
    Title = "Select Buy (Misc)", Values = GlobalTables.MiscShop, Multi = false, Value = AutoBuyMiscValue,
    Callback = function(value) AutoBuyMiscValue = value; Config:Set("AutoBuyMiscValue", value); Config:Save() end
})

-- [FIX v023.6] helper ป้องกัน duplicate thread
local function StartAutoBuyMisc()
    if AutoBuyMiscThread then return end  -- guard
    AutoBuyMiscThread = task.spawn(function()
        while AutoBuyMiscToggleEnabled do
            if AutoBuyMiscValue then
                pcall(function() ReplicatedStorage.ShopSystem:FireServer("Buy", AutoBuyMiscValue) end)
            end
            task.wait(10)
        end
        AutoBuyMiscThread = nil
    end)
end

AutoBuyMiscToggle = Main5:Toggle({
    Title = "Auto Buy (Misc)", Value = AutoBuyMiscToggleEnabled,
    Callback = function(enabled)
        AutoBuyMiscToggleEnabled = enabled; Config:Set("AutoBuyMiscEnabled", enabled); Config:Save()
        if AutoBuyMiscThread then task.cancel(AutoBuyMiscThread); AutoBuyMiscThread = nil end
        if enabled then StartAutoBuyMisc() end
    end
})

Main5:Button({
    Title = "Buy Misc (Once)",
    Callback = function()
        if AutoBuyMiscValue then pcall(function() ReplicatedStorage.ShopSystem:FireServer("Buy", AutoBuyMiscValue) end) end
    end
})

-- ============================================================
-- ====================== UI: COLLECT TAB =====================
-- ============================================================
Main6:Section({ Title = "Collect Item", Icon = "package" })

AutoCollectToggle = Main6:Toggle({
    Title = "Auto Collect", Value = AutoCollectEnabled,
    Callback = function(state)
        AutoCollectEnabled = state; Config:Set("AutoCollectEnabled", state); Config:Save()
        if state then KnownCollectItems = {}; StartAutoCollectLoop()
        else CollectRunning = false end
    end
})

Main6:Section({ Title = "Setting Collect", Icon = "settings" })

CollectItemDropdown = Main6:Dropdown({
    Title = "Item Collect", Values = CollectItems, Multi = true, Value = SelectedCollectItems,
    Callback = function(values) SelectedCollectItems = values or {}; Config:Set("SelectedCollectItems", values); Config:Save() end
})

CollectModeDropdown = Main6:Dropdown({
    Title = "Mode Collect", Values = { "Clean", "IDGF" }, Multi = false, Value = CollectMode,
    Callback = function(value) CollectMode = value; Config:Set("CollectMode", value); Config:Save() end
})

-- ============================================================
-- ====================== UI: SETTING TAB =====================
-- ============================================================

-- ── SERVER STATS PANEL ──────────────────────────────────────
Main3:Section({ Title = "Server Stats", Icon = "server" })

local ServerStatsPanel = Main3:Paragraph({
    Title   = "[ Server Stats ]  ·  Loading...",
    Content = "Fetching server information...",
})

local function GetServerPing()
    local ok, val = pcall(function()
        return math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    return ok and val or 0
end

local function GetMemoryUsageMB()
    local ok, val = pcall(function() return math.floor(StatsService:GetTotalMemoryUsageMb()) end)
    return ok and val or 0
end

local function GetMobCount()
    local living = workspace:FindFirstChild("Living")
    if not living then return 0 end
    local count = 0
    for _, obj in ipairs(living:GetChildren()) do if IsValidMob(obj) then count = count + 1 end end
    return count
end

local function RefreshServerStats()
    pcall(function()
        local playerList  = Players:GetPlayers()
        local playerCount = #playerList
        local playerNames = {}
        for _, pl in ipairs(playerList) do
            table.insert(playerNames, (pl == LocalPlayer) and ("★ " .. pl.Name) or pl.Name)
        end

        local ping    = GetServerPing()
        local memMB   = GetMemoryUsageMB()
        local mobCnt  = GetMobCount()
        local uptime  = FarmStats_GetUptime()
        local kpm     = FarmStats_GetKPM()
        local hp, maxHp = GetPlayerHPInfo()
        local hpPct   = maxHp > 0 and math.floor((hp/maxHp)*100) or 0
        local jobId   = game.JobId ~= "" and game.JobId:sub(1,18) .. "..." or "N/A"
        local serverTime = math.floor(workspace.DistributedGameTime)

        local pingLabel = ping < 80 and "● Excellent" or ping < 150 and "● Good" or ping < 250 and "● Fair" or "● Poor"

        local content = table.concat({
            "══════════ Server ══════════",
            string.format("  Place ID     : %s", tostring(game.PlaceId)),
            string.format("  Job ID       : %s", jobId),
            string.format("  Server Time  : %02d:%02d:%02d", math.floor(serverTime/3600), math.floor((serverTime%3600)/60), serverTime%60),
            string.format("  Ping         : %d ms  %s", ping, pingLabel),
            string.format("  Memory       : %d MB", memMB),
            "══════════ Players ══════════",
            string.format("  Online       : %d player%s", playerCount, playerCount ~= 1 and "s" or ""),
            string.format("  List         : %s", #playerNames > 0 and table.concat(playerNames, ", ") or "—"),
            "══════════ Mobs ══════════",
            string.format("  Alive        : %d mobs in wave", mobCnt),
            "══════════ Farm Session ══════════",
            string.format("  Uptime       : %s", uptime),
            string.format("  Kills        : %d  |  KPM: %s", FarmStats.KillCount, kpm),
            string.format("  Waves        : %d  |  Interrupts: %d", FarmStats.WaveCount, FarmStats.InterruptCount),
            string.format("  Deaths       : %d  |  Rejoins: %d", FarmStats.DeathCount, FarmStats.RejoinCount),
            string.format("  Player HP    : %d / %d  (%d%%)", math.floor(hp), math.floor(maxHp), hpPct),
            "══════════ Systems ══════════",
            string.format("  Farm         : %s", AutoFarmEnabled and "● Running" or "○ Stopped"),
            string.format("  Watchdog     : %s", (WatchdogEnabled and WatchdogThread ~= nil) and "● Active" or "○ Off"),
            string.format("  SmartRejoin  : %s  (err: %d/%d)", SmartRejoinEnabled and "● On" or "○ Off", _rejoinErrorCount, SmartRejoinMax),
            string.format("  Webhook      : %s", WebhookEnabled and "● On" or "○ Off"),
        }, "\n")

        ServerStatsPanel:Set({
            Title   = string.format("[ Server Stats ]  ·  %d Players  ·  Ping: %dms", playerCount, ping),
            Content = content,
        })
    end)
end

-- auto-refresh ทุก 5s
task.spawn(function()
    while true do task.wait(5); RefreshServerStats() end
end)

Main3:Button({
    Title = "Refresh Stats (NOW)",
    Callback = function()
        RefreshServerStats()
        Notify("Server Stats", "Refreshed!", 2, "server", "stats_refresh")
    end
})

Main3:Divider()

-- ── SAVE CONFIG ─────────────────────────────────────────────
Main3:Section({ Title = "Save Config", Icon = "save" })

Main3:Button({
    Title = "Save Config (NOW)",
    Callback = function()
        Config:Save()
        Notify("Config Saved", "Config saved successfully!", 2, "save", "config_save")
    end
})

local AutoSaveEnabled = Config:Get("AutoSaveEnabled", true)
local AutoSaveDelay   = Config:Get("AutoSaveDelay", 15)
local AutoSaveThread  = nil

local function RestartAutoSave()
    if AutoSaveThread then task.cancel(AutoSaveThread); AutoSaveThread = nil end
    if AutoSaveEnabled then
        AutoSaveThread = task.spawn(function()
            while AutoSaveEnabled do task.wait(AutoSaveDelay); Config:Save() end
        end)
    end
end
RestartAutoSave()

Main3:Toggle({
    Title = "Auto Save Config", Value = AutoSaveEnabled,
    Callback = function(state) AutoSaveEnabled = state; Config:Set("AutoSaveEnabled", state); Config:Save(); RestartAutoSave() end
})

Main3:Input({
    Title = "Delay Save Config", Default = tostring(AutoSaveDelay), Placeholder = "Default: 15",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 then AutoSaveDelay = num; Config:Set("AutoSaveDelay", num); Config:Save(); RestartAutoSave() end
    end
})

-- ── SMART REJOIN ─────────────────────────────────────────────
Main3:Section({ Title = "Smart Rejoin", Icon = "refresh-cw" })

Main3:Toggle({
    Title = "Smart Rejoin (Auto)", Value = SmartRejoinEnabled,
    Callback = function(state) SmartRejoinEnabled = state; Config:Set("SmartRejoinEnabled", state); Config:Save() end
})

Main3:Slider({
    Title = "Max Errors Before Rejoin", Value = { Min = 1, Max = 20, Default = SmartRejoinMax }, Step = 1,
    Callback = function(value) SmartRejoinMax = value; Config:Set("SmartRejoinMax", value); Config:Save() end
})

Main3:Toggle({
    Title = "Auto Rejoin (Teleport Fail)", Value = AutoRejoinEnabled,
    Callback = function(state) AutoRejoinEnabled = state; Config:Set("AutoRejoinEnabled", state); Config:Save() end
})

Main3:Button({
    Title = "Reset Error Count",
    Callback = function()
        SmartRejoin_ResetCount()
        Notify("SmartRejoin", "Error count reset to 0.", 2, "refresh-cw", "rejoin_reset")
    end
})

-- ── DISCORD WEBHOOK LOGGER ───────────────────────────────────
Main3:Section({ Title = "Discord Webhook Logger", Icon = "send" })

Main3:Paragraph({
    Title = "ℹ Webhook Info",
    Content = "ส่ง Farm Stats ไปยัง Discord Webhook อัตโนมัติ\nกรอก Webhook URL ก่อน แล้ว toggle เปิด",
})

Main3:Input({
    Title = "Webhook URL", Placeholder = "https://discord.com/api/webhooks/...",
    Default = WebhookURL,
    Callback = function(text)
        WebhookURL = text; Config:Set("WebhookURL", text); Config:Save()
        if WebhookEnabled then StartWebhookLoop() end
    end
})

Main3:Slider({
    Title = "Log Interval (minutes)", Value = { Min = 5, Max = 120, Default = WebhookInterval }, Step = 5,
    Callback = function(value) WebhookInterval = value; Config:Set("WebhookInterval", value); Config:Save()
        if WebhookEnabled then StartWebhookLoop() end
    end
})

Main3:Toggle({
    Title = "Enable Webhook Logger", Value = WebhookEnabled,
    Callback = function(state)
        WebhookEnabled = state; Config:Set("WebhookEnabled", state); Config:Save()
        if state then StartWebhookLoop() else
            if WebhookThread then task.cancel(WebhookThread); WebhookThread = nil end
        end
    end
})

Main3:Button({
    Title = "Send Report Now",
    Callback = function()
        if WebhookURL == "" then
            Notify("Webhook Error", "Please set a Webhook URL first.", 3, "alert-triangle", "webhook_err")
            return
        end
        SendWebhookLog()
        Notify("Webhook", "Report sent to Discord!", 2, "send", "webhook_send")
        FarmLog_Push("◈ Webhook: Manual report sent", "Sys")
    end
})

-- ── SERVER STATUS ────────────────────────────────────────────
Main3:Section({ Title = "Server Status", Icon = "server" })

Main3:Button({
    Title = "Serverhop",
    Callback = function()
        local servers = {}
        local ok, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        end)
        if ok and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end
        end
        if #servers > 0 then
            Notify("Serverhop", "Teleporting to another server...", 2, "server", "serverhop")
            task.wait(1)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            Notify("Serverhop Failed", "No available servers found.", 3, "alert-triangle", "serverhop_fail")
        end
    end
})

Main3:Button({
    Title = "Rejoin",
    Callback = function()
        Notify("Rejoin", "Rejoining server...", 2, "refresh-cw", "rejoin")
        task.wait(1)
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end
})

-- ── MISCELLANEOUS ────────────────────────────────────────────
Main3:Section({ Title = "Miscellaneous", Icon = "settings" })

NoBarrierToggle = Main3:Toggle({
    Title = "Bypass Barrier (PATCHED)", Value = noBarrierActive,
    Callback = function(value)
        noBarrierActive = value; Config:Set("NoBarrier", value); Config:Save()
        if value then startNoBarrier() else stopNoBarrier() end
    end
})

Main3:Toggle({
    Title = "Watchdog (Farm Safety)", Value = WatchdogEnabled,
    Callback = function(state)
        WatchdogEnabled = state; Config:Set("WatchdogEnabled", state); Config:Save()
        if state and AutoFarmEnabled then StartWatchdog()
        elseif not state and WatchdogThread then task.cancel(WatchdogThread); WatchdogThread = nil end
    end
})

Main3:Toggle({
    Title = "Anti AFK", Value = hi1,
    Callback = function(enabled)
        hi1 = enabled; Config:Set("antiafk_enabled", enabled); Config:Save()
        if AntiAFKConnection then AntiAFKConnection:Disconnect(); AntiAFKConnection = nil end
        if enabled then
            AntiAFKConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            task.spawn(function()
                while hi1 do
                    pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
                    task.wait(60)
                end
            end)
        end
    end
})

-- ── NOTIFICATION THROTTLE CONFIG ────────────────────────────
Main3:Slider({
    Title = "Notify Throttle (seconds)", Value = { Min = 1, Max = 30, Default = _notifyThrottleSec }, Step = 1,
    Callback = function(value) _notifyThrottleSec = value end
})

-- ============================================================
-- =================== AUTO START ON LOAD ====================
-- [FIX v023.6] ทุกระบบใช้ thread handle — ไม่มี duplicate
-- ============================================================
task.spawn(function()
    task.wait(2)

    if AutoFarmEnabled then
        FarmLog_Push("◈ Auto Farm: Restored from config — starting...", "Sys")
        StartFarmLoop()
        HandleMiscOptions(MiscOptions)
        -- [FIX v023.6] StartWatchdog ที่นี่ที่เดียว ไม่ spawn ซ้ำ
        StartWatchdog()
    end

    if noBarrierActive then startNoBarrier() end

    if ESP.Enabled then StartESPLoop() end

    -- [FIX v023.6] AutoBuy ใช้ helper function ที่มี guard ป้องกัน duplicate
    if AutoBuyWeaponToggleEnabled then StartAutoBuyWeapon() end
    if AutoBuyMiscToggleEnabled   then StartAutoBuyMisc()   end

    if AutoCollectEnabled then StartAutoCollectLoop() end

    if AutoVoteEnabled or AutoStartEnabled then RefreshVoteAndStartSetup() end
    if AutoVoteinGameEnabled then SetupAutoVote_InGame(true) end

    if WebhookEnabled then StartWebhookLoop() end

    -- Anti AFK restore
    if hi1 then
        if AntiAFKConnection then AntiAFKConnection:Disconnect(); AntiAFKConnection = nil end
        AntiAFKConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
        end)
        task.spawn(function()
            while hi1 do
                pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
                task.wait(60)
            end
        end)
    end

    -- initial server stats
    RefreshServerStats()

    FarmLog_Push(string.format("◈ DYHUB %s loaded — All systems online!", ver), "Sys")
    FarmLog_Push(string.format("◈ Watchdog: %s  |  Anti-AFK: %s  |  SmartRejoin: %s",
        WatchdogEnabled and "On" or "Off",
        hi1 and "On" or "Off",
        SmartRejoinEnabled and "On" or "Off"), "Info")
    FarmLog_Push(string.format("◈ Webhook: %s  |  Version: %s  |  User: %s",
        WebhookEnabled and "On" or "Off", userversion, LocalPlayer.Name), "Info")
end)

print("[DYHUB] Version " .. version .. " " .. ver .. " loaded successfully!")
print("[DYHUB] Config system active | Auto saving every 15 seconds")
