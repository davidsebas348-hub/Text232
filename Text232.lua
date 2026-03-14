--------------------------------------------------
-- TOGGLE
--------------------------------------------------
if getgenv().AUTO_SPACE then
	getgenv().AUTO_SPACE = false

	if getgenv().AUTO_SPACE_CONNS then
		for _,c in pairs(getgenv().AUTO_SPACE_CONNS) do
			pcall(function()
				c:Disconnect()
			end)
		end
	end

	getgenv().AUTO_SPACE_CONNS = {}
	return
end

getgenv().AUTO_SPACE = true
getgenv().AUTO_SPACE_CONNS = {}
--------------------------------------------------

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local live = workspace:WaitForChild("Live")

local spaceHeld = false
local releaseTask
local toolDisabled = false

local function firePress()

	if spaceHeld then return end
	spaceHeld = true

	local args = {
		[1] = {
			["Goal"] = "KeyPress",
			["Key"] = Enum.KeyCode.Space
		}
	}

	player.Character:WaitForChild("Communicate"):FireServer(unpack(args))
end

local function fireRelease()

	if not spaceHeld then return end
	spaceHeld = false

	local args = {
		[1] = {
			["Goal"] = "KeyRelease",
			["Key"] = Enum.KeyCode.Space
		}
	}

	player.Character:WaitForChild("Communicate"):FireServer(unpack(args))
end

local function setup()

	if not getgenv().AUTO_SPACE then return end

	local model = live:WaitForChild(player.Name)
	local char = player.Character

	while model:GetAttribute("Combo") == nil do
		model:GetAttributeChangedSignal("Combo"):Wait()
	end

	--------------------------------------------------
	-- COMBO DETECTION
	--------------------------------------------------

	table.insert(getgenv().AUTO_SPACE_CONNS,
		model:GetAttributeChangedSignal("Combo"):Connect(function()

			if not getgenv().AUTO_SPACE then return end
			if toolDisabled then return end

			local combo = model:GetAttribute("Combo")
			local m1ing = model:FindFirstChild("M1ing")

			if combo == 1 and m1ing then

				if releaseTask then
					task.cancel(releaseTask)
					releaseTask = nil
				end

				firePress()

			end
		end)
	)

	--------------------------------------------------
	-- M1ing REMOVED
	--------------------------------------------------

	table.insert(getgenv().AUTO_SPACE_CONNS,
		model.ChildRemoved:Connect(function(child)

			if child.Name ~= "M1ing" then return end
			if not getgenv().AUTO_SPACE then return end

			releaseTask = task.delay(1,function()

				if not model:FindFirstChild("M1ing") then
					fireRelease()
				end

			end)

		end)
	)

	--------------------------------------------------
	-- M1ing ADDED
	--------------------------------------------------

	table.insert(getgenv().AUTO_SPACE_CONNS,
		model.ChildAdded:Connect(function(child)

			if child.Name ~= "M1ing" then return end
			if not getgenv().AUTO_SPACE then return end

			toolDisabled = false

			if releaseTask then
				task.cancel(releaseTask)
				releaseTask = nil
			end

			firePress()

		end)
	)

	--------------------------------------------------
	-- TOOL DETECTION
	--------------------------------------------------

	table.insert(getgenv().AUTO_SPACE_CONNS,
		char.ChildAdded:Connect(function(child)

			if not child:IsA("Tool") then return end

			local combo = model:GetAttribute("Combo")

			if child.Name == "Consecutive Punches" then

				if releaseTask then
					task.cancel(releaseTask)
					releaseTask = nil
				end

				firePress()
				return
			end

			-- SOLO desactiva si combo es 1
			if combo == 1 then
				toolDisabled = true
				fireRelease()
			end

		end)
	)

end

table.insert(getgenv().AUTO_SPACE_CONNS,
	player.CharacterAdded:Connect(function()
		task.wait(1)
		setup()
	end)
)

if player.Character then
	setup()
end
