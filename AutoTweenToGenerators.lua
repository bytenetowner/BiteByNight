local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function StealthTeleport(TargetPart, SideOffset)
	local Character = LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	if not Root then return false end

	local TargetPosition = TargetPart.Position
	local Distance = (Root.Position - TargetPosition).Magnitude
	local HorizontalSpeed = 12
	local HorizontalDuration = math.max(Distance / HorizontalSpeed, 2)

	local OffsetCFrame = SideOffset or CFrame.new(0, 0, 5) 
	local TargetCFrame = TargetPart.CFrame * OffsetCFrame
	
	local UnderStart = Root.CFrame * CFrame.new(0, -25, 0)
	local UnderTarget = TargetCFrame * CFrame.new(0, -20, 0)
	local FinalPos = CFrame.new(TargetCFrame.Position, TargetPosition)

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
	task.wait(0.5)

	if PlayerGui:FindFirstChild("Gen") then
		return true
	end
	
	return false
end

local function GetGeneratorsFolder()
	local Maps = workspace:FindFirstChild("MAPS")
	local GameMap = Maps and Maps:FindFirstChild("GAME MAP")
	return GameMap and GameMap:FindFirstChild("Generators")
end

local function StartGeneratorAutomation()
	local Offsets = {
		CFrame.new(0, 0, 5),
		CFrame.new(5, 0, 0),
		CFrame.new(-5, 0, 0)
	}

	while true do
		task.wait(1)
		
		local Generators = GetGeneratorsFolder()
		if not Generators then continue end

		local Character = LocalPlayer.Character
		if not Character or Character:GetAttribute("Team") ~= "Survivor" then continue end

		for _, Generator in ipairs(Generators:GetChildren()) do
			if not Generator:IsA("Model") then continue end
			
			local Progress = Generator:GetAttribute("Progress")
			local Primary = Generator.PrimaryPart

			if Progress and Progress < 100 and Primary then
				local Success = false
				
				for _, Offset in ipairs(Offsets) do
					Success = StealthTeleport(Primary, Offset)
					if Success then break end
					task.wait(0.5)
				end

				if Success then
					repeat
						task.wait(1)
						local CurrentFolder = GetGeneratorsFolder()
						if not CurrentFolder or not Generator:IsDescendantOf(CurrentFolder) or not PlayerGui:FindFirstChild("Gen") then break end
					until Generator:GetAttribute("Progress") >= 100
				end
				
				break
			end
		end
	end
end

task.spawn(StartGeneratorAutomation)
