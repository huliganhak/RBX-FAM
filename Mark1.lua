local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. ค้นหาปุ่มกด หรือสร้างขึ้นมาใหม่หากหาไม่พบ
local button = script.Parent
if not (button and (button:IsA("TextButton") or button:IsA("ImageButton"))) then
	button = script:FindFirstAncestorOfClass("TextButton") or script:FindFirstAncestorOfClass("ImageButton")
end

-- หากหาปุ่มเดิมไม่พบ จะสร้าง UI ใหม่ให้อยู่ตำแหน่งที่เหมาะสม
if not button then
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AutoStageTeleportGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local newButton = Instance.new("TextButton")
	newButton.Name = "TeleportButton"
	newButton.Size = UDim2.new(0, 160, 0, 45)
	
	-- ปรับตำแหน่งและ AnchorPoint ใหม่เพื่อไม่ให้หลุดขอบจอ
	newButton.AnchorPoint = Vector2.new(1, 0.5) -- ใช้ขอบขวาของปุ่มเป็นจุดอ้างอิง
	newButton.Position = UDim2.new(0.95, -20, 0.6, 0) -- ขยับเข้ามาจากขอบขวา 20 พิกเซล
	
	newButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	newButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	newButton.TextScaled = true
	newButton.Font = Enum.Font.GothamBold
	newButton.Text = "Loading..."
	newButton.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = newButton

	button = newButton
end

-- 2. ฟังก์ชันอัปเดตข้อความบนปุ่ม
local function updateButtonText(text)
	if button:IsA("TextButton") then
		button.Text = text
	elseif button:FindFirstChildOfClass("TextLabel") then
		button:FindFirstChildOfClass("TextLabel").Text = text
	end
end

-- 3. ค้นหา Map3 และ Stages
local map3 = workspace:WaitForChild("Map3", 10)
if not map3 then 
	updateButtonText("No Map3")
	warn("ไม่พบ workspace.Map3") 
	return 
end

local stagesFolder = map3:WaitForChild("Stages", 10)
if not stagesFolder then 
	updateButtonText("No Stages")
	warn("ไม่พบ workspace.Map3.Stages") 
	return 
end

local sortedStages = {}
local currentIndex = 1

-- 4. ดึงข้อมูลและเรียงลำดับด่านจากน้อยไปมาก
local function loadAndSortStages()
	sortedStages = {}
	for _, stageFolder in ipairs(stagesFolder:GetChildren()) do
		local stageNumStr = string.match(stageFolder.Name, "%d+")
		if stageNumStr then
			local stageNum = tonumber(stageNumStr)
			if stageNum then
				table.insert(sortedStages, {
					number = stageNum,
					folder = stageFolder
				})
			end
		end
	end

	table.sort(sortedStages, function(a, b)
		return a.number < b.number
	end)
end

-- 5. ระบบ Teleport
local function teleportToNextStage()
	if #sortedStages == 0 then
		loadAndSortStages()
	end

	if #sortedStages == 0 then
		updateButtonText("No Stages")
		return
	end

	local currentStageData = sortedStages[currentIndex]
	if not currentStageData then return end

	local stageFolder = currentStageData.folder
	local spawnPart = stageFolder:FindFirstChild("Spawn")

	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if spawnPart and hrp then
		-- วาปตัวละครไปที่ Spawn
		hrp.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
		
		-- เลื่อนไป Stage ถัดไป
		currentIndex = currentIndex + 1
		if currentIndex > #sortedStages then
			currentIndex = 1
		end
		
		-- แสดงเลข Stage ถัดไปบนปุ่ม
		local nextStageNum = sortedStages[currentIndex].number
		updateButtonText("Next: Stage " .. nextStageNum)
	else
		warn("ไม่พบ Spawn ใน " .. stageFolder.Name)
	end
end

-- เริ่มทำงาน
loadAndSortStages()

if #sortedStages > 0 then
	updateButtonText("Go Stage " .. sortedStages[1].number)
else
	updateButtonText("No Stages")
end

button.MouseButton1Click:Connect(teleportToNextStage)
