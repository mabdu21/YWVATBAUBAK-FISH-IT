--// DYHUB Fix It Up - Repair100 + Anti AFK patch v13
--// Changes: v13 hard-locks Repair100 engine reading to the exact EnginePositions.EngineBlock.EngineLabel.TextLabel on the currently seated vehicle. It will never prefer/fallback to another engine folder such as i4 2.0 when the real label says i4 1.9D.

--// NAH WTF SO AI BUT I'M USING CLAUDE CODE OPUS 4.8 🤑😈🥀💎

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UIS            = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local StarterGui     = game:GetService("StarterGui")

local LP   = Players.LocalPlayer
local PG   = LP:WaitForChild("PlayerGui")

local RUNTIME_KEY = "STOP_USE_DEX_DYHUB"
local GUI_NAME    = "STOP_USE_DEX"

-- Sell-point position
local SELL_CF     = CFrame.new(-1911, 6, -786)
local SELL_EXIT   = Vector3.new(-1921, 5, -789)

-- Repair-zone position at nearest Pitstop(Small)
local REPAIR_CF   = CFrame.new(-1122, 4.5, -1524)

-- Central drop-off for all parts before re-apply at Pitstop(Small)
local DROP_CF     = CFrame.new(-1121, 2.2, -1543)

-- ──────────────────────────────────────────────────────────
--  CONSTANTS
-- ──────────────────────────────────────────────────────────
local REPAIR_PASSES   = 1   -- How many repair rounds per cycle
local TP_SETTLE       = 0.85 -- Short settle; each repaired part now gets a fixed 20s repair wait
local CLICK_INTERVAL  = 0.25
local BUY_CLICK_INTERVAL  = 2      -- Click car purchase detector every 2s
local SELL_RETRY_INTERVAL = 2      -- Re-fire sell prompt every 2s until vehicle is gone
local CONFIRM_CLICK_INTERVAL = 2   -- Press HUD confirmation button every 2s while confirmation is open
local CONFIRM_WAIT_TIMEOUT = 12    -- Max wait for confirmation to appear after buy/sell action
local CONFIRM_CLOSE_TIMEOUT = 30   -- Max wait for confirmation to close after pressing Confirm
local BUY_POST_CONFIRM_LOAD_WAIT = 2.00 -- After confirming a purchase, wait 2s because the game deletes/reloads the car
local VEHICLE_READY_TIMEOUT = 22   -- Max wait for bought vehicle to come back and be stable
local VEHICLE_STABLE_TIME = 0.35   -- Small stability check after the 2s reload wait
local BOUGHT_NEAREST_RADIUS = 65   -- Bought car should respawn very close to the player/original buy spot
local BUY_MAX_TARGET_ATTEMPTS = 12 -- If one car cannot be bought, try another matching % car instead of stopping
local SELL_RETRY_AFTER_BLOCK = 25  -- If sale confirmation does not open, wait 25 sec before trying again
local MOVEABLE_REAPPLY_RADIUS = 100
local REAPPLY_RETRY_ATTEMPTS = 3
local REAPPLY_RETRY_DELAY = 0.35
local NOT_ENOUGH_MONEY_TEXT = "You don't have enough money"
local NOT_ENOUGH_GOLD_TEXT = "You don't have enough gold"
local BUY_FAIL_SCAN_TIME = 2.5      -- After clicking/confirming buy, scan new HUD notifications for no-money before entering a car
local REPAIR_WAIT_PER_PART = 20         -- Fixed repair time per part/station before moving to the parts pile
local REPAIR_PARALLEL_ALL = true     -- true = Machine 1/2/3 + BatteryCharger + PartsWasher start together
local REPAIR_WAKE_INTERVAL = 1.00       -- Re-seat/re-click while a repair station is still waiting for the part
local MOVEABLE_WAIT_TIMEOUT = 5         -- Wait briefly for a stripped part to appear in MoveableParts
local PARALLEL_ASSIGN_TIMEOUT = 1.75    -- Wider scan per part name so newly stripped parts are not missed
local PART_TP_VERIFY_RADIUS = 5.5       -- How close a part must be to count as really teleported
local PART_TP_RETRIES = 7               -- Anti-visual/snap-back retry count for repair parts
local PART_TP_SETTLE_FAST = 0.28        -- Short settle used by the parallel repair loader
local CAR_TWEEN_SPEED = 85              -- Studs/second for Movement Mode = Tween
local CAR_TWEEN_MIN_TIME = 0.35
local CAR_TWEEN_MAX_TIME = 9.00

-- Repair 100% replacement flow positions
local REPAIR100_CAR_CF        = CFrame.new(-1495, 5, -525)
local REPAIR100_BUY_PLAYER_CF = CFrame.new(-1448, 5, -534)
local REPAIR100_SWAP_CF       = CFrame.new(-1484, 4, -508)
local REPLACED_PART_HIDE_CF   = CFrame.new(999, 99, 999)
local REPAIR100_NEAR_RADIUS   = 20
local REPAIR100_BUY_DELAY     = 1.00
local REPAIR100_NEW_PART_TIMEOUT = 5.00
local REPAIR100_OLD_PART_TIMEOUT = 4.50
local REPAIR100_FORCE_REMOVE_RETRIES = 5
local REPAIR100_FORCE_REAPPLY_RETRIES = 5
local REPAIR100_FRESH_BACKUP_RADIUS = 65 -- still requires the object to be newly spawned after the buy snapshot
local REPAIR100_PART_BUY_ORDER = {"Injectors", "AirIntake", "Sparkplugs"}

-- EngineLabel can briefly show a default/stale engine while a bought car is loading.
-- Do not lock the parts-store folder until the same exact engine text stays stable.
local ENGINE_READ_TIMEOUT      = 5.00
local ENGINE_READ_MIN_TIME     = 1.50
local ENGINE_READ_STABLE_TIME  = 1.10

local REPAIR100_REAPPLY_ORDER  = {"Injectors", "AirIntake", "Sparkplugs"}
local REPAIR100_REPLACEMENT_PART_SET = {
    Injectors = true,
    AirIntake = true,
    Sparkplugs = true,
}
local TELEPORT_WARNING_TEXT = "Teleport mode is active. Higher ban risk — use carefully."

local MOVEMENT_MODE_OPTIONS = {"Tween", "Teleport"}

local JUNKYARD_SELECT_OPTIONS = {
    {Text = "< 0%",  Value = 0},
    {Text = "< 1%",  Value = 1},
    {Text = "< 2%",  Value = 2},
    {Text = "< 3%",  Value = 3},
    {Text = "< 10%", Value = 10},
    {Text = "< 20%", Value = 20},
    {Text = "< 30%", Value = 30},
    {Text = "< 40%", Value = 40},
    {Text = "< 50%", Value = 50},
}

local JUNKYARD_ESP_NAME = "FixItUp_CarChance_ESP"
local JUNKYARD_TAG_NAME = "FixItUp_CarChance_Tag"

local PART_POSITIONS = {
    -- Pitstop(Small) selected by nearest distance to REPAIR_CF.
    -- These are repair-table placement positions, not player/car movement points.
    Machine1       = Vector3.new(-1105.98755, 4, -1531.06824),
    Machine2       = Vector3.new(-1105.98755, 4, -1525.22461),
    Machine3       = Vector3.new(-1167.86255, 4, -1520.80237),
    Radiator       = Vector3.new(-1105.61816, 4, -1536.56946),
    Battery        = Vector3.new(-1106.80957, 4, -1518.53784),
}

-- Transmission name variants (any one may exist on a given car)
local TRANSMISSION_NAMES = {
    "1-Speed Manual",
    "2-Speed Manual",
    "3-Speed Manual",
    "4-Speed Manual",
    "5-Speed Manual",
    "6-Speed Manual",
    "7-Speed DCT",
    "8-Speed DCT",
    "8-Speed TC",
}

-- Parts to attempt removing (script skips ones that don't exist).
-- Keep Injectors / AirIntake / Sparkplugs here so the normal strip/reapply flow
-- can still remove and reinstall them. They are only skipped from repair stations.
local REMOVE_ORDER = {
    "EngineBlock",
    "EngineBlock_Forged",
    "Battery",
    "Injectors",
    "AirIntake",
    "AirIntake_Turbo",
    "AirIntake_Sport",
    "Sparkplugs",
    "ExhaustManifold",
    "CylinderHead",
    "Transmission",   -- fires literal Transmission + every transmission variant below
    "Radiator",
    "Alternator",
    "TimingBelt",
    "VETC",
}

-- Re-apply order. Non-repairable fresh parts are kept here so they can be
-- installed after the repaired parts pile is ready; they are not sent to machines.
local REAPPLY_ORDER = {
    "EngineBlock",
    "EngineBlock_Forged",
    "CylinderHead",
    "Injectors",
    "Transmission",   -- placeholder resolved at runtime
    "Radiator",
    "ExhaustManifold",
    "AirIntake",
    "AirIntake_Turbo",
    "AirIntake_Sport",
    "Sparkplugs",
    "Alternator",
    "TimingBelt",
    "Battery",
    "VETC",
}

-- Repair station definitions
local REPAIR_STATIONS = {
    {
        partName   = "CylinderHead",
        displayName= "Machine 1",
        -- Requested mapping: Machine 1 repairs CylinderHead + every transmission variant.
        -- AirIntake/AirIntake_Turbo/AirIntake_Sport are intentionally not sent here.
        partNames  = {
            "CylinderHead",
            "1-Speed Manual",
            "2-Speed Manual",
            "3-Speed Manual",
            "4-Speed Manual",
            "5-Speed Manual",
            "6-Speed Manual",
            "7-Speed DCT",
            "8-Speed DCT",
            "8-Speed TC",
        },
        stationPath= {"Map","FirstCity","Buildings","Pitstop(Small)","Station1"},
        targetPosition = PART_POSITIONS.Machine1,
        buttonPath = {"GrindingMachine","Button","ClickDetector"},
        screenPath = {"GrindingMachine","Screen","Part","SurfaceGui","TextLabel"},
        preferNearestMachine = true,
    },
    {
        partName   = "ExhaustManifold",
        displayName= "Machine 2",
        partNames  = {"ExhaustManifold","VETC"},
        stationPath= {"Map","FirstCity","Buildings","Pitstop(Small)","Station1"},
        targetPosition = PART_POSITIONS.Machine2,
        buttonPath = {"GrindingMachine","Button","ClickDetector"},
        screenPath = {"GrindingMachine","Screen","Part","SurfaceGui","TextLabel"},
        preferNearestMachine = true,
    },
    {
        partName   = "EngineBlock",
        displayName= "Machine 3",
        partNames  = {"EngineBlock","EngineBlock_Forged","TimingBelt","Alternator"},
        stationPath= {"Map","FirstCity","Buildings","Pitstop(Small)","Station2"},
        targetPosition = PART_POSITIONS.Machine3,
        buttonPath = {"GrindingMachine","Button","ClickDetector"},
        screenPath = {"GrindingMachine","Screen","Part","SurfaceGui","TextLabel"},
        preferNearestMachine = true,
    },
    {
        partName   = "Radiator",
        displayName= "Radiator / PartsWasher",
        partNames  = {"Radiator"},
        stationPath= {"Map","FirstCity","Buildings","Pitstop(Small)","Station1"},
        targetPosition = PART_POSITIONS.Radiator,
        buttonPath = {"PartsWasher","Faucet","ClickDetector"},
        screenPath = nil,
    },
    {
        partName   = "Battery",
        displayName= "Battery / BatteryCharger",
        partNames  = {"Battery"},
        stationPath= {"Map","FirstCity","Buildings","Pitstop(Small)","Station1"},
        targetPosition = PART_POSITIONS.Battery,
        buttonPath = {"BatteryCharger","Button","ClickDetector"},
        screenPath = nil,
    },
}

-- ──────────────────────────────────────────────────────────
--  RUNTIME STATE
-- ──────────────────────────────────────────────────────────
local ENV = getgenv and getgenv() or _G

if ENV[RUNTIME_KEY] then
    pcall(function() ENV[RUNTIME_KEY].Destroy() end)
end

local old = PG:FindFirstChild(GUI_NAME)
if old then old:Destroy() end

local Runtime = {
    Enabled     = false,
    Alive       = true,
    Connections = {},
    Thread      = 0,
    StatusCB    = nil,   -- set to GUI setter below

    -- JunkyardHub merge settings
    SelectThreshold = 50,
    SelectText      = "< 50%",
    CarEspEnabled   = false,
    MovementMode    = "Tween",
    MovementText    = "Tween",
    Repair100Enabled = false,
    AntiAfkEnabled   = false,

    -- Stage guard: prevents the script from buying a new car while already sitting, repairing, installing or selling.
    Stage           = "Idle",
    RunToken        = 0,
    CurrentVehicleName = nil,
    LastBuyFailReason = nil,
}

ENV[RUNTIME_KEY] = Runtime

-- ──────────────────────────────────────────────────────────
--  KAITUN / AUTO EXEC CONFIG
--  Example:
--  _G.Kaitun = {
--      ["Auto Farm"] = true,
--      ["Movement Mode"] = "Tween", -- Tween / Teleport
--      ["Select Type (%)"] = "< 50%",
--      ["Car ESP"] = false,
--      ["Anti AFK"] = true,       -- hides the UI while keeping the farm running
--      ["Repair 100%"] = false,   -- buys fresh Injectors + AirIntake + Sparkplugs before the normal repair flow
--  }
--  loadstring(game:HttpGet("YOUR_LINK_HERE"))()
-- ──────────────────────────────────────────────────────────
local function syncKaitunSetting(key, value)
    local cfg = ENV.Kaitun or _G.Kaitun
    if type(cfg) == "table" then
        cfg[key] = value
    end
end

local function cleanKaitunText(value)
    local raw = tostring(value or "")
    raw = raw:gsub("94p", " ") -- non-breaking space from copy/paste
    raw = raw:gsub("%s+", " ")
    raw = raw:gsub("^%s+", ""):gsub("%s+$", "")
    return raw
end

local function applySelectTypeValue(selectedType)
    if selectedType == nil then
        return false
    end

    local raw = cleanKaitunText(selectedType)
    local asNumber = tonumber(raw)

    for _, option in ipairs(JUNKYARD_SELECT_OPTIONS) do
        if raw == option.Text or asNumber == option.Value then
            Runtime.SelectText = option.Text
            Runtime.SelectThreshold = option.Value
            syncKaitunSetting("Select Type (%)", option.Text)
            return true
        end
    end

    -- Allows copied values such as "<50%", "50%", "Select < 50%", etc.
    local extracted = tonumber(raw:match("(%d+%.?%d*)"))
    if extracted then
        for _, option in ipairs(JUNKYARD_SELECT_OPTIONS) do
            if extracted == option.Value then
                Runtime.SelectText = option.Text
                Runtime.SelectThreshold = option.Value
                syncKaitunSetting("Select Type (%)", option.Text)
                return true
            end
        end

        Runtime.SelectText = "< " .. tostring(extracted) .. "%"
        Runtime.SelectThreshold = extracted
        syncKaitunSetting("Select Type (%)", Runtime.SelectText)
        return true
    end

    return false
end

local function applyKaitunConfig()
    local cfg = ENV.Kaitun or _G.Kaitun
    if type(cfg) ~= "table" then return end

    -- Backward compatibility: old typo -> correct key.
    if cfg["Anri AFK"] ~= nil and cfg["Anti AFK"] == nil then
        cfg["Anti AFK"] = cfg["Anri AFK"]
        cfg["Anri AFK"] = nil
    end

    if cfg["Auto Farm"] ~= nil then
        Runtime.Enabled = cfg["Auto Farm"] == true
    end

    local moveMode = cfg["Movement Mode"] or cfg.MovementMode or cfg["Move Mode"]
    if moveMode == "Tween" or moveMode == "Teleport" then
        Runtime.MovementMode = moveMode
        Runtime.MovementText = moveMode
    else
        Runtime.MovementMode = "Tween"
        Runtime.MovementText = "Tween"
        syncKaitunSetting("Movement Mode", "Tween")
    end

    local esp = cfg["Car ESP"]
    if esp == nil then esp = cfg.CarESP end
    if esp ~= nil then
        Runtime.CarEspEnabled = esp == true
    end

    local repair100 = cfg["Repair 100%"]
    if repair100 == nil then repair100 = cfg.Repair100 end
    if repair100 ~= nil then
        Runtime.Repair100Enabled = repair100 == true
    end

    local antiAfk = cfg["Anti AFK"]
    if antiAfk == nil then antiAfk = cfg.AntiAFK end
    if antiAfk ~= nil then
        Runtime.AntiAfkEnabled = antiAfk == true
    end

    local selectedType = cfg["Select Type (%)"] or cfg.SelectType or cfg["Car Percent"]
    applySelectTypeValue(selectedType)
end

applyKaitunConfig()

function Runtime.Add(conn)
    table.insert(Runtime.Connections, conn)
    return conn
end

function Runtime.Destroy()
    Runtime.Alive   = false
    Runtime.Enabled = false
    Runtime.Thread  += 1

    -- Remove Junkyard ESP objects before cleanup
    pcall(function()
        local vehicles = workspace:FindFirstChild("Vehicles")
        if vehicles then
            for _, model in ipairs(vehicles:GetChildren()) do
                if model:IsA("Model") then
                    local esp = model:FindFirstChild(JUNKYARD_ESP_NAME)
                    if esp then esp:Destroy() end
                    local tag = model:FindFirstChild(JUNKYARD_TAG_NAME)
                    if tag then tag:Destroy() end
                end
            end
        end
    end)

    for _, c in ipairs(Runtime.Connections) do
        pcall(function()
            if typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            elseif typeof(c) == "Instance" then
                c:Destroy()
            elseif type(c) == "function" then
                c()
            elseif type(c) == "table" and c.Destroy then
                c:Destroy()
            end
        end)
    end

    local g = PG:FindFirstChild(GUI_NAME)
    if g then g:Destroy() end
    ENV[RUNTIME_KEY] = nil
end


-- ──────────────────────────────────────────────────────────
--  SILENT ANTI-AFK (AUTO START: PC + MOBILE)
-- ──────────────────────────────────────────────────────────
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local function startSilentAntiAfk()
    if not Runtime.AntiAfkEnabled then return end
    if Runtime._AntiAfkStarted then return end
    Runtime._AntiAfkStarted = true

    local idleConnection = LP.Idled:Connect(function()
        -- Primary method used by most executors. No UI, no status, no notify.
        local ok = pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)

        -- Fallback for executors/devices where VirtualUser is blocked or ignored.
        if not ok then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
                task.wait()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
            end)
        end
    end)

    Runtime.Add(idleConnection)
end

startSilentAntiAfk()
local restoreCharacter

-- ──────────────────────────────────────────────────────────
--  HELPER: STATUS
-- ──────────────────────────────────────────────────────────
local function setStatus(txt)
    if Runtime.StatusCB then Runtime.StatusCB(txt) end
end

local function setStage(stage, txt)
    Runtime.Stage = stage or "Idle"
    if txt then
        setStatus(txt)
    end
end

local function canContinue(runToken)
    return Runtime.Alive and Runtime.Enabled and (runToken == nil or Runtime.RunToken == runToken)
end

local function sameStage(stage)
    return Runtime.Stage == stage
end

local function hardStop(reason)
    Runtime.Enabled = false
    Runtime.Thread += 1
    Runtime.RunToken += 1
    Runtime.Stage = "Stopped"
    Runtime.CurrentVehicleName = nil
    if reason then
        setStatus(reason)
    else
        setStatus("Stopped")
    end
    pcall(restoreCharacter)
end

local function showTeleportWarning()
    setStatus("Warning: " .. TELEPORT_WARNING_TEXT)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "DYHUB Warning",
            Text = TELEPORT_WARNING_TEXT,
            Duration = 5,
        })
    end)
end


-- ──────────────────────────────────────────────────────────
--  HELPER: CHARACTER SAFETY
-- ──────────────────────────────────────────────────────────
local function getChar()   return LP.Character end
local function getHum()    local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot()   local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end

-- Restores full locomotion — critical: prevents walking-disabled bug
restoreCharacter = function()
    local hum = getHum()
    if not hum then return end
    hum.WalkSpeed   = 16
    hum.JumpPower   = 50
    hum.AutoRotate  = true
    hum.PlatformStand = false
    -- force unseat safely
    pcall(function()
        if hum.SeatPart then
            hum.Sit = false
        end
    end)
end

-- ──────────────────────────────────────────────────────────
--  HELPER: MOVEMENT MODE
--  Tween is used only for character/car movement.
--  Repair parts still use stableTeleportMoveable/teleportAndSettle.
-- ──────────────────────────────────────────────────────────
local function moveCharacterToCF(targetCF, runToken, statusText, forceTeleport)
    local char = getChar()
    local root = getRoot()
    if not char or not root or typeof(targetCF) ~= "CFrame" then return false end

    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    local mode = Runtime.MovementMode or "Tween"
    if forceTeleport or mode ~= "Tween" then
        if statusText then
            setStatus(statusText .. " • Teleport")
        end
        pcall(function()
            char:PivotTo(targetCF)
        end)
        pcall(function()
            root.CFrame = targetCF
        end)
        return true
    end

    if statusText then
        setStatus(statusText .. " • Tween")
    end

    local okStart, startCF = pcall(function()
        return char:GetPivot()
    end)
    if not okStart or typeof(startCF) ~= "CFrame" then
        startCF = root.CFrame
    end

    local dist = (startCF.Position - targetCF.Position).Magnitude
    local duration = math.clamp(dist / CAR_TWEEN_SPEED, CAR_TWEEN_MIN_TIME, CAR_TWEEN_MAX_TIME)

    local driver = Instance.new("CFrameValue")
    driver.Value = startCF

    local conn
    conn = driver:GetPropertyChangedSignal("Value"):Connect(function()
        if not char or not char.Parent then return end
        pcall(function()
            char:PivotTo(driver.Value)
        end)
        pcall(function()
            local r = getRoot()
            if r then
                r.AssemblyLinearVelocity = Vector3.zero
                r.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end)

    local tween = TweenService:Create(
        driver,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        { Value = targetCF }
    )

    tween:Play()
    local start = os.clock()
    while (runToken == nil or canContinue(runToken)) and char and char.Parent and os.clock() - start < duration do
        task.wait(0.03)
    end

    if runToken ~= nil and not canContinue(runToken) then
        pcall(function() tween:Cancel() end)
    end

    pcall(function()
        if conn then conn:Disconnect() end
        driver:Destroy()
    end)

    if runToken == nil or canContinue(runToken) then
        pcall(function()
            char:PivotTo(targetCF)
        end)
        pcall(function()
            local r = getRoot()
            if r then
                r.AssemblyLinearVelocity = Vector3.zero
                r.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end

    return true
end

-- ──────────────────────────────────────────────────────────
--  HELPER: SAFE TELEPORT (model or part)
-- ──────────────────────────────────────────────────────────
local function safeSetPivot(obj, cf)
    if not obj or not obj.Parent then return false end
    local ok = pcall(function()
        if obj:IsA("Model") then
            obj:PivotTo(cf)
        elseif obj:IsA("BasePart") then
            obj.CFrame = cf
        end
    end)
    return ok
end

-- Zero out velocities on a model
local function stopVelocity(model)
    if not model then return end

    if model:IsA("BasePart") then
        model.AssemblyLinearVelocity  = Vector3.zero
        model.AssemblyAngularVelocity = Vector3.zero
        return
    end

    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            v.AssemblyLinearVelocity  = Vector3.zero
            v.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

-- Teleport a part/model and hold for `settle` seconds to avoid snap-back
local function teleportAndSettle(obj, cf, settle)
    settle = settle or TP_SETTLE
    if not obj or not obj.Parent then return false end
    -- Anchor temporarily to defeat physics snap-back
    local parts = {}
    if obj:IsA("BasePart") then parts = {obj}
    else parts = obj:GetDescendants() end
    local wasAnchored = {}
    for _, p in ipairs(parts) do
        if p:IsA("BasePart") then
            wasAnchored[p] = p.Anchored
            p.Anchored = true
        end
    end
    safeSetPivot(obj, cf)
    stopVelocity(obj)
    task.wait(settle)
    safeSetPivot(obj, cf)   -- re-apply after wait (network may drift)
    -- Restore anchor state
    for p, wasA in pairs(wasAnchored) do
        pcall(function() p.Anchored = wasA end)
    end
    return true
end

-- ──────────────────────────────────────────────────────────
--  HELPER: CLICK DETECTOR (works on PC and mobile)
-- ──────────────────────────────────────────────────────────
local function fireClickDetector(cd, pulses)
    if not cd or not cd.Parent then return false end

    pulses = math.clamp(tonumber(pulses) or 1, 1, 3)
    local fired = false

    pcall(function()
        cd.MaxActivationDistance = math.max(cd.MaxActivationDistance or 32, 48)
    end)

    for _ = 1, pulses do
        if not cd or not cd.Parent then break end

        local ok = pcall(function()
            fireclickdetector(cd)
        end)
        fired = fired or ok

        -- Executor fallback. Some environments expose firesignal but not fireclickdetector.
        pcall(function()
            firesignal(cd.MouseClick, LP)
            fired = true
        end)

        if pulses > 1 then
            task.wait(0.055)
        end
    end

    return fired
end

-- ──────────────────────────────────────────────────────────
--  HELPER: PROXIMITY PROMPT (instant hold, PC + mobile)
-- ──────────────────────────────────────────────────────────
local function fireProximityPrompt(pp)
    if not pp then return end
    pcall(function()
        local orig = pp.HoldDuration
        pp.HoldDuration = 0
        fireproximityprompt(pp)
        task.wait(0.1)
        pp.HoldDuration = orig
    end)
end

-- ──────────────────────────────────────────────────────────
--  HELPER: RESOLVE STATION NODES
--  Pitstop(Small) and GrindingMachine can have duplicate names, so we select by nearest position.
-- ──────────────────────────────────────────────────────────
local function getInstanceWorldPosition(obj)
    if not obj or not obj.Parent then return nil end

    if obj:IsA("BasePart") then
        return obj.Position
    end

    if obj:IsA("Model") then
        local ok, cf = pcall(function()
            return obj:GetPivot()
        end)
        if ok and typeof(cf) == "CFrame" then
            return cf.Position
        end
    end

    local part = obj:FindFirstChildWhichIsA("BasePart", true)
    return part and part.Position or nil
end

local function findNearestNamedChild(parent, childName, nearPos)
    if not parent then return nil end

    nearPos = nearPos or REPAIR_CF.Position
    local best, bestDist = nil, math.huge

    for _, child in ipairs(parent:GetChildren()) do
        if child.Name == childName then
            local pos = getInstanceWorldPosition(child)
            local dist = pos and (pos - nearPos).Magnitude or math.huge
            if dist < bestDist then
                best = child
                bestDist = dist
            end
        end
    end

    -- Fallback: exact child name if there is only one or the object has no BaseParts.
    return best or parent:FindFirstChild(childName)
end

local function resolveStationRoot(stationDef)
    local node = workspace

    for _, seg in ipairs(stationDef.stationPath or {}) do
        if not node then return nil end

        if seg == "Pitstop(Small)" then
            node = findNearestNamedChild(node, seg, REPAIR_CF.Position)
        else
            node = node:FindFirstChild(seg)
        end
    end

    return node
end

local function resolvePathFrom(rootNode, pathList, stationDef)
    local node = rootNode

    for _, seg in ipairs(pathList or {}) do
        if not node then return nil end

        if seg:sub(1,1) == ":" then
            -- method call like :GetChildren()[4]
            local method = seg:match(":(%a+)%b[]")
            local idx    = tonumber(seg:match("%[(%d+)%]"))
            if method and idx then
                local list = node[method](node)
                node = list[idx]
            else
                return nil
            end
        elseif seg == "GrindingMachine" and stationDef and stationDef.preferNearestMachine then
            -- Station1 has two children named GrindingMachine. Pick the one nearest to that machine's part point.
            node = findNearestNamedChild(node, seg, stationDef.targetPosition or REPAIR_CF.Position)
        else
            node = node:FindFirstChild(seg)
        end
    end

    return node
end

local function resolveStation(stationDef)
    local stationRoot = resolveStationRoot(stationDef)
    if not stationRoot then
        return nil, nil
    end

    local btn = resolvePathFrom(stationRoot, stationDef.buttonPath, stationDef)
    if not btn then
        return nil, nil
    end

    local lbl = nil
    if stationDef.screenPath then
        lbl = resolvePathFrom(stationRoot, stationDef.screenPath, stationDef)
    end

    return btn, lbl
end

-- ──────────────────────────────────────────────────────────
--  HELPER: WAIT FOR SCREEN TEXT (polls until not "WAITING PART")
-- ──────────────────────────────────────────────────────────
local function waitForRepairComplete(screenLabel, partCF, partObj, timeout, runToken)
    if not screenLabel then return true end
    timeout = timeout or 30
    local t0 = os.clock()
    while os.clock() - t0 < timeout do
        if not canContinue(runToken) then return false end
        local txt = screenLabel.Text or ""
        if txt == "NO REPAIRS NEEDED" then return true end
        if txt == "INVALID PART"       then return true end  -- skip
        if txt == "WAITING PART" then
            -- re-teleport to wake up the station
            safeSetPivot(partObj, partCF)
            task.wait(0.5)
        else
            task.wait(0.35)
        end
    end
    return false
end

-- ──────────────────────────────────────────────────────────
--  HELPER: GET A-CHASSIS GUI
-- ──────────────────────────────────────────────────────────
local function getAChassis()
    local g = PG:FindFirstChild("A-Chassis Interface")
    if not g then return nil, "No A-Chassis Interface" end
    return g
end

-- ──────────────────────────────────────────────────────────
--  HELPER: GET CURRENT VEHICLE ID FROM A-CHASSIS
-- ──────────────────────────────────────────────────────────
local function getVehicleID()
    local gui, err = getAChassis()
    if not gui then return nil, err end
    local carVal = gui:FindFirstChild("Car", true)
    if not carVal then return nil, "Car.Value not found" end
    local ok, val = pcall(function() return carVal.Value end)
    if not ok or val == nil then return nil, "Car.Value empty" end
    if typeof(val) == "Instance" then
        return val.Name, val
    end
    return tostring(val), nil
end

-- ──────────────────────────────────────────────────────────
--  HELPER: GET ENGINE LABEL TEXT (e.g. "i4 1.9D")
--  v12: strict + stable resolver.
--  The old logic read one TextLabel instantly. Some cars briefly expose a stale/default
--  label such as "i4 2.0" while the real bought car / A-Chassis finishes loading.
-- ──────────────────────────────────────────────────────────
local function trimString(value)
    local text = tostring(value or "")
    text = text:gsub("\194\160", " ") -- non-breaking space
    text = text:gsub("\226\128\139", "") -- zero-width space
    text = text:gsub("[%c\r\n\t]+", " ")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text
end

local function normalizeEngineName(rawText)
    local text = trimString(rawText)
    text = text:gsub("^ENGINE%s*:%s*", "")
    text = trimString(text)
    if text == "" then return nil end
    return text
end

local function getPartsStoreRootForEngineRead()
    local ok, root = pcall(function()
        return workspace.PartsStore.SpareParts.Parts
    end)
    if ok and root then
        return root
    end
    return nil
end

local function readExactEngineLabel(vehicle)
    -- The ONLY trusted source for the engine model.
    -- Do not scan random labels first: some vehicles/UI copies can still contain stale/default
    -- values such as "ENGINE: i4 2.0" while the real car label says "ENGINE: i4 1.9D".
    if not vehicle or not vehicle.Parent then return nil end

    local ok, rawText = pcall(function()
        return vehicle.Body.EnginePositions.EngineBlock.EngineLabel.TextLabel.Text
    end)

    if ok then
        return normalizeEngineName(rawText)
    end

    return nil
end

local function findExactPartsStoreEngineFolder(engineName)
    engineName = normalizeEngineName(engineName)
    if not engineName then return nil end

    local root = getPartsStoreRootForEngineRead()
    if not root then return nil end

    -- First try the literal folder name.
    local folder = root:FindFirstChild(engineName)
    if folder then
        return folder
    end

    -- Then try a normalized exact match only. This handles hidden spaces / NBSP in folder names
    -- without ever falling back to another engine like i4 2.0.
    for _, child in ipairs(root:GetChildren()) do
        if normalizeEngineName(child.Name) == engineName then
            return child
        end
    end

    return nil
end

local function collectEngineLabelCandidates(vehicle)
    local candidates = {}
    local seen = {}

    local function addCandidate(rawText, priority)
        local engine = normalizeEngineName(rawText)
        if not engine or seen[engine] then return end

        seen[engine] = true
        table.insert(candidates, {
            Name = engine,
            Priority = priority or 0,
            HasStoreFolder = findExactPartsStoreEngineFolder(engine) ~= nil,
        })
    end

    -- Hard rule: if the requested exact path exists, trust ONLY that value.
    -- This fixes the i4 1.9D -> i4 2.0 bug caused by fallback scans finding stale labels.
    local exactEngine = readExactEngineLabel(vehicle)
    if exactEngine then
        addCandidate(exactEngine, 1000)
        return candidates
    end

    -- Fallback only when the exact path is missing/rebuilt. Keep this inside the current vehicle,
    -- and prioritize labels actually named/parented EngineLabel.
    if vehicle and vehicle.Parent then
        local body = vehicle:FindFirstChild("Body")
        local searchRoot = body or vehicle

        for _, obj in ipairs(searchRoot:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local raw = tostring(obj.Text or "")
                local parentName = obj.Parent and obj.Parent.Name or ""
                local priority = 0

                if parentName == "EngineLabel" then
                    priority = 80
                elseif raw:upper():find("ENGINE", 1, true) then
                    priority = 30
                end

                if priority > 0 then
                    addCandidate(raw, priority)
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        return a.Priority > b.Priority
    end)

    return candidates
end

local function getEngineLabel(vehicle)
    if not vehicle or not vehicle.Parent then return nil end

    local candidates = collectEngineLabelCandidates(vehicle)
    local best = candidates[1]

    if best then
        return best.Name
    end

    return nil
end

local function waitForStableEngineLabel(vehicle, runToken, timeout)
    timeout = timeout or ENGINE_READ_TIMEOUT

    local start = os.clock()
    local lastEngine = nil
    local stableSince = 0
    local bestEngine = nil

    setStatus("Reading engine label")

    while canContinue(runToken) and vehicle and vehicle.Parent and os.clock() - start <= timeout do
        local engine = getEngineLabel(vehicle)

        if engine then
            local hasFolder = findExactPartsStoreEngineFolder(engine) ~= nil
            if hasFolder then
                bestEngine = engine
            end

            if engine ~= lastEngine then
                lastEngine = engine
                stableSince = os.clock()
                setStatus("Engine detected: " .. tostring(engine))
            else
                local readAge = os.clock() - start
                local stableAge = os.clock() - stableSince

                if readAge >= ENGINE_READ_MIN_TIME and stableAge >= ENGINE_READ_STABLE_TIME then
                    if hasFolder then
                        setStatus("Engine locked: " .. tostring(engine))
                        return engine
                    else
                        setStatus("Engine locked but store folder missing: " .. tostring(engine))
                        return engine
                    end
                end
            end
        end

        task.wait(0.15)
    end

    -- Never swap to a different fallback engine here. If the exact car label was i4 1.9D,
    -- keep i4 1.9D even if another stale i4 2.0 label/folder exists somewhere.
    return lastEngine or bestEngine or getEngineLabel(vehicle)
end

-- ──────────────────────────────────────────────────────────
--  HELPER: FIND VEHICLE IN workspace.Vehicles
-- ──────────────────────────────────────────────────────────
local function getVehicle()
    local vehContainer = workspace:FindFirstChild("Vehicles")
    if not vehContainer then return nil, "workspace.Vehicles missing" end
    local name, obj = getVehicleID()
    if not name then return nil, "Could not identify vehicle" end
    if obj and obj:IsDescendantOf(vehContainer) then return obj end
    local v = vehContainer:FindFirstChild(name)
    if not v then return nil, "Vehicle not found: "..tostring(name) end
    return v
end


local sitInDriveSeat

-- ──────────────────────────────────────────────────────────
--  JUNKYARDHUB MERGE: VEHICLE FILTER / BUY / ESP
-- ──────────────────────────────────────────────────────────
local function getVehiclesFolder()
    return workspace:FindFirstChild("Vehicles")
end

local function getJunkChance(model)
    local value = model and model:GetAttribute("SpawnChance")
    if type(value) == "number" then
        return value
    end
    return nil
end

local function isJunkyardVehicle(model)
    return model
        and model:IsA("Model")
        and model.Parent ~= nil
        and model:GetAttribute("Junkyard") == true
end

local function getModelCF(model)
    if not model or not model.Parent then return nil end
    local ok, cf = pcall(function()
        return model:GetPivot()
    end)
    if ok and typeof(cf) == "CFrame" then
        return cf
    end
    return nil
end

local function getModelAdornee(model)
    if not model or not model.Parent then return nil end
    if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
        return model.PrimaryPart
    end
    return model:FindFirstChildWhichIsA("BasePart", true)
end

local function fmtChance(chance)
    if type(chance) ~= "number" then return "?" end
    local text = string.format("%.2f", chance)
    text = text:gsub("0+$", ""):gsub("%.$", "")
    return text .. "%"
end

local function chanceColor(chance)
    if type(chance) ~= "number" then
        return Color3.fromRGB(160, 160, 160)
    end
    if chance >= 20 then
        return Color3.fromRGB(155, 155, 160)
    elseif chance >= 12 then
        return Color3.fromRGB(96, 230, 150)
    elseif chance >= 7 then
        return Color3.fromRGB(88, 166, 255)
    elseif chance >= 3 then
        return Color3.fromRGB(183, 120, 255)
    elseif chance >= 1 then
        return Color3.fromRGB(255, 210, 90)
    end
    return Color3.fromRGB(255, 105, 130)
end

local function removeCarEsp(model)
    if not model then return end
    local esp = model:FindFirstChild(JUNKYARD_ESP_NAME)
    if esp then pcall(function() esp:Destroy() end) end
    local tag = model:FindFirstChild(JUNKYARD_TAG_NAME)
    if tag then pcall(function() tag:Destroy() end) end
end

local function applyCarEsp(model)
    if not Runtime.CarEspEnabled or not isJunkyardVehicle(model) then
        removeCarEsp(model)
        return
    end

    local chance = getJunkChance(model)
    local color = chanceColor(chance)

    local highlight = model:FindFirstChild(JUNKYARD_ESP_NAME)
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = JUNKYARD_ESP_NAME
        highlight.FillTransparency = 0.38
        highlight.OutlineTransparency = 0
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model
    end
    highlight.FillColor = color
    highlight.Enabled = true

    local tag = model:FindFirstChild(JUNKYARD_TAG_NAME)
    if not tag then
        tag = Instance.new("BillboardGui")
        tag.Name = JUNKYARD_TAG_NAME
        tag.Size = UDim2.new(0, 126, 0, 40)
        tag.AlwaysOnTop = true
        tag.MaxDistance = 2000
        tag.LightInfluence = 0
        tag.Parent = model

        local holder = Instance.new("Frame")
        holder.Name = "Holder"
        holder.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        holder.BackgroundTransparency = 0.18
        holder.BorderSizePixel = 0
        holder.Size = UDim2.new(1, 0, 1, 0)
        holder.Parent = tag

        Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 12)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.82
        stroke.Thickness = 1
        stroke.Parent = holder

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 18
        label.TextStrokeTransparency = 0.65
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Parent = holder
    end

    local adornee = getModelAdornee(model)
    if adornee then
        tag.Adornee = adornee
        local root = getRoot()
        local dist = root and (root.Position - adornee.Position).Magnitude or 40
        tag.StudsOffset = Vector3.new(0, math.clamp(3 + (dist / 60), 3.2, 12), 0)
    end

    local holder = tag:FindFirstChild("Holder")
    local label = holder and holder:FindFirstChild("Label")
    if label and label:IsA("TextLabel") then
        label.Text = fmtChance(chance)
        label.TextColor3 = color
    end
    tag.Enabled = true
end

local function refreshCarEsp()
    local vehicles = getVehiclesFolder()
    if not vehicles then return end

    for _, model in ipairs(vehicles:GetChildren()) do
        if model:IsA("Model") then
            if Runtime.CarEspEnabled then
                applyCarEsp(model)
            else
                removeCarEsp(model)
            end
        end
    end
end

local function setCarEspEnabled(state)
    Runtime.CarEspEnabled = state == true
    refreshCarEsp()
end

local function chanceMatchesSelected(chance)
    if type(chance) ~= "number" then return false end
    local limit = Runtime.SelectThreshold
    if type(limit) ~= "number" then return false end

    -- Percent filter rules:
    -- < 0%  = only exactly 0%.
    -- < X%  = X% or lower, including decimals such as 0.9, 0.1 and 0.
    -- Negative or broken values are ignored to avoid bad targets.
    if chance < 0 then return false end
    if limit <= 0 then
        return chance <= 0.000001
    end

    return chance <= limit
end

local function findBestJunkyardVehicle(ignoredNames)
    local vehicles = getVehiclesFolder()
    local root = getRoot()
    if not vehicles or not root then
        return nil
    end

    ignoredNames = ignoredNames or {}

    local bestModel = nil
    local bestChance = -math.huge
    local bestDist = math.huge

    for _, model in ipairs(vehicles:GetChildren()) do
        if isJunkyardVehicle(model) and not ignoredNames[model.Name] then
            local cd = model:FindFirstChild("ClickDetector")
            local chance = getJunkChance(model)

            if cd and chanceMatchesSelected(chance) then
                local cf = getModelCF(model)
                if cf then
                    local dist = (root.Position - cf.Position).Magnitude

                    -- Pick the highest % that still passes the selected filter first.
                    -- If two cars have the same chance, choose the nearest one.
                    if chance > bestChance or (math.abs(chance - bestChance) <= 0.000001 and dist < bestDist) then
                        bestModel = model
                        bestChance = chance
                        bestDist = dist
                    end
                end
            end
        end
    end

    return bestModel
end

local destroyVehicleSeats

local function teleportToJunkyardVehicle(model, runToken)
    local cf = getModelCF(model)
    if not cf then return false end

    -- Driver-seat guard:
    -- Before moving to a buy target, remove Body.Seats / Body.Seat first.
    -- Some cars use Seat, some use Seats, and some rebuild the folder later.
    destroyVehicleSeats(model)

    local targetCF = CFrame.new(cf.Position + Vector3.new(6, 3, 0))
    return moveCharacterToCF(targetCF, runToken, "Moving to buy car", false)
end

destroyVehicleSeats = function(vehicle)
    if not vehicle or not vehicle.Parent then return false end

    local destroyed = false

    local function wipe(obj)
        if obj and obj.Parent then
            local ok = pcall(function()
                obj:Destroy()
            end)
            if ok then
                destroyed = true
            end
        end
    end

    -- Main requested paths: Car.Body.Seats and Car.Body.Seat
    local body = vehicle:FindFirstChild("Body")
    wipe(body and body:FindFirstChild("Seats"))
    wipe(body and body:FindFirstChild("Seat"))

    -- Fallback for cars that rebuild/move the Seat/Seats folder somewhere else.
    for _, obj in ipairs(vehicle:GetDescendants()) do
        if (obj.Name == "Seats" or obj.Name == "Seat") and obj:IsA("Folder") then
            wipe(obj)
        end
    end

    return destroyed
end

local function holdDriverSeatOnly(vehicle, runToken, duration)
    -- Short repeating cleanup for overnight farming. Some cars respawn Body.Seats
    -- right after purchase/load, so deleting only once can still fail randomly.
    duration = duration or 4
    local start = os.clock()

    while canContinue(runToken) and vehicle and vehicle.Parent and os.clock() - start <= duration do
        destroyVehicleSeats(vehicle)
        task.wait(0.20)
    end
end

local function getConfirmationFrame()
    local hud = PG and PG:FindFirstChild("HUD")
    local frames = hud and hud:FindFirstChild("Frames")
    return frames and frames:FindFirstChild("Confirmation")
end

local function isConfirmationVisible()
    local confirmation = getConfirmationFrame()
    if not confirmation then
        return false
    end

    local ok, visible = pcall(function()
        return confirmation.Visible == true
    end)

    return ok and visible == true
end

local function getConfirmationButton()
    local confirmation = getConfirmationFrame()
    if not confirmation then return nil end

    local btn = confirmation:FindFirstChild("Confirm", true)
    if btn and btn:IsA("GuiButton") then
        return btn
    end

    return nil
end

local function isGuiVisibleDeep(guiObject)
    if not guiObject or not guiObject:IsA("GuiObject") then
        return false
    end

    local node = guiObject
    while node and node ~= PG do
        if node:IsA("GuiObject") and node.Visible == false then
            return false
        end
        node = node.Parent
    end

    return true
end

local function getNotificationsFolder()
    local hud = PG and PG:FindFirstChild("HUD")
    return hud and hud:FindFirstChild("Notifications")
end

local function getNotificationTextObjects()
    local items = {}
    local notifications = getNotificationsFolder()
    if not notifications then
        return items
    end

    local function addTextObject(obj)
        if not obj or not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
            return
        end

        local ok, txt = pcall(function()
            return tostring(obj.Text or "")
        end)

        if ok then
            txt = txt:gsub("^%s+", ""):gsub("%s+$", "")
            if txt ~= "" then
                table.insert(items, {
                    Object = obj,
                    Text = txt,
                    Visible = isGuiVisibleDeep(obj),
                })
            end
        end
    end

    -- Scan every notification clone. Some game builds create a new object named Template,
    -- while other builds reuse the original Template and only change its Text.
    for _, obj in ipairs(notifications:GetDescendants()) do
        addTextObject(obj)
    end

    addTextObject(notifications:FindFirstChild("Template"))
    return items
end

local function getActiveNotificationTexts()
    local texts = {}
    for _, item in ipairs(getNotificationTextObjects()) do
        if item.Visible then
            table.insert(texts, item.Text)
        end
    end
    return texts
end

local function snapshotNotificationTextObjects()
    local map = {}
    for _, item in ipairs(getNotificationTextObjects()) do
        map[item.Object] = {
            Text = item.Text,
            Visible = item.Visible,
        }
    end
    return map
end

local function isNoMoneyText(txt)
    local lower = tostring(txt or ""):lower()
    local moneyText = tostring(NOT_ENOUGH_MONEY_TEXT):lower()
    local goldText = tostring(NOT_ENOUGH_GOLD_TEXT):lower()

    return lower == moneyText
        or lower == goldText
        or lower:find("not enough money", 1, true) ~= nil
        or lower:find("enough money", 1, true) ~= nil
        or lower:find("not enough gold", 1, true) ~= nil
        or lower:find("enough gold", 1, true) ~= nil
end

local function hasActiveNotification()
    return #getActiveNotificationTexts() > 0
end

local function hasNotEnoughMoneyNotification(baseline)
    for _, item in ipairs(getNotificationTextObjects()) do
        if isNoMoneyText(item.Text) then
            -- If a baseline exists, count new notification clones, reused labels whose text changed,
            -- or reused labels that were hidden before the buy click and became visible after it.
            -- This prevents one old "no money" message from skipping every later car forever,
            -- while still catching Template objects that are reused by the HUD.
            local old = baseline and baseline[item.Object]
            if not old or old.Text ~= item.Text or (old.Visible ~= true and item.Visible == true) then
                return true, item.Text
            end
        end
    end
    return false, nil
end

local function waitForBuyFailureNotification(baseline, timeout)
    local start = os.clock()
    timeout = timeout or BUY_FAIL_SCAN_TIME

    while os.clock() - start <= timeout do
        local noMoney, text = hasNotEnoughMoneyNotification(baseline)
        if noMoney then
            return true, text
        end
        task.wait(0.1)
    end

    return false, nil
end

local function checkStageAbortFromHud(expectedStage, actionAttempted)
    if expectedStage == "Buying" then
        -- Only treat the no-money notification as a failure after we have actually clicked this car.
        -- This prevents an old notification from instantly skipping every next matching car.
        if actionAttempted then
            local noMoney, text = hasNotEnoughMoneyNotification(Runtime.BuyNoticeBaseline)
            if noMoney then
                -- Do not stop the whole script anymore. Mark this target as failed and let the buyer try another car.
                Runtime.LastBuyFailReason = text or NOT_ENOUGH_MONEY_TEXT
                setStatus("Cannot buy this car — trying another")
                return true
            end
        end
    elseif expectedStage == "Selling" then
        -- Selling no longer stops the whole script. If a HUD notification appears and the confirm menu
        -- does not open, sellUntilVehicleGone() will wait 10s and retry the prompt + confirm flow.
        if actionAttempted and not isConfirmationVisible() and hasActiveNotification() then
            setStatus("Sale blocked — retrying soon")
            return false
        end
    end

    return false
end


local function clickGuiButton(button)
    if not button or not button.Parent then return false end

    local fired = false

    -- Works for most executors on PC + mobile because it fires the GuiButton signals directly.
    pcall(function()
        firesignal(button.MouseButton1Down)
        fired = true
    end)
    pcall(function()
        firesignal(button.MouseButton1Up)
        fired = true
    end)
    pcall(function()
        firesignal(button.MouseButton1Click)
        fired = true
    end)
    pcall(function()
        firesignal(button.Activated)
        fired = true
    end)
    pcall(function()
        button:Activate()
        fired = true
    end)

    return fired
end

local function clickConfirmationIfVisible(expectedStage, runToken, statusText)
    if not canContinue(runToken) then return false end
    if expectedStage and not sameStage(expectedStage) then return false end
    if not isConfirmationVisible() then return false end

    local btn = getConfirmationButton()
    if not btn then
        setStatus("Waiting for confirm button")
        return false
    end

    if statusText then setStatus(statusText) end
    return clickGuiButton(btn)
end

local function runConfirmationFlow(expectedStage, runToken, preConfirmAction, waitText, confirmText)
    local t0 = os.clock()
    local lastPreAction = -math.huge
    local saw = false
    local didPreAction = false

    -- Step 1: do the requested action only for the current stage until Confirmation opens.
    while canContinue(runToken) and sameStage(expectedStage) and os.clock() - t0 <= CONFIRM_WAIT_TIMEOUT do
        if checkStageAbortFromHud(expectedStage, didPreAction) then
            return false, "hud_abort"
        end

        if isConfirmationVisible() then
            saw = true
            break
        end

        local now = os.clock()
        if preConfirmAction and now - lastPreAction >= BUY_CLICK_INTERVAL then
            if waitText then setStatus(waitText) end
            preConfirmAction()
            didPreAction = true
            lastPreAction = now

            if checkStageAbortFromHud(expectedStage, didPreAction) then
                return false, "hud_abort"
            end
        end

        task.wait(0.15)
    end

    if not saw then
        return false, "confirmation_not_open"
    end

    -- Step 2: press HUD.Frames.Confirmation.Confirm every 2 seconds until it closes.
    local closeStart = os.clock()
    local lastConfirmAt = -math.huge

    while canContinue(runToken) and sameStage(expectedStage) and isConfirmationVisible() and os.clock() - closeStart <= CONFIRM_CLOSE_TIMEOUT do
        if checkStageAbortFromHud(expectedStage, true) then
            return false, "hud_abort"
        end

        local now = os.clock()
        if now - lastConfirmAt >= CONFIRM_CLICK_INTERVAL then
            clickConfirmationIfVisible(expectedStage, runToken, confirmText)
            lastConfirmAt = now
        end
        task.wait(0.15)
    end

    if isConfirmationVisible() then
        return false, "confirmation_still_open"
    end

    return true
end

local function getVehicleByName(vehicleName)
    local vehicles = getVehiclesFolder()
    if not vehicles or not vehicleName then return nil end
    local found = vehicles:FindFirstChild(vehicleName)
    if found and found:IsA("Model") then
        return found
    end
    return nil
end

local function getSeatedVehicle()
    local hum = getHum()
    local seat = hum and hum.SeatPart
    local vehicles = getVehiclesFolder()

    if seat and vehicles then
        local model = seat:FindFirstAncestorOfClass("Model")
        if model and model:IsDescendantOf(vehicles) then
            return model
        end
    end

    return nil
end

local function isSeatedInVehicle(vehicle)
    local seated = getSeatedVehicle()
    return seated ~= nil and vehicle ~= nil and seated == vehicle
end

local function getCurrentOwnedVehicle()
    -- v13: prefer the vehicle we are physically seated in.
    -- A-Chassis Car.Value can briefly stay on an older car after a purchase/reload,
    -- so Repair100 never uses A-Chassis for engine locking when not seated.
    local seatedVehicle = getSeatedVehicle()
    if seatedVehicle and seatedVehicle.Parent then
        return seatedVehicle
    end

    local vehicle = nil
    pcall(function()
        vehicle = select(1, getVehicle())
    end)

    if vehicle and vehicle.Parent then
        return vehicle
    end

    return nil
end

local function getVehicleDistanceFrom(model, pos)
    if not model or not model.Parent or typeof(pos) ~= "Vector3" then
        return math.huge
    end

    local cf = getModelCF(model)
    if not cf then
        return math.huge
    end

    return (cf.Position - pos).Magnitude
end

local function isLoadedVehicleCandidate(model)
    return model
        and model.Parent
        and model:IsA("Model")
        and model:FindFirstChild("DriveSeat", true) ~= nil
end

local function findNearestLoadedVehicle(originPos, radius, requireNoClickDetector)
    local vehicles = getVehiclesFolder()
    local root = getRoot()
    if not vehicles or not root then return nil end

    radius = radius or BOUGHT_NEAREST_RADIUS
    local rootPos = root.Position
    local bestNoDetector = nil
    local bestNoDetectorScore = math.huge
    local bestAny = nil
    local bestAnyScore = math.huge

    for _, model in ipairs(vehicles:GetChildren()) do
        if isLoadedVehicleCandidate(model) then
            local cf = getModelCF(model)
            if cf then
                local distRoot = (cf.Position - rootPos).Magnitude
                local distOrigin = originPos and (cf.Position - originPos).Magnitude or distRoot
                local score = math.min(distRoot, distOrigin)

                if score <= radius then
                    -- Bought/reloaded cars should not still expose the junkyard purchase ClickDetector.
                    -- If we allow models that still have ClickDetector after a failed buy, the script can jump into an unowned car.
                    if not model:FindFirstChild("ClickDetector") then
                        if score < bestNoDetectorScore then
                            bestNoDetector = model
                            bestNoDetectorScore = score
                        end
                    elseif not requireNoClickDetector and score < bestAnyScore then
                        bestAny = model
                        bestAnyScore = score
                    end
                end
            end
        end
    end

    return bestNoDetector or (not requireNoClickDetector and bestAny or nil)
end

local function waitForBoughtVehicleToReload(originPos, runToken)
    setStage("WaitingVehicle", "Waiting for car to load")

    -- The game often removes the bought car for 1-2 seconds and then recreates it with a new name.
    -- Do not search by the old model name anymore; wait 2 seconds, then use the nearest loaded vehicle.
    local loadStart = os.clock()
    while canContinue(runToken) and os.clock() - loadStart < BUY_POST_CONFIRM_LOAD_WAIT do
        task.wait(0.2)
    end

    local stableModel = nil
    local stableAt = 0
    local start = os.clock()

    while canContinue(runToken) and os.clock() - start <= VEHICLE_READY_TIMEOUT do
        local candidate = getCurrentOwnedVehicle()

        -- v12 stale A-Chassis guard:
        -- If A-Chassis still points to an old loaded car far away from the buy spot/player,
        -- ignore it and use the nearest freshly loaded vehicle instead.
        if isLoadedVehicleCandidate(candidate) then
            local root = getRoot()
            local rootPos = root and root.Position or nil
            local nearOrigin = (originPos == nil) or getVehicleDistanceFrom(candidate, originPos) <= BOUGHT_NEAREST_RADIUS
            local nearPlayer = (rootPos ~= nil) and getVehicleDistanceFrom(candidate, rootPos) <= BOUGHT_NEAREST_RADIUS

            if not nearOrigin and not nearPlayer then
                candidate = nil
            end
        end

        if not isLoadedVehicleCandidate(candidate) then
            candidate = findNearestLoadedVehicle(originPos, BOUGHT_NEAREST_RADIUS, true)
        end

        if isLoadedVehicleCandidate(candidate) then
            if candidate ~= stableModel then
                stableModel = candidate
                stableAt = os.clock()
            elseif os.clock() - stableAt >= VEHICLE_STABLE_TIME then
                Runtime.CurrentVehicleName = stableModel.Name
                destroyVehicleSeats(stableModel)
                setStatus("Car loaded: " .. tostring(stableModel.Name))
                return stableModel
            end
        else
            stableModel = nil
            stableAt = 0
        end

        task.wait(0.2)
    end

    local fallbackVehicle = getCurrentOwnedVehicle()
    if isLoadedVehicleCandidate(fallbackVehicle) then
        local root = getRoot()
        local rootPos = root and root.Position or nil
        local nearOrigin = (originPos == nil) or getVehicleDistanceFrom(fallbackVehicle, originPos) <= BOUGHT_NEAREST_RADIUS
        local nearPlayer = (rootPos ~= nil) and getVehicleDistanceFrom(fallbackVehicle, rootPos) <= BOUGHT_NEAREST_RADIUS
        if not nearOrigin and not nearPlayer then
            fallbackVehicle = nil
        end
    end

    fallbackVehicle = fallbackVehicle or findNearestLoadedVehicle(originPos, BOUGHT_NEAREST_RADIUS, true)
    if fallbackVehicle then
        destroyVehicleSeats(fallbackVehicle)
    end
    return fallbackVehicle
end

local function waitForPurchasedVehicle(model, runToken)
    if not model or not model.Parent then
        return nil, "target_missing"
    end

    local vehicleName = model.Name
    local originCF = getModelCF(model)
    local originPos = originCF and originCF.Position or nil
    Runtime.CurrentVehicleName = vehicleName
    Runtime.LastBuyFailReason = nil
    Runtime.BuyNoticeBaseline = snapshotNotificationTextObjects()
    setStage("Buying", "Buying car: " .. tostring(vehicleName) .. " " .. tostring(Runtime.SelectText))

    local function pressBuyDetector()
        if not canContinue(runToken) or not sameStage("Buying") then return end
        if not model or not model.Parent then return end

        local cd = model:FindFirstChild("ClickDetector")
        if cd then
            teleportToJunkyardVehicle(model, runToken)
            task.wait(0.1)

            -- Only click buy when the script is still at the buy step and close to the target.
            if canContinue(runToken) and sameStage("Buying") then
                if checkStageAbortFromHud("Buying", true) then return end
                Runtime.BuyNoticeBaseline = Runtime.BuyNoticeBaseline or snapshotNotificationTextObjects()
                fireClickDetector(cd, 2)
                task.wait(0.15)
                checkStageAbortFromHud("Buying", true)
            end
        end
    end

    local ok, reason = runConfirmationFlow(
        "Buying",
        runToken,
        pressBuyDetector,
        "Opening purchase menu",
        "Confirming purchase"
    )

    if not ok then
        return nil, Runtime.LastBuyFailReason or reason or "buy_failed"
    end

    -- Important guard: pressing Confirm can close the menu even when the purchase fails.
    -- If the game shows a new "You don't have enough money" notification here, do NOT enter the nearest car.
    local noMoney, text = waitForBuyFailureNotification(Runtime.BuyNoticeBaseline, BUY_FAIL_SCAN_TIME)
    if noMoney then
        Runtime.LastBuyFailReason = text or NOT_ENOUGH_MONEY_TEXT
        setStatus("Not enough currency — trying another car")
        return nil, Runtime.LastBuyFailReason
    end

    local boughtVehicle = waitForBoughtVehicleToReload(originPos, runToken)
    if not boughtVehicle or not boughtVehicle.Parent then
        return nil, "bought_car_not_ready"
    end

    return boughtVehicle
end

local function acquireJunkyardVehicle(runToken)
    -- Guard: if the player is already sitting in an owned/active car, do not buy a new one.
    local activeVehicle = getCurrentOwnedVehicle()
    if activeVehicle and activeVehicle.Parent and isLoadedVehicleCandidate(activeVehicle) then
        Runtime.CurrentVehicleName = activeVehicle.Name
        setStage("UsingVehicle", "Using current car")
        destroyVehicleSeats(activeVehicle)
        if sitInDriveSeat then
            sitInDriveSeat(activeVehicle, runToken)
        end
        return activeVehicle
    end

    if not canContinue(runToken) then
        return nil, "Stopped"
    end

    local ignoredNames = {}
    local attempts = 0

    while canContinue(runToken) and attempts < BUY_MAX_TARGET_ATTEMPTS do
        attempts += 1
        setStage("FindingCar", "Finding car " .. tostring(Runtime.SelectText))

        local target = findBestJunkyardVehicle(ignoredNames)
        if not target then
            return nil, "No matching junkyard car"
        end

        Runtime.CurrentVehicleName = target.Name
        setStatus("Found car: " .. tostring(target.Name))
        teleportToJunkyardVehicle(target, runToken)
        task.wait(0.35)

        local vehicle, buyReason = waitForPurchasedVehicle(target, runToken)

        if vehicle and vehicle.Parent and canContinue(runToken) then
            setStage("EnteringCar", "Getting in car")

            -- Before sitting, hard-lock to DriveSeat only. Body.Seats can respawn after purchase,
            -- so keep deleting it briefly before the first seat attempt.
            destroyVehicleSeats(vehicle)
            task.spawn(function()
                holdDriverSeatOnly(vehicle, runToken, 4)
            end)
            task.wait(0.25)

            local seated = sitInDriveSeat(vehicle, runToken)
            if seated then
                task.wait(0.65)
                return vehicle
            end

            ignoredNames[target.Name] = true
            setStatus("Seat failed — trying another car")
            task.wait(0.5)
        else
            ignoredNames[target.Name] = true
            Runtime.CurrentVehicleName = nil
            setStatus("Buy failed — trying another car")
            task.wait(0.75)
        end
    end

    return nil, "No purchasable matching car"
end

local function collectNearbyMoveableParts(radius)
    local result = {}
    local root = getRoot()
    local mp = workspace:FindFirstChild("MoveableParts")
    if not root or not mp then return result end

    for _, obj in ipairs(mp:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local cf = nil
            if obj:IsA("Model") then
                cf = getModelCF(obj)
            else
                cf = obj.CFrame
            end

            if cf and (cf.Position - root.Position).Magnitude <= radius then
                table.insert(result, obj)
            end
        end
    end

    table.sort(result, function(a, b)
        return a.Name < b.Name
    end)

    return result
end

local function isVehicleStillInVehicles(vehicle)
    local vehicles = getVehiclesFolder()
    return vehicle ~= nil and vehicles ~= nil and vehicle:IsDescendantOf(vehicles)
end

local function findSellPromptNear(pos, radius)
    local bestPrompt = nil
    local bestDist = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                local dist = (part.Position - pos).Magnitude
                if dist <= radius and dist < bestDist then
                    bestDist = dist
                    bestPrompt = obj
                end
            end
        end
    end

    return bestPrompt
end

local function isNearPosition(pos, radius)
    local root = getRoot()
    if not root then return false end
    return (root.Position - pos).Magnitude <= (radius or 30)
end

local function sellUntilVehicleGone(vehicle, runToken)
    local checkPos = Vector3.new(SELL_EXIT.X, SELL_EXIT.Y, SELL_EXIT.Z)

    setStage("Selling", "Selling car")

    while canContinue(runToken) and sameStage("Selling") and isVehicleStillInVehicles(vehicle) do
        local prompt = findSellPromptNear(checkPos, 25)

        if prompt and isNearPosition(checkPos, 35) then
            local function pressSellPrompt()
                if not canContinue(runToken) or not sameStage("Selling") then return end
                if not isNearPosition(checkPos, 35) then return end
                fireProximityPrompt(prompt)
            end

            local ok, reason = runConfirmationFlow(
                "Selling",
                runToken,
                pressSellPrompt,
                "Opening sell menu",
                "Confirming sale"
            )

            if ok then
                -- The car may take a moment to disappear after confirm.
                local goneStart = os.clock()
                while canContinue(runToken) and sameStage("Selling") and isVehicleStillInVehicles(vehicle) and os.clock() - goneStart < 8 do
                    task.wait(0.25)
                end
            else
                -- New logic: if sell confirmation does not open or a HUD notice blocks it,
                -- wait 10 seconds and try the ProximityPrompt + Confirm button again.
                setStatus("Sell failed — retrying in 25s")
                local waitStart = os.clock()
                while canContinue(runToken) and sameStage("Selling") and isVehicleStillInVehicles(vehicle) and os.clock() - waitStart < SELL_RETRY_AFTER_BLOCK do
                    task.wait(0.25)
                end
            end
        else
            setStatus("Waiting for sell spot")
            task.wait(0.75)
        end

        if isVehicleStillInVehicles(vehicle) then
            task.wait(SELL_RETRY_INTERVAL)
        end
    end

    return not isVehicleStillInVehicles(vehicle)
end

task.spawn(function()
    while Runtime.Alive do
        if Runtime.CarEspEnabled then
            refreshCarEsp()
        end
        task.wait(1.25)
    end
end)

-- ──────────────────────────────────────────────────────────
--  HELPER: FIND TRANSMISSION IN MoveableParts
-- ──────────────────────────────────────────────────────────
local function findTransmission()
    local mp = workspace:FindFirstChild("MoveableParts")
    if not mp then return nil end
    for _, tName in ipairs(TRANSMISSION_NAMES) do
        local t = mp:FindFirstChild(tName)
        if t then return t, tName end
    end
    return nil
end

-- ──────────────────────────────────────────────────────────
--  HELPER: FIND PART IN MoveableParts (handles VETC variants)
-- ──────────────────────────────────────────────────────────
local function findMoveable(partName)
    local mp = workspace:FindFirstChild("MoveableParts")
    if not mp then return nil end
    -- Direct
    local direct = mp:FindFirstChild(partName)
    if direct then return direct end
    -- VETC variant: "VETC EngineBlock", "VETC ExhaustManifold", etc.
    local vetcVariant = mp:FindFirstChild("VETC " .. partName)
    if vetcVariant then return vetcVariant end
    -- Check if this name already starts with VETC
    if partName == "VETC" then
        for _, child in ipairs(mp:GetChildren()) do
            if child.Name:sub(1, 4) == "VETC" then return child end
        end
    end
    return nil
end

-- ──────────────────────────────────────────────────────────
--  HELPER: SIT IN DRIVERSEAT (retry until seated)
-- ──────────────────────────────────────────────────────────
sitInDriveSeat = function(vehicle, runToken)
    if not vehicle or not vehicle.Parent then return false end

    local driveSeat = vehicle:FindFirstChild("DriveSeat", true)
    if not driveSeat or not driveSeat:IsA("BasePart") then return false end

    local root = getRoot()
    if not root then return false end

    local attempts = 0
    while canContinue(runToken) and vehicle.Parent and attempts < 18 do
        local hum = getHum()
        root = getRoot()

        if not hum or not root then
            return false
        end

        -- Keep removing passenger/rear seats during every retry.
        destroyVehicleSeats(vehicle)

        -- Success only when we are in the real DriveSeat.
        if hum.SeatPart == driveSeat then
            return true
        end

        -- If Roblox snapped us into any other seat, instantly unseat and try DriveSeat again.
        if hum.SeatPart and hum.SeatPart ~= driveSeat then
            pcall(function()
                hum.Sit = false
            end)
            task.wait(0.20)
        end

        -- Move to just above DriveSeat (+Y 2), then force DriveSeat:Sit when possible.
        -- Uses Tween when Movement Mode = Tween; repair parts are unaffected.
        local seatCF = driveSeat.CFrame * CFrame.new(0, 2, 0)
        moveCharacterToCF(seatCF, runToken, "Getting in car", false)

        task.wait(0.15)

        pcall(function()
            driveSeat:Sit(hum)
        end)

        task.wait(1.10)

        if hum.SeatPart == driveSeat then
            return true
        end

        attempts += 1
    end

    local hum = getHum()
    return hum and hum.SeatPart == driveSeat
end

-- ──────────────────────────────────────────────────────────
--  HELPER: UNSEAT CHARACTER SAFELY (no limb removal)
-- ──────────────────────────────────────────────────────────
local function unseatCharacter(vehicleOverride)
    local hum = getHum()
    if not hum then return end
    -- Destroy seats folder to force ejection without damaging character
    local vehicle = vehicleOverride
    if not vehicle then
        vehicle = select(1, getVehicle())
    end
    if vehicle then
        destroyVehicleSeats(vehicle)
    end
    -- Restore locomotion after unseat
    task.wait(0.3)
    restoreCharacter()
end

-- ──────────────────────────────────────────────────────────
--  HELPER: TELEPORT CAR + CHARACTER TO TARGET CF
-- ──────────────────────────────────────────────────────────
local function teleportCarAndChar(vehicle, targetCF, runToken)
    local char  = getChar()
    local root  = getRoot()
    if not vehicle or not vehicle.Parent or not char or not root then return false end

    local okCF, carCF = pcall(function()
        return vehicle:GetPivot()
    end)
    if not okCF or typeof(carCF) ~= "CFrame" then return false end

    local okChar, charCF = pcall(function()
        return char:GetPivot()
    end)
    if not okChar or typeof(charCF) ~= "CFrame" then return false end

    local offset = carCF:ToObjectSpace(charCF)
    local mode = Runtime.MovementMode or "Tween"

    stopVelocity(vehicle)
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    if mode == "Tween" then
        setStatus("Moving car • Tween")
        local driver = Instance.new("CFrameValue")
        driver.Value = carCF

        local dist = (carCF.Position - targetCF.Position).Magnitude
        local duration = math.clamp(dist / CAR_TWEEN_SPEED, CAR_TWEEN_MIN_TIME, CAR_TWEEN_MAX_TIME)

        local conn
        conn = driver:GetPropertyChangedSignal("Value"):Connect(function()
            if not vehicle or not vehicle.Parent then return end
            local cf = driver.Value
            pcall(function()
                vehicle:PivotTo(cf)
            end)
            if char and char.Parent then
                pcall(function()
                    char:PivotTo(cf:ToWorldSpace(offset))
                end)
            end
            stopVelocity(vehicle)
        end)

        local tween = TweenService:Create(driver, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
            Value = targetCF
        })

        tween:Play()
        local start = os.clock()
        while (runToken == nil or canContinue(runToken)) and vehicle.Parent and os.clock() - start < duration do
            task.wait(0.03)
        end

        if runToken ~= nil and not canContinue(runToken) then
            pcall(function() tween:Cancel() end)
        end

        pcall(function()
            if conn then conn:Disconnect() end
            driver:Destroy()
        end)
    else
        setStatus("Moving car • Teleport")
        pcall(function()
            vehicle:PivotTo(targetCF)
        end)
        task.wait(0.15)
        pcall(function()
            char:PivotTo(targetCF:ToWorldSpace(offset))
        end)
    end

    if runToken == nil or canContinue(runToken) then
        pcall(function()
            vehicle:PivotTo(targetCF)
            char:PivotTo(targetCF:ToWorldSpace(offset))
        end)
    end

    stopVelocity(vehicle)
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    return true
end

-- ──────────────────────────────────────────────────────────
--  MAIN FARM LOOP
-- ──────────────────────────────────────────────────────────
-- ──────────────────────────────────────────────────────────
--  REPAIR FLOW V3: parallel stations -> fixed 15s -> drop point
-- ──────────────────────────────────────────────────────────
local function getMoveableFolder()
    return workspace:FindFirstChild("MoveableParts")
end

local function getMoveableCF(obj)
    if not obj or not obj.Parent then return nil end
    if obj:IsA("Model") then
        return getModelCF(obj)
    elseif obj:IsA("BasePart") then
        return obj.CFrame
    end
    return nil
end

local function getMoveablePosition(obj)
    local cf = getMoveableCF(obj)
    return cf and cf.Position or nil
end

local function snapshotMoveableParts()
    local snap = {}
    local mp = getMoveableFolder()
    if not mp then return snap end
    for _, obj in ipairs(mp:GetChildren()) do
        snap[obj] = true
    end
    return snap
end

local function moveableMatchesWantedName(objName, wantedName)
    if not objName or not wantedName then return false, 99 end

    if wantedName == "Transmission" then
        for _, tName in ipairs(TRANSMISSION_NAMES) do
            if objName == tName then
                return true, 0
            end
        end
        return false, 99
    end

    if objName == wantedName then
        return true, 0
    end

    -- VETC variants, for example "VETC EngineBlock".
    if objName == "VETC " .. wantedName then
        return true, 1
    end

    if wantedName == "VETC" and objName:sub(1, 4) == "VETC" then
        return true, 1
    end

    return false, 99
end

local function chooseBestMoveableByName(wantedName, usedParts, beforeStripSet)
    local mp = getMoveableFolder()
    if not mp then return nil end

    local root = getRoot()
    local rootPos = root and root.Position or DROP_CF.Position
    local candidates = {}

    for _, obj in ipairs(mp:GetChildren()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and not usedParts[obj] then
            local match, nameScore = moveableMatchesWantedName(obj.Name, wantedName)
            if match then
                local pos = getMoveablePosition(obj)
                if pos then
                    local isNew = beforeStripSet and not beforeStripSet[obj]
                    table.insert(candidates, {
                        Obj = obj,
                        NameScore = nameScore,
                        IsNew = isNew == true,
                        Dist = (pos - rootPos).Magnitude,
                    })
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        -- Prefer parts that appeared after this cycle started. That avoids stealing other players' old MoveableParts.
        if a.IsNew ~= b.IsNew then
            return a.IsNew
        end
        if a.NameScore ~= b.NameScore then
            return a.NameScore < b.NameScore
        end
        return a.Dist < b.Dist
    end)

    return candidates[1] and candidates[1].Obj or nil
end

local function waitForMoveableByName(wantedName, usedParts, beforeStripSet, runToken, timeout)
    local start = os.clock()
    timeout = timeout or MOVEABLE_WAIT_TIMEOUT

    while canContinue(runToken) and os.clock() - start <= timeout do
        local obj = chooseBestMoveableByName(wantedName, usedParts, beforeStripSet)
        if obj and obj.Parent then
            return obj
        end
        task.wait(0.2)
    end

    return nil
end

local function getRepairTargetCF(station, partName)
    -- Station-specific targetPosition is preferred because the small pitstop has duplicate machines.
    local targetPos = station and station.targetPosition or nil
    if not targetPos then
        targetPos = PART_POSITIONS[partName]
    end
    if not targetPos and station then
        targetPos = PART_POSITIONS[station.partName]
    end
    return CFrame.new(targetPos or DROP_CF.Position)
end

local function distanceMoveableToCF(obj, cf)
    local pos = getMoveablePosition(obj)
    if not pos then return math.huge end
    return (pos - cf.Position).Magnitude
end

local function stableTeleportMoveable(obj, cf, runToken, settle, retries)
    if not obj or not obj.Parent then return false end

    settle = settle or PART_TP_SETTLE_FAST
    retries = retries or PART_TP_RETRIES

    for attempt = 1, retries do
        if not canContinue(runToken) or not obj or not obj.Parent then return false end

        teleportAndSettle(obj, cf, settle)

        local dist = distanceMoveableToCF(obj, cf)
        if dist <= PART_TP_VERIFY_RADIUS then
            stopVelocity(obj)
            return true
        end

        -- Anti visual teleport / snap-back: force the same pivot again before giving up.
        safeSetPivot(obj, cf)
        stopVelocity(obj)
        task.wait(0.10 + (attempt * 0.03))
    end

    return distanceMoveableToCF(obj, cf) <= (PART_TP_VERIFY_RADIUS * 1.35)
end

local function getScreenTextSafe(screenLbl)
    if not screenLbl then return nil end
    local ok, txt = pcall(function()
        return tostring(screenLbl.Text or "")
    end)
    if ok then return txt end
    return nil
end

local function repairSinglePartAtStation(station, partName, partObj, btn, screenLbl, runToken)
    if not partObj or not partObj.Parent then return false end
    if not btn then return false end

    local targetCF = getRepairTargetCF(station, partName)
    setStatus("Repairing " .. tostring(partObj.Name) .. " • " .. tostring(REPAIR_WAIT_PER_PART) .. "s")

    -- Step 1: put the part on the correct repair point and make it stable.
    stableTeleportMoveable(partObj, targetCF, runToken, TP_SETTLE, PART_TP_RETRIES)
    task.wait(CLICK_INTERVAL)

    -- Step 2: start the machine.
    fireClickDetector(btn, 2)

    -- Step 3: fixed repair window for this exact part.
    -- If the station still says WAITING PART, re-seat and re-click without resetting the whole cycle.
    local start = os.clock()
    local lastWake = 0

    while canContinue(runToken) and partObj.Parent and os.clock() - start < REPAIR_WAIT_PER_PART do
        local now = os.clock()
        if now - lastWake >= REPAIR_WAKE_INTERVAL then
            local txt = nil
            if screenLbl then
                pcall(function()
                    txt = tostring(screenLbl.Text or "")
                end)
            end

            if (not screenLbl) or txt == "WAITING PART" or txt == "" then
                safeSetPivot(partObj, targetCF)
                stopVelocity(partObj)
                fireClickDetector(btn, 2)
            end

            lastWake = now
        end

        task.wait(0.15)
    end

    -- Step 4: after the repair wait, move the part to the shared drop point.
    if partObj and partObj.Parent then
        setStatus("Moving " .. tostring(partObj.Name) .. " to parts pile")
        stableTeleportMoveable(partObj, DROP_CF, runToken, 0.75, PART_TP_RETRIES)
        return true
    end

    return false
end

local function buildParallelRepairQueues(beforeStripSet, runToken)
    local stationQueues = {}
    local queuedSeen = {}
    local skippedCount = 0

    for stationIndex, station in ipairs(REPAIR_STATIONS) do
        if not canContinue(runToken) then break end

        local btn, screenLbl = resolveStation(station)
        local queue = {
            Station = station,
            Button = btn,
            Screen = screenLbl,
            Items = {},
        }

        if not btn then
            skippedCount += #station.partNames
            setStatus("Repair station missing, skipping group")
        else
            for _, partName in ipairs(station.partNames) do
                if not canContinue(runToken) then break end

                -- Short timeout here keeps the script smooth. The parts were already allowed to drop before this step.
                local partObj = waitForMoveableByName(partName, queuedSeen, beforeStripSet, runToken, PARALLEL_ASSIGN_TIMEOUT)
                if partObj and partObj.Parent then
                    queuedSeen[partObj] = true
                    table.insert(queue.Items, {
                        StationIndex = stationIndex,
                        Station = station,
                        PartName = partName,
                        Part = partObj,
                        Button = btn,
                        Screen = screenLbl,
                        TargetCF = getRepairTargetCF(station, partName),
                    })
                else
                    skippedCount += 1
                end
            end
        end

        stationQueues[stationIndex] = queue
        task.wait(0.03)
    end

    return stationQueues, skippedCount
end

local function hasRepairWork(stationQueues, activeJobs)
    for _, job in pairs(activeJobs) do
        if job then return true end
    end

    for _, queue in ipairs(stationQueues) do
        if queue and #queue.Items > 0 then
            return true
        end
    end

    return false
end

local function waitForStationReady(screenLbl, runToken, timeout)
    if not screenLbl then
        task.wait(0.25)
        return true
    end

    timeout = timeout or 8
    local start = os.clock()

    while canContinue(runToken) and os.clock() - start <= timeout do
        local txt = getScreenTextSafe(screenLbl) or ""
        local lower = txt:lower()

        -- Ready states seen in this game usually include WAITING PART / NO REPAIRS NEEDED / INVALID PART.
        -- Unknown blank text is treated as ready so the script does not freeze overnight.
        if txt == ""
            or lower:find("waiting", 1, true)
            or lower:find("no repairs", 1, true)
            or lower:find("invalid", 1, true)
            or lower:find("ready", 1, true) then
            return true
        end

        -- Busy states: keep waiting briefly before loading the next part into the same machine.
        if lower:find("repair", 1, true)
            or lower:find("work", 1, true)
            or lower:find("busy", 1, true) then
            task.wait(0.25)
        else
            -- If the screen uses a text we do not know, do not hard-lock the cycle.
            return true
        end
    end

    return false
end

local function runStationSequentialRepairFlow(beforeStripSet, runToken)
    -- Fallback mode: one machine/device after another.
    local repairedCount = 0
    local skippedCount = 0
    local usedParts = {}

    setStage("Repairing", "Repairing parts • sequential")

    for stationIndex, station in ipairs(REPAIR_STATIONS) do
        if not canContinue(runToken) then
            return repairedCount, skippedCount
        end

        local btn, screenLbl = resolveStation(station)
        local stationName = station.displayName or ("Machine " .. tostring(stationIndex))

        if not btn then
            skippedCount += #station.partNames
            setStatus(stationName .. " missing — skipped")
            task.wait(0.15)
            continue
        end

        setStatus(stationName .. " ready")

        for _, partName in ipairs(station.partNames) do
            if not canContinue(runToken) then
                return repairedCount, skippedCount
            end

            local partObj = waitForMoveableByName(partName, usedParts, beforeStripSet, runToken, MOVEABLE_WAIT_TIMEOUT)
            if not partObj or not partObj.Parent then
                skippedCount += 1
                task.wait(0.08)
                continue
            end

            usedParts[partObj] = true

            waitForStationReady(screenLbl, runToken, 8)

            local targetCF = getRepairTargetCF(station, partName)
            setStatus(stationName .. " ← " .. tostring(partObj.Name))

            local placed = stableTeleportMoveable(partObj, targetCF, runToken, TP_SETTLE, PART_TP_RETRIES)
            if not placed then
                placed = stableTeleportMoveable(partObj, targetCF, runToken, 1.05, PART_TP_RETRIES + 2)
            end

            if placed then
                local ok = repairSinglePartAtStation(station, partName, partObj, btn, screenLbl, runToken)
                if ok then
                    repairedCount += 1
                else
                    skippedCount += 1
                end
            else
                skippedCount += 1
                setStatus("Part failed to stay at repair point — skipped")
            end

            waitForStationReady(screenLbl, runToken, 8)
            task.wait(0.18)
        end

        setStatus(stationName .. " done")
        task.wait(0.25)
    end

    return repairedCount, skippedCount
end

local function runStationParallelAllRepairFlow(beforeStripSet, runToken)
    -- Parallel mode: Machine 1, Machine 2, Machine 3, Radiator/PartsWasher,
    -- and Battery/BatteryCharger all start together. Each device still repairs
    -- one part at a time so one machine does not eat two parts at once.
    local repairedCount = 0
    local skippedCount = 0
    local stationQueues, assignSkipped = buildParallelRepairQueues(beforeStripSet, runToken)
    skippedCount += assignSkipped

    setStage("Repairing", "Repairing parts • all machines")

    local activeWorkers = 0
    local doneEvent = Instance.new("BindableEvent")

    local function addResult(repaired, skipped)
        repairedCount += repaired or 0
        skippedCount += skipped or 0
    end

    local function runQueueWorker(stationIndex, queue)
        local localRepaired = 0
        local localSkipped = 0
        local station = queue.Station
        local stationName = station.displayName or ("Machine " .. tostring(stationIndex))

        setStatus(stationName .. " started")

        for _, item in ipairs(queue.Items) do
            if not canContinue(runToken) then
                break
            end

            local partObj = item.Part
            if not partObj or not partObj.Parent then
                localSkipped += 1
                task.wait(0.08)
                continue
            end

            -- Check only this device's own screen. Other devices keep running.
            waitForStationReady(queue.Screen, runToken, 8)

            setStatus(stationName .. " ← " .. tostring(partObj.Name))

            local targetCF = item.TargetCF or getRepairTargetCF(station, item.PartName)
            local placed = stableTeleportMoveable(partObj, targetCF, runToken, TP_SETTLE, PART_TP_RETRIES)
            if not placed then
                placed = stableTeleportMoveable(partObj, targetCF, runToken, 1.05, PART_TP_RETRIES + 2)
            end

            if placed and canContinue(runToken) then
                local ok = repairSinglePartAtStation(station, item.PartName, partObj, queue.Button, queue.Screen, runToken)
                if ok then
                    localRepaired += 1
                else
                    localSkipped += 1
                end
            else
                localSkipped += 1
                setStatus(stationName .. " part failed — skipped")
            end

            -- This worker waits only for its own machine/device before taking
            -- the next part from its own queue. Other workers are not blocked.
            waitForStationReady(queue.Screen, runToken, 8)
            task.wait(0.12)
        end

        setStatus(stationName .. " done")
        addResult(localRepaired, localSkipped)
        activeWorkers -= 1
        doneEvent:Fire()
    end

    for stationIndex, queue in ipairs(stationQueues) do
        if queue and queue.Button and #queue.Items > 0 then
            activeWorkers += 1
            task.spawn(function()
                local ok, err = pcall(function()
                    runQueueWorker(stationIndex, queue)
                end)

                if not ok then
                    skippedCount += #queue.Items
                    local stationName = queue.Station and queue.Station.displayName or ("Machine " .. tostring(stationIndex))
                    setStatus(stationName .. " error — skipped")
                    activeWorkers -= 1
                    doneEvent:Fire()
                end
            end)
        elseif queue and (not queue.Button) then
            skippedCount += #queue.Items
        end
    end

    if activeWorkers <= 0 then
        pcall(function() doneEvent:Destroy() end)
        return repairedCount, skippedCount
    end

    while canContinue(runToken) and activeWorkers > 0 do
        task.wait(0.2)
    end

    -- If the user stopped the farm, do not wait forever for sleeping workers.
    local stopWaitStart = os.clock()
    while activeWorkers > 0 and os.clock() - stopWaitStart < 1.5 do
        task.wait(0.1)
    end

    if activeWorkers <= 0 then
        pcall(function() doneEvent:Destroy() end)
    end
    return repairedCount, skippedCount
end

local function runParallelRepairFlow(beforeStripSet, runToken)
    if REPAIR_PARALLEL_ALL then
        return runStationParallelAllRepairFlow(beforeStripSet, runToken)
    end

    return runStationSequentialRepairFlow(beforeStripSet, runToken)
end

-- Backward-compatible name used by farmCycle.
local function runSequentialRepairFlow(beforeStripSet, runToken)
    -- farmCycle still calls this old name, but it now uses the selected repair mode.
    return runParallelRepairFlow(beforeStripSet, runToken)
end

local function gatherPartsToDrop(transObj, runToken, beforeStripSet)
    setStage("Gathering", "Gathering parts")

    local gathered = 0
    local seen = {}

    local function gather(partObj)
        if not canContinue(runToken) then return end
        if not partObj or not partObj.Parent or seen[partObj] then return end
        seen[partObj] = true
        stableTeleportMoveable(partObj, DROP_CF, runToken, 0.55, PART_TP_RETRIES)
        gathered += 1
        if gathered % 5 == 0 then
            task.wait(0.1)
        end
    end

    -- Known parts first. Prefer objects that appeared after this cycle's strip.
    -- This is important for Repair 100%: old Injectors/AirIntake/Sparkplugs are hidden
    -- far away, but they still share the same names in MoveableParts. Do not pick them.
    for _, pName in ipairs(REAPPLY_ORDER) do
        local partObj = nil
        if pName == "Transmission" then
            partObj = transObj or findTransmission()
        else
            local preferred = chooseBestMoveableByName(pName, seen, beforeStripSet)
            if preferred then
                partObj = preferred
            elseif Runtime.Repair100Enabled and REPAIR100_REPLACEMENT_PART_SET[pName] then
                -- Never fall back by name for replacement-only parts after Repair 100%.
                -- A name lookup can return the old hidden object.
                partObj = nil
            else
                partObj = findMoveable(pName)
            end
        end
        gather(partObj)
    end

    -- Then every nearby MoveableParts object. Unknown parts cannot be sent to a repair station safely,
    -- but they can still be placed at the pile and tested with ReapplyPart later.
    for _, partObj in ipairs(collectNearbyMoveableParts(MOVEABLE_REAPPLY_RADIUS)) do
        gather(partObj)
    end

    return gathered
end

local function installAllCandidateParts(vehicle, transObj, runToken, beforeStripSet)
    setStage("Installing", "Installing parts")

    local function isStillMoveablePart(partObj)
        local mpNow = getMoveableFolder()
        return partObj ~= nil and mpNow ~= nil and partObj:IsDescendantOf(mpNow)
    end

    local function addUniquePart(list, seen, partObj)
        if partObj and partObj.Parent and not seen[partObj] then
            table.insert(list, partObj)
            seen[partObj] = true
        end
    end

    local installList = {}
    local installSeen = {}

    for _, pName in ipairs(REAPPLY_ORDER) do
        local partObj = nil
        if pName == "Transmission" then
            partObj = transObj or findTransmission()
        else
            -- Prefer the exact part that dropped after RemovePart in this cycle.
            -- This prevents ReapplyPart from using an old hidden Injectors/AirIntake/Sparkplugs
            -- instance that still exists in workspace.MoveableParts with the same name.
            local preferred = chooseBestMoveableByName(pName, installSeen, beforeStripSet)
            if preferred then
                partObj = preferred
            elseif Runtime.Repair100Enabled and REPAIR100_REPLACEMENT_PART_SET[pName] then
                -- Do not use findMoveable() for these three after Repair 100%, because
                -- workspace.MoveableParts.Injectors / AirIntake / Sparkplugs may point to the old part.
                partObj = nil
            else
                partObj = findMoveable(pName)
            end
        end
        addUniquePart(installList, installSeen, partObj)
    end

    for _, partObj in ipairs(collectNearbyMoveableParts(MOVEABLE_REAPPLY_RADIUS)) do
        addUniquePart(installList, installSeen, partObj)
    end

    local installedCount = 0
    local ignoredCount = 0

    for index, partObj in ipairs(installList) do
        if not canContinue(runToken) then return installedCount, ignoredCount end

        if not isStillMoveablePart(partObj) then
            installedCount += 1
            continue
        end

        setStatus("Installing " .. tostring(partObj.Name))

        local removed = false
        for attempt = 1, REAPPLY_RETRY_ATTEMPTS do
            if not canContinue(runToken) then return installedCount, ignoredCount end

            if not isStillMoveablePart(partObj) then
                removed = true
                break
            end

            pcall(function()
                -- Use the chosen object instance directly. Never re-resolve by name here,
                -- because MoveableParts can contain old and new parts with the same name.
                local args = {
                    [1] = "ReapplyPart",
                    [2] = partObj,
                }
                vehicle.PartsEvent:FireServer(unpack(args))
            end)

            local waitStart = os.clock()
            while canContinue(runToken) and os.clock() - waitStart < REAPPLY_RETRY_DELAY do
                if not isStillMoveablePart(partObj) then
                    removed = true
                    break
                end
                task.wait(0.08)
            end

            if removed then
                break
            end
        end

        if removed or not isStillMoveablePart(partObj) then
            installedCount += 1
        else
            ignoredCount += 1
        end

        if index % 4 == 0 then
            task.wait(0.15)
        else
            task.wait(0.05)
        end
    end

    return installedCount, ignoredCount
end

-- ──────────────────────────────────────────────────────────
--  REPAIR 100% PRE-SWAP FLOW
--  Buys fresh Injectors + AirIntake + Sparkplugs for the detected engine, removes
--  the old ones from the car, hides the old parts, and installs the exact saved
--  fresh instances before
--  the normal strip/repair/install/sell cycle continues.
-- ──────────────────────────────────────────────────────────
local function getPartsStoreEngineFolder(engineName)
    engineName = normalizeEngineName(engineName)
    if not engineName or engineName == "" then return nil end

    -- Strict exact folder only. No fuzzy fallback here: if the car says i4 1.9D,
    -- Repair 100% must buy from workspace.PartsStore.SpareParts.Parts["i4 1.9D"]
    -- and never silently fall back to i4 2.0 or another available folder.
    local folder = findExactPartsStoreEngineFolder(engineName)
    if folder and normalizeEngineName(folder.Name) == engineName then
        return folder
    end

    return nil
end

local function findStorePartNode(engineFolder, partName)
    if not engineFolder or not engineFolder.Parent or not partName then
        return nil
    end

    -- Exact path first:
    -- workspace.PartsStore.SpareParts.Parts[engineName].Injectors / AirIntake / Sparkplugs
    local exact = engineFolder:FindFirstChild(partName)
    if exact then
        return exact
    end

    -- Small fallback for inconsistent capitalization such as "injectors" or "SparkPlugs".
    local wantedLower = tostring(partName):lower()
    for _, child in ipairs(engineFolder:GetChildren()) do
        if child.Name:lower() == wantedLower then
            return child
        end
    end

    return nil
end

local function hasStorePartForRepair100(engineFolder, partName)
    if not engineFolder or not engineFolder.Parent or not partName then
        return false, nil
    end

    local partNode = findStorePartNode(engineFolder, partName)
    if not partNode then
        return false, nil
    end

    local cd = partNode:FindFirstChild("ClickDetector", true)
    if not cd then
        return false, partNode
    end

    return true, partNode, cd
end

local function getAvailableRepair100StoreParts(engineFolder)
    local available = {}

    for _, partName in ipairs(REPAIR100_PART_BUY_ORDER) do
        local hasPart = hasStorePartForRepair100(engineFolder, partName)
        if hasPart then
            table.insert(available, partName)
        else
            setStatus("Store has no " .. tostring(partName) .. " for this engine")
            task.wait(0.08)
        end
    end

    return available
end


local function getVehiclePartsEvent(vehicle)
    if not vehicle or not vehicle.Parent then return nil end

    local direct = vehicle:FindFirstChild("PartsEvent")
    if direct and direct:IsA("RemoteEvent") then
        return direct
    end

    local deep = vehicle:FindFirstChild("PartsEvent", true)
    if deep and deep:IsA("RemoteEvent") then
        return deep
    end

    local vehicles = workspace:FindFirstChild("Vehicles")
    local byName = vehicles and vehicles:FindFirstChild(vehicle.Name)
    if byName then
        local evt = byName:FindFirstChild("PartsEvent", true)
        if evt and evt:IsA("RemoteEvent") then
            return evt
        end
    end

    return nil
end

local function fireVehiclePartsEvent(vehicle, actionName, payload, runToken, retries, pulseDelay)
    retries = retries or 3
    pulseDelay = pulseDelay or 0.12

    local event = getVehiclePartsEvent(vehicle)
    if not event then
        setStatus("PartsEvent missing")
        return false
    end

    local fired = false
    for attempt = 1, retries do
        if not canContinue(runToken) then return false end

        local ok = pcall(function()
            event:FireServer(actionName, payload)
        end)

        if ok then
            fired = true
        end

        task.wait(pulseDelay)
    end

    return fired
end

local function waitAndConfirmCurrentDialog(runToken, statusText, openTimeout, closeTimeout)
    openTimeout = openTimeout or CONFIRM_WAIT_TIMEOUT
    closeTimeout = closeTimeout or CONFIRM_CLOSE_TIMEOUT

    local openStart = os.clock()
    while canContinue(runToken) and os.clock() - openStart <= openTimeout do
        if isConfirmationVisible() then
            break
        end
        task.wait(0.10)
    end

    if not isConfirmationVisible() then
        return false, "confirmation_not_open"
    end

    local closeStart = os.clock()
    local lastConfirmAt = -math.huge

    while canContinue(runToken) and isConfirmationVisible() and os.clock() - closeStart <= closeTimeout do
        local now = os.clock()
        if now - lastConfirmAt >= 0.35 then
            clickConfirmationIfVisible(nil, runToken, statusText or "Confirming")
            lastConfirmAt = now
        end
        task.wait(0.10)
    end

    return not isConfirmationVisible(), isConfirmationVisible() and "confirmation_still_open" or nil
end

local function buyRepair100Part(engineFolder, partName, runToken)
    if not engineFolder or not engineFolder.Parent then
        return false, "engine_folder_missing"
    end

    local hasPart, _, cd = hasStorePartForRepair100(engineFolder, partName)
    if not hasPart or not cd then
        return false, "not_available"
    end

    setStatus("Buying new " .. tostring(partName) .. " • " .. tostring(engineFolder.Name))
    fireClickDetector(cd, 2)

    local ok, reason = waitAndConfirmCurrentDialog(runToken, "Confirming " .. tostring(partName), 8, 12)
    if not ok then
        return false, reason or "confirm_failed"
    end

    return true
end

local function findNewestNamedMoveable(partName, baselineSet, nearPos, radius, usedParts)
    local mp = getMoveableFolder()
    if not mp then return nil end

    local candidates = {}

    for _, obj in ipairs(mp:GetChildren()) do
        if (obj:IsA("Model") or obj:IsA("BasePart"))
            and obj.Name == partName
            and not (baselineSet and baselineSet[obj])
            and not (usedParts and usedParts[obj]) then

            local pos = getMoveablePosition(obj)
            if pos then
                local dist = nearPos and (pos - nearPos).Magnitude or 0
                if (not radius) or dist <= radius then
                    table.insert(candidates, {Obj = obj, Dist = dist})
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        return a.Dist < b.Dist
    end)

    return candidates[1] and candidates[1].Obj or nil
end

local function waitForFreshBoughtRepair100Part(partName, baselineSet, usedParts, runToken, vehicle)
    -- The object MUST be new after the buy snapshot. Distance is only used for priority.
    -- This fixes the old bug where the script bought the item, failed the 20-stud check,
    -- then skipped RemovePart/ReapplyPart and went straight to the normal repair flow.
    local start = os.clock()

    while canContinue(runToken) and os.clock() - start <= REPAIR100_NEW_PART_TIMEOUT do
        local root = getRoot()
        local anchors = {}
        if root then table.insert(anchors, root.Position) end
        table.insert(anchors, REPAIR100_BUY_PLAYER_CF.Position)
        local carCF = getModelCF(vehicle)
        if carCF then table.insert(anchors, carCF.Position) end

        -- Priority 1: newly spawned exact-name part near the player/store (requested <= 20 studs).
        for _, nearPos in ipairs(anchors) do
            local obj = findNewestNamedMoveable(partName, baselineSet, nearPos, REPAIR100_NEAR_RADIUS, usedParts)
            if obj and obj.Parent then
                return obj
            end
        end

        -- Priority 2: still newly spawned after the buy snapshot, but a little farther away.
        -- This is safe from old parts because baselineSet blocks anything that existed before buying.
        local best, bestDist = nil, math.huge
        local mp = getMoveableFolder()
        if mp then
            for _, obj in ipairs(mp:GetChildren()) do
                if (obj:IsA("Model") or obj:IsA("BasePart"))
                    and obj.Name == partName
                    and not (baselineSet and baselineSet[obj])
                    and not (usedParts and usedParts[obj]) then

                    local pos = getMoveablePosition(obj)
                    if pos then
                        local minDist = math.huge
                        for _, nearPos in ipairs(anchors) do
                            minDist = math.min(minDist, (pos - nearPos).Magnitude)
                        end
                        if minDist <= REPAIR100_FRESH_BACKUP_RADIUS and minDist < bestDist then
                            best = obj
                            bestDist = minDist
                        end
                    end
                end
            end
        end

        if best and best.Parent then
            setStatus("Saved new " .. tostring(partName) .. " • " .. tostring(math.floor(bestDist)) .. " studs")
            return best
        end

        task.wait(0.12)
    end

    return nil
end

local function waitForRemovedOldRepair100Part(partName, beforeRemoveSet, protectedSet, runToken, timeout)
    -- After RemovePart, the old installed part should newly appear in MoveableParts.
    -- We only accept objects that did NOT exist before removing and are NOT one of the fresh bought parts.
    local mp = getMoveableFolder()
    if not mp then return nil end

    timeout = timeout or REPAIR100_OLD_PART_TIMEOUT
    local start = os.clock()
    local best, bestDist

    while canContinue(runToken) and os.clock() - start <= timeout do
        best, bestDist = nil, math.huge

        for _, obj in ipairs(mp:GetChildren()) do
            if (obj:IsA("Model") or obj:IsA("BasePart"))
                and obj.Name == partName
                and not (beforeRemoveSet and beforeRemoveSet[obj])
                and not (protectedSet and protectedSet[obj]) then

                local pos = getMoveablePosition(obj)
                if pos then
                    local dist = (pos - REPAIR100_SWAP_CF.Position).Magnitude
                    if dist < bestDist then
                        best = obj
                        bestDist = dist
                    end
                end
            end
        end

        if best and best.Parent then
            return best
        end

        task.wait(0.12)
    end

    return nil
end

local function removeOldRepair100Part(vehicle, partName, beforeRemoveSet, protectedSet, runToken)
    -- Force RemovePart and verify that the old installed part appears in MoveableParts.
    -- The remote is pulsed because slow clients sometimes ignore a single packet while the car is still settling.
    for attempt = 1, REPAIR100_FORCE_REMOVE_RETRIES do
        if not canContinue(runToken) then return nil end

        setStatus("Removing old " .. tostring(partName) .. " #" .. tostring(attempt))
        fireVehiclePartsEvent(vehicle, "RemovePart", partName, runToken, 2, 0.10)

        local oldObj = waitForRemovedOldRepair100Part(partName, beforeRemoveSet, protectedSet, runToken, 1.10)
        if oldObj and oldObj.Parent then
            return oldObj
        end

        task.wait(0.18)
    end

    return nil
end

local function hideOldRepair100Part(partName, oldObj, slotIndex, runToken)
    if not oldObj or not oldObj.Parent then return false end

    local awayCF = REPLACED_PART_HIDE_CF * CFrame.new(((slotIndex or 1) - 1) * 5, 0, 0)
    setStatus("Hiding old " .. tostring(partName))

    -- Use more retries than normal repair movement because freshly removed parts can snap back.
    local ok = stableTeleportMoveable(oldObj, awayCF, runToken, 0.55, PART_TP_RETRIES + 7)
    safeSetPivot(oldObj, awayCF)
    stopVelocity(oldObj)
    task.wait(0.10)

    return ok or distanceMoveableToCF(oldObj, awayCF) <= (PART_TP_VERIFY_RADIUS * 1.6)
end

local function moveOldReplacementPartsAway(protectedSet, runToken, targetNames, scanSeconds)
    local mp = getMoveableFolder()
    if not mp then return 0 end

    targetNames = targetNames or REPAIR100_REPLACEMENT_PART_SET
    scanSeconds = scanSeconds or 3.25

    local moved = 0
    local movedSet = {}
    local start = os.clock()

    -- Removed parts can appear a few frames after RemovePart fires. Keep scanning
    -- briefly so old Injectors/AirIntake/Sparkplugs do not stay near the car and
    -- get mixed up with the freshly purchased ones.
    while canContinue(runToken) and os.clock() - start <= scanSeconds do
        local foundThisPass = false

        for _, obj in ipairs(mp:GetChildren()) do
            if (obj:IsA("Model") or obj:IsA("BasePart"))
                and targetNames[obj.Name] == true
                and not movedSet[obj]
                and not (protectedSet and protectedSet[obj]) then

                moved += 1
                movedSet[obj] = true
                foundThisPass = true

                local awayCF = REPLACED_PART_HIDE_CF * CFrame.new((moved - 1) * 4, 0, 0)
                setStatus("Hiding old " .. tostring(obj.Name))

                -- Extra retries here because these freshly removed parts are the
                -- most likely to snap back on slow clients.
                stableTeleportMoveable(obj, awayCF, runToken, 0.45, PART_TP_RETRIES + 4)
                safeSetPivot(obj, awayCF)
                stopVelocity(obj)
                task.wait(0.08)
            end
        end

        if moved > 0 and not foundThisPass and os.clock() - start > 1.1 then
            break
        end

        task.wait(0.15)
    end

    return moved
end

local function reapplyRepair100Part(vehicle, partObj, runToken)
    if not vehicle or not vehicle.Parent or not partObj or not partObj.Parent then
        return false
    end

    local function isStillFreshMoveable()
        local mpNow = getMoveableFolder()
        return partObj ~= nil and partObj.Parent ~= nil and mpNow ~= nil and partObj:IsDescendantOf(mpNow)
    end

    if not isStillFreshMoveable() then
        return true
    end

    for attempt = 1, REPAIR100_FORCE_REAPPLY_RETRIES do
        if not canContinue(runToken) then return false end
        if not isStillFreshMoveable() then
            return true
        end

        setStatus("Installing new " .. tostring(partObj.Name) .. " #" .. tostring(attempt))

        -- Keep the exact saved fresh part at the swap point before every remote pulse.
        -- Never re-resolve by workspace.MoveableParts[partName], because that can point to the old hidden part.
        safeSetPivot(partObj, REPAIR100_SWAP_CF)
        stopVelocity(partObj)
        task.wait(0.05)

        fireVehiclePartsEvent(vehicle, "ReapplyPart", partObj, runToken, 2, 0.10)

        local waitStart = os.clock()
        while canContinue(runToken) and os.clock() - waitStart <= 0.75 do
            if not isStillFreshMoveable() then
                return true
            end
            task.wait(0.08)
        end
    end

    return not isStillFreshMoveable()
end

local function runRepair100Replacement(vehicle, engineName, runToken)
    if not Runtime.Repair100Enabled then
        return false
    end
    if not vehicle or not vehicle.Parent then
        return false
    end

    -- Hard safety: Repair 100% must read the engine from the car the player is actually seated in.
    -- If we are not seated, try to sit once; otherwise skip Repair100 instead of buying the wrong folder.
    local seatedVehicle = getSeatedVehicle()
    if seatedVehicle and seatedVehicle.Parent then
        vehicle = seatedVehicle
    else
        setStatus("Repair 100% waiting for DriveSeat before engine read")
        destroyVehicleSeats(vehicle)
        sitInDriveSeat(vehicle, runToken)
        task.wait(0.65)
        seatedVehicle = getSeatedVehicle()
        if seatedVehicle and seatedVehicle.Parent then
            vehicle = seatedVehicle
        else
            setStatus("Repair 100% skipped — not seated in current car")
            return false
        end
    end

    engineName = normalizeEngineName(engineName)

    -- Read again right before the swap flow from the exact EngineLabel path on this seated vehicle.
    local lockedEngine = waitForStableEngineLabel(vehicle, runToken, ENGINE_READ_TIMEOUT)
    if lockedEngine then
        engineName = lockedEngine
    end

    if not engineName or engineName == "" then
        setStatus("Repair 100% skipped — engine not found")
        return false
    end

    local engineFolder = getPartsStoreEngineFolder(engineName)
    if not engineFolder then
        setStatus("Repair 100% skipped — exact store folder missing: " .. tostring(engineName))
        return false
    end

    setStage("Repair100", "Repair 100% setup: " .. tostring(engineName))

    -- Move the bought car to the parts-store pit stop area.
    teleportCarAndChar(vehicle, REPAIR100_CAR_CF, runToken)
    task.wait(0.45)

    -- Exit the vehicle and stand at the store counter.
    unseatCharacter(vehicle)
    task.wait(0.35)
    moveCharacterToCF(REPAIR100_BUY_PLAYER_CF, runToken, "Moving to parts store", false)
    task.wait(0.35)

    local availableParts = getAvailableRepair100StoreParts(engineFolder)
    if #availableParts <= 0 then
        setStatus("Repair 100% skipped — no store parts for this engine")
        return false
    end

    -- Buy and remember fresh parts one-by-one.
    -- Important: the snapshot is taken BEFORE each buy, then we only accept a newly spawned
    -- MoveableParts object within 20 studs from the player. This prevents mixing up old parts.
    local boughtParts = {}
    local boughtObjectSet = {}
    local boughtNames = {}
    local boughtNameSet = {}

    for index, partName in ipairs(availableParts) do
        if not canContinue(runToken) then return false end

        local beforeThisBuySet = snapshotMoveableParts()
        local ok, reason = buyRepair100Part(engineFolder, partName, runToken)

        if ok then
            local newObj = waitForFreshBoughtRepair100Part(partName, beforeThisBuySet, boughtObjectSet, runToken, vehicle)
            if newObj and newObj.Parent then
                boughtParts[partName] = newObj
                boughtObjectSet[newObj] = true
                if not boughtNameSet[partName] then
                    table.insert(boughtNames, partName)
                    boughtNameSet[partName] = true
                end
                setStatus("Saved new " .. tostring(partName))
            else
                -- Do not remove the old installed part if the fresh replacement cannot be identified.
                setStatus("Bought " .. tostring(partName) .. " but no new part appeared within 20 studs")
            end
        else
            setStatus("Buy skipped: " .. tostring(partName) .. " • " .. tostring(reason))
        end

        if index < #availableParts then
            task.wait(REPAIR100_BUY_DELAY)
        end
    end

    if #boughtNames <= 0 then
        setStatus("Repair 100% skipped — no replacement parts saved")
        return false
    end

    -- Move to swap point. Old parts are removed only after the fresh replacements are saved.
    moveCharacterToCF(REPAIR100_SWAP_CF, runToken, "Moving to swap point", false)
    task.wait(0.40)

    local beforeRemoveSet = snapshotMoveableParts()
    local removedOld = 0
    local hiddenOld = 0

    for index, partName in ipairs(boughtNames) do
        if not canContinue(runToken) then return false end

        local freshObj = boughtParts[partName]
        if freshObj and freshObj.Parent then
            local oldObj = removeOldRepair100Part(vehicle, partName, beforeRemoveSet, boughtObjectSet, runToken)
            if oldObj and oldObj.Parent then
                removedOld += 1
                if hideOldRepair100Part(partName, oldObj, index, runToken) then
                    hiddenOld += 1
                end
            else
                setStatus("Remove failed: " .. tostring(partName))
            end
        end

        task.wait(0.18)
    end

    -- Extra cleanup pass in case the game spawns the old parts slightly late.
    local removeNameSet = {}
    for _, partName in ipairs(boughtNames) do
        removeNameSet[partName] = true
    end
    moveOldReplacementPartsAway(beforeRemoveSet, runToken, removeNameSet, 1.75)

    -- Move the saved fresh parts to the swap point and reapply them.
    for index, partName in ipairs(boughtNames) do
        if not canContinue(runToken) then return false end

        local obj = boughtParts[partName]
        if obj and obj.Parent then
            local targetCF = REPAIR100_SWAP_CF * CFrame.new((index - 2) * 3, 0, 0)
            setStatus("Moving new " .. tostring(partName))
            stableTeleportMoveable(obj, targetCF, runToken, 0.55, PART_TP_RETRIES + 4)
            safeSetPivot(obj, targetCF)
            stopVelocity(obj)
            task.wait(0.16)
        else
            setStatus("Saved new " .. tostring(partName) .. " is missing")
        end
    end

    local installed = 0
    for _, partName in ipairs(REPAIR100_REAPPLY_ORDER) do
        if not canContinue(runToken) then return false end

        local partObj = boughtParts[partName]
        if partObj and partObj.Parent then
            setStatus("Installing new " .. tostring(partName))
            if reapplyRepair100Part(vehicle, partObj, runToken) then
                installed += 1
            end
            task.wait(0.20)
        end
    end

    setStatus("Repair 100% installed " .. tostring(installed) .. "/" .. tostring(#boughtNames) .. " • old hidden " .. tostring(hiddenOld) .. "/" .. tostring(removedOld))
    task.wait(0.35)
    return installed > 0
end

-- ──────────────────────────────────────────────────────────
--  MAIN FARM LOOP
-- ──────────────────────────────────────────────────────────
local function farmCycle(runToken)
    if not canContinue(runToken) then return end

    -- Buy/use vehicle. This function already blocks buying when A-Chassis/current seat says we already own a car.
    local vehicle, vErr = acquireJunkyardVehicle(runToken)
    if not vehicle then
        vehicle, vErr = getVehicle()
    end
    if not vehicle then
        setStatus("No vehicle — " .. tostring(vErr))
        task.wait(2)
        return
    end

    -- v13: after acquiring/sitting, trust the physically seated vehicle over any stale A-Chassis pointer.
    local seatedVehicle = getSeatedVehicle()
    if seatedVehicle and seatedVehicle.Parent then
        vehicle = seatedVehicle
        Runtime.CurrentVehicleName = vehicle.Name
    elseif Runtime.Repair100Enabled then
        -- Repair100 buys engine-specific parts, so do not read from A-Chassis unless seated first.
        setStatus("Getting in DriveSeat before engine read")
        destroyVehicleSeats(vehicle)
        sitInDriveSeat(vehicle, runToken)
        task.wait(0.65)
        seatedVehicle = getSeatedVehicle()
        if seatedVehicle and seatedVehicle.Parent then
            vehicle = seatedVehicle
            Runtime.CurrentVehicleName = vehicle.Name
        else
            setStatus("Repair 100% engine read skipped — not seated")
        end
    else
        local ownedVehicle = getCurrentOwnedVehicle()
        if ownedVehicle and ownedVehicle.Parent then
            vehicle = ownedVehicle
            Runtime.CurrentVehicleName = vehicle.Name
        end
    end

    local engineName = nil
    if (not Runtime.Repair100Enabled) or getSeatedVehicle() then
        engineName = waitForStableEngineLabel(vehicle, runToken, ENGINE_READ_TIMEOUT)
    end
    if engineName then
        setStatus("Engine: " .. engineName)
        task.wait(0.35)
    end

    if Runtime.Repair100Enabled then
        local repair100Ok = runRepair100Replacement(vehicle, engineName, runToken)
        if not canContinue(runToken) then return end

        if not repair100Ok then
            setStatus("Repair 100% swap was not completed — retrying once")
            task.wait(0.75)
            repair100Ok = runRepair100Replacement(vehicle, engineName, runToken)
            if not canContinue(runToken) then return end
        end

        if not repair100Ok then
            setStatus("Repair 100% swap failed — continuing normal repair safely")
            task.wait(1.00)
        end

        destroyVehicleSeats(vehicle)
        task.spawn(function()
            holdDriverSeatOnly(vehicle, runToken, 3)
        end)
        task.wait(0.25)
        sitInDriveSeat(vehicle, runToken)
    end

    setStage("RepairZone", "Driving to repair zone")
    teleportCarAndChar(vehicle, REPAIR_CF, runToken)
    task.wait(1)

    -- Snapshot BEFORE stripping. Newly created MoveableParts are preferred during repair,
    -- which avoids grabbing other players' older parts.
    local beforeStripSet = snapshotMoveableParts()

    -- Strip parts from the car.
    setStage("Stripping", "Stripping parts")
    local removedCount = 0

    for _, pName in ipairs(REMOVE_ORDER) do
        if not canContinue(runToken) then return end

        if pName == "Transmission" then
            -- Transmission names are inconsistent. Fire literal "Transmission" first, then every safe variant.
            local firedTransmissionNames = {"Transmission"}
            for _, tName in ipairs(TRANSMISSION_NAMES) do
                table.insert(firedTransmissionNames, tName)
            end

            for _, tName in ipairs(firedTransmissionNames) do
                if not canContinue(runToken) then return end
                pcall(function()
                    vehicle.PartsEvent:FireServer("RemovePart", tName)
                end)
                task.wait(0.06)
            end
            removedCount += 1
        else
            pcall(function()
                vehicle.PartsEvent:FireServer("RemovePart", pName)
            end)
            removedCount += 1
            task.wait(0.16)
        end
    end

    setStatus("Waiting for parts to drop")
    task.wait(0.65)

    -- Re-resolve transmission after stripping, because it normally appears in MoveableParts only now.
    local transObj = findTransmission()

    -- Repair known repairable parts in parallel. All machines/devices start together; each device handles one part at a time for 20s.
    local repairedCount, repairSkipped = runSequentialRepairFlow(beforeStripSet, runToken)
    setStatus("Repaired " .. tostring(repairedCount) .. " parts" .. (repairSkipped > 0 and (" • skipped " .. tostring(repairSkipped)) or ""))
    task.wait(0.35)

    -- Gather everything that may belong to this car to DROP_CF before installation.
    gatherPartsToDrop(transObj, runToken, beforeStripSet)
    task.wait(0.45)

    -- Reapply parts. If a part does not disappear after 2-3 remote attempts, treat it as someone else's part / incompatible.
    local installedCount, ignoredCount = installAllCandidateParts(vehicle, transObj, runToken, beforeStripSet)
    setStatus("Installed " .. tostring(installedCount) .. " parts" .. (ignoredCount > 0 and (" • skipped " .. tostring(ignoredCount)) or ""))
    task.wait(0.5)

    -- Move car to sell point. Always make sure we sit in DriveSeat first.
    setStage("MoveToSell", "Going to sell")

    destroyVehicleSeats(vehicle)
    task.spawn(function()
        holdDriverSeatOnly(vehicle, runToken, 3)
    end)
    task.wait(0.25)

    local seated = sitInDriveSeat(vehicle, runToken)
    if not seated then
        setStatus("Getting in car again")
        task.wait(0.75)
        seated = sitInDriveSeat(vehicle, runToken)
    end

    teleportCarAndChar(vehicle, SELL_CF, runToken)
    task.wait(1.5)

    unseatCharacter(vehicle)
    task.wait(0.5)

    moveCharacterToCF(CFrame.new(SELL_EXIT), runToken, "Moving to sell prompt", false)
    task.wait(0.5)
    restoreCharacter()

    local sold = sellUntilVehicleGone(vehicle, runToken)
    if not sold then
        setStatus("Sell not confirmed, continuing safely")
    end

    restoreCharacter()
    task.wait(1)

    setStage("Idle", "Cycle complete — restarting")
    task.wait(1)
end

-- ──────────────────────────────────────────────────────────
--  FARM LOOP RUNNER
-- ──────────────────────────────────────────────────────────
local function startFarmLoop()
    Runtime.Thread += 1
    local id = Runtime.Thread

    task.spawn(function()
        while Runtime.Alive and Runtime.Enabled and Runtime.Thread == id do
            local ok, err = pcall(function() farmCycle(Runtime.RunToken) end)
            if not ok then
                setStatus("Error: "..tostring(err):sub(1, 60))
                task.wait(2)
            end
        end
    end)
end

local function setEnabled(v)
    Runtime.Enabled = v
    Runtime.RunToken += 1
    if v then
        setStage("Starting", "Starting")
        startFarmLoop()
    else
        Runtime.Thread += 1
        Runtime.CurrentVehicleName = nil
        setStage("Idle", "Stopped")
    end
end

-- ──────────────────────────────────────────────────────────
--  GUI — macOS Style (original layout preserved, status added)
-- ──────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name          = GUI_NAME
gui.ResetOnSpawn  = false
gui.IgnoreGuiInset= true
gui.Parent        = PG
gui.Enabled       = not Runtime.AntiAfkEnabled

local main = Instance.new("Frame")
main.Size             = UDim2.new(0, 410, 0, 390)
main.Position         = UDim2.new(0.5, -205, 0.5, -185)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
main.BorderSizePixel  = 0
main.Active           = true
main.Parent           = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 22)

local stroke = Instance.new("UIStroke")
stroke.Color        = Color3.fromRGB(70, 70, 78)
stroke.Thickness    = 1
stroke.Transparency = 0.25
stroke.Parent       = main

-- Title bar
local top = Instance.new("Frame")
top.Size             = UDim2.new(1, 0, 0, 48)
top.BackgroundColor3 = Color3.fromRGB(34, 34, 38)
top.BorderSizePixel  = 0
top.Parent           = main

Instance.new("UICorner", top).CornerRadius = UDim.new(0, 22)

local fix = Instance.new("Frame")
fix.Size             = UDim2.new(1, 0, 0, 22)
fix.Position         = UDim2.new(0, 0, 1, -22)
fix.BackgroundColor3 = top.BackgroundColor3
fix.BorderSizePixel  = 0
fix.Parent           = top

local function circle(x, color)
    local b = Instance.new("TextButton")
    b.Size            = UDim2.new(0, 13, 0, 13)
    b.Position        = UDim2.new(0, x, 0, 18)
    b.BackgroundColor3= color
    b.Text            = ""
    b.AutoButtonColor = false
    b.Parent          = top
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    return b
end

local closeBtn = circle(17, Color3.fromRGB(255, 95, 87))
local miniBtn  = circle(40, Color3.fromRGB(255, 189, 46))
circle(63, Color3.fromRGB(39, 201, 63))

local titleLbl = Instance.new("TextLabel")
titleLbl.Size             = UDim2.new(1, -100, 1, 0)
titleLbl.Position         = UDim2.new(0, 92, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text             = "DYHUB | Fix It Up!"
titleLbl.TextColor3       = Color3.fromRGB(240, 240, 245)
titleLbl.Font             = Enum.Font.GothamSemibold
titleLbl.TextSize         = 15
titleLbl.TextXAlignment   = Enum.TextXAlignment.Left
titleLbl.Parent           = top

-- Main card
local card = Instance.new("Frame")
card.Size             = UDim2.new(1, -32, 0, 86)
card.Position         = UDim2.new(0, 16, 0, 66)
card.BackgroundColor3 = Color3.fromRGB(31, 31, 35)
card.BorderSizePixel  = 0
card.Parent           = main

Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)

local nameLbl = Instance.new("TextLabel")
nameLbl.Size            = UDim2.new(1, -105, 0, 28)
nameLbl.Position        = UDim2.new(0, 16, 0, 14)
nameLbl.BackgroundTransparency = 1
nameLbl.Text            = "Auto Farm"
nameLbl.TextColor3      = Color3.fromRGB(245, 245, 248)
nameLbl.Font            = Enum.Font.GothamSemibold
nameLbl.TextSize        = 16
nameLbl.TextXAlignment  = Enum.TextXAlignment.Left
nameLbl.Parent          = card

local descLbl = Instance.new("TextLabel")
descLbl.Size            = UDim2.new(1, -225, 0, 34)
descLbl.Position        = UDim2.new(0, 16, 0, 42)
descLbl.BackgroundTransparency = 1
descLbl.Text            = "Strip → Repair → Install → Sell → Repeat"
descLbl.TextColor3      = Color3.fromRGB(155, 155, 165)
descLbl.Font            = Enum.Font.Gotham
descLbl.TextSize        = 12
descLbl.TextWrapped     = true
descLbl.TextXAlignment  = Enum.TextXAlignment.Left
descLbl.Parent          = card

-- Toggle switch
local toggle = Instance.new("TextButton")
toggle.Size             = UDim2.new(0, 60, 0, 32)
toggle.Position         = UDim2.new(1, -76, 0, 27)
toggle.BackgroundColor3 = Color3.fromRGB(58, 58, 64)
toggle.Text             = ""
toggle.AutoButtonColor  = false
toggle.Parent           = card

Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

local knob = Instance.new("Frame")
knob.Size             = UDim2.new(0, 24, 0, 24)
knob.Position         = UDim2.new(0, 4, 0.5, -12)
knob.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
knob.BorderSizePixel  = 0
knob.Parent           = toggle

Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

-- Movement mode dropdown beside Auto Farm toggle
local movementTitle = Instance.new("TextLabel")
movementTitle.Size            = UDim2.new(0, 96, 0, 18)
movementTitle.Position        = UDim2.new(1, -190, 0, 16)
movementTitle.BackgroundTransparency = 1
movementTitle.Text            = "Movement Mode"
movementTitle.TextColor3      = Color3.fromRGB(180, 180, 190)
movementTitle.Font            = Enum.Font.GothamSemibold
movementTitle.TextSize        = 10
movementTitle.TextXAlignment  = Enum.TextXAlignment.Left
movementTitle.Parent          = card

local movementButton = Instance.new("TextButton")
movementButton.Size             = UDim2.new(0, 104, 0, 30)
movementButton.Position         = UDim2.new(1, -194, 0, 42)
movementButton.BackgroundColor3 = Color3.fromRGB(44, 44, 50)
movementButton.BorderSizePixel  = 0
movementButton.AutoButtonColor  = false
movementButton.Text             = Runtime.MovementText
movementButton.TextColor3       = Color3.fromRGB(245, 245, 248)
movementButton.Font             = Enum.Font.GothamSemibold
movementButton.TextSize         = 12
movementButton.Parent           = card

Instance.new("UICorner", movementButton).CornerRadius = UDim.new(0, 10)

local movementMenu = Instance.new("Frame")
movementMenu.Size             = UDim2.new(0, 104, 0, 76)
movementMenu.Position         = UDim2.new(1, -210, 0, 138)
movementMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
movementMenu.BorderSizePixel  = 0
movementMenu.Visible          = false
movementMenu.ZIndex           = 40
movementMenu.Parent           = main

Instance.new("UICorner", movementMenu).CornerRadius = UDim.new(0, 12)

local movementMenuLayout = Instance.new("UIListLayout")
movementMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
movementMenuLayout.Padding = UDim.new(0, 5)
movementMenuLayout.Parent = movementMenu

local movementMenuPad = Instance.new("UIPadding")
movementMenuPad.PaddingTop = UDim.new(0, 8)
movementMenuPad.PaddingBottom = UDim.new(0, 8)
movementMenuPad.PaddingLeft = UDim.new(0, 8)
movementMenuPad.PaddingRight = UDim.new(0, 8)
movementMenuPad.Parent = movementMenu

-- Status panel (inside main, below card)
local statusPanel = Instance.new("Frame")
statusPanel.Size             = UDim2.new(1, -32, 0, 60)
statusPanel.Position         = UDim2.new(0, 16, 0, 166)
statusPanel.BackgroundColor3 = Color3.fromRGB(31, 31, 35)
statusPanel.BorderSizePixel  = 0
statusPanel.Parent           = main

Instance.new("UICorner", statusPanel).CornerRadius = UDim.new(0, 14)

local dotIndicator = Instance.new("Frame")
dotIndicator.Size             = UDim2.new(0, 8, 0, 8)
dotIndicator.Position         = UDim2.new(0, 12, 0.5, -4)
dotIndicator.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
dotIndicator.BorderSizePixel  = 0
dotIndicator.Parent           = statusPanel

Instance.new("UICorner", dotIndicator).CornerRadius = UDim.new(1, 0)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size            = UDim2.new(1, -36, 1, 0)
statusLbl.Position        = UDim2.new(0, 28, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text            = "Ready"
statusLbl.TextColor3      = Color3.fromRGB(180, 180, 190)
statusLbl.Font            = Enum.Font.Gotham
statusLbl.TextSize        = 13
statusLbl.TextXAlignment  = Enum.TextXAlignment.Left
statusLbl.TextWrapped     = true
statusLbl.Parent          = statusPanel

-- Junkyard settings panel
local settingsPanel = Instance.new("Frame")
settingsPanel.Size             = UDim2.new(1, -32, 0, 88)
settingsPanel.Position         = UDim2.new(0, 16, 0, 238)
settingsPanel.BackgroundColor3 = Color3.fromRGB(31, 31, 35)
settingsPanel.BorderSizePixel  = 0
settingsPanel.Parent           = main

Instance.new("UICorner", settingsPanel).CornerRadius = UDim.new(0, 14)

local selectTitle = Instance.new("TextLabel")
selectTitle.Size            = UDim2.new(0, 150, 0, 22)
selectTitle.Position        = UDim2.new(0, 14, 0, 10)
selectTitle.BackgroundTransparency = 1
selectTitle.Text            = "Select Type (%)"
selectTitle.TextColor3      = Color3.fromRGB(220, 220, 228)
selectTitle.Font            = Enum.Font.GothamSemibold
selectTitle.TextSize        = 13
selectTitle.TextXAlignment  = Enum.TextXAlignment.Left
selectTitle.Parent          = settingsPanel

local selectButton = Instance.new("TextButton")
selectButton.Size             = UDim2.new(0, 142, 0, 30)
selectButton.Position         = UDim2.new(0, 14, 0, 42)
selectButton.BackgroundColor3 = Color3.fromRGB(44, 44, 50)
selectButton.BorderSizePixel  = 0
selectButton.AutoButtonColor  = false
selectButton.Text             = Runtime.SelectText
selectButton.TextColor3       = Color3.fromRGB(245, 245, 248)
selectButton.Font             = Enum.Font.GothamSemibold
selectButton.TextSize         = 13
selectButton.Parent           = settingsPanel

Instance.new("UICorner", selectButton).CornerRadius = UDim.new(0, 10)

local selectMenu = Instance.new("Frame")
selectMenu.Size             = UDim2.new(0, 142, 0, 284)
selectMenu.Position         = UDim2.new(0, 14, 0, 76)
selectMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
selectMenu.BorderSizePixel  = 0
selectMenu.Visible          = false
selectMenu.ZIndex           = 30
selectMenu.Parent           = main

Instance.new("UICorner", selectMenu).CornerRadius = UDim.new(0, 12)

local selectMenuLayout = Instance.new("UIListLayout")
selectMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
selectMenuLayout.Padding = UDim.new(0, 4)
selectMenuLayout.Parent = selectMenu

local selectMenuPad = Instance.new("UIPadding")
selectMenuPad.PaddingTop = UDim.new(0, 8)
selectMenuPad.PaddingBottom = UDim.new(0, 8)
selectMenuPad.PaddingLeft = UDim.new(0, 8)
selectMenuPad.PaddingRight = UDim.new(0, 8)
selectMenuPad.Parent = selectMenu

local repair100Title = Instance.new("TextLabel")
repair100Title.Size            = UDim2.new(0, 90, 0, 22)
repair100Title.Position        = UDim2.new(0, 166, 0, 10)
repair100Title.BackgroundTransparency = 1
repair100Title.Text            = "Repair 100%"
repair100Title.TextColor3      = Color3.fromRGB(220, 220, 228)
repair100Title.Font            = Enum.Font.GothamSemibold
repair100Title.TextSize        = 13
repair100Title.TextXAlignment  = Enum.TextXAlignment.Left
repair100Title.Parent          = settingsPanel

local repair100Toggle = Instance.new("TextButton")
repair100Toggle.Size             = UDim2.new(0, 60, 0, 30)
repair100Toggle.Position         = UDim2.new(0, 166, 0, 42)
repair100Toggle.BackgroundColor3 = Color3.fromRGB(58, 58, 64)
repair100Toggle.Text             = ""
repair100Toggle.AutoButtonColor  = false
repair100Toggle.Parent           = settingsPanel

Instance.new("UICorner", repair100Toggle).CornerRadius = UDim.new(1, 0)

local repair100Knob = Instance.new("Frame")
repair100Knob.Size             = UDim2.new(0, 22, 0, 22)
repair100Knob.Position         = UDim2.new(0, 4, 0.5, -11)
repair100Knob.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
repair100Knob.BorderSizePixel  = 0
repair100Knob.Parent           = repair100Toggle

Instance.new("UICorner", repair100Knob).CornerRadius = UDim.new(1, 0)

local espTitle = Instance.new("TextLabel")
espTitle.Size            = UDim2.new(0, 100, 0, 22)
espTitle.Position        = UDim2.new(1, -106, 0, 10)
espTitle.BackgroundTransparency = 1
espTitle.Text            = "Esp Car (%)"
espTitle.TextColor3      = Color3.fromRGB(220, 220, 228)
espTitle.Font            = Enum.Font.GothamSemibold
espTitle.TextSize        = 13
espTitle.TextXAlignment  = Enum.TextXAlignment.Left
espTitle.Parent          = settingsPanel

local espToggle = Instance.new("TextButton")
espToggle.Size             = UDim2.new(0, 60, 0, 30)
espToggle.Position         = UDim2.new(1, -106, 0, 42)
espToggle.BackgroundColor3 = Color3.fromRGB(58, 58, 64)
espToggle.Text             = ""
espToggle.AutoButtonColor  = false
espToggle.Parent           = settingsPanel

Instance.new("UICorner", espToggle).CornerRadius = UDim.new(1, 0)

local espKnob = Instance.new("Frame")
espKnob.Size             = UDim2.new(0, 22, 0, 22)
espKnob.Position         = UDim2.new(0, 4, 0.5, -11)
espKnob.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
espKnob.BorderSizePixel  = 0
espKnob.Parent           = espToggle

Instance.new("UICorner", espKnob).CornerRadius = UDim.new(1, 0)

local function updateEspToggle()
    local on = Runtime.CarEspEnabled
    TweenService:Create(espToggle, TweenInfo.new(0.18), {
        BackgroundColor3 = on and Color3.fromRGB(50, 170, 95) or Color3.fromRGB(58, 58, 64)
    }):Play()
    TweenService:Create(espKnob, TweenInfo.new(0.18), {
        Position = on and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
    }):Play()
end

local function updateRepair100Toggle()
    local on = Runtime.Repair100Enabled
    TweenService:Create(repair100Toggle, TweenInfo.new(0.18), {
        BackgroundColor3 = on and Color3.fromRGB(50, 170, 95) or Color3.fromRGB(58, 58, 64)
    }):Play()
    TweenService:Create(repair100Knob, TweenInfo.new(0.18), {
        Position = on and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
    }):Play()
end

local function updateSelectButton()
    selectButton.Text = Runtime.SelectText
end

local function updateMovementButton()
    movementButton.Text = Runtime.MovementText or Runtime.MovementMode or "Tween"
end

for index, modeName in ipairs(MOVEMENT_MODE_OPTIONS) do
    local opt = Instance.new("TextButton")
    opt.Size             = UDim2.new(1, 0, 0, 28)
    opt.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    opt.BorderSizePixel  = 0
    opt.AutoButtonColor  = false
    opt.Text             = modeName
    opt.TextColor3       = Color3.fromRGB(235, 235, 240)
    opt.Font             = Enum.Font.GothamSemibold
    opt.TextSize         = 12
    opt.LayoutOrder      = index
    opt.ZIndex           = 41
    opt.Parent           = movementMenu

    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 8)

    Runtime.Add(opt.MouseButton1Click:Connect(function()
        Runtime.MovementMode = modeName
        Runtime.MovementText = modeName
        updateMovementButton()
        movementMenu.Visible = false
        syncKaitunSetting("Movement Mode", modeName)
        if modeName == "Teleport" then
            showTeleportWarning()
        else
            setStatus("Movement mode: " .. modeName)
        end
    end))
end

Runtime.Add(movementButton.MouseButton1Click:Connect(function()
    movementMenu.Visible = not movementMenu.Visible
    selectMenu.Visible = false
end))

for index, option in ipairs(JUNKYARD_SELECT_OPTIONS) do
    local opt = Instance.new("TextButton")
    opt.Size             = UDim2.new(1, 0, 0, 26)
    opt.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    opt.BorderSizePixel  = 0
    opt.AutoButtonColor  = false
    opt.Text             = option.Text
    opt.TextColor3       = Color3.fromRGB(235, 235, 240)
    opt.Font             = Enum.Font.GothamSemibold
    opt.TextSize         = 12
    opt.LayoutOrder      = index
    opt.ZIndex           = 31
    opt.Parent           = selectMenu

    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 8)

    Runtime.Add(opt.MouseButton1Click:Connect(function()
        Runtime.SelectThreshold = option.Value
        Runtime.SelectText = option.Text
        updateSelectButton()
        selectMenu.Visible = false
        syncKaitunSetting("Select Type (%)", option.Text)
        setStatus("Selected car type: " .. option.Text)
    end))
end

Runtime.Add(selectButton.MouseButton1Click:Connect(function()
    selectMenu.Visible = not selectMenu.Visible
    movementMenu.Visible = false
end))

Runtime.Add(repair100Toggle.MouseButton1Click:Connect(function()
    Runtime.Repair100Enabled = not Runtime.Repair100Enabled
    syncKaitunSetting("Repair 100%", Runtime.Repair100Enabled)
    updateRepair100Toggle()
    setStatus(Runtime.Repair100Enabled and "Repair 100% enabled" or "Repair 100% disabled")
end))

Runtime.Add(espToggle.MouseButton1Click:Connect(function()
    setCarEspEnabled(not Runtime.CarEspEnabled)
    syncKaitunSetting("Car ESP", Runtime.CarEspEnabled)
    updateEspToggle()
    setStatus(Runtime.CarEspEnabled and "Car ESP enabled" or "Car ESP disabled")
end))


-- Wire up status callback
Runtime.StatusCB = function(txt)
    local on = Runtime.Enabled
    statusLbl.Text = tostring(txt)
    -- Dot color: green when running, amber when idle, red on error
    if not on then
        dotIndicator.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
    elseif txt:lower():find("error") then
        dotIndicator.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
    else
        dotIndicator.BackgroundColor3 = Color3.fromRGB(39, 201, 63)
    end
end

-- Toggle visuals
local function updateToggle()
    local on = Runtime.Enabled
    TweenService:Create(toggle, TweenInfo.new(0.18), {
        BackgroundColor3 = on and Color3.fromRGB(50, 170, 95) or Color3.fromRGB(58, 58, 64)
    }):Play()
    TweenService:Create(knob, TweenInfo.new(0.18), {
        Position = on and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -12)
    }):Play()
    if not on then
        dotIndicator.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
    end
end

-- Toggle click
Runtime.Add(toggle.MouseButton1Click:Connect(function()
    local v = not Runtime.Enabled
    setEnabled(v)
    syncKaitunSetting("Auto Farm", Runtime.Enabled)
    updateToggle()
end))

-- Close button
Runtime.Add(closeBtn.MouseButton1Click:Connect(function()
    Runtime.Destroy()
end))

-- Minimise button
Runtime.Add(miniBtn.MouseButton1Click:Connect(function()
    local small = main.Size.Y.Offset > 60
    TweenService:Create(main, TweenInfo.new(0.2), {
        Size = small and UDim2.new(0, 410, 0, 48) or UDim2.new(0, 410, 0, 390)
    }):Play()
    card.Visible        = not small
    statusPanel.Visible = not small
    settingsPanel.Visible = not small
    selectMenu.Visible = false
    movementMenu.Visible = false
end))

-- Drag
do
    local dragging, dragStart, startPos = false, nil, nil

    Runtime.Add(top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = main.Position
        end
    end))

    Runtime.Add(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    Runtime.Add(UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end))
end

Runtime.Add(UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or (not selectMenu.Visible and not movementMenu.Visible) then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position

        local function isInside(frame)
            if not frame or not frame.Visible then return false end
            local absPos = frame.AbsolutePosition
            local absSize = frame.AbsoluteSize
            return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
        end

        if selectMenu.Visible and not isInside(selectMenu) and not isInside(selectButton) then
            selectMenu.Visible = false
        end
        if movementMenu.Visible and not isInside(movementMenu) and not isInside(movementButton) then
            movementMenu.Visible = false
        end
    end
end))

-- Initialise
updateToggle()
updateEspToggle()
updateRepair100Toggle()
updateSelectButton()
updateMovementButton()

if Runtime.MovementMode == "Teleport" then
    task.defer(showTeleportWarning)
end

if Runtime.Enabled then
    setStatus("Kaitun auto farm enabled")
    task.defer(function()
        if Runtime.Alive and Runtime.Enabled then
            startFarmLoop()
        end
    end)
else
    setStatus("Ready")
end
