--[[
    NOMADE V3 - MAIN
    Profissionalizado: Sistema de Conexões + Bypass
]]

-- Link da Library (SUBSTITUA PELO SEU RAW LINK)
local LibLink = "https://raw.githubusercontent.com/NomadeJRL/Nomade-Menu-V2/main/Library.lua"
local Library = loadstring(game:HttpGet(LibLink))()

local Window = Library:Init({Title = "NOMADE REMASTER"})

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Tabela para guardar conexões (Isso arruma o bug de não desligar)
local Toggles = {}

-- == TABS ==
local Combat = Window:Tab("Combat", "⚔️")
local Visuals = Window:Tab("Visuals", "👁️")
local Movement = Window:Tab("Movement", "🏃")
local World = Window:Tab("World", "🌍")

-- ================= COMBAT =================
Combat:Section("Aimbot")

Combat:Toggle("Aimbot (Camera)", function(state)
    if state then
        Toggles.Aim = RunService.RenderStepped:Connect(function()
            local closest = nil
            local dist = 150 -- FOV
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
        end)
    else
        if Toggles.Aim then Toggles.Aim:Disconnect() end
    end
end)

Combat:Section("Exploits")
Combat:Toggle("TriggerBot", function(state)
    if state then
        Toggles.Trig = RunService.RenderStepped:Connect(function()
            if Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid") then
                mouse1click()
            end
        end)
    else
        if Toggles.Trig then Toggles.Trig:Disconnect() end
    end
end)

-- ================= VISUALS =================
Visuals:Section("ESP System")

Visuals:Toggle("ESP Box", function(state)
    if state then
        Toggles.ESP = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("NomadeESP") then
                        local h = Instance.new("Highlight")
                        h.Name = "NomadeESP"
                        h.FillTransparency = 1
                        h.OutlineColor = Color3.fromRGB(255, 40, 40)
                        h.Parent = p.Character
                    end
                end
            end
        end)
    else
        if Toggles.ESP then Toggles.ESP:Disconnect() end
        for _, v in pairs(workspace:GetDescendants()) do 
            if v.Name == "NomadeESP" then v:Destroy() end 
        end
    end
end)

Visuals:Toggle("Chams (Fill)", function(state)
    if state then
        Toggles.Chams = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local h = p.Character:FindFirstChild("NomadeESP")
                    if h then h.FillTransparency = 0.5 h.FillColor = Color3.fromRGB(255, 0, 0) end
                end
            end
        end)
    else
        if Toggles.Chams then Toggles.Chams:Disconnect() end
        -- Limpa visual ao desligar
        for _, v in pairs(workspace:GetDescendants()) do 
            if v.Name == "NomadeESP" then v.FillTransparency = 1 end 
        end
    end
end)

Visuals:Section("Environment")
Visuals:Toggle("Fullbright", function(state)
    if state then
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.GlobalShadows = false
    else
        game.Lighting.Brightness = 1
        game.Lighting.GlobalShadows = true
    end
end)

-- ================= MOVEMENT =================
Movement:Section("Speed & Fly")

local SpeedVal = 16
Movement:Slider("WalkSpeed Amount", 16, 200, 16, function(v) SpeedVal = v end)

Movement:Toggle("Enable Speed", function(state)
    if state then
        Toggles.Speed = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = SpeedVal
            end
        end)
    else
        if Toggles.Speed then Toggles.Speed:Disconnect() end
        if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
    end
end)

Movement:Toggle("Infinite Jump", function(state)
    if state then
        Toggles.InfJump = UserInputService.JumpRequest:Connect(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end)
    else
        if Toggles.InfJump then Toggles.InfJump:Disconnect() end
    end
end)

Movement:Button("Fly (Press F)", function()
    local flying = false
    local bv = nil
    local con
    con = Mouse.KeyDown:Connect(function(k)
        if k == "f" then
            flying = not flying
            if flying then
                bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(0,0,0)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Parent = LocalPlayer.Character.HumanoidRootPart
                while flying and LocalPlayer.Character do
                    RunService.RenderStepped:Wait()
                    local cam = workspace.CurrentCamera.CFrame
                    local v = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then v=v+cam.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then v=v-cam.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then v=v+cam.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then v=v-cam.RightVector end
                    bv.Velocity = v * 80
                end
            else
                if bv then bv:Destroy() end
            end
        end
    end)
end)

-- ================= WORLD =================
World:Section("Modifications")

World:Toggle("Low Gravity", function(state)
    workspace.Gravity = state and 50 or 196.2
end)

World:Button("Server Hop", function()
    -- Função simples de aviso
    Library:Tween(game.CoreGui.NomadeV3Remaster.MainFrame, {BackgroundColor3 = Color3.fromRGB(50,20,20)})
    wait(0.2)
    Library:Tween(game.CoreGui.NomadeV3Remaster.MainFrame, {BackgroundColor3 = Color3.fromRGB(15,15,20)})
end)
