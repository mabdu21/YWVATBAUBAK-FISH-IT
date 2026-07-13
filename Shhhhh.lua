-- =========================
local version = "BETA"
local ver     = "v022.56"
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
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local VIM               = game:GetService("VirtualInputManager")
local CoreGui           = game:GetService("CoreGui")

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

-- ====================== RE-EXECUTION SAFETY ======================
-- Tracks live RemoteEvent connections & background flags so re-running
-- the script (common with auto-executors) never double-hooks events,
-- which would otherwise cause duplicate bids / duplicate offer replies.
local activeConnections = {}
local function registerConnection(connection)
    table.insert(activeConnections, connection)
    return connection
end

-- Live runtime state (synced from the saved config further below)
local AutoAcceptOffers = false
local MinAcceptPercent = 15
local AutoPlaceEnabled = false
local AutoBid          = false
local MinBid            = 0
local MaxBid            = 0
local AutoCollect      = false
local AutoCollectNoTP  = false

-- Auction helper state
local ignoredAuctionUnits = {}
local currentAuctionUnit  = nil

-- Remotes resolved lazily in the background (see BACKGROUND INITIALIZATION)
local PlaceStockItem                  = nil
local GetPlayerInventory              = nil
local TransferVehicleItemsToInventory = nil
local BidEvent                        = nil

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
    Size       = UDim2.fromOffset(540, 420),
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
    local self      = setmetatable({}, CustomConfig)
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

-- ====================== SETTINGS TABLE (persisted) ======================
local settings = {
    AutoAcceptOffers = Config:Get("AutoAcceptOffers", false),
    MinAcceptPercent = Config:Get("MinAcceptPercent", 15),
    AutoPlaceEnabled = Config:Get("AutoPlaceEnabled", false),
    InstantPrompt    = Config:Get("InstantPrompt", false),
    autoCleanEnabled = Config:Get("autoCleanEnabled", false),
    washSlot         = Config:Get("washSlot", {}),
    AutoBid          = Config:Get("AutoBid", false),
    MinBid           = Config:Get("MinBid", 5),
    MaxBid           = Config:Get("MaxBid", 1000),
    AutoCollect      = Config:Get("AutoCollect", false),
    AutoCollectNoTP  = Config:Get("AutoCollectNoTP", false),
    AutoSaveEnabled  = Config:Get("AutoSaveEnabled", true),
    AutoSaveDelay    = Config:Get("AutoSaveDelay", 15),
    selectedZone     = Config:Get("selectedZone", "Junk Yard"),
    selectedLocation = Config:Get("selectedLocation", "Mall"),
    MovementType     = Config:Get("MovementType", "WalkSpeed"),
    MovementEnabled  = Config:Get("MovementEnabled", false),
    Noclip           = Config:Get("Noclip", false),
    InfiniteJump     = Config:Get("InfiniteJump", false),
    MovementValue    = Config:Get("MovementValue", 16),
}

-- Sync loaded config into the live runtime state declared earlier
InstantPrompt    = settings.InstantPrompt
AutoAcceptOffers = settings.AutoAcceptOffers
MinAcceptPercent = settings.MinAcceptPercent
AutoPlaceEnabled = settings.AutoPlaceEnabled
AutoBid          = settings.AutoBid
MinBid           = settings.MinBid
MaxBid           = settings.MaxBid
AutoCollect      = settings.AutoCollect
AutoCollectNoTP  = settings.AutoCollectNoTP

if settings.AutoSaveEnabled then
    Config:AutoSave(settings.AutoSaveDelay)
end

-- Register the cleanup routine for THIS execution (used if the script re-runs)
getgenv().DYHUB_SH_Cleanup = function()
    AutoAcceptOffers = false
    AutoPlaceEnabled = false
    AutoBid          = false
    AutoCollect      = false
    AutoCollectNoTP  = false
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
local InfoTab     = Window:Tab({ Title = "Information", Icon = "info" })
local _D1         = Window:Divider()
local AuctionTab  = Window:Tab({ Title = "Main",  Icon = "rocket" })
local PlayerTab  = Window:Tab({ Title = "Player",  Icon = "user" })
local CollectTab  = Window:Tab({ Title = "Collect",  Icon = "package" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local _D2         = Window:Divider()
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

Window:SelectTab(1)

--// =========================
--// PLAYER TAB - MOVEMENT
--// =========================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local movementType    = settings.MovementType or "WalkSpeed"
if type(movementType) == "table" then
    movementType = movementType[1] or "WalkSpeed"
end
if movementType ~= "WalkSpeed" and movementType ~= "JumpPower" then
    movementType = "WalkSpeed"
end
local movementValue   = settings.MovementValue or 16
local movementEnabled = settings.MovementEnabled or false

local noclipEnabled   = settings.Noclip or false
local infJumpEnabled  = settings.InfiniteJump or false

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return end
    return char:FindFirstChildOfClass("Humanoid")
end

local function getCharacter()
    return LocalPlayer.Character
end

PlayerTab:Section({
    Title = "Movement",
    Icon = "person-standing"
})

-- Movement Type
PlayerTab:Dropdown({

    Title = "Movement Type",

    Values = {
        "WalkSpeed",
        "JumpPower",
    },

    Multi = false,

    Value = movementType,

    Callback = function(v)

        -- Defensive unwrap: some WindUI builds may still hand back a table
        if type(v) == "table" then
            v = v[1]
        end

        if v ~= "WalkSpeed" and v ~= "JumpPower" then
            return
        end

        movementType = v

        settings.MovementType = v
        Config:Set("MovementType", v)
        Config:Save()

        WindUI:Notify({
            Title = "Movement",
            Content = "Selected : "..v,
            Duration = 2,
            Icon = "settings"
        })

    end

})

-- Value
PlayerTab:Slider({

    Title = "Movement Value",

    Desc = "Adjust selected movement.",

    Value = {
        Min = 0,
        Max = 200,
        Default = movementValue
    },

    Step = 1,

    Callback = function(v)

        movementValue = v

        settings.MovementValue = v
        Config:Set("MovementValue", v)
        Config:Save()

    end

})

-- Enable
PlayerTab:Toggle({

    Title = "Enable Movement",

    Desc = "Keep movement value forever.",

    Value = movementEnabled,

    Callback = function(v)

        movementEnabled = v

        settings.MovementEnabled = v
        Config:Set("MovementEnabled", v)
        Config:Save()

        WindUI:Notify({
            Title = "Movement",
            Content = v and "Enabled" or "Disabled",
            Duration = 2,
            Icon = v and "shield" or "shield-off"
        })

    end

})

-- Noclip
PlayerTab:Toggle({

    Title = "Noclip",

    Desc = "Walk through walls.",

    Value = noclipEnabled,

    Callback = function(v)

        noclipEnabled = v

        settings.Noclip = v
        Config:Set("Noclip", v)
        Config:Save()

        WindUI:Notify({
            Title = "Noclip",
            Content = v and "Enabled" or "Disabled",
            Duration = 2,
            Icon = v and "shield" or "shield-off"
        })

    end

})

-- Infinite Jump
PlayerTab:Toggle({

    Title = "Infinite Jump",

    Desc = "Adjust your jump to infinitely.",

    Value = infJumpEnabled,

    Callback = function(v)

        infJumpEnabled = v

        settings.InfiniteJump = v
        Config:Set("InfiniteJump", v)
        Config:Save()

        WindUI:Notify({
            Title = "Infinite Jump",
            Content = v and "Enabled" or "Disabled",
            Duration = 2,
            Icon = v and "shield" or "shield-off"
        })

    end

})

----------------------------------------------------
-- Force WalkSpeed / JumpPower
----------------------------------------------------

RunService.Heartbeat:Connect(function()

    if not movementEnabled then
        return
    end

    local hum = getHumanoid()

    if not hum then
        return
    end

    if movementType == "WalkSpeed" then

        if hum.WalkSpeed ~= movementValue then
            hum.WalkSpeed = movementValue
        end

    elseif movementType == "JumpPower" then

        hum.UseJumpPower = true

        if hum.JumpPower ~= movementValue then
            hum.JumpPower = movementValue
        end

    end

end)

----------------------------------------------------
-- Noclip
----------------------------------------------------

RunService.Stepped:Connect(function()

    if not noclipEnabled then
        return
    end

    local char = getCharacter()

    if not char then
        return
    end

    for _,v in ipairs(char:GetDescendants()) do

        if v:IsA("BasePart") then
            v.CanCollide = false
        end

    end

end)

----------------------------------------------------
-- Infinite Jump
----------------------------------------------------

UserInputService.JumpRequest:Connect(function()

    if not infJumpEnabled then
        return
    end

    local hum = getHumanoid()

    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

end)

-- ====================== HELPER FUNCTIONS ======================
-- (ported from the Storage Hunters system — logic unchanged)

local function safeCallRemote(remote, ...)
    if not remote then return false, "Remote not found" end
    local args = {...}
    if remote:IsA("RemoteEvent") then
        local status, err = pcall(function()
            remote:FireServer(unpack(args))
        end)
        return status, err
    elseif remote:IsA("RemoteFunction") then
        local status, result = pcall(function()
            return remote:InvokeServer(unpack(args))
        end)
        return status, result
    end
    return false, "Invalid remote type"
end

local function getTopLevelModel(instance)
    if not instance then return nil end
    local current = instance
    local lastModel = nil
    while current and current ~= Workspace do
        if current:IsA("Model") then
            lastModel = current
        end
        current = current.Parent
    end
    return lastModel
end

local function getMyVehicle()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass('Humanoid')

    if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA('VehicleSeat') then
        return getTopLevelModel(humanoid.SeatPart)
    end

    local plotsFolder = Workspace:FindFirstChild("_Plots")
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            if plotsFolder and obj:IsDescendantOf(plotsFolder) then
                continue
            end
            if obj.Name:lower():find("plot") then
                continue
            end
            if obj:FindFirstChildWhichIsA("VehicleSeat", true) then
                return obj
            end
        end
    end
    return nil
end

-- Only returns a vehicle when the player is CURRENTLY SEATED in it.
-- (getMyVehicle() above also matches any vehicle the player merely owns,
-- even if parked far away -- using that inside teleportTo() was causing
-- TP to Location / TP to Zone / TP to Base (without item) to silently
-- teleport a random parked truck instead of moving the player.)
local function getSeatedVehicle()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass('Humanoid')
    if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA('VehicleSeat') then
        return getTopLevelModel(humanoid.SeatPart)
    end
    return nil
end

-- Safe pivot getter: handles BaseParts, Models, AND plain Folders.
-- Some zone/plot markers are Folders (no BasePart, no native GetPivot),
-- so a raw :GetPivot() call on them throws and the whole teleport
-- silently fails. This falls back to averaging descendant BasePart
-- positions when the instance itself has no pivot.
local function getSafePivot(inst)
    if not inst then return nil end

    if inst:IsA("BasePart") then
        return inst.CFrame
    end

    if inst:IsA("Model") then
        local ok, cf = pcall(function() return inst:GetPivot() end)
        if ok and cf then return cf end
    end

    -- Folder (or anything else without a usable pivot) -> average of
    -- descendant BasePart positions
    local sum = Vector3.new()
    local count = 0
    for _, d in ipairs(inst:GetDescendants()) do
        if d:IsA("BasePart") then
            sum = sum + d.Position
            count = count + 1
        end
    end
    if count > 0 then
        return CFrame.new(sum / count)
    end

    return nil
end

local function teleportTo(destinationCFrame)
    local vehicle = getSeatedVehicle()
    if vehicle then
        print("[Teleport] Teleporting vehicle: " .. tostring(vehicle))
        local root = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart", true)
        if root then
            local wasAnchored = root.Anchored
            root.Anchored = true
            local success, err = pcall(function()
                vehicle:PivotTo(destinationCFrame)
            end)
            if not success then warn("[Teleport] Vehicle PivotTo failed: " .. tostring(err)) end

            task.spawn(function()
                task.wait(0.15)
                root.Anchored = wasAnchored
            end)
        else
            pcall(function()
                vehicle:PivotTo(destinationCFrame)
            end)
        end
        return
    end

    local character = LocalPlayer.Character
    if character then
        print("[Teleport] Teleporting character")
        local success, err = pcall(function()
            character:PivotTo(destinationCFrame)
        end)
        if not success then warn("[Teleport] Character PivotTo failed: " .. tostring(err)) end
    else
        warn("[Teleport] Character not found!")
    end
end

local function findLocationByName(name)
    local areas = Workspace:FindFirstChild("Areas")
    if areas then
        local found = areas:FindFirstChild(name, true)
        if found and (found:IsA("BasePart") or found:IsA("Model")) then return found end
    end

    local shops = Workspace:FindFirstChild("Shops")
    if shops then
        local found = shops:FindFirstChild(name, true)
        if found and (found:IsA("BasePart") or found:IsA("Model")) then return found end
    end

    for _, desc in ipairs(Workspace:GetDescendants()) do
        if (desc:IsA("BasePart") or desc:IsA("Model")) and desc.Name:lower():find(name:lower()) then
            return desc
        end
    end
    return nil
end

local function getMyPlot()
    local plots = Workspace:FindFirstChild("_Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:GetAttribute('OwnerUserId') == LocalPlayer.UserId then
                return plot
            end
        end
    end

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:GetAttribute('OwnerUserId') == LocalPlayer.UserId and not obj:FindFirstChildWhichIsA("VehicleSeat", true) then
            return obj
        end
    end
    return nil
end

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

local function isGUID(str)
    if type(str) ~= "string" then return false end
    if #str ~= 36 then return false end
    local hyphens = 0
    for i = 1, #str do
        if str:sub(i, i) == "-" then
            hyphens = hyphens + 1
        end
    end
    return hyphens == 4
end

local function getVehicleItems(vehicle)
    local uids = {}
    local seen = {}

    local function addUid(uid)
        if isGUID(uid) and not seen[uid] then
            seen[uid] = true
            table.insert(uids, uid)
        end
    end

    if vehicle then
        for _, desc in ipairs(vehicle:GetDescendants()) do
            addUid(desc.Name)
            if desc:IsA("StringValue") then
                addUid(desc.Value)
            end
            local attrs = desc:GetAttributes()
            for k, v in pairs(attrs) do
                if type(v) == "string" then
                    addUid(v)
                end
            end
        end
    end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        for _, desc in ipairs(playerGui:GetDescendants()) do
            addUid(desc.Name)
            if desc:IsA("StringValue") then
                addUid(desc.Value)
            end
            local attrs = desc:GetAttributes()
            for k, v in pairs(attrs) do
                if type(v) == "string" then
                    addUid(v)
                end
            end
        end
    end

    return uids
end

local function findUnpackZone()
    local zone = Workspace:FindFirstChild("UnpackZone") or Workspace:FindFirstChild("Unpack Zone")
    if zone then return zone end

    local plot = getMyPlot()
    if plot then
        zone = plot:FindFirstChild("UnpackZone") or plot:FindFirstChild("Unpack Zone") or plot:FindFirstChild("UnpackZone", true) or plot:FindFirstChild("Unpack Zone", true)
        if zone then return zone end
    end

    for _, desc in ipairs(Workspace:GetDescendants()) do
        local name = desc.Name:lower()
        if name:find("unpack") and name:find("zone") then
            return desc
        end
    end

    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name:lower():find("unpack") then
            return desc
        end
    end

    return nil
end

-- Body assigned later in the AUTO PLACE LOOP section (forward declaration)
local startAutoPlaceLoop

-- ====================== AUCTION TAB ======================
AuctionTab:Divider()

local InstantPrompt = settings.InstantPrompt
local PromptCache = {}
local Connections = {}

local function ApplyPrompt(prompt)
    if not PromptCache[prompt] then
        PromptCache[prompt] = prompt.HoldDuration
    end

    if prompt.HoldDuration ~= 0 then
        prompt.HoldDuration = 0
    end
end

local function RestorePrompts()
    for prompt, duration in pairs(PromptCache) do
        if prompt and prompt.Parent then
            prompt.HoldDuration = duration
        end
    end

    table.clear(PromptCache)
end

AuctionTab:Section({ Title = "Auction Prompt", Icon = "cpu" })

local function setInstantPrompt(state, notify)
    InstantPrompt = state
    settings.InstantPrompt = state
    Config:Set("InstantPrompt", state)
    Config:Save()

    if notify then
        WindUI:Notify({
            Title = "Instant Prompt",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = state and "cpu" or "ban"
        })
    end

    if state then

        -- Apply ทุกตัวที่มีอยู่
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                ApplyPrompt(v)
            end
        end

        -- Prompt ที่สร้างใหม่
        if Connections.Added then
            Connections.Added:Disconnect()
        end
        Connections.Added = Workspace.DescendantAdded:Connect(function(v)
            if v:IsA("ProximityPrompt") then
                ApplyPrompt(v)
            end
        end)

        -- กันเกมเปลี่ยน HoldDuration กลับ
        task.spawn(function()
            while InstantPrompt do
                for prompt in pairs(PromptCache) do
                    if prompt and prompt.Parent and prompt.HoldDuration ~= 0 then
                        prompt.HoldDuration = 0
                    end
                end
                task.wait(0.2)
            end
        end)

    else

        if Connections.Added then
            Connections.Added:Disconnect()
            Connections.Added = nil
        end

        RestorePrompts()

    end
end

AuctionTab:Toggle({
    Title = "Instant Prompt",
    Desc = "Adjust proximity prompt to no hold anymore.",
    Value = InstantPrompt,
    Callback = function(state)
        setInstantPrompt(state, true)
    end
})

-- Resume Instant Prompt automatically if it was left enabled in the saved config
if InstantPrompt then
    task.defer(function() setInstantPrompt(true, false) end)
end

AuctionTab:Section({ Title = "Auction Bidding", Icon = "gavel" })

AuctionTab:Toggle({
    Title    = "Auto Bid",
    Desc     = "Automatically place bids while an auction is active.",
    Value    = AutoBid,
    Callback = function(state)
        AutoBid = state
        settings.AutoBid = state
        Config:Set("AutoBid", state); Config:Save()
        WindUI:Notify({ Title = "Auto Bid", Content = state and "Enabled" or "Disabled", Duration = 2, Icon = state and "gavel" or "ban" })
    end
})
AuctionTab:Input({
    Title       = "Min Starting Bid",
    Value       = tostring(MinBid),
    Placeholder = "Enter your min bid",
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
    Placeholder = "Enter your max bid",
    Callback    = function(text)
        local num = tonumber(text)
        MaxBid = num or 1000
        settings.MaxBid = MaxBid
        Config:Set("MaxBid", MaxBid); Config:Save()
    end
})
AuctionTab:Paragraph({
    Title = "How it works",
    Desc  = "Auctions starting below Min Starting Bid are skipped automatically. Bids increase by 50 each round, capped at your Max Bid.",
})

-- ====================== COLLECT TAB ======================
CollectTab:Divider()
CollectTab:Section({ Title = "Offers & Plot", Icon = "tag" })

CollectTab:Toggle({
    Title    = "Auto Accept Offers",
    Desc     = "Automatically respond to shopper NPC offers.",
    Value    = AutoAcceptOffers,
    Callback = function(state)
        AutoAcceptOffers = state
        settings.AutoAcceptOffers = state
        Config:Set("AutoAcceptOffers", state); Config:Save()
        WindUI:Notify({ Title = "Auto Accept Offers", Content = state and "Enabled" or "Disabled", Duration = 2, Icon = state and "tag" or "ban" })
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
        else
            warn("[DYHUB] Min Accept %: invalid number entered")
        end
    end
})
CollectTab:Toggle({
    Title    = "Auto Place Items",
    Desc     = "Automatically place inventory items onto your plot.",
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

local StartWash = game:GetService("ReplicatedStorage").Events.Wash.StartWash
local CollectWash = game:GetService("ReplicatedStorage").Events.Wash.CollectWash

-- ค่าที่บันทึกไว้ (โหลดจาก settings ถ้ามี)
-- washSlot ตอนนี้เป็น table เพราะ dropdown เป็น Multi-select เช่น { "1", "3" }
local washSlot = settings.washSlot
if type(washSlot) ~= "table" then washSlot = {} end
local autoCleanEnabled = settings.autoCleanEnabled or false
local autoCleanGen     = 0 -- กันไม่ให้ลูปเก่ากับลูปใหม่ทับกันตอนกด toggle ถี่ๆ

-- Dropdown เลือกช่อง (เลือกได้หลายช่องพร้อมกัน) ใช้กับทั้ง StartWash และ CollectWash
CollectTab:Dropdown({
    Title    = "Adjust slot for Clean",
    Values   = { "1", "2", "3" },
    Multi    = true,
    Value    = washSlot,
    Callback = function(v)
        washSlot = v
        settings.washSlot = v
        Config:Set("washSlot", v); Config:Save()
        WindUI:Notify({ Title = "Wash Slot", Content = table.concat(v, ", "), Duration = 2, Icon = "settings" })
    end
})

-- คืน list ของช่องที่เลือกไว้ เรียงจากน้อยไปมาก (เป็นตัวเลข) เช่น {1, 3}
local function getSelectedWashSlots()
    local list = {}
    for _, v in pairs(washSlot) do
        local n = tonumber(v)
        if n then table.insert(list, n) end
    end
    table.sort(list)
    return list
end

-- อ้างอิงปุ่ม CollectBtn ของแต่ละช่องใน WashShopPanel
-- PlayerGui.UIControllerGui.WashShopPanel.SlotsContainer.SlotN.Content.CollectBtn
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

-- รอจน CollectBtn.Visible == true (มี timeout กันลูปค้างถ้า UI ไม่ขึ้น)
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

-- 1 รอบของ Auto Clean:
-- เช็คว่ามีของบนรถไหม (เหมือน Unload Truck) -> ถ้ามี ยิง StartWash ทีละช่องที่เลือกไว้
-- -> รอ UI CollectBtn ของช่องนั้นเป็น true -> ยิง CollectWash -> วนช่องถัดไป
local function doAutoCleanCycle(myGen, silent)
    local vehicle  = getMyVehicle()
    local itemUids = getVehicleItems(vehicle)

    if #itemUids == 0 then
        return false
    end

    local slots = getSelectedWashSlots()
    if #slots == 0 then
        if not silent then
            WindUI:Notify({ Title = "Auto Clean", Content = "Please select at least one slot.", Duration = 3, Icon = "alert-triangle" })
        end
        return false
    end

    for _, slot in ipairs(slots) do
        if not (autoCleanEnabled and autoCleanGen == myGen) then break end

        -- StartWash ต้องการ id เป็น string เดี่ยวๆ ไม่ใช่ table {} จึงต้องยิงทีละ uid
        local anyMoved = false
        for _, uid in ipairs(itemUids) do
            if not (autoCleanEnabled and autoCleanGen == myGen) then break end
            local success, moved = safeCallRemote(StartWash, slot, uid, "Vehicle", "STARTER-DUSTER")
            if success and moved then
                anyMoved = true
            end
        end

        if anyMoved then
            local ready = waitForCollectReady(slot, myGen, 20)
            if ready then
                safeCallRemote(CollectWash, slot)
                if not silent then
                    WindUI:Notify({ Title = "Auto Clean", Content = "Slot " .. slot .. " collected!", Duration = 2, Icon = "check" })
                end
            end
        end

        task.wait(0.3)
    end

    return true
end

-- Toggle: Auto Clean (Dirty)
-- ทำงานแบบเดียวกับ Unload Truck คือเช็คของบนรถก่อน ต่างกันตรงที่พอมีของแล้ว
-- จะยิง StartWash แทน TransferVehicleItemsToInventory แล้ววนรอเก็บของอัตโนมัติ
CollectTab:Toggle({
    Title    = "Auto Clean Item (Dirty)",
    Desc     = "Automatically move dirty items into the washer and collect.",
    Value    = autoCleanEnabled,
    Callback = function(v)
        autoCleanEnabled = v
        settings.autoCleanEnabled = v
        Config:Set("autoCleanEnabled", v); Config:Save()

        WindUI:Notify({
            Title    = "Auto Clean",
            Content  = v and "Enabled" or "Disabled",
            Duration = 3,
            Icon     = v and "shield" or "shield-off"
        })

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
    Desc  = "Move dirty from your vehicle into washing.",
    Callback = function()
        local vehicle = getMyVehicle()
        if TransferVehicleItemsToInventory then
            local itemUids = getVehicleItems(vehicle)
            if #itemUids > 0 then
                local success, result = safeCallRemote(StartWash, slot, itemUids, "Vehicle", "STARTER-DUSTER")
                if success then
                    WindUI:Notify({ Title = "Clean Item", Content = "Clean command sent!", Duration = 2, Icon = "truck" })
                else
                    WindUI:Notify({ Title = "Clean Item", Content = "Failed to Clean Item.", Duration = 3, Icon = "alert-triangle" })
                end
            else
                WindUI:Notify({ Title = "Clean Item", Content = "No items detected in the vehicle.", Duration = 3, Icon = "alert-triangle" })
            end
        else
            WindUI:Notify({ Title = "Clean Item", Content = "Remote not ready yet, try again shortly.", Duration = 3, Icon = "alert-triangle" })
        end
    end
})
CollectTab:Button({
    Title = "Collect Clean Item",
    Desc  = "Collect item from washing machine.",
    Callback = function()
        safeCallRemote(CollectWash, slot)
    end
})
CollectTab:Divider()
CollectTab:Section({ Title = "Truck Utilities", Icon = "truck" })
CollectTab:Button({
    Title = "Unload Truck",
    Desc  = "Move everything from your vehicle into your inventory.",
    Callback = function()
        local vehicle = getMyVehicle()
        if TransferVehicleItemsToInventory then
            local itemUids = getVehicleItems(vehicle)
            if #itemUids > 0 then
                local success, result = safeCallRemote(TransferVehicleItemsToInventory, itemUids)
                if success then
                    WindUI:Notify({ Title = "Unload Truck", Content = "Unload command sent!", Duration = 2, Icon = "truck" })
                else
                    WindUI:Notify({ Title = "Unload Truck", Content = "Failed to unload.", Duration = 3, Icon = "alert-triangle" })
                end
            else
                WindUI:Notify({ Title = "Unload Truck", Content = "No items detected in the vehicle.", Duration = 3, Icon = "alert-triangle" })
            end
        else
            WindUI:Notify({ Title = "Unload Truck", Content = "Remote not ready yet, try again shortly.", Duration = 3, Icon = "alert-triangle" })
        end
    end
})
CollectTab:Paragraph({
    Title = "Important",
    Desc  = "You must be sitting in the truck's driver seat for Unload Truck to work.",
})

CollectTab:Divider()
CollectTab:Section({ Title = "Collect", Icon = "move" })
CollectTab:Toggle({
    Title    = "Auto Collect",
    Desc     = "Teleports to and collects nearby item.",
    Value    = AutoCollect,
    Callback = function(state)
        AutoCollect = state
        settings.AutoCollect = state
        Config:Set("AutoCollect", state); Config:Save()
        if state and AutoCollectNoTP then
            -- avoid both modes fighting over the same prompt at once
            AutoCollectNoTP = false
            settings.AutoCollectNoTP = false
            Config:Set("AutoCollectNoTP", false); Config:Save()
        end
        WindUI:Notify({ Title = "Auto Collect", Content = state and "Enabled" or "Disabled", Duration = 2, Icon = state and "move" or "ban" })
    end
})

CollectTab:Toggle({
    Title    = "Auto Collect (without tp)",
    Desc     = "Collects item only when you're already close enough.",
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
        WindUI:Notify({ Title = "Auto Collect (without tp)", Content = state and "Enabled" or "Disabled", Duration = 2, Icon = state and "move" or "ban" })
    end
})

-- ====================== TELEPORT TAB ======================
TeleportTab:Divider()
TeleportTab:Section({ Title = "Base Teleport", Icon = "home" })
TeleportTab:Button({
    Title = "TP to Base",
    Desc  = "Teleport to your base (needs at least 1 item in the truck for the Unpack Zone to appear).",
    Callback = function()
        local unpackZone = findUnpackZone()
        local pivot = unpackZone and getSafePivot(unpackZone)
        if pivot then
            teleportTo(pivot + Vector3.new(0, 5, 0))
        else
            WindUI:Notify({ Title = "TP to Base", Content = "Unpack Zone not found. Make sure your truck has at least 1 item.", Duration = 3, Icon = "alert-triangle" })
        end
    end
})
TeleportTab:Paragraph({
    Title = "Tips",
    Desc  = "If you're seated in the truck, it teleports together with you. At least 1 item must be in the trunk for the Unpack Zone to appear.",
})

TeleportTab:Button({
    Title = "TP to Base (Without item in car)",
    Desc  = "Teleport to your base plot directly. Use this when the truck is empty and the Unpack Zone hasn't spawned.",
    Callback = function()
        local plot = getMyPlot()
        local pivot = plot and getSafePivot(plot)
        if pivot then
            teleportTo(pivot + Vector3.new(0, 5, 0))
        else
            WindUI:Notify({ Title = "TP to Base", Content = "Your plot could not be found.", Duration = 3, Icon = "alert-triangle" })
        end
    end
})

TeleportTab:Divider()
TeleportTab:Section({ Title = "Zones", Icon = "map" })
local zoneList = {
    ["Junk Yard"] = function()
        local areas = Workspace:FindFirstChild("Areas")
        local zone = areas and areas:FindFirstChild("Junk Yard")
        local part = zone and zone:FindFirstChild("CentrePiece", true)
        return part
    end,

    ["Back Alley"] = function()
        local areas = Workspace:FindFirstChild("Areas")
        local zone = areas and areas:FindFirstChild("Back Alley")
        local part = zone and zone:FindFirstChild("Back Alley Road", true)
        return part
    end,

    ["Farm Yard"] = function()
        local areas = Workspace:FindFirstChild("Areas")
        local zone = areas and areas:FindFirstChild("Farmyard")
        local part = zone and zone:FindFirstChild("Lost and Found Box", true)
        return part
    end,

    ["Jurassic"] = function()
        local areas = Workspace:FindFirstChild("Areas")
        local zone = areas and areas:FindFirstChild("Jurassic")
        local part = zone and zone:FindFirstChild("AreaBoundary", true)
        return part
    end,

    ["Shipyard"] = function()
        local areas = Workspace:FindFirstChild("Areas")
        local zone = areas and areas:FindFirstChild("Shipyard")
        local part = zone and zone:FindFirstChild("Lost and Found Box", true)
        return part
    end,
}

local selectedZone = settings.selectedZone or "Junk Yard"

TeleportTab:Dropdown({
    Title = "Select Zone",
    Values = {
        "Junk Yard",
        "Back Alley",
        "Farm Yard",
        "Shipyard",
        "Jurassic",
    },
    Multi = false,
    Value = selectedZone,
    Callback = function(v)
        selectedZone = v
        settings.selectedZone = v
        Config:Set("selectedZone", v)
        Config:Save()

        WindUI:Notify({
            Title = "Teleport",
            Content = "Selected: " .. v,
            Duration = 2,
            Icon = "map-pin"
        })
    end
})

TeleportTab:Button({
    Title = "TP to Zone",
    Desc = "Teleport to the selected zone.",
    Callback = function()
        local finder = zoneList[selectedZone]

        if not finder then
            WindUI:Notify({
                Title = "Teleport",
                Content = "Invalid zone selected.",
                Duration = 3,
                Icon = "alert-triangle"
            })
            return
        end

        local part = finder()
        local pivot = part and getSafePivot(part)

        if pivot then
            teleportTo(pivot + Vector3.new(0, 5, 0))
        else
            WindUI:Notify({
                Title = "Teleport",
                Content = "Location not found.",
                Duration = 3,
                Icon = "alert-triangle"
            })
        end
    end
})

TeleportTab:Divider()
TeleportTab:Section({ Title = "Shops", Icon = "shopping-cart" })
local tpLocations = {
    ["Car Shop"]     = Vector3.new(-240, 1725, -181),
    ["Grading"]      = Vector3.new(339, 1725, -280),
    ["Item Clearing"]= Vector3.new(406, 1725, -275),
    ["Repair Shop"]  = Vector3.new(425, 1725, -77),
    ["Mall"]         = Vector3.new(363, 1725, -58),
}

local selectedLocation = settings.selectedLocation or "Mall"

TeleportTab:Dropdown({
    Title = "Select Location",
    Values = {
        "Car Shop",
        "Grading",
        "Item Clearing",
        "Repair Shop",
        "Mall"
    },
    Multi = false,
    Value = selectedLocation,
    Callback = function(v)
        selectedLocation = v
        settings.selectedLocation = v
        Config:Set("selectedLocation", v)
        Config:Save()

        WindUI:Notify({
            Title = "Teleport",
            Content = "Selected: " .. v,
            Duration = 2,
            Icon = "map-pin"
        })
    end
})

TeleportTab:Button({
    Title = "TP to Location",
    Desc = "Teleport to the selected location",
    Callback = function()
        local pos = tpLocations[selectedLocation]

        if pos then
            teleportTo(CFrame.new(pos + Vector3.new(0, 5, 0)))
        else
            WindUI:Notify({
                Title = "Teleport",
                Content = "No location selected.",
                Duration = 3,
                Icon = "alert-triangle"
            })
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
    Title = "Update: 07/13/2026 | CL: " .. ver,
    Desc  = [[• [ Added ] Auction tab: Auto-Bid, Min Starting Bid, Max Bid
• [ Added ] Collect tab: Auto-Accept Offers, Auto Place Items, Unload Truck, Auto-Collect
• [ Added ] Teleport tab: Base, Zones & Shops shortcuts ]],
})
Info:Divider()

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
end -- INFORMATION TAB do-scope

-- ====================== SETTINGS TAB ======================
do
SettingsTab:Divider()
SettingsTab:Section({Title="Save Config",Icon="save"})
SettingsTab:Button({Title="Save Config (NOW)", Desc = "Saves all current settings immediately.",Callback=function()
    Config:Save(); WindUI:Notify({Title="Config Saved",Content="Config saved successfully!",Duration=2,Icon="save"})
end})
local AutoSaveEnabled = settings.AutoSaveEnabled
local AutoSaveDelay   = settings.AutoSaveDelay
SettingsTab:Toggle({Title="Auto Save Config", Desc = "Automatically saves config at set interval.",Value=AutoSaveEnabled,Callback=function(state)
    AutoSaveEnabled=state; settings.AutoSaveEnabled=state; Config:Set("AutoSaveEnabled",state); Config:Save()
    if state then Config:AutoSave(AutoSaveDelay) else Config:AutoSave(0) end
end})
SettingsTab:Input({Title="Delay Save Config",Value=tostring(AutoSaveDelay),Placeholder="Default: 15",Callback=function(text)
    local num=tonumber(text)
    if num and num>=1 then
        AutoSaveDelay=num; settings.AutoSaveDelay=num; Config:Set("AutoSaveDelay",num); Config:Save()
        if AutoSaveEnabled then Config:AutoSave(num) end
    else warn("[DYHUB] Invalid delay value!") end
end})

SettingsTab:Divider()
SettingsTab:Section({Title="Server Status",Icon="server"})
SettingsTab:Button({Title="Serverhop", Desc = "Teleports you to a different random server.",Callback=function()
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
SettingsTab:Button({Title="Rejoin", Desc = "Rejoins the current game server.",Callback=function()
    WindUI:Notify({Title="Rejoin",Content="Rejoining...",Duration=2,Icon="refresh-cw"}); task.wait(1)
    TeleportService:Teleport(game.PlaceId,LocalPlayer)
end})
end -- SETTINGS TAB do-scope

-- ====================== BACKGROUND INITIALIZATION ======================
-- Resolves remotes and hooks live game events independently in the
-- background so the UI never blocks waiting on them.
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
            local ShowOffer = NPCShopper:WaitForChild('ShowOffer')

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
                        local basePrice = tonumber(tbl[5])
                        if offerPrice and basePrice and basePrice > 0 then
                            local computed = ((offerPrice - basePrice) / basePrice) * 100
                            if computed >= -100 and computed <= 500 then
                                return math.round(computed)
                            end
                        end

                        for i = 5, #tbl do
                            local v = tbl[i]
                            local num = tonumber(v)
                            if num and num > 0 and num < 1 then
                                return num * 100
                            end
                        end

                        for i = 5, #tbl do
                            local v = tbl[i]
                            local num = tonumber(v)
                            if num and num >= -100 and num <= 100 then
                                return num
                            end
                        end
                        return 0
                    end

                    local percent = getParsedPercent(args)

                    if percent >= MinAcceptPercent then
                        safeCallRemote(RespondOffer, offerId, true)
                    else
                        safeCallRemote(RespondOffer, offerId, false)
                    end
                end))
                print("[Storage Hunter] NPCShopper hooked.")
            end
        end
    end)

    -- Plot remote
    task.spawn(function()
        local PlotEvents = Events:WaitForChild('Plot')
        if PlotEvents then
            PlaceStockItem = PlotEvents:WaitForChild('PlaceStockItem')
            print("[Storage Hunter] PlaceStockItem remote resolved.")
        end
    end)

    -- Inventory remote
    task.spawn(function()
        local InventoryEvents = Events:WaitForChild('Inventory')
        if InventoryEvents then
            GetPlayerInventory = InventoryEvents:WaitForChild('GetPlayerInventory')
            print("[Storage Hunter] GetPlayerInventory remote resolved.")
        end
    end)

    -- Vehicle remote
    task.spawn(function()
        local VehicleEvents = Events:WaitForChild('Vehicles')
        if VehicleEvents then
            TransferVehicleItemsToInventory = VehicleEvents:WaitForChild('TransferVehicleItemsToInventory')
            print("[Storage Hunter] TransferVehicleItemsToInventory remote resolved.")
        end
    end)

    -- Auto-Bid hook
    task.spawn(function()
        local AuctionEvents = Events:WaitForChild('Auction')
        if AuctionEvents then
            BidEvent = AuctionEvents:WaitForChild('Bid')
            local UpdateCurrentWinningBid = AuctionEvents:WaitForChild('UpdateCurrentWinningBid')
            local LeaveAuction = AuctionEvents:FindFirstChild('LeaveAuction') or AuctionEvents:WaitForChild('LeaveAuction')

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
                                task.spawn(function()
                                    safeCallRemote(LeaveAuction)
                                end)
                            end
                        else
                            ignoredAuctionUnits[storageUnit] = false
                        end
                    end

                    if storageUnit and ignoredAuctionUnits[storageUnit] then
                        return
                    end

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
                            safeCallRemote(BidEvent, storageUnit, nextBid)
                        else
                            safeCallRemote(BidEvent, nextBid)
                        end
                    end
                end))
                print("[Storage Hunter] Auction events hooked.")
            end
        end
    end)

    print("[Storage Hunter] Background initialization complete.")
end)

-- ====================== AUTO PLACE LOOP ======================
startAutoPlaceLoop = function()
    task.spawn(function()
        print("[Auto Place] Loop started")
        while AutoPlaceEnabled do
            local plot = getMyPlot()
            if not plot then
                task.wait(2)
                continue
            end

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
                for itemId, itemData in pairs(inventory) do
                    if not AutoPlaceEnabled then break end

                    local idToSend
                    if type(itemData) == "table" then
                        idToSend = itemData.UID or itemData.uid or itemData.UUID or itemData.uuid or itemData.Id or itemData.id or itemData.ItemId or itemData.itemId or itemId
                    else
                        idToSend = itemData
                    end

                    if idToSend then
                        if PlaceStockItem then
                            local placeStatus, placeErr = pcall(function()
                                if PlaceStockItem:IsA("RemoteEvent") then
                                    PlaceStockItem:FireServer(plot, idToSend)
                                elseif PlaceStockItem:IsA("RemoteFunction") then
                                    PlaceStockItem:InvokeServer(plot, idToSend)
                                end
                            end)
                            if not placeStatus then
                                warn("[Auto Place] Failed to send command: " .. tostring(placeErr))
                            end
                        else
                            warn("[Auto Place] Remote PlaceStockItem not ready yet!")
                        end
                        task.wait(0.5) -- anti-kick throttle
                    end
                end
            end
            task.wait(2)
        end
        print("[Auto Place] Loop stopped")
    end)
end

-- Resume Auto Place automatically if it was left enabled in the saved config
if AutoPlaceEnabled then
    task.defer(startAutoPlaceLoop)
end

-- ====================== AUTO-COLLECT ======================
local function isCollectPrompt(prompt)
    local actionText = (prompt.ActionText or ""):lower()
    return actionText:find("open", 1, true) ~= nil
        or actionText:find("add to vehicle", 1, true) ~= nil
end

-- Fires a ProximityPrompt in a way that works on both PC and mobile
-- executors (fireproximityprompt is the universal path; the
-- InputHoldBegin/InputHoldEnd pair is the fallback and is itself
-- input-device agnostic since it drives the prompt's hold API directly
-- rather than simulating a keypress/tap).
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
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if not (AutoCollect or AutoCollectNoTP) then break end

                    if desc:IsA("ProximityPrompt") and desc.Enabled and isCollectPrompt(desc) then
                        local promptParent = desc.Parent
                        if promptParent and promptParent:IsA("BasePart") then

                            if AutoCollect then
                                -- Auto Collect: teleport to the prompt, fire it, then return
                                local wasAnchored   = rootPart.Anchored
                                local originalCFrame = rootPart.CFrame
                                rootPart.Anchored = true
                                rootPart.CFrame = promptParent.CFrame + Vector3.new(0, 3, 0)
                                task.wait(0.15)

                                firePrompt(desc)

                                task.wait(0.15)
                                rootPart.CFrame = originalCFrame
                                rootPart.Anchored = wasAnchored

                            elseif AutoCollectNoTP then
                                -- Auto Collect (without tp): only fire when we're
                                -- already close enough for the prompt to be usable
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

print("[DYHUB] Game loaded "..version.." | "..ver.." loaded successfully!")
print("[DYHUB] Auto saving every "..tostring(settings.AutoSaveDelay).."s")
