local Players = game:GetService("Players")
local player = Players.LocalPlayer
local button = script.Parent

local stagesFolder = workspace:WaitForChild("Map3"):WaitForChild("Stages")

local sortedStages = {}
local currentIndex = 1

-- 1. ฟังก์ชันดึง Stage ทั้งหมดและเรียงลำดับตามตัวเลข
local function loadAndSortStages()
	sortedStages = {}
	
	for _, stageFolder in ipairs(stagesFolder:GetChildren()) do
		-- ดึงเฉพาะตัวเลขออกจากชื่อโฟลเดอร์ เช่น "Stage31" -> 31
		local stageNum = tonumber(stageFolder.Name:match("%d+"))
		if stageNum then
			table.insert(sortedStages, {
				number = stageNum,
				folder = stageFolder
			})
		end
	end

	-- เรียงลำดับจากเลขน้อยไปหามาก
	table.sort(sortedStages, function(a, b)
		return a.number < b.number
	end)
end

-- 2. ฟังก์ชันสำหรับ Warp ไปยัง Spawn ของ Stage ถัดไป
local function teleportToNextStage()
	if #sortedStages == 0 then
		loadAndSortStages()
	end

	if #sortedStages == 0 then
		warn("ไม่พบ Stage ใน workspace.Map3.Stages")
		return
	end

	-- ดึง Stage ตาม Index ปัจจุบัน
	local currentStageData = sortedStages[currentIndex]
	local stageFolder = currentStageData.folder
	local spawnPart = stageFolder:FindFirstChild("Spawn")

	if spawnPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		-- วาปตัวละครไปตำแหน่ง Spawn (ยกสูงขึ้นเล็กน้อยเพื่อกันติดพื้น)
		player.Character.HumanoidRootPart.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
		
		-- อัปเดตข้อความบนปุ่ม
		button.Text = "Next Stage (" .. currentStageData.number .. ")"
		
		-- ขยับ Index ไปยังลำดับถัดไป (ถ้าถึง stage สุดท้ายแล้วกดอีกจะวนกลับมาอันแรก)
		currentIndex = currentIndex + 1
		if currentIndex > #sortedStages then
			currentIndex = 1
		end
	else
		warn("ไม่พบ Spawn ใน " .. stageFolder.Name)
	end
end

-- โหลดข้อมูล Stage ครั้งแรกและผูกเหตุการณ์คลิกปุ่ม
loadAndSortStages()

if #sortedStages > 0 then
	button.Text = "Next Stage (" .. sortedStages[1].number .. ")"
end

button.MouseButton1Click:Connect(teleportToNextStage)
