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

--// ===== UI (Draggable) =====
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "InvokeUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 220)
frame.Position = UDim2.new(0.5, -180, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "RF Invoker (Attack)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = titleBar

-- Make only top corners rounded visually
local maskBottom = Instance.new("Frame")
maskBottom.Size = UDim2.new(1, 0, 0, 10)
maskBottom.Position = UDim2.new(0, 0, 1, -10)
maskBottom.BackgroundColor3 = titleBar.BackgroundColor3
maskBottom.BorderSizePixel = 0
maskBottom.Parent = titleBar

-- Draggable
do
	local dragging = false
	local dragStart, startPos

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

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- Helpers UI
local function mkLabel(text, x, y)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 110, 0, 26)
	l.Position = UDim2.new(0, x, 0, y)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(220, 220, 220)
	l.Font = Enum.Font.SourceSans
	l.TextSize = 16
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = frame
	return l
end

local function mkBox(defaultText, x, y)
	local tb = Instance.new("TextBox")
	tb.Size = UDim2.new(0, 90, 0, 28)
	tb.Position = UDim2.new(0, x, 0, y)
	tb.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	tb.TextColor3 = Color3.fromRGB(255, 255, 255)
	tb.Font = Enum.Font.SourceSans
	tb.TextSize = 16
	tb.ClearTextOnFocus = false
	tb.Text = tostring(defaultText)
	tb.Parent = frame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = tb

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(70, 70, 70)
	stroke.Thickness = 1
	stroke.Parent = tb

	return tb
end

local function mkBtn(text, x, y, w)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, w, 0, 34)
	b.Position = UDim2.new(0, x, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 16
	b.Text = text
	b.AutoButtonColor = true
	b.Parent = frame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = b

	return b
end

mkLabel("Total:", 16, 60)
local totalBox = mkBox(50, 140, 58)

mkLabel("Batch:", 16, 95)
local batchBox = mkBox(10, 140, 93)

mkLabel("Delay (sec):", 16, 130)
local delayBox = mkBox(0.1, 140, 128)

local startBtn = mkBtn("Start", 16, 170, 160)
local stopBtn  = mkBtn("Stop",  196, 170, 148)
stopBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -32, 0, 22)
status.Position = UDim2.new(0, 16, 0, 205)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.Font = Enum.Font.SourceSans
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = "Status: Idle"
status.Parent = frame

--// ===== Logic =====
local running = false
local runToken = 0

local function toNumberSafe(text, fallback)
	local n = tonumber(text)
	if not n then return fallback end
	return n
end

local function setStatus(t)
	status.Text = "Status: " .. t
end

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

	-- Clamp กันค่าพังๆ
	if total < 1 then total = 1 end
	if batch < 1 then batch = 1 end
	if delay < 0 then delay = 0 end
	if batch > total then batch = total end

	-- update textbox ให้เห็นค่าที่ clamp แล้ว
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
