--[[
    ZENITH V5 - MAIN LOGIC
    FIX: ESP REWRITTEN (AUTO-UPDATE SYSTEM)
]]

-- !!! SEU LINK RAW AQUI !!!
local LibLink = "https://raw.githubusercontent.com/NomadeJRL/Nomade-Menu-V2/main/Library.lua?v="..math.random(1,10000)
local Library = loadstring(game:HttpGet(LibLink))()

if not Library then return end

local Window = Library:Init({Title = "ZENITH"})

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Variáveis Globais de Controle
getgenv().Zenith = {
    Aimbot = false,
    TriggerBot = false,
    Hitbox = false,
    Speed = false, SpeedVal = 16,
    Fly = false,
    Noclip = false,
    InfJump = false,
    -- ESP
    ESP_Master = false,
    ESP_Box = false,
    ESP_Name = false,
    ESP_Chams = false
}

-- Folder para guardar o ESP (Limpeza fácil)
if game.CoreGui:FindFirstChild("ZenithESP_Folder") then game.CoreGui.ZenithESP_Folder:Destroy() end
local ESPHolder = Instance.new("Folder")
ESPHolder.Name = "ZenithESP_Folder"
ESPHolder.Parent = game.CoreGui

-- == ABAS ==
local Combat = Window:Tab("Combat", "rbxassetid://10888373305")
local Visuals = Window:Tab("Visuals", "rbxassetid://10888374266")
local Movement = Window:Tab("Movement", "rbxassetid://10888372674")
local World = Window:Tab("World", "rbxassetid://10888375056")

-- ======================================================
-- [SISTEMA DE ESP ROBUSTO]
-- ======================================================

local function CreateVisuals(plr)
    if plr == LocalPlayer then return end

    -- Função interna para aplicar no Char
    local function Apply(char)
        if not char then return end
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not root then return end

        -- 1. BOX & NAME (BillboardGui - Funciona sempre)
        if not char:FindFirstChild("ZenithBill") then
            local bb = Instance.new("BillboardGui")
            bb.Name = "ZenithBill"
            bb.Adornee = root
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(0, 4, 0, 5)
            bb.StudsOffset = Vector3.new(0, 0, 0)
            bb.Parent = char -- Colocar no Char garante que suma se ele morrer

            -- Caixa (Borda)
            local frame = Instance.new("Frame")
            frame.Name = "BoxFrame"
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            frame.Visible = false -- Controlado pelo Loop
            frame.Parent = bb

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(255, 40, 40)
            stroke.Thickness = 1.5
            stroke.Parent = frame

            -- Nome e Vida
            local txt = Instance.new("TextLabel")
            txt.Name = "NameTag"
            txt.Size = UDim2.new(1, 0, 0, 10)
            txt.Position = UDim2.new(0, 0, 0, -15)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.fromRGB(255, 255, 255)
            txt.TextStrokeTransparency = 0
            txt.TextSize = 11
            txt.Font = Enum.Font.Code
            txt.Text = plr.Name
            txt.Visible = false
            txt.Parent = bb
        end

        -- 2. CHAMS (Highlight)
        if not char:FindFirstChild("ZenithCham") then
            local hl = Instance.new("Highlight")
            hl.Name = "ZenithCham"
            hl.FillColor = Color3.fromRGB(255, 40, 40)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Enabled = false -- Controlado pelo Loop
            hl.Parent = char
        end
    end

    -- Aplica se já existir char e conecta para futuros
    if plr.Character then Apply(plr.Character) end
    plr.CharacterAdded:Connect(Apply)
end

-- Inicializa em todos
for _, p in pairs(Players:GetPlayers()) do CreateVisuals(p) end
Players.PlayerAdded:Connect(CreateVisuals)

-- LOOP DE CONTROLE VISUAL (Liga/Desliga em tempo real)
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            
            -- Controle da BOX/NAME
            local bb = char:FindFirstChild("ZenithBill")
            if bb then
                local box = bb:FindFirstChild("BoxFrame")
                local txt = bb:FindFirstChild("NameTag")
                
                if getgenv().Zenith.ESP_Master then
                    if getgenv().Zenith.ESP_Box and box then box.Visible = true else box.Visible = false end
                    if getgenv().Zenith.ESP_Name and txt then 
                        txt.Visible = true 
                        -- Atualiza vida
                        local hum = char:FindFirstChild("Humanoid")
                        if hum then 
                            txt.Text = p.Name .. " [" .. math.floor(hum.Health) .. "]"
                            txt.TextColor3 = Color3.fromHSV((hum.Health/hum.MaxHealth)*0.3, 1, 1) -- Cor muda com a vida
                        end
                    else 
                        txt.Visible = false 
                    end
                else
                    if box then box.Visible = false end
                    if txt then txt.Visible = false end
                end
            end

            -- Controle do CHAMS
            local hl = char:FindFirstChild("ZenithCham")
            if hl then
                if getgenv().Zenith.ESP_Master and getgenv().Zenith.ESP_Chams then
                    hl.Enabled = true
                else
                    hl.Enabled = false
                end
            end
        end
    end
end)

-- ================= VISUALS UI =================
Visuals:Section("Wallhack")

Visuals:Toggle("Master Switch (LIGAR PRIMEIRO)", function(v) 
    getgenv().Zenith.ESP_Master = v 
end)

Visuals:Toggle("ESP Box", function(v) getgenv().Zenith.ESP_Box = v end)
Visuals:Toggle("ESP Name", function(v) getgenv().Zenith.ESP_Name = v end)
Visuals:Toggle("Chams (Glow)", function(v) getgenv().Zenith.ESP_Chams = v end)

Visuals:Section("Environment")
Visuals:Toggle("Fullbright", function(v)
    if v then Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.GlobalShadows=false
    else Lighting.GlobalShadows=true end
end)

-- ================= COMBAT =================
Combat:Section("Legit")
Combat:Toggle("Aimbot (Camera)", function(v)
    getgenv().Zenith.Aimbot = v
    RunService.RenderStepped:Connect(function()
        if getgenv().Zenith.Aimbot then
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
            if closest then 
                TweenService:Create(Camera, TweenInfo.new(0.05), {CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)}):Play()
            end
        end
    end)
end)

Combat:Section("Rage")
Combat:Toggle("Hitbox Expander", function(v)
    getgenv().Zenith.Hitbox = v
    while getgenv().Zenith.Hitbox do
        task.wait(1)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(15,15,15)
                p.Character.HumanoidRootPart.Transparency = 0.7
                p.Character.HumanoidRootPart.CanCollide = false
                p.Character.HumanoidRootPart.Color = Color3.fromRGB(140, 100, 255)
            end
        end
    end
end)

-- ================= MOVEMENT =================
Movement:Section("Physics")
Movement:Slider("Speed Amount", 16, 200, 16, function(v) getgenv().Zenith.SpeedVal = v end)

Movement:Toggle("Enable Speed", function(v)
    getgenv().Zenith.Speed = v
    RunService.RenderStepped:Connect(function()
        if getgenv().Zenith.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Zenith.SpeedVal
        end
    end)
end)

Movement:Toggle("Infinite Jump", function(v)
    getgenv().Zenith.InfJump = v
    UserInputService.JumpRequest:Connect(function()
        if getgenv().Zenith.InfJump and LocalPlayer.Character then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
end)

Movement:Toggle("Noclip", function(v)
    getgenv().Zenith.Noclip = v
    RunService.Stepped:Connect(function()
        if getgenv().Zenith.Noclip and LocalPlayer.Character then
            for _, x in pairs(LocalPlayer.Character:GetDescendants()) do
                if x:IsA("BasePart") then x.CanCollide = false end
            end
        end
    end)
end)

-- ================= WORLD =================
World:Section("Modifications")
World:Toggle("Low Gravity", function(v) Workspace.Gravity = v and 50 or 196.2 end)

World:Button("Destroy UI", function()
    game.CoreGui.ZenithV4:Destroy()
    if game.CoreGui:FindFirstChild("ZenithESP_Folder") then game.CoreGui.ZenithESP_Folder:Destroy() end
    -- Reset genv
    for k,v in pairs(getgenv().Zenith) do getgenv().Zenith[k] = false end
end)
