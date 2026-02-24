--// ShurikenMerge Open/Close UI
--// ใช้กดปุ่ม ExpandOut (Open) / ExpandIn (Close) ด้วย VirtualInputManager

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--========================
-- Click function
--========================
local function interact_2(path)
    if typeof(path) ~= "Instance" then
        warn("interact_2: path is not an Instance")
        return false
    end

    -- เช็คว่าเป็น GuiObject ไหม + เช็ค Visible
    if not path:IsA("GuiObject") then
        warn("interact_2: target is not a GuiObject ->", path:GetFullName())
        return false
    end

    if not path.Visible then
        warn("interact_2: target is not visible ->", path:GetFullName())
        return false
    end

    local centerX = path.AbsolutePosition.X + (path.AbsoluteSize.X / 2)
    local centerY = path.AbsolutePosition.Y + (path.AbsoluteSize.Y / 2) + 63

    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, path, 2)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, path, 2)
    task.wait(0.3)

    return true
end

--========================
-- Helper: get target buttons
--========================
local function getExpandOut()
    local shurikenMerge = playerGui:FindFirstChild("ShurikenMerge")
    if not shurikenMerge then return nil end

    local merge = shurikenMerge:FindFirstChild("Merge")
    if not merge then return nil end

    return merge:FindFirstChild("ExpandOut")
end

local function getExpandIn()
    local shurikenMerge = playerGui:FindFirstChild("ShurikenMerge")
    if not shurikenMerge then return nil end

    local merge = shurikenMerge:FindFirstChild("Merge")
    if not merge then return nil end

    return merge:FindFirstChild("ExpandIn")
end

--========================
-- Create UI
--========================
-- ลบ UI เดิม (ถ้ามี)
local old = CoreGui:FindFirstChild("ShurikenMergeToggleUI")
if old then
    old:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShurikenMergeToggleUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    screenGui.Parent = CoreGui
end)

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 220, 0, 110)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -10, 0, 28)
title.Position = UDim2.new(0, 5, 0, 4)
title.BackgroundTransparency = 1
title.Text = "ShurikenMerge Control"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = frame

local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenButton"
openBtn.Size = UDim2.new(0, 95, 0, 38)
openBtn.Position = UDim2.new(0, 10, 0, 40)
openBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
openBtn.BorderSizePixel = 0
openBtn.Text = "Open"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.TextSize = 16
openBtn.Font = Enum.Font.GothamBold
openBtn.Parent = frame

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 95, 0, 38)
closeBtn.Position = UDim2.new(0, 115, 0, 40)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "Close"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -10, 0, 20)
statusLabel.Position = UDim2.new(0, 5, 1, -24)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

--========================
-- Drag UI (optional)
--========================
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        -- no-op
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

--========================
-- Button actions
--========================
openBtn.MouseButton1Click:Connect(function()
    local target = getExpandOut()
    if not target then
        statusLabel.Text = "Status: ExpandOut not found"
        warn("ExpandOut not found")
        return
    end

    if target.Visible then
        statusLabel.Text = "Status: Open clicked (ExpandOut)"
        interact_2(target)
    else
        statusLabel.Text = "Status: ExpandOut Visible = false"
        warn("ExpandOut Visible = false")
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    local target = getExpandIn()
    if not target then
        statusLabel.Text = "Status: ExpandIn not found"
        warn("ExpandIn not found")
        return
    end

    if target.Visible then
        statusLabel.Text = "Status: Close clicked (ExpandIn)"
        interact_2(target)
    else
        statusLabel.Text = "Status: ExpandIn Visible = false"
        warn("ExpandIn Visible = false")
    end
end)