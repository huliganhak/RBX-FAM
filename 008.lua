local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local lp = Players.LocalPlayer

-- ลบ UI เก่าทิ้งก่อนหากเคยรันไปแล้ว
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
-- 🎨 [SUPER-COMPACT DESIGN UI] เล็กพิเศษ ไม่ล้นกรอบ ไม่บังจอเกม
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaX_UltimateLootUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- หน้าต่างหลัก (บีบความสูงลงเหลือ 210 เพื่อลดขนาดโดยรวม)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 210)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- แถบหัวเรื่องด้านบน (Top Bar สูง 25)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 25)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -55, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "💎 LOOT CONTROLLER"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.TextSize = 10
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- ปุ่มย่อหน้าต่าง (Minimize)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 16, 0, 16)
MinBtn.Position = UDim2.new(1, -38, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize = 11
MinBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 3)
MinCorner.Parent = MinBtn

-- ปุ่มปิดหน้าต่าง (Close)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 16, 0, 16)
CloseBtn.Position = UDim2.new(1, -18, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 9
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 3)
CloseCorner.Parent = CloseBtn

-- เส้นแบ่งโซน (Divider)
local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -16, 0, 1)
Line.Position = UDim2.new(0, 8, 0, 25)
Line.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- โซนเนื้อหา (Content)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -25)
ContentFrame.Position = UDim2.new(0, 0, 0, 25)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- UI Layout จัดระเบียบกระชับแนวตั้งเป็นระเบียบ
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4) -- ลดช่องว่างระหว่างบรรทัดป้องกัน UI ตกขอบ
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local PaddingTop = Instance.new("Frame")
PaddingTop.Size = UDim2.new(1, 0, 0, 2)
PaddingTop.BackgroundTransparency = 1
PaddingTop.LayoutOrder = 1
PaddingTop.Parent = ContentFrame

-- 📥 แถวที่ 1: ดีเลย์ลูปหลัก (ความสูงลดเหลือ 20)
local MainDelayRow = Instance.new("Frame")
MainDelayRow.Size = UDim2.new(1, -16, 0, 20)
MainDelayRow.BackgroundTransparency = 1
MainDelayRow.LayoutOrder = 2
MainDelayRow.Parent = ContentFrame

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0, 130, 1, 0)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Font = Enum.Font.GothamMedium
DelayLabel.Text = "หน่วงเวลาลูปหลัก (วิ):"
DelayLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
DelayLabel.TextSize = 9
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = MainDelayRow

local DelayInput = Instance.new("TextBox")
DelayInput.Size = UDim2.new(1, -135, 1, 0)
DelayInput.Position = UDim2.new(0, 135, 0, 0)
DelayInput.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
DelayInput.Font = Enum.Font.Gotham
DelayInput.Text = "10"
DelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayInput.TextSize = 10
DelayInput.Parent = MainDelayRow

local DICorner = Instance.new("UICorner")
DICorner.CornerRadius = UDim.new(0, 3)
DICorner.Parent = DelayInput

-- 📥 แถวที่ 2: ดีเลย์ลูปคลิกแยก (ความสูงลดเหลือ 20)
local CustomClickRow = Instance.new("Frame")
CustomClickRow.Size = UDim2.new(1, -16, 0, 20)
CustomClickRow.BackgroundTransparency = 1
CustomClickRow.LayoutOrder = 3
CustomClickRow.Parent = ContentFrame

local ClickDelayLabel = Instance.new("TextLabel")
ClickDelayLabel.Size = UDim2.new(0, 130, 1, 0)
ClickDelayLabel.BackgroundTransparency = 1
ClickDelayLabel.Font = Enum.Font.GothamMedium
ClickDelayLabel.Text = "หน่วงเวลาคลิกแยก (วิ):"
ClickDelayLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
ClickDelayLabel.TextSize = 9
ClickDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
ClickDelayLabel.Parent = CustomClickRow

local ClickDelayInput = Instance.new("TextBox")
ClickDelayInput.Size = UDim2.new(1, -135, 1, 0)
ClickDelayInput.Position = UDim2.new(0, 135, 0, 0)
ClickDelayInput.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
ClickDelayInput.Font = Enum.Font.Gotham
ClickDelayInput.Text = "3"  -- ปรับค่าเริ่มต้นตามรูปภาพผู้ใช้
ClickDelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickDelayInput.TextSize = 10
ClickDelayInput.Parent = CustomClickRow

local CDICorner = Instance.new("UICorner")
CDICorner.CornerRadius = UDim.new(0, 3)
CDICorner.Parent = ClickDelayInput

-- 📥 แถวที่ 3: Checkbox 1 (ลดขนาด)
local CBMainRow = Instance.new("Frame")
CBMainRow.Size = UDim2.new(1, -16, 0, 16)
CBMainRow.BackgroundTransparency = 1
CBMainRow.LayoutOrder = 4
CBMainRow.Parent = ContentFrame

local CBBtn1 = Instance.new("TextButton")
CBBtn1.Size = UDim2.new(0, 13, 0, 13)
CBBtn1.Position = UDim2.new(0, 0, 0, 1)
CBBtn1.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
CBBtn1.Text = "✓"  -- เริ่มต้นเปิดใช้งาน
CBBtn1.Font = Enum.Font.GothamBold
CBBtn1.TextColor3 = Color3.fromRGB(0, 255, 170)
CBBtn1.TextSize = 9
CBBtn1.Parent = CBMainRow

local CBCorner1 = Instance.new("UICorner")
CBCorner1.CornerRadius = UDim.new(0, 2)
CBCorner1.Parent = CBBtn1

local CBLabel1 = Instance.new("TextLabel")
CBLabel1.Size = UDim2.new(1, -20, 1, 0)
CBLabel1.Position = UDim2.new(0, 18, 0, 0)
CBLabel1.BackgroundTransparency = 1
CBLabel1.Font = Enum.Font.GothamMedium
CBLabel1.Text = "คลิกโจมตีพร้อมลูปหลักทุกครั้ง"
CBLabel1.TextColor3 = Color3.fromRGB(150, 150, 160)
CBLabel1.TextSize = 9
CBLabel1.TextXAlignment = Enum.TextXAlignment.Left
CBLabel1.Parent = CBMainRow

-- 📥 แถวที่ 4: Checkbox 2 (ลดขนาด)
local CBCustomRow = Instance.new("Frame")
CBCustomRow.Size = UDim2.new(1, -16, 0, 16)
CBCustomRow.BackgroundTransparency = 1
CBCustomRow.LayoutOrder = 5
CBCustomRow.Parent = ContentFrame

local CBBtn2 = Instance.new("TextButton")
CBBtn2.Size = UDim2.new(0, 13, 0, 13)
CBBtn2.Position = UDim2.new(0, 0, 0, 1)
CBBtn2.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
CBBtn2.Text = "✓"  -- แก้ไขให้เริ่มต้นเปิดใช้งาน (ตามรูปภาพ)
CBBtn2.Font = Enum.Font.GothamBold
CBBtn2.TextColor3 = Color3.fromRGB(0, 255, 170)
CBBtn2.TextSize = 9
CBBtn2.Parent = CBCustomRow

local CBCorner2 = Instance.new("UICorner")
CBCorner2.CornerRadius = UDim.new(0, 2)
CBCorner2.Parent = CBBtn2

local CBLabel2 = Instance.new("TextLabel")
CBLabel2.Size = UDim2.new(1, -20, 1, 0)
CBLabel2.Position = UDim2.new(0, 18, 0, 0)
CBLabel2.BackgroundTransparency = 1
CBLabel2.Font = Enum.Font.GothamMedium
CBLabel2.Text = "เปิดใช้ระบบลูปคลิกแยกทำงานอิสระ"
CBLabel2.TextColor3 = Color3.fromRGB(150, 150, 160)
CBLabel2.TextSize = 9
CBLabel2.TextXAlignment = Enum.TextXAlignment.Left
CBLabel2.Parent = CBCustomRow

-- 📥 แถวที่ 5: ปุ่ม Action Button (กระชับความสูงเป็น 22)
local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, -16, 0, 22)
ActionBtn.BackgroundColor3 = Color3.fromRGB(230, 70, 70) -- เริ่มต้นเป็นสีแดง (STOP LOOT) เนื่องจากบอทรันทันที
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.Text = "STOP LOOT"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.TextSize = 10
ActionBtn.LayoutOrder = 6
ActionBtn.Parent = ContentFrame

local ABCorner = Instance.new("UICorner")
ABCorner.CornerRadius = UDim.new(0, 4)
ABCorner.Parent = ActionBtn

-- 📥 แถวที่ 6: กล่องแสดง Log UI (ความสูงเหลือ 55 พอดีกับเฟรมหลัก)
local LogFrame = Instance.new("Frame")
LogFrame.Size = UDim2.new(1, -16, 0, 55)
LogFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
LogFrame.BorderSizePixel = 0
LogFrame.LayoutOrder = 7
LogFrame.Parent = ContentFrame

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 4)
LogCorner.Parent = LogFrame

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -10, 1, -10)
LogText.Position = UDim2.new(0, 5, 0, 5)
LogText.BackgroundTransparency = 1
LogText.Font = Enum.Font.Code
LogText.Text = "ระบบ: เริ่มต้นทำงานอัตโนมัติ..."
LogText.TextColor3 = Color3.fromRGB(0, 255, 170)
LogText.TextSize = 9
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.Parent = LogFrame

-- =========================================================
-- ⚡ [LOGIC SYSTEMS] ระบบควบคุมประมวลผลหลังบ้าน
-- =========================================================
local isRunning = true             -- เปิดใช้งานทันที
local isMainClickEnabled = true    -- เปิดใช้งานทันที
local isCustomClickEnabled = true  -- เปิดใช้งานทันทีตามรูปภาพ

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
            updateUIStatus("⏳ [ลูปหลัก] สถานะ: ไม่พบของบนพื้น\nกำลังสแกนหาเรื่อยๆ...")
        end
    end
end

local function startMainLoop()
    while isRunning do
        executeLooting()
        local delayVal = tonumber(DelayInput.Text) or 10
        task.wait(delayVal)
    end
end

local function startCustomClickLoop()
    while isRunning and isCustomClickEnabled do
        virtualClick()
        local clickDelay = tonumber(ClickDelayInput.Text) or 3
        task.wait(clickDelay)
    end
end

-- สั่งให้ระบเริ่มทำงาน (Auto-Start) ทันทีที่รันสคริปต์
mainLoopTask = task.spawn(startMainLoop)
customClickTask = task.spawn(startCustomClickLoop)
updateUIStatus("▶️ บอทเริ่มทำงานอัตโนมัติเรียบร้อยแล้ว!")

-- Event Handlers
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

CBBtn1.MouseButton1Click:Connect(function()
    isMainClickEnabled = not isMainClickEnabled
    CBBtn1.Text = isMainClickEnabled and "✓" or ""
end)

CBBtn2.MouseButton1Click:Connect(function()
    isCustomClickEnabled = not isCustomClickEnabled
    CBBtn2.Text = isCustomClickEnabled and "✓" or ""
    
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

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentFrame.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 260, 0, 25), "Out", "Quad", 0.2, true)
        MinBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 260, 0, 210), "Out", "Quad", 0.2, true, function()
            ContentFrame.Visible = true
        end)
        MinBtn.Text = "-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    isRunning = false
    if mainLoopTask then mainLoopTask = nil end
    if customClickTask then customClickTask = nil end
    ScreenGui:Destroy()
end)
