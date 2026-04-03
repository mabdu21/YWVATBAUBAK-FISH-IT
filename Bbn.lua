-- ==========================================
-- Test V517
-- ==========================================

local version = "5.4.0"

repeat task.wait() until game:IsLoaded()

-- FPS Unlock
if setfpscap then
    setfpscap(1000000)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "dsc.gg/dyhub",
        Text = "FPS Unlocked!",
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
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ====================== SERVICES ======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ===================== SETTINGS =====================
local MAX_DISTANCE = 500

local Settings = {
    Auto = {
        Generator = false
    },
    Setting = {
        Delay = 6,
        Highlight = true,
        Name = true,
        Distance = true,
        Health = true,
        Class = true
    },
    ESP = {
        Survivor = false,
        Killer = false,
        Generator = false,
        FuseBox = false,
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
local Main = Window:Tab({ Title = "Main", Icon = "rocket" })
local EspTab = Window:Tab({ Title = "ESP", Icon = "eye" })
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
                -- ครั้งแรกที่เจอ
                if not hasStarted then
                    hasStarted = true
                    task.wait(Settings.Setting.Delay)
                end

                -- ยิงตลอดทุก 6 วิ
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
                -- ถ้า GUI หาย รีเซ็ตสถานะ
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
    local part = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart", true)
    if not part or highlights[obj] then return end

    if Settings.Setting.Highlight then
        local h = Instance.new("Highlight")
        h.FillTransparency = 1
        h.OutlineColor = color
        h.Adornee = obj
        h.Parent = CoreGui
        highlights[obj] = h
    end

    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.new(0, 100, 0, 40)
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeTransparency = 0.5
    label.TextSize = 12
    label.Font = Enum.Font.SourceSans
    label.Parent = gui
    gui.Parent = part
    billboards[obj] = gui

    connections[obj] = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent then removeESP(obj) return end
        
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local dist = (root.Position - part.Position).Magnitude

        if dist > MAX_DISTANCE then removeESP(obj) return end

        local text = ""
        if obj:FindFirstChild("Humanoid") then
            if Settings.Setting.Name then 
                local charAttr = obj:GetAttribute("Character")
                local class = charAttr and tostring(charAttr):gsub("^Survivor%-", "") or ""
                text = Settings.Setting.Class and (obj.Name .. " | " .. class) or obj.Name 
            end
            if Settings.Setting.Health then text = text .. "\n" .. math.floor(obj.Humanoid.Health) .. " HP" end
        else
            text = role or "Object"
        end
        if Settings.Setting.Distance then text = text .. "\n" .. math.floor(dist) .. " MM" end
        label.Text = text
    end)
end

local COLORS = {
    Survivor = Color3.fromRGB(0, 170, 255),
    Killer = Color3.fromRGB(255, 0, 0),
    Generator = Color3.fromRGB(255, 255, 0),
    FuseBoxes = Color3.fromRGB(0, 255, 255),
    Batteries = Color3.fromRGB(0, 255, 0)
}

local function scan()
    -- Scan Players
    local playerFolder = workspace:FindFirstChild("PLAYERS")
    if playerFolder then
        for _,folder in pairs(playerFolder:GetChildren()) do
            for _,model in pairs(folder:GetChildren()) do
                if model:IsA("Model") and model ~= LocalPlayer.Character then
                    if folder.Name == "ALIVE" and Settings.ESP.Survivor then addESP(model, COLORS.Survivor, "Survivor")
                    elseif folder.Name == "KILLER" and Settings.ESP.Killer then addESP(model, COLORS.Killer, "Killer")
                    else removeESP(model) end
                end
            end
        end
    end
    -- Scan Objects
    local maps = workspace:FindFirstChild("MAPS")
    if maps then
        for _,map in pairs(maps:GetChildren()) do
            local function checkObj(fName, setVal)
                local f = map:FindFirstChild(fName)
                if f and setVal then
                    for _,o in pairs(f:GetChildren()) do addESP(o, COLORS[fName] or Color3.new(1,1,1), fName) end
                end
            end
            checkObj("Generators", Settings.ESP.Generator)
            checkObj("FuseBoxes", Settings.ESP.FuseBox)
            checkObj("Batteries", Settings.ESP.Batteries)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        scan()
    end
end)

-- ====================== GUI TABS ======================

-- Main Tab
Main:Section({ Title = "Auto Object", Icon = "zap" })
Main:Toggle({
    Title = "Auto Generator",
    Description = "Automatically fixing Generator",
    Value = false,
    Callback = function(v) Settings.Auto.Generator = v end
})
Main:Slider({
    Title = "Auto Generator Delay",
    Description = "Delay between each fix",
    Value = {Min = 1, Max = 20, Default = 6},
    Callback = function(v) Settings.Setting.Delay = v end
})

-- ESP Tab
EspTab:Section({ Title = "Player ESP", Icon = "user" })
EspTab:Toggle({ Title = "Survivor", Value = false, Callback = function(v) Settings.ESP.Survivor = v end })
EspTab:Toggle({ Title = "Killer", Value = false, Callback = function(v) Settings.ESP.Killer = v end })

EspTab:Section({ Title = "Object ESP", Icon = "package" })
EspTab:Toggle({ Title = "Generator", Value = false, Callback = function(v) Settings.ESP.Generator = v end })
EspTab:Toggle({ Title = "FuseBox", Value = false, Callback = function(v) Settings.ESP.FuseBox = v end })
EspTab:Toggle({ Title = "Batteries", Value = false, Callback = function(v) Settings.ESP.Batteries = v end })

EspTab:Section({ Title = "Setting ESP", Icon = "settings" })
EspTab:Toggle({ Title = "Show Name", Value = true, Callback = function(v) Settings.Setting.Name = v end })
EspTab:Toggle({ Title = "Show Class", Value = false, Callback = function(v) Settings.Setting.Class = v end })
EspTab:Toggle({ Title = "Show Health", Value = false, Callback = function(v) Settings.Setting.Health = v end })
EspTab:Toggle({ Title = "Show Distance", Value = true, Callback = function(v) Settings.Setting.Distance = v end })
EspTab:Toggle({ Title = "Show Highlights", Value = true, Callback = function(v) Settings.Setting.Highlight = v end })

-- Information Tab
Info = InfoTab

if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

-- Define the Request function that mimics ui.Creator.Request
ui.Creator.Request = function(requestData)
    local HttpService = game:GetService("HttpService")
    
    -- Try different HTTP methods
    local success, result = pcall(function()
        if HttpService.RequestAsync then
            -- Method 1: Use RequestAsync if available
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
            -- Method 2: Fallback to GetAsync
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

-- Remove this line completely: Info = InfoTab
-- The Info variable is already correctly set above

local InviteCode = "jWNDPNMmyB"
local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local function LoadDiscordInfo()
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(ui.Creator.Request({
            Url = DiscordAPI,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "RobloxBot/1.0",
                ["Accept"] = "application/json"
            }
        }).Body)
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
                    return game:GetService("HttpService"):JSONDecode(ui.Creator.Request({
                        Url = DiscordAPI,
                        Method = "GET",
                    }).Body)
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
        print("Discord API Error:", result) -- Debug print
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
