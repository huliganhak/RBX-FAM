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
screenGui.Name = "FrogOneClickUI"
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
        mainFrame.Size = UDim2.new(0, 280, 0, 150)
        container.Visible = true
        minimizeBtn.Text = "-"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ==========================================
-- 4. โค้ดทำงานรวม (Single Click)
-- ==========================================
actionBtn.MouseButton1Click:Connect(function()
    local eventFrogs = workspace:FindFirstChild("LocalEventFrogs")
    if not eventFrogs then
        statusLabel.Text = "❌ ไม่พบ LocalEventFrogs"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    -- 1. สแกนหากบตัวแรก
    local targetFrog = nil
    for _, child in ipairs(eventFrogs:GetChildren()) do
        if string.sub(child.Name, 1, 5) == "Frog_" then
            targetFrog = child
            break
        end
    end

    if not targetFrog then
        statusLabel.Text = "⚠️ ไม่พบกบใน LocalEventFrogs"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end

    local frogUUID = string.sub(targetFrog.Name, 6)
    
    -- 2. วาร์ปไปตำแหน่งกบ
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
            hrp.CFrame = frogCFrame + Vector3.new(0, 2, 0) -- วาร์ปไปเหนือหัวกบเล็กน้อย
        end
    end

    statusLabel.Text = "⚡ วาร์ปแล้ว กำลังรอซิงค์ตำแหน่ง..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    -- -------------------------------------------------------------
    -- ⏳ [จุดสำคัญ] หน่วงเวลา 0.2 วินาทีเพื่อให้ Server รับรู้พิกัดวาร์ป
    -- (ถ้ายังจับไม่ติด ลองปรับเพิ่มเป็น 0.3 หรือ 0.5 ดูครับ)
    -- -------------------------------------------------------------
    task.wait(0.2)

    -- 3. ยิง RemoteFunction สั่งจับกบ
    task.spawn(function()
        local success, result = pcall(function()
            return catchRemote:InvokeServer(frogUUID)
        end)

        if success then
            statusLabel.Text = "✅ จับสำเร็จ! UUID: " .. string.sub(frogUUID, 1, 8) .. "..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            statusLabel.Text = "❌ จับไม่สำเร็จ (Error)"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
end)
