-- =========================
local version = "BETA"
local ver     = "v014.22"
-- =========================

repeat task.wait() until game:IsLoaded()

-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

if setfpscap then
    setfpscap(1000000)
    WindUI:Notify({ Title = "Service", Content = "FPS Unlocked! | " .. ver, Duration = 3, Icon = "cpu" })
else
    WindUI:Notify({ Title = "Not Working", Content = "Your exploit does not support setfpscap.", Duration = 3, Icon = "ban" })
end

-- ====================== SERVICES ======================
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local StarterGui        = game:GetService("StarterGui")
local TeleportService   = game:GetService("TeleportService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local VIM               = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = Workspace.CurrentCamera

-- ====================== CHARACTER CACHE ======================
local Character        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid         = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character        = char
    Humanoid         = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- ====================== VERSION CHECK ======================
local FreeVersion    = "Free Version"
local PremiumVersion = "Premium Version"

local function checkVersion(playerName)
    local url = "https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua"
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then return FreeVersion end
    local func = loadstring(response)
    if not func then return FreeVersion end
    local ok, premiumData = pcall(func)
    if not ok then return FreeVersion end
    return premiumData and premiumData[playerName] and PremiumVersion or FreeVersion
end

local userversion = checkVersion(LocalPlayer.Name)
local isPremium   = (userversion == PremiumVersion)

-- ====================== WINDOW ======================
local Window = WindUI:CreateWindow({
    Title      = "DYHUB",
    IconThemed = true,
    Icon       = "rbxassetid://104487529937663",
    Author     = "Animal Hospital | " .. userversion,
    Folder     = "DYHUB_AnimalHospital",
    Size       = UDim2.fromOffset(500, 400),
    Transparent = true,
    Theme      = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar    = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.K)
pcall(function() Window:Tag({ Title = version, Color = Color3.fromHex("#db7093") }) end)
Window:EditOpenButton({
    Title           = "DYHUB - Open",
    Icon            = "monitor",
    CornerRadius    = UDim.new(0, 6),
    StrokeThickness = 2,
    Color           = ColorSequence.new(Color3.fromRGB(30,30,30), Color3.fromRGB(255,255,255)),
    Draggable       = true,
})

-- ====================== CONFIG SYSTEM ======================
local ConfigFolder = "DYHUB_AH"
local CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self      = setmetatable({}, CustomConfig)
    self.ConfigData = {}
    self.ConfigPath = ConfigFolder .. "/config_ah.json"
    self._autoSaveThread = nil
    self._autoSaveDelay  = 15
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    self:Load()
    return self
end
function CustomConfig:Set(key, value) self.ConfigData[key] = value end
function CustomConfig:Get(key, default)
    local v = self.ConfigData[key]
    return v ~= nil and v or default
end
function CustomConfig:Save()
    local ok, err = pcall(function()
        writefile(self.ConfigPath, HttpService:JSONEncode(self.ConfigData))
    end)
    if not ok then warn("[DYHUB] Save failed:", err) end
end
function CustomConfig:Load()
    if isfile(self.ConfigPath) then
        local ok, result = pcall(function()
            return HttpService:JSONDecode(readfile(self.ConfigPath))
        end)
        if ok and type(result) == "table" then
            self.ConfigData = result
            print("[DYHUB] Config loaded!")
        else
            warn("[DYHUB] Failed to load config, using defaults")
            self.ConfigData = {}
        end
    else
        print("[DYHUB] No config found, creating new one")
        self.ConfigData = {}
    end
end
function CustomConfig:AutoSave(interval)
    if self._autoSaveThread then
        task.cancel(self._autoSaveThread)
        self._autoSaveThread = nil
    end
    if interval and interval > 0 then
        self._autoSaveDelay  = interval
        self._autoSaveThread = task.spawn(function()
            while true do
                task.wait(self._autoSaveDelay or 15)
                self:Save()
            end
        end)
    end
end

local Config = CustomConfig.new()
if Config:Get("AutoSaveEnabled", true) then
    Config:AutoSave(Config:Get("AutoSaveDelay", 15))
end

-- ====================== SETTINGS TABLE (รวม state ทั้งหมด) ======================
local settings = {
    AutoTreat       = Config:Get("AutoTreat",       false),
    AutoCoffee      = Config:Get("AutoCoffee",      false),
    AutoCheckIn     = Config:Get("AutoCheckIn",     false),
    EspEnabled      = Config:Get("EspEnabled",      false),
    AutoMedicine    = Config:Get("AutoMedicine",    false),
    AutoSlime       = Config:Get("AutoSlime",       false),
    AutoFire        = Config:Get("AutoFire",        false),
    AutoTaser       = Config:Get("AutoTaser",       false),
    AutoSaveEnabled = Config:Get("AutoSaveEnabled", true),
    AutoSaveDelay   = Config:Get("AutoSaveDelay",   15),
}

-- ====================== SHARED UTILITIES ======================
local ProcessedNPCs = {}

local function firePromptIn(instance)
    if not instance then return end
    local prompt = instance:FindFirstChild("PP") or instance:FindFirstChildOfClass("ProximityPrompt")
    if prompt then fireproximityprompt(prompt) end
end

local function normalizeString(str)
    if not str then return "" end
    return string.gsub(string.lower(str), "%s+", "")
end

local function hasTool(parentFolder, itemName)
    if not parentFolder then return false end
    local normName = normalizeString(itemName)
    for _, tool in ipairs(parentFolder:GetChildren()) do
        if tool:IsA("Tool") and normalizeString(tool.Name) == normName then
            return true
        end
    end
    return false
end

local function getActivePatientInfo()
    local misc = Workspace:FindFirstChild("Misc")
    if not misc then return nil, nil, nil end

    local deskNames = {"CheckIn", "CheckIn2"}
    for _, deskName in ipairs(deskNames) do
        local desk = misc:FindFirstChild(deskName)
        if desk then
            local bell = desk:FindFirstChild("Bell")
            if bell then
                local bellPos
                if bell:IsA("BasePart") then
                    bellPos = bell.Position
                else
                    local actualPart = bell:FindFirstChildOfClass("BasePart") or (bell:IsA("Model") and bell.PrimaryPart)
                    if actualPart then bellPos = actualPart.Position end
                end

                if bellPos then
                    for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
                        if npc:GetAttribute("IsPatient") == true then
                            local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                            if root then
                                local distance = (root.Position - bellPos).Magnitude
                                if distance <= 5 then
                                    return npc, desk, bellPos
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil, nil, nil
end

if Workspace:FindFirstChild("NPCs") then
    Workspace.NPCs.ChildRemoved:Connect(function(child)
        if ProcessedNPCs[child] then ProcessedNPCs[child] = nil end
    end)
end

-- ====================== TABS ======================
local InfoTab     = Window:Tab({ Title = "Information", Icon = "info" })
local _D2         = Window:Divider()
local MainTab     = Window:Tab({ Title = "Main",        Icon = "rocket" })
local EspTab      = Window:Tab({ Title = "Esp",         Icon = "eye" })
local TeleportTab = Window:Tab({ Title = "Collect",     Icon = "package" })
local _D3         = Window:Divider()
local Main3       = Window:Tab({ Title = "Settings",    Icon = "settings" })

Window:SelectTab(1)

-- ====================== MAIN TAB ======================
MainTab:Divider()
MainTab:Section({ Title = "Hospital Automation", Icon = "activity" })

-- FEATURE: Auto Treating Patients
do
    -- Supply item -> pickup position lookup (fixed world positions)
    local ItemPositions = {
        Herbs           = Vector3.new(-137, 3, -59),
        Medicine        = Vector3.new(-137, 3, -62),
        ["Eye Drops"]   = Vector3.new(-153, 3, -57),
        ["IV Drops"]    = Vector3.new(-153, 3, -60),
        ["Cough Syrup"] = Vector3.new(-137, 3, -79),
        ["Maple Syrup"] = Vector3.new(-137, 3, -82),
        Bandages        = Vector3.new(-153, 3, -83),
        Ointment        = Vector3.new(-153, 3, -80),
        Thermo          = Vector3.new(-153, 3, -71),
        Medkit          = Vector3.new(-153, 3, -69),
    }

    local ProcessedTreatment = {}

    MainTab:Paragraph({
        Title = "Info: Treating Patients",
        Desc  = "Runs the full treatment sequence per patient: \nDNA Sample → Analyzer → Monitor → fetch the reported item → Apply Treatment.",
        Image = "stethoscope", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Treating Patients",
        Desc     = "You must be standing in the same room as the patient for a step to treat.",
        Value    = settings.AutoTreat,
        Callback = function(v)
            settings.AutoTreat = v
            Config:Set("AutoTreat", v); Config:Save()
            if not v then table.clear(ProcessedTreatment) end
            WindUI:Notify({ Title="Auto Treating Patients", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "stethoscope" or "ban" })
        end
    })

    -- Works for both Folders and Models: averages every BasePart position under the room
    -- to get a rough center point, then a room radius (max distance from center to any part).
    -- This avoids relying on Model:GetBoundingBox(), which silently fails (and gets swallowed
    -- by pcall) whenever RoomN happens to be a Folder rather than a Model.
    local RoomCenterCache = {}

    local function getRoomCenterAndRadius(room)
        local cached = RoomCenterCache[room]
        if cached then return cached.center, cached.radius end

        local sumPos, count = Vector3.new(), 0
        local parts = {}
        for _, part in ipairs(room:GetDescendants()) do
            if part:IsA("BasePart") then
                sumPos = sumPos + part.Position
                count  = count + 1
                table.insert(parts, part)
            end
        end
        if count == 0 then return nil, nil end

        local center = sumPos / count
        local radius = 0
        for _, part in ipairs(parts) do
            local d = (part.Position - center).Magnitude
            if d > radius then radius = d end
        end
        radius = math.max(radius, 15) -- floor, in case the room is tiny/oddly built

        RoomCenterCache[room] = { center = center, radius = radius }
        return center, radius
    end

    -- Finds which RoomN (Folder or Model, under Rooms.Medical) the patient NPC is physically closest to
    local function findPatientRoom(npc)
        local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        if not root then return nil end
        local rooms   = Workspace:FindFirstChild("Rooms")
        local medical = rooms and rooms:FindFirstChild("Medical")
        if not medical then
            warn("[DYHUB] Auto Treating Patients: workspace.Rooms.Medical not found")
            return nil
        end

        local bestRoom, bestDist = nil, math.huge
        for _, room in ipairs(medical:GetChildren()) do
            if string.match(room.Name, "^Room%d+$") then
                local center, radius = getRoomCenterAndRadius(room)
                if center then
                    local dist = (root.Position - center).Magnitude
                    if dist <= radius and dist < bestDist then
                        bestDist = dist
                        bestRoom = room
                    end
                end
            end
        end
        return bestRoom
    end

    local function playerInRoom(room)
        if not room or not HumanoidRootPart then return false end
        local center, radius = getRoomCenterAndRadius(room)
        if not center then return false end
        return (HumanoidRootPart.Position - center).Magnitude <= radius
    end

    local function getActionText(prompt)
        if not prompt then return "" end
        return prompt.ActionText or ""
    end

    -- Looks for a ProximityPrompt near a world position, first inside `scope`, then falling back to the whole Workspace.
    -- If itemName is given, it PREFERS a prompt whose ActionText (or part Name) matches that item
    -- (e.g. ActionText == "Herbs") over whatever prompt just happens to be geometrically nearest —
    -- this is what was firing the wrong/empty prompt and causing the teleport-back-with-nothing bug.
    local function findNearestPromptTo(position, scope, maxDist, itemName)
        maxDist = maxDist or 15
        local normItemName = itemName and normalizeString(itemName) or nil

        local function scan(container, requireMatch)
            local bestPrompt, bestDist = nil, maxDist
            for _, desc in ipairs(container:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    local part = desc.Parent
                    if part and part:IsA("BasePart") then
                        local dist = (part.Position - position).Magnitude
                        if dist <= bestDist then
                            if requireMatch then
                                local actionNorm = normalizeString(getActionText(desc))
                                local nameNorm    = normalizeString(part.Name)
                                if actionNorm == normItemName or nameNorm == normItemName then
                                    bestDist   = dist
                                    bestPrompt = desc
                                end
                            else
                                bestDist   = dist
                                bestPrompt = desc
                            end
                        end
                    end
                end
            end
            return bestPrompt
        end

        if normItemName then
            local matched = scope and scan(scope, true)
            if not matched then matched = scan(Workspace, true) end
            if matched then return matched end
        end

        -- fallback: nearest prompt regardless of ActionText (old behaviour)
        local nearest = scope and scan(scope, false)
        if not nearest then nearest = scan(Workspace, false) end
        return nearest
    end

    -- Scans EVERY ProximityPrompt in the whole Workspace (no room/scope restriction, no
    -- distance cutoff) and returns the one whose ActionText (or its part's Name) matches
    -- itemName, picking the closest match to the player's CURRENT position. This is meant
    -- to be called right after teleporting near ItemPositions[itemName] — since that table
    -- is only an approximate coordinate, restricting the search to a small radius around it
    -- was causing the scan to miss the real pickup prompt entirely (so nothing ever got fired).
    local function findPromptForItem(itemName)
        local normItemName = normalizeString(itemName)
        local originPos = HumanoidRootPart and HumanoidRootPart.Position
        if not originPos then return nil end

        local bestPrompt, bestDist = nil, math.huge
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                local part = desc.Parent
                if part and part:IsA("BasePart") then
                    local actionNorm = normalizeString(getActionText(desc))
                    local nameNorm    = normalizeString(part.Name)
                    if actionNorm == normItemName or nameNorm == normItemName then
                        local dist = (part.Position - originPos).Magnitude
                        if dist < bestDist then
                            bestDist   = dist
                            bestPrompt = desc
                        end
                    end
                end
            end
        end
        return bestPrompt
    end

    -- -----------------------------------------------------------------------
    -- findApplyTreatmentPP: หา PP ที่ ActionText == "Apply Treatment"
    -- โดยมองใน Minigame.Bed.InBed (รองรับทุกห้อง) และ fallback ไปยัง NPC
    -- -----------------------------------------------------------------------
    local function findApplyTreatmentPP(npc, minigame)
        -- 1) ลองหาใน Minigame.Bed.InBed.PP ก่อน (structure ใหม่ของเกม)
        if minigame then
            local bed   = minigame:FindFirstChild("Bed")
            local inBed = bed and bed:FindFirstChild("InBed")
            if inBed then
                -- สแกนทุก PP ใน InBed (อาจมีหลายตัว)
                for _, desc in ipairs(inBed:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and getActionText(desc) == "Apply Treatment" then
                        return desc
                    end
                end
                -- หรือชื่อ child ตรงๆ
                local pp = inBed:FindFirstChild("PP")
                if pp and pp:IsA("ProximityPrompt") and getActionText(pp) == "Apply Treatment" then
                    return pp
                end
            end
            -- สแกนทั้ง Minigame เผื่อ path ต่างออกไป
            for _, desc in ipairs(minigame:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and getActionText(desc) == "Apply Treatment" then
                    return desc
                end
            end
        end
        -- 2) Fallback: PP บน NPC โดยตรง (เผื่อเกมเปลี่ยน structure)
        if npc then
            local npcPP = npc:FindFirstChild("PP")
            if npcPP and npcPP:IsA("ProximityPrompt") and getActionText(npcPP) == "Apply Treatment" then
                return npcPP
            end
        end
        return nil
    end

    -- Returns the next item name (from the TV report inv) that still needs to be
    -- fetched — skipping any entry already marked complete (checkmark visible) and
    -- picking items in their display order (LayoutOrder) so that when several items
    -- are requested (e.g. Herbs + Eye Drops) they get fetched one at a time, in order,
    -- instead of grabbing whichever child happens to be first in GetChildren().
    local function getNextNeededItem(tvInv)
        if not tvInv then return nil end
        local candidates = {}
        for _, child in ipairs(tvInv:GetChildren()) do
            if ItemPositions[child.Name] then
                local checkMark   = child:FindFirstChild("check")
                local alreadyDone = checkMark and checkMark.Visible == true
                if not alreadyDone then
                    table.insert(candidates, child)
                end
            end
        end
        if #candidates == 0 then return nil end
        table.sort(candidates, function(a, b)
            local la = (a:IsA("GuiObject") and a.LayoutOrder) or 0
            local lb = (b:IsA("GuiObject") and b.LayoutOrder) or 0
            if la ~= lb then return la < lb end
            return a.Name < b.Name
        end)
        return candidates[1].Name
    end

    -- *** FIX: ก่อนหน้านี้ถ้า applyPP หายไปแค่ 1 เฟรม (เช่น ตอนเกม refresh UI ของ
    -- Bed.InBed ชั่วคราว หรือ minigame ยังโหลดไม่เสร็จ) สคริปต์จะสรุปทันทีว่า
    -- "คนไข้ได้รับการรักษาแล้ว" ทั้งที่ยังไม่ได้เอายาให้คนไข้เลย ทำให้ notify หลอก
    -- ฟังก์ชันนี้เช็คซ้ำหลายครั้ง (พร้อม delay) ก่อนสรุปผลจริง ๆ เพื่อกัน false-alarm
    local function confirmApplyPPGone(npc, minigame)
        for i = 1, 4 do
            local pp = findApplyTreatmentPP(npc, minigame)
            if pp and pp.Parent and pp.Enabled then
                return false
            end
            task.wait(0.4)
        end
        return true
    end

    local function runTreatmentSequence(npc, room)
        if ProcessedTreatment[npc] then return end
        ProcessedTreatment[npc] = true

        -- treatmentApplied = true as soon as the "Apply Treatment" PP fires,
        -- whether triggered by this script or manually — signals this patient is done.
        local treatmentApplied = false
        local ppTriggeredConn  = nil
        -- Tracks retry attempts per item, so a repeatedly-rejected item doesn't loop forever.
        local itemAttempts     = {}
        -- Tracks retry attempts for the "Take DNA Sample" step (see STEP A fix below).
        local dnaAttempts      = 0

        -- Hook PP ที่ ActionText = "Apply Treatment" จาก Bed.InBed หรือ NPC
        local function hookApplyTreatmentPP(minigame)
            if ppTriggeredConn then return end
            local applyPP = findApplyTreatmentPP(npc, minigame)
            if applyPP then
                ppTriggeredConn = applyPP.Triggered:Connect(function()
                    treatmentApplied = true
                end)
            end
        end

        local roomReminderShown = false

        task.spawn(function()
            while npc and npc.Parent and room and room.Parent and settings.AutoTreat
                  and npc:GetAttribute("IsPatient") == true and not treatmentApplied do

                -- Re-fetch Minigame every loop in case it spawns late
                local minigame = room:FindFirstChild("Minigame")
                hookApplyTreatmentPP(minigame)

                if not playerInRoom(room) then
                    if not roomReminderShown then
                        roomReminderShown = true
                        WindUI:Notify({ Title="Auto Treating Patients", Content="Please go to "..room.Name.." to continue treatment.", Duration=3, Icon="alert-triangle" })
                    end
                    task.wait(1.5)
                else
                    roomReminderShown = false
                    local handled = false

                    -- STEP A: Take DNA Sample (PP บน NPC)
                    -- *** FIX: บั๊กที่บางครั้งกด PP นี้แล้วค้าง ไม่ไปขั้นต่อไป (ต้อง toggle
                    -- ปิด/เปิดถึงจะกลับมาทำงาน) เกิดจาก fireproximityprompt เงียบ ๆ ไม่ผ่าน
                    -- เพราะ PP บน NPC ตัวนี้ไม่ได้ bypass ระยะ/มุมมอง (LOS) เหมือน PP ตัวอื่น ๆ
                    -- ในสคริปต์ ถ้าผู้เล่นยืนไม่ตรง/ไกลไปนิดเดียว การกดจะไม่ติด แต่ ActionText
                    -- ยังคงเป็น "Take DNA Sample" เหมือนเดิม ทำให้วนกดซ้ำ ๆ ไปเรื่อย ๆ โดยไม่คืบหน้า
                    -- แก้โดย bypass MaxActivationDistance/RequiresLineOfSight ชั่วคราว และถ้ายิงซ้ำ
                    -- ติดกันหลายครั้งแล้วยังไม่ขยับ ให้เดินเข้าไปประชิด NPC ก่อนยิงอีกครั้ง (self-recover)
                    pcall(function()
                        local npcPP = npc:FindFirstChild("PP")
                        if npcPP and npcPP:IsA("ProximityPrompt") and getActionText(npcPP) == "Take DNA Sample" then
                            dnaAttempts = dnaAttempts + 1

                            if dnaAttempts % 5 == 0 and HumanoidRootPart then
                                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                                if npcRoot then
                                    HumanoidRootPart.CFrame = npcRoot.CFrame * CFrame.new(0, 0, 3)
                                    task.wait(0.2)
                                end
                            end

                            local oldDist = npcPP.MaxActivationDistance
                            local oldLOS  = npcPP.RequiresLineOfSight
                            npcPP.MaxActivationDistance = 9e9
                            npcPP.RequiresLineOfSight   = false

                            fireproximityprompt(npcPP)
                            handled = true

                            task.spawn(function()
                                task.wait(0.5)
                                pcall(function()
                                    npcPP.MaxActivationDistance = oldDist
                                    npcPP.RequiresLineOfSight   = oldLOS
                                end)
                            end)
                        else
                            dnaAttempts = 0
                        end
                    end)

                    -- STEP B: Analyzer
                    if not handled then
                        pcall(function()
                            local analyzerPP = minigame and minigame:FindFirstChild("Analyzer") and minigame.Analyzer:FindFirstChild("PP")
                            if analyzerPP and analyzerPP.Enabled == true then
                                fireproximityprompt(analyzerPP)
                                handled = true
                            end
                        end)
                    end

                    -- STEP C: Monitor
                    if not handled then
                        pcall(function()
                            local monitorPP2 = minigame and minigame:FindFirstChild("Monitor") and minigame.Monitor:FindFirstChild("PP2")
                            if monitorPP2 and monitorPP2.Enabled == true then
                                fireproximityprompt(monitorPP2)
                                handled = true
                            end
                        end)
                    end

                    -- STEP D: Apply Treatment (มองหา PP จาก Bed.InBed หรือ NPC)
                    if not handled then
                        local applyPP = findApplyTreatmentPP(npc, minigame)

                        if applyPP then
                            -- อ่านยาที่ต้องการจาก TV ในห้องนี้
                            local tvInv = minigame and minigame:FindFirstChild("TV")
                                and minigame.TV:FindFirstChild("Screen")
                                and minigame.TV.Screen:FindFirstChild("UI")
                                and minigame.TV.Screen.UI:FindFirstChild("Report")
                                and minigame.TV.Screen.UI.Report:FindFirstChild("inv")

                            local itemName = getNextNeededItem(tvInv)

                            if itemName and HumanoidRootPart then
                                local function isHoldingItem()
                                    local curChar = LocalPlayer.Character
                                    return hasTool(curChar, itemName) or hasTool(LocalPlayer.Backpack, itemName)
                                end

                                -- มียาแล้วหรือยัง?
                                if not isHoldingItem() then
                                    -- ตรวจสอบก่อนว่า applyPP ยังใช้งานได้ (คนไข้ยังอยู่)
                                    -- ถ้า PP หายไปแล้ว (คนไข้ได้รับยาจากคนอื่น / ออกจากห้อง) ให้หยุดทันที
                                    -- *** FIX: เช็คซ้ำหลายครั้ง (confirmApplyPPGone) ก่อนสรุปว่า
                                    -- "รักษาเสร็จแล้ว" กัน notify หลอก เพราะเดิม applyPP อาจหายไปแค่
                                    -- ชั่วคราว (เช่น Bed.InBed ยัง refresh ไม่เสร็จ) ทั้งที่ยังไม่ได้
                                    -- เอายาให้คนไข้เลย ***
                                    if (not applyPP or not applyPP.Parent or not applyPP.Enabled) and confirmApplyPPGone(npc, minigame) then
                                        -- คนไข้ได้รับการรักษาแล้วโดยคนอื่น หยุดลูปทันที
                                        treatmentApplied = true
                                        WindUI:Notify({ Title = "Auto Treating Patients", Content = "Patient already treated. Awaiting next patient.", Duration = 3, Icon = "check" })
                                    elseif not applyPP or not applyPP.Parent or not applyPP.Enabled then
                                        -- PP หายไปแค่ชั่วคราว (false alarm) ข้ามรอบนี้ไปเฉย ๆ แล้วลองใหม่รอบถัดไป
                                    else
                                        local originalCFrame = HumanoidRootPart.CFrame
                                        local targetPos       = ItemPositions[itemName]

                                        HumanoidRootPart.CFrame = CFrame.new(targetPos)
                                        task.wait(0.5)

                                        -- หา PP ของยาจาก World
                                        local matchedPrompt = nil
                                        do
                                            local searchRadius = 30
                                            local normItemName = normalizeString(itemName)
                                            local nearbyPPs    = {}

                                            for _, model in ipairs(Workspace:GetDescendants()) do
                                                if model:IsA("Model") then
                                                    local pp = model:FindFirstChild("PP")
                                                    if pp and pp:IsA("ProximityPrompt") then
                                                        local partPos = nil
                                                        if model.PrimaryPart then
                                                            partPos = model.PrimaryPart.Position
                                                        elseif pp.Parent and pp.Parent:IsA("BasePart") then
                                                            partPos = pp.Parent.Position
                                                        end
                                                        if partPos and (partPos - targetPos).Magnitude <= searchRadius then
                                                            table.insert(nearbyPPs, pp)
                                                        end
                                                    end
                                                end
                                            end

                                            for _, pp in ipairs(nearbyPPs) do
                                                if normalizeString(getActionText(pp)) == normItemName then
                                                    matchedPrompt = pp
                                                    break
                                                end
                                            end
                                        end

                                        if matchedPrompt then
                                            local oldDist = matchedPrompt.MaxActivationDistance
                                            local oldLOS  = matchedPrompt.RequiresLineOfSight
                                            pcall(function()
                                                matchedPrompt.MaxActivationDistance = 9e9
                                                matchedPrompt.RequiresLineOfSight   = false
                                            end)

                                            for attempt = 1, 10 do
                                                if isHoldingItem() then break end
                                                HumanoidRootPart.CFrame = CFrame.new(targetPos)
                                                fireproximityprompt(matchedPrompt)
                                                task.wait(0.3)
                                            end

                                            task.spawn(function()
                                                task.wait(0.5)
                                                pcall(function()
                                                    matchedPrompt.MaxActivationDistance = oldDist
                                                    matchedPrompt.RequiresLineOfSight   = oldLOS
                                                end)
                                            end)
                                        end

                                        -- เดินกลับก่อน จากนั้นค่อยตรวจซ้ำว่า applyPP ยังอยู่ไหม
                                        HumanoidRootPart.CFrame = originalCFrame
                                        task.wait(0.5)

                                        -- *** KEY FIX: ถ้า PP หายไประหว่างไปเก็บยา
                                        -- แสดงว่าคนไข้ได้รับการรักษาแล้ว — หยุดทันที อย่าไปกด PP อีก
                                        -- (เช็คซ้ำหลายครั้งด้วย confirmApplyPPGone ก่อนสรุป กัน notify
                                        -- หลอกตอน PP หายไปแค่ชั่วคราวระหว่างเดินไปเก็บยา) ***
                                        if (not applyPP or not applyPP.Parent or not applyPP.Enabled) and confirmApplyPPGone(npc, minigame) then
                                            treatmentApplied = true
                                            WindUI:Notify({ Title = "Auto Treating Patients", Content = "Patient already treated. Awaiting next patient.", Duration = 3, Icon = "check" })
                                        end
                                    end
                                end

                                -- Fire Apply Treatment only once holding the item, then VERIFY it
                                -- actually went through (item consumed or PP gone) before declaring
                                -- success. Previously this was assumed unconditionally, which — if
                                -- the wrong item was fetched — silently left the patient untreated
                                -- and stuck, needing the toggle switched off/on to recover.
                                if not treatmentApplied and isHoldingItem() then
                                    if applyPP and applyPP.Parent and applyPP.Enabled then
                                        itemAttempts[itemName] = (itemAttempts[itemName] or 0) + 1
                                        fireproximityprompt(applyPP)
                                        task.wait(0.5)

                                        local stillHolding = isHoldingItem()
                                        local ppGone        = (not applyPP.Parent) or (not applyPP.Enabled)

                                        if ppGone or not stillHolding then
                                            handled          = true
                                            treatmentApplied = true
                                            WindUI:Notify({ Title = "Auto Treating Patients", Content = "Patient treated. Awaiting next patient.", Duration = 3, Icon = "check" })
                                        elseif itemAttempts[itemName] >= 5 then
                                            -- Rejected repeatedly (likely wrong item) — stop retrying
                                            -- this one so the poller can move on instead of hanging.
                                            treatmentApplied = true
                                            WindUI:Notify({ Title = "Auto Treating Patients", Content = "Unable to apply treatment for this patient. Skipping.", Duration = 3, Icon = "alert-triangle" })
                                        end
                                    else
                                        -- PP หายไปแล้ว คนไข้ได้รับการรักษาไปแล้ว
                                        treatmentApplied = true
                                        WindUI:Notify({ Title = "Auto Treating Patients", Content = "Patient already treated. Awaiting next patient.", Duration = 3, Icon = "check" })
                                    end
                                end
                            end

                            task.wait(1.5)
                        end
                    end

                    task.wait(0.3)
                end
            end

            if ppTriggeredConn then
                ppTriggeredConn:Disconnect()
                ppTriggeredConn = nil
            end

            -- Notify เฉพาะถ้ายังไม่ได้ notify จาก Apply Treatment ข้างบน
            -- (กรณีที่ loop ออกเพราะ IsPatient = false แต่ไม่ได้กด Apply Treatment เอง)

            ProcessedTreatment[npc] = nil
        end)
    end

    task.spawn(function()
        while task.wait(1) do
            if settings.AutoTreat and Workspace:FindFirstChild("NPCs") then
                for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
                    if npc:GetAttribute("IsPatient") == true and not ProcessedTreatment[npc] then
                        local room = findPatientRoom(npc)
                        if room then runTreatmentSequence(npc, room) end
                    end
                end
            end
        end
    end)
end

-- FEATURE: Auto Coffee Machine
do
    MainTab:Paragraph({
        Title = "Info: Coffee Machine",
        Desc  = "Automatically brews and grabs coffee when the machine is ready.",
        Image = "coffee", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Coffee Machine",
        Desc     = "Automatically operates the coffee machine.",
        Value    = settings.AutoCoffee,
        Callback = function(v)
            settings.AutoCoffee = v
            Config:Set("AutoCoffee", v); Config:Save()
            WindUI:Notify({ Title="Auto Coffee", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "coffee" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(0.5) do
            if settings.AutoCoffee then
                pcall(function()
                    local coffeeMachine = Workspace:FindFirstChild("CoffeeMachine") or (Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("CoffeeMachine"))
                    if coffeeMachine then
                        local statusUI = coffeeMachine:FindFirstChild("Attachment") and coffeeMachine.Attachment:FindFirstChild("UI")
                        local statusLabel = statusUI and statusUI:FindFirstChild("status")
                        if statusLabel and string.find(statusLabel.Text:lower(), "ready") then
                            firePromptIn(coffeeMachine:FindFirstChild("Coffee"))
                        end
                    end
                end)
            end
        end
    end)
end

-- FEATURE: Auto Check-In (Normal Only)
do
    MainTab:Paragraph({
        Title = "Info: Check-In",
        Desc  = "Automatically checks in normal patients. Skips anomalies (Skinwalkers).",
        Image = "clipboard-check", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Check-In (Normal Only)",
        Desc     = "Automatically checks in normal patients at the front desk.",
        Value    = settings.AutoCheckIn,
        Callback = function(v)
            settings.AutoCheckIn = v
            Config:Set("AutoCheckIn", v); Config:Save()
            if not v then table.clear(ProcessedNPCs) end
            WindUI:Notify({ Title="Auto Check-In", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "clipboard-check" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(1) do
            if settings.AutoCheckIn then
                local activeNPC, activeDesk, bellPos = getActivePatientInfo()

                if activeNPC and activeDesk and bellPos and not ProcessedNPCs[activeNPC] then
                    local isSkinwalker = activeNPC:GetAttribute("Skinwalker")

                    if isSkinwalker == true then
                        ProcessedNPCs[activeNPC] = true
                    else
                        ProcessedNPCs[activeNPC] = true

                        task.spawn(function()
                            local mainCheckIn = Workspace.Misc:FindFirstChild("CheckIn")

                            if mainCheckIn then
                                while activeNPC and activeNPC.Parent and settings.AutoCheckIn do
                                    local root = activeNPC:FindFirstChild("HumanoidRootPart") or activeNPC.PrimaryPart
                                    if not root or (root.Position - bellPos).Magnitude > 5 then
                                        break
                                    end

                                    pcall(function()
                                        local form = activeDesk:FindFirstChild("Form")
                                        firePromptIn(form)
                                        task.wait(0.7)

                                        local camera = activeDesk:FindFirstChild("Camera")
                                        firePromptIn(camera)
                                        task.wait(0.7)

                                        local computer = mainCheckIn:FindFirstChild("Computer")
                                        firePromptIn(computer)
                                        task.wait(0.7)

                                        local printer = mainCheckIn:FindFirstChild("Printer")
                                        firePromptIn(printer)
                                        task.wait(0.7)

                                        local printedBadge = activeDesk:FindFirstChild("PrintedBadge")
                                        firePromptIn(printedBadge)
                                        task.wait(0.7)

                                        firePromptIn(activeNPC)
                                    end)

                                    task.wait(0.1)
                                end
                            end
                        end)
                    end
                end
            end
        end
    end)
end

-- FEATURE: Auto Clean Slime
do
    MainTab:Paragraph({
        Title = "Info: Clean Slime",
        Desc  = "Automatically cleans up slime spills.",
        Image = "droplet", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Clean Slime",
        Desc     = "Automatically cleans slime around the hospital.",
        Value    = settings.AutoSlime,
        Callback = function(v)
            settings.AutoSlime = v
            Config:Set("AutoSlime", v); Config:Save()
            WindUI:Notify({ Title="Auto Clean Slime", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "droplet" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(1) do
            if settings.AutoSlime then
                pcall(function()
                    local slime = Workspace:FindFirstChild("Slime") or (Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("Slime"))
                    if slime then firePromptIn(slime) end
                end)
            end
        end
    end)
end

-- FEATURE: Auto Extinguish Fire
do
    MainTab:Paragraph({
        Title = "Info: Extinguish Fire",
        Desc  = "Automatically extinguishes fires in rooms.",
        Image = "flame", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Extinguish Fire",
        Desc     = "Automatically finds and extinguishes fires.",
        Value    = settings.AutoFire,
        Callback = function(v)
            settings.AutoFire = v
            Config:Set("AutoFire", v); Config:Save()
            WindUI:Notify({ Title="Auto Extinguish Fire", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "flame" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(1) do
            if settings.AutoFire then
                pcall(function()
                    local rooms = Workspace:FindFirstChild("Rooms")
                    if rooms then
                        for _, desc in ipairs(rooms:GetDescendants()) do
                            if desc.Name == "Fire" then
                                for _, pp in ipairs(desc:GetDescendants()) do
                                    if pp.Name == "PP" or pp:IsA("ProximityPrompt") then
                                        fireproximityprompt(pp)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

-- FEATURE: Auto Taser Anomaly
do
    MainTab:Paragraph({
        Title = "Info: Taser Anomaly",
        Desc  = "Automatically grabs a taser and fires it at an active anomaly (Skinwalker).",
        Image = "zap", ImageSize = 30,
    })
    MainTab:Toggle({
        Title    = "Auto Taser Anomaly",
        Desc     = "Automatically tasers anomalies when detected.",
        Value    = settings.AutoTaser,
        Callback = function(v)
            settings.AutoTaser = v
            Config:Set("AutoTaser", v); Config:Save()
            WindUI:Notify({ Title="Auto Taser Anomaly", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "zap" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(0.5) do
            if settings.AutoTaser then
                pcall(function()
                    local hasSkinwalker = false
                    local targetNPC = nil

                    for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
                        if npc:GetAttribute("Skinwalker") == true then
                            hasSkinwalker = true
                            targetNPC = npc
                            break
                        end
                    end

                    if hasSkinwalker and targetNPC then
                        local char = LocalPlayer.Character
                        local backpack = LocalPlayer:FindFirstChild("Backpack")

                        local hasTaser = false
                        if backpack and backpack:FindFirstChild("Taser") then hasTaser = true end
                        if char and char:FindFirstChild("Taser") then hasTaser = true end

                        if not hasTaser then
                            local taserStation = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("TaserStation")
                            local mainPart = taserStation and taserStation:FindFirstChild("Main")

                            if mainPart then
                                local statusUI = mainPart:FindFirstChild("Attachment") and mainPart.Attachment:FindFirstChild("UI")
                                local statusLabel = statusUI and statusUI:FindFirstChild("status")

                                if statusLabel and statusLabel.Text and string.find(string.lower(statusLabel.Text), "ready") then
                                    local taserPrompt = mainPart:FindFirstChild("PP")

                                    if taserPrompt and taserPrompt:IsA("ProximityPrompt") then
                                        local oldDist = taserPrompt.MaxActivationDistance
                                        local oldLOS = taserPrompt.RequiresLineOfSight

                                        taserPrompt.MaxActivationDistance = 9e9
                                        taserPrompt.RequiresLineOfSight = false

                                        fireproximityprompt(taserPrompt)

                                        task.spawn(function()
                                            task.wait(0.5)
                                            taserPrompt.MaxActivationDistance = oldDist
                                            taserPrompt.RequiresLineOfSight = oldLOS
                                        end)

                                        task.wait(0.8)
                                    end
                                end
                            end
                        end

                        local hasTaserNow = false
                        if backpack and backpack:FindFirstChild("Taser") then hasTaserNow = true end
                        if char and char:FindFirstChild("Taser") then hasTaserNow = true end

                        if hasTaserNow then
                            local args = { targetNPC }
                            ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net"):WaitForChild("RE/TaserFired"):FireServer(unpack(args))
                            task.wait(1)
                        end
                    end
                end)
            end
        end
    end)
end

-- ====================== ESP TAB ======================
EspTab:Divider()
EspTab:Section({ Title = "NPC Detection", Icon = "eye" })

do
    EspTab:Paragraph({
        Title = "Info: ESP Anomaly",
        Desc  = "Highlights all NPCs and tags whether they are a normal patient or an anomaly (Skinwalker).",
        Image = "eye", ImageSize = 30,
    })
    EspTab:Toggle({
        Title    = "ESP Patients (NPC)",
        Desc     = "Shows highlight and tag on all NPCs.",
        Value    = settings.EspEnabled,
        Callback = function(v)
            settings.EspEnabled = v
            Config:Set("EspEnabled", v); Config:Save()
            if not v and Workspace:FindFirstChild("NPCs") then
                for _, npc in ipairs(Workspace.NPCs:GetChildren()) do
                    if npc:FindFirstChild("AnomalyHighlight") then npc.AnomalyHighlight:Destroy() end
                    if npc:FindFirstChild("AnomalyTag") then npc.AnomalyTag:Destroy() end
                end
            end
            WindUI:Notify({ Title="NPC ESP", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "eye" or "eye-off" })
        end
    })

    local function applyESP(npc)
        if not settings.EspEnabled then return end
        local isSkinwalker = npc:GetAttribute("Skinwalker")
        local color = isSkinwalker == true and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

        local highlight = npc:FindFirstChild("AnomalyHighlight") or Instance.new("Highlight", npc)
        highlight.Name, highlight.FillColor, highlight.FillTransparency, highlight.OutlineColor, highlight.OutlineTransparency, highlight.Enabled = "AnomalyHighlight", color, 0.5, color, 0, true

        local root = npc:FindFirstChild("HumanoidRootPart")
        if root then
            local tag = npc:FindFirstChild("AnomalyTag") or Instance.new("BillboardGui", npc)
            tag.Name, tag.Size, tag.AlwaysOnTop, tag.StudsOffset = "AnomalyTag", UDim2.new(0, 200, 0, 50), true, Vector3.new(0, 3, 0)
            local label = tag:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel", tag)
            label.Size, label.BackgroundTransparency, label.Font, label.TextSize = UDim2.new(1, 0, 1, 0), 1, Enum.Font.GothamBold, 14

            tag.Enabled = true
            label.Text = npc.Name .. "\n" .. (isSkinwalker == true and "[ANOMALY]" or "[NORMAL]")
            label.TextColor3 = color
        end
    end
    task.spawn(function()
        while task.wait(1) do
            if settings.EspEnabled and Workspace:FindFirstChild("NPCs") then
                for _, npc in ipairs(Workspace.NPCs:GetChildren()) do pcall(applyESP, npc) end
            end
        end
    end)
end

-- ====================== COLLECT TAB ======================
TeleportTab:Divider()
TeleportTab:Section({ Title = "Auto Collect", Icon = "package" })

do
    TeleportTab:Paragraph({
        Title = "Info: Collect Medicine (Room 8)",
        Desc  = "Reads the TV checklist in Room 8 and grabs only the medicine items still needed.",
        Image = "package", ImageSize = 30,
    })
    TeleportTab:Toggle({
        Title    = "Auto Collect Medicine",
        Desc     = "Automatically grabs required medicine based on the Room 8 checklist.",
        Value    = settings.AutoMedicine,
        Callback = function(v)
            settings.AutoMedicine = v
            Config:Set("AutoMedicine", v); Config:Save()
            WindUI:Notify({ Title="Auto Collect Medicine", Content=v and "Enabled" or "Disabled", Duration=3, Icon=v and "package" or "ban" })
        end
    })
    task.spawn(function()
        while task.wait(0.5) do
            if settings.AutoMedicine then
                pcall(function()
                    local rooms = Workspace:FindFirstChild("Rooms")
                    if not rooms then return end
                    local emergency = rooms:FindFirstChild("Emergency")
                    if not emergency then return end
                    local room8 = emergency:FindFirstChild("Room8")
                    if not room8 then return end
                    local minigame = room8:FindFirstChild("Minigame")
                    if not minigame then return end

                    local tv = minigame:FindFirstChild("TV")
                    local medicineFolder = minigame:FindFirstChild("Medicine")
                    if not tv or not medicineFolder then return end

                    local itemsNeeded = {}

                    for _, desc in ipairs(tv:GetDescendants()) do
                        if desc.Name == "inv" then
                            for _, uiItem in ipairs(desc:GetChildren()) do
                                if uiItem:IsA("GuiObject") and not uiItem:IsA("UIListLayout") and not uiItem:IsA("UIPadding") and not uiItem:IsA("UICorner") then
                                    local checkMark = uiItem:FindFirstChild("check")
                                    if checkMark and checkMark.Visible == true then
                                        -- already checked off, skip
                                    else
                                        itemsNeeded[uiItem.Name] = true
                                    end
                                end
                            end
                        end
                    end

                    local grabbedSomething = false

                    for itemName, _ in pairs(itemsNeeded) do
                        local normItemName = normalizeString(itemName)
                        local char = LocalPlayer.Character

                        if not hasTool(LocalPlayer.Backpack, itemName) and not hasTool(char, itemName) then
                            for _, desc in ipairs(medicineFolder:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    local parentName = desc.Parent and desc.Parent.Name or ""
                                    if normalizeString(parentName) == normItemName or normalizeString(desc.ObjectText) == normItemName then

                                        local oldDist = desc.MaxActivationDistance
                                        local oldLOS = desc.RequiresLineOfSight

                                        desc.MaxActivationDistance = 9e9
                                        desc.RequiresLineOfSight = false

                                        fireproximityprompt(desc)

                                        task.spawn(function()
                                            task.wait(0.5)
                                            desc.MaxActivationDistance = oldDist
                                            desc.RequiresLineOfSight = oldLOS
                                        end)

                                        grabbedSomething = true
                                        task.wait(0.3)
                                        break
                                    end
                                end
                            end
                        end
                    end

                    if grabbedSomething then
                        task.wait(5)
                    end
                end)
            end
        end
    end)
end

-- ====================== INFO TAB ======================
local Info = InfoTab
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

Info:Section({ Title = "Latest Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({
    Title = "Update: 07/10/2026 | CL: " .. ver,
    Desc  = [[• [Fixed] Taking DNA Sample gets stuck and doesn't proceed to the next step (requires toggle to turn on/off) 
• [ Added ] Auto Treating Patients (DNA Sample → Analyzer → Monitor → Fetch Item → Apply Treatment, multi-room)]],
})
Info:Divider()

-- ====================== SETTINGS TAB ======================
do
Main3:Divider()
Main3:Section({Title="Save Config",Icon="save"})
Main3:Button({Title="Save Config (NOW)", Desc = "Saves all current settings immediately.",Callback=function()
    Config:Save(); WindUI:Notify({Title="Config Saved",Content="Config saved successfully!",Duration=2,Icon="save"})
end})
Main3:Toggle({Title="Auto Save Config", Desc = "Automatically saves config at set interval.",Value=settings.AutoSaveEnabled,Callback=function(state)
    settings.AutoSaveEnabled=state; Config:Set("AutoSaveEnabled",state); Config:Save()
    if state then Config:AutoSave(settings.AutoSaveDelay) else Config:AutoSave(0) end
end})
Main3:Input({Title="Delay Save Config",Value=tostring(settings.AutoSaveDelay),Placeholder="Default: 15",Callback=function(text)
    local num=tonumber(text)
    if num and num>=1 then
        settings.AutoSaveDelay=num; Config:Set("AutoSaveDelay",num); Config:Save()
        if settings.AutoSaveEnabled then Config:AutoSave(num) end
    else warn("[DYHUB] Invalid delay value!") end
end})

Main3:Section({Title="Server Status",Icon="server"})
Main3:Button({Title="Serverhop", Desc = "Teleports you to a different random server.",Callback=function()
    local servers={}
    local success,result=pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
    end)
    if success and result and result.data then
        for _,server in ipairs(result.data) do
            if server.id~=game.JobId and server.playing<server.maxPlayers then table.insert(servers,server.id) end
        end
    end
    if #servers>0 then
        WindUI:Notify({Title="Serverhop",Content="Teleporting...",Duration=2,Icon="server"}); task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId,servers[math.random(1,#servers)],LocalPlayer)
    else WindUI:Notify({Title="Serverhop Failed",Content="No available servers.",Duration=3,Icon="alert-triangle"}) end
end})
Main3:Button({Title="Rejoin", Desc = "Rejoins the current game server.",Callback=function()
    WindUI:Notify({Title="Rejoin",Content="Rejoining...",Duration=2,Icon="refresh-cw"}); task.wait(1)
    TeleportService:Teleport(game.PlaceId,LocalPlayer)
end})
end -- SETTINGS TAB do-scope

-- ====================== INFORMATION TAB (Discord + Owner) ======================
do
ui.Creator.Request=function(requestData)
    local success,result=pcall(function()
        if HttpService.RequestAsync then
            local response=HttpService:RequestAsync({Url=requestData.Url,Method=requestData.Method or "GET",Headers=requestData.Headers or {}})
            return {Body=response.Body,StatusCode=response.StatusCode,Success=response.Success}
        else local body=HttpService:GetAsync(requestData.Url); return {Body=body,StatusCode=200,Success=true} end
    end)
    if success then return result else error("HTTP Request failed: "..tostring(result)) end
end

local InviteCode="jWNDPNMmyB"
local DiscordAPI="https://discord.com/api/v10/invites/"..InviteCode.."?with_counts=true&with_expiration=true"
local function LoadDiscordInfo()
    local success,result=pcall(function()
        return HttpService:JSONDecode(ui.Creator.Request({Url=DiscordAPI,Method="GET",Headers={["User-Agent"]="RobloxBot/1.0",["Accept"]="application/json"}}).Body)
    end)
    if success and result and result.guild then
        local DiscordInfo=Info:Paragraph({
            Title=result.guild.name,
            Desc=' <font color="#52525b">●</font> Member Count : '..tostring(result.approximate_member_count)..'\n <font color="#16a34a">●</font> Online Count : '..tostring(result.approximate_presence_count),
            Image="https://cdn.discordapp.com/icons/"..result.guild.id.."/"..result.guild.icon..".png?size=1024",ImageSize=42,
        })
        Info:Button({Title="Update Info",Callback=function()
            local ok,r=pcall(function() return HttpService:JSONDecode(ui.Creator.Request({Url=DiscordAPI,Method="GET"}).Body) end)
            if ok and r and r.guild then
                DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : '..tostring(r.approximate_member_count)..'\n <font color="#16a34a">●</font> Online Count : '..tostring(r.approximate_presence_count))
                WindUI:Notify({Title="Discord Info Updated",Content="Refreshed!",Duration=2,Icon="refresh-cw"})
            else WindUI:Notify({Title="Update Failed",Content="Could not refresh.",Duration=3,Icon="alert-triangle"}) end
        end})
        Info:Button({Title="Copy Discord Invite",Callback=function()
            setclipboard("https://discord.gg/"..InviteCode); WindUI:Notify({Title="Copied!",Content="Discord invite copied!",Duration=2,Icon="clipboard-check"})
        end})
    else Info:Paragraph({Title="Error fetching Discord Info",Desc="Unable to load.",Image="triangle-alert",ImageSize=26,Color="Red"}) end
end
LoadDiscordInfo()

Info:Divider()
Info:Section({Title="DYHUB Information",TextXAlignment="Center",TextSize=17})
Info:Divider()
Info:Paragraph({Title="Main Owner",Desc="@dyumraisgoodguy#8888",Image="rbxassetid://119789418015420",ImageSize=30})
Info:Paragraph({Title="Social",Desc="Copy link social media for follow!",Image="rbxassetid://104487529937663",ImageSize=30,
    Buttons={{Icon="copy",Title="Copy Link",Callback=function() setclipboard("https://guns.lol/DYHUB") end}}})
Info:Paragraph({Title="Discord",Desc="Join our discord for more scripts!",Image="rbxassetid://104487529937663",ImageSize=30,
    Buttons={{Icon="copy",Title="Copy Link",Callback=function() setclipboard("https://discord.gg/jWNDPNMmyB") end}}})
end -- INFORMATION TAB do-scope

print("[DYHUB] Game: Animal Hospital "..version.." | "..ver.." loaded successfully!")
print("[DYHUB] Config active | Auto saving every "..tostring(settings.AutoSaveDelay).."s")
