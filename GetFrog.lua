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
-- 2. สร้าง UI หน้าจอ (ปรับขนาดเพิ่มปุ่มวาร์ป)
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
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Text = "🐸 Frog Teleport & Catch"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 35)
statusLabel.Position = UDim2.new(0.05, 0, 0.14, 0)
statusLabel.Text = "สถานะ: รอสแกนหากบ..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = mainFrame

-- ปุ่มที่ 1: สแกน
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 32)
scanBtn.Position = UDim2.new(0.05, 0, 0.32, 0)
scanBtn.Text = "1. สแกนหากบตัวแรก"
scanBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.Font = Enum.Font.SourceSansBold
scanBtn.TextSize = 13
scanBtn.Parent = mainFrame
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 5)

-- ปุ่มที่ 2: วาร์ป
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.9, 0, 0, 32)
tpBtn.Position = UDim2.new(0.05, 0, 0.48, 0)
tpBtn.Text = "2. วาร์ปไปหากบตัวนี้"
tpBtn.BackgroundColor3 = Color3.fromRGB(200, 130, 30)
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.SourceSansBold
tpBtn.TextSize = 13
tpBtn.Parent = mainFrame
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5)

-- ปุ่มที่ 3: จับ
local catchBtn = Instance.new("TextButton")
catchBtn.Size = UDim2.new(0.9, 0, 0, 32)
catchBtn.Position = UDim2.new(0.05, 0, 0.64, 0)
catchBtn.Text = "3. ส่งคำสั่งจับ (InvokeServer)"
catchBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
catchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
catchBtn.Font = Enum.Font.SourceSansBold
catchBtn.TextSize = 13
catchBtn.Parent = mainFrame
Instance.new("UICorner", catchBtn).CornerRadius = UDim.new(0, 5)

-- ==========================================
-- 3. ระบบการทำงาน
-- ==========================================
local currentFrogObject = nil
local currentFrogUUID = nil

-- Step 1: สแกนหากบ
scanBtn.MouseButton1Click:Connect(function()
    local eventFrogs = workspace:FindFirstChild("LocalEventFrogs")
    currentFrogObject = nil
    currentFrogUUID = nil

    if not eventFrogs then
        statusLabel.Text = "❌ ไม่พบ LocalEventFrogs ใน Workspace"
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
        print("[Scan] พบกบ:", currentFrogObject.Name)
    else
        statusLabel.Text = "⚠️ ไม่พบกบใน LocalEventFrogs"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end)

-- Step 2: วาร์ปไปตำแหน่งกบ
tpBtn.MouseButton1Click:Connect(function()
    if not currentFrogObject or not currentFrogObject.Parent then
        statusLabel.Text = "⚠️ กรุณาสแกนหากบก่อน หรือกบอาจจะหายไปแล้ว!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if not hrp then
        statusLabel.Text = "❌ ไม่พบตัวละครของคุณ"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    -- ค้นหาพิกัดของกบ (เช็คจาก CFrame ของตัวกบ หรือ RootPart/PrimaryPart)
    local frogCFrame = nil
    if currentFrogObject:IsA("Model") and currentFrogObject.PrimaryPart then
        frogCFrame = currentFrogObject.PrimaryPart.CFrame
    elseif currentFrogObject:FindFirstChild("RootPart") then
        frogCFrame = currentFrogObject.RootPart.CFrame
    elseif currentFrogObject:IsA("BasePart") then
        frogCFrame = currentFrogObject.CFrame
    end

    if frogCFrame then
        -- วาร์ปตัวละครไปเหนือกบเล็กน้อย (+3 studs ด้านบน) เพื่อไม่ให้ตัวจมดิน
        hrp.CFrame = frogCFrame + Vector3.new(0, 3, 0)
        statusLabel.Text = "⚡ วาร์ปไปหากบสำเร็จ!"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 255)
        print("[Teleport] วาร์ปไปพิกัด:", frogCFrame.Position)
    else
        statusLabel.Text = "❌ ไม่พบตำแหน่ง (Part) ของกบตัวนี้"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Step 3: ส่งคำสั่งจับ
catchBtn.MouseButton1Click:Connect(function()
    if not currentFrogUUID then
        statusLabel.Text = "⚠️ กรุณาสแกนหากบก่อน!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end

    statusLabel.Text = "กำลังส่งคำสั่งจับ..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    task.spawn(function()
        local success, result = pcall(function()
            return catchRemote:InvokeServer(currentFrogUUID)
        end)

        if success then
            statusLabel.Text = "✅ จับสำเร็จ! Result: " .. tostring(result)
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            print("[Catch Result]:", result)
            
            -- ล้างค่าเตรียมทดสอบตัวถัดไป
            currentFrogObject = nil
            currentFrogUUID = nil
        else
            statusLabel.Text = "❌ จับไม่สำเร็จ (Error)"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            warn("[Catch Error]:", result)
        end
    end)
end)
