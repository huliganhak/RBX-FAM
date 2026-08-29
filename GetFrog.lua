local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. อ้างอิง RemoteFunction (Knit)
-- ==========================================
local catchRemote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("acecateer_knit@1.7.2")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("FrogEventService")
    :WaitForChild("RF")
    :WaitForChild("Catch")

-- ==========================================
-- 2. สร้าง UI หน้าจอ
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FrogTeleportCatchUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 240)
mainFrame.Position = UDim2.new(0.5, -150, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true -- ตัดส่วนเกินเมื่อทำการย่อ UI
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- แถบ Header สำหรับคลิกลากและวางปุ่มควบคุม
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 30)
headerFrame.BackgroundTransparency = 1
headerFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "🐸 Frog Catch Tester"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = headerFrame

-- ปุ่มย่อ UI (-)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -55, 0, 3)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 16
minimizeBtn.Parent = headerFrame
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 4)

-- ปุ่มปิด UI (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -28, 0, 3)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 13
closeBtn.Parent = headerFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

-- ส่วนเนื้อหาภายใน UI
local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -30)
container.Position = UDim2.new(0, 0, 0, 30)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0, 0)
statusLabel.Text = "สถานะ: รอสแกนหากบ..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = container

-- ปุ่มขั้นตอนต่างๆ
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 32)
scanBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
scanBtn.Text = "1. สแกนหากบตัวแรก"
scanBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.Font = Enum.Font.SourceSansBold
scanBtn.TextSize = 13
scanBtn.Parent = container
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 5)

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.9, 0, 0, 32)
tpBtn.Position = UDim2.new(0.05, 0, 0.44, 0)
tpBtn.Text = "2. วาร์ปไปหากบตัวนี้"
tpBtn.BackgroundColor3 = Color3.fromRGB(200, 130, 30)
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.SourceSansBold
tpBtn.TextSize = 13
tpBtn.Parent = container
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5)

local catchBtn = Instance.new("TextButton")
catchBtn.Size = UDim2.new(0.9, 0, 0, 32)
catchBtn.Position = UDim2.new(0.05, 0, 0.66, 0)
catchBtn.Text = "3. ส่งคำสั่งจับ (InvokeServer)"
catchBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
catchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
catchBtn.Font = Enum.Font.SourceSansBold
catchBtn.TextSize = 13
catchBtn.Parent = container
Instance.new("UICorner", catchBtn).CornerRadius = UDim.new(0, 5)

-- ==========================================
-- 3. ระบบควบคุมปุ่มย่อ / ปุ่มปิด
-- ==========================================
local isMinimized = false

-- สลับการย่อ/ขยายหน้าจอ
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 300, 0, 30) -- ย่อเหลือเฉพาะแถบ Title
        container.Visible = false
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 300, 0, 240) -- ขยายกลับขนาดปกติ
        container.Visible = true
        minimizeBtn.Text = "-"
    end
end)

-- ทำลาย UI ทิ้งเมื่อกดปิด
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ==========================================
-- 4. ระบบการทำงานสแกน / วาร์ป / จับ
-- ==========================================
local currentFrogObject = nil
local currentFrogUUID = nil

scanBtn.MouseButton1Click:Connect(function()
    local eventFrogs = workspace:FindFirstChild("LocalEventFrogs")
    currentFrogObject = nil
    currentFrogUUID = nil

    if not eventFrogs then
        statusLabel.Text = "❌ ไม่พบ LocalEventFrogs"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    for _, child in ipairs(eventFrogs:GetChildren()) do
        if string.sub(child.Name, 1, 5) == "Frog_" then
            currentFrogObject = child
            currentFrogUUID = string.sub(child.Name, 6)
            break
        end
    end

    if currentFrogObject and currentFrogUUID then
        statusLabel.Text = "พบกบ: " .. currentFrogUUID
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusLabel.Text = "⚠️ ไม่พบกบใน LocalEventFrogs"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end)

tpBtn.MouseButton1Click:Connect(function()
    if not currentFrogObject or not currentFrogObject.Parent then
        statusLabel.Text = "⚠️ สแกนหากบก่อน หรือกบไม่อยู่แล้ว"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if not hrp then return end

    local frogCFrame = nil
    if currentFrogObject:IsA("Model") and currentFrogObject.PrimaryPart then
        frogCFrame = currentFrogObject.PrimaryPart.CFrame
    elseif currentFrogObject:FindFirstChild("RootPart") then
        frogCFrame = currentFrogObject.RootPart.CFrame
    elseif currentFrogObject:IsA("BasePart") then
        frogCFrame = currentFrogObject.CFrame
    end

    if frogCFrame then
        hrp.CFrame = frogCFrame + Vector3.new(0, 3, 0)
        statusLabel.Text = "⚡ วาร์ปสำเร็จ!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 255)
    end
end)

catchBtn.MouseButton1Click:Connect(function()
    if not currentFrogUUID then return end

    statusLabel.Text = "กำลังส่งคำสั่งจับ..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    task.spawn(function()
        local success, result = pcall(function()
            return catchRemote:InvokeServer(currentFrogUUID)
        end)

        if success then
            statusLabel.Text = "✅ จับสำเร็จ!"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            currentFrogObject = nil
            currentFrogUUID = nil
        else
            statusLabel.Text = "❌ จับไม่สำเร็จ"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
end)
