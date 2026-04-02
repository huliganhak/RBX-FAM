local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local collectCashRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CollectCash")
local claimEventLuckyBlockRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ClaimEventLuckyBlock")

local running = false
local interval = 180
local collapsed = false
local claimingLuckyBlock = false

local runStartTime = 0
local currentRound = 0
local waitingForNextRound = false
local nextRoundTime = 0

local guiParent
if gethui then
	guiParent = gethui()
else
	guiParent = player:WaitForChild("PlayerGui")
end

local oldGui = guiParent:FindFirstChild("AutoCollectUI")
if oldGui then
	oldGui:Destroy()
end

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))

	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if hours > 0 then
		return string.format("%02d:%02d:%02d", hours, minutes, secs)
	end

	return string.format("%02d:%02d", minutes, secs)
end

local function jumpOnce()
	if not running then
		return
	end

	pcall(function()
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
		task.wait()
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
	end)
end

local function getPlacements()
	local plotName = player:GetAttribute("PlotName")
	if not plotName then
		return nil
	end

	local plots = workspace:FindFirstChild("Plots")
	if not plots then
		return nil
	end

	local plot = plots:FindFirstChild(plotName)
	if not plot then
		return nil
	end

	return plot:FindFirstChild("Placements")
end

local function collectOnce()
	local placements = getPlacements()
	if not placements then
		return
	end

	pcall(function()
		collectCashRemote:FireServer()
	end)

	for _, obj in ipairs(placements:GetChildren()) do
		if not running then
			break
		end

		local prompt = obj:FindFirstChild("ProximityPrompt")
		if prompt and prompt.Enabled then
			pcall(function()
				fireproximityprompt(prompt)
			end)
			task.wait(0.2)
		end
	end

	if running then
		task.wait(0.1)
		jumpOnce()
	end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoCollectUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 230)
frame.Position = UDim2.new(0.5, -125, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
pcall(function()
	frame.Draggable = true
end)
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 34)
topBar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 12)
topFix.Position = UDim2.new(0, 0, 1, -12)
topFix.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
topFix.BorderSizePixel = 0
topFix.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Collect"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = false
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = topBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 22, 0, 22)
minimizeButton.Position = UDim2.new(1, -52, 0, 6)
minimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimizeButton.Text = "–"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextScaled = false
minimizeButton.TextSize = 16
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = topBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeButton

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 22, 0, 22)
closeButton.Position = UDim2.new(1, -26, 0, 6)
closeButton.BackgroundColor3 = Color3.fromRGB(170, 65, 65)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = false
closeButton.TextSize = 14
closeButton.Font = Enum.Font.SourceSansBold
closeButton.BorderSizePixel = 0
closeButton.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 18)
statusLabel.Position = UDim2.new(0, 10, 0, 46)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Stopped"
statusLabel.TextColor3 = Color3.fromRGB(215, 215, 215)
statusLabel.TextScaled = false
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = frame

local runtimeLabel = Instance.new("TextLabel")
runtimeLabel.Size = UDim2.new(1, -20, 0, 18)
runtimeLabel.Position = UDim2.new(0, 10, 0, 66)
runtimeLabel.BackgroundTransparency = 1
runtimeLabel.Text = "Runtime: 00:00"
runtimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
runtimeLabel.TextScaled = false
runtimeLabel.TextSize = 13
runtimeLabel.Font = Enum.Font.SourceSans
runtimeLabel.Parent = frame

local roundLabel = Instance.new("TextLabel")
roundLabel.Size = UDim2.new(1, -20, 0, 18)
roundLabel.Position = UDim2.new(0, 10, 0, 86)
roundLabel.BackgroundTransparency = 1
roundLabel.Text = "Round: 0"
roundLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
roundLabel.TextScaled = false
roundLabel.TextSize = 13
roundLabel.Font = Enum.Font.SourceSans
roundLabel.Parent = frame

local nextRoundLabel = Instance.new("TextLabel")
nextRoundLabel.Size = UDim2.new(1, -20, 0, 18)
nextRoundLabel.Position = UDim2.new(0, 10, 0, 106)
nextRoundLabel.BackgroundTransparency = 1
nextRoundLabel.Text = "Next round in: --"
nextRoundLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
nextRoundLabel.TextScaled = false
nextRoundLabel.TextSize = 13
nextRoundLabel.Font = Enum.Font.SourceSans
nextRoundLabel.Parent = frame

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 100, 0, 34)
startButton.Position = UDim2.new(0, 14, 0, 138)
startButton.BackgroundColor3 = Color3.fromRGB(55, 165, 85)
startButton.Text = "Start"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.TextScaled = false
startButton.TextSize = 15
startButton.Font = Enum.Font.SourceSansBold
startButton.BorderSizePixel = 0
startButton.Parent = frame

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 8)
startCorner.Parent = startButton

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 100, 0, 34)
stopButton.Position = UDim2.new(0, 136, 0, 138)
stopButton.BackgroundColor3 = Color3.fromRGB(185, 65, 65)
stopButton.Text = "Stop"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.TextScaled = false
stopButton.TextSize = 15
stopButton.Font = Enum.Font.SourceSansBold
stopButton.BorderSizePixel = 0
stopButton.Parent = frame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 8)
stopCorner.Parent = stopButton

local luckyBlockButton = Instance.new("TextButton")
luckyBlockButton.Size = UDim2.new(0, 222, 0, 34)
luckyBlockButton.Position = UDim2.new(0, 14, 0, 182)
luckyBlockButton.BackgroundColor3 = Color3.fromRGB(210, 150, 55)
luckyBlockButton.Text = "Claim Event Box x5"
luckyBlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
luckyBlockButton.TextScaled = false
luckyBlockButton.TextSize = 15
luckyBlockButton.Font = Enum.Font.SourceSansBold
luckyBlockButton.BorderSizePixel = 0
luckyBlockButton.Parent = frame

local luckyBlockCorner = Instance.new("UICorner")
luckyBlockCorner.CornerRadius = UDim.new(0, 8)
luckyBlockCorner.Parent = luckyBlockButton

local expandedSize = UDim2.new(0, 250, 0, 230)
local collapsedSize = UDim2.new(0, 250, 0, 34)

local function resetStatusDisplay()
	statusLabel.Text = "Status: Stopped"
	runtimeLabel.Text = "Runtime: 00:00"
	roundLabel.Text = "Round: 0"
	nextRoundLabel.Text = "Next round in: --"
end

local function setCollapsed(state)
	collapsed = state

	statusLabel.Visible = not state
	runtimeLabel.Visible = not state
	roundLabel.Visible = not state
	nextRoundLabel.Visible = not state
	startButton.Visible = not state
	stopButton.Visible = not state
	luckyBlockButton.Visible = not state

	minimizeButton.Text = state and "+" or "–"

	local targetSize = state and collapsedSize or expandedSize
	TweenService:Create(
		frame,
		TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = targetSize}
	):Play()
end

task.spawn(function()
	while screenGui.Parent do
		if running then
			local elapsed = os.clock() - runStartTime
			runtimeLabel.Text = "Runtime: " .. formatTime(elapsed)
			roundLabel.Text = "Round: " .. tostring(currentRound)

			if waitingForNextRound then
				local remain = math.max(0, nextRoundTime - os.clock())
				nextRoundLabel.Text = "Next round in: " .. formatTime(remain)
			else
				nextRoundLabel.Text = "Next round in: Collecting..."
			end
		end

		task.wait(0.2)
	end
end)

startButton.MouseButton1Click:Connect(function()
	if running then
		return
	end

	running = true
	runStartTime = os.clock()
	currentRound = 0
	waitingForNextRound = false
	nextRoundTime = 0

	statusLabel.Text = "Status: Starting..."
	runtimeLabel.Text = "Runtime: 00:00"
	roundLabel.Text = "Round: 0"
	nextRoundLabel.Text = "Next round in: Collecting..."

	task.spawn(function()
		while running do
			currentRound += 1
			waitingForNextRound = false
			statusLabel.Text = "Status: Collecting"

			collectOnce()

			if not running then
				break
			end

			waitingForNextRound = true
			nextRoundTime = os.clock() + interval
			statusLabel.Text = "Status: Waiting"

			while running and os.clock() < nextRoundTime do
				task.wait(0.2)
			end
		end

		running = false
		waitingForNextRound = false
		resetStatusDisplay()
	end)
end)

stopButton.MouseButton1Click:Connect(function()
	running = false
	waitingForNextRound = false
	resetStatusDisplay()
end)

luckyBlockButton.MouseButton1Click:Connect(function()
	if claimingLuckyBlock then
		return
	end

	claimingLuckyBlock = true
	local oldText = luckyBlockButton.Text
	luckyBlockButton.Text = "Claiming..."
	luckyBlockButton.Active = false
	luckyBlockButton.AutoButtonColor = false

	task.spawn(function()
		for i = 1, 5 do
			pcall(function()
				claimEventLuckyBlockRemote:FireServer()
			end)
			task.wait(0.15)
		end

		luckyBlockButton.Text = oldText
		luckyBlockButton.Active = true
		luckyBlockButton.AutoButtonColor = true
		claimingLuckyBlock = false
	end)
end)

minimizeButton.MouseButton1Click:Connect(function()
	setCollapsed(not collapsed)
end)

closeButton.MouseButton1Click:Connect(function()
	running = false
	waitingForNextRound = false
	screenGui:Destroy()
end)

resetStatusDisplay()
