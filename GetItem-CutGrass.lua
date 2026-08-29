local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. ฟังก์ชันวาร์ปกลับ Spawn
-- ==========================================
local function teleportToSpawn()
    local success, err = pcall(function()
        local packages = ReplicatedStorage:WaitForChild("Packages", 5)
        local index = packages and packages:WaitForChild("_Index", 5)
        local knitPkg = index and index:WaitForChild("acecateer_knit@1.7.2", 5)
        local knit = knitPkg and knitPkg:WaitForChild("knit", 5)
        local services = knit and knit:WaitForChild("Services", 5)
        local teleportService = services and services:WaitForChild("BaseTeleportService", 5)
        local rf = teleportService and teleportService:WaitForChild("RF", 5)
        local teleportRemote = rf and rf:WaitForChild("TeleportToSpawn", 5)

        if teleportRemote and teleportRemote:IsA("RemoteFunction") then
            teleportRemote:InvokeServer()
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
            local currentNum = tonumber(current)
            local maxNum = tonumber(max)
            
            if currentNum and maxNum and currentNum >= maxNum then
                return true, currentText
            end
            return false, currentText
        end
    end
    return false, "N/A"
end

-- ==========================================
-- 3. สร้าง UI หลัก
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoLoopZoneCollectorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 310)
mainFrame.Position = UDim2.new(0.5, -160, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Header
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 30)
headerFrame.BackgroundTransparency = 1
headerFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "🤖 Auto Loop Zone Collector"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 13
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

-- Container
local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -30)
container.Position = UDim2.new(0, 0, 0, 30)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local selectedWorldName = "W5"
local selectedZoneName = ""
local autoLoopActive = false

-- World Dropdown
local worldDropdownBtn = Instance.new("TextButton")
worldDropdownBtn.Size = UDim2.new(0.42, 0, 0, 30)
worldDropdownBtn.Position = UDim2.new(0.05, 0, 0.04, 0)
worldDropdownBtn.Text = "World: W5 ▼"
worldDropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
worldDropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
worldDropdownBtn.Font = Enum.Font.SourceSansBold
worldDropdownBtn.TextSize = 12
worldDropdownBtn.Parent = container
Instance.new("UICorner", worldDropdownBtn).CornerRadius = UDim.new(0, 4)

local worldScroll = Instance.new("ScrollingFrame")
worldScroll.Size = UDim2.new(0.42, 0, 0, 110)
worldScroll.Position = UDim2.new(0.05, 0, 0.16, 0)
worldScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
worldScroll.Visible = false
worldScroll.ZIndex = 10
worldScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
worldScroll.Parent = container
local worldListLayout = Instance.new("UIListLayout", worldScroll)

-- Zone Dropdown
local zoneDropdownBtn = Instance.new("TextButton")
zoneDropdownBtn.Size = UDim2.new(0.45, 0, 0, 30)
zoneDropdownBtn.Position = UDim2.new(0.5, 0, 0.04, 0)
zoneDropdownBtn.Text = "เลือก Zone ▼"
zoneDropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
zoneDropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
zoneDropdownBtn.Font = Enum.Font.SourceSansBold
zoneDropdownBtn.TextSize = 12
zoneDropdownBtn.Parent = container
Instance.new("UICorner", zoneDropdownBtn).CornerRadius = UDim.new(0, 4)

local zoneScroll = Instance.new("ScrollingFrame")
zoneScroll.Size = UDim2.new(0.45, 0, 0, 110)
zoneScroll.Position = UDim2.new(0.5, 0, 0.16, 0)
zoneScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
zoneScroll.Visible = false
zoneScroll.ZIndex = 10
zoneScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
zoneScroll.Parent = container
local zoneListLayout = Instance.new("UIListLayout", zoneScroll)

-- Settings Input: Loop Delay
local loopDelayLabel = Instance.new("TextLabel")
loopDelayLabel.Size = UDim2.new(0.5, 0, 0, 22)
loopDelayLabel.Position = UDim2.new(0.05, 0, 0.18, 0)
loopDelayLabel.Text = "หน่วงซ้ำต่อรอบ (วิ):"
loopDelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
loopDelayLabel.TextSize = 11
loopDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
loopDelayLabel.BackgroundTransparency = 1
loopDelayLabel.Parent = container

local loopDelayBox = Instance.new("TextBox")
loopDelayBox.Size = UDim2.new(0.35, 0, 0, 22)
loopDelayBox.Position = UDim2.new(0.6, 0, 0.18, 0)
loopDelayBox.Text = "0.5"
loopDelayBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
loopDelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
loopDelayBox.Font = Enum.Font.SourceSans
loopDelayBox.TextSize = 11
loopDelayBox.Parent = container
Instance.new("UICorner", loopDelayBox).CornerRadius = UDim.new(0, 4)

-- Settings Input: Return Spawn Delay
local returnDelayLabel = Instance.new("TextLabel")
returnDelayLabel.Size = UDim2.new(0.5, 0, 0, 22)
returnDelayLabel.Position = UDim2.new(0.05, 0, 0.28, 0)
returnDelayLabel.Text = "หน่วงหลังวาร์ปกลับ (วิ):"
returnDelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
returnDelayLabel.TextSize = 11
returnDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
returnDelayLabel.BackgroundTransparency = 1
returnDelayLabel.Parent = container

local returnDelayBox = Instance.new("TextBox")
returnDelayBox.Size = UDim2.new(0.35, 0, 0, 22)
returnDelayBox.Position = UDim2.new(0.6, 0, 0.28, 0)
returnDelayBox.Text = "3"
returnDelayBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
returnDelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
returnDelayBox.Font = Enum.Font.SourceSans
returnDelayBox.TextSize = 11
returnDelayBox.Parent = container
Instance.new("UICorner", returnDelayBox).CornerRadius = UDim.new(0, 4)

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.40, 0)
statusLabel.Text = "สถานะ: พร้อมทำงาน"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = container

-- Toggle Auto Loop Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.72, 0)
toggleBtn.Text = "▶️ เปิดทำงาน Auto Loop"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
toggleBtn.Parent = container
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 4. ระบบ Dropdown
-- ==========================================
local function refreshZoneList()
    for _, child in pairs(zoneScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local zonesFolder = workspace:FindFirstChild("Zones")
    local worldFolder = zonesFolder and zonesFolder:FindFirstChild(selectedWorldName)
    if not worldFolder then return end

    local zones = {}
    for _, zone in pairs(worldFolder:GetChildren()) do
        table.insert(zones, zone.Name)
    end
    table.sort(zones)

    for _, zoneName in ipairs(zones) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.Text = zoneName
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 12
        btn.ZIndex = 11
        btn.Parent = zoneScroll

        btn.MouseButton1Click:Connect(function()
            selectedZoneName = zoneName
            zoneDropdownBtn.Text = zoneName .. " ▼"
            zoneScroll.Visible = false
        end)
    end
    zoneScroll.CanvasSize = UDim2.new(0, 0, 0, #zones * 25)
end

local function refreshWorldList()
    for _, child in pairs(worldScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local zonesFolder = workspace:FindFirstChild("Zones")
    if not zonesFolder me then return end

    local worlds = {}
    for _, w in pairs(zonesFolder:GetChildren()) do
        table.insert(worlds, w.Name)
    end
    table.sort(worlds)

    for _, worldName in ipairs(worlds) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.Text = worldName
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 12
        btn.ZIndex = 11
        btn.Parent = worldScroll

        btn.MouseButton1Click:Connect(function()
            selectedWorldName = worldName
            worldDropdownBtn.Text = "World: " .. worldName .. " ▼"
            worldScroll.Visible = false
            selectedZoneName = ""
            zoneDropdownBtn.Text = "เลือก Zone ▼"
            refreshZoneList()
        end)
    end
    worldScroll.CanvasSize = UDim2.new(0, 0, 0, #worlds * 25)
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
-- 5. ฟังก์ชันประมวลผล 1 รอบการฟาร์ม (แก้ไข Error)
-- ==========================================
local function processSingleCollect()
    local isFull, capacityText = isBackpackFull()
    if isFull then
        local returnWait = tonumber(returnDelayBox.Text) or 3
        statusLabel.Text = "🛑 กระเป๋าเต็ม! (" .. capacityText .. ") วาร์ปกลับ Spawn..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        
        teleportToSpawn()
        
        statusLabel.Text = "⏳ รอนับถอยหลังพัก " .. tostring(returnWait) .. " วินาที..."
        task.wait(returnWait)
        return false
    end

    if selectedZoneName == "" then
        statusLabel.Text = "⚠️ กรุณากดเลือก Zone ก่อนครับ"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return false
    end

    local targetZone = workspace.Zones[selectedWorldName]:FindFirstChild(selectedZoneName)
    local spawnZone = targetZone and targetZone:FindFirstChild("SpawnZone")

    if not spawnZone then
        statusLabel.Text = "❌ ไม่พบ SpawnZone ใน " .. selectedZoneName
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return false
    end

    local items = spawnZone:GetChildren()
    if #items == 0 then
        statusLabel.Text = "⚠️ ไม่พบไอเทมใน " .. selectedZoneName
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return false
    end

    local targetItem = items[1]
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if hrp then
        local itemCFrame = nil
        if targetItem:IsA("Model") then
            itemCFrame = targetItem.PrimaryPart and targetItem.PrimaryPart.CFrame or targetItem:GetPivot()
        elseif targetItem:IsA("BasePart") then
            itemCFrame = targetItem.CFrame
        else
            local part = targetItem:FindFirstChildWhichIsA("BasePart", true)
            if part then itemCFrame = part.CFrame end
        end

        if itemCFrame then hrp.CFrame = itemCFrame end
    end

    task.wait(0.15)

    -- เช็คการเก็บไอเทมแบบปลอดภัย
    local prompt = targetItem:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        -- ตรวจสอบว่ามีฟังก์ชัน fireproximityprompt หรือไม่ ก่อนเรียกใช้
        if typeof(fireproximityprompt) == "function" then
            for i = 1, 3 do
                if targetItem.Parent then
                    fireproximityprompt(prompt)
                    task.wait(0.05)
                end
            end
        else
            -- หากไม่มี ให้ใช้ ProximityPromptService หรือ Trigger มาตรฐาน
            game:GetService("ProximityPromptService")
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0)
            prompt:InputHoldEnd()
        end

        statusLabel.Text = "✅ เก็บสำเร็จ: " .. targetItem.Name
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        local itemPart = targetItem:IsA("BasePart") and targetItem or targetItem:FindFirstChildWhichIsA("BasePart", true)
        if hrp and itemPart then
            -- ตรวจสอบ firetouchinterest แบบปลอดภัย
            if typeof(firetouchinterest) == "function" then
                firetouchinterest(hrp, itemPart, 0)
                task.wait(0.05)
                firetouchinterest(hrp, itemPart, 1)
            end

            statusLabel.Text = "✅ เก็บสำเร็จ: " .. targetItem.Name
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            statusLabel.Text = "❌ ไม่พบวิธีเก็บไอเทม"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    return true
end

-- ==========================================
-- 6. ระบบ Auto Loop
-- ==========================================
toggleBtn.MouseButton1Click:Connect(function()
    autoLoopActive = not autoLoopActive

    if autoLoopActive then
        toggleBtn.Text = "⏹️ หยุดทำงาน Auto Loop"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)

        task.spawn(function()
            while autoLoopActive do
                processSingleCollect()
                
                local loopWait = tonumber(loopDelayBox.Text) or 0.5
                task.wait(loopWait)
            end
        end)
    else
        toggleBtn.Text = "▶️ เปิดทำงาน Auto Loop"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        statusLabel.Text = "⏸️ หยุดการทำงานแล้ว"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- ระบบย่อ/ปิด UI
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    mainFrame.Size = isMinimized and UDim2.new(0, 320, 0, 30) or UDim2.new(0, 320, 0, 310)
    container.Visible = not isMinimized
    minimizeBtn.Text = isMinimized and "+" or "-"
end)

closeBtn.MouseButton1Click:Connect(function()
    autoLoopActive = false
    screenGui:Destroy()
end)
