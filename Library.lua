--[[
    HYDRA UI LIBRARY - PREMIUM EDITION
    Theme: Toxic Green / Deep Dark
    Type: Fully Modular & Animatable
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local HydraLib = {}

local Theme = {
    Main = Color3.fromRGB(15, 15, 15),
    Sidebar = Color3.fromRGB(10, 10, 10),
    Card = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(0, 255, 120), -- Verde Hydra
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(120, 120, 120),
    Outline = Color3.fromRGB(40, 40, 40)
}

function HydraLib:Window(Config)
    -- Limpa UI antiga
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "HydraNetwork" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HydraNetwork"
    ScreenGui.Parent = CoreGui
    ScreenGui.IgnoreGuiInset = true

    -- Janela Principal
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 700, 0, 450)
    Main.Position = UDim2.new(0.5, -350, 0.5, -225)
    Main.BackgroundColor3 = Theme.Main
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 6) MainCorner.Parent = Main
    local MainStroke = Instance.new("UIStroke") MainStroke.Color = Theme.Accent MainStroke.Thickness = 1 MainStroke.Parent = Main

    -- Barra Superior (Header)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Theme.Sidebar
    Header.BorderSizePixel = 0
    Header.Parent = Main
    local HCorner = Instance.new("UICorner") HCorner.CornerRadius = UDim.new(0,6) HCorner.Parent = Header
    
    -- Fix para o canto inferior do header ser reto
    local HFix = Instance.new("Frame") HFix.Size = UDim2.new(1,0,0,10) HFix.Position = UDim2.new(0,0,1,-5) HFix.BackgroundColor3 = Theme.Sidebar HFix.BorderSizePixel=0 HFix.Parent = Header

    local Logo = Instance.new("TextLabel")
    Logo.Text = "HYDRA <font color='rgb(0,255,120)'>NETWORK</font>"
    Logo.RichText = true
    Logo.Font = Enum.Font.GothamBlack
    Logo.TextSize = 18
    Logo.TextColor3 = Theme.Text
    Logo.Size = UDim2.new(0, 200, 1, 0)
    Logo.Position = UDim2.new(0, 15, 0, 0)
    Logo.BackgroundTransparency = 1
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    Logo.Parent = Header

    local Ver = Instance.new("TextLabel")
    Ver.Text = "v1.5.0 | Stable"
    Ver.Font = Enum.Font.Code
    Ver.TextSize = 12
    Ver.TextColor3 = Theme.TextDark
    Ver.Size = UDim2.new(0, 100, 1, 0)
    Ver.Position = UDim2.new(1, -110, 0, 0)
    Ver.BackgroundTransparency = 1
    Ver.TextXAlignment = Enum.TextXAlignment.Right
    Ver.Parent = Header

    -- Barra Lateral
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 180, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    local SCorner = Instance.new("UICorner") SCorner.CornerRadius = UDim.new(0,6) SCorner.Parent = Sidebar
    local SFix = Instance.new("Frame") SFix.Size=UDim2.new(0,10,0,10) SFix.Position=UDim2.new(1,-5,0,0) SFix.BackgroundColor3=Theme.Sidebar SFix.BorderSizePixel=0 SFix.Parent=Sidebar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -10, 1, -20)
    TabContainer.Position = UDim2.new(0, 5, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local TabList = Instance.new("UIListLayout") TabList.Padding = UDim.new(0,5) TabList.Parent = TabContainer

    -- Conteúdo
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -190, 1, -50)
    PageContainer.Position = UDim2.new(0, 190, 0, 45)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Main

    -- Drag System
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true dragStart=i.Position startPos=Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d=i.Position-dragStart Main.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)

    -- Toggle Key
    UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode == Enum.KeyCode.RightControl then Main.Visible = not Main.Visible end end)

    local Window = {}

    function Window:Tab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabContainer
        
        local TCorner = Instance.new("UICorner") TCorner.CornerRadius = UDim.new(0,6) TCorner.Parent = TabBtn
        
        local TIcon = Instance.new("TextLabel")
        TIcon.Text = icon
        TIcon.Size = UDim2.new(0, 30, 1, 0)
        TIcon.Position = UDim2.new(0, 10, 0, 0)
        TIcon.BackgroundTransparency = 1
        TIcon.TextColor3 = Theme.TextDark
        TIcon.TextSize = 18
        TIcon.Parent = TabBtn
        
        local TText = Instance.new("TextLabel")
        TText.Text = name
        TText.Size = UDim2.new(1, -50, 1, 0)
        TText.Position = UDim2.new(0, 45, 0, 0)
        TText.BackgroundTransparency = 1
        TText.TextColor3 = Theme.TextDark
        TText.TextSize = 14
        TText.Font = Enum.Font.GothamBold
        TText.TextXAlignment = Enum.TextXAlignment.Left
        TText.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.BorderSizePixel = 0
        Page.Parent = PageContainer
        
        local PGrid = Instance.new("UIGridLayout") 
        PGrid.CellSize = UDim2.new(0.48, 0, 0, 0) -- Altura auto ajustada
        PGrid.CellPadding = UDim2.new(0.02, 0, 0, 10)
        PGrid.Parent = Page
        
        local PPad = Instance.new("UIPadding") PPad.PaddingRight = UDim.new(0,10) PPad.Parent = Page

        TabBtn.MouseButton1Click:Connect(function()
            for _,v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Sidebar}):Play()
                    TweenService:Create(v.TextLabel, {TextColor3 = Theme.TextDark}):Play() -- Icon
                    TweenService:Create(v.TextLabel.NextSelection, {TextColor3 = Theme.TextDark}):Play() -- Text (Hack via parent order)
                end
            end
            -- Reset Pages
            for _,v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            
            -- Active
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30,30,30)}):Play()
            TweenService:Create(TIcon, TweenInfo.new(0.2), {TextColor3 = Theme.Accent}):Play()
            TweenService:Create(TText, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
        end)
        
        -- Hack to find label easily
        TIcon.NextSelection = TText

        local Elements = {}

        function Elements:Toggle(text, callback)
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(0,0,0,50) -- Altura fixa
            Card.BackgroundColor3 = Theme.Card
            Card.Parent = Page
            local CCorner = Instance.new("UICorner") CCorner.CornerRadius = UDim.new(0,6) CCorner.Parent = Card
            local CStroke = Instance.new("UIStroke") CStroke.Color = Theme.Outline CStroke.Parent = Card

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,0,1,0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = Card

            local Lab = Instance.new("TextLabel")
            Lab.Text = text
            Lab.Size = UDim2.new(0.7, 0, 1, 0)
            Lab.Position = UDim2.new(0, 15, 0, 0)
            Lab.BackgroundTransparency = 1
            Lab.TextColor3 = Theme.Text
            Lab.Font = Enum.Font.GothamSemibold
            Lab.TextSize = 13
            Lab.TextXAlignment = Enum.TextXAlignment.Left
            Lab.Parent = Card

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 36, 0, 18)
            Switch.Position = UDim2.new(1, -50, 0.5, -9)
            Switch.BackgroundColor3 = Color3.fromRGB(40,40,40)
            Switch.Parent = Card
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 14, 0, 14)
            Dot.Position = UDim2.new(0, 2, 0.5, -7)
            Dot.BackgroundColor3 = Color3.fromRGB(150,150,150)
            Dot.Parent = Switch
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)

            local active = false
            Btn.MouseButton1Click:Connect(function()
                active = not active
                if active then
                    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
                    TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 20, 0.5, -7), BackgroundColor3 = Color3.new(1,1,1)}):Play()
                    TweenService:Create(CStroke, TweenInfo.new(0.2), {Color = Theme.Accent, Transparency = 0.5}):Play()
                else
                    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
                    TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150,150,150)}):Play()
                    TweenService:Create(CStroke, TweenInfo.new(0.2), {Color = Theme.Outline, Transparency = 0}):Play()
                end
                callback(active)
            end)
        end

        function Elements:Button(text, callback)
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(0,0,0,45)
            Card.BackgroundColor3 = Theme.Card
            Card.Parent = Page
            local CCorner = Instance.new("UICorner") CCorner.CornerRadius = UDim.new(0,6) CCorner.Parent = Card
            local CStroke = Instance.new("UIStroke") CStroke.Color = Theme.Outline CStroke.Parent = Card

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,0,1,0)
            Btn.BackgroundTransparency = 1
            Btn.Text = text
            Btn.TextColor3 = Theme.Text
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 13
            Btn.Parent = Card
            
            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(CStroke, TweenInfo.new(0.1), {Color = Theme.Accen
