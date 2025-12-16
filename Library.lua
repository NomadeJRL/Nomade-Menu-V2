--[[
    ZENITH LIBRARY V4 - STABLE
    Author: Nomade Team
    Fixes: Drag System, Visual Glitches
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {}

local Styles = {
    Main     = Color3.fromRGB(18, 18, 22),
    Sidebar  = Color3.fromRGB(13, 13, 15),
    Section  = Color3.fromRGB(24, 24, 28),
    Accent   = Color3.fromRGB(140, 100, 255), -- Roxo Zenith
    Text     = Color3.fromRGB(245, 245, 255),
    TextDim  = Color3.fromRGB(140, 140, 150),
    Outline  = Color3.fromRGB(45, 45, 50)
}

function Library:Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

function Library:Init(Config)
    -- Limpa UI antiga
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "ZenithV4" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZenithV4"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 700, 0, 450)
    Main.Position = UDim2.new(0.5, -350, 0.5, -225)
    Main.BackgroundColor3 = Styles.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 8) MainCorner.Parent = Main
    local MainStroke = Instance.new("UIStroke") MainStroke.Color = Styles.Outline MainStroke.Thickness = 1 MainStroke.Parent = Main

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Styles.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    
    local SideCorner = Instance.new("UICorner") SideCorner.CornerRadius = UDim.new(0, 8) SideCorner.Parent = Sidebar
    local SideFix = Instance.new("Frame") SideFix.Size = UDim2.new(0,10,1,0) SideFix.Position = UDim2.new(1,-5,0,0) SideFix.BackgroundColor3 = Styles.Sidebar SideFix.BorderSizePixel=0 SideFix.Parent=Sidebar

    -- Logo
    local Logo = Instance.new("TextLabel")
    Logo.Text = Config.Title
    Logo.Font = Enum.Font.GothamBlack
    Logo.TextSize = 24
    Logo.TextColor3 = Styles.Text
    Logo.Size = UDim2.new(1, 0, 0, 60)
    Logo.BackgroundTransparency = 1
    Logo.Parent = Sidebar

    local LogoSub = Instance.new("TextLabel")
    LogoSub.Text = "ESP FRAMEWORK"
    LogoSub.Font = Enum.Font.Code
    LogoSub.TextSize = 10
    LogoSub.TextColor3 = Styles.Accent
    LogoSub.Size = UDim2.new(1, 0, 0, 15)
    LogoSub.Position = UDim2.new(0,0,0.65,0)
    LogoSub.BackgroundTransparency = 1
    LogoSub.Parent = Logo

    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -70)
    TabContainer.Position = UDim2.new(0, 0, 0, 70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    local TabList = Instance.new("UIListLayout") TabList.Padding = UDim.new(0,5) TabList.HorizontalAlignment=Enum.HorizontalAlignment.Center TabList.Parent=TabContainer

    -- Page Container
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -200, 1, 0)
    PageContainer.Position = UDim2.new(0, 200, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Main

    -- Drag System (Sidebar Only)
    local dragging, dragStart, startPos
    Sidebar.InputBegan:Connect(function(input)
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

    UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightControl then Main.Visible = not Main.Visible end end)

    local Window = {}
    local FirstTab = true

    function Window:Tab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.85, 0, 0, 40)
        TabBtn.BackgroundColor3 = Styles.Sidebar
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabContainer
        
        local TCorner = Instance.new("UICorner") TCorner.CornerRadius = UDim.new(0, 6) TCorner.Parent = TabBtn
        
        local TIcon = Instance.new("ImageLabel")
        TIcon.Size = UDim2.new(0, 20, 0, 20)
        TIcon.Position = UDim2.new(0, 12, 0.5, -10)
        TIcon.BackgroundTransparency = 1
        TIcon.Image = icon or ""
        TIcon.ImageColor3 = Styles.TextDim
        TIcon.Parent = TabBtn

        local TText = Instance.new("TextLabel")
        TText.Text = name
        TText.Size = UDim2.new(1, -45, 1, 0)
        TText.Position = UDim2.new(0, 45, 0, 0)
        TText.BackgroundTransparency = 1
        TText.TextXAlignment = Enum.TextXAlignment.Left
        TText.Font = Enum.Font.GothamBold
        TText.TextSize = 13
        TText.TextColor3 = Styles.TextDim
        TText.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Styles.Accent
        Page.BorderSizePixel = 0
        Page.Parent = PageContainer
        
        local PList = Instance.new("UIListLayout") PList.Padding=UDim.new(0,8) PList.HorizontalAlignment=Enum.HorizontalAlignment.Center PList.Parent=Page
        local PPad = Instance.new("UIPadding") PPad.PaddingTop=UDim.new(0,15) PPad.PaddingLeft=UDim.new(0,10) PPad.PaddingRight=UDim.new(0,10) PPad.Parent=Page

        local function Activate()
            for _,v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Library:Tween(v, {BackgroundColor3 = Styles.Sidebar})
                    Library:Tween(v.ImageLabel, {ImageColor3 = Styles.TextDim})
                    Library:Tween(v.TextLabel, {TextColor3 = Styles.TextDim})
                end
            end
            for _,v in pairs(PageContainer:GetChildren()) do v.Visible=false end
            Page.Visible = true
            Library:Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 30)})
            Library:Tween(TIcon, {ImageColor3 = Styles.Accent})
            Library:Tween(TText, {TextColor3 = Styles.Text})
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        if FirstTab then FirstTab=false Activate() end

        local Elements = {}

        function Elements:Section(text)
            local S = Instance.new("TextLabel")
            S.Text = text
            S.Size = UDim2.new(0.95, 0, 0, 25)
            S.BackgroundTransparency = 1
            S.TextColor3 = Styles.Accent
            S.Font = Enum.Font.GothamBlack
            S.TextSize = 11
            S.TextXAlignment = Enum.TextXAlignment.Left
            S.Parent = Page
        end

        function Elements:Toggle(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0.98, 0, 0, 40)
            Btn.BackgroundColor3 = Styles.Section
            Btn.Text = ""
            Btn.AutoButtonColor = false
            Btn.Parent = Page
            
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            local Str = Instance.new("UIStroke") Str.Color = Styles.Outline Str.Parent = Btn

            local Lab = Instance.new("TextLabel")
            Lab.Text = text
            Lab.Size = UDim2.new(0.7, 0, 1, 0)
            Lab.Position = UDim2.new(0, 15, 0, 0)
            Lab.BackgroundTransparency = 1
            Lab.TextColor3 = Styles.Text
            Lab.Font = Enum.Font.GothamSemibold
            Lab.TextSize = 13
            Lab.TextXAlignment = Enum.TextXAlignment.Left
            Lab.Parent = Btn

            local Sw = Instance.new("Frame")
            Sw.Size = UDim2.new(0, 36, 0, 18)
            Sw.Position = UDim2.new(1, -45, 0.5, -9)
            Sw.BackgroundColor3 = Color3.fromRGB(40,40,45)
            Sw.Parent = Btn
            Instance.new("UICorner", Sw).CornerRadius = UDim.new(1,0)

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 14, 0, 14)
            Dot.Position = UDim2.new(0, 2, 0.5, -7)
            Dot.BackgroundColor3 = Color3.fromRGB(150,150,160)
            Dot.Parent = Sw
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)

            local active = false
            Btn.MouseButton1Click:Connect(function()
                active = not active
                if active then
                    Library:Tween(Sw, {BackgroundColor3 = Styles.Accent})
                    Library:Tween(Dot, {Position = UDim2.new(0, 20, 0.5, -7), BackgroundColor3 = Color3.new(1,1,1)})
                    Library:Tween(Str, {Color = Styles.Accent})
                else
                    Library:Tween(Sw, {BackgroundColor3 = Color3.fromRGB(40,40,45)})
                    Library:Tween(Dot, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150,150,160)})
                    Library:Tween(Str, {Color = Styles.Outline})
                end
                callback(active)
            end)
        end

        function Elements:Button(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0.98, 0, 0, 35)
            Btn.BackgroundColor3 = Styles.Section
            Btn.Text = text
            Btn.TextColor3 = Styles.Text
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 13
            Btn.AutoButtonColor = false
            Btn.Parent = Page
            
            local C = Instance.new("UICorner") C.CornerRadius = UDim.new(0, 6) C.Parent = Btn
            local S = Instance.new("UIStroke") S.Color = Styles.Outline S.Parent = Btn
            
            Btn.MouseButton1Click:Connect(function()
                Library:Tween(Btn, {BackgroundColor3 = Styles.Accent}, 0.1)
                wait(0.1)
                Library:Tween(Btn, {BackgroundColor3 = Styles.Section}, 0.2)
                callback()
            end)
        end

        return Elements
    end
    return Window
end

return Library
