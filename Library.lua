--[[
    NOMADE MENU - V30 ULTIMATE EDITION (ROBLOX LUAU)
    TARGET: FPS GAMES (Universal)
    STYLE: Modern / Material Design / Animated / Themed
    AUTHOR: System Architect
    
    UPDATE LOG V30:
    - REFORMULAÇÃO UI: Player Dropdown (Lista de Jogadores).
      - Agora possui tamanho fixo pequeno (Max 200px) com ScrollingFrame.
      - Atualização automática em tempo real (Sem botão).
      - Event-based listener (PlayerAdded/Removing).
    - UPDATE LOG V29/V28:
    - TriggerBot 100% Funcional.
    - Troll "Mamadinha".
    - Kill Menu System.
    - Correções Visuais (ESP/Rendering).

    FEATURES:
    - Combate: Legit, Silent, Rage, Wallbang, TriggerBot.
    - Visuais: Chams, ESP (Box/Name/Line), X-Ray.
    - Global: Fly V3, NoClip, Suspension V2, God Mode, Teleport.
    - Troll: Fling Rotation, Chat Spam, Ghost Mode, Player Target System.
    - Misc: Speed (CFrame), Jump, UI Scale.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--// MANIPULAÇÃO DINÂMICA DA CÂMERA
local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

--// COMPATIBILIDADE COM EXECUTORES & UTILS
local Drawing = Drawing or require(script.Parent.Drawing) -- Fallback
local protect_gui = (syn and syn.protect_gui) or (function(gui) gui.Parent = CoreGui end)
local mouse1press = mouse1press or (function() end)
local mouse1release = mouse1release or (function() end)

--// CLEANUP SYSTEM
local CleanupRegistry = {}

local function RegisterCleanup(obj)
    table.insert(CleanupRegistry, obj)
end

local function PerformCleanup()
    for _, obj in pairs(CleanupRegistry) do
        if typeof(obj) == "Instance" then
            if obj.Parent then obj:Destroy() end
        elseif typeof(obj) == "table" and obj.Remove then
            obj:Remove() 
        elseif typeof(obj) == "table" and obj.Destroy then
            obj:Destroy()
        end
    end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "NomadeChams" or v.Name == "NomadeFlingVelocity" then v:Destroy() end
    end
    table.clear(CleanupRegistry)
end

for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("NomadeUI_") or v.Name:find("NomadeLoader") or v.Name:find("NomadeMobile") then v:Destroy() end
end
PerformCleanup()

--// VARIÁVEIS GLOBAIS DE ESTADO
local LockedTarget = nil
local WindowFocused = true -- Fix para TriggerBot não clicar fora da janela
UserInputService.WindowFocused:Connect(function() WindowFocused = true end)
UserInputService.WindowFocusReleased:Connect(function() WindowFocused = false end)

local ChamsCache = {}
local CrosshairLines = {}
local OriginalTransparency = {}
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}
local FlyVelocity = nil
local FlyGyro = nil
local SuspVelocity = nil 
local FlingVelocity = nil 
local TargetPlayerInstance = nil 
local FakeLagStart = 0

--// LOADER VARIABLES
local MenuToggleKey = Enum.KeyCode.Insert
local IsMobile = false

--// CONFIGURAÇÃO
local Config = {
    AimAssist = {
        Enabled = false,
        TriggerBot = false,
        Silent = false,
        Legit = false,
        Magic = false,
        MagicSize = 5,
        WallCheck = false,
        Wallbang = false,
        FOV = 100,
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
        Skeleton = false, -- Skeleton Added
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
        GodMode = false,
        LoopHealth = false,
        ClickTP = false,
        Gravity = 196.2,
        FreeCam = false,
        FreeCamSpeed = 1,
        FakeLag = false,
        FakeLagDuration = 0.5, -- Segundos
        FakeLagAuto = true -- Reativar automatico
    },
    Troll = {
        Fling = false,
        SpamChat = false,
        Invisible = false,
        SitLoop = false,
        Freeze = false,
        SpamMessage = "NOMADE MENU ON TOP",
        FlingPower = 200, 
        TargetName = "",
        Sarrada = false,
        Mamadinha = false,
        Spectate = false,
        FlingTarget = false
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
    Cyberpunk = {
        Background = Color3.fromRGB(10, 10, 15),
        Sidebar = Color3.fromRGB(15, 15, 20),
        Element = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(255, 0, 110),
        Text = Color3.fromRGB(0, 240, 255)
    },
    CottonCandy = {
        Background = Color3.fromRGB(30, 25, 30),
        Sidebar = Color3.fromRGB(40, 30, 40),
        Element = Color3.fromRGB(50, 40, 50),
        Accent = Color3.fromRGB(255, 150, 200),
        Text = Color3.fromRGB(180, 220, 255)
    },
    DarkVader = {
        Background = Color3.fromRGB(5, 5, 5),
        Sidebar = Color3.fromRGB(10, 10, 10),
        Element = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(200, 20, 20),
        Text = Color3.fromRGB(200, 200, 200)
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
        elseif v:IsA("ScrollingFrame") then
            UI:Tween(v, {ScrollBarImageColor3 = newTheme.Accent})
        else
            UI:Tween(v, {BackgroundColor3 = newTheme.Accent})
        end
    end
    for _, v in pairs(ThemeObjects.Texts) do UI:Tween(v, {TextColor3 = newTheme.Text}) end
end

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
    protect_gui(ScreenGui)
    RegisterCleanup(ScreenGui)

    -- Tooltip
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

    -- Main Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    MainFrame.BackgroundColor3 = CurrentTheme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true 
    MainFrame.Parent = ScreenGui
    table.insert(ThemeObjects.Backgrounds, MainFrame)

    UI:CreateBackgroundAnimation(MainFrame)

    MainUIScale = Instance.new("UIScale")
    MainUIScale.Scale = Config.Misc.MenuScale
    MainUIScale.Parent = MainFrame

    -- Drag Logic
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

    -- Sidebar
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

    -- Title
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
    Version.Text = "Ultimate V30"
    Version.Font = Enum.Font.Gotham
    Version.TextSize = 12
    Version.TextColor3 = Color3.fromRGB(150,150,150)
    Version.BackgroundTransparency = 1
    Version.Position = UDim2.new(0, 0, 0, 50)
    Version.Size = UDim2.new(1, 0, 0, 20)
    Version.ZIndex = 3
    Version.Parent = Sidebar

    -- Tabs
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

    -- Pages
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
            for _, t in pairs(Window.Tabs) do
                if t.Page.Visible then
                    t.Page.Visible = false
                end
                UI:Tween(t.Btn, {BackgroundColor3 = CurrentTheme.Background, TextColor3 = Color3.fromRGB(150,150,150)})
            end
            
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

        function Components:Button(text, callback)
            local BtnFrame = Instance.new("Frame")
            BtnFrame.Size = UDim2.new(1, -10, 0, 35)
            BtnFrame.BackgroundColor3 = CurrentTheme.Element
            BtnFrame.Parent = Page
            table.insert(ThemeObjects.Elements, BtnFrame)
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = BtnFrame
            
            local TextBtn = Instance.new("TextButton")
            TextBtn.Text = text
            TextBtn.Font = Enum.Font.GothamBold
            TextBtn.TextSize = 14
            TextBtn.TextColor3 = CurrentTheme.Text
            TextBtn.Size = UDim2.new(1, 0, 1, 0)
            TextBtn.BackgroundTransparency = 1
            TextBtn.Parent = BtnFrame
            table.insert(ThemeObjects.Texts, TextBtn)
            
            TextBtn.MouseButton1Click:Connect(function()
                UI:Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.Accent}, 0.1)
                task.wait(0.1)
                UI:Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.Element}, 0.2)
                if callback then callback() end
            end)
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
        
        -- DROPDOWN COM SCROLLINGFRAME & TAMANHO FIXO (V30)
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
            
            -- SCROLLING FRAME SETUP
            local ScrollContainer = Instance.new("ScrollingFrame")
            ScrollContainer.Position = UDim2.new(0, 0, 0, 45)
            ScrollContainer.Size = UDim2.new(1, 0, 1, -45)
            ScrollContainer.BackgroundTransparency = 1
            ScrollContainer.BorderSizePixel = 0
            ScrollContainer.ScrollBarThickness = 4
            ScrollContainer.ScrollBarImageColor3 = CurrentTheme.Accent
            ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
            ScrollContainer.Visible = false
            ScrollContainer.Parent = DropFrame
            table.insert(ThemeObjects.Accents, ScrollContainer) 

            local ScrollLayout = Instance.new("UIListLayout")
            ScrollLayout.Padding = UDim.new(0, 5)
            ScrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ScrollLayout.Parent = ScrollContainer

            local ScrollPadding = Instance.new("UIPadding")
            ScrollPadding.PaddingTop = UDim.new(0, 5)
            ScrollPadding.Parent = ScrollContainer
            
            local currentOptions = options
            local opened = false

            local function RefreshOptions(newOpts)
                -- Limpa itens antigos
                for _, child in pairs(ScrollContainer:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                
                currentOptions = newOpts
                
                for i, opt in ipairs(currentOptions) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Text = opt
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 13
                    OptBtn.TextColor3 = Color3.fromRGB(200,200,200)
                    OptBtn.BackgroundColor3 = CurrentTheme.Sidebar
                    OptBtn.Size = UDim2.new(1, -20, 0, 25)
                    OptBtn.Parent = ScrollContainer
                    
                    local OptCorner = Instance.new("UICorner")
                    OptCorner.CornerRadius = UDim.new(0, 4)
                    OptCorner.Parent = OptBtn
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        Label.Text = text .. ": " .. opt
                        opened = false
                        UI:Tween(DropFrame, {Size = UDim2.new(1, -10, 0, 45)})
                        ScrollContainer.Visible = false
                        Arrow.Text = "v"
                        if callback then callback(opt) end
                    end)
                end
                
                ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, (#currentOptions * 30) + 10)
                
                -- Se aberto, recalcular tamanho mantendo limite
                if opened then
                    local totalHeight = (#currentOptions * 30) + 55
                    local maxHeight = 200 -- Limite de altura
                    UI:Tween(DropFrame, {Size = UDim2.new(1, -10, 0, math.min(totalHeight, maxHeight))})
                end
            end

            DropBtn.MouseButton1Click:Connect(function()
                opened = not opened
                if opened then
                    local totalHeight = (#currentOptions * 30) + 55
                    local maxHeight = 200 -- Limite de altura
                    UI:Tween(DropFrame, {Size = UDim2.new(1, -10, 0, math.min(totalHeight, maxHeight))})
                    ScrollContainer.Visible = true
                    Arrow.Text = "^"
                else
                    UI:Tween(DropFrame, {Size = UDim2.new(1, -10, 0, 45)})
                    task.wait(0.2)
                    ScrollContainer.Visible = false
                    Arrow.Text = "v"
                end
            end)
            
            RefreshOptions(options)
            
            return {Refresh = RefreshOptions}
        end
        
        function Components:TextBox(text, configTable, configKey, callback)
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
            Input.Position = UDim2.new(0.55, 0, 0.5, -12.5)
            Input.Parent = BoxFrame
            
            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 4)
            InputCorner.Parent = Input

            Input.FocusLost:Connect(function()
                configTable[configKey] = Input.Text
                if callback then callback(Input.Text) end
            end)
        end

        return Components
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == MenuToggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
    
    -- Botão de Fechar/Cleanup
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(200,50,50)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.Parent = Sidebar
    CloseBtn.MouseButton1Click:Connect(function()
        PerformCleanup()
        ScreenGui:Destroy()
    end)

    return Window
end

--// SISTEMAS MECÂNICOS
local function CreateDrawing(type, props)
    local d = Drawing.new(type)
    for k, v in pairs(props) do d[k] = v end
    RegisterCleanup(d)
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

--// FULLBRIGHT SYSTEM (COM RESTORE)
local function ToggleFullbright(state)
    if state then
        OriginalLighting.Brightness = Lighting.Brightness
        OriginalLighting.ClockTime = Lighting.ClockTime
        OriginalLighting.FogEnd = Lighting.FogEnd
        OriginalLighting.GlobalShadows = Lighting.GlobalShadows
        OriginalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end
end

--// GLOBAL FUNCTIONS (V28 REFINED)
local function ToggleFly(state)
    if state then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local attachment = Instance.new("Attachment", hrp)
        attachment.Name = "FlyAttachment"
        
        FlyVelocity = Instance.new("LinearVelocity")
        FlyVelocity.Attachment0 = attachment
        FlyVelocity.MaxForce = 10000
        FlyVelocity.VectorVelocity = Vector3.new(0, 0, 0)
        FlyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World 
        FlyVelocity.Parent = hrp
        
        FlyGyro = Instance.new("AlignOrientation")
        FlyGyro.Attachment0 = attachment
        FlyGyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
        FlyGyro.MaxTorque = 100000
        FlyGyro.Responsiveness = 200
        FlyGyro.Parent = hrp
        
        if LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = true
        end
    else
        if FlyVelocity then FlyVelocity:Destroy() end
        if FlyGyro then FlyGyro:Destroy() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
                if v.Name == "FlyAttachment" then v:Destroy() end
            end
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
        end
    end
end

local function ToggleSuspension(state)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if state then
        if not SuspVelocity then
            local att = Instance.new("Attachment", hrp)
            att.Name = "SuspAtt"
            SuspVelocity = Instance.new("VectorForce")
            SuspVelocity.Attachment0 = att
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
local function UpdateTarget(name)
    if name == "" then TargetPlayerInstance = nil return "Nenhum" end
    for _, v in pairs(Players:GetPlayers()) do
        if string.sub(string.lower(v.Name), 1, #name) == string.lower(name) or 
           string.sub(string.lower(v.DisplayName), 1, #name) == string.lower(name) then
            TargetPlayerInstance = v
            return v.Name
        end
    end
    TargetPlayerInstance = nil
    return "Não Encontrado"
end

-- Novo Sistema de Fling (Touch/Linear)
local function ToggleFling(state)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if state and hrp then
        Config.Global.NoClip = true 
        -- Usa LinearVelocity para mover em direção ao alvo ou gerar impacto de alta velocidade
        local att = Instance.new("Attachment", hrp)
        att.Name = "FlingAtt"
        
        FlingVelocity = Instance.new("LinearVelocity")
        FlingVelocity.Name = "NomadeFlingVelocity"
        FlingVelocity.Attachment0 = att
        FlingVelocity.MaxForce = math.huge
        FlingVelocity.VectorVelocity = Vector3.new(0, 0, 0) 
        FlingVelocity.Parent = hrp
        
        -- Angula Velocity suave para "girar" levemente, evitando detecção de spin absurda
        local ang = Instance.new("AngularVelocity")
        ang.Name = "FlingAng"
        ang.Attachment0 = att
        ang.AngularVelocity = Vector3.new(0, 100, 0) -- Rotação controlada
        ang.MaxTorque = math.huge
        ang.Parent = hrp
    else
        Config.Global.NoClip = false
        if FlingVelocity then FlingVelocity:Destroy() FlingVelocity = nil end
        if hrp then
             for _,v in pairs(hrp:GetChildren()) do
                 if v.Name == "FlingAtt" or v.Name == "FlingAng" then v:Destroy() end
             end
             hrp.RotVelocity = Vector3.new(0,0,0)
             hrp.Velocity = Vector3.new(0,0,0)
        end
        if char:FindFirstChild("Humanoid") then char.Humanoid.Sit = false end
    end
end

local function ToggleSpam(state)
    if state then
        task.spawn(function()
            while Config.Troll.SpamChat do
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    -- Novo Sistema de Chat
                    local ch = TextChatService:FindFirstChild("TextChannels")
                    if ch and ch:FindFirstChild("RBXGeneral") then
                         ch.RBXGeneral:SendAsync(Config.Troll.SpamMessage)
                    end
                else
                    -- Sistema Antigo
                    local args = {[1] = Config.Troll.SpamMessage, [2] = "All"}
                    local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                    if event then
                        pcall(function() event:FindFirstChild("SayMessageRequest"):FireServer(unpack(args)) end)
                    end
                end
                task.wait(2.5) -- Spam mais lento para evitar kick imediato
            end
        end)
    end
end

local function ToggleInvisible(state)
    -- Método de Desync Simples (Ghost Mode Visual)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if state then
            -- Apenas visualmente invisivel localmente e manipulação de joint
             for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then
                    if v.Name ~= "HumanoidRootPart" then v.Transparency = 1 end
                end
            end
        else
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then
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
        local camCFrame = Camera.CFrame

        -- Fly Logic
        if Config.Global.Fly and FlyVelocity then
            local moveDir = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * math.clamp(Config.Global.FlySpeed, 0, 300)
            end
            FlyVelocity.VectorVelocity = moveDir
            if FlyGyro then FlyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camCFrame.LookVector) end
        end
        
        -- Suspension Update
        if Config.Global.Suspension and SuspVelocity then
            local dampening = 0.98 + (Config.Global.SuspensionPower / 5000)
            SuspVelocity.Force = Vector3.new(0, workspace.Gravity * hrp.AssemblyMass * dampening, 0)
        end
        
        -- Infinite Jump
        if Config.Global.InfiniteJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if hum:GetState() == Enum.HumanoidStateType.Freefall then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end

        -- CFrame Speed (Bypass WalkSpeed Detection)
        if Config.Misc.SpeedToggle then
            local moveVec = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + camCFrame.RightVector end
            
            moveVec = Vector3.new(moveVec.X, 0, moveVec.Z) -- Ignorar Y no chão
            if moveVec.Magnitude > 0 then
                -- Move CFrame diretamente
                local speed = Config.Misc.WalkSpeed / 50 -- Ajuste de escala
                hrp.CFrame = hrp.CFrame + (moveVec.Unit * speed)
            end
        end

        -- CFrame Jump / HighJump
        if Config.Global.HighJump then
             -- Se o anti-cheat detecta JumpPower, não usamos.
             -- Se o usuário quer HighJump, usamos Velocity no momento do pulo.
             if UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial ~= Enum.Material.Air then
                 hrp.Velocity = Vector3.new(hrp.Velocity.X, Config.Global.HighJumpPower, hrp.Velocity.Z)
             end
        end
        
        -- Loop Health
        if Config.Global.LoopHealth then
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
        
        -- NoClip
        if Config.Global.NoClip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
        
        -- Free Cam (V30 New)
        if Config.Global.FreeCam then
            -- Override camera type to Scriptable
            Camera.CameraType = Enum.CameraType.Scriptable
            local speed = Config.Global.FreeCamSpeed
            local camCFrame = Camera.CFrame
            local moveVector = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector - Vector3.new(0, 1, 0) end
            
            Camera.CFrame = camCFrame + (moveVector * speed)
        end
        
        -- Fake Lag Logic (V30 New)
        if Config.Global.FakeLag then
            if tick() - FakeLagStart < Config.Global.FakeLagDuration then
                hrp.Anchored = true
            else
                hrp.Anchored = false
                if Config.Global.FakeLagAuto then
                    -- Wait small delay before re-anchoring to allow replication
                    if tick() - FakeLagStart > Config.Global.FakeLagDuration + 0.05 then
                        FakeLagStart = tick()
                    end
                else
                    Config.Global.FakeLag = false
                end
            end
        else
            if not Config.Troll.Freeze then hrp.Anchored = false end
        end
        
        -- TROLL LOOPS
        if Config.Troll.SitLoop then hum.Sit = true end
        if Config.Troll.Freeze then hrp.Anchored = true end
        
        if Config.Troll.Sarrada and TargetPlayerInstance and TargetPlayerInstance.Character and TargetPlayerInstance.Character:FindFirstChild("HumanoidRootPart") then
            local targetHR = TargetPlayerInstance.Character.HumanoidRootPart
            local offset = targetHR.CFrame * CFrame.new(0, 0, 1.1) -- Atrás
            local thrust = math.sin(tick() * 18) * 0.5
            hrp.CFrame = offset * CFrame.new(0, 0, thrust)
            hrp.Velocity = Vector3.new(0,0,0)
            Config.Global.NoClip = true
        end
        
        if Config.Troll.Mamadinha and TargetPlayerInstance and TargetPlayerInstance.Character and TargetPlayerInstance.Character:FindFirstChild("HumanoidRootPart") then
            local targetHR = TargetPlayerInstance.Character.HumanoidRootPart
            -- Frente do player, altura agachada, virado para ele (Corrigido V30)
            local offset = targetHR.CFrame * CFrame.new(0, -3, -2) * CFrame.Angles(0, math.pi, 0)
            local bob = math.sin(tick() * 20) * 0.5
            hrp.CFrame = offset * CFrame.new(0, bob, 0)
            hrp.Velocity = Vector3.new(0,0,0)
            Config.Global.NoClip = true
        end
        
        -- TOUCH FLING LOGIC (Loop)
        if Config.Troll.Fling and FlingVelocity then
            -- Mover erraticamente ao redor da posição atual ou alvos
            local targetPos = hrp.Position
            
            -- Se tiver um alvo específico, vá até ele. Se for Fling All, procure o mais próximo
            local flingTarget = nil
            if Config.Troll.FlingTarget and TargetPlayerInstance then
                flingTarget = TargetPlayerInstance.Character and TargetPlayerInstance.Character:FindFirstChild("HumanoidRootPart")
            else
                -- Procura alguém perto
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        if (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude < 50 then
                            flingTarget = p.Character.HumanoidRootPart
                            break
                        end
                    end
                end
            end

            if flingTarget then
                -- Move para dentro do alvo com alta velocidade
                hrp.CFrame = CFrame.new(flingTarget.Position + Vector3.new(math.random(-2,2), 0, math.random(-2,2))) * CFrame.Angles(math.random(0,360), math.random(0,360), math.random(0,360))
                FlingVelocity.VectorVelocity = Vector3.new(10000, 10000, 10000) -- Impacto
            else
                 -- Idle spin
                 FlingVelocity.VectorVelocity = Vector3.new(0, 50, 0)
            end
            
            -- Rotação rápida para causar colisão física
            hrp.RotVelocity = Vector3.new(Config.Troll.FlingPower, Config.Troll.FlingPower, Config.Troll.FlingPower)
        end
        
        -- HITBOX EXPANDER LOOP
        if Config.AimAssist.Magic then
             for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    if Config.AimAssist.TeamCheck and p.Team == LocalPlayer.Team then continue end
                    local h = p.Character.Head
                    h.Size = Vector3.new(Config.AimAssist.MagicSize, Config.AimAssist.MagicSize, Config.AimAssist.MagicSize)
                    h.CanCollide = false
                    h.Transparency = 0.5
                end
             end
        end
    end
end

--// CHAMS
local function UpdateChams()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local isTeam = (Config.Visuals.TeamCheck and plr.Team == LocalPlayer.Team)
            
            if Config.Visuals.Chams and not isTeam then
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
                    RegisterCleanup(highlight)
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

--// ESP & VISUALS (CORRIGIDO V31: SKELETON + BETTER BOX)
local ESP_Cache = {}

local function RemoveESP(plr)
    if ESP_Cache[plr] then
        for k, d in pairs(ESP_Cache[plr]) do 
            if k == "Skeleton" then
                for _, line in pairs(d) do line:Remove() end
            else
                d:Remove() 
            end
        end
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
        
        local cx = Camera.ViewportSize.X / 2
        local cy = Camera.ViewportSize.Y / 2
        
        CrosshairLines[1].From = Vector2.new(cx-6, cy)
        CrosshairLines[1].To = Vector2.new(cx+6, cy)
        CrosshairLines[2].From = Vector2.new(cx, cy-6)
        CrosshairLines[2].To = Vector2.new(cx, cy+6)
        
        for _, l in pairs(CrosshairLines) do l.Visible = true end
    else
        for _, l in pairs(CrosshairLines) do l.Visible = false end
    end

    -- ESP Loop
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
            
            local isTeammate = (plr.Team == LocalPlayer.Team)
            if Config.Visuals.TeamCheck and isTeammate then RemoveESP(plr) continue end
            
            if not ESP_Cache[plr] then
                ESP_Cache[plr] = {
                    BoxOutline = CreateDrawing("Square", {Thickness = 3, Color = Color3.new(0,0,0), Filled = false}),
                    Box = CreateDrawing("Square", {Thickness = 1, Color = Config.Visuals.Color, Filled = false}),
                    Name = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Color = Color3.new(1,1,1)}),
                    Tracer = CreateDrawing("Line", {Thickness = 1, Color = Config.Visuals.Color}),
                    Skeleton = {} -- Table for dynamic lines
                }
            end

            local cache = ESP_Cache[plr]
            local hrp = plr.Character.HumanoidRootPart
            local hum = plr.Character.Humanoid
            
            -- FIX V31: Check Root Part visibility mainly to prevent flickering
            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(hrp.Position)

            -- Verifica se o jogador está vivo e se o root part está na tela (mais estável)
            if rootOnScreen and hum.Health > 0 then
                
                -- BOX LOGIC
                local topPos = hrp.Position + Vector3.new(0, 3, 0)
                local botPos = hrp.Position - Vector3.new(0, 3.5, 0)
                local topVec = Camera:WorldToViewportPoint(topPos)
                local botVec = Camera:WorldToViewportPoint(botPos)

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
                
                -- SKELETON LOGIC (NEW)
                if Config.Visuals.Skeleton then
                    local connections = {}
                    if hum.RigType == Enum.HumanoidRigType.R15 then
                        connections = {
                            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, 
                            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
                        }
                    else -- R6
                        connections = {
                            {"Head", "Torso"}, 
                            {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, 
                            {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
                        }
                    end
                    
                    for i, pair in ipairs(connections) do
                        local p1 = plr.Character:FindFirstChild(pair[1])
                        local p2 = plr.Character:FindFirstChild(pair[2])
                        if p1 and p2 then
                            local pos1, v1 = Camera:WorldToViewportPoint(p1.Position)
                            local pos2, v2 = Camera:WorldToViewportPoint(p2.Position)
                            
                            if v1 and v2 then
                                if not cache.Skeleton[i] then
                                    cache.Skeleton[i] = CreateDrawing("Line", {Thickness = 1, Color = Config.Visuals.Color})
                                end
                                cache.Skeleton[i].Visible = true
                                cache.Skeleton[i].Color = Config.Visuals.Color
                                cache.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                                cache.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                            elseif cache.Skeleton[i] then
                                cache.Skeleton[i].Visible = false
                            end
                        end
                    end
                    -- Hide unused lines
                    for k, v in pairs(cache.Skeleton) do
                        if k > #connections then v.Visible = false end
                    end
                else
                    for _, v in pairs(cache.Skeleton) do v.Visible = false end
                end

            else
                for k, d in pairs(cache) do
                    if k == "Skeleton" then
                        for _, v in pairs(d) do v.Visible = false end
                    else
                        d.Visible = false 
                    end
                end
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

--// UNIVERSAL HOOK (CORRIGIDO PARA RAYCAST PARAMS & WALLBANG)
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if method == "Raycast" then
            -- Argumentos: Origin, Direction, RaycastParams
            local origin = args[1]
            local direction = args[2]
            local params = args[3]

            local hookTarget = LockedTarget or GetClosestTarget()

            -- Silent Aim Redirect
            if Config.AimAssist.Enabled and Config.AimAssist.Silent and hookTarget and hookTarget.Parent then
                local newDir = (hookTarget.Position - origin).Unit * direction.Magnitude
                args[2] = newDir -- Modifica a direção
                
                -- Wallbang Logic (Modificar Params)
                if Config.AimAssist.Wallbang and params and typeof(params) == "RaycastParams" then
                    -- Adiciona a si mesmo e a câmera na lista de ignorados, e força o filtro a respeitar
                    params.FilterType = Enum.RaycastFilterType.Include
                    params.FilterDescendantsInstances = {hookTarget.Parent} -- Tenta acertar APENAS o inimigo
                end
                
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

--// CORE LOOP (V28)
RunService:BindToRenderStep("Nomade_Core_Loop_V28", Enum.RenderPriority.Camera.Value + 1, function()
    UpdateVisuals()
    UpdateChams()
    UpdateGlobalPhysics()
    
    if not Camera then Camera = Workspace.CurrentCamera end

    -- FOV Update
    FOVCircle.Visible = Config.AimAssist.Enabled
    FOVCircle.Radius = Config.AimAssist.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()

    -- Spinbot Update
    if Config.Rage.Enabled and Config.Rage.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local speed = Config.Rage.SpinSpeed
        if Config.Rage.Jitter then
             hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(math.random(-speed, speed)), 0)
        else
             hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(speed), 0)
        end
    end

    -- TriggerBot Logic (100% Funcional)
    if Config.AimAssist.TriggerBot and WindowFocused then -- Check WindowFocused
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        if target and target.Parent then
            local plr = Players:GetPlayerFromCharacter(target.Parent)
            if plr and plr ~= LocalPlayer then
                if not (Config.AimAssist.TeamCheck and plr.Team == LocalPlayer.Team) then
                    mouse1press()
                    task.wait(0.05)
                    mouse1release()
                end
            end
        end
    end

    -- Aim Lock Logic
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

    -- Gravity Slider
    if Config.Global.Gravity ~= 196.2 then
        workspace.Gravity = Config.Global.Gravity
    end
    
    -- Click TP
    if Config.Global.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local mouse = LocalPlayer:GetMouse()
        if mouse.Target then
            LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)))
            task.wait(0.2)
        end
    end
    
    -- View Target
    if Config.Troll.Spectate and TargetPlayerInstance and TargetPlayerInstance.Character then
        Camera.CameraSubject = TargetPlayerInstance.Character:FindFirstChild("Humanoid")
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

--// INICIALIZAÇÃO DA INTERFACE NOMADE V30 (WRAPPED)
local function StartNomade()
    --// NOTIFICATION SYSTEM
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NomadeUI_" .. math.random(1000,9999)
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    protect_gui(ScreenGui)
    RegisterCleanup(ScreenGui)

    local NotifyContainer = Instance.new("Frame")
    NotifyContainer.Position = UDim2.new(1, -270, 1, -120) -- Bottom Right Corner
    NotifyContainer.Size = UDim2.new(0, 250, 0, 100)
    NotifyContainer.BackgroundTransparency = 1
    NotifyContainer.Parent = ScreenGui

    local NotifyLayout = Instance.new("UIListLayout")
    NotifyLayout.Padding = UDim.new(0, 5)
    NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifyLayout.Parent = NotifyContainer

    local function SendNotification(title, text, duration)
        local Notification = Instance.new("Frame")
        Notification.Size = UDim2.new(1, 0, 0, 0) -- Start small for animation
        Notification.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        Notification.BorderSizePixel = 0
        Notification.ClipsDescendants = true
        Notification.Parent = NotifyContainer
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Notification
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(120, 90, 255)
        Stroke.Thickness = 1.5
        Stroke.Parent = Notification
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Text = title
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 14
        TitleLabel.TextColor3 = Color3.fromRGB(120, 90, 255)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Position = UDim2.new(0, 10, 0, 5)
        TitleLabel.Size = UDim2.new(1, -20, 0, 20)
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = Notification
        
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Text = text
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.TextSize = 12
        DescLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Position = UDim2.new(0, 10, 0, 25)
        DescLabel.Size = UDim2.new(1, -20, 0, 30)
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.TextWrapped = true
        DescLabel.Parent = Notification
        
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 60)}):Play()
        
        task.delay(duration or 3, function()
            local t = TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
            t:Play()
            t.Completed:Wait()
            Notification:Destroy()
        end)
    end

    -- Disable default notifications
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", false)
    end)
    SendNotification("Nomade V30", "Sistema inicializado com sucesso.", 5)

    -- Create Menu
    local Menu = UI:CreateWindow("NOMADE MENU")

    local AimTab = Menu:Tab("COMBATE")
    AimTab:Section("GERAL")
    AimTab:Toggle("Ativar Aimbot Global", Config.AimAssist, "Enabled")
    AimTab:Toggle("Ignorar Time (Team Check)", Config.AimAssist, "TeamCheck")
    AimTab:Toggle("TriggerBot (Auto Fire)", Config.AimAssist, "TriggerBot")
    AimTab:Section("MODOS")
    AimTab:Toggle("Legit Aim (Suave)", Config.AimAssist, "Legit")
    AimTab:Toggle("Silent Aim (Invisível)", Config.AimAssist, "Silent", nil, true)
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
    RageTab:Toggle("Hitbox Expander (Loop)", Config.AimAssist, "Magic", nil, true)
    RageTab:Slider("Tamanho Hitbox", 2, 20, Config.AimAssist, "MagicSize")

    local VisualsTab = Menu:Tab("VISUAIS")
    VisualsTab:Section("ESP JOGADORES")
    VisualsTab:Toggle("Caixa 2D", Config.Visuals, "Box")
    VisualsTab:Toggle("Esqueleto (Skeleton)", Config.Visuals, "Skeleton")
    VisualsTab:Toggle("Chams (Parede)", Config.Visuals, "Chams") 
    VisualsTab:Toggle("Nomes", Config.Visuals, "Names")
    VisualsTab:Toggle("Linhas (Tracers)", Config.Visuals, "Tracers")
    VisualsTab:Section("CONFIGURAÇÃO ESP")
    VisualsTab:Toggle("Ocultar Time (Team Check)", Config.Visuals, "TeamCheck")
    VisualsTab:Section("AMBIENTE")
    VisualsTab:Toggle("X-Ray Map", Config.Visuals, "XRay", ToggleXRay, true)
    VisualsTab:Toggle("Fullbright (Luz)", Config.Visuals, "Fullbright", ToggleFullbright) 
    VisualsTab:Toggle("Crosshair (Mira)", Config.Visuals, "Crosshair")

    local GlobalTab = Menu:Tab("GLOBAL")
    GlobalTab:Section("MOVIMENTO AVANÇADO")
    GlobalTab:Toggle("Free Cam (Camera Livre)", Config.Global, "FreeCam")
    GlobalTab:Slider("Velocidade Camera", 0.1, 5, Config.Global, "FreeCamSpeed")
    GlobalTab:Toggle("Voar (Linear Fly)", Config.Global, "Fly", ToggleFly, true)
    GlobalTab:Slider("Velocidade Voo", 10, 300, Config.Global, "FlySpeed") 
    GlobalTab:Toggle("NoClip (Atravessar)", Config.Global, "NoClip")
    GlobalTab:Section("REDE / NETWORK")
    GlobalTab:Toggle("Fake Lag (Blink)", Config.Global, "FakeLag")
    GlobalTab:Toggle("Reativar Automatico", Config.Global, "FakeLagAuto")
    GlobalTab:Slider("Duração Lag (Sec)", 0.1, 5, Config.Global, "FakeLagDuration")
    GlobalTab:Section("FÍSICA")
    GlobalTab:Toggle("Pulo Infinito", Config.Global, "InfiniteJump")
    GlobalTab:Toggle("Click TP (Ctrl+Click)", Config.Global, "ClickTP")
    GlobalTab:Toggle("Suspensão V2", Config.Global, "Suspension", ToggleSuspension, true)
    GlobalTab:Slider("Força Suspensão", 10, 100, Config.Global, "SuspensionPower")
    GlobalTab:Slider("Gravidade", 0, 200, Config.Global, "Gravity")
    GlobalTab:Toggle("Super Pulo", Config.Global, "HighJump")
    GlobalTab:Slider("Altura Pulo", 50, 500, Config.Global, "HighJumpPower")
    GlobalTab:Section("GOD MODE")
    GlobalTab:Toggle("Modo Deus (No-Death)", Config.Global, "GodMode", function(state)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then 
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not state)
            hum.BreakJointsOnDeath = not state
        end
    end, true)
    GlobalTab:Toggle("Vida Infinita (Loop)", Config.Global, "LoopHealth", nil, true)

    local TrollTab = Menu:Tab("TROLL")
    TrollTab:Section("SELEÇÃO DE ALVO")

    local function GetPlayers()
        local t = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(t, p.Name) end
        end
        return t
    end

    local PlayerDropdown = TrollTab:Dropdown("Selecionar Alvo", GetPlayers(), function(val)
        UpdateTarget(val)
    end)

    local function UpdateList()
        PlayerDropdown.Refresh(GetPlayers())
    end

    Players.PlayerAdded:Connect(UpdateList)
    Players.PlayerRemoving:Connect(UpdateList)

    TrollTab:Section("AÇÕES DE ALVO")
    TrollTab:Toggle("Sarrada (Atrás)", Config.Troll, "Sarrada", nil, true)
    TrollTab:Toggle("Mamadinha (Frente)", Config.Troll, "Mamadinha", nil, true)
    TrollTab:Toggle("Spectate (Ver Câmera)", Config.Troll, "Spectate")
    TrollTab:Toggle("Fling Alvo (Kill)", Config.Troll, "FlingTarget", nil, true)
    TrollTab:Button("Teleportar Atrás", function()
        if TargetPlayerInstance and TargetPlayerInstance.Character and TargetPlayerInstance.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
            LocalPlayer.Character:SetPrimaryPartCFrame(TargetPlayerInstance.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        end
    end)
    TrollTab:Section("ANNOY PLAYERS (GLOBAL)")
    TrollTab:Toggle("Touch Fling (Girar/Tocar)", Config.Troll, "Fling", ToggleFling, true)
    TrollTab:Slider("Rotação Fling", 100, 5000, Config.Troll, "FlingPower")
    TrollTab:Section("CHAT")
    TrollTab:Toggle("Spam Chat (Universal)", Config.Troll, "SpamChat", ToggleSpam)
    TrollTab:TextBox("Mensagem Spam", Config.Troll, "SpamMessage")
    TrollTab:Section("PERSONAGEM")
    TrollTab:Toggle("Invisível (Desync)", Config.Troll, "Invisible", ToggleInvisible, true)
    TrollTab:Toggle("Sit Loop (Sentar)", Config.Troll, "SitLoop")
    TrollTab:Toggle("Freeze (Congelar)", Config.Troll, "Freeze")

    local MiscTab = Menu:Tab("OUTROS")
    MiscTab:Section("INTERFACE")
    MiscTab:Slider("Tamanho Menu (Scale)", 0.5, 1.5, Config.Misc, "MenuScale", function(val)
        if MainUIScale then MainUIScale.Scale = val end
    end)
    MiscTab:Button("Unload & Cleanup", function()
        PerformCleanup()
        SendNotification("Sistema", "Script Unloaded", 2)
    end)
    MiscTab:Section("PERSONAGEM (LEGIT)")
    MiscTab:Toggle("Alterar Movimento (CFrame)", Config.Misc, "SpeedToggle")
    MiscTab:Slider("Velocidade Extra", 1, 100, Config.Misc, "WalkSpeed")

    local SettingsTab = Menu:Tab("CONFIGURAÇÃO")
    SettingsTab:Section("APARÊNCIA")
    SettingsTab:Dropdown("Selecionar Tema", {"Nomade", "Cyberpunk", "CottonCandy", "DarkVader", "Halloween", "Natal"}, function(selected)
        UI:ApplyTheme(selected)
    end)
    SettingsTab:Section("DISPOSITIVO")
    SettingsTab:Button("Alternar PC / Mobile", function()
        IsMobile = not IsMobile
        if IsMobile then Config.Misc.MenuScale = 1.2 else Config.Misc.MenuScale = 1.0 end
        PerformCleanup()
        StartNomade()
    end)
    SettingsTab:Section("SISTEMA")
    SettingsTab:Button("Destruir Menu (Kill)", function()
        PerformCleanup()
        game:GetService("CoreGui").NomadeUI_26:Destroy() -- Tentativa genérica
        if MainFrame then MainFrame.Parent:Destroy() end
    end)

    --// WATERMARK SYSTEM (PC ONLY)
    if not IsMobile then
        local WatermarkFrame = Instance.new("Frame")
        WatermarkFrame.Size = UDim2.new(0, 220, 0, 50)
        WatermarkFrame.Position = UDim2.new(0, 15, 1, -65) -- Bottom Left (Improved Pos)
        WatermarkFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        WatermarkFrame.BorderSizePixel = 0
        WatermarkFrame.Parent = ScreenGui
        
        local WCorner = Instance.new("UICorner")
        WCorner.CornerRadius = UDim.new(0, 8)
        WCorner.Parent = WatermarkFrame
        
        local WStroke = Instance.new("UIStroke")
        WStroke.Color = Color3.fromRGB(120, 90, 255)
        WStroke.Thickness = 1.5
        WStroke.Parent = WatermarkFrame
        
        local WTitle = Instance.new("TextLabel")
        WTitle.Text = "NOMADE V30 ULTIMATE"
        WTitle.Font = Enum.Font.GothamBlack
        WTitle.TextSize = 14
        WTitle.TextColor3 = Color3.fromRGB(120, 90, 255)
        WTitle.BackgroundTransparency = 1
        WTitle.Position = UDim2.new(0, 10, 0, 5)
        WTitle.Size = UDim2.new(1, -20, 0, 20)
        WTitle.TextXAlignment = Enum.TextXAlignment.Left
        WTitle.Parent = WatermarkFrame
        
        local WStats = Instance.new("TextLabel")
        WStats.Font = Enum.Font.Gotham
        WStats.TextSize = 12
        WStats.TextColor3 = Color3.fromRGB(200, 200, 200)
        WStats.BackgroundTransparency = 1
        WStats.Position = UDim2.new(0, 10, 0, 25)
        WStats.Size = UDim2.new(1, -20, 0, 20)
        WStats.TextXAlignment = Enum.TextXAlignment.Left
        WStats.Parent = WatermarkFrame
        
        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 90, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        }
        Gradient.Rotation = 45
        Gradient.Parent = WStroke
        
        RunService.RenderStepped:Connect(function(dt)
            if not WatermarkFrame.Parent then return end
            local fps = math.floor(1 / dt)
            local time = math.floor(workspace.DistributedGameTime)
            WStats.Text = string.format("FPS: %d  |  TEMPO: %ds", fps, time)
        end)
    end

    --// MOBILE BUTTON SYSTEM
    if IsMobile then
        local MobileGui = Instance.new("ScreenGui")
        MobileGui.Name = "NomadeMobile"
        MobileGui.IgnoreGuiInset = true -- Better for mobile placement
        protect_gui(MobileGui)
        RegisterCleanup(MobileGui)
        
        local MobBtn = Instance.new("TextButton")
        MobBtn.Name = "NomadeOpen"
        MobBtn.Text = "N"
        MobBtn.Font = Enum.Font.GothamBlack
        MobBtn.TextSize = 24
        MobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        MobBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        MobBtn.Size = UDim2.new(0, 50, 0, 50)
        MobBtn.Position = UDim2.new(0, 50, 0.5, -25) -- Adjusted position
        MobBtn.AutoButtonColor = false
        MobBtn.Active = true
        MobBtn.Parent = MobileGui
        
        local MC = Instance.new("UICorner")
        MC.CornerRadius = UDim.new(0, 16) -- Slightly more rounded
        MC.Parent = MobBtn
        
        local MStroke = Instance.new("UIStroke")
        MStroke.Color = Color3.fromRGB(120, 90, 255)
        MStroke.Thickness = 2
        MStroke.Parent = MobBtn
        
        local dragging = false
        local dragStart = nil
        local startPos = nil
        local hasMoved = false

        MobBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                hasMoved = false
                dragStart = input.Position
                startPos = MobBtn.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                if delta.Magnitude > 10 then
                    hasMoved = true
                    MobBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)

        MobBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                if not hasMoved then
                    ScreenGui.Enabled = not ScreenGui.Enabled
                end
            end
        end)
    end
end

--// LOADER SYSTEM IMPROVED V30
local function CreateLoader()
    local LoaderGui = Instance.new("ScreenGui")
    LoaderGui.Name = "NomadeLoader"
    LoaderGui.IgnoreGuiInset = true
    protect_gui(LoaderGui)
    RegisterCleanup(LoaderGui)
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = LoaderGui
    
    -- Background Animation reused from main UI
    UI:CreateBackgroundAnimation(MainFrame)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(120, 90, 255)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.5
    Stroke.Parent = MainFrame
    
    -- Header Area
    local Title = Instance.new("TextLabel")
    Title.Text = "NOMADE V30"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 32
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 20)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Parent = MainFrame
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Text = "EDIÇÃO FINAL"
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextSize = 14
    SubTitle.TextColor3 = Color3.fromRGB(120, 90, 255)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Position = UDim2.new(0, 0, 0, 55)
    SubTitle.Size = UDim2.new(1, 0, 0, 20)
    SubTitle.Parent = MainFrame

    -- Update Log Container
    local LogContainer = Instance.new("Frame")
    LogContainer.Size = UDim2.new(0.9, 0, 0.45, 0)
    LogContainer.Position = UDim2.new(0.05, 0, 0.25, 0)
    LogContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    LogContainer.Parent = MainFrame
    
    local LogCorner = Instance.new("UICorner")
    LogCorner.CornerRadius = UDim.new(0, 8)
    LogCorner.Parent = LogContainer
    
    local LogLabel = Instance.new("TextLabel")
    LogLabel.Text = "ATUALIZAÇÕES"
    LogLabel.Font = Enum.Font.GothamBold
    LogLabel.TextSize = 12
    LogLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    LogLabel.BackgroundTransparency = 1
    LogLabel.Size = UDim2.new(1, -20, 0, 20)
    LogLabel.Position = UDim2.new(0, 10, 0, 5)
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogLabel.Parent = LogContainer
    
    local LogBox = Instance.new("ScrollingFrame")
    LogBox.Position = UDim2.new(0, 10, 0, 25)
    LogBox.Size = UDim2.new(1, -20, 1, -35)
    LogBox.BackgroundTransparency = 1
    LogBox.BorderSizePixel = 0
    LogBox.ScrollBarThickness = 2
    LogBox.ScrollBarImageColor3 = Color3.fromRGB(120, 90, 255)
    LogBox.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LogBox.Parent = LogContainer
    
    local LogText = Instance.new("TextLabel")
    LogText.Text = [[
• Reformulação Visual da Interface
• Correção da Lista de Jogadores (Tempo Real)
• Adicionado ESP Esqueleto
• Suporte Mobile Aprimorado
• TriggerBot 100% Funcional
• Novas Funções Troll Adicionadas
• Otimização de Performance
]]
    LogText.Font = Enum.Font.Gotham
    LogText.TextSize = 13
    LogText.TextColor3 = Color3.fromRGB(200, 200, 200)
    LogText.BackgroundTransparency = 1
    LogText.Size = UDim2.new(1, 0, 0, 0)
    LogText.AutomaticSize = Enum.AutomaticSize.Y
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.Parent = LogBox

    -- Buttons Logic
    local function CreateButton(text, icon, pos, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0.42, 0, 0, 50)
        Btn.Position = pos
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.Parent = MainFrame
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 8)
        BtnCorner.Parent = Btn
        
        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Color3.fromRGB(60, 60, 70)
        BtnStroke.Thickness = 1
        BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        BtnStroke.Parent = Btn
        
        local Title = Instance.new("TextLabel")
        Title.Text = text
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 16
        Title.TextColor3 = Color3.fromRGB(240, 240, 240)
        Title.BackgroundTransparency = 1
        Title.Size = UDim2.new(1, 0, 1, 0)
        Title.Parent = Btn
        
        Btn.MouseEnter:Connect(function()
            UI:Tween(Btn, {BackgroundColor3 = Color3.fromRGB(120, 90, 255)})
            UI:Tween(Title, {TextColor3 = Color3.fromRGB(255, 255, 255)})
            UI:Tween(BtnStroke, {Transparency = 1})
        end)
        
        Btn.MouseLeave:Connect(function()
            UI:Tween(Btn, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)})
            UI:Tween(Title, {TextColor3 = Color3.fromRGB(240, 240, 240)})
            UI:Tween(BtnStroke, {Transparency = 0})
        end)
        
        Btn.MouseButton1Click:Connect(callback)
        return Btn, Title
    end

    CreateButton("DISPOSITIVO MOBILE", "", UDim2.new(0.05, 0, 0.78, 0), function()
        IsMobile = true
        Config.Misc.MenuScale = 1.2
        UI:Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        task.wait(0.3)
        LoaderGui:Destroy()
        StartNomade()
    end)
    
    local PCBtn, PCTitle = CreateButton("COMPUTADOR (PC)", "", UDim2.new(0.53, 0, 0.78, 0), function() end)
    
    PCBtn.MouseButton1Click:Connect(function()
        PCTitle.Text = "PRESSIONE UMA TECLA"
        UI:Tween(PCBtn, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)})
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                MenuToggleKey = input.KeyCode
                connection:Disconnect()
                UI:Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
                task.wait(0.3)
                LoaderGui:Destroy()
                StartNomade()
            end
        end)
    end)
end

--// INICIAR
CreateLoader()
