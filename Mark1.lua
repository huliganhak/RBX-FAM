local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- เคลียร์ UI เก่า
for _, oldGui in ipairs(playerGui:GetChildren()) do
	if oldGui.Name == "StageWarpHubGui" then
		oldGui:Destroy()
	end
end

-- 1. ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StageWarpHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 2. Main Frame (ย่อขนาดให้เล็กลงและกระชับสุดๆ)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 105)
mainFrame.Position = UDim2.new(0.85, -110, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- 3. Top Title Bar (แถบด้านบนพร้อมปุ่มพับ-ปิด)
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
titleLabel.Text = "🚀 Stage Warp"
titleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- ปุ่มพับ (-)
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinButton"
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
closeBtn.Name = "CloseButton"
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

-- 4. Status Bar (แสดงข้อมูล Stage ปัจจุบัน)
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -16, 0, 20)
statusLabel.Position = UDim2.new(0, 8, 0, 32)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "📍 Stage: - (0/0)"
statusLabel.TextColor3 = Color3.fromRGB(85, 205, 255)
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- 5. Control Buttons (ปุ่ม Teleport และ Reset แบบคอมแพกต์)
local nextBtn = Instance.new("TextButton")
nextBtn.Name = "NextButton"
nextBtn.Size = UDim2.new(1, -50, 0, 36)
nextBtn.Position = UDim2.new(0, 8, 0, 58)
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
resetBtn.Size = UDim2.new(0, 36, 0, 36)
resetBtn.Position = UDim2.new(1, -44, 0, 58)
resetBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Text = "🔄"
resetBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
resetBtn.TextSize = 14
resetBtn.Parent = mainFrame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetBtn

-- 6. ปุ่มเปิดมินิ (เมื่อพับหน้าจอ)
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenButton"
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

-- 7. ระบบ Drag
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

-- 8. Teleport & Logic
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

-- Events
minBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openBtn.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

resetBtn.MouseButton1Click:Connect(function()
	currentIndex = 1
	updateUI()
end)

nextBtn.MouseButton1Click:Connect(teleportToNextStage)

-- Run
loadAndSortStages()
updateUI()
