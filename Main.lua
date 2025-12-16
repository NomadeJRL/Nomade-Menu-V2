--[[
    ZENITH V4 - MAIN LOGIC
    Features: STABLE ESP (Billboard & Highlight)
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

-- Variáveis de Controle
local Toggles = {}
local ESP_Storage = {} -- Armazena os objetos de ESP criados

-- == ABAS ==
local Combat = Window:Tab("Combat", "rbxassetid://10888373305")
local Visuals = Window:Tab("Visuals", "rbxassetid://10888374266")
local Movement = Window:Tab("Movement", "rbxassetid://10888372674")
local World = Window:Tab("World", "rbxassetid://10888375056")

-- ======================================================
-- [SISTEMA DE ESP PROFISSIONAL]
-- ======================================================
local ESP_Settings = {
    Enabled = false,
    Box = false,
    Name = false,
    Chams = false,
    Tracers = false
}

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    -- Cria container para o player
    local container = {
        Box = nil,
        Name = nil,
        Cham = nil,
        Tracer = nil
    }
    
    -- BOX & NAME (BillboardGui)
    local bb = Instance.new("BillboardGui")
    bb.Name = "ZenithESP"
    bb.Adornee = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    bb.Size = UDim2.new(0, 4, 0, 5) -- Tamanho padrão
    bb.StudsOffset = Vector3.new(0, 0, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = false
    bb.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Parent = bb
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(140, 100, 255)
    stroke.Thickness = 1.5
    stroke.Parent = frame
    
    local nameTag = Instance.new("TextLabel")
    nameTag.Size = UDim2.new(1, 0, 0, 10)
    nameTag.Position = UDim2.new(0, 0, 0, -15)
    nameTag.BackgroundTransparency = 1
    nameTag.TextColor3 = Color3.new(1,1,1)
    nameTag.TextStrokeTransparency = 0
    nameTag.TextSize = 12
    nameTag.Text = player.Name
    nameTag.Visible = false
    nameTag.Parent = bb
    
    container.Box = bb
    container.Name = nameTag
    
    -- CHAMS (Highlight)
    local hl = Instance.new("Highlight")
    hl.Name = "ZenithChams"
    hl.FillColor = Color3.fromRGB(140, 100, 255)
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.5
    hl.Enabled = false
    hl.Parent = game.CoreGui -- Parentado no CoreGui para não ser deletado pelo jogo
    
    container.Cham = hl
    
    ESP_Storage[player] = container
end

local function RemoveESP(player)
    if ESP_Storage[player] then
        if ESP_Storage[player].Box then ESP_Storage[player].Box:Destroy() end
        if ESP_Storage[player].Cham then ESP_Storage[player].Cham:Destroy() end
        ESP_Storage[player] = nil
    end
end

-- Gerenciador de Players
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

-- Loop de Atualização (Render)
RunService.RenderStepped:Connect(function()
    for player, esp in pairs(ESP_Storage) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local hrp = player.Character.HumanoidRootPart
            
            -- Atualiza Adornees
            if esp.Box then esp.Box.Adornee = hrp end
            if esp.Cham then esp.Cham.Adornee = player.Character end
            
            -- Lógica de Visibilidade
            local visible = ESP_Settings.Enabled
            
            if visible then
                -- Box
                if ESP_Settings.Box then
                    esp.Box.Enabled = true
                    esp.Box.Frame.Visible = true -- Borda da caixa
                else
                    esp.Box.Frame.Visible = false
                end
                
                -- Name
                if ESP_Settings.Name then
                    esp.Box.Enabled = true
                    esp.Name.Visible = true
                    esp.Name.Text = player.Name .. " [" .. math.floor(player.Character.Humanoid.Health) .. "]"
                else
                    esp.Name.Visible = false
                end
                
                -- Se nem Box nem Name, desativa o Billboard
                if not ESP_Settings.Box and not ESP_Settings.Name then esp.Box.Enabled = false end
                
                -- Chams
                if ESP_Settings.Chams then
                    esp.Cham.Enabled = true
                else
                    esp.Cham.Enabled = false
                end
            else
                if esp.Box then esp.Box.Enabled = false end
                if esp.Cham then esp.Cham.Enabled = false end
            end
        else
            -- Esconde se morto/sumido
            if esp.Box then esp.Box.Enabled = false end
            if esp.Cham then esp.Cham.Enabled = false end
        end
    end
end)

-- == TOGGLES VISUALS ==
Visuals:Section("Wallhack")
Visuals:Toggle("Master Switch", function(v) ESP_Settings.Enabled = v end)
Visuals:Toggle("Box (2D)", function(v) ESP_Settings.Box = v end)
Visuals:Toggle("Names + HP", function(v) ESP_Settings.Name = v end)
Visuals:Toggle("Chams (Glow)", function(v) ESP_Settings.Chams = v end)

Visuals:Section("Environment")
Visuals:Toggle("Fullbright", function(v)
    if v then Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.GlobalShadows=false
    else Lighting.GlobalShadows=true end
end)

-- ======================================================
-- [COMBAT]
-- ======================================================
Combat:Section("Legit")
Combat:Toggle("Aimbot (Camera)", function(state)
    if state then
        Toggles.Aim = RunService.RenderStepped:Connect(function()
            local closest, dist = nil, 150
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
        end)
    else
        if Toggles.Aim then Toggles.Aim:Disconnect() end
    end
end)

Combat:Section("Rage")
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
Movement:Section("Speed")
Movement:Toggle("CFrame Speed", function(state)
    if state then
        Toggles.Speed = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (LocalPlayer.Character.Humanoid.MoveDirection * 0.5)
                end
            end
        end)
    else
        if Toggles.Speed then Toggles.Speed:Disconnect() end
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

-- ======================================================
-- [WORLD]
-- ======================================================
World:Section("Utility")
World:Button("Click TP (Ctrl)", function()
    Mouse.Button1Down:Connect(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0,3,0))
        end
    end)
end)

World:Button("Destroy UI", function()
    game.CoreGui.ZenithV4:Destroy()
    for _, v in pairs(ESP_Storage) do
        if v.Box then v.Box:Destroy() end
        if v.Cham then v.Cham:Destroy() end
    end
    for _, v in pairs(Toggles) do v:Disconnect() end
end)
