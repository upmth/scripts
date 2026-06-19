local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UtilsFolder = ReplicatedStorage:WaitForChild("Utils")
local RewardTemplate = UtilsFolder:WaitForChild("Reward")
local RewardVisualRemote = ReplicatedStorage:WaitForChild("SCTRemotes"):WaitForChild("RewardVisual")

local RewardClone = nil

local function hideReward()
	if RewardClone then
		RewardClone:Destroy()
		RewardClone = nil
	end
end

local function showReward()
	hideReward()

	RewardClone = RewardTemplate:Clone()
	RewardClone.Name = "LocalReward"
	RewardClone.Anchored = true
	RewardClone.CanCollide = false
	RewardClone.CanTouch = false
	RewardClone.CanQuery = false
	RewardClone.Parent = workspace
end

RewardVisualRemote.OnClientEvent:Connect(function(Action)
	if Action == "Show" then
		showReward()
	elseif Action == "Hide" then
		hideReward()
	end
end)
