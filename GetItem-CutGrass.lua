local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. ฟังก์ชันอ้างอิงตำแหน่ง SpawnZone
-- ==========================================
local function getSpawnZone()
    local zones = workspace:FindFirstChild("Zones")
    local w5 = zones and zones:FindFirstChild("W5")
    local zone47 = w5 and w5:FindFirstChild("Zone_47")
    return zone47 and zone47:FindFirstChild("SpawnZone")
end

-- ==========================================
-- 2. สร้าง UI หน้าจอ
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ItemOneClickUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 150)
mainFrame.Position = UDim2.new(0.5, -140, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Header (มีปุ่มย่อ - และปิด X)
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 30)
headerFrame.BackgroundTransparency = 1
headerFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "📦 Item One-Click Collect"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = headerFrame

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

-- Container
local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -30)
container.Position = UDim2.new(0, 0, 0, 30)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 35)
statusLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
statusLabel.Text = "สถานะ: พร้อมทำงาน"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = container

-- ปุ่มกดครั้งเดียวจบ
local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(0.9, 0, 0, 45)
actionBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
actionBtn.Text = "🚀 สแกน + วาร์ป + เก็บไอเทม (1 ชิ้น)"
actionBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
actionBtn.Font = Enum.Font.SourceSansBold
actionBtn.TextSize = 13
actionBtn.Parent = container
Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 3. ระบบย่อ / ปิด UI
-- ==========================================
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 280, 0, 30)
        container.Visible = false
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 280, 0, 150)
        container.Visible = true
        minimizeBtn.Text = "-"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ==========================================
-- 4. ระบบทำงาน 1 Click (สแกน ➔ วาร์ป ➔ เก็บ)
-- ==========================================
actionBtn.MouseButton1Click:Connect(function()
    local spawnZone = getSpawnZone()
    if not spawnZone then
        statusLabel.Text = "❌ ไม่พบ SpawnZone ใน Zone_47"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    -- 1. สแกนหาไอเทมชิ้นแรก
    local items = spawnZone:GetChildren()
    if #items == 0 then
        statusLabel.Text = "⚠️ ไม่พบไอเทมใน SpawnZone"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end

    local targetItem = items[1]

    -- 2. วาร์ปไปหาไอเทม
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if hrp then
        local itemCFrame = nil
        if targetItem:IsA("Model") then
            itemCFrame = targetItem.PrimaryPart and targetItem.PrimaryPart.CFrame or targetItem:GetPivot()
        elseif targetItem:IsA("BasePart") then
            itemCFrame = targetItem.CFrame
        else
            local part = targetItem:FindFirstChildWhichIsA("BasePart", true)
            if part then itemCFrame = part.CFrame end
        end

        if itemCFrame then
            hrp.CFrame = itemCFrame + Vector3.new(0, 2, 0)
        end
    end

    -- ⏳ หน่วงเวลา 0.2 วินาทีให้ Server ซิงค์พิกัดตัวละคร
    task.wait(0.2)

    -- 3. สั่งเก็บไอเทม (ลองหาทั้ง Prompt และ Touch)
    -- 3. สั่งเก็บไอเทมแบบ Instant (เร็วกว่าเดิม ไม่ต้องรอ HoldDuration)
    statusLabel.Text = "⚡ วาร์ปแล้ว กำลังเก็บ: " .. targetItem.Name
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    local prompt = targetItem:FindFirstChildWhichIsA("ProximityPrompt", true)

    if prompt then
        -- ใช้ fireproximityprompt ข้ามเวลา HoldDuration ทันที
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            -- เผื่อกรณีใช้ Executor ที่ไม่รองรับคำสั่งนี้ ให้ย้อนกลับไปใช้แบบเดิม
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end

        statusLabel.Text = "⚡ เก็บสำเร็จ (Instant Prompt): " .. targetItem.Name
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        -- ถ้าไม่มี Prompt ใช้ firetouchinterest สำหรับไอเทมแบบเดินชน
        local itemPart = targetItem:IsA("BasePart") and targetItem or targetItem:FindFirstChildWhichIsA("BasePart", true)
        if hrp and itemPart and firetouchinterest then
            firetouchinterest(hrp, itemPart, 0)
            task.wait(0.05)
            firetouchinterest(hrp, itemPart, 1)

            statusLabel.Text = "✅ เก็บสำเร็จ! (Touch): " .. targetItem.Name
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            statusLabel.Text = "❌ ไม่พบวิธีเก็บไอเทมชิ้นนี้"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end)
