--!native
--!optimize 2
--[[
    ROBLOX-CORE-COMPILER // DIAGNOSTIC COMMAND INTERFACE (GUI) b v3.8 (PT-BR)
    TARGET: HEROES BATTLEGROUNDS
    UPDATE: MAP CHANGE BLUR FIX (ANTI-BLUR ENFORCEMENT)
    NOTE: AGGRESSIVE ATTACK RECOGNITION RETAINED
    STATUS: EXTREME OPTIMIZATION (O3)
]]

-- // DEPENDENCY LOADER //
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- // SERVICE CACHE //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera

-- // LOADER SYSTEM (PC/MOBILE SELECTOR) //
local LoaderConfig = {
    IsMobile = false,
    Keybind = Enum.KeyCode.RightControl
}

local function InitializeLoader()
    if CoreGui:FindFirstChild("DCI_Loader") then CoreGui.DCI_Loader:Destroy() end

    local LoaderScreen = Instance.new("ScreenGui")
    LoaderScreen.Name = "DCI_Loader"
    LoaderScreen.Parent = CoreGui
    LoaderScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 180)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = LoaderScreen

    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Color3.fromRGB(60, 60, 60)
    Stroke.Thickness = 2
    
    local Corner = Instance.new("UICorner", MainFrame)
    Corner.CornerRadius = UDim.new(0, 6)

    local Title = Instance.new("TextLabel")
    Title.Text = "CARREGADOR DO SISTEMA"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.Parent = MainFrame

    local SubTitle = Instance.new("TextLabel")
    SubTitle.Text = "Selecione sua plataforma:"
    SubTitle.Size = UDim2.new(1, 0, 0, 20)
    SubTitle.Position = UDim2.new(0, 0, 0, 35)
    SubTitle.BackgroundTransparency = 1
    SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextSize = 14
    SubTitle.Parent = MainFrame

    local PCButton = Instance.new("TextButton")
    PCButton.Text = "PC / COMPUTADOR"
    PCButton.Size = UDim2.new(0, 130, 0, 45)
    PCButton.Position = UDim2.new(0, 20, 0, 70)
    PCButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    PCButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PCButton.Font = Enum.Font.GothamBold
    PCButton.Parent = MainFrame
    Instance.new("UICorner", PCButton).CornerRadius = UDim.new(0, 4)

    local MobileButton = Instance.new("TextButton")
    MobileButton.Text = "CELULAR / TABLET"
    MobileButton.Size = UDim2.new(0, 130, 0, 45)
    MobileButton.Position = UDim2.new(1, -150, 0, 70)
    MobileButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MobileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MobileButton.Font = Enum.Font.GothamBold
    MobileButton.Parent = MainFrame
    Instance.new("UICorner", MobileButton).CornerRadius = UDim.new(0, 4)

    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Text = "Aguardando entrada..."
    InfoLabel.Size = UDim2.new(1, 0, 0, 30)
    InfoLabel.Position = UDim2.new(0, 0, 1, -35)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    InfoLabel.Font = Enum.Font.Code
    InfoLabel.TextSize = 12
    InfoLabel.Parent = MainFrame

    local SelectionMade = false

    PCButton.MouseButton1Click:Connect(function()
        if SelectionMade then return end
        SelectionMade = true
        InfoLabel.Text = "PRESSIONE UMA TECLA..."
        InfoLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        local input = UserInputService.InputBegan:Wait()
        if input.UserInputType == Enum.UserInputType.Keyboard then
            LoaderConfig.Keybind = input.KeyCode
        end
        LoaderConfig.IsMobile = false
        LoaderScreen:Destroy()
    end)

    MobileButton.MouseButton1Click:Connect(function()
        if SelectionMade then return end
        SelectionMade = true
        LoaderConfig.IsMobile = true
        LoaderConfig.Keybind = Enum.KeyCode.RightControl
        LoaderScreen:Destroy()
    end)

    repeat task.wait() until not LoaderScreen.Parent
end

InitializeLoader()

-- // MAIN INTERFACE CREATION //
local WindowOptions = {
    Title = "DCI (GUI) b v3.8 " .. (LoaderConfig.IsMobile and "[MOBILE]" or "[PC]"),
    SubTitle = "Anti-Blur Optimized",
    TabWidth = 160,
    Size = LoaderConfig.IsMobile and UDim2.fromOffset(480, 320) or UDim2.fromOffset(580, 460),
    Acrylic = false, -- [CRITICAL FIX] Disabled to prevent map change blur artifacts
    Theme = "Dark",
    MinimizeKey = LoaderConfig.Keybind
}

local Window = Fluent:CreateWindow(WindowOptions)

-- // GLOBAL STATE //
getgenv().CoreState = {
    AutoBlockAll = false,      
    
    LastAttackTime = 0, 
    
    AttackSpeed = false,
    AttackSpeedValue = 2.5,
    SpeedHack = false,
    WalkSpeed = 16,
    JumpPower = 50,
    ESP = false,
    CamLock = false,
    CamLockTarget = nil,
    CamLockKey = Enum.KeyCode.Q,
    CamSmoothness = 0.14,
    CamLockYOffset = 1.8 
}

-- // UTILITY & OPTIMIZATION //
local strmatch = string.match
local mathsqrt = math.sqrt
local tablefind = table.find
local VIM = VirtualInputManager
local BLOCK_KEY = Enum.KeyCode.F
local SAFE_ZONE = 7 
local SAFE_ZONE_SQ = SAFE_ZONE * SAFE_ZONE
local MAX_DETECTION_RANGE = 30 
local MAX_DETECTION_SQ = MAX_DETECTION_RANGE * MAX_DETECTION_RANGE

local function IsAlive(char)
    local hum = char and char:FindFirstChild("Humanoid")
    return char and hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

local function GetClosestEnemy(range, fovCheck)
    local closest, minDist = nil, range or 9e9
    local myRoot = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local mouse = Players.LocalPlayer:GetMouse()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local char = player.Character
            if IsAlive(char) then
                local root = char.HumanoidRootPart
                local dist = (root.Position - myRoot.Position).Magnitude
                
                if dist < range then
                    if fovCheck then
                        local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
                        if onScreen then
                            local mouseDist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                            if mouseDist < minDist then
                                closest = player
                                minDist = mouseDist
                            end
                        end
                    else 
                        if dist < minDist then
                            closest = player
                            minDist = dist 
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- // CAMLOCK SUBSYSTEM //
RunService:BindToRenderStep("DCI_CamLock", Enum.RenderPriority.Camera.Value + 1, function()
    if getgenv().CoreState.CamLock then
        local target = getgenv().CoreState.CamLockTarget
        if target and target.Character and IsAlive(target.Character) then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local cam = Workspace.CurrentCamera
                local currentPos = cam.CFrame.Position
                local yOffset = getgenv().CoreState.CamLockYOffset or 0
                local targetPos = targetRoot.Position + Vector3.new(0, yOffset, 0)
                local smoothFactor = getgenv().CoreState.CamSmoothness or 0.18
                local desiredLook = CFrame.new(currentPos, targetPos)
                cam.CFrame = cam.CFrame:Lerp(desiredLook, smoothFactor)
            end
        else
            getgenv().CoreState.CamLock = false
            getgenv().CoreState.CamLockTarget = nil
        end
    end
end)

local function ToggleCamLock()
    if getgenv().CoreState.CamLock then
        getgenv().CoreState.CamLock = false
        getgenv().CoreState.CamLockTarget = nil
        Fluent:Notify({Title = "CamLock", Content = "Desbloqueado", Duration = 1})
    else
        local target = GetClosestEnemy(2000, true) 
        if not target then target = GetClosestEnemy(50, false) end

        if target then
            getgenv().CoreState.CamLock = true
            getgenv().CoreState.CamLockTarget = target
            Fluent:Notify({Title = "CamLock", Content = "Travado em: " .. target.Name, Duration = 2})
        else
            Fluent:Notify({Title = "CamLock", Content = "Sem alvos no alcance", Duration = 1})
        end
    end
end

-- // MOBILE CONTROLLER (WIDGET) //
if LoaderConfig.IsMobile then
    if CoreGui:FindFirstChild("DCI_MobileWidget") then CoreGui.DCI_MobileWidget:Destroy() end

    local WidgetGui = Instance.new("ScreenGui")
    WidgetGui.Name = "DCI_MobileWidget"
    WidgetGui.Parent = CoreGui
    WidgetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WidgetGui.DisplayOrder = 9999 
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 110, 0, 50) 
    Container.Position = UDim2.new(0.05, 0, 0.4, 0)
    Container.BackgroundTransparency = 1
    Container.Parent = WidgetGui

    -- MENU BUTTON
    local MenuBtn = Instance.new("TextButton")
    MenuBtn.Size = UDim2.new(0, 50, 0, 50)
    MenuBtn.Position = UDim2.new(0, 0, 0, 0)
    MenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MenuBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
    MenuBtn.Text = "MENU"
    MenuBtn.Font = Enum.Font.GothamBlack
    MenuBtn.TextSize = 10
    MenuBtn.BackgroundTransparency = 0.2
    MenuBtn.Parent = Container
    Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", MenuBtn).Color = Color3.fromRGB(0, 255, 100)

    -- LOCK BUTTON
    local LockBtn = Instance.new("TextButton")
    LockBtn.Size = UDim2.new(0, 50, 0, 50)
    LockBtn.Position = UDim2.new(0, 60, 0, 0)
    LockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    LockBtn.TextColor3 = Color3.fromRGB(200, 200, 200) 
    LockBtn.Text = "LOCK"
    LockBtn.Font = Enum.Font.GothamBlack
    LockBtn.TextSize = 10
    LockBtn.BackgroundTransparency = 0.2
    LockBtn.Parent = Container
    Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(1, 0)
    local LockStroke = Instance.new("UIStroke", LockBtn)
    LockStroke.Color = Color3.fromRGB(200, 200, 200)

    -- STATE UPDATER LOOP 
    RunService.RenderStepped:Connect(function()
        if getgenv().CoreState.CamLock and getgenv().CoreState.CamLockTarget then
            LockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            LockBtn.Text = "ATIVO"
            LockStroke.Color = Color3.fromRGB(0, 255, 100)
        else
            LockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            LockBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            LockBtn.Text = "LOCK"
            LockStroke.Color = Color3.fromRGB(200, 200, 200)
        end
    end)

    -- DRAG LOGIC
    local Dragging, DragInput, DragStart, StartPos
    MenuBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Container.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    MenuBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            Container.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    -- MENU CLICK
    local MainGUIReference = nil
    
    local function FindMainGUI()
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "DCI_MobileWidget" and gui.Name ~= "DCI_Loader" then
                for _, obj in ipairs(gui:GetDescendants()) do
                    if obj:IsA("TextLabel") and obj.Text == WindowOptions.Title then
                        return gui
                    end
                end
            end
        end
        return nil
    end

    MenuBtn.Activated:Connect(function()
        if not MainGUIReference then MainGUIReference = FindMainGUI() end
        if MainGUIReference then
            MainGUIReference.Enabled = not MainGUIReference.Enabled
        else
            MainGUIReference = FindMainGUI()
            if MainGUIReference then MainGUIReference.Enabled = not MainGUIReference.Enabled else
                Fluent:Notify({Title = "ERRO", Content = "GUI não encontrada.", Duration = 2})
            end
        end
    end)
    LockBtn.Activated:Connect(function() ToggleCamLock() end)
end

-- // DATABASE: KNOWN ATTACKS (EXTENDED) //
local KNOWN_ATTACKS = {
    ["15322492552"] = true, ["15322493614"] = true, ["15322494803"] = true, ["15322496218"] = true,
    ["16605699401"] = true, ["16605828199"] = true, ["16605774003"] = true, ["14989482371"] = true,
    ["16146436596"] = true, ["16146437896"] = true, ["16146439328"] = true, ["16146440723"] = true,
    ["18616154806"] = true, ["18616155940"] = true, ["18679858193"] = true, ["18679241274"] = true,
    ["18833984494"] = true, ["18833986974"] = true, ["18833989817"] = true, ["18833991833"] = true,
    ["109118299683778"] = true, ["134710131702457"] = true, ["129007872635806"] = true, ["97193330603283"] = true,
    ["71064390671639"] = true, ["113302934282694"] = true, ["103692467047605"] = true, ["118311121122152"] = true,
    ["110878031211717"] = true,
    ["13917336710"] = true, ["15271714828"] = true, ["15271719973"] = true, ["15271729409"] = true,
    ["18619394783"] = true, ["18838849992"] = true,
}

local IGNORED_ANIMS = {
    ["run"] = true, ["walk"] = true, ["idle"] = true,
    ["jump"] = true, ["fall"] = true, ["climb"] = true,
    ["swim"] = true, ["dash_forward"] = false, 
    ["movement"] = true, ["running"] = true, ["walking"] = true
}
local ACTION_PRIORITIES = {
    [Enum.AnimationPriority.Action] = true, [Enum.AnimationPriority.Action2] = true,
    [Enum.AnimationPriority.Action3] = true, [Enum.AnimationPriority.Action4] = true
}

local isBlocking = false
local function GetCleanID(animationTrack)
    if not animationTrack then return nil end
    local anim = animationTrack.Animation
    if not anim then return nil end
    local id = anim.AnimationId
    if not id or #id == 0 then return nil end
    return strmatch(id, "%d+")
end

local function GetClosestPartDistance(character, rootPos)
    local minDistSq = 999999
    local partsToCheck = {
        character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"),
        character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
    }
    local tool = character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then table.insert(partsToCheck, tool.Handle) end
    
    for _, part in ipairs(partsToCheck) do
        if part then
            local diff = part.Position - rootPos
            local distSq = diff.X*diff.X + diff.Y*diff.Y + diff.Z*diff.Z
            if distSq < minDistSq then minDistSq = distSq end
        end
    end
    return minDistSq
end

local function ToggleBlock(state)
    if isBlocking == state then return end
    isBlocking = state
    
    if state then
        VIM:SendKeyEvent(true, BLOCK_KEY, false, game)
    else
        VIM:SendKeyEvent(false, BLOCK_KEY, false, game)
    end
end

local function ProcessAutoBlock()
    local state = getgenv().CoreState
    if (tick() - (state.LastAttackTime or 0)) < 0.8 then
        if isBlocking then ToggleBlock(false) end
        return
    end

    if not state.AutoBlockAll then 
        if isBlocking then ToggleBlock(false) end
        return 
    end

    local myChar = Players.LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position
    local shouldBlock = false
    
    local playerList = Players:GetPlayers()
    for i = 1, #playerList do
        local player = playerList[i]
        if player == Players.LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        
        if root and hum and hum.Health > 0 then
            local diff = root.Position - myPos
            local distSq = diff.X*diff.X + diff.Y*diff.Y + diff.Z*diff.Z
            
            if distSq < MAX_DETECTION_SQ then
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    local tracks = animator:GetPlayingAnimationTracks()
                    local anyThreatDetected = false
                    
                    for t = 1, #tracks do
                        local track = tracks[t]
                        local alertArmed = false
                        local isDatabaseMatch = false 
                        
                        local id = GetCleanID(track)
                        if id and KNOWN_ATTACKS[id] then 
                            alertArmed = true 
                            isDatabaseMatch = true 
                        end

                        if not alertArmed then
                            local name = track.Name:lower()
                            local isWalkAnim = IGNORED_ANIMS[name] or name:find("walk") or name:find("run")
                            if not isWalkAnim and ACTION_PRIORITIES[track.Priority] then
                                alertArmed = true
                            end
                        end

                        if not alertArmed then
                            local name = track.Name:lower()
                            if not IGNORED_ANIMS[name] then
                                alertArmed = true
                            end
                        end

                        if alertArmed then
                            local threshold = SAFE_ZONE_SQ
                            if isDatabaseMatch then
                                threshold = MAX_DETECTION_SQ 
                            end

                            local physicalDistSq = GetClosestPartDistance(char, myPos)
                            if physicalDistSq <= threshold then
                                anyThreatDetected = true
                                shouldBlock = true; 
                            end
                        end
                    end
                    if anyThreatDetected then break end
                end
            end
        end
        if shouldBlock then break end
    end
    ToggleBlock(shouldBlock)
end

local function ProcessAttackSpeed()
    if not getgenv().CoreState.AttackSpeed then return end
    pcall(function()
        local char = Players.LocalPlayer.Character
        local animator = char and char:FindFirstChild("Humanoid") and char.Humanoid:FindFirstChild("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local name = track.Animation.Name:lower()
                if name:find("attack") or name:find("punch") or name:find("m1") then
                    if track.Speed ~= getgenv().CoreState.AttackSpeedValue then
                        track:AdjustSpeed(getgenv().CoreState.AttackSpeedValue)
                    end
                end
            end
        end
    end)
end

-- [ESP MODULE]
local ESP_HOLDER = Instance.new("Folder", game.CoreGui)
ESP_HOLDER.Name = "Core_ESP_v3"

local function UpdateESP()
    if not getgenv().CoreState.ESP then 
        ESP_HOLDER:ClearAllChildren()
        return 
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local char = player.Character
            local espInstance = ESP_HOLDER:FindFirstChild(player.Name)

            if IsAlive(char) then
                if not espInstance then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = player.Name
                    highlight.Adornee = char
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = ESP_HOLDER
                    espInstance = highlight
                end
                
                if getgenv().CoreState.CamLock and getgenv().CoreState.CamLockTarget == player then
                    espInstance.FillColor = Color3.fromRGB(0, 255, 100)
                    espInstance.OutlineColor = Color3.fromRGB(255, 255, 255)
                    espInstance.FillTransparency = 0.3
                else
                    espInstance.FillColor = Color3.fromRGB(255, 0, 0) 
                    espInstance.OutlineColor = Color3.fromRGB(255, 255, 255)
                    espInstance.FillTransparency = 0.5
                end
            else
                if espInstance then espInstance:Destroy() end
            end
        end
    end
    
    for _, child in ipairs(ESP_HOLDER:GetChildren()) do
        if not Players:FindFirstChild(child.Name) then
            child:Destroy()
        end
    end
end

-- // INPUT & M1 DETECTION FIX //
local function RegisterAttack()
    getgenv().CoreState.LastAttackTime = tick()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        RegisterAttack()
    end

    if gameProcessed then if UserInputService:GetFocusedTextBox() then return end end
    if getgenv().CoreState.CamLockKey and input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == getgenv().CoreState.CamLockKey then
        ToggleCamLock()
    end
end)

local function SetupToolListener(char)
    if not char then return end
    
    local function BindTool(child)
        if child:IsA("Tool") then
            child.Activated:Connect(RegisterAttack)
        end
    end

    char.ChildAdded:Connect(BindTool)
    for _, child in ipairs(char:GetChildren()) do
        BindTool(child)
    end
end

Players.LocalPlayer.CharacterAdded:Connect(SetupToolListener)
if Players.LocalPlayer.Character then SetupToolListener(Players.LocalPlayer.Character) end


-- [CRITICAL: AGGRESSIVE BLUR REMOVER]
-- This function runs continuously to ensure NO blur exists in Lighting.
-- This solves the "map change blur" issue by destroying the effect immediately.
local function AggressiveBlurCleaner()
    -- Target the specific library blur
    local fluentBlur = Lighting:FindFirstChild("FluentAcrylicBlur")
    if fluentBlur then 
        fluentBlur:Destroy() 
    end
    
    -- Target generic Blurs that might be stuck (optional safeguard)
    -- We assume any BlurEffect appearing during a map change while using this script is unwanted
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") and (v.Name == "FluentAcrylicBlur" or v.Enabled == true) then
            v.Enabled = false
            v:Destroy()
        end
    end
end

-- Bind to Lighting changes to catch map updates instantly
Lighting.ChildAdded:Connect(function(child)
    if child:IsA("BlurEffect") or child.Name == "FluentAcrylicBlur" then
        task.wait() -- yield microsecond to allow property set
        child:Destroy()
    end
end)

-- Redundancy loop
RunService.RenderStepped:Connect(AggressiveBlurCleaner)

-- // UI CONSTRUCTION //
local Tabs = {
    Combat = Window:AddTab({ Title = "Combate", Icon = "sword" }),
    Visuals = Window:AddTab({ Title = "Visuais", Icon = "eye" }),
    Movement = Window:AddTab({ Title = "Movimento", Icon = "activity" }),
    Settings = Window:AddTab({ Title = "Config", Icon = "settings" })
}

local SectionCombat = Tabs.Combat:AddSection("Sistema de Defesa")

SectionCombat:AddToggle("AutoBlockAll", {
    Title = "AutoBlock: Zero Delay",
    Description = "Defesa Instantânea (RenderStep Priority).",
    Default = false,
    Callback = function(v) getgenv().CoreState.AutoBlockAll = v end
})

local SectionOffense = Tabs.Combat:AddSection("Ataque / Auxiliar")

SectionOffense:AddKeybind("CamLockKey", {
    Title = "Tecla CamLock (PC)",
    Mode = "Toggle",
    Default = "Q",
    Callback = function(Value) end,
    ChangedCallback = function(New) 
        if typeof(New) == "EnumItem" then
            getgenv().CoreState.CamLockKey = New
            Fluent:Notify({Title = "Config", Content = "Tecla CamLock: " .. tostring(New.Name), Duration = 2})
        end
    end
})

SectionOffense:AddSlider("CamSmoothness", {
    Title = "Suavidade da Câmera",
    Description = "Menor = Mais Móvel/Fluido.",
    Default = 0.14,
    Min = 0.05,
    Max = 1.0,
    Rounding = 2,
    Callback = function(v) getgenv().CoreState.CamSmoothness = v end
})
SectionOffense:AddSlider("CamHeight", {
    Title = "Altura da Câmera (Offset)",
    Description = "Ajusta altura da mira (Corrige visão reta).",
    Default = 1.8,
    Min = -5, 
    Max = 10, 
    Rounding = 1,
    Callback = function(v) getgenv().CoreState.CamLockYOffset = v end
})

SectionOffense:AddToggle("AttackSpeed", {
    Title = "Acelerar Animação",
    Description = "Modifica velocidade da animação local.",
    Default = false,
    Callback = function(v) getgenv().CoreState.AttackSpeed = v end
})
SectionOffense:AddSlider("AttackSpeedVal", {
    Title = "Fator de Velocidade",
    Default = 2,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Callback = function(v) getgenv().CoreState.AttackSpeedValue = v end
})

local SectionVisuals = Tabs.Visuals:AddSection("ESP")
SectionVisuals:AddToggle("ESP", {
    Title = "ESP Jogadores",
    Description = "Veja inimigos através das paredes.",
    Default = false,
    Callback = function(v) getgenv().CoreState.ESP = v end
})

local SectionMovement = Tabs.Movement:AddSection("Jogador Local")
SectionMovement:AddToggle("SpeedHack", {
    Title = "Ativar Modificadores",
    Default = false,
    Callback = function(v) getgenv().CoreState.SpeedHack = v end
})
SectionMovement:AddSlider("WalkSpeed", {
    Title = "Velocidade (WalkSpeed)",
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 1,
    Callback = function(v) getgenv().CoreState.WalkSpeed = v end
})
SectionMovement:AddSlider("JumpPower", {
    Title = "Pulo (JumpPower)",
    Default = 50,
    Min = 50,
    Max = 250,
    Rounding = 1,
    Callback = function(v) getgenv().CoreState.JumpPower = v end
})

-- // MAIN LOOP OPTIMIZATION (ZERO DELAY) //
RunService:BindToRenderStep("DCI_CoreLoop", Enum.RenderPriority.Character.Value + 5, function()
    pcall(function()
        ProcessAutoBlock()
        ProcessAttackSpeed()
        UpdateESP() 
        if getgenv().CoreState.SpeedHack then
            local char = Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = getgenv().CoreState.WalkSpeed
                char.Humanoid.JumpPower = getgenv().CoreState.JumpPower
            end
        end
    end)
end)

-- // INIT //
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "Sistema v3.8 (Anti-Blur)",
    Content = "Correção de Borrão em Mapa Ativada.",
    Duration = 5
})
