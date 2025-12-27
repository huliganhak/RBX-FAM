local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ===================== Monster TP Logic =====================
local function getRootPartFromInstance(inst)
	if not inst then return nil end

	if inst:IsA("BasePart") then
		return inst
	end

	if inst:IsA("Model") then
		local hrp = inst:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then return hrp end

		if inst.PrimaryPart and inst.PrimaryPart:IsA("BasePart") then
			return inst.PrimaryPart
		end

		for _, d in ipairs(inst:GetDescendants()) do
			if d:IsA("BasePart") then
				return d
			end
		end
	end

	return nil
end

local function tpToNearestMonster(mapId, monsterId)
	local monstersRoot = workspace:FindFirstChild("Monsters")
	if not monstersRoot then return false, "ไม่พบ workspace.Monsters" end

	local mapKey = string.format("%03d", tonumber(mapId) or 0)
	local monsterKey = string.format("%03d", tonumber(monsterId) or 0)

	local mapFolder = monstersRoot:FindFirstChild(mapKey)
	if not mapFolder then return false, "ไม่พบโฟลเดอร์แผนที่: " .. mapKey end

	-- ใน mapFolder มีหลายตัวชื่อเดียวกัน เช่น "001"
	local candidates = {}
	for _, inst in ipairs(mapFolder:GetChildren()) do
		if inst.Name == monsterKey then
			table.insert(candidates, inst)
		end
	end

	if #candidates == 0 then
		return false, ("ไม่พบมอนสเตอร์ชื่อ %s ใน map %s"):format(monsterKey, mapKey)
	end

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false, "ไม่พบ HumanoidRootPart ของผู้เล่น" end

	local origin = hrp.Position
	local bestPart, bestDist = nil, math.huge

	for _, inst in ipairs(candidates) do
		local p = getRootPartFromInstance(inst)
		if p then
			local dist = (p.Position - origin).Magnitude
			if dist < bestDist then
				bestDist = dist
				bestPart = p
			end
		end
	end

	if not bestPart then
		return false, "เจอชื่อมอนสเตอร์ แต่ไม่มี BasePart/Model ที่ใช้หาตำแหน่งได้"
	end

	hrp.CFrame = bestPart.CFrame * CFrame.new(0, 0, 6)
	return true, ("TP หา %s ใน %s (ใกล้สุด ระยะ %.1f)"):format(monsterKey, mapKey, bestDist)
end

-- ===================== UI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "MonsterTP_UI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 190)
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
title.Text = "TP หา Monster (ใกล้สุด)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = root

-- Minimize
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

-- row: MapId / MonsterId
local row = Instance.new("Frame")
row.LayoutOrder = 2
row.Size = UDim2.new(1, 0, 0, 40)
row.BackgroundTransparency = 1
row.Parent = root

local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowLayout.Padding = UDim.new(0, 10)
rowLayout.Parent = row

local mapBox = makeBox("MapId เช่น 010")
mapBox.Size = UDim2.new(0.5, -5, 1, 0)
mapBox.Text = "010"
mapBox.Parent = row

local monsterBox = makeBox("MonsterId เช่น 001")
monsterBox.Size = UDim2.new(0.5, -5, 1, 0)
monsterBox.Text = "001"
monsterBox.Parent = row

local tpBtn = Instance.new("TextButton")
tpBtn.LayoutOrder = 3
tpBtn.Size = UDim2.new(1, 0, 0, 42)
tpBtn.BackgroundColor3 = Color3.fromRGB(70, 120, 170)
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Text = "TP หา Monster ใกล้สุด (อ่านค่าปัจจุบัน)"
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 15
tpBtn.Parent = root
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 12)

local msg = Instance.new("TextLabel")
msg.LayoutOrder = 4
msg.Size = UDim2.new(1, 0, 0, 18)
msg.BackgroundTransparency = 1
msg.Text = ""
msg.TextColor3 = Color3.fromRGB(255, 200, 80)
msg.Font = Enum.Font.Gotham
msg.TextSize = 12
msg.TextXAlignment = Enum.TextXAlignment.Left
msg.Parent = root

-- Drag (ลากที่ title)
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

-- ===================== Button Action =====================
tpBtn.MouseButton1Click:Connect(function()
	-- ✅ ทุกครั้งที่กด จะอ่านค่าจาก TextBox ใหม่เสมอ
	local mapId = (mapBox.Text or ""):gsub("%s+", "")
	local monsterId = (monsterBox.Text or ""):gsub("%s+", "")

	-- อนุญาตทั้ง "010" และ "10"
	local mapNum = tonumber(mapId)
	local monsterNum = tonumber(monsterId)

	if not mapNum or not monsterNum then
		msg.Text = "กรอก MapId/MonsterId เป็นตัวเลข (เช่น 010 / 001)"
		return
	end

	local ok, info = tpToNearestMonster(mapNum, monsterNum)
	msg.Text = info or (ok and "OK" or "Fail")
end)
