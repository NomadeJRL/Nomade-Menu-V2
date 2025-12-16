--[[
    ZENITH V3 - MAIN
    Features: Skeleton ESP, Tracers, Box, Name, Chams
]]

-- Link Anti-Cache (Coloque o SEU link RAW da library aqui)
local LibLink = "https://raw.githubusercontent.com/NomadeJRL/Nomade-Menu-V2/main/Library.lua?v="..math.random(1,10000)
local Library = loadstring(game:HttpGet(LibLink))()

if not Library then return end

local Window = Library:Init({Title = "ZENITH"})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Toggles = {} 
local ESP_Folder = Instance.new("Folder", game.CoreGui)
ESP_Folder.Name = "ZenithESP_Holder"

-- == ABAS (COM ÍCONES) ==
local Combat = Window:Tab("Combat", "rbxassetid://10888373305")
local Visuals = Window:Tab("Visuals", "rbxassetid://10888374266")
local Movement = Window:Tab("Movement", "rbxassetid://10888372674")
local World = Window:Tab("World", "rbxassetid://10888375056")

-- ======================================================
-- [VISUALS / ESP] - O CORAÇÃO DO SCRIPT
-- ======================================================
Visuals:Section("Visual Awareness")

-- Configurações do ESP
local ESP_Settings = {
    Box = false,
    Name = false,
    Skeleton = false,
    Tracers = false,
    Chams = false
}

local function DrawSkeleton(char)
    -- Desenha linhas entre ossos (R15 e R6 support)
    local function Line(p1, p2)
        local v1, on1 = Camera:WorldToViewportPoint(p1.Position)
        local v2, on2 = Camera:WorldToViewportPoint(p2.Position)
        if on1 and on2 then
            Library:DrawLine(ESP_Folder, v1, v2, Color3.fromRGB(140, 100, 255), 1)
        end
    end

    pcall(function()
        -- R15 / R6 Logic
        if char:FindFirstChild("Head") and char:FindFirstChild("UpperTorso") then -- R15
            Line(char.Head, char.UpperTorso)
            Line(char.UpperTorso, char.LowerTorso)
            if char:FindFirstChild("LeftUpperArm") then Line(char.UpperTorso, char.LeftUpperArm) Line(char.LeftUpperArm, char.LeftLowerArm) Line(char.LeftLowerArm, char.LeftHand) end
            if char:FindFirstChild("RightUpperArm") then Line(char.UpperTorso, char.RightUpperArm) Line(char.RightUpperArm, char.RightLowerArm) Line(char.RightLowerArm, char.RightHand) end
            if char:FindFirstChild("LeftUpperLeg") then Line(char.LowerTorso, char.LeftUpperLeg) Line(char.LeftUpperLeg, char.LeftLowerLeg) Line(char.LeftLowerLeg, char.LeftFoot) end
            if char:FindFirstChild("RightUpperLeg") then Line(char.LowerTorso, char.RightUpperLeg) Line(char.RightUpperLeg, char.RightLowerLeg) Line(char.RightLowerLeg, char.RightFoot) end
        elseif char:FindFirstChild("Head") and char:FindFirstChild("Torso") then -- R6
            Line(char.Head, char.Torso)
            Line(char.Torso, char["Left Arm"])
            Line(char.Torso, char["Right Arm"])
            Line(char.Torso, char["Left Leg"])
            Line(char.Torso, char["Right Leg"])
        end
    end)
end

local function UpdateESP()
    ESP_Folder:ClearAllChildren()
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local hrp = p.Character.HumanoidRootPart
            local hum = p.Character.Humanoid
            local vec, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen and hum.Health > 0 then
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)

                -- 1. BOX
                if ESP_Settings.Box then
                    local Size = UDim2.new(0, 2000 / vec.Z, 0, 2500 / vec.Z)
                    local Pos = UDim2.new(0, vec.X - Size.X.Offset/2, 0, vec.Y - Size.Y.Offset/2)
                    
                    local Box = Instance.new("Frame")
                    Box.Size = Size
                    Box.Position = Pos
                    Box.BackgroundColor3 = Color3.new(1,1,1)
                    Box.BackgroundTransparency = 1
                    Box.BorderSizePixel = 0
                    Box.Parent = ESP_Folder
                    
                    local Stroke = Instance.new("UIStroke")
                    Stroke.Color = Color3.fromRGB(140, 100, 255)
                    Stroke.Thickness = 1
                    Stroke.Parent = Box
                end

                -- 2. NAMES
                if ESP_Settings.Name then
                    local Tag = Instance.new("TextLabel")
                    Tag.Text = p.Name .. "\n[" .. math.floor(hum.Health) .. "%]"
                    Tag.Position = UDim2.new(0, vec.X, 0, vec.Y - (1500/vec.Z) - 15)
                    Tag.Size = UDim2.new(0,0,0,0)
                    Tag.TextColor3 = Color3.new(1,1,1)
                    Tag.Font = Enum.Font.Code
                    Tag.TextSize = 12
                    Tag.TextStrokeTransparency = 0
                    Tag.Parent = ESP_Folder
                end

                -- 3. SKELETON
                if ESP_Settings.Skeleton then
                    DrawSkeleton(p.Character)
                end

                -- 4. TRACERS
                if ESP_Settings.Tracers then
                    local Bottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Library:DrawLine(ESP_Folder, Bottom, Vector2.new(vec.X, vec.Y), Color3.fromRGB(140, 100, 255), 1)
                end
                
                -- 5. CHAMS (Highlight)
                if ESP_Settings.Chams then
                    if not p.Character:FindFirstChild("ZenithCham") then
                        local h = Instance.new("Highlight")
                        h.Name = "ZenithCham"
                        h.FillColor = Color3.fromRGB(140, 100, 255)
                        h.OutlineColor = Color3.new(1,1,1)
                        h.FillTransparency = 0.5
                        h.OutlineTransparency = 0
                        h.Parent = p.Character
                    end
                else
                    if p.Character:FindFirstChild("ZenithCham") then p.Character.ZenithCham:Destroy() end
                end
            end
        end
    end
end

-- Toggles visuais
Visuals:Toggle("ESP Box", function(v) 
    ESP_Settings.Box = v 
    if not v and not ESP_Settings.Skeleton and not ESP_Settings.Tracers and not ESP_Settings.Name then ESP_Folder:ClearAllChildren() end
end)
Visuals:Toggle("ESP Name & HP", function(v) ESP_Settings.Name = v end)
Visuals:Toggle("ESP Skeleton", function(v) ESP_Settings.Skeleton = v end)
Visuals:Toggle("ESP Tracers", function(v) ESP_Settings.Tracers = v end)
Visuals:Toggle("Chams (Glow)", function(v) 
    ESP_Settings.Chams = v 
    if not v then for _, x in pairs(Workspace:GetDescendants()) do if x.Name == "ZenithCham" then x:Destroy() end end end
end)

-- Loop do ESP
RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

Visuals:Section("Environment")
Visuals:Toggle("Fullbright", function(state)
    if state then
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.GlobalShadows = false
    else
        game.Lighting.GlobalShadows = true
    end
end)

-- ======================================================
-- [COMBAT]
-- ======================================================
Combat:Section("Legit & Rage")

Combat:Toggle("Aimbot (Camera)", function(state)
    if state then
        Toggles.Aim = RunService.RenderStepped:Connect(function()
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
            if closest then 
                TweenService:Create(Camera, TweenInfo.new(0.05), {CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)}):Play()
            end
        end)
    else
        if Toggles.Aim then Toggles.Aim:Disconnect() end
    end
end)

Combat:Toggle("TriggerBot", function(state)
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

Combat:Toggle("Hitbox Expander", function(state)
    getgenv().Hitbox = state
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(2,2,1)
                p.Character.HumanoidRootPart.Transparency = 1
            end
        end
    else
        task.spawn(function()
            while getgenv().Hitbox do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        p.Character.HumanoidRootPart.Size = Vector3.new(15,15,15)
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
-- [MOVEMENT]
-- ======================================================
Movement:Section("Character Physics")

local SpeedVal = 16
Movement:Slider("WalkSpeed", 16, 200, 16, function(v) SpeedVal = v end)

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
            if LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
        end)
    else
        if Toggles.InfJump then Toggles.InfJump:Disconnect() end
    end
end)

Movement:Toggle("Noclip", function(state)
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

World:Toggle("Low Gravity", function(state)
    Workspace.Gravity = state and 50 or 196.2
end)

World:Button("Unload Menu", function()
    game.CoreGui.ZenithV3:Destroy()
    ESP_Folder:Destroy()
    for _, v in pairs(Toggles) do v:Disconnect() end
end)
