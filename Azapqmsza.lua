-- v085
-- =========================
local version = "Rework"
local ver = "v011.4"
-- =========================
repeat task.wait() until game:IsLoaded()
-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ====================== GameLoad ======================


if setfpscap then
    setfpscap(1000000)
    WindUI:Notify({ Title = "Service", Content = "FPS Unlocked! | " .. ver, Duration = 3, Icon = "cpu" })
    warn("FPS Unlocked!")
else
    WindUI:Notify({ Title = "Not Working", Content = "Your exploit does not support setfpscap.", Duration = 3, Icon = "ban" })
end

-- ====================== CUSTOM CONFIG SYSTEM ======================
local HttpService = game:GetService("HttpService")
local ConfigFolder = "DYHUB_SZA"

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
    if success then warn("[DYHUB] Config saved!") else warn("[DYHUB] Save failed:", err) end
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

local SavedConfig = CustomConfig.new()
SavedConfig:AutoSave(15)

-- ====================== SERVICES ======================
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local Workspace          = game:GetService("Workspace")
local Lighting           = game:GetService("Lighting")
local UserInputService   = game:GetService("UserInputService")
local VirtualUser        = game:GetService("VirtualUser")

-- ====================== PLAYER ======================
local LocalPlayer  = Players.LocalPlayer
local Character    = LocalPlayer.Character
if not Character then Character = LocalPlayer.CharacterAdded:Wait() end

local Humanoid   = Character:WaitForChild("Humanoid")
local RootPart   = Character:WaitForChild("HumanoidRootPart")
local Terrain    = Workspace:FindFirstChildOfClass("Terrain")

local DefaultWalkSpeed  = Humanoid.WalkSpeed
local DefaultJumpPower  = Humanoid.JumpPower or 50
local DefaultJumpHeight = Humanoid.JumpHeight or 7.2

-- ====================== REMOTES ======================
local UpgradeRemotes       = ReplicatedStorage:WaitForChild("UpgradeRemotes")
local PurchaseHealthUpgrade = UpgradeRemotes:WaitForChild("PurchaseHealthUpgrade")
local PurchaseWeaponUpgrade = UpgradeRemotes:WaitForChild("PurchaseWeaponUpgrade")
local WaveRemotes          = ReplicatedStorage:WaitForChild("WaveRemotes")
local SkipVote             = WaveRemotes:WaitForChild("SkipVote")
local GearRemotes          = ReplicatedStorage:WaitForChild("GearRemotes")
local GearPurchase         = GearRemotes:WaitForChild("GearPurchase")

local ZombieDamageRemote = nil
local function EnsureZombieRemote()
    if ZombieDamageRemote then return true end
    pcall(function()
        local zr = ReplicatedStorage:WaitForChild("ZombieRemotes")
        ZombieDamageRemote = zr:WaitForChild("ZombieDamage", 5)
    end)
    return ZombieDamageRemote ~= nil
end
EnsureZombieRemote()

local function FireZombieDamage(zombieId, damage)
    if not EnsureZombieRemote() then return end
    local ok = pcall(function() ZombieDamageRemote:FireServer(zombieId, damage) end)
    if not ok then EnsureZombieRemote() end
end

-- ====================== CONFIG STATE ======================
local Config = {
    KillAuraEnabled      = SavedConfig:Get("KillAuraEnabled", false),
    KillAuraMode         = SavedConfig:Get("KillAuraMode", "V1"),
    KillAuraRange        = SavedConfig:Get("KillAuraRange", 5000),
    KillAuraDamage       = SavedConfig:Get("KillAuraDamage", 999999999),
    KillAuraV2Multiplier = SavedConfig:Get("KillAuraV2Multiplier", 1),
    AutoEquip            = SavedConfig:Get("AutoEquip", false),
    AutoBuyWeapon        = SavedConfig:Get("AutoBuyWeapon", false),
    AutoBuyHealth        = SavedConfig:Get("AutoBuyHealth", false),
    AutoBuyGear          = SavedConfig:Get("AutoBuyGear", false),
    AutoSkipWave         = SavedConfig:Get("AutoSkipWave", false),
    SelectedGear         = SavedConfig:Get("SelectedGear", "AutoTurret"),

    ZombieESP  = SavedConfig:Get("ZombieESP", false),
    PlayerESP  = SavedConfig:Get("PlayerESP", false),
    NoFog      = SavedConfig:Get("NoFog", false),
    FullBright = SavedConfig:Get("FullBright", false),

    SpeedHack      = SavedConfig:Get("SpeedHack", false),
    SpeedValue     = SavedConfig:Get("SpeedValue", 24),
    JumpHack       = SavedConfig:Get("JumpHack", false),
    JumpValue      = SavedConfig:Get("JumpValue", 100),
    TPSafeGround   = false,
    TPSafeSky      = false,
    TPSafeZoneV2   = false,
    Fly            = SavedConfig:Get("Fly", false),
    FlySpeed       = SavedConfig:Get("FlySpeed", 50),
    Noclip         = SavedConfig:Get("Noclip", false),

    AntiAFK     = SavedConfig:Get("AntiAFK", false),
    FPSUncap    = SavedConfig:Get("FPSUncap", false),
    FPSCap      = SavedConfig:Get("FPSCap", 60),
    FPSBooster  = SavedConfig:Get("FPSBooster", false),
}

-- ====================== WEAPON DATA ======================
local WeaponTier = {
    Pistol = 1, ShotGun = 2, Rifle = 3,
    Minigun = 4, Revolver = 5, DualPistols = 6,
    SMG = 7, CombatShotgun = 8, BurstRifle = 9,
    AK47 = 10, Sniper = 11, HeavyRifle = 12,
    Flamethrower = 13, MP5 = 14, USPS = 15,
    GoldenAK47 = 16, EmberSMG = 17, LavaRifle = 18,
    CoreBreaker = 19, LavaBow = 20, InfernoMinigun = 21,
    LavaGatling = 22, GumdropBlaster = 23, ArticStriker = 24,
    GalacticWeaver = 25, WorldEnder = 26, TommyGun = 27,
}

local WeaponDamage = {
    Pistol = 17, Revolver = 65, DualPistols = 35,
    USPS = 50, ShotGun = 40, SMG = 12,
    CombatShotgun = 55, MP5 = 20, Rifle = 60,
    BurstRifle = 160, AK47 = 90, Sniper = 500,
    TommyGun = 70, HeavyRifle = 155, Minigun = 13,
    Flamethrower = 104, GrenadeLauncher = 600, GumdropBlaster = 750,
    ArticStriker = 400, GoldenAK47 = 450, EmberSMG = 275,
    LavaRifle = 523, CoreBreaker = 629, LavaBow = 2160,
    InfernoMinigun = 364, LavaGatling = 880, GalacticWeaver = 800,
    WorldEnder = 1440, RPG = 1000, Plasma = 1500,
}

local GunConfig = nil
pcall(function()
    local data = ReplicatedStorage:WaitForChild("Data")
    GunConfig = require(data:WaitForChild("GunConfig"))
end)

local function GetToolDamage(tool)
    if not tool then return 10 end
    if GunConfig and GunConfig.Guns and GunConfig.Guns[tool.Name] then
        return GunConfig.Guns[tool.Name].Damage
    end
    local attr = tool:GetAttribute("Damage")
    if attr then return attr end
    local val = tool:FindFirstChild("Damage")
    if val and (val:IsA("NumberValue") or val:IsA("IntValue")) then return val.Value end
    return WeaponDamage[tool.Name] or 10
end

local BestWeapon = nil
local BestTier   = -1

local function ScanForBestWeapon(container)
    if not container then return end
    for _, item in ipairs(container:GetChildren()) do
        if item:IsA("Tool") and item:FindFirstChild("Handle") then
            local tier = WeaponTier[item.Name] or 0
            if tier > BestTier then BestTier = tier; BestWeapon = item end
        end
    end
end

local function TryAutoEquip()
    if not Config.AutoEquip then return end
    BestTier = -1; BestWeapon = nil
    ScanForBestWeapon(Character)
    ScanForBestWeapon(LocalPlayer:FindFirstChild("Backpack"))
    if BestWeapon and BestWeapon ~= Character:FindFirstChildOfClass("Tool") then
        pcall(function() Humanoid:EquipTool(BestWeapon) end)
    end
end

-- ====================== ZOMBIE DETECTION ======================
local function GetZombies()
    local results = {}
    local zc = _G.ZombieClient
    if zc and zc.Zombies then
        for id, data in pairs(zc.Zombies) do
            if data and not data.IsDying then
                local pos = data.CurrentPosition or data.TargetPosition
                if pos then table.insert(results, { id = id, pos = pos, data = data }) end
            end
        end
        if #results > 0 then return results end
    end
    local folder = Workspace:FindFirstChild("Zombies_Local")
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") and child.PrimaryPart then
                local id = tonumber(child.Name:match("%d+$")) or child:GetAttribute("ZombieId")
                if id then table.insert(results, { id = id, pos = child.PrimaryPart.Position, model = child }) end
            end
        end
        if #results > 0 then return results end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.PrimaryPart then
            local nameLow = obj.Name:lower()
            if nameLow:find("zombie") then
                local id = tonumber(obj.Name:match("%d+$")) or obj:GetAttribute("ZombieId") or obj:GetAttribute("Id")
                if id then
                    local duplicate = false
                    for _, r in ipairs(results) do if r.id == id then duplicate = true; break end end
                    if not duplicate then table.insert(results, { id = id, pos = obj.PrimaryPart.Position, model = obj }) end
                end
            end
        end
    end
    return results
end

-- ====================== KILL AURA ======================
local KillCooldowns  = {}
local KILL_COOLDOWN  = 0.15
local KillAuraV2Active = false

task.spawn(function()
    while true do
        task.wait(30)
        local now = os.clock()
        for id, t in pairs(KillCooldowns) do
            if now - t > 10 then KillCooldowns[id] = nil end
        end
    end
end)

local function KillAuraV1()
    if not Config.KillAuraEnabled or Config.KillAuraMode ~= "V1" then return end
    if not EnsureZombieRemote() then return end
    if not RootPart or not RootPart.Parent then
        Character = LocalPlayer.Character
        if Character then
            RootPart  = Character:FindFirstChild("HumanoidRootPart")
            Humanoid  = Character:FindFirstChild("Humanoid")
        end
        if not RootPart then return end
    end
    local myPos = RootPart.Position
    local now   = os.clock()
    for _, zombie in ipairs(GetZombies()) do
        if typeof(zombie.pos) == "Vector3" then
            if (zombie.pos - myPos).Magnitude <= Config.KillAuraRange then
                local id = zombie.id
                if not KillCooldowns[id] or now - KillCooldowns[id] >= KILL_COOLDOWN then
                    KillCooldowns[id] = now
                    FireZombieDamage(id, Config.KillAuraDamage)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if Config.KillAuraEnabled and Config.KillAuraMode == "V2" then
            if not KillAuraV2Active then
                Config.AutoEquip = true; TryAutoEquip(); KillAuraV2Active = true
            end
            if not EnsureZombieRemote() then continue end
            if not Character or not Character.Parent or not Humanoid or not RootPart or not RootPart.Parent then
                Character = LocalPlayer.Character
                if Character then
                    Humanoid  = Character:FindFirstChild("Humanoid")
                    RootPart  = Character:FindFirstChild("HumanoidRootPart")
                end
            else
                local tool   = Character:FindFirstChildOfClass("Tool")
                local damage = math.floor(GetToolDamage(tool) * Config.KillAuraV2Multiplier)
                local now    = os.clock()
                for _, zombie in ipairs(GetZombies()) do
                    if typeof(zombie.pos) == "Vector3" then
                        local id = zombie.id
                        if not KillCooldowns[id] or now - KillCooldowns[id] >= KILL_COOLDOWN then
                            KillCooldowns[id] = now
                            FireZombieDamage(id, damage)
                        end
                    end
                end
            end
        else
            if KillAuraV2Active then KillAuraV2Active = false end
        end
    end
end)

-- ====================== AUTO BUY ======================
local AutoBuyTimers   = { Weapon = 0, Health = 0, Gear = 0 }
local AutoBuyNotified = { Weapon = false, Health = false, Gear = false }

local function Notify(title, desc, t)
    WindUI:Notify({ Title = title, Content = desc, Duration = t or 2, Icon = "bell" })
end

local function AutoBuyTick()
    local now = os.clock()
    if Config.AutoBuyWeapon and now - AutoBuyTimers.Weapon > 0.5 then
        AutoBuyTimers.Weapon = now
        pcall(function() PurchaseWeaponUpgrade:FireServer() end)
        if not AutoBuyNotified.Weapon then
            AutoBuyNotified.Weapon = true
            Notify("Auto Buy", "Weapon Upgrade is active", 2)
        end
    end
    if not Config.AutoBuyWeapon then AutoBuyNotified.Weapon = false end

    if Config.AutoBuyHealth and now - AutoBuyTimers.Health > 0.5 then
        AutoBuyTimers.Health = now
        pcall(function() PurchaseHealthUpgrade:FireServer() end)
        if not AutoBuyNotified.Health then
            AutoBuyNotified.Health = true
            Notify("Auto Buy", "Health Upgrade is active", 2)
        end
    end
    if not Config.AutoBuyHealth then AutoBuyNotified.Health = false end

    if Config.AutoBuyGear and now - AutoBuyTimers.Gear > 0.3 then
        AutoBuyTimers.Gear = now
        pcall(function() GearPurchase:FireServer(Config.SelectedGear) end)
        if not AutoBuyNotified.Gear then
            AutoBuyNotified.Gear = true
            Notify("Auto Buy", Config.SelectedGear .. " is active", 2)
        end
    end
    if not Config.AutoBuyGear then AutoBuyNotified.Gear = false end
end

-- ====================== MOVEMENT ======================
local SafeGroundCFrame  = nil
local SafeZoneV2CFrame  = nil
local SkyOrigPos        = nil
local SkyPlatform       = nil

local function UpdateSpeed()
    if not Humanoid then return end
    if Config.SpeedHack then
        Humanoid.WalkSpeed = Config.SpeedValue
    else
        if Humanoid.WalkSpeed ~= DefaultWalkSpeed then Humanoid.WalkSpeed = DefaultWalkSpeed end
    end
    if Config.JumpHack then
        if Humanoid.UseJumpPower then Humanoid.JumpPower = Config.JumpValue
        else Humanoid.JumpHeight = Config.JumpValue / 7 end
    else
        if Humanoid.UseJumpPower then
            if Humanoid.JumpPower ~= DefaultJumpPower then Humanoid.JumpPower = DefaultJumpPower end
        else
            if Humanoid.JumpHeight ~= DefaultJumpHeight then Humanoid.JumpHeight = DefaultJumpHeight end
        end
    end
end

local SafeGroundPos = Vector3.new(22.22, 4, -167.02)
local function UpdateTPSafeGround()
    if not RootPart then return end
    if Config.TPSafeGround then
        if not SafeGroundCFrame then
            SafeGroundCFrame = RootPart.CFrame
            RootPart.CFrame  = CFrame.new(SafeGroundPos)
        end
    else
        if SafeGroundCFrame then
            RootPart.CFrame = SafeGroundCFrame; SafeGroundCFrame = nil
        end
    end
end

local SafeZoneV2Pos = Vector3.new(-340.99, 458.54, -321.69)
local function UpdateTPSafeZoneV2()
    if not RootPart then return end
    if Config.TPSafeZoneV2 then
        if not SafeZoneV2CFrame then
            SafeZoneV2CFrame = RootPart.CFrame
            RootPart.CFrame  = CFrame.new(SafeZoneV2Pos)
        end
    else
        if SafeZoneV2CFrame then
            RootPart.CFrame = SafeZoneV2CFrame; SafeZoneV2CFrame = nil
        end
    end
end

local function UpdateTPSafeSky()
    if not RootPart then return end
    if Config.TPSafeSky then
        if not SkyOrigPos then
            SkyOrigPos   = RootPart.Position
            local skyY   = SkyOrigPos.Y + 40
            if not SkyPlatform then
                SkyPlatform             = Instance.new("Part")
                SkyPlatform.Name        = "SkyPlatform"
                SkyPlatform.Size        = Vector3.new(50, 2, 50)
                SkyPlatform.Anchored    = true
                SkyPlatform.Transparency = 1
                SkyPlatform.CanCollide  = true
                SkyPlatform.Position    = Vector3.new(SkyOrigPos.X, skyY - SkyPlatform.Size.Y / 2, SkyOrigPos.Z)
                SkyPlatform.Parent      = Workspace
            end
            RootPart.CFrame = CFrame.new(SkyOrigPos.X, skyY + (Humanoid.HipHeight or RootPart.Size.Y / 2), SkyOrigPos.Z)
        end
        if SkyPlatform then
            SkyPlatform.Position = Vector3.new(RootPart.Position.X, SkyPlatform.Position.Y, RootPart.Position.Z)
        end
    else
        if SkyOrigPos then RootPart.CFrame = CFrame.new(SkyOrigPos); SkyOrigPos = nil end
        if SkyPlatform then SkyPlatform:Destroy(); SkyPlatform = nil end
    end
end

local function UpdateNoclip()
    if not Character or not Config.Noclip then return end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

-- ====================== FLY ======================
local BodyGyro       = nil
local BodyVelocity   = nil
local MobileFlyGui   = nil
local MobileInput    = { up = false, down = false }

local function CreateMobileFlyButtons()
    if MobileFlyGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "MobileFlyButtons"; gui.IgnoreGuiInset = true
    gui.DisplayOrder = 10; gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local btnUp = Instance.new("TextButton")
    btnUp.Size = UDim2.new(0, 80, 0, 80)
    btnUp.Position = UDim2.new(1, -90, 0.5, -90)
    btnUp.Text = "⬆ Fly Up"
    btnUp.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    btnUp.TextColor3 = Color3.new(1,1,1)
    btnUp.BorderSizePixel = 0; btnUp.Parent = gui
    local btnDown = Instance.new("TextButton")
    btnDown.Size = UDim2.new(0, 80, 0, 80)
    btnDown.Position = UDim2.new(1, -90, 0.5, 10)
    btnDown.Text = "⬇ Fly Down"
    btnDown.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    btnDown.TextColor3 = Color3.new(1,1,1)
    btnDown.BorderSizePixel = 0; btnDown.Parent = gui
    btnUp.MouseButton1Down:Connect(function() MobileInput.up = true end)
    btnUp.MouseButton1Up:Connect(function() MobileInput.up = false end)
    btnDown.MouseButton1Down:Connect(function() MobileInput.down = true end)
    btnDown.MouseButton1Up:Connect(function() MobileInput.down = false end)
    MobileFlyGui = { gui = gui, input = MobileInput }
end

local function DestroyMobileFlyButtons()
    if MobileFlyGui then pcall(function() MobileFlyGui.gui:Destroy() end); MobileFlyGui = nil end
end

local function EnableFly()
    if not RootPart then return end
    Humanoid.PlatformStand = true
    if not BodyGyro then
        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(400000,400000,400000)
        BodyGyro.P = 30000; BodyGyro.Parent = RootPart
    end
    if not BodyVelocity then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(400000,400000,400000)
        BodyVelocity.Velocity = Vector3.zero
        BodyVelocity.Parent = RootPart
    end
    if UserInputService.TouchEnabled then CreateMobileFlyButtons() end
end

local function DisableFly()
    if Humanoid then Humanoid.PlatformStand = false end
    if BodyGyro then BodyGyro:Destroy(); BodyGyro = nil end
    if BodyVelocity then BodyVelocity:Destroy(); BodyVelocity = nil end
    DestroyMobileFlyButtons()
end

local function UpdateFlyVelocity()
    if not BodyVelocity or not BodyGyro then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local dir = Vector3.zero
    if not UserInputService.TouchEnabled then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
    else
        if Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
            local md = Humanoid.MoveDirection
            dir = cam.CFrame.LookVector * md.Z + cam.CFrame.RightVector * md.X
        end
        if MobileFlyGui and MobileFlyGui.input.up   then dir = dir + Vector3.yAxis end
        if MobileFlyGui and MobileFlyGui.input.down then dir = dir - Vector3.yAxis end
    end
    if dir.Magnitude > 0 then BodyVelocity.Velocity = dir.Unit * Config.FlySpeed
    else BodyVelocity.Velocity = Vector3.zero end
    BodyGyro.CFrame = cam.CFrame
end

-- ====================== ESP ======================
local ESPObjects = {}

local function ClearESP()
    for _, gui in ipairs(ESPObjects) do pcall(function() gui:Destroy() end) end
    ESPObjects = {}
end

local function RefreshESP()
    ClearESP()
    if Config.ZombieESP then
        for _, zombie in ipairs(GetZombies()) do
            if zombie.model and zombie.model.PrimaryPart then
                local bb = Instance.new("BillboardGui")
                bb.AlwaysOnTop = true; bb.Size = UDim2.new(0,80,0,30)
                bb.StudsOffset = Vector3.new(0,2.5,0)
                bb.Parent = zombie.model.PrimaryPart
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,0,1,0)
                lbl.TextColor3 = Color3.fromRGB(255,60,60)
                lbl.TextStrokeTransparency = 0.5; lbl.Text = "Zombie"; lbl.Parent = bb
                table.insert(ESPObjects, bb)
            end
        end
    end
    if Config.PlayerESP then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bb = Instance.new("BillboardGui")
                    bb.AlwaysOnTop = true; bb.Size = UDim2.new(0,100,0,25)
                    bb.StudsOffset = Vector3.new(0,3,0); bb.Parent = hrp
                    local lbl = Instance.new("TextLabel")
                    lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,0,1,0)
                    lbl.TextColor3 = Color3.fromRGB(0,255,100)
                    lbl.TextStrokeTransparency = 0.5; lbl.Text = plr.Name; lbl.Parent = bb
                    table.insert(ESPObjects, bb)
                end
            end
        end
    end
end

-- ====================== LIGHTING ======================
local SavedLighting = {}

local function SetFullBright(enabled)
    if enabled then
        if not SavedLighting.saved then
            SavedLighting = {
                Ambient = Lighting.Ambient, Brightness = Lighting.Brightness,
                OutdoorAmbient = Lighting.OutdoorAmbient, ClockTime = Lighting.ClockTime,
                GlobalShadows = Lighting.GlobalShadows, saved = true,
            }
        end
        Lighting.Ambient = Color3.fromRGB(255,255,255); Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.ClockTime = 14; Lighting.GlobalShadows = false
        if not Config.NoFog then Lighting.FogEnd = 999999; Lighting.FogStart = 99999 end
    else
        if SavedLighting.saved then
            Lighting.Ambient = SavedLighting.Ambient; Lighting.Brightness = SavedLighting.Brightness
            Lighting.OutdoorAmbient = SavedLighting.OutdoorAmbient
            Lighting.ClockTime = SavedLighting.ClockTime; Lighting.GlobalShadows = SavedLighting.GlobalShadows
            SavedLighting.saved = false
        end
        if not Config.NoFog then Lighting.FogEnd = 5000; Lighting.FogStart = 1000 end
    end
end

local function SetNoFog(enabled)
    if enabled then Lighting.FogEnd = 999999; Lighting.FogStart = 99999
    else if not Config.FullBright then Lighting.FogEnd = 5000; Lighting.FogStart = 1000 end end
end

-- ====================== FPS ======================
local function ApplyFPSSettings()
    if Config.FPSUncap then pcall(function() setfpscap(Config.FPSCap) end)
    else pcall(function() setfpscap(0) end) end
end

local FPSBoostActive  = false
local FPSBoostSaved   = {}
local FPSBoostConn    = nil

local function EnableFPSBooster()
    if FPSBoostActive then return end
    FPSBoostActive = true
    FPSBoostSaved.GlobalShadows = Lighting.GlobalShadows
    FPSBoostSaved.Brightness    = Lighting.Brightness
    FPSBoostSaved.FogEnd        = Lighting.FogEnd
    pcall(function() FPSBoostSaved.TerrainDeco    = Terrain.Decoration end)
    pcall(function() FPSBoostSaved.WaterWaveSize  = Terrain.WaterWaveSize end)
    pcall(function() FPSBoostSaved.WaterWaveSpeed = Terrain.WaterWaveSpeed end)
    pcall(function() FPSBoostSaved.WaterReflect   = Terrain.WaterReflectance end)
    pcall(function() FPSBoostSaved.WaterTransp    = Terrain.WaterTransparency end)
    pcall(function() FPSBoostSaved.QualityLevel   = settings().rendering.QualityLevel end)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            pcall(function() obj.Material = Enum.Material.SmoothPlastic; obj.Reflectance = 0; obj.CastShadow = false end)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            pcall(function() obj:Destroy() end)
        end
    end
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostProcessEffect") then pcall(function() child.Enabled = false end) end
    end
    if Terrain then
        pcall(function() Terrain.Decoration = false end)
        pcall(function() Terrain.WaterWaveSize = 0 end)
        pcall(function() Terrain.WaterWaveSpeed = 0 end)
        pcall(function() Terrain.WaterReflectance = 0 end)
        pcall(function() Terrain.WaterTransparency = 0 end)
    end
    local clouds = Workspace:FindFirstChild("Clouds")
    if clouds then pcall(function() clouds:Destroy() end) end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then pcall(function() obj:Destroy() end) end
    end
    pcall(function() settings().physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Always end)
    pcall(function() settings().rendering.QualityLevel = Enum.QualityLevel.Level1 end)
    Lighting.GlobalShadows = false; Lighting.Brightness = 3; Lighting.FogEnd = 9000000000
    pcall(function() if sethiddenproperty then sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility) end end)
    FPSBoostConn = game.DescendantAdded:Connect(function(obj)
        if not Config.FPSBooster then return end
        if obj:IsA("BasePart") then
            pcall(function() obj.Material = Enum.Material.SmoothPlastic; obj.Reflectance = 0; obj.CastShadow = false end)
        elseif obj:IsA("Decal") then
            pcall(function() obj:Destroy() end)
        end
    end)
    Notify("FPS Booster", "Ultra FPS Boost enabled!", 2)
end

local function DisableFPSBooster()
    if not FPSBoostActive then return end
    FPSBoostActive = false
    if FPSBoostConn then FPSBoostConn:Disconnect(); FPSBoostConn = nil end
    pcall(function() Lighting.GlobalShadows = FPSBoostSaved.GlobalShadows end)
    pcall(function() Lighting.Brightness    = FPSBoostSaved.Brightness end)
    pcall(function() Lighting.FogEnd        = FPSBoostSaved.FogEnd end)
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostProcessEffect") then pcall(function() child.Enabled = true end) end
    end
    if Terrain then
        pcall(function() Terrain.Decoration        = FPSBoostSaved.TerrainDeco end)
        pcall(function() Terrain.WaterWaveSize      = FPSBoostSaved.WaterWaveSize end)
        pcall(function() Terrain.WaterWaveSpeed     = FPSBoostSaved.WaterWaveSpeed end)
        pcall(function() Terrain.WaterReflectance   = FPSBoostSaved.WaterReflect end)
        pcall(function() Terrain.WaterTransparency  = FPSBoostSaved.WaterTransp end)
    end
    pcall(function() settings().rendering.QualityLevel = FPSBoostSaved.QualityLevel end)
    Notify("FPS Booster", "Disabled - Settings restored", 2)
end

-- ====================== ANTI-AFK ======================
local AntiAFKIdledConn = nil
local AntiAFKJumpTimer = 0
local AntiAFKMoveTimer = 0
local AntiAFKMoveDir   = false

local function SetupAntiAFK()
    if AntiAFKIdledConn then AntiAFKIdledConn:Disconnect() end
    AntiAFKIdledConn = LocalPlayer.Idled:Connect(function()
        if Config.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end
SetupAntiAFK()

local function AntiAFKTick()
    if not Config.AntiAFK or Config.Fly then return end
    if not Humanoid or Humanoid.Health <= 0 or not RootPart then return end
    local now = os.clock()
    if now - AntiAFKJumpTimer > 7 then
        AntiAFKJumpTimer = now
        pcall(function() Humanoid.Jump = true end)
    end
    if now - AntiAFKMoveTimer > 30 then
        AntiAFKMoveTimer = now
        AntiAFKMoveDir   = not AntiAFKMoveDir
        local dir = AntiAFKMoveDir and 1 or -1
        pcall(function()
            Humanoid:Move(Vector3.new(dir,0,0), true)
            task.wait(0.1)
            Humanoid:Move(Vector3.new(0,0,0), true)
        end)
    end
end

-- ====================== CHARACTER RESPAWN ======================
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid  = char:WaitForChild("Humanoid")
    RootPart  = char:WaitForChild("HumanoidRootPart")
    DefaultWalkSpeed  = Humanoid.WalkSpeed
    DefaultJumpPower  = Humanoid.JumpPower or 50
    DefaultJumpHeight = Humanoid.JumpHeight or 7.2
    Config.TPSafeGround = false; SafeGroundCFrame = nil
    Config.TPSafeSky    = false; SkyOrigPos = nil
    Config.TPSafeZoneV2 = false; SafeZoneV2CFrame = nil
    if SkyPlatform then SkyPlatform:Destroy(); SkyPlatform = nil end
    AutoBuyNotified.Weapon = false
    AutoBuyNotified.Health = false
    AutoBuyNotified.Gear   = false
    DisableFly()
    SetupAntiAFK()
    if Config.FPSBooster then task.wait(0.5); EnableFPSBooster() end
end)

-- ====================== HEARTBEAT ======================
local ESPTimer    = 0
local HeartbeatConn = RunService.Heartbeat:Connect(function()
    KillAuraV1()
    AutoBuyTick()
    TryAutoEquip()
    UpdateSpeed()
    UpdateTPSafeGround()
    UpdateTPSafeZoneV2()
    UpdateTPSafeSky()
    UpdateNoclip()
    AntiAFKTick()
    if Config.Fly then EnableFly(); UpdateFlyVelocity() else DisableFly() end
    local now = os.clock()
    if now - ESPTimer > 1 then
        ESPTimer = now
        if Config.ZombieESP or Config.PlayerESP then RefreshESP() else ClearESP() end
    end
end)

-- ========================================================
-- ====================== WINDOW ==========================
-- ========================================================
local Players = game:GetService("Players")

local FreeVersion    = "Free Version"
local PremiumVersion = "Premium Version"
local ExtraVersion   = "Free Version"

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

local player    = Players.LocalPlayer
local userversion = checkVersion(player.Name)

-- ====================== WINDOW ======================
local Window = WindUI:CreateWindow({
    Title = "DYHUB",
    IconThemed = true,
    Icon = "rbxassetid://104487529937663",
    Author = "Survive Zombie Arena | " .. userversion,
    Folder = "DYHUB_SZA",
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
local Info     = Window:Tab({ Title = "Information", Icon = "info" })
local _D1         = Window:Divider()
local TabMain     = Window:Tab({ Title = "Main",     Icon = "rocket" })
local TabMovement = Window:Tab({ Title = "Movement", Icon = "footprints" })
local TabVisual   = Window:Tab({ Title = "Visual",   Icon = "eye" })
local TabConfig   = Window:Tab({ Title = "Setting",   Icon = "settings" })

Window:SelectTab(1)

-- ====================== INFORMATION TAB ======================

if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end
Info:Section({ Title = "Latest Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({
    Title = "Update: 05/24/2026 | CL: " .. ver,
    Desc  = "• [ New ] Custom Config System\n• [ New ] Auto Save Config\n• [ New ] Kill Aura V1 & V2\n• [ New ] FPS Booster\n• [ New ] Fly System\n• [ New ] Noclip\n• [ New ] Zombie & Player ESP\n• [ New ] TP Safe Ground / Sky / Zone V2\n• [ New ] Auto Buy Weapon / Health / Gear\n• [ New ] Full Bright & No Fog\n• [ New ] Anti AFK\n• [ Added ] Gear Type Selection\n• [ Fixed ] Anti AFK state on load\n• [ Improved ] Settings restored on rejoin",
})
Info:Divider()

ui.Creator.Request = function(requestData)
    local success, result = pcall(function()
        if HttpService.RequestAsync then
            local response = HttpService:RequestAsync({
                Url = requestData.Url, Method = requestData.Method or "GET", Headers = requestData.Headers or {}
            })
            return { Body = response.Body, StatusCode = response.StatusCode, Success = response.Success }
        else
            local body = HttpService:GetAsync(requestData.Url)
            return { Body = body, StatusCode = 200, Success = true }
        end
    end)
    if success then return result else error("HTTP Request failed: "..tostring(result)) end
end

local InviteCode = "jWNDPNMmyB"
local DiscordAPI = "https://discord.com/api/v10/invites/"..InviteCode.."?with_counts=true&with_expiration=true"

local function LoadDiscordInfo()
    local success, result = pcall(function()
        return HttpService:JSONDecode(ui.Creator.Request({
            Url = DiscordAPI, Method = "GET",
            Headers = { ["User-Agent"] = "RobloxBot/1.0", ["Accept"] = "application/json" }
        }).Body)
    end)
    if success and result and result.guild then
        local DiscordInfo = Info:Paragraph({
            Title = result.guild.name,
            Desc  = ' <font color="#52525b">●</font> Member Count : '..tostring(result.approximate_member_count)..
                    '\n <font color="#16a34a">●</font> Online Count : '..tostring(result.approximate_presence_count),
            Image = "https://cdn.discordapp.com/icons/"..result.guild.id.."/"..result.guild.icon..".png?size=1024",
            ImageSize = 42,
        })
        Info:Button({
            Title = "Update Info",
            Callback = function()
                local ok, r = pcall(function()
                    return HttpService:JSONDecode(ui.Creator.Request({ Url = DiscordAPI, Method = "GET" }).Body)
                end)
                if ok and r and r.guild then
                    DiscordInfo:SetDesc(
                        ' <font color="#52525b">●</font> Member Count : '..tostring(r.approximate_member_count)..
                        '\n <font color="#16a34a">●</font> Online Count : '..tostring(r.approximate_presence_count)
                    )
                    WindUI:Notify({ Title = "Discord Info Updated", Content = "Refreshed!", Duration = 2, Icon = "refresh-cw" })
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
        Info:Paragraph({
            Title = "Error fetching Discord Info", Desc = "Unable to load Discord information.",
            Image = "triangle-alert", ImageSize = 26, Color = "Red",
        })
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
    Buttons = {{ Icon="copy", Title="Copy Link", Callback=function() setclipboard("https://guns.lol/DYHUB") end }}
})
Info:Paragraph({
    Title = "Discord", Desc = "Join our discord for more scripts!",
    Image = "rbxassetid://104487529937663", ImageSize = 30,
    Buttons = {{ Icon="copy", Title="Copy Link", Callback=function() setclipboard("https://discord.gg/jWNDPNMmyB") end }}
})

-- ====================== MAIN TAB ======================
TabMain:Section({ Title = "Kill Aura", Icon = "crosshair" })

TabMain:Toggle({
    Title = "Kill Aura",
    Desc  = "Fire ZombieDamage remote on all zombies in range",
    Value = Config.KillAuraEnabled,
    Callback = function(v)
        Config.KillAuraEnabled = v
        SavedConfig:Set("KillAuraEnabled", v); SavedConfig:Save()
    end,
})

TabMain:Dropdown({
    Title  = "Mode",
    Values = { "V1", "V2" },
    Multi  = false,
    Value  = Config.KillAuraMode,
    Callback = function(v)
        Config.KillAuraMode = v
        SavedConfig:Set("KillAuraMode", v); SavedConfig:Save()
    end,
})

TabMain:Slider({
    Title = "Range",
    Value = { Min = 100, Max = 5000, Default = Config.KillAuraRange },
    Step  = 100,
    Callback = function(v)
        Config.KillAuraRange = v
        SavedConfig:Set("KillAuraRange", v); SavedConfig:Save()
    end,
})

TabMain:Slider({
    Title = "Damage (V1)",
    Value = { Min = 1000, Max = 999999999, Default = Config.KillAuraDamage },
    Step  = 1000,
    Callback = function(v)
        Config.KillAuraDamage = v
        SavedConfig:Set("KillAuraDamage", v); SavedConfig:Save()
    end,
})

TabMain:Slider({
    Title = "Multiplier (V2)",
    Value = { Min = 1, Max = 100, Default = Config.KillAuraV2Multiplier },
    Step  = 1,
    Callback = function(v)
        Config.KillAuraV2Multiplier = v
        SavedConfig:Set("KillAuraV2Multiplier", v); SavedConfig:Save()
    end,
})

TabMain:Section({ Title = "Automation", Icon = "zap" })

TabMain:Toggle({
    Title = "Auto Equip",
    Value = Config.AutoEquip,
    Callback = function(v)
        Config.AutoEquip = v
        SavedConfig:Set("AutoEquip", v); SavedConfig:Save()
    end,
})

TabMain:Toggle({
    Title = "Auto Buy Weapon",
    Value = Config.AutoBuyWeapon,
    Callback = function(v)
        Config.AutoBuyWeapon = v
        SavedConfig:Set("AutoBuyWeapon", v); SavedConfig:Save()
        if v then Notify("Auto Buy", "Weapon Upgrade enabled", 2) end
    end,
})

TabMain:Toggle({
    Title = "Auto Buy Health",
    Value = Config.AutoBuyHealth,
    Callback = function(v)
        Config.AutoBuyHealth = v
        SavedConfig:Set("AutoBuyHealth", v); SavedConfig:Save()
        if v then Notify("Auto Buy", "Health Upgrade enabled", 2) end
    end,
})

TabMain:Toggle({
    Title = "Auto Buy Gear",
    Value = Config.AutoBuyGear,
    Callback = function(v)
        Config.AutoBuyGear = v
        SavedConfig:Set("AutoBuyGear", v); SavedConfig:Save()
        if v then Notify("Auto Buy", Config.SelectedGear .. " Gear enabled", 2) end
    end,
})

TabMain:Dropdown({
    Title  = "Gear Type",
    Multi  = false,
    Value  = Config.SelectedGear,
    Values = {
        "Landmine","LaserTurret","AutoTurret","Barricade","SteelBarricade",
        "FlamethrowerTurret","ShockwaveMine","HealingStation","MendingTower",
        "StimShot","Molotov","VanguardTurret","Cloak","Shuriken","BladeFury",
        "SoulHarvester","RaiseUndead","DeathNova","FragGrenade","Deadeye",
        "TargetMark","Drone","Spikes","Bunker",
    },
    Callback = function(v)
        Config.SelectedGear = v
        SavedConfig:Set("SelectedGear", v); SavedConfig:Save()
    end,
})

TabMain:Section({ Title = "Misc", Icon = "settings" })

TabMain:Toggle({
    Title = "Auto Skip Wave",
    Value = Config.AutoSkipWave,
    Callback = function(v)
        Config.AutoSkipWave = v
        SavedConfig:Set("AutoSkipWave", v); SavedConfig:Save()
    end,
})

-- ====================== MOVEMENT TAB ======================
TabMovement:Section({ Title = "Speed & Jump", Icon = "footprints" })

TabMovement:Toggle({
    Title = "Speed Hack",
    Value = Config.SpeedHack,
    Callback = function(v)
        Config.SpeedHack = v
        SavedConfig:Set("SpeedHack", v); SavedConfig:Save()
    end,
})

TabMovement:Slider({
    Title = "Walk Speed",
    Value = { Min = 16, Max = 200, Default = Config.SpeedValue },
    Step  = 1,
    Callback = function(v)
        Config.SpeedValue = v
        SavedConfig:Set("SpeedValue", v); SavedConfig:Save()
    end,
})

TabMovement:Toggle({
    Title = "Jump Hack",
    Value = Config.JumpHack,
    Callback = function(v)
        Config.JumpHack = v
        SavedConfig:Set("JumpHack", v); SavedConfig:Save()
    end,
})

TabMovement:Slider({
    Title = "Jump Power",
    Value = { Min = 50, Max = 500, Default = Config.JumpValue },
    Step  = 1,
    Callback = function(v)
        Config.JumpValue = v
        SavedConfig:Set("JumpValue", v); SavedConfig:Save()
    end,
})

TabMovement:Section({ Title = "Fly & Noclip", Icon = "wind" })

TabMovement:Toggle({
    Title = "Fly",
    Value = Config.Fly,
    Callback = function(v)
        Config.Fly = v
        SavedConfig:Set("Fly", v); SavedConfig:Save()
        if not v then DisableFly() end
    end,
})

TabMovement:Slider({
    Title = "Fly Speed",
    Value = { Min = 10, Max = 200, Default = Config.FlySpeed },
    Step  = 1,
    Callback = function(v)
        Config.FlySpeed = v
        SavedConfig:Set("FlySpeed", v); SavedConfig:Save()
    end,
})

TabMovement:Toggle({
    Title = "Noclip",
    Value = Config.Noclip,
    Callback = function(v)
        Config.Noclip = v
        SavedConfig:Set("Noclip", v); SavedConfig:Save()
    end,
})

TabMovement:Section({ Title = "Teleports", Icon = "map-pin" })

TabMovement:Toggle({
    Title = "TP Safe Ground",
    Value = false,
    Callback = function(v) Config.TPSafeGround = v end,
})

TabMovement:Toggle({
    Title = "TP Safe Sky",
    Value = false,
    Callback = function(v)
        Config.TPSafeSky = v
        if not v then
            if SkyOrigPos and RootPart then RootPart.CFrame = CFrame.new(SkyOrigPos) end
            SkyOrigPos = nil
            if SkyPlatform then SkyPlatform:Destroy(); SkyPlatform = nil end
        end
    end,
})

TabMovement:Toggle({
    Title = "TP Safe Zone V2",
    Value = false,
    Callback = function(v) Config.TPSafeZoneV2 = v end,
})

-- ====================== VISUAL TAB ======================
TabVisual:Section({ Title = "ESP", Icon = "eye" })

TabVisual:Toggle({
    Title = "Zombie ESP",
    Value = Config.ZombieESP,
    Callback = function(v)
        Config.ZombieESP = v
        SavedConfig:Set("ZombieESP", v); SavedConfig:Save()
        RefreshESP()
    end,
})

TabVisual:Toggle({
    Title = "Player ESP",
    Value = Config.PlayerESP,
    Callback = function(v)
        Config.PlayerESP = v
        SavedConfig:Set("PlayerESP", v); SavedConfig:Save()
        RefreshESP()
    end,
})

TabVisual:Section({ Title = "World & Lighting", Icon = "sun" })

TabVisual:Toggle({
    Title = "No Fog",
    Value = Config.NoFog,
    Callback = function(v)
        Config.NoFog = v
        SavedConfig:Set("NoFog", v); SavedConfig:Save()
        SetNoFog(v)
    end,
})

TabVisual:Toggle({
    Title = "Full Bright",
    Value = Config.FullBright,
    Callback = function(v)
        Config.FullBright = v
        SavedConfig:Set("FullBright", v); SavedConfig:Save()
        SetFullBright(v)
    end,
})

TabVisual:Toggle({
    Title = "FPS Booster",
    Value = Config.FPSBooster,
    Callback = function(v)
        Config.FPSBooster = v
        SavedConfig:Set("FPSBooster", v); SavedConfig:Save()
        if v then EnableFPSBooster() else DisableFPSBooster() end
    end,
})

TabVisual:Section({ Title = "FPS Settings", Icon = "cpu" })

TabVisual:Toggle({
    Title = "FPS Uncap",
    Value = Config.FPSUncap,
    Callback = function(v)
        Config.FPSUncap = v
        SavedConfig:Set("FPSUncap", v); SavedConfig:Save()
        ApplyFPSSettings()
    end,
})

TabVisual:Slider({
    Title = "FPS Cap",
    Value = { Min = 10, Max = 600, Default = Config.FPSCap },
    Step  = 1,
    Callback = function(v)
        Config.FPSCap = v
        SavedConfig:Set("FPSCap", v); SavedConfig:Save()
        if Config.FPSUncap then ApplyFPSSettings() end
    end,
})

TabVisual:Section({ Title = "Misc", Icon = "settings" })

TabVisual:Toggle({
    Title = "Anti AFK",
    Value = Config.AntiAFK,
    Callback = function(v)
        Config.AntiAFK = v
        SavedConfig:Set("AntiAFK", v); SavedConfig:Save()
        if v then SetupAntiAFK()
        else if AntiAFKIdledConn then AntiAFKIdledConn:Disconnect() end end
    end,
})

-- ====================== CONFIG TAB ======================
TabConfig:Section({ Title = "Save Config", Icon = "save" })

TabConfig:Button({
    Title = "Save Config (NOW)",
    Desc  = "Saves all current settings immediately.",
    Callback = function()
        SavedConfig:Save()
        WindUI:Notify({ Title = "Config Saved", Content = "Config saved successfully!", Duration = 2, Icon = "save" })
    end,
})

local AutoSaveEnabled = SavedConfig:Get("AutoSaveEnabled", true)
local AutoSaveDelay   = SavedConfig:Get("AutoSaveDelay", 15)
local AutoSaveThread  = nil

local function RestartAutoSave()
    if AutoSaveThread then task.cancel(AutoSaveThread); AutoSaveThread = nil end
    if AutoSaveEnabled then
        AutoSaveThread = task.spawn(function()
            while AutoSaveEnabled do
                task.wait(AutoSaveDelay)
                SavedConfig:Save()
            end
        end)
    end
end

TabConfig:Toggle({
    Title = "Auto Save Config",
    Desc  = "Automatically saves your config at the set interval.",
    Value = AutoSaveEnabled,
    Callback = function(state)
        AutoSaveEnabled = state
        SavedConfig:Set("AutoSaveEnabled", state); SavedConfig:Save()
        RestartAutoSave()
    end,
})

TabConfig:Input({
    Title       = "Delay Save Config",
    Default     = tostring(AutoSaveDelay),
    Placeholder = "Default: 15",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 then
            AutoSaveDelay = num
            SavedConfig:Set("AutoSaveDelay", num); SavedConfig:Save()
            RestartAutoSave()
        else
            warn("[DYHUB] Invalid delay value!")
        end
    end,
})

TabConfig:Section({ Title = "Server", Icon = "server" })

TabConfig:Button({
    Title = "Serverhop",
    Desc  = "Teleports you to a different random server.",
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
    end,
})

TabConfig:Button({
    Title = "Rejoin",
    Desc  = "Rejoins the current game server.",
    Callback = function()
        WindUI:Notify({ Title = "Rejoin", Content = "Rejoining server...", Duration = 2, Icon = "refresh-cw" })
        task.wait(1)
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- ====================== SKIP VOTE LOOP ======================
local SkipVoteTimer = 0
local SkipVoteHeartbeat = RunService.Heartbeat:Connect(function()
    if Config.AutoSkipWave and os.clock() - SkipVoteTimer > 5 then
        SkipVoteTimer = os.clock()
        pcall(function() SkipVote:FireServer(true) end)
    end
end)

-- ====================== APPLY SAVED STATES ON LOAD ======================
if Config.FullBright then SetFullBright(true) end
if Config.NoFog      then SetNoFog(true) end
if Config.FPSUncap   then ApplyFPSSettings() end
if Config.FPSBooster then task.wait(1); EnableFPSBooster() end

RestartAutoSave()

print("[DYHUB] Version " .. version .. " | " .. ver .. " loaded successfully!")
print("[DYHUB] Config system active | Auto saving every 15 seconds")
