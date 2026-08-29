local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. สร้าง UI หน้าจอ
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DynamicItemCollectorUI"
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

-- Header (ย่อ/ปิด)
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 30)
headerFrame.BackgroundTransparency = 1
headerFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "📦 Dynamic Zone Collector"
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

-- ช่องพิมพ์ World (ค่าเริ่มต้น: W5)
local worldBox = Instance.new("TextBox")
worldBox.Size = UDim2.new(0.42, 0, 0, 30)
worldBox.Position = UDim2.new(0.05, 0, 0.05, 0)
worldBox.Text = "W5"
worldBox.PlaceholderText = "World (e.g. W5)"
worldBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
worldBox.TextColor3 = Color3.fromRGB(255, 255, 255)
worldBox.Font = Enum.Font.SourceSansBold
worldBox.TextSize = 13
worldBox.Parent = container
Instance.new("UICorner", worldBox).CornerRadius = UDim.new(0, 4)

-- ช่องพิมพ์ Zone (ค่าเริ่มต้น: Zone_47)
local zoneBox = Instance.new("TextBox")
zoneBox.Size = UDim2.new(0.45, 0, 0, 30)
zoneBox.Position = UDim2.new(0.5, 0, 0.05, 0)
zoneBox.Text = "Zone_47"
zoneBox.PlaceholderText = "Zone (e.g. Zone_47)"
zoneBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
zoneBox.TextColor3 = Color3.fromRGB(255, 255, 255)
zoneBox.Font = Enum.Font.SourceSansBold
zoneBox.TextSize = 13
zoneBox.Parent = container
Instance.new("UICorner", zoneBox).CornerRadius = UDim.new(0, 4)

-- ข้อความบอกสถานะ
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.28, 0)
statusLabel.Text = "สถานะ: พร้อมทำงาน"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = container

-- ปุ่มทำงาน 1-Click
local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(0.9, 0, 0, 45)
actionBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
actionBtn.Text = "🚀 สแกน + วาร์ป + เก็บไอเทม"
actionBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
actionBtn.Font = Enum.Font.SourceSansBold
actionBtn.TextSize = 14
actionBtn.Parent = container
Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 2. ระบบย่อ/ปิด UI
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
-- 3. ฟังก์ชันค้นหา SpawnZone แบบ Dynamic สแกนสดทุกครั้ง
-- ==========================================
local function getSpawnZoneDynamic()
    local selectedWorld = worldBox.Text -- อ่านค่า World จาก TextBox
    local selectedZone = zoneBox.Text   -- อ่านค่า Zone จาก TextBox

    local zonesFolder = workspace:FindFirstChild("Zones")
    if not zonesFolder then return nil, "ไม่พบ workspace.Zones" end

    -- สแกนสดหา World (เช่น W1-W5)
    local targetWorld = zonesFolder:FindFirstChild(selectedWorld)
    if not targetWorld then return nil, "ไม่พบ World: " .. selectedWorld end

    -- สแกนสดหา Zone (เช่น Zone_47) เผื่อเพิ่งโหลดขึ้นมา
    local targetZone = targetWorld:FindFirstChild(selectedZone)
    if not targetZone then return nil, "ไม่พบ " .. selectedZone .. " ใน " .. selectedWorld end

    -- ค้นหา SpawnZone ภายใน Zone นั้น
    local spawnZone = targetZone:FindFirstChild("SpawnZone")
    if not spawnZone then return nil, "ไม่พบ SpawnZone ใน " .. selectedZone end

    return spawnZone, nil
end

-- ==========================================
-- 4. ระบบการทำงาน
-- ==========================================
actionBtn.MouseButton1Click:Connect(function()
    -- ดึง SpawnZone ใหม่สดๆ ทุกรอบที่กด
    local spawnZone, err = getSpawnZoneDynamic()
    if not spawnZone then
        statusLabel.Text = "❌ " .. tostring(err)
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    -- สแกนหาไอเทมชิ้นแรก
    local items = spawnZone:GetChildren()
    if #items == 0 then
        statusLabel.Text = "⚠️ ไม่พบไอเทมใน " .. zoneBox.Text
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end

    local targetItem = items[1]

    -- วาร์ปไปตำแหน่งไอเทม
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
            hrp.CFrame = itemCFrame
        end
    end

    statusLabel.Text = "⚡ วาร์ปแล้ว รอ Server ซิงค์..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    -- หน่วงเวลาเล็กน้อยเพื่อให้ Server รับพิกัด
    task.wait(0.15)

    -- สั่งเก็บไอเทมแบบ Instant (ซ้ำ 3 รอบกันหลุด)
    local prompt = targetItem:FindFirstChildWhichIsA("ProximityPrompt", true)

    if prompt then
        if fireproximityprompt then
            for i = 1, 3 do
                if targetItem.Parent then
                    fireproximityprompt(prompt)
                    task.wait(0.05)
                end
            end
        else
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end

        statusLabel.Text = "✅ เก็บสำเร็จ: " .. targetItem.Name
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        local itemPart = targetItem:IsA("BasePart") and targetItem or targetItem:FindFirstChildWhichIsA("BasePart", true)
        if hrp and itemPart and firetouchinterest then
            firetouchinterest(hrp, itemPart, 0)
            task.wait(0.05)
            firetouchinterest(hrp, itemPart, 1)

            statusLabel.Text = "✅ เก็บสำเร็จ (Touch): " .. targetItem.Name
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            statusLabel.Text = "❌ ไม่พบวิธีเก็บไอเทม"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end)
