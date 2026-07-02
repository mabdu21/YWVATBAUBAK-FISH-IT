-- Powered by DYHUB | 100 Days At Sea
-- =========================
local version = "WindUI Rework"
local ver     = "v001.00"
-- =========================

repeat task.wait() until game:IsLoaded()

-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

if setfpscap then
    pcall(setfpscap, 1000000)
    pcall(function()
        WindUI:Notify({ Title = "Service", Content = "FPS Unlocked! | " .. ver, Duration = 3, Icon = "cpu" })
    end)
else
    pcall(function()
        WindUI:Notify({ Title = "Service", Content = "Your executor does not support setfpscap.", Duration = 3, Icon = "ban" })
    end)
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

-- ====================== WINDOW ======================
local Window = WindUI:CreateWindow({
    Title      = "DYHUB",
    IconThemed = true,
    Icon       = "rbxassetid://104487529937663",
    Author     = "100 Days At Sea | Free Version",
    Folder     = "DYHUB_100DaysAtSea",
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
local ConfigFolder = "DYHUB_100DaysAtSea"
local CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self      = setmetatable({}, CustomConfig)
    self.ConfigData = {}
    self.ConfigPath = ConfigFolder .. "/100DaysAtSea_config.json"
    self._autoSaveThread = nil
    self._autoSaveDelay  = 15
    pcall(function()
        if isfolder and makefolder and not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    end)
    self:Load()
    return self
end
function CustomConfig:Set(key, value) self.ConfigData[key] = value end
function CustomConfig:Get(key, default)
    local v = self.ConfigData[key]
    return v ~= nil and v or default
end
function CustomConfig:Save()
    pcall(function()
        if writefile then writefile(self.ConfigPath, HttpService:JSONEncode(self.ConfigData)) end
    end)
end
function CustomConfig:Load()
    pcall(function()
        if isfile and readfile and isfile(self.ConfigPath) then
            local data = HttpService:JSONDecode(readfile(self.ConfigPath))
            if type(data) == "table" then self.ConfigData = data end
        end
    end)
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
Config:AutoSave(Config:Get("AutoSaveDelay", 15))

-- ====================== TABS ======================
local InfoTab     = Window:Tab({ Title = "Information", Icon = "info" })
local _D1         = Window:Divider()
local MainTab     = Window:Tab({ Title = "Main",        Icon = "rocket" })
local FarmTab     = Window:Tab({ Title = "Farm",        Icon = "pickaxe" })
local LootTab     = Window:Tab({ Title = "Collect",     Icon = "package" })
local CombatTab   = Window:Tab({ Title = "Combat",      Icon = "swords" })
local PlayerTab   = Window:Tab({ Title = "Player",      Icon = "user" })
local EspTab      = Window:Tab({ Title = "ESP",         Icon = "eye" })
local VisualTab   = Window:Tab({ Title = "Visual",      Icon = "sun" })
local _D2         = Window:Divider()
local SettingsTab = Window:Tab({ Title = "Settings",    Icon = "settings" })

Window:SelectTab(1)

InfoTab:Section({ Title = "100 Days At Sea", TextXAlignment = "Center", TextSize = 17 })
InfoTab:Divider()
InfoTab:Paragraph({
    Title = "DYHUB WindUI Rework | " .. ver,
    Desc  = [[UI style has been rebuilt with WindUI.
Old Violence District systems were removed.
All gameplay systems from the 100 Days At Sea script are loaded through this UI wrapper.]],
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})
InfoTab:Divider()

MainTab:Section({ Title = "Main Features", Icon = "rocket" })
FarmTab:Section({ Title = "Farm & Utility", Icon = "pickaxe" })
LootTab:Section({ Title = "Collect & Loot", Icon = "package" })
CombatTab:Section({ Title = "Combat", Icon = "swords" })
PlayerTab:Section({ Title = "Player", Icon = "user" })
EspTab:Section({ Title = "ESP", Icon = "eye" })
VisualTab:Section({ Title = "Visual", Icon = "sun" })
SettingsTab:Section({ Title = "Settings", Icon = "settings" })
SettingsTab:Paragraph({
    Title = "Toggle Key",
    Desc = "Press K to open or close DYHUB.",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})

-- ====================== RZY COMPATIBILITY WRAPPER ======================
-- Keeps every system from the old 100 Days At Sea script, but routes all controls into WindUI.
local function DY_SafeCallback(callback, ...)
    if type(callback) ~= "function" then return end
    local ok, err = pcall(callback, ...)
    if not ok then warn("[DYHUB UI Callback]", err) end
end

local function DY_CleanKey(text)
    return tostring(text or "Control"):gsub("%W+", "_")
end

local function DY_RouteTab(title)
    local t = tostring(title or ""):lower()
    if t:find("attack") or t:find("brutal") then
        return CombatTab
    elseif t:find("collect") or t:find("chest") or t:find("claim") then
        return LootTab
    elseif t:find("grinder") or t:find("campfire") or t:find("material") or t:find("pick") or t:find("fishing") or t:find("store") or t:find("dismantle") or t:find("discover") then
        return FarmTab
    elseif t:find("fly") or t:find("heal") or t:find("eat") then
        return PlayerTab
    elseif t:find("esp") or t:find("island") or t:find("rig") then
        return EspTab
    elseif t:find("lag") or t:find("fog") then
        return VisualTab
    end
    return MainTab
end

local function DY_NormalizeMulti(selected, values)
    local out = {}
    for _, name in ipairs(values or {}) do out[name] = false end
    if type(selected) == "table" then
        for key, value in pairs(selected) do
            if type(key) == "string" and type(value) == "boolean" then
                out[key] = value
            elseif type(key) == "number" then
                out[tostring(value)] = true
            elseif value then
                out[tostring(key)] = true
            end
        end
    elseif selected ~= nil then
        out[tostring(selected)] = true
    end
    return out
end

local function DY_MultiToList(tbl)
    local list = {}
    if type(tbl) == "table" then
        for key, value in pairs(tbl) do
            if value == true then table.insert(list, key) end
        end
    end
    table.sort(list)
    return list
end

local Win = {}

function Win:AddToggle(title, default, callback)
    local tab = DY_RouteTab(title)
    local key = "toggle_" .. DY_CleanKey(title)
    local state = default and true or false
    local control
    local api = {}

    control = tab:Toggle({
        Title = tostring(title),
        Desc = state and "Default: Enabled" or "Default: Disabled",
        Value = state,
        Callback = function(value)
            state = value and true or false
            Config:Set(key, state)
            Config:Save()
            DY_SafeCallback(callback, state)
        end
    })

    function api:Set(value)
        state = value and true or false
        pcall(function()
            if control and control.Set then control:Set(state) end
        end)
        Config:Set(key, state)
        Config:Save()
        DY_SafeCallback(callback, state)
    end

    -- The original script depends on this default toggle starting immediately.
    if tostring(title):lower():find("soft anti%-lag") and state == true then
        task.defer(function() DY_SafeCallback(callback, true) end)
    end

    return api
end

function Win:AddDropdown(title, values, callback)
    local tab = DY_RouteTab(title)
    local key = "dropdown_" .. DY_CleanKey(title)
    local defaultValue = (values and values[1]) or nil
    local value = Config:Get(key, defaultValue)

    local control = tab:Dropdown({
        Title = tostring(title),
        Values = values or {},
        Multi = false,
        Value = value,
        Callback = function(selected)
            Config:Set(key, selected)
            Config:Save()
            DY_SafeCallback(callback, selected)
        end
    })

    if value ~= nil then
        task.defer(function() DY_SafeCallback(callback, value) end)
    end
    return control
end

function Win:AddMultiDropdown(title, values, callback)
    local tab = DY_RouteTab(title)
    local key = "multidropdown_" .. DY_CleanKey(title)
    local savedList = Config:Get(key, {})

    local control = tab:Dropdown({
        Title = tostring(title),
        Values = values or {},
        Multi = true,
        Value = savedList,
        Callback = function(selected)
            local normalized = DY_NormalizeMulti(selected, values or {})
            Config:Set(key, DY_MultiToList(normalized))
            Config:Save()
            DY_SafeCallback(callback, normalized)
        end
    })

    task.defer(function()
        DY_SafeCallback(callback, DY_NormalizeMulti(savedList, values or {}))
    end)

    return control
end

function Win:AddInput(title, default, callback)
    local tab = DY_RouteTab(title)
    local key = "input_" .. DY_CleanKey(title)
    local value = tostring(Config:Get(key, default or ""))

    local control = tab:Input({
        Title = tostring(title),
        Default = value,
        Value = value,
        Placeholder = tostring(default or ""),
        Callback = function(text)
            Config:Set(key, tostring(text or ""))
            Config:Save()
            DY_SafeCallback(callback, text)
        end
    })

    task.defer(function() DY_SafeCallback(callback, value) end)
    return control
end

-- Tabel Penyimpanan Status Dropdown
local TargetMaterials = {
    ["Wood"] = false,
    ["Metal"] = false,
    ["Goo"] = false,
    ["Small Gas Can"] = false,
    ["Big Gas Can"] = false,
    ["Gas Drum"] = false,
    ["Small Crate"] = false,
    ["Big Crate"] = false,
}

Win:AddMultiDropdown("Material", {"Wood", "Metal", "Goo", "Small Gas Can", "Big Gas Can", "Gas Drum", "Small Crate", "Big Crate", "Penguin"}, function(selectedTable)
    TargetMaterials = selectedTable
end)

local AutoGrinderEnabled = false
local AutoCampfireEnabled = false
local AutoPickEnabled = false

local GrinderToggle = nil
local CampfireToggle = nil

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
-- [SISTEM INTI]: DYNAMIC REMOTE FINDER & TOKEN INTERCEPTOR
-- ====================================================================
local CurrentSyncToken = nil
local GameRemoteEvent = nil
local GameRemoteFunction = nil

local function FindHiddenRemotes()
    local hiddenServices = {
        "Chat", "LocalizationService", "SocialService", "LogService"
    }
    for _, sName in ipairs(hiddenServices) do
        pcall(function()
            local service = game:GetService(sName)
            if service then
                local re = service:FindFirstChild("RemoteEvent")
                local rf = service:FindFirstChild("RemoteFunction")
                if re then GameRemoteEvent = re end
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
                            if self:IsA("RemoteEvent") then GameRemoteEvent = self end
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

-- ====================================================================
-- [FITUR 1]: AUTO GRINDER (PRESERVED POSITION + DISCONNECT)
-- ====================================================================
GrinderToggle = Win:AddToggle("Auto Grinder", false, function(state)
    AutoGrinderEnabled = state
    
    if AutoGrinderEnabled then
        task.spawn(function()
            while AutoGrinderEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local GrinderCol = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Grinder") and workspace.SpawnIsland.Grinder:FindFirstChild("Collection")
                
                if DebrisField and GrinderCol then
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        if not AutoGrinderEnabled then break end
                        
                        if folderObj:GetAttribute("RZY_Processed") then continue end
                        
                        local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        if not resType and part then
                            resType = part:GetAttribute("Resource") or part:GetAttribute("Item")
                        end
                        
                        if resType and TargetMaterials[resType] and part then
                            local isExcluded = false
                            for attrName, attrValue in pairs(folderObj:GetAttributes()) do
                                local lowerName = string.lower(attrName)
                                local lowerValue = type(attrValue) == "string" and string.lower(attrValue) or ""
                                if string.find(lowerName, "armor") or string.find(lowerValue, "armor") or
                                   string.find(lowerName, "chest") or string.find(lowerValue, "chest") or
                                   string.find(lowerName, "leg") or string.find(lowerValue, "leg") then
                                    isExcluded = true
                                    break
                                end
                            end
                            
                            if not isExcluded then
                                local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                                local grabber = folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                local lastHolder = folderObj:GetAttribute("LastHolder") or part:GetAttribute("LastHolder")
                                
                                local myId = tostring(LocalPlayer.UserId)
                                local myName = LocalPlayer.Name
                                
                                local isCurrentlyMyGrab = (isGrabbed == true and (tostring(grabber) == myId or grabber == myName))
                                local isMyPastItem = (lastHolder == myName)
                                
                                if isCurrentlyMyGrab or isMyPastItem then
                                    -- Posisi pas seperti semula tanpa rx, rz
                                    part.CFrame = GrinderCol.CFrame + Vector3.new(0, 1, 0)
                                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                    
                                    -- Langsung putus hubungan & tandai agar dilepas skrip
                                    pcall(function() SafeRemoteEvent("GiveUpOwnership", part) end)
                                    folderObj:SetAttribute("RZY_Processed", true)
                                end
                            end
                        end
                    end
                end
                task.wait(0.05) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 2]: AUTO CAMPFIRE (PRESERVED POSITION + DISCONNECT)
-- ====================================================================
CampfireToggle = Win:AddToggle("Auto Campfire", false, function(state)
    AutoCampfireEnabled = state
    
    if state and GrinderToggle then
        AutoGrinderEnabled = false
        GrinderToggle:Set(false)
    end
    
    if AutoCampfireEnabled then
        task.spawn(function()
            while AutoCampfireEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                local Dropper = workspace:FindFirstChild("SpawnIsland") and workspace.SpawnIsland:FindFirstChild("Dropper")

                if DebrisField and Dropper then
                    local dropperPart = Dropper:IsA("BasePart") and Dropper or Dropper:FindFirstChildWithClass("BasePart") or (Dropper:IsA("Model") and Dropper.PrimaryPart)
                    
                    if dropperPart then
                        for _, folderObj in ipairs(DebrisField:GetChildren()) do
                            if not AutoCampfireEnabled then break end
                            
                            if folderObj:GetAttribute("RZY_Processed") then continue end
                            
                            local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            if not resType and part then
                                resType = part:GetAttribute("Resource") or part:GetAttribute("Item")
                            end
                            
                            local validFuels = {
                                ["Wood"] = true, ["Small Gas Can"] = true, ["Big Gas Can"] = true, ["Gas Drum"] = true
                            }
                            
                            if resType and TargetMaterials[resType] and validFuels[resType] and part then
                                local isExcluded = false
                                for attrName, attrValue in pairs(folderObj:GetAttributes()) do
                                    local lowerName = string.lower(attrName)
                                    local lowerValue = type(attrValue) == "string" and string.lower(attrValue) or ""
                                    if string.find(lowerName, "armor") or string.find(lowerValue, "armor") or
                                       string.find(lowerName, "chest") or string.find(lowerValue, "chest") or
                                       string.find(lowerName, "leg") or string.find(lowerValue, "leg") then
                                        isExcluded = true
                                        break
                                    end
                                end
                                
                                if not isExcluded then
                                    local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                                    local grabber = folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                    local lastHolder = folderObj:GetAttribute("LastHolder") or part:GetAttribute("LastHolder")
                                    
                                    local myId = tostring(LocalPlayer.UserId)
                                    local myName = LocalPlayer.Name
                                    
                                    local isCurrentlyMyGrab = (isGrabbed == true and (tostring(grabber) == myId or grabber == myName))
                                    local isMyPastItem = (lastHolder == myName)
                                    
                                    if isCurrentlyMyGrab or isMyPastItem then
                                        -- Posisi pas seperti semula tanpa rx, rz
                                        part.CFrame = dropperPart.CFrame + Vector3.new(0, 0, 0)
                                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                        
                                        -- Langsung putus hubungan & tandai agar dilepas skrip
                                        pcall(function() SafeRemoteEvent("GiveUpOwnership", part) end)
                                        folderObj:SetAttribute("RZY_Processed", true)
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
end)

-- ====================================================================
-- [FITUR 3]: AUTO EAT (NORMAL & BRUTAL)
-- ====================================================================
local AutoEatEnabled = true
local EatMode = "Normal (Lapar)" 

-- [UI] Dropdown Mode
Win:AddDropdown("Mode Auto Eat", {"Normal (Lapar)", "Brutal (Sapu Bersih)"}, function(selectedMode)
    EatMode = selectedMode
end)

local function RunAutoEat()
    task.spawn(function()
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        local FillBar = PlayerGui:WaitForChild("HUD"):WaitForChild("Food"):WaitForChild("Bar"):WaitForChild("Fill")
        
        while AutoEatEnabled do
            pcall(function()
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                
                if DebrisField then
                    -- ==============================================================
                    -- [LOGIKA 1]: NORMAL (Makan hanya jika lapar)
                    -- ==============================================================
                    if EatMode == "Normal (Lapar)" then
                        if FillBar.Size.X.Scale <= 0.7 then
                            for _, folderObj in ipairs(DebrisField:GetChildren()) do
                                -- Berhenti jika sudah kenyang atau toggle dimatikan/diganti
                                if not AutoEatEnabled or FillBar.Size.X.Scale >= 0.99 or EatMode ~= "Normal (Lapar)" then break end
                                
                                local isFood = folderObj:GetAttribute("Food")
                                local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                                if not isFood and part then isFood = part:GetAttribute("Food") end
                                
                                if isFood and part then
                                    local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                                    local grabber = folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                    
                                    if isGrabbed and tostring(grabber) ~= tostring(LocalPlayer.UserId) and grabber ~= LocalPlayer.Name then continue end
                                    
                                    SafeRemoteEvent("Eat", "~s" .. folderObj.Name)
                                    task.wait(0.05) 
                                end
                            end
                        end
                        
                    -- ==============================================================
                    -- [LOGIKA 2]: BRUTAL (Makan SEMUA tanpa peduli lapar untuk membersihkan map)
                    -- ==============================================================
                    elseif EatMode == "Brutal (Sapu Bersih)" then
                        for _, folderObj in ipairs(DebrisField:GetChildren()) do
                            if not AutoEatEnabled or EatMode ~= "Brutal (Sapu Bersih)" then break end
                            
                            local isFood = folderObj:GetAttribute("Food")
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            if not isFood and part then isFood = part:GetAttribute("Food") end
                            
                            if isFood and part then
                                local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
                                local grabber = folderObj:GetAttribute("Grabber") or part:GetAttribute("Grabber")
                                
                                if isGrabbed and tostring(grabber) ~= tostring(LocalPlayer.UserId) and grabber ~= LocalPlayer.Name then continue end
                                
                                -- [BRUTAL MODE]: Lahap serentak dalam milidetik
                                task.spawn(function()
                                    pcall(function()
                                        SafeRemoteEvent("Eat", "~s" .. folderObj.Name)
                                    end)
                                end)
                                
                                task.wait(0.01) -- Jeda super cepat anti-kick
                            end
                        end
                    end
                end
            end)
            
            task.wait(1) 
        end
    end)
end

Win:AddToggle("Auto Eat", true, function(state)
    AutoEatEnabled = state
    if AutoEatEnabled then RunAutoEat() end
end)
RunAutoEat() -- EKSEKUSI OTOMATIS

-- ====================================================================
-- [FITUR 4]: AUTO COLLECT (DEFAULT AKTIF)
-- ====================================================================
local CollectedItems = {} 
local HasDiamondChest = false
local AutoDoubloonEnabled = true -- Default Aktif

LocalPlayer.CharacterAdded:Connect(function()
    CollectedItems = {}
    HasDiamondChest = false
end)

local TargetWeaponsCollect = {
    ["machete"] = true, ["poku poku"] = true, ["swordfish spear"] = true, ["ghost cutlass"] = true,
    ["flintlock"] = true, ["blunderbuss"] = true, ["rifle"] = true, ["boomstick"] = true,
    ["magma staff"] = true, ["ice staff"] = true, ["squid laser"] = true, ["revolver"] = true, ["hand cannon"] = true, 
    ["angler flare"] = true, ["medkit"] = true
}

local function RunAutoCollect()
    task.spawn(function()
        while AutoDoubloonEnabled do
            local workspace = game:GetService("Workspace")
            local DebrisField = workspace:FindFirstChild("DebrisField")
            
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
            
            if humanoid and humanoid.Health <= 0 then
                HasDiamondChest = false
                CollectedItems = {}
            end
            
            if DebrisField and rootPart then
                for _, folderObj in ipairs(DebrisField:GetChildren()) do
                    if not AutoDoubloonEnabled then break end
                    
                    local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                    local uniqueId = folderObj.Name 
                    local isChest = false
                    
                    if folderObj:GetAttribute("DoubloonChest") or (part and part:GetAttribute("DoubloonChest")) then isChest = true end
                    if not isChest then
                        for attrName, attrValue in pairs(folderObj:GetAttributes()) do
                            local lowerName, lowerValue = string.lower(attrName), type(attrValue) == "string" and string.lower(attrValue) or ""
                            if string.find(lowerName, "doubloonchest") or string.find(lowerValue, "doubloonchest") then
                                isChest = true; break
                            end
                        end
                    end
                    
                    if isChest then
                        SafeRemoteEvent("Collect", "~s" .. uniqueId)
                        task.wait(0.3) 
                        continue 
                    end
                    
                    if part then
                        local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                        if not resType then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                        if not resType then resType = part.Name end 
                        
                        if resType then
                            local distance = (part.Position - rootPart.Position).Magnitude
                            if distance <= 15 then
                                local shouldCollect = false
                                local lowerRes = string.lower(resType)
                                
                                if string.find(lowerRes, "ammo") or string.find(lowerRes, "bandage") then
                                    shouldCollect = true
                                elseif string.find(lowerRes, "diamond") and (string.find(lowerRes, "chest") or string.find(lowerRes, "armor")) then
                                    if not HasDiamondChest then shouldCollect = true; HasDiamondChest = true end
                                else
                                    for wName, _ in pairs(TargetWeaponsCollect) do
                                        if string.find(lowerRes, wName) then
                                            if not CollectedItems[wName] then shouldCollect = true; CollectedItems[wName] = true end
                                            break 
                                        end
                                    end
                                end
                                
                                if shouldCollect then
                                    SafeRemoteEvent("Collect", "~s" .. uniqueId)
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(1) 
        end
    end)
end

Win:AddToggle("Auto Collect", true, function(state)
    AutoDoubloonEnabled = state
    if AutoDoubloonEnabled then RunAutoCollect() end
end)
RunAutoCollect() -- EKSEKUSI OTOMATIS

-- ====================================================================
-- [FITUR 5]: AUTO ATTACK (HANDHELD ONLY + ANGLER FLARE WRAITH)
-- ====================================================================
local AttackMode = "Brutal All Target" 
local BrutalAttackRange = 200 
local AutoAttackEnabled = true 
local LastFlareTime = 0 -- Cooldown memori untuk Angler Flare

Win:AddDropdown("Mode Auto Attack", {"Nearest (Global)", "Brutal All Target"}, function(selectedMode)
    AttackMode = selectedMode
end)

Win:AddInput("Brutal Attack Range", "200", function(value)
    local num = tonumber(value)
    if num then BrutalAttackRange = num end
end)

-- [FUNGSI]: Pengecekan Nyawa Anti-Bug
local function IsEnemyAlive(enemy)
    local healthVal = enemy:FindFirstChild("Health")
    if healthVal and (healthVal:IsA("IntValue") or healthVal:IsA("NumberValue")) then
        return healthVal.Value > 0 
    end
    
    local humanoid = enemy:FindFirstChild("Humanoid") or enemy:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid.Health > 0
    end
    
    return true
end

local function RunAutoAttack()
    task.spawn(function()
        while AutoAttackEnabled do
            pcall(function()
                local workspace = game:GetService("Workspace")
                local CreatureContainer = workspace:FindFirstChild("CreatureContainer")
                
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChild("Humanoid")
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart"))
                
                if CreatureContainer and rootPart and humanoid then
                    
                    -- [FUNGSI UPGRADE]: DETEKSI OTOMATIS (HANYA SAAT SENJATA DIPEGANG)
                    local function CheckAndAttackAsync(toolName, attackLogic)
                        local tool = character:FindFirstChild(toolName)
                        if tool and tool:IsA("Tool") then 
                            task.spawn(function() pcall(attackLogic, tool) end) 
                            return true
                        end
                        return false
                    end

                    -- ==============================================================
                    -- [LOGIKA KHUSUS]: ANGLER FLARE VS WRAITH (COOLDOWN 1 DETIK)
                    -- ==============================================================
                    if tick() - LastFlareTime >= 1 then
                        local targetWraith, targetWraithPart = nil, nil
                        
                        for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                            if enemy.Name == "Wraith" or enemy.Name == "Wraith_CLIENT" then
                                local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                                if enemyPart then
                                    targetWraith = enemy
                                    targetWraithPart = enemyPart
                                    break 
                                end
                            end
                        end
                        
                        if targetWraith and targetWraithPart then
                            local enemyPos = targetWraith:IsA("Model") and targetWraith:GetPivot().Position or targetWraithPart.Position
                            
                            local fired = CheckAndAttackAsync("Angler Flare", function(t)
                                local firePart = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart") or rootPart
                                if firePart then
                                    local originPos = firePart.Position
                                    local direction = (enemyPos - originPos).Unit
                                    
                                    -- Format Argumen Remote sesuai data yang Anda temukan
                                    local originDirStr = string.format("~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0", originPos.X, originPos.Y, originPos.Z, direction.X, direction.Y, direction.Z)
                                    local targetPosStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                                    
                                    SafeRemoteFunction("ToolReplicator", "~sAngler Flare", "~sFire", originDirStr, targetPosStr)
                                end
                            end)
                            
                            if fired then LastFlareTime = tick() end
                        end
                    end
                    -- ==============================================================

                    -- [LOGIKA 1]: SERANG SATU MUSUH TERDEKAT (NEAREST)
                    if AttackMode == "Nearest (Global)" then
                        local nearestEnemy, nearestEnemyPart, shortestDistance = nil, nil, math.huge 
                        for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                            
                            -- Abaikan Wraith untuk senjata biasa
                            if enemy.Name == "Wraith" or enemy.Name == "Wraith_CLIENT" then continue end
                            if not IsEnemyAlive(enemy) then continue end
                            
                            local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                            if enemyPart then
                                local distance = (enemyPart.Position - rootPart.Position).Magnitude
                                if distance <= shortestDistance then
                                    shortestDistance = distance; nearestEnemy = enemy; nearestEnemyPart = enemyPart
                                end
                            end
                        end
                        
                        if nearestEnemy and nearestEnemyPart then
                            local enemyPos = nearestEnemy:IsA("Model") and nearestEnemy:GetPivot().Position or nearestEnemyPart.Position
                            local vecStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                            
                            pcall(function()
                                -- Senjata Remote
                                for _, wName in ipairs({"Harpoon", "Riptide"}) do
                                    CheckAndAttackAsync(wName, function(t) SafeRemoteFunction("ToolReplicator", "~s" .. wName, "~sHitEnemy", nearestEnemy) end)
                                end
                                CheckAndAttackAsync("Magma Staff", function(t) SafeRemoteFunction("ToolReplicator", "~sMagma Staff", "~sFire", vecStr) end)
                                CheckAndAttackAsync("Squid Laser", function(t) SafeRemoteFunction("ToolReplicator", "~sLaser", "~sShoot", vecStr) end)
                                CheckAndAttackAsync("Grenade", function(t) SafeRemoteFunction("ToolReplicator", "~sGrenade", "~sThrow", vecStr, vecStr) end)
                                
                                local gunTypes = {"Rifle", "Flintlock", "Blunderbuss", "Revolver", "Hand Cannon", "Boomstick", "DualPistols", "Assault Rifle"}
                                for _, gunName in ipairs(gunTypes) do
                                    CheckAndAttackAsync(gunName, function(t)
                                        local firePart = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart") or rootPart
                                        if firePart then
                                            local direction = (enemyPos - rootPart.Position).Unit
                                            local gunFormatStr = string.format("~t{1=~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0}", enemyPos.X, enemyPos.Y, enemyPos.Z, direction.X, direction.Y, direction.Z)
                                            SafeRemoteFunction("ToolReplicator", "~sGun", "~sShoot", firePart, gunFormatStr)
                                        end
                                    end)
                                end

                                -- Senjata Melee
                                local meleeTypes = {"Machete", "Ghost Cutlass", "Poku Poku", "Swordfish Spear"} 
                                for _, meleeName in ipairs(meleeTypes) do
                                    CheckAndAttackAsync(meleeName, function(t)
                                        local handle = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart")
                                        if handle and nearestEnemyPart then
                                            t:Activate()
                                            if firetouchinterest then
                                                firetouchinterest(handle, nearestEnemyPart, 0)
                                                task.wait(0.01)
                                                firetouchinterest(handle, nearestEnemyPart, 1)
                                            end
                                        end
                                    end)
                                end
                            end)
                        end
                        
                    -- [LOGIKA 2]: SERANG SEMUA MUSUH DALAM RADIUS (BRUTAL)
                    elseif AttackMode == "Brutal All Target" then
                        for _, enemy in ipairs(CreatureContainer:GetChildren()) do
                            
                            -- Abaikan Wraith untuk senjata biasa
                            if enemy.Name == "Wraith" or enemy.Name == "Wraith_CLIENT" then continue end
                            if not IsEnemyAlive(enemy) then continue end
                            
                            local enemyPart = enemy:IsA("BasePart") and enemy or enemy:FindFirstChildWhichIsA("BasePart") or (enemy:IsA("Model") and enemy.PrimaryPart)
                            
                            if enemyPart then
                                local enemyPos = enemy:IsA("Model") and enemy:GetPivot().Position or enemyPart.Position
                                local distance = (enemyPos - rootPart.Position).Magnitude
                                
                                if distance <= BrutalAttackRange then
                                    local vecStr = string.format("~v%.4f,%.4f,%.4f", enemyPos.X, enemyPos.Y, enemyPos.Z)
                                    pcall(function()
                                        -- Senjata Remote
                                        for _, wName in ipairs({"Harpoon", "Riptide"}) do
                                            CheckAndAttackAsync(wName, function(t) SafeRemoteFunction("ToolReplicator", "~s" .. wName, "~sHitEnemy", enemy) end)
                                        end
                                        CheckAndAttackAsync("Magma Staff", function(t) SafeRemoteFunction("ToolReplicator", "~sMagma Staff", "~sFire", vecStr) end)
                                        CheckAndAttackAsync("Squid Laser", function(t) SafeRemoteFunction("ToolReplicator", "~sLaser", "~sShoot", vecStr) end)
                                        CheckAndAttackAsync("Grenade", function(t) SafeRemoteFunction("ToolReplicator", "~sGrenade", "~sThrow", vecStr, vecStr) end)

                                        local gunTypes = {"Rifle", "Flintlock", "Blunderbuss", "Revolver", "Hand Cannon", "Boomstick", "DualPistols", "Assault Rifle"}
                                        for _, gunName in ipairs(gunTypes) do
                                            CheckAndAttackAsync(gunName, function(t)
                                                local firePart = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart") or rootPart
                                                if firePart then
                                                    local direction = (enemyPos - rootPart.Position).Unit
                                                    local gunFormatStr = string.format("~t{1=~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0}", enemyPos.X, enemyPos.Y, enemyPos.Z, direction.X, direction.Y, direction.Z)
                                                    SafeRemoteFunction("ToolReplicator", "~sGun", "~sShoot", firePart, gunFormatStr)
                                                end
                                            end)
                                        end

                                        -- Senjata Melee
                                        local meleeTypes = {"Machete", "Ghost Cutlass", "Poku Poku", "Swordfish Spear"} 
                                        for _, meleeName in ipairs(meleeTypes) do
                                            CheckAndAttackAsync(meleeName, function(t)
                                                local handle = t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart")
                                                if handle and enemyPart then
                                                    t:Activate()
                                                    if firetouchinterest then
                                                        firetouchinterest(handle, enemyPart, 0)
                                                        task.wait(0.01)
                                                        firetouchinterest(handle, enemyPart, 1)
                                                    end
                                                end
                                            end)
                                        end
                                    end)
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

Win:AddToggle("Auto Attack", true, function(state)
    AutoAttackEnabled = state
    if AutoAttackEnabled then RunAutoAttack() end
end)
RunAutoAttack()

-- ====================================================================
-- [FITUR 6]: AUTO PICK MATERIAL (BRUTAL ONLY)
-- ====================================================================
local AutoPickEnabled = false 

-- [FUNGSI]: Pengecekan Validasi Barang Khusus Material
local function IsItemValidToPick(folderObj, part)
    -- Jika barang sudah masuk Grinder/Mesin lain, langsung LEWATKAN!
    if folderObj:GetAttribute("RZY_Processed") then return false end
            
    local isGrabbed = folderObj:GetAttribute("Grabbed") or part:GetAttribute("Grabbed")
    if isGrabbed then return false end 
    
    -- Evaluasi Material
    local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
    if not resType then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
    
    local isTargetMaterial = false
    -- Pastikan TargetMaterials sudah didefinisikan sebelumnya di script Anda
    if resType and TargetMaterials and TargetMaterials[resType] then
        local isExcluded = false
        -- Abaikan jika barang tersebut adalah Armor
        for attrName, attrValue in pairs(folderObj:GetAttributes()) do
            local lowerName = string.lower(attrName)
            local lowerValue = type(attrValue) == "string" and string.lower(attrValue) or ""
            if string.find(lowerName, "armor") or string.find(lowerValue, "armor") or
               string.find(lowerName, "chest") or string.find(lowerValue, "chest") or
               string.find(lowerName, "leg") or string.find(lowerValue, "leg") then
                isExcluded = true
                break
            end
        end
        if not isExcluded then isTargetMaterial = true end
    end
    
    return isTargetMaterial
end

-- [UI & LOGIKA] Toggle Auto Pick
Win:AddToggle("Auto Pick Material", false, function(state)
    AutoPickEnabled = state
    
    if AutoPickEnabled then
        task.spawn(function()
            while AutoPickEnabled do
                local workspace = game:GetService("Workspace")
                local DebrisField = workspace:FindFirstChild("DebrisField")
                
                local character = LocalPlayer.Character
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChildWhichIsA("BasePart"))
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                
                if DebrisField and rootPart then
                    -- Tentukan alat penarik (Harpoon atau Riptide)
                    local pullTool = "Harpoon"
                    if (character and character:FindFirstChild("Riptide")) or (backpack and backpack:FindFirstChild("Riptide")) then
                        pullTool = "Riptide"
                    end
                    
                    -- ==============================================================
                    -- [LOGIKA BRUTAL]: AMBIL SEMUA BARANG TANPA BATAS JARAK
                    -- ==============================================================
                    for _, folderObj in ipairs(DebrisField:GetChildren()) do
                        if not AutoPickEnabled then break end -- Berhenti jika toggle dimatikan di tengah jalan
                        
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        
                        -- Langsung sikat jika valid, tanpa perlu kalkulasi jarak!
                        if part and IsItemValidToPick(folderObj, part) then
                            task.spawn(function()
                                pcall(function()
                                    local pos = part.Position
                                    local vecStr = string.format("~v%.4f,%.4f,%.4f", pos.X, pos.Y, pos.Z)
                                    SafeRemoteFunction("ToolReplicator", "~s" .. pullTool, "~sGrab", folderObj, vecStr)
                                end)
                            end)
                            
                            -- Jeda aman
                            task.wait(0.1) 
                        end
                    end
                    
                end
                task.wait(0.1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 7]: AUTO OPEN CHEST (DEFAULT AKTIF)
-- ====================================================================
local AutoChestEnabled = true

local function RunAutoChest()
    task.spawn(function()
        while AutoChestEnabled do
            local workspace = game:GetService("Workspace")
            local ChestsFolder = workspace:FindFirstChild("Chests")
            local IslandContainer = workspace:FindFirstChild("IslandContainer")
            
            local character = LocalPlayer.Character
            local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart"))
            
            if rootPart then
                local nearestChest = nil
                local shortestDistance = 15 
                local potentialChests = {}
                
                if ChestsFolder then
                    for _, chest in ipairs(ChestsFolder:GetChildren()) do table.insert(potentialChests, chest) end
                end
                
                if IslandContainer then
                    for _, island in ipairs(IslandContainer:GetChildren()) do
                        for _, item in ipairs(island:GetChildren()) do
                            if string.find(string.lower(item.Name), "chest") then table.insert(potentialChests, item) end
                        end
                    end
                end
                
                for _, chest in ipairs(potentialChests) do
                    local part = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local distance = (part.Position - rootPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance; nearestChest = chest
                        end
                    end
                end
                
                if nearestChest then pcall(function() SafeRemoteFunction("OpenChest", nearestChest) end) end
            end
            task.wait(0.1) 
        end
    end)
end

Win:AddToggle("Auto Open Chest", true, function(state)
    AutoChestEnabled = state
    if AutoChestEnabled then RunAutoChest() end
end)
RunAutoChest() -- EKSEKUSI OTOMATIS

-- ====================================================================
-- [FITUR 8]: AUTO FISHING (DEFAULT AKTIF)
-- ====================================================================
local AutoFishingEnabled = true

local function RunAutoFishing()
    task.spawn(function()
        while AutoFishingEnabled do
            local character = LocalPlayer.Character
            if character then
                local equippedTool = character:FindFirstChild("Fishing Rod")
                if equippedTool then
                    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
                    if rootPart then
                        local pos = rootPart.Position
                        local dir = rootPart.CFrame.LookVector
                        local vecStr = string.format("~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ0", pos.X, pos.Y + 1, pos.Z, dir.X, dir.Y, dir.Z)
                        
                        pcall(function()
                            SafeRemoteFunction("ToolReplicator", "~sFishing Rod", "~sCast")
                            SafeRemoteFunction("ToolReplicator", "~sFishing Rod", "~sFishPoof", vecStr)
                        end)
                    end
                end
            end
            task.wait(1) 
        end
    end)
end

Win:AddToggle("Auto Fishing", true, function(state)
    AutoFishingEnabled = state
    if AutoFishingEnabled then RunAutoFishing() end
end)
RunAutoFishing() -- EKSEKUSI OTOMATIS

-- ====================================================================
-- [FITUR 9]: AUTO STORE (DEFAULT AKTIF)
-- ====================================================================
local AutoStoreEnabled = true

local function RunAutoStore()
    task.spawn(function()
        local myId = tostring(LocalPlayer.UserId)
        local myName = LocalPlayer.Name
        
        while AutoStoreEnabled do
            local workspace = game:GetService("Workspace")
            local DebrisField = workspace:FindFirstChild("DebrisField")
            
            if DebrisField then
                for _, folderObj in ipairs(DebrisField:GetChildren()) do
                    if not AutoStoreEnabled then break end
                    if folderObj:GetAttribute("RZY_Processed") then continue end
                    
                    local isGrabbed = folderObj:GetAttribute("Grabbed")
                    if not isGrabbed then
                        local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                        if part then isGrabbed = part:GetAttribute("Grabbed") end
                    end
                    
                    if isGrabbed then
                        local grabber = tostring(folderObj:GetAttribute("Grabber"))
                        if grabber == "nil" then
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            if part then grabber = tostring(part:GetAttribute("Grabber")) end
                        end
                        
                        if grabber == myId or grabber == myName then
                            local resType = folderObj:GetAttribute("Resource") or folderObj:GetAttribute("Item")
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            
                            if not resType and part then resType = part:GetAttribute("Resource") or part:GetAttribute("Item") end
                            
                            if resType == "Wood" or resType == "Metal" then
                                if part then
                                    pcall(function()
                                        SafeRemoteEvent("StoreItem", part)
                                        folderObj:SetAttribute("RZY_Processed", true)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.5) 
        end
    end)
end

Win:AddToggle("Auto Store (Wood & Metal)", true, function(state)
    AutoStoreEnabled = state
    if AutoStoreEnabled then RunAutoStore() end
end)
RunAutoStore() -- EKSEKUSI OTOMATIS

-- ====================================================================
-- [FITUR 10]: AUTO DISCOVER ISLANDS (SKY DROP & STAY + EXCLUSION)
-- ====================================================================
local AutoDiscoverEnabled = false
local DiscoveredIslands = {} -- Tabel memori agar pulau yang sudah dikunjungi tidak di-TP lagi

-- Daftar kata kunci pulau yang TIDAK BOLEH dikunjungi
local ExcludedIslandKeywords = {
    "RivalRig1", 
    "RivalRig2", 
    "RivalRig3", 
    "GhostGalleon", 
    "SquidIsland"
}

Win:AddToggle("Auto Discover Island", false, function(state)
    AutoDiscoverEnabled = state
    
    if AutoDiscoverEnabled then
        task.spawn(function()
            while AutoDiscoverEnabled do
                pcall(function()
                    local char = LocalPlayer.Character
                    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart"))
                    local container = workspace:FindFirstChild("IslandContainer")
                    
                    if root and container then
                        -- 1. Cari semua pulau yang belum pernah kita kunjungi
                        local pendingIslands = {}
                        for _, island in ipairs(container:GetChildren()) do
                            local isExcluded = false
                            
                            -- Pengecekan nama pulau terhadap daftar blacklist
                            for _, keyword in ipairs(ExcludedIslandKeywords) do
                                if string.find(island.Name, keyword) then
                                    isExcluded = true
                                    break
                                end
                            end
                            
                            -- Jika pulau belum dikunjungi dan BUKAN pulau yang dilarang
                            if not DiscoveredIslands[island] and not isExcluded then
                                table.insert(pendingIslands, island)
                            end
                        end
                        
                        -- 2. Jika ada pulau baru yang belum dikunjungi, eksekusi!
                        if #pendingIslands > 0 then
                            for _, island in ipairs(pendingIslands) do
                                -- Pengaman: Berhenti jika toggle dimatikan di tengah jalan
                                if not AutoDiscoverEnabled or not root.Parent then return end
                                
                                -- AMAN DARI NYANGKUT: Mengambil titik tengah pulau, lalu ditambah ketinggian 50 stud ke atas
                                local targetCFrame = island:GetPivot()
                                root.CFrame = targetCFrame * CFrame.new(0, 50, 0)
                                
                                -- JEDA: Diam 1 detik (Ada waktu jatuh dari langit dan server membaca "Discovered")
                                task.wait(2) 
                                
                                -- TANDAI: Masukkan pulau ini ke tabel agar tidak di-TP lagi
                                DiscoveredIslands[island] = true
                            end
                        end
                    end
                end)
                
                -- Jeda santai mengecek folder IslandContainer setiap 1 detik
                task.wait(1) 
            end
        end)
    end
end)

-- ====================================================================
-- [FITUR 11]: UNIVERSAL FLY (UPGRADED: SAFE CUTSCENE, NOCLIP & FIXCAM)
-- ====================================================================
local UniversalFlyEnabled = true 
local UniversalFlySpeed = 200

Win:AddInput("Fly Speed (Universal)", "200", function(val)
    local num = tonumber(val)
    if num then
        UniversalFlySpeed = num
    end
end)

local UFlyConnection
local currentMoverTarget = nil
local currentBG = nil
local currentBV = nil

-- Fungsi untuk membersihkan efek terbang secara bersih
local function ClearFlyMovers()
    if currentBG then currentBG:Destroy(); currentBG = nil end
    if currentBV then currentBV:Destroy(); currentBV = nil end
    currentMoverTarget = nil
    
    pcall(function()
        local char = game:GetService("Players").LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.PlatformStand = false 
        end
    end)
end

local function StopUniversalFly()
    UniversalFlyEnabled = false
    if UFlyConnection then
        UFlyConnection:Disconnect()
        UFlyConnection = nil
    end
    ClearFlyMovers()
end

-- Fungsi FixCam
local function ApplyFixCam(humanoid)
    task.spawn(function()
        task.wait(0.15) 
        local camera = workspace.CurrentCamera
        if camera and humanoid then
            camera.CameraType = Enum.CameraType.Custom
            camera.CameraSubject = humanoid
        end
    end)
end

-- Fungsi Utama Terbang
local function StartUniversalFly()
    if UFlyConnection then return end 
    
    local runService = game:GetService("RunService")
    local uis = game:GetService("UserInputService")
    
    UFlyConnection = runService.Stepped:Connect(function()
        if not UniversalFlyEnabled then
            StopUniversalFly()
            return
        end

        local player = game:GetService("Players").LocalPlayer
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local rootPart = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart"))
        local camera = workspace.CurrentCamera
        
        -- Hentikan jika karakter tidak valid atau mati
        if not humanoid or not rootPart or humanoid.Health <= 0 then return end
        
        -- =========================================================
        -- [ANTI-KICK 260 CUTSCENE DETECTOR]
        -- Jika server mengunci (Anchor) karakter untuk memutar video, 
        -- hentikan paksaan fisika agar server tidak mengira kita eksploitasi.
        -- =========================================================
        if rootPart.Anchored then
            if currentBV then currentBV.velocity = Vector3.new(0, 0, 0) end
            return -- Abaikan baris di bawahnya sampai cutscene selesai
        end
        
        -- [INTEGRASI NOCLIP]: Mengubah semua part tubuh menjadi tembus pandang/tembok
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
        
        -- [SMART DETECT]
        local expectedTarget = humanoid.SeatPart or rootPart
        local isVehicle = (expectedTarget ~= rootPart)
        
        -- Transisi Penggerak
        if currentMoverTarget ~= expectedTarget then
            local wasVehicle = (currentMoverTarget and (currentMoverTarget:IsA("VehicleSeat") or currentMoverTarget:IsA("Seat")))
            
            ClearFlyMovers()
            currentMoverTarget = expectedTarget
            
            -- [ANTI STUCK/NEMPEL BUG]
            if wasVehicle and not isVehicle then
                humanoid.Sit = false
                rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.05) 
            end
            
            if isVehicle then
                ApplyFixCam(humanoid)
            end
            
            currentBG = Instance.new("BodyGyro")
            currentBG.P = 9e4
            currentBG.maxTorque = isVehicle and Vector3.new(1e5, 1e5, 1e5) or Vector3.new(9e9, 9e9, 9e9) 
            currentBG.cframe = expectedTarget.CFrame
            currentBG.Parent = expectedTarget

            currentBV = Instance.new("BodyVelocity")
            currentBV.velocity = Vector3.new(0, 0, 0)
            currentBV.maxForce = Vector3.new(9e9, 9e9, 9e9)
            currentBV.Parent = expectedTarget
        end
        
        humanoid.PlatformStand = not isVehicle

        local moveDir = Vector3.new(0, 0, 0)

        -- [LOGIKA UNIVERSAL + DEADZONE]
        local moveMagnitude = humanoid.MoveDirection.Magnitude
        if moveMagnitude > 0.1 then
            local localMove = camera.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
            
            if localMove.Z < -0.1 or localMove.Z > 0.1 then
                moveDir = moveDir + (camera.CFrame.LookVector * -localMove.Z)
            end
            if localMove.X > 0.1 or localMove.X < -0.1 then
                moveDir = moveDir + (camera.CFrame.RightVector * localMove.X)
            end
        end

        -- KONTROL PC
        if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        -- Eksekusi
        if currentBG and currentBV then
            currentBG.cframe = camera.CFrame
            
            if moveDir.Magnitude > 0 then
                currentBV.velocity = moveDir.Unit * UniversalFlySpeed
            else
                currentBV.velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end

Win:AddToggle("Universal Fly", true, function(state)
    UniversalFlyEnabled = state
    if UniversalFlyEnabled then
        StartUniversalFly()
    else
        StopUniversalFly()
    end
end)

StartUniversalFly()

-- ====================================================================
-- [FITUR 12]: AUTO DISMANTLE ALL (BRUTAL + EXCEPTIONS)
-- ====================================================================
local AutoDismantleEnabled = false

-- Daftar bangunan yang tidak boleh dihancurkan
local DismantleExceptions = {
    ["Small Shelter"] = true,
    ["Container Shelter"] = true,
    ["Makeshift Building"] = true,
    ["Outpost"] = true
}

local function RunAutoDismantle()
    task.spawn(function()
        while AutoDismantleEnabled do
            pcall(function()
                local spawnIsland = workspace:FindFirstChild("SpawnIsland")
                local craftedFolder = spawnIsland and spawnIsland:FindFirstChild("Crafted")
                
                if craftedFolder then
                    for _, item in ipairs(craftedFolder:GetChildren()) do
                        if not AutoDismantleEnabled then break end 
                        
                        -- Pengecekan Pengecualian: Cek apakah nama bangunan ada di daftar aman
                        local isExcluded = false
                        for exName, _ in pairs(DismantleExceptions) do
                            if string.find(item.Name, exName) then
                                isExcluded = true
                                break
                            end
                        end
                        
                        -- Hanya hancurkan jika punya ":" (buatan pemain) dan BUKAN termasuk pengecualian
                        if string.find(item.Name, ":") and not isExcluded then
                            local targetString = "~s" .. item.Name
                            
                            -- [BRUTAL MODE]: Eksekusi serentak menggunakan task.spawn
                            task.spawn(function()
                                pcall(function()
                                    SafeRemoteFunction("ToolReplicator", "~sWrench", "~sTeardown", targetString)
                                end)
                            end)
                            
                            -- Delay sangat kecil agar tidak terdeteksi spam berlebih (Anti-Kick)
                            task.wait(0.01) 
                        end
                    end
                end
            end)
            
            task.wait(1) 
        end
    end)
end

Win:AddToggle("Auto Dismantle All", false, function(state)
    AutoDismantleEnabled = state
    if AutoDismantleEnabled then
        RunAutoDismantle()
    end
end)

-- ====================================================================
-- [FITUR 14]: AUTO HEAL (BANDAGE) - AUTO EQUIP & RESTORE TOOL
-- ====================================================================
local AutoHealEnabled = true

local function RunAutoHeal()
    task.spawn(function()
        while AutoHealEnabled do
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                local humanoid = character and character:FindFirstChild("Humanoid")
                local backpack = player:FindFirstChild("Backpack")
                
                -- Pastikan karakter hidup dan humanoid ada
                if humanoid and humanoid.Health > 0 and humanoid.Health <= 70 then
                    
                    -- [LANGKAH 1]: Mengingat apa yang sedang Anda pegang saat ini
                    local currentTool = character:FindFirstChildWhichIsA("Tool")
                    local previousToolName = currentTool and currentTool.Name or nil
                    
                    -- [LANGKAH 2]: Mencari Bandage di inventory (Backpack atau Character)
                    local bandage = (backpack and backpack:FindFirstChild("Bandage")) or character:FindFirstChild("Bandage")
                    
                    if bandage then
                        -- Paksa karakter memegang Bandage
                        humanoid:EquipTool(bandage)
                        task.wait(0.05) -- Jeda sangat singkat agar server mendaftarkan pergantian tool
                        
                        -- [LANGKAH 3]: Proses Heal sampai penuh
                        while AutoHealEnabled and humanoid and humanoid.Health < humanoid.MaxHealth and humanoid.Health > 0 do
                            
                            -- Mencegah bug jika Anda tidak sengaja mengganti senjata di tengah proses healing
                            if not character:FindFirstChild("Bandage") then
                                humanoid:EquipTool(bandage)
                            end
                            
                            -- Memanggil fungsi remote Bandage
                            SafeRemoteFunction("ToolReplicator", "~sBandage", "~sHeal")
                            
                            task.wait(0.05) 
                        end
                        
                        -- [LANGKAH 4]: Kembalikan ke tool sebelumnya (atau kosongkan tangan)
                        if previousToolName then
                            -- Jika sebelumnya memang pegang Bandage, biarkan saja.
                            -- Tapi jika pegang yang lain (misal: Melee/Pistol), panggil kembali tool tersebut.
                            if previousToolName ~= "Bandage" then
                                local toolToEquip = (backpack and backpack:FindFirstChild(previousToolName)) or character:FindFirstChild(previousToolName)
                                if toolToEquip then
                                    humanoid:EquipTool(toolToEquip)
                                end
                            end
                        else
                            -- Jika sebelumnya tangan Anda kosong, maka kosongkan kembali tangannya
                            humanoid:UnequipTools()
                        end
                        
                    end
                end
            end)
            
            -- Jeda 1 detik sebelum mengecek darah lagi (menghemat CPU)
            task.wait(0.5) 
        end
    end)
end

Win:AddToggle("Auto Heal (<= 70 to 100)", true, function(state)
    AutoHealEnabled = state
    if AutoHealEnabled then
        RunAutoHeal()
    end
end)

-- Langsung dijalankan karena defaultnya "true"
RunAutoHeal()

-- ====================================================================
-- [FITUR 15]: ALL ISLAND & RIG ESP (SUPER LIGHTWEIGHT / ANTI-LAG)
-- ====================================================================
local IslandESPEnabled = true 
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Konfigurasi ESP (Radar Island sudah dihapus)
local IslandConfig = {
    ["RivalRig1"] = {Text = "Rival Rig 1", Color = Color3.fromRGB(255, 65, 65)},
    ["RivalRig2"] = {Text = "Rival Rig 2", Color = Color3.fromRGB(255, 65, 65)},
    ["RivalRig3"] = {Text = "Rival Rig 3", Color = Color3.fromRGB(255, 65, 65)},
    
    ["CageIsland"] = {Text = "Cage Island (Survivor)", Color = Color3.fromRGB(50, 255, 50)},
    ["TrappedIsland"] = {Text = "Trapped Island (Survivor)", Color = Color3.fromRGB(50, 255, 50)},
    ["PirateChallengeIsland"] = {Text = "Pirate Challenge Island", Color = Color3.fromRGB(50, 255, 50)},
    
    ["SkullIsland"] = {Text = "Skull Island (Green Key)", Color = Color3.fromRGB(255, 255, 0)},
    ["ShantyIsland"] = {Text = "Shanty Island", Color = Color3.fromRGB(255, 200, 0)},
    ["TempleIsland"] = {Text = "Temple Island", Color = Color3.fromRGB(255, 200, 0)},
    ["PirateStronghold"] = {Text = "Pirate Stronghold", Color = Color3.fromRGB(255, 30, 30)},
    
    ["SquidIslandMain"] = {Text = "Squid Island Main", Color = Color3.fromRGB(200, 50, 255)}
}

-- [FUNGSI]: Pembersih Total saat toggle mati
local function CleanAllIslandESP()
    local islandContainer = workspace:FindFirstChild("IslandContainer")
    if islandContainer then
        for _, child in ipairs(islandContainer:GetDescendants()) do
            if child.Name == "IslandESP_Gui" then child:Destroy() end
        end
    end
end

-- [FUNGSI UTAMA]: Scanner Pulau & Rig Terpusat (Anti-Lag)
local function StartIslandScanner()
    task.spawn(function()
        while IslandESPEnabled do
            pcall(function()
                local islandContainer = workspace:FindFirstChild("IslandContainer")
                local character = LocalPlayer.Character
                local root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso"))
                
                if islandContainer then
                    for _, child in ipairs(islandContainer:GetChildren()) do
                        if not IslandESPEnabled then break end
                        
                        local config = IslandConfig[child.Name]
                        local displayName, displayColor = nil, nil
                        
                        -- Cek daftar pulau statis
                        if config then
                            displayName = config.Text
                            displayColor = config.Color
                            
                        -- Cek Squid Island Dinamis
                        elseif string.find(child.Name, "^SquidIsland") and child.Name ~= "SquidIslandMain" then
                            local islandNum = string.match(child.Name, "%d+") or ""
                            displayName = "Squid Island " .. islandNum
                            displayColor = Color3.fromRGB(230, 130, 255) 
                        end
                        
                        -- Jika masuk daftar, pasang atau perbarui ESP
                        if displayName and displayColor then
                            -- Cari titik tumpu (part) pulau
                            local targetPart = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart")
                            if not targetPart and child:IsA("Model") and child.PrimaryPart then targetPart = child.PrimaryPart end
                            if not targetPart then targetPart = child:FindFirstChildWhichIsA("BasePart", true) end
                            
                            if targetPart then
                                -- Periksa apakah GUI sudah dibuat sebelumnya
                                local espGui = targetPart:FindFirstChild("IslandESP_Gui")
                                
                                -- Buat GUI baru jika belum ada
                                if not espGui then
                                    espGui = Instance.new("BillboardGui")
                                    espGui.Name = "IslandESP_Gui"
                                    espGui.AlwaysOnTop = true
                                    espGui.Size = UDim2.new(0, 200, 0, 40)
                                    espGui.StudsOffset = Vector3.new(0, 20, 0) 
                                    espGui.Adornee = targetPart
                                    espGui.Parent = targetPart
                                    
                                    local textLabel = Instance.new("TextLabel")
                                    textLabel.Name = "DistanceText" -- Dinamai agar mudah di-update
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.TextColor3 = displayColor
                                    textLabel.TextSize = 13 
                                    textLabel.Font = Enum.Font.SourceSans 
                                    textLabel.TextStrokeTransparency = 0.3 
                                    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                    textLabel.Parent = espGui
                                end
                                
                                -- UPDATE JARAK (Eksekusi 1 pintu)
                                local textLabel = espGui:FindFirstChild("DistanceText")
                                if textLabel and root then
                                    local distance = (targetPart.Position - root.Position).Magnitude
                                    textLabel.Text = string.format("%s [%dm]", displayName, math.floor(distance))
                                end
                            end
                        end
                    end
                end
            end)
            -- Jeda 1 detik. Semua kalkulasi puluhan pulau selesai dalam sekejap tanpa memberatkan memori
            task.wait(1) 
        end
    end)
end

-- [UI TOGGLE]
Win:AddToggle("Island & Rig ESP", true, function(state)
    IslandESPEnabled = state
    if IslandESPEnabled then
        StartIslandScanner()
    else
        CleanAllIslandESP()
    end
end)

-- LANGSUNG EKSEKUSI KARENA DEFAULT AKTIF
StartIslandScanner()

-- ====================================================================
-- [FITUR 16]: SOFT ANTI-LAG (WATER & DEBRIS OPTIMIZER)
-- ====================================================================
local SoftAntiLagEnabled = true

Win:AddToggle("Soft Anti-Lag (Sea & Debris)", true, function(state)
    SoftAntiLagEnabled = state
    
    if SoftAntiLagEnabled then
        task.spawn(function()
            local workspace = game:GetService("Workspace")
            local terrain = workspace.Terrain
            local Lighting = game:GetService("Lighting")
            
            while SoftAntiLagEnabled do
                pcall(function()
                    -- [OPTIMASI LAUT]: Mematikan gelombang dan pantulan cahaya laut
                    -- Ini adalah sumber lag terbesar di game bertema lautan
                    if terrain then
                        terrain.WaterWaveSize = 0
                        terrain.WaterWaveSpeed = 0
                        terrain.WaterReflectance = 0
                    end
                    
                    -- [OPTIMASI PENCAHAYAAN GLOBAL]: Kurangi pantulan silau
                    Lighting.GlobalShadows = false -- Mematikan bayangan global (Sangat ampuh menaikkan FPS)
                    Lighting.EnvironmentDiffuseScale = 0
                    Lighting.EnvironmentSpecularScale = 0
                    
                    -- [OPTIMASI DEBRIS]: Matikan bayangan pada ratusan barang yang mengapung
                    local DebrisField = workspace:FindFirstChild("DebrisField")
                    if DebrisField then
                        for _, folderObj in ipairs(DebrisField:GetChildren()) do
                            -- Pengecekan agar tidak membebani CPU, hanya memproses beberapa part
                            local part = folderObj:FindFirstChildWhichIsA("BasePart") or folderObj:FindFirstChildWhichIsA("MeshPart")
                            if part and part.CastShadow then
                                part.CastShadow = false
                            end
                        end
                    end
                end)
                
                -- Jeda 5 detik: Sangat ramah CPU karena tidak perlu di-scan setiap saat
                task.wait(5)
            end
        end)
    else
        -- Jika dimatikan, kembalikan ke settingan normal/standar Roblox
        pcall(function()
            local terrain = game:GetService("Workspace").Terrain
            if terrain then
                terrain.WaterWaveSize = 0.15
                terrain.WaterWaveSpeed = 10
                terrain.WaterReflectance = 1
            end
            game:GetService("Lighting").GlobalShadows = true
        end)
    end
end)

-- ====================================================================
-- [FITUR: AUTO VISIBLE HUD COMPONENTS (LANGSUNG AKTIF SEKALI JALAN)]
-- ====================================================================
task.spawn(function()
    local Player = game:GetService("Players").LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    pcall(function()
        -- Menunggu HUD utama dan Features UI terbentuk (maksimal 10 detik)
        local HUD = PlayerGui:WaitForChild("HUD", 10)
        local FeaturesUI = HUD and HUD:WaitForChild("Features", 10)
        
        if FeaturesUI then
            -- Ubah status visible menjadi true hanya sekali jalan
            FeaturesUI.Visible = true
            
            local mapUI = FeaturesUI:WaitForChild("Map", 5)
            if mapUI then mapUI.Visible = true end
            
            local timerUI = FeaturesUI:WaitForChild("Timer", 5)
            if timerUI then timerUI.Visible = true end
        end
    end)
end)

-- ====================================================================
-- [FITUR: AUTO CLAIM ITEM DI FOLDER EFFECTS (OPTIMIZED & SAFE CUTSCENE)]
-- ====================================================================
local AutoClaimEffectsEnabled = false
local LocalPlayer = game:GetService("Players").LocalPlayer

local function RunAutoClaimEffects()
    task.spawn(function()
        while AutoClaimEffectsEnabled do
            pcall(function()
                local workspace = game:GetService("Workspace")
                local effectsFolder = workspace:FindFirstChild("Effects")
                local character = LocalPlayer.Character
                local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso"))
                
                if effectsFolder and rootPart then
                    -- 1. Hanya mengecek anak folder di permukaan
                    for _, folderObj in ipairs(effectsFolder:GetChildren()) do
                        
                        -- Berhenti jika toggle dimatikan di tengah jalan
                        if not AutoClaimEffectsEnabled then break end 
                        
                        -- 2. Memeriksa apakah nama folder HANYA terdiri dari angka (ID acak)
                        if tonumber(folderObj.Name) ~= nil then
                            
                            -- 3. Baru kita cari ProximityPrompt di dalam folder angka tersebut
                            for _, obj in ipairs(folderObj:GetDescendants()) do
                                
                                -- Pengaman tambahan jika toggle dimatikan
                                if not AutoClaimEffectsEnabled then break end
                                
                                if obj:IsA("ProximityPrompt") and obj.Enabled then
                                    
                                    -- Mencari lokasi part dari prompt tersebut
                                    local promptPart = obj.Parent
                                    if promptPart and promptPart:IsA("BasePart") then
                                        
                                        -- 4. [PENCEGAH KICK 260 SAAT CUTSCENE]: Cek Jarak!
                                        -- Jangan paksa ambil jika jaraknya lebih dari 25 studs (terlalu jauh)
                                        local distance = (promptPart.Position - rootPart.Position).Magnitude
                                        
                                        if distance <= 25 then
                                            -- Eksekusi aman
                                            if fireproximityprompt then
                                                fireproximityprompt(obj, 1, 0)
                                            end
                                            
                                            -- Jeda santai agar server tidak kaget
                                            task.wait(1.5)
                                        end
                                        
                                    end
                                end
                            end
                            
                        end
                    end
                end
            end)
            
            -- Jeda istirahat pencarian setiap 2 detik (Sangat ringan)
            task.wait(2) 
        end
    end)
end

-- [UI] Toggle Auto Claim Effects
Win:AddToggle("Auto Claim Effects", false, function(state)
    AutoClaimEffectsEnabled = state
    if AutoClaimEffectsEnabled then
        RunAutoClaimEffects()
    end
end)

-- ====================================================================
-- [FITUR]: AUTO NO-FOG (SANTAI / LIGHTWEIGHT)
-- ====================================================================
local AutoNoFogEnabled = false

local function RunAutoNoFog()
    task.spawn(function()
        local Lighting = game:GetService("Lighting")
        
        while AutoNoFogEnabled do
            pcall(function()
                -- 1. Hapus kabut klasik (FogEnd dijauhkan ke ujung dunia)
                Lighting.FogEnd = 9e9
                Lighting.FogStart = 9e9
                
                -- 2. Hapus kabut modern (Atmosphere) yang biasa dipakai saat event/hujan
                local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                if atmosphere then
                    atmosphere.Density = 0
                    atmosphere.Glare = 0
                    atmosphere.Haze = 0
                end
            end)
            
            -- Jeda 3 detik: Sangat santai, CPU tidak akan panas sama sekali
            task.wait(3)
        end
    end)
end

-- [UI] Toggle Auto No-Fog
Win:AddToggle("Auto No-Fog", false, function(state)
    AutoNoFogEnabled = state
    if AutoNoFogEnabled then
        RunAutoNoFog()
    end
end)

-- ====================== END OF DYHUB 100 DAYS AT SEA ======================
