--========================================================--
-- Speed System - Visual Upgrade (mais espaçado)
--========================================================--

local VelocidadeBase        = 17
local VelocidadeBoost       = 24
local VelocidadeAr          = 20
local StrafePower           = 9
local DistanciaBoost        = 50
local Suavizacao            = 0.18

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UIS               = game:GetService("UserInputService")
local LocalPlayer       = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

local Estados = {
    LoopForce       = false,
    BoostDistancia  = false,
    AirControl      = false,
    Strafe          = false,
    Suavizacao      = true,
    RespawnProtect  = true,
    FiltroAlvo      = "Todos"
}

local CurrentSpeed = VelocidadeBase
local Character, Humanoid, RootPart
local HeartbeatConn
local MenuAberto = false
local ActiveSlider = nil
local Sliding = false

---------------- GUI ----------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Ícone
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

-- Janela
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 560)
Main.Position = UDim2.new(0.02, 0, 0.15, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 45)

-- Título
local Title = Instance.new("TextButton")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Title.Text = "   Speed System"
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

-- Abas
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

-- Frames das abas
local PlayerFrame = Instance.new("ScrollingFrame")
PlayerFrame.Size = UDim2.new(1, -12, 1, -86)
PlayerFrame.Position = UDim2.new(0, 6, 0, 80)
PlayerFrame.BackgroundTransparency = 1
PlayerFrame.BorderSizePixel = 0
PlayerFrame.ScrollBarThickness = 3
PlayerFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
PlayerFrame.CanvasSize = UDim2.new(0, 0, 0, 620)
PlayerFrame.Parent = Main

local CombatFrame = Instance.new("Frame")
CombatFrame.Size = UDim2.new(1, -12, 1, -86)
CombatFrame.Position = UDim2.new(0, 6, 0, 80)
CombatFrame.BackgroundTransparency = 1
CombatFrame.Visible = false
CombatFrame.Parent = Main

local CombatLabel = Instance.new("TextLabel")
CombatLabel.Size = UDim2.new(1, 0, 0, 30)
CombatLabel.Position = UDim2.new(0, 0, 0.4, 0)
CombatLabel.BackgroundTransparency = 1
CombatLabel.Text = "Em breve..."
CombatLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
CombatLabel.Font = Enum.Font.Gotham
CombatLabel.TextSize = 14
CombatLabel.Parent = CombatFrame

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

-- Checkbox melhorado
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

-- Filtro
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

-- Slider
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

    local data = {
        bg = bg, fill = fill, thumb = thumb, label = label,
        min = min, max = max, callback = callback, nome = nome
    }

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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginSlide(input)
        end
    end)
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginSlide(input)
        end
    end)
end

CreateSlider(PlayerFrame, "Velocidade Base", 320, 8, 45, VelocidadeBase, function(v) VelocidadeBase = v end)
CreateSlider(PlayerFrame, "Velocidade Ar", 370, 8, 55, VelocidadeAr, function(v) VelocidadeAr = v end)
CreateSlider(PlayerFrame, "Strafe Power", 420, 0, 25, StrafePower, function(v) StrafePower = v end)
CreateSlider(PlayerFrame, "Distância Boost", 470, 10, 150, DistanciaBoost, function(v) DistanciaBoost = v end)
CreateSlider(PlayerFrame, "Velocidade Boost", 520, 10, 55, VelocidadeBoost, function(v) VelocidadeBoost = v end)

-- Input slider
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

---------------- LÓGICA (igual) ----------------
local function GetCharacter()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        RootPart = Character:FindFirstChild("HumanoidRootPart")
    end
end

local function IsEnemy(player)
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

                if Estados.FiltroAlvo == "Todos" then
                    valido = true
                elseif Estados.FiltroAlvo == "Inimigos" then
                    valido = IsEnemy(plr)
                elseif Estados.FiltroAlvo == "Amigos" then
                    valido = not IsEnemy(plr)
                elseif Estados.FiltroAlvo == "MaisProximo" then
                    valido = true
                end

                if valido and dist < nearestDist then
                    nearestDist = dist
                    nearestPlayer = plr
                end
            end
        end

        if nearestPlayer and nearestDist <= DistanciaBoost then
            target = VelocidadeBoost
        end
    end

    if Estados.AirControl and Humanoid and Humanoid.FloorMaterial == Enum.Material.Air then
        target = math.max(target, VelocidadeAr)
    end

    return target
end

local function ApplyStrafe()
    if not Estados.Strafe or not RootPart then return end

    local moveDir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.A) then
        moveDir = moveDir - Camera.CFrame.RightVector
    end
    if UIS:IsKeyDown(Enum.KeyCode.D) then
        moveDir = moveDir + Camera.CFrame.RightVector
    end

    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
        local vel = RootPart.AssemblyLinearVelocity
        local horizontal = Vector3.new(vel.X, 0, vel.Z)

        local power = StrafePower
        if Humanoid and Humanoid.FloorMaterial == Enum.Material.Air then
            power = StrafePower * 0.25
        end

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
print("Speed System - Visual Upgrade carregado!")
