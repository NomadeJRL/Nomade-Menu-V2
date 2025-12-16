--[[
    NOMADE UI LIBRARY V3 (PROFESSIONAL FRAMEWORK)
    Estilo: Modern Dark / Fluent
    Autor: Nomade Team
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

local Library = {}

-- Configurações Visuais
local Config = {
    MainColor = Color3.fromRGB(18, 18, 22),
    SidebarColor = Color3.fromRGB(14, 14, 16),
    CardColor = Color3.fromRGB(25, 25, 28),
    Accent = Color3.fromRGB(255, 55, 55), -- Vermelho Nomade
    TextMain = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(140, 140, 140),
    Stroke = Color3.fromRGB(45, 45, 50)
}

function Library:Validate(defaults, options)
    for i, v in pairs(defaults) do
        if options[i] == nil then
            options[i] = v
        end
    end
    return options
end

function Library:Tween(object, goal, callback)
    local tween = TweenService:Create(object, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play()
    if callback then
        tween.Completed:Connect(callback)
    end
    return tween
end

function Library:Init(options)
    options = Library:Validate({
        Title = "Nomade V3"
    }, options or {})

    -- Limpeza
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "NomadeV3" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NomadeV3"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Container
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 750, 0, 480)
    Main.Position = UDim2.new(0.5, -375, 0.5, -240)
    Main.BackgroundColor3 = Config.MainColor
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 10) MainCorner.Parent = Main
    local MainStroke = Instance.new("UIStroke") MainStroke.Color = Config.Stroke MainStroke.Thickness = 1 MainStroke.Parent = Main

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Config.SidebarColor
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    
    local SideCorner = Instance.new("UICorner") SideCorner.CornerRadius = UDim.new(0,10) SideCorner.Parent = Sidebar
    -- Fix para o canto direito da sidebar não ser arredondado
    local SideFix = Instance.new("Frame") SideFix.Size=UDim2.new(0,10,1,0) SideFix.Position=UDim2.new(1,-10,0,0) SideFix.BackgroundColor3=Config.SidebarColor SideFix.BorderSizePixel=0 SideFix.Parent=Sidebar

    -- Logo Area
    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Text = options.Title
    LogoLabel.Font = Enum.Font.GothamBlack
    LogoLabel.TextSize = 22
    LogoLabel.TextColor3 = Config.TextMain
    LogoLabel.Size = UDim2.new(1, 0, 0, 60)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Parent = Sidebar
    
    -- Divisor
    local Line = Instance.new("Frame") Line.Size = UDim2.new(0.8,0,0,1) Line.Position = UDim2.new(0.1,0,0,60) Line.BackgroundColor3 = Config.Stroke Line.BorderSizePixel=0 Line.Parent = Sidebar

    -- Container de Abas
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -70)
    TabContainer.Position = UDim2.new(0, 0, 0, 70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local TabList = Instance.new("UIListLayout") TabList.Padding = UDim.new(0,5) TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center TabList.Parent = TabContainer

    -- Área de Páginas (Conteúdo)
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "Pages"
    PageContainer.Size = UDim2.new(1, -200, 1, 0)
    PageContainer.Position = UDim2.new(0, 200, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Main

    -- Drag System
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Main.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

    -- Toggle Keybind
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)

    local Window = {}

    function Window:Tab(name, icon)
        -- Botão da Aba
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.9, 0, 0, 40)
        TabBtn.BackgroundColor3 = Config.SidebarColor
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner") TabCorner.CornerRadius = UDim.new(0,6) TabCorner.Parent = TabBtn
        
        local TabIcon = Instance.new("TextLabel")
        TabIcon.Text = icon or ""
        TabIcon.Size = UDim2.new(0, 40, 1, 0)
        TabIcon.BackgroundTransparency = 1
        TabIcon.TextSize = 20
        TabIcon.TextColor3 = Config.TextDim
        TabIcon.Parent = TabBtn
        
        local TabTitle = Instance.new("TextLabel")
        TabTitle.Text = name
        TabTitle.Size = UDim2.new(1, -40, 1, 0)
        TabTitle.Position = UDim2.new(0, 40, 0, 0)
        TabTitle.BackgroundTransparency = 1
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left
        TabTitle.Font = Enum.Font.GothamBold
        TabTitle.TextSize = 14
        TabTitle.TextColor3 = Config.TextDim
        TabTitle.Parent = TabBtn

        -- Página de Conteúdo
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Config.Accent
        Page.BorderSizePixel = 0
        Page.Parent = PageContainer
        
        local PageList = Instance.new("UIListLayout") PageList.Padding = UDim.new(0, 10) PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center PageList.Parent = Page
        local PagePad = Instance.new("UIPadding") PagePad.PaddingTop = UDim.new(0,20) PagePad.PaddingLeft=UDim.new(0,10) PagePad.PaddingRight=UDim.new(0,10) PagePad.Parent = Page

        -- Lógica de Seleção
        TabBtn.MouseButton1Click:Connect(function()
            -- Resetar outros
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Library:Tween(v, {BackgroundColor3 = Config.SidebarColor})
                    Library:Tween(v.TextLabel, {TextColor3 = Config.TextDim}) -- Icon
                    Library:Tween(v:FindFirstChild("TextLabel", true), {TextColor3 = Config.TextDim}) -- Title
                end
            end
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            
            -- Ativar este
            Page.Visible = true
            Library:Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(30,30,35)})
            Library:Tween(TabIcon, {TextColor3 = Config.Accent})
            Library:Tween(TabTitle, {TextColor3 = Config.TextMain})
        end)

        -- ELEMENTOS DA PÁGINA
        local Elements = {}

        function Elements:Section(text)
            local Sec = Instance.new("TextLabel")
            Sec.Text = text
            Sec.Size = UDim2.new(0.95, 0, 0, 30)
            Sec.BackgroundTransparency = 1
            Sec.TextColor3 = Config.TextDim
            Sec.Font = Enum.Font.GothamBold
            Sec.TextSize = 12
            Sec.TextXAlignment = Enum.TextXAlignment.Left
            Sec.Parent = Page
        end

        function Elements:Toggle(text, default, callback)
            local TglBtn = Instance.new("TextButton")
            TglBtn.Size = UDim2.new(0.98, 0, 0, 45)
            TglBtn.BackgroundColor3 = Config.CardColor
            TglBtn.Text = ""
            TglBtn.AutoButtonColor = false
            TglBtn.Parent = Page
            
            local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0,6) Corner.Parent = TglBtn
            local Stroke = Instance.new("UIStroke") Stroke.Color = Config.Stroke Stroke.Parent = TglBtn
            
            local Title = Instance.new("TextLabel")
            Title.Text = text
            Title.Size = UDim2.new(0.7, 0, 1, 0)
            Title.Position = UDim2.new(0, 15, 0, 0)
            Title.BackgroundTransparency = 1
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Font = Enum.Font.GothamSemibold
            Title.TextSize = 14
            Title.TextColor3 = Config.TextMain
            Title.Parent = TglBtn
            
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 44, 0, 24)
            Switch.AnchorPoint = Vector2.new(1, 0.5)
            Switch.Position = UDim2.new(1, -15, 0.5, 0)
            Switch.BackgroundColor3 = Color3.fromRGB(50,50,55)
            Switch.Parent = TglBtn
            local SwCorner = Instance.new("UICorner") SwCorner.CornerRadius = UDim.new(1,0) SwCorner.Parent = Switch
            
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 20, 0, 20)
            Knob.AnchorPoint = Vector2.new(0, 0.5)
            Knob.Position = UDim2.new(0, 2, 0.5, 0)
            Knob.BackgroundColor3 = Color3.fromRGB(200,200,200)
            Knob.Parent = Switch
            local KCorner = Instance.new("UICorner") KCorner.CornerRadius = UDim.new(1,0) KCorner.Parent = Knob

            local state = default or false
            
            local function Update()
                if state then
                    Library:Tween(Switch, {BackgroundColor3 = Config.Accent})
                    Library:Tween(Knob, {Position = UDim2.new(0, 22, 0.5, 0)})
                    Library:Tween(Knob, {BackgroundColor3 = Color3.fromRGB(255,255,255)})
                    Library:Tween(Stroke, {Color = Config.Accent})
                else
                    Library:Tween(Switch, {BackgroundColor3 = Color3.fromRGB(50,50,55)})
                    Library:Tween(Knob, {Position = UDim2.new(0, 2, 0.5, 0)})
                    Library:Tween(Knob, {BackgroundColor3 = Color3.fromRGB(200,200,200)})
                    Library:Tween(Stroke, {Color = Config.Stroke})
                end
                callback(state)
            end
            
            if default then Update() end

            TglBtn.MouseButton1Click:Connect(function()
                state = not state
                Update()
            end)
        end

        function Elements:Slider(text, min, max, default, callback)
            local SldFrame = Instance.new("Frame")
            SldFrame.Size = UDim2.new(0.98, 0, 0, 60)
            SldFrame.BackgroundColor3 = Config.CardColor
            SldFrame.Parent = Page
            
            local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0,6) Corner.Parent = SldFrame
            local Stroke = Instance.new("UIStroke") Stroke.Color = Config.Stroke Stroke.Parent = SldFrame
            
            local Title = Instance.new("TextLabel")
            Title.Text = text
            Title.Size = UDim2.new(1, -20, 0, 30)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Font = Enum.Font.GothamSemibold
            Title.TextSize = 14
            Title.TextColor3 = Config.TextMain
            Title.Parent = SldFrame
            
            local ValueLbl = Instance.new("TextLabel")
            ValueLbl.Text = tostring(default)
            ValueLbl.Size = UDim2.new(0, 50, 0, 30)
            ValueLbl.Position = UDim2.new(1, -60, 0, 0)
            ValueLbl.BackgroundTransparency = 1
            ValueLbl.TextXAlignment = Enum.TextXAlignment.Right
            ValueLbl.Font = Enum.Font.Gotham
            ValueLbl.TextSize = 14
            ValueLbl.TextColor3 = Config.TextDim
            ValueLbl.Parent = SldFrame
            
            local BarBG = Instance.new("Frame")
            BarBG.Size = UDim2.new(1, -30, 0, 6)
            BarBG.Position = UDim2.new(0, 15, 0, 40)
            BarBG.BackgroundColor3 = Color3.fromRGB(50,50,55)
            BarBG.Parent = SldFrame
            Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1,0)
            
            local BarFill = Instance.new("Frame")
            BarFill.Size = UDim2.new(0, 0, 1, 0)
            BarFill.BackgroundColor3 = Config.Accent
            BarFill.Parent = BarBG
            Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1,0)
            
            local value = default
            
            local function Update(input)
                local pos = UDim2.new(math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1), 0, 1, 0)
                BarFill.Size = pos
                local s = math.floor(min + ((max - min) * pos.X.Scale))
                value = s
                ValueLbl.Text = tostring(s)
                callback(s)
            end
            
            -- Set initial value
            local startPercent = (default - min) / (max - min)
            BarFill.Size = UDim2.new(startPercent, 0, 1, 0)
            
            local dragging = false
            BarBG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; Update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
        end

        function Elements:Button(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0.98, 0, 0, 40)
            Btn.BackgroundColor3 = Config.CardColor
            Btn.Text = text
            Btn.TextColor3 = Config.TextMain
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 14
            Btn.AutoButtonColor = false
            Btn.Parent = Page
            
            local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0,6) Corner.Parent = Btn
            local Stroke = Instance.new("UIStroke") Stroke.Color = Config.Stroke Stroke.Parent = Btn
            
            Btn.MouseEnter:Connect(function() Library:Tween(Stroke, {Color = Config.Accent}) end)
            Btn.MouseLeave:Connect(function() Library:Tween(Stroke, {Color = Config.Stroke}) end)
            
            Btn.MouseButton1Click:Connect(function()
                Library:Tween(Btn, {BackgroundColor3 = Config.Accent})
                wait(0.1)
                Library:Tween(Btn, {BackgroundColor3 = Config.CardColor})
                callback()
            end)
        end

        return Elements
    end

    return Window
end

return Library
