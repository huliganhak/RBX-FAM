local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "NuvikTeam - v1",
   LoadingTitle = "NuvikTeam",
   LoadingSubtitle = "by Nuvik",
   Theme = "Amethyst",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "NuvikTeam",
      FileName = "Config"
   },
   KeySystem = false
})

local SelectedEgg = "Egg1"
local OpenAmount = 1
local SelectedTrain = "Normal"
local SelectedStage = "Stage 1 (0 Wins)"

local AutoEgg = false
local AutoKill = false
local AutoTrain = false
local AutoTrainArena = false

local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("Remotes")

local function ExtraerValor(Value)
    local val = type(Value) == "table" and Value[1] or Value
    return (val and val ~= "") and val or nil
end

local FarmTab = Window:CreateTab("Farm", 4483362458)

FarmTab:CreateSection("Farm Configuration")

FarmTab:CreateDropdown({
   Name = "Select Train Arena",
   Options = {"Normal", "Rebirth", "Gold", "Divine"},
   CurrentOption = {"Normal"},
   MultipleOptions = false,
   Callback = function(Value)
      local nuevoValor = ExtraerValor(Value)
      if nuevoValor then
         SelectedTrain = nuevoValor
      end
   end
})

FarmTab:CreateDropdown({
   Name = "Select Egg",
   Options = {"Egg1", "Egg2", "Egg3", "Egg4"},
   CurrentOption = {"Egg1"},
   MultipleOptions = false,
   Callback = function(Value)
      local nuevoValor = ExtraerValor(Value)
      if nuevoValor then
         SelectedEgg = nuevoValor
      end
   end
})

FarmTab:CreateSlider({
   Name = "Open Amount (Gamepass)",
   Range = {1, 3},
   Increment = 1,
   CurrentValue = 1,
   Callback = function(Value)
      OpenAmount = Value
   end
})

FarmTab:CreateSection("Auto Farms")

FarmTab:CreateToggle({
   Name = "Auto Train",
   CurrentValue = false,
   Callback = function(Value)
      AutoTrain = Value
      if AutoTrain then
         task.spawn(function()
            while AutoTrain do
               pcall(function()
                  Remotes:WaitForChild("MHP"):FireServer()
               end)
               task.wait(0.05)
            end
         end)
      end
   end
})

FarmTab:CreateToggle({
   Name = "Auto Train Arena",
   CurrentValue = false,
   Callback = function(Value)
      AutoTrainArena = Value
      if AutoTrainArena then
         task.spawn(function()
            while AutoTrainArena do
               pcall(function()
                  local trainArea = workspace:FindFirstChild("Train Area")
                  if trainArea and SelectedTrain then
                     local arenaNode = trainArea:FindFirstChild(SelectedTrain)
                     if arenaNode then
                        Remotes:WaitForChild("MHP"):FireServer(arenaNode)
                     end
                  end
               end)
               task.wait(0.1)
            end
         end)
      end
   end
})

FarmTab:CreateToggle({
   Name = "Auto Kill",
   CurrentValue = false,
   Callback = function(Value)
      AutoKill = Value
      if AutoKill then
         task.spawn(function()
            while AutoKill do
               pcall(function()
                  Remotes:WaitForChild("TakeDamage"):FireServer(8000000000000000)
               end)
               task.wait(0.1)
            end
         end)
      end
   end
})

FarmTab:CreateToggle({
   Name = "Auto Egg",
   CurrentValue = false,
   Callback = function(Value)
      AutoEgg = Value
      if AutoEgg then
         task.spawn(function()
            while AutoEgg do
               pcall(function()
                  RS:WaitForChild("Remote")
                    :WaitForChild("Function")
                    :WaitForChild("Luck")
                    :WaitForChild("[C-S]DoLuck")
                    :InvokeServer(SelectedEgg, OpenAmount)
               end)
               task.wait(0.1) 
            end
         end)
      end
   end
})

local TpTab = Window:CreateTab("Teleport", 4483362458)

local StagesData = {
    ["Stage 1 (0 Wins)"] = "Button1",
    ["Stage 2 (1 Win)"] = "Button2",
    ["Stage 3 (3 Wins)"] = "Button3",
    ["Stage 4 (4 Wins)"] = "Button4",
    ["Stage 5 (25 Wins)"] = "Button5",
    ["Stage 6 (75 Wins)"] = "Button6",
    ["Stage 7 (250 Wins)"] = "Button7",
    ["Stage 8 (650 Wins)"] = "Button8",
    ["Stage 9 (1.2K Wins)"] = "Button9",
    ["Stage 10 (3K Wins)"] = "Button10",
    ["Stage 11 (7.5K Wins)"] = "Button11",
    ["Stage 12 (25K Wins)"] = "Button12",
    ["Stage 13 (75K Wins)"] = "Button13",
    ["Stage 14 (175K Wins)"] = "Button14",
    ["Stage 15 (250K Wins)"] = "Button15",
    ["Stage 16 (1M Wins)"] = "Button16"
}

local StageList = {
    "Stage 1 (0 Wins)", "Stage 2 (1 Win)", "Stage 3 (3 Wins)", "Stage 4 (4 Wins)",
    "Stage 5 (25 Wins)", "Stage 6 (75 Wins)", "Stage 7 (250 Wins)", "Stage 8 (650 Wins)",
    "Stage 9 (1.2K Wins)", "Stage 10 (3K Wins)", "Stage 11 (7.5K Wins)", "Stage 12 (25K Wins)",
    "Stage 13 (75K Wins)", "Stage 14 (175K Wins)", "Stage 15 (250K Wins)", "Stage 16 (1M Wins)"
}

TpTab:CreateSection("Stages by Wins")

TpTab:CreateDropdown({
   Name = "Select Stage",
   Options = StageList,
   CurrentOption = {"Stage 1 (0 Wins)"},
   MultipleOptions = false,
   Callback = function(Value)
      local nuevoValor = ExtraerValor(Value)
      if nuevoValor then
         SelectedStage = nuevoValor
      end
   end
})

TpTab:CreateButton({
   Name = "Teleport",
   Callback = function()
      local targetButtonName = StagesData[SelectedStage]
      if targetButtonName then
         local targetButton = RS:WaitForChild("Buttons"):FindFirstChild(targetButtonName)
         if targetButton then
            local args = { targetButton }
            Remotes:WaitForChild("Teleport"):FireServer(unpack(args))
         end
      end
   end
})

Rayfield:Notify({
   Title = "NuvikTeam",
   Content = "FULL Hub loaded successfully 🔥",
   Duration = 4
})
