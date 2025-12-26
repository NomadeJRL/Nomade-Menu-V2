--[[
    NOMADE MENU - V26 GLOBAL GODMODE & TELEPORT EDITION (ROBLOX LUAU)
    TARGET: FPS GAMES (Universal)
    STYLE: Modern / Material Design / Animated / Themed
    AUTHOR: System Architect
    
    UPDATE LOG:
    - NOVO: Opções de "God Mode" (Mitigação de Dano, Health Loop).
    - NOVO: Teleportes (Click TP, Safe Spot).
    - NOVO: Gravity Slider e Time Speed.
    - NOVO: Aba TROLL (Fling, Spam, Invisible).
    - OTIMIZAÇÃO: Physics Suspension agora é mais estável.
    
    FEATURES:
    - Combate: Legit, Silent, Rage, Wallbang.
    - Visuais: Chams, ESP, X-Ray.
    - Global: Fly V3, NoClip, Suspension V2, God Mode, Teleport.
    - Troll: Fling Rotation, Chat Spam, Ghost Mode.
    - Misc: Speed, Jump, UI Scale.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// MANIPULAÇÃO DINÂMICA DA CÂMERA
local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

--// COMPATIBILIDADE COM EXECUTORES & UTILS
local Drawing = Drawing or require(script.Parent.Drawing) -- Fallback
local protect_gui = (syn and syn.protect_gui) or (function(gui) gui.Parent = game:GetService("CoreGui") end)

--// VARIÁVEIS GLOBAIS
local LockedTarget = nil
local ChamsCache = {}
local CrosshairLines = {}
local OriginalTransparency = {}
local FlyVelocity = nil
local FlyGyro = nil
local SuspVelocity = nil 
local FlingBAV = nil -- Troll Fling

--// CONFIGURAÇÃO
local Config = {
    AimAssist = {
        Enabled = true,
        Silent = false,
        Legit = true,
        Magic = false,
        MagicSize = 5,
        WallCheck = false,
        Wallbang = false,
        FOV = 150,
        Smoothness = 0.2,
        TeamCheck = false,
        Key = Enum.UserInputType.MouseButton2
    },
    Rage = {
        Enabled = false,
        Spinbot = false,
        SpinSpeed = 20,
        Jitter = false,
        NoSpread = false
    },
    Visuals = {
        Box = false,
        Tracers = false,
        Names = false,
        Snaplines = false,
        Chams = false,
        ChamsColor = Color3.fromRGB(255, 0, 255),
        Fullbright = false,
        XRay = false,
        XRayTransparency = 0.5,
        Crosshair = false,
        TeamCheck = false,
        Color = Color3.fromRGB(255, 50, 50)
    },
    Global = {
        NoClip = false,
        Fly = false,
        FlySpeed = 50,
        InfiniteJump = false,
        Suspension = false,
        SuspensionPower = 50,
        HighJump = false,
        HighJumpPower = 100,
        GodMode = false,       -- NOVO
        LoopHealth = false,    -- NOVO
        ClickTP = false,       -- NOVO
        Gravity = 196.2
    },
    Troll = {                  -- NOVO (Troll Tab)
        Fling = false,
        SpamChat = false,
        Invisible = false,
        SitLoop = false,
        Freeze = false,
        SpamMessage = "NOMADE MENU ON TOP",
        FlingPower = 10000
    },
    Misc = {
        WalkSpeed = 16,
        JumpPower = 50,
        SpeedToggle = false,
        MenuScale = 1.0
    },
    Theme = "Nomade"
}

--// TEMAS VISUAIS
local Themes = {
    Nomade = {
        Background = Color3.fromRGB(20, 20, 25),
        Sidebar = Color3.fromRGB(25, 25, 30),
        Element = Color3.fromRGB(35, 35, 40),
        Accent = Color3.fromRGB(120, 90, 255),
        Text = Color3.fromRGB(240, 240, 240)
    },
    Halloween = {
        Background = Color3.fromRGB(20, 10, 5),
        Sidebar = Color3.fromRGB(30, 15, 10),
        Element = Color3.fromRGB(45, 25, 15),
        Accent = Color3.fromRGB(255, 100, 0),
        Text = Color3.fromRGB(255, 240, 220)
    },
    Natal = {
        Background = Color3.fromRGB(20, 30, 20),
        Sidebar = Color3.fromRGB(25, 40, 25),
        Element = Color3.fromRGB(35, 55, 35),
        Accent = Color3.fromRGB(255, 50, 50),
        Text = Color3.fromRGB(240, 255, 240)
    }
}

local CurrentTheme = Themes.Nomade
local ThemeObjects = {Backgrounds = {}, Sidebars = {}, Elements = {}, Accents = {}, Texts = {}}

--// BIBLIOTECA UI PROFISSIONAL
local UI = {}
local MainUIScale = nil 

function UI:Tween(instance, properties, duration)
    TweenService:Create(instance, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties):Play()
end

function UI:ApplyTheme(ThemeName)
    local newTheme = Themes[ThemeName] or Themes.Nomade
    CurrentTheme = newTheme
    Config.Theme = ThemeName
    
    for _, v in pairs(ThemeObjects.Backgrounds) do UI:Tween(v, {BackgroundColor3 = newTheme.Background}) end
    for _, v in pairs(ThemeObjects.Sidebars) do UI:Tween(v, {BackgroundColor3 = newTheme.Sidebar}) end
    for _, v in pairs(ThemeObjects.Elements) do UI:Tween(v, {BackgroundColor3 = newTheme.Element}) end
    for _, v in pairs(ThemeObjects.Accents) do 
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            UI:Tween(v, {TextColor3 = newTheme.Accent})
        else
            UI:Tween(v, {BackgroundColor3 = newTheme.Accent})
        end
    end
    for _, v in pairs(ThemeObjects.Texts) do UI:Tween(v, {TextColor3 = newTheme.Text}) end
end

-- Função para Animação de Fundo
function UI:CreateBackgroundAnimation(ParentFrame)
    local BackgroundHolder = Instance.new("Frame")
    BackgroundHolder.Size = UDim2.new(1, 0, 1, 0)
    BackgroundHolder.BackgroundTransparency = 1
    BackgroundHolder.ZIndex = 0
    BackgroundHolder.ClipsDescendants = true
    BackgroundHolder.Parent = ParentFrame

    for i = 1, 6 do
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://3570695787"
        Circle.ImageTransparency = 0.96
        Circle.BackgroundTransparency = 1
        Circle.Size = UDim2.new(0, math.random(150, 350), 0, math.random(150, 350))
        Circle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        Circle.ImageColor3 = CurrentTheme.Accent
        Circle.Parent = BackgroundHolder
        table.insert(ThemeObjects.Accents, Circle)

        task.spawn(function()
            while ParentFrame.Parent do
                local targetPos = UDim2.new(math.random(), 0, math.random(), 0)
                local duration = math.random(8, 15)
                TweenService:Create(Circle, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = targetPos}):Play()
                task.wait(duration)
            end
        end)
    end
end

function UI:CreateWindow(Name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NomadeUI_" .. math.random(1000,9999)
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    
    if game:GetService("CoreGui"):FindFirstChild(ScreenGui.Name) then
        game:GetService("CoreGui")[ScreenGui.Name]:Destroy()
    end
    protect_gui(ScreenGui)

    -- Tooltip Global
    local TooltipFrame = Instance.new("Frame")
    TooltipFrame.Size = UDim2.new(0, 200, 0, 30)
    TooltipFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    TooltipFrame.BorderSizePixel = 0
    TooltipFrame.Visible = false
    TooltipFrame.ZIndex = 100
    TooltipFrame.Parent = ScreenGui
    
    local TooltipCorner = Instance.new("UICorner")
    TooltipCorner.CornerRadius = UDim.new(0, 6)
    TooltipCorner.Parent = TooltipFrame
    
    local TooltipText = Instance.new("TextLabel")
    TooltipText.Size = UDim2.new(1, -10, 1, 0)
    TooltipText.Position = UDim2.new(0, 5, 0, 0)
    TooltipText.BackgroundTransparency = 1
    TooltipText.TextColor3 = Color3.fromRGB(255,255,255)
    TooltipText.TextSize = 12
    TooltipText.Font = Enum.Font.Gotham
    TooltipText.ZIndex = 101
    TooltipText.Parent = TooltipFrame

    RunService.RenderStepped:Connect(function()
        if TooltipFrame.Visible then
            local mPos = UserInputService:GetMouseLocation()
            TooltipFrame.Position = UDim2.new(0, mPos.X + 15, 0, mPos.Y + 15)
        end
    end)

    local function RegisterTooltip(obj, text)
        obj.MouseEnter:Connect(function()
            TooltipText.Text = text
            TooltipFrame.Size = UDim2.new(0, TooltipText.TextBounds.X + 20, 0, 30)
            TooltipFrame.Visible = true
        end)
        obj.MouseLeave:Connect(function() TooltipFrame.Visible = false end)
    end

    -- Container Principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    MainFrame.BackgroundColor3 = CurrentTheme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true 
    MainFrame.Parent = ScreenGui
    table.insert(ThemeObjects.Backgrounds, MainFrame)

    -- Animação de Fundo
    UI:CreateBackgroundAnimation(MainFrame)

    -- Escala
    MainUIScale = Instance.new("UIScale")
    MainUIScale.Scale = Config.Misc.MenuScale
    MainUIScale.Parent = MainFrame

    -- Lógica de Arraste (Fix V15)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local Shadow = Instance.new("UIStroke")
    Shadow.Thickness = 2
    Shadow.Color = Color3.fromRGB(15, 15, 15)
    Shadow.Transparency = 0.2
    Shadow.Parent = MainFrame

    -- Barra Lateral
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = CurrentTheme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 2
    Sidebar.Parent = MainFrame
    table.insert(ThemeObjects.Sidebars, Sidebar)

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 8)
    SidebarCorner.Parent = Sidebar

    local SidebarFix = Instance.new("Frame")
    SidebarFix.Size = UDim2.new(0, 10, 1, 0)
    SidebarFix.Position = UDim2.new(1, -10, 0, 0)
    SidebarFix.BackgroundColor3 = CurrentTheme.Sidebar
    SidebarFix.BorderSizePixel = 0
    SidebarFix.ZIndex = 2
    SidebarFix.Parent = Sidebar
    table.insert(ThemeObjects.Sidebars, SidebarFix)

    -- Título
    local Title = Instance.new("TextLabel")
    Title.Text = Name
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 24
    Title.TextColor3 = CurrentTheme.Accent
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 25)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.ZIndex = 3
    Title.Parent = Sidebar
    table.insert(ThemeObjects.Accents, Title)

    local Version = Instance.new("TextLabel")
    Version.Text = "Ultimate V26"
    Version.Font = Enum.Font.Gotham
    Version.TextSize = 12
    Version.TextColor3 = Color3.fromRGB(150,150,150)
    Version.BackgroundTransparency = 1
    Version.Position = UDim2.new(0, 0, 0, 50)
    Version.Size = UDim2.new(1, 0, 0, 20)
    Version.ZIndex = 3
    Version.Parent = Sidebar

    -- Abas
    local TabContainer = Instance.new("Frame")
    TabContainer.Position = UDim2.new(0, 10, 0, 100)
    TabContainer.Size = UDim2.new(1, -20, 1, -110)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ZIndex = 3
    TabContainer.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 8)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer

    -- Páginas
    local PageContainer = Instance.new("Frame")
    PageContainer.Position = UDim2.new(0, 190, 0, 10)
    PageContainer.Size = UDim2.new(1, -200, 1, -20)
    PageContainer.BackgroundTransparency = 1
    PageContainer.ZIndex = 2
    PageContainer.ClipsDescendants = true
    PageContainer.Parent = MainFrame

    local Window = {Tabs = {}}

    function Window:Tab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = Color3.fromRGB(150,150,150)
        TabBtn.BackgroundColor3 = CurrentTheme.Background
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.AutoButtonColor = false
        TabBtn.ZIndex = 3
        TabBtn.Parent = TabContainer
        table.insert(ThemeObjects.Backgrounds, TabBtn) 

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = CurrentTheme.Accent
        Page.Visible = false
        Page.Parent = PageContainer
        
        -- FIX SCROLL INFINITO
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 5)
        PagePadding.PaddingLeft = UDim.new(0, 5)
        PagePadding.Parent = Page

        TabBtn.MouseButton1Click:Connect(function()
            -- Desativar outras abas
            for _, t in pairs(Window.Tabs) do
                if t.Page.Visible then
                    t.Page.Visible = false
                end
                UI:Tween(t.Btn, {BackgroundColor3 = CurrentTheme.Background, TextColor3 = Color3.fromRGB(150,150,150)})
            end
            
            -- Animação de Entrada
            Page.Visible = true
            Page.Position = UDim2.new(0, 30, 0, 0)
            UI:Tween(Page, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
            
            UI:Tween(TabBtn, {BackgroundColor3 = CurrentTheme.Element, TextColor3 = CurrentTheme.Text})
        end)

        if #Window.Tabs == 0 then
            Page.Visible = true
            TabBtn.BackgroundColor3 = CurrentTheme.Element
            TabBtn.TextColor3 = CurrentTheme.Text
        end

        table.insert(Window.Tabs, {Page = Page, Btn = TabBtn})

        local Components = {}

        function Components:Section(text)
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 12
            Label.TextColor3 = CurrentTheme.Accent
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1, 0, 0, 25)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Page
            table.insert(ThemeObjects.Accents, Label)
        end

        function Components:Toggle(text, configTable, configKey, callback, risky)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 45)
            ToggleFrame.BackgroundColor3 = CurrentTheme.Element
            ToggleFrame.Parent = Page
            table.insert(ThemeObjects.Elements, ToggleFrame)
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame

            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextColor3 = CurrentTheme.Text
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            table.insert(ThemeObjects.Texts, Label)

            if risky then
                local RiskIcon = Instance.new("TextLabel")
                RiskIcon.Text = "?"
                RiskIcon.Font = Enum.Font.GothamBold
                RiskIcon.TextSize = 14
                RiskIcon.TextColor3 = Color3.fromRGB(255, 180, 50)
                RiskIcon.BackgroundColor3 = Color3.fromRGB(50, 40, 20)
                RiskIcon.Size = UDim2.new(0, 20, 0, 20)
                RiskIcon.Position = UDim2.new(0, Label.TextBounds.X + 25, 0.5, -10)
                RiskIcon.Parent = ToggleFrame
                local RiskCorner = Instance.new("UICorner")
                RiskCorner.CornerRadius = UDim.new(1, 0)
                RiskCorner.Parent = RiskIcon
                RegisterTooltip(RiskIcon, "Função experimental. Pode falhar.")
            end

            local SwitchBg = Instance.new("TextButton")
            SwitchBg.Text = ""
            SwitchBg.Size = UDim2.new(0, 44, 0, 22)
            SwitchBg.Position = UDim2.new(1, -60, 0.5, -11)
            SwitchBg.BackgroundColor3 = configTable[configKey] and CurrentTheme.Accent or Color3.fromRGB(50,50,55)
            SwitchBg.AutoButtonColor = false
            SwitchBg.Parent = ToggleFrame

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = SwitchBg

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 18, 0, 18)
            Circle.Position = configTable[configKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            Circle.BackgroundColor3 = CurrentTheme.Text
            Circle.Parent = SwitchBg
            table.insert(ThemeObjects.Texts, Circle)
            
            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = Circle

            SwitchBg.MouseButton1Click:Connect(function()
                configTable[configKey] = not configTable[configKey]
                local state = configTable[configKey]
                
                if state then
                    UI:Tween(SwitchBg, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
                    UI:Tween(Circle, {Position = UDim2.new(1, -20, 0.5, -9)}, 0.2)
                else
                    UI:Tween(SwitchBg, {BackgroundColor3 = Color3.fromRGB(50,50,55)}, 0.2)
                    UI:Tween(Circle, {Position = UDim2.new(0, 2, 0.5, -9)}, 0.2)
                end
                
                if callback then callback(state) end
            end)
        end

        function Components:Slider(text, min, max, configTable, configKey, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -10, 0, 65)
            SliderFrame.BackgroundColor3 = CurrentTheme.Element
            SliderFrame.Parent = Page
            table.insert(ThemeObjects.Elements, SliderFrame)
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame

            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextColor3 = CurrentTheme.Text
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 15, 0, 5)
            Label.Size = UDim2.new(1, -30, 0, 20)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            table.insert(ThemeObjects.Texts, Label)

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Text = string.format("%.2f", configTable[configKey])
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 14
            ValueLabel.TextColor3 = CurrentTheme.Accent
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(1, -50, 0, 5)
            ValueLabel.Size = UDim2.new(0, 40, 0, 20)
            ValueLabel.Parent = SliderFrame
            table.insert(ThemeObjects.Accents, ValueLabel)

            local SliderBar = Instance.new("TextButton")
            SliderBar.Text = ""
            SliderBar.AutoButtonColor = false
            SliderBar.Size = UDim2.new(1, -30, 0, 6)
            SliderBar.Position = UDim2.new(0, 15, 0, 40)
            SliderBar.BackgroundColor3 = Color3.fromRGB(50,50,55)
            SliderBar.Parent = SliderFrame

            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = SliderBar

            local Fill = Instance.new("Frame")
            local current = configTable[configKey] or min
            local scale = (current - min) / (max - min)
            Fill.Size = UDim2.new(scale, 0, 1, 0)
            Fill.BackgroundColor3 = CurrentTheme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = SliderBar
            table.insert(ThemeObjects.Accents, Fill)
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill

            local dragging = false
            SliderBar.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputEnded:Connect(function(input) 
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
            end)

            RunService.RenderStepped:Connect(function()
                if dragging then
                    local mouseX = UserInputService:GetMouseLocation().X
                    local relative = mouseX - SliderBar.AbsolutePosition.X
                    
                    -- FIX SCROLL INFINITO (MATH.CLAMP)
                    local perc = math.clamp(relative / SliderBar.AbsoluteSize.X, 0, 1)
                    
                    local val = min + (max - min) * perc
                    if max > 2 then val = math.floor(val) else val = math.floor(val*100)/100 end
                    
                    configTable[configKey] = val
                    UI:Tween(Fill, {Size = UDim2.new(perc, 0, 1, 0)}, 0.05)
                    ValueLabel.Text = string.format("%.2f", val)
                    
                    if callback then callback(val) end
                end
            end)
        end
        
        function Components:Dropdown(text, options, callback)
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, -10, 0, 45)
            DropFrame.BackgroundColor3 = CurrentTheme.Element
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = Page
            table.insert(ThemeObjects.Elements, DropFrame)
            
            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 6)
            DropCorner.Parent = DropFrame
            
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextColor3 = CurrentTheme.Text
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.Size = UDim2.new(1, -15, 0, 45)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropFrame
            table.insert(ThemeObjects.Texts, Label)
            
            local Arrow = Instance.new("TextLabel")
            Arrow.Text = "v"
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 14
            Arrow.TextColor3 = Color3.fromRGB(150,150,150)
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.Size = UDim2.new(0, 30, 0, 45)
            Arrow.Parent = DropFrame
            
            local DropBtn = Instance.new("TextButton")
            DropBtn.Text = ""
            DropBtn.BackgroundTransparency = 1
            DropBtn.Size = UDim2.new(1, 0, 0, 45)
            DropBtn.Parent = DropFrame
            
            local opened = false
            DropBtn.MouseButton1Click:Connect(function()
                opened = not opened
                local height = opened and (45 + (#options * 30)) or 45
                UI:Tween(DropFrame, {Size = UDim2.new(1, -10, 0, height)})
                Arrow.Text = opened and "^" or "v"
            end)
            
            for i, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Text = opt
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 13
                OptBtn.TextColor3 = Color3.fromRGB(200,200,200)
                OptBtn.BackgroundColor3 = CurrentTheme.Sidebar
                OptBtn.Size = UDim2.new(1, -20, 0, 25)
                OptBtn.Position = UDim2.new(0, 10, 0, 45 + ((i-1)*30))
                OptBtn.Parent = DropFrame
                
                local OptCorner = Instance.new("UICorner")
                OptCorner.CornerRadius = UDim.new(0, 4)
                OptCorner.Parent = OptBtn
                
                OptBtn.MouseButton1Click:Connect(function()
                    Label.Text = text .. ": " .. opt
                    opened = false
                    UI:Tween(DropFrame, {Size = UDim2.new(1, -10, 0, 45)})
                    Arrow.Text = "v"
                    if callback then callback(opt) end
                end)
            end
        end
        
        -- Campo de Texto (Textbox) para o Troll
        function Components:TextBox(text, configTable, configKey)
            local BoxFrame = Instance.new("Frame")
            BoxFrame.Size = UDim2.new(1, -10, 0, 45)
            BoxFrame.BackgroundColor3 = CurrentTheme.Element
            BoxFrame.Parent = Page
            table.insert(ThemeObjects.Elements, BoxFrame)

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 6)
            BoxCorner.Parent = BoxFrame

            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextColor3 = CurrentTheme.Text
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.Size = UDim2.new(0.5, 0, 1, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BoxFrame
            table.insert(ThemeObjects.Texts, Label)

            local Input = Instance.new("TextBox")
            Input.Text = configTable[configKey]
            Input.Font = Enum.Font.Gotham
            Input.TextSize = 13
            Input.TextColor3 = Color3.fromRGB(200,200,200)
            Input.BackgroundColor3 = Color3.fromRGB(50,50,55)
            Input.Size = UDim2.new(0.4, 0, 0, 25)
            Input.Position = UDim2.new(1, -10 - (Input.Size.X.Scale * BoxFrame.AbsoluteSize.X), 0.5, -12.5) -- Approx
            Input.Position = UDim2.new(0.55, 0, 0.5, -12.5)
            Input.Parent = BoxFrame
            
            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 4)
            InputCorner.Parent = Input

            Input.FocusLost:Connect(function()
                configTable[configKey] = Input.Text
            end)
        end

        return Components
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    return Window
end

--// SISTEMAS MECÂNICOS
local function CreateDrawing(type, props)
    local d = Drawing.new(type)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function IsVisible(targetPart)
    if not Config.AimAssist.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera, Workspace.CurrentCamera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, direction, params)
    if result and result.Instance then
        if result.Instance:IsDescendantOf(targetPart.Parent) then return true end
        return false
    end
    return true
end

--// X-RAY SYSTEM
local function ToggleXRay(state)
    if state then
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) and part.Transparency < 1 then
                if not OriginalTransparency[part] then
                    OriginalTransparency[part] = part.Transparency
                end
                part.Transparency = Config.Visuals.XRayTransparency
            end
        end
    else
        for part, original in pairs(OriginalTransparency) do
            if part and part.Parent then
                part.Transparency = original
            end
        end
        table.clear(OriginalTransparency)
    end
end

--// GLOBAL FUNCTIONS (MELHORADO V25 - FIX STABILITY)
local function ToggleFly(state)
    if state then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        
        -- Fly V3: LinearVelocity (Mais estável que BodyVelocity)
        local attachment = Instance.new("Attachment", hrp)
        attachment.Name = "FlyAttachment"
        
        FlyVelocity = Instance.new("LinearVelocity")
        FlyVelocity.Attachment0 = attachment
        FlyVelocity.MaxForce = 10000 -- Reduzido para evitar "Fling"
        FlyVelocity.VectorVelocity = Vector3.new(0, 0, 0)
        FlyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World 
        FlyVelocity.Parent = hrp
        
        -- Gyro para manter orientação
        FlyGyro = Instance.new("AlignOrientation")
        FlyGyro.Attachment0 = attachment
        FlyGyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
        FlyGyro.MaxTorque = 100000
        FlyGyro.Responsiveness = 200
        FlyGyro.Parent = hrp
        
        LocalPlayer.Character.Humanoid.PlatformStand = true
    else
        if FlyVelocity then FlyVelocity:Destroy() end
        if FlyGyro then FlyGyro:Destroy() end
        -- Limpeza extra
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
                if v.Name == "FlyAttachment" then v:Destroy() end
            end
        end
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

--// NOVO SISTEMA DE SUSPENSÃO (V25 - FIX LATERAL MOVEMENT)
local function ToggleSuspension(state)
    local hrp = LocalPlayer.Character.HumanoidRootPart
    if state then
        if not SuspVelocity then
            local att = Instance.new("Attachment", hrp)
            att.Name = "SuspAtt"
            SuspVelocity = Instance.new("VectorForce")
            SuspVelocity.Attachment0 = att
            -- Força menor para suavizar, evita travamento
            SuspVelocity.Force = Vector3.new(0, workspace.Gravity * hrp.AssemblyMass * 0.98, 0)
            SuspVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
            SuspVelocity.Parent = hrp
        end
    else
        if SuspVelocity then 
            SuspVelocity:Destroy()
            SuspVelocity = nil
            if hrp:FindFirstChild("SuspAtt") then hrp.SuspAtt:Destroy() end
        end
    end
end

--// TROLL FUNCTIONS
local function ToggleFling(state)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if state and hrp then
        Config.Global.NoClip = true -- Ativar noclip para entrar nos jogadores
        FlingBAV = Instance.new("BodyAngularVelocity")
        FlingBAV.Name = "NomadeFling"
        FlingBAV.AngularVelocity = Vector3.new(0, Config.Troll.FlingPower, 0)
        FlingBAV.MaxTorque = Vector3.new(0, math.huge, 0)
        FlingBAV.P = 10000
        FlingBAV.Parent = hrp
    else
        Config.Global.NoClip = false
        if FlingBAV then FlingBAV:Destroy() FlingBAV = nil end
        if hrp and hrp:FindFirstChild("NomadeFling") then hrp.NomadeFling:Destroy() end
        if char:FindFirstChild("Humanoid") then char.Humanoid.Sit = false end
        -- Reset Rotation
        if hrp then hrp.RotVelocity = Vector3.new(0,0,0) end
    end
end

local function ToggleSpam(state)
    if state then
        task.spawn(function()
            while Config.Troll.SpamChat do
                local args = {
                    [1] = Config.Troll.SpamMessage,
                    [2] = "All"
                }
                local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if event then
                    pcall(function() event:FindFirstChild("SayMessageRequest"):FireServer(unpack(args)) end)
                end
                task.wait(2)
            end
        end)
    end
end

local function ToggleInvisible(state)
    local char = LocalPlayer.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                if state then
                    if v.Name ~= "HumanoidRootPart" then v.Transparency = 1 end
                else
                    if v.Name ~= "HumanoidRootPart" then v.Transparency = 0 end
                end
            end
        end
    end
end

local function UpdateGlobalPhysics()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        
        -- Fly Logic (V25 - LIMIT SPEED)
        if Config.Global.Fly and FlyVelocity then
            local moveDir = Vector3.new()
            local camCFrame = Camera.CFrame
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            -- Normalizar para evitar velocidades infinitas (FIX TRAVAMENTO)
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * math.clamp(Config.Global.FlySpeed, 0, 300) -- Cap speed
            end
            
            FlyVelocity.VectorVelocity = moveDir
            
            -- Manter rotação
            if FlyGyro then
                FlyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camCFrame.LookVector)
            end
        end
        
        -- Infinite Jump
        if Config.Global.InfiniteJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if hum:GetState() == Enum.HumanoidStateType.Freefall then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        
        -- Suspension Update (Dynamic Power)
        if Config.Global.Suspension and SuspVelocity then
            -- Ajuste fino para não voar nem cair rápido demais
            local dampening = 0.98 + (Config.Global.SuspensionPower / 5000)
            SuspVelocity.Force = Vector3.new(0, workspace.Gravity * hrp.AssemblyMass * dampening, 0)
        end
        
        -- High Jump
        if Config.Global.HighJump then
            hum.UseJumpPower = true
            hum.JumpPower = Config.Global.HighJumpPower
        end
        
        -- Loop Health (V26)
        if Config.Global.LoopHealth then
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
        
        -- NoClip (Stepped Loop)
        if Config.Global.NoClip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
        
        -- TROLL LOOPS
        if Config.Troll.SitLoop then
            hum.Sit = true
        end
        
        if Config.Troll.Freeze then
            hrp.Anchored = true
        else
            if not Config.Troll.Freeze and hrp.Anchored and not Config.Troll.Fling then 
               -- Only unanchor if not needed elsewhere, but safe to default false here for character control
               hrp.Anchored = false 
            end
        end
    end
end

--// CHAMS
local function UpdateChams()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if Config.Visuals.Chams then
                if not ChamsCache[plr] then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "NomadeChams"
                    highlight.FillColor = Config.Visuals.ChamsColor
                    highlight.OutlineColor = Color3.new(1,1,1)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = plr.Character
                    ChamsCache[plr] = highlight
                end
            else
                if ChamsCache[plr] then
                    ChamsCache[plr]:Destroy()
                    ChamsCache[plr] = nil
                end
            end
        end
    end
end

--// ESP & VISUALS
local ESP_Cache = {}

local function RemoveESP(plr)
    if ESP_Cache[plr] then
        for _, d in pairs(ESP_Cache[plr]) do d:Remove() end
        ESP_Cache[plr] = nil
    end
end

local function UpdateVisuals()
    -- Crosshair
    if Config.Visuals.Crosshair then
        if #CrosshairLines == 0 then
            local l1 = CreateDrawing("Line", {Thickness=1, Color=Color3.new(0,1,0), Visible=true})
            local l2 = CreateDrawing("Line", {Thickness=1, Color=Color3.new(0,1,0), Visible=true})
            table.insert(CrosshairLines, l1)
            table.insert(CrosshairLines, l2)
        end
        local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
        CrosshairLines[1].From = Vector2.new(cx-5, cy)
        CrosshairLines[1].To = Vector2.new(cx+5, cy)
        CrosshairLines[2].From = Vector2.new(cx, cy-5)
        CrosshairLines[2].To = Vector2.new(cx, cy+5)
        for _, l in pairs(CrosshairLines) do l.Visible = true end
    else
        for _, l in pairs(CrosshairLines) do l.Visible = false end
    end

    -- Fullbright
    if Config.Visuals.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end

    -- ESP
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
            
            local isTeammate = (plr.Team == LocalPlayer.Team)
            if Config.Visuals.TeamCheck and isTeammate then RemoveESP(plr) continue end
            
            if Config.AimAssist.Magic and plr.Character:FindFirstChild("Head") and not isTeammate then
                local head = plr.Character.Head
                if head.Size.X ~= Config.AimAssist.MagicSize then
                    head.Size = Vector3.new(Config.AimAssist.MagicSize, Config.AimAssist.MagicSize, Config.AimAssist.MagicSize)
                    head.Transparency = 0.5; head.CanCollide = false
                end
            elseif plr.Character:FindFirstChild("Head") then
                 if plr.Character.Head.Size.X > 2 then plr.Character.Head.Size = Vector3.new(1.2,1.2,1.2); plr.Character.Head.Transparency = 0 end
            end
            
            if not ESP_Cache[plr] then
                ESP_Cache[plr] = {
                    BoxOutline = CreateDrawing("Square", {Thickness = 3, Color = Color3.new(0,0,0), Filled = false}),
                    Box = CreateDrawing("Square", {Thickness = 1, Color = Config.Visuals.Color, Filled = false}),
                    Name = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Color = Color3.new(1,1,1)}),
                    Tracer = CreateDrawing("Line", {Thickness = 1, Color = Config.Visuals.Color})
                }
            end

            local cache = ESP_Cache[plr]
            local hrp = plr.Character.HumanoidRootPart
            local topVec, topOnScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
            local botVec, botOnScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))

            if (topOnScreen or botOnScreen) and plr.Character.Humanoid.Health > 0 then
                local height = botVec.Y - topVec.Y
                local width = height / 1.8
                local position = Vector2.new(topVec.X - (width / 2), topVec.Y)
                local size = Vector2.new(width, height)

                if Config.Visuals.Box then
                    cache.BoxOutline.Visible = true; cache.BoxOutline.Position = position; cache.BoxOutline.Size = size
                    cache.Box.Visible = true; cache.Box.Color = Config.Visuals.Color; cache.Box.Position = position; cache.Box.Size = size
                else cache.Box.Visible = false; cache.BoxOutline.Visible = false end

                if Config.Visuals.Names then
                    cache.Name.Visible = true; cache.Name.Text = plr.Name
                    cache.Name.Position = Vector2.new(topVec.X, topVec.Y - 20)
                else cache.Name.Visible = false end

                if Config.Visuals.Tracers then
                    cache.Tracer.Visible = true; cache.Tracer.Color = Config.Visuals.Color
                    cache.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    cache.Tracer.To = Vector2.new(botVec.X, botVec.Y)
                else cache.Tracer.Visible = false end
            else
                for _, d in pairs(cache) do d.Visible = false end
            end
        else
            RemoveESP(plr)
        end
    end
end

--// SELETOR DE ALVO
local function GetClosestTarget()
    local closestDist = math.huge
    local target = nil

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Humanoid.Health > 0 then
            if Config.AimAssist.TeamCheck and plr.Team == LocalPlayer.Team then continue end

            local part = plr.Character.Head
            
            local checkWall = Config.AimAssist.WallCheck and not Config.AimAssist.Wallbang
            if checkWall and not IsVisible(part) then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if dist < Config.AimAssist.FOV and dist < closestDist then
                    closestDist = dist
                    target = part
                end
            end
        end
    end
    return target
end

--// UNIVERSAL HOOK
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if method == "Raycast" then
            local origin = args[1]
            local direction = args[2]

            local hookTarget = LockedTarget or GetClosestTarget()

            -- Silent Aim
            if Config.AimAssist.Enabled and Config.AimAssist.Silent and hookTarget and hookTarget.Parent then
                local newDir = (hookTarget.Position - origin).Unit * direction.Magnitude
                args[2] = newDir
                return oldNamecall(self, table.unpack(args))
            end
            
            -- No Spread
            if Config.Rage.Enabled and Config.Rage.NoSpread then
                local centerRay = Camera:ViewportPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                if centerRay then
                    args[2] = centerRay.Direction.Unit * direction.Magnitude
                end
                return oldNamecall(self, table.unpack(args))
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    mt.__index = newcclosure(function(self, k)
        local hookTarget = LockedTarget or GetClosestTarget()
        if k == "Hit" and Config.AimAssist.Enabled and Config.AimAssist.Silent and hookTarget then
            if self:IsA("Mouse") then return hookTarget.CFrame end
        end
        return oldIndex(self, k)
    end)
    setreadonly(mt, true)
end)

local FOVCircle = CreateDrawing("Circle", {
    Thickness = 1, Color = Color3.fromRGB(255, 255, 255), NumSides = 60,
    Radius = Config.AimAssist.FOV, Filled = false, Visible = false
})

local SnapLine = CreateDrawing("Line", {
    Thickness = 1, Color = Color3.fromRGB(255, 0, 0), Transparency = 1, Visible = false
})

--// CORE LOOP (V26)
RunService:BindToRenderStep("Nomade_Core_Loop_V26", Enum.RenderPriority.Camera.Value + 1, function()
    UpdateVisuals()
    UpdateChams()
    UpdateGlobalPhysics() -- Atualizar Fly, Noclip, etc
    
    if not Camera then Camera = Workspace.CurrentCamera end

    -- FOV
    FOVCircle.Visible = Config.AimAssist.Enabled
    FOVCircle.Radius = Config.AimAssist.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()

    -- Spinbot
    if Config.Rage.Enabled and Config.Rage.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local speed = Config.Rage.SpinSpeed
        if Config.Rage.Jitter then
             hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(math.random(-speed, speed)), 0)
        else
             hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(speed), 0)
        end
    end

    -- Lock Logic
    local IsHolding = UserInputService:IsMouseButtonPressed(Config.AimAssist.Key)
    
    if Config.AimAssist.Enabled and IsHolding then
        if not LockedTarget then LockedTarget = GetClosestTarget() end
        
        if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:FindFirstChild("Humanoid") and LockedTarget.Parent.Humanoid.Health > 0 then
            
            if Config.Visuals.Snaplines then
                local screenPos, onScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
                if onScreen then
                    SnapLine.Visible = true
                    SnapLine.From = UserInputService:GetMouseLocation()
                    SnapLine.To = Vector2.new(screenPos.X, screenPos.Y)
                else
                    SnapLine.Visible = false
                end
            end

            if Config.AimAssist.Legit then
                local aimPos = LockedTarget.Position
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.lookAt(currentCFrame.Position, aimPos)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, Config.AimAssist.Smoothness)
            end
        else
            LockedTarget = nil; SnapLine.Visible = false
        end
    else
        LockedTarget = nil; SnapLine.Visible = false
    end

    if Config.Misc.SpeedToggle and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.Misc.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = Config.Misc.JumpPower
    end
    
    -- Gravity Slider Logic
    if Config.Global.Gravity then
        workspace.Gravity = Config.Global.Gravity
    end
    
    -- Click TP Logic
    if Config.Global.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local mouse = LocalPlayer:GetMouse()
        if mouse.Target then
            LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)))
            task.wait(0.2) -- Debounce
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

--// INICIALIZAÇÃO DA INTERFACE NOMADE V26
local Menu = UI:CreateWindow("NOMADE MENU")

local AimTab = Menu:Tab("COMBATE")
AimTab:Section("GERAL")
AimTab:Toggle("Ativar Aimbot Global", Config.AimAssist, "Enabled")
AimTab:Toggle("Verificar Time", Config.AimAssist, "TeamCheck")
AimTab:Section("MODOS")
AimTab:Toggle("Legit Aim (Travar)", Config.AimAssist, "Legit")
AimTab:Toggle("Silent Aim (Redirect)", Config.AimAssist, "Silent", nil, true)
AimTab:Section("PENETRAÇÃO")
AimTab:Toggle("Wallbang (Atirar Parede)", Config.AimAssist, "Wallbang", nil, true)
AimTab:Section("AJUSTES")
AimTab:Slider("Raio do FOV", 10, 800, Config.AimAssist, "FOV")
AimTab:Slider("Suavidade Legit", 0, 1, Config.AimAssist, "Smoothness")

local RageTab = Menu:Tab("RAGE")
RageTab:Section("ARMA")
RageTab:Toggle("Ativar Rage", Config.Rage, "Enabled")
RageTab:Toggle("No Spread (Tiro Reto)", Config.Rage, "NoSpread", nil, true)
RageTab:Section("MOVIMENTO")
RageTab:Toggle("Girar (Spinbot)", Config.Rage, "Spinbot", nil, true)
RageTab:Toggle("Jitter (Tremor)", Config.Rage, "Jitter", nil, true)
RageTab:Slider("Velocidade do Giro", 1, 100, Config.Rage, "SpinSpeed")
RageTab:Section("EXPLOITS")
RageTab:Toggle("Hitbox Mágica", Config.AimAssist, "Magic", nil, true)
RageTab:Slider("Tamanho Hitbox", 2, 15, Config.AimAssist, "MagicSize")

local VisualsTab = Menu:Tab("VISUAIS")
VisualsTab:Section("ESP JOGADORES")
VisualsTab:Toggle("Caixa 2D", Config.Visuals, "Box")
VisualsTab:Toggle("Chams (Parede)", Config.Visuals, "Chams") 
VisualsTab:Toggle("Nomes", Config.Visuals, "Names")
VisualsTab:Toggle("Linhas (Tracers)", Config.Visuals, "Tracers")
VisualsTab:Section("AMBIENTE")
VisualsTab:Toggle("X-Ray Map (Transparente)", Config.Visuals, "XRay", ToggleXRay, true)
VisualsTab:Toggle("Fullbright (Luz)", Config.Visuals, "Fullbright") 
VisualsTab:Toggle("Crosshair", Config.Visuals, "Crosshair")
VisualsTab:Section("AUXILIARES")
VisualsTab:Toggle("Linha de Trava", Config.Visuals, "Snaplines")
VisualsTab:Toggle("Verificar Time", Config.Visuals, "TeamCheck")

local GlobalTab = Menu:Tab("GLOBAL")
GlobalTab:Section("GOD MODE")
GlobalTab:Toggle("Modo Deus (No Death)", Config.Global, "GodMode", function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not state) end
end, true)
GlobalTab:Toggle("Vida Infinita (Loop)", Config.Global, "LoopHealth", nil, true)
GlobalTab:Section("MOVIMENTO")
GlobalTab:Toggle("Voar (Fly V3)", Config.Global, "Fly", ToggleFly, true)
GlobalTab:Slider("Velocidade Voo", 10, 300, Config.Global, "FlySpeed") 
GlobalTab:Toggle("NoClip (Atravessar)", Config.Global, "NoClip")
GlobalTab:Toggle("Pulo Infinito", Config.Global, "InfiniteJump")
GlobalTab:Toggle("Click TP (Ctrl+Click)", Config.Global, "ClickTP")
GlobalTab:Section("FÍSICA")
GlobalTab:Toggle("Suspensão V2 (Flutuar)", Config.Global, "Suspension", ToggleSuspension, true)
GlobalTab:Slider("Força Suspensão", 10, 100, Config.Global, "SuspensionPower")
GlobalTab:Slider("Gravidade", 0, 200, Config.Global, "Gravity")
GlobalTab:Toggle("Super Pulo", Config.Global, "HighJump")
GlobalTab:Slider("Altura Pulo", 50, 500, Config.Global, "HighJumpPower")

local TrollTab = Menu:Tab("TROLL")
TrollTab:Section("ANNOY PLAYERS")
TrollTab:Toggle("Fling All (Girar/Tocar)", Config.Troll, "Fling", ToggleFling, true)
TrollTab:Slider("Força Fling", 1000, 50000, Config.Troll, "FlingPower")
TrollTab:Section("CHAT")
TrollTab:Toggle("Spam Chat", Config.Troll, "SpamChat", ToggleSpam)
TrollTab:TextBox("Mensagem Spam", Config.Troll, "SpamMessage")
TrollTab:Section("PERSONAGEM")
TrollTab:Toggle("Invisível (Ghost)", Config.Troll, "Invisible", ToggleInvisible, true)
TrollTab:Toggle("Sit Loop (Sentar)", Config.Troll, "SitLoop")
TrollTab:Toggle("Freeze (Congelar)", Config.Troll, "Freeze")

local MiscTab = Menu:Tab("OUTROS")
MiscTab:Section("INTERFACE")
MiscTab:Slider("Tamanho Menu (Scale)", 0.5, 1.5, Config.Misc, "MenuScale", function(val)
    if MainUIScale then MainUIScale.Scale = val end
end)
MiscTab:Section("PERSONAGEM (LEGIT)")
MiscTab:Toggle("Alterar Movimento", Config.Misc, "SpeedToggle")
MiscTab:Slider("Velocidade", 16, 200, Config.Misc, "WalkSpeed")
MiscTab:Slider("Pulo", 50, 200, Config.Misc, "JumpPower")

local SettingsTab = Menu:Tab("CONFIGURAÇÃO")
SettingsTab:Section("APARÊNCIA")
SettingsTab:Dropdown("Selecionar Tema", {"Nomade", "Halloween", "Natal"}, function(selected)
    UI:ApplyTheme(selected)
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Nomade V26",
    Text = "Troll Tab Added. [INSERT]",
    Duration = 5
})
