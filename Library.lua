--[[
    ZENITH LIBRARY V2 (REFORGED)
    Fixes: Slider Drag Bug, Better Animations, Icons
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

local Library = {}

local Styles = {
    Main     = Color3.fromRGB(15, 15, 20),
    Sidebar  = Color3.fromRGB(10, 10, 12),
    Section  = Color3.fromRGB(25, 25, 30),
    Accent   = Color3.fromRGB(140, 100, 255), -- Roxo Zenith
    Text     = Color3.fromRGB(245, 245, 255),
    TextDim  = Color3.fromRGB(140, 140, 150),
    Outline  = Color3.fromRGB(40, 40, 45)
}

function Library:Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end

function Library:Init(Config)
    for _, v in pairs(CoreGui:GetDescendants()) do
        if v.Name == "ZenithReforged" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZenithReforged"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Window
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 0, 0, 0) -- Anim
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Styles.Main
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local MCorner = Instance.new("UICorner") MCorner.CornerRadius = UDim.new(0, 10) MCorner.Parent = Main
    local MStroke = Instance.new("UIStroke") MStroke.Color = Styles.Outline MStroke.Thickness = 1 MStroke.Parent = Main

    Library:Tween(Main, {Size = UDim2.new(0, 750, 0, 480)}, 0.5)

    -- Sidebar (Drag Area)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Styles.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    
    local SCorner = Instance.new("UICorner") SCorner.CornerRadius = UDim.new(0, 10) SCorner.Parent = Sidebar
    local SFix = Instance.new("Frame") SFix.Size=UDim2.new(0,10,1,0) SFix.Position=UDim2.new(1,-10,0,0) SFix.BackgroundColor3=Styles.Sidebar SFix.BorderSizePixel=0 SFix.Parent=Sidebar

    -- Logo
    local Logo = Instance.new("TextLabel")
    Logo.Text = Config.Title
    Logo.Font = Enum.Font.GothamBlack
    Logo.TextSize = 26
    Logo.TextColor3 = Styles.Text
    Logo.Size = UDim2.new(1, 0, 0, 70)
    Logo.BackgroundTransparency = 1
    Logo.Parent = Sidebar

    local LogoSub = Instance.new("TextLabel")
    LogoSub.Text = "V2 // PREMIUM"
    LogoSub.Font = Enum.Font.Code
    LogoSub.TextSize = 10
    LogoSub.TextColor3 = Styles.Accent
    LogoSub.Size = UDim2.new(1, 0, 0, 15)
    LogoSub.Position = UDim2.new(0,0,0.65,0)
    LogoSub.BackgroundTransparency = 1
    LogoSub.Parent = Logo

    -- Tab Container
    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Size = UDim2.new(1, 0, 1, -80)
    TabHolder.Position = UDim2.new(0, 0, 0, 80)
    TabHolder.BackgroundTransparency = 1
    TabHolder.BorderSizePixel = 0
    TabHolder.ScrollBarThickness = 0
    TabHolder.Parent = Sidebar
    local TabList = Instance.new("UIListLayout") TabList.Padding = UDim.new(0,8) TabList.HorizontalAlignment=Enum.HorizontalAlignment.Center TabList.Parent=TabHolder

    -- Page Container
    local PageHolder = Instance.new("Frame")
    PageHolder.Size = UDim2.new(1, -200, 1, 0)
    PageHolder.Position = UDim2.new(0, 200, 0, 0)
    PageHolder.BackgroundTransparency = 1
    PageHolder.Parent = Main

    -- DRAG SYSTEM (CORRIGIDO: Só arrasta pela Sidebar)
    local dragging, dragStart, startPos
    Sidebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Library:Tween(Main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

    -- Toggle Key
    UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightControl then Main.Visible = not Main.Visible end end)

    local Window = {}
    local FirstTab = true

    function Window:Tab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.85, 0, 0, 42)
        TabBtn.BackgroundColor3 = Styles.Sidebar
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabHolder
        
        local TCorner = Instance.new("UICorner") TCorner.CornerRadius = UDim.new(0,8) TCorner.Parent = TabBtn
        
        local TIco = Instance.new("ImageLabel") TIco.Size=UDim2.new(0,24,0,24) TIco.Position=UDim2.new(0,12,0.5,-12) TIco.BackgroundTransparency=1 TIco.Image=icon TIco.ImageColor3=Styles.TextDim TIco.Parent=TabBtn
        local TTxt = Instance.new("TextLabel") TTxt.Text=name TTxt.Size=UDim2.new(1,-50,1,0) TTxt.Position=UDim2.new(0,50,0,0) TTxt.BackgroundTransparency=1 TTxt.TextXAlignment=Enum.TextXAlignment.Left TTxt.Font=Enum.Font.GothamBold TTxt.TextSize=14 TTxt.TextColor3=Styles.TextDim TTxt.Parent=TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1,0,1,0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Styles.Accent
        Page.BorderSizePixel = 0
        Page.Parent = PageHolder
        
        local PList = Instance.new("UIListLayout") PList.Padding=UDim.new(0,10) PList.HorizontalAlignment=Enum.HorizontalAlignment.Center PList.Parent=Page
        local PPad = Instance.new("UIPadding") PPad.PaddingTop=UDim.new(0,20) PPad.PaddingLeft=UDim.new(0,15) PPad.PaddingRight=UDim.new(0,15) PPad.Parent=Page

        local function Activate()
            for _,v in pairs(TabHolder:GetChildren()) do
                if v:IsA("TextButton") then
                    Library:Tween(v, {BackgroundColor3 = Styles.Sidebar})
                    Library:Tween(v.ImageLabel, {ImageColor3 = Styles.TextDim})
                    Library:Tween(v.TextLabel, {TextColor3 = Styles.TextDim})
                end
            end
            for _,v in pairs(PageHolder:GetChildren()) do v.Visible=false end
            
            Page.Visible = true
            Library:Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(22, 22, 26)})
            Library:Tween(TIco, {ImageColor3 = Styles.Accent})
            Library:Tween(TTxt, {TextColor3 = Styles.Text})
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        if FirstTab then FirstTab=false Activate() end

        local Elements = {}

        function Elements:Section(text)
            local S = Instance.new("TextLabel")
            S.Text = text:upper()
            S.Size = UDim2.new(1,0,0,30)
            S.BackgroundTransparency = 1
            S.TextColor3 = Styles.Accent
            S.Font = Enum.Font.GothamBlack
            S.TextSize = 11
            S.TextXAlignment = Enum.TextXAlignment.Left
            S.Parent = Page
        end

        function Elements:Toggle(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,0,0,44)
            Btn.BackgroundColor3 = Styles.Section
            Btn.Text = ""
            Btn.AutoButtonColor = false
            Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
            local Str = Instance.new("UIStroke") Str.Color = Styles.Outline Str.Parent = Btn

            local Lab = Instance.new("TextLabel")
            Lab.Text = text
            Lab.Size = UDim2.new(0.8,0,1,0)
            Lab.Position = UDim2.new(0,15,0,0)
            Lab.BackgroundTransparency = 1
            Lab.TextColor3 = Styles.Text
            Lab.Font = Enum.Font.GothamSemibold
            Lab.TextSize = 13
            Lab.TextXAlignment = Enum.TextXAlignment.Left
            Lab.Parent = Btn

            local Sw = Instance.new("Frame")
            Sw.Size = UDim2.new(0,40,0,20)
            Sw.Position = UDim2.new(1,-50,0.5,-10)
            Sw.BackgroundColor3 = Color3.fromRGB(40,40,45)
            Sw.Parent = Btn
            Instance.new("UICorner", Sw).CornerRadius = UDim.new(1,0)

            local Ball = Instance.new("Frame")
            Ball.Size = UDim2.new(0,16,0,16)
            Ball.Position = UDim2.new(0,2,0.5,-8)
            Ball.BackgroundColor3 = Color3.fromRGB(150,150,150)
            Ball.Parent = Sw
            Instance.new("UICorner", Ball).CornerRadius = UDim.new(1,0)

            local active = false
            Btn.MouseButton1Click:Connect(function()
                active = not active
                if active then
                    Library:Tween(Sw, {BackgroundColor3 = Styles.Accent})
                    Library:Tween(Ball, {Position = UDim2.new(0,22,0.5,-8), BackgroundColor3 = Color3.new(1,1,1)})
                    Library:Tween(Str, {Color = Styles.Accent})
                else
                    Library:Tween(Sw, {BackgroundColor3 = Color3.fromRGB(40,40,45)})
                    Library:Tween(Ball, {Position = UDim2.new(0,2,0.5,-8), BackgroundColor3 = Color3.fromRGB(150,150,150)})
                    Library:Tween(Str, {Color = Styles.Outline})
                end
                callback(active)
            end)
        end

        function Elements:Slider(text, min, max, def, callback)
            local F = Instance.new("Frame")
            F.Size = UDim2.new(1,0,0,55)
            F.BackgroundColor3 = Styles.Section
            F.Parent = Page
            Instance.new("UICorner", F).CornerRadius = UDim.new(0,6)
            Instance.new("UIStroke", F).Color = Styles.Outline

            local Lab = Instance.new("TextLabel")
            Lab.Text = text
            Lab.Size = UDim2.new(1,-20,0,25)
            Lab.Position = UDim2.new(0,15,0,5)
            Lab.BackgroundTransparency = 1
            Lab.TextColor3 = Styles.Text
            Lab.Font = Enum.Font.GothamSemibold
            Lab.TextSize = 13
            Lab.TextXAlignment = Enum.TextXAlignment.Left
            Lab.Parent = F

            local Val = Instance.new("TextLabel")
            Val.Text = tostring(def)
            Val.Size = UDim2.new(0,50,0,25)
            Val.Position = UDim2.new(1,-15,0,5)
            Val.AnchorPoint = Vector2.new(1,0)
            Val.BackgroundTransparency = 1
            Val.TextColor3 = Styles.TextDim
            Val.Font = Enum.Font.Code
            Val.TextSize = 13
            Val.TextXAlignment = Enum.TextXAlignment.Right
            Val.Parent = F

            local BarBG = Instance.new("Frame")
            BarBG.Size = UDim2.new(1,-30,0,6)
            BarBG.Position = UDim2.new(0,15,0,38)
            BarBG.BackgroundColor3 = Color3.fromRGB(40,40,45)
            BarBG.Parent = F
            Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1,0)

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(0,0,1,0)
            Bar.BackgroundColor3 = Styles.Accent
            Bar.Parent = BarBG
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)

            local function Update(input)
                local pos = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                Library:Tween(Bar, {Size = UDim2.new(pos,0,1,0)}, 0.1)
                local res = math.floor(min + ((max-min)*pos))
                Val.Text = tostring(res)
                callback(res)
            end

            -- SLIDER LOGIC FIXADA (Não interfere no drag da janela)
            BarBG.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local dragging = true
                    Update(i)
                    local c; c = UserInputService.InputChanged:Connect(function(io) if io.UserInputType==Enum.UserInputType.MouseMovement then Update(io) end end)
                    UserInputService.InputEnded:Connect(function(ie) if ie.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; c:Disconnect() end end)
                end
            end)
            
            -- Init
            local p = (def-min)/(max-min)
            Bar.Size = UDim2.new(p,0,1,0)
        end

        return Elements
    end
    
    return Window
end

return Library
