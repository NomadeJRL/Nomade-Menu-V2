--[[
    NOMADE MENU V2 - MAIN SCRIPT
    Este script contém toda a lógica dos cheats.
]]

-- AQUI ESTÁ O SEGREDO: Carregando a Library do SEU GitHub (Link Limpo)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NomadeJRL/Nomade-Menu-V2/main/Library.lua"))()

-- Criando a Janela
local Window = Library:CreateWindow({Title = "Nomade V2 | Ultimate"})

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- == CRIANDO AS ABAS ==
local Combat = Window:Tab("Combat")
local Visuals = Window:Tab("Visuals")
local Movement = Window:Tab("Movement")
local World = Window:Tab("World")
local Misc = Window:Tab("Misc")

-- == COMBAT (COMBATE) ==
Combat:Label("--- Mira & Ataque ---")

local AimbotOn = false
Combat:Toggle("Aimbot (Head Lock)", false, function(state)
    AimbotOn = state
end)

-- Lógica do Aimbot
RunService.RenderStepped:Connect(function()
    if AimbotOn then
        local closest = nil
        local dist = 250 -- Campo de visão (FOV)
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if mag < dist then dist = mag closest = v.Character.Head end
                end
            end
        end
        if closest then 
            TweenService:Create(Camera, TweenInfo.new(0.05), {CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)}):Play()
        end
    end
end)

Combat:Toggle("TriggerBot", false, function(state)
    getgenv().Trigger = state
    while getgenv().Trigger do
        wait()
        if Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid") then
            mouse1click()
        end
    end
end)

Combat:Button("Silent Aim (Hitbox)", function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            v.Character.HumanoidRootPart.Size = Vector3.new(10,10,10)
            v.Character.HumanoidRootPart.Transparency = 0.7
            v.Character.HumanoidRootPart.CanCollide = false
            v.Character.HumanoidRootPart.Color = Color3.fromRGB(255,0,0)
        end
    end
end)

-- == VISUALS (VISUAIS) ==
Visuals:Label("--- ESP & Render ---")

Visuals:Toggle("ESP Box", false, function(state)
    if state then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                if not v.Character:FindFirstChild("NomadeESP") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "NomadeESP"
                    hl.FillTransparency = 1
                    hl.OutlineColor = Color3.fromRGB(255, 50, 50)
                    hl.Parent = v.Character
                end
            end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "NomadeESP" then v:Destroy() end
        end
    end
end)

Visuals:Toggle("Chams (Glow)", false, function(state)
    if state then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                if not v.Character:FindFirstChild("NomadeCham") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "NomadeCham"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineTransparency = 1
                    hl.Parent = v.Character
                end
            end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "NomadeCham" then v:Destroy() end
        end
    end
end)

Visuals:Button("Fullbright (Luz)", function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
end)

-- == MOVEMENT (MOVIMENTAÇÃO) ==
Movement:Label("--- Velocidade & Pulo ---")

local SpeedOn = false
Movement:Toggle("CFrame Speed (Bypass)", false, function(state)
    SpeedOn = state
    RunService.RenderStepped:Connect(function()
        if SpeedOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (LocalPlayer.Character.Humanoid.MoveDirection * 0.5)
            end
        end
    end)
end)

Movement:Toggle("Infinite Jump", false, function(state)
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if state then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
    end)
end)

Movement:Toggle("Noclip", false, function(state)
    getgenv().Noclip = state
    RunService.Stepped:Connect(function()
        if getgenv().Noclip and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end)

Movement:Button("Fly (Tecla F)", function()
    local mouse = LocalPlayer:GetMouse()
    mouse.KeyDown:Connect(function(k)
        if k:lower() == "f" then
            local root = LocalPlayer.Character.HumanoidRootPart
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0,50,0)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Parent = root
            wait(0.5)
            bv:Destroy()
        end
    end)
end)

-- == WORLD (MUNDO) ==
World:Toggle("Low Gravity", false, function(state)
    workspace.Gravity = state and 50 or 196.2
end)

World:Toggle("SpinBot", false, function(state)
    getgenv().Spin = state
    while getgenv().Spin do
        RunService.RenderStepped:Wait()
        if LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
        end
    end
end)

World:Button("Click TP (Ctrl + Click)", function()
    local mouse = LocalPlayer:GetMouse()
    mouse.Button1Down:Connect(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0,3,0))
        end
    end)
end)

-- == MISC (OUTROS) ==
Misc:Button("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

Misc:Button("Destroy UI", function()
    game.CoreGui.NomadeUI:Destroy()
end)
