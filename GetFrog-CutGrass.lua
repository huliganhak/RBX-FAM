local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ⚙️ ค่าเริ่มต้น (Default Values 1.0 วินาที)
-- ==========================================
local TARGET_WORLD = "W5"
local waitFrogSpawn = 1.0
local catchDelay = 1.0
local loopDelay = 1.0
local scanInterval = 1.0

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
-- 2. สร้าง UI แบบ Compact ดีไซน์ใหม่
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZoneFrogFarmUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 310, 0, 315) -- ปรับขนาดให้พอดี ไม่บังจอ
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

-- 📊 Info Section (กบสะสม / Zone / สถานะ)
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, 0, 0, 52)
infoFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
infoFrame.Parent = container
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 6)

local frogsCountLabel = Instance.new("TextLabel")
frogsCountLabel.Size = UDim2.new(1, 0, 0, 16)
frogsCountLabel.Position = UDim2.new(0, 0, 0, 4)
frogsCountLabel.Text = "🐸 จำนวนกบสะสม: 0"
frogsCountLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
frogsCountLabel.TextSize = 12
frogsCountLabel.Font = Enum.Font.SourceSansBold
frogsCountLabel.BackgroundTransparency = 1
frogsCountLabel.Parent = infoFrame

local zoneLabel = Instance.new("TextLabel")
zoneLabel.Size = UDim2.new(1, 0, 0, 15)
zoneLabel.Position = UDim2.new(0, 0, 0, 20)
zoneLabel.Text = "📍 Zone ปัจจุบัน: -"
zoneLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
zoneLabel.TextSize = 11
zoneLabel.Font = Enum.Font.SourceSansBold
zoneLabel.BackgroundTransparency = 1
zoneLabel.Parent = infoFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 15)
statusLabel.Position = UDim2.new(0, 0, 0, 35)
statusLabel.Text = "สถานะ: พร้อมใช้งาน"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = infoFrame

-- ⚙️ Settings Section (จัดเรียงแบบ 2 ช่องต่อบรรทัด)
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

-- แถวที่ 1 ของการตั้งค่า
local scanInput = createInputGroup(container, UDim2.new(0, 0, 0, 58), "🔍 หน่วงสแกน:", "1.0")
local spawnInput = createInputGroup(container, UDim2.new(0.515, 0, 0, 58), "⏳ รอโหลดกบ:", "1.0")

-- แถวที่ 2 ของการตั้งค่า
local catchInput = createInputGroup(container, UDim2.new(0, 0, 0, 88), "⚡ หน่วงหลังจับ:", "1.0")
local loopDelayInput = createInputGroup(container, UDim2.new(0.515, 0, 0, 88), "💤 พักก่อนลูป:", "1.0")

-- 🔁 ปุ่มสลับลูปสำหรับโหมด 1 (Zone)
local loopToggleBtn = Instance.new("TextButton")
loopToggleBtn.Size = UDim2.new(1, 0, 0, 24)
loopToggleBtn.Position = UDim2.new(0, 0, 0, 118)
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
startZoneBtn.Position = UDim2.new(0, 0, 0, 147)
startZoneBtn.Text = "🚀 โหมด 1: เริ่มฟาร์มแบบไล่ Zone"
startZoneBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 75)
startZoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startZoneBtn.Font = Enum.Font.SourceSansBold
startZoneBtn.TextSize = 12
startZoneBtn.Parent = container
Instance.new("UICorner", startZoneBtn).CornerRadius = UDim.new(0, 6)

-- ปุ่มโหมด 2 วางคู่กัน ซ้าย-ขวา
local startLoopScanBtn = Instance.new("TextButton")
startLoopScanBtn.Size = UDim2.new(0.485, 0, 0, 34)
startLoopScanBtn.Position = UDim2.new(0, 0, 0, 186)
startLoopScanBtn.Text = "🔄 2.1 สแกน Loop"
startLoopScanBtn.BackgroundColor3 = Color3.fromRGB(60, 110, 180)
startLoopScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startLoopScanBtn.Font = Enum.Font.SourceSansBold
startLoopScanBtn.TextSize = 12
startLoopScanBtn.Parent = container
Instance.new("UICorner", startLoopScanBtn).CornerRadius = UDim.new(0, 6)

local startSingleScanBtn = Instance.new("TextButton")
startSingleScanBtn.Size = UDim2.new(0.485, 0, 0, 34)
startSingleScanBtn.Position = UDim2.new(0.515, 0, 0, 186)
startSingleScanBtn.Text = "🎯 2.2 สแกน Single"
startSingleScanBtn.BackgroundColor3 = Color3.fromRGB(130, 80, 180)
startSingleScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startSingleScanBtn.Font = Enum.Font.SourceSansBold
startSingleScanBtn.TextSize = 12
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
    mainFrame.Size = isMinimized and UDim2.new(0, 310, 0, 28) or UDim2.new(0, 310, 0, 260)
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

    statusLabel.Text = string.format("⚡ วาร์ปจับกบ (%d/%d)...", currentCount, totalCount)
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    task.wait(0.2)

    local success, result = pcall(function()
        return catchRemote:InvokeServer(frogUUID)
    end)

    if success then
        statusLabel.Text = "✅ จับสำเร็จ! UUID: " .. string.sub(frogUUID, 1, 6)
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
    startZoneBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 75)
    
    startLoopScanBtn.Text = "🔄 2.1 สแกน Loop"
    startLoopScanBtn.BackgroundColor3 = Color3.fromRGB(60, 110, 180)
    
    startSingleScanBtn.Text = "🎯 2.2 สแกน Single"
    startSingleScanBtn.BackgroundColor3 = Color3.fromRGB(130, 80, 180)

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

-- โหมด 2.2: สแกนกบครั้งเดียว
local function startSingleScanFarming()
    task.spawn(function()
        zoneLabel.Text = "📍 Zone ปัจจุบัน: Single Scan"
        statusLabel.Text = "🔍 สแกนหากบครั้งเดียว..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        task.wait(0.1)
        local frogs = getFrogsList()

        if #frogs == 0 then
            statusLabel.Text = "⚠️ ไม่พบกบ ณ ตอนนี้"
            statusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
            task.wait(1.2)
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
        startLoopScanBtn.Text = "🛑 หยุด Loop"
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
        startSingleScanBtn.Text = "🛑 กำลังทำ..."
        startSingleScanBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        startSingleScanFarming()
    end
end)
