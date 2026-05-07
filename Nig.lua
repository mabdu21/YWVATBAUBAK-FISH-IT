-- speed

repeat task.wait() until game:IsLoaded()

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(67)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

if setfpscap then
    setfpscap(1000000)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "dsc.gg/dyhub",
        Text = "Anti AFK & FPS Unlocked!",
        Duration = 2,
        Button1 = "Okay"
    })
    warn("Anti AFK Enabled & FPS Unlocked!")
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "dsc.gg/dyhub",
        Text = "Anti AFK Enabled (FPS Unlock Not Supported)",
        Duration = 2,
        Button1 = "Okay"
    })
    warn("Anti AFK Enabled but setfpscap is missing.")
end

local cfg = {
    f = {["Auto Farm"] = false, ["Auto Rebirth"] = false, ["Auto Bonus"] = false, ["Auto Collect"] = false},
    s = {sp = 1.5, spfn = 0.2, rs = 3, chk = 20},
    p = {st = Vector3.new(700,3,236), wt = Vector3.new(677,-7,235), fn = Vector3.new(700,3,235), tx = 605}
}

local p,ts,rs,w = game:GetService("Players").LocalPlayer, game:GetService("TweenService"), game:GetService("ReplicatedStorage"), workspace
local act,tid = nil,0
local farm_count = 0
local is_collecting = false
local last_collect = 0

-- [[ UI Setup ]] --
local old = game:GetService("CoreGui"):FindFirstChild("DYHUB_AI_BTW")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui", game:GetService("CoreGui")) sg.Name = "DYHUB_AI_BTW"
local mf = Instance.new("Frame", sg) 
mf.Size = UDim2.new(0,220,0,340) mf.Position = UDim2.new(0.5,-110,0.5,-170) 
mf.BackgroundColor3 = Color3.fromRGB(10,10,10) mf.Active = true mf.Draggable = true
Instance.new("UICorner", mf).CornerRadius = UDim.new(0,12)

local tl = Instance.new("TextLabel", mf) 
tl.Size = UDim2.new(1,0,0,45) tl.Text = "kalb (nigga hub jk)" tl.TextColor3 = Color3.fromRGB(0, 255, 180) 
tl.Font = "GothamBold" tl.TextSize = 16 tl.BackgroundTransparency = 1

local logL = Instance.new("TextLabel", mf)
logL.Size = UDim2.new(0.9,0,0,40) logL.Position = UDim2.new(0.05,0,0,45)
logL.Text = "Welcome nigga, " .. p.Name
logL.TextColor3 = Color3.fromRGB(255, 255, 255)
logL.Font = "GothamMedium" logL.TextSize = 11 logL.BackgroundTransparency = 0.1
logL.BackgroundColor3 = Color3.fromRGB(20,20,20)
logL.TextWrapped = true
Instance.new("UICorner", logL).CornerRadius = UDim.new(0,8)

-- [[ Your Custom Functions ]] --
local function parse_val(str)
    if not str then return 0 end
    str = tostring(str):upper():gsub(",", ""):match("[%d%.%a]+") or ""
    local sfx = {K = 1e3, M = 1e6, B = 1e9, T = 1e12}
    local val, char = str:match("([%d%.]+)(%a?)")
    if val and char and sfx[char] then return tonumber(val) * sfx[char] end
    return tonumber(val) or 0
end

local function click_btn(btn)
    if btn:IsA("ImageButton") or btn:IsA("TextButton") then
        if firesignal then 
            firesignal(btn.MouseButton1Click) 
            firesignal(btn.Activated) 
        else 
            btn:Activated() 
        end
    end
end

-- [[ Utility Functions ]] --
local function say(msg)
    ts:Create(logL, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    task.wait(0.15)
    logL.Text = msg
    ts:Create(logL, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
end

local function tw(pos, dur)
    local c = p.Character local r = c and c:FindFirstChild("HumanoidRootPart")
    if r and c.Humanoid.Health > 0 then
        if act then act:Cancel() end
        act = ts:Create(r, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = (typeof(pos) == "CFrame" and pos or CFrame.new(pos))})
        act:Play()
        repeat task.wait() until (act.PlaybackState == Enum.PlaybackState.Completed) or (not cfg.f["Auto Farm"] and not is_collecting) or (c.Humanoid.Health <= 0)
        return true
    end
    return false
end

-- [[ Logic Modules ]] --
local function do_collect()
    if is_collecting then return end
    is_collecting = true
    say("Collecting nigga rewards...")
    local myPlot = nil
    for i = 1, 5 do
        local path = w.Plots:FindFirstChild("Plot"..i)
        if path and path:FindFirstChild("Decorations", true) then
            local label = path:FindFirstChild("PlotOwner", true) and path:FindFirstChild("OwnerGUI", true) and path:FindFirstChild("TextLabel", true)
            if label and label.Text:lower():find(p.Name:lower()) then myPlot = path break end
        end
    end
    if myPlot and myPlot:FindFirstChild("Buttons") then
        local r = p.Character:FindFirstChild("HumanoidRootPart")
        for i = 1, 30 do
            if not cfg.f["Auto Collect"] or p.Character.Humanoid.Health <= 0 then break end
            local slot = myPlot.Buttons:FindFirstChild("Slot"..i)
            if slot and slot:FindFirstChild("ButtonGUI") then
                say("Teleporting to Nigga Slot "..i)
                r.CFrame = slot.CFrame * CFrame.new(0, 3, 0)
                task.wait(0.1)
                rs.Shared.Packages.Network.rev_B_Collect:FireServer(i)
                task.wait(0.1)
            end
        end
        say("Collection done!")
        last_collect = tick()
    end
    is_collecting = false
    farm_count = 0
end

function run()
    tid = tid + 1 local mid = tid
    while cfg.f["Auto Farm"] and mid == tid do
        if not p.Character or p.Character.Humanoid.Health <= 0 then
            say("Waiting for nigga respawn...") p.CharacterAdded:Wait() task.wait(2) continue 
        end
        if cfg.f["Auto Collect"] and farm_count >= 2 then do_collect() end
        pcall(function()
            say("Farm Cycle #"..(farm_count + 1))
            tw(cfg.p.st, cfg.s.sp)
            rs.Shared.Packages.Network.rev_KickEvent:FireServer(67)
            local ok = false
            for i=1, cfg.s.chk*2 do
                local g = p.PlayerGui:FindFirstChild("HUD")
                if g and g.Run.Visible then ok = true break end
                task.wait(0.5)
            end
            if ok then
                say("Escaping Nigga Wave...") tw(cfg.p.wt, cfg.s.sp)
                repeat task.wait(0.5)
                    local wv = w:FindFirstChild("Waves")
                    local m = wv and wv:FindFirstChildOfClass("Model")
                    local rp = m and (m:FindFirstChild("RootPart") or m:FindFirstChildWhichIsA("BasePart"))
                until not cfg.f["Auto Farm"] or is_collecting or (rp and rp.Position.X >= cfg.p.tx) or p.Character.Humanoid.Health <= 0
                if not is_collecting and p.Character.Humanoid.Health > 0 then
                    say("Nigga Survived! Resetting position.") tw(cfg.p.fn, cfg.s.spfn)
                    farm_count = farm_count + 1
                end
            end
        end)
    end
end

-- [[ Background Monitor ]] --
task.spawn(function()
    while task.wait(1) do
        -- Standalone Collect
        if cfg.f["Auto Collect"] and not cfg.f["Auto Farm"] and (tick() - last_collect >= 15) then
            do_collect()
        end
        
        -- Auto Bonus (Using click_btn)
        if cfg.f["Auto Bonus"] then
            pcall(function()
                local kick = p.PlayerGui:FindFirstChild("KickUpgrades")
                if kick then
                    for _, v in pairs(kick:GetChildren()) do
                        if v.Name == "Bonus" and v.Visible then 
                            say("Bonus nigga! Clicking...")
                            click_btn(v)
                        end
                    end
                end
            end)
        end

        -- Auto Rebirth (Using parse_val)
        if cfg.f["Auto Rebirth"] then
            pcall(function()
                local hud = p.PlayerGui:FindFirstChild("HUD")
                local rbFrame = p.PlayerGui:FindFirstChild("Frames") and p.PlayerGui.Frames:FindFirstChild("Rebirth")
                if hud and rbFrame then
                    local power = parse_val(hud.BottomLeft.KickLevel.TextLabel.Text)
                    local _, reqStr = rbFrame.Progress.Title.Text:match("([%d%.%a]+)/([%d%.%a]+)")
                    local req = parse_val(reqStr)
                    if power >= req and req > 0 then
                        say("Rebirth Ready nigga! Ascending...")
                        rs.Shared.Packages.Network.rev_RebirthRequest:FireServer()
                    end
                end
            end)
        end
    end
end)

-- [[ UI Buttons ]] --
local function create_btn(name, pos, key)
    local b = Instance.new("TextButton", mf) 
    b.Size = UDim2.new(0.85,0,0,35) b.Position = pos b.Text = name..": OFF" 
    b.BackgroundColor3 = Color3.fromRGB(30,30,30) b.TextColor3 = Color3.new(1,1,1)
    b.Font = "Gotham" b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(function()
        cfg.f[key] = not cfg.f[key]
        b.Text = name..": "..(cfg.f[key] and "ACTIVE" or "OFF")
        b.BackgroundColor3 = cfg.f[key] and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(30,30,30)
        say(name .. (cfg.f[key] and " is now ON" or " is now OFF"))
        if key == "Auto Farm" and cfg.f[key] then task.spawn(run) end
    end)
end

create_btn("Auto Farm", UDim2.new(0.075,0,0,100), "Auto Farm")
create_btn("Auto Rebirth", UDim2.new(0.075,0,0,145), "Auto Rebirth")
create_btn("Auto Bonus", UDim2.new(0.075,0,0,190), "Auto Bonus")
create_btn("Auto Collect", UDim2.new(0.075,0,0,235), "Auto Collect")

-- Support Label
local dcL = Instance.new("TextButton", mf)
dcL.Size = UDim2.new(1,0,0,25) dcL.Position = UDim2.new(0,0,1,-30)
dcL.Text = "dsc.gg/dyhub (Copy Link)" dcL.TextColor3 = Color3.fromRGB(88, 101, 242)
dcL.Font = "Gotham" dcL.TextSize = 10 dcL.BackgroundTransparency = 1
dcL.MouseButton1Click:Connect(function()
    setclipboard("nigga credit script by https://dsc.gg/dyhub")
    say("Support link copied!")
end)
