if Library then
    Library:Unload()
end

game.Players.LocalPlayer.Character.Humanoid.Health = 0

game:GetService('Players').LocalPlayer.CharacterAdded:Wait()
loadstring(game:HttpGet('https://raw.githubusercontent.com/mabdu21/YWVATBAUBAK-FISH-IT/refs/heads/main/dddd/dhdhdhdhdh/ap'))()

loadstring(game:HttpGet('https://raw.githubusercontent.com/mabdu21/YWVATBAUBAK-FISH-IT/refs/heads/main/dddd/dhdhdhdhdh/fp'))()

local placeId = game.PlaceId

if placeId == 17887390746 or placeId == 17887392216 or placeId == 17793786340 or placeId == 14202073004 then
    loadstring(game:HttpGet('https://raw.githubusercontent.com/mabdu21/YWVATBAUBAK-FISH-IT/refs/heads/main/dddd/unnamed'))()

    return
end

local isDaHood = (game.PlaceId == 2788229376)

if not game:IsLoaded() then
    game.Loaded:Wait()
end
if getnamecallmethod then
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua', true))()
end

coroutine.wrap(function()
    local success, err = pcall(function()
        local gamerawmetatable = getrawmetatable(game)

        setreadonly(gamerawmetatable, false)

        old__namecall1 = gamerawmetatable.__namecall
        gamerawmetatable.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local remoteName = tostring(args[1])
            local blockedRemotes = {
                TeleportDetect = true,
                CHECKER_1 = true,
                CHECKER = true,
                GUI_CHECK = true,
                OneMoreTime = true,
                checkingSPEED = true,
                BANREMOTE = true,
                PERMAIDBAN = true,
                KICKREMOTE = true,
                BR_KICKPC = true,
                BR_KICKMOBILE = true,
            }

            if blockedRemotes[remoteName] then
                return
            end

            return old__namecall1(self, ...)
        end)
    end)

    if not success then
        warn('[Anti-RemoteBlock] Executor not support hook metatable (__namecall). Skipped.')
    end

    warn('[+] DYHUB : anticheat bypassed.')
end)()

local repo = 'https://raw.githubusercontent.com/mabdu21/YWVATBAUBAK-FISH-IT/refs/heads/main/dddd/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles

Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = true
Library.NotifySide = 'Right'

local TextChatService = game:GetService('TextChatService')
local chatWindow = TextChatService:FindFirstChild('ChatWindowConfiguration')
local ChatEnabled = true

if ChatEnabled and chatWindow then
    chatWindow.Enabled = true
end

local Camera = workspace.CurrentCamera
local Username = '@' .. game.Players.LocalPlayer.Name
local gameName = game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name
local FooterText = 'DYHUB | dsc.gg/dyhub | ' .. gameName .. ' | ' .. Username
local Window = Library:CreateWindow({
    Title = 'DYHUB',
    Footer = FooterText,
    Icon = 104487529937663,
    NotifySide = 'Right',
    ShowCustomCursor = false,
    AutoShow = true,
    MobileButtonsSide = 'Left',
})
local plr = game.Players.LocalPlayer
local mps = game:GetService('MarketplaceService')
local ownerList = {
    anhchangm5 = true,
    Dao_Beo = true,
    anhchangm52 = true,
    anhaycogihontoi = true,
    anhchongyeuvo = true,
    anhchangm53 = true,
}

getgenv().premiumUsers = {}

Library:Notify('If you pay for this script you get scammed, this script is completely free ok', 15)

local isOwner = ownerList[plr.Name] == true

local function checkPremium()
    local owns = false

    pcall(function()
        owns = mps:UserOwnsGamePassAsync(plr.UserId, 1651339821)
    end)

    return owns or getgenv().premiumUsers[plr.Name] == true
end
local hasPremium = checkPremium()

if isOwner then
    Library:Notify('Owner DYHUB User! Welcome ' .. plr.DisplayName .. ' (@' .. plr.Name .. ')', 15)
end
if hasPremium then
    Library:Notify('Premium User! Welcome ' .. plr.DisplayName .. ' (@' .. plr.Name .. ')', 10)
end
if not isOwner then
    if not hasPremium then
        Library:Notify('Premium User! Welcome ' .. plr.DisplayName .. ' (@' .. plr.Name .. ')', 10)
    end
end

local Tabs = {
    Main = Window:AddTab('Main', 'sword'),
    Target = Window:AddTab('Target', 'target'),
    Player = Window:AddTab('Player', 'users'),
    Visual = Window:AddTab('Visual', 'eye'),
    World = Window:AddTab('World', 'trees'),
    Character = Window:AddTab('Character', 'user'),
    Misc = Window:AddTab('Misc', 'heart'),
    Extra = Window:AddTab('Extra', 'star'),
    ['UI Settings'] = Window:AddTab('UI Settings', 'settings'),
}
local previousTargetHealth = {}
local BuyingActive = false
local AutoKillActive = false
local AutoHealActive = false
local AutoArmorActive = false

getgenv().DYHUB = {}

local DYHUBcc = {
    TargetAim = {
        Enabled = true,
        Target = 'None',
        AutoSelect = false,
        PredictMode = '',
        AutoFire = false,
        Strafe = false,
        VisualizeStrafe = false,
        VisualizeStrafeInlineColor = Color3.fromRGB(255, 255, 255),
        VisualizeStrafeOutlineColor = Color3.fromRGB(255, 255, 255),
        StrafeMethod = 'Randomize',
        Highlight = true,
        HighlightOutlineColor = Color3.fromRGB(255, 255, 255),
        Tracer = true,
        TracerPosition = 'Tool',
        TracerFillColor = Color3.fromRGB(255, 255, 255),
        TracerOutlineColor = Color3.fromRGB(0, 0, 0),
        LookAt = false,
        SpectateTarget = false,
        UseHackFlame = false,
        AutoStomp = false,
        Prediction = 0,
        AutoPredict = false,
        HitPart = 'Head',
        Offset = 0,
		RandomStrafe = false,
		RandomStrafeDelay = 3,
        JumpOffset = 0,
        AirPartEnabled = false,
        AirPart = 'Head',
        Resolver = false,
        Resolvermode = '',
        TargetStats = false,
        Autokill = false,
        DotCircle = false,
        Spoofer = true,
        TrashTalk = false,
    },
    HitEffects = {
        HitSounds = false,
        HitSoundID = 'rbxassetid://6534948092',
        HitSoundVolume = 5,
        HitNotifications = false,
        HitNotificationsTime = 3,
        HitChams = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Lifetime = 3,
            Transparency = 0.7,
            Material = 'Neon',
        },
        HitEffect = {
            Enabled = false,
            Type = 'Coom',
            Color = Color3.fromRGB(255, 255, 255),
        },
        HitSkeleton = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
        },
    },
    Checks = {
        Wall = false,
        Forcefield = false,
        Alive = false,
        Team = false,
    },
    KillAura = {
        Enabled = false,
        Active = false,
        Range = 250,
        Silent = false,
        Visualize = false,
        StompAura = false,
        Whitelist = {},
    },
    RapidFire = {Enabled = false},
    Wallbang = {Enabled = false},
    HitboxExpander = {
        Enabled = false,
        Visualize = false,
        Color = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.5,
        OutlineTransparency = 0.3,
        Size = 15,
    },
    Movement = {
        JumpPowerEnabled = false,
        JumpPower = 50,
    },
}
local tracers = {}
local TracerConnections = {}
local LP = game.Players.LocalPlayer

-- Function createTracer
local function createTracer(ply)
    if not LP.Character or not ply.Character then return end
    local lpChar = LP.Character
    local targetChar = ply.Character

    local hitPartName = DYHUBcc.TargetAim.HitPart
    local hitPart = targetChar:FindFirstChild(hitPartName)
    if not hitPart then return end

    local fromPart
    if DYHUBcc.TargetAim.TracerPosition == 'UpperTorso' then
        fromPart = lpChar:FindFirstChild('UpperTorso')
    else -- 'Tool'
        local tool = lpChar:FindFirstChildOfClass('Tool')
        if tool and tool:FindFirstChild('Handle') then
            fromPart = tool.Handle
        else
            fromPart = lpChar:FindFirstChild('RightHand')
        end
    end
    if not fromPart then return end

    if tracers[ply] then
        tracers[ply]:Destroy()
        tracers[ply] = nil
    end

    local att1 = Instance.new("Attachment", fromPart)
    local att2 = Instance.new("Attachment", hitPart)

    local beam = Instance.new("Beam")
    beam.Attachment0 = att1
    beam.Attachment1 = att2
    beam.Color = ColorSequence.new(DYHUBcc.TargetAim.TracerFillColor)
    beam.Width0 = 0.10
    beam.Width1 = 0.10
	beam.FaceCamera = true
	beam.LightEmission = 0
	beam.LightInfluence = 0
	beam.Transparency = NumberSequence.new({
	    NumberSequenceKeypoint.new(0, 0),
	    NumberSequenceKeypoint.new(1, 0),
	})
    beam.Texture = "" -- Streak texture for better visual
    beam.TextureSpeed = 5
    beam.TextureLength = 2
    beam.Parent = fromPart

    tracers[ply] = beam

    -- Handle target respawn
    if TracerConnections[ply] then
        TracerConnections[ply]:Disconnect()
    end
    TracerConnections[ply] = ply.CharacterAdded:Connect(function(newChar)
        task.wait(0.2)
        local newHitPart = newChar:WaitForChild(hitPartName)
        if tracers[ply] then
            local newAtt = Instance.new("Attachment", newHitPart)
            tracers[ply].Attachment1 = newAtt
        end
    end)
	LP.CharacterAdded:Connect(function()
	    task.wait(0.2)
	    for ply in pairs(tracers) do
	        createTracer(ply)
	    end
	end)
end

local function removeTracer(ply)
    if tracers[ply] then
        tracers[ply]:Destroy()
        tracers[ply] = nil
    end
    if TracerConnections[ply] then
        TracerConnections[ply]:Disconnect()
        TracerConnections[ply] = nil
    end
end
getgenv().targetlist = {}
local MultiTargetEnabled = false
local MultiTargetConnection = nil
local TargetLabel = nil
local SelectAllButton = nil
local RemoveAllButton = nil
local StompOrAutokill = function()
    return DYHUBcc.TargetAim.AutoStomp or DYHUBcc.TargetAim.Autokill
end
local function toggleTargetInList(target)
    if not target then return false end
    local name = target.Name
    local idx = table.find(targetlist, name)
    if idx then
        table.remove(targetlist, idx)
        return false -- removed
    else
        table.insert(targetlist, name)
        return true -- added
    end
end
local oldVelPos = {}
local DotCircle = Drawing.new('Circle')

DotCircle.Visible = false
DotCircle.Filled = true
DotCircle.Radius = 5
DotCircle.Thickness = 1.5
DotCircle.Color = Color3.fromRGB(255, 255, 255)
DotCircle.Transparency = 1

if not LPH_OBFUSCATED then
    LPH_JIT = function(...)
        return ...
    end
    LPH_NO_VIRTUALIZE = function(...)
        return ...
    end
end

local BodyClone = game:GetObjects('rbxassetid://8246626421')[1]

BodyClone.Parent = workspace

BodyClone.Humanoid:Destroy()
BodyClone.Head.Face:Destroy()

for _, v in pairs(BodyClone:GetDescendants())do
    if v:IsA('BasePart') or v:IsA('MeshPart') then
        v.CanCollide = false
        v.Transparency = 1
    end
end

BodyClone.HumanoidRootPart.Transparency = 1
BodyClone.HumanoidRootPart.Velocity = Vector3.zero
BodyClone.HumanoidRootPart.CFrame = CFrame.new(9999, 9999, 9999)

local BodyCloneHighlight = Instance.new('Highlight')

BodyCloneHighlight.Enabled = false
BodyCloneHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
BodyCloneHighlight.FillColor = Color3.fromRGB(0, 255, 0)
BodyCloneHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
BodyCloneHighlight.FillTransparency = 0.3
BodyCloneHighlight.OutlineTransparency = 0
BodyCloneHighlight.Adornee = BodyClone
BodyCloneHighlight.Parent = BodyClone

local GlowLight = Instance.new('PointLight')

GlowLight.Color = Color3.fromRGB(255, 255, 255)
GlowLight.Brightness = 4
GlowLight.Range = 4
GlowLight.Parent = BodyClone.HumanoidRootPart

local DesyncLine = Drawing.new('Line')

DesyncLine.Thickness = 2
DesyncLine.Color = Color3.fromRGB(255, 255, 255)
DesyncLine.Visible = false
DesyncLine.Transparency = 1
local ka_tracer = Instance.new('Part')

ka_tracer.Size = Vector3.new(0.2, 0.2, 0.2)
ka_tracer.Material = Enum.Material.Neon
ka_tracer.Color = Color3.fromRGB(255, 255, 255)
ka_tracer.Transparency = 1
ka_tracer.Anchored = true
ka_tracer.CanCollide = false
ka_tracer.Parent = workspace

local TweenService = game:GetService('TweenService')
local HitChams = LPH_NO_VIRTUALIZE(function(Player)
    if not DYHUBcc.HitEffects.HitChams.Enabled then
        return
    end
    if Player and Player.Character and Player.Character:FindFirstChild('HumanoidRootPart') then
        Player.Character.Archivable = true

        local Cloned = Player.Character:Clone()

        Cloned.Name = 'Player Clone'

        local BodyParts = {
            'Head',
            'UpperTorso',
            'LowerTorso',
            'LeftUpperArm',
            'LeftLowerArm',
            'LeftHand',
            'RightUpperArm',
            'RightLowerArm',
            'RightHand',
            'LeftUpperLeg',
            'LeftLowerLeg',
            'LeftFoot',
            'RightUpperLeg',
            'RightLowerLeg',
            'RightFoot',
        }

        for _, Part in ipairs(Cloned:GetChildren())do
            if Part:IsA('BasePart') then
                local PartValid = false

                for _, validPart in ipairs(BodyParts)do
                    if Part.Name == validPart then
                        PartValid = true

                        break
                    end
                end

                if not PartValid then
                    Part:Destroy()
                end
            elseif Part:IsA('Accessory') or Part:IsA('Tool') or Part.Name == 'face' or Part:IsA('Shirt') or Part:IsA('Pants') or Part:IsA('Hat') then
                Part:Destroy()
            end
        end

        if Cloned:FindFirstChild('Humanoid') then
            Cloned.Humanoid:Destroy()
        end

        for _, BodyPart in ipairs(Cloned:GetChildren())do
            if BodyPart:IsA('BasePart') then
                BodyPart.CanCollide = false
                BodyPart.Anchored = true
                BodyPart.Transparency = DYHUBcc.HitEffects.HitChams.Transparency
                BodyPart.Color = DYHUBcc.HitEffects.HitChams.Color
                BodyPart.Material = DYHUBcc.HitEffects.HitChams.Material
            end
        end

        if Cloned:FindFirstChild('Head') then
            local Head = Cloned.Head

            Head.Transparency = DYHUBcc.HitEffects.HitChams.Transparency
            Head.Color = DYHUBcc.HitEffects.HitChams.Color
            Head.Material = DYHUBcc.HitEffects.HitChams.Material

            if Head:FindFirstChild('face') then
                Head.face:Destroy()
            end
        end

        Cloned.Parent = game.Workspace

        local tweenInfo = TweenInfo.new(DYHUBcc.HitEffects.HitChams.Lifetime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true)

        for _, BodyPart in ipairs(Cloned:GetChildren())do
            if BodyPart:IsA('BasePart') then
                local tween = TweenService:Create(BodyPart, tweenInfo, {Transparency = 1})

                tween:Play()
            end
        end

        task.delay(DYHUBcc.HitEffects.HitChams.Lifetime, function()
            if Cloned and Cloned.Parent then
                Cloned:Destroy()
            end
        end)
    end
end)
local HitChamsSkeleton = LPH_NO_VIRTUALIZE(function(Player)
    if not DYHUBcc.HitEffects.HitSkeleton.Enabled then
        return
    end
    if Player and Player.Character and Player.Character:FindFirstChild('HumanoidRootPart') then
        local bones = {
            {
                'Head',
                'UpperTorso',
            },
            {
                'UpperTorso',
                'LowerTorso',
            },
            {
                'UpperTorso',
                'RightUpperArm',
            },
            {
                'RightUpperArm',
                'RightLowerArm',
            },
            {
                'RightLowerArm',
                'RightHand',
            },
            {
                'UpperTorso',
                'LeftUpperArm',
            },
            {
                'LeftUpperArm',
                'LeftLowerArm',
            },
            {
                'LeftLowerArm',
                'LeftHand',
            },
            {
                'LowerTorso',
                'RightUpperLeg',
            },
            {
                'RightUpperLeg',
                'RightLowerLeg',
            },
            {
                'RightLowerLeg',
                'RightFoot',
            },
            {
                'LowerTorso',
                'LeftUpperLeg',
            },
            {
                'LeftUpperLeg',
                'LeftLowerLeg',
            },
            {
                'LeftLowerLeg',
                'LeftFoot',
            },
        }
        local lines = {}

        for _, bonePair in ipairs(bones)do
            local parentBone = Player.Character:FindFirstChild(bonePair[1])
            local childBone = Player.Character:FindFirstChild(bonePair[2])

            if parentBone and childBone then
                local line = Instance.new('Part')

                line.Size = Vector3.new(0.02, 0.02, (parentBone.Position - childBone.Position).Magnitude)
                line.CFrame = CFrame.new(parentBone.Position, childBone.Position) * CFrame.new(0, 0, -line.Size.Z / 2)
                line.Anchored = true
                line.CanCollide = false
                line.Transparency = DYHUBcc.HitEffects.HitChams.Transparency
                line.Color = DYHUBcc.HitEffects.HitSkeleton.Color
                line.Material = Enum.Material.Neon
                line.Parent = workspace

                local tweenInfo = TweenInfo.new(DYHUBcc.HitEffects.HitChams.Lifetime / 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                local tween = TweenService:Create(line, tweenInfo, {Transparency = 1})

                tween:Play()
                table.insert(lines, line)
            end
        end

        task.delay(DYHUBcc.HitEffects.HitChams.Lifetime, function()
            for _, line in ipairs(lines)do
                if line and line.Parent then
                    line:Destroy()
                end
            end
        end)
    end
end)
local FOVCircleEnabled = false
local FOVCircleSize = 300
local FOVInnerColor = Color3.fromRGB(255, 255, 255)
local GradientFillEnabled = false
local GradientColor1 = Color3.fromRGB(255, 255, 255)
local FillTransparency = 0.5
local InnerCircle = Drawing.new('Circle')

InnerCircle.Visible = false
InnerCircle.Thickness = 1
InnerCircle.NumSides = 64
InnerCircle.Filled = false
InnerCircle.Color = FOVInnerColor
InnerCircle.Radius = FOVCircleSize
InnerCircle.ZIndex = 10

local FillCircle = Drawing.new('Circle')

FillCircle.Visible = false
FillCircle.Filled = true
FillCircle.Transparency = FillTransparency
FillCircle.NumSides = 64
FillCircle.Radius = FOVCircleSize
FillCircle.Color = GradientColor1
FillCircle.ZIndex = 10

local players = game:GetService('Players')
local Players = game:GetService('Players')
local localPlayer = players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local possibleRemotes = {
    'MAINEVENT',
    'MainEvent',
    'Remote',
    'Packages',
    'MainRemotes',
    'Bullets',
}

local function getMainRemote()
    if ReplicatedStorage:FindFirstChild('MainEvent') then
        return ReplicatedStorage.MainEvent
    end
    if ReplicatedStorage:FindFirstChild('MAINEVENT') then
        return ReplicatedStorage.MAINEVENT
    end
    if ReplicatedStorage:FindFirstChild('Remote') then
        return ReplicatedStorage.Remote
    end
    if ReplicatedStorage:FindFirstChild('Bullets') then
        return ReplicatedStorage.Bullets
    end

    local mainRemotes = ReplicatedStorage:FindFirstChild('MainRemotes')

    if mainRemotes and mainRemotes:FindFirstChild('MainRemoteEvent') then
        return mainRemotes.MainRemoteEvent
    end

    local packages = ReplicatedStorage:FindFirstChild('Packages')

    if packages then
        local knit = packages:FindFirstChild('Knit')

        if knit and knit:FindFirstChild('Services') then
            local toolService = knit.Services:FindFirstChild('ToolService')

            if toolService and toolService:FindFirstChild('RE') then
                local re = toolService.RE

                if re:FindFirstChild('UpdateAim') then
                    return re.UpdateAim
                end
            end
        end
    end

    return nil
end

local MainEvent = getMainRemote()
local previousPositions = {}
local customVelocities = {}
local lastTarget = nil
local t = 0
local M1Down = false
local lastHealth = nil
local ka_lastHealth = {}
local sounds = {
    Hrntai = 'https://github.com/CongoOhioDog/SoundS/blob/main/Hrntai.wav?raw=true',
    Henta01 = 'https://github.com/CongoOhioDog/SoundS/blob/main/henta01.wav?raw=true',
    Kitty = 'https://github.com/CongoOhioDog/SoundS/blob/main/Kitty.mp3?raw=true',
}
local hitsounds = {
    Bubble = 'rbxassetid://6534947588',
    Lazer = 'rbxassetid://130791043',
    Pick = 'rbxassetid://1347140027',
    Pop = 'rbxassetid://198598793',
    Rust = 'rbxassetid://1255040462',
    Sans = 'rbxassetid://3188795283',
    Fart = 'rbxassetid://130833677',
    Big = 'rbxassetid://5332005053',
    Vine = 'rbxassetid://5332680810',
    UwU = 'rbxassetid://8679659744',
    Bruh = 'rbxassetid://4578740568',
    Skeet = 'rbxassetid://5633695679',
    Neverlose = 'rbxassetid://6534948092',
    Fatality = 'rbxassetid://6534947869',
    Bonk = 'rbxassetid://5766898159',
    Minecraft = 'rbxassetid://5869422451',
    Gamesense = 'rbxassetid://4817809188',
    RIFK7 = 'rbxassetid://9102080552',
    Bamboo = 'rbxassetid://3769434519',
    Crowbar = 'rbxassetid://546410481',
    Weeb = 'rbxassetid://6442965016',
    Beep = 'rbxassetid://8177256015',
    Bambi = 'rbxassetid://8437203821',
    Stone = 'rbxassetid://3581383408',
    ['Old Fatality'] = 'rbxassetid://6607142036',
    Click = 'rbxassetid://8053704437',
    Ding = 'rbxassetid://7149516994',
    Snow = 'rbxassetid://6455527632',
    Laser = 'rbxassetid://7837461331',
    Mario = 'rbxassetid://2815207981',
    Steve = 'rbxassetid://4965083997',
    ['Call of Duty'] = 'rbxassetid://5952120301',
    Bat = 'rbxassetid://3333907347',
    ['TF2 Critical'] = 'rbxassetid://296102734',
    Saber = 'rbxassetid://8415678813',
    Baimware = 'rbxassetid://3124331820',
    Osu = 'rbxassetid://7149255551',
    TF2 = 'rbxassetid://2868331684',
    Slime = 'rbxassetid://6916371803',
    ['Among Us'] = 'rbxassetid://5700183626',
    One = 'rbxassetid://7380502345',
}

local function isAlive(plr)
    if not plr or not plr.Character then
        return false
    end

    local hum = plr.Character:FindFirstChildOfClass('Humanoid')

    if not hum or hum.Health <= 0 then
        return false
    end

    local be = plr.Character:FindFirstChild('BodyEffects')

    if be then
        local ko = be:FindFirstChild('K.O')
        local grabbed = be:FindFirstChild('GRABBING_CONSTRAINT')

        if (ko and ko.Value) or (grabbed and grabbed.Value) then
            return false
        end
    end

    return true
end
local function getBestTargetFromList()
    local bestDist = math.huge
    local bestTarget = nil
    local localChar = game.Players.LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = localChar.HumanoidRootPart.Position
    
    local prioritizeDowned = StompOrAutokill()
    
    for _, name in ipairs(targetlist) do
        local target = game.Players:FindFirstChild(name)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            continue -- remove invalid
        end
        if not isAlive(target) and not prioritizeDowned then
            continue -- skip downed if not prioritize
        end
        if prioritizeDowned and isAlive(target) then
            continue -- skip alive if prioritize downed? Wait, Æ°u tiÃªn not alive náº¿u báº­t stomp/autokill
        end
        -- Forcefield check
        if DYHUBcc.Checks.Forcefield and target.Character:FindFirstChildWhichIsA("ForceField") then
            continue
        end
        -- Team check? Assume in GetClosest, but for consistency
        if DYHUBcc.Checks.Team and target.Team == game.Players.LocalPlayer.Team then
            continue
        end
        local dist = (myPos - target.Character.HumanoidRootPart.Position).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestTarget = target
        end
    end
    -- Clean invalid from list
    for i = #targetlist, 1, -1 do
        if not game.Players:FindFirstChild(targetlist[i]) then
            table.remove(targetlist, i)
        end
    end
    return bestTarget
end
local function isAlive2(plr)
    if not plr or not plr.Character then
        return false
    end

    local hum = plr.Character:FindFirstChildOfClass('Humanoid')

    if not hum or hum.Health <= 0 then
        return false
    end

    return true
end
local function KnockCheck(plr)
    if plr and plr.Character and plr.Character:FindFirstChild('BodyEffects') then
        local ko = plr.Character.BodyEffects:FindFirstChild('K.O')

        return ko and ko.Value or false
    end

    return false
end
local function GetClosestCharacter()
    local closestDist = math.huge
    local closestPlayer = nil
    local mousePos

    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        mousePos = UserInputService:GetMouseLocation()
    end

    for _, player in pairs(players:GetPlayers())do
        if player == localPlayer then
            continue
        end

        local char = player.Character

        if not char or not char:FindFirstChild('Head') or not char:FindFirstChild('HumanoidRootPart') then
            continue
        end
        if not isAlive(player) and DYHUBcc.Checks.Alive then
            continue
        end
        if DYHUBcc.Checks.Team and player.Team == localPlayer.Team then
            continue
        end
        if DYHUBcc.Checks.Forcefield and player.Character:FindFirstChildWhichIsA('ForceField') then
            continue
        end

        local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
        local screenPos = Vector2.new(headPos.X, headPos.Y)
        local dist = (screenPos - mousePos).Magnitude

        if FOVCircleEnabled and dist > FOVCircleSize then
            continue
        end

        local isVisible = true

        if DYHUBcc.Checks.Wall then
            local raycastParams = RaycastParams.new()

            raycastParams.FilterDescendantsInstances = {
                localPlayer.Character,
            }
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

            local result = workspace:Raycast(Camera.CFrame.Position, char.Head.Position - Camera.CFrame.Position, raycastParams)

            if result and result.Instance and not result.Instance:IsDescendantOf(char) then
                isVisible = false
            end
        end
        if onScreen and isVisible and dist < closestDist then
            closestDist = dist
            closestPlayer = player
        end
    end

    return closestPlayer
end
local function createHitSound()
    local sound = Instance.new('Sound')

    sound.Parent = localPlayer.Character.HumanoidRootPart
    sound.SoundId = DYHUBcc.HitEffects.HitSoundID
    sound.Volume = DYHUBcc.HitEffects.HitSoundVolume

    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end
local function SetRigTransparency(clone, trans)
    for _, v in pairs(clone:GetDescendants())do
        if v:IsA('BasePart') or v:IsA('MeshPart') then
            v.Transparency = trans
        end
    end
end
local function SetRigCollisionFalse(clone)
    for _, v in pairs(clone:GetDescendants())do
        if v:IsA('BasePart') or v:IsA('MeshPart') then
            v.CanCollide = false
        end
    end
end
local function SetRigColor(clone, color)
    for _, v in pairs(clone:GetDescendants())do
        if v:IsA('BasePart') or v:IsA('MeshPart') then
            v.Color = color
        end
    end
end


local TargetGroup = Tabs.Target:AddLeftGroupbox('Target')
local AutokillGroup = Tabs.Target:AddLeftGroupbox('Autokill')
local ChecksGroup = Tabs.Target:AddRightGroupbox('Checks')
local TargetLabel = TargetGroup:AddLabel('Target: None')
local function updateTargetLabel()
    if not TargetLabel then return end
    if not MultiTargetEnabled then
        local targetName = DYHUBcc.TargetAim.Target
        if targetName == 'None' then
            TargetLabel:SetText('Target: None')
        else
            local target = game.Players:FindFirstChild(targetName)
            if target then
                TargetLabel:SetText('Target: ' .. target.DisplayName .. ' (@' .. target.Name .. ')')
            else
                DYHUBcc.TargetAim.Target = 'None'
                TargetLabel:SetText('Target: None')
            end
        end
    else
        local displays = {}
        for _, name in ipairs(targetlist) do
            local plr = game.Players:FindFirstChild(name)
            if plr then
                table.insert(displays, plr.DisplayName)
            end
        end
        TargetLabel:SetText('Targets: ' .. table.concat(displays, ', ') .. ( #displays == 0 and ' None' or '' ))
    end
end
local function onTargetSelect()
    local target = GetClosestCharacter()
    local msg
    if MultiTargetEnabled then
        local added = toggleTargetInList(target)
        if added then
            msg = 'Added: ' .. (target and target.DisplayName or 'None')
        else
            msg = 'Removed: ' .. (target and target.DisplayName or 'None')
        end
        updateTargetLabel()
    else
        if target then
            DYHUBcc.TargetAim.Target = target.Name
            msg = 'Target: ' .. target.DisplayName .. ' (@' .. target.Name .. ')'
        else
            DYHUBcc.TargetAim.Target = 'None'
            msg = 'Target removed'
        end
        updateTargetLabel()
    end
    Library:Notify(msg, 3)
end
TargetGroup:AddToggle('TargetAimEnabled', {
    Text = 'Enabled',
    Default = true,
    Callback = function(Value)
        DYHUBcc.TargetAim.Enabled = Value

        if not Value then
            DYHUBcc.TargetAim.Target = 'None'
            TargetLabel:SetText('Target: None')
            SetRigTransparency(BodyClone, 1)


            BodyCloneHighlight.Enabled = false
            Camera.CameraSubject = localPlayer.Character.Humanoid
        end
    end,
}):AddKeyPicker('TargetAimKey', {
    Default = 'Q',
    Text = 'Target Aim',
    Mode = 'Toggle',
    Callback = function(Value)
        if not DYHUBcc.TargetAim.Enabled then
            return
        end
        local target = GetClosestCharacter()
        if Value and not MultiTargetEnabled then
            if target then
                DYHUBcc.TargetAim.Target = target.Name
                TargetLabel:SetText('Target: ' .. target1.DisplayName .. ' (@' .. target.Name .. ')')
			end
        elseif Value and MultiTargetEnabled then
            onTargetSelect()
        elseif not Value and MultiTargetEnabled then
            onTargetSelect()
        elseif not Value and not MultiTargetEnabled then
            DYHUBcc.TargetAim.Target = 'None'
            TargetLabel:SetText('Target: None')
            SetRigTransparency(BodyClone, 1)
            BodyCloneHighlight.Enabled = false
        end
    end,
})
local MultiTargetToggle = TargetGroup:AddToggle('MultiTarget', {
    Text = 'Multi Target',
    Default = false,
    Callback = function(Value)
        MultiTargetEnabled = Value
        targetlist = {} -- Clear list
        updateTargetLabel()
        if Value then
            -- Add buttons Select All / Remove All
            SelectAllButton = TargetGroup:AddButton('Select All', function()
                if not MultiTargetEnabled then
                    Library:Notify('Multi Target is not enabled!', 3)
                    return
                end
                targetlist = {}
                for _, plr in ipairs(game.Players:GetPlayers()) do
                    if plr == game.Players.LocalPlayer then continue end
                    if GetClosestCharacter() == plr or true then -- Add all pass GetClosest logic, but simplify: all valid
                        -- Simulate checks in GetClosest
                        if isAlive(plr) or StompOrAutokill() then -- Basic
                            table.insert(targetlist, plr.Name)
                        end
                    end
                end
                updateTargetLabel()
                Library:Notify('Selected all valid targets!', 3)
            end)
            RemoveAllButton = TargetGroup:AddButton('Remove All', function()
                if not MultiTargetEnabled then
                    Library:Notify('Multi Target is not enabled!', 3)
                    return
                end
                targetlist = {}
                updateTargetLabel()
                DYHUBcc.TargetAim.Target = 'None'
                Library:Notify('Removed all targets!', 3)
            end)
            -- Start loop select best
            MultiTargetConnection = RunService.Heartbeat:Connect(function()
                local best = getBestTargetFromList()
                if best then
                    DYHUBcc.TargetAim.Target = best.Name
                elseif #targetlist == 0 then
                    DYHUBcc.TargetAim.Target = 'None'
                end
                updateTargetLabel()
            end)
        else
            -- Remove buttons if exist (Library may not support remove, so hide or ignore)
            if MultiTargetConnection then
                MultiTargetConnection:Disconnect()
                MultiTargetConnection = nil
            end
            DYHUBcc.TargetAim.Target = 'None'
            -- Assume buttons not re-added
        end
    end,
})
local function makeDraggable(frame)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService('UserInputService').InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if input == dragInput then
                local delta = input.Position - dragStart

                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

if game:GetService('UserInputService').TouchEnabled then
    local selectGui = Instance.new('ScreenGui')

    selectGui.Name = 'SelectTargetGui'
    selectGui.ResetOnSpawn = false
    selectGui.Parent = game.CoreGui

    local selectBtn = Instance.new('TextButton')

    selectBtn.Size = UDim2.new(0, 120, 0, 50)
    selectBtn.Position = UDim2.new(0.5, -60, 0.85, -25)
    selectBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    selectBtn.BackgroundColor3 = Color3.fromRGB(156, 186, 140)
    selectBtn.Text = 'Set Target'
    selectBtn.TextColor3 = Color3.new(1, 1, 1)
    selectBtn.TextSize = 18
    selectBtn.Font = Enum.Font.GothamBold
    selectBtn.Parent = selectGui

    local corner = Instance.new('UICorner')

    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = selectBtn

    makeDraggable(selectBtn)
    selectBtn.MouseButton1Click:Connect(function()
        if not DYHUBcc.TargetAim.Enabled then
            Library:Notify('Target Aim is off', 3)
            return
        end
        onTargetSelect() -- Use same function
    end)
end

TargetGroup:AddToggle('AutoSelect', {
    Text = 'Auto Select',
    Default = false,
    Callback = function(Value)
        DYHUBcc.TargetAim.AutoSelect = Value

        if Value then
            RunService:BindToRenderStep('AutoSelect', 1, function()
                local target = GetClosestCharacter()

                if lastTarget and lastTarget ~= target and lastTarget.Character then
                    
                    
                end
                if target then
                    DYHUBcc.TargetAim.Target = target.Name
                else
                    DYHUBcc.TargetAim.Target = 'None'
                end

                lastTarget = target
            end)
        else
            RunService:UnbindFromRenderStep('AutoSelect')

            if lastTarget and lastTarget.Character then
                
                
            end

            lastTarget = nil
        end
    end,
})
local AutoFireConnection = nil
local vu = getgenv().vu
local uis = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Sá»­a callback AutoFire
TargetGroup:AddToggle('AutoFire', {
    Text = 'Auto Fire',
    Default = false,
    Callback = function(Value)
        DYHUBcc.TargetAim.AutoFire = Value
        if Value then
            AutoFireConnection = RunService.Heartbeat:Connect(function()
                local placeId = game.PlaceId
                local isDaHood = (placeId == 2788229376)
                if isDaHood then return end
                
                local targetName = DYHUBcc.TargetAim.Target
                if targetName == 'None' then return end
                
                local target = game.Players:FindFirstChild(targetName)
                if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") or not target.Character:FindFirstChild("Head") then return end
                
                if not isAlive(target) then return end
                
                local localChar = game.Players.LocalPlayer.Character
                if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
                
                local dist = (localChar.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
                if dist > 270 then return end
                
                -- Wall check
                local isVisible = true
                if DYHUBcc.Checks.Wall then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {localChar}
                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local ray = workspace:Raycast(Camera.CFrame.Position, target.Character.Head.Position - Camera.CFrame.Position, rayParams)
                    if ray and not ray.Instance:IsDescendantOf(target.Character) then
                        isVisible = false
                    end
                end
                if not isVisible then return end
                
                -- Tool check
                local tool = localChar:FindFirstChildOfClass("Tool")
                if not tool then return end
                
                -- Ammo check
                local ammoObj = tool:FindFirstChild("Ammo")
                local hasAmmo = true
                if ammoObj and ammoObj:IsA("IntValue") and ammoObj.Value <= 0 then
                    hasAmmo = false
                end
                
                -- Shoot
                if hasAmmo then
                    tool:Activate()
                else
                    local mousePos = uis:GetMouseLocation()
                    vu:Button1Down(mousePos)
                    task.wait(0.05)
                    vu:Button1Up(mousePos)
                end
            end)
        else
            if AutoFireConnection then
                AutoFireConnection:Disconnect()
                AutoFireConnection = nil
            end
        end
    end,
})
TargetGroup:AddToggle('TrashTalk', {
    Text = 'Trash talk when target die',
    Default = false,
    Callback = function(Value)
        DYHUBcc.TargetAim.TrashTalk = Value
    end,
})

local Storage = {Connections = {}}

local function NewConnection(signal, callback)
    local conn = signal:Connect(callback)

    table.insert(Storage.Connections, conn)

    return conn
end

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

TargetGroup:AddToggle('TargetStatsEnabled', {
    Text = 'Target Stats',
    Default = false,
    Callback = function(v)
        DYHUBcc.TargetAim.TargetStats = v
    end,
})
coroutine.wrap(function()
    local Colors = {
        Background = Color3.fromRGB(250, 248, 245),
        Main = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(147, 179, 141),
        Secondary = Color3.fromRGB(200, 220, 195),
        Border = Color3.fromRGB(220, 218, 215),
        Text = Color3.fromRGB(80, 80, 80),
        TextLight = Color3.fromRGB(120, 120, 120),
        Alive = Color3.fromRGB(147, 179, 141),
        Knocked = Color3.fromRGB(255, 193, 86),
        Grabbing = Color3.fromRGB(255, 138, 101),
        Dead = Color3.fromRGB(255, 107, 107),
    }

    local function IsMobile()
        return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end
    local function GetStatus(plr)
        if not plr or not plr.Character then
            return 'Dead', false, Colors.Dead
        end

        local hum = plr.Character:FindFirstChildOfClass('Humanoid')

        if not hum or hum.Health <= 0 then
            return 'Dead', false, Colors.Dead
        end

        local be = plr.Character:FindFirstChild('BodyEffects')

        if be then
            local grab = be:FindFirstChild('GRABBING_CONSTRAINT')
            local ko = be:FindFirstChild('K.O')

            if grab and grab.Value then
                return 'Grabbing', false, Colors.Grabbing
            end
            if ko and ko.Value then
                return 'Knocked', false, Colors.Knocked
            end
        end

        return 'Alive', true, Colors.Alive
    end

    local ScreenGui = Instance.new('ScreenGui')

    ScreenGui.Name = 'DYHUBTargetHUD'
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService('CoreGui')

    local MainFrame = Instance.new('Frame')

    MainFrame.Name = 'MainFrame'
    MainFrame.Size = IsMobile() and UDim2.new(0, 340, 0, 140) or UDim2.new(0, 420, 0, 150)
    MainFrame.Position = IsMobile() and UDim2.new(0.5, -170, 0.85, -70) or UDim2.new(0.5, -210, 0.75, -75)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Colors.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new('UICorner')

    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new('UIStroke')

    MainStroke.Color = Colors.Border
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.3
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame

    local Shadow = Instance.new('ImageLabel')

    Shadow.Name = 'Shadow'
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 5)
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = 'rbxassetid://5554236805'
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.9
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame

    local AvatarContainer = Instance.new('Frame')

    AvatarContainer.Name = 'AvatarContainer'
    AvatarContainer.Size = UDim2.new(0, 85, 0, 85)
    AvatarContainer.Position = UDim2.new(0, 15, 0, 15)
    AvatarContainer.BackgroundColor3 = Colors.Background
    AvatarContainer.BorderSizePixel = 0
    AvatarContainer.Parent = MainFrame

    local AvatarCorner = Instance.new('UICorner')

    AvatarCorner.CornerRadius = UDim.new(0, 12)
    AvatarCorner.Parent = AvatarContainer

    local AvatarStroke = Instance.new('UIStroke')

    AvatarStroke.Color = Colors.Accent
    AvatarStroke.Thickness = 3
    AvatarStroke.Transparency = 0
    AvatarStroke.Parent = AvatarContainer

    local Avatar = Instance.new('ImageLabel')

    Avatar.Name = 'Avatar'
    Avatar.Size = UDim2.new(1, -6, 1, -6)
    Avatar.Position = UDim2.new(0, 3, 0, 3)
    Avatar.BackgroundTransparency = 1
    Avatar.Image = ''
    Avatar.Parent = AvatarContainer

    local AvatarImageCorner = Instance.new('UICorner')

    AvatarImageCorner.CornerRadius = UDim.new(0, 10)
    AvatarImageCorner.Parent = Avatar

    local StatusBadge = Instance.new('Frame')

    StatusBadge.Name = 'StatusBadge'
    StatusBadge.Size = UDim2.new(0, 70, 0, 20)
    StatusBadge.Position = UDim2.new(0.5, -35, 1, -25)
    StatusBadge.BackgroundColor3 = Colors.Alive
    StatusBadge.BorderSizePixel = 0
    StatusBadge.Parent = AvatarContainer

    local BadgeCorner = Instance.new('UICorner')

    BadgeCorner.CornerRadius = UDim.new(0, 10)
    BadgeCorner.Parent = StatusBadge

    local StatusText = Instance.new('TextLabel')

    StatusText.Size = UDim2.new(1, 0, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = 'ALIVE'
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextSize = 11
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusText.Parent = StatusBadge

    local InfoContainer = Instance.new('Frame')

    InfoContainer.Name = 'InfoContainer'
    InfoContainer.Size = IsMobile() and UDim2.new(1, -115, 1, -30) or UDim2.new(1, -115, 1, -30)
    InfoContainer.Position = UDim2.new(0, 110, 0, 15)
    InfoContainer.BackgroundTransparency = 1
    InfoContainer.Parent = MainFrame

    local PlayerName = Instance.new('TextLabel')

    PlayerName.Name = 'PlayerName'
    PlayerName.Size = UDim2.new(1, 0, 0, 24)
    PlayerName.Position = UDim2.new(0, 0, 0, 0)
    PlayerName.BackgroundTransparency = 1
    PlayerName.Text = 'Username'
    PlayerName.Font = Enum.Font.GothamBold
    PlayerName.TextSize = IsMobile() and 15 or 17
    PlayerName.TextColor3 = Colors.Text
    PlayerName.TextXAlignment = Enum.TextXAlignment.Left
    PlayerName.TextTruncate = Enum.TextTruncate.AtEnd
    PlayerName.Parent = InfoContainer

    local DisplayName = Instance.new('TextLabel')

    DisplayName.Name = 'DisplayName'
    DisplayName.Size = UDim2.new(1, 0, 0, 18)
    DisplayName.Position = UDim2.new(0, 0, 0, 26)
    DisplayName.BackgroundTransparency = 1
    DisplayName.Text = '@displayname'
    DisplayName.Font = Enum.Font.Gotham
    DisplayName.TextSize = IsMobile() and 12 or 13
    DisplayName.TextColor3 = Colors.TextLight
    DisplayName.TextXAlignment = Enum.TextXAlignment.Left
    DisplayName.TextTruncate = Enum.TextTruncate.AtEnd
    DisplayName.Parent = InfoContainer

    local HealthBarBG = Instance.new('Frame')

    HealthBarBG.Name = 'HealthBarBG'
    HealthBarBG.Size = UDim2.new(1, 0, 0, 8)
    HealthBarBG.Position = UDim2.new(0, 0, 0, 52)
    HealthBarBG.BackgroundColor3 = Colors.Background
    HealthBarBG.BorderSizePixel = 0
    HealthBarBG.Parent = InfoContainer

    local HealthBarBGCorner = Instance.new('UICorner')

    HealthBarBGCorner.CornerRadius = UDim.new(1, 0)
    HealthBarBGCorner.Parent = HealthBarBG

    local HealthBar = Instance.new('Frame')

    HealthBar.Name = 'HealthBar'
    HealthBar.Size = UDim2.new(1, 0, 1, 0)
    HealthBar.BackgroundColor3 = Colors.Accent
    HealthBar.BorderSizePixel = 0
    HealthBar.Parent = HealthBarBG

    local HealthBarCorner = Instance.new('UICorner')

    HealthBarCorner.CornerRadius = UDim.new(1, 0)
    HealthBarCorner.Parent = HealthBar

    local HealthGradient = Instance.new('UIGradient')

    HealthGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Accent),
        ColorSequenceKeypoint.new(1, Colors.Secondary),
    }
    HealthGradient.Rotation = 90
    HealthGradient.Parent = HealthBar

    local HealthText = Instance.new('TextLabel')

    HealthText.Name = 'HealthText'
    HealthText.Size = UDim2.new(1, 0, 0, 16)
    HealthText.Position = UDim2.new(0, 0, 0, 64)
    HealthText.BackgroundTransparency = 1
    HealthText.Text = '100 / 100 HP'
    HealthText.Font = Enum.Font.GothamMedium
    HealthText.TextSize = IsMobile() and 11 or 12
    HealthText.TextColor3 = Colors.TextLight
    HealthText.TextXAlignment = Enum.TextXAlignment.Left
    HealthText.Parent = InfoContainer

    local DistanceText = Instance.new('TextLabel')

    DistanceText.Name = 'DistanceText'
    DistanceText.Size = UDim2.new(0, 70, 0, 16)
    DistanceText.Position = UDim2.new(1, -70, 0, 64)
    DistanceText.BackgroundTransparency = 1
    DistanceText.Text = '0m'
    DistanceText.Font = Enum.Font.GothamBold
    DistanceText.TextSize = IsMobile() and 11 or 12
    DistanceText.TextColor3 = Colors.Accent
    DistanceText.TextXAlignment = Enum.TextXAlignment.Right
    DistanceText.Parent = InfoContainer

    local ButtonContainer = Instance.new('Frame')

    ButtonContainer.Name = 'ButtonContainer'
    ButtonContainer.Size = UDim2.new(1, -30, 0, 32)
    ButtonContainer.Position = UDim2.new(0, 15, 1, -42)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Parent = MainFrame

    local ButtonLayout = Instance.new('UIListLayout')

    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.Padding = UDim.new(0, 8)
    ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ButtonLayout.Parent = ButtonContainer

    local function CreateButton(text, layoutOrder, callback)
        local button = Instance.new('TextButton')

        button.Name = text .. 'Button'
        button.Size = IsMobile() and UDim2.new(0.31, 0, 1, 0) or UDim2.new(0.31, 0, 1, 0)
        button.BackgroundColor3 = Colors.Accent
        button.BorderSizePixel = 0
        button.Text = text
        button.Font = Enum.Font.GothamBold
        button.TextSize = IsMobile() and 11 or 13
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.AutoButtonColor = false
        button.LayoutOrder = layoutOrder
        button.Parent = ButtonContainer

        local corner = Instance.new('UICorner')

        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.Secondary,
            }):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.Accent,
            }):Play()
        end)
        button.MouseButton1Click:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(0.31, -4, 1, -4),
            }):Play()
            wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(0.31, 0, 1, 0),
            }):Play()

            if callback then
                callback()
            end
        end)

        return button
    end

    local SpectateButton = CreateButton('Spectate', 1, function()
        spectating = not spectating
        SpectateButton.Text = spectating and 'ON' or 'Spectate'
    end)
    local TPButton = CreateButton('TP', 2, function()
        local target = Players:FindFirstChild(DYHUBcc.TargetAim.Target)

        if target and target.Character and target.Character:FindFirstChild('HumanoidRootPart') then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    end)
    local ClearButton = CreateButton('Clear', 3, function()
        DYHUBcc.TargetAim.Target = 'None'

        if tracer then
            
        end
        if tracerOutline then
            
        end
        if BodyClone then
            SetRigTransparency(BodyClone, 1)
        end
        if DesyncLine then
            DesyncLine.Visible = false
        end
        if BodyCloneHighlight then
            BodyCloneHighlight.Enabled = false
        end

        MainFrame.Visible = false
    end)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart

        TweenService:Create(MainFrame, TweenInfo.new(0.1), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y),
        }):Play()
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    local spectating = false
    local oldCam = nil
    local lastHealth = 100

    RunService.Heartbeat:Connect(function()
        if not (DYHUBcc and DYHUBcc.TargetAim and DYHUBcc.TargetAim.TargetStats and DYHUBcc.TargetAim.Enabled) then
            MainFrame.Visible = false

            return
        end

        local targetName = DYHUBcc.TargetAim.Target

        if not targetName or targetName == 'None' then
            MainFrame.Visible = false

            return
        end

        local target = Players:FindFirstChild(targetName)

        if not target then
            MainFrame.Visible = false

            return
        end

        MainFrame.Visible = true
        Avatar.Image = 'rbxthumb://type=AvatarHeadShot&id=' .. target.UserId .. '&w=420&h=420'
        PlayerName.Text = target.Name
        DisplayName.Text = '@' .. target.DisplayName

        local status, alive, statusColor = GetStatus(target)

        StatusText.Text = status:upper()
        StatusBadge.BackgroundColor3 = statusColor
        AvatarStroke.Color = statusColor

        local character = target.Character
        local humanoid = character and character:FindFirstChildOfClass('Humanoid')

        if humanoid then
            local currentHealth = math.floor(humanoid.Health)
            local maxHealth = math.floor(humanoid.MaxHealth)
            local healthPercent = currentHealth / maxHealth

            TweenService:Create(HealthBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(healthPercent, 0, 1, 0),
            }):Play()

            HealthText.Text = currentHealth .. ' / ' .. maxHealth .. ' HP'

            if healthPercent > 0.6 then
                HealthGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Colors.Accent),
                    ColorSequenceKeypoint.new(1, Colors.Secondary),
                }
            elseif healthPercent > 0.3 then
                HealthGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 193, 86)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 218, 150)),
                }
            else
                HealthGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 107, 107)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 150)),
                }
            end

            lastHealth = currentHealth
        end
        if character and character:FindFirstChild('HumanoidRootPart') and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then
            local distance = (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

            DistanceText.Text = math.floor(distance) .. 'm'
        end
    end)
end)()
TargetGroup:AddToggle('Highlight', {
    Text = 'Highlight',
    Default = true,
    Callback = function(Value)
        DYHUBcc.TargetAim.Highlight = Value
    end,
}):AddColorPicker('HighlightOutline', {
    Default = DYHUBcc.TargetAim.HighlightOutlineColor,
    Title = 'Outline Color',
    Callback = function(Value)
        DYHUBcc.TargetAim.HighlightOutlineColor = Value
    end,
})

local TweenService = game:GetService('TweenService')
local lastHPs = {}
local healthConnections = {}
local activeTweens = {}
local function getStateColor(character)
    local bodyEffects = character:FindFirstChild('BodyEffects')
    if not bodyEffects then
        return DYHUBcc.TargetAim.HighlightOutlineColor
    end
    local isDead = bodyEffects:FindFirstChild('SDeath') and bodyEffects.SDeath.Value
    local isKO = bodyEffects:FindFirstChild('K.O') and bodyEffects['K.O'].Value
    if isDead then
        return Color3.fromRGB(0, 0, 0)
    elseif isKO then
        return Color3.fromRGB(255, 0, 0)
    else
        return DYHUBcc.TargetAim.HighlightOutlineColor
    end
end
local function stopTween(highlight)
    if activeTweens[highlight] then
        activeTweens[highlight]:Cancel()
        activeTweens[highlight] = nil
    end
end
local function connectHealth(target)
    if healthConnections[target] then
        return
    end
    local function setup(character)
        local hum = character:FindFirstChild('Humanoid')
        if not hum then
            return
        end
        lastHPs[target] = hum.Health
        healthConnections[target] = hum.HealthChanged:Connect(function(newHP)
            if not character or not character.Parent then
                return
            end
            local highlight = character:FindFirstChild('DYHUBHighlight')
            if not highlight or not highlight.Enabled then
                return
            end
            local oldHP = lastHPs[target] or newHP
            lastHPs[target] = newHP
            stopTween(highlight)
            if newHP < oldHP then
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                local finalColor = getStateColor(character)
                local tween = TweenService:Create(highlight, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {OutlineColor = finalColor})
                activeTweens[highlight] = tween
                tween:Play()
                tween.Completed:Once(function()
                    if activeTweens[highlight] == tween then
                        activeTweens[highlight] = nil
                    end
                end)
            else
                highlight.OutlineColor = getStateColor(character)
            end
        end)
    end
    if target.Character then
        setup(target.Character)
    end
    target.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        setup(char)
    end)
end
local function disconnectHealth(target)
    if healthConnections[target] then
        healthConnections[target]:Disconnect()
        healthConnections[target] = nil
    end
    lastHPs[target] = nil
end

NewConnection(RunService.Heartbeat, function()
    if not DYHUBcc.TargetAim.Highlight then
        -- XÃ³a táº¥t cáº£ náº¿u táº¯t highlight
        for _, plr in ipairs(Players:GetPlayers()) do
            local hl = plr.Character and plr.Character:FindFirstChild('DYHUBHighlight')
            if hl then
                hl:Destroy()
                disconnectHealth(plr)
            end
        end
        return
    end

    local currentTargets = {}
    if MultiTargetEnabled then
        for _, name in ipairs(targetlist) do
            local plr = Players:FindFirstChild(name)
            if plr and plr.Character then
                table.insert(currentTargets, plr)
            end
        end
    else
        local targetName = DYHUBcc.TargetAim.Target
        if targetName ~= 'None' then
            local plr = Players:FindFirstChild(targetName)
            if plr and plr.Character then
                table.insert(currentTargets, plr)
            end
        end
    end

    -- XÃ³a highlight cho nhá»¯ng ngÆ°á»i khÃ´ng cÃ²n trong list
    for _, plr in ipairs(Players:GetPlayers()) do
        local inList = false
        for _, t in ipairs(currentTargets) do
            if t == plr then
                inList = true
                break
            end
        end
        if not inList then
            local hl = plr.Character and plr.Character:FindFirstChild('DYHUBHighlight')
            if hl then
                hl:Destroy()
                disconnectHealth(plr)
            end
        end
    end

    -- Táº¡o/update highlight cho current targets
    for _, target in ipairs(currentTargets) do
        local char = target.Character
        local hum = char:FindFirstChild('Humanoid')
        if not hum then continue end

        local highlight = char:FindFirstChild('DYHUBHighlight')
        if not highlight then
            highlight = Instance.new('Highlight')
            highlight.Name = 'DYHUBHighlight'
            highlight.FillTransparency = 1
            highlight.OutlineColor = DYHUBcc.TargetAim.HighlightOutlineColor
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = char
            highlight.Parent = char
            connectHealth(target)
        end
        -- Cáº­p nháº­t mÃ u state náº¿u cáº§n (ngoÃ i tween HP)
        highlight.OutlineColor = getStateColor(char)
    end
end)
TargetGroup:AddToggle('DotCircle', {
    Text = 'Dot Circle',
    Default = false,
    Callback = function(Value)
        DYHUBcc.TargetAim.DotCircle = Value
        DotCircle.Visible = Value and DYHUBcc.TargetAim.Enabled
    end,
}):AddColorPicker('DotCircleColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Dot Color',
    Callback = function(Value)
        DotCircle.Color = Value
    end,
})
TargetGroup:AddToggle('Tracer', {
    Text = 'Tracer',
    Default = true,
    Callback = function(Value)
        DYHUBcc.TargetAim.Tracer = Value
        if not Value then
            for _, ply in ipairs(game.Players:GetPlayers()) do
                removeTracer(ply)
            end
        end
    end,
}):AddColorPicker('TracerFillColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Tracer Color',
    Callback = function(Value)
        DYHUBcc.TargetAim.TracerFillColor = Value
        for _, beam in pairs(tracers) do
            beam.Color = ColorSequence.new(Value)
        end
    end
})
local TracerUpdateConnection = RunService.Heartbeat:Connect(function()
    if not DYHUBcc.TargetAim.Tracer then return end

    local targets = {}
    if MultiTargetEnabled then
        for _, name in ipairs(targetlist) do
            local ply = game.Players:FindFirstChild(name)
            if ply and ply.Character then
                table.insert(targets, ply)
            end
        end
    else
        local targetName = DYHUBcc.TargetAim.Target
        if targetName ~= 'None' then
            local ply = game.Players:FindFirstChild(targetName)
            if ply and ply.Character then
                table.insert(targets, ply)
            end
        end
    end

    -- Create/update for current targets
    for _, ply in ipairs(targets) do
        if not tracers[ply] then
            createTracer(ply)
        end
    end

    -- Remove extra
    for p in pairs(tracers) do
        local found = false
        for _, t in ipairs(targets) do
            if t == p then
                found = true
                break
            end
        end
        if not found then
            removeTracer(p)
        end
    end
end)
-- Sá»­a Dropdown TracerPosition
TargetGroup:AddDropdown('TracerPosition', {
    Values = {
        'Tool',
        'UpperTorso',
    },
    Default = 'Tool',
    Multi = false,
    Text = 'Tracer Position',
    Callback = function(Value)
        DYHUBcc.TargetAim.TracerPosition = Value
        -- Update existing tracers by recreating
        for ply in pairs(tracers) do
            createTracer(game.Players[ply])
        end
    end,
})
TargetGroup:AddToggle('LookAt', {
    Text = 'Look At',
    Default = false,
    Callback = function(Value)
        DYHUBcc.TargetAim.LookAt = Value
    end,
})
TargetGroup:AddButton('Teleport to Target', function()
    local targetName = DYHUBcc.TargetAim.Target

    if not targetName or targetName == '' or targetName == 'None' then
        Library:Notify('DYHUB - No target from TargetAim!', 3)

        return
    end

    local targetPlayer = Players:FindFirstChild(targetName)

    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild('HumanoidRootPart') then
        Library:Notify('DYHUB - Target not found or no character!', 3)

        return
    end

    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')

    if not hrp then
        Library:Notify('DYHUB - Your character not loaded!', 3)

        return
    end

    hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)

    Library:Notify('Teleported to ' .. targetName, 2)
end)
AutokillGroup:AddToggle('AutoKillEnabled', {
    Text = 'AutoKill',
    Default = false,
    Callback = function(Value)
        DYHUBcc.TargetAim.AutoKill = Value
        if not Value then
            AutoKillActive = Value
        end
    end,
}):AddKeyPicker('AutoKillKey', {
    Default = 'Y',
    Text = 'Auto Kill',
    Mode = 'Toggle',
    Callback = function(Value)
        DYHUBcc.TargetAim.AutoKill = Value
        if not Value then
            AutoKillActive = Value
        end
    end,
})
local supportsHackFlame = typeof(sethiddenproperty) == "function"

if supportsHackFlame then
    AutokillGroup:AddToggle('UseHackFlame', {
        Text = 'Use Hack Flame',
        Default = false,
        Callback = function(Value)
            DYHUBcc.TargetAim.UseHackFlame = Value
        end,
    })
else
    AutokillGroup:AddLabel('Hack Flame not supported on this executor')
end
AutokillGroup:AddToggle('AutoKillEnabled', {
    Text = 'Spoofer',
    Default = true,
    Callback = function(Value)
        DYHUBcc.TargetAim.Spoofer = Value
    end,
})

AutokillGroup:AddToggle('VisualizeStrafe', {
    Text = 'Visualize Strafe',
    Default = false,
    Callback = function(Value)
        DYHUBcc.TargetAim.VisualizeStrafe = Value
    end,
}):AddColorPicker('VisInline', {
    Default = DYHUBcc.TargetAim.VisualizeStrafeInlineColor,
    Title = 'Inline Color',
    Callback = function(Value)
        DYHUBcc.TargetAim.VisualizeStrafeInlineColor = Value
        BodyCloneHighlight.FillColor = Value
    end,
}):AddColorPicker('VisOutline', {
    Default = DYHUBcc.TargetAim.VisualizeStrafeOutlineColor,
    Title = 'Outline Color',
    Callback = function(Value)
        DYHUBcc.TargetAim.VisualizeStrafeOutlineColor = Value
        BodyCloneHighlight.OutlineColor = Value
    end,
})
local voidBypassEnabled = false
local voidLimit = 5000
AutokillGroup:AddToggle('VoidBypassEnabled', {
    Text = 'Void Bypass Enabled',
    Default = false,
    Callback = function(Value)
        voidBypassEnabled = Value
    end
})
AutokillGroup:AddSlider('Voidlimit', {
    Text = 'Void limit',
    Default = 5000,
    Min = 10,
    Max = 10000,
    Rounding = 0,
    Suffix = 'stud',
    Callback = function(v)
        voidLimit = v
    end,
})
local oldspoofer = false

AutokillGroup:AddToggle('AntiFlame', {
    Text = 'Anti Flame',
    Default = false,
    Callback = function(Value)
        if Value then
            oldspoofer = DYHUBcc.TargetAim.Spoofer
            DYHUBcc.TargetAim.Spoofer = false
        else
            DYHUBcc.TargetAim.Spoofer = oldspoofer
        end
    end,
})
AutokillGroup:AddDropdown('StrafeMethod', {
    Values = {
        'Orbit',
        'Randomize',
        'Crazy',
        'Bait',
        'Hyper Spiral',
        'Chaos Orbit',
        'Death ZigZag',
        'Fake Jump Pro',
        'Insane Figure8',
        'Nuclear Blender',
        'Demon 360',
        'Void Dancer',
        'Hell Spiral X',
        'Quantum Flicker',
        'Xk5 strafe',
        'Phantom Blitz',
        'Oblivion Vortex',
        'Rift Shatter',
        'Eclipse Pulse',
        'Doom Weaver',
    },
    Default = 'Randomize',
    Multi = false,
    Text = 'Strafe Method',
    Callback = function(Value)
        DYHUBcc.TargetAim.StrafeMethod = Value
    end,
})
local AllStrafeModes = {
    'Orbit', 'Randomize', 'Crazy', 'Bait', 'Hyper Spiral', 'Chaos Orbit',
    'Death ZigZag', 'Fake Jump Pro', 'Insane Figure8', 'Nuclear Blender',
    'Demon 360', 'Void Dancer', 'Hell Spiral X', 'Quantum Flicker',
    'Xk5 strafe', 'Phantom Blitz', 'Oblivion Vortex', 'Rift Shatter',
    'Eclipse Pulse', 'Doom Weaver',
}

-- Random Strafe Toggle + Slider (giá»¯ nguyÃªn)
AutokillGroup:AddToggle('RandomStrafe', {
    Text = 'Random Strafe Method',
    Default = false,
    Callback = function(v)
        DYHUBcc.TargetAim.RandomStrafe = v
    end,
})

AutokillGroup:AddSlider('RandomStrafeDelay', {
    Text = 'Random Strafe Delay (sec)',
    Default = 3,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Suffix = 's',
    Callback = function(v)
        DYHUBcc.TargetAim.RandomStrafeDelay = v
    end,
})

-- LOOP FIX: Fallback ALL modes (khÃ´ng fixed "Randomize") + random simple
task.spawn(function()
    local lastSwitch = tick()
    while task.wait(0.1) do
        if not DYHUBcc.TargetAim.RandomStrafe then
            lastSwitch = tick()
            continue
        end
        if tick() - lastSwitch >= DYHUBcc.TargetAim.RandomStrafeDelay then
            local pool = AllStrafeModes
            local newMethod = pool[math.random(1, #pool)]
            local oldMethod = DYHUBcc.TargetAim.StrafeMethod
            DYHUBcc.TargetAim.StrafeMethod = newMethod
            lastSwitch = tick()
        end
    end
end)
TargetGroup:AddToggle('AutoPredict', {
    Text = 'Auto Prediction',
    Default = false,
    Callback = function(Value)
        DYHUBcc.TargetAim.AutoPredict = Value
    end
})
-- Prediction Input (using Slider for numerical input)
TargetGroup:AddInput('Prediction', {
    Text = 'Prediction',
    Default = '0(recommend 0)',
    Numeric = true,
    Finished = true,
    Placeholder = '0.0',
    ClearTextOnFocus = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DYHUBcc.TargetAim.Prediction = num
        end
    end
})
TargetGroup:AddLabel("Auto Prediction and prediction for shoot and strafe")
local state = {
    lastTargetPosition = nil,
    lastTargetTime = nil,
    predictionType = DYHUBcc.TargetAim.PredictMode,
    predictionMultiplier = DYHUBcc.TargetAim.Prediction,
    expMinDist = 0,  -- Customize these as needed, perhaps add sliders
    expMaxDist = 10,
    expCurrentDist = 0,
    expDirection = 1,
    artPositionLog = {},
    artFoundPattern = nil,
    artLastRefresh = 0,
    artRefreshTime = 1,
    artMinMatches = 3,
    artForgiveness = 5,
    artOutOfVoidBonus = 10,
    artDistancePenalty = 0.1,
    resolveEnabled = DYHUBcc.TargetAim.Resolver,
    resolveMode = DYHUBcc.TargetAim.Resolvermode,
}
local ResolverGroup = Tabs.Target:AddLeftGroupbox('Resolver')
ResolverGroup:AddToggle('Resolver', {
    Text = 'Resolver',
    Default = false,
    Callback = function(Value)
        DYHUBcc.TargetAim.Resolver = Value
    end
})

-- Resolver Mode Dropdown
ResolverGroup:AddDropdown('ResolverMode', {
    Text = 'Mode',
    Default = 'predict',
    Values = {'predict', 'exponential', 'artifical'},
    Callback = function(v)
        DYHUBcc.TargetAim.Resolvermode = v
        state.resolveMode = v
    end
})

-- Predict Type Dropdown
ResolverGroup:AddDropdown('PredictType', {
    Text = 'Predict Type',
    Default = 'Custom',
    Values = {'Custom', 'Regular'},
    Callback = function(v)
        DYHUBcc.TargetAim.PredictMode = v
        state.predictionType = v
    end
})

-- Predict Strength Label + Input
ResolverGroup:AddLabel('Predict Strength')
ResolverGroup:AddInput('PredictStrength', {
    Default = '2.0',
    Numeric = true,
    Finished = true,
    Text = '',
    Placeholder = '2.0',
    Callback = function(v)
        local num = tonumber(v)
        if num then
            state.predictionMultiplier = num
        end
    end
})

-- Expo Min Distance Label + Input
ResolverGroup:AddLabel('Expo Min Distance')
ResolverGroup:AddInput('ExpoMinDist', {
    Default = '10',
    Numeric = true,
    Finished = true,
    Text = '',
    Placeholder = '10',
    Callback = function(v)
        local num = tonumber(v)
        if num then
            state.expMinDist = num
        end
    end
})

-- Expo Max Distance Label + Input
ResolverGroup:AddLabel('Expo Max Distance')
ResolverGroup:AddInput('ExpoMaxDist', {
    Default = '100',
    Numeric = true,
    Finished = true,
    Text = '',
    Placeholder = '100',
    Callback = function(v)
        local num = tonumber(v)
        if num then
            state.expMaxDist = num
        end
    end
})

-- Art Refresh Time Slider
ResolverGroup:AddSlider('ArtRefreshTime', {
    Text = 'Art Refresh Time',
    Min = 1,
    Max = 10,
    Default = 3,
    Rounding = 1,
    Suffix = 's',
    Callback = function(v)
        state.artRefreshTime = v
    end
})

-- Art Forgiveness Slider
ResolverGroup:AddSlider('ArtForgiveness', {
    Text = 'Art Forgiveness',
    Min = 1,
    Max = 50,
    Default = 14.4,
    Rounding = 1,
    Callback = function(v)
        state.artForgiveness = v
    end
})

-- Art Void Bonus Slider
ResolverGroup:AddSlider('ArtVoidBonus', {
    Text = 'Art Void Bonus',
    Min = 0,
    Max = 50,
    Default = 13,
    Rounding = 0,
    Callback = function(v)
        state.artOutOfVoidBonus = v
    end
})

-- Art Dist Penalty Slider
ResolverGroup:AddSlider('ArtDistPenalty', {
    Text = 'Art Dist Penalty',
    Min = 0,
    Max = 10,
    Default = 3.2,
    Rounding = 1,
    Suffix = 'x',
    Callback = function(v)
        state.artDistancePenalty = v
    end
})

-- Art Min Matches Slider
ResolverGroup:AddSlider('ArtMinMatches', {
    Text = 'Art Min Matches',
    Min = 1,
    Max = 20,
    Default = 3,
    Rounding = 0,
    Callback = function(v)
        state.artMinMatches = v
    end
})
-- The resolver functions as provided
local function resolvePredictPosition(targetRoot, targetPos)
    local currentTime = tick()
    if state.lastTargetPosition and state.lastTargetTime then
        local deltaTime = currentTime - state.lastTargetTime
        if deltaTime > 0 and deltaTime < 1 then
            local calculatedVelocity = (targetPos - state.lastTargetPosition) / deltaTime
            local velocityMagnitude = calculatedVelocity.Magnitude
            if state.predictionType == 'Custom' then
                if velocityMagnitude > 0.001 then
                    local predictionStrength = state.predictionMultiplier * 0.01
                    local distance = (targetPos - state.lastTargetPosition).Magnitude
                    local predictedDistance = (distance / deltaTime) * predictionStrength
                    local direction = (targetPos - state.lastTargetPosition).Unit
                    targetPos = targetPos + direction * predictedDistance
                end
            elseif state.predictionType == 'Regular' then
                if velocityMagnitude > 0.001 then
                    local predictionStrength = state.predictionMultiplier * 0.01
                    targetPos = targetPos + (calculatedVelocity * predictionStrength)
                end
            end
        end
    end
    state.lastTargetPosition = targetRoot.Position
    state.lastTargetTime = currentTime
    return targetPos
end

local function resolveExponentialPosition(targetRoot, targetPos)
    local step = (state.expMaxDist - state.expMinDist) / 10
    state.expCurrentDist = state.expCurrentDist + (step * state.expDirection)
    if state.expCurrentDist >= state.expMaxDist then
        state.expCurrentDist = state.expMaxDist
        state.expDirection = -1
    elseif state.expCurrentDist <= state.expMinDist then
        state.expCurrentDist = state.expMinDist
        state.expDirection = 1
    end
    local upVector = targetRoot.CFrame.UpVector
    return targetPos + (upVector * state.expCurrentDist)
end

local function resolveArtificalPosition(targetRoot, targetPos)
    local now = tick()
    if now - state.artLastRefresh >= state.artRefreshTime then
        state.artPositionLog = {}
        state.artFoundPattern = nil
        state.artLastRefresh = now
    end
    local forgiveness = state.artForgiveness
    local distFromCenter = math.abs(targetPos.X) + math.abs(targetPos.Z)
    local isOutOfVoid = distFromCenter < 7000
    if isOutOfVoid then
        forgiveness = forgiveness + state.artOutOfVoidBonus
    end
    local myChar = game.Players.LocalPlayer.Character
    if myChar and myChar:FindFirstChild('HumanoidRootPart') then
        local dist = (targetPos - myChar.HumanoidRootPart.Position).Magnitude
        local penalty = (dist / 100) * state.artDistancePenalty
        forgiveness = math.clamp(forgiveness - penalty, 1, 1000)
    end
    table.insert(state.artPositionLog, {
        pos = targetPos,
        time = now,
    })
    if #state.artPositionLog > 500 then
        local newLog = {}
        for i = #state.artPositionLog - 300, #state.artPositionLog do
            table.insert(newLog, state.artPositionLog[i])
        end
        state.artPositionLog = newLog
    end
    local matches = {}
    for i = 1, #state.artPositionLog do
        local p1 = state.artPositionLog[i].pos
        local count = 0
        local sum = Vector3.new(0, 0, 0)
        for j = 1, #state.artPositionLog do
            if i ~= j then
                local p2 = state.artPositionLog[j].pos
                local diff = (p1 - p2).Magnitude
                if diff <= forgiveness then
                    count = count + 1
                    sum = sum + p2
                end
            end
        end
        if count >= state.artMinMatches then
            table.insert(matches, {
                pos = (sum + p1) / (count + 1),
                count = count,
            })
        end
    end
    local best
    for _, m in ipairs(matches) do
        if not best or m.count > best.count then
            best = m
        end
    end
    if best then
        state.artFoundPattern = best.pos
        return best.pos
    end
    return Vector3.new(0, -10000, 0) -- getDeepVoid() example
end

local function getResolvedPosition(targetRoot)
    local basePos = targetRoot.Position
    if not state.resolveEnabled then
        return basePos
    end
    if state.resolveMode == 'predict' then
        return resolvePredictPosition(targetRoot, basePos)
    elseif state.resolveMode == 'exponential' then
        return resolveExponentialPosition(targetRoot, basePos)
    elseif state.resolveMode == 'artifical' then
        return resolveArtificalPosition(targetRoot, basePos)
    end
    return basePos
end

TargetGroup:AddToggle('AutoStomp', {
    Text = 'Auto Stomp',
    Default = false,
    Callback = function(Value)
        DYHUBcc.TargetAim.AutoStomp = Value
    end,
})

local targetAimSpectateConnection

TargetGroup:AddToggle('SpectateTarget', {
    Text = 'Spectate Target',
    Default = false,
    Callback = function(Value)
        DYHUBcc.TargetAim.SpectateTarget = Value

        if Value then
            if DYHUBcc.TargetAim.Target == 'None' then
                Library:Notify("DYHUB - please select a target before using 'Spectate Target'.", 3)

                Toggles.SpectateTarget.Value = false
                DYHUBcc.TargetAim.SpectateTarget = false

                return
            end
            if targetAimSpectateConnection then
                targetAimSpectateConnection:Disconnect()
            end

            targetAimSpectateConnection = NewConnection(RunService.Heartbeat, function()
                local targetName = DYHUBcc.TargetAim.Target

                if targetName == 'None' then
                    workspace.CurrentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild('Humanoid')
                    Toggles.SpectateTarget.Value = false
                    DYHUBcc.TargetAim.SpectateTarget = false

                    return
                end

                local targetPlayer = Players:FindFirstChild(targetName)

                if not targetPlayer then
                    return
                end

                local char = targetPlayer.Character
                local hum = char and char:FindFirstChild('Humanoid')

                if hum and hum.Health > 0 then
                    workspace.CurrentCamera.CameraSubject = hum
                else
                    workspace.CurrentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild('Humanoid')
                end
            end)
        else
            if targetAimSpectateConnection then
                targetAimSpectateConnection:Disconnect()

                targetAimSpectateConnection = nil
            end

            workspace.CurrentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild('Humanoid')
        end
    end,
}):AddKeyPicker('SpectateKey', {
    Default = 'B',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Spectate Target',
    Callback = function(Value)
        Toggles.SpectateTarget.Value = Value
    end,
})

local HitEffectsGroup = Tabs.Target:AddRightGroupbox('Hit Effects')

HitEffectsGroup:AddToggle('HitSkeleton', {
    Text = 'Hit Skeleton',
    Default = false,
    Callback = function(Value)
        DYHUBcc.HitEffects.HitSkeleton.Enabled = Value
    end,
}):AddColorPicker('HitSkeletonColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Skeleton Color',
    Callback = function(Value)
        DYHUBcc.HitEffects.HitSkeleton.Color = Value
    end,
})
HitEffectsGroup:AddToggle('HitChamsEnabled', {
    Text = 'Hit Chams',
    Default = false,
    Callback = function(Value)
        DYHUBcc.HitEffects.HitChams.Enabled = Value
    end,
}):AddColorPicker('HitChamsColor', {
    Default = DYHUBcc.HitEffects.HitChams.Color,
    Title = 'Hit Chams Color',
    Callback = function(Value)
        DYHUBcc.HitEffects.HitChams.Color = Value
    end,
})
HitEffectsGroup:AddSlider('HitChamsLifetime', {
    Text = 'Hit Chams and skeleton Lifetime (sec)',
    Min = 1,
    Max = 10,
    Default = DYHUBcc.HitEffects.HitChams.Lifetime,
    Rounding = 1,
    Callback = function(Value)
        DYHUBcc.HitEffects.HitChams.Lifetime = Value
    end,
})
HitEffectsGroup:AddSlider('HitChamsTransparency', {
    Text = 'Hit Chams and skeleton Transparency',
    Min = 0,
    Max = 1,
    Default = DYHUBcc.HitEffects.HitChams.Transparency,
    Rounding = 2,
    Callback = function(Value)
        DYHUBcc.HitEffects.HitChams.Transparency = Value
    end,
})
HitEffectsGroup:AddDropdown('HitChamsMaterial', {
    Values = {
        'Neon',
        'ForceField',
    },
    Default = DYHUBcc.HitEffects.HitChams.Material == 'Neon' and 1 or 2,
    Multi = false,
    Text = 'Hit Chams Material',
    Callback = function(Value)
        DYHUBcc.HitEffects.HitChams.Material = Value
    end,
})
HitEffectsGroup:AddToggle('HitEffectEnabled', {
    Text = 'Hit Effect',
    Default = false,
    Callback = function(Value)
        DYHUBcc.HitEffects.HitEffect.Enabled = Value
    end,
}):AddColorPicker('HitEffectColor', {
    Default = DYHUBcc.HitEffects.HitEffect.Color,
    Title = 'Effect Color',
    Callback = function(Value)
        DYHUBcc.HitEffects.HitEffect.Color = Value
    end,
})
HitEffectsGroup:AddDropdown('HitEffectType', {
    Values = {
        'Cosmic Explosion',
        'Coom',
        'Slash',
        'Atomic Slash',
        'Thunder',
        'Electric',
        'Aura',
    },
    Default = 'Coom',
    Multi = false,
    Text = 'Effect Type',
    Callback = function(Value)
        DYHUBcc.HitEffects.HitEffect.Type = Value
    end,
})

local Workspace = game:GetService('Workspace')

local function CreateAtomicSlashEffect()
    local Part = Instance.new('Part')

    Part.Parent = Workspace

    local Attachment = Instance.new('Attachment')

    Attachment.Parent = Part

    local Crescents = Instance.new('ParticleEmitter')

    Crescents.Name = 'Crescents'
    Crescents.Lifetime = NumberRange.new(0.19, 0.38)
    Crescents.SpreadAngle = Vector2.new(-360, 360)
    Crescents.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.1932907, 0),
        NumberSequenceKeypoint.new(0.778754, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    Crescents.LightEmission = 10
    Crescents.Color = ColorSequence.new(Color3.fromRGB(160, 96, 255))
    Crescents.VelocitySpread = -360
    Crescents.Speed = NumberRange.new(0.0826858, 0.0826858)
    Crescents.Brightness = 4
    Crescents.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.398774, 8.8026266, 2.2834616),
        NumberSequenceKeypoint.new(1, 11.477972, 1.860431),
    })
    Crescents.Enabled = false
    Crescents.ZOffset = 0.4542207
    Crescents.Rate = 50
    Crescents.Texture = 'rbxassetid://12509373457'
    Crescents.RotSpeed = NumberRange.new(800, 1000)
    Crescents.Rotation = NumberRange.new(-360, 360)
    Crescents.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
    Crescents.Parent = Attachment

    local Glow = Instance.new('ParticleEmitter')

    Glow.Name = 'Glow'
    Glow.Lifetime = NumberRange.new(0.16, 0.16)
    Glow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.1421725, 0.6182796),
        NumberSequenceKeypoint.new(1, 1),
    })
    Glow.Color = ColorSequence.new(Color3.fromRGB(173, 82, 252))
    Glow.Speed = NumberRange.new(0, 0)
    Glow.Brightness = 5
    Glow.Size = NumberSequence.new(9.1873131, 16.5032349)
    Glow.Enabled = false
    Glow.ZOffset = -5.65939E-2
    Glow.Rate = 50
    Glow.Texture = 'rbxassetid://8708637750'
    Glow.Parent = Attachment

    local Effect = Instance.new('ParticleEmitter')

    Effect.Name = 'Effect'
    Effect.Lifetime = NumberRange.new(0.4, 0.7)
    Effect.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
    Effect.SpreadAngle = Vector2.new(360, -360)
    Effect.LockedToPart = true
    Effect.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.1070999, 0.19375),
        NumberSequenceKeypoint.new(0.7761194, 0.88125),
        NumberSequenceKeypoint.new(1, 1),
    })
    Effect.LightEmission = 1
    Effect.Color = ColorSequence.new(Color3.fromRGB(173, 82, 252))
    Effect.Drag = 1
    Effect.VelocitySpread = 360
    Effect.Speed = NumberRange.new(0.0036749, 0.0036749)
    Effect.Brightness = 2.0999999
    Effect.Size = NumberSequence.new(6.9680691, 9.9213123)
    Effect.Enabled = false
    Effect.ZOffset = 0.4777403
    Effect.Rate = 50
    Effect.Texture = 'rbxassetid://9484012464'
    Effect.RotSpeed = NumberRange.new(-150, -150)
    Effect.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
    Effect.Rotation = NumberRange.new(50, 50)
    Effect.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
    Effect.Parent = Attachment

    local Gradient1 = Instance.new('ParticleEmitter')

    Gradient1.Name = 'Gradient1'
    Gradient1.Lifetime = NumberRange.new(0.3, 0.3)
    Gradient1.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.15, 0.3),
        NumberSequenceKeypoint.new(1, 1),
    })
    Gradient1.Color = ColorSequence.new(Color3.fromRGB(173, 82, 252))
    Gradient1.Speed = NumberRange.new(0, 0)
    Gradient1.Brightness = 6
    Gradient1.Size = NumberSequence.new(0, 11.6261358)
    Gradient1.Enabled = false
    Gradient1.ZOffset = 0.9187313
    Gradient1.Rate = 50
    Gradient1.Texture = 'rbxassetid://8196169974'
    Gradient1.Parent = Attachment

    local Shards = Instance.new('ParticleEmitter')

    Shards.Name = 'Shards'
    Shards.Lifetime = NumberRange.new(0.19, 0.7)
    Shards.SpreadAngle = Vector2.new(-90, 90)
    Shards.Color = ColorSequence.new(Color3.fromRGB(179, 145, 253))
    Shards.Drag = 10
    Shards.Squash = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5705521, 0.4125001),
        NumberSequenceKeypoint.new(1, -0.9375),
    })
    Shards.Speed = NumberRange.new(97.7530136, 146.9970093)
    Shards.Brightness = 4
    Shards.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.284774, 1.2389833, 0.1534118),
        NumberSequenceKeypoint.new(1, 0),
    })
    Shards.Enabled = false
    Shards.Acceleration = Vector3.new(0, -56.961341857910156, 0)
    Shards.ZOffset = 0.5705321
    Shards.Rate = 50
    Shards.Texture = 'rbxassetid://8030734851'
    Shards.Rotation = NumberRange.new(90, 90)
    Shards.Orientation = Enum.ParticleOrientation.VelocityParallel
    Shards.Parent = Attachment

    return Attachment
end
local function CreateAuraEffect()
    local Part = Instance.new('Part')

    Part.Parent = Workspace

    local Attachment = Instance.new('Attachment')

    Attachment.Parent = Part

    local SPIKES = Instance.new('ParticleEmitter')

    SPIKES.Name = 'SPIKES'
    SPIKES.Acceleration = Vector3.new(0, 100, 0)
    SPIKES.Color = ColorSequence.new(Color3.new(0, 1, 0), Color3.new(0, 1, 0))
    SPIKES.Drag = 3
    SPIKES.EmissionDirection = Enum.NormalId.Right
    SPIKES.Lifetime = NumberRange.new(0.25, 0.5)
    SPIKES.LightEmission = 1
    SPIKES.Orientation = Enum.ParticleOrientation.VelocityParallel
    SPIKES.Rate = 100
    SPIKES.Rotation = NumberRange.new(-90, -90)
    SPIKES.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 2, 0),
        NumberSequenceKeypoint.new(0.25, 3, 0.25),
        NumberSequenceKeypoint.new(0.653846, 2.0625, 0.164957),
        NumberSequenceKeypoint.new(1, 0, 0),
    })
    SPIKES.Speed = NumberRange.new(10, 25)
    SPIKES.SpreadAngle = Vector2.new(0, 180)
    SPIKES.Squash = NumberSequence.new({
        NumberSequenceKeypoint.new(0, -0.25),
        NumberSequenceKeypoint.new(1, 0.5),
        NumberSequenceKeypoint.new(1, 0.25),
    })
    SPIKES.Texture = 'rbxassetid://7451697448'
    SPIKES.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.25, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    SPIKES.Enabled = false
    SPIKES.Parent = Attachment

    local SPECKS = Instance.new('ParticleEmitter')

    SPECKS.Name = 'SPECKS'
    SPECKS.Acceleration = Vector3.new(0, -25, 0)
    SPECKS.Brightness = 2
    SPECKS.Color = ColorSequence.new(Color3.new(0, 1, 0), Color3.new(0, 1, 0))
    SPECKS.Drag = 5
    SPECKS.Lifetime = NumberRange.new(0.375, 0.625)
    SPECKS.LightEmission = 1
    SPECKS.Rate = 100
    SPECKS.RotSpeed = NumberRange.new(-45, 45)
    SPECKS.Rotation = NumberRange.new(-360, 360)
    SPECKS.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.25),
        NumberSequenceKeypoint.new(1, 0),
    })
    SPECKS.Speed = NumberRange.new(25, 50)
    SPECKS.SpreadAngle = Vector2.new(45, 45)
    SPECKS.Squash = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    SPECKS.Texture = 'rbxassetid://4509687978'
    SPECKS.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.25, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })
    SPECKS.Enabled = false
    SPECKS.Parent = Attachment

    local GLOW = Instance.new('ParticleEmitter')

    GLOW.Name = 'GLOW'
    GLOW.Acceleration = Vector3.new(0, 5, 0)
    GLOW.Color = ColorSequence.new(Color3.new(0, 1, 0), Color3.new(0, 1, 0))
    GLOW.Lifetime = NumberRange.new(0.5, 1)
    GLOW.LightEmission = 1
    GLOW.Rate = 50
    GLOW.Rotation = NumberRange.new(-360, 360)
    GLOW.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 8),
        NumberSequenceKeypoint.new(1, 3),
    })
    GLOW.Speed = NumberRange.new(10, 25)
    GLOW.Texture = 'rbxassetid://4509687978'
    GLOW.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.95),
        NumberSequenceKeypoint.new(1, 1),
    })
    GLOW.ZOffset = -1
    GLOW.Enabled = false
    GLOW.Parent = Attachment

    return Attachment
end
local function TriggerAura(HitPart, Color)
    local TempAttach = CreateAuraEffect():Clone()

    TempAttach.Parent = HitPart or Workspace.CurrentCamera

    for _, emitter in ipairs(TempAttach:GetChildren())do
        if emitter:IsA('ParticleEmitter') then
            emitter.Color = ColorSequence.new(Color or Color3.fromRGB(160, 96, 255))
            emitter.Enabled = true
        end
    end

    task.delay(2, function()
        for _, emitter in ipairs(TempAttach:GetChildren())do
            emitter.Enabled = false
        end

        TempAttach:Destroy()
    end)
end
local function CreateThunderEffect()
    local Part = Instance.new('Part')

    Part.Parent = Workspace

    local Attachment = Instance.new('Attachment')

    Attachment.Parent = Part

    local RESIDUE = Instance.new('ParticleEmitter')

    RESIDUE.Name = 'RESIDUE'
    RESIDUE.Acceleration = Vector3.new(0, -25, 0)
    RESIDUE.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 105, 170)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 105, 170)),
    }
    RESIDUE.Drag = 2
    RESIDUE.Lifetime = NumberRange.new(0.25, 0.5)
    RESIDUE.LightEmission = 1
    RESIDUE.Orientation = Enum.ParticleOrientation.VelocityParallel
    RESIDUE.Rate = 100
    RESIDUE.Rotation = NumberRange.new(90, 90)
    RESIDUE.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 2),
        NumberSequenceKeypoint.new(1, 0),
    }
    RESIDUE.Speed = NumberRange.new(25, 50)
    RESIDUE.SpreadAngle = Vector2.new(-90, 90)
    RESIDUE.Squash = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    }
    RESIDUE.Texture = 'rbxassetid://4509687978'
    RESIDUE.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.25, 1),
        NumberSequenceKeypoint.new(1, 1),
    }

    local ELECTRIC = Instance.new('ParticleEmitter')

    ELECTRIC.Name = 'ELECTRIC'
    ELECTRIC.Brightness = 3
    ELECTRIC.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 134, 199)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 134, 199)),
    }
    ELECTRIC.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8
    ELECTRIC.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
    ELECTRIC.Lifetime = NumberRange.new(0.5, 1)
    ELECTRIC.LightEmission = 2
    ELECTRIC.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
    ELECTRIC.Rate = 12
    ELECTRIC.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 25),
        NumberSequenceKeypoint.new(1, 0),
    }
    ELECTRIC.Speed = NumberRange.new(0, 0)
    ELECTRIC.SpreadAngle = Vector2.new(-360, 360)
    ELECTRIC.Texture = 'rbxassetid://10547286472'
    ELECTRIC.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.25, 1),
        NumberSequenceKeypoint.new(1, 1),
    }
    RESIDUE.Parent = Attachment
    RESIDUE.Enabled = true
    ELECTRIC.Parent = Attachment
    ELECTRIC.Enabled = true

    local SMOKE = Instance.new('ParticleEmitter')

    SMOKE.Name = 'SMOKE'
    SMOKE.Acceleration = Vector3.new(0, 5, 1)
    SMOKE.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(0.196078, 0.196078, 0.196078)),
        ColorSequenceKeypoint.new(1, Color3.new(0.196078, 0.196078, 0.196078)),
    })
    SMOKE.Drag = 1
    SMOKE.FlipbookFramerate = NumberRange.new(25, 25)
    SMOKE.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8
    SMOKE.LightInfluence = 1
    SMOKE.Rate = 10
    SMOKE.RotSpeed = NumberRange.new(-15, 15)
    SMOKE.Rotation = NumberRange.new(-360, 360)
    SMOKE.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 4, 0),
        NumberSequenceKeypoint.new(1, 8, 2),
    })
    SMOKE.Speed = NumberRange.new(1, 1)
    SMOKE.Texture = 'rbxassetid://8073306083'
    SMOKE.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1, 0),
        NumberSequenceKeypoint.new(0.5, 0.75, 0),
        NumberSequenceKeypoint.new(1, 1, 0),
    })
    SMOKE.Parent = Attachment
    SMOKE.Enabled = false

    return Attachment
end
local function TriggerThunder(HitPart, Color)
    local TempAttach = CreateThunderEffect():Clone()

    TempAttach.Parent = HitPart or Workspace.CurrentCamera

    for _, emitter in ipairs(TempAttach:GetChildren())do
        if emitter:IsA('ParticleEmitter') then
            emitter.Color = ColorSequence.new(Color or Color3.fromRGB(160, 96, 255))
            emitter.Enabled = true
        end
    end

    task.delay(2, function()
        for _, emitter in ipairs(TempAttach:GetChildren())do
            emitter.Enabled = false
        end

        TempAttach:Destroy()
    end)
end
local function CreateCoomEffect()
    local Part = Instance.new('Part')

    Part.Parent = Workspace

    local Attachment = Instance.new('Attachment')

    Attachment.Parent = Part

    local Foam = Instance.new('ParticleEmitter')

    Foam.Name = 'Foam'
    Foam.LightInfluence = 0.5
    Foam.Lifetime = NumberRange.new(1, 1)
    Foam.SpreadAngle = Vector2.new(360, -360)
    Foam.VelocitySpread = 360
    Foam.Squash = NumberSequence.new(1)
    Foam.Speed = NumberRange.new(20, 20)
    Foam.Brightness = 2.5
    Foam.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.1016692, 0.6508875, 0.6508875),
        NumberSequenceKeypoint.new(0.6494689, 1.4201183, 0.4127519),
        NumberSequenceKeypoint.new(1, 0),
    })
    Foam.Enabled = false
    Foam.Acceleration = Vector3.new(0, -66.04029846191406, 0)
    Foam.Rate = 100
    Foam.Texture = 'rbxassetid://8297030850'
    Foam.Rotation = NumberRange.new(-90, -90)
    Foam.Orientation = Enum.ParticleOrientation.VelocityParallel
    Foam.Parent = Attachment

    return Attachment
end
local function TriggerAtomicSlash(HitPart, Color)
    local TempAttach = CreateAtomicSlashEffect():Clone()

    TempAttach.Parent = HitPart or Workspace.CurrentCamera

    for _, emitter in ipairs(TempAttach:GetChildren())do
        if emitter:IsA('ParticleEmitter') then
            emitter.Color = ColorSequence.new(Color or Color3.fromRGB(160, 96, 255))
            emitter.Enabled = true
        end
    end

    task.delay(2, function()
        for _, emitter in ipairs(TempAttach:GetChildren())do
            emitter.Enabled = false
        end

        TempAttach:Destroy()
    end)
end
local function TriggerCoom(HitPart, Color)
    local TempAttach = CreateCoomEffect():Clone()

    TempAttach.Parent = HitPart or Workspace.CurrentCamera

    local foam = TempAttach:FindFirstChild('Foam')

    if foam then
        foam.Color = ColorSequence.new(Color or Color3.fromRGB(255, 255, 255))
        foam.Enabled = true

        task.delay(2, function()
            foam.Enabled = false

            TempAttach:Destroy()
        end)
    end
end
local function CreateCosmicExplosionEffect()
    local Part = Instance.new('Part')

    Part.Parent = Workspace

    local Attachment = Instance.new('Attachment')

    Attachment.Name = 'Attachment'
    Attachment.Parent = Part

    local Glow = Instance.new('ParticleEmitter')

    Glow.Name = 'Glow'
    Glow.Lifetime = NumberRange.new(0.16, 0.16)
    Glow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.1421725, 0.6182796),
        NumberSequenceKeypoint.new(1, 1),
    })
    Glow.Color = ColorSequence.new(Color3.fromRGB(173, 82, 252))
    Glow.Speed = NumberRange.new(0, 0)
    Glow.Brightness = 5
    Glow.Size = NumberSequence.new(9.1873131, 16.5032349)
    Glow.Enabled = false
    Glow.ZOffset = -5.65939E-2
    Glow.Rate = 50
    Glow.Texture = 'rbxassetid://8708637750'
    Glow.Parent = Attachment

    local Effect = Instance.new('ParticleEmitter')

    Effect.Name = 'Effect'
    Effect.Lifetime = NumberRange.new(0.4, 0.7)
    Effect.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
    Effect.SpreadAngle = Vector2.new(360, -360)
    Effect.LockedToPart = true
    Effect.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.1070999, 0.19375),
        NumberSequenceKeypoint.new(0.7761194, 0.88125),
        NumberSequenceKeypoint.new(1, 1),
    })
    Effect.LightEmission = 1
    Effect.Color = ColorSequence.new(Color3.fromRGB(173, 82, 252))
    Effect.Drag = 1
    Effect.VelocitySpread = 360
    Effect.Speed = NumberRange.new(0.0036749, 0.0036749)
    Effect.Brightness = 2.0999999
    Effect.Size = NumberSequence.new(6.9680691, 9.9213123)
    Effect.Enabled = false
    Effect.ZOffset = 0.4777403
    Effect.Rate = 50
    Effect.Texture = 'rbxassetid://9484012464'
    Effect.RotSpeed = NumberRange.new(-150, -150)
    Effect.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
    Effect.Rotation = NumberRange.new(50, 50)
    Effect.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
    Effect.Parent = Attachment

    local Gradient1 = Instance.new('ParticleEmitter')

    Gradient1.Name = 'Gradient1'
    Gradient1.Lifetime = NumberRange.new(0.3, 0.3)
    Gradient1.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.15, 0.3),
        NumberSequenceKeypoint.new(1, 1),
    })
    Gradient1.Color = ColorSequence.new(Color3.fromRGB(173, 82, 252))
    Gradient1.Speed = NumberRange.new(0, 0)
    Gradient1.Brightness = 6
    Gradient1.Size = NumberSequence.new(0, 11.6261358)
    Gradient1.Enabled = false
    Gradient1.ZOffset = 0.9187313
    Gradient1.Rate = 50
    Gradient1.Texture = 'rbxassetid://8196169974'
    Gradient1.Parent = Attachment

    local Shards = Instance.new('ParticleEmitter')

    Shards.Name = 'Shards'
    Shards.Lifetime = NumberRange.new(0.19, 0.7)
    Shards.SpreadAngle = Vector2.new(-90, 90)
    Shards.Color = ColorSequence.new(Color3.fromRGB(173, 82, 252))
    Shards.Drag = 10
    Shards.VelocitySpread = -90
    Shards.Squash = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5705521, 0.4125001),
        NumberSequenceKeypoint.new(1, -0.9375),
    })
    Shards.Speed = NumberRange.new(97.7530136, 146.9970093)
    Shards.Brightness = 4
    Shards.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.284774, 1.2389833, 0.1534118),
        NumberSequenceKeypoint.new(1, 0),
    })
    Shards.Enabled = false
    Shards.Acceleration = Vector3.new(0, -56.961341857910156, 0)
    Shards.ZOffset = 0.5705321
    Shards.Rate = 50
    Shards.Texture = 'rbxassetid://8030734851'
    Shards.Rotation = NumberRange.new(90, 90)
    Shards.Orientation = Enum.ParticleOrientation.VelocityParallel
    Shards.Parent = Attachment

    local Crescents = Instance.new('ParticleEmitter')

    Crescents.Name = 'Crescents'
    Crescents.Lifetime = NumberRange.new(0.19, 0.38)
    Crescents.SpreadAngle = Vector2.new(-360, 360)
    Crescents.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.1932907, 0),
        NumberSequenceKeypoint.new(0.778754, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    Crescents.LightEmission = 10
    Crescents.Color = ColorSequence.new(Color3.fromRGB(160, 96, 255))
    Crescents.VelocitySpread = -360
    Crescents.Speed = NumberRange.new(0.0826858, 0.0826858)
    Crescents.Brightness = 4
    Crescents.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.398774, 8.8026266, 2.2834616),
        NumberSequenceKeypoint.new(1, 11.477972, 1.860431),
    })
    Crescents.Enabled = false
    Crescents.ZOffset = 0.4542207
    Crescents.Rate = 50
    Crescents.Texture = 'rbxassetid://12509373457'
    Crescents.RotSpeed = NumberRange.new(800, 1000)
    Crescents.Rotation = NumberRange.new(-360, 360)
    Crescents.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
    Crescents.Parent = Attachment

    local ParticleEmitter2 = Instance.new('ParticleEmitter')

    ParticleEmitter2.Name = 'ParticleEmitter2'
    ParticleEmitter2.FlipbookFramerate = NumberRange.new(20, 20)
    ParticleEmitter2.Lifetime = NumberRange.new(0.19, 0.38)
    ParticleEmitter2.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
    ParticleEmitter2.SpreadAngle = Vector2.new(360, 360)
    ParticleEmitter2.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.209842, 0.5),
        NumberSequenceKeypoint.new(0.503842, 0.263333),
        NumberSequenceKeypoint.new(0.799842, 0.5),
        NumberSequenceKeypoint.new(1, 1),
    })
    ParticleEmitter2.LightEmission = 1
    ParticleEmitter2.Color = ColorSequence.new(Color3.fromRGB(173, 82, 252))
    ParticleEmitter2.VelocitySpread = 360
    ParticleEmitter2.Speed = NumberRange.new(0.0161231, 0.0161231)
    ParticleEmitter2.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 4.3125),
        NumberSequenceKeypoint.new(0.3985056, 7.9375),
        NumberSequenceKeypoint.new(1, 10),
    })
    ParticleEmitter2.Enabled = false
    ParticleEmitter2.ZOffset = 0.15
    ParticleEmitter2.Rate = 100
    ParticleEmitter2.Texture = 'http://www.roblox.com/asset/?id=12394566430'
    ParticleEmitter2.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
    ParticleEmitter2.Rotation = NumberRange.new(39, 999)
    ParticleEmitter2.Orientation = Enum.ParticleOrientation.VelocityParallel
    ParticleEmitter2.Parent = Attachment
    Part.Parent = workspace

    return Attachment
end
local function TriggerCosmicExplosion(HitPart, Color)
    local TempAttach = CreateCosmicExplosionEffect():Clone()

    TempAttach.Parent = HitPart or Workspace.CurrentCamera

    for _, emitter in ipairs(TempAttach:GetChildren())do
        if emitter:IsA('ParticleEmitter') then
            emitter.Color = ColorSequence.new(Color or Color3.fromRGB(160, 96, 255))
            emitter.Enabled = true
        end
    end

    task.delay(2, function()
        for _, emitter in ipairs(TempAttach:GetChildren())do
            emitter.Enabled = false
        end

        TempAttach:Destroy()
    end)
end
local function electric()
    local Part = Instance.new('Part')

    Part.Parent = Workspace

    local Attachment = Instance.new('Attachment')

    Attachment.Parent = Part

    local ELECTRIC1 = Instance.new('ParticleEmitter')

    ELECTRIC1.Name = 'ELECTRIC1'
    ELECTRIC1.Brightness = 5
    ELECTRIC1.Color = ColorSequence.new(Color3.fromRGB(0, 134, 199))
    ELECTRIC1.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8
    ELECTRIC1.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
    ELECTRIC1.Lifetime = NumberRange.new(1)
    ELECTRIC1.LightEmission = 1
    ELECTRIC1.Rate = 5
    ELECTRIC1.Size = NumberSequence.new(2)
    ELECTRIC1.Speed = NumberRange.new(0)
    ELECTRIC1.SpreadAngle = Vector2.new(-360, 360)
    ELECTRIC1.Texture = 'http://www.roblox.com/asset/?id=12390063093'
    ELECTRIC1.Transparency = NumberSequence.new(0, 1)
    ELECTRIC1.Enabled = false
    ELECTRIC1.Parent = Attachment

    local ELECTRIC2 = Instance.new('ParticleEmitter')

    ELECTRIC2.Name = 'ELECTRIC2'
    ELECTRIC2.Color = ColorSequence.new(Color3.fromRGB(0, 134, 199))
    ELECTRIC2.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8
    ELECTRIC2.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
    ELECTRIC2.Lifetime = NumberRange.new(0.25, 0.5)
    ELECTRIC2.LightEmission = 1
    ELECTRIC2.Rate = 25
    ELECTRIC2.Rotation = NumberRange.new(-360, 360)
    ELECTRIC2.Size = NumberSequence.new(2)
    ELECTRIC2.Speed = NumberRange.new(0)
    ELECTRIC2.SpreadAngle = Vector2.new(-360, 360)
    ELECTRIC2.Texture = 'http://www.roblox.com/asset/?id=12390081661'
    ELECTRIC2.Transparency = NumberSequence.new(0, 1)
    ELECTRIC2.Enabled = false
    ELECTRIC2.Parent = Attachment

    local ELECTRIC3 = Instance.new('ParticleEmitter')

    ELECTRIC3.Name = 'ELECTRIC3'
    ELECTRIC3.Color = ColorSequence.new(Color3.fromRGB(0, 134, 199))
    ELECTRIC3.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8
    ELECTRIC3.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
    ELECTRIC3.Lifetime = NumberRange.new(0.25, 0.5)
    ELECTRIC3.LightEmission = 1
    ELECTRIC3.Rate = 25
    ELECTRIC3.Rotation = NumberRange.new(-360, 360)
    ELECTRIC3.Size = NumberSequence.new(2)
    ELECTRIC3.Speed = NumberRange.new(0)
    ELECTRIC3.SpreadAngle = Vector2.new(-360, 360)
    ELECTRIC3.Texture = 'http://www.roblox.com/asset/?id=12390081661'
    ELECTRIC3.Transparency = NumberSequence.new(0, 1)
    ELECTRIC3.Enabled = false
    ELECTRIC3.Parent = Attachment

    local Wave1 = Instance.new('ParticleEmitter')

    Wave1.Name = 'Wave1'
    Wave1.Brightness = 10
    Wave1.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255))
    Wave1.Lifetime = NumberRange.new(1)
    Wave1.LightEmission = 0.4
    Wave1.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
    Wave1.Rate = 10
    Wave1.RotSpeed = NumberRange.new(200, 400)
    Wave1.Rotation = NumberRange.new(-180, 180)
    Wave1.Size = NumberSequence.new(3)
    Wave1.Speed = NumberRange.new(1, 3)
    Wave1.SpreadAngle = Vector2.new(10, -10)
    Wave1.Texture = 'rbxassetid://8047533775'
    Wave1.Transparency = NumberSequence.new(0, 1)
    Wave1.Enabled = false
    Wave1.Parent = Attachment

    local ELECTRIC4 = Instance.new('ParticleEmitter')

    ELECTRIC4.Name = 'ELECTRIC4'
    ELECTRIC4.Color = ColorSequence.new(Color3.fromRGB(0, 134, 199))
    ELECTRIC4.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8
    ELECTRIC4.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
    ELECTRIC4.Lifetime = NumberRange.new(0.25, 0.5)
    ELECTRIC4.LightEmission = 1
    ELECTRIC4.Rate = 25
    ELECTRIC4.Rotation = NumberRange.new(-360, 360)
    ELECTRIC4.Size = NumberSequence.new(2)
    ELECTRIC4.Speed = NumberRange.new(0)
    ELECTRIC4.SpreadAngle = Vector2.new(-360, 360)
    ELECTRIC4.Texture = 'http://www.roblox.com/asset/?id=12390081661'
    ELECTRIC4.Transparency = NumberSequence.new(0, 1)
    ELECTRIC4.Enabled = false
    ELECTRIC4.Parent = Attachment

    return Attachment
end
local function triggerelectric(HitPart, Color)
    local TempAttach = electric():Clone()

    TempAttach.Parent = HitPart or Workspace.CurrentCamera

    for _, emitter in ipairs(TempAttach:GetChildren())do
        if emitter:IsA('ParticleEmitter') then
            emitter.Color = ColorSequence.new(Color or Color3.fromRGB(160, 96, 255))
            emitter.Enabled = true
        end
    end

    task.delay(2, function()
        for _, emitter in ipairs(TempAttach:GetChildren())do
            emitter.Enabled = false
        end

        TempAttach:Destroy()
    end)
end
local function slash()
    local Part = Instance.new('Part')

    Part.Parent = Workspace

    local Attachment = Instance.new('Attachment')

    Attachment.Parent = Part

    local Crescents = Instance.new('ParticleEmitter')

    Crescents.Name = 'Crescents'
    Crescents.Lifetime = NumberRange.new(0.19, 0.38)
    Crescents.SpreadAngle = Vector2.new(-360, 360)
    Crescents.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.1932907, 0),
        NumberSequenceKeypoint.new(0.778754, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    Crescents.LightEmission = 10
    Crescents.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 96, 255)),
        ColorSequenceKeypoint.new(0.3160622, Color3.fromRGB(160, 96, 255)),
        ColorSequenceKeypoint.new(0.5146805, Color3.fromRGB(154, 82, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 96, 255)),
    })
    Crescents.VelocitySpread = -360
    Crescents.Speed = NumberRange.new(0.0826858, 0.0826858)
    Crescents.Brightness = 4
    Crescents.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.398774, 8.8026266, 2.2834616),
        NumberSequenceKeypoint.new(1, 11.477972, 1.860431),
    })
    Crescents.Enabled = false
    Crescents.ZOffset = 0.4542207
    Crescents.Rate = 50
    Crescents.Texture = 'rbxassetid://12509373457'
    Crescents.RotSpeed = NumberRange.new(800, 1000)
    Crescents.Rotation = NumberRange.new(-360, 360)
    Crescents.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
    Crescents.Parent = Attachment
    Part.Parent = workspace

    return Attachment
end
local function triggerslash(HitPart, Color)
    local TempAttach = slash():Clone()

    TempAttach.Parent = HitPart or Workspace.CurrentCamera

    for _, emitter in ipairs(TempAttach:GetChildren())do
        if emitter:IsA('ParticleEmitter') then
            emitter.Color = ColorSequence.new(Color or Color3.fromRGB(160, 96, 255))
            emitter.Enabled = true
        end
    end

    task.delay(2, function()
        for _, emitter in ipairs(TempAttach:GetChildren())do
            emitter.Enabled = false
        end

        TempAttach:Destroy()
    end)
end
local function TriggerHitEffect(Player)
    if not DYHUBcc.HitEffects.HitEffect.Enabled then
        return
    end
    if Player and Player.Character and Player.Character:FindFirstChild('HumanoidRootPart') then
        local HitPart = Player.Character.HumanoidRootPart
        local EffectType = DYHUBcc.HitEffects.HitEffect.Type
        local EffectColor = DYHUBcc.HitEffects.HitEffect.Color

        if EffectType == 'Atomic Slash' then
            TriggerAtomicSlash(HitPart, EffectColor)
        end
        if EffectType == 'Cosmic Explosion' then
            TriggerCosmicExplosion(HitPart, EffectColor)
        end
        if EffectType == 'Coom' then
            TriggerCoom(HitPart, EffectColor)
        end
        if EffectType == 'Thunder' then
            TriggerThunder(HitPart, EffectColor)
        end
        if EffectType == 'Slash' then
            triggerslash(HitPart, EffectColor)
        end
        if EffectType == 'Aura' then
            TriggerAura(HitPart, EffectColor)
        end
        if EffectType == 'Electric' then
            triggerelectric(HitPart, EffectColor)
        end
    end
end

local TweenService = game:GetService('TweenService')
local RaycastParams = RaycastParams.new()

RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
RaycastParams.IgnoreWater = true

local font = Enum.Font.SourceSansBold
local baseSize = 40
local distance = 10000
local animationDuration = 3
local fadeDuration = 1
local maxOffset = 20
local isDamageNumbersEnabled = false
local damageColor = Color3.fromRGB(255, 255, 255)
local previousHealth = {}

local function isPlayerVisible(player)
    if not player.Character or not player.Character:FindFirstChild('Head') then
        return false
    end

    local head = player.Character.Head
    local origin = Camera.CFrame.Position
    local direction = (head.Position - origin).Unit * (head.Position - origin).Magnitude

    RaycastParams.FilterDescendantsInstances = {
        Players.LocalPlayer.Character,
    }

    local result = workspace:Raycast(origin, direction, RaycastParams)

    return not result or result.Instance:IsDescendantOf(player.Character)
end
local function getNearestToCursor()
    local mouseLocation = UserInputService:GetMouseLocation()
    local nearestPlayer
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers())do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild('Head') then
            local head = player.Character.Head
            local screenPosition, onScreen = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local distanceToCursor = (Vector2.new(screenPosition.X, screenPosition.Y) - mouseLocation).Magnitude

                if distanceToCursor < shortestDistance then
                    shortestDistance = distanceToCursor
                    nearestPlayer = player
                end
            end
        end
    end

    return nearestPlayer
end
local function createDamageDisplay(player, damageAmount)
    if not isDamageNumbersEnabled then
        return
    end

    local head = player.Character and player.Character:FindFirstChild('Head')

    if head then
        local damageContainer = head:FindFirstChild('DamageContainer')

        if not damageContainer then
            damageContainer = Instance.new('BillboardGui')
            damageContainer.Name = 'DamageContainer'
            damageContainer.Parent = head
            damageContainer.Adornee = head
            damageContainer.Size = UDim2.new(0, 100, 0, 50)
            damageContainer.StudsOffset = Vector3.new(0, 2, 0)
            damageContainer.AlwaysOnTop = true
            damageContainer.MaxDistance = distance
            damageContainer.Enabled = true
        end

        local textLabel = Instance.new('TextLabel')

        textLabel.Parent = damageContainer
        textLabel.Text = tostring(damageAmount)
        textLabel.TextColor3 = damageColor
        textLabel.TextSize = baseSize + (damageAmount / 10)
        textLabel.Font = font
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 0, baseSize)
        textLabel.TextStrokeTransparency = 0.4
        textLabel.Position = UDim2.new(0.5, -50 + math.random(-maxOffset, maxOffset), 0, math.random(-maxOffset, maxOffset))

        local targetPosition = UDim2.new(0.5, -50, 0, -100)
        local moveUpTween = TweenService:Create(textLabel, TweenInfo.new(animationDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPosition})
        local fadeOutTween = TweenService:Create(textLabel, TweenInfo.new(fadeDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            TextTransparency = 1,
            TextStrokeTransparency = 1,
        })

        moveUpTween:Play()
        moveUpTween.Completed:Connect(function()
            fadeOutTween:Play()
            fadeOutTween.Completed:Connect(function()
                textLabel:Destroy()
            end)
        end)
    end
end
local function checkNearestPlayerDamage()
    local nearestPlayer = getNearestToCursor()

    if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChildOfClass('Humanoid') then
        local humanoid = nearestPlayer.Character:FindFirstChildOfClass('Humanoid')
        local currentHealth = humanoid.Health
        local prevHealth = previousHealth[nearestPlayer.UserId] or currentHealth

        if currentHealth < prevHealth then
            createDamageDisplay(nearestPlayer, math.floor(prevHealth - currentHealth))
        end

        previousHealth[nearestPlayer.UserId] = currentHealth
    end
end

RunService.RenderStepped:Connect(checkNearestPlayerDamage)
HitEffectsGroup:AddToggle('DamageNumbersEnabled', {
    Text = 'Damage Numbers',
    Default = false,
    Callback = function(Value)
        isDamageNumbersEnabled = Value
    end,
}):AddColorPicker('DamageColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Damage Color',
    Callback = function(Value)
        damageColor = Value
    end,
})
HitEffectsGroup:AddToggle('HitNotifications', {
    Text = 'Hit Notifications',
    Default = false,
    Callback = function(Value)
        DYHUBcc.HitEffects.HitNotifications = Value
    end,
})
HitEffectsGroup:AddSlider('NotifyTime', {
    Text = 'Notify Time',
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        DYHUBcc.HitEffects.HitNotificationsTime = Value
    end,
})
HitEffectsGroup:AddToggle('HitSounds', {
    Text = 'Hit Sounds',
    Default = false,
    Callback = function(Value)
        DYHUBcc.HitEffects.HitSounds = Value
    end,
})
HitEffectsGroup:AddDropdown('HitSoundSelect', {
    Values = {
        'Bubble',
        'Lazer',
        'Pick',
        'Pop',
        'Rust',
        'Sans',
        'Fart',
        'Big',
        'Vine',
        'UwU',
        'Bruh',
        'Skeet',
        'Neverlose',
        'Fatality',
        'Bonk',
        'Minecraft',
        'Gamesense',
        'RIFK7',
        'Bamboo',
        'Crowbar',
        'Weeb',
        'Beep',
        'Bambi',
        'Stone',
        'Old Fatality',
        'Click',
        'Ding',
        'Snow',
        'Laser',
        'Mario',
        'Steve',
        'Call of Duty',
        'Bat',
        'TF2 Critical',
        'Saber',
        'Baimware',
        'Osu',
        'TF2',
        'Slime',
        'Among Us',
        'One',
    },
    Default = 'Neverlose',
    Multi = false,
    Text = 'Hit Sound',
    Callback = function(Value)
        DYHUBcc.HitEffects.HitSoundID = hitsounds[Value]
    end,
})
HitEffectsGroup:AddSlider('HitSoundVolume', {
    Text = 'Volume',
    Default = 5,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        DYHUBcc.HitEffects.HitSoundVolume = Value
    end,
})
ChecksGroup:AddToggle('CheckWall', {
    Text = 'Check Wall',
    Default = false,
    Callback = function(Value)
        DYHUBcc.Checks.Wall = Value
    end,
})
ChecksGroup:AddToggle('CheckForcefield', {
    Text = 'Check Forcefield',
    Default = false,
    Callback = function(Value)
        DYHUBcc.Checks.Forcefield = Value
    end,
})
ChecksGroup:AddToggle('CheckAlive', {
    Text = 'Check Alive',
    Default = false,
    Callback = function(Value)
        DYHUBcc.Checks.Alive = Value
    end,
})
ChecksGroup:AddToggle('CheckTeam', {
    Text = 'Check Team',
    Default = false,
    Callback = function(Value)
        DYHUBcc.Checks.Team = Value
    end,
})
ChecksGroup:AddToggle('FOVCircleToggle', {
    Text = 'FOV Circle',
    Default = false,
    Callback = function(Value)
        FOVCircleEnabled = Value
        InnerCircle.Visible = Value
        FillCircle.Visible = Value and GradientFillEnabled
    end,
}):AddColorPicker('FOVInnerColorPicker', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Inner Circle Color',
    Callback = function(Value)
        FOVInnerColor = Value
        InnerCircle.Color = Value
    end,
})
ChecksGroup:AddSlider('FOVSizeSlider', {
    Text = 'FOV Size',
    Default = 300,
    Min = 100,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        FOVCircleSize = Value
        InnerCircle.Radius = Value
        FillCircle.Radius = Value
    end,
})
ChecksGroup:AddToggle('GradientFillToggle', {
    Text = 'Gradient Fill FOV Circle',
    Default = false,
    Callback = function(Value)
        GradientFillEnabled = Value
        FillCircle.Visible = FOVCircleEnabled and Value
    end,
}):AddColorPicker('GradientColor1Picker', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Gradient Color 1',
    Callback = function(Value)
        GradientColor1 = Value
    end,
})
ChecksGroup:AddSlider('FillTransparencySlider', {
    Text = 'Fill Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        FillTransparency = Value
        FillCircle.Transparency = Value
    end,
})
RunService.RenderStepped:Connect(function()
    if FOVCircleEnabled then
        local pos

        if UserInputService.TouchEnabled then
            pos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        else
            pos = UserInputService:GetMouseLocation()
        end

        InnerCircle.Position = pos
        FillCircle.Position = pos

        if GradientFillEnabled then
            FillCircle.Color = GradientColor1
        end
    end
end)

local KillAuraGroup = Tabs.Main:AddRightGroupbox('Kill Aura')

KillAuraGroup:AddToggle('KillAuraEnabled', {
    Text = 'Enabled',
    Default = false,
    Callback = function(Value)
        DYHUBcc.KillAura.Enabled = Value

        if not Value then
            DYHUBcc.KillAura.Active = false
            ka_tracer.Transparency = 1
        end
    end,
}):AddKeyPicker('KillAuraKey', {
    Default = 'K',
    Text = 'Kill Aura',
    Mode = 'Toggle',
    Callback = function(Value)
        if DYHUBcc.KillAura.Enabled then
            DYHUBcc.KillAura.Active = Value
        end
    end,
})
KillAuraGroup:AddSlider('KillAuraRange', {
    Text = 'Range',
    Default = 250,
    Min = 10,
    Max = 250,
    Rounding = 0,
    Callback = function(Value)
        DYHUBcc.KillAura.Range = Value
    end,
})
KillAuraGroup:AddToggle('KillAuraSilent', {
    Text = 'Silent',
    Default = false,
    Callback = function(Value)
        DYHUBcc.KillAura.Silent = Value
    end,
})
KillAuraGroup:AddToggle('KillAuraVisualize', {
    Text = 'Visualize',
    Default = false,
    Callback = function(Value)
        DYHUBcc.KillAura.Visualize = Value
    end,
}):AddColorPicker('KAVisColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Visualizer Color',
    Callback = function(Value)
        ka_tracer.Color = Value
    end,
})
KillAuraGroup:AddToggle('StompAura', {
    Text = 'Stomp Aura',
    Default = false,
    Callback = function(Value)
        DYHUBcc.KillAura.StompAura = Value
    end,
})

local function ApplyWallbang(state)
    DYHUBcc.Wallbang.Enabled = state

    if not getnamecallmethod then
        Library:Notify('Your executor does not support Wallbang.', 3)

        return
    end

    local ReplicatedStorage = game:GetService('ReplicatedStorage')
    local Handler = ReplicatedStorage:FindFirstChild('MainModule')

    if not Handler then
        return
    end

    local Module = require(Handler)

    if state and workspace:FindFirstChild('Vehicles') then
        Module.Ignored = {
            workspace:WaitForChild('Vehicles'),
            workspace:WaitForChild('MAP'),
            workspace:WaitForChild('Ignored'),
        }
    else
        if workspace:FindFirstChild('Vehicles') then
            Module.Ignored = {
                workspace:WaitForChild('Vehicles'),
                workspace:WaitForChild('Ignored'),
            }
        end
    end
end
local LegitBox = Tabs.Main:AddLeftTabbox()
local AimlockBox = LegitBox:AddTab('Aimlock')
local SilentBox = LegitBox:AddTab('SilentAim')
local sentryAutoSet = false
local sentryNotify = true
local SentryGroup = Tabs.Main:AddLeftGroupbox("Sentry")
SentryGroup:AddToggle("SentryNotify", {Text = "Notify Who Hit", Default = true, Callback = function(v) sentryNotify = v end})
SentryGroup:AddToggle("SentryAutoSet", {Text = "Auto Set Target", Default = false, Callback = function(v) sentryAutoSet = v end})
local replicated = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local lplr = players.LocalPlayer
local MainEvent = replicated:FindFirstChild("MainEvent") -- Assuming MainEvent is the remote
if MainEvent then
    MainEvent.OnClientEvent:Connect(function(name, shooter, handle, forced, aimpos, targetpart, _)
        if shooter == lplr then return end
        if shooter and targetpart and targetpart:IsDescendantOf(lplr.Character) then
            if sentryNotify then
                Library:Notify("You were hit by " .. shooter.Name, 5)
            end
            if sentryAutoSet then
                if MultiTargetEnabled then
                    toggleTargetInList(shooter)
                    updateTargetLabel()
                    Library:Notify("Added " .. shooter.Name .. " to target list", 3)
                else
                    DYHUBcc.TargetAim.Target = shooter.Name
                    updateTargetLabel()
                    Library:Notify("Set target to " .. shooter.Name, 3)
                end
            end
        end
    end)
end
local GunModsGroup = Tabs.Main:AddRightGroupbox('Gun Mods')
local BulletTpGroup = Tabs.Main:AddLeftGroupbox('Bullet Tp')

if getnamecallmethod then
    local players = game:GetService('Players')
    local run_service = game:GetService('RunService')
    local user_input_service = game:GetService('UserInputService')
    local tween_service = game:GetService('TweenService')
    local client = players.LocalPlayer
    local mouse = client:GetMouse()
    local Camera = workspace.CurrentCamera
    local script_data = {
        functions = {},
        targeting = {target = nil},
        connections = {},
        utility = {gun = {}},
    }
    local config = {
        bullet_tp = false,
        part = 'Head',
        bullet_tp_mode = 'Follow Nearest Cursor',
    }

    BulletTpGroup:AddToggle('BulletTP', {
        Text = 'Bullet TP',
        Default = config.bullet_tp,
        Callback = function(value)
            config.bullet_tp = value

            if value then
                Library:Notify('Bullet TP Enabled', 2)
                ApplyWallbang(true)
            else
                Library:Notify('Bullet TP Disabled', 2)

                script_data.targeting.target = nil
            end
        end,
    })
    BulletTpGroup:AddDropdown('BulletTPPart', {
        Text = 'TP Bullet Part',
        Values = {
            'Head',
            'HumanoidRootPart',
            'Torso',
            'LeftArm',
            'RightArm',
            'LeftLeg',
            'RightLeg',
        },
        Default = 'Head',
        Callback = function(value)
            config.part = value
        end,
    })
    BulletTpGroup:AddDropdown('BulletTPMode', {
        Text = 'TP Bullet Mode',
        Values = {
            'Follow Target Aim',
            'Follow Nearest Cursor',
        },
        Default = 'Follow Nearest Cursor',
        Callback = function(value)
            config.bullet_tp_mode = value
        end,
    })

    function script_data.targeting.get_closest_target()
        local closest = nil

        if config.bullet_tp_mode == 'Follow Target Aim' then
            local targetName = DYHUBcc.TargetAim.Target

            if targetName and targetName ~= 'None' then
                local targetPlayer = players:FindFirstChild(targetName)

                if targetPlayer and targetPlayer.Character then
                    local humanoid = targetPlayer.Character:FindFirstChild('Humanoid')
                    local root = targetPlayer.Character:FindFirstChild('HumanoidRootPart')

                    if humanoid and humanoid.Health > 0 and root then
                        closest = targetPlayer
                    end
                end
            end
        end
        if not closest or config.bullet_tp_mode == 'Follow Nearest Cursor' then
            local min_dist = math.huge
            local isMobile = user_input_service.TouchEnabled and not user_input_service.KeyboardEnabled
            local screenPos = isMobile and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) or user_input_service:GetMouseLocation()

            for _, player in ipairs(players:GetPlayers())do
                if player ~= client and player.Character then
                    local root = player.Character:FindFirstChild('HumanoidRootPart')
                    local humanoid = player.Character:FindFirstChild('Humanoid')

                    if root and humanoid and humanoid.Health > 0 then
                        local worldPos, onScreen = Camera:WorldToViewportPoint(root.Position)

                        if onScreen then
                            local dist = (Vector2.new(worldPos.X, worldPos.Y) - screenPos).Magnitude

                            if dist < min_dist then
                                min_dist = dist
                                closest = player
                            end
                        end
                    end
                end
            end
        end

        script_data.targeting.target = closest

        return closest
    end

    local mt = getrawmetatable(game)

    setreadonly(mt, false)

    local old_index = mt.__index

    mt.__index = function(self, index)
        if not checkcaller() and self == mouse then
            if (index == 'Hit' or (index == 'Target' and game.PlaceId == 2788229376)) and config.bullet_tp then
                local target = script_data.targeting.target

                if target and target.Character then
                    local part = target.Character:FindFirstChild(config.part) or target.Character:FindFirstChild('HumanoidRootPart')

                    if part then
                        if index == 'Hit' then
                            return CFrame.new(part.Position)
                        else
                            return part
                        end
                    end
                end
            end
        end

        return old_index(self, index)
    end

    setreadonly(mt, true)

    script_data.functions.cframe_to_offset = function(origin, target)
        local actual_origin = origin * CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0)

        return actual_origin:ToObjectSpace(target):inverse()
    end
    script_data.functions.teleport_bullet = function(tool)
        if not config.bullet_tp then
            return
        end

        local target = script_data.targeting.target

        if not (target and target.Character) then
            return
        end

        local target_part = target.Character:FindFirstChild(config.part) or target.Character:FindFirstChild('HumanoidRootPart')

        if not target_part then
            return
        end

        local char = client.Character

        if not char or not char:FindFirstChild('RightHand') then
            return
        end

        local original_grip = tool.Grip

        tool.Parent = client.Backpack
        tool.Grip = script_data.functions.cframe_to_offset(char.RightHand.CFrame, target_part.CFrame)
        tool.Parent = char

        run_service.RenderStepped:Wait()

        tool.Parent = client.Backpack
        tool.Grip = original_grip
        tool.Parent = char
    end
    script_data.functions.handle_character = function(character)
        for _, conn in ipairs({
            'character_child_added',
            'child_removing_character',
        })do
            if script_data.connections[conn] then
                script_data.connections[conn]:Disconnect()
            end
        end

        script_data.connections.character_child_added = character.ChildAdded:Connect(function(tool)
            if tool:IsA('Tool') then
                for _, conn in ipairs(getconnections(tool:GetPropertyChangedSignal('Grip')))do
                    conn:Disable()
                end

                script_data.connections.tool_activated = tool.Activated:Connect(function()
                    if config.bullet_tp then
                        script_data.functions.teleport_bullet(tool)
                    end
                end)
            end
        end)
        script_data.connections.child_removing_character = character.ChildRemoved:Connect(function()
            script_data.utility.gun.tool = nil

            if script_data.connections.tool_activated then
                script_data.connections.tool_activated:Disconnect()
            end
        end)
    end

    local function setup_character(char)
        script_data.functions.handle_character(char)
    end

    local current_character = client.Character or client.CharacterAdded:Wait()

    setup_character(current_character)
    client.CharacterAdded:Connect(setup_character)
    client.CharacterRemoving:Connect(function()
        for _, conn in ipairs({
            'character_child_added',
            'child_removing_character',
        })do
            if script_data.connections[conn] then
                script_data.connections[conn]:Disconnect()
            end
        end
    end)
    run_service.Heartbeat:Connect(function()
        if config.bullet_tp then
            script_data.targeting.get_closest_target()
        end
    end)
else
    BulletTpGroup:AddLabel("Your executor doesn't support BulletTp")
end

DYHUBcc.EquipAllGuns = {Enabled = false}

local EquipAllConnection = nil
local lastEquipTime = 0
local EquipAllConnection
local EquipAddedConnection

local function equipAllGuns()
    local char = localPlayer.Character
    local backpack = localPlayer.Backpack

    if not char or not backpack then
        return
    end

    for _, tool in ipairs(backpack:GetChildren())do
        if tool:IsA('Tool') and tool:FindFirstChild('Ammo') then
            tool.Parent = char
        end
    end
end
local function setupEquipAll()
    local char = localPlayer.Character
    local backpack = localPlayer.Backpack

    if not char or not backpack or not DYHUBcc.EquipAllGuns.Enabled then
        return
    end

    equipAllGuns()

    if EquipAllConnection then
        EquipAllConnection:Disconnect()

        EquipAllConnection = nil
    end

    EquipAllConnection = char.ChildRemoved:Connect(function(child)
        if DYHUBcc.EquipAllGuns.Enabled and child:IsA('Tool') and child:FindFirstChild('Ammo') and (tick() - lastEquipTime) >= 0.5 then
            lastEquipTime = tick()

            task.spawn(function()
                task.wait(0.1)
                equipAllGuns()
            end)
        end
    end)

    if EquipAddedConnection then
        EquipAddedConnection:Disconnect()

        EquipAddedConnection = nil
    end

    EquipAddedConnection = backpack.ChildAdded:Connect(function(child)
        if DYHUBcc.EquipAllGuns.Enabled and child:IsA('Tool') and child:FindFirstChild('Ammo') then
            child.Parent = char
        end
    end)
end

localPlayer.CharacterAdded:Connect(function()
    task.wait(5)

    if DYHUBcc.EquipAllGuns.Enabled then
        setupEquipAll()
    end
end)
GunModsGroup:AddToggle('EquipAllGunsEnabled', {
    Text = 'Equip All Guns',
    Default = false,
    Callback = function(Value)
        DYHUBcc.EquipAllGuns.Enabled = Value

        if Value then
            setupEquipAll()
        else
            if EquipAllConnection then
                EquipAllConnection:Disconnect()

                EquipAllConnection = nil
            end
        end
    end,
}):AddKeyPicker('EquipAllGunsKey', {
    Default = 'none',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Equip All Guns',
})
GunModsGroup:AddToggle('RapidFireEnabled', {
    Text = 'Rapid Fire',
    Default = false,
    Callback = function(Value)
        DYHUBcc.RapidFire.Enabled = Value

        if not getnamecallmethod then
            local iter, tbl, index = ipairs(game:GetDescendants())

            while true do
                local instance

                index, instance = iter(tbl, index)

                if index == nil then
                    break
                end
                if instance.Name == 'ShootingCooldown' and instance:IsA('ValueBase') then
                    instance.Value = 0
                end
            end

            game.DescendantAdded:Connect(function(newDescendant)
                if newDescendant.Name == 'ShootingCooldown' and newDescendant:IsA('ValueBase') then
                    newDescendant.Value = 0
                end
            end)

            local iter2, tbl2, index2 = ipairs(game:GetDescendants())

            while true do
                local instance2

                index2, instance2 = iter2(tbl2, index2)

                if index2 == nil then
                    break
                end
                if instance2.Name == 'ToleranceCooldown' and instance2:IsA('ValueBase') then
                    instance2.Value = 0
                end
            end

            game.DescendantAdded:Connect(function(newDescendant2)
                if newDescendant2.Name == 'ToleranceCooldown' and newDescendant2:IsA('ValueBase') then
                    newDescendant2.Value = 0
                end
            end)
            wait(2)

            game.Players.LocalPlayer.Character.Humanoid.Health = 0
        end
    end,
})
GunModsGroup:AddToggle('WallbangEnabled', {
    Text = 'Wallbang',
    Default = false,
    Callback = function(Value)
        DYHUBcc.Wallbang.Enabled = Value

        if getnamecallmethod then
            local Handler = game:FindService('ReplicatedStorage').MainModule
            local Module = require(Handler)

            if Value == true and workspace:FindFirstChild('Vehicles') then
                Module.Ignored = {
                    workspace:WaitForChild('Vehicles'),
                    workspace:WaitForChild('MAP'),
                    workspace:WaitForChild('Ignored'),
                }
            else
                if workspace:FindFirstChild('Vehicles') then
                    Module.Ignored = {
                        workspace:WaitForChild('Vehicles'),
                        workspace:WaitForChild('Ignored'),
                    }
                end
            end
        else
            Library:Notify('Your executor does not support this feature.', 3)
        end
    end,
})

if isDaHood then
    getgenv().RemoveShootAnimationsEnabled = false
    getgenv().ShootAnimationIds = {
        ['rbxassetid://2807049953'] = true,
        ['rbxassetid://2809413000'] = true,
        ['rbxassetid://2809419094'] = true,
        ['rbxassetid://507768375'] = true,
        ['rbxassetid://507755388'] = true,
        ['rbxassetid://2807049953'] = true,
        ['rbxassetid://2877910736'] = true,
    }
    getgenv().StopAnimationTracks = function(character)
        local humanoid = character:FindFirstChildOfClass('Humanoid')

        if humanoid then
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks())do
                if getgenv().ShootAnimationIds[track.Animation.AnimationId] then
                    track:Stop()
                end
            end
        end
    end
    getgenv().MonitorCharacter = function(character)
        character.DescendantAdded:Connect(function(descendant)
            if descendant:IsA('AnimationTrack') and getgenv().RemoveShootAnimationsEnabled then
                if getgenv().ShootAnimationIds[descendant.Animation.AnimationId] then
                    descendant:Stop()
                end
            end
        end)
    end
    getgenv().MonitorPlayers = function()
        for _, player in ipairs(game:GetService('Players'):GetPlayers())do
            local character = player.Character or player.CharacterAdded:Wait()

            getgenv().StopAnimationTracks(character)
            getgenv().MonitorCharacter(character)
            player.CharacterAdded:Connect(function(newCharacter)
                getgenv().StopAnimationTracks(newCharacter)
                getgenv().MonitorCharacter(newCharacter)
            end)
        end

        game:GetService('Players').PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                getgenv().StopAnimationTracks(character)
                getgenv().MonitorCharacter(character)
            end)
        end)
    end
    getgenv().MonitorAnimations = function()
        game:GetService('RunService').RenderStepped:Connect(function()
            if getgenv().RemoveShootAnimationsEnabled then
                for _, player in ipairs(game:GetService('Players'):GetPlayers())do
                    local character = player.Character

                    if character then
                        getgenv().StopAnimationTracks(character)
                    end
                end
            end
        end)
    end

    GunModsGroup:AddToggle('AntiflingToggle', {
        Text = 'remove shoot animations',
        Default = false,
        Callback = function(enabled)
            getgenv().RemoveShootAnimationsEnabled = enabled

            if enabled then
                getgenv().MonitorPlayers()
                task.spawn(getgenv().MonitorAnimations)
            end
        end,
    })
end

local HitboxGroup = Tabs.Main:AddRightGroupbox('Hitbox Expander')

HitboxGroup:AddToggle('HitboxEnabled', {
    Text = 'Enabled',
    Default = false,
    Callback = function(Value)
        DYHUBcc.HitboxExpander.Enabled = Value
    end,
})
HitboxGroup:AddToggle('HitboxVisualize', {
    Text = 'Visualize',
    Default = false,
    Callback = function(Value)
        DYHUBcc.HitboxExpander.Visualize = Value
    end,
}):AddColorPicker('HitboxColor', {
    Default = DYHUBcc.HitboxExpander.Color,
    Title = 'Fill Color',
    Callback = function(Value)
        DYHUBcc.HitboxExpander.Color = Value
    end,
}):AddColorPicker('HitboxOutline', {
    Default = DYHUBcc.HitboxExpander.OutlineColor,
    Title = 'Outline Color',
    Callback = function(Value)
        DYHUBcc.HitboxExpander.OutlineColor = Value
    end,
})
HitboxGroup:AddSlider('HitboxFillTrans', {
    Text = 'Fill Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        DYHUBcc.HitboxExpander.FillTransparency = Value
    end,
})
HitboxGroup:AddSlider('HitboxOutlineTrans', {
    Text = 'Outline Transparency',
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        DYHUBcc.HitboxExpander.OutlineTransparency = Value
    end,
})
HitboxGroup:AddSlider('HitboxSize', {
    Text = 'Size',
    Default = 15,
    Min = 1,
    Max = 37,
    Rounding = 0,
    Callback = function(Value)
        DYHUBcc.HitboxExpander.Size = Value
    end,
})
coroutine.wrap(function()
getgenv().DYHUB.Legit = {
    Aimlock = false,
    HitPart = 'Head',
    Smoothing = false,
    SmoothingAmount = 0.1,
    Prediction = 0.05,
    JumpOffset = 0,
    Offset = true,
    SilentFOV = 100,
    SilentFOVEnabled = false,
    Resolver = false,
    Triggerbot = {
        Enabled = false,
        FOV = 20,
        Delay = 0,
        OnlyTarget = false,
        CheckKO = false,
        CheckKnife = false,
        CheckGrab = false,
        CheckTeam = false,
        CheckFriend = false,
    },
}
getgenv().DYHUB.Legit.Triggerbot.HitParts = {
    'Head',
    'HumanoidRootPart',
    'UpperTorso',
    'LowerTorso',
    'LeftUpperArm',
    'RightUpperArm',
    'LeftLowerArm',
    'RightLowerArm',
    'LeftHand',
    'RightHand',
    'LeftUpperLeg',
    'RightUpperLeg',
    'LeftLowerLeg',
    'RightLowerLeg',
    'LeftFoot',
    'RightFoot',
    'Torso',
    'Left Arm',
    'Right Arm',
    'Left Leg',
    'Right Leg',
}
getgenv().DYHUB.Legit.Triggerbot.SelectedHitParts = {
    'Head',
    'HumanoidRootPart',
    'UpperTorso',
    'LowerTorso',
    'LeftUpperArm',
    'RightUpperArm',
    'LeftLowerArm',
    'RightLowerArm',
    'LeftHand',
    'RightHand',
    'LeftUpperLeg',
    'RightUpperLeg',
    'LeftLowerLeg',
    'RightLowerLeg',
    'LeftFoot',
    'RightFoot',
    'Torso',
    'Left Arm',
    'Right Arm',
    'Left Leg',
    'Right Leg',
}

AimlockBox:AddLabel("From Targetaim")
AimlockBox:AddToggle('AimlockEnabled', {
    Text = 'Aimlock',
    Default = false,
    Callback = function(Value)
        getgenv().DYHUB.Legit.Aimlock = Value
    end,
})
AimlockBox:AddDropdown('HitPart', {
    Values = {
        'Head',
        'UpperTorso',
        'HumanoidRootPart',
    },
    Default = 1,
    Multi = false,
    Text = 'Hit Part',
    Callback = function(Value)
        getgenv().DYHUB.Legit.HitPart = Value
    end,
})
AimlockBox:AddToggle('SmoothingEnabled', {
    Text = 'Smoothing',
    Default = false,
    Callback = function(Value)
        getgenv().DYHUB.Legit.Smoothing = Value
    end,
})
AimlockBox:AddSlider('SmoothingAmount', {
    Text = 'Smoothing Amount',
    Default = 0.1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        getgenv().DYHUB.Legit.SmoothingAmount = Value
    end,
})
AimlockBox:AddSlider('Prediction', {
    Text = 'Prediction',
    Default = 0.05,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        getgenv().DYHUB.Legit.Prediction = Value
    end,
})
AimlockBox:AddSlider('JumpOffset', {
    Text = 'Jump Offset',
    Default = 0,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        getgenv().DYHUB.Legit.JumpOffset = Value
    end,
})
AimlockBox:AddToggle('ResolverToggle', {
    Text = 'Resolver',
    Default = false,
    Callback = function(Value)
        getgenv().DYHUB.Legit.Resolver = Value
    end,
})

local VelocityData = {}

Players.PlayerRemoving:Connect(function(plr)
    VelocityData[plr] = nil
end)
NewConnection(RunService.Heartbeat, function(dt)
    if dt > 0.5 then
        return
    end

    local targetName = DYHUBcc.TargetAim.Target

    if targetName == 'None' or not targetName then
        return
    end

    local targetPlr = Players:FindFirstChild(targetName)

    if not targetPlr or targetPlr == LocalPlayer or not targetPlr.Character then
        return
    end

    local hrp = targetPlr.Character:FindFirstChild('HumanoidRootPart')

    if not hrp then
        return
    end

    local resolverEnabled = getgenv().DYHUB and getgenv().DYHUB.Legit and getgenv().DYHUB.Legit.Resolver or false

    if not resolverEnabled then
        if VelocityData[targetPlr] then
            VelocityData[targetPlr].Velocity = Vector3.zero
        end

        return
    end
    if not VelocityData[targetPlr] then
        VelocityData[targetPlr] = {
            PreviousPosition = hrp.Position,
            Velocity = Vector3.zero,
        }
    end

    local data = VelocityData[targetPlr]
    local displacement = hrp.Position - data.PreviousPosition

    data.Velocity = displacement / dt
    data.PreviousPosition = hrp.Position
end)

local function updateCamlock()
    if not getgenv().DYHUB.Legit.Aimlock then
        return
    end

    local targetName = DYHUBcc.TargetAim.Target

    if targetName == 'None' then
        return
    end

    local target = Players:FindFirstChild(targetName)

    if not target or not target.Character then
        return
    end

    local part = target.Character:FindFirstChild(getgenv().DYHUB.Legit.HitPart)

    if not part or not isAlive(target) or not isPlayerVisible(target) then
        return
    end

    local velocity = part.AssemblyLinearVelocity

    if getgenv().DYHUB.Legit.Resolver and VelocityData[target] then
        velocity = VelocityData[target].Velocity or velocity
    end

    local prediction = getgenv().DYHUB.Legit.Prediction or 0
    local predictedPos = part.Position + (velocity * prediction)

    if getgenv().DYHUB.Legit.JumpOffsetEnabled and target.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        predictedPos = predictedPos + Vector3.new(0, getgenv().DYHUB.Legit.JumpOffset or 0, 0)
    end

    local goal = CFrame.new(Camera.CFrame.Position, predictedPos)

    if getgenv().DYHUB.Legit.SmoothingEnabled then
        local smoothAmount = getgenv().DYHUB.Legit.SmoothingAmount or 0.2

        Camera.CFrame = Camera.CFrame:Lerp(goal, smoothAmount)
    else
        Camera.CFrame = goal
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().DYHUB.Legit.Aimlock then
        updateCamlock()
    end
end)
local mtSupport = pcall(function()
    local mt = getrawmetatable(game)

    setreadonly(mt, false)

    local old = mt.__index

    mt.__index = old

    setreadonly(mt, true)
end)

if not mtSupport then
    SilentBox:AddLabel("Your executor doesn't support Silent Aim")
end
if mtSupport then
    local mouse = localPlayer:GetMouse()
    local camera = Workspace.CurrentCamera
    local silentAimEnabled = false
    local silentTarget = nil
    local silentFOVEnabled = false
    local silentFOVSize = 150
    local silentFOVColor = Color3.fromRGB(255, 255, 255)
    local silentOutlineColor = Color3.fromRGB(0, 0, 0)
    local silentFillColor = Color3.fromRGB(255, 255, 255)
    local silentFillEnabled = false
    local silentFillTransparency = 0.5
    local silentPrediction = 0
    local silentAutoPred = false
    local silentCheckWall = false
    local silentCheckAlive = true
    local silentOffset = 0
    local silentJumpOffset = 0
    local useAirPart = false
    local silentAirPart = 'Head'
    local silentHitPart = 'Head'
    local FOVCircle = Drawing.new('Circle')

    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 100
    FOVCircle.Filled = false
    FOVCircle.ZIndex = 1
    FOVCircle.Visible = false

    local FOVOutline = Drawing.new('Circle')

    FOVOutline.Thickness = 2
    FOVOutline.NumSides = 100
    FOVOutline.Filled = false
    FOVOutline.ZIndex = 1
    FOVOutline.Visible = false

    local FOVFill = Drawing.new('Circle')

    FOVFill.Thickness = 1
    FOVFill.NumSides = 100
    FOVFill.Filled = true
    FOVFill.ZIndex = 0
    FOVFill.Visible = false

    local function getAimPos()
        if UserInputService.TouchEnabled then
            return Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        end

        return UserInputService:GetMouseLocation()
    end


    local function getClosestTarget()
        local closest, dist = nil, math.huge
        local aimPos = getAimPos()

        for _, plr in ipairs(Players:GetPlayers())do
            if plr ~= localPlayer and plr.Character then
                if silentCheckAlive and not isAlive(plr) then
                    continue
                end

                local char = plr.Character
                local part = char:FindFirstChild(silentHitPart)

                if not part then
                    continue
                end

                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)

                if not onScreen then
                    continue
                end

                local mag = (Vector2.new(screenPos.X, screenPos.Y) - aimPos).Magnitude

                if mag > silentFOVSize then
                    continue
                end
                if mag < dist then
                    dist = mag
                    closest = plr
                end
            end
        end

        return closest
    end

    local mt = getrawmetatable(game)

    setreadonly(mt, false)

    local oldIndex = mt.__index

    mt.__index = newcclosure(function(self, idx)
        if silentAimEnabled and self == mouse and (idx == 'Hit' or idx == 'Target') then
            local target = silentTarget

            if not target or not target.Character then
                return oldIndex(self, idx)
            end

            local char = target.Character
            local root = char:FindFirstChild('HumanoidRootPart')
            local partName = useAirPart and silentAirPart or silentHitPart
            local part = char:FindFirstChild(partName)

            if not root or not part then
                return oldIndex(self, idx)
            end

            local pos = part.Position
            local pred = pos + root.Velocity * silentPrediction

            pred += Vector3.new(0, silentOffset + silentJumpOffset, 0)

            if idx == 'Hit' then
                return CFrame.new(pos, pred)
            elseif idx == 'Target' then
                return part
            end
        end

        return oldIndex(self, idx)
    end)

    setreadonly(mt, true)
    RunService.RenderStepped:Connect(function()
        local aimPos = getAimPos()

        if silentFOVEnabled then
            FOVCircle.Visible = true
            FOVOutline.Visible = true
            FOVFill.Visible = silentFillEnabled
            FOVCircle.Position = aimPos
            FOVOutline.Position = aimPos
            FOVFill.Position = aimPos
            FOVCircle.Radius = silentFOVSize
            FOVOutline.Radius = silentFOVSize + 1
            FOVFill.Radius = silentFOVSize
            FOVCircle.Color = silentFOVColor
            FOVOutline.Color = silentOutlineColor
            FOVFill.Color = silentFillColor
            FOVFill.Transparency = silentFillTransparency
        else
            FOVCircle.Visible = false
            FOVOutline.Visible = false
            FOVFill.Visible = false
        end
        if not silentAimEnabled then
            silentTarget = nil
            FOVCircle.Visible = false
            FOVOutline.Visible = false
            FOVFill.Visible = false
            return
        end

        local newTarget = getClosestTarget()

        silentTarget = newTarget
    end)
    SilentBox:AddToggle('SilentAimToggle', {
        Text = 'Silent Aim',
        Default = false,
        Callback = function(v)
            silentAimEnabled = v

            if not v then
                silentTarget = nil
            end
        end,
    })
    SilentBox:AddToggle('SilentFOVToggle', {
        Text = 'Show FOV',
        Default = false,
        Callback = function(v)
            silentFOVEnabled = v
        end,
    }):AddColorPicker('SilentFOVColor', {
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(c)
            silentFOVColor = c
        end,
    }):AddColorPicker('SilentOutlineColor', {
        Default = Color3.fromRGB(0, 0, 0),
        Callback = function(c)
            silentOutlineColor = c
        end,
    })
    SilentBox:AddSlider('SilentFOVSize', {
        Text = 'FOV Size',
        Default = 150,
        Min = 50,
        Max = 800,
        Callback = function(v)
            silentFOVSize = v
        end,
    })
    SilentBox:AddToggle('FillFOVToggle', {
        Text = 'Fill FOV',
        Default = false,
        Callback = function(v)
            silentFillEnabled = v
        end,
    }):AddColorPicker('FillFOVColor', {
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(c)
            silentFillColor = c
        end,
    })
    SilentBox:AddSlider('FillFOVTransparency', {
        Text = 'Fill Transparency',
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(v)
            silentFillTransparency = v
        end,
    })
    SilentBox:AddInput('SilentPredictionInput', {
        Text = 'Prediction',
        Default = '0',
        Numeric = true,
        Finished = true,
        Callback = function(v)
            silentPrediction = tonumber(v) or 0
        end,
    })
    SilentBox:AddToggle('SilentAutoPred', {
        Text = 'Auto Prediction',
        Default = false,
        Callback = function(v)
            silentAutoPred = v
        end,
    })
    --[[SilentBox:AddToggle('SilentCheckWall', {
        Text = 'Check Wall',
        Default = false,
        Callback = function(v)
            silentCheckWall = v
        end,
    })]]
    SilentBox:AddToggle('SilentCheckAlive', {
        Text = 'Check Alive',
        Default = true,
        Callback = function(v)
            silentCheckAlive = v
        end,
    })
    SilentBox:AddInput('SilentOffset', {
        Text = 'Offset',
        Default = '0',
        Numeric = true,
        Finished = true,
        Callback = function(v)
            silentOffset = tonumber(v) or 0
        end,
    })
    SilentBox:AddInput('SilentJumpOffset', {
        Text = 'Jump Offset',
        Default = '0',
        Numeric = true,
        Finished = true,
        Callback = function(v)
            silentJumpOffset = tonumber(v) or 0
        end,
    })
    SilentBox:AddToggle('UseAirPart', {
        Text = 'Use Air Part',
        Default = false,
        Callback = function(v)
            useAirPart = v
        end,
    })
    SilentBox:AddDropdown('SilentAirPart', {
        Text = 'Air Part',
        Values = {
            'Head',
            'HumanoidRootPart',
            'UpperTorso',
            'LowerTorso',
        },
        Default = 'Head',
        Callback = function(v)
            silentAirPart = v
        end,
    })
end
end)()
local groupbox = Tabs.Extra:AddLeftGroupbox('Anti-FakePos')

local hasFakepos = false
groupbox:AddButton({
	Text = 'Anti fake pos',
	Func = function()
		if hasFakepos then
			return
		end

		hasFakepos = true

		loadstring(game:HttpGet('https://pastefy.app/SCPhMMAi/raw'))()
	end,
})
local ChatTask
local chatbox = Tabs.Extra:AddRightGroupbox('Misc')
chatbox:AddToggle('DisableChat', {
    Text = 'Disable Chat',
    Default = false,
    Callback = function(v)
        if v then
            ChatTask = task.spawn(function()
                while Toggles.DisableChat.Value do
                    task.wait(0.5)
                    pcall(function()
                        local tcs = game:GetService("TextChatService")
                        tcs.ChatInputBarConfiguration.Enabled = false
                    end)
                    pcall(function()
                        local chat = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Chat")
                        if chat then chat:Destroy() end
                    end)
                end
            end)
        else
			pcall(function()
				local tcs = game:GetService("TextChatService")
				tcs.ChatInputBarConfiguration.Enabled = true
			end)
            if ChatTask then
                task.cancel(ChatTask)
                ChatTask = nil
            end
        end
    end
})
local hasLoadedPacks = false

chatbox:AddButton({
	Text = 'Load Animation Packs',
	Func = function()
		if hasLoadedPacks then
			return
		end

		hasLoadedPacks = true

		loadstring(game:HttpGet('https://raw.githubusercontent.com/alebinh60/asmobile/refs/heads/main/animationspacks'))()
	end,
})
local ChinaHatGroup = Tabs.Visual:AddRightGroupbox('VietNam Hat')

getgenv().ChinaHatSettings = {
    enabled = false,
    hatColor = Color3.fromRGB(255, 255, 255),
    lightColor = Color3.fromRGB(255, 255, 255),
    lightBrightness = 0,
    lightRange = 12,
    scale = Vector3.new(1.7, 1.1, 1.7),
}

local function CreateHat(Character)
    local Head = Character:FindFirstChild('Head')

    if not Head then
        return
    end

    local Cone = Instance.new('Part')

    Cone.Name = 'ChinaHat'
    Cone.Size = Vector3.new(1, 1, 1)
    Cone.BrickColor = BrickColor.new('Hot pink')
    Cone.Material = Enum.Material.Neon
    Cone.Transparency = 0.2
    Cone.Anchored = false
    Cone.CanCollide = false
    Cone.Color = getgenv().ChinaHatSettings.hatColor

    local Mesh = Instance.new('SpecialMesh')

    Mesh.MeshType = Enum.MeshType.FileMesh
    Mesh.MeshId = 'rbxassetid://1033714'
    Mesh.Scale = getgenv().ChinaHatSettings.scale
    Mesh.Parent = Cone

    local Weld = Instance.new('Weld')

    Weld.Part0 = Head
    Weld.Part1 = Cone
    Weld.C0 = CFrame.new(0, 0.9, 0)
    Weld.Parent = Cone

    local Light = Instance.new('PointLight')

    Light.Color = getgenv().ChinaHatSettings.lightColor
    Light.Brightness = getgenv().ChinaHatSettings.lightBrightness
    Light.Range = getgenv().ChinaHatSettings.lightRange
    Light.Shadows = true
    Light.Parent = Cone
    Cone.Parent = Character
end
local function OnCharacterAdded1(Character)
    if getgenv().ChinaHatSettings.enabled then
        CreateHat(Character)
    end
end

localPlayer.CharacterAdded:Connect(OnCharacterAdded1)

if localPlayer.Character then
    task.wait(3)
    OnCharacterAdded1(localPlayer.Character)
end

ChinaHatGroup:AddToggle('ChinaHatEnabled', {
    Text = 'VietNam Hat',
    Default = getgenv().ChinaHatSettings.enabled,
    Callback = function(state)
        getgenv().ChinaHatSettings.enabled = state

        if state then
            if localPlayer.Character then
                OnCharacterAdded1(localPlayer.Character)
            end
        else
            if localPlayer.Character then
                local hat = localPlayer.Character:FindFirstChild('ChinaHat')

                if hat then
                    hat:Destroy()
                end
            end
        end
    end,
}):AddColorPicker('ChinaHatColor', {
    Default = getgenv().ChinaHatSettings.hatColor,
    Title = 'Hat Color',
    Callback = function(color)
        getgenv().ChinaHatSettings.hatColor = color

        if getgenv().ChinaHatSettings.enabled and localPlayer.Character then
            local hat = localPlayer.Character:FindFirstChild('ChinaHat')

            if hat then
                hat:Destroy()
            end

            CreateHat(localPlayer.Character)
        end
    end,
}):AddColorPicker('ChinaLightColor', {
    Default = getgenv().ChinaHatSettings.lightColor,
    Title = 'Light Color',
    Callback = function(color)
        getgenv().ChinaHatSettings.lightColor = color

        if getgenv().ChinaHatSettings.enabled and localPlayer.Character then
            local hat = localPlayer.Character:FindFirstChild('ChinaHat')

            if hat then
                hat:Destroy()
            end

            CreateHat(localPlayer.Character)
        end
    end,
})
ChinaHatGroup:AddSlider('ChinaLightBrightness', {
    Text = 'Light Brightness',
    Min = 0,
    Max = 10,
    Default = getgenv().ChinaHatSettings.lightBrightness,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        getgenv().ChinaHatSettings.lightBrightness = value

        if getgenv().ChinaHatSettings.enabled and localPlayer.Character then
            local hat = localPlayer.Character:FindFirstChild('ChinaHat')

            if hat then
                hat:Destroy()
            end

            CreateHat(localPlayer.Character)
        end
    end,
})
ChinaHatGroup:AddSlider('ChinaLightRange', {
    Text = 'Light Range',
    Min = 0,
    Max = 50,
    Default = getgenv().ChinaHatSettings.lightRange,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        getgenv().ChinaHatSettings.lightRange = value

        if getgenv().ChinaHatSettings.enabled and localPlayer.Character then
            local hat = localPlayer.Character:FindFirstChild('ChinaHat')

            if hat then
                hat:Destroy()
            end

            CreateHat(localPlayer.Character)
        end
    end,
})
local DYHUBEsp = loadstring(game:HttpGet('https://raw.githubusercontent.com/alebinh60/asmobile/refs/heads/main/esplib'))()
local esp = DYHUBEsp
local ESPGroup = Tabs.Visual:AddLeftGroupbox('ESP')

if isDaHood then
    local CashEspGroup = Tabs.Visual:AddLeftGroupbox('Cash Esp')
    local originalSizes = originalSizes or {}

    CashEspGroup:AddToggle('CashEsp', {
        Text = 'Cash Esp',
        Default = false,
        Callback = function(state)
            for _, drop in pairs(workspace.Ignored.Drop:GetChildren())do
                if drop.Name == 'MoneyDrop' and drop:FindFirstChild('BillboardGui') then
                    local gui = drop.BillboardGui

                    if state then
                        if not originalSizes[drop] then
                            originalSizes[drop] = gui.Size
                        end

                        gui.AlwaysOnTop = true
                        gui.Size = UDim2.new(0, 45, 0, 45)
                    else
                        if originalSizes[drop] then
                            gui.Size = originalSizes[drop]
                        end

                        gui.AlwaysOnTop = false
                    end
                end
            end
        end,
    })
    workspace.Ignored.Drop.ChildAdded:Connect(function(child)
        if child.Name == 'MoneyDrop' and child:FindFirstChild('BillboardGui') and Toggles.CashEsp.Value then
            local gui = child.BillboardGui

            if not originalSizes[child] then
                originalSizes[child] = gui.Size
            end

            gui.AlwaysOnTop = true
            gui.Size = UDim2.new(0, 45, 0, 45)
        end
    end)
end

ESPGroup:AddToggle('BoxESPToggle', {
    Text = 'Box ESP',
    Default = false,
    Callback = function(Value)
        esp.State.BoxEnabled = Value
    end,
}):AddColorPicker('BoxColorPicker', {
    Default = Color3.new(0.403922, 0.34902, 0.701961),
    Title = 'Box Color',
    Callback = function(Value)
        esp.Config.BoxColor = Value

        for _, espObj in pairs(esp.Caches.BoxCache)do
            espObj.Box.Color = Value
        end
    end,
})
ESPGroup:AddToggle('BoxGradientToggle', {
    Text = 'Box Gradient',
    Default = false,
    Callback = function(Value)
        esp.Config.BoxGradientEnabled = Value
    end,
}):AddColorPicker('BoxGradientColor1', {
    Default = Color3.new(0.403922, 0.34902, 0.701961),
    Title = 'Gradient Color 1',
    Callback = function(Value)
        esp.Config.BoxGradientColor1 = Value

        for _, espObj in pairs(esp.Caches.BoxCache)do
            espObj.Gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, esp.Config.BoxGradientColor1),
                ColorSequenceKeypoint.new(0.5, esp.Config.BoxGradientColor2),
                ColorSequenceKeypoint.new(1, esp.Config.BoxGradientColor1),
            })
        end
    end,
}):AddColorPicker('BoxGradientColor2', {
    Default = Color3.new(0.8, 0.4, 1),
    Title = 'Gradient Color 2',
    Callback = function(Value)
        esp.Config.BoxGradientColor2 = Value

        for _, espObj in pairs(esp.Caches.BoxCache)do
            espObj.Gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, esp.Config.BoxGradientColor1),
                ColorSequenceKeypoint.new(0.5, esp.Config.BoxGradientColor2),
                ColorSequenceKeypoint.new(1, esp.Config.BoxGradientColor1),
            })
        end
    end,
})
ESPGroup:AddSlider('BoxFillTransparencySlider', {
    Text = 'Box Fill Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(Value)
        esp.Config.BoxFillTransparency = Value

        for _, espObj in pairs(esp.Caches.BoxCache)do
            espObj.FillFrame.BackgroundTransparency = Value
        end
    end,
})
ESPGroup:AddToggle('BoxOutlineToggle', {
    Text = 'Box Outline',
    Default = true,
    Callback = function(Value)
        esp.Config.BoxOutlineEnabled = Value

        for _, espObj in pairs(esp.Caches.BoxCache)do
            espObj.Stroke.Enabled = Value
            espObj.BoxOutline.Visible = Value and not esp.Config.BoxGradientEnabled
        end
    end,
}):AddColorPicker('BoxOutlineColor', {
    Default = Color3.new(0, 0, 0),
    Title = 'Outline Color',
    Callback = function(Value)
        esp.Config.BoxOutlineColor = Value

        for _, espObj in pairs(esp.Caches.BoxCache)do
            espObj.Stroke.Color = Value
            espObj.BoxOutline.Color = Value
        end
    end,
})
ESPGroup:AddToggle('RingESPToggle', {
    Text = 'Ring ESP',
    Default = false,
    Callback = function(Value)
        if Value then
            esp:InitiateRing(Color3.new(1, 1, 1))
        else
            esp.State.RingEnabled = false
        end
    end,
}):AddColorPicker('RingColorPicker', {
    Default = Color3.new(1, 1, 1),
    Title = 'Ring Color',
    Callback = function(Value)
        esp.Config.RingColor = Value

        for _, data in pairs(esp.Caches.RingCache)do
            data.Ring.Color3 = Value
        end
    end,
})
ESPGroup:AddToggle('NameESPToggle', {
    Text = 'Name ESP',
    Default = false,
    Callback = function(Value)
        esp:InitiateName(Value)
    end,
})
ESPGroup:AddToggle('DistanceESPToggle', {
    Text = 'Distance ESP',
    Default = false,
    Callback = function(Value)
        esp:InitiateDistance(Value)
    end,
})
ESPGroup:AddToggle('SkeletonESPToggle', {
    Text = 'Skeleton ESP',
    Default = false,
    Callback = function(Value)
        if Value then
            esp:InitiateSkeleton(Color3.new(0.403922, 0.34902, 0.701961))
        else
            esp.State.SkeletonEnabled = false
        end
    end,
}):AddColorPicker('SkeletonColorPicker', {
    Default = Color3.new(0.403922, 0.34902, 0.701961),
    Title = 'Skeleton Color',
    Callback = function(Value)
        esp.Config.SkeletonColor = Value

        for _, skeleton in pairs(esp.Caches.SkeletonCache)do
            for _, line in pairs(skeleton)do
                line.Color = Value
            end
        end
    end,
})
ESPGroup:AddToggle('HealthBarESPToggle', {
    Text = 'Health Bar',
    Default = false,
    Callback = function(Value)
        esp.State.HealthBarEnabled = Value
    end,
})
ESPGroup:AddToggle('HealthTextESPToggle', {
    Text = 'Health Text',
    Default = false,
    Callback = function(Value)
        esp.State.HealthTextEnabled = Value
    end,
})
ESPGroup:AddSlider('HealthBarLerpSpeed', {
    Text = 'Health Bar Smoothness',
    Default = 0.15,
    Min = 0.05,
    Max = 0.5,
    Rounding = 2,
    Compact = true,
    Callback = function(Value)
        esp.Config.HealthBarLerpSpeed = Value
    end,
})
ESPGroup:AddToggle('TracerESPToggle', {
    Text = 'Tracer ESP',
    Default = false,
    Callback = function(Value)
        if Value then
            esp:InitiateTracer(Color3.new(0.403922, 0.34902, 0.701961), esp.Config.TracerOrigin)
        else
            esp.State.TracerEnabled = false
        end
    end,
}):AddColorPicker('TracerColorPicker', {
    Default = Color3.new(0.403922, 0.34902, 0.701961),
    Title = 'Tracer Color',
    Callback = function(Value)
        esp.Config.TracerColor = Value

        for _, tracer in pairs(esp.Caches.TracerCache)do
            tracer.Color = Value
        end
    end,
})
ESPGroup:AddDropdown('TracerOriginDropdown', {
    Text = 'Tracer Origin',
    Default = 'Bottom Screen',
    Values = {
        'Bottom Screen',
        'Cursor',
        'Top Screen',
    },
    Compact = true,
    Callback = function(Value)
        esp.Config.TracerOrigin = Value
    end,
})
ESPGroup:AddToggle('ChamsToggle', {
    Text = 'Chams',
    Default = false,
    Callback = function(Value)
        if Value then
            esp:InitiateChams(Color3.new(0.403922, 0.34902, 0.701961))
        else
            esp.State.ChamsEnabled = false
        end
    end,
}):AddColorPicker('ChamsColorPicker', {
    Default = Color3.new(0.403922, 0.34902, 0.701961),
    Title = 'Fill Color',
    Callback = function(Value)
        esp.Config.ChamsColor = Value

        for _, chams in pairs(esp.Caches.ChamsCache)do
            chams.FillColor = Value
        end
    end,
}):AddColorPicker('ChamsOutlineColorPicker', {
    Default = Color3.new(1, 1, 1),
    Title = 'Outline Color',
    Callback = function(Value)
        esp.Config.ChamsOutlineColor = Value

        for _, chams in pairs(esp.Caches.ChamsCache)do
            chams.OutlineColor = Value
        end
    end,
})
ESPGroup:AddSlider('ChamFillTransparency', {
    Text = 'Chams Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(Value)
        esp.Config.ChamsFillTransparency = Value

        for _, chams in pairs(esp.Caches.ChamsCache)do
            chams.FillTransparency = Value
        end
    end,
})
ESPGroup:AddToggle('TeamCheckToggle', {
    Text = 'Team Check',
    Default = true,
    Callback = function(Value)
        esp:TeamCheck(Value)
    end,
})
ESPGroup:AddSlider('ESPDistanceSlider', {
    Text = 'ESP Distance',
    Default = 1000,
    Min = 100,
    Max = 1000,
    Rounding = 0,
    Suffix = ' studs',
    Compact = true,
    Callback = function(Value)
        esp:SetDistance(Value)
    end,
})
esp:Initialize()
task.wait(1)
coroutine.wrap(function()
    local AuraColor = Color3.new(1, 1, 1)
    local AuraColors = {
        Safe = Color3.fromRGB(255, 255, 255),
    }

    local function AttachAuraSafe(character)
        local torso = character:FindFirstChild('UpperTorso') or character:FindFirstChild('Torso')

        if not torso then
            return
        end

        for _, child in ipairs(torso:GetChildren())do
            if child.Name == 'AuraSafe' then
                child:Destroy()
            end
        end

        local container = Instance.new('Folder')

        container.Name = 'AuraSafe'
        container.Parent = torso

        local pointLight = Instance.new('PointLight')

        pointLight.Range = 5
        pointLight.Brightness = 3
        pointLight.Color = AuraColors.Safe
        pointLight.Enabled = true
        pointLight.Shadows = false
        pointLight.Parent = container

        local glowAttach = Instance.new('Attachment')

        glowAttach.Name = 'Glow'
        glowAttach.CFrame = CFrame.new(0, 0, 0)
        glowAttach.Parent = container

        local particleGlow = Instance.new('ParticleEmitter')

        particleGlow.Acceleration = Vector3.new(0, 0, 0)
        particleGlow.Brightness = 1
        particleGlow.Color = ColorSequence.new(AuraColors.Safe)
        particleGlow.Drag = 0
        particleGlow.EmissionDirection = Enum.NormalId.Back
        particleGlow.Enabled = true
        particleGlow.FlipbookFramerate = NumberRange.new(1, 1)
        particleGlow.FlipbookLayout = Enum.ParticleFlipbookLayout.None
        particleGlow.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
        particleGlow.Lifetime = NumberRange.new(1, 1)
        particleGlow.LightEmission = 1
        particleGlow.LightInfluence = 1
        particleGlow.LockedToPart = true
        particleGlow.Orientation = Enum.ParticleOrientation.FacingCamera
        particleGlow.Rate = 4
        particleGlow.RotSpeed = NumberRange.new(0, 0)
        particleGlow.Rotation = NumberRange.new(0, 0)
        particleGlow.Shape = Enum.ParticleEmitterShape.Box
        particleGlow.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
        particleGlow.ShapePartial = 1
        particleGlow.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
        particleGlow.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 4.25),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 3.375),
        })
        particleGlow.Speed = NumberRange.new(0.001, 0.001)
        particleGlow.SpreadAngle = Vector2.new(0, 0)
        particleGlow.Squash = NumberSequence.new(0, 0)
        particleGlow.Texture = 'rbxassetid://1075864321'
        particleGlow.TimeScale = 1
        particleGlow.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        particleGlow.VelocityInheritance = 0
        particleGlow.WindAffectsDrag = false
        particleGlow.ZOffset = -1
        particleGlow.Parent = glowAttach

        local attach2Upper = Instance.new('Attachment')

        attach2Upper.Name = '2'
        attach2Upper.CFrame = CFrame.new(0, 2.125, 0)
        attach2Upper.Parent = container

        local attach2Lower = Instance.new('Attachment')

        attach2Lower.Name = '2'
        attach2Lower.CFrame = CFrame.new(0, -3, 0)
        attach2Lower.Parent = container

        local beamSafe1 = Instance.new('Beam')

        beamSafe1.Attachment0 = attach2Lower
        beamSafe1.Attachment1 = attach2Upper
        beamSafe1.Brightness = 1
        beamSafe1.Color = ColorSequence.new(AuraColors.Safe)
        beamSafe1.CurveSize0 = 0
        beamSafe1.CurveSize1 = 0
        beamSafe1.Enabled = true
        beamSafe1.FaceCamera = true
        beamSafe1.LightEmission = 1
        beamSafe1.LightInfluence = 1
        beamSafe1.Segments = 10
        beamSafe1.Texture = 'rbxassetid://7673945506'
        beamSafe1.TextureLength = 0.3
        beamSafe1.TextureMode = Enum.TextureMode.Stretch
        beamSafe1.TextureSpeed = 2
        beamSafe1.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        beamSafe1.Width0 = 6
        beamSafe1.Width1 = 6
        beamSafe1.ZOffset = 1
        beamSafe1.Parent = container

        local beamSafe2 = Instance.new('Beam')

        beamSafe2.Attachment0 = attach2Lower
        beamSafe2.Attachment1 = attach2Upper
        beamSafe2.Brightness = 1
        beamSafe2.Color = ColorSequence.new(AuraColors.Safe)
        beamSafe2.CurveSize0 = 0
        beamSafe2.CurveSize1 = 0
        beamSafe2.Enabled = true
        beamSafe2.FaceCamera = true
        beamSafe2.LightEmission = 1
        beamSafe2.LightInfluence = 1
        beamSafe2.Segments = 10
        beamSafe2.Texture = 'http://www.roblox.com/asset/?id=6045867277'
        beamSafe2.TextureLength = 0.1
        beamSafe2.TextureMode = Enum.TextureMode.Stretch
        beamSafe2.TextureSpeed = 1
        beamSafe2.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        beamSafe2.Width0 = 5
        beamSafe2.Width1 = 5
        beamSafe2.ZOffset = 1
        beamSafe2.Parent = container

        local beamSafe3 = Instance.new('Beam')

        beamSafe3.Attachment0 = attach2Lower
        beamSafe3.Attachment1 = attach2Upper
        beamSafe3.Brightness = 1
        beamSafe3.Color = ColorSequence.new(AuraColors.Safe)
        beamSafe3.CurveSize0 = 0
        beamSafe3.CurveSize1 = 0
        beamSafe3.Enabled = true
        beamSafe3.FaceCamera = true
        beamSafe3.LightEmission = 1
        beamSafe3.LightInfluence = 1
        beamSafe3.Segments = 10
        beamSafe3.Texture = 'rbxassetid://1849531275'
        beamSafe3.TextureLength = 0.1
        beamSafe3.TextureMode = Enum.TextureMode.Stretch
        beamSafe3.TextureSpeed = 1
        beamSafe3.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        beamSafe3.Width0 = 6
        beamSafe3.Width1 = 6
        beamSafe3.ZOffset = 1
        beamSafe3.Parent = container

        local topSymbolAttach = Instance.new('Attachment')

        topSymbolAttach.Name = '1TopSymbol'
        topSymbolAttach.CFrame = CFrame.new(0, 5.75001049, 1) * CFrame.fromMatrix(Vector3.zero, Vector3.new(0, 0, -1), Vector3.new(-1, 0, 0), Vector3.new(0, 1, 0))
        topSymbolAttach.Parent = container

        local bottomSymbolAttach = Instance.new('Attachment')

        bottomSymbolAttach.Name = '1BottomSymbol'
        bottomSymbolAttach.CFrame = CFrame.new(0, -1.24998808, 1) * CFrame.fromMatrix(Vector3.zero, Vector3.new(0, 0, -1), Vector3.new(-1, 0, 0), Vector3.new(0, 1, 0))
        bottomSymbolAttach.Parent = container

        local beamSymbol = Instance.new('Beam')

        beamSymbol.Attachment0 = topSymbolAttach
        beamSymbol.Attachment1 = bottomSymbolAttach
        beamSymbol.Brightness = 1
        beamSymbol.Color = ColorSequence.new(AuraColors.Safe)
        beamSymbol.CurveSize0 = 0.5
        beamSymbol.CurveSize1 = 0.5
        beamSymbol.Enabled = true
        beamSymbol.FaceCamera = false
        beamSymbol.LightEmission = 1
        beamSymbol.LightInfluence = 1
        beamSymbol.Segments = 100
        beamSymbol.Texture = 'rbxassetid://8285797183'
        beamSymbol.TextureLength = 1
        beamSymbol.TextureMode = Enum.TextureMode.Stretch
        beamSymbol.TextureSpeed = 0
        beamSymbol.Transparency = NumberSequence.new(0, 0)
        beamSymbol.Width0 = 7
        beamSymbol.Width1 = 7
        beamSymbol.ZOffset = 0
        beamSymbol.Parent = container
    end

    local ToggledAuras = {}

    local function SetupAura(character, auraName)
        if not character then
            return
        end

        local AuraColor = AuraColors[auraName]

        if auraName == 'Safe' then
            AttachAuraSafe(character)
        end
    end

    local Players = game:GetService('Players')
    local LocalPlayer = Players.LocalPlayer
    local awEnabled = false
    local awInstances = {}
    local awHrp = nil
    local awColor = Color3.new(1, 1, 1)
    local bhEnabled = false
    local bhInstances = {}
    local bhColor = Color3.new(1, 1, 1)

    local function destroyAw()
        for _, inst in pairs(awInstances)do
            pcall(function()
                inst:Destroy()
            end)
        end

        awInstances = {}
    end
    local function createAw()
        local character = game.Players.LocalPlayer.Character

        if not character then
            return
        end

        awHrp = character:FindFirstChild('UpperTorso') or character:FindFirstChild('Torso')

        if not awHrp then
            return
        end

        destroyAw()

        local att1 = Instance.new('Attachment')

        att1.Name = 'AngelAttachment1'
        att1.CFrame = CFrame.new(0, 4.25, 0)
        att1.Parent = awHrp

        table.insert(awInstances, att1)

        local pe1 = Instance.new('ParticleEmitter')

        pe1.Name = 'AngelParticle1'
        pe1.Acceleration = Vector3.new(0, -6, 0)
        pe1.Brightness = 1
        pe1.Color = ColorSequence.new(awColor)
        pe1.Drag = 0
        pe1.EmissionDirection = Enum.NormalId.Bottom
        pe1.Enabled = true
        pe1.Lifetime = NumberRange.new(1, 2)
        pe1.LightEmission = 1
        pe1.LightInfluence = 1
        pe1.LockedToPart = true
        pe1.Orientation = Enum.ParticleOrientation.FacingCamera
        pe1.Rate = 50
        pe1.RotSpeed = NumberRange.new(-100, 100)
        pe1.Rotation = NumberRange.new(-360, 360)
        pe1.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5, 0.3),
            NumberSequenceKeypoint.new(1, 0.5, 0.3),
        })
        pe1.Speed = NumberRange.new(2.5, 2.5)
        pe1.SpreadAngle = Vector2.new(0, 360)
        pe1.Squash = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0),
        })
        pe1.Texture = 'rbxassetid://7511321694'
        pe1.TimeScale = 1
        pe1.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.1, 0),
            NumberSequenceKeypoint.new(0.3, 0),
            NumberSequenceKeypoint.new(0.8, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        pe1.VelocityInheritance = 0
        pe1.WindAffectsDrag = false
        pe1.ZOffset = 0
        pe1.Parent = att1

        table.insert(awInstances, pe1)

        local pe2 = Instance.new('ParticleEmitter')

        pe2.Name = 'AngelParticle2'
        pe2.Acceleration = Vector3.new(0, -6, 0)
        pe2.Brightness = 1
        pe2.Color = ColorSequence.new(awColor)
        pe2.Drag = 0
        pe2.EmissionDirection = Enum.NormalId.Bottom
        pe2.Enabled = true
        pe2.Lifetime = NumberRange.new(1, 2)
        pe2.LightEmission = 1
        pe2.LightInfluence = 1
        pe2.LockedToPart = true
        pe2.Orientation = Enum.ParticleOrientation.FacingCamera
        pe2.Rate = 100
        pe2.RotSpeed = NumberRange.new(-100, 100)
        pe2.Rotation = NumberRange.new(-360, 360)
        pe2.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5, 0.3),
            NumberSequenceKeypoint.new(1, 0.5, 0.3),
        })
        pe2.Speed = NumberRange.new(2.5, 2.5)
        pe2.SpreadAngle = Vector2.new(0, 360)
        pe2.Squash = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0),
        })
        pe2.Texture = 'rbxassetid://1084976679'
        pe2.TimeScale = 1
        pe2.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.2, 0),
            NumberSequenceKeypoint.new(0.8, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        pe2.VelocityInheritance = 0
        pe2.WindAffectsDrag = false
        pe2.ZOffset = 0
        pe2.Parent = att1

        table.insert(awInstances, pe2)

        local att2 = Instance.new('Attachment')

        att2.Name = 'AngelAttachment2'
        att2.CFrame = CFrame.new(0, 0.75, 0.5)
        att2.Parent = awHrp

        table.insert(awInstances, att2)

        local att3 = Instance.new('Attachment')

        att3.Name = 'AngelAttachment3'
        att3.CFrame = CFrame.new(-5.25, 0, 2) * CFrame.fromMatrix(Vector3.new(0, 0, 0), Vector3.new(0.866025388, 0, 0.5), Vector3.new(0, 1, 0), Vector3.new(-0.5, 0, 0.866025388))
        att3.Parent = awHrp

        table.insert(awInstances, att3)

        local att4 = Instance.new('Attachment')

        att4.Name = 'AngelAttachment4'
        att4.CFrame = CFrame.new(5.25, 0, 2) * CFrame.fromMatrix(Vector3.new(0, 0, 0), Vector3.new(0.866025388, 0, -0.5), Vector3.new(0, 1, 0), Vector3.new(0.5, 0, 0.866025388))
        att4.Parent = awHrp

        table.insert(awInstances, att4)

        local beam1 = Instance.new('Beam')

        beam1.Name = 'AngelBeam1'
        beam1.Attachment0 = att2
        beam1.Attachment1 = att3
        beam1.Brightness = 1
        beam1.Color = ColorSequence.new(awColor)
        beam1.CurveSize0 = 2
        beam1.CurveSize1 = 2
        beam1.Enabled = true
        beam1.FaceCamera = false
        beam1.LightEmission = 1
        beam1.LightInfluence = 1
        beam1.Segments = 10
        beam1.Texture = 'rbxassetid://9544400688'
        beam1.TextureLength = 1
        beam1.TextureMode = Enum.TextureMode.Stretch
        beam1.TextureSpeed = 0
        beam1.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0),
        })
        beam1.Width0 = 4
        beam1.Width1 = 6
        beam1.ZOffset = 0
        beam1.Parent = awHrp

        table.insert(awInstances, beam1)

        local beam2 = Instance.new('Beam')

        beam2.Name = 'AngelBeam2'
        beam2.Attachment0 = att2
        beam2.Attachment1 = att4
        beam2.Brightness = 1
        beam2.Color = ColorSequence.new(awColor)
        beam2.CurveSize0 = -2
        beam2.CurveSize1 = -2
        beam2.Enabled = true
        beam2.FaceCamera = false
        beam2.LightEmission = 1
        beam2.LightInfluence = 1
        beam2.Segments = 10
        beam2.Texture = 'rbxassetid://9544400688'
        beam2.TextureLength = 1
        beam2.TextureMode = Enum.TextureMode.Stretch
        beam2.TextureSpeed = 0
        beam2.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0),
        })
        beam2.Width0 = 4
        beam2.Width1 = 6
        beam2.ZOffset = 0
        beam2.Parent = awHrp

        table.insert(awInstances, beam2)

        local pl = Instance.new('PointLight')

        pl.Name = 'AngelPointLight'
        pl.Brightness = 4
        pl.Color = awColor
        pl.Enabled = true
        pl.Range = 5
        pl.Shadows = false
        pl.Parent = awHrp

        table.insert(awInstances, pl)
    end
    local function updateAwColor(newColor)
        awColor = newColor

        if awEnabled then
            for _, inst in pairs(awInstances)do
                if inst:IsA('ParticleEmitter') or inst:IsA('Beam') then
                    inst.Color = ColorSequence.new(awColor)
                elseif inst:IsA('PointLight') then
                    inst.Color = awColor
                end
            end
        end
    end
    local function destroyBh()
        for _, inst in pairs(bhInstances)do
            pcall(function()
                inst:Destroy()
            end)
        end

        bhInstances = {}
    end
    local function createBh()
        local character = game.Players.LocalPlayer.Character

        if not character then
            return
        end

        destroyBh()

        local parts = {}

        for _, part in pairs(character:GetChildren())do
            if part:IsA('BasePart') and part.Name ~= 'HumanoidRootPart' then
                table.insert(parts, part)
            end
        end
        for _, part in pairs(parts)do
            local atom1 = Instance.new('ParticleEmitter')

            atom1.Name = 'BhAtom1'
            atom1.Acceleration = Vector3.new(0, 1, 0)
            atom1.Brightness = 10
            atom1.Color = ColorSequence.new(bhColor)
            atom1.Drag = 50
            atom1.EmissionDirection = Enum.NormalId.Top
            atom1.Enabled = true
            atom1.Lifetime = NumberRange.new(0.4, 0.6)
            atom1.LightEmission = 1
            atom1.LightInfluence = 0
            atom1.LockedToPart = false
            atom1.Orientation = Enum.ParticleOrientation.FacingCamera
            atom1.Rate = 20
            atom1.RotSpeed = NumberRange.new(0, 0)
            atom1.Rotation = NumberRange.new(-360, 360)
            atom1.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.125),
                NumberSequenceKeypoint.new(1, 0),
            })
            atom1.Speed = NumberRange.new(30, 40)
            atom1.SpreadAngle = Vector2.new(90, 90)
            atom1.Squash = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 0),
            })
            atom1.Texture = 'rbxassetid://11448304274'
            atom1.TimeScale = 0.75
            atom1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.500529, 0),
                NumberSequenceKeypoint.new(1, 1),
            })
            atom1.VelocityInheritance = 0
            atom1.WindAffectsDrag = false
            atom1.ZOffset = -1
            atom1.Parent = part

            table.insert(bhInstances, atom1)

            local flame1 = Instance.new('ParticleEmitter')

            flame1.Name = 'BhFlame1'
            flame1.Acceleration = Vector3.new(0, 1, 0)
            flame1.Brightness = 10
            flame1.Color = ColorSequence.new(bhColor)
            flame1.Drag = 0
            flame1.EmissionDirection = Enum.NormalId.Top
            flame1.Enabled = true
            flame1.Lifetime = NumberRange.new(0.4, 0.6)
            flame1.LightEmission = 1
            flame1.LightInfluence = 0
            flame1.LockedToPart = false
            flame1.Orientation = Enum.ParticleOrientation.FacingCamera
            flame1.Rate = 150
            flame1.RotSpeed = NumberRange.new(0, 0)
            flame1.Rotation = NumberRange.new(-360, 360)
            flame1.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            })
            flame1.Speed = NumberRange.new(1, 2)
            flame1.SpreadAngle = Vector2.new(90, 90)
            flame1.Squash = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 0),
            })
            flame1.Texture = 'rbxassetid://10545078665'
            flame1.TimeScale = 0.75
            flame1.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.500529, 0),
                NumberSequenceKeypoint.new(1, 1),
            })
            flame1.VelocityInheritance = 0
            flame1.WindAffectsDrag = false
            flame1.ZOffset = -1
            flame1.Parent = part

            table.insert(bhInstances, flame1)

            local flame2 = Instance.new('ParticleEmitter')

            flame2.Name = 'BhFlame2'
            flame2.Acceleration = Vector3.new(0, 1, 0)
            flame2.Brightness = 10
            flame2.Color = ColorSequence.new(bhColor)
            flame2.Drag = 0
            flame2.EmissionDirection = Enum.NormalId.Top
            flame2.Enabled = true
            flame2.Lifetime = NumberRange.new(0.3, 0.4)
            flame2.LightEmission = 1
            flame2.LightInfluence = 0
            flame2.LockedToPart = false
            flame2.Orientation = Enum.ParticleOrientation.FacingCamera
            flame2.Rate = 150
            flame2.RotSpeed = NumberRange.new(0, 0)
            flame2.Rotation = NumberRange.new(-360, 360)
            flame2.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1.1875),
                NumberSequenceKeypoint.new(1, 0),
            })
            flame2.Speed = NumberRange.new(2, 3)
            flame2.SpreadAngle = Vector2.new(90, 90)
            flame2.Squash = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 0),
            })
            flame2.Texture = 'rbxassetid://10545078665'
            flame2.TimeScale = 0.75
            flame2.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.500529, 0),
                NumberSequenceKeypoint.new(1, 1),
            })
            flame2.VelocityInheritance = 0
            flame2.WindAffectsDrag = false
            flame2.ZOffset = -1.10000002
            flame2.Parent = part

            table.insert(bhInstances, flame2)

            local glow = Instance.new('ParticleEmitter')

            glow.Name = 'BhGlow'
            glow.Acceleration = Vector3.new(0, 1, 0)
            glow.Brightness = 10
            glow.Color = ColorSequence.new(bhColor)
            glow.Drag = 0
            glow.EmissionDirection = Enum.NormalId.Top
            glow.Enabled = true
            glow.FlipbookFramerate = NumberRange.new(30, 30)
            glow.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
            glow.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
            glow.Lifetime = NumberRange.new(0.4, 0.6)
            glow.LightEmission = 1
            glow.LightInfluence = 0
            glow.LockedToPart = true
            glow.Orientation = Enum.ParticleOrientation.FacingCamera
            glow.Rate = 200
            glow.RotSpeed = NumberRange.new(0, 0)
            glow.Rotation = NumberRange.new(-360, 360)
            glow.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.5),
                NumberSequenceKeypoint.new(1, 0.5),
            })
            glow.Speed = NumberRange.new(0.1, 0.1)
            glow.SpreadAngle = Vector2.new(360, 360)
            glow.Squash = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 0),
            })
            glow.Texture = 'rbxassetid://8451174579'
            glow.TimeScale = 0.75
            glow.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0.9125),
                NumberSequenceKeypoint.new(1, 1),
            })
            glow.VelocityInheritance = 0
            glow.WindAffectsDrag = false
            glow.ZOffset = 1
            glow.Parent = part

            table.insert(bhInstances, glow)

            local steam = Instance.new('ParticleEmitter')

            steam.Name = 'BhSteam'
            steam.Acceleration = Vector3.new(0, 1, 0)
            steam.Brightness = 10
            steam.Color = ColorSequence.new(bhColor)
            steam.Drag = 5
            steam.EmissionDirection = Enum.NormalId.Top
            steam.Enabled = true
            steam.Lifetime = NumberRange.new(0.4, 0.6)
            steam.LightEmission = 1
            steam.LightInfluence = 0
            steam.LockedToPart = false
            steam.Orientation = Enum.ParticleOrientation.FacingCamera
            steam.Rate = 100
            steam.RotSpeed = NumberRange.new(0, 0)
            steam.Rotation = NumberRange.new(-360, 360)
            steam.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 2.4375),
                NumberSequenceKeypoint.new(1, 0),
            })
            steam.Speed = NumberRange.new(8, 10)
            steam.SpreadAngle = Vector2.new(90, 90)
            steam.Squash = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 0),
            })
            steam.Texture = 'rbxassetid://11156590261'
            steam.TimeScale = 0.75
            steam.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.499471, 0.8875),
                NumberSequenceKeypoint.new(1, 1),
            })
            steam.VelocityInheritance = 0
            steam.WindAffectsDrag = false
            steam.ZOffset = -1
            steam.Parent = part

            table.insert(bhInstances, steam)
        end
    end
    local function updateBhColor(newColor)
        bhColor = newColor

        if bhEnabled then
            for _, inst in pairs(bhInstances)do
                if inst:IsA('ParticleEmitter') then
                    inst.Color = ColorSequence.new(bhColor)
                end
            end
        end
    end

    LocalPlayer.CharacterAdded:Connect(function(newChar)
        for auraName, toggled in pairs(ToggledAuras)do
            if toggled then
                task.wait(0.5)
                SetupAura(newChar, auraName)
            end
        end
    end)

    local AuraGroup = Tabs.Visual:AddLeftGroupbox('AuraGroup')

    AuraGroup:AddToggle('AngelWingsToggle', {
        Text = 'Angel Wings',
        Default = false,
        Callback = function(value)
            getgenv().awEnabled = value

            if value then
                createAw()
            else
                destroyAw()
            end
        end,
    }):AddColorPicker('AngelWingsColorPicker', {
        Default = Color3.new(1, 1, 1),
        Title = 'Angel Wings Color',
        Callback = function(color)
            updateAwColor(color)
        end,
    })
    AuraGroup:AddToggle('BlueheatAuraToggle', {
        Text = 'Bulon Heat Aura',
        Default = false,
        Callback = function(value)
            getgenv().bhEnabled = value

            if value then
                createBh()
            else
                destroyBh()
            end
        end,
    }):AddColorPicker('BlueheatColorPicker', {
        Default = Color3.new(1, 1, 1),
        Title = 'Blueheat Color',
        Callback = function(color)
            updateBhColor(color)
        end,
    })
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild('HumanoidRootPart', 5)

        if getgenv().awEnabled then
            createAw()
        end
        if getgenv().bhEnabled then
            createBh()
        end
    end)

    local initialChar = game.Players.LocalPlayer.Character

    if initialChar then
        initialChar:WaitForChild('HumanoidRootPart', 5)

        if getgenv().awEnabled then
            createAw()
        end
        if getgenv().bhEnabled then
            createBh()
        end
    end

    AuraGroup:AddToggle('SafeToggle', {
        Text = 'Safe',
        Default = false,
        Tooltip = 'Toggle Safe Aura',
        Callback = function(Value)
            ToggledAuras.Safe = Value

            if Value then
                SetupAura(LocalPlayer.Character, 'Safe')
            else
                local torso = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild('UpperTorso') or LocalPlayer.Character:FindFirstChild('Torso'))

                if torso then
                    local aura = torso:FindFirstChild('AuraSafe')

                    if aura then
                        aura:Destroy()
                    end
                end
            end
        end,
    }):AddColorPicker('SafeColor', {
        Default = AuraColors.Safe,
        Title = 'Aura Color',
        Callback = function(Value)
            AuraColors.Safe = Value

            if ToggledAuras.Safe then
                SetupAura(LocalPlayer.Character, 'Safe')
            end
        end,
    })

    if LocalPlayer.Character then
        for auraName in pairs(ToggledAuras)do
            SetupAura(LocalPlayer.Character, auraName)
        end
    end
end)()
task.wait(1)
coroutine.wrap(function()
    local SelfGroup = Tabs.Visual:AddRightGroupbox('Self')

    utility = utility or {}

    local Settings = {
        Visuals = {
            SelfESP = {
                Trail = {
                    Color = Color3.fromRGB(113, 221, 75),
                    Color2 = Color3.fromRGB(0, 0, 0),
                    LifeTime = 1.6,
                    Width = 0.1,
                },
            },
        },
    }

    Settings.Visuals.Character_Chams = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Material = Enum.Material.ForceField,
    }
    Settings.Visuals.Weapon_Chams = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Material = Enum.Material.Neon,
    }

    local function applyChams(character)
        if Settings.Visuals.Character_Chams.Enabled and character then
            for i, v in pairs(character:GetDescendants())do
                if (v.Parent:IsA('Tool') and (v:IsA('MeshPart') or v:IsA('BasePart'))) then
                    continue
                end
                if v:IsA('MeshPart') then
                    v.Material = Settings.Visuals.Character_Chams.Material
                    v.Color = Settings.Visuals.Character_Chams.Color
                    v.TextureID = ''
                end
                if v:IsA('BasePart') then
                    v.Material = Settings.Visuals.Character_Chams.Material
                    v.Color = Settings.Visuals.Character_Chams.Color
                end
            end
        end
        if Settings.Visuals.Weapon_Chams.Enabled and character then
            local Gun = character:FindFirstChildOfClass('Tool')

            if Gun then
                for i, v in pairs(Gun:GetChildren())do
                    if v:IsA('MeshPart') then
                        v.Material = Settings.Visuals.Weapon_Chams.Material
                        v.Color = Settings.Visuals.Weapon_Chams.Color
                        v.TextureID = ''
                    end
                    if v:IsA('BasePart') then
                        v.Material = Settings.Visuals.Weapon_Chams.Material
                        v.Color = Settings.Visuals.Weapon_Chams.Color
                    end
                end
            end
        end
    end
    local function onChamsCharacter(character)
        task.wait(2)
        applyChams(character)
        character.ChildAdded:Connect(function(child)
            if child:IsA('Tool') then
                applyChams(character)
            end
        end)
    end

    localPlayer.CharacterAdded:Connect(onChamsCharacter)

    if localPlayer.Character then
        onChamsCharacter(localPlayer.Character)
    end

    SelfGroup:AddToggle('WeaponChamsEnabled', {
        Text = 'Weapon Enabled',
        Default = false,
        Callback = function(Value)
            Settings.Visuals.Weapon_Chams.Enabled = Value

            applyChams(localPlayer.Character)
        end,
    }):AddColorPicker('WeaponChamsColor', {
        Default = Settings.Visuals.Weapon_Chams.Color,
        Title = 'Weapon Color',
        Callback = function(Value)
            Settings.Visuals.Weapon_Chams.Color = Value

            applyChams(localPlayer.Character)
        end,
    })
    SelfGroup:AddDropdown('WeaponChamsType', {
        Values = {
            'Neon',
            'ForceField',
        },
        Default = 'Neon',
        Multi = false,
        Text = 'Weapon Cham Type',
        Callback = function(Value)
            if Value == 'Neon' then
                Settings.Visuals.Weapon_Chams.Material = Enum.Material.Neon
            elseif Value == 'ForceField' then
                Settings.Visuals.Weapon_Chams.Material = Enum.Material.ForceField
            end

            applyChams(localPlayer.Character)
        end,
    })
    SelfGroup:AddToggle('ClientChamsEnabled', {
        Text = 'Client Enabled',
        Default = false,
        Callback = function(Value)
            Settings.Visuals.Character_Chams.Enabled = Value

            applyChams(localPlayer.Character)
        end,
    }):AddColorPicker('ClientChamsColor', {
        Default = Settings.Visuals.Character_Chams.Color,
        Title = 'Client Color',
        Callback = function(Value)
            Settings.Visuals.Character_Chams.Color = Value

            applyChams(localPlayer.Character)
        end,
    })
    SelfGroup:AddDropdown('ClientChamsType', {
        Values = {
            'Force Field',
            'Neon',
        },
        Default = 'Force Field',
        Multi = false,
        Text = 'Client Cham Type',
        Callback = function(Value)
            if Value == 'Force Field' then
                Settings.Visuals.Character_Chams.Material = Enum.Material.ForceField
            elseif Value == 'Neon' then
                Settings.Visuals.Character_Chams.Material = Enum.Material.Neon
            end

            applyChams(localPlayer.Character)
        end,
    })

    utility.trail_character = function(Bool)
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild('HumanoidRootPart')

        if Bool then
            if not humanoidRootPart:FindFirstChild('Baba') then
                local Baba = Instance.new('Trail', humanoidRootPart)

                Baba.Name = 'Baba'
                humanoidRootPart.Material = Enum.Material.Neon

                local attachment0 = Instance.new('Attachment', humanoidRootPart)

                attachment0.Position = Vector3.new(0, 1, 0)

                local attachment1 = Instance.new('Attachment', humanoidRootPart)

                attachment1.Position = Vector3.new(0, -1, 0)
                Baba.Attachment0 = attachment0
                Baba.Attachment1 = attachment1
                Baba.Color = ColorSequence.new(Settings.Visuals.SelfESP.Trail.Color, Settings.Visuals.SelfESP.Trail.Color2)
                Baba.Lifetime = Settings.Visuals.SelfESP.Trail.LifeTime
                Baba.Transparency = NumberSequence.new(0, 0)
                Baba.LightEmission = 0.2
                Baba.FaceCamera = true
                Baba.Brightness = 10
                Baba.WidthScale = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, Settings.Visuals.SelfESP.Trail.Width),
                    NumberSequenceKeypoint.new(1, 0),
                }
            end
        else
            for _, child in ipairs(humanoidRootPart:GetChildren())do
                if child:IsA('Trail') and child.Name == 'Baba' then
                    child:Destroy()
                end
            end
        end
    end

    local function onCharacterAdded(character)
        if getgenv().trailEnabled then
            utility.trail_character(true)
        end
    end

    localPlayer.CharacterAdded:Connect(onCharacterAdded)

    if localPlayer.Character then
        onCharacterAdded(localPlayer.Character)
    end

    SelfGroup:AddToggle('TrailTogglev2', {
        Text = 'Trail',
        Default = false,
        Callback = function(state)
            getgenv().trailEnabled = state

            utility.trail_character(state)
        end,
    }):AddColorPicker('TrailColorv2', {
        Default = Settings.Visuals.SelfESP.Trail.Color,
        Title = 'Trail Color',
        Callback = function(color)
            Settings.Visuals.SelfESP.Trail.Color = color

            if getgenv().trailEnabled then
                utility.trail_character(false)
                utility.trail_character(true)
            end
        end,
    }):AddColorPicker('TrailColor2v2', {
        Default = Settings.Visuals.SelfESP.Trail.Color2,
        Title = 'Trail Color 2',
        Callback = function(color)
            Settings.Visuals.SelfESP.Trail.Color2 = color

            if getgenv().trailEnabled then
                utility.trail_character(false)
                utility.trail_character(true)
            end
        end,
    })
    SelfGroup:AddSlider('TrailLifetimev2', {
        Text = 'Trail Lifetime v2',
        Default = 1.6,
        Min = 0.1,
        Max = 5,
        Rounding = 1,
        Callback = function(value)
            Settings.Visuals.SelfESP.Trail.LifeTime = value

            if getgenv().trailEnabled then
                utility.trail_character(false)
                utility.trail_character(true)
            end
        end,
    })
end)()
task.wait(1)
coroutine.wrap(function()
    local BulletTracerGroup = Tabs.Visual:AddLeftGroupbox('BulletTracer')

    DYHUBcc.BulletTracers = {
        Enabled = false,
        TextureID = 'rbxassetid://12781852245',
        Color = Color3.new(255, 255, 255),
        Size = 0.3,
        Transparency = 0,
        TimeAlive = 3,
    }

    local function bullettracerlol(startPos, endPos)
        local startPart = Instance.new('Part')

        startPart.Name = 'BulletStart'
        startPart.Anchored = true
        startPart.CanCollide = false
        startPart.Transparency = 1
        startPart.Size = Vector3.new(0.2, 0.2, 0.2)
        startPart.Material = Enum.Material.ForceField
        startPart.Color = Color3.new(1, 0, 0)
        startPart.Transparency = 1
        startPart.CanTouch = false
        startPart.CanQuery = false
        startPart.Massless = true
        startPart.CollisionGroupId = 0
        startPart.Position = startPos
        startPart.Parent = workspace

        local endPart = Instance.new('Part')

        endPart.Name = 'BulletEnd'
        endPart.Anchored = true
        endPart.CanCollide = false
        endPart.Size = Vector3.new(0.2, 0.2, 0.2)
        endPart.Material = Enum.Material.ForceField
        endPart.Color = Color3.new(1, 0, 0)
        endPart.Transparency = 1
        endPart.CanTouch = false
        endPart.CanQuery = false
        endPart.Massless = true
        endPart.CollisionGroupId = 0
        endPart.Position = endPos
        endPart.Parent = workspace

        local beam = Instance.new('Beam')

        beam.Attachment0 = Instance.new('Attachment', startPart)
        beam.Attachment1 = Instance.new('Attachment', endPart)
        beam.Parent = startPart
        beam.FaceCamera = true
        beam.Color = ColorSequence.new(DYHUBcc.BulletTracers.Color)
        beam.Texture = DYHUBcc.BulletTracers.TextureID
        beam.LightEmission = 1
        beam.Transparency = NumberSequence.new(DYHUBcc.BulletTracers.Transparency)
        beam.Width0 = DYHUBcc.BulletTracers.Size
        beam.Width1 = DYHUBcc.BulletTracers.Size

        task.delay(DYHUBcc.BulletTracers.TimeAlive, function()
            if beam and beam.Parent then
                local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(beam, tweenInfo, {
                    Width0 = 0,
                    Width1 = 0,
                })

                tween:Play()
                tween.Completed:Wait()
            end
            if startPart and startPart.Parent then
                startPart:Destroy()
            end
            if endPart and endPart.Parent then
                endPart:Destroy()
            end
            if beam and beam.Parent then
                beam:Destroy()
            end
        end)

        return startPart, endPart, beam
    end

    if getnamecallmethod and MainEvent ~= nil then
        local mt = getrawmetatable(MainEvent)

        setreadonly(mt, false)

        local cloned_mt = table.clone(mt)
        local oldnamecall = cloned_mt.__namecall

        setrawmetatable(MainEvent, {
            __namecall = (function(self, ...)
                local args = {...}

                if getnamecallmethod() == 'FireServer' then
                    if args[1] == 'ShootGun' then
                        if DYHUBcc.BulletTracers.Enabled then
                            bullettracerlol(args[3], args[4])
                        end
                    end
                end

                return oldnamecall(self, unpack(args))
            end),
            __index = cloned_mt.__index,
            __newindex = cloned_mt.__newindex,
            __call = cloned_mt.__call,
            __tostring = cloned_mt.__tostring,
        })
    end

    BulletTracerGroup:AddToggle('BulletTracersEnabled', {
        Text = 'Enabled',
        Default = false,
        Callback = function(Value)
            DYHUBcc.BulletTracers.Enabled = Value

            if not getnamecallmethod then
                Library:Notify('Your executor does not support this feature')
            end
        end,
    }):AddColorPicker('BulletTracersColor', {
        Default = DYHUBcc.BulletTracers.Color,
        Title = 'Color',
        Callback = function(Value)
            DYHUBcc.BulletTracers.Color = Value
        end,
    })
    BulletTracerGroup:AddDropdown('BulletTracersTexture', {
        Values = {
            'Beam',
            'Lightning',
            'Heartrate',
            'Chain',
            'Glitch',
            'Swirl',
        },
        Default = 'Beam',
        Multi = false,
        Text = 'Texture',
        Callback = function(Value)
            if Value == 'Beam' then
                DYHUBcc.BulletTracers.TextureID = 'rbxassetid://12781852245'
            elseif Value == 'Lightning' then
                DYHUBcc.BulletTracers.TextureID = 'rbxassetid://446111271'
            elseif Value == 'Heartrate' then
                DYHUBcc.BulletTracers.TextureID = 'rbxassetid://5830549480'
            elseif Value == 'Chain' then
                DYHUBcc.BulletTracers.TextureID = 'rbxassetid://9632168658'
            elseif Value == 'Glitch' then
                DYHUBcc.BulletTracers.TextureID = 'rbxassetid://8089467613'
            elseif Value == 'Swirl' then
                DYHUBcc.BulletTracers.TextureID = 'rbxassetid://5638168605'
            end
        end,
    })
    BulletTracerGroup:AddSlider('BulletTracersSize', {
        Text = 'Size',
        Default = 0.3,
        Min = 0.1,
        Max = 3,
        Rounding = 2,
        Callback = function(Value)
            DYHUBcc.BulletTracers.Size = Value
        end,
    })
    BulletTracerGroup:AddSlider('BulletTracersTransparency', {
        Text = 'Transparency',
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            DYHUBcc.BulletTracers.Transparency = Value
        end,
    })
    BulletTracerGroup:AddSlider('BulletTracersTimeAlive', {
        Text = 'Time Alive',
        Default = 3,
        Min = 1,
        Max = 10,
        Rounding = 0,
        Callback = function(Value)
            DYHUBcc.BulletTracers.TimeAlive = Value
        end,
    })

    local HudUi = Tabs.Visual:AddLeftGroupbox('Hud Changer')
    local defaultTextHP = ' Health '
    local defaultTextArmor = '                   Armor'
    local defaultTextEnergy = 'Dark Energy              '
    local defaultColorHP = Color3.new(0.941176, 0.031373, 0.819608)
    local defaultColorArmor = Color3.new(0.376471, 0.031373, 0.933333)
    local defaultColorEnergy = Color3.new(0.768627, 0.039216, 0.952941)
    local textHP, textArmor, textEnergy = defaultTextHP, defaultTextArmor, defaultTextEnergy
    local colorHP, colorArmor, colorEnergy = defaultColorHP, defaultColorArmor, defaultColorEnergy
    local toggleHP, toggleArmor, toggleEnergy = false, false, false

    local function skibiditoilet()
        local player = game.Players.LocalPlayer
        local playerGui = player:WaitForChild('PlayerGui')
        local gui = playerGui:WaitForChild('MainScreenGui').Bar

        if toggleHP then
            gui.HP.TextLabel.Text = textHP
            gui.HP.bar.BackgroundColor3 = colorHP
        end
        if toggleArmor then
            gui.Armor.TextLabel.Text = textArmor
            gui.Armor.bar.BackgroundColor3 = colorArmor
        end
        if toggleEnergy then
            gui.Energy.TextLabel.Text = textEnergy
            gui.Energy.bar.BackgroundColor3 = colorEnergy
        end
    end

    HudUi:AddToggle('ToggleHP', {
        Text = 'Customize Health',
        Default = false,
        Callback = function(state)
            toggleHP = state

            skibiditoilet()
        end,
    }):AddColorPicker('ColorHP', {
        Text = 'Health Color',
        Default = defaultColorHP,
        Callback = function(value)
            if toggleHP then
                colorHP = value

                skibiditoilet()
            end
        end,
    })
    HudUi:AddInput('TextHP', {
        Text = 'Health Text',
        Default = defaultTextHP,
        Callback = function(value)
            if toggleHP then
                textHP = value

                skibiditoilet()
            end
        end,
    })
    HudUi:AddToggle('ToggleArmor', {
        Text = 'Customize Armor',
        Default = false,
        Callback = function(state)
            toggleArmor = state

            skibiditoilet()
        end,
    }):AddColorPicker('ColorArmor', {
        Text = 'Armor Color',
        Default = defaultColorArmor,
        Callback = function(value)
            if toggleArmor then
                colorArmor = value

                skibiditoilet()
            end
        end,
    })
    HudUi:AddInput('TextArmor', {
        Text = 'Armor Text',
        Default = defaultTextArmor,
        Callback = function(value)
            if toggleArmor then
                textArmor = value

                skibiditoilet()
            end
        end,
    })
    HudUi:AddToggle('ToggleEnergy', {
        Text = 'Customize Energy',
        Default = false,
        Callback = function(state)
            toggleEnergy = state

            skibiditoilet()
        end,
    }):AddColorPicker('ColorEnergy', {
        Text = 'Energy Color',
        Default = defaultColorEnergy,
        Callback = function(value)
            if toggleEnergy then
                colorEnergy = value

                skibiditoilet()
            end
        end,
    })
    HudUi:AddInput('TextEnergy', {
        Text = 'Energy Text',
        Default = defaultTextEnergy,
        Callback = function(value)
            if toggleEnergy then
                textEnergy = value

                skibiditoilet()
            end
        end,
    })

    local player = game.Players.LocalPlayer

    player.CharacterAdded:Connect(function()
        if toggleHP or toggleArmor or toggleEnergy then
            player:WaitForChild('PlayerGui')
            skibiditoilet()
        end
    end)
end)()

local MovementGroup = Tabs.Character:AddLeftGroupbox('Movement')

task.wait(1)
coroutine.wrap(function()
    local CrosshairGroup = Tabs.Visual:AddRightGroupbox('Crosshair')
    local Client = players.LocalPlayer
    local mouse = Client:GetMouse()
    local RunService = game:GetService('RunService')
    local Camera = workspace.CurrentCamera
    local visualState = {
        time = 0,
        rotationProgress = 0,
        currentRotationSpeed = 0.8,
        smoothedRotation = 5,
        lines = {
            top = {
                Size = UDim2.new(0, 3, 0, 25),
                Position = UDim2.new(0.5, -1.5, 0, 0),
                Color = Color3.new(1, 1, 1),
            },
            bottom = {
                Size = UDim2.new(0, 3, 0, 25),
                Position = UDim2.new(0.5, -1.5, 1, -25),
                Color = Color3.new(1, 1, 1),
            },
            left = {
                Size = UDim2.new(0, 25, 0, 3),
                Position = UDim2.new(0, 0, 0.5, -1.5),
                Color = Color3.new(1, 1, 1),
            },
            right = {
                Size = UDim2.new(0, 25, 0, 3),
                Position = UDim2.new(1, -25, 0.5, -1.5),
                Color = Color3.new(1, 1, 1),
            },
        },
        text = {
            Text = 'DYHUB',
            Position = UDim2.new(0, 0, 0, 0),
            Color = Color3.new(1, 1, 1),
            Font = Enum.Font.Arcade,
            TextScaled = true,
        },
    }
    local screenGui
    local aimContainer
    local topLine, bottomLine, leftLine, rightLine
    local textLabel
    local lineLength = 25
    local lineThickness = 1
    local baseRotationSpeed = 0.8
    local pulseSpeed = 2.5
    local minLength = -10
    local maxLength = -30
    local time = 0
    local rotationProgress = 0
    local currentRotationSpeed = baseRotationSpeed
    local smoothedRotation = 5
    local isCrosshairEnabled = false
    local isTextEnabled = true
    local isRainbowEnabled = false
    local isFollowTargetEnabled = false
    local fixedColor = Color3.new(1, 1, 1)
    local targetAim = nil

    local function getClosestTarget()
        local closestPlayer = nil
        local shortestDistance = math.huge

        for _, player in pairs(players:GetPlayers())do
            if player ~= Client and player.Character then
                local character = player.Character
                local humanoid = character:FindFirstChild('Humanoid')
                local upperTorso = character:FindFirstChild('UpperTorso')
                local torso = character:FindFirstChild('Torso') or character:FindFirstChild('HumanoidRootPart')

                if humanoid and humanoid.Health > 0 and (upperTorso or torso) then
                    local targetPart = upperTorso or torso
                    local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)

                    if onScreen then
                        local mousePos = Vector2.new(mouse.X, mouse.Y)
                        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (mousePos - targetPos).Magnitude

                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = targetPart
                        end
                    end
                end
            end
        end

        return closestPlayer
    end
    local function createLine(parent, size, position, color)
        local frame = Instance.new('Frame')

        frame.Size = size
        frame.Position = position
        frame.BackgroundColor3 = color
        frame.BorderSizePixel = 0
        frame.ZIndex = 5
        frame.Parent = parent

        local stroke = Instance.new('UIStroke')

        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Color = Color3.new(0, 0, 0)
        stroke.Thickness = 1
        stroke.Parent = frame

        return frame
    end
    local function createTextLabel(parent, text, position, color, font, scaled)
        local label = Instance.new('TextLabel')

        label.Text = text
        label.Position = position
        label.TextColor3 = color
        label.Font = font
        label.TextScaled = scaled
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0, 150, 0, 23)
        label.ZIndex = 10
        label.Parent = parent

        local stroke = Instance.new('UIStroke')

        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        stroke.Color = Color3.new(0, 0, 0)
        stroke.Thickness = 1
        stroke.LineJoinMode = Enum.LineJoinMode.Round
        stroke.Parent = label

        return label
    end
    local function clearGui()
        if screenGui then
            screenGui:Destroy()

            screenGui = nil
        end
    end
    local function createGui()
        clearGui()

        screenGui = Instance.new('ScreenGui')
        screenGui.Name = 'AimSightGUI'
        screenGui.ResetOnSpawn = false
        screenGui.Parent = Client:WaitForChild('PlayerGui')
        aimContainer = Instance.new('Frame')
        aimContainer.BackgroundTransparency = 1
        aimContainer.Size = UDim2.new(0, 25, 0, 25)
        aimContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        aimContainer.Parent = screenGui
        topLine = createLine(aimContainer, visualState.lines.top.Size, visualState.lines.top.Position, visualState.lines.top.Color)
        bottomLine = createLine(aimContainer, visualState.lines.bottom.Size, visualState.lines.bottom.Position, visualState.lines.bottom.Color)
        leftLine = createLine(aimContainer, visualState.lines.left.Size, visualState.lines.left.Position, visualState.lines.left.Color)
        rightLine = createLine(aimContainer, visualState.lines.right.Size, visualState.lines.right.Position, visualState.lines.right.Color)
        textLabel = createTextLabel(screenGui, visualState.text.Text, visualState.text.Position, visualState.text.Color, visualState.text.Font, visualState.text.TextScaled)
        textLabel.Visible = isTextEnabled
    end
    local function saveVisualState()
        visualState.time = time
        visualState.rotationProgress = rotationProgress
        visualState.currentRotationSpeed = currentRotationSpeed
        visualState.smoothedRotation = smoothedRotation
        visualState.lines.top.Size = topLine.Size
        visualState.lines.top.Position = topLine.Position
        visualState.lines.top.Color = topLine.BackgroundColor3
        visualState.lines.bottom.Size = bottomLine.Size
        visualState.lines.bottom.Position = bottomLine.Position
        visualState.lines.bottom.Color = bottomLine.BackgroundColor3
        visualState.lines.left.Size = leftLine.Size
        visualState.lines.left.Position = leftLine.Position
        visualState.lines.left.Color = leftLine.BackgroundColor3
        visualState.lines.right.Size = rightLine.Size
        visualState.lines.right.Position = rightLine.Position
        visualState.lines.right.Color = rightLine.BackgroundColor3
        visualState.text.Text = textLabel.Text
        visualState.text.Position = textLabel.Position
        visualState.text.Color = textLabel.TextColor3
        visualState.text.Font = textLabel.Font
        visualState.text.TextScaled = textLabel.TextScaled
    end
    local function restoreVisualState()
        if not (topLine and bottomLine and leftLine and rightLine and textLabel) then
            return
        end

        time = visualState.time or 0
        rotationProgress = visualState.rotationProgress or 0
        currentRotationSpeed = visualState.currentRotationSpeed or baseRotationSpeed
        smoothedRotation = visualState.smoothedRotation or 5
        topLine.Size = visualState.lines.top.Size or topLine.Size
        topLine.Position = visualState.lines.top.Position or topLine.Position
        topLine.BackgroundColor3 = visualState.lines.top.Color or topLine.BackgroundColor3
        bottomLine.Size = visualState.lines.bottom.Size or bottomLine.Size
        bottomLine.Position = visualState.lines.bottom.Position or bottomLine.Position
        bottomLine.BackgroundColor3 = visualState.lines.bottom.Color or bottomLine.BackgroundColor3
        leftLine.Size = visualState.lines.left.Size or leftLine.Size
        leftLine.Position = visualState.lines.left.Position or leftLine.Position
        leftLine.BackgroundColor3 = visualState.lines.left.Color or leftLine.BackgroundColor3
        rightLine.Size = visualState.lines.right.Size or rightLine.Size
        rightLine.Position = visualState.lines.right.Position or rightLine.Position
        rightLine.BackgroundColor3 = visualState.lines.right.Color or rightLine.BackgroundColor3
        textLabel.Text = visualState.text.Text or textLabel.Text
        textLabel.Position = visualState.text.Position or textLabel.Position
        textLabel.TextColor3 = visualState.text.Color or textLabel.TextColor3
        textLabel.Font = visualState.text.Font or textLabel.Font
        textLabel.TextScaled = visualState.text.TextScaled or textLabel.TextScaled
    end
    local function getRainbowColor(t)
        local r = math.sin(t * 0.6) * 0.5 + 0.5
        local g = math.sin(t * 0.6 + 2) * 0.5 + 0.5
        local b = math.sin(t * 0.6 + 4) * 0.5 + 0.5

        return Color3.new(r, g, b)
    end
    local function calculateRotationSpeed(progress)
        local slowdownStart = 0.6
        local slowdownDuration = 0.35
        local minSlowdownSpeed = 0.3
        local baseRotationSpeedLocal = baseRotationSpeed

        if progress >= slowdownStart then
            local slowdownProgress = (progress - slowdownStart) / slowdownDuration
            local easedProgress = slowdownProgress * slowdownProgress
            local slowdownFactor = 1 - (easedProgress * (1 - minSlowdownSpeed))

            return baseRotationSpeedLocal * math.max(slowdownFactor, minSlowdownSpeed)
        else
            return baseRotationSpeedLocal
        end
    end
    local function smoothRotation(currentRot, targetRot, smoothing)
        return currentRot + (targetRot - currentRot) * smoothing
    end
    local function smoothPulse(t, speed)
        local rawPulse = math.sin(t * speed) * 0.5 + 0.5

        return rawPulse * rawPulse
    end
    local function onCharacterAdded(character)
        if isCrosshairEnabled then
            createGui()
            restoreVisualState()
        end

        local humanoid = character:WaitForChild('Humanoid')

        humanoid.Died:Connect(function()
            saveVisualState()
        end)
    end

    Client.CharacterAdded:Connect(onCharacterAdded)

    if Client.Character then
        onCharacterAdded(Client.Character)
    end

    RunService.RenderStepped:Connect(function(deltaTime)
        if not (aimContainer and topLine and bottomLine and leftLine and rightLine and textLabel) then
            return
        end

        time = time + deltaTime

        local mouseX = mouse.X
        local mouseY = mouse.Y
        local targetX = mouseX
        local targetY = mouseY

        if isFollowTargetEnabled and DYHUBcc and DYHUBcc.TargetAim and DYHUBcc.TargetAim.Target ~= 'None' then
            local targetPlayer = Players:FindFirstChild(DYHUBcc.TargetAim.Target)

            if targetPlayer and targetPlayer.Character then
                local aimPart = targetPlayer.Character:FindFirstChild('Head')

                if aimPart then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(aimPart.Position)

                    if onScreen then
                        targetX = screenPos.X
                        targetY = screenPos.Y
                    end
                end
            end
        end

        aimContainer.Position = UDim2.new(0, targetX, 0, targetY)
        textLabel.Position = UDim2.new(0, targetX - 70, 0, targetY + 50)
        rotationProgress = (rotationProgress + currentRotationSpeed * deltaTime) % 1
        currentRotationSpeed = calculateRotationSpeed(rotationProgress)

        local targetRotation = rotationProgress * 360

        smoothedRotation = smoothRotation(smoothedRotation, targetRotation, 1)
        aimContainer.Rotation = smoothedRotation

        local pulse = smoothPulse(time, pulseSpeed)
        local currentLength = minLength + (maxLength - minLength) * pulse

        topLine.Size = UDim2.new(0, lineThickness, 0, currentLength)
        bottomLine.Size = UDim2.new(0, lineThickness, 0, currentLength)
        leftLine.Size = UDim2.new(0, currentLength, 0, lineThickness)
        rightLine.Size = UDim2.new(0, currentLength, 0, lineThickness)
        topLine.Position = UDim2.new(0.5, -lineThickness / 2, 0, 0)
        bottomLine.Position = UDim2.new(0.5, -lineThickness / 2, 1, -currentLength)
        leftLine.Position = UDim2.new(0, 0, 0.5, -lineThickness / 2)
        rightLine.Position = UDim2.new(1, -currentLength, 0.5, -lineThickness / 2)

        local color = isRainbowEnabled and getRainbowColor(time) or fixedColor

        topLine.BackgroundColor3 = color
        bottomLine.BackgroundColor3 = color
        leftLine.BackgroundColor3 = color
        rightLine.BackgroundColor3 = color
        textLabel.TextColor3 = color
    end)
    CrosshairGroup:AddToggle('CrosshairEnabled', {
        Text = 'Enabled',
        Default = false,
        Callback = function(Value)
            isCrosshairEnabled = Value

            if Value then
                createGui()
                restoreVisualState()
            else
                clearGui()
            end
        end,
    }):AddColorPicker('CrosshairColor', {
        Default = Color3.fromRGB(255, 255, 255),
        Title = 'Color',
        Callback = function(Value)
            fixedColor = Value

            if not isRainbowEnabled and topLine and bottomLine and leftLine and rightLine and textLabel then
                topLine.BackgroundColor3 = Value
                bottomLine.BackgroundColor3 = Value
                leftLine.BackgroundColor3 = Value
                rightLine.BackgroundColor3 = Value
                textLabel.TextColor3 = Value
            end
        end,
    })
    CrosshairGroup:AddToggle('CrosshairFollowTarget', {
        Text = 'Follow Target',
        Default = false,
        Tooltip = 'Crosshair will follow the closest enemy on screen',
        Callback = function(Value)
            isFollowTargetEnabled = Value
        end,
    })
    CrosshairGroup:AddToggle('CrosshairText', {
        Text = 'Text',
        Default = true,
        Callback = function(Value)
            isTextEnabled = Value

            if textLabel then
                textLabel.Visible = Value
            end
        end,
    })
    CrosshairGroup:AddSlider('CrosshairSpinSpeed', {
        Text = 'Spin Speed',
        Default = 0.8,
        Min = 0.1,
        Max = 2,
        Rounding = 2,
        Callback = function(Value)
            baseRotationSpeed = Value
        end,
    })
    CrosshairGroup:AddSlider('CrosshairLineLength', {
        Text = 'Line Length',
        Default = 25,
        Min = 5,
        Max = 100,
        Rounding = 1,
        Callback = function(Value)
            lineLength = Value
            visualState.lines.top.Size = UDim2.new(0, 3, 0, Value)
            visualState.lines.bottom.Size = UDim2.new(0, 3, 0, Value)
            visualState.lines.left.Size = UDim2.new(0, Value, 0, 3)
            visualState.lines.right.Size = UDim2.new(0, Value, 0, 3)
            minLength = -Value * 0.4
            maxLength = -Value * 1.2
        end,
    })
    CrosshairGroup:AddToggle('CrosshairRainbow', {
        Text = 'Rainbow',
        Default = false,
        Callback = function(Value)
            isRainbowEnabled = Value
        end,
    })
    CrosshairGroup:AddDivider()

    local spinConnection = nil
    local spinSpeed = 10

    CrosshairGroup:AddToggle('CursorSpin', {
        Text = 'Spinning Cursor',
        Default = false,
        Callback = function(value)
            if value then
                if spinConnection then
                    spinConnection:Disconnect()
                end

                spinConnection = game:GetService('RunService').RenderStepped:Connect(function(deltaTime)
                    if not Toggles.CursorSpin.Value then
                        return
                    end

                    local aimGui = plr.PlayerGui:FindFirstChild('MainScreenGui')

                    if aimGui then
                        local aim = aimGui:FindFirstChild('Aim')

                        if aim then
                            aim.Rotation = (aim.Rotation + (spinSpeed * deltaTime * 60)) % 360
                        end
                    end
                end)
            else
                if spinConnection then
                    spinConnection:Disconnect()

                    spinConnection = nil
                end

                local aimGui = plr.PlayerGui:FindFirstChild('MainScreenGui')

                if aimGui and aimGui:FindFirstChild('Aim') then
                    aimGui.Aim.Rotation = 0
                end
            end
        end,
    })
    CrosshairGroup:AddSlider('CursorSpinSpeed', {
        Text = 'Spin Speed',
        Min = 1,
        Max = 100,
        Default = 10,
        Rounding = 1,
        Callback = function(value)
            spinSpeed = value
        end,
    })

    local TextureGroup = Tabs.World:AddRightGroupbox('Texture Minecraft')
    local WeatherGroup = Tabs.World:AddRightGroupbox('Weather')
    local faces = {
        'Front',
        'Back',
        'Bottom',
        'Top',
        'Right',
        'Left',
    }
    local materials = {
        {
            'Wood',
            '3258599312',
        },
        {
            'WoodPlanks',
            '8676581022',
        },
        {
            'Brick',
            '8558400252',
        },
        {
            'Cobblestone',
            '5003953441',
        },
        {
            'Concrete',
            '7341687607',
        },
        {
            'DiamondPlate',
            '6849247561',
        },
        {
            'Fabric',
            '118776397',
        },
        {
            'Granite',
            '4722586771',
        },
        {
            'Grass',
            '4722588177',
        },
        {
            'Ice',
            '3823766459',
        },
        {
            'Marble',
            '62967586',
        },
        {
            'Metal',
            '62967586',
        },
        {
            'Sand',
            '152572215',
        },
    }
    local originalMaterials = {}
    local textureConnection

    function texture(ins, id)
        for _, v in pairs(faces)do
            local texture = Instance.new('Texture', ins)

            texture.ZIndex = 2147483647
            texture.Texture = 'rbxassetid://' .. id
            texture.Face = Enum.NormalId[v]
            texture.Color3 = ins.Color
            texture.Transparency = ins.Transparency
        end
    end

    local function applyTextures()
        for _, part in pairs(workspace:GetDescendants())do
            if part:IsA('BasePart') and not originalMaterials[part] then
                originalMaterials[part] = part.Material

                for _, v in pairs(materials)do
                    if part.Material.Name == v[1] then
                        texture(part, v[2])

                        part.Material = Enum.Material.SmoothPlastic

                        break
                    end
                end
            end
        end
    end
    local function revertTextures()
        for part, material in pairs(originalMaterials)do
            if part and part.Parent then
                part.Material = material

                for _, child in pairs(part:GetChildren())do
                    if child:IsA('Texture') then
                        child:Destroy()
                    end
                end
            end
        end

        originalMaterials = {}
    end

    TextureGroup:AddToggle('TextureToggle', {
        Text = 'Enabled',
        Default = false,
        Callback = function(state)
            if state then
                applyTextures()

                textureConnection = workspace.DescendantAdded:Connect(function(desc)
                    if desc:IsA('BasePart') then
                        originalMaterials[desc] = desc.Material

                        for _, v in pairs(materials)do
                            if desc.Material.Name == v[1] then
                                texture(desc, v[2])

                                desc.Material = Enum.Material.SmoothPlastic

                                break
                            end
                        end
                    end
                end)
            else
                if textureConnection then
                    textureConnection:Disconnect()

                    textureConnection = nil
                end

                revertTextures()
            end
        end,
    })

    getgenv().RainSettings = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Lifetime = 5,
        Rate = 1000,
        Speed = 100,
    }
    getgenv().SnowSettings = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Lifetime = 100,
        Rate = 100,
        Speed = 10,
    }

    local rainPart = nil
    local rainEmitter = nil
    local rainConnection = nil
    local snowPart = nil
    local snowEmitter = nil
    local snowConnection = nil

    local function rainParticleEmitter()
        if rainPart then
            rainPart:Destroy()

            rainPart = nil
            rainEmitter = nil
        end

        rainPart = Instance.new('Part')
        rainPart.Size = Vector3.new(51.8, 0.001, 52.084)
        rainPart.CanCollide = false
        rainPart.Anchored = true
        rainPart.Transparency = 1
        rainPart.Parent = workspace
        rainEmitter = Instance.new('ParticleEmitter')
        rainEmitter.Color = ColorSequence.new(RainSettings.Color)
        rainEmitter.LightEmission = 1
        rainEmitter.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
        rainEmitter.Size = NumberSequence.new(0.2)
        rainEmitter.Squash = NumberSequence.new(7)
        rainEmitter.Texture = 'rbxassetid://118641183'
        rainEmitter.EmissionDirection = Enum.NormalId.Bottom
        rainEmitter.Lifetime = NumberRange.new(RainSettings.Lifetime)
        rainEmitter.Rate = RainSettings.Rate
        rainEmitter.Speed = NumberRange.new(RainSettings.Speed)
        rainEmitter.LockedToPart = true
        rainEmitter.Enabled = true
        rainEmitter.Parent = rainPart
    end
    local function snowParticleEmitter()
        if snowPart then
            snowPart:Destroy()

            snowPart = nil
            snowEmitter = nil
        end

        snowPart = Instance.new('Part')
        snowPart.Name = 'SnowEmitterPart'
        snowPart.Size = Vector3.new(51.8, 0.001, 52.084)
        snowPart.Anchored = true
        snowPart.CanCollide = false
        snowPart.CanQuery = true
        snowPart.CanTouch = true
        snowPart.CastShadow = true
        snowPart.CollisionGroup = 'Default'
        snowPart.CollisionGroupId = 0
        snowPart.Material = Enum.Material.Plastic
        snowPart.PivotOffset = CFrame.new(0, 0, 0)
        snowPart.Reflectance = 0
        snowPart.RootPriority = 0
        snowPart.RotVelocity = Vector3.new(0, 0, 0)
        snowPart.Transparency = 1
        snowPart.Velocity = Vector3.new(0, 0, 0)
        snowPart.Parent = workspace
        snowEmitter = Instance.new('ParticleEmitter')
        snowEmitter.Acceleration = Vector3.new(0, 0, 0)
        snowEmitter.Brightness = 1
        snowEmitter.Color = ColorSequence.new(SnowSettings.Color)
        snowEmitter.Drag = 0
        snowEmitter.EmissionDirection = Enum.NormalId.Bottom
        snowEmitter.Enabled = true
        snowEmitter.FlipbookFramerate = NumberRange.new(1, 1)
        snowEmitter.FlipbookLayout = Enum.ParticleFlipbookLayout.None
        snowEmitter.FlipbookMode = Enum.ParticleFlipbookMode.Loop
        snowEmitter.Lifetime = NumberRange.new(5, 100)
        snowEmitter.LightEmission = 0
        snowEmitter.LightInfluence = 0
        snowEmitter.LockedToPart = false
        snowEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
        snowEmitter.Rate = SnowSettings.Rate
        snowEmitter.RotSpeed = NumberRange.new(360, 360)
        snowEmitter.Rotation = NumberRange.new(20, 20)
        snowEmitter.Shape = Enum.ParticleEmitterShape.Box
        snowEmitter.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
        snowEmitter.ShapePartial = 1
        snowEmitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
        snowEmitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2, 0.4),
            NumberSequenceKeypoint.new(1, 0.2, 0.4),
        })
        snowEmitter.Speed = NumberRange.new(SnowSettings.Speed)
        snowEmitter.SpreadAngle = Vector2.new(90, 90)
        snowEmitter.Squash = NumberSequence.new(0)
        snowEmitter.Texture = 'rbxassetid://129110349'
        snowEmitter.TimeScale = 1
        snowEmitter.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.8625),
            NumberSequenceKeypoint.new(0.15, 0),
            NumberSequenceKeypoint.new(0.196326, 0.70625),
            NumberSequenceKeypoint.new(1, 0),
        })
        snowEmitter.VelocityInheritance = 0
        snowEmitter.WindAffectsDrag = false
        snowEmitter.ZOffset = 0
        snowEmitter.Parent = snowPart
    end

    WeatherGroup:AddToggle('RainEnabled', {
        Text = 'Rain',
        Default = false,
        Callback = function(Value)
            RainSettings.Enabled = Value

            if Value then
                rainParticleEmitter()

                rainConnection = NewConnection(RunService.Heartbeat, function()
                    local camPos = Camera.CFrame.Position

                    rainPart.CFrame = CFrame.new(camPos + Vector3.new(0, 30, 0))
                end)
            else
                if rainConnection then
                    rainConnection:Disconnect()

                    rainConnection = nil
                end
                if rainPart then
                    rainPart:Destroy()

                    rainPart = nil
                    rainEmitter = nil
                end
            end
        end,
    }):AddColorPicker('RainColor', {
        Default = RainSettings.Color,
        Title = 'Rain Color',
        Callback = function(Value)
            RainSettings.Color = Value

            if RainSettings.Enabled then
                rainParticleEmitter()
            end
        end,
    })
    WeatherGroup:AddInput('RainLifetime', {
        Default = tostring(RainSettings.Lifetime),
        Numeric = true,
        Finished = true,
        Text = 'Lifetime',
        Callback = function(Value)
            local num = tonumber(Value)

            if num then
                RainSettings.Lifetime = num

                if RainSettings.Enabled then
                    rainParticleEmitter()
                end
            end
        end,
    })
    WeatherGroup:AddSlider('RainRate', {
        Text = 'Amount',
        Default = RainSettings.Rate,
        Min = 1,
        Max = 10000,
        Rounding = 0,
        Callback = function(Value)
            RainSettings.Rate = Value

            if RainSettings.Enabled then
                rainParticleEmitter()
            end
        end,
    })
    WeatherGroup:AddSlider('RainSpeed', {
        Text = 'Speed',
        Default = RainSettings.Speed,
        Min = 10,
        Max = 1000,
        Rounding = 0,
        Callback = function(Value)
            RainSettings.Speed = Value

            if RainSettings.Enabled then
                rainParticleEmitter()
            end
        end,
    })
    WeatherGroup:AddToggle('SnowEnabled', {
        Text = 'Snow Enabled',
        Default = false,
        Callback = function(Value)
            SnowSettings.Enabled = Value

            if Value then
                snowParticleEmitter()

                snowConnection = NewConnection(RunService.Heartbeat, function()
                    local camPos = Camera.CFrame.Position

                    snowPart.CFrame = CFrame.new(camPos + Vector3.new(0, 5, 0))
                end)
            else
                if snowConnection then
                    snowConnection:Disconnect()

                    snowConnection = nil
                end
                if snowPart then
                    snowPart:Destroy()

                    snowPart = nil
                    snowEmitter = nil
                end
            end
        end,
    }):AddColorPicker('SnowColor', {
        Default = SnowSettings.Color,
        Title = 'Snow Color',
        Callback = function(Value)
            SnowSettings.Color = Value

            if SnowSettings.Enabled then
                snowParticleEmitter()
            end
        end,
    })
    WeatherGroup:AddSlider('SnowRate', {
        Text = 'Snow Amount',
        Default = SnowSettings.Rate,
        Min = 1,
        Max = 1000,
        Rounding = 0,
        Callback = function(Value)
            SnowSettings.Rate = Value

            if SnowSettings.Enabled then
                snowParticleEmitter()
            end
        end,
    })
    WeatherGroup:AddSlider('SnowSpeed', {
        Text = 'Snow Speed',
        Default = SnowSettings.Speed,
        Min = 1,
        Max = 1000,
        Rounding = 0,
        Callback = function(Value)
            SnowSettings.Speed = Value

            if SnowSettings.Enabled then
                snowParticleEmitter()
            end
        end,
    })

    DYHUBcc.Movement = {
        Speed = {
            Enabled = false,
            Keybind = false,
            Speed = 20,
        },
        Fly = {
            Enabled = false,
            Keybind = false,
            Speed = 20,
        },
    }

    MovementGroup:AddToggle('SpeedEnabled', {
        Text = 'Speed Enabled',
        Default = false,
        Callback = function(Value)
            DYHUBcc.Movement.Speed.Enabled = Value
        end,
    }):AddKeyPicker('SpeedKey', {
        Default = 'none',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Speed Key',
        Callback = function() end,
    })
    MovementGroup:AddSlider('SpeedValue', {
        Text = 'Speed',
        Default = 20,
        Min = 1,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            DYHUBcc.Movement.Speed.Speed = Value
        end,
    })
    MovementGroup:AddToggle('FlyEnabled', {
        Text = 'Fly Cframe',
        Default = false,
        Callback = function(Value)
            DYHUBcc.Movement.Fly.Enabled = Value
        end,
    }):AddKeyPicker('FlyKey', {
        Default = 'none',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Fly Key',
        Callback = function(Value)
            DYHUBcc.Movement.Fly.Keybind = Value
        end,
    })
    MovementGroup:AddSlider('FlySpeed', {
        Text = 'Fly Speed',
        Default = 20,
        Min = 1,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            DYHUBcc.Movement.Fly.Speed = Value
        end,
    })

    getgenv().FlySpeed = 150
    getgenv().FlightEnabled = false
    getgenv().Flying = false

    local IdleAnim = Instance.new('Animation')

    IdleAnim.AnimationId = 'rbxassetid://3541114300'

    local IdleTrack, FlyTrack
    local FlyAnim = Instance.new('Animation')

    FlyAnim.AnimationId = 'rbxassetid://3541044388'

    local function CreateCore()
        if workspace:FindFirstChild('Core') then
            workspace.Core:Destroy()
        end

        local Core = Instance.new('Part')

        Core.Name = 'Core'
        Core.Size = Vector3.new(0.05, 0.05, 0.05)
        Core.CanCollide = false
        Core.Transparency = 1
        Core.Parent = workspace

        local Weld = Instance.new('Weld', Core)

        Weld.Part0 = Core
        Weld.Part1 = localPlayer.Character.HumanoidRootPart
        Weld.C0 = CFrame.new(0, 0, 0)

        return Core
    end

    local currentMove = Vector3.zero

    local function IsMoving()
        return currentMove.Magnitude > 0.1
    end
    local function StartFly()
        if getgenv().Flying or not localPlayer.Character or not localPlayer.Character:FindFirstChild('HumanoidRootPart') then
            return
        end

        getgenv().Flying = true

        local hum = localPlayer.Character:FindFirstChildOfClass('Humanoid')

        hum.PlatformStand = true
        IdleTrack = hum:LoadAnimation(IdleAnim)
        FlyTrack = hum:LoadAnimation(FlyAnim)

        IdleTrack:Play()

        local Core = CreateCore()
        local BV = Instance.new('BodyVelocity', Core)

        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BV.Velocity = Vector3.zero

        local BG = Instance.new('BodyGyro', Core)

        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.P = 9e4
        BG.CFrame = Core.CFrame

        local connection

        connection = RunService.RenderStepped:Connect(function()
            if not getgenv().Flying then
                connection:Disconnect()

                return
            end

            local camera = Camera

            currentMove = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                currentMove += camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                currentMove -= camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                currentMove -= camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                currentMove += camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                currentMove += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                currentMove -= Vector3.new(0, 1, 0)
            end

            BV.Velocity = currentMove * getgenv().FlySpeed
            BG.CFrame = camera.CFrame

            if IsMoving() then
                if IdleTrack.IsPlaying then
                    IdleTrack:Stop()
                end
                if not FlyTrack.IsPlaying then
                    FlyTrack:Play()
                end
            else
                if FlyTrack.IsPlaying then
                    FlyTrack:Stop()
                end
                if not IdleTrack.IsPlaying then
                    IdleTrack:Play()
                end
            end
        end)
    end
    local function StopFly()
        if not getgenv().Flying then
            return
        end

        getgenv().Flying = false

        local hum = localPlayer.Character:FindFirstChildOfClass('Humanoid')

        hum.PlatformStand = false

        if IdleTrack then
            IdleTrack:Stop()
        end
        if FlyTrack then
            FlyTrack:Stop()
        end
        if workspace:FindFirstChild('Core') then
            workspace.Core:Destroy()
        end
    end

    MovementGroup:AddToggle('FlightV2_Enabled', {
        Text = 'Fly Velocity + superhero',
        Default = false,
        Callback = function(value)
            getgenv().FlightEnabled = value

            if not value then
                StopFly()
            end
        end,
    }):AddKeyPicker('FlightV2_Keybind', {
        Default = 'none',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Fly V2 Keybind',
        Callback = function(state)
            if UserInputService:GetFocusedTextBox() then
                return
            end
            if state and getgenv().FlightEnabled then
                StartFly()
            else
                StopFly()
            end
        end,
    })
    MovementGroup:AddSlider('FlightV2_Speed', {
        Text = 'Fly Speed',
        Default = 150,
        Min = 10,
        Max = 1000,
        Rounding = 0,
        Callback = function(value)
            getgenv().FlySpeed = value
        end,
    })
    localPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        StopFly()

        if getgenv().FlightEnabled then
            task.wait(2)

            if getgenv().FlightEnabled then
                StartFly()
            end
        end
    end)

    getgenv().walkSpeedEnabled = false
    getgenv().walkSpeed = 100

    MovementGroup:AddToggle('WalkSpeedToggle', {
        Text = 'Boost walk and jump',
        Default = false,
        Callback = function(state)
            getgenv().walkSpeedEnabled = state
        end,
    }):AddKeyPicker('WalkSpeedKeybind', {
        Default = 'T',
        Text = 'Velocity',
        Mode = 'Toggle',
        Callback = function(state)
            if game:GetService('UserInputService'):GetFocusedTextBox() then
                return
            end
            getgenv().walkSpeedEnabled = state
        end,
    })
    MovementGroup:AddSlider('WalkSpeedSlider', {
        Text = 'WalkSpeed',
        Default = 100,
        Min = 16,
        Max = 500,
        Rounding = 0,
        Callback = function(value)
            getgenv().walkSpeed = value
        end,
    })
    MovementGroup:AddSlider('JumpPowerSlider', {
        Text = 'Power',
        Default = 50,
        Min = 1,
        Max = 1000,
        Rounding = 0,
        Callback = function(Value)
            DYHUBcc.Movement.JumpPower = Value
        end,
    })

    getgenv().DYHUB.BunnyHop = {
        Enabled = false,
        Keybind = false,
        Speed = 100,
    }

    MovementGroup:AddToggle('BunnyHop_Enabled', {
        Text = 'Bunny Hop',
        Default = false,
        Callback = function(value)
            getgenv().DYHUB.BunnyHop.Enabled = value
        end,
    }):AddKeyPicker('BunnyHop_Keybind', {
        Default = 'None',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Bunny Hop Keybind',
        Callback = function(state)
            getgenv().DYHUB.BunnyHop.Keybind = state
        end,
    })
    MovementGroup:AddSlider('BunnyHop_Speed', {
        Text = 'Bunny Hop Speed',
        Default = 100,
        Min = 1,
        Max = 200,
        Rounding = 1,
        Callback = function(value)
            getgenv().DYHUB.BunnyHop.Speed = value
        end,
    })
    RunService.RenderStepped:Connect(function()
        if getgenv().DYHUB.BunnyHop.Enabled or getgenv().DYHUB.BunnyHop.Keybind then
            if localPlayer.Character or localPlayer.Character:FindFirstChild('Humanoid') or localPlayer.Character:FindFirstChild('HumanoidRootPart') then
                local hum = localPlayer.Character:FindFirstChildOfClass('Humanoid')
                local hrp = localPlayer.Character.HumanoidRootPart
                local camera = Camera

                if UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial ~= Enum.Material.Air then
                    hum.Jump = true

                    local look = camera.CFrame.LookVector * Vector3.new(1, 0, 1)
                    local move = Vector3.zero

                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        move += look
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        move -= look
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        move += Vector3.new(-look.Z, 0, look.X)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        move += Vector3.new(look.Z, 0, -look.X)
                    end
                    if move.Magnitude > 0 then
                        local speed = getgenv().DYHUB.BunnyHop.Speed

                        hrp.Velocity = Vector3.new(move.Unit.X * speed, hrp.Velocity.Y, move.Unit.Z * speed)
                    end
                end
            end
        end
    end)

    getgenv().DYHUB.SpinBot = {
        Enabled = false,
        Speed = 20,
    }

    MovementGroup:AddToggle('SpinBot_Enabled', {
        Text = 'SpinBot',
        Default = false,
        Callback = function(value)
            getgenv().DYHUB.SpinBot.Enabled = value
        end,
    }):AddKeyPicker('SpinBot_Keybind', {
        Default = 'none',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'SpinBot Keybind',
    })
    MovementGroup:AddSlider('SpinBot_Speed', {
        Text = 'Spin Speed',
        Default = 20,
        Min = 1,
        Max = 100,
        Rounding = 0,
        Callback = function(value)
            getgenv().DYHUB.SpinBot.Speed = value
        end,
    })

    local MacroGroup = Tabs.Character:AddLeftGroupbox('Fake Macro')

    player = game.Players.LocalPlayer
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild('Humanoid')
    emoteId = 'rbxassetid://3189777795'
    maxSpeed = 300
    baseSpeed = 16
    speedIncrement = 1.75
    emoteDuration = 1.6
    currentSpeed = baseSpeed
    isSpeedEnabled = false
    emoteTrack = nil
    isSpeedReady = false
    Keybind = Enum.KeyCode.Q
    UserInputService = game:GetService('UserInputService')
    RunService = game:GetService('RunService')

    function initializeCharacter(newCharacter)
        character = newCharacter or player.Character
        humanoid = character:WaitForChild('Humanoid')
        currentSpeed = baseSpeed
        humanoid.WalkSpeed = baseSpeed
        isSpeedEnabled = false
        isSpeedReady = false
    end
    function playEmote()
        animation = Instance.new('Animation')
        animation.AnimationId = emoteId
        emoteTrack = humanoid:LoadAnimation(animation)

        emoteTrack:Play()
        task.wait(emoteDuration)

        if emoteTrack and emoteTrack.IsPlaying then
            emoteTrack:Stop()
        end

        isSpeedReady = true
    end
    function updateSpeed()
        if _G.ScriptEnabled and isSpeedEnabled then
            if isSpeedReady then
                currentSpeed = math.min(currentSpeed + speedIncrement, maxSpeed)
                humanoid.WalkSpeed = currentSpeed
            else
                humanoid.WalkSpeed = baseSpeed
            end
        elseif not isSpeedEnabled or not _G.ScriptEnabled then
            humanoid.WalkSpeed = baseSpeed
            currentSpeed = baseSpeed
        end
    end
    function toggleSpeedFeature()
        if not _G.ScriptEnabled then
            return
        end

        isSpeedEnabled = not isSpeedEnabled

        if isSpeedEnabled then
            currentSpeed = baseSpeed
            humanoid.WalkSpeed = baseSpeed
            isSpeedReady = false

            playEmote()
        else
            currentSpeed = baseSpeed
            humanoid.WalkSpeed = baseSpeed
            isSpeedReady = false
        end
    end

    player.CharacterAdded:Connect(initializeCharacter)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if _G.ScriptEnabled and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Keybind then
            toggleSpeedFeature()
        end
    end)
    RunService.Heartbeat:Connect(updateSpeed)
    initializeCharacter(character)
    MacroGroup:AddToggle('MyToggle', {
        Text = 'Fake Macro',
        Default = false,
        Tooltip = 'This is a tooltip',
        Callback = function(Value)
            if Value then
                _G.ScriptEnabled = true
            else
                _G.ScriptEnabled = false
            end
        end,
    }):AddKeyPicker('KeyPicker', {
        Default = 'Q',
        SyncToggleState = false,
        Mode = 'Toggle',
        Text = 'Speed Toggle Keybind',
        Callback = function(Value) end,
        ChangedCallback = function(New)
            Keybind = New
        end,
    })
    MacroGroup:AddSlider('EmoteDuration', {
        Text = 'Emote Duration (Seconds)',
        Default = 1.6,
        Min = 0,
        Max = 2.5,
        Rounding = 2,
        Compact = false,
        Callback = function(Value)
            emoteDuration = Value
        end,
    })
    MacroGroup:AddSlider('MaxSpeed', {
        Text = 'Max Speed',
        Default = 300,
        Min = 16,
        Max = 1000,
        Rounding = 0,
        Compact = false,
        Callback = function(Value)
            print('[cb] Max Speed changed! New value:', Value)

            maxSpeed = Value
        end,
    })
    MacroGroup:AddSlider('SpeedIncrement', {
        Text = 'Speed Increment',
        Default = 1.75,
        Min = 0.1,
        Max = 10,
        Rounding = 2,
        Compact = false,
        Callback = function(Value)
            print('[cb] Speed Increment changed! New value:', Value)

            speedIncrement = Value
        end,
    })
    NewConnection(RunService.Heartbeat, function(dt)
        if not getgenv().DYHUB.SpinBot.Enabled then
            local character = localPlayer.Character

            if character and character:FindFirstChild('Humanoid') then
                character.Humanoid.AutoRotate = true
            end

            return
        end

        local character = localPlayer.Character

        if not character then
            return
        end

        local humanoid = character:FindFirstChild('Humanoid')
        local hrp = character:FindFirstChild('HumanoidRootPart')

        if not hrp or not humanoid then
            return
        end

        humanoid.AutoRotate = false

        local spinSpeed = getgenv().DYHUB.SpinBot.Speed or 300

        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
    end)
    game:GetService('RunService').RenderStepped:Connect(function()
        if not getgenv().walkSpeedEnabled then return end
        local player = game.Players.LocalPlayer
        local humanoid = player.Character and player.Character:FindFirstChild('Humanoid')

        if not humanoid then
            return
        end
        humanoid.WalkSpeed = getgenv().walkSpeed or 16
        humanoid.JumpPower = DYHUBcc.Movement.JumpPower or 50
    end)

    if UserInputService.TouchEnabled then
        local wsGui = Instance.new('ScreenGui')

        wsGui.Name = 'MobileWalkSpeedButton'
        wsGui.ResetOnSpawn = false
        wsGui.Parent = game.CoreGui

        local wsBtn = Instance.new('TextButton')

        wsBtn.Size = UDim2.new(0, 110, 0, 40)
        wsBtn.Position = UDim2.new(0.5, -70, 0.7, -20)
        wsBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        wsBtn.BackgroundColor3 = Color3.fromRGB(156, 186, 140)
        wsBtn.TextColor3 = Color3.new(1, 1, 1)
        wsBtn.Font = Enum.Font.GothamBold
        wsBtn.TextSize = 16
        wsBtn.Parent = wsGui

        local corner = Instance.new('UICorner', wsBtn)

        corner.CornerRadius = UDim.new(0, 12)

        local stroke = Instance.new('UIStroke', wsBtn)

        stroke.Color = Color3.fromRGB(130, 160, 114)
        stroke.Thickness = 2
        stroke.Transparency = 0.5

        local function updateButton()
            if getgenv().walkSpeedEnabled then
                wsBtn.Text = 'WalkSpeed ON (' .. getgenv().walkSpeed .. ')'
                wsBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
            else
                wsBtn.Text = 'WalkSpeed OFF'
                wsBtn.BackgroundColor3 = Color3.fromRGB(156, 186, 140)
            end
        end

        updateButton()
        makeDraggable(wsBtn)
        wsBtn.MouseButton1Click:Connect(function()
            getgenv().walkSpeedEnabled = not getgenv().walkSpeedEnabled

            updateButton()
        end)
        spawn(function()
            while wsGui.Parent do
                updateButton()
                task.wait(0.5)
            end
        end)
    end

    localPlayer.CharacterAdded:Connect(function(char)
        StopFly()
        task.wait(1)

        if DYHUBcc.Movement.FlyEnabled then
            StartFly()
        end
    end)
    NewConnection(RunService.Heartbeat, function(dt)
        if DYHUBcc.Movement.Speed.Enabled then
            if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart') then
                local move_direction = localPlayer.Character.Humanoid.MoveDirection
                local hrp = localPlayer.Character.HumanoidRootPart

                hrp.CFrame = hrp.CFrame + (move_direction * dt) * DYHUBcc.Movement.Speed.Speed * 8
            end
        end
        if DYHUBcc.Movement.Fly.Enabled and DYHUBcc.Movement.Fly.Keybind then
            if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart') then
                local move_direction = localPlayer.Character.Humanoid.MoveDirection
                local hrp = localPlayer.Character.HumanoidRootPart
                local add = Vector3.new(0, (UserInputService:IsKeyDown(Enum.KeyCode.Space) and DYHUBcc.Movement.Fly.Speed / 8 or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -DYHUBcc.Movement.Fly.Speed / 8) or 0, 0)

                hrp.CFrame = hrp.CFrame + (move_direction * dt) * DYHUBcc.Movement.Fly.Speed * 8
                hrp.CFrame = hrp.CFrame + add
                hrp.Velocity = (hrp.Velocity * Vector3.new(1, 0, 1)) + Vector3.new(0, 1.9, 0)
            end
        end
    end)
end)()
task.wait(1)
coroutine.wrap(function()
    local ShopTable = {}

    local function BuildShopTable()
        ShopTable = {}

        local shopFolder = workspace:WaitForChild('Ignored'):WaitForChild('Shop')

        for _, shop in pairs(shopFolder:GetChildren())do
            if shop:FindFirstChild('Head') then
                local head = shop.Head
                local shopName = shop.Name
                local gui = head:FindFirstChildWhichIsA('BillboardGui') or head:FindFirstChildWhichIsA('SurfaceGui')

                if gui then
                    local textLabel = gui:FindFirstChildWhichIsA('TextLabel')

                    if textLabel and textLabel.Text ~= '' then
                        shopName = textLabel.Text
                    end
                end
                if head:FindFirstChildWhichIsA('TextLabel') then
                    shopName = head:FindFirstChildWhichIsA('TextLabel').Text
                end

                local key = shopName:match('^(%[.-%])')

                if key then
                    local ammoKey = shopName:match('(%[.-%sAmmo%])')

                    if ammoKey then
                        key = ammoKey
                    end

                    ShopTable[key] = {ShopName = shopName}
                else
                    ShopTable[shopName] = {ShopName = shopName}
                end
            end
        end
    end

    BuildShopTable()
    spawn(function()
        while wait(30) do
            BuildShopTable()
        end
    end)

    local headshots = {}

    headshots.AutoLoadout = {
        Enabled = false,
        Guns = {},
        Queue = {},
        CurrentBuying = nil,
    }

    local Mouse = LocalPlayer:GetMouse()
    local Stats = game:GetService('Stats')
    local PingPredTable = {
        [50] = 0.1433,
        [55] = 0.1412,
        [60] = 0.1389,
        [65] = 0.1367,
        [70] = 0.1346,
        [75] = 0.1324,
        [80] = 0.1303,
        [85] = 0.1282,
        [90] = 0.1261,
        [95] = 0.124,
        [100] = 0.1219,
        [105] = 0.1198,
        [110] = 0.1177,
        [115] = 0.1157,
        [120] = 0.1136,
        [125] = 0.1116,
        [130] = 0.1095,
        [135] = 0.1075,
        [140] = 0.1055,
        [145] = 0.1035,
        [150] = 0.1015,
        [155] = 0.0995,
        [160] = 0.0975,
        [165] = 0.0956,
        [170] = 0.0936,
        [175] = 0.0917,
        [180] = 0.0897,
        [185] = 0.0878,
        [190] = 0.0859,
        [195] = 0.084,
        [200] = 0.0821,
        [205] = 0.0802,
        [210] = 0.0783,
        [215] = 0.0765,
        [220] = 0.0746,
        [225] = 0.0728,
        [230] = 0.071,
        [235] = 0.0692,
        [240] = 0.0674,
        [245] = 0.0656,
        [250] = 0.0638,
        [255] = 0.062,
        [260] = 0.0603,
        [265] = 0.0585,
        [270] = 0.0568,
        [275] = 0.0551,
        [280] = 0.0534,
        [285] = 0.0517,
        [290] = 0.05,
    }
    local currentPred = 0

    task.spawn(function()
        while true do
            local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue()
            local closest = 100
            local minDiff = math.huge

            for p, _ in pairs(PingPredTable)do
                local diff = math.abs(p - ping)

                if diff < minDiff then
                    minDiff = diff
                    closest = p
                end
            end

            currentPred = PingPredTable[closest] or 0.13

            task.wait(0.3)
        end
    end)

    local VelocityTracker = {}

    NewConnection(RunService.Heartbeat, function(dt)
        if dt > 0.5 then
            return
        end

        for _, plr in Players:GetPlayers()do
            if plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') then
                local hrp = plr.Character.HumanoidRootPart

                if not VelocityTracker[plr] then
                    VelocityTracker[plr] = {
                        PreviousPos = hrp.Position,
                        PreviousTime = tick(),
                    }
                end

                local track = VelocityTracker[plr]
                local velocity = (hrp.Position - track.PreviousPos) / (tick() - track.PreviousTime)

                track.Velocity = velocity
                track.PreviousPos = hrp.Position
                track.PreviousTime = tick()
            end
        end
    end)
    RunService.Heartbeat:Connect(function(delta)
        if not DYHUBcc.TargetAim.Enabled or DYHUBcc.TargetAim.Target == 'None' then
            DotCircle.Visible = false

            return
        end

        local targetPlayer = Players:FindFirstChild(DYHUBcc.TargetAim.Target)

        if not targetPlayer or not targetPlayer.Character then
            DotCircle.Visible = false

            return
        end

        local character = targetPlayer.Character
        local hitPart = character:FindFirstChild(DYHUBcc.TargetAim.HitPart)
        local hrp = character:FindFirstChild('HumanoidRootPart')

        if not hitPart or not hrp then
            DotCircle.Visible = false

            return
        end

        local resolvedVelocity = hrp.AssemblyLinearVelocity

        if DYHUBcc.TargetAim.Resolver then
            local lastPos = oldVelPos[targetPlayer]

            if lastPos then
                resolvedVelocity = (hrp.Position - lastPos) / math.max(delta, 4.166666666666667E-3)
            end

            oldVelPos[targetPlayer] = hrp.Position
        end

        local predictVal = DYHUBcc.TargetAim.AutoPredict and (Stats.Network.ServerStatsItem['Data Ping']:GetValue() / 1000 + 0.035) or DYHUBcc.TargetAim.Prediction
        local predictedPos = hitPart.Position + resolvedVelocity * predictVal
        local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)

        if onScreen and DYHUBcc.TargetAim.DotCircle then
            DotCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
            DotCircle.Visible = true
        else
            DotCircle.Visible = false
        end
    end)

    if getnamecallmethod then
        local Meta = getrawmetatable(game)
        local backupindex = Meta.__index

        setreadonly(Meta, false)

        Meta.__index = function(t, k)
            if k:lower() == 'hit' then
                if DYHUBcc.TargetAim.Enabled and DYHUBcc.TargetAim.Target ~= 'None' and localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart') then
                    local TargetPlayer = players:FindFirstChild(DYHUBcc.TargetAim.Target)

                    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild('Head') and not TargetPlayer.Character:FindFirstChild('ForceField') then
                        if not KnockCheck(TargetPlayer) then
                            return TargetPlayer.Character.Head.CFrame
                        end
                    end
                end
            end

            return backupindex(t, k)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            M1Down = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            M1Down = false
        end
    end)

    local pingvalue = nil
    local split = nil
    local ping = nil
    local PredictionValue = nil
    local GlobalPredictionMultiplier = 0.8
    local basePredictionTable = {
        {
            ping = 130,
            value = 0.51,
        },
        {
            ping = 125,
            value = 0.49,
        },
        {
            ping = 110,
            value = 0.46,
        },
        {
            ping = 105,
            value = 0.38,
        },
        {
            ping = 90,
            value = 0.36,
        },
        {
            ping = 80,
            value = 0.34,
        },
        {
            ping = 70,
            value = 0.31,
        },
        {
            ping = 60,
            value = 0.229,
        },
        {
            ping = 50,
            value = 0.225,
        },
        {
            ping = 40,
            value = 0.256,
        },
    }
    local Flex = {
        'another round, same result\u{1f614}',
        'spectator POV unlocked \u{1f923}',
        'no stress, just hits \u{1f635}',
        'you rush, I punish \u{1f375}',
        'missed again? \u{1f602}',
        'head found \u{1f375}',
        'lolllllll\u{1f923}',
        'need change script\u{1f92d}',
    }
    local Promo1 = {
        'join gg /bxF2urQanD \u{1f375}',
        'DYHUBcc On Top\u{1f375}',
        'lose again? try DYHUB \u{1f924}',
        'cant win hvh? gg /bxF2urQanD \u{1f924}',
        'still losing? DYHUB \u{1f375}',
        'free wins at gg /bxF2urQanD \u{1f924}',
        'upgrade your game: DYHUB \u{1f375}',
        'no cheat no win? DYHUB \u{1f375}',
        'hvh made easy -> DYHUB \u{1f375}',
        'Get DYHUBcc free at gg /bxF2urQanD',
        'your fix is DYHUB \u{1f375}',
        'next round? bring DYHUB \u{1f375}',
        'download skill: DYHUB \u{1f375}',
    }
    local previousKnock = false
    local previousDead = false
    local lastTargetCharacter = nil

    players.PlayerRemoving:Connect(function(plr)
        if plr.Name == DYHUBcc.TargetAim.Target then
            Library:Notify(plr.Name .. ' left the game\u{1f923}', 3)

            DYHUBcc.TargetAim.Target = 'None'
            previousKnock = false
            previousDead = false
            lastTargetCharacter = nil
        end
    end)
    game:GetService('RunService').Stepped:Connect(function()
        pingvalue = game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValueString()
        split = string.split(pingvalue, '(')
        ping = tonumber(split[1])

        for _, data in ipairs(basePredictionTable)do
            if ping < data.ping then
                PredictionValue = data.value * GlobalPredictionMultiplier

                break
            end
        end
    end)
-- External creations (outside loop, like Symbol)
local ScreenGui = Instance.new('ScreenGui')
ScreenGui.Parent = game.CoreGui
local StatusLabel = Instance.new('TextLabel')
StatusLabel.Size = UDim2.new(1, 0, 0, 40)
StatusLabel.Position = UDim2.new(0, 0, 1, -160)
StatusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.TextSize = 16
StatusLabel.Font = Enum.Font.Code
StatusLabel.Text = ''
StatusLabel.Parent = ScreenGui

local function update_status(text)
    StatusLabel.Text = text
end

-- Get ping function like Symbol
local function getPing()
    local item = game:GetService('Stats').Network.ServerStatsItem:FindFirstChild('Data Ping')
    if item then
        local ok, v = pcall(function()
            return item:GetValueString()
        end)
        if ok and v then
            return (tonumber(v:match('%d+')) or 0) / 1000
        end
    end
    return 0
end

-- Variables outside loop (like Symbol)
local figure8Time = 0
local chaosTimer = 0
local orbitAngle = 0
local spiralAngle = 0
local jumpPhase = 0
local baitNextToggle = 0
local baitIsStrong = false
local baitInterval = math.random(1, 3)
local baitMultiplier = 2
local sliderStrafeHeight = 0

local previousPositions = {}
local customVelocities = {}
local lastTarget = nil
local t = 0
local M1Down = false
local lastHealth = nil
local ka_lastHealth = {}

-- First Heartbeat (removed StrafeEnabled logic, kept RapidFire and other)
NewConnection(RunService.Heartbeat, function(dt)
    pcall(function()
        if getnamecallmethod and DYHUBcc.RapidFire.Enabled then
            local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass('Tool')
            if tool and tool:FindFirstChild('GunScript') then
                for _, v in ipairs(getconnections(tool.Activated))do
                    local funcinfo = debug.getinfo(v.Function)
                    for i = 1, funcinfo.nups do
                        local c, n = debug.getupvalue(v.Function, i)
                        if type(c) == 'number' then
                            debug.setupvalue(v.Function, i, 0)
                        end
                    end
                end
            end
        end
        local TargetPlayer = players:FindFirstChild(DYHUBcc.TargetAim.Target)
        local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
        local SavedPosition = hrp and hrp.CFrame or CFrame.new()
        local Tool = localPlayer.Character:FindFirstChildOfClass('Tool')
        local status = ''
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild('Head') and TargetPlayer.Character:FindFirstChild('HumanoidRootPart') and hrp then
            local currentPosition = TargetPlayer.Character.Head.Position
            local lastPosition = previousPositions[TargetPlayer] or currentPosition
            local estimatedVelocity = (currentPosition - lastPosition) / dt
            local alpha = 0.5
            customVelocities[TargetPlayer] = (customVelocities[TargetPlayer] or Vector3.zero) * alpha + estimatedVelocity * (1 - alpha)
            previousPositions[TargetPlayer] = currentPosition
            local ping = getPing()
            local PredictionValue = DYHUBcc.TargetAim.AutoPredict and (ping + 0.165) or DYHUBcc.TargetAim.Prediction
            -- Removed Strafe logic here as StrafeEnabled is removed, using AutoKill instead
            local PredictedAimingPosition = currentPosition + (customVelocities[TargetPlayer] * PredictionValue)
            local args = {
                [1] = 'ShootGun',
                [2] = Tool and Tool.Handle or nil,
                [3] = Tool and Tool.Handle.Position or Vector3.zero,
                [4] = PredictedAimingPosition,
                [5] = TargetPlayer.Character.Head,
                [6] = Vector3.new(0, 0, 0),
            }
            if DYHUBcc.TargetAim.AutoFire and MainEvent then
                MainEvent:FireServer(unpack(args))
            elseif M1Down and MainEvent then
                MainEvent:FireServer(unpack(args))
            end
        end
        if DYHUBcc.TargetAim.Enabled and DYHUBcc.TargetAim.Target ~= 'None' and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild('Head') and not KnockCheck(TargetPlayer) then
            local tool = localPlayer.Character:FindFirstChildOfClass('Tool')
            if tool and not TargetPlayer.Character:FindFirstChild('ForceField') then
                if DYHUBcc.TargetAim.AutoFire then
                    local args = {
                        [1] = 'ShootGun',
                        [2] = tool.Handle,
                        [3] = tool.Handle.Position,
                        [4] = TargetPlayer.Character.Head.Position,
                        [5] = TargetPlayer.Character.Head,
                        [6] = Vector3.new(0, 0, 0),
                    }
                    if MainEvent then
                        MainEvent:FireServer(unpack(args))
                    end
                elseif M1Down then
                    if not getnamecallmethod then
                        local args = {
                            [1] = 'ShootGun',
                            [2] = tool.Handle,
                            [3] = tool.Handle.Position,
                            [4] = TargetPlayer.Character.Head.Position,
                            [5] = TargetPlayer.Character.Head,
                            [6] = Vector3.new(0, 0, 0),
                        }
                        if MainEvent then
                            MainEvent:FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end)
end)
local function GetInventoryAmmoByGun(gunName)
    local inv = LocalPlayer:FindFirstChild("DataFolder")
        and LocalPlayer.DataFolder:FindFirstChild("Inventory")

    if not inv then
        return 0
    end

    local cleanName = gunName:gsub("[%[%]]", "")
    local ammo = inv:FindFirstChild(cleanName .. " Ammo")

    return ammo and tonumber(ammo.Value) or 0
end
local function normalizeName(str)
    return string.lower(str):gsub("%s+", "")
end
local function getAmmoCount(gunName)
	local inventory = LocalPlayer.DataFolder.Inventory
	local ammo = inventory:FindFirstChild(gunName)
	if ammo then
		return tonumber(ammo.Value) or 0
	end
	return 0
end
local function HasAllSelectedGuns()
    local char = localPlayer.Character
    local backpack = localPlayer.Backpack
    if not char or not backpack then return false end

    -- duyá»‡t tá»«ng gun Ä‘Ã£ chá»n trong AutoLoadout
    for selectedGun in pairs(headshots.AutoLoadout.Guns) do
        local wanted = normalizeName(selectedGun)
        local found = false

        -- check trong Character
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = normalizeName(tool.Name)
                if string.find(toolName, wanted, 1, true) then
                    found = true
                    break
                end
            end
        end

        -- náº¿u chÆ°a tháº¥y thÃ¬ check Backpack
        if not found then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolName = normalizeName(tool.Name)
                    if string.find(toolName, wanted, 1, true) then
                        found = true
                        break
                    end
                end
            end
        end

        -- thiáº¿u 1 cÃ¢y â†’ fail ngay
        if not found then
            return false
        end
    end

    -- cÃ³ Ä‘áº§y Ä‘á»§ táº¥t cáº£
    return true
end


-- Assuming NewConnection is a custom function to connect to RunService.Heartbeat
NewConnection(RunService.Heartbeat, function(dt)
    pcall(function()
        if DYHUBcc.TargetAim.AutoKill then
            AutoKillActive = true
            if headshots.AutoLoadout.Enabled and not HasAllSelectedGuns() then
                update_status('Autokill status: Buying gun')
                return
            end
            local targetName = DYHUBcc.TargetAim.Target
            if getgenv().lastTarget ~= targetName then
                local char = localPlayer.Character
                local hrp = char and char:FindFirstChild('HumanoidRootPart')
                if hrp and SavedPosition and typeof(SavedPosition) == 'CFrame' then
                    if not getgenv()._restoringCFrame then
                        getgenv()._restoringCFrame = true
                        RunService:BindToRenderStep('RestoreCFrame', 199, function()
                            local c = localPlayer.Character
                            local r = c and c:FindFirstChild('HumanoidRootPart')
                            if r and SavedPosition and typeof(SavedPosition) == 'CFrame' then
                                r.CFrame = SavedPosition
                            end
                            RunService:UnbindFromRenderStep('RestoreCFrame')
                            getgenv()._restoringCFrame = false
                        end)
                    end
                end
                getgenv().lastTarget = targetName
            end
            if targetName ~= nil and targetName ~= 'None' then
                local Target = players:FindFirstChild(targetName)
                if Target and Target.Character and localPlayer and localPlayer.Character then
                    local humanoidRootPart = localPlayer.Character:FindFirstChild('HumanoidRootPart')
                    local head = localPlayer.Character:FindFirstChild('Head')
                    local tool = localPlayer.Character:FindFirstChildOfClass('Tool')
                    local toolHandle = tool and tool:FindFirstChild('Handle')
                    local targetHRP = Target.Character:FindFirstChild('HumanoidRootPart')
                    local targetHead = Target.Character:FindFirstChild('Head')
                    local targetHumanoid = Target.Character:FindFirstChild('Humanoid')
                    local SavedPosition = localPlayer.Character.HumanoidRootPart.CFrame
                    local displayName = Target.DisplayName
                    local username = Target.Name
                    local health = targetHumanoid and targetHumanoid.Health or 0
                    local status = ''
                    local currentPosition = targetHead.Position
                    local lastPosition = previousPositions[Target] or currentPosition
                    local estimatedVelocity = (currentPosition - lastPosition) / dt
                    local alpha = 0.5
                    customVelocities[Target] = (customVelocities[Target] or Vector3.zero) * alpha + estimatedVelocity * (1 - alpha)
                    previousPositions[Target] = currentPosition
                    local ping = getPing()
                    local velocity = customVelocities[Target] or Vector3.zero
                    local speed = velocity.Magnitude
                    local VELOCITY_THRESHOLD = 2222
                    local basePrediction = DYHUBcc.TargetAim.Prediction
                    local PredictionValue
                    if DYHUBcc.TargetAim.AutoPredict and speed <= VELOCITY_THRESHOLD then
                        local base = ping
                        local frameComp = 0.12 + math.clamp(speed / 12000, 0, 0.12)
                        local lagComp = math.clamp(ping * 0.35, 0, 0.08)
                        PredictionValue = base + frameComp + lagComp
                    else
                        PredictionValue = basePrediction
                    end
                    if humanoidRootPart and head and toolHandle and targetHRP and targetHead then
                        local flameToolName = '[Flamethrower]'
                        local hasFlame = localPlayer.Backpack:FindFirstChild(flameToolName) or localPlayer.Character:FindFirstChild(flameToolName)
                        if DYHUBcc.TargetAim.UseHackFlame and not hasFlame then
                            update_status('Need Flamethrower Gun')
                            return
                        end
                        if not KnockCheck(Target) then
                            if voidBypassEnabled then
                                local pos = Target.Character.HumanoidRootPart.CFrame.Position
                                if pos.X < -voidLimit or pos.X > voidLimit or pos.Y < -voidLimit or pos.Y > voidLimit or pos.Z < -voidLimit or pos.Z > voidLimit then
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(math.random(-500, 500), math.random(0, 500), math.random(-500, 500))
                                    status = 'Target in void(hide around map)'
                                    if DYHUBcc.TargetAim.Spoofer then
                                        RunService:BindToRenderStep('RestoreAutokill', 199, function()
                                            humanoidRootPart.CFrame = SavedPosition
                                            RunService:UnbindFromRenderStep('RestoreAutokill')
                                        end)
                                    end
                                    update_status('Name: ' .. displayName .. '(@' .. username .. ') Health: ' .. health .. ' Autokill status: ' .. status)
                                    return
                                end
                            end
                            if not Target.Character:FindFirstChild('ForceField') then
                                local v236 = tick()
                                local strafeOffset
                                local rotationCF = CFrame.new()
                                local strafeModeOption = DYHUBcc.TargetAim.StrafeMethod
                                local character = localPlayer.Character
                                local humanoid = character:FindFirstChildOfClass("Humanoid")
                                local root = humanoid and humanoid.RootPart
                                if root then
                                    if DYHUBcc.TargetAim.Autokill and DYHUBcc.TargetAim.UseHackFlame and DYHUBcc.TargetAim.Target ~= 'None' then
                                        local targetName = DYHUBcc.TargetAim.Target
                                        local Target = players:FindFirstChild(targetName)
                                        local targetChar = Target and Target.Character
                                        local targetHumanoid = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
                                        local targetRoot = targetHumanoid and targetHumanoid.RootPart
                                        if targetRoot then
                                            sethiddenproperty(root, "PhysicsRepRootPart", targetRoot)
                                        end
                                    else
                                        sethiddenproperty(root, "PhysicsRepRootPart", nil)
                                    end
                                end
                                if DYHUBcc.TargetAim.UseHackFlame then
                                    local humanoid = localPlayer.Character:FindFirstChildOfClass('Humanoid')
                                    localPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
									strafeOffset = Vector3.new(0, 15, 0)
                                else
                                    localPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
                                    if strafeModeOption == 'Orbit' then
                                        strafeOffset = Vector3.new(math.cos(tick() * 10) * 10, 0, math.sin(tick() * 10) * 10)
                                    elseif strafeModeOption == 'Randomize' then
                                        strafeOffset = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
                                    elseif strafeModeOption == 'Crazy' then
                                        targetStrafeSpeed = math.random(100, 500)
                                        targetStrafeDistance = math.random(10, 50)
                                        targetStrafeHeight = math.random(5, 40)
                                        strafeOffset = Vector3.new(math.sin(v236 * targetStrafeSpeed) * targetStrafeDistance, targetStrafeHeight, math.cos(v236 * targetStrafeSpeed) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Bait' then
                                        if baitNextToggle <= v236 then
                                            baitIsStrong = not baitIsStrong
                                            baitNextToggle = v236 + baitInterval
                                        end
                                        if baitIsStrong then
                                            targetStrafeSpeed = math.random(200, 600) * baitMultiplier
                                            targetStrafeDistance = math.random(10, 50) * baitMultiplier
                                            targetStrafeHeight = math.random(10, 40) * baitMultiplier
                                        else
                                            targetStrafeSpeed = math.random(10, 40)
                                            targetStrafeDistance = math.random(5, 20)
                                            targetStrafeHeight = sliderStrafeHeight
                                        end
                                        strafeOffset = Vector3.new(math.sin(v236 * targetStrafeSpeed) * targetStrafeDistance, targetStrafeHeight, math.cos(v236 * targetStrafeSpeed) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Hyper Spiral' then
                                        spiralAngle = spiralAngle + 0.8
                                        targetStrafeSpeed = 250 + math.random(200, 800)
                                        targetStrafeDistance = math.random(15, 50)
                                        targetStrafeHeight = 10 + spiralAngle * 0.9 % 45
                                        strafeOffset = Vector3.new(math.sin(spiralAngle) * targetStrafeDistance, targetStrafeHeight, math.cos(spiralAngle) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Chaos Orbit' then
                                        orbitAngle = orbitAngle + 0.65
                                        targetStrafeSpeed = 300 + math.random(300, 900)
                                        targetStrafeDistance = math.random(20, 50)
                                        targetStrafeHeight = math.sin(v236 * 20) * 45
                                        strafeOffset = Vector3.new(math.sin(orbitAngle) * targetStrafeDistance, targetStrafeHeight, math.cos(orbitAngle) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Death ZigZag' then
                                        chaosTimer = chaosTimer + 0.18
                                        targetStrafeSpeed = 400 + math.random(300, 900)
                                        local v245 = math.sin(chaosTimer * 45) * 55
                                        targetStrafeDistance = math.random(15, 45)
                                        targetStrafeHeight = math.random(10, 50)
                                        strafeOffset = Vector3.new(v245, targetStrafeHeight, math.random(-30, 30))
                                    elseif strafeModeOption == 'Fake Jump Pro' then
                                        jumpPhase = (jumpPhase + 0.25) % 1
                                        targetStrafeSpeed = 300 + math.random(250, 850)
                                        targetStrafeDistance = math.random(15, 48)
                                        targetStrafeHeight = jumpPhase < 0.1 and 25 + jumpPhase * 400 or math.random(5, 18)
                                        strafeOffset = Vector3.new(math.sin(v236 * 35) * targetStrafeDistance, targetStrafeHeight, math.cos(v236 * 35) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Insane Figure8' then
                                        figure8Time = figure8Time + 0.12
                                        targetStrafeSpeed = 350 + math.random(300, 900)
                                        local v243 = math.random(25, 50)
                                        local v244 = figure8Time * 14
                                        strafeOffset = Vector3.new(math.sin(v244) * v243 * 1.8, math.sin(v244 * 2) * 50, math.cos(v244) * v243)
                                    elseif strafeModeOption == 'Nuclear Blender' then
                                        spiralAngle = spiralAngle + 1.8
                                        targetStrafeSpeed = 800 + math.random(400, 1200)
                                        targetStrafeDistance = math.random(20, 65)
                                        targetStrafeHeight = math.random(10, 50)
                                        strafeOffset = Vector3.new(math.sin(spiralAngle * 5) * targetStrafeDistance, targetStrafeHeight, math.cos(spiralAngle * 5) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Demon 360' then
                                        orbitAngle = orbitAngle + 2.5
                                        targetStrafeSpeed = 1200
                                        targetStrafeDistance = 30 + math.sin(v236 * 50) * 20
                                        targetStrafeHeight = math.abs(math.sin(v236 * 45)) * 80
                                        strafeOffset = Vector3.new(math.sin(orbitAngle * 7) * targetStrafeDistance, targetStrafeHeight, math.cos(orbitAngle * 7) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Void Dancer' then
                                        local v242 = v236 * 35
                                        targetStrafeSpeed = 1200
                                        targetStrafeDistance = 40 + math.sin(v242 * 3) * 25
                                        targetStrafeHeight = math.sin(v242 * 8) * 100 - 30
                                        strafeOffset = Vector3.new(math.sin(v242) * targetStrafeDistance * 1.5, targetStrafeHeight, math.cos(v242) * targetStrafeDistance * 1.5)
                                    elseif strafeModeOption == 'Hell Spiral X' then
                                        spiralAngle = spiralAngle + 3.5
                                        targetStrafeSpeed = 1500
                                        targetStrafeDistance = 15 + spiralAngle % 50
                                        targetStrafeHeight = spiralAngle % 100 - 50
                                        strafeOffset = Vector3.new(math.sin(spiralAngle * 10) * targetStrafeDistance, targetStrafeHeight, math.cos(spiralAngle * 10) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Quantum Flicker' then
                                        local v241 = v236 * 100
                                        targetStrafeSpeed = 2000
                                        targetStrafeDistance = math.random(10, 70)
                                        targetStrafeHeight = math.random(-40, 80)
                                        strafeOffset = Vector3.new(math.sin(v241) * targetStrafeDistance, targetStrafeHeight, math.cos(v241) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Xk5 strafe' then
                                        if (v236 % 4) > 1 then
                                            targetStrafeSpeed = 1300 + math.sin(v236 * 35) * 1000
                                            targetStrafeDistance = 40 + math.sin(v236 * 45) * 30
                                            targetStrafeHeight = math.sin(v236 * 50) * 85
                                            strafeOffset = Vector3.new(math.sin(v236 * targetStrafeSpeed) * targetStrafeDistance, targetStrafeHeight, math.cos(v236 * targetStrafeSpeed) * targetStrafeDistance)
                                        else
                                            targetStrafeSpeed = 1100 + math.random(800, 1600)
                                            targetStrafeDistance = math.random(1, 4)
                                            targetStrafeHeight = -3.3
                                            strafeOffset = Vector3.new(math.sin(v236 * targetStrafeSpeed) * targetStrafeDistance, targetStrafeHeight, math.cos(v236 * targetStrafeSpeed) * targetStrafeDistance)
                                        end
                                    elseif strafeModeOption == 'Phantom Blitz' then
                                        spiralAngle = spiralAngle + 4
                                        targetStrafeSpeed = 1800 + math.random(600, 1400)
                                        targetStrafeDistance = 20 + math.sin(v236 * 60) * 30
                                        targetStrafeHeight = math.cos(spiralAngle * 5) * 90 - 20
                                        strafeOffset = Vector3.new(math.sin(spiralAngle * 12) * targetStrafeDistance, targetStrafeHeight, math.cos(spiralAngle * 12) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Oblivion Vortex' then
                                        orbitAngle = orbitAngle + 3
                                        targetStrafeSpeed = 1600 + math.random(800, 2000)
                                        targetStrafeDistance = 25 + orbitAngle % 60
                                        targetStrafeHeight = math.sin(v236 * 70) * 100
                                        strafeOffset = Vector3.new(math.sin(orbitAngle * 10) * targetStrafeDistance, targetStrafeHeight, math.cos(orbitAngle * 10) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Rift Shatter' then
                                        chaosTimer = chaosTimer + 0.3
                                        targetStrafeSpeed = 2000 + math.random(1000, 2500)
                                        targetStrafeDistance = math.random(15, 60)
                                        targetStrafeHeight = math.random(-40, 80)
                                        strafeOffset = Vector3.new(math.sin(v236 * 80) * targetStrafeDistance, targetStrafeHeight, math.cos(v236 * 80) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Eclipse Pulse' then
                                        local v240 = v236 * 90
                                        targetStrafeSpeed = 2200
                                        targetStrafeDistance = 30 + math.cos(v240 * 2) * 40
                                        targetStrafeHeight = math.sin(v240 * 6) * 150 - 50
                                        strafeOffset = Vector3.new(math.sin(v240 * 15) * targetStrafeDistance, targetStrafeHeight, math.cos(v240 * 15) * targetStrafeDistance)
                                    elseif strafeModeOption == 'Doom Weaver' then
                                        figure8Time = figure8Time + 0.2
                                        targetStrafeSpeed = 1900 + math.random(700, 2100)
                                        local v238 = math.random(30, 70)
                                        local v239 = figure8Time * 20
                                        targetStrafeHeight = math.sin(v239 * 3) * 140 + math.cos(v239 * 5) * 50
                                        strafeOffset = Vector3.new(math.sin(v239 * 2) * v238 * 2, targetStrafeHeight, math.cos(v239 * 2) * v238)
                                    end
                                end
                                local desyncPosition = currentPosition + (customVelocities[Target] * PredictionValue) + strafeOffset
                                local cf = CFrame.lookAt(desyncPosition, currentPosition)
								if DYHUBcc.TargetAim.UseHackFlame then
									cff = cf * CFrame.Angles(0, 0, math.rad(90))
								else
                                    cff = cf
								end
								humanoidRootPart.CFrame = cff
                                status = 'Shooting Target'
                                if not DYHUBcc.TargetAim.UseHackFlame then
                                    local PredictedAimingPosition = currentPosition + (customVelocities[Target] * PredictionValue)
                                    MainEvent:FireServer('ShootGun', toolHandle, toolHandle.Position, PredictedAimingPosition, targetHead, Vector3.new(0, 1, 0))
                                else
                                    if tool then
                                        tool:Activate()
                                    end
                                end
                            else
                                humanoidRootPart.CFrame += Vector3.new(math.random(-7777553, 7777553), math.random(0, 7777553), math.random(-7777553, 7777553))
                                status = 'Waiting.. Target has spawn protection'
                                MainEvent:FireServer('Reload', tool)
                            end
                            if DYHUBcc.TargetAim.Spoofer then
                                RunService:BindToRenderStep('RestoreAutokill', 199, function()
                                    humanoidRootPart.CFrame = SavedPosition
                                    RunService:UnbindFromRenderStep('RestoreAutokill')
                                end)
                            end
                            if DYHUBcc.TargetAim.VisualizeStrafe then
                                BodyClone:SetPrimaryPartCFrame(humanoidRootPart.CFrame)
                                BodyCloneHighlight.Enabled = true
                                SetRigTransparency(BodyClone, 0)
                                SetRigColor(BodyClone, DYHUBcc.TargetAim.VisualizeStrafeInlineColor)
                                BodyCloneHighlight.FillColor = DYHUBcc.TargetAim.VisualizeStrafeInlineColor
                                BodyCloneHighlight.OutlineColor = DYHUBcc.TargetAim.VisualizeStrafeOutlineColor
                            else
                                BodyCloneHighlight.Enabled = false
                                BodyClone:SetPrimaryPartCFrame(CFrame.new(9999, 9999, 9999))
                                SetRigTransparency(BodyClone, 1)
                            end
                        else
                            local bodyEffects = Target.Character:FindFirstChild('BodyEffects')
                            local isDead = bodyEffects and bodyEffects:FindFirstChild('SDeath') and bodyEffects.SDeath.Value
                            if isDead == false then
                                if Target.Character:FindFirstChild('UpperTorso') and Target.Character:FindFirstChild('HumanoidRootPart') and Target.Character:FindFirstChild('Humanoid') then
                                    humanoidRootPart.CFrame = CFrame.new(Target.Character.UpperTorso.Position + Vector3.new(0, 3, 0))
                                    status = 'Stomping Target'
                                    MainEvent:FireServer('Stomp')
                                end
                            elseif isDead == true then
                                humanoidRootPart.CFrame += Vector3.new(math.random(-7777553, 7777553), math.random(0, 7777553), math.random(-7777553, 7777553))
                                status = 'Waiting.. Target is currently dead'
                                MainEvent:FireServer('Reload', tool)
                            end
                            if DYHUBcc.TargetAim.Spoofer then
                                RunService:BindToRenderStep('RestoreAutokill', 199, function()
                                    humanoidRootPart.CFrame = SavedPosition
                                    RunService:UnbindFromRenderStep('RestoreAutokill')
                                end)
                            end
                            if DYHUBcc.TargetAim.VisualizeStrafe then
                                BodyClone:SetPrimaryPartCFrame(humanoidRootPart.CFrame)
                                BodyCloneHighlight.Enabled = true
                                SetRigTransparency(BodyClone, 0)
                                SetRigColor(BodyClone, DYHUBcc.TargetAim.VisualizeStrafeInlineColor)
                                BodyCloneHighlight.FillColor = DYHUBcc.TargetAim.VisualizeStrafeInlineColor
                                BodyCloneHighlight.OutlineColor = DYHUBcc.TargetAim.VisualizeStrafeOutlineColor
                            else
                                BodyCloneHighlight.Enabled = false
                                BodyClone:SetPrimaryPartCFrame(CFrame.new(9999, 9999, 9999))
                                SetRigTransparency(BodyClone, 1)
                            end
                        end
                    else
                        if DYHUBcc.TargetAim.UseHackFlame then
                            local character = localPlayer.Character
                            local humanoid = character and character:FindFirstChildOfClass('Humanoid')
                            local Backpack = localPlayer.Backpack
                            if character and Backpack and humanoid and humanoid.Health > 0 then
                                local flameToolName = '[Flamethrower]'
                                local flameTool = Backpack:FindFirstChild(flameToolName)
                                if flameTool and not character:FindFirstChild(flameToolName) then
                                    flameTool.Parent = character
                                end
                                for _, tool in pairs(character:GetChildren())do
                                    if tool:IsA('Tool') then
                                        tool:Activate()
                                    end
                                end
                                for _, tool in ipairs(character:GetChildren())do
                                    if tool:IsA('Tool') and tool.Name ~= flameToolName then
                                        tool.Parent = Backpack
                                    end
                                end
                            end
                            status = 'Auto equipping Flamethrower'
                        else
                            localPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
                            equipAllGuns()
                            status = 'Auto equipping all guns with ammo'
                            for _, equippedTool in ipairs(localPlayer.Character:GetChildren())do
                                if equippedTool:IsA('Tool') and equippedTool:FindFirstChild('Ammo') and equippedTool.Ammo.Value <= 0 then
                                    MainEvent:FireServer('Reload', equippedTool)
                                    status = status .. ' Reloading ' .. equippedTool.Name
                                end
                            end
                        end
                        humanoidRootPart.CFrame += Vector3.new(math.random(-777, 777), math.random(0, 777), math.random(-777, 777))
                        if DYHUBcc.TargetAim.Spoofer then
                            RunService:BindToRenderStep('RestoreHide', 199, function()
                                humanoidRootPart.CFrame = SavedPosition
                                RunService:UnbindFromRenderStep('RestoreHide')
                            end)
                            if DYHUBcc.TargetAim.VisualizeStrafe then
                                BodyClone:SetPrimaryPartCFrame(humanoidRootPart.CFrame)
                                BodyCloneHighlight.Enabled = true
                                SetRigTransparency(BodyClone, 0)
                                SetRigColor(BodyClone, DYHUBcc.TargetAim.VisualizeStrafeInlineColor)
                                BodyCloneHighlight.FillColor = DYHUBcc.TargetAim.VisualizeStrafeInlineColor
                                BodyCloneHighlight.OutlineColor = DYHUBcc.TargetAim.VisualizeStrafeOutlineColor
                            else
                                BodyCloneHighlight.Enabled = false
                                BodyClone:SetPrimaryPartCFrame(CFrame.new(9999, 9999, 9999))
                                SetRigTransparency(BodyClone, 1)
                            end
                        end
                        status = status .. " Waiting.. Equip your gun while using 'Auto Kill Target'"
                    end
                    update_status('Name: ' .. displayName .. '(@' .. username .. ') Health: ' .. health .. ' Autokill status: ' .. status)
                end
            else
                update_status('')
            end
        else
            localPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            AutoKillActive = false
            BodyCloneHighlight.Enabled = false
            BodyClone:SetPrimaryPartCFrame(CFrame.new(9999, 9999, 9999))
            SetRigTransparency(BodyClone, 1)
            update_status('')
        end
    end)
end)
    local ChatVersion = TextChatService.ChatVersion
    local ChatEvent = ReplicatedStorage:FindFirstChild('DefaultChatSystemChatEvents')
    local TargetTextChannel = TextChatService.ChatInputBarConfiguration.TargetTextChannel
    local deadHandledFor = nil
    local lastDeathChatTime = 0
    local DEATH_CHAT_COOLDOWN = 3

    -- Hit batch system like Symbol
    local hitBatch = {
        queue = {},
        lastNotify = 0,
        batchTime = 0.1,  -- Batch time like Symbol
    }
	-- Hit message templates (mixed styles, no emoji)
	local hitTemplates = {
	    "Hit {targetdisplayname} for {hitdmg} damage",
	    "Direct hit on {targetname} â€” {hitdmg} damage",
	    "{localgun} hit {targetdisplayname} in the {hitpart}",
	    "Dealt {hitdmg} damage to {targetname}",
	    "Clean shot landed on {targetdisplayname} for {hitdmg} damage",
	    "{targetdisplayname} was struck in the {hitpart} for {hitdmg} damage",
	    "{targetname} took {hitdmg} damage to the {hitpart}",
	    "{localgun} connected for {hitdmg} damage",
	    "You slammed {targetdisplayname} for {hitdmg} HP",
	    "{targetname} failed to dodge â€” {hitdmg} damage",
	    "{targetdisplayname} didnâ€™t react in time ({hitdmg} damage)",
	    "{targetname} just lost {hitdmg} HP",
	    "{targetdisplayname} got clipped for {hitdmg} damage",
	    "{targetname} caught that one â€” {hitdmg} damage",
	    "{targetdisplayname} couldnâ€™t handle the shot ({hitdmg} damage)"
	}
	
	-- Function to process batch and notify (like Symbol's onHitNotify)
	local function processHitBatch()
	    local now = tick()
	    if now - hitBatch.lastNotify >= hitBatch.batchTime then
	        hitBatch.lastNotify = now
	
	        local totalDmg = 0
	        local targets = {}
	
	        for _, data in ipairs(hitBatch.queue) do
	            totalDmg = totalDmg + data.hitdmg
	
	            if not table.find(targets, data.targetname) then
	                table.insert(targets, data.targetname)
	            end
	        end
	
	        if #hitBatch.queue > 0 then
	            local lastHit = hitBatch.queue[#hitBatch.queue]
	
	            -- Pick random template
	            local msg = hitTemplates[math.random(#hitTemplates)]
	
	            -- Replace placeholders
	            msg = msg:gsub('{hitdmg}', tostring(totalDmg))
	            msg = msg:gsub('{localgun}', lastHit.localgun)
	            msg = msg:gsub('{targetlasthp}', tostring(lastHit.targetlasthp))
	            msg = msg:gsub('{hitpart}', lastHit.hitpart)
	            msg = msg:gsub('{targetname}', lastHit.targetname)
	            msg = msg:gsub('{targetdisplayname}', lastHit.targetdisplayname)
	
	            Library:Notify(
	                'DYHUB - ' .. msg,
	                DYHUBcc.HitEffects.HitNotificationsTime
	            )
	
	            hitBatch.queue = {}
	        end
	    end
	end

    NewConnection(RunService.Heartbeat, function(dt)
        AutoArmorActive = false
        AutoHealActive = false
        local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
        local Tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass('Tool')
        local SavedPosition = hrp and hrp.CFrame
        local useDesync = DYHUBcc.TargetAim.AutoStomp or DYHUBcc.KillAura.StompAura or DYHUBcc.TargetAim.AutoKill or headshots.AutoLoadout.Enabled

        -- Unified TargetPlayer fetch (optimize to avoid repeated calls)
        local TargetPlayer = (DYHUBcc.TargetAim.Target ~= 'None') and players:FindFirstChild(DYHUBcc.TargetAim.Target) or nil

        -- Process any pending hit batch (call once per frame)
        if DYHUBcc.HitEffects.HitNotifications and #hitBatch.queue > 0 then
            processHitBatch()
        end

        -- TargetAim hit detection (optimized)
        if DYHUBcc.TargetAim.Enabled and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild('Humanoid') and TargetPlayer.Character:FindFirstChild('Head') and not TargetPlayer.Character:FindFirstChild('ForceField') then
            local hum = TargetPlayer.Character.Humanoid
            local curr = math.round(hum.Health)
            local prev = previousTargetHealth[TargetPlayer.Name] or curr
            if curr < prev then
                local dmg = prev - curr
                local toolName = Tool and Tool.Name or 'Unknown'
                local hitData = {
                    hitdmg = math.floor(dmg),
                    localgun = toolName,
                    targetlasthp = math.floor(curr),
                    hitpart = 'Head',  -- Assume Head as target part; adjust if dynamic
                    targetname = TargetPlayer.Name,
                    targetdisplayname = TargetPlayer.DisplayName,
                }
                table.insert(hitBatch.queue, hitData)

                -- Other hit effects (sounds, chams, etc.)
                if DYHUBcc.HitEffects.HitSounds then
                    createHitSound()
                end
                if DYHUBcc.HitEffects.HitChams.Enabled then
                    HitChams(TargetPlayer)
                end
                if DYHUBcc.HitEffects.HitEffect.Enabled then
                    TriggerHitEffect(TargetPlayer)
                end
                if DYHUBcc.HitEffects.HitSkeleton.Enabled then
                    HitChamsSkeleton(TargetPlayer)
                end
            end
            previousTargetHealth[TargetPlayer.Name] = curr
        end

        -- KillAura section (optimized, integrated hit detection with batch)
        if DYHUBcc.KillAura.Enabled and Tool and Tool:FindFirstChild('Handle') then
            local closest = math.huge
            local ka_target = nil
            for _, player in pairs(players:GetPlayers()) do
                if player ~= localPlayer and not DYHUBcc.KillAura.Whitelist[player.Name] and player.Character and player.Character:FindFirstChild('Head') and player.Character:FindFirstChild('HumanoidRootPart') and not player.Character:FindFirstChild('GRABBING_CONSTRAINT') then
                    local bodyEffects = player.Character:FindFirstChild('BodyEffects')
                    if bodyEffects and not bodyEffects['K.O'].Value then
                        if player.Character:FindFirstChildOfClass('ForceField') then
                            continue
                        end
                        local dist = (hrp.Position - player.Character.Head.Position).Magnitude
                        if dist < closest and dist <= DYHUBcc.KillAura.Range then
                            closest = dist
                            ka_target = player
                        end
                    end
                end
            end
            if ka_target and ka_target.Character and ka_target.Character:FindFirstChild('Head') then
                if DYHUBcc.KillAura.Visualize then
                    ka_tracer.Transparency = 0
                    ka_tracer.Size = Vector3.new(0.2, 0.2, (hrp.Position - ka_target.Character.Head.Position).Magnitude)
                    ka_tracer.CFrame = CFrame.lookAt(hrp.Position, ka_target.Character.Head.Position) * CFrame.new(0, 0, -ka_tracer.Size.Z / 2)
                else
                    ka_tracer.Transparency = 1
                end
                local humanoid = ka_target.Character:FindFirstChild('Humanoid')
                if humanoid then
                    local curr = math.round(humanoid.Health)
                    local prev = ka_lastHealth[ka_target.Name] or curr
                    if curr < prev then
                        local dmg = prev - curr
                        local hitData = {
                            hitdmg = math.floor(dmg),
                            localgun = Tool.Name or 'Unknown',
                            targetlasthp = math.floor(curr),
                            hitpart = 'Head',  -- Assume
                            targetname = ka_target.Name,
                            targetdisplayname = ka_target.DisplayName,
                        }
                        table.insert(hitBatch.queue, hitData)

                        createHitSound()  -- Assuming this is hit sound
                    end
                    ka_lastHealth[ka_target.Name] = curr
                end
                local offset = DYHUBcc.KillAura.Silent and Vector3.new(0, -12, 0) or Vector3.new(0, 0, 0)
                MainEvent:FireServer('ShootGun', Tool:FindFirstChild('Handle'), Tool:FindFirstChild('Handle').CFrame.Position + offset, ka_target.Character.Head.Position + offset, ka_target.Character.Head, Vector3.new(0, 0, -1))
            else
                ka_tracer.Transparency = 1
            end
        end

        -- TargetAim.Enabled and LookAt (unchanged, optimized placement)
        if DYHUBcc.TargetAim.Enabled and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild('Head') then
            if DYHUBcc.TargetAim.LookAt then
                localPlayer.Character.Humanoid.AutoRotate = false
                localPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(localPlayer.Character.HumanoidRootPart.Position, Vector3.new(TargetPlayer.Character.HumanoidRootPart.Position.X, localPlayer.Character.HumanoidRootPart.Position.Y, TargetPlayer.Character.HumanoidRootPart.Position.Z))
            else
                localPlayer.Character.Humanoid.AutoRotate = true
            end
        else
            LocalPlayer.Character.Humanoid.AutoRotate = true
        end

        -- Target death/knock handling (unchanged)
        if TargetPlayer then
            if TargetPlayer.Character ~= lastTargetCharacter then
                previousKnock = false
                previousDead = false
                deadHandledFor = nil
            end
            lastTargetCharacter = TargetPlayer.Character
            if TargetPlayer.Character then
                local be = TargetPlayer.Character:FindFirstChild('BodyEffects')
                if be then
                    local ko = be:FindFirstChild('K.O')
                    local sdeath = be:FindFirstChild('SDeath')
                    local hum = TargetPlayer.Character:FindFirstChildOfClass('Humanoid')
                    local currentKnock = ko and ko.Value or false
                    local currentDead = (sdeath and sdeath.Value) or (hum and hum.Health <= 0) or false
                    if currentKnock and not previousKnock then
                        Library:Notify(TargetPlayer.Name .. ' knocked', 3)
                    end
                    if currentDead and not previousDead and deadHandledFor ~= TargetPlayer.Character then
                        deadHandledFor = TargetPlayer.Character
                        Library:Notify(TargetPlayer.Name .. ' died', 3)
                        if DYHUBcc.TargetAim.TrashTalk then
                            local now = os.clock()
                            if now - lastDeathChatTime >= DEATH_CHAT_COOLDOWN then
                                lastDeathChatTime = now
                                local flexMessage = Flex[math.random(#Flex)]
                                if ChatVersion == Enum.ChatVersion.LegacyChatService and ChatEvent then
                                    ChatEvent.SayMessageRequest:FireServer(flexMessage, 'All')
                                elseif TargetTextChannel then
                                    TargetTextChannel:SendAsync(flexMessage)
                                end
                                task.wait(0.25)
                                local promoMessage = Promo1[math.random(#Promo1)]
                                if ChatVersion == Enum.ChatVersion.LegacyChatService and ChatEvent then
                                    ChatEvent.SayMessageRequest:FireServer(promoMessage, 'All')
                                elseif TargetTextChannel then
                                    TargetTextChannel:SendAsync(promoMessage)
                                end
                            end
                        end
                    end
                    previousKnock = currentKnock
                    previousDead = currentDead
                end
            end
        elseif DYHUBcc.TargetAim.Target ~= 'None' then
            Library:Notify(DYHUBcc.TargetAim.Target .. ' left the game', 3)
            DYHUBcc.TargetAim.Target = 'None'
            previousKnock = false
            previousDead = false
            lastTargetCharacter = nil
            deadHandledFor = nil
        end

        -- Desync and visualize handling (unchanged)
        if not useDesync or not hrp then
            BodyClone:SetPrimaryPartCFrame(CFrame.new(9999, 9999, 9999))
            BodyCloneHighlight.Enabled = false
            DesyncLine.Visible = false
        end
        if useDesync and hrp then
            if DYHUBcc.TargetAim.AutoStomp and TargetPlayer and KnockCheck(TargetPlayer) and localPlayer.Character.BodyEffects.Reload.Value == false then
                local bodyEffects = TargetPlayer.Character:FindFirstChild('BodyEffects')
                local isDead = bodyEffects and bodyEffects:FindFirstChild('SDeath') and bodyEffects.SDeath.Value
                if isDead == false then
                    hrp.CFrame = CFrame.new(TargetPlayer.Character.UpperTorso.Position + Vector3.new(0, 3, 0))
                    RunService:BindToRenderStep('RestoreStomp', 199, function()
                        hrp.CFrame = SavedPosition
                        RunService:UnbindFromRenderStep('RestoreStomp')
                    end)
                    if DYHUBcc.HitEffects.HitNotifications then
                        if tick() - t >= 3 then
                            t = tick()
                            Library:Notify('DYHUB - Attempted to Stomp Target: ' .. TargetPlayer.Name, DYHUBcc.HitEffects.HitNotificationsTime)
                        end
                    end
                    MainEvent:FireServer('Stomp')
                end
            elseif DYHUBcc.KillAura.StompAura and not (AutoKillActive or AutoArmorActive or headshots.AutoLoadout.CurrentBuying or BuyingActive or AutoHealActive) then
                local shortestDistance = math.huge
                local stompTarget
                for _, player in pairs(players:GetPlayers()) do
                    if player ~= localPlayer and player.Character and player.Character:FindFirstChild('Head') and KnockCheck(player) and not player.Character:FindFirstChild('ForceField') then
                        local distance = (player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if distance <= DYHUBcc.KillAura.Range and distance < shortestDistance then
                            shortestDistance = distance
                            stompTarget = player
                        end
                    end
                end
                if stompTarget then
                    local bodyEffects = stompTarget.Character:FindFirstChild('BodyEffects')
                    local isDead = bodyEffects and bodyEffects:FindFirstChild('SDeath') and bodyEffects.SDeath.Value
                    if isDead == false then
                        hrp.CFrame = CFrame.new(stompTarget.Character.UpperTorso.Position + Vector3.new(0, 3, 0))
                        RunService:BindToRenderStep('RestoreStompAura', 199, function()
                            hrp.CFrame = SavedPosition
                            RunService:UnbindFromRenderStep('RestoreStompAura')
                        end)
                        MainEvent:FireServer('Stomp')
                    end
                end
            end
        end
    end)

	local function GetInventoryAmmo(gunName)
	    local inv = localPlayer:FindFirstChild('DataFolder')
	        and localPlayer.DataFolder:FindFirstChild('Inventory')
	
	    if not inv then
	        return 0
	    end
	
	    local cleanName = gunName:gsub("[%[%]]", "")
	    local ammoName = cleanName .. " Ammo"
	
	    local ammo = inv:FindFirstChild(ammoName)
	    return ammo and tonumber(ammo.Value) or 0
	end

	local function getAmmoKey(gun)
	    local name = gun:gsub("[%[%]]", "")
	    return "[" .. name .. " Ammo]"
	end
	local function cleanGunName(gun)
	    return gun:gsub("[%[%]]", "")
	end
    NewConnection(RunService.Heartbeat, function()
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild('HumanoidRootPart')

        if not char or not hrp then
            return
        end

        pcall(function()
            if headshots.AutoLoadout.Enabled then
                if not headshots.AutoLoadout.CurrentBuying then
                    if #headshots.AutoLoadout.Queue == 0 then
                        local orderedGuns = {}

                        for gun in pairs(headshots.AutoLoadout.Guns)do
                            table.insert(orderedGuns, gun)
                        end

                        table.sort(orderedGuns)

                        for _, gun in ipairs(orderedGuns)do
                            local hasGun = localPlayer.Character:FindFirstChild(gun) or localPlayer.Backpack:FindFirstChild(gun)

                            if not hasGun then
                                if ShopTable[gun] then
                                    table.insert(headshots.AutoLoadout.Queue, {
                                        type = 'gun',
                                        name = gun,
                                    })
                                end
                            else
                                local invAmmo = GetInventoryAmmo(gun)

                                if invAmmo == 0 then
                                    local ammoKey = getAmmoKey(gun)

                                    if ShopTable[ammoKey] then
                                        for i = 1, 3 do
                                            table.insert(headshots.AutoLoadout.Queue, {
                                                type = 'ammo',
                                                gun = gun,
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if #headshots.AutoLoadout.Queue > 0 then
                        headshots.AutoLoadout.CurrentBuying = table.remove(headshots.AutoLoadout.Queue, 1)
                        BuyingActive = true
                    end
                end
            end
            if headshots.AutoLoadout.CurrentBuying then
                local item = headshots.AutoLoadout.CurrentBuying
                local shopName

                if item.type == 'gun' then
                    shopName = ShopTable[item.name].ShopName
                else
                    local ammoKey = getAmmoKey(item.gun)

                    shopName = ShopTable[ammoKey].ShopName
                end

                local shop = workspace.Ignored.Shop:FindFirstChild(shopName)

                if shop and shop:FindFirstChild('Head') then
                    local saved = hrp.CFrame

                    hrp.CFrame = shop.Head.CFrame
                    hrp.Velocity = Vector3.zero
                    hrp.AssemblyLinearVelocity = Vector3.zero

                    RunService:BindToRenderStep('RestoreAutoBuy', 199, function()
                        hrp.CFrame = saved
                        RunService:UnbindFromRenderStep('RestoreAutoBuy')
                    end)

                    local tool = char:FindFirstChildOfClass('Tool')

                    if tool then
                        tool.Parent = localPlayer.Backpack
                    end

                    fireclickdetector(shop:FindFirstChildOfClass('ClickDetector'))
                end

                BuyingActive = false
                headshots.AutoLoadout.CurrentBuying = nil
            end
        end)
    end)

    if isDaHood then
        local AutoBuyGroup = Tabs.Misc:AddLeftGroupbox('AutoBuy')

        AutoBuyGroup:AddToggle('AutoBuyGunAmmo', {
            Text = 'Autobuy Gun',
            Default = false,
            Callback = function(Value)
                headshots.AutoLoadout.Enabled = Value

                if not Value then
                    headshots.AutoLoadout.Queue = {}
                    headshots.AutoLoadout.CurrentBuying = nil
                end
            end,
        })
        AutoBuyGroup:AddDropdown('AutoLoadoutGun', {
            Values = {
                '[Rifle]',
                '[LMG]',
                '[Flintlock]',
                '[AK47]',
                '[AUG]',
                '[Flamethrower]',
                '[Double-Barrel SG]',
                '[Drum-Shotgun]',
                '[DrumGun]',
                '[Glock]',
                '[P90]',
                '[RPG]',
                '[Revolver]',
                '[Silencer]',
                '[SilencerAR]',
                '[Shotgun]',
                '[SMG]',
                '[TacticalShotgun]',
                '[Taser]',
            },
            Default = {},
            Multi = true,
            Text = 'Select Guns',
            Callback = function(Value)
                headshots.AutoLoadout.Guns = Value
            end,
        })


local AutoAmmoEnabled = true
AutoBuyGroup:AddToggle('AutoAmmoEnabled', {
    Text = 'Auto Ammo',
    Default = true,
    Callback = function(Value)
        AutoAmmoEnabled = Value
    end
})
-- Logic functions (thÃªm vÃ o cuá»‘i script, trÆ°á»›c Library:Notify('Script Loaded'))
local function getCurrentGun()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        return tool.Name
    end
    return nil
end
local function getAmmoCount(gunName)
    local inventory = LocalPlayer.DataFolder.Inventory
    local ammo = inventory:FindFirstChild(gunName)
    if ammo then
        return tonumber(ammo.Value) or 0
    end
    return 0
end
local function findAmmoItemInShop(gunName)
    local ShopFolder = workspace:WaitForChild("Ignored"):WaitForChild("Shop")
    for _, item in ipairs(ShopFolder:GetChildren()) do
        if item:IsA("Model") and item:FindFirstChild("Head") and item.Name:match("%[" .. gunName:sub(2, -2) .. " Ammo%]") then -- Match pattern like "90 [AUG Ammo] - $90"
            return item
        end
    end
    return nil
end
local function buyAmmo(gunName)
    local ammoItem = findAmmoItemInShop(gunName)
    if not ammoItem then return end
   
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
   
    local SavedPositiond = hrp.CFrame
    hrp.CFrame = ammoItem.Head.CFrame
	hrp.Velocity = Vector3.zero
	hrp.AssemblyLinearVelocity = Vector3.zero
    local currentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if currentTool then
        currentTool.Parent = LocalPlayer.Backpack
    end
    local clickDetector = ammoItem:FindFirstChild("ClickDetector")
    if clickDetector then
        fireclickdetector(clickDetector)
    end
	humanoidRootPart.CFrame = SavedPositiond
    if currentTool then
        currentTool.Parent = LocalPlayer.Character
    end
end
local function checkAmmoAndBuy()
    if not AutoAmmoEnabled then return end
    local gunName = getCurrentGun()
    if not gunName then return end
    local ammoCount = getAmmoCount(gunName)
    if ammoCount <= 0 then
        -- Destroy Core/BodyVelocity náº¿u tá»“n táº¡i (tá»« code vÃ­ dá»¥)
        if Core then
            Core:Destroy()
            Core = nil
        end
        if BodyVelocity then
            BodyVelocity:Destroy()
            BodyVelocity = nil
        end
        buyAmmo(gunName)
    end
end
	-- ThÃªm vÃ o cÃ¹ng Heartbeat
	NewConnection(RunService.Heartbeat, function()
	    pcall(checkAmmoAndBuy)
	end)
        AutoBuyGroup:AddButton({
            Text = 'Buy Ammo for Guns',
            Func = function()
                local plr = game.Players.LocalPlayer
                local guns = {}

                for _, item in ipairs(plr.Backpack:GetChildren())do
                    if item:IsA('Tool') and item.Name:match('%[.*%]') then
                        local gunName = item.Name:match('%[(.*)%]')

                        if gunName and not table.find(guns, gunName) then
                            table.insert(guns, gunName)
                        end
                    end
                end

                local char = plr.Character

                if char then
                    for _, item in ipairs(char:GetChildren())do
                        if item:IsA('Tool') and item.Name:match('%[.*%]') then
                            local gunName = item.Name:match('%[(.*)%]')

                            if gunName and not table.find(guns, gunName) then
                                table.insert(guns, gunName)
                            end
                        end
                    end
                end
                if #guns == 0 then
                    return
                end

                local shopFolder = workspace.Ignored:FindFirstChild('Shop')

                if not shopFolder then
                    return
                end

                local hrp = char and char:FindFirstChild('HumanoidRootPart')

                if not hrp then
                    return
                end

                local savedPos = hrp.CFrame

                for _, gunName in ipairs(guns)do
                    local found = false

                    for _, item in ipairs(shopFolder:GetChildren())do
                        if item.Name:find(gunName .. ' Ammo') and item:FindFirstChild('ClickDetector') and item:FindFirstChild('Head') then
                            hrp.CFrame = item.Head.CFrame
                            hrp.Velocity = Vector3.zero
                            hrp.AssemblyLinearVelocity = Vector3.zero

                            task.wait(0.2)
                            fireclickdetector(item.ClickDetector)
                            RunService:BindToRenderStep('RestoreAutoBuyammo', 199, function()
                                hrp.CFrame = savedPos
                                RunService:UnbindFromRenderStep('RestoreAutoBuyammo')
                            end)
                            task.wait(0.2)

                            found = true

                            break
                        end
                    end
                end

                Library:Notify('Ammo buying complete!', 5)
            end,
        })

        getgenv().AutoHealEnabled = false
        getgenv().AutoHealThreshold = 100
        getgenv().AutoArmorEnabled = false
        getgenv().AutoArmorThreshold = 50

        AutoBuyGroup:AddToggle('AutoHeal', {
            Text = 'Auto Heal',
            Default = false,
            Tooltip = 'auto eat when low health',
            Callback = function(Value)
                getgenv().AutoHealEnabled = Value

                if Value then
                    Library:Notify('Auto Heal enabled', 5)
                else
                    Library:Notify('Auto Heal disabled', 5)
                end
            end,
        })
        AutoBuyGroup:AddSlider('AutoHealThreshold', {
            Text = 'Heal Threshold',
            Default = 99,
            Min = 1,
            Max = 99,
            Rounding = 0,
            Tooltip = 'Heal when health below this value',
            Callback = function(Value)
                getgenv().AutoHealThreshold = Value

                Library:Notify('Auto Heal threshold set to ' .. Value, 5)
            end,
        })
        AutoBuyGroup:AddToggle('AutoArmor', {
            Text = 'Auto Armor',
            Default = false,
            Tooltip = 'auto buy armor when low',
            Callback = function(Value)
                getgenv().AutoArmorEnabled = Value

                if Value then
                    Library:Notify('Auto Armor enabled', 5)
                else
                    Library:Notify('Auto Armor disabled', 5)
                end
            end,
        })
        AutoBuyGroup:AddSlider('AutoArmorThreshold', {
            Text = 'Armor Threshold',
            Default = 50,
            Min = 0,
            Max = 129,
            Rounding = 0,
            Tooltip = 'Buy armor when below this value',
            Callback = function(Value)
                getgenv().AutoArmorThreshold = Value

                Library:Notify('Auto Armor threshold set to ' .. Value, 5)
            end,
        })
        task.wait(1)

        local TacoShopModel

        do
            for _, shop in ipairs(workspace.Ignored.Shop:GetChildren())do
                if shop:IsA('Model') and shop.Name:find('%[Taco%]') then
                    TacoShopModel = shop

                    break
                end
            end
        end

        coroutine.wrap(function()
            while true do
                task.wait()
                pcall(function()
                    if not getgenv().AutoHealEnabled then
                        return
                    end
                    if AutoKillActive or AutoArmorActive or headshots.AutoLoadout.CurrentBuying or BuyingActive then
                        return
                    end

                    local character = plr.Character

                    if not character then
                        return
                    end

                    local humanoid = character:FindFirstChildOfClass('Humanoid')
                    local hrp = character:FindFirstChild('HumanoidRootPart')

                    if not humanoid or not hrp then
                        return
                    end
                    if humanoid.Health <= 0 then
                        return
                    end
                    if humanoid.Health > getgenv().AutoHealThreshold then
                        return
                    end
                    if not TacoShopModel or not TacoShopModel:FindFirstChild('Head') then
                        return
                    end

                    local SavedPosition = hrp.CFrame

                    while humanoid.Health < 100 and getgenv().AutoHealEnabled do
                        AutoHealActive = true
                        hrp.CFrame = TacoShopModel.Head.CFrame * CFrame.new(0, -3.1, 0)
                        hrp.Velocity = Vector3.zero
                        hrp.AssemblyLinearVelocity = Vector3.zero

                        RunService:BindToRenderStep('RestoreAutoHeal', 199, function()
                            hrp.CFrame = SavedPosition

                            RunService:UnbindFromRenderStep('RestoreAutoHeal')
                        end)

                        local backpack = plr.Backpack
                        local taco = backpack:FindFirstChild('[Taco]') or character:FindFirstChild('[Taco]')

                        if taco then
                            if taco.Parent == backpack then
                                taco.Parent = character
                            else
                                taco:Activate()
                            end
                        else
                            local click = TacoShopModel:FindFirstChildOfClass('ClickDetector')

                            if click then
                                fireclickdetector(click)
                            end
                        end

                        task.wait(0.05)
                    end

                    AutoHealActive = false
                end)
            end
        end)()
        task.wait(1)

        local ArmorShopModel

        do
            for _, shop in ipairs(workspace.Ignored.Shop:GetChildren())do
                if shop:IsA('Model') and shop.Name:find('Armor') then
                    if shop.Name:find('High') then
                        ArmorShopModel = shop

                        break
                    end

                    ArmorShopModel = ArmorShopModel or shop
                end
            end
        end

        coroutine.wrap(function()
            local RunService = game:GetService('RunService')

            while true do
                task.wait()
                pcall(function()
                    if not getgenv().AutoArmorEnabled then
                        return
                    end
                    if AutoKillActive or AutoHealActive or headshots.AutoLoadout.CurrentBuying or BuyingActive then
                        return
                    end

                    local character = plr.Character

                    if not character then
                        return
                    end

                    local hrp = character:FindFirstChild('HumanoidRootPart')
                    local bodyEffects = character:FindFirstChild('BodyEffects')

                    if not hrp or not bodyEffects then
                        return
                    end

                    local armor = bodyEffects:FindFirstChild('Armor')

                    if not armor then
                        return
                    end
                    if armor.Value > getgenv().AutoArmorThreshold then
                        return
                    end
                    if not ArmorShopModel or not ArmorShopModel:FindFirstChild('Head') then
                        return
                    end

                    local SavedPosition = hrp.CFrame

                    while armor.Value < 130 and getgenv().AutoArmorEnabled do
                        AutoArmorActive = true

                        local tool = character:FindFirstChildWhichIsA('Tool')

                        if tool then
                            tool.Parent = plr.Backpack
                        end

                        hrp.CFrame = ArmorShopModel.Head.CFrame * CFrame.new(0, -1.8, 0)
                        hrp.Velocity = Vector3.zero
                        hrp.AssemblyLinearVelocity = Vector3.zero

                        RunService:BindToRenderStep('RestoreAutoArmor', 199, function()
                            hrp.CFrame = SavedPosition

                            RunService:UnbindFromRenderStep('RestoreAutoArmor')
                        end)

                        local click = ArmorShopModel:FindFirstChildOfClass('ClickDetector')

                        if click then
                            fireclickdetector(click)
                        end

                        task.wait(0.05)
                    end

                    AutoArmorActive = false
                end)
            end
        end)()

        getgenv().AutoMaskEnabled = false
        getgenv().SelectedMask = 'surgeon'

        AutoBuyGroup:AddToggle('AutoMask', {
            Text = 'Auto Mask',
            Default = false,
            Tooltip = 'auto buy and use mask when needed',
            Callback = function(Value)
                getgenv().AutoMaskEnabled = Value

                if Value then
                    Library:Notify('Auto Mask enabled', 5)
                else
                    Library:Notify('Auto Mask disabled', 5)
                end
            end,
        })
        AutoBuyGroup:AddDropdown('MaskSelection', {
            Values = {
                'paint',
                'ninja',
                'surgeon',
                'riot',
                'hockey',
                'breathing',
                'skull',
                'pumpkin',
            },
            Default = 'surgeon',
            Multi = false,
            Text = 'Select Mask',
            Tooltip = 'Choose mask type',
            Callback = function(Value)
                getgenv().SelectedMask = Value

                Library:Notify('Selected mask: ' .. Value, 5)
            end,
        })

        local MaskShopTable = {}

        for _, shop in ipairs(workspace.Ignored.Shop:GetChildren())do
            if shop:IsA('Model') and shop.Name:find('Mask') then
                local maskType = shop.Name:match('%[(.- Mask)%]')

                if maskType then
                    MaskShopTable[maskType:lower()] = shop
                end
            end
        end

        local function getMaskKey()
            return tostring(getgenv().SelectedMask or ''):lower() .. ' mask'
        end

        coroutine.wrap(function()
            local RunService = game:GetService('RunService')

            while true do
                task.wait()
                pcall(function()
                    if not getgenv().AutoMaskEnabled then
                        return
                    end

                    local character = plr.Character

                    if not character then
                        return
                    end

                    local hrp = character:FindFirstChild('HumanoidRootPart')
                    local humanoid = character:FindFirstChildOfClass('Humanoid')

                    if not hrp or not humanoid or humanoid.Health <= 0 then
                        return
                    end

                    local maskKey = getMaskKey()
                    local maskShop = MaskShopTable[maskKey]

                    if not maskShop or not maskShop:FindFirstChild('Head') then
                        return
                    end

                    local SavedPosition = hrp.CFrame
                    local maskInBackpack = plr.Backpack:FindFirstChild('[Mask]')
                    local maskInChar = character:FindFirstChild('[Mask]')
                    local inGameMask = character:FindFirstChild('In-gameMask')

                    if maskInBackpack or maskInChar or inGameMask then
                        if (maskInBackpack or maskInChar) and not inGameMask then
                            local tool = maskInBackpack or maskInChar

                            tool.Parent = character

                            task.wait(0.25)

                            local equipped = character:FindFirstChild('[Mask]')

                            if equipped then
                                equipped:Activate()
                                task.wait(0.8)

                                equipped.Parent = plr.Backpack
                            end

                            getgenv().AutoMaskEnabled = false

                            Library:Notify('Mask used, auto logic disabled.', 5)
                        end

                        return
                    end

                    hrp.CFrame = maskShop.Head.CFrame * CFrame.new(0, 2, 0)
                    hrp.Velocity = Vector3.zero
                    hrp.AssemblyLinearVelocity = Vector3.zero

                    RunService:BindToRenderStep('RestoreAutoMask', 199, function()
                        hrp.CFrame = SavedPosition

                        RunService:UnbindFromRenderStep('RestoreAutoMask')
                    end)

                    local click = maskShop:FindFirstChildOfClass('ClickDetector')

                    if click then
                        fireclickdetector(click)
                    end
                end)
            end
        end)()
    end
end)()
task.wait(1)
coroutine.wrap(function()
    local RS = cloneref(game:GetService('RunService'))
    local highlights = {}

    RS.RenderStepped:Connect(function()
        if not DYHUBcc.HitboxExpander.Enabled then
            for _, Player in pairs(Players:GetPlayers())do
                if Player == LocalPlayer then
                    continue
                end

                local Character = Player.Character

                if Character then
                    local HRP = Character:FindFirstChild('HumanoidRootPart')

                    if HRP then
                        HRP.Size = Vector3.new(2, 2, 1)
                        HRP.Transparency = 1
                        HRP.CanCollide = true
                    end
                    if highlights[Player] then
                        highlights[Player]:Destroy()

                        highlights[Player] = nil
                    end
                end
            end

            return
        end

        for _, Player in pairs(Players:GetPlayers())do
            if Player == LocalPlayer then
                continue
            end

            local Character = Player.Character

            if Character then
                local HRP = Character:FindFirstChild('HumanoidRootPart')

                if HRP then
                    HRP.Size = Vector3.new(DYHUBcc.HitboxExpander.Size, DYHUBcc.HitboxExpander.Size, DYHUBcc.HitboxExpander.Size)
                    HRP.CanCollide = false

                    if DYHUBcc.HitboxExpander.Visualize then
                        HRP.Transparency = 0.9

                        if not highlights[Player] then
                            local Visualize = Instance.new('Highlight')

                            Visualize.Parent = HRP
                            Visualize.FillColor = DYHUBcc.HitboxExpander.Color
                            Visualize.OutlineColor = DYHUBcc.HitboxExpander.OutlineColor
                            Visualize.FillTransparency = DYHUBcc.HitboxExpander.FillTransparency
                            Visualize.OutlineTransparency = DYHUBcc.HitboxExpander.OutlineTransparency
                            highlights[Player] = Visualize
                        else
                            local Visualize = highlights[Player]

                            Visualize.FillColor = DYHUBcc.HitboxExpander.Color
                            Visualize.OutlineColor = DYHUBcc.HitboxExpander.OutlineColor
                            Visualize.FillTransparency = DYHUBcc.HitboxExpander.FillTransparency
                            Visualize.OutlineTransparency = DYHUBcc.HitboxExpander.OutlineTransparency
                        end
                    else
                        HRP.Transparency = 1

                        if highlights[Player] then
                            highlights[Player]:Destroy()

                            highlights[Player] = nil
                        end
                    end
                end
            end
        end
    end)

    local CharacterModsGroup = Tabs.Character:AddRightGroupbox('Character Mods')
	local function toggleAntiSlow(bool)
	    if bool then
	        RunService:BindToRenderStep("Anti-Slow", Enum.RenderPriority.Camera.Value, function()
	            if localPlayer.Character and localPlayer.Character:FindFirstChild("BodyEffects") then
	                local BE = localPlayer.Character.BodyEffects
	                local Movement = BE:FindFirstChild("Movement")
	                if Movement then
	                    if Movement:FindFirstChild("NoWalkSpeed") then Movement.NoWalkSpeed:Destroy() end
	                    if Movement:FindFirstChild("ReduceWalk") then Movement.ReduceWalk:Destroy() end
	                    if Movement:FindFirstChild("NoJumping") then Movement.NoJumping:Destroy() end
	                end
	                if BE:FindFirstChild("Reload") and BE.Reload.Value then
	                    BE.Reload.Value = false
	                end
	            end
	        end)
	    else
	        RunService:UnbindFromRenderStep("Anti-Slow")
	    end
	end
	
	CharacterModsGroup:AddToggle('AntiSlow', {
	    Text = 'No Slowdown',
	    Default = false,
	    Callback = function(v) toggleAntiSlow(v) end
	})
    getgenv().NoJumpCooldown = false

    RunService.RenderStepped:Connect(function()
        if getgenv().NoJumpCooldown and localPlayer.Character and localPlayer.Character:FindFirstChild('Humanoid') then
            local hum = localPlayer.Character.Humanoid

            hum.UseJumpPower = not hum.UseJumpPower
        end
    end)
    CharacterModsGroup:AddToggle('NoJumpCooldown', {
        Text = 'No Jump Cooldown',
        Default = false,
        Callback = function(v)
            getgenv().NoJumpCooldown = v
        end,
    })

    local RspawnAbuse = Tabs.Character:AddRightGroupbox('Respawn abuse')

    getgenv().DYHUB.RespawnAbuse = {
        Enabled = false,
    }

	RspawnAbuse:AddToggle('RespawnAbuseToggle', {
	    Text = 'Respawn Abuse',
	    Default = false,
	    Callback = function(v)
	        getgenv().DYHUB.RespawnAbuse.Enabled = v
	
	        if v then
	            task.spawn(function()
	                while getgenv().DYHUB.RespawnAbuse.Enabled do
	                    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	                    local hum = char:WaitForChild("Humanoid")
	
	                    -- Äá»£i cho tá»›i khi KHÃ”NG cÃ²n ForceField
	                    while char:FindFirstChild("ForceField") 
	                        and getgenv().DYHUB.RespawnAbuse.Enabled do
	                        task.wait(0.1)
	                    end
	
	                    if hum and hum.Health > 0 then
	                        task.wait(0)
	                        if hum.Health > 0 then
	                            hum.Health = 0
	                        end
	                    end
	
	                    -- Äá»£i respawn tiáº¿p
	                    localPlayer.CharacterAdded:Wait()
	                    task.wait(0.1)
	                end
	            end)
	        end
	    end,
	})


    local AnimationGroup = Tabs.Character:AddRightGroupbox('Animation')

    getgenv().DYHUB.Dance = {
        Enabled = false,
        Playing = false,
        Selected = 'Hyper Flex',
        AnimationId = '10714369624',
    }
    getgenv().DYHUB.RandomEmote = {Enabled = false}

    local DanceList = {
        ['Baby Queen - Bouncy Twirl'] = '14352343065',
        ['Floss'] = '10714340543',
        ['Rainbow Dance'] = '131275075715065',
        ['Michael Myers'] = '104253439312610',
        ['Yungblud Happier Jump'] = '15609995579',
        ['Hyper Flex'] = '10714369624',
        ['Gangnam Style'] = '131104967711844',
        ['Coffin Walkout'] = '126771729094882',
        ['Mae Stephens - Dance'] = '16553163212',
        ['Victory Dance'] = '15505456446',
        ['Elton John - Heart Skip'] = '11309255148',
        ['Sturdy Dance - Ice Spice'] = '17746180844',
        ['Meme China'] = '98943029911905',
        ['Basketball Head'] = '138243322520289',
        ['Sidekicks'] = '10370362157',
        ['Baby Dance'] = '10713983178',
        ['Rampage'] = '139658061151500',
        ['Rambunctious'] = '85916053135662',
        ['Griddy'] = '121966805049108',
        ['Orange Justice'] = '78927657777256',
        ['Float Stylish'] = '112089880074848',
        ['Float in clouds'] = '116370641960604',
        ['billy bounce'] = '136095999219650',
        ['zero two dance v2'] = '116714406076290',
        ['jabba switchway'] = '82682811348660',
        ['beat'] = '133394554631338',
        ['take the l'] = '117865821073911',
        ['Popular'] = '93062298566806',
        ['hip sway'] = '138316142522795',
        ['cute feet kicking'] = '124287251935400',
    }
    local danceTrack = nil
    local randomTask = nil

    local function loadDance(name)
        local char = localPlayer.Character

        if not char then
            return
        end

        local hum = char:FindFirstChild('Humanoid')

        if not hum then
            return
        end
        if danceTrack then
            danceTrack:Stop()
            danceTrack:Destroy()
        end

        local animId = DanceList[name]

        if animId then
            local anim = Instance.new('Animation')

            anim.AnimationId = 'rbxassetid://' .. animId
            danceTrack = hum:LoadAnimation(anim)
            danceTrack.Priority = Enum.AnimationPriority.Action
            danceTrack.Looped = true

            if getgenv().DYHUB.Dance.Playing or getgenv().DYHUB.RandomEmote.Enabled then
                danceTrack:Play()
            end
        end
    end

    localPlayer.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild('Humanoid')

        if danceTrack then
            danceTrack:Stop()
            danceTrack:Destroy()

            danceTrack = nil
        end
        if getgenv().DYHUB.Dance.Playing then
            loadDance(getgenv().DYHUB.Dance.Selected)
        end
        if getgenv().DYHUB.RespawnAbuse.Enabled then
            task.delay(getgenv().DYHUB.RespawnAbuse.Delay, function()
                if hum and hum.Health > 0 then
                    hum.Health = 0
                end
            end)
        end
    end)
    AnimationGroup:AddDropdown('DanceSelect', {
        Values = (function()
            local t = {}

            for k, _ in pairs(DanceList)do
                table.insert(t, k)
            end

            table.sort(t)

            return t
        end)(),
        Default = 0,
        Multi = false,
        Text = 'Dance Animation',
        Searchable = true,
        Callback = function(v)
            getgenv().DYHUB.Dance.Selected = v

            loadDance(v)
        end,
    })
    AnimationGroup:AddToggle('DanceToggle', {
        Text = 'Play Dance',
        Default = false,
        Callback = function(v)
            getgenv().DYHUB.Dance.Enabled = v
            getgenv().DYHUB.Dance.Playing = v

            if v and danceTrack then
                danceTrack.Looped = true

                danceTrack:Play()
            elseif danceTrack then
                danceTrack:Stop()
            end
        end,
    }):AddKeyPicker('DanceKey', {
        Default = 'None',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Dance Keybind',
    })

	AnimationGroup:AddToggle(
		"RandomEmoteToggle",
		{
			Text = "Random Emote",
			Default = false,
			Callback = function(v)
				getgenv().DYHUB.RandomEmote.Enabled = v
				if v then
					local dances = {}
					for k in pairs(DanceList) do
						table.insert(dances, k)
					end
					local selected = dances[math.random(1, #dances)]
					loadDance(selected)
					if randomTask then
						task.cancel(randomTask)
					end
					randomTask =
						task.spawn(
						function()
							while getgenv().DYHUB.RandomEmote.Enabled do
								task.wait(math.random(5, 7))
								local dances = {}
								for k in pairs(DanceList) do
									table.insert(dances, k)
								end
								local selected = dances[math.random(1, #dances)]
								loadDance(selected)
							end
						end
					)
				else
					if randomTask then
						task.cancel(randomTask)
						randomTask = nil
					end
					if danceTrack then
						danceTrack:Stop()
						danceTrack:Destroy()
						danceTrack = nil
					end
				end
			end
		}
	):AddKeyPicker(
		"RandomEmoteKey",
		{Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Random Emote Keybind"}
	)

    local KeepOnDeath = false
    local AnimationOptions = {
        Idle1 = 'http://www.roblox.com/asset/?id=180435571',
        Idle2 = 'http://www.roblox.com/asset/?id=180435792',
        Walk = 'http://www.roblox.com/asset/?id=180426354',
        Run = 'http://www.roblox.com/asset/?id=180426354',
        Jump = 'http://www.roblox.com/asset/?id=125750702',
        Climb = 'http://www.roblox.com/asset/?id=180436334',
        Fall = 'http://www.roblox.com/asset/?id=180436148',
    }
    local AnimationSets = {
        Default = {
            idle1 = '180435571',
            idle2 = '180435792',
            walk = '180426354',
            run = '180426354',
            jump = '125750702',
            climb = '180436334',
            fall = '180436148',
        },
        Ninja = {
            idle1 = '656117400',
            idle2 = '656118341',
            walk = '656121766',
            run = '656118852',
            jump = '656117878',
            climb = '656114359',
            fall = '656115606',
        },
        Superhero = {
            idle1 = '616111295',
            idle2 = '616113536',
            walk = '616122287',
            run = '616117076',
            jump = '616115533',
            climb = '616104706',
            fall = '616108001',
        },
        Robot = {
            idle1 = '616088211',
            idle2 = '616089559',
            walk = '616095330',
            run = '616091570',
            jump = '616090535',
            climb = '616086039',
            fall = '616087089',
        },
        Cartoon = {
            idle1 = '742637544',
            idle2 = '742638445',
            walk = '742640026',
            run = '742638842',
            jump = '742637942',
            climb = '742636889',
            fall = '742637151',
        },
        Catwalk = {
            idle1 = '133806214992291',
            idle2 = '94970088341563',
            walk = '109168724482748',
            run = '81024476153754',
            jump = '116936326516985',
            climb = '119377220967554',
            fall = '92294537340807',
        },
        Zombie = {
            idle1 = '616158929',
            idle2 = '616160636',
            walk = '616168032',
            run = '616163682',
            jump = '616161997',
            climb = '616156119',
            fall = '616157476',
        },
        Mage = {
            idle1 = '707742142',
            idle2 = '707855907',
            walk = '707897309',
            run = '707861613',
            jump = '707853694',
            climb = '707826056',
            fall = '707829716',
        },
        Pirate = {
            idle1 = '750785693',
            idle2 = '750782770',
            walk = '750785693',
            run = '750782770',
            jump = '750782770',
            climb = '750782770',
            fall = '750782770',
        },
        Knight = {
            idle1 = '657595757',
            idle2 = '657568135',
            walk = '657552124',
            run = '657564596',
            jump = '657560148',
            climb = '657556206',
            fall = '657552124',
        },
        Vampire = {
            idle1 = '1083465857',
            idle2 = '1083465857',
            walk = '1083465857',
            run = '1083465857',
            jump = '1083465857',
            climb = '1083465857',
            fall = '1083465857',
        },
        Bubbly = {
            idle1 = '910004836',
            idle2 = '910009958',
            walk = '910034870',
            run = '910025107',
            jump = '910016857',
            climb = '910009958',
            fall = '910009958',
        },
        Elder = {
            idle1 = '845386501',
            idle2 = '845397899',
            walk = '845403856',
            run = '845386501',
            jump = '845386501',
            climb = '845386501',
            fall = '845386501',
        },
        Toy = {
            idle1 = '782841498',
            idle2 = '782841498',
            walk = '782841498',
            run = '782841498',
            jump = '782841498',
            climb = '782841498',
            fall = '782841498',
        },
    }

    local function applyCustomAnimations(character)
        if not character or not character:FindFirstChild('Animate') then
            return
        end

        local Animate = character.Animate
        local Cloned = Animate:Clone()

        Cloned.idle.Animation1.AnimationId = AnimationOptions.Idle1
        Cloned.idle.Animation2.AnimationId = AnimationOptions.Idle2
        Cloned.walk.WalkAnim.AnimationId = AnimationOptions.Walk
        Cloned.run.RunAnim.AnimationId = AnimationOptions.Run
        Cloned.jump.JumpAnim.AnimationId = AnimationOptions.Jump
        Cloned.climb.ClimbAnim.AnimationId = AnimationOptions.Climb
        Cloned.fall.FallAnim.AnimationId = AnimationOptions.Fall

        Animate:Destroy()

        Cloned.Parent = character
    end

    localPlayer.CharacterAdded:Connect(function(char)
        if KeepOnDeath then
            task.wait(1.5)
            applyCustomAnimations(char)
        end
    end)

    local animPackNames = {}

    for name, _ in pairs(AnimationSets)do
        table.insert(animPackNames, name)
    end

    table.sort(animPackNames)

    local function updateAnimation(key, id)
        AnimationOptions[key] = 'http://www.roblox.com/asset/?id=' .. id

        if localPlayer.Character then
            applyCustomAnimations(localPlayer.Character)
        end
    end

    AnimationGroup:AddDropdown('AnimPack', {
        Values = animPackNames,
        Default = 1,
        Multi = false,
        Text = 'Animation Pack',
        Searchable = true,
        Callback = function(value)
            local set = AnimationSets[value]

            updateAnimation('Idle1', set.idle1)
            updateAnimation('Idle2', set.idle2)
            updateAnimation('Walk', set.walk)
            updateAnimation('Run', set.run)
            updateAnimation('Jump', set.jump)
            updateAnimation('Climb', set.climb)
            updateAnimation('Fall', set.fall)
        end,
    })
    AnimationGroup:AddDropdown('Idle1', {
        Values = animPackNames,
        Default = 1,
        Multi = false,
        Text = 'Idle Animation 1',
        Callback = function(v)
            updateAnimation('Idle1', AnimationSets[v].idle1)
        end,
    })
    AnimationGroup:AddDropdown('Idle2', {
        Values = animPackNames,
        Default = 1,
        Multi = false,
        Text = 'Idle Animation 2',
        Callback = function(v)
            updateAnimation('Idle2', AnimationSets[v].idle2)
        end,
    })
    AnimationGroup:AddDropdown('Walk', {
        Values = animPackNames,
        Default = 1,
        Multi = false,
        Text = 'Walk Animation',
        Callback = function(v)
            updateAnimation('Walk', AnimationSets[v].walk)
        end,
    })
    AnimationGroup:AddDropdown('Run', {
        Values = animPackNames,
        Default = 1,
        Multi = false,
        Text = 'Run Animation',
        Callback = function(v)
            updateAnimation('Run', AnimationSets[v].run)
        end,
    })
    AnimationGroup:AddDropdown('Jump', {
        Values = animPackNames,
        Default = 1,
        Multi = false,
        Text = 'Jump Animation',
        Callback = function(v)
            updateAnimation('Jump', AnimationSets[v].jump)
        end,
    })
    AnimationGroup:AddDropdown('Climb', {
        Values = animPackNames,
        Default = 1,
        Multi = false,
        Text = 'Climb Animation',
        Callback = function(v)
            updateAnimation('Climb', AnimationSets[v].climb)
        end,
    })
    AnimationGroup:AddDropdown('Fall', {
        Values = animPackNames,
        Default = 1,
        Multi = false,
        Text = 'Fall Animation',
        Callback = function(v)
            updateAnimation('Fall', AnimationSets[v].fall)
        end,
    })
    AnimationGroup:AddToggle('KeepAnimOnDeath', {
        Text = 'Keep On Death',
        Default = false,
        Tooltip = 'Gi\u{1eef} animation sau khi respawn',
        Callback = function(v)
            KeepOnDeath = v
        end,
    })

    getgenv().DYHUB.Character = getgenv().DYHUB.Character or {}
    getgenv().DYHUB.Character.Noclip = false

    local NoclipConnection

    local function toggleNoclip(bool)
        getgenv().DYHUB.Character.Noclip = bool

        if bool then
            NoclipConnection = NewConnection(RunService.Stepped, function()
                if localPlayer.Character then
                    for _, v in pairs(localPlayer.Character:GetDescendants())do
                        if v:IsA('BasePart') and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            if NoclipConnection then
                NoclipConnection:Disconnect()
            end
        end
    end

    CharacterModsGroup:AddToggle('Noclip', {
        Text = 'Noclip',
        Default = false,
        Callback = toggleNoclip,
    }):AddKeyPicker('NoclipKey', {
        Default = 'N',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Noclip',
    })

    do
        local CollectionService = game:GetService('CollectionService')
        local seats = {}

        local function disableSeat(seat, bool)
            if seat and seat:IsA('Seat') then
                seat.Disabled = bool

                if bool then
                    CollectionService:AddTag(seat, 'NoSitSeat')
                else
                    CollectionService:RemoveTag(seat, 'NoSitSeat')
                end
            end
        end

        for _, seat in workspace:GetDescendants()do
            if seat:IsA('Seat') then
                disableSeat(seat, false)
                table.insert(seats, seat)
            end
        end

        workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA('Seat') then
                table.insert(seats, obj)
                disableSeat(obj, getgenv().NoSeat or false)
            end
        end)
        CharacterModsGroup:AddToggle('NoSeat', {
            Text = 'No Seat',
            Default = false,
            Callback = function(v)
                getgenv().NoSeat = v

                for _, seat in seats do
                    disableSeat(seat, v)
                end
            end,
        })
    end

    DYHUBcc.Desync = {
        Enabled = false,
        Mode = 'Custom',
        RandomAmount = 20,
        Visualize = false,
        Line = false,
        Status = false,
        Dot = false,
        CustomX = 0,
        CustomY = 0,
        CustomZ = 0,
    }

    local BodyCloneDesync = game:GetObjects('rbxassetid://8246626421')[1]

    BodyCloneDesync.Parent = workspace

    BodyCloneDesync.Humanoid:Destroy()
    BodyCloneDesync.Head.Face:Destroy()

    for _, v in pairs(BodyCloneDesync:GetDescendants())do
        if v:IsA('BasePart') or v:IsA('MeshPart') then
            v.CanCollide = false
            v.Transparency = 0
        end
    end

    BodyCloneDesync.HumanoidRootPart.Transparency = 0.5
    BodyCloneDesync.HumanoidRootPart.Velocity = Vector3.zero
    BodyCloneDesync.HumanoidRootPart.CFrame = CFrame.new(9999, 9999, 9999)

    local BodyCloneDesyncHighlight = Instance.new('Highlight')

    BodyCloneDesyncHighlight.Enabled = false
    BodyCloneDesyncHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    BodyCloneDesyncHighlight.FillColor = Color3.fromRGB(0, 255, 0)
    BodyCloneDesyncHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    BodyCloneDesyncHighlight.FillTransparency = 0.3
    BodyCloneDesyncHighlight.OutlineTransparency = 0
    BodyCloneDesyncHighlight.Adornee = BodyCloneDesync
    BodyCloneDesyncHighlight.Parent = BodyCloneDesync

    local GlowLight = Instance.new('PointLight')

    GlowLight.Color = Color3.fromRGB(0, 255, 100)
    GlowLight.Brightness = 4
    GlowLight.Range = 2
    GlowLight.Parent = BodyCloneDesync.HumanoidRootPart

    local DesyncLine1 = Drawing.new('Line')

    DesyncLine1.Thickness = 2
    DesyncLine1.Color = Color3.fromRGB(0, 255, 0)
    DesyncLine1.Visible = false
    DesyncLine1.Transparency = 1

    local DesyncDot = Drawing.new('Circle')

    DesyncDot.Radius = 6
    DesyncDot.Thickness = 1.5
    DesyncDot.NumSides = 16
    DesyncDot.Color = Color3.fromRGB(0, 255, 100)
    DesyncDot.Filled = true
    DesyncDot.Transparency = 1
    DesyncDot.Visible = false

    local DesyncStatus = Drawing.new('Text')

    DesyncStatus.Text = 'Desync: FALSE'
    DesyncStatus.Size = 16
    DesyncStatus.Font = 2
    DesyncStatus.Color = Color3.fromRGB(255, 0, 0)
    DesyncStatus.Outline = true
    DesyncStatus.OutlineColor = Color3.fromRGB(0, 0, 0)
    DesyncStatus.Center = false
    DesyncStatus.Visible = false
    DesyncStatus.Position = Vector2.new(100, 100)

    local function resetCamera()
        if LocalPlayer.Character then
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChild('Humanoid')
        end
    end

    local desync_setback = Instance.new('Part')

    desync_setback.Name = 'DesyncSetback'
    desync_setback.Size = Vector3.new(2, 2, 1)
    desync_setback.CanCollide = false
    desync_setback.Anchored = true
    desync_setback.Transparency = 1
    desync_setback.Parent = workspace

    NewConnection(RunService.Heartbeat, function()
        if not LocalPlayer.Character then
            BodyCloneDesync:SetPrimaryPartCFrame(CFrame.new(9999, 9999, 9999))

            BodyCloneDesyncHighlight.Enabled = false
            DesyncLine1.Visible = false
            DesyncDot.Visible = false
            DesyncStatus.Visible = false

            return
        end

        local hrp = LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
        local lowerTorso = LocalPlayer.Character:FindFirstChild('LowerTorso')

        if not hrp then
            DesyncDot.Visible = false

            return
        end

        local oldCFrame = hrp.CFrame
        local desyncCFrame = oldCFrame

        if DYHUBcc.Desync.Enabled then
            if DYHUBcc.Desync.Mode == 'Destroy Cheaters' then
                desyncCFrame = CFrame.new(9e9, 1, 1) * oldCFrame.Rotation
            elseif DYHUBcc.Desync.Mode == 'Underground' then
                desyncCFrame = CFrame.new(hrp.Position - Vector3.new(0, 12, 0)) * oldCFrame.Rotation
            elseif DYHUBcc.Desync.Mode == 'Void Spam' then
                desyncCFrame = math.random(1, 2) == 1 and oldCFrame or CFrame.new(math.random(10000, 50000), math.random(10000, 50000), math.random(10000, 50000)) * oldCFrame.Rotation
            elseif DYHUBcc.Desync.Mode == 'Void' then
                desyncCFrame = oldCFrame + Vector3.new(math.random(-444444, 444444), math.random(-444444, 444444), math.random(-44444, 44444))
                desyncCFrame = desyncCFrame * oldCFrame.Rotation
            elseif DYHUBcc.Desync.Mode == 'Random' then
                local amount = DYHUBcc.Desync.RandomAmount
                local offset = Vector3.new(math.random(-amount, amount), math.random(-amount / 2, amount / 2), math.random(-amount, amount))

                desyncCFrame = CFrame.new(oldCFrame.Position + offset) * oldCFrame.Rotation
            elseif DYHUBcc.Desync.Mode == 'Safe Shoot' then
                desyncCFrame = CFrame.new(hrp.Position - Vector3.new(0, 5, 0)) * CFrame.Angles(math.random(0, 360), math.random(0, 360), math.rad(180))
            elseif DYHUBcc.Desync.Mode == 'Custom' then
                desyncCFrame = CFrame.new(hrp.Position - Vector3.new(DYHUBcc.Desync.CustomX, DYHUBcc.Desync.CustomY, DYHUBcc.Desync.CustomZ)) * oldCFrame.Rotation
            end

            hrp.CFrame = desyncCFrame

            if not DYHUBcc.TargetAim.SpectateTarget then
                Camera.CameraSubject = desync_setback
            end

            RunService.RenderStepped:Wait()

            desync_setback.CFrame = oldCFrame * CFrame.new(0, hrp.Size.Y / 2 + 0.5, 0)
            hrp.CFrame = oldCFrame
        end

        local visualizePosition = hrp.Position
        local visualizeCFrame = hrp.CFrame

        if DYHUBcc.Desync.Enabled then
            visualizeCFrame = desyncCFrame
        elseif DYHUBcc.TargetAim.AutoKill then
            visualizeCFrame = killpos
        else
            visualizeCFrame = hrp.CFrame
        end
        if DYHUBcc.Desync.Visualize and DYHUBcc.Desync.Enabled then
            BodyCloneDesync:SetPrimaryPartCFrame(visualizeCFrame)

            BodyCloneDesyncHighlight.Enabled = true
        else
            BodyCloneDesyncHighlight.Enabled = false

            BodyCloneDesync:SetPrimaryPartCFrame(CFrame.new(9999, 9999, 9999))
        end
        if DYHUBcc.Desync.Line and DYHUBcc.Desync.Enabled then
            local targetPosition = visualizeCFrame.Position
            local screenRoot, onScreenRoot = Camera:WorldToViewportPoint(targetPosition)
            local mouseLocation = UserInputService:GetMouseLocation()

            if onScreenRoot then
                DesyncLine1.From = mouseLocation
                DesyncLine1.To = Vector2.new(screenRoot.X, screenRoot.Y)
                DesyncLine1.Color = BodyCloneDesyncHighlight.FillColor or Color3.fromRGB(255, 255, 255)
                DesyncLine1.Visible = true
            else
                DesyncLine1.Visible = false
            end
        else
            DesyncLine1.Visible = false
        end
        if DYHUBcc.Desync.Dot and DYHUBcc.Desync.Enabled then
            local targetPosition = visualizeCFrame.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPosition)

            if onScreen then
                DesyncDot.Position = Vector2.new(screenPos.X, screenPos.Y)
                DesyncDot.Visible = true
            else
                DesyncDot.Visible = false
            end
        else
            DesyncDot.Visible = false
        end
        if DYHUBcc.Desync.Status then
            DesyncStatus.Text = 'Desync: ' .. (DYHUBcc.Desync.Enabled and 'TRUE' or 'FALSE')
            DesyncStatus.Color = DYHUBcc.Desync.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            DesyncStatus.Visible = true
        else
            DesyncStatus.Visible = false
        end
    end)

    local dragging = false

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and DYHUBcc.Desync.Status then
            local mousePos = UserInputService:GetMouseLocation()
            local textPos = DesyncStatus.Position
            local textSize = DesyncStatus.TextBounds

            if mousePos.X >= textPos.X and mousePos.X <= textPos.X + textSize.X and mousePos.Y >= textPos.Y and mousePos.Y <= textPos.Y + textSize.Y then
                dragging = true
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            DesyncStatus.Position = UserInputService:GetMouseLocation()
        end
    end)

    local AntiAim = Tabs.Player:AddRightTabbox()
    local DesyncGroup = AntiAim:AddTab('Desync')

    DesyncGroup:AddToggle('DesyncEnabled', {
        Text = 'Enabled',
        Default = false,
        Callback = function(Value)
            DYHUBcc.Desync.Enabled = Value

            if not Value then
                resetCamera()
            end
        end,
    }):AddKeyPicker('DesyncKeybind', {
        Default = 'None',
        NoUI = true,
        Text = 'Desync Key',
        Callback = function(Key)
            DYHUBcc.Desync.Enabled = not DYHUBcc.Desync.Enabled

            if not DYHUBcc.Desync.Enabled then
                resetCamera()
            end
        end,
    })
    DesyncGroup:AddDropdown('DesyncMode', {
        Values = {
            'Destroy Cheaters',
            'Underground',
            'Void Spam',
            'Void',
            'Random',
            'Safe Shoot',
            'Custom',
        },
        Default = 7,
        Multi = false,
        Text = 'Desync Mode',
        Callback = function(Value)
            DYHUBcc.Desync.Mode = Value
        end,
    })
    DesyncGroup:AddSlider('DesyncCustomX', {
        Text = 'Custom X',
        Default = 0,
        Min = -1E4,
        Max = 10000,
        Rounding = 0,
        Callback = function(Value)
            DYHUBcc.Desync.CustomX = Value
        end,
    })
    DesyncGroup:AddSlider('DesyncCustomY', {
        Text = 'Custom Y',
        Default = 0,
        Min = -1E4,
        Max = 10000,
        Rounding = 0,
        Callback = function(Value)
            DYHUBcc.Desync.CustomY = Value
        end,
    })
    DesyncGroup:AddSlider('DesyncCustomZ', {
        Text = 'Custom Z',
        Default = 0,
        Min = -1E4,
        Max = 10000,
        Rounding = 0,
        Callback = function(Value)
            DYHUBcc.Desync.CustomZ = Value
        end,
    })
    DesyncGroup:AddSlider('DesyncRandomAmount', {
        Text = 'Random Amount',
        Default = 20,
        Min = 1,
        Max = 10000000,
        Suffix = '',
        Compact = false,
        Callback = function(Value)
            DYHUBcc.Desync.RandomAmount = Value
        end,
    })
    DesyncGroup:AddToggle('DesyncVisualize', {
        Text = 'Visualize Desync',
        Default = false,
        Callback = function(Value)
            DYHUBcc.Desync.Visualize = Value
        end,
    }):AddColorPicker('DesyncVizColor', {
        Default = Color3.fromRGB(0, 255, 0),
        Title = 'Color',
        Callback = function(Value)
            BodyCloneDesyncHighlight.FillColor = Value
            GlowLight.Color = Value
            DesyncDot.Color = Value
        end,
    })
    DesyncGroup:AddToggle('DesyncLine', {
        Text = 'Line Desync',
        Default = false,
        Callback = function(Value)
            DYHUBcc.Desync.Line = Value
        end,
    })
    DesyncGroup:AddToggle('DesyncStatus', {
        Text = 'Desync Status',
        Default = false,
        Callback = function(Value)
            DYHUBcc.Desync.Status = Value
        end,
    })
    DesyncGroup:AddToggle('DesyncDot', {
        Text = 'Dot Desync',
        Default = false,
        Callback = function(Value)
            DYHUBcc.Desync.Dot = Value
        end,
    })

    local FakePosGroup = AntiAim:AddTab('Fake Pos')
    local FakePos = {
        Enabled = false,
        Mode = 'Voidless',
        Version = 'Version 3',
        ReturnDelay = 0.5,
        Method = 'Advanced',
        OriginalPos = nil,
        Active = false,
    }

    local function GetFakePosOffset()
        if FakePos.Version == 'Version 1' then
            return CFrame.new(100000, 100000, 100000)
        elseif FakePos.Version == 'Version 2' then
            return CFrame.new(50000000, 50000000, 50000000)
        elseif FakePos.Version == 'Version 3' then
            return CFrame.new(500000000, 500000000, 500000000)
        end
    end
    local function ApplyFakePosition()
        if FakePos.Active then
            return
        end

        local Character = Player.Character or Player.CharacterAdded:Wait()
        local HRP = Character:FindFirstChild('HumanoidRootPart')

        if not HRP then
            return
        end

        FakePos.Active = true
        FakePos.OriginalPos = HRP.CFrame

        local oldFallHeight = workspace.FallenPartsDestroyHeight

        workspace.FallenPartsDestroyHeight = -math.huge

        if FakePos.Method == 'Advanced' then
            pcall(function()
                setfflag('NextGenReplicatorEnabledWrite4', 'True')
            end)
        end
        if FakePos.Mode == 'Voidless' then
            local offset = GetFakePosOffset()

            if offset then
                HRP.CFrame = offset
            end

            task.spawn(function()
                task.wait(FakePos.ReturnDelay)

                if HRP and FakePos.OriginalPos then
                    HRP.CFrame = FakePos.OriginalPos
                end

                workspace.FallenPartsDestroyHeight = oldFallHeight
                FakePos.Active = false
            end)
        elseif FakePos.Mode == 'On the spot' then
            task.spawn(function()
                task.wait(FakePos.ReturnDelay)

                workspace.FallenPartsDestroyHeight = oldFallHeight
                FakePos.Active = false
            end)
        end
    end
    local function DisableFakePosition()
        FakePos.Active = false
        workspace.FallenPartsDestroyHeight = 0 / 0

        if FakePos.Method == 'Advanced' then
            pcall(function()
                setfflag('NextGenReplicatorEnabledWrite4', 'False')
            end)
        end
    end
    local function isSetFFlagSupported()
        local success, err = pcall(function()
            setfflag('SomeDummyFlagForTest', '0')
        end)

        if success then
            return true
        else
            warn('Executor not support setfflag: ' .. tostring(err))

            return false
        end
    end

    FakePosGroup:AddToggle('EnableFakePos', {
        Text = 'Enable',
        Default = false,
        Tooltip = 'You has been scam',
    }):AddKeyPicker('FakePosBind', {
        Default = '',
        Mode = 'Toggle',
        Text = 'Fake Position',
        NoUI = false,
        SyncToggleState = false,
        Callback = function(value)
            if game:GetService('UserInputService'):GetFocusedTextBox() then
                return
            end
            if not isSetFFlagSupported() then
                Library:Notify('FakePos requires a powerful executor', 3)
            end
            if Toggles.EnableFakePos.Value then
                if value then
                    ApplyFakePosition()
                    Library:Notify('FakePos Enabled', 3)
                else
                    DisableFakePosition()
                    Library:Notify('FakePos Disabled', 3)
                end
            end
        end,
    }):OnChanged(function(value)
        FakePos.Enabled = value

        if value then
            ApplyFakePosition()
        else
            DisableFakePosition()
        end
    end)
    FakePosGroup:AddDropdown('FakePosVersion', {
        Values = {
            'Version 1',
            'Version 2',
            'Version 3',
        },
        Default = 3,
        Multi = false,
        Text = 'Version',
        Callback = function(value)
            FakePos.Version = value
        end,
    })
    FakePosGroup:AddDropdown('FakePosMode', {
        Values = {
            'Voidless',
            'On the spot',
        },
        Default = 1,
        Multi = false,
        Text = 'Mode',
        Callback = function(value)
            FakePos.Mode = value
        end,
    })
    FakePosGroup:AddSlider('FakePosReturn', {
        Text = 'Return Delay',
        Default = 0.5,
        Min = 0.1,
        Max = 3,
        Rounding = 1,
        Callback = function(value)
            FakePos.ReturnDelay = value
        end,
    })

    getgenv().VelocitySpoofer = false
    getgenv().DirectionToShoot = 'Custom'
    getgenv().Direction = Vector3.zero
    getgenv().CustomVelocity = Vector3.zero

    local AntilockTab = AntiAim:AddTab('Antilock')
    local VelocityGui = Instance.new('ScreenGui', game.CoreGui)

    VelocityGui.Name = 'VelocityStatusGui'
    VelocityGui.ResetOnSpawn = false
    VelocityGui.Enabled = false

    local VelocityText = Instance.new('TextLabel', VelocityGui)

    VelocityText.Size = UDim2.new(0, 200, 0, 20)
    VelocityText.Position = UDim2.new(0.02, 0, 0.75, 0)
    VelocityText.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    VelocityText.BackgroundTransparency = 1
    VelocityText.TextScaled = true
    VelocityText.Font = Enum.Font.Code
    VelocityText.TextStrokeTransparency = 0
    VelocityText.TextColor3 = Color3.fromRGB(255, 255, 255)
    VelocityText.Active = true
    VelocityText.Draggable = true
    VelocityText.Text = 'Velocity Spoofer : false'

    AntilockTab:AddToggle('VelocitySpooferToggle', {
        Text = 'Velocity Spoofer',
        Default = false,
        Callback = function(v)
            getgenv().VelocitySpoofer = v
            VelocityText.Text = 'Velocity Spoofer : ' .. tostring(v)
        end,
    }):AddKeyPicker('VelocityKey', {
        Default = 'V',
        Mode = 'Toggle',
        Text = 'Velocity Key',
        Callback = function(v)
            getgenv().VelocitySpoofer = v

            Toggles.VelocitySpooferToggle:SetValue(v)

            VelocityText.Text = 'Velocity Spoofer : ' .. tostring(v)
        end,
    })
    AntilockTab:AddDropdown('VelocityMode', {
        Text = 'Velocity Mode',
        Default = 'Custom',
        Values = {
            'Custom',
            'Behind',
            'ForWard',
            'Left',
            'Right',
            'Up',
            'Down',
            'One',
            'Zero',
        },
        Callback = function(v)
            getgenv().DirectionToShoot = v
        end,
    })
    AntilockTab:AddSlider('CustomX', {
        Text = 'Custom X',
        Min = -1E4,
        Max = 10000,
        Default = 0,
        Rounding = 0,
        Callback = function(v)
            getgenv().CustomVelocity = Vector3.new(v, getgenv().CustomVelocity.Y, getgenv().CustomVelocity.Z)
        end,
    })
    AntilockTab:AddSlider('CustomY', {
        Text = 'Custom Y',
        Min = -1E4,
        Max = 10000,
        Default = 0,
        Rounding = 0,
        Callback = function(v)
            getgenv().CustomVelocity = Vector3.new(getgenv().CustomVelocity.X, v, getgenv().CustomVelocity.Z)
        end,
    })
    AntilockTab:AddSlider('CustomZ', {
        Text = 'Custom Z',
        Min = -1E4,
        Max = 10000,
        Default = 0,
        Rounding = 0,
        Callback = function(v)
            getgenv().CustomVelocity = Vector3.new(getgenv().CustomVelocity.X, getgenv().CustomVelocity.Y, v)
        end,
    })
    AntilockTab:AddToggle('Statusvelo', {
        Text = 'Status',
        Default = false,
        Callback = function(v)
            VelocityGui.Enabled = v
        end,
    })

    local function UpdateDirection()
        local d = getgenv().DirectionToShoot

        if d == 'Behind' then
            getgenv().Direction = Vector3.new(0, 0, -1)
        elseif d == 'Down' then
            getgenv().Direction = Vector3.new(0, -1, 0)
        elseif d == 'ForWard' then
            getgenv().Direction = Vector3.new(0, 0, 1)
        elseif d == 'Left' then
            getgenv().Direction = Vector3.new(-1, 0, 0)
        elseif d == 'Right' then
            getgenv().Direction = Vector3.new(1, 0, 0)
        elseif d == 'Up' then
            getgenv().Direction = Vector3.new(0, 1, 0)
        elseif d == 'One' then
            getgenv().Direction = Vector3.new(1, 1, 1)
        elseif d == 'Zero' then
            getgenv().Direction = Vector3.zero
        elseif d == 'Custom' then
            getgenv().Direction = getgenv().CustomVelocity
        end
    end

    game:GetService('RunService').Heartbeat:Connect(function()
        if getgenv().VelocitySpoofer then
            local char = game.Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild('HumanoidRootPart')

            if hrp then
                UpdateDirection()

                local old = hrp.Velocity

                hrp.Velocity = getgenv().Direction * (65536)

                game:GetService('RunService').RenderStepped:Wait()

                hrp.Velocity = old
            end
        end
    end)

    local PlayerListGroup = Tabs.Player:AddLeftGroupbox('Playerlist')
    local selectedPlayer = nil
    local spectateConnection = nil
    local isEnabled = false
    local currentBringTask1 = nil

    local function SpoofOnce(myRoot, spoofCF)
        if not myRoot then
            return
        end

        local SavedPosition = myRoot.CFrame

        myRoot.CFrame = spoofCF

        pcall(function()
            RunService:UnbindFromRenderStep('RestoreBring')
        end)
        RunService:BindToRenderStep('RestoreBring', 199, function()
            myRoot.CFrame = SavedPosition

            RunService:UnbindFromRenderStep('RestoreBring')
        end)
    end
    local function SpoofOnce(myRoot, spoofCF)
        if not myRoot then
            return
        end

        local SavedPosition = myRoot.CFrame

        myRoot.CFrame = spoofCF

        pcall(function()
            RunService:UnbindFromRenderStep('RestoreBring')
        end)
        RunService:BindToRenderStep('RestoreStrafe', 199, function()
            myRoot.CFrame = SavedPosition

            RunService:UnbindFromRenderStep('RestoreBring')
        end)
    end
    local function StartBring()
        if selectedPlayer == nil or not isEnabled then
            return
        end

        local targetPlayer = Players:FindFirstChild(tostring(selectedPlayer))

        if not targetPlayer or not targetPlayer.Character then
            isEnabled = false

            return
        end

        local myChar = LocalPlayer.Character

        if not myChar then
            return
        end

        local myRoot = myChar:FindFirstChild('HumanoidRootPart')

        if not myRoot then
            return
        end
        if AutoArmorActive or AutoLoadoutActive or BuyingSingleActive or AutoHealActive or BuyingAmmoActive or AutoKillActive then
            return
        end

        local oldPos = myRoot.CFrame

        task.spawn(function()
            local targetChar = targetPlayer.Character
            local targetRoot = targetChar:FindFirstChild('HumanoidRootPart')
            local targetHead = targetChar:FindFirstChild('Head')
            local bodyEffects = targetChar:FindFirstChild('BodyEffects')
            local koValue = bodyEffects and bodyEffects:FindFirstChild('K.O')

            if not (targetRoot and targetHead and koValue) then
                isEnabled = false

                return
            end

            local function EquipAllAmmoTools()
                local backpack = LocalPlayer:FindFirstChild('Backpack')

                if not backpack then
                    return
                end

                local hasUnequipped = false

                for _, tool in ipairs(backpack:GetChildren())do
                    if tool:IsA('Tool') and tool:FindFirstChild('Ammo') then
                        hasUnequipped = true
                        tool.Parent = myChar
                    end
                end

                return hasUnequipped
            end

            while not koValue.Value and isEnabled do
                local hasEquippedAmmoTool = false

                for _, tool in ipairs(myChar:GetChildren())do
                    if tool:IsA('Tool') and tool:FindFirstChild('Ammo') then
                        hasEquippedAmmoTool = true

                        break
                    end
                end

                if not hasEquippedAmmoTool then
                    EquipAllAmmoTools()
                end

                for _, equippedTool in ipairs(myChar:GetChildren())do
                    if equippedTool:IsA('Tool') and equippedTool:FindFirstChild('Ammo') and equippedTool.Ammo.Value <= 0 then
                        ReplicatedStorage.MainEvent:FireServer('Reload', equippedTool)
                        task.wait(0.5)
                    end
                end

                local offset = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))

                SpoofOnce(myRoot, CFrame.new(targetRoot.Position + offset))

                local tool = myChar:FindFirstChildWhichIsA('Tool')

                if tool and tool:FindFirstChild('Ammo') and tool.Ammo.Value > 0 then
                    ReplicatedStorage.MainEvent:FireServer('ShootGun', tool.Handle, tool.Handle.Position, targetHead.Position, targetHead, Vector3.new(0, 0, -1))
                end

                task.wait()
            end

            if koValue.Value and isEnabled then
                repeat
                    local upperTorso = targetChar:FindFirstChild('UpperTorso')

                    if upperTorso then
                        SpoofOnce(myRoot, CFrame.new(upperTorso.Position + Vector3.new(0, 3, 0)))
                    end

                    ReplicatedStorage.MainEvent:FireServer('Grabbing', false)
                    task.wait()
                until targetChar:FindFirstChild('GRABBING_CONSTRAINT') or not isEnabled

                if targetChar:FindFirstChild('GRABBING_CONSTRAINT') then
                    myRoot.CFrame = oldPos

                    task.wait(0.2)
                    ReplicatedStorage.MainEvent:FireServer('Grabbing', false)
                end
            end

            isEnabled = false
        end)
    end

    PlayerListGroup:AddDropdown('AutoKillTarget', {
        SpecialType = 'Player',
        ExcludeLocalPlayer = true,
        Multi = false,
        Text = 'Target',
        Searchable = true,
        Callback = function(Value)
            selectedPlayer = Value
        end,
    })

    local BeStand = {
        Enabled = false,
        Connection = nil,
        CurrentAnim = nil,
        IdleTrack = nil,
        WalkTrack = nil,
        LastTarget = nil,
    }

    local function setCameraToCharacter(character)
        if character and character:FindFirstChild('Humanoid') then
            Camera.CameraType = Enum.CameraType.Custom
            Camera.CameraSubject = character.Humanoid
        end
    end
    local function resetCamera1()
        local char = LocalPlayer.Character

        if char then
            setCameraToCharacter(char)
        end
    end

    Players.PlayerRemoving:Connect(function(plr)
        if plr == selectedPlayer then
            resetCamera1()
        end
    end)
    PlayerListGroup:AddToggle('BeStand', {
        Text = 'Be Stand [Follow Selected]',
        Default = false,
        Tooltip = 'Follow behind the selected player with cool animation',
        Callback = function(state)
            BeStand.Enabled = state

            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:WaitForChild('Humanoid')

            if not BeStand.IdleTrack then
                local idleAnim = Instance.new('Animation')

                idleAnim.AnimationId = 'rbxassetid://13850660986'
                BeStand.IdleTrack = hum:LoadAnimation(idleAnim)
                BeStand.IdleTrack.Priority = Enum.AnimationPriority.Action
            end
            if not BeStand.WalkTrack then
                local walkAnim = Instance.new('Animation')

                walkAnim.AnimationId = 'rbxassetid://3084858603'
                BeStand.WalkTrack = hum:LoadAnimation(walkAnim)
                BeStand.WalkTrack.Priority = Enum.AnimationPriority.Action
            end

            local function playAnim(track)
                if BeStand.CurrentAnim == track then
                    return
                end
                if BeStand.CurrentAnim then
                    BeStand.CurrentAnim:Stop()
                end

                BeStand.CurrentAnim = track

                if track and BeStand.Enabled then
                    track:Play()
                end
            end

            if not state then
                if BeStand.Connection then
                    BeStand.Connection:Disconnect()

                    BeStand.Connection = nil
                end

                BeStand.LastTarget = nil

                playAnim(nil)
                resetCamera1()

                return
            end
            if selectedPlayer and selectedPlayer.Character then
                setCameraToCharacter(selectedPlayer.Character)
            end

            BeStand.Connection = RunService.RenderStepped:Connect(function()
                if not BeStand.Enabled then
                    return
                end

                local target = selectedPlayer

                if not target or not target.Character or not target.Character:FindFirstChild('HumanoidRootPart') or not target.Character:FindFirstChild('Humanoid') then
                    playAnim(BeStand.IdleTrack)
                    resetCamera1()

                    return
                end

                local targetHum = target.Character.Humanoid
                local targetRoot = target.Character.HumanoidRootPart

                if targetHum.Health <= 0 then
                    playAnim(BeStand.IdleTrack)
                    resetCamera1()

                    return
                end
                if BeStand.LastTarget ~= target then
                    BeStand.LastTarget = target

                    setCameraToCharacter(target.Character)
                end

                local standOffset = Vector3.new(2, 2, 2.5)

                char:PivotTo(targetRoot.CFrame * CFrame.new(standOffset))

                if targetHum.MoveDirection.Magnitude > 0.1 then
                    playAnim(BeStand.WalkTrack)
                else
                    playAnim(BeStand.IdleTrack)
                end
            end)
        end,
    })
    PlayerListGroup:AddToggle('Bring', {
        Text = 'bring',
        Default = false,
        Callback = function(state)
            isEnabled = state

            if not state and currentBringTask1 then
                task.cancel(currentBringTask1)

                currentBringTask1 = nil
            end
            if state then
                if selectedPlayer == nil then
                    toggle:SetValue(false)

                    return
                end

                currentBringTask1 = task.spawn(StartBring)
            end
        end,
    })
	PlayerListGroup:AddButton('Set TargetAim', function()
	    if not selectedPlayer then
	        Library:Notify('No player selected')
	        return
	    end
	    if MultiTargetEnabled then
	        toggleTargetInList(selectedPlayer)
	        updateTargetLabel()
	        Library:Notify('Toggled ' .. selectedPlayer.DisplayName .. ' in list', 3)
	    else
	        DYHUBcc.TargetAim.Target = selectedPlayer.Name
	        updateTargetLabel()
	        Library:Notify('Target set to ' .. selectedPlayer.DisplayName)
	    end
	end)
    PlayerListGroup:AddToggle('SpectateToggle', {
        Text = 'Spectate',
        Default = false,
        Callback = function(Value)
            if Value then
                if not selectedPlayer then
                    Library:Notify('No player selected')

                    Toggles.SpectateToggle.Value = false

                    return
                end
                if spectateConnection then
                    spectateConnection:Disconnect()
                end

                spectateConnection = NewConnection(RunService.Heartbeat, function()
                    if not selectedPlayer then
                        Camera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild('Humanoid')
                        Toggles.SpectateToggle.Value = false

                        return
                    end

                    local char = selectedPlayer.Character
                    local hum = char and char:FindFirstChild('Humanoid')

                    if hum and hum.Health > 0 then
                        Camera.CameraSubject = hum
                    else
                        Camera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild('Humanoid')
                    end
                end)

                Library:Notify('Spectating ' .. selectedPlayer.DisplayName)
            else
                if spectateConnection then
                    spectateConnection:Disconnect()

                    spectateConnection = nil
                end

                Camera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild('Humanoid')
            end
        end,
    })
    PlayerListGroup:AddButton('Goto', function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild('HumanoidRootPart') then
            plr.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame

            Library:Notify('Teleported to ' .. selectedPlayer.DisplayName)
        else
            Library:Notify('No player selected or no HRP')
        end
    end)

    local MainPlacesGroup = Tabs.Player:AddLeftGroupbox('Main Places')

    MainPlacesGroup:AddButton('Bank', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-442, 39, -284))
    end)
    MainPlacesGroup:AddButton('Inside Bank', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-443, 23, -284))
    end)
    MainPlacesGroup:AddButton('Vault', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-658, -30, -285))
    end)
    MainPlacesGroup:AddButton('Mid Apartment Roof', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-323, 80, -299))
    end)
    MainPlacesGroup:AddButton('Revolver Shop', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-634, 21, -132))
    end)
    MainPlacesGroup:AddButton('LMG Shop', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-626, 23, -295))
    end)
    MainPlacesGroup:AddButton('Swimming Pool', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-847, 21, -279))
    end)
    MainPlacesGroup:AddButton('Broken Fire Station', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-1182, 28, -521))
    end)
    MainPlacesGroup:AddButton('Downhill Gun Shop', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-559, 8, -735))
    end)
    MainPlacesGroup:AddButton('Uphill Gun Shop', function()
        LocalPlayer.Character:PivotTo(CFrame.new(481, 48, -602))
    end)
    MainPlacesGroup:AddButton('Military Base', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-40, 65, -926))
    end)
    MainPlacesGroup:AddButton('Breaking Bad House', function()
        LocalPlayer.Character:PivotTo(CFrame.new(598, 28, -214))
    end)
    MainPlacesGroup:AddButton('Church', function()
        LocalPlayer.Character:PivotTo(CFrame.new(205, 21, -124))
    end)
    MainPlacesGroup:AddButton('Police Station', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-264, 21, -93))
    end)
    MainPlacesGroup:AddButton('School', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-594, 21, 173))
    end)

    local ExtraPlacesGroup = Tabs.Player:AddLeftGroupbox('Extra Places')

    ExtraPlacesGroup:AddButton('UFO', function()
        LocalPlayer.Character:PivotTo(CFrame.new(50, 138, -671))
    end)
    ExtraPlacesGroup:AddButton('Casino', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-866, 44, -156))
    end)
    ExtraPlacesGroup:AddButton('Gas Station', function()
        LocalPlayer.Character:PivotTo(CFrame.new(537, 47, -248))
    end)
    ExtraPlacesGroup:AddButton('Gym / Fitness', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-77, 22, -622))
    end)

    local FoodGroup = Tabs.Player:AddLeftGroupbox('Food Stores')

    FoodGroup:AddButton('Food Store #1', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-336, 23, -298))
    end)
    FoodGroup:AddButton('Food Store #2', function()
        LocalPlayer.Character:PivotTo(CFrame.new(299, 49, -617))
    end)
    FoodGroup:AddButton('Food Store #3', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-279, 22, -807))
    end)
    FoodGroup:AddButton('Food Store #4', function()
        LocalPlayer.Character:PivotTo(CFrame.new(584, 51, -477))
    end)
    FoodGroup:AddButton('Food Store #5', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-995, 25, -157))
    end)
    FoodGroup:AddButton('Food Store #6', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-903, 22, -670))
    end)

    local ArmorGroup = Tabs.Player:AddLeftGroupbox('Armor Locations')

    ArmorGroup:AddButton('Armor #1 (Downhill)', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-605, 10, -788))
    end)
    ArmorGroup:AddButton('Armor #2 (Uphill)', function()
        LocalPlayer.Character:PivotTo(CFrame.new(532, 50, -637))
    end)
    ArmorGroup:AddButton('Armor #3 (Sewer)', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-933, -28, 565))
    end)
    ArmorGroup:AddButton('Armor #4', function()
        LocalPlayer.Character:PivotTo(CFrame.new(409, 48, -50))
    end)
    ArmorGroup:AddButton('Armor #5 (Police)', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-257, 21, -78))
    end)
    ArmorGroup:AddButton('Armor #6', function()
        LocalPlayer.Character:PivotTo(CFrame.new(97, 23, -303))
    end)

    local SafeGroup = Tabs.Player:AddLeftGroupbox('Safe Zones')

    SafeGroup:AddButton('Safe Zone #1', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-55, -58, 146))
    end)
    SafeGroup:AddButton('Safe Zone #2', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-124, -58, 130))
    end)
    SafeGroup:AddButton('Safe Zone #3 (High)', function()
        LocalPlayer.Character:PivotTo(CFrame.new(-547, 173, -2))
    end)
end)()
task.wait(1)
coroutine.wrap(function()
    local TrollingBox = Tabs.Misc:AddLeftGroupbox('Trolling')

        local function include(module)
            return loadstring(game:HttpGet('https://raw.githubusercontent.com/penguin-cmyk/legion/refs/heads/main/utils/' .. module .. '.lua'))()
        end

        local DhLibrary = include('dh_library')
        local Animations = DhLibrary:Animations()
        local Services = DhLibrary:Services()
        local Sounds = DhLibrary:Sounds()
        local Modules = {}
        local States = {}
        local Tools = {}
        local MainEvent = Services.MainEvent
        local PlaceId = game.PlaceId
        local TeleportService = game:GetService('TeleportService')
        local LightingService = game:GetService('Lighting')
        local UserInputService = Services.UserInputService
        local ReplicatedStorage = Services.ReplicatedStorage
        local LocalPlayer = Services.LocalPlayer
        local RunService = Services.RunService
        local Workspace = Services.Workspace
        local Players = Services.Players
        local Skins = ReplicatedStorage:WaitForChild('Bike').Skins
        local Camera = Workspace.CurrentCamera
        local Starting = true
        local RoadRoller = game:GetObjects('rbxassetid://85904556439762')[1]
        local SonicRings = game:GetObjects('rbxassetid://107016840921635')[1]
        local BlackHole = game:GetObjects('rbxassetid://107558636253769')[1]
        local Spirit = game:GetObjects('rbxassetid://89731535148122')[1]
        local Charm = game:GetObjects('rbxassetid://139067309930404')[1]
        local Thanos = game:GetObjects('rbxassetid://129891025243944')[1]
        local AfterSlash = game:GetObjects('rbxassetid://102168430997910')[1]
        local TweenService = game:GetService('TweenService')
        local AssetService = game:GetService('AssetService')
        local Train = AssetService:CreateMeshPartAsync('rbxassetid://743576537')
        local Aura = AssetService:CreateMeshPartAsync('http://www.roblox.com/asset/?id=1323306')

        Aura.Color = Color3.fromRGB(4, 175, 236)
        Aura.Anchored = true
        Aura.Parent = workspace
        Aura.CanCollide = false
        Aura.CastShadow = false
        Train.TextureID = 'rbxassetid://743576568'
        Train.Anchored = true
        Train.Parent = workspace
        Train.CFrame = Train.CFrame * CFrame.Angles(0, -math.rad(90), 0)

        local ShakeModule = {}
        local shakeActive = false
        local shakeStartTime = 0
        local shakeDuration = 0.8
        local initialIntensity = 1
        local noise = math.noise

        local function updateCameraShake()
            if not shakeActive then
                return
            end

            local elapsed = os.clock() - shakeStartTime

            if elapsed >= shakeDuration then
                shakeActive = false

                return
            end

            local progress = elapsed / shakeDuration
            local currentIntensity = initialIntensity * (1 - progress ^ 2)
            local downwardOffset = Vector3.new(0, -0.5 * currentIntensity, 0)
            local bounceOffset = Vector3.new(0, 0.3 * currentIntensity * math.sin(progress * 10), 0)
            local timeFactor = os.clock() * 10
            local shakeX = noise(timeFactor, 0) * currentIntensity * 0.1
            local shakeY = noise(timeFactor, 100) * currentIntensity * 0.1
            local shakeZ = noise(timeFactor, 200) * currentIntensity * 0.1
            local rotX = noise(timeFactor, 300) * currentIntensity * 0.05
            local rotY = noise(timeFactor, 400) * currentIntensity * 0.05
            local rotZ = noise(timeFactor, 500) * currentIntensity * 0.05
            local offsetPosition = downwardOffset + bounceOffset + Vector3.new(shakeX, shakeY, shakeZ)
            local offsetRotation = CFrame.Angles(rotX, rotY, rotZ)

            Camera.CFrame = Camera.CFrame * CFrame.new(offsetPosition) * offsetRotation
        end

        function ShakeModule.StartShake(intensity, duration)
            initialIntensity = intensity or 1
            shakeDuration = duration or 0.8
            shakeStartTime = os.clock()
            shakeActive = true
        end

        DhLibrary:AddConnection('ShakeModule', Services.RunService.Heartbeat:Connect(updateCameraShake))

        do
            function Modules:VehicleFly()
                local Vehicle: Model = DhLibrary:GetCar()

                if not Vehicle or States.CurrentlyVehicleFlying then
                    States.AllowedVehicleFly = false
                    States.CurrentlyVehicleFlying = false

                    task.wait(0.2)

                    States.AllowedVehicleFly = true

                    return
                end

                States.CurrentlyVehicleFlying = true

                local BodyPosition = DhLibrary:Create('BodyPosition', {
                    Parent = Vehicle,
                    MaxForce = Vector3.new(9e9, 9e9, 9e9),
                    Position = Vehicle.Position,
                })
                local BodyGyro = DhLibrary:Create('BodyGyro', {
                    Parent = Vehicle,
                    MaxTorque = Vector3.new(9e9, 9e9, 9e9),
                    CFrame = Vehicle.CFrame,
                })

                DhLibrary:AddConnection('VehicleFly', NewConnection(RunService.Heartbeat, function()
                    if not States.AllowedVehicleFly then
                        DhLibrary:RemoveConnection('VehicleFly')
                        BodyPosition:Destroy()
                        BodyGyro:Destroy()

                        return
                    end

                    local Speed: number = States.VehicleFlySpeed or 2
                    local MoveDirection: Vector3 = Vector3.new(UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or (UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0), UserInputService:IsKeyDown(Enum.KeyCode.Space) and 0.2, UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0))

                    BodyGyro.CFrame = CFrame.new(Vehicle.Position) * Camera.CFrame.Rotation
                    BodyPosition.Position = BodyPosition.Position + (BodyGyro.CFrame.LookVector * MoveDirection.Z + BodyGyro.CFrame.RightVector * MoveDirection.X + Vector3.new(0, MoveDirection.Y, 0)) * Speed
                end))
            end
        end

        local lastStompTime = 0
        local STOMP_COOLDOWN = 2
        local STOMP_EFFECT = 'Thanos'

        do
            local function boobs(targetCharacter)
                STOMP_EFFECT = States.StompEffect or 'Thanos'

                local currentTime = tick()

                if currentTime - lastStompTime < STOMP_COOLDOWN then
                    return
                end

                lastStompTime = currentTime

                if STOMP_EFFECT == 'RoadRoller' then
                    RoadRoller.Parent = workspace
                    RoadRoller.Anchored = true
                    RoadRoller.CFrame = targetCharacter.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0)

                    local Sound = Instance.new('Sound', workspace)

                    Sound.SoundId = 'rbxassetid://4877348549'
                    Sound.PlayOnRemove = true

                    Sound:Destroy()
                    TweenService:Create(RoadRoller, TweenInfo.new(0.2), {
                        CFrame = targetCharacter.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(math.rad(200), -math.rad(200), math.rad(90)),
                    }):Play()
                    ShakeModule.StartShake(7, 0.5)
                    task.wait(2)

                    RoadRoller.CFrame = CFrame.new(20, 2000, 20)
                elseif STOMP_EFFECT == 'Rings' then
                    local Sound = Instance.new('Sound', workspace)

                    Sound.SoundId = 'rbxassetid://7456436580'
                    Sound.PlayOnRemove = true

                    Sound:Destroy()

                    local FakePart = Instance.new('Part', workspace)

                    FakePart.Transparency = 1
                    FakePart.Position = targetCharacter.Head.Position
                    FakePart.Anchored = true
                    FakePart.CanCollide = false
                    SonicRings.Parent = FakePart

                    task.wait(0.5)

                    SonicRings.Parent = workspace

                    FakePart:Destroy()
                elseif STOMP_EFFECT == 'BlackHole' then
                    BlackHole.Parent = workspace
                    BlackHole.Position = targetCharacter:FindFirstChild('UpperTorso').Position + Vector3.new(0, 1, 0)

                    BlackHole.open:Play()
                    ShakeModule.StartShake(7, 0.5)

                    for _, emitter in pairs(BlackHole:GetDescendants())do
                        if emitter:IsA('ParticleEmitter') or emitter:IsA('Beam') then
                            emitter.Enabled = true
                        end
                    end

                    task.wait(1.5)
                    task.spawn(function()
                        BlackHole.wind:Play()
                        BlackHole.bring:Play()

                        for _, part in pairs(targetCharacter:GetChildren())do
                            if not part:IsA('BasePart') then
                                continue
                            end

                            TweenService:Create(part, TweenInfo.new(1.4), {
                                Position = BlackHole.Event.WorldPosition,
                            }):Play()
                        end

                        task.wait(1.5)
                        targetCharacter:Destroy()
                    end)
                    task.wait(3)
                    TweenService:Create(BlackHole.wind, TweenInfo.new(0.5), {Volume = 0}):Play()

                    for _, emitter in pairs(BlackHole:GetDescendants())do
                        if emitter:IsA('ParticleEmitter') or emitter:IsA('Beam') then
                            emitter.Enabled = false
                        end
                    end

                    task.wait(2)

                    BlackHole.Parent = Services.ReplicatedStorage
                elseif STOMP_EFFECT == 'Spirit' then
                    Spirit.Stomp:Play()

                    Aura.Transparency = 0
                    Aura.Position = targetCharacter:FindFirstChild('UpperTorso').Position

                    ShakeModule.StartShake(7, 0.5)
                    TweenService:Create(Aura, TweenInfo.new(2), {
                        Position = targetCharacter:FindFirstChild('UpperTorso').Position + Vector3.new(0, 50, 0),
                        Size = Vector3.new(120, 90, 120),
                        Transparency = 1,
                    }):Play()

                    local Sound = Instance.new('Sound', workspace)

                    Sound.SoundId = 'rbxassetid://6290067239'
                    Sound.PlayOnRemove = true

                    Sound:Destroy()

                    for _, asset in pairs(targetCharacter:GetDescendants())do
                        if not asset:IsA('BasePart') or not asset:IsA('Decal') then
                            continue
                        end

                        TweenService:Create(asset, TweenInfo.new(0.5), {Transparency = 1}):Play()
                    end
                elseif STOMP_EFFECT == 'Charm' then
                    local Stomp = Charm.FX.Stomp
                    local Sound = Charm.SFX:FindFirstChild('Explosive Hit 5')
                    local TargetPos = targetCharacter:FindFirstChild('UpperTorso').Position
                    local Emitters = {}
                    local PartOne = Stomp.PartOne:Clone()
                    local Part = Stomp.Part:Clone()

                    Charm.Parent = workspace
                    PartOne.Position = TargetPos
                    PartOne.Anchored = true
                    PartOne.Parent = workspace
                    Part.Position = TargetPos
                    Part.Anchored = true
                    Part.Parent = workspace

                    for _, emitter in pairs(PartOne:GetDescendants())do
                        if emitter:IsA('ParticleEmitter') then
                            table.insert(Emitters, emitter)
                        end
                    end
                    for _, emitter in pairs(Part:GetDescendants())do
                        if emitter:IsA('ParticleEmitter') then
                            table.insert(Emitters, emitter)
                        end
                    end
                    for _, emitter in pairs(Emitters)do
                        emitter.Enabled = true
                    end

                    local old_color = LightingService.FogColor

                    Sound:Play()

                    for _, asset in pairs(targetCharacter:GetDescendants())do
                        if not asset:IsA('BasePart') or not asset:IsA('Decal') then
                            continue
                        end

                        TweenService:Create(asset, TweenInfo.new(0.5), {Transparency = 1}):Play()
                    end

                    TweenService:Create(LightingService, TweenInfo.new(0.5), {
                        FogColor = Color3.fromRGB(255, 42, 191),
                    }):Play()
                    task.wait(0.8)
                    Part:Destroy()
                    PartOne:Destroy()
                    TweenService:Create(LightingService, TweenInfo.new(0.5), {FogColor = old_color}):Play()

                    Charm.Parent = Services.ReplicatedStorage
                elseif STOMP_EFFECT == 'Thanos' then
                    local Sound = Instance.new('Sound', workspace)

                    Sound.SoundId = 'rbxassetid://3050376525'

                    Sound:Play()

                    for _, part in pairs(targetCharacter:GetDescendants())do
                        if part:IsA('BasePart') or part:IsA('MeshPart') then
                            local Thanos_Effect = Thanos:Clone()

                            Thanos_Effect.Parent = part
                            Thanos_Effect.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, part.Color),
                                ColorSequenceKeypoint.new(0.6, Color3.fromRGB(65, 33, 18)),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
                            })

                            TweenService:Create(part, TweenInfo.new(0.5), {Transparency = 1}):Play()
                            task.delay(0.5, function()
                                Thanos_Effect.Enabled = false
                            end)
                            task.wait(0.1)
                        end
                    end

                    repeat
                        task.wait()
                    until Sound.TimeLength == 0

                    Sound:Destroy()
                elseif STOMP_EFFECT == 'Afterslash' then
                    local AfterSlashEfx = AfterSlash:Clone()
                    local UpperTorso = targetCharacter:FindFirstChild('UpperTorso')

                    UpperTorso.Position = (CFrame.new(UpperTorso.Position) * CFrame.new(0, 35, 0)).Position

                    local Part = AfterSlashEfx.Part

                    Part.Position = UpperTorso.Position
                    Part.Parent = UpperTorso
                    Part.Size = Vector3.new(5, 7, 5)

                    for _ = 1, 25 do
                        task.wait(math.random(1, 9) / 100)

                        local Sound = Instance.new('Sound', Part)

                        Sound.SoundId = 'rbxassetid://5989945551'

                        local DistortionSoundEffect = Instance.new('DistortionSoundEffect', Sound)

                        Sound.PlayOnRemove = true

                        Sound:Destroy()

                        Part.Position = UpperTorso.Position
                    end

                    UpperTorso.Position = (CFrame.new(UpperTorso.Position) * CFrame.new(0, -5, 0)).Position

                    for _, emitter in pairs(Part:GetDescendants())do
                        if emitter:IsA('ParticleEmitter') then
                            emitter.Enabled = false
                        end
                    end

                    task.wait(0.25)

                    local Attachment = Instance.new('Attachment', workspace.Terrain)

                    Attachment.WorldPosition = UpperTorso.Position

                    local Sound = Instance.new('Sound', Part)

                    Sound.SoundId = 'rbxassetid://4471648128'
                    Sound.PlayOnRemove = true

                    Sound:Destroy()

                    for _, emitter in pairs(AfterSlashEfx.Burst:GetDescendants())do
                        if emitter:IsA('ParticleEmitter') then
                            emitter.Parent = Attachment

                            emitter:Emit(emitter:GetAttribute('EmitCount'))
                        end
                    end
                    for _, part in pairs(targetCharacter:GetDescendants())do
                        if part:IsA('BasePart') then
                            TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Transparency = 1}):Play()
                        end
                    end
                end
            end

            function Modules:StompEffects(state)
                if not state then
                    DhLibrary:RemoveConnection('StompEffect')

                    return
                end

                DhLibrary:AddConnection('StompEffect', NewConnection(RunService.Heartbeat, function()
                    local playerCharacter = LocalPlayer.Character

                    if not playerCharacter or not playerCharacter:FindFirstChild('LowerTorso') or not playerCharacter:FindFirstChild('UpperTorso') then
                        return
                    end

                    local rayOrigin = playerCharacter.LowerTorso.Position
                    local rayDirection = Vector3.new(0, -playerCharacter.UpperTorso.Size.y * 4.5, 0)
                    local whitelist = {}

                    for _, player in ipairs(Services.Players:GetPlayers())do
                        if player ~= Services.LocalPlayer and player.Character and not whitelist[player.Character] then
                            table.insert(whitelist, player.Character)
                        end
                    end

                    if #whitelist > 0 then
                        local hitPart, hitPosition, hitNormal = workspace:FindPartOnRayWithWhitelist(Ray.new(rayOrigin, rayDirection), whitelist, false, true)

                        if hitPart then
                            local stompedCharacter = hitPart:FindFirstAncestorOfClass('Model')

                            if stompedCharacter and stompedCharacter:FindFirstChild('HumanoidRootPart') and stompedCharacter:FindFirstChild('BodyEffects') and stompedCharacter.BodyEffects.SDeath.Value and DhLibrary:IsAnimPlaying(playerCharacter, 2816431506) then
                                boobs(stompedCharacter)
                            end
                        end
                    end
                end))
            end
        end

        MovementGroup:AddToggle('VFly', {
            Text = 'Toggle Vehicle Fly',
            Default = false,
            Callback = function(state)
                States.AllowedVehicleFly = state
            end,
        }):AddKeyPicker('Vehicle Fly', {
            Text = '',
            Default = 'F',
            Mode = 'Toggle',
            SyncToggleState = false,
            Callback = function(key)
                Modules:VehicleFly()
            end,
        })
        MovementGroup:AddSlider('VFlySpeed', {
            Text = 'Vehicle Fly Speed',
            Default = 2,
            Min = 1,
            Max = 20,
            Rounding = 1,
            Compact = false,
            Callback = function(value)
                States.VehicleFlySpeed = value
            end,
        })

        local StompEffects = Tabs.Visual:AddLeftGroupbox('StompEffects')

        StompEffects:AddToggle('StompEffects', {
            Text = 'Stompeffects',
            Default = false,
            Callback = function(state)
                Modules:StompEffects(state)
            end,
        })
        StompEffects:AddDropdown('Dropdown', {
            Text = 'Select stomp effect',
            Values = {
                'Spirit',
                'RoadRoller',
                'Rings',
                'BlackHole',
                'Charm',
                'Thanos',
                'Afterslash',
            },
            Default = 'Thanos',
            Multi = false,
            Callback = function(value)
                States.StompEffect = value
            end,
        })

        do
            local LocalPlayer = game:GetService('Players').LocalPlayer
            local RunService = game:GetService('RunService')
            local ReplicatedStorage = game:GetService('ReplicatedStorage')
            local Grabbed = false
            local Up = false
            local ToolStates = {
                Neckgrab = false,
                Up = false,
                Air = false,
                Throw = false,
                HeavenThrow = false,
                Punch = false,
                RipInHalf = false,
                Void = false,
                Orbit = false,
                Bend = false,
                Blow = false,
            }

            local function CreateNeckgrabTool()
                local tool = Instance.new('Tool')

                tool.RequiresHandle = false
                tool.Name = 'Activate Neckgrab'
                tool.Parent = LocalPlayer.Backpack

                tool.Activated:Connect(function()
                    ReplicatedStorage.MainEvent:FireServer('Grabbing', true)

                    repeat
                        task.wait(0.1)
                    until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('BodyEffects') and LocalPlayer.Character.BodyEffects:FindFirstChild('Grabbed') and LocalPlayer.Character.BodyEffects.Grabbed.Value ~= nil and LocalPlayer.Character.BodyEffects.Grabbed.Value ~= ''

                    local targetName = tostring(LocalPlayer.Character.BodyEffects.Grabbed.Value)
                    local targetPlayer = game.Players:FindFirstChild(targetName)

                    if not targetPlayer or not targetPlayer.Character then
                        return
                    end

                    local targetChar = targetPlayer.Character
                    local targetTorso = targetChar:FindFirstChild('UpperTorso')

                    if not targetTorso then
                        return
                    end

                    Grabbed = true

                    local constraint = targetChar:FindFirstChild('GRABBING_CONSTRAINT')

                    if constraint and constraint:FindFirstChild('H') then
                        constraint.H.Length = math.huge
                    end

                    for _, track in pairs(LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks())do
                        if track.Animation.AnimationId == 'rbxassetid://11075367458' then
                            track:Stop()
                        end
                    end

                    task.spawn(function()
                        local anim = Instance.new('Animation')

                        anim.AnimationId = 'rbxassetid://3135389157'

                        local loaded = LocalPlayer.Character.Humanoid:LoadAnimation(anim)

                        loaded.Priority = Enum.AnimationPriority.Action

                        loaded:Play()
                        loaded:AdjustSpeed(0.2)
                        wait(0.8)
                        loaded:AdjustSpeed(0)
                    end)

                    if not targetTorso:FindFirstChild('BodyPosition') then
                        local bodypos = Instance.new('BodyPosition')

                        bodypos.Name = 'BodyPosition'
                        bodypos.D = 200
                        bodypos.MaxForce = Vector3.new(10000, 10000, 10000)
                        bodypos.Parent = targetTorso
                    end
                    if not targetTorso:FindFirstChild('BodyGyro') then
                        local bodygyro = Instance.new('BodyGyro')

                        bodygyro.Name = 'BodyGyro'
                        bodygyro.D = 100
                        bodygyro.MaxTorque = Vector3.new(10000, 10000, 10000)
                        bodygyro.Parent = targetTorso
                    end

                    RunService:BindToRenderStep('Pos', Enum.RenderPriority.Character.Value, function()
                        local hand = LocalPlayer.Character:FindFirstChild('RightHand')
                        local root = LocalPlayer.Character:FindFirstChild('HumanoidRootPart')

                        if hand and root then
                            targetTorso.BodyPosition.Position = hand.Position + Vector3.new(0, -0.7, 0)
                            targetTorso.BodyGyro.CFrame = CFrame.new(targetTorso.Position, root.Position)
                        end
                    end)
                    LocalPlayer.Character.BodyEffects.Grabbed:GetPropertyChangedSignal('Value'):Connect(function()
                        if LocalPlayer.Character.BodyEffects.Grabbed.Value == nil or LocalPlayer.Character.BodyEffects.Grabbed.Value == '' then
                            Grabbed = false
                            Up = false

                            RunService:UnbindFromRenderStep('Pos')

                            for _, track in pairs(LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks())do
                                local id = track.Animation.AnimationId

                                if id == 'rbxassetid://3135389157' or id == 'rbxassetid://14496531574' or id == 'rbxassetid://3096047107' then
                                    track:Stop()
                                end
                            end

                            if targetTorso:FindFirstChild('BodyPosition') then
                                targetTorso.BodyPosition:Destroy()
                            end
                            if targetTorso:FindFirstChild('BodyGyro') then
                                targetTorso.BodyGyro:Destroy()
                            end
                        end
                    end)
                end)
            end
            local function CreateUpTool()
                local tool = Instance.new('Tool')

                tool.RequiresHandle = false
                tool.Name = 'Up'
                tool.Parent = LocalPlayer.Backpack

                tool.Activated:Connect(function()
                    if Grabbed == true then
                        if Up == false then
                            local target = tostring(LocalPlayer.Character.BodyEffects.Grabbed.Value)

                            Up = true

                            for _, Track in pairs(LocalPlayer.Character:WaitForChild('Humanoid'):GetPlayingAnimationTracks())do
                                if Track.Animation.AnimationId == 'rbxassetid://3135389157' then
                                    Track:Stop()
                                end
                            end

                            spawn(function()
                                local Animation = Instance.new('Animation')

                                Animation.AnimationId = 'rbxassetid://14496531574'

                                local LoadAnimation = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid'):LoadAnimation(Animation)

                                LoadAnimation.Priority = Enum.AnimationPriority.Action

                                LoadAnimation:Play()
                                LoadAnimation:AdjustSpeed(1)
                                wait(1)
                                LoadAnimation:AdjustSpeed(0)
                            end)
                            spawn(function()
                                wait(0.3)
                                RunService:UnbindFromRenderStep('Pos')
                                wait(0.05)
                                RunService:BindToRenderStep('Pos', 0, function()
                                    game.Players[target].Character.UpperTorso.BodyPosition.Position = LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 8 + Vector3.new(0, 23, 0)
                                    game.Players[target].Character.UpperTorso.BodyGyro.CFrame = CFrame.new(game.Players[target].Character.UpperTorso.Position, LocalPlayer.Character.HumanoidRootPart.Position)
                                end)

                                game.Players[target].Character.UpperTorso.BodyPosition.D = 1200
                            end)
                        else
                            for _, Track in pairs(LocalPlayer.Character:WaitForChild('Humanoid'):GetPlayingAnimationTracks())do
                                if Track.Animation.AnimationId == 'rbxassetid://14496531574' then
                                    Track:Stop(1)
                                end
                            end

                            spawn(function()
                                wait(0.45)

                                local Animation = Instance.new('Animation')

                                Animation.AnimationId = 'rbxassetid://3135389157'

                                local LoadAnimation = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid'):LoadAnimation(Animation)

                                LoadAnimation.Priority = Enum.AnimationPriority.Action

                                LoadAnimation:Play()
                                LoadAnimation:AdjustSpeed(0.2)
                                task.wait(0.8)
                                LoadAnimation:AdjustSpeed(0)
                            end)

                            local target = tostring(LocalPlayer.Character.BodyEffects.Grabbed.Value)

                            RunService:UnbindFromRenderStep('Pos')

                            Up = false

                            RunService:BindToRenderStep('Pos', 0, function()
                                game.Players[target].Character.UpperTorso.BodyPosition.Position = LocalPlayer.Character.RightHand.Position + Vector3.new(0, -0.7, 0)
                                game.Players[target].Character.UpperTorso.BodyGyro.CFrame = CFrame.new(game.Players[target].Character.UpperTorso.Position, LocalPlayer.Character.HumanoidRootPart.Position)
                            end)
                            wait(1)

                            game.Players[target].Character.UpperTorso.BodyPosition.D = 200
                        end
                    end
                end)
            end
            local function CreateAirTool()
                local tool = Instance.new('Tool')

                tool.RequiresHandle = false
                tool.Name = 'Air'
                tool.Parent = LocalPlayer.Backpack

                tool.Activated:Connect(function()
                    if Grabbed == true then
                        if Up == false then
                            local target = tostring(LocalPlayer.Character.BodyEffects.Grabbed.Value)

                            Up = true

                            for _, Track in pairs(LocalPlayer.Character:WaitForChild('Humanoid'):GetPlayingAnimationTracks())do
                                if Track.Animation.AnimationId == 'rbxassetid://3135389157' then
                                    Track:Stop()
                                end
                            end

                            spawn(function()
                                local Animation = Instance.new('Animation')

                                Animation.AnimationId = 'rbxassetid://14496531574'

                                local LoadAnimation = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid'):LoadAnimation(Animation)

                                LoadAnimation.Priority = Enum.AnimationPriority.Action

                                LoadAnimation:Play()
                                LoadAnimation:AdjustSpeed(1)
                                wait(1)
                                LoadAnimation:AdjustSpeed(0)
                            end)
                            spawn(function()
                                wait(0.3)
                                RunService:UnbindFromRenderStep('Pos')
                                wait(0.05)
                                RunService:BindToRenderStep('Pos', 0, function()
                                    local char = LocalPlayer.Character
                                    local targetChar = game.Players[target].Character
                                    local behindPosition = char.HumanoidRootPart.Position - char.HumanoidRootPart.CFrame.LookVector * 5 + Vector3.new(0, 9, 0)

                                    targetChar.UpperTorso.BodyPosition.Position = behindPosition
                                    targetChar.UpperTorso.BodyGyro.CFrame = CFrame.new(targetChar.UpperTorso.Position, char.HumanoidRootPart.Position)
                                end)

                                game.Players[target].Character.UpperTorso.BodyPosition.D = 1200
                            end)
                        else
                            for _, Track in pairs(LocalPlayer.Character:WaitForChild('Humanoid'):GetPlayingAnimationTracks())do
                                if Track.Animation.AnimationId == 'rbxassetid://14496531574' then
                                    Track:Stop(1)
                                end
                            end

                            spawn(function()
                                wait(0.45)

                                local Animation = Instance.new('Animation')

                                Animation.AnimationId = 'rbxassetid://3135389157'

                                local LoadAnimation = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid'):LoadAnimation(Animation)

                                LoadAnimation.Priority = Enum.AnimationPriority.Action

                                LoadAnimation:Play()
                                LoadAnimation:AdjustSpeed(0.2)
                                task.delay(2, function()
                                    LoadAnimation:Stop()
                                end)
                                task.wait(0.8)
                                LoadAnimation:AdjustSpeed(0)
                            end)

                            local target = tostring(LocalPlayer.Character.BodyEffects.Grabbed.Value)

                            RunService:UnbindFromRenderStep('Pos')

                            Up = false

                            RunService:BindToRenderStep('Pos', 0, function()
                                local char = LocalPlayer.Character
                                local targetChar = game.Players[target].Character

                                targetChar.UpperTorso.BodyPosition.Position = char.RightHand.Position + Vector3.new(0, -0.7, 0)
                                targetChar.UpperTorso.BodyGyro.CFrame = CFrame.new(targetChar.UpperTorso.Position, char.HumanoidRootPart.Position)
                            end)
                            wait(1)

                            game.Players[target].Character.UpperTorso.BodyPosition.D = 200
                        end
                    end
                end)
            end
            local function CreateThrowTool()
                local tool = Instance.new('Tool')

                tool.RequiresHandle = false
                tool.Name = 'Throw'
                tool.Parent = LocalPlayer.Backpack

                tool.Activated:Connect(function()
                    if Grabbed == true then
                        if Up == false then
                            local target = tostring(LocalPlayer.Character.BodyEffects.Grabbed.Value)

                            for _, Track in pairs(LocalPlayer.Character:WaitForChild('Humanoid'):GetPlayingAnimationTracks())do
                                if Track.Animation.AnimationId == 'rbxassetid://3135389157' then
                                    Track:Stop()
                                end
                            end

                            local Animation = Instance.new('Animation')

                            Animation.AnimationId = 'rbxassetid://3096047107'

                            local LoadAnimation = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid'):LoadAnimation(Animation)

                            LoadAnimation.Priority = Enum.AnimationPriority.Action

                            LoadAnimation:Play()
                            LoadAnimation:AdjustSpeed(1)
                            wait(0.2)

                            game.Players[target].Character.UpperTorso.BodyPosition.D = 900

                            RunService:UnbindFromRenderStep('Pos')
                            game.Players[target].Character.UpperTorso:FindFirstChild('BodyGyro'):Destroy()

                            game.Players[target].Character.UpperTorso.BodyPosition.Position = LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 150 + Vector3.new(0, 5, 0)

                            wait(0.5)
                            game.Players[target].Character.UpperTorso:FindFirstChild('BodyPosition'):Destroy()
                            ReplicatedStorage.MainEvent:FireServer('Grabbing', false)
                        end
                    end
                end)
            end
            local function CreateHeavenThrowTool()
                local tool = Instance.new('Tool')

                tool.RequiresHandle = false
                tool.Name = 'Heaven Throw'
                tool.Parent = LocalPlayer.Backpack

                tool.Activated:Connect(function()
                    if Grabbed == true then
                        if Up == false then
                            local target = tostring(LocalPlayer.Character.BodyEffects.Grabbed.Value)

                            for _, Track in pairs(LocalPlayer.Character:WaitForChild('Humanoid'):GetPlayingAnimationTracks())do
                                if Track.Animation.AnimationId == 'rbxassetid://3135389157' then
                                    Track:Stop()
                                end
                            end

                            local Animation = Instance.new('Animation')

                            Animation.AnimationId = 'rbxassetid://14496531574'

                            local LoadAnimation = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid'):LoadAnimation(Animation)

                            LoadAnimation.Priority = Enum.AnimationPriority.Action

                            LoadAnimation:Play()
                            LoadAnimation:AdjustSpeed(1)
                            wait(0.4)
                            RunService:UnbindFromRenderStep('Pos')
                            game.Players[target].Character.UpperTorso:FindFirstChild('BodyGyro'):Destroy()
                            wait(0.01)

                            game.Players[target].Character.UpperTorso.BodyPosition.D = 200
                            game.Players[target].Character.UpperTorso.BodyPosition.Position = LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 3 + Vector3.new(0, 3000, 0)

                            wait(2)
                            ReplicatedStorage.MainEvent:FireServer('Grabbing', false)
                        end
                    end
                end)
            end
            local function CreatePunchTool()
                local tool = Instance.new('Tool')

                tool.RequiresHandle = false
                tool.Name = 'Punch'
                tool.Parent = LocalPlayer.Backpack

                tool.Activated:Connect(function()
                    if Grabbed == true then
                        if Up == false then
                            local target = tostring(LocalPlayer.Character.BodyEffects.Grabbed.Value)

                            for _, Track in pairs(LocalPlayer.Character:WaitForChild('Humanoid'):GetPlayingAnimationTracks())do
                                if Track.Animation.AnimationId == 'rbxassetid://3135389157' then
                                    Track:Stop()
                                end
                            end

                            RunService:UnbindFromRenderStep('Pos')
                            RunService:BindToRenderStep('Pos', 0, function()
                                game.Players[target].Character.UpperTorso.BodyGyro.CFrame = CFrame.new(game.Players[target].Character.UpperTorso.Position, LocalPlayer.Character.HumanoidRootPart.Position)
                            end)

                            game.Players[target].Character.UpperTorso.BodyPosition.D = 3400
                            game.Players[target].Character.UpperTorso.BodyPosition.Position = LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 3 + Vector3.new(0, 1, 0)

                            local Animation = Instance.new('Animation')

                            Animation.AnimationId = 'rbxassetid://3354696735'

                            local LoadAnimation = LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(Animation)

                            LoadAnimation.Priority = Enum.AnimationPriority.Action

                            LoadAnimation:Play()
                            wait(1)
                            game.Players[target].Character.UpperTorso:FindFirstChild('BodyPosition'):Destroy()
                            RunService:UnbindFromRenderStep('Pos')
                            game.Players[target].Character.UpperTorso:FindFirstChild('BodyGyro'):Destroy()

                            for i = 1, 2 do
                                wait()

                                game.Players[target].Character.UpperTorso.Velocity = Vector3.new(LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector.X * 950, -200, LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector.Z * 950)
                            end
                        end
                    end

                    wait(1)
                    ReplicatedStorage.MainEvent:FireServer('Grabbing', false)
                end)
            end
            local function CreateRipInHalfTool()
                local tool = Instance.new('Tool')

                tool.RequiresHandle = false
                tool.Name = 'Rip In Half'
                tool.Parent = LocalPlayer.Backpack

                tool.Activated:Connect(function()
                    if Grabbed == true then
                        if Up == false then
                            local target = tostring(LocalPlayer.Character.BodyEffects.Grabbed.Value)

                            for _, Track in pairs(LocalPlayer.Character:WaitForChild('Humanoid'):GetPlayingAnimationTracks())do
                                if Track.Animation.AnimationId == 'rbxassetid://3135389157' then
                                    Track:Stop()
                                end
                            end

                            local Animation1 = Instance.new('Animation')

                            Animation1.AnimationId = 'rbxassetid://13850666420'

                            local LoadAnimation1 = LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(Animation1)

                            LoadAnimation1.Priority = Enum.AnimationPriority.Action

                            LoadAnimation1:Play()

                            local Animation2 = Instance.new('Animation')

                            Animation2.AnimationId = 'rbxassetid://13850675130'

                            local LoadAnimation2 = LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(Animation2)

                            LoadAnimation2.Priority = Enum.AnimationPriority.Action

                            LoadAnimation2:Play()
                            RunService:UnbindFromRenderStep('Pos')
                            RunService:BindToRenderStep('Pos', 0, function()
                                game.Players[target].Character.UpperTorso.BodyGyro.CFrame = CFrame.new(game.Players[target].Character.UpperTorso.Position, LocalPlayer.Character.HumanoidRootPart.Position)
                                game.Players[target].Character.UpperTorso.BodyPosition.Position = LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 2 + Vector3.new(0, 0.2, 0)
                            end)
                            task.wait(0.2)

                            game.Players[target].Character.LowerTorso.Position = Vector3.new(0, -12E2, 0)

                            RunService:UnbindFromRenderStep('Pos')
                            task.wait(0.2)
                            game.Players[target].Character.UpperTorso:FindFirstChild('BodyPosition'):Destroy()
                            game.Players[target].Character.UpperTorso:FindFirstChild('BodyGyro'):Destroy()
                            task.wait(0.1)

                            game.Players[target].Character.UpperTorso.Velocity = LocalPlayer.Character.HumanoidRootPart.CFrame.RightVector * 90
                            game.Players[target].Character.RightUpperLeg.Velocity = LocalPlayer.Character.HumanoidRootPart.CFrame.RightVector * -90
                            game.Players[target].Character.LeftUpperLeg.Velocity = LocalPlayer.Character.HumanoidRootPart.CFrame.RightVector * -90

                            task.wait(0.3)
                            ReplicatedStorage.MainEvent:FireServer('Grabbing', false)
                            task.wait(0.2)
                            LoadAnimation1:Stop(0.3)
                            LoadAnimation2:Stop(0.3)
                        end
                    end
                end)
            end
            local function CreateVoidTool()
                local tool = Instance.new('Tool')

                tool.RequiresHandle = false
                tool.Name = 'Void'
                tool.Parent = LocalPlayer.Backpack

                tool.Activated:Connect(function()
                    if Grabbed == true then
                        if Up == false then
                            local target = tostring(LocalPlayer.Character.BodyEffects.Grabbed.Value)

                            wait(0.3)

                            for _, Track in pairs(LocalPlayer.Character:WaitForChild('Humanoid'):GetPlayingAnimationTracks())do
                                if Track.Animation.AnimationId == 'rbxassetid://3135389157' then
                                    Track:Stop()
                                end
                            end

                            game.Players[target].Character.UpperTorso.BodyPosition.D = 1200

                            RunService:UnbindFromRenderStep('Pos')
                            RunService:BindToRenderStep('Pos', 0, function()
                                game.Players[target].Character.UpperTorso.BodyGyro.CFrame = CFrame.new(game.Players[target].Character.UpperTorso.Position, LocalPlayer.Character.HumanoidRootPart.Position)
                            end)

                            game.Players[target].Character.UpperTorso.BodyPosition.Position = LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 4 + Vector3.new(0, 1.4, 0)

                            local Animation = Instance.new('Animation')

                            Animation.AnimationId = 'rbxassetid://14774699952'

                            local LoadAnimation = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid'):LoadAnimation(Animation)

                            LoadAnimation.Priority = Enum.AnimationPriority.Action

                            LoadAnimation:Play()
                            LoadAnimation:AdjustSpeed(0.4)
                            wait(2)
                            game.Players[target].Character.UpperTorso:FindFirstChild('BodyPosition'):Destroy()
                            game.Players[target].Character.UpperTorso:FindFirstChild('BodyGyro'):Destroy()

                            for _, v in pairs(game.Players[target].Character:GetChildren())do
                                if v:IsA('MeshPart') then
                                    v.Position = Vector3.new(0, -600, 0)
                                end
                            end

                            wait(0.2)
                            LoadAnimation:Stop()
                            ReplicatedStorage.MainEvent:FireServer('Grabbing', false)
                        end
                    end
                end)
            end

            local orbiting = false
            local theta = 0
            local orbitConnection

            local function CreateOrbitTool()
                local tool = Instance.new('Tool')

                tool.RequiresHandle = false
                tool.Name = 'Orbit'
                tool.Parent = LocalPlayer.Backpack

                tool.Activated:Connect(function()
                    if Grabbed ~= true then
                        return
                    end

                    local targetName = tostring(LocalPlayer.Character.BodyEffects.Grabbed.Value)
                    local targetPlayer = game.Players:FindFirstChild(targetName)

                    if not targetPlayer or not targetPlayer.Character then
                        return
                    end

                    local targetChar = targetPlayer.Character
                    local targetTorso = targetChar:FindFirstChild('UpperTorso')

                    if not targetTorso then
                        return
                    end
                    if not targetTorso:FindFirstChild('BodyPosition') then
                        local bp = Instance.new('BodyPosition')

                        bp.Name = 'BodyPosition'
                        bp.D = 200
                        bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        bp.Parent = targetTorso
                    end
                    if not targetTorso:FindFirstChild('BodyGyro') then
                        local bg = Instance.new('BodyGyro')

                        bg.Name = 'BodyGyro'
                        bg.D = 100
                        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                        bg.Parent = targetTorso
                    end
                    if orbiting then
                        orbiting = false

                        if orbitConnection then
                            orbitConnection:Disconnect()

                            orbitConnection = nil
                        end

                        RunService:BindToRenderStep('Pos', 0, function()
                            local hand = LocalPlayer.Character:FindFirstChild('RightHand')

                            if hand then
                                targetTorso.BodyPosition.Position = hand.Position + Vector3.new(0, -0.7, 0)
                                targetTorso.BodyGyro.CFrame = CFrame.new(targetTorso.Position, LocalPlayer.Character.HumanoidRootPart.Position)
                            end
                        end)

                        targetTorso.BodyPosition.D = 200
                    else
                        orbiting = true
                        theta = 0

                        if orbitConnection then
                            orbitConnection:Disconnect()
                        end

                        orbitConnection = RunService.RenderStepped:Connect(function()
                            local root = LocalPlayer.Character:FindFirstChild('HumanoidRootPart')

                            if not root then
                                return
                            end

                            theta += 0.6

                            local radius = 20
                            local height = 3
                            local offset = Vector3.new(math.cos(theta) * radius, height, math.sin(theta) * radius)
                            local orbitPos = root.Position + offset

                            targetTorso.BodyPosition.Position = orbitPos
                            targetTorso.BodyGyro.CFrame = CFrame.new(targetTorso.Position, root.Position)
                        end)
                        targetTorso.BodyPosition.D = 1200
                    end
                end)
            end

            local IM = game:GetService('ReplicatedStorage').IM.ANIM
            local PlayersChar = workspace.Players

            if _G.JOINTWATCHER then
                _G.JOINTWATCHER:Disconnect()
            end

            local function Align(P0, P1, P, R)
                local A0, A1 = Instance.new('Attachment', P0), Instance.new('Attachment', P1)
                local AP, AO = Instance.new('AlignPosition', P0), Instance.new('AlignOrientation', P0)

                A1.Position = P
                A0.Rotation = R
                AP.RigidityEnabled = true
                AP.Responsiveness = 200
                AP.Attachment0 = A0
                AP.Attachment1 = A1
                AO.MaxTorque = 9e9
                AO.Responsiveness = 200
                AO.RigidityEnabled = true
                AO.Attachment0 = A0
                AO.Attachment1 = A1

                return A0, A1, AP, A0
            end
            local function CreateBendTool()
                local tool = Instance.new('Tool')

                tool.Name = 'Bend'
                tool.RequiresHandle = false
                tool.CanBeDropped = false
                tool.Parent = LocalPlayer.Backpack

                tool.Activated:Connect(function()
                    _G.JOINTWATCHER = PlayersChar.DescendantAdded:Connect(function(Ins)
                        if Ins:IsA('Weld') and Ins.Name == 'GRABBING_CONSTRAINT' then
                            repeat
                                task.wait()
                            until Ins.Part0 ~= nil
                            repeat
                                task.wait()
                            until Ins:FindFirstChildOfClass('RopeConstraint')

                            local AT0, AT1, AP, A0

                            if Ins.Part0:IsDescendantOf(LocalPlayer.Character) then
                                Ins:FindFirstChildOfClass('RopeConstraint').Length = 9e9
                                LocalPlayer.Character.Animate.Disabled = true

                                for _, Anim in pairs(LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks())do
                                    Anim:Stop()
                                end

                                LocalPlayer.Character.Animate.Disabled = false

                                LocalPlayer.Character.Humanoid:LoadAnimation(IM.RightAim):Play()
                                LocalPlayer.Character.Humanoid:LoadAnimation(IM.LeftAim):Play()

                                AT0, AT1, AP, A0 = Align(Ins.Parent.UpperTorso, LocalPlayer.Character.UpperTorso, Vector3.new(0, 0, -2), Vector3.new(45, 0, 0))

                                spawn(function()
                                    while Ins.Parent ~= nil do
                                        task.wait()

                                        local Sine = tick() * 60

                                        AT1.Position = Vector3.new(0, -0.5, -4 + 1 * math.sin(Sine / 8))
                                    end
                                end)
                            end

                            repeat
                                task.wait()
                            until Ins.Parent == nil

                            LocalPlayer.Character.Animate.Disabled = true

                            for _, Anim in pairs(LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks())do
                                Anim:Stop()
                            end

                            LocalPlayer.Character.Animate.Disabled = false

                            AT0:Destroy()
                            AT1:Destroy()
                            AP:Destroy()
                            A0:Destroy()
                        end
                    end)
                end)
            end
            local function CreateBlowTool()
                local tool = Instance.new('Tool')

                tool.Name = 'Blow'
                tool.RequiresHandle = false
                tool.CanBeDropped = false
                tool.Parent = LocalPlayer.Backpack

                tool.Activated:Connect(function()
                    _G.JOINTWATCHER = PlayersChar.DescendantAdded:Connect(function(Ins)
                        if Ins:IsA('Weld') and Ins.Name == 'GRABBING_CONSTRAINT' then
                            repeat
                                task.wait()
                            until Ins.Part0 ~= nil
                            repeat
                                task.wait()
                            until Ins:FindFirstChildOfClass('RopeConstraint')

                            local AT0, AT1, AP, A0

                            if Ins.Part0:IsDescendantOf(LocalPlayer.Character) then
                                Ins:FindFirstChildOfClass('RopeConstraint').Length = 9e9
                                LocalPlayer.Character.Animate.Disabled = true

                                for _, Anim in pairs(LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks())do
                                    Anim:Stop()
                                end

                                LocalPlayer.Character.Animate.Disabled = false

                                LocalPlayer.Character.Humanoid:LoadAnimation(IM.RightAim):Play()
                                LocalPlayer.Character.Humanoid:LoadAnimation(IM.LeftAim):Play()

                                AT0, AT1, AP, A0 = Align(Ins.Parent.UpperTorso, LocalPlayer.Character.UpperTorso, Vector3.new(0, 0, 10), Vector3.new(90, 545, 0))

                                spawn(function()
                                    while Ins.Parent ~= nil do
                                        task.wait()

                                        local Sine = tick() * 60

                                        AT1.Position = Vector3.new(0, -1.2, -5 + 1 * math.sin(Sine / 8))
                                    end
                                end)
                            end

                            repeat
                                task.wait()
                            until Ins.Parent == nil

                            LocalPlayer.Character.Animate.Disabled = true

                            for _, Anim in pairs(LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks())do
                                Anim:Stop()
                            end

                            LocalPlayer.Character.Animate.Disabled = false

                            AT0:Destroy()
                            AT1:Destroy()
                            AP:Destroy()
                            A0:Destroy()
                        end
                    end)
                end)
            end

            function play(ID, STOP, TOOL)
                local localPlayer = game.Players.LocalPlayer

                if localPlayer.Backpack:FindFirstChild('[Boombox]') then
                    local Tool = nil
                    local character = localPlayer.Character

                    if character:FindFirstChildWhichIsA('Tool') and TOOL == true then
                        Tool = character:FindFirstChildWhichIsA('Tool')
                        character:FindFirstChildWhichIsA('Tool').Parent = localPlayer.Backpack
                    end

                    local boombox = localPlayer.Backpack['[Boombox]']

                    if boombox then
                        boombox.Parent = character

                        game.ReplicatedStorage.MainEvent:FireServer('Boombox', ID)

                        character['[Boombox]'].Parent = localPlayer.Backpack
                        localPlayer.PlayerGui.MainScreenGui.BoomboxFrame.Visible = false

                        if Tool then
                            Tool.Parent = character
                        end
                        if STOP then
                            character.LowerTorso:WaitForChild('BOOMBOXSOUND')

                            local cor = coroutine.wrap(function()
                                repeat
                                    wait()
                                until character.LowerTorso.BOOMBOXSOUND.SoundId == 'rbxassetid://' .. ID and character.LowerTorso.BOOMBOXSOUND.TimeLength > 0.01

                                OriginalKeyUpValue = OriginalKeyUpValue + 1

                                STOPLMAO(ID, OriginalKeyUpValue)
                            end)

                            cor()
                        end
                    end
                end
            end

            local function StopAudio()
                local localPlayer = Players.LocalPlayer

                if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild('LowerTorso') then
                    local boomboxSound = localPlayer.Character.LowerTorso:FindFirstChild('BOOMBOXSOUND')

                    if boomboxSound then
                        ReplicatedStorage:WaitForChild('MainEvent'):FireServer('BoomboxStop')
                    end
                end
            end
            local function RemoveTool(toolName)
                local backpack = LocalPlayer:FindFirstChild('Backpack')
                local character = LocalPlayer.Character

                if backpack then
                    local toolInBackpack = backpack:FindFirstChild(toolName)

                    if toolInBackpack then
                        toolInBackpack:Destroy()
                    end
                end
                if character then
                    local toolInCharacter = character:FindFirstChild(toolName)

                    if toolInCharacter then
                        toolInCharacter:Destroy()
                    end
                end
            end

            LocalPlayer.CharacterAdded:Connect(function()
                task.wait(2)

                for toolName, isEnabled in pairs(ToolStates)do
                    if isEnabled then
                        if toolName == 'Neckgrab' then
                            CreateNeckgrabTool()
                        elseif toolName == 'Up' then
                            CreateUpTool()
                        elseif toolName == 'Air' then
                            CreateAirTool()
                        elseif toolName == 'Throw' then
                            CreateThrowTool()
                        elseif toolName == 'HeavenThrow' then
                            CreateHeavenThrowTool()
                        elseif toolName == 'Punch' then
                            CreatePunchTool()
                        elseif toolName == 'RipInHalf' then
                            CreateRipInHalfTool()
                        elseif toolName == 'Void' then
                            CreateVoidTool()
                        elseif toolName == 'Orbit' then
                            CreateOrbitTool()
                        elseif toolName == 'Bend' then
                            CreateBendTool()
                        elseif toolName == 'Blow' then
                            CreateBlowTool()
                        end
                    end
                end
            end)
            TrollingBox:AddToggle('NeckgrabToggle', {
                Text = 'Neckgrab',
                Default = false,
                Callback = function(state)
                    ToolStates.Neckgrab = state

                    if state then
                        CreateNeckgrabTool()
                    else
                        RemoveTool('Activate Neckgrab')
                    end
                end,
            })
            TrollingBox:AddToggle('UpToggle', {
                Text = 'Up',
                Default = false,
                Callback = function(state)
                    ToolStates.Up = state

                    if state then
                        CreateUpTool()
                    else
                        RemoveTool('Up')
                    end
                end,
            })
            TrollingBox:AddToggle('AirToggle', {
                Text = 'Air',
                Default = false,
                Callback = function(state)
                    ToolStates.Air = state

                    if state then
                        CreateAirTool()
                    else
                        RemoveTool('Air')
                    end
                end,
            })
            TrollingBox:AddToggle('ThrowToggle', {
                Text = 'Throw',
                Default = false,
                Callback = function(state)
                    ToolStates.Throw = state

                    if state then
                        CreateThrowTool()
                    else
                        RemoveTool('Throw')
                    end
                end,
            })
            TrollingBox:AddToggle('HeavenThrowToggle', {
                Text = 'Heaven Throw',
                Default = false,
                Callback = function(state)
                    ToolStates.HeavenThrow = state

                    if state then
                        CreateHeavenThrowTool()
                    else
                        RemoveTool('Heaven Throw')
                    end
                end,
            })
            TrollingBox:AddToggle('PunchToggle', {
                Text = 'Punch',
                Default = false,
                Callback = function(state)
                    ToolStates.Punch = state

                    if state then
                        CreatePunchTool()
                    else
                        RemoveTool('Punch')
                    end
                end,
            })
            TrollingBox:AddToggle('RipInHalfToggle', {
                Text = 'Rip In Half',
                Default = false,
                Callback = function(state)
                    ToolStates.RipInHalf = state

                    if state then
                        CreateRipInHalfTool()
                    else
                        RemoveTool('Rip In Half')
                    end
                end,
            })
            TrollingBox:AddToggle('VoidToggle', {
                Text = 'Void',
                Default = false,
                Callback = function(state)
                    ToolStates.Void = state

                    if state then
                        CreateVoidTool()
                    else
                        RemoveTool('Void')
                    end
                end,
            })
            TrollingBox:AddToggle('OrbitToggle', {
                Text = 'Orbit',
                Default = false,
                Callback = function(state)
                    ToolStates.Orbit = state

                    if state then
                        CreateOrbitTool()
                    else
                        RemoveTool('Orbit')
                    end
                end,
            })
            TrollingBox:AddToggle('BendToggle', {
                Text = 'Bend',
                Default = false,
                Callback = function(state)
                    ToolStates.Bend = state

                    if state then
                        CreateBendTool()
                    else
                        RemoveTool('Bend')
                    end
                end,
            })
            TrollingBox:AddToggle('BlowToggle', {
                Text = 'Blow',
                Default = false,
                Callback = function(state)
                    ToolStates.Blow = state

                    if state then
                        CreateBlowTool()
                    else
                        RemoveTool('Blow')
                    end
                end,
            })

            local vu512 = game:GetService('Players').LocalPlayer
            local vu513 = {}
            local vu527 = nil

            local function vu517(pu514, pu515, pu516)
                return game:GetService('RunService').Heartbeat:Connect(function()
                    pu514.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    pu514.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    pu514.CFrame = pu515.CFrame * (pu516 or CFrame.new())
                    pu514.Velocity = Vector3.new(0, 0, 0)

                    if not pu514:FindFirstChildWhichIsA('BodyVelocity') then
                        Instance.new('BodyVelocity', pu514)
                    end

                    pu514.BodyVelocity.velocity = Vector3.new(0, 0, 0)
                    pu514.BodyVelocity.maxForce = Vector3.new(9000000000, 9000000000, 9000000000)
                end)
            end
            local function vu520(p518, p519)
                if type(p518) == 'table' and p519 then
                    p518[#p518 + 1] = p519
                end
            end
            local function vu526(p521, pu522)
                if game:GetService('RunService')[p521] then
                    local vu523 = nil

                    vu523 = game:GetService('RunService')[p521]:Connect(function()
                        local v524, v525 = pcall(pu522)

                        if not v524 then
                            vu523:Disconnect()
                            warn(v525)
                        end
                    end)

                    return vu523
                end
            end

            function AnimStop(p528, p529)
                local v530, v531, v532 = pairs(vu527:WaitForChild('Humanoid'):GetPlayingAnimationTracks())

                while true do
                    local v533

                    v532, v533 = v530(v531, v532)

                    if v532 == nil then
                        break
                    end
                    if v533.Animation.AnimationId:match('rbxassetid://' .. p528) then
                        if tonumber(p529) then
                            v533:Stop(p529)
                        else
                            v533:Stop()
                        end
                    end
                end
            end

            local function vu541(p534, p535)
                local v536, v537, v538 = pairs(vu527:WaitForChild('Humanoid'):GetPlayingAnimationTracks())

                while true do
                    local v539

                    v538, v539 = v536(v537, v538)

                    if v538 == nil then
                        break
                    end
                    if v539.Animation.AnimationId:match('rbxassetid://' .. p534) then
                        v539:Stop()
                    end
                end

                local v540 = Instance.new('Animation', game:GetService('Workspace'))

                v540.AnimationId = 'rbxassetid://' .. p534
                playing = vu527.Humanoid:LoadAnimation(v540)

                playing:Play()

                if tonumber(p535) then
                    playing:AdjustSpeed(p535)
                else
                    playing:AdjustSpeed(1)
                end

                v540:Destroy()
            end
            local function vu553(p542)
                local v543, v544, v545 = pairs(vu512.Character.Humanoid:GetPlayingAnimationTracks())

                while true do
                    local v546

                    v545, v546 = v543(v544, v545)

                    if v545 == nil then
                        break
                    end
                    if v546.Animation.AnimationId:match('rbxassetid://' .. p542) then
                        v546:Stop(0)

                        if not vu527:FindFirstChild(p542) then
                            local v547 = Instance.new('Animation', vu527)

                            v547.AnimationId = 'rbxassetid://' .. p542
                            v547.Name = '_____GYAT'
                            playing = vu527.Humanoid:LoadAnimation(v547)

                            playing:Play()
                        end
                    end
                end

                if vu527.Humanoid.MoveDirection.magnitude > 0 then
                    AnimStop(p542)

                    local v548 = vu527
                    local v549, v550, v551 = pairs(v548:GetChildren())

                    while true do
                        local v552

                        v551, v552 = v549(v550, v551)

                        if v551 == nil then
                            break
                        end
                        if v552.Name == '_____GYAT' then
                            v552:Destroy()
                        end
                    end
                end
            end
            local function vu561(p554, p555)
                local v556, v557, v558 = pairs(vu527:WaitForChild('Humanoid'):GetPlayingAnimationTracks())

                while true do
                    local v559

                    v558, v559 = v556(v557, v558)

                    if v558 == nil then
                        break
                    end
                    if v559.Animation.AnimationId:match('rbxassetid://' .. p554) then
                        v559:Stop()

                        return
                    end
                end

                local v560 = Instance.new('Animation', game:GetService('Workspace'))

                v560.AnimationId = 'rbxassetid://' .. p554
                playing = vu527.Humanoid:LoadAnimation(v560)

                playing:Play()

                if tonumber(p555) then
                    playing:AdjustSpeed(p555)
                else
                    playing:AdjustSpeed(1)
                end

                v560:Destroy()
            end
            local function vu568(p562)
                p562.Archivable = true

                local v563 = p562:Clone()

                v563.Humanoid.RootPart.Anchored = false
                v563.Humanoid.Health = 9000000000
                v563.Humanoid.MaxHealth = 9000000000

                v563.RagdollConstraints:Destroy()
                v563.BodyEffects:Destroy()
                v563:WaitForChild('GRABBING_CONSTRAINT'):Destroy()

                local v564, v565, v566 = pairs(v563:GetDescendants())

                while true do
                    local v567

                    v566, v567 = v564(v565, v566)

                    if v566 == nil then
                        break
                    end
                    if v567:IsA('BasePart') and (v567.Name ~= 'Head' and (v567.Name ~= 'HumanoidRootPart' and (v567.Name ~= 'UpperTorso' and (v567.Name ~= 'LowerTorso' and (v567.Name ~= 'LeftUpperArm' and (v567.Name ~= 'RightUpperArm' and (v567.Name ~= 'LeftLowerArm' and (v567.Name ~= 'RightLowerArm' and (v567.Name ~= 'LeftHand' and (v567.Name ~= 'RightHand' and (v567.Name ~= 'LeftUpperLeg' and (v567.Name ~= 'RightUpperLeg' and (v567.Name ~= 'LeftLowerLeg' and (v567.Name ~= 'RightLowerLeg' and (v567.Name ~= 'LeftFoot' and v567.Name ~= 'RightFoot'))))))))))))))) then
                        v567.Massless = false

                        v567:Destroy()
                    end
                    if v567:IsA('BasePart') then
                        v567.CustomPhysicalProperties = PhysicalProperties.new(100, 2, 0.5, 100, 1)
                        v567.Transparency = 1
                    end
                    if v567:IsA('Decal') then
                        v567.Transparency = 1
                    end
                    if v567:IsA('Motor6D') then
                        v567:Destroy()
                    end
                end

                v563.Parent = vu512.Character

                v563.Humanoid:ChangeState('GettingUp')

                p562.Archivable = false

                return v563
            end

            TrollingBox:AddButton('Rape (cant revert)', function()
                local vu603 = game.Players.LocalPlayer
                local vu604 = vu603.Character
                local vu605 = game:GetService('ReplicatedStorage').IM.ANIM
                local v606 = workspace.Players

                if _G.JOINTWATCHER then
                    _G.JOINTWATCHER:Disconnect()

                    _G.JOINTWATCHER = nil
                end

                local function vu615(p607, p608, p609, p610)
                    local v611 = Instance.new('Attachment', p607)
                    local v612 = Instance.new('Attachment', p608)
                    local v613 = Instance.new('AlignPosition', p607)
                    local v614 = Instance.new('AlignOrientation', p607)

                    v612.Position = p609
                    v611.Rotation = p610
                    v613.RigidityEnabled = true
                    v613.Responsiveness = 200
                    v613.Attachment0 = v611
                    v613.Attachment1 = v612
                    v614.MaxTorque = 9000000000
                    v614.Responsiveness = 200
                    v614.RigidityEnabled = true
                    v614.Attachment0 = v611
                    v614.Attachment1 = v612

                    return v611, v612, v613, v611
                end
                local function v632(pu616)
                    if pu616:IsA('Weld') and pu616.Name == 'GRABBING_CONSTRAINT' then
                        repeat
                            task.wait()
                        until pu616.Part0
                        repeat
                            task.wait()
                        until pu616:FindFirstChildOfClass('RopeConstraint')

                        local v617, v618, v619, v620

                        if pu616.Part0:IsDescendantOf(vu603.Character) then
                            pu616:FindFirstChildOfClass('RopeConstraint').Length = 9000000000
                            vu604.Animate.Disabled = true

                            local v621, v622, v623 = pairs(vu604.Humanoid:GetPlayingAnimationTracks())

                            while true do
                                local v624

                                v623, v624 = v621(v622, v623)

                                if v623 == nil then
                                    break
                                end

                                v624:Stop()
                            end

                            vu604.Animate.Disabled = false

                            vu604.Humanoid:LoadAnimation(vu605.RightAim):Play()
                            vu604.Humanoid:LoadAnimation(vu605.LeftAim):Play()

                            local v625

                            v617, v625, v618, v619 = vu615(pu616.Parent.UpperTorso, vu603.Character.UpperTorso, Vector3.new(0, 0, 10), Vector3.new(90, 545, 0))

                            local vu626 = v625

                            task.spawn(function()
                                while pu616.Parent do
                                    task.wait()

                                    local v627 = tick() * 60

                                    vu626.Position = Vector3.new(0, -1.2, -4 + 1 * math.sin(v627 / 8))
                                end
                            end)

                            v620 = vu626
                        else
                            v617 = nil
                            v620 = nil
                            v618 = nil
                            v619 = nil
                        end

                        repeat
                            task.wait()
                        until not pu616.Parent

                        vu604.Animate.Disabled = true

                        local v628, v629, v630 = pairs(vu604.Humanoid:GetPlayingAnimationTracks())

                        while true do
                            local v631

                            v630, v631 = v628(v629, v630)

                            if v630 == nil then
                                break
                            end

                            v631:Stop()
                        end

                        vu604.Animate.Disabled = false

                        if v617 then
                            v617:Destroy()
                        end
                        if v620 then
                            v620:Destroy()
                        end
                        if v618 then
                            v618:Destroy()
                        end
                        if v619 then
                            v619:Destroy()
                        end
                    end
                end

                _G.JOINTWATCHER = v606.DescendantAdded:Connect(v632)
            end)
            TrollingBox:AddButton('Kiss', function()
                local vu685 = game.Players.LocalPlayer
                local vu686 = vu685.Character
                local vu687 = game:GetService('ReplicatedStorage').IM.ANIM
                local v688 = workspace.Players

                if _G.JOINTWATCHER then
                    _G.JOINTWATCHER:Disconnect()
                end

                local function vu697(p689, p690, p691, p692)
                    local v693 = Instance.new('Attachment', p689)
                    local v694 = Instance.new('Attachment', p690)
                    local v695 = Instance.new('AlignPosition', p689)
                    local v696 = Instance.new('AlignOrientation', p689)

                    v694.Position = p691
                    v693.Rotation = p692
                    v695.RigidityEnabled = true
                    v695.Responsiveness = 200
                    v695.Attachment0 = v693
                    v695.Attachment1 = v694
                    v696.MaxTorque = 9000000000
                    v696.Responsiveness = 200
                    v696.RigidityEnabled = true
                    v696.Attachment0 = v693
                    v696.Attachment1 = v694

                    return v693, v694, v695, v696
                end

                _G.JOINTWATCHER = v688.DescendantAdded:Connect(function(pu698)
                    if pu698:IsA('Weld') and pu698.Name == 'GRABBING_CONSTRAINT' then
                        repeat
                            task.wait()
                        until pu698.Part0 ~= nil
                        repeat
                            task.wait()
                        until pu698:FindFirstChildOfClass('RopeConstraint')

                        local v699, v700, v701, v702

                        if pu698.Part0:IsDescendantOf(vu685.Character) then
                            pu698:FindFirstChildOfClass('RopeConstraint').Length = 9000000000
                            vu686.Animate.Disabled = true

                            local v703, v704, v705 = pairs(vu686.Humanoid:GetPlayingAnimationTracks())

                            while true do
                                local v706

                                v705, v706 = v703(v704, v705)

                                if v705 == nil then
                                    break
                                end

                                v706:Stop()
                            end

                            vu686.Animate.Disabled = false

                            vu686.Humanoid:LoadAnimation(vu687.RightAim):Play()
                            vu686.Humanoid:LoadAnimation(vu687.LeftAim):Play()

                            local v707

                            v699, v707, v700, v701 = vu697(pu698.Parent.UpperTorso, vu685.Character.UpperTorso, Vector3.new(0, 0, 2), Vector3.new(20, 180, 0))

                            local vu708 = v707

                            spawn(function()
                                while pu698.Parent ~= nil do
                                    task.wait()

                                    local v709 = tick() * 60

                                    vu708.Position = Vector3.new(0, 0.5, -1.7 + 0.4 * math.sin(v709 / 9))
                                end
                            end)

                            v702 = vu708
                        else
                            v699 = nil
                            v702 = nil
                            v700 = nil
                            v701 = nil
                        end

                        repeat
                            task.wait()
                        until pu698.Parent == nil

                        vu686.Animate.Disabled = true

                        local v710, v711, v712 = pairs(vu686.Humanoid:GetPlayingAnimationTracks())

                        while true do
                            local v713

                            v712, v713 = v710(v711, v712)

                            if v712 == nil then
                                break
                            end

                            v713:Stop()
                        end

                        vu686.Animate.Disabled = false

                        if v699 then
                            v699:Destroy()
                        end
                        if v702 then
                            v702:Destroy()
                        end
                        if v700 then
                            v700:Destroy()
                        end
                        if v701 then
                            v701:Destroy()
                        end
                    end
                end)
            end)
        end


	getgenv().jerkOffEnabled = false

	TrollingBox:AddToggle('JerkOff', {
		Text = 'Jerk Off',
		Default = false,
		Callback = function(v)
			getgenv().jerkOffEnabled = v

			if v then
				local speaker = game.Players.LocalPlayer
				local humanoid = speaker.Character and speaker.Character:FindFirstChildOfClass('Humanoid')
				local backpack = speaker:FindFirstChild('Backpack')

				if not humanoid or not backpack then
					Library:Notify('Character or backpack not found!', 5)

					return
				end

				local function createJerkOffTool()
					local tool = Instance.new('Tool')

					tool.Name = 'Jerk Off'
					tool.ToolTip = 'in the stripped club. straight up "jorking it" . and by "it" , haha, well. let\'s justr say. My peanits.'
					tool.RequiresHandle = false
					tool.Parent = backpack

					local jorkin = false
					local track = nil

					local function stopTomfoolery()
						jorkin = false

						if track then
							track:Stop()

							track = nil
						end
					end

					tool.Equipped:Connect(function()
						jorkin = true
					end)
					tool.Unequipped:Connect(stopTomfoolery)
					humanoid.Died:Connect(stopTomfoolery)
					task.spawn(function()
						while task.wait() do
							if not jorkin then
								continue
							end

							local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15

							if not track then
								local anim = Instance.new('Animation')

								anim.AnimationId = isR15 and 'rbxassetid://698251653' or 'rbxassetid://72042024'
								track = humanoid:LoadAnimation(anim)
							end

							track:Play()
							track:AdjustSpeed(isR15 and 0.7 or 0.65)

							track.TimePosition = 0.6

							task.wait(0.1)

							while track and track.TimePosition < (isR15 and 0.7 or 0.65) do
								task.wait(0.1)
							end

							if track then
								track:Stop()

								track = nil
							end
						end
					end)
				end

				createJerkOffTool()
			else
				local speaker = game.Players.LocalPlayer
				local backpack = speaker:FindFirstChild('Backpack')
				local character = speaker.Character

				if backpack then
					local toolInBackpack = backpack:FindFirstChild('Jerk Off')

					if toolInBackpack then
						toolInBackpack:Destroy()
					end
				end
				if character then
					local toolInCharacter = character:FindFirstChild('Jerk Off')

					if toolInCharacter then
						toolInCharacter:Destroy()
					end
				end
			end
		end,
	})

		getgenv().Test = false
		getgenv().SoundId = '6899466638'
		getgenv().ToolEnabled = false
		getgenv().CreateTool = function()
			getgenv().Tool = Instance.new('Tool')
			getgenv().Tool.RequiresHandle = false
			getgenv().Tool.Name = '[Kick]'
			getgenv().Tool.TextureId = 'rbxassetid://483225199'
			getgenv().Animation = Instance.new('Animation')
			getgenv().Animation.AnimationId = 'rbxassetid://2788306916'

			getgenv().Tool.Activated:Connect(function()
				getgenv().Test = true
				getgenv().Player = game.Players.LocalPlayer
				getgenv().Character = getgenv().Player.Character or getgenv().Player.CharacterAdded:Wait()
				getgenv().Humanoid = getgenv().Character:FindFirstChild('Humanoid')

				if getgenv().Humanoid then
					getgenv().AnimationTrack = getgenv().Humanoid:LoadAnimation(getgenv().Animation)

					getgenv().AnimationTrack:AdjustSpeed(3.4)
					getgenv().AnimationTrack:Play()
				end

				task.wait(0.6)

				getgenv().Boombox = game.Players.LocalPlayer.Backpack:FindFirstChild('[Boombox]')

				if getgenv().Boombox then
					getgenv().Boombox.Parent = game.Players.LocalPlayer.Character

					MainEvent:FireServer('Boombox', tonumber(getgenv().SoundId))

					getgenv().Boombox.RequiresHandle = false
					getgenv().Boombox.Parent = game.Players.LocalPlayer.Backpack

					task.wait(1)
					MainEvent:FireServer('BoomboxStop')
				else
					getgenv().Sound = Instance.new('Sound', workspace)
					getgenv().Sound.SoundId = 'rbxassetid://' .. getgenv().SoundId

					getgenv().Sound:Play()
					task.wait(1)
					getgenv().Sound:Stop()
				end

				wait(1.4)

				getgenv().Test = false
			end)

			getgenv().Tool.Parent = game.Players.LocalPlayer:WaitForChild('Backpack')
		end
		getgenv().RemoveTool = function()
			getgenv().Player = game.Players.LocalPlayer
			getgenv().Tool = getgenv().Player.Backpack:FindFirstChild('[Kick]') or getgenv().Player.Character:FindFirstChild('[Kick]')

			if getgenv().Tool then
				getgenv().Tool:Destroy()
			end
		end

		game:GetService('RunService').Heartbeat:Connect(function()
			if getgenv().Test then
				getgenv().Character = game.Players.LocalPlayer.Character

				if not getgenv().Character then
					return
				end

				getgenv().HumanoidRootPart = getgenv().Character:FindFirstChild('HumanoidRootPart')

				if not getgenv().HumanoidRootPart then
					return
				end

				getgenv().originalVelocity = getgenv().HumanoidRootPart.Velocity
				getgenv().HumanoidRootPart.Velocity = Vector3.new(getgenv().HumanoidRootPart.CFrame.LookVector.X * 800, 800, getgenv().HumanoidRootPart.CFrame.LookVector.Z * 800)

				game:GetService('RunService').RenderStepped:Wait()

				getgenv().HumanoidRootPart.Velocity = getgenv().originalVelocity
			end
		end)
		TrollingBox:AddToggle('Pqnd4Kick', {
			Text = 'Pqnd4 Kick Tool',
			Default = false,
			Callback = function(v)
				getgenv().ToolEnabled = v

				if v then
					getgenv().CreateTool()
				else
					getgenv().RemoveTool()
				end
			end,
		})

end)()
task.wait(1)
coroutine.wrap(function()
    local MiscBox = Tabs.Misc:AddRightGroupbox('Misc')

    MiscBox:AddToggle('AntiVoid', {
        Text = 'Anti Void',
        Default = true,
        Callback = function(v)
            if v then
                workspace.FallenPartsDestroyHeight = -math.huge
            else
                Workspace.FallenPartsDestroyHeight = -50
            end
        end,
    })
workspace.FallenPartsDestroyHeight = -math.huge
        local antiStompActive = true
        local antiStompActivev2 = true

    local flashbackActive = false
    local lastPosition = nil
    local antiStompConnection = nil

    local function startAntiStomp()
        local function setupCharacter(chr)
            local hum = chr:WaitForChild('Humanoid', 5)
            local bodyEffects = chr:WaitForChild('BodyEffects', 5)

            if not hum or not bodyEffects then
                warn('Humanoid or BodyEffects missing')

                return
            end

            local koValue = bodyEffects:WaitForChild('K.O', 5)

            if not koValue then
                warn('K.O value missing')

                return
            end
            if antiStompConnection then
                antiStompConnection:Disconnect()

                antiStompConnection = nil
            end

            antiStompConnection = RunService.Heartbeat:Connect(function()
                if not antiStompActivev2 then
                    antiStompConnection:Disconnect()

                    antiStompConnection = nil

                    return
                end
                if koValue.Value == true and hum.Health > 0 then
                    if flashbackActive then
                        local root = chr:FindFirstChild('HumanoidRootPart')

                        if root then
                            lastPosition = root.CFrame
                        end
                    end

                    hum.Health = 0
                end
            end)
        end

        if LocalPlayer.Character then
            setupCharacter(LocalPlayer.Character)
        end

        LocalPlayer.CharacterAdded:Connect(function(newCharacter)
            if not antiStompActivev2 then
                return
            end

            setupCharacter(newCharacter)

            if flashbackActive and lastPosition then
                local root = newCharacter:WaitForChild('HumanoidRootPart', 5)

                if root then
                    root.CFrame = lastPosition
                end

                lastPosition = nil
            end
        end)
    end
	startAntiStomp()
    MiscBox:AddToggle('AntiStomp', {
        Text = 'Anti Stomp v1+v2',
        Default = true,
        Callback = function(state)
            antiStompActivev2 = state
            antiStompActive = state

            if state then
                startAntiStomp()
            end
        end,
    })
    MiscBox:AddToggle('Flashback', {
        Text = 'Flashback',
        Default = false,
        Callback = function(state)
            flashbackActive = state
        end,
    })

    local lastDeathPosition = nil

    NewConnection(RunService.Heartbeat, function()
        local chr = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = chr:FindFirstChildOfClass('Humanoid')

        if not hum then
            return
        end

        local bodyEffects = chr:FindFirstChild('BodyEffects')

        if not bodyEffects then
            return
        end

        local koValue = bodyEffects:FindFirstChild('K.O')

        if antiStompActive then
            if hum.Health <= 5 or (koValue and koValue.Value) then
                local tool = chr:FindFirstChildOfClass('Tool')

                if tool then
                    tool.Parent = LocalPlayer.Backpack
                end

                for _, v in pairs(chr:GetChildren())do
                    if v:IsA('MeshPart') or v:IsA('Part') then
                        v:Destroy()
                    end
                end
                for _, v in pairs(chr:GetChildren())do
                    if v:IsA('Accessory') then
                        if v:FindFirstChild('Handle') then
                            v.Handle:Destroy()
                        end
                    end
                end
            end
        end
    end)

    if isDahood then
        local antiBagConnection

        MiscBox:AddToggle('AntiBag', {
            Text = 'Anti Bag',
            Default = false,
            Callback = function(Value)
                if Value then
                    antiBagConnection = NewConnection(RunService.Heartbeat, function()
                        if localPlayer.Character:FindFirstChild('Christmas_Sock') then
                            localPlayer.Character:FindFirstChild('Christmas_Sock'):Destroy()
                        end
                    end)
                else
                    if antiBagConnection then
                        antiBagConnection:Disconnect()

                        antiBagConnection = nil
                    end
                end
            end,
        })

        local antiGrabConnection

        MiscBox:AddToggle('AntiGrab', {
            Text = 'Anti Grab',
            Default = false,
            Callback = function(Value)
                if Value then
                    antiGrabConnection = NewConnection(RunService.Heartbeat, function()
                        local GC = localPlayer.Character:FindFirstChild('GRABBING_CONSTRAINT')

                        if GC then
                            GC:Destroy()
                            wait(0.04)

                            local humanoid = localPlayer.Character:FindFirstChildWhichIsA('Humanoid')

                            if humanoid then
                                humanoid.Sit = true
                            end
                        end
                    end)
                else
                    if antiGrabConnection then
                        antiGrabConnection:Disconnect()

                        antiGrabConnection = nil
                    end
                end
            end,
        })

        getgenv().XZQW_ENABLED = false
        getgenv().HIDE_ANIMATIONS = false
        getgenv().YRWL_Connection___ = {}
        getgenv().BlockedAnimations = {
            'rbxassetid://2788289281',
            'rbxassetid://507766388',
            'rbxassetid://2788292075',
            'rbxassetid://278829075',
            'rbxassetid://4798175381',
            'rbxassetid://2953512033',
            'rbxassetid://2788309982',
            'rbxassetid://2788312709',
            'rbxassetid://2788313790',
            'rbxassetid://2788316350',
            'rbxassetid://2788315673',
            'rbxassetid://2788314837',
        }
        ReplicatedStorage:WaitForChild('ClientAnimations').Block.AnimationId = 'rbxassetid://0'

        local function startAutoBlock()
            table.insert(getgenv().YRWL_Connection___, NewConnection(RunService.Stepped, function()
                if getgenv().XZQW_ENABLED then
                    local character = LocalPlayer.Character

                    if character and character:FindFirstChild('BodyEffects') then
                        local bodyEffects = character.BodyEffects

                        if bodyEffects:FindFirstChild('Block') then
                            bodyEffects.Block:Destroy()
                        end

                        local tool = character:FindFirstChildWhichIsA('Tool')

                        if tool and tool:FindFirstChild('Ammo') then
                            ReplicatedStorage.MainEvent:FireServer('Block', false)
                        else
                            ReplicatedStorage.MainEvent:FireServer('Block', true)
                            wait()
                            ReplicatedStorage.MainEvent:FireServer('Block', false)
                        end
                    end
                end
            end))
        end
        local function stopAutoBlock()
            for _, connection in ipairs(getgenv().YRWL_Connection___)do
                connection:Disconnect()
            end

            table.clear(getgenv().YRWL_Connection___)
        end
        local function startHidingAnimations()
            RunService:BindToRenderStep('Hide - Block', 0, function()
                if getgenv().HIDE_ANIMATIONS then
                    local character = LocalPlayer.Character

                    if character then
                        local humanoid = character:FindFirstChildWhichIsA('Humanoid')

                        if humanoid then
                            for _, animationTrack in pairs(humanoid:GetPlayingAnimationTracks())do
                                if table.find(getgenv().BlockedAnimations, animationTrack.Animation.AnimationId) then
                                    animationTrack:Stop()
                                end
                            end
                        end
                    end
                end
            end)
        end
        local function stopHidingAnimations()
            RunService:UnbindFromRenderStep('Hide - Block')
        end

        MiscBox:AddToggle('AutoBlock', {
            Text = 'God Block',
            Default = false,
            Callback = function(state)
                getgenv().XZQW_ENABLED = state

                if state then
                    startAutoBlock()
                else
                    stopAutoBlock()
                end
            end,
        })

        local Depbox = MiscBox:AddDependencyBox()

        Depbox:AddToggle('HideAnimations', {
            Text = 'Hide Animations',
            Default = false,
            Callback = function(state)
                getgenv().HIDE_ANIMATIONS = state

                if state then
                    startHidingAnimations()
                else
                    stopHidingAnimations()
                end
            end,
        })
        Depbox:SetupDependencies({
            {
                Toggles.AutoBlock,
                true,
            },
        })

        getgenv().CASH_AURA_ENABLED = false
        getgenv().CASH_AURA_RANGE = 17
        getgenv().COOLDOWN = 0.2

        local function GetCash()
            local cash = {}
            local drop = workspace:FindFirstChild('Ignored') and workspace.Ignored:FindFirstChild('Drop')

            if not drop then
                return cash
            end

            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')

            if not root then
                return cash
            end

            for _, v in drop:GetChildren()do
                if v.Name == 'MoneyDrop' then
                    local pos = v:GetAttribute('OriginalPos') or v.Position

                    if (pos - root.Position).Magnitude <= getgenv().CASH_AURA_RANGE then
                        table.insert(cash, v)
                    end
                end
            end

            return cash
        end
        local function CashAuraLoop()
            while getgenv().CASH_AURA_ENABLED do
                for _, money in GetCash()do
                    local cd = money:FindFirstChildOfClass('ClickDetector')

                    if cd then
                        fireclickdetector(cd)
                    end
                end

                task.wait(getgenv().COOLDOWN)
            end
        end

        MiscBox:AddToggle('CashAura', {
            Text = 'Cash Aura',
            Default = false,
            Callback = function(v)
                getgenv().CASH_AURA_ENABLED = v

                if v then
                    task.spawn(CashAuraLoop)
                end
            end,
        })
        MiscBox:AddSlider('CashAuraRange', {
            Text = 'Cash Aura Range',
            Min = 10,
            Max = 50,
            Default = 17,
            Rounding = 1,
            Callback = function(v)
                getgenv().CASH_AURA_RANGE = v
            end,
        })
        MiscBox:AddSlider('CashAuraCD', {
            Text = 'Cash Aura Cooldown',
            Min = 0.1,
            Max = 1,
            Default = 0.2,
            Rounding = 2,
            Callback = function(v)
                getgenv().COOLDOWN = v
            end,
        })
    end

    local autoReloadEnabled = true
    local removeShootAnimEnabled = false

    NewConnection(RunService.Heartbeat, function()
        if not autoReloadEnabled then
            return
        end

        local tool = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass('Tool')

        if tool and tool:FindFirstChild('Ammo') and tool.Ammo.Value <= 0 then
            pcall(function()
                MainEvent:FireServer('Reload', tool)
            end)
        end
    end)
    MiscBox:AddToggle('AutoReloadToggle', {
        Text = 'Auto Reload',
        Default = true,
        Callback = function(v)
            autoReloadEnabled = v

            Library:Notify(v and 'Auto Reload: ON' or 'Auto Reload: OFF', 2)
        end,
    })
    MiscBox:AddToggle('ChatSpy', {
        Text = 'Chat Spy',
        Default = true,
        Callback = function(v)
            ChatEnabled = v

            if chatWindow then
                chatWindow.Enabled = v
            end
        end,
    })

    local maxzoom = game.Players.LocalPlayer.CameraMaxZoomDistance

    MiscBox:AddToggle('InfZoom', {
        Text = 'Infinite Zoom',
        Default = false,
        Callback = function(v)
            if v then
                game.Players.LocalPlayer.CameraMaxZoomDistance = math.huge
            else
                game.Players.LocalPlayer.CameraMaxZoomDistance = maxzoom
            end
        end,
    })

    local ngu = MiscBox:AddButton({
        Text = 'Force Reset',
        Func = function()
            local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild('Humanoid')

            if hum then
                hum.Health = 0
            end
        end,
    })

    if isDaHood then
        ngu:AddButton({
            Text = 'Unjail (141$)',
            Func = function()
                local plr = game.Players.LocalPlayer
                local currency = plr:FindFirstChild('DataFolder') and plr.DataFolder:FindFirstChild('Currency')

                if not currency or currency.Value < 125 then
                    Library:Notify('Not enough cash! (Need 125$)', 5)

                    return
                end

                local hrp = plr.Character and plr.Character:FindFirstChild('HumanoidRootPart')

                if not hrp then
                    return
                end

                hrp.CFrame = CFrame.new(-270.94, 20.327, -242.38)

                task.wait(0.5)

                local keyShop = workspace:FindFirstChild('Ignored') and workspace.Ignored:FindFirstChild('Shop') and workspace.Ignored.Shop:FindFirstChild('[Key] - $141')

                if keyShop and keyShop:FindFirstChild('ClickDetector') then
                    fireclickdetector(keyShop.ClickDetector)
                end

                repeat
                    task.wait()
                until plr.Backpack:FindFirstChild('[Key]') or plr.Character:FindFirstChild('[Key]')

                local key = plr.Backpack:FindFirstChild('[Key]') or plr.Character:FindFirstChild('[Key]')

                if key then
                    local hum = plr.Character:FindFirstChildOfClass('Humanoid')

                    if hum then
                        hum:EquipTool(key)
                    end

                    task.wait(0.3)

                    hrp.CFrame = CFrame.new(-485.668, 23.631, -285.169)

                    task.wait(0.5)
                    key:Activate()
                    Library:Notify('Unjailed successfully!', 5)
                end
            end,
        })
    else
        print('Kh\u{f4}ng ph\u{1ea3}i Da Hood \u{2192} B\u{1ecf} qua Unjail')
    end
end)()
task.wait(1)
coroutine.wrap(function()
    if isDaHood then
        local DetectionBox = Tabs.Misc:AddRightGroupbox('Detection')
        local antiModEnabled = true
        local checkModFriendsEnabled = true
        local groupCheckEnabled = true
        local antiModMethod = 'Kick'
        local modList = {
            163721789,
            15427717,
            201454243,
            822999,
            63794379,
            17260230,
            28357488,
            93101606,
            8195210,
            89473551,
            16917269,
            85989579,
            1553950697,
            476537893,
            155627580,
            31163456,
            7200829,
            25717070,
            16138978,
            60660789,
            1161411094,
            9125623,
            11319153,
            34758833,
            194109750,
            35616559,
            1257271138,
            28885841,
            23558830,
            4255947062,
            29242182,
            2395613299,
            3314981799,
            3390225662,
            2459178,
            2846299656,
            2967502742,
            7001683347,
            7312775547,
            328566086,
            170526279,
            99356639,
            352087139,
            6074834798,
            2212830051,
            3944434729,
            5136267958,
            84570351,
            542488819,
            1830168970,
            3950637598,
            1962396833,
        }
        local groupIDs = {10604500, 17215700}

        local function detectMods()
            while antiModEnabled do
                task.wait(1.5)

                for _, player in ipairs(Players:GetPlayers())do
                    if player == LocalPlayer then
                        continue
                    end
                    if table.find(modList, player.UserId) then
                        local msg = 'MODERATOR DETECTED: ' .. player.DisplayName .. ' (@' .. player.Name .. ')'

                        if antiModMethod == 'Notify' then
                            Library:Notify(msg, 5)
                        else
                            LocalPlayer:Kick('MOD DETECTED: ' .. player.DisplayName)
                        end
                    end
                    if groupCheckEnabled then
                        for _, groupId in ipairs(groupIDs)do
                            local success, inGroup = pcall(player.IsInGroup, player, groupId)

                            if success and inGroup then
                                local role = 'Unknown'

                                pcall(function()
                                    role = player:GetRoleInGroup(groupId)
                                end)

                                local msg = '[' .. role .. '] JOINED: ' .. player.DisplayName .. ' (@' .. player.Name .. ')'

                                if antiModMethod == 'Notify' then
                                    Library:Notify(msg, 5)
                                else
                                    LocalPlayer:Kick('STAFF DETECTED: ' .. player.DisplayName)
                                end
                            end
                        end
                    end
                end
            end
        end
        local function checkFriendsWithMods()
            while checkModFriendsEnabled do
                task.wait(8)

                for _, player in ipairs(Players:GetPlayers())do
                    if player == LocalPlayer then
                        continue
                    end

                    pcall(function()
                        local friends = player:GetFriendsAsync()
                        local page = friends:GetCurrentPage()

                        for _, friend in ipairs(page)do
                            if table.find(modList, friend.Id) then
                                Library:Notify(player.DisplayName .. ' is friends with a Moderator!', 6)

                                break
                            end
                        end
                    end)
                end
            end
        end

        local AntiModToggle = DetectionBox:AddToggle('AntiMod', {
            Text = 'Anti Mod Detection',
            Default = true,
            Callback = function(v)
                antiModEnabled = v

                Library:Notify(v and 'Anti-Mod: ON' or 'Anti-Mod: OFF', 3)

                if v then
                    task.spawn(detectMods)
                end
            end,
        })
        local DepBox = DetectionBox:AddDependencyBox()

        DepBox:SetupDependencies({
            {
                Toggles.AntiMod,
                true,
            },
        })
        DepBox:AddDropdown('AntiModMethod', {
            Values = {
                'Notify',
                'Kick',
            },
            Default = 'Kick',
            Multi = false,
            Text = 'Action Method',
            Callback = function(v)
                antiModMethod = v

                Library:Notify('Anti-Mod Action \u{2192} ' .. v, 3)
            end,
        })
        DepBox:AddToggle('CheckModFriends', {
            Text = 'Check Mod Friends',
            Default = true,
            Tooltip = 'Warns if someone is friends with a Moderator',
            Callback = function(v)
                checkModFriendsEnabled = v

                Library:Notify(v and 'Mod Friends Check: ON' or 'Mod Friends Check: OFF', 3)

                if v then
                    task.spawn(checkFriendsWithMods)
                end
            end,
        })
        DepBox:AddToggle('GroupCheck', {
            Text = 'Staff Group Check',
            Default = true,
            Tooltip = 'Detects players in restricted Da Hood staff groups',
            Callback = function(v)
                groupCheckEnabled = v

                Library:Notify(v and 'Staff Group Check: ON' or 'Staff Group Check: OFF', 3)

                if v and antiModEnabled then
                    task.spawn(detectMods)
                end
            end,
        })
    end
end)()
task.wait(1)
coroutine.wrap(function()
        local lighting = game:GetService('Lighting')
        local LightingService = game:GetService('Lighting')
        local originalAmbient = LightingService.Ambient
        local originalOutdoorAmbient = LightingService.OutdoorAmbient
        local originalFogColor = LightingService.FogColor
        local originalFogStart = LightingService.FogStart
        local originalFogEnd = LightingService.FogEnd
        local originalBrightness = LightingService.Brightness
        local originalClockTime = LightingService.ClockTime
        local nebulaThemeColor = Color3.fromRGB(173, 216, 230)

    local Visuals = {}
    local LightingGroup = Tabs.World:AddLeftGroupbox('Lighting')
        LightingGroup:AddToggle('CustomAmbient', {
            Text = 'Custom Ambient',
            Default = false,
            Callback = function(Value)
                LightingService.Ambient = Value and AmbientColor or originalAmbient
            end,
        }):AddColorPicker('AmbientColor', {
            Default = originalAmbient,
            Title = 'Ambient Color',
            Callback = function(Value)
                AmbientColor = Value

                if Toggles.CustomAmbient.Value then
                    LightingService.Ambient = Value
                end
            end,
        })
        LightingGroup:AddToggle('CustomOutdoorAmbient', {
            Text = 'Custom Outdoor Ambient',
            Default = false,
            Callback = function(Value)
                LightingService.OutdoorAmbient = Value and OutdoorAmbientColor or originalOutdoorAmbient
            end,
        }):AddColorPicker('OutdoorAmbientColor', {
            Default = originalOutdoorAmbient,
            Title = 'Outdoor Ambient Color',
            Callback = function(Value)
                OutdoorAmbientColor = Value

                if Toggles.CustomOutdoorAmbient.Value then
                    LightingService.OutdoorAmbient = Value
                end
            end,
        })
        LightingGroup:AddToggle('CustomFog', {
            Text = 'Custom Fog',
            Default = false,
            Callback = function(Value)
                if Value then
                    LightingService.FogColor = FogColor
                    LightingService.FogStart = FogStart
                    LightingService.FogEnd = FogEnd
                else
                    LightingService.FogColor = originalFogColor
                    LightingService.FogStart = originalFogStart
                    LightingService.FogEnd = originalFogEnd
                end
            end,
        }):AddColorPicker('FogColor', {
            Default = originalFogColor,
            Title = 'Fog Color',
            Callback = function(Value)
                FogColor = Value

                if Toggles.CustomFog.Value then
                    LightingService.FogColor = Value
                end
            end,
        })
        LightingGroup:AddSlider('FogStart', {
            Text = 'Fog Start',
            Min = 0,
            Max = 1000,
            Default = originalFogStart,
            Rounding = 1,
            Callback = function(Value)
                FogStart = Value

                if Toggles.CustomFog.Value then
                    LightingService.FogStart = Value
                end
            end,
        })
        LightingGroup:AddSlider('FogEnd', {
            Text = 'Fog End',
            Min = 0,
            Max = 1000,
            Default = originalFogEnd,
            Rounding = 1,
            Callback = function(Value)
                FogEnd = Value

                if Toggles.CustomFog.Value then
                    LightingService.FogEnd = Value
                end
            end,
        })
        LightingGroup:AddToggle('CustomBrightness', {
            Text = 'Custom Brightness',
            Default = false,
            Callback = function(Value)
                LightingService.Brightness = Value and BrightnessValue or originalBrightness
            end,
        })
        LightingGroup:AddSlider('BrightnessValue', {
            Text = 'Brightness',
            Min = 0,
            Max = 10,
            Default = originalBrightness,
            Rounding = 1,
            Callback = function(Value)
                BrightnessValue = Value

                if Toggles.CustomBrightness.Value then
                    LightingService.Brightness = Value
                end
            end,
        })
        LightingGroup:AddToggle('CustomClockTime', {
            Text = 'Custom Clock Time',
            Default = false,
            Callback = function(Value)
                if Value then
                    LightingService.ClockTime = ClockTimeValue

                    if ClockTimeTask then
                        task.cancel(ClockTimeTask)
                    end

                    ClockTimeTask = task.spawn(function()
                        while Toggles.CustomClockTime.Value do
                            LightingService.ClockTime = ClockTimeValue

                            task.wait(0.1)
                        end
                    end)
                else
                    if ClockTimeTask then
                        task.cancel(ClockTimeTask)

                        ClockTimeTask = nil
                    end

                    LightingService.ClockTime = originalClockTime
                end
            end,
        })
        LightingGroup:AddSlider('ClockTimeValue', {
            Text = 'Clock Time',
            Min = 0,
            Max = 24,
            Default = 0,
            Rounding = 1,
            Callback = function(Value)
                ClockTimeValue = Value

                if Toggles.CustomClockTime.Value then
                    LightingService.ClockTime = Value
                end
            end,
        })
        LightingGroup:AddToggle('NebulaTheme', {
            Text = 'Nebula Theme',
            Default = false,
            Callback = function(Value)
                if Value then
                    local b = Instance.new('BloomEffect', LightingService)

                    b.Intensity = 0.7
                    b.Size = 24
                    b.Threshold = 1
                    b.Name = 'NebulaBloom'

                    local c = Instance.new('ColorCorrectionEffect', LightingService)

                    c.Saturation = 0.5
                    c.Contrast = 0.2
                    c.TintColor = nebulaThemeColor
                    c.Name = 'NebulaColorCorrection'

                    local a = Instance.new('Atmosphere', LightingService)

                    a.Density = 0.4
                    a.Offset = 0.25
                    a.Glare = 1
                    a.Haze = 2
                    a.Color = nebulaThemeColor
                    a.Decay = Color3.fromRGB(173, 216, 230)
                    a.Name = 'NebulaAtmosphere'
                    LightingService.Ambient = nebulaThemeColor
                    LightingService.OutdoorAmbient = nebulaThemeColor
                    LightingService.FogStart = 100
                    LightingService.FogEnd = 500
                    LightingService.FogColor = nebulaThemeColor
                else
                    for _, name in pairs({
                        'NebulaBloom',
                        'NebulaColorCorrection',
                        'NebulaAtmosphere',
                    })do
                        local obj = LightingService:FindFirstChild(name)

                        if obj then
                            obj:Destroy()
                        end
                    end

                    LightingService.Ambient = originalAmbient
                    LightingService.OutdoorAmbient = originalOutdoorAmbient
                    LightingService.FogStart = originalFogStart
                    LightingService.FogEnd = originalFogEnd
                    LightingService.FogColor = originalFogColor
                end
            end,
        }):AddColorPicker('NebulaColor', {
            Default = Color3.fromRGB(173, 216, 230),
            Title = 'Nebula Color',
            Callback = function(Value)
                nebulaThemeColor = Value

                if Toggles.NebulaTheme.Value then
                    local nc = LightingService:FindFirstChild('NebulaColorCorrection')

                    if nc then
                        nc.TintColor = Value
                    end

                    local na = LightingService:FindFirstChild('NebulaAtmosphere')

                    if na then
                        na.Color = Value
                    end

                    LightingService.Ambient = Value
                    LightingService.OutdoorAmbient = Value
                    LightingService.FogColor = Value
                end
            end,
        })

        local SelectedSkybox = 'Minecraft'
        local LightingSettings = {
            DefaultSkyboxBk = lighting.Sky.SkyboxBk,
            DefaultSkyboxDn = lighting.Sky.SkyboxDn,
            DefaultSkyboxFt = lighting.Sky.SkyboxFt,
            DefaultSkyboxLf = lighting.Sky.SkyboxLf,
            DefaultSkyboxRt = lighting.Sky.SkyboxRt,
            DefaultSkyboxUp = lighting.Sky.SkyboxUp,
        }
        local DefaultSky = lighting:FindFirstChildOfClass('Sky')
        local LightingSettings = {}

        if DefaultSky then
            LightingSettings.DefaultSkyboxBk = DefaultSky.SkyboxBk
            LightingSettings.DefaultSkyboxDn = DefaultSky.SkyboxDn
            LightingSettings.DefaultSkyboxFt = DefaultSky.SkyboxFt
            LightingSettings.DefaultSkyboxLf = DefaultSky.SkyboxLf
            LightingSettings.DefaultSkyboxRt = DefaultSky.SkyboxRt
            LightingSettings.DefaultSkyboxUp = DefaultSky.SkyboxUp
        end

        local customSkyInstance = nil
        local SkyboxAssets = {
            Minecraft = {
                SkyboxBk = 'rbxassetid://1876545003',
                SkyboxDn = 'rbxassetid://1876544331',
                SkyboxFt = 'rbxassetid://1876542941',
                SkyboxLf = 'rbxassetid://1876543392',
                SkyboxRt = 'rbxassetid://1876543764',
                SkyboxUp = 'rbxassetid://1876544642',
            },
            PurpleDay = {
                SkyboxBk = 'rbxassetid://296908715',
                SkyboxDn = 'rbxassetid://296908724',
                SkyboxFt = 'rbxassetid://296908740',
                SkyboxLf = 'rbxassetid://296908755',
                SkyboxRt = 'rbxassetid://296908764',
                SkyboxUp = 'rbxassetid://296908769',
            },
            RedNight = {
                SkyboxBk = 'rbxassetid://401664839',
                SkyboxDn = 'rbxassetid://401664862',
                SkyboxFt = 'rbxassetid://401664960',
                SkyboxLf = 'rbxassetid://401664881',
                SkyboxRt = 'rbxassetid://401664901',
                SkyboxUp = 'rbxassetid://401664936',
            },
            Trollge = {
                SkyboxBk = 'rbxassetid://6155393905',
                SkyboxDn = 'rbxassetid://6155393905',
                SkyboxFt = 'rbxassetid://6155393905',
                SkyboxLf = 'rbxassetid://6155393905',
                SkyboxRt = 'rbxassetid://6155393905',
                SkyboxUp = 'rbxassetid://6155393905',
            },
            Night = {
                SkyboxBk = 'rbxassetid://48020371',
                SkyboxDn = 'rbxassetid://48020144',
                SkyboxFt = 'rbxassetid://48020234',
                SkyboxLf = 'rbxassetid://48020211',
                SkyboxRt = 'rbxassetid://48020254',
                SkyboxUp = 'rbxassetid://48020383',
            },
            Space = {
                SkyboxBk = 'rbxassetid://149397692',
                SkyboxDn = 'rbxassetid://149397686',
                SkyboxFt = 'rbxassetid://149397697',
                SkyboxLf = 'rbxassetid://149397684',
                SkyboxRt = 'rbxassetid://149397688',
                SkyboxUp = 'rbxassetid://149397702',
            },
            Default = {
                SkyboxBk = 'rbxassetid://6444884337',
                SkyboxDn = 'rbxassetid://6444884785',
                SkyboxFt = 'rbxassetid://6444884337',
                SkyboxLf = 'rbxassetid://6444884337',
                SkyboxRt = 'rbxassetid://6444884337',
                SkyboxUp = 'rbxassetid://6412503613',
            },
            VibeMorning = {
                SkyboxBk = 'rbxassetid://1417494030',
                SkyboxDn = 'rbxassetid://1417494146',
                SkyboxFt = 'rbxassetid://1417494253',
                SkyboxLf = 'rbxassetid://1417494402',
                SkyboxRt = 'rbxassetid://1417494499',
                SkyboxUp = 'rbxassetid://1417494643',
            },
            VibeNight = {
                SkyboxBk = 'rbxassetid://5084575798',
                SkyboxDn = 'rbxassetid://5084575916',
                SkyboxFt = 'rbxassetid://5103949679',
                SkyboxLf = 'rbxassetid://5103948542',
                SkyboxRt = 'rbxassetid://5103948784',
                SkyboxUp = 'rbxassetid://5084576400',
            },
            PurpleSplash = {
                SkyboxBk = 'rbxassetid://8539982183',
                SkyboxDn = 'rbxassetid://8539981943',
                SkyboxFt = 'rbxassetid://8539981721',
                SkyboxLf = 'rbxassetid://8539981424',
                SkyboxRt = 'rbxassetid://8539980766',
                SkyboxUp = 'rbxassetid://8539981085',
            },
            GreenSpace = {
                SkyboxBk = 'rbxassetid://159248188',
                SkyboxDn = 'rbxassetid://159248183',
                SkyboxFt = 'rbxassetid://159248187',
                SkyboxLf = 'rbxassetid://159248173',
                SkyboxRt = 'rbxassetid://159248192',
                SkyboxUp = 'rbxassetid://159248176',
            },
            Snowy = {
                SkyboxBk = 'rbxassetid://155657655',
                SkyboxDn = 'rbxassetid://155674246',
                SkyboxFt = 'rbxassetid://155657609',
                SkyboxLf = 'rbxassetid://155657671',
                SkyboxRt = 'rbxassetid://155657619',
                SkyboxUp = 'rbxassetid://155674931',
            },
            Spongebob = {
                SkyboxBk = 'rbxassetid://10287764626',
                SkyboxDn = 'rbxassetid://10287766382',
                SkyboxFt = 'rbxassetid://10287764626',
                SkyboxLf = 'rbxassetid://10287763421',
                SkyboxRt = 'rbxassetid://10287764626',
                SkyboxUp = 'rbxassetid://10287767597',
            },
            PinkDay = {
                SkyboxBk = 'rbxassetid://271042516',
                SkyboxDn = 'rbxassetid://271077243',
                SkyboxFt = 'rbxassetid://271042556',
                SkyboxLf = 'rbxassetid://271042310',
                SkyboxRt = 'rbxassetid://271042467',
                SkyboxUp = 'rbxassetid://271077958',
            },
            AlienRed = {
                SkyboxBk = 'rbxassetid://1012890',
                SkyboxDn = 'rbxassetid://1012891',
                SkyboxFt = 'rbxassetid://1012887',
                SkyboxLf = 'rbxassetid://1012889',
                SkyboxRt = 'rbxassetid://1012888',
                SkyboxUp = 'rbxassetid://1014449',
            },
            WallsOfAutumn = {
                SkyboxBk = 'rbxassetid://7123244709',
                SkyboxDn = 'rbxassetid://7123246497',
                SkyboxFt = 'rbxassetid://7123255895',
                SkyboxLf = 'rbxassetid://7123257992',
                SkyboxRt = 'rbxassetid://7123279103',
                SkyboxUp = 'rbxassetid://7123281828',
            },
            ColdWinterness = {
                SkyboxBk = 'rbxassetid://7123754562',
                SkyboxDn = 'rbxassetid://7123756028',
                SkyboxFt = 'rbxassetid://7123757422',
                SkyboxLf = 'rbxassetid://7123758897',
                SkyboxRt = 'rbxassetid://7123760563',
                SkyboxUp = 'rbxassetid://7123762364',
            },
            Oblivion = {
                SkyboxBk = 'rbxassetid://7123654189',
                SkyboxDn = 'rbxassetid://7123657455',
                SkyboxFt = 'rbxassetid://7123662047',
                SkyboxLf = 'rbxassetid://7123664533',
                SkyboxRt = 'rbxassetid://7123666598',
                SkyboxUp = 'rbxassetid://7123668994',
            },
            ClassicSky = {
                SkyboxBk = 'rbxassetid://672345740',
                SkyboxDn = 'rbxassetid://672345828',
                SkyboxFt = 'rbxassetid://672345879',
                SkyboxLf = 'rbxassetid://672345927',
                SkyboxRt = 'rbxassetid://672346006',
                SkyboxUp = 'rbxassetid://672346072',
            },
            PurpleNight = {
                SkyboxBk = 'rbxassetid://5084575798',
                SkyboxDn = 'rbxassetid://5084575916',
                SkyboxFt = 'rbxassetid://5103949679',
                SkyboxLf = 'rbxassetid://5103948542',
                SkyboxRt = 'rbxassetid://5103948784',
                SkyboxUp = 'rbxassetid://5084576400',
            },
            PurpleDayClear = {
                SkyboxBk = 'rbxassetid://6847607535',
                SkyboxDn = 'rbxassetid://6847607977',
                SkyboxFt = 'rbxassetid://6847608302',
                SkyboxLf = 'rbxassetid://6847608608',
                SkyboxRt = 'rbxassetid://6847608986',
                SkyboxUp = 'rbxassetid://6847609323',
            },
            YellowDay = {
                SkyboxBk = 'rbxassetid://2651432901',
                SkyboxDn = 'rbxassetid://2651434974',
                SkyboxFt = 'rbxassetid://2651435990',
                SkyboxLf = 'rbxassetid://2651436494',
                SkyboxRt = 'rbxassetid://2651436979',
                SkyboxUp = 'rbxassetid://2651437350',
            },
            MinecraftSky = {
                SkyboxBk = 'rbxassetid://8735166756',
                SkyboxDn = 'rbxassetid://8735166707',
                SkyboxFt = 'rbxassetid://8735231668',
                SkyboxLf = 'rbxassetid://8735166755',
                SkyboxRt = 'rbxassetid://8735166751',
                SkyboxUp = 'rbxassetid://8735166729',
            },
            Sunset = {
                SkyboxBk = 'rbxassetid://150939022',
                SkyboxDn = 'rbxassetid://150939038',
                SkyboxFt = 'rbxassetid://150939047',
                SkyboxLf = 'rbxassetid://150939056',
                SkyboxRt = 'rbxassetid://150939063',
                SkyboxUp = 'rbxassetid://150939082',
            },
            CartoonSky = {
                SkyboxBk = 'rbxassetid://6778646360',
                SkyboxDn = 'rbxassetid://6778658683',
                SkyboxFt = 'rbxassetid://6778648039',
                SkyboxLf = 'rbxassetid://6778649136',
                SkyboxRt = 'rbxassetid://6778650519',
                SkyboxUp = 'rbxassetid://6778658364',
            },
            Anime = {
                SkyboxBk = 'rbxassetid://7643700666',
                SkyboxDn = 'rbxassetid://7643743687',
                SkyboxFt = 'rbxassetid://7644304186',
                SkyboxLf = 'rbxassetid://7644288724',
                SkyboxRt = 'rbxassetid://7643700819',
                SkyboxUp = 'rbxassetid://7643757404',
            },
            HellSky = {
                SkyboxBk = 'rbxassetid://437430787',
                SkyboxDn = 'rbxassetid://437430804',
                SkyboxFt = 'rbxassetid://437430543',
                SkyboxLf = 'rbxassetid://437430732',
                SkyboxRt = 'rbxassetid://437430747',
                SkyboxUp = 'rbxassetid://437430771',
            },
            StarryNight = {
                SkyboxBk = 'rbxassetid://8291078911',
                SkyboxDn = 'rbxassetid://8291077403',
                SkyboxFt = 'rbxassetid://8291081613',
                SkyboxLf = 'rbxassetid://8291074004',
                SkyboxRt = 'rbxassetid://8291080353',
                SkyboxUp = 'rbxassetid://8291075054',
            },
            Omori = {
                SkyboxBk = 'rbxassetid://8767416629',
                SkyboxDn = 'rbxassetid://8767416629',
                SkyboxFt = 'rbxassetid://8767416629',
                SkyboxLf = 'rbxassetid://8767416629',
                SkyboxRt = 'rbxassetid://8767416629',
                SkyboxUp = 'rbxassetid://8767416629',
            },
            c00lkidd = {
                SkyboxBk = 'rbxassetid://433381097',
                SkyboxDn = 'rbxassetid://433381097',
                SkyboxFt = 'rbxassetid://433381097',
                SkyboxLf = 'rbxassetid://433381097',
                SkyboxRt = 'rbxassetid://433381097',
                SkyboxUp = 'rbxassetid://433381097',
            },
            ClearDay = {
                SkyboxBk = 'rbxassetid://591058823',
                SkyboxDn = 'rbxassetid://591059876',
                SkyboxFt = 'rbxassetid://591058104',
                SkyboxLf = 'rbxassetid://591057861',
                SkyboxRt = 'rbxassetid://591057625',
                SkyboxUp = 'rbxassetid://591059642',
            },
            Mountains = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=324014980',
                SkyboxDn = 'http://www.roblox.com/asset/?id=324015477',
                SkyboxFt = 'http://www.roblox.com/asset/?id=324014995',
                SkyboxLf = 'http://www.roblox.com/asset/?id=324014679',
                SkyboxRt = 'http://www.roblox.com/asset/?id=324015013',
                SkyboxUp = 'http://www.roblox.com/asset/?id=324015409',
            },
            Forest = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=70945545',
                SkyboxDn = 'http://www.roblox.com/asset/?id=70945449',
                SkyboxFt = 'http://www.roblox.com/asset/?id=70945487',
                SkyboxLf = 'http://www.roblox.com/asset/?id=70945523',
                SkyboxRt = 'http://www.roblox.com/asset/?id=70945508',
                SkyboxUp = 'http://www.roblox.com/asset/?id=70945531',
            },
            LargeForest = {
                SkyboxBk = 'rbxassetid://17428978603',
                SkyboxDn = 'rbxassetid://17428977445',
                SkyboxFt = 'rbxassetid://17428977114',
                SkyboxLf = 'rbxassetid://17428978399',
                SkyboxRt = 'rbxassetid://17428976828',
                SkyboxUp = 'rbxassetid://17428976669',
            },
            Crimson = {
                SkyboxBk = 'rbxassetid://15832429892',
                SkyboxDn = 'rbxassetid://15832430998',
                SkyboxFt = 'rbxassetid://15832430210',
                SkyboxLf = 'rbxassetid://15832430671',
                SkyboxRt = 'rbxassetid://15832431198',
                SkyboxUp = 'rbxassetid://15832429401',
            },
            PumpkinHill = {
                SkyboxBk = 'rbxassetid://11202510597',
                SkyboxDn = 'rbxassetid://11202510255',
                SkyboxFt = 'rbxassetid://11202509993',
                SkyboxLf = 'rbxassetid://11202510806',
                SkyboxRt = 'rbxassetid://11202511066',
                SkyboxUp = 'rbxassetid://11202509704',
            },
            AnimeIsland = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=14753804949',
                SkyboxDn = 'http://www.roblox.com/asset/?id=14753795573',
                SkyboxFt = 'http://www.roblox.com/asset/?id=14753807625',
                SkyboxLf = 'http://www.roblox.com/asset/?id=14753797417',
                SkyboxRt = 'http://www.roblox.com/asset/?id=14753799966',
                SkyboxUp = 'http://www.roblox.com/asset/?id=14753810287',
            },
            SnowyMountains = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=368385273',
                SkyboxDn = 'http://www.roblox.com/asset/?id=48015300',
                SkyboxFt = 'http://www.roblox.com/asset/?id=368388290',
                SkyboxLf = 'http://www.roblox.com/asset/?id=368390615',
                SkyboxRt = 'http://www.roblox.com/asset/?id=368385190',
                SkyboxUp = 'http://www.roblox.com/asset/?id=48015387',
            },
            Desert = {
                SkyboxBk = 'rbxassetid://161319957',
                SkyboxDn = 'rbxassetid://161319965',
                SkyboxFt = 'rbxassetid://161319970',
                SkyboxLf = 'rbxassetid://161319983',
                SkyboxRt = 'rbxassetid://161319989',
                SkyboxUp = 'rbxassetid://161319996',
            },
            Cloudy = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=225469345',
                SkyboxDn = 'http://www.roblox.com/asset/?id=225469349',
                SkyboxFt = 'http://www.roblox.com/asset/?id=225469359',
                SkyboxLf = 'http://www.roblox.com/asset/?id=225469364',
                SkyboxRt = 'http://www.roblox.com/asset/?id=225469372',
                SkyboxUp = 'http://www.roblox.com/asset/?id=225469380',
            },
            Island = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=319343577',
                SkyboxDn = 'http://www.roblox.com/asset/?id=319343653',
                SkyboxFt = 'http://www.roblox.com/asset/?id=319343666',
                SkyboxLf = 'http://www.roblox.com/asset/?id=319343686',
                SkyboxRt = 'http://www.roblox.com/asset/?id=319343631',
                SkyboxUp = 'http://www.roblox.com/asset/?id=319343614',
            },
            OrangeFog = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=458016711',
                SkyboxDn = 'http://www.roblox.com/asset/?id=458016826',
                SkyboxFt = 'http://www.roblox.com/asset/?id=458016532',
                SkyboxLf = 'http://www.roblox.com/asset/?id=458016655',
                SkyboxRt = 'http://www.roblox.com/asset/?id=458016782',
                SkyboxUp = 'http://www.roblox.com/asset/?id=458016792',
            },
            FadeNight = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=16888843486',
                SkyboxDn = 'http://www.roblox.com/asset/?id=16888845693',
                SkyboxFt = 'http://www.roblox.com/asset/?id=16888848245',
                SkyboxLf = 'http://www.roblox.com/asset/?id=16888850949',
                SkyboxRt = 'http://www.roblox.com/asset/?id=16888854243',
                SkyboxUp = 'http://www.roblox.com/asset/?id=16888857144',
            },
            Office = {
                SkyboxBk = 'rbxassetid://658623433',
                SkyboxDn = 'rbxassetid://316342560',
                SkyboxFt = 'rbxassetid://658625205',
                SkyboxLf = 'rbxassetid://658627155',
                SkyboxRt = 'rbxassetid://658628504',
                SkyboxUp = 'rbxassetid://658632701',
            },
            Spongebob2 = {
                SkyboxBk = 'rbxassetid://12049872454',
                SkyboxDn = 'rbxassetid://12049872284',
                SkyboxFt = 'rbxassetid://12049872181',
                SkyboxLf = 'rbxassetid://12049872074',
                SkyboxRt = 'rbxassetid://12049871884',
                SkyboxUp = 'rbxassetid://12049871774',
            },
            PurpleFog = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=17279854976',
                SkyboxDn = 'http://www.roblox.com/asset/?id=17279856318',
                SkyboxFt = 'http://www.roblox.com/asset/?id=17279858447',
                SkyboxLf = 'http://www.roblox.com/asset/?id=17279860360',
                SkyboxRt = 'http://www.roblox.com/asset/?id=17279862234',
                SkyboxUp = 'http://www.roblox.com/asset/?id=17279864507',
            },
            EarthSpace = {
                SkyboxBk = 'rbxassetid://15753305495',
                SkyboxDn = 'rbxassetid://15753362674',
                SkyboxFt = 'rbxassetid://15753305823',
                SkyboxLf = 'rbxassetid://15753310707',
                SkyboxRt = 'rbxassetid://15753304774',
                SkyboxUp = 'rbxassetid://15753304473',
            },
            GreenCloudy = {
                SkyboxBk = 'rbxassetid://921882045',
                SkyboxDn = 'rbxassetid://921881907',
                SkyboxFt = 'rbxassetid://921882121',
                SkyboxLf = 'rbxassetid://921881811',
                SkyboxRt = 'rbxassetid://921881989',
                SkyboxUp = 'rbxassetid://921882259',
            },
            SummerDay = {
                SkyboxBk = 'http://www.roblox.com/asset/?version=1&id=135483466',
                SkyboxDn = 'http://www.roblox.com/asset/?version=1&id=135483484',
                SkyboxFt = 'http://www.roblox.com/asset/?version=1&id=135483461',
                SkyboxLf = 'http://www.roblox.com/asset/?version=1&id=135483495',
                SkyboxRt = 'http://www.roblox.com/asset/?version=1&id=135483499',
                SkyboxUp = 'http://www.roblox.com/asset/?version=1&id=135483475',
            },
            SnowyPlains = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=155657655',
                SkyboxDn = 'http://www.roblox.com/asset/?id=155674246',
                SkyboxFt = 'http://www.roblox.com/asset/?id=155657609',
                SkyboxLf = 'http://www.roblox.com/asset/?id=155657671',
                SkyboxRt = 'http://www.roblox.com/asset/?id=155657619',
                SkyboxUp = 'http://www.roblox.com/asset/?id=155674931',
            },
            Underwater = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=227635868',
                SkyboxDn = 'http://www.roblox.com/asset/?id=227635921',
                SkyboxFt = 'http://www.roblox.com/asset/?id=227635954',
                SkyboxLf = 'http://www.roblox.com/asset/?id=227635974',
                SkyboxRt = 'http://www.roblox.com/asset/?id=227635990',
                SkyboxUp = 'http://www.roblox.com/asset/?id=227636031',
            },
            BlueAbyss = {
                SkyboxBk = 'rbxassetid://16269815885',
                SkyboxDn = 'rbxassetid://16269839652',
                SkyboxFt = 'rbxassetid://16269798011',
                SkyboxLf = 'rbxassetid://16269813852',
                SkyboxRt = 'rbxassetid://16269814948',
                SkyboxUp = 'rbxassetid://16269829700',
            },
            Poison = {
                SkyboxBk = 'rbxassetid://1370716695',
                SkyboxDn = 'rbxassetid://1370716766',
                SkyboxFt = 'rbxassetid://1370716833',
                SkyboxLf = 'rbxassetid://1370716898',
                SkyboxRt = 'rbxassetid://1370716955',
                SkyboxUp = 'rbxassetid://1370717024',
            },
            BlueSpace = {
                SkyboxBk = 'rbxassetid://1127563035',
                SkyboxDn = 'rbxassetid://1127563006',
                SkyboxFt = 'rbxassetid://1127563026',
                SkyboxLf = 'rbxassetid://1127563216',
                SkyboxRt = 'rbxassetid://1127563115',
                SkyboxUp = 'rbxassetid://1127562999',
            },
            AnimeMountains = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=12849370744',
                SkyboxDn = 'http://www.roblox.com/asset/?id=12849378890',
                SkyboxFt = 'http://www.roblox.com/asset/?id=12849390276',
                SkyboxLf = 'http://www.roblox.com/asset/?id=12849405549',
                SkyboxRt = 'http://www.roblox.com/asset/?id=12849398428',
                SkyboxUp = 'http://www.roblox.com/asset/?id=12849426002',
            },
            PinkGradient = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=5371541816',
                SkyboxDn = 'http://www.roblox.com/asset/?id=5371541154',
                SkyboxFt = 'http://www.roblox.com/asset/?id=5371541816',
                SkyboxLf = 'http://www.roblox.com/asset/?id=5371541816',
                SkyboxRt = 'http://www.roblox.com/asset/?id=5371541816',
                SkyboxUp = 'http://www.roblox.com/asset/?id=5371540604',
            },
            YellowGradient = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=159005370',
                SkyboxDn = 'rbxassetid://858422412',
                SkyboxFt = 'http://www.roblox.com/asset/?id=159005370',
                SkyboxLf = 'http://www.roblox.com/asset/?id=159005370',
                SkyboxRt = 'http://www.roblox.com/asset/?id=159005370',
                SkyboxUp = 'http://www.roblox.com/asset/?id=159006363',
            },
            BlueGradient = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=4628466090',
                SkyboxDn = 'http://www.roblox.com/asset/?id=4628471901',
                SkyboxFt = 'http://www.roblox.com/asset/?id=4628466090',
                SkyboxLf = 'http://www.roblox.com/asset/?id=4628466090',
                SkyboxRt = 'http://www.roblox.com/asset/?id=4628466090',
                SkyboxUp = 'http://www.roblox.com/asset/?id=4628472152',
            },
            GreenNebula = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=47974894',
                SkyboxDn = 'http://www.roblox.com/asset/?id=47974690',
                SkyboxFt = 'http://www.roblox.com/asset/?id=47974821',
                SkyboxLf = 'http://www.roblox.com/asset/?id=47974776',
                SkyboxRt = 'http://www.roblox.com/asset/?id=47974859',
                SkyboxUp = 'http://www.roblox.com/asset/?id=47974909',
            },
            OrangeGradient = {
                SkyboxBk = 'rbxassetid://6902754982',
                SkyboxDn = 'rbxassetid://6902795826',
                SkyboxFt = 'rbxassetid://6902754982',
                SkyboxLf = 'rbxassetid://6902754982',
                SkyboxRt = 'rbxassetid://6902754982',
                SkyboxUp = 'rbxassetid://6902796078',
            },
            GreenAurora = {
                SkyboxBk = 'http://www.roblox.com/asset/?id=16563478983',
                SkyboxDn = 'http://www.roblox.com/asset/?id=16563481302',
                SkyboxFt = 'http://www.roblox.com/asset/?id=16563484084',
                SkyboxLf = 'http://www.roblox.com/asset/?id=16563485362',
                SkyboxRt = 'http://www.roblox.com/asset/?id=16563487078',
                SkyboxUp = 'http://www.roblox.com/asset/?id=16563489821',
            },
        }
        local skyboxNames = {}

        for k in pairs(SkyboxAssets)do
            table.insert(skyboxNames, k)
        end

        table.sort(skyboxNames)

        local function applyCustomSkybox(name)
            if customSkyInstance then
                customSkyInstance:Destroy()
            end

            customSkyInstance = Instance.new('Sky')

            local sky = SkyboxAssets[name]

            customSkyInstance.SkyboxBk = sky.SkyboxBk
            customSkyInstance.SkyboxDn = sky.SkyboxDn
            customSkyInstance.SkyboxFt = sky.SkyboxFt
            customSkyInstance.SkyboxLf = sky.SkyboxLf
            customSkyInstance.SkyboxRt = sky.SkyboxRt
            customSkyInstance.SkyboxUp = sky.SkyboxUp
            customSkyInstance.Name = 'CustomSky'
            customSkyInstance.Parent = lighting
        end
        local function restoreDefaultSkybox()
            if customSkyInstance then
                customSkyInstance:Destroy()

                customSkyInstance = nil
            end
            if DefaultSky then
                DefaultSky.SkyboxBk = LightingSettings.DefaultSkyboxBk
                DefaultSky.SkyboxDn = LightingSettings.DefaultSkyboxDn
                DefaultSky.SkyboxFt = LightingSettings.DefaultSkyboxFt
                DefaultSky.SkyboxLf = LightingSettings.DefaultSkyboxLf
                DefaultSky.SkyboxRt = LightingSettings.DefaultSkyboxRt
                DefaultSky.SkyboxUp = LightingSettings.DefaultSkyboxUp
                DefaultSky.Parent = lighting
            end
        end

        LightingGroup:AddToggle('CustomSkyboxEnabled', {
            Text = 'Custom Skybox',
            Default = false,
            Callback = function(Value)
                if Value then
                    applyCustomSkybox(SelectedSkybox)
                else
                    restoreDefaultSkybox()
                end
            end,
        })
        LightingGroup:AddDropdown('SkyboxSelected', {
            Values = skyboxNames,
            Default = 'Minecraft',
            Multi = false,
            Text = 'Skybox',
            Callback = function(Value)
                SelectedSkybox = Value

                if Toggles.CustomSkyboxEnabled.Value then
                    applyCustomSkybox(SelectedSkybox)
                end
            end,
        })

end)()
coroutine.wrap(function()
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

    MenuGroup:AddToggle('KeybindMenuOpen', {
        Default = Library.KeybindFrame.Visible,
        Text = 'Open Keybind Menu',
        Callback = function(value)
            Library.KeybindFrame.Visible = value
        end,
    })
    MenuGroup:AddDropdown('NotificationSide', {
        Values = {
            'Left',
            'Right',
        },
        Default = 'Right',
        Text = 'Notification Side',
        Callback = function(Value)
            Library:SetNotifySide(Value)
        end,
    })
    MenuGroup:AddDropdown('DPIDropdown', {
        Values = {
            '50%',
            '75%',
            '100%',
            '125%',
            '150%',
            '175%',
            '200%',
        },
        Default = '100%',
        Text = 'DPI Scale',
        Callback = function(Value)
            Value = Value:gsub('%%', '')

            local DPI = tonumber(Value)

            Library:SetDPIScale(DPI)
        end,
    })
    MenuGroup:AddDivider()
    MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
        Default = 'K',
        NoUI = true,
        Text = 'Menu keybind',
    })
    MenuGroup:AddButton('Unload', function()
        Library:Unload()
    end)

    getgenv().vu = game:GetService('VirtualUser')
    getgenv().isAntiAfkEnabled = false
    getgenv().antiAfkConnection = nil

    MenuGroup:AddToggle('AntiAFKToggle', {
        Text = 'Anti-AFK',
        Default = false,
        Tooltip = 'Prevent AFK timeout',
        Callback = function(state)
            getgenv().isAntiAfkEnabled = state

            if getgenv().isAntiAfkEnabled then
                getgenv().antiAfkConnection = game:GetService('Players').LocalPlayer.Idled:Connect(function()
                    getgenv().vu:CaptureController()
                    getgenv().vu:ClickButton2(Vector2.new())
                end)
            else
                if getgenv().antiAfkConnection then
                    getgenv().antiAfkConnection:Disconnect()

                    getgenv().antiAfkConnection = nil
                end
            end
        end,
        Disabled = false,
        Visible = true,
    })
    MenuGroup:AddButton({
        Text = 'Copy Job ID',
        Func = function()
            setclipboard(game.JobId)
        end,
        Tooltip = 'Copy the current server Job ID to clipboard',
        DoubleClick = false,
        Disabled = false,
        Visible = true,
    })
    MenuGroup:AddButton({
        Text = 'Copy JS Join Script',
        Func = function()
            local jsScript = 'game:GetService("TeleportService"):TeleportToPlaceInstance(' .. game.PlaceId .. ', "' .. game.JobId .. '", game.Players.LocalPlayer)'

            setclipboard(jsScript)
        end,
        Tooltip = 'Copy the join script for the current server',
        DoubleClick = false,
        Disabled = false,
        Visible = true,
    })
    MenuGroup:AddInput('JobIdInput', {
        Default = '',
        Numeric = false,
        Finished = true,
        Text = '..JobId..',
        Tooltip = 'Enter a Job ID to join a specific server',
        Placeholder = 'Enter Job ID here',
        ClearTextOnFocus = true,
        Callback = function(Value)
            game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, Value, game:GetService('Players').LocalPlayer)
        end,
        Disabled = false,
        Visible = true,
    })
    MenuGroup:AddButton({
        Text = 'Rejoin Server',
        Func = function()
            game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
        end,
        Tooltip = 'Rejoin the current server',
        DoubleClick = false,
        Disabled = false,
        Visible = true,
    })
    Library:SetWatermarkVisibility(true)

    getgenv().DYHUB = {}
    getgenv().DYHUB.WatermarkEnabled = true
    getgenv().DYHUB.WatermarkShowFPS = true
    getgenv().DYHUB.WatermarkShowGameName = false
    getgenv().DYHUB.WatermarkShowUptime = false
    getgenv().DYHUB.WatermarkShowExecutor = false
    getgenv().DYHUB.WatermarkShowPing = true

    local Stats = game:GetService('Stats')
    local FrameTimer = tick()
    local FrameCounter = 0
    local FPS = 60
    local StartTime = tick()

    local function getExecutor()
        if syn then
            return 'Synapse X'
        end
        if secure_call then
            return 'ScriptWare'
        end
        if identifyexecutor then
            return identifyexecutor()
        end

        return 'Unknown'
    end

    local MarketplaceService = game:GetService('MarketplaceService')

    local function getGameName(placeId)
        local success, result = pcall(function()
            return MarketplaceService:GetProductInfo(placeId).Name
        end)

        return success and result or 'Unknown Game'
    end
    local function updateWatermark()
        FrameCounter += 1

        if (tick() - FrameTimer) >= 1 then
            FPS = FrameCounter
            FrameTimer = tick()
            FrameCounter = 0
        end

        local Ping = math.floor(Stats.Network.ServerStatsItem['Data Ping']:GetValue())
        local Executor = getExecutor()
        local Uptime = math.floor(tick() - StartTime)
        local UptimeFormatted = string.format('%02d:%02d', math.floor(Uptime / 60), Uptime % 60)
        local GameName = getGameName(game.PlaceId)
        local watermarkParts = {
            'DYHUB.tea',
        }

        if getgenv().DYHUB.WatermarkShowExecutor then
            table.insert(watermarkParts, Executor)
        end
        if getgenv().DYHUB.WatermarkShowGameName then
            table.insert(watermarkParts, string.format('%s (%d)', GameName, game.PlaceId))
        end
        if getgenv().DYHUB.WatermarkShowUptime then
            table.insert(watermarkParts, string.format('Uptime: %s', UptimeFormatted))
        end
        if getgenv().DYHUB.WatermarkShowFPS then
            table.insert(watermarkParts, string.format('FPS %d', math.floor(FPS)))
        end
        if getgenv().DYHUB.WatermarkShowPing then
            table.insert(watermarkParts, string.format('%d ms', Ping))
        end

        Library:SetWatermark(table.concat(watermarkParts, ' | '))
        Library:SetWatermarkVisibility(getgenv().DYHUB.WatermarkEnabled)
    end

    local WatermarkConnection = RunService.RenderStepped:Connect(updateWatermark)
    local WatermarkGroup = Tabs['UI Settings']:AddRightGroupbox('Watermark')

    WatermarkGroup:AddToggle('WatermarkEnabled', {
        Text = 'Enabled',
        Default = true,
        Callback = function(Value)
            getgenv().DYHUB.WatermarkEnabled = Value
        end,
    })
    WatermarkGroup:AddToggle('WatermarkShowFPS', {
        Text = 'Show FPS',
        Default = true,
        Callback = function(Value)
            getgenv().DYHUB.WatermarkShowFPS = Value
        end,
    })
    WatermarkGroup:AddToggle('WatermarkShowGameName', {
        Text = 'Show Game Name',
        Default = false,
        Callback = function(Value)
            getgenv().DYHUB.WatermarkShowGameName = Value
        end,
    })
    WatermarkGroup:AddToggle('WatermarkShowUptime', {
        Text = 'Show Uptime',
        Default = false,
        Callback = function(Value)
            getgenv().DYHUB.WatermarkShowUptime = Value
        end,
    })
    WatermarkGroup:AddToggle('WatermarkShowExecutor', {
        Text = 'Show Executor',
        Default = false,
        Callback = function(Value)
            getgenv().DYHUB.WatermarkShowExecutor = Value
        end,
    })
    WatermarkGroup:AddToggle('WatermarkShowPing', {
        Text = 'Show Ping',
        Default = true,
        Callback = function(Value)
            getgenv().DYHUB.WatermarkShowPing = Value
        end,
    })

    Library.ToggleKeybind = Options.MenuKeybind

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({
        'MenuKeybind',
    })
    ThemeManager:SetFolder('DYHUBog')
    SaveManager:SetFolder('DYHUBog/dahood')
    SaveManager:BuildConfigSection(Tabs['UI Settings'])
    ThemeManager:ApplyToTab(Tabs['UI Settings'])
    SaveManager:LoadAutoloadConfig()
    table.insert(Storage.Connections, TracerUpdateConnection)
    Library:OnUnload(function()
	    if TracerUpdateConnection then
	        TracerUpdateConnection:Disconnect()
	    end
	    for _, ply in ipairs(game.Players:GetPlayers()) do
	        removeTracer(ply)
	    end
        workspace.FallenPartsDestroyHeight = 0 / 0

        print('Unloaded!')

        Library.Unloaded = true

        for _, conn in ipairs(Storage.Connections)do
            conn:Disconnect()
        end
    end)
end)()
Library:Notify('Script Loaded', 3)
