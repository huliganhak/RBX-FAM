--// ===== RemoteFunction path =====
local rf = game:GetService("ReplicatedStorage")
	:WaitForChild("Packages")
	:WaitForChild("Knit")
	:WaitForChild("Services")
	:WaitForChild("PlayerService")
	:WaitForChild("__comm__")
	:WaitForChild("RF")
	:WaitForChild("AddNum")

local args = { "Attack" }

--// ===== Services =====
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

--// ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "RFInvokerUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 300)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = frame

-- root container
local root = Instance.new("Frame")
root.BackgroundTransparency = 1
root.Size = UDim2.new(1, 0, 1, 0)
root.Parent = frame

local rootLayout = Instance.new("UIListLayout")
rootLayout.FillDirection = Enum.FillDirection.Vertical
rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
rootLayout.Padding = UDim.new(0, 10)
rootLayout.Parent = root

-- helpers
local function makeBox(defaultText)
	local box = Instance.new("TextBox")
	box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.Text = tostring(defaultText or "")
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
	return box
end

local function makeLabel(text, w)
	local lb = Instance.new("TextLabel")
	lb.BackgroundTransparency = 1
	lb.Text = text
	lb.TextColor3 = Color3.fromRGB(220, 220, 220)
	lb.Font = Enum.Font.Gotham
	lb.TextSize = 14
	lb.TextXAlignment = Enum.TextXAlignment.Left
	if w then lb.Size = UDim2.new(0, w, 1, 0) end
	return lb
end

local function makeBtn(text, h)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, h or 36)
	b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.Text = text
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
	return b
end

local function toNumberSafe(text, fallback)
	local n = tonumber(text)
	if n == nil then return fallback end
	return n
end

-- ===== Title row =====
local titleRow = Instance.new("Frame")
titleRow.LayoutOrder = 1
titleRow.Size = UDim2.new(1, 0, 0, 28)
titleRow.BackgroundTransparency = 1
titleRow.Parent = root

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -34, 1, 0)
title.BackgroundTransparency = 1
title.Text = "RF Invoker (Attack)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = titleRow

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, 0, 0, 0)
minBtn.AnchorPoint = Vector2.new(1, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Text = "–"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.Parent = titleRow
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- ===== Row: Total / Batch / Delay =====
local row1 = Instance.new("Frame")
row1.LayoutOrder = 2
row1.Size = UDim2.new(1, 0, 0, 34)
row1.BackgroundTransparency = 1
row1.Parent = root

local row1Layout = Instance.new("UIListLayout")
row1Layout.FillDirection = Enum.FillDirection.Horizontal
row1Layout.SortOrder = Enum.SortOrder.LayoutOrder
row1Layout.Padding = UDim.new(0, 8)
row1Layout.Parent = row1

local totalLabel = makeLabel("Total:", 45); totalLabel.LayoutOrder = 1; totalLabel.Parent = row1
local totalBox = makeBox("50"); totalBox.LayoutOrder = 2; totalBox.Size = UDim2.new(0, 60, 1, 0); totalBox.Parent = row1

local batchLabel = makeLabel("Batch:", 50); batchLabel.LayoutOrder = 3; batchLabel.Parent = row1
local batchBox = makeBox("10"); batchBox.LayoutOrder = 4; batchBox.Size = UDim2.new(0, 60, 1, 0); batchBox.Parent = row1

local delayLabel = makeLabel("Delay:", 48); delayLabel.LayoutOrder = 5; delayLabel.Parent = row1
local delayBox = makeBox("0.1"); delayBox.LayoutOrder = 6; delayBox.Size = UDim2.new(0, 70, 1, 0); delayBox.Parent = row1

-- ===== Row: WalkSpeed + Apply + Lock =====
local row2 = Instance.new("Frame")
row2.LayoutOrder = 3
row2.Size = UDim2.new(1, 0, 0, 34)
row2.BackgroundTransparency = 1
row2.Parent = root

local row2Layout = Instance.new("UIListLayout")
row2Layout.FillDirection = Enum.FillDirection.Horizontal
row2Layout.SortOrder = Enum.SortOrder.LayoutOrder
row2Layout.Padding = UDim.new(0, 8)
row2Layout.Parent = row2

local speedLabel = makeLabel("WalkSpeed:", 80); speedLabel.LayoutOrder = 1; speedLabel.Parent = row2
local speedBox = makeBox("16"); speedBox.LayoutOrder = 2; speedBox.Size = UDim2.new(0, 60, 1, 0); speedBox.Parent = row2

local applySpeedBtn = Instance.new("TextButton")
applySpeedBtn.LayoutOrder = 3
applySpeedBtn.Size = UDim2.new(0, 110, 1, 0)
applySpeedBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
applySpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applySpeedBtn.Text = "Apply"
applySpeedBtn.Font = Enum.Font.GothamBold
applySpeedBtn.TextSize = 14
applySpeedBtn.Parent = row2
Instance.new("UICorner", applySpeedBtn).CornerRadius = UDim.new(0, 10)

local lockSpeedBtn = Instance.new("TextButton")
lockSpeedBtn.LayoutOrder = 4
lockSpeedBtn.Size = UDim2.new(0, 110, 1, 0)
lockSpeedBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 40)
lockSpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lockSpeedBtn.Text = "Lock: OFF"
lockSpeedBtn.Font = Enum.Font.GothamBold
lockSpeedBtn.TextSize = 14
lockSpeedBtn.Parent = row2
Instance.new("UICorner", lockSpeedBtn).CornerRadius = UDim.new(0, 10)

-- ===== Row: Start / Stop =====
local row3 = Instance.new("Frame")
row3.LayoutOrder = 4
row3.Size = UDim2.new(1, 0, 0, 40)
row3.BackgroundTransparency = 1
row3.Parent = root

local row3Layout = Instance.new("UIListLayout")
row3Layout.FillDirection = Enum.FillDirection.Horizontal
row3Layout.SortOrder = Enum.SortOrder.LayoutOrder
row3Layout.Padding = UDim.new(0, 10)
row3Layout.Parent = row3

local startBtn = Instance.new("TextButton")
startBtn.LayoutOrder = 1
startBtn.Size = UDim2.new(0.5, -5, 1, 0)
startBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Text = "Start"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 15
startBtn.Parent = row3
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 12)

local stopBtn = Instance.new("TextButton")
stopBtn.LayoutOrder = 2
stopBtn.Size = UDim2.new(0.5, -5, 1, 0)
stopBtn.BackgroundColor3 = Color3.fromRGB(160, 70, 70)
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Text = "Stop"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 15
stopBtn.Parent = row3
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 12)

-- ===== Status =====
local status = Instance.new("TextLabel")
status.LayoutOrder = 5
status.Size = UDim2.new(1, 0, 0, 18)
status.BackgroundTransparency = 1
status.Text = "Status: Idle"
status.TextColor3 = Color3.fromRGB(255, 200, 80)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = root

local function setStatus(t)
	status.Text = "Status: " .. t
end

-- ===== Drag to move (ลากย้าย UI) =====
do
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

	titleRow.InputBegan:Connect(function(input)
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

-- ===== Minimize / Expand (แบบเดียวกับที่คุณใช้แล้วเวิร์ค) =====
local minimized = false
local fullSize = frame.Size

local function setRootChildrenVisible(visible)
	for _, child in ipairs(root:GetChildren()) do
		if child ~= titleRow and child:IsA("GuiObject") then
			child.Visible = visible
		end
	end
end

minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		setRootChildrenVisible(false)
		frame.Size = UDim2.new(fullSize.X.Scale, fullSize.X.Offset, 0, 55)
		minBtn.Text = "+"
	else
		setRootChildrenVisible(true)
		frame.Size = fullSize
		minBtn.Text = "–"
	end
end)

-- ===== WalkSpeed logic =====
local lockSpeed = false
local desiredSpeed = 16

local function getHumanoid()
	local char = player.Character
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid")
end

local function applySpeed()
	local hum = getHumanoid()
	if not hum then
		setStatus("No Humanoid yet (respawn?)")
		return
	end
	hum.WalkSpeed = desiredSpeed
	setStatus("WalkSpeed set to " .. tostring(desiredSpeed))
end

applySpeedBtn.MouseButton1Click:Connect(function()
	desiredSpeed = toNumberSafe(speedBox.Text, 16)
	if desiredSpeed < 0 then desiredSpeed = 0 end
	speedBox.Text = tostring(desiredSpeed)
	applySpeed()
end)

lockSpeedBtn.MouseButton1Click:Connect(function()
	lockSpeed = not lockSpeed
	lockSpeedBtn.Text = lockSpeed and "Lock: ON" or "Lock: OFF"
	lockSpeedBtn.BackgroundColor3 = lockSpeed and Color3.fromRGB(45, 95, 95) or Color3.fromRGB(80, 60, 40)
	setStatus(lockSpeed and ("Locking WalkSpeed=" .. desiredSpeed) or "Speed lock off")
end)

RunService.Heartbeat:Connect(function()
	if not lockSpeed then return end
	local hum = getHumanoid()
	if hum and hum.WalkSpeed ~= desiredSpeed then
		hum.WalkSpeed = desiredSpeed
	end
end)

player.CharacterAdded:Connect(function()
	task.wait(0.2)
	if lockSpeed then applySpeed() end
end)

-- ===== Invoke logic =====
local running = false
local runToken = 0

local function invokeOnce(index)
	local ok, result = pcall(function()
		return rf:InvokeServer(unpack(args))
	end)
	if not ok then
		warn("fail", index, result)
	end
end

local function runBatched(total, batch, delay, token)
	setStatus(("Running... total=%d batch=%d delay=%.3f"):format(total, batch, delay))
	local sent = 0

	for startIdx = 1, total, batch do
		if not running or token ~= runToken then
			setStatus(("Stopped at %d/%d"):format(sent, total))
			return
		end

		local lastIdx = math.min(startIdx + batch - 1, total)
		for i = startIdx, lastIdx do
			sent += 1
			task.spawn(invokeOnce, i)
		end

		setStatus(("Sent %d/%d (batch %d-%d)"):format(sent, total, startIdx, lastIdx))
		task.wait(delay)
	end

	setStatus(("Done! Sent %d/%d"):format(sent, total))
	running = false
end

startBtn.MouseButton1Click:Connect(function()
	if running then
		setStatus("Already running.")
		return
	end

	local total = math.floor(toNumberSafe(totalBox.Text, 50))
	local batch = math.floor(toNumberSafe(batchBox.Text, 10))
	local delay = toNumberSafe(delayBox.Text, 0.1)

	if total < 1 then total = 1 end
	if batch < 1 then batch = 1 end
	if delay < 0 then delay = 0 end
	if batch > total then batch = total end

	totalBox.Text = tostring(total)
	batchBox.Text = tostring(batch)
	delayBox.Text = tostring(delay)

	running = true
	runToken += 1
	local token = runToken
	task.spawn(runBatched, total, batch, delay, token)
end)

stopBtn.MouseButton1Click:Connect(function()
	if not running then
		setStatus("Idle (nothing to stop).")
		return
	end
	running = false
	setStatus("Stopping...")
end)
