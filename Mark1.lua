local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- 1. เคลียร์ UI เก่า
for _, oldGui in ipairs(playerGui:GetChildren()) do
	if oldGui.Name == "StageWarpHubGui" or oldGui.Name == "TrainingTeleportGui" then
		oldGui:Destroy()
	end
end

-- ข้อมูล Map
local mapList = {
	{ Name = "Map 3", WorkspaceName = "Map3" },
	{ Name = "Map 4", WorkspaceName = "Map4" },
	{ Name = "Map 5", WorkspaceName = "Map5" },
	{ Name = "Map 6", WorkspaceName = "Map6" },
	{ Name = "Map 7", WorkspaceName = "Map7" },
	{ Name = "Map 8", WorkspaceName = "Map8" },
	{ Name = "Map 9", WorkspaceName = "Map9" },
	{ Name = "Map 10", WorkspaceName = "Map10" },
}

-- ข้อมูล Training Zone
local trainLocations = {
	{ Name = "Train 1", Path = {"Map", "Lobby", "Decor", "Extra", "TrainingZone1"} },
	{ Name = "Train 2", Path = {"MapTest", "TrainingZone", "TrainingZone10"} },
	{ Name = "Train 3", Path = {"Map3", "TrainingZone", "TrainingZone19"} },
	{ Name = "Train 4", Path = {"Map4", "TrainingZone", "TrainingZone28"} },
	{ Name = "Train 5", Path = {"Map5", "TrainingZone", "TrainingZone37"} },
	{ Name = "Train 6", Path = {"Map6", "TrainingZone", "TrainingZone46"} },
	{ Name = "Train 7", Path = {"Map7", "TrainingZone", "TrainingZone55"} },
	{ Name = "Train 8", Path = {"Map8", "TrainingZone", "TrainingZone64"} },
	{ Name = "Train 9", Path = {"Map9", "TrainingZone", "TrainingZone73"} },
	{ Name = "Train 10", Path = {"Map10", "TrainingZone", "TrainingZone82"} },
}

local selectedMapIndex = 1
local selectedTrainIndex = 1
local sortedStages = {}
local currentIndex = 1
local currentSpawnedIndex = 1
local targetEndStageIndex = nil

local autoLoopActive = false
local autoClickActive = false
local autoRebirthActive = false
local autoEndlessActive = false
local antiAfkActive = false
local antiGamePauseActive = false
local isClaiming = false

-- Fly Variables
local isFlying = false
local flySpeed = 50
local linearVelocity = nil
local alignOrientation = nil
local flyAttachment = nil
local flyRenderConnection = nil

local idleConnection = nil

-- Safe Remote Helper (ป้องกัน Warning / Error ติดค้าง)
local function getRemote(parent, name)
	if not parent then return nil end
	return parent:FindFirstChild(name)
end

-- 2. ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StageWarpHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 3. Main Frame (ขยายความสูงรองรับปุ่ม Fly)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 230, 0, 491)
mainFrame.Position = UDim2.new(0.85, -115, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Top Bar
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

-- Dropdown Map
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

local mapListFrame = Instance.new("ScrollingFrame")
mapListFrame.Name = "MapListFrame"
mapListFrame.Size = UDim2.new(1, -16, 0, 110)
mapListFrame.Position = UDim2.new(0, 8, 0, 60)
mapListFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mapListFrame.BorderSizePixel = 0
mapListFrame.Visible = false
mapListFrame.ZIndex = 30
mapListFrame.ScrollBarThickness = 4
mapListFrame.CanvasSize = UDim2.new(0, 0, 0, #mapList * 22)
mapListFrame.Parent = mainFrame

local mapListCorner = Instance.new("UICorner")
mapListCorner.CornerRadius = UDim.new(0, 6)
mapListCorner.Parent = mapListFrame

local mapListLayout = Instance.new("UIListLayout")
mapListLayout.Padding = UDim.new(0, 2)
mapListLayout.Parent = mapListFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -16, 0, 16)
statusLabel.Position = UDim2.new(0, 8, 0, 62)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "📍 Target: Stage - (0/0)"
statusLabel.TextColor3 = Color3.fromRGB(85, 205, 255)
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local stageStateLabel = Instance.new("TextLabel")
stageStateLabel.Name = "StageStateLabel"
stageStateLabel.Size = UDim2.new(1, -16, 0, 16)
stageStateLabel.Position = UDim2.new(0, 8, 0, 78)
stageStateLabel.BackgroundTransparency = 1
stageStateLabel.Font = Enum.Font.GothamBold
stageStateLabel.Text = "👾 Status: Unknown"
stageStateLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
stageStateLabel.TextSize = 10
stageStateLabel.TextXAlignment = Enum.TextXAlignment.Left
stageStateLabel.Parent = mainFrame

-- Stage Controls
local claimBtn = Instance.new("TextButton")
claimBtn.Size = UDim2.new(0, 55, 0, 26)
claimBtn.Position = UDim2.new(0, 8, 0, 98)
claimBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
claimBtn.Font = Enum.Font.GothamBold
claimBtn.Text = "🎁 Claim"
claimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
claimBtn.TextSize = 10
claimBtn.Parent = mainFrame

local claimCorner = Instance.new("UICorner")
claimCorner.CornerRadius = UDim.new(0, 6)
claimCorner.Parent = claimBtn

local nextBtn = Instance.new("TextButton")
nextBtn.Size = UDim2.new(1, -101, 0, 26)
nextBtn.Position = UDim2.new(0, 67, 0, 98)
nextBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
nextBtn.Font = Enum.Font.GothamBold
nextBtn.Text = "⚡ Teleport Next"
nextBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
nextBtn.TextSize = 10
nextBtn.Parent = mainFrame

local nextCorner = Instance.new("UICorner")
nextCorner.CornerRadius = UDim.new(0, 6)
nextCorner.Parent = nextBtn

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0, 24, 0, 26)
resetBtn.Position = UDim2.new(1, -32, 0, 98)
resetBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Text = "🔄"
resetBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
resetBtn.TextSize = 11
resetBtn.Parent = mainFrame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetBtn

-- Target Stage Dropdown
local targetStageDropdownBtn = Instance.new("TextButton")
targetStageDropdownBtn.Size = UDim2.new(1, -16, 0, 26)
targetStageDropdownBtn.Position = UDim2.new(0, 8, 0, 130)
targetStageDropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
targetStageDropdownBtn.Font = Enum.Font.GothamBold
targetStageDropdownBtn.Text = "🎯 Auto Stop Stage: Select ▼"
targetStageDropdownBtn.TextColor3 = Color3.fromRGB(255, 170, 0)
targetStageDropdownBtn.TextSize = 10
targetStageDropdownBtn.Parent = mainFrame

local targetStageDropdownCorner = Instance.new("UICorner")
targetStageDropdownCorner.CornerRadius = UDim.new(0, 6)
targetStageDropdownCorner.Parent = targetStageDropdownBtn

local targetStageScrollFrame = Instance.new("ScrollingFrame")
targetStageScrollFrame.Size = UDim2.new(1, -16, 0, 120)
targetStageScrollFrame.Position = UDim2.new(0, 8, 0, 158)
targetStageScrollFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
targetStageScrollFrame.BorderSizePixel = 0
targetStageScrollFrame.Visible = false
targetStageScrollFrame.ZIndex = 25
targetStageScrollFrame.ScrollBarThickness = 4
targetStageScrollFrame.Parent = mainFrame

local targetStageScrollCorner = Instance.new("UICorner")
targetStageScrollCorner.CornerRadius = UDim.new(0, 6)
targetStageScrollCorner.Parent = targetStageScrollFrame

local targetStageListLayout = Instance.new("UIListLayout")
targetStageListLayout.Padding = UDim.new(0, 2)
targetStageListLayout.Parent = targetStageScrollFrame

-- Start Stop Auto Loop
local startStopToggleBtn = Instance.new("TextButton")
startStopToggleBtn.Size = UDim2.new(1, -16, 0, 26)
startStopToggleBtn.Position = UDim2.new(0, 8, 0, 162)
startStopToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
startStopToggleBtn.Font = Enum.Font.GothamBold
startStopToggleBtn.Text = "▶️ Start Auto Loop"
startStopToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startStopToggleBtn.TextSize = 10
startStopToggleBtn.Parent = mainFrame

local startStopToggleCorner = Instance.new("UICorner")
startStopToggleCorner.CornerRadius = UDim.new(0, 6)
startStopToggleCorner.Parent = startStopToggleBtn

-- Train Dropdown
local trainDropdownBtn = Instance.new("TextButton")
trainDropdownBtn.Size = UDim2.new(1, -48, 0, 26)
trainDropdownBtn.Position = UDim2.new(0, 8, 0, 194)
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
trainWarpBtn.Size = UDim2.new(0, 28, 0, 26)
trainWarpBtn.Position = UDim2.new(1, -36, 0, 194)
trainWarpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 230)
trainWarpBtn.Font = Enum.Font.GothamBold
trainWarpBtn.Text = "GO"
trainWarpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
trainWarpBtn.TextSize = 10
trainWarpBtn.Parent = mainFrame

local trainWarpCorner = Instance.new("UICorner")
trainWarpCorner.CornerRadius = UDim.new(0, 6)
trainWarpCorner.Parent = trainWarpBtn

local trainListFrame = Instance.new("ScrollingFrame")
trainListFrame.Size = UDim2.new(1, -48, 0, 110)
trainListFrame.Position = UDim2.new(0, 8, 0, 222)
trainListFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
trainListFrame.BorderSizePixel = 0
trainListFrame.Visible = false
trainListFrame.ZIndex = 20
trainListFrame.ScrollBarThickness = 4
trainListFrame.CanvasSize = UDim2.new(0, 0, 0, #trainLocations * 22)
trainListFrame.Parent = mainFrame

local trainListCorner = Instance.new("UICorner")
trainListCorner.CornerRadius = UDim.new(0, 6)
trainListCorner.Parent = trainListFrame

local trainListLayout = Instance.new("UIListLayout")
trainListLayout.Padding = UDim.new(0, 2)
trainListLayout.Parent = trainListFrame

-- Event Buttons
local endlessBtn = Instance.new("TextButton")
endlessBtn.Size = UDim2.new(0.5, -11, 0, 26)
endlessBtn.Position = UDim2.new(0, 8, 0, 226)
endlessBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 180)
endlessBtn.Font = Enum.Font.GothamBold
endlessBtn.Text = "♾️ Endless"
endlessBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
endlessBtn.TextSize = 10
endlessBtn.Parent = mainFrame

local endlessCorner = Instance.new("UICorner")
endlessCorner.CornerRadius = UDim.new(0, 6)
endlessCorner.Parent = endlessBtn

local bossEventBtn = Instance.new("TextButton")
bossEventBtn.Size = UDim2.new(0.5, -11, 0, 26)
bossEventBtn.Position = UDim2.new(0.5, 3, 0, 226)
bossEventBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
bossEventBtn.Font = Enum.Font.GothamBold
bossEventBtn.Text = "👹 Boss Event"
bossEventBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
bossEventBtn.TextSize = 10
bossEventBtn.Parent = mainFrame

local bossEventCorner = Instance.new("UICorner")
bossEventCorner.CornerRadius = UDim.new(0, 6)
bossEventCorner.Parent = bossEventBtn

-- Auto Re-Endless
local autoEndlessToggleBtn = Instance.new("TextButton")
autoEndlessToggleBtn.Size = UDim2.new(1, -16, 0, 26)
autoEndlessToggleBtn.Position = UDim2.new(0, 8, 0, 258)
autoEndlessToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
autoEndlessToggleBtn.Font = Enum.Font.GothamBold
autoEndlessToggleBtn.Text = "🔄 Auto Re-Endless: OFF"
autoEndlessToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
autoEndlessToggleBtn.TextSize = 10
autoEndlessToggleBtn.Parent = mainFrame

local autoEndlessCorner = Instance.new("UICorner")
autoEndlessCorner.CornerRadius = UDim.new(0, 6)
autoEndlessCorner.Parent = autoEndlessToggleBtn

-- Auto Click & Auto Rebirth
local clickToggleBtn = Instance.new("TextButton")
clickToggleBtn.Size = UDim2.new(1, -16, 0, 26)
clickToggleBtn.Position = UDim2.new(0, 8, 0, 290)
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
rebirthToggleBtn.Position = UDim2.new(0, 8, 0, 322)
rebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
rebirthToggleBtn.Font = Enum.Font.GothamBold
rebirthToggleBtn.Text = "♻️ Auto Rebirth: OFF"
rebirthToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
rebirthToggleBtn.TextSize = 10
rebirthToggleBtn.Parent = mainFrame

local rebirthToggleCorner = Instance.new("UICorner")
rebirthToggleCorner.CornerRadius = UDim.new(0, 6)
rebirthToggleCorner.Parent = rebirthToggleBtn

-- Fly Mode Button
local flyToggleBtn = Instance.new("TextButton")
flyToggleBtn.Name = "FlyToggleBtn"
flyToggleBtn.Size = UDim2.new(1, -16, 0, 26)
flyToggleBtn.Position = UDim2.new(0, 8, 0, 354)
flyToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
flyToggleBtn.Font = Enum.Font.GothamBold
flyToggleBtn.Text = "🕊️ Fly Mode: OFF (E)"
flyToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
flyToggleBtn.TextSize = 10
flyToggleBtn.Parent = mainFrame

local flyToggleCorner = Instance.new("UICorner")
flyToggleCorner.CornerRadius = UDim.new(0, 6)
flyToggleCorner.Parent = flyToggleBtn

-- Anti-AFK & Anti-Pause
local antiAfkToggleBtn = Instance.new("TextButton")
antiAfkToggleBtn.Size = UDim2.new(1, -16, 0, 26)
antiAfkToggleBtn.Position = UDim2.new(0, 8, 0, 386)
antiAfkToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
antiAfkToggleBtn.Font = Enum.Font.GothamBold
antiAfkToggleBtn.Text = "🛡️ Anti-AFK: OFF"
antiAfkToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
antiAfkToggleBtn.TextSize = 10
antiAfkToggleBtn.Parent = mainFrame

local antiAfkCorner = Instance.new("UICorner")
antiAfkCorner.CornerRadius = UDim.new(0, 6)
antiAfkCorner.Parent = antiAfkToggleBtn

local antiPauseToggleBtn = Instance.new("TextButton")
antiPauseToggleBtn.Size = UDim2.new(1, -16, 0, 26)
antiPauseToggleBtn.Position = UDim2.new(0, 8, 0, 418)
antiPauseToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
antiPauseToggleBtn.Font = Enum.Font.GothamBold
antiPauseToggleBtn.Text = "⏸️ Anti-GamePause: OFF"
antiPauseToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
antiPauseToggleBtn.TextSize = 10
antiPauseToggleBtn.Parent = mainFrame

local antiPauseCorner = Instance.new("UICorner")
antiPauseCorner.CornerRadius = UDim.new(0, 6)
antiPauseCorner.Parent = antiPauseToggleBtn

-- Open Button
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

-- Drag System
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

-- Fly / Unfly System Logic
local function stopFly()
	isFlying = false
	flyToggleBtn.Text = "🕊️ Fly Mode: OFF (E)"
	flyToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	flyToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

	if flyRenderConnection then
		flyRenderConnection:Disconnect()
		flyRenderConnection = nil
	end

	if linearVelocity then linearVelocity:Destroy() end
	if alignOrientation then alignOrientation:Destroy() end
	if flyAttachment then flyAttachment:Destroy() end

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = false
		end
	end
end

local function startFly()
	local character = player.Character
	if not character then return end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	isFlying = true
	flyToggleBtn.Text = "🕊️ Fly Mode: ON (E)"
	flyToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
	flyToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)

	humanoid.PlatformStand = true

	flyAttachment = Instance.new("Attachment")
	flyAttachment.Name = "FlyAttachment"
	flyAttachment.Parent = hrp

	linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = flyAttachment
	linearVelocity.MaxForce = 999999
	linearVelocity.VectorVelocity = Vector3.zero
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.Parent = hrp

	alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = flyAttachment
	alignOrientation.MaxTorque = 999999
	alignOrientation.Responsiveness = 200
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Parent = hrp

	flyRenderConnection = RunService.RenderStepped:Connect(function()
		if not isFlying then return end

		alignOrientation.CFrame = camera.CFrame

		local moveVector = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveVector = moveVector + camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveVector = moveVector - camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveVector = moveVector - camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveVector = moveVector + camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveVector = moveVector + Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			moveVector = moveVector - Vector3.new(0, 1, 0)
		end

		if moveVector.Magnitude > 0 then
			linearVelocity.VectorVelocity = moveVector.Unit * flySpeed
		else
			linearVelocity.VectorVelocity = Vector3.zero
		end
	end)
end

local function toggleFly()
	if isFlying then
		stopFly()
	else
		startFly()
	end
end

flyToggleBtn.MouseButton1Click:Connect(toggleFly)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.E then
		toggleFly()
	end
end)

-- Map & Stage System
local function updateTargetStageDropdownList()
	for _, child in ipairs(targetStageScrollFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for index, stageData in ipairs(sortedStages) do
		local stageBtn = Instance.new("TextButton")
		stageBtn.Size = UDim2.new(1, -8, 0, 20)
		stageBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
		stageBtn.Font = Enum.Font.Gotham
		stageBtn.Text = "Stage " .. stageData.number
		stageBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
		stageBtn.TextSize = 10
		stageBtn.ZIndex = 26
		stageBtn.Parent = targetStageScrollFrame

		stageBtn.MouseButton1Click:Connect(function()
			targetEndStageIndex = index
			targetStageDropdownBtn.Text = "🎯 Auto Stop Stage: " .. stageData.number .. " ▼"
			targetStageScrollFrame.Visible = false
		end)
	end

	targetStageScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #sortedStages * 22)
end

local function loadAndSortStages()
	sortedStages = {}
	currentIndex = 1
	currentSpawnedIndex = 1
	targetEndStageIndex = nil
	targetStageDropdownBtn.Text = "🎯 Auto Stop Stage: Select ▼"
	
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

	updateTargetStageDropdownList()
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

local isStageClear = false

local function teleportToNextStage()
	if #sortedStages == 0 then loadAndSortStages() end
	if #sortedStages == 0 then return end

	local currentStageData = sortedStages[currentIndex]
	if not currentStageData then return end

	local spawnPart = currentStageData.folder:FindFirstChild("Spawn")
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if spawnPart and hrp then
		isStageClear = false 
		stageStateLabel.Text = "👾 Status: Checking..."
		stageStateLabel.TextColor3 = Color3.fromRGB(255, 200, 100)

		hrp.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
		currentSpawnedIndex = currentIndex
		currentIndex = currentIndex + 1
		if currentIndex > #sortedStages then currentIndex = 1 end
		updateUI()
	end
end

local function claimTargetStage()
	if isClaiming then return end
	isClaiming = true

	if #sortedStages == 0 then loadAndSortStages() end
	if #sortedStages == 0 then 
		isClaiming = false
		return 
	end

	local targetClaimIdx = currentSpawnedIndex + 1
	if targetClaimIdx > #sortedStages then targetClaimIdx = #sortedStages end

	local currentStageData = sortedStages[targetClaimIdx]
	if not currentStageData then 
		isClaiming = false
		return 
	end

	local padFolder = currentStageData.folder:FindFirstChild("Pad")
	local freePart = padFolder and padFolder:FindFirstChild("Free")
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if freePart and hrp then
		local targetCFrame
		if freePart:IsA("BasePart") then
			targetCFrame = freePart.CFrame
		elseif freePart:IsA("Model") then
			targetCFrame = freePart:GetPivot()
		else
			local childPart = freePart:FindFirstChildWhichIsA("BasePart", true)
			if childPart then targetCFrame = childPart.CFrame end
		end

		if targetCFrame then
			hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
			task.wait(2)
			currentIndex = 1
			currentSpawnedIndex = 1
			updateUI()
			
			if autoLoopActive then
				teleportToNextStage()
			end
		end
	end
	
	isClaiming = false
end

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

-- Stage Detector Loop
task.spawn(function()
	while true do
		pcall(function()
			local currentStageData = sortedStages[currentSpawnedIndex]
			
			if currentStageData and currentStageData.folder then
				local barrierFolder = currentStageData.folder:FindFirstChild("Barrier")
				local innerBarrier = barrierFolder and barrierFolder:FindFirstChild("Barrier")
				local infoGui = innerBarrier and innerBarrier:FindFirstChild("InfoGui")
				
				if infoGui then
					if infoGui.Enabled then
						stageStateLabel.Text = "👾 Status: Enemy"
						stageStateLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
						isStageClear = false
					else
						stageStateLabel.Text = "👾 Status: Clear"
						stageStateLabel.TextColor3 = Color3.fromRGB(85, 255, 120)
						isStageClear = true
					end
				else
					stageStateLabel.Text = "👾 Status: Clear"
					stageStateLabel.TextColor3 = Color3.fromRGB(85, 255, 120)
					isStageClear = true
				end
			else
				stageStateLabel.Text = "👾 Status: Unknown"
				stageStateLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
				isStageClear = false
			end
		end)
		task.wait(0.1)
	end
end)

-- Auto Loops (Safe Remote Connection)
task.spawn(function()
	while true do
		if autoLoopActive and not isClaiming then
			if isStageClear then
				if targetEndStageIndex and currentSpawnedIndex == targetEndStageIndex then
					claimTargetStage()
				else
					teleportToNextStage()
					task.wait(1)
				end
			end
		end
		task.wait(0.5)
	end
end)

task.spawn(function()
	while true do
		if autoEndlessActive then
			local inEndless = false
			for _, child in ipairs(workspace:GetChildren()) do
				if string.find(child.Name, "EndlessEnemies") then
					inEndless = true
					break
				end
			end

			if not inEndless then
				pcall(function()
					local shared = getRemote(ReplicatedStorage, "Shared")
					local remotes = getRemote(shared, "Remotes")
					local endlessRemote = getRemote(remotes, "EndlessJoinRequest")
					if endlessRemote then endlessRemote:FireServer(6) end
				end)
				task.wait(3)
			end
		end
		task.wait(1)
	end
end)

task.spawn(function()
	while true do
		if autoClickActive then
			pcall(function()
				local shared = getRemote(ReplicatedStorage, "Shared")
				local remotes = getRemote(shared, "Remotes")
				local clickRemote = getRemote(remotes, "PlayerClick")
				if clickRemote then clickRemote:FireServer() end
			end)
		end
		task.wait(0.1)
	end
end)

task.spawn(function()
	while true do
		if autoRebirthActive then
			pcall(function()
				local shared = getRemote(ReplicatedStorage, "Shared")
				local remotes = getRemote(shared, "Remotes")
				local rebirthRemote = getRemote(remotes, "RequestRebirth")
				if rebirthRemote then rebirthRemote:InvokeServer() end
			end)
		end
		task.wait(0.5)
	end
end)

-- Event Listeners
mapDropdownBtn.MouseButton1Click:Connect(function()
	mapListFrame.Visible = not mapListFrame.Visible
	targetStageScrollFrame.Visible = false
	trainListFrame.Visible = false
end)

targetStageDropdownBtn.MouseButton1Click:Connect(function()
	targetStageScrollFrame.Visible = not targetStageScrollFrame.Visible
	mapListFrame.Visible = false
	trainListFrame.Visible = false
end)

trainDropdownBtn.MouseButton1Click:Connect(function()
	trainListFrame.Visible = not trainListFrame.Visible
	mapListFrame.Visible = false
	targetStageScrollFrame.Visible = false
end)

trainWarpBtn.MouseButton1Click:Connect(teleportToTrain)

endlessBtn.MouseButton1Click:Connect(function()
	pcall(function()
		local shared = getRemote(ReplicatedStorage, "Shared")
		local remotes = getRemote(shared, "Remotes")
		local endlessRemote = getRemote(remotes, "EndlessJoinRequest")
		if endlessRemote then endlessRemote:FireServer(6) end
	end)
end)

bossEventBtn.MouseButton1Click:Connect(function()
	pcall(function()
		local shared = getRemote(ReplicatedStorage, "Shared")
		local remotes = getRemote(shared, "Remotes")
		local bossRemote = getRemote(remotes, "BossEventResponse")
		if bossRemote then bossRemote:FireServer(true) end
	end)
end)

autoEndlessToggleBtn.MouseButton1Click:Connect(function()
	autoEndlessActive = not autoEndlessActive
	autoEndlessToggleBtn.Text = autoEndlessActive and "🔄 Auto Re-Endless: ON" or "🔄 Auto Re-Endless: OFF"
	autoEndlessToggleBtn.TextColor3 = autoEndlessActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
	autoEndlessToggleBtn.BackgroundColor3 = autoEndlessActive and Color3.fromRGB(20, 60, 30) or Color3.fromRGB(40, 40, 50)
end)

startStopToggleBtn.MouseButton1Click:Connect(function()
	autoLoopActive = not autoLoopActive
	if autoLoopActive then
		startStopToggleBtn.Text = "⏹️ Stop Auto Loop"
		startStopToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
		teleportToNextStage()
	else
		startStopToggleBtn.Text = "▶️ Start Auto Loop"
		startStopToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
	end
end)

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

antiAfkToggleBtn.MouseButton1Click:Connect(function()
	antiAfkActive = not antiAfkActive
	if antiAfkActive then
		antiAfkToggleBtn.Text = "🛡️ Anti-AFK: ON"
		antiAfkToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
		antiAfkToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
		
		idleConnection = player.Idled:Connect(function()
			if antiAfkActive then
				VirtualUser:Button2Down(Vector2.zero, camera.CFrame)
				task.wait(1)
				VirtualUser:Button2Up(Vector2.zero, camera.CFrame)
			end
		end)
	else
		antiAfkToggleBtn.Text = "🛡️ Anti-AFK: OFF"
		antiAfkToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
		antiAfkToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		if idleConnection then idleConnection:Disconnect() end
	end
end)

antiPauseToggleBtn.MouseButton1Click:Connect(function()
	antiGamePauseActive = not antiGamePauseActive
	if antiGamePauseActive then
		antiPauseToggleBtn.Text = "⏸️ Anti-GamePause: ON"
		antiPauseToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
		antiPauseToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
		
		pcall(function()
			local targetScript = CoreGui:FindFirstChild("RobloxGui") and CoreGui.RobloxGui:FindFirstChild("CoreScripts/NetworkPause", true)
			if targetScript then targetScript:Destroy() end
		end)
	else
		antiPauseToggleBtn.Text = "⏸️ Anti-GamePause: OFF"
		antiPauseToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
		antiPauseToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	end
end)

claimBtn.MouseButton1Click:Connect(claimTargetStage)
nextBtn.MouseButton1Click:Connect(teleportToNextStage)

resetBtn.MouseButton1Click:Connect(function()
	currentIndex = 1
	currentSpawnedIndex = 1
	updateUI()
end)

minBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	mapListFrame.Visible = false
	targetStageScrollFrame.Visible = false
	trainListFrame.Visible = false
	openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openBtn.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
	autoLoopActive = false
	autoClickActive = false
	autoRebirthActive = false
	autoEndlessActive = false
	antiAfkActive = false
	stopFly()
	if idleConnection then idleConnection:Disconnect() end
	screenGui:Destroy()
end)

-- Initial Load
loadAndSortStages()
updateUI()
