--// Rebirth Loop UI (LocalScript)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local rebirthEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RebirthEvent")

-- ===== State =====
local running = false
local rounds = 0
local loopThread = nil

-- ===== UI =====
local gui = Instance.new("ScreenGui")
gui.Name = "RebirthLoopUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 300, 0, 170)
frame.Position = UDim2.new(0, 20, 0, 120)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Rebirth Auto Loop"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left

local roundsLabel = Instance.new("TextLabel")
roundsLabel.Parent = frame
roundsLabel.Size = UDim2.new(1, -20, 0, 24)
roundsLabel.Position = UDim2.new(0, 10, 0, 42)
roundsLabel.BackgroundTransparency = 1
roundsLabel.Text = "Rounds: 0 | Status: STOPPED"
roundsLabel.Font = Enum.Font.Gotham
roundsLabel.TextSize = 14
roundsLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
roundsLabel.TextXAlignment = Enum.TextXAlignment.Left

local function makeLabel(txt, y)
	local l = Instance.new("TextLabel")
	l.Parent = frame
	l.Size = UDim2.new(0, 90, 0, 24)
	l.Position = UDim2.new(0, 10, 0, y)
	l.BackgroundTransparency = 1
	l.Text = txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextColor3 = Color3.fromRGB(200, 200, 200)
	l.TextXAlignment = Enum.TextXAlignment.Left
	return l
end

local function makeBox(default, y)
	local b = Instance.new("TextBox")
	b.Parent = frame
	b.Size = UDim2.new(0, 170, 0, 24)
	b.Position = UDim2.new(0, 110, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.Text = default
	b.ClearTextOnFocus = false
	b.BorderSizePixel = 0
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = b
	return b
end

makeLabel("Interval (s):", 72)
local intervalBox = makeBox("30", 72)

makeLabel("Arg (e.g. 5):", 102)
local argBox = makeBox("5", 102)

local startStopBtn = Instance.new("TextButton")
startStopBtn.Parent = frame
startStopBtn.Size = UDim2.new(0, 130, 0, 30)
startStopBtn.Position = UDim2.new(0, 10, 0, 132)
startStopBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 90)
startStopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startStopBtn.Font = Enum.Font.GothamBold
startStopBtn.TextSize = 14
startStopBtn.Text = "START"
startStopBtn.BorderSizePixel = 0
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = startStopBtn

local resetBtn = Instance.new("TextButton")
resetBtn.Parent = frame
resetBtn.Size = UDim2.new(0, 130, 0, 30)
resetBtn.Position = UDim2.new(0, 150, 0, 132)
resetBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 14
resetBtn.Text = "RESET COUNT"
resetBtn.BorderSizePixel = 0
local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 8)
btnCorner2.Parent = resetBtn

-- ===== Helpers =====
local function setStatus()
	roundsLabel.Text = ("Rounds: %d | Status: %s"):format(rounds, running and "RUNNING" or "STOPPED")
	startStopBtn.Text = running and "STOP" or "START"
	startStopBtn.BackgroundColor3 = running and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(0, 170, 90)
end

local function getInterval()
	local n = tonumber(intervalBox.Text)
	if not n or n < 0.1 then
		n = 30
		intervalBox.Text = "30"
	end
	return n
end

local function getArg()
	local n = tonumber(argBox.Text)
	if not n then
		n = 5
		argBox.Text = "5"
	end
	return n
end

local function startLoop()
	if running then return end
	running = true
	setStatus()

	loopThread = task.spawn(function()
		while running do
			local arg = getArg()
			rebirthEvent:FireServer(arg)

			rounds += 1
			setStatus()

			local interval = getInterval()
			task.wait(interval)
		end
	end)
end

local function stopLoop()
	if not running then return end
	running = false
	setStatus()
end

-- ===== Events =====
startStopBtn.MouseButton1Click:Connect(function()
	if running then
		stopLoop()
	else
		startLoop()
	end
end)

resetBtn.MouseButton1Click:Connect(function()
	rounds = 0
	setStatus()
end)

setStatus()
