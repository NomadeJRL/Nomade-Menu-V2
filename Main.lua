--[[
    ZENITH V5 - FAILSAFE MAIN
    UI Carrega ANTES da lógica.
]]

-- Link da Library (Anti-Cache)
local LibLink = "https://raw.githubusercontent.com/NomadeJRL/Nomade-Menu-V2/main/Library.lua?v="..tostring(math.random(1,100000))
local Library = loadstring(game:HttpGet(LibLink))()

-- Se falhar, avisa
if not Library then 
    game.StarterGui:SetCore("SendNotification", {Title="Erro", Text="Falha ao carregar Library!"})
    return 
end

-- === 1. CRIAR INTERFACE (PRIORIDADE) ===
local Window = Library:Init({Title = "ZENITH"})

local Combat = Window:Tab("Combat", "rbxassetid://10888373305")
local Visuals = Window:Tab("Visuals", "rbxassetid://10888374266")
local Movement = Window:Tab("Movement", "rbxassetid://10888372674")
local World = Window:Tab("World", "rbxassetid://10888375056")

-- Variáveis Globais
getgenv().Zenith = {
    Aimbot = false, Hitbox = false, Trigger = false,
    ESP_Master = false, ESP_Box = false, ESP_Name = false, ESP_Chams = false,
    Speed = false, SpeedVal = 16, Fly = false, Noclip = false, InfJump = false
}

-- === 2. DEFINIR BOTÕES DA UI ===

-- [Combat Buttons]
Combat:Section("Legit")
Combat:Toggle("Aimbot (Camera)", function(v) getgenv().Zenith.Aimbot = v end)
Combat:Toggle("TriggerBot", function(v) getgenv().Zenith.Trigger = v end)

Combat:Section("Rage")
Combat:Toggle("Hitbox Expander", function(v) getgenv().Zenith.Hitbox = v end)

-- [Visuals Buttons]
Visuals:Section("Wallhack")
Visuals:Toggle("Master Switch (LIGAR PRIMEIRO)", function(v) getgenv().Zenith.ESP_Master = v end)
Visuals:Toggle("ESP Box", function(v) getgenv().Zenith.ESP_Box = v end)
Visuals:Toggle("ESP Name", function(v) getgenv().Zenith.ESP_Name = v end)
Visuals:Toggle("Chams", function(v) getgenv().Zenith.ESP_Chams = v end)

Visuals:Section("World")
Visuals:Toggle("Fullbright", function(v) 
    if v then game.Lighting.Brightness=2 game.Lighting.ClockTime=14 game.Lighting.GlobalShadows=false
    else game.Lighting.GlobalShadows=true end
end)

-- [Movement Buttons]
Movement:Section("Physics")
Movement:Slider("Speed", 16, 200, 16, function(v) getgenv().Zenith.SpeedVal = v end)
Movement:Toggle("Enable Speed", function(v) getgenv().Zenith.Speed = v end)
Movement:Toggle("Infinite Jump", function(v) getgenv().Zenith.InfJump = v end)
Movement:Toggle("Noclip", function(v) getgenv().Zenith.Noclip = v end)

-- [World Buttons]
World:Section("Env")
World:Toggle("Low Gravity", function(v) workspace.Gravity = v and 50 or 196.2 end)
World:Button("Click TP (Ctrl)", function() end) -- Placeholder visual
World:Button("Destroy UI", function() game.CoreGui.ZenithV5:Destroy() end)


-- === 3. INICIAR LÓGICA (BACKEND) ===
-- Isso roda separado, se der erro não impede a UI de abrir

task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local Mouse = Players.LocalPlayer:GetMouse()
    local LocalPlayer = Players.LocalPlayer

    -- Setup ESP Holder
    if game.CoreGui:FindFirstChild("ZenithESP") then game.CoreGui.ZenithESP:Destroy() end
    local ESPFolder = Instance.new("Folder", game.CoreGui)
    ESPFolder.Name = "ZenithESP"

    -- Função Criar ESP
    local function AddESP(p)
        if p == LocalPlayer then return end
        local bb = Instance.new("BillboardGui")
        bb.Name = "Box"
        bb.Size = UDim2.new(0,4,0,5)
        bb.AlwaysOnTop = true
        bb.Enabled = false
        bb.Parent = ESPFolder
        
        local f = Instance.new("Frame", bb)
        f.Size = UDim2.new(1,0,1,0)
        f.BackgroundTransparency = 1
        local s = Instance.new("UIStroke", f)
        s.Color = Color3.fromRGB(140,100,255)
        s.Thickness = 1.5

        local t = Instance.new("TextLabel", bb)
        t.Text = p.Name
        t.Position = UDim2.new(0,0,0,-15)
        t.Size = UDim2.new(1,0,0,10)
        t.BackgroundTransparency = 1
        t.TextColor3 = Color3.new(1,1,1)
        t.Visible = false
    end

    for _, p in pairs(Players:GetPlayers()) do AddESP(p) end
    Players.PlayerAdded:Connect(AddESP)

    -- Loop Principal
    RunService.RenderStepped:Connect(function()
        -- ESP Logic
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                -- Aqui atualizamos o ESP existente em vez de criar novo
                -- (Simplificado para estabilidade)
            end
        end

        -- Aimbot
        if getgenv().Zenith.Aimbot then
            local closest = nil
            local dist = 150
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if vis then
                        local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if mag < dist then dist = mag closest = p.Character.Head end
                    end
                end
            end
            if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
        end

        -- Speed
        if getgenv().Zenith.Speed and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = getgenv().Zenith.SpeedVal end
        end
    end)
    
    -- Eventos Input
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if getgenv().Zenith.InfJump and LocalPlayer.Character then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
end)
