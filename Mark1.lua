local Players = game:GetService("Players")
local player = Players.LocalPlayer
local button = script.Parent

-- รอให้ Map3 และ Stages โหลดเสร็จก่อน
local map3 = workspace:WaitForChild("Map3", 10)
if not map3 then 
	warn("ไม่พบ workspace.Map3") 
	return 
end

local stagesFolder = map3:WaitForChild("Stages", 10)
if not stagesFolder then 
	warn("ไม่พบ workspace.Map3.Stages") 
	return 
end

local sortedStages = {}
local currentIndex = 1

-- ฟังก์ชันดึง Stage และเรียงลำดับ
local function loadAndSortStages()
	sortedStages = {}
	
	for _, stageFolder in ipairs(stagesFolder:GetChildren()) do
		local stageName = stageFolder.Name
		
		-- ตรวจสอบและดึงตัวเลขจากชื่อโฟลเดอร์แบบปลอดภัย
		local stageNumStr = string.match(stageName, "%d+")
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

	-- เรียงลำดับจากน้อยไปมาก
	table.sort(sortedStages, function(a, b)
		return a.number < b.number
	end)
end

-- ฟังก์ชัน Warp ไปยัง Stage ถัดไป
local function teleportToNextStage()
	if #sortedStages == 0 then
		loadAndSortStages()
	end

	if #sortedStages == 0 then
		warn("ไม่มีด่านให้วาป")
		return
	end

	local currentStageData = sortedStages[currentIndex]
	if not currentStageData then return end

	local stageFolder = currentStageData.folder
	local spawnPart = stageFolder:FindFirstChild("Spawn")

	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if spawnPart and hrp then
		-- วาปตัวละคร
		hrp.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
		
		-- ขยับไปลำดับถัดไป
		currentIndex = currentIndex + 1
		if currentIndex > #sortedStages then
			currentIndex = 1
		end
		
		-- อัปเดตข้อความบนปุ่ม
		local nextStageNum = sortedStages[currentIndex].number
		button.Text = "Next Stage (" .. nextStageNum .. ")"
	else
		warn("ไม่พบ Spawn ใน " .. stageFolder.Name .. " หรือตัวละครยังไม่พร้อม")
	end
end

-- เริ่มต้นทำงาน
loadAndSortStages()

if #sortedStages > 0 then
	button.Text = "Go to Stage (" .. sortedStages[1].number .. ")"
end

button.MouseButton1Click:Connect(teleportToNextStage)
