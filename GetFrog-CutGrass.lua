local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ⚙️ ตั้งค่าความเร็ว และโหมดทำงาน
-- ==========================================
local SCAN_INTERVAL = 0.2  -- เช็กกบทุกๆ กี่วินาที (0.2 วิ)
local AUTO_CATCH = false    -- เปลี่ยนเป็น true ถ้าอยากให้ "จับอัตโนมัติ" ทันทีที่พบกบ

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
-- 2. สร้าง UI หน้าจอ (ขยายความสูงรองรับปุ่มใหม่)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FrogOneClickUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 190) -- ขยายความสูงเป็น 190
mainFrame.Position = UDim2.new(0.5, -140, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- แถบ Header (มีปุ่มย่อ - และปิด X)
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 30)
headerFrame.BackgroundTransparency = 1
headerFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "🐸 Frog One-Click Catch"
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

-- Container สำหรับปุ่มและข้อความ
local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -30)
container.Position = UDim2.new(0, 0, 0, 30)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.02, 0)
statusLabel.Text = "สถานะ: รอเปิดการสแกน..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = container

-- ปุ่มเปิด/ปิด ระบบ Auto Scan
local toggleScanBtn = Instance.new("TextButton")
toggleScanBtn.Size = UDim2.new(0.9, 0, 0, 35)
toggleScanBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleScanBtn.Text = "🔍 เปิด Auto Scan (เช็กทุก 0.2s)"
toggleScanBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 180)
toggleScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleScanBtn.Font = Enum.Font.SourceSansBold
toggleScanBtn.TextSize = 13
toggleScanBtn.Parent = container
Instance.new("UICorner", toggleScanBtn).CornerRadius = UDim.new(0, 6)

-- ปุ่มกดสแกน + วาร์ป + จับกบ (Manual Click)
local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(0.9, 0, 0, 45)
actionBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
actionBtn.Text = "🚀 สแกน + วาร์ป + จับกบ (1 ตัว)"
actionBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
actionBtn.Font = Enum.Font.SourceSansBold
actionBtn.TextSize = 14
actionBtn.Parent = container
Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 3. ระบบย่อ/ปิด UI
-- ==========================================
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 280, 0, 30)
        container.Visible = false
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 280, 0, 190)
        container.Visible = true
        minimizeBtn.Text = "-"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ==========================================
-- 4. ฟังก์ชันหลัก: สแกนหากบ + จับกบ
-- ==========================================
local isCatching = false

local function getFrogsList()
    local eventFrogs = workspace:FindFirstChild("LocalEventFrogs")
    if not eventFrogs then return {} end
    
    local frogs = {}
    for _, child in ipairs(eventFrogs:GetChildren()) do
        if string.sub(child.Name, 1, 5) == "Frog_" then
            table.insert(frogs, child)
        end
    end
    return frogs
end

local function catchFrog(targetFrog)
    if isCatching or not targetFrog then return end
    isCatching = true

    local frogUUID = string.sub(targetFrog.Name, 6)
    
    -- วาร์ปไปตำแหน่งกบ
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if hrp then
        local frogCFrame = nil
        if targetFrog:IsA("Model") and targetFrog.PrimaryPart then
            frogCFrame = targetFrog.PrimaryPart.CFrame
        elseif targetFrog:FindFirstChild("RootPart") then
            frogCFrame = targetFrog.RootPart.CFrame
        elseif targetFrog:IsA("BasePart") then
            frogCFrame = targetFrog.CFrame
        end

        if frogCFrame then
            hrp.CFrame = frogCFrame + Vector3.new(0, 2, 0)
        end
    end

    statusLabel.Text = "⚡ วาร์ปแล้ว กำลังรอซิงค์..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    task.wait(0.2)

    -- ยิง Remote
    local success, result = pcall(function()
        return catchRemote:InvokeServer(frogUUID)
    end)

    if success then
        statusLabel.Text = "✅ จับสำเร็จ! UUID: " .. string.sub(frogUUID, 1, 8)
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusLabel.Text = "❌ จับไม่สำเร็จ"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end

    task.wait(0.3)
    isCatching = false
end

-- ==========================================
-- 5. ระบบ Loop เช็กกบอัตโนมัติ (เปิด/ปิด ได้)
-- ==========================================
local isScanning = false

toggleScanBtn.MouseButton1Click:Connect(function()
    isScanning = not isScanning
    
    if isScanning then
        toggleScanBtn.Text = "🛑 ปิด Auto Scan"
        toggleScanBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        
        -- เริ่ม Loop สแกนทุก 0.2 วิ
        task.spawn(function()
            while isScanning do
                local frogs = getFrogsList()
                local count = #frogs
                
                if count > 0 then
                    statusLabel.Text = "🎯 พบกบในแมพ: " .. count .. " ตัว!"
                    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    
                    -- ถ้าเปิด AUTO_CATCH ให้มันจับให้อัตโนมัติเลย
                    if AUTO_CATCH and not isCatching then
                        catchFrog(frogs[1])
                    end
                else
                    statusLabel.Text = "⚠️ ไม่พบกบใน LocalEventFrogs"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                end
                
                task.wait(SCAN_INTERVAL)
            end
        end)
    else
        toggleScanBtn.Text = "🔍 เปิด Auto Scan (เช็กทุก 0.2s)"
        toggleScanBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 180)
        statusLabel.Text = "สถานะ: ปิดการสแกนแล้ว"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- ปุ่ม Manual Catch (กดมือเอง)
actionBtn.MouseButton1Click:Connect(function()
    local frogs = getFrogsList()
    if #frogs > 0 then
        catchFrog(frogs[1])
    else
        statusLabel.Text = "⚠️ ไม่พบกบใน LocalEventFrogs"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)
