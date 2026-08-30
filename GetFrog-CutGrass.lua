local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ⚙️ ค่าเริ่มต้น (Default Values 1.0 วินาที)
-- ==========================================
local TARGET_WORLD = "W5"       -- กำหนด World ที่ใช้งาน
local waitFrogSpawn = 1.0       -- เวลารอโหลดกบ (วินาที)
local catchDelay = 1.0          -- เวลาหน่วงหลังจับกบ (วินาที)
local loopDelay = 1.0           -- เวลาพักก่อนเริ่มลูปใหม่ (วินาที)
local scanInterval = 1.0        -- เวลาหน่วงในการสแกนหากบ (วินาที)

-- ==========================================
-- 1. อ้างอิง RemoteFunction (Knit)
-- ==========================================
local catchRemote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("acecateer_knit@1.7.2")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("FrogEventService")
    :WaitForChild("RF")
    :WaitForChild("Catch")

-- ==========================================
-- 2. สร้าง UI หน้าจอ
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZoneFrogFarmUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 480)
mainFrame.Position = UDim2.new(0.5, -150, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Header Bar
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 30)
headerFrame.BackgroundTransparency = 1
headerFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "🐸 Frog Farm Hub"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
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

-- Text แสดงจำนวนกบที่สะสม (Frogs Count)
local frogsCountLabel = Instance.new("TextLabel")
frogsCountLabel.Size = UDim2.new(0.9, 0, 0, 18)
frogsCountLabel.Position = UDim2.new(0.05, 0, 0.01, 0)
frogsCountLabel.Text = "🐸 จำนวนกบสะสม: 0"
frogsCountLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
frogsCountLabel.TextSize = 13
frogsCountLabel.Font = Enum.Font.SourceSansBold
frogsCountLabel.BackgroundTransparency = 1
frogsCountLabel.Parent = container

-- Text แสดง Zone ปัจจุบัน
local zoneLabel = Instance.new("TextLabel")
zoneLabel.Size = UDim2.new(0.9, 0, 0, 18)
zoneLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
zoneLabel.Text = "📍 Zone ปัจจุบัน: -"
zoneLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
zoneLabel.TextSize = 12
zoneLabel.Font = Enum.Font.SourceSansBold
zoneLabel.BackgroundTransparency = 1
zoneLabel.Parent = container

-- Text แสดงสถานะ
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 18)
statusLabel.Position = UDim2.new(0.05, 0, 0.09, 0)
statusLabel.Text = "สถานะ: รอเปิดการทำงาน..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = container

-- ------------------------------------------
-- ⚙️ โซนตั้งค่าเวลา (Default 1.0s ทุกช่อง)
-- ------------------------------------------

-- 1. หน่วงเวลาสแกนกบ
local scanTimeFrame = Instance.new("Frame")
scanTimeFrame.Size = UDim2.new(0.9, 0, 0, 22)
scanTimeFrame.Position = UDim2.new(0.05, 0, 0.14, 0)
scanTimeFrame.BackgroundTransparency = 1
scanTimeFrame.Parent = container

local scanLabel = Instance.new("TextLabel")
scanLabel.Size = UDim2.new(0.65, 0, 1, 0)
scanLabel.Text = "🔍 หน่วงเวลาสแกนกบ (วินาที):"
scanLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
scanLabel.TextSize = 12
scanLabel.Font = Enum.Font.SourceSans
scanLabel.TextXAlignment = Enum.TextXAlignment.Left
scanLabel.BackgroundTransparency = 1
scanLabel.Parent = scanTimeFrame

local scanInput = Instance.new("TextBox")
scanInput.Size = UDim2.new(0.35, 0, 1, 0)
scanInput.Position = UDim2.new(0.65, 0, 0, 0)
scanInput.Text = "1.0"
scanInput.PlaceholderText = "1.0"
scanInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
scanInput.TextColor3 = Color3.fromRGB(255, 255, 255)
scanInput.Font = Enum.Font.SourceSansBold
scanInput.TextSize = 13
scanInput.Parent = scanTimeFrame
Instance.new("UICorner", scanInput).CornerRadius = UDim.new(0, 4)

-- 2. รอโหลดกบ
local spawnTimeFrame = Instance.new("Frame")
spawnTimeFrame.Size = UDim2.new(0.9, 0, 0, 22)
spawnTimeFrame.Position = UDim2.new(0.05, 0, 0.20, 0)
spawnTimeFrame.BackgroundTransparency = 1
spawnTimeFrame.Parent = container

local spawnLabel = Instance.new("TextLabel")
spawnLabel.Size = UDim2.new(0.65, 0, 1, 0)
spawnLabel.Text = "⏳ รอโหลดกบ (วินาที):"
spawnLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
spawnLabel.TextSize = 12
spawnLabel.Font = Enum.Font.SourceSans
spawnLabel.TextXAlignment = Enum.TextXAlignment.Left
spawnLabel.BackgroundTransparency = 1
spawnLabel.Parent = spawnTimeFrame

local spawnInput = Instance.new("TextBox")
spawnInput.Size = UDim2.new(0.35, 0, 1, 0)
spawnInput.Position = UDim2.new(0.65, 0, 0, 0)
spawnInput.Text = "1.0"
spawnInput.PlaceholderText = "1.0"
spawnInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
spawnInput.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnInput.Font = Enum.Font.SourceSansBold
spawnInput.TextSize = 13
spawnInput.Parent = spawnTimeFrame
Instance.new("UICorner", spawnInput).CornerRadius = UDim.new(0, 4)

-- 3. หน่วงหลังจับ
local catchTimeFrame = Instance.new("Frame")
catchTimeFrame.Size = UDim2.new(0.9, 0, 0, 22)
catchTimeFrame.Position = UDim2.new(0.05, 0, 0.26, 0)
catchTimeFrame.BackgroundTransparency = 1
catchTimeFrame.Parent = container

local catchLabel = Instance.new("TextLabel")
catchLabel.Size = UDim2.new(0.65, 0, 1, 0)
catchLabel.Text = "⚡ หน่วงหลังจับ (วินาที):"
catchLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
catchLabel.TextSize = 12
catchLabel.Font = Enum.Font.SourceSans
catchLabel.TextXAlignment = Enum.TextXAlignment.Left
catchLabel.BackgroundTransparency = 1
catchLabel.Parent = catchTimeFrame

local catchInput = Instance.new("TextBox")
catchInput.Size = UDim2.new(0.35, 0, 1, 0)
catchInput.Position = UDim2.new(0.65, 0, 0, 0)
catchInput.Text = "1.0"
catchInput.PlaceholderText = "1.0"
catchInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
catchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
catchInput.Font = Enum.Font.SourceSansBold
catchInput.TextSize = 13
catchInput.Parent = catchTimeFrame
Instance.new("UICorner", catchInput).CornerRadius = UDim.new(0, 4)

-- 4. พักก่อนลูปใหม่
local loopTimeFrame = Instance.new("Frame")
loopTimeFrame.Size = UDim2.new(0.9, 0, 0, 22)
loopTimeFrame.Position = UDim2.new(0.05, 0, 0.32, 0)
loopTimeFrame.BackgroundTransparency = 1
loopTimeFrame.Parent = container

local loopDelayLabel = Instance.new("TextLabel")
loopDelayLabel.Size = UDim2.new(0.65, 0, 1, 0)
loopDelayLabel.Text = "💤 พักก่อนลูปใหม่ (วินาที):"
loopDelayLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
loopDelayLabel.TextSize = 12
loopDelayLabel.Font = Enum.Font.SourceSans
loopDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
loopDelayLabel.BackgroundTransparency = 1
loopDelayLabel.Parent = loopTimeFrame

local loopDelayInput = Instance.new("TextBox")
loopDelayInput.Size = UDim2.new(0.35, 0, 1, 0)
loopDelayInput.Position = UDim2.new(0.65, 0, 0, 0)
loopDelayInput.Text = "1.0"
loopDelayInput.PlaceholderText = "1.0"
loopDelayInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
loopDelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
loopDelayInput.Font = Enum.Font.SourceSansBold
loopDelayInput.TextSize = 13
loopDelayInput.Parent = loopTimeFrame
Instance.new("UICorner", loopDelayInput).CornerRadius = UDim.new(0, 4)

-- ปุ่มสลับโหมดวนลูป (สำหรับโหมด Zone)
local loopToggleBtn = Instance.new("TextButton")
loopToggleBtn.Size = UDim2.new(0.9, 0, 0, 24)
loopToggleBtn.Position = UDim2.new(0.05, 0, 0.39, 0)
loopToggleBtn.Text = "🔁 โหมดวนลูป Zone: ปิดอยู่ (ทำรอบเดียว)"
loopToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
loopToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loopToggleBtn.Font = Enum.Font.SourceSansBold
loopToggleBtn.TextSize = 12
loopToggleBtn.Parent = container
Instance.new("UICorner", loopToggleBtn).CornerRadius = UDim.new(0, 6)

-- ------------------------------------------
-- 🔘 ปุ่มเลือกโหมดการทำงาน
-- ------------------------------------------

-- ปุ่มโหมด 1: ไล่ Zone
local startZoneBtn = Instance.new("TextButton")
startZoneBtn.Size = UDim2.new(0.9, 0, 0, 32)
startZoneBtn.Position = UDim2.new(0.05, 0, 0.46, 0)
startZoneBtn.Text = "🚀 โหมด 1: เริ่มฟาร์มแบบไล่ Zone"
startZoneBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
startZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startZoneBtn.Font = Enum.Font.SourceSansBold
startZoneBtn.TextSize = 13
startZoneBtn.Parent = container
Instance.new("UICorner", startZoneBtn).CornerRadius = UDim.new(0, 6)

-- ปุ่มโหมด 2.1: Loop สแกนกบ
local startLoopScanBtn = Instance.new("TextButton")
startLoopScanBtn.Size = UDim2.new(0.9, 0, 0, 32)
startLoopScanBtn.Position = UDim2.new(0.05, 0, 0.54, 0)
startLoopScanBtn.Text = "🔄 โหมด 2.1: สแกนหากบแบบ Loop"
startLoopScanBtn.BackgroundColor3 = Color3.fromRGB(70, 120, 200)
startLoopScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startLoopScanBtn.Font = Enum.Font.SourceSansBold
startLoopScanBtn.TextSize = 13
startLoopScanBtn.Parent = container
Instance.new("UICorner", startLoopScanBtn).CornerRadius = UDim.new(0, 6)

-- ปุ่มโหมด 2.2: สแกนกบครั้งเดียว
local startSingleScanBtn = Instance.new("TextButton")
startSingleScanBtn.Size = UDim2.new(0.9, 0, 0, 32)
startSingleScanBtn.Position = UDim2.new(0.05, 0, 0.62, 0)
startSingleScanBtn.Text = "🎯 โหมด 2.2: สแกนกบครั้งเดียว (Single)"
startSingleScanBtn.BackgroundColor3 = Color3.fromRGB(150, 90, 200)
startSingleScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startSingleScanBtn.Font = Enum.Font.SourceSansBold
startSingleScanBtn.TextSize = 13
startSingleScanBtn.Parent = container
Instance.new("UICorner", startSingleScanBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 3. ระบบอัปเดตจำนวนกบสะสม (Frogs Attribute)
-- ==========================================
local function updateFrogsDisplay()
    local frogsVal = LocalPlayer:GetAttribute("Frogs")
    if frogsVal == nil then
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:FindFirstChild("Frogs") then
            frogsVal = leaderstats.Frogs.Value
        end
    end
    frogsCountLabel.Text = "🐸 จำนวนกบสะสม: " .. tostring(frogsVal or 0)
end

updateFrogsDisplay()
LocalPlayer:GetAttributeChangedSignal("Frogs"):Connect(updateFrogsDisplay)

-- ==========================================
-- 4. ระบบจัดการ UI Event ต่างๆ
-- ==========================================
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    mainFrame.Size = isMinimized and UDim2.new(0, 300, 0, 30) or UDim2.new(0, 300, 0, 480)
    container.Visible = not isMinimized
    minimizeBtn.Text = isMinimized and "+" or "-"
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local isLoopingEnabled = false
loopToggleBtn.MouseButton1Click:Connect(function()
    isLoopingEnabled = not isLoopingEnabled
    if isLoopingEnabled then
        loopToggleBtn.Text = "🔁 โหมดวนลูป Zone: เปิดอยู่ (วนไม่สิ้นสุด)"
        loopToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    else
        loopToggleBtn.Text = "🔁 โหมดวนลูป Zone: ปิดอยู่ (ทำรอบเดียว)"
        loopToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

scanInput.FocusLost:Connect(function()
    local num = tonumber(scanInput.Text)
    if num and num >= 0 then scanInterval = num else scanInput.Text = tostring(scanInterval) end
end)

spawnInput.FocusLost:Connect(function()
    local num = tonumber(spawnInput.Text)
    if num and num >= 0 then waitFrogSpawn = num else spawnInput.Text = tostring(waitFrogSpawn) end
end)

catchInput.FocusLost:Connect(function()
    local num = tonumber(catchInput.Text)
    if num and num >= 0 then catchDelay = num else catchInput.Text = tostring(catchDelay) end
end)

loopDelayInput.FocusLost:Connect(function()
    local num = tonumber(loopDelayInput.Text)
    if num and num >= 0 then loopDelay = num else loopDelayInput.Text = tostring(loopDelay) end
end)

-- ==========================================
-- 5. ฟังก์ชันจับกบและจัดการตำแหน่ง
-- ==========================================
local isFarming = false
local currentMode = ""

local function getObjectCFrame(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.CFrame
    elseif obj:IsA("Model") then return obj.PrimaryPart and obj.PrimaryPart.CFrame or obj:GetPivot() end
    return nil
end

local function getSortedZones()
    local zonesFolder = workspace:FindFirstChild("Zones")
    if not zonesFolder then return {} end
    local worldFolder = zonesFolder:FindFirstChild(TARGET_WORLD)
    if not worldFolder then return {} end

    local zoneList = {}
    for _, child in ipairs(worldFolder:GetChildren()) do
        local num = tonumber(string.match(child.Name, "%d+"))
        if num then
            table.insert(zoneList, { name = child.Name, number = num, object = child })
        end
    end

    table.sort(zoneList, function(a, b) return a.number < b.number end)
    return zoneList
end

local function getFrogsList()
    local eventFrogs = workspace:FindFirstChild("LocalEventFrogs")
    if not eventFrogs then return {} end
    
    local frogs = {}
    for _, child in ipairs(eventFrogs:GetChildren()) do
        if string.sub(child.Name, 1, 5) == "Frog_" then
            table.insert(frogs, child)
        end
    end
    return frogs
end

local function catchSingleFrog(targetFrog, currentCount, totalCount)
    if not targetFrog or not targetFrog.Parent then return end

    local frogUUID = string.sub(targetFrog.Name, 6)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if hrp then
        local frogCFrame = nil
        if targetFrog:IsA("Model") and targetFrog.PrimaryPart then
            frogCFrame = targetFrog.PrimaryPart.CFrame
        elseif targetFrog:FindFirstChild("RootPart") then
            frogCFrame = targetFrog.RootPart.CFrame
        elseif targetFrog:IsA("BasePart") then
            frogCFrame = targetFrog.CFrame
        end

        if frogCFrame then
            hrp.CFrame = frogCFrame + Vector3.new(0, 2, 0)
        end
    end

    statusLabel.Text = string.format("⚡ วาร์ปแล้ว รอซิงค์ตำแหน่ง (%d/%d)...", currentCount, totalCount)
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    task.wait(0.2)

    local success, result = pcall(function()
        return catchRemote:InvokeServer(frogUUID)
    end)

    if success then
        statusLabel.Text = "✅ จับสำเร็จ! UUID: " .. string.sub(frogUUID, 1, 8) .. "..."
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusLabel.Text = "❌ จับไม่สำเร็จ (Error)"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end

    task.wait(catchDelay)
end

-- ==========================================
-- 6. Main Loops / Functions
-- ==========================================

local function resetButtons()
    isFarming = false
    currentMode = ""
    startZoneBtn.Text = "🚀 โหมด 1: เริ่มฟาร์มแบบไล่ Zone"
    startZoneBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
    
    startLoopScanBtn.Text = "🔄 โหมด 2.1: สแกนหากบแบบ Loop"
    startLoopScanBtn.BackgroundColor3 = Color3.fromRGB(70, 120, 200)
    
    startSingleScanBtn.Text = "🎯 โหมด 2.2: สแกนกบครั้งเดียว (Single)"
    startSingleScanBtn.BackgroundColor3 = Color3.fromRGB(150, 90, 200)

    statusLabel.Text = "สถานะ: ทำงานเสร็จสิ้นแล้ว"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
end

-- โหมด 1: ไล่ Zone
local function startZoneFarming()
    task.spawn(function()
        repeat
            local sortedZones = getSortedZones()
            if #sortedZones == 0 then
                statusLabel.Text = "❌ ไม่พบ Zone ใน " .. TARGET_WORLD
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                break
            end

            for _, zoneData in ipairs(sortedZones) do
                if not isFarming or currentMode ~= "Zone" then break end

                zoneLabel.Text = "📍 Zone ปัจจุบัน: " .. zoneData.name

                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local zoneCFrame = getObjectCFrame(zoneData.object)

                if hrp and zoneCFrame then
                    hrp.CFrame = zoneCFrame + Vector3.new(0, 3, 0)
                    statusLabel.Text = "🔍 กำลังสแกนหากบ..."
                    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                    
                    task.wait(waitFrogSpawn)

                    local frogs = getFrogsList()
                    if #frogs == 0 then
                        statusLabel.Text = "⚠️ ไม่พบกบใน Zone นี้"
                        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
                        task.wait(0.2)
                    else
                        local totalFrogs = #frogs
                        statusLabel.Text = string.format("🐸 พบกบ %d ตัว! กำลังเก็บ...", totalFrogs)
                        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                        task.wait(0.1)

                        for i, frog in ipairs(frogs) do
                            if not isFarming or currentMode ~= "Zone" then break end
                            catchSingleFrog(frog, i, totalFrogs)
                        end
                    end
                end
            end

            if isFarming and currentMode == "Zone" and isLoopingEnabled then
                statusLabel.Text = string.format("⏳ พักรอเริ่มรอบใหม่ (%.1f วินาที)...", loopDelay)
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                task.wait(loopDelay)
            end

        until not isFarming or currentMode ~= "Zone" or not isLoopingEnabled

        resetButtons()
    end)
end

-- โหมด 2.1: Loop สแกนกบซ้ำๆ
local function startLoopScanFarming()
    task.spawn(function()
        zoneLabel.Text = "📍 Zone ปัจจุบัน: Loop Scan"
        while isFarming and currentMode == "LoopScan" do
            statusLabel.Text = string.format("🔍 กำลังสแกนหากบ (หน่วง %.1f วินาที)...", scanInterval)
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            
            task.wait(scanInterval)
            if not isFarming or currentMode ~= "LoopScan" then break end

            local frogs = getFrogsList()
            if #frogs > 0 then
                local totalFrogs = #frogs
                statusLabel.Text = string.format("🐸 พบกบ %d ตัว! กำลังเริ่มเก็บ...", totalFrogs)
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                task.wait(0.1)

                for i, frog in ipairs(frogs) do
                    if not isFarming or currentMode ~= "LoopScan" then break end
                    catchSingleFrog(frog, i, totalFrogs)
                end
            end
        end

        resetButtons()
    end)
end

-- โหมด 2.2: สแกนกบครั้งเดียวแล้วจบ
local function startSingleScanFarming()
    task.spawn(function()
        zoneLabel.Text = "📍 Zone ปัจจุบัน: Single Scan"
        statusLabel.Text = "🔍 กำลังสแกนหากบครั้งเดียว..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        task.wait(0.1)
        local frogs = getFrogsList()

        if #frogs == 0 then
            statusLabel.Text = "⚠️ ไม่พบกบ ณ ตอนนี้"
            statusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
            task.wait(1.5)
        else
            local totalFrogs = #frogs
            statusLabel.Text = string.format("🐸 พบกบ %d ตัว! กำลังเก็บ...", totalFrogs)
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            task.wait(0.1)

            for i, frog in ipairs(frogs) do
                if not isFarming or currentMode ~= "SingleScan" then break end
                catchSingleFrog(frog, i, totalFrogs)
            end
        end

        resetButtons()
    end)
end

-- ==========================================
-- 7. Event กดปุ่มเปิด-ปิด แต่ละโหมด
-- ==========================================

-- ปุ่ม 1: ไล่ Zone
startZoneBtn.MouseButton1Click:Connect(function()
    if isFarming and currentMode == "Zone" then
        resetButtons()
    else
        resetButtons()
        isFarming = true
        currentMode = "Zone"
        startZoneBtn.Text = "🛑 หยุดฟาร์ม (โหมด Zone)"
        startZoneBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        startZoneFarming()
    end
end)

-- ปุ่ม 2.1: Loop Scan
startLoopScanBtn.MouseButton1Click:Connect(function()
    if isFarming and currentMode == "LoopScan" then
        resetButtons()
    else
        resetButtons()
        isFarming = true
        currentMode = "LoopScan"
        startLoopScanBtn.Text = "🛑 หยุดสแกน Loop"
        startLoopScanBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        startLoopScanFarming()
    end
end)

-- ปุ่ม 2.2: Single Scan
startSingleScanBtn.MouseButton1Click:Connect(function()
    if isFarming and currentMode == "SingleScan" then
        resetButtons()
    else
        resetButtons()
        isFarming = true
        currentMode = "SingleScan"
        startSingleScanBtn.Text = "🛑 กำลังทำรายการ..."
        startSingleScanBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        startSingleScanFarming()
    end
end)
