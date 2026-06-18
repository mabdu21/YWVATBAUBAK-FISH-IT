-- v123
if getgenv and getgenv()._GAG2_Stop then
    pcall(getgenv()._GAG2_Stop)
    task.wait(0.3)
end

local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/mabdu21/YWVATBAUBAK-FISH-IT/refs/heads/main/uaiui.lua"))()

-- per-instance kill switch + tracked connections (LOCAL so two copies don't share it)
local stopped = false
local hubConnections = {}

-- // ========================================== \\ --
-- //          GLOBAL SERVICES & VARIABLES       \\ --
-- // ========================================== \\ --

Players = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
Workspace = game:GetService("Workspace")
CollectionService = game:GetService("CollectionService")
HttpService = game:GetService("HttpService")

LocalPlayer = Players.LocalPlayer
GameName = "Grow a Garden 2"

-- // ========================================== \\ --
-- //          PRIORITY SYSTEM                   \\ --
-- // ========================================== \\ --

ActivityPriority = {
    currentActivity = nil,
    activities = {
        FieldGuard = 150,
        WipePlot = 135,
        AutoFavorite = 130,
        AutoSteal = 120,
        MapSeed = 110,
        AutoSell = 100,
        AutoBuyGear = 90,
        AutoBuyCrate = 88,
        AutoBuySeed = 80,
        AutoEgg = 76,
        AutoCrate = 75,
        AutoPack = 74,
        AutoSprinkler = 65,
        AutoWater = 60,
        AutoBuyPets = 56,
        AutoSellPets = 54,
        AutoEquipPets = 52,
        AutoPetSlot = 50,
        AutoSkill = 48,
        AutoExpand = 45,
        AutoDaily = 44,
        AutoMailClaim = 43,
        AutoMailSend = 42,
        AutoPlant = 40,
        AutoCollectSeed = 35,
        AutoCollect = 30,
        AutoHarvest = 20
    }
}

function ActivityPriority:CanStart(activityName)
    if not self.currentActivity then return true end
    local currentPriority = self.activities[self.currentActivity] or 0
    local newPriority = self.activities[activityName] or 0
    return newPriority >= currentPriority
end

function ActivityPriority:SetActivity(activityName)
    if activityName == nil then self.currentActivity = nil; return true end
    if self:CanStart(activityName) then self.currentActivity = activityName; return true end
    return false
end

function ActivityPriority:ClearActivity(activityName)
    if self.currentActivity == activityName then self.currentActivity = nil end
end

-- // ========================================== \\ --
-- //          NETWORKING (PACKET) REFS          \\ --
-- // ========================================== \\ --

Networking = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Networking"))

-- Safe resolver: returns nil (not an error) if a namespace/action is missing, so a packet
-- that doesn't exist in this version of the game can never crash the script at load.
function pkt(...)
    local cur = Networking
    for _, k in ipairs({ ... }) do
        if type(cur) ~= "table" then return nil end
        cur = cur[k]
    end
    return cur
end

-- farm
PurchaseSeed    = pkt("SeedShop", "PurchaseSeed")        -- (seedName)
PurchaseGear    = pkt("GearShop", "PurchaseGear")        -- (itemName)
PlantSeed       = pkt("Plant", "PlantSeed")              -- (pos, seedName, tool)
CollectFruit    = pkt("Garden", "CollectFruit")          -- (plantId, fruitId)
SellAll         = pkt("NPCS", "SellAll")                 -- () -> {Success, SoldCount, SellPrice}
ExpandGarden    = pkt("Actions", "ExpandGarden")         -- ()
CheckDailyDeal  = pkt("NPCS", "CheckDailyDeal")          -- ()
UseDailyDealAll = pkt("NPCS", "UseDailyDealAll")         -- ()
-- boosts
PlaceSprinkler  = pkt("Place", "PlaceSprinkler")         -- (pos, name, tool, plotId)
UseWateringCan  = pkt("WateringCan", "UseWateringCan")   -- (pos, name, tool)
SpendSkillPoint = pkt("SkillPoints", "SpendSkillPoint")  -- (stat)
-- pets
GetEquippedPets    = pkt("Pets", "GetEquippedPets")
RequestEquipByName = pkt("Pets", "RequestEquipByName")        -- LEGACY: does NOT equip on live (verified 2026-06-15)
RequestToggleFollower = pkt("Pets", "RequestToggleFollower")  -- THE real equip/unequip: toggle a pet by its UUID
RequestPetSlot     = pkt("Pets", "RequestPurchasePetSlot")
WildPetTame        = pkt("Pets", "WildPetTame")
SellPet            = pkt("NPCS", "SellPet")
-- eggs / crates / packs
OpenEgg         = pkt("Egg", "OpenEgg")
OpenCrate       = pkt("Crate", "OpenCrate")
OpenSeedPack    = pkt("SeedPack", "OpenSeedPack")
ClickPack       = pkt("SeedPack", "ClickPack")          -- claim a spawned seed pack by id (owner fix)
-- steal
BeginSteal      = pkt("Steal", "BeginSteal")             -- (ownerUserId, plantId, fruitId)
CompleteSteal   = pkt("Steal", "CompleteSteal")          -- ()
StealStarted    = pkt("Steal", "StealStarted")           -- OnClientEvent(thiefPlayer) — server tells the VICTIM
StealCancelled  = pkt("Steal", "StealCancelled")         -- OnClientEvent(thiefPlayer)
-- crates / favorites
PurchaseCrate   = pkt("CrateShop", "PurchaseCrate")      -- (crateName)
SetFruitFavorite = pkt("Backpack", "SetFruitFavorite")   -- (fruitId, bool)
-- selective sell / bids (per-fruit; bulk pack is server-side, see helpers)
SellFruit       = pkt("NPCS", "SellFruit")               -- (fruitId) -> {Success, SellPrice, Reason?}
GetFruitBid     = pkt("NPCS", "GetFruitBid")             -- (fruitId) -> {CurrentOffer, BidPrice, BaseValue}
-- mail / mailbox
MailOpenInbox   = pkt("Mailbox", "OpenInbox")            -- () -> { [giftId] = payload }
MailClaim       = pkt("Mailbox", "Claim")                -- (giftId) -> (ok, msg)
MailDecline     = pkt("Mailbox", "Decline")              -- (giftId)
MailLookup      = pkt("Mailbox", "LookupPlayer")         -- (username) -> (userId, displayName)
MailSendBatch   = pkt("Mailbox", "SendBatch")            -- (userId, items{{Category,ItemKey,Count}}, note) -> (ok, msg)
MailIndexProbe  = pkt("Mailbox", "IndexProbe")           -- () -> number
-- wipe plot + field guard (shovel)
UseShovel       = pkt("Shovel", "UseShovel")             -- (plantId, fruitId, shovelName, tool)
SwingShovel     = pkt("Shovel", "SwingShovel")           -- ()
HitPlayer       = pkt("Shovel", "HitPlayer")             -- (targetUserId)  server: dist<=12 & facing dot>=0.3

-- // ========================================== \\ --
-- //          FEATURE STATE                     \\ --
-- // ========================================== \\ --

-- farm
autoPlantEnabled = false
selectedPlantSeeds = {}
plantSpacing = 4
plantInterval = 5

autoHarvestEnabled = false
harvestInterval = 0.25

autoSellEnabled = false
sellInterval = 15

autoBuySeedEnabled = false
selectedSeeds = {}
buySeedInterval = 5
buySeedPerTick = 8

autoBuyGearEnabled = false
selectedGear = {}
buyGearInterval = 10

autoExpandEnabled = false
autoDailyEnabled = false

-- master auto farm / auto action selector
autoFarmEnabled = false
selectedAutoFarmActions = {}
autoFarmActionOptions = {
    "Auto Plants",
    "Auto Harvest",
    "Auto Sell",
    "Auto Buy Seeds",
    "Auto Buy Pets",
    "Auto Buy Gears",
    "Auto Buy Crates",
    "Auto Open Eggs",
    "Auto Open Crates",
    "Auto Open Seed Packs",
    "Auto Expand Garden",
    "Auto Daily Deals",
    "Auto Equip Pets",
    "Auto Buy Pet Slots",
    "Auto Place Sprinklers",
    "Auto Watering Can",
    "Auto Spend Skill Points"
}

-- boosts
autoSprinklerEnabled = false
sprinklerInterval = 30

autoWaterEnabled = false
waterInterval = 8

autoSkillEnabled = false
selectedSkills = {}

-- pets (teleport to wild pets is automatic)
autoEquipPetsEnabled = false
autoPetSlotEnabled = false
autoBuyPetsEnabled = false
maxPetPrice = 25000
petBuyInterval = 5
autoSellPetsEnabled = false
selectedSellPets = {}

-- eggs / crates / packs
autoEggEnabled = false
autoCrateEnabled = false
autoPackEnabled = false
openInterval = 4

-- steal (teleport is automatic)
autoStealEnabled = false
stealReturnHome = true
stealDelay = 0.05

-- map events (anti-afk is always on, no toggle)
autoSeedEventEnabled = true

-- cosmetic crates (props shop)
autoBuyCrateEnabled = false
selectedCrates = {}
crateBuyInterval = 10

-- dropped item collection (teleport-to-collect)
autoCollectSeedsEnabled = false
autoCollectAcornsEnabled = false
autoCollectSeedGoldRainbowEnabled = false
collectSeedPromptCooldown = {}

-- favorites (protect from sell)
autoFavMutationEnabled = false
autoFavInventoryEnabled = false
autoFavFarmEnabled = false

-- pet filters (name + rarity); empty = no filter for that kind
selectedEquipPetNames = {}
selectedEquipPetRarities = {}
selectedTamePetNames = {}
selectedTamePetRarities = {}

-- remove the egg/crate roll animation UI
removeRollUiEnabled = false

-- // ---- NEW: competitor-parity + extra features state ---- //

-- granular auto-favorite (protect-from-sell filter; matched fruit get favorited at harvest + in a sweep)
autoFavFilterEnabled = false
favMinWeight = 0            -- favorite if weight >= this (0 = ignore weight)
favMinPrice = 0             -- favorite if computed sell value >= this (0 = ignore price)
selectedFavMutations = {}   -- favorite if fruit carries one of these mutations
selectedFavFruits = {}      -- favorite these fruit types (by name)

-- selective auto-sell. Bulk pack is server-side -> "Selective" = favorite-protect the keepers then SellAll.
sellMode = "All"            -- "All" | "Selective"

-- selective auto-harvest (skip = leave on plant)
ignoredHarvestMutations = {}   -- don't harvest fruit with these mutations
ignoredHarvestTypes = {}       -- don't harvest these fruit types (CorePartName)
minHarvestWeight = 0           -- only harvest fruit with weight >= this (0 = harvest all; best-effort)

-- wipe plot (shovel; destructive)
selectedWipeSeeds = {}      -- only wipe plants whose SeedName is selected (empty = wipe ALL)
wipeBusy = false

-- shop buy mode
seedBuyMode = "Selected"    -- "Selected" | "All"
gearBuyMode = "Selected"

-- event-seed type filter (empty = all). matches GoldSeed/RainbowSeed attrs
selectedEventSeedTypes = {}

-- // ---- full-parity config state (per-item caps, blacklists, gear-use, loadout) ---- //
seedBuyLimits = {}          -- {SeedName=maxBuysPerPass} overrides buySeedPerTick for that seed
plantSeedLimits = {}        -- {SeedName=maxPlantedPerPass} (nil/absent = unlimited)
plantSeedCount = {}         -- runtime per-seed planted tally (reset each pass)
maxAutoPlant = 0            -- cap on total plants placed per pass (0 = fill all free cells)
plantBlacklist = {}         -- seed names to never auto-plant (wins over selectedPlantSeeds)
selectedFavByFruit = {}     -- {FruitName={Mutation,...}} keep fruit only if it has one of these (empty list = any mutation)
expandTargetCount = 0       -- plot expansions to buy (0 = unlimited)
expandDoneCount = 0
targetPetSlots = 0          -- pet-slot purchases to make this session (0 = unlimited)
petSlotDoneCount = 0
petBuyCaps = {}             -- {PetName=maxToTame} lifetime tame cap per pet
petBuyCount = {}            -- runtime tally of tamed pets by name
gearsToUse = {}             -- gear names to actively deploy (Sprinkler / Watering Can only; no generic gear-use remote)
equipLoadout = {}           -- ordered {{name,level,slot},...}; slot is server-controlled so list order approximates slots

-- FPS boost
fpsBoostEnabled = false      -- light: strip post-fx + shadows + low quality
fpsMaxEnabled = false        -- aggressive: also kill textures/decals/particles, plastic everything
fpsCap = 0                   -- setfpscap value (0 = uncapped). NOTE low cap slows frame-bound harvest
fpsBoostApplied = false

-- mail
autoMailClaimEnabled = false
mailClaimInterval = 30
mailSendUsername = ""
mailSendUserId = nil
mailSendCategory = nil
selectedMailItems = {}      -- chosen item keys for the current category
mailSendNote = ""
mailSendCount = 1
autoMailSendEnabled = false
mailSendInterval = 60
mailInboxCountCache = 0
mailSendUsernames = {}      -- multi-recipient overflow list (rejected items spill to next user); empty = use mailSendUsername
mailItemCounts = {}         -- {ItemKey=count} per-item counts; overrides global mailSendCount
mailSendByCategory = {}     -- {Category={ItemKey=count}} cross-category one-shot; overrides single category/selectedMailItems

-- steal priority + field guard
stealMostExpensive = true   -- steal highest-value fruit first
fieldGuardEnabled = false
guardThieves = {}           -- [Player] = lastSeen os.clock()
guardHitCooldown = {}       -- [Player] = last HitPlayer os.clock()

-- discord webhook
webhookUrl = ""
webhookReportEnabled = false
webhookReportInterval = 5
webhookTameEnabled = false
selectedWebhookTameRarities = {}
webhookMutationEnabled = false
webhookSeenMutations = {}
webhookTamePetNames = {}    -- only ping tame webhook for these pet names (empty = any)
webhookSeedNames = {}       -- only ping mutation webhook for these mutation/fruit names (empty = any)
webhookNote = ""            -- appended as a "Note" field on every embed
webhookDiscordId = ""       -- Discord user id to @ping (sent as message content)
soldTotal = 0
hubStartTime = os.time()

-- on-screen status overlay (custom black panel, MacLib-independent)
statusOverlayEnabled = false
ovGui = nil                 -- ScreenGui handle
ovRefs = nil                -- table of label refs to update
ovBalSamples = {}           -- {{t=clock, bal=sheckles}, ...} for income/min trend

-- // ========================================== \\ --
-- //          HELPERS                           \\ --
-- // ========================================== \\ --

-- Responsive wait that ALWAYS yields at least one tick (so a disabled loop never busy-spins)
function waitInterval(getEnabled, seconds)
    local waited = 0
    while waited < seconds do
        task.wait(0.4)
        waited = waited + 0.4
        if not getEnabled() then return end
    end
end

-- MacLib multi-dropdown returns a dict { name = true }; convert to an array
function toArray(dict)
    local out = {}
    if type(dict) == "table" then
        for name, on in pairs(dict) do
            if on == true then out[#out + 1] = name elseif type(on) == "string" then out[#out + 1] = on end
        end
    end
    return out
end

function autoFarmHas(actionName)
    if not autoFarmEnabled then return false end
    for _, name in ipairs(selectedAutoFarmActions) do
        if name == actionName then return true end
    end
    return false
end
function autoPlantActive() return autoPlantEnabled or autoFarmHas("Auto Plants") end
function autoHarvestActive() return autoHarvestEnabled or autoFarmHas("Auto Harvest") end
function autoSellActive() return autoSellEnabled or autoFarmHas("Auto Sell") end
function autoBuySeedActive() return autoBuySeedEnabled or autoFarmHas("Auto Buy Seeds") end
function autoBuyGearActive() return autoBuyGearEnabled or autoFarmHas("Auto Buy Gears") end
function autoBuyCrateActive() return autoBuyCrateEnabled or autoFarmHas("Auto Buy Crates") end
function autoBuyPetsActive() return autoBuyPetsEnabled or autoFarmHas("Auto Buy Pets") end
function autoEquipPetsActive() return autoEquipPetsEnabled or autoFarmHas("Auto Equip Pets") end
function autoPetSlotActive() return autoPetSlotEnabled or autoFarmHas("Auto Buy Pet Slots") end
function autoEggActive() return autoEggEnabled or autoFarmHas("Auto Open Eggs") end
function autoCrateActive() return autoCrateEnabled or autoFarmHas("Auto Open Crates") end
function autoPackActive() return autoPackEnabled or autoFarmHas("Auto Open Seed Packs") end
function autoSprinklerActive() return autoSprinklerEnabled or autoFarmHas("Auto Place Sprinklers") end
function autoWaterActive() return autoWaterEnabled or autoFarmHas("Auto Watering Can") end
function autoSkillActive() return autoSkillEnabled or autoFarmHas("Auto Spend Skill Points") end
function autoExpandActive() return autoExpandEnabled or autoFarmHas("Auto Expand Garden") end
function autoDailyActive() return autoDailyEnabled or autoFarmHas("Auto Daily Deals") end

-- local-player replica (Sheckles / Inventory)
local _replica
function replica()
    if _replica then return _replica end
    local ok, psc = pcall(function() return require(ReplicatedStorage.ClientModules.PlayerStateClient) end)
    if ok and psc and psc.WaitForLocalReplica then
        local ok2, r = pcall(function() return psc:WaitForLocalReplica(30) end)
        if ok2 and r then _replica = r end
    end
    return _replica
end
function pdata() local r = replica(); return (r and r.Data) or {} end
function getSheckles() return tonumber(pdata().Sheckles) or 0 end
function inv(category) local i = pdata().Inventory; return (i and i[category]) or {} end
-- normalize an inventory category to { name = totalCount } (shape varies)
function invNames(category)
    local out = {}
    for k, v in pairs(inv(category)) do
        local name, count
        if type(v) == "table" then
            name = v.Name or v.ItemName or v.Type or (type(k) == "string" and not v.Name and k) or tostring(k)
            count = tonumber(v.Count) or tonumber(v.Amount) or 1
        elseif type(v) == "number" then
            name, count = tostring(k), v
        else
            name, count = tostring(k), 1
        end
        if name then out[name] = (out[name] or 0) + (count or 1) end
    end
    return out
end
function fmt(n)
    n = tonumber(n) or 0
    if n >= 1e9 then return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.2fK", n / 1e3)
    else return tostring(math.floor(n)) end
end

-- catalogs for the dropdowns
function seedNames()
    local out = {}
    local ok, data = pcall(function() return require(ReplicatedStorage.SharedModules.SeedData) end)
    if ok and type(data) == "table" then
        local rows = {}
        for _, e in pairs(data) do
            if type(e) == "table" and e.SeedName and e.RestockShop ~= false and e.PurchasePrice then
                rows[#rows + 1] = { name = e.SeedName, price = tonumber(e.PurchasePrice) or 0 }
            end
        end
        table.sort(rows, function(a, b) return a.price < b.price end)
        for _, r in ipairs(rows) do out[#out + 1] = r.name end
    end
    return out
end
function seedPrice(name)
    local ok, data = pcall(function() return require(ReplicatedStorage.SharedModules.SeedData) end)
    if ok and type(data) == "table" then
        for _, e in pairs(data) do
            if type(e) == "table" and e.SeedName == name then return tonumber(e.PurchasePrice) or 0 end
        end
    end
    return 0
end
function gearNames()
    local out, seen = {}, {}
    local ok, data = pcall(function() return require(ReplicatedStorage.SharedModules.GearShopData) end)
    if ok and data and type(data.Data) == "table" then
        for _, e in pairs(data.Data) do
            if type(e) == "table" and e.ItemName and not e.RobuxOnly and not seen[e.ItemName] then
                seen[e.ItemName] = true; out[#out + 1] = e.ItemName
            end
        end
    end
    if #out == 0 then
        local ok2, items = pcall(function() return ReplicatedStorage.StockValues.GearShop.Items end)
        if ok2 and items then for _, c in ipairs(items:GetChildren()) do out[#out + 1] = c.Name end end
    end
    table.sort(out)
    return out
end
function stockOf(shop, name)
    local ok, items = pcall(function() return ReplicatedStorage.StockValues[shop].Items end)
    if not ok or not items then return nil end
    local v = items:FindFirstChild(name)
    return v and tonumber(v.Value) or 0
end

-- plot / world
function myPlot()
    local id = LocalPlayer:GetAttribute("PlotId")
    local gardens = Workspace:FindFirstChild("Gardens")
    if not (id and gardens) then return nil end
    return gardens:FindFirstChild("Plot" .. tostring(id))
end
function myPlotId() return LocalPlayer:GetAttribute("PlotId") end
function humanoid() local c = LocalPlayer.Character; return c and c:FindFirstChildOfClass("Humanoid") end
function hrpNow() local c = LocalPlayer.Character; return c and c:FindFirstChild("HumanoidRootPart") end
function fruitCount() return tonumber(LocalPlayer:GetAttribute("FruitCount")) or 0 end
function maxFruitCap() return tonumber(LocalPlayer:GetAttribute("MaxFruitCapacity")) or 100 end
function isNight() local n = ReplicatedStorage:FindFirstChild("Night"); return n and n.Value == true end

-- tools in Backpack + Character carrying attribute `attr` (optionally matching a name)
function toolsByAttr(attr, wantName)
    local out = {}
    local function scan(c)
        if not c then return end
        for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute(attr) ~= nil then
                if (not wantName) or t:GetAttribute(attr) == wantName or t.Name == wantName then out[#out + 1] = t end
            end
        end
    end
    scan(LocalPlayer:FindFirstChildOfClass("Backpack")); scan(LocalPlayer.Character)
    return out
end
function heldToolByAttr(attr)
    local c = LocalPlayer.Character
    local t = c and c:FindFirstChildWhichIsA("Tool")
    if t and t:GetAttribute(attr) ~= nil then return t end
    return nil
end
-- equip a tool by attribute (and optional name); waits for the equip to land, with a parent fallback
function equipByAttr(attr, wantName)
    local t = heldToolByAttr(attr)
    if t and ((not wantName) or t:GetAttribute(attr) == wantName) then return t end
    t = toolsByAttr(attr, wantName)[1]
    if not t then return nil end
    local hum = humanoid(); if not hum then return nil end
    pcall(function() hum:EquipTool(t) end)
    task.wait(0.22)
    if heldToolByAttr(attr) then return heldToolByAttr(attr) end
    local char = LocalPlayer.Character
    if char then pcall(function() t.Parent = char end); task.wait(0.15) end
    return heldToolByAttr(attr)
end

-- PlantArea-tagged parts inside MY plot
function myPlantAreas()
    local out, plot = {}, myPlot()
    if not plot then return out end
    for _, p in ipairs(CollectionService:GetTagged("PlantArea")) do
        if p:IsA("BasePart") and p:IsDescendantOf(plot) then out[#out + 1] = p end
    end
    return out
end
-- raycast-confirmed grid of world positions over my PlantArea surfaces
function plantGrid(spacing)
    local pts, areas = {}, myPlantAreas()
    spacing = math.max(2, spacing or 4)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = areas
    for _, area in ipairs(areas) do
        local cf, size = area.CFrame, area.Size
        local topY = (cf * CFrame.new(0, size.Y / 2, 0)).Position.Y
        local dx = -size.X / 2 + spacing / 2
        while dx <= size.X / 2 - spacing / 2 do
            local dz = -size.Z / 2 + spacing / 2
            while dz <= size.Z / 2 - spacing / 2 do
                local w = (cf * CFrame.new(dx, 0, dz)).Position
                local hit = Workspace:Raycast(Vector3.new(w.X, topY + 10, w.Z), Vector3.new(0, -40, 0), params)
                if hit then pts[#pts + 1] = hit.Position end
                dz = dz + spacing
            end
            dx = dx + spacing
        end
    end
    return pts
end
function existingPlantPositions()
    local out, plot = {}, myPlot()
    local plants = plot and plot:FindFirstChild("Plants")
    if not plants then return out end
    for _, m in ipairs(plants:GetChildren()) do
        local ok, piv = pcall(function() return m:GetPivot().Position end)
        if ok then out[#out + 1] = piv end
    end
    return out
end
function myBasePos()
    local plot = myPlot(); if not plot then return nil end
    -- the game's own steal-return arrow points to Plot<id>.SpawnPoint — that's the real deposit spot
    local sp = plot:FindFirstChild("SpawnPoint")
    if sp and sp:IsA("BasePart") then return sp.Position + Vector3.new(0, 3, 0) end
    for _, tag in ipairs({ "GardenTotalArea", "GardenZone" }) do
        for _, p in ipairs(CollectionService:GetTagged(tag)) do
            if p:IsA("BasePart") and p:IsDescendantOf(plot) then
                return Vector3.new(p.Position.X, p.Position.Y - p.Size.Y / 2 + 5, p.Position.Z)
            end
        end
    end
    local ok, piv = pcall(function() return plot:GetPivot().Position end)
    return ok and piv or nil
end
-- teleport to a position, run fn, restore the original CFrame
function atPosition(pos, fn)
    local hrp = hrpNow(); if not hrp then return false end
    local saved = hrp.CFrame
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
    task.wait(0.45)
    local ok = pcall(fn)
    task.wait(0.15)
    if hrp and hrp.Parent then hrp.CFrame = saved end
    return ok
end

-- carrier model holding PlantId/FruitId/UserId for a prompt
function promptCarrier(prompt)
    local node = prompt.Parent
    while node and node ~= Workspace and node:GetAttribute("PlantId") == nil do node = node.Parent end
    if node and node:GetAttribute("PlantId") ~= nil then return node end
    return prompt:FindFirstAncestorWhichIsA("Model")
end
function ripeHarvests()
    local out = {}
    for _, pr in ipairs(CollectionService:GetTagged("HarvestPrompt")) do
        if pr:IsA("ProximityPrompt") and pr.Enabled and pr:IsDescendantOf(Workspace) then
            local m = promptCarrier(pr)
            local pid = m and m:GetAttribute("PlantId")
            if pid then
                local uid = tonumber(m:GetAttribute("UserId"))
                if uid == nil or uid == LocalPlayer.UserId then
                    local pos
                    local pp = pr.Parent
                    if pp and pp:IsA("BasePart") then pos = pp.Position
                    elseif m then local ok, pv = pcall(function() return m:GetPivot().Position end); if ok then pos = pv end end
                    out[#out + 1] = { plantId = tostring(pid), fruitId = tostring(m:GetAttribute("FruitId") or ""), model = m, pos = pos }
                end
            end
        end
    end
    return out
end
function stealable()
    local out = {}
    for _, pr in ipairs(CollectionService:GetTagged("StealPrompt")) do
        if pr:IsA("ProximityPrompt") and pr.Enabled and pr:IsDescendantOf(Workspace) then
            local m = promptCarrier(pr)
            local pid = m and m:GetAttribute("PlantId")
            if pid then
                local pos
                local pp = pr.Parent
                if pp and pp:IsA("BasePart") then pos = pp.Position
                elseif m then local ok, pv = pcall(function() return m:GetPivot().Position end); if ok then pos = pv end end
                out[#out + 1] = {
                    plantId = tostring(pid),
                    fruitId = tostring(m:GetAttribute("FruitId") or ""),
                    owner = tonumber(m:GetAttribute("OwnerUserId")) or tonumber(m:GetAttribute("UserId")) or 0,
                    pos = pos,
                    model = m,
                }
            end
        end
    end
    return out
end
function wildPets()
    local out = {}
    local map = Workspace:FindFirstChild("Map")
    local ref = map and map:FindFirstChild("WildPetRef")
    if ref then for _, p in ipairs(ref:GetChildren()) do
        if p:IsA("BasePart") then
            out[#out + 1] = {
                part = p,
                name = p:GetAttribute("PetName"),
                price = tonumber(p:GetAttribute("Price")) or 0,
                owner = tonumber(p:GetAttribute("OwnerUserId")) or 0,
                pos = p.Position,
            }
        end
    end end
    return out
end
-- every pet species in the game (from PetData; skips its helper functions)
function allPetNames()
    local out = {}
    local ok, data = pcall(function() return require(ReplicatedStorage.SharedData.PetData) end)
    if ok and type(data) == "table" then
        for k, v in pairs(data) do
            if type(k) == "string" and type(v) == "table" then out[#out + 1] = k end
        end
    end
    table.sort(out)
    return out
end
function ownedPetNames()
    local names, seen = {}, {}
    local function add(nm) if nm and nm ~= "" and not seen[nm] then seen[nm] = true; names[#names + 1] = nm end end
    -- equipped pets (remote returns a list of { Name = ..., Id = ... })
    local ok, list = pcall(function() return GetEquippedPets:Fire() end)
    if ok and type(list) == "table" then
        for k, v in pairs(list) do
            if type(v) == "table" then add(v.Name or v.PetName or v.Type or v.Species)
            elseif type(v) == "string" then add(v)
            elseif type(k) == "string" then add(k) end
        end
    end
    -- unequipped pets stored in inventory
    for nm in pairs(invNames("Pets")) do add(nm) end
    -- unequipped pet tools in backpack / character
    for _, t in ipairs(toolsByAttr("PetId")) do add(t:GetAttribute("PetName") or t.Name) end
    table.sort(names)
    return names
end
-- owned but UNEQUIPPED pets as {id=uuid, name=Name} from the replica; equip = toggle-follower on this uuid
function unequippedPets()
    local out = {}
    for id, pd in pairs(inv("Pets")) do
        if type(pd) == "table" and pd.Equipped == false then
            out[#out + 1] = { id = pd.Id or id, name = pd.Name }
        end
    end
    return out
end
function equippedPetCount()
    local ok, list = pcall(function() return GetEquippedPets:Fire() end)
    if ok and type(list) == "table" then local n = 0; for _ in pairs(list) do n += 1 end; return n end
    return 0
end

-- sell all fruit; returns sold count (reads the server response)
function sellAllNow()
    local ok, res = pcall(function() return SellAll:Fire() end)
    if ok and type(res) == "table" and res.Success then
        local n = tonumber(res.SoldCount) or 0
        soldTotal = soldTotal + n
        return n
    end
    return 0
end

-- discord webhook helpers
function httpPost(url, body)
    local req = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
    if not req then return false end
    return (pcall(function()
        req({ Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end))
end
function sendWebhook(embed)
    if not webhookUrl or webhookUrl == "" then return end
    if webhookNote ~= "" then
        embed.fields = embed.fields or {}
        embed.fields[#embed.fields + 1] = { name = "Note", value = tostring(webhookNote), inline = false }
    end
    local payload = { embeds = { embed } }
    if webhookDiscordId ~= "" then payload.content = "<@" .. tostring(webhookDiscordId) .. ">" end
    local ok, body = pcall(function() return HttpService:JSONEncode(payload) end)
    if ok then httpPost(webhookUrl, body) end
end
function fmtRuntime(sec)
    sec = math.max(0, math.floor(sec))
    return string.format("%02d:%02d:%02d", math.floor(sec / 3600), math.floor((sec % 3600) / 60), sec % 60)
end

-- cosmetic crate names (props/crate shop)
function crateNames()
    local out, seen = {}, {}
    local ok, data = pcall(function() return require(ReplicatedStorage.SharedModules.CrateData) end)
    if ok and data and type(data.GetAllCrates) == "function" then
        local ok2, list = pcall(data.GetAllCrates)
        if ok2 and type(list) == "table" then
            for _, e in pairs(list) do
                local nm = (type(e) == "table" and (e.Name or e.CrateName)) or (type(e) == "string" and e)
                if nm and not seen[nm] then seen[nm] = true; out[#out + 1] = nm end
            end
        end
    end
    if #out == 0 then
        local ok3, items = pcall(function() return ReplicatedStorage.StockValues.CrateShop.Items end)
        if ok3 and items then for _, c in ipairs(items:GetChildren()) do out[#out + 1] = c.Name end end
    end
    table.sort(out)
    return out
end

-- fruit Tools in Backpack + Character (a fruit carries attributes Fruit + Id, optionally Mutation)
function fruitTools()
    local out = {}
    local function scan(c)
        if not c then return end
        for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and t:GetAttribute("Fruit") ~= nil and t:GetAttribute("Id") ~= nil then out[#out + 1] = t end
        end
    end
    scan(LocalPlayer:FindFirstChildOfClass("Backpack")); scan(LocalPlayer.Character)
    return out
end
-- fruit instances growing on my farm (models carrying an Id attribute under the plot)
function farmFruit()
    local out, plot = {}, myPlot()
    if not plot then return out end
    for _, d in ipairs(plot:GetDescendants()) do
        if d:GetAttribute("Id") ~= nil and (d:GetAttribute("Fruit") ~= nil or d:GetAttribute("FruitId") ~= nil) then
            out[#out + 1] = d
        end
    end
    return out
end
-- favorite/unfavorite a fruit by its Id attribute
function favoriteFruit(id, on)
    if not (SetFruitFavorite and id) then return end
    pcall(function() SetFruitFavorite:Fire(id, on and true or false) end)
end

-- pet rarity for a given pet name (PetData[name].Rarity is a string like "Common")
function petRarity(name)
    local ok, data = pcall(function() return require(ReplicatedStorage.SharedData.PetData) end)
    if ok and type(data) == "table" then
        local e = data[name]
        if type(e) == "table" then return tostring(e.Rarity or e.RarityName or "") end
    end
    return ""
end
-- every distinct rarity in the game (so the rarity dropdowns are always fully populated)
function knownRarities()
    local set = {}
    local ok, data = pcall(function() return require(ReplicatedStorage.SharedData.PetData) end)
    if ok and type(data) == "table" then
        for _, e in pairs(data) do
            if type(e) == "table" and e.Rarity ~= nil then set[tostring(e.Rarity)] = true end
        end
    end
    local out = {}; for r in pairs(set) do out[#out + 1] = r end; table.sort(out); return out
end
-- filter test: matches if name is selected OR its rarity is selected; both empty = match all
function petMatch(name, names, rarities)
    if #names == 0 and #rarities == 0 then return true end
    for _, n in ipairs(names) do if n == name then return true end end
    if #rarities > 0 then
        local r = petRarity(name)
        for _, rr in ipairs(rarities) do if rr == r then return true end end
    end
    return false
end

-- dropped items on the map matching a name substring; returns { {inst, pos}, ... }
function droppedItems(nameSubstr)
    local out = {}
    local folder = Workspace:FindFirstChild("DroppedItems")
    if not folder then return out end
    for _, d in ipairs(folder:GetChildren()) do
        if (not nameSubstr) or string.find(string.lower(d.Name), string.lower(nameSubstr), 1, true) then
            local ok, piv = pcall(function() return d:GetPivot().Position end)
            local pos = ok and piv or (d:IsA("BasePart") and d.Position)
            if pos then out[#out + 1] = { inst = d, pos = pos } end
        end
    end
    return out
end

-- Auto Collect Seed (Gold/Rainbow): server spawn locations with ProximityPrompt.
-- It scans every Part under workspace.Map.SeedPackSpawnServerLocations, so same-name Parts are handled safely.
collectSeedPromptFire = (function()
    local g = (getgenv and getgenv()) or {}
    return rawget(g, "fireproximityprompt") or fireproximityprompt
end)()
function collectSeedSpawnRoot()
    local map = Workspace:FindFirstChild("Map")
    return map and map:FindFirstChild("SeedPackSpawnServerLocations") or nil
end
function collectSeedPartFrom(inst)
    local root = collectSeedSpawnRoot()
    if not (root and inst) then return nil end
    local node = inst
    while node and node ~= Workspace do
        if node:IsA("BasePart") and node:IsDescendantOf(root) then return node end
        if node == root then break end
        node = node.Parent
    end
    return nil
end
function collectSeedType(node)
    while node and node ~= Workspace do
        local n = string.lower(tostring(node.Name or ""))
        if node:GetAttribute("GoldSeed") == true or string.find(n, "gold", 1, true) then return "Gold" end
        if node:GetAttribute("RainbowSeed") == true or string.find(n, "rainbow", 1, true) then return "Rainbow" end
        node = node.Parent
    end
    return "Unknown"
end
function collectSeedPromptValid(prompt)
    if not (prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt:IsDescendantOf(Workspace)) then return false end
    local root = collectSeedSpawnRoot()
    if not (root and prompt:IsDescendantOf(root)) then return false end
    local part = collectSeedPartFrom(prompt)
    if not (part and part.Parent) then return false end
    -- Unknown is allowed because some live builds only mark the server-location Part, not the rarity type.
    local ty = collectSeedType(part)
    return ty == "Gold" or ty == "Rainbow" or ty == "Unknown"
end
function collectSeedPromptPosition(prompt)
    local part = collectSeedPartFrom(prompt)
    if part then return part.Position, part end
    local parent = prompt and prompt.Parent
    if parent and parent:IsA("BasePart") then return parent.Position, parent end
    return nil, nil
end
function pressCollectSeedPrompt(prompt)
    if not collectSeedPromptValid(prompt) then return false end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = math.max(tonumber(prompt.MaxActivationDistance) or 0, 30)
    end)
    local ok = false
    for _ = 1, 2 do
        if not collectSeedPromptValid(prompt) then break end
        if collectSeedPromptFire then
            local fired = pcall(function() collectSeedPromptFire(prompt, 0) end)
            if not fired then fired = pcall(function() collectSeedPromptFire(prompt) end) end
            ok = ok or fired
        else
            local fired = pcall(function()
                prompt:InputHoldBegin()
                task.wait(0.05)
                prompt:InputHoldEnd()
            end)
            ok = ok or fired
        end
        task.wait(0.2)
    end
    return ok
end
function collectGoldRainbowSeedPrompts()
    local root = collectSeedSpawnRoot()
    if not root then return end
    local targets = {}
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("ProximityPrompt") and collectSeedPromptValid(d) then
            local pos, part = collectSeedPromptPosition(d)
            if pos then targets[#targets + 1] = { prompt = d, part = part, pos = pos } end
        end
    end
    table.sort(targets, function(a, b)
        local hrp = hrpNow()
        if not hrp then return false end
        return (a.pos - hrp.Position).Magnitude < (b.pos - hrp.Position).Magnitude
    end)
    for _, job in ipairs(targets) do
        if not autoCollectSeedGoldRainbowEnabled then break end
        if collectSeedPromptValid(job.prompt) then
            local key = job.part or job.prompt
            local last = collectSeedPromptCooldown[key]
            if not last or os.clock() - last >= 1.25 then
                local hrp = hrpNow()
                if hrp then
                    pcall(function() hrp.CFrame = CFrame.new(job.pos + Vector3.new(0, 3.5, 0)) end)
                    task.wait(0.16)
                    pressCollectSeedPrompt(job.prompt)
                    collectSeedPromptCooldown[key] = os.clock()
                    task.wait(0.5)
                end
            end
        end
    end
end

-- Auto-collect map seed events (Shooting Star pack carries a ClickDetector).
-- Teleport-to-then-click is automatic so the click always lands.
fireCD = (function()
    local g = (getgenv and getgenv()) or {}
    return rawget(g, "fireclickdetector") or fireclickdetector
end)()
local function eventSeedTypeOf(node)
    while node and node ~= Workspace do
        if node:GetAttribute("GoldSeed") == true then return "Gold" end
        if node:GetAttribute("RainbowSeed") == true then return "Rainbow" end
        node = node.Parent
    end
    return nil
end
function collectMapSeeds()
    local map = Workspace:FindFirstChild("Map")
    -- owner fix: spawned seed packs (Shooting Star: Rainbow/Gold/normal) carry a "SeedPack" id
    -- and are claimed via the ClickPack remote (teleport-then-claim). Type filter (Gold/Rainbow) kept.
    local client = map and map:FindFirstChild("SeedPackSpawnClient")
    if client then
        for _, sp in ipairs(client:GetChildren()) do
            local id = sp:GetAttribute("SeedPack")
            if id then
                local passes = true
                if #selectedEventSeedTypes > 0 then
                    local ty = eventSeedTypeOf(sp)
                    if ty and not inSet(selectedEventSeedTypes, ty) then passes = false end
                end
                if passes then
                    local hrp = hrpNow()
                    if hrp then
                        local ok, pos = pcall(function() return sp:GetPivot().Position end)
                        if ok then pcall(function() hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0)) end); task.wait(0.1) end
                    end
                    if ClickPack then pcall(function() ClickPack:Fire(id) end) end
                    task.wait(0.05)
                end
            end
        end
    end
    -- fallback: also fire any transient click detectors the game spawns for the pack (type-filtered)
    local conts = { client, Workspace:FindFirstChild("Temporary") }
    for _, cont in ipairs(conts) do
        if cont then
            for _, d in ipairs(cont:GetDescendants()) do
                if d:IsA("ClickDetector") and fireCD then
                    local passes = true
                    if #selectedEventSeedTypes > 0 then
                        local ty = eventSeedTypeOf(d)
                        if ty and not inSet(selectedEventSeedTypes, ty) then passes = false end
                    end
                    if passes then pcall(fireCD, d) end
                end
            end
        end
    end
end

-- // ---- NEW FEATURE HELPERS ---- //

function inSet(list, v)
    for _, x in ipairs(list) do if x == v then return true end end
    return false
end

-- mutation string may hold several joined by + or , ; test membership
function mutationStrHas(str, name)
    if not str or str == "" then return false end
    for tok in string.gmatch(tostring(str), "[^%+%,]+") do
        if tok:match("^%s*(.-)%s*$") == name then return true end
    end
    return false
end

-- catalogs for filter dropdowns
function mutationNames()
    local out = {}
    local ok, data = pcall(function() return require(ReplicatedStorage.SharedModules.MutationData) end)
    if ok and type(data) == "table" then
        local lookup = rawget(data, "Mutations") or data
        for k, v in pairs(lookup) do
            if type(k) == "string" and type(v) == "table" and v.PriceMultiplier then out[#out + 1] = k end
        end
    end
    if #out == 0 then out = { "Gold", "Rainbow", "Electric", "Frozen", "Bloodlit", "Chained", "Starstruck" } end
    table.sort(out)
    return out
end
function fruitTypeNames()
    local out = {}
    local ok, data = pcall(function() return require(ReplicatedStorage.SharedModules.SellValueData) end)
    if ok and type(data) == "table" then
        for k, v in pairs(data) do if type(k) == "string" and type(v) == "number" then out[#out + 1] = k end end
    end
    table.sort(out)
    return out
end

-- local sell-value mirror (matches server BaseValue; no remote)
local _fvc
function fruitValueCalc()
    if _fvc ~= nil then return _fvc end
    local ok, m = pcall(function() return require(ReplicatedStorage.SharedModules.FruitValueCalc) end)
    _fvc = (ok and type(m) == "function") and m or false
    return _fvc
end
function fruitToolValue(t)
    local calc = fruitValueCalc(); if not calc then return nil end
    local fn = t:GetAttribute("FruitName") or t:GetAttribute("Fruit")
    local ok, v = pcall(calc, fn, t:GetAttribute("SizeMultiplier") or 1, t:GetAttribute("Mutation"), LocalPlayer, t:GetAttribute("DecayAlpha"))
    return ok and tonumber(v) or nil
end

-- best-effort weight of an in-world (un-harvested) fruit MODEL via FruitVisualizerController
local _fviz
function fruitVisualizer()
    if _fviz ~= nil then return _fviz end
    local ok, m = pcall(function()
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        local c = ps and ps:FindFirstChild("Controllers")
        local mod = c and c:FindFirstChild("FruitVisualizerController")
        return mod and require(mod)
    end)
    _fviz = (ok and type(m) == "table") and m or false
    return _fviz
end
function fruitModelWeight(m)
    local fv = fruitVisualizer()
    if fv and fv.CalculateFruitWeight then
        local ok, w = pcall(function() return fv:CalculateFruitWeight(m) end)
        if ok and type(w) == "number" then return w end
    end
    return nil
end

-- ---- selective harvest + favorite-on-harvest ----
-- should we harvest this ripe fruit model? (false = leave it on the plant)
function harvestModelPasses(m)
    if not m then return true end
    local mut = m:GetAttribute("Mutation")
    if mut and mut ~= "" and #ignoredHarvestMutations > 0 then
        for _, im in ipairs(ignoredHarvestMutations) do if mutationStrHas(mut, im) then return false end end
    end
    if #ignoredHarvestTypes > 0 then
        local t = m:GetAttribute("CorePartName")
        if t and inSet(ignoredHarvestTypes, t) then return false end
    end
    if minHarvestWeight > 0 then
        local w = fruitModelWeight(m)
        if w and w < minHarvestWeight then return false end  -- best-effort; if unknown, don't skip
    end
    return true
end
-- does this fruit (model attrs OR tool) match the favorite-protect filter?
function favMatchAttrs(fruitName, mutation, weight, value)
    if not autoFavFilterEnabled then return false end
    if #selectedFavMutations > 0 and mutation and mutation ~= "" then
        for _, fm in ipairs(selectedFavMutations) do if mutationStrHas(mutation, fm) then return true end end
    end
    if #selectedFavFruits > 0 and fruitName and inSet(selectedFavFruits, fruitName) then return true end
    if favMinWeight > 0 and weight and weight >= favMinWeight then return true end
    if favMinPrice > 0 and value and value >= favMinPrice then return true end
    -- per-fruit favorite: keep this fruit only if it carries one of the listed mutations (empty list = any mutation)
    if fruitName then
        local allowed = selectedFavByFruit[fruitName]
        if allowed ~= nil then
            if #allowed == 0 then return true end
            if mutation and mutation ~= "" then
                for _, fm in ipairs(allowed) do if mutationStrHas(mutation, fm) then return true end end
            end
        end
    end
    return false
end
-- right after harvesting fruitId, favorite it if it should be protected from SellAll
function maybeFavoriteHarvest(model, fruitId)
    if not (autoFavFilterEnabled and SetFruitFavorite and fruitId and fruitId ~= "") then return end
    local fn = model:GetAttribute("CorePartName")
    local mut = model:GetAttribute("Mutation")
    local w = (favMinWeight > 0) and fruitModelWeight(model) or nil
    if favMatchAttrs(fn, mut, w, nil) then
        pcall(function() SetFruitFavorite:Fire(fruitId, true) end)
    end
end

-- ---- selective sell (favorite-protect + SellAll, since the pack is server-side) ----
-- sweep enumerable fruit TOOLS and favorite the keepers (covers held/loose fruit + retro pass)
function favoriteSweep()
    if not (autoFavFilterEnabled and SetFruitFavorite) then return end
    for _, t in ipairs(fruitTools()) do
        if t:GetAttribute("IsFavorite") ~= true then
            local fn = t:GetAttribute("FruitName") or t:GetAttribute("Fruit")
            local w = tonumber(t:GetAttribute("Weight"))
            local v = (favMinPrice > 0) and fruitToolValue(t) or nil
            if favMatchAttrs(fn, t:GetAttribute("Mutation"), w, v) then
                favoriteFruit(t:GetAttribute("Id"), true); task.wait(0.05)
            end
        end
    end
end

-- ---- mail ----
GIFT_CATEGORIES = { "Seeds", "Pets", "HarvestedFruits", "Sprinklers", "WateringCans", "Mushrooms",
    "Crates", "SeedPacks", "Trowels", "Gnomes", "Raccoons", "Props", "Flashbangs", "Birds" }
function equippedPetIdSet()
    local set = {}
    local ok, list = pcall(function() return GetEquippedPets:Fire() end)
    if ok and type(list) == "table" then
        for _, v in pairs(list) do if type(v) == "table" and v.Id then set[v.Id] = true end end
    end
    return set
end
-- returns { {label=, key=, count=} } of giftable items in a category
function giftItemsOf(category)
    local out = {}
    if category == "HarvestedFruits" then
        for _, t in ipairs(fruitTools()) do
            local id = t:GetAttribute("Id")
            if id then out[#out + 1] = { label = (t:GetAttribute("FruitName") or t.Name) .. " [" .. tostring(id):sub(1, 6) .. "]", key = id, count = 1 } end
        end
        return out
    end
    local entry = inv(category)
    if category == "Pets" then
        local eq = equippedPetIdSet()
        for k, v in pairs(entry) do
            if type(v) == "table" and not v.Equipped and not eq[v.Id or k] then
                out[#out + 1] = { label = (v.Name or "Pet"), key = (v.Id or tostring(k)), count = 1 }
            end
        end
    else
        for k, v in pairs(entry) do
            local cnt = (type(v) == "number") and v or (type(v) == "table" and (tonumber(v.Count) or 1)) or 1
            if cnt > 0 then out[#out + 1] = { label = tostring(k) .. " x" .. tostring(cnt), key = tostring(k), count = cnt } end
        end
    end
    return out
end
function mailInbox()
    if not MailOpenInbox then return {} end
    local ok, inbox = pcall(function() return MailOpenInbox:Fire() end)
    return (ok and type(inbox) == "table") and inbox or {}
end
function mailInboxCount()
    local n = 0; for _ in pairs(mailInbox()) do n = n + 1 end; return n
end
function mailClaimAll()
    local inbox, n = mailInbox(), 0
    for giftId in pairs(inbox) do
        if not MailClaim then break end
        pcall(function() MailClaim:Fire(giftId) end); n = n + 1; task.wait(0.4)
    end
    return n
end
function sanitizeName(s)
    s = tostring(s or ""):gsub("^%s*@?(.-)%s*$", "%1")
    if #s < 3 or #s > 20 or not s:match("^[%w_]+$") then return nil end
    return s
end
function resolveMailUser(name)
    local clean = sanitizeName(name); if not (clean and MailLookup) then return nil end
    local ok, uid = pcall(function() return MailLookup:Fire(clean) end)
    if ok and type(uid) == "number" and uid > 0 then return uid end
    return nil
end
-- send selectedMailItems (of mailSendCategory) to the resolved username; chunks <=20, >=1.6s apart
function doMailSend()
    if not MailSendBatch then return false, "no remote" end
    -- resolve recipients: multi-username overflow list, else single mailSendUsername
    local recipNames = {}
    if #mailSendUsernames > 0 then
        for _, u in ipairs(mailSendUsernames) do if tostring(u) ~= "" then recipNames[#recipNames + 1] = tostring(u) end end
    elseif mailSendUsername ~= "" then recipNames[1] = mailSendUsername end
    if #recipNames == 0 then return false, "no recipient" end

    -- build item list. spec is an array of keys OR a map {key=count}; counts: per-item > global; UUID cats forced to 1
    local uuidCats = { Pets = true, HarvestedFruits = true }
    local catAlias = { Pet = "Pets", Seed = "Seeds", Fruit = "HarvestedFruits", HarvestedFruit = "HarvestedFruits" }
    local items = {}
    local function addItems(category, spec)
        if type(spec) ~= "table" then return end
        category = catAlias[category] or category  -- accept competitor-style singular Pet/Seed
        local isMap = false
        for k in pairs(spec) do if type(k) == "string" then isMap = true break end end
        if isMap then
            for key, cnt in pairs(spec) do
                local c = uuidCats[category] and 1 or math.max(1, math.floor(tonumber(cnt) or 1))
                items[#items + 1] = { Category = category, ItemKey = key, Count = c }
            end
        else
            for _, key in ipairs(spec) do
                local c = uuidCats[category] and 1 or math.max(1, math.floor(tonumber(mailItemCounts[key]) or mailSendCount))
                items[#items + 1] = { Category = category, ItemKey = key, Count = c }
            end
        end
    end
    if next(mailSendByCategory) ~= nil then
        for cat, spec in pairs(mailSendByCategory) do addItems(cat, spec) end
    elseif mailSendCategory and #selectedMailItems > 0 then
        addItems(mailSendCategory, selectedMailItems)
    else
        return false, "no items selected"
    end
    if #items == 0 then return false, "no items selected" end

    -- send to recipients in order; items a recipient rejects overflow to the next recipient
    local note = mailSendNote ~= "" and mailSendNote or nil
    local pending = items
    local totalSent, lastMsg, reachedCount = 0, nil, 0
    for ri, uname in ipairs(recipNames) do
        if #pending == 0 then break end
        local uid = resolveMailUser(uname)
        if not uid and ri == 1 and mailSendUsername == uname then uid = mailSendUserId end
        if uid then
            local before = totalSent
            local stillPending, i = {}, 1
            while i <= #pending do
                local batch, total = {}, 0
                while i <= #pending and (total + pending[i].Count) <= 20 do
                    total = total + pending[i].Count; batch[#batch + 1] = pending[i]; i = i + 1
                end
                if #batch == 0 then batch[#batch + 1] = pending[i]; i = i + 1 end  -- single item > 20: send as-is
                local ok, sres, smsg = pcall(function() return MailSendBatch:Fire(uid, batch, note) end)
                if ok and sres ~= false then
                    totalSent = totalSent + #batch
                else
                    lastMsg = (smsg and tostring(smsg)) or "server rejected"
                    for _, it in ipairs(batch) do stillPending[#stillPending + 1] = it end
                end
                task.wait(1.6)  -- server rate-limit >= 1.5s
            end
            pending = stillPending
            if totalSent > before then reachedCount = reachedCount + 1 end
        else
            lastMsg = "bad username: " .. uname
        end
    end
    if totalSent == 0 then return false, ("send failed: " .. (lastMsg or "unknown")) end
    local resMsg = string.format("sent %d item-stack(s) to %d recipient(s)", totalSent, reachedCount)
    if #pending > 0 then resMsg = resMsg .. string.format(" (%d undelivered: %s)", #pending, lastMsg or "?") end
    return true, resMsg
end

-- ---- wipe plot ----
function shovelTool()
    for _, c in ipairs({ LocalPlayer:FindFirstChildOfClass("Backpack"), LocalPlayer.Character }) do
        if c then for _, x in ipairs(c:GetChildren()) do
            if x:IsA("Tool") and x:GetAttribute("Shovel") ~= nil then return x end
        end end
    end
    return nil
end
function myPlantsFolder()
    local plot = myPlot(); return plot and plot:FindFirstChild("Plants")
end
function plantedSeedNames()
    local set, out = {}, {}
    local f = myPlantsFolder()
    if f then for _, m in ipairs(f:GetChildren()) do
        local sn = m:GetAttribute("SeedName")
        if sn and not set[sn] then set[sn] = true; out[#out + 1] = sn end
    end end
    table.sort(out)
    return out
end
-- returns sold count, or -1 if no shovel available
function doWipePlot()
    local f = myPlantsFolder(); if not f then return 0 end
    local sh = shovelTool(); if not sh then return -1 end
    local hum = humanoid(); if hum then pcall(function() hum:EquipTool(sh) end); task.wait(0.25) end
    sh = shovelTool(); local shovelName = sh and sh:GetAttribute("Shovel")
    if not (sh and shovelName and UseShovel) then return -1 end
    local useFilter = #selectedWipeSeeds > 0
    local n = 0
    for _, m in ipairs(f:GetChildren()) do
        if stopped or not wipeBusy then break end
        local sn = m:GetAttribute("SeedName")
        if (not useFilter) or (sn and inSet(selectedWipeSeeds, sn)) then
            pcall(function() UseShovel:Fire(m.Name, "", shovelName, sh) end)
            n = n + 1
            task.wait(0.55 + math.random() * 0.3)  -- swing cooldown ~0.65 + jitter
        end
    end
    return n
end

-- ---- steal value (rank targets) ----
function stealValue(m)
    if not m then return 0 end
    local calc = fruitValueCalc()
    local fn = m:GetAttribute("CorePartName") or m:GetAttribute("FruitName")
    local sz = m:GetAttribute("SizeMulti") or m:GetAttribute("SizeMultiplier") or 1
    local mut = m:GetAttribute("Mutation")
    if calc and fn then
        local ok, v = pcall(calc, fn, sz, mut, LocalPlayer, m:GetAttribute("DecayAlpha"))
        if ok and tonumber(v) then return tonumber(v) end
    end
    return sz  -- fallback: bigger is better
end

-- ---- field guard ----
function faceAndHit(plr)
    if not (plr and plr.Character) then return end
    local theirHrp = plr.Character:FindFirstChild("HumanoidRootPart")
    local myHrp = hrpNow()
    if not (theirHrp and myHrp) then return end
    -- get a shovel out
    local sh = shovelTool()
    if sh then local hum = humanoid(); if hum and LocalPlayer.Character:FindFirstChildWhichIsA("Tool") ~= sh then pcall(function() hum:EquipTool(sh) end) end end
    -- teleport just in front of them, facing them (server needs dist<=12 & dot>=0.3)
    pcall(function() myHrp.CFrame = CFrame.lookAt(theirHrp.Position + Vector3.new(0, 0, 6), theirHrp.Position) end)
    task.wait(0.12)
    pcall(function() if SwingShovel then SwingShovel:Fire() end end)
    pcall(function() if HitPlayer then HitPlayer:Fire(plr.UserId) end end)
end

-- ---- FPS boost ----
-- never touch our own UI (MacLib lives in CoreGui/gethui) or the player GUIs
function isProtectedGui(inst)
    local cg = game:GetService("CoreGui")
    if inst:IsDescendantOf(cg) then return true end
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui and inst:IsDescendantOf(hui) then return true end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and inst:IsDescendantOf(pg) then return true end
    return false
end
-- strip one instance's render cost (MAX). Leaves geometry/attributes/prompts/clickdetectors intact.
function stripFpsInstance(v)
    if isProtectedGui(v) then return end
    if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = false
    elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = false
    elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v.Enabled = false
    elseif v:IsA("SpecialMesh") then pcall(function() v.TextureId = "" end)
    elseif v:IsA("MeshPart") then
        v.Material = Enum.Material.Plastic; v.Reflectance = 0; v.CastShadow = false
        pcall(function() v.RenderFidelity = Enum.RenderFidelity.Performance end)
    elseif v:IsA("BasePart") then
        v.Material = Enum.Material.Plastic; v.Reflectance = 0; v.CastShadow = false
    end
end
-- hide every garden that isn't mine (the biggest single render cost: >50% of all parts).
-- non-destructive (transparency) so Steal/Guard still resolve instances if re-enabled.
function hideOtherGardens()
    local g = Workspace:FindFirstChild("Gardens"); if not g then return 0 end
    local mine = "Plot" .. tostring(myPlotId())
    local n = 0
    for _, plot in ipairs(g:GetChildren()) do
        if plot.Name ~= mine then
            for _, v in ipairs(plot:GetDescendants()) do
                pcall(function()
                    if v:IsA("BasePart") then v.Transparency = 1; v.CastShadow = false; n = n + 1
                    elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
                end)
            end
        end
    end
    return n
end
-- absolute minimum: DELETE other players' gardens (breaks Steal/Guard until rejoin). Tested safe.
function nukeOtherGardens()
    local g = Workspace:FindFirstChild("Gardens"); if not g then return 0 end
    local mine = "Plot" .. tostring(myPlotId())
    local n = 0
    for _, plot in ipairs(g:GetChildren()) do
        if plot.Name ~= mine then pcall(function() plot:Destroy() end); n = n + 1 end
    end
    return n
end
fpsDescConn = nil
function applyFpsBoost()
    local Lighting = game:GetService("Lighting")
    pcall(function()
        local t = Workspace:FindFirstChildOfClass("Terrain")
        if t then t.WaterWaveSize = 0; t.WaterWaveSpeed = 0; t.WaterReflectance = 0; t.WaterTransparency = 0 end
        Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9; Lighting.Brightness = 1
        pcall(function() Lighting.EnvironmentDiffuseScale = 0; Lighting.EnvironmentSpecularScale = 0 end)
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
                or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then pcall(function() e.Enabled = false end) end
        end
        pcall(function() settings().Rendering.QualityLevel = 1 end)
    end)
    if fpsMaxEnabled then
        -- scan WORKSPACE only (where the render load is; auto-skips CoreGui/PlayerGui)
        for _, v in ipairs(Workspace:GetDescendants()) do pcall(stripFpsInstance, v) end
        -- BENCHMARKED: hiding (transparency) gives ~0 FPS (Roblox still renders transparent geometry);
        -- DELETING other gardens is the real win (live A/B: 46->63 FPS, CPU 0.49->0.36 cores). Breaks Steal/Guard until rejoin.
        nukeOtherGardens()
        -- keep newly-streamed parts stripped (game streams fruit/plants constantly)
        if not fpsDescConn then
            fpsDescConn = Workspace.DescendantAdded:Connect(function(v)
                if fpsMaxEnabled then task.defer(stripFpsInstance, v) end
            end)
            table.insert(hubConnections, fpsDescConn)
        end
    end
    fpsBoostApplied = true
end
function applyFpsCap()
    local f = (getgenv and getgenv().setfpscap) or setfpscap
    if type(f) == "function" then pcall(f, (fpsCap and fpsCap > 0) and fpsCap or 999) end
end

-- // ========================================== \\ --
-- //                 UI SETUP                   \\ --
-- // ========================================== \\ --

Window = MacLib:Window({
    Title = tostring(GameName) .. " [BETA]",
    Subtitle = "DYHUB",
    Size = UDim2.fromOffset(865, 650),
    DragStyle = 2,
    DisabledWindowControls = {},
    ShowUserInfo = false,
    Keybind = Enum.KeyCode.LeftControl,
    AcrylicBlur = false,
})

tabGroups = { MainGroup = Window:TabGroup() }
tabs = {
    Farm = tabGroups.MainGroup:Tab({ Name = "Farm", Image = "rbxassetid://10723407389" }),
    Shop = tabGroups.MainGroup:Tab({ Name = "Shop", Image = "rbxassetid://10734949856" }),
    Pets = tabGroups.MainGroup:Tab({ Name = "Pets", Image = "rbxassetid://10723354671" }),
    Open = tabGroups.MainGroup:Tab({ Name = "Eggs & Crates", Image = "rbxassetid://10747372992" }),
    Mail = tabGroups.MainGroup:Tab({ Name = "Mail", Image = "rbxassetid://10734897102" }),
    Steal = tabGroups.MainGroup:Tab({ Name = "Steal", Image = "rbxassetid://10709769841" }),
    Misc = tabGroups.MainGroup:Tab({ Name = "Misc", Image = "rbxassetid://10747372992" }),
    Settings = tabGroups.MainGroup:Tab({ Name = "Settings", Image = "rbxassetid://10734950309" })
}

sections = {
    StatusSection = tabs.Farm:Section({ Side = "Left" }),
    PlantSection = tabs.Farm:Section({ Side = "Left" }),
    HarvestSellSection = tabs.Farm:Section({ Side = "Left" }),
    CollectSection = tabs.Farm:Section({ Side = "Left" }),
    ActionsSection = tabs.Farm:Section({ Side = "Right" }),
    BoostSection = tabs.Farm:Section({ Side = "Right" }),
    SkillSection = tabs.Farm:Section({ Side = "Right" }),
    FavoritesSection = tabs.Farm:Section({ Side = "Right" }),
    WipeSection = tabs.Farm:Section({ Side = "Right" }),
    SeedShopSection = tabs.Shop:Section({ Side = "Left" }),
    CrateShopSection = tabs.Shop:Section({ Side = "Left" }),
    GearShopSection = tabs.Shop:Section({ Side = "Right" }),
    PetSection = tabs.Pets:Section({ Side = "Left" }),
    PetTameSection = tabs.Pets:Section({ Side = "Left" }),
    PetSellSection = tabs.Pets:Section({ Side = "Right" }),
    OpenSection = tabs.Open:Section({ Side = "Left" }),
    MailClaimSection = tabs.Mail:Section({ Side = "Left" }),
    MailSendSection = tabs.Mail:Section({ Side = "Right" }),
    StealSection = tabs.Steal:Section({ Side = "Left" }),
    StealInfoSection = tabs.Steal:Section({ Side = "Right" }),
    GuardSection = tabs.Steal:Section({ Side = "Right" }),
    MiscMoveSection = tabs.Misc:Section({ Side = "Left" }),
    MiscMapSection = tabs.Misc:Section({ Side = "Left" }),
    MiscWebhookSection = tabs.Misc:Section({ Side = "Left" }),
    MiscQolSection = tabs.Misc:Section({ Side = "Right" }),
    MiscFpsSection = tabs.Misc:Section({ Side = "Right" }),
    SettingsSection = tabs.Settings:Section({ Side = "Left" })
}

-- // ========================================== \\ --
-- //              ANTI-AFK BYPASS               \\ --
-- // ========================================== \\ --

coroutine.wrap(function()
    local GC = getconnections or get_signal_cons
    if GC then
        for i, v in pairs(GC(LocalPlayer.Idled)) do
            if v["Disable"] then v["Disable"](v) elseif v["Disconnect"] then v["Disconnect"](v) end
        end
    else
        local VirtualUser = cloneref(game:GetService("VirtualUser"))
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)()

do
    local antiAfkThread = nil

    local function startAntiAfkLoop(character)
        if antiAfkThread then
            pcall(task.cancel, antiAfkThread)
            antiAfkThread = nil
        end

        local humanoid = character:WaitForChild("Humanoid")
        antiAfkThread = task.spawn(function()
            while humanoid and humanoid.Parent and not stopped do
                task.wait(60)
                if humanoid and humanoid.Parent then
                    for _, c in pairs(getconnections(humanoid.Running)) do
                        pcall(function() c:Fire(1) end)
                    end
                end
            end
        end)
    end

    if LocalPlayer.Character then
        startAntiAfkLoop(LocalPlayer.Character)
    end
    table.insert(hubConnections, LocalPlayer.CharacterAdded:Connect(startAntiAfkLoop))
end

coroutine.wrap(function()
    local VIM = game:GetService("VirtualInputManager")
    while not stopped do
        task.wait(300)
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.Unknown, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.Unknown, false, game)
        end)
    end
end)()

-- // ========================================== \\ --
-- //                   FARM                     \\ --
-- // ========================================== \\ --

sections.StatusSection:Header({ Text = "Status" })
plotLabel = sections.StatusSection:Label({ Text = "Plot: ..." })
cashLabel = sections.StatusSection:Label({ Text = "Sheckles: ..." })

sections.PlantSection:Header({ Text = "Auto Plant" })
plantDropdown = sections.PlantSection:Dropdown({
    Name = "Seeds to plant",
    Multi = true,
    Search = true,
    Options = seedNames(),
    Default = {},
    Callback = function(val) selectedPlantSeeds = toArray(val) end
}, "PlantSeedsDropdown")
sections.PlantSection:Toggle({
    Name = "Auto Plant",
    Default = false,
    Callback = function(state)
        autoPlantEnabled = state
        if state and #selectedPlantSeeds == 0 then
            Window:Notify({ Title = "Auto Plant", Description = "Select at least one seed first." })
        end
    end
}, "AutoPlantToggle")
sections.PlantSection:Slider({
    Name = "Plant Spacing (studs)",
    Default = 4, Minimum = 2, Maximum = 10, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) plantSpacing = v end
}, "PlantSpacingSlider")

sections.HarvestSellSection:Header({ Text = "Harvest & Sell" })
sections.HarvestSellSection:Toggle({
    Name = "Auto Harvest",
    Default = false,
    Callback = function(state) autoHarvestEnabled = state end
}, "AutoHarvestToggle")
sections.HarvestSellSection:Slider({
    Name = "Harvest Interval (s) - pause between passes",
    Default = 0.25, Minimum = 0.05, Maximum = 5, DisplayMethod = "Value", Precision = 2,
    Callback = function(v) harvestInterval = v end
}, "HarvestIntervalSlider")
-- selective harvest: skip = leave on plant
sections.HarvestSellSection:Dropdown({
    Name = "Don't harvest mutations",
    Multi = true, Search = true, Options = mutationNames(), Default = {},
    Callback = function(val) ignoredHarvestMutations = toArray(val) end
}, "IgnoreHarvestMutationsDropdown")
sections.HarvestSellSection:Dropdown({
    Name = "Don't harvest fruit types",
    Multi = true, Search = true, Options = fruitTypeNames(), Default = {},
    Callback = function(val) ignoredHarvestTypes = toArray(val) end
}, "IgnoreHarvestTypesDropdown")
sections.HarvestSellSection:Slider({
    Name = "Only harvest Weight >= KG (0=all)",
    Default = 0, Minimum = 0, Maximum = 50, DisplayMethod = "Value", Precision = 1,
    Callback = function(v) minHarvestWeight = v end
}, "MinHarvestWeightSlider")
sections.HarvestSellSection:Toggle({
    Name = "Auto Sell (also sells when pack is full)",
    Default = false,
    Callback = function(state) autoSellEnabled = state end
}, "AutoSellToggle")
sections.HarvestSellSection:Slider({
    Name = "Sell Interval (s)",
    Default = 15, Minimum = 3, Maximum = 120, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) sellInterval = v end
}, "SellIntervalSlider")

sections.CollectSection:Header({ Text = "Collect Drops" })
sections.CollectSection:Toggle({
    Name = "Auto Collect Dropped Seeds",
    Default = false,
    Callback = function(state) autoCollectSeedsEnabled = state end
}, "AutoCollectSeedsToggle")
sections.CollectSection:Toggle({
    Name = "Auto Collect Dropped Acorns",
    Default = false,
    Callback = function(state) autoCollectAcornsEnabled = state end
}, "AutoCollectAcornsToggle")
sections.CollectSection:Toggle({
    Name = "Auto Collect Seed (Gold/Rainbow)",
    Default = false,
    Callback = function(state) autoCollectSeedGoldRainbowEnabled = state end
}, "AutoCollectSeedGoldRainbowToggle")
sections.CollectSection:Label({ Text = "Teleports to drops / seed prompts to pick them up." })

sections.ActionsSection:Header({ Text = "Auto Actions" })
sections.ActionsSection:Dropdown({
    Name = "Auto Farm Actions",
    Multi = true,
    Search = true,
    Options = autoFarmActionOptions,
    Default = {},
    Callback = function(val) selectedAutoFarmActions = toArray(val) end
}, "AutoFarmActionsDropdown")
sections.ActionsSection:Toggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(state)
        autoFarmEnabled = state
        if state and #selectedAutoFarmActions == 0 then
            Window:Notify({ Title = "Auto Farm", Description = "Select at least one action first.", Lifetime = 4 })
        end
    end
}, "AutoFarmMasterToggle")
sections.ActionsSection:Label({ Text = "Uses the selected Seeds/Gear/Pet dropdowns from each tab." })
sections.ActionsSection:Toggle({
    Name = "Auto Expand Garden",
    Default = false,
    Callback = function(state) autoExpandEnabled = state; if state then expandDoneCount = 0 end end
}, "AutoExpandToggle")
sections.ActionsSection:Toggle({
    Name = "Auto Daily Deals",
    Default = false,
    Callback = function(state) autoDailyEnabled = state end
}, "AutoDailyToggle")

sections.BoostSection:Header({ Text = "Boosts" })
sections.BoostSection:Toggle({
    Name = "Auto Place Sprinklers",
    Default = false,
    Callback = function(state) autoSprinklerEnabled = state end
}, "AutoSprinklerToggle")
sections.BoostSection:Slider({
    Name = "Sprinkler Interval (s)",
    Default = 30, Minimum = 10, Maximum = 120, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) sprinklerInterval = v end
}, "SprinklerIntervalSlider")
sections.BoostSection:Toggle({
    Name = "Auto Watering Can",
    Default = false,
    Callback = function(state) autoWaterEnabled = state end
}, "AutoWaterToggle")
sections.BoostSection:Slider({
    Name = "Water Interval (s)",
    Default = 8, Minimum = 2, Maximum = 60, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) waterInterval = v end
}, "WaterIntervalSlider")

sections.SkillSection:Header({ Text = "Skill Points" })
sections.SkillSection:Dropdown({
    Name = "Stats to level",
    Multi = true,
    Search = true,
    Options = { "BaseSpeed", "BaseJump", "ShovelPower", "MaxBackpack" },
    Default = {},
    Callback = function(val) selectedSkills = toArray(val) end
}, "SkillStatsDropdown")
sections.SkillSection:Toggle({
    Name = "Auto Spend Skill Points",
    Default = false,
    Callback = function(state) autoSkillEnabled = state end
}, "AutoSkillToggle")

sections.FavoritesSection:Header({ Text = "Favorites (protect from sell)" })
sections.FavoritesSection:Toggle({
    Name = "Auto Favorite Mutated Fruit",
    Default = false,
    Callback = function(state) autoFavMutationEnabled = state end
}, "AutoFavMutationToggle")
sections.FavoritesSection:Toggle({
    Name = "Auto Favorite All Inventory Fruit",
    Default = false,
    Callback = function(state) autoFavInventoryEnabled = state end
}, "AutoFavInventoryToggle")
sections.FavoritesSection:Toggle({
    Name = "Auto Favorite Farm Fruit",
    Default = false,
    Callback = function(state) autoFavFarmEnabled = state end
}, "AutoFavFarmToggle")
-- granular favorite = selective sell: favorited fruit are NEVER sold by Auto Sell (Sell-All).
sections.FavoritesSection:Toggle({
    Name = "Auto Favorite by Filter (= selective sell)",
    Default = false,
    Callback = function(state) autoFavFilterEnabled = state end
}, "AutoFavFilterToggle")
favMutDropdown = sections.FavoritesSection:Dropdown({
    Name = "Keep mutations",
    Multi = true, Search = true, Options = mutationNames(), Default = {},
    Callback = function(val) selectedFavMutations = toArray(val) end
}, "FavMutationsDropdown")
favFruitDropdown = sections.FavoritesSection:Dropdown({
    Name = "Keep fruit types",
    Multi = true, Search = true, Options = fruitTypeNames(), Default = {},
    Callback = function(val) selectedFavFruits = toArray(val) end
}, "FavFruitsDropdown")
sections.FavoritesSection:Slider({
    Name = "Keep if Weight >= KG (0=off)",
    Default = 0, Minimum = 0, Maximum = 50, DisplayMethod = "Value", Precision = 1,
    Callback = function(v) favMinWeight = v end
}, "FavMinWeightSlider")
sections.FavoritesSection:Slider({
    Name = "Keep if Value >= $ (0=off)",
    Default = 0, Minimum = 0, Maximum = 100000, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) favMinPrice = v end
}, "FavMinPriceSlider")
sections.FavoritesSection:Label({ Text = "Filter favorites at harvest; Sell-All skips them." })
sections.FavoritesSection:Button({
    Name = "Unfavorite All Inventory Fruit",
    Callback = function()
        for _, t in ipairs(fruitTools()) do
            favoriteFruit(t:GetAttribute("Id"), false)
            task.wait(0.05)
        end
    end
})

sections.WipeSection:Header({ Text = "Wipe Plot (DESTRUCTIVE)" })
sections.WipeSection:Label({ Text = "Permanently SHOVELS your planted crops!" })
wipeArmed = false
wipeSeedsDropdown = sections.WipeSection:Dropdown({
    Name = "Only wipe these seeds (empty = ALL)",
    Multi = true, Search = true, Options = plantedSeedNames(), Default = {},
    Callback = function(val) selectedWipeSeeds = toArray(val) end
}, "WipeSeedsDropdown")
sections.WipeSection:Button({
    Name = "Refresh planted list",
    Callback = function()
        pcall(function() wipeSeedsDropdown:ClearOptions(); wipeSeedsDropdown:InsertOptions(plantedSeedNames()) end)
    end
})
sections.WipeSection:Toggle({
    Name = "Arm Wipe (safety)",
    Default = false,
    Callback = function(s) wipeArmed = s end
}, "WipeArmToggle")
sections.WipeSection:Button({
    Name = "WIPE SELECTED PLANTS NOW",
    Callback = function()
        if not wipeArmed then
            Window:Notify({ Title = "Wipe Plot", Description = "Enable 'Arm Wipe' first.", Lifetime = 4 }); return
        end
        if wipeBusy then return end
        wipeBusy = true
        task.spawn(function()
            ActivityPriority:SetActivity("WipePlot")
            local n = doWipePlot()
            ActivityPriority:ClearActivity("WipePlot")
            wipeBusy = false; wipeArmed = false
            if n == -1 then Window:Notify({ Title = "Wipe Plot", Description = "No Shovel tool found in backpack.", Lifetime = 5 })
            else Window:Notify({ Title = "Wipe Plot", Description = "Removed " .. tostring(n) .. " plant(s).", Lifetime = 5 }) end
        end)
    end
})

-- // ========================================== \\ --
-- //                   SHOP                     \\ --
-- // ========================================== \\ --

sections.SeedShopSection:Header({ Text = "Auto Buy - Seeds" })
sections.SeedShopSection:Dropdown({
    Name = "Buy Mode",
    Multi = false, Options = { "Selected", "All" }, Default = "Selected",
    Callback = function(val) seedBuyMode = (type(val) == "table") and (toArray(val)[1]) or val end
}, "SeedBuyModeDropdown")
seedShopDropdown = sections.SeedShopSection:Dropdown({
    Name = "Seeds to buy",
    Multi = true,
    Search = true,
    Options = seedNames(),
    Default = {},
    Callback = function(val) selectedSeeds = toArray(val) end
}, "BuySeedsDropdown")
sections.SeedShopSection:Toggle({
    Name = "Auto Buy Seeds",
    Default = false,
    Callback = function(state) autoBuySeedEnabled = state end
}, "AutoBuySeedToggle")
sections.SeedShopSection:Slider({
    Name = "Buy Interval (s)",
    Default = 5, Minimum = 1, Maximum = 30, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) buySeedInterval = v end
}, "BuySeedIntervalSlider")
sections.SeedShopSection:Slider({
    Name = "Max buys / seed / pass",
    Default = 8, Minimum = 1, Maximum = 50, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) buySeedPerTick = v end
}, "BuySeedPerTickSlider")

sections.CrateShopSection:Header({ Text = "Auto Buy - Cosmetic Crates" })
crateShopDropdown = sections.CrateShopSection:Dropdown({
    Name = "Crates to buy",
    Multi = true,
    Search = true,
    Options = crateNames(),
    Default = {},
    Callback = function(val) selectedCrates = toArray(val) end
}, "BuyCratesDropdown")
sections.CrateShopSection:Toggle({
    Name = "Auto Buy Crates",
    Default = false,
    Callback = function(state) autoBuyCrateEnabled = state end
}, "AutoBuyCrateToggle")
sections.CrateShopSection:Slider({
    Name = "Crate Buy Interval (s)",
    Default = 10, Minimum = 2, Maximum = 60, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) crateBuyInterval = v end
}, "CrateBuyIntervalSlider")

sections.GearShopSection:Header({ Text = "Auto Buy - Gear" })
sections.GearShopSection:Dropdown({
    Name = "Buy Mode",
    Multi = false, Options = { "Selected", "All" }, Default = "Selected",
    Callback = function(val) gearBuyMode = (type(val) == "table") and (toArray(val)[1]) or val end
}, "GearBuyModeDropdown")
gearShopDropdown = sections.GearShopSection:Dropdown({
    Name = "Gear to buy",
    Multi = true,
    Search = true,
    Options = gearNames(),
    Default = {},
    Callback = function(val) selectedGear = toArray(val) end
}, "BuyGearDropdown")
sections.GearShopSection:Toggle({
    Name = "Auto Buy Gear",
    Default = false,
    Callback = function(state) autoBuyGearEnabled = state end
}, "AutoBuyGearToggle")
sections.GearShopSection:Slider({
    Name = "Gear Buy Interval (s)",
    Default = 10, Minimum = 2, Maximum = 60, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) buyGearInterval = v end
}, "BuyGearIntervalSlider")

-- // ========================================== \\ --
-- //                   PETS                     \\ --
-- // ========================================== \\ --

sections.PetSection:Header({ Text = "Pets" })
sections.PetSection:Toggle({
    Name = "Auto Equip Pets",
    Default = false,
    Callback = function(state) autoEquipPetsEnabled = state end
}, "AutoEquipPetsToggle")
equipNameDropdown = sections.PetSection:Dropdown({
    Name = "Equip only these names",
    Multi = true,
    Search = true,
    Options = {},
    Default = {},
    Callback = function(val) selectedEquipPetNames = toArray(val) end
}, "EquipPetNamesDropdown")
equipRarityDropdown = sections.PetSection:Dropdown({
    Name = "Equip only these rarities",
    Multi = true,
    Search = true,
    Options = {},
    Default = {},
    Callback = function(val) selectedEquipPetRarities = toArray(val) end
}, "EquipPetRaritiesDropdown")
sections.PetSection:Button({
    Name = "Refresh equip filters",
    Callback = function()
        pcall(function() equipNameDropdown:ClearOptions(); equipNameDropdown:InsertOptions(allPetNames()) end)
        pcall(function() equipRarityDropdown:ClearOptions(); equipRarityDropdown:InsertOptions(knownRarities()) end)
    end
})
sections.PetSection:Label({ Text = "Empty filters = equip any (up to slot cap)." })
sections.PetSection:Toggle({
    Name = "Auto Buy Pet Slots",
    Default = false,
    Callback = function(state) autoPetSlotEnabled = state; if state then petSlotDoneCount = 0 end end
}, "AutoPetSlotToggle")

sections.PetTameSection:Header({ Text = "Wild Pets (tame)" })
sections.PetTameSection:Toggle({
    Name = "Auto Buy Wild Pets",
    Default = false,
    Callback = function(state) autoBuyPetsEnabled = state end
}, "AutoBuyPetsToggle")
tameNameDropdown = sections.PetTameSection:Dropdown({
    Name = "Tame only these names",
    Multi = true,
    Search = true,
    Options = {},
    Default = {},
    Callback = function(val) selectedTamePetNames = toArray(val) end
}, "TamePetNamesDropdown")
tameRarityDropdown = sections.PetTameSection:Dropdown({
    Name = "Tame only these rarities",
    Multi = true,
    Search = true,
    Options = {},
    Default = {},
    Callback = function(val) selectedTamePetRarities = toArray(val) end
}, "TamePetRaritiesDropdown")
sections.PetTameSection:Button({
    Name = "Refresh tame filters",
    Callback = function()
        pcall(function() tameNameDropdown:ClearOptions(); tameNameDropdown:InsertOptions(allPetNames()) end)
        pcall(function() tameRarityDropdown:ClearOptions(); tameRarityDropdown:InsertOptions(knownRarities()) end)
    end
})
sections.PetTameSection:Slider({
    Name = "Max Pet Price (Sheckles)",
    Default = 25000, Minimum = 1000, Maximum = 1000000, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) maxPetPrice = v end
}, "MaxPetPriceSlider")
sections.PetTameSection:Slider({
    Name = "Wild Pet Buy Interval (s)",
    Default = 5, Minimum = 2, Maximum = 60, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) petBuyInterval = v end
}, "PetBuyIntervalSlider")
-- populate pet dropdowns off the main thread (all species + all rarities are static from PetData)
task.spawn(function()
    local names, rarities = allPetNames(), knownRarities()
    pcall(function() equipNameDropdown:ClearOptions(); equipNameDropdown:InsertOptions(names) end)
    pcall(function() equipRarityDropdown:ClearOptions(); equipRarityDropdown:InsertOptions(rarities) end)
    pcall(function() tameNameDropdown:ClearOptions(); tameNameDropdown:InsertOptions(names) end)
    pcall(function() tameRarityDropdown:ClearOptions(); tameRarityDropdown:InsertOptions(rarities) end)
end)

sections.PetSellSection:Header({ Text = "Sell Pets" })
petSellDropdown = sections.PetSellSection:Dropdown({
    Name = "Pets to sell",
    Multi = true,
    Search = true,
    Options = {},
    Default = {},
    Callback = function(val) selectedSellPets = toArray(val) end
}, "SellPetsDropdown")
sections.PetSellSection:Button({
    Name = "Refresh pet list",
    Callback = function()
        pcall(function() petSellDropdown:ClearOptions(); petSellDropdown:InsertOptions(ownedPetNames()) end)
    end
})
-- populate the pet list off the main thread; retry until pets are available
task.spawn(function()
    for attempt = 1, 12 do
        task.wait(attempt == 1 and 2 or 3)
        local owned = ownedPetNames()
        pcall(function() petSellDropdown:ClearOptions(); petSellDropdown:InsertOptions(owned) end)
        if #owned > 0 then break end
    end
end)
sections.PetSellSection:Toggle({
    Name = "Auto Sell Selected Pets",
    Default = false,
    Callback = function(state) autoSellPetsEnabled = state end
}, "AutoSellPetsToggle")

-- // ========================================== \\ --
-- //               EGGS & CRATES                \\ --
-- // ========================================== \\ --

sections.OpenSection:Header({ Text = "Auto Open" })
sections.OpenSection:Toggle({
    Name = "Auto Open Eggs",
    Default = false,
    Callback = function(state) autoEggEnabled = state end
}, "AutoEggToggle")
sections.OpenSection:Toggle({
    Name = "Auto Open Crates",
    Default = false,
    Callback = function(state) autoCrateEnabled = state end
}, "AutoCrateToggle")
sections.OpenSection:Toggle({
    Name = "Auto Open Seed Packs",
    Default = false,
    Callback = function(state) autoPackEnabled = state end
}, "AutoPackToggle")
sections.OpenSection:Slider({
    Name = "Open Interval (s)",
    Default = 4, Minimum = 1, Maximum = 30, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) openInterval = v end
}, "OpenIntervalSlider")

-- // ========================================== \\ --
-- //                   MAIL                     \\ --
-- // ========================================== \\ --

sections.MailClaimSection:Header({ Text = "Mail - Claim" })
mailInboxLabel = sections.MailClaimSection:Label({ Text = "Inbox: ?" })
sections.MailClaimSection:Toggle({
    Name = "Auto Claim Mail",
    Default = false,
    Callback = function(state) autoMailClaimEnabled = state end
}, "AutoMailClaimToggle")
sections.MailClaimSection:Slider({
    Name = "Claim Interval (s)",
    Default = 30, Minimum = 10, Maximum = 300, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) mailClaimInterval = v end
}, "MailClaimIntervalSlider")
sections.MailClaimSection:Button({
    Name = "Claim All Now",
    Callback = function()
        local n = mailClaimAll()
        Window:Notify({ Title = "Mail", Description = "Claimed " .. n .. " gift(s).", Lifetime = 4 })
    end
})
sections.MailClaimSection:Button({
    Name = "Refresh Inbox Count",
    Callback = function()
        mailInboxCountCache = mailInboxCount()
        pcall(function() mailInboxLabel:UpdateName("Inbox: " .. mailInboxCountCache) end)
    end
})

sections.MailSendSection:Header({ Text = "Mail - Send to Player" })
mailUserInput = sections.MailSendSection:Input({
    Name = "Username",
    Placeholder = "exact roblox username",
    Default = "",
    Callback = function(text) mailSendUsername = text; mailSendUserId = nil end
}, "MailUsernameInput")
mailResolveLabel = sections.MailSendSection:Label({ Text = "Recipient: (not resolved)" })
sections.MailSendSection:Button({
    Name = "Resolve Username",
    Callback = function()
        local uid = resolveMailUser(mailSendUsername)
        mailSendUserId = uid
        pcall(function() mailResolveLabel:UpdateName(uid and ("Recipient: id " .. uid) or "Recipient: NOT FOUND") end)
    end
})
mailItemKeyByLabel = {}
mailItemsDropdown = sections.MailSendSection:Dropdown({
    Name = "Items to send",
    Multi = true, Search = true, Options = {}, Default = {},
    Callback = function(val)
        local labels = toArray(val)
        selectedMailItems = {}
        for _, lbl in ipairs(labels) do
            local key = mailItemKeyByLabel[lbl]
            if key then selectedMailItems[#selectedMailItems + 1] = key end
        end
    end
}, "MailItemsDropdown")
local function refreshMailItems()
    if not mailSendCategory then return end
    local items = giftItemsOf(mailSendCategory)
    mailItemKeyByLabel = {}
    local opts = {}
    for _, it in ipairs(items) do mailItemKeyByLabel[it.label] = it.key; opts[#opts + 1] = it.label end
    selectedMailItems = {}
    pcall(function() mailItemsDropdown:ClearOptions(); mailItemsDropdown:InsertOptions(opts) end)
end
sections.MailSendSection:Dropdown({
    Name = "Category",
    Multi = false, Search = true, Options = GIFT_CATEGORIES, Default = GIFT_CATEGORIES[1],
    Callback = function(val)
        mailSendCategory = (type(val) == "table") and (toArray(val)[1]) or val
        refreshMailItems()
    end
}, "MailCategoryDropdown")
sections.MailSendSection:Slider({
    Name = "Count / stackable item",
    Default = 1, Minimum = 1, Maximum = 100, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) mailSendCount = v end
}, "MailCountSlider")
mailNoteInput = sections.MailSendSection:Input({
    Name = "Note (optional)",
    Placeholder = "gg", Default = "",
    Callback = function(text) mailSendNote = text end
}, "MailNoteInput")
sections.MailSendSection:Button({
    Name = "Refresh Items",
    Callback = function() refreshMailItems() end
})
sections.MailSendSection:Button({
    Name = "Send Now",
    Callback = function()
        local ok, msg = doMailSend()
        Window:Notify({ Title = "Mail Send", Description = tostring(msg), Lifetime = 5 })
    end
})
sections.MailSendSection:Toggle({
    Name = "Auto Send (sends items OUT - irreversible)",
    Default = false,
    Callback = function(state)
        autoMailSendEnabled = state
        if state then Window:Notify({ Title = "Auto Send", Description = "Will repeatedly mail selected items to the username.", Lifetime = 6 }) end
    end
}, "AutoMailSendToggle")
sections.MailSendSection:Slider({
    Name = "Auto Send Interval (s)",
    Default = 60, Minimum = 15, Maximum = 600, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) mailSendInterval = v end
}, "MailSendIntervalSlider")

-- // ========================================== \\ --
-- //                   STEAL                    \\ --
-- // ========================================== \\ --

sections.StealSection:Header({ Text = "Auto Steal (night only)" })
sections.StealSection:Toggle({
    Name = "Auto Steal others' fruit",
    Default = false,
    Callback = function(state) autoStealEnabled = state end
}, "AutoStealToggle")
sections.StealSection:Toggle({
    Name = "Return home after each (banks it)",
    Default = true,
    Callback = function(state) stealReturnHome = state end
}, "StealReturnToggle")
sections.StealSection:Slider({
    Name = "Steal speed (delay/fruit, 0=instant)",
    Default = 0.05, Minimum = 0, Maximum = 1, DisplayMethod = "Value", Precision = 2,
    Callback = function(v) stealDelay = v end
}, "StealDelaySlider")
sections.StealSection:Toggle({
    Name = "Steal most valuable first",
    Default = true,
    Callback = function(s) stealMostExpensive = s end
}, "StealMostExpensiveToggle")

sections.GuardSection:Header({ Text = "Field Guard" })
sections.GuardSection:Toggle({
    Name = "Defend my plot (shovel thieves)",
    Default = false,
    Callback = function(s) fieldGuardEnabled = s end
}, "FieldGuardToggle")
sections.GuardSection:Label({ Text = "Chases whoever steals from you and" })
sections.GuardSection:Label({ Text = "swings the shovel at them. Needs a Shovel." })

sections.StealInfoSection:Header({ Text = "Info" })
sections.StealInfoSection:Label({ Text = "Night-only. Auto-teleports to each" })
sections.StealInfoSection:Label({ Text = "fruit, steals, then returns home." })

-- // ========================================== \\ --
-- //                   MISC                     \\ --
-- // ========================================== \\ --

sections.MiscMoveSection:Header({ Text = "Movement" })
currentSpeed = 25
walkSpeedPropConnection = nil
sections.MiscMoveSection:Slider({
    Name = "Walk Speed",
    Default = 25, Minimum = 16, Maximum = 200, DisplayMethod = "Value", Precision = 0,
    Callback = function(speed)
        currentSpeed = speed
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = speed end
        end
    end
}, "WalkSpeedSlider")

sections.MiscMapSection:Header({ Text = "Map events" })
sections.MiscMapSection:Toggle({
    Name = "Auto-collect Gold/Rainbow seed (Shooting Star)",
    Default = true,
    Callback = function(state) autoSeedEventEnabled = state end
}, "AutoSeedEventToggle")
sections.MiscMapSection:Dropdown({
    Name = "Only collect types (empty = all)",
    Multi = true, Search = false, Options = { "Gold", "Rainbow" }, Default = {},
    Callback = function(val) selectedEventSeedTypes = toArray(val) end
}, "EventSeedTypesDropdown")
sections.MiscMapSection:Label({ Text = "Auto-teleports to the pack to grab it." })

sections.MiscFpsSection:Header({ Text = "FPS Boost (mass farm)" })
sections.MiscFpsSection:Toggle({
    Name = "FPS Boost (no shadows/fx, low quality)",
    Default = false,
    Callback = function(s) fpsBoostEnabled = s; if s then applyFpsBoost() end end
}, "FpsBoostToggle")
sections.MiscFpsSection:Toggle({
    Name = "MAX FPS (strip + DELETE other gardens)",
    Default = false,
    Callback = function(s) fpsMaxEnabled = s; if s then fpsBoostEnabled = true; applyFpsBoost() end end
}, "FpsMaxToggle")
sections.MiscFpsSection:Label({ Text = "MAX deletes other plots: +37% FPS (46->63" })
sections.MiscFpsSection:Label({ Text = "live), CPU -27%. Breaks Steal til rejoin." })
sections.MiscFpsSection:Slider({
    Name = "FPS Cap (0=uncapped)",
    Default = 0, Minimum = 0, Maximum = 240, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) fpsCap = v; applyFpsCap() end
}, "FpsCapSlider")
sections.MiscFpsSection:Button({
    Name = "Re-apply FPS Boost",
    Callback = function() applyFpsBoost() end
})
sections.MiscFpsSection:Button({
    Name = "DELETE other gardens (max; breaks Steal)",
    Callback = function()
        local n = nukeOtherGardens()
        Window:Notify({ Title = "FPS", Description = "Deleted " .. tostring(n) .. " other garden(s). Steal/Guard need a rejoin.", Lifetime = 5 })
    end
})
sections.MiscFpsSection:Label({ Text = "FPS is frame-capped; MAX cuts draw-calls/VRAM" })
sections.MiscFpsSection:Label({ Text = "so you can run more alts at once." })

sections.MiscWebhookSection:Header({ Text = "Discord Webhook" })
webhookUrlInput = sections.MiscWebhookSection:Input({
    Name = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = "",
    Callback = function(text) webhookUrl = text end
}, "WebhookUrlInput")
sections.MiscWebhookSection:Toggle({
    Name = "Status Report",
    Default = false,
    Callback = function(s) webhookReportEnabled = s end
}, "WebhookReportToggle")
sections.MiscWebhookSection:Slider({
    Name = "Report Interval (min)",
    Default = 5, Minimum = 1, Maximum = 120, DisplayMethod = "Value", Precision = 0,
    Callback = function(v) webhookReportInterval = v end
}, "WebhookIntervalSlider")
sections.MiscWebhookSection:Toggle({
    Name = "Notify on Rare Tame",
    Default = false,
    Callback = function(s) webhookTameEnabled = s end
}, "WebhookTameToggle")
webhookTameRarityDropdown = sections.MiscWebhookSection:Dropdown({
    Name = "Tame notify rarities (empty = all)",
    Multi = true,
    Search = true,
    Options = {},
    Default = {},
    Callback = function(val) selectedWebhookTameRarities = toArray(val) end
}, "WebhookTameRaritiesDropdown")
sections.MiscWebhookSection:Toggle({
    Name = "Notify on Mutation",
    Default = false,
    Callback = function(s)
        if s then
            -- mark fruit you already hold as seen, so only NEW mutations ping
            for _, t in ipairs(fruitTools()) do
                local mut, id = t:GetAttribute("Mutation"), t:GetAttribute("Id")
                if mut and id then webhookSeenMutations[id] = true end
            end
        end
        webhookMutationEnabled = s
    end
}, "WebhookMutationToggle")
sections.MiscWebhookSection:Button({
    Name = "Test Webhook",
    Callback = function()
        sendWebhook({ title = "Test", description = "Webhook is working.", color = 5763719 })
    end
})
task.spawn(function()
    pcall(function() webhookTameRarityDropdown:ClearOptions(); webhookTameRarityDropdown:InsertOptions(knownRarities()) end)
end)

sections.MiscQolSection:Header({ Text = "Quality of Life" })
sections.MiscQolSection:Toggle({
    Name = "Remove Roll UI",
    Default = false,
    Callback = function(state) removeRollUiEnabled = state end
}, "RemoveRollUiToggle")
sections.MiscQolSection:Label({ Text = "Skips the egg/crate opening animation." })
sections.MiscQolSection:Toggle({
    Name = "Status Overlay (dark screen)",
    Default = false,
    Callback = function(state) setStatusOverlay(state) end
}, "StatusOverlayToggle")
sections.MiscQolSection:Label({ Text = "Full black info screen. 'Hide GUI' button reveals the game." })

sections.MiscQolSection:Header({ Text = "Auto Execute" })
sections.MiscQolSection:Toggle({
    Name = "Auto Execute on Teleport",
    Default = false,
    Callback = function(v)
        local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or queueonteleport
        if not qot then
            pcall(function()
                Window:Notify({
                    Title = "Auto Execute",
                    Description = "Executor doesn't support queue_on_teleport.",
                    Lifetime = 5
                })
            end)
            return
        end
        if v then
            qot([[
                task.wait(10)
                loadstring(game:HttpGet(""))()
            ]])
        else
            qot("")
        end
    end
}, "AutoExecuteToggle")

function setupWalkSpeedWatcher(character)
    if walkSpeedPropConnection then
        walkSpeedPropConnection:Disconnect()
        walkSpeedPropConnection = nil
    end
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = currentSpeed
    walkSpeedPropConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if humanoid.WalkSpeed ~= currentSpeed then humanoid.WalkSpeed = currentSpeed end
    end)
end
table.insert(hubConnections, LocalPlayer.CharacterAdded:Connect(function(character) setupWalkSpeedWatcher(character) end))
if LocalPlayer.Character then setupWalkSpeedWatcher(LocalPlayer.Character) end

-- // ========================================== \\ --
-- //          ACTIVITY LOOPS (PRIORITY)         \\ --
-- // ========================================== \\ --

-- AutoSteal (120) - teleport to each fruit is automatic; returning home banks it
task.spawn(function()
    while not stopped do
        if autoStealEnabled and ActivityPriority:CanStart("AutoSteal") then
            ActivityPriority:SetActivity("AutoSteal")
            if isNight() then
                local targets = stealable()
                if stealMostExpensive then
                    table.sort(targets, function(a, b) return stealValue(a.model) > stealValue(b.model) end)
                end
                for _, f in ipairs(targets) do
                    if not (autoStealEnabled and isNight()) then break end
                    -- teleport to the fruit and settle (so the server accepts the steal from range)
                    if f.pos then local hrp = hrpNow(); if hrp then pcall(function() hrp.CFrame = CFrame.new(f.pos + Vector3.new(0, 4, 0)) end); task.wait(0.35) end end
                    pcall(function() BeginSteal:Fire(f.owner, f.plantId, f.fruitId) end)
                    task.wait(0.15)  -- let the server register the begin before completing
                    pcall(function() CompleteSteal:Fire() end)
                    -- STAY at the fruit until it's actually carried — big fruit take ~0.7s+ to register,
                    -- leaving early was dropping the loot ("returns empty"). Confirm carry before banking.
                    local t0 = os.clock()
                    while not LocalPlayer:GetAttribute("CarryingStolenFruit") and os.clock() - t0 < 2 and autoStealEnabled and isNight() do
                        task.wait(0.1)
                    end
                    if stealReturnHome and LocalPlayer:GetAttribute("CarryingStolenFruit") then
                        local base, hrp = myBasePos(), hrpNow()
                        if base and hrp then
                            pcall(function() hrp.CFrame = CFrame.new(base + Vector3.new(0, 4, 0)) end)
                            local t1 = os.clock()
                            while LocalPlayer:GetAttribute("CarryingStolenFruit") and os.clock() - t1 < 3 and autoStealEnabled do task.wait(0.15) end
                        end
                    end
                    if stealDelay > 0 then task.wait(stealDelay) end
                end
            end
            ActivityPriority:ClearActivity("AutoSteal")
        end
        waitInterval(function() return autoStealEnabled end, 1.5)
    end
end)

-- MapSeed (110) - auto-collect Shooting Star seed packs
task.spawn(function()
    while not stopped do
        if autoSeedEventEnabled and ActivityPriority:CanStart("MapSeed") then
            ActivityPriority:SetActivity("MapSeed")
            collectMapSeeds()
            ActivityPriority:ClearActivity("MapSeed")
        end
        waitInterval(function() return autoSeedEventEnabled end, 0.5)
    end
end)

-- AutoSell (100)
task.spawn(function()
    while not stopped do
        if autoSellActive() and ActivityPriority:CanStart("AutoSell") then
            ActivityPriority:SetActivity("AutoSell")
            sellAllNow()
            ActivityPriority:ClearActivity("AutoSell")
        end
        waitInterval(function() return autoSellActive() end, sellInterval)
    end
end)

-- AutoBuyGear (90)
task.spawn(function()
    while not stopped do
        local gearList = (gearBuyMode == "All") and gearNames() or selectedGear
        if autoBuyGearActive() and #gearList > 0 and ActivityPriority:CanStart("AutoBuyGear") then
            ActivityPriority:SetActivity("AutoBuyGear")
            for _, name in ipairs(gearList) do
                if not autoBuyGearActive() then break end
                local stock = stockOf("GearShop", name)
                if stock == nil or stock > 0 then
                    pcall(function() PurchaseGear:Fire(name) end)
                    task.wait(0.25)
                end
            end
            ActivityPriority:ClearActivity("AutoBuyGear")
        end
        waitInterval(function() return autoBuyGearActive() end, buyGearInterval)
    end
end)

-- AutoBuySeed (80) - stock + affordability aware
task.spawn(function()
    while not stopped do
        local seedList = (seedBuyMode == "All") and seedNames() or selectedSeeds
        if autoBuySeedActive() and #seedList > 0 and ActivityPriority:CanStart("AutoBuySeed") then
            ActivityPriority:SetActivity("AutoBuySeed")
            for _, name in ipairs(seedList) do
                if not autoBuySeedActive() then break end
                local stock, bought, price = stockOf("SeedShop", name), 0, seedPrice(name)
                local buyLim = tonumber(seedBuyLimits[name])
                local seedCap = (buyLim and buyLim > 0) and buyLim or buySeedPerTick  -- 0/absent = use BuySeedPerTick
                while bought < seedCap do
                    if stock ~= nil and stock <= 0 then break end
                    if price > 0 and getSheckles() < price then break end
                    local ok = pcall(function() PurchaseSeed:Fire(name) end)
                    if not ok then break end
                    bought = bought + 1
                    if stock ~= nil then stock = stock - 1 end
                    task.wait(0.15)
                end
            end
            ActivityPriority:ClearActivity("AutoBuySeed")
        end
        waitInterval(function() return autoBuySeedActive() end, buySeedInterval)
    end
end)

-- AutoBuyCrate (88) - cosmetic crates from the crate/props shop
task.spawn(function()
    while not stopped do
        if autoBuyCrateActive() and #selectedCrates > 0 and ActivityPriority:CanStart("AutoBuyCrate") then
            ActivityPriority:SetActivity("AutoBuyCrate")
            for _, name in ipairs(selectedCrates) do
                if not autoBuyCrateActive() then break end
                local stock = stockOf("CrateShop", name)
                if stock == nil or stock > 0 then
                    pcall(function() PurchaseCrate:Fire(name) end)
                    task.wait(0.25)
                end
            end
            ActivityPriority:ClearActivity("AutoBuyCrate")
        end
        waitInterval(function() return autoBuyCrateActive() end, crateBuyInterval)
    end
end)

-- AutoFavorite (130) - protects fruit from sell; runs frequently so new fruit is covered
task.spawn(function()
    while not stopped do
        if (autoFavMutationEnabled or autoFavInventoryEnabled or autoFavFarmEnabled or autoFavFilterEnabled) and ActivityPriority:CanStart("AutoFavorite") then
            ActivityPriority:SetActivity("AutoFavorite")
            if autoFavFilterEnabled then favoriteSweep() end
            if autoFavMutationEnabled or autoFavInventoryEnabled then
                for _, t in ipairs(fruitTools()) do
                    if not (autoFavMutationEnabled or autoFavInventoryEnabled) then break end
                    local want = autoFavInventoryEnabled or (t:GetAttribute("Mutation") ~= nil)
                    if want and t:GetAttribute("IsFavorite") ~= true then
                        favoriteFruit(t:GetAttribute("Id"), true); task.wait(0.05)
                    end
                end
            end
            if autoFavFarmEnabled then
                for _, d in ipairs(farmFruit()) do
                    if not autoFavFarmEnabled then break end
                    if d:GetAttribute("IsFavorite") ~= true then
                        favoriteFruit(d:GetAttribute("Id"), true); task.wait(0.05)
                    end
                end
            end
            ActivityPriority:ClearActivity("AutoFavorite")
        end
        waitInterval(function() return autoFavMutationEnabled or autoFavInventoryEnabled or autoFavFarmEnabled or autoFavFilterEnabled end, 3)
    end
end)

-- AutoCollect (30) - teleport onto dropped items so proximity pickup grabs them
task.spawn(function()
    while not stopped do
        if (autoCollectSeedsEnabled or autoCollectAcornsEnabled) and ActivityPriority:CanStart("AutoCollect") then
            ActivityPriority:SetActivity("AutoCollect")
            local targets = {}
            if autoCollectSeedsEnabled then for _, it in ipairs(droppedItems("Seed")) do targets[#targets + 1] = it end end
            if autoCollectAcornsEnabled then for _, it in ipairs(droppedItems("Acorn")) do targets[#targets + 1] = it end end
            for _, it in ipairs(targets) do
                if not (autoCollectSeedsEnabled or autoCollectAcornsEnabled) then break end
                local hrp = hrpNow()
                if hrp and it.inst and it.inst.Parent then
                    pcall(function() hrp.CFrame = CFrame.new(it.pos + Vector3.new(0, 3, 0)) end)
                    task.wait(0.05)
                end
            end
            ActivityPriority:ClearActivity("AutoCollect")
        end
        waitInterval(function() return autoCollectSeedsEnabled or autoCollectAcornsEnabled end, 2)
    end
end)

-- Auto Collect Seed (Gold/Rainbow) - scans server spawn locations and presses ProximityPrompt
task.spawn(function()
    while not stopped do
        if autoCollectSeedGoldRainbowEnabled and ActivityPriority:CanStart("AutoCollectSeed") then
            ActivityPriority:SetActivity("AutoCollectSeed")
            collectGoldRainbowSeedPrompts()
            ActivityPriority:ClearActivity("AutoCollectSeed")
        end
        waitInterval(function() return autoCollectSeedGoldRainbowEnabled end, 0.75)
    end
end)

-- Remove Roll UI - keeps the egg/crate opening animation hidden (rewards still arrive)
task.spawn(function()
    while not stopped do
        if removeRollUiEnabled then
            local gui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            local node = gui and gui:FindFirstChild("RollFrame_New", true)
            if node then
                if node:IsA("ScreenGui") then
                    pcall(function() node.Enabled = false end)
                else
                    pcall(function() node.Visible = false end)
                    local sg = node:FindFirstAncestorWhichIsA("ScreenGui")
                    if sg then pcall(function() sg.Enabled = false end) end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- Webhook: periodic status report (not a priority activity - no character movement)
task.spawn(function()
    while not stopped do
        if webhookReportEnabled and webhookUrl ~= "" then
            sendWebhook({
                title = "Grow a Garden 2 - Status",
                color = 3447003,
                fields = {
                    { name = "Sheckles", value = fmt(getSheckles()), inline = true },
                    { name = "Tokens", value = fmt(tonumber(pdata().Tokens) or 0), inline = true },
                    { name = "Fruit", value = fruitCount() .. "/" .. maxFruitCap(), inline = true },
                    { name = "Sold (total)", value = fmt(soldTotal), inline = true },
                    { name = "Pets owned", value = tostring(#ownedPetNames()), inline = true },
                    { name = "Runtime", value = fmtRuntime(os.time() - hubStartTime), inline = true }
                }
            })
        end
        waitInterval(function() return webhookReportEnabled end, math.max(60, webhookReportInterval * 60))
    end
end)

-- Webhook: notify when a mutated fruit shows up (one ping per unique fruit id)
task.spawn(function()
    while not stopped do
        if webhookMutationEnabled and webhookUrl ~= "" then
            for _, t in ipairs(fruitTools()) do
                local mut, id = t:GetAttribute("Mutation"), t:GetAttribute("Id")
                if mut and id and not webhookSeenMutations[id] then
                    webhookSeenMutations[id] = true
                    local fname = tostring(t:GetAttribute("Fruit") or t.Name)
                    local pass = #webhookSeedNames == 0
                    if not pass then
                        for _, want in ipairs(webhookSeedNames) do
                            if mutationStrHas(tostring(mut), want) or fname == want then pass = true; break end
                        end
                    end
                    if pass then
                        sendWebhook({
                            title = "Mutation found!",
                            color = 15844367,
                            fields = {
                                { name = "Fruit", value = fname, inline = true },
                                { name = "Mutation", value = tostring(mut), inline = true }
                            }
                        })
                    end
                end
            end
        end
        waitInterval(function() return webhookMutationEnabled end, 5)
    end
end)

-- Eggs / Crates / Seed Packs
local function openCategory(category, packet, getEnabled)
    for nm, count in pairs(invNames(category)) do
        for _ = 1, math.min(count, 25) do
            if not getEnabled() then return end
            local ok, res = pcall(function() return packet:Fire(nm) end)
            if not ok then break end
            if type(res) == "table" and res.Success == false then break end
            task.wait(0.3)
        end
    end
end
task.spawn(function()
    while not stopped do
        if autoEggActive() and ActivityPriority:CanStart("AutoEgg") then
            ActivityPriority:SetActivity("AutoEgg")
            openCategory("Eggs", OpenEgg, function() return autoEggActive() end)
            ActivityPriority:ClearActivity("AutoEgg")
        end
        waitInterval(function() return autoEggActive() end, openInterval)
    end
end)
task.spawn(function()
    while not stopped do
        if autoCrateActive() and ActivityPriority:CanStart("AutoCrate") then
            ActivityPriority:SetActivity("AutoCrate")
            openCategory("Crates", OpenCrate, function() return autoCrateActive() end)
            ActivityPriority:ClearActivity("AutoCrate")
        end
        waitInterval(function() return autoCrateActive() end, openInterval)
    end
end)
task.spawn(function()
    while not stopped do
        if autoPackActive() and ActivityPriority:CanStart("AutoPack") then
            ActivityPriority:SetActivity("AutoPack")
            openCategory("SeedPacks", OpenSeedPack, function() return autoPackActive() end)
            ActivityPriority:ClearActivity("AutoPack")
        end
        waitInterval(function() return autoPackActive() end, openInterval)
    end
end)

-- AutoSprinkler (65)
task.spawn(function()
    while not stopped do
        if autoSprinklerActive() and ActivityPriority:CanStart("AutoSprinkler") then
            ActivityPriority:SetActivity("AutoSprinkler")
            local pid = myPlotId()
            if pid then
                local placed = existingPlantPositions()
                for _, t in ipairs(toolsByAttr("Sprinkler")) do
                    if not autoSprinklerActive() then break end
                    if #gearsToUse == 0 or inSet(gearsToUse, t:GetAttribute("Sprinkler")) then
                        local hum = humanoid(); if not hum then break end
                        pcall(function() hum:EquipTool(t) end); task.wait(0.22)
                        local held = heldToolByAttr("Sprinkler"); if not held then break end
                        for _, pos in ipairs(plantGrid(8)) do
                            local far = true
                            for _, op in ipairs(placed) do if (pos - op).Magnitude < 12 then far = false; break end end
                            if far then
                                pcall(function() PlaceSprinkler:Fire(pos, held:GetAttribute("Sprinkler"), held, pid) end)
                                placed[#placed + 1] = pos; task.wait(0.3)
                                break
                            end
                        end
                    end
                end
                pcall(function() local h = humanoid(); if h then h:UnequipTools() end end)
            end
            ActivityPriority:ClearActivity("AutoSprinkler")
        end
        waitInterval(function() return autoSprinklerActive() end, sprinklerInterval)
    end
end)

-- AutoWater (60)
task.spawn(function()
    while not stopped do
        if autoWaterActive() and ActivityPriority:CanStart("AutoWater") then
            ActivityPriority:SetActivity("AutoWater")
            local t = equipByAttr("WateringCan")
            if t and (#gearsToUse == 0 or inSet(gearsToUse, t:GetAttribute("WateringCan"))) then
                local name = t:GetAttribute("WateringCan")
                for _, pos in ipairs(existingPlantPositions()) do
                    if not autoWaterActive() then break end
                    pcall(function() UseWateringCan:Fire(pos - Vector3.new(0, 0.3, 0), name, t) end)
                    task.wait(0.2)
                end
            end
            ActivityPriority:ClearActivity("AutoWater")
        end
        waitInterval(function() return autoWaterActive() end, waterInterval)
    end
end)

-- AutoBuyPets (56) - walk up (auto-teleport) and tame affordable wild pets
task.spawn(function()
    while not stopped do
        if autoBuyPetsActive() and ActivityPriority:CanStart("AutoBuyPets") then
            ActivityPriority:SetActivity("AutoBuyPets")
            for _, w in ipairs(wildPets()) do
                if not autoBuyPetsActive() then break end
                local pname = w.name or ""
                local pcap = tonumber(petBuyCaps[pname])
                local capped = pcap and (petBuyCount[pname] or 0) >= pcap
                if not capped and w.owner == 0 and w.price > 0 and w.price <= maxPetPrice and getSheckles() >= w.price
                    and petMatch(pname, selectedTamePetNames, selectedTamePetRarities) then
                    if w.pos then atPosition(w.pos, function() WildPetTame:Fire(w.part) end)
                    else pcall(function() WildPetTame:Fire(w.part) end) end
                    task.wait(0.4)
                    if (w.part == nil or not w.part.Parent) then
                        petBuyCount[pname] = (petBuyCount[pname] or 0) + 1
                        if webhookTameEnabled and webhookUrl ~= "" then
                            local r = petRarity(pname)
                            local nameOk = #webhookTamePetNames == 0 or inSet(webhookTamePetNames, pname)
                            local rarityOk = #selectedWebhookTameRarities == 0 or table.find(selectedWebhookTameRarities, r)
                            if nameOk and rarityOk then
                                sendWebhook({
                                    title = "Wild pet tamed!",
                                    color = 3066993,
                                    fields = {
                                        { name = "Pet", value = (pname ~= "" and pname) or "?", inline = true },
                                        { name = "Rarity", value = (r ~= "" and r) or "?", inline = true },
                                        { name = "Price", value = fmt(w.price), inline = true }
                                    }
                                })
                            end
                        end
                    end
                end
            end
            ActivityPriority:ClearActivity("AutoBuyPets")
        end
        waitInterval(function() return autoBuyPetsActive() end, petBuyInterval)
    end
end)

-- AutoSellPets (54)
task.spawn(function()
    while not stopped do
        if autoSellPetsEnabled and #selectedSellPets > 0 and ActivityPriority:CanStart("AutoSellPets") then
            ActivityPriority:SetActivity("AutoSellPets")
            local set = {}; for _, n in ipairs(selectedSellPets) do set[n] = true end
            for _, t in ipairs(toolsByAttr("PetId")) do
                if not autoSellPetsEnabled then break end
                local nm = t:GetAttribute("PetName") or t.Name
                if set[nm] then
                    local hum = humanoid(); if hum then pcall(function() hum:EquipTool(t) end); task.wait(0.25) end
                    pcall(function() SellPet:Fire(t:GetAttribute("PetId")) end)
                    task.wait(0.3)
                end
            end
            ActivityPriority:ClearActivity("AutoSellPets")
        end
        waitInterval(function() return autoSellPetsEnabled end, 4)
    end
end)

-- AutoEquipPets (52) - equip = toggle-follower by pet UUID (RequestEquipByName is a dead legacy path; live-verified 2026-06-15)
task.spawn(function()
    while not stopped do
        if autoEquipPetsActive() and ActivityPriority:CanStart("AutoEquipPets") then
            ActivityPriority:SetActivity("AutoEquipPets")
            local cap = tonumber(LocalPlayer:GetAttribute("MaxEquippedPets")) or 3
            local have = equippedPetCount()
            if have < cap then
                local pool = unequippedPets()  -- {id,name} from replica (Equipped==false); toggling one equips it
                local used = {}
                if #equipLoadout > 0 then
                    -- explicit loadout: equip in slot order (slot is server-controlled, so order approximates it). GAG2 has no pet level, so e.level is ignored.
                    table.sort(equipLoadout, function(a, b) return (tonumber(a.slot) or 99) < (tonumber(b.slot) or 99) end)
                    for _, e in ipairs(equipLoadout) do
                        if not autoEquipPetsActive() or have >= cap then break end
                        if e.name then
                            for _, p in ipairs(pool) do
                                if not used[p.id] and p.name == e.name then
                                    pcall(function() RequestToggleFollower:Fire(p.id) end)
                                    used[p.id] = true; have = have + 1; task.wait(0.5)
                                    break
                                end
                            end
                        end
                    end
                else
                    for _, p in ipairs(pool) do
                        if not autoEquipPetsActive() or have >= cap then break end
                        if not used[p.id] and petMatch(p.name, selectedEquipPetNames, selectedEquipPetRarities) then
                            pcall(function() RequestToggleFollower:Fire(p.id) end)
                            used[p.id] = true; have = have + 1; task.wait(0.5)
                        end
                    end
                end
            end
            ActivityPriority:ClearActivity("AutoEquipPets")
        end
        waitInterval(function() return autoEquipPetsActive() end, 12)
    end
end)

-- AutoPetSlot (50)
task.spawn(function()
    while not stopped do
        if autoPetSlotActive() and ActivityPriority:CanStart("AutoPetSlot")
            and (targetPetSlots == 0 or petSlotDoneCount < targetPetSlots) then
            ActivityPriority:SetActivity("AutoPetSlot")
            pcall(function() RequestPetSlot:Fire() end)
            if targetPetSlots > 0 then
                petSlotDoneCount = petSlotDoneCount + 1
                if petSlotDoneCount >= targetPetSlots then autoPetSlotEnabled = false end
            end
            ActivityPriority:ClearActivity("AutoPetSlot")
        end
        waitInterval(function() return autoPetSlotActive() end, 20)
    end
end)

-- AutoSkill (48)
task.spawn(function()
    while not stopped do
        if autoSkillActive() and #selectedSkills > 0 and ActivityPriority:CanStart("AutoSkill") then
            ActivityPriority:SetActivity("AutoSkill")
            for _, stat in ipairs(selectedSkills) do
                if not autoSkillActive() then break end
                pcall(function() SpendSkillPoint:Fire(stat) end)
                task.wait(0.25)
            end
            ActivityPriority:ClearActivity("AutoSkill")
        end
        waitInterval(function() return autoSkillActive() end, 6)
    end
end)

-- AutoExpand (45)
task.spawn(function()
    while not stopped do
        if autoExpandActive() and ActivityPriority:CanStart("AutoExpand")
            and (expandTargetCount == 0 or expandDoneCount < expandTargetCount) then
            ActivityPriority:SetActivity("AutoExpand")
            pcall(function() ExpandGarden:Fire() end)
            if expandTargetCount > 0 then
                expandDoneCount = expandDoneCount + 1
                if expandDoneCount >= expandTargetCount then autoExpandEnabled = false end
            end
            ActivityPriority:ClearActivity("AutoExpand")
        end
        waitInterval(function() return autoExpandActive() end, 12)
    end
end)

-- AutoDaily (44)
task.spawn(function()
    while not stopped do
        if autoDailyActive() and ActivityPriority:CanStart("AutoDaily") then
            ActivityPriority:SetActivity("AutoDaily")
            pcall(function() CheckDailyDeal:Fire() end); task.wait(0.3)
            pcall(function() UseDailyDealAll:Fire() end)
            ActivityPriority:ClearActivity("AutoDaily")
        end
        waitInterval(function() return autoDailyActive() end, 60)
    end
end)

-- AutoPlant (40) - multi-select; each seed fills free raycast-grid spots until depleted
task.spawn(function()
    while not stopped do
        if autoPlantActive() and #selectedPlantSeeds > 0 and ActivityPriority:CanStart("AutoPlant") then
            ActivityPriority:SetActivity("AutoPlant")
            local grid = plantGrid(plantSpacing)
            if #grid > 0 then
                local occupied = existingPlantPositions()
                local function isClear(pos)
                    for _, op in ipairs(occupied) do
                        if (Vector2.new(pos.X, pos.Z) - Vector2.new(op.X, op.Z)).Magnitude < 1 then return false end
                    end
                    return true
                end
                local free = {}
                for _, p in ipairs(grid) do if isClear(p) then free[#free + 1] = p end end
                table.clear(plantSeedCount)
                local fi, planted = 1, 0
                for _, name in ipairs(selectedPlantSeeds) do
                    if not autoPlantActive() or fi > #free then break end
                    if maxAutoPlant > 0 and planted >= maxAutoPlant then break end
                    if not inSet(plantBlacklist, name) then
                        local plantLim = tonumber(plantSeedLimits[name])
                        local seedCap = (plantLim and plantLim > 0) and plantLim or nil  -- nil/0 = unlimited
                        local hum = humanoid(); if not hum then break end
                        local tool = toolsByAttr("SeedTool", name)[1]
                        if tool then
                            pcall(function() hum:EquipTool(tool) end); task.wait(0.22)
                            while fi <= #free do
                                if not autoPlantActive() then break end
                                if maxAutoPlant > 0 and planted >= maxAutoPlant then break end
                                if seedCap and (plantSeedCount[name] or 0) >= seedCap then break end
                                local held = heldToolByAttr("SeedTool")
                                if not held or held:GetAttribute("SeedTool") ~= name then break end
                                pcall(function() PlantSeed:Fire(free[fi], name, held) end)
                                plantSeedCount[name] = (plantSeedCount[name] or 0) + 1
                                planted = planted + 1
                                fi = fi + 1; task.wait(0.12)
                            end
                        end
                    end
                end
            end
            ActivityPriority:ClearActivity("AutoPlant")
        end
        waitInterval(function() return autoPlantActive() end, plantInterval)
    end
end)

-- AutoHarvest (20) - caps at MaxFruitCapacity, yields a frame per collect, sells when full
task.spawn(function()
    while not stopped do
        if autoHarvestActive() and ActivityPriority:CanStart("AutoHarvest") then
            ActivityPriority:SetActivity("AutoHarvest")
            local list = ripeHarvests()
            if #list == 0 then
                if autoSellActive() and fruitCount() > 0 then sellAllNow() end
            else
                local cap = maxFruitCap()
                for _, h in ipairs(list) do
                    if not autoHarvestActive() then break end
                    if fruitCount() >= cap - 1 then break end
                    if harvestModelPasses(h.model) then
                        pcall(function() CollectFruit:Fire(h.plantId, h.fruitId) end)
                        maybeFavoriteHarvest(h.model, h.fruitId)  -- protect keepers from SellAll
                        task.wait()
                    end
                end
                if autoSellActive() then sellAllNow() end
            end
            ActivityPriority:ClearActivity("AutoHarvest")
        end
        waitInterval(function() return autoHarvestActive() end, harvestInterval)
    end
end)

-- live status (Plot / Sheckles)
task.spawn(function()
    while not stopped do
        pcall(function()
            local id = myPlotId()
            plotLabel:UpdateName("Plot: " .. (id and tostring(id) or "?"))
            cashLabel:UpdateName("Sheckles: " .. fmt(getSheckles()))
        end)
        task.wait(2)
    end
end)

-- AutoMailClaim (43) - claim all received mail on an interval
task.spawn(function()
    while not stopped do
        if autoMailClaimEnabled and ActivityPriority:CanStart("AutoMailClaim") then
            ActivityPriority:SetActivity("AutoMailClaim")
            mailClaimAll()
            ActivityPriority:ClearActivity("AutoMailClaim")
            pcall(function() if mailInboxLabel then mailInboxLabel:UpdateName("Inbox: " .. mailInboxCount()) end end)
        end
        if autoMailClaimEnabled then
            waitInterval(function() return autoMailClaimEnabled end, mailClaimInterval)
        else
            task.wait(1)
        end
    end
end)

-- AutoMailSend (42) - mail selected items to the resolved username on an interval
task.spawn(function()
    while not stopped do
        if autoMailSendEnabled and ActivityPriority:CanStart("AutoMailSend") then
            ActivityPriority:SetActivity("AutoMailSend")
            pcall(doMailSend)
            ActivityPriority:ClearActivity("AutoMailSend")
        end
        if autoMailSendEnabled then
            waitInterval(function() return autoMailSendEnabled end, mailSendInterval)
        else
            task.wait(1)
        end
    end
end)

-- Field Guard (150) - hit whoever steals from us; StealStarted tells the victim who the thief is
if StealStarted then
    table.insert(hubConnections, StealStarted.OnClientEvent:Connect(function(plr)
        if typeof(plr) == "Instance" and plr:IsA("Player") and plr ~= LocalPlayer then
            guardThieves[plr] = os.clock()
        end
    end))
end
if StealCancelled then
    table.insert(hubConnections, StealCancelled.OnClientEvent:Connect(function(plr)
        if plr then guardThieves[plr] = nil end
    end))
end
task.spawn(function()
    while not stopped do
        if fieldGuardEnabled and ActivityPriority:CanStart("FieldGuard") then
            local now = os.clock()
            for plr, t in pairs(guardThieves) do
                if (not plr.Parent) or (now - t > 15) then guardThieves[plr] = nil end
            end
            -- fallback: anyone actively carrying/stealing fruit is a thief
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and (plr:GetAttribute("IsStealingFruit") == true or plr:GetAttribute("CarryingStolenFruit") == true) then
                    guardThieves[plr] = now
                end
            end
            if next(guardThieves) then
                ActivityPriority:SetActivity("FieldGuard")
                local savedHrp = hrpNow()
                local savedCF = savedHrp and savedHrp.CFrame
                for plr in pairs(guardThieves) do
                    if not fieldGuardEnabled then break end
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        if (os.clock() - (guardHitCooldown[plr] or 0)) >= 0.55 then
                            faceAndHit(plr)
                            guardHitCooldown[plr] = os.clock()
                            task.wait(0.1)
                        end
                    end
                end
                local hrp = hrpNow()
                if hrp and savedCF then pcall(function() hrp.CFrame = savedCF end) end
                ActivityPriority:ClearActivity("FieldGuard")
            end
        end
        if fieldGuardEnabled then task.wait(0.4) else task.wait(1.5) end
    end
end)

-- // ========================================== \\ --
-- //                 SETTINGS                   \\ --
-- // ========================================== \\ --

sections.SettingsSection:Header({ Text = "UI Settings" })
sections.SettingsSection:Slider({
    Name = "UI Size",
    Default = 0.75, Minimum = 0.5, Maximum = 2, DisplayMethod = "Value", Precision = 2,
    Callback = function(Value) Window:SetScale(Value) end
}, "UiSizeSlider")

task.spawn(function()
    task.wait(0.1)
    Window:GlobalSetting({
        Name = "UI Blur",
        Default = Window:GetAcrylicBlurState(),
        Callback = function(bool) Window:SetAcrylicBlurState(bool) end,
    })
    Window:GlobalSetting({
        Name = "Notifications",
        Default = Window:GetNotificationsState(),
        Callback = function(bool) Window:SetNotificationsState(bool) end,
    })
end)

sections.SettingsSection:Button({
    Name = "Destroy GUI",
    Callback = function() Window:Unload() end
})

task.spawn(function()
    task.wait(0.2)
    Window:CreateMinimizer({
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.new(1, -10, 0.5, 0),
        Icon = "rbxassetid://104487529937663"
    })
end)

task.spawn(function()
    task.wait(0.5)
    print("DYHUB loaded!")
    task.wait(0.5)
    if _G.KeyExpiresAt then Window:SetKeyTimer(_G.KeyExpiresAt) end
end)

-- // ========================================== \\ --
-- //        ON-SCREEN STATUS OVERLAY           \\ --
-- // ========================================== \\ --

OV_ACT = {
    AutoBuyPets = "Buying pets", AutoBuySeed = "Buying seeds", AutoBuyGear = "Buying gear",
    AutoBuyCrate = "Buying crates", AutoPlant = "Planting", AutoHarvest = "Harvesting",
    AutoSell = "Selling", AutoSteal = "Stealing", AutoSprinkler = "Placing sprinklers",
    AutoWater = "Watering", AutoEquipPets = "Equipping pets", AutoPetSlot = "Buying pet slots",
    AutoExpand = "Expanding plot", AutoDaily = "Daily deals", AutoEgg = "Opening eggs",
    AutoCrate = "Opening crates", AutoPack = "Opening packs", AutoMailClaim = "Claiming mail",
    AutoMailSend = "Sending mail", FieldGuard = "Guarding field", AutoSkill = "Spending skills",
    MapSeed = "Collecting seeds", AutoFavorite = "Favoriting",
}
function ovActivity()
    local a = ActivityPriority and ActivityPriority.currentActivity
    if not a then return "Idle" end
    return OV_ACT[a] or a
end
function ovPlantCount()
    local g = workspace:FindFirstChild("Gardens")
    g = g and g:FindFirstChild("Plot" .. tostring(myPlotId()))
    g = g and g:FindFirstChild("Plants")
    return g and #g:GetChildren() or 0
end
function ovPetGroups()
    local eq, un = {}, {}
    for _, pd in pairs(inv("Pets")) do
        if type(pd) == "table" and pd.Name then
            local nm = pd.Name
            local mut = pd.Mutation or pd.Variant or pd.Modifier  -- future-proof if mutated pets ever carry a field
            if mut and mut ~= "" and mut ~= true then nm = tostring(mut) .. " " .. nm end
            if pd.Equipped == true then eq[nm] = (eq[nm] or 0) + 1 else un[nm] = (un[nm] or 0) + 1 end
        end
    end
    return eq, un
end
function ovFmtGroup(map, cap)
    local arr = {}
    for nm, c in pairs(map) do arr[#arr + 1] = { nm, c } end
    table.sort(arr, function(a, b) if a[2] == b[2] then return a[1] < b[1] end return a[2] > b[2] end)
    local lines, shown = {}, 0
    for _, e in ipairs(arr) do
        if shown >= cap then lines[#lines + 1] = ('<font color="#888888">…and %d more</font>'):format(#arr - shown); break end
        lines[#lines + 1] = ('%s <font color="#7CFC8A">x%d</font>'):format(e[1], e[2]); shown = shown + 1
    end
    if #lines == 0 then lines[1] = '<font color="#888888">None</font>' end
    return table.concat(lines, "\n")
end
function ovEvent()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local fr = pg and pg:FindFirstChild("WeatherUI") and pg.WeatherUI:FindFirstChild("Frame")
    local act = {}
    if fr then
        for _, f in ipairs(fr:GetChildren()) do
            if f:IsA("GuiObject") and f.Visible then
                local timer
                for _, t in ipairs(f:GetDescendants()) do
                    if t:IsA("TextLabel") then
                        local s = tostring(t.Text)
                        if s:match("%d+m") or s:match("^%s*%d+s%s*$") or s:match("%d+:%d+") then timer = s:gsub("^%s+", ""):gsub("%s+$", ""); break end
                    end
                end
                act[#act + 1] = timer and (f.Name .. ' <font color="#9FE8B0">(' .. timer .. ')</font>') or f.Name
            end
        end
    end
    return (#act > 0) and table.concat(act, ", ") or "None"
end
function ovIncomePerMin()
    local now = os.clock()
    local bal = getSheckles()
    table.insert(ovBalSamples, { t = now, bal = bal })
    while #ovBalSamples > 1 and (now - ovBalSamples[1].t) > 60 do table.remove(ovBalSamples, 1) end
    local first = ovBalSamples[1]
    local dt = now - first.t
    if dt < 5 then return nil end
    return (bal - first.bal) / (dt / 60)
end

function destroyStatusOverlay()
    if ovGui then pcall(function() ovGui:Destroy() end) end
    ovGui, ovRefs = nil, nil
end

function buildStatusOverlay()
    destroyStatusOverlay()
    local parent
    pcall(function() parent = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) end)
    parent = parent or game:GetService("CoreGui")
    if not pcall(function() local t = Instance.new("ScreenGui"); t.Parent = parent; t:Destroy() end) then
        parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    local function mk(class, props, par)
        local o = Instance.new(class)
        for k, v in pairs(props) do o[k] = v end
        if par then o.Parent = par end
        return o
    end
    local FONT = Enum.Font.GothamBold

    local gui = mk("ScreenGui", { Name = "DYHUBStatus", ResetOnSpawn = false, IgnoreGuiInset = true,
        DisplayOrder = 99999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    gui.Parent = parent

    -- full-screen black backdrop (the "dark screen" that hides the game)
    local backdrop = mk("Frame", { Name = "Backdrop", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(8, 8, 10),
        BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 1 }, gui)

    -- "Hide GUI" button (top-right) -> turns the dark screen OFF (shows game), small pill restores
    local hideBtn = mk("TextButton", { Text = "Hide GUI", Font = FONT, TextSize = 18, TextColor3 = Color3.fromRGB(15, 25, 18),
        BackgroundColor3 = Color3.fromRGB(76, 200, 130), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -24, 0, 20),
        Size = UDim2.fromOffset(150, 50), AutoButtonColor = true, ZIndex = 50 }, gui)
    mk("UICorner", { CornerRadius = UDim.new(0, 10) }, hideBtn)
    local pill = mk("TextButton", { Text = "🌱 DYHUB", Font = FONT, TextSize = 16, TextColor3 = Color3.fromRGB(15, 25, 18),
        BackgroundColor3 = Color3.fromRGB(76, 200, 130), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -24, 0, 20),
        Size = UDim2.fromOffset(120, 40), Visible = false, ZIndex = 50 }, gui)
    mk("UICorner", { CornerRadius = UDim.new(0, 10) }, pill)
    hideBtn.MouseButton1Click:Connect(function() backdrop.Visible = false; hideBtn.Visible = false; pill.Visible = true end)
    pill.MouseButton1Click:Connect(function() backdrop.Visible = true; hideBtn.Visible = true; pill.Visible = false end)

    -- scalable content container (UIScale keeps it fitting any screen)
    local content = mk("Frame", { Name = "Content", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.06),
        Size = UDim2.fromOffset(480, 10), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 2 }, backdrop)
    local uiscale = mk("UIScale", { Scale = 1 }, content)
    mk("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center }, content)

    local function lbl(txt, size, color, order, align, h)
        return mk("TextLabel", { Text = txt, Font = FONT, TextSize = size, TextColor3 = color or Color3.fromRGB(235, 235, 240),
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, h or (size + 8)), RichText = true,
            TextXAlignment = align or Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = order }, content)
    end
    local function divider(order)
        mk("Frame", { BackgroundColor3 = Color3.fromRGB(150, 100, 230), BackgroundTransparency = 0.2, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 2), LayoutOrder = order }, content)
    end

    lbl("🌱 DYHUB", 34, Color3.fromRGB(190, 140, 255), 1)
    local nameLbl = lbl("👤 …", 22, Color3.fromRGB(120, 180, 255), 2)
    local actLbl = lbl("📋 …", 18, Color3.fromRGB(210, 210, 220), 3)
    local timeLbl = lbl("⏰ 00:00:00", 16, Color3.fromRGB(180, 180, 190), 4)
    divider(5)
    local cols = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 330), LayoutOrder = 6, ZIndex = 2 }, content)
    local function colLbl(xs)
        return mk("TextLabel", { Text = "", Font = FONT, TextSize = 18, TextColor3 = Color3.fromRGB(230, 230, 235),
            BackgroundTransparency = 1, Size = UDim2.new(0.5, -10, 1, 0), Position = UDim2.fromScale(xs, 0), RichText = true,
            TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }, cols)
    end
    local leftLbl = colLbl(0)
    local rightLbl = colLbl(0.5)
    divider(7)
    local eventLbl = lbl("✨ Event: None", 20, Color3.fromRGB(180, 230, 180), 8, nil, 30)

    -- responsive scale from viewport
    local function rescale()
        local cam = workspace.CurrentCamera
        local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
        uiscale.Scale = math.clamp(math.min(vp.X / 1100, vp.Y / 820), 0.45, 2.2)
    end
    rescale()
    if workspace.CurrentCamera then
        table.insert(hubConnections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale))
    end

    ovGui = gui
    ovRefs = { name = nameLbl, act = actLbl, time = timeLbl, left = leftLbl, right = rightLbl, event = eventLbl }
end

function refreshStatusOverlay()
    if not ovRefs then return end
    ovRefs.name.Text = "👤 " .. LocalPlayer.Name
    ovRefs.act.Text = "📋 " .. ovActivity()
    ovRefs.time.Text = "⏰ " .. fmtRuntime(os.time() - hubStartTime)
    local bal = getSheckles()
    local ipm = ovIncomePerMin()
    local ipmStr
    if ipm == nil then ipmStr = '<font color="#bbbbbb">~ …</font>'
    else
        local up = ipm >= 0
        ipmStr = ('<font color="%s">~ %s%s/min</font>'):format(up and "#7CFC8A" or "#FF7A7A", up and "+" or "-", fmt(math.abs(math.floor(ipm))))
    end
    ovRefs.left.Text = table.concat({
        '<b>💰 Sheckles:</b>  ' .. fmt(bal),
        '<b>📈 Income:</b>  ' .. ipmStr,
        '<b>🌱 Planted:</b>  ' .. ovPlantCount(),
        '<b>🍎 Fruits:</b>  ' .. fruitCount() .. '<font color="#888888"> / ' .. maxFruitCap() .. '</font>',
        '<b>🏡 Expansions:</b>  ' .. (tonumber(pdata().OwnedExpansions) or 0),
    }, "\n\n")
    local eq, un = ovPetGroups()
    local petCap = tonumber(LocalPlayer:GetAttribute("MaxEquippedPets")) or 3
    local eqN = 0; for _, c in pairs(eq) do eqN = eqN + c end
    ovRefs.right.Text = table.concat({
        ('<b>🐾 Equipped <font color="#7CFC8A">%d/%d</font>:</b>\n'):format(eqN, petCap) .. ovFmtGroup(eq, 6),
        '<b>🎒 Inventory:</b>\n' .. ovFmtGroup(un, 8),
    }, "\n\n")
    ovRefs.event.Text = "✨ Event: " .. ovEvent()
end

function setStatusOverlay(on)
    statusOverlayEnabled = on and true or false
    if statusOverlayEnabled then
        if not ovGui then pcall(buildStatusOverlay) end
        pcall(refreshStatusOverlay)
    else
        destroyStatusOverlay()
    end
end

task.spawn(function()
    while not stopped do
        if statusOverlayEnabled and ovRefs then pcall(refreshStatusOverlay) end
        task.wait(1)
    end
end)

-- // ---- _G config (one-click inject; set BEFORE loadstring) ---- //
-- Example (every key optional; arrays OR {name=count} maps where noted):
-- _G.DYHUBConfig = {
--   AutoFarm = {
--     Harvest=true, Sell=true, Plant=true, Expand=true, Daily=true,
--     PlantSeeds={"Carrot"},                       -- which seeds to plant
--     LimitPlantSeed={Carrot=10, Bamboo=20},       -- per-seed plant cap / pass
--     LimitAutoPlant=200, BlacklistSeeds={"Bamboo"},  -- global plant cap / pass (0=unlimited); never-plant list
--     BuySeeds="All",                              -- or {"Carrot","Tomato"}
--     LimitBuySeed={Carrot=10, Bamboo=9999}, BuySeedPerTick=8,  -- per-seed / global buy cap per pass
--     BuyGears={"Rare Sprinkler"}, GearsToUse={"Rare Sprinkler"},  -- buy + deploy (Sprinkler/Watering only)
--     Sprinkler=true, Water=true, PlotExpansions=1,
--   },
--   Pets = {
--     AutoBuy=true, MaxPrice=25000, TameNames={"Unicorn"}, TameRarities={"Mythic"},
--     BuyPets={Monkey=99, Robin=5},                -- per-pet tame cap (lifetime); keys also act as tame allow-list
--     Equip=true, EquipNames={"Unicorn"}, EquipRarities={"Secret"},
--     EquipLoadout={ {"Unicorn",5,1}, {"Golden Dragonfly",10,2} },  -- {name,level,slot}; order~=slot, level best-effort
--     AutoPetSlot=true, UnlockPetSlots=6,          -- number = stop after N purchases this session
--   },
--   Open = { Eggs=true, Crates=true, Packs=true },
--   Map  = { CollectSeedPacks=true, SeedPackTypes={"Gold","Rainbow"} },
--   Mail = {
--     AutoClaim=true, AutoSend=false, Username="", Usernames={"u1","u2"},  -- overflow: fill u1 then u2
--     Category="Seeds", Items={}, Count=1, ItemCounts={Carrot=100},        -- per-item counts
--     ItemsByCategory={ Pets={Robin=5}, Seeds={Carrot=100} }, Note="",     -- cross-category one-shot (singular Pet/Seed also ok)
--   },
--   Sell = {
--     FavoriteFilter=true, KeepMutations={"Rainbow","Gold"}, KeepFruits={}, KeepMinWeight=0, KeepMinPrice=0,
--     FavoriteByFruit={ ["Horned Melon"]={"Rainbow","Gold"} },  -- keep fruit only if mutation matches ({} = any)
--   },
--   Harvest = { IgnoreMutations={}, IgnoreTypes={}, MinWeight=0 },
--   Steal = { Auto=false, MostExpensive=true }, Guard=false,
--   Fps = { Boost=true, Max=false, Cap=0 }, Wipe = { Seeds={} },
--   Webhook = { URL="", Report=false, ReportInterval=5, TameNotify=true, TameRarities={"Mythic"},
--     TamePetNames={"Unicorn"}, MutationNotify=true, SeedNames={"Rainbow"}, Note="", DiscordId="" },
-- }
function applyGConfig()
    local C = (_G and _G.DYHUBConfig) or (getgenv and getgenv().DYHUBConfig)
    if type(C) ~= "table" then return end
    local function arr(v) return (type(v) == "table") and v or {} end
    local function b(v) return v and true or false end
    if type(C.AutoFarm) == "table" then
        local f = C.AutoFarm
        if f.Enabled ~= nil then autoFarmEnabled = b(f.Enabled) end
        if f.Actions ~= nil then selectedAutoFarmActions = arr(f.Actions) end
        if f.Harvest ~= nil then autoHarvestEnabled = b(f.Harvest) end
        if f.Sell ~= nil then autoSellEnabled = b(f.Sell) end
        if f.Plant ~= nil then autoPlantEnabled = b(f.Plant) end
        if f.Expand ~= nil then autoExpandEnabled = b(f.Expand) end
        if f.Daily ~= nil then autoDailyEnabled = b(f.Daily) end
        if f.PlantSeeds ~= nil then selectedPlantSeeds = arr(f.PlantSeeds) end
        if f.BuySeeds == "All" then seedBuyMode = "All"; autoBuySeedEnabled = true
        elseif f.BuySeeds ~= nil then selectedSeeds = arr(f.BuySeeds); autoBuySeedEnabled = #selectedSeeds > 0 end
        if f.BuyGears == "All" then gearBuyMode = "All"; autoBuyGearEnabled = true
        elseif f.BuyGears ~= nil then selectedGear = arr(f.BuyGears); autoBuyGearEnabled = #selectedGear > 0 end
        -- per-seed buy caps + global buy-per-pass
        if f.LimitBuySeed ~= nil then seedBuyLimits = arr(f.LimitBuySeed) end
        if f.BuySeedPerTick ~= nil then buySeedPerTick = tonumber(f.BuySeedPerTick) or buySeedPerTick end
        -- per-seed plant caps + global plant cap + plant blacklist
        if f.LimitPlantSeed ~= nil then plantSeedLimits = arr(f.LimitPlantSeed) end
        if f.LimitAutoPlant ~= nil then maxAutoPlant = tonumber(f.LimitAutoPlant) or 0 end
        if f.BlacklistSeeds ~= nil then plantBlacklist = arr(f.BlacklistSeeds) end
        -- bounded plot expansion
        if f.PlotExpansions ~= nil then expandTargetCount = tonumber(f.PlotExpansions) or 0; expandDoneCount = 0; if expandTargetCount > 0 then autoExpandEnabled = true end end
        -- gear deploy ("Gears To Use"); only Sprinkler / Watering Can are server-deployable
        if f.Sprinkler ~= nil then autoSprinklerEnabled = b(f.Sprinkler) end
        if f.Water ~= nil then autoWaterEnabled = b(f.Water) end
        if f.GearsToUse ~= nil then
            gearsToUse = arr(f.GearsToUse)
            -- convenience auto-enable, but never override an explicit Sprinkler=/Water= the user set above
            for _, gn in ipairs(gearsToUse) do
                local s = tostring(gn)
                if f.Sprinkler == nil and s:find("Sprinkler") then autoSprinklerEnabled = true end
                if f.Water == nil and s:find("Water") then autoWaterEnabled = true end
            end
        end
    end
    if type(C.Mail) == "table" then
        local m = C.Mail
        if m.AutoClaim ~= nil then autoMailClaimEnabled = b(m.AutoClaim) end
        if m.AutoSend ~= nil then autoMailSendEnabled = b(m.AutoSend) end
        if m.Username then mailSendUsername = tostring(m.Username); mailSendUserId = nil end
        if m.Category then mailSendCategory = tostring(m.Category) end
        if m.Items then selectedMailItems = arr(m.Items) end
        if m.Count then mailSendCount = tonumber(m.Count) or 1 end
        if m.Note then mailSendNote = tostring(m.Note) end
        if m.Usernames ~= nil then mailSendUsernames = arr(m.Usernames) end
        if m.ItemCounts ~= nil then mailItemCounts = arr(m.ItemCounts) end
        if m.ItemsByCategory ~= nil and type(m.ItemsByCategory) == "table" then mailSendByCategory = m.ItemsByCategory end
    end
    if type(C.Sell) == "table" then
        local s = C.Sell
        if s.FavoriteFilter ~= nil then autoFavFilterEnabled = b(s.FavoriteFilter) end
        if s.KeepMutations then selectedFavMutations = arr(s.KeepMutations) end
        if s.KeepFruits then selectedFavFruits = arr(s.KeepFruits) end
        if s.KeepMinWeight then favMinWeight = tonumber(s.KeepMinWeight) or 0 end
        if s.KeepMinPrice then favMinPrice = tonumber(s.KeepMinPrice) or 0 end
        if s.FavoriteByFruit ~= nil and type(s.FavoriteByFruit) == "table" then selectedFavByFruit = s.FavoriteByFruit end
    end
    if type(C.Harvest) == "table" then
        local h = C.Harvest
        if h.IgnoreMutations then ignoredHarvestMutations = arr(h.IgnoreMutations) end
        if h.IgnoreTypes then ignoredHarvestTypes = arr(h.IgnoreTypes) end
        if h.MinWeight then minHarvestWeight = tonumber(h.MinWeight) or 0 end
    end
    if type(C.Steal) == "table" then
        if C.Steal.Auto ~= nil then autoStealEnabled = b(C.Steal.Auto) end
        if C.Steal.MostExpensive ~= nil then stealMostExpensive = b(C.Steal.MostExpensive) end
    end
    if C.Guard ~= nil then fieldGuardEnabled = b(C.Guard) end
    if type(C.Fps) == "table" then
        if C.Fps.Max then fpsMaxEnabled = true; fpsBoostEnabled = true end
        if C.Fps.Boost then fpsBoostEnabled = true end
        if C.Fps.Cap then fpsCap = tonumber(C.Fps.Cap) or 0 end
        if fpsBoostEnabled then pcall(applyFpsBoost) end
        if fpsCap and fpsCap > 0 then pcall(applyFpsCap) end
    end
    if type(C.Pets) == "table" then
        local p = C.Pets
        if p.AutoBuy ~= nil then autoBuyPetsEnabled = b(p.AutoBuy) end
        if p.MaxPrice ~= nil then maxPetPrice = tonumber(p.MaxPrice) or maxPetPrice end
        if p.TameNames ~= nil then selectedTamePetNames = arr(p.TameNames) end
        if p.TameRarities ~= nil then selectedTamePetRarities = arr(p.TameRarities) end
        if type(p.BuyPets) == "table" then
            petBuyCaps = p.BuyPets
            -- if no explicit tame allow-list, derive it from the cap-map keys
            if #selectedTamePetNames == 0 then
                local names = {}
                for nm in pairs(petBuyCaps) do names[#names + 1] = nm end
                selectedTamePetNames = names
            end
            autoBuyPetsEnabled = true
        end
        if p.Equip ~= nil then autoEquipPetsEnabled = b(p.Equip) end
        if p.EquipNames ~= nil then selectedEquipPetNames = arr(p.EquipNames) end
        if p.EquipRarities ~= nil then selectedEquipPetRarities = arr(p.EquipRarities) end
        if type(p.EquipLoadout) == "table" then
            local lo = {}
            for _, e in ipairs(p.EquipLoadout) do
                if type(e) == "table" then
                    lo[#lo + 1] = { name = e[1] or e.name, level = tonumber(e[2] or e.level), slot = tonumber(e[3] or e.slot) }
                end
            end
            equipLoadout = lo
            if #lo > 0 then autoEquipPetsEnabled = true end
        end
        if p.AutoPetSlot ~= nil then autoPetSlotEnabled = b(p.AutoPetSlot) end
        if p.UnlockPetSlots ~= nil then
            if type(p.UnlockPetSlots) == "number" then
                if p.UnlockPetSlots <= 0 then
                    autoPetSlotEnabled = false  -- numeric 0 = buy none, not "unlimited+enabled"
                else
                    targetPetSlots = p.UnlockPetSlots; petSlotDoneCount = 0; autoPetSlotEnabled = true
                end
            else
                autoPetSlotEnabled = b(p.UnlockPetSlots)
            end
        end
    end
    if type(C.Open) == "table" then
        local o = C.Open
        if o.Eggs ~= nil then autoEggEnabled = b(o.Eggs) end
        if o.Crates ~= nil then autoCrateEnabled = b(o.Crates) end
        if o.Packs ~= nil then autoPackEnabled = b(o.Packs) end
    end
    if type(C.Map) == "table" then
        local mp = C.Map
        if mp.CollectSeedPacks ~= nil then autoSeedEventEnabled = b(mp.CollectSeedPacks) end
        if mp.CollectSeedPrompts ~= nil then autoCollectSeedGoldRainbowEnabled = b(mp.CollectSeedPrompts) end
        if mp.SeedPackTypes ~= nil then selectedEventSeedTypes = arr(mp.SeedPackTypes) end
    end
    if type(C.Webhook) == "table" then
        local w = C.Webhook
        if w.URL ~= nil then webhookUrl = tostring(w.URL) end
        if w.Report ~= nil then webhookReportEnabled = b(w.Report) end
        if w.ReportInterval ~= nil then webhookReportInterval = tonumber(w.ReportInterval) or webhookReportInterval end
        if w.TameNotify ~= nil then webhookTameEnabled = b(w.TameNotify) end
        if w.TameRarities ~= nil then selectedWebhookTameRarities = arr(w.TameRarities) end
        if w.TamePetNames ~= nil then webhookTamePetNames = arr(w.TamePetNames) end
        if w.MutationNotify ~= nil then webhookMutationEnabled = b(w.MutationNotify) end
        if w.SeedNames ~= nil then webhookSeedNames = arr(w.SeedNames) end
        if w.Note ~= nil then webhookNote = tostring(w.Note) end
        if w.DiscordId ~= nil then webhookDiscordId = tostring(w.DiscordId) end
    end
    if type(C.Wipe) == "table" and C.Wipe.Seeds then selectedWipeSeeds = arr(C.Wipe.Seeds) end
    pcall(function() Window:Notify({ Title = "DYHUB", Description = "_G.DYHUBConfig applied.", Lifetime = 4 }) end)
end

MacLib:SetFolder("DYHUB")
task.spawn(function()
    MacLib:LoadAutoLoadConfig()
end)
task.spawn(function()
    task.wait(1.6)  -- after autoload, so explicit _G config wins
    pcall(applyGConfig)
end)
task.spawn(function()
    tabs.Farm:Select()
end)

-- expose a stop handle so the next run of this hub can unload this copy
if getgenv then
    getgenv()._GAG2_Stop = function()
        stopped = true
        autoFarmEnabled = false; selectedAutoFarmActions = {}
        autoPlantEnabled = false; autoHarvestEnabled = false; autoSellEnabled = false
        autoBuySeedEnabled = false; autoBuyGearEnabled = false; autoBuyCrateEnabled = false
        autoExpandEnabled = false; autoDailyEnabled = false; autoSprinklerEnabled = false
        autoWaterEnabled = false; autoSkillEnabled = false
        autoEquipPetsEnabled = false; autoPetSlotEnabled = false; autoBuyPetsEnabled = false; autoSellPetsEnabled = false
        autoEggEnabled = false; autoCrateEnabled = false; autoPackEnabled = false
        autoStealEnabled = false; autoSeedEventEnabled = false
        autoCollectSeedsEnabled = false; autoCollectAcornsEnabled = false; autoCollectSeedGoldRainbowEnabled = false
        autoFavMutationEnabled = false; autoFavInventoryEnabled = false; autoFavFarmEnabled = false
        autoFavFilterEnabled = false; autoMailClaimEnabled = false; autoMailSendEnabled = false
        fieldGuardEnabled = false; wipeBusy = false
        removeRollUiEnabled = false
        statusOverlayEnabled = false; pcall(destroyStatusOverlay)
        pcall(function() if walkSpeedPropConnection then walkSpeedPropConnection:Disconnect() end end)
        for _, c in ipairs(hubConnections) do pcall(function() c:Disconnect() end) end
        table.clear(hubConnections)
        pcall(function() Window:Unload() end)
    end
end
