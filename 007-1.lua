local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("MainGUI")
local buttonUI = mainGui:WaitForChild("ButtonUI")
local leaderstats = player:WaitForChild("leaderstats")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local guildInviteRemote = remotes:WaitForChild("GuildInvite")

-- =========================
-- ตัวแปรที่แก้ได้ อยู่ในไฟล์นี้
-- =========================
local SOURCE_BUY_BUTTON_NAME = "BuyBtn"       -- ปุ่มจริงของเกม สำหรับซื้อ 5 SP
local SOURCE_BIGBUY_BUTTON_NAME = "BigBuyBtn" -- ปุ่มจริงของเกม สำหรับซื้อ 50 SP
local LOOP_DELAY = 0.5                        -- เวลาหน่วงต่อรอบ
local INVITE_DELAY = 0.2                      -- เวลาหน่วงตอนเชิญแต่ละคน

local FRAME_WIDTH = 250
local EXPANDED_HEIGHT = 205
local COLLAPSED_HEIGHT = 30
-- =========================

local mana, sp
for _, v in ipairs(leaderstats:GetChildren()) do
	if v.Name:find("Mana", 1, true) then
		mana = v
	elseif v.Name:find("SP", 1, true) then
		sp = v
	end
end

if not mana or not sp then
	warn("ไม่เจอ Mana หรือ SP ใน leaderstats")
	return
end

local sourceBuyBtn = buttonUI:FindFirstChild(SOURCE_BUY_BUTTON_NAME)
local sourceBigBuyBtn = buttonUI:FindFirstChild(SOURCE_BIGBUY_BUTTON_NAME)

if not sourceBuyBtn or not sourceBigBuyBtn then
	warn("ไม่เจอ BuyBtn หรือ BigBuyBtn ใน MainGUI.ButtonUI")
	return
end

local function getButtonInfo(btn)
	if not btn then
		return nil, nil, nil
	end

	local label = btn:FindFirstChild("TextLabel")
	if not label then
		return nil, nil, nil
	end

	local amountText, priceText = tostring(label.Text):match("BUY%s+([%d,]+)%s+SP%s*%-%s*([%d,]+)%s+MANA")
	local amount = amountText and tonumber((amountText:gsub(",", "")))
	local price = priceText and tonumber((priceText:gsub(",", "")))

	return amount, price, label.Text
end

local function doBuy(btn)
	local amount, price = getButtonInfo(btn)
	if not amount or not price then
		return false, "อ่านราคาไม่ได้"
	end

	if mana.Value < price then
		return false, ("Mana ไม่พอ | ต้องใช้ %d | มี %d"):format(price, mana.Value)
	end

	firesignal(btn.MouseButton1Click)
	return true, ("ซื้อ %d SP สำเร็จ"):format(amount)
end

-- =========================
-- สร้าง UI
-- =========================
local oldGui = playerGui:FindFirstChild("CustomSPBuyerUI")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomSPBuyerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, FRAME_WIDTH, 0, EXPANDED_HEIGHT)
frame.Position = UDim2.new(0.5, -(FRAME_WIDTH / 2), 0.5, -(EXPANDED_HEIGHT / 2))
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(80, 80, 80)
frameStroke.Thickness = 1
frameStroke.Parent = frame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 10)
topBarCorner.Parent = topBar

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 10)
topBarFix.Position = UDim2.new(0, 0, 1, -10)
topBarFix.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "SP Buyer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 24, 0, 20)
minimizeButton.Position = UDim2.new(1, -52, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 14
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeButton

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 24, 0, 20)
closeButton.Position = UDim2.new(1, -26, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 13
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1
content.Parent = frame

local manaLabel = Instance.new("TextLabel")
manaLabel.Size = UDim2.new(1, -16, 0, 18)
manaLabel.Position = UDim2.new(0, 8, 0, 8)
manaLabel.BackgroundTransparency = 1
manaLabel.TextXAlignment = Enum.TextXAlignment.Left
manaLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
manaLabel.TextSize = 13
manaLabel.Font = Enum.Font.Gotham
manaLabel.Parent = content

local spLabel = Instance.new("TextLabel")
spLabel.Size = UDim2.new(1, -16, 0, 18)
spLabel.Position = UDim2.new(0, 8, 0, 28)
spLabel.BackgroundTransparency = 1
spLabel.TextXAlignment = Enum.TextXAlignment.Left
spLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
spLabel.TextSize = 13
spLabel.Font = Enum.Font.Gotham
spLabel.Parent = content

local loopBox = Instance.new("TextButton")
loopBox.Size = UDim2.new(0, 18, 0, 18)
loopBox.Position = UDim2.new(0, 8, 0, 52)
loopBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
loopBox.BorderSizePixel = 0
loopBox.Text = ""
loopBox.AutoButtonColor = true
loopBox.Font = Enum.Font.GothamBold
loopBox.TextSize = 12
loopBox.TextColor3 = Color3.fromRGB(255, 255, 255)
loopBox.Parent = content

local loopCorner = Instance.new("UICorner")
loopCorner.CornerRadius = UDim.new(0, 5)
loopCorner.Parent = loopBox

local loopText = Instance.new("TextLabel")
loopText.Size = UDim2.new(1, -34, 0, 18)
loopText.Position = UDim2.new(0, 30, 0, 52)
loopText.BackgroundTransparency = 1
loopText.Text = "Loop Buy"
loopText.TextColor3 = Color3.fromRGB(255, 255, 255)
loopText.TextSize = 13
loopText.Font = Enum.Font.Gotham
loopText.TextXAlignment = Enum.TextXAlignment.Left
loopText.Parent = content

local function styleButton(btn, color)
	btn.BackgroundColor3 = color
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = true

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = btn
end

local buyButton = Instance.new("TextButton")
buyButton.Size = UDim2.new(1, -16, 0, 26)
buyButton.Position = UDim2.new(0, 8, 0, 78)
buyButton.Text = "Buy"
buyButton.Parent = content
styleButton(buyButton, Color3.fromRGB(0, 170, 127))

local bigBuyButton = Instance.new("TextButton")
bigBuyButton.Size = UDim2.new(1, -16, 0, 26)
bigBuyButton.Position = UDim2.new(0, 8, 0, 108)
bigBuyButton.Text = "BigBuy"
bigBuyButton.Parent = content
styleButton(bigBuyButton, Color3.fromRGB(170, 85, 0))

local inviteAllButton = Instance.new("TextButton")
inviteAllButton.Size = UDim2.new(1, -16, 0, 26)
inviteAllButton.Position = UDim2.new(0, 8, 0, 138)
inviteAllButton.Text = "Invite All"
inviteAllButton.Parent = content
styleButton(inviteAllButton, Color3.fromRGB(70, 105, 180))

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 0, 18)
statusLabel.Position = UDim2.new(0, 8, 1, -22)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "พร้อมใช้งาน"
statusLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = content

-- =========================
-- Drag UI
-- =========================
local dragging = false
local dragInput
local dragStart
local startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		updateDrag(input)
	end
end)

-- =========================
-- State
-- =========================
local loopEnabled = false
local currentLoopToken = 0
local isCollapsed = false
local isInviting = false

local function refreshLoopBox()
	if loopEnabled then
		loopBox.Text = "✓"
		loopBox.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
	else
		loopBox.Text = ""
		loopBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	end
end

local function setCollapsed(collapsed)
	isCollapsed = collapsed
	content.Visible = not collapsed

	if isCollapsed then
		frame.Size = UDim2.new(0, FRAME_WIDTH, 0, COLLAPSED_HEIGHT)
		minimizeButton.Text = "+"
	else
		frame.Size = UDim2.new(0, FRAME_WIDTH, 0, EXPANDED_HEIGHT)
		minimizeButton.Text = "-"
	end
end

minimizeButton.MouseButton1Click:Connect(function()
	setCollapsed(not isCollapsed)
end)

closeButton.MouseButton1Click:Connect(function()
	loopEnabled = false
	currentLoopToken += 1
	screenGui:Destroy()
end)

loopBox.MouseButton1Click:Connect(function()
	loopEnabled = not loopEnabled
	refreshLoopBox()

	if not loopEnabled then
		currentLoopToken += 1
		statusLabel.Text = "หยุด loop แล้ว"
	else
		statusLabel.Text = "เปิด loop แล้ว"
	end
end)

refreshLoopBox()

local function updateInfo()
	local buyAmount, buyPrice = getButtonInfo(sourceBuyBtn)
	local bigAmount, bigPrice = getButtonInfo(sourceBigBuyBtn)

	manaLabel.Text = "Mana : " .. tostring(mana.Value)
	spLabel.Text = "SP : " .. tostring(sp.Value)

	if buyAmount and buyPrice then
		buyButton.Text = ("Buy (%d/%d)"):format(buyAmount, buyPrice)
	else
		buyButton.Text = "Buy (N/A)"
	end

	if bigAmount and bigPrice then
		bigBuyButton.Text = ("BigBuy (%d/%d)"):format(bigAmount, bigPrice)
	else
		bigBuyButton.Text = "BigBuy (N/A)"
	end
end

mana:GetPropertyChangedSignal("Value"):Connect(updateInfo)
sp:GetPropertyChangedSignal("Value"):Connect(updateInfo)

local buyLabel = sourceBuyBtn:FindFirstChild("TextLabel")
if buyLabel then
	buyLabel:GetPropertyChangedSignal("Text"):Connect(updateInfo)
end

local bigBuyLabel = sourceBigBuyBtn:FindFirstChild("TextLabel")
if bigBuyLabel then
	bigBuyLabel:GetPropertyChangedSignal("Text"):Connect(updateInfo)
end

local function startBuyLoop(btn, modeName)
	currentLoopToken += 1
	local myToken = currentLoopToken

	task.spawn(function()
		while loopEnabled and myToken == currentLoopToken do
			local ok, msg = doBuy(btn)
			statusLabel.Text = modeName .. " | " .. msg

			if not ok then
				break
			end

			task.wait(LOOP_DELAY)
		end
	end)
end

local function inviteAllPlayers()
	if isInviting then
		statusLabel.Text = "กำลังเชิญอยู่"
		return
	end

	isInviting = true
	inviteAllButton.Active = false
	inviteAllButton.AutoButtonColor = false
	inviteAllButton.Text = "Inviting..."

	task.spawn(function()
		local invitedCount = 0

		for _, targetPlayer in ipairs(Players:GetPlayers()) do
			if targetPlayer ~= player then
				guildInviteRemote:FireServer(targetPlayer.Name)
				invitedCount += 1
				statusLabel.Text = "Invite: " .. targetPlayer.Name
				task.wait(INVITE_DELAY)
			end
		end

		if invitedCount > 0 then
			statusLabel.Text = "เชิญครบ " .. invitedCount .. " คน"
		else
			statusLabel.Text = "ไม่มีผู้เล่นอื่นให้เชิญ"
		end

		inviteAllButton.Text = "Invite All"
		inviteAllButton.Active = true
		inviteAllButton.AutoButtonColor = true
		isInviting = false
	end)
end

buyButton.MouseButton1Click:Connect(function()
	updateInfo()

	if loopEnabled then
		statusLabel.Text = "เริ่ม loop Buy"
		startBuyLoop(sourceBuyBtn, "Buy")
	else
		local ok, msg = doBuy(sourceBuyBtn)
		statusLabel.Text = msg

		if ok then
			task.wait(0.2)
			updateInfo()
		end
	end
end)

bigBuyButton.MouseButton1Click:Connect(function()
	updateInfo()

	if loopEnabled then
		statusLabel.Text = "เริ่ม loop BigBuy"
		startBuyLoop(sourceBigBuyBtn, "BigBuy")
	else
		local ok, msg = doBuy(sourceBigBuyBtn)
		statusLabel.Text = msg

		if ok then
			task.wait(0.2)
			updateInfo()
		end
	end
end)

inviteAllButton.MouseButton1Click:Connect(function()
	inviteAllPlayers()
end)

setCollapsed(false)
updateInfo()
print("SP Buyer UI Loaded")
