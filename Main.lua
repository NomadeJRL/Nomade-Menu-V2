--[[
    NOMADE V4 - MAIN LOGIC
    Usage: loadstring(game:HttpGet("..."))()
]]

-- !!! SUBSTITUA PELO SEU LINK DA LIBRARY LIMPO !!!
local LibLink = "https://raw.githubusercontent.com/NomadeJRL/Nomade-Menu-V2/main/Library.lua"
local Library = loadstring(game:HttpGet(LibLink))()

local Window = Library:Window({Title = "NOMADE V4 | REDUX"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- == TABS ==
local Combat = Window:Tab("Combat")
local Visuals = Window:Tab("Visuals")
local Movement = Window:Tab("Movement")
local World = Window:Tab("World")

-- ================= COMBAT =================
Combat:Section("Legit & Rage")

Combat:Toggle("Aimbot (Auto Lock)", false, function(state)
    getgenv().Aimbot = state
    RunService.RenderStepped:Connect(function()
        if getgenv().Aimbot then
            local closest = nil
            local dist = 150
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
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) 
            end
        end
    end)
end)

Combat:Toggle("Hitbox Expander", false, function(state)
    getgenv().Hitbox = state
    while getgenv().Hitbox do
        task.wait(1)
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(15,15,15)
                v.Character.HumanoidRootPart.Transparency = 0.7
                v.Character.HumanoidRootPart.CanCollide = false
                v.Character.HumanoidRootPart.Color = Color3.fromRGB(255,0,0)
            end
        end
    end
end)

-- ================= VISUALS =================
Visuals:Section("ESP")

Visuals:Toggle("ESP Box", false, function(state)
    getgenv().ESP = state
    if not state then
        for _, v in pairs(workspace:GetDescendants()) do if v.Name == "NomadeESP" then v:Destroy() end end
    else
        task.spawn(function()
            while getgenv().ESP do
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and not v.Character:FindFirstChild("NomadeESP") then
                        local h = Instance.new("Highlight")
                        h.Name = "NomadeESP"
                        h.FillTransparency = 1
                        h.OutlineColor = Color3.fromRGB(255, 50, 50)
                        h.Parent = v.Character
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

Visuals:Toggle("Fullbright", false, function(state)
    if state then
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 100000
    else
        game.Lighting.GlobalShadows = true
    end
end)

-- ================= MOVEMENT =================
Movement:Section("Speed")

Movement:Toggle("Speed Boost (CFrame)", false, function(state)
    getgenv().Speed = state
    RunService.RenderStepped:Connect(function()
        if getgenv().Speed and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + (hum.MoveDirection * 0.5) -- Velocidade fixa
            end
        end
    end)
end)

Movement:Toggle("Infinite Jump", false, function(state)
    getgenv().InfJump = state
    UserInputService.JumpRequest:Connect(function()
        if getgenv().InfJump and LocalPlayer.Character then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
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

-- ================= WORLD =================
World:Section("Env")

World:Toggle("Low Gravity", false, function(state)
    workspace.Gravity = state and 50 or 196.2
end)

World:Button("Click TP (Ctrl+Click)", function()
    Mouse.Button1Down:Connect(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0,3,0))
        end
    end)
end)

World:Button("Destroy Menu", function()
    game.CoreGui.NomadeV4:Destroy()
end)
