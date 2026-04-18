local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function GetGeneratorsFolder()
	local Maps = Workspace:FindFirstChild("MAPS")
	local GameMap = Maps and Maps:FindFirstChild("GAME MAP")
	return GameMap and GameMap:FindFirstChild("Generators")
end

local function FocusCameraOnTarget(TargetPart)
	if TargetPart then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPart.Position)
	end
end

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
				local TargetCFrame = MainPart.CFrame * CFrame.new(0, 5, 0)
				
				local MoveTween = TweenService:Create(Root, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {CFrame = TargetCFrame})
				MoveTween:Play()
				MoveTween.Completed:Wait()
				
				FocusCameraOnTarget(MainPart)
				
				task.wait(0.1)
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
				task.wait(2)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
				
				repeat
					task.wait(0.2)
					FocusCameraOnTarget(MainPart)
					if not Generator:IsDescendantOf(Folder) or Character:GetAttribute("Team") ~= "Survivor" then break end
				until Generator:GetAttribute("Progress") >= 100
				
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
				task.wait(0.5)
			end
		end
	end
end

task.spawn(RunGeneratorAutomation)
