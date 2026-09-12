local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Remote สำหรับ Auto Click
local clickRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("acecateer_knit@1.7.2"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("StrengthService"):WaitForChild("RE"):WaitForChild("ClickRequested")

-- ==========================================
-- 0. ตัวแปรสถานะ Anti-AFK & Anti-GamePause
-- ==========================================
local antiAfkActive = true
local antiPauseActive = true

local afkConnection = LocalPlayer.Idled:Connect(function()
    if antiAfkActive then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end
end)

pcall(function()
    if getgenv then getgenv().DisabledFocusPause = true end
end)

-- ==========================================
-- 1. ฟังก์ชันวาร์ปกลับ Spawn
-- ==========================================
local function teleportToSpawn()
    local success, err = pcall(function()
        local teleportRemote = ReplicatedStorage:FindFirstChild("TeleportToSpawn", true)
        if teleportRemote and teleportRemote:IsA("RemoteFunction") then
            teleportRemote:InvokeServer()
        else
            for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                if v.Name == "TeleportToSpawn" and (v:IsA("RemoteFunction") or v:IsA("RemoteEvent")) then
                    if v:IsA("RemoteFunction") then v:InvokeServer()
                    elseif v:IsA("RemoteEvent") then v:FireServer() end
                    break
                end
            end
        end
    end)
    return success
end

-- ==========================================
-- 2. ฟังก์ชันเช็คกระเป๋าเต็ม
-- ==========================================
local function isBackpackFull()
    local mainScreen = LocalPlayer.PlayerGui:FindFirstChild("MainScreenGui")
    local backpackValue = mainScreen and mainScreen:FindFirstChild("Currencies", true) and mainScreen.Currencies:FindFirstChild("Backpack", true) and mainScreen.Currencies.Backpack:FindFirstChild("Value")
    
    if backpackValue and backpackValue:IsA("TextLabel") then
        local currentText = backpackValue.Text
        local current, max = currentText:match("(%d+)%s*/%s*(%d+)")
        if current and max then
            if tonumber(current) >= tonumber(max) then return true, currentText end
            return false, currentText
        end
    end
    return false, "N/A"
end

-- ==========================================
-- 3. สร้าง UI ขนาดกะทัดรัด (Compact UI)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CompactCollectorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = (CoreGui:FindFirstChild("CoreGui") and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 310) -- ย่อขนาดให้เล็กลง ไม่บังจอ
mainFrame.Position = UDim2.new(0.02, 0, 0.15, 0) -- ไว้มุมซ้ายเพื่อไม่เกะกะตรงกลาง
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 6)

-- Header
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 24)
headerFrame.BackgroundTransparency = 1
headerFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.Text = "🤖 Auto Collector (Compact)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 11
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = headerFrame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 20, 0, 20)
minimizeBtn.Position = UDim2.new(1, -45, 0, 2)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 14
minimizeBtn.Parent = headerFrame
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 3)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -22, 0, 2)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 11
closeBtn.Parent = headerFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 3)

-- Container หลัก
local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -24)
container.Position = UDim2.new(0, 0, 0, 24)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Floating Icon ตอนพับจอ
local floatingIcon = Instance.new("TextButton")
floatingIcon.Size = UDim2.new(0, 38, 0, 38)
floatingIcon.Position = UDim2.new(0.02, 0, 0.15, 0)
floatingIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
floatingIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
floatingIcon.Text = "🤖"
floatingIcon.TextSize = 18
floatingIcon.Visible = false
floatingIcon.Active = true
floatingIcon.Draggable = true
floatingIcon.Parent = screenGui
Instance.new("UICorner", floatingIcon).CornerRadius = UDim.new(1, 0)
local floatingStroke = Instance.new("UIStroke")
floatingStroke.Color = Color3.fromRGB(80, 80, 80)
floatingStroke.Thickness = 2
floatingStroke.Parent = floatingIcon

local selectedWorldName = "W5"
local selectedZoneName = ""
local autoLoopActive = false
local autoClickActive = false

-- World & Zone Dropdown (แถวเดียวกัน แบบย่อ)
local worldDropdownBtn = Instance.new("TextButton")
worldDropdownBtn.Size = UDim2.new(0.46, 0, 0, 24)
worldDropdownBtn.Position = UDim2.new(0.04, 0, 0.02, 0)
worldDropdownBtn.Text = "W5 ▼"
worldDropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
worldDropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
worldDropdownBtn.Font = Enum.Font.SourceSansBold
worldDropdownBtn.TextSize = 11
worldDropdownBtn.Parent = container
Instance.new("UICorner", worldDropdownBtn).CornerRadius = UDim.new(0, 3)

local worldScroll = Instance.new("ScrollingFrame")
worldScroll.Size = UDim2.new(0.46, 0, 0, 90)
worldScroll.Position = UDim2.new(0.04, 0, 0.09, 0)
worldScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
worldScroll.Visible = false
worldScroll.ZIndex = 10
worldScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
worldScroll.Parent = container
Instance.new("UIListLayout", worldScroll)

local zoneDropdownBtn = Instance.new("TextButton")
zoneDropdownBtn.Size = UDim2.new(0.46, 0, 0, 24)
zoneDropdownBtn.Position = UDim2.new(0.52, 0, 0.02, 0)
zoneDropdownBtn.Text = "เลือก Zone ▼"
zoneDropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
zoneDropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
zoneDropdownBtn.Font = Enum.Font.SourceSansBold
zoneDropdownBtn.TextSize = 11
zoneDropdownBtn.Parent = container
Instance.new("UICorner", zoneDropdownBtn).CornerRadius = UDim.new(0, 3)

local zoneScroll = Instance.new("ScrollingFrame")
zoneScroll.Size = UDim2.new(0.46, 0, 0, 90)
zoneScroll.Position = UDim2.new(0.52, 0, 0.09, 0)
zoneScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
zoneScroll.Visible = false
zoneScroll.ZIndex = 10
zoneScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
zoneScroll.Parent = container
Instance.new("UIListLayout", zoneScroll)

-- Delay Settings (บรรทัดเดียวรวมกัน)
local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(0.55, 0, 0, 18)
delayLabel.Position = UDim2.new(0.04, 0, 0.30, 0)
delayLabel.Text = "หน่วงฟาร์ม/วาร์ป (วิ):"
delayLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
delayLabel.TextSize = 10
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.BackgroundTransparency = 1
delayLabel.Parent = container

local loopDelayBox = Instance.new("TextBox")
loopDelayBox.Size = UDim2.new(0.18, 0, 0, 18)
loopDelayBox.Position = UDim2.new(0.58, 0, 0.30, 0)
loopDelayBox.Text = "0.5"
loopDelayBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
loopDelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
loopDelayBox.Font = Enum.Font.SourceSans
loopDelayBox.TextSize = 10
loopDelayBox.Parent = container
Instance.new("UICorner", loopDelayBox).CornerRadius = UDim.new(0, 3)

local returnDelayBox = Instance.new("TextBox")
returnDelayBox.Size = UDim2.new(0.18, 0, 0, 18)
returnDelayBox.Position = UDim2.new(0.78, 0, 0.30, 0)
returnDelayBox.Text = "3"
returnDelayBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
returnDelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
returnDelayBox.Font = Enum.Font.SourceSans
returnDelayBox.TextSize = 10
returnDelayBox.Parent = container
Instance.new("UICorner", returnDelayBox).CornerRadius = UDim.new(0, 3)

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.92, 0, 0, 20)
statusLabel.Position = UDim2.new(0.04, 0, 0.40, 0)
statusLabel.Text = "สถานะ: พร้อมทำงาน"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 10
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = container

-- Toggle Auto Loop Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.92, 0, 0, 26)
toggleBtn.Position = UDim2.new(0.04, 0, 0.48, 0)
toggleBtn.Text = "▶️ Auto Loop"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 11
toggleBtn.Parent = container
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)

-- Auto Click Setting & Button
local clickDelayBox = Instance.new("TextBox")
clickDelayBox.Size = UDim2.new(0.18, 0, 0, 18)
clickDelayBox.Position = UDim2.new(0.78, 0, 0.60, 0)
clickDelayBox.Text = "0.1"
clickDelayBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
clickDelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
clickDelayBox.Font = Enum.Font.SourceSans
clickDelayBox.TextSize = 10
clickDelayBox.Parent = container
Instance.new("UICorner", clickDelayBox).CornerRadius = UDim.new(0, 3)

local clickDelayLabel = Instance.new("TextLabel")
clickDelayLabel.Size = UDim2.new(0.55, 0, 0, 18)
clickDelayLabel.Position = UDim2.new(0.04, 0, 0.60, 0)
clickDelayLabel.Text = "หน่วงคลิก (วิ):"
clickDelayLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
clickDelayLabel.TextSize = 10
clickDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
clickDelayLabel.BackgroundTransparency = 1
clickDelayLabel.Parent = container

local toggleClickBtn = Instance.new("TextButton")
toggleClickBtn.Size = UDim2.new(0.92, 0, 0, 26)
toggleClickBtn.Position = UDim2.new(0.04, 0, 0.68, 0)
toggleClickBtn.Text = "⚡ Auto Click (Strength)"
toggleClickBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 180)
toggleClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleClickBtn.Font = Enum.Font.SourceSansBold
toggleClickBtn.TextSize = 11
toggleClickBtn.Parent = container
Instance.new("UICorner", toggleClickBtn).CornerRadius = UDim.new(0, 4)

-- Anti-AFK & Anti-GamePause Toggles (จัดคู่กันซ้าย-ขวา)
local toggleAfkBtn = Instance.new("TextButton")
toggleAfkBtn.Size = UDim2.new(0.45, 0, 0, 26)
toggleAfkBtn.Position = UDim2.new(0.04, 0, 0.81, 0)
toggleAfkBtn.Text = "🛡️ AFK: เปิด"
toggleAfkBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
toggleAfkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleAfkBtn.Font = Enum.Font.SourceSansBold
toggleAfkBtn.TextSize = 10
toggleAfkBtn.Parent = container
Instance.new("UICorner", toggleAfkBtn).CornerRadius = UDim.new(0, 4)

local togglePauseBtn = Instance.new("TextButton")
togglePauseBtn.Size = UDim2.new(0.45, 0, 0, 26)
togglePauseBtn.Position = UDim2.new(0.51, 0, 0.81, 0)
togglePauseBtn.Text = "⏸️ Pause: เปิด"
togglePauseBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
togglePauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
togglePauseBtn.Font = Enum.Font.SourceSansBold
togglePauseBtn.TextSize = 10
togglePauseBtn.Parent = container
Instance.new("UICorner", togglePauseBtn).CornerRadius = UDim.new(0, 4)

-- ==========================================
-- 4. ระบบ Dropdown Logic
-- ==========================================
local function refreshZoneList()
    for _, child in pairs(zoneScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local zonesFolder = workspace:FindFirstChild("Zones")
    local worldFolder = zonesFolder and zonesFolder:FindFirstChild(selectedWorldName)
    if not worldFolder then return end
    local zones = {}
    for _, zone in pairs(worldFolder:GetChildren()) do table.insert(zones, zone.Name) end
    table.sort(zones)
    for _, zoneName in ipairs(zones) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 22)
        btn.Text = zoneName
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 11
        btn.ZIndex = 11
        btn.Parent = zoneScroll
        btn.MouseButton1Click:Connect(function()
            selectedZoneName = zoneName
            zoneDropdownBtn.Text = zoneName .. " ▼"
            zoneScroll.Visible = false
        end)
    end
    zoneScroll.CanvasSize = UDim2.new(0, 0, 0, #zones * 22)
end

local function refreshWorldList()
    for _, child in pairs(worldScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local zonesFolder = workspace:FindFirstChild("Zones")
    if not zonesFolder then return end
    local worlds = {}
    for _, w in pairs(zonesFolder:GetChildren()) do table.insert(worlds, w.Name) end
    table.sort(worlds)
    for _, worldName in ipairs(worlds) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 22)
        btn.Text = worldName
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 11
        btn.ZIndex = 11
        btn.Parent = worldScroll
        btn.MouseButton1Click:Connect(function()
            selectedWorldName = worldName
            worldDropdownBtn.Text = worldName .. " ▼"
            worldScroll.Visible = false
            selectedZoneName = ""
            zoneDropdownBtn.Text = "เลือก Zone ▼"
            refreshZoneList()
        end)
    end
    worldScroll.CanvasSize = UDim2.new(0, 0, 0, #worlds * 22)
end

worldDropdownBtn.MouseButton1Click:Connect(function()
    refreshWorldList()
    worldScroll.Visible = not worldScroll.Visible
    zoneScroll.Visible = false
end)

zoneDropdownBtn.MouseButton1Click:Connect(function()
    refreshZoneList()
    zoneScroll.Visible = not zoneScroll.Visible
    worldScroll.Visible = false
end)

-- ==========================================
-- 5. ฟังก์ชันการทำงานหลัก
-- ==========================================
local function processSingleCollect()
    local isFull, capacityText = isBackpackFull()
    if isFull then
        local returnWait = tonumber(returnDelayBox.Text) or 3
        statusLabel.Text = "🛑 กระเป๋าเต็ม! วาร์ปกลับ..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        teleportToSpawn()
        task.wait(returnWait)
        return false
    end

    if selectedZoneName == "" then
        statusLabel.Text = "⚠️ ยังไม่ได้เลือก Zone"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return false
    end

    local targetZone = workspace.Zones[selectedWorldName]:FindFirstChild(selectedZoneName)
    local spawnZone = targetZone and targetZone:FindFirstChild("SpawnZone")
    if not spawnZone then return false end

    local items = spawnZone:GetChildren()
    if #items == 0 then return false end

    local targetItem = items[1]
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if hrp then
        local itemCFrame = targetItem:IsA("Model") and (targetItem.PrimaryPart and targetItem.PrimaryPart.CFrame or targetItem:GetPivot())
            or (targetItem:IsA("BasePart") and targetItem.CFrame)
            or (targetItem:FindFirstChildWhichIsA("BasePart", true) and targetItem:FindFirstChildWhichIsA("BasePart", true).CFrame)
        if itemCFrame then hrp.CFrame = itemCFrame end
    end

    task.wait(0.15)
    local prompt = targetItem:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and typeof(fireproximityprompt) == "function" then
        fireproximityprompt(prompt)
    end
    statusLabel.Text = "✅ เก็บ: " .. targetItem.Name
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    return true
end

-- ==========================================
-- 6. Events ปุ่มควบคุมต่างๆ
-- ==========================================
toggleBtn.MouseButton1Click:Connect(function()
    autoLoopActive = not autoLoopActive
    if autoLoopActive then
        toggleBtn.Text = "⏹️ หยุด Auto Loop"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        task.spawn(function()
            while autoLoopActive do
                processSingleCollect()
                task.wait(tonumber(loopDelayBox.Text) or 0.5)
            end
        end)
    else
        toggleBtn.Text = "▶️ Auto Loop"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        statusLabel.Text = "⏸️ หยุดทำงาน"
    end
end)

toggleClickBtn.MouseButton1Click:Connect(function()
    autoClickActive = not autoClickActive
    if autoClickActive then
        toggleClickBtn.Text = "⏹️ หยุด Auto Click"
        toggleClickBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        task.spawn(function()
            while autoClickActive do
                pcall(function() clickRemote:FireServer() end)
                task.wait(tonumber(clickDelayBox.Text) or 0.1)
            end
        end)
    else
        toggleClickBtn.Text = "⚡ Auto Click (Strength)"
        toggleClickBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 180)
    end
end)

toggleAfkBtn.MouseButton1Click:Connect(function()
    antiAfkActive = not antiAfkActive
    toggleAfkBtn.Text = antiAfkActive and "🛡️ AFK: เปิด" or "🛡️ AFK: ปิด"
    toggleAfkBtn.BackgroundColor3 = antiAfkActive and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(180, 50, 50)
end)

togglePauseBtn.MouseButton1Click:Connect(function()
    antiPauseActive = not antiPauseActive
    togglePauseBtn.Text = antiPauseActive and "⏸️ Pause: เปิด" or "⏸️ Pause: ปิด"
    togglePauseBtn.BackgroundColor3 = antiPauseActive and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(180, 50, 50)
    pcall(function() if getgenv then getgenv().DisabledFocusPause = antiPauseActive end end)
end)

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    floatingIcon.Visible = true
end)

floatingIcon.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    floatingIcon.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    autoLoopActive = false
    autoClickActive = false
    if afkConnection then afkConnection:Disconnect() end
    screenGui:Destroy()
end)
