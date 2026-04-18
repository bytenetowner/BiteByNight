local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local PromptDetected = false

local function GetGeneratorsFolder()
	local Maps = Workspace:FindFirstChild("MAPS")
	local GameMap = Maps and Maps:FindFirstChild("GAME MAP")
	return GameMap and GameMap:FindFirstChild("Generators")
end

local function AlignCharacterAndCamera(TargetPart)
	local Character = LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	
	if Root and TargetPart then
		local TargetPos = TargetPart.Position
		local NewRootCFrame = CFrame.new(Root.Position, Vector3.new(TargetPos.X, Root.Position.Y, TargetPos.Z))
		Root.CFrame = NewRootCFrame
		
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPos)
	end
end

ProximityPromptService.PromptShown:Connect(function(Prompt)
	PromptDetected = true
	task.wait(0.1)
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
	task.wait(2)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end)

local function RunGeneratorAutomation()
	while true do
		task.wait(0.5)
		
		local Character = LocalPlayer.Character
		local Root = Character and Character:FindFirstChild("HumanoidRootPart")
		
		if not Root or Character:GetAttribute("Team") ~= "Survivor" then 
			continue 
		end
		
		local Folder = GetGeneratorsFolder()
		if not Folder then 
			continue 
		end
		
		for _, Generator in ipairs(Folder:GetChildren()) do
			local MainPart = Generator.PrimaryPart
			local Progress = Generator:GetAttribute("Progress")
			
			if MainPart and Progress and Progress < 100 then
				PromptDetected = false
				local GenPos = MainPart.Position
				
				local StartUnder = Root.CFrame * CFrame.new(0, -20, 0)
				TweenService:Create(Root, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {CFrame = StartUnder}):Play()
				task.wait(0.5)
				
				local TargetUnderPos = Vector3.new(GenPos.X, Root.Position.Y, GenPos.Z)
				local Distance = (Root.Position - TargetUnderPos).Magnitude
				local TravelTime = Distance / 25
				
				TweenService:Create(Root, TweenInfo.new(TravelTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(TargetUnderPos, GenPos)}):Play()
				task.wait(TravelTime)
				
				local Angle = 0
				while not PromptDetected do
					Angle = Angle + 0.1
					local Offset = Vector3.new(math.cos(Angle) * 5, 0, math.sin(Angle) * 5)
					local NewPos = GenPos + Offset
					
					Root.CFrame = CFrame.new(NewPos, GenPos)
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, GenPos)
					
					task.wait()
					
					if not Generator:IsDescendantOf(Folder) or Generator:GetAttribute("Progress") >= 100 then break end
				end
				
				repeat
					task.wait(0.2)
					AlignCharacterAndCamera(MainPart)
					if not Generator:IsDescendantOf(Folder) or Character:GetAttribute("Team") ~= "Survivor" then break end
				until Generator:GetAttribute("Progress") >= 100
				
				PromptDetected = false
				task.wait(0.5)
			end
		end
	end
end

task.spawn(RunGeneratorAutomation)
