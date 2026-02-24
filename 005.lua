--// ShurikenMerge Open/Close UI
--// Open flow  : ExpandOut -> ZoomL
--// Close flow : ZoomS -> ExpandIn
--// + Auto Collect Coin ON/OFF

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--========================
-- Global toggle
--========================
getgenv().AutoCollectCoin = false
local autoCollectThreadRunning = false

--========================
-- Click function
--========================
local function interact_2(path)
    if typeof(path) ~= "Instance" then
        warn("interact_2: path is not an Instance")
        return false
    end

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
local function getMerge()
    local shurikenMerge = playerGui:FindFirstChild("ShurikenMerge")
    if not shurikenMerge then return nil end

    local merge = shurikenMerge:FindFirstChild("Merge")
    if not merge then return nil end

    return merge
end

local function getExpandOut()
    local merge = getMerge()
    if not merge then return nil end
    return merge:FindFirstChild("ExpandOut")
end

local function getExpandIn()
    local merge = getMerge()
    if not merge then return nil end
    return merge:FindFirstChild("ExpandIn")
end

local function getZoomL()
    local merge = getMerge()
    if not merge then return nil end
    return merge:FindFirstChild("ZoomL")
end

local function getZoomS()
    local merge = getMerge()
    if not merge then return nil end
    return merge:FindFirstChild("ZoomS")
end

--========================
-- Helper: click safely
--========================
local function clickIfVisible(target, targetName)
    if not target then
        warn(targetName .. " not found")
        return false, targetName .. " not found"
    end

    if not target:IsA("GuiObject") then
        warn(targetName .. " is not GuiObject")
        return false, targetName .. " is not GuiObject"
    end

    if not target.Visible then
        warn(targetName .. " Visible = false")
        return false, targetName .. " Visible = false"
    end

    local ok = interact_2(target)
    if ok then
        return true, targetName .. " clicked"
    end

    return false, targetName .. " click failed"
end

--========================
-- Auto Collect Logic
--========================
local function startAutoCollect(statusLabel)
    if autoCollectThreadRunning then
        getgenv().AutoCollectCoin = true
        statusLabel.Text = "Status: Auto Collect already running"
        return
    end

    getgenv().AutoCollectCoin = true
    autoCollectThreadRunning = true
    statusLabel.Text = "Status: Auto Collect ON"

    task.spawn(function()
        while getgenv().AutoCollectCoin do
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp and workspace:FindFirstChild("Coin") then
                for _, v in ipairs(workspace.Coin:GetDescendants()) do
                    if not getgenv().AutoCollectCoin then
                        break
                    end

                    if v:IsA("TouchTransmitter") then
                        local part = v.Parent
                        if part and part:IsA("BasePart") and part:IsDescendantOf(workspace) then
                            pcall(function()
                                firetouchinterest(hrp, part, 0) -- touch
                                task.wait()
                                firetouchinterest(hrp, part, 1) -- untouch
                            end)
                        end
                    end
                end
            end

            task.wait(0.2)
        end

        autoCollectThreadRunning = false
        if statusLabel and statusLabel.Parent then
            statusLabel.Text = "Status: Auto Collect OFF"
        end
    end)
end

local function stopAutoCollect(statusLabel)
    getgenv().AutoCollectCoin = false
    statusLabel.Text = "Status: Stopping Auto Collect..."
end

--========================
-- Create UI
--========================
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
frame.Size = UDim2.new(0, 240, 0, 175) -- สูงขึ้น
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

-- Open / Close row
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenButton"
openBtn.Size = UDim2.new(0, 105, 0, 40)
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
closeBtn.Size = UDim2.new(0, 105, 0, 40)
closeBtn.Position = UDim2.new(0, 125, 0, 40)
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

-- Collect ON / OFF row
local collectOnBtn = Instance.new("TextButton")
collectOnBtn.Name = "CollectOnButton"
collectOnBtn.Size = UDim2.new(0, 105, 0, 34)
collectOnBtn.Position = UDim2.new(0, 10, 0, 88)
collectOnBtn.BackgroundColor3 = Color3.fromRGB(65, 130, 255)
collectOnBtn.BorderSizePixel = 0
collectOnBtn.Text = "Collect ON"
collectOnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
collectOnBtn.TextSize = 14
collectOnBtn.Font = Enum.Font.GothamBold
collectOnBtn.Parent = frame

local collectOnCorner = Instance.new("UICorner")
collectOnCorner.CornerRadius = UDim.new(0, 8)
collectOnCorner.Parent = collectOnBtn

local collectOffBtn = Instance.new("TextButton")
collectOffBtn.Name = "CollectOffButton"
collectOffBtn.Size = UDim2.new(0, 105, 0, 34)
collectOffBtn.Position = UDim2.new(0, 125, 0, 88)
collectOffBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
collectOffBtn.BorderSizePixel = 0
collectOffBtn.Text = "Collect OFF"
collectOffBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
collectOffBtn.TextSize = 14
collectOffBtn.Font = Enum.Font.GothamBold
collectOffBtn.Parent = frame

local collectOffCorner = Instance.new("UICorner")
collectOffCorner.CornerRadius = UDim.new(0, 8)
collectOffCorner.Parent = collectOffBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -10, 0, 26)
statusLabel.Position = UDim2.new(0, 5, 1, -28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

--========================
-- Drag UI
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

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

--========================
-- Button actions (Open/Close)
--========================
openBtn.MouseButton1Click:Connect(function()
    statusLabel.Text = "Status: Opening..."

    local ok1, msg1 = clickIfVisible(getExpandOut(), "ExpandOut")
    if not ok1 then
        statusLabel.Text = "Status: " .. msg1
        return
    end

    task.wait(0.15)

    local ok2, msg2 = clickIfVisible(getZoomL(), "ZoomL")
    if not ok2 then
        statusLabel.Text = "Status: " .. msg2
        return
    end

    statusLabel.Text = "Status: Open flow done"
end)

closeBtn.MouseButton1Click:Connect(function()
    statusLabel.Text = "Status: Closing..."

    local ok1, msg1 = clickIfVisible(getZoomS(), "ZoomS")
    if not ok1 then
        statusLabel.Text = "Status: " .. msg1
        return
    end

    task.wait(0.15)

    local ok2, msg2 = clickIfVisible(getExpandIn(), "ExpandIn")
    if not ok2 then
        statusLabel.Text = "Status: " .. msg2
        return
    end

    statusLabel.Text = "Status: Close flow done"
end)

--========================
-- Button actions (Auto Collect)
--========================
collectOnBtn.MouseButton1Click:Connect(function()
    startAutoCollect(statusLabel)
end)

collectOffBtn.MouseButton1Click:Connect(function()
    stopAutoCollect(statusLabel)
end)
