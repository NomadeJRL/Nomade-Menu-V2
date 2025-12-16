--[[
    NOMADE MENU V2 - MAIN LOGIC
    Usage: loadstring(game:HttpGet("LINK_DO_LOADER"))()
]]

-- !!! IMPORTANTE: Substitua o link abaixo pelo seu link RAW do Library.lua no GitHub !!!
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/NomadeV2/main/Library.lua"))()

local Window = Library:CreateWindow({Title = "Nomade V2 | Ultimate"})

-- Serviços e Variáveis
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- == TABS ==
local Combat = Window:Tab("Combat")
local Visuals = Window:Tab("Visuals")
local Movement = Window:Tab("Movement")
local World = Window:Tab("World")
local Misc = Window:Tab("Misc")

-- == COMBAT FEATURES ==
Combat:Label("--- Aimbot & Assist ---")

local AimbotEnabled = false
Combat:Toggle("Aimbot (Head Lock)", false, function(state)
    AimbotEnabled = state
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local closest = nil
        local dist = 200 -- FOV
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if mag < dist then dist = mag closest = v.Character.Head end
                end
            end
        end
        if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
    end
end)

Combat:Toggle("TriggerBot", false, function(state)
    getgenv().TriggerBot = state
    while getgenv().TriggerBot do
        wait()
        if Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid") then
            mouse1click()
        end
    end
end)

Combat:Button("Silent Aim (Hitbox Expander)", function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            v.Character.HumanoidRootPart.Size = Vector3.new(10,10,10)
            v.Character.HumanoidRootPart.Transparency = 0.7
            v.Character.HumanoidRootPart.CanCollide = false
        end
    end
end)

-- == VISUALS FEATURES ==
Visuals:Label("--- ESP & Render ---")

Visuals:Toggle("ESP Box (Wallhack)", false, function(state)
    if state then
        -- Simples Highlight ESP
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hl = Instance.new("Highlight")
                hl.Name = "NomadeESP"
                hl.FillTransparency = 1
                hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                hl.Parent = v.Character
            end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "NomadeESP" then v:Destroy() end
        end
    end
end)

Visuals:Toggle("Chams (Fill)", false, function(state)
    if state then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hl = Instance.new("Highlight")
                hl.Name = "NomadeChams"
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineTransparency = 1
                hl.Parent = v.Character
            end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "NomadeChams" then v:Destroy() end
        end
    end
end)

Visuals:Button("Fullbright (Light)", function()
    game.Lighting.Brightness = 2
    game.Lighting.ClockTime = 14
    game.Lighting.FogEnd = 100000
    game.Lighting.GlobalShadows = false
end)

-- == MOVEMENT FEATURES ==
Movement:Label("--- Physics Bypass ---")

local SpeedEnabled = false
Movement:Toggle("CFrame Speed (Bypass)", false, function(state)
    SpeedEnabled = state
    RunService.RenderStepped:Connect(function()
        if SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
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

Movement:Button("Fly (Press F)", function()
    -- Script de fly simples
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

-- == WORLD FEATURES ==
World:Toggle("Low Gravity", false, function(state)
    workspace.Gravity = state and 50 or 196.2
end)

World:Button("Click TP (Ctrl+Click)", function()
    local mouse = LocalPlayer:GetMouse()
    mouse.Button1Down:Connect(function()
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0,3,0))
        end
    end)
end)

World:Button("Delete Map (FPS)", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.Transparency = 1
            v.CanCollide = false
        end
    end
end)

-- == MISC FEATURES ==
Misc:Button("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

Misc:Button("Server Hop", function()
    -- Função complexa de HttpGet para achar servidores
    print("Server Hopping...")
end)

Misc:Button("Destroy UI", function()
    game.CoreGui.NomadeUI:Destroy()
end)
