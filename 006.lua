local Players = game:GetService("Players")
local player = Players.LocalPlayer

local running = false
local interval = 30

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
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoCollectUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0.5, -110, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
pcall(function()
	frame.Draggable = true
end)
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "Auto Collect"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = false
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 38)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Stopped"
statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
statusLabel.TextScaled = false
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = frame

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0.42, 0, 0, 40)
startButton.Position = UDim2.new(0.06, 0, 0, 80)
startButton.BackgroundColor3 = Color3.fromRGB(50, 170, 80)
startButton.Text = "Start"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.TextScaled = false
startButton.TextSize = 16
startButton.Font = Enum.Font.SourceSansBold
startButton.Parent = frame

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 8)
startCorner.Parent = startButton

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0.42, 0, 0, 40)
stopButton.Position = UDim2.new(0.52, 0, 0, 80)
stopButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
stopButton.Text = "Stop"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.TextScaled = false
stopButton.TextSize = 16
stopButton.Font = Enum.Font.SourceSansBold
stopButton.Parent = frame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 8)
stopCorner.Parent = stopButton

startButton.MouseButton1Click:Connect(function()
	if running then
		return
	end

	running = true
	statusLabel.Text = "Status: Running"

	task.spawn(function()
		while running do
			collectOnce()
			task.wait(interval)
		end
		statusLabel.Text = "Status: Stopped"
	end)
end)

stopButton.MouseButton1Click:Connect(function()
	running = false
	statusLabel.Text = "Status: Stopped"
end)
