-- v043
-- =========================
local version = "Rework"
local ver = "v020.1"
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
        WindUI:Notify({
            Title = "Initialization",
            Content = "Game is loading, Please wait.",
            Duration = 3,
            Icon = "download",
        })
        gui.AncestryChanged:Wait()
    end
end

waitLoadingGone()

WindUI:Notify({
    Title = "Initialization",
    Content = "Load complete, Starting in 3s.",
    Duration = 3,
    Icon = "shield-check",
})

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
    WindUI:Notify({
        Title = "Service",
        Content = "FPS Unlocked! | " .. ver,
        Duration = 3,
        Icon = "cpu",
    })
    warn("FPS Unlocked!")
else
    WindUI:Notify({
        Title = "Not Working",
        Content = "Your exploit does not support setfpscap.",
        Duration = 3,
        Icon = "ban",
    })
    warn("Your exploit does not support setfpscap.")
end

-- ====================== CUSTOM CONFIG SYSTEM ======================
local HttpService = game:GetService("HttpService")
local ConfigFolder = "DYHUB_REWORK_STBB"

local CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self = setmetatable({}, CustomConfig)
    self.ConfigData = {}
    self.ConfigPath = ConfigFolder .. "/config.json"
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
    self:Load()
    return self
end

function CustomConfig:Set(key, value)
    self.ConfigData[key] = value
end

function CustomConfig:Get(key, default)
    if self.ConfigData[key] ~= nil then
        return self.ConfigData[key]
    end
    return default
end

function CustomConfig:Save()
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(self.ConfigData)
        writefile(self.ConfigPath, json)
    end)
    if success then
        print("[DYHUB] Config saved successfully!")
    else
        warn("[DYHUB] Failed to save config:", err)
    end
end

function CustomConfig:Load()
    if isfile(self.ConfigPath) then
        local success, result = pcall(function()
            local json = readfile(self.ConfigPath)
            return HttpService:JSONDecode(json)
        end)
        if success and type(result) == "table" then
            self.ConfigData = result
            print("[DYHUB] Config loaded successfully!")
        else
            warn("[DYHUB] Failed to load config, using defaults")
            self.ConfigData = {}
        end
    else
        print("[DYHUB] No config file found, creating new one")
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
local HttpService = game:GetService("HttpService")

local FreeVersion = "Free Version"
local PremiumVersion = "Premium Version"
local ExtraVersion = "Extra Version"

local function getData(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        return nil
    end

    local func = loadstring(response)
    if func then
        return func()
    end

    return nil
end

local function checkVersion(playerName)
    -- Extra check (priority สูงสุด)
    local extraUrl = "https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/STBBList.lua"
    local extraData = getData(extraUrl)

    if extraData and extraData[playerName] then
        return ExtraVersion
    end

    -- Premium check
    local premiumUrl = "https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua"
    local premiumData = getData(premiumUrl)

    if premiumData and premiumData[playerName] then
        return PremiumVersion
    end

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
local Info = Window:Tab({ Title = "Information", Icon = "info" })
MainDivider = Window:Divider()
local Main = Window:Tab({ Title = "Main", Icon = "rocket" })
local Main4 = Window:Tab({ Title = "Esp", Icon = "eye" })
local Main2 = Window:Tab({ Title = "Player", Icon = "user" })
MainDivider1 = Window:Divider()
local Main5 = Window:Tab({ Title = "Shop", Icon = "shopping-cart" })
local Main6 = Window:Tab({ Title = "Collect", Icon = "hand" })
local Main7 = Window:Tab({ Title = "Gamemode", Icon = "gamepad-2" })
MainDivider2 = Window:Divider()
local Main3 = Window:Tab({ Title = "Setting", Icon = "settings" })
Window:SelectTab(1)

-- ======================== INFO ========================
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

Info:Section({ Title = "Lasted Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()

Info:Paragraph({
    Title = "Update: 06/03/2026",
    Desc = "- [ Fixed ] Auto Collect \n- [ Fixed ] Auto Game Mode \n- [ Added ] Mob Height Override \n- [ Improved ] Mob Height Override",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})
Info:Divider()
Info:Section({ Title = "Discord Information", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
ui.Creator.Request = function(requestData)
    local success, result = pcall(function()
        if HttpService.RequestAsync then
            local response = HttpService:RequestAsync({
                Url = requestData.Url,
                Method = requestData.Method or "GET",
                Headers = requestData.Headers or {}
            })
            return {
                Body = response.Body,
                StatusCode = response.StatusCode,
                Success = response.Success
            }
        else
            local body = HttpService:GetAsync(requestData.Url)
            return {
                Body = body,
                StatusCode = 200,
                Success = true
            }
        end
    end)
    if success then
        return result
    else
        error("HTTP Request failed: " .. tostring(result))
    end
end

local InviteCode = "jWNDPNMmyB"
local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local function LoadDiscordInfo()
    local success, result = pcall(function()
        local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
        if not httpRequest then return nil end
        local response = httpRequest({
            Url = DiscordAPI,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "RobloxBot/1.0",
                ["Accept"] = "application/json"
            }
        })
        if response and response.Body then
            return game:GetService("HttpService"):JSONDecode(response.Body)
        end
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
                    local response = httpRequest({
                        Url = DiscordAPI,
                        Method = "GET",
                    })
                    if response and response.Body then
                        return game:GetService("HttpService"):JSONDecode(response.Body)
                    end
                    return nil
                end)

                if updated and updatedResult and updatedResult.guild then
                    DiscordInfo:SetDesc(
                        ' <font color="#52525b">●</font> Member Count : ' .. tostring(updatedResult.approximate_member_count) ..
                        '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(updatedResult.approximate_presence_count)
                    )
                    WindUI:Notify({
                        Title = "Discord Info Updated",
                        Content = "Successfully refreshed Discord statistics",
                        Duration = 2,
                        Icon = "refresh-cw",
                    })
                else
                    WindUI:Notify({
                        Title = "Update Failed",
                        Content = "Could not refresh Discord info",
                        Duration = 3,
                        Icon = "alert-triangle",
                    })
                end
            end
        })

        Info:Button({
            Title = "Copy Discord Invite",
            Callback = function()
                setclipboard("https://discord.gg/" .. InviteCode)
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "Discord invite copied to clipboard",
                    Duration = 2,
                    Icon = "clipboard-check",
                })
            end
        })
    else
        Info:Paragraph({
            Title = "Error fetching Discord Info",
            Desc = "Unable to load Discord information. Check your internet connection.",
            Image = "triangle-alert",
            ImageSize = 26,
            Color = "Red",
        })
        print("Discord API Error:", result)
    end
end

LoadDiscordInfo()

Info:Divider()
Info:Section({
    Title = "DYHUB Information",
    TextXAlignment = "Center",
    TextSize = 17,
})
Info:Divider()

local Owner = Info:Paragraph({
    Title = "Main Owner",
    Desc = "@dyumraisgoodguy#8888",
    Image = "rbxassetid://119789418015420",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 0,
    Locked = false,
})

local Social = Info:Paragraph({
    Title = "Social",
    Desc = "Copy link social media for follow!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 0,
    Locked = false,
    Buttons = {
        {
            Icon = "copy",
            Title = "Copy Link",
            Callback = function()
                setclipboard("https://guns.lol/DYHUB")
                print("Copied social media link to clipboard!")
            end,
        }
    }
})

local Discord = Info:Paragraph({
    Title = "Discord",
    Desc = "Join our discord for more scripts!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 0,
    Locked = false,
    Buttons = {
        {
            Icon = "copy",
            Title = "Copy Link",
            Callback = function()
                setclipboard("https://discord.gg/jWNDPNMmyB")
                print("Copied discord link to clipboard!")
            end,
        }
    }
})

-- ====================== SERVICES ======================
local Players = game:GetService("Players")
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
    redeemCodes = {
        "100MVisit2",
        "100MVisit1",
        "CamArmada",
        "CCTVBase",
        "ADelayedGameIsEventuallyGoodButRushedGameIsForeverBad"
    },
    Mode = {
    	"Normal Mode",
    	"Vague Memory",
    	"Extreme Mode",
    	"Hard Mode",
    	"Insane Mode",
    	"Nightmare Mode",
    	"Boss Rush",
    	"Dark Dimension",
    	"Hell",
    	"Mist",
    	"Christmas Act 1",
    	"Zombie Act 1",
    	"Holdout",
    	"Invasion"
    },
    Votes = {
    	"Normal Mode",
    	"Vague Memory",
    	"Extreme Mode",
    	"Hard Mode",
    	"Insane Mode",
    	"Nightmare Mode",
    	"Boss Rush",
    	"Dark Dimension",
    	"Hell",
    	"Mist",
    	"Christmas Act 1",
    	"Zombie Act 1",
    	"Holdout",
    	"Invasion"
    },
    Weapon = {
        "Stungun", "Flamethrower", "Harpoon Gun", "Shot Gun",
        "Pulse Rifle", "Shot Harpoon Gun", "EPD", "Small Laser Gun"
    },
    MiscShop = {
        "HeadPhone", "Titan-Request", "SpecialTitan-Request",
        "Speaker-Request", "Grenade", "Jetpack", "Lens"
    },
}

-- ====================== CONFIG VARIABLES ======================
local skillList = { "Q", "E", "R", "T", "Y", "G", "H", "Z", "X", "C", "V", "B", "U" }
local skillDropdownValues = { "All", "Q", "E", "R", "T", "Y", "G", "H", "Z", "X", "C", "V", "B", "U" }

-- ====================== STATE VARIABLES ======================
local AutoFarmEnabled = Config:Get("AutoFarmEnabled", false)
local FarmPosition = Config:Get("FarmPosition", "Above")
local FarmMode = Config:Get("FarmMode", "Tween")
local MiscOptions = Config:Get("MiscOptions", {})
local AutoAttackEnabled = false
local AutoSkillEnabled = false
local AutoSkipHeliEnabled = false
local DeleteMapEnabled = false
local AutoStartEnabled = false
local AutoFillUpEnabled = false
local SelectedSkills = Config:Get("SelectedSkills", { "All" })
local SafeModeEnabled = false
local SafeValue = Config:Get("SafeValue", 30)
local WaitingRespawn = false
local IdlePosition = CFrame.new(-23.3435822, 67, 0.341766357) * CFrame.Angles(math.rad(0), 0, 0)
local SkillDelay = Config:Get("SkillDelay", 1)
local LoopDelay = 0.5
local TweenSpeed = 1
local HeightValue = Config:Get("HeightValue", 2)
local NeedNoClip = false
local LockActive = false
local AutoStartConnection = nil
local noBarrierConnection = nil
local noBarrierActive = Config:Get("NoBarrier", false)

-- antiafk
local VirtualUser = game:GetService("VirtualUser")
local hi2 = Config:Get("hi2", true)
local hi1 = Config:Get("hi2", true)

-- Auto Buy state
local AutoBuyWeaponEnabled = Config:Get("AutoBuyWeaponEnabled", false)
local AutoBuyMiscEnabled = Config:Get("AutoBuyMiscEnabled", false)
local SelectedWeapon = Config:Get("SelectedWeapon", "Stungun")
local SelectedMiscItem = Config:Get("SelectedMiscItem", "HeadPhone")

-- ====================== FILL UP PART CONFIG ======================
local FILLUP_PART_PATH = {"HelicopterShop", "ShopXDD", "PartForShop"}
local FILLUP_TARGET_POS = Vector3.new(44.2756729, 26.3595276, -32.7318268)
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
    local pos = p.CFrame.Position
    return (pos - FILLUP_TARGET_POS).Magnitude < FILLUP_POS_THRESHOLD
end

-- ====================== ALLY SYSTEM ======================
local AllyNames = {
    ["Heavy Soldier Toilet V2"] = true,
    ["Quad Laser Toilet"] = true,
    ["Strider Rocket Laser"] = true,
    ["Helicopter Camera"] = true,
    ["Heavy Soldier Toilet V1"] = true,
}

local function IsAlly(mob)
    return AllyNames[mob.Name] ~= nil
end

-- ====================== TP SYSTEM ======================
function tp(pu79)
    pcall(function()
        local v80 = Client
        if v80 then v80 = Client.Character end
        if v80:FindFirstChild("Humanoid") and v80.Humanoid.Sit == true then
            v80.Humanoid.Sit = false
        end
        NeedNoClip = true
        local v81 = {
            Target = pu79.Target or print("mae mung tai."),
            Mod = pu79.Mod or CFrame.new(0, 0, 0)
        }
        v80:FindFirstChild("HumanoidRootPart").CFrame = v81.Target * v81.Mod
    end)
end

function Tp(p82)
    if Client.Character.Humanoid.Sit == true then
        Client.Character.Humanoid.Sit = false
    end
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
        local v88 = Vector3.new(5, math.huge, 5)
        v87.Velocity = Vector3.new(0, 0, 0)
        v87.MaxForce = v88
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
        local isPlayer = Players:GetPlayerFromCharacter(obj)
        if isPlayer then return false end
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
    local cf, size = mob:GetBoundingBox()
    return size.Y
end

-- ====================== MOB SELECTION ======================
local function GetNearestMob()
    local nearestMob = nil
    local nearestDistance = math.huge
    local livingFolder = workspace:FindFirstChild("Living")
    if not livingFolder then return nil end
    for _, mob in ipairs(livingFolder:GetChildren()) do
        if IsValidMob(mob) then
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            if mobRoot then
                local distance = (HumanoidRootPart.Position - mobRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestMob = mob
                end
            end
        end
    end
    return nearestMob
end

local function GetHighestMob()
    local highestMob = nil
    local highestY = -math.huge
    local livingFolder = workspace:FindFirstChild("Living")
    if not livingFolder then return nil end
    local myY = HumanoidRootPart and HumanoidRootPart.Position.Y or 0
    for _, mob in ipairs(livingFolder:GetChildren()) do
        if IsValidMob(mob) then
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            if mobRoot then
                local mobY = mobRoot.Position.Y
                if mobY > myY and mobY > highestY then
                    highestY = mobY
                    highestMob = mob
                end
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

-- ====================== MOB HEIGHT OVERRIDE ======================
local PADDING_REDUCE_STEP = Config:Get("PaddingReduceStep", 2)
local PADDING_SAFE_MIN = Config:Get("PaddingSafeMin", -30)
local PADDING_CHECK_INTERVAL = Config:Get("PaddingCheckInterval", 1)

local MobHeightOverride = {}
local MobLastHealth = {}

local function GetEffectivePadding(mob)
    if MobHeightOverride[mob] ~= nil then
        return MobHeightOverride[mob]
    end
    return HeightValue
end

local function StartDamageChecker(mob)
    task.spawn(function()
        local humanoid = mob and mob:FindFirstChild("Humanoid")
        if not humanoid then return end

        MobLastHealth[mob] = humanoid.Health
        MobHeightOverride[mob] = nil

        local elapsed = 0

        -- ⏱️ ระบบใหม่
        local lastDamageTime = tick()
        local noDamageTimer = 0
        local triggered2sAfterHit = false

        while mob and mob.Parent and not IsMobDead(mob) and AutoFarmEnabled do
            task.wait(0.5)
            elapsed += 0.5

            if not mob or not mob.Parent or IsMobDead(mob) then break end
            humanoid = mob:FindFirstChild("Humanoid")
            if not humanoid then break end

            local currentHP = humanoid.Health
            local lastHP = MobLastHealth[mob] or currentHP

            -- ✅ ถ้า HP ลด = มีดาเมจ
            if currentHP < lastHP then
                lastDamageTime = tick()
                noDamageTimer = 0
                triggered2sAfterHit = false

                print("[DYHUB] Damage detected at padding " .. GetEffectivePadding(mob) .. " for " .. mob.Name)
            else
                -- ❌ ไม่มีดาเมจ
                noDamageTimer = tick() - lastDamageTime
            end

            -- ⏱️ ครบ 2 วิหลังจาก "เคยตีเข้าแล้วแต่หยุดเข้า"
            if noDamageTimer >= 2.5 and not triggered2sAfterHit then
                triggered2sAfterHit = true

                local currentPad = GetEffectivePadding(mob)
                local newPad = math.max(currentPad - PADDING_REDUCE_STEP, PADDING_SAFE_MIN)

                if newPad ~= currentPad then
                    MobHeightOverride[mob] = newPad
                    print("[DYHUB] no damage after hit → reduce padding to " .. newPad .. " for " .. mob.Name)
                end
            end

            -- ⏱️ ทุก ๆ 5 วิถ้ายังไม่เข้าเลือด
            if noDamageTimer >= 5.5 then
                lastDamageTime = tick() -- รีเซ็ตรอบ

                local currentPad = GetEffectivePadding(mob)
                local newPad = math.max(currentPad - PADDING_REDUCE_STEP, PADDING_SAFE_MIN)

                if newPad ~= currentPad then
                    MobHeightOverride[mob] = newPad
                    print("[DYHUB] still no damage → reduce padding to " .. newPad .. " for " .. mob.Name)
                end
            end

            -- interval เดิม
            if elapsed >= PADDING_CHECK_INTERVAL then
                elapsed = 0
                MobLastHealth[mob] = currentHP
            end
        end

        -- reset
        MobHeightOverride[mob] = nil
        MobLastHealth[mob] = nil
        print("[DYHUB] DmgCheck: Mob dead/gone, reset override for " .. (mob and mob.Name or "?"))
    end)
end

-- ====================== TARGET CFRAME ======================
local function GetTargetCFrame(mob, position)
    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
    local mobHead = mob:FindFirstChild("Head")
    local mobHumanoid = mob:FindFirstChild("Humanoid")
    if not mobRoot then return nil end
    local mobHeight = GetMobSize(mob)
    local padding = GetEffectivePadding(mob)
    if position == "Above" then
        local headPos = mobHead and mobHead.Position or mobRoot.Position
        local targetPos = headPos + Vector3.new(0, mobHeight + padding, 0)
        local lookCF = CFrame.new(targetPos, headPos)
        return lookCF * CFrame.Angles(math.rad(-10), 0, 0)
    elseif position == "Under" then
        local rootPos = mobRoot.Position
        local legOffset = mobHumanoid and (mobHumanoid.HipHeight + 1) or 3
        local feetPos = rootPos - Vector3.new(0, legOffset, 0)
        local targetPos = feetPos - Vector3.new(0, mobHeight + padding, 0)
        local lookCF = CFrame.new(targetPos, feetPos)
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
            local args = { [1] = "Buy", [2] = "FillHP" }
            ReplicatedStorage.ShopSystem:FireServer(unpack(args))
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
                print("[DYHUB] FillUp: HP not full, starting fill up process...")

                if AutoSkipHeliEnabled then
                    print("[DYHUB] FillUp: Pausing Auto Skip Heli...")
                    TriggerAutoSkipHeli(false)
                end

                local waited = 0
                local maxWait = 30
                while not IsFillUpPartReady() and AutoFillUpEnabled do
                    waited = waited + 0.2
                    if waited >= maxWait then
                        print("[DYHUB] FillUp: PartForShop timeout after 30s, skipping...")
                        break
                    end
                    task.wait(0.2)
                end

                if IsFillUpPartReady() and AutoFillUpEnabled then
                    print("[DYHUB] FillUp: PartForShop ready! Firing FillHP x2...")
                    DoFillUp()
                    task.wait(1)
                end

                if AutoSkipHeliEnabled then
                    print("[DYHUB] FillUp: Resuming Auto Skip Heli...")
                    TriggerAutoSkipHeli(true)
                end
            end

            task.wait(1)
        end

        FillUpRunning = false
        print("[DYHUB] FillUp: Loop stopped.")
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
            local maxDistance = 1000
            if math.abs(pos.X) > maxDistance or math.abs(pos.Y) > maxDistance or math.abs(pos.Z) > maxDistance then
                print("[DYHUB] Barrier detected! Teleporting to safe zone...")
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

-- ====================== AUTO START SYSTEM ======================
local function FireGetReady()
    task.wait(2.5)
    pcall(function()
        local args = { [1] = "1", [2] = true }
        ReplicatedStorage.GetReadyRemote:FireServer(unpack(args))
    end)
end

local function StartAutoStart()
    FireGetReady()
    if AutoStartConnection then
        AutoStartConnection:Disconnect()
        AutoStartConnection = nil
    end
    AutoStartConnection = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if AutoStartEnabled and AutoFarmEnabled then
            FireGetReady()
        end
    end)
end

local function StopAutoStart()
    if AutoStartConnection then
        AutoStartConnection:Disconnect()
        AutoStartConnection = nil
    end
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
-- ====================== COLLECT SYSTEM (v019 - Prefix Match) =
-- ============================================================

-- รายการ dropdown ที่แสดงใน UI
-- "Flash Drives" จะ match: Flash Drives #1, Flash Drives #2, Flash Drives #A ฯลฯ
-- "Astro Samples" จะ match: Trooper Blast, Trooper Spinner ฯลฯ (ทุกอย่างใน group)
local CollectItems = {
    "Clock Spider",
    "X-18 Core",
    "Green Energy Core",
    "Weird Transmitter",
    "Presents",
    "Weird Prism",
    "Key Card",
    "Zombie Core",
    "Flash Drives",
    "Astro Samples",
}

-- รายการชื่อจริงที่ map ไปหา group (สำหรับ group ที่ชื่อ sub-item ไม่ตรงกับ prefix)
-- "Astro Samples" ใน dropdown จะ match ชื่อเหล่านี้ทั้งหมด
local CollectGroupMap = {
    ["Astro Samples"] = {
        "Trooper Blast",
        "Trooper Spinner",
        "Specialist Blaster",
        "Specialist Spinner",
        "Specialist Sword Arm",
        "Strider Leg",
        "Interceptor Wing",
        "Interceptor Goggles",
        "Interceptor Spinner",
        "Impactor Cannon",
        "Impactor Laser",
        "High Impactor Cannon",
        "High Impactor Laser",
        "Destructor Laser",
        "Destructor Blaster",
        "Destructor Core",
        "Obliterator Blaster",
        "Obliterator Spinner",
    },
}

local AutoCollectEnabled = Config:Get("AutoCollectEnabled", false)
local SelectedCollectItems = Config:Get("SelectedCollectItems", {})
local CollectMode = Config:Get("CollectMode", "Clean")

local KnownCollectItems = {}
local CollectRunning = false

-- ====================== PREFIX/GROUP MATCH HELPER ======================
-- คืน true ถ้า objectName match กับ pattern ใดๆ ใน SelectedCollectItems
-- รองรับ 3 แบบ:
--   1. Exact match (case-insensitive): "Key Card" == "Key Card"
--   2. Prefix match (case-insensitive): "Flash Drives" matches "Flash Drives #1", "Flash Drives #A"
--      (ตัวอักษรถัดจาก prefix ต้องเป็น space, #, _, - หรือจบสตริง)
--   3. Group map: "Astro Samples" ใน selected จะ match ชื่อใน CollectGroupMap["Astro Samples"]

local function MatchesPattern(objectName, pattern)
    local objLower = objectName:lower()
    local patLower = pattern:lower()

    -- 1. Exact match
    if objLower == patLower then return true end

    -- 2. Prefix match
    if #objLower > #patLower then
        if objLower:sub(1, #patLower) == patLower then
            local nextChar = objLower:sub(#patLower + 1, #patLower + 1)
            if nextChar == " " or nextChar == "#" or nextChar == "_" or nextChar == "-" then
                return true
            end
        end
    end

    -- 3. Group map match
    if CollectGroupMap[pattern] then
        for _, groupName in ipairs(CollectGroupMap[pattern]) do
            if objLower == groupName:lower() then
                return true
            end
        end
    end

    return false
end

local function IsCollectTarget(objectName)
    for _, pattern in ipairs(SelectedCollectItems) do
        if MatchesPattern(objectName, pattern) then
            return true
        end
    end
    return false
end

-- ====================== หา collect item ใน workspace ======================
local function FindCollectItems()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj and obj.Parent then
            if IsCollectTarget(obj.Name) then
                if obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("BasePart") then
                    table.insert(found, obj)
                end
            end
        end
    end
    return found
end

local function FindNewCollectItems()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj and obj.Parent then
            if IsCollectTarget(obj.Name) then
                if obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("BasePart") then
                    if not KnownCollectItems[obj] then
                        table.insert(found, obj)
                    end
                end
            end
        end
    end
    return found
end

-- ====================== หา root part ของ item ======================
local function GetItemRootPart(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
    elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
        return obj
    end
    return nil
end

-- ====================== Tween ไปหา item ======================
local function TweenToItem(itemRoot)
    if not itemRoot or not HumanoidRootPart then return end
    local targetPos = itemRoot.Position + Vector3.new(0, 3, 0)
    local targetCF = CFrame.new(targetPos, itemRoot.Position)
    local tweenInfo = TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, { CFrame = targetCF })
    tween:Play()
    tween.Completed:Wait()
end

-- ====================== กด ProximityPrompt ของ item ======================
local function ActivateItemPrompts(obj)
    pcall(function()
        local function tryPrompt(target)
            for _, child in ipairs(target:GetDescendants()) do
                if child:IsA("ProximityPrompt") then
                    child.HoldDuration = 0
                    child.MaxActivationDistance = 50
                    if fireproximityprompt then
                        fireproximityprompt(child)
                    end
                    child:InputHoldBegin()
                    task.wait(0.05)
                    child:InputHoldEnd()
                end
            end
            local directPrompt = target:FindFirstChildOfClass("ProximityPrompt")
            if directPrompt then
                directPrompt.HoldDuration = 0
                directPrompt.MaxActivationDistance = 50
                if fireproximityprompt then
                    fireproximityprompt(directPrompt)
                end
                directPrompt:InputHoldBegin()
                task.wait(0.05)
                directPrompt:InputHoldEnd()
            end
        end
        tryPrompt(obj)
    end)
end

-- ====================== เช็คว่า item ถูกเก็บแล้ว ======================
local function IsItemGone(obj)
    return not obj or not obj.Parent
end

-- ====================== เก็บ item ตัวเดียว ======================
local function CollectSingleItem(obj)
    if IsItemGone(obj) then return end
    local itemRoot = GetItemRootPart(obj)
    if not itemRoot then return end

    print("[DYHUB] Collect: Going to collect " .. obj.Name)

    TweenToItem(itemRoot)

    local lockConn
    lockConn = RunService.RenderStepped:Connect(function()
        if IsItemGone(obj) or not AutoCollectEnabled then
            lockConn:Disconnect()
            return
        end
        if not itemRoot or not itemRoot.Parent then
            lockConn:Disconnect()
            return
        end
        local targetPos = itemRoot.Position + Vector3.new(0, 3, 0)
        local targetCF = CFrame.new(targetPos, itemRoot.Position)
        if Character and HumanoidRootPart then
            Character:PivotTo(targetCF)
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    local timeout = 0
    repeat
        ActivateItemPrompts(obj)
        task.wait(0.1)
        timeout = timeout + 0.1
        if timeout > 10 then
            print("[DYHUB] Collect: Timeout collecting " .. obj.Name .. ", skipping...")
            break
        end
    until IsItemGone(obj) or not AutoCollectEnabled

    lockConn:Disconnect()

    if IsItemGone(obj) then
        print("[DYHUB] Collect: " .. obj.Name .. " collected!")
    end

    KnownCollectItems[obj] = true
end

-- ====================== เช็คว่า mob ทุกตัวตายหมดแล้ว ======================
local function AllMobsDead()
    local livingFolder = workspace:FindFirstChild("Living")
    if not livingFolder then return true end
    for _, mob in ipairs(livingFolder:GetChildren()) do
        if IsValidMob(mob) then return false end
    end
    return true
end

-- ====================== Collect Loop หลัก ======================
local function StartAutoCollectLoop()
    if CollectRunning then return end
    CollectRunning = true

    task.spawn(function()
        while AutoCollectEnabled do
            if #SelectedCollectItems == 0 then
                task.wait(1)
            else
                local itemsToCollect = FindNewCollectItems()

                if #itemsToCollect > 0 then
                    if CollectMode == "IDGF" then
                        print("[DYHUB] Collect [IDGF]: Found " .. #itemsToCollect .. " item(s), collecting NOW!")

                        local prevLockActive = LockActive
                        LockActive = false
                        task.wait(0.1)

                        for _, obj in ipairs(itemsToCollect) do
                            if not AutoCollectEnabled then break end
                            if not IsItemGone(obj) then
                                CollectSingleItem(obj)
                            else
                                KnownCollectItems[obj] = true
                            end
                        end

                        if AutoFarmEnabled then
                            TeleportToIdle()
                            WaitingRespawn = false
                        end

                    elseif CollectMode == "Clean" then
                        print("[DYHUB] Collect [Clean]: Found items, waiting for all mobs to die first...")

                        local waitedClean = 0
                        while not AllMobsDead() and AutoCollectEnabled do
                            task.wait(0.5)
                            waitedClean = waitedClean + 0.5
                            if waitedClean >= 120 then
                                print("[DYHUB] Collect [Clean]: Timeout waiting for mobs, proceeding anyway...")
                                break
                            end
                        end

                        if not AutoCollectEnabled then break end

                        if AutoSkipHeliEnabled then
                            print("[DYHUB] Collect [Clean]: Pausing Auto Skip Heli...")
                            TriggerAutoSkipHeli(false)
                        end

                        LockActive = false
                        task.wait(0.1)

                        print("[DYHUB] Collect [Clean]: Collecting all items...")
                        local currentItems = FindNewCollectItems()
                        for _, obj in ipairs(currentItems) do
                            if not AutoCollectEnabled then break end
                            if not IsItemGone(obj) then
                                CollectSingleItem(obj)
                            else
                                KnownCollectItems[obj] = true
                            end
                        end

                        if AutoSkipHeliEnabled then
                            print("[DYHUB] Collect [Clean]: Resuming Auto Skip Heli...")
                            TriggerAutoSkipHeli(true)
                        end

                        if not IsPlayerHPFull() and AutoFillUpEnabled then
                            print("[DYHUB] Collect [Clean]: HP not full, waiting for fill up...")
                            local fillWait = 0
                            while not IsPlayerHPFull() and AutoFillUpEnabled and AutoCollectEnabled do
                                task.wait(0.5)
                                fillWait = fillWait + 0.5
                                if fillWait >= 60 then break end
                            end
                        end

                        if AutoFarmEnabled then
                            TeleportToIdle()
                            WaitingRespawn = false
                        end
                    end
                else
                    for obj, _ in pairs(KnownCollectItems) do
                        if IsItemGone(obj) then
                            KnownCollectItems[obj] = nil
                        end
                    end
                end
            end

            task.wait(0.5)
        end

        CollectRunning = false
        print("[DYHUB] Collect: Loop stopped.")
    end)
end

-- ====================== ตรวจ item ใหม่ที่ spawn เข้า workspace ======================
workspace.DescendantAdded:Connect(function(obj)
    if not AutoCollectEnabled or #SelectedCollectItems == 0 then return end
    -- ใช้ IsCollectTarget แทน table.find
    if not IsCollectTarget(obj.Name) then return end
    if not (obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("BasePart")) then return end
    print("[DYHUB] Collect: New item detected: " .. obj.Name)
end)

-- ====================== MAIN FARM LOOP ======================
local function StartFarmLoop()
    task.spawn(function()
        task.spawn(function()
            while AutoFarmEnabled do
                if WaitingRespawn and not LockActive then
                    pcall(function()
                        local cf = IdlePosition
                        local tweenInfo = TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                        local tween = TweenService:Create(HumanoidRootPart, tweenInfo, { CFrame = cf })
                        tween:Play()
                        tween.Completed:Wait()
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
                    print("[DYHUB] Found Giant ST toilet with lever!")

                    local cf = GetTargetCFrame(mob, FarmPosition)
                    if cf then
                        if FarmMode == "Tween" then
                            local tweenInfo = TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                            local tween = TweenService:Create(HumanoidRootPart, tweenInfo, { CFrame = cf })
                            tween:Play()
                            tween.Completed:Wait()
                        else
                            tp1(cf)
                        end
                    end

                    local giantLockConn
                    giantLockConn = RunService.RenderStepped:Connect(function()
                        if IsMobDead(mob) or not mob.Parent or not AutoFarmEnabled then
                            giantLockConn:Disconnect()
                            return
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
                    print("[DYHUB] Giant ST defeated! Resuming normal farming...")

                else
                    if mobType == "Helicopter" then
                        print("[DYHUB] Priority: Attacking Helicopter!")
                    end
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
    if not AutoFarmEnabled then return end

    local hasAutoAttack = table.find(selectedOptions, "Auto Attack")
    if hasAutoAttack and not AutoAttackEnabled then
        AutoAttackEnabled = true
        StartAutoAttack()
    elseif not hasAutoAttack then
        AutoAttackEnabled = false
    end

    local hasAutoSkill = table.find(selectedOptions, "Auto Skill")
    if hasAutoSkill and not AutoSkillEnabled then
        AutoSkillEnabled = true
        StartAutoSkill()
    elseif not hasAutoSkill then
        AutoSkillEnabled = false
    end

    local hasAutoSkipHeli = table.find(selectedOptions, "Auto Skip Helicopter")
    if hasAutoSkipHeli and not AutoSkipHeliEnabled then
        AutoSkipHeliEnabled = true
        TriggerAutoSkipHeli(true)
    elseif not hasAutoSkipHeli and AutoSkipHeliEnabled then
        AutoSkipHeliEnabled = false
        TriggerAutoSkipHeli(false)
    end

    local hasDeleteMap = table.find(selectedOptions, "Delete Map")
    if hasDeleteMap and not DeleteMapEnabled then
        DeleteMapEnabled = true
        DeleteMapTextures()
    end

    SafeModeEnabled = table.find(selectedOptions, "Safe Mode") ~= nil

    local hasAutoStart = table.find(selectedOptions, "Auto Start")
    if hasAutoStart and not AutoStartEnabled then
        AutoStartEnabled = true
        StartAutoStart()
    elseif not hasAutoStart and AutoStartEnabled then
        AutoStartEnabled = false
        StopAutoStart()
    end

    local hasAutoFillUp = table.find(selectedOptions, "Auto Fill Up")
    if hasAutoFillUp and not AutoFillUpEnabled then
        AutoFillUpEnabled = true
        StartAutoFillUpLoop()
    elseif not hasAutoFillUp then
        AutoFillUpEnabled = false
        FillUpRunning = false
    end

    Config:Set("MiscOptions", selectedOptions)
    Config:Save()
end

-- ====================== CHARACTER RESPAWN HANDLER ======================
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Client = LocalPlayer
    task.wait(1)
    local cam = workspace.CurrentCamera
    cam.CameraSubject = HumanoidRootPart
    cam.CameraType = Enum.CameraType.Custom
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
            AutoAttackEnabled = false
            AutoSkillEnabled = false
            AutoSkipHeliEnabled = false
            AutoFillUpEnabled = false
            FillUpRunning = false
            if AutoStartEnabled then
                AutoStartEnabled = false
                StopAutoStart()
            end
        end
        Config:Set("AutoFarmEnabled", state)
        Config:Save()
    end
})

Main:Section({ Title = "Farm Settings", Icon = "settings" })

PositionDropdown = Main:Dropdown({
    Title = "Position Farm",
    Values = { "Above", "Under" },
    Multi = false,
    Value = FarmPosition,
    Callback = function(value)
        FarmPosition = value
        Config:Set("FarmPosition", value)
        Config:Save()
    end
})

ModeDropdown = Main:Dropdown({
    Title = "Mode Farm",
    Values = { "Tween" },
    Multi = false,
    Value = FarmMode,
    Callback = function(value)
        FarmMode = value
        Config:Set("FarmMode", value)
        Config:Save()
    end
})

MiscDropdown = Main:Dropdown({
    Title = "Misc Farm",
    Values = { "Auto Attack", "Auto Skill", "Auto Start", "Auto Skip Helicopter", "Auto Fill Up", "Safe Mode", "Delete Map" },
    Multi = true,
    Value = MiscOptions,
    Callback = function(values)
        MiscOptions = values
        HandleMiscOptions(values)
    end
})

Main:Section({ Title = "Override Settings", Icon = "ruler" })

PaddingReduceInput = Main:Input({
    Title = "Set Padding Reduce",
    Default = tostring(PADDING_REDUCE_STEP),
    Placeholder = "Default: 2",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            PADDING_REDUCE_STEP = num
            Config:Set("PaddingReduceStep", num)
            Config:Save()
        else
            warn("Entered an incorrect number!")
        end
    end
})

PaddingSafeInput = Main:Input({
    Title = "Set Padding Safe",
    Default = tostring(PADDING_SAFE_MIN),
    Placeholder = "Default: -30",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            PADDING_SAFE_MIN = num
            Config:Set("PaddingSafeMin", num)
            Config:Save()
        else
            warn("Entered an incorrect number!")
        end
    end
})

PaddingCheckInput = Main:Input({
    Title = "Set Padding Check",
    Default = tostring(PADDING_CHECK_INTERVAL),
    Placeholder = "Default: 1",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            PADDING_CHECK_INTERVAL = num
            Config:Set("PaddingCheckInterval", num)
            Config:Save()
        else
            warn("Entered an incorrect number!")
        end
    end
})

Main:Section({ Title = "General Settings", Icon = "zap" })

SkillDropdown = Main:Dropdown({
    Title = "Auto Skill (Keys)",
    Values = skillDropdownValues,
    Multi = true,
    Value = SelectedSkills,
    Callback = function(values)
        SelectedSkills = values
        Config:Set("SelectedSkills", values)
        Config:Save()
    end
})

SkillDelaySlider = Main:Slider({
    Title = "Skill Delay (S)",
    Value = { Min = 1, Max = 30, Default = SkillDelay },
    Step = 1,
    Callback = function(value)
        SkillDelay = value
        Config:Set("SkillDelay", value)
        Config:Save()
    end
})

SafeModeSlider = Main:Slider({
    Title = "Safe Mode HP (%)",
    Value = { Min = 1, Max = 100, Default = SafeValue },
    Step = 1,
    Callback = function(value)
        SafeValue = value
        Config:Set("SafeValue", value)
        Config:Save()
    end
})

FarmHeightSlider = Main:Slider({
    Title = "Farm Height (+Y)",
    Value = { Min = 1, Max = 30, Default = HeightValue },
    Step = 1,
    Callback = function(value)
        HeightValue = value
        Config:Set("HeightValue", value)
        Config:Save()
    end
})

Main:Section({ Title = "Flush Settings", Icon = "toilet" })

local Flushaura = Config:Get("flushaura", false)
local FlushAuraValue = Config:Get("FlushAuraValue", 5)

Main:Slider({
    Title    = "Flush Aura (stud)",
    Value    = { Min = 1, Max = 15, Default = FlushAuraValue },
    Step     = 1,
    Callback = function(value)
        FlushAuraValue = value
        Config:Set("FlushAuraValue", value)
        Config:Save()
    end
})

Main:Toggle({
    Title    = "Flush Aura",
    Value    = Flushaura,
    Callback = function(enabled)
        Flushaura = enabled
        Config:Set("flushaura", enabled)
        Config:Save()

        if enabled then
            task.spawn(function()
                while Flushaura do
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        local char = player.Character
                        if not char then return end

                        local root = char:FindFirstChild("HumanoidRootPart")
                        if not root then return end

                        for _, prompt in pairs(workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                if prompt.ActionText == "Flush"
                                or prompt.ActionText == "Dragon Flash"
                                or prompt.ActionText == "flush"
                                or prompt.ActionText == "Flash" then

                                    local part = prompt.Parent
                                    if part and part:IsA("BasePart") then
                                        local distance = (root.Position - part.Position).Magnitude

                                        if distance <= FlushAuraValue then
                                            prompt.HoldDuration = 0
                                            prompt.MaxActivationDistance = FlushAuraValue

                                            if fireproximityprompt then
                                                fireproximityprompt(prompt)
                                            else
                                                prompt:InputHoldBegin()
                                                task.wait()
                                                prompt:InputHoldEnd()
                                            end
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
    Enabled = Config:Get("EspEnabled", false),
    MobEnabled    = Config:Get("EspMobEnabled", true),
    PlayerEnabled = Config:Get("EspPlayerEnabled", true),
    ItemEnabled   = Config:Get("EspItemEnabled", true),
    Settings = Config:Get("EspSettings", { "Highlight", "Distance", "Health", "Name" }),
    SelectedItems = Config:Get("EspSelectedItems", {}),
    MaxDistance = 1500,
    _mobHighlights    = {},
    _playerHighlights = {},
    _itemHighlights   = {},
    _connections = {},
    -- ESP Item Dropdown ใช้ list เดียวกับ CollectItems
    ItemList = {
        "Clock Spider",
        "X-18 Core",
        "Green Energy Core",
        "Weird Transmitter",
        "Presents",
        "Weird Prism",
        "Key Card",
        "Zombie Core",
        "Flash Drives",
        "Astro Samples",
    },
    MobList = {},
}

-- ====================== ESP MATCH HELPER ======================
-- ใช้ logic เดียวกับ Collect (prefix + group map)
local function IsESPItemTarget(objectName, selectedList)
    for _, pattern in ipairs(selectedList) do
        -- Exact
        if objectName:lower() == pattern:lower() then return true end
        -- Prefix
        if #objectName > #pattern then
            if objectName:lower():sub(1, #pattern) == pattern:lower() then
                local nc = objectName:lower():sub(#pattern + 1, #pattern + 1)
                if nc == " " or nc == "#" or nc == "_" or nc == "-" then
                    return true
                end
            end
        end
        -- Group map
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
    billboard.Name = "DYHUB_ESP_LABEL"
    billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false
    billboard.Adornee = parent
    billboard.Parent = parent

    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.fromScale(1, 1)
    frame.Parent = billboard

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.4
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Text = labelText
    label.Parent = frame

    return billboard, label
end

local function CreateHighlight(model, outlineColor, fillColor, fillTransparency)
    local existing = model:FindFirstChild("DYHUB_ESP_HIGHLIGHT")
    if existing then existing:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name = "DYHUB_ESP_HIGHLIGHT"
    hl.OutlineColor = outlineColor
    hl.FillColor = fillColor
    hl.FillTransparency = fillTransparency or 0.9
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = model
    return hl
end

local function RemoveESP(model)
    pcall(function()
        local hl = model:FindFirstChild("DYHUB_ESP_HIGHLIGHT")
        if hl then hl:Destroy() end
        local hb = model:FindFirstChild("DYHUB_ESP_LABEL")
        if hb then hb:Destroy() end
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp then
            local lb = hrp:FindFirstChild("DYHUB_ESP_LABEL")
            if lb then lb:Destroy() end
        end
    end)
end

local function IsInRange(targetPart)
    if not targetPart then return false end
    if not HumanoidRootPart then return false end
    local dist = (HumanoidRootPart.Position - targetPart.Position).Magnitude
    return dist <= ESP.MaxDistance
end

local function BuildLabelText(model, showName, showHealth, showDistance)
    local parts = {}
    if showName then table.insert(parts, model.Name) end
    if showHealth then
        local humanoid = model:FindFirstChild("Humanoid")
        if humanoid then
            local hp = math.floor(humanoid.Health)
            local maxHp = math.floor(humanoid.MaxHealth)
            table.insert(parts, "❤ " .. hp .. "/" .. maxHp)
        end
    end
    if showDistance then
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp and HumanoidRootPart then
            local dist = math.floor((HumanoidRootPart.Position - hrp.Position).Magnitude)
            table.insert(parts, "📏 " .. dist .. "m")
        end
    end
    return table.concat(parts, "\n")
end

local function BuildItemLabelText(obj, showName, showDistance)
    local parts = {}
    if showName then table.insert(parts, obj.Name) end
    if showDistance then
        local root = obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") or (obj:IsA("BasePart") and obj or nil)
        if not root and obj:IsA("Model") then root = obj.PrimaryPart end
        if root and HumanoidRootPart then
            local dist = math.floor((HumanoidRootPart.Position - root.Position).Magnitude)
            table.insert(parts, "📏 " .. dist .. "m")
        end
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
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local settings = GetESPSettings()
    if settings.highlight then
        CreateHighlight(mob, Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 255, 255), 0.9)
    end
    if settings.name or settings.health or settings.distance then
        local _, label = CreateESPLabel(hrp, "", Color3.fromRGB(255, 255, 255))
        task.spawn(function()
            while mob and mob.Parent and ESP.Enabled and ESP.MobEnabled do
                local humanoid = mob:FindFirstChild("Humanoid")
                if not humanoid or humanoid.Health <= 0 then break end
                if not IsInRange(hrp) then
                    label.Visible = false
                    task.wait(0.5)
                else
                    label.Visible = true
                    label.Text = BuildLabelText(mob, settings.name, settings.health, settings.distance)
                    task.wait(0.15)
                end
            end
            RemoveESP(mob)
            ESP._mobHighlights[mob] = nil
        end)
    end
    ESP._mobHighlights[mob] = true
end

local function ScanMobs()
    local livingFolder = workspace:FindFirstChild("Living")
    if not livingFolder then return end
    local mobNames = {}
    for _, obj in ipairs(livingFolder:GetChildren()) do
        if IsValidMob(obj) then
            if not table.find(mobNames, obj.Name) then
                table.insert(mobNames, obj.Name)
            end
        end
    end
    ESP.MobList = mobNames
    for _, mob in ipairs(livingFolder:GetChildren()) do
        if IsValidMob(mob) and not ESP._mobHighlights[mob] then
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hrp and IsInRange(hrp) then
                ApplyMobESP(mob)
            end
        end
    end
end

local function ApplyPlayerESP(playerChar)
    if not playerChar or not playerChar.Parent then return end
    local hrp = playerChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if playerChar == LocalPlayer.Character then return end
    local settings = GetESPSettings()
    if settings.highlight then
        CreateHighlight(playerChar, Color3.fromRGB(50, 255, 50), Color3.fromRGB(255, 255, 255), 0.9)
    end
    if settings.name or settings.health or settings.distance then
        local _, label = CreateESPLabel(hrp, "", Color3.fromRGB(255, 255, 255))
        task.spawn(function()
            while playerChar and playerChar.Parent and ESP.Enabled and ESP.PlayerEnabled do
                local humanoid = playerChar:FindFirstChild("Humanoid")
                if not humanoid or humanoid.Health <= 0 then break end
                if not IsInRange(hrp) then
                    label.Visible = false
                    task.wait(0.5)
                else
                    label.Visible = true
                    label.Text = BuildLabelText(playerChar, settings.name, settings.health, settings.distance)
                    task.wait(0.15)
                end
            end
            RemoveESP(playerChar)
            ESP._playerHighlights[playerChar] = nil
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
                if hrp and IsInRange(hrp) then
                    ApplyPlayerESP(char)
                end
            end
        end
    end
end

local function GetItemRoot(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
    elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
        return obj
    end
    return nil
end

local function ApplyItemESP(obj)
    if not obj or not obj.Parent then return end
    local root = GetItemRoot(obj)
    if not root then return end
    local settings = GetESPSettings()
    local adornee = obj:IsA("Model") and obj or obj
    if settings.highlight then
        CreateHighlight(adornee, Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 255, 255), 0.9)
    end
    if settings.name or settings.distance then
        local labelParent = root
        local _, label = CreateESPLabel(labelParent, "", Color3.fromRGB(255, 255, 255))
        task.spawn(function()
            while obj and obj.Parent and ESP.Enabled and ESP.ItemEnabled do
                local currentRoot = GetItemRoot(obj)
                if not currentRoot then break end
                if not IsInRange(currentRoot) then
                    label.Visible = false
                    task.wait(0.5)
                else
                    label.Visible = true
                    label.Text = BuildItemLabelText(obj, settings.name, settings.distance)
                    task.wait(0.25)
                end
            end
            RemoveESP(obj)
            ESP._itemHighlights[obj] = nil
        end)
    end
    ESP._itemHighlights[obj] = true
end

local function ScanItems()
    if #ESP.SelectedItems == 0 then return end
    local function CheckDescendants(container)
        for _, obj in ipairs(container:GetDescendants()) do
            if not ESP._itemHighlights[obj] then
                -- ใช้ IsESPItemTarget แทน table.find
                if IsESPItemTarget(obj.Name, ESP.SelectedItems) then
                    local root = GetItemRoot(obj)
                    if root and IsInRange(root) then
                        ApplyItemESP(obj)
                    end
                end
            end
        end
    end
    CheckDescendants(workspace)
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
    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end
    local tickCounter = 0
    ESPConnection = RunService.Heartbeat:Connect(function()
        tickCounter = tickCounter + 1
        if tickCounter % 30 == 0 and ESP.Enabled and ESP.MobEnabled then
            pcall(ScanMobs)
        end
        if tickCounter % 47 == 0 and ESP.Enabled and ESP.PlayerEnabled then
            pcall(ScanPlayers)
        end
        if tickCounter % 61 == 0 and ESP.Enabled and ESP.ItemEnabled then
            pcall(ScanItems)
        end
        if tickCounter >= 3660 then tickCounter = 0 end
    end)
end

local function StopESPLoop()
    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end
    ClearAllESP()
end

workspace.DescendantAdded:Connect(function(obj)
    if not ESP.Enabled or not ESP.ItemEnabled then return end
    if #ESP.SelectedItems == 0 then return end
    task.wait(0.1)
    -- ใช้ IsESPItemTarget แทน table.find
    if IsESPItemTarget(obj.Name, ESP.SelectedItems) then
        if not ESP._itemHighlights[obj] then
            local root = GetItemRoot(obj)
            if root and IsInRange(root) then
                ApplyItemESP(obj)
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if not ESP.Enabled or not ESP.PlayerEnabled then return end
        task.wait(1)
        if not ESP._playerHighlights[char] then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and IsInRange(hrp) then
                ApplyPlayerESP(char)
            end
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
                if hrp and IsInRange(hrp) then
                    ApplyMobESP(obj)
                end
            end
        end)
    end
end

task.spawn(function()
    if not workspace:FindFirstChild("Living") then
        workspace.ChildAdded:Connect(function(child)
            if child.Name == "Living" then
                WatchLivingFolder()
            end
        end)
    else
        WatchLivingFolder()
    end
end)

-- ====================== UI: ESP TAB ======================
Main4:Section({ Title = "Esp Visual", Icon = "eye" })

EspEnableToggle = Main4:Toggle({
    Title = "Enable ESP",
    Value = ESP.Enabled,
    Callback = function(state)
        ESP.Enabled = state
        Config:Set("EspEnabled", state)
        Config:Save()
        if state then StartESPLoop() else StopESPLoop() end
    end
})

EspMobToggle = Main4:Toggle({
    Title = "Mob ESP",
    Value = ESP.MobEnabled,
    Callback = function(state)
        ESP.MobEnabled = state
        Config:Set("EspMobEnabled", state)
        Config:Save()
        if not state then
            for mob, _ in pairs(ESP._mobHighlights) do RemoveESP(mob) end
            ESP._mobHighlights = {}
        end
    end
})

EspPlayerToggle = Main4:Toggle({
    Title = "Player ESP",
    Value = ESP.PlayerEnabled,
    Callback = function(state)
        ESP.PlayerEnabled = state
        Config:Set("EspPlayerEnabled", state)
        Config:Save()
        if not state then
            for char, _ in pairs(ESP._playerHighlights) do RemoveESP(char) end
            ESP._playerHighlights = {}
        end
    end
})

EspItemToggle = Main4:Toggle({
    Title = "Item ESP",
    Value = ESP.ItemEnabled,
    Callback = function(state)
        ESP.ItemEnabled = state
        Config:Set("EspItemEnabled", state)
        Config:Save()
        if not state then
            for obj, _ in pairs(ESP._itemHighlights) do RemoveESP(obj) end
            ESP._itemHighlights = {}
        end
    end
})

Main4:Section({ Title = "Esp Settings", Icon = "settings" })

EspSettingsDropdown = Main4:Dropdown({
    Title = "ESP Options",
    Multi = true,
    Values = { "Highlight", "Distance", "Health", "Name" },
    Value = ESP.Settings,
    Callback = function(value)
        ESP.Settings = value or {}
        Config:Set("EspSettings", value)
        Config:Save()
        if ESP.Enabled then ClearAllESP() end
    end,
})

EspItemDropdown = Main4:Dropdown({
    Title = "ESP Items",
    Multi = true,
    Values = ESP.ItemList,
    Value = ESP.SelectedItems,
    Callback = function(value)
        ESP.SelectedItems = value or {}
        Config:Set("EspSelectedItems", value)
        Config:Save()
        for obj, _ in pairs(ESP._itemHighlights) do RemoveESP(obj) end
        ESP._itemHighlights = {}
        if ESP.Enabled and ESP.ItemEnabled then
            pcall(ScanItems)
        end
    end,
})

-- ====================== UI: PLAYER TAB ======================
Main2:Section({ Title = "Local Player", Icon = "user" })

local WSValue = Config:Get("WSValue", 16)
local JPValue = Config:Get("JPValue", 50)
local NoClip = Config:Get("NoClip", false)

local function updatePlayerStats()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WSValue
        LocalPlayer.Character.Humanoid.JumpPower = JPValue
    end
end

RunService.Stepped:Connect(function()
    if NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
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
    Callback = function(value)
        WSValue = value
        Config:Set("WSValue", value)
        Config:Save()
        updatePlayerStats()
    end
})

Main2:Slider({
    Title = "Set Jumppower",
    Value = { Min = 1, Max = 500, Default = JPValue },
    Step = 1,
    Callback = function(value)
        JPValue = value
        Config:Set("JPValue", value)
        Config:Save()
        updatePlayerStats()
    end
})

nocliptoggle = Main2:Toggle({
    Title = "No Clip",
    Value = NoClip,
    Callback = function(state)
        NoClip = state
        Config:Set("NoClip", state)
        Config:Save()
    end
})

Main2:Section({ Title = "Redeem Codes", Icon = "bird" })

local SelectedCodes = Config:Get("SelectedCodes", {})

CodeDropdown = Main2:Dropdown({
    Title = "Select Redeem Codes",
    Multi = true,
    Values = GlobalTables.redeemCodes,
    Value = SelectedCodes,
    Callback = function(value)
        SelectedCodes = value or {}
        Config:Set("SelectedCodes", value)
        Config:Save()
    end,
})

Main2:Button({
    Title = "Redeem Codes (Selected)",
    Callback = function()
        for _, code in ipairs(SelectedCodes or {}) do
            pcall(function()
                ReplicatedStorage:WaitForChild("RedeemCode"):FireServer(code)
                task.wait(0.2)
            end)
        end
    end,
})

Main2:Button({
    Title = "Redeem Code (All)",
    Callback = function()
        for _, code in ipairs(GlobalTables.redeemCodes or {}) do
            pcall(function()
                ReplicatedStorage:WaitForChild("RedeemCode"):FireServer(code)
                task.wait(0.5)
            end)
        end
    end,
})

Main7:Section({ Title = "Casual Information", TextXAlignment = "Center", TextSize = 17 })
Main7:Divider()

Main7:Paragraph({
    Title = "Casual: Mission Selection",
    Desc = "- [ Step 1 ] Stay in the Lobby (not inside a game) \n- [ Step 2 ] Press Play and go to the Classic gamemode selection screen \n- [ Step 3 ] Select Casual and finish teleporting \n- [ Step 4 ] Run the script",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})
Main7:Divider()
Main7:Section({ Title = "Game Mode", Icon = "gamepad-2" })

local AutoVoteValue = Config:Get("AutoVoteValue", "Normal Mode")
local AutoVoteEnabled = Config:Get("AutoVoteEnabled", false)

GameModeDropdown = Main7:Dropdown({
    Title = "Set Game Mode",
    Values = GlobalTables.Mode,
    Multi = false,
    Value = AutoVoteValue,
    Callback = function(value)
        AutoVoteValue = value
        ReplicatedStorage:WaitForChild("Vote"):FireServer(value)
        Config:Set("AutoVoteValue", value)
        Config:Save()
    end
})

AutoVoteToggle = Main7:Toggle({
    Title = "Auto Game Mode",
    Value = AutoVoteEnabled,
    Callback = function(enabled)
        AutoVoteEnabled = enabled

        Config:Set("AutoVoteEnabled", enabled)
        Config:Save()

        if enabled then
            task.spawn(function()
                while AutoVoteEnabled do
                    if AutoVoteValue then
                        pcall(function()
                            local args = {
                                [1] = {
                                    [1] = "StartSolo",
                                    [2] = AutoVoteValue
                                }
                            }
                            
                            game:GetService("ReplicatedStorage").MainHandler:FireServer(unpack(args))
                        end)
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

Main7:Section({ Title = "Vote Mode", Icon = "gamepad-2" })

local AutoVoteValue2 = Config:Get("AutoVoteValue2", "Normal Mode")
local AutoVoteinGameEnabled = Config:Get("AutoVoteinGameEnabled", false)

GameModeDropdown2 = Main7:Dropdown({
    Title = "Set Vote Mode",
    Values = GlobalTables.Votes,
    Multi = false,
    Value = AutoVoteValue2,
    Callback = function(value)
        AutoVoteValue2 = value
        ReplicatedStorage:WaitForChild("Vote"):FireServer(value)
        Config:Set("AutoVoteValue2", value)
        Config:Save()
    end
})

AutoVoteIGToggle = Main7:Toggle({
    Title = "Auto Vote Mode (In-Game)",
    Value = AutoVoteinGameEnabled,
    Callback = function(enabled)
        AutoVoteinGameEnabled = enabled

        Config:Set("AutoVoteinGameEnabled", enabled)
        Config:Save()

        if enabled then
            task.spawn(function()
                while AutoVoteinGameEnabled do
                    if AutoVoteValue2 then
                        pcall(function()
                            ReplicatedStorage.Vote:FireServer(AutoVoteValue2)
                        end)
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

-- ====================== UI: AUTO BUY ======================
Main5:Section({ Title = "Shop Weapon", Icon = "helicopter" })

local AutoBuyWeaponValue = Config:Get("AutoBuyWeaponValue", "Stungun")
local AutoBuyWeaponToggleEnabled = Config:Get("AutoBuyWeaponEnabled", false)

WeaponDropdown = Main5:Dropdown({
    Title = "Select Buy (Weapon)",
    Values = GlobalTables.Weapon,
    Multi = false,
    Value = AutoBuyWeaponValue,
    Callback = function(value)
        AutoBuyWeaponValue = value
        Config:Set("AutoBuyWeaponValue", value)
        Config:Save()
    end
})

AutoBuyWeaponToggle = Main5:Toggle({
    Title = "Auto Buy (Weapon)",
    Value = AutoBuyWeaponToggleEnabled,
    Callback = function(enabled)
        AutoBuyWeaponToggleEnabled = enabled
        Config:Set("AutoBuyWeaponEnabled", enabled)
        Config:Save()
        if enabled then
            task.spawn(function()
                while AutoBuyWeaponToggleEnabled do
                    if AutoBuyWeaponValue then
                        pcall(function()
                            local args = { [1] = "Buy", [2] = AutoBuyWeaponValue }
                            ReplicatedStorage.ShopSystem:FireServer(unpack(args))
                        end)
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
        if AutoBuyWeaponValue then
            pcall(function()
                local args = { [1] = "Buy", [2] = AutoBuyWeaponValue }
                ReplicatedStorage.ShopSystem:FireServer(unpack(args))
            end)
        end
    end
})

Main5:Section({ Title = "Shop Misc", Icon = "helicopter" })

local AutoBuyMiscValue = Config:Get("AutoBuyMiscValue", "HeadPhone")
local AutoBuyMiscToggleEnabled = Config:Get("AutoBuyMiscEnabled", false)

MiscShopDropdown = Main5:Dropdown({
    Title = "Select Buy (Misc)",
    Values = GlobalTables.MiscShop,
    Multi = false,
    Value = AutoBuyMiscValue,
    Callback = function(value)
        AutoBuyMiscValue = value
        Config:Set("AutoBuyMiscValue", value)
        Config:Save()
    end
})

AutoBuyMiscToggle = Main5:Toggle({
    Title = "Auto Buy (Misc)",
    Value = AutoBuyMiscToggleEnabled,
    Callback = function(enabled)
        AutoBuyMiscToggleEnabled = enabled
        Config:Set("AutoBuyMiscEnabled", enabled)
        Config:Save()
        if enabled then
            task.spawn(function()
                while AutoBuyMiscToggleEnabled do
                    if AutoBuyMiscValue then
                        pcall(function()
                            local args = { [1] = "Buy", [2] = AutoBuyMiscValue }
                            ReplicatedStorage.ShopSystem:FireServer(unpack(args))
                        end)
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
        if AutoBuyMiscValue then
            pcall(function()
                local args = { [1] = "Buy", [2] = AutoBuyMiscValue }
                ReplicatedStorage.ShopSystem:FireServer(unpack(args))
            end)
        end
    end
})

-- ============================================================
-- ====================== UI: COLLECT TAB =====================
-- ============================================================

Main6:Section({ Title = "Collect Item", Icon = "package" })

AutoCollectToggle = Main6:Toggle({
    Title = "Auto Collect",
    Value = AutoCollectEnabled,
    Callback = function(state)
        AutoCollectEnabled = state
        Config:Set("AutoCollectEnabled", state)
        Config:Save()
        if state then
            KnownCollectItems = {}
            StartAutoCollectLoop()
        else
            CollectRunning = false
        end
    end
})

Main6:Section({ Title = "Setting Collect", Icon = "settings" })

CollectItemDropdown = Main6:Dropdown({
    Title = "Item Collect",
    Values = CollectItems,
    Multi = true,
    Value = SelectedCollectItems,
    Callback = function(values)
        SelectedCollectItems = values or {}
        Config:Set("SelectedCollectItems", values)
        Config:Save()
    end
})

CollectModeDropdown = Main6:Dropdown({
    Title = "Mode Collect",
    Values = { "Clean", "IDGF" },
    Multi = false,
    Value = CollectMode,
    Callback = function(value)
        CollectMode = value
        Config:Set("CollectMode", value)
        Config:Save()
    end
})

-- ====================== UI: MISC TAB ======================
-- เพิ่ม Section Save Config
Main3:Section({ Title = "Save Config", Icon = "save" })

Main3:Button({
    Title = "Save Config (NOW)",
    Callback = function()
        Config:Save()
        WindUI:Notify({
            Title = "Config Saved",
            Content = "Config saved successfully!",
            Duration = 2,
            Icon = "save",
        })
    end
})

local AutoSaveEnabled = Config:Get("AutoSaveEnabled", true)
local AutoSaveDelay = Config:Get("AutoSaveDelay", 15)
local AutoSaveThread = nil

local function RestartAutoSave()
    if AutoSaveThread then
        task.cancel(AutoSaveThread)
        AutoSaveThread = nil
    end
    if AutoSaveEnabled then
        AutoSaveThread = task.spawn(function()
            while AutoSaveEnabled do
                task.wait(AutoSaveDelay)
                Config:Save()
                print("[DYHUB] Auto saved config every " .. AutoSaveDelay .. "s")
            end
        end)
    end
end

Main3:Toggle({
    Title = "Auto Save Config",
    Value = AutoSaveEnabled,
    Callback = function(state)
        AutoSaveEnabled = state
        Config:Set("AutoSaveEnabled", state)
        Config:Save()
        RestartAutoSave()
    end
})

Main3:Input({
    Title = "Delay Save Config",
    Default = tostring(AutoSaveDelay),
    Placeholder = "Default: 15",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 then
            AutoSaveDelay = num
            Config:Set("AutoSaveDelay", num)
            Config:Save()
            RestartAutoSave()
        else
            warn("[DYHUB] Invalid delay value!")
        end
    end
})

Main3:Section({ Title = "Server Status", Icon = "server" })

Main3:Button({
    Title = "Serverhop",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local servers = {}
        local success, result = pcall(function()
            return HttpService:JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
            )
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end
        end
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            WindUI:Notify({
                Title = "Serverhop",
                Content = "Teleporting to another server...",
                Duration = 2,
                Icon = "server",
            })
            task.wait(1)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
        else
            WindUI:Notify({
                Title = "Serverhop Failed",
                Content = "No available servers found.",
                Duration = 3,
                Icon = "alert-triangle",
            })
        end
    end
})

Main3:Button({
    Title = "Rejoin",
    Callback = function()
        WindUI:Notify({
            Title = "Rejoin",
            Content = "Rejoining server...",
            Duration = 2,
            Icon = "refresh-cw",
        })
        task.wait(1)
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

Main3:Section({ Title = "Miscellaneous", Icon = "settings" })

NoBarrierToggle = Main3:Toggle({
    Title = "Bypass Barrier (PATCHED)",
    Value = noBarrierActive,
    Callback = function(value)
        noBarrierActive = value
        Config:Set("NoBarrier", value)
        Config:Save()
        if value then
            startNoBarrier()
        else
            stopNoBarrier()
        end
    end
})

local antiafk = Main3:Toggle({
    Title = "Anti AFK",
    Value = hi1,
    Callback = function(enabled)
        hi1 = enabled
        Config:Set("hi2", enabled)
        Config:Save()

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

if noBarrierActive then
    startNoBarrier()
end

if ESP.Enabled then
    task.wait(2)
    StartESPLoop()
end

if AutoBuyWeaponToggleEnabled then
    task.spawn(function()
        while AutoBuyWeaponToggleEnabled do
            if AutoBuyWeaponValue then
                pcall(function()
                    local args = { [1] = "Buy", [2] = AutoBuyWeaponValue }
                    ReplicatedStorage.ShopSystem:FireServer(unpack(args))
                end)
            end
            task.wait(10)
        end
    end)
end

if AutoBuyMiscToggleEnabled then
    task.spawn(function()
        while AutoBuyMiscToggleEnabled do
            if AutoBuyMiscValue then
                pcall(function()
                    local args = { [1] = "Buy", [2] = AutoBuyMiscValue }
                    ReplicatedStorage.ShopSystem:FireServer(unpack(args))
                end)
            end
            task.wait(10)
        end
    end)
end

if AutoCollectEnabled then
    task.wait(2)
    StartAutoCollectLoop()
end

print("[DYHUB] Version " .. version .. " loaded successfully!")
print("[DYHUB] Config system active | Auto saving every 15 seconds")
