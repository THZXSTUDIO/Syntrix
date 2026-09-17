--========================================================--
-- Syntrix System (Speed + Aimbot MEGABRAIN)
-- Player = Speed | Combat = Aimbot
--========================================================--

---------------- SERVIÇOS ----------------
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

----------------======== SPEED ========----------------
local VelocidadeBase   = 17
local VelocidadeBoost  = 24
local VelocidadeAr     = 20
local StrafePower      = 9
local DistanciaBoost   = 50
local Suavizacao       = 0.18

local Estados = {
	LoopForce      = false,
	BoostDistancia = false,
	AirControl     = false,
	Strafe         = false,
	Suavizacao     = true,
	RespawnProtect = true,
	FiltroAlvo     = "Todos"
}

local CurrentSpeed = VelocidadeBase
local Character, Humanoid, RootPart
local HeartbeatConn
local MenuAberto = false
local ActiveSlider, Sliding = nil, false

----------------======== AIMBOT ========----------------
local AimbotAtivo, AimbotKey, WaitingBind, HoldRMB = false, nil, false, false
local PartAimbotAtivo, PartAimbotKey, WaitingPartBind, PartHoldRMB = false, nil, false, false
local SelectedParts, LiveTargets, AimOffset = {}, {}, Vector3.new(0,0,0)
local Connections, ExplorerOpen, MultiSelectMode, HeadFindMode, Expanded = {}, false, false, false, {}
local FrameCount, CachedClosest, LastClean = 0, nil, 0
local FOV, Smooth, TeamCheck, ShowFOV, DeathProtect = 90, 5, true, true, true

---------------- CÍRCULO FOV ----------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = FOV
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(0, 170, 255)
FOVCircle.Visible = true

---------------- GUI PRINCIPAL (SYNTRIX) ----------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SyntrixSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 48, 0, 48)
Icon.Position = UDim2.new(0.02, 0, 0.4, 0)
Icon.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Icon.Text = "S"
Icon.TextColor3 = Color3.fromRGB(0, 170, 255)
Icon.Font = Enum.Font.GothamBold
Icon.TextSize = 20
Icon.AutoButtonColor = false
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", Icon).Color = Color3.fromRGB(0, 140, 220)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 580)
Main.Position = UDim2.new(0.02, 0, 0.12, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 45)

local Title = Instance.new("TextButton")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Title.Text = "   Syntrix System"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.AutoButtonColor = false
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 14)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 38, 0, 38)
MinBtn.Position = UDim2.new(1, -38, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.Parent = Main

local TabPlayer = Instance.new("TextButton")
TabPlayer.Size = UDim2.new(0.5, -6, 0, 30)
TabPlayer.Position = UDim2.new(0, 6, 0, 44)
TabPlayer.BackgroundColor3 = Color3.fromRGB(0, 130, 85)
TabPlayer.Text = "Player"
TabPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
TabPlayer.Font = Enum.Font.GothamMedium
TabPlayer.TextSize = 13
TabPlayer.Parent = Main
Instance.new("UICorner", TabPlayer).CornerRadius = UDim.new(0, 8)

local TabCombat = Instance.new("TextButton")
TabCombat.Size = UDim2.new(0.5, -6, 0, 30)
TabCombat.Position = UDim2.new(0.5, 0, 0, 44)
TabCombat.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabCombat.Text = "Combat"
TabCombat.TextColor3 = Color3.fromRGB(160, 160, 160)
TabCombat.Font = Enum.Font.GothamMedium
TabCombat.TextSize = 13
TabCombat.Parent = Main
Instance.new("UICorner", TabCombat).CornerRadius = UDim.new(0, 8)

local PlayerFrame = Instance.new("ScrollingFrame")
PlayerFrame.Size = UDim2.new(1, -12, 1, -86)
PlayerFrame.Position = UDim2.new(0, 6, 0, 80)
PlayerFrame.BackgroundTransparency = 1
PlayerFrame.BorderSizePixel = 0
PlayerFrame.ScrollBarThickness = 3
PlayerFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
PlayerFrame.CanvasSize = UDim2.new(0, 0, 0, 620)
PlayerFrame.Parent = Main

local CombatFrame = Instance.new("ScrollingFrame")
CombatFrame.Size = UDim2.new(1, -12, 1, -86)
CombatFrame.Position = UDim2.new(0, 6, 0, 80)
CombatFrame.BackgroundTransparency = 1
CombatFrame.BorderSizePixel = 0
CombatFrame.ScrollBarThickness = 3
CombatFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
CombatFrame.CanvasSize = UDim2.new(0, 0, 0, 720)
CombatFrame.Visible = false
CombatFrame.Parent = Main

-- Abrir / Minimizar
local function AbrirMenu()
	MenuAberto = true
	Icon.Visible = false
	Main.Visible = true
end
local function Minimizar()
	MenuAberto = false
	Main.Visible = false
	Icon.Visible = true
end
Icon.MouseButton1Click:Connect(AbrirMenu)
MinBtn.MouseButton1Click:Connect(Minimizar)

-- Arrastar
local dragging, dragStart, startPos
local function StartDrag(input, frame)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end
Title.InputBegan:Connect(function(input) StartDrag(input, Main) end)
Icon.InputBegan:Connect(function(input) StartDrag(input, Icon) end)

UIS.InputChanged:Connect(function(input)
	if dragging and not Sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		local target = MenuAberto and Main or Icon
		target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
		Sliding = false
		ActiveSlider = nil
	end
end)

-- Abas
TabPlayer.MouseButton1Click:Connect(function()
	PlayerFrame.Visible = true
	CombatFrame.Visible = false
	TabPlayer.BackgroundColor3 = Color3.fromRGB(0, 130, 85)
	TabPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
	TabCombat.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	TabCombat.TextColor3 = Color3.fromRGB(160, 160, 160)
end)
TabCombat.MouseButton1Click:Connect(function()
	PlayerFrame.Visible = false
	CombatFrame.Visible = true
	TabCombat.BackgroundColor3 = Color3.fromRGB(0, 130, 85)
	TabCombat.TextColor3 = Color3.fromRGB(255, 255, 255)
	TabPlayer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	TabPlayer.TextColor3 = Color3.fromRGB(160, 160, 160)
end)

----------------======== PLAYER (SPEED) ========----------------
local function CreateCheckbox(parent, nome, y, key)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 292, 0, 32)
	btn.Position = UDim2.new(0, 6, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local box = Instance.new("Frame")
	box.Size = UDim2.new(0, 18, 0, 18)
	box.Position = UDim2.new(0, 12, 0.5, -9)
	box.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	box.BorderSizePixel = 0
	box.Parent = btn
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

	local mark = Instance.new("Frame")
	mark.Size = UDim2.new(0, 10, 0, 10)
	mark.Position = UDim2.new(0.5, -5, 0.5, -5)
	mark.BackgroundColor3 = Color3.fromRGB(0, 220, 130)
	mark.BorderSizePixel = 0
	mark.Visible = false
	mark.Parent = box
	Instance.new("UICorner", mark).CornerRadius = UDim.new(0, 3)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -44, 1, 0)
	label.Position = UDim2.new(0, 40, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = nome
	label.TextColor3 = Color3.fromRGB(230, 230, 230)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = btn

	btn.MouseButton1Click:Connect(function()
		Estados[key] = not Estados[key]
		mark.Visible = Estados[key]
		box.BackgroundColor3 = Estados[key] and Color3.fromRGB(0, 90, 60) or Color3.fromRGB(55, 55, 55)
		btn.BackgroundColor3 = Estados[key] and Color3.fromRGB(28, 48, 40) or Color3.fromRGB(32, 32, 32)
	end)
end

CreateCheckbox(PlayerFrame, "Loop Force", 10, "LoopForce")
CreateCheckbox(PlayerFrame, "Boost por Distância", 48, "BoostDistancia")
CreateCheckbox(PlayerFrame, "Air Control", 86, "AirControl")
CreateCheckbox(PlayerFrame, "Strafe", 124, "Strafe")
CreateCheckbox(PlayerFrame, "Suavização", 162, "Suavizacao")
CreateCheckbox(PlayerFrame, "Proteção Respawn", 200, "RespawnProtect")

local FiltroLabel = Instance.new("TextLabel")
FiltroLabel.Size = UDim2.new(1, -20, 0, 18)
FiltroLabel.Position = UDim2.new(0, 10, 0, 248)
FiltroLabel.BackgroundTransparency = 1
FiltroLabel.Text = "Filtro: Todos"
FiltroLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
FiltroLabel.Font = Enum.Font.Gotham
FiltroLabel.TextSize = 12
FiltroLabel.TextXAlignment = Enum.TextXAlignment.Left
FiltroLabel.Parent = PlayerFrame

local Filtros = {"Todos", "Inimigos", "Amigos", "MaisProximo"}
local FiltroIndex = 1
local FiltroBtn = Instance.new("TextButton")
FiltroBtn.Size = UDim2.new(0, 292, 0, 30)
FiltroBtn.Position = UDim2.new(0, 6, 0, 270)
FiltroBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FiltroBtn.Text = "Trocar Filtro"
FiltroBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FiltroBtn.Font = Enum.Font.Gotham
FiltroBtn.TextSize = 12
FiltroBtn.Parent = PlayerFrame
Instance.new("UICorner", FiltroBtn).CornerRadius = UDim.new(0, 8)
FiltroBtn.MouseButton1Click:Connect(function()
	FiltroIndex = FiltroIndex % #Filtros + 1
	Estados.FiltroAlvo = Filtros[FiltroIndex]
	FiltroLabel.Text = "Filtro: " .. Estados.FiltroAlvo
end)

local function CreateSlider(parent, nome, y, min, max, default, callback)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 16)
	label.Position = UDim2.new(0, 10, 0, y)
	label.BackgroundTransparency = 1
	label.Text = nome .. ": " .. default
	label.TextColor3 = Color3.fromRGB(190, 190, 190)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(0, 292, 0, 12)
	bg.Position = UDim2.new(0, 6, 0, y + 20)
	bg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	bg.BorderSizePixel = 0
	bg.Parent = parent
	Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	fill.BorderSizePixel = 0
	fill.Parent = bg
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.new(0, 18, 0, 18)
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	thumb.BorderSizePixel = 0
	thumb.Parent = bg
	Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

	local data = {bg = bg, fill = fill, thumb = thumb, label = label, min = min, max = max, callback = callback, nome = nome}
	local function beginSlide(input)
		Sliding = true
		ActiveSlider = data
		local rel = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (max - min) * rel + 0.5)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		thumb.Position = UDim2.new(rel, 0, 0.5, 0)
		label.Text = nome .. ": " .. value
		callback(value)
	end
	bg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then beginSlide(input) end
	end)
	thumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then beginSlide(input) end
	end)
end

CreateSlider(PlayerFrame, "Velocidade Base", 320, 8, 45, VelocidadeBase, function(v) VelocidadeBase = v end)
CreateSlider(PlayerFrame, "Velocidade Ar", 370, 8, 55, VelocidadeAr, function(v) VelocidadeAr = v end)
CreateSlider(PlayerFrame, "Strafe Power", 420, 0, 25, StrafePower, function(v) StrafePower = v end)
CreateSlider(PlayerFrame, "Distância Boost", 470, 10, 150, DistanciaBoost, function(v) DistanciaBoost = v end)
CreateSlider(PlayerFrame, "Velocidade Boost", 520, 10, 55, VelocidadeBoost, function(v) VelocidadeBoost = v end)

UIS.InputChanged:Connect(function(input)
	if Sliding and ActiveSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local rel = math.clamp((input.Position.X - ActiveSlider.bg.AbsolutePosition.X) / ActiveSlider.bg.AbsoluteSize.X, 0, 1)
		local value = math.floor(ActiveSlider.min + (ActiveSlider.max - ActiveSlider.min) * rel + 0.5)
		ActiveSlider.fill.Size = UDim2.new(rel, 0, 1, 0)
		ActiveSlider.thumb.Position = UDim2.new(rel, 0, 0.5, 0)
		ActiveSlider.label.Text = ActiveSlider.nome .. ": " .. value
		ActiveSlider.callback(value)
	end
end)

----------------======== COMBAT (AIMBOT MEGABRAIN) ========----------------
local function MakeButton(text, y, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 292, 0, 26)
	btn.Position = UDim2.new(0, 6, 0, y)
	btn.BackgroundColor3 = color or Color3.fromRGB(45, 45, 45)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 12
	btn.Parent = CombatFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local function MakeLabel(text, y)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -20, 0, 16)
	lbl.Position = UDim2.new(0, 10, 0, y)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = CombatFrame
	return lbl
end

local function CreateSmallBtn(text, x, y, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 22)
	btn.Position = UDim2.new(0, x, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 11
	btn.Parent = CombatFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
	btn.MouseButton1Click:Connect(callback)
end

-- Seção Aimbot Normal
local Sec1 = Instance.new("TextLabel")
Sec1.Size = UDim2.new(1, 0, 0, 18)
Sec1.Position = UDim2.new(0, 0, 0, 4)
Sec1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Sec1.Text = "  AIMBOT NORMAL (Players)"
Sec1.TextColor3 = Color3.fromRGB(100, 200, 255)
Sec1.Font = Enum.Font.GothamBold
Sec1.TextSize = 11
Sec1.TextXAlignment = Enum.TextXAlignment.Left
Sec1.Parent = CombatFrame

local ToggleBtn = MakeButton("Aimbot: OFF", 26)
local function AtualizarToggle()
	ToggleBtn.Text = AimbotAtivo and "Aimbot: ON" or "Aimbot: OFF"
	ToggleBtn.BackgroundColor3 = AimbotAtivo and Color3.fromRGB(0, 130, 70) or Color3.fromRGB(50, 50, 50)
end

local BindBtn = MakeButton("Bind: None", 56)
local HoldRMBBtn = MakeButton("Hold RMB: OFF", 86)

MakeLabel("FOV / Smooth / Círculo", 118)
CreateSmallBtn("FOV20", 6, 138, function() FOV = 20 FOVCircle.Radius = 20 end)
CreateSmallBtn("FOV90", 104, 138, function() FOV = 90 FOVCircle.Radius = 90 end)
CreateSmallBtn("FOV180", 202, 138, function() FOV = 180 FOVCircle.Radius = 180 end)
CreateSmallBtn("S1", 6, 165, function() Smooth = 1 end)
CreateSmallBtn("S5", 104, 165, function() Smooth = 5 end)
CreateSmallBtn("S12", 202, 165, function() Smooth = 12 end)

local TeamBtn = MakeButton("Team Check: ON", 195, Color3.fromRGB(0, 100, 60))
local CircleBtn = MakeButton("Círculo FOV: ON", 225, Color3.fromRGB(0, 100, 60))
local DeathBtn = MakeButton("Death Protect: ON", 255, Color3.fromRGB(0, 100, 60))

-- Seção Part Aimbot
local Sec2 = Instance.new("TextLabel")
Sec2.Size = UDim2.new(1, 0, 0, 18)
Sec2.Position = UDim2.new(0, 0, 0, 295)
Sec2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Sec2.Text = "  PART AIMBOT (MEGABRAIN)"
Sec2.TextColor3 = Color3.fromRGB(100, 255, 150)
Sec2.Font = Enum.Font.GothamBold
Sec2.TextSize = 11
Sec2.TextXAlignment = Enum.TextXAlignment.Left
Sec2.Parent = CombatFrame

local PartToggleBtn = MakeButton("Part Aimbot: OFF", 317)
local function AtualizarPartToggle()
	PartToggleBtn.Text = PartAimbotAtivo and "Part Aimbot: ON" or "Part Aimbot: OFF"
	PartToggleBtn.BackgroundColor3 = PartAimbotAtivo and Color3.fromRGB(0, 130, 70) or Color3.fromRGB(50, 50, 50)
end

local PartBindBtn = MakeButton("Part Bind: None", 347)
local PartHoldRMBBtn = MakeButton("Part Hold RMB: OFF", 377)
local DirectoryBtn = MakeButton("Abrir Explorer", 407)

local OffsetLabel = MakeLabel("Offset → X: 0.0   Y: 0.0", 440)
CreateSmallBtn("X+", 6, 460, function() AimOffset = AimOffset + Vector3.new(0.5,0,0) OffsetLabel.Text = string.format("Offset → X: %.1f   Y: %.1f", AimOffset.X, AimOffset.Y) end)
CreateSmallBtn("X-", 104, 460, function() AimOffset = AimOffset - Vector3.new(0.5,0,0) OffsetLabel.Text = string.format("Offset → X: %.1f   Y: %.1f", AimOffset.X, AimOffset.Y) end)
CreateSmallBtn("Y+", 202, 460, function() AimOffset = AimOffset + Vector3.new(0,0.5,0) OffsetLabel.Text = string.format("Offset → X: %.1f   Y: %.1f", AimOffset.X, AimOffset.Y) end)
CreateSmallBtn("Y-", 6, 487, function() AimOffset = AimOffset - Vector3.new(0,0.5,0) OffsetLabel.Text = string.format("Offset → X: %.1f   Y: %.1f", AimOffset.X, AimOffset.Y) end)

local ResetOffsetBtn = MakeButton("Reset Offset", 517)

MakeLabel("Regras Ativas:", 550)
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Size = UDim2.new(0, 292, 0, 100)
ListFrame.Position = UDim2.new(0, 6, 0, 570)
ListFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
ListFrame.BorderSizePixel = 0
ListFrame.ScrollBarThickness = 5
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.Parent = CombatFrame
Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)
local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 4)
ListLayout.Parent = ListFrame

---------------- EXPLORER (igual original) ----------------
local Explorer = Instance.new("Frame")
Explorer.Size = UDim2.new(0, 360, 0, 500)
Explorer.Position = UDim2.new(0.30, 0, 0.15, 0)
Explorer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Explorer.BorderSizePixel = 0
Explorer.Visible = false
Explorer.Active = true
Explorer.Draggable = true
Explorer.Parent = ScreenGui
Instance.new("UICorner", Explorer).CornerRadius = UDim.new(0, 10)

local ExpTitle = Instance.new("TextLabel")
ExpTitle.Size = UDim2.new(1, -40, 0, 28)
ExpTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ExpTitle.Text = "  Explorer (MEGABRAIN)"
ExpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ExpTitle.Font = Enum.Font.GothamBold
ExpTitle.TextSize = 13
ExpTitle.TextXAlignment = Enum.TextXAlignment.Left
ExpTitle.Parent = Explorer
Instance.new("UICorner", ExpTitle).CornerRadius = UDim.new(0, 10)

local ExpClose = Instance.new("TextButton")
ExpClose.Size = UDim2.new(0, 32, 0, 28)
ExpClose.Position = UDim2.new(1, -36, 0, 0)
ExpClose.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
ExpClose.Text = "X"
ExpClose.TextColor3 = Color3.fromRGB(255, 255, 255)
ExpClose.Font = Enum.Font.GothamBold
ExpClose.TextSize = 14
ExpClose.Parent = Explorer
Instance.new("UICorner", ExpClose).CornerRadius = UDim.new(0, 8)

local MultiBtn = Instance.new("TextButton")
MultiBtn.Size = UDim2.new(0, 130, 0, 26)
MultiBtn.Position = UDim2.new(0, 10, 0, 35)
MultiBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MultiBtn.Text = "Multi Select: OFF"
MultiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MultiBtn.Font = Enum.Font.Gotham
MultiBtn.TextSize = 12
MultiBtn.Parent = Explorer
Instance.new("UICorner", MultiBtn).CornerRadius = UDim.new(0, 6)

local HeadFindBtn = Instance.new("TextButton")
HeadFindBtn.Size = UDim2.new(0, 130, 0, 26)
HeadFindBtn.Position = UDim2.new(0, 150, 0, 35)
HeadFindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HeadFindBtn.Text = "Head Find: OFF"
HeadFindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HeadFindBtn.Font = Enum.Font.Gotham
HeadFindBtn.TextSize = 12
HeadFindBtn.Parent = Explorer
Instance.new("UICorner", HeadFindBtn).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 18)
StatusLabel.Position = UDim2.new(0, 10, 0, 68)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Pronto"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Explorer

local TreeFrame = Instance.new("ScrollingFrame")
TreeFrame.Size = UDim2.new(1, -20, 1, -100)
TreeFrame.Position = UDim2.new(0, 10, 0, 90)
TreeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TreeFrame.BorderSizePixel = 0
TreeFrame.ScrollBarThickness = 6
TreeFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
TreeFrame.Parent = Explorer
Instance.new("UICorner", TreeFrame).CornerRadius = UDim.new(0, 6)
local TreeLayout = Instance.new("UIListLayout")
TreeLayout.SortOrder = Enum.SortOrder.LayoutOrder
TreeLayout.Padding = UDim.new(0, 1)
TreeLayout.Parent = TreeFrame

---------------- CORE AIMBOT (ORIGINAL) ----------------
local function ClearAllConnections()
	for _, conn in pairs(Connections) do pcall(function() conn:Disconnect() end) end
	Connections = {}
end
local function ClearAllSelected()
	ClearAllConnections()
	SelectedParts = {}
	LiveTargets = {}
	CachedClosest = nil
end
local function IsValidTarget(part)
	return part and part.Parent and part:IsDescendantOf(workspace)
end
local function AddLiveTarget(part)
	if not IsValidTarget(part) then return end
	for i = 1, #LiveTargets do if LiveTargets[i] == part then return end end
	table.insert(LiveTargets, part)
end
local function RemoveDeadTargets()
	local now = tick()
	if now - LastClean < 1.2 then return end
	LastClean = now
	local newList = {}
	for i = 1, #LiveTargets do
		if IsValidTarget(LiveTargets[i]) then table.insert(newList, LiveTargets[i]) end
	end
	LiveTargets = newList
	if CachedClosest and not IsValidTarget(CachedClosest) then CachedClosest = nil end
end
local function SetupRule(rule)
	if not rule or not rule.smartRoot or not rule.smartRoot.Parent then return end
	local ok, descendants = pcall(function() return rule.smartRoot:GetDescendants() end)
	if ok and descendants then
		for _, obj in pairs(descendants) do
			if obj:IsA("BasePart") and obj.Name == rule.partName then
				if rule.parentName == "" or (obj.Parent and obj.Parent.Name == rule.parentName) then
					AddLiveTarget(obj)
				end
			end
		end
	end
	local conn = rule.smartRoot.DescendantAdded:Connect(function(obj)
		if obj:IsA("BasePart") and obj.Name == rule.partName then
			if rule.parentName == "" or (obj.Parent and obj.Parent.Name == rule.parentName) then
				AddLiveTarget(obj)
			end
		end
	end)
	table.insert(Connections, conn)
end
local function RefreshListUI()
	for _, child in pairs(ListFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
	for i, data in ipairs(SelectedParts) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -10, 0, 26)
		row.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
		row.BorderSizePixel = 0
		row.Parent = ListFrame
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -40, 1, 0)
		nameLabel.Position = UDim2.new(0, 8, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = (data.parentName ~= "" and data.parentName .. " > " or "") .. data.partName
		nameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextSize = 11
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = row

		local removeBtn = Instance.new("TextButton")
		removeBtn.Size = UDim2.new(0, 24, 0, 20)
		removeBtn.Position = UDim2.new(1, -28, 0, 3)
		removeBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
		removeBtn.Text = "X"
		removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		removeBtn.Font = Enum.Font.GothamBold
		removeBtn.TextSize = 12
		removeBtn.Parent = row
		Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 4)
		removeBtn.MouseButton1Click:Connect(function()
			table.remove(SelectedParts, i)
			ClearAllConnections()
			LiveTargets = {}
			CachedClosest = nil
			for _, r in ipairs(SelectedParts) do SetupRule(r) end
			RefreshListUI()
		end)
	end
	ListFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(#SelectedParts * 30, 100))
end
local function DoHeadFind(folder)
	if not folder or not folder.Parent then return end
	ClearAllSelected()
	local rule = {partName = "Head", parentName = "", smartRoot = folder}
	table.insert(SelectedParts, rule)
	SetupRule(rule)
	RefreshListUI()
	StatusLabel.Text = "Head Find: " .. folder.Name
	StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
	HeadFindMode = false
	HeadFindBtn.Text = "Head Find: OFF"
	HeadFindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end

local function BuildTree()
	for _, child in pairs(TreeFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
	local function CreateItem(obj, depth)
		local isContainer = obj:IsA("Folder") or obj:IsA("Model") or obj:IsA("Configuration") or obj == workspace
		local isPart = obj:IsA("BasePart")
		local prefix = string.rep("   ", depth)
		local icon = isContainer and "📁 " or (isPart and "📦 " or "📄 ")
		local item = Instance.new("TextButton")
		item.Size = UDim2.new(1, -8, 0, 22)
		item.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		item.Text = prefix .. icon .. obj.Name
		item.TextColor3 = Color3.fromRGB(220, 220, 220)
		item.Font = Enum.Font.Gotham
		item.TextSize = 12
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.Parent = TreeFrame
		Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)
		item.MouseButton1Click:Connect(function()
			if HeadFindMode and isContainer then DoHeadFind(obj) return end
			if MultiSelectMode and isPart then
				local parentName = obj.Parent and obj.Parent.Name or ""
				local already = false
				for _, d in ipairs(SelectedParts) do
					if d.partName == obj.Name and d.parentName == parentName then already = true break end
				end
				if not already then
					local rule = {partName = obj.Name, parentName = parentName, smartRoot = obj.Parent and obj.Parent.Parent or workspace}
					table.insert(SelectedParts, rule)
					SetupRule(rule)
					RefreshListUI()
				end
			end
		end)
		if isContainer then
			item.MouseButton2Click:Connect(function()
				local key = obj:GetFullName()
				if Expanded[key] then Expanded[key] = nil else Expanded[key] = true end
				BuildTree()
			end)
		end
	end
	local function AddChildren(parent, depth)
		local children = {}
		pcall(function() for _, c in pairs(parent:GetChildren()) do table.insert(children, c) end end)
		table.sort(children, function(a, b) return a.Name:lower() < b.Name:lower() end)
		for _, child in ipairs(children) do
			CreateItem(child, depth)
			if Expanded[child:GetFullName()] then AddChildren(child, depth + 1) end
		end
	end
	CreateItem(workspace, 0)
	if Expanded[workspace:GetFullName()] then AddChildren(workspace, 1) end
	TreeFrame.CanvasSize = UDim2.new(0, 0, 0, TreeLayout.AbsoluteContentSize.Y + 30)
end

local function IsDead()
	local char = LocalPlayer.Character
	if not char then return true end
	local hum = char:FindFirstChildOfClass("Humanoid")
	return not hum or hum.Health <= 0
end
local function CanToggle()
	return not (DeathProtect and IsDead())
end

-- Botões Combat
DirectoryBtn.MouseButton1Click:Connect(function()
	ExplorerOpen = not ExplorerOpen
	Explorer.Visible = ExplorerOpen
	if ExplorerOpen then BuildTree() end
end)
ExpClose.MouseButton1Click:Connect(function()
	ExplorerOpen = false
	Explorer.Visible = false
	HeadFindMode = false
	MultiSelectMode = false
	HeadFindBtn.Text = "Head Find: OFF"
	HeadFindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	MultiBtn.Text = "Multi Select: OFF"
	MultiBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	StatusLabel.Text = "Pronto"
	StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
end)
MultiBtn.MouseButton1Click:Connect(function()
	if MultiSelectMode then
		MultiSelectMode = false
		MultiBtn.Text = "Multi Select: OFF"
		MultiBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		StatusLabel.Text = "Pronto"
		StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	else
		HeadFindMode = false
		HeadFindBtn.Text = "Head Find: OFF"
		HeadFindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		MultiSelectMode = true
		ClearAllSelected()
		RefreshListUI()
		MultiBtn.Text = "Multi Select: ON"
		MultiBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 60)
		StatusLabel.Text = "Multi Select ligado"
		StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
	end
end)
HeadFindBtn.MouseButton1Click:Connect(function()
	if HeadFindMode then
		HeadFindMode = false
		HeadFindBtn.Text = "Head Find: OFF"
		HeadFindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		StatusLabel.Text = "Pronto"
		StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	else
		MultiSelectMode = false
		MultiBtn.Text = "Multi Select: OFF"
		MultiBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		HeadFindMode = true
		HeadFindBtn.Text = "Head Find: ON"
		HeadFindBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 60)
		StatusLabel.Text = "Clique em uma PASTA"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
	end
end)

ToggleBtn.MouseButton1Click:Connect(function()
	if not CanToggle() then ToggleBtn.Text = "Morreu (Death Protect)" task.wait(1.2) AtualizarToggle() return end
	if not AimbotAtivo and not AimbotKey and not HoldRMB then ToggleBtn.Text = "Escolha um Bind!" task.wait(1) AtualizarToggle() return end
	AimbotAtivo = not AimbotAtivo
	AtualizarToggle()
end)
BindBtn.MouseButton1Click:Connect(function()
	if HoldRMB then return end
	WaitingBind = true
	BindBtn.Text = "Aperte qualquer tecla..."
	BindBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 0)
end)
HoldRMBBtn.MouseButton1Click:Connect(function()
	if not CanToggle() then return end
	HoldRMB = not HoldRMB
	if HoldRMB then
		AimbotKey = nil
		BindBtn.Text = "Bind: None"
		HoldRMBBtn.Text = "Hold RMB: ON"
		HoldRMBBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
		AimbotAtivo = false
		AtualizarToggle()
	else
		HoldRMBBtn.Text = "Hold RMB: OFF"
		HoldRMBBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		AimbotAtivo = false
		AtualizarToggle()
	end
end)
TeamBtn.MouseButton1Click:Connect(function()
	TeamCheck = not TeamCheck
	TeamBtn.Text = TeamCheck and "Team Check: ON" or "Team Check: OFF"
	TeamBtn.BackgroundColor3 = TeamCheck and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(50, 50, 50)
end)
CircleBtn.MouseButton1Click:Connect(function()
	ShowFOV = not ShowFOV
	FOVCircle.Visible = ShowFOV
	CircleBtn.Text = ShowFOV and "Círculo FOV: ON" or "Círculo FOV: OFF"
	CircleBtn.BackgroundColor3 = ShowFOV and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(45, 45, 45)
end)
DeathBtn.MouseButton1Click:Connect(function()
	DeathProtect = not DeathProtect
	DeathBtn.Text = DeathProtect and "Death Protect: ON" or "Death Protect: OFF"
	DeathBtn.BackgroundColor3 = DeathProtect and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(50, 50, 50)
end)
PartToggleBtn.MouseButton1Click:Connect(function()
	if not CanToggle() then PartToggleBtn.Text = "Morreu (Death Protect)" task.wait(1.2) AtualizarPartToggle() return end
	if not PartAimbotAtivo and #SelectedParts == 0 then PartToggleBtn.Text = "Selecione partes primeiro!" task.wait(1.1) AtualizarPartToggle() return end
	PartAimbotAtivo = not PartAimbotAtivo
	AtualizarPartToggle()
end)
PartBindBtn.MouseButton1Click:Connect(function()
	if PartHoldRMB then return end
	WaitingPartBind = true
	PartBindBtn.Text = "Aperte qualquer tecla..."
	PartBindBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 0)
end)
PartHoldRMBBtn.MouseButton1Click:Connect(function()
	if not CanToggle() then return end
	PartHoldRMB = not PartHoldRMB
	if PartHoldRMB then
		PartAimbotKey = nil
		PartBindBtn.Text = "Part Bind: None"
		PartHoldRMBBtn.Text = "Part Hold RMB: ON"
		PartHoldRMBBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
		PartAimbotAtivo = false
		AtualizarPartToggle()
	else
		PartHoldRMBBtn.Text = "Part Hold RMB: OFF"
		PartHoldRMBBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		PartAimbotAtivo = false
		AtualizarPartToggle()
	end
end)
ResetOffsetBtn.MouseButton1Click:Connect(function()
	AimOffset = Vector3.new(0, 0, 0)
	OffsetLabel.Text = "Offset → X: 0.0   Y: 0.0"
end)

---------------- INPUTS AIMBOT ----------------
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if WaitingBind then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then return end
		WaitingBind = false
		if input.UserInputType == Enum.UserInputType.Keyboard then
			AimbotKey = input.KeyCode
			BindBtn.Text = "Bind: " .. input.KeyCode.Name
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			AimbotKey = "MB2"
			BindBtn.Text = "Bind: Mouse2"
		elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
			AimbotKey = "MB3"
			BindBtn.Text = "Bind: Mouse3"
		else
			AimbotKey = nil
			BindBtn.Text = "Bind: None"
		end
		BindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		return
	end
	if WaitingPartBind then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then return end
		WaitingPartBind = false
		if input.UserInputType == Enum.UserInputType.Keyboard then
			PartAimbotKey = input.KeyCode
			PartBindBtn.Text = "Part Bind: " .. input.KeyCode.Name
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			PartAimbotKey = "MB2"
			PartBindBtn.Text = "Part Bind: Mouse2"
		elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
			PartAimbotKey = "MB3"
			PartBindBtn.Text = "Part Bind: Mouse3"
		else
			PartAimbotKey = nil
			PartBindBtn.Text = "Part Bind: None"
		end
		PartBindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		return
	end
	if HoldRMB and input.UserInputType == Enum.UserInputType.MouseButton2 and CanToggle() then
		AimbotAtivo = true
		AtualizarToggle()
		return
	end
	if PartHoldRMB and input.UserInputType == Enum.UserInputType.MouseButton2 and CanToggle() then
		PartAimbotAtivo = true
		AtualizarPartToggle()
		return
	end
	if not HoldRMB and AimbotKey and CanToggle() then
		local matched = (typeof(AimbotKey) == "EnumItem" and input.KeyCode == AimbotKey)
			or (AimbotKey == "MB2" and input.UserInputType == Enum.UserInputType.MouseButton2)
			or (AimbotKey == "MB3" and input.UserInputType == Enum.UserInputType.MouseButton3)
		if matched then AimbotAtivo = not AimbotAtivo AtualizarToggle() end
	end
	if not PartHoldRMB and PartAimbotKey and CanToggle() then
		local matched = (typeof(PartAimbotKey) == "EnumItem" and input.KeyCode == PartAimbotKey)
			or (PartAimbotKey == "MB2" and input.UserInputType == Enum.UserInputType.MouseButton2)
			or (PartAimbotKey == "MB3" and input.UserInputType == Enum.UserInputType.MouseButton3)
		if matched then PartAimbotAtivo = not PartAimbotAtivo AtualizarPartToggle() end
	end
end)

UIS.InputEnded:Connect(function(input)
	if HoldRMB and input.UserInputType == Enum.UserInputType.MouseButton2 then
		AimbotAtivo = false
		AtualizarToggle()
	end
	if PartHoldRMB and input.UserInputType == Enum.UserInputType.MouseButton2 then
		PartAimbotAtivo = false
		AtualizarPartToggle()
	end
end)

---------------- LÓGICA AIMBOT ----------------
local function IsEnemy(player)
	if not TeamCheck then return true end
	if not player.Team then return true end
	if LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
	return true
end
local function GetClosestPlayer()
	local closest, shortest = nil, FOV
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
			if player.Character.Humanoid.Health > 0 and IsEnemy(player) then
				local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - Camera.ViewportSize / 2).Magnitude
					if dist < shortest then shortest = dist closest = player end
				end
			end
		end
	end
	return closest
end
local function GetClosestCustom()
	RemoveDeadTargets()
	FrameCount = FrameCount + 1
	if FrameCount % 2 ~= 0 and CachedClosest and IsValidTarget(CachedClosest) then return CachedClosest end
	local closest, shortest = nil, FOV
	local center = Camera.ViewportSize / 2
	local hasOffset = AimOffset.Magnitude > 0.01
	for i = 1, #LiveTargets do
		local part = LiveTargets[i]
		if IsValidTarget(part) then
			local worldPos = part.Position
			if hasOffset then worldPos = worldPos + part.CFrame:VectorToWorldSpace(AimOffset) end
			local pos, onScreen = Camera:WorldToViewportPoint(worldPos)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if dist < shortest then shortest = dist closest = part end
			end
		end
	end
	CachedClosest = closest
	return closest
end

RunService.RenderStepped:Connect(function()
	FOVCircle.Position = Camera.ViewportSize / 2
	FOVCircle.Radius = FOV
	local goal = nil
	if PartAimbotAtivo then
		local targetPart = GetClosestCustom()
		if targetPart then
			goal = targetPart.Position
			if AimOffset.Magnitude > 0.01 then goal = goal + targetPart.CFrame:VectorToWorldSpace(AimOffset) end
		end
	elseif AimbotAtivo then
		local target = GetClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			goal = target.Character.HumanoidRootPart.Position
		end
	end
	if goal then
		local direction = (goal - Camera.CFrame.Position).Unit
		local newCF = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
		Camera.CFrame = Camera.CFrame:Lerp(newCF, 1 / Smooth)
	end
end)

---------------- LÓGICA SPEED ----------------
local function GetCharacter()
	Character = LocalPlayer.Character
	if Character then
		Humanoid = Character:FindFirstChildOfClass("Humanoid")
		RootPart = Character:FindFirstChild("HumanoidRootPart")
	end
end
local function IsEnemySpeed(player)
	if not player.Team then return true end
	if LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
	return true
end
local function GetTargetSpeed()
	local target = VelocidadeBase
	local nearestDist = DistanciaBoost + 1
	local nearestPlayer = nil
	if Estados.BoostDistancia and RootPart then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local dist = (RootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
				local valido = false
				if Estados.FiltroAlvo == "Todos" then valido = true
				elseif Estados.FiltroAlvo == "Inimigos" then valido = IsEnemySpeed(plr)
				elseif Estados.FiltroAlvo == "Amigos" then valido = not IsEnemySpeed(plr)
				elseif Estados.FiltroAlvo == "MaisProximo" then valido = true end
				if valido and dist < nearestDist then nearestDist = dist nearestPlayer = plr end
			end
		end
		if nearestPlayer and nearestDist <= DistanciaBoost then target = VelocidadeBoost end
	end
	if Estados.AirControl and Humanoid and Humanoid.FloorMaterial == Enum.Material.Air then
		target = math.max(target, VelocidadeAr)
	end
	return target
end
local function ApplyStrafe()
	if not Estados.Strafe or not RootPart then return end
	local moveDir = Vector3.zero
	if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit
		local vel = RootPart.AssemblyLinearVelocity
		local horizontal = Vector3.new(vel.X, 0, vel.Z)
		local power = StrafePower
		if Humanoid and Humanoid.FloorMaterial == Enum.Material.Air then power = StrafePower * 0.25 end
		local newHorizontal = horizontal + moveDir * power * 0.35
		RootPart.AssemblyLinearVelocity = Vector3.new(newHorizontal.X, vel.Y, newHorizontal.Z)
	end
end
local function SetSpeed(target)
	if not Humanoid or not RootPart then return end
	if Estados.Suavizacao then
		CurrentSpeed = CurrentSpeed + (target - CurrentSpeed) * Suavizacao
	else
		CurrentSpeed = target
	end
	Humanoid.WalkSpeed = CurrentSpeed
	if Estados.LoopForce then
		local vel = RootPart.AssemblyLinearVelocity
		local horizontal = Vector3.new(vel.X, 0, vel.Z)
		if horizontal.Magnitude < CurrentSpeed * 0.75 and Humanoid.MoveDirection.Magnitude > 0.1 then
			local dir = Humanoid.MoveDirection.Unit
			RootPart.AssemblyLinearVelocity = Vector3.new(dir.X * CurrentSpeed, vel.Y, dir.Z * CurrentSpeed)
		end
	end
end
local function StartHeartbeat()
	if HeartbeatConn then HeartbeatConn:Disconnect() end
	HeartbeatConn = RunService.Heartbeat:Connect(function()
		if not Character or not Humanoid or not RootPart or Humanoid.Health <= 0 then
			GetCharacter()
			return
		end
		SetSpeed(GetTargetSpeed())
		ApplyStrafe()
	end)
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.45)
	GetCharacter()
	if Estados.RespawnProtect then
		CurrentSpeed = VelocidadeBase
		StartHeartbeat()
	end
end)

GetCharacter()
StartHeartbeat()
print("Syntrix System (Speed + Aimbot MEGABRAIN) carregado!")
