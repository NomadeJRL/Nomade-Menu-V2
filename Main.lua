--[[
    ZENITH - MAIN LOGIC
    Anti-Nil Check Included
]]

-- Link Anti-Cache
local LibLink = "https://raw.githubusercontent.com/NomadeJRL/Nomade-Menu-V2/main/Library.lua?v="..math.random(1,9999)
local Library = loadstring(game:HttpGet(LibLink))()

-- Segurança de Carregamento
if not Library or not Library.Init then
    game.StarterGui:SetCore("SendNotification", {Title="Erro", Text="Library falhou ao carregar!"})
    return
end

local Window = Library:Init({Title = "ZENITH"})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Controle de Conexões (IMPORTANTE PARA DESLIGAR FUNÇÕES)
local Toggles = {}

-- == ABAS ==
local Combat = Window:Tab("Combat", "rbxassetid://10888373305")
local Visuals = Window:Tab("Visuals", "rbxassetid://10888374266")
local Movement = Window:Tab("Movement", "rbxassetid://10888372674")
local World = Window:Tab("World", "rbxassetid://10888375056")

-- ======================================================
-- [COMBAT]
-- ======================================================
Combat:Section("Assist")

Combat:Toggle("Aimbot (Camera)", false, function(state)
    if state then
        Toggles.Aim = RunService.RenderStepped:Connect(function()
            local closest = nil
            local maxDist = 200
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if vis then
                        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if dist < maxDist then maxDist = dist closest = p.Character.Head end
                    end
                end
            end
            if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
        end)
    else
        if Toggles.Aim then Toggles.Aim:Disconnect() end
    end
end)

Combat:Toggle("TriggerBot", false, function(state)
    if state then
        Toggles.Trig = RunService.RenderStepped:Connect(function()
            local t = Mouse.Target
            if t and t.Parent and t.Parent:FindFirstChild("Humanoid") and t.Parent.Name ~= LocalPlayer.Name then
                mouse1click()
            end
        end)
    else
        if Toggles.Trig then Toggles.Trig:Disconnect() end
    end
end)

Combat:Section("Exploits")
Combat:Toggle("Hitbox Expander", false, function(state)
    getgenv().Hitbox = state
    if not state then
        -- Reset sizes
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                p.Character.HumanoidRootPart.Transparency = 1
            end
        end
    else
        task.spawn(function()
            while getgenv().Hitbox do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        p.Character.HumanoidRootPart.Size = Vector3.new(12, 12, 12)
                        p.Character.HumanoidRootPart.Transparency = 0.7
                        p.Character.HumanoidRootPart.CanCollide = false
                        p.Character.HumanoidRootPart.Color = Color3.fromRGB(140, 100, 255)
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

-- ======================================================
-- [VISUALS]
-- ======================================================
Visuals:Section("ESP")

Visuals:Toggle("ESP Box (Wallhack)", false, function(state)
    getgenv().ESP = state
    if not state then
        for _, v in pairs(workspace:GetDescendants()) do if v.Name == "ZenithESP" then v:Destroy() end end
    else
        task.spawn(function()
            while getgenv().ESP do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ZenithESP") then
                        local h = Instance.new("Highlight")
                        h.Name = "ZenithESP"
                        h.FillTransparency = 1
                        h.OutlineColor = Color3.fromRGB(140, 100, 255)
                        h.Parent = p.Character
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

Visuals:Toggle("Chams (Glow)", false, function(state)
    getgenv().Chams = state
    if not state then
        for _, v in pairs(workspace:GetDescendants()) do if v.Name == "ZenithChams" then v:Destroy() end end
    else
        task.spawn(function()
            while getgenv().Chams do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ZenithChams") then
                        local h = Instance.new("Highlight")
                        h.Name = "ZenithChams"
                        h.FillColor = Color3.fromRGB(140, 100, 255)
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

Visuals:Section("World")
Visuals:Toggle("Fullbright", false, function(state)
    if state then
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.GlobalShadows = false
    else
        game.Lighting.GlobalShadows = true
    end
end)

-- ======================================================
-- [MOVEMENT]
-- ======================================================
Movement:Section("Character")

local Speed = 16
Movement:Slider("Speed Amount", 16, 200, 16, function(v) Speed = v end)

Movement:Toggle("Enable Speed", false, function(state)
    if state then
        Toggles.Speed = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Speed
            end
        end)
    else
        if Toggles.Speed then Toggles.Speed:Disconnect() end
        if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
    end
end)

Movement:Toggle("Flight", false, function(state)
    if state then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "ZenithFly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = LocalPlayer.Character.HumanoidRootPart
        
        Toggles.Fly = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character then
                local cam = workspace.CurrentCamera.CFrame
                local v = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then v = v + cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then v = v - cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0,1,0) end
                bv.Velocity = v * 50
            end
        end)
    else
        if Toggles.Fly then Toggles.Fly:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart:FindFirstChild("ZenithFly") then
            LocalPlayer.Character.HumanoidRootPart.ZenithFly:Destroy()
        end
    end
end)

Movement:Toggle("Noclip", false, function(state)
    if state then
        Toggles.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    else
        if Toggles.Noclip then Toggles.Noclip:Disconnect() end
    end
end)

-- ======================================================
-- [WORLD]
-- ======================================================
World:Section("Environment")

World:Toggle("Low Gravity", false, function(state)
    workspace.Gravity = state and 50 or 196.2
end)

World:Button("Server Hop", function()
    game.StarterGui:SetCore("SendNotification", {Title="Zenith", Text="Searching server..."})
    -- (Teleport logic placeholder)
end)

World:Button("Destroy UI", function()
    game.CoreGui.ZenithMain:Destroy()
end)
