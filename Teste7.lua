-- [[ CONFIGURAÇÃO E OTIMIZAÇÃO ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    Aimbot = false,
    ESP = false,
    FOV = 150, 
    MenuVisible = true
}

-- [[ CRIAÇÃO DO CÍRCULO DE FOV ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false
FOVCircle.Visible = false

--- [[ INTERFACE DO USUÁRIO ]] ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PainelPremiumV2"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -75, 0.5, -100)
MainFrame.Size = UDim2.new(0, 160, 0, 190)
MainFrame.Active = true
MainFrame.Draggable = true

-- Arredondar cantos
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "HUB PRIVADO"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local function CreateButton(txt)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    return btn
end

local AimbotBtn = CreateButton("Aimbot: OFF")
local ESPBtn = CreateButton("ESP: OFF")

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0.9, 0, 0, 20)
FOVLabel.Text = "Ajustar FOV:"
FOVLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Parent = MainFrame

local FOVSlider = Instance.new("TextBox")
FOVSlider.Parent = MainFrame
FOVSlider.Size = UDim2.new(0.9, 0, 0, 30)
FOVSlider.Text = tostring(Config.FOV)
FOVSlider.PlaceholderText = "Ex: 150"
FOVSlider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
FOVSlider.TextColor3 = Color3.new(0, 1, 0)

--- [[ LÓGICA CORE ]] ---

local function GetClosestPlayer()
    local target = nil
    local shortestDistance = Config.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    target = player
                    shortestDistance = distance
                end
            end
        end
    end
    return target
end

-- Gerenciador de ESP Seguro
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESPHighlight")
            if Config.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillAlpha = 0.5
                    highlight.OutlineAlpha = 0
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

--- [[ CONEXÕES ]] ---

AimbotBtn.MouseButton1Click:Connect(function()
    Config.Aimbot = not Config.Aimbot
    AimbotBtn.Text = "Aimbot: " .. (Config.Aimbot and "ON" or "OFF")
    AimbotBtn.BackgroundColor3 = Config.Aimbot and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(45, 45, 45)
    FOVCircle.Visible = Config.Aimbot
end)

ESPBtn.MouseButton1Click:Connect(function()
    Config.ESP = not Config.ESP
    ESPBtn.Text = "ESP: " .. (Config.ESP and "ON" or "OFF")
    ESPBtn.BackgroundColor3 = Config.ESP and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(45, 45, 45)
    if not Config.ESP then UpdateESP() end -- Limpa ao desligar
end)

FOVSlider.FocusLost:Connect(function()
    local val = tonumber(FOVSlider.Text)
    if val then
        Config.FOV = val
        FOVCircle.Radius = val
    else
        FOVSlider.Text = tostring(Config.FOV)
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.Aimbot then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Config.FOV
        
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
    
    if Config.ESP then
        UpdateESP()
    end
end)

-- Tecla Insert para fechar/abrir
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Insert then
        Config.MenuVisible = not Config.MenuVisible
        MainFrame.Visible = Config.MenuVisible
    end
end)
