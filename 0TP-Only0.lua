local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer

-- ลบ UI เก่าทิ้งก่อนถ้าเคยรันไว้
if CoreGui:FindFirstChild("DeltaX_TeleportUI") then
    CoreGui["DeltaX_TeleportUI"]:Destroy()
end

-- =========================================================
-- 🎨 [DESIGN UI] โครงสร้างหน้าต่างควบคุม TP
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaX_TeleportUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 185)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, -92)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- แถบหัวเรื่องด้านบน (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 25)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -55, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "🌀 TELEPORT TOOL"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 10
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

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

local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -16, 0, 1)
Line.Position = UDim2.new(0, 8, 0, 25)
Line.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -25)
ContentFrame.Position = UDim2.new(0, 0, 0, 25)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local PaddingTop = Instance.new("Frame")
PaddingTop.Size = UDim2.new(1, 0, 0, 2)
PaddingTop.BackgroundTransparency = 1
PaddingTop.LayoutOrder = 1
PaddingTop.Parent = ContentFrame

-- 📥 ฟังก์ชั่นสร้างแถวสำหรับกรอกค่า (X, Y, Z)
local function createCoordRow(labelText, defaultVal, order)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -16, 0, 22)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder = order
    Row.Parent = ContentFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 60, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, -65, 1, 0)
    Input.Position = UDim2.new(0, 65, 0, 0)
    Input.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Input.Font = Enum.Font.Gotham
    Input.Text = tostring(defaultVal)
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.TextSize = 10
    Input.Parent = Row

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 3)
    Corner.Parent = Input

    return Input
end

local InputX = createCoordRow("พิกัด X:", "0", 2)
local InputY = createCoordRow("พิกัด Y:", "50", 3)
local InputZ = createCoordRow("พิกัด Z:", "0", 4)

-- 📥 ปุ่มดึงพิกัดปัจจุบัน
local GetPosBtn = Instance.new("TextButton")
GetPosBtn.Size = UDim2.new(1, -16, 0, 20)
GetPosBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
GetPosBtn.Font = Enum.Font.GothamMedium
GetPosBtn.Text = "📍 ดึงพิกัดปัจจุบัน"
GetPosBtn.TextColor3 = Color3.fromRGB(180, 220, 255)
GetPosBtn.TextSize = 9
GetPosBtn.LayoutOrder = 5
GetPosBtn.Parent = ContentFrame

local GetPosCorner = Instance.new("UICorner")
GetPosCorner.CornerRadius = UDim.new(0, 4)
GetPosCorner.Parent = GetPosBtn

-- 📥 ปุ่มสั่ง Teleport
local TPBtn = Instance.new("TextButton")
TPBtn.Size = UDim2.new(1, -16, 0, 24)
TPBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TPBtn.Font = Enum.Font.GothamBold
TPBtn.Text = "TELEPORT"
TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBtn.TextSize = 10
TPBtn.LayoutOrder = 6
TPBtn.Parent = ContentFrame

local TPCorner = Instance.new("UICorner")
TPCorner.CornerRadius = UDim.new(0, 4)
TPCorner.Parent = TPBtn

-- =========================================================
-- ⚡ [LOGIC SYSTEMS] ระบบประมวลผลการ TP
-- =========================================================

-- ปุ่มดึงพิกัดตัวละครปัจจุบัน
GetPosBtn.MouseButton1Click:Connect(function()
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local pos = lp.Character.HumanoidRootPart.Position
        InputX.Text = string.format("%.1f", pos.X)
        InputY.Text = string.format("%.1f", pos.Y)
        InputZ.Text = string.format("%.1f", pos.Z)
    end
end)

-- ปุ่มสั่งวาร์ป
TPBtn.MouseButton1Click:Connect(function()
    local x = tonumber(InputX.Text)
    local y = tonumber(InputY.Text)
    local z = tonumber(InputZ.Text)

    if x and y and z then
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
        end
    end
end)

-- ระบบย่อหน้าต่าง
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentFrame.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 25), "Out", "Quad", 0.2, true)
        MinBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 240, 0, 185), "Out", "Quad", 0.2, true, function()
            ContentFrame.Visible = true
        end)
        MinBtn.Text = "-"
    end
end)

-- ปุ่มปิดหน้าต่าง
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
