--// =========================
--// vyqyq | SZA
--// =========================

repeat task.wait() until game:IsLoaded()

local version = "BETA"
local ver = "v009"

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer

--// UI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--// FPS Unlock
if setfpscap then
    setfpscap(1000000)

    WindUI:Notify({
        Title = "Service",
        Content = "FPS Unlocked! | "..ver,
        Duration = 3,
        Icon = "cpu"
    })

else

    WindUI:Notify({
        Title = "Not Working",
        Content = "Your exploit does not support setfpscap.",
        Duration = 3,
        Icon = "ban"
    })

end

--// Window
local Window = WindUI:CreateWindow({
    Title = "DYHUB",
    IconThemed = true,
    Icon = "rbxassetid://104487529937663",
    Author = "Survive Zombie Arena",
    Folder = "DYHUB_SZA",
    Size = UDim2.fromOffset(520,380),
    Transparent = true,
    Theme = "Dark",
    BackgroundImageTransparency = 0.8,
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
        Color = Color3.fromRGB(0,255,100)
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


--// Tabs
local Main = Window:Tab({
    Title = "Main",
    Icon = "rocket"
})

local Upgrade = Window:Tab({
    Title = "Upgrade",
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

getgenv().AutoEquip = false
getgenv().AutoRejoin = false

local savedCFrame
local killauraloop = false

--// Remotes
local GunHit =
    ReplicatedStorage
    :WaitForChild("GunRemotes")
    :WaitForChild("GunHit")

--// Functions
local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function getRoot()
    local c = getChar()
    return c:FindFirstChild("HumanoidRootPart")
end

local function equipTool()

    local char = getChar()

    local tool = char:FindFirstChildOfClass("Tool")

    if tool then
        return tool
    end

    local hum = char:FindFirstChildOfClass("Humanoid")

    if hum then

        for _,v in ipairs(LP.Backpack:GetChildren()) do

            if v:IsA("Tool") then

                hum:EquipTool(v)

                return v

            end
        end
    end
end

local function spamKey(key,var)

    task.spawn(function()

        while getgenv()[var] do

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

            task.wait(1)

        end

    end)
end

--// Kill Aura
local function startKillAura()

    if killauraloop then
        return
    end

    killauraloop = true

    task.spawn(function()

        while getgenv().KillAura do

            local char =
                LP.Character
                or LP.CharacterAdded:Wait()

            local hum =
                char:FindFirstChildOfClass("Humanoid")

            if hum and hum.Health > 0 then

                local tool =
                    char:FindFirstChildOfClass("Tool")

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

                    local zombies =
                        workspace:FindFirstChild("Zombies_Local")

                    if zombies then

                        for _,z in ipairs(zombies:GetChildren()) do

                            local hrp =
                                z:FindFirstChild("HumanoidRootPart")

                            if hrp then

                                local id =
                                    tonumber(z.Name:match("%d+"))
                                    or z:GetAttribute("Id")
                                    or z:GetAttribute("ID")

                                if id then

                                    pcall(function()

                                        for i = 1,2 do

                                            GunHit:FireServer(
                                                tool.Name,
                                                id,
                                                hrp.Position
                                            )

                                        end

                                    end)

                                end
                            end
                        end
                    end
                end
            end

            task.wait(0.03)

        end

        killauraloop = false

    end)
end

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
LP.CharacterRemoving:Connect(function()

    if getgenv().AutoRejoin then

        task.wait(3)

        TeleportService:Teleport(game.PlaceId)

    end
end)

--// =========================
--// MAIN
--// =========================

Main:Section({
    Title = "Farm",
    Icon = "swords"
})

Main:Toggle({
    Title = "Kill Aura",
    Desc = "Kill all zombies",
    Default = false,
    Callback = function(v)

        getgenv().KillAura = v

        if v then
            startKillAura()
        end
    end
})

Main:Toggle({
    Title = "Auto Equip",
    Desc = "Equip weapon automatically",
    Default = false,
    Callback = function(v)

        getgenv().AutoEquip = v

    end
})

Main:Toggle({
    Title = "Safe Zone",
    Desc = "Float above zombies",
    Default = false,
    Callback = function(v)

        getgenv().SafeZone = v

        local char = getChar()

        local hum =
            char:FindFirstChildOfClass("Humanoid")

        if hum then
            hum.HipHeight = v and 20 or 2
        end
    end
})

Main:Toggle({
    Title = "Instant Wave",
    Desc = "Teleport hidden spot",
    Default = false,
    Callback = function(v)

        getgenv().InstantWave = v

        local root = getRoot()

        if not root then
            return
        end

        if v then

            savedCFrame = root.CFrame

            root.CFrame =
                CFrame.new(31,-67,-145)

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
    Default = false,
    Callback = function(v)

        getgenv().SkillE = v

        if v then
            spamKey(Enum.KeyCode.E,"SkillE")
        end
    end
})

Main:Toggle({
    Title = "Spam R",
    Default = false,
    Callback = function(v)

        getgenv().SkillR = v

        if v then
            spamKey(Enum.KeyCode.R,"SkillR")
        end
    end
})

Main:Toggle({
    Title = "Spam Q",
    Default = false,
    Callback = function(v)

        getgenv().SkillQ = v

        if v then
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
    Default = false,
    Callback = function(v)

        getgenv().AutoHeal = v

        if v then

            task.spawn(function()

                while getgenv().AutoHeal do

                    pcall(function()

                        ReplicatedStorage
                        .UpgradeRemotes
                        .PurchaseHealthUpgrade
                        :FireServer()

                    end)

                    task.wait(1)

                end
            end)
        end
    end
})

Upgrade:Toggle({
    Title = "Auto Weapon Upgrade",
    Default = false,
    Callback = function(v)

        getgenv().AutoWeapon = v

        if v then

            task.spawn(function()

                while getgenv().AutoWeapon do

                    pcall(function()

                        ReplicatedStorage
                        .UpgradeRemotes
                        .PurchaseWeaponUpgrade
                        :FireServer()

                    end)

                    task.wait(1)

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

        TeleportService:Teleport(game.PlaceId)

    end
})

Misc:Toggle({
    Title = "Auto Rejoin",
    Default = false,
    Callback = function(v)

        getgenv().AutoRejoin = v

    end
})

--// Notify
pcall(function()

    game:GetService("StarterGui"):SetCore(
        "SendNotification",
        {
            Title = "DYHUB",
            Text = "Loaded Successfully",
            Duration = 5
        }
    )

end)

warn("DYHUB Loaded")
