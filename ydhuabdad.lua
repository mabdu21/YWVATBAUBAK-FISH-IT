-- v018
-- =========================
local version = "Early Access"
-- =========================

repeat task.wait() until game:IsLoaded()

-- ====================== FPS UNLOCK ======================
local part = Instance.new("Part")
part.Size = Vector3.new(10, 1, 10)
part.Position = Vector3.new(-23.3435822, 62.5, 0.341766357)
part.Transparency = 1
part.Anchored = true
part.CanCollide = true
part.Material = Enum.Material.Neon
part.BrickColor = BrickColor.new("Bright blue")
part.Name = "DYHUB_WAITING_PART"
part.Parent = workspace

if setfpscap then
    setfpscap(1000000)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "dsc.gg/dyhub",
        Text = "FPS Unlocked! | v018",
        Duration = 2,
        Button1 = "Okay"
    })
    warn("FPS Unlocked!")
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "dsc.gg/dyhub",
        Text = "Your exploit does not support setfpscap.",
        Duration = 2,
        Button1 = "Okay"
    })
    warn("Your exploit does not support setfpscap.")
end

-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ====================== CUSTOM CONFIG SYSTEM ======================
local HttpService = game:GetService("HttpService")
local ConfigFolder = "DYHUB_ST33_CONFIG"

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
            task.wait(interval or 30)
            self:Save()
        end
    end)
end

local Config = CustomConfig.new()
Config:AutoSave(30)

-- ====================== WINDOW ======================
local Window = WindUI:CreateWindow({
    Title = "DYHUB",
    IconThemed = true,
    Icon = "rbxassetid://104487529937663",
    Author = "STBB | Beta Version",
    Folder = "DYHUB_STBB",
    Size = UDim2.fromOffset(550, 380),
    Transparent = true,
    Theme = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

Window:Tag({ Title = version, Color = Color3.fromHex("#ffd700") })

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
local MainDivider = Window:Divider()
local Main = Window:Tab({ Title = "Main", Icon = "rocket" })
local Main4 = Window:Tab({ Title = "Esp", Icon = "eye" })
local Main2 = Window:Tab({ Title = "Player", Icon = "user" })
local MainDivider1 = Window:Divider()
local Main5 = Window:Tab({ Title = "Shop", Icon = "shopping-cart" })
local Main6 = Window:Tab({ Title = "Collect", Icon = "hand" })
local MainDivider2 = Window:Divider()
local Main3 = Window:Tab({ Title = "Misc", Icon = "settings" })
Window:SelectTab(1)

-- ======================== INFO ========================
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
        "Normal", "Hard", "VeryHard", "Insane", "Nightmare", "BossRush",
        "ThunderStorm", "Zombie", "Christmas", "Hell", "DarkDimension", "Astro",
        "AstroV2", "100MVisit"
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
local skillList = { "Q", "E", "R", "T", "Y", "G", "H", "Z", "X", "C", "V", "B" }
local skillDropdownValues = { "All", "Q", "E", "R", "T", "Y", "G", "H", "Z", "X", "C", "V", "B" }

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

-- ====================== ADAPTIVE HEIGHT SYSTEM ======================
-- เก็บ padding ที่ปรับแล้วต่อ mob (ใช้ชื่อ + position เป็น key)
local MobAdaptivePadding = {}
-- เก็บ health snapshot ของ mob ก่อนหน้า เพื่อตรวจว่าเราดาเมจมันได้หรือเปล่า
local MobHealthSnapshot = {}

local ADAPTIVE_CHECK_INTERVAL = 3    -- วินาที รอดูว่า hp ลดหรือไม่
local ADAPTIVE_STEP = 1              -- ลด padding ครั้งละกี่หน่วย
local ADAPTIVE_MIN_PADDING = -2      -- ต่ำสุดที่ยอมให้ลด (ไม่ให้ลงต่ำเกินจน mob ตีกลับ)

local function GetMobAdaptiveKey(mob)
    -- ใช้ชื่อเป็น key เพื่อให้ mob ตัวเดิมจำ padding ได้
    return mob.Name
end

local function GetAdaptivePadding(mob)
    local key = GetMobAdaptiveKey(mob)
    if MobAdaptivePadding[key] ~= nil then
        return MobAdaptivePadding[key]
    end
    return HeightValue
end

local function SetAdaptivePadding(mob, value)
    local key = GetMobAdaptiveKey(mob)
    MobAdaptivePadding[key] = value
    -- save ไป config
    Config:Set("AdaptivePadding_" .. key, value)
end

local function ResetAdaptivePadding(mob)
    local key = GetMobAdaptiveKey(mob)
    MobAdaptivePadding[key] = nil
    Config:Set("AdaptivePadding_" .. key, nil)
end

-- โหลด adaptive padding จาก config ตอนเริ่ม
-- (โหลดหลัง Config.new() แล้ว ดังนั้นทำที่นี่ได้)
local function LoadAdaptivePaddingFromConfig()
    local prefix = "AdaptivePadding_"
    -- ไม่สามารถ iterate keys ของ Config ได้ตรงๆ แต่เราจะโหลด on-demand ใน GetAdaptivePadding
    -- ตรงนี้เป็น placeholder สำหรับ future
end
LoadAdaptivePaddingFromConfig()

-- ====================== TARGET CFRAME (with adaptive height) ======================
local function GetTargetCFrame(mob, position, overridePadding)
    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
    local mobHead = mob:FindFirstChild("Head")
    local mobHumanoid = mob:FindFirstChild("Humanoid")
    if not mobRoot then return nil end
    local mobHeight = GetMobSize(mob)
    local padding = overridePadding ~= nil and overridePadding or GetAdaptivePadding(mob)
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

-- ====================== ADAPTIVE HEIGHT WATCHER ======================
-- เปิด task เพื่อตรวจ mob HP ว่าเราตีได้หรือเปล่า ถ้าไม่ได้ให้ลด padding
local ActiveAdaptiveTasks = {}

local function StartAdaptiveWatcher(mob)
    local key = GetMobAdaptiveKey(mob)
    if ActiveAdaptiveTasks[key] then return end -- มีแล้ว

    ActiveAdaptiveTasks[key] = true
    task.spawn(function()
        -- รอก่อน 1 วิ ให้ระบบเริ่มตีก่อน
        task.wait(1)

        while AutoFarmEnabled and mob and mob.Parent and not IsMobDead(mob) do
            local humanoid = mob:FindFirstChild("Humanoid")
            if not humanoid then break end

            local hpBefore = humanoid.Health
            MobHealthSnapshot[key] = hpBefore

            -- รอ ADAPTIVE_CHECK_INTERVAL วิ
            task.wait(ADAPTIVE_CHECK_INTERVAL)

            -- ตรวจอีกทีว่า mob ยังมีชีวิตอยู่
            if IsMobDead(mob) then break end

            local hpAfter = humanoid.Health
            local currentPadding = GetAdaptivePadding(mob)

            -- ถ้า hp ไม่ลดเลย และ padding ยัง > ADAPTIVE_MIN_PADDING
            if hpAfter >= hpBefore and currentPadding > ADAPTIVE_MIN_PADDING then
                local newPadding = math.max(ADAPTIVE_MIN_PADDING, currentPadding - ADAPTIVE_STEP)
                SetAdaptivePadding(mob, newPadding)
                print(string.format("[DYHUB] Adaptive: %s HP not dropping (%.0f), reducing padding: %.1f -> %.1f",
                    mob.Name, hpAfter, currentPadding, newPadding))
            elseif hpAfter < hpBefore then
                -- ตีได้แล้ว ล็อค padding นี้ไว้ (ไม่ reset กลับ แต่หยุด watcher)
                print(string.format("[DYHUB] Adaptive: %s HP dropping (%.0f -> %.0f), locking padding at %.1f",
                    mob.Name, hpBefore, hpAfter, currentPadding))
                break
            end
        end

        -- mob ตายแล้ว -> reset padding กลับเป็น default เฉพาะถ้ามันตาย
        if IsMobDead(mob) then
            ResetAdaptivePadding(mob)
            print("[DYHUB] Adaptive: " .. mob.Name .. " died, padding reset to default")
        end

        ActiveAdaptiveTasks[key] = nil
    end)
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
    -- เริ่ม adaptive watcher ทันทีที่ teleport ไปหา mob
    StartAdaptiveWatcher(mob)
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
            -- [v018] ตรวจว่ามี mob ก่อนใช้ skill
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

-- ====================== COLLECT SYSTEM ======================
local CollectEnabled = Config:Get("CollectEnabled", false)
local SelectedCollectItems = Config:Get("SelectedCollectItems", {})
local CollectMode = Config:Get("CollectMode", "IDGF")
local CollectRunning = false

local CollectItemList = {
    "Clock Spider", "Transmitter", "Flash Drive", "Astro Samples (Bugs)",
    "X-18", "The Present", "Lightning module", "Drive"
}

-- ตาราง track ว่า item ไหนเจอแล้ว (เช็คใหม่/เก่า)
local SeenCollectItems = {}

-- หา item object ใน workspace ทั้งหมด (ไม่สนว่าอยู่ใน folder ไหน)
local function FindCollectItems()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local isTarget = false
        for _, name in ipairs(SelectedCollectItems) do
            if obj.Name == name then
                isTarget = true
                break
            end
        end
        if isTarget then
            if obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("BasePart") then
                -- เช็คว่าเป็น item ใหม่ (ยังไม่เคยเห็น)
                if not SeenCollectItems[obj] then
                    table.insert(found, obj)
                end
            end
        end
    end
    return found
end

-- คืนค่า root part ของ item (สำหรับ tween ไปหา)
local function GetItemRootPart(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
    elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
        return obj
    end
    return nil
end

-- คำนวณ CFrame สำหรับไปหา item (ลอยบน item เหมือน auto farm ลอยบน mob)
local function GetItemTargetCFrame(obj)
    local root = GetItemRootPart(obj)
    if not root then return nil end
    local itemPos = root.Position
    local hoverHeight = 3 + HeightValue -- ลอยสูงกว่า item
    local targetPos = itemPos + Vector3.new(0, hoverHeight, 0)
    local lookCF = CFrame.new(targetPos, itemPos)
    return lookCF * CFrame.Angles(math.rad(-10), 0, 0)
end

-- tween ไปหา item
local function TweenToItem(obj)
    local cf = GetItemTargetCFrame(obj)
    if not cf then return end
    local tweenInfo = TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, { CFrame = cf })
    tween:Play()
    tween.Completed:Wait()
end

-- ยิง ProximityPrompt บน item (ใช้ระบบเดียวกับ GiantST)
local function ActivateItemPrompts(obj)
    pcall(function()
        local function tryPromptOn(target)
            if not target then return end
            local prompt = target:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                prompt.HoldDuration = 0
                prompt.MaxActivationDistance = 50
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                else
                    prompt:InputHoldBegin()
                    task.wait(0.05)
                    prompt:InputHoldEnd()
                end
            end
        end

        if obj:IsA("Model") then
            tryPromptOn(obj)
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("BasePart") or child:IsA("MeshPart") or child:IsA("Part") then
                    tryPromptOn(child)
                end
            end
        else
            tryPromptOn(obj)
            tryPromptOn(obj.Parent)
        end
    end)
end

-- ตรวจว่า item ถูกเก็บแล้วหรือยัง (ออกจาก workspace แล้ว)
local function IsItemGone(obj)
    return not obj or not obj.Parent
end

-- เก็บ item ตัวเดียว
local function CollectSingleItem(obj)
    if IsItemGone(obj) then return end
    SeenCollectItems[obj] = true -- mark ว่าเห็นแล้ว

    print("[DYHUB] Collect: Going to " .. obj.Name)

    -- tween ไปหา item
    TweenToItem(obj)

    -- lock ตำแหน่งไว้บน item แล้ว spam ProximityPrompt
    local lockConn
    lockConn = RunService.RenderStepped:Connect(function()
        if IsItemGone(obj) or not CollectEnabled then
            lockConn:Disconnect()
            return
        end
        local cf = GetItemTargetCFrame(obj)
        if cf and Character and HumanoidRootPart then
            Character:PivotTo(cf)
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    -- spam ProximityPrompt จนกว่า item จะหาย
    local timeout = 0
    repeat
        ActivateItemPrompts(obj)
        task.wait(0.05)
        timeout = timeout + 0.05
        if timeout > 10 then
            print("[DYHUB] Collect: Timeout on " .. obj.Name .. ", skipping...")
            break
        end
    until IsItemGone(obj) or not CollectEnabled

    lockConn:Disconnect()

    if IsItemGone(obj) then
        print("[DYHUB] Collect: " .. obj.Name .. " collected!")
    end
end

-- เช็คว่า mob ทั้งหมดตายหมดแล้วหรือยัง (สำหรับ Clean mode)
local function AreAllMobsDead()
    local livingFolder = workspace:FindFirstChild("Living")
    if not livingFolder then return true end
    for _, obj in ipairs(livingFolder:GetChildren()) do
        if IsValidMob(obj) then return false end
    end
    return true
end

-- ====================== COLLECT LOOP CORE ======================
local CollectLoopRunning = false

local function DoCollectRound()
    -- หา item ที่ต้องเก็ก
    local items = FindCollectItems()
    if #items == 0 then return end

    print("[DYHUB] Collect: Found " .. #items .. " items to collect")

    -- ถ้า AutoSkipHeli เปิดอยู่ -> หยุดก่อน (ทำให้ wave ไม่ skip ระหว่างเก็บ)
    local wasAutoSkipHeli = AutoSkipHeliEnabled
    if wasAutoSkipHeli then
        print("[DYHUB] Collect: Pausing Auto Skip Heli for collect...")
        TriggerAutoSkipHeli(false)
    end

    -- เก็บ items ทีละตัว
    for _, obj in ipairs(items) do
        if not CollectEnabled then break end
        if not IsItemGone(obj) then
            CollectSingleItem(obj)
            task.wait(0.2)
        end
    end

    -- กลับ idle หลังเก็บ
    TeleportToIdle()
    WaitingRespawn = false

    -- Auto Fill Up ถ้า HP ไม่เต็ม
    if AutoFillUpEnabled and not IsPlayerHPFull() then
        print("[DYHUB] Collect: HP not full after collect, doing fill up...")
        DoFillUp()
        task.wait(1)
    end

    -- คืน Auto Skip Heli
    if wasAutoSkipHeli then
        print("[DYHUB] Collect: Resuming Auto Skip Heli...")
        TriggerAutoSkipHeli(true)
    end
end

local function StartCollectLoop()
    if CollectLoopRunning then return end
    CollectLoopRunning = true

    task.spawn(function()
        while CollectEnabled do
            if #SelectedCollectItems == 0 then
                task.wait(1)
            else
                local items = FindCollectItems()

                if #items > 0 then
                    if CollectMode == "IDGF" then
                        -- ====================== IDGF MODE ======================
                        -- ไม่สนใจ mob ที่เหลือ ไปเก็บของก่อนเลย
                        print("[DYHUB] Collect (IDGF): Items found! Going to collect immediately...")

                        -- pause auto farm lock ชั่วคราว
                        local prevLock = LockActive
                        LockActive = false
                        task.wait(0.05)

                        DoCollectRound()

                        -- คืน lock state
                        LockActive = prevLock

                    elseif CollectMode == "Clean" then
                        -- ====================== CLEAN MODE ======================
                        -- รอให้ mob ตายหมดก่อน แล้วค่อยเก็บ
                        if AreAllMobsDead() then
                            print("[DYHUB] Collect (Clean): All mobs dead! Collecting items...")
                            DoCollectRound()
                        else
                            print("[DYHUB] Collect (Clean): Items found but mobs still alive, waiting...")
                        end
                    end
                end
            end

            task.wait(0.5)
        end

        CollectLoopRunning = false
        print("[DYHUB] Collect: Loop stopped.")
    end)
end

-- Watcher: ดัก item ที่เพิ่งปรากฏใน workspace (event-based สำหรับ item ใหม่)
local CollectWatcherConnection = nil

local function StartCollectWatcher()
    if CollectWatcherConnection then return end
    CollectWatcherConnection = workspace.DescendantAdded:Connect(function(obj)
        if not CollectEnabled or #SelectedCollectItems == 0 then return end
        task.wait(0.1) -- รอให้ load เสร็จ
        if not obj or not obj.Parent then return end

        -- เช็คชื่อ
        local isTarget = false
        for _, name in ipairs(SelectedCollectItems) do
            if obj.Name == name then
                isTarget = true
                break
            end
        end
        if not isTarget then return end
        if not (obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("BasePart")) then return end

        -- เป็น item ใหม่ (ยังไม่เคยเห็น)
        if SeenCollectItems[obj] then return end

        print("[DYHUB] Collect Watcher: New item detected - " .. obj.Name)
    end)
end

local function StopCollectWatcher()
    if CollectWatcherConnection then
        CollectWatcherConnection:Disconnect()
        CollectWatcherConnection = nil
    end
end

-- ====================== MAIN FARM LOOP ======================
local function StartFarmLoop()
    task.spawn(function()
        -- Sub-loop: ดัน idle position
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

            -- ถ้า IDGF mode และมี item -> ข้าม mob loop ไปทำ collect แทน
            -- (collect loop จัดการเองอยู่แล้ว แต่ถ้า IDGF ให้หยุด mob targeting)
            if CollectEnabled and CollectMode == "IDGF" and #SelectedCollectItems > 0 then
                local itemsNow = FindCollectItems()
                if #itemsNow > 0 then
                    -- ให้ collect loop จัดการ เราแค่ idle ที่นี่
                    task.wait(0.2)
                    goto continue_farm
                end
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

                    StartAdaptiveWatcher(mob)

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

            ::continue_farm::
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

local AutoFarmToggle = Main:Toggle({
    Title = "Auto Farm",
    Value = AutoFarmEnabled,
    Callback = function(state)
        AutoFarmEnabled = state
        if state then
            StartFarmLoop()
            HandleMiscOptions(MiscOptions)
            -- ถ้า collect เปิดอยู่ด้วย ให้ start collect loop
            if CollectEnabled then
                StartCollectLoop()
                StartCollectWatcher()
            end
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

local PositionDropdown = Main:Dropdown({
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

local ModeDropdown = Main:Dropdown({
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

local MiscDropdown = Main:Dropdown({
    Title = "Misc Farm",
    Values = { "Auto Attack", "Auto Skill", "Auto Start", "Auto Skip Helicopter", "Auto Fill Up", "Safe Mode", "Delete Map" },
    Multi = true,
    Value = MiscOptions,
    Callback = function(values)
        MiscOptions = values
        HandleMiscOptions(values)
    end
})

Main:Section({ Title = "General Settings", Icon = "zap" })

local SkillDropdown = Main:Dropdown({
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

local SkillDelaySlider = Main:Slider({
    Title = "Skill Delay (S)",
    Value = { Min = 1, Max = 30, Default = SkillDelay },
    Step = 1,
    Callback = function(value)
        SkillDelay = value
        Config:Set("SkillDelay", value)
        Config:Save()
    end
})

local SafeModeSlider = Main:Slider({
    Title = "Safe Mode HP (%)",
    Value = { Min = 1, Max = 100, Default = SafeValue },
    Step = 1,
    Callback = function(value)
        SafeValue = value
        Config:Set("SafeValue", value)
        Config:Save()
    end
})

local FarmHeightSlider = Main:Slider({
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
    ItemList = {
        "Clock Spider", "Transmitter", "Flash Drive", "Astro Samples (Bugs)",
        "X-18", "The Present", "Lightning module", "Drive"
    },
    MobList = {},
}

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
                if table.find(ESP.SelectedItems, obj.Name) then
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
    if table.find(ESP.SelectedItems, obj.Name) then
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

local EspEnableToggle = Main4:Toggle({
    Title = "Enable ESP",
    Value = ESP.Enabled,
    Callback = function(state)
        ESP.Enabled = state
        Config:Set("EspEnabled", state)
        Config:Save()
        if state then StartESPLoop() else StopESPLoop() end
    end
})

local EspMobToggle = Main4:Toggle({
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

local EspPlayerToggle = Main4:Toggle({
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

local EspItemToggle = Main4:Toggle({
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

local EspSettingsDropdown = Main4:Dropdown({
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

local EspItemDropdown = Main4:Dropdown({
    Title = "Select Items (ESP)",
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

local nocliptoggle = Main2:Toggle({
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

local CodeDropdown = Main2:Dropdown({
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

Main2:Section({ Title = "Game Mode", Icon = "gamepad-2" })

local AutoVoteValue = Config:Get("AutoVoteValue", "Normal")
local AutoVoteEnabled = Config:Get("AutoVoteEnabled", false)

local GameModeDropdown = Main2:Dropdown({
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

local AutoVoteToggle = Main2:Toggle({
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
                            ReplicatedStorage:WaitForChild("Vote"):FireServer(AutoVoteValue)
                        end)
                    end
                    task.wait(10)
                end
            end)
        end
    end
})

-- ====================== UI: AUTO BUY ======================
Main5:Section({ Title = "Shop Weapon", Icon = "helicopter" })

local AutoBuyWeaponValue = Config:Get("AutoBuyWeaponValue", "Stungun")
local AutoBuyWeaponToggleEnabled = Config:Get("AutoBuyWeaponEnabled", false)

local WeaponDropdown = Main5:Dropdown({
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

local AutoBuyWeaponToggle = Main5:Toggle({
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

local MiscShopDropdown = Main5:Dropdown({
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

local AutoBuyMiscToggle = Main5:Toggle({
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

-- ====================== UI: COLLECT TAB ======================
Main6:Section({ Title = "Collect Item", Icon = "package" })

local AutoCollectToggle = Main6:Toggle({
    Title = "Auto Collect",
    Value = CollectEnabled,
    Callback = function(state)
        CollectEnabled = state
        Config:Set("CollectEnabled", state)
        Config:Save()
        if state then
            -- clear seen table เพื่อ re-detect item ที่มีอยู่แล้ว
            SeenCollectItems = {}
            StartCollectLoop()
            StartCollectWatcher()
        else
            CollectLoopRunning = false
            StopCollectWatcher()
        end
    end
})

Main6:Section({ Title = "Setting Collect", Icon = "settings" })

local CollectItemDropdown = Main6:Dropdown({
    Title = "Select Item (Collect)",
    Values = CollectItemList,
    Multi = true,
    Value = SelectedCollectItems,
    Callback = function(values)
        SelectedCollectItems = values or {}
        Config:Set("SelectedCollectItems", values)
        Config:Save()
        -- reset seen ใหม่เมื่อเปลี่ยน item list
        SeenCollectItems = {}
        print("[DYHUB] Collect: Item list updated, re-scanning...")
    end
})

local CollectModeDropdown = Main6:Dropdown({
    Title = "Mode Collect",
    Values = { "IDGF", "Clean" },
    Multi = false,
    Value = CollectMode,
    Callback = function(value)
        CollectMode = value
        Config:Set("CollectMode", value)
        Config:Save()
        print("[DYHUB] Collect mode set to: " .. value)
    end
})

-- ====================== UI: MISC TAB ======================
Main3:Section({ Title = "Miscellaneous", Icon = "settings" })

local NoBarrierToggle = Main3:Toggle({
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

if CollectEnabled then
    task.wait(2)
    SeenCollectItems = {}
    StartCollectLoop()
    StartCollectWatcher()
end

print("[DYHUB] Version " .. version .. " loaded successfully!")
print("[DYHUB] Config system active | Auto saving every 30 seconds")
