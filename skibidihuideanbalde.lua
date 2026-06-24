repeat task.wait(0.25) until game:IsLoaded()

local ENV = (type(getgenv) == "function" and getgenv()) or _G
ENV.Image = ENV.Image or "rbxassetid://104487529937663"
ENV.ToggleUI = ENV.ToggleUI or "LeftControl"


if ENV.DYHUB_BrokenBladeMerged and type(ENV.DYHUB_BrokenBladeMerged.Stop) == "function" then
    pcall(function()
        ENV.DYHUB_BrokenBladeMerged.Stop()
    end)
end

local Hub = {
    Running = true,
    Connections = {},
    Version = "041.09"
}
ENV.DYHUB_BrokenBladeMerged = Hub

local function AddConnection(c)
    if c then
        table.insert(Hub.Connections, c)
    end
    return c
end

function Hub.Stop()
    Hub.Running = false
    for _, c in ipairs(Hub.Connections) do
        pcall(function()
            c:Disconnect()
        end)
    end
end

local function SafeWait(t)
    local untilTime = os.clock() + (t or 0)
    repeat
        task.wait(math.min(0.1, math.max(0.01, untilTime - os.clock())))
    until (not Hub.Running) or os.clock() >= untilTime
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local Fluent
local ok, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not ok or not Fluent then
    warn("[DYHUB] Failed to load Fluent UI:", err)
    return
end

local Settings = {
    SelectedMobs = {},
    AutoFarm = false,
    AutoFarmBeta = false,
    AutoQuest = false,
    AutoSkills = false,
    AutoAttack = false,
    KillAura = false,
    InfiniteParry = false,
    AutoChests = false,
    AutoEclipse = false,
    CollectGubby = false,
    PlayerESP = false,
    MobESP = false,
    BossESP = false,
    ChestESP = false,
    WalkSpeed = 16,
    JumpPower = 50,
    NoClip = false,
    InfJump = false,
    AntiAFK = true,
    KillAuraRange = 30,
    FarmOffset = 4,
    FarmHeight = 3,
    BossHealth = 500,
    SkillDelay = 0.7,
    MinRewardQuantity = 2,
    BadRewardID = "126209318110046",
    LowGraphics = false
}

_G.BossToNPC_ID = _G.BossToNPC_ID or {
    ["Space Invader"] = "240012",
    ["Hraegon"] = "240011",
    ["Thorvak"] = "240010",
    ["Surtrik"] = "240009",
    ["Niflor"] = "240008",
}

local State = {
    Target = nil,
    QuestGood = true,
    WaitingForQuestReset = false,
    LastKillTime = 0,
    Blacklist = {},
    Dead = {},
    EnemyCache = {},
    MobNames = {},
    MobLevels = setmetatable({}, {__mode = "k"}),
    LastCache = 0,
    LastBetaScan = 0,
    BetaTargetLevel = nil,
    LastPlayerLevel = nil,
    LastQuest = 0,
    LastMove = 0,
    LastAttack = 0,
    LastCollect = 0,
    LastESP = 0,
    ParryVFXObject = nil,
    LastParryTrigger = 0,
    Status = "Idle"
}

local function Notify(title, content, duration)
    pcall(function()
        Fluent:Notify({
            Title = tostring(title or "DYHUB"),
            Content = tostring(content or ""),
            Duration = duration or 3
        })
    end)
end

local function Lower(s)
    return string.lower(tostring(s or ""))
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetPivotPosition(obj)
    if not obj then
        return nil
    end
    if obj:IsA("Model") then
        return obj:GetPivot().Position
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    local part = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    return part and part.Position
end

local function GetPivotCFrame(obj)
    if not obj then
        return nil
    end
    if obj:IsA("Model") then
        return obj:GetPivot()
    elseif obj:IsA("BasePart") then
        return obj.CFrame
    end
    local part = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    return part and part.CFrame
end

local function SafePivot(cf)
    local char = LocalPlayer.Character
    local hum = GetHumanoid()
    local root = GetRoot()

    if not char or not root or not cf then
        return false
    end

    pcall(function()
        if hum then
            hum.Sit = false
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(cf)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    return true
end

local function IsPlayerCharacter(model)
    if not model or not model:IsA("Model") then
        return false
    end
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function GetMobHumanoid(model)
    if not model or not model:IsA("Model") then
        return nil
    end
    return model:FindFirstChildOfClass("Humanoid")
end

local function IsDeadMob(model)
    if not model or not model.Parent then
        return true
    end

    local hum = GetMobHumanoid(model)
    if not hum then
        return true
    end

    if hum.Health > 100 then
        State.Dead[model] = nil
    end

    if State.Dead[model] then
        return true
    end

    if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then
        State.Dead[model] = true
        return true
    end

    if hum.MaxHealth > 100 and hum.Health <= 10 then
        State.Dead[model] = true
        return true
    end

    return false
end

local function IsMob(model)
    if not model or not model:IsA("Model") then
        return false
    end
    if IsPlayerCharacter(model) then
        return false
    end
    local hum = GetMobHumanoid(model)
    if not hum or hum.Health <= 0 then
        return false
    end
    if not (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) then
        return false
    end
    return true
end

local function IsBoss(model)
    local hum = GetMobHumanoid(model)
    return hum and hum.MaxHealth >= Settings.BossHealth
end

local function IsSelected(name)
    local selected = Settings.SelectedMobs or {}
    local hasAny = false

    for k, v in pairs(selected) do
        if v ~= false and v ~= nil then
            hasAny = true
            if tostring(k) == tostring(name) or tostring(v) == tostring(name) then
                return true
            end
        end
    end

    return not hasAny
end

local function ReadObjectText(obj)
    if not obj then
        return nil
    end

    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        return obj.Text
    end

    if obj:IsA("StringValue") then
        return obj.Value
    end

    return nil
end

local function ExtractFirstNumber(text)
    local s = string.gsub(tostring(text or ""), ",", "")
    local n = string.match(s, "(%d+)")
    return tonumber(n)
end

local function ExtractLevelFromText(text)
    local s = string.gsub(tostring(text or ""), ",", "")
    if s == "" then
        return nil
    end

    local level = string.match(s, "[Ll][Vv]%s*%.?%s*[%:%-%[]*%s*(%d+)")
        or string.match(s, "%[[Ll][Vv]%s*%.?%s*(%d+)%]")
        or string.match(s, "[Ll]evel%s*[%:%-%.%[]*%s*(%d+)")

    return tonumber(level)
end

local function GetPlayerLevel()
    local gui = LocalPlayer:FindFirstChild("PlayerGui") or PlayerGui
    local main = gui and gui:FindFirstChild("Main")
    local home = main and main:FindFirstChild("HomePage", true)
    local levelBar = home and home:FindFirstChild("LevelBar", true)
    local numberLabel = levelBar and levelBar:FindFirstChild("Number", true)
    local level = numberLabel and ExtractFirstNumber(ReadObjectText(numberLabel))

    if level then
        State.LastPlayerLevel = level
        return level
    end

    if gui then
        local scanned = 0
        for _, obj in ipairs(gui:GetDescendants()) do
            scanned += 1
            if scanned > 2500 then
                break
            end

            local objName = Lower(obj.Name)
            local parentName = Lower(obj.Parent and obj.Parent.Name or "")
            if (objName == "number" and string.find(parentName, "level", 1, true)) or string.find(objName, "level", 1, true) then
                level = ExtractFirstNumber(ReadObjectText(obj))
                if level then
                    State.LastPlayerLevel = level
                    return level
                end
            end
        end
    end

    return State.LastPlayerLevel
end

local function GetMobLevel(model)
    if not model then
        return nil
    end

    local cached = State.MobLevels[model]
    if cached then
        return cached
    end

    local level = ExtractLevelFromText(model.Name)
    if level then
        State.MobLevels[model] = level
        return level
    end

    local monsterHP = model:FindFirstChild("MonsterHP", true)
    if monsterHP then
        for _, obj in ipairs(monsterHP:GetDescendants()) do
            level = ExtractLevelFromText(ReadObjectText(obj))
            if level then
                State.MobLevels[model] = level
                return level
            end
        end
    end

    local scanned = 0
    for _, obj in ipairs(model:GetDescendants()) do
        scanned += 1
        if scanned > 160 then
            break
        end

        level = ExtractLevelFromText(obj.Name) or ExtractLevelFromText(ReadObjectText(obj))
        if level then
            State.MobLevels[model] = level
            return level
        end
    end

    return nil
end

local function GetEnemyService()
    return workspace:FindFirstChild("EnemyService")
end

local function GetHumanoidOwner(obj)
    local current = obj

    while current and current ~= workspace do
        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
            return current
        end

        current = current.Parent
    end

    return nil
end

local function IsUnderHumanoidModel(obj)
    return GetHumanoidOwner(obj) ~= nil
end

local function IsUnderEnemyService(obj)
    local enemyService = GetEnemyService()
    return enemyService and obj and obj:IsDescendantOf(enemyService)
end

local function HasCollectKeyword(obj, keyWords)
    local lname = Lower(obj and obj.Name or "")

    for _, word in ipairs(keyWords or {}) do
        if string.find(lname, word, 1, true) then
            return true
        end
    end

    return false
end

local function IsValidCollectTarget(obj, keyWords)
    if not obj or not obj.Parent then
        return false
    end

    if not (obj:IsA("BasePart") or obj:IsA("Model")) then
        return false
    end

    if IsUnderHumanoidModel(obj) then
        return false
    end

    if IsUnderEnemyService(obj) then
        return false
    end

    return HasCollectKeyword(obj, keyWords)
end

local function GetCollectRoot(obj, keyWords)
    if not IsValidCollectTarget(obj, keyWords) then
        return nil
    end

    local best = obj
    local current = obj.Parent

    while current and current ~= workspace do
        if (current:IsA("BasePart") or current:IsA("Model")) and IsValidCollectTarget(current, keyWords) then
            best = current
        end

        current = current.Parent
    end

    return best
end

local function RefreshEnemyCache(force)
    if not force and os.clock() - State.LastCache < 4 then
        return State.EnemyCache
    end

    State.LastCache = os.clock()
    State.EnemyCache = {}
    State.MobNames = {}

    local seenNames = {}
    local enemyService = GetEnemyService()

    if enemyService then
        for _, obj in ipairs(enemyService:GetChildren()) do
            if IsMob(obj) then
                table.insert(State.EnemyCache, obj)
                if not seenNames[obj.Name] then
                    seenNames[obj.Name] = true
                    table.insert(State.MobNames, obj.Name)
                end
            end
        end
    else
        local checked = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            checked += 1
            if checked > 7000 then
                break
            end
            if IsMob(obj) then
                table.insert(State.EnemyCache, obj)
                if not seenNames[obj.Name] then
                    seenNames[obj.Name] = true
                    table.insert(State.MobNames, obj.Name)
                end
            end
        end
    end

    table.sort(State.MobNames, function(a, b)
        return Lower(a) < Lower(b)
    end)

    return State.EnemyCache
end

local function GetMobList(force)
    RefreshEnemyCache(force)
    local list = {}
    for _, name in ipairs(State.MobNames) do
        table.insert(list, name)
    end
    if #list == 0 then
        table.insert(list, "No mobs found - press Refresh")
    end
    return list
end

local function SelectTarget(bossOnly)
    local root = GetRoot()
    RefreshEnemyCache(false)

    local best, bestDist = nil, math.huge

    for _, mob in ipairs(State.EnemyCache) do
        if IsMob(mob) and not IsDeadMob(mob) and IsSelected(mob.Name) then
            if (not bossOnly) or IsBoss(mob) then
                if not State.Blacklist[mob] or os.clock() > State.Blacklist[mob] then
                    local pos = GetPivotPosition(mob)
                    local dist = root and pos and (pos - root.Position).Magnitude or 0
                    if dist < bestDist then
                        best = mob
                        bestDist = dist
                    end
                end
            end
        end
    end

    if not best and bossOnly then
        for _, mob in ipairs(State.EnemyCache) do
            if IsMob(mob) and not IsDeadMob(mob) and IsSelected(mob.Name) then
                local pos = GetPivotPosition(mob)
                local dist = root and pos and (pos - root.Position).Magnitude or 0
                if dist < bestDist then
                    best = mob
                    bestDist = dist
                end
            end
        end
    end

    State.Target = best
    return best
end

local function SelectAutoLevelTarget(forceRefresh)
    local root = GetRoot()
    local playerLevel = GetPlayerLevel()

    if not playerLevel then
        State.Status = "BETA: Cannot read your level"
        State.Target = nil
        State.BetaTargetLevel = nil
        return nil, nil, nil
    end

    RefreshEnemyCache(forceRefresh == true)

    local best, bestDist, bestLevel = nil, math.huge, -1
    local lowestAbove = math.huge
    local foundLevel = false

    for _, mob in ipairs(State.EnemyCache) do
        if IsMob(mob) and not IsDeadMob(mob) then
            if not State.Blacklist[mob] or os.clock() > State.Blacklist[mob] then
                local mobLevel = GetMobLevel(mob)

                if mobLevel then
                    foundLevel = true

                    if mobLevel <= playerLevel then
                        local pos = GetPivotPosition(mob)
                        local dist = root and pos and (pos - root.Position).Magnitude or 0

                        if mobLevel > bestLevel or (mobLevel == bestLevel and dist < bestDist) then
                            best = mob
                            bestDist = dist
                            bestLevel = mobLevel
                        end
                    elseif mobLevel < lowestAbove then
                        lowestAbove = mobLevel
                    end
                end
            end
        end
    end

    State.Target = best
    State.BetaTargetLevel = best and bestLevel or nil

    if best then
        State.Status = "BETA: Farming Lv." .. tostring(bestLevel) .. " / Your Lv." .. tostring(playerLevel)
    elseif foundLevel and lowestAbove < math.huge then
        State.Status = "BETA: Next mob unlocks at Lv." .. tostring(lowestAbove)
    else
        State.Status = "BETA: No suitable mob level found"
    end

    return best, State.BetaTargetLevel, playerLevel
end

local function PressKey(keyName)
    local key = Enum.KeyCode[keyName]
    if not key then
        return
    end

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.025)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end

local function FindParryVFX()
    local runtime = workspace:FindFirstChild("__Player3CSkillRuntime")
    if not runtime then
        return nil
    end

    local vfx = runtime:FindFirstChild("Boss攻击红光VFX")
    if vfx and vfx.Parent then
        return vfx
    end

    return runtime:FindFirstChild("Boss攻击红光VFX", true)
end

local function SmartParryStep()
    if not Settings.InfiniteParry then
        State.ParryVFXObject = nil
        return
    end

    local vfx = FindParryVFX()
    if not vfx then
        State.ParryVFXObject = nil
        return
    end

    if State.ParryVFXObject == vfx then
        return
    end

    if os.clock() - State.LastParryTrigger < 0.25 then
        State.ParryVFXObject = vfx
        return
    end

    State.ParryVFXObject = vfx
    State.LastParryTrigger = os.clock()
    PressKey("F")
    State.Status = "Boss attack blocked"
end

local function ClickAttack()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(999, 999))
    end)

    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.025)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

local function FindFirstPrompt(obj)
    if not obj then
        return nil
    end

    if obj:IsA("ProximityPrompt") then
        return obj
    end

    return obj:FindFirstChildWhichIsA("ProximityPrompt", true)
end

local function FirePrompt(prompt)
    if not prompt then
        return false
    end

    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 9999)
        prompt.HoldDuration = 0
    end)

    if type(fireproximityprompt) == "function" then
        pcall(function()
            fireproximityprompt(prompt)
        end)
        return true
    end

    return false
end

local function FastClick(button)
    if not button then
        return false
    end

    pcall(function()
        if type(getconnections) == "function" then
            for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                connection:Fire()
            end
            for _, connection in pairs(getconnections(button.Activated)) do
                connection:Fire()
            end
        end
    end)

    pcall(function()
        if button.Activate then
            button:Activate()
        end
    end)

    return true
end

local function CleanBossName(name)
    local cleaned = string.match(tostring(name or ""), "%]%s*(.+)$") or tostring(name or "")
    return cleaned
end

local function GetNPCForBoss(bossModel)
    if not bossModel then
        return nil
    end

    local rawBossName = CleanBossName(bossModel.Name)
    local npcID = _G.BossToNPC_ID[rawBossName] or _G.BossToNPC_ID[bossModel.Name]
    if not npcID then
        return nil
    end

    local world = workspace:FindFirstChild("World")
    local npc = world and world:FindFirstChild("NPC")
    local bossTask = npc and npc:FindFirstChild("BossTask")

    return bossTask and bossTask:FindFirstChild(npcID)
end

local function GetTaskFolder()
    local main = PlayerGui:FindFirstChild("Main")
    local home = main and main:FindFirstChild("HomePage")
    local panel = home and home:FindFirstChild("TaskPanel")
    local content = panel and panel:FindFirstChild("Content")
    return content and content:FindFirstChild("Task")
end

local function GiveUpQuest(frame)
    if not frame then
        return
    end

    local title = frame:FindFirstChild("Title")
    local giveUp = title and title:FindFirstChild("GiveUp")
    local button = (giveUp and giveUp:FindFirstChild("BG")) or giveUp

    if button then
        FastClick(button)
    end
end

local function InteractBossNPC(target)
    local npc = GetNPCForBoss(target)
    if not npc then
        return false
    end

    local cf = GetPivotCFrame(npc)
    if cf then
        SafePivot(cf * CFrame.new(0, 0, 2))
        SafeWait(0.15)
    end

    local prompt
    for _ = 1, 20 do
        prompt = FindFirstPrompt(npc)
        if prompt then
            break
        end
        task.wait(0.05)
    end

    if prompt then
        FirePrompt(prompt)
        PressKey("E")
        return true
    end

    return false
end

local function CheckQuest(target)
    if not Settings.AutoQuest then
        State.QuestGood = true
        return true
    end

    if not target then
        State.QuestGood = false
        return false
    end

    if State.WaitingForQuestReset then
        State.QuestGood = false
        if os.clock() - State.LastKillTime > 1.5 then
            State.WaitingForQuestReset = false
        end
        return false
    end

    if os.clock() - State.LastQuest < 0.45 then
        return State.QuestGood
    end
    State.LastQuest = os.clock()

    local taskFolder = GetTaskFolder()
    local targetName = Lower(CleanBossName(target.Name))
    local questState = "None"
    local questFrame = nil

    if taskFolder then
        for _, quest in ipairs(taskFolder:GetChildren()) do
            if (quest:IsA("Frame") or quest:IsA("ImageLabel")) and quest.Name ~= "Template" and quest.Visible == true then
                questState = "Good"
                questFrame = quest

                local foundBossName = false
                local badReward = false
                local lowQuantity = false

                for _, v in ipairs(quest:GetDescendants()) do
                    if (v:IsA("ImageLabel") or v:IsA("ImageButton")) and v.Image then
                        if Settings.BadRewardID ~= "" and string.find(v.Image, Settings.BadRewardID, 1, true) then
                            badReward = true
                        end
                    elseif v:IsA("TextLabel") and v.Text then
                        local textLower = Lower(v.Text)
                        if string.find(textLower, targetName, 1, true) then
                            foundBossName = true
                        end

                        local cleanText = string.gsub(v.Text, "%s+", "")
                        local quantity = tonumber(cleanText) or tonumber(string.match(cleanText, "^x(%d+)$")) or tonumber(string.match(cleanText, "(%d+)"))
                        if quantity and quantity < Settings.MinRewardQuantity then
                            lowQuantity = true
                        end
                    end
                end

                if not foundBossName then
                    questState = "WrongQuest"
                elseif badReward or lowQuantity then
                    questState = "Bad"
                end

                break
            end
        end
    end

    if questState == "Good" then
        State.QuestGood = true
        State.Status = "Quest ready"
        return true
    end

    State.QuestGood = false
    State.Status = "Finding better quest"

    if questFrame and (questState == "WrongQuest" or questState == "Bad") then
        GiveUpQuest(questFrame)
        SafeWait(0.1)
    end

    InteractBossNPC(target)

    return false
end

local function FarmTarget()
    local target = State.Target
    if not target or not IsMob(target) or IsDeadMob(target) or not IsSelected(target.Name) then
        if target and IsDeadMob(target) then
            State.WaitingForQuestReset = true
            State.LastKillTime = os.clock()
        end
        target = SelectTarget(true)
    end

    if not target then
        State.Status = "No target found"
        return
    end

    if not CheckQuest(target) then
        return
    end

    local cf = GetPivotCFrame(target)
    if not cf then
        State.Blacklist[target] = os.clock() + 5
        State.Target = nil
        return
    end

    if os.clock() - State.LastMove > 0.12 then
        State.LastMove = os.clock()
        SafePivot(cf * CFrame.new(0, Settings.FarmHeight, Settings.FarmOffset))
    end

    if os.clock() - State.LastAttack > 0.12 then
        State.LastAttack = os.clock()
        ClickAttack()
    end

    State.Status = "Farming: " .. target.Name
end

local function FarmTargetBeta()
    local playerLevel = GetPlayerLevel()
    local target = State.Target
    local targetLevel = target and GetMobLevel(target)
    local shouldReselect = false

    if not playerLevel then
        State.Status = "BETA: Cannot read your level"
        return
    end

    if not target or not IsMob(target) or IsDeadMob(target) or not targetLevel or targetLevel > playerLevel then
        if target and IsDeadMob(target) then
            State.WaitingForQuestReset = true
            State.LastKillTime = os.clock()
        end
        shouldReselect = true
    end

    if not shouldReselect and os.clock() - State.LastBetaScan > 1.25 then
        State.LastBetaScan = os.clock()
        local best, bestLevel = SelectAutoLevelTarget(false)
        if best and bestLevel and targetLevel and bestLevel >= targetLevel then
            target = best
            targetLevel = bestLevel
        end
    end

    if shouldReselect then
        target, targetLevel, playerLevel = SelectAutoLevelTarget(true)
    end

    if not target then
        return
    end

    if not CheckQuest(target) then
        return
    end

    local cf = GetPivotCFrame(target)
    if not cf then
        State.Blacklist[target] = os.clock() + 5
        State.Target = nil
        State.BetaTargetLevel = nil
        return
    end

    if os.clock() - State.LastMove > 0.12 then
        State.LastMove = os.clock()
        SafePivot(cf * CFrame.new(0, Settings.FarmHeight, Settings.FarmOffset))
    end

    if os.clock() - State.LastAttack > 0.12 then
        State.LastAttack = os.clock()
        ClickAttack()
    end

    State.Status = "BETA farming Lv." .. tostring(targetLevel or "?") .. " / Your Lv." .. tostring(playerLevel or "?") .. ": " .. target.Name
end

local function KillAuraStep()
    if not Settings.KillAura then
        return
    end

    local root = GetRoot()
    if not root then
        return
    end

    RefreshEnemyCache(false)

    local attacked = false
    for _, mob in ipairs(State.EnemyCache) do
        if IsMob(mob) and not IsDeadMob(mob) then
            local pos = GetPivotPosition(mob)
            if pos and (pos - root.Position).Magnitude <= Settings.KillAuraRange then
                attacked = true
                break
            end
        end
    end

    if attacked then
        ClickAttack()
    end
end

local function AutoCollectStep(kind)
    if os.clock() - State.LastCollect < 0.75 then
        return
    end
    State.LastCollect = os.clock()

    local root = GetRoot()
    if not root then
        return
    end

    local keyWords
    if kind == "chest" then
        keyWords = {"chest", "holy", "crate", "reward"}
    elseif kind == "gubby" then
        keyWords = {"gubby"}
    else
        keyWords = {"eclipse"}
    end

    local found = 0
    local scanned = 0
    local used = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        scanned += 1
        if scanned > 9000 or found >= 5 then
            break
        end

        local target = GetCollectRoot(obj, keyWords)

        if target and not used[target] then
            used[target] = true

            local cf = GetPivotCFrame(target)
            if cf then
                SafePivot(cf + Vector3.new(0, 3, 0))
                SafeWait(0.08)

                local prompt = FindFirstPrompt(target)
                if prompt then
                    FirePrompt(prompt)
                end

                pcall(function()
                    local touchPart = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart", true)
                    if type(firetouchinterest) == "function" and touchPart and not IsUnderHumanoidModel(touchPart) then
                        firetouchinterest(root, touchPart, 0)
                        task.wait(0.03)
                        firetouchinterest(root, touchPart, 1)
                    end
                end)

                found += 1
            end
        end
    end
end

local function FindWorldTarget(name)
    local lname = Lower(name)

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            local parentName = parent and Lower(parent.Name) or ""
            local grandName = parent and parent.Parent and Lower(parent.Parent.Name) or ""

            if string.find(parentName, lname, 1, true) or string.find(grandName, lname, 1, true) then
                FirePrompt(obj)
                return true
            end
        end
    end

    local first4 = string.sub(lname, 1, math.min(4, #lname))

    for _, obj in ipairs(workspace:GetDescendants()) do
        local objName = Lower(obj.Name)
        local parentName = obj.Parent and Lower(obj.Parent.Name) or ""

        if string.find(objName, lname, 1, true) or string.find(parentName, lname, 1, true) or (#first4 >= 3 and string.find(objName, first4, 1, true)) then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local cf = GetPivotCFrame(obj)
                if cf then
                    SafePivot(cf + Vector3.new(0, 8, 0))
                    return true
                end
            end
        end
    end

    return false
end

local function TeleportNearest(bossOnly)
    RefreshEnemyCache(true)
    local old = State.Target
    State.Target = nil
    local target = SelectTarget(bossOnly)
    State.Target = old

    if target then
        local cf = GetPivotCFrame(target)
        if cf then
            SafePivot(cf * CFrame.new(0, 3, bossOnly and 8 or 5))
            Notify("Teleport", "Teleported to " .. target.Name, 2)
            return
        end
    end

    Notify("Teleport", "No target found.", 2)
end

local ESPFolder
local ESPItems = {}

local function GetESPFolder()
    if ESPFolder and ESPFolder.Parent then
        return ESPFolder
    end

    local parent = (type(gethui) == "function" and gethui()) or CoreGui
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "DYHUB_BrokenBlade_ESP"
    ESPFolder.Parent = parent
    return ESPFolder
end

local function RemoveESP(obj)
    local data = ESPItems[obj]
    if data then
        for _, item in pairs(data) do
            pcall(function()
                item:Destroy()
            end)
        end
        ESPItems[obj] = nil
    end
end

local function AddESP(obj, text, color)
    if not obj or not obj.Parent then
        return
    end

    if ESPItems[obj] then
        return
    end

    local part = obj:IsA("BasePart") and obj or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    if not part then
        return
    end

    local folder = GetESPFolder()
    local highlight = Instance.new("Highlight")
    highlight.Name = "DYHUB_Highlight"
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Adornee = obj
    highlight.Parent = folder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DYHUB_Label"
    billboard.Adornee = part
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 140, 0, 26)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = folder

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextStrokeTransparency = 0.3
    label.TextColor3 = color
    label.Text = text
    label.Parent = billboard

    ESPItems[obj] = {highlight, billboard}
end

local function ClearESP()
    for obj in pairs(ESPItems) do
        RemoveESP(obj)
    end
end

local function UpdateESP()
    if os.clock() - State.LastESP < 1.5 then
        return
    end
    State.LastESP = os.clock()

    if not Settings.PlayerESP and not Settings.MobESP and not Settings.BossESP and not Settings.ChestESP then
        ClearESP()
        return
    end

    for obj in pairs(ESPItems) do
        if not obj or not obj.Parent then
            RemoveESP(obj)
        end
    end

    if Settings.PlayerESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                AddESP(player.Character, player.Name, Color3.fromRGB(80, 170, 255))
            end
        end
    end

    if Settings.MobESP or Settings.BossESP then
        RefreshEnemyCache(false)
        for _, mob in ipairs(State.EnemyCache) do
            if IsMob(mob) then
                if IsBoss(mob) then
                    if Settings.BossESP then
                        AddESP(mob, "[Boss] " .. mob.Name, Color3.fromRGB(255, 120, 80))
                    end
                elseif Settings.MobESP then
                    AddESP(mob, "[Mob] " .. mob.Name, Color3.fromRGB(120, 255, 120))
                end
            end
        end
    end

    if Settings.ChestESP then
        local added = 0
        local scanned = 0
        local used = {}
        local chestWords = {"chest", "holy", "crate", "reward"}

        for _, obj in ipairs(workspace:GetDescendants()) do
            scanned += 1
            if scanned > 9000 or added >= 80 then
                break
            end

            local target = GetCollectRoot(obj, chestWords)

            if target and not used[target] then
                used[target] = true
                AddESP(target, "[Chest] " .. target.Name, Color3.fromRGB(255, 220, 120))
                added += 1
            end
        end
    end
end

local function ApplyLowGraphics()
    Settings.LowGraphics = true

    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.ShadowSoftness = 0
    end)

    if Terrain then
        pcall(function()
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
        end)
    end

    local total = 0
    for _, v in ipairs(game:GetDescendants()) do
        total += 1
        if total % 300 == 0 then
            task.wait()
        end

        pcall(function()
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            elseif v:IsA("PostEffect") or v:IsA("Atmosphere") then
                v.Enabled = false
            end
        end)
    end

    Notify("FPS Boost", "Visual effects lowered for better performance.", 3)
end

local function StopAll()
    Settings.AutoFarm = false
    Settings.AutoQuest = false
    Settings.AutoSkills = false
    Settings.AutoAttack = false
    Settings.KillAura = false
    Settings.InfiniteParry = false
    Settings.AutoChests = false
    Settings.AutoEclipse = false
    Settings.CollectGubby = false
    Settings.NoClip = false
    State.Target = nil
    State.QuestGood = true
    State.WaitingForQuestReset = false
    Notify("Emergency Stop", "All active features are now off.", 3)
end

AddConnection(LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

AddConnection(UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local hum = GetHumanoid()
        if hum then
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end
end))

AddConnection(RunService.Stepped:Connect(function()
    if Settings.NoClip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
end))

AddConnection(RunService.Heartbeat:Connect(function()
    if not Hub.Running then
        return
    end

    pcall(function()
        local hum = GetHumanoid()
        if hum then
            if Settings.WalkSpeed > 0 and hum.WalkSpeed ~= Settings.WalkSpeed then
                hum.WalkSpeed = Settings.WalkSpeed
            end
            if Settings.JumpPower > 0 and hum.JumpPower ~= Settings.JumpPower then
                hum.JumpPower = Settings.JumpPower
            end
        end
    end)

    if Settings.AutoFarmBeta then
        FarmTargetBeta()
    elseif Settings.AutoFarm then
        FarmTarget()
    else
        State.Target = nil
        State.BetaTargetLevel = nil
        State.WaitingForQuestReset = false
    end

    if Settings.KillAura then
        KillAuraStep()
    end

    if Settings.AutoChests then
        AutoCollectStep("chest")
    elseif Settings.CollectGubby then
        AutoCollectStep("gubby")
    elseif Settings.AutoEclipse then
        AutoCollectStep("eclipse")
    end

    UpdateESP()
end))

task.spawn(function()
    while Hub.Running do
        if Settings.AutoAttack then
            ClickAttack()
            task.wait(0.12)
        else
            task.wait(0.25)
        end
    end
end)

task.spawn(function()
    while Hub.Running do
        if Settings.InfiniteParry then
            SmartParryStep()
            task.wait(0.03)
        else
            State.ParryVFXObject = nil
            task.wait(0.25)
        end
    end
end)

task.spawn(function()
    while Hub.Running do
        if Settings.AutoSkills and (not (Settings.AutoFarm or Settings.AutoFarmBeta) or (State.Target and State.QuestGood)) then
            PressKey("Z")
            PressKey("Z")
            PressKey("Z")
            PressKey("X")
            PressKey("C")
            PressKey("V")
            task.wait(Settings.SkillDelay)
        else
            task.wait(0.25)
        end
    end
end)

local Window = Fluent:CreateWindow({
    Title = "DYHUB | Broken Blade",
    SubTitle = "by dyumra",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 400),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode[tostring(ENV.ToggleUI or "LeftControl")] or Enum.KeyCode.LeftControl
})

local CombatTab = Window:AddTab({Title = "Main", Icon = "rocket"})
local QuestTab = Window:AddTab({Title = "Quest", Icon = "scroll"})
local CollectTab = Window:AddTab({Title = "Collection", Icon = "package"})
local TeleportTab = Window:AddTab({Title = "Teleport", Icon = "map"})
local PlayerTab = Window:AddTab({Title = "Player", Icon = "user"})
local ESPTab = Window:AddTab({Title = "Visuals", Icon = "eye"})
local SettingsTab = Window:AddTab({Title = "Utility", Icon = "settings"})

local TargetDropdown
local AutoFarmToggle
local AutoFarmBetaToggle

AutoFarmBetaToggle = CombatTab:AddToggle("DYHUB_AutoFarmBeta", {
    Title = "Auto Farm (BETA)",
    Description = "Automatically farms the best mob for your current level.",
    Default = false,
    Callback = function(v)
        Settings.AutoFarmBeta = v
        State.Target = nil
        State.BetaTargetLevel = nil
        State.QuestGood = not Settings.AutoQuest

        if v then
            Settings.AutoFarm = false
            pcall(function()
                if AutoFarmToggle and AutoFarmToggle.SetValue then
                    AutoFarmToggle:SetValue(false)
                elseif AutoFarmToggle and AutoFarmToggle.Set then
                    AutoFarmToggle:Set(false)
                end
            end)
            Notify("Auto Farm BETA", "Now farming by level automatically.", 3)
        end
    end
})

TargetDropdown = CombatTab:AddDropdown("DYHUB_TargetMobs", {
    Title = "Target Selection",
    Description = "Choose the mobs you want to farm manually.",
    Values = GetMobList(true),
    Multi = true,
    Default = {},
    Callback = function(value)
        Settings.SelectedMobs = value or {}
        State.Target = nil
    end
})

CombatTab:AddButton({
    Title = "Refresh Targets",
    Description = "Updates the mob list shown above.",
    Callback = function()
        local list = GetMobList(true)
        pcall(function()
            if TargetDropdown and TargetDropdown.SetValues then
                TargetDropdown:SetValues(list)
            end
        end)
        Notify("Refresh", "Mob list updated: " .. tostring(#list) .. " found.", 2)
    end
})

AutoFarmToggle = CombatTab:AddToggle("DYHUB_AutoFarm", {
    Title = "Auto Farm",
    Description = "Farms the mobs selected in the list above.",
    Default = false,
    Callback = function(v)
        Settings.AutoFarm = v
        State.Target = nil
        State.QuestGood = not Settings.AutoQuest

        if v then
            Settings.AutoFarmBeta = false
            State.BetaTargetLevel = nil
            pcall(function()
                if AutoFarmBetaToggle and AutoFarmBetaToggle.SetValue then
                    AutoFarmBetaToggle:SetValue(false)
                elseif AutoFarmBetaToggle and AutoFarmBetaToggle.Set then
                    AutoFarmBetaToggle:Set(false)
                end
            end)
        end
    end
})

CombatTab:AddToggle("DYHUB_AutoSkills", {
    Title = "Skill Combo",
    Description = "Uses your skills while farming.",
    Default = false,
    Callback = function(v)
        Settings.AutoSkills = v
    end
})

CombatTab:AddToggle("DYHUB_AutoAttack", {
    Title = "Auto Attack",
    Description = "Keeps using normal attacks automatically.",
    Default = false,
    Callback = function(v)
        Settings.AutoAttack = v
    end
})

CombatTab:AddToggle("DYHUB_KillAura", {
    Title = "Kill Aura",
    Description = "Attacks enemies near your character.",
    Default = false,
    Callback = function(v)
        Settings.KillAura = v
    end
})

CombatTab:AddSlider("DYHUB_KillAuraRange", {
    Title = "Attack Range",
    Default = 30,
    Min = 5,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        Settings.KillAuraRange = tonumber(v) or 30
    end
})

CombatTab:AddToggle("DYHUB_InfiniteParry", {
    Title = "Auto Parry (Boss only)",
    Description = "Blocks boss attacks when the warning appears.",
    Default = false,
    Callback = function(v)
        Settings.InfiniteParry = v
        State.ParryVFXObject = nil
    end
})

QuestTab:AddToggle("DYHUB_AutoQuest", {
    Title = "Quest Filter",
    Description = "Keeps quests that match your farming target.",
    Default = false,
    Callback = function(v)
        Settings.AutoQuest = v
        State.QuestGood = not v
        State.Target = nil
    end
})

QuestTab:AddSlider("DYHUB_MinRewardQuantity", {
    Title = "Minimum Reward",
    Description = "Skips quests with rewards lower than this number.",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(v)
        Settings.MinRewardQuantity = tonumber(v) or 2
    end
})

QuestTab:AddInput("DYHUB_BadRewardID", {
    Title = "Blocked Reward",
    Default = Settings.BadRewardID,
    Description = "Skips quests with this unwanted reward.",
    Placeholder = "Enter reward ID",
    Numeric = false,
    Finished = true,
    Callback = function(v)
        Settings.BadRewardID = tostring(v or "")
    end
})

QuestTab:AddParagraph({
    Title = "Boss Quest Support",
    Content = "Helps the quest system find the correct boss NPC.",
})

CollectTab:AddToggle("DYHUB_AutoChests", {
    Title = "Auto Open Chests",
    Description = "Opens nearby chests and reward boxes automatically.",
    Default = false,
    Callback = function(v)
        Settings.AutoChests = v
    end
})

CollectTab:AddToggle("DYHUB_CollectGubby", {
    Title = "Auto Collect Gubby",
    Description = "Collects Gubby items automatically.",
    Default = false,
    Callback = function(v)
        Settings.CollectGubby = v
    end
})

CollectTab:AddToggle("DYHUB_AutoEclipse", {
    Title = "Auto Collect Eclipse",
    Description = "Collects Eclipse items automatically.",
    Default = false,
    Callback = function(v)
        Settings.AutoEclipse = v
    end
})

local islands = {"Origin", "Helheim", "Muspelheim", "Niflheim", "Nidavellir", "Eclipse", "Jotunheim", "Sky Spire", "Explosion"}

for _, islandName in ipairs(islands) do
    TeleportTab:AddButton({
        Title = "Teleport: " .. islandName,
        Callback = function()
            local found = FindWorldTarget(islandName)
            if found then
                Notify("Teleport", "Teleported to " .. islandName .. ".", 2)
            else
                Notify("Teleport", islandName .. " was not found.", 3)
            end
        end
    })
end

TeleportTab:AddButton({
    Title = "Nearest Boss",
    Description = "Teleports to the nearest boss.",
    Callback = function()
        TeleportNearest(true)
    end
})

TeleportTab:AddButton({
    Title = "Nearest Mob",
    Description = "Teleports to the nearest mob.",
    Callback = function()
        TeleportNearest(false)
    end
})

TeleportTab:AddButton({
    Title = "Current Farm Target",
    Description = "Teleports to the mob currently being farmed.",
    Callback = function()
        local target = State.Target or SelectTarget(true)
        local cf = GetPivotCFrame(target)
        if cf then
            SafePivot(cf * CFrame.new(0, 3, 7))
            Notify("Teleport", "Teleported to target.", 2)
        else
            Notify("Teleport", "No current target.", 2)
        end
    end
})

PlayerTab:AddSlider("DYHUB_WalkSpeed", {
    Title = "Walk Speed",
    Description = "Changes your movement speed.",
    Default = 16,
    Min = 16,
    Max = 250,
    Rounding = 0,
    Callback = function(v)
        Settings.WalkSpeed = tonumber(v) or 16
    end
})

PlayerTab:AddSlider("DYHUB_JumpPower", {
    Title = "Jump Power",
    Description = "Changes your jump height.",
    Default = 50,
    Min = 50,
    Max = 250,
    Rounding = 0,
    Callback = function(v)
        Settings.JumpPower = tonumber(v) or 50
    end
})

PlayerTab:AddToggle("DYHUB_NoClip", {
    Title = "Noclip",
    Description = "Lets your character walk through objects.",
    Default = false,
    Callback = function(v)
        Settings.NoClip = v
    end
})

PlayerTab:AddToggle("DYHUB_InfJump", {
    Title = "Infinite Jump",
    Description = "Lets you jump again while in the air.",
    Default = false,
    Callback = function(v)
        Settings.InfJump = v
    end
})

PlayerTab:AddToggle("DYHUB_AntiAFK", {
    Title = "Anti AFK",
    Description = "Helps prevent being kicked while idle.",
    Default = true,
    Callback = function(v)
        Settings.AntiAFK = v
    end
})

PlayerTab:AddButton({
    Title = "Reset Character",
    Description = "Respawns your character instantly.",
    Callback = function()
        local hum = GetHumanoid()
        if hum then
            hum.Health = 0
        end
    end
})

PlayerTab:AddButton({
    Title = "Rejoin Server",
    Description = "Joins the same game again.",
    Callback = function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
})

ESPTab:AddToggle("DYHUB_PlayerESP", {
    Title = "Player ESP",
    Description = "Shows other players through walls.",
    Default = false,
    Callback = function(v)
        Settings.PlayerESP = v
        if not v then
            ClearESP()
        end
    end
})

ESPTab:AddToggle("DYHUB_MobESP", {
    Title = "Mob ESP",
    Description = "Shows normal mobs through walls.",
    Default = false,
    Callback = function(v)
        Settings.MobESP = v
        if not v then
            ClearESP()
        end
    end
})

ESPTab:AddToggle("DYHUB_BossESP", {
    Title = "Boss ESP",
    Description = "Shows bosses through walls.",
    Default = false,
    Callback = function(v)
        Settings.BossESP = v
        if not v then
            ClearESP()
        end
    end
})

ESPTab:AddToggle("DYHUB_ChestESP", {
    Title = "Chest ESP",
    Description = "Shows chests and rewards through walls.",
    Default = false,
    Callback = function(v)
        Settings.ChestESP = v
        if not v then
            ClearESP()
        end
    end
})

SettingsTab:AddButton({
    Title = "Optimize FPS",
    Description = "Improves FPS by lowering visual effects.",
    Callback = ApplyLowGraphics
})

SettingsTab:AddButton({
    Title = "Emergency Stop",
    Description = "Turns off every active feature at once.",
    Callback = StopAll
})

SettingsTab:AddButton({
    Title = "Refresh Mob List",
    Description = "Updates the saved mob list.",
    Callback = function()
        local list = GetMobList(true)
        Notify("Mob List", "Updated: " .. tostring(#list) .. " mobs found.", 2)
    end
})

SettingsTab:AddButton({
    Title = "Print Status",
    Description = "Shows the current script status in console.",
    Callback = function()
        print("========== DYHUB Broken Blade Status ==========")
        print("Version:", Hub.Version)
        print("Running:", Hub.Running)
        print("Status:", State.Status)
        print("Current Target:", State.Target and State.Target:GetFullName() or "nil")
        print("Enemies Cached:", #State.EnemyCache)
        print("Selected Mobs:")
        for k, v in pairs(Settings.SelectedMobs or {}) do
            print("  ", k, v)
        end
        print("==============================================")
        Notify("Status", State.Status, 3)
    end
})

SettingsTab:AddParagraph({
    Title = "Notice",
    Content = "Some risky features are not included to keep the script more stable.",
})

pcall(function()
    Window:SelectTab(1)
end)

local function GetToggleKey()
    local keyName = tostring(ENV.ToggleUI or "LeftControl")
    return Enum.KeyCode[keyName] or Enum.KeyCode.LeftControl
end

local function CreateMobileToggle()
    task.spawn(function()
        local success, errorMsg = pcall(function()
            local parentGui = (type(gethui) == "function" and gethui()) or CoreGui

            pcall(function()
                local old = parentGui:FindFirstChild("DYHUB_BrokenBlade_Toggle")
                if old then
                    old:Destroy()
                end
            end)

            if ENV.DYHUB_BrokenBladeOpenUI and ENV.DYHUB_BrokenBladeOpenUI.Parent then
                return
            end

            ENV.LoadedMobileUI = true

            local OpenUI = Instance.new("ScreenGui")
            OpenUI.Name = "DYHUB_BrokenBlade_OpenUI"
            OpenUI.ResetOnSpawn = false
            OpenUI.IgnoreGuiInset = true
            OpenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

            if syn and syn.protect_gui then
                pcall(function()
                    syn.protect_gui(OpenUI)
                end)
                OpenUI.Parent = CoreGui
            else
                OpenUI.Parent = parentGui
            end

            local ImageButton = Instance.new("ImageButton")
            ImageButton.Name = "ToggleLogo"
            ImageButton.Parent = OpenUI
            ImageButton.BackgroundColor3 = Color3.fromRGB(105, 105, 105)
            ImageButton.BackgroundTransparency = 0.8
            ImageButton.Position = UDim2.new(0.9, 0, 0.1, 0)
            ImageButton.Size = UDim2.new(0, 50, 0, 50)
            ImageButton.Image = tostring(ENV.Image or "rbxassetid://104487529937663")
            ImageButton.ImageTransparency = 0.2
            ImageButton.Active = true
            ImageButton.Draggable = true
            ImageButton.ClipsDescendants = true

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = ImageButton

            ENV.DYHUB_BrokenBladeOpenUI = OpenUI

            AddConnection(ImageButton.MouseButton1Click:Connect(function()
                local key = GetToggleKey()
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end)
            end))
        end)

        if not success then
            warn("[DYHUB] Failed to create mobile UI button: " .. tostring(errorMsg))
        end
    end)
end

CreateMobileToggle()

Notify("DYHUB", "Broken Blade loaded. Press the toggle key or tap the logo to open the menu.", 5)
