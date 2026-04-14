local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("MainGUI")
local buttonUI = mainGui:WaitForChild("ButtonUI")
local leaderstats = player:WaitForChild("leaderstats")

-- =========================
-- ตัวแปรที่แก้ได้ อยู่ในไฟล์นี้
-- =========================
local SOURCE_BUY_BUTTON_NAME = "BuyBtn"       -- ปุ่มจริงของเกม สำหรับซื้อ 5 SP
local SOURCE_BIGBUY_BUTTON_NAME = "BigBuyBtn" -- ปุ่มจริงของเกม สำหรับซื้อ 50 SP
local LOOP_DELAY = 0.5                        -- เวลาหน่วงต่อรอบ
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

local function canBuy(btn)
	local amount, price = getButtonInfo(btn)
	if not amount or not price then
		return false, "อ่านราคาไม่ได้"
	end

	if mana.Value < price then
		return false, ("Mana ไม่พอ | ต้องใช้ %d | มี %d"):format(price, mana.Value)
	end

	return true, ("ซื้อ %d SP ใช้ %d Mana"):format(amount, price)
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
frame.Size = UDim2.new(0, 300, 0, 220)
frame.Position = UDim2.new(0.5, -150, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 80)
stroke.Thickness = 1
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "SP Buyer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = frame

local manaLabel = Instance.new("TextLabel")
manaLabel.Size = UDim2.new(1, -20, 0, 25)
manaLabel.Position = UDim2.new(0, 10, 0, 40)
manaLabel.BackgroundTransparency = 1
manaLabel.TextXAlignment = Enum.TextXAlignment.Left
manaLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
manaLabel.TextSize = 16
manaLabel.Font = Enum.Font.Gotham
manaLabel.Parent = frame

local spLabel = Instance.new("TextLabel")
spLabel.Size = UDim2.new(1, -20, 0, 25)
spLabel.Position = UDim2.new(0, 10, 0, 65)
spLabel.BackgroundTransparency = 1
spLabel.TextXAlignment = Enum.TextXAlignment.Left
spLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
spLabel.TextSize = 16
spLabel.Font = Enum.Font.Gotham
spLabel.Parent = frame

local loopBox = Instance.new("TextButton")
loopBox.Size = UDim2.new(0, 24, 0, 24)
loopBox.Position = UDim2.new(0, 10, 0, 98)
loopBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
loopBox.Text = ""
loopBox.AutoButtonColor = true
loopBox.Font = Enum.Font.GothamBold
loopBox.TextSize = 16
loopBox.TextColor3 = Color3.fromRGB(255, 255, 255)
loopBox.Parent = frame

local loopCorner = Instance.new("UICorner")
loopCorner.CornerRadius = UDim.new(0, 6)
loopCorner.Parent = loopBox

local loopText = Instance.new("TextLabel")
loopText.Size = UDim2.new(1, -45, 0, 24)
loopText.Position = UDim2.new(0, 40, 0, 98)
loopText.BackgroundTransparency = 1
loopText.Text = "Loop Buy"
loopText.TextColor3 = Color3.fromRGB(255, 255, 255)
loopText.TextSize = 16
loopText.Font = Enum.Font.Gotham
loopText.TextXAlignment = Enum.TextXAlignment.Left
loopText.Parent = frame

local buyButton = Instance.new("TextButton")
buyButton.Size = UDim2.new(1, -20, 0, 36)
buyButton.Position = UDim2.new(0, 10, 0, 132)
buyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
buyButton.Text = "Buy"
buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buyButton.TextSize = 18
buyButton.Font = Enum.Font.GothamBold
buyButton.Parent = frame

local buyCorner = Instance.new("UICorner")
buyCorner.CornerRadius = UDim.new(0, 8)
buyCorner.Parent = buyButton

local bigBuyButton = Instance.new("TextButton")
bigBuyButton.Size = UDim2.new(1, -20, 0, 36)
bigBuyButton.Position = UDim2.new(0, 10, 0, 174)
bigBuyButton.BackgroundColor3 = Color3.fromRGB(170, 85, 0)
bigBuyButton.Text = "BigBuy"
bigBuyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bigBuyButton.TextSize = 18
bigBuyButton.Font = Enum.Font.GothamBold
bigBuyButton.Parent = frame

local bigBuyCorner = Instance.new("UICorner")
bigBuyCorner.CornerRadius = UDim.new(0, 8)
bigBuyCorner.Parent = bigBuyButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 1, -24)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "พร้อมใช้งาน"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

-- =========================
-- Drag UI
-- =========================
local dragging = false
local dragInput
local dragStart
local startPos

local UserInputService = game:GetService("UserInputService")

local function updateDrag(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(
		startPos.X.Scale, startPos.X.Offset + delta.X,
		startPos.Y.Scale, startPos.Y.Offset + delta.Y
	)
end

title.InputBegan:Connect(function(input)
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

title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateDrag(input)
	end
end)

-- =========================
-- Loop logic
-- =========================
local loopEnabled = false
local currentLoopToken = 0

local function refreshLoopBox()
	if loopEnabled then
		loopBox.Text = "✓"
		loopBox.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
	else
		loopBox.Text = ""
		loopBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	end
end

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

	manaLabel.Text = "Mana คงเหลือ : " .. tostring(mana.Value)
	spLabel.Text = "SP คงเหลือ : " .. tostring(sp.Value)

	if buyAmount and buyPrice then
		buyButton.Text = ("Buy (%d SP / %d Mana)"):format(buyAmount, buyPrice)
	else
		buyButton.Text = "Buy (อ่านราคาไม่ได้)"
	end

	if bigAmount and bigPrice then
		bigBuyButton.Text = ("BigBuy (%d SP / %d Mana)"):format(bigAmount, bigPrice)
	else
		bigBuyButton.Text = "BigBuy (อ่านราคาไม่ได้)"
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

updateInfo()
print("SP Buyer UI Loaded")
