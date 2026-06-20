local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- ใช้ WaitForChild รอให้โฟลเดอร์ Loot พร้อมใช้งานสูงสุด 30 วินาที (สำคัญมากสำหรับระบบ Autoexec)
local lootFolder = workspace:WaitForChild("Loot", 30)

-- ลบ UI เก่าทิ้งก่อนถ้าเคยรันไปแล้ว
if CoreGui:FindFirstChild("DeltaX_UltimateLootUI") then
    CoreGui["DeltaX_UltimateLootUI"]:Destroy()
end

-- ดึงตำแหน่ง RemoteFunction จากระบบเกมของคุณ
local remoteFunction = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("leifstout_networker@0.3.1")
    :WaitForChild("networker")
    :WaitForChild("_remotes")
    :WaitForChild("LootService")
    :WaitForChild("RemoteFunction")

-- =========================================================
-- 🎨 [DESIGN UI] สร้างโครงสร้างหน้าต่างควบคุม
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaX_UltimateLootUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- หน้าต่างหลัก (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 270)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- แถบหัวเรื่องด้านบน (Top Bar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "💎 LOOT CONTROLLER (AUTO)"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- ปุ่มย่อหน้าต่าง (Minimize Button)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -55, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize = 14
MinBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

-- ปุ่มปิดหน้าต่าง (Close Button)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 11
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- เส้นแบ่งโซน (Divider)
local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -24, 0, 1)
Line.Position = UDim2.new(0, 12, 0, 35)
Line.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- ---------------------------------------------------------
-- โซนตั้งค่า (Settings Content)
-- ---------------------------------------------------------
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -35)
ContentFrame.Position = UDim2.new(0, 0, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- ช่องใส่ค่าดีเลย์ (Delay Box)
local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0, 120, 0, 30)
DelayLabel.Position = UDim2.new(0, 15, 0, 15)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Font = Enum.Font.GothamMedium
DelayLabel.Text = "หน่วงเวลาลูป (วินาที):"
DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DelayLabel.TextSize = 12
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = ContentFrame

local DelayInput = Instance.new("TextBox")
DelayInput.Size = UDim2.new(0, 140, 0, 30)
DelayInput.Position = UDim2.new(0, 145, 0, 15)
DelayInput.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
DelayInput.Font = Enum.Font.Gotham
DelayInput.Text = "10"
DelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayInput.TextSize = 13
DelayInput.Parent = ContentFrame

local DICorner = Instance.new("UICorner")
DICorner.CornerRadius = UDim.new(0, 6)
DICorner.Parent = DelayInput

-- ส่วนของ Checkbox Loop
local CBBtn = Instance.new("TextButton")
CBBtn.Size = UDim2.new(0, 18, 0, 18)
CBBtn.Position = UDim2.new(0, 15, 0, 56)
CBBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
CBBtn.Text = "✓"
CBBtn.Font = Enum.Font.GothamBold
CBBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
CBBtn.TextSize = 14
CBBtn.Parent = ContentFrame

local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(0, 4)
CBCorner.Parent = CBBtn

local CBLabel = Instance.new("TextLabel")
CBLabel.Size = UDim2.new(0, 200, 0, 18)
CBLabel.Position = UDim2.new(0, 40, 0, 56)
CBLabel.BackgroundTransparency = 1
CBLabel.Font = Enum.Font.GothamMedium
CBLabel.Text = "เปิดทำงานวนลูปต่อเนื่อง"
CBLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
CBLabel.TextSize = 12
CBLabel.TextXAlignment = Enum.TextXAlignment.Left
CBLabel.Parent = ContentFrame

-- ปุ่มเริ่ม/หยุด (ปรับให้เริ่มต้นเป็นสถานะรันอยู่ STOP LOOT สีแดงทันที)
local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, -30, 0, 35)
ActionBtn.Position = UDim2.new(0, 15, 0, 88)
ActionBtn.BackgroundColor3 = Color3.fromRGB(230, 70, 70) -- สีแดงแสดงว่าบอทเริ่มวิ่งแล้ว
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.Text = "STOP LOOT"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.TextSize = 13
ActionBtn.Parent = ContentFrame

local ABCorner = Instance.new("UICorner")
ABCorner.CornerRadius = UDim.new(0, 8)
ABCorner.Parent = ActionBtn

-- ---------------------------------------------------------
-- โซนแสดงผล Log บน UI แทนการ Print
-- ---------------------------------------------------------
local LogFrame = Instance.new("Frame")
LogFrame.Size = UDim2.new(1, -30, 0, 85)
LogFrame.Position = UDim2.new(0, 15, 0, 135)
LogFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
LogFrame.BorderSizePixel = 0
LogFrame.Parent = ContentFrame

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 8)
LogCorner.Parent = LogFrame

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -16, 1, -16)
LogText.Position = UDim2.new(0, 8, 0, 8)
LogText.BackgroundTransparency = 1
LogText.Font = Enum.Font.Code
LogText.Text = "ระบบ: เปิดใช้ระบบออโต้ฟาร์มสำเร็จ..."
LogText.TextColor3 = Color3.fromRGB(0, 255, 170)
LogText.TextSize = 11
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.Parent = LogFrame

-- =========================================================
-- ⚡ [LOGIC SYSTEMS] ระบบควบคุมสคริปต์
-- =========================================================
local isRunning = true -- 🔥 เปลี่ยนเป็น true เพื่อให้สั่งทำงานออโต้ตั้งแต่เริ่มโหลดไฟล์
local isLooping = true 
local currentCooldown = 10
local runningTask = nil

-- ฟังก์ชันอัปเดตข้อความในกล่อง Log บน UI
local function updateUIStatus(message, isError)
    if isError then
        LogText.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        LogText.TextColor3 = Color3.fromRGB(0, 255, 170)
    end
    LogText.Text = "🕒 เวลา: " .. os.date("%X") .. "\n" .. message
end

-- ฟังก์ชันหัวใจหลักในการดึงและยิง Remote เก็บของ
local function executeLooting()
    if not lootFolder or not remoteFunction then
        updateUIStatus("❌ ผิดพลาด: ระบบกำลังรอโหลดโฟลเดอร์ของในเกม...", true)
        return
    end

    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local allItems = lootFolder:GetChildren()
        local firstItem = allItems[1]
        
        if firstItem then
            local itemID = firstItem.Name
            local args = {"requestCollect", itemID}
            
            local success, result = pcall(function()
                return remoteFunction:InvokeServer(unpack(args))
            end)
            
            if success then
                updateUIStatus("⚡ [Auto] สำเร็จ: ยิงเก็บไอเทมรอบนี้แล้ว!\nID: " .. string.sub(itemID, 1, 15) .. "...")
            else
                updateUIStatus("❌ ผิดพลาด: เซิร์ฟเวอร์ปฏิเสธซิกแนล", true)
            end
        else
            updateUIStatus("⏳ [Auto] สถานะ: ไม่พบไอเทมบนพื้น\nกำลังสแกนหาเรื่อยๆ...")
        end
    end
end

-- ระบบลูปควบคุมการทำงานหลัก
local function mainLoop()
    while isRunning do
        executeLooting()
        
        if not isLooping then
            isRunning = false
            ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
            ActionBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
            ActionBtn.Text = "START LOOT"
            updateUIStatus("✅ เสร็จสิ้น: เก็บเฉพาะรอบเรียบร้อย (หยุดทำงานแล้ว)")
            break
        end
        
        local inputVal = tonumber(DelayInput.Text)
        currentCooldown = inputVal or 10
        
        task.wait(currentCooldown)
    end
end

-- 🔥 สั่งเปิดระบบฟาร์มให้ทำงานทันทีด้านหลังแบ็คกราวด์ตั้งแต่สคริปต์โหลดเสร็จ
runningTask = task.spawn(mainLoop)

-- ปุ่มเปิด/ปิดระบบการฟาร์ม (Start / Stop เผื่อต้องการกดคุมมือภายหลัง)
ActionBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        ActionBtn.BackgroundColor3 = Color3.fromRGB(230, 70, 70)
        ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActionBtn.Text = "STOP LOOT"
        updateUIStatus("▶️ เริ่มทำงาน: กำลังดึงของเข้ากระเป๋า...")
        
        runningTask = task.spawn(mainLoop)
    else
        ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
        ActionBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
        ActionBtn.Text = "START LOOT"
        updateUIStatus("⏹️ หยุดทำงาน: หยุดยิงระบบดักชั่วคราว")
        
        if runningTask then
            isRunning = false
            runningTask = nil
        end
    end
end)

-- ปุ่มเลือกเปิด/ปิดการ วนลูป (Checkbox)
CBBtn.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    if isLooping then
        CBBtn.Text = "✓"
        CBBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
    else
        CBBtn.Text = ""
    end
end)

-- ปุ่มย่อ / ขยายหน้าต่าง UI (Minimize)
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentFrame.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 300, 0, 35), "Out", "Quad", 0.2, true)
        MinBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 300, 0, 270), "Out", "Quad", 0.2, true, function()
            ContentFrame.Visible = true
        end)
        MinBtn.Text = "-"
    end
end)

-- ปุ่มปิดสคริปต์ถาวร (Close)
CloseBtn.MouseButton1Click:Connect(function()
    isRunning = false
    ScreenGui:Destroy()
end)
