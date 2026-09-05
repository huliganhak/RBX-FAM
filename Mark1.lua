local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- เคลียร์ UI เก่า
for _, oldGui in ipairs(playerGui:GetChildren()) do
	if oldGui.Name == "StageWarpHubGui" or oldGui.Name == "TrainingTeleportGui" then
		oldGui:Destroy()
	end
end

-- รายชื่อ Train 1 - 5
local trainLocations = {
	{ Name = "Train 1", Path = {"Map", "Lobby", "Decor", "Extra", "TrainingZone1"} },
	{ Name = "Train 2", Path = {"MapTest", "TrainingZone", "TrainingZone10"} },
	{ Name = "Train 3", Path = {"Map3", "TrainingZone", "TrainingZone19"} },
	{ Name = "Train 4", Path = {"Map4", "TrainingZone", "TrainingZone28"} },
	{ Name = "Train 5", Path = {"Map5", "TrainingZone", "TrainingZone37"} },
}

local selectedTrainIndex = 1
local autoClickActive = false
local autoRebirthActive = false

-- 1. ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StageWarpHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 2. Main Frame (ขยายความสูงรองรับ Auto Rebirth)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 230, 0, 220)
mainFrame.Position = UDim2.new(0.85, -115, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- 3. Top Title Bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 28)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "🚀 Stage Warp Hub"
titleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- ปุ่มพับ (-)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 20, 0, 20)
minBtn.Position = UDim2.new(1, -46, 0, 4)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.Font = Enum.Font.GothamBold
minBtn.Text = "-"
minBtn.TextSize = 14
minBtn.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 4)
minCorner.Parent = minBtn

-- ปุ่มปิด (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -24, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(225, 50, 65)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.TextSize = 10
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

-- 4. Status Bar
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -16, 0, 18)
statusLabel.Position = UDim2.new(0, 8, 0, 32)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "📍 Target: Stage - (0/0)"
statusLabel.TextColor3 = Color3.fromRGB(85, 205, 255)
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- 5. Stage Warp & Reset Buttons
local nextBtn = Instance.new("TextButton")
nextBtn.Name = "NextButton"
nextBtn.Size = UDim2.new(1, -48, 0, 30)
nextBtn.Position = UDim2.new(0, 8, 0, 52)
nextBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
nextBtn.Font = Enum.Font.GothamBold
nextBtn.Text = "⚡ Teleport Next"
nextBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
nextBtn.TextSize = 11
nextBtn.Parent = mainFrame

local nextCorner = Instance.new("UICorner")
nextCorner.CornerRadius = UDim.new(0, 6)
nextCorner.Parent = nextBtn

local resetBtn = Instance.new("TextButton")
resetBtn.Name = "ResetButton"
resetBtn.Size = UDim2.new(0, 30, 0, 30)
resetBtn.Position = UDim2.new(1, -38, 0, 52)
resetBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Text = "🔄"
resetBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
resetBtn.TextSize = 13
resetBtn.Parent = mainFrame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetBtn

-- 6. Training Dropdown
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Name = "DropdownBtn"
dropdownBtn.Size = UDim2.new(1, -48, 0, 28)
dropdownBtn.Position = UDim2.new(0, 8, 0, 88)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
dropdownBtn.Font = Enum.Font.GothamBold
dropdownBtn.Text = "🏋️ Select: Train 1 ▼"
dropdownBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
dropdownBtn.TextSize = 10
dropdownBtn.Parent = mainFrame

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 6)
dropdownCorner.Parent = dropdownBtn

local trainWarpBtn = Instance.new("TextButton")
trainWarpBtn.Name = "TrainWarpBtn"
trainWarpBtn.Size = UDim2.new(0, 30, 0, 28)
trainWarpBtn.Position = UDim2.new(1, -38, 0, 88)
trainWarpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 230)
trainWarpBtn.Font = Enum.Font.GothamBold
trainWarpBtn.Text = "GO"
trainWarpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
trainWarpBtn.TextSize = 10
trainWarpBtn.Parent = mainFrame

local trainWarpCorner = Instance.new("UICorner")
trainWarpCorner.CornerRadius = UDim.new(0, 6)
trainWarpCorner.Parent = trainWarpBtn

-- List Dropdown
local listFrame = Instance.new("Frame")
listFrame.Name = "ListFrame"
listFrame.Size = UDim2.new(1, -48, 0, 115)
listFrame.Position = UDim2.new(0, 8, 0, 118)
listFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
listFrame.BorderSizePixel = 0
listFrame.Visible = false
listFrame.ZIndex = 20
listFrame.Parent = mainFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 6)
listCorner.Parent = listFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = listFrame

for i, item in ipairs(trainLocations) do
	local itemBtn = Instance.new("TextButton")
	itemBtn.Size = UDim2.new(1, 0, 0, 21)
	itemBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	itemBtn.Font = Enum.Font.Gotham
	itemBtn.Text = item.Name
	itemBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	itemBtn.TextSize = 10
	itemBtn.ZIndex = 21
	itemBtn.Parent = listFrame
	
	itemBtn.MouseButton1Click:Connect(function()
		selectedTrainIndex = i
		dropdownBtn.Text = "🏋️ Select: " .. item.Name .. " ▼"
		listFrame.Visible = false
	end)
end

-- 7. ปุ่ม Auto Click (Loop)
local clickToggleBtn = Instance.new("TextButton")
clickToggleBtn.Name = "ClickToggleBtn"
clickToggleBtn.Size = UDim2.new(1, -16, 0, 28)
clickToggleBtn.Position = UDim2.new(0, 8, 0, 122)
clickToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
clickToggleBtn.Font = Enum.Font.GothamBold
clickToggleBtn.Text = "🖱️ Auto Click: OFF"
clickToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
clickToggleBtn.TextSize = 10
clickToggleBtn.Parent = mainFrame

local clickToggleCorner = Instance.new("UICorner")
clickToggleCorner.CornerRadius = UDim.new(0, 6)
clickToggleCorner.Parent = clickToggleBtn

-- 8. ปุ่ม Auto Rebirth (Loop)
local rebirthToggleBtn = Instance.new("TextButton")
rebirthToggleBtn.Name = "RebirthToggleBtn"
rebirthToggleBtn.Size = UDim2.new(1, -16, 0, 28)
rebirthToggleBtn.Position = UDim2.new(0, 8, 0, 155)
rebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
rebirthToggleBtn.Font = Enum.Font.GothamBold
rebirthToggleBtn.Text = "♻️ Auto Rebirth: OFF"
rebirthToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
rebirthToggleBtn.TextSize = 10
rebirthToggleBtn.Parent = mainFrame

local rebirthToggleCorner = Instance.new("UICorner")
rebirthToggleCorner.CornerRadius = UDim.new(0, 6)
rebirthToggleCorner.Parent = rebirthToggleBtn

-- 9. ปุ่มเปิดมินิ (เวลาพับ)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 85, 0, 26)
openBtn.Position = UDim2.new(1, -95, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
openBtn.Font = Enum.Font.GothamBold
openBtn.Text = "🚀 Stage"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.TextSize = 11
openBtn.Visible = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 6)
openCorner.Parent = openBtn

-- 10. Drag Window System
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- 11. Stage & Teleport Logic
local map3 = workspace:WaitForChild("Map3", 10)
local stagesFolder = map3 and map3:WaitForChild("Stages", 10)
local sortedStages = {}
local currentIndex = 1

local function loadAndSortStages()
	sortedStages = {}
	if not stagesFolder then return end
	for _, stageFolder in ipairs(stagesFolder:GetChildren()) do
		local stageNumStr = string.match(stageFolder.Name, "%d+")
		if stageNumStr then
			local stageNum = tonumber(stageNumStr)
			if stageNum then
				table.insert(sortedStages, { number = stageNum, folder = stageFolder })
			end
		end
	end
	table.sort(sortedStages, function(a, b) return a.number < b.number end)
end

local function updateUI()
	if #sortedStages == 0 then
		statusLabel.Text = "📍 Stage: ไม่พบข้อมูล"
		statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	else
		local currentNum = sortedStages[currentIndex] and sortedStages[currentIndex].number or "-"
		statusLabel.Text = "📍 Target: Stage " .. currentNum .. " (" .. currentIndex .. "/" .. #sortedStages .. ")"
		statusLabel.TextColor3 = Color3.fromRGB(85, 205, 255)
	end
end

local function teleportToNextStage()
	if #sortedStages == 0 then loadAndSortStages() end
	if #sortedStages == 0 then return end

	local currentStageData = sortedStages[currentIndex]
	if not currentStageData then return end

	local spawnPart = currentStageData.folder:FindFirstChild("Spawn")
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if spawnPart and hrp then
		hrp.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
		currentIndex = currentIndex + 1
		if currentIndex > #sortedStages then currentIndex = 1 end
		updateUI()
	end
end

-- Teleport Training Zone Logic
local function getTargetObject(pathArray)
	local current = workspace
	for _, name in ipairs(pathArray) do
		current = current:FindFirstChild(name)
		if not current then return nil end
	end
	return current
end

local function teleportToTrain()
	local selectedData = trainLocations[selectedTrainIndex]
	if not selectedData then return end

	local targetObj = getTargetObject(selectedData.Path)
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if targetObj and hrp then
		local targetCFrame
		if targetObj:IsA("BasePart") then
			targetCFrame = targetObj.CFrame
		elseif targetObj:IsA("Model") then
			targetCFrame = targetObj:GetPivot()
		else
			local firstPart = targetObj:FindFirstChildWhichIsA("BasePart", true)
			if firstPart then targetCFrame = firstPart.CFrame end
		end

		if targetCFrame then
			hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
		end
	end
end

-- 12. Auto Click Loop
task.spawn(function()
	while true do
		if autoClickActive then
			pcall(function()
				ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("PlayerClick"):FireServer()
			end)
		end
		task.wait(0.1)
	end
end)

-- 13. Auto Rebirth Loop
task.spawn(function()
	while true do
		if autoRebirthActive then
			pcall(function()
				ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("RequestRebirth"):InvokeServer()
			end)
		end
		task.wait(0.5) -- ตั้งเวลาหน่วงยิง InvokeServer ทุกๆ 0.5 วินาที
	end
end)

-- Events Binding
dropdownBtn.MouseButton1Click:Connect(function()
	listFrame.Visible = not listFrame.Visible
end)

trainWarpBtn.MouseButton1Click:Connect(teleportToTrain)

clickToggleBtn.MouseButton1Click:Connect(function()
	autoClickActive = not autoClickActive
	if autoClickActive then
		clickToggleBtn.Text = "🖱️ Auto Click: ON"
		clickToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
		clickToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
	else
		clickToggleBtn.Text = "🖱️ Auto Click: OFF"
		clickToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
		clickToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	end
end)

rebirthToggleBtn.MouseButton1Click:Connect(function()
	autoRebirthActive = not autoRebirthActive
	if autoRebirthActive then
		rebirthToggleBtn.Text = "♻️ Auto Rebirth: ON"
		rebirthToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
		rebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
	else
		rebirthToggleBtn.Text = "♻️ Auto Rebirth: OFF"
		rebirthToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
		rebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	end
end)

nextBtn.MouseButton1Click:Connect(teleportToNextStage)

resetBtn.MouseButton1Click:Connect(function()
	currentIndex = 1
	updateUI()
end)

minBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	listFrame.Visible = false
	openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openBtn.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
	autoClickActive = false
	autoRebirthActive = false
	screenGui:Destroy()
end)

-- Start
loadAndSortStages()
updateUI()
