local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GeneratorAddedConnection = nil

local function StartGeneratorSolver()
	GeneratorAddedConnection = PlayerGui.ChildAdded:Connect(function(Child)
		if Child.Name == "Gen" then
			local GeneratorMain = Child:WaitForChild("GeneratorMain", 5)
			
			if GeneratorMain then
				local Event = GeneratorMain:WaitForChild("Event", 5)
				
				if Event and Event:IsA("RemoteEvent") then
					Event:FireServer("Completed")
				end
			end
		end
	end)
end

StartGeneratorSolver()
