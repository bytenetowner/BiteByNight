local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function StealthTeleport(TargetPart, SideOffset)
	local Character = LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	if not Root then return false end

	local TargetPos = TargetPart.Position
	local Distance = (Root.Position - TargetPos).Magnitude
	local MoveSpeed = 12
	local Duration = math.max(Distance / MoveSpeed, 2)

	local OffsetCFrame = SideOffset or CFrame.new(0, 0, 5) 
	local TargetCFrame = TargetPart.CFrame * OffsetCFrame
	
	local StartUnder = Root.CFrame * CFrame.new(0, -25, 0)
	local TargetUnder = TargetCFrame * CFrame.new(0, -20, 0)
	local FinalCFrame = CFrame.new(TargetCFrame.Position, TargetPos)

	local FastTween = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local SlowTween = TweenInfo.new(Duration, Enum.EasingStyle.Linear)

	local StepOne = TweenService:Create(Root, FastTween, {CFrame = StartUnder})
	StepOne:Play()
	StepOne.Completed:Wait()

	local StepTwo = TweenService:Create(Root, SlowTween, {CFrame = TargetUnder})
	StepTwo:Play()
	StepTwo.Completed:Wait()

	local StepThree = TweenService:Create(Root, FastTween, {CFrame = FinalCFrame})
	StepThree:Play()
	StepThree.Completed:Wait()
	
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

local function GetGenerators()
	local Maps = workspace:FindFirstChild("MAPS")
	local GameMap = Maps and Maps:FindFirstChild("GAME MAP")
	return GameMap and GameMap:FindFirstChild("Generators")
end

local function RunAutomation()
	local Positions = {
		CFrame.new(5, 0, 0),
		CFrame.new(-5, 0, 0),
		CFrame.new(0, 0, -5)
	}

	while true do
		task.wait(1)
		
		local Folder = GetGenerators()
		if not Folder then continue end

		local Character = LocalPlayer.Character
		if not Character or Character:GetAttribute("Team") ~= "Survivor" then continue end

		for _, Gen in ipairs(Folder:GetChildren()) do
			if not Gen:IsA("Model") then continue end
			
			local Progress = Gen:GetAttribute("Progress")
			local MainPart = Gen.PrimaryPart

			if Progress and Progress < 100 and MainPart then
				local Success = false
				
				for _, Offset in ipairs(Positions) do
					Success = StealthTeleport(MainPart, Offset)
					if Success then break end
					task.wait(0.5)
				end

				if Success then
					repeat
						task.wait(1)
						local CheckFolder = GetGenerators()
						if not CheckFolder or not Gen:IsDescendantOf(CheckFolder) or not PlayerGui:FindFirstChild("Gen") then break end
					until Gen:GetAttribute("Progress") >= 100
				end
				
				break
			end
		end
	end
end

task.spawn(RunAutomation)
