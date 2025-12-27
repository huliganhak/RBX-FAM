local Players = game:GetService("Players")
local player = Players.LocalPlayer

local loopRunning = false
local loopToken = 0

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

local function getHpFromMonster(inst)
    -- HpValue เป็น NumberValue อยู่ใต้ตัวมอนสเตอร์
    local hp = inst:FindFirstChild("HpValue")
    if hp and hp:IsA("NumberValue") then
        return hp.Value
    end
    -- เผื่อเป็น Model แล้ว HpValue อยู่ข้างใน
    if inst:IsA("Model") then
        local hp2 = inst:FindFirstChild("HpValue", true)
        if hp2 and hp2:IsA("NumberValue") then
            return hp2.Value
        end
    end
    return nil -- ไม่เจอ HpValue
end

local function formatHp(hp)
	if hp == nil then return "N/A" end
	-- ทำให้สั้น: เช่น 1.08e+23 หรือ 12345.67
	if math.abs(hp) >= 1e6 or (math.abs(hp) > 0 and math.abs(hp) < 0.001) then
		return string.format("%.2e", hp)
	else
		return string.format("%.2f", hp)
	end
end

local function getCandidates(mapNum, monsterNum)
	local monstersRoot = workspace:FindFirstChild("Monsters")
	if not monstersRoot then return nil, "ไม่พบ workspace.Monsters" end

	local mapKey = string.format("%03d", tonumber(mapNum) or 0)
	local monsterKey = string.format("%03d", tonumber(monsterNum) or 0)

	local mapFolder = monstersRoot:FindFirstChild(mapKey)
	if not mapFolder then return nil, "ไม่พบโฟลเดอร์แผนที่: " .. mapKey end

	local candidates = {}
	for _, inst in ipairs(mapFolder:GetChildren()) do
		if inst.Name == monsterKey then
			table.insert(candidates, inst)
		end
	end

	if #candidates == 0 then
		return nil, ("ไม่พบมอนสเตอร์ชื่อ %s ใน map %s"):format(monsterKey, mapKey)
	end

	return candidates, nil
end

local function findNearest(candidates, origin, predicateFn)
	local bestInst, bestPart, bestDist, bestHp = nil, nil, math.huge, nil
	for _, inst in ipairs(candidates) do
		local hp = getHpFromMonster(inst) -- nil ได้
		if (not predicateFn) or predicateFn(inst, hp) then
			local p = getRootPartFromInstance(inst)
			if p then
				local dist = (p.Position - origin).Magnitude
				if dist < bestDist then
					bestDist = dist
					bestInst = inst
					bestPart = p
					bestHp = hp
				end
			end
		end
	end
	return bestInst, bestPart, bestDist, bestHp
end

local function tpToNearestMonsterAlive(mapId, monsterId)
    local monstersRoot = workspace:FindFirstChild("Monsters")
    if not monstersRoot then return false, "ไม่พบ workspace.Monsters" end

    local mapKey = string.format("%03d", tonumber(mapId) or 0)
    local monsterKey = string.format("%03d", tonumber(monsterId) or 0)

    local mapFolder = monstersRoot:FindFirstChild(mapKey)
    if not mapFolder then return false, "ไม่พบโฟลเดอร์แผนที่: " .. mapKey end

    -- เก็บทุก instance ที่ชื่อเดียวกัน เช่น "001"
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
    local bestPart, bestDist, bestHp = nil, math.huge, nil
    local aliveCount, deadCount, noHpCount = 0, 0, 0

    for _, inst in ipairs(candidates) do
        local hp = getHpFromMonster(inst)

        -- ถ้า hp เจอและ <= 0 ให้ข้ามทันที
        if hp ~= nil and hp <= 0 then
            deadCount += 1
        else
            if hp == nil then
                noHpCount += 1 -- ไม่เจอ HpValue (ยังให้ผ่านได้ ถ้าคุณอยากให้ข้ามก็สั่งได้)
            else
                aliveCount += 1
            end

            local p = getRootPartFromInstance(inst)
            if p then
                local dist = (p.Position - origin).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestPart = p
                    bestHp = hp
                end
            end
        end
    end

    if not bestPart then
        return false, ("ไม่มีตัวที่ TP ได้ (HP0=%d, ไม่มีHP=%d)"):format(deadCount, noHpCount)
    end

    hrp.CFrame = bestPart.CFrame * CFrame.new(0, 0, 6)

    local hpText = formatHp(bestHp)

	return true, (
		"TP หา %s ใน %s | HP=%s | ใกล้สุด %.1f\n" ..
		"Alive=%d  Dead=%d  NoHp=%d"
	):format(monsterKey, mapKey, hpText, bestDist, aliveCount, deadCount, noHpCount)
end

local function stopAutoLoop(msgLabel)
	-- หยุดเสมอ กันซ้อน 100%
	loopRunning = false
	loopToken += 1
	if msgLabel then
		msgLabel.Text = "STOP: หยุดลูปแล้ว"
	end
end

-- ===================== UI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "MonsterTP_UI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 240)
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

local autoBtn = Instance.new("TextButton")
autoBtn.LayoutOrder = 4
autoBtn.Size = UDim2.new(1, 0, 0, 40)
autoBtn.BackgroundColor3 = Color3.fromRGB(90, 150, 90)
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.Text = "AUTO: ถ้าใกล้สุด HP=0 -> TP ไปตัวถัดไป (วนลูป)"
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 13
autoBtn.Parent = root
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 12)

local stopLoopBtn = Instance.new("TextButton")
stopLoopBtn.LayoutOrder = 5
stopLoopBtn.Size = UDim2.new(1, 0, 0, 34)
stopLoopBtn.BackgroundColor3 = Color3.fromRGB(160, 70, 70)
stopLoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopLoopBtn.Text = "STOP (Auto Loop)"
stopLoopBtn.Font = Enum.Font.GothamBold
stopLoopBtn.TextSize = 14
stopLoopBtn.Visible = false
stopLoopBtn.Parent = root
Instance.new("UICorner", stopLoopBtn).CornerRadius = UDim.new(0, 12)

local msg = Instance.new("TextLabel")
msg.LayoutOrder = 6
msg.Size = UDim2.new(1, 0, 0, 34) -- ✅ เพิ่มความสูง (จาก 18 -> 34/40)
msg.BackgroundTransparency = 1
msg.Text = ""
msg.TextColor3 = Color3.fromRGB(255, 200, 80)
msg.Font = Enum.Font.Gotham
msg.TextSize = 12
msg.TextXAlignment = Enum.TextXAlignment.Left
msg.TextYAlignment = Enum.TextYAlignment.Top -- ✅ ชิดบน
msg.TextWrapped = true -- ✅ ให้ตัดบรรทัดอัตโนมัติ
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

	stopAutoLoop(msg)
	stopLoopBtn.Visible = false
	autoBtn.Active = true
	autoBtn.AutoButtonColor = true
		
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

	local ok, info = tpToNearestMonsterAlive(mapNum, monsterNum)
	msg.Text = info or (ok and "OK" or "Fail")
end)

autoBtn.MouseButton1Click:Connect(function()
	-- ✅ กันซ้อน: ถ้ามีลูปอยู่ ให้ stop ก่อนแล้วค่อยเริ่มใหม่
	stopAutoLoop(msg)

	loopRunning = true
	loopToken += 1
	local myToken = loopToken

	stopLoopBtn.Visible = true
	autoBtn.Active = false
	autoBtn.AutoButtonColor = false
	msg.Text = "AUTO: เริ่มลูปแล้ว (จะ TP เมื่อใกล้สุด HP=0)"

	task.spawn(function()
		while loopRunning and myToken == loopToken do
			-- ✅ อ่านค่าใหม่จาก textbox “ทุกครั้ง” (คุณแก้ค่าแล้วกด/ปล่อยให้ลูปวิ่ง ก็เปลี่ยนตาม)
			local mapId = (mapBox.Text or ""):gsub("%s+", "")
			local monsterId = (monsterBox.Text or ""):gsub("%s+", "")

			local mapNum = tonumber(mapId)
			local monsterNum = tonumber(monsterId)
			if not mapNum or not monsterNum then
				msg.Text = "AUTO: กรุณากรอก MapId/MonsterId เป็นตัวเลข"
				task.wait(0.3)
				continue
			end

			local candidates, err = getCandidates(mapNum, monsterNum)
			if not candidates then
				msg.Text = "AUTO: "..err
				task.wait(0.5)
				continue
			end

			local char = player.Character or player.CharacterAdded:Wait()
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then
				msg.Text = "AUTO: ไม่พบ HumanoidRootPart"
				task.wait(0.5)
				continue
			end

			local origin = hrp.Position

			-- nearest “ตัวใกล้สุด” (ไม่กรอง HP)
			local nInst, nPart, nDist, nHp = findNearest(candidates, origin, nil)

			-- ถ้าใกล้สุด HP=0 -> TP ไปหา “ตัวถัดไปที่ HP != 0”
			if nPart and nHp ~= nil and nHp <= 0 then
				local aInst, aPart, aDist, aHp = findNearest(candidates, origin, function(_, hp)
					return (hp ~= nil) and (hp > 0)  -- HP nil ให้ผ่านได้ (ถ้าคุณอยากบังคับต้องมี hp>0 บอกได้)
				end)

				if aPart then
					hrp.CFrame = aPart.CFrame * CFrame.new(0, 0, 6)
					msg.Text = ("AUTO: ใกล้สุด HP=0 -> TP ไปตัวถัดไป | HP=%s | dist=%.1f\n(เดิมใกล้สุด dist=%.1f)")
						:format(formatHp(aHp), aDist, nDist)
				else
					msg.Text = "AUTO: ใกล้สุด HP=0 แต่ไม่พบตัวที่ HP>0 ให้ TP"
				end
			else
				-- ใกล้สุดยังไม่ตาย => ไม่ TP แค่อัปเดตสถานะ
				if nPart then
					msg.Text = ("AUTO: เฝ้าใกล้สุด | HP=%s | dist=%.1f\n(จะ TP เมื่อ HP=0)")
						:format(formatHp(nHp), nDist)
				else
					msg.Text = "AUTO: หาเป้าหมายไม่เจอ (ไม่มี Part/Model ที่ใช้ตำแหน่งได้)"
				end
			end

			task.wait(0.25)
			if not (loopRunning and myToken == loopToken) then break end

		end

		-- จบลูป
		stopLoopBtn.Visible = false
		autoBtn.Active = true
		autoBtn.AutoButtonColor = true
	end)
end)


stopLoopBtn.MouseButton1Click:Connect(function()
	stopAutoLoop(msg)
	stopLoopBtn.Visible = false
	autoBtn.Active = true
	autoBtn.AutoButtonColor = true
end)




