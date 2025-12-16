--[[
    NOMADE V3 - MAIN LOGIC
    Professional GitHub Implementation
]]

-- !!! COLOQUE SEU LINK RAW AQUI !!!
local LibLink = "https://raw.githubusercontent.com/NomadeJRL/Nomade-Menu-V2/main/Library.lua"
local Library = loadstring(game:HttpGet(LibLink))()

local Window = Library:Init({Title = "Nomade V3 | Professional"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- == TABS ==
local Combat = Window:Tab("Combat", "⚔️")
local Visuals = Window:Tab("Visuals", "👁️")
local Movement = Window:Tab("Movement", "🏃")
local World = Window:Tab("World", "🌍")
local Misc = Window:Tab("Misc", "⚙️")

-- ================= COMBAT =================
Combat:Section("Aimbot & Assists")

local AimSettings = {Enabled = false, FOV = 100, Smoothness = 0.5}
Combat:Toggle("Aimbot Enable", false, function(v) AimSettings.Enabled = v end)
Combat:Slider("FOV Size", 50, 500, 100, function(v) AimSettings.FOV = v end)

RunService.RenderStepped:Connect(function()
    if AimSettings.Enabled then
        local dist = AimSettings.FOV
        local target = nil
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if mag < dist then dist = mag target = v.Character.Head end
                end
            end
        end
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

Combat:Toggle("TriggerBot (Auto Shoot)", false, function(v)
    getgenv().Trigger = v
    while getgenv().Trigger do
        task.wait()
        if Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid") then
            mouse1click()
        end
    end
end)

Combat:Section("Hitbox Manipulation")
Combat:Toggle("Hitbox Expander (Blatant)", false, function(v)
    getgenv().Hitbox = v
    while getgenv().Hitbox do
        task.wait(1)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(15,15,15)
                p.Character.HumanoidRootPart.Transparency = 0.7
                p.Character.HumanoidRootPart.CanCollide = false
                p.Character.HumanoidRootPart.Color = Color3.fromRGB(255,0,0)
            end
        end
    end
end)

-- ================= VISUALS =================
Visuals:Section("ESP")

Visuals:Toggle("ESP Box", false, function(v)
    getgenv().ESPBox = v
    if not v then 
        for _, x in pairs(workspace:GetDescendants()) do if x.Name == "NomadeBox" then x:Destroy() end end 
    else
        -- Lógica de Highlight Simples
        while getgenv().ESPBox do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("NomadeBox") then
                    local h = Instance.new("Highlight")
                    h.Name = "NomadeBox"
                    h.FillTransparency = 1
                    h.OutlineColor = Color3.fromRGB(255, 60, 60)
                    h.Parent = p.Character
                end
            end
            task.wait(1)
        end
    end
end)

Visuals:Toggle("Chams (Fill)", false, function(v)
    getgenv().Chams = v
    while getgenv().Chams do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("NomadeBox") or Instance.new("Highlight", p.Character)
                h.Name = "NomadeBox"
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.FillTransparency = 0.5
            end
        end
        task.wait(1)
    end
end)

Visuals:Section("World Render")
Visuals:Toggle("Fullbright", false, function(v)
    if v then Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.GlobalShadows = false
    else Lighting.GlobalShadows = true end
end)

Visuals:Slider("Field of View", 70, 120, 70, function(v) Camera.FieldOfView = v end)

-- ================= MOVEMENT =================
Movement:Section("Character Physics")

Movement:Slider("WalkSpeed", 16, 200, 16, function(v)
    getgenv().SpeedVal = v
end)
Movement:Toggle("Enable Speed", false, function(v)
    getgenv().SpeedOn = v
    RunService.RenderStepped:Connect(function()
        if getgenv().SpeedOn and LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().SpeedVal
        end
    end)
end)

Movement:Slider("JumpPower", 50, 300, 50, function(v)
    if LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = v end
end)

Movement:Toggle("Infinite Jump", false, function(v)
    getgenv().InfJump = v
    UserInputService.JumpRequest:Connect(function()
        if getgenv().InfJump then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
    end)
end)

Movement:Toggle("Noclip", false, function(v)
    getgenv().Noclip = v
    RunService.Stepped:Connect(function()
        if getgenv().Noclip and LocalPlayer.Character then
            for _, x in pairs(LocalPlayer.Character:GetDescendants()) do
                if x:IsA("BasePart") then x.CanCollide = false end
            end
        end
    end)
end)

Movement:Button("Fly Mode (Press F)", function()
    local mouse = LocalPlayer:GetMouse()
    mouse.KeyDown:Connect(function(k)
        if k == "f" then
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0,50,0)
            bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            bv.Parent = LocalPlayer.Character.HumanoidRootPart
            task.wait(0.5)
            bv:Destroy()
        end
    end)
end)

-- ================= WORLD =================
World:Section("Environment")

World:Toggle("Low Gravity", false, function(v) Workspace.Gravity = v and 50 or 196.2 end)

World:Toggle("Spin Bot", false, function(v)
    getgenv().Spin = v
    while getgenv().Spin do
        RunService.RenderStepped:Wait()
        if LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(100), 0)
        end
    end
end)

World:Button("Click TP (Ctrl + Click)", function()
    Mouse.Button1Down:Connect(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0,3,0))
        end
    end)
end)

World:Button("Remove Fog", function() Lighting.FogEnd = 100000 end)

-- ================= MISC =================
Misc:Section("Server & Client")

Misc:Button("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

Misc:Button("Server Hop", function()
    -- Lógica simples de aviso
    print("Server hop triggered")
end)

Misc:Button("FPS Boost", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
    end
end)

Misc:Button("Unload Menu", function()
    game.CoreGui.NomadeV3:Destroy()
end)
