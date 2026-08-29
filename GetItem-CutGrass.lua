local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. กำหนดตำแหน่งที่ต้องการค้นหาไอเทม
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
screenGui.Name = "ItemCollectorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 240)
mainFrame.Position = UDim2.new(0.5, -150, 0.35, 0)
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
titleLabel.Text = "📦 Item Collector Tester"
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
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0, 0)
statusLabel.Text = "สถานะ: รอสแกนหาไอเทม..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = container

-- ปุ่ม 3 Step
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 32)
scanBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
scanBtn.Text = "1. สแกนหาไอเทมตัวแรก"
scanBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.Font = Enum.Font.SourceSansBold
scanBtn.TextSize = 13
scanBtn.Parent = container
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 5)

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.9, 0, 0, 32)
tpBtn.Position = UDim2.new(0.05, 0, 0.44, 0)
tpBtn.Text = "2. วาร์ปไปหาไอเทม"
tpBtn.BackgroundColor3 = Color3.fromRGB(200, 130, 30)
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.SourceSansBold
tpBtn.TextSize = 13
tpBtn.Parent = container
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5)

local collectBtn = Instance.new("TextButton")
collectBtn.Size = UDim2.new(0.9, 0, 0, 32)
collectBtn.Position = UDim2.new(0.05, 0, 0.66, 0)
collectBtn.Text = "3. สั่งกดเก็บ (Prompt / Touch)"
collectBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
collectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
collectBtn.Font = Enum.Font.SourceSansBold
collectBtn.TextSize = 13
collectBtn.Parent = container
Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0, 5)

-- ==========================================
-- 3. ระบบย่อ/ปิด UI
-- ==========================================
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 300, 0, 30)
        container.Visible = false
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 300, 0, 240)
        container.Visible = true
        minimizeBtn.Text = "-"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ==========================================
-- 4. ระบบการทำงาน 3 ขั้นตอน
-- ==========================================
local currentItem = nil

-- Step 1: สแกนหาไอเทมตัวแรกใน SpawnZone
scanBtn.MouseButton1Click:Connect(function()
    local spawnZone = getSpawnZone()
    currentItem = nil

    if not spawnZone then
        statusLabel.Text = "❌ ไม่พบ SpawnZone ในพิกัดที่ระบุ"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    -- ดึงไอเทมตัวแรกที่เจอใน Folder/Zone
    local items = spawnZone:GetChildren()
    if #items > 0 then
        currentItem = items[1]
        statusLabel.Text = "พบไอเทม: " .. currentItem.Name
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        print("[Scan] พบไอเทม:", currentItem.Name)
    else
        statusLabel.Text = "⚠️ ไม่พบไอเทมใน SpawnZone"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end)

-- Step 2: วาร์ปไปหาไอเทม
tpBtn.MouseButton1Click:Connect(function()
    if not currentItem or not currentItem.Parent then
        statusLabel.Text = "⚠️ กรุณาสแกนหาไอเทมก่อน หรือไอเทมหายไปแล้ว"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if not hrp then return end

    -- หาพิกัด CFrame ของไอเทม (รองรับทั้ง Model, Part และ MeshPart)
    local itemCFrame = nil
    if currentItem:IsA("Model") then
        itemCFrame = currentItem.PrimaryPart and currentItem.PrimaryPart.CFrame or currentItem:GetPivot()
    elseif currentItem:IsA("BasePart") then
        itemCFrame = currentItem.CFrame
    else
        -- ถ้าไอเทมมี Part ซ่อนอยู่ข้างใน
        local part = currentItem:FindFirstChildWhichIsA("BasePart", true)
        if part then itemCFrame = part.CFrame end
    end

    if itemCFrame then
        hrp.CFrame = itemCFrame + Vector3.new(0, 2, 0)
        statusLabel.Text = "⚡ วาร์ปไปหา " .. currentItem.Name .. " แล้ว!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 255)
    else
        statusLabel.Text = "❌ ไม่พบพิกัดของไอเทมนี้"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Step 3: สั่งกดเก็บไอเทม
collectBtn.MouseButton1Click:Connect(function()
    if not currentItem or not currentItem.Parent then
        statusLabel.Text = "⚠️ ไม่พบไอเทมเป้าหมาย"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end

    statusLabel.Text = "กำลังพยายามเก็บไอเทม..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    -- ค้นหา ProximityPrompt ข้างในไอเทม
    local prompt = currentItem:FindFirstChildWhichIsA("ProximityPrompt", true)

    if prompt then
        -- แบบที่ 1: ถ้าไอเทมใช้ ProximityPrompt ในการเก็บ
        prompt:InputHoldBegin()
        if prompt.HoldDuration > 0 then
            task.wait(prompt.HoldDuration)
        end
        prompt:InputHoldEnd()
        
        statusLabel.Text = "✅ Trigger ProximityPrompt สำเร็จ!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        -- แบบที่ 2: ถ้าเป็นไอเทมประเภทเดินชน (TouchInterest)
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local itemPart = currentItem:IsA("BasePart") and currentItem or currentItem:FindFirstChildWhichIsA("BasePart", true)

        if hrp and itemPart then
            firetouchinterest(hrp, itemPart, 0)
            task.wait(0.1)
            firetouchinterest(hrp, itemPart, 1)
            
            statusLabel.Text = "✅ สั่ง Touch (เดินชน) ไอเทมเรียบร้อย!"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            statusLabel.Text = "❌ ไม่พบวิธีเก็บ (ไม่มี Prompt หรือ Part ให้ชน)"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end)
