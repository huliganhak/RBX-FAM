local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local rollRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RollWeapons")

local oldGui = playerGui:FindFirstChild("RollTestUI")
if oldGui then
	oldGui:Destroy()
end

local running = false
local runToken = 0
local summary = {}
local recentLogs = {}

local function make(className, props, parent)
	local obj = Instance.new(className)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	obj.Parent = parent
	return obj
end

local function buildSummaryText()
	local names = {}
	for name in pairs(summary) do
		table.insert(names, name)
	end
	table.sort(names)

	if #names == 0 then
		return "-"
	end

	local lines = {}
	for _, name in ipairs(names) do
		table.insert(lines, string.format("%s = %d", name, summary[name]))
	end
	return table.concat(lines, "\n")
end

local function pushRecent(text)
	table.insert(recentLogs, 1, text)
	while #recentLogs > 10 do
		table.remove(recentLogs)
	end
end

local gui = make("ScreenGui", {
	Name = "RollTestUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local frame = make("Frame", {
	Name = "Main",
	Size = UDim2.new(0, 460, 0, 430),
	Position = UDim2.new(0, 30, 0, 120),
	BackgroundColor3 = Color3.fromRGB(28, 28, 28),
	BorderSizePixel = 0,
	Active = true,
}, gui)

make("UICorner", {
	CornerRadius = UDim.new(0, 10),
}, frame)

local titleBar = make("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1, 0, 0, 36),
	BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	BorderSizePixel = 0,
}, frame)

make("UICorner", {
	CornerRadius = UDim.new(0, 10),
}, titleBar)

make("TextLabel", {
	Name = "Title",
	Size = UDim2.new(1, -110, 1, 0),
	Position = UDim2.new(0, 12, 0, 0),
	BackgroundTransparency = 1,
	Text = "RollWeapons Tester",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
}, titleBar)

local minimizeBtn = make("TextButton", {
	Name = "MinimizeBtn",
	Size = UDim2.new(0, 28, 0, 28),
	Position = UDim2.new(1, -68, 0, 4),
	BackgroundColor3 = Color3.fromRGB(70, 120, 180),
	BorderSizePixel = 0,
	Text = "_",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 16,
}, titleBar)

make("UICorner", {
	CornerRadius = UDim.new(0, 8),
}, minimizeBtn)

local closeBtn = make("TextButton", {
	Name = "CloseBtn",
	Size = UDim2.new(0, 28, 0, 28),
	Position = UDim2.new(1, -34, 0, 4),
	BackgroundColor3 = Color3.fromRGB(170, 60, 60),
	BorderSizePixel = 0,
	Text = "X",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 14,
}, titleBar)

make("UICorner", {
	CornerRadius = UDim.new(0, 8),
}, closeBtn)

local content = make("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -16, 1, -52),
	Position = UDim2.new(0, 8, 0, 44),
	BackgroundTransparency = 1,
}, frame)

make("TextLabel", {
	Name = "LoopLabel",
	Size = UDim2.new(0, 80, 0, 24),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundTransparency = 1,
	Text = "Loop",
	TextColor3 = Color3.fromRGB(230, 230, 230),
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.Gotham,
	TextSize = 14,
}, content)

local loopBox = make("TextBox", {
	Name = "LoopBox",
	Size = UDim2.new(0, 100, 0, 28),
	Position = UDim2.new(0, 0, 0, 24),
	BackgroundColor3 = Color3.fromRGB(45, 45, 45),
	BorderSizePixel = 0,
	Text = "30",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	PlaceholderText = "count",
	Font = Enum.Font.Gotham,
	TextSize = 14,
	ClearTextOnFocus = false,
}, content)

make("UICorner", {
	CornerRadius = UDim.new(0, 8),
}, loopBox)

make("TextLabel", {
	Name = "DelayLabel",
	Size = UDim2.new(0, 80, 0, 24),
	Position = UDim2.new(0, 120, 0, 0),
	BackgroundTransparency = 1,
	Text = "Delay",
	TextColor3 = Color3.fromRGB(230, 230, 230),
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.Gotham,
	TextSize = 14,
}, content)

local delayBox = make("TextBox", {
	Name = "DelayBox",
	Size = UDim2.new(0, 100, 0, 28),
	Position = UDim2.new(0, 120, 0, 24),
	BackgroundColor3 = Color3.fromRGB(45, 45, 45),
	BorderSizePixel = 0,
	Text = "1",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	PlaceholderText = "seconds",
	Font = Enum.Font.Gotham,
	TextSize = 14,
	ClearTextOnFocus = false,
}, content)

make("UICorner", {
	CornerRadius = UDim.new(0, 8),
}, delayBox)

local startBtn = make("TextButton", {
	Name = "StartBtn",
	Size = UDim2.new(0, 90, 0, 28),
	Position = UDim2.new(0, 242, 0, 24),
	BackgroundColor3 = Color3.fromRGB(50, 140, 75),
	BorderSizePixel = 0,
	Text = "Start",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 14,
}, content)

make("UICorner", {
	CornerRadius = UDim.new(0, 8),
}, startBtn)

local stopBtn = make("TextButton", {
	Name = "StopBtn",
	Size = UDim2.new(0, 90, 0, 28),
	Position = UDim2.new(0, 342, 0, 24),
	BackgroundColor3 = Color3.fromRGB(170, 70, 70),
	BorderSizePixel = 0,
	Text = "Stop",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 14,
}, content)

make("UICorner", {
	CornerRadius = UDim.new(0, 8),
}, stopBtn)

local statusLabel = make("TextLabel", {
	Name = "StatusLabel",
	Size = UDim2.new(1, 0, 0, 24),
	Position = UDim2.new(0, 0, 0, 64),
	BackgroundTransparency = 1,
	Text = "Status: Idle",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
}, content)

local progressLabel = make("TextLabel", {
	Name = "ProgressLabel",
	Size = UDim2.new(1, 0, 0, 24),
	Position = UDim2.new(0, 0, 0, 88),
	BackgroundTransparency = 1,
	Text = "Progress: 0 / 0",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.Gotham,
	TextSize = 14,
}, content)

local lastItemLabel = make("TextLabel", {
	Name = "LastItemLabel",
	Size = UDim2.new(1, 0, 0, 24),
	Position = UDim2.new(0, 0, 0, 112),
	BackgroundTransparency = 1,
	Text = "Last Item: -",
	TextColor3 = Color3.fromRGB(255, 230, 120),
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
}, content)

make("TextLabel", {
	Name = "RecentTitle",
	Size = UDim2.new(0.48, 0, 0, 24),
	Position = UDim2.new(0, 0, 0, 148),
	BackgroundTransparency = 1,
	Text = "Recent Rolls",
	TextColor3 = Color3.fromRGB(230, 230, 230),
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
}, content)

make("TextLabel", {
	Name = "SummaryTitle",
	Size = UDim2.new(0.48, 0, 0, 24),
	Position = UDim2.new(0.52, 0, 0, 148),
	BackgroundTransparency = 1,
	Text = "Summary",
	TextColor3 = Color3.fromRGB(230, 230, 230),
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
}, content)

local recentFrame = make("Frame", {
	Name = "RecentFrame",
	Size = UDim2.new(0.48, -6, 0, 220),
	Position = UDim2.new(0, 0, 0, 172),
	BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	BorderSizePixel = 0,
}, content)

make("UICorner", {
	CornerRadius = UDim.new(0, 8),
}, recentFrame)

local recentLabel = make("TextLabel", {
	Name = "RecentLabel",
	Size = UDim2.new(1, -10, 1, -10),
	Position = UDim2.new(0, 5, 0, 5),
	BackgroundTransparency = 1,
	Text = "-",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Font = Enum.Font.Code,
	TextSize = 14,
	TextWrapped = false,
}, recentFrame)

local summaryFrame = make("Frame", {
	Name = "SummaryFrame",
	Size = UDim2.new(0.52, -6, 0, 220),
	Position = UDim2.new(0.48, 6, 0, 172),
	BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	BorderSizePixel = 0,
}, content)

make("UICorner", {
	CornerRadius = UDim.new(0, 8),
}, summaryFrame)

local summaryLabel = make("TextLabel", {
	Name = "SummaryLabel",
	Size = UDim2.new(1, -10, 1, -10),
	Position = UDim2.new(0, 5, 0, 5),
	BackgroundTransparency = 1,
	Text = "-",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Font = Enum.Font.Code,
	TextSize = 14,
	TextWrapped = false,
}, summaryFrame)

local function setStatus(text)
	statusLabel.Text = "Status: " .. text
end

local function stopRolling()
	running = false
end

local function getRewardName()
	local result = rollRemote:InvokeServer(false)
	local items = result and result[1]
	local reward = items and items[#items]

	if reward and reward:IsA("Instance") then
		return reward.Name
	end

	return nil
end

local expandedSize = frame.Size
local minimized = false

local function toggleMinimize()
	minimized = not minimized

	if minimized then
		content.Visible = false
		frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 44)
		minimizeBtn.Text = "+"
	else
		content.Visible = true
		frame.Size = expandedSize
		minimizeBtn.Text = "_"
	end
end

startBtn.MouseButton1Click:Connect(function()
	if running then
		return
	end

	local loopCount = tonumber(loopBox.Text) or 30
	local delay = tonumber(delayBox.Text) or 1

	loopCount = math.max(1, math.floor(loopCount))
	delay = math.max(0, delay)

	summary = {}
	recentLogs = {}
	recentLabel.Text = "-"
	summaryLabel.Text = "-"
	progressLabel.Text = string.format("Progress: 0 / %d", loopCount)
	lastItemLabel.Text = "Last Item: -"

	running = true
	runToken += 1
	local myToken = runToken

	setStatus("Starting...")

	task.spawn(function()
		for i = 1, loopCount do
			if not running or myToken ~= runToken then
				break
			end

			setStatus("Rolling...")
			progressLabel.Text = string.format("Progress: %d / %d", i, loopCount)

			local ok, rewardNameOrError = pcall(getRewardName)
			local rewardName

			if ok then
				rewardName = rewardNameOrError
			else
				rewardName = nil
			end

			if rewardName then
				lastItemLabel.Text = "Last Item: " .. rewardName
				summary[rewardName] = (summary[rewardName] or 0) + 1
				pushRecent(string.format("%03d) %s", i, rewardName))
			else
				lastItemLabel.Text = "Last Item: -"
				pushRecent(string.format("%03d) FAILED", i))
			end

			recentLabel.Text = table.concat(recentLogs, "\n")
			summaryLabel.Text = buildSummaryText()

			if i < loopCount then
				local startTime = os.clock()
				while running and myToken == runToken and (os.clock() - startTime) < delay do
					task.wait(0.05)
				end
			end
		end

		if myToken ~= runToken then
			return
		end

		if running then
			running = false
			setStatus("Done")
		else
			setStatus("Stopped")
		end
	end)
end)

stopBtn.MouseButton1Click:Connect(function()
	stopRolling()
end)

minimizeBtn.MouseButton1Click:Connect(function()
	toggleMinimize()
end)

closeBtn.MouseButton1Click:Connect(function()
	stopRolling()
	gui:Destroy()
end)

local dragging = false
local dragInput
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
