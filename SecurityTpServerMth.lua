
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SCTFolder = workspace:WaitForChild("SCTParts")
local UtilsFolder = ReplicatedStorage:WaitForChild("Utils")
local RewardTemplate = UtilsFolder:WaitForChild("Reward")

local RemotesFolder = ReplicatedStorage:FindFirstChild("SCTRemotes")

if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "SCTRemotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local RewardVisualRemote = RemotesFolder:FindFirstChild("RewardVisual")

if not RewardVisualRemote then
	RewardVisualRemote = Instance.new("RemoteEvent")
	RewardVisualRemote.Name = "RewardVisual"
	RewardVisualRemote.Parent = RemotesFolder
end

local Config = {
	MinTimeToNext = {
		[1] = 0.5,
		[2] = 1,
		[3] = 1.5,
		[4] = 2,
	},

	RewardDelay = 5,
	TouchCooldown = 0.12,
	ScanInterval = 0.06,
	TeleportYOffset = 3,
	MaxActiveSpeed = 450,
	MovementGrace = 0.25,
}

local Checkpoints = {}
local PlayerState = {}
local PlayerTouchCooldown = {}
local RewardCooldown = {}

for Index = 1, 5 do
	local Part = SCTFolder:WaitForChild("SCT" .. Index)

	if not Part:IsA("BasePart") then
		error("SCT" .. Index .. " precisa ser uma BasePart.")
	end

	Checkpoints[Index] = Part
end

if not RewardTemplate:IsA("BasePart") then
	error("ReplicatedStorage.Utils.Reward precisa ser uma BasePart.")
end

local function getPlayerFromHit(Hit)
	local Character = Hit:FindFirstAncestorOfClass("Model")

	if not Character then
		return nil
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if not Humanoid then
		return nil
	end

	return Players:GetPlayerFromCharacter(Character)
end

local function getCharacterParts(Player)
	local Character = Player.Character

	if not Character then
		return nil
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local Root = Character:FindFirstChild("HumanoidRootPart")

	if not Humanoid or not Root or Humanoid.Health <= 0 then
		return nil
	end

	return Character, Humanoid, Root
end

local function getState(Player)
	local State = PlayerState[Player]

	if not State then
		State = {
			Stage = 0,
			LastCheckpointTime = 0,
			IgnoreMovementUntil = 0,
			LastScanPosition = nil,
			LastScanTime = 0,
			RewardVisible = false,
			RewardToken = 0,
		}

		PlayerState[Player] = State
	end

	return State
end

local function getSafePartCFrame(Part)
	local Position = Part.Position + Vector3.new(0, Part.Size.Y / 2 + Config.TeleportYOffset, 0)
	return CFrame.new(Position)
end

local function getSpawnCFrame()
	local Spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)

	if Spawn then
		return getSafePartCFrame(Spawn)
	end

	return CFrame.new(0, 8, 0)
end

local function getCheckpointCFrame(Index)
	local Part = Checkpoints[Index] or Checkpoints[1]
	return getSafePartCFrame(Part)
end

local function hideReward(Player)
	local State = getState(Player)

	State.RewardVisible = false
	State.RewardToken += 1

	RewardVisualRemote:FireClient(Player, "Hide")
end

local function showRewardAfterDelay(Player)
	local State = getState(Player)

	State.RewardToken += 1

	local Token = State.RewardToken

	task.delay(Config.RewardDelay, function()
		if not Player.Parent then
			return
		end

		local CurrentState = getState(Player)

		if CurrentState.RewardToken ~= Token then
			return
		end

		if CurrentState.Stage <= 0 then
			return
		end

		CurrentState.RewardVisible = true

		RewardVisualRemote:FireClient(Player, "Show")
	end)
end

local function teleportPlayer(Player, TargetCFrame)
	local Character, _, Root = getCharacterParts(Player)

	if not Character or not Root then
		return
	end

	local State = getState(Player)

	Character:PivotTo(TargetCFrame)

	Root.AssemblyLinearVelocity = Vector3.zero
	Root.AssemblyAngularVelocity = Vector3.zero

	State.IgnoreMovementUntil = os.clock() + Config.MovementGrace
	State.LastScanPosition = TargetCFrame.Position
	State.LastScanTime = os.clock()
end

local function resetProgress(Player)
	local State = getState(Player)

	State.Stage = 0
	State.LastCheckpointTime = 0
	State.IgnoreMovementUntil = os.clock() + Config.MovementGrace
	State.LastScanPosition = nil
	State.LastScanTime = 0

	hideReward(Player)
end

local function sendToSpawn(Player)
	resetProgress(Player)
	teleportPlayer(Player, getSpawnCFrame())
end

local function sendToCheckpoint(Player, Index)
	local State = getState(Player)
	local Now = os.clock()

	State.Stage = math.clamp(Index, 1, 5)
	State.LastCheckpointTime = Now

	teleportPlayer(Player, getCheckpointCFrame(State.Stage))
end

local function hasMovementSpike(Player, Position)
	local State = getState(Player)
	local Now = os.clock()

	if Now < State.IgnoreMovementUntil then
		return false
	end

	if not State.LastScanPosition or State.LastScanTime <= 0 then
		State.LastScanPosition = Position
		State.LastScanTime = Now
		return false
	end

	local DeltaTime = Now - State.LastScanTime

	if DeltaTime <= 0 then
		return false
	end

	local Distance = (Position - State.LastScanPosition).Magnitude
	local Speed = Distance / DeltaTime

	return Speed > Config.MaxActiveSpeed
end

local function canProcessTouch(Player, Index)
	local Now = os.clock()

	PlayerTouchCooldown[Player] = PlayerTouchCooldown[Player] or {}

	local LastTouch = PlayerTouchCooldown[Player][Index] or 0

	if Now - LastTouch < Config.TouchCooldown then
		return false
	end

	PlayerTouchCooldown[Player][Index] = Now

	return true
end

local function processCheckpoint(Player, Index)
	if not canProcessTouch(Player, Index) then
		return
	end

	local _, _, Root = getCharacterParts(Player)

	if not Root then
		return
	end

	local State = getState(Player)
	local Now = os.clock()

	if Index == 1 then
		State.Stage = 1
		State.LastCheckpointTime = Now
		State.LastScanPosition = Root.Position
		State.LastScanTime = Now

		hideReward(Player)
		showRewardAfterDelay(Player)

		return
	end

	if State.Stage <= 0 then
		sendToSpawn(Player)
		return
	end

	if hasMovementSpike(Player, Root.Position) then
		sendToCheckpoint(Player, State.Stage)
		return
	end

	if Index == State.Stage + 1 then
		local RequiredTime = Config.MinTimeToNext[State.Stage]

		if not RequiredTime then
			return
		end

		local Elapsed = Now - State.LastCheckpointTime

		if Elapsed < RequiredTime then
			sendToCheckpoint(Player, State.Stage)
			return
		end

		State.Stage = Index
		State.LastCheckpointTime = Now
		State.LastScanPosition = Root.Position
		State.LastScanTime = Now

		return
	end

	if Index > State.Stage + 1 then
		sendToCheckpoint(Player, State.Stage)
		return
	end
end

local function isInsideReward(Player)
	local _, _, Root = getCharacterParts(Player)

	if not Root then
		return false
	end

	local RewardCFrame = RewardTemplate.CFrame
	local RewardSize = RewardTemplate.Size + Vector3.new(5, 6, 5)

	local LocalPosition = RewardCFrame:PointToObjectSpace(Root.Position)

	return math.abs(LocalPosition.X) <= RewardSize.X / 2
		and math.abs(LocalPosition.Y) <= RewardSize.Y / 2
		and math.abs(LocalPosition.Z) <= RewardSize.Z / 2
end

local function processReward(Player)
	local Now = os.clock()
	local LastReward = RewardCooldown[Player] or 0

	if Now - LastReward < 0.5 then
		return
	end

	RewardCooldown[Player] = Now

	local State = getState(Player)

	if not State.RewardVisible then
		sendToSpawn(Player)
		return
	end

	if State.Stage < 5 then
		sendToSpawn(Player)
		return
	end

	resetProgress(Player)
end

for Index, Part in ipairs(Checkpoints) do
	Part.Touched:Connect(function(Hit)
		local Player = getPlayerFromHit(Hit)

		if Player then
			processCheckpoint(Player, Index)
		end
	end)
end

local OverlapParamsObject = OverlapParams.new()
OverlapParamsObject.FilterType = Enum.RaycastFilterType.Exclude
OverlapParamsObject.FilterDescendantsInstances = { SCTFolder }

local ScanAccumulator = 0

RunService.Heartbeat:Connect(function(DeltaTime)
	ScanAccumulator += DeltaTime

	if ScanAccumulator < Config.ScanInterval then
		return
	end

	ScanAccumulator = 0

	for Index, Part in ipairs(Checkpoints) do
		local Parts = workspace:GetPartBoundsInBox(Part.CFrame, Part.Size, OverlapParamsObject)
		local FoundPlayers = {}

		for _, Hit in ipairs(Parts) do
			local Player = getPlayerFromHit(Hit)

			if Player and not FoundPlayers[Player] then
				FoundPlayers[Player] = true
				processCheckpoint(Player, Index)
			end
		end
	end

	for Player, State in pairs(PlayerState) do
		local _, _, Root = getCharacterParts(Player)

		if Root then
			local Now = os.clock()

			if State.Stage > 0 then
				if Now >= State.IgnoreMovementUntil then
					if hasMovementSpike(Player, Root.Position) then
						sendToCheckpoint(Player, State.Stage)
					else
						State.LastScanPosition = Root.Position
						State.LastScanTime = Now
					end
				else
					State.LastScanPosition = Root.Position
					State.LastScanTime = Now
				end
			end

			if State.RewardVisible and isInsideReward(Player) then
				processReward(Player)
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function()
		task.wait(0.3)
		resetProgress(Player)
	end)
end)

Players.PlayerRemoving:Connect(function(Player)
	PlayerState[Player] = nil
	PlayerTouchCooldown[Player] = nil
	RewardCooldown[Player] = nil
end)
