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
        local currentText = backpackValue.Text -- เช่น "4/23"
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
screenGui.Name = "DropdownZoneCollectorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Position = UDim2.new(0.5, -160, 0.3, 0)
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
titleLabel.Text = "📦 Auto Dropdown Zone Collector"
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

-- World Dropdown
local worldDropdownBtn = Instance.new("TextButton")
worldDropdownBtn.Size = UDim2.new(0.42, 0, 0, 32)
worldDropdownBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
worldDropdownBtn.Text = "World: W5 ▼"
worldDropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
worldDropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
worldDropdownBtn.Font = Enum.Font.SourceSansBold
worldDropdownBtn.TextSize = 13
worldDropdownBtn.Parent = container
Instance.new("UICorner", worldDropdownBtn).CornerRadius = UDim.new(0, 4)

local worldScroll = Instance.new("ScrollingFrame")
worldScroll.Size = UDim2.new(0.42, 0, 0, 120)
worldScroll.Position = UDim2.new(0.05, 0, 0.2, 0)
worldScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
worldScroll.Visible = false
worldScroll.ZIndex = 10
worldScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
worldScroll.Parent = container
local worldListLayout = Instance.new("UIListLayout", worldScroll)

-- Zone Dropdown
local zoneDropdownBtn = Instance.new("TextButton")
zoneDropdownBtn.Size = UDim2.new(0.45, 0, 0, 32)
zoneDropdownBtn.Position = UDim2.new(0.5, 0, 0.05, 0)
zoneDropdownBtn.Text = "เลือก Zone ▼"
zoneDropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
zoneDropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
zoneDropdownBtn.Font = Enum.Font.SourceSansBold
zoneDropdownBtn.TextSize = 13
zoneDropdownBtn.Parent = container
Instance.new("UICorner", zoneDropdownBtn).CornerRadius = UDim.new(0, 4)

local zoneScroll = Instance.new("ScrollingFrame")
zoneScroll.Size = UDim2.new(0.45, 0, 0, 120)
zoneScroll.Position = UDim2.new(0.5, 0, 0.2, 0)
zoneScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
zoneScroll.Visible = false
zoneScroll.ZIndex = 10
zoneScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
zoneScroll.Parent = container
local zoneListLayout = Instance.new("UIListLayout", zoneScroll)

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.28, 0)
statusLabel.Text = "สถานะ: พร้อมทำงาน"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = container

-- Action Button
local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(0.9, 0, 0, 45)
actionBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
actionBtn.Text = "🚀 สแกน + วาร์ป + เก็บไอเทม"
actionBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
actionBtn.Font = Enum.Font.SourceSansBold
actionBtn.TextSize = 14
actionBtn.Parent = container
Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 4. ระบบ List Dropdown
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
    if not zonesFolder then return end

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
-- 5. ระบบการทำงานหลัก
-- ==========================================
actionBtn.MouseButton1Click:Connect(function()
    -- 1. เช็คกระเป๋าก่อนทำงาน
    local isFull, capacityText = isBackpackFull()
    if isFull then
        statusLabel.Text = "🛑 กระเป๋าเต็มแล้ว! (" .. capacityText .. ") กำลังกลับ Spawn..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        
        -- สั่งกลับ Spawn ทันที
        teleportToSpawn()
        return
    end

    if selectedZoneName == "" then
        statusLabel.Text = "⚠️ กรุณากดเลือก Zone ก่อนครับ"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end

    local targetZone = workspace.Zones[selectedWorldName]:FindFirstChild(selectedZoneName)
    local spawnZone = targetZone and targetZone:FindFirstChild("SpawnZone")

    if not spawnZone then
        statusLabel.Text = "❌ ไม่พบ SpawnZone ใน " .. selectedZoneName
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    local items = spawnZone:GetChildren()
    if #items == 0 then
        statusLabel.Text = "⚠️ ไม่พบไอเทมใน " .. selectedZoneName
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
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

    statusLabel.Text = "⚡ วาร์ปแล้ว รอ Server ซิงค์..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    task.wait(0.15)

    local prompt = targetItem:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        if fireproximityprompt then
            for i = 1, 3 do
                if targetItem.Parent then
                    fireproximityprompt(prompt)
                    task.wait(0.05)
                end
            end
        else
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end

        statusLabel.Text = "✅ เก็บสำเร็จ: " .. targetItem.Name
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        local itemPart = targetItem:IsA("BasePart") and targetItem or targetItem:FindFirstChildWhichIsA("BasePart", true)
        if hrp and itemPart and firetouchinterest then
            firetouchinterest(hrp, itemPart, 0)
            task.wait(0.05)
            firetouchinterest(hrp, itemPart, 1)

            statusLabel.Text = "✅ เก็บสำเร็จ (Touch): " .. targetItem.Name
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            statusLabel.Text = "❌ ไม่พบวิธีเก็บไอเทม"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end)

-- ระบบย่อ/ปิด UI
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    mainFrame.Size = isMinimized and UDim2.new(0, 320, 0, 30) or UDim2.new(0, 320, 0, 260)
    container.Visible = not isMinimized
    minimizeBtn.Text = isMinimized and "+" or "-"
end)

closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
