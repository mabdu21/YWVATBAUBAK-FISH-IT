-- =========================
local version = "BETA"
local ver     = "v021.13"
-- =========================

repeat task.wait() until game:IsLoaded()

-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

if setfpscap then
    pcall(function() setfpscap(1000) end)
    WindUI:Notify({ Title = "Service", Content = "FPS Unlocked | " .. ver, Duration = 3, Icon = "cpu" })
else
    WindUI:Notify({ Title = "Service", Content = "setfpscap not supported by your executor.", Duration = 3, Icon = "ban" })
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

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = Workspace.CurrentCamera

-- ====================== REMOTES ======================
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local bustStart     = remotesFolder:WaitForChild("AttemptATMBustStart")
local bustEnd       = remotesFolder:WaitForChild("AttemptATMBustComplete")
local RemoteStart   = remotesFolder:WaitForChild("RequestStartJobSession")
local RemoteEnd     = remotesFolder:WaitForChild("RequestEndJobSession")

-- ====================== GLOBAL STATE ======================
local State = {
    SpeedEnabled      = false,
    SpeedMode         = "Legit",
    SpeedValue        = 16,
    FlyEnabled        = false,
    FlySpeed          = 50,
    NoclipEnabled     = false,
    InfJumpEnabled    = false,
    JumpPowerEnabled  = false,
    JumpPowerValue    = 50,
    InstantPromptOn   = false,
    AntiAfkEnabled    = false,
    BypassActive      = false,
    RainbowEnabled    = false,
    PhysicsEnabled    = false,
    AccelPower        = 0,
    BrakeForce        = 0,
    SelectedPlayer    = nil,

    ATMStatus         = "Idle",
    ATMBags           = "0 / 25",
    DeliveryStatus    = "Idle",
}

_G.ESP_Enabled  = false
_G.ESP_Targets  = { Players = true, Police = true, Criminals = true }
_G.ESP_Settings = { Boxes = false, Tracers = false, Skeletons = false, Names = false, Distance = false, Thickness = 1 }
_G.ESP_Colors   = {
    Police   = Color3.fromRGB(0, 0, 255),
    Criminal = Color3.fromRGB(255, 0, 0),
    Neutral  = Color3.fromRGB(0, 255, 0),
}

-- ====================== CONNECTIONS STORAGE ======================
local Connections = {
    Fly        = nil,
    Noclip     = nil,
    AntiAfk    = nil,
    Speed      = nil,
    PromptScan = nil,
    Delivery   = nil,
}

-- ====================== HELPER FUNCTIONS ======================
local function GetMyVehicle()
    local folder = Workspace:FindFirstChild("Vehicles")
    if not folder then return nil end
    for _, veh in pairs(folder:GetChildren()) do
        local owner = veh:FindFirstChild("Owner")
        if owner and owner.Value == LocalPlayer.Name then
            return veh
        end
    end
    return nil
end

local function getPlayerNames()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    table.sort(names)
    return names
end

local function ExecuteServerHop()
    local qot = syn and syn.queue_on_teleport or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(function()
            qot([[
                repeat task.wait() until game:IsLoaded()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/xxCichyxx/rbxscripts/refs/heads/main/DrivingEmpireXeno.lua"))()
            ]])
        end)
    end

    WindUI:Notify({ Title = "Server Hop", Content = "Searching for another server.", Duration = 2, Icon = "server" })

    local success = false
    local attempts = 0
    while not success and attempts < 5 do
        attempts = attempts + 1
        local ok, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        end)

        if ok and response and response.data then
            local candidates = {}
            for _, server in pairs(response.data) do
                if server.id ~= game.JobId and tonumber(server.playing) < tonumber(server.maxPlayers) then
                    table.insert(candidates, server)
                end
            end
            table.sort(candidates, function(a, b) return a.playing < b.playing end)
            if #candidates > 0 then
                local range = math.min(5, #candidates)
                local target = candidates[math.random(1, range)]
                local hopOk = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer)
                end)
                if hopOk then success = true end
            end
        end
        if not success then task.wait(1.5) end
    end

    if not success then
        WindUI:Notify({ Title = "Server Hop", Content = "Failed to find a suitable server.", Duration = 3, Icon = "alert-triangle" })
    end
end

-- ====================== CONFIG SYSTEM ======================
local ConfigFolder = "DYHUB_DE"
local ConfigPath   = ConfigFolder .. "/de_config.json"

local Config = {}
Config.__index = Config

function Config.new()
    local self = setmetatable({}, Config)
    self.data = {}
    self.autoSaveThread = nil
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    self:Load()
    return self
end

function Config:Set(k, v) self.data[k] = v end
function Config:Get(k, d)
    local v = self.data[k]
    if v == nil then return d end
    return v
end

function Config:Save()
    pcall(function()
        writefile(ConfigPath, HttpService:JSONEncode(self.data))
    end)
end

function Config:Load()
    if isfile(ConfigPath) then
        local ok, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigPath))
        end)
        if ok and type(result) == "table" then
            self.data = result
        end
    end
end

function Config:AutoSave(interval)
    if self.autoSaveThread then
        task.cancel(self.autoSaveThread)
        self.autoSaveThread = nil
    end
    if interval and interval > 0 then
        self.autoSaveThread = task.spawn(function()
            while true do
                task.wait(interval)
                self:Save()
            end
        end)
    end
end

local Config = Config.new()
Config:AutoSave(Config:Get("AutoSaveDelay", 15))

-- ====================== WINDOW ======================
local Window = WindUI:CreateWindow({
    Title      = "DYHUB",
    IconThemed = true,
    Icon       = "rbxassetid://104487529937663",
    Author     = "Driving Empire | Paid Version",
    Folder     = "DYHUB_DE",
    Size       = UDim2.fromOffset(560, 420),
    Theme      = "Dark",
    BackgroundImageTransparency = 0.8,
    HideSearchBar    = false,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.K)
pcall(function() Window:Tag({ Title = version, Color = Color3.fromHex("#db7093") }) end)
pcall(function()
    Window:EditOpenButton({
        Title           = "DYHUB - Open",
        Icon            = "monitor",
        CornerRadius    = UDim.new(0, 6),
        StrokeThickness = 2,
        Color           = ColorSequence.new(Color3.fromRGB(30,30,30), Color3.fromRGB(255,255,255)),
        Draggable       = true,
    })
end)

-- ====================== TABS ======================
local InfoTab     = Window:Tab({ Title = "Information", Icon = "info" })
Window:Divder()
local MainTab     = Window:Tab({ Title = "Main",        Icon = "rocket" })
local EspTab      = Window:Tab({ Title = "ESP",         Icon = "eye" })
local PlayerTab   = Window:Tab({ Title = "Player",      Icon = "user" })
local CollectTab  = Window:Tab({ Title = "Collect",     Icon = "package" })
Window:Divder()
local SettingsTab = Window:Tab({ Title = "Settings",    Icon = "settings" })

Window:SelectTab(1)

-- =========================================================================
--  MAIN TAB
-- =========================================================================
do
    MainTab:Divder()
    MainTab:Section({ Title = "Current Status", Icon = "activity" })

    local JobStatus     = MainTab:Paragraph({ Title = "Current Job",      Desc = "Loading" })
    local VehicleModel  = MainTab:Paragraph({ Title = "Vehicle Model",    Desc = "No Active Vehicle" })
    local VehicleSpeed  = MainTab:Paragraph({ Title = "Vehicle Speed",    Desc = "0 SPS" })
    local VehicleParts  = MainTab:Paragraph({ Title = "Parts Detected",   Desc = "0" })
    local VehicleState  = MainTab:Paragraph({ Title = "Vehicle Status",   Desc = "On Foot" })
    MainTab:Divder()
    MainTab:Section({ Title = "Job System", Icon = "briefcase" })

    MainTab:Button({
        Title    = "Join or Leave Police",
        Desc     = "Toggles the Security job on or off.",
        Callback = function()
            local current = LocalPlayer:GetAttribute("JobId")
            if current == "Security" then
                pcall(function() RemoteEnd:FireServer("jobPad") end)
                WindUI:Notify({ Title = "Job", Content = "Left Security.", Duration = 2, Icon = "shield-off" })
            else
                pcall(function() RemoteStart:FireServer("Security", "jobPad") end)
                WindUI:Notify({ Title = "Job", Content = "Joined Security.", Duration = 2, Icon = "shield" })
            end
        end
    })

    MainTab:Button({
        Title    = "Join or Leave Criminal",
        Desc     = "Toggles the Criminal job on or off.",
        Callback = function()
            local current = LocalPlayer:GetAttribute("JobId")
            if current == "Criminal" then
                pcall(function() RemoteEnd:FireServer("jobPad") end)
                WindUI:Notify({ Title = "Job", Content = "Left Criminal.", Duration = 2, Icon = "user-x" })
            else
                pcall(function() RemoteStart:FireServer("Criminal", "jobPad") end)
                WindUI:Notify({ Title = "Job", Content = "Joined Criminal.", Duration = 2, Icon = "user" })
            end
        end
    })

    MainTab:Button({
        Title    = "Join or Leave Delivery",
        Desc     = "Toggles the Delivery job on or off.",
        Callback = function()
            local current = LocalPlayer:GetAttribute("JobId")
            if current == "Delivery" then
                pcall(function() RemoteEnd:FireServer("jobPad") end)
                WindUI:Notify({ Title = "Job", Content = "Left Delivery.", Duration = 2, Icon = "truck" })
            else
                pcall(function() RemoteStart:FireServer("Delivery", "jobPad") end)
                WindUI:Notify({ Title = "Job", Content = "Joined Delivery.", Duration = 2, Icon = "truck" })
            end
        end
    })
    MainTab:Divder()
    MainTab:Section({ Title = "Vehicle Mods", Icon = "car" })

    local originalColors = {}
    local lastVehicleRef = nil

    MainTab:Toggle({
        Title    = "Vehicle RGB",
        Desc     = "Applies a rainbow color effect to your vehicle.",
        Value    = State.RainbowEnabled,
        Callback = function(v)
            State.RainbowEnabled = v
            Config:Set("Rainbow", v)
            if not v then
                for part, color in pairs(originalColors) do
                    pcall(function() if part and part.Parent then part.Color = color end end)
                end
                table.clear(originalColors)
                lastVehicleRef = nil
            end
            WindUI:Notify({ Title = "Vehicle RGB", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = "palette" })
        end
    })

    MainTab:Toggle({
        Title    = "Custom Physics Modifier",
        Desc     = "Enables manual acceleration and braking boost for your vehicle.",
        Value    = State.PhysicsEnabled,
        Callback = function(v)
            State.PhysicsEnabled = v
            Config:Set("Physics", v)
            WindUI:Notify({ Title = "Physics", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = "gauge" })
        end
    })

    MainTab:Slider({
        Title    = "Acceleration Power",
        Desc     = "Higher value means stronger boost when pressing forward or reverse.",
        Value    = { Min = 0, Max = 5000, Default = State.AccelPower },
        Step     = 1,
        Callback = function(v)
            State.AccelPower = v
            Config:Set("AccelPower", v)
        end
    })

    MainTab:Slider({
        Title    = "Brake Force",
        Desc     = "Higher value means stronger braking when counter-throttling.",
        Value    = { Min = 0, Max = 1500, Default = State.BrakeForce },
        Step     = 1,
        Callback = function(v)
            State.BrakeForce = v
            Config:Set("BrakeForce", v)
        end
    })

    -- Vehicle Info Loop
    task.spawn(function()
        local hue = 0
        while task.wait(0.1) do
            local myVeh = GetMyVehicle()

            -- Vehicle change detected -> reset original colors
            if myVeh ~= lastVehicleRef then
                for part, color in pairs(originalColors) do
                    pcall(function() if part and part.Parent then part.Color = color end end)
                end
                table.clear(originalColors)
                lastVehicleRef = myVeh
            end

            if State.RainbowEnabled and myVeh then
                hue = (hue + 1) % 360
                local rainbowColor = Color3.fromHSV(hue / 360, 0.9, 1)
                for _, obj in pairs(myVeh:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        if not originalColors[obj] then originalColors[obj] = obj.Color end
                        obj.Color = rainbowColor
                    end
                end
            end

            if myVeh then
                local carType   = myVeh:FindFirstChild("CarType")
                local driver    = myVeh:FindFirstChild("Driver")
                local seat      = myVeh:FindFirstChild("VehicleSeat")
                local partCount = 0
                for _, p in pairs(myVeh:GetDescendants()) do
                    if p:IsA("BasePart") then partCount = partCount + 1 end
                end
                pcall(function() VehicleModel:SetDesc(tostring(carType and carType.Value or myVeh.Name)) end)
                pcall(function() VehicleParts:SetDesc(tostring(partCount)) end)
                if seat then
                    local vel = seat.AssemblyLinearVelocity
                    pcall(function() VehicleSpeed:SetDesc(math.floor(vel.Magnitude) .. " SPS") end)
                end
                if driver and driver.Value == LocalPlayer then
                    pcall(function() VehicleState:SetDesc("Driving") end)
                else
                    pcall(function() VehicleState:SetDesc("Outside") end)
                end

                if State.PhysicsEnabled and seat and driver and driver.Value == LocalPlayer then
                    if seat.MaxSpeed < 9000 then seat.MaxSpeed = 9999 end
                    local throttle = seat.ThrottleFloat
                    local vel = seat.AssemblyLinearVelocity
                    local speed = vel.Magnitude
                    if State.AccelPower > 0 and math.abs(throttle) > 0 then
                        local isForward = seat.CFrame.LookVector:Dot(vel) > 0
                        if throttle > 0 then
                            if isForward or speed < 3 then
                                seat.AssemblyLinearVelocity = vel + (seat.CFrame.LookVector * (State.AccelPower / 5))
                            else
                                seat.AssemblyLinearVelocity = vel * (1 - (State.BrakeForce / 200))
                            end
                        elseif throttle < 0 then
                            if not isForward or speed < 3 then
                                seat.AssemblyLinearVelocity = vel + (-seat.CFrame.LookVector * (State.AccelPower / 5))
                            else
                                seat.AssemblyLinearVelocity = vel * (1 - (State.BrakeForce / 200))
                            end
                        end
                    end
                end
            else
                pcall(function()
                    VehicleModel:SetDesc("No Active Vehicle")
                    VehicleSpeed:SetDesc("0 SPS")
                    VehicleParts:SetDesc("0")
                    VehicleState:SetDesc("On Foot")
                end)
            end

            local job = LocalPlayer:GetAttribute("JobId")
            if job == "Security" then
                pcall(function() JobStatus:SetDesc("Police Officer") end)
            elseif job == "Criminal" then
                pcall(function() JobStatus:SetDesc("Criminal") end)
            elseif job == "Delivery" then
                pcall(function() JobStatus:SetDesc("Delivery Driver") end)
            else
                pcall(function() JobStatus:SetDesc("Citizen") end)
            end
        end
    end)
end

-- =========================================================================
--  ESP TAB
-- =========================================================================
do
    local hasDrawing = pcall(function() return Drawing end)
    if not hasDrawing then
        EspTab:Paragraph({ Title = "Drawing Not Available", Desc = "ESP features have been disabled because Drawing is not supported by your executor." })
    end

    local ESP_Objects = {}

    local function CreateESP(player)
        if ESP_Objects[player] or not Drawing then return end
        local ok, obj = pcall(function()
            return {
                Box = Drawing.new("Square"),
                Tracer = Drawing.new("Line"),
                Name = Drawing.new("Text"),
                Distance = Drawing.new("Text"),
                Skeleton = {
                    Spine   = Drawing.new("Line"),
                    LeftArm  = Drawing.new("Line"),
                    RightArm = Drawing.new("Line"),
                    LeftLeg  = Drawing.new("Line"),
                    RightLeg = Drawing.new("Line"),
                    Head     = Drawing.new("Line"),
                }
            }
        end)
        if ok and obj then
            obj.Box.Filled = false
            obj.Box.Visible = false
            obj.Name.Center = true
            obj.Name.Outline = true
            obj.Name.Size = 14
            obj.Name.Visible = false
            obj.Distance.Center = true
            obj.Distance.Outline = true
            obj.Distance.Size = 13
            obj.Distance.Visible = false
            for _, line in pairs(obj.Skeleton) do
                line.Visible = false
                line.Thickness = 1
            end
            ESP_Objects[player] = obj
        end
    end

    local function RemoveESP(player)
        if ESP_Objects[player] and Drawing then
            local obj = ESP_Objects[player]
            pcall(function() obj.Box:Remove() end)
            pcall(function() obj.Tracer:Remove() end)
            pcall(function() obj.Name:Remove() end)
            pcall(function() obj.Distance:Remove() end)
            for _, line in pairs(obj.Skeleton) do pcall(function() line:Remove() end) end
            ESP_Objects[player] = nil
        end
    end

    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
    Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)
    Players.PlayerRemoving:Connect(RemoveESP)

    local function GetRoleColor(player)
        local job = player:GetAttribute("JobId")
        if job == "Security" and _G.ESP_Targets.Police then return _G.ESP_Colors.Police end
        if job == "Criminal" and _G.ESP_Targets.Criminals then return _G.ESP_Colors.Criminal end
        if _G.ESP_Targets.Players then return _G.ESP_Colors.Neutral end
        return nil
    end

    local function IsESPVisible(player)
        if not _G.ESP_Enabled then return false end
        local job = player:GetAttribute("JobId")
        if job == "Security" and _G.ESP_Targets.Police then return true end
        if job == "Criminal" and _G.ESP_Targets.Criminals then return true end
        if (job ~= "Security" and job ~= "Criminal") and _G.ESP_Targets.Players then return true end
        return false
    end

    EspTab:Divder()
    EspTab:Section({ Title = "Master Control", Icon = "power" })
    EspTab:Toggle({
        Title    = "Enable ESP",
        Desc     = "Master switch for all ESP visuals.",
        Value    = _G.ESP_Enabled,
        Callback = function(v) _G.ESP_Enabled = v end
    })
    EspTab:Divder()
    EspTab:Section({ Title = "Targets", Icon = "target" })
    EspTab:Toggle({ Title = "Players (Neutral)", Desc = "Display ESP for neutral players.", Value = _G.ESP_Targets.Players,   Callback = function(v) _G.ESP_Targets.Players   = v end })
    EspTab:Toggle({ Title = "Police (Security)", Desc = "Display ESP for Security players.", Value = _G.ESP_Targets.Police,   Callback = function(v) _G.ESP_Targets.Police   = v end })
    EspTab:Toggle({ Title = "Criminals",         Desc = "Display ESP for Criminal players.",  Value = _G.ESP_Targets.Criminals, Callback = function(v) _G.ESP_Targets.Criminals = v end })
    EspTab:Divder()
    EspTab:Section({ Title = "Visuals", Icon = "layers" })
    EspTab:Toggle({ Title = "Boxes 2D",   Desc = "Draw a 2D box around each player.",     Value = _G.ESP_Settings.Boxes,     Callback = function(v) _G.ESP_Settings.Boxes     = v end })
    EspTab:Toggle({ Title = "Tracers",    Desc = "Draw a line from screen center to player.", Value = _G.ESP_Settings.Tracers,   Callback = function(v) _G.ESP_Settings.Tracers   = v end })
    EspTab:Toggle({ Title = "Names",      Desc = "Show the player name above the box.",   Value = _G.ESP_Settings.Names,     Callback = function(v) _G.ESP_Settings.Names     = v end })
    EspTab:Toggle({ Title = "Distance",   Desc = "Show distance in studs below the name.", Value = _G.ESP_Settings.Distance,  Callback = function(v) _G.ESP_Settings.Distance  = v end })
    EspTab:Toggle({ Title = "Skeletons",  Desc = "Draw a simple bone structure.",          Value = _G.ESP_Settings.Skeletons, Callback = function(v) _G.ESP_Settings.Skeletons = v end })
    EspTab:Slider({
        Title    = "Line Thickness",
        Desc     = "Adjust the thickness of all ESP lines.",
        Value    = { Min = 1, Max = 5, Default = _G.ESP_Settings.Thickness },
        Step     = 0.5,
        Callback = function(v) _G.ESP_Settings.Thickness = v end
    })
    EspTab:Divder()
    EspTab:Section({ Title = "Colors", Icon = "palette" })
    EspTab:Colorpicker({ Title = "Police Color",   Desc = "Color used for Security players.",   Default = _G.ESP_Colors.Police,   Callback = function(c) _G.ESP_Colors.Police   = c end })
    EspTab:Colorpicker({ Title = "Criminal Color", Desc = "Color used for Criminal players.",   Default = _G.ESP_Colors.Criminal, Callback = function(c) _G.ESP_Colors.Criminal = c end })
    EspTab:Colorpicker({ Title = "Neutral Color",  Desc = "Color used for neutral players.",    Default = _G.ESP_Colors.Neutral,  Callback = function(c) _G.ESP_Colors.Neutral  = c end })

    task.spawn(function()
        while true do
            for player, obj in pairs(ESP_Objects) do
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local visible = IsESPVisible(player)

                if visible and hrp and hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen and pos.Z > 0 then
                        local color     = GetRoleColor(player) or _G.ESP_Colors.Neutral
                        local thickness = _G.ESP_Settings.Thickness
                        local dist      = math.floor((Camera.CFrame.p - hrp.Position).magnitude)

                        if _G.ESP_Settings.Boxes then
                            local sizeX = 2000 / pos.Z
                            local sizeY = 3000 / pos.Z
                            obj.Box.Visible   = true
                            obj.Box.Color     = color
                            obj.Box.Thickness = thickness
                            obj.Box.Size      = Vector2.new(sizeX, sizeY)
                            obj.Box.Position  = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                        else obj.Box.Visible = false end

                        if _G.ESP_Settings.Tracers then
                            obj.Tracer.Visible   = true
                            obj.Tracer.Color     = color
                            obj.Tracer.Thickness = thickness
                            obj.Tracer.From      = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            obj.Tracer.To        = Vector2.new(pos.X, pos.Y)
                        else obj.Tracer.Visible = false end

                        if _G.ESP_Settings.Names then
                            obj.Name.Visible  = true
                            obj.Name.Color    = color
                            obj.Name.Position = Vector2.new(pos.X, pos.Y - (3000 / pos.Z) / 2 - 20)
                            obj.Name.Text     = player.Name
                        else obj.Name.Visible = false end

                        if _G.ESP_Settings.Distance then
                            obj.Distance.Visible  = true
                            obj.Distance.Color    = Color3.new(1, 1, 1)
                            obj.Distance.Position = Vector2.new(pos.X, pos.Y - (3000 / pos.Z) / 2 - 5)
                            obj.Distance.Text     = "[" .. dist .. " studs]"
                        else obj.Distance.Visible = false end

                        if _G.ESP_Settings.Skeletons and char:FindFirstChild("Head") then
                            local headPos  = Camera:WorldToViewportPoint(char.Head.Position)
                            local torsoPos = Camera:WorldToViewportPoint(char:FindFirstChild("UpperTorso") and char.UpperTorso.Position or hrp.Position)
                            local legLPos  = Camera:WorldToViewportPoint(char:FindFirstChild("LeftFoot") and char.LeftFoot.Position or hrp.Position)
                            local legRPos  = Camera:WorldToViewportPoint(char:FindFirstChild("RightFoot") and char.RightFoot.Position or hrp.Position)
                            local armRPos  = Camera:WorldToViewportPoint(char:FindFirstChild("RightHand") and char.RightHand.Position or hrp.Position)
                            local armLPos  = Camera:WorldToViewportPoint(char:FindFirstChild("LeftHand") and char.LeftHand.Position or hrp.Position)

                            obj.Skeleton.Head.From    = Vector2.new(pos.X, pos.Y)
                            obj.Skeleton.Head.To      = Vector2.new(headPos.X, headPos.Y)
                            obj.Skeleton.Spine.From   = Vector2.new(headPos.X, headPos.Y)
                            obj.Skeleton.Spine.To     = Vector2.new(torsoPos.X, torsoPos.Y)
                            obj.Skeleton.LeftArm.From = Vector2.new(torsoPos.X, torsoPos.Y)
                            obj.Skeleton.LeftArm.To   = Vector2.new(armLPos.X, armLPos.Y)
                            obj.Skeleton.RightArm.From= Vector2.new(torsoPos.X, torsoPos.Y)
                            obj.Skeleton.RightArm.To  = Vector2.new(armRPos.X, armRPos.Y)
                            obj.Skeleton.LeftLeg.From = Vector2.new(torsoPos.X, torsoPos.Y)
                            obj.Skeleton.LeftLeg.To   = Vector2.new(legLPos.X, legLPos.Y)
                            obj.Skeleton.RightLeg.From= Vector2.new(torsoPos.X, torsoPos.Y)
                            obj.Skeleton.RightLeg.To  = Vector2.new(legRPos.X, legRPos.Y)

                            for _, line in pairs(obj.Skeleton) do
                                line.Visible   = true
                                line.Color     = color
                                line.Thickness = thickness
                            end
                        else
                            for _, line in pairs(obj.Skeleton) do line.Visible = false end
                        end
                    else
                        obj.Box.Visible = false
                        obj.Tracer.Visible = false
                        obj.Name.Visible = false
                        obj.Distance.Visible = false
                        for _, line in pairs(obj.Skeleton) do line.Visible = false end
                    end
                else
                    obj.Box.Visible = false
                    obj.Tracer.Visible = false
                    obj.Name.Visible = false
                    obj.Distance.Visible = false
                    for _, line in pairs(obj.Skeleton) do line.Visible = false end
                end
            end
            task.wait()
        end
    end)
end

-- =========================================================================
--  PLAYER TAB
-- =========================================================================
do
    PlayerTab:Divder()
    PlayerTab:Section({ Title = "Movement", Icon = "footprints" })

    PlayerTab:Toggle({
        Title    = "Enable Speed",
        Desc     = "Increases your movement speed using the selected mode.",
        Value    = State.SpeedEnabled,
        Callback = function(v)
            State.SpeedEnabled = v
            if not v then
                pcall(function()
                    local c = LocalPlayer.Character
                    if c then
                        local h = c:FindFirstChildOfClass("Humanoid")
                        if h then h.WalkSpeed = 16 end
                    end
                end)
            end
            WindUI:Notify({ Title = "Speed", Content = v and "Enabled" or "Disabled", Duration = 2, Icon = "wind" })
        end
    })

    PlayerTab:Dropdown({
        Title    = "Speed Mode",
        Desc     = "Choose how the speed hack behaves.",
        Values   = { "Legit", "HVH", "Normal", "CFrame" },
        Value    = State.SpeedMode,
        Callback = function(v) State.SpeedMode = v end
    })

    PlayerTab:Slider({
        Title    = "Speed Value",
        Desc     = "Higher value means faster movement.",
        Value    = { Min = 16, Max = 300, Default = State.SpeedValue },
        Step     = 1,
        Callback = function(v) State.SpeedValue = v end
    })

    local function isMoving()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return false, Vector3.new() end
        local moveDir = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        local movement = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then movement = movement + moveDir end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then movement = movement - moveDir end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then movement = movement + Vector3.new(-moveDir.Z, 0, moveDir.X) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then movement = movement + Vector3.new(moveDir.Z, 0, -moveDir.X) end
        if movement.Magnitude > 0 then return true, movement.Unit end
        return false, Vector3.new()
    end

    local function startSpeedLoop()
        if Connections.Speed then return end
        Connections.Speed = RunService.RenderStepped:Connect(function()
            if not State.SpeedEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            local moving, dir = isMoving()
            if moving then
                if State.SpeedMode == "Normal" then
                    hum.WalkSpeed = State.SpeedValue
                elseif State.SpeedMode == "CFrame" then
                    hrp.CFrame = hrp.CFrame + (dir * (State.SpeedValue / 50))
                elseif State.SpeedMode == "Legit" then
                    hrp.Velocity = Vector3.new(dir.X * State.SpeedValue, hrp.Velocity.Y, dir.Z * State.SpeedValue)
                elseif State.SpeedMode == "HVH" then
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then hum.Jump = true end
                    hrp.Velocity = Vector3.new(dir.X * State.SpeedValue, hrp.Velocity.Y, dir.Z * State.SpeedValue)
                end
            else
                if State.SpeedMode == "Legit" or State.SpeedMode == "HVH" then
                    hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                end
            end
        end)
    end

    local function stopSpeedLoop()
        if Connections.Speed then
            Connections.Speed:Disconnect()
            Connections.Speed = nil
        end
    end

    startSpeedLoop()
    PlayerTab:Divder()
    PlayerTab:Section({ Title = "Flight", Icon = "wind" })

    PlayerTab:Toggle({
        Title    = "Enable Fly",
        Desc     = "Allows you to fly freely through the map.",
        Value    = State.FlyEnabled,
        Callback = function(v)
            State.FlyEnabled = v
            if Connections.Fly then Connections.Fly:Disconnect() Connections.Fly = nil end
            if v then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then
                    State.FlyEnabled = false
                    return
                end
                local vFly = Instance.new("BodyVelocity")
                vFly.Name = "DYHUB_FlyVel"
                vFly.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                vFly.Velocity = Vector3.new(0, 0, 0)
                vFly.Parent = hrp
                local vGyro = Instance.new("BodyGyro")
                vGyro.Name = "DYHUB_FlyGyro"
                vGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                vGyro.CFrame = hrp.CFrame
                vGyro.Parent = hrp
                hum.PlatformStand = true
                Connections.Fly = RunService.RenderStepped:Connect(function()
                    if not State.FlyEnabled or not hrp or not hrp.Parent then
                        if Connections.Fly then Connections.Fly:Disconnect() Connections.Fly = nil end
                        return
                    end
                    local dir = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                    vGyro.CFrame = Camera.CFrame
                    if dir.Magnitude > 0 then vFly.Velocity = dir.Unit * State.FlySpeed
                    else vFly.Velocity = Vector3.new(0, 0, 0) end
                end)
            else
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.PlatformStand = false end
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            if hrp:FindFirstChild("DYHUB_FlyVel") then hrp.DYHUB_FlyVel:Destroy() end
                            if hrp:FindFirstChild("DYHUB_FlyGyro") then hrp.DYHUB_FlyGyro:Destroy() end
                        end
                    end
                end)
            end
        end
    })

    PlayerTab:Slider({
        Title    = "Fly Speed",
        Desc     = "Higher value means faster flight.",
        Value    = { Min = 0, Max = 500, Default = State.FlySpeed },
        Step     = 1,
        Callback = function(v) State.FlySpeed = v end
    })
    PlayerTab:Divder()
    PlayerTab:Section({ Title = "Physics", Icon = "atom" })

    PlayerTab:Toggle({
        Title    = "Noclip",
        Desc     = "Allows you to walk through any solid object.",
        Value    = State.NoclipEnabled,
        Callback = function(v)
            State.NoclipEnabled = v
            if Connections.Noclip then Connections.Noclip:Disconnect() Connections.Noclip = nil end
            if v then
                Connections.Noclip = RunService.Stepped:Connect(function()
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            for _, p in pairs(char:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanCollide = false end
                            end
                        end
                    end)
                end)
            end
        end
    })

    PlayerTab:Toggle({
        Title    = "Infinite Jump",
        Desc     = "Lets you jump in mid air without limits.",
        Value    = State.InfJumpEnabled,
        Callback = function(v) State.InfJumpEnabled = v end
    })

    PlayerTab:Toggle({
        Title    = "Override Jump Power",
        Desc     = "Replaces the default jump height with a custom value.",
        Value    = State.JumpPowerEnabled,
        Callback = function(v)
            State.JumpPowerEnabled = v
            if v then
                pcall(function()
                    local c = LocalPlayer.Character
                    if c then
                        local h = c:FindFirstChildOfClass("Humanoid")
                        if h then
                            h.UseJumpPower = true
                            h.JumpPower = State.JumpPowerValue
                        end
                    end
                end)
            else
                pcall(function()
                    local c = LocalPlayer.Character
                    if c then
                        local h = c:FindFirstChildOfClass("Humanoid")
                        if h then h.JumpPower = 50 end
                    end
                end)
            end
        end
    })

    PlayerTab:Slider({
        Title    = "Jump Power",
        Desc     = "Higher value means higher jumps.",
        Value    = { Min = 0, Max = 500, Default = State.JumpPowerValue },
        Step     = 1,
        Callback = function(v)
            State.JumpPowerValue = v
            if State.JumpPowerEnabled then
                pcall(function()
                    local c = LocalPlayer.Character
                    if c then
                        local h = c:FindFirstChildOfClass("Humanoid")
                        if h then h.JumpPower = v end
                    end
                end)
            end
        end
    })

    UserInputService.JumpRequest:Connect(function()
        if State.InfJumpEnabled then
            pcall(function()
                local c = LocalPlayer.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        end
    end)
    PlayerTab:Divder()
    PlayerTab:Section({ Title = "World", Icon = "globe" })

    PlayerTab:Toggle({
        Title    = "Instant Prompt",
        Desc     = "Removes the hold time from every ProximityPrompt in the world.",
        Value    = State.InstantPromptOn,
        Callback = function(v)
            State.InstantPromptOn = v
            if Connections.PromptScan then Connections.PromptScan:Disconnect() Connections.PromptScan = nil end

            local function ApplyInstant(obj)
                if obj:IsA("ProximityPrompt") then
                    pcall(function()
                        obj.HoldDuration = 0
                        obj.RequiresLineOfSight = false
                        obj.MaxActivationDistance = math.max(obj.MaxActivationDistance, 20)
                    end)
                end
            end

            if v then
                for _, d in pairs(Workspace:GetDescendants()) do ApplyInstant(d) end
                Connections.PromptScan = Workspace.DescendantAdded:Connect(function(obj)
                    task.wait()
                    ApplyInstant(obj)
                end)
            end
        end
    })
    PlayerTab:Divder()
    PlayerTab:Section({ Title = "Teleport", Icon = "map-pin" })

    local PlayerDropdown
    PlayerDropdown = PlayerTab:Dropdown({
        Title    = "Select Player",
        Desc     = "Choose a player to teleport to.",
        Values   = getPlayerNames(),
        Value    = "",
        Callback = function(v) State.SelectedPlayer = v end
    })

    PlayerTab:Button({
        Title    = "Refresh Player List",
        Desc     = "Updates the dropdown with the current player list.",
        Callback = function()
            pcall(function()
                if PlayerDropdown and PlayerDropdown.Refresh then
                    PlayerDropdown:Refresh(getPlayerNames())
                elseif PlayerDropdown and PlayerDropdown.SetValues then
                    PlayerDropdown:SetValues(getPlayerNames())
                end
            end)
        end
    })

    PlayerTab:Button({
        Title    = "Teleport To Player",
        Desc     = "Teleports you directly to the selected player.",
        Callback = function()
            if not State.SelectedPlayer then
                WindUI:Notify({ Title = "Teleport", Content = "Please select a player first.", Duration = 2, Icon = "alert-triangle" })
                return
            end
            local target = Players:FindFirstChild(State.SelectedPlayer)
            if not target or not target.Character then return end
            local dest = target.Character:GetPivot() * CFrame.new(0, 8, 0)
            local myVeh = GetMyVehicle()
            local isDriving = myVeh and myVeh:FindFirstChild("Driver") and myVeh.Driver.Value == LocalPlayer
            if isDriving and myVeh then
                local allParts = {}
                for _, p in pairs(myVeh:GetDescendants()) do if p:IsA("BasePart") then table.insert(allParts, p) end end
                for _, p in pairs(allParts) do p.Anchored = true end
                myVeh:PivotTo(dest)
                task.wait(0.2)
                for _, p in pairs(allParts) do
                    p.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    p.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    p.Anchored = false
                end
            else
                pcall(function() LocalPlayer.Character:PivotTo(dest) end)
            end
        end
    })
    PlayerTab:Divder()
    PlayerTab:Section({ Title = "Safety", Icon = "shield" })

    PlayerTab:Toggle({
        Title    = "Anti-AFK",
        Desc     = "Prevents the game from disconnecting you for being idle.",
        Value    = State.AntiAfkEnabled,
        Callback = function(v)
            State.AntiAfkEnabled = v
            if Connections.AntiAfk then Connections.AntiAfk:Disconnect() Connections.AntiAfk = nil end
            if v then
                Connections.AntiAfk = LocalPlayer.Idled:Connect(function()
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new(), Workspace.CurrentCamera.CFrame)
                    end)
                end)
            end
        end
    })
end

-- =========================================================================
--  COLLECT TAB (ATM FARM + AUTO DELIVERY)
-- =========================================================================
do
    local ATMFlag   = { Search = false }
    local noclipConn = nil
    local BagLimit   = 25

    local spawnPos = Vector3.new(-315.4537353515625, 17.595108032226562, -1660.684326171875)
    local platformPositions = {
        Vector3.new(-978.8837890625, -166, 313.3407897949219),
        Vector3.new(-484.3203430175781, -166, -1226.457275390625),
        Vector3.new(220.6251220703125, -166, 137.8120880126953),
        Vector3.new(-94.29008483886719, -166, 2340.5263671875),
        Vector3.new(-866.1265258789062, -166, 3189.411865234375),
        Vector3.new(-2068.16015625, -166, 4206.7861328125),
    }
    local sellPos1 = Vector3.new(-2520.495849609375, 15.116586685180664, 4035.560791015625)
    local sellPos2 = Vector3.new(-2542.12646484375, 15.116586685180664, 4030.9150390625)

    local FarmConfig = {
        task1 = 0.5, task2 = 2.0, task3 = 0.15, task4 = 5.0,
        task5 = 0.15, task6 = 0.0, task7 = 5.0, task8 = 0.0,
    }

    local ATMStatusParagraph
    local ATMBagsParagraph
    local DeliveryStatusParagraph

    local function setATMStatus(t)
        State.ATMStatus = t
        pcall(function() if ATMStatusParagraph then ATMStatusParagraph:SetDesc(t) end end)
    end

    local function setWeight(isHeavy)
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CustomPhysicalProperties = isHeavy and PhysicalProperties.new(100, 0.3, 0.5) or nil
                    end
                end
            end
        end)
    end

    local function SetNoclip(state)
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, p in pairs(char:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end)
            end)
        end
    end

    local function createAllPlatforms()
        for _, pos in ipairs(platformPositions) do
            local p = Instance.new("Part")
            p.Name = "DeltaCorePlatform"
            p.Parent = Workspace
            p.Position = pos
            p.Size = Vector3.new(50000, 3, 50000)
            p.Color = Color3.fromRGB(170, 0, 255)
            p.Anchored = true
        end
    end

    local function removeAllPlatforms()
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.Name == "DeltaCorePlatform" then pcall(function() obj:Destroy() end) end
        end
    end

    local function tpTo(pos)
        if not ATMFlag.Search and pos ~= spawnPos then return end
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
            end
        end)
    end

    local function SimpleGoTo(destination, timeout)
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root or not hum then return end
        local startT = tick()
        timeout = timeout or 2
        while (root.Position - destination).Magnitude > 3 do
            if not ATMFlag.Search or (tick() - startT) > timeout then break end
            hum:MoveTo(destination)
            if root.AssemblyLinearVelocity.Magnitude < 0.5 then hum.Jump = true end
            task.wait(0.1)
        end
    end

    local function GetAvailableATM()
        local spawners = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Jobs") and Workspace.Game.Jobs:FindFirstChild("CriminalATMSpawners")
        if not spawners then return nil, nil end
        for _, spawner in ipairs(spawners:GetChildren()) do
            local atm = spawner:FindFirstChild("CriminalATM")
            if atm and atm:GetAttribute("State") == "Normal" then
                return spawner, atm
            end
        end
        return nil, nil
    end

    local function CheckBagLimit()
        if not ATMFlag.Search then return false end
        local currentCrimes = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("CrimesCommitted") or 0
        if currentCrimes >= BagLimit then
            setATMStatus("Bag limit reached, heading to sell point")
            while currentCrimes >= BagLimit and ATMFlag.Search do
                SetNoclip(true)
                tpTo(sellPos1)
                task.wait(FarmConfig.task1)
                setATMStatus("Walking to sell location")
                SimpleGoTo(sellPos2, 2)
                task.wait(FarmConfig.task2)
                currentCrimes = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("CrimesCommitted") or 0
            end
            setATMStatus("Items sold, resuming farm")
            return true
        end
        return false
    end

    local function SmartBust(targetSpawner, atmModel)
        if not ATMFlag.Search then return end
        local safePos = platformPositions[math.random(1, #platformPositions)]
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        setATMStatus("Starting robbery")
        if root then root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
        tpTo(targetSpawner.Position)
        task.wait(FarmConfig.task3)
        pcall(function() bustStart:InvokeServer(atmModel) end)
        setATMStatus("Waiting on safe platform")
        tpTo(safePos)
        task.wait(FarmConfig.task4)
        setATMStatus("Collecting the loot")
        if root then root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
        tpTo(targetSpawner.Position)
        task.wait(FarmConfig.task5)
        pcall(function() bustEnd:InvokeServer(atmModel) end)
        task.wait(FarmConfig.task6)
        tpTo(safePos)
        CheckBagLimit()
    end

    local function StartATMLoop()
        task.spawn(function()
            while ATMFlag.Search do
                CheckBagLimit()
                for _, platformPos in ipairs(platformPositions) do
                    if not ATMFlag.Search then break end
                    if CheckBagLimit() then tpTo(platformPos) end
                    SetNoclip(true)
                    setWeight(true)
                    setATMStatus("Scanning platform")
                    tpTo(platformPos)
                    task.wait(FarmConfig.task7)
                    local spawner, atm = GetAvailableATM()
                    if spawner and atm then
                        SmartBust(spawner, atm)
                        setATMStatus("Cooldown between attempts")
                        task.wait(FarmConfig.task8)
                    end
                end
                task.wait(0.1)
            end
        end)
    end

    local function StartATMFarm()
        if ATMFlag.Search then return end
        ATMFlag.Search = true
        setATMStatus("Starting ATM farm")
        pcall(function() RemoteStart:FireServer("Criminal", "jobPad") end)
        task.wait(0.5)
        removeAllPlatforms()
        createAllPlatforms()
        task.wait(0.5)
        SetNoclip(true)
        setWeight(true)
        task.wait(1)
        StartATMLoop()
        WindUI:Notify({ Title = "ATM Farm", Content = "Started successfully.", Duration = 2, Icon = "package" })
    end

    local function StopATMFarm()
        if not ATMFlag.Search then return end
        ATMFlag.Search = false
        setATMStatus("Stopping ATM farm")
        tpTo(spawnPos)
        task.wait(0.5)
        pcall(function() RemoteEnd:FireServer("jobPad") end)
        SetNoclip(false)
        setWeight(false)
        removeAllPlatforms()
        setATMStatus("ATM farm stopped")
    end

    -- ============== AUTO DELIVERY ==============
    local DELIVERY_ANCHOR_NAME = "DeliveryTargetAnchor"
    local DELIVERY_DIST_HIGH   = 26
    local DELIVERY_DIST_LOW    = 24
    local DELIVERY_PLATFORM_LIFE = 3
    local deliveryRunning = false
    local currentPlatform  = nil
    local platformFadeThread = nil
    local useHigh = true
    local deliveryThread = nil

    local function setDeliveryStatus(t)
        State.DeliveryStatus = t
        pcall(function() if DeliveryStatusParagraph then DeliveryStatusParagraph:SetDesc(t) end end)
    end

    local function destroyDeliveryPlatform()
        if platformFadeThread then
            pcall(function() task.cancel(platformFadeThread) end)
            platformFadeThread = nil
        end
        if currentPlatform and currentPlatform.Parent then
            pcall(function() currentPlatform:Destroy() end)
        end
        currentPlatform = nil
    end

    local function spawnDeliveryPlatformAt(position)
        destroyDeliveryPlatform()
        local platform = Instance.new("Part")
        platform.Name = "TeleportPlatform"
        platform.Size = Vector3.new(10, 1, 10)
        platform.CFrame = CFrame.new(position - Vector3.new(0, 3 + platform.Size.Y / 2, 0))
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 1
        platform.CastShadow = false
        platform.Parent = Workspace
        currentPlatform = platform
    end

    local function scheduleDeliveryPlatformRemoval()
        if platformFadeThread then pcall(function() task.cancel(platformFadeThread) end) end
        platformFadeThread = task.delay(DELIVERY_PLATFORM_LIFE, function()
            destroyDeliveryPlatform()
        end)
    end

    local function findDeliveryAnchor()
        return Workspace:FindFirstChild(DELIVERY_ANCHOR_NAME, true)
    end

    local function doDeliveryTeleport()
        local anchor = findDeliveryAnchor()
        if not anchor then return false end
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return false end

        local dist = useHigh and DELIVERY_DIST_HIGH or DELIVERY_DIST_LOW
        local anchorCF = anchor:IsA("BasePart") and anchor.CFrame or CFrame.new(anchor.Position)
        local offset = anchorCF.LookVector * dist
        local targetPos = anchorCF.Position + offset + Vector3.new(0, 3, 0)

        spawnDeliveryPlatformAt(targetPos)
        scheduleDeliveryPlatformRemoval()
        task.wait()
        rootPart.CFrame = CFrame.new(targetPos, anchorCF.Position)

        useHigh = not useHigh
        return true
    end

    local function startDeliveryLoop()
        if deliveryRunning then return end
        deliveryRunning = true
        setDeliveryStatus("Joining Delivery job")
        pcall(function() RemoteStart:FireServer("Delivery", "jobPad") end)
        task.wait(0.5)
        setDeliveryStatus("Waiting for delivery target")

        deliveryThread = task.spawn(function()
            while deliveryRunning do
                local ok = doDeliveryTeleport()
                if not ok then
                    setDeliveryStatus("Anchor not found, retrying")
                    task.wait(1)
                end
                task.wait(0)
            end
        end)
    end

    local function stopDeliveryLoop()
        if not deliveryRunning then return end
        deliveryRunning = false
        if deliveryThread then
            pcall(function() task.cancel(deliveryThread) end)
            deliveryThread = nil
        end
        destroyDeliveryPlatform()
        pcall(function() RemoteEnd:FireServer("jobPad") end)
        setDeliveryStatus("Delivery stopped")
    end

    -- ============== COLLECT TAB UI ==============
    CollectTab:Divder()
    CollectTab:Section({ Title = "Farm Status", Icon = "activity" })
    ATMStatusParagraph       = CollectTab:Paragraph({ Title = "ATM Farm",       Desc = "Idle" })
    ATMBagsParagraph         = CollectTab:Paragraph({ Title = "ATM Bags",       Desc = "0 / 25" })
    DeliveryStatusParagraph  = CollectTab:Paragraph({ Title = "Auto Delivery",  Desc = "Idle" })
    CollectTab:Divder()
    CollectTab:Section({ Title = "ATM Farm", Icon = "package" })
    CollectTab:Toggle({
        Title    = "Auto ATM",
        Desc     = "Toggles the full ATM farm cycle on or off.",
        Value    = false,
        Callback = function(v)
            if v then StartATMFarm() else StopATMFarm() end
        end
    })
    CollectTab:Slider({
        Title    = "Bag Limit",
        Desc     = "Maximum number of bags before the script sells automatically.",
        Value    = { Min = 6, Max = 200, Default = BagLimit },
        Step     = 1,
        Callback = function(v) BagLimit = v end
    })
    CollectTab:Divder()
    CollectTab:Section({ Title = "ATM Delay Configuration", Icon = "settings" })
    local function addATMTaskInput(name, key)
        CollectTab:Input({
            Title    = name,
            Desc     = "Adjust the delay for this step in seconds.",
            Placeholder = "Current: " .. tostring(FarmConfig[key]),
            Callback = function(text)
                local val = tonumber(text)
                if val and val >= 0 then
                    FarmConfig[key] = val
                    WindUI:Notify({ Title = "ATM Config", Content = name .. " set to " .. val .. "s", Duration = 2, Icon = "settings" })
                end
            end
        })
    end
    addATMTaskInput("Task 1: Teleport to Sell Point 1", "task1")
    addATMTaskInput("Task 2: Sale Processing",          "task2")
    addATMTaskInput("Task 3: Load ATM (Start)",         "task3")
    addATMTaskInput("Task 4: Robbery Cooldown",         "task4")
    addATMTaskInput("Task 5: Load ATM (Collect)",       "task5")
    addATMTaskInput("Task 6: Finalize Robbery",         "task6")
    addATMTaskInput("Task 7: Platform Loading",         "task7")
    addATMTaskInput("Task 8: Short Break",              "task8")

    CollectTab:Button({
        Title    = "Reset ATM Delays",
        Desc     = "Restores all ATM delay values to their defaults.",
        Callback = function()
            FarmConfig.task1 = 0.5;  FarmConfig.task2 = 2.0
            FarmConfig.task3 = 0.15; FarmConfig.task4 = 5.0
            FarmConfig.task5 = 0.15; FarmConfig.task6 = 0.0
            FarmConfig.task7 = 5.0;  FarmConfig.task8 = 0.0
            WindUI:Notify({ Title = "ATM Config", Content = "All ATM delays reset to default.", Duration = 2, Icon = "rotate-ccw" })
        end
    })
    CollectTab:Divder()
    CollectTab:Section({ Title = "Delivery Farm", Icon = "truck" })
    CollectTab:Toggle({
        Title    = "Auto Delivery",
        Desc     = "Toggles automatic delivery teleportation on or off.",
        Value    = false,
        Callback = function(v)
            if v then startDeliveryLoop() else stopDeliveryLoop() end
        end
    })

    -- Progress loop
    task.spawn(function()
        while true do
            pcall(function()
                if LocalPlayer.Character then
                    local cur = LocalPlayer.Character:GetAttribute("CrimesCommitted") or 0
                    local suffix = (cur >= BagLimit and BagLimit > 0) and " (Full)" or ""
                    State.ATMBags = cur .. " / " .. BagLimit .. suffix
                    if ATMBagsParagraph then ATMBagsParagraph:SetDesc(State.ATMBags) end
                end
            end)
            task.wait(0.5)
        end
    end)

    -- Cleanup platforms on death / respawn
    LocalPlayer.CharacterRemoving:Connect(function()
        destroyDeliveryPlatform()
    end)
end

-- =========================================================================
--  SETTINGS TAB
-- =========================================================================
do
    SettingsTab:Divder()
    SettingsTab:Section({ Title = "Save Config", Icon = "save" })
    SettingsTab:Button({
        Title    = "Save Config Now",
        Desc     = "Saves the current configuration to file immediately.",
        Callback = function()
            Config:Save()
            WindUI:Notify({ Title = "Config", Content = "Configuration saved successfully.", Duration = 2, Icon = "save" })
        end
    })

    local AutoSaveOn = Config:Get("AutoSaveEnabled", true)
    local AutoSaveD  = Config:Get("AutoSaveDelay", 15)
    SettingsTab:Toggle({
        Title    = "Auto Save Config",
        Desc     = "Automatically saves the configuration at a set interval.",
        Value    = AutoSaveOn,
        Callback = function(v)
            AutoSaveOn = v; Config:Set("AutoSaveEnabled", v); Config:Save()
            if v then Config:AutoSave(AutoSaveD) else Config:AutoSave(0) end
        end
    })
    SettingsTab:Input({
        Title    = "Save Delay (Seconds)",
        Desc     = "Interval in seconds between automatic saves.",
        Placeholder = "Default: 15",
        Value = tostring(AutoSaveD),
        Callback = function(text)
            local n = tonumber(text)
            if n and n >= 1 then
                AutoSaveD = n; Config:Set("AutoSaveDelay", n); Config:Save()
                if AutoSaveOn then Config:AutoSave(n) end
            end
        end
    })
    SettingsTab:Divder()
    SettingsTab:Section({ Title = "Server", Icon = "server" })
    SettingsTab:Button({
        Title    = "Server Hop",
        Desc     = "Teleports you to a different random server of the same game.",
        Callback = ExecuteServerHop
    })
    SettingsTab:Button({
        Title    = "Rejoin Server",
        Desc     = "Rejoins the current game server.",
        Callback = function()
            WindUI:Notify({ Title = "Rejoin", Content = "Rejoining the current server.", Duration = 2, Icon = "refresh-cw" })
            task.wait(1)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })
    SettingsTab:Divder()
    SettingsTab:Section({ Title = "Bypass Monitor", Icon = "shield" })
    local BypassStatus = SettingsTab:Paragraph({ Title = "Bypass Status", Desc = "Disarmed" })
    local BlockCount = 0
    local HookInstalled = false

    local TargetRemotes = {
        ["StarwatchClientEventIngestor"] = true, ["_network"] = true,
        ["rsp"] = true, ["rps"] = true, ["rsi"] = true, ["rs"] = true, ["rsw"] = true,
        ["ptsstop"] = true, ["ptsstart"] = true, ["SdkTelemetryRemote"] = true,
        ["TeleportInfo"] = true, ["SendLogString"] = true, ["GetClientLogs"] = true,
        ["GetClientFPS"] = true, ["GetClientPing"] = true, ["GetClientMemoryUsage"] = true,
        ["GetClientPerformanceStats"] = true, ["GetClientReport"] = true,
        ["RepBL"] = true, ["UnauthorizedTeleport"] = true, ["ClientDetectedSoftlock"] = true,
        ["loadTime"] = true, ["InformLoadingEventFunnel"] = true, ["InformGeneralEventFunnel"] = true,
    }

    local function InstallEarlyHook()
        if HookInstalled then return end
        local success = pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = { ... }
                if State.BypassActive and (method == "FireServer" or method == "InvokeServer") then
                    local n = tostring(self)
                    local shouldBlock = false
                    if TargetRemotes[n] then shouldBlock = true end
                    if not shouldBlock and string.match(n, "^%x%x%x%x%x%x%x%x%-") then shouldBlock = true end
                    if not shouldBlock and n == "Location" and args[1] == "Enter" and args[2] == "Boats" then shouldBlock = true end
                    if shouldBlock then
                        BlockCount = BlockCount + 1
                        return nil
                    end
                end
                return oldNamecall(self, ...)
            end)
        end)
        if success then HookInstalled = true end
    end
    InstallEarlyHook()

    SettingsTab:Toggle({
        Title    = "Bypass Monitor Events",
        Desc     = "Blocks telemetry logs, RSP, RPS, and unauthorized remote calls.",
        Value    = false,
        Callback = function(v)
            State.BypassActive = v
            if v then
                BlockCount = 0
                WindUI:Notify({ Title = "Bypass", Content = "Bypass monitor activated.", Duration = 3, Icon = "shield" })
            else
                pcall(function() BypassStatus:SetDesc("Disarmed") end)
            end
        end
    })

    task.spawn(function()
        while true do
            pcall(function()
                if State.BypassActive then
                    local remotesF = ReplicatedStorage:FindFirstChild("Remotes")
                    if remotesF then
                        for _, remote in pairs(remotesF:GetChildren()) do
                            local n = remote.Name
                            if string.match(n, "^%x%x%x%x%x%x%x%x%-") and not TargetRemotes[n] then
                                TargetRemotes[n] = true
                            end
                        end
                        pcall(function() BypassStatus:SetDesc("Active (" .. BlockCount .. " blocked)") end)
                    else
                        pcall(function() BypassStatus:SetDesc("Waiting for the game engine to load") end)
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

-- =========================================================================
--  INFORMATION TAB
-- =========================================================================
do
    local ui = ui or {}
    ui.Creator = ui.Creator or {}

    InfoTab:Divder()
    InfoTab:Section({ Title = "Latest Update", TextXAlignment = "Center", TextSize = 17 })
    InfoTab:Divder()
    InfoTab:Paragraph({
        Title = "Update: 07/17/2026 | CL: " .. ver,
        Desc  = [[- [Added] Noclip, Infinite Jump, Jump Power
- [Added] Instant Prompt with continuous scanning
- [Added] Vehicle RGB and Physics Modifier
- [Added] ATM Farm with custom delay inputs
- [Added] Auto Delivery teleport loop
- [Added] ESP with Boxes, Tracers, Skeletons, and Names
- [Added] Bypass Monitor using early hook
- [Fixed] Memory Leaks / Clean Cache
- [Fixed] Connection Cleanup on Toggle Off
- [Fixed] Lag Optimizations / Reloaded
- [Fixed] Anti-AFK Disconnect Issue]],
    })
    InfoTab:Divder()

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
                local DiscordInfo = InfoTab:Paragraph({
                    Title = result.guild.name,
                    Desc  = ' <font color="#52525b">●</font> Member Count : ' .. tostring(result.approximate_member_count) ..
                            '\n <font color="#16a34a">●</font> Online Count : '  .. tostring(result.approximate_presence_count),
                    Image = "https://cdn.discordapp.com/icons/" .. result.guild.id .. "/" .. result.guild.icon .. ".png?size=1024",
                    ImageSize = 42,
                })
                InfoTab:Button({ Title = "Update Info", Callback = function()
                    local ok, r = pcall(function() return HttpService:JSONDecode(ui.Creator.Request({ Url = DiscordAPI, Method = "GET" }).Body) end)
                    if ok and r and r.guild then
                        pcall(function() DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : ' .. tostring(r.approximate_member_count) .. '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(r.approximate_presence_count)) end)
                        WindUI:Notify({ Title = "Discord Info Updated", Content = "Refreshed!", Duration = 2, Icon = "refresh-cw" })
                    else
                        WindUI:Notify({ Title = "Update Failed", Content = "Could not refresh.", Duration = 3, Icon = "alert-triangle" })
                    end
                end })
                InfoTab:Button({ Title = "Copy Discord Invite", Callback = function()
                    setclipboard("https://discord.gg/" .. InviteCode)
                    WindUI:Notify({ Title = "Copied!", Content = "Discord invite copied!", Duration = 2, Icon = "clipboard-check" })
                end })
            else
                InfoTab:Paragraph({ Title = "Error fetching Discord Info", Desc = "Unable to load.", Image = "triangle-alert", ImageSize = 26, Color = "Red" })
            end
        end
        LoadDiscordInfo()

        InfoTab:Divder()
        InfoTab:Section({ Title = "DYHUB Information", TextXAlignment = "Center", TextSize = 17 })
        InfoTab:Divder()
        InfoTab:Paragraph({ Title = "Main Owner", Desc = "@dyumraisgoodguy#8888", Image = "rbxassetid://119789418015420", ImageSize = 30 })
        InfoTab:Paragraph({ Title = "Social", Desc = "Copy link social media for follow!", Image = "rbxassetid://104487529937663", ImageSize = 30,
            Buttons = {{ Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://guns.lol/DYHUB") end }} })
        InfoTab:Paragraph({ Title = "Discord", Desc = "Join our discord for more scripts!", Image = "rbxassetid://104487529937663", ImageSize = 30,
            Buttons = {{ Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://discord.gg/jWNDPNMmyB") end }} })
    end
end

-- ====================== CHARACTER RESPAWN HANDLER ======================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    State.SpeedEnabled = false
    pcall(function()
        local h = char:WaitForChild("Humanoid", 5)
        if h then h.WalkSpeed = 16 end
    end)
end)

print("[DYHUB] " .. version .. " | " .. ver .. " | Driving Empire loaded successfully.")
print("[DYHUB] Auto saving every " .. tostring(Config:Get("AutoSaveDelay", 15)) .. "s")
