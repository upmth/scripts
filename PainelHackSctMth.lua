local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if not RunService:IsStudio() then
	return
end

local Player = Players.LocalPlayer

local Config = {
	PointFolders = { "SecurityPoints", "SCTParts" },
	PointNames = {
		{ "Point1", "SCT1", "1" },
		{ "Point2", "SCT2", "2" },
		{ "Point3", "SCT3", "3" },
		{ "Point4", "SCT4", "4" },
		{ "Point5", "SCT5", "5" },
	},

	TeleportOffset = 3,
	BlinkDistance = 60,
	BurstPower = 180,
}

local SavedSlots = {
	A = nil,
	B = nil,
	C = nil,
}

local NoclipEnabled = false
local OriginalCollision = {}
local StatusLabel = nil
local PositionLabel = nil

local function setStatus(Text)
	if StatusLabel then
		StatusLabel.Text = Text
	end
end

local function getCharacterParts()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local Root = Character:WaitForChild("HumanoidRootPart")

	return Character, Humanoid, Root
end

local function clearVelocity()
	local _, _, Root = getCharacterParts()

	Root.AssemblyLinearVelocity = Vector3.zero
	Root.AssemblyAngularVelocity = Vector3.zero
end

local function safeTeleport(TargetCFrame)
	local Character, _, Root = getCharacterParts()

	Character:PivotTo(TargetCFrame + Vector3.new(0, Config.TeleportOffset, 0))

	Root.AssemblyLinearVelocity = Vector3.zero
	Root.AssemblyAngularVelocity = Vector3.zero
end

local function saveSlot(Slot)
	local _, _, Root = getCharacterParts()

	SavedSlots[Slot] = Root.CFrame
	setStatus("Slot " .. Slot .. " salvo")
end

local function teleportSlot(Slot)
	local SavedCFrame = SavedSlots[Slot]

	if not SavedCFrame then
		setStatus("Slot " .. Slot .. " vazio")
		return
	end

	safeTeleport(SavedCFrame)
	setStatus("TP para Slot " .. Slot)
end

local function findPoint(Index)
	for _, FolderName in ipairs(Config.PointFolders) do
		local Folder = workspace:FindFirstChild(FolderName)

		if Folder then
			for _, PointName in ipairs(Config.PointNames[Index]) do
				local Point = Folder:FindFirstChild(PointName)

				if Point and Point:IsA("BasePart") then
					return Point
				end
			end
		end
	end

	return nil
end

local function teleportPoint(Index)
	local Point = findPoint(Index)

	if not Point then
		setStatus("Point " .. Index .. " não encontrado")
		return
	end

	safeTeleport(Point.CFrame)
	setStatus("TP para Point " .. Index)
end

local function setSpeed(Value)
	local _, Humanoid = getCharacterParts()

	Humanoid.WalkSpeed = Value
	setStatus("Speed: " .. Value)
end

local function setJump(Value)
	local _, Humanoid = getCharacterParts()

	pcall(function()
		Humanoid.UseJumpPower = true
	end)

	Humanoid.JumpPower = Value
	setStatus("Jump: " .. Value)
end

local function blinkForward()
	local _, _, Root = getCharacterParts()
	local Target = Root.CFrame + Root.CFrame.LookVector * Config.BlinkDistance

	safeTeleport(Target)
	setStatus("Blink: " .. Config.BlinkDistance .. " studs")
end

local function burstForward()
	local _, _, Root = getCharacterParts()

	Root.AssemblyLinearVelocity = Root.CFrame.LookVector * Config.BurstPower
	setStatus("Burst: " .. Config.BurstPower)
end

local function respawn()
	local _, Humanoid = getCharacterParts()

	Humanoid.Health = 0
	setStatus("Respawn testado")
end

local function setNoclip(Value)
	NoclipEnabled = Value

	if not NoclipEnabled then
		for Part, OldValue in pairs(OriginalCollision) do
			if Part and Part.Parent then
				Part.CanCollide = OldValue
			end
		end

		OriginalCollision = {}
		setStatus("Noclip: OFF")
		return
	end

	setStatus("Noclip: ON")
end

RunService.Heartbeat:Connect(function()
	if PositionLabel then
		local _, _, Root = getCharacterParts()
		local Position = Root.Position

		PositionLabel.Text = string.format(
			"X %.1f | Y %.1f | Z %.1f",
			Position.X,
			Position.Y,
			Position.Z
		)
	end

	if not NoclipEnabled then
		return
	end

	local Character = Player.Character

	if not Character then
		return
	end

	for _, Object in ipairs(Character:GetDescendants()) do
		if Object:IsA("BasePart") then
			if OriginalCollision[Object] == nil then
				OriginalCollision[Object] = Object.CanCollide
			end

			Object.CanCollide = false
		end
	end
end)

Player.CharacterAdded:Connect(function()
	OriginalCollision = {}

	if NoclipEnabled then
		setStatus("Noclip mantido após respawn")
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SecurityTester"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(280, 420)
Main.Position = UDim2.fromOffset(24, 120)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(55, 55, 60)
Stroke.Thickness = 1
Stroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 31)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -48, 1, 0)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "Security Tester"
Title.TextColor3 = Color3.fromRGB(235, 235, 235)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextSize = 14
Title.Font = Enum.Font.GothamMedium
Title.Parent = Header

local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.fromOffset(28, 24)
HideButton.Position = UDim2.new(1, -34, 0.5, -12)
HideButton.BackgroundColor3 = Color3.fromRGB(40, 40, 44)
HideButton.BorderSizePixel = 0
HideButton.Text = "-"
HideButton.TextColor3 = Color3.fromRGB(230, 230, 230)
HideButton.TextSize = 16
HideButton.Font = Enum.Font.Gotham
HideButton.Parent = Header

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 5)
HideCorner.Parent = HideButton

local Body = Instance.new("ScrollingFrame")
Body.Size = UDim2.new(1, -16, 1, -48)
Body.Position = UDim2.fromOffset(8, 42)
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.ScrollBarThickness = 3
Body.CanvasSize = UDim2.fromOffset(0, 0)
Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 6)
List.SortOrder = Enum.SortOrder.LayoutOrder
List.Parent = Body

local function makeLabel(Text, Height)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0, Height or 24)
	Label.BackgroundTransparency = 1
	Label.Text = Text
	Label.TextColor3 = Color3.fromRGB(190, 190, 195)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextSize = 12
	Label.Font = Enum.Font.Gotham
	Label.Parent = Body

	return Label
end

StatusLabel = makeLabel("Ready", 24)
PositionLabel = makeLabel("X 0 | Y 0 | Z 0", 20)

local function createSection(Text)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0, 20)
	Label.BackgroundTransparency = 1
	Label.Text = Text
	Label.TextColor3 = Color3.fromRGB(150, 150, 155)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextSize = 11
	Label.Font = Enum.Font.GothamMedium
	Label.Parent = Body

	return Label
end

local function createRow()
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 30)
	Row.BackgroundTransparency = 1
	Row.Parent = Body

	local RowList = Instance.new("UIListLayout")
	RowList.FillDirection = Enum.FillDirection.Horizontal
	RowList.Padding = UDim.new(0, 6)
	RowList.SortOrder = Enum.SortOrder.LayoutOrder
	RowList.Parent = Row

	return Row
end

local function createButton(Parent, Text, Callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 1, 0)
	Button.BackgroundColor3 = Color3.fromRGB(35, 35, 39)
	Button.BorderSizePixel = 0
	Button.Text = Text
	Button.TextColor3 = Color3.fromRGB(235, 235, 235)
	Button.TextSize = 12
	Button.Font = Enum.Font.Gotham
	Button.AutoButtonColor = true
	Button.Parent = Parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 5)
	Corner.Parent = Button

	local ButtonStroke = Instance.new("UIStroke")
	ButtonStroke.Color = Color3.fromRGB(58, 58, 63)
	ButtonStroke.Thickness = 1
	ButtonStroke.Parent = Button

	Button.MouseButton1Click:Connect(Callback)

	return Button
end

local function createSplitButtons(LeftText, LeftCallback, RightText, RightCallback)
	local Row = createRow()

	local LeftHolder = Instance.new("Frame")
	LeftHolder.Size = UDim2.new(0.5, -3, 1, 0)
	LeftHolder.BackgroundTransparency = 1
	LeftHolder.Parent = Row

	local RightHolder = Instance.new("Frame")
	RightHolder.Size = UDim2.new(0.5, -3, 1, 0)
	RightHolder.BackgroundTransparency = 1
	RightHolder.Parent = Row

	createButton(LeftHolder, LeftText, LeftCallback)
	createButton(RightHolder, RightText, RightCallback)
end

createSection("Positions")

createSplitButtons("Save A", function()
	saveSlot("A")
end, "Go A", function()
	teleportSlot("A")
end)

createSplitButtons("Save B", function()
	saveSlot("B")
end, "Go B", function()
	teleportSlot("B")
end)

createSplitButtons("Save C", function()
	saveSlot("C")
end, "Go C", function()
	teleportSlot("C")
end)

createSection("Points")

createSplitButtons("P1", function()
	teleportPoint(1)
end, "P2", function()
	teleportPoint(2)
end)

createSplitButtons("P3", function()
	teleportPoint(3)
end, "P4", function()
	teleportPoint(4)
end)

local PointRow = createRow()
createButton(PointRow, "P5", function()
	teleportPoint(5)
end)

createSection("Movement")

createSplitButtons("Speed 16", function()
	setSpeed(16)
end, "Speed 80", function()
	setSpeed(80)
end)

createSplitButtons("Speed 160", function()
	setSpeed(160)
end, "Speed 300", function()
	setSpeed(300)
end)

createSplitButtons("Jump 50", function()
	setJump(50)
end, "Jump 120", function()
	setJump(120)
end)

createSplitButtons("Blink", blinkForward, "Burst", burstForward)

createSection("Tools")

createSplitButtons("Clear Vel", function()
	clearVelocity()
	setStatus("Velocity cleared")
end, "Respawn", respawn)

local NoclipButton
local NoclipRow = createRow()

NoclipButton = createButton(NoclipRow, "Noclip OFF", function()
	setNoclip(not NoclipEnabled)
	NoclipButton.Text = NoclipEnabled and "Noclip ON" or "Noclip OFF"
end)

local Minimized = false

HideButton.MouseButton1Click:Connect(function()
	Minimized = not Minimized
	Body.Visible = not Minimized

	if Minimized then
		Main.Size = UDim2.fromOffset(280, 36)
		HideButton.Text = "+"
	else
		Main.Size = UDim2.fromOffset(280, 420)
		HideButton.Text = "-"
	end
end)

local Dragging = false
local DragStart = nil
local StartPosition = nil

Header.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = Input.Position
		StartPosition = Main.Position
	end
end)

Header.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		Dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(Input)
	if not Dragging then
		return
	end

	if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local Delta = Input.Position - DragStart

	Main.Position = UDim2.new(
		StartPosition.X.Scale,
		StartPosition.X.Offset + Delta.X,
		StartPosition.Y.Scale,
		StartPosition.Y.Offset + Delta.Y
	)
end)

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
	if GameProcessed then
		return
	end

	if Input.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

local function createRow()
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 34)
	Row.BackgroundTransparency = 1
	Row.Parent = Body

	local RowList = Instance.new("UIListLayout")
	RowList.FillDirection = Enum.FillDirection.Horizontal
	RowList.Padding = UDim.new(0, 6)
	RowList.SortOrder = Enum.SortOrder.LayoutOrder
	RowList.Parent = Row

	return Row
end

local function createButton(Parent, Text, Callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 1, 0)
	Button.BackgroundColor3 = Color3.fromRGB(34, 37, 49)
	Button.BorderSizePixel = 0
	Button.Text = Text
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.TextScaled = true
	Button.Font = Enum.Font.GothamSemibold
	Button.AutoButtonColor = true
	Button.Parent = Parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Button

	Button.MouseButton1Click:Connect(Callback)

	return Button
end

local function createSplitButtons(LeftText, LeftCallback, RightText, RightCallback)
	local Row = createRow()

	local LeftHolder = Instance.new("Frame")
	LeftHolder.Size = UDim2.new(0.5, -3, 1, 0)
	LeftHolder.BackgroundTransparency = 1
	LeftHolder.Parent = Row

	local RightHolder = Instance.new("Frame")
	RightHolder.Size = UDim2.new(0.5, -3, 1, 0)
	RightHolder.BackgroundTransparency = 1
	RightHolder.Parent = Row

	createButton(LeftHolder, LeftText, LeftCallback)
	createButton(RightHolder, RightText, RightCallback)
end

createSection("Saved positions")

createSplitButtons("Save A", function()
	saveSlot("A")
end, "TP A", function()
	teleportSlot("A")
end)

createSplitButtons("Save B", function()
	saveSlot("B")
end, "TP B", function()
	teleportSlot("B")
end)

createSplitButtons("Save C", function()
	saveSlot("C")
end, "TP C", function()
	teleportSlot("C")
end)

createSection("Security points")

createSplitButtons("Point 1", function()
	teleportPoint(1)
end, "Point 2", function()
	teleportPoint(2)
end)

createSplitButtons("Point 3", function()
	teleportPoint(3)
end, "Point 4", function()
	teleportPoint(4)
end)

local PointRow = createRow()
createButton(PointRow, "Point 5", function()
	teleportPoint(5)
end)

createSection("Movement tests")

createSplitButtons("Speed 16", function()
	setSpeed(16)
end, "Speed 80", function()
	setSpeed(80)
end)

createSplitButtons("Speed 160", function()
	setSpeed(160)
end, "Speed 300", function()
	setSpeed(300)
end)

createSplitButtons("Jump 50", function()
	setJump(50)
end, "Jump 120", function()
	setJump(120)
end)

createSplitButtons("Blink", blinkForward, "Burst", burstForward)

createSection("Debug")

createSplitButtons("Clear velocity", function()
	clearVelocity()
	setStatus("Velocidade zerada")
end, "Respawn", respawn)

local NoclipButton

local NoclipRow = createRow()

NoclipButton = createButton(NoclipRow, "Noclip: OFF", function()
	setNoclip(not NoclipEnabled)
	NoclipButton.Text = NoclipEnabled and "Noclip: ON" or "Noclip: OFF"
end)

local Minimized = false

HideButton.MouseButton1Click:Connect(function()
	Minimized = not Minimized

	Body.Visible = not Minimized

	if Minimized then
		Main.Size = UDim2.fromOffset(310, 42)
		HideButton.Text = "+"
	else
		Main.Size = UDim2.fromOffset(310, 460)
		HideButton.Text = "-"
	end
end)

local Dragging = false
local DragStart = nil
local StartPosition = nil

Header.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = Input.Position
		StartPosition = Main.Position
	end
end)

Header.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		Dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(Input)
	if not Dragging then
		return
	end

	if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local Delta = Input.Position - DragStart

	Main.Position = UDim2.new(
		StartPosition.X.Scale,
		StartPosition.X.Offset + Delta.X,
		StartPosition.Y.Scale,
		StartPosition.Y.Offset + Delta.Y
	)
end)

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
	if GameProcessed then
		return
	end

	if Input.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)
