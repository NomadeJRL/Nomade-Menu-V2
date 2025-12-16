--[[
    NOMADE UI LIBRARY V3 - REMASTERED
    Design: Dark Glass + Neon Red
    Fixes: Loader Proporcional, Toggle Animation, Glow Effects
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Library = {}

-- Configurações de Cores Profissionais
local Theme = {
    Main        = Color3.fromRGB(15, 15, 20), -- Fundo principal
    Sidebar     = Color3.fromRGB(10, 10, 12), -- Lateral mais escura
    Card        = Color3.fromRGB(22, 22, 27), -- Cartões
    Accent      = Color3.fromRGB(255, 40, 40), -- Vermelho Neon
    Text        = Color3.fromRGB(240, 240, 240),
    TextDim     = Color3.fromRGB(140, 140, 140),
    Stroke      = Color3.fromRGB(35, 35, 40),
    Glow        = "rbxassetid://5028857472" -- Textura de brilho
}

function Library:Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

function Library:Init(Config)
    local Title = Config.Title or "NOMADE"
    
    -- Limpeza
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "NomadeV3Remaster" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NomadeV3Remaster"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- ===========================
    --      LOADER NOVO
    -- ===========================
    local LoaderFrame = Instance.new("Frame")
    LoaderFrame.Size = UDim2.new(0, 0, 0, 0) -- Animação de entrada
    LoaderFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LoaderFrame.BackgroundColor3 = Theme.Main
    LoaderFrame.BorderSizePixel = 0
    LoaderFrame.Parent = ScreenGui
    
    local LCorner = Instance.new("UICorner") LCorner.CornerRadius = UDim.new(0, 8) LCorner.Parent = LoaderFrame
    local LStroke = Instance.new("UIStroke") LStroke.Color = Theme.Accent LStroke.Thickness = 1 LStroke.Transparency = 0.5 LStroke.Parent = LoaderFrame
    
    -- Glow (Sombra vermelha)
    local LGlow = Instance.new("ImageLabel")
    LGlow.Size = UDim2.new(1, 100, 1, 100)
    LGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    LGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    LGlow.BackgroundTransparency = 1
    LGlow.Image = Theme.Glow
    LGlow.ImageColor3 = Theme.Accent
    LGlow.ImageTransparency = 0.8
    LGlow.ZIndex = -1
    LGlow.Parent = LoaderFrame

    -- Animação de abrir o Loader
    Library:Tween(LoaderFrame, {Size = UDim2.new(0, 350, 0, 180)}, 0.5)
    wait(0.5)

    -- Logo do Loader
    local LLogo = Instance.new("TextLabel")
    LLogo.Text = "NOMADE <font color='rgb(255,40,40)'>V3</font>"
    LLogo.RichText = true
    LLogo.Font = Enum.Font.GothamBlack
    LLogo.TextSize = 32
    LLogo.TextColor3 = Theme.Text
    LLogo.Size = UDim2.new(1, 0, 0, 50)
    LLogo.Position = UDim2.new(0, 0, 0.2, 0)
    LLogo.BackgroundTransparency = 1
    LLogo.Parent = LoaderFrame

    local LStatus = Instance.new("TextLabel")
    LStatus.Text = "Authenticating..."
    LStatus.Font = Enum.Font.Gotham
    LStatus.TextSize = 12
    LStatus.TextColor3 = Theme.TextDim
    LStatus.Size = UDim2.new(1, 0, 0, 20)
    LStatus.Position = UDim2.new(0, 0, 0.5, 0)
    LStatus.BackgroundTransparency = 1
    LStatus.Parent = LoaderFrame

    -- Barra de Carregamento
    local BarBG = Instance.new("Frame")
    BarBG.Size = UDim2.new(0.7, 0, 0, 4)
    BarBG.Position = UDim2.new(0.5, 0, 0.75, 0)
    BarBG.AnchorPoint = Vector2.new(0.5, 0.5)
    BarBG.BackgroundColor3 = Theme.Stroke
    BarBG.BorderSizePixel = 0
    BarBG.Parent = LoaderFrame
    Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1,0)

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Theme.Accent
    BarFill.BorderSizePixel = 0
    BarFill.Parent = BarBG
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1,0)

    -- Simulação de Load
    Library:Tween(BarFill, {Size = UDim2.new(0.4, 0, 1, 0)}, 0.5)
    wait(0.6)
    LStatus.Text = "Loading Modules..."
    Library:Tween(BarFill, {Size = UDim2.new(0.8, 0, 1, 0)}, 0.5)
    wait(0.4)
    LStatus.Text = "Ready."
    Library:Tween(BarFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.3)
    wait(0.5)
    
    -- Fechar Loader
    Library:Tween(LoaderFrame, {Size = UDim2.new(0, 350, 0, 0), BackgroundTransparency = 1}, 0.3)
    Library:Tween(LLogo, {TextTransparency = 1}, 0.2)
    Library:Tween(LStatus, {TextTransparency = 1}, 0.2)
    Library:Tween(BarBG, {BackgroundTransparency = 1}, 0.2)
    wait(0.3)
    LoaderFrame:Destroy()

    -- ===========================
    --      MENU PRINCIPAL
    -- ===========================
    
    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 720, 0, 460)
    Main.Position = UDim2.new(0.5, -360, 0.5, -230)
    Main.BackgroundColor3 = Theme.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = false -- Para sombra aparecer
    Main.Parent = ScreenGui
    
    -- Gradiente sutil no fundo
    local MainGrad = Instance.new("UIGradient")
    MainGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180,180,180))
    }
    MainGrad.Rotation = 45
    MainGrad.Parent = Main

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    -- Sombra do Menu
    local MainShadow = Instance.new("ImageLabel")
    MainShadow.Size = UDim2.new(1, 140, 1, 140)
    MainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainShadow.BackgroundTransparency = 1
    MainShadow.Image = Theme.Glow
    MainShadow.ImageColor3 = Color3.new(0,0,0)
    MainShadow.ImageTransparency = 0.4
    MainShadow.ZIndex = -1
    MainShadow.Parent = Main

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    
    local SideCorner = Instance.new("UICorner") SideCorner.CornerRadius = UDim.new(0, 10) SideCorner.Parent = Sidebar
    local SideFix = Instance.new("Frame") SideFix.Size = UDim2.new(0,10,1,0) SideFix.Position = UDim2.new(1,-10,0,0) SideFix.BackgroundColor3 = Theme.Sidebar SideFix.BorderSizePixel=0 SideFix.Parent=Sidebar

    -- Logo Area
    local Logo = Instance.new("TextLabel")
    Logo.Text = Title
    Logo.Font = Enum.Font.GothamBlack
    Logo.TextSize = 26
    Logo.TextColor3 = Theme.Text
    Logo.Size = UDim2.new(1, 0, 0, 70)
    Logo.BackgroundTransparency = 1
    Logo.Parent = Sidebar
    
    -- Subtitulo versão
    local Ver = Instance.new("TextLabel")
    Ver.Text = "BUILD V3"
    Ver.Font = Enum.Font.Code
    Ver.TextSize = 10
    Ver.TextColor3 = Theme.Accent
    Ver.Size = UDim2.new(1,0,0,15)
    Ver.Position = UDim2.new(0,0,0.65,0)
    Ver.BackgroundTransparency = 1
    Ver.Parent = Logo

    -- Container Tabs
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -80)
    TabContainer.Position = UDim2.new(0, 0, 0, 80)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    local TabList = Instance.new("UIListLayout") TabList.Padding = UDim.new(0,5) TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center TabList.Parent = TabContainer

    -- Container Pages
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -200, 1, 0)
    PageContainer.Position = UDim2.new(0, 200, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.ClipsDescendants = true -- Corta o scroll
    PageContainer.Parent = Main
    local PageCorner = Instance.new("UICorner") PageCorner.CornerRadius = UDim.new(0,10) PageCorner.Parent = PageContainer

    -- Drag System
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

    -- Toggle Menu
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)

    local WindowFunctions = {}

    function WindowFunctions:Tab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.9, 0, 0, 42)
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabContainer
        
        local TCorner = Instance.new("UICorner") TCorner.CornerRadius = UDim.new(0,6) TCorner.Parent = TabBtn
        
        local Ico = Instance.new("TextLabel")
        Ico.Text = icon
        Ico.Size = UDim2.new(0, 40, 1, 0)
        Ico.BackgroundTransparency = 1
        Ico.TextSize = 20
        Ico.TextColor3 = Theme.TextDim
        Ico.Parent = TabBtn
        
        local Tit = Instance.new("TextLabel")
        Tit.Text = name
        Tit.Size = UDim2.new(1, -40, 1, 0)
        Tit.Position = UDim2.new(0, 40, 0, 0)
        Tit.BackgroundTransparency = 1
        Tit.TextXAlignment = Enum.TextXAlignment.Left
        Tit.Font = Enum.Font.GothamBold
        Tit.TextSize = 14
        Tit.TextColor3 = Theme.TextDim
        Tit.Parent = TabBtn
        
        -- Indicador Ativo
        local Ind = Instance.new("Frame")
        Ind.Size = UDim2.new(0, 3, 0.6, 0)
        Ind.Position = UDim2.new(0, 0, 0.2, 0)
        Ind.BackgroundColor3 = Theme.Accent
        Ind.BackgroundTransparency = 1
        Ind.Parent = TabBtn
        Instance.new("UICorner", Ind).CornerRadius = UDim.new(0,2)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.BorderSizePixel = 0
        Page.Parent = PageContainer
        
        local PList = Instance.new("UIListLayout") PList.Padding = UDim.new(0,10) PList.HorizontalAlignment=Enum.HorizontalAlignment.Center PList.Parent = Page
        local PPad = Instance.new("UIPadding") PPad.PaddingTop=UDim.new(0,20) PPad.PaddingLeft=UDim.new(0,10) PPad.PaddingRight=UDim.new(0,15) PPad.Parent = Page

        TabBtn.MouseButton1Click:Connect(function()
            -- Reset
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Library:Tween(v, {BackgroundColor3 = Theme.Sidebar})
                    Library:Tween(v.TextLabel, {TextColor3 = Theme.TextDim}) -- Icon
                    Library:Tween(v:FindFirstChild("TextLabel", true), {TextColor3 = Theme.TextDim}) -- Text
                    Library:Tween(v.Frame, {BackgroundTransparency = 1}) -- Indicador
                end
            end
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            
            -- Active
            Page.Visible = true
            Library:Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(20,20,24)})
            Library:Tween(Ico, {TextColor3 = Theme.Accent})
            Library:Tween(Tit, {TextColor3 = Theme.Text})
            Library:Tween(Ind, {BackgroundTransparency = 0})
        end)

        local Elements = {}

        function Elements:Section(text)
            local Sec = Instance.new("TextLabel")
            Sec.Text = text
            Sec.Size = UDim2.new(0.98, 0, 0, 30)
            Sec.BackgroundTransparency = 1
            Sec.TextColor3 = Theme.TextDim
            Sec.Font = Enum.Font.GothamBold
            Sec.TextSize = 12
            Sec.TextXAlignment = Enum.TextXAlignment.Left
            Sec.Parent = Page
        end

        function Elements:Toggle(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0.98, 0, 0, 44)
            Btn.BackgroundColor3 = Theme.Card
            Btn.Text = ""
            Btn.AutoButtonColor = false
            Btn.Parent = Page
            
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
            local Str = Instance.new("UIStroke") Str.Color = Theme.Stroke Str.Parent = Btn
            
            local Lab = Instance.new("TextLabel")
            Lab.Text = text
            Lab.Size = UDim2.new(0.7, 0, 1, 0)
            Lab.Position = UDim2.new(0, 15, 0, 0)
            Lab.BackgroundTransparency = 1
            Lab.TextColor3 = Theme.Text
            Lab.Font = Enum.Font.GothamSemibold
            Lab.TextSize = 14
            Lab.TextXAlignment = Enum.TextXAlignment.Left
            Lab.Parent = Btn
            
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 42, 0, 22)
            Switch.AnchorPoint = Vector2.new(1, 0.5)
            Switch.Position = UDim2.new(1, -15, 0.5, 0)
            Switch.BackgroundColor3 = Color3.fromRGB(40,40,45)
            Switch.Parent = Btn
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)
            
            local Ball = Instance.new("Frame")
            Ball.Size = UDim2.new(0, 18, 0, 18)
            Ball.AnchorPoint = Vector2.new(0, 0.5)
            Ball.Position = UDim2.new(0, 2, 0.5, 0)
            Ball.BackgroundColor3 = Color3.fromRGB(150,150,150)
            Ball.Parent = Switch
            Instance.new("UICorner", Ball).CornerRadius = UDim.new(1,0)
            
            local active = false
            Btn.MouseButton1Click:Connect(function()
                active = not active
                if active then
                    Library:Tween(Switch, {BackgroundColor3 = Theme.Accent})
                    Library:Tween(Ball, {Position = UDim2.new(0, 22, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1)})
                    Library:Tween(Str, {Color = Theme.Accent})
                else
                    Library:Tween(Switch, {BackgroundColor3 = Color3.fromRGB(40,40,45)})
                    Library:Tween(Ball, {Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Color3.fromRGB(150,150,150)})
                    Library:Tween(Str, {Color = Theme.Stroke})
                end
                callback(active)
            end)
        end

        function Elements:Slider(text, min, max, def, callback)
            local Sld = Instance.new("Frame")
            Sld.Size = UDim2.new(0.98, 0, 0, 60)
            Sld.BackgroundColor3 = Theme.Card
            Sld.Parent = Page
            Instance.new("UICorner", Sld).CornerRadius = UDim.new(0,6)
            Instance.new("UIStroke", Sld).Color = Theme.Stroke
            
            local Tit = Instance.new("TextLabel")
            Tit.Text = text
            Tit.Size = UDim2.new(1, -20, 0, 30)
            Tit.Position = UDim2.new(0, 15, 0, 0)
            Tit.BackgroundTransparency = 1
            Tit.TextColor3 = Theme.Text
            Tit.Font = Enum.Font.GothamSemibold
            Tit.TextSize = 14
            Tit.TextXAlignment = Enum.TextXAlignment.Left
            Tit.Parent = Sld
            
            local Val = Instance.new("TextLabel")
            Val.Text = tostring(def)
            Val.Size = UDim2.new(0, 50, 0, 30)
            Val.Position = UDim2.new(1, -15, 0, 0)
            Val.AnchorPoint = Vector2.new(1,0)
            Val.BackgroundTransparency = 1
            Val.TextColor3 = Theme.TextDim
            Val.Font = Enum.Font.Gotham
            Val.TextSize = 14
            Val.TextXAlignment = Enum.TextXAlignment.Right
            Val.Parent = Sld
            
            local BarBG = Instance.new("Frame")
            BarBG.Size = UDim2.new(1, -30, 0, 6)
            BarBG.Position = UDim2.new(0, 15, 0, 40)
            BarBG.BackgroundColor3 = Color3.fromRGB(40,40,45)
            BarBG.Parent = Sld
            Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1,0)
            
            local BarFill = Instance.new("Frame")
            BarFill.Size = UDim2.new(0,0,1,0)
            BarFill.BackgroundColor3 = Theme.Accent
            BarFill.Parent = BarBG
            Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1,0)
            
            local function Update(input)
                local pos = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                BarFill.Size = UDim2.new(pos, 0, 1, 0)
                local v = math.floor(min + ((max - min) * pos))
                Val.Text = tostring(v)
                callback(v)
            end
            
            BarBG.InputBegan:Connect(function(i) 
                if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    local dragging = true
                    Update(i)
                    local con; con = UserInputService.InputChanged:Connect(function(io) 
                        if io.UserInputType == Enum.UserInputType.MouseMovement then Update(io) end 
                    end)
                    UserInputService.InputEnded:Connect(function(ie) 
                        if ie.UserInputType == Enum.UserInputType.MouseButton1 then 
                            dragging = false 
                            con:Disconnect() 
                        end 
                    end)
                end 
            end)
            
            -- Set Initial
            local p = (def - min) / (max - min)
            BarFill.Size = UDim2.new(p, 0, 1, 0)
        end

        function Elements:Button(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0.98, 0, 0, 40)
            Btn.BackgroundColor3 = Theme.Card
            Btn.Text = text
            Btn.TextColor3 = Theme.Text
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 14
            Btn.AutoButtonColor = false
            Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
            local Str = Instance.new("UIStroke") Str.Color = Theme.Stroke Str.Parent = Btn
            
            Btn.MouseEnter:Connect(function() Library:Tween(Str, {Color = Theme.Accent}) end)
            Btn.MouseLeave:Connect(function() Library:Tween(Str, {Color = Theme.Stroke}) end)
            Btn.MouseButton1Click:Connect(function()
                Library:Tween(Btn, {BackgroundColor3 = Theme.Accent})
                wait(0.1)
                Library:Tween(Btn, {BackgroundColor3 = Theme.Card})
                callback()
            end)
        end

        return Elements
    end

    return WindowFunctions
end

return Library
