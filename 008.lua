local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- ลบ UI เก่าทิ้งก่อนถ้าเคยรันไปแล้ว
if CoreGui:FindFirstChild("DeltaX_SpeedUI_V2") then
    CoreGui["DeltaX_SpeedUI_V2"]:Destroy()
end

-- =========================================================
-- 🎨 สร้างโครงสร้าง UI (สไตล์โมเดิร์น ดำ-โปร่งแสง)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaX_SpeedUI_V2"
ScreenGui.Parent = CoreGui

-- 1. หน้าต่างหลัก (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 180) -- เพิ่มความสูงเพื่อใส่ Checkbox
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- คลิกลากย้ายได้
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- 2. หัวข้อ (Title)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ DELTAX SPEED V2"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 14
Title.Parent = MainFrame

-- 3. ช่องพิมพ์ตัวเลข (TextBox)
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 220, 0, 35)
SpeedInput.Position = UDim2.new(0.5, -110, 0, 45)
SpeedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpeedInput.BorderSizePixel = 0
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.Text = "50" -- ใส่ค่าเริ่มต้นให้เลย
SpeedInput.PlaceholderText = "ใส่ความเร็ว..."
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.TextSize = 14
SpeedInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = SpeedInput

-- 4. ส่วนของ Checkbox ล็อกความเร็ว
local CheckboxFrame = Instance.new("Frame")
CheckboxFrame.Size = UDim2.new(0, 220, 0, 30)
CheckboxFrame.Position = UDim2.new(0.5, -110, 0, 90)
CheckboxFrame.BackgroundTransparency = 1
CheckboxFrame.Parent = MainFrame

local CheckboxBtn = Instance.new("TextButton")
CheckboxBtn.Size = UDim2.new(0, 20, 0, 20)
CheckboxBtn.Position = UDim2.new(0, 5, 0, 5)
CheckboxBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
CheckboxBtn.BorderSizePixel = 0
CheckboxBtn.Text = "" -- เริ่มต้นเป็นว่างเปล่า (ปิด)
CheckboxBtn.Font = Enum.Font.GothamBold
CheckboxBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
CheckboxBtn.TextSize = 16
CheckboxBtn.Parent = CheckboxFrame

local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(0, 4)
CBCorner.Parent = CheckboxBtn

local CheckboxLabel = Instance.new("TextLabel")
CheckboxLabel.Size = UDim2.new(0, 180, 0, 30)
CheckboxLabel.Position = UDim2.new(0, 35, 0, 0)
CheckboxLabel.BackgroundTransparency = 1
CheckboxLabel.Font = Enum.Font.Gotham
CheckboxLabel.Text = "ล็อกความเร็วตลอดเวลา (Loop)"
CheckboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CheckboxLabel.TextXAlignment = Enum.TextXAlignment.Left
CheckboxLabel.TextSize = 13
CheckboxLabel.Parent = CheckboxFrame

-- 5. ปุ่มกดปรับความเร็ว (Set Button)
local SetButton = Instance.new("TextButton")
SetButton.Size = UDim2.new(0, 220, 0, 35)
SetButton.Position = UDim2.new(0.5, -110, 0, 130)
SetButton.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
SetButton.BorderSizePixel = 0
SetButton.Font = Enum.Font.GothamBold
SetButton.Text = "SET SPEED"
SetButton.TextColor3 = Color3.fromRGB(15, 15, 15)
SetButton.TextSize = 14
SetButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = SetButton

-- =========================================================
-- ⚡ ระบบการทำงาน (Logic)
-- =========================================================
local isLooping = false
local currentSpeed = 16
local loopConnection = nil

-- ฟังก์ชันดึงค่าจากช่องพิมพ์และตั้งค่าให้กับตัวละคร
local function updateSpeed()
    local targetSpeed = tonumber(SpeedInput.Text)
    if targetSpeed then
        currentSpeed = targetSpeed
        if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
            lp.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = currentSpeed
        end
    end
end

-- สั่งเริ่มหรือหยุดลูปการล็อกความเร็ว (เชื่อมกับ Checkbox)
local function toggleLoop()
    isLooping = not isLooping
    
    if isLooping then
        -- เปิดใช้งาน: เปลี่ยน Checkbox เป็นสีเขียว มีเครื่องหมายถูก ✔️
        CheckboxBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        CheckboxBtn.Text = "✓"
        updateSpeed() -- อัปเดตความเร็วปัจจุบันก่อนเริ่มลูป
        
        -- ใช้ RunService.Heartbeat ลูปถมค่าความเร็วทุกๆ เฟรม (เร็วและเนียนที่สุด เกมดักรีเซ็ตไม่ทันแน่นอน)
        loopConnection = RunService.Heartbeat:Connect(function()
            if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                lp.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = currentSpeed
            end
        end)
        print("DeltaX: เปิดระบบล็อกความเร็วแบบวนลูป")
    else
        -- ปิดใช้งาน: เปลี่ยน Checkbox กลับเป็นสีมืด
        CheckboxBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        CheckboxBtn.Text = ""
        
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
        print("DeltaX: ปิดระบบล็อกความเร็ว")
    end
end

-- เชื่อมต่อเหตุการณ์เข้ากับปุ่มต่างๆ
SetButton.MouseButton1Click:Connect(function()
    updateSpeed()
    -- เอฟเฟกต์ปุ่มกระพริบเมื่อกด
    local oldColor = SetButton.BackgroundColor3
    SetButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    task.wait(0.1)
    SetButton.BackgroundColor3 = oldColor
end)

CheckboxBtn.MouseButton1Click:Connect(toggleLoop)

-- เมื่อตัวละครเกิดใหม่ (หากยังเปิดติ๊กถูกอยู่) สคริปต์ก็จะล็อกความเร็วให้ต่อทันที
lp.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum and isLooping then
        hum.WalkSpeed = currentSpeed
    end
end)
