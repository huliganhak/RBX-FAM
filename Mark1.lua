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

-- 2. Main Frame (หน้าต่างหลักสไตล์ Hub)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 360, 0, 240)
mainFrame.Position = UDim2.new(0.5, -180, 0.4, -120) -- เด้งขึ้นกลางจอ
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- 3. Top Title Bar (แถบด้านบน)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 38)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "🚀 Stage Warp Hub v1.0"
titleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- ปุ่มพับ (-)
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinButton"
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -62, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.Font = Enum.Font.GothamBold
minBtn.Text = "-"
minBtn.TextSize = 16
minBtn.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

-- ปุ่มปิด (X) สีแดงสดแบบในรูป
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(225, 50, 65)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.TextSize = 12
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- 4. Status Panel (กล่องแสดงสถานะกลางหน้าจอ)
local statusFrame = Instance.new("Frame")
statusFrame.Name = "StatusFrame"
statusFrame.Size = UDim2.new(1, -24, 0, 85)
statusFrame.Position = UDim2.new(0, 12, 0, 48)
statusFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
statusFrame.BorderSizePixel = 0
statusFrame.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusFrame

local currentStageLabel = Instance.new("TextLabel")
currentStageLabel.Size = UDim2.new(1, 0, 0, 25)
currentStageLabel.Position = UDim2.new(0, 0, 0, 12)
currentStageLabel.BackgroundTransparency = 1
currentStageLabel.Font = Enum.Font.GothamBold
currentStageLabel.Text = "📍 Target Stage: -"
currentStageLabel.TextColor3 = Color3.fromRGB(85, 205, 255)
currentStageLabel.TextSize = 14
currentStageLabel.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "สถานะ: พร้อมใช้งาน"
statusLabel.TextColor3 = Color3.fromRGB(160, 220, 160)
statusLabel.TextSize = 12
statusLabel.Parent = statusFrame

-- 5. Control Buttons (การ์ดปุ่มกดด้านล่าง 2 ปุ่มคู่กัน)
local nextBtn = Instance.new("TextButton")
nextBtn.Name = "NextButton"
nextBtn.Size = UDim2.new(0.5, -18, 0, 42)
nextBtn.Position = UDim2.new(0, 12, 0, 142)
nextBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
nextBtn.Font = Enum.Font.GothamBold
nextBtn.Text = "⚡ Teleport Next"
nextBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
nextBtn.TextSize = 12
nextBtn.Parent = mainFrame

local nextCorner = Instance.new("UICorner")
nextCorner.CornerRadius = UDim.new(0, 8)
nextCorner.Parent = nextBtn

local resetBtn = Instance.new("TextButton")
resetBtn.Name = "ResetButton"
resetBtn.Size = UDim2.new(0.5, -18, 0, 42)
resetBtn.Position = UDim2.new(0.5, 6, 0, 142)
resetBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Text = "🔄 Reset to First"
resetBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
resetBtn.TextSize = 12
resetBtn.Parent = mainFrame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 8)
resetCorner.Parent = resetBtn

-- 6. ปุ่มมินิเปิดกลับ (ลอยขอบจอเวลาพับ)
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenButton"
openBtn.Size = UDim2.new(0, 120, 0, 32)
openBtn.Position = UDim2.new(1, -130, 0, 15)
openBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
openBtn.Font = Enum.Font.GothamBold
openBtn.Text = "🚀 Open Hub"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.TextSize = 12
openBtn.Visible = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openBtn

-- 7. ระบบ Drag หน้าจอ (ลากเคลื่อนย้าย Hub ได้ด้วยเมาส์)
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

-- 8. Teleport & Stage Logic
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
		currentStageLabel.Text = "📍 Target Stage: ไม่พบด่าน"
		statusLabel.Text = "สถานะ: ข้อผิดพลาด (ไม่พบ Map3)"
		statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	else
		local currentNum = sortedStages[currentIndex] and sortedStages[currentIndex].number or "-"
		currentStageLabel.Text = "📍 Target Stage: Stage " .. currentNum
		statusLabel.Text = "สถานะ: พร้อมใช้งาน (" .. currentIndex .. "/" .. #sortedStages .. ")"
		statusLabel.TextColor3 = Color3.fromRGB(160, 220, 160)
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

-- Window Control Events
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

-- Initial Run
loadAndSortStages()
updateUI()
