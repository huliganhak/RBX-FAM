local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 325)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = frame

local root = Instance.new("Frame")
root.BackgroundTransparency = 1
root.Size = UDim2.new(1, 0, 1, 0)
root.Parent = frame

local rootLayout = Instance.new("UIListLayout")
rootLayout.FillDirection = Enum.FillDirection.Vertical
rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
rootLayout.Padding = UDim.new(0, 10)
rootLayout.Parent = root

local title = Instance.new("TextLabel")
title.LayoutOrder = 1
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "Teleport / Monster TP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = root

-- ===== Minimize button =====
local minimized = false
local fullSize = frame.Size

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -28, 0, 0)
minBtn.AnchorPoint = Vector2.new(1, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Text = "–"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.Parent = title
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		for _, child in ipairs(root:GetChildren()) do
			if child ~= title and child:IsA("GuiObject") then
				child.Visible = false
			end
		end
		frame.Size = UDim2.new(fullSize.X.Scale, fullSize.X.Offset, 0, 55)
		minBtn.Text = "+"
	else
		for _, child in ipairs(root:GetChildren()) do
			if child ~= title and child:IsA("GuiObject") then
				child.Visible = true
			end
		end
		frame.Size = fullSize
		minBtn.Text = "–"
	end
end)

local function makeBox(placeholder)
	local box = Instance.new("TextBox")
	box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.Gotham
	box.TextSize = 16
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
	return box
end

local function makeLabel(text, w)
	local lb = Instance.new("TextLabel")
	lb.Size = UDim2.new(0, w, 1, 0)
	lb.BackgroundTransparency = 1
	lb.Text = text
	lb.TextColor3 = Color3.fromRGB(220, 220, 220)
	lb.Font = Enum.Font.Gotham
	lb.TextSize = 14
	lb.TextXAlignment = Enum.TextXAlignment.Left
	return lb
end

-- ===== Row X Y Z =====
local rowXYZ = Instance.new("Frame")
rowXYZ.LayoutOrder = 2
rowXYZ.Size = UDim2.new(1, 0, 0, 40)
rowXYZ.BackgroundTransparency = 1
rowXYZ.Parent = root

local xyzLayout = Instance.new("UIListLayout")
xyzLayout.FillDirection = Enum.FillDirection.Horizontal
xyzLayout.SortOrder = Enum.SortOrder.LayoutOrder
xyzLayout.Padding = UDim.new(0, 10)
xyzLayout.Parent = rowXYZ

local xBox = makeBox("X"); xBox.LayoutOrder = 1; xBox.Size = UDim2.new(1/3, -7, 1, 0); xBox.Parent = rowXYZ
local yBox = makeBox("Y"); yBox.LayoutOrder = 2; yBox.Size = UDim2.new(1/3, -7, 1, 0); yBox.Parent = rowXYZ
local zBox = makeBox("Z"); zBox.LayoutOrder = 3; zBox.Size = UDim2.new(1/3, -7, 1, 0); zBox.Parent = rowXYZ

xBox.Text = "-390"
yBox.Text = "6000"
zBox.Text = "-30.5"

-- ===== Row จำนวน / หน่วง / วนลูป =====
local rowOpt = Instance.new("Frame")
rowOpt.LayoutOrder = 3
rowOpt.Size = UDim2.new(1, 0, 0, 34)
rowOpt.BackgroundTransparency = 1
rowOpt.Parent = root

local optLayout = Instance.new("UIListLayout")
optLayout.FillDirection = Enum.FillDirection.Horizontal
optLayout.SortOrder = Enum.SortOrder.LayoutOrder
optLayout.Padding = UDim.new(0, 10)
optLayout.Parent = rowOpt

local countLabel = makeLabel("จำนวน:", 55); countLabel.Parent = rowOpt
local countBox = makeBox("1"); countBox.Size = UDim2.new(0, 60, 1, 0); countBox.Text = "1"; countBox.Parent = rowOpt

local delayLabel = makeLabel("หน่วง:", 45); delayLabel.Parent = rowOpt
local delayBox = makeBox("0.2"); delayBox.Size = UDim2.new(0, 60, 1, 0); delayBox.Text = "0.2"; delayBox.Parent = rowOpt

local loopGroup = Instance.new("Frame")
loopGroup.BackgroundTransparency = 1
loopGroup.Size = UDim2.new(1, - (55+60+45+60+40), 1, 0)
loopGroup.Parent = rowOpt

local loopLayout = Instance.new("UIListLayout")
loopLayout.FillDirection = Enum.FillDirection.Horizontal
loopLayout.SortOrder = Enum.SortOrder.LayoutOrder
loopLayout.Padding = UDim.new(0, 8)
loopLayout.Parent = loopGroup

local cbBtn = Instance.new("TextButton")
cbBtn.Size = UDim2.new(0, 24, 0, 24)
cbBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
cbBtn.Text = ""
cbBtn.Parent = loopGroup
Instance.new("UICorner", cbBtn).CornerRadius = UDim.new(0, 6)

local cbMark = Instance.new("TextLabel")
cbMark.Size = UDim2.new(1, 0, 1, 0)
cbMark.BackgroundTransparency = 1
cbMark.Text = "✓"
cbMark.TextColor3 = Color3.fromRGB(60, 160, 80)
cbMark.Font = Enum.Font.GothamBold
cbMark.TextSize = 18
cbMark.Visible = false
cbMark.Parent = cbBtn

local cbText = makeLabel("วนลูป", 60)
cbText.Parent = loopGroup

-- ===== Buttons TP XYZ =====
local okBtn = Instance.new("TextButton")
okBtn.LayoutOrder = 4
okBtn.Size = UDim2.new(1, 0, 0, 40)
okBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
okBtn.Text = "OK (Teleport XYZ)"
okBtn.Font = Enum.Font.GothamBold
okBtn.TextSize = 16
okBtn.Parent = root
Instance.new("UICorner", okBtn).CornerRadius = UDim.new(0, 12)

local stopBtn = Instance.new("TextButton")
stopBtn.LayoutOrder = 5
stopBtn.Size = UDim2.new(1, 0, 0, 34)
stopBtn.BackgroundColor3 = Color3.fromRGB(160, 70, 70)
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Text = "STOP"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.Visible = false
stopBtn.Parent = root
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 12)

-- ===== Monster TP UI =====
local monsterTitle = Instance.new("TextLabel")
monsterTitle.LayoutOrder = 6
monsterTitle.Size = UDim2.new(1, 0, 0, 18)
monsterTitle.BackgroundTransparency = 1
monsterTitle.Text = "Monster TP (workspace.Monsters[MapId][MonsterId])"
monsterTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
monsterTitle.Font = Enum.Font.Gotham
monsterTitle.TextSize = 12
monsterTitle.TextXAlignment = Enum.TextXAlignment.Left
monsterTitle.Parent = root

local rowMonster = Instance.new("Frame")
rowMonster.LayoutOrder = 7
rowMonster.Size = UDim2.new(1, 0, 0, 40)
rowMonster.BackgroundTransparency = 1
rowMonster.Parent = root

local mLayout = Instance.new("UIListLayout")
mLayout.FillDirection = Enum.FillDirection.Horizontal
mLayout.SortOrder = Enum.SortOrder.LayoutOrder
mLayout.Padding = UDim.new(0, 10)
mLayout.Parent = rowMonster

local mapBox = makeBox("MapId เช่น 010")
mapBox.Size = UDim2.new(0.5, -5, 1, 0)
mapBox.Text = "010"
mapBox.Parent = rowMonster

local monsterBox = makeBox("MonsterId เช่น 001")
monsterBox.Size = UDim2.new(0.5, -5, 1, 0)
monsterBox.Text = "001"
monsterBox.Parent = rowMonster

local tpMonsterBtn = Instance.new("TextButton")
tpMonsterBtn.LayoutOrder = 8
tpMonsterBtn.Size = UDim2.new(1, 0, 0, 38)
tpMonsterBtn.BackgroundColor3 = Color3.fromRGB(70, 120, 170)
tpMonsterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpMonsterBtn.Text = "TP หา Monster ใกล้สุด"
tpMonsterBtn.Font = Enum.Font.GothamBold
tpMonsterBtn.TextSize = 15
tpMonsterBtn.Parent = root
Instance.new("UICorner", tpMonsterBtn).CornerRadius = UDim.new(0, 12)

local msg = Instance.new("TextLabel")
msg.LayoutOrder = 9
msg.Size = UDim2.new(1, 0, 0, 18)
msg.BackgroundTransparency = 1
msg.Text = ""
msg.TextColor3 = Color3.fromRGB(255, 200, 80)
msg.Font = Enum.Font.Gotham
msg.TextSize = 12
msg.TextXAlignment = Enum.TextXAlignment.Left
msg.Parent = root

-- ===== Drag to move (ลากย้าย UI) =====
do
	local UIS = game:GetService("UserInputService")
	local dragging = false
	local dragStart
	local startPos

	local function update(pos)
		local delta = pos - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
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

	UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			update(input.Position)
		end
	end)
end

-- ===== Logic =====
local loopEnabled = false
local loopRunning = false
local loopToken = 0

local function teleportToXYZ(x, y, z)
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		msg.Text = "ไม่พบ HumanoidRootPart"
		return false
	end
	hrp.CFrame = CFrame.new(Vector3.new(x, y, z))
	return true
end

local function parseXYZInputs()
	local x = tonumber(xBox.Text)
	local y = tonumber(yBox.Text)
	local z = tonumber(zBox.Text)

	local count = tonumber(countBox.Text)
	local delay = tonumber(delayBox.Text)

	if not x or not y or not z then
		return nil, "กรุณากรอกตัวเลข X/Y/Z ให้ถูกต้อง"
	end

	if not count or count < 1 then count = 1 end
	count = math.floor(count)

	if not delay or delay < 0 then delay = 0 end

	return { x=x, y=y, z=z, count=count, delay=delay }, nil
end

local function setLoopUI(running)
	stopBtn.Visible = running
	if running then
		okBtn.Text = "Running..."
		okBtn.Active = false
		okBtn.AutoButtonColor = false
	else
		okBtn.Text = "OK (Teleport XYZ)"
		okBtn.Active = true
		okBtn.AutoButtonColor = true
	end
end

cbBtn.MouseButton1Click:Connect(function()
	loopEnabled = not loopEnabled
	cbMark.Visible = loopEnabled
end)

stopBtn.MouseButton1Click:Connect(function()
	if loopRunning then
		loopRunning = false
		loopToken += 1
		msg.Text = "หยุดลูปแล้ว"
		setLoopUI(false)
	end
end)

okBtn.MouseButton1Click:Connect(function()
	local data, err = parseXYZInputs()
	if not data then
		msg.Text = err
		return
	end

	if not loopEnabled then
		for i = 1, data.count do
			local ok = teleportToXYZ(data.x, data.y, data.z)
			if not ok then return end
			msg.Text = ("Teleport (%d/%d): %.2f, %.2f, %.2f"):format(i, data.count, data.x, data.y, data.z)
			if data.delay > 0 and i < data.count then
				task.wait(data.delay)
			end
		end
		return
	end

	if loopRunning then
		msg.Text = "ลูปกำลังทำงานอยู่"
		return
	end

	loopRunning = true
	loopToken += 1
	local myToken = loopToken
	setLoopUI(true)

	task.spawn(function()
		local round = 0
		while loopRunning and myToken == loopToken do
			round += 1
			for i = 1, data.count do
				if not (loopRunning and myToken == loopToken) then break end
				local ok = teleportToXYZ(data.x, data.y, data.z)
				if not ok then loopRunning = false break end
				msg.Text = ("Loop #%d | (%d/%d): %.2f, %.2f, %.2f"):format(round, i, data.count, data.x, data.y, data.z)
				if data.delay > 0 then task.wait(data.delay) else RunService.Heartbeat:Wait() end
			end
		end
		setLoopUI(false)
	end)
end)

-- ===== Monster TP Logic =====
local function getRootPartFromInstance(inst)
	if not inst then return nil end
	if inst:IsA("Model") then
		local hrp = inst:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then return hrp end
		if inst.PrimaryPart and inst.PrimaryPart:IsA("BasePart") then return inst.PrimaryPart end
		local torso = inst:FindFirstChild("Torso") or inst:FindFirstChild("UpperTorso")
		if torso and torso:IsA("BasePart") then return torso end
		for _, d in ipairs(inst:GetDescendants()) do
			if d:IsA("BasePart") then return d end
		end
	elseif inst:IsA("BasePart") then
		return inst
	end
	return nil
end

local function tpToNearestMonster(mapId, monsterId)
	local monstersRoot = workspace:FindFirstChild("Monsters")
	if not monstersRoot then return false, "ไม่พบ workspace.Monsters" end

	local mapFolder = monstersRoot:FindFirstChild(tostring(mapId))
	if not mapFolder then return false, "ไม่พบโฟลเดอร์แผนที่: "..tostring(mapId) end

	local group = mapFolder:FindFirstChild(tostring(monsterId))
	if not group then return false, ("ไม่พบมอนสเตอร์ %s ใน map %s"):format(tostring(monsterId), tostring(mapId)) end

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false, "ไม่พบ HumanoidRootPart ของผู้เล่น" end

	local origin = hrp.Position
	local bestPart, bestDist = nil, math.huge

	for _, child in ipairs(group:GetChildren()) do
		local p = getRootPartFromInstance(child)
		if p then
			local dist = (p.Position - origin).Magnitude
			if dist < bestDist then
				bestDist = dist
				bestPart = p
			end
		end
	end

	if not bestPart then
		return false, "หา RootPart ของมอนสเตอร์ไม่เจอ (ในโฟลเดอร์นั้นอาจไม่ใช่ Model/Part)"
	end

	hrp.CFrame = bestPart.CFrame * CFrame.new(0, 0, 6)
	return true, ("TP หา %s ใน %s (ระยะ %.1f)"):format(tostring(monsterId), tostring(mapId), bestDist)
end

tpMonsterBtn.MouseButton1Click:Connect(function()
	local mapId = (mapBox.Text or ""):gsub("%s+", "")
	local monsterId = (monsterBox.Text or ""):gsub("%s+", "")
	if mapId == "" or monsterId == "" then
		msg.Text = "กรอก MapId/MonsterId ก่อน (เช่น 010 / 001)"
		return
	end

	local ok, info = tpToNearestMonster(mapId, monsterId)
	msg.Text = info or (ok and "OK" or "Fail")
end)
