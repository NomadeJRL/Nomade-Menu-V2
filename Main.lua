--[[
    ZENITH V2 - MAIN LOGIC
    Features: 100% Working ESP, Optimized Functions
]]

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

-- Vars
local Toggles = {} -- Guarda as conexões para poder desligar depois
local ESP_Folder = Instance.new("Folder", game.CoreGui)
ESP_Folder.Name = "ZenithESP_Holder"

-- == TABS ==
local Combat = Window:Tab("Combat", "rbxassetid://10888373305")
local Visuals = Window:Tab("Visuals", "rbxassetid://10888374266")
local Movement = Window:Tab("Movement", "rbxassetid://10888372674")
local World = Window:Tab("World", "rbxassetid://10888375056")

-- ================= COMBAT =================
Combat:Section("Aimbot & Assist")

Combat:Toggle("Aimbot (Legit)", function(state)
    if state then
        Toggles.Aim = RunService.RenderStepped:Connect(function()
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
                TweenService:Create(Camera, TweenInfo.new(0.05), {CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)}):Play()
            end
        end)
    else
        if Toggles.Aim then Toggles.Aim:Disconnect() end
    end
end)

Combat:Section("Rage")
Combat:Toggle("Hitbox Expander", function(state)
    getgenv().Hitbox = state
    if not state then
        -- Reset
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

-- ================= VISUALS =================
Visuals:Section("ESP System (V2)")

local function UpdateESP()
    ESP_Folder:ClearAllChildren()
    if not getgenv().ESPEnabled then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local vec, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                -- BOX ESP (BillboardGui - Mais Confiável)
                local bb = Instance.new("BillboardGui")
                bb.Adornee = hrp
                bb.Size = UDim2.new(0, 4, 0, 5) -- Tamanho relativo
                bb.StudsOffset = Vector3.new(0, 0, 0)
                bb.AlwaysOnTop = true
                bb.Parent = ESP_Folder

                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundTransparency = 1
                frame.BorderSizePixel = 0
                frame.Parent = bb

                local stroke = Instance.new("UIStroke")
                stroke.Thickness = 1.5
                stroke.Color = Color3.fromRGB(140, 100, 255)
                stroke.Parent = frame

                -- NAME ESP
                local name = Instance.new("TextLabel")
                name.Text = p.Name
                name.Position = UDim2.new(0, 0, 0, -15)
                name.Size = UDim2.new(1, 0, 0, 10)
                name.BackgroundTransparency = 1
                name.TextColor3 = Color3.fromRGB(255, 255, 255)
                name.TextStrokeTransparency = 0
                name.TextSize = 10
                name.Parent = bb
            end
        end
    end
end

Visuals:Toggle("ESP Box & Name", function(state)
    getgenv().ESPEnabled = state
    if state then
        -- Loop de atualização do ESP (RenderStepped para ser liso)
        Toggles.ESPLoop = RunService.RenderStepped:Connect(function()
            -- Otimização: Atualizar a cada X frames se pesar muito
            UpdateESP() 
        end)
    else
        if Toggles.ESPLoop then Toggles.ESPLoop:Disconnect() end
        ESP_Folder:ClearAllChildren()
    end
end)

Visuals:Toggle("Chams (Glow)", function(state)
    getgenv().Chams = state
    if not state then
        for _, v in pairs(Workspace:GetDescendants()) do if v.Name == "ZenithChams" then v:Destroy() end end
    else
        task.spawn(function()
            while getgenv().Chams do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("ZenithChams") then
                        local h = Instance.new("Highlight")
                        h.Name = "ZenithChams"
                        h.FillColor = Color3.fromRGB(140, 100, 255)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.5
                        h.OutlineTransparency = 0
                        h.Parent = p.Character
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

Visuals:Section("Environment")
Visuals:Toggle("Fullbright", function(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = true
    end
end)

-- ================= MOVEMENT =================
Movement:Section("Physics")

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

-- ================= WORLD =================
World:Section("Modifications")

World:Toggle("Low Gravity", function(state)
    Workspace.Gravity = state and 50 or 196.2
end)

World:Button("Unload Menu", function()
    game.CoreGui.ZenithReforged:Destroy()
    ESP_Folder:Destroy()
    -- Desconecta tudo
    for _, v in pairs(Toggles) do v:Disconnect() end
end)
