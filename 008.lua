local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local lp = Players.LocalPlayer

-- ลบ UI เก่าทิ้งก่อนถ้าเคยรันไปแล้ว
if CoreGui:FindFirstChild("DeltaX_UltimateLootUI") then
    CoreGui["DeltaX_UltimateLootUI"]:Destroy()
end

-- ดึงตำแหน่ง RemoteFunction จากระบบเกม
local remoteFunction = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("leifstout_networker@0.3.1")
    :WaitForChild("networker")
    :WaitForChild("_remotes")
    :WaitForChild("LootService")
    :WaitForChild("RemoteFunction")

-- =========================================================
-- 🎨 [COMPACT DESIGN UI] โครงสร้างหน้าต่างควบคุมแบบประหยัดพื้นที่
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaX_UltimateLootUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- หน้าต่างหลัก (ย่อขนาดลงเพื่อความกะทัดรัด)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 250)
MainFrame.Position = UDim2.new(0.5, -140, 0.4, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- แถบหัวเรื่องด้านบน (Top Bar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "💎 LOOT CONTROLLER"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- ปุ่มย่อหน้าต่าง (Minimize)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -45, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize = 12
MinBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

-- ปุ่มปิดหน้าต่าง (Close)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -22, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 10
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- เส้นแบ่งโซน (Divider)
local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -20, 0, 1)
Line.Position = UDim2.new(0, 10, 0, 30)
Line.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- โซนเนื้อหา (Content)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- UI Layout สำหรับจัดระเบียบองค์ประกอบภายในแบบอัตโนมัติ เพื่อความเป๊ะ
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- เว้นระยะด้านบนเล็กน้อย
local PaddingTop = Instance.new("Frame")
PaddingTop.Size = UDim2.new(1, 0, 0, 4)
PaddingTop.BackgroundTransparency = 1
PaddingTop.LayoutOrder = 1
PaddingTop.Parent = ContentFrame

-- 📥 แถวที่ 1: ตั้งค่าดีเลย์ลูปหลัก
local MainDelayRow = Instance.new("Frame")
MainDelayRow.Size = UDim2.new(1, -20, 0, 26)
MainDelayRow.BackgroundTransparency = 1
MainDelayRow.LayoutOrder = 2
MainDelayRow.Parent = ContentFrame

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0, 140, 1, 0)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Font = Enum.Font.GothamMedium
DelayLabel.Text = "หน่วงเวลาลูปหลัก (วินาที):"
DelayLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DelayLabel.TextSize = 11
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = MainDelayRow

local DelayInput = Instance.new("TextBox")
DelayInput.Size = UDim2.new(1, -145, 1, 0)
DelayInput.Position = UDim2.new(0, 145, 0, 0)
DelayInput.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
DelayInput.Font = Enum.Font.Gotham
DelayInput.Text = "10"
DelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayInput.TextSize = 11
DelayInput.Parent = MainDelayRow

local DICorner = Instance.new("UICorner")
DICorner.CornerRadius = UDim.new(0, 4)
DICorner.Parent = DelayInput

-- 📥 แถวที่ 2: ตั้งค่าดีเลย์ลูปคลิกแยก
local CustomClickRow = Instance.new("Frame")
CustomClickRow.Size = UDim2.new(1, -20, 0, 26)
CustomClickRow.BackgroundTransparency = 1
CustomClickRow.LayoutOrder = 3
CustomClickRow.Parent = ContentFrame

local ClickDelayLabel = Instance.new("TextLabel")
ClickDelayLabel.Size = UDim2.new(0, 140, 1, 0)
ClickDelayLabel.BackgroundTransparency = 1
ClickDelayLabel.Font = Enum.Font.GothamMedium
ClickDelayLabel.Text = "หน่วงเวลาคลิกแยก (วินาที):"
ClickDelayLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ClickDelayLabel.TextSize = 11
ClickDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
ClickDelayLabel.Parent = CustomClickRow

local ClickDelayInput = Instance.new("TextBox")
ClickDelayInput.Size = UDim2.new(1, -145, 1, 0)
ClickDelayInput.Position = UDim2.new(0, 145, 0, 0)
ClickDelayInput.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
ClickDelayInput.Font = Enum.Font.Gotham
ClickDelayInput.Text = "1"
ClickDelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickDelayInput.TextSize = 11
ClickDelayInput.Parent = CustomClickRow

local CDICorner = Instance.new("UICorner")
CDICorner.CornerRadius = UDim.new(0, 4)
CDICorner.Parent = ClickDelayInput

-- 📥 แถวที่ 3: Checkbox 1 (คลิกในลูปหลัก)
local CBMainRow = Instance.new("Frame")
CBMainRow.Size = UDim2.new(1, -20, 0, 20)
CBMainRow.BackgroundTransparency = 1
CBMainRow.LayoutOrder = 4
CBMainRow.Parent = ContentFrame

local CBBtn1 = Instance.new("TextButton")
CBBtn1.Size = UDim2.new(0, 15, 0, 15)
CBBtn1.Position = UDim2.new(0, 0, 0, 2)
CBBtn1.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
CBBtn1.Text = "✓"
CBBtn1.Font = Enum.Font.GothamBold
CBBtn1.TextColor3 = Color3.fromRGB(0, 255, 170)
CBBtn1.TextSize = 11
CBBtn1.Parent = CBMainRow

local CBCorner1 = Instance.new("UICorner")
CBCorner1.CornerRadius = UDim.new(0, 3)
CBCorner1.Parent = CBBtn1

local CBLabel1 = Instance.new("TextLabel")
CBLabel1.Size = UDim2.new(1, -25, 1, 0)
CBLabel1.Position = UDim2.new(0, 22, 0, 0)
CBLabel1.BackgroundTransparency = 1
CBLabel1.Font = Enum.Font.GothamMedium
CBLabel1.Text = "คลิกโจมตีพร้อมลูปหลักทุกครั้ง"
CBLabel1.TextColor3 = Color3.fromRGB(160, 160, 170)
CBLabel1.TextSize = 10
CBLabel1.TextXAlignment = Enum.TextXAlignment.Left
CBLabel1.Parent = CBMainRow

-- 📥 แถวที่ 4: Checkbox 2 (เปิดลูปคลิกแยกอิสระ)
local CBCustomRow = Instance.new("Frame")
CBCustomRow.Size = UDim2.new(1, -20, 0, 20)
CBCustomRow.BackgroundTransparency = 1
CBCustomRow.LayoutOrder = 5
CBCustomRow.Parent = ContentFrame

local CBBtn2 = Instance.new("TextButton")
CBBtn2.Size = UDim2.new(0, 15, 0, 15)
CBBtn2.Position = UDim2.new(0, 0, 0, 2)
CBBtn2.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
CBBtn2.Text = ""
CBBtn2.Font = Enum.Font.GothamBold
CBBtn2.TextColor3 = Color3.fromRGB(0, 255, 170)
CBBtn2.TextSize = 11
CBBtn2.Parent = CBCustomRow

local CBCorner2 = Instance.new("UICorner")
CBCorner2.CornerRadius = UDim.new(0, 3)
CBCorner2.Parent = CBBtn2

local CBLabel2 = Instance.new("TextLabel")
CBLabel2.Size = UDim2.new(1, -25, 1, 0)
CBLabel2.Position = UDim2.new(0, 22, 0, 0)
CBLabel2.BackgroundTransparency = 1
CBLabel2.Font = Enum.Font.GothamMedium
CBLabel2.Text = "เปิดใช้ระบบลูปคลิกแยกทำงานอิสระ"
CBLabel2.TextColor3 = Color3.fromRGB(160, 160, 170)
CBLabel2.TextSize = 10
CBLabel2.TextXAlignment = Enum.TextXAlignment.Left
CBLabel2.Parent = CBCustomRow

-- 📥 แถวที่ 5: ปุ่มเริ่ม/หยุดหลัก (Action Button)
local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, -20, 0, 28)
ActionBtn.BackgroundColor3 = Color3.fromRGB(230, 70, 70)
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.Text = "STOP LOOT"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.TextSize = 11
ActionBtn.LayoutOrder = 6
ActionBtn.Parent = ContentFrame

local ABCorner = Instance.new("UICorner")
ABCorner.CornerRadius = UDim.new(0, 6)
ABCorner.Parent = ActionBtn

-- 📥 แถวที่ 6: กล่องแสดงสถานะ Log UI
local LogFrame = Instance.new("Frame")
LogFrame.Size = UDim2.new(1, -20, 0, 65)
LogFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
LogFrame.BorderSizePixel = 0
LogFrame.LayoutOrder = 7
LogFrame.Parent = ContentFrame

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 6)
LogCorner.Parent = LogFrame

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -12, 1, -12)
LogText.Position = UDim2.new(0, 6, 0, 6)
LogText.BackgroundTransparency = 1
LogText.Font = Enum.Font.Code
LogText.Text = "ระบบ: รีเซ็ตและย่อขนาดหน้าต่างสำเร็จ..."
LogText.TextColor3 = Color3.fromRGB(0, 255, 170)
LogText.TextSize = 10
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.Parent = LogFrame

-- =========================================================
-- ⚡ [LOGIC SYSTEMS] ระบบประมวลผลการทำงานด้านหลัง
-- =========================================================
local isRunning = true 
local isMainClickEnabled = true    -- ควบคุม Checkbox 1
local isCustomClickEnabled = false -- ควบคุม Checkbox 2

local mainLoopTask = nil
local customClickTask = nil

local function updateUIStatus(message, isError)
    if isError then
        LogText.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        LogText.TextColor3 = Color3.fromRGB(0, 255, 170)
    end
    LogText.Text = "🕒 " .. os.date("%X") .. "\n" .. message
end

-- ฟังก์ชันจำลองการคลิกแบบกดแล้วปล่อยทันที
local function virtualClick()
    local camera = workspace.CurrentCamera
    if camera then
        local screenSize = camera.ViewportSize
        local centerX = screenSize.X / 2
        local centerY = screenSize.Y / 2
        
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)  
        task.wait(0.05)                                                               
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0) 
    end
end

-- ฟังก์ชันลูปหลักเก็บไอเทม
local function executeLooting()
    local currentLootFolder = workspace:FindFirstChild("Loot")
    if not currentLootFolder or not remoteFunction then
        updateUIStatus("❌ ระบบกำลังรอโหลดโฟลเดอร์ Loot...", true)
        return
    end

    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local allItems = currentLootFolder:GetChildren()
        local firstItem = allItems[1]
        
        if firstItem then
            -- 🔥 เงื่อนไข Checkbox 1: คลิกโจมตีก่อนดึง Remote เฉพาะตอนบอทเจอไอเทม
            if isMainClickEnabled then
                virtualClick()
                task.wait(0.1)
            end
            
            local itemID = firstItem.Name
            local args = {"requestCollect", itemID}
            
            local success, result = pcall(function()
                return remoteFunction:InvokeServer(unpack(args))
            end)
            
            if success then
                updateUIStatus("⚡ [ลูปหลัก] สำเร็จ: ดักเก็บของรอบนี้แล้ว!\nID: " .. string.sub(itemID, 1, 12) .. "...")
            else
                updateUIStatus("❌ ผิดพลาด: Server ปฏิเสธการส่งข้อมูล", true)
            end
        else
            updateUIStatus("⏳ [ลูปหลัก] สถานะ: ไม่พบของบนพื้น\nกำลังตรวจจับพิกัดเรื่อยๆ...")
        end
    end
end

-- ลูปการทำงานหลัก (ควบคุมดักเก็บไอเทม)
local function startMainLoop()
    while isRunning do
        executeLooting()
        local delayVal = tonumber(DelayInput.Text) or 10
        task.wait(delayVal)
    end
end

-- 🔥 ลูปการทำงานแยกอิสระ (ลูปคลิกอย่างเดียวตามใจสั่ง)
local function startCustomClickLoop()
    while isRunning and isCustomClickEnabled do
        virtualClick()
        local clickDelay = tonumber(ClickDelayInput.Text) or 1
        task.wait(clickDelay)
    end
end

-- สั่งเริ่มการทำงานลูปหลักทันทีเมื่อเปิดเกม
mainLoopTask = task.spawn(startMainLoop)

-- Event: ปุ่มสลับเปิด/ปิดระบบ (Action Button)
ActionBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ActionBtn.BackgroundColor3 = Color3.fromRGB(230, 70, 70)
        ActionBtn.Text = "STOP LOOT"
        updateUIStatus("▶️ เปิดระบบ: บอทเริ่มต้นใหม่อีกครั้ง")
        mainLoopTask = task.spawn(startMainLoop)
        if isCustomClickEnabled then
            customClickTask = task.spawn(startCustomClickLoop)
        end
    else
        ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
        ActionBtn.Text = "START LOOT"
        updateUIStatus("⏹️ หยุดระบบ: ปิดลูปการทำงานทั้งหมดแล้ว")
        if mainLoopTask then mainLoopTask = nil end
        if customClickTask then customClickTask = nil end
    end
end)

-- Event: Checkbox 1 (เปิด/ปิดการคลิกในลูปหลัก)
CBBtn1.MouseButton1Click:Connect(function()
    isMainClickEnabled = not isMainClickEnabled
    CBBtn1.Text = isMainClickEnabled and "✓" or ""
end)

-- Event: Checkbox 2 (เปิด/ปิดระบบลูปคลิกแยกอิสระ)
CBBtn2.MouseButton1Click:Connect(function()
    isCustomClickEnabled = not isCustomClickEnabled
    CBBtn2.Text = isCustomClickEnabled and "✓" or ""
    
    -- จัดการ Thread ลูปคลิกแยก
    if isCustomClickEnabled and isRunning then
        if not customClickTask then
            customClickTask = task.spawn(startCustomClickLoop)
        end
    else
        if customClickTask then
            customClickTask = nil
        end
    end
end)

-- Event: ย่อหน้าต่าง UI (Minimize)
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentFrame.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 280, 0, 30), "Out", "Quad", 0.2, true)
        MinBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 280, 0, 250), "Out", "Quad", 0.2, true, function()
            ContentFrame.Visible = true
        end)
        MinBtn.Text = "-"
    end
end)

-- Event: ปิดสคริปต์ (Close)
CloseBtn.MouseButton1Click:Connect(function()
    isRunning = false
    if mainLoopTask then mainLoopTask = nil end
    if customClickTask then customClickTask = nil end
    ScreenGui:Destroy()
end)
