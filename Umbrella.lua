--[[
    ========================================================================
    UMBRELLA CORPORATION (MURDER MYSTERY 2 HVH SUPREMACY EDITION v10.0)
    ========================================================================
--]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICornerMain = Instance.new("UICorner")
local UIStrokeMain = Instance.new("UIStroke")

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Безопасное получение CoreGui / PlayerGui
local ParentGui = game:GetService("CoreGui")
if not pcall(function() local x = ParentGui.Name end) then
    ParentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- Удаляем предыдущие копии
for _, old in ipairs(ParentGui:GetChildren()) do
    if old.Name == "Umbrella_MM2_Edition" then
        old:Destroy()
    end
end

ScreenGui.Name = "Umbrella_MM2_Edition"
ScreenGui.Parent = ParentGui
ScreenGui.ResetOnSpawn = false

------------------------------------------------------------------------
-- 8-СЕГМЕНТНЫЙ ЗОНТ UMBRELLA
------------------------------------------------------------------------
local function CreateExactUmbrellaLogo(parent, size)
    local Container = Instance.new("Frame")
    Container.Name = "UmbrellaLogoContainer"
    Container.Parent = parent
    Container.BackgroundTransparency = 1
    Container.Size = UDim2.new(0, size, 0, size)
    
    local UmbrellaCircle = Instance.new("Frame")
    UmbrellaCircle.Parent = Container
    UmbrellaCircle.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
    UmbrellaCircle.Size = UDim2.new(1, 0, 1, 0)
    UmbrellaCircle.ClipsDescendants = true
    Instance.new("UICorner", UmbrellaCircle).CornerRadius = UDim.new(1, 0)
    
    for i = 0, 3 do
        local WedgeFrame = Instance.new("Frame")
        WedgeFrame.Parent = UmbrellaCircle
        WedgeFrame.BackgroundTransparency = 1
        WedgeFrame.Size = UDim2.new(1, 0, 1, 0)
        WedgeFrame.Rotation = i * 90
        
        local WedgePiece = Instance.new("Frame")
        WedgePiece.Parent = WedgeFrame
        WedgePiece.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        WedgePiece.BorderSizePixel = 0
        WedgePiece.Position = UDim2.new(0.5, 0, 0, 0)
        WedgePiece.Size = UDim2.new(0.5, 0, 0.5, 0)
        
        local Gradient = Instance.new("UIGradient")
        Gradient.Parent = WedgePiece
        Gradient.Rotation = 45
        Gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.499, 0),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(1, 1)
        })
    end
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = UmbrellaCircle
    Stroke.Color = Color3.fromRGB(15, 15, 18)
    Stroke.Thickness = 1.5

    return Container
end

------------------------------------------------------------------------
-- 1. ЭКРАН ЗАГРУЗКИ
------------------------------------------------------------------------
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Parent = ScreenGui
LoadingFrame.BackgroundColor3 = Color3.fromRGB(12, 13, 17)
LoadingFrame.Position = UDim2.new(0.5, -90, 0.5, -65)
LoadingFrame.Size = UDim2.new(0, 180, 0, 130)
LoadingFrame.ClipsDescendants = true

local LoadingCorner = Instance.new("UICorner", LoadingFrame)
LoadingCorner.CornerRadius = UDim.new(0, 12)

local LoadingStroke = Instance.new("UIStroke", LoadingFrame)
LoadingStroke.Color = Color3.fromRGB(220, 35, 45)
LoadingStroke.Thickness = 1.5

local LoadingLogoHolder = Instance.new("Frame")
LoadingLogoHolder.Parent = LoadingFrame
LoadingLogoHolder.BackgroundTransparency = 1
LoadingLogoHolder.Position = UDim2.new(0.5, -28, 0, 20)
LoadingLogoHolder.Size = UDim2.new(0, 56, 0, 56)

local LoadingLogo = CreateExactUmbrellaLogo(LoadingLogoHolder, 56)

local ProgressBarBg = Instance.new("Frame")
ProgressBarBg.Parent = LoadingFrame
ProgressBarBg.BackgroundColor3 = Color3.fromRGB(25, 26, 32)
ProgressBarBg.Position = UDim2.new(0, 20, 0, 95)
ProgressBarBg.Size = UDim2.new(1, -40, 0, 6)
Instance.new("UICorner", ProgressBarBg).CornerRadius = UDim.new(1, 0)

local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Parent = ProgressBarBg
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1, 0)

------------------------------------------------------------------------
-- 2. ГЛАВНОЕ ОКНО ЧИТА
------------------------------------------------------------------------
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 19)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
MainFrame.Size = UDim2.new(0, 720, 0, 480)
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.ClipsDescendants = false
MainFrame.Visible = false

UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

UIStrokeMain.Parent = MainFrame
UIStrokeMain.Color = Color3.fromRGB(220, 35, 45)
UIStrokeMain.Thickness = 1.5
UIStrokeMain.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- ШАПКА МЕНЮ
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(18, 19, 25)
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BorderSizePixel = 0

local HeaderLine = Instance.new("Frame")
HeaderLine.Parent = Header
HeaderLine.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
HeaderLine.BorderSizePixel = 0
HeaderLine.Position = UDim2.new(0, 0, 1, -2)
HeaderLine.Size = UDim2.new(1, 0, 0, 2)

local HeaderLogoHolder = Instance.new("Frame")
HeaderLogoHolder.Name = "HeaderLogoHolder"
HeaderLogoHolder.Parent = Header
HeaderLogoHolder.BackgroundTransparency = 1
HeaderLogoHolder.Position = UDim2.new(0, 12, 0, 10)
HeaderLogoHolder.Size = UDim2.new(0, 28, 0, 28)

local HeaderLogo = CreateExactUmbrellaLogo(HeaderLogoHolder, 28)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Header
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 48, 0, 8)
TitleLabel.Size = UDim2.new(0, 220, 0, 32)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = 'UMBRELLA <font color="#dc232d">CORPORATION</font>'
TitleLabel.RichText = true
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 17
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local Badge = Instance.new("TextLabel")
Badge.Parent = Header
Badge.BackgroundColor3 = Color3.fromRGB(40, 15, 20)
Badge.Position = UDim2.new(0, 275, 0, 14)
Badge.Size = UDim2.new(0, 95, 0, 20)
Badge.Font = Enum.Font.SourceSansBold
Badge.Text = "SUPREMACY v10.0"
Badge.TextColor3 = Color3.fromRGB(255, 70, 80)
Badge.TextSize = 10
Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 4)

local StatusDot = Instance.new("Frame")
StatusDot.Parent = Header
StatusDot.BackgroundColor3 = Color3.fromRGB(40, 220, 100)
StatusDot.Position = UDim2.new(1, -95, 0, 20)
StatusDot.Size = UDim2.new(0, 8, 0, 8)
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local StatusText = Instance.new("TextLabel")
StatusText.Parent = Header
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(1, -82, 0, 14)
StatusText.Size = UDim2.new(0, 50, 0, 20)
StatusText.Font = Enum.Font.SourceSans
StatusText.Text = "ACTIVE"
StatusText.TextColor3 = Color3.fromRGB(150, 150, 160)
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = Header
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Position = UDim2.new(1, -30, 0, 8)
MinimizeBtn.Size = UDim2.new(0, 25, 0, 30)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 35, 45)
MinimizeBtn.TextSize = 22

------------------------------------------------------------------------
-- ВИЗУАЛЬНЫЙ ИНДИКАТОР AWALL
------------------------------------------------------------------------
local AwallIndicator = Instance.new("Frame")
AwallIndicator.Name = "AwallIndicator"
AwallIndicator.Parent = ScreenGui
AwallIndicator.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
AwallIndicator.Position = UDim2.new(0.5, 0, 0.5, 30)
AwallIndicator.Size = UDim2.new(0, 40, 0, 40)
AwallIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
AwallIndicator.Visible = false

local AwallCorner = Instance.new("UICorner", AwallIndicator)
AwallCorner.CornerRadius = UDim.new(0, 6)

local AwallStroke = Instance.new("UIStroke", AwallIndicator)
AwallStroke.Color = Color3.fromRGB(255, 255, 255)
AwallStroke.Thickness = 2

local AwallText = Instance.new("TextLabel")
AwallText.Parent = AwallIndicator
AwallText.BackgroundTransparency = 1
AwallText.Position = UDim2.new(0, 0, 1, 4)
AwallText.Size = UDim2.new(1, 0, 0, 18)
AwallText.Font = Enum.Font.SourceSansBold
AwallText.Text = "WALL"
AwallText.TextColor3 = Color3.fromRGB(255, 70, 70)
AwallText.TextSize = 12

------------------------------------------------------------------------
-- ТАБЫ СЛЕВА
------------------------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
Sidebar.Position = UDim2.new(0, 0, 0, 48)
Sidebar.Size = UDim2.new(0, 140, 1, -48)
Sidebar.BorderSizePixel = 0

local SidebarLine = Instance.new("Frame")
SidebarLine.Parent = Sidebar
SidebarLine.BackgroundColor3 = Color3.fromRGB(25, 26, 32)
SidebarLine.BorderSizePixel = 0
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.Size = UDim2.new(0, 1, 1, 0)

local TabContainer = Instance.new("Frame")
TabContainer.Parent = Sidebar
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 8, 0, 12)
TabContainer.Size = UDim2.new(1, -16, 1, -24)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabContainer
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)

------------------------------------------------------------------------
-- ОСНОВНАЯ ОБЛАСТЬ КОНТЕНТА
------------------------------------------------------------------------
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 140, 0, 48)
ContentArea.Size = UDim2.new(1, -140, 1, -48)

local Tabs = {}
local TabButtons = {}

local function CreateTabPage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Parent = ContentArea
    Page.BackgroundTransparency = 1
    Page.Position = UDim2.new(0, 12, 0, 12)
    Page.Size = UDim2.new(1, -24, 1, -24)
    Page.Visible = false
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(220, 35, 45)
    Page.CanvasSize = UDim2.new(0, 0, 0, 660)
    
    local Grid = Instance.new("UIGridLayout")
    Grid.Parent = Page
    Grid.CellSize = UDim2.new(0, 260, 0, 320)
    Grid.CellPadding = UDim2.new(0, 12, 0, 12)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    
    Tabs[name] = Page
    return Page
end

CreateTabPage("Main")
CreateTabPage("Visuals")
CreateTabPage("Combat")
CreateTabPage("HvH")
CreateTabPage("Settings")

local function SwitchTab(targetTab)
    for name, page in pairs(Tabs) do
        page.Visible = (name == targetTab)
    end
    for name, btn in pairs(TabButtons) do
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if name == targetTab then
            btn.BackgroundColor3 = Color3.fromRGB(35, 15, 18)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            if stroke then stroke.Color = Color3.fromRGB(220, 35, 45) end
        else
            btn.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
            btn.TextColor3 = Color3.fromRGB(140, 145, 155)
            if stroke then stroke.Color = Color3.fromRGB(30, 32, 40) end
        end
    end
end

local function AddTabButton(name, iconText, layoutOrder)
    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "TabBtn"
    Btn.Parent = TabContainer
    Btn.LayoutOrder = layoutOrder
    Btn.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.Text = "  " .. iconText .. "   " .. name:upper()
    Btn.TextColor3 = Color3.fromRGB(140, 145, 155)
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = Btn
    Stroke.Color = Color3.fromRGB(30, 32, 40)
    Stroke.Thickness = 1
    
    Btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
    
    TabButtons[name] = Btn
end

AddTabButton("Main", "⚡", 1)
AddTabButton("Visuals", "👁", 2)
AddTabButton("Combat", "⚔", 3)
AddTabButton("HvH", "☠", 4)
AddTabButton("Settings", "⚙", 5)

------------------------------------------------------------------------
-- КОМПОНЕНТЫ ИНТЕРФЕЙСА
------------------------------------------------------------------------
local function CreateSection(parentPage, title)
    local Section = Instance.new("Frame")
    Section.Parent = parentPage
    Section.BackgroundColor3 = Color3.fromRGB(18, 19, 25)
    Section.Size = UDim2.new(0, 260, 0, 320)
    
    Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = Section
    Stroke.Color = Color3.fromRGB(30, 32, 40)
    Stroke.Thickness = 1
    
    local SecTitle = Instance.new("TextLabel")
    SecTitle.Parent = Section
    SecTitle.BackgroundTransparency = 1
    SecTitle.Position = UDim2.new(0, 10, 0, 6)
    SecTitle.Size = UDim2.new(1, -20, 0, 18)
    SecTitle.Font = Enum.Font.SourceSansBold
    SecTitle.Text = title:upper()
    SecTitle.TextColor3 = Color3.fromRGB(220, 35, 45)
    SecTitle.TextSize = 12
    SecTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local SecLine = Instance.new("Frame")
    SecLine.Parent = Section
    SecLine.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    SecLine.BorderSizePixel = 0
    SecLine.Position = UDim2.new(0, 10, 0, 26)
    SecLine.Size = UDim2.new(1, -20, 0, 1)
    
    local SecContainer = Instance.new("Frame")
    SecContainer.Parent = Section
    SecContainer.BackgroundTransparency = 1
    SecContainer.Position = UDim2.new(0, 10, 0, 30)
    SecContainer.Size = UDim2.new(1, -20, 1, -35)
    
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = SecContainer
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)
    
    return SecContainer
end

local function CreateToggle(parentSec, text, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = parentSec
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Size = UDim2.new(1, 0, 0, 22)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Font = Enum.Font.SourceSans
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 205, 215)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Parent = ToggleFrame
    SwitchBg.Text = ""
    SwitchBg.Position = UDim2.new(1, -36, 0, 2)
    SwitchBg.Size = UDim2.new(0, 34, 0, 18)
    SwitchBg.BackgroundColor3 = defaultState and Color3.fromRGB(220, 35, 45) or Color3.fromRGB(30, 32, 40)
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
    
    local SwitchDot = Instance.new("Frame")
    SwitchDot.Parent = SwitchBg
    SwitchDot.Position = defaultState and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    SwitchDot.Size = UDim2.new(0, 12, 0, 12)
    SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", SwitchDot).CornerRadius = UDim.new(1, 0)
    
    local state = defaultState
    SwitchBg.MouseButton1Click:Connect(function()
        state = not state
        if state then
            SwitchBg.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
            SwitchDot.Position = UDim2.new(1, -16, 0.5, -6)
        else
            SwitchBg.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
            SwitchDot.Position = UDim2.new(0, 2, 0.5, -6)
        end
        callback(state)
    end)
end

local function CreateSlider(parentSec, text, defaultVal, minVal, maxVal, isDecimal, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Parent = parentSec
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Size = UDim2.new(1, 0, 0, 30)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = SliderFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, 0, 0, 14)
    Label.Font = Enum.Font.SourceSans
    Label.Text = text .. ": " .. tostring(defaultVal)
    Label.TextColor3 = Color3.fromRGB(200, 205, 215)
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local BarBg = Instance.new("Frame")
    BarBg.Parent = SliderFrame
    BarBg.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    BarBg.Position = UDim2.new(0, 0, 0, 16)
    BarBg.Size = UDim2.new(1, 0, 0, 6)
    Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0, 3)
    
    local Fill = Instance.new("Frame")
    Fill.Parent = BarBg
    Fill.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
    local startPercent = (defaultVal - minVal) / (maxVal - minVal)
    Fill.Size = UDim2.new(startPercent, 0, 1, 0)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)
    
    local Handle = Instance.new("TextButton")
    Handle.Parent = BarBg
    Handle.Text = ""
    Handle.Position = UDim2.new(startPercent, -5, 0.5, -5)
    Handle.Size = UDim2.new(0, 10, 0, 10)
    Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Handle).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function Update(inputX)
        local rel = math.clamp((inputX - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Handle.Position = UDim2.new(rel, -5, 0.5, -5)
        
        local val = minVal + (rel * (maxVal - minVal))
        if isDecimal then
            val = math.round(val * 100) / 100
        else
            val = math.round(val)
        end
        Label.Text = text .. ": " .. tostring(val)
        callback(val)
    end
    
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input.Position.X)
        end
    end)
end

local function CreateDropdown(parentSec, text, options, defaultOpt, callback)
    local DropFrame = Instance.new("Frame")
    DropFrame.Parent = parentSec
    DropFrame.BackgroundTransparency = 1
    DropFrame.Size = UDim2.new(1, 0, 0, 42)
    DropFrame.ZIndex = 5

    local Label = Instance.new("TextLabel")
    Label.Parent = DropFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, 0, 0, 14)
    Label.Font = Enum.Font.SourceSans
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 205, 215)
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local MainBtn = Instance.new("TextButton")
    MainBtn.Parent = DropFrame
    MainBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    MainBtn.Position = UDim2.new(0, 0, 0, 16)
    MainBtn.Size = UDim2.new(1, 0, 0, 22)
    MainBtn.Font = Enum.Font.SourceSansBold
    MainBtn.Text = "  " .. defaultOpt .. "  ▼"
    MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainBtn.TextSize = 12
    MainBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 4)

    local ListFrame = Instance.new("Frame")
    ListFrame.Parent = DropFrame
    ListFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
    ListFrame.Position = UDim2.new(0, 0, 0, 40)
    ListFrame.Size = UDim2.new(1, 0, 0, #options * 22 + 4)
    ListFrame.Visible = false
    ListFrame.ZIndex = 10
    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 4)
    local ListStroke = Instance.new("UIStroke", ListFrame)
    ListStroke.Color = Color3.fromRGB(220, 35, 45)
    ListStroke.Thickness = 1

    local ListLayout = Instance.new("UIListLayout", ListFrame)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 2)

    local isExpanded = false
    MainBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        ListFrame.Visible = isExpanded
        DropFrame.ZIndex = isExpanded and 100 or 5
    end)

    for i, optName in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Parent = ListFrame
        OptBtn.BackgroundTransparency = 1
        OptBtn.Size = UDim2.new(1, 0, 0, 20)
        OptBtn.Font = Enum.Font.SourceSans
        OptBtn.Text = "  " .. optName
        OptBtn.TextColor3 = Color3.fromRGB(200, 205, 215)
        OptBtn.TextSize = 12
        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
        OptBtn.ZIndex = 11

        OptBtn.MouseButton1Click:Connect(function()
            MainBtn.Text = "  " .. optName .. "  ▼"
            isExpanded = false
            ListFrame.Visible = false
            DropFrame.ZIndex = 5
            callback(optName)
        end)
    end
end

------------------------------------------------------------------------
-- НАПОЛНЕНИЕ ВКЛАДОК И НАСТРОЙКА HVH ФУНКЦИЙ
------------------------------------------------------------------------
_G.ChamsActive = false
_G.ChamsStyle = "Highlight" -- "Box" или "Highlight" (Заливка + Обводка)
_G.ChamsFillTransparency = 0.5
_G.ChamsOutlineTransparency = 0
_G.SelfChamsActive = false
_G.SelfChamsColor = Color3.fromRGB(255, 20, 147)
_G.WeaponChamsActive = false
_G.WeaponChamsColor = Color3.fromRGB(255, 215, 0)
_G.DroppedGunEspActive = false
_G.DroppedGunEspColor = Color3.fromRGB(0, 255, 255)
_G.MurdererRepelActive = false

-- ADVANCED VISUALS, ESP & LIMB VISIBILITY CHECK SETTINGS
_G.EspBoxType = "None" -- "None", "2D Box", "2D Corner Box", "3D Box", "Filled 2D Box"
_G.EspNameActive = false
_G.EspRoleActive = false
_G.EspDistanceActive = false
_G.EspHealthActive = false
_G.EspSkeletonActive = false
_G.EspFontName = "SourceSansBold"
_G.EspTextSize = 12

_G.VisCheckActive = true
_G.PerLimbVisCheckActive = true
_G.VisColorMurderer = Color3.fromRGB(255, 35, 45)
_G.VisColorSheriff  = Color3.fromRGB(30, 140, 255)
_G.VisColorInnocent = Color3.fromRGB(30, 255, 100)
_G.OccludedColor    = Color3.fromRGB(120, 120, 120)

_G.CustomModelsActive = false
_G.SelectedCustomModel = "donkey"

_G.CameraAimActive = false
_G.RealSilentAimActive = false
_G.AutoAimMurderer = false
_G.PredictionActive = false
_G.PredictionAmount = 0.165
_G.AwallCheckActive = false
_G.ShowAwallSquare = false

_G.NoclipActive = false
_G.AntiFlingActive = false
_G.AutoPickupActive = false
_G.PickupMode = "Teleport" -- "Teleport" или "Distance"
_G.KillAuraActive = false
_G.SpeedActive = false
_G.SpinbotActive = false
_G.BhopActive = false
_G.BhopJumpPower = 50

_G.JitterActive = false
_G.JitterRange = 45
_G.NetworkFakeLagActive = false
_G.FakeLagLimit = 10
_G.KillTrashTalkActive = false
_G.FastGunActive = false
_G.InfiniteJumpActive = false
_G.HitboxExpanderActive = false
_G.HitboxSize = 8

_G.KnifeReachActive = false
_G.KnifeReachDist = 25
_G.AutoShootSheriff = false
_G.AntiMurdererOrbit = false
_G.OrbitDistance = 12
_G.BackstabAimbot = false

_G.SpeedValue = 40
_G.SpinSpeed = 30
_G.KillAuraRange = 15
_G.KillAuraDelay = 0.1

-- Вспомогательная функция создания палитры цвета (Color Picker)
local function CreateColorPicker(parentSec, text, defaultColor, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = parentSec
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 48)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, -40, 0, 16)
    Label.Font = Enum.Font.SourceSans
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 205, 215)
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Preview = Instance.new("Frame")
    Preview.Parent = Frame
    Preview.Position = UDim2.new(1, -34, 0, 0)
    Preview.Size = UDim2.new(0, 34, 0, 16)
    Preview.BackgroundColor3 = defaultColor
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)
    local PreviewStroke = Instance.new("UIStroke", Preview)
    PreviewStroke.Color = Color3.fromRGB(50, 52, 60)
    PreviewStroke.Thickness = 1
    
    local PalettesFrame = Instance.new("Frame")
    PalettesFrame.Parent = Frame
    PalettesFrame.BackgroundTransparency = 1
    PalettesFrame.Position = UDim2.new(0, 0, 0, 20)
    PalettesFrame.Size = UDim2.new(1, 0, 0, 24)
    
    local PaletteLayout = Instance.new("UIListLayout", PalettesFrame)
    PaletteLayout.FillDirection = Enum.FillDirection.Horizontal
    PaletteLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PaletteLayout.Padding = UDim.new(0, 5)
    
    local PresetColors = {
        Color3.fromRGB(255, 35, 45),   -- Red
        Color3.fromRGB(255, 140, 0),  -- Orange
        Color3.fromRGB(255, 215, 0),  -- Yellow
        Color3.fromRGB(30, 255, 100),  -- Green
        Color3.fromRGB(0, 255, 255),   -- Cyan
        Color3.fromRGB(30, 140, 255),  -- Blue
        Color3.fromRGB(160, 32, 240),  -- Purple
        Color3.fromRGB(255, 20, 147),  -- Pink
        Color3.fromRGB(255, 255, 255)  -- White
    }
    
    for i, col in ipairs(PresetColors) do
        local Btn = Instance.new("TextButton")
        Btn.Parent = PalettesFrame
        Btn.Text = ""
        Btn.BackgroundColor3 = col
        Btn.Size = UDim2.new(0, 20, 0, 20)
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
        
        Btn.MouseButton1Click:Connect(function()
            Preview.BackgroundColor3 = col
            callback(col)
        end)
    end
end

-- Custom Models (English Keys + Roblox Asset IDs)
local CustomModelAssetIDs = {
    ["donkey"]    = "rbxassetid://15258571412",
    ["cute girl"] = "rbxassetid://120285863159417",
    ["pig"]       = "rbxassetid://12928490816",
    ["angel"]     = "rbxassetid://12318430407",
    ["demon"]     = "rbxassetid://116615563871570"
}

-- Load external Lua table from GitHub if available
task.spawn(function()
    pcall(function()
        local downloadedLua = game:HttpGet("https://raw.githubusercontent.com/Rostik22803/Umbrella-mm2/refs/heads/main/models.lua")
        if downloadedLua and downloadedLua ~= "" then
            local loadedModels = loadstring(downloadedLua)()
            if typeof(loadedModels) == "table" then
                for k, v in pairs(loadedModels) do
                    local strVal = tostring(v)
                    if not strVal:find("rbxassetid://") then
                        strVal = "rbxassetid://" .. strVal
                    end
                    CustomModelAssetIDs[tostring(k):lower()] = strVal
                end
            end
        end
    end)
end)

local function RemoveCustomModel()
    local char = LocalPlayer.Character
    if not char then return end
    for _, old in ipairs(char:GetChildren()) do
        if old.Name == "CustomChangerModel" then
            old:Destroy()
        end
    end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Transparency = 0
        elseif p:IsA("Decal") then
            p.Transparency = 0
        end
    end
end

local function ApplyCustomModel(modelName)
    local char = LocalPlayer.Character
    if not char then return end
    
    RemoveCustomModel()
    
    local key = tostring(modelName):lower()
    local assetId = CustomModelAssetIDs[key]
    if not assetId then return end
    
    task.spawn(function()
        local success, objs = pcall(function()
            return game:GetObjects(assetId)
        end)
        
        if success and objs and #objs > 0 then
            local rawObj = objs[1]
            local newModel = nil
            
            if rawObj:IsA("Model") then
                newModel = rawObj:Clone()
            else
                newModel = Instance.new("Model")
                rawObj:Clone().Parent = newModel
            end
            
            if newModel then
                newModel.Name = "CustomChangerModel"
                
                -- Hide original body parts
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.Transparency = 1
                    elseif p:IsA("Decal") then
                        p.Transparency = 1
                    end
                end
                
                local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                if not hrp then return end
                
                newModel.Parent = char
                
                local primary = newModel.PrimaryPart or newModel:FindFirstChild("HumanoidRootPart") or newModel:FindFirstChildOfClass("BasePart")
                if primary then
                    newModel:PivotTo(hrp.CFrame)
                    for _, part in ipairs(newModel:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Anchored = false
                            part.CanCollide = false
                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = hrp
                            weld.Part1 = part
                            weld.Parent = part
                        end
                    end
                end
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if _G.CustomModelsActive then
        task.wait(0.5)
        ApplyCustomModel(_G.SelectedCustomModel)
    end
end)

-- Вспомогательная очистка всех видов Чамсов у модели
local function ClearChamsFromModel(model)
    if not model then return end
    for _, obj in ipairs(model:GetDescendants()) do
        if obj.Name == "MM2_BoxCham" or obj.Name == "MM2_HighlightCham" or obj.Name == "MM2_SelfCham" or obj.Name == "MM2_WeaponCham" or obj.Name == "MM2_GunCham" then
            obj:Destroy()
        end
    end
end

-- 1. MAIN
local SecMovement = CreateSection(Tabs["Main"], "Movement Mods")
CreateToggle(SecMovement, "Speedhack", false, function(st) _G.SpeedActive = st end)
CreateSlider(SecMovement, "Walk Speed", _G.SpeedValue, 16, 150, false, function(val) _G.SpeedValue = val end)
CreateToggle(SecMovement, "Bhop (Auto Jump)", false, function(st) _G.BhopActive = st end)
CreateSlider(SecMovement, "Bhop Jump Power (Height)", _G.BhopJumpPower, 20, 150, false, function(val) _G.BhopJumpPower = val end)
CreateToggle(SecMovement, "Infinite Jump (Fly Air)", false, function(st) _G.InfiniteJumpActive = st end)
CreateToggle(SecMovement, "Spinbot", false, function(st) _G.SpinbotActive = st end)
CreateSlider(SecMovement, "Spin Speed", _G.SpinSpeed, 10, 100, false, function(val) _G.SpinSpeed = val end)
CreateToggle(SecMovement, "Noclip (Pass Wall)", false, function(st) _G.NoclipActive = st end)

local SecUtility = CreateSection(Tabs["Main"], "Player Protection & Repel")
CreateToggle(SecUtility, "Anti-Fling", false, function(st) _G.AntiFlingActive = st end)
CreateToggle(SecUtility, "Auto Pickup Gun", false, function(st) _G.AutoPickupActive = st end)
CreateToggle(SecUtility, "Distance Pickup (No Teleport)", false, function(st) _G.PickupMode = st and "Distance" or "Teleport" end)
CreateToggle(SecUtility, "Murderer Repel Shield (Push Away)", false, function(st) _G.MurdererRepelActive = st end)

-- 2. VISUALS
local SecESP = CreateSection(Tabs["Visuals"], "Player ESP & Chams Options")
CreateToggle(SecESP, "Role Chams (Players)", false, function(st)
    _G.ChamsActive = st
    if not st then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                ClearChamsFromModel(player.Character)
            end
        end
    end
end)

CreateDropdown(SecESP, "Chams Style Mode", {"Highlight (Fill+Outline)", "Box (Squares)"}, "Highlight (Fill+Outline)", function(selected)
    if selected:find("Box") then
        _G.ChamsStyle = "Box"
    else
        _G.ChamsStyle = "Highlight"
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            ClearChamsFromModel(player.Character)
        end
    end
end)

CreateSlider(SecESP, "Chams Fill Transparency", _G.ChamsFillTransparency, 0, 1, true, function(val)
    _G.ChamsFillTransparency = val
end)

CreateToggle(SecESP, "Dynamic Visibility Check (Raycast)", true, function(st)
    _G.VisCheckActive = st
end)

CreateToggle(SecESP, "Per-Limb Vis Color (Head vs Body)", true, function(st)
    _G.PerLimbVisCheckActive = st
end)

CreateToggle(SecESP, "Self Chams", false, function(st)
    _G.SelfChamsActive = st
    if not st and LocalPlayer.Character then
        ClearChamsFromModel(LocalPlayer.Character)
    end
end)
CreateColorPicker(SecESP, "Self Chams Color", _G.SelfChamsColor, function(color)
    _G.SelfChamsColor = color
    if LocalPlayer.Character then ClearChamsFromModel(LocalPlayer.Character) end
end)

local Sec2DESP = CreateSection(Tabs["Visuals"], "Box ESP, Info Overlay & Skeleton")
CreateDropdown(Sec2DESP, "Box ESP Style", {"None", "2D Box", "2D Corner Box", "3D Box", "Filled 2D Box"}, "None", function(selected)
    _G.EspBoxType = selected
end)

CreateToggle(Sec2DESP, "Show Player Nickname (Name)", false, function(st)
    _G.EspNameActive = st
end)

CreateToggle(Sec2DESP, "Show Role & Held Weapon", false, function(st)
    _G.EspRoleActive = st
end)

CreateToggle(Sec2DESP, "Show Distance (Meters)", false, function(st)
    _G.EspDistanceActive = st
end)

CreateToggle(Sec2DESP, "Show Health Bar & Text", false, function(st)
    _G.EspHealthActive = st
end)

CreateToggle(Sec2DESP, "Skeleton ESP (Player Bones)", false, function(st)
    _G.EspSkeletonActive = st
end)

CreateDropdown(Sec2DESP, "ESP Text Font", {"SourceSansBold", "SourceSans", "GothamBold", "Gotham", "ArialBold", "Code", "Arcade", "RobotoBold", "UbuntuBold", "SciFi", "Fantasy"}, "SourceSansBold", function(selected)
    _G.EspFontName = selected
end)

CreateSlider(Sec2DESP, "ESP Text Size", _G.EspTextSize, 8, 24, false, function(val)
    _G.EspTextSize = val
end)

local SecESPColors = CreateSection(Tabs["Visuals"], "ESP & Visibility Role Colors")
CreateColorPicker(SecESPColors, "Murderer Vis Color", _G.VisColorMurderer, function(col) _G.VisColorMurderer = col end)
CreateColorPicker(SecESPColors, "Sheriff Vis Color", _G.VisColorSheriff, function(col) _G.VisColorSheriff = col end)
CreateColorPicker(SecESPColors, "Innocent Vis Color", _G.VisColorInnocent, function(col) _G.VisColorInnocent = col end)
CreateColorPicker(SecESPColors, "Occluded / Hidden Color", _G.OccludedColor, function(col) _G.OccludedColor = col end)

local SecWeaponVisuals = CreateSection(Tabs["Visuals"], "Weapon & Item Chams")
CreateToggle(SecWeaponVisuals, "Weapon Chams", false, function(st)
    _G.WeaponChamsActive = st
    if not st then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "MM2_WeaponCham" then obj:Destroy() end
        end
    end
end)
CreateColorPicker(SecWeaponVisuals, "Weapon Chams Color", _G.WeaponChamsColor, function(color)
    _G.WeaponChamsColor = color
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "MM2_WeaponCham" then obj:Destroy() end
    end
end)

CreateToggle(SecWeaponVisuals, "Dropped Gun ESP", false, function(st)
    _G.DroppedGunEspActive = st
    if not st then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "MM2_GunCham" then obj:Destroy() end
        end
    end
end)
CreateColorPicker(SecWeaponVisuals, "Dropped Gun Color", _G.DroppedGunEspColor, function(color)
    _G.DroppedGunEspColor = color
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "MM2_GunCham" then obj:Destroy() end
    end
end)

local SecModels = CreateSection(Tabs["Visuals"], "Custom Models Switcher")
CreateToggle(SecModels, "Enable Custom Model", false, function(st)
    _G.CustomModelsActive = st
    if st then
        ApplyCustomModel(_G.SelectedCustomModel)
    else
        RemoveCustomModel()
    end
end)
CreateDropdown(SecModels, "Select Model", {"donkey", "cute girl", "pig", "angel", "demon"}, "donkey", function(selected)
    _G.SelectedCustomModel = selected
    if _G.CustomModelsActive then
        ApplyCustomModel(selected)
    end
end)

-- 3. COMBAT
local SecCombat = CreateSection(Tabs["Combat"], "Aimbot & Prediction")
CreateToggle(SecCombat, "Camera Lock Aimbot (LKM)", false, function(st) _G.CameraAimActive = st end)
CreateToggle(SecCombat, "Real Invisible Silent Aim", false, function(st) _G.RealSilentAimActive = st end)
CreateToggle(SecCombat, "Auto Aim Murderer (Auto Shoot)", false, function(st) _G.AutoAimMurderer = st _G.AutoShootSheriff = st end)
CreateToggle(SecCombat, "Movement Velocity Prediction", false, function(st) _G.PredictionActive = st end)
CreateSlider(SecCombat, "Prediction Time", _G.PredictionAmount, 0.05, 0.5, true, function(val) _G.PredictionAmount = val end)
CreateToggle(SecCombat, "Fast Automatic Gun (Hold LKM)", false, function(st) _G.FastGunActive = st end)
CreateToggle(SecCombat, "AutoWall Check (Awall)", false, function(st) _G.AwallCheckActive = st end)
CreateToggle(SecCombat, "Show Dynamic Awall Square", false, function(st) 
    _G.ShowAwallSquare = st 
    AwallIndicator.Visible = st
end)
CreateToggle(SecCombat, "Hitbox Expander (Enemies)", false, function(st) _G.HitboxExpanderActive = st end)
CreateSlider(SecCombat, "Hitbox Size", _G.HitboxSize, 4, 20, false, function(val) _G.HitboxSize = val end)

local SecAura = CreateSection(Tabs["Combat"], "Kill Aura (Murderer)")
CreateToggle(SecAura, "Enable Kill Aura", false, function(st) _G.KillAuraActive = st end)
CreateSlider(SecAura, "Aura Range", _G.KillAuraRange, 5, 50, false, function(val) _G.KillAuraRange = val end)
CreateSlider(SecAura, "Attack Delay", _G.KillAuraDelay, 0.01, 0.5, true, function(val) _G.KillAuraDelay = val end)

-- 4. HVH SUPREMACY
local SecAntiAim = CreateSection(Tabs["HvH"], "Desync & Lag Engine")
CreateToggle(SecAntiAim, "Jitter Desync (Yaw Angle)", false, function(st) _G.JitterActive = st end)
CreateSlider(SecAntiAim, "Jitter Angle", _G.JitterRange, 15, 90, false, function(val) _G.JitterRange = val end)
CreateToggle(SecAntiAim, "Network Desync Lag", false, function(st) _G.NetworkFakeLagActive = st end)
CreateSlider(SecAntiAim, "Desync Lag Packets", _G.FakeLagLimit, 2, 20, false, function(val) _G.FakeLagLimit = val end)

local SecRageHvH = CreateSection(Tabs["HvH"], "Rage Combat Exploits")
CreateToggle(SecRageHvH, "Long Knife Reach (Hitbox TP)", false, function(st) _G.KnifeReachActive = st end)
CreateSlider(SecRageHvH, "Reach Distance", _G.KnifeReachDist, 10, 40, false, function(val) _G.KnifeReachDist = val end)
CreateToggle(SecRageHvH, "Auto Shoot Murderer (Sheriff)", false, function(st) _G.AutoShootSheriff = st end)
CreateToggle(SecRageHvH, "Backstab Teleport Aimbot", false, function(st) _G.BackstabAimbot = st end)
CreateToggle(SecRageHvH, "Anti-Murderer Orbit Shield", false, function(st) _G.AntiMurdererOrbit = st end)
CreateSlider(SecRageHvH, "Orbit Distance", _G.OrbitDistance, 8, 25, false, function(val) _G.OrbitDistance = val end)
CreateToggle(SecRageHvH, "Kill Trash Talker (Chat)", false, function(st) _G.KillTrashTalkActive = st end)

-- 5. SETTINGS
local SecColors = CreateSection(Tabs["Settings"], "Theme & Customization")
local ColorInfo = Instance.new("TextLabel")
ColorInfo.Parent = SecColors
ColorInfo.BackgroundTransparency = 1
ColorInfo.Size = UDim2.new(1, 0, 0, 24)
ColorInfo.Font = Enum.Font.SourceSans
ColorInfo.Text = "Umbrella Supremacy v10.0 -- Menu Customization"
ColorInfo.TextColor3 = Color3.fromRGB(150, 155, 165)
ColorInfo.TextSize = 12
ColorInfo.TextWrapped = true

CreateColorPicker(SecColors, "Menu Accent Color", Color3.fromRGB(220, 35, 45), function(accentColor)
    UIStrokeMain.Color = accentColor
    HeaderLine.BackgroundColor3 = accentColor
    LoadingStroke.Color = accentColor
    ProgressBarFill.BackgroundColor3 = accentColor
    for _, page in pairs(Tabs) do
        page.ScrollBarImageColor3 = accentColor
    end
    for _, btn in pairs(TabButtons) do
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if btn.TextColor3 == Color3.fromRGB(255, 255, 255) then
            btn.BackgroundColor3 = Color3.new(accentColor.R * 0.25, accentColor.G * 0.25, accentColor.B * 0.25)
            if stroke then stroke.Color = accentColor end
        end
    end
end)

CreateSlider(SecColors, "Menu Transparency", 0, 0, 0.8, true, function(val)
    MainFrame.BackgroundTransparency = val
    Sidebar.BackgroundTransparency = val
    Header.BackgroundTransparency = val
end)

local SecKeybinds = CreateSection(Tabs["Settings"], "Controls & Unload")
local ToggleKey = Enum.KeyCode.RightShift
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Parent = SecKeybinds
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Size = UDim2.new(1, 0, 0, 22)
KeybindLabel.Font = Enum.Font.SourceSans
KeybindLabel.Text = "Toggle Keybind: [ RightShift ]"
KeybindLabel.TextColor3 = Color3.fromRGB(200, 205, 215)
KeybindLabel.TextSize = 12
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Parent = SecKeybinds
UnloadBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 20)
UnloadBtn.Size = UDim2.new(1, 0, 0, 26)
UnloadBtn.Font = Enum.Font.SourceSansBold
UnloadBtn.Text = "Unload / Destroy Interface"
UnloadBtn.TextColor3 = Color3.fromRGB(255, 70, 80)
UnloadBtn.TextSize = 12
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)
local UnloadStroke = Instance.new("UIStroke", UnloadBtn)
UnloadStroke.Color = Color3.fromRGB(220, 35, 45)
UnloadStroke.Thickness = 1

UnloadBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

SwitchTab("Main")

------------------------------------------------------------------------
-- ЛОГИКА АНИМАЦИИ ЗАГРУЗКИ
------------------------------------------------------------------------
task.spawn(function()
    local spinConn = RunService.RenderStepped:Connect(function(dt)
        LoadingLogoHolder.Rotation = (LoadingLogoHolder.Rotation + (dt * 200)) % 360
        HeaderLogoHolder.Rotation = (HeaderLogoHolder.Rotation + (dt * 90)) % 360
    end)
    
    local fillTween = TweenService:Create(ProgressBarFill, TweenInfo.new(1.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
    fillTween:Play()
    fillTween.Completed:Wait()
    
    task.wait(0.2)
    
    local fadeOut = TweenService:Create(LoadingFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Wait()
    
    LoadingFrame:Destroy()
    spinConn:Disconnect()
    
    RunService.RenderStepped:Connect(function(dt)
        HeaderLogoHolder.Rotation = (HeaderLogoHolder.Rotation + (dt * 30)) % 360
    end)
    
    MainFrame.Visible = true
end)

------------------------------------------------------------------------
-- ИГРОВАЯ ЛОГИКА MM2 + СИСТЕМА ПРЕДИКТА (MOVEMENT PREDICTION)
------------------------------------------------------------------------
local RoleColors = {
    Murderer = Color3.fromRGB(255, 35, 45),
    Sheriff  = Color3.fromRGB(30, 140, 255),
    Innocent = Color3.fromRGB(30, 255, 100)
}

local function GetRole(player)
    if not player then return "Innocent" end
    local bpack = player:FindFirstChild("Backpack")
    local char = player.Character
    if (bpack and bpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
        return "Murderer"
    elseif (bpack and (bpack:FindFirstChild("Gun") or bpack:FindFirstChild("Revolver"))) or 
           (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) then
        return "Sheriff"
    end
    return "Innocent"
end

local function CheckPartVisibility(part)
    if not part or not part:IsA("BasePart") or not LocalPlayer.Character then return false end
    local origin = Camera.CFrame.Position
    local destination = part.Position
    local direction = (destination - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        if result.Instance and (result.Instance:IsDescendantOf(part.Parent) or result.Instance == part) then
            return true
        end
        return false
    end
    return true
end

local function GetRoleVisColor(role)
    if role == "Murderer" then
        return _G.VisColorMurderer
    elseif role == "Sheriff" then
        return _G.VisColorSheriff
    else
        return _G.VisColorInnocent
    end
end

local function ApplyChamsToCharacter(character, color, isSelf, player)
    if not character then return end
    
    local role = player and GetRole(player) or "Innocent"
    local visColor = isSelf and _G.SelfChamsColor or GetRoleVisColor(role)
    
    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    local headVis = head and CheckPartVisibility(head) or false
    local torsoVis = (torso and CheckPartVisibility(torso)) or (hrp and CheckPartVisibility(hrp)) or false
    local overallVis = headVis or torsoVis
    
    if _G.ChamsStyle == "Highlight" then
        local hlName = isSelf and "MM2_SelfCham" or "MM2_HighlightCham"
        local existingHl = character:FindFirstChild(hlName)
        if not existingHl then
            existingHl = Instance.new("Highlight")
            existingHl.Name = hlName
            existingHl.Adornee = character
            existingHl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            existingHl.Parent = character
        end
        local hlColor = isSelf and visColor or ((not _G.VisCheckActive or overallVis) and visColor or _G.OccludedColor)
        existingHl.FillColor = hlColor
        existingHl.OutlineColor = hlColor
        existingHl.FillTransparency = _G.ChamsFillTransparency
        existingHl.OutlineTransparency = _G.ChamsOutlineTransparency
    else
        local boxName = isSelf and "MM2_SelfCham" or "MM2_BoxCham"
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local box = part:FindFirstChild(boxName)
                if not box then
                    box = Instance.new("BoxHandleAdornment")
                    box.Name = boxName
                    box.Size = part.Size + Vector3.new(0.04, 0.04, 0.04)
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Adornee = part
                    box.Parent = part
                end
                
                local partColor = visColor
                if not isSelf and _G.VisCheckActive then
                    if _G.PerLimbVisCheckActive then
                        -- Точная проверка каждого отдельного лимба (руки, ноги, голова, тело) через стены
                        local isPartVis = CheckPartVisibility(part)
                        partColor = isPartVis and visColor or _G.OccludedColor
                    else
                        partColor = overallVis and visColor or _G.OccludedColor
                    end
                end
                
                box.Color3 = partColor
                box.Transparency = _G.ChamsFillTransparency
            end
        end
    end
end

local function CreateBoxCham(part, color, chamName)
    if part:FindFirstChild(chamName) then 
        part:FindFirstChild(chamName).Color3 = color
        return 
    end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = chamName
    box.Size = part.Size + Vector3.new(0.04, 0.04, 0.04)
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Adornee = part
    box.Color3 = color
    box.Transparency = 0.3
    box.Parent = part
end

-- ФУНКЦИЯ РАСЧЕТА ПРЕДИКТА ДВИЖЕНИЯ ЦЕЛИ (Velocity Prediction)
local function GetPredictedPosition(targetHrp)
    if not targetHrp then return Vector3.new(0, 0, 0) end
    if _G.PredictionActive then
        local vel = targetHrp.Velocity
        return targetHrp.Position + (vel * _G.PredictionAmount)
    end
    return targetHrp.Position
end

-- ФУНКЦИЯ ПРОВЕРКИ AWALL И РАСЧЕТА ДИСТАНЦИИ
local function CheckAwallRay(targetHrp)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return false, 999 
    end
    
    local startPos = Camera.CFrame.Position
    local endPos = targetHrp and GetPredictedPosition(targetHrp) or (Camera.CFrame.Position + Camera.CFrame.LookVector * 100)
    local direction = (endPos - startPos)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(startPos, direction, raycastParams)
    
    if result then
        if targetHrp and result.Instance:IsDescendantOf(targetHrp.Parent) then
            return true, result.Distance
        else
            return false, result.Distance
        end
    end
    return true, 100
end

-- РЕНДЕР ДИНАМИЧЕСКОГО КВАДРАТА AWALL
RunService.RenderStepped:Connect(function()
    if _G.ShowAwallSquare then
        AwallIndicator.Visible = true
        local isVisible, dist = CheckAwallRay(nil)
        
        local squareSize = math.clamp(110 - dist * 2.2, 24, 95)
        AwallIndicator.Size = UDim2.new(0, squareSize, 0, squareSize)
        
        if isVisible then
            AwallIndicator.BackgroundColor3 = Color3.fromRGB(30, 220, 100)
            AwallText.Text = "OPEN"
            AwallText.TextColor3 = Color3.fromRGB(30, 255, 100)
        else
            AwallIndicator.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
            AwallText.Text = "WALL (" .. math.round(dist) .. "m)"
            AwallText.TextColor3 = Color3.fromRGB(255, 70, 70)
        end
    else
        AwallIndicator.Visible = false
    end
end)

-- 1. MURDERER REPEL SHIELD
RunService.RenderStepped:Connect(function()
    if _G.MurdererRepelActive and GetRole(LocalPlayer) ~= "Murderer" and LocalPlayer.Character then
        local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and GetRole(player) == "Murderer" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local mHrp = player.Character.HumanoidRootPart
                    local dist = (myHrp.Position - mHrp.Position).Magnitude
                    if dist < 22 then
                        local avoidDir = (myHrp.Position - mHrp.Position).Unit
                        myHrp.CFrame = CFrame.new(myHrp.Position + (avoidDir * 2.5), mHrp.Position)
                    end
                end
            end
        end
    end
end)

-- 2. WEAPON CHAMS
task.spawn(function()
    while true do
        task.wait(0.4)
        if _G.WeaponChamsActive then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    for _, tool in ipairs(player.Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local handle = tool:FindFirstChild("Handle")
                            if handle then
                                CreateBoxCham(handle, _G.WeaponChamsColor, "MM2_WeaponCham")
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 3. DROPPED GUN ESP
task.spawn(function()
    while true do
        task.wait(0.4)
        if _G.DroppedGunEspActive then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                    CreateBoxCham(obj, _G.DroppedGunEspColor, "MM2_GunCham")
                end
            end
        end
    end
end)

-- 4. HVH: KNIFE REACH
task.spawn(function()
    while true do
        task.wait(0.05)
        if _G.KnifeReachActive and GetRole(LocalPlayer) == "Murderer" and LocalPlayer.Character then
            local knife = LocalPlayer.Character:FindFirstChild("Knife")
            local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if knife and myHrp then
                local handle = knife:FindFirstChild("Handle")
                if handle then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local targetHrp = player.Character.HumanoidRootPart
                            local predPos = GetPredictedPosition(targetHrp)
                            local dist = (myHrp.Position - predPos).Magnitude
                            if dist <= _G.KnifeReachDist then
                                firetouchinterest(handle, targetHrp, 0)
                                firetouchinterest(handle, targetHrp, 1)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 5. FAST AUTOMATIC GUN
local isShootingFast = false
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isShootingFast = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isShootingFast = false
    end
end)

task.spawn(function()
    while true do
        task.wait(0.08)
        if _G.FastGunActive and isShootingFast and LocalPlayer.Character then
            local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Revolver")
            if not gun then
                local bpack = LocalPlayer:FindFirstChild("Backpack")
                if bpack then
                    local bgun = bpack:FindFirstChild("Gun") or bpack:FindFirstChild("Revolver")
                    if bgun then
                        bgun.Parent = LocalPlayer.Character
                        gun = bgun
                    end
                end
            end
            
            if gun then
                gun:Activate()
                local shootRemote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("ShootServer")
                if shootRemote and shootRemote:IsA("RemoteEvent") then
                    shootRemote:FireServer(Camera.CFrame.LookVector * 200)
                end
            end
        end
    end
end)

-- 6. HVH & COMBAT: AUTO AIM & SHOOT MURDERER (VISIBLE CHECK)
task.spawn(function()
    while true do
        task.wait(0.04)
        if (_G.AutoAimMurderer or _G.AutoShootSheriff) and (GetRole(LocalPlayer) == "Sheriff" or GetRole(LocalPlayer) == "Innocent") and LocalPlayer.Character then
            local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHrp then
                local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Revolver")
                if not gun then
                    local bpack = LocalPlayer:FindFirstChild("Backpack")
                    if bpack then
                        local bgun = bpack:FindFirstChild("Gun") or bpack:FindFirstChild("Revolver")
                        if bgun then
                            bgun.Parent = LocalPlayer.Character
                            gun = bgun
                        end
                    end
                end
                if gun then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and GetRole(player) == "Murderer" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local targetHrp = player.Character.HumanoidRootPart
                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                local isVisible, _ = CheckAwallRay(targetHrp)
                                if isVisible then
                                    local predPos = GetPredictedPosition(targetHrp)
                                    gun:Activate()
                                    local shootRemote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("ShootServer")
                                    if shootRemote and shootRemote:IsA("RemoteEvent") then
                                        pcall(function() shootRemote:FireServer(CFrame.new(myHrp.Position, predPos)) end)
                                        pcall(function() shootRemote:FireServer(predPos) end)
                                    end
                                    task.wait(0.15)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 7. HVH: ANTI-MURDERER ORBIT SHIELD
local orbitAngle = 0
RunService.RenderStepped:Connect(function(dt)
    if _G.AntiMurdererOrbit and LocalPlayer.Character then
        local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and GetRole(player) == "Murderer" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local mHrp = player.Character.HumanoidRootPart
                    orbitAngle = (orbitAngle + (dt * 300)) % 360
                    local offset = Vector3.new(math.cos(math.rad(orbitAngle)) * _G.OrbitDistance, 2, math.sin(math.rad(orbitAngle)) * _G.OrbitDistance)
                    myHrp.CFrame = CFrame.new(mHrp.Position + offset, mHrp.Position)
                end
            end
        end
    end
end)

-- 8. HVH: BACKSTAB TELEPORT AIMBOT
RunService.RenderStepped:Connect(function()
    if _G.BackstabAimbot and LocalPlayer.Character then
        local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = player.Character.HumanoidRootPart
                    local dist = (myHrp.Position - targetHrp.Position).Magnitude
                    if dist <= 35 then
                        myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2.5)
                    end
                end
            end
        end
    end
end)

-- 9. HVH: JITTER YAW DESYNC
local jitterToggle = false
RunService.RenderStepped:Connect(function()
    if _G.JitterActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            jitterToggle = not jitterToggle
            local angle = jitterToggle and _G.JitterRange or -_G.JitterRange
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(angle), 0)
        end
    end
end)

-- 10. HVH: NETWORK DESYNC FAKE LAG
local networkCounter = 0
RunService.Heartbeat:Connect(function()
    if _G.NetworkFakeLagActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            networkCounter = networkCounter + 1
            if networkCounter < _G.FakeLagLimit then
                if sethiddenproperty then
                    sethiddenproperty(hrp, "NetworkIsWaitingForDatabase", true)
                end
            else
                networkCounter = 0
                if sethiddenproperty then
                    sethiddenproperty(hrp, "NetworkIsWaitingForDatabase", false)
                end
            end
        end
    end
end)

-- 11. HVH / COMBAT: HITBOX EXPANDER
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.HitboxExpanderActive then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                        hrp.Transparency = 0.7
                        hrp.Color = Color3.fromRGB(220, 35, 45)
                        hrp.CanCollide = false
                    end
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Size ~= Vector3.new(2, 2, 1) then
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                    end
                end
            end
        end
    end
end)

-- 12. HVH: INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJumpActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- 13. HVH: KILL TRASH TALK
local TrashPhrases = {
    "Umbrella Corp owns you ☂",
    "Ez hit by Umbrella MM2!",
    "L + Ratio + Umbrella Win ☂",
    "Go buy Umbrella MM2 exploit!",
    "Too ez for Umbrella HvH Engine ☂",
    "Sit down kid, Umbrella on top ☂",
    "Imagine missing with aimbot, umbrella better!",
    "Clean tap by Umbrella MM2 ☂",
    "Where is your skill? Powered by Umbrella!",
    "Dodge this? Umbrella Silent Aim active ☂",
    "Cry about it to Roblox support ☂",
    "Umbrella Supremacy v10.0 -- No chance!",
    "Skill issue detected! Install Umbrella ☂",
    "Nice try, but Umbrella is superior ☂",
    "Outplayed & Outsmarted by Umbrella MM2!",
    "You just got deleted by Umbrella ☂",
    "0 ping aim, 100% precision with Umbrella!",
    "Ez win ez game, Umbrella dominating ☂",
    "Is that your best? Umbrella owns MM2!",
    "Better luck next round! Powered by Umbrella ☂"
}

local function SendChatMessage(msg)
    local textChat = game:GetService("TextChatService")
    if textChat.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = textChat.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync(msg) end
    else
        game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer(msg, "All")
    end
end

local lastKillTime = 0
task.spawn(function()
    while true do
        task.wait(_G.KillAuraDelay)
        if _G.KillAuraActive and GetRole(LocalPlayer) == "Murderer" and LocalPlayer.Character then
            local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
            if knife then
                if knife.Parent == LocalPlayer.Backpack then
                    knife.Parent = LocalPlayer.Character
                end
                local handle = knife:FindFirstChild("Handle")
                local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and handle then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local targetHrp = player.Character.HumanoidRootPart
                            local distance = (myHrp.Position - targetHrp.Position).Magnitude
                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            if distance <= _G.KillAuraRange and humanoid and humanoid.Health > 0 then
                                local stabRemote = knife:FindFirstChild("Stab") or knife:FindFirstChild("StabServer")
                                if stabRemote and stabRemote:IsA("RemoteEvent") then
                                    stabRemote:FireServer()
                                end
                                if firetouchinterest then
                                    firetouchinterest(handle, targetHrp, 0)
                                    firetouchinterest(handle, targetHrp, 1)
                                end
                                if _G.KillTrashTalkActive and tick() - lastKillTime > 3 then
                                    lastKillTime = tick()
                                    SendChatMessage(TrashPhrases[math.random(1, #TrashPhrases)])
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Поток PLAYERS CHAMS
task.spawn(function()
    while true do
        task.wait(0.3)
        if _G.ChamsActive then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local role = GetRole(player)
                    local color = RoleColors[role]
                    ApplyChamsToCharacter(player.Character, color, false, player)
                end
            end
        end
    end
end)

------------------------------------------------------------------------
-- 2D BOX, OVERLAY INFO (NICK, ROLE, DIST, HP) & SKELETON ESP ENGINE
------------------------------------------------------------------------
local EspOverlayHolder = Instance.new("Folder")
EspOverlayHolder.Name = "MM2_EspOverlayHolder"
EspOverlayHolder.Parent = ScreenGui

local FontMap = {
    ["SourceSansBold"] = Enum.Font.SourceSansBold,
    ["SourceSans"]     = Enum.Font.SourceSans,
    ["GothamBold"]     = Enum.Font.GothamBold,
    ["Gotham"]         = Enum.Font.Gotham,
    ["ArialBold"]      = Enum.Font.ArialBold,
    ["Code"]           = Enum.Font.Code,
    ["Arcade"]         = Enum.Font.Arcade,
    ["RobotoBold"]     = Enum.Font.RobotoBold,
    ["UbuntuBold"]     = Enum.Font.UbuntuBold,
    ["SciFi"]          = Enum.Font.SciFi,
    ["Fantasy"]        = Enum.Font.Fantasy,
}

local SkeletonBonesR6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"}
}

local SkeletonBonesR15 = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function ClearEspOverlays()
    for _, child in ipairs(EspOverlayHolder:GetChildren()) do
        child:Destroy()
    end
end

local function ClearSkeletonFromCharacter(char)
    if not char then return end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            for _, child in ipairs(part:GetChildren()) do
                if (child:IsA("Beam") and child.Name:find("SkL_")) or (child:IsA("Attachment") and child.Name:find("SkAtt_")) then
                    child:Destroy()
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if _G.EspBoxType == "None" and not _G.EspNameActive and not _G.EspRoleActive and not _G.EspDistanceActive and not _G.EspHealthActive and not _G.EspSkeletonActive then
        ClearEspOverlays()
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                ClearSkeletonFromCharacter(player.Character)
                local old3d = player.Character:FindFirstChild("MM2_3DBoxEsp")
                if old3d then old3d:Destroy() end
            end
        end
        return
    end

    local currentFont = FontMap[_G.EspFontName] or Enum.Font.SourceSansBold
    local baseSize = _G.EspTextSize or 12

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 and head then
                local role = GetRole(player)
                local headVis = _G.VisCheckActive and CheckPartVisibility(head) or true
                local bodyVis = _G.VisCheckActive and CheckPartVisibility(hrp) or true
                local overallVis = headVis or bodyVis
                local visColor = (overallVis or not _G.VisCheckActive) and GetRoleVisColor(role) or _G.OccludedColor
                
                -- SKELETON ESP DRAWING (World Space Beams - runs independently of 2D box screen limits)
                if _G.EspSkeletonActive then
                    local bones = char:FindFirstChild("UpperTorso") and SkeletonBonesR15 or SkeletonBonesR6
                    for _, pair in ipairs(bones) do
                        local p1 = char:FindFirstChild(pair[1])
                        local p2 = char:FindFirstChild(pair[2])
                        if p1 and p2 then
                            local p1Vis = _G.VisCheckActive and CheckPartVisibility(p1) or true
                            local p2Vis = _G.VisCheckActive and CheckPartVisibility(p2) or true
                            local boneVis = p1Vis or p2Vis
                            local boneColor = (boneVis or not _G.VisCheckActive) and GetRoleVisColor(role) or _G.OccludedColor
                            
                            local att1Name = "SkAtt_" .. pair[1] .. "_" .. pair[2]
                            local att2Name = "SkAtt_" .. pair[2] .. "_" .. pair[1]
                            local beamName = "SkL_" .. pair[1] .. "_" .. pair[2]

                            local b1 = p1:FindFirstChild(att1Name)
                            if not b1 then
                                b1 = Instance.new("Attachment")
                                b1.Name = att1Name
                                b1.Parent = p1
                            end

                            local b2 = p2:FindFirstChild(att2Name)
                            if not b2 then
                                b2 = Instance.new("Attachment")
                                b2.Name = att2Name
                                b2.Parent = p2
                            end

                            local beam = p1:FindFirstChild(beamName)
                            if not beam then
                                beam = Instance.new("Beam")
                                beam.Name = beamName
                                beam.Attachment0 = b1
                                beam.Attachment1 = b2
                                beam.Width0 = 0.15
                                beam.Width1 = 0.15
                                beam.AlwaysOnTop = true
                                beam.FaceCamera = true
                                beam.LightInfluence = 0
                                beam.LightEmission = 1
                                beam.Parent = p1
                            end
                            beam.Color = ColorSequence.new(boneColor)
                            beam.Enabled = true
                        end
                    end
                else
                    ClearSkeletonFromCharacter(char)
                end

                -- 2D OVERLAY INFO (NICK, ROLE, DIST, HP)
                local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
                local legsPos, legsOnScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                
                if headOnScreen or legsOnScreen then
                    local bGuiName = "EspGui_" .. player.Name
                    local bGui = EspOverlayHolder:FindFirstChild(bGuiName)
                    if not bGui then
                        bGui = Instance.new("BillboardGui")
                        bGui.Name = bGuiName
                        bGui.Parent = EspOverlayHolder
                        bGui.AlwaysOnTop = true
                        bGui.ExtentsOffsetWorldSpace = Vector3.new(0, 3.2, 0)
                        
                        local mainLayout = Instance.new("UIListLayout", bGui)
                        mainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        mainLayout.Padding = UDim.new(0, 1)
                        
                        local nLabel = Instance.new("TextLabel")
                        nLabel.Name = "NameLabel"
                        nLabel.Parent = bGui
                        nLabel.BackgroundTransparency = 1
                        nLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        nLabel.TextStrokeTransparency = 0.3
                        nLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        
                        local rLabel = Instance.new("TextLabel")
                        rLabel.Name = "RoleLabel"
                        rLabel.Parent = bGui
                        rLabel.BackgroundTransparency = 1
                        rLabel.TextStrokeTransparency = 0.3
                        rLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        
                        local dLabel = Instance.new("TextLabel")
                        dLabel.Name = "DistLabel"
                        dLabel.Parent = bGui
                        dLabel.BackgroundTransparency = 1
                        dLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                        dLabel.TextStrokeTransparency = 0.3
                        
                        local hpBg = Instance.new("Frame")
                        hpBg.Name = "HealthBg"
                        hpBg.Parent = bGui
                        hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        hpBg.Size = UDim2.new(0, 80, 0, 5)
                        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)
                        
                        local hpFill = Instance.new("Frame")
                        hpFill.Name = "HealthFill"
                        hpFill.Parent = hpBg
                        hpFill.BackgroundColor3 = Color3.fromRGB(30, 255, 100)
                        hpFill.Size = UDim2.new(1, 0, 1, 0)
                        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)
                    end
                    
                    bGui.Adornee = head
                    bGui.Size = UDim2.new(0, 240, 0, (baseSize + 3) * 3 + 20)

                    local nLabel = bGui:FindFirstChild("NameLabel")
                    local rLabel = bGui:FindFirstChild("RoleLabel")
                    local dLabel = bGui:FindFirstChild("DistLabel")
                    local hpBg = bGui:FindFirstChild("HealthBg")
                    local hpFill = hpBg and hpBg:FindFirstChild("HealthFill")
                    
                    if nLabel then
                        nLabel.Visible = _G.EspNameActive
                        nLabel.Font = currentFont
                        nLabel.TextSize = baseSize
                        nLabel.Size = UDim2.new(1, 0, 0, baseSize + 2)
                        nLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                        nLabel.TextColor3 = visColor
                    end
                    
                    if rLabel then
                        rLabel.Visible = _G.EspRoleActive
                        rLabel.Font = currentFont
                        rLabel.TextSize = math.max(8, baseSize - 1)
                        rLabel.Size = UDim2.new(1, 0, 0, math.max(8, baseSize - 1) + 2)
                        local toolStr = ""
                        for _, item in ipairs(char:GetChildren()) do
                            if item:IsA("Tool") then
                                toolStr = " [" .. item.Name .. "]"
                                break
                            end
                        end
                        rLabel.Text = "[ " .. role:upper() .. toolStr .. " ]"
                        rLabel.TextColor3 = visColor
                    end
                    
                    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local dist = myHrp and (myHrp.Position - hrp.Position).Magnitude or 0
                    if dLabel then
                        dLabel.Visible = _G.EspDistanceActive
                        dLabel.Font = currentFont
                        dLabel.TextSize = math.max(8, baseSize - 2)
                        dLabel.Size = UDim2.new(1, 0, 0, math.max(8, baseSize - 2) + 2)
                        dLabel.Text = math.floor(dist) .. "m"
                    end
                    
                    if hpBg and hpFill then
                        hpBg.Visible = _G.EspHealthActive
                        local healthPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        hpFill.Size = UDim2.new(healthPct, 0, 1, 0)
                        hpFill.BackgroundColor3 = Color3.fromRGB(255 - math.floor(healthPct * 225), math.floor(healthPct * 225), 30)
                    end
                    
                    -- 3D BOX HANDLE ADORNMENT ESP
                    if _G.EspBoxType == "3D Box" or _G.EspBoxType == "2D Box" or _G.EspBoxType == "Filled 2D Box" or _G.EspBoxType == "2D Corner Box" then
                        local box3d = char:FindFirstChild("MM2_3DBoxEsp")
                        if not box3d then
                            box3d = Instance.new("BoxHandleAdornment")
                            box3d.Name = "MM2_3DBoxEsp"
                            box3d.AlwaysOnTop = true
                            box3d.ZIndex = 6
                            box3d.Size = Vector3.new(3, 5, 3)
                            box3d.Adornee = hrp
                            box3d.Parent = char
                        end
                        box3d.Color3 = visColor
                        box3d.Transparency = (_G.EspBoxType == "Filled 2D Box") and 0.4 or 0.75
                    else
                        local old3d = char:FindFirstChild("MM2_3DBoxEsp")
                        if old3d then old3d:Destroy() end
                    end

                else
                    local oldGui = EspOverlayHolder:FindFirstChild("EspGui_" .. player.Name)
                    if oldGui then oldGui:Destroy() end
                end
            else
                ClearSkeletonFromCharacter(char)
            end
        end
    end
end)

-- Поток SELF CHAMS
task.spawn(function()
    while true do
        task.wait(0.3)
        if _G.SelfChamsActive and LocalPlayer.Character then
            ApplyChamsToCharacter(LocalPlayer.Character, _G.SelfChamsColor, true)
        end
    end
end)

-- ПОТОК SPINBOT
RunService.RenderStepped:Connect(function(dt)
    if _G.SpinbotActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(_G.SpinSpeed), 0)
        end
    end
end)

-- ПОТОК BHOP (с настраиваемой высотой / JumpPower)
RunService.RenderStepped:Connect(function()
    if _G.BhopActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = _G.BhopJumpPower
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Поток NOCLIP
RunService.Stepped:Connect(function()
    if _G.NoclipActive and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ANTI-FLING
RunService.Heartbeat:Connect(function()
    if _G.AntiFlingActive and LocalPlayer.Character then
        local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            if myHrp.Velocity.Magnitude > 75 or myHrp.RotVelocity.Magnitude > 75 then
                myHrp.Velocity = Vector3.new(0, 0, 0)
                myHrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Velocity = Vector3.new(0, 0, 0)
                        part.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end
end)

-- ПОТОК SPEEDHACK
RunService.Heartbeat:Connect(function()
    if _G.SpeedActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = _G.SpeedValue
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid.WalkSpeed ~= 16 then
                humanoid.WalkSpeed = 16
            end
        end
    end
end)

-- АВТОПОДБОР ПИСТОЛЕТА (ДВА РЕЖИМА: ТЕЛЕПОРТ И НА РАССТОЯНИИ BBOX/TOUCH)
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoPickupActive and GetRole(LocalPlayer) ~= "Murderer" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local gunInstance = nil
            local drop = workspace:FindFirstChild("GunDrop")
            if drop then
                gunInstance = drop
            else
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == "GunDrop" or (obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent.Name == "LeftHand") then
                        if obj:IsA("BasePart") then
                            gunInstance = obj
                            break
                        elseif obj.Parent:IsA("BasePart") then
                            gunInstance = obj.Parent
                            break
                        end
                    end
                end
            end
            
            if gunInstance and gunInstance:IsA("BasePart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                
                if _G.PickupMode == "Distance" or _G.PickupMode == "Reach" then
                    -- ВТОРОЙ ВИД ПОДБОРА: БЕЗ ТЕЛЕПОРТАЦИИ (На расстоянии через Touch Interest & Part Extension)
                    local char = LocalPlayer.Character
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local touchHandle = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or root
                    
                    if firetouchinterest and touchHandle then
                        firetouchinterest(touchHandle, gunInstance, 0)
                        firetouchinterest(touchHandle, gunInstance, 1)
                    end
                    
                    -- Запасная логика подтягивания коллизии пистолета без перемещения тела игрока
                    if (root.Position - gunInstance.Position).Magnitude < 100 then
                        if gunInstance:FindFirstChildOfClass("TouchTransmitter") then
                            local oldCFrame = gunInstance.CFrame
                            gunInstance.CFrame = root.CFrame
                            task.wait(0.05)
                            if gunInstance and gunInstance.Parent then
                                gunInstance.CFrame = oldCFrame
                            end
                        end
                    end
                else
                    -- ПЕРВЫЙ ВИД ПОДБОРА: БЫСТРЫЙ ТЕЛЕПОРТ
                    local oldCFrame = hrp.CFrame
                    local checkTime = 0
                    while gunInstance and gunInstance.Parent and checkTime < 0.3 do
                        hrp.CFrame = gunInstance.CFrame
                        RunService.Heartbeat:Wait()
                        checkTime = checkTime + game:GetService("RunService").Heartbeat:Wait()
                    end
                    hrp.CFrame = oldCFrame
                    task.wait(0.5)
                end
            end
        end
    end
end)

local function GetClosestTarget()
    local myRole = GetRole(LocalPlayer)
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRole = GetRole(player)
            local validTarget = false
            if myRole == "Murderer" and targetRole ~= "Murderer" then
                validTarget = true
            elseif (myRole == "Sheriff" or myRole == "Innocent") and targetRole == "Murderer" then
                validTarget = true
            end
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if validTarget and humanoid and humanoid.Health > 0 then
                local targetHrp = player.Character.HumanoidRootPart
                local isVisible, _ = CheckAwallRay(targetHrp)
                if isVisible then
                    local predPos = GetPredictedPosition(targetHrp)
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - predPos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function IsHoldingWeapon()
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("gun") or tool.Name:lower():find("revolver")) then
            return true
        end
    end
    return false
end

-- 1. CAMERA LOCK AIMBOT
RunService.RenderStepped:Connect(function()
    if _G.CameraAimActive and IsHoldingWeapon() then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local target = GetClosestTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local predPos = GetPredictedPosition(target.Character.HumanoidRootPart)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, predPos)
            end
        end
    end
end)

-- 2. REAL INVISIBLE SILENT AIM (MM2 Specialized Hook for Shoot/Stab/Throw Remotes & Index/Namecall)
local Mouse = LocalPlayer:GetMouse()
local OldIndex = nil
OldIndex = hookmetamethod(game, "__index", function(self, key)
    if _G.RealSilentAimActive and not checkcaller() and (key == "Hit" or key == "Target") then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local predPos = GetPredictedPosition(target.Character.HumanoidRootPart)
            if key == "Hit" then
                return CFrame.new(predPos)
            elseif key == "Target" then
                return target.Character.HumanoidRootPart
            end
        end
    end
    return OldIndex(self, key)
end)

local OldNamecall = nil
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if _G.RealSilentAimActive and not checkcaller() and (method == "FireServer" or method == "fireServer") then
        local remoteName = self.Name
        if remoteName == "Shoot" or remoteName == "ShootServer" or remoteName == "Stab" or remoteName == "StabServer" or remoteName == "Throw" or remoteName == "KnifeServer" then
            local target = GetClosestTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local predPos = GetPredictedPosition(target.Character.HumanoidRootPart)
                for i, arg in ipairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = predPos
                    elseif typeof(arg) == "CFrame" then
                        args[i] = CFrame.new(arg.Position, predPos)
                    end
                end
                if #args == 0 or (typeof(args[1]) ~= "Vector3" and typeof(args[1]) ~= "CFrame") then
                    args[1] = predPos
                end
                return OldNamecall(self, unpack(args))
            end
        end
    end
    
    return OldNamecall(self, ...)
end)

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentArea.Visible = false
        Sidebar.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 720, 0, 48), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 720, 0, 480), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        task.wait(0.15)
        ContentArea.Visible = true
        Sidebar.Visible = true
        MinimizeBtn.Text = "−"
    end
end)

-- CUSTOM DRAGGING UTILITY (Fixes draggable bug blocking child button clicks)
local dragToggle = nil
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(0.08), {Position = position}):Play()
end

Header.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not UserInputService:GetFocusedTextBox() then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateInput(input)
    end
end)
