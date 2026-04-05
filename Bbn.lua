--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// REMOTE
local remote = ReplicatedStorage:WaitForChild("Events")
    :WaitForChild("CollectableObjects")
    :WaitForChild("Collect")

local folder = workspace:WaitForChild("_LocalCollectableObjects")

--// SETTINGS
local BASE_DELAY = 0.001
local MAX_WORKERS = 1000 -- จำนวนยิงพร้อมกัน (ปรับได้)
local MAX_QUEUE = 1234

--// STATE
local enabled = false
local queue = {}
local processing = false
local activeWorkers = 0
local seen = {}

--// PRIORITY
local function getPriority(value)
    if value == 501 then return 1 end
    if value == 250 then return 2 end
    if value == 50 then return 3 end
    return 999
end

--// ADD
local function addToQueue(obj)
    if not enabled then return end
    if not obj or not obj.Name then return end
    if seen[obj] then return end

    local first, second = string.match(obj.Name, "^(%d+)_(%d+)$")
    if not first then return end

    local value = 0
    pcall(function()
        value = tonumber(obj:FindFirstChild("Circle")
            and obj.Circle:FindFirstChild("Stats")
            and obj.Circle.Stats:FindFirstChild("Value")
            and obj.Circle.Stats.Value.Text) or 0
    end)

    seen[obj] = true

    table.insert(queue, {
        obj = obj,
        id1 = first,
        id2 = tonumber(second),
        value = value
    })

    -- limit queue กัน lag
    if #queue > MAX_QUEUE then
        table.remove(queue, 1)
    end
end

--// SORT
local function sortQueue()
    table.sort(queue, function(a, b)
        return getPriority(a.value) < getPriority(b.value)
    end)
end

--// WORKER
local function worker()
    activeWorkers += 1

    while enabled do
        local data

        if #queue > 0 then
            sortQueue()
            data = table.remove(queue, 1)
        end

        if data then
            pcall(function()
                remote:FireServer(data.id1, data.id2)
            end)

            -- adaptive delay (คิวเยอะ = ยิงถี่ขึ้นนิด)
            local delay = BASE_DELAY
            if #queue > 50 then
                delay = BASE_DELAY * 0.5
            end

            task.wait(delay)
        else
            task.wait(0.05)
        end
    end

    activeWorkers -= 1
end

--// START
local function startCollect()
    -- preload
    for _, obj in ipairs(folder:GetChildren()) do
        addToQueue(obj)
    end

    -- spawn workers
    for i = 1, MAX_WORKERS do
        task.spawn(worker)
    end
end

--// NEW OBJECT
folder.ChildAdded:Connect(function(obj)
    if enabled then
        addToQueue(obj)
    end
end)

--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "DYHUB"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 230, 0, 110)
main.Position = UDim2.new(0.5, -115, 0.5, -55)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.Active = true
main.BorderSizePixel = 0

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "IF LAG JUST REJOIN"
title.TextColor3 = Color3.fromRGB(200, 200, 200)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(0.8, 0, 0, 45)
toggle.Position = UDim2.new(0.1, 0, 0.5, -5)
toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggle.Text = "OFF"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 16

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled

    if enabled then
        toggle.Text = "ON (script by ai)"
        toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
        table.clear(queue)
        table.clear(seen)
        startCollect()
    else
        toggle.Text = "OFF (credit .gg/dyhub)"
        toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        table.clear(queue)
        table.clear(seen)
    end
end)

--// DRAG
local dragging = false
local dragInput, startPos, startFramePos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startPos = input.Position
        startFramePos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - startPos
        main.Position = UDim2.new(
            startFramePos.X.Scale,
            startFramePos.X.Offset + delta.X,
            startFramePos.Y.Scale,
            startFramePos.Y.Offset + delta.Y
        )
    end
end)
