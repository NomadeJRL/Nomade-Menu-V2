--[[
    ZENITH LIBRARY V5 - STABILITY UPDATE
    Fixes: Auto-Show Page, Rendering Priority, ZIndex
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

local Theme = {
    Main = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(14, 14, 17),
    Accent = Color3.fromRGB(140, 100, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Stroke = Color3.fromRGB(45, 45, 50)
}

function Library:Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

function Library:Init(Config)
    -- Limpa versões antigas
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "ZenithV5" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZenithV5"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true

    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 700, 0, 450)
    Main.Position = UDim2.new(0.5, -350, 0.5, -225)
    Main.BackgroundColor3 = Theme.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 8) Corner.Parent = Main
    local Stroke = Instance.new("UIStroke") Stroke.Color = Theme.Stroke Stroke.Thickness = 1 Stroke.Parent = Main

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    local SCorner = Instance.new("UICorner") SCorner.CornerRadius = UDim.new(0,8) SCorner.Parent = Sidebar
    local SFix = Instance.new("Frame") SFix.Size = UDim2.new(0,10,1,0) SFix.Position = UDim2.new(1,-5,0,0) SFix.BackgroundColor3=Theme.Sidebar SFix.BorderSizePixel=0 SFix.Parent=Sidebar

    -- Logo
    local Logo = Instance.new("TextLabel")
    Logo.Text = Config.Title
    Logo.Font = Enum.Font.GothamBlack
    Logo.TextSize = 24
    Logo.TextColor3 = Theme.Text
    Logo.Size = UDim2.new(1, 0, 0, 60)
    Logo.BackgroundTransparency = 1
    Logo.Parent = Sidebar

    -- Container Abas
    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Size = UDim2.new(1, 0, 1, -70)
    TabHolder.Position = UDim2.new(0, 0, 0, 70)
    TabHolder.BackgroundTransparency = 1
    TabHolder.BorderSizePixel = 0
    TabHolder.ScrollBarThickness = 0
    TabHolder.Parent = Sidebar
    local TabList = Instance.new("UIListLayout") TabList.Padding = UDim.new(0, 5) TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center TabList.Parent = TabHolder

    -- Container Paginas
    local PageHolder = Instance.new("Frame")
    PageHolder.Size = UDim2.new(1, -200, 1, 0)
    PageHolder.Position = UDim2.new(0, 200, 0, 0)
    PageHolder.BackgroundTransparency = 1
    PageHolder.Parent = Main

    -- Drag System
    local dragging, dragStart, startPos
    Sidebar.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = true 
            dragStart = i.Position 
            startPos = Main.Position 
        end 
    end)
    UserInputService.InputChanged:Connect(function(i) 
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then 
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end 
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    
    -- Toggle Key
    UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode == Enum.KeyCode.RightControl then Main.Visible = not Main.Visible end end)

    local Window = {}
    local FirstTab = true

    function Window:Tab(name, icon)
        -- Botão Aba
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.9, 0, 0, 40)
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabHolder
        local TCorner = Instance.new("UICorner") TCorner.CornerRadius = UDim.new(0,6) TCorner.Parent = TabBtn

        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.Position = UDim2.new(0, 10, 0.5, -10)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = icon or ""
        IconImg.ImageColor3 = Color3.fromRGB(150,150,150)
        IconImg.Parent = TabBtn

        local Title = Instance.new("TextLabel")
        Title.Text = name
        Title.Size = UDim2.new(1, -40, 1, 0)
        Title.Position = UDim2.new(0, 40, 0, 0)
        Title.BackgroundTransparency = 1
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextColor3 = Color3.fromRGB(150,150,150)
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 13
        Title.Parent = TabBtn

        -- Pagina
        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.V
