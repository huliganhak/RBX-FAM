local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ⚙️ ค่าเริ่มต้น (Default Values)
-- ==========================================
local TARGET_WORLD = "W5"       -- กำหนด World ที่ใช้งาน
local waitFrogSpawn = 0.5       -- เวลารอโหลดกบ (วินาที)
local catchDelay = 0.2          -- เวลาหน่วงหลังจับกบ (วินาที)
local loopDelay = 1.0           -- เวลาพักก่อนเริ่มลูปใหม่ (วินาที)

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
mainFrame.Size = UDim2.new(0, 280, 0, 320)
mainFrame.Position = UDim2.new(0.5, -140, 0.25, 0)
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
titleLabel.Text = "🐸 Zone Step Frog Farm"
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

-- Text แสดง Zone ปัจจุบัน
local zoneLabel = Instance.new("TextLabel")
zoneLabel.Size = UDim2.new(0.9, 0, 0, 18)
zoneLabel.Position = UDim2.new(0.05, 0, 0.02, 0)
zoneLabel.Text = "📍 Zone ปัจจุบัน: -"
zoneLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
zoneLabel.TextSize = 13
zoneLabel.Font = Enum.Font.SourceSansBold
zoneLabel.BackgroundTransparency = 1
zoneLabel.Parent = container

-- Text แสดงสถานะการค้นหา/จับกบ
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
-- ⚙️ โซนตั้งค่าเวลา (TextBox Inputs)
-- ------------------------------------------

local spawnTimeFrame = Instance.new("Frame")
spawnTimeFrame.Size = UDim2.new(0.9, 0, 0, 24)
spawnTimeFrame.Position = UDim2.new(0.05, 0, 0.18, 0)
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
spawnInput.Text = tostring(waitFrogSpawn)
spawnInput.PlaceholderText = "0.5"
spawnInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
spawnInput.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnInput.Font = Enum.Font.SourceSansBold
spawnInput.TextSize = 13
spawnInput.Parent = spawnTimeFrame
Instance.new("UICorner", spawnInput).CornerRadius = UDim.new(0, 4)

local catchTimeFrame = Instance.new("Frame")
catchTimeFrame.Size = UDim2.new(0.9, 0, 0, 24)
catchTimeFrame.Position = UDim2.new(0.05, 0, 0.28, 0)
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
catchInput.Text = tostring(catchDelay)
catchInput.PlaceholderText = "0.2"
catchInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
catchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
catchInput.Font = Enum.Font.SourceSansBold
catchInput.TextSize = 13
catchInput.Parent = catchTimeFrame
Instance.new("UICorner", catchInput).CornerRadius = UDim.new(0, 4)

local loopTimeFrame = Instance.new("Frame")
loopTimeFrame.Size = UDim2.new(0.9, 0, 0, 24)
loopTimeFrame.Position = UDim2.new(0.05, 0, 0.38, 0)
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
loopDelayInput.Text = tostring(loopDelay)
loopDelayInput.PlaceholderText = "1.0"
loopDelayInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
loopDelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
loopDelayInput.Font = Enum.Font.SourceSansBold
loopDelayInput.TextSize = 13
loopDelayInput.Parent = loopTimeFrame
Instance.new("UICorner", loopDelayInput).CornerRadius = UDim.new(0, 4)

local loopToggleBtn = Instance.new("TextButton")
loopToggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
loopToggleBtn.Position = UDim2.new(0.05, 0, 0.50, 0)
loopToggleBtn.Text = "🔁 โหมดวนลูปซ้ำ: ปิดอยู่ (ทำรอบเดียว)"
loopToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
loopToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loopToggleBtn.Font = Enum.Font.SourceSansBold
loopToggleBtn.TextSize = 12
loopToggleBtn.Parent = container
Instance.new("UICorner", loopToggleBtn).CornerRadius = UDim.new(0, 6)

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.9, 0, 0, 40)
startBtn.Position = UDim2.new(0.05, 0, 0.63, 0)
startBtn.Text = "🚀 เริ่มฟาร์มแบบไล่ Zone"
startBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Font = Enum.Font.SourceSansBold
startBtn.TextSize = 14
startBtn.Parent = container
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 3. ระบบจัดการ Event ต่างๆ
-- ==========================================
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    mainFrame.Size = isMinimized and UDim2.new(0, 280, 0, 30) or UDim2.new(0, 280, 0, 320)
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
        loopToggleBtn.Text = "🔁 โหมดวนลูปซ้ำ: เปิดอยู่ (วนไม่สิ้นสุด)"
        loopToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    else
        loopToggleBtn.Text = "🔁 โหมดวนลูปซ้ำ: ปิดอยู่ (ทำรอบเดียว)"
        loopToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
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
-- 4. ฟังก์ชันจัดการ Zone และการจับกบ
-- ==========================================
local isFarming = false

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
        table.insert(frogs, child)
    end
    return frogs
end

local function catchSingleFrog(frog, currentCount, totalCount)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not frog or not frog.Parent then return end

    -- 1. วาร์ปไปพิกัดกบ
    local frogCFrame = getObjectCFrame(frog)
    if frogCFrame then
        hrp.CFrame = frogCFrame + Vector3.new(0, 1, 0)
    end

    statusLabel.Text = string.format("⚡ กำลังจับกบ (%d/%d)...", currentCount, totalCount)
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

    task.wait(0.2)

    -- 2. หา UUID ของกบ
    local frogUUID = frog:GetAttribute("UUID") or frog:GetAttribute("FrogId")
    if not frogUUID then
        if string.sub(frog.Name, 1, 5) == "Frog_" then
            frogUUID = string.sub(frog.Name, 6)
        else
            frogUUID = frog.Name
        end
    end
    
    task.wait(0.2)
    
    -- 3. ส่ง UUID ตรงเข้า Remote และรอ Server ยืนยันผลลัพธ์
    if frogUUID then
        local success, result = pcall(function()
            return catchRemote:InvokeServer(frogUUID)
        end)
    
        if success then
            statusLabel.Text = "✅ จับสำเร็จ! UUID: " .. string.sub(frogUUID, 1, 8) .. "..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            statusLabel.Text = "❌ จับไม่สำเร็จ (Server Reject)"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    task.wait(0.2)
    task.wait(catchDelay)
end

-- ==========================================
-- 5. Main Loop การทำงาน
-- ==========================================
local function startZoneFarming()
    task.spawn(function()
        repeat
            local sortedZones = getSortedZones()
            if #sortedZones == 0 then
                statusLabel.Text = "❌ ไม่พบ Zone ใน " .. TARGET_WORLD
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                isFarming = false
                break
            end

            for _, zoneData in ipairs(sortedZones) do
                if not isFarming then break end

                zoneLabel.Text = "📍 Zone ปัจจุบัน: " .. zoneData.name

                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local zoneCFrame = getObjectCFrame(zoneData.object)

                if hrp and zoneCFrame then
                    -- 1. ย้ายไป Zone
                    hrp.CFrame = zoneCFrame + Vector3.new(0, 3, 0)
                    
                    statusLabel.Text = "🔍 กำลังสแกนหากบ..."
                    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                    
                    task.wait(waitFrogSpawn)

                    -- 2. เช็กกบ
                    local frogs = getFrogsList()
                    
                    if #frogs == 0 then
                        statusLabel.Text = "⚠️ ไม่พบกบใน Zone นี้"
                        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
                        task.wait(0.3)
                    else
                        local totalFrogs = #frogs
                        statusLabel.Text = string.format("🐸 พบกบ %d ตัว! กำลังเก็บ...", totalFrogs)
                        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                        task.wait(0.05)

                        -- 3. ไล่จับ
                        for i, frog in ipairs(frogs) do
                            if not isFarming then break end
                            catchSingleFrog(frog, i, totalFrogs)
                        end
                    end
                end
            end

            if isFarming and isLoopingEnabled then
                statusLabel.Text = string.format("⏳ พักรอเริ่มรอบใหม่ (%.1f วินาที)...", loopDelay)
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                task.wait(loopDelay)
            end

        until not isFarming or not isLoopingEnabled

        isFarming = false
        startBtn.Text = "🚀 เริ่มฟาร์มแบบไล่ Zone"
        startBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        statusLabel.Text = "สถานะ: ทำงานเสร็จสิ้นแล้ว"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end)
end

startBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        startBtn.Text = "🛑 หยุดฟาร์ม"
        startBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        startZoneFarming()
    else
        startBtn.Text = "🚀 เริ่มฟาร์มแบบไล่ Zone"
        startBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        statusLabel.Text = "สถานะ: หยุดการทำงาน"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)
