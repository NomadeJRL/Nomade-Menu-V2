--[[
    NOMADE UI LIBRARY V4 (REDUX)
    Design: Modern Panels
    Fixes: Layout automático, Auto-Open Tab, Cores visíveis.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Library = {}

function Library:Window(Config)
    -- Limpa UI antiga
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "NomadeV4" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NomadeV4"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Container (Janela)
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 650, 0, 400)
    Main.Position = UDim2.new(0.5, -325, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30) -- Cinza Carvão (Não preto puro)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 6) MainCorner.Parent = Main
    local MainStroke = Instance.new("UIStroke") MainStroke.Color = Color3.fromRGB(60, 60, 65) MainStroke.Thickness = 1 MainStroke.Parent = Main

    -- Barra Lateral (Sidebar)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    
    local SideCorner = Instance.new("UICorner") SideCorner.CornerRadius = UDim.new(0, 6) SideCorner.Parent = Sidebar
    local SideFix = Instance.new("Frame") SideFix.Size = UDim2.new(0,10,1,0) SideFix.Position = UDim2.new(1,-5,0,0) SideFix.BackgroundColor3 = Color3.fromRGB(20,20,23) SideFix.BorderSizePixel=0 SideFix.Parent=Sidebar

    -- Logo
    local Logo = Instance.new("TextLabel")
    Logo.Text = Config.Title or "NOMADE"
    Logo.Font = Enum.Font.GothamBlack
    Logo.TextSize = 24
    Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    Logo.Size = UDim2.new(1, 0, 0, 60)
    Logo.BackgroundTransparency = 1
    Logo.Parent = Sidebar

    local LogoAccent = Instance.new("Frame")
    LogoAccent.Size = UDim2.new(0, 40, 0, 2)
    LogoAccent.Position = UDim2.new(0.5, -20, 0, 50)
    LogoAccent.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Vermelho
    LogoAccent.BorderSizePixel = 0
    LogoAccent.Parent = Sidebar

    -- Container de Abas
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -70)
    TabContainer.Position = UDim2.new(0, 0, 0, 70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local TabList = Instance.new("UIListLayout") 
    TabList.Padding = UDim.new(0, 5) 
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center 
    TabList.Parent = TabContainer

    -- Área de Páginas (Onde ficam os botões)
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Size = UDim2.new(1, -190, 1, -20)
    PageContainer.Position = UDim2.new(0, 190, 0, 10)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Main

    -- Drag System (Arrastar)
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

    -- Toggle Key (Insert)
    UserInputService.InputBegan:Connect(function(i, gp)
        if not gp and i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end
    end)

    local Window = {}
    local FirstTab = true

    function Window:Tab(name)
        -- Botão da Aba
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.9, 0, 0, 38)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 14
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabContainer
        
        local TCorner = Instance.new("UICorner") TCorner.CornerRadius = UDim.new(0, 6) TCorner.Parent = TabBtn

        -- A Página (Scroll)
        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
        Page.BorderSizePixel = 0
        Page.Parent = PageContainer

        local PList = Instance.new("UIListLayout") 
        PList.Padding = UDim.new(0, 8) 
        PList.SortOrder = Enum.SortOrder.LayoutOrder
        PList.Parent = Page
        
        local PPad = Instance.new("UIPadding") 
        PPad.PaddingTop = UDim.new(0, 5) 
        PPad.PaddingRight = UDim.new(0, 10) 
        PPad.Parent = Page

        -- Função para Ativar Aba
        local function Activate()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20,20,23), TextColor3 = Color3.fromRGB(150,150,150)}):Play()
                end
            end
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.fromRGB(255,255,255)}):Play()
        end

        TabBtn.MouseButton1Click:Connect(Activate)

        -- Auto-abrir a primeira aba
        if FirstTab then
            FirstTab = false
            Activate()
        end

        local Elements = {}

        function Elements:Section(text)
            local Sec = Instance.new("TextLabel")
            Sec.Text = text
            Sec.Size = UDim2.new(1, 0, 0, 25)
            Sec.BackgroundTransparency = 1
            Sec.TextColor3 = Color3.fromRGB(255, 50, 50)
            Sec.Font = Enum.Font.GothamBlack
            Sec.TextSize = 12
            Sec.TextXAlignment = Enum.TextXAlignment.Left
            Sec.Parent = Page
        end

        function Elements:Toggle(text, default, callback)
            local TBtn = Instance.new("TextButton")
            TBtn.Size = UDim2.new(1, 0, 0, 40)
            TBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40) -- Cor visível do botão
            TBtn.Text = ""
            TBtn.AutoButtonColor = false
            TBtn.Parent = Page
            
            local TCorner = Instance.new("UICorner") TCorner.CornerRadius = UDim.new(0, 6) TCorner.Parent = TBtn
            local TStroke = Instance.new("UIStroke") TStroke.Color = Color3.fromRGB(50, 50, 55) TStroke.Parent = TBtn

            local Lab = Instance.new("TextLabel")
            Lab.Text = text
            Lab.Size = UDim2.new(0.7, 0, 1, 0)
            Lab.Position = UDim2.new(0, 15, 0, 0)
            Lab.BackgroundTransparency = 1
            Lab.TextColor3 = Color3.fromRGB(200, 200, 200)
            Lab.Font = Enum.Font.GothamSemibold
            Lab.TextSize = 14
            Lab.TextXAlignment = Enum.TextXAlignment.Left
            Lab.Parent = TBtn

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 40, 0, 20)
            Switch.AnchorPoint = Vector2.new(1, 0.5)
            Switch.Position = UDim2.new(1, -15, 0.5, 0)
            Switch.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
            Switch.Parent = TBtn
            local SCorner = Instance.new("UICorner") SCorner.CornerRadius = UDim.new(1,0) SCorner.Parent = Switch
            
            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 16, 0, 16)
            Dot.AnchorPoint = Vector2.new(0, 0.5)
            Dot.Position = UDim2.new(0, 2, 0.5, 0)
            Dot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Dot.Parent = Switch
            local DCorner = Instance.new("UICorner") DCorner.CornerRadius = UDim.new(1,0) DCorner.Parent = Dot

            local active = default
            local function Update()
                if active then
                    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
                    TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 22, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    TweenService:Create(TStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 50, 50)}):Play()
                else
                    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 23)}):Play()
                    TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
                    TweenService:Create(TStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 55)}):Play()
                end
                callback(active)
            end
            
            if default then Update() end

            TBtn.MouseButton1Click:Connect(function()
                active = not active
                Update()
            end)
        end

        function Elements:Button(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 14
            Btn.AutoButtonColor = false
            Btn.Parent = Page
            
            local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = Btn
            local Stroke = Instance.new("UIStroke") Stroke.Color = Color3.fromRGB(50, 50, 55) Stroke.Parent = Btn
            
            Btn.MouseEnter:Connect(function() TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255,50,50)}):Play() end)
            Btn.MouseLeave:Connect(function() TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50,50,55)}):Play() end)
            
            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255,50,50)}):Play()
                wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35,35,40)}):Play()
                callback()
            end)
        end

        return Elements
    end

    return Window
end

return Library
