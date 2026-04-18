local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local function StealthTeleport(TargetPart)
	local Character = LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	if not Root then return end

	local TargetPosition = TargetPart.Position
	local Distance = (Root.Position - TargetPosition).Magnitude
	local HorizontalSpeed = 12
	local HorizontalDuration = math.max(Distance / HorizontalSpeed, 2)

	local ForwardOffset = TargetPart.CFrame.LookVector * 5
	local UnderStart = Root.CFrame * CFrame.new(0, -25, 0)
	local UnderTarget = (TargetPart.CFrame + ForwardOffset) * CFrame.new(0, -20, 0)
	local FinalPos = CFrame.new((TargetPart.CFrame + ForwardOffset).Position, TargetPosition)

	local VerticalFastInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local HorizontalSlowInfo = TweenInfo.new(HorizontalDuration, Enum.EasingStyle.Linear)

	local Step1 = TweenService:Create(Root, VerticalFastInfo, {CFrame = UnderStart})
	Step1:Play()
	Step1.Completed:Wait()

	local Step2 = TweenService:Create(Root, HorizontalSlowInfo, {CFrame = UnderTarget})
	Step2:Play()
	Step2.Completed:Wait()

	local Step3 = TweenService:Create(Root, VerticalFastInfo, {CFrame = FinalPos})
	Step3:Play()
	Step3.Completed:Wait()
	
	task.wait(0.2)
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
	task.wait(3)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

local function GetGeneratorsFolder()
	local Maps = workspace:FindFirstChild("MAPS")
	if not Maps then return nil end
	
	local GameMap = Maps:FindFirstChild("GAME MAP")
	if not GameMap then return nil end
	
	return GameMap:FindFirstChild("Generators")
end

local function StartGeneratorAutomation()
	while true do
		task.wait(1)
		
		local Generators = GetGeneratorsFolder()
		if not Generators then 
			continue 
		end

		local Character = LocalPlayer.Character
		if not Character or Character:GetAttribute("Team") ~= "Survivor" then 
			continue 
		end

		local GeneratorList = Generators:GetChildren()
		local FoundTarget = false

		for _, Generator in ipairs(GeneratorList) do
			if not Generator:IsA("Model") then continue end
			
			local Progress = Generator:GetAttribute("Progress")
			local Primary = Generator.PrimaryPart

			if Progress and Progress < 100 and Primary then
				FoundTarget = true
				StealthTeleport(Primary)

				repeat
					task.wait(1)
					local CurrentGenerators = GetGeneratorsFolder()
					if not CurrentGenerators or not Generator:IsDescendantOf(CurrentGenerators) then break end
				until Generator:GetAttribute("Progress") >= 100
				
				break
			end
		end
		
		if not FoundTarget then
			task.wait(2)
		end
	end
end

task.spawn(StartGeneratorAutomation)
