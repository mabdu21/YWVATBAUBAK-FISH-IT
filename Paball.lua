repeat task.wait() until game:IsLoaded()

-- FPS Unlock
if setfpscap then
    setfpscap(1000000)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "dsc.gg/dyhub",
        Text = "FPS Unlocked!",
        Duration = 2,
        Button1 = "Okay"
    })
    warn("FPS Unlocked!")
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "dsc.gg/dyhub",
        Text = "Your exploit does not support setfpscap.",
        Duration = 2,
        Button1 = "Okay"
    })
    warn("Your exploit does not support setfpscap.")
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

player.CharacterAdded:Connect(function(char)
	character = char
end)

local function getRoot()
	return character:WaitForChild("HumanoidRootPart")
end

-- VARIABLES
local BrickFarmRunning = false
local PizzaFarmRunning = false
local Selling = false

-- REMOTES
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SellRemote = Remotes:WaitForChild("SellItem")

local DeliverRemote = ReplicatedStorage:WaitForChild("DeliverItem")
local RegisterRemote = ReplicatedStorage:WaitForChild("RegisterNPC")

-- MAP
local BrickFolder = Workspace:WaitForChild("BrickSystem"):WaitForChild("Bricks")

local NPC = Workspace.NPCs["\224\184\163\224\184\177\224\184\154\224\184\139\224\184\183\224\185\137\224\184\173\224\184\130\224\184\173\224\184\135\224\184\156\224\184\180\224\184\148\224\184\129\224\184\143\224\184\171\224\184\161\224\184\178\224\184\162"]

local PizzaJobNPC = Workspace.NPCs["\224\184\158\224\184\153\224\184\177\224\184\129\224\184\135\224\184\178\224\184\153\224\184\163\224\185\137\224\184\178\224\184\153\224\184\158\224\184\180\224\184\139\224\184\139\224\185\136\224\184\178"]

local ITEM_NAME = "\224\184\155\224\184\185\224\184\153"

---------------------------------------------------
-- PROMPT SYSTEM (ANTI BUG)
---------------------------------------------------

local function firePrompt(prompt)

	if not prompt then return false end

	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 50

	for i = 1,10 do

		if not prompt.Parent then
			return true
		end

		fireproximityprompt(prompt)

		task.wait(0.05)

	end

	return true

end

local function waitPrompt(model)

	for i = 1,20 do

		local prompt = model:FindFirstChildWhichIsA("ProximityPrompt",true)

		if prompt then
			return prompt
		end

		task.wait()

	end

end

---------------------------------------------------
-- SELL PART
---------------------------------------------------

local SellPart

local function getSellPart()

	if SellPart then
		return SellPart
	end

	local part = Instance.new("Part")
	part.Size = Vector3.new(6,1,6)
	part.Anchored = true
	part.Transparency = 1
	part.CanCollide = true

	part.CFrame = NPC.HumanoidRootPart.CFrame * CFrame.new(0,8,0)
	part.Parent = Workspace

	SellPart = part

	return part

end

---------------------------------------------------
-- WINDUI
---------------------------------------------------

local Window = WindUI:CreateWindow({
	  Title = "DYHUB",
	  IconThemed = true,
	  Icon = "rbxassetid://104487529937663",
  	Author = "PABALL - ป๋าบอล [BETA] | Free Version",
  	Folder = "DYHUB",
    Size = UDim2.fromOffset(500, 350),
    Transparent = true,
    Theme = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.K)

pcall(function()
    Window:Tag({
        Title = "TEST",
        Color = Color3.fromHex("#30ff6a")
    })
end)

Window:EditOpenButton({
    Title = "DYHUB - Open",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 255, 255)),
    Draggable = true,
})

local InfoTab = Window:Tab({ Title = "Information", Icon = "info" })
local MainDivider = Window:Divider()
local Main = Window:Tab({
	Title="Main",
	Icon="rocket"
})

Window:SelectTab(1)

Main:Section({
	Title="Auto Farm"
})

---------------------------------------------------
-- BRICK FARM
---------------------------------------------------

local function collectBrick(brick)

	local root = getRoot()

	local part = brick:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	root.CFrame = part.CFrame + Vector3.new(0,3,0)

	task.wait(0.2)

	local prompt = waitPrompt(brick)

	if prompt then
		firePrompt(prompt)
	end

	repeat
		task.wait()
	until not brick.Parent or not BrickFarmRunning

end

local function sellItems()

	Selling = true

	local root = getRoot()
	local sellPart = getSellPart()

	root.CFrame = sellPart.CFrame + Vector3.new(0,3,0)

	task.wait(0.2)

	repeat

		SellRemote:FireServer(
			ITEM_NAME,
			NPC.Name
		)

		task.wait(0.1)

	until not player.Backpack:FindFirstChild(ITEM_NAME)

	Selling = false

end

Main:Toggle({

	Title="จกปูน",

	Callback=function(state)

		BrickFarmRunning = state

		if state then

			task.spawn(function()

				while BrickFarmRunning do

					if Selling then
						task.wait()
						continue
					end

					local bricks = BrickFolder:GetChildren()

					if #bricks > 0 then

						for _,brick in ipairs(bricks) do

							if not BrickFarmRunning then break end
							if brick.Name ~= "BrickModel" then continue end

							collectBrick(brick)

						end

					else

						sellItems()

					end

					task.wait()

				end

			end)

		end

	end

})

---------------------------------------------------
-- PIZZA FARM
---------------------------------------------------

local function joinPizza()

	local root = getRoot()

	root.CFrame = PizzaJobNPC.HumanoidRootPart.CFrame + Vector3.new(0,3,0)

	task.wait(0.3)

	local prompt = waitPrompt(PizzaJobNPC)

	if prompt then
		firePrompt(prompt)
	end

	task.wait(0.3)

end

Main:Toggle({

	Title="ส่งพิซซ่า",

	Callback=function(state)

		PizzaFarmRunning = state

		if state then

			task.spawn(function()

				local root = getRoot()
				local oldPos = root.CFrame

				-- วาร์ปไปกดงานครั้งเดียว
				root.CFrame = PizzaJobNPC.HumanoidRootPart.CFrame + Vector3.new(0,3,0)

				task.wait(0.25)

				joinPizza()

				task.wait(0.25)

				-- วาร์ปกลับ
				root.CFrame = oldPos

				while PizzaFarmRunning do

					RegisterRemote:FireServer("MY")
					task.wait()

					DeliverRemote:FireServer("MY")

					task.wait(0.1)

				end

			end)

		end

	end

})

local wsp = ""

local event = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SpawnCar")

local car = {"DragBike","HP4","Hayabusa","R1","R15","R3","S1000RR","Wave110","ZR"}

Main:Section({
	Title="Vehicle"
})

Main:Dropdown({
    Title = "เลือกรถ",
    Values = car,
    Multi = false,
    Callback = function(v)
        wsp = v
    end
})

Main:Button({
    Title = "เสกรถ",
    Callback = function()
        if wsp ~= "" then
            event:FireServer(wsp)
        else
            warn("Please select a car first")
        end
    end
})

Info = InfoTab

if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end

-- Define the Request function that mimics ui.Creator.Request
ui.Creator.Request = function(requestData)
    local HttpService = game:GetService("HttpService")
    
    -- Try different HTTP methods
    local success, result = pcall(function()
        if HttpService.RequestAsync then
            -- Method 1: Use RequestAsync if available
            local response = HttpService:RequestAsync({
                Url = requestData.Url,
                Method = requestData.Method or "GET",
                Headers = requestData.Headers or {}
            })
            return {
                Body = response.Body,
                StatusCode = response.StatusCode,
                Success = response.Success
            }
        else
            -- Method 2: Fallback to GetAsync
            local body = HttpService:GetAsync(requestData.Url)
            return {
                Body = body,
                StatusCode = 200,
                Success = true
            }
        end
    end)
    
    if success then
        return result
    else
        error("HTTP Request failed: " .. tostring(result))
    end
end

-- Remove this line completely: Info = InfoTab
-- The Info variable is already correctly set above

local InviteCode = "jWNDPNMmyB"
local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local function LoadDiscordInfo()
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(ui.Creator.Request({
            Url = DiscordAPI,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "RobloxBot/1.0",
                ["Accept"] = "application/json"
            }
        }).Body)
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
                    return game:GetService("HttpService"):JSONDecode(ui.Creator.Request({
                        Url = DiscordAPI,
                        Method = "GET",
                    }).Body)
                end)

                if updated and updatedResult and updatedResult.guild then
                    DiscordInfo:SetDesc(
                        ' <font color="#52525b">●</font> Member Count : ' .. tostring(updatedResult.approximate_member_count) ..
                        '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(updatedResult.approximate_presence_count)
                    )
                    
                    WindUI:Notify({
                        Title = "Discord Info Updated",
                        Content = "Successfully refreshed Discord statistics",
                        Duration = 2,
                        Icon = "refresh-cw",
                    })
                else
                    WindUI:Notify({
                        Title = "Update Failed",
                        Content = "Could not refresh Discord info",
                        Duration = 3,
                        Icon = "alert-triangle",
                    })
                end
            end
        })

        Info:Button({
            Title = "Copy Discord Invite",
            Callback = function()
                setclipboard("https://discord.gg/" .. InviteCode)
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "Discord invite copied to clipboard",
                    Duration = 2,
                    Icon = "clipboard-check",
                })
            end
        })
    else
        Info:Paragraph({
            Title = "Error fetching Discord Info",
            Desc = "Unable to load Discord information. Check your internet connection.",
            Image = "triangle-alert",
            ImageSize = 26,
            Color = "Red",
        })
        print("Discord API Error:", result) -- Debug print
    end
end

LoadDiscordInfo()

Info:Divider()
Info:Section({ 
    Title = "DYHUB Information",
    TextXAlignment = "Center",
    TextSize = 17,
})
Info:Divider()

local Owner = Info:Paragraph({
    Title = "Main Owner",
    Desc = "@dyumraisgoodguy#8888",
    Image = "rbxassetid://119789418015420",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 0,
    Locked = false,
})

local Social = Info:Paragraph({
    Title = "Social",
    Desc = "Copy link social media for follow!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 0,
    Locked = false,
    Buttons = {
        {
            Icon = "copy",
            Title = "Copy Link",
            Callback = function()
                setclipboard("https://guns.lol/DYHUB")
                print("Copied social media link to clipboard!")
            end,
        }
    }
})

local Discord = Info:Paragraph({
    Title = "Discord",
    Desc = "Join our discord for more scripts!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 0,
    Locked = false,
    Buttons = {
        {
            Icon = "copy",
            Title = "Copy Link",
            Callback = function()
                setclipboard("https://discord.gg/jWNDPNMmyB")
                print("Copied discord link to clipboard!")
            end,
        }
    }
})
