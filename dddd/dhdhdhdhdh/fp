local fired = false

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    fired = false
end)

getgenv().fireclickdetector = function(object, distance, event)
    if not fired then
        fired = true
        game:GetService("VirtualInputManager"):SendKeyEvent(true, 101, false, peeky)
    end

    if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool") then        game:GetService("Players").LocalPlayer.Character.Humanoid:UnequipTools()
    end

    local click_detector = object:FindFirstChild("ClickDetector") or object
    local old_cd_parent = click_detector.Parent

    local stub_part = Instance.new("Part")
    stub_part.Transparency = 1
    stub_part.Size = Vector3.new(30, 30, 30)
    stub_part.Anchored = true
    stub_part.CanCollide = false
    stub_part.Parent = workspace

    click_detector.Parent = stub_part
    click_detector.MaxActivationDistance = math.huge

    local connection = game:GetService("RunService").Heartbeat:Connect(function()
        stub_part.CFrame = workspace.Camera.CFrame * CFrame.new(0, 0, -20) * CFrame.new(workspace.Camera.CFrame.LookVector)       game:GetService("VirtualUser"):ClickButton1(Vector2.new(20, 20), workspace:FindFirstChildOfClass("Camera").CFrame)
    end)
    click_detector.MouseClick:Once(function()
        connection:Disconnect()
        click_detector.Parent = old_cd_parent
        stub_part:Destroy()
    end)

    task.delay(3, function()
        connection:Disconnect()
        click_detector.Parent = old_cd_parent
        stub_part:Destroy()
    end)
end
