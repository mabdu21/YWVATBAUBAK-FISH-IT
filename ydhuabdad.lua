-- v043
-- =========================
local version = "Rework"
local ver = "v021.6"
-- =========================

-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ====================== GameLoad ======================
repeat task.wait() until game:IsLoaded()

-- ====================== LoadingGui ======================
local p = game:GetService("Players").LocalPlayer
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
local part = Instance.new("Part")
part.Size = Vector3.new(10, 1, 10)
part.Position = Vector3.new(-23.3435822, 61, 0.341766357)
part.Transparency = 1
part.Anchored = true
part.CanCollide = true
part.Material = Enum.Material.Neon
part.BrickColor = BrickColor.new("Bright blue")
part.Name = "DYHUB_WAITING_PART"
part.Parent = workspace

if setfpscap then
    setfpscap(1000000)
    WindUI:Notify({ Title = "Service", Content = "FPS Unlocked! | " .. ver, Duration = 3, Icon = "cpu" })
    warn("FPS Unlocked!")
else
    WindUI:Notify({ Title = "Not Working", Content = "Your exploit does not support setfpscap.", Duration = 3, Icon = "ban" })
end

-- ====================== CUSTOM CONFIG SYSTEM ======================
local HttpService = game:GetService("HttpService")
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
    local success, err = pcall(function()
        writefile(self.ConfigPath, HttpService:JSONEncode(self.ConfigData))
    end)
    if success then print("[DYHUB] Config saved!") else warn("[DYHUB] Save failed:", err) end
end

function CustomConfig:Load()
    if isfile(self.ConfigPath) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(self.ConfigPath))
        end)
        if success and type(result) == "table" then
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
    task.spawn(function()
        while true do
            task.wait(interval or 15)
            self:Save()
        end
    end)
end

local Config = CustomConfig.new()
Config:AutoSave(15)

-- ====================== WINDOW 2 ======================
local Players = game:GetService("Players")

local FreeVersion = "Free Version"
local PremiumVersion = "Premium Version"
local ExtraVersion = "Extra Version"

local function getData(url)
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then return nil end
    local func = loadstring(response)
    if func then return func() end
    return nil
end

local function checkVersion(playerName)
    local extraData = getData("https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/STBBList.lua")
    if extraData and extraData[playerName] then return ExtraVersion end
    local premiumData = getData("https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua")
    if premiumData and premiumData[playerName] then return PremiumVersion end
    return FreeVersion
end

local player = Players.LocalPlayer
local userversion = checkVersion(player.Name)

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
MainDivider  = Window:Divider()
local Main   = Window:Tab({ Title = "Main", Icon = "rocket" })
local Main4  = Window:Tab({ Title = "Esp", Icon = "eye" })
local Main2  = Window:Tab({ Title = "Player", Icon = "user" })
MainDivider1 = Window:Divider()
local Main5  = Window:Tab({ Title = "Shop", Icon = "shopping-cart" })
local Main6  = Window:Tab({ Title = "Collect", Icon = "hand" })
local Main7  = Window:Tab({ Title = "Gamemode", Icon = "gamepad-2" })
MainDivider2 = Window:Divider()
local Main3  = Window:Tab({ Title = "Setting", Icon = "settings" })
Window:SelectTab(1)

-- ======================== INFO ========================
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

Info:Section({ Title = "Lasted Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({
    Title = "Update: 06/05/2026",
    Desc = "- [ Fixed ] Auto Vote & Start Sync\n- [ Improved ] Auto Vote & Start loop on respawn",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
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

local InviteCode = "jWNDPNMmyB"
local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local function LoadDiscordInfo()
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
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- ====================== PLAYER ======================
local LocalPlayer = Players.LocalPlayer
local Client = LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ====================== GLOBAL TABLES ======================
GlobalTables = {
    redeemCodes = { "100MVisit2", "100MVisit1", "CamArmada", "CCTVBase", "ADelayedGameIsEventuallyGoodButRushedGameIsForeverBad" },
    Mode  = { "Normal Mode", "Vague Memory", "Extreme Mode", "Hard Mode", "Insane Mode", "Nightmare Mode", "Boss Rush", "Dark Dimension", "Hell", "Mist", "Christmas Act 1", "Zombie Act 1", "Holdout", "Invasion" },
    Votes = {
        "Normal",
        "100MVisit",
        "VeryHard",
        "Hard",
        "Insane",
        "Nightmare",
        "BossRush",
        "DarkDimension",
        "Hell",
        "ThunderStorm",
        "Christmas",
        "Zombie",
        "AstroV2",
        "Astro"
    },
    Weapon = { "Stungun", "Flamethrower", "Harpoon Gun", "Shot Gun", "Pulse Rifle", "Shot Harpoon Gun", "EPD", "Small Laser Gun" },
    MiscShop = { "HeadPhone", "Titan-Request", "SpecialTitan-Request", "Speaker-Request", "Grenade", "Jetpack", "Lens" },
}

-- ====================== CONFIG VARIABLES ======================
local skillList = { "Q", "E", "R", "T", "Y", "G", "H", "Z", "X", "C", "V", "B", "U" }
local skillDropdownValues = { "All", "Q", "E", "R", "T", "Y", "G", "H", "Z", "X", "C", "V", "B", "U" }

-- ====================== STATE VARIABLES ======================
local AutoFarmEnabled        = Config:Get("AutoFarmEnabled", false)
local FarmPosition           = Config:Get("FarmPosition", "Above")
local FarmMode               = Config:Get("FarmMode", "Tween")
local MiscOptions            = Config:Get("MiscOptions", {})
local AutoAttackEnabled      = false
local AutoSkillEnabled       = false
local AutoSkipHeliEnabled    = false
local DeleteMapEnabled       = false
local AutoStartEnabled       = false
local AutoFillUpEnabled      = false
local SelectedSkills         = Config:Get("SelectedSkills", { "All" })
local SafeModeEnabled        = false
local SafeValue              = Config:Get("SafeValue", 30)
local WaitingRespawn         = false
local IdlePosition           = CFrame.new(-23.3435822, 67, 0.341766357) * CFrame.Angles(math.rad(0), 0, 0)
local SkillDelay             = Config:Get("SkillDelay", 1)
local LoopDelay              = 0.5
local TweenSpeed             = 1
local HeightValue            = Config:Get("HeightValue", 3)
local NeedNoClip             = false
local LockActive             = false
local AutoStartConnection    = nil
local noBarrierConnection    = nil
local noBarrierActive        = Config:Get("NoBarrier", false)

local VirtualUser = game:GetService("VirtualUser")
local hi2 = Config:Get("hi2", true)
local hi1 = Config:Get("hi2", true)

local AutoBuyWeaponEnabled   = Config:Get("AutoBuyWeaponEnabled", false)
local AutoBuyMiscEnabled     = Config:Get("AutoBuyMiscEnabled", false)
local SelectedWeapon         = Config:Get("SelectedWeapon", "Stungun")
local SelectedMiscItem       = Config:Get("SelectedMiscItem", "HeadPhone")

-- ====================== FILL UP PART CONFIG ======================
local FILLUP_PART_PATH   = { "HelicopterShop", "ShopXDD", "PartForShop" }
local FILLUP_TARGET_POS  = Vector3.new(44.2756729, 26.3595276, -32.7318268)
local FILLUP_POS_THRESHOLD = 0.5
local FillUpRunning = false

local function GetFillUpPart()
    local obj = workspace
    for _, key in ipairs(FILLUP_PART_PATH) do
        obj = obj:FindFirstChild(key)
        if not obj then return nil end
    end
    return obj
end

local function IsFillUpPartReady()
    local p = GetFillUpPart()
    if not p then return false end
    return (p.CFrame.Position - FILLUP_TARGET_POS).Magnitude < FILLUP_POS_THRESHOLD
end

-- ====================== ALLY SYSTEM ======================
local AllyNames = {
    ["Heavy Soldier Toilet V2"]  = true,
    ["Quad Laser Toilet"]        = true,
    ["Strider Rocket Laser"]     = true,
    ["Helicopter Camera"]        = true,
    ["Heavy Soldier Toilet V1"]  = true,
    ["Rocket Heli v2"]           = true,
}

local function IsAlly(mob)
    return AllyNames[mob.Name] ~= nil
end

-- ====================== TP SYSTEM ======================
function tp(pu79)
    pcall(function()
        local v80 = Client
        if v80 then v80 = Client.Character end
        if v80:FindFirstChild("Humanoid") and v80.Humanoid.Sit == true then v80.Humanoid.Sit = false end
        NeedNoClip = true
        local v81 = { Target = pu79.Target or print("mae mung tai."), Mod = pu79.Mod or CFrame.new(0, 0, 0) }
        v80:FindFirstChild("HumanoidRootPart").CFrame = v81.Target * v81.Mod
    end)
end

function Tp(p82)
    if Client.Character.Humanoid.Sit == true then Client.Character.Humanoid.Sit = false end
    local v83, v84, v85 = pairs(Client.Character:GetDescendants())
    while true do
        local v86
        v85, v86 = v83(v84, v85)
        if v85 == nil then break end
        if v86:IsA("BasePart") then v86.CanCollide = false end
    end
    if not Client.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
        local v87 = Instance.new("BodyVelocity")
        v87.Parent = Client.Character.HumanoidRootPart
        v87.Name = "BodyClip"
        v87.Velocity = Vector3.new(0, 0, 0)
        v87.MaxForce = Vector3.new(5, math.huge, 5)
    end
    Client.Character.HumanoidRootPart.CFrame = p82
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
local function IsValidMob(obj)
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
        if Players:GetPlayerFromCharacter(obj) then return false end
        if IsAlly(obj) then return false end
        local humanoid = obj:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then return true end
    end
    return false
end

local function IsMobDead(mob)
    if not mob or not mob.Parent then return true end
    local humanoid = mob:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return true end
    return false
end

local function GetMobSize(mob)
    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return 4 end
    local _, size = mob:GetBoundingBox()
    return size.Y
end

-- ====================== MOB SELECTION ======================
local function GetNearestMob()
    local nearestMob, nearestDist = nil, math.huge
    local livingFolder = workspace:FindFirstChild("Living")
    if not livingFolder then return nil end
    for _, mob in ipairs(livingFolder:GetChildren()) do
        if IsValidMob(mob) then
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            if mobRoot then
                local d = (HumanoidRootPart.Position - mobRoot.Position).Magnitude
                if d < nearestDist then nearestDist = d; nearestMob = mob end
            end
        end
    end
    return nearestMob
end

local function GetHighestMob()
    local highestMob, highestY = nil, -math.huge
    local livingFolder = workspace:FindFirstChild("Living")
    if not livingFolder then return nil end
    local myY = HumanoidRootPart and HumanoidRootPart.Position.Y or 0
    for _, mob in ipairs(livingFolder:GetChildren()) do
        if IsValidMob(mob) then
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            if mobRoot then
                local mobY = mobRoot.Position.Y
                if mobY > myY and mobY > highestY then highestY = mobY; highestMob = mob end
            end
        end
    end
    return highestMob
end

-- ====================== PRIORITY SYSTEM ======================
local function GetHelicopter()
    local livingFolder = workspace:FindFirstChild("Living")
    if not livingFolder then return nil end
    local heli = livingFolder:FindFirstChild("Helicopter")
    if heli and IsValidMob(heli) then return heli end
    return nil
end

local function GetGiantSTToilet()
    local livingFolder = workspace:FindFirstChild("Living")
    if not livingFolder then return nil end
    local giant = livingFolder:FindFirstChild("Giant ST toilet")
    if giant and IsValidMob(giant) then
        local lever = giant:FindFirstChild("lever")
        if lever then
            local prompt = lever:FindFirstChildOfClass("ProximityPrompt")
            if prompt then return giant, prompt end
        end
    end
    return nil, nil
end

local function ActivateProximityPrompt(prompt)
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 50
        if fireproximityprompt then fireproximityprompt(prompt) end
        prompt:InputHoldBegin()
        task.wait(0.05)
        prompt:InputHoldEnd()
    end)
end

local function ActivateAllFlushPrompts()
    pcall(function()
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Model") then
                local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    local actionText = prompt.ActionText:lower()
                    if actionText:find("flush") or actionText:find("flash") or actionText:find("dragon") then
                        ActivateProximityPrompt(prompt)
                    end
                end
            end
        end
    end)
end

local function GetPriorityMob()
    local heli = GetHelicopter()
    if heli then return heli, "Helicopter" end
    local giant, prompt = GetGiantSTToilet()
    if giant and prompt then return giant, "GiantST", prompt end
    local highMob = GetHighestMob()
    if highMob then return highMob, "HighMob" end
    local nearMob = GetNearestMob()
    if nearMob then return nearMob, "NearestMob" end
    return nil, nil
end

-- ============================================================
-- ====================== MOB VISUAL BOUNDS ===================
-- ============================================================

local function GetMobVisualBounds(mob)
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

-- ============================================================
-- ====================== MOB HEIGHT OVERRIDE =================
-- ============================================================

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
    if position == "Above" then
        local visualHeight = maxY - minY
        local floor = -(visualHeight) + PLAYER_HALF_HEIGHT + ANTI_CLIP_MARGIN
        return floor
    elseif position == "Under" then
        local visualHeight = maxY - minY
        local floor = -(visualHeight) + PLAYER_HALF_HEIGHT + ANTI_CLIP_MARGIN
        return floor
    end
    return ANTI_CLIP_MARGIN
end

local function GetEffectivePadding(mob)
    if MobConfirmedPadding[mob] ~= nil then
        return MobConfirmedPadding[mob]
    end
    if MobHeightOverride[mob] ~= nil then
        return MobHeightOverride[mob]
    end
    return HeightValue
end

local function ClampPaddingToAntiClip(mob, padding)
    local antiFloor = GetAntiClipFloor(mob, FarmPosition)
    local clamped = math.max(padding, antiFloor)
    clamped = math.max(clamped, PADDING_SAFE_MIN)
    return clamped
end

local function StartDamageChecker(mob)
    task.spawn(function()
        local humanoid = mob and mob:FindFirstChild("Humanoid")
        if not humanoid then return end

        if MobConfirmedPadding[mob] ~= nil then
            print("[DYHUB] DmgCheck: Using confirmed padding " .. MobConfirmedPadding[mob] .. " for " .. mob.Name)
            return
        end

        MobLastHealth[mob]     = humanoid.Health
        MobHeightOverride[mob] = ClampPaddingToAntiClip(mob, MobHeightOverride[mob] or HeightValue)

        local lastDamageTime   = tick()
        local noDamageTimer    = 0
        local hitStreak        = 0
        local lastWasHit       = false
        local reducedOnce      = false

        print("[DYHUB] DmgCheck v3: Start for " .. mob.Name .. " | init padding=" .. GetEffectivePadding(mob))

        while mob and mob.Parent and not IsMobDead(mob) and AutoFarmEnabled do
            task.wait(0.3)

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

                if lastWasHit then
                    hitStreak = hitStreak + 1
                else
                    hitStreak = 1
                end
                lastWasHit = true

                local curPad = GetEffectivePadding(mob)
                print("[DYHUB] HIT! dmg=" .. math.floor(dmgDealt) .. " streak=" .. hitStreak .. " pad=" .. curPad .. " mob=" .. mob.Name)

                if dmgDealt >= DMG_THRESHOLD and MobConfirmedPadding[mob] == nil then
                    MobConfirmedPadding[mob] = curPad
                    MobHeightOverride[mob]   = curPad
                    print("[DYHUB] ✅ CONFIRMED (threshold dmg=" .. math.floor(dmgDealt) .. "≥" .. DMG_THRESHOLD .. ") pad=" .. curPad .. " for " .. mob.Name)
                    break
                end

                if hitStreak >= 2 and MobConfirmedPadding[mob] == nil then
                    MobConfirmedPadding[mob] = curPad
                    MobHeightOverride[mob]   = curPad
                    print("[DYHUB] ✅ CONFIRMED (streak=" .. hitStreak .. ") pad=" .. curPad .. " for " .. mob.Name)
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
                local rawNew = curPad - PADDING_REDUCE_STEP
                local newPad = ClampPaddingToAntiClip(mob, rawNew)
                if newPad ~= curPad then
                    MobHeightOverride[mob] = newPad
                    print("[DYHUB] ↓ no-hit 2s → pad " .. curPad .. " → " .. newPad .. " (" .. mob.Name .. ")")
                else
                    print("[DYHUB] ⛔ anti-clip floor hit at pad=" .. curPad .. " - stop reduce (" .. mob.Name .. ")")
                end
            end

            if noDamageTimer >= 6 then
                lastDamageTime = tick()
                reducedOnce    = false
                local curPad = GetEffectivePadding(mob)
                local rawNew = curPad - PADDING_REDUCE_STEP
                local newPad = ClampPaddingToAntiClip(mob, rawNew)
                if newPad ~= curPad then
                    MobHeightOverride[mob] = newPad
                    print("[DYHUB] ↓↓ no-hit → pad " .. curPad .. " → " .. newPad .. " (" .. mob.Name .. ")")
                else
                    print("[DYHUB] ⛔ anti-clip floor - padding to floor then, stop (" .. mob.Name .. ")")
                end
            end

            MobLastHealth[mob] = currentHP
        end

        MobHeightOverride[mob] = nil
        MobLastHealth[mob]     = nil
        print("[DYHUB] DmgCheck: Done for " .. (mob and mob.Name or "?"))
    end)
end

local function ResetMobOverride(mob)
    MobHeightOverride[mob]   = nil
    MobConfirmedPadding[mob] = nil
    MobLastHealth[mob]       = nil
end

-- ============================================================
-- ====================== TARGET CFRAME =======================
-- ============================================================

local function GetTargetCFrame(mob, position)
    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return nil end

    local padding     = GetEffectivePadding(mob)
    local center, minY, maxY = GetMobVisualBounds(mob)

    if position == "Above" then
        local targetPos = Vector3.new(center.X, maxY + padding, center.Z)
        local lookAt    = Vector3.new(center.X, maxY, center.Z)
        local lookCF    = CFrame.new(targetPos, lookAt)
        return lookCF * CFrame.Angles(math.rad(-10), 0, 0)

    elseif position == "Under" then
        local targetPos = Vector3.new(center.X, minY - padding, center.Z)
        local lookAt    = Vector3.new(center.X, minY, center.Z)
        local lookCF    = CFrame.new(targetPos, lookAt)
        return lookCF * CFrame.Angles(math.rad(10), 0, 0)
    end
end

local function TeleportToMob(mob)
    local cf = GetTargetCFrame(mob, FarmPosition)
    if not cf then return end
    if FarmMode == "Tween" then
        local tweenInfo = TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(HumanoidRootPart, tweenInfo, { CFrame = cf })
        tween:Play()
        tween.Completed:Wait()
    elseif FarmMode == "tp" then
        tp({ Target = cf, Mod = CFrame.new(0, 0, 0) })
    elseif FarmMode == "Tp" then
        Tp(cf)
    elseif FarmMode == "tp1" then
        tp1(cf)
    end
end

local function LockToMob(mob)
    LockActive = true
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not AutoFarmEnabled or IsMobDead(mob) or not LockActive then
            connection:Disconnect()
            LockActive = false
            return
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

-- ====================== AUTO LOOPS ======================
local function StartAutoAttack()
    task.spawn(function()
        while AutoAttackEnabled and AutoFarmEnabled do
            local mob = GetPriorityMob()
            if mob and not WaitingRespawn then
                pcall(function() ReplicatedStorage.LMB:FireServer() end)
            end
            task.wait(0.05)
        end
    end)
end

local function StartAutoSkill()
    task.spawn(function()
        while AutoSkillEnabled and AutoFarmEnabled do
            local mob = GetPriorityMob()
            if mob and not WaitingRespawn then
                local keysToPress = {}
                if table.find(SelectedSkills, "All") then
                    keysToPress = skillList
                else
                    keysToPress = SelectedSkills
                end
                for _, key in ipairs(keysToPress) do
                    if not AutoSkillEnabled or not AutoFarmEnabled then break end
                    local keyCode = Enum.KeyCode[key]
                    if keyCode then
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                        end)
                        task.wait(SkillDelay)
                    end
                end
            end
            task.wait(LoopDelay)
        end
    end)
end

local function TriggerAutoSkipHeli(state)
    pcall(function() ReplicatedStorage.SetSettingAutoSkipWave:FireServer(state) end)
end

local function DeleteMapTextures()
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            elseif obj:IsA("MeshPart") then
                obj.TextureID = ""
            elseif obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            elseif obj:IsA("Part") or obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
    end)
end

-- ====================== PLAYER HP HELPERS ======================
local function GetPlayerHPInfo()
    local humanoid = Character and Character:FindFirstChild("Humanoid")
    if not humanoid then return 100, 100 end
    return humanoid.Health, humanoid.MaxHealth
end

local function IsPlayerHPFull()
    local hp, maxHp = GetPlayerHPInfo()
    if maxHp <= 0 then return true end
    return hp >= maxHp
end

-- ====================== AUTO FILL UP ======================
local function DoFillUp()
    for i = 1, 2 do
        pcall(function()
            ReplicatedStorage.ShopSystem:FireServer("Buy", "FillHP")
        end)
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
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.Health = humanoid.MaxHealth end
            end
        end)
    end)
end

local function stopNoBarrier()
    if noBarrierConnection then
        noBarrierConnection:Disconnect()
        noBarrierConnection = nil
    end
end

-- ============================================================
-- ====================== AUTO VOTE MODE v3 ===================
-- [FIX v021.4]
--   • Dropdown เลือกค่าเฉยๆ ไม่ยิง FireServer
--   • Toggle เท่านั้นที่ trigger การทำงาน
--   • Auto Vote + Auto Start Sync:
--     ถ้าเปิดทั้งคู่ → ยิง vote → รอ 2.5s → ยิง start
--     รอ respawn แล้วลูปใหม่
--   • ถ้าเปิดแค่อันเดียว ทำงานแยกของมัน
-- ============================================================

local AutoVoteEnabled       = Config:Get("AutoVoteEnabled", false)
local AutoVoteValue         = Config:Get("AutoVoteValue", "Normal Mode")
local AutoVoteinGameEnabled = Config:Get("AutoVoteinGameEnabled", false)
local AutoVoteValue2        = Config:Get("AutoVoteValue2", "Normal")

-- Connection handles
local _voteRespawnConn    = nil
local _voteIGRespawnConn  = nil
local _syncRespawnConn    = nil

-- ─── Helper: ยิง Vote Solo (ใช้ค่า AutoVoteValue ปัจจุบัน) ───
local function FireVote_Solo()
    if not AutoVoteValue then return end
    pcall(function()
        ReplicatedStorage.MainHandler:FireServer({ [1] = "StartSolo", [2] = AutoVoteValue })
    end)
    print("[DYHUB] AutoVote Solo fired: " .. tostring(AutoVoteValue))
end

-- ─── Helper: ยิง GetReady (Auto Start) ───
local function FireGetReady()
    task.wait(2.5)
    pcall(function() ReplicatedStorage.GetReadyRemote:FireServer("1", true) end)
    print("[DYHUB] AutoStart fired")
end

-- ─── Helper: ยิง Vote InGame ───
local function FireVote_InGame()
    if not AutoVoteValue2 then return end
    pcall(function()
        ReplicatedStorage.Vote:FireServer(AutoVoteValue2)
    end)
    print("[DYHUB] AutoVote IG fired: " .. tostring(AutoVoteValue2))
end

-- ────────────────────────────────────────────────────────────
-- SYNC MODE: Auto Vote Solo + Auto Start ทั้งคู่เปิด
-- ลำดับ: FireVote → รอ 2.5s → FireStart → รอ respawn → loop
-- ────────────────────────────────────────────────────────────
local function SetupSyncVoteAndStart()
    -- ตัด connection เก่าทั้งหมดก่อน
    if _voteRespawnConn then _voteRespawnConn:Disconnect(); _voteRespawnConn = nil end
    if _syncRespawnConn then _syncRespawnConn:Disconnect(); _syncRespawnConn = nil end

    -- ยิงครั้งแรก
    FireVote_Solo()
    task.spawn(function()
        task.wait(2.5)
        if AutoVoteEnabled and AutoStartEnabled then
            FireGetReady()
        end
    end)

    -- รอ respawn แล้วยิงใหม่
    _syncRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1.5)
        if AutoVoteEnabled and AutoStartEnabled then
            FireVote_Solo()
            task.spawn(function()
                task.wait(2.5)
                if AutoVoteEnabled and AutoStartEnabled then
                    FireGetReady()
                end
            end)
        end
    end)
    print("[DYHUB] Sync Mode: AutoVote + AutoStart active")
end

-- ────────────────────────────────────────────────────────────
-- SOLO MODE: Auto Vote เปิดอย่างเดียว (ไม่มี Auto Start)
-- ────────────────────────────────────────────────────────────
local function SetupAutoVote_SoloOnly(enabled)
    if _voteRespawnConn then _voteRespawnConn:Disconnect(); _voteRespawnConn = nil end
    if not enabled then return end
    FireVote_Solo()
    _voteRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1.5)
        if AutoVoteEnabled and not AutoStartEnabled then
            FireVote_Solo()
        end
    end)
    print("[DYHUB] AutoVote Solo-only active")
end

-- ────────────────────────────────────────────────────────────
-- AUTO START ONLY: Auto Start เปิดอย่างเดียว (ไม่มี Auto Vote)
-- (เดิม) ยิง GetReady + รอ respawn loop
-- ────────────────────────────────────────────────────────────
local function SetupAutoStartOnly(enabled)
    if AutoStartConnection then AutoStartConnection:Disconnect(); AutoStartConnection = nil end
    if not enabled then return end
    FireGetReady()
    AutoStartConnection = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if AutoStartEnabled and not AutoVoteEnabled then
            task.spawn(FireGetReady)
        end
    end)
    print("[DYHUB] AutoStart-only active")
end

-- ────────────────────────────────────────────────────────────
-- MASTER SETUP: เรียกทุกครั้งที่ toggle เปลี่ยน
-- ────────────────────────────────────────────────────────────
local function RefreshVoteAndStartSetup()
    -- ล้าง connection ทั้งหมดก่อน
    if _voteRespawnConn   then _voteRespawnConn:Disconnect();   _voteRespawnConn   = nil end
    if _syncRespawnConn   then _syncRespawnConn:Disconnect();   _syncRespawnConn   = nil end
    if AutoStartConnection then AutoStartConnection:Disconnect(); AutoStartConnection = nil end

    if AutoVoteEnabled and AutoStartEnabled then
        -- ทั้งคู่เปิด → Sync Mode
        SetupSyncVoteAndStart()
    elseif AutoVoteEnabled and not AutoStartEnabled then
        -- Vote อย่างเดียว
        SetupAutoVote_SoloOnly(true)
    elseif not AutoVoteEnabled and AutoStartEnabled then
        -- Start อย่างเดียว
        SetupAutoStartOnly(true)
    else
        -- ทั้งคู่ปิด — ไม่ทำอะไร
        print("[DYHUB] AutoVote + AutoStart both off")
    end
end

-- ─── InGame Vote (แยกอิสระ ไม่ sync กับ AutoStart) ───
local function SetupAutoVote_InGame(enabled)
    if _voteIGRespawnConn then
        _voteIGRespawnConn:Disconnect()
        _voteIGRespawnConn = nil
    end
    if not enabled then return end
    FireVote_InGame()
    _voteIGRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1.5)
        if AutoVoteinGameEnabled then FireVote_InGame() end
    end)
end

-- ============================================================
-- ====================== AUTO START (Misc Farm Sync) =========
-- ใช้ RefreshVoteAndStartSetup แทน StartAutoStart/StopAutoStart เดิม
-- เพื่อ sync กับ AutoVote
-- ============================================================
local function StartAutoStart()
    AutoStartEnabled = true
    RefreshVoteAndStartSetup()
end

local function StopAutoStart()
    AutoStartEnabled = false
    RefreshVoteAndStartSetup()
end

-- ====================== TELEPORT TO IDLE ======================
local function TeleportToIdle()
    LockActive = false
    task.wait(0.1)
    WaitingRespawn = true
    pcall(function()
        Character:PivotTo(IdlePosition)
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function GetPlayerHealthPercent()
    local humanoid = Character and Character:FindFirstChild("Humanoid")
    if not humanoid then return 100 end
    if humanoid.MaxHealth <= 0 then return 100 end
    return (humanoid.Health / humanoid.MaxHealth) * 100
end

-- ============================================================
-- ====================== COLLECT SYSTEM ======================
-- ============================================================

local CollectItems = {
    "Clock Spider", "X-18 Core", "Green Energy Core", "Weird Transmitter",
    "Presents", "Weird Prism", "Key Card", "Zombie Core",
    "Flash Drives", "Astro Samples",
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

local AutoCollectEnabled    = Config:Get("AutoCollectEnabled", false)
local SelectedCollectItems  = Config:Get("SelectedCollectItems", {})
local CollectMode           = Config:Get("CollectMode", "Clean")

local KnownCollectItems = {}
local CollectRunning    = false

local function MatchesPattern(objectName, pattern)
    local objL, patL = objectName:lower(), pattern:lower()
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
    local targetCF  = CFrame.new(targetPos, itemRoot.Position)
    local tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear), { CFrame = targetCF })
    tween:Play()
    tween.Completed:Wait()
end

local function ActivateItemPrompts(obj)
    pcall(function()
        local function tryPrompt(target)
            for _, child in ipairs(target:GetDescendants()) do
                if child:IsA("ProximityPrompt") then
                    child.HoldDuration = 0; child.MaxActivationDistance = 50
                    if fireproximityprompt then fireproximityprompt(child) end
                    child:InputHoldBegin(); task.wait(0.05); child:InputHoldEnd()
                end
            end
        end
        tryPrompt(obj)
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
        local targetCF = CFrame.new(itemRoot.Position + Vector3.new(0, 3, 0), itemRoot.Position)
        if Character and HumanoidRootPart then
            Character:PivotTo(targetCF)
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
    local livingFolder = workspace:FindFirstChild("Living")
    if not livingFolder then return true end
    for _, mob in ipairs(livingFolder:GetChildren()) do
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
    print("[DYHUB] Collect: New item: " .. obj.Name)
end)

-- ====================== MAIN FARM LOOP ======================
local function StartFarmLoop()
    task.spawn(function()
        task.spawn(function()
            while AutoFarmEnabled do
                if WaitingRespawn and not LockActive then
                    pcall(function()
                        local tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear), { CFrame = IdlePosition })
                        tween:Play(); tween.Completed:Wait()
                        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                    end)
                end
                task.wait(0.1)
            end
        end)

        while AutoFarmEnabled do
            if not Character or not Character.Parent then
                Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                Client = LocalPlayer
            end

            local mob, mobType, extraData = GetPriorityMob()

            if mob then
                WaitingRespawn = false

                if mobType == "GiantST" and extraData then
                    local cf = GetTargetCFrame(mob, FarmPosition)
                    if cf then
                        if FarmMode == "Tween" then
                            local tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear), { CFrame = cf })
                            tween:Play(); tween.Completed:Wait()
                        else tp1(cf) end
                    end
                    local giantLockConn
                    giantLockConn = RunService.RenderStepped:Connect(function()
                        if IsMobDead(mob) or not mob.Parent or not AutoFarmEnabled then
                            giantLockConn:Disconnect(); return
                        end
                        local lockCF = GetTargetCFrame(mob, FarmPosition)
                        if lockCF and Character and HumanoidRootPart then
                            Character:PivotTo(lockCF)
                            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                        end
                    end)
                    repeat
                        task.wait(0.2)
                        ActivateProximityPrompt(extraData)
                        ActivateAllFlushPrompts()
                    until IsMobDead(mob) or not mob.Parent or not AutoFarmEnabled
                    giantLockConn:Disconnect()

                else
                    if SafeModeEnabled and GetPlayerHealthPercent() < SafeValue then
                        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                        if mobRoot then
                            local safePos = mobRoot.Position + Vector3.new(0, 111 + GetMobSize(mob), 0)
                            pcall(function()
                                Character:PivotTo(CFrame.new(safePos))
                                HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                            end)
                        end
                        task.wait(0.5)
                    else
                        StartDamageChecker(mob)
                        TeleportToMob(mob)
                        LockToMob(mob)
                        repeat task.wait(0.1) until IsMobDead(mob) or not AutoFarmEnabled
                        ResetMobOverride(mob)
                    end
                end
            else
                TeleportToIdle()
                repeat task.wait(0.5) until GetPriorityMob() ~= nil or not AutoFarmEnabled
                WaitingRespawn = false
            end

            task.wait(0.1)
        end
        WaitingRespawn = false
    end)
end

-- ====================== MISC OPTIONS HANDLER ======================
local function HandleMiscOptions(selectedOptions)
    MiscOptions = selectedOptions

    local hasAutoAttack = table.find(selectedOptions, "Auto Attack")
    if hasAutoAttack and not AutoAttackEnabled then AutoAttackEnabled = true; StartAutoAttack()
    elseif not hasAutoAttack then AutoAttackEnabled = false end

    local hasAutoSkill = table.find(selectedOptions, "Auto Skill")
    if hasAutoSkill and not AutoSkillEnabled then AutoSkillEnabled = true; StartAutoSkill()
    elseif not hasAutoSkill then AutoSkillEnabled = false end

    local hasAutoSkipHeli = table.find(selectedOptions, "Auto Skip Helicopter")
    if hasAutoSkipHeli and not AutoSkipHeliEnabled then AutoSkipHeliEnabled = true; TriggerAutoSkipHeli(true)
    elseif not hasAutoSkipHeli and AutoSkipHeliEnabled then AutoSkipHeliEnabled = false; TriggerAutoSkipHeli(false) end

    local hasDeleteMap = table.find(selectedOptions, "Delete Map")
    if hasDeleteMap and not DeleteMapEnabled then DeleteMapEnabled = true; DeleteMapTextures() end

    SafeModeEnabled = table.find(selectedOptions, "Safe Mode") ~= nil

    -- Auto Start sync กับ Auto Vote
    local hasAutoStart = table.find(selectedOptions, "Auto Start")
    if hasAutoStart and not AutoStartEnabled then
        -- StartAutoStart จะเรียก RefreshVoteAndStartSetup ให้ sync กับ AutoVote อัตโนมัติ
        StartAutoStart()
    elseif not hasAutoStart and AutoStartEnabled then
        StopAutoStart()
    end

    local hasAutoFillUp = table.find(selectedOptions, "Auto Fill Up")
    if hasAutoFillUp and not AutoFillUpEnabled then
        if AutoFarmEnabled then AutoFillUpEnabled = true; StartAutoFillUpLoop() end
    elseif not hasAutoFillUp then AutoFillUpEnabled = false; FillUpRunning = false end

    Config:Set("MiscOptions", selectedOptions)
    Config:Save()
end

-- ====================== CHARACTER RESPAWN HANDLER ======================
LocalPlayer.CharacterAdded:Connect(function(char)
    Character       = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Client          = LocalPlayer
    MobHeightOverride   = {}
    MobConfirmedPadding = {}
    MobLastHealth       = {}
    task.wait(1)
    local cam = workspace.CurrentCamera
    cam.CameraSubject = HumanoidRootPart
    cam.CameraType    = Enum.CameraType.Custom
end)

-- ====================== UI: MAIN ======================
Main:Section({ Title = "Auto Farm", Icon = "package" })

AutoFarmToggle = Main:Toggle({
    Title = "Auto Farm",
    Value = AutoFarmEnabled,
    Callback = function(state)
        AutoFarmEnabled = state
        if state then
            StartFarmLoop()
            HandleMiscOptions(MiscOptions)
        else
            AutoAttackEnabled = false; AutoSkillEnabled = false
            AutoSkipHeliEnabled = false; AutoFillUpEnabled = false
            FillUpRunning = false
            if AutoStartEnabled then StopAutoStart() end
        end
        Config:Set("AutoFarmEnabled", state); Config:Save()
    end
})

Main:Section({ Title = "Farm Settings", Icon = "settings" })

PositionDropdown = Main:Dropdown({
    Title = "Position Farm",
    Values = { "Above", "Under" },
    Multi = false,
    Value = FarmPosition,
    Callback = function(value) FarmPosition = value; Config:Set("FarmPosition", value); Config:Save() end
})

ModeDropdown = Main:Dropdown({
    Title = "Mode Farm",
    Values = { "Tween" },
    Multi = false,
    Value = FarmMode,
    Callback = function(value) FarmMode = value; Config:Set("FarmMode", value); Config:Save() end
})

MiscDropdown = Main:Dropdown({
    Title = "Misc Farm",
    Values = { "Auto Attack", "Auto Skill", "Auto Start", "Auto Skip Helicopter", "Auto Fill Up", "Safe Mode", "Delete Map" },
    Multi = true,
    Value = MiscOptions,
    Callback = function(values) MiscOptions = values; HandleMiscOptions(values) end
})

-- ============================================================
-- ====================== UI: OVERRIDE SETTINGS ===============
-- ============================================================
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
    Value = { Min = 0, Max = 10, Default = ANTI_CLIP_MARGIN },
    Step = 1,
    Callback = function(value)
        ANTI_CLIP_MARGIN = value
        Config:Set("AntiClipMargin", value)
        Config:Save()
        print("[DYHUB] Anti-Clip Margin set to " .. value)
    end
})

Main:Slider({
    Title = "Damage Threshold (confirm lock)",
    Value = { Min = 1, Max = 500, Default = DMG_THRESHOLD },
    Step = 1,
    Callback = function(value)
        DMG_THRESHOLD = value
        Config:Set("DmgThreshold", value)
        Config:Save()
        print("[DYHUB] Damage Threshold set to " .. value)
    end
})

Main:Button({
    Title = "Reset All Confirmed Positions",
    Callback = function()
        MobConfirmedPadding = {}
        MobHeightOverride   = {}
        WindUI:Notify({ Title = "Override Reset", Content = "All confirmed mob positions cleared.", Duration = 2, Icon = "refresh-cw" })
    end
})

Main:Section({ Title = "General Settings", Icon = "zap" })

SkillDropdown = Main:Dropdown({
    Title = "Auto Skill (Keys)",
    Values = skillDropdownValues,
    Multi = true,
    Value = SelectedSkills,
    Callback = function(values) SelectedSkills = values; Config:Set("SelectedSkills", values); Config:Save() end
})

SkillDelaySlider = Main:Slider({
    Title = "Skill Delay (S)",
    Value = { Min = 1, Max = 30, Default = SkillDelay },
    Step = 1,
    Callback = function(value) SkillDelay = value; Config:Set("SkillDelay", value); Config:Save() end
})

SafeModeSlider = Main:Slider({
    Title = "Safe Mode HP (%)",
    Value = { Min = 1, Max = 100, Default = SafeValue },
    Step = 1,
    Callback = function(value) SafeValue = value; Config:Set("SafeValue", value); Config:Save() end
})

FarmHeightSlider = Main:Slider({
    Title = "Farm Height (+Y)",
    Value = { Min = -30, Max = 30, Default = HeightValue },
    Step = 1,
    Callback = function(value)
        HeightValue = value
        Config:Set("HeightValue", value)
        Config:Save()
        for mob, _ in pairs(MobHeightOverride) do
            if MobConfirmedPadding[mob] == nil then
                MobHeightOverride[mob] = nil
            end
        end
        print("[DYHUB] Farm Height changed to " .. value .. " | non-confirmed overrides reset")
    end
})

Main:Section({ Title = "Flush Settings", Icon = "toilet" })

local Flushaura      = Config:Get("flushaura", false)
local FlushAuraValue = Config:Get("FlushAuraValue", 5)

Main:Slider({
    Title = "Flush Aura (stud)",
    Value = { Min = 1, Max = 15, Default = FlushAuraValue },
    Step = 1,
    Callback = function(value) FlushAuraValue = value; Config:Set("FlushAuraValue", value); Config:Save() end
})

Main:Toggle({
    Title = "Flush Aura",
    Value = Flushaura,
    Callback = function(enabled)
        Flushaura = enabled
        Config:Set("flushaura", enabled); Config:Save()
        if enabled then
            task.spawn(function()
                while Flushaura do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
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
                                            prompt.HoldDuration = 0
                                            prompt.MaxActivationDistance = FlushAuraValue
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
            end)
        end
    end
})

-- ============================================================
-- ====================== ESP SYSTEM =========================
-- ============================================================

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
    ItemList = {
        "Clock Spider","X-18 Core","Green Energy Core","Weird Transmitter",
        "Presents","Weird Prism","Key Card","Zombie Core","Flash Drives","Astro Samples",
    },
    MobList = {},
}

local function IsESPItemTarget(objectName, selectedList)
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

local function CreateESPLabel(parent, labelText, textColor)
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

local function BuildLabelText(model, showName, showHealth, showDistance)
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

local function BuildItemLabelText(obj, showName, showDistance)
    local parts = {}
    if showName then table.insert(parts, obj.Name) end
    if showDistance then
        local root = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or (obj:IsA("BasePart") and obj or nil)
        if root and HumanoidRootPart then table.insert(parts, "📏 " .. math.floor((HumanoidRootPart.Position - root.Position).Magnitude) .. "m") end
    end
    return table.concat(parts, "\n")
end

local function GetESPSettings()
    local s = ESP.Settings
    return {
        highlight = table.find(s, "Highlight") ~= nil,
        distance  = table.find(s, "Distance") ~= nil,
        health    = table.find(s, "Health") ~= nil,
        name      = table.find(s, "Name") ~= nil,
    }
end

local function ApplyMobESP(mob)
    if not mob or not mob.Parent then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local settings = GetESPSettings()
    if settings.highlight then CreateHighlight(mob, Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 255, 255), 0.9) end
    if settings.name or settings.health or settings.distance then
        local _, label = CreateESPLabel(hrp, "", Color3.fromRGB(255, 255, 255))
        task.spawn(function()
            while mob and mob.Parent and ESP.Enabled and ESP.MobEnabled do
                local humanoid = mob:FindFirstChild("Humanoid")
                if not humanoid or humanoid.Health <= 0 then break end
                if not IsInRange(hrp) then label.Visible = false; task.wait(0.5)
                else label.Visible = true; label.Text = BuildLabelText(mob, settings.name, settings.health, settings.distance); task.wait(0.15) end
            end
            RemoveESP(mob); ESP._mobHighlights[mob] = nil
        end)
    end
    ESP._mobHighlights[mob] = true
end

local function ScanMobs()
    local livingFolder = workspace:FindFirstChild("Living"); if not livingFolder then return end
    for _, mob in ipairs(livingFolder:GetChildren()) do
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
    local settings = GetESPSettings()
    if settings.highlight then CreateHighlight(playerChar, Color3.fromRGB(50, 255, 50), Color3.fromRGB(255, 255, 255), 0.9) end
    if settings.name or settings.health or settings.distance then
        local _, label = CreateESPLabel(hrp, "", Color3.fromRGB(255, 255, 255))
        task.spawn(function()
            while playerChar and playerChar.Parent and ESP.Enabled and ESP.PlayerEnabled do
                local humanoid = playerChar:FindFirstChild("Humanoid")
                if not humanoid or humanoid.Health <= 0 then break end
                if not IsInRange(hrp) then label.Visible = false; task.wait(0.5)
                else label.Visible = true; label.Text = BuildLabelText(playerChar, settings.name, settings.health, settings.distance); task.wait(0.15) end
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
    local settings = GetESPSettings()
    if settings.highlight then CreateHighlight(obj, Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 255, 255), 0.9) end
    if settings.name or settings.distance then
        local _, label = CreateESPLabel(root, "", Color3.fromRGB(255, 255, 255))
        task.spawn(function()
            while obj and obj.Parent and ESP.Enabled and ESP.ItemEnabled do
                local currentRoot = GetItemRoot(obj); if not currentRoot then break end
                if not IsInRange(currentRoot) then label.Visible = false; task.wait(0.5)
                else label.Visible = true; label.Text = BuildItemLabelText(obj, settings.name, settings.distance); task.wait(0.25) end
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
    for mob, _ in pairs(ESP._mobHighlights) do RemoveESP(mob) end
    ESP._mobHighlights = {}
    for char, _ in pairs(ESP._playerHighlights) do RemoveESP(char) end
    ESP._playerHighlights = {}
    for obj, _ in pairs(ESP._itemHighlights) do RemoveESP(obj) end
    ESP._itemHighlights = {}
end

local ESPConnection = nil

local function StartESPLoop()
    if ESPConnection then ESPConnection:Disconnect(); ESPConnection = nil end
    local tickCounter = 0
    ESPConnection = RunService.Heartbeat:Connect(function()
        tickCounter = tickCounter + 1
        if tickCounter % 30 == 0  and ESP.Enabled and ESP.MobEnabled    then pcall(ScanMobs) end
        if tickCounter % 47 == 0  and ESP.Enabled and ESP.PlayerEnabled then pcall(ScanPlayers) end
        if tickCounter % 61 == 0  and ESP.Enabled and ESP.ItemEnabled   then pcall(ScanItems) end
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

local function WatchLivingFolder()
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
    Values = { "Highlight", "Distance", "Health", "Name" },
    Value = ESP.Settings,
    Callback = function(value)
        ESP.Settings = value or {}; Config:Set("EspSettings", value); Config:Save()
        if ESP.Enabled then ClearAllESP() end
    end,
})

EspItemDropdown = Main4:Dropdown({
    Title = "ESP Items", Multi = true,
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

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    updatePlayerStats()
end)

Main2:Slider({
    Title = "Set Walkspeed",
    Value = { Min = 1, Max = 200, Default = WSValue },
    Step = 1,
    Callback = function(value) WSValue = value; Config:Set("WSValue", value); Config:Save(); updatePlayerStats() end
})

Main2:Slider({
    Title = "Set Jumppower",
    Value = { Min = 1, Max = 500, Default = JPValue },
    Step = 1,
    Callback = function(value) JPValue = value; Config:Set("JPValue", value); Config:Save(); updatePlayerStats() end
})

nocliptoggle = Main2:Toggle({
    Title = "No Clip", Value = NoClip,
    Callback = function(state) NoClip = state; Config:Set("NoClip", state); Config:Save() end
})

Main2:Section({ Title = "Redeem Codes", Icon = "bird" })

local SelectedCodes = Config:Get("SelectedCodes", {})

CodeDropdown = Main2:Dropdown({
    Title = "Select Redeem Codes", Multi = true,
    Values = GlobalTables.redeemCodes, Value = SelectedCodes,
    Callback = function(value) SelectedCodes = value or {}; Config:Set("SelectedCodes", value); Config:Save() end,
})

Main2:Button({
    Title = "Redeem Codes (Selected)",
    Callback = function()
        for _, code in ipairs(SelectedCodes or {}) do
            pcall(function() ReplicatedStorage:WaitForChild("RedeemCode"):FireServer(code); task.wait(0.2) end)
        end
    end,
})

Main2:Button({
    Title = "Redeem Code (All)",
    Callback = function()
        for _, code in ipairs(GlobalTables.redeemCodes or {}) do
            pcall(function() ReplicatedStorage:WaitForChild("RedeemCode"):FireServer(code); task.wait(0.5) end)
        end
    end,
})

-- ====================== UI: GAMEMODE TAB ======================
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

-- [FIX v021.4] Dropdown เลือกค่าเฉยๆ ไม่ยิง FireServer
GameModeDropdown = Main7:Dropdown({
    Title = "Set Game Mode",
    Values = GlobalTables.Mode,
    Multi = false,
    Value = AutoVoteValue,
    Callback = function(value)
        -- บันทึกค่าเฉยๆ ไม่ยิง FireServer
        AutoVoteValue = value
        Config:Set("AutoVoteValue", value)
        Config:Save()
        print("[DYHUB] Game Mode selected: " .. tostring(value) .. " (toggle to activate)")
    end
})

-- [FIX v021.4] Toggle เท่านั้นที่ยิง + sync กับ AutoStart
AutoVoteToggle = Main7:Toggle({
    Title = "Auto Game Mode (Lobby)",
    Value = AutoVoteEnabled,
    Callback = function(enabled)
        AutoVoteEnabled = enabled
        Config:Set("AutoVoteEnabled", enabled)
        Config:Save()
        -- RefreshVoteAndStartSetup จัดการ sync กับ AutoStart ให้อัตโนมัติ
        RefreshVoteAndStartSetup()
    end
})

Main7:Divider()
Main7:Section({ Title = "Vote Information", TextXAlignment = "Center", TextSize = 17 })
Main7:Divider()
Main7:Paragraph({
    Title = "Auto Vote: Game Mode",
    Desc = "- [ Step 1 ] Stay in the Lobby (inside a game)\n- [ Step 2 ] Set Auto Vote & Wait",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})
Main7:Divider()
Main7:Section({ Title = "Vote Mode", Icon = "gamepad-2" })

-- [FIX v021.4] Dropdown เลือกค่าเฉยๆ ไม่ยิง FireServer
GameModeDropdown2 = Main7:Dropdown({
    Title = "Set Vote Mode",
    Values = GlobalTables.Votes,
    Multi = false,
    Value = AutoVoteValue2,
    Callback = function(value)
        -- บันทึกค่าเฉยๆ ไม่ยิง FireServer
        AutoVoteValue2 = value
        Config:Set("AutoVoteValue2", value)
        Config:Save()
        print("[DYHUB] Vote Mode selected: " .. tostring(value) .. " (toggle to activate)")
    end
})

-- [FIX v021.4] Toggle เท่านั้นที่ยิง (แยกอิสระจาก AutoStart)
AutoVoteIGToggle = Main7:Toggle({
    Title = "Auto Vote Mode (In-Game)",
    Value = AutoVoteinGameEnabled,
    Callback = function(enabled)
        AutoVoteinGameEnabled = enabled
        Config:Set("AutoVoteinGameEnabled", enabled)
        Config:Save()
        SetupAutoVote_InGame(enabled)
    end
})

-- ====================== UI: AUTO BUY ======================
Main5:Section({ Title = "Shop Weapon", Icon = "helicopter" })

local AutoBuyWeaponValue         = Config:Get("AutoBuyWeaponValue", "Stungun")
local AutoBuyWeaponToggleEnabled = Config:Get("AutoBuyWeaponEnabled", false)

WeaponDropdown = Main5:Dropdown({
    Title = "Select Buy (Weapon)",
    Values = GlobalTables.Weapon, Multi = false, Value = AutoBuyWeaponValue,
    Callback = function(value) AutoBuyWeaponValue = value; Config:Set("AutoBuyWeaponValue", value); Config:Save() end
})

AutoBuyWeaponToggle = Main5:Toggle({
    Title = "Auto Buy (Weapon)", Value = AutoBuyWeaponToggleEnabled,
    Callback = function(enabled)
        AutoBuyWeaponToggleEnabled = enabled; Config:Set("AutoBuyWeaponEnabled", enabled); Config:Save()
        if enabled then
            task.spawn(function()
                while AutoBuyWeaponToggleEnabled do
                    if AutoBuyWeaponValue then
                        pcall(function() ReplicatedStorage.ShopSystem:FireServer("Buy", AutoBuyWeaponValue) end)
                    end
                    task.wait(10)
                end
            end)
        end
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
    Title = "Select Buy (Misc)",
    Values = GlobalTables.MiscShop, Multi = false, Value = AutoBuyMiscValue,
    Callback = function(value) AutoBuyMiscValue = value; Config:Set("AutoBuyMiscValue", value); Config:Save() end
})

AutoBuyMiscToggle = Main5:Toggle({
    Title = "Auto Buy (Misc)", Value = AutoBuyMiscToggleEnabled,
    Callback = function(enabled)
        AutoBuyMiscToggleEnabled = enabled; Config:Set("AutoBuyMiscEnabled", enabled); Config:Save()
        if enabled then
            task.spawn(function()
                while AutoBuyMiscToggleEnabled do
                    if AutoBuyMiscValue then
                        pcall(function() ReplicatedStorage.ShopSystem:FireServer("Buy", AutoBuyMiscValue) end)
                    end
                    task.wait(10)
                end
            end)
        end
    end
})

Main5:Button({
    Title = "Buy Misc (Once)",
    Callback = function()
        if AutoBuyMiscValue then pcall(function() ReplicatedStorage.ShopSystem:FireServer("Buy", AutoBuyMiscValue) end) end
    end
})

-- ====================== UI: COLLECT TAB ======================
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
    Title = "Item Collect",
    Values = CollectItems, Multi = true, Value = SelectedCollectItems,
    Callback = function(values) SelectedCollectItems = values or {}; Config:Set("SelectedCollectItems", values); Config:Save() end
})

CollectModeDropdown = Main6:Dropdown({
    Title = "Mode Collect",
    Values = { "Clean", "IDGF" }, Multi = false, Value = CollectMode,
    Callback = function(value) CollectMode = value; Config:Set("CollectMode", value); Config:Save() end
})

-- ====================== UI: SETTING TAB ======================
Main3:Section({ Title = "Save Config", Icon = "save" })

Main3:Button({
    Title = "Save Config (NOW)",
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
    Title = "Auto Save Config", Value = AutoSaveEnabled,
    Callback = function(state) AutoSaveEnabled = state; Config:Set("AutoSaveEnabled", state); Config:Save(); RestartAutoSave() end
})

Main3:Input({
    Title = "Delay Save Config", Default = tostring(AutoSaveDelay), Placeholder = "Default: 15",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 then AutoSaveDelay = num; Config:Set("AutoSaveDelay", num); Config:Save(); RestartAutoSave()
        else warn("[DYHUB] Invalid delay value!") end
    end
})

Main3:Section({ Title = "Server Status", Icon = "server" })

Main3:Button({
    Title = "Serverhop",
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
    Callback = function()
        WindUI:Notify({ Title = "Rejoin", Content = "Rejoining server...", Duration = 2, Icon = "refresh-cw" })
        task.wait(1)
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

Main3:Section({ Title = "Miscellaneous", Icon = "settings" })

NoBarrierToggle = Main3:Toggle({
    Title = "Bypass Barrier (PATCHED)", Value = noBarrierActive,
    Callback = function(value)
        noBarrierActive = value; Config:Set("NoBarrier", value); Config:Save()
        if value then startNoBarrier() else stopNoBarrier() end
    end
})

local antiafk = Main3:Toggle({
    Title = "Anti AFK", Value = hi1,
    Callback = function(enabled)
        hi1 = enabled; Config:Set("hi2", enabled); Config:Save()
        if enabled then
            task.spawn(function()
                game.Players.LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
                while hi1 do
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                    task.wait(60)
                end
            end)
        end
    end
})

-- ====================== AUTO START ON LOAD ======================
if AutoFarmEnabled then
    task.wait(2)
    StartFarmLoop()
    HandleMiscOptions(MiscOptions)
end

if noBarrierActive then startNoBarrier() end

if ESP.Enabled then
    task.wait(2)
    StartESPLoop()
end

if AutoBuyWeaponToggleEnabled then
    task.spawn(function()
        while AutoBuyWeaponToggleEnabled do
            if AutoBuyWeaponValue then pcall(function() ReplicatedStorage.ShopSystem:FireServer("Buy", AutoBuyWeaponValue) end) end
            task.wait(10)
        end
    end)
end

if AutoBuyMiscToggleEnabled then
    task.spawn(function()
        while AutoBuyMiscToggleEnabled do
            if AutoBuyMiscValue then pcall(function() ReplicatedStorage.ShopSystem:FireServer("Buy", AutoBuyMiscValue) end) end
            task.wait(10)
        end
    end)
end

if AutoCollectEnabled then
    task.wait(2)
    StartAutoCollectLoop()
end

-- [FIX v021.4] ใช้ RefreshVoteAndStartSetup แทนการเรียกแยก
if AutoVoteEnabled or AutoStartEnabled then
    RefreshVoteAndStartSetup()
end

if AutoVoteinGameEnabled then SetupAutoVote_InGame(true) end

print("[DYHUB] Version " .. version .. " " .. ver .. " loaded successfully!")
print("[DYHUB] Config system active | Auto saving every 15 seconds")
