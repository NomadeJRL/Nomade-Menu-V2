--[[
    HYDRA NETWORK - MAIN LOGIC
    Versão com Anti-Cache
]]

-- Link da Library com sistema anti-cache (adiciona números aleatórios no final)
local LibLink = "https://raw.githubusercontent.com/NomadeJRL/Nomade-Menu-V2/main/Library.lua?v="..tostring(math.random(1, 100000))

-- Carrega a Library
local Library = loadstring(game:HttpGet(LibLink))()

-- Verificação de Segurança (Para não dar erro se falhar)
if not Library or not Library.Window then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Erro Crítico";
        Text = "A Library não carregou! Verifique o GitHub.";
        Duration = 5;
    })
    return -- Para o script
end

-- Cria a Janela
local Window = Library:Window({Title = "HYDRA"})

-- ... O RESTO DO SCRIPT CONTINUA IGUAL ABAIXO ...

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Variáveis Globais (Safe)
getgenv().Hydra = {
    Aimbot = false, SilentAim = false, TriggerBot = false, FOV = 100, KillAura = false,
    Hitbox = false, NoRecoil = false, RapidFire = false,
    ESP = false, NameESP = false, HealthESP = false, Chams = false, Tracers = false, Crosshair = false,
    Speed = false, SpeedVal = 16, Fly = false, FlySpeed = 50, Noclip = false, InfJump = false, HighJump = false,
    Spider = false, Jesus = false, Spin = false,
    Gravity = false, Fog = false, Fullbright = false,
    LoopHeal = false
}

-- == TABS ==
local Combat = Window:Tab("Combat", "rbxassetid://10888373305") -- Sword Icon
local Visuals = Window:Tab("Visuals", "rbxassetid://10888374266") -- Eye Icon
local Movement = Window:Tab("Movement", "rbxassetid://10888372674") -- Run Icon
local World = Window:Tab("World", "rbxassetid://10888375056") -- Globe Icon
local PlayerTab = Window:Tab("Player", "rbxassetid://10888375684") -- User Icon

-- =================================================================
-- [COMBAT] (8 Funções)
-- =================================================================

Combat:Toggle("Aimbot (Legit)", function(v)
    getgenv().Hydra.Aimbot = v
    RunService.RenderStepped:Connect(function()
        if getgenv().Hydra.Aimbot then
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
    end)
end)

Combat:Toggle("Silent Aim (Hitbox)", function(v)
    getgenv().Hydra.Hitbox = v
    while getgenv().Hydra.Hitbox do
        task.wait(1)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(10,10,10)
                p.Character.HumanoidRootPart.Transparency = 0.8
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
end)

Combat:Toggle("TriggerBot", function(v)
    getgenv().Hydra.TriggerBot = v
    task.spawn(function()
        while getgenv().Hydra.TriggerBot do
            task.wait()
            if Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid") then
                mouse1click()
            end
        end
    end)
end)

Combat:Toggle("Kill Aura (Touch)", function(v)
    getgenv().Hydra.KillAura = v
    task.spawn(function()
        while getgenv().Hydra.KillAura do
            task.wait(0.1)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 15 then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, p.Character.HumanoidRootPart, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, p.Character.HumanoidRootPart, 1)
                    end
                end
            end
        end
    end)
end)

-- Mockups for Weapon Mods (Game specific usually, but here generic)
Combat:Button("No Recoil (Generic)", function() 
    -- Generic camera shaker bypass attempt
    local old = require(game:GetService("ReplicatedFirst").CameraShaker)
    if old then old.Shake = function() end end
end)

Combat:Button("Rapid Fire (Clicker)", function()
    -- Auto clicker simple
    for i=1, 10 do mouse1click() task.wait(0.01) end
end)

-- =================================================================
-- [VISUALS] (8 Funções)
-- =================================================================

Visuals:Toggle("ESP Box", function(v)
    getgenv().Hydra.ESP = v
    if not v then
        for _, x in pairs(workspace:GetDescendants()) do if x.Name == "HydraBox" then x:Destroy() end end
    else
        task.spawn(function()
            while getgenv().Hydra.ESP do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("HydraBox") then
                        local h = Instance.new("Highlight")
                        h.Name = "HydraBox"
                        h.FillTransparency = 1
                        h.OutlineColor = Color3.fromRGB(0, 255, 120)
                        h.Parent = p.Character
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

Visuals:Toggle("Chams (Wallhack)", function(v)
    getgenv().Hydra.Chams = v
    if not v then
        for _, x in pairs(workspace:GetDescendants()) do if x.Name == "HydraChams" then x:Destroy() end end
    else
        task.spawn(function()
            while getgenv().Hydra.Chams do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("HydraChams") then
                        local h = Instance.new("Highlight")
                        h.Name = "HydraChams"
                        h.FillColor = Color3.fromRGB(0, 255, 120)
                        h.OutlineTransparency = 1
                        h.FillTransparency = 0.5
                        h.Parent = p.Character
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

Visuals:Toggle("Crosshair", function(v)
    if v then
        local c = Instance.new("Frame")
        c.Name = "HydraCross"
        c.Size = UDim2.new(0, 4, 0, 4)
        c.Position = UDim2.new(0.5, -2, 0.5, -2)
        c.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
        c.Parent = game.CoreGui
        Instance.new("UICorner", c).CornerRadius = UDim.new(1,0)
    else
        if game.CoreGui:FindFirstChild("HydraCross") then game.CoreGui.HydraCross:Destroy() end
    end
end)

Visuals:Toggle("Fullbright", function(v)
    if v then Lighting.Brightness = 2 Lighting.ClockTime = 12 Lighting.GlobalShadows = false
    else Lighting.GlobalShadows = true end
end)

Visuals:Toggle("No Fog", function(v)
    if v then Lighting.FogEnd = 100000 else Lighting.FogEnd = 500 end
end)

-- =================================================================
-- [MOVEMENT] (8 Funções)
-- =================================================================

Movement:Slider("Speed Amount", 16, 200, 16, function(v) getgenv().Hydra.SpeedVal = v end)

Movement:Toggle("Enable Speed (CFrame)", function(v)
    getgenv().Hydra.Speed = v
    RunService.RenderStepped:Connect(function()
        if getgenv().Hydra.Speed and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.MoveDirection.Magnitude > 0 and root then
                root.CFrame = root.CFrame + (hum.MoveDirection * (getgenv().Hydra.SpeedVal / 50))
                root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
            end
        end
    end)
end)

Movement:Toggle("Flight Mode", function(v)
    getgenv().Hydra.Fly = v
    if v then
        local root = LocalPlayer.Character.HumanoidRootPart
        local bv = Instance.new("BodyVelocity")
        bv.Name = "HydraFly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0,0,0)
        bv.Parent = root
        
        while getgenv().Hydra.Fly do
            RunService.RenderStepped:Wait()
            local cam = workspace.CurrentCamera.CFrame
            local vel = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0,1,0) end
            bv.Velocity = vel * 50
        end
        bv:Destroy()
    end
end)

Movement:Toggle("Infinite Jump", function(v)
    getgenv().Hydra.InfJump = v
    UserInputService.JumpRequest:Connect(function()
        if getgenv().Hydra.InfJump then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
    end)
end)

Movement:Toggle("Noclip (Wall)", function(v)
    getgenv().Hydra.Noclip = v
    RunService.Stepped:Connect(function()
        if getgenv().Hydra.Noclip and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end)

Movement:Toggle("Spin Bot", function(v)
    getgenv().Hydra.Spin = v
    while getgenv().Hydra.Spin do
        RunService.RenderStepped:Wait()
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(30), 0)
    end
end)

Movement:Toggle("Jesus (Water Walk)", function(v)
    for _, x in pairs(workspace:GetDescendants()) do
        if x:IsA("Part") and x.Name == "Water" then x.CanCollide = v end
    end
end)

-- =================================================================
-- [WORLD] (8 Funções)
-- =================================================================

World:Toggle("Low Gravity", function(v) workspace.Gravity = v and 50 or 196.2 end)

World:Toggle("Time Changer (Night)", function(v) 
    getgenv().Hydra.Time = v
    while getgenv().Hydra.Time do
        Lighting.ClockTime = 0
        task.wait(1)
    end
end)

World:Button("Click TP (Ctrl+Click)", function()
    Mouse.Button1Down:Connect(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0,3,0))
        end
    end)
end)

World:Button("Delete Map (FPS Boost)", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.Transparency = 1
            v.CanCollide = false
        end
    end
end)

World:Button("Server Hop", function()
    -- Basic Hop Logic
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

World:Button("Rejoin Server", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

-- =================================================================
-- [PLAYER] (5 Funções)
-- =================================================================

PlayerTab:Button("Respawn Character", function()
    LocalPlayer.Character.Humanoid.Health = 0
end)

PlayerTab:Toggle("God Mode (Loop Heal)", function(v)
    getgenv().Hydra.LoopHeal = v
    while getgenv().Hydra.LoopHeal do
        task.wait()
        LocalPlayer.Character.Humanoid.Health = 100
    end
end)

PlayerTab:Button("Invisible (Local)", function()
    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = 1 end
    end
end)

PlayerTab:Toggle("Anti-AFK", function(v)
    if v then
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end
end)

PlayerTab:Button("Force Reset", function()
    LocalPlayer.Character:BreakJoints()
end)
