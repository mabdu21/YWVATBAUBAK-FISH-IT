-- ==========================================
-- Test V75
-- ==========================================

local version = "1.5.1"

repeat task.wait() until game:IsLoaded()

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(67)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

if setfpscap then
    setfpscap(1000000)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "dsc.gg/dyhub",
        Text = "Anti AFK & FPS Unlocked!",
        Duration = 2,
        Button1 = "Okay"
    })
    warn("Anti AFK Enabled & FPS Unlocked!")
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "dsc.gg/dyhub",
        Text = "Anti AFK Enabled (FPS Unlock Not Supported)",
        Duration = 2,
        Button1 = "Okay"
    })
    warn("Anti AFK Enabled but setfpscap is missing.")
end


local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ====================== SERVICES ======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ===================== SETTINGS =====================
local MAX_DISTANCE = 677

local Settings = {
    Auto = {
        Escape = false,
        Barricade = false,
        Generator = false,
        KillAll = false,
        AC = true
    },
    Misc = {
        Fullbright = false,
        NoFog = false
    },
    Setting = {
        Delay = 6,
        Highlight = true,
        Name = true,
        Distance = true,
        Health = true,
        Class = false
    },
    ESP = {
        Survivor = false,
        Killer = false,
        Lobby = false,
        Generator = false,
        FuseBox = false,
        Trap = false,
        Minion = false,
        Axe = false,
        Batteries = false
    }
}

-- ====================== VERSION CHECK ======================
local FreeVersion = "Free Version"
local PremiumVersion = "Premium Version"

local function checkVersion(playerName)
    local url = "https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua"
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then return FreeVersion end

    local func, err = loadstring(response)
    if func then
        local premiumData = func()
        return premiumData[playerName] and PremiumVersion or FreeVersion
    end
    return FreeVersion
end

local userversion = checkVersion(LocalPlayer.Name)

-- ====================== WINDOW SETUP ======================
local Window = WindUI:CreateWindow({
    Title = "DYHUB",
    IconThemed = true,
    Icon = "rbxassetid://104487529937663",
    Author = "Bite by Night | " .. userversion,
    Folder = "DYHUB_BBN",
    Size = UDim2.fromOffset(500, 350),
    Transparent = true,
    Theme = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = { Enabled = true, Anonymous = false },
})

Window:EditOpenButton({
    Title = "DYHUB - Open",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 255, 255)),
    Draggable = true,
})

Window:SetToggleKey(Enum.KeyCode.K)

pcall(function()
    Window:Tag({ Title = version, Color = Color3.fromHex("#30ff6a") })
end)

local InfoTab = Window:Tab({ Title = "Information", Icon = "info" })
local MainDivider1 = Window:Divider()
local Auto = Window:Tab({ Title = "Survivor", Icon = "user-check" })
local Killer = Window:Tab({ Title = "Killer", Icon = "swords" })
local MainDivider = Window:Divider()
local Main = Window:Tab({ Title = "Main", Icon = "rocket" })
local EspTab = Window:Tab({ Title = "Esp", Icon = "eye" })
Window:SelectTab(1)

-- ====================== AUTO GENERATOR ======================
task.spawn(function()
    local hasStarted = false

    while true do
        task.wait(0.2)

        if Settings.Auto.Generator then
            local gui = LocalPlayer:FindFirstChild("PlayerGui")
            local gen = gui and gui:FindFirstChild("Gen")

            if gen then
                if not hasStarted then
                    hasStarted = true
                    task.wait(Settings.Setting.Delay)
                end

                pcall(function()
                    local args = {
                        [1] = {
                            ["Wires"] = true,
                            ["Switches"] = true,
                            ["Lever"] = true
                        }
                    }
                    gen.GeneratorMain.Event:FireServer(unpack(args))
                end)

                task.wait(Settings.Setting.Delay)
            else
                hasStarted = false
            end
        end
    end
end)

-- ====================== ESP CORE ======================
local highlights = {}
local billboards = {}
local connections = {}

local function removeESP(obj)
    if highlights[obj] then highlights[obj]:Destroy() highlights[obj] = nil end
    if billboards[obj] then billboards[obj]:Destroy() billboards[obj] = nil end
    if connections[obj] then connections[obj]:Disconnect() connections[obj] = nil end
end

local function addESP(obj, color, role)
    if not obj or obj == LocalPlayer.Character then return end

    -- ✅ รองรับ MeshPart
    local part
    if obj:IsA("BasePart") then
        part = obj
    else
        part = obj:FindFirstChild("Head") 
            or obj:FindFirstChild("HumanoidRootPart") 
            or obj:FindFirstChildWhichIsA("BasePart", true)
    end

    if not part then return end

    -- 🔥 ลบ Highlight เก่าของ object นี้ก่อน (สำคัญมาก)
    for _,v in pairs(obj:GetDescendants()) do
        if v:IsA("Highlight") then
            v:Destroy()
        end
    end

    -- กันซ้ำเฉพาะ ESP เรา
    if highlights[obj] then return end

    -- ================= Highlight =================
    if Settings.Setting.Highlight then
        local h = Instance.new("Highlight")
        h.FillTransparency = 1
        h.OutlineColor = color
        h.Adornee = obj
        h.Parent = CoreGui
        highlights[obj] = h
    end

    -- ================= Billboard =================
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.new(0, 100, 0, 40)
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeTransparency = 0.25
    label.TextSize = 13
    label.Font = Enum.Font.SourceSans
    label.Parent = gui

    gui.Parent = part
    billboards[obj] = gui

    connections[obj] = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent then removeESP(obj) return end
        
        local roleCheck = role:gsub(" ", "")

        if roleCheck == "Survivor" and not Settings.ESP.Survivor then removeESP(obj) return end
        if roleCheck == "Killer" and not Settings.ESP.Killer then removeESP(obj) return end
        if roleCheck == "Lobby" and not Settings.ESP.Lobby then removeESP(obj) return end
        if roleCheck == "Generators" and not Settings.ESP.Generator then removeESP(obj) return end
        if roleCheck == "FuseBoxes" and not Settings.ESP.FuseBox then removeESP(obj) return end
        if roleCheck == "Batteries" and not Settings.ESP.Batteries then removeESP(obj) return end
        if roleCheck == "Trap" and not Settings.ESP.Trap then removeESP(obj) return end
        if roleCheck == "Minion" and not Settings.ESP.Minion then removeESP(obj) return end
        if roleCheck == "Axe" and not Settings.ESP.Axe then removeESP(obj) return end

        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local dist = (root.Position - part.Position).Magnitude
        if dist > MAX_DISTANCE then removeESP(obj) return end

        local text = ""

        if obj:FindFirstChild("Humanoid") then
            local charAttr = obj:GetAttribute("Character")
            local class = charAttr and tostring(charAttr):gsub("^Survivor%-", "") or "Unknown"
            
            if Settings.Setting.Name and Settings.Setting.Class then
                text = obj.Name .. " | " .. class
            elseif Settings.Setting.Name then
                text = obj.Name
            elseif Settings.Setting.Class then
                text = class
            end

            if Settings.Setting.Health then 
                text = text .. "\n" .. math.floor(obj.Humanoid.Health) .. " HP"
            end
        else
            text = role or "Object"
        end

        if Settings.Setting.Distance then 
            text = text .. "\n" .. math.floor(dist) .. " MM" 
        end
        
        label.Text = text
    end)
end

-- ================= COLORS =================
local COLORS = {
    Survivor = Color3.fromRGB(0, 170, 255),
    Killer = Color3.fromRGB(255, 0, 0),
    Lobby = Color3.fromRGB(255, 255, 255),
    Trap = Color3.fromRGB(255, 65, 65),
    Generators = Color3.fromRGB(255, 255, 0),
    FuseBoxes = Color3.fromRGB(0, 255, 255),
    Minion = Color3.fromRGB(120, 6, 6),
    Axe = Color3.fromRGB(165, 42, 42),
    Batteries = Color3.fromRGB(0, 255, 0)
}

local function scan()
    local playerFolder = workspace:FindFirstChild("PLAYERS")
    if playerFolder then
        for _,folder in pairs(playerFolder:GetChildren()) do
            for _,model in pairs(folder:GetChildren()) do
                if model:IsA("Model") and model ~= LocalPlayer.Character then
                    if folder.Name == "ALIVE" and Settings.ESP.Survivor then addESP(model, COLORS.Survivor, "Survivor")
                    elseif folder.Name == "KILLER" and Settings.ESP.Killer then addESP(model, COLORS.Killer, "Killer")
                    elseif folder.Name == "LOBBY" and Settings.ESP.Lobby then addESP(model, COLORS.Lobby, "Lobby")
                    end
                end
            end
        end
    end

    local maps = workspace:FindFirstChild("MAPS")
    if maps then
        for _,map in pairs(maps:GetChildren()) do

            local function checkObj(fName, setVal)
                local f = map:FindFirstChild(fName)
                if f and setVal then
                    for _,o in pairs(f:GetChildren()) do
                        addESP(o, COLORS[fName] or Color3.new(1,1,1), fName)
                    end
                end
            end
            
            checkObj("Generators", Settings.ESP.Generator)
            checkObj("FuseBoxes", Settings.ESP.FuseBox)

            -- 🔥 Battery FIX
            if Settings.ESP.Batteries then
                local ignoreFolder = workspace:FindFirstChild("IGNORE")
                if ignoreFolder then
                    for _, o in pairs(ignoreFolder:GetChildren()) do
                        if o.Name == "Battery" then
                            addESP(o, COLORS.Batteries, "Batteries")
                        end
                    end
                end
            end

            if Settings.ESP.Minion then
                local ignoreFolder = workspace:FindFirstChild("IGNORE")
                if ignoreFolder then
                    for _, o in pairs(ignoreFolder:GetChildren()) do
                        if o.Name == "Minion" then
                            addESP(o, COLORS.Minion, "Minion")
                        end
                    end
                end
            end

            if Settings.ESP.Axe then
                local ignoreFolder = workspace:FindFirstChild("IGNORE")
                if ignoreFolder then
                    for _, o in pairs(ignoreFolder:GetChildren()) do
                        if o.Name == "Axe" then
                            addESP(o, COLORS.Axe, "Axe")
                        end
                    end
                end
            end

            if Settings.ESP.Trap then
                local ignoreFolder = workspace:FindFirstChild("IGNORE")
                if ignoreFolder then
                    for _,o in pairs(ignoreFolder:GetChildren()) do
                        if o.Name == "Trap" then
                            addESP(o, COLORS.Trap, "Trap")
                        end
                    end
                end

                local trapFolder = workspace:FindFirstChild("Trap")
                if trapFolder then
                    for _,o in pairs(trapFolder:GetChildren()) do
                        addESP(o, COLORS.Trap, "Trap")
                    end
                end
            end
        end
    end
end

local function clearAllESP()
    for obj, _ in pairs(highlights) do removeESP(obj) end
end

task.spawn(function()
    while true do
        task.wait(1)
        scan()
    end
end)

-- ====================== KILLER ======================
Killer:Section({ Title = "Combat", Icon = "swords" })
-- Toggle
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Players = game.Players
local LocalPlayer = Players.LocalPlayer

Killer:Toggle({
    Title = "Auto Kill All (Not Legit)",
    Description = "Automatically teleport to kill survivor all",
    Value = false,
    Callback = function(v)
        Settings.Auto.KillAll = v
        
        if tpConn then 
            tpConn:Disconnect() 
            tpConn = nil 
        end

        if Settings.Auto.KillAll then
            tpConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local closestPlayer = nil
                local shortestDistance = math.huge

                for _, target in ipairs(workspace.PLAYERS.ALIVE:GetChildren()) do
                    local tRoot = target:FindFirstChild("HumanoidRootPart")
                    local tHum = target:FindFirstChild("Humanoid")
                    
                    if tRoot and tHum and tHum.Health > 0 and target ~= char then
                        local distance = (root.Position - tRoot.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = target
                        end
                    end
                end

                if closestPlayer then
                    local tRoot = closestPlayer:FindFirstChild("HumanoidRootPart")
                    root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)

                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end)
        end
    end
})

-- ====================== GUI TABS ======================
Main:Section({ Title = "Anti Cheat", Icon = "cpu" })
-- Toggle
Main:Toggle({
    Title = "Bypass Anti Cheat",
    Description = "Automatically clean Anti Cheat",
    Value = Settings.Auto.AC,
    Callback = function(v)
        Settings.Auto.AC = v
    end
})

-- ================= BYPASS ANTI CHEAT =================
task.spawn(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local oldNamecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if Settings.Auto.AC then
            if method == "FireServer" then
                local name = tostring(self):lower()

                if name:find("anti") 
                or name:find("cheat") 
                or name:find("kick") 
                or name:find("ban") 
                or name:find("detect") then
                    return task.wait(math.huge)
                end
            end
        end

        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end)

-- =================== FULL BRIGHTNESS =============
Main:Section({ Title = "Miscellaneous", Icon = "grid-2x2" })

local lighting = game:GetService("Lighting")
local oldLighting = {}

Main:Toggle({
    Title = "Fullbright",
    Value = Settings.Misc.Fullbright,
    Callback = function(v)
        Settings.Misc.Fullbright = v
        if v then
            oldLighting.Brightness = lighting.Brightness
            oldLighting.ClockTime = lighting.ClockTime
            oldLighting.GlobalShadows = lighting.GlobalShadows
            oldLighting.Ambient = lighting.Ambient
            
            lighting.Brightness = 5
            lighting.ClockTime = 14
            lighting.GlobalShadows = false
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
        else
            if oldLighting.Brightness ~= nil then
                lighting.Brightness = oldLighting.Brightness
                lighting.ClockTime = oldLighting.ClockTime
                lighting.GlobalShadows = oldLighting.GlobalShadows
                lighting.Ambient = oldLighting.Ambient
            end
        end
    end
})

Main:Toggle({
    Title = "No Fog",
    Value = Settings.Misc.NoFog,
    Callback = function(v)
        Settings.Misc.NoFog = v
        if v then
            oldLighting.Density = lighting.Atmosphere.Density
            oldLighting.FogStart = lighting.FogStart
            oldLighting.FogEnd = lighting.FogEnd
            
            lighting.FogStart = 0
            lighting.FogEnd = 9e9
            lighting.Atmosphere.Density = 0
        else
            if oldLighting.FogEnd ~= nil then
                lighting.Atmosphere.Density = oldLighting.Density
                lighting.FogStart = oldLighting.FogStart
                lighting.FogEnd = oldLighting.FogEnd
            end
        end
    end
})

-- Main Tab
Auto:Section({ Title = "Auto Fixing", Icon = "zap" })
Auto:Toggle({
    Title = "Auto Generator",
    Description = "Automatically fixing Generator",
    Value = false,
    Callback = function(v) Settings.Auto.Generator = v end
})
Auto:Slider({
    Title = "Auto Generator Delay",
    Description = "Delay between each fix",
    Value = {Min = 1, Max = 20, Default = 6},
    Callback = function(v) Settings.Setting.Delay = v end
})
Auto:Section({ Title = "Auto Objective", Icon = "door-closed" })
-- Toggle
Auto:Toggle({
    Title = "Auto Barricade",
    Description = "Automatically perfect Barricade",
    Value = false,
    Callback = function(v)
        Settings.Auto.Barricade = v
    end
})

Auto:Section({ Title = "Auto Win", Icon = "crown" })
Auto:Toggle({
    Title = "Auto Escape (Not Legit)",
    Description = "Automatically teleport to Escape",
    Value = false,
    Callback = function(v) 
        Settings.Auto.Escape = v
        
        if v then
            task.spawn(function()
                local player = game:GetService("Players").LocalPlayer
                local teleported = false

                while Settings.Auto.Escape do
                    task.wait(1.25) -- เช็คทุกๆ 0.5 วินาทีก็พอ ไม่ต้องทุกเฟรม

                    if teleported then continue end

                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChild("Humanoid")

                    -- ตรวจสอบเงื่อนไขการหลบหนี
                    local canEscape = workspace.GAME:FindFirstChild("CAN_ESCAPE")
                    if not root or not (canEscape and canEscape.Value) then continue end
                    if char.Parent ~= workspace.PLAYERS.ALIVE then continue end

                    local map = workspace.MAPS:FindFirstChild("GAME MAP")
                    local escapes = map and map:FindFirstChild("Escapes")

                    if escapes then
                        for _, part in pairs(escapes:GetChildren()) do
                            local highlight = part:FindFirstChildOfClass("Highlight")
                            
                            -- เช็คว่าทางออกเปิดใช้งานหรือยัง
                            if part:IsA("BasePart") and part:GetAttribute("Enabled") and (highlight and highlight.Enabled) then
                                teleported = true

                                -- เริ่มกระบวนการวาร์ป
                                root.Anchored = true
                                -- ยกตัวขึ้นเล็กน้อยเพื่อป้องกันการติดพื้น (+3 studs)
                                char:SetPrimaryPartCFrame(part.CFrame * CFrame.new(0, 3, 0))

                                task.wait(1) -- รอให้ Server รับข้อมูลตำแหน่งใหม่
                                if root then root.Anchored = false end

                                -- คูลดาวน์ 10 วินาทีป้องกันการวาร์ปซ้ำซ้อน
                                task.delay(10, function()
                                    teleported = false
                                end)
                                
                                break 
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- ================= AUTO BARRICADE (FILTER ENABLED DOT) =================
task.spawn(function()
    while true do
        task.wait(0.25)

        if Settings.Auto.Barricade then
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local gui = player:FindFirstChild("PlayerGui")

                if gui then
                    -- วนหา Dot ทุกตัว (กันมีหลายอัน)
                    for _, dot in ipairs(gui:GetChildren()) do
                        if dot.Name == "Dot" and dot:IsA("ScreenGui") and dot.Enabled then
                            
                            if dot:FindFirstChild("Container") 
                            and dot.Container:FindFirstChild("Frame") then
                                
                                local frame = dot.Container.Frame

                                -- ปรับตำแหน่งเฉพาะตัวที่เปิดอยู่
                                frame.AnchorPoint = Vector2.new(0,0)
                                frame.Position = UDim2.new(0,675,0,419)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ESP Tab
EspTab:Section({ Title = "Player ESP", Icon = "user" })
EspTab:Toggle({ Title = "Survivor", Value = false, Callback = function(v) Settings.ESP.Survivor = v if not v then clearAllESP() end end })
EspTab:Toggle({ Title = "Killer", Value = false, Callback = function(v) Settings.ESP.Killer = v if not v then clearAllESP() end end })
EspTab:Toggle({ Title = "Lobby", Value = false, Callback = function(v) Settings.ESP.Lobby = v if not v then clearAllESP() end end })

EspTab:Section({ Title = "Hazard ESP", Icon = "sword" })
EspTab:Toggle({ Title = "Axe (Springtrap)", Value = false, Callback = function(v) Settings.ESP.Axe = v if not v then clearAllESP() end end })
EspTab:Toggle({ Title = "Trap (Springtrap)", Value = false, Callback = function(v) Settings.ESP.Trap = v if not v then clearAllESP() end end })
EspTab:Toggle({ Title = "Minion (Doppelganger)", Value = false, Callback = function(v) Settings.ESP.Minion = v if not v then clearAllESP() end end })

EspTab:Section({ Title = "Object ESP", Icon = "package" })
EspTab:Toggle({ Title = "Generator", Value = false, Callback = function(v) Settings.ESP.Generator = v if not v then clearAllESP() end end })
EspTab:Toggle({ Title = "FuseBox", Value = false, Callback = function(v) Settings.ESP.FuseBox = v if not v then clearAllESP() end end })
EspTab:Toggle({ Title = "Batteries", Value = false, Callback = function(v) Settings.ESP.Batteries = v if not v then clearAllESP() end end })

EspTab:Section({ Title = "Setting ESP", Icon = "settings" })
EspTab:Toggle({ Title = "Show Name", Value = true, Callback = function(v) Settings.Setting.Name = v end })
EspTab:Toggle({ Title = "Show Class", Value = false, Callback = function(v) Settings.Setting.Class = v end })
EspTab:Toggle({ Title = "Show Health", Value = true, Callback = function(v) Settings.Setting.Health = v end })
EspTab:Toggle({ Title = "Show Distance", Value = true, Callback = function(v) Settings.Setting.Distance = v end })
EspTab:Toggle({ Title = "Show Highlights", Value = true, Callback = function(v) Settings.Setting.Highlight = v if not v then clearAllESP() end end })

-- Information Tab
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

InfoTab:Section({ Title = "Lasted Update", TextXAlignment = "Center", TextSize = 17 })
InfoTab:Divider()

InfoTab:Paragraph({
    Title = "Update: 05/04/2026",
    Desc = "- [ Fixed ] Auto Escape \n- [ Fixed ] Auto Barricade \n- [ Fixed ] Esp Battery \n- [ Added ] Esp Axe \n- [ Added ] Esp Minion",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})

InfoTab:Section({ Title = "Discord Server", TextXAlignment = "Center", TextSize = 17 })
InfoTab:Divider()

ui.Creator.Request = function(requestData)
    local HttpService = game:GetService("HttpService")
    local success, result = pcall(function()
        if HttpService.RequestAsync then
            local response = HttpService:RequestAsync({
                Url = requestData.Url,
                Method = requestData.Method or "GET",
                Headers = requestData.Headers or {}
            })
            return { Body = response.Body, StatusCode = response.StatusCode, Success = response.Success }
        else
            local body = HttpService:GetAsync(requestData.Url)
            return { Body = body, StatusCode = 200, Success = true }
        end
    end)
    return success and result or error("HTTP Request failed")
end

local InviteCode = "jWNDPNMmyB"
local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local function LoadDiscordInfo()
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(ui.Creator.Request({
            Url = DiscordAPI,
            Method = "GET",
            Headers = { ["User-Agent"] = "RobloxBot/1.0", ["Accept"] = "application/json" }
        }).Body)
    end)

    if success and result and result.guild then
        local DiscordInfo = InfoTab:Paragraph({
            Title = result.guild.name,
            Desc = ' <font color="#52525b">●</font> Member Count : ' .. tostring(result.approximate_member_count) ..
                '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(result.approximate_presence_count),
            Image = "https://cdn.discordapp.com/icons/" .. result.guild.id .. "/" .. result.guild.icon .. ".png?size=1024",
            ImageSize = 42,
        })

        InfoTab:Button({
            Title = "Update Info",
            Callback = function()
                local updated, updatedResult = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(ui.Creator.Request({ Url = DiscordAPI, Method = "GET" }).Body)
                end)
                if updated and updatedResult.guild then
                    DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : ' .. tostring(updatedResult.approximate_member_count) .. '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(updatedResult.approximate_presence_count))
                end
            end
        })

        InfoTab:Button({
            Title = "Copy Discord Invite",
            Callback = function() setclipboard("https://discord.gg/" .. InviteCode) end
        })
    end
end

LoadDiscordInfo()

InfoTab:Divider()
InfoTab:Section({ Title = "DYHUB Information", TextXAlignment = "Center", TextSize = 17 })
InfoTab:Divider()

InfoTab:Paragraph({
    Title = "Main Owner",
    Desc = "@dyumraisgoodguy#8888",
    Image = "rbxassetid://119789418015420",
    ImageSize = 30,
})

InfoTab:Paragraph({
    Title = "Social",
    Desc = "Copy link social media for follow!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Buttons = {{
        Icon = "copy",
        Title = "Copy Link",
        Callback = function() setclipboard("https://guns.lol/DYHUB") end,
    }}
})

InfoTab:Paragraph({
    Title = "Discord",
    Desc = "Join our discord for more scripts!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Buttons = {{
        Icon = "copy",
        Title = "Copy Link",
        Callback = function() setclipboard("https://discord.gg/jWNDPNMmyB") end,
    }}
})
