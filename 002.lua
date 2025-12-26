local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 260) -- สูงพอให้ปุ่มโผล่แน่นอน
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
title.Text = "Teleport (X Y Z)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = root

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

local countLabel = makeLabel("จำนวน:", 55); countLabel.LayoutOrder = 1; countLabel.Parent = rowOpt
local countBox = makeBox("1"); countBox.LayoutOrder = 2; countBox.Size = UDim2.new(0, 60, 1, 0); countBox.Text = "1"; countBox.Parent = rowOpt

local delayLabel = makeLabel("หน่วง:", 45); delayLabel.LayoutOrder = 3; delayLabel.Parent = rowOpt
local delayBox = makeBox("0.2"); delayBox.LayoutOrder = 4; delayBox.Size = UDim2.new(0, 60, 1, 0); delayBox.Text = "0.2"; delayBox.Parent = rowOpt

-- checkbox group
local loopGroup = Instance.new("Frame")
loopGroup.LayoutOrder = 5
loopGroup.BackgroundTransparency = 1
loopGroup.Size = UDim2.new(1, - (55+60+45+60+40), 1, 0) -- เหลือพื้นที่ที่เหลือ
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

-- ===== Buttons =====
local okBtn = Instance.new("TextButton")
okBtn.LayoutOrder = 4
okBtn.Size = UDim2.new(1, 0, 0, 40)
okBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
okBtn.Text = "OK (Teleport)"
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

local msg = Instance.new("TextLabel")
msg.LayoutOrder = 6
msg.Size = UDim2.new(1, 0, 0, 18)
msg.BackgroundTransparency = 1
msg.Text = ""
msg.TextColor3 = Color3.fromRGB(255, 200, 80)
msg.Font = Enum.Font.Gotham
msg.TextSize = 12
msg.TextXAlignment = Enum.TextXAlignment.Left
msg.Parent = root

-- ===== Logic (ของเดิม) =====
local loopEnabled = false
local loopRunning = false
local loopToken = 0

local function teleportTo(x, y, z)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        msg.Text = "ไม่พบ HumanoidRootPart"
        return false
    end
    hrp.CFrame = CFrame.new(Vector3.new(x, y, z))
    return true
end

local function parseInputs()
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
        okBtn.Text = "OK (Teleport)"
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
    local data, err = parseInputs()
    if not data then
        msg.Text = err
        return
    end

    if not loopEnabled then
        for i = 1, data.count do
            local ok = teleportTo(data.x, data.y, data.z)
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
                local ok = teleportTo(data.x, data.y, data.z)
                if not ok then loopRunning = false break end
                msg.Text = ("Loop #%d | (%d/%d): %.2f, %.2f, %.2f"):format(round, i, data.count, data.x, data.y, data.z)
                if data.delay > 0 then task.wait(data.delay) else RunService.Heartbeat:Wait() end
            end
        end
        setLoopUI(false)
    end)
end)
