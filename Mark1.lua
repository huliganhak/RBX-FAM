local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- เคลียร์ UI เก่า
for _, oldGui in ipairs(playerGui:GetChildren()) do
	if oldGui.Name == "TrainingTeleportGui" then
		oldGui:Destroy()
	end
end

-- รายชื่อ Train 1 - 5 และ Path เป้าหมาย
local trainLocations = {
	{ Name = "Train 1", Path = {"Map", "Lobby", "Decor", "Extra", "TrainingZone1"} },
	{ Name = "Train 2", Path = {"MapTest", "TrainingZone", "TrainingZone10"} },
	{ Name = "Train 3", Path = {"Map3", "TrainingZone", "TrainingZone19"} },
	{ Name = "Train 4", Path = {"Map4", "TrainingZone", "TrainingZone28"} },
	{ Name = "Train 5", Path = {"Map5", "TrainingZone", "TrainingZone37"} },
}

local selectedIndex = 1

-- 1. ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrainingTeleportGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 2. Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 115)
mainFrame.Position = UDim2.new(0.85, -110, 0.25, 0)
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
titleLabel.Text = "🏋️ Training Teleport"
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

-- 4. Dropdown Button (ปุ่มเลือกลิสต์)
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Name = "DropdownBtn"
dropdownBtn.Size = UDim2.new(1, -16, 0, 28)
dropdownBtn.Position = UDim2.new(0, 8, 0, 34)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
dropdownBtn.Font = Enum.Font.GothamBold
dropdownBtn.Text = "📍 Select: Train 1 ▼"
dropdownBtn.TextColor3 = Color3.fromRGB(85, 205, 255)
dropdownBtn.TextSize = 11
dropdownBtn.Parent = mainFrame

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 6)
dropdownCorner.Parent = dropdownBtn

-- List Frame (รายการให้เลือก 1 - 5)
local listFrame = Instance.new("Frame")
listFrame.Name = "ListFrame"
listFrame.Size = UDim2.new(1, -16, 0, 125)
listFrame.Position = UDim2.new(0, 8, 0, 64)
listFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
listFrame.BorderSizePixel = 0
listFrame.Visible = false
listFrame.ZIndex = 10
listFrame.Parent = mainFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 6)
listCorner.Parent = listFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = listFrame

-- สร้างปุ่มเลือก Train 1 - 5 ใน List
for i, item in ipairs(trainLocations) do
	local itemBtn = Instance.new("TextButton")
	itemBtn.Size = UDim2.new(1, 0, 0, 23)
	itemBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	itemBtn.BackgroundTransparency = 0.2
	itemBtn.Font = Enum.Font.Gotham
	itemBtn.Text = item.Name
	itemBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	itemBtn.TextSize = 11
	itemBtn.ZIndex = 11
	itemBtn.Parent = listFrame
	
	itemBtn.MouseButton1Click:Connect(function()
		selectedIndex = i
		dropdownBtn.Text = "📍 Select: " .. item.Name .. " ▼"
		listFrame.Visible = false
	end)
end

-- 5. Teleport Button (ปุ่มกดวาป)
local warpBtn = Instance.new("TextButton")
warpBtn.Name = "WarpBtn"
warpBtn.Size = UDim2.new(1, -16, 0, 32)
warpBtn.Position = UDim2.new(0, 8, 0, 70)
warpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
warpBtn.Font = Enum.Font.GothamBold
warpBtn.Text = "⚡ Teleport"
warpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
warpBtn.TextSize = 12
warpBtn.Parent = mainFrame

local warpCorner = Instance.new("UICorner")
warpCorner.CornerRadius = UDim.new(0, 6)
warpCorner.Parent = warpBtn

-- 6. ปุ่มเปิดมินิ (เวลาพับ)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 95, 0, 26)
openBtn.Position = UDim2.new(1, -105, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
openBtn.Font = Enum.Font.GothamBold
openBtn.Text = "🏋️ Training"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.TextSize = 11
openBtn.Visible = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 6)
openCorner.Parent = openBtn

-- 7. ระบบ Drag ย้ายหน้าต่าง
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

-- 8. ฟังก์ชันค้นหา Object จาก Path แบบปลอดภัย
local function getTargetObject(pathArray)
	local current = workspace
	for _, name in ipairs(pathArray) do
		current = current:FindFirstChild(name)
		if not current then
			return nil
		end
	end
	return current
end

-- 9. ฟังก์ชัน Teleport
local function teleportToTarget()
	local selectedData = trainLocations[selectedIndex]
	if not selectedData then return end

	local targetObj = getTargetObject(selectedData.Path)
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if targetObj and hrp then
		-- ตรวจสอบว่าเป้าหมายเป็น BasePart หรือ Model/Folder
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
		else
			warn("ไม่สามารถหาตำแหน่ง CFrame ของ " .. selectedData.Name .. " ได้")
		end
	else
		warn("ไม่พบตำแหน่ง: " .. selectedData.Name .. " ใน Workspace")
	end
end

-- Events
dropdownBtn.MouseButton1Click:Connect(function()
	listFrame.Visible = not listFrame.Visible
end)

warpBtn.MouseButton1Click:Connect(teleportToTarget)

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
	screenGui:Destroy()
end)
