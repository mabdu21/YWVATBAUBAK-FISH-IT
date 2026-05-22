-- Powered by dyumra | v341 (Reworked)
-- =========================
local version = "Rework"
local ver     = "v013.6"
-- =========================

repeat task.wait() until game:IsLoaded()

-- ====================== LOAD UI ======================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- FPS Unlock
if setfpscap then
    setfpscap(1000000)
    WindUI:Notify({ Title = "Service", Content = "FPS Unlocked! | " .. ver, Duration = 3, Icon = "cpu" })
    warn("FPS Unlocked!")
else
    WindUI:Notify({ Title = "Not Working", Content = "Your exploit does not support setfpscap.", Duration = 3, Icon = "ban" })
end

-- ====================== SERVICES (CACHED) ======================
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local StarterGui        = game:GetService("StarterGui")
local TeleportService   = game:GetService("TeleportService")
local VirtualUser       = game:GetService("VirtualUser")

local LocalPlayer      = Players.LocalPlayer
local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")
local Camera           = Workspace.CurrentCamera

-- ====================== CHARACTER CACHE (รองรับ Respawn) ======================
local Character         = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid          = Character:WaitForChild("Humanoid")
local HumanoidRootPart  = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character      = char
    Humanoid       = char:WaitForChild("Humanoid")
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
    local premiumData = func()
    return premiumData and premiumData[playerName] and PremiumVersion or FreeVersion
end

local userversion = checkVersion(LocalPlayer.Name)

-- ====================== WINDOW ======================
local Window = WindUI:CreateWindow({
    Title      = "DYHUB",
    IconThemed = true,
    Icon       = "rbxassetid://104487529937663",
    Author     = "Violence District | " .. userversion,
    Folder     = "DYHUB_VD",
    Size       = UDim2.fromOffset(500, 400),
    Transparent = true,
    Theme      = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar  = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.K)

pcall(function()
    Window:Tag({ Title = version, Color = Color3.fromHex("#db7093") })
end)

Window:EditOpenButton({
    Title          = "DYHUB - Open",
    Icon           = "monitor",
    CornerRadius   = UDim.new(0, 6),
    StrokeThickness = 2,
    Color          = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 255, 255)),
    Draggable      = true,
})

-- ====================== CONFIG SYSTEM ======================
local ConfigFolder = "DYHUB_VD"

local CustomConfig = {}
CustomConfig.__index = CustomConfig

function CustomConfig.new()
    local self = setmetatable({}, CustomConfig)
    self.ConfigData = {}
    self.ConfigPath = ConfigFolder .. "/config.json"
    self._autoSaveThread = nil
    self._autoSaveDelay  = 15
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    self:Load()
    return self
end

function CustomConfig:Set(key, value)
    self.ConfigData[key] = value
end

function CustomConfig:Get(key, default)
    local v = self.ConfigData[key]
    if v ~= nil then return v end
    return default
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

-- ====================== TABS ======================
local InfoTab     = Window:Tab({ Title = "Information", Icon = "info" })
local _D1         = Window:Divider()
local SurTab      = Window:Tab({ Title = "Survivor",    Icon = "user-check" })
local killerTab   = Window:Tab({ Title = "Killer",      Icon = "swords" })
local _D2         = Window:Divider()
local MainTab     = Window:Tab({ Title = "Main",        Icon = "rocket" })
local EspTab      = Window:Tab({ Title = "Esp",         Icon = "eye" })
local PlayerTab   = Window:Tab({ Title = "Player",      Icon = "user" })
local TeleportTab = Window:Tab({ Title = "Teleport",    Icon = "map-pin" })
local _D3         = Window:Divider()
local Main3       = Window:Tab({ Title = "Settings",    Icon = "settings" })

Window:SelectTab(1)

-- =====================================================================================
--  ESP SYSTEM  (รองรับ Respawn / Map Reload / Spawn ใหม่ / ไม่ Leak)
-- =====================================================================================

-- ── สี ──
local COLOR_SURVIVOR       = Color3.fromRGB(0,   0,   255)
local COLOR_MURDERER       = Color3.fromRGB(255,  0,    0)
local COLOR_GENERATOR_DONE = Color3.fromRGB(0,   255,   0)
local COLOR_GATE           = Color3.fromRGB(255, 255,  255)
local COLOR_PALLET         = Color3.fromRGB(255, 255,   0)
local COLOR_OUTLINE        = Color3.fromRGB(0,     0,   0)
local COLOR_WINDOW         = Color3.fromRGB(175, 215,  230)
local COLOR_HOOK           = Color3.fromRGB(255,   0,   0)
local COLOR_PATIENT        = Color3.fromRGB(255, 165,   0)

-- ── State ──
local espEnabled       = Config:Get("espEnabled",       false)
local espSurvivor      = Config:Get("espSurvivor",      false)
local espMurder        = Config:Get("espMurder",        false)
local espGenerator     = Config:Get("espGenerator",     false)
local espGate          = Config:Get("espGate",          false)
local espHook          = Config:Get("espHook",          false)
local espPallet        = Config:Get("espPallet",        false)
local espWindowEnabled = Config:Get("espWindow",        false)
local espPatient       = Config:Get("espPatient",       false)
local ShowName         = Config:Get("ShowName",         true)
local ShowDistance     = Config:Get("ShowDistance",     true)
local ShowHP           = Config:Get("ShowHP",           true)
local ShowHighlight    = Config:Get("ShowHighlight",    true)
local ShowPercent      = Config:Get("ShowPercent",      true)
local ESP_MAX_DISTANCE = Config:Get("ESP_MAX_DISTANCE", 1500) 

-- ── Table เก็บ ESP ทั้งหมด ──
-- key = Instance (char / model)
-- value = { highlight, bill, nameLabel, hpLabel, distLabel, color }
local espObjects = {}

-- ── Generator Cache ──
local _cachedGenFolders  = nil
local _cacheInvalidTimer = 0

local function _invalidateGenCache()
    _cachedGenFolders = nil
end

-- Invalidate เมื่อมี descendant เพิ่ม/ลบ (batch; ไม่ใช้ Connect แบบหนัก)
Workspace.DescendantAdded:Connect(_invalidateGenCache)
Workspace.DescendantRemoving:Connect(_invalidateGenCache)

local function getFolderGenerator()
    if _cachedGenFolders then return _cachedGenFolders end
    local list = {}
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "Generator" and desc:IsA("Model") then
            table.insert(list, desc)
        end
    end
    _cachedGenFolders = list
    return list
end

-- ── ลบ ESP ของ object นั้น ──
local function removeESP(obj)
    local data = espObjects[obj]
    if not data then return end
    pcall(function() if data.highlight then data.highlight:Destroy() end end)
    pcall(function() if data.bill      then data.bill:Destroy()      end end)
    espObjects[obj] = nil
end

-- ── สร้าง / อัปเดต ESP ──
local function createESP(obj, baseColor)
    if not obj or not obj.Parent then return end
    if obj.Name == "Lobby" then return end

    -- ถ้ามีอยู่แล้ว → อัปเดตสีเท่านั้น ไม่สร้างซ้ำ
    local data = espObjects[obj]
    if data then
        if data.highlight then
            data.highlight.FillColor    = baseColor
            data.highlight.OutlineColor = baseColor
            data.highlight.Enabled      = ShowHighlight
        end
        data.nameLabel.TextColor3 = baseColor
        data.hpLabel.TextColor3   = baseColor
        data.distLabel.TextColor3 = baseColor
        data.color = baseColor
        return
    end

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Adornee             = obj
    highlight.FillColor           = baseColor
    highlight.FillTransparency    = 0.8
    highlight.OutlineColor        = baseColor
    highlight.OutlineTransparency = 0.1
    highlight.Enabled             = ShowHighlight
    highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    pcall(function() highlight.Parent = obj end)

    -- BillboardGui
    local bill = Instance.new("BillboardGui")
    bill.Size        = UDim2.new(0, 200, 0, 50)
    bill.Adornee     = obj
    bill.AlwaysOnTop = true
    pcall(function() bill.Parent = obj end)

    local frame = Instance.new("Frame")
    frame.Size                   = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent                 = bill

    local function makeLabel(ypos)
        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, 0, 0.33, 0)
        lbl.Position               = UDim2.new(0, 0, ypos, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font                   = Enum.Font.SourceSansBold
        lbl.TextSize               = 14
        lbl.TextColor3             = baseColor
        lbl.TextStrokeColor3       = COLOR_OUTLINE
        lbl.TextStrokeTransparency = 0
        lbl.Text                   = ""
        lbl.Parent                 = frame
        return lbl
    end

    local nameLabel = makeLabel(0)
    nameLabel.Text  = obj.Name
    local hpLabel   = makeLabel(0.33)
    local distLabel = makeLabel(0.66)

    espObjects[obj] = {
        highlight = highlight,
        bill      = bill,
        nameLabel = nameLabel,
        hpLabel   = hpLabel,
        distLabel = distLabel,
        color     = baseColor,
    }
end

-- ── Generator progress helpers ──
local function getGeneratorProgress(gen)
    local progress = 0
    if gen:GetAttribute("Progress") then
        progress = gen:GetAttribute("Progress")
    elseif gen:GetAttribute("RepairProgress") then
        progress = gen:GetAttribute("RepairProgress")
    else
        for _, child in ipairs(gen:GetDescendants()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local n = child.Name:lower()
                if n:find("progress") or n:find("repair") or n:find("percent") then
                    progress = child.Value; break
                end
            end
        end
    end
    progress = (progress > 1) and progress / 100 or progress
    return math.clamp(progress, 0, 1)
end

local function getProgressColor(p)
    if p < 0.5 then
        local t = p / 0.5
        return Color3.fromRGB(math.floor(255 - (255-153)*t), 255, math.floor(255 - (255-153)*t))
    else
        local t = (p - 0.5) / 0.5
        return Color3.fromRGB(math.floor(153*(1-t)), 255, math.floor(153*(1-t)))
    end
end

local function generatorFinished(gen)
    return getGeneratorProgress(gen) >= 0.99
        or gen:FindFirstChild("Finished") ~= nil
        or gen:FindFirstChild("Repaired") ~= nil
end

-- ── Main ESP Update (ทุก ESP_INTERVAL วิ) ──
local _espAccum    = 0
local ESP_INTERVAL = 0.5   -- วินาที; ปรับได้

local function updateESP()
    if not espEnabled then return end

    -- ดึง HRP ของตัวเอง (รองรับ respawn)
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- ─── Players ESP ───────────────────────────────────────────
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
    
        local pChar = player.Character
        if not pChar or pChar.Name == "Lobby" then continue end
    
        local pRoot = pChar:FindFirstChild("HumanoidRootPart")
        local dist = pRoot and math.floor((hrp.Position - pRoot.Position).Magnitude) or math.huge
    
        -- ถ้าไกลเกินระยะ ESP
        if dist > ESP_MAX_DISTANCE then
            local data = espObjects[pChar]
    
            if data then
                if data.bill then
                    data.bill.Enabled = false
                end
    
                if data.highlight then
                    data.highlight.Enabled = false
                end
            end
    
            continue
        end
    
        local isMurderer = pChar:FindFirstChild("Weapon") ~= nil
    
        if isMurderer then
            if espMurder then
                createESP(pChar, COLOR_MURDERER)
            else
                removeESP(pChar)
            end
        else
            if espSurvivor then
                createESP(pChar, COLOR_SURVIVOR)
            else
                removeESP(pChar)
            end
        end
    end

    -- ─── World Objects ESP ─────────────────────────────────────
    local scanned = {}

    for _, desc in ipairs(Workspace:GetDescendants()) do
        if not desc:IsA("Model") or scanned[desc] then continue end

        local n    = desc.Name
        local part = desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart")
        local dist = part and math.floor((hrp.Position - part.Position).Magnitude) or math.huge

        -- ── Generator ──
        if n == "Generator" then
            scanned[desc] = true
            if espGenerator then
                -- Distance check
                if dist > ESP_MAX_DISTANCE then
                    local data = espObjects[desc]
                    if data then
                        if data.bill      then data.bill.Enabled      = false end
                        if data.highlight then data.highlight.Enabled = false end
                    end
                    continue
                end
                local progress   = getGeneratorProgress(desc)
                local isFinished = generatorFinished(desc)
                local col        = isFinished and COLOR_GENERATOR_DONE or getProgressColor(progress)
                createESP(desc, col)
                local data = espObjects[desc]
                if data and part then
                    -- Name + Percent
                    if ShowName and ShowPercent then
                        data.nameLabel.Text    = n .. " | " .. math.floor(progress * 100) .. "%"
                        data.nameLabel.Visible = true
                    elseif ShowName then
                        data.nameLabel.Text    = n
                        data.nameLabel.Visible = true
                    else
                        data.nameLabel.Visible = false
                    end
                    data.distLabel.Text    = ShowDistance and ("[ " .. dist .. " MM ]") or ""
                    data.distLabel.Visible = ShowDistance
                    data.hpLabel.Visible   = false
                    data.nameLabel.TextColor3 = col
                    data.distLabel.TextColor3 = col
                    -- bill visible
                    if data.bill      then data.bill.Enabled      = true end
                    if data.highlight then data.highlight.Enabled = ShowHighlight end
                end
            else
                removeESP(desc)
            end

        -- ── Gate ──
        elseif n == "Gate" then
            scanned[desc] = true
            if espGate then
                if dist <= ESP_MAX_DISTANCE then
                    createESP(desc, COLOR_GATE)
                    local data = espObjects[desc]
                    if data then
                        data.nameLabel.Text    = ShowName and "Gate" or ""
                        data.nameLabel.Visible = ShowName
                        data.distLabel.Text    = ShowDistance and ("[ " .. dist .. " MM ]") or ""
                        data.distLabel.Visible = ShowDistance
                        data.hpLabel.Visible   = false
                        data.nameLabel.TextColor3 = COLOR_GATE
                        data.distLabel.TextColor3 = COLOR_GATE
                        if data.bill      then data.bill.Enabled      = true end
                        if data.highlight then data.highlight.Enabled = ShowHighlight end
                    end
                else
                    local data = espObjects[desc]
                    if data then
                        if data.bill      then data.bill.Enabled      = false end
                        if data.highlight then data.highlight.Enabled = false end
                    end
                end
            else
                removeESP(desc)
            end

        -- ── Hook ──
        elseif n == "Hook" then
            scanned[desc] = true
            local mdl = desc:FindFirstChild("Model")
            if mdl then
                local mdlPart = mdl.PrimaryPart or mdl:FindFirstChildWhichIsA("BasePart")
                local mdlDist = mdlPart and math.floor((hrp.Position - mdlPart.Position).Magnitude) or math.huge
                if espHook then
                    if mdlDist <= ESP_MAX_DISTANCE then
                        createESP(mdl, COLOR_HOOK)
                        local data = espObjects[mdl]
                        if data then
                            data.nameLabel.Text    = ShowName and "Hook" or ""
                            data.nameLabel.Visible = ShowName
                            data.distLabel.Text    = ShowDistance and ("[ " .. mdlDist .. " MM ]") or ""
                            data.distLabel.Visible = ShowDistance
                            data.hpLabel.Visible   = false
                            data.nameLabel.TextColor3 = COLOR_HOOK
                            data.distLabel.TextColor3 = COLOR_HOOK
                            if data.bill      then data.bill.Enabled      = true end
                            if data.highlight then data.highlight.Enabled = ShowHighlight end
                        end
                    else
                        local data = espObjects[mdl]
                        if data then
                            if data.bill      then data.bill.Enabled      = false end
                            if data.highlight then data.highlight.Enabled = false end
                        end
                    end
                else
                    removeESP(mdl)
                end
            end

        -- ── Pallet ──
        elseif n == "Palletwrong" then
            scanned[desc] = true
            if espPallet then
                if dist <= ESP_MAX_DISTANCE then
                    createESP(desc, COLOR_PALLET)
                    local data = espObjects[desc]
                    if data then
                        data.nameLabel.Text    = ShowName and "Pallet" or ""
                        data.nameLabel.Visible = ShowName
                        data.distLabel.Text    = ShowDistance and ("[ " .. dist .. " MM ]") or ""
                        data.distLabel.Visible = ShowDistance
                        data.hpLabel.Visible   = false
                        data.nameLabel.TextColor3 = COLOR_PALLET
                        data.distLabel.TextColor3 = COLOR_PALLET
                        if data.bill      then data.bill.Enabled      = true end
                        if data.highlight then data.highlight.Enabled = ShowHighlight end
                    end
                else
                    local data = espObjects[desc]
                    if data then
                        if data.bill      then data.bill.Enabled      = false end
                        if data.highlight then data.highlight.Enabled = false end
                    end
                end
            else
                removeESP(desc)
            end

        -- ── Window ──
        elseif n == "Window" then
            scanned[desc] = true
            if espWindowEnabled then
                if dist <= ESP_MAX_DISTANCE then
                    createESP(desc, COLOR_WINDOW)
                    local data = espObjects[desc]
                    if data then
                        data.nameLabel.Text    = ShowName and "Window" or ""
                        data.nameLabel.Visible = ShowName
                        data.distLabel.Text    = ShowDistance and ("[ " .. dist .. " MM ]") or ""
                        data.distLabel.Visible = ShowDistance
                        data.hpLabel.Visible   = false
                        data.nameLabel.TextColor3 = COLOR_WINDOW
                        data.distLabel.TextColor3 = COLOR_WINDOW
                        if data.bill      then data.bill.Enabled      = true end
                        if data.highlight then data.highlight.Enabled = ShowHighlight end
                    end
                else
                    local data = espObjects[desc]
                    if data then
                        if data.bill      then data.bill.Enabled      = false end
                        if data.highlight then data.highlight.Enabled = false end
                    end
                end
            else
                removeESP(desc)
            end
        end

        -- ── Patient (SCP / scp###) ──
        -- ตรวจแยกต่างหากหลัง block ด้านบน
        if not scanned[desc] and n:match("^[Ss][Cc][Pp]%d*$") then
            scanned[desc] = true
            if espPatient then
                if dist <= ESP_MAX_DISTANCE then
                    createESP(desc, COLOR_PATIENT)
                    local data = espObjects[desc]
                    if data and part then
                        data.nameLabel.Text       = ShowName and "Patient" or ""
                        data.nameLabel.Visible    = ShowName
                        data.nameLabel.TextColor3 = COLOR_PATIENT
                        data.distLabel.Text       = ShowDistance and ("[ " .. dist .. " MM ]") or ""
                        data.distLabel.Visible    = ShowDistance
                        data.distLabel.TextColor3 = COLOR_PATIENT
                        data.hpLabel.Visible      = false
                        if data.bill      then data.bill.Enabled      = true end
                        if data.highlight then data.highlight.Enabled = ShowHighlight end
                    end
                else
                    local data = espObjects[desc]
                    if data then
                        if data.bill      then data.bill.Enabled      = false end
                        if data.highlight then data.highlight.Enabled = false end
                    end
                end
            else
                removeESP(desc)
            end
        end
    end

    -- ─── Update labels สำหรับ Player ESP ─────────────────────
    for obj, data in pairs(espObjects) do
        if not obj or not obj.Parent then
            removeESP(obj); continue
        end
        if obj.Name == "Lobby" then continue end

        local oPart    = obj:FindFirstChild("HumanoidRootPart")
                      or obj.PrimaryPart
                      or obj:FindFirstChildWhichIsA("BasePart")
        if not oPart then continue end

        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        local isPlayer = humanoid ~= nil

        -- Player ESP → ไม่ใช้ distance gate (ผู้เล่นมองเห็นได้ตลอด)
        if isPlayer then
            local oDist = math.floor((hrp.Position - oPart.Position).Magnitude)
        
            -- ถ้าไกลเกินระยะ ESP
            if oDist > ESP_MAX_DISTANCE then
                if data.highlight then
                    data.highlight.Enabled = false
                end
        
                if data.bill then
                    data.bill.Enabled = false
                end
        
                continue
            end

            if ShowHP and humanoid then
                data.hpLabel.Text     = "[ " .. math.floor(humanoid.Health) .. " HP ]"
                data.hpLabel.Visible  = true
                data.hpLabel.Position = UDim2.new(0, 0, 0.33, 0)
                data.distLabel.Position = UDim2.new(0, 0, 0.66, 0)
            else
                data.hpLabel.Text    = ""
                data.hpLabel.Visible = false
                data.distLabel.Position = UDim2.new(0, 0, 0.33, 0)
            end

            if ShowName and not data.nameLabel.Text:find("|") then
                data.nameLabel.Visible = true
            end

            data.distLabel.Text    = ShowDistance and ("[ " .. oDist .. " MM ]") or ""
            data.distLabel.Visible = ShowDistance

            if data.highlight then data.highlight.Enabled = ShowHighlight end
            if data.bill      then data.bill.Enabled      = true end
        end
        -- World Object labels ถูก update ในรอบ scan ด้านบนแล้ว
    end
end

-- ── Heartbeat throttle ──
RunService.Heartbeat:Connect(function(dt)
    _espAccum += dt
    if _espAccum >= ESP_INTERVAL then
        _espAccum = 0
        pcall(updateESP)
    end
end)

-- ── ลบ ESP เมื่อ Player ออก ──
Players.PlayerRemoving:Connect(function(player)
    if player.Character then removeESP(player.Character) end
end)

-- ── ลบ ESP เมื่อ Character Respawn ──
Players.PlayerAdded:Connect(function(player)
    player.CharacterRemoving:Connect(function(char)
        removeESP(char)
    end)
end)
for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterRemoving:Connect(function(char)
        removeESP(char)
    end)
end

-- ── ล้าง ESP ทั้งหมด ──
local function clearAllESP()
    for obj in pairs(espObjects) do
        removeESP(obj)
    end
end

-- ====================== ESP UI ======================
EspTab:Section({ Title = "Feature Esp", Icon = "eye" })

EspTab:Toggle({
    Title = "Enable ESP",
    Desc  = "Automatically enables ESP for all supported",
    Value = espEnabled,
    Callback = function(v)
        espEnabled = v
        Config:Set("espEnabled", v)
        Config:Save()
        if not espEnabled then clearAllESP() end
    end
})

-- ── ESP Distance Slider ──
EspTab:Input({
    Title = "Set ESP Distance (Maximum distance)",
    Default = tostring(ESP_MAX_DISTANCE),
    Placeholder = "Default: 1500",
    Callback = function(text)
        local num = tonumber(text)
        if num then ESP_MAX_DISTANCE = num; Config:Set("ESP_MAX_DISTANCE", num); Config:Save()
        else warn("Entered an incorrect number!") end
    end
})

EspTab:Section({ Title = "Esp Role", Icon = "user" })
EspTab:Toggle({
    Title = "ESP Survivor",
    Desc  = "ESP the Survivor locations through walls",
    Value = espSurvivor,
    Callback = function(v) espSurvivor = v; Config:Set("espSurvivor", v); Config:Save() end
})
EspTab:Toggle({
    Title = "ESP Killer",
    Desc  = "ESP the Killer location through walls",
    Value = espMurder,
    Callback = function(v) espMurder = v; Config:Set("espMurder", v); Config:Save() end
})

EspTab:Section({ Title = "Esp Engine", Icon = "biceps-flexed" })
EspTab:Toggle({
    Title = "ESP Generator",
    Desc  = "ESP the Generator location through walls",
    Value = espGenerator,
    Callback = function(v)
        espGenerator = v; Config:Set("espGenerator", v); Config:Save()
        if not v then
            for obj in pairs(espObjects) do
                if obj.Name == "Generator" then removeESP(obj) end
            end
        end
    end
})
EspTab:Toggle({
    Title = "ESP Gate",
    Desc  = "ESP the Gate locations through walls",
    Value = espGate,
    Callback = function(v)
        espGate = v; Config:Set("espGate", v); Config:Save()
        if not v then
            for obj in pairs(espObjects) do
                if obj.Name == "Gate" then removeESP(obj) end
            end
        end
    end
})

EspTab:Section({ Title = "Esp Object", Icon = "package" })
EspTab:Toggle({
    Title = "ESP Pallet",
    Desc  = "ESP the Pallet locations through walls",
    Value = espPallet,
    Callback = function(v)
        espPallet = v; Config:Set("espPallet", v); Config:Save()
        if not v then
            for obj in pairs(espObjects) do
                if obj.Name == "Palletwrong" then removeESP(obj) end
            end
        end
    end
})
EspTab:Toggle({
    Title = "ESP Hook",
    Desc  = "ESP the Hook locations through walls",
    Value = espHook,
    Callback = function(v)
        espHook = v; Config:Set("espHook", v); Config:Save()
        if not v then
            for obj in pairs(espObjects) do
                if obj.Name == "Model" and obj.Parent and obj.Parent.Name == "Hook" then
                    removeESP(obj)
                end
            end
        end
    end
})
EspTab:Toggle({
    Title = "ESP Window",
    Desc  = "ESP the Window locations through walls",
    Value = espWindowEnabled,
    Callback = function(v)
        espWindowEnabled = v; Config:Set("espWindow", v); Config:Save()
        if not v then
            for obj in pairs(espObjects) do
                if obj.Name == "Window" then removeESP(obj) end
            end
        end
    end
})
EspTab:Toggle({
    Title = "ESP Patient",
    Desc  = "ESP the Patient (SCP) locations through walls",
    Value = espPatient,
    Callback = function(v)
        espPatient = v; Config:Set("espPatient", v); Config:Save()
        if not v then
            for obj in pairs(espObjects) do
                if obj.Name:match("^[Ss][Cc][Pp]%d*$") then removeESP(obj) end
            end
        end
    end
})

EspTab:Section({ Title = "Esp Settings", Icon = "settings" })
EspTab:Toggle({
    Title = "Show Name", Desc = "Displays object and player names", Value = ShowName,
    Callback = function(v) ShowName = v; Config:Set("ShowName", v); Config:Save() end
})
EspTab:Toggle({
    Title = "Show Distance", Desc = "Shows the distance between you and ESP targets", Value = ShowDistance,
    Callback = function(v) ShowDistance = v; Config:Set("ShowDistance", v); Config:Save() end
})
EspTab:Toggle({
    Title = "Show Health", Desc = "Displays player health values", Value = ShowHP,
    Callback = function(v) ShowHP = v; Config:Set("ShowHP", v); Config:Save() end
})
EspTab:Toggle({
    Title = "Show Highlight", Desc = "Adds highlights around ESP targets", Value = ShowHighlight,
    Callback = function(v)
        ShowHighlight = v; Config:Set("ShowHighlight", v); Config:Save()
        for _, data in pairs(espObjects) do
            if data.highlight then data.highlight.Enabled = v end
        end
    end
})
EspTab:Toggle({
    Title = "Show Percent", Desc = "Shows generator completion percentage", Value = ShowPercent,
    Callback = function(v) ShowPercent = v; Config:Set("ShowPercent", v); Config:Save() end
})

-- ====================== MAIN TAB ======================
MainTab:Section({ Title = "Feature Gameplay", Icon = "target" })

MainTab:Button({
    Title    = "Aimbot (NEW)",
    Desc     = "Advanced survivor aimbot settings and lock",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/Y6ui9r3d/raw"))()
    end
})

-- ── Crosshair ──
local CrosshairEnabled = Config:Get("CrosshairEnabled", false)

local function CreateCrosshair()
    if PlayerGui:FindFirstChild("CrosshairGUI") then return end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name            = "CrosshairGUI"
    ScreenGui.ResetOnSpawn    = false
    ScreenGui.IgnoreGuiInset  = true
    ScreenGui.Parent          = PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Name                = "Crosshair"
    Frame.Size                = UDim2.new(0, 5, 0, 5)
    Frame.AnchorPoint         = Vector2.new(0.5, 0.5)
    Frame.Position            = UDim2.new(0.5, 0, 0.5, 0)
    Frame.BackgroundColor3    = Color3.new(1, 1, 1)
    Frame.BackgroundTransparency = 0.3
    Frame.BorderSizePixel     = 0
    Frame.ZIndex              = 999
    Frame.Parent              = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent       = Frame
end

local function RemoveCrosshair()
    local gui = PlayerGui:FindFirstChild("CrosshairGUI")
    if gui then gui:Destroy() end
end

PlayerGui.ChildRemoved:Connect(function(child)
    if child.Name == "CrosshairGUI" and CrosshairEnabled then
        task.defer(CreateCrosshair)
    end
end)

if CrosshairEnabled then CreateCrosshair() end

MainTab:Toggle({
    Title = "Enable Cursor (Recommended)",
    Desc  = "Creates a center screen cursor for aiming",
    Value = CrosshairEnabled,
    Callback = function(state)
        CrosshairEnabled = state
        Config:Set("CrosshairEnabled", state)
        Config:Save()
        if state then CreateCrosshair() else RemoveCrosshair() end
    end
})

-- ── Bypass Gate ──
local bypassGateEnabled = Config:Get("bypassGateEnabled", false)

local function gatherGates()
    local gates = {}
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "Gate" and desc:IsA("Model") then
            table.insert(gates, desc)
        end
    end
    return gates
end

local function setGateState(enabled)
    for _, gate in pairs(gatherGates()) do
        local leftGate  = gate:FindFirstChild("LeftGate")
        local rightGate = gate:FindFirstChild("RightGate")
        local leftEnd   = gate:FindFirstChild("LeftGate-end")
        local rightEnd  = gate:FindFirstChild("RightGate-end")
        local box       = gate:FindFirstChild("Box")
        if enabled then
            if leftGate  then leftGate.Transparency  = 1; leftGate.CanCollide  = false end
            if rightGate then rightGate.Transparency = 1; rightGate.CanCollide = false end
            if leftEnd   then leftEnd.Transparency   = 0; leftEnd.CanCollide   = true  end
            if rightEnd  then rightEnd.Transparency  = 0; rightEnd.CanCollide  = true  end
            if box       then box.CanCollide         = false end
        else
            if leftGate  then leftGate.Transparency  = 0; leftGate.CanCollide  = true  end
            if rightGate then rightGate.Transparency = 0; rightGate.CanCollide = true  end
            if leftEnd   then leftEnd.Transparency   = 1; leftEnd.CanCollide   = true  end
            if rightEnd  then rightEnd.Transparency  = 1; rightEnd.CanCollide  = true  end
            if box       then box.CanCollide         = true  end
        end
    end
end

if bypassGateEnabled then setGateState(true) end

MainTab:Section({ Title = "Feature Bypass", Icon = "lock-open" })
MainTab:Toggle({
    Title = "Bypass Gate (Open Gate)",
    Desc  = "Lets you walk through opened gates",
    Value = bypassGateEnabled,
    Callback = function(state)
        bypassGateEnabled = state
        Config:Set("bypassGateEnabled", state)
        Config:Save()
        setGateState(state)
    end
})

-- ── Visual ──
local fullBrightEnabled = Config:Get("fullBrightEnabled", false)
local noFogEnabled      = Config:Get("noFogEnabled", false)
local _fullBrightConn, _noFogConn

MainTab:Section({ Title = "Feature Visual", Icon = "lightbulb" })
MainTab:Toggle({
    Title = "Full Bright",
    Desc  = "Brightens the entire map for better visibility",
    Value = fullBrightEnabled,
    Callback = function(v)
        fullBrightEnabled = v
        Config:Set("fullBrightEnabled", v)
        Config:Save()
        if v then
            if _fullBrightConn then _fullBrightConn:Disconnect() end
            _fullBrightConn = RunService.Heartbeat:Connect(function()
                if not fullBrightEnabled then _fullBrightConn:Disconnect(); _fullBrightConn = nil; return end
                Lighting.Brightness = 2
                Lighting.ClockTime  = 14
                Lighting.Ambient    = Color3.fromRGB(255, 255, 255)
            end)
        else
            if _fullBrightConn then _fullBrightConn:Disconnect(); _fullBrightConn = nil end
            Lighting.Brightness = 1
            Lighting.ClockTime  = 12
            Lighting.Ambient    = Color3.fromRGB(128, 128, 128)
        end
    end
})

MainTab:Toggle({
    Title = "No Fog",
    Desc  = "Removes fog and improves map clarity",
    Value = noFogEnabled,
    Callback = function(v)
        noFogEnabled = v
        Config:Set("noFogEnabled", v)
        Config:Save()
        if v then
            if _noFogConn then _noFogConn:Disconnect() end
            _noFogConn = RunService.Heartbeat:Connect(function()
                if not noFogEnabled then _noFogConn:Disconnect(); _noFogConn = nil; return end
                local atm = Lighting:FindFirstChild("Atmosphere")
                if atm then atm.Density = 0 end
            end)
        else
            if _noFogConn then _noFogConn:Disconnect(); _noFogConn = nil end
            local atm = Lighting:FindFirstChild("Atmosphere")
            if atm then atm.Density = 0.5 end
        end
    end
})

-- ── Anti AFK ──
MainTab:Section({ Title = "Misc", Icon = "settings" })
local AntiAFK_main    = Config:Get("AntiAFK_main", true)
local _antiAfkThread

local function startAntiAFK()
    if _antiAfkThread then task.cancel(_antiAfkThread); _antiAfkThread = nil end
    _antiAfkThread = task.spawn(function()
        while AntiAFK_main do
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(math.random(150, 270))
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(math.random(150, 270))
        end
    end)
end

if AntiAFK_main then startAntiAFK() end

MainTab:Toggle({
    Title = "Anti AFK",
    Desc  = "Prevents automatic AFK disconnection.",
    Value = AntiAFK_main,
    Callback = function(state)
        AntiAFK_main = state
        Config:Set("AntiAFK_main", state)
        Config:Save()
        if state then startAntiAFK()
        elseif _antiAfkThread then task.cancel(_antiAfkThread); _antiAfkThread = nil end
    end
})


-- ====================== SURVIVOR TAB ======================
SurTab:Section({ Title = "Feature Survivor", Icon = "user" })

-- Auto Shoot
local autoShoot = false
SurTab:Toggle({
    Title = "Auto Shoot (STILL BUG)",
    Desc  = "Automatically shoots nearby killer",
    Value = false,
    Callback = function(v)
        autoShoot = v
        if autoShoot then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes")
                    :WaitForChild("Items")
                    :WaitForChild("Parrying Dagger")
                    :WaitForChild("parry")
                while autoShoot do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Weapon") then
                                local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                                if tr and (root.Position - tr.Position).Magnitude <= 10 then
                                    remote:FireServer()
                                end
                            end
                        end
                    end
                    task.wait(0.001)
                end
            end)
        end
    end
})

-- Auto Parry
local autoparry = false
SurTab:Toggle({
    Title = "Auto Parry (STILL BUG)",
    Desc  = "Automatically parries nearby killer attacks",
    Value = false,
    Callback = function(v)
        autoparry = v
        if autoparry then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes")
                    :WaitForChild("Items")
                    :WaitForChild("Parrying Dagger")
                    :WaitForChild("parry")
                while autoparry do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Weapon") then
                                local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                                if tr and (root.Position - tr.Position).Magnitude <= 10 then
                                    remote:FireServer()
                                end
                            end
                        end
                    end
                    task.wait(0.001)
                end
            end)
        end
    end
})

-- ====================== GENERATOR HELPERS (SHARED) ======================

local GeneratorRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator")
local skillRemote      = GeneratorRemotes:WaitForChild("SkillCheckResultEvent")
local repairRemote     = GeneratorRemotes:WaitForChild("RepairEvent")

local currentRepairPoint = nil
local currentRepairModel = nil

local cancelWalkCooldown = false
local cancelXCooldown    = false
local mobileCancelHold   = false

local function notify(title, content)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = 5,
        Icon = "triangle-alert"
    })
end

local function getClosestGeneratorPoint(root, maxDist)
    local gens = getFolderGenerator()
    local bestGen, bestPt, bestDist = nil, nil, maxDist or 999

    for _, gen in ipairs(gens) do
        if not generatorFinished(gen) then
            for i = 1, 4 do
                local pt = gen:FindFirstChild("GeneratorPoint" .. i)
                if pt then
                    local d = (root.Position - pt.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestGen = gen
                        bestPt = pt
                    end
                end
            end
        end
    end

    return bestGen, bestPt, bestDist
end

local function findNearestWeaponPlayer(root, maxDist)
    local nearest, nearestDist = nil, maxDist or 12.5

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            local hasWeapon = obj:FindFirstChild("Weapon", true)
            local hrp_      = obj:FindFirstChild("HumanoidRootPart")

            if hasWeapon and hrp_ then
                local dist = (root.Position - hrp_.Position).Magnitude

                if dist < nearestDist then
                    nearestDist = dist
                    nearest = obj
                end
            end
        end
    end

    return nearest, nearestDist
end

local function cancelRepair()
    if currentRepairPoint then
        repairRemote:FireServer(currentRepairPoint, false)
        task.wait(0.05)
        repairRemote:FireServer(currentRepairPoint, false)
    end
end

local function teleportToBestGenerator()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    local gen, pt = getClosestGeneratorPoint(root)

    if gen and pt then
        currentRepairModel = gen
        currentRepairPoint = pt

        root.CFrame = CFrame.new(pt.Position + Vector3.new(0, 2, 0))

        task.wait(0.15)

        repairRemote:FireServer(pt, true)
    end
end

-- Better cancel movement system (PC + Mobile)
task.spawn(function()
    while true do
        task.wait(0.06)

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")

        if root and hum and currentRepairPoint then
            local dist = (root.Position - currentRepairPoint.Position).Magnitude

            local moving =
                hum.MoveDirection.Magnitude > 0.03
                or root.AssemblyLinearVelocity.Magnitude > 1

            if dist <= 7 and moving then
                if not cancelWalkCooldown then
                    cancelWalkCooldown = true

                    cancelRepair()

                    task.wait(0.35)

                    cancelWalkCooldown = false
                end
            end
        else
            cancelWalkCooldown = false
        end
    end
end)

-- X Cancel (PC)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then
        return
    end

    if input.KeyCode == Enum.KeyCode.X then
        if currentRepairPoint and not cancelXCooldown then
            cancelXCooldown = true

            cancelRepair()

            notify(
                "Generator Cancelled",
                "Repair cancelled successfully."
            )

            task.delay(0.4, function()
                cancelXCooldown = false
            end)
        end
    end
end)

-- Mobile cancel support
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    task.spawn(function()
        while true do
            task.wait(0.1)

            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")

            if hum and currentRepairPoint then
                if hum.MoveDirection.Magnitude > 0.05 then
                    if not mobileCancelHold then
                        mobileCancelHold = true

                        cancelRepair()

                        task.wait(0.4)

                        mobileCancelHold = false
                    end
                end
            end
        end
    end)
end

-- ── Generator Section ──
SurTab:Section({
    Title = "Feature Generator",
    Icon = "zap"
})

local AutoSkillPerfect = Config:Get("AutoSkillPerfect", false)
local AutoSkillNeutral = Config:Get("AutoSkillNeutral", false)
local AutoGenRepair    = Config:Get("AutoGenRepair", false)

-- Auto Perfect
SurTab:Toggle({
    Title = "Auto SkillCheck (Perfect)",
    Desc  = "Automatically hits perfect generator skill checks",
    Value = AutoSkillPerfect,

    Callback = function(v)
        AutoSkillPerfect = v
        Config:Set("AutoSkillPerfect", v)
        Config:Save()

        if v then
            notify(
                "Auto Skill Perfect Enabled",
                "Perfect skill checks are now automatic."
            )

            task.spawn(function()
                local pGui = LocalPlayer:WaitForChild("PlayerGui")

                while AutoSkillPerfect do
                    task.wait(0.1)

                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")

                    if root then
                        local gen, pt = getClosestGeneratorPoint(root)

                        if gen and pt then
                            currentRepairModel = gen
                            currentRepairPoint = pt
                        end

                        local gui = pGui:FindFirstChild("SkillCheckPromptGui")

                        if gui then
                            local check = gui:FindFirstChild("Check")

                            if check and check.Visible and currentRepairPoint then
                                local dist = (root.Position - currentRepairPoint.Position).Magnitude

                                if dist <= 6 then
                                    skillRemote:FireServer(
                                        "success",
                                        1,
                                        currentRepairModel,
                                        currentRepairPoint
                                    )

                                    check.Visible = false
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- Auto Neutral
SurTab:Toggle({
    Title = "Auto SkillCheck (Not Perfect)",
    Desc  = "Automatically hits neutral skill checks",
    Value = AutoSkillNeutral,

    Callback = function(v)
        AutoSkillNeutral = v
        Config:Set("AutoSkillNeutral", v)
        Config:Save()

        if v then
            notify(
                "Auto Skill Neutral Enabled",
                "Neutral skill checks are now automatic."
            )

            task.spawn(function()
                local pGui = LocalPlayer:WaitForChild("PlayerGui")

                while AutoSkillNeutral do
                    task.wait(0.1)

                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")

                    if root then
                        local gen, pt = getClosestGeneratorPoint(root)

                        if gen and pt then
                            currentRepairModel = gen
                            currentRepairPoint = pt
                        end

                        local gui = pGui:FindFirstChild("SkillCheckPromptGui")

                        if gui then
                            local check = gui:FindFirstChild("Check")

                            if check and check.Visible and currentRepairPoint then
                                local dist = (root.Position - currentRepairPoint.Position).Magnitude

                                if dist <= 6 then
                                    skillRemote:FireServer(
                                        "neutral",
                                        0,
                                        currentRepairModel,
                                        currentRepairPoint
                                    )

                                    check.Visible = false
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- Auto Generator
SurTab:Toggle({
    Title = "Auto Generator (Teleport + Repair)",
    Desc  = "Teleports and repairs generators automatically",
    Value = AutoGenRepair,

    Callback = function(v)
        AutoGenRepair = v
        Config:Set("AutoGenRepair", v)
        Config:Save()

        if v then
            notify(
                "Auto Generator Enabled",
                "Press X or move joystick to cancel repair."
            )

            task.spawn(function()
                while AutoGenRepair do
                    task.wait(0.3)

                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")

                    if root then
                        local killer = findNearestWeaponPlayer(root, 12.5)

                        if killer and currentRepairPoint then
                            cancelRepair()

                            task.wait(0.2)

                            teleportToBestGenerator()
                        else
                            if not currentRepairPoint
                            or (root.Position - currentRepairPoint.Position).Magnitude > 8 then
                                teleportToBestGenerator()
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- ── Heal Section ──
SurTab:Section({ Title = "Feature Heal", Icon = "cross" })

local function getHealth(plr)
    if not plr.Character then return 100 end
    local hum = plr.Character:FindFirstChild("Humanoid")
    if hum then return hum.Health end
    local h = plr.Character:FindFirstChild("Health")
    if h and h.Value then return h.Value end
    return 100
end

local function getClosestLowHPPlayer(root, maxDist)
    local closest, closestDist = nil, maxDist or 6
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp_ = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp_ and getHealth(plr) <= 60 then
                local d = (root.Position - hrp_.Position).Magnitude
                if d < closestDist then closest = plr; closestDist = d end
            end
        end
    end
    return closest
end

local autoHealEnabled  = false
local autoHealEnabled2 = false

local function runHealLoop(flagGetter, flagName)
    task.spawn(function()
        local pGui      = LocalPlayer:WaitForChild("PlayerGui")
        local healRemote = ReplicatedStorage:WaitForChild("Remotes")
            :WaitForChild("Healing")
            :WaitForChild("SkillCheckResultEvent")
        local lastHealTarget = nil
        while flagGetter() do
            task.wait(0.15)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChild("Humanoid")
            if root and hum then
                local isMoving = hum.MoveDirection.Magnitude > 0.05
                local target   = getClosestLowHPPlayer(root)
                if not lastHealTarget and target then lastHealTarget = target end
                if isMoving then lastHealTarget = nil end
                local gui = pGui:FindFirstChild("SkillCheckPromptGui")
                if gui then
                    local check = gui:FindFirstChild("Check")
                    if check and check.Visible and lastHealTarget then
                        if getHealth(lastHealTarget) <= 60 and lastHealTarget.Character then
                            healRemote:FireServer("success", 1, lastHealTarget.Character)
                            check.Visible = false
                        end
                    end
                end
            end
        end
    end)
end

SurTab:Toggle({
    Title = "Auto Heal SkillCheck (STILL BUG)",
    Desc  = "Automatically completes healing skill checks",
    Value = false,
    Callback = function(v)
        autoHealEnabled = v
        if v then runHealLoop(function() return autoHealEnabled end, "autoHealEnabled") end
    end
})
SurTab:Toggle({
    Title = "Instant Heal (STILL BUG)",
    Desc  = "Automatically completes healing in 1 sec",
    Value = false,
    Callback = function(v)
        autoHealEnabled2 = v
        if v then runHealLoop(function() return autoHealEnabled2 end, "autoHealEnabled2") end
    end
})

-- ── Cheat Section ──
SurTab:Section({ Title = "Feature Cheat", Icon = "bug" })

SurTab:Button({
    Title    = "Fling Killer (Spam if doesn't fling)",
    Desc     = "Attempts to fling the killer away using physics",
    Callback = function()
        local Targets = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Weapon") then
                table.insert(Targets, plr.Name)
            end
        end
        local AllBool = false
        local function GetPlayer(Name)
            Name = Name:lower()
            if Name == "all" or Name == "others" then AllBool = true; return end
            if Name == "random" then
                local pl = Players:GetPlayers()
                local idx = table.find(pl, LocalPlayer)
                if idx then table.remove(pl, idx) end
                return pl[math.random(#pl)]
            end
            for _, x in next, Players:GetPlayers() do
                if x ~= LocalPlayer then
                    if x.Name:lower():match("^" .. Name) or x.DisplayName:lower():match("^" .. Name) then return x end
                end
            end
        end
        local function Message(_T, _t, t)
            StarterGui:SetCore("SendNotification", { Title = _T, Text = _t, Duration = t })
        end
        local function SkidFling(TargetPlayer)
            local Char  = LocalPlayer.Character
            local Hum   = Char and Char:FindFirstChildOfClass("Humanoid")
            local Root  = Hum and Hum.RootPart
            local TC    = TargetPlayer.Character
            local TH    = TC and TC:FindFirstChildOfClass("Humanoid")
            local TR    = TC and TC:FindFirstChild("HumanoidRootPart")
            local THead = TC and TC:FindFirstChild("Head")
            local Acc   = TC and TC:FindFirstChildOfClass("Accessory")
            local Hand  = Acc and Acc:FindFirstChild("Handle")
            if not (Char and Hum and Root) then return Message("Error", "Script Failed", 5) end
            if Root.Velocity.Magnitude < 50 then getgenv().OldPos = Root.CFrame end
            if TH and TH.Sit and not AllBool then return Message("Error", "Target is sitting", 5) end
            if THead then Workspace.CurrentCamera.CameraSubject = THead
            elseif Hand then Workspace.CurrentCamera.CameraSubject = Hand
            elseif TH then Workspace.CurrentCamera.CameraSubject = TH end
            if not TC:FindFirstChildWhichIsA("BasePart") then return end
            local FPos = function(BP, Pos, Ang)
                Root.CFrame = CFrame.new(BP.Position) * Pos * Ang
                Char:SetPrimaryPartCFrame(CFrame.new(BP.Position) * Pos * Ang)
                Root.Velocity    = Vector3.new(9e7, 9e7 * 10, 9e7)
                Root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end
            local SFBasePart = function(BP)
                local Time, Angle = tick(), 0
                repeat
                    if Root and TH then
                        if BP.Velocity.Magnitude < 50 then
                            Angle += 100
                            FPos(BP, CFrame.new(0, 1.5, 0) + TH.MoveDirection * BP.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BP, CFrame.new(0, -1.5, 0) + TH.MoveDirection * BP.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                        else
                            FPos(BP, CFrame.new(0, 1.5, TR.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                        end
                    else break end
                until BP.Velocity.Magnitude > 500 or BP.Parent ~= TargetPlayer.Character or TH.Sit or Hum.Health <= 0 or tick() > Time + 2
            end
            Workspace.FallenPartsDestroyHeight = 0 / 0
            local BV = Instance.new("BodyVelocity")
            BV.Name      = "DYHUB-YES"
            BV.Parent    = Root
            BV.Velocity  = Vector3.new(9e9, 9e9, 9e9)
            BV.MaxForce  = Vector3.new(math.huge, math.huge, math.huge)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            if TR and THead then
                if (TR.CFrame.p - THead.CFrame.p).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TR) end
            elseif TR then SFBasePart(TR)
            elseif THead then SFBasePart(THead)
            elseif Hand then SFBasePart(Hand)
            else return Message("Error", "Target missing everything", 5) end
            BV:Destroy()
            Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            Workspace.CurrentCamera.CameraSubject = Hum
            repeat
                Root.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
                Char:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
                Hum:ChangeState("GettingUp")
                for _, x in ipairs(Char:GetChildren()) do
                    if x:IsA("BasePart") then x.Velocity = Vector3.new(); x.RotVelocity = Vector3.new() end
                end
                task.wait()
            until (Root.Position - getgenv().OldPos.p).Magnitude < 25
            Workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
        if not getgenv().Welcome then Message("DYHUB | FLING", "THANK FOR USING", 6) end
        getgenv().Welcome = true
        if AllBool then
            for _, x in next, Players:GetPlayers() do SkidFling(x) end
        end
        for _, x in next, Targets do
            local TPlayer = GetPlayer(x)
            if TPlayer and TPlayer ~= LocalPlayer then
                if TPlayer.UserId ~= 4340578793 then SkidFling(TPlayer)
                else Message("ERROR", "CANT FLING OWNER", 8) end
            end
        end
    end
})

SurTab:Button({
    Title    = "Invisible (Not Visual)",
    Desc     = "Makes your character invisible to others",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/mabdu21/kjandsaddjadbhahayenajhsjbdwa/refs/heads/main/INV.lua"))()
    end
})

SurTab:Button({
    Title    = "Self UnHook (Not 100%)",
    Desc     = "Attempts to free yourself from hooks",
    Callback = function()
        ReplicatedStorage.Remotes.Carry.SelfUnHookEvent:FireServer()
    end
})

-- ====================== KILLER TAB ======================
local DYHUB_AimbotEnabled        = false
local DYHUB_Aimbot28Enabled      = false
local DYHUB_LockedTarget         = nil
local DYHUB_PredictionTime       = 0.14
local DYHUB_MIN_DISTANCE         = 1
local DYHUB_MAX_DISTANCE         = 250
local DYHUB_MIN_PITCH            = Config:Get("DYHUB_MIN_PITCH", -1)
local DYHUB_MAX_PITCH            = Config:Get("DYHUB_MAX_PITCH", 30)
local DYHUB_LOW_HP_IGNORE        = 20
local DYHUB_ToughWall            = Config:Get("DYHUB_ToughWall", true)
local DYHUB_AimbotToggleGUIVisible   = false
local DYHUB_Aimbot28ToggleGUIVisible = false
local DYHUB_mobileButton, DYHUB_mobileButton28, DYHUB_guiFolder

local DYHUB_Settings = {
    Aimbot = {
        DragUI                 = false,
        MobileButtonPosition   = UDim2.new(1, -40, 1, -40),
        MobileButton28Position = UDim2.new(1, -140, 1, -40),
        SetKeybindLock         = Config:Get("AimbotKey", "Z"),
        SetKeybindLock28       = Config:Get("AimbotKey28", "X"),
    }
}

killerTab:Section({ Title = "Killer: The Veil", Icon = "target" })
killerTab:Paragraph({
    Title = "Information: The Veil",
    Desc  = "• Aimbot is currently in BETA.\n• There is a chance of missing.\n• Aimbot will not support people at high places.",
    Image = "rbxassetid://104487529937663",
    ImageSize = 50,
})

killerTab:Toggle({
    Title = "Enable Aimbot (The Veil)", Desc = "Automatically locks aim onto nearby survivors", Value = false,
    Callback = function(state)
        if state and DYHUB_Aimbot28Enabled then
            DYHUB_Aimbot28Enabled = false
            if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        DYHUB_AimbotEnabled = state
        if DYHUB_mobileButton then
            DYHUB_mobileButton.BackgroundColor3 = state and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
        end
    end
})

killerTab:Toggle({
    Title = "Enable Aimbot Charge (The Veil)", Desc = "Charge-based aimbot optimized for The Veil", Value = false,
    Callback = function(state)
        if state and DYHUB_AimbotEnabled then
            DYHUB_AimbotEnabled = false
            if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        DYHUB_Aimbot28Enabled = state
        if DYHUB_mobileButton28 then
            DYHUB_mobileButton28.BackgroundColor3 = state and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
        end
    end
})

killerTab:Section({ Title = "Killer: The Veil Setting", Icon = "settings" })
killerTab:Input({
    Title = "Set Pitch Min", Value = tostring(DYHUB_MIN_PITCH), Placeholder = "Default: -1",
    Callback = function(v)
        local n = tonumber(v)
        if n then DYHUB_MIN_PITCH = n; Config:Set("DYHUB_MIN_PITCH", n); Config:Save() end
    end
})
killerTab:Input({
    Title = "Set Pitch Max", Value = tostring(DYHUB_MAX_PITCH), Placeholder = "Default: 30",
    Callback = function(v)
        local n = tonumber(v)
        if n then DYHUB_MAX_PITCH = n; Config:Set("DYHUB_MAX_PITCH", n); Config:Save() end
    end
})
killerTab:Toggle({
    Title = "Tough Wall (The Veil)", Desc = "Allows aiming through walls", Value = DYHUB_ToughWall,
    Callback = function(v) DYHUB_ToughWall = v; Config:Set("DYHUB_ToughWall", v); Config:Save() end
})
killerTab:Input({
    Title = "Set Keybind Aimbot (PC)", Value = DYHUB_Settings.Aimbot.SetKeybindLock, Placeholder = "Default: Z",
    Callback = function(v)
        if #v == 1 then
            DYHUB_Settings.Aimbot.SetKeybindLock = v:upper()
            Config:Set("AimbotKey", v:upper()); Config:Save()
        end
    end
})
killerTab:Input({
    Title = "Set Keybind Aimbot Charge (PC)", Value = DYHUB_Settings.Aimbot.SetKeybindLock28, Placeholder = "Default: X",
    Callback = function(v)
        if #v == 1 then
            DYHUB_Settings.Aimbot.SetKeybindLock28 = v:upper()
            Config:Set("AimbotKey28", v:upper()); Config:Save()
        end
    end
})

killerTab:Section({ Title = "Killer: The Veil GUI", Icon = "settings" })
killerTab:Toggle({
    Title = "Enable Aimbot (Toggle GUI)", Desc = "Shows a mobile toggle button for aimbot", Value = false,
    Callback = function(v)
        DYHUB_AimbotToggleGUIVisible = v
        if DYHUB_mobileButton then DYHUB_mobileButton.Visible = v end
    end
})
killerTab:Toggle({
    Title = "Enable Aimbot Charge (Toggle GUI)", Desc = "Shows a mobile toggle button for aimbot charge", Value = false,
    Callback = function(v)
        DYHUB_Aimbot28ToggleGUIVisible = v
        if DYHUB_mobileButton28 then DYHUB_mobileButton28.Visible = v end
    end
})
killerTab:Toggle({
    Title = "Custom Position Drag (Toggle GUI)", Desc = "Allows dragging the mobile aimbot buttons", Value = false,
    Callback = function(state)
        DYHUB_Settings.Aimbot.DragUI = state
        DYHUB_EnableDrag(state)
    end
})

-- ── Aimbot Helpers ──
local function DYHUB_GetLocalRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function DYHUB_HP_OK(plr)
    local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
    return hum and hum.Health > DYHUB_LOW_HP_IGNORE
end
local function DYHUB_GetClosestInScreen()
    local closest, minDist = nil, math.huge
    local mouse = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and DYHUB_HP_OK(plr) then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                    if d < minDist then minDist = d; closest = plr end
                end
            end
        end
    end
    return closest
end
local function DYHUB_GetClosestByDistance()
    local root = DYHUB_GetLocalRoot()
    if not root then return nil end
    local closest, distMin = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and DYHUB_HP_OK(plr) then
            local r = plr.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (root.Position - r.Position).Magnitude
                if d < distMin then distMin = d; closest = plr end
            end
        end
    end
    return closest, distMin
end
local function DYHUB_CanSeeTarget(target)
    if DYHUB_ToughWall then return true end
    local head = target.Character and target.Character:FindFirstChild("Head")
    local root = DYHUB_GetLocalRoot()
    if not head or not root then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LocalPlayer.Character or {}, target.Character }
    local result = Workspace:Raycast(root.Position + Vector3.new(0, 2, 0), head.Position - root.Position, params)
    return not result
end
local function DYHUB_GetAutoPitchMax(dist)
    if dist >= 190 then return 45.5
    elseif dist >= 150 then return 40.5
    elseif dist >= 90  then return 36.5
    else return 30.5 end
end
local function DYHUB_AimAt_Normal(target)
    if not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    local hrp_ = target.Character:FindFirstChild("HumanoidRootPart")
    local lr   = DYHUB_GetLocalRoot()
    if not head or not hrp_ or not lr then return end
    local pred     = head.Position + (hrp_.Velocity * DYHUB_PredictionTime)
    local dist     = (lr.Position - pred).Magnitude
    local pitchMax = DYHUB_GetAutoPitchMax(dist)
    local alpha    = math.clamp((dist - DYHUB_MIN_DISTANCE) / (DYHUB_MAX_DISTANCE - DYHUB_MIN_DISTANCE), 0, 1)
    local pitch    = DYHUB_MIN_PITCH + (pitchMax - DYHUB_MIN_PITCH) * alpha
    local dir      = (pred - Camera.CFrame.Position).Unit
    local yaw      = math.atan2(dir.X, dir.Z)
    local pr       = math.rad(pitch)
    local look     = Vector3.new(math.sin(yaw)*math.cos(pr), math.sin(pr), math.cos(yaw)*math.cos(pr))
    Camera.CFrame  = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + look)
end
local _pitchTable = {{1,0.09},{10,0.9},{20,1.9},{30,2.9},{40,3.9},{50,4.9},{60,5.9},{70,6.9},{80,7.9},{90,8.9},{100,10.9},{110,11.9},{120,12.9},{130,13.9},{140,14.9},{150,15.9},{160,16.9},{170,17.9},{180,18.9},{190,20.3},{200,22.3}}
local function DYHUB_GetPitchByDistance(d)
    for _, v in ipairs(_pitchTable) do if d < v[1] then return v[2] end end
    return 23.3
end
local function DYHUB_AimAt_28(target)
    if not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    local hrp_ = target.Character:FindFirstChild("HumanoidRootPart")
    local lr   = DYHUB_GetLocalRoot()
    if not head or not hrp_ or not lr then return end
    local pred  = head.Position + (hrp_.Velocity * DYHUB_PredictionTime)
    local dist  = (pred - Camera.CFrame.Position).Magnitude
    local pitch = DYHUB_GetPitchByDistance(dist)
    local dir   = (pred - Camera.CFrame.Position).Unit
    local yaw   = math.atan2(dir.X, dir.Z)
    local pr    = math.rad(pitch)
    local look  = Vector3.new(math.sin(yaw)*math.cos(pr), math.sin(pr), math.cos(yaw)*math.cos(pr))
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + look)
end

-- Keyboard toggle aimbot
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local key = input.KeyCode.Name
    if key == DYHUB_Settings.Aimbot.SetKeybindLock then
        DYHUB_AimbotEnabled = not DYHUB_AimbotEnabled
        if DYHUB_AimbotEnabled and DYHUB_Aimbot28Enabled then
            DYHUB_Aimbot28Enabled = false
            if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        if DYHUB_mobileButton then
            DYHUB_mobileButton.BackgroundColor3 = DYHUB_AimbotEnabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
        end
    end
    if key == DYHUB_Settings.Aimbot.SetKeybindLock28 then
        DYHUB_Aimbot28Enabled = not DYHUB_Aimbot28Enabled
        if DYHUB_Aimbot28Enabled and DYHUB_AimbotEnabled then
            DYHUB_AimbotEnabled = false
            if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        if DYHUB_mobileButton28 then
            DYHUB_mobileButton28.BackgroundColor3 = DYHUB_Aimbot28Enabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
        end
    end
end)

-- Drag system
local DYHUB_DragConnNormal, DYHUB_DragConn28, DYHUB_DragMoveConn, DYHUB_DragMoveConn28
local function DYHUB_ClearDragConnections()
    if DYHUB_DragConnNormal then DYHUB_DragConnNormal:Disconnect();  DYHUB_DragConnNormal  = nil end
    if DYHUB_DragConn28     then DYHUB_DragConn28:Disconnect();      DYHUB_DragConn28      = nil end
    if DYHUB_DragMoveConn   then DYHUB_DragMoveConn:Disconnect();    DYHUB_DragMoveConn    = nil end
    if DYHUB_DragMoveConn28 then DYHUB_DragMoveConn28:Disconnect();  DYHUB_DragMoveConn28  = nil end
end

function DYHUB_EnableDrag(state)
    DYHUB_ClearDragConnections()
    if not state then
        if DYHUB_mobileButton   then DYHUB_Settings.Aimbot.MobileButtonPosition   = DYHUB_mobileButton.Position end
        if DYHUB_mobileButton28 then DYHUB_Settings.Aimbot.MobileButton28Position = DYHUB_mobileButton28.Position end
        return
    end
    local function makeDrag(btn, settingKey)
        if not btn then return end
        local dragging, startPos, startInput = false, nil, nil
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; startInput = input.Position; startPos = btn.Position
                local ce; ce = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false; DYHUB_Settings.Aimbot[settingKey] = btn.Position; ce:Disconnect()
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - startInput
                btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    makeDrag(DYHUB_mobileButton,   "MobileButtonPosition")
    makeDrag(DYHUB_mobileButton28, "MobileButton28Position")
end

local function DYHUB_EnsureGUIFolder()
    if not DYHUB_guiFolder or not DYHUB_guiFolder.Parent then
        DYHUB_guiFolder = Instance.new("ScreenGui")
        DYHUB_guiFolder.Name         = "DYHUB_AimbotGUI"
        DYHUB_guiFolder.ResetOnSpawn = false
        DYHUB_guiFolder.Parent       = PlayerGui
    end
end

local function DYHUB_CreateMobileButtons()
    pcall(function() if DYHUB_mobileButton   then DYHUB_mobileButton:Destroy()   end end)
    pcall(function() if DYHUB_mobileButton28 then DYHUB_mobileButton28:Destroy() end end)
    local function makeBtn(text, pos, isEnabled)
        local btn = Instance.new("TextButton")
        btn.Size              = UDim2.new(0, 90, 0, 90)
        btn.Position          = pos
        btn.AnchorPoint       = Vector2.new(1, 1)
        btn.BackgroundColor3  = isEnabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
        btn.Text              = text
        btn.TextSize          = 36
        btn.Font              = Enum.Font.GothamBold
        btn.TextColor3        = Color3.new(1, 1, 1)
        btn.Visible           = false
        btn.Parent            = DYHUB_guiFolder
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 45)
        c.Parent = btn
        return btn
    end
    DYHUB_mobileButton   = makeBtn("🗡️", DYHUB_Settings.Aimbot.MobileButtonPosition,   DYHUB_AimbotEnabled)
    DYHUB_mobileButton28 = makeBtn("⚔️", DYHUB_Settings.Aimbot.MobileButton28Position, DYHUB_Aimbot28Enabled)
    DYHUB_mobileButton.Visible   = DYHUB_AimbotToggleGUIVisible
    DYHUB_mobileButton28.Visible = DYHUB_Aimbot28ToggleGUIVisible
    DYHUB_mobileButton.MouseButton1Click:Connect(function()
        DYHUB_AimbotEnabled = not DYHUB_AimbotEnabled
        if DYHUB_AimbotEnabled and DYHUB_Aimbot28Enabled then
            DYHUB_Aimbot28Enabled = false
            if DYHUB_mobileButton28 then DYHUB_mobileButton28.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        DYHUB_mobileButton.BackgroundColor3 = DYHUB_AimbotEnabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
    end)
    DYHUB_mobileButton28.MouseButton1Click:Connect(function()
        DYHUB_Aimbot28Enabled = not DYHUB_Aimbot28Enabled
        if DYHUB_Aimbot28Enabled and DYHUB_AimbotEnabled then
            DYHUB_AimbotEnabled = false
            if DYHUB_mobileButton then DYHUB_mobileButton.BackgroundColor3 = Color3.fromRGB(255,60,60) end
        end
        DYHUB_mobileButton28.BackgroundColor3 = DYHUB_Aimbot28Enabled and Color3.fromRGB(60,255,60) or Color3.fromRGB(255,60,60)
    end)
    DYHUB_EnableDrag(DYHUB_Settings.Aimbot.DragUI)
end

task.spawn(function()
    DYHUB_EnsureGUIFolder()
    DYHUB_CreateMobileButtons()
    while task.wait(3) do
        DYHUB_EnsureGUIFolder()
        local gui = PlayerGui:FindFirstChild("DYHUB_AimbotGUI")
        if gui and not gui.Enabled then gui.Enabled = true end
    end
end)

-- RenderStepped: aimbot (เดิม 1 connection เท่านั้น)
RunService.RenderStepped:Connect(function()
    if DYHUB_AimbotEnabled then
        DYHUB_LockedTarget = DYHUB_GetClosestInScreen()
        if DYHUB_LockedTarget and DYHUB_CanSeeTarget(DYHUB_LockedTarget) then
            DYHUB_AimAt_Normal(DYHUB_LockedTarget)
        end
    elseif DYHUB_Aimbot28Enabled then
        DYHUB_LockedTarget = DYHUB_GetClosestByDistance()
        if DYHUB_LockedTarget and DYHUB_CanSeeTarget(DYHUB_LockedTarget) then
            DYHUB_AimAt_28(DYHUB_LockedTarget)
        end
    end
end)

-- ── The Masked ──
killerTab:Section({ Title = "Killer: The Masked", Icon = "venetian-mask" })
killerTab:Paragraph({
    Title = "Information: The Masked",
    Desc  = "• Richard (No Abilities)\n• Tony (One Shot, No hold)\n• Brandon (Speed Boost)\n• Jake (Lunge Range)\n• Richter (Removes terror radius)\n• Graham (Faster Vault)\n• Alex (Chainsaw, One Shot)",
    Image = "rbxassetid://104487529937663",
    ImageSize = 50,
})
local MaskedList    = {"Richard","Tony","Brandon","Jake","Richter","Graham","Alex"}
local selectedMasks = Config:Get("selectedMasks", "Richard")
killerTab:Dropdown({
    Title    = "Select Mask",
    Values   = MaskedList,
    Multi    = false,
    Value    = selectedMasks,
    Callback = function(value) selectedMasks = value; Config:Set("selectedMasks", value); Config:Save() end
})
killerTab:Button({
    Title    = "Choose Mask (Selected)",
    Desc     = "Equips the selected mask ability",
    Callback = function()
        ReplicatedStorage.Remotes.Killers.Masked.Activatepower:FireServer(selectedMasks)
    end
})
killerTab:Button({
    Title    = "Random Mask (Legit Mode)",
    Desc     = "Chooses a random mask ability automatically",
    Callback = function()
        ReplicatedStorage.Remotes.Killers.Masked.Activatepower:FireServer(MaskedList[math.random(#MaskedList)])
    end
})

-- ── The Stalker ──
killerTab:Section({ Title = "Killer: The Stalker", Icon = "eye-off" })
local Stalker = false
killerTab:Toggle({
    Title = "Start Stalker (Raycast / Remote)", Desc = "Automatically stalks nearby survivors", Value = false,
    Callback = function(v)
        Stalker = v
        if v then
            task.spawn(function()
                while Stalker do
                    task.wait(0.2)
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then continue end
                    if not char:FindFirstChild("Weapon") then continue end
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            local hrp_ = plr.Character:FindFirstChild("HumanoidRootPart")
                            local hum  = plr.Character:FindFirstChild("Humanoid")
                            if hrp_ and hum then
                                local dist = (root.Position - hrp_.Position).Magnitude
                                if dist >= 30 and dist <= 70 and hum.Health > 20 then
                                    ReplicatedStorage:WaitForChild("Remotes")
                                        :WaitForChild("Killers")
                                        :WaitForChild("Stalker")
                                        :WaitForChild("StartStalking")
                                        :FireServer(plr)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- ── Feature Killer ──
killerTab:Section({ Title = "Feature Killer", Icon = "swords" })

local killallEnabled = false
killerTab:Toggle({
    Title = "Kill All (Warning: Get Ban)", Desc = "Automatically teleport and kill all", Value = false,
    Callback = function(v)
        killallEnabled = v
        if v then
            task.spawn(function()
                local remote    = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
                local startCFrame = nil
                while killallEnabled do
                    task.wait(0.2)
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then continue end
                    if not startCFrame then startCFrame = root.CFrame end
                    local targets = {}
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                            local hm = plr.Character:FindFirstChildOfClass("Humanoid")
                            if tr and hm then table.insert(targets, {root = tr, humanoid = hm}) end
                        end
                    end
                    for _, entry in ipairs(targets) do
                        if not killallEnabled then break end
                        if entry.humanoid.Health > 20 then
                            pcall(function()
                                root.CFrame = entry.root.CFrame * CFrame.new(0, 0, 2)
                                remote:FireServer()
                            end)
                            task.wait(0.15)
                        end
                    end
                    local allLow = true
                    for _, entry in ipairs(targets) do
                        if entry.humanoid.Health > 20 then allLow = false; break end
                    end
                    if allLow and startCFrame then root.CFrame = startCFrame; task.wait(1) end
                end
            end)
        end
    end
})

local Autocarry = false
killerTab:Toggle({
    Title = "Auto Carry (Nearby Survivor / 2.5s)", Desc = "Automatically picks up nearby downed survivors", Value = false,
    Callback = function(v)
        Autocarry = v
        if v then
            task.spawn(function()
                while Autocarry do
                    task.wait(2.5)
                    local char = LocalPlayer.Character
                    local hrp_ = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp_ then continue end
                    local candidates = {}
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            local hum  = plr.Character:FindFirstChild("Humanoid")
                            local oHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                            if hum and oHrp and hum.Health == 20
                            and (hrp_.Position - oHrp.Position).Magnitude <= 10 then
                                table.insert(candidates, plr)
                            end
                        end
                    end
                    if #candidates ~= 1 then continue end
                    local target = candidates[1]
                    if target and target.Character then
                        local tHum = target.Character:FindFirstChild("Humanoid")
                        if tHum and tHum.Health == 20 then
                            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry")
                                :WaitForChild("CarrySurvivorEvent"):FireServer(target.Character)
                            task.wait(5)
                        end
                    end
                end
            end)
        end
    end
})

local AutoHook = false
killerTab:Toggle({
    Title = "Auto Hook (Nearby Hook / 2.5s)", Desc = "Automatically hook nearby survivors", Value = false,
    Callback = function(v)
        AutoHook = v
        if v then
            task.spawn(function()
                while AutoHook do
                    task.wait(2.5)
                    local char = LocalPlayer.Character
                    local hrp_ = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp_ then continue end
                    local candidates = {}
                    for _, target in ipairs(Players:GetPlayers()) do
                        if target ~= LocalPlayer and target.Character then
                            local hum  = target.Character:FindFirstChild("Humanoid")
                            local thrp = target.Character:FindFirstChild("HumanoidRootPart")
                            if hum and thrp and hum.Health == 20
                            and (hrp_.Position - thrp.Position).Magnitude <= 10 then
                                table.insert(candidates, target)
                            end
                        end
                    end
                    if #candidates ~= 1 then continue end
                    local nearestHook, nearestDist = nil, 10
                    for _, desc in ipairs(Workspace:GetDescendants()) do
                        if desc.Name == "HookPoint" then
                            local d = (hrp_.Position - desc.Position).Magnitude
                            if d <= nearestDist then nearestDist = d; nearestHook = desc end
                        end
                    end
                    if not nearestHook then continue end
                    ReplicatedStorage.Remotes.Carry.HookEvent:FireServer(nearestHook)
                    task.wait(5)
                end
            end)
        end
    end
})

-- ── Feature Fun ──
killerTab:Section({ Title = "Feature Fun", Icon = "crown" })
local GrabKey = Config:Get("GrabKey", "C")
killerTab:Input({
    Title = "Set Keybind Grab (PC ONLY)", Value = GrabKey, Placeholder = "Grab (Default: C)",
    Callback = function(text)
        if type(text) == "string" and #text > 0 then
            GrabKey = text:upper(); Config:Set("GrabKey", GrabKey); Config:Save()
        end
    end
})

local function DoGrab()
    local char = LocalPlayer.Character
    local hrp_ = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp_ then return end
    local candidates = {}
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and target.Character then
            local hum  = target.Character:FindFirstChild("Humanoid")
            local thrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hum and thrp and (hrp_.Position - thrp.Position).Magnitude <= 20 and hum.Health ~= 20 then
                table.insert(candidates, target)
            end
        end
    end
    if #candidates ~= 1 then return end
    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Killers")
        :WaitForChild("Stalker"):WaitForChild("grab"):FireServer(candidates[1].Character)
end

killerTab:Button({ Title = "Grab (Nearby Survivor/Killer)", Desc = "Automatically grab the player", Callback = DoGrab })

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not GrabKey then return end
    local ok, keyEnum = pcall(function() return Enum.KeyCode[GrabKey] end)
    if ok and keyEnum and input.KeyCode == keyEnum then DoGrab() end
end)

local nocooldownskillEnabled = false
killerTab:Toggle({
    Title = "Auto Attack (No Animation)", Desc = "Automatically attack the player", Value = false,
    Callback = function(v)
        nocooldownskillEnabled = v
        if v then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
                while nocooldownskillEnabled do
                    task.wait(0.1)
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local closest, closestDist = nil, 10
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                                local hm = plr.Character:FindFirstChildOfClass("Humanoid")
                                if tr and hm then
                                    local d = (root.Position - tr.Position).Magnitude
                                    if d <= closestDist and hm.Health > 20 then
                                        closestDist = d; closest = plr.Character
                                    end
                                end
                            end
                        end
                        if closest then remote:FireServer() end
                    end
                end
            end)
        end
    end
})

-- ── Feature Cheat ──
killerTab:Section({ Title = "Feature Cheat", Icon = "bug" })

local noFlashlightEnabled = false
killerTab:Toggle({
    Title = "No Flashlight", Desc = "Prevents blind from using flash", Value = false,
    Callback = function(state) noFlashlightEnabled = state end
})

-- No Flashlight loop (1 loop เท่านั้น ไม่ซ้ำ)
task.spawn(function()
    while true do
        task.wait(0.5)
        if noFlashlightEnabled then
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                for _, desc in pairs(pg:GetDescendants()) do
                    if desc:IsA("GuiObject") and desc.Name == "Blind" then desc:Destroy() end
                end
            end
        end
    end
end)

local destroyPalletwrong = false
killerTab:Toggle({
    Title = "Remove Palletwrong (All)", Desc = "Removes all Palletwrong objects around the map", Value = false,
    Callback = function(v)
        destroyPalletwrong = v
        if v then
            task.spawn(function()
                while destroyPalletwrong do
                    task.wait(1)
                    for _, desc in ipairs(Workspace:GetDescendants()) do
                        if desc:IsA("Model") and desc.Name == "Palletwrong" then desc:Destroy() end
                    end
                end
            end)
        end
    end
})

killerTab:Button({
    Title    = "Fix Cam (3rd Person Camera)",
    Desc     = "Changes the camera from first person to third person view",
    Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid  = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Camera.CameraType    = Enum.CameraType.Custom
            Camera.CameraSubject = humanoid
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 400
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            local head = character:FindFirstChild("Head")
            if head then head.Anchored = false end
        end
    end
})

-- ====================== PLAYER TAB ======================
local speedEnabled   = false
local flyNoclipSpeed = Config:Get("SpeedWalk", 3)
local NoClipEnabled  = Config:Get("NoClipEnabled", false)
local speedConnection, noclipConnection

PlayerTab:Section({ Title = "Feature Player", Icon = "rabbit" })
PlayerTab:Slider({
    Title = "Set Speed (Legit = 3)",
    Value = { Min = 1, Max = 677, Value = flyNoclipSpeed },
    Step  = 1,
    Callback = function(val)
        flyNoclipSpeed = val; Config:Set("flyNoclipSpeed", val); Config:Save()
    end
})
PlayerTab:Toggle({
    Title = "Enable Speed", Desc = "Adjusts your character movement speed using a slider", Value = false,
    Callback = function(v)
        speedEnabled = v
        if speedEnabled then
            if speedConnection then speedConnection:Disconnect() end
            speedConnection = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local hrp_ = char:FindFirstChild("HumanoidRootPart")
                    local hum  = char:FindFirstChild("Humanoid")
                    if hrp_ and hum and hum.MoveDirection.Magnitude > 0 then
                        hrp_.CFrame = hrp_.CFrame + hum.MoveDirection * flyNoclipSpeed * 0.004
                    end
                end
            end)
        else
            if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        end
    end
})

PlayerTab:Section({ Title = "Feature Power", Icon = "flame" })
PlayerTab:Toggle({
    Title = "No Clip", Desc = "Allows your character to walk through walls and object", Value = NoClipEnabled,
    Callback = function(state)
        NoClipEnabled = state; Config:Set("NoClipEnabled", state); Config:Save()
        if state then
            if noclipConnection then noclipConnection:Disconnect() end
            noclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end
})

-- No Fall
local NoFallEnabled = false
local FallRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("Fall")

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if NoFallEnabled and self == FallRemote and method == "FireServer" then return nil end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

PlayerTab:Toggle({
    Title = "No Fall (Beta)", Desc = "Prevents movement slowdown after falling from heights", Value = false,
    Callback = function(v) NoFallEnabled = v end
})

-- ====================== TELEPORT TAB ======================
local function getCFrame(obj)
    if obj:IsA("BasePart") then return obj.CFrame
    elseif obj:IsA("Model") then
        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        return part and part.CFrame
    end
end

local function getAllGenerators()
    local list, count = {}, 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Generator" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            count += 1
            table.insert(list, { Name = "Generator " .. count, Object = obj })
        end
    end
    return list
end

TeleportTab:Section({ Title = "Teleport: Place", Icon = "map" })
local SelectedPlace
TeleportTab:Dropdown({
    Title = "Select Place", Values = {"Lobby", "Game"},
    Callback = function(v) SelectedPlace = v end
})
TeleportTab:Button({
    Title    = "Teleport",
    Desc     = "Teleports your character to the place selected",
    Callback = function()
        if SelectedPlace == "Lobby" then
            local spawn = Workspace:FindFirstChild("SpawnLocation")
            if spawn and LocalPlayer.Character then
                LocalPlayer.Character:PivotTo(spawn.CFrame + Vector3.new(0, 1, 0))
            end
        elseif SelectedPlace == "Game" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Weapon") then
                    LocalPlayer.Character:PivotTo(p.Character.PrimaryPart.CFrame * CFrame.new(0, 0, 200))
                    break
                end
            end
        end
    end
})

TeleportTab:Section({ Title = "Teleport: Generator", Icon = "zap" })
local generatorList = getAllGenerators()
local GenTarget

local GenDropdown = TeleportTab:Dropdown({
    Title  = "Select Generator",
    Values = (function()
        local t = {}
        for _, g in ipairs(generatorList) do table.insert(t, g.Name) end
        return t
    end)(),
    Callback = function(v)
        for _, g in ipairs(generatorList) do
            if g.Name == v then GenTarget = g.Object end
        end
    end
})

TeleportTab:Button({
    Title    = "Teleport",
    Desc     = "Teleports your character to the generator selected",
    Callback = function()
        if GenTarget then LocalPlayer.Character:PivotTo(getCFrame(GenTarget)) end
    end
})
TeleportTab:Button({
    Title    = "Refresh Generator",
    Desc     = "Updates the dropdown with newly spawned generators on the map",
    Callback = function()
        generatorList = getAllGenerators()
        local t = {}
        for _, g in ipairs(generatorList) do table.insert(t, g.Name) end
        GenDropdown:Update(t)
    end
})

TeleportTab:Section({ Title = "Teleport: Refresh", Icon = "loader" })
TeleportTab:Button({
    Title    = "Refresh All",
    Desc     = "Updates the dropdown with newly spawned objects on the map",
    Callback = function()
        generatorList = getAllGenerators()
        if GenDropdown then
            local t = {}
            for _, g in ipairs(generatorList) do table.insert(t, g.Name) end
            GenDropdown:Update(t)
        end
        GenTarget = nil
        print("[DYHUB] Refresh All completed")
    end
})

-- ====================== SETTINGS TAB ======================
Main3:Section({ Title = "Save Config", Icon = "save" })
Main3:Button({
    Title    = "Save Config (NOW)",
    Desc     = "Saves all current settings to config file immediately.",
    Callback = function()
        Config:Save()
        WindUI:Notify({ Title = "Config Saved", Content = "Config saved successfully!", Duration = 2, Icon = "save" })
    end
})

local AutoSaveEnabled = Config:Get("AutoSaveEnabled", true)
local AutoSaveDelay   = Config:Get("AutoSaveDelay",   15)

Main3:Toggle({
    Title = "Auto Save Config", Value = AutoSaveEnabled,
    Desc  = "Automatically saves your config at the set interval.",
    Callback = function(state)
        AutoSaveEnabled = state; Config:Set("AutoSaveEnabled", state); Config:Save()
        if state then Config:AutoSave(AutoSaveDelay) else Config:AutoSave(0) end
    end
})
Main3:Input({
    Title = "Delay Save Config", Value = tostring(AutoSaveDelay), Placeholder = "Default: 15",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 then
            AutoSaveDelay = num; Config:Set("AutoSaveDelay", num); Config:Save()
            if AutoSaveEnabled then Config:AutoSave(num) end
        else
            warn("[DYHUB] Invalid delay value!")
        end
    end
})

Main3:Section({ Title = "Server Status", Icon = "server" })
Main3:Button({
    Title    = "Serverhop",
    Desc     = "Teleports you to a different random server of this game.",
    Callback = function()
        local servers = {}
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            ))
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end
        end
        if #servers > 0 then
            WindUI:Notify({ Title = "Serverhop", Content = "Teleporting to another server...", Duration = 2, Icon = "server" })
            task.wait(1)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            WindUI:Notify({ Title = "Serverhop Failed", Content = "No available servers found.", Duration = 3, Icon = "alert-triangle" })
        end
    end
})
Main3:Button({
    Title    = "Rejoin",
    Desc     = "Rejoins the current game server.",
    Callback = function()
        WindUI:Notify({ Title = "Rejoin", Content = "Rejoining server...", Duration = 2, Icon = "refresh-cw" })
        task.wait(1)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

-- ====================== INFORMATION TAB ======================
local Info = InfoTab

if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

Info:Section({ Title = "Latest Update", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({
    Title = "Update: 05/22/2026",
    Desc  = "- [ Rework ] Full ESP Core Rebuilt\n- [ New ] ESP Distance (0-5000)\n- [ Fixed ] ESP Gate, Hook, Pallet, Window, Patient\n- [ Fixed ] ESP Distance Check for all object types\n- [ Fixed ] Duplicate ESP / Memory Leak\n- [ Fixed ] Character Respawn ESP refresh\n- [ Optimized ] FullBright / NoFog now use Connection not while loop\n- [ Optimized ] AntiAFK now uses task.spawn properly\n- [ Fixed ] Speed Toggle uses correct character reference\n- [ Fixed ] Grab keybind pcall protected\n- [ Improved ] Config Save/Load stability\n- [ Improved ] Service caching",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})
Info:Divider()

ui.Creator.Request = function(requestData)
    local success, result = pcall(function()
        if HttpService.RequestAsync then
            local response = HttpService:RequestAsync({
                Url = requestData.Url, Method = requestData.Method or "GET", Headers = requestData.Headers or {}
            })
            return { Body = response.Body, StatusCode = response.StatusCode, Success = response.Success }
        else
            local body = HttpService:GetAsync(requestData.Url)
            return { Body = body, StatusCode = 200, Success = true }
        end
    end)
    if success then return result else error("HTTP Request failed: " .. tostring(result)) end
end

local InviteCode = "jWNDPNMmyB"
local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local function LoadDiscordInfo()
    local success, result = pcall(function()
        return HttpService:JSONDecode(ui.Creator.Request({
            Url = DiscordAPI, Method = "GET",
            Headers = { ["User-Agent"] = "RobloxBot/1.0", ["Accept"] = "application/json" }
        }).Body)
    end)
    if success and result and result.guild then
        local DiscordInfo = Info:Paragraph({
            Title = result.guild.name,
            Desc  = ' <font color="#52525b">●</font> Member Count : ' .. tostring(result.approximate_member_count) ..
                    '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(result.approximate_presence_count),
            Image = "https://cdn.discordapp.com/icons/" .. result.guild.id .. "/" .. result.guild.icon .. ".png?size=1024",
            ImageSize = 42,
        })
        Info:Button({
            Title = "Update Info",
            Callback = function()
                local ok, r = pcall(function()
                    return HttpService:JSONDecode(ui.Creator.Request({ Url = DiscordAPI, Method = "GET" }).Body)
                end)
                if ok and r and r.guild then
                    DiscordInfo:SetDesc(
                        ' <font color="#52525b">●</font> Member Count : ' .. tostring(r.approximate_member_count) ..
                        '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(r.approximate_presence_count)
                    )
                    WindUI:Notify({ Title = "Discord Info Updated", Content = "Refreshed!", Duration = 2, Icon = "refresh-cw" })
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
        Info:Paragraph({
            Title = "Error fetching Discord Info", Desc = "Unable to load Discord information.",
            Image = "triangle-alert", ImageSize = 26, Color = "Red",
        })
    end
end

LoadDiscordInfo()

Info:Divider()
Info:Section({ Title = "DYHUB Information", TextXAlignment = "Center", TextSize = 17 })
Info:Divider()
Info:Paragraph({ Title = "Main Owner", Desc = "@dyumraisgoodguy#8888", Image = "rbxassetid://119789418015420", ImageSize = 30 })
Info:Paragraph({
    Title = "Social", Desc = "Copy link social media for follow!",
    Image = "rbxassetid://104487529937663", ImageSize = 30,
    Buttons = {{ Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://guns.lol/DYHUB") end }}
})
Info:Paragraph({
    Title = "Discord", Desc = "Join our discord for more scripts!",
    Image = "rbxassetid://104487529937663", ImageSize = 30,
    Buttons = {{ Icon = "copy", Title = "Copy Link", Callback = function() setclipboard("https://discord.gg/jWNDPNMmyB") end }}
})

-- ====================== AUTO RESTORE ON LOAD ======================
if NoClipEnabled then
    noclipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

print("[DYHUB] " .. version .. " " .. ver .. " loaded successfully!")
print("[DYHUB] Config system active | Auto saving every " .. tostring(AutoSaveDelay) .. " seconds")
