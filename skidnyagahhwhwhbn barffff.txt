--[[
    Focus:
      * WindUI only
      * single runtime kill-switch
      * lazy remotes / no blocking WaitForChild spam
      * central scheduler instead of creating duplicate loops from toggles
      * safer cache + delays to reduce first-run lag / crash
      * polished WindUI layout with descriptions on every control
      * fixed WindUI slider API and manual multi-code redeem button
]]

-- =========================
version = "Rework"
ver = "v032.50"
-- =========================

--// Runtime kill switch: prevents ghost loops when re-executing
local ENV = (getgenv and getgenv()) or _G
local RUNTIME_KEY = "BARF_BY_DYHUB"
if ENV[RUNTIME_KEY] and ENV[RUNTIME_KEY].Destroy then
    pcall(function() ENV[RUNTIME_KEY]:Destroy() end)
end

local Runtime = {
    Alive = true,
    Connections = {},
    LoopCount = 0,
    Cache = {},
    Started = os.clock(),
}
function Runtime:Destroy()
    self.Alive = false
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
    self.Connections = {}
end
ENV[RUNTIME_KEY] = Runtime

local function alive()
    return Runtime.Alive == true and ENV[RUNTIME_KEY] == Runtime
end

local function keepConnection(c)
    if c then table.insert(Runtime.Connections, c) end
    return c
end

local function log(...)
    print("[DYHUB]", ...)
end

local function warnLog(...)
    warn("[DYHUB]", ...)
end

local function safeTask(name, fn)
    local ok, err = pcall(fn)
    if not ok then warnLog(name, err) end
    return ok
end

local function spawnLoop(name, interval, fn, startDelay)
    Runtime.LoopCount += 1
    task.spawn(function()
        task.wait(startDelay or 0.75)
        while alive() do
            local started = os.clock()
            safeTask(name, fn)
            local spent = os.clock() - started
            task.wait(math.max(interval or 1, 0.05) + math.min(spent * 0.25, 0.5))
        end
    end)
end

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)

--// No hard wait for remotes on first run. Everything is lazy-cached.
local RemoteCache = {}
local function remotesFolder()
    return ReplicatedStorage:FindFirstChild("Remotes")
end

local function getRemote(...)
    local names = {...}
    local key = table.concat(names, "/")
    local cached = RemoteCache[key]
    if cached and cached.Parent then return cached end

    local obj = remotesFolder()
    for _, name in ipairs(names) do
        if not obj then break end
        obj = obj:FindFirstChild(name)
    end

    RemoteCache[key] = obj
    return obj
end

local function fire(remote, ...)
    if not remote then return false end
    local args = {...}
    local ok = pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(args))
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(unpack(args))
        end
    end)
    return ok
end

local function invoke(remote, ...)
    if not remote then return nil end
    local args = {...}
    local ok, result = pcall(function()
        if remote:IsA("RemoteFunction") then
            return remote:InvokeServer(unpack(args))
        elseif remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(args))
            return true
        end
    end)
    if ok then return result end
    return nil
end

local function notify(title, content, duration, icon)
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = tostring(title or "DYHUB"),
                Content = tostring(content or ""),
                Duration = duration or 2.5,
                Icon = icon or "bell"
            })
        else
            log(title, content)
        end
    end)
end

--// Config
local CONFIG_FILE = "BARF_config.json"
local Config = {
    MasterFarm = false,

    AutoPlant = false,
    PlantMode = "Best Value",
    SelectedSeed = "Carrot",
    PlantDelay = 0.35,
    AutoUpgradePlants = false,
    AutoUnlockFarmPlots = false,
    AutoSellCrates = false,

    AutoCompost = false,
    AutoCompostAllSeeds = false,
    AutoPullComposterLever = false,
    TargetCompostSeeds = {},
    TargetCompostMutations = {},
    CompostFloor = 2,
    MaxCompostInsertAmount = 0,
    PullLeverDelay = 2,

    AutoRollSeeds = false,
    RollDelay = 2.5,
    AutoBuyAllRolledSeeds = false,
    AutoBuySelectedRolledSeeds = false,
    AutoBuyByRarity = false,
    AutoBuyAnyTranscended = false,
    TargetSeeds = {},
    TargetRarities = {},
    AutoOpenSeedPacks = false,

    AutoUpgradeFarm = false,
    AutoUpgradeSeedLuck = false,
    AutoUpgradeSeedRolls = false,
    AutoUpgradePlot = false,
    PlotUpgradeFloor = "All Floors",
    PlotUpgradePriority = "Yield > Soil > Power > Sprinkler > Saw",
    TargetPlotUpgrades = {},

    AutoFertilize = false,
    TargetFertilizePlants = {},
    TargetFertilizeMutations = {},
    TargetFertilizerTypes = {},

    AutoBuyAllGears = false,
    AutoBuySelectedGears = false,
    TargetGears = {},

    AutoUnlockEggSlots = false,
    AutoBuyAllEggs = false,
    AutoBuySelectedEggs = false,
    TargetEggs = {},
    AutoHatchEggs = false,
    HatchAllPodiums = false,
    SelectedEggPodium = 1,

    AutoUpgradePets = false,
    AutoSellPets = false,

    AutoPlantRush = false,
    AutoClaimPlantRushDrops = false,
    AutoCollectHoneycombs = false,
    AutoSubmitHoneyToken = false,
    AutoCollectAlienDrops = false,
    AutoSubmitSeedsToCollector = false,
    AutoSubmitAllSeedsToCollector = false,
    TargetCollectorSeeds = {},

    AutoDailyRewards = false,
    AutoPlaytimeRewards = false,
    AutoGroupReward = false,
    AutoRedeemCodes = false, -- legacy config key; UI now uses a manual Redeem Code button
    Codes = "", -- legacy custom-code field kept for config compatibility
    SelectedRedeemCodes = {},

    AntiAFK = true,
    BlockRobuxPopups = true,
    SkipMoneyCheck = false,
    InfiniteJump = false,
    NoClip = false,
    AutoReconnect = false,
    LowGraphics = false,
}

local saveQueued = false
local function saveConfigNow()
    if type(writefile) ~= "function" then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
    end)
end

local function queueSave()
    if saveQueued then return end
    saveQueued = true
    task.delay(0.75, function()
        saveQueued = false
        saveConfigNow()
    end)
end

local function loadConfig()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
    pcall(function()
        if isfile(CONFIG_FILE) then
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    Config[k] = v
                end
            end
        end
    end)
end
loadConfig()

local function setConfig(key, value)
    Config[key] = value
    queueSave()
end

local function isSelected(list, value)
    if not list then return false end
    value = tostring(value or "")
    for k, v in pairs(list) do
        if tostring(k) == value and v == true then return true end
        if tostring(v) == value then return true end
    end
    return false
end

local function tableKeysFromArray(arr)
    local out = {}
    if type(arr) == "table" then
        for _, v in pairs(arr) do
            out[tostring(v)] = true
        end
    end
    return out
end

local function normalizeName(s)
    s = tostring(s or "")
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    s = s:gsub("%s+Seed$", "")
    return s
end

--// Economy helpers
local MoneySuffixes = {
    K = 1e3, M = 1e6, B = 1e9, T = 1e12,
    QA = 1e15, QD = 1e15, QI = 1e18, QN = 1e18,
    SX = 1e21, SP = 1e24, OC = 1e27, O = 1e27,
    NO = 1e30, N = 1e30, DE = 1e33, D = 1e33,
    UN = 1e36, UD = 1e36, DD = 1e39, TD = 1e42,
    QAD = 1e45, QID = 1e48, SXD = 1e51, SPD = 1e54,
    OCD = 1e57, NOD = 1e60, VG = 1e63,
}

local function parseMoney(value)
    if type(value) == "number" then return value end
    if type(value) ~= "string" then return 0 end
    local clean = value:upper():gsub("[$,%s]", "")
    local num, suffix = clean:match("^([%d%.]+)(%a*)$")
    if not num then return 0 end
    return (tonumber(num) or 0) * (MoneySuffixes[suffix] or 1)
end

local function getPlayerCash()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Leaderstats")
    if leaderstats then
        local cashObj = leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Coins")
        if cashObj then return parseMoney(cashObj.Value) end
    end
    local mainUI = PlayerGui and PlayerGui:FindFirstChild("MainUI")
    local moneyCounter = mainUI and mainUI:FindFirstChild("MoneyCounter")
    local cashCounter = moneyCounter and moneyCounter:FindFirstChild("CashCounter")
    if cashCounter and cashCounter.Text then return parseMoney(cashCounter.Text) end
    return 0
end

local function canAfford(cost)
    if Config.SkipMoneyCheck then return true end
    if not cost or cost <= 0 then return true end
    return getPlayerCash() >= cost
end

--// Static data merged from Auto Roll Source
local RARITY_ORDER = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Divine", "Prismatic", "Secret", "Exotic", "Transcended"}
local RARITY_ORDER_HIGH = {"Transcended","Exotic","Divine","Prismatic","Secret","Legendary","Epic","Rare","Uncommon","Common"}
local FertilizerTypes = {"Normal Fertilizer","Strong Fertilizer","Super Fertilizer","Prismatic Fertilizer"}

local SeedDatabase = {
    -- COMMON (weights ~75-100)
    {name="Carrot",             rarity="Common",      cost=100,              income=3,       chance="Common"},
    {name="Beetroot",           rarity="Common",      cost=250,              income=5,       chance="Common"},
    {name="Pumpkin",            rarity="Common",      cost=500,              income=8,       chance="Common"},
    {name="Cinnamon",           rarity="Common",      cost=nil,              income=nil,     chance="?"},

    -- UNCOMMON
    {name="Wheat",              rarity="Uncommon",    cost=600,              income=12,      chance="Uncommon"},
    {name="Melon",              rarity="Uncommon",    cost=1200,             income=18,      chance="Uncommon"},
    {name="Onion",              rarity="Uncommon",    cost=2500,             income=20,      chance="Uncommon"},
    {name="Cantaloupe",         rarity="Uncommon",    cost=3500,             income=25,      chance="Uncommon"},
    {name="Watermelon",         rarity="Uncommon",    cost=5000,             income=30,      chance="Uncommon"},
    {name="Promise Lily",       rarity="Uncommon",    cost=nil,              income=22,      chance="Friend-o-Tron"},
    {name="Twinflame Tulip",    rarity="Uncommon",    cost=520000,           income=450,     chance="Not rollable"},

    -- RARE
    {name="Blueberry",          rarity="Rare",        cost=15000,            income=50,      chance="Rare"},
    {name="Cabbage",            rarity="Rare",        cost=40000,            income=85,      chance="Rare"},
    {name="Grape",              rarity="Rare",        cost=65000,            income=120,     chance="Rare"},
    {name="Peach",              rarity="Rare",        cost=120000,           income=180,     chance="Rare"},
    {name="Bamboo",             rarity="Rare",        cost=90000,            income=160,     chance="Rare"},

    -- EPIC
    {name="Corn",               rarity="Epic",        cost=200000,           income=250,     chance="Epic"},
    {name="Plum",               rarity="Epic",        cost=300000,           income=300,     chance="Epic"},
    {name="Cauliflower",        rarity="Epic",        cost=500000,           income=400,     chance="Epic"},
    {name="Nectarine",          rarity="Epic",        cost=600000,           income=480,     chance="Epic"},
    {name="Sunflower",          rarity="Epic",        cost=650000,           income=550,     chance="Epic"},
    {name="Citrus",             rarity="Epic",        cost=850000,           income=700,     chance="Epic"},
    {name="Twinflame Tulip",    rarity="Epic",        cost=520000,           income=450,     chance="Not rollable"},
    {name="Honeysuckle",        rarity="Epic",        cost=615000,           income=500,     chance="Bee Event"},
    {name="Martian Melon",      rarity="Epic",        cost=700000,           income=620,     chance="Alien Event"},
    {name="Admin Sunflower",    rarity="Epic",        cost=865000,           income=725,     chance="Admin"},

    -- LEGENDARY
    {name="Spring Onion",       rarity="Legendary",   cost=2500000,          income=1200,    chance="Legendary"},
    {name="Mango",              rarity="Legendary",   cost=4000000,          income=1600,    chance="Legendary"},
    {name="Mushroom",           rarity="Legendary",   cost=7000000,          income=2000,    chance="Legendary"},
    {name="Banana",             rarity="Legendary",   cost=9000000,          income=2500,    chance="Legendary"},
    {name="Potato",             rarity="Legendary",   cost=15000000,         income=2700,    chance="Legendary"},
    {name="Amulet Anemone",     rarity="Legendary",   cost=nil,              income=1800,    chance="Friend-o-Tron"},

    -- SECRET
    {name="Strawberry",         rarity="Secret",      cost=30000000,         income=6000,    chance="Secret"},
    {name="Glowshroom",         rarity="Secret",      cost=45000000,         income=8000,    chance="Secret"},
    {name="Beanstalk",          rarity="Secret",      cost=55000000,         income=8000,    chance="Secret"},
    {name="Tomato",             rarity="Secret",      cost=100000000,        income=12000,   chance="Secret"},
    {name="Monsoon Crown",      rarity="Secret",      cost=65000000,         income=6500,    chance="Rain Event"},
    {name="Starfruit",          rarity="Secret",      cost=130000000,        income=13000,   chance="Not rollable"},
    {name="Mooncap",            rarity="Secret",      cost=nil,              income=nil,     chance="?"},

    -- PRISMATIC
    {name="Apple",              rarity="Prismatic",   cost=500000000,        income=20000,   chance="Prismatic"},
    {name="Cherry Blossom",     rarity="Prismatic",   cost=1500000000,       income=30000,   chance="Prismatic"},
    {name="Blood Orange",       rarity="Prismatic",   cost=1200000000,       income=35000,   chance="Prismatic"},
    {name="Garlic",             rarity="Prismatic",   cost=5500000000,       income=50000,   chance="Prismatic"},
    {name="Iron Fern",          rarity="Prismatic",   cost=4000000000,       income=42500,   chance="Prismatic"},
    {name="Frostbell",          rarity="Prismatic",   cost=1750000000,       income=32000,   chance="Blizzard Event"},
    {name="Hex Sprout",         rarity="Prismatic",   cost=7500000000,       income=55000,   chance="Not rollable"},
    {name="Pineapple",          rarity="Prismatic",   cost=800000000,        income=40000,   chance="Seed Pack"},
    {name="Rush Root",          rarity="Prismatic",   cost=850000000,        income=45000,   chance="Plant Rush"},
    {name="Galaxy Hibiscus",    rarity="Prismatic",   cost=1550000000,       income=32000,   chance="Alien Event"},
    {name="Duoheart Daisy",     rarity="Prismatic",   cost=nil,              income=nil,     chance="?"},
    {name="Crimson Higanbana",  rarity="Prismatic",   cost=35000000000000,   income=225000,  chance="Not rollable"},
    {name="Glasswing",          rarity="Prismatic",   cost=nil,              income=nil,     chance="?"},

    -- DIVINE
    {name="Golden Apple",       rarity="Divine",      cost=5000000000,       income=65000,   chance="Divine"},
    {name="Cocoa",              rarity="Divine",      cost=10000000000,      income=70000,   chance="Divine"},
    {name="Crystalberry",       rarity="Divine",      cost=20000000000,      income=88000,   chance="Divine"},
    {name="Amber Wisp",         rarity="Divine",      cost=12500000000,      income=72000,   chance="Fall Event"},
    {name="Admin Bloom",        rarity="Divine",      cost=25000000000,      income=85000,   chance="Admin"},
    {name="Diamond Blossom",    rarity="Divine",      cost=2500000000,       income=55000,   chance="Seed Collector"},
    {name="Dreadcap",           rarity="Divine",      cost=25000000000,      income=95000,   chance="Not rollable"},
    {name="Compost Hydra",      rarity="Divine",      cost=115000000000,     income=125000,  chance="Composter"},
    {name="Horned Melon",       rarity="Divine",      cost=3500000000,       income=80000,   chance="Trucker"},
    {name="Pomegranate",        rarity="Divine",      cost=4000000000,       income=75000,   chance="Seed Pack"},

    -- EXOTIC
    {name="Moonflower",         rarity="Exotic",      cost=70000000000,      income=110000,  chance="Exotic"},
    {name="Passionfruit",       rarity="Exotic",      cost=100000000000,     income=120000,  chance="Exotic"},
    {name="Darkmatter Bramble", rarity="Exotic",      cost=1000000000000,    income=145000,  chance="Blackhole Event"},
    {name="Uranium Reed",       rarity="Exotic",      cost=10000000000000,   income=165000,  chance="Nuclear Event"},
    {name="Muckthorn",          rarity="Exotic",      cost=1500000000000,    income=170000,  chance="Not rollable"},
    {name="Crowned Pear",       rarity="Exotic",      cost=125000000000,     income=135000,  chance="Not rollable"},
    {name="Striped Starfruit",  rarity="Exotic",      cost=120000000000,     income=130000,  chance="Not rollable"},
    {name="Crimson Higanbana",  rarity="Exotic",      cost=35000000000000,   income=225000,  chance="Not rollable"},
    {name="Pepper",             rarity="Exotic",      cost=900000000000,     income=140000,  chance="Exotic"},
    {name="Void Fruit",         rarity="Exotic",      cost=15000000000000,   income=180000,  chance="Exotic"},
    {name="Kiwi",               rarity="Exotic",      cost=60000000000,      income=90000,   chance="Not rollable"},
    {name="Dragonfruit",        rarity="Exotic",      cost=8000000000,       income=350000,  chance="Seed Pack"},
    {name="Truckers Delight",   rarity="Exotic",      cost=nil,              income=160000,  chance="Trucker Event"},
    {name="Heartvine Bloom",    rarity="Exotic",      cost=nil,              income=nil,     chance="Friend-o-Tron"},

    -- TRANSCENDED
    {name="Durian",             rarity="Transcended", cost=100000000000000,  income=380000,  chance="Transcended"},
    {name="Ghost Pepper",       rarity="Transcended", cost=275000000000000,  income=500000,  chance="Transcended"},
    {name="Papaya",             rarity="Transcended", cost=150000000000000,  income=450000,  chance="Transcended"},
    {name="Ember Fruit",        rarity="Transcended", cost=350000000000000,  income=525000,  chance="Transcended"},
    {name="Admin Rose",         rarity="Transcended", cost=375000000000000,  income=575000,  chance="Admin"},
    {name="Soulbound Orchid",   rarity="Transcended", cost=275000000000000,  income=500000,  chance="Friend Machine"},
    {name="Muck Monarch",       rarity="Transcended", cost=200000000000000,  income=525000,  chance="Not rollable"},
    {name="Heart of Corruption",rarity="Transcended", cost=350000000000000,  income=600000,  chance="Not rollable"},
    {name="Garden Golem",       rarity="Transcended", cost=425000000000000,  income=565000,  chance="Plant Rush"},
    {name="Golden Quillflower", rarity="Transcended", cost=125000000000000,  income=425000,  chance="Not rollable"},
    {name="Aurora Lotus",       rarity="Transcended", cost=750000000000000,  income=750000,  chance="Transcended"},
    {name="Queens Blossom",     rarity="Transcended", cost=nil,              income=nil,     chance="Bee Event"},
    {name="Witherfang",         rarity="Transcended", cost=nil,              income=nil,     chance="?"},
    {name="Garden Devourer",    rarity="Transcended", cost=nil,              income=nil,     chance="Composter"},
}
local SeedByName = {}
for _,s in ipairs(SeedDatabase) do SeedByName[s.name]=s end

local GearItems = {
    {name="Fire Spray",           cost=1000000000000000, maxStock=1},
    {name="Bubblegum Spray",      cost=250000000000000,  maxStock=1},
    {name="Cosmic Spray",         cost=25000000000000,   maxStock=1},
    {name="Prismatic Fertilizer", cost=25000000000000,   maxStock=1},
    {name="Rainbow Spray",        cost=1000000000000,    maxStock=1},
    {name="Radioactive Spray",    cost=100000000000,     maxStock=1},
    {name="Super Pet Treat",      cost=20000000000,      maxStock=1},
    {name="Super Fertilizer",     cost=15000000000,      maxStock=1},
    {name="Void Spray",           cost=10000000000,      maxStock=1},
    {name="Autumn Spray",         cost=1000000000,       maxStock=1},
    {name="Frozen Spray",         cost=750000000,        maxStock=2},
    {name="Strong Pet Treat",     cost=75000000,         maxStock=1},
    {name="Strong Fertilizer",    cost=50000000,         maxStock=2},
    {name="Wet Spray",            cost=10000000,         maxStock=2},
    {name="Acid Spray",           cost=1000000,          maxStock=3},
    {name="Normal Pet Treat",     cost=1000000,          maxStock=2},
    {name="Normal Fertilizer",    cost=500000,           maxStock=3},
}

local function seedNames()
    local names = {}
    for _, s in ipairs(SeedDatabase) do
        if s.name and not isSelected(names, s.name) then table.insert(names, s.name) end
    end
    table.sort(names)
    return names
end

local function gearNames()
    local names = {}
    for _, g in ipairs(GearItems) do
        table.insert(names, g.name)
    end
    table.sort(names)
    return names
end

local function getMutationList()
    local list, seen = {"Normal"}, {Normal = true}
    local shared = ReplicatedStorage:FindFirstChild("Shared")
    local muts = shared and shared:FindFirstChild("MutationAppliers")
    if muts then
        for _, obj in ipairs(muts:GetChildren()) do
            if obj.Name and obj.Name ~= "" and not seen[obj.Name] then
                seen[obj.Name] = true
                table.insert(list, obj.Name)
            end
        end
    end
    local fallback = {"Alien","Autumn","Cosmic","Farm","Frozen","Honeycomb","Radioactive","Rainbow","Void","Wet"}
    for _, name in ipairs(fallback) do
        if not seen[name] then table.insert(list, name) end
    end
    table.sort(list, function(a, b)
        if a == "Normal" then return true end
        if b == "Normal" then return false end
        return a < b
    end)
    return list
end

--// Lazy DataReplicator
local Replicator
task.defer(function()
    task.wait(1.5)
    pcall(function()
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        local module = packages and packages:FindFirstChild("DataReplicator")
        if module then
            local DataReplicator = require(module)
            Replicator = DataReplicator.GetReplicator()
        end
    end)
end)

local function snapshot()
    if not Replicator then return nil end
    local ok, data = pcall(function() return Replicator:Snapshot() end)
    return ok and data or nil
end

--// Character helpers
local function getCharacter()
    return LocalPlayer.Character
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function teleportTo(cf)
    local root = getRoot()
    if not root then return false end
    pcall(function()
        root.CFrame = cf
    end)
    return true
end

--// Plot / farm cache
local plotCache, plotCacheTime = nil, 0
local function findMyPlot(force)
    if plotCache and plotCache.Parent and not force and os.clock() - plotCacheTime < 8 then
        return plotCache
    end

    local plotRemote = getRemote("Plot", "GetPlot")
    local result = invoke(plotRemote)
    if typeof(result) == "Instance" then
        plotCache, plotCacheTime = result, os.clock()
        return result
    end

    local map = workspace:FindFirstChild("Map")
    local plots = map and map:FindFirstChild("Plots") or workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local owner = plot:FindFirstChild("Owner")
            local ownerValue = owner and owner.Value
            local attrOwner = plot:GetAttribute("Owner") or plot:GetAttribute("OwnerName") or plot:GetAttribute("UserId")
            if ownerValue == LocalPlayer or ownerValue == LocalPlayer.Name or attrOwner == LocalPlayer.Name or attrOwner == LocalPlayer.UserId then
                plotCache, plotCacheTime = plot, os.clock()
                return plot
            end
        end
    end

    return plotCache
end

local dirtCache, dirtCacheTime = {}, 0
local function getDirtPlots(opts)
    opts = opts or {}
    local plot = findMyPlot()
    local now = os.clock()
    if not plot then return {} end

    if dirtCache[plot] and now - dirtCacheTime < 2 then
        -- use cached full list, filter below
    else
        local list = {}
        for _, inst in ipairs(plot:GetDescendants()) do
            if inst:IsA("BasePart") and inst.Name == "Dirt" then
                table.insert(list, inst)
                if #list % 60 == 0 then task.wait() end
            end
        end
        dirtCache = {[plot] = list}
        dirtCacheTime = now
    end

    local out = {}
    for _, dirt in ipairs(dirtCache[plot] or {}) do
        local parent = dirt.Parent
        local unlocked = parent and parent:GetAttribute("Unlocked")
        local plantName = dirt:GetAttribute("PlantName") or (parent and parent:GetAttribute("PlantName"))
        if opts.empty and plantName then continue end
        if opts.planted and not plantName then continue end
        if opts.locked and unlocked ~= false then continue end
        if not opts.locked and unlocked == false then continue end
        table.insert(out, dirt)
    end
    return out
end

local function nearest(list)
    local root = getRoot()
    if not root then return list and list[1] end
    table.sort(list, function(a, b)
        return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
    end)
    return list[1]
end

local function getSeedTools()
    local list = {}
    local function scan(container)
        if not container then return end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool:GetAttribute("trueName") or tool:GetAttribute("Plant") or tool:GetAttribute("Seed") or normalizeName(tool.Name)
                if n and n ~= "" then
                    table.insert(list, {tool = tool, plant = normalizeName(n)})
                end
            end
        end
    end
    scan(LocalPlayer:FindFirstChildOfClass("Backpack"))
    scan(LocalPlayer.Character)
    return list
end

local function chooseSeedTool()
    local tools = getSeedTools()
    if #tools == 0 then return nil end

    if Config.PlantMode == "Selected Seed" then
        for _, e in ipairs(tools) do
            if e.plant == Config.SelectedSeed then return e.tool, e.plant end
        end
    end

    table.sort(tools, function(a, b)
        local da = SeedByName[a.plant] or {}
        local db = SeedByName[b.plant] or {}
        if Config.PlantMode == "Fastest Grow" then
            local ga = tonumber(a.tool:GetAttribute("StageGrowTime") or 999)
            local gb = tonumber(b.tool:GetAttribute("StageGrowTime") or 999)
            return ga < gb
        elseif Config.PlantMode == "Best ROI" then
            local ia = tonumber(da.income or a.tool:GetAttribute("Income") or 0)
            local ib = tonumber(db.income or b.tool:GetAttribute("Income") or 0)
            local ca = tonumber(da.cost or a.tool:GetAttribute("Cost") or 1)
            local cb = tonumber(db.cost or b.tool:GetAttribute("Cost") or 1)
            return (ia / math.max(1, ca)) > (ib / math.max(1, cb))
        elseif Config.PlantMode == "Rarest Owned" then
            local rank = {}
            for i, r in ipairs(RARITY_ORDER_HIGH) do rank[r] = i end
            return (rank[da.rarity] or 999) < (rank[db.rarity] or 999)
        else
            local va = tonumber(da.cost or a.tool:GetAttribute("Price") or a.tool:GetAttribute("Cost") or 0)
            local vb = tonumber(db.cost or b.tool:GetAttribute("Price") or b.tool:GetAttribute("Cost") or 0)
            return va > vb
        end
    end)

    return tools[1].tool, tools[1].plant
end

--// Core farm functions
local function plantOnce()
    local dirt = nearest(getDirtPlots({empty = true}))
    if not dirt then return false end
    local tool = chooseSeedTool()
    if not tool then return false end

    local hum = getHumanoid()
    pcall(function()
        if hum then hum:EquipTool(tool) end
    end)
    task.wait(0.05)
    return fire(getRemote("PlantSeed"), dirt)
end

local function upgradePlantsOnce()
    local remote = getRemote("UpgradePlant")
    if not remote then return end
    local count = 0
    for _, dirt in ipairs(getDirtPlots({planted = true})) do
        fire(remote, dirt)
        count += 1
        if count % 10 == 0 then task.wait(0.05) else task.wait(0.02) end
    end
end

local function unlockPlotsOnce()
    local remote = getRemote("UnlockPlot")
    if not remote then return end
    local count = 0
    for _, dirt in ipairs(getDirtPlots({locked = true})) do
        fire(remote, dirt)
        count += 1
        if count % 8 == 0 then task.wait(0.1) else task.wait(0.03) end
    end
end

local function sellCratesOnce()
    fire(getRemote("SellCrates"))
end

--// Composter
local function getSeedQuantity(tool)
    local qty = tostring(tool and tool.Name or ""):match("%(x(%d+)%)")
    return tonumber(qty) or 1
end

local function clampInsertAmount(available)
    local max = tonumber(Config.MaxCompostInsertAmount) or 0
    if max > 0 then return math.min(available, max) end
    return available
end

local function findCompostSeed()
    local function scan(parent)
        if not parent then return nil end
        for _, tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") then
                local isSeed = tool:GetAttribute("InventoryCategory") == "Seeds" or tool.Name:lower():find("seed")
                if isSeed then
                    local plant = normalizeName(tool:GetAttribute("Plant") or tool:GetAttribute("trueName") or tool.Name)
                    local mutation = tool:GetAttribute("Mutation") or "Normal"
                    if Config.AutoCompostAllSeeds
                        or ((not next(Config.TargetCompostSeeds or {}) or isSelected(Config.TargetCompostSeeds, plant))
                        and (not next(Config.TargetCompostMutations or {}) or isSelected(Config.TargetCompostMutations, mutation))) then
                        return tool
                    end
                end
            end
        end
    end
    return scan(LocalPlayer:FindFirstChildOfClass("Backpack")) or scan(LocalPlayer.Character)
end

local function compostOnce()
    local seed = findCompostSeed()
    if not seed then return false end
    local remote = getRemote("Composter", "InsertSeed")
    if not remote then return false end
    local qty = clampInsertAmount(getSeedQuantity(seed))
    qty = math.clamp(qty, 1, 50)
    for i = 1, qty do
        fire(remote, seed, tonumber(Config.CompostFloor) or 2)
        task.wait(0.08)
    end
    return true
end

local function pullComposterLeverOnce()
    fire(getRemote("Composter", "PullLever"), tonumber(Config.CompostFloor) or 2)
end

--// Upgrades
local PlotUpgradeOrders = {
    ["Yield > Soil > Power > Sprinkler > Saw"] = {"ExtraYield", "SoilQuality", "ExtraPower", "ExtraSprinklerRange", "ExtraSawRange"},
    ["Soil > Yield > Power"] = {"SoilQuality", "ExtraYield", "ExtraPower", "ExtraSprinklerRange", "ExtraSawRange"},
    ["Sprinkler > Power > Yield"] = {"ExtraSprinklerRange", "ExtraPower", "ExtraYield", "SoilQuality", "ExtraSawRange"},
    ["Saw > Yield > Soil"] = {"ExtraSawRange", "ExtraYield", "SoilQuality", "ExtraSprinklerRange", "ExtraPower"},
}

local PlotUpgradeLabels = {
    ["Yield"] = "ExtraYield",
    ["Soil"] = "SoilQuality",
    ["Power"] = "ExtraPower",
    ["Sprinkler Range"] = "ExtraSprinklerRange",
    ["Saw Range"] = "ExtraSawRange",
}

local function selectedPlotOrder()
    local out = {}
    for label, remoteArg in pairs(PlotUpgradeLabels) do
        if isSelected(Config.TargetPlotUpgrades, label) then
            table.insert(out, remoteArg)
        end
    end
    if #out > 0 then return out end
    return PlotUpgradeOrders[Config.PlotUpgradePriority] or PlotUpgradeOrders["Yield > Soil > Power > Sprinkler > Saw"]
end

local function plotUpgradeOnce()
    local remote = getRemote("PlotUpgradeTransaction")
    if not remote then return end
    local floors = {}
    if Config.PlotUpgradeFloor == "All Floors" then
        floors = {"Floor1", "Floor2", "Floor3", "Floor4", "Floor5", "Floor6"}
    else
        floors = {Config.PlotUpgradeFloor}
    end
    for _, floor in ipairs(floors) do
        for _, upgrade in ipairs(selectedPlotOrder()) do
            invoke(remote, upgrade, floor)
            task.wait(0.06)
        end
    end
end

local function upgradeFarmOnce()
    invoke(getRemote("UpgradeFarm"))
end

local function upgradeSeedLuckOnce()
    invoke(getRemote("UpgradeSeedLuck"))
end

local function upgradeSeedRollsOnce()
    invoke(getRemote("UpgradeSeedRolls"))
end

--// Seed roller systems
local lastRolledNames = {}
local buyLock = false

local function shouldBuySeed(seedName)
    seedName = normalizeName(seedName)
    local seed = SeedByName[seedName]
    if Config.AutoBuyAllRolledSeeds then return true end
    if Config.AutoBuyAnyTranscended and seed and seed.rarity == "Transcended" then return true end
    if Config.AutoBuySelectedRolledSeeds and isSelected(Config.TargetSeeds, seedName) then return true end
    if Config.AutoBuyByRarity and seed and isSelected(Config.TargetRarities, seed.rarity) then return true end
    return false
end

local function buyRolledSlot(slot, seedName)
    local seed = seedName and SeedByName[normalizeName(seedName)]
    if seed and seed.cost and not canAfford(seed.cost) then return false end
    return fire(getRemote("BuySeed"), slot)
end

local function getSeedRollStands()
    local stands = {}
    local plot = findMyPlot()
    if not plot then return stands end
    local roller = plot:FindFirstChild("SeedRoller")
    if not roller then return stands end
    for i = 1, 6 do
        local stand = roller:FindFirstChild("Stand" .. i)
        if stand then
            local ok, cf = pcall(function() return stand:GetPivot() end)
            if ok and cf then stands[i] = cf.Position end
        end
    end
    return stands
end

local function getAvailableRolledSeeds()
    local stands = getSeedRollStands()
    local availableSeeds = {}
    if next(stands) == nil then return availableSeeds end

    local scanned = 0
    for _, model in ipairs(workspace:GetChildren()) do
        if scanned >= 250 then break end
        scanned += 1
        if model:IsA("Model") and model:FindFirstChild("BuySeed", true) then
            local ok, pivot = pcall(function() return model:GetPivot() end)
            if ok and pivot then
                local modelPos = pivot.Position
                local nearestStand, minDist = nil, math.huge
                for idx, pos in pairs(stands) do
                    local dist = (Vector3.new(modelPos.X, 0, modelPos.Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearestStand = idx
                    end
                end
                if nearestStand and minDist < 15 then
                    local price = 0
                    local seedGui = model:FindFirstChild("SeedGui", true)
                    if seedGui then
                        for _, desc in ipairs(seedGui:GetDescendants()) do
                            if desc:IsA("TextLabel") and desc.Text and string.find(desc.Text, "$", 1, true) then
                                price = parseMoney(desc.Text)
                                break
                            end
                        end
                    end
                    availableSeeds[model.Name] = {
                        standIdx = nearestStand,
                        price = price,
                        rarity = (SeedByName[normalizeName(model.Name)] and SeedByName[normalizeName(model.Name)].rarity) or "Common",
                    }
                end
            end
        end
    end
    return availableSeeds
end

local function pollAndBuyRolledSeeds()
    if buyLock then return false end
    if not (Config.AutoBuyAllRolledSeeds or Config.AutoBuySelectedRolledSeeds or Config.AutoBuyByRarity or Config.AutoBuyAnyTranscended) then return false end

    local available = getAvailableRolledSeeds()
    local boughtAny = false
    for seedName, info in pairs(available) do
        if shouldBuySeed(seedName) and canAfford(info.price or 0) then
            boughtAny = buyRolledSlot(info.standIdx, seedName) or boughtAny
            if boughtAny then notify("Seed Purchased", tostring(seedName), 1.4, "sprout") end
            task.wait(0.45)
        end
    end
    return boughtAny
end

local function handleRolledSeeds(rolledSeeds)
    if buyLock then return end
    if not (Config.AutoBuyAllRolledSeeds or Config.AutoBuySelectedRolledSeeds or Config.AutoBuyByRarity or Config.AutoBuyAnyTranscended) then return end
    if type(rolledSeeds) ~= "table" then return end

    local queue = {}
    for slot, seedName in ipairs(rolledSeeds) do
        if type(seedName) == "string" and shouldBuySeed(seedName) then
            table.insert(queue, {slot = slot, name = seedName})
        end
    end

    if #queue == 0 then return end
    buyLock = true
    task.spawn(function()
        task.wait(0.15)
        for _, entry in ipairs(queue) do
            if not alive() then break end
            buyRolledSlot(entry.slot, entry.name)
            notify("Seed Purchased", tostring(entry.name), 1.6, "sprout")
            task.wait(0.45)
        end
        task.wait(0.25)
        buyLock = false
    end)
end

local function connectRollEvent()
    local r = getRemote("RollSeeds")
    if r and r:IsA("RemoteEvent") and not Runtime.RollConnection then
        Runtime.RollConnection = keepConnection(r.OnClientEvent:Connect(function(rolled)
            lastRolledNames = type(rolled) == "table" and rolled or lastRolledNames
            handleRolledSeeds(rolled)
        end))
    end
end

local function rollSeedsOnce()
    connectRollEvent()
    fire(getRemote("RollSeeds"))
end

local function openSeedPackOnce()
    fire(getRemote("RequestOpenSeedPack"))
    task.wait(0.2)
    fire(getRemote("OpenSeedPack"))
    task.wait(0.2)
    fire(getRemote("SeedPackOpenFinished"))
end

--// Poll fallback if server does not fire rolled table
local function buyAllSlotsOnce()
    for slot = 1, 6 do
        buyRolledSlot(slot)
        task.wait(0.08)
    end
end

--// Gear / Egg helpers
local function getGearStockFromGui(name)
    local mainUI = PlayerGui and PlayerGui:FindFirstChild("MainUI")
    local menus = mainUI and mainUI:FindFirstChild("Menus")
    local frame = menus and menus:FindFirstChild("GearShopFrame")
    local scrolling = frame and frame:FindFirstChild("ScrollingFrame")
    local item = scrolling and scrolling:FindFirstChild(name)
    if not item then return 0 end
    local text = ""
    for _, d in ipairs(item:GetDescendants()) do
        if d:IsA("TextLabel") and (d.Text:find("x") or d.Text:lower():find("stock")) then
            text = d.Text
            break
        end
    end
    local n = text:match("x%s*(%d+)") or text:match("(%d+)")
    return tonumber(n) or 0
end

local function buyGear(name)
    if not name or name == "" then return false end
    return invoke(getRemote("Gear", "Transaction"), name) ~= nil
end

local function buySelectedGearsOnce()
    for _, g in ipairs(GearItems) do
        if Config.AutoBuyAllGears or isSelected(Config.TargetGears, g.name) then
            if canAfford(g.cost or 0) and getGearStockFromGui(g.name) > 0 then
                buyGear(g.name)
                task.wait(0.35)
            end
        end
    end
end

local function getEggTransactionRemote()
    return getRemote("EggShop", "Transaction") or getRemote("Egg", "Transaction") or getRemote("BuyEgg")
end

local function getEggSlots()
    local slots = {}
    local mainUI = PlayerGui and PlayerGui:FindFirstChild("MainUI")
    local menus = mainUI and mainUI:FindFirstChild("Menus")
    local frame = menus and (menus:FindFirstChild("EggShopFrame") or menus:FindFirstChild("EggFrame"))
    if frame then
        for _, obj in ipairs(frame:GetDescendants()) do
            if obj:IsA("Frame") and (obj.Name:lower():find("slot") or obj.Name:lower():find("egg")) then
                local name = obj:GetAttribute("EggName") or obj.Name
                local slot = tonumber(obj:GetAttribute("Slot") or obj.Name:match("%d+")) or #slots + 1
                table.insert(slots, {Name = tostring(name), Slot = slot})
            end
        end
    end
    if #slots == 0 then
        for i = 1, 5 do table.insert(slots, {Name = "Podium " .. i, Slot = i}) end
    end
    return slots
end

local function buyEgg(slot)
    local remote = getEggTransactionRemote()
    if not remote then return false end
    local slotIndex = type(slot) == "table" and (slot.Slot or slot.EggSlotNumber or slot.Index) or slot
    return invoke(remote, "BuyEgg", slotIndex) ~= nil or invoke(remote, slotIndex) ~= nil
end

local function unlockEggSlotsOnce()
    local remote = getEggTransactionRemote()
    if not remote then return end
    for i = 1, 6 do
        invoke(remote, "UnlockSlot", i)
        task.wait(0.25)
    end
end

local function hatchEggOnce(podium)
    local remote = getEggTransactionRemote()
    if not remote then return false end
    local success, eggName = pcall(function()
        return remote:InvokeServer("BuyEgg", podium)
    end)
    if success and eggName and getRemote("RollEgg") then
        fire(getRemote("RollEgg"), eggName)
    end
    return success
end

local function autoHatchOnce()
    if Config.HatchAllPodiums then
        for i = 1, 5 do hatchEggOnce(i) task.wait(0.35) end
    else
        hatchEggOnce(tonumber(Config.SelectedEggPodium) or 1)
    end
end

--// Pets / rewards / events
local function autoUpgradePetsOnce()
    local data = snapshot()
    local inv = data and data.PetInventory
    if type(inv) ~= "table" then return end
    for key in pairs(inv) do
        invoke(getRemote("Pets", "UpgradePet") or getRemote("UpgradePet"), key)
        task.wait(0.08)
    end
end

local function autoSellPetsOnce()
    local data = snapshot()
    local inv = data and data.PetInventory
    local equipped = data and data.EquippedPets or {}
    if type(inv) ~= "table" then return end
    local equippedMap = {}
    for _, key in ipairs(equipped) do equippedMap[key] = true end
    for key in pairs(inv) do
        if not equippedMap[key] then
            invoke(getRemote("SellPet"), key)
            task.wait(0.1)
        end
    end
end

local function plantRushShootOnce()
    local r = getRemote("PlantRush", "Shoot") or getRemote("PlantRush")
    fire(r, "Shoot")
end

local function claimPlantRushDropsOnce()
    fire(getRemote("PlantRush", "DropClaim") or getRemote("ClaimBossDrop"))
end

local function collectHoneycombsOnce()
    local root = getRoot()
    if not root then return 0 end
    local folder = (workspace:FindFirstChild("InteractiveEvents") and workspace.InteractiveEvents:FindFirstChild("QueenBee")) or workspace:FindFirstChild("QueenBee")
    local runtime = folder and (folder:FindFirstChild("RuntimeHoneycombs") or folder)
    if not runtime then return 0 end

    local origin = root.CFrame
    local count = 0
    for _, obj in ipairs(runtime:GetChildren()) do
        if count >= 15 then break end
        local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
        local cf = obj:IsA("Model") and obj:GetPivot() or (obj:IsA("BasePart") and obj.CFrame)
        if cf then
            root.CFrame = cf + Vector3.new(0, 3, 0)
            task.wait(0.08)
            if prompt and fireproximityprompt then
                pcall(function()
                    prompt.HoldDuration = 0
                    prompt.RequiresLineOfSight = false
                    fireproximityprompt(prompt)
                end)
            else
                fire(getRemote("CollectHoneycomb"))
            end
            count += 1
            task.wait(0.12)
        end
    end
    root.CFrame = origin
    return count
end

local function submitHoneyTokenOnce()
    fire(getRemote("SubmitHoneyToken"))
    local root = getRoot()
    local folder = (workspace:FindFirstChild("InteractiveEvents") and workspace.InteractiveEvents:FindFirstChild("QueenBee")) or workspace:FindFirstChild("QueenBee")
    local machine = folder and (folder:FindFirstChild("HoneyJarMachine", true) or folder:FindFirstChild("Honey Jar Machine", true))
    if root and machine then
        local origin = root.CFrame
        root.CFrame = machine:GetPivot() + Vector3.new(0, 3, 0)
        task.wait(0.2)
        for _, d in ipairs(machine:GetDescendants()) do
            if d:IsA("ProximityPrompt") and fireproximityprompt then
                pcall(function() d.HoldDuration = 0; fireproximityprompt(d) end)
            end
        end
        task.wait(0.15)
        root.CFrame = origin
    end
end

local function collectAlienDropsOnce()
    local root = getRoot()
    if not root then return end
    local origin = root.CFrame
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if count >= 25 then break end
        local lower = obj.Name:lower()
        if (obj:IsA("BasePart") or obj:IsA("Model")) and (lower:find("alien") or lower:find("drop")) then
            local cf = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
            root.CFrame = cf + Vector3.new(0, 3, 0)
            count += 1
            task.wait(0.08)
        end
        if count % 8 == 0 then task.wait() end
    end
    root.CFrame = origin
end

local function submitCollectorSeedOnce()
    if Config.AutoSubmitAllSeedsToCollector then
        fire(getRemote("SubmitAllSeeds"))
        return true
    end
    local remote = getRemote("SubmitSeedToCollector") or getRemote("SubmitSeed") or getRemote("SeedCollector", "SubmitSeed")
    if not remote then return false end
    local function scan(parent)
        if not parent then return nil end
        for _, tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") then
                local plant = normalizeName(tool:GetAttribute("Plant") or tool:GetAttribute("trueName") or tool.Name)
                if isSelected(Config.TargetCollectorSeeds, plant) then return tool end
            end
        end
    end
    local tool = scan(LocalPlayer:FindFirstChildOfClass("Backpack")) or scan(LocalPlayer.Character)
    if tool then
        fire(remote, tool)
        return true
    end
    return false
end

local function claimDailyRewardsOnce()
    for i = 1, 14 do
        invoke(getRemote("ClaimDailyReward"), i)
        task.wait(0.08)
    end
end

local function claimPlaytimeRewardsOnce()
    local state = invoke(getRemote("GetPlaytimeRewardState"))
    local claimed = type(state) == "table" and state.ClaimedMap or {}
    for i = 1, 30 do
        if not claimed[tostring(i)] then
            invoke(getRemote("ClaimPlaytimeReward"), i)
            task.wait(0.06)
        end
    end
end

local function claimGroupRewardOnce()
    invoke(getRemote("GroupReward"))
end

local RedeemCodeList = {"ALL", "250KUSERS", "UPDATE2", "PLANTRUSH", "THANKYOU", "BARF:3", "UPDATE1", "2KLIKES", "100KVISITS"}
local RedeemCodeOnlyList = {"250KUSERS", "UPDATE2", "PLANTRUSH", "THANKYOU", "BARF:3", "UPDATE1", "2KLIKES", "100KVISITS"}

local function redeemCode(code)
    code = tostring(code or "")
    if code == "" or code == "ALL" then return false end
    return invoke(getRemote("SubmitCode"), code) ~= nil
end

local function getSelectedRedeemCodes()
    local selected = Config.SelectedRedeemCodes
    local out, seen = {}, {}

    if isSelected(selected, "ALL") then
        for _, code in ipairs(RedeemCodeOnlyList) do
            table.insert(out, code)
        end
        return out
    end

    for _, code in ipairs(RedeemCodeOnlyList) do
        if isSelected(selected, code) and not seen[code] then
            seen[code] = true
            table.insert(out, code)
        end
    end

    -- Legacy support: if the user had old custom codes saved, still allow the button to redeem them.
    if #out == 0 then
        for code in tostring(Config.Codes or ""):gmatch("[^,%s]+") do
            if not seen[code] then
                seen[code] = true
                table.insert(out, code)
            end
        end
    end

    return out
end

local function redeemCodesOnce()
    local codes = getSelectedRedeemCodes()
    if #codes == 0 then
        notify("Redeem Code", "Please select at least one code.", 2.5, "ticket")
        return
    end

    task.spawn(function()
        local count = 0
        for _, code in ipairs(codes) do
            if not alive() then break end
            redeemCode(code)
            count += 1
            task.wait(0.35)
        end
        notify("Redeem Code", "Redeemed " .. tostring(count) .. " code(s).", 2.5, "badge-check")
    end)
end

--// Fertilizer automation
local function getFertTool()
    local allowed = Config.TargetFertilizerTypes
    local function scan(parent)
        if not parent then return nil end
        for _, tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") then
                for _, ftype in ipairs(FertilizerTypes) do
                    if tool.Name:find(ftype) and (not next(allowed or {}) or isSelected(allowed, ftype)) then
                        return tool
                    end
                end
            end
        end
    end
    return scan(LocalPlayer.Character) or scan(LocalPlayer:FindFirstChildOfClass("Backpack"))
end

local function fertilizeOnce()
    local fert = getFertTool()
    if not fert then return end
    local hum = getHumanoid()
    if hum then pcall(function() hum:EquipTool(fert) end) end
    local remote = getRemote("Fertilize") or getRemote("UseFertilizer")
    if remote then
        for _, dirt in ipairs(getDirtPlots({planted = true})) do
            fire(remote, dirt)
            task.wait(0.1)
            break
        end
    end
end

--// Player utilities
local function applyLowGraphics()
    task.spawn(function()
        local n = 0
        for _, obj in ipairs(game:GetDescendants()) do
            if not alive() then break end
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = false
            end
            n += 1
            if n % 350 == 0 then task.wait() end
        end
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
        end)
        notify("FPS Boost", "Low graphics applied safely.", 2, "zap")
    end)
end

local function rejoinServer()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

local function serverHop()
    task.spawn(function()
        local ok, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if ok and data and data.data then
            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end
    end)
end

--// Anti AFK
keepConnection(LocalPlayer.Idled:Connect(function()
    if not Config.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end))

--// Infinite jump
keepConnection(UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

--// NoClip optimized: character parts cache
local charParts = {}
local function rebuildCharParts()
    table.clear(charParts)
    local char = LocalPlayer.Character
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then table.insert(charParts, d) end
    end
end
rebuildCharParts()
keepConnection(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    rebuildCharParts()
end))
keepConnection(RunService.Stepped:Connect(function()
    if Config.NoClip then
        for _, part in ipairs(charParts) do
            if part and part.Parent then part.CanCollide = false end
        end
    end
end))

--// Block Robux purchase popups lightly
task.defer(function()
    task.wait(2)
    pcall(function()
        local purchasePrompt = CoreGui:FindFirstChild("PurchasePrompt")
        if purchasePrompt then purchasePrompt.Enabled = not Config.BlockRobuxPopups end
    end)
end)

--// Load WindUI after core is ready
repeat task.wait() until game:IsLoaded()

WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local FreeVersion, PremiumVersion, ExtraVersion = "Free Version", "Premium Version", "Extra Version"
local function getData(url)
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success or not response then return nil end
    local func = loadstring(response)
    if func then
        local ok, data = pcall(func)
        if ok then return data end
    end
    return nil
end

local function checkVersion(playerName)
    local extraData = getData("https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/STBBList.lua")
    if extraData and extraData[playerName] then return ExtraVersion end
    local premiumData = getData("https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua")
    if premiumData and premiumData[playerName] then return PremiumVersion end
    return FreeVersion
end

local userversion = checkVersion(LocalPlayer.Name)

local Window = WindUI:CreateWindow({
    Title = "DYHUB",
    IconThemed = true,
    Icon = "rbxassetid://104487529937663",
    Author = "BARF | " .. userversion,
    Folder = "DYHUB",
    Size = UDim2.fromOffset(560, 390),
    Transparent = true,
    Theme = "Dark",
    BackgroundImageTransparency = 0.82,
    HasOutline = false,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.K)
Window:Tag({ Title = version, Color = Color3.fromHex("#db7093") })
Window:EditOpenButton({
    Title = "DYHUB - Open",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 255, 255)),
    Draggable = true
})

local Tab = Window:Tab({Title = "Information", Icon = "info"})
Window:Divider()
local MainTab = Window:Tab({Title = "Main", Icon = "sprout"})
local UpgradeTab = Window:Tab({Title = "Upgrades", Icon = "sparkles"})
local ShopTab = Window:Tab({Title = "Shop", Icon = "shopping-cart"})
local EventTab = Window:Tab({Title = "Events", Icon = "star"})
local RewardTab = Window:Tab({Title = "Rewards", Icon = "gift"})
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})
local SettingsTab = Window:Tab({Title = "Settings", Icon = "settings"})

-- ======================== Information ========================
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

Info:Section({ Title = "Lasted Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({
    Title = "Update: 06/08/2026 | CL: " .. ver,
    Desc = [[• [ Merged ] Systems from another hub for dyhub
• [ Reworked ] One runtime kill switch + central scheduler to reduce duplicate loops.
• [ Improved ] Lazy remotes, cached plot scans, no heavy stock scan on first run.
• [ Added ] Smart farm, seed roll targets, rarity roll, transcended roll, pets, eggs, gear, events, rewards, player tools.]],
})
Info:Divider()
Info:Section({ Title = "Discord Information", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()

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

InviteCode = "jWNDPNMmyB"
DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

function LoadDiscordInfo()
    local success, result = pcall(function()
        local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
        if not httpRequest then return nil end
        local response = httpRequest({ Url = DiscordAPI, Method = "GET", Headers = { ["User-Agent"] = "RobloxBot/1.0", ["Accept"] = "application/json" } })
        if response and response.Body then return game:GetService("HttpService"):JSONDecode(response.Body) end
        return nil
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
                    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
                    if not httpRequest then return nil end
                    local response = httpRequest({ Url = DiscordAPI, Method = "GET" })
                    if response and response.Body then return game:GetService("HttpService"):JSONDecode(response.Body) end
                    return nil
                end)
                if updated and updatedResult and updatedResult.guild then
                    DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : ' .. tostring(updatedResult.approximate_member_count) .. '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(updatedResult.approximate_presence_count))
                    WindUI:Notify({ Title = "Discord Info Updated", Content = "Successfully refreshed Discord statistics", Duration = 2, Icon = "refresh-cw" })
                else
                    WindUI:Notify({ Title = "Update Failed", Content = "Could not refresh Discord info", Duration = 3, Icon = "alert-triangle" })
                end
            end
        })

        Info:Button({
            Title = "Copy Discord Invite",
            Callback = function()
                setclipboard("https://discord.gg/" .. InviteCode)
                WindUI:Notify({ Title = "Copied!", Content = "Discord invite copied to clipboard", Duration = 2, Icon = "clipboard-check" })
            end
        })
    else
        Info:Paragraph({ Title = "Error fetching Discord Info", Desc = "Unable to load Discord information.", Image = "triangle-alert", ImageSize = 26, Color = "Red" })
    end
end

LoadDiscordInfo()

Info:Divider()
Info:Section({ Title = "DYHUB Information", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()

Info:Paragraph({ Title = "Main Owner", Desc = "@dyumraisgoodguy#8888", Image = "rbxassetid://119789418015420", ImageSize = 30 })

Info:Paragraph({
    Title = "Social",
    Desc = "Copy link social media for follow!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Buttons = { { Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://guns.lol/DYHUB") end } }
})

Info:Paragraph({
    Title = "Discord",
    Desc = "Join our discord for more scripts!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Buttons = { { Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://discord.gg/jWNDPNMmyB") end } }
})
Info:Divider()
Info:Paragraph({
    Title = "DYHUB",
    Desc = "Press K to hide/show UI.",
    Image = "rbxassetid://104487529937663",
    ImageSize = 32,
})
Info:Paragraph({
    Title = "Runtime",
    Desc = "Loops: " .. tostring(Runtime.LoopCount) .. " | JobId: " .. tostring(game.JobId),
})



-- ======================== UI Helpers ========================
local function resolveNumber(value, fallback)
    if type(value) == "number" then return value end
    if type(value) == "string" then return tonumber(value) or fallback end
    if type(value) == "table" then
        if type(value.Value) == "number" then return value.Value end
        if type(value.value) == "number" then return value.value end
        if type(value.Default) == "number" then return value.Default end
        if type(value[1]) == "number" then return value[1] end
    end
    return fallback
end

local function addSection(tab, data)
    data.TextSize = data.TextSize or 16
    return tab:Section(data)
end

local function addToggle(tab, data)
    data.Desc = data.Desc or "Enable or disable this feature."
    return tab:Toggle(data)
end

local function addDropdown(tab, data)
    data.Desc = data.Desc or "Choose one or more options."
    return tab:Dropdown(data)
end

local function addButton(tab, data)
    data.Desc = data.Desc or "Run this action one time."
    return tab:Button(data)
end

local function addInput(tab, data)
    data.Desc = data.Desc or "Enter a value for this setting."
    data.Finished = data.Finished ~= false
    return tab:Input(data)
end

local function addSlider(tab, data)
    local minValue = data.Min or 0
    local maxValue = data.Max or 100
    local defaultValue = data.Default or data.DefaultValue or minValue
    local cb = data.Callback

    data.Desc = data.Desc or "Adjust this value smoothly."
    data.Value = {
        Min = minValue,
        Max = maxValue,
        Default = defaultValue,
    }
    data.Min = nil
    data.Max = nil
    data.Default = nil
    data.DefaultValue = nil

    data.Callback = function(value)
        local numberValue = resolveNumber(value, defaultValue)
        if cb then cb(numberValue) end
    end

    return tab:Slider(data)
end

-- ======================== Main / Farm ========================
addSection(MainTab, {
    Title = "Automation Control",
    Desc = "Primary farming controls with optimized scheduling and safe delays.",
    Icon = "activity",
})
addToggle(MainTab, {
    Title = "Auto Farm Everything",
    Desc = "Runs planting, upgrades, plot unlocks, and selling through one optimized loop.",
    Value = Config.MasterFarm,
    Callback = function(v) setConfig("MasterFarm", v) end,
})

addSection(MainTab, {
    Title = "Planting System",
    Desc = "Controls seed selection, planting behavior, and farming speed.",
    Icon = "sprout",
})
addToggle(MainTab, {
    Title = "Auto Plant",
    Desc = "Automatically plants the best available seed on unlocked empty plots.",
    Value = Config.AutoPlant,
    Callback = function(v) setConfig("AutoPlant", v) end,
})
addDropdown(MainTab, {
    Title = "Plant Strategy",
    Desc = "Selects how the script chooses which seed should be planted first.",
    Values = {"Best Value", "Best ROI", "Fastest Grow", "Rarest Owned", "Selected Seed"},
    Value = Config.PlantMode,
    Callback = function(v) setConfig("PlantMode", v) end,
})
addDropdown(MainTab, {
    Title = "Preferred Seed",
    Desc = "Used when Plant Strategy is set to Selected Seed.",
    Values = seedNames(),
    Value = Config.SelectedSeed,
    Callback = function(v) setConfig("SelectedSeed", v) end,
})
addSlider(MainTab, {
    Title = "Plant Delay",
    Desc = "Controls the delay between each planting attempt to reduce lag and ping spikes.",
    Min = 0.2,
    Max = 5,
    Default = tonumber(Config.PlantDelay) or 0.35,
    Step = 0.05,
    Callback = function(v) setConfig("PlantDelay", v) end,
})

addSection(MainTab, {
    Title = "Farm Actions",
    Desc = "Extra farm automation and one-click utility actions.",
    Icon = "wheat",
})
addToggle(MainTab, {
    Title = "Auto Upgrade Plants",
    Desc = "Upgrades planted crops automatically using the game upgrade remote.",
    Value = Config.AutoUpgradePlants,
    Callback = function(v) setConfig("AutoUpgradePlants", v) end,
})
addToggle(MainTab, {
    Title = "Auto Unlock Farm Plots",
    Desc = "Unlocks locked farm plots when the unlock remote is available.",
    Value = Config.AutoUnlockFarmPlots,
    Callback = function(v) setConfig("AutoUnlockFarmPlots", v) end,
})
addToggle(MainTab, {
    Title = "Auto Sell Crates",
    Desc = "Automatically sells available crates on a safe interval.",
    Value = Config.AutoSellCrates,
    Callback = function(v) setConfig("AutoSellCrates", v) end,
})
addButton(MainTab, {
    Title = "Plant Once",
    Desc = "Plants one seed immediately using the current plant strategy.",
    Callback = plantOnce,
})
addButton(MainTab, {
    Title = "Sell Crates Now",
    Desc = "Sells crates immediately without enabling the auto loop.",
    Callback = sellCratesOnce,
})
addButton(MainTab, {
    Title = "Teleport To My Plot",
    Desc = "Moves your character above your detected farm plot.",
    Callback = function()
        local plot = findMyPlot(true)
        if plot then
            teleportTo(plot:GetPivot() + Vector3.new(0, 5, 0))
        else
            notify("Teleport", "Your plot could not be detected yet.", 2.5, "map-pin")
        end
    end,
})

-- ======================== Upgrades ========================
addSection(UpgradeTab, {
    Title = "Core Upgrades",
    Desc = "Main farm upgrade automation with low-frequency remote calls.",
    Icon = "sparkles",
})
addToggle(UpgradeTab, {
    Title = "Auto Upgrade Farm",
    Desc = "Upgrades general farm stats whenever the remote is ready.",
    Value = Config.AutoUpgradeFarm,
    Callback = function(v) setConfig("AutoUpgradeFarm", v) end,
})
addToggle(UpgradeTab, {
    Title = "Auto Upgrade Seed Luck",
    Desc = "Improves seed luck automatically with safe cooldowns.",
    Value = Config.AutoUpgradeSeedLuck,
    Callback = function(v) setConfig("AutoUpgradeSeedLuck", v) end,
})
addToggle(UpgradeTab, {
    Title = "Auto Upgrade Seed Rolls",
    Desc = "Improves seed roll capacity automatically with safe cooldowns.",
    Value = Config.AutoUpgradeSeedRolls,
    Callback = function(v) setConfig("AutoUpgradeSeedRolls", v) end,
})
addButton(UpgradeTab, {
    Title = "Upgrade Core Once",
    Desc = "Runs farm, seed luck, and seed roll upgrades one time.",
    Callback = function()
        upgradeFarmOnce()
        task.wait(0.08)
        upgradeSeedLuckOnce()
        task.wait(0.08)
        upgradeSeedRollsOnce()
    end,
})

addSection(UpgradeTab, {
    Title = "Plot Upgrades",
    Desc = "Floor-based plot upgrades with selectable priority and multi-target support.",
    Icon = "layout-grid",
})
addDropdown(UpgradeTab, {
    Title = "Upgrade Floor",
    Desc = "Selects which plot floor should receive upgrades.",
    Values = {"All Floors", "Floor1", "Floor2", "Floor3", "Floor4", "Floor5", "Floor6"},
    Value = Config.PlotUpgradeFloor,
    Callback = function(v) setConfig("PlotUpgradeFloor", v) end,
})
addDropdown(UpgradeTab, {
    Title = "Upgrade Priority",
    Desc = "Controls the upgrade order when no specific targets are selected.",
    Values = {"Yield > Soil > Power > Sprinkler > Saw", "Soil > Yield > Power", "Sprinkler > Power > Yield", "Saw > Yield > Soil"},
    Value = Config.PlotUpgradePriority,
    Callback = function(v) setConfig("PlotUpgradePriority", v) end,
})
addDropdown(UpgradeTab, {
    Title = "Selected Plot Upgrades",
    Desc = "Choose specific upgrades. Leave empty to follow the selected priority order.",
    Values = {"Yield", "Soil", "Power", "Sprinkler Range", "Saw Range"},
    Value = Config.TargetPlotUpgrades,
    Multi = true,
    AllowNone = true,
    Callback = function(v) setConfig("TargetPlotUpgrades", v or {}) end,
})
addToggle(UpgradeTab, {
    Title = "Auto Upgrade Plot",
    Desc = "Automatically upgrades selected plot stats one at a time.",
    Value = Config.AutoUpgradePlot,
    Callback = function(v) setConfig("AutoUpgradePlot", v) end,
})
addButton(UpgradeTab, {
    Title = "Upgrade Plot Once",
    Desc = "Runs one full plot upgrade pass with your current settings.",
    Callback = plotUpgradeOnce,
})

addSection(UpgradeTab, {
    Title = "Fertilizer",
    Desc = "Optional fertilizer support for selected fertilizer tools.",
    Icon = "droplets",
})
addDropdown(UpgradeTab, {
    Title = "Fertilizer Types",
    Desc = "Select which fertilizer tools can be used by automation.",
    Values = FertilizerTypes,
    Value = Config.TargetFertilizerTypes,
    Multi = true,
    AllowNone = true,
    Callback = function(v) setConfig("TargetFertilizerTypes", v or {}) end,
})
addToggle(UpgradeTab, {
    Title = "Auto Fertilize",
    Desc = "Automatically uses selected fertilizer tools when available.",
    Value = Config.AutoFertilize,
    Callback = function(v) setConfig("AutoFertilize", v) end,
})
addButton(UpgradeTab, {
    Title = "Fertilize Once",
    Desc = "Uses one valid fertilizer tool immediately.",
    Callback = fertilizeOnce,
})

-- ======================== Shop ========================
addSection(ShopTab, {
    Title = "Seed Roller",
    Desc = "Roll seeds and buy chosen results using optimized roll detection.",
    Icon = "dice-5",
})
addToggle(ShopTab, {
    Title = "Auto Roll Seeds",
    Desc = "Rolls seeds repeatedly with your selected delay.",
    Value = Config.AutoRollSeeds,
    Callback = function(v)
        setConfig("AutoRollSeeds", v)
        connectRollEvent()
    end,
})
addSlider(ShopTab, {
    Title = "Roll Delay",
    Desc = "Sets the delay between seed rolls to reduce lag and remote spam.",
    Min = 0.5,
    Max = 10,
    Default = tonumber(Config.RollDelay) or 2.5,
    Step = 0.1,
    Callback = function(v) setConfig("RollDelay", v) end,
})
addToggle(ShopTab, {
    Title = "Auto Buy All Rolled Seeds",
    Desc = "Buys every seed slot after each roll.",
    Value = Config.AutoBuyAllRolledSeeds,
    Callback = function(v) setConfig("AutoBuyAllRolledSeeds", v) end,
})

addSection(ShopTab, {
    Title = "Seed Targets",
    Desc = "Choose exact seeds or rarities to buy after rolling.",
    Icon = "list-checks",
})
addDropdown(ShopTab, {
    Title = "Selected Seed Targets",
    Desc = "Multi-select exact seed names that should be bought after a roll.",
    Values = seedNames(),
    Value = Config.TargetSeeds,
    Multi = true,
    AllowNone = true,
    Callback = function(v) setConfig("TargetSeeds", v or {}) end,
})
addToggle(ShopTab, {
    Title = "Auto Buy Selected Seeds",
    Desc = "Buys only rolled seeds that match Selected Seed Targets.",
    Value = Config.AutoBuySelectedRolledSeeds,
    Callback = function(v) setConfig("AutoBuySelectedRolledSeeds", v) end,
})
addDropdown(ShopTab, {
    Title = "Selected Rarities",
    Desc = "Multi-select rarities to buy automatically after each roll.",
    Values = RARITY_ORDER,
    Value = Config.TargetRarities,
    Multi = true,
    AllowNone = true,
    Callback = function(v) setConfig("TargetRarities", v or {}) end,
})
addToggle(ShopTab, {
    Title = "Auto Buy By Rarity",
    Desc = "Buys rolled seeds when their rarity matches the selected rarity list.",
    Value = Config.AutoBuyByRarity,
    Callback = function(v) setConfig("AutoBuyByRarity", v) end,
})
addToggle(ShopTab, {
    Title = "Auto Buy Any Transcended",
    Desc = "Buys any rolled Transcended seed even if it is not in the target list.",
    Value = Config.AutoBuyAnyTranscended,
    Callback = function(v) setConfig("AutoBuyAnyTranscended", v) end,
})
addToggle(ShopTab, {
    Title = "Auto Open Seed Packs",
    Desc = "Automatically opens seed packs using the available pack remote.",
    Value = Config.AutoOpenSeedPacks,
    Callback = function(v) setConfig("AutoOpenSeedPacks", v) end,
})
addButton(ShopTab, {
    Title = "Roll Seeds Once",
    Desc = "Performs a single seed roll without enabling Auto Roll Seeds.",
    Callback = rollSeedsOnce,
})
addButton(ShopTab, {
    Title = "Buy All Slots Once",
    Desc = "Buys every current seed slot one time.",
    Callback = buyAllSlotsOnce,
})
addButton(ShopTab, {
    Title = "Open Seed Pack Once",
    Desc = "Opens one seed pack immediately.",
    Callback = openSeedPackOnce,
})

addSection(ShopTab, {
    Title = "Gear Shop",
    Desc = "Gear purchase controls with all-stock and selected-item modes.",
    Icon = "shopping-bag",
})
addDropdown(ShopTab, {
    Title = "Selected Gears",
    Desc = "Multi-select gear items that should be purchased automatically.",
    Values = gearNames(),
    Value = Config.TargetGears,
    Multi = true,
    AllowNone = true,
    Callback = function(v) setConfig("TargetGears", v or {}) end,
})
addToggle(ShopTab, {
    Title = "Auto Buy All Gears",
    Desc = "Buys every gear item that is available and affordable.",
    Value = Config.AutoBuyAllGears,
    Callback = function(v) setConfig("AutoBuyAllGears", v) end,
})
addToggle(ShopTab, {
    Title = "Auto Buy Selected Gears",
    Desc = "Buys only gear items selected in Selected Gears.",
    Value = Config.AutoBuySelectedGears,
    Callback = function(v) setConfig("AutoBuySelectedGears", v) end,
})
addButton(ShopTab, {
    Title = "Buy Selected Gear Once",
    Desc = "Attempts to buy selected gear items one time.",
    Callback = buySelectedGearsOnce,
})

addSection(ShopTab, {
    Title = "Egg Shop & Hatch",
    Desc = "Egg slot unlocking, egg buying, and hatch automation.",
    Icon = "egg",
})
addToggle(ShopTab, {
    Title = "Auto Unlock Egg Slots",
    Desc = "Unlocks available egg slots automatically.",
    Value = Config.AutoUnlockEggSlots,
    Callback = function(v) setConfig("AutoUnlockEggSlots", v) end,
})
addToggle(ShopTab, {
    Title = "Auto Buy All Eggs",
    Desc = "Buys all available egg podiums on a safe interval.",
    Value = Config.AutoBuyAllEggs,
    Callback = function(v) setConfig("AutoBuyAllEggs", v) end,
})
addDropdown(ShopTab, {
    Title = "Selected Egg Labels",
    Desc = "Multi-select egg podium labels for targeted egg buying.",
    Values = {"Podium 1", "Podium 2", "Podium 3", "Podium 4", "Podium 5"},
    Value = Config.TargetEggs,
    Multi = true,
    AllowNone = true,
    Callback = function(v) setConfig("TargetEggs", v or {}) end,
})
addToggle(ShopTab, {
    Title = "Auto Buy Selected Eggs",
    Desc = "Buys only the egg podiums selected above.",
    Value = Config.AutoBuySelectedEggs,
    Callback = function(v) setConfig("AutoBuySelectedEggs", v) end,
})
addToggle(ShopTab, {
    Title = "Auto Hatch Eggs",
    Desc = "Hatches eggs automatically using the selected podium settings.",
    Value = Config.AutoHatchEggs,
    Callback = function(v) setConfig("AutoHatchEggs", v) end,
})
addToggle(ShopTab, {
    Title = "Hatch All Podiums",
    Desc = "Hatches every podium instead of only the selected podium.",
    Value = Config.HatchAllPodiums,
    Callback = function(v) setConfig("HatchAllPodiums", v) end,
})
addSlider(ShopTab, {
    Title = "Selected Egg Podium",
    Desc = "Selects the podium used when Hatch All Podiums is disabled.",
    Min = 1,
    Max = 5,
    Default = tonumber(Config.SelectedEggPodium) or 1,
    Step = 1,
    Callback = function(v) setConfig("SelectedEggPodium", math.floor(v + 0.5)) end,
})
addButton(ShopTab, {
    Title = "Unlock Egg Slots Once",
    Desc = "Attempts to unlock available egg slots one time.",
    Callback = unlockEggSlotsOnce,
})
addButton(ShopTab, {
    Title = "Hatch Once",
    Desc = "Runs one hatch action with your selected podium settings.",
    Callback = autoHatchOnce,
})

local stockParagraph = ShopTab:Paragraph({
    Title = "Live Stock",
    Desc = "Stock is scanned only when requested to prevent first-run freezing.",
})
addButton(ShopTab, {
    Title = "Refresh Stock Info",
    Desc = "Refreshes lightweight stock and cash information without heavy startup scans.",
    Callback = function()
        task.spawn(function()
            local parts = {}
            table.insert(parts, "Cash: $" .. tostring(math.floor(getPlayerCash())))
            table.insert(parts, "Gear stock is checked only when buying to reduce lag.")
            table.insert(parts, "Seeds loaded: " .. tostring(#SeedDatabase))
            stockParagraph:SetDesc(table.concat(parts, "\n"))
        end)
    end,
})

-- ======================== Events ========================
addSection(EventTab, {
    Title = "Plant Rush",
    Desc = "Plant Rush event controls with clear one-time actions.",
    Icon = "target",
})
addToggle(EventTab, {
    Title = "Auto Shoot Plant Rush",
    Desc = "Automatically fires the Plant Rush shoot remote on a short safe delay.",
    Value = Config.AutoPlantRush,
    Callback = function(v) setConfig("AutoPlantRush", v) end,
})
addToggle(EventTab, {
    Title = "Auto Claim Plant Rush Drops",
    Desc = "Automatically claims Plant Rush drops when available.",
    Value = Config.AutoClaimPlantRushDrops,
    Callback = function(v) setConfig("AutoClaimPlantRushDrops", v) end,
})
addButton(EventTab, {
    Title = "Shoot Once",
    Desc = "Shoots Plant Rush once without enabling automation.",
    Callback = plantRushShootOnce,
})
addButton(EventTab, {
    Title = "Claim Drops Once",
    Desc = "Claims available Plant Rush drops one time.",
    Callback = claimPlantRushDropsOnce,
})

addSection(EventTab, {
    Title = "Queen Bee & Honey",
    Desc = "Honeycomb collection and honey token submission tools.",
    Icon = "beaker",
})
addToggle(EventTab, {
    Title = "Auto Collect Honeycombs",
    Desc = "Automatically collects available Queen Bee honeycombs.",
    Value = Config.AutoCollectHoneycombs,
    Callback = function(v) setConfig("AutoCollectHoneycombs", v) end,
})
addToggle(EventTab, {
    Title = "Auto Submit Honey Token",
    Desc = "Automatically submits honey tokens through the event remote.",
    Value = Config.AutoSubmitHoneyToken,
    Callback = function(v) setConfig("AutoSubmitHoneyToken", v) end,
})
addButton(EventTab, {
    Title = "Collect Honey Once",
    Desc = "Collects honeycombs one time.",
    Callback = collectHoneycombsOnce,
})
addButton(EventTab, {
    Title = "Submit Honey Once",
    Desc = "Submits one honey token action immediately.",
    Callback = submitHoneyTokenOnce,
})

addSection(EventTab, {
    Title = "Alien Drops",
    Desc = "Alien event drop collection tools.",
    Icon = "sparkles",
})
addToggle(EventTab, {
    Title = "Auto Collect Alien Drops",
    Desc = "Automatically collects nearby Alien event drops.",
    Value = Config.AutoCollectAlienDrops,
    Callback = function(v) setConfig("AutoCollectAlienDrops", v) end,
})
addButton(EventTab, {
    Title = "Collect Alien Drops Once",
    Desc = "Runs one Alien drop collection pass.",
    Callback = collectAlienDropsOnce,
})

addSection(EventTab, {
    Title = "Seed Collector",
    Desc = "Seed collector submission controls with targeted and all-seed modes.",
    Icon = "package-check",
})
addDropdown(EventTab, {
    Title = "Collector Seed Targets",
    Desc = "Multi-select seeds that can be submitted to the collector.",
    Values = seedNames(),
    Value = Config.TargetCollectorSeeds,
    Multi = true,
    AllowNone = true,
    Callback = function(v) setConfig("TargetCollectorSeeds", v or {}) end,
})
addToggle(EventTab, {
    Title = "Auto Submit Targeted Seeds",
    Desc = "Submits only selected collector seed targets.",
    Value = Config.AutoSubmitSeedsToCollector,
    Callback = function(v) setConfig("AutoSubmitSeedsToCollector", v) end,
})
addToggle(EventTab, {
    Title = "Auto Submit All Seeds",
    Desc = "Submits any valid seed found in your inventory.",
    Value = Config.AutoSubmitAllSeedsToCollector,
    Callback = function(v) setConfig("AutoSubmitAllSeedsToCollector", v) end,
})
addButton(EventTab, {
    Title = "Submit Collector Once",
    Desc = "Runs one seed collector submission attempt.",
    Callback = submitCollectorSeedOnce,
})

-- ======================== Rewards ========================
addSection(RewardTab, {
    Title = "Reward Claiming",
    Desc = "Daily, playtime, and group reward automation.",
    Icon = "gift",
})
addToggle(RewardTab, {
    Title = "Auto Daily Rewards",
    Desc = "Claims daily rewards automatically when available.",
    Value = Config.AutoDailyRewards,
    Callback = function(v) setConfig("AutoDailyRewards", v) end,
})
addToggle(RewardTab, {
    Title = "Auto Playtime Rewards",
    Desc = "Claims playtime rewards automatically with a safe interval.",
    Value = Config.AutoPlaytimeRewards,
    Callback = function(v) setConfig("AutoPlaytimeRewards", v) end,
})
addToggle(RewardTab, {
    Title = "Auto Group Reward",
    Desc = "Claims the group reward automatically when the remote is available.",
    Value = Config.AutoGroupReward,
    Callback = function(v) setConfig("AutoGroupReward", v) end,
})
addButton(RewardTab, {
    Title = "Claim Daily Once",
    Desc = "Claims all daily reward indexes one time.",
    Callback = claimDailyRewardsOnce,
})
addButton(RewardTab, {
    Title = "Claim Playtime Once",
    Desc = "Claims all unclaimed playtime rewards one time.",
    Callback = claimPlaytimeRewardsOnce,
})
addButton(RewardTab, {
    Title = "Claim Group Once",
    Desc = "Claims the group reward one time.",
    Callback = claimGroupRewardOnce,
})

addSection(RewardTab, {
    Title = "Redeem Codes",
    Desc = "Choose one or more official codes, then redeem them with one button.",
    Icon = "ticket",
})
addDropdown(RewardTab, {
    Title = "Selected Codes",
    Desc = "Select ALL to redeem every code, or select multiple individual codes.",
    Values = RedeemCodeList,
    Value = Config.SelectedRedeemCodes,
    Multi = true,
    AllowNone = true,
    Callback = function(v) setConfig("SelectedRedeemCodes", v or {}) end,
})
addButton(RewardTab, {
    Title = "Redeem Code",
    Desc = "Redeems the selected code list one by one using the original SubmitCode remote.",
    Callback = redeemCodesOnce,
})

addSection(RewardTab, {
    Title = "Pets",
    Desc = "Pet upgrade and pet selling automation.",
    Icon = "paw-print",
})
addToggle(RewardTab, {
    Title = "Auto Upgrade Pets",
    Desc = "Automatically upgrades pets when the pet upgrade remote is available.",
    Value = Config.AutoUpgradePets,
    Callback = function(v) setConfig("AutoUpgradePets", v) end,
})
addToggle(RewardTab, {
    Title = "Auto Sell Unequipped Pets",
    Desc = "Automatically sells unequipped pets on a safe reward loop interval.",
    Value = Config.AutoSellPets,
    Callback = function(v) setConfig("AutoSellPets", v) end,
})
addButton(RewardTab, {
    Title = "Upgrade Pets Once",
    Desc = "Runs one pet upgrade pass.",
    Callback = autoUpgradePetsOnce,
})
addButton(RewardTab, {
    Title = "Sell Unequipped Pets Once",
    Desc = "Runs one unequipped pet sell pass.",
    Callback = autoSellPetsOnce,
})

-- ======================== Player ========================
addSection(PlayerTab, {
    Title = "Protection",
    Desc = "Quality-of-life protections and light performance helpers.",
    Icon = "shield-check",
})
addToggle(PlayerTab, {
    Title = "Anti AFK",
    Desc = "Prevents idle disconnection with a lightweight idle handler.",
    Value = Config.AntiAFK,
    Callback = function(v) setConfig("AntiAFK", v) end,
})
addToggle(PlayerTab, {
    Title = "Block Robux Popups",
    Desc = "Attempts to block unwanted purchase prompts while the script is active.",
    Value = Config.BlockRobuxPopups,
    Callback = function(v) setConfig("BlockRobuxPopups", v) end,
})
addButton(PlayerTab, {
    Title = "FPS Boost",
    Desc = "Applies low graphics settings to reduce rendering lag.",
    Callback = applyLowGraphics,
})

addSection(PlayerTab, {
    Title = "Movement",
    Desc = "Local character helpers with cached character parts to reduce per-frame lag.",
    Icon = "user-round-cog",
})
addToggle(PlayerTab, {
    Title = "Infinite Jump",
    Desc = "Allows repeated jumps while enabled.",
    Value = Config.InfiniteJump,
    Callback = function(v) setConfig("InfiniteJump", v) end,
})
addToggle(PlayerTab, {
    Title = "Noclip",
    Desc = "Disables character collision using a cached part list.",
    Value = Config.NoClip,
    Callback = function(v)
        setConfig("NoClip", v)
        rebuildCharParts()
    end,
})
addButton(PlayerTab, {
    Title = "Refresh Character Cache",
    Desc = "Refreshes cached body parts used by movement systems.",
    Callback = rebuildCharParts,
})

addSection(PlayerTab, {
    Title = "World Teleports",
    Desc = "Quick teleports to common world objects when they exist.",
    Icon = "map-pin",
})
local function teleportWorkspaceModel(modelName, y, z)
    local model = workspace:FindFirstChild(modelName)
    if model then
        teleportTo(model:GetPivot() * CFrame.new(0, y or 5, z or 8))
    else
        notify("Teleport", modelName .. " was not found.", 2.5, "map-pin")
    end
end
addButton(PlayerTab, {
    Title = "Teleport: Seed Collector",
    Desc = "Teleports near the Seed Collector model.",
    Callback = function() teleportWorkspaceModel("SeedCollector", 5, 8) end,
})
addButton(PlayerTab, {
    Title = "Teleport: Pet Merchant",
    Desc = "Teleports near the Pet Merchant model.",
    Callback = function() teleportWorkspaceModel("PetMerchant", 5, 10) end,
})
addButton(PlayerTab, {
    Title = "Teleport: Friend-O-Tron",
    Desc = "Teleports near the Friend-O-Tron model.",
    Callback = function() teleportWorkspaceModel("FriendOTron", 5, 10) end,
})

-- ======================== Settings ========================
addSection(SettingsTab, {
    Title = "Configuration",
    Desc = "Save, reload, or safely unload the current runtime.",
    Icon = "save",
})
addToggle(SettingsTab, {
    Title = "Skip Money Check",
    Desc = "Allows purchase remotes to run without checking your local cash display first.",
    Value = Config.SkipMoneyCheck,
    Callback = function(v) setConfig("SkipMoneyCheck", v) end,
})
addButton(SettingsTab, {
    Title = "Save Config",
    Desc = "Saves all current DYHUB settings to your executor workspace.",
    Callback = function()
        saveConfigNow()
        notify("Config", "Saved successfully.", 2, "save")
    end,
})
addButton(SettingsTab, {
    Title = "Reload Config",
    Desc = "Reloads saved settings. Re-run the script to refresh displayed UI values.",
    Callback = function()
        loadConfig()
        notify("Config", "Reloaded. Re-run script to refresh UI values.", 3, "refresh-cw")
    end,
})
addButton(SettingsTab, {
    Title = "Unload Script",
    Desc = "Stops all DYHUB loops and disconnects runtime connections.",
    Callback = function()
        Runtime:Destroy()
        notify("DYHUB", "Runtime unloaded.", 2, "power")
    end,
})

addSection(SettingsTab, {
    Title = "Server",
    Desc = "Reconnect, server hop, or join a specific server JobId.",
    Icon = "server",
})
addToggle(SettingsTab, {
    Title = "Auto Reconnect",
    Desc = "Automatically rejoins if Roblox shows a disconnect prompt.",
    Value = Config.AutoReconnect,
    Callback = function(v) setConfig("AutoReconnect", v) end,
})
addButton(SettingsTab, {
    Title = "Rejoin Server",
    Desc = "Rejoins the current place immediately.",
    Callback = rejoinServer,
})
addButton(SettingsTab, {
    Title = "Server Hop",
    Desc = "Teleports to the same place for a fresh server attempt.",
    Callback = serverHop,
})
SettingsTab:Paragraph({
    Title = "Current Server",
    Desc = "JobId: " .. tostring(game.JobId),
})
local targetServerJobId = ""
addInput(SettingsTab, {
    Title = "Target Server ID",
    Desc = "Paste a JobId, then press Teleport to Server ID.",
    Placeholder = "Paste JobId here",
    Value = "",
    Callback = function(v) targetServerJobId = tostring(v or "") end,
})
addButton(SettingsTab, {
    Title = "Teleport to Server ID",
    Desc = "Teleports to the exact server JobId entered above.",
    Callback = function()
        if targetServerJobId ~= "" then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServerJobId, LocalPlayer)
        else
            notify("Server", "Please enter a valid JobId first.", 2.5, "server")
        end
    end,
})

Window:SelectTab(1)

--// Central optimized loops
spawnLoop("farm", 0.25, function()
    local farm = Config.MasterFarm or Config.AutoPlant
    if farm then
        plantOnce()
        task.wait(tonumber(Config.PlantDelay) or 0.35)
    end
end, 2.0)

spawnLoop("farm-upgrades", 2.0, function()
    if Config.MasterFarm or Config.AutoUpgradePlants then upgradePlantsOnce() end
    if Config.MasterFarm or Config.AutoUnlockFarmPlots then unlockPlotsOnce() end
    if Config.MasterFarm or Config.AutoSellCrates then sellCratesOnce() end
    if Config.AutoCompost or Config.AutoCompostAllSeeds then compostOnce() end
    if Config.AutoPullComposterLever then
        pullComposterLeverOnce()
        task.wait(tonumber(Config.PullLeverDelay) or 2)
    end
end, 2.5)

spawnLoop("seed-roll", 1.0, function()
    connectRollEvent()

    local wantsBuy = Config.AutoBuyAllRolledSeeds or Config.AutoBuySelectedRolledSeeds or Config.AutoBuyByRarity or Config.AutoBuyAnyTranscended
    local boughtFromWorld = false
    if wantsBuy then
        boughtFromWorld = pollAndBuyRolledSeeds()
    end

    if Config.AutoRollSeeds or (wantsBuy and not boughtFromWorld) then
        rollSeedsOnce()
        task.wait(tonumber(Config.RollDelay) or 2.5)
    end

    if Config.AutoOpenSeedPacks then
        openSeedPackOnce()
        task.wait(1.5)
    end
end, 3.0)

spawnLoop("upgrades", 1.5, function()
    if Config.AutoUpgradeFarm then upgradeFarmOnce() end
    if Config.AutoUpgradeSeedLuck then upgradeSeedLuckOnce() end
    if Config.AutoUpgradeSeedRolls then upgradeSeedRollsOnce() end
    if Config.AutoUpgradePlot then plotUpgradeOnce() end
end, 3.5)

spawnLoop("fertilizer", 3.0, function()
    if Config.AutoFertilize then fertilizeOnce() end
end, 4.0)

spawnLoop("shop", 5.0, function()
    if Config.AutoBuyAllGears or Config.AutoBuySelectedGears then buySelectedGearsOnce() end
    if Config.AutoUnlockEggSlots then unlockEggSlotsOnce() end
    if Config.AutoBuyAllEggs or Config.AutoBuySelectedEggs then
        for _, slot in ipairs(getEggSlots()) do
            if Config.AutoBuyAllEggs or isSelected(Config.TargetEggs, slot.Name) or isSelected(Config.TargetEggs, "Podium " .. tostring(slot.Slot)) then
                buyEgg(slot)
                task.wait(0.25)
            end
        end
    end
    if Config.AutoHatchEggs then autoHatchOnce() end
end, 4.5)

spawnLoop("events", 1.0, function()
    if Config.AutoPlantRush then plantRushShootOnce(); task.wait(0.15) end
    if Config.AutoClaimPlantRushDrops then claimPlantRushDropsOnce(); task.wait(0.5) end
    if Config.AutoCollectHoneycombs then collectHoneycombsOnce(); task.wait(1) end
    if Config.AutoSubmitHoneyToken then submitHoneyTokenOnce(); task.wait(1) end
    if Config.AutoCollectAlienDrops then collectAlienDropsOnce(); task.wait(1) end
    if Config.AutoSubmitSeedsToCollector or Config.AutoSubmitAllSeedsToCollector then submitCollectorSeedOnce(); task.wait(1) end
end, 5.0)

spawnLoop("rewards", 30.0, function()
    if Config.AutoDailyRewards then claimDailyRewardsOnce() end
    if Config.AutoPlaytimeRewards then claimPlaytimeRewardsOnce() end
    if Config.AutoGroupReward then claimGroupRewardOnce() end
    if Config.AutoUpgradePets then autoUpgradePetsOnce() end
    if Config.AutoSellPets then autoSellPetsOnce() end
end, 6.0)

spawnLoop("auto-reconnect", 5.0, function()
    if not Config.AutoReconnect then return end
    local overlay = CoreGui:FindFirstChild("RobloxPromptGui")
    overlay = overlay and overlay:FindFirstChild("promptOverlay")
    local prompt = overlay and overlay:FindFirstChild("ErrorPrompt")
    if prompt then
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end, 7.0)

task.defer(function()
    task.wait(1)
    notify("DYHUB Loaded", "loaded without startup-heavy scans.", 3, "check-circle")
    log("DYHUB script loaded |", ver)
end)
