--// =========================
--// v2 | SZA
--// =========================

local version = "BETA"

repeat task.wait() until game:IsLoaded()

--// FPS Unlock
pcall(function()
    if setfpscap then
        setfpscap(1000000)

        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "dsc.gg/dyhub",
            Text = "FPS Unlocked!",
            Duration = 3
        })

        warn("FPS Unlocked!")
    else
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "dsc.gg/dyhub",
            Text = "Executor unsupported setfpscap",
            Duration = 3
        })
    end
end)

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

--// UI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--// Premium Check
local FreeVersion = "Free Version"
local PremiumVersion = "Premium Version"

local function checkVersion(playerName)
    local url = "https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua"

    local success,response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        return FreeVersion
    end

    local func = loadstring(response)

    if not func then
        return FreeVersion
    end

    local data = func()

    if data[playerName] then
        return PremiumVersion
    end

    return FreeVersion
end

local userversion = checkVersion(LocalPlayer.Name)

--// Window
local Window = WindUI:CreateWindow({
    Title = "DYHUB",
    IconThemed = true,
    Icon = "rbxassetid://104487529937663",
    Author = "Survive Zombie Arena | "..userversion,
    Folder = "DYHUB_SZA",
    Size = UDim2.fromOffset(520,380),
    Transparent = true,
    Theme = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = false
    }
})

Window:SetToggleKey(Enum.KeyCode.K)

pcall(function()
    Window:Tag({
        Title = version,
        Color = Color3.fromHex("#30ff6a")
    })
end)

Window:EditOpenButton({
    Title = "DYHUB",
    Icon = "monitor",
    CornerRadius = UDim.new(0,6),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromRGB(30,30,30),
        Color3.fromRGB(255,255,255)
    ),
    Draggable = true
})

--// Tabs
local Main = Window:Tab({
    Title = "Main",
    Icon = "rocket"
})

local Upgrade = Window:Tab({
    Title = "Upgrades",
    Icon = "shopping-cart"
})

local Misc = Window:Tab({
    Title = "Misc",
    Icon = "settings"
})

Window:SelectTab(1)

--// Globals
getgenv().KillAura = false
getgenv().SafeZone = false
getgenv().InstantWave = false

getgenv().AutoHeal = false
getgenv().AutoWeapon = false

getgenv().SkillE = false
getgenv().SkillR = false
getgenv().SkillQ = false

getgenv().AutoRejoin = false
getgenv().AutoEquip = false

local savedCFrame

--// Remotes
local gunRemote = ReplicatedStorage:WaitForChild("GunRemotes"):WaitForChild("GunHit")

--// Functions
local function getCharacter()
    return LocalPlayer.Character
end

local function getRoot()
    local char = getCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
end

local function equipTool()
    local char = getCharacter()
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")

    if tool then
        return tool
    end

    for _,v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            v.Parent = char
            return v
        end
    end
end

local function spamKey(key,global)
    task.spawn(function()
        while getgenv()[global] do
            task.wait(1)

            VirtualInputManager:SendKeyEvent(true,key,false,game)
            VirtualInputManager:SendKeyEvent(false,key,false,game)
        end
    end)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local GR = ReplicatedStorage:WaitForChild("GunRemotes")
local GH = GR:WaitForChild("GunHit")

task.spawn(function()
    while getgenv().KillAura do
        local char = LP.Character or LP.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")

        if hum and hum.Health > 0 then
            local tool = char:FindFirstChildOfClass("Tool")

            if not tool then
                for _,v in ipairs(LP.Backpack:GetChildren()) do
                    if v:IsA("Tool") then
                        hum:EquipTool(v)
                        tool = v
                        break
                    end
                end
            end

            if tool then
                local zombies = workspace:FindFirstChild("Zombies_Local")

                if zombies then
                    for _,z in ipairs(zombies:GetChildren()) do
                        local hrp = z:FindFirstChild("HumanoidRootPart")

                        if hrp then
                            local id = tonumber(z.Name:match("%d+"))

                            if id then
                                GH:FireServer(
                                    tool.Name,
                                    id,
                                    hrp.Position
                                )
                            end
                        end
                    end
                end
            end
        end

        task.wait(0.03)
    end
end)

--// Auto Equip
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoEquip then
            pcall(function()
                equipTool()
            end)
        end
    end
end)

--// Auto Rejoin
LocalPlayer.CharacterRemoving:Connect(function()
    if getgenv().AutoRejoin then
        task.wait(3)
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
end)

--// =========================
--// MAIN
--// =========================

Main:Section({
    Title = "Auto Farm",
    Icon = "swords"
})

Main:Toggle({
    Title = "Kill Aura",
    Desc = "Automatically kill zombies",
    Default = false,
    Callback = function(state)
        getgenv().KillAura = state

        if state then
            startKillAura()
        end
    end
})

Main:Toggle({
    Title = "Auto Equip",
    Desc = "Automatically equip weapon",
    Default = false,
    Callback = function(state)
        getgenv().AutoEquip = state
    end
})

Main:Toggle({
    Title = "Safe Zone",
    Desc = "Float above zombies",
    Default = false,
    Callback = function(state)

        getgenv().SafeZone = state

        local char = getCharacter()

        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.HipHeight = state and 20 or 2
        end
    end
})

Main:Toggle({
    Title = "Instant Wave",
    Desc = "Teleport to hidden area",
    Default = false,
    Callback = function(state)

        getgenv().InstantWave = state

        local root = getRoot()

        if not root then
            return
        end

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

--// =========================
--// SKILLS
--// =========================

Main:Section({
    Title = "Skills",
    Icon = "zap"
})

Main:Toggle({
    Title = "Spam E",
    Desc = "Auto use E",
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
    Desc = "Auto use R",
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
    Desc = "Auto use Q",
    Default = false,
    Callback = function(state)

        getgenv().SkillQ = state

        if state then
            spamKey(Enum.KeyCode.Q,"SkillQ")
        end
    end
})

--// =========================
--// UPGRADES
--// =========================

Upgrade:Section({
    Title = "Auto Upgrade",
    Icon = "shopping-cart"
})

Upgrade:Toggle({
    Title = "Auto Heal Upgrade",
    Desc = "Automatically buy HP upgrades",
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
    Desc = "Automatically buy weapon upgrades",
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

--// =========================
--// MISC
--// =========================

Misc:Section({
    Title = "Misc",
    Icon = "settings"
})

Misc:Button({
    Title = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

Misc:Toggle({
    Title = "Auto Rejoin",
    Desc = "Rejoin after kick/death",
    Default = false,
    Callback = function(state)
        getgenv().AutoRejoin = state
    end
})

--// Notification
pcall(function()

    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "DYHUB",
        Text = "Loaded Successfully!",
        Duration = 5
    })

end)

warn("DYHUB Loaded")
