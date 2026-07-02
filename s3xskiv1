-- =========================
local version = "BETA"
local ver     = "v001.02"
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
local TeleportService   = game:GetService("TeleportService")
local TweenService      = game:GetService("TweenService")

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
    Author     = "100 Days At Sea | " .. userversion,
    Folder     = "DYHUB_100day",
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
local ConfigFolder = "DYHUB_100day"
local CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self      = setmetatable({}, CustomConfig)
    self.ConfigData = {}
    self.ConfigPath = ConfigFolder .. "/100day_config.json"
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

-- ====================== SETTINGS TABLE ======================
local settings = {
    AutoSaveEnabled  = Config:Get("AutoSaveEnabled",  true),
    AutoSaveDelay    = Config:Get("AutoSaveDelay",    15),
    AutoGrinder      = Config:Get("AutoGrinder",      false),
    AutoCampfire     = Config:Get("AutoCampfire",     false),
    AutoEatEnabled   = Config:Get("AutoEatEnabled",   false),
    EatMode          = Config:Get("EatMode",          "Normal (Lapar)"),
    AutoCollect      = Config:Get("AutoCollect",      false),
    AutoAttack       = Config:Get("AutoAttack",       false),
    AttackMode       = Config:Get("AttackMode",       "Brutal All Target"),
    BrutalRange      = Config:Get("BrutalRange",      200),
    AutoPick         = Config:Get("AutoPick",         false),
    AutoChest        = Config:Get("AutoChest",        false),
    AutoFishing      = Config:Get("AutoFishing",      false),
    AutoStore        = Config:Get("AutoStore",        false),
    AutoDiscover     = Config:Get("AutoDiscover",     false),
    AutoDismantle    = Config:Get("AutoDismantle",    false),
    AutoHeal         = Config:Get("AutoHeal",         false),
    IslandESP        = Config:Get("IslandESP",        false),
    SoftAntiLag      = Config:Get("SoftAntiLag",      false),
    AutoClaimEffects = Config:Get("AutoClaimEffects", false),
    AutoNoFog        = Config:Get("AutoNoFog",        false),
    FlyEnabled       = Config:Get("FlyEnabled",       false),
    FlySpeed         = Config:Get("FlySpeed",         200),
    TargetMaterials  = Config:Get("TargetMaterials",  {}),
}

-- ====================== TABS ======================
local InfoTab     = Window:Tab({ Title = "Information", Icon = "info" })
local _D1         = Window:Divider()
local MainTab     = Window:Tab({ Title = "Main",        Icon = "rocket" })
local CombatTab   = Window:Tab({ Title = "Player",      Icon = "swords" })
local CollectTab  = Window:Tab({ Title = "Collect",     Icon = "package" })
local WorldTab    = Window:Tab({ Title = "World",       Icon = "globe" })
local EspTab      = Window:Tab({ Title = "Esp",         Icon = "eye" })
local _D2         = Window:Divider()
local SettingsTab = Window:Tab({ Title = "Settings",    Icon = "settings" })

Window:SelectTab(1)

-- =====================================================================
-- CORE REMOTE SYSTEM
-- =====================================================================
local CurrentSyncToken   = nil
local GameRemoteEvent    = nil
local GameRemoteFunction = nil

local function FindHiddenRemotes()
    local hiddenServices = { "Chat", "LocalizationService", "SocialService", "LogService" }
    for _, sName in ipairs(hiddenServices) do
        pcall(function()
            local service = game:GetService(sName)
            if service then
                local re = service:FindFirstChild("RemoteEvent")
                local rf = service:FindFirstChild("RemoteFunction")
                if re then GameRemoteEvent    = re end
                if rf then GameRemoteFunction = rf end
            end
        end)
    end
end
FindHiddenRemotes()

pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if (method == "FireServer" or method == "InvokeServer") then
                if self.Name == "RemoteEvent" or self.Name == "RemoteFunction" then
                    if type(args[1]) == "number" and type(args[2]) == "string" then
                        if not checkcaller() then
                            if self:IsA("RemoteEvent")    then GameRemoteEvent    = self end
                            if self:IsA("RemoteFunction") then GameRemoteFunction = self end
                            if CurrentSyncToken then
                                CurrentSyncToken = CurrentSyncToken + 1
                                args[1] = CurrentSyncToken
                                return oldNamecall(self, unpack(args))
                            else
                                CurrentSyncToken = args[1]
                            end
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

local function GetNextToken()
    if not CurrentSyncToken then CurrentSyncToken = math.random(100000, 999999) end
    CurrentSyncToken = CurrentSyncToken + 1
    return CurrentSyncToken
end

local function SafeRemoteEvent(actionName, ...)
    if GameRemoteEvent then
        GameRemoteEvent:FireServer(GetNextToken(), actionName, ...)
    else
        FindHiddenRemotes()
        if GameRemoteEvent then GameRemoteEvent:FireServer(GetNextToken(), actionName, ...) end
    end
end

local function SafeRemoteFunction(actionName, ...)
    if GameRemoteFunction then
        return GameRemoteFunction:InvokeServer(GetNextToken(), actionName, ...)
    else
        FindHiddenRemotes()
        if GameRemoteFunction then return GameRemoteFunction:InvokeServer(GetNextToken(), actionName, ...) end
    end
end

-- =====================================================================
-- SHARED STATE
-- =====================================================================
local TargetMaterials      = settings.TargetMaterials or {}
local AutoGrinderEnabled   = settings.AutoGrinder
local AutoCampfireEnabled  = settings.AutoCampfire
local AutoPickEnabled      = settings.AutoPick
local AutoEatEnabled       = settings.AutoEatEnabled
local EatMode              = settings.EatMode
local AutoDoubloonEnabled  = settings.AutoCollect
local AutoAttackEnabled    = settings.AutoAttack
local AttackMode           = settings.AttackMode
local BrutalAttackRange    = settings.BrutalRange
local AutoChestEnabled     = settings.AutoChest
local AutoFishingEnabled   = settings.AutoFishing
local AutoStoreEnabled     = settings.AutoStore
local AutoDiscoverEnabled  = settings.AutoDiscover
local AutoDismantleEnabled = settings.AutoDismantle
local AutoHealEnabled      = settings.AutoHeal
local IslandESPEnabled     = settings.IslandESP
local SoftAntiLagEnabled   = settings.SoftAntiLag
local AutoClaimEnabled     = settings.AutoClaimEffects
local AutoNoFogEnabled     = settings.AutoNoFog
local UniversalFlyEnabled  = settings.FlyEnabled
local UniversalFlySpeed    = settings.FlySpeed
local LastFlareTime        = 0
local CollectedItems       = {}
local HasDiamondChest      = false
local DiscoveredIslands    = {}

LocalPlayer.CharacterAdded:Connect(function()
    CollectedItems  = {}
    HasDiamondChest = false
end)

local GrinderToggle  = nil
local CampfireToggle = nil

-- =====================================================================
-- FEATURE FUNCTIONS
-- =====================================================================

-- AUTO GRINDER
local function StartAutoGrinder()
    task.spawn(function()
        while AutoGrinderEnabled do
            local DebrisField = workspace:FindFirstChild("DebrisField")
            local GrinderCol  = workspace:FindFirstChild("SpawnIsland")
                and workspace.SpawnIsland:FindFirstChild("Grinder")
                and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")
            if DebrisField and GrinderCol then
                for _, fo in ipairs(DebrisField:GetChildren()) do
                    if not AutoGrinderEnabled then break end
                    if fo:GetAttribute("RZY_Processed") then continue end
                    local resType = fo:GetAttribute("Resource") or fo:GetAttribute("Item")
                    local part = fo:FindFirstChildWhichIsA("BasePart") or fo:FindFirstChildWhichIsA("MeshPart")
                    if not resType and part then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                    if resType and TargetMaterials[resType] and part then
                        local excluded = false
                        for attrName, attrValue in pairs(fo:GetAttributes()) do
                            local lN = string.lower(attrName)
                            local lV = type(attrValue)=="string" and string.lower(attrValue) or ""
                            if string.find(lN,"armor") or string.find(lV,"armor") or
                               string.find(lN,"chest") or string.find(lV,"chest") or
                               string.find(lN,"leg")   or string.find(lV,"leg") then
                                excluded = true; break
                            end
                        end
                        if not excluded then
                            local grabber    = fo:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                            local lastHolder = fo:GetAttribute("LastHolder") or part:GetAttribute("LastHolder")
                            local myId, myName = tostring(LocalPlayer.UserId), LocalPlayer.Name
                            local isGrabbed = fo:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                            local isMine = (isGrabbed==true and (tostring(grabber)==myId or grabber==myName)) or (lastHolder==myName)
                            if isMine then
                                part.CFrame = GrinderCol.CFrame + Vector3.new(0,1,0)
                                part.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                pcall(function() SafeRemoteEvent("GiveUpOwnership", part) end)
                                fo:SetAttribute("RZY_Processed", true)
                            end
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

-- AUTO CAMPFIRE
local function StartAutoCampfire()
    task.spawn(function()
        while AutoCampfireEnabled do
            local DebrisField = workspace:FindFirstChild("DebrisField")
            local Dropper = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Dropper")
            if DebrisField and Dropper then
                local dropperPart = Dropper:IsA("BasePart") and Dropper
                    or Dropper:FindFirstChildWithClass("BasePart")
                    or (Dropper:IsA("Model") and Dropper.PrimaryPart)
                if dropperPart then
                    local validFuels = { ["Wood"]=true, ["Small Gas Can"]=true, ["Big Gas Can"]=true, ["Gas Drum"]=true }
                    for _, fo in ipairs(DebrisField:GetChildren()) do
                        if not AutoCampfireEnabled then break end
                        if fo:GetAttribute("RZY_Processed") then continue end
                        local resType = fo:GetAttribute("Resource") or fo:GetAttribute("Item")
                        local part = fo:FindFirstChildWhichIsA("BasePart") or fo:FindFirstChildWhichIsA("MeshPart")
                        if not resType and part then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                        if resType and TargetMaterials[resType] and validFuels[resType] and part then
                            local excluded = false
                            for attrName, attrValue in pairs(fo:GetAttributes()) do
                                local lN = string.lower(attrName)
                                local lV = type(attrValue)=="string" and string.lower(attrValue) or ""
                                if string.find(lN,"armor") or string.find(lV,"armor") or
                                   string.find(lN,"chest") or string.find(lV,"chest") or
                                   string.find(lN,"leg")   or string.find(lV,"leg") then
                                    excluded = true; break
                                end
                            end
                            if not excluded then
                                local grabber    = fo:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                local lastHolder = fo:GetAttribute("LastHolder") or part:GetAttribute("LastHolder")
                                local myId, myName = tostring(LocalPlayer.UserId), LocalPlayer.Name
                                local isGrabbed = fo:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                                local isMine = (isGrabbed==true and (tostring(grabber)==myId or grabber==myName)) or (lastHolder==myName)
                                if isMine then
                                    part.CFrame = dropperPart.CFrame
                                    part.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                    pcall(function() SafeRemoteEvent("GiveUpOwnership", part) end)
                                    fo:SetAttribute("RZY_Processed", true)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

-- AUTO EAT
local function RunAutoEat()
    task.spawn(function()
        local PGui    = LocalPlayer:WaitForChild("PlayerGui")
        local FillBar = PGui:WaitForChild("HUD"):WaitForChild("Food"):WaitForChild("Bar"):WaitForChild("Fill")
        while AutoEatEnabled do
            pcall(function()
                local DebrisField = workspace:FindFirstChild("DebrisField")
                if not DebrisField then return end
                if EatMode == "Normal (Lapar)" then
                    if FillBar.Size.X.Scale <= 0.7 then
                        for _, fo in ipairs(DebrisField:GetChildren()) do
                            if not AutoEatEnabled or FillBar.Size.X.Scale >= 0.99 or EatMode ~= "Normal (Lapar)" then break end
                            local isFood = fo:GetAttribute("Food")
                            local part = fo:FindFirstChildWhichIsA("BasePart") or fo:FindFirstChildWhichIsA("MeshPart")
                            if not isFood and part then isFood = part:GetAttribute("Food") end
                            if isFood and part then
                                local isGrabbed = fo:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                                local grabber   = fo:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                if isGrabbed and tostring(grabber)~=tostring(LocalPlayer.UserId) and grabber~=LocalPlayer.Name then continue end
                                SafeRemoteEvent("Eat", "~s"..fo.Name)
                                task.wait(0.05)
                            end
                        end
                    end
                elseif EatMode == "Brutal (Sapu Bersih)" then
                    for _, fo in ipairs(DebrisField:GetChildren()) do
                        if not AutoEatEnabled or EatMode ~= "Brutal (Sapu Bersih)" then break end
                        local isFood = fo:GetAttribute("Food")
                        local part = fo:FindFirstChildWhichIsA("BasePart") or fo:FindFirstChildWhichIsA("MeshPart")
                        if not isFood and part then isFood = part:GetAttribute("Food") end
                        if isFood and part then
                            local isGrabbed = fo:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                            local grabber   = fo:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                            if isGrabbed and tostring(grabber)~=tostring(LocalPlayer.UserId) and grabber~=LocalPlayer.Name then continue end
                            task.spawn(function() pcall(function() SafeRemoteEvent("Eat","~s"..fo.Name) end) end)
                            task.wait(0.01)
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- AUTO COLLECT
local TargetWeaponsCollect = {
    ["machete"]=true, ["poku poku"]=true, ["swordfish spear"]=true, ["ghost cutlass"]=true,
    ["flintlock"]=true, ["blunderbuss"]=true, ["rifle"]=true, ["boomstick"]=true,
    ["magma staff"]=true, ["ice staff"]=true, ["squid laser"]=true, ["revolver"]=true,
    ["hand cannon"]=true, ["angler flare"]=true, ["medkit"]=true
}

local function RunAutoCollect()
    task.spawn(function()
        while AutoDoubloonEnabled do
            local DebrisField = workspace:FindFirstChild("DebrisField")
            local character   = LocalPlayer.Character
            local humanoid    = character and character:FindFirstChild("Humanoid")
            local rootPart    = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
            if humanoid and humanoid.Health <= 0 then HasDiamondChest=false; CollectedItems={} end
            if DebrisField and rootPart then
                for _, fo in ipairs(DebrisField:GetChildren()) do
                    if not AutoDoubloonEnabled then break end
                    local part     = fo:FindFirstChildWhichIsA("BasePart") or fo:FindFirstChildWhichIsA("MeshPart")
                    local uniqueId = fo.Name
                    local isChest  = false
                    if fo:GetAttribute("DoubloonChest") or (part and part:GetAttribute("DoubloonChest")) then isChest=true end
                    if not isChest then
                        for attrName, attrValue in pairs(fo:GetAttributes()) do
                            local lN = string.lower(attrName)
                            local lV = type(attrValue)=="string" and string.lower(attrValue) or ""
                            if string.find(lN,"doubloonchest") or string.find(lV,"doubloonchest") then isChest=true; break end
                        end
                    end
                    if isChest then SafeRemoteEvent("Collect","~s"..uniqueId); task.wait(0.3); continue end
                    if part then
                        local resType = fo:GetAttribute("Resource") or fo:GetAttribute("Item")
                        if not resType then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                        if not resType then resType = part.Name end
                        if resType then
                            local dist = (part.Position - rootPart.Position).Magnitude
                            if dist <= 15 then
                                local shouldCollect = false
                                local lowerRes = string.lower(resType)
                                if string.find(lowerRes,"ammo") or string.find(lowerRes,"bandage") then
                                    shouldCollect = true
                                elseif string.find(lowerRes,"diamond") and (string.find(lowerRes,"chest") or string.find(lowerRes,"armor")) then
                                    if not HasDiamondChest then shouldCollect=true; HasDiamondChest=true end
                                else
                                    for wName in pairs(TargetWeaponsCollect) do
                                        if string.find(lowerRes,wName) then
                                            if not CollectedItems[wName] then shouldCollect=true; CollectedItems[wName]=true end
                                            break
                                        end
                                    end
                                end
                                if shouldCollect then SafeRemoteEvent("Collect","~s"..uniqueId); task.wait(0.1) end
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end

-- AUTO ATTACK
local function IsEnemyAlive(enemy)
    local healthVal = enemy:FindFirstChild("Health")
    if healthVal and (healthVal:IsA("IntValue") or healthVal:IsA("NumberValue")) then return healthVal.Value > 0 end
    local humanoid = enemy:FindFirstChild("Humanoid") or enemy:FindFirstChildOfClass("Humanoid")
    if humanoid then return humanoid.Health > 0 end
    return true
end

local function RunAutoAttack()
    task.spawn(function()
        while AutoAttackEnabled do
            pcall(function()
                local CreatureContainer = workspace:FindFirstChild("CreatureContainer")
                local character = LocalPlayer.Character
                local humanoid  = character and character:FindFirstChild("Humanoid")
                local rootPart  = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart"))
                if not (CreatureContainer and rootPart and humanoid) then return end

                local function CheckAttack(toolName, attackLogic)
                    local tool = character:FindFirstChild(toolName)
                    if tool and tool:IsA("Tool") then task.spawn(function() pcall(attackLogic, tool) end); return true end
                    return false
                end

                -- Angler Flare vs Wraith
                if tick() - LastFlareTime >= 1 then
                    for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                        if enemy.Name~="Wraith" and enemy.Name~="Wraith_CLIENT" then continue end
                        local ep = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                        if ep then
                            local ePos = enemy:IsA("Model") and enemy:GetPivot().Position or ep.Position
                            local fired = CheckAttack("Angler Flare", function(t)
                                local fp = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart") or rootPart
                                if fp then
                                    local oPos = fp.Position
                                    local dir  = (ePos - oPos).Unit
                                    local oStr = string.format("~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0", oPos.X,oPos.Y,oPos.Z,dir.X,dir.Y,dir.Z)
                                    local tStr = string.format("~v%.4f,%.4f,%.4f", ePos.X,ePos.Y,ePos.Z)
                                    SafeRemoteFunction("ToolReplicator","~sAngler Flare","~sFire",oStr,tStr)
                                end
                            end)
                            if fired then LastFlareTime = tick() end
                            break
                        end
                    end
                end

                local function AttackEnemy(enemy, enemyPart)
                    if not IsEnemyAlive(enemy) then return end
                    if enemy.Name=="Wraith" or enemy.Name=="Wraith_CLIENT" then return end
                    local ePos   = enemy:IsA("Model") and enemy:GetPivot().Position or enemyPart.Position
                    local vecStr = string.format("~v%.4f,%.4f,%.4f", ePos.X,ePos.Y,ePos.Z)
                    pcall(function()
                        for _, wName in ipairs({"Harpoon","Riptide"}) do
                            CheckAttack(wName, function() SafeRemoteFunction("ToolReplicator","~s"..wName,"~sHitEnemy",enemy) end)
                        end
                        CheckAttack("Magma Staff", function() SafeRemoteFunction("ToolReplicator","~sMagma Staff","~sFire",vecStr) end)
                        CheckAttack("Squid Laser", function() SafeRemoteFunction("ToolReplicator","~sLaser","~sShoot",vecStr) end)
                        CheckAttack("Grenade",     function() SafeRemoteFunction("ToolReplicator","~sGrenade","~sThrow",vecStr,vecStr) end)
                        for _, gunName in ipairs({"Rifle","Flintlock","Blunderbuss","Revolver","Hand Cannon","Boomstick","DualPistols","Assault Rifle"}) do
                            CheckAttack(gunName, function(t)
                                local fp = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart") or rootPart
                                if fp then
                                    local dir  = (ePos - rootPart.Position).Unit
                                    local gStr = string.format("~t{1=~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0}", ePos.X,ePos.Y,ePos.Z,dir.X,dir.Y,dir.Z)
                                    SafeRemoteFunction("ToolReplicator","~sGun","~sShoot",fp,gStr)
                                end
                            end)
                        end
                        for _, meleeName in ipairs({"Machete","Ghost Cutlass","Poku Poku","Swordfish Spear"}) do
                            CheckAttack(meleeName, function(t)
                                local handle = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart")
                                if handle and enemyPart then
                                    t:Activate()
                                    if firetouchinterest then
                                        firetouchinterest(handle,enemyPart,0); task.wait(0.01); firetouchinterest(handle,enemyPart,1)
                                    end
                                end
                            end)
                        end
                    end)
                end

                if AttackMode == "Nearest (Global)" then
                    local nearestEnemy, nearestPart, shortest = nil, nil, math.huge
                    for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                        if enemy.Name=="Wraith" or enemy.Name=="Wraith_CLIENT" then continue end
                        if not IsEnemyAlive(enemy) then continue end
                        local ep = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                        if ep then
                            local d = (ep.Position - rootPart.Position).Magnitude
                            if d < shortest then shortest=d; nearestEnemy=enemy; nearestPart=ep end
                        end
                    end
                    if nearestEnemy and nearestPart then AttackEnemy(nearestEnemy, nearestPart) end
                elseif AttackMode == "Brutal All Target" then
                    for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                        if enemy.Name=="Wraith" or enemy.Name=="Wraith_CLIENT" then continue end
                        if not IsEnemyAlive(enemy) then continue end
                        local ep = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                        if ep then
                            local ePos = enemy:IsA("Model") and enemy:GetPivot().Position or ep.Position
                            if (ePos - rootPart.Position).Magnitude <= BrutalAttackRange then
                                AttackEnemy(enemy, ep)
                            end
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- AUTO PICK
local function IsItemValidToPick(fo, part)
    if fo:GetAttribute("RZY_Processed") then return false end
    if fo:GetAttribute("Grabbed") or part:GetAttribute("Grabbed") then return false end
    local resType = fo:GetAttribute("Resource") or fo:GetAttribute("Item")
    if not resType then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
    if not (resType and TargetMaterials[resType]) then return false end
    for attrName, attrValue in pairs(fo:GetAttributes()) do
        local lN = string.lower(attrName)
        local lV = type(attrValue)=="string" and string.lower(attrValue) or ""
        if string.find(lN,"armor") or string.find(lV,"armor") or
           string.find(lN,"chest") or string.find(lV,"chest") or
           string.find(lN,"leg")   or string.find(lV,"leg") then return false end
    end
    return true
end

local function StartAutoPick()
    task.spawn(function()
        while AutoPickEnabled do
            local DebrisField = workspace:FindFirstChild("DebrisField")
            local character   = LocalPlayer.Character
            local rootPart    = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
            local backpack    = LocalPlayer:FindFirstChild("Backpack")
            if DebrisField and rootPart then
                local pullTool = "Harpoon"
                if (character and character:FindFirstChild("Riptide")) or (backpack and backpack:FindFirstChild("Riptide")) then pullTool = "Riptide" end
                for _, fo in ipairs(DebrisField:GetChildren()) do
                    if not AutoPickEnabled then break end
                    local part = fo:FindFirstChildWhichIsA("BasePart") or fo:FindFirstChildWhichIsA("MeshPart")
                    if part and IsItemValidToPick(fo, part) then
                        task.spawn(function()
                            pcall(function()
                                local pos    = part.Position
                                local vecStr = string.format("~v%.4f,%.4f,%.4f", pos.X,pos.Y,pos.Z)
                                SafeRemoteFunction("ToolReplicator","~s"..pullTool,"~sGrab",fo,vecStr)
                            end)
                        end)
                        task.wait(0.1)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- AUTO CHEST
local function RunAutoChest()
    task.spawn(function()
        while AutoChestEnabled do
            local character = LocalPlayer.Character
            local rootPart  = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart"))
            if rootPart then
                local nearest, shortestDist = nil, 15
                local potentials = {}
                local ChestsFolder    = workspace:FindFirstChild("Chests")
                local IslandContainer = workspace:FindFirstChild("IslandContainer")
                if ChestsFolder then for _, c in ipairs(ChestsFolder:GetChildren()) do table.insert(potentials,c) end end
                if IslandContainer then
                    for _, island in ipairs(IslandContainer:GetChildren()) do
                        for _, item in ipairs(island:GetChildren()) do
                            if string.find(string.lower(item.Name),"chest") then table.insert(potentials,item) end
                        end
                    end
                end
                for _, chest in ipairs(potentials) do
                    local part = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local d = (part.Position - rootPart.Position).Magnitude
                        if d < shortestDist then shortestDist=d; nearest=chest end
                    end
                end
                if nearest then pcall(function() SafeRemoteFunction("OpenChest", nearest) end) end
            end
            task.wait(0.1)
        end
    end)
end

-- AUTO FISHING
local function RunAutoFishing()
    task.spawn(function()
        while AutoFishingEnabled do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Fishing Rod") then
                local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
                if rootPart then
                    local pos = rootPart.Position
                    local dir = rootPart.CFrame.LookVector
                    local vecStr = string.format("~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0", pos.X,pos.Y+1,pos.Z,dir.X,dir.Y,dir.Z)
                    pcall(function()
                        SafeRemoteFunction("ToolReplicator","~sFishing Rod","~sCast")
                        SafeRemoteFunction("ToolReplicator","~sFishing Rod","~sFishPoof",vecStr)
                    end)
                end
            end
            task.wait(1)
        end
    end)
end

-- AUTO STORE
local function RunAutoStore()
    task.spawn(function()
        local myId, myName = tostring(LocalPlayer.UserId), LocalPlayer.Name
        while AutoStoreEnabled do
            local DebrisField = workspace:FindFirstChild("DebrisField")
            if DebrisField then
                for _, fo in ipairs(DebrisField:GetChildren()) do
                    if not AutoStoreEnabled then break end
                    if fo:GetAttribute("RZY_Processed") then continue end
                    local isGrabbed = fo:GetAttribute("Grabbed")
                    local part = fo:FindFirstChildWhichIsA("BasePart") or fo:FindFirstChildWhichIsA("MeshPart")
                    if not isGrabbed and part then isGrabbed = part:GetAttribute("Grabbed") end
                    if isGrabbed then
                        local grabber = tostring(fo:GetAttribute("Grabber"))
                        if grabber == "nil" and part then grabber = tostring(part:GetAttribute("Grabber")) end
                        if grabber==myId or grabber==myName then
                            local resType = fo:GetAttribute("Resource") or fo:GetAttribute("Item")
                            if not resType and part then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                            if (resType=="Wood" or resType=="Metal") and part then
                                pcall(function() SafeRemoteEvent("StoreItem",part); fo:SetAttribute("RZY_Processed",true) end)
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- AUTO DISCOVER
local ExcludedIslandKW = {"RivalRig1","RivalRig2","RivalRig3","GhostGalleon","SquidIsland"}
local function StartAutoDiscover()
    task.spawn(function()
        while AutoDiscoverEnabled do
            pcall(function()
                local char      = LocalPlayer.Character
                local root      = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart"))
                local container = workspace:FindFirstChild("IslandContainer")
                if root and container then
                    local pending = {}
                    for _, island in ipairs(container:GetChildren()) do
                        local excluded = false
                        for _, kw in ipairs(ExcludedIslandKW) do
                            if string.find(island.Name, kw) then excluded=true; break end
                        end
                        if not DiscoveredIslands[island] and not excluded then table.insert(pending, island) end
                    end
                    for _, island in ipairs(pending) do
                        if not AutoDiscoverEnabled or not root.Parent then return end
                        root.CFrame = island:GetPivot() * CFrame.new(0,50,0)
                        task.wait(2)
                        DiscoveredIslands[island] = true
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- AUTO DISMANTLE
local DismantleExceptions = { ["Small Shelter"]=true, ["Container Shelter"]=true, ["Makeshift Building"]=true, ["Outpost"]=true }
local function RunAutoDismantle()
    task.spawn(function()
        while AutoDismantleEnabled do
            pcall(function()
                local spawnIsland   = workspace:FindFirstChild("SpawnIsland")
                local craftedFolder = spawnIsland and spawnIsland:FindFirstChild("Crafted")
                if craftedFolder then
                    for _, item in ipairs(craftedFolder:GetChildren()) do
                        if not AutoDismantleEnabled then break end
                        local excluded = false
                        for exName in pairs(DismantleExceptions) do
                            if string.find(item.Name,exName) then excluded=true; break end
                        end
                        if string.find(item.Name,":") and not excluded then
                            task.spawn(function()
                                pcall(function() SafeRemoteFunction("ToolReplicator","~sWrench","~sTeardown","~s"..item.Name) end)
                            end)
                            task.wait(0.01)
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- AUTO HEAL
local function RunAutoHeal()
    task.spawn(function()
        while AutoHealEnabled do
            pcall(function()
                local character = LocalPlayer.Character
                local humanoid  = character and character:FindFirstChild("Humanoid")
                local backpack  = LocalPlayer:FindFirstChild("Backpack")
                if humanoid and humanoid.Health > 0 and humanoid.Health <= 70 then
                    local currentTool = character:FindFirstChildWhichIsA("Tool")
                    local prevName    = currentTool and currentTool.Name or nil
                    local bandage     = (backpack and backpack:FindFirstChild("Bandage")) or character:FindFirstChild("Bandage")
                    if bandage then
                        humanoid:EquipTool(bandage); task.wait(0.05)
                        while AutoHealEnabled and humanoid and humanoid.Health < humanoid.MaxHealth and humanoid.Health > 0 do
                            if not character:FindFirstChild("Bandage") then humanoid:EquipTool(bandage) end
                            SafeRemoteFunction("ToolReplicator","~sBandage","~sHeal")
                            task.wait(0.05)
                        end
                        if prevName and prevName ~= "Bandage" then
                            local toolToEquip = (backpack and backpack:FindFirstChild(prevName)) or character:FindFirstChild(prevName)
                            if toolToEquip then humanoid:EquipTool(toolToEquip) end
                        elseif not prevName then
                            humanoid:UnequipTools()
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

-- ISLAND ESP
local IslandConfig = {
    ["RivalRig1"]            = {Text="Rival Rig 1",               Color=Color3.fromRGB(255,65,65)},
    ["RivalRig2"]            = {Text="Rival Rig 2",               Color=Color3.fromRGB(255,65,65)},
    ["RivalRig3"]            = {Text="Rival Rig 3",               Color=Color3.fromRGB(255,65,65)},
    ["CageIsland"]           = {Text="Cage Island (Survivor)",    Color=Color3.fromRGB(50,255,50)},
    ["TrappedIsland"]        = {Text="Trapped Island (Survivor)", Color=Color3.fromRGB(50,255,50)},
    ["PirateChallengeIsland"]= {Text="Pirate Challenge Island",   Color=Color3.fromRGB(50,255,50)},
    ["SkullIsland"]          = {Text="Skull Island (Green Key)",  Color=Color3.fromRGB(255,255,0)},
    ["ShantyIsland"]         = {Text="Shanty Island",             Color=Color3.fromRGB(255,200,0)},
    ["TempleIsland"]         = {Text="Temple Island",             Color=Color3.fromRGB(255,200,0)},
    ["PirateStronghold"]     = {Text="Pirate Stronghold",         Color=Color3.fromRGB(255,30,30)},
    ["SquidIslandMain"]      = {Text="Squid Island Main",         Color=Color3.fromRGB(200,50,255)},
}

local function CleanAllIslandESP()
    local ic = workspace:FindFirstChild("IslandContainer")
    if ic then
        for _, c in ipairs(ic:GetDescendants()) do
            if c.Name == "IslandESP_Gui" then c:Destroy() end
        end
    end
end

local function StartIslandScanner()
    task.spawn(function()
        while IslandESPEnabled do
            pcall(function()
                local ic        = workspace:FindFirstChild("IslandContainer")
                local character = LocalPlayer.Character
                local root      = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso"))
                if not ic then return end
                for _, child in ipairs(ic:GetChildren()) do
                    if not IslandESPEnabled then break end
                    local cfg = IslandConfig[child.Name]
                    local displayName, displayColor = nil, nil
                    if cfg then
                        displayName = cfg.Text; displayColor = cfg.Color
                    elseif string.find(child.Name,"^SquidIsland") and child.Name~="SquidIslandMain" then
                        displayName  = "Squid Island "..(string.match(child.Name,"%d+") or "")
                        displayColor = Color3.fromRGB(230,130,255)
                    end
                    if displayName and displayColor then
                        local targetPart = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart")
                        if not targetPart and child:IsA("Model") and child.PrimaryPart then targetPart = child.PrimaryPart end
                        if not targetPart then targetPart = child:FindFirstChildWhichIsA("BasePart",true) end
                        if targetPart then
                            local espGui = targetPart:FindFirstChild("IslandESP_Gui")
                            if not espGui then
                                espGui = Instance.new("BillboardGui")
                                espGui.Name="IslandESP_Gui"; espGui.AlwaysOnTop=true
                                espGui.Size=UDim2.new(0,200,0,40); espGui.StudsOffset=Vector3.new(0,20,0)
                                espGui.Adornee=targetPart; espGui.Parent=targetPart
                                local lbl = Instance.new("TextLabel")
                                lbl.Name="DistanceText"; lbl.Size=UDim2.new(1,0,1,0)
                                lbl.BackgroundTransparency=1; lbl.TextColor3=displayColor
                                lbl.TextSize=13; lbl.Font=Enum.Font.SourceSans
                                lbl.TextStrokeTransparency=0.3; lbl.TextStrokeColor3=Color3.new()
                                lbl.Parent=espGui
                            end
                            local lbl = espGui:FindFirstChild("DistanceText")
                            if lbl and root then
                                local d = (targetPart.Position - root.Position).Magnitude
                                lbl.Text = string.format("%s [%dm]", displayName, math.floor(d))
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- SOFT ANTI-LAG
local function StartSoftAntiLag()
    task.spawn(function()
        local terrain = workspace.Terrain
        while SoftAntiLagEnabled do
            pcall(function()
                if terrain then terrain.WaterWaveSize=0; terrain.WaterWaveSpeed=0; terrain.WaterReflectance=0 end
                Lighting.GlobalShadows=false; Lighting.EnvironmentDiffuseScale=0; Lighting.EnvironmentSpecularScale=0
                local DebrisField = workspace:FindFirstChild("DebrisField")
                if DebrisField then
                    for _, f in ipairs(DebrisField:GetChildren()) do
                        local p = f:FindFirstChildWhichIsA("BasePart") or f:FindFirstChildWhichIsA("MeshPart")
                        if p and p.CastShadow then p.CastShadow=false end
                    end
                end
            end)
            task.wait(5)
        end
    end)
end

-- AUTO CLAIM EFFECTS
local function RunAutoClaimEffects()
    task.spawn(function()
        while AutoClaimEnabled do
            pcall(function()
                local effectsFolder = workspace:FindFirstChild("Effects")
                local character     = LocalPlayer.Character
                local rootPart      = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso"))
                if effectsFolder and rootPart then
                    for _, fo in ipairs(effectsFolder:GetChildren()) do
                        if not AutoClaimEnabled then break end
                        if tonumber(fo.Name) ~= nil then
                            for _, obj in ipairs(fo:GetDescendants()) do
                                if not AutoClaimEnabled then break end
                                if obj:IsA("ProximityPrompt") and obj.Enabled then
                                    local promptPart = obj.Parent
                                    if promptPart and promptPart:IsA("BasePart") then
                                        local d = (promptPart.Position - rootPart.Position).Magnitude
                                        if d <= 25 then
                                            if fireproximityprompt then fireproximityprompt(obj,1,0) end
                                            task.wait(1.5)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

-- AUTO NO-FOG
local function RunAutoNoFog()
    task.spawn(function()
        while AutoNoFogEnabled do
            pcall(function()
                Lighting.FogEnd=9e9; Lighting.FogStart=9e9
                local atm = Lighting:FindFirstChildOfClass("Atmosphere")
                if atm then atm.Density=0; atm.Glare=0; atm.Haze=0 end
            end)
            task.wait(3)
        end
    end)
end

-- UNIVERSAL FLY
local UFlyConnection    = nil
local currentMoverTarget = nil
local currentBG         = nil
local currentBV         = nil

local function ClearFlyMovers()
    if currentBG then currentBG:Destroy(); currentBG=nil end
    if currentBV then currentBV:Destroy(); currentBV=nil end
    currentMoverTarget = nil
    pcall(function()
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand=false end
    end)
end

local function ApplyFixCam(humanoid)
    task.spawn(function()
        task.wait(0.15)
        local camera = workspace.CurrentCamera
        if camera and humanoid then camera.CameraType=Enum.CameraType.Custom; camera.CameraSubject=humanoid end
    end)
end

local function StopUniversalFly()
    UniversalFlyEnabled = false
    if UFlyConnection then UFlyConnection:Disconnect(); UFlyConnection=nil end
    ClearFlyMovers()
end

local function StartUniversalFly()
    if UFlyConnection then return end
    UFlyConnection = RunService.Stepped:Connect(function()
        if not UniversalFlyEnabled then StopUniversalFly(); return end
        local char     = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local rootPart = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart"))
        local camera   = workspace.CurrentCamera
        if not humanoid or not rootPart or humanoid.Health <= 0 then return end
        if rootPart.Anchored then
            if currentBV then currentBV.velocity=Vector3.new(0,0,0) end; return
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide=false end
        end
        local expectedTarget = humanoid.SeatPart or rootPart
        local isVehicle      = (expectedTarget ~= rootPart)
        if currentMoverTarget ~= expectedTarget then
            local wasVehicle = currentMoverTarget and (currentMoverTarget:IsA("VehicleSeat") or currentMoverTarget:IsA("Seat"))
            ClearFlyMovers()
            currentMoverTarget = expectedTarget
            if wasVehicle and not isVehicle then
                humanoid.Sit=false; rootPart.CFrame=rootPart.CFrame+Vector3.new(0,3,0); task.wait(0.05)
            end
            if isVehicle then ApplyFixCam(humanoid) end
            currentBG = Instance.new("BodyGyro")
            currentBG.P=9e4; currentBG.maxTorque=isVehicle and Vector3.new(1e5,1e5,1e5) or Vector3.new(9e9,9e9,9e9)
            currentBG.cframe=expectedTarget.CFrame; currentBG.Parent=expectedTarget
            currentBV = Instance.new("BodyVelocity")
            currentBV.velocity=Vector3.new(0,0,0); currentBV.maxForce=Vector3.new(9e9,9e9,9e9)
            currentBV.Parent=expectedTarget
        end
        humanoid.PlatformStand = not isVehicle
        local moveDir = Vector3.new(0,0,0)
        if humanoid.MoveDirection.Magnitude > 0.1 then
            local lm = camera.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
            if math.abs(lm.Z) > 0.1 then moveDir = moveDir + camera.CFrame.LookVector  * -lm.Z end
            if math.abs(lm.X) > 0.1 then moveDir = moveDir + camera.CFrame.RightVector *  lm.X end
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
        if currentBG and currentBV then
            currentBG.cframe   = camera.CFrame
            currentBV.velocity = moveDir.Magnitude > 0 and (moveDir.Unit * UniversalFlySpeed) or Vector3.new(0,0,0)
        end
    end)
end

-- HUD FIX
task.spawn(function()
    local PGui = LocalPlayer:WaitForChild("PlayerGui")
    pcall(function()
        local HUD = PGui:WaitForChild("HUD",10)
        local FeaturesUI = HUD and HUD:WaitForChild("Features",10)
        if FeaturesUI then
            FeaturesUI.Visible = true
            local mapUI = FeaturesUI:WaitForChild("Map",5)
            if mapUI then mapUI.Visible=true end
            local timerUI = FeaturesUI:WaitForChild("Timer",5)
            if timerUI then timerUI.Visible=true end
        end
    end)
end)

-- =====================================================================
-- UI: MAIN TAB  (Materials / Processing)
-- =====================================================================
MainTab:Divider()
MainTab:Section({ Title = "Materials", Icon = "box" })

MainTab:Dropdown({
    Title    = "Target Materials",
    Desc     = "วัสดุที่ต้องการใช้กับ Auto Grinder / Campfire / Pick",
    Values   = {"Wood","Metal","Goo","Small Gas Can","Big Gas Can","Gas Drum","Small Crate","Big Crate","Penguin"},
    Multi    = true,
    Value    = settings.TargetMaterials,
    Callback = function(selectedTable)
        TargetMaterials = selectedTable
        settings.TargetMaterials = selectedTable
        Config:Set("TargetMaterials", selectedTable); Config:Save()
    end
})

MainTab:Divider()
MainTab:Section({ Title = "Processing", Icon = "settings" })

GrinderToggle = MainTab:Toggle({
    Title    = "Auto Grinder",
    Desc     = "ส่งวัสดุที่ถือไปยัง Grinder อัตโนมัติ (ปิด Auto Campfire อัตโนมัติ)",
    Value    = AutoGrinderEnabled,
    Callback = function(v)
        AutoGrinderEnabled = v; settings.AutoGrinder = v
        Config:Set("AutoGrinder", v); Config:Save()
        if v then
            if AutoCampfireEnabled then AutoCampfireEnabled=false; CampfireToggle:Set(false) end
            StartAutoGrinder()
        end
        WindUI:Notify({ Title="Auto Grinder", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

CampfireToggle = MainTab:Toggle({
    Title    = "Auto Campfire",
    Desc     = "ส่งเชื้อเพลิงไปยัง Campfire/Dropper อัตโนมัติ (ปิด Auto Grinder อัตโนมัติ)",
    Value    = AutoCampfireEnabled,
    Callback = function(v)
        AutoCampfireEnabled = v; settings.AutoCampfire = v
        Config:Set("AutoCampfire", v); Config:Save()
        if v then
            if AutoGrinderEnabled then AutoGrinderEnabled=false; GrinderToggle:Set(false) end
            StartAutoCampfire()
        end
        WindUI:Notify({ Title="Auto Campfire", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

MainTab:Toggle({
    Title    = "Auto Pick Material",
    Desc     = "หยิบวัสดุที่เลือกอัตโนมัติโดยไม่จำกัดระยะ",
    Value    = AutoPickEnabled,
    Callback = function(v)
        AutoPickEnabled = v; settings.AutoPick = v
        Config:Set("AutoPick", v); Config:Save()
        if v then StartAutoPick() end
        WindUI:Notify({ Title="Auto Pick", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

MainTab:Toggle({
    Title    = "Auto Store (Wood & Metal)",
    Desc     = "เก็บ Wood และ Metal ที่ถือไปยัง Storage อัตโนมัติ",
    Value    = AutoStoreEnabled,
    Callback = function(v)
        AutoStoreEnabled = v; settings.AutoStore = v
        Config:Set("AutoStore", v); Config:Save()
        if v then RunAutoStore() end
        WindUI:Notify({ Title="Auto Store", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

MainTab:Toggle({
    Title    = "Auto Dismantle All",
    Desc     = "ทำลายสิ่งก่อสร้างทั้งหมด ยกเว้น Shelter / Outpost",
    Value    = AutoDismantleEnabled,
    Callback = function(v)
        AutoDismantleEnabled = v; settings.AutoDismantle = v
        Config:Set("AutoDismantle", v); Config:Save()
        if v then RunAutoDismantle() end
        WindUI:Notify({ Title="Auto Dismantle", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

-- =====================================================================
-- UI: COMBAT TAB
-- =====================================================================
CombatTab:Divider()
CombatTab:Section({ Title = "Auto Attack", Icon = "swords" })

CombatTab:Dropdown({
    Title    = "Attack Mode",
    Desc     = "วิธีเลือกเป้าโจมตี",
    Values   = {"Nearest (Global)", "Brutal All Target"},
    Multi    = false,
    Value    = AttackMode,
    Callback = function(v)
        AttackMode = v; settings.AttackMode = v
        Config:Set("AttackMode", v); Config:Save()
        WindUI:Notify({ Title="Attack Mode", Content=v, Duration=2, Icon="settings" })
    end
})

CombatTab:Slider({
    Title    = "Brutal Attack Range",
    Desc     = "รัศมีโจมตีสำหรับ Brutal All Target (studs)",
    Value    = { Min=50, Max=1000, Default=BrutalAttackRange },
    Step     = 10,
    Callback = function(v)
        BrutalAttackRange = v; settings.BrutalRange = v
        Config:Set("BrutalRange", v); Config:Save()
    end
})

CombatTab:Toggle({
    Title    = "Auto Attack",
    Desc     = "โจมตีศัตรูอัตโนมัติตามโหมดที่เลือก",
    Value    = AutoAttackEnabled,
    Callback = function(v)
        AutoAttackEnabled = v; settings.AutoAttack = v
        Config:Set("AutoAttack", v); Config:Save()
        if v then RunAutoAttack() end
        WindUI:Notify({ Title="Auto Attack", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

CombatTab:Divider()
CombatTab:Section({ Title = "Survival", Icon = "heart" })

CombatTab:Dropdown({
    Title    = "Auto Eat Mode",
    Desc     = "Normal = กินเมื่อหิว | Brutal = เก็บกวาดอาหารทั้งแมพ",
    Values   = {"Normal (Lapar)", "Brutal (Sapu Bersih)"},
    Multi    = false,
    Value    = EatMode,
    Callback = function(v)
        EatMode = v; settings.EatMode = v
        Config:Set("EatMode", v); Config:Save()
        WindUI:Notify({ Title="Eat Mode", Content=v, Duration=2, Icon="settings" })
    end
})

CombatTab:Toggle({
    Title    = "Auto Eat",
    Desc     = "กินอาหารอัตโนมัติตามโหมดที่เลือก",
    Value    = AutoEatEnabled,
    Callback = function(v)
        AutoEatEnabled = v; settings.AutoEatEnabled = v
        Config:Set("AutoEatEnabled", v); Config:Save()
        if v then RunAutoEat() end
        WindUI:Notify({ Title="Auto Eat", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

CombatTab:Toggle({
    Title    = "Auto Heal (HP ≤ 70)",
    Desc     = "ใช้ Bandage อัตโนมัติเมื่อ HP ต่ำกว่า 70 แล้วคืนอาวุธเดิม",
    Value    = AutoHealEnabled,
    Callback = function(v)
        AutoHealEnabled = v; settings.AutoHeal = v
        Config:Set("AutoHeal", v); Config:Save()
        if v then RunAutoHeal() end
        WindUI:Notify({ Title="Auto Heal", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

-- =====================================================================
-- UI: COLLECT TAB
-- =====================================================================
CollectTab:Divider()
CollectTab:Section({ Title = "Collection", Icon = "package" })

CollectTab:Toggle({
    Title    = "Auto Collect",
    Desc     = "เก็บ Chest / Ammo / Bandage / อาวุธใกล้ ๆ อัตโนมัติ",
    Value    = AutoDoubloonEnabled,
    Callback = function(v)
        AutoDoubloonEnabled = v; settings.AutoCollect = v
        Config:Set("AutoCollect", v); Config:Save()
        if v then RunAutoCollect() end
        WindUI:Notify({ Title="Auto Collect", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

CollectTab:Toggle({
    Title    = "Auto Open Chest",
    Desc     = "เปิดหีบที่อยู่ในระยะ 15 studs อัตโนมัติ",
    Value    = AutoChestEnabled,
    Callback = function(v)
        AutoChestEnabled = v; settings.AutoChest = v
        Config:Set("AutoChest", v); Config:Save()
        if v then RunAutoChest() end
        WindUI:Notify({ Title="Auto Chest", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

CollectTab:Toggle({
    Title    = "Auto Fishing",
    Desc     = "ตกปลาอัตโนมัติเมื่อถือ Fishing Rod",
    Value    = AutoFishingEnabled,
    Callback = function(v)
        AutoFishingEnabled = v; settings.AutoFishing = v
        Config:Set("AutoFishing", v); Config:Save()
        if v then RunAutoFishing() end
        WindUI:Notify({ Title="Auto Fishing", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

CollectTab:Toggle({
    Title    = "Auto Claim Effects",
    Desc     = "กด ProximityPrompt ในโฟลเดอร์ Effects ระยะ 25 studs",
    Value    = AutoClaimEnabled,
    Callback = function(v)
        AutoClaimEnabled = v; settings.AutoClaimEffects = v
        Config:Set("AutoClaimEffects", v); Config:Save()
        if v then RunAutoClaimEffects() end
        WindUI:Notify({ Title="Auto Claim Effects", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

-- =====================================================================
-- UI: WORLD TAB
-- =====================================================================
WorldTab:Divider()
WorldTab:Section({ Title = "Movement", Icon = "user" })

WorldTab:Slider({
    Title    = "Fly Speed",
    Desc     = "ความเร็วของ Universal Fly",
    Value    = { Min=10, Max=1000, Default=UniversalFlySpeed },
    Step     = 10,
    Callback = function(v)
        UniversalFlySpeed = v; settings.FlySpeed = v
        Config:Set("FlySpeed", v); Config:Save()
    end
})

WorldTab:Toggle({
    Title    = "Universal Fly + NoClip",
    Desc     = "บินผ่านกำแพงได้ทุกที่ [Space=ขึ้น] [Ctrl=ลง]",
    Value    = UniversalFlyEnabled,
    Callback = function(v)
        UniversalFlyEnabled = v; settings.FlyEnabled = v
        Config:Set("FlyEnabled", v); Config:Save()
        if v then StartUniversalFly() else StopUniversalFly() end
        WindUI:Notify({ Title="Universal Fly", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

WorldTab:Toggle({
    Title    = "Auto Discover Island",
    Desc     = "สุ่มเทเลพอร์ตไปยังเกาะที่ยังไม่ค้นพบ (ข้าม Rival Rig / Ghost Galleon)",
    Value    = AutoDiscoverEnabled,
    Callback = function(v)
        AutoDiscoverEnabled = v; settings.AutoDiscover = v
        Config:Set("AutoDiscover", v); Config:Save()
        if v then StartAutoDiscover() end
        WindUI:Notify({ Title="Auto Discover", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

WorldTab:Divider()
WorldTab:Section({ Title = "Performance", Icon = "cpu" })

WorldTab:Toggle({
    Title    = "Soft Anti-Lag",
    Desc     = "ปิดคลื่น / เงา / WaterReflectance เพื่อเพิ่ม FPS",
    Value    = SoftAntiLagEnabled,
    Callback = function(v)
        SoftAntiLagEnabled = v; settings.SoftAntiLag = v
        Config:Set("SoftAntiLag", v); Config:Save()
        if v then
            StartSoftAntiLag()
        else
            pcall(function()
                local terrain = workspace.Terrain
                if terrain then terrain.WaterWaveSize=0.15; terrain.WaterWaveSpeed=10; terrain.WaterReflectance=1 end
                Lighting.GlobalShadows=true
            end)
        end
        WindUI:Notify({ Title="Soft Anti-Lag", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

WorldTab:Toggle({
    Title    = "Auto No-Fog",
    Desc     = "ลบหมอกทั้งแบบ Classic และ Atmosphere อัตโนมัติ",
    Value    = AutoNoFogEnabled,
    Callback = function(v)
        AutoNoFogEnabled = v; settings.AutoNoFog = v
        Config:Set("AutoNoFog", v); Config:Save()
        if v then RunAutoNoFog() end
        WindUI:Notify({ Title="No-Fog", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

-- =====================================================================
-- UI: ESP TAB
-- =====================================================================
EspTab:Divider()
EspTab:Section({ Title = "Island & Rig ESP", Icon = "eye" })

EspTab:Toggle({
    Title    = "Island & Rig ESP",
    Desc     = "แสดงชื่อและระยะทางเหนือเกาะ / Rig ทุกที่",
    Value    = IslandESPEnabled,
    Callback = function(v)
        IslandESPEnabled = v; settings.IslandESP = v
        Config:Set("IslandESP", v); Config:Save()
        if v then StartIslandScanner() else CleanAllIslandESP() end
        WindUI:Notify({ Title="Island ESP", Content=v and "เปิดแล้ว" or "ปิดแล้ว", Duration=3, Icon=v and "check-circle" or "x-circle" })
    end
})

-- =====================================================================
-- UI: INFORMATION TAB
-- =====================================================================
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

InfoTab:Section({ Title = "Latest Update", TextXAlignment = "Center", TextSize = 17 })
InfoTab:Divider()
InfoTab:Paragraph({
    Title = "Update: 07/02/2026 | CL: " .. ver,
    Desc  = [[• [ Added ] Auto Grinder / Auto Campfire
• [ Added ] Auto Attack — Nearest & Brutal All Target
• [ Added ] Auto Heal, Auto Eat (Normal & Brutal)
• [ Added ] Auto Collect, Auto Pick, Auto Store
• [ Added ] Auto Fishing, Auto Chest, Auto Dismantle
• [ Added ] Universal Fly + NoClip
• [ Added ] Island & Rig ESP
• [ Added ] Auto Discover Island
• [ Added ] Auto No-Fog, Soft Anti-Lag
• [ Added ] Auto Claim Effects
• [ Fixed ] Config auto-save system]],
})
InfoTab:Divider()

ui.Creator.Request = function(requestData)
    local success, result = pcall(function()
        if HttpService.RequestAsync then
            local response = HttpService:RequestAsync({ Url=requestData.Url, Method=requestData.Method or "GET", Headers=requestData.Headers or {} })
            return { Body=response.Body, StatusCode=response.StatusCode, Success=response.Success }
        else
            local body = HttpService:GetAsync(requestData.Url)
            return { Body=body, StatusCode=200, Success=true }
        end
    end)
    if success then return result else error("HTTP Request failed: "..tostring(result)) end
end

local InviteCode = "jWNDPNMmyB"
local DiscordAPI = "https://discord.com/api/v10/invites/"..InviteCode.."?with_counts=true&with_expiration=true"

local function LoadDiscordInfo()
    local success, result = pcall(function()
        return HttpService:JSONDecode(ui.Creator.Request({
            Url="https://discord.com/api/v10/invites/"..InviteCode.."?with_counts=true&with_expiration=true",
            Method="GET",
            Headers={ ["User-Agent"]="RobloxBot/1.0", ["Accept"]="application/json" }
        }).Body)
    end)
    if success and result and result.guild then
        local DiscordInfo = InfoTab:Paragraph({
            Title = result.guild.name,
            Desc  = ' <font color="#52525b">●</font> Member Count : '..tostring(result.approximate_member_count)..
                    '\n <font color="#16a34a">●</font> Online Count : '..tostring(result.approximate_presence_count),
            Image = "https://cdn.discordapp.com/icons/"..result.guild.id.."/"..result.guild.icon..".png?size=1024",
            ImageSize = 42,
        })
        InfoTab:Button({ Title="Update Info", Callback=function()
            local ok, r = pcall(function() return HttpService:JSONDecode(ui.Creator.Request({ Url=DiscordAPI, Method="GET" }).Body) end)
            if ok and r and r.guild then
                DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : '..tostring(r.approximate_member_count)..
                    '\n <font color="#16a34a">●</font> Online Count : '..tostring(r.approximate_presence_count))
                WindUI:Notify({ Title="Discord Info Updated", Content="Refreshed!", Duration=2, Icon="refresh-cw" })
            else
                WindUI:Notify({ Title="Update Failed", Content="Could not refresh.", Duration=3, Icon="alert-triangle" })
            end
        end })
        InfoTab:Button({ Title="Copy Discord Invite", Callback=function()
            setclipboard("https://discord.gg/"..InviteCode)
            WindUI:Notify({ Title="Copied!", Content="Discord invite copied!", Duration=2, Icon="clipboard-check" })
        end })
    else
        InfoTab:Paragraph({ Title="Error fetching Discord Info", Desc="Unable to load.", Image="triangle-alert", ImageSize=26, Color="Red" })
    end
end
LoadDiscordInfo()

InfoTab:Divider()
InfoTab:Section({ Title="DYHUB Information", TextXAlignment="Center", TextSize=17 })
InfoTab:Divider()
InfoTab:Paragraph({ Title="Main Owner", Desc="@dyumraisgoodguy#8888", Image="rbxassetid://119789418015420", ImageSize=30 })
InfoTab:Paragraph({ Title="Social", Desc="Copy link social media for follow!", Image="rbxassetid://104487529937663", ImageSize=30,
    Buttons={{ Icon="copy", Title="Copy Link", Callback=function() setclipboard("https://guns.lol/DYHUB") end }} })
InfoTab:Paragraph({ Title="Discord", Desc="Join our discord for more scripts!", Image="rbxassetid://104487529937663", ImageSize=30,
    Buttons={{ Icon="copy", Title="Copy Link", Callback=function() setclipboard("https://discord.gg/jWNDPNMmyB") end }} })

-- =====================================================================
-- UI: SETTINGS TAB
-- =====================================================================
SettingsTab:Divider()
SettingsTab:Section({ Title="Save Config", Icon="save" })

SettingsTab:Button({ Title="Save Config (NOW)", Desc="บันทึก Config ทันที", Callback=function()
    Config:Save()
    WindUI:Notify({ Title="Config Saved", Content="บันทึกสำเร็จ!", Duration=2, Icon="save" })
end })

local _AutoSaveEnabled = settings.AutoSaveEnabled
local _AutoSaveDelay   = settings.AutoSaveDelay

SettingsTab:Toggle({ Title="Auto Save Config", Desc="บันทึก Config อัตโนมัติตามช่วงเวลาที่กำหนด", Value=_AutoSaveEnabled, Callback=function(state)
    _AutoSaveEnabled = state; settings.AutoSaveEnabled = state
    Config:Set("AutoSaveEnabled", state); Config:Save()
    if state then Config:AutoSave(_AutoSaveDelay) else Config:AutoSave(0) end
end })

SettingsTab:Input({ Title="Delay Save Config", Value=tostring(_AutoSaveDelay), Placeholder="Default: 15", Callback=function(text)
    local num = tonumber(text)
    if num and num >= 1 then
        _AutoSaveDelay = num; settings.AutoSaveDelay = num
        Config:Set("AutoSaveDelay", num); Config:Save()
        if _AutoSaveEnabled then Config:AutoSave(num) end
    else warn("[DYHUB] Invalid delay value!") end
end })

SettingsTab:Divider()
SettingsTab:Section({ Title="Server", Icon="server" })

SettingsTab:Button({ Title="Serverhop", Desc="เทเลพอร์ตไปยัง Server อื่นแบบสุ่ม", Callback=function()
    local servers = {}
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
    end)
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                table.insert(servers, server.id)
            end
        end
    end
    if #servers > 0 then
        WindUI:Notify({ Title="Serverhop", Content="กำลังเทเลพอร์ต...", Duration=2, Icon="server" }); task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], LocalPlayer)
    else
        WindUI:Notify({ Title="Serverhop Failed", Content="ไม่พบ Server ว่าง", Duration=3, Icon="alert-triangle" })
    end
end })

SettingsTab:Button({ Title="Rejoin", Desc="เข้าเกมใหม่ใน Server เดิม", Callback=function()
    WindUI:Notify({ Title="Rejoin", Content="กำลัง Rejoin...", Duration=2, Icon="refresh-cw" }); task.wait(1)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end })

-- =====================================================================
-- AUTO-START DEFAULT-ON FEATURES
-- =====================================================================
if AutoEatEnabled       then RunAutoEat()         end
if AutoDoubloonEnabled  then RunAutoCollect()     end
if AutoAttackEnabled    then RunAutoAttack()      end
if AutoChestEnabled     then RunAutoChest()       end
if AutoFishingEnabled   then RunAutoFishing()     end
if AutoStoreEnabled     then RunAutoStore()       end
if AutoHealEnabled      then RunAutoHeal()        end
if IslandESPEnabled     then StartIslandScanner() end
if SoftAntiLagEnabled   then StartSoftAntiLag()  end
if UniversalFlyEnabled  then StartUniversalFly() end
if AutoGrinderEnabled   then StartAutoGrinder()  end
if AutoCampfireEnabled  then StartAutoCampfire() end
if AutoPickEnabled      then StartAutoPick()     end
if AutoDismantleEnabled then RunAutoDismantle()  end
if AutoDiscoverEnabled  then StartAutoDiscover() end
if AutoClaimEnabled     then RunAutoClaimEffects() end
if AutoNoFogEnabled     then RunAutoNoFog()      end

-- =====================================================================
print("[DYHUB] " .. version .. " | " .. ver .. " loaded successfully!")
print("[DYHUB] Config active | Auto saving every " .. tostring(settings.AutoSaveDelay) .. "s")
