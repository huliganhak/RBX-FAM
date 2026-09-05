local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. เคลียร์ UI เก่า
for _, oldGui in ipairs(playerGui:GetChildren()) do
	if oldGui.Name == "StageWarpHubGui" or oldGui.Name == "TrainingTeleportGui" then
		oldGui:Destroy()
	end
end

-- ข้อมูล Map ที่เลือกได้ (Map3 - Map5)
local mapList = {
	{ Name = "Map 3", WorkspaceName = "Map3" },
	{ Name = "Map 4", WorkspaceName = "Map4" },
	{ Name = "Map 5", WorkspaceName = "Map5" },
}

-- ข้อมูล Training Zone (Train 1 - 5)
local trainLocations = {
	{ Name = "Train 1", Path = {"Map", "Lobby", "Decor", "Extra", "TrainingZone1"} },
	{ Name = "Train 2", Path = {"MapTest", "TrainingZone", "TrainingZone10"} },
	{ Name = "Train 3", Path = {"Map3", "TrainingZone", "TrainingZone19"} },
	{ Name = "Train 4", Path = {"Map4", "TrainingZone", "TrainingZone28"} },
	{ Name = "Train 5", Path = {"Map5", "TrainingZone", "TrainingZone37"} },
}

local selectedMapIndex = 1
local selectedTrainIndex = 1
local sortedStages = {}
local currentIndex = 1

local autoClickActive = false
local autoRebirthActive = false

-- 2. ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StageWarpHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 3. Main Frame (ปรับขนาดรองรับ 2 Dropdown)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 230, 0, 250)
mainFrame.Position = UDim2.new(0.85, -115, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- 4. Top Title Bar
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
titleLabel.Text = "🚀 Multi-Map Warp Hub"
titleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

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

-- 5. Dropdown เลือก Map (Map 3 - Map 5)
local mapDropdownBtn = Instance.new("TextButton")
mapDropdownBtn.Name = "MapDropdownBtn"
mapDropdownBtn.Size = UDim2.new(1, -16, 0, 26)
mapDropdownBtn.Position = UDim2.new(0, 8, 0, 32)
mapDropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mapDropdownBtn.Font = Enum.Font.GothamBold
mapDropdownBtn.Text = "🗺️ Select: Map 3 ▼"
mapDropdownBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
mapDropdownBtn.TextSize = 10
mapDropdownBtn.Parent = mainFrame

local mapDropdownCorner = Instance.new("UICorner")
mapDropdownCorner.CornerRadius = UDim.new(0, 6)
mapDropdownCorner.Parent = mapDropdownBtn

local mapListFrame = Instance.new("Frame")
mapListFrame.Name = "MapListFrame"
mapListFrame.Size = UDim2.new(1, -16, 0, 70)
mapListFrame.Position = UDim2.new(0, 8, 0, 60)
mapListFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mapListFrame.BorderSizePixel = 0
mapListFrame.Visible = false
mapListFrame.ZIndex = 30
mapListFrame.Parent = mainFrame

local mapListCorner = Instance.new("UICorner")
mapListCorner.CornerRadius = UDim.new(0, 6)
mapListCorner.Parent = mapListFrame

local mapListLayout = Instance.new("UIListLayout")
mapListLayout.Padding = UDim.new(0, 2)
mapListLayout.Parent = mapListFrame

-- 6. Status Bar
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -16, 0, 18)
statusLabel.Position = UDim2.new(0, 8, 0, 62)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "📍 Target: Stage - (0/0)"
statusLabel.TextColor3 = Color3.fromRGB(85, 205, 255)
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- 7. Stage Warp & Reset Buttons
local nextBtn = Instance.new("TextButton")
nextBtn.Name = "NextButton"
nextBtn.Size = UDim2.new(1, -48, 0, 28)
nextBtn.Position = UDim2.new(0, 8, 0, 82)
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
resetBtn.Size = UDim2.new(0, 28, 0, 28)
resetBtn.Position = UDim2.new(1, -36, 0, 82)
resetBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Text = "🔄"
resetBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
resetBtn.TextSize = 12
resetBtn.Parent = mainFrame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetBtn

-- 8. Training Dropdown
local trainDropdownBtn = Instance.new("TextButton")
trainDropdownBtn.Name = "TrainDropdownBtn"
trainDropdownBtn.Size = UDim2.new(1, -48, 0, 26)
trainDropdownBtn.Position = UDim2.new(0, 8, 0, 116)
trainDropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
trainDropdownBtn.Font = Enum.Font.GothamBold
trainDropdownBtn.Text = "🏋️ Select: Train 1 ▼"
trainDropdownBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
trainDropdownBtn.TextSize = 10
trainDropdownBtn.Parent = mainFrame

local trainDropdownCorner = Instance.new("UICorner")
trainDropdownCorner.CornerRadius = UDim.new(0, 6)
trainDropdownCorner.Parent = trainDropdownBtn

local trainWarpBtn = Instance.new("TextButton")
trainWarpBtn.Name = "TrainWarpBtn"
trainWarpBtn.Size = UDim2.new(0, 28, 0, 26)
trainWarpBtn.Position = UDim2.new(1, -36, 0, 116)
trainWarpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 230)
trainWarpBtn.Font = Enum.Font.GothamBold
trainWarpBtn.Text = "GO"
trainWarpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
trainWarpBtn.TextSize = 10
trainWarpBtn.Parent = mainFrame

local trainWarpCorner = Instance.new("UICorner")
trainWarpCorner.CornerRadius = UDim.new(0, 6)
trainWarpCorner.Parent = trainWarpBtn

local trainListFrame = Instance.new("Frame")
trainListFrame.Name = "TrainListFrame"
trainListFrame.Size = UDim2.new(1, -48, 0, 115)
trainListFrame.Position = UDim2.new(0, 8, 0, 144)
trainListFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
trainListFrame.BorderSizePixel = 0
trainListFrame.Visible = false
trainListFrame.ZIndex = 20
trainListFrame.Parent = mainFrame

local trainListCorner = Instance.new("UICorner")
trainListCorner.CornerRadius = UDim.new(0, 6)
trainListCorner.Parent = trainListFrame

local trainListLayout = Instance.new("UIListLayout")
trainListLayout.Padding = UDim.new(0, 2)
trainListLayout.Parent = trainListFrame

-- 9. Auto Buttons (Click & Rebirth)
local clickToggleBtn = Instance.new("TextButton")
clickToggleBtn.Size = UDim2.new(1, -16, 0, 26)
clickToggleBtn.Position = UDim2.new(0, 8, 0, 150)
clickToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
clickToggleBtn.Font = Enum.Font.GothamBold
clickToggleBtn.Text = "🖱️ Auto Click: OFF"
clickToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
clickToggleBtn.TextSize = 10
clickToggleBtn.Parent = mainFrame

local clickToggleCorner = Instance.new("UICorner")
clickToggleCorner.CornerRadius = UDim.new(0, 6)
clickToggleCorner.Parent = clickToggleBtn

local rebirthToggleBtn = Instance.new("TextButton")
rebirthToggleBtn.Size = UDim2.new(1, -16, 0, 26)
rebirthToggleBtn.Position = UDim2.new(0, 8, 0, 182)
rebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
rebirthToggleBtn.Font = Enum.Font.GothamBold
rebirthToggleBtn.Text = "♻️ Auto Rebirth: OFF"
rebirthToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
rebirthToggleBtn.TextSize = 10
rebirthToggleBtn.Parent = mainFrame

local rebirthToggleCorner = Instance.new("UICorner")
rebirthToggleCorner.CornerRadius = UDim.new(0, 6)
rebirthToggleCorner.Parent = rebirthToggleBtn

-- 10. Open Button (Minimizing)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 85, 0, 26)
openBtn.Position = UDim2.new(1, -95, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
openBtn.Font = Enum.Font.GothamBold
openBtn.Text = "🚀 Hub"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.TextSize = 11
openBtn.Visible = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 6)
openCorner.Parent = openBtn

-- 11. Drag Window System
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

-- 12. Dynamic Map & Stage Logic
local function loadAndSortStages()
	sortedStages = {}
	currentIndex = 1
	
	local currentMapData = mapList[selectedMapIndex]
	if not currentMapData then return end
	
	local targetMapFolder = workspace:FindFirstChild(currentMapData.WorkspaceName)
	local stagesFolder = targetMapFolder and targetMapFolder:FindFirstChild("Stages")

	if stagesFolder then
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
end

local function updateUI()
	if #sortedStages == 0 then
		statusLabel.Text = "📍 Stage: ไม่พบข้อมูลด่าน"
		statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	else
		local currentNum = sortedStages[currentIndex] and sortedStages[currentIndex].number or "-"
		statusLabel.Text = "📍 Target: Stage " .. currentNum .. " (" .. currentIndex .. "/" .. #sortedStages .. ")"
		statusLabel.TextColor3 = Color3.fromRGB(85, 205, 255)
	end
end

-- สร้างรายการ Map เลือกได้ (Map 3 - 5)
for i, item in ipairs(mapList) do
	local itemBtn = Instance.new("TextButton")
	itemBtn.Size = UDim2.new(1, 0, 0, 20)
	itemBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	itemBtn.Font = Enum.Font.Gotham
	itemBtn.Text = item.Name
	itemBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	itemBtn.TextSize = 10
	itemBtn.ZIndex = 31
	itemBtn.Parent = mapListFrame
	
	itemBtn.MouseButton1Click:Connect(function()
		selectedMapIndex = i
		mapDropdownBtn.Text = "🗺️ Select: " .. item.Name .. " ▼"
		mapListFrame.Visible = false
		loadAndSortStages()
		updateUI()
	end)
end

-- สร้างรายการ Train (1 - 5)
for i, item in ipairs(trainLocations) do
	local itemBtn = Instance.new("TextButton")
	itemBtn.Size = UDim2.new(1, 0, 0, 21)
	itemBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	itemBtn.Font = Enum.Font.Gotham
	itemBtn.Text = item.Name
	itemBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	itemBtn.TextSize = 10
	itemBtn.ZIndex = 21
	itemBtn.Parent = trainListFrame
	
	itemBtn.MouseButton1Click:Connect(function()
		selectedTrainIndex = i
		trainDropdownBtn.Text = "🏋️ Select: " .. item.Name .. " ▼"
		trainListFrame.Visible = false
	end)
end

-- Teleport Stage Logic
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

-- Loops System
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

task.spawn(function()
	while true do
		if autoRebirthActive then
			pcall(function()
				ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("RequestRebirth"):InvokeServer()
			end)
		end
		task.wait(0.5)
	end
end)

-- Events
mapDropdownBtn.MouseButton1Click:Connect(function()
	mapListFrame.Visible = not mapListFrame.Visible
	trainListFrame.Visible = false
end)

trainDropdownBtn.MouseButton1Click:Connect(function()
	trainListFrame.Visible = not trainListFrame.Visible
	mapListFrame.Visible = false
end)

trainWarpBtn.MouseButton1Click:Connect(teleportToTrain)

clickToggleBtn.MouseButton1Click:Connect(function()
	autoClickActive = not autoClickActive
	clickToggleBtn.Text = autoClickActive and "🖱️ Auto Click: ON" or "🖱️ Auto Click: OFF"
	clickToggleBtn.TextColor3 = autoClickActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
	clickToggleBtn.BackgroundColor3 = autoClickActive and Color3.fromRGB(20, 60, 30) or Color3.fromRGB(40, 40, 50)
end)

rebirthToggleBtn.MouseButton1Click:Connect(function()
	autoRebirthActive = not autoRebirthActive
	rebirthToggleBtn.Text = autoRebirthActive and "♻️ Auto Rebirth: ON" or "♻️ Auto Rebirth: OFF"
	rebirthToggleBtn.TextColor3 = autoRebirthActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
	rebirthToggleBtn.BackgroundColor3 = autoRebirthActive and Color3.fromRGB(20, 60, 30) or Color3.fromRGB(40, 40, 50)
end)

nextBtn.MouseButton1Click:Connect(teleportToNextStage)

resetBtn.MouseButton1Click:Connect(function()
	currentIndex = 1
	updateUI()
end)

minBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	mapListFrame.Visible = false
	trainListFrame.Visible = false
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

-- Initial Load
loadAndSortStages()
updateUI()
