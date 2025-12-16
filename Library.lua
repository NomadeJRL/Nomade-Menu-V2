--[[
    ZENITH UI FRAMEWORK
    Version: 1.0 (Premium)
    Author: Zenith Team
    Theme: Onyx & Royal Purple
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

local Library = {}

-- Configurações de Design
local Styles = {
    Main = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(14, 14, 17),
    Section = Color3.fromRGB(24, 24, 28),
    Accent = Color3.fromRGB(140, 100, 255), -- Roxo Premium
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(120, 120, 130),
    Stroke = Color3.fromRGB(40, 40, 45),
    Hover = Color3.fromRGB(35, 35, 40)
}

function Library:Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), props):Play()
end

function Library:Init(Config)
    -- Limpeza de Instâncias Antigas
    for _, v in pairs(CoreGui:GetDescendants()) do
        if v.Name == "ZenithMain" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZenithMain"
    ScreenGui.Parent = CoreGui
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Janela Principal
    local Main = Instance.new("Frame")
    Main.Name = "Window"
    Main.Size = UDim2.new(0, 0, 0, 0) -- Começa fechado para animar
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Styles.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local MCorner = Instance.new("UICorner") MCorner.CornerRadius = UDim.new(0, 10) MCorner.Parent = Main
    local MStroke = Instance.new("UIStroke") MStroke.Color = Styles.Stroke MStroke.Thickness = 1 MStroke.Parent = Main

    -- Animação de Entrada
    Library:Tween(Main, {Size = UDim2.new(0, 750, 0, 480)}, 0.6)

    -- Barra Lateral
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Styles.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    
    local SCorner = Instance.new("UICorner") SCorner.CornerRadius = UDim.new(0, 10) SCorner.Parent = Sidebar
    local SFix = Instance.new("Frame") SFix.Size = UDim2.new(0,10,1,0) SFix.Position = UDim2.new(1,-10,0,0) SFix.BackgroundColor3 = Styles.Sidebar SFix.BorderSizePixel=0 SFix.Parent = Sidebar
    local SLine = Instance.new("Frame") SLine.Size = UDim2.new(0,1,1,0) SLine.Position = UDim2.new(1,0,0,0) SLine.BackgroundColor3 = Styles.Stroke SLine.BorderSizePixel=0 SLine.Parent = Sidebar

    -- Logo
    local Logo = Instance.new("TextLabel")
    Logo.Text = Config.Title or "ZENITH"
    Logo.Font = Enum.Font.GothamBlack
    Logo.TextSize = 24
    Logo.TextColor3 = Styles.Text
    Logo.Size = UDim2.new(1, 0, 0, 70)
    Logo.Position = UDim2.new(0, 0, 0, 10)
    Logo.BackgroundTransparency = 1
    Logo.Parent = Sidebar

    local LogoAccent = Instance.new("Frame")
    LogoAccent.Size = UDim2.new(0, 30, 0, 2)
    LogoAccent.Position = UDim2.new(0.5, -15, 0, 60)
    LogoAccent.BackgroundColor3 = Styles.Accent
    LogoAccent.BorderSizePixel = 0
    LogoAccent.Parent = Sidebar

    -- Container de Abas
    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Size = UDim2.new(1, 0, 1, -90)
    TabHolder.Position = UDim2.new(0, 0, 0, 90)
    TabHolder.BackgroundTransparency = 1
    TabHolder.BorderSizePixel = 0
    TabHolder.ScrollBarThickness = 0
    TabHolder.Parent = Sidebar
    
    local TabList = Instance.new("UIListLayout") 
    TabList.Padding = UDim.new(0, 8) 
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center 
    TabList.Parent = TabHolder

    -- Container de Páginas
    local PageHolder = Instance.new("Frame")
    PageHolder.Size = UDim2.new(1, -200, 1, 0)
    PageHolder.Position = UDim2.new(0, 200, 0, 0)
    PageHolder.BackgroundTransparency = 1
    PageHolder.Parent = Main

    -- Sistema de Drag
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Library:Tween(Main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

    -- Toggle Key (Insert)
    UserInputService.InputBegan:Connect(function(i, gp)
        if not gp and i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end
    end)

    -- Window Functions
    local Window = {}
    local FirstTab = true

    function Window:Tab(name, icon)
        -- Botão
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.85, 0, 0, 40)
        TabBtn.BackgroundColor3 = Styles.Sidebar
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabHolder
        
        local TCorner = Instance.new("UICorner") TCorner.CornerRadius = UDim.new(0, 8) TCorner.Parent = TabBtn
        local TStroke = Instance.new("UIStroke") TStroke.Transparency = 1 TStroke.Color = Styles.Stroke TStroke.Parent = TabBtn

        local TIco = Instance.new("ImageLabel")
        TIco.Size = UDim2.new(0, 20, 0, 20)
        TIco.Position = UDim2.new(0, 15, 0.5, -10)
        TIco.BackgroundTransparency = 1
        TIco.Image = icon or ""
        TIco.ImageColor3 = Styles.TextDim
        TIco.Parent = TabBtn

        local TText = Instance.new("TextLabel")
        TText.Text = name
        TText.Size = UDim2.new(1, -50, 1, 0)
        TText.Position = UDim2.new(0, 50, 0, 0)
        TText.BackgroundTransparency = 1
        TText.TextXAlignment = Enum.TextXAlignment.Left
        TText.Font = Enum.Font.GothamBold
        TText.TextSize = 13
        TText.TextColor3 = Styles.TextDim
        TText.Parent = TabBtn

        -- Página
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Styles.Accent
        Page.BorderSizePixel = 0
        Page.Parent = PageHolder
        
        local PList = Instance.new("UIListLayout") 
        PList.Padding = UDim.new(0, 10) 
        PList.SortOrder = Enum.SortOrder.LayoutOrder 
        PList.Parent = Page
        
        local PPad = Instance.new("UIPadding") 
        PPad.PaddingTop = UDim.new(0, 20) 
        PPad.PaddingLeft = UDim.new(0, 20) 
        PPad.PaddingRight = UDim.new(0, 20) 
        PPad.PaddingBottom = UDim.new(0, 20) 
        PPad.Parent = Page

        -- Ativação
        local function Activate()
            for _, v in pairs(TabHolder:GetChildren()) do
                if v:IsA("TextButton") then
                    Library:Tween(v, {BackgroundColor3 = Styles.Sidebar})
                    Library:Tween(v.ImageLabel, {ImageColor3 = Styles.TextDim})
                    Library:Tween(v.TextLabel, {TextColor3 = Styles.TextDim})
                    Library:Tween(v.UIStroke, {Transparency = 1})
                end
            end
            for _, v in pairs(PageHolder:GetChildren()) do v.Visible = false end
            
            Page.Visible = true
            Library:Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(20, 20, 24)})
            Library:Tween(TIco, {ImageColor3 = Styles.Accent})
            Library:Tween(TText, {TextColor3 = Styles.Text})
            Library:Tween(TStroke, {Transparency = 0, Color = Styles.Accent})
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        
        if FirstTab then FirstTab = false Activate() end

        local Elements = {}

        function Elements:Section(text)
            local Sec = Instance.new("Frame")
            Sec.Size = UDim2.new(1, 0, 0, 30)
            Sec.BackgroundTransparency = 1
            Sec.Parent = Page
            
            local Lab = Instance.new("TextLabel")
            Lab.Text = text
            Lab.Size = UDim2.new(1, 0, 1, 0)
            Lab.BackgroundTransparency = 1
            Lab.TextColor3 = Styles.Text
            Lab.Font = Enum.Font.GothamBold
            Lab.TextSize = 14
            Lab.TextXAlignment = Enum.TextXAlignment.Left
            Lab.Parent = Sec
        end

        function Elements:Toggle(text, default, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 42)
            Button.BackgroundColor3 = Styles.Section
            Button.Text = ""
            Button.AutoButtonColor = false
            Button.Parent = Page
            
            local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = Button
            local Stroke = Instance.new("UIStroke") Stroke.Color = Styles.Stroke Stroke.Parent = Button

            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Styles.TextDim
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Button

            local Toggler = Instance.new("Frame")
            Toggler.Size = UDim2.new(0, 40, 0, 20)
            Toggler.Position = UDim2.new(1, -50, 0.5, -10)
            Toggler.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            Toggler.Parent = Button
            Instance.new("UICorner", Toggler).CornerRadius = UDim.new(1,0)

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = UDim2.new(0, 2, 0.5, -8)
            Circle.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
            Circle.Parent = Toggler
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1,0)

            local active = default
            local function Update()
                if active then
                    Library:Tween(Toggler, {BackgroundColor3 = Styles.Accent})
                    Library:Tween(Circle, {Position = UDim2.new(0, 22, 0.5, -8), BackgroundColor3 = Color3.new(1,1,1)})
                    Library:Tween(Label, {TextColor3 = Styles.Text})
                    Library:Tween(Stroke, {Color = Styles.Accent})
                else
                    Library:Tween(Toggler, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)})
                    Library:Tween(Circle, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(150, 150, 160)})
                    Library:Tween(Label, {TextColor3 = Styles.TextDim})
                    Library:Tween(Stroke, {Color = Styles.Stroke})
                end
                callback(active)
            end
            
            if default then Update() end

            Button.MouseButton1Click:Connect(function()
                active = not active
                Update()
            end)
        end

        function Elements:Slider(text, min, max, default, callback)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 60)
            Frame.BackgroundColor3 = Styles.Section
            Frame.Parent = Page
            
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", Frame).Color = Styles.Stroke

            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Size = UDim2.new(1, -20, 0, 30)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Styles.TextDim
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local Value = Instance.new("TextLabel")
            Value.Text = tostring(default)
            Value.Size = UDim2.new(0, 50, 0, 30)
            Value.Position = UDim2.new(1, -15, 0, 0)
            Value.AnchorPoint = Vector2.new(1,0)
            Value.BackgroundTransparency = 1
            Value.TextColor3 = Styles.Text
            Value.Font = Enum.Font.Code
            Value.TextSize = 13
            Value.TextXAlignment = Enum.TextXAlignment.Right
            Value.Parent = Frame

            local BarBG = Instance.new("Frame")
            BarBG.Size = UDim2.new(1, -30, 0, 6)
            BarBG.Position = UDim2.new(0, 15, 0, 40)
            BarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            BarBG.Parent = Frame
            Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1,0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BackgroundColor3 = Styles.Accent
            Fill.Parent = BarBG
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

            local function Update(input)
                local s = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                Library:Tween(Fill, {Size = UDim2.new(s, 0, 1, 0)}, 0.1)
                local res = math.floor(min + ((max - min) * s))
                Value.Text = tostring(res)
                callback(res)
            end

            BarBG.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local dragging = true
                    Update(i)
                    local con; con = UserInputService.InputChanged:Connect(function(io) if io.UserInputType==Enum.UserInputType.MouseMovement then Update(io) end end)
                    UserInputService.InputEnded:Connect(function(ie) if ie.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; con:Disconnect() end end)
                end
            end)
            
            -- Init
            local p = (default - min) / (max - min)
            Fill.Size = UDim2.new(p,0,1,0)
        end

        function Elements:Button(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 40)
            Button.BackgroundColor3 = Styles.Section
            Button.Text = text
            Button.TextColor3 = Styles.Text
            Button.Font = Enum.Font.GothamBold
            Button.TextSize = 13
            Button.AutoButtonColor = false
            Button.Parent = Page
            
            local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = Button
            local Stroke = Instance.new("UIStroke") Stroke.Color = Styles.Stroke Stroke.Parent = Button

            Button.MouseEnter:Connect(function() Library:Tween(Stroke, {Color = Styles.Accent}) end)
            Button.MouseLeave:Connect(function() Library:Tween(Stroke, {Color = Styles.Stroke}) end)
            Button.MouseButton1Click:Connect(function()
                Library:Tween(Button, {BackgroundColor3 = Styles.Accent}, 0.1)
                wait(0.1)
                Library:Tween(Button, {BackgroundColor3 = Styles.Section}, 0.2)
                callback()
            end)
        end

        return Elements
    end

    return Window
end

return Library
