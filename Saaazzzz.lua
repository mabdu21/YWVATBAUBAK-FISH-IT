-- =========================
local version = "BETA"
-- =========================

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
    warn("Your exploit does not support setfpscap.")
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local FreeVersion = "Free Version"
local PremiumVersion = "Premium Version"

local function checkVersion(playerName)
    local url = "https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua"

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        return FreeVersion
    end

    local premiumData
    local func, err = loadstring(response)
    if func then
        premiumData = func()
    else
        return FreeVersion
    end

    if premiumData[playerName] then
        return PremiumVersion
    else
        return FreeVersion
    end
end

local player = Players.LocalPlayer
local userversion = checkVersion(player.Name)

local Window = WindUI:CreateWindow({
    Title = "DYHUB",
    IconThemed = true,
    Icon = "rbxassetid://104487529937663",
    Author = "Survive Zombie Arena | " .. userversion,
    Folder = "DYHUB_SZA",
    Size = UDim2.fromOffset(500, 350),
    Transparent = true,
    Theme = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.K)

pcall(function()
    Window:Tag({
        Title = version,
        Color = Color3.fromHex("#30ff6a")
    })
end)

Window:EditOpenButton({
    Title = "DYHUB - Open",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 255, 255)),
    Draggable = true,
})


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- Tabs
local Main = Window:Tab({
    Title = "Main",
    Icon = "rocket"
})

local Upgrade = Window:Tab({
    Title = "Upgrades",
    Icon = "shopping-cart"
})


Window:SelectTab(1)

-- =========================
-- VARIABLES
-- =========================

getgenv().KillAura = false
getgenv().SafeZone = false
getgenv().InstantWave = false

getgenv().AutoHeal = false
getgenv().AutoWeapon = false

getgenv().SkillE = false
getgenv().SkillR = false
getgenv().SkillQ = false

local savedCFrame

-- =========================
-- FUNCTIONS
-- =========================

local function equipTool()
    local char = LocalPlayer.Character
    if not char then return nil end

    local tool = char:FindFirstChildOfClass("Tool")

    if tool then
        return tool
    end

    for _,v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            v.Parent = char
            return v
        end
    end
end


local gunRemote = ReplicatedStorage:WaitForChild("GunRemotes"):WaitForChild("GunHit")

local function startKillAura()
    task.spawn(function()
        while getgenv().KillAura do
            task.wait(0.05)

            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end

                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local tool = equipTool()
                if not tool then return end

                local zombies = workspace:FindFirstChild("Zombies_Local")
                if not zombies then return end

                local count = 0

                for _,zombie in ipairs(zombies:GetChildren()) do
                    if count >= 8 then
                        break
                    end

                    local zroot = zombie:FindFirstChild("HumanoidRootPart")

                    if zroot then
                        local dist = (root.Position - zroot.Position).Magnitude

                        if dist <= 120 then
                            local id = tonumber(zombie.Name:match("%d+"))

                            if id then
                                gunRemote:FireServer(
                                    tool.Name,
                                    id,
                                    zroot.Position
                                )

                                count += 1
                            end
                        end
                    end
                end
            end)
        end
    end)
end

local function spamKey(key, global)
    task.spawn(function()
        while getgenv()[global] do
            task.wait(1)

            VirtualInputManager:SendKeyEvent(
                true,
                key,
                false,
                game
            )

            VirtualInputManager:SendKeyEvent(
                false,
                key,
                false,
                game
            )
        end
    end)
end

-- =========================
-- MAIN
-- =========================

Main:Section({
    Title = "Auto Farm",
    Icon = "swords"
})

Main:Toggle({
    Title = "Kill Aura",
    Desc = "Automatically kill all zombies",
    Default = false,
    Callback = function(state)
        getgenv().KillAura = state

        if state then
            startKillAura()
        end
    end
})

Main:Toggle({
    Title = "Safe Zone",
    Desc = "Fly above zombies",
    Default = false,
    Callback = function(state)
        getgenv().SafeZone = state

        local char = LocalPlayer.Character

        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.HipHeight = state and 20 or 2
        end
    end
})

Main:Toggle({
    Title = "Instant Clear Wave",
    Desc = "Teleport to safe area",
    Default = false,
    Callback = function(state)
        getgenv().InstantWave = state

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if not root then return end

        if state then
            savedCFrame = root.CFrame

            root.CFrame = CFrame.new(31,-67,-145)

            task.wait(0.2)

            root.Anchored = true
        else
            root.Anchored = false

            if savedCFrame then
                root.CFrame = savedCFrame
            end
        end
    end
})

-- =========================
-- UPGRADES
-- =========================

Upgrade:Section({
    Title = "Auto Upgrade",
    Icon = "shopping-cart"
})

Upgrade:Toggle({
    Title = "Auto Heal Upgrade",
    Desc = "Automatically upgrade health",
    Default = false,
    Callback = function(state)
        getgenv().AutoHeal = state

        if state then
            task.spawn(function()
                while getgenv().AutoHeal do
                    task.wait(1)

                    pcall(function()
                        ReplicatedStorage
                            .UpgradeRemotes
                            .PurchaseHealthUpgrade
                            :FireServer()
                    end)
                end
            end)
        end
    end
})

Upgrade:Toggle({
    Title = "Auto Weapon Upgrade",
    Desc = "Automatically upgrade weapon",
    Default = false,
    Callback = function(state)
        getgenv().AutoWeapon = state

        if state then
            task.spawn(function()
                while getgenv().AutoWeapon do
                    task.wait(1)

                    pcall(function()
                        ReplicatedStorage
                            .UpgradeRemotes
                            .PurchaseWeaponUpgrade
                            :FireServer()
                    end)
                end
            end)
        end
    end
})

-- =========================
-- SKILLS
-- =========================

Main:Section({
    Title = "Auto Skills",
    Icon = "zap"
})

Main:Toggle({
    Title = "Spam E",
    Desc = "Auto use E skill",
    Default = false,
    Callback = function(state)
        getgenv().SkillE = state

        if state then
            spamKey(Enum.KeyCode.E,"SkillE")
        end
    end
})

Main:Toggle({
    Title = "Spam R",
    Desc = "Auto use R skill",
    Default = false,
    Callback = function(state)
        getgenv().SkillR = state

        if state then
            spamKey(Enum.KeyCode.R,"SkillR")
        end
    end
})

Main:Toggle({
    Title = "Spam Q",
    Desc = "Auto use Q skill",
    Default = false,
    Callback = function(state)
        getgenv().SkillQ = state

        if state then
            spamKey(Enum.KeyCode.Q,"SkillQ")
    end
})

