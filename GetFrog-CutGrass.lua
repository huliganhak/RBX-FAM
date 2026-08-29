local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ⚙️ ตั้งค่าความเร็ว และโหมดทำงาน
-- ==========================================
local TARGET_WORLD = "W5"       -- กำหนด World ที่ใช้งาน
local WAIT_FROG_SPAWN = 0.5    -- เวลาที่รอให้กบโหลดขึ้นมาหลังจากย้าย Zone
local CATCH_DELAY = 0.2        -- เวลาหน่วงหลังจับกบแต่ละตัว

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
-- 2. สร้าง UI หน้าจอ (ปรับความสูงรองรับ Text + Toggle)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZoneFrogFarmUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 210)
mainFrame.Position = UDim2.new(0.5, -140, 0.35, 0)
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
zoneLabel.Size = UDim2.new(0.9, 0, 0, 22)
zoneLabel.Position = UDim2.new(0.05, 0, 0.02, 0)
zoneLabel.Text = "📍 Zone ปัจจุบัน: - "
zoneLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
zoneLabel.TextSize = 13
zoneLabel.Font = Enum.Font.SourceSansBold
zoneLabel.BackgroundTransparency = 1
zoneLabel.Parent = container

-- Text แสดงสถานะการทำงาน
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 22)
statusLabel.Position = UDim2.new(0.05, 0, 0.16, 0)
statusLabel.Text = "สถานะ: รอเปิดการทำงาน..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = container

-- ปุ่มสลับเปิด/ปิด โหมดวนลูปซ้ำ (Infinite Loop Toggle)
local loopToggleBtn = Instance.new("TextButton")
loopToggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
loopToggleBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
loopToggleBtn.Text = "🔁 โหมดวนลูปซ้ำ: ปิดอยู่ (ทำรอบเดียว)"
loopToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
loopToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loopToggleBtn.Font = Enum.Font.SourceSansBold
loopToggleBtn.TextSize = 12
loopToggleBtn.Parent = container
Instance.new("UICorner", loopToggleBtn).CornerRadius = UDim.new(0, 6)

-- ปุ่มกดเริ่ม/หยุดฟาร์ม
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.9, 0, 0, 42)
startBtn.Position = UDim2.new(0.05, 0, 0.58, 0)
startBtn.Text = "🚀 เริ่มฟาร์มแบบไล่ Zone"
startBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Font = Enum.Font.SourceSansBold
startBtn.TextSize = 14
startBtn.Parent = container
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 3. ระบบย่อ/ปิด UI & สลับโหมด Loop
-- ==========================================
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    mainFrame.Size = isMinimized and UDim2.new(0, 280, 0, 30) or UDim2.new(0, 280, 0, 210)
    container.Visible = not isMinimized
    minimizeBtn.Text = isMinimized and "+" or "-"
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local isLoopingEnabled = false -- ตัวแปรสถานะโหมดวนลูป
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

-- ==========================================
-- 4. ฟังก์ชันจัดการ Zone และการจับกบ
-- ==========================================
local isFarming = false

local function getObjectCFrame(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then
        return obj.CFrame
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart.CFrame
        else
            return obj:GetPivot()
        end
    end
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

    table.sort(zoneList, function(a, b)
        return a.number < b.number
    end)

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

local function catchSingleFrog(frog)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not frog then return end

    local frogCFrame = getObjectCFrame(frog)
    if frogCFrame then
        hrp.CFrame = frogCFrame + Vector3.new(0, 2, 0)
    end

    task.wait(0.1)
    local frogUUID = string.sub(frog.Name, 6)
    pcall(function()
        catchRemote:InvokeServer(frogUUID)
    end)
    task.wait(CATCH_DELAY)
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

            -- ไล่จาก Zone 47 -> Zone สุดท้าย
            for _, zoneData in ipairs(sortedZones) do
                if not isFarming then break end

                zoneLabel.Text = "📍 Zone ปัจจุบัน: " .. zoneData.name

                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local zoneCFrame = getObjectCFrame(zoneData.object)

                if hrp and zoneCFrame then
                    -- 1. ย้ายไป Zone ปัจจุบัน
                    statusLabel.Text = "🚶 กำลังย้ายไป " .. zoneData.name
                    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                    hrp.CFrame = zoneCFrame + Vector3.new(0, 3, 0)
                    
                    task.wait(WAIT_FROG_SPAWN)

                    -- 2. วนเก็บกบใน Zone
                    while isFarming do
                        local frogs = getFrogsList()
                        if #frogs == 0 then
                            break -- ไม่เจอกบ ขยับไป Zone+1
                        end

                        statusLabel.Text = string.format("🐸 พบกบ %d ตัวที่ %s", #frogs, zoneData.name)
                        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)

                        for _, frog in ipairs(frogs) do
                            if not isFarming then break end
                            catchSingleFrog(frog)
                        end

                        task.wait(0.2)
                    end
                end
            end
            
            task.wait(0.5)

        -- ถ้าเปิดโหมด Loop ไว้ จะทำวนซ้ำเรื่อยๆ จนกว่าเราจะกดหยุดเอง
        until not isFarming or not isLoopingEnabled

        -- เมื่อทำงานเสร็จสมบูรณ์
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
