-- =========================
local version = "BETA"
local ver     = "v029.10"
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local TweenService      = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = Workspace.CurrentCamera

-- ====================== CHARACTER CACHE ======================
local Character        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid         = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local function refreshCharacter(char)
    Character        = char
    Humanoid         = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end

LocalPlayer.CharacterAdded:Connect(refreshCharacter)

-- ====================== UTILITIES MODULE ======================
local Utils = {}
Utils.BusyLock = false

function Utils:Log(msg)
    print("[DYHUB] " .. tostring(msg))
end

function Utils:Notify(title, content, icon, duration)
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = duration or 2,
            Icon = icon or "info"
        })
    end)
end

function Utils:SafeCall(fn, ...)
    local args = {...}
    local ok, result = pcall(fn, unpack(args))
    if not ok then warn("[DYHUB] SafeCall failed: " .. tostring(result)) end
    return ok, result
end

function Utils:SafeCallRemote(remote, ...)
    if not remote then return false, "Remote not found" end
    local args = {...}
    return Utils:SafeCall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(args))
        elseif remote:IsA("RemoteFunction") then
            return remote:InvokeServer(unpack(args))
        else
            error("Invalid remote type")
        end
    end)
end

function Utils:GetTopLevelModel(instance)
    if not instance then return nil end
    local current = instance
    local lastModel = nil
    while current and current ~= Workspace do
        if current:IsA("Model") then lastModel = current end
        current = current.Parent
    end
    return lastModel
end

function Utils:GetSafePivot(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst.CFrame end
    if inst:IsA("Model") then
        local ok, cf = pcall(function() return inst:GetPivot() end)
        if ok and cf then return cf end
    end
    local sum, count = Vector3.new(), 0
    for _, d in ipairs(inst:GetDescendants()) do
        if d:IsA("BasePart") then
            sum = sum + d.Position
            count = count + 1
        end
    end
    if count > 0 then return CFrame.new(sum / count) end
    return nil
end

function Utils:IsGUID(str)
    if type(str) ~= "string" then return false end
    if #str ~= 36 then return false end
    local hyphens = 0
    for i = 1, #str do if str:sub(i, i) == "-" then hyphens = hyphens + 1 end end
    return hyphens == 4
end

-- ✅ FIXED: Find weight label with recursive search
function Utils:FindWeightLabel()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("UIControllerGui")
    if not gui then return nil end
    
    -- Try direct child first
    local label = gui:FindFirstChild("OverweightValue")
    if label then return label end
    
    -- Recursive search as fallback
    for _, desc in ipairs(gui:GetDescendants()) do
        if desc.Name == "OverweightValue" and (desc:IsA("TextLabel") or desc:IsA("TextButton")) then
            return desc
        end
    end
    
    return nil
end

-- ✅ FIXED: Parse vehicle weight with better regex
function Utils:ParseVehicleWeight()
    local label = self:FindWeightLabel()
    if not label then return nil, nil end
    
    local text = label.Text or ""
    -- Strip all HTML tags
    local stripped = text:gsub("<[^>]+>", "")
    -- Remove "kg" and other non-numeric chars
    stripped = stripped:gsub("kg", "")
    
    -- Try to match "X / Y" pattern
    local current = tonumber(stripped:match("(%d+)"))
    local max     = tonumber(stripped:match("/%s*(%d+)"))
    
    if current and max and max > 0 then
        return current, max
    end
    
    return nil, nil
end

-- ====================== WEIGHT TRACKER (NEW) ======================
local WeightTracker = {
    current = 0,
    max = 50,
    lastRead = 0,
    readInterval = 0.25,
    itemsCollected = 0,
    lastKnownGood = { current = 0, max = 50 }
}

function WeightTracker:Read(force)
    local now = tick()
    if not force and (now - self.lastRead) < self.readInterval then
        return self.current, self.max
    end
    self.lastRead = now
    
    local curr, max = Utils:ParseVehicleWeight()
    if curr and max and max > 0 then
        self.current = curr
        self.max = max
        self.lastKnownGood = { current = curr, max = max }
        self.itemsCollected = 0  -- Reset counter on real read
    end
    return self.current, self.max
end

function WeightTracker:AddItem()
    self.itemsCollected = self.itemsCollected + 1
    self.current = self.current + 1
    if self.current > self.max then
        self.current = self.max
    end
end

function WeightTracker:IsFull()
    self:Read(true)
    if self.current >= self.max then
        return true
    end
    -- Fallback: if we collected more items than max without UI updating
    if self.itemsCollected >= (self.max - 2) then
        return true
    end
    return false
end

function WeightTracker:Reset()
    self.current = 0
    self.itemsCollected = 0
    self.lastRead = 0
    self.max = 50
end

-- ====================== VEHICLE MANAGER ======================
local Vehicle = {}

function Vehicle:GetMyVehicle()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass('Humanoid')
    if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA('VehicleSeat') then
        return Utils:GetTopLevelModel(humanoid.SeatPart), true
    end

    local plotsFolder = Workspace:FindFirstChild("_Plots")
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            if plotsFolder and obj:IsDescendantOf(plotsFolder) then continue end
            if obj.Name:lower():find("plot") then continue end
            if obj:FindFirstChildWhichIsA("VehicleSeat", true) then
                return obj, false
            end
        end
    end
    return nil, false
end

function Vehicle:GetSeatedVehicle()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass('Humanoid')
    if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA('VehicleSeat') then
        return Utils:GetTopLevelModel(humanoid.SeatPart)
    end
    return nil
end

function Vehicle:IsSeated() return self:GetSeatedVehicle() ~= nil end

function Vehicle:GetDistanceFromPlayer(vehicle)
    if not vehicle then return math.huge end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return math.huge end
    local vehiclePart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart", true)
    if not vehiclePart then return math.huge end
    return (root.Position - vehiclePart.Position).Magnitude
end

function Vehicle:EnterByPrompt(vehicle)
    if not vehicle then return false end
    if self:IsSeated() then return true end

    local seat = vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
    if not seat then return false end

    local character = LocalPlayer.Character
    if not character then return false end
    local hum = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end

    if seat:IsA("BasePart") then
        local dist = (root.Position - seat.Position).Magnitude
        if dist > 15 then
            Movement:GoTo(seat.CFrame + Vector3.new(0, 2, 0), { timeout = 15 })
            task.wait(0.5)
        end
    end

    local prompt = nil
    for _, child in ipairs(seat:GetChildren()) do
        if child:IsA("ProximityPrompt") then prompt = child; break end
    end
    if not prompt and seat.Parent then
        for _, child in ipairs(seat.Parent:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                prompt = child
                break
            end
        end
    end

    if prompt then
        pcall(function() fireproximityprompt(prompt) end)
        local start = tick()
        while not self:IsSeated() and (tick() - start) < 3 do
            task.wait(0.2)
        end
    end

    if not self:IsSeated() then
        pcall(function() hum.Sit = seat end)
        local start = tick()
        while not self:IsSeated() and (tick() - start) < 3 do
            task.wait(0.2)
        end
    end

    return self:IsSeated()
end

function Vehicle:ExitByPrompt()
    if not self:IsSeated() then return true end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    local seatedVehicle = self:GetSeatedVehicle()
    local seat = seatedVehicle and seatedVehicle:FindFirstChildWhichIsA("VehicleSeat", true)

    if seat then
        local prompt = nil
        for _, child in ipairs(seat:GetChildren()) do
            if child:IsA("ProximityPrompt") then prompt = child; break end
        end
        if prompt then
            pcall(function() fireproximityprompt(prompt) end)
            task.wait(0.5)
        end
    end

    if self:IsSeated() then
        pcall(function() hum.Sit = false end)
        pcall(function() hum.Jump = true end)
        task.wait(0.5)
    end

    if self:IsSeated() then
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        task.wait(0.5)
    end

    local maxRetries = 3
    local retry = 0
    while self:IsSeated() and retry < maxRetries do
        retry = retry + 1
        pcall(function() hum.Sit = false end)
        pcall(function() hum.Jump = true end)
        task.wait(0.5)
    end

    return not self:IsSeated()
end

function Vehicle:Enter(vehicle) return self:EnterByPrompt(vehicle) end
function Vehicle:Exit() return self:ExitByPrompt() end

-- ====================== MOVEMENT SYSTEM ======================
local Movement = {}
Movement.Mode        = "Tween"
Movement.Speed       = 200
Movement.ArrivalDist = 5
Movement.ActiveTween = nil

function Movement:Cancel()
    if self.ActiveTween then
        pcall(function() self.ActiveTween:Cancel() end)
        self.ActiveTween = nil
    end
end

function Movement:GoTo(targetCFrame, options)
    options = options or {}
    local character = LocalPlayer.Character
    if not character then return false end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local vehicle = Vehicle:GetSeatedVehicle()
    local subject = vehicle or character
    local subjectRoot = vehicle and (vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart", true)) or root
    if not subjectRoot then return false end

    self:Cancel()

    if self.Mode == "Teleport" then
        return self:Teleport(subject, targetCFrame)
    elseif self.Mode == "Tween" then
        return self:Tween(subject, subjectRoot, targetCFrame, options.timeout or 30)
    end
    return false
end

function Movement:Teleport(subject, targetCFrame)
    local ok = Utils:SafeCall(function() subject:PivotTo(targetCFrame) end)
    task.wait(0.2)
    return ok
end

function Movement:Tween(subject, subjectRoot, targetCFrame, timeout)
    local startPos = subjectRoot.Position
    local dist     = (targetCFrame.Position - startPos).Magnitude
    if dist < self.ArrivalDist then return true end

    local duration = math.max(0.3, dist / math.max(1, self.Speed))

    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    local tweenComplete = false
    self.ActiveTween = TweenService:Create(subjectRoot, tweenInfo, {
        CFrame = targetCFrame
    })

    self.ActiveTween:Play()
    self.ActiveTween.Completed:Once(function() tweenComplete = true end)

    local startTick = tick()
    while not tweenComplete and (tick() - startTick) < (timeout or 30) do
        task.wait(0.1)
    end

    self.ActiveTween = nil
    if not tweenComplete then
        pcall(function() subject:PivotTo(targetCFrame) end)
    end

    local currentSubjectRoot = subject:FindFirstChildWhichIsA("BasePart", true)
    if currentSubjectRoot and (currentSubjectRoot.Position - targetCFrame.Position).Magnitude < (self.ArrivalDist * 2) then
        return true
    end
    return tweenComplete
end

-- ====================== VERSION CHECK ======================
local FreeVersion    = "Free Version"
local PremiumVersion = "Premium Version"

local function checkVersion(playerName)
    local url = "https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua"
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then return FreeVersion end
    local func, err = loadstring(response)
    if not func then return FreeVersion end
    local ok, premiumData = pcall(func)
    if not ok then return FreeVersion end
    return premiumData and premiumData[playerName] and PremiumVersion or FreeVersion
end

local userversion = checkVersion(LocalPlayer.Name)
local isPremium   = (userversion == PremiumVersion)

-- ====================== RE-EXECUTION SAFETY ======================
local activeConnections = {}
local function registerConnection(connection)
    table.insert(activeConnections, connection)
    return connection
end

-- Live runtime state
local AutoAcceptOffers = false
local MinAcceptPercent = 15
local AutoPlaceEnabled = false
local AutoBid          = false
local MinBid           = 5
local MaxBid           = 1000
local AutoCollect      = false
local AutoCollectNoTP  = false

local AutoSellEnabled  = false
local MinSellRate      = -15
local MinWeight        = 20
local SaveTrophies     = true
local SaveAccessories  = true
local CurrentWeight    = 0
local CurrentRate      = 1.0
local SellCooldown     = 0
local SellSyncing      = false

local PathfinderEnabled = false
local PathfinderPhase   = "Idle"
local PathfinderStatus  = "Waiting for activation"
local PathfinderRunning = false
local PathfinderStopping = false
local State_itemsAvailable = false

local FarmMode          = "Full Weight"
local farmTargetArea    = "Junk Yard"

local ItemsCollectedCount = 0
local ItemsPlacedCount    = 0

local AREA_GARAGES = {
    ["Junk Yard"]  = { "Scrap Garage" },
    ["Back Alley"] = { "Shop Front" },
    ["Farmyard"]   = { "Stable Garage", "Barn Garage" },
    ["Shipyard"]   = { "Small Container Garage", "Large Container Garage", "Warehouse Garage" },
    ["Jurassic"]   = { "Jurassic Stable Garage" },
    ["Cargo Ship"] = { "Steel Cargo Container", "Cargo Container", "Luxury Cargo Container", "Wooden Cargo Container" },
}

local ItemsModule = (function()
    local ok, result = pcall(function() return require(ReplicatedStorage.Modules.Items) end)
    if ok then return result end
    return {}
end)()

local ignoredAuctionUnits = {}
local currentAuctionUnit  = nil

-- Remotes
local PlaceStockItem                  = nil
local GetPlayerInventory              = nil
local TransferVehicleItemsToInventory = nil
local BidEvent                        = nil
local GetShopStock                    = nil
local GetPawnState                    = nil
local GetSellableItems                = nil
local SellItems                       = nil
local RateChanged                     = nil
local VehicleWeightUpdate             = nil
local AuctionPickupStart              = nil
local AuctionPickupEnd                = nil
local LeaveAuctionRemote              = nil
local RequestSpawnRemote              = nil

if getgenv().DYHUB_SH_Cleanup then
    pcall(getgenv().DYHUB_SH_Cleanup)
end

-- ====================== WINDOW ======================
local Window = WindUI:CreateWindow({
    Title      = "DYHUB",
    IconThemed = true,
    Icon       = "rbxassetid://104487529937663",
    Author     = "Storage Hunter | " .. userversion,
    Folder     = "DYHUB_SH",
    Size       = UDim2.fromOffset(580, 440),
    Transparent = true,
    Theme      = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar    = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

getgenv().DYHUB_SH_Window = Window

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
local ConfigFolder = "DYHUB_SH"
local CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self = setmetatable({}, CustomConfig)
    self.ConfigData = {}
    self.ConfigPath = ConfigFolder .. "/config_sh.json"
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
    Utils:SafeCall(function()
        writefile(self.ConfigPath, HttpService:JSONEncode(self.ConfigData))
    end)
end

function CustomConfig:Load()
    if isfile(self.ConfigPath) then
        local ok, result = pcall(function() return HttpService:JSONDecode(readfile(self.ConfigPath)) end)
        if ok and type(result) == "table" then
            self.ConfigData = result
            print("[DYHUB] Config loaded!")
        else
            self.ConfigData = {}
        end
    else
        self.ConfigData = {}
    end
end

function CustomConfig:AutoSave(interval)
    if self._autoSaveThread then
        task.cancel(self._autoSaveThread)
        self._autoSaveThread = nil
    end
    if interval and interval > 0 then
        self._autoSaveDelay = interval
        self._autoSaveThread = task.spawn(function()
            while true do
                task.wait(self._autoSaveDelay)
                self:Save()
            end
        end)
    end
end

local Config = CustomConfig.new()

-- ====================== SETTINGS TABLE ======================
local settings = {
    AutoAcceptOffers  = Config:Get("AutoAcceptOffers", false),
    MinAcceptPercent  = Config:Get("MinAcceptPercent", 15),
    AutoPlaceEnabled  = Config:Get("AutoPlaceEnabled", false),
    InstantPrompt     = Config:Get("InstantPrompt", false),
    autoCleanEnabled  = Config:Get("autoCleanEnabled", false),
    washSlot          = Config:Get("washSlot", {}),
    AutoBid           = Config:Get("AutoBid", false),
    MinBid            = Config:Get("MinBid", 5),
    MaxBid            = Config:Get("MaxBid", 1000),
    AutoCollect       = Config:Get("AutoCollect", false),
    AutoCollectNoTP   = Config:Get("AutoCollectNoTP", false),
    AutoSaveEnabled   = Config:Get("AutoSaveEnabled", true),
    AutoSaveDelay     = Config:Get("AutoSaveDelay", 15),
    selectedZone      = Config:Get("selectedZone", "Junk Yard"),
    selectedLocation  = Config:Get("selectedLocation", "Mall"),
    MovementTypes     = Config:Get("MovementTypes", { "WalkSpeed" }),
    MovementEnabled   = Config:Get("MovementEnabled", false),
    Noclip            = Config:Get("Noclip", false),
    InfiniteJump      = Config:Get("InfiniteJump", false),
    WalkSpeedValue    = Config:Get("WalkSpeedValue", 16),
    JumpPowerValue    = Config:Get("JumpPowerValue", 50),
    AutoSellEnabled   = Config:Get("AutoSellEnabled", false),
    MinSellRate       = Config:Get("MinSellRate", -15),
    MinWeight         = Config:Get("MinWeight", 20),
    SaveTrophies      = Config:Get("SaveTrophies", true),
    SaveAccessories   = Config:Get("SaveAccessories", true),
    PathfinderEnabled = Config:Get("PathfinderEnabled", false),
    FarmMovementMode  = Config:Get("FarmMovementMode", "Tween"),
    MovementSpeed     = Config:Get("MovementSpeed", 200),
    FarmMode          = Config:Get("FarmMode", "Full Weight"),
}

-- Sync loaded config
local InstantPrompt  = settings.InstantPrompt
AutoAcceptOffers     = settings.AutoAcceptOffers
MinAcceptPercent     = settings.MinAcceptPercent
AutoPlaceEnabled     = settings.AutoPlaceEnabled
AutoBid              = settings.AutoBid
MinBid               = settings.MinBid
MaxBid               = settings.MaxBid
AutoCollect          = settings.AutoCollect
AutoCollectNoTP      = settings.AutoCollectNoTP
AutoSellEnabled      = settings.AutoSellEnabled
MinSellRate          = settings.MinSellRate
MinWeight            = settings.MinWeight
SaveTrophies         = settings.SaveTrophies
SaveAccessories      = settings.SaveAccessories
FarmMode             = settings.FarmMode
farmTargetArea       = settings.selectedZone or "Junk Yard"
Movement.Mode        = settings.FarmMovementMode
Movement.Speed       = settings.MovementSpeed

if settings.AutoSaveEnabled then
    Config:AutoSave(settings.AutoSaveDelay)
end

getgenv().DYHUB_SH_Cleanup = function()
    AutoAcceptOffers = false
    AutoPlaceEnabled = false
    AutoBid          = false
    AutoCollect      = false
    AutoCollectNoTP  = false
    AutoSellEnabled  = false
    PathfinderEnabled = false
    PathfinderStopping = true
    PathfinderRunning = false
    Movement:Cancel()
    for _, conn in ipairs(activeConnections) do
        if conn and conn.Connected then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(activeConnections)
    pcall(function()
        local w = getgenv().DYHUB_SH_Window
        if w then w:Destroy() end
    end)
end

-- ====================== TABS ======================
local InfoTab       = Window:Tab({ Title = "Information", Icon = "info" })
local _D1           = Window:Divider()
local AuctionTab    = Window:Tab({ Title = "Main",        Icon = "rocket" })
local PlayerTab     = Window:Tab({ Title = "Player",      Icon = "user" })
local CollectTab    = Window:Tab({ Title = "Collect",     Icon = "package" })
local PathfinderTab = Window:Tab({ Title = "Automatic",   Icon = "tractor" })
local TeleportTab   = Window:Tab({ Title = "Teleport",    Icon = "map-pin" })
local _D2           = Window:Divider()
local SettingsTab   = Window:Tab({ Title = "Settings",    Icon = "settings" })

Window:SelectTab(1)

-- ====================== HELPER FUNCTIONS ======================
local function getMyPlot()
    local plots = Workspace:FindFirstChild("_Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:GetAttribute('OwnerUserId') == LocalPlayer.UserId then return plot end
        end
    end
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:GetAttribute('OwnerUserId') == LocalPlayer.UserId and not obj:FindFirstChildWhichIsA("VehicleSeat", true) then
            return obj
        end
    end
    return nil
end

local function findUnpackZone()
    local zone = Workspace:FindFirstChild("UnpackZone") or Workspace:FindFirstChild("Unpack Zone")
    if zone then return zone end
    local plot = getMyPlot()
    if plot then
        zone = plot:FindFirstChild("UnpackZone") or plot:FindFirstChild("Unpack Zone")
              or plot:FindFirstChild("UnpackZone", true) or plot:FindFirstChild("Unpack Zone", true)
        if zone then return zone end
    end
    for _, desc in ipairs(Workspace:GetDescendants()) do
        local name = desc.Name:lower()
        if name:find("unpack") and name:find("zone") then return desc end
    end
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name:lower():find("unpack") then return desc end
    end
    return nil
end

local function teleportTo(destinationCFrame)
    local vehicle = Vehicle:GetSeatedVehicle()
    if vehicle then
        local root = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart", true)
        if root then
            local wasAnchored = root.Anchored
            root.Anchored = true
            pcall(function() vehicle:PivotTo(destinationCFrame) end)
            task.spawn(function()
                task.wait(0.15)
                root.Anchored = wasAnchored
            end)
        else
            pcall(function() vehicle:PivotTo(destinationCFrame) end)
        end
        return
    end
    local character = LocalPlayer.Character
    if character then
        pcall(function() character:PivotTo(destinationCFrame) end)
    end
end

local function getVehicleItems(vehicle)
    local uids, seen = {}, {}
    local function addUid(uid)
        if Utils:IsGUID(uid) and not seen[uid] then
            seen[uid] = true
            table.insert(uids, uid)
        end
    end
    if vehicle then
        for _, desc in ipairs(vehicle:GetDescendants()) do
            addUid(desc.Name)
            if desc:IsA("StringValue") then addUid(desc.Value) end
            for _, v in pairs(desc:GetAttributes()) do
                if type(v) == "string" then addUid(v) end
            end
        end
    end
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        for _, desc in ipairs(playerGui:GetDescendants()) do
            addUid(desc.Name)
            if desc:IsA("StringValue") then addUid(desc.Value) end
            for _, v in pairs(desc:GetAttributes()) do
                if type(v) == "string" then addUid(v) end
            end
        end
    end
    return uids
end

local function findPromptsNear(centerPos, radius, promptName)
    local results = {}
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Name == promptName then
            local parentPart = desc.Parent
            if parentPart and parentPart:IsA("BasePart") then
                local dist = (parentPart.Position - centerPos).Magnitude
                if dist <= radius then
                    table.insert(results, { prompt = desc, part = parentPart, position = parentPart.Position, distance = dist })
                end
            end
        end
    end
    table.sort(results, function(a, b) return a.distance < b.distance end)
    return results
end

local function triggerPrompt(prompt)
    pcall(function() fireproximityprompt(prompt) end)
    task.wait(0.1)
end

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

-- Forward declarations
local startAutoPlaceLoop
local startAutoSellLoop
local setPathfinderEnabled

-- ====================== PLAYER TAB ======================
local movementTypes   = settings.MovementTypes or { "WalkSpeed" }
if type(movementTypes) ~= "table" then movementTypes = { "WalkSpeed" } end
local movementEnabled = settings.MovementEnabled or false
local noclipEnabled   = settings.Noclip or false
local infJumpEnabled  = settings.InfiniteJump or false
local walkSpeedValue  = settings.WalkSpeedValue or 16
local jumpPowerValue  = settings.JumpPowerValue or 50

local function getHumanoid() local c = LocalPlayer.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function getCharacter() return LocalPlayer.Character end
PlayerTab:Divider()
PlayerTab:Section({ Title = "Movement", Icon = "person-standing" })

PlayerTab:Dropdown({
    Title  = "Movement Type",
    Desc   = "Select movement types to apply",
    Values = { "WalkSpeed", "JumpPower" },
    Multi  = true,
    Value  = movementTypes,
    Callback = function(v)
        if type(v) == "table" then
            movementTypes = v
        else
            movementTypes = { v }
        end
        settings.MovementTypes = movementTypes
        Config:Set("MovementTypes", movementTypes); Config:Save()
        Utils:Notify("Movement", "Selected: " .. table.concat(movementTypes, ", "), "settings", 2)
    end
})

PlayerTab:Slider({
    Title = "WalkSpeed Value",
    Desc  = "Set your WalkSpeed value",
    Value = { Min = 0, Max = 500, Default = walkSpeedValue },
    Step  = 1,
    Callback = function(v)
        walkSpeedValue = v
        settings.WalkSpeedValue = v
        Config:Set("WalkSpeedValue", v); Config:Save()
    end
})

PlayerTab:Slider({
    Title = "JumpPower Value",
    Desc  = "Set your JumpPower value",
    Value = { Min = 0, Max = 500, Default = jumpPowerValue },
    Step  = 1,
    Callback = function(v)
        jumpPowerValue = v
        settings.JumpPowerValue = v
        Config:Set("JumpPowerValue", v); Config:Save()
    end
})

PlayerTab:Toggle({
    Title = "Enable Movement",
    Desc  = "Apply movement values continuously",
    Value = movementEnabled,
    Callback = function(v)
        movementEnabled = v
        settings.MovementEnabled = v
        Config:Set("MovementEnabled", v); Config:Save()
    end
})
PlayerTab:Divider()
PlayerTab:Section({ Title = "Physical", Icon = "flame" })

PlayerTab:Toggle({
    Title = "Noclip",
    Desc  = "Pass through walls and obstacles",
    Value = noclipEnabled,
    Callback = function(v)
        noclipEnabled = v
        settings.Noclip = v
        Config:Set("Noclip", v); Config:Save()
    end
})

PlayerTab:Toggle({
    Title = "Infinite Jump",
    Desc  = "Jump without limits",
    Value = infJumpEnabled,
    Callback = function(v)
        infJumpEnabled = v
        settings.InfiniteJump = v
        Config:Set("InfiniteJump", v); Config:Save()
    end
})

RunService.Heartbeat:Connect(function()
    if not movementEnabled then return end
    local hum = getHumanoid()
    if not hum then return end

    local hasWalkSpeed = false
    local hasJumpPower = false
    for _, t in ipairs(movementTypes) do
        if t == "WalkSpeed" then hasWalkSpeed = true end
        if t == "JumpPower"  then hasJumpPower  = true end
    end

    if hasWalkSpeed then
        if hum.WalkSpeed ~= walkSpeedValue then hum.WalkSpeed = walkSpeedValue end
    end

    if hasJumpPower then
        hum.UseJumpPower = true
        if hum.JumpPower ~= jumpPowerValue then hum.JumpPower = jumpPowerValue end
    end
end)

RunService.Stepped:Connect(function()
    if not noclipEnabled then return end
    local char = getCharacter()
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not infJumpEnabled then return end
    local hum = getHumanoid()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ====================== AUCTION TAB (MAIN) ======================
AuctionTab:Divider()

local PromptCache = {}
local PromptConns = {}

local function ApplyPrompt(prompt)
    if not PromptCache[prompt] then PromptCache[prompt] = prompt.HoldDuration end
    if prompt.HoldDuration ~= 0 then prompt.HoldDuration = 0 end
end

local function RestorePrompts()
    for prompt, duration in pairs(PromptCache) do
        if prompt and prompt.Parent then prompt.HoldDuration = duration end
    end
    table.clear(PromptCache)
end

AuctionTab:Section({ Title = "Auction Prompt", Icon = "cpu" })

local function setInstantPrompt(state, notify)
    InstantPrompt = state
    settings.InstantPrompt = state
    Config:Set("InstantPrompt", state); Config:Save()
    if notify then
        Utils:Notify("Instant Prompt", state and "Enabled" or "Disabled", state and "cpu" or "ban", 2)
    end
    if state then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then ApplyPrompt(v) end
        end
        if PromptConns.Added then PromptConns.Added:Disconnect() end
        PromptConns.Added = Workspace.DescendantAdded:Connect(function(v)
            if v:IsA("ProximityPrompt") then ApplyPrompt(v) end
        end)
        task.spawn(function()
            while InstantPrompt do
                for prompt in pairs(PromptCache) do
                    if prompt and prompt.Parent and prompt.HoldDuration ~= 0 then
                        prompt.HoldDuration = 0
                    end
                end
                task.wait(0.5)
            end
        end)
    else
        if PromptConns.Added then PromptConns.Added:Disconnect(); PromptConns.Added = nil end
        RestorePrompts()
    end
end

AuctionTab:Toggle({
    Title = "Instant Prompt",
    Desc  = "Remove prompt hold delay",
    Value = InstantPrompt,
    Callback = function(state) setInstantPrompt(state, true) end
})

if InstantPrompt then task.defer(function() setInstantPrompt(true, false) end) end
AuctionTab:Divider()
AuctionTab:Section({ Title = "Auction Bidding", Icon = "gavel" })

AuctionTab:Toggle({
    Title    = "Auto Bid",
    Desc     = "Auto bid on active auctions",
    Value    = AutoBid,
    Callback = function(state)
        AutoBid = state
        settings.AutoBid = state
        Config:Set("AutoBid", state); Config:Save()
    end
})

AuctionTab:Input({
    Title       = "Min Starting Bid",
    Value       = tostring(MinBid),
    Placeholder = "Enter minimum bid",
    Callback    = function(text)
        local num = tonumber(text)
        MinBid = num or 5
        settings.MinBid = MinBid
        Config:Set("MinBid", MinBid); Config:Save()
    end
})

AuctionTab:Input({
    Title       = "Max Bid",
    Value       = tostring(MaxBid),
    Placeholder = "Enter maximum bid",
    Callback    = function(text)
        local num = tonumber(text)
        MaxBid = num or 1000
        settings.MaxBid = MaxBid
        Config:Set("MaxBid", MaxBid); Config:Save()
    end
})

AuctionTab:Paragraph({
    Title = "How it works",
    Desc  = "Auctions starting below Min Bid are skipped. Bids increase by 50 each round, capped at Max Bid.",
})

AuctionTab:Button({
    Title = "Leave Auction",
    Desc  = "Exit the current auction",
    Callback = function()
        if LeaveAuctionRemote then
            local ok = pcall(function() Utils:SafeCallRemote(LeaveAuctionRemote) end)
            Utils:Notify("Leave Auction", ok and "Left!" or "Failed to leave.", ok and "log-out" or "alert-triangle", 2)
        else
            Utils:Notify("Leave Auction", "Remote not ready yet.", "alert-triangle", 3)
        end
    end
})

-- ====================== COLLECT TAB ======================
CollectTab:Divider()
CollectTab:Section({ Title = "Offers & Plot", Icon = "tag" })

CollectTab:Toggle({
    Title    = "Auto Accept Offers",
    Desc     = "Auto accept NPC shopper offers",
    Value    = AutoAcceptOffers,
    Callback = function(state)
        AutoAcceptOffers = state
        settings.AutoAcceptOffers = state
        Config:Set("AutoAcceptOffers", state); Config:Save()
    end
})

CollectTab:Input({
    Title       = "Min Accept (%)",
    Value       = tostring(MinAcceptPercent),
    Placeholder = "15",
    Callback    = function(text)
        local num = tonumber(text)
        if num then
            MinAcceptPercent = num
            settings.MinAcceptPercent = num
            Config:Set("MinAcceptPercent", num); Config:Save()
        end
    end
})

CollectTab:Toggle({
    Title    = "Auto Place Items",
    Desc     = "Auto place items on your plot",
    Value    = AutoPlaceEnabled,
    Callback = function(state)
        AutoPlaceEnabled = state
        settings.AutoPlaceEnabled = state
        Config:Set("AutoPlaceEnabled", state); Config:Save()
        if state then startAutoPlaceLoop() end
    end
})

CollectTab:Divider()
CollectTab:Section({ Title = "Clean Dirty", Icon = "package" })

local StartWash   = game:GetService("ReplicatedStorage").Events.Wash.StartWash
local CollectWash = game:GetService("ReplicatedStorage").Events.Wash.CollectWash

local washSlot = settings.washSlot
if type(washSlot) ~= "table" then washSlot = {} end
local autoCleanEnabled = settings.autoCleanEnabled or false
local autoCleanGen     = 0

CollectTab:Dropdown({
    Title    = "Wash Slots",
    Values   = { "1", "2", "3" },
    Multi    = true,
    Value    = washSlot,
    Callback = function(v)
        washSlot = v
        settings.washSlot = v
        Config:Set("washSlot", v); Config:Save()
    end
})

local function getSelectedWashSlots()
    local list = {}
    for _, v in pairs(washSlot) do
        local n = tonumber(v)
        if n then table.insert(list, n) end
    end
    table.sort(list)
    return list
end

local function getCollectBtn(slot)
    local ok, btn = pcall(function()
        local uiControllerGui = PlayerGui:WaitForChild("UIControllerGui", 5)
        local washShopPanel   = uiControllerGui:WaitForChild("WashShopPanel", 5)
        local slotsContainer  = washShopPanel:WaitForChild("SlotsContainer", 5)
        local slotFrame       = slotsContainer:WaitForChild("Slot" .. tostring(slot), 5)
        local content         = slotFrame:WaitForChild("Content", 5)
        return content:WaitForChild("CollectBtn", 5)
    end)
    if ok then return btn end
    return nil
end

local function waitForCollectReady(slot, myGen, timeout)
    timeout = timeout or 20
    local btn = getCollectBtn(slot)
    if not btn then return false end
    local start = os.clock()
    while (os.clock() - start) < timeout do
        if not (autoCleanEnabled and autoCleanGen == myGen) then return false end
        local ok, visible = pcall(function() return btn.Visible end)
        if ok and visible then return true end
        task.wait(0.25)
    end
    return false
end

local function doAutoCleanCycle(myGen, silent)
    local vehicle  = Vehicle:GetMyVehicle()
    local itemUids = getVehicleItems(vehicle)
    if #itemUids == 0 then return false end
    local slots = getSelectedWashSlots()
    if #slots == 0 then
        if not silent then Utils:Notify("Auto Clean", "Please select at least one slot.", "alert-triangle", 3) end
        return false
    end
    for _, slot in ipairs(slots) do
        if not (autoCleanEnabled and autoCleanGen == myGen) then break end
        local success, moved = Utils:SafeCallRemote(StartWash, 1, itemUids, "Vehicle", "STARTER-DUSTER")
        if success and moved then
            local ready = waitForCollectReady(slot, myGen, 20)
            if ready then
                Utils:SafeCallRemote(CollectWash, slot)
                if not silent then Utils:Notify("Auto Clean", "Slot " .. slot .. " collected!", "check", 2) end
            end
        end
        task.wait(0.3)
    end
    return true
end

CollectTab:Toggle({
    Title    = "Auto Clean Item (Dirty)",
    Desc     = "Auto clean dirty items in a loop",
    Value    = autoCleanEnabled,
    Callback = function(v)
        autoCleanEnabled = v
        settings.autoCleanEnabled = v
        Config:Set("autoCleanEnabled", v); Config:Save()
        autoCleanGen = autoCleanGen + 1
        local myGen = autoCleanGen
        if v then
            task.spawn(function()
                while autoCleanEnabled and autoCleanGen == myGen do
                    doAutoCleanCycle(myGen, true)
                    task.wait(2)
                end
            end)
        end
    end
})

CollectTab:Button({
    Title = "Clean Item",
    Desc  = "Send dirty items to washer",
    Callback = function()
        local vehicle = Vehicle:GetMyVehicle()
        local itemUids = getVehicleItems(vehicle)
        if #itemUids > 0 then
            local success = Utils:SafeCallRemote(StartWash, 1, itemUids, "Vehicle", "STARTER-DUSTER")
            if success then
                Utils:Notify("Clean Item", "Clean command sent!", "truck", 2)
            else
                Utils:Notify("Clean Item", "Failed to Clean Item.", "alert-triangle", 3)
            end
        else
            Utils:Notify("Clean Item", "No items detected in the vehicle.", "alert-triertriangle", 3)
        end
    end
})

CollectTab:Divider()
CollectTab:Section({ Title = "Truck Utilities", Icon = "truck" })

CollectTab:Button({
    Title = "Unload Truck",
    Desc  = "Transfer all items to inventory",
    Callback = function()
        local vehicle = Vehicle:GetMyVehicle()
        if TransferVehicleItemsToInventory then
            local itemUids = getVehicleItems(vehicle)
            if #itemUids > 0 then
                local success = Utils:SafeCallRemote(TransferVehicleItemsToInventory, itemUids)
                if success then
                    Utils:Notify("Unload Truck", "Unload command sent!", "truck", 2)
                else
                    Utils:Notify("Unload Truck", "Failed to unload.", "alert-triangle", 3)
                end
            else
                Utils:Notify("Unload Truck", "No items detected in the vehicle.", "alert-triangle", 3)
            end
        else
            Utils:Notify("Unload Truck", "Remote not ready yet, try again shortly.", "alert-triangle", 3)
        end
    end
})

CollectTab:Paragraph({
    Title = "Important",
    Desc  = "You must be seated in the truck to unload items.",
})

CollectTab:Divider()
CollectTab:Section({ Title = "Collect", Icon = "move" })

CollectTab:Toggle({
    Title    = "Auto Collect",
    Desc     = "Teleport and collect nearby items",
    Value    = AutoCollect,
    Callback = function(state)
        AutoCollect = state
        settings.AutoCollect = state
        Config:Set("AutoCollect", state); Config:Save()
        if state and AutoCollectNoTP then
            AutoCollectNoTP = false
            settings.AutoCollectNoTP = false
            Config:Set("AutoCollectNoTP", false); Config:Save()
        end
    end
})

CollectTab:Toggle({
    Title    = "Auto Collect (No TP)",
    Desc     = "Collect items without teleporting",
    Value    = AutoCollectNoTP,
    Callback = function(state)
        AutoCollectNoTP = state
        settings.AutoCollectNoTP = state
        Config:Set("AutoCollectNoTP", state); Config:Save()
        if state and AutoCollect then
            AutoCollect = false
            settings.AutoCollect = false
            Config:Set("AutoCollect", false); Config:Save()
        end
    end
})

-- ====================== AUTO SELL TAB ======================
AuctionTab:Divider()
AuctionTab:Section({ Title = "Sell Option", Icon = "dollar-sign" })

AuctionTab:Toggle({
    Title    = "Auto Sell",
    Desc     = "Auto sell when rate and weight conditions are met",
    Value    = AutoSellEnabled,
    Callback = function(state)
        AutoSellEnabled = state
        settings.AutoSellEnabled = state
        Config:Set("AutoSellEnabled", state); Config:Save()
        if state then startAutoSellLoop() end
    end
})

AuctionTab:Slider({
    Title = "Min Sell Rate (%)",
    Desc  = "Minimum rate to sell (negative allowed)",
    Value = { Min = -100, Max = 10000, Default = MinSellRate },
    Step  = 1,
    Callback = function(value)
        MinSellRate = value
        settings.MinSellRate = value
        Config:Set("MinSellRate", value); Config:Save()
    end
})

AuctionTab:Slider({
    Title = "Min Load Weight (kg)",
    Desc  = "Minimum weight before selling",
    Value = { Min = 0, Max = 1000, Default = MinWeight },
    Step  = 1,
    Callback = function(value)
        MinWeight = value
        settings.MinWeight = value
        Config:Set("MinWeight", value); Config:Save()
    end
})

AuctionTab:Toggle({
    Title    = "Save Trophies",
    Desc     = "Keep Trophy category items",
    Value    = SaveTrophies,
    Callback = function(state)
        SaveTrophies = state
        settings.SaveTrophies = state
        Config:Set("SaveTrophies", state); Config:Save()
    end
})

AuctionTab:Toggle({
    Title    = "Save Accessories",
    Desc     = "Keep Accessory category items",
    Value    = SaveAccessories,
    Callback = function(state)
        SaveAccessories = state
        settings.SaveAccessories = state
        Config:Set("SaveAccessories", state); Config:Save()
    end
})

AuctionTab:Divider()
AuctionTab:Section({ Title = "Auto Sell Live Status", Icon = "activity" })

local RateLabel       = AuctionTab:Paragraph({ Title = "Current Rate",   Desc = "Waiting for data..." })
local WeightLabel     = AuctionTab:Paragraph({ Title = "Vehicle Load",   Desc = "Waiting for data..." })
local SellStatusLabel = AuctionTab:Paragraph({ Title = "Status",         Desc = "Inactive" })

AuctionTab:Button({
    Title = "Refresh Rate Now",
    Desc  = "Force refresh current rate",
    Callback = function()
        task.spawn(function()
            if GetPawnState then
                local ok, state = pcall(function() return GetPawnState:InvokeServer() end)
                if ok and type(state) == "table" and state.rate then
                    CurrentRate = state.rate
                    Utils:Notify("Rate Refreshed", "Done!", "refresh-cw", 2)
                else
                    Utils:Notify("Refresh Failed", "Pawn remote not ready.", "alert-triangle", 3)
                end
            else
                Utils:Notify("Refresh Failed", "Pawn remote not ready.", "alert-triangle", 3)
            end
        end)
    end
})

-- ====================== PATHFINDER TAB ======================
PathfinderTab:Divider()
PathfinderTab:Section({ Title = "Farm Option", Icon = "cpu" })

PathfinderTab:Toggle({
    Title    = "Auto Farm",
    Desc     = "Run full auto farm cycle",
    Value    = PathfinderEnabled,
    Callback = function(state)
        setPathfinderEnabled(state)
        settings.PathfinderEnabled = state
        Config:Set("PathfinderEnabled", state); Config:Save()
        Utils:Notify("Pathfinder", state and "Enabled" or "Disabled", state and "navigation" or "ban", 2)
    end
})

PathfinderTab:Divider()

PathfinderTab:Section({ Title = "Farm Mode", Icon = "layers" })

PathfinderTab:Dropdown({
    Title  = "Farm Mode",
    Desc   = "Choose how to collect items",
    Values = { "Full Weight", "Garage All" },
    Multi  = false,
    Value  = FarmMode,
    Callback = function(v)
        if type(v) == "table" then v = v[1] end
        FarmMode = v
        settings.FarmMode = v
        Config:Set("FarmMode", v); Config:Save()
        Utils:Notify("Farm Mode", "Set to: " .. v, "layers", 2)
    end
})

PathfinderTab:Paragraph({
    Title = "How Farm Modes Work",
    Desc  = [[Full Weight: Keep bidding and collecting until vehicle weight is full, then return to base.

Garage All: Collect everything in the current garage, then return to base.

If weight fills up during collection, the bot will unload and come back to finish collecting.]],
})

PathfinderTab:Divider()
PathfinderTab:Section({ Title = "Target Area (Auto Farm)", Icon = "map-pin" })

PathfinderTab:Dropdown({
    Title  = "Target Area for Farm",
    Desc   = "Select an Area for Farming",
    Values = { "Junk Yard", "Back Alley", "Farm Yard", "Shipyard", "Jurassic", "Cargo Ship" },
    Multi  = false,
    Value  = farmTargetArea,
    Callback = function(v)
        if type(v) == "table" then v = v[1] end
        farmTargetArea = v
        settings.selectedZone = v
        Config:Set("selectedZone", v); Config:Save()
        Utils:Notify("Target Area", "Set to: " .. v, "map-pin", 2)
    end
})

PathfinderTab:Paragraph({
    Title = "How it works",
    Desc  = "Select one area above. The bot will park the car, walk to bid in the same area, then loop.",
})

PathfinderTab:Divider()
PathfinderTab:Section({ Title = "Movement Farm", Icon = "footprints" })

PathfinderTab:Dropdown({
    Title  = "Movement Type for Farm",
    Desc   = "Tween is smooth, Teleport is instant",
    Values = { "Tween", "Teleport" },
    Multi  = false,
    Value  = settings.FarmMovementMode or "Tween",
    Callback = function(v)
        if type(v) == "table" then v = v[1] end
        Movement.Mode = v
        settings.FarmMovementMode = v
        Config:Set("FarmMovementMode", v); Config:Save()
        Utils:Notify("Farm Movement", "Set to: " .. v, "footprints", 2)
    end
})

PathfinderTab:Slider({
    Title = "Movement Speed (studs/s)",
    Desc  = "Tween movement speed",
    Value = { Min = 50, Max = 500, Default = settings.MovementSpeed or 200 },
    Step  = 10,
    Callback = function(v)
        Movement.Speed = v
        settings.MovementSpeed = v
        Config:Set("MovementSpeed", v); Config:Save()
    end
})

PathfinderTab:Divider()
PathfinderTab:Section({ Title = "Status", Icon = "activity" })

local PhaseLabel         = PathfinderTab:Paragraph({ Title = "Phase",     Desc = "Idle" })
local StatusLabel        = PathfinderTab:Paragraph({ Title = "State",     Desc = "Waiting for activation..." })
local WeightStatusLabel  = PathfinderTab:Paragraph({ Title = "Weight",    Desc = "Waiting for data..." })
local ItemsLabel         = PathfinderTab:Paragraph({ Title = "Items",     Desc = "Collected: 0 | Placed: 0" })

-- ✅ FIXED: Real-time weight display using WeightTracker
RunService.Heartbeat:Connect(function()
    if not PhaseLabel or not StatusLabel then return end
    pcall(function() PhaseLabel:SetDesc("Phase: " .. tostring(PathfinderPhase)) end)
    pcall(function() StatusLabel:SetDesc("State: " .. tostring(PathfinderStatus)) end)
    pcall(function() ItemsLabel:SetDesc(string.format("Collected: %d | Placed: %d", ItemsCollectedCount, ItemsPlacedCount)) end)
    pcall(function()
        local currW, maxW = WeightTracker:Read(false)
        WeightStatusLabel:SetDesc(string.format("%d / %d kg", currW, maxW))
    end)
end)

-- ====================== TELEPORT TAB ======================
TeleportTab:Divider()
TeleportTab:Section({ Title = "Base Teleport", Icon = "house" })

TeleportTab:Button({
    Title = "TP to Base",
    Desc  = "Teleport to your base",
    Callback = function()
        local unpackZone = findUnpackZone()
        local pivot = unpackZone and Utils:GetSafePivot(unpackZone)
        if pivot then
            teleportTo(pivot + Vector3.new(0, 5, 0))
        else
            Utils:Notify("TP to Base", "Unpack Zone not found. Make sure your truck has at least 1 item.", "triangle-alert", 3)
        end
    end
})

TeleportTab:Paragraph({
    Title = "Tips",
    Desc  = "If seated in the truck, it teleports with you.",
})
TeleportTab:Divider()
TeleportTab:Button({
    Title = "TP to Plot",
    Desc  = "Teleport directly to your plot",
    Callback = function()
        local plot = getMyPlot()
        local pivot = plot and Utils:GetSafePivot(plot)
        if pivot then
            teleportTo(pivot + Vector3.new(0, 5, 0))
        else
            Utils:Notify("TP to Base", "Your plot could not be found.", "alert-triangle", 3)
        end
    end
})

TeleportTab:Divider()
TeleportTab:Section({ Title = "Zones", Icon = "map" })

local zoneList = {
    ["Junk Yard"] = function()
        local areas = Workspace:FindFirstChild("Areas")
        local zone = areas and areas:FindFirstChild("Junk Yard")
        return zone and zone:FindFirstChild("CentrePiece", true)
    end,
    ["Back Alley"] = function()
        local areas = Workspace:FindFirstChild("Areas")
        local zone = areas and areas:FindFirstChild("Back Alley")
        return zone and zone:FindFirstChild("Back Alley Road", true)
    end,
    ["Farm Yard"] = function()
        local areas = Workspace:FindFirstChild("Areas")
        local zone = areas and areas:FindFirstChild("Farmyard")
        return zone and zone:FindFirstChild("Lost and Found Box", true)
    end,
    ["Shipyard"] = function()
        local areas = Workspace:FindFirstChild("Areas")
        local zone = areas and areas:FindFirstChild("Shipyard")
        return zone and zone:FindFirstChild("Lost and Found Box", true)
    end,
    ["Jurassic"] = function()
        local areas = Workspace:FindFirstChild("Areas")
        local zone = areas and areas:FindFirstChild("Jurassic")
        return zone and zone:FindFirstChild("AreaBoundary", true)
    end,
    ["Cargo Ship"] = function()
        local areas = Workspace:FindFirstChild("CargoShip")
        if areas then
            return areas:FindFirstChild("AreaBoundary", true) or areas
        end
        return Workspace:FindFirstChild("CargoShip", true)
    end,
}

local selectedZone = settings.selectedZone or "Junk Yard"

TeleportTab:Dropdown({
    Title  = "Select Zone",
    Desc   = "Choose a zone to teleport to",
    Values = { "Junk Yard", "Back Alley", "Farm Yard", "Shipyard", "Jurassic", "Cargo Ship" },
    Multi  = false,
    Value  = selectedZone,
    Callback = function(v)
        selectedZone = v
        farmTargetArea = v
        settings.selectedZone = v
        Config:Set("selectedZone", v); Config:Save()
    end
})

local function getZoneCarParkPosition()
    local finder = zoneList[selectedZone]
    if not finder then return nil end
    local part  = finder()
    local pivot = part and Utils:GetSafePivot(part)
    if pivot then
        return pivot + Vector3.new(0, 3, 0)
    end
    return nil
end

TeleportTab:Button({
    Title = "TP to Zone",
    Desc  = "Teleport to selected zone",
    Callback = function()
        local pos = getZoneCarParkPosition()
        if pos then
            teleportTo(pos)
        else
            Utils:Notify("Teleport", "Location not found.", "alert-triangle", 3)
        end
    end
})

TeleportTab:Divider()
TeleportTab:Section({ Title = "Shops", Icon = "shopping-cart" })

local tpLocations = {
    ["Car Shop"]      = Vector3.new(-240, 1725, -181),
    ["Grading"]       = Vector3.new(339,  1725, -280),
    ["Item Clearing"] = Vector3.new(406,  1725, -275),
    ["Repair Shop"]   = Vector3.new(425,  1725,  -77),
    ["Mall"]          = Vector3.new(363,  1725,  -58),
}

local selectedLocation = settings.selectedLocation or "Mall"

TeleportTab:Dropdown({
    Title  = "Select Location",
    Desc   = "Choose a shop location",
    Values = { "Car Shop", "Grading", "Item Clearing", "Repair Shop", "Mall" },
    Multi  = false,
    Value  = selectedLocation,
    Callback = function(v)
        selectedLocation = v
        settings.selectedLocation = v
        Config:Set("selectedLocation", v); Config:Save()
    end
})

TeleportTab:Button({
    Title = "TP to Location",
    Desc  = "Teleport to selected location",
    Callback = function()
        local pos = tpLocations[selectedLocation]
        if pos then
            teleportTo(CFrame.new(pos + Vector3.new(0, 5, 0)))
        else
            Utils:Notify("Teleport", "No location selected.", "alert-triangle", 3)
        end
    end
})

-- ====================== INFORMATION TAB ======================
local Info = InfoTab
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

Info:Section({ Title = "Latest Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({
    Title = "Update: 07/17/2026 | CL: " .. ver,
    Desc  = [[• [ FIX ] Weight display now updates in real-time during collect
• [ NEW ] WeightTracker system with caching and fallback
• [ FIX ] Bot now reliably detects weight full and returns to base
• [ FIX ] Garage All mode - collects everything then returns to base
• [ FIX ] Auto unload & return to garage when weight fills up mid-collect
• [ FIX ] All descriptions improved for clarity]],
})
Info:Divider()

do
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
        return HttpService:JSONDecode(ui.Creator.Request({ Url = DiscordAPI, Method = "GET", Headers = { ["User-Agent"] = "RobloxBot/1.0", ["Accept"] = "application/json" } }).Body)
    end)
    if success and result and result.guild then
        local DiscordInfo = Info:Paragraph({
            Title = result.guild.name,
            Desc  = ' <font color="#52525b">●</font> Member Count : ' .. tostring(result.approximate_member_count) ..
                    '\n <font color="#16a34a">●</font> Online Count : '  .. tostring(result.approximate_presence_count),
            Image = "https://cdn.discordapp.com/icons/" .. result.guild.id .. "/" .. result.guild.icon .. ".png?size=1024",
            ImageSize = 42,
        })
        Info:Button({ Title = "Update Info", Callback = function()
            local ok, r = pcall(function() return HttpService:JSONDecode(ui.Creator.Request({ Url = DiscordAPI, Method = "GET" }).Body) end)
            if ok and r and r.guild then
                DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : ' .. tostring(r.approximate_member_count) .. '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(r.approximate_presence_count))
                Utils:Notify("Discord Info Updated", "Refreshed!", "refresh-cw", 2)
            else
                Utils:Notify("Update Failed", "Could not refresh.", "alert-triangle", 3)
            end
        end })
        Info:Button({ Title = "Copy Discord Invite", Callback = function()
            setclipboard("https://discord.gg/" .. InviteCode)
            Utils:Notify("Copied!", "Discord invite copied!", "clipboard-check", 2)
        end })
    else
        Info:Paragraph({ Title = "Error fetching Discord Info", Desc = "Unable to load.", Image = "triangle-alert", ImageSize = 26, Color = "Red" })
    end
end
LoadDiscordInfo()

Info:Divider()
Info:Section({ Title = "DYHUB Information", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({ Title = "Main Owner", Desc = "@dyumraisgoodguy#8888", Image = "rbxassetid://119789418015420", ImageSize = 30 })
Info:Paragraph({ Title = "Social", Desc = "Copy link social media for follow!", Image = "rbxassetid://104487529937663", ImageSize = 30,
    Buttons = {{ Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://guns.lol/DYHUB") end }} })
Info:Paragraph({ Title = "Discord", Desc = "Join our discord for more scripts!", Image = "rbxassetid://104487529937663", ImageSize = 30,
    Buttons = {{ Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://discord.gg/jWNDPNMmyB") end }} })
end

-- ====================== SETTINGS TAB ======================
do
SettingsTab:Divider()
SettingsTab:Section({ Title = "Save Config", Icon = "save" })
SettingsTab:Button({ Title = "Save Config (NOW)", Desc = "Save all settings now", Callback = function()
    Config:Save()
    Utils:Notify("Config Saved", "Config saved successfully!", "save", 2)
end })

local AutoSaveEnabled = settings.AutoSaveEnabled
local AutoSaveDelay   = settings.AutoSaveDelay

SettingsTab:Toggle({ Title = "Auto Save Config", Desc = "Auto save at set interval", Value = AutoSaveEnabled, Callback = function(state)
    AutoSaveEnabled = state; settings.AutoSaveEnabled = state; Config:Set("AutoSaveEnabled", state); Config:Save()
    if state then Config:AutoSave(AutoSaveDelay) else Config:AutoSave(0) end
end })

SettingsTab:Input({ Title = "Delay Save Config", Value = tostring(AutoSaveDelay), Placeholder = "Default: 15 seconds", Callback = function(text)
    local num = tonumber(text)
    if num and num >= 1 then
        AutoSaveDelay = num; settings.AutoSaveDelay = num; Config:Set("AutoSaveDelay", num); Config:Save()
        if AutoSaveEnabled then Config:AutoSave(num) end
    else warn("[DYHUB] Invalid delay value!") end
end })

SettingsTab:Divider()
SettingsTab:Section({ Title = "Server Status", Icon = "server" })

SettingsTab:Button({ Title = "Serverhop", Desc = "Join a different server", Callback = function()
    local servers = {}
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    end)
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then table.insert(servers, server.id) end
        end
    end
    if #servers > 0 then
        Utils:Notify("Serverhop", "Teleporting...", "server", 2); task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    else
        Utils:Notify("Serverhop Failed", "No available servers.", "alert-triangle", 3)
    end
end })

SettingsTab:Button({ Title = "Rejoin", Desc = "Rejoin current server", Callback = function()
    Utils:Notify("Rejoin", "Rejoining...", "refresh-cw", 2); task.wait(1)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end })
end

-- ====================== BACKGROUND INITIALIZATION ======================
task.spawn(function()
    local Events = ReplicatedStorage:WaitForChild('Events')

    task.spawn(function()
        pcall(function()
            require(ReplicatedStorage.Modules.Items)
            require(ReplicatedStorage.Modules.MutatorModule)
            require(ReplicatedStorage.Modules.GameConfig)
        end)
    end)

    -- Auto-Accept Offers hook
    task.spawn(function()
        local NPCShopper = Events:WaitForChild('NPCShopper')
        if NPCShopper then
            local RespondOffer = NPCShopper:WaitForChild('RespondOffer')
            local ShowOffer    = NPCShopper:WaitForChild('ShowOffer')
            if ShowOffer and RespondOffer then
                registerConnection(ShowOffer.OnClientEvent:Connect(function(...)
                    if not AutoAcceptOffers then return end
                    local args = {...}
                    local offerId = args[1]
                    if not offerId then return end
                    local function getParsedPercent(tbl)
                        for i = 2, #tbl do
                            local v = tbl[i]
                            if type(v) == "string" and v:find("%%") then
                                local cleanStr = v:gsub("[^%d%.%-]", "")
                                local num = tonumber(cleanStr)
                                if num then return num end
                            end
                        end
                        local offerPrice = tonumber(tbl[4])
                        local basePrice  = tonumber(tbl[5])
                        if offerPrice and basePrice and basePrice > 0 then
                            local computed = ((offerPrice - basePrice) / basePrice) * 100
                            if computed >= -100 and computed <= 500 then return math.round(computed) end
                        end
                        for i = 5, #tbl do
                            local v = tbl[i]
                            local num = tonumber(v)
                            if num and num > 0 and num < 1 then return num * 100 end
                        end
                        for i = 5, #tbl do
                            local v = tbl[i]
                            local num = tonumber(v)
                            if num and num >= -100 and num <= 100 then return num end
                        end
                        return 0
                    end
                    local percent = getParsedPercent(args)
                    if percent >= MinAcceptPercent then
                        Utils:SafeCallRemote(RespondOffer, offerId, true)
                    else
                        Utils:SafeCallRemote(RespondOffer, offerId, false)
                    end
                end))
                Utils:Log("Auto Accept Offer hooked successfully.")
            end
        end
    end)

    task.spawn(function()
        local PlotEvents = Events:WaitForChild('Plot')
        if PlotEvents then
            PlaceStockItem = PlotEvents:WaitForChild('PlaceStockItem')
            GetShopStock   = PlotEvents:FindFirstChild('GetShopStock') or PlotEvents:WaitForChild('GetShopStock')
        end
    end)

    task.spawn(function()
        local InventoryEvents = Events:WaitForChild('Inventory')
        if InventoryEvents then
            GetPlayerInventory = InventoryEvents:WaitForChild('GetPlayerInventory')
        end
    end)

    task.spawn(function()
        local VehicleEvents = Events:WaitForChild('Vehicles')
        if VehicleEvents then
            TransferVehicleItemsToInventory = VehicleEvents:WaitForChild('TransferVehicleItemsToInventory')
            pcall(function()
                RequestSpawnRemote = VehicleEvents:FindFirstChild('RequestSpawn') or VehicleEvents:WaitForChild('RequestSpawn', 5)
            end)
        end
    end)

    task.spawn(function()
        local Pawn = Events:WaitForChild('Pawn')
        if Pawn then
            GetPawnState     = Pawn:WaitForChild('GetPawnState')
            GetSellableItems = Pawn:WaitForChild('GetSellableItems')
            SellItems        = Pawn:WaitForChild('SellItems')
            RateChanged      = Pawn:WaitForChild('RateChanged')
            registerConnection(RateChanged.OnClientEvent:Connect(function(data)
                if type(data) == "table" and data.rate then CurrentRate = data.rate end
            end))
        end
    end)

    task.spawn(function()
        local UIEvents = Events:WaitForChild('UI')
        if UIEvents then
            VehicleWeightUpdate = UIEvents:WaitForChild('VehicleWeightUpdate')
            registerConnection(VehicleWeightUpdate.OnClientEvent:Connect(function(currentKg, maxKg)
                CurrentWeight = tonumber(currentKg) or 0
            end))
        end
    end)

    task.spawn(function()
        local AuctionEvents = Events:WaitForChild('Auction')
        if AuctionEvents then
            BidEvent                = AuctionEvents:WaitForChild('Bid')
            local UpdateCurrentWinningBid = AuctionEvents:WaitForChild('UpdateCurrentWinningBid')
            local LeaveAuction      = AuctionEvents:FindFirstChild('LeaveAuction') or AuctionEvents:WaitForChild('LeaveAuction')
            LeaveAuctionRemote      = LeaveAuction
            AuctionPickupStart      = AuctionEvents:WaitForChild('AuctionPickupStart')
            AuctionPickupEnd        = AuctionEvents:WaitForChild('AuctionPickupEnd')

            registerConnection(AuctionPickupStart.OnClientEvent:Connect(function(bidAmount, totalValue)
                State_itemsAvailable = true
            end))
            registerConnection(AuctionPickupEnd.OnClientEvent:Connect(function()
                State_itemsAvailable = false
            end))

            if UpdateCurrentWinningBid and BidEvent then
                registerConnection(UpdateCurrentWinningBid.OnClientEvent:Connect(function(currentBid, winningPlayer, storageUnit, timeLeft)
                    if not AutoBid then return end
                    local currentBidNum = tonumber(currentBid)
                    if not currentBidNum then return end
                    if storageUnit and storageUnit ~= currentAuctionUnit then
                        currentAuctionUnit = storageUnit
                        if currentBidNum < MinBid then
                            ignoredAuctionUnits[storageUnit] = true
                            if LeaveAuction then
                                task.spawn(function() Utils:SafeCallRemote(LeaveAuction) end)
                            end
                        else
                            ignoredAuctionUnits[storageUnit] = false
                        end
                    end
                    if storageUnit and ignoredAuctionUnits[storageUnit] then return end
                    local isWinning = false
                    if typeof(winningPlayer) == "Instance" and winningPlayer:IsA("Player") then
                        isWinning = (winningPlayer == LocalPlayer)
                    elseif type(winningPlayer) == "string" then
                        isWinning = (winningPlayer == LocalPlayer.Name)
                    elseif type(winningPlayer) == "number" then
                        isWinning = (winningPlayer == LocalPlayer.UserId)
                    end
                    if isWinning then return end
                    local nextBid = currentBidNum + 50
                    if nextBid <= MaxBid then
                        if storageUnit then
                            Utils:SafeCallRemote(BidEvent, storageUnit, nextBid)
                        else
                            Utils:SafeCallRemote(BidEvent, nextBid)
                        end
                    end
                end))
            end
        end
    end)

    Utils:Log("Background initialization complete.")
end)

-- ====================== AUTO PLACE LOOP ======================
local function getLocalInventory()
    local invFolders = {
        LocalPlayer.Character,
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer:FindFirstChild("Inventory"),
        LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Inventory")
    }
    for _, folder in ipairs(invFolders) do
        if folder then
            local list = {}
            for _, child in ipairs(folder:GetChildren()) do
                list[child.Name] = { Id = child.Name, Name = child.Name, UID = child:GetAttribute("UID") or child.Name }
            end
            return list
        end
    end
    return nil
end

startAutoPlaceLoop = function()
    task.spawn(function()
        while AutoPlaceEnabled do
            local plot = getMyPlot()
            if not plot then task.wait(2); continue end

            local success, inventory
            if GetPlayerInventory then
                success, inventory = pcall(function()
                    if GetPlayerInventory:IsA("RemoteFunction") then
                        return GetPlayerInventory:InvokeServer()
                    end
                end)
            end
            if not success or type(inventory) ~= "table" then
                inventory = getLocalInventory()
            end

            if inventory and type(inventory) == "table" then
                local occupiedPoints = {}
                if GetShopStock then
                    local ok2, stock = pcall(function() return GetShopStock:InvokeServer(plot) end)
                    if ok2 and type(stock) == "table" then
                        for _, itemGroup in ipairs(stock) do
                            if type(itemGroup) == "table" then
                                for _, placedItem in ipairs(itemGroup) do
                                    if type(placedItem) == "table" and placedItem.Attrs then
                                        local sGUID = placedItem.Attrs.ShelfGUID or placedItem.Attrs.shelfGUID
                                        local sName = placedItem.Attrs.SnapPointName or placedItem.Attrs.snapPointName
                                        if sGUID and sName then occupiedPoints[sGUID .. "_" .. sName] = true end
                                    end
                                end
                            end
                        end
                    end
                end

                local itemsToPlace = {}
                for itemUID, itemData in pairs(inventory) do
                    local itemId = nil
                    if type(itemData) == "table" then
                        itemId = itemData.ItemId or itemData.itemId or itemData.Id or itemData.id
                    else
                        itemId = itemData
                    end
                    if itemUID and itemId then table.insert(itemsToPlace, { uid = itemUID, id = itemId }) end
                end

                local emptySnapPoints = {}
                if GetShopStock and plot then
                    for _, desc in ipairs(plot:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") then
                            local promptName = desc.Name:lower()
                            local actionText = desc.ActionText:lower()
                            if promptName:find("additem") or actionText:find("add item") then
                                local snapPoint = desc.Parent
                                if snapPoint and (snapPoint:IsA("BasePart") or snapPoint:IsA("Attachment")) then
                                    local current  = snapPoint
                                    local shelfGUID = nil
                                    while current and current ~= plot do
                                        shelfGUID = current:GetAttribute("GUID")
                                        if shelfGUID then break end
                                        current = current.Parent
                                    end
                                    if shelfGUID then
                                        local key = shelfGUID .. "_" .. snapPoint.Name
                                        if not occupiedPoints[key] then
                                            local worldCFrame = snapPoint:IsA("Attachment") and snapPoint.WorldCFrame or snapPoint.CFrame
                                            table.insert(emptySnapPoints, { prompt = desc, snapPoint = snapPoint, worldCFrame = worldCFrame, shelfGUID = shelfGUID, name = snapPoint.Name })
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                local placedThisCycle = 0

                if GetShopStock and #itemsToPlace > 0 and #emptySnapPoints > 0 then
                    for _, snapPointInfo in ipairs(emptySnapPoints) do
                        if not AutoPlaceEnabled then break end
                        if #itemsToPlace == 0 then break end
                        local item = table.remove(itemsToPlace, 1)
                        if PlaceStockItem then
                            Utils:SafeCall(function()
                                if PlaceStockItem:IsA("RemoteEvent") then
                                    PlaceStockItem:FireServer(item.uid, tostring(item.id), snapPointInfo.worldCFrame, 0, snapPointInfo.shelfGUID, snapPointInfo.name)
                                elseif PlaceStockItem:IsA("RemoteFunction") then
                                    PlaceStockItem:InvokeServer(item.uid, tostring(item.id), snapPointInfo.worldCFrame, 0, snapPointInfo.shelfGUID, snapPointInfo.name)
                                end
                            end)
                            placedThisCycle = placedThisCycle + 1
                            task.wait(0.5)
                        end
                    end
                else
                    for itemId, itemData in pairs(inventory) do
                        if not AutoPlaceEnabled then break end
                        local idToSend
                        if type(itemData) == "table" then
                            idToSend = itemData.UID or itemData.uid or itemData.UUID or itemData.uuid or itemData.Id or itemData.id or itemData.ItemId or itemData.itemId or itemId
                        else
                            idToSend = itemData
                        end
                        if idToSend and PlaceStockItem then
                            Utils:SafeCall(function()
                                if PlaceStockItem:IsA("RemoteEvent") then
                                    PlaceStockItem:FireServer(plot, idToSend)
                                elseif PlaceStockItem:IsA("RemoteFunction") then
                                    PlaceStockItem:InvokeServer(plot, idToSend)
                                end
                            end)
                            placedThisCycle = placedThisCycle + 1
                            task.wait(0.5)
                        end
                    end
                end

                ItemsPlacedCount = ItemsPlacedCount + placedThisCycle
            end
            task.wait(2)
        end
    end)
end

-- ====================== AUTO SELL LOOP ======================
startAutoSellLoop = function()
    task.spawn(function()
        while AutoSellEnabled do
            if SellSyncing then
                task.wait(1)
            elseif tick() < SellCooldown then
                task.wait(1)
            else
                local pct = math.floor((CurrentRate - 1) * 100 + 0.5)
                if pct < MinSellRate then
                    task.wait(2)
                elseif CurrentWeight < MinWeight then
                    task.wait(2)
                else
                    SellSyncing = true
                    if GetSellableItems and SellItems then
                        local success, items = pcall(function() return GetSellableItems:InvokeServer() end)
                        if success and type(items) == "table" then
                            local toSell = {}
                            for guid, info in pairs(items) do
                                if not info.Favorited then
                                    local itemDef = ItemsModule[info.ItemId]
                                    local skip = false
                                    if itemDef then
                                        if SaveTrophies     and itemDef.Category == "Trophy"      then skip = true end
                                        if SaveAccessories  and itemDef.Category == "Accessories" then skip = true end
                                    end
                                    if not skip then table.insert(toSell, guid) end
                                end
                            end
                            if #toSell > 0 then
                                local sellSuccess = pcall(function() return SellItems:InvokeServer(toSell) end)
                                if sellSuccess then
                                    SellCooldown = tick() + 15
                                    Utils:Notify("Auto Sell", "Sold " .. #toSell .. " item(s)!", "dollar-sign", 2)
                                end
                            end
                        end
                    end
                    SellSyncing = false
                    task.wait(2)
                end
            end
        end
    end)
end

-- ====================== PATHFINDER LOOP (FIXED - REAL-TIME WEIGHT) ======================
local function pathfinderLoop()
    local function setState(phase, status)
        PathfinderPhase = phase
        PathfinderStatus = status
    end

    local function checkEnabled()
        return PathfinderEnabled and not PathfinderStopping
    end

    local function findAuctionInArea(areaName)
        local root = getRoot()
        if not root then return nil end
        local rootPos = root.Position
        local bestDist = math.huge
        local bestPrompt = nil

        local targetGarages = AREA_GARAGES[areaName]
        if not targetGarages then return nil end

        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Name == "EnterAuction" then
                local garageType = prompt.ObjectText
                local isInArea = false
                for _, g in ipairs(targetGarages) do
                    if g == garageType then
                        isInArea = true
                        break
                    end
                end
                if isInArea then
                    local promptParent = prompt.Parent
                    if promptParent then
                        local dist = (promptParent.Position - rootPos).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestPrompt = {
                                prompt = prompt,
                                promptParent = promptParent,
                                position = promptParent.Position,
                                garageType = garageType,
                                areaName = areaName,
                                distance = dist,
                            }
                        end
                    end
                end
            end
        end
        return bestPrompt
    end

    -- ✅ Helper: Unload trunk reliably
    local function unloadTrunkReliably(maxAttempts)
        maxAttempts = maxAttempts or 3
        for attempt = 1, maxAttempts do
            if not checkEnabled() then return false end
            if not Vehicle:IsSeated() then
                local veh = Vehicle:GetMyVehicle()
                if veh then
                    Vehicle:EnterByPrompt(veh)
                    task.wait(1)
                end
            end
            if Vehicle:IsSeated() and TransferVehicleItemsToInventory then
                local veh = Vehicle:GetSeatedVehicle()
                local itemUids = getVehicleItems(veh)
                if #itemUids > 0 then
                    setState("Unloading", string.format("Unloading %d items (attempt %d)", #itemUids, attempt))
                    local ok = Utils:SafeCallRemote(TransferVehicleItemsToInventory, itemUids)
                    if ok then
                        task.wait(2)
                        local newItems = getVehicleItems(veh)
                        if #newItems == 0 or #newItems < #itemUids then
                            -- Force reset weight tracker after unload
                            WeightTracker:Reset()
                            WeightTracker:Read(true)
                            return true
                        end
                    end
                else
                    WeightTracker:Reset()
                    WeightTracker:Read(true)
                    return true
                end
            end
            task.wait(0.5)
        end
        return false
    end

    while PathfinderEnabled and not PathfinderStopping do
        local targetArea = farmTargetArea

        if selectedZone ~= targetArea then
            selectedZone = targetArea
        end

        -- ========== STEP 1: Find auction ==========
        setState("Finding Auction", "Searching " .. targetArea .. " for auctions...")
        local target = findAuctionInArea(targetArea)

        if not target then
            setState("Idle", "No auctions in " .. targetArea .. ", waiting 5s...")
            local waitStart = tick()
            while tick() - waitStart < 5 and checkEnabled() do task.wait(0.5) end
        else
            -- ========== STEP 2: Spawn car ==========
            setState("Spawning Car", "Requesting STARTER-DUSTER...")
            local myVehicle, isSeated = Vehicle:GetMyVehicle()
            local needSpawn = false

            if not myVehicle then
                needSpawn = true
            elseif not isSeated then
                needSpawn = true
            end

            if needSpawn then
                if RequestSpawnRemote then
                    Utils:SafeCallRemote(RequestSpawnRemote, "STARTER-DUSTER")
                    task.wait(2)
                    local waitStart = tick()
                    while tick() - waitStart < 15 and checkEnabled() do
                        task.wait(0.5)
                        myVehicle, isSeated = Vehicle:GetMyVehicle()
                        if myVehicle and isSeated then break end
                    end
                end
            end

            if not checkEnabled() then break end

            -- ========== STEP 3: Move car to Zone ==========
            setState("Moving to Zone", "Parking car at " .. targetArea .. "...")
            local parkPos = getZoneCarParkPosition()
            if parkPos and checkEnabled() then
                Movement:GoTo(parkPos, { timeout = 60 })
                task.wait(1)
            end

            if not checkEnabled() then break end

            -- ========== STEP 4: Exit car ==========
            if Vehicle:IsSeated() then
                setState("Exiting Car", "Exiting vehicle...")
                Vehicle:ExitByPrompt()
                task.wait(1.5)
            end

            if not checkEnabled() then break end

            -- ========== STEP 5: Walk to bid ==========
            setState("Walking to Bid", "Walking to " .. target.garageType)
            local arrived = Movement:GoTo(CFrame.new(target.position + Vector3.new(0, 3, 0)), { timeout = 60 })
            if not arrived and checkEnabled() then
                setState("Walking to Bid", "Failed to reach, retrying...")
                task.wait(3)
            elseif checkEnabled() then
                -- ========== STEP 6: Trigger auction + bid ==========
                setState("Triggering Auction", "Starting auction...")
                triggerPrompt(target.prompt)
                task.wait(1)

                local gui       = LocalPlayer.PlayerGui:FindFirstChild("UIControllerGui")
                local container = gui and gui:FindFirstChild("AuctionBiddingContainer")
                if not (container and container.Visible) then
                    triggerPrompt(target.prompt)
                    task.wait(1)
                end

                setState("Waiting for Bidding", "Auction in progress, bidding...")
                State_itemsAvailable = false

                local biddingEndTime = tick()
                local inAuction = true

                while inAuction and checkEnabled() do
                    task.wait(0.5)
                    gui       = LocalPlayer.PlayerGui:FindFirstChild("UIControllerGui")
                    container = gui and gui:FindFirstChild("AuctionBiddingContainer")
                    if not (container and container.Visible) then
                        if State_itemsAvailable then
                            inAuction = false
                        else
                            if tick() - biddingEndTime > 8 then inAuction = false end
                        end
                    else
                        biddingEndTime = tick()
                    end
                    if tick() - biddingEndTime > 180 then
                        inAuction = false
                    end
                end

                if State_itemsAvailable and checkEnabled() then
                    -- ========== STEP 7: Collect items (REAL-TIME WEIGHT CHECK) ==========
                    setState("Collecting Items", "Auction won! Collecting items...")

                    -- ✅ Reset weight tracker for new collect session
                    WeightTracker:Reset()
                    WeightTracker:Read(true)

                    local function findGarageModel()
                        for _, model in ipairs(Workspace:GetChildren()) do
                            if model.Name == target.garageType or model.Name:find(target.garageType) then
                                return model
                            end
                        end
                        return nil
                    end

                    local garageModel = findGarageModel()
                    local garagePos   = garageModel and garageModel:GetPivot().Position or target.position

                    local totalCollected = 0
                    local collectComplete = false

                    -- ✅ Collect loop with real-time weight check
                    while not collectComplete and checkEnabled() do
                        local blacklist = {}
                        local collectedThisCycle = 0
                        local garageLoopStart = tick()
                        local garageCleared = false
                        local weightFullHit = false

                        local function isBlacklisted(key)
                            return blacklist[key] and blacklist[key].attempts >= 3
                        end
                        local function recordAttempt(key)
                            blacklist[key] = blacklist[key] or { attempts = 0 }
                            blacklist[key].attempts = blacklist[key].attempts + 1
                        end

                        while not garageCleared and not weightFullHit and checkEnabled() do
                            if tick() - garageLoopStart > 30 then
                                setState("Collecting Items", "Garage timeout")
                                break
                            end

                            -- Collect boxes
                            local boxes = findPromptsNear(garagePos, 100, "OpenBoxPrompt")
                            for i, box in ipairs(boxes) do
                                if not checkEnabled() or weightFullHit then break end
                                local key = tostring(box.prompt)
                                if not isBlacklisted(key) then
                                    setState("Collecting Items", string.format("Opening box %d/%d", i, #boxes))
                                    local arrived = Movement:GoTo(CFrame.new(box.position + Vector3.new(0, 3, 0)), { timeout = 15 })
                                    if arrived then
                                        triggerPrompt(box.prompt)
                                        collectedThisCycle = collectedThisCycle + 1
                                        WeightTracker:AddItem()
                                        -- ✅ Real-time weight check after collect
                                        task.wait(0.3)
                                        if WeightTracker:IsFull() then
                                            weightFullHit = true
                                            setState("Collecting Items", string.format("Weight full! (%d/%d kg)", WeightTracker.current, WeightTracker.max))
                                            break
                                        end
                                        task.wait(0.2)
                                    else
                                        recordAttempt(key)
                                    end
                                end
                            end

                            if weightFullHit then break end

                            -- Collect pickups
                            local pickups = findPromptsNear(target.position, 80, "PickupPrompt")
                            if #pickups == 0 and garageModel then
                                pickups = findPromptsNear(garagePos, 100, "PickupPrompt")
                            end
                            if #pickups == 0 then
                                for _, desc in ipairs(Workspace:GetDescendants()) do
                                    if desc:IsA("ProximityPrompt") and desc.Name == "PickupPrompt" then
                                        local parent = desc.Parent
                                        if parent and parent:IsA("BasePart") then
                                            table.insert(pickups, { prompt = desc, part = parent, position = parent.Position, distance = 0 })
                                        end
                                    end
                                end
                                table.sort(pickups, function(a, b) return a.distance < b.distance end)
                            end

                            for i, pickup in ipairs(pickups) do
                                if not checkEnabled() or weightFullHit then break end
                                local key = tostring(pickup.prompt)
                                if not isBlacklisted(key) then
                                    setState("Collecting Items", string.format("Collecting item %d/%d", i, #pickups))
                                    local arrived = Movement:GoTo(CFrame.new(pickup.position + Vector3.new(0, 3, 0)), { timeout = 15 })
                                    if arrived then
                                        triggerPrompt(pickup.prompt)
                                        collectedThisCycle = collectedThisCycle + 1
                                        WeightTracker:AddItem()
                                        -- ✅ Real-time weight check after collect
                                        task.wait(0.3)
                                        if WeightTracker:IsFull() then
                                            weightFullHit = true
                                            setState("Collecting Items", string.format("Weight full! (%d/%d kg)", WeightTracker.current, WeightTracker.max))
                                            break
                                        end
                                        task.wait(0.2)
                                    else
                                        recordAttempt(key)
                                    end
                                end
                            end

                            task.wait(0.3)
                            local remainingBoxes = findPromptsNear(garagePos, 100, "OpenBoxPrompt")
                            local remainingItems = findPromptsNear(garagePos, 100, "PickupPrompt")
                            if #remainingBoxes == 0 and #remainingItems == 0 then
                                garageCleared = true
                            end
                            task.wait(0.5)
                        end

                        totalCollected = totalCollected + collectedThisCycle
                        ItemsCollectedCount = ItemsCollectedCount + collectedThisCycle

                        -- If weight was full mid-collect, unload and come back
                        if weightFullHit and checkEnabled() then
                            setState("Unloading", "Weight full! Returning to unload...")

                            -- Return to zone parking
                            if selectedZone ~= targetArea then selectedZone = targetArea end
                            local returnPos = getZoneCarParkPosition()
                            if returnPos then
                                Movement:GoTo(returnPos, { timeout = 60 })
                                task.wait(1)
                            end

                            if not checkEnabled() then break end

                            -- Enter vehicle + unload
                            myVehicle, isSeated = Vehicle:GetMyVehicle()
                            if not myVehicle then
                                if RequestSpawnRemote then
                                    Utils:SafeCallRemote(RequestSpawnRemote, "STARTER-DUSTER")
                                    task.wait(2)
                                    local waitStart = tick()
                                    while tick() - waitStart < 10 and checkEnabled() do
                                        task.wait(0.5)
                                        myVehicle, isSeated = Vehicle:GetMyVehicle()
                                        if myVehicle and isSeated then break end
                                    end
                                end
                            end

                            if myVehicle and checkEnabled() then
                                local entered = false
                                for attempt = 1, 3 do
                                    if not checkEnabled() then break end
                                    entered = Vehicle:EnterByPrompt(myVehicle)
                                    if entered then break end
                                    task.wait(1)
                                end

                                if entered then
                                    task.wait(0.5)
                                    unloadTrunkReliably(3)
                                    task.wait(1)
                                    -- Exit vehicle
                                    setState("Exiting Vehicle", "Exiting vehicle...")
                                    for attempt = 1, 3 do
                                        if not Vehicle:IsSeated() then break end
                                        Vehicle:ExitByPrompt()
                                        task.wait(0.8)
                                    end

                                    -- Go back to garage to finish collecting
                                    setState("Returning to Garage", "Going back to collect remaining...")
                                    Movement:GoTo(CFrame.new(target.position + Vector3.new(0, 3, 0)), { timeout = 60 })
                                    task.wait(1)
                                else
                                    setState("Unloading", "Failed to enter vehicle, skipping")
                                    collectComplete = true
                                end
                            else
                                setState("Unloading", "No vehicle available, skipping")
                                collectComplete = true
                            end
                        else
                            -- Garage is cleared (no more items)
                            collectComplete = true
                        end
                    end

                    setState("Collecting Items", string.format("Collected %d items total", totalCollected))

                    if not checkEnabled() then break end

                    -- ✅ Determine if we should return to base
                    local shouldReturnToBase = true
                    local weightFullNow = WeightTracker:IsFull()

                    if FarmMode == "Full Weight" and not weightFullNow then
                        -- Weight not full, find more auctions
                        shouldReturnToBase = false
                        setState("Finding More", string.format("Weight: %d/%d kg, finding more auctions", WeightTracker.current, WeightTracker.max))
                    elseif weightFullNow then
                        setState("Weight Full", string.format("Weight: %d/%d kg, returning to base", WeightTracker.current, WeightTracker.max))
                    end

                    if shouldReturnToBase then
                        -- ========== STEP 8: Return to Zone ==========
                        setState("Returning to Zone", "Going back to " .. targetArea .. "...")
                        if selectedZone ~= targetArea then selectedZone = targetArea end
                        local returnPos = getZoneCarParkPosition()
                        if returnPos then
                            Movement:GoTo(returnPos, { timeout = 60 })
                            task.wait(1)
                        end

                        if not checkEnabled() then break end

                        -- ========== STEP 9: Enter vehicle + Unload ==========
                        setState("Entering Vehicle", "Entering vehicle...")
                        myVehicle, isSeated = Vehicle:GetMyVehicle()

                        if not myVehicle then
                            if RequestSpawnRemote then
                                Utils:SafeCallRemote(RequestSpawnRemote, "STARTER-DUSTER")
                                task.wait(2)
                                local waitStart = tick()
                                while tick() - waitStart < 10 and checkEnabled() do
                                    task.wait(0.5)
                                    myVehicle, isSeated = Vehicle:GetMyVehicle()
                                    if myVehicle and isSeated then break end
                                end
                            end
                        end

                        if myVehicle and checkEnabled() then
                            local entered = false
                            for attempt = 1, 3 do
                                if not checkEnabled() then break end
                                entered = Vehicle:EnterByPrompt(myVehicle)
                                if entered then break end
                                setState("Entering Vehicle", string.format("Attempt %d/3 failed", attempt))
                                task.wait(1)
                            end

                            if entered then
                                task.wait(0.5)
                                unloadTrunkReliably(3)
                                task.wait(1)
                                setState("Exiting Vehicle", "Exiting vehicle...")
                                for attempt = 1, 3 do
                                    if not Vehicle:IsSeated() then break end
                                    Vehicle:ExitByPrompt()
                                    task.wait(0.8)
                                end
                            end
                        end

                        if not checkEnabled() then break end

                        -- ========== STEP 10: Walk to base ==========
                        setState("Walking to Base", "Returning to base...")
                        local plot = getMyPlot()
                        if plot then
                            local plotPivot = Utils:GetSafePivot(plot)
                            if plotPivot then
                                Movement:GoTo(plotPivot + Vector3.new(0, 5, 0), { timeout = 60 })
                                task.wait(0.5)
                            end
                        end

                        local unpackZone = findUnpackZone()
                        if unpackZone then
                            local unp = Utils:GetSafePivot(unpackZone)
                            if unp then
                                Movement:GoTo(unp + Vector3.new(0, 5, 0), { timeout = 30 })
                                task.wait(0.5)
                            end
                        end

                        if not checkEnabled() then break end

                        -- ========== STEP 11: Place all items ==========
                        setState("Placing Items", "Placing items at base...")
                        while checkEnabled() do
                            plot = getMyPlot()
                            if not (plot and PlaceStockItem) then break end

                            local success, inventory = false, nil
                            if GetPlayerInventory then
                                success, inventory = pcall(function()
                                    if GetPlayerInventory:IsA("RemoteFunction") then
                                        return GetPlayerInventory:InvokeServer()
                                    end
                                end)
                            end
                            if not success or type(inventory) ~= "table" then
                                inventory = getLocalInventory()
                            end

                            if not inventory or type(inventory) ~= "table" then break end

                            local itemCount = 0
                            for _ in pairs(inventory) do itemCount = itemCount + 1 end
                            if itemCount == 0 then break end

                            local emptySnapPoints = {}
                            for _, desc in ipairs(plot:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    local promptName = desc.Name:lower()
                                    local actionText = desc.ActionText:lower()
                                    if promptName:find("additem") or actionText:find("add item") then
                                        local snapPoint = desc.Parent
                                        if snapPoint and (snapPoint:IsA("BasePart") or snapPoint:IsA("Attachment")) then
                                            local current = snapPoint
                                            local shelfGUID = nil
                                            while current and current ~= plot do
                                                shelfGUID = current:GetAttribute("GUID")
                                                if shelfGUID then break end
                                                current = current.Parent
                                            end
                                            if shelfGUID then
                                                local worldCFrame = snapPoint:IsA("Attachment") and snapPoint.WorldCFrame or snapPoint.CFrame
                                                table.insert(emptySnapPoints, { worldCFrame = worldCFrame, shelfGUID = shelfGUID, name = snapPoint.Name })
                                            end
                                        end
                                    end
                                end
                            end

                            if #emptySnapPoints == 0 then
                                setState("Placing Items", "No more empty snap points!")
                                break
                            end

                            local placedThisRound = 0
                            for itemUID, itemData in pairs(inventory) do
                                if not checkEnabled() then break end
                                if #emptySnapPoints == 0 then break end
                                local snapPoint = table.remove(emptySnapPoints, 1)
                                local itemId = type(itemData) == "table" and (itemData.ItemId or itemData.itemId or itemData.Id or itemData.id) or itemData
                                if itemUID and itemId then
                                    setState("Placing Items", string.format("Placing item %d (snap %d)", placedThisRound + 1, #emptySnapPoints))
                                    Utils:SafeCall(function()
                                        if PlaceStockItem:IsA("RemoteEvent") then
                                            PlaceStockItem:FireServer(itemUID, tostring(itemId), snapPoint.worldCFrame, 0, snapPoint.shelfGUID, snapPoint.name)
                                        elseif PlaceStockItem:IsA("RemoteFunction") then
                                            PlaceStockItem:InvokeServer(itemUID, tostring(itemId), snapPoint.worldCFrame, 0, snapPoint.shelfGUID, snapPoint.name)
                                        end
                                    end)
                                    placedThisRound = placedThisRound + 1
                                    ItemsPlacedCount = ItemsPlacedCount + 1
                                    task.wait(0.4)
                                end
                            end

                            if placedThisRound == 0 then
                                setState("Placing Items", "Could not place any items")
                                break
                            end

                            setState("Placing Items", string.format("Placed %d items, checking for more...", placedThisRound))
                            task.wait(1)
                        end

                        -- ✅ Reset weight tracker after returning to base
                        WeightTracker:Reset()
                    end
                else
                    setState("Bidding", "Auction lost / no items")
                    task.wait(2)
                end

                setState("Loop Delay", "Cycle complete, restarting in 3s...")
                local delayStart = tick()
                while tick() - delayStart < 3 and checkEnabled() do
                    task.wait(0.5)
                end
            end
        end
    end

    PathfinderPhase = "Idle"
    PathfinderStatus = PathfinderStopping and "Stopping..." or "Disabled"
    PathfinderRunning = false
end

setPathfinderEnabled = function(value)
    PathfinderEnabled = value
    if value and not PathfinderRunning then
        PathfinderStopping = false
        PathfinderRunning = true
        PathfinderStatus  = "Starting..."
        task.spawn(pathfinderLoop)
    elseif not value then
        PathfinderStopping = true
        PathfinderStatus = "Stopping..."
    end
end

-- ====================== AUTO-COLLECT THREAD ======================
local function isCollectPrompt(prompt)
    local actionText = (prompt.ActionText or ""):lower()
    return actionText:find("open", 1, true) ~= nil
        or actionText:find("add to vehicle", 1, true) ~= nil
end

local function firePrompt(prompt)
    if fireproximityprompt then
        pcall(fireproximityprompt, prompt, 0, true)
    else
        pcall(function()
            prompt:InputHoldBegin()
            task.wait((prompt.HoldDuration or 0) + 0.05)
            prompt:InputHoldEnd()
        end)
    end
end

task.spawn(function()
    while true do
        task.wait(0.3)
        if AutoCollect or AutoCollectNoTP then
            local character = LocalPlayer.Character
            local rootPart  = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if not (AutoCollect or AutoCollectNoTP) then break end
                    if desc:IsA("ProximityPrompt") and desc.Enabled and isCollectPrompt(desc) then
                        local promptParent = desc.Parent
                        if promptParent and promptParent:IsA("BasePart") then
                            if AutoCollect then
                                local wasAnchored    = rootPart.Anchored
                                local originalCFrame = rootPart.CFrame
                                rootPart.Anchored = true
                                rootPart.CFrame   = promptParent.CFrame + Vector3.new(0, 3, 0)
                                task.wait(0.15)
                                firePrompt(desc)
                                task.wait(0.15)
                                rootPart.CFrame   = originalCFrame
                                rootPart.Anchored = wasAnchored
                            elseif AutoCollectNoTP then
                                local maxDist = desc.MaxActivationDistance
                                if not maxDist or maxDist <= 0 then maxDist = 10 end
                                local distance = (rootPart.Position - promptParent.Position).Magnitude
                                if distance <= maxDist then
                                    firePrompt(desc)
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Resume loops if left enabled in saved config
if AutoPlaceEnabled then task.defer(startAutoPlaceLoop) end
if AutoSellEnabled  then task.defer(startAutoSellLoop)  end
if PathfinderEnabled then
    task.defer(function() setPathfinderEnabled(true) end)
end

print("[DYHUB] Game loaded " .. version .. " loaded successfully!")
print("[DYHUB] Auto saving every " .. tostring(settings.AutoSaveDelay) .. "s")
