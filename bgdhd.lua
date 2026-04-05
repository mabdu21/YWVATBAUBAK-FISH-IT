local version = "DUPE"

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
local Settings = {
    inf = {
        Coin = false,
        Exp = true
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
    Author = "Get Fat to Splash | " .. userversion,
    Folder = "DYHUB_GFTS",
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
    Window:Tag({ Title = version, Color = Color3.fromHex("#ff0000") })
end)

local InfoTab = Window:Tab({ Title = "Information", Icon = "info" })
local MainDivider1 = Window:Divider()
local Main = Window:Tab({ Title = "Main", Icon = "rocket" })
Window:SelectTab(1)

-- ส่วนของ Infinite Coin
Main:Toggle({
    Title = "Infinite Coin (Loop)",
    Description = "Get infinite coin periodically",
    Value = false,
    Callback = function(v)
        Settings.inf.Coin = v
        if v then
            task.spawn(function()
                while Settings.inf.Coin do
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("E&F")
                    if remote and remote.Eco:FindFirstChild("AddEcoRE") then
                        remote.Eco.AddEcoRE:FireServer("coin", math.huge)
                    end
                    task.wait(0.5) -- ปรับเวลาหน่วงตามความเหมาะสมเพื่อไม่ให้โดนเตะ (Kick)
                end
            end)
        end
    end
})

-- ส่วนของ Infinite Fat (Exp)
Main:Toggle({
    Title = "Infinite Fat (Loop)",
    Description = "Get infinite fat/exp periodically",
    Value = false,
    Callback = function(v)
        Settings.inf.Exp = v
        if v then
            task.spawn(function()
                while Settings.inf.Exp do
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("E&F")
                    if remote and remote.Eco:FindFirstChild("AddEcoRE") then
                        remote.Eco.AddEcoRE:FireServer("exp", math.huge)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
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
