local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ⚙️ ค่าเริ่มต้น
-- ==========================================
local TARGET_WORLD = "W5"
local waitFrogSpawn = 1.0
local catchDelay = 0.5
local loopDelay = 1.0
local scanInterval = 1.0

local currentZoneIndex = 1 -- 📍 ตัวแปรเก็บลำดับ Zone ปัจจุบัน

-- ==========================================
-- 1. อ้างอิง RemoteFunction (Knit)
-- ==========================================
local knitServices = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("acecateer_knit@1.7.2")
    :WaitForChild("knit")
    :WaitForChild("Services")

local catchRemote = knitServices
    :WaitForChild("FrogEventService")
    :WaitForChild("RF")
    :WaitForChild("Catch")

local teleportToSpawnRemote = knitServices
    :WaitForChild("BaseTeleportService")
    :WaitForChild("RF")
    :WaitForChild("TeleportToSpawn")

local function teleportBackToSpawn()
    pcall(function()
        teleportToSpawnRemote:InvokeServer()
    end)
end

-- ==========================================
-- 2. ฟังก์ชันช่วยเช็กจำนวนกบปัจจุบัน
-- ==========================================
local function getCurrentFrogCount()
    local frogsVal = LocalPlayer:GetAttribute("Frogs")
    if frogsVal == nil then
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:FindFirstChild("Frogs") then
            frogsVal = leaderstats.Frogs.Value
        end
    end
    return frogsVal or 0
end

-- ==========================================
-- 3. สร้าง UI
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZoneFrogFarmUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 310, 0, 370)
mainFrame.Position = UDim2.new(0.5, -155, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Header Bar
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 28)
headerFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
headerFrame.Parent = mainFrame
Instance.new("UICorner", headerFrame).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "🐸 Frog Farm Hub"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = headerFrame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 22, 0, 22)
minimizeBtn.Position = UDim2.new(1, -50, 0, 3)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 14
minimizeBtn.Parent = headerFrame
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 4)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -25, 0, 3)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 12
closeBtn.Parent = headerFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

-- Container
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -16, 1, -36)
container.Position = UDim2.new(0, 8, 0, 32)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- 📊 Info Section
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, 0, 0, 68)
infoFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
infoFrame.Parent = container
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 6)

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0, 15)
timerLabel.Position = UDim2.new(0, 0, 0, 3)
timerLabel.Text = "⏳ Event: กำลังโหลด..."
timerLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
timerLabel.TextSize = 11
timerLabel.Font = Enum.Font.SourceSansBold
timerLabel.BackgroundTransparency = 1
timerLabel.Parent = infoFrame

local frogsCountLabel = Instance.new("TextLabel")
frogsCountLabel.Size = UDim2.new(1, 0, 0, 15)
frogsCountLabel.Position = UDim2.new(0, 0, 0, 19)
frogsCountLabel.Text = "🐸 จำนวนกบสะสม: 0"
frogsCountLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
frogsCountLabel.TextSize = 11
frogsCountLabel.Font = Enum.Font.SourceSansBold
frogsCountLabel.BackgroundTransparency = 1
frogsCountLabel.Parent = infoFrame

local zoneLabel = Instance.new("TextLabel")
zoneLabel.Size = UDim2.new(1, 0, 0, 15)
zoneLabel.Position = UDim2.new(0, 0, 0, 35)
zoneLabel.Text = "📍 Zone ปัจจุบัน: -"
zoneLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
zoneLabel.TextSize = 11
zoneLabel.Font = Enum.Font.SourceSansBold
zoneLabel.BackgroundTransparency = 1
zoneLabel.Parent = infoFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 15)
statusLabel.Position = UDim2.new(0, 0, 0, 51)
statusLabel.Text = "สถานะ: พร้อมใช้งาน"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = infoFrame

-- ⚙️ Settings Section
local function createInputGroup(parent, pos, labelText, defaultVal)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.485, 0, 0, 26)
    frame.Position = pos
    frame.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.68, 0, 1, 0)
    lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 10
    lbl.Font = Enum.Font.SourceSans
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = frame

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.28, 0, 0.75, 0)
    input.Position = UDim2.new(0.69, 0, 0.125, 0)
    input.Text = defaultVal
    input.PlaceholderText = defaultVal
    input.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.SourceSansBold
    input.TextSize = 11
    input.Parent = frame
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 3)

    return input
end

local scanInput = createInputGroup(container, UDim2.new(0, 0, 0, 74), "🔍 หน่วงสแกน:", "1.0")
local spawnInput = createInputGroup(container, UDim2.new(0.515, 0, 0, 74), "⏳ รอโหลดกบ:", "1.0")
local catchInput = createInputGroup(container, UDim2.new(0, 0, 0, 104), "⚡ หน่วงหลังจับ:", "0.5")
local loopDelayInput = createInputGroup(container, UDim2.new(0.515, 0, 0, 104), "💤 พักก่อนลูป:", "1.0")

-- 🔁 ปุ่มสลับลูปสำหรับโหมด 1 (Zone)
local loopToggleBtn = Instance.new("TextButton")
loopToggleBtn.Size = UDim2.new(1, 0, 0, 24)
loopToggleBtn.Position = UDim2.new(0, 0, 0, 134)
loopToggleBtn.Text = "🔁 ลูป Zone: ปิดอยู่ (ทำรอบเดียว)"
loopToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
loopToggleBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
loopToggleBtn.Font = Enum.Font.SourceSansBold
loopToggleBtn.TextSize = 11
loopToggleBtn.Parent = container
Instance.new("UICorner", loopToggleBtn).CornerRadius = UDim.new(0, 5)

-- 🔘 โซนปุ่มการทำงานหลัก
local startZoneBtn = Instance.new("TextButton")
startZoneBtn.Size = UDim2.new(1, 0, 0, 34)
startZoneBtn.Position = UDim2.new(0, 0, 0, 163)
startZoneBtn.Text = "🚀 โหมด 1: เริ่มฟาร์มแบบไล่ Zone"
startZoneBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 75)
startZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startZoneBtn.Font = Enum.Font.SourceSansBold
startZoneBtn.TextSize = 12
startZoneBtn.Parent = container
Instance.new("UICorner", startZoneBtn).CornerRadius = UDim.new(0, 6)

-- ⏭️ ปุ่ม Next Zone
local nextZoneBtn = Instance.new("TextButton")
nextZoneBtn.Size = UDim2.new(1, 0, 0, 28)
nextZoneBtn.Position = UDim2.new(0, 0, 0, 202)
nextZoneBtn.Text = "⏭️ ไป Zone ถัดไป (Next Zone)"
nextZoneBtn.BackgroundColor3 = Color3.fromRGB(200, 130, 30)
nextZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nextZoneBtn.Font = Enum.Font.SourceSansBold
nextZoneBtn.TextSize = 12
nextZoneBtn.Parent = container
Instance.new("UICorner", nextZoneBtn).CornerRadius = UDim.new(0, 6)

local startLoopScanBtn = Instance.new("TextButton")
startLoopScanBtn.Size = UDim2.new(0.485, 0, 0, 34)
startLoopScanBtn.Position = UDim2.new(0, 0, 0, 235)
startLoopScanBtn.Text = "🔄 2.1 สแกน Loop"
startLoopScanBtn.BackgroundColor3 = Color3.fromRGB(60, 110, 180)
startLoopScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startLoopScanBtn.Font = Enum.Font.SourceSansBold
startLoopScanBtn.TextSize = 12
startLoopScanBtn.Parent = container
Instance.new("UICorner", startLoopScanBtn).CornerRadius = UDim.new(0, 6)

local startSingleScanBtn = Instance.new("TextButton")
startSingleScanBtn.Size = UDim2.new(0.485, 0, 0, 34)
startSingleScanBtn.Position = UDim2.new(0.515, 0, 0, 235)
startSingleScanBtn.Text = "🎯 2.2 สแกน Single"
startSingleScanBtn.BackgroundColor3 = Color3.fromRGB(130, 80, 180)
startSingleScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startSingleScanBtn.Font = Enum.Font.SourceSansBold
startSingleScanBtn.TextSize = 12
startSingleScanBtn.Parent = container
Instance.new("UICorner", startSingleScanBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 4. ระบบดึงค่า Event Timer & Frogs Count
-- ==========================================

task.spawn(function()
    local success, timerTextObj = pcall(function()
        return Workspace:WaitForChild("Worlds")
            :WaitForChild("World_5")
            :WaitForChild("PondW5")
            :WaitForChild("Pond")
            :WaitForChild("EventBillboardGui")
            :WaitForChild("Timer")
    end)

    if success and timerTextObj then
        local function updateTimer()
            timerLabel.Text = "⏳ Event: " .. tostring(timerTextObj.Text)
        end
        updateTimer()
        timerTextObj:GetPropertyChangedSignal("Text"):Connect(updateTimer)
    else
        timerLabel.Text = "⏳ Event: ไม่พบตำแหน่ง Timer"
    end
end)

local function updateFrogsDisplay()
    frogsCountLabel.Text = "🐸 จำนวนกบสะสม: " .. tostring(getCurrentFrogCount())
end

updateFrogsDisplay()
LocalPlayer:GetAttributeChangedSignal("Frogs"):Connect(updateFrogsDisplay)

-- ==========================================
-- 5. ระบบจัดการ UI Event
-- ==========================================
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    mainFrame.Size = isMinimized and UDim2.new(0, 310, 0, 28) or UDim2.new(0, 310, 0, 370)
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
        loopToggleBtn.Text = "🔁 ลูป Zone: เปิดอยู่ (วนไม่สิ้นสุด)"
        loopToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 110, 150)
        loopToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        loopToggleBtn.Text = "🔁 ลูป Zone: ปิดอยู่ (ทำรอบเดียว)"
        loopToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
        loopToggleBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
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
-- 6. ฟังก์ชันค้นหา Zone และจับกบ (เพิ่มระบบยืนยันแต้ม)
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
    local zonesFolder = Workspace:FindFirstChild("Zones")
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
    local eventFrogs = Workspace:FindFirstChild("LocalEventFrogs")
    if not eventFrogs then return {} end
    
    local frogs = {}
    for _, child in ipairs(eventFrogs:GetChildren()) do
        if string.sub(child.Name, 1, 5) == "Frog_" then
            table.insert(frogs, child)
        end
    end
    return frogs
end

-- 🌟 ฟังก์ชันจับกบพร้อมระบบรอเช็กแต้มยืนยัน
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

    statusLabel.Text = string.format("⚡ วาร์ปจับกบ (%d/%d)...", currentCount, totalCount)
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    task.wait(0.1)

    -- 📌 บันทึกแต้มกบก่อนทำการจับ
    local initialCount = getCurrentFrogCount()

    -- ส่งสัญญาณจับกบไปยัง Server
    pcall(function()
        catchRemote:InvokeServer(frogUUID)
    end)

    -- 🔍 วนรอจนกว่าแต้มกบจะเพิ่มขึ้นจริง (ตั้งเวลา Timeout ไว้ที่ 2.0 วินาที)
    statusLabel.Text = "⏳ กำลังรอเช็กแต้ม..."
    statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)

    local startTime = tick()
    local caughtSuccess = false

    while (tick() - startTime) < 2.0 do
        if getCurrentFrogCount() > initialCount then
            caughtSuccess = true
            break
        end
        task.wait(0.05)
    end

    if caughtSuccess then
        statusLabel.Text = "✅ จับสำเร็จ! แต้มขึ้นแล้ว"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusLabel.Text = "⚠️ หมดเวลารอแต้ม (ข้ามไปขั้นตอนถัดไป)"
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
    end

    task.wait(catchDelay)
end

-- ==========================================
-- 7. Main Loops & Reset Systems
-- ==========================================

local function resetButtons()
    isFarming = false
    currentMode = ""
    currentZoneIndex = 1

    startZoneBtn.Text = "🚀 โหมด 1: เริ่มฟาร์มแบบไล่ Zone"
    startZoneBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 75)
    
    startLoopScanBtn.Text = "🔄 2.1 สแกน Loop"
    startLoopScanBtn.BackgroundColor3 = Color3.fromRGB(60, 110, 180)
    
    startSingleScanBtn.Text = "🎯 2.2 สแกน Single"
    startSingleScanBtn.BackgroundColor3 = Color3.fromRGB(130, 80, 180)

    statusLabel.Text = "🌀 กำลังวาร์ปกลับ Spawn..."
    statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    teleportBackToSpawn()

    task.wait(0.5)
    zoneLabel.Text = "📍 Zone ปัจจุบัน: -"
    statusLabel.Text = "สถานะ: กลับ Spawn แล้ว (Reset Zone)"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
end

-- โหมด 1: ไล่ Zone แบบอัตโนมัติ
local function startZoneFarming()
    task.spawn(function()
        repeat
            local sortedZones = getSortedZones()
            if #sortedZones == 0 then
                statusLabel.Text = "❌ ไม่พบ Zone ใน " .. TARGET_WORLD
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                break
            end

            while currentZoneIndex <= #sortedZones do
                if not isFarming or currentMode ~= "Zone" then break end

                local zoneData = sortedZones[currentZoneIndex]
                zoneLabel.Text = "📍 Zone ปัจจุบัน: " .. zoneData.name

                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local zoneCFrame = getObjectCFrame(zoneData.object)

                if hrp and zoneCFrame then
                    hrp.CFrame = zoneCFrame + Vector3.new(0, 3, 0)
                    statusLabel.Text = "🔍 กำลังสแกนหากบ..."
                    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                    
                    task.wait(waitFrogSpawn)

                    local frogs = getFrogsList()
                    if #frogs > 0 then
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

                currentZoneIndex = currentZoneIndex + 1
            end

            if isFarming and currentMode == "Zone" then
                currentZoneIndex = 1

                if isLoopingEnabled then
                    statusLabel.Text = string.format("⏳ ครบรอบ! พักรอเริ่มลูปใหม่ (%.1f วิ)...", loopDelay)
                    statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                    task.wait(loopDelay)
                end
            end

        until not isFarming or currentMode ~= "Zone" or not isLoopingEnabled

        resetButtons()
    end)
end

-- โหมด 2.1: Loop Scan
local function startLoopScanFarming()
    task.spawn(function()
        zoneLabel.Text = "📍 Zone ปัจจุบัน: Loop Scan"
        while isFarming and currentMode == "LoopScan" do
            statusLabel.Text = string.format("🔍 สแกนหากบ (หน่วง %.1f วินาที)...", scanInterval)
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            
            task.wait(scanInterval)
            if not isFarming or currentMode ~= "LoopScan" then break end

            local frogs = getFrogsList()
            if #frogs > 0 then
                local totalFrogs = #frogs
                statusLabel.Text = string.format("🐸 พบกบ %d ตัว! กำลังเก็บ...", totalFrogs)
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

-- โหมด 2.2: Single Scan (ค้นหา -> เลือกกบตัวแรกสุด 1 ตัว -> วาร์ปจับ + เช็กแต้ม -> จบการทำงาน)
local function startSingleScanFarming()
    task.spawn(function()
        zoneLabel.Text = "📍 Zone ปัจจุบัน: Single Scan"
        statusLabel.Text = "🔍 กำลังค้นหากบ..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        task.wait(0.1)
        local frogs = getFrogsList()

        if #frogs == 0 then
            statusLabel.Text = "⚠️ ไม่พบกบ ณ ตอนนี้"
            statusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
        else
            local firstFrog = frogs[1]
            statusLabel.Text = "🎯 พบกบ! กำลังวาร์ปไปจับตัวแรก..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            -- วาร์ปจับและเช็กแต้ม
            catchSingleFrog(firstFrog, 1, 1)

            statusLabel.Text = "✅ จับกบตัวแรกเสร็จสิ้น (ตำแหน่งเดิม)"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end

        -- คืนค่าปุ่มโดยไม่วาร์ปกลับ Spawn
        isFarming = false
        currentMode = ""
        startSingleScanBtn.Text = "🎯 2.2 สแกน Single"
        startSingleScanBtn.BackgroundColor3 = Color3.fromRGB(130, 80, 180)
    end)
end

-- ==========================================
-- 8. Event กดปุ่ม
-- ==========================================

-- ปุ่ม 1: ไล่ Zone
startZoneBtn.MouseButton1Click:Connect(function()
    if isFarming and currentMode == "Zone" then
        resetButtons()
    else
        isFarming = true
        currentMode = "Zone"
        startZoneBtn.Text = "🛑 หยุดฟาร์ม (โหมด Zone)"
        startZoneBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        startZoneFarming()
    end
end)

-- ⏭️ ปุ่ม Next Zone (วาร์ปเปลี่ยน Zone เท่านั้น ไม่สแกน/จับกบ)
nextZoneBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        local sortedZones = getSortedZones()
        if #sortedZones == 0 then
            statusLabel.Text = "❌ ไม่พบ Zone ใน " .. TARGET_WORLD
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end

        if currentZoneIndex > #sortedZones then
            statusLabel.Text = "🏠 เกิน Zone สุดท้าย -> กลับ Spawn"
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            
            teleportBackToSpawn()
            currentZoneIndex = 1
            zoneLabel.Text = "📍 Zone ปัจจุบัน: -"
            statusLabel.Text = "สถานะ: วาร์ปกลับ Spawn (Reset Zone)"
            return
        end

        local targetZoneData = sortedZones[currentZoneIndex]
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local zoneCFrame = getObjectCFrame(targetZoneData.object)

        if hrp and zoneCFrame then
            hrp.CFrame = zoneCFrame + Vector3.new(0, 3, 0)
            zoneLabel.Text = "📍 Zone ปัจจุบัน: " .. targetZoneData.name
            statusLabel.Text = "📍 วาร์ปไป " .. targetZoneData.name .. " เรียบร้อย"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end

        currentZoneIndex = currentZoneIndex + 1
    end)
end)

-- ปุ่ม 2.1: Loop Scan
startLoopScanBtn.MouseButton1Click:Connect(function()
    if isFarming and currentMode == "LoopScan" then
        resetButtons()
    else
        isFarming = true
        currentMode = "LoopScan"
        startLoopScanBtn.Text = "🛑 หยุด Loop"
        startLoopScanBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        startLoopScanFarming()
    end
end)

-- ปุ่ม 2.2: Single Scan
startSingleScanBtn.MouseButton1Click:Connect(function()
    if isFarming and currentMode == "SingleScan" then
        isFarming = false
        currentMode = ""
        startSingleScanBtn.Text = "🎯 2.2 สแกน Single"
        startSingleScanBtn.BackgroundColor3 = Color3.fromRGB(130, 80, 180)
        statusLabel.Text = "🛑 ยกเลิก Single Scan"
    else
        isFarming = true
        currentMode = "SingleScan"
        startSingleScanBtn.Text = "🛑 กำลังทำ..."
        startSingleScanBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        startSingleScanFarming()
    end
end)
