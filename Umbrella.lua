--[[
    ========================================================================
    UMBRELLA CORPORATION (MURDER MYSTERY 2 HVH SUPREMACY EDITION v11.0)
    Full HvH Feature Suite: Hit Logs, Hit Sounds, Hitmarkers, Tracers,
    Impact Effects, Watermark, and Advanced HvH Movement Engine
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
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

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
local UmbrellaCircles = {}

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
    table.insert(UmbrellaCircles, UmbrellaCircle)
    
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
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
MainFrame.Size = UDim2.new(0, 750, 0, 500)
MainFrame.Active = true
MainFrame.Draggable = true
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
Badge.Text = "SUPREMACY v11.0"
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

-- 1. FOV CIRCLE (КРУГ ПРИЦЕЛА AIMBOT)
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "Umbrella_FOVCircle"
FOVCircle.Parent = ScreenGui
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", FOVCircle)
fovStroke.Color = Color3.fromRGB(220, 35, 45)
fovStroke.Thickness = 1.2

-- 2. CUSTOM HVH CROSSHAIR (КАСТОМНЫЙ ПРИЦЕЛ)
local CrosshairCenter = Instance.new("Frame")
CrosshairCenter.Name = "Umbrella_Crosshair"
CrosshairCenter.Parent = ScreenGui
CrosshairCenter.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairCenter.Size = UDim2.new(0, 4, 0, 4)
CrosshairCenter.BackgroundColor3 = Color3.fromRGB(255, 45, 55)
CrosshairCenter.BorderSizePixel = 0
CrosshairCenter.Visible = false
Instance.new("UICorner", CrosshairCenter).CornerRadius = UDim.new(1, 0)

local chBars = {}
for i = 1, 4 do
    local bar = Instance.new("Frame")
    bar.Parent = CrosshairCenter
    bar.BorderSizePixel = 0
    bar.BackgroundColor3 = Color3.fromRGB(255, 45, 55)
    chBars[i] = bar
end

-- 3. SNAPLINES CONTAINER
local SnaplinesContainer = Instance.new("Frame")
SnaplinesContainer.Name = "Umbrella_Snaplines"
SnaplinesContainer.Parent = ScreenGui
SnaplinesContainer.BackgroundTransparency = 1
SnaplinesContainer.Size = UDim2.new(1, 0, 1, 0)
SnaplinesContainer.ZIndex = 2

------------------------------------------------------------------------
-- 3. HVH ВИЗУАЛЫ: HIT LOGS, WATERMARK, HITMARKER
------------------------------------------------------------------------

-- КОНТЕЙНЕР HIT LOGS (Левый верхний угол)
local HitLogsContainer = Instance.new("Frame")
HitLogsContainer.Name = "HitLogsContainer"
HitLogsContainer.Parent = ScreenGui
HitLogsContainer.BackgroundTransparency = 1
HitLogsContainer.Position = UDim2.new(0, 15, 0, 15)
HitLogsContainer.Size = UDim2.new(0, 360, 0, 260)
HitLogsContainer.ClipsDescendants = false

local HitLogsLayout = Instance.new("UIListLayout")
HitLogsLayout.Parent = HitLogsContainer
HitLogsLayout.SortOrder = Enum.SortOrder.LayoutOrder
HitLogsLayout.Padding = UDim.new(0, 4)

-- WATERMARK (Правый верхний угол)
local Watermark = Instance.new("Frame")
Watermark.Name = "Umbrella_Watermark"
Watermark.Parent = ScreenGui
Watermark.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
Watermark.Position = UDim2.new(1, -265, 0, 12)
Watermark.Size = UDim2.new(0, 250, 0, 26)
Watermark.BorderSizePixel = 0
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 4)
local wmStroke = Instance.new("UIStroke", Watermark)
wmStroke.Color = Color3.fromRGB(220, 35, 45)
wmStroke.Thickness = 1.2

local WatermarkLine = Instance.new("Frame", Watermark)
WatermarkLine.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
WatermarkLine.Size = UDim2.new(0, 3, 1, 0)
WatermarkLine.BorderSizePixel = 0

local WatermarkLabel = Instance.new("TextLabel")
WatermarkLabel.Parent = Watermark
WatermarkLabel.BackgroundTransparency = 1
WatermarkLabel.Position = UDim2.new(0, 8, 0, 0)
WatermarkLabel.Size = UDim2.new(1, -12, 1, 0)
WatermarkLabel.Font = Enum.Font.SourceSansBold
WatermarkLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
WatermarkLabel.TextSize = 12
WatermarkLabel.RichText = true
WatermarkLabel.Text = 'UMBRELLA <font color="#dc232d">SUPREMACY</font> | 60 FPS | MM2 HvH'
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left

-- SCREEN HITMARKER (Центр экрана)
local HitmarkerHolder = Instance.new("Frame")
HitmarkerHolder.Name = "HitmarkerHolder"
HitmarkerHolder.Parent = ScreenGui
HitmarkerHolder.AnchorPoint = Vector2.new(0.5, 0.5)
HitmarkerHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
HitmarkerHolder.Size = UDim2.new(0, 24, 0, 24)
HitmarkerHolder.BackgroundTransparency = 1

local function CreateHitmarkerLine(rot)
    local line = Instance.new("Frame")
    line.Parent = HitmarkerHolder
    line.BackgroundColor3 = Color3.fromRGB(255, 55, 65)
    line.Size = UDim2.new(0, 9, 0, 2)
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = UDim2.new(0.5, 0, 0.5, 0)
    line.Rotation = rot
    line.BorderSizePixel = 0
    line.BackgroundTransparency = 1
    return line
end

local hmLines = {
    CreateHitmarkerLine(45),
    CreateHitmarkerLine(135),
    CreateHitmarkerLine(225),
    CreateHitmarkerLine(315)
}

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
    Page.Position = UDim2.new(0, 10, 0, 10)
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Visible = false
    Page.ScrollBarThickness = 5
    Page.ScrollBarImageColor3 = Color3.fromRGB(220, 35, 45)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.BorderSizePixel = 0
    Page.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    Page.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    Page.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    
    local Grid = Instance.new("UIGridLayout")
    Grid.Parent = Page
    Grid.CellSize = UDim2.new(0, 275, 0, 290)
    Grid.CellPadding = UDim2.new(0, 14, 0, 14)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    
    Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, Grid.AbsoluteContentSize.Y + 28)
    end)
    
    Tabs[name] = Page
    return Page
end

CreateTabPage("Main")
CreateTabPage("Visuals")
CreateTabPage("Combat")
CreateTabPage("HvH")
CreateTabPage("Settings")

------------------------------------------------------------------------
-- СИСТЕМА ЦВЕТОВ, ТЕМ И КАСТОМИЗАЦИИ ИНТЕРФЕЙСА
------------------------------------------------------------------------
local ColorPresets = {
    ["Umbrella Red"]     = Color3.fromRGB(220, 35, 45),
    ["Blood Crimson"]    = Color3.fromRGB(255, 30, 40),
    ["Cyber Cyan"]       = Color3.fromRGB(0, 240, 255),
    ["Electric Purple"]  = Color3.fromRGB(180, 50, 255),
    ["Neon Pink"]        = Color3.fromRGB(255, 20, 147),
    ["Acid Green"]       = Color3.fromRGB(40, 255, 70),
    ["Sunset Gold"]      = Color3.fromRGB(255, 200, 30),
    ["Deep Orange"]      = Color3.fromRGB(255, 110, 20),
    ["Sky Blue"]         = Color3.fromRGB(50, 150, 255),
    ["Pure White"]       = Color3.fromRGB(255, 255, 255),
    ["Muted Gray"]       = Color3.fromRGB(150, 155, 165),
    ["Rainbow RGB"]      = Color3.fromRGB(255, 255, 255)
}

local ColorOptionNames = {
    "Umbrella Red",
    "Blood Crimson",
    "Cyber Cyan",
    "Electric Purple",
    "Neon Pink",
    "Acid Green",
    "Sunset Gold",
    "Deep Orange",
    "Sky Blue",
    "Pure White",
    "Rainbow RGB"
}

local FOVColorOptionNames = {
    "Theme Match",
    "Umbrella Red",
    "Blood Crimson",
    "Cyber Cyan",
    "Electric Purple",
    "Neon Pink",
    "Acid Green",
    "Sunset Gold",
    "Deep Orange",
    "Sky Blue",
    "Pure White",
    "Rainbow RGB"
}

local MenuBgPresets = {
    ["Classic Dark"]   = {Main = Color3.fromRGB(14, 15, 19), Header = Color3.fromRGB(18, 19, 25), Sidebar = Color3.fromRGB(15, 16, 21), Section = Color3.fromRGB(18, 19, 25), Stroke = Color3.fromRGB(30, 32, 40)},
    ["Pitch Black"]    = {Main = Color3.fromRGB(8, 8, 10),   Header = Color3.fromRGB(12, 12, 15), Sidebar = Color3.fromRGB(10, 10, 13), Section = Color3.fromRGB(13, 13, 17), Stroke = Color3.fromRGB(24, 24, 30)},
    ["Midnight Navy"]  = {Main = Color3.fromRGB(10, 13, 22), Header = Color3.fromRGB(14, 18, 30), Sidebar = Color3.fromRGB(12, 15, 25), Section = Color3.fromRGB(16, 21, 34), Stroke = Color3.fromRGB(26, 35, 54)},
    ["Charcoal Gray"]  = {Main = Color3.fromRGB(22, 23, 27), Header = Color3.fromRGB(28, 29, 35), Sidebar = Color3.fromRGB(25, 26, 31), Section = Color3.fromRGB(28, 29, 35), Stroke = Color3.fromRGB(42, 44, 54)},
    ["Deep Crimson"]   = {Main = Color3.fromRGB(20, 10, 13), Header = Color3.fromRGB(28, 12, 17), Sidebar = Color3.fromRGB(24, 11, 15), Section = Color3.fromRGB(28, 12, 17), Stroke = Color3.fromRGB(48, 20, 26)},
    ["Dark Violet"]    = {Main = Color3.fromRGB(16, 10, 22), Header = Color3.fromRGB(24, 13, 32), Sidebar = Color3.fromRGB(20, 11, 27), Section = Color3.fromRGB(24, 13, 32), Stroke = Color3.fromRGB(42, 22, 56)}
}

local MenuBgOptionNames = {
    "Classic Dark",
    "Pitch Black",
    "Midnight Navy",
    "Charcoal Gray",
    "Deep Crimson",
    "Dark Violet"
}

_G.SelectedThemeColor = "Umbrella Red"
_G.SelectedMenuBgTheme = "Classic Dark"
_G.MenuTransparency = 0
_G.SectionTransparency = 0
_G.SelectedFOVColor = "Umbrella Red"
_G.FOVTransparency = 0
_G.FOVThickness = 1.2
_G.SelectedWeaponChamColor = "Sunset Gold"
_G.SelectedDroppedGunColor = "Cyber Cyan"
_G.SelectedMurdererColor = "Blood Crimson"
_G.SelectedSheriffColor = "Sky Blue"
_G.SelectedInnocentColor = "Acid Green"
_G.ChamsFillTransparency = 0.35
_G.ChamsOutlineTransparency = 0.0
_G.RainbowColor = Color3.fromRGB(220, 35, 45)

local AllSections = {}
local AllSectionTitles = {}
local AllSectionLines = {}
local AllSectionScrollbars = {}
local AllSectionStrokes = {}
local AllSliderFills = {}
local AllToggles = {}
local AllDropdownStrokes = {}
local AllDropdownScrollbars = {}

local function GetThemeAccentColor()
    if _G.SelectedThemeColor == "Rainbow RGB" or _G.RGBSyncActive then
        return _G.RainbowColor or Color3.fromRGB(220, 35, 45)
    end
    return ColorPresets[_G.SelectedThemeColor] or Color3.fromRGB(220, 35, 45)
end

local function ColorToHex(c)
    local r = math.clamp(math.round(c.R * 255), 0, 255)
    local g = math.clamp(math.round(c.G * 255), 0, 255)
    local b = math.clamp(math.round(c.B * 255), 0, 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

local CurrentActiveTab = "Main"

local function SwitchTab(targetTab)
    CurrentActiveTab = targetTab
    for name, page in pairs(Tabs) do
        page.Visible = (name == targetTab)
    end
    local accent = GetThemeAccentColor()
    local bgPreset = MenuBgPresets[_G.SelectedMenuBgTheme] or MenuBgPresets["Classic Dark"]
    for name, btn in pairs(TabButtons) do
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if name == targetTab then
            btn.BackgroundColor3 = Color3.fromRGB(
                math.clamp(math.round(accent.R * 60), 20, 80),
                math.clamp(math.round(accent.G * 60), 15, 80),
                math.clamp(math.round(accent.B * 60), 18, 80)
            )
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            if stroke then stroke.Color = accent end
        else
            btn.BackgroundColor3 = bgPreset.Sidebar
            btn.TextColor3 = Color3.fromRGB(140, 145, 155)
            if stroke then stroke.Color = bgPreset.Stroke end
        end
    end
end

local function ApplyMenuTheme()
    local accent = GetThemeAccentColor()
    local bgPreset = MenuBgPresets[_G.SelectedMenuBgTheme] or MenuBgPresets["Classic Dark"]
    
    MainFrame.BackgroundColor3 = bgPreset.Main
    MainFrame.BackgroundTransparency = _G.MenuTransparency or 0
    
    Header.BackgroundColor3 = bgPreset.Header
    Header.BackgroundTransparency = math.clamp((_G.MenuTransparency or 0) * 0.85, 0, 0.95)
    
    Sidebar.BackgroundColor3 = bgPreset.Sidebar
    Sidebar.BackgroundTransparency = math.clamp((_G.MenuTransparency or 0) * 0.85, 0, 0.95)
    
    if SidebarLine then SidebarLine.BackgroundColor3 = bgPreset.Stroke end
    
    UIStrokeMain.Color = accent
    HeaderLine.BackgroundColor3 = accent
    
    TitleLabel.Text = 'UMBRELLA <font color="' .. ColorToHex(accent) .. '">CORPORATION</font>'
    Badge.TextColor3 = accent
    Badge.BackgroundColor3 = Color3.fromRGB(
        math.clamp(math.round(accent.R * 45), 25, 70),
        math.clamp(math.round(accent.G * 45), 15, 70),
        math.clamp(math.round(accent.B * 45), 18, 70)
    )
    
    for _, circle in ipairs(UmbrellaCircles) do
        circle.BackgroundColor3 = accent
    end
    
    if Watermark then
        Watermark.BackgroundColor3 = bgPreset.Sidebar
        Watermark.BackgroundTransparency = _G.MenuTransparency or 0
        local wmStroke = Watermark:FindFirstChildOfClass("UIStroke")
        if wmStroke then wmStroke.Color = accent end
        local wmLine = Watermark:FindFirstChildWhichIsA("Frame")
        if wmLine then wmLine.BackgroundColor3 = accent end
        local wmLabel = Watermark:FindFirstChildOfClass("TextLabel")
        if wmLabel then
            wmLabel.Text = 'UMBRELLA <font color="' .. ColorToHex(accent) .. '">SUPREMACY</font> | 60 FPS | MM2 HvH'
        end
    end
    
    for _, sec in ipairs(AllSections) do
        sec.BackgroundColor3 = bgPreset.Section
        sec.BackgroundTransparency = _G.SectionTransparency or 0
    end
    for _, stroke in ipairs(AllSectionStrokes) do
        stroke.Color = bgPreset.Stroke
    end
    for _, line in ipairs(AllSectionLines) do
        line.BackgroundColor3 = bgPreset.Stroke
    end
    for _, title in ipairs(AllSectionTitles) do
        title.TextColor3 = accent
    end
    for _, scroller in ipairs(AllSectionScrollbars) do
        scroller.ScrollBarImageColor3 = accent
    end
    for _, tabScroller in pairs(Tabs) do
        tabScroller.ScrollBarImageColor3 = accent
    end
    for _, fill in ipairs(AllSliderFills) do
        fill.BackgroundColor3 = accent
    end
    for _, dropStroke in ipairs(AllDropdownStrokes) do
        dropStroke.Color = accent
    end
    for _, dropScroller in ipairs(AllDropdownScrollbars) do
        dropScroller.ScrollBarImageColor3 = accent
    end
    for _, toggleData in ipairs(AllToggles) do
        if toggleData.GetState() then
            toggleData.Button.BackgroundColor3 = accent
        else
            toggleData.Button.BackgroundColor3 = bgPreset.Stroke
        end
    end
    
    SwitchTab(CurrentActiveTab or "Main")
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
    local bgPreset = MenuBgPresets[_G.SelectedMenuBgTheme] or MenuBgPresets["Classic Dark"]
    Section.BackgroundColor3 = bgPreset.Section
    Section.BackgroundTransparency = _G.SectionTransparency or 0
    Section.Size = UDim2.new(0, 275, 0, 290)
    
    Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = Section
    Stroke.Color = bgPreset.Stroke
    Stroke.Thickness = 1
    
    local SecTitle = Instance.new("TextLabel")
    SecTitle.Parent = Section
    SecTitle.BackgroundTransparency = 1
    SecTitle.Position = UDim2.new(0, 10, 0, 6)
    SecTitle.Size = UDim2.new(1, -20, 0, 18)
    SecTitle.Font = Enum.Font.SourceSansBold
    SecTitle.Text = title:upper()
    SecTitle.TextColor3 = GetThemeAccentColor()
    SecTitle.TextSize = 12
    SecTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local SecLine = Instance.new("Frame")
    SecLine.Parent = Section
    SecLine.BackgroundColor3 = bgPreset.Stroke
    SecLine.BorderSizePixel = 0
    SecLine.Position = UDim2.new(0, 10, 0, 26)
    SecLine.Size = UDim2.new(1, -20, 0, 1)
    
    local SecContainer = Instance.new("ScrollingFrame")
    SecContainer.Parent = Section
    SecContainer.BackgroundTransparency = 1
    SecContainer.Position = UDim2.new(0, 8, 0, 30)
    SecContainer.Size = UDim2.new(1, -12, 1, -34)
    SecContainer.ScrollBarThickness = 3
    SecContainer.ScrollBarImageColor3 = GetThemeAccentColor()
    SecContainer.BorderSizePixel = 0
    SecContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    SecContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SecContainer.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    SecContainer.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    SecContainer.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = SecContainer
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 6)
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SecContainer.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    
    table.insert(AllSections, Section)
    table.insert(AllSectionTitles, SecTitle)
    table.insert(AllSectionLines, SecLine)
    table.insert(AllSectionScrollbars, SecContainer)
    table.insert(AllSectionStrokes, Stroke)
    
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
    local bgPreset = MenuBgPresets[_G.SelectedMenuBgTheme] or MenuBgPresets["Classic Dark"]
    SwitchBg.BackgroundColor3 = defaultState and GetThemeAccentColor() or bgPreset.Stroke
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
        local currentBg = MenuBgPresets[_G.SelectedMenuBgTheme] or MenuBgPresets["Classic Dark"]
        if state then
            SwitchBg.BackgroundColor3 = GetThemeAccentColor()
            SwitchDot.Position = UDim2.new(1, -16, 0.5, -6)
        else
            SwitchBg.BackgroundColor3 = currentBg.Stroke
            SwitchDot.Position = UDim2.new(0, 2, 0.5, -6)
        end
        callback(state)
    end)
    
    table.insert(AllToggles, {
        Button = SwitchBg,
        GetState = function() return state end
    })
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
    local bgPreset = MenuBgPresets[_G.SelectedMenuBgTheme] or MenuBgPresets["Classic Dark"]
    BarBg.BackgroundColor3 = bgPreset.Stroke
    BarBg.Position = UDim2.new(0, 0, 0, 16)
    BarBg.Size = UDim2.new(1, 0, 0, 6)
    Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0, 3)
    
    local Fill = Instance.new("Frame")
    Fill.Parent = BarBg
    Fill.BackgroundColor3 = GetThemeAccentColor()
    local startPercent = (defaultVal - minVal) / (maxVal - minVal)
    Fill.Size = UDim2.new(math.clamp(startPercent, 0, 1), 0, 1, 0)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)
    table.insert(AllSliderFills, Fill)
    
    local Handle = Instance.new("TextButton")
    Handle.Parent = BarBg
    Handle.Text = ""
    Handle.Position = UDim2.new(math.clamp(startPercent, 0, 1), -5, 0.5, -5)
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
    local maxVisibleItems = math.min(#options, 6)
    local listHeight = maxVisibleItems * 22 + 4

    local DropFrame = Instance.new("Frame")
    DropFrame.Parent = parentSec
    DropFrame.BackgroundTransparency = 1
    DropFrame.Size = UDim2.new(1, -4, 0, 42)
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
    local bgPreset = MenuBgPresets[_G.SelectedMenuBgTheme] or MenuBgPresets["Classic Dark"]
    MainBtn.BackgroundColor3 = bgPreset.Stroke
    MainBtn.Position = UDim2.new(0, 0, 0, 16)
    MainBtn.Size = UDim2.new(1, 0, 0, 22)
    MainBtn.Font = Enum.Font.SourceSansBold
    MainBtn.Text = "  " .. tostring(defaultOpt) .. "  ▼"
    MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainBtn.TextSize = 12
    MainBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 4)

    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Parent = DropFrame
    ListFrame.BackgroundColor3 = bgPreset.Header
    ListFrame.Position = UDim2.new(0, 0, 0, 40)
    ListFrame.Size = UDim2.new(1, 0, 0, listHeight)
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 22 + 4)
    ListFrame.ScrollBarThickness = 3
    ListFrame.ScrollBarImageColor3 = GetThemeAccentColor()
    ListFrame.BorderSizePixel = 0
    ListFrame.Visible = false
    ListFrame.ZIndex = 25
    ListFrame.ClipsDescendants = true
    ListFrame.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    ListFrame.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    ListFrame.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 4)
    local ListStroke = Instance.new("UIStroke", ListFrame)
    ListStroke.Color = GetThemeAccentColor()
    ListStroke.Thickness = 1
    
    table.insert(AllDropdownStrokes, ListStroke)
    table.insert(AllDropdownScrollbars, ListFrame)

    local ListLayout = Instance.new("UIListLayout", ListFrame)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 2)
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 4)
    end)

    local currentSelected = tostring(defaultOpt)
    local isExpanded = false
    MainBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        ListFrame.Visible = isExpanded
        if isExpanded then
            DropFrame.Size = UDim2.new(1, -4, 0, 42 + listHeight + 4)
            MainBtn.Text = "  " .. currentSelected .. "  ▲"
        else
            DropFrame.Size = UDim2.new(1, -4, 0, 42)
            MainBtn.Text = "  " .. currentSelected .. "  ▼"
        end
    end)

    for i, optName in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Parent = ListFrame
        OptBtn.BackgroundTransparency = 1
        OptBtn.Size = UDim2.new(1, -6, 0, 20)
        OptBtn.Font = Enum.Font.SourceSans
        OptBtn.Text = "  " .. optName
        OptBtn.TextColor3 = Color3.fromRGB(200, 205, 215)
        OptBtn.TextSize = 12
        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
        OptBtn.ZIndex = 26

        OptBtn.MouseButton1Click:Connect(function()
            currentSelected = tostring(optName)
            MainBtn.Text = "  " .. optName .. "  ▼"
            isExpanded = false
            ListFrame.Visible = false
            DropFrame.Size = UDim2.new(1, -4, 0, 42)
            callback(optName)
        end)
    end
end

------------------------------------------------------------------------
-- НАПОЛНЕНИЕ ВКЛАДОК И НАСТРОЙКА HVH ФУНКЦИЙ
------------------------------------------------------------------------
_G.ChamsActive = false
_G.ChamsStyle = "Fill / Glow"
_G.SelfChamsActive = false
_G.SelectedSelfChamColor = "Neon Pink"
_G.WeaponChamsActive = false
_G.DroppedGunEspActive = false
_G.MurdererRepelActive = false

_G.CustomModelsActive = false
_G.SelectedCustomModel = "angel"
_G.CustomModelScale = 1.0
_G.CustomModelHeightOffset = 0.0
_G.CustomModelRotation = 0

-- Custom Weapons (Knife & Gun Skins / 3D Models)
_G.CustomKnifeActive = false
_G.SelectedKnifeModel = "Luger Blade / Heat"
_G.CustomGunActive = false
_G.SelectedGunModel = "Golden Luger"
_G.CustomWeaponMaterial = "Default"
_G.CustomWeaponColor = "Original"
_G.CustomWeaponAura = "None"
_G.WeaponTrailActive = false
_G.SelectedWeaponTrailColor = "Rainbow RGB"

_G.CameraAimActive = false
_G.RealSilentAimActive = false
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

-- HvH Advanced Movement Features
_G.AutoStrafeActive = false
_G.FlyActive = false
_G.FlySpeed = 50
_G.FastStopActive = false
_G.HighJumpActive = false
_G.JumpBoostPower = 100
_G.LongJumpActive = false
_G.LongJumpPower = 60

-- HvH Hit Visuals & Sounds
_G.HitLogsActive = true
_G.HitSoundsActive = true
_G.SelectedHitSound = "Skeet"
_G.HitSoundVolume = 3
_G.HitmarkersActive = true
_G.TracersActive = true
_G.HitEffectActive = true
_G.WatermarkActive = true

-- World, Fog & Atmospheric Visuals
_G.FogColorActive = false
_G.SelectedFogColor = "Blood Red"
_G.FogStart = 0
_G.FogEnd = 300

_G.CustomSkyActive = false
_G.SelectedSkyPreset = "Purple Galaxy"

_G.TimeOfDayActive = false
_G.TimeOfDayValue = 0

_G.AmbientActive = false
_G.SelectedAmbient = "Blood Red"

_G.FullbrightActive = false

_G.ColorCorrectionActive = false
_G.SaturationBoost = 1.2
_G.ContrastBoost = 0.3

-- Chinese Hat Visuals
_G.ChineseHatActive = false
_G.SelectedHatColor = "Blood Red"
_G.HatSpinActive = true
_G.HatHeight = 1.15
_G.HatScale = 1.2

-- Neon Trails & Ground Rope
_G.PlayerTrailActive = false
_G.SelectedTrailColor = "Blood Red"
_G.TrailLifetime = 0.6
_G.FootRopeActive = false
_G.SelectedRopeColor = "Blood Red"
_G.RopeLifetime = 0.9
_G.RopeWidth = 0.35

-- Custom Footstep Sounds & Camera FX
_G.CustomFootstepsActive = false
_G.SelectedFootstep = "Minecraft Stone"
_G.FootstepsVolume = 4
_G.CustomFOVActive = false
_G.CustomFOVValue = 70
_G.BlurActive = false
_G.BlurSize = 6
_G.KillFlashActive = true

-- Aimbot Precision & Smoothing Fix
_G.AimBone = "Head"
_G.AimSmoothness = 1
_G.ShowFOVCircle = true
_G.FOVCircleRadius = 130
_G.AlwaysAim = false

-- HvH Aesthetics & Visuals
_G.CustomCrosshairActive = false
_G.SelectedCrosshairColor = "Blood Red"
_G.CrosshairSize = 8
_G.CrosshairGap = 3
_G.SnaplinesActive = false
_G.HeadDotActive = false
_G.RGBSyncActive = false

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

-- Custom Models (English Keys + Roblox Asset IDs)
local ModelCandidateList = {
    ["angel"] = {
        "rbxassetid://12318430407"
    },
    ["spiderman"] = {
        "rbxassetid://13803824982"
    },
    ["pig"] = {
        "rbxassetid://12928490816",
        "rbxassetid://3642054273",
        "rbxassetid://2892055918"
    },
    ["donkey"] = {
        "rbxassetid://6299324098",
        "rbxassetid://1801346817",
        "rbxassetid://150272153",
        "rbxassetid://15258571412"
    },
    ["la vaca saturnita"] = {
        "rbxassetid://129565620410132",
        "rbxassetid://76127116347738",
        "rbxassetid://128822862184236",
        "rbxassetid://74147642842271",
        "rbxassetid://11986494439",
        "rbxassetid://35685520"
    }
}

local ModelRotationOffsets = {
    ["la vaca saturnita"] = CFrame.Angles(0, math.rad(180), 0)
}

-- Load external Lua table from GitHub if available without overriding built-in verified models
task.spawn(function()
    pcall(function()
        local downloadedLua = game:HttpGet("https://raw.githubusercontent.com/Rostik22803/Umbrella-mm2/refs/heads/main/models.lua")
        if downloadedLua and downloadedLua ~= "" then
            local loadedModels = loadstring(downloadedLua)()
            if typeof(loadedModels) == "table" then
                for k, v in pairs(loadedModels) do
                    local key = tostring(k):lower()
                    local strVal = tostring(v)
                    if not strVal:find("rbxassetid://") then
                        strVal = "rbxassetid://" .. strVal
                    end
                    if not ModelCandidateList[key] then
                        ModelCandidateList[key] = { strVal }
                    else
                        table.insert(ModelCandidateList[key], strVal)
                    end
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
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum.Sit = false
    end
end

local function LoadModelObjects(key)
    local candidates = ModelCandidateList[key]
    if not candidates then return nil end
    for _, assetUrl in ipairs(candidates) do
        local success, objs = pcall(function()
            return game:GetObjects(assetUrl)
        end)
        if success and objs and #objs > 0 then
            return objs
        end
    end
    return nil
end

local function ApplyCustomModel(modelName)
    local char = LocalPlayer.Character
    if not char then return end
    
    RemoveCustomModel()
    
    local key = tostring(modelName):lower()
    local candidates = ModelCandidateList[key]
    if not candidates then return end
    
    task.spawn(function()
        local objs = LoadModelObjects(key)
        if not objs or #objs == 0 then return end
        
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
            
            -- Strip any conflicting Humanoids, NPC Scripts, Controllers, Seats that freeze jumping or walking
            for _, obj in ipairs(newModel:GetDescendants()) do
                if obj:IsA("LuaSourceContainer") or obj:IsA("Humanoid") or obj:IsA("AnimationController")
                or obj:IsA("BodyMover") or obj:IsA("Seat") or obj:IsA("TouchTransmitter") then
                    obj:Destroy()
                end
            end
            
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if not hrp then return end
            
            -- Find or assign primary part
            local primary = newModel.PrimaryPart or newModel:FindFirstChild("HumanoidRootPart") or newModel:FindFirstChildWhichIsA("BasePart")
            if not primary then
                for _, p in ipairs(newModel:GetDescendants()) do
                    if p:IsA("BasePart") then
                        primary = p
                        break
                    end
                end
            end
            
            if primary then
                newModel.PrimaryPart = primary
                
                -- Auto-normalize oversized models (La Vaca Saturnita, etc.) to standard player height
                local successBox, modelSize = pcall(function()
                    local _, sz = newModel:GetBoundingBox()
                    return sz
                end)
                
                if successBox and modelSize and modelSize.Y > 0 then
                    local targetNormalHeight = 5.3 -- Standard player character height
                    if modelSize.Y > targetNormalHeight then
                        local autoFactor = targetNormalHeight / modelSize.Y
                        pcall(function()
                            newModel:ScaleTo(autoFactor)
                        end)
                    end
                end
                
                -- User Scale multiplier from slider
                local userMultiplier = _G.CustomModelScale or 1.0
                if userMultiplier ~= 1.0 then
                    pcall(function()
                        newModel:ScaleTo(userMultiplier)
                    end)
                end
                
                -- Position at HRP with height offset and rotation (La Vaca Saturnita rotated 180 deg)
                local yOffset = _G.CustomModelHeightOffset or 0
                local baseRot = ModelRotationOffsets[key] or CFrame.new()
                local userRot = (_G.CustomModelRotation and _G.CustomModelRotation ~= 0) and CFrame.Angles(0, math.rad(_G.CustomModelRotation), 0) or CFrame.new()
                newModel:PivotTo(hrp.CFrame * CFrame.new(0, yOffset, 0) * baseRot * userRot)
                
                -- Configure all parts: Massless = true, CanCollide = false, CanQuery = false, CanTouch = false
                for _, part in ipairs(newModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                        part.CanCollide = false
                        part.CanTouch = false
                        part.CanQuery = false
                        part.Massless = true -- CRITICAL: prevents jump and walking physics bugs!
                        local weld = Instance.new("WeldConstraint")
                        weld.Part0 = hrp
                        weld.Part1 = part
                        weld.Parent = part
                    end
                end
                
                newModel.Parent = char
                
                -- Hide original parts only after custom model is successfully mounted and verified
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and not p:IsDescendantOf(newModel) then
                        p.Transparency = 1
                    elseif p:IsA("Decal") and not p:IsDescendantOf(newModel) then
                        p.Transparency = 1
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

------------------------------------------------------------------------
-- CUSTOM WEAPONS ENGINE (KNIFE & GUN SKINS / 3D MODELS / FX)
------------------------------------------------------------------------
local KnifePresets = {
    ["Default"] = nil,
    ["Luger Blade / Heat"] = {
        MeshId = "rbxassetid://105333894",
        TextureId = "rbxassetid://105334003",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(255, 90, 20)
    },
    ["Fang (Serrated Godly)"] = {
        MeshId = "rbxassetid://117500241",
        TextureId = "rbxassetid://117500388",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(210, 210, 220)
    },
    ["Saw (Buzzsaw Godly)"] = {
        MeshId = "rbxassetid://168119698",
        TextureId = "rbxassetid://168119736",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(220, 40, 40)
    },
    ["Seer (Emerald Glow)"] = {
        MeshId = "rbxassetid://156092238",
        TextureId = "rbxassetid://156092253",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(30, 255, 120)
    },
    ["Shark (Predator)"] = {
        MeshId = "rbxassetid://118269783",
        TextureId = "rbxassetid://118269752",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(40, 160, 220)
    },
    ["Blood Dagger"] = {
        MeshId = "rbxassetid://51682254",
        TextureId = "rbxassetid://51682267",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(230, 20, 40)
    },
    ["Ghost Blade"] = {
        MeshId = "rbxassetid://64131019",
        TextureId = "rbxassetid://64131051",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.ForceField,
        Color = Color3.fromRGB(220, 240, 255)
    },
    ["Shadow Katana"] = {
        MeshId = "rbxassetid://86297695",
        TextureId = "rbxassetid://86290910",
        Scale = Vector3.new(1.15, 1.15, 1.15),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(35, 35, 35)
    },
    ["Rainbow Periastron (Godly)"] = {
        MeshId = "rbxassetid://80557857",
        TextureId = "rbxassetid://157345185",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        IsChroma = true
    },
    ["Darkheart Blade"] = {
        MeshId = "rbxasset://fonts/sword.mesh",
        TextureId = "rbxasset://textures/SwordTexture.png",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(40, 5, 50)
    },
    ["Classic Linked Sword"] = {
        MeshId = "rbxassetid://12221720",
        TextureId = "rbxassetid://12224218",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(220, 220, 230)
    },
    ["Chroma Rainbow Blade"] = {
        MeshId = "rbxassetid://121944778",
        TextureId = "rbxassetid://157019835",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        IsChroma = true
    },
    ["Plasmite Cyber Knife"] = {
        MeshId = "rbxassetid://121944778",
        TextureId = "rbxassetid://161369273",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(0, 255, 255)
    },
    ["Ice Glacier Dagger"] = {
        MeshId = "rbxassetid://121944778",
        TextureId = "rbxassetid://161313071",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Glass,
        Color = Color3.fromRGB(140, 220, 255)
    },
    ["Midnight Dark Knife"] = {
        MeshId = "rbxassetid://121944778",
        TextureId = "rbxassetid://161367322",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(130, 20, 255)
    },
    ["Lightsaber (Neon Beam)"] = {
        IsSpecial3D = "Lightsaber",
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(0, 255, 255)
    }
}

local GunPresets = {
    ["Default"] = nil,
    ["Golden Luger"] = {
        MeshId = "rbxassetid://95356090",
        TextureId = "rbxassetid://95387789",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(255, 215, 0)
    },
    ["Sci-Fi Laser Revolver"] = {
        MeshId = "rbxassetid://18265627",
        TextureId = "rbxassetid://18265614",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(0, 255, 255)
    },
    ["Phaser (Plasma Gun)"] = {
        MeshId = "rbxassetid://69486593",
        TextureId = "rbxassetid://69486519",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(255, 50, 200)
    },
    ["Chroma Luger (Animated RGB)"] = {
        MeshId = "rbxassetid://95356090",
        TextureId = "rbxassetid://95387789",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        IsChroma = true
    },
    ["Sheriff .45 Revolver"] = {
        MeshId = "rbxassetid://97886770",
        TextureId = "rbxassetid://97888197",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(255, 205, 50)
    },
    ["Darkbringer Style (Void Glow)"] = {
        MeshId = "rbxassetid://97886770",
        TextureId = "",
        Scale = Vector3.new(1.1, 1.1, 1.1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(120, 10, 240)
    },
    ["Lightbringer Style (Holy Glow)"] = {
        MeshId = "rbxassetid://97886770",
        TextureId = "",
        Scale = Vector3.new(1.1, 1.1, 1.1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(255, 255, 200)
    }
}

local KnifeModelNames = {
    "Luger Blade / Heat",
    "Fang (Serrated Godly)",
    "Saw (Buzzsaw Godly)",
    "Seer (Emerald Glow)",
    "Shark (Predator)",
    "Blood Dagger",
    "Ghost Blade",
    "Shadow Katana",
    "Rainbow Periastron (Godly)",
    "Darkheart Blade",
    "Classic Linked Sword",
    "Chroma Rainbow Blade",
    "Plasmite Cyber Knife",
    "Ice Glacier Dagger",
    "Midnight Dark Knife",
    "Lightsaber (Neon Beam)",
    "Default"
}

local GunModelNames = {
    "Golden Luger",
    "Sci-Fi Laser Revolver",
    "Phaser (Plasma Gun)",
    "Chroma Luger (Animated RGB)",
    "Sheriff .45 Revolver",
    "Darkbringer Style (Void Glow)",
    "Lightbringer Style (Holy Glow)",
    "Default"
}

local OriginalWeaponData = {}

local function BackupWeapon(tool)
    if not tool or OriginalWeaponData[tool] then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
    OriginalWeaponData[tool] = {
        MeshId = mesh and mesh.MeshId or "",
        TextureId = mesh and mesh.TextureId or "",
        Scale = mesh and mesh.Scale or Vector3.new(1, 1, 1),
        Offset = mesh and mesh.Offset or Vector3.new(0, 0, 0),
        VertexColor = mesh and mesh.VertexColor or Vector3.new(1, 1, 1),
        Color = handle.Color,
        Material = handle.Material,
        Transparency = handle.Transparency
    }
end

local function RestoreWeapon(tool)
    if not tool then return end
    local customVisual = tool:FindFirstChild("MM2_WeaponVisual")
    if customVisual then customVisual:Destroy() end
    local customModel = tool:FindFirstChild("CustomWeaponModel")
    if customModel then customModel:Destroy() end
    
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    local aura = handle:FindFirstChild("MM2_WeaponAura")
    if aura then aura:Destroy() end
    local trail = handle:FindFirstChild("MM2_WeaponTrail")
    if trail then trail:Destroy() end
    local a0 = handle:FindFirstChild("MM2_TrailAtt0")
    if a0 then a0:Destroy() end
    local a1 = handle:FindFirstChild("MM2_TrailAtt1")
    if a1 then a1:Destroy() end
    
    local data = OriginalWeaponData[tool]
    if data then
        handle.Transparency = data.Transparency or 0
        handle.Color = data.Color
        handle.Material = data.Material
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            mesh.MeshId = data.MeshId
            mesh.TextureId = data.TextureId
            mesh.Scale = data.Scale
            mesh.Offset = data.Offset
            mesh.VertexColor = data.VertexColor
        end
    else
        handle.Transparency = 0
    end
    for _, ch in ipairs(handle:GetChildren()) do
        if ch:IsA("Decal") then ch.Transparency = 0 end
    end
end

local function ApplyWeaponFX(tool, isKnife, emitterPart)
    if not emitterPart then return end
    
    -- 1. Aura Particle Emitter
    local existingAura = emitterPart:FindFirstChild("MM2_WeaponAura")
    if _G.CustomWeaponAura ~= "None" then
        if not existingAura then
            existingAura = Instance.new("ParticleEmitter")
            existingAura.Name = "MM2_WeaponAura"
            existingAura.Parent = emitterPart
        end
        existingAura.LightEmission = 0.95
        existingAura.LightInfluence = 0
        existingAura.Drag = 1
        
        if _G.CustomWeaponAura == "Fire Flames" then
            existingAura.Texture = "rbxassetid://243098098"
            existingAura.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 80)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 20)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 20, 20))
            })
            existingAura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.05)})
            existingAura.Rate = 28
            existingAura.Speed = NumberRange.new(1.0, 2.0)
            existingAura.Lifetime = NumberRange.new(0.4, 0.7)
            existingAura.SpreadAngle = Vector2.new(35, 35)
        elseif _G.CustomWeaponAura == "Void Smoke" then
            existingAura.Texture = "rbxassetid://243098098"
            existingAura.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 5, 80))
            })
            existingAura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0.1)})
            existingAura.Rate = 22
            existingAura.Speed = NumberRange.new(0.8, 1.5)
            existingAura.Lifetime = NumberRange.new(0.5, 0.8)
            existingAura.SpreadAngle = Vector2.new(45, 45)
        elseif _G.CustomWeaponAura == "Cyber Sparks" then
            existingAura.Texture = "rbxassetid://258129523"
            existingAura.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
            })
            existingAura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 0.02)})
            existingAura.Rate = 35
            existingAura.Speed = NumberRange.new(2.0, 4.0)
            existingAura.Lifetime = NumberRange.new(0.3, 0.5)
            existingAura.SpreadAngle = Vector2.new(180, 180)
        elseif _G.CustomWeaponAura == "Golden Haze" then
            existingAura.Texture = "rbxassetid://258129523"
            existingAura.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 100)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 0))
            })
            existingAura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0.05)})
            existingAura.Rate = 25
            existingAura.Speed = NumberRange.new(1.0, 2.5)
            existingAura.Lifetime = NumberRange.new(0.4, 0.6)
            existingAura.SpreadAngle = Vector2.new(60, 60)
        elseif _G.CustomWeaponAura == "Blood Drip" then
            existingAura.Texture = "rbxassetid://243098098"
            existingAura.Color = ColorSequence.new(Color3.fromRGB(220, 20, 30))
            existingAura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0.05)})
            existingAura.Rate = 22
            existingAura.Speed = NumberRange.new(0.5, 1.2)
            existingAura.Lifetime = NumberRange.new(0.4, 0.7)
            existingAura.Acceleration = Vector3.new(0, -9, 0)
        end
    else
        if existingAura then existingAura:Destroy() end
    end
    
    -- 2. Blade Trail (for Knife)
    if isKnife then
        local existingTrail = emitterPart:FindFirstChild("MM2_WeaponTrail")
        if _G.WeaponTrailActive then
            local att0 = emitterPart:FindFirstChild("MM2_TrailAtt0")
            local att1 = emitterPart:FindFirstChild("MM2_TrailAtt1")
            if not att0 then
                att0 = Instance.new("Attachment")
                att0.Name = "MM2_TrailAtt0"
                att0.Position = Vector3.new(0, 1.2, 0)
                att0.Parent = emitterPart
            end
            if not att1 then
                att1 = Instance.new("Attachment")
                att1.Name = "MM2_TrailAtt1"
                att1.Position = Vector3.new(0, -0.6, 0)
                att1.Parent = emitterPart
            end
            if not existingTrail then
                existingTrail = Instance.new("Trail")
                existingTrail.Name = "MM2_WeaponTrail"
                existingTrail.Attachment0 = att0
                existingTrail.Attachment1 = att1
                existingTrail.FaceCamera = true
                existingTrail.LightEmission = 0.85
                existingTrail.WidthScale = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                })
                existingTrail.Parent = emitterPart
            end
            existingTrail.Lifetime = 0.35
            local trailCol = Color3.fromRGB(255, 255, 255)
            if _G.SelectedWeaponTrailColor == "Rainbow RGB" then
                trailCol = _G.RainbowColor
            elseif ChamColorPresets[_G.SelectedWeaponTrailColor] then
                trailCol = ChamColorPresets[_G.SelectedWeaponTrailColor]
            end
            existingTrail.Color = ColorSequence.new(trailCol)
        else
            if existingTrail then existingTrail:Destroy() end
            local a0 = emitterPart:FindFirstChild("MM2_TrailAtt0")
            if a0 then a0:Destroy() end
            local a1 = emitterPart:FindFirstChild("MM2_TrailAtt1")
            if a1 then a1:Destroy() end
        end
    end
end

local function ApplyCustomKnife(tool)
    if not tool or not _G.CustomKnifeActive then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    BackupWeapon(tool)
    
    local preset = KnifePresets[_G.SelectedKnifeModel]
    if not preset then
        RestoreWeapon(tool)
        return
    end
    
    -- Special 3D Lightsaber
    if preset.IsSpecial3D == "Lightsaber" then
        handle.Transparency = 1
        local old = tool:FindFirstChild("CustomWeaponModel")
        if old then old:Destroy() end
        local oldVis = tool:FindFirstChild("MM2_WeaponVisual")
        if oldVis then oldVis:Destroy() end
        
        local model = Instance.new("Model")
        model.Name = "CustomWeaponModel"
        
        local hilt = Instance.new("Part")
        hilt.Name = "Hilt"
        hilt.Size = Vector3.new(0.25, 0.9, 0.25)
        hilt.Material = Enum.Material.Metal
        hilt.Color = Color3.fromRGB(45, 45, 45)
        hilt.CanCollide = false
        hilt.CanTouch = false
        hilt.CanQuery = false
        hilt.Massless = true
        hilt.CFrame = handle.CFrame
        hilt.Parent = model
        
        local blade = Instance.new("Part")
        blade.Name = "Blade"
        blade.Shape = Enum.PartType.Cylinder
        blade.Size = Vector3.new(3.0, 0.22, 0.22)
        blade.Material = Enum.Material.Neon
        local bladeColor = preset.Color
        if _G.CustomWeaponColor ~= "Original" and ChamColorPresets[_G.CustomWeaponColor] then
            bladeColor = ChamColorPresets[_G.CustomWeaponColor]
        end
        blade.Color = bladeColor
        blade.CanCollide = false
        blade.CanTouch = false
        blade.CanQuery = false
        blade.Massless = true
        blade.CFrame = handle.CFrame * CFrame.new(0, 1.6, 0) * CFrame.Angles(0, 0, math.rad(90))
        blade.Parent = model
        
        local w1 = Instance.new("WeldConstraint")
        w1.Part0 = handle
        w1.Part1 = hilt
        w1.Parent = hilt
        
        local w2 = Instance.new("WeldConstraint")
        w2.Part0 = hilt
        w2.Part1 = blade
        w2.Parent = blade
        
        model.Parent = tool
        ApplyWeaponFX(tool, true, blade)
        return
    end
    
    -- Clean up any 3D model
    local oldModel = tool:FindFirstChild("CustomWeaponModel")
    if oldModel then oldModel:Destroy() end
    local oldVis = tool:FindFirstChild("MM2_WeaponVisual")
    if oldVis then oldVis:Destroy() end
    
    -- Native MM2 Handle SpecialMesh transformation (Zero Raycast Interception, 100% Attack Function)
    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
    if not mesh then
        mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.Parent = handle
    end
    
    mesh.MeshId = preset.MeshId
    mesh.TextureId = preset.TextureId or ""
    mesh.Scale = preset.Scale or Vector3.new(1, 1, 1)
    mesh.Offset = preset.Offset or Vector3.new(0, 0, 0)
    handle.Transparency = 0
    
    -- Material override
    if _G.CustomWeaponMaterial ~= "Default" then
        if _G.CustomWeaponMaterial == "Neon Glow" then handle.Material = Enum.Material.Neon
        elseif _G.CustomWeaponMaterial == "ForceField" then handle.Material = Enum.Material.ForceField
        elseif _G.CustomWeaponMaterial == "Glass" then handle.Material = Enum.Material.Glass
        elseif _G.CustomWeaponMaterial == "Chrome Metal" then handle.Material = Enum.Material.Metal end
    elseif preset.Material then
        handle.Material = preset.Material
    else
        handle.Material = Enum.Material.Plastic
    end
    
    -- Color
    if _G.CustomWeaponColor ~= "Original" then
        if _G.CustomWeaponColor == "Rainbow RGB" then
            handle.Color = _G.RainbowColor
            mesh.VertexColor = Vector3.new(_G.RainbowColor.R, _G.RainbowColor.G, _G.RainbowColor.B)
        elseif ChamColorPresets[_G.CustomWeaponColor] then
            local col = ChamColorPresets[_G.CustomWeaponColor]
            handle.Color = col
            mesh.VertexColor = Vector3.new(col.R, col.G, col.B)
        end
    elseif preset.IsChroma then
        handle.Color = _G.RainbowColor
        mesh.VertexColor = Vector3.new(_G.RainbowColor.R, _G.RainbowColor.G, _G.RainbowColor.B)
    elseif preset.Color then
        handle.Color = preset.Color
        mesh.VertexColor = Vector3.new(preset.Color.R, preset.Color.G, preset.Color.B)
    else
        handle.Color = Color3.fromRGB(255, 255, 255)
        mesh.VertexColor = Vector3.new(1, 1, 1)
    end
    
    ApplyWeaponFX(tool, true, handle)
end

local function ApplyCustomGun(tool)
    if not tool or not _G.CustomGunActive then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    BackupWeapon(tool)
    
    local preset = GunPresets[_G.SelectedGunModel]
    if not preset then
        RestoreWeapon(tool)
        return
    end
    
    -- Clean up any 3D model
    local oldModel = tool:FindFirstChild("CustomWeaponModel")
    if oldModel then oldModel:Destroy() end
    local oldVis = tool:FindFirstChild("MM2_WeaponVisual")
    if oldVis then oldVis:Destroy() end
    
    -- Native MM2 Handle SpecialMesh transformation (Zero Raycast Interception, 100% Shooting Function)
    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
    if not mesh then
        mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.Parent = handle
    end
    
    mesh.MeshId = preset.MeshId
    mesh.TextureId = preset.TextureId or ""
    mesh.Scale = preset.Scale or Vector3.new(1, 1, 1)
    mesh.Offset = preset.Offset or Vector3.new(0, 0, 0)
    handle.Transparency = 0
    
    -- Material override
    if _G.CustomWeaponMaterial ~= "Default" then
        if _G.CustomWeaponMaterial == "Neon Glow" then handle.Material = Enum.Material.Neon
        elseif _G.CustomWeaponMaterial == "ForceField" then handle.Material = Enum.Material.ForceField
        elseif _G.CustomWeaponMaterial == "Glass" then handle.Material = Enum.Material.Glass
        elseif _G.CustomWeaponMaterial == "Chrome Metal" then handle.Material = Enum.Material.Metal end
    elseif preset.Material then
        handle.Material = preset.Material
    else
        handle.Material = Enum.Material.Plastic
    end
    
    -- Color
    if _G.CustomWeaponColor ~= "Original" then
        if _G.CustomWeaponColor == "Rainbow RGB" then
            handle.Color = _G.RainbowColor
            mesh.VertexColor = Vector3.new(_G.RainbowColor.R, _G.RainbowColor.G, _G.RainbowColor.B)
        elseif ChamColorPresets[_G.CustomWeaponColor] then
            local col = ChamColorPresets[_G.CustomWeaponColor]
            handle.Color = col
            mesh.VertexColor = Vector3.new(col.R, col.G, col.B)
        end
    elseif preset.IsChroma then
        handle.Color = _G.RainbowColor
        mesh.VertexColor = Vector3.new(_G.RainbowColor.R, _G.RainbowColor.G, _G.RainbowColor.B)
    elseif preset.Color then
        handle.Color = preset.Color
        mesh.VertexColor = Vector3.new(preset.Color.R, preset.Color.G, preset.Color.B)
    else
        handle.Color = Color3.fromRGB(255, 255, 255)
        mesh.VertexColor = Vector3.new(1, 1, 1)
    end
    
    ApplyWeaponFX(tool, false, handle)
end

local function GetPlayerKnife()
    local char = LocalPlayer.Character
    local bpack = LocalPlayer:FindFirstChild("Backpack")
    local candidates = {}
    if char then
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then table.insert(candidates, obj) end
        end
    end
    if bpack then
        for _, obj in ipairs(bpack:GetChildren()) do
            if obj:IsA("Tool") then table.insert(candidates, obj) end
        end
    end
    for _, tool in ipairs(candidates) do
        local n = tool.Name:lower()
        if n == "knife" or n:find("knife") or tool:FindFirstChild("KnifeServer") or tool:FindFirstChild("Stab") then
            return tool
        end
    end
    return nil
end

local function GetPlayerGun()
    local char = LocalPlayer.Character
    local bpack = LocalPlayer:FindFirstChild("Backpack")
    local candidates = {}
    if char then
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then table.insert(candidates, obj) end
        end
    end
    if bpack then
        for _, obj in ipairs(bpack:GetChildren()) do
            if obj:IsA("Tool") then table.insert(candidates, obj) end
        end
    end
    for _, tool in ipairs(candidates) do
        local n = tool.Name:lower()
        if n == "gun" or n == "revolver" or n:find("gun") or n:find("revolver") or tool:FindFirstChild("GunServer") or tool:FindFirstChild("Shoot") then
            return tool
        end
    end
    return nil
end

local function UpdateCustomWeapons()
    local knife = GetPlayerKnife()
    if knife then
        if _G.CustomKnifeActive then
            ApplyCustomKnife(knife)
        else
            RestoreWeapon(knife)
        end
    end
    
    local gun = GetPlayerGun()
    if gun then
        if _G.CustomGunActive then
            ApplyCustomGun(gun)
        else
            RestoreWeapon(gun)
        end
    end
end

-- Periodically maintain weapon skins & effects
task.spawn(function()
    while true do
        task.wait(0.2)
        if _G.CustomKnifeActive or _G.CustomGunActive then
            UpdateCustomWeapons()
        end
    end
end)

local function HookBackpackAndChar()
    local bpack = LocalPlayer:FindFirstChild("Backpack")
    if bpack then
        bpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and (_G.CustomKnifeActive or _G.CustomGunActive) then
                task.wait(0.1)
                UpdateCustomWeapons()
            end
        end)
    end
    if LocalPlayer.Character then
        LocalPlayer.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and (_G.CustomKnifeActive or _G.CustomGunActive) then
                task.wait(0.1)
                UpdateCustomWeapons()
            end
        end)
    end
end

HookBackpackAndChar()
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    HookBackpackAndChar()
    if _G.CustomKnifeActive or _G.CustomGunActive then
        UpdateCustomWeapons()
    end
end)

------------------------------------------------------------------------
-- WORLD, WEATHER, FOG & SKYBOX VISUALS ENGINE
------------------------------------------------------------------------
local OriginalLighting = {
    FogColor = Lighting.FogColor,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ExposureCompensation = Lighting.ExposureCompensation,
    GlobalShadows = Lighting.GlobalShadows,
    FieldOfView = Camera.FieldOfView
}

local FogColorPresets = {
    ["Blood Red"]      = Color3.fromRGB(220, 20, 30),
    ["Purple Night"]   = Color3.fromRGB(135, 30, 220),
    ["Cyber Cyan"]     = Color3.fromRGB(20, 210, 245),
    ["Midnight Black"] = Color3.fromRGB(8, 8, 12),
    ["Neon Green"]     = Color3.fromRGB(30, 240, 80),
    ["Toxic Orange"]   = Color3.fromRGB(255, 110, 20),
    ["Deep Violet"]    = Color3.fromRGB(75, 15, 130),
    ["Pure White"]     = Color3.fromRGB(245, 245, 255)
}

local SkyPresets = {
    ["Purple Galaxy"] = {
        Bk = "rbxassetid://159454299",
        Dn = "rbxassetid://159454296",
        Ft = "rbxassetid://159454293",
        Lf = "rbxassetid://159454286",
        Rt = "rbxassetid://159454300",
        Up = "rbxassetid://159454288"
    },
    ["Red Blood Moon"] = {
        Bk = "rbxassetid://401664839",
        Dn = "rbxassetid://401664862",
        Ft = "rbxassetid://401664960",
        Lf = "rbxassetid://401664881",
        Rt = "rbxassetid://401664901",
        Up = "rbxassetid://401664936"
    },
    ["Cyberpunk City"] = {
        Bk = "rbxassetid://271042516",
        Dn = "rbxassetid://271077243",
        Ft = "rbxassetid://271042556",
        Lf = "rbxassetid://271042310",
        Rt = "rbxassetid://271042467",
        Up = "rbxassetid://271077958"
    },
    ["Dark Space"] = {
        Bk = "rbxassetid://600830446",
        Dn = "rbxassetid://600831635",
        Ft = "rbxassetid://600832720",
        Lf = "rbxassetid://600886090",
        Rt = "rbxassetid://600833862",
        Up = "rbxassetid://600835177"
    },
    ["Pure Void (Black)"] = {
        Bk = "rbxassetid://1544482705",
        Dn = "rbxassetid://1544482705",
        Ft = "rbxassetid://1544482705",
        Lf = "rbxassetid://1544482705",
        Rt = "rbxassetid://1544482705",
        Up = "rbxassetid://1544482705"
    }
}

local AmbientPresets = {
    ["Blood Red"]       = Color3.fromRGB(160, 20, 30),
    ["Purple Twilight"] = Color3.fromRGB(120, 30, 190),
    ["Cold Cyan"]       = Color3.fromRGB(30, 130, 170),
    ["Night Warm"]      = Color3.fromRGB(150, 95, 45),
    ["Pure White"]      = Color3.fromRGB(255, 255, 255)
}

-- 1. НАДЕЖНАЯ СИСТЕМА КАСТОМНОГО СКАЙБОКСА (Удаляет родной Sky и обнуляет плотность Atmosphere)
local BackupOriginalSky = nil
local CustomSkyInstance = nil

local function ApplySkyPreset(presetName)
    local preset = SkyPresets[presetName]
    if not preset then return end
    
    -- Бэкапим и удаляем все остальные Sky в Lighting
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") and child.Name ~= "Umbrella_CustomSky" then
            if not BackupOriginalSky then
                pcall(function() BackupOriginalSky = child:Clone() end)
            end
            child:Destroy()
        end
    end
    
    -- Обнуляем плотность и дымку Atmosphere (Atmosphere скрывает Skybox в MM2)
    for _, atmo in ipairs(Lighting:GetChildren()) do
        if atmo:IsA("Atmosphere") then
            atmo.Density = 0
            atmo.Haze = 0
            atmo.Glare = 0
        end
    end
    
    -- Отключаем облака если есть
    pcall(function()
        local clouds = workspace:FindFirstChildOfClass("Clouds") or (workspace.Terrain and workspace.Terrain:FindFirstChildOfClass("Clouds"))
        if clouds then clouds.Enabled = false end
    end)
    
    local sky = Lighting:FindFirstChild("Umbrella_CustomSky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "Umbrella_CustomSky"
        sky.Parent = Lighting
    end
    
    sky.SkyboxBk = preset.Bk
    sky.SkyboxDn = preset.Dn
    sky.SkyboxFt = preset.Ft
    sky.SkyboxLf = preset.Lf
    sky.SkyboxRt = preset.Rt
    sky.SkyboxUp = preset.Up
    sky.CelestialBodiesShown = false
    sky.StarCount = 3000
    sky.SunAngularSize = 0
    sky.MoonAngularSize = 0
    
    CustomSkyInstance = sky
end

local function RemoveSkyPreset()
    if CustomSkyInstance then
        CustomSkyInstance:Destroy()
        CustomSkyInstance = nil
    end
    for _, child in ipairs(Lighting:GetChildren()) do
        if child.Name == "Umbrella_CustomSky" then child:Destroy() end
    end
    if BackupOriginalSky then
        pcall(function() BackupOriginalSky:Clone().Parent = Lighting end)
    end
    for _, atmo in ipairs(Lighting:GetChildren()) do
        if atmo:IsA("Atmosphere") then
            atmo.Density = 0.3
        end
    end
end

-- Авто-защита от сброса неба картой MM2
Lighting.ChildAdded:Connect(function(child)
    if _G.CustomSkyActive and child:IsA("Sky") and child.Name ~= "Umbrella_CustomSky" then
        task.wait()
        child:Destroy()
        ApplySkyPreset(_G.SelectedSkyPreset)
    end
end)

-- 2. HVH КИТАЙСКАЯ ШАПКА (CHINESE HAT), ШЛЕЙФЫ (BODY & ROPE TRAIL) И ЗВУКИ ШАГОВ
local RopeColorPresets = {
    ["Blood Red"]      = Color3.fromRGB(220, 25, 35),
    ["Purple HvH"]     = Color3.fromRGB(160, 30, 240),
    ["Cyber Cyan"]     = Color3.fromRGB(20, 220, 255),
    ["Electric Green"] = Color3.fromRGB(40, 255, 90),
    ["Pure White"]     = Color3.fromRGB(255, 255, 255),
    ["Gold Glow"]      = Color3.fromRGB(255, 215, 0)
}

-- 1. КИТАЙСКАЯ ШАПКА (CHINESE HAT / ASIAN CONICAL HAT)
local ChineseHatPart = nil
local hatRotationAngle = 0

local function RemoveChineseHat()
    if ChineseHatPart then ChineseHatPart:Destroy() ChineseHatPart = nil end
    if LocalPlayer.Character then
        for _, obj in ipairs(LocalPlayer.Character:GetDescendants()) do
            if obj.Name == "Umbrella_ChineseHat" or obj.Name == "Umbrella_HatWeld" then
                obj:Destroy()
            end
        end
    end
end

local function ApplyChineseHat()
    RemoveChineseHat()
    if not _G.ChineseHatActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    ChineseHatPart = Instance.new("Part")
    ChineseHatPart.Name = "Umbrella_ChineseHat"
    ChineseHatPart.CanCollide = false
    ChineseHatPart.CanTouch = false
    ChineseHatPart.CanQuery = false
    ChineseHatPart.CastShadow = false
    ChineseHatPart.Anchored = false
    ChineseHatPart.Material = Enum.Material.Neon
    ChineseHatPart.Size = Vector3.new(3, 0.8, 3)
    ChineseHatPart.Transparency = 0.1
    
    local col = RopeColorPresets[_G.SelectedHatColor] or Color3.fromRGB(220, 25, 35)
    ChineseHatPart.Color = col
    
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    local s = _G.HatScale or 1.2
    mesh.Scale = Vector3.new(s * 1.35, s * 0.95, s * 1.35)
    mesh.Parent = ChineseHatPart
    
    local glow = Instance.new("Highlight")
    glow.Name = "HatGlow"
    glow.FillTransparency = 0.55
    glow.FillColor = col
    glow.OutlineColor = Color3.fromRGB(255, 255, 255)
    glow.OutlineTransparency = 0.2
    glow.Adornee = ChineseHatPart
    glow.Parent = ChineseHatPart
    
    ChineseHatPart.CFrame = head.CFrame * CFrame.new(0, _G.HatHeight or 1.15, 0)
    ChineseHatPart.Parent = char
    
    local weld = Instance.new("Weld")
    weld.Name = "Umbrella_HatWeld"
    weld.Part0 = head
    weld.Part1 = ChineseHatPart
    weld.C0 = CFrame.new(0, _G.HatHeight or 1.15, 0)
    weld.Parent = ChineseHatPart
end

-- 2. ВЕРЕВОЧКА ИЗ-ПОД НОГ (FOOT ROPE TRAIL ПО ЗЕМЛЕ)
local FootRopeTrail = nil
local FootRopeAtt0 = nil
local FootRopeAtt1 = nil

local function RemoveFootRope()
    if FootRopeTrail then FootRopeTrail:Destroy() FootRopeTrail = nil end
    if FootRopeAtt0 then FootRopeAtt0:Destroy() FootRopeAtt0 = nil end
    if FootRopeAtt1 then FootRopeAtt1:Destroy() FootRopeAtt1 = nil end
    if LocalPlayer.Character then
        for _, obj in ipairs(LocalPlayer.Character:GetDescendants()) do
            if obj.Name == "Umbrella_FootRope" or obj.Name == "Umbrella_RopeAtt0" or obj.Name == "Umbrella_RopeAtt1" then
                obj:Destroy()
            end
        end
    end
end

local function ApplyFootRope()
    RemoveFootRope()
    if not _G.FootRopeActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    FootRopeAtt0 = Instance.new("Attachment")
    FootRopeAtt0.Name = "Umbrella_RopeAtt0"
    FootRopeAtt0.Position = Vector3.new(-0.25, -2.95, 0)
    FootRopeAtt0.Parent = hrp
    
    FootRopeAtt1 = Instance.new("Attachment")
    FootRopeAtt1.Name = "Umbrella_RopeAtt1"
    FootRopeAtt1.Position = Vector3.new(0.25, -2.95, 0)
    FootRopeAtt1.Parent = hrp
    
    FootRopeTrail = Instance.new("Trail")
    FootRopeTrail.Name = "Umbrella_FootRope"
    FootRopeTrail.Attachment0 = FootRopeAtt0
    FootRopeTrail.Attachment1 = FootRopeAtt1
    FootRopeTrail.Lifetime = _G.RopeLifetime or 0.9
    FootRopeTrail.MinLength = 0.04
    FootRopeTrail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, _G.RopeWidth or 0.35),
        NumberSequenceKeypoint.new(1, 0.02)
    })
    
    local col = RopeColorPresets[_G.SelectedRopeColor] or Color3.fromRGB(220, 25, 35)
    FootRopeTrail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, col),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(math.floor(col.R * 80), math.floor(col.G * 80), math.floor(col.B * 80)))
    })
    FootRopeTrail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),
        NumberSequenceKeypoint.new(0.8, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    FootRopeTrail.LightEmission = 0.95
    FootRopeTrail.FaceCamera = true
    FootRopeTrail.Parent = hrp
end

-- 3. НЕОНОВЫЙ ТРЕЙЛ ЗА ТЕЛОМ (BODY NEON TRAIL)
local CharacterTrail = nil
local TrailAtt0 = nil
local TrailAtt1 = nil

local function RemoveCharacterTrail()
    if CharacterTrail then CharacterTrail:Destroy() CharacterTrail = nil end
    if TrailAtt0 then TrailAtt0:Destroy() TrailAtt0 = nil end
    if TrailAtt1 then TrailAtt1:Destroy() TrailAtt1 = nil end
    if LocalPlayer.Character then
        for _, obj in ipairs(LocalPlayer.Character:GetDescendants()) do
            if obj.Name == "Umbrella_Trail" or obj.Name == "Umbrella_TrailAtt0" or obj.Name == "Umbrella_TrailAtt1" then
                obj:Destroy()
            end
        end
    end
end

local function ApplyCharacterTrail()
    RemoveCharacterTrail()
    if not _G.PlayerTrailActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    TrailAtt0 = Instance.new("Attachment")
    TrailAtt0.Name = "Umbrella_TrailAtt0"
    TrailAtt0.Position = Vector3.new(0, 0.9, 0)
    TrailAtt0.Parent = hrp
    
    TrailAtt1 = Instance.new("Attachment")
    TrailAtt1.Name = "Umbrella_TrailAtt1"
    TrailAtt1.Position = Vector3.new(0, -1.3, 0)
    TrailAtt1.Parent = hrp
    
    CharacterTrail = Instance.new("Trail")
    CharacterTrail.Name = "Umbrella_Trail"
    CharacterTrail.Attachment0 = TrailAtt0
    CharacterTrail.Attachment1 = TrailAtt1
    CharacterTrail.Lifetime = _G.TrailLifetime or 0.6
    CharacterTrail.MinLength = 0.04
    CharacterTrail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.3),
        NumberSequenceKeypoint.new(0.5, 0.85),
        NumberSequenceKeypoint.new(1, 0.04)
    })
    
    local col = RopeColorPresets[_G.SelectedTrailColor] or Color3.fromRGB(220, 25, 35)
    CharacterTrail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, col),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(math.floor(col.R * 60), math.floor(col.G * 60), math.floor(col.B * 60)))
    })
    CharacterTrail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.8, 0.35),
        NumberSequenceKeypoint.new(1, 1)
    })
    CharacterTrail.LightEmission = 1.0
    CharacterTrail.FaceCamera = true
    CharacterTrail.Parent = hrp
end

-- 4. КАСТОМНЫЕ ЗВУКИ ШАГОВ (CUSTOM FOOTSTEP SOUNDS)
local FootstepAssets = {
    ["Minecraft Stone"]      = "rbxassetid://9117824839",
    ["Concrete Combat Boot"] = "rbxassetid://131070686",
    ["High Heels Click"]     = "rbxassetid://6357119106",
    ["Anime Bubble Pop"]     = "rbxassetid://6534947588",
    ["Squeaky Meme Toy"]     = "rbxassetid://9069609200"
}

local lastStepTime = 0
local function ProcessCustomFootsteps()
    if not _G.CustomFootstepsActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    
    -- Глушим стандартный звук шагов
    local defaultRun = hrp:FindFirstChild("Running")
    if defaultRun and defaultRun:IsA("Sound") then
        defaultRun.Volume = 0
    end
    
    if hum.MoveDirection.Magnitude > 0.1 and hum.FloorMaterial ~= Enum.Material.Air then
        local stepInterval = math.clamp(0.36 * (16 / math.max(hum.WalkSpeed, 10)), 0.12, 0.45)
        local now = tick()
        if now - lastStepTime >= stepInterval then
            lastStepTime = now
            local assetId = FootstepAssets[_G.SelectedFootstep] or FootstepAssets["Minecraft Stone"]
            local s = Instance.new("Sound")
            s.SoundId = assetId
            s.Volume = math.clamp((_G.FootstepsVolume or 4) * 0.25, 0.1, 5)
            s.Pitch = math.random(95, 105) / 100
            s.Parent = SoundService
            s:Play()
            s.Ended:Connect(function() s:Destroy() end)
            task.delay(1.5, function() if s and s.Parent then s:Destroy() end end)
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if _G.ChineseHatActive then ApplyChineseHat() end
    if _G.FootRopeActive then ApplyFootRope() end
    if _G.PlayerTrailActive then ApplyCharacterTrail() end
end)

-- Вспышка экрана при попадании (Screen Flash)
local FlashFrame = Instance.new("Frame")
FlashFrame.Name = "Umbrella_Flash"
FlashFrame.Parent = ScreenGui
FlashFrame.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
FlashFrame.BackgroundTransparency = 1
FlashFrame.Size = UDim2.new(1, 0, 1, 0)
FlashFrame.ZIndex = 1

local function TriggerScreenFlash()
    if not _G.KillFlashActive then return end
    FlashFrame.BackgroundTransparency = 0.75
    task.spawn(function()
        for i = 1, 6 do
            task.wait(0.02)
            FlashFrame.BackgroundTransparency = 0.75 + (0.25 * (i / 6))
        end
        FlashFrame.BackgroundTransparency = 1
    end)
end

-- 3. ПОСТОБРАБОТКА (COLOR CORRECTION & BLUR)
local ColorCorrectionInstance = nil
local function UpdateColorCorrection()
    if _G.ColorCorrectionActive then
        if not ColorCorrectionInstance or not ColorCorrectionInstance.Parent then
            ColorCorrectionInstance = Lighting:FindFirstChild("Umbrella_ColorCorrection")
            if not ColorCorrectionInstance then
                ColorCorrectionInstance = Instance.new("ColorCorrectionEffect")
                ColorCorrectionInstance.Name = "Umbrella_ColorCorrection"
                ColorCorrectionInstance.Parent = Lighting
            end
        end
        ColorCorrectionInstance.Saturation = _G.SaturationBoost
        ColorCorrectionInstance.Contrast = _G.ContrastBoost
    else
        if ColorCorrectionInstance then
            ColorCorrectionInstance:Destroy()
            ColorCorrectionInstance = nil
        end
        local existing = Lighting:FindFirstChild("Umbrella_ColorCorrection")
        if existing then existing:Destroy() end
    end
end

local BlurInstance = nil
local function UpdateBlur()
    if _G.BlurActive then
        if not BlurInstance or not BlurInstance.Parent then
            BlurInstance = Lighting:FindFirstChild("Umbrella_Blur")
            if not BlurInstance then
                BlurInstance = Instance.new("BlurEffect")
                BlurInstance.Name = "Umbrella_Blur"
                BlurInstance.Parent = Lighting
            end
        end
        BlurInstance.Size = _G.BlurSize
    else
        if BlurInstance then
            BlurInstance:Destroy()
            BlurInstance = nil
        end
        local existing = Lighting:FindFirstChild("Umbrella_Blur")
        if existing then existing:Destroy() end
    end
end

-- РЕНДЕР ЦИКЛ ОСВЕЩЕНИЯ, ТУМАНА, ПОГОДЫ И FOV
RunService.RenderStepped:Connect(function()
    -- Туман
    if _G.FogColorActive then
        Lighting.FogColor = FogColorPresets[_G.SelectedFogColor] or Color3.fromRGB(220, 20, 30)
        Lighting.FogStart = _G.FogStart
        Lighting.FogEnd = _G.FogEnd
    end
    
    -- Время суток
    if _G.TimeOfDayActive then
        Lighting.ClockTime = _G.TimeOfDayValue
    end
    
    -- Окружающий свет
    if _G.AmbientActive then
        local col = AmbientPresets[_G.SelectedAmbient] or Color3.fromRGB(160, 20, 30)
        Lighting.Ambient = col
        Lighting.OutdoorAmbient = col
    end
    
    -- Fullbright
    if _G.FullbrightActive then
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    end
    
    -- Кастомный FOV камеры
        -- Кастомный FOV камеры
        -- Кастомный FOV камеры
    if _G.CustomFOVActive then
        Camera.FieldOfView = _G.CustomFOVValue
    end
    
    -- Вращение и радужный цвет китайской шапки (Chinese Hat Rotation & RGB)
    if _G.ChineseHatActive and ChineseHatPart and ChineseHatPart.Parent then
        local char = LocalPlayer.Character
        local head = char and char:FindFirstChild("Head")
        if head then
            local weld = ChineseHatPart:FindFirstChild("Umbrella_HatWeld")
            if weld then
                if _G.HatSpinActive then
                    hatRotationAngle = (hatRotationAngle + (180 * (1/60))) % 360
                    weld.C0 = CFrame.new(0, _G.HatHeight or 1.15, 0) * CFrame.Angles(0, math.rad(hatRotationAngle), 0)
                else
                    weld.C0 = CFrame.new(0, _G.HatHeight or 1.15, 0)
                end
            end
            
            if _G.SelectedHatColor == "Rainbow RGB" then
                local hue = (tick() * 0.5) % 1
                local rgbCol = Color3.fromHSV(hue, 1, 1)
                ChineseHatPart.Color = rgbCol
                local glow = ChineseHatPart:FindFirstChild("HatGlow")
                if glow then glow.FillColor = rgbCol end
            end
        end
    end
    
    -- Радужный цикл для веревочки из-под ног (Rainbow RGB)
    if _G.FootRopeActive and FootRopeTrail and FootRopeTrail.Parent and _G.SelectedRopeColor == "Rainbow RGB" then
        local hue = (tick() * 0.6) % 1
        local rgbCol = Color3.fromHSV(hue, 1, 1)
        FootRopeTrail.Color = ColorSequence.new(rgbCol)
    end
    
    -- Радужный цикл для неона за телом (Body Trail RGB)
    if _G.PlayerTrailActive and CharacterTrail and CharacterTrail.Parent and _G.SelectedTrailColor == "Rainbow RGB" then
        local hue = (tick() * 0.6) % 1
        local rgbCol = Color3.fromHSV(hue, 1, 1)
        CharacterTrail.Color = ColorSequence.new(rgbCol)
    end
    
    -- Обработка звуков шагов
    ProcessCustomFootsteps()
end)

-- 1. MAIN TAB
local SecMovement = CreateSection(Tabs["Main"], "Movement Mods")
CreateToggle(SecMovement, "Speedhack", false, function(st) _G.SpeedActive = st end)
CreateSlider(SecMovement, "Walk Speed", _G.SpeedValue, 16, 150, false, function(val) _G.SpeedValue = val end)
CreateToggle(SecMovement, "Bhop (Auto Jump)", false, function(st) _G.BhopActive = st end)
CreateToggle(SecMovement, "Infinite Jump (Fly Air)", false, function(st) _G.InfiniteJumpActive = st end)
CreateToggle(SecMovement, "Spinbot", false, function(st) _G.SpinbotActive = st end)
CreateSlider(SecMovement, "Spin Speed", _G.SpinSpeed, 10, 100, false, function(val) _G.SpinSpeed = val end)
CreateToggle(SecMovement, "Noclip (Pass Wall)", false, function(st) _G.NoclipActive = st end)

local SecHvHMovement = CreateSection(Tabs["Main"], "HvH Advanced Movement")
CreateToggle(SecHvHMovement, "Auto-Strafe (Air Control)", false, function(st) _G.AutoStrafeActive = st end)
CreateToggle(SecHvHMovement, "Fly (Free 3D Flight)", false, function(st) _G.FlyActive = st end)
CreateSlider(SecHvHMovement, "Fly Speed", _G.FlySpeed, 15, 150, false, function(val) _G.FlySpeed = val end)
CreateToggle(SecHvHMovement, "Fast Stop (Instant Decel)", false, function(st) _G.FastStopActive = st end)
CreateToggle(SecHvHMovement, "High Jump Boost", false, function(st) _G.HighJumpActive = st end)
CreateSlider(SecHvHMovement, "Jump Boost Power", _G.JumpBoostPower, 50, 250, false, function(val) _G.JumpBoostPower = val end)
CreateToggle(SecHvHMovement, "Long Jump (Lunge Boost)", false, function(st) _G.LongJumpActive = st end)
CreateSlider(SecHvHMovement, "Long Jump Power", _G.LongJumpPower, 20, 120, false, function(val) _G.LongJumpPower = val end)

local SecUtility = CreateSection(Tabs["Main"], "Player Protection & Repel")
CreateToggle(SecUtility, "Anti-Fling", false, function(st) _G.AntiFlingActive = st end)
CreateToggle(SecUtility, "Auto Pickup Gun", false, function(st) _G.AutoPickupActive = st end)
CreateToggle(SecUtility, "Distance Pickup (No Teleport)", false, function(st) _G.PickupMode = st and "Distance" or "Teleport" end)
CreateToggle(SecUtility, "Murderer Repel Shield (Push Away)", false, function(st) _G.MurdererRepelActive = st end)

-- 2. VISUALS TAB
local SecESP = CreateSection(Tabs["Visuals"], "Player ESP & Weapon Chams")
CreateDropdown(SecESP, "Chams Style", {"Fill / Glow", "Boxes", "Outline Only"}, _G.ChamsStyle, function(val)
    _G.ChamsStyle = val
    ClearAllChams()
end)

CreateToggle(SecESP, "Player Chams (Role Colors)", false, function(st)
    _G.ChamsActive = st
    if not st then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                for _, obj in ipairs(player.Character:GetDescendants()) do
                    if obj.Name == "MM2_BoxCham" or obj.Name == "MM2_PlayerHighlight" then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end)

CreateToggle(SecESP, "Self Chams (Local & Custom Model)", false, function(st)
    _G.SelfChamsActive = st
    if not st and LocalPlayer.Character then
        for _, obj in ipairs(LocalPlayer.Character:GetDescendants()) do
            if obj.Name == "MM2_SelfCham" or obj.Name == "MM2_SelfHighlight" then
                obj:Destroy()
            end
        end
    end
end)

CreateDropdown(SecESP, "Self Chams Color", {"Neon Pink", "Blood Red", "Cyber Cyan", "Gold Glow", "Lime Green", "Electric Purple", "Rainbow RGB"}, _G.SelectedSelfChamColor, function(col)
    _G.SelectedSelfChamColor = col
    if LocalPlayer.Character then
        for _, obj in ipairs(LocalPlayer.Character:GetDescendants()) do
            if obj.Name == "MM2_SelfCham" or obj.Name == "MM2_SelfHighlight" then
                obj:Destroy()
            end
        end
    end
end)

CreateToggle(SecESP, "Weapon Chams (Held Knife & Gun)", false, function(st)
    _G.WeaponChamsActive = st
    if not st then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "MM2_WeaponCham" or obj.Name == "MM2_WeaponHighlight" then
                obj:Destroy()
            end
        end
    end
end)

CreateDropdown(SecESP, "Weapon Chams Color", ColorOptionNames, _G.SelectedWeaponChamColor, function(col)
    _G.SelectedWeaponChamColor = col
end)

CreateToggle(SecESP, "Dropped Gun ESP (Glow & Box)", false, function(st)
    _G.DroppedGunEspActive = st
    if not st then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "MM2_GunCham" or obj.Name == "MM2_GunHighlight" then
                obj:Destroy()
            end
        end
    end
end)

CreateDropdown(SecESP, "Dropped Gun Color", ColorOptionNames, _G.SelectedDroppedGunColor, function(col)
    _G.SelectedDroppedGunColor = col
end)

local SecHitVisuals = CreateSection(Tabs["Visuals"], "HvH Hit Visuals & Audio")
CreateToggle(SecHitVisuals, "Hit Logs (Screen Feed)", true, function(st) _G.HitLogsActive = st end)
CreateToggle(SecHitVisuals, "Hit Sounds (Audio Feedback)", true, function(st) _G.HitSoundsActive = st end)
CreateDropdown(SecHitVisuals, "Hit Sound Type", {"Skeet", "Neverlose", "Bell", "Bubble", "COD", "Rust"}, "Skeet", function(selected)
    _G.SelectedHitSound = selected
end)
CreateSlider(SecHitVisuals, "Sound Volume", _G.HitSoundVolume, 1, 10, false, function(val) _G.HitSoundVolume = val end)
CreateToggle(SecHitVisuals, "Screen Hitmarker", true, function(st) _G.HitmarkersActive = st end)
CreateToggle(SecHitVisuals, "Bullet Tracers (Laser Beam)", true, function(st) _G.TracersActive = st end)
CreateToggle(SecHitVisuals, "3D Hit Impact Sphere", true, function(st) _G.HitEffectActive = st end)
CreateToggle(SecHitVisuals, "HvH Watermark Display", true, function(st) 
    _G.WatermarkActive = st 
    Watermark.Visible = st
end)

local SecCustomWeapons = CreateSection(Tabs["Visuals"], "Custom Weapons (Knife & Gun Skins / 3D Models)")
CreateToggle(SecCustomWeapons, "Enable Custom Knife", false, function(st)
    _G.CustomKnifeActive = st
    UpdateCustomWeapons()
end)
CreateDropdown(SecCustomWeapons, "Knife Model / Skin", KnifeModelNames, _G.SelectedKnifeModel, function(val)
    _G.SelectedKnifeModel = val
    if _G.CustomKnifeActive then
        UpdateCustomWeapons()
    end
end)
CreateToggle(SecCustomWeapons, "Enable Custom Gun", false, function(st)
    _G.CustomGunActive = st
    UpdateCustomWeapons()
end)
CreateDropdown(SecCustomWeapons, "Gun Model / Skin", GunModelNames, _G.SelectedGunModel, function(val)
    _G.SelectedGunModel = val
    if _G.CustomGunActive then
        UpdateCustomWeapons()
    end
end)
CreateDropdown(SecCustomWeapons, "Weapon Material", {"Default", "Neon Glow", "ForceField", "Glass", "Chrome Metal"}, _G.CustomWeaponMaterial, function(val)
    _G.CustomWeaponMaterial = val
    if _G.CustomKnifeActive or _G.CustomGunActive then
        UpdateCustomWeapons()
    end
end)
CreateDropdown(SecCustomWeapons, "Weapon Color Tint", {"Original", "Blood Red", "Cyber Cyan", "Neon Pink", "Gold", "Lime Green", "Rainbow RGB"}, _G.CustomWeaponColor, function(val)
    _G.CustomWeaponColor = val
    if _G.CustomKnifeActive or _G.CustomGunActive then
        UpdateCustomWeapons()
    end
end)
CreateDropdown(SecCustomWeapons, "Weapon Aura (FX)", {"None", "Fire Flames", "Void Smoke", "Cyber Sparks", "Golden Haze", "Blood Drip"}, _G.CustomWeaponAura, function(val)
    _G.CustomWeaponAura = val
    if _G.CustomKnifeActive or _G.CustomGunActive then
        UpdateCustomWeapons()
    end
end)
CreateToggle(SecCustomWeapons, "Knife Blade Trail", false, function(st)
    _G.WeaponTrailActive = st
    if _G.CustomKnifeActive then
        UpdateCustomWeapons()
    end
end)
CreateDropdown(SecCustomWeapons, "Blade Trail Color", {"Rainbow RGB", "Blood Red", "Cyber Cyan", "Gold Glow", "Pure White"}, _G.SelectedWeaponTrailColor, function(val)
    _G.SelectedWeaponTrailColor = val
    if _G.CustomKnifeActive then
        UpdateCustomWeapons()
    end
end)
local SecChineseHat = CreateSection(Tabs["Visuals"], "HvH Chinese Hat Visual")
CreateToggle(SecChineseHat, "Chinese Conical Hat", false, function(st)
    _G.ChineseHatActive = st
    if st then
        ApplyChineseHat()
    else
        RemoveChineseHat()
    end
end)
CreateDropdown(SecChineseHat, "Hat Color Preset", {"Blood Red", "Purple HvH", "Cyber Cyan", "Electric Green", "Pure White", "Gold Glow", "Rainbow RGB"}, "Blood Red", function(selected)
    _G.SelectedHatColor = selected
    if _G.ChineseHatActive then
        ApplyChineseHat()
    end
end)
CreateToggle(SecChineseHat, "Spinning Animation", true, function(st)
    _G.HatSpinActive = st
end)
CreateSlider(SecChineseHat, "Hat Scale", _G.HatScale, 0.8, 2.0, true, function(val)
    _G.HatScale = val
    if _G.ChineseHatActive then
        ApplyChineseHat()
    end
end)
CreateSlider(SecChineseHat, "Height Offset", _G.HatHeight, 0.6, 2.0, true, function(val)
    _G.HatHeight = val
    if _G.ChineseHatActive then
        ApplyChineseHat()
    end
end)

local SecTrails = CreateSection(Tabs["Visuals"], "Neon Trails & Ground Rope")
CreateToggle(SecTrails, "Body Neon Trail", false, function(st)
    _G.PlayerTrailActive = st
    if st then
        ApplyCharacterTrail()
    else
        RemoveCharacterTrail()
    end
end)
CreateDropdown(SecTrails, "Body Trail Color", {"Blood Red", "Purple HvH", "Cyber Cyan", "Electric Green", "Pure White", "Gold Glow", "Rainbow RGB"}, "Blood Red", function(selected)
    _G.SelectedTrailColor = selected
    if _G.PlayerTrailActive then
        ApplyCharacterTrail()
    end
end)
CreateSlider(SecTrails, "Body Trail Lifetime", _G.TrailLifetime, 0.2, 2.0, true, function(val)
    _G.TrailLifetime = val
    if CharacterTrail and CharacterTrail.Parent then
        CharacterTrail.Lifetime = val
    end
end)
CreateToggle(SecTrails, "Foot Rope Trail (Под ногами)", false, function(st)
    _G.FootRopeActive = st
    if st then
        ApplyFootRope()
    else
        RemoveFootRope()
    end
end)
CreateDropdown(SecTrails, "Rope Color Preset", {"Blood Red", "Purple HvH", "Cyber Cyan", "Electric Green", "Pure White", "Gold Glow", "Rainbow RGB"}, "Blood Red", function(selected)
    _G.SelectedRopeColor = selected
    if _G.FootRopeActive then
        ApplyFootRope()
    end
end)
CreateSlider(SecTrails, "Rope Length (Tail)", _G.RopeLifetime, 0.3, 2.5, true, function(val)
    _G.RopeLifetime = val
    if FootRopeTrail and FootRopeTrail.Parent then
        FootRopeTrail.Lifetime = val
    end
end)
CreateSlider(SecTrails, "Rope Thickness", _G.RopeWidth, 0.1, 1.0, true, function(val)
    _G.RopeWidth = val
    if FootRopeTrail and FootRopeTrail.Parent then
        FootRopeTrail.WidthScale = NumberSequence.new({
            NumberSequenceKeypoint.new(0, val),
            NumberSequenceKeypoint.new(1, 0.02)
        })
    end
end)

local SecFootsteps = CreateSection(Tabs["Visuals"], "Footsteps Audio & Camera")
CreateToggle(SecFootsteps, "Custom Footstep Sounds", false, function(st)
    _G.CustomFootstepsActive = st
    if not st and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local run = hrp:FindFirstChild("Running")
            if run and run:IsA("Sound") then run.Volume = 0.65 end
        end
    end
end)
CreateDropdown(SecFootsteps, "Footstep Sound Type", {"Minecraft Stone", "Concrete Combat Boot", "High Heels Click", "Anime Bubble Pop", "Squeaky Meme Toy"}, "Minecraft Stone", function(selected)
    _G.SelectedFootstep = selected
end)
CreateSlider(SecFootsteps, "Footsteps Volume", _G.FootstepsVolume, 1, 10, false, function(val)
    _G.FootstepsVolume = val
end)
CreateToggle(SecFootsteps, "Custom Camera FOV", false, function(st)
    _G.CustomFOVActive = st
    if not st then
        Camera.FieldOfView = OriginalLighting.FieldOfView or 70
    end
end)
CreateSlider(SecFootsteps, "Field of View", _G.CustomFOVValue, 60, 120, false, function(val)
    _G.CustomFOVValue = val
    if _G.CustomFOVActive then
        Camera.FieldOfView = val
    end
end)
CreateToggle(SecFootsteps, "Screen Depth Blur", false, function(st)
    _G.BlurActive = st
    UpdateBlur()
end)
CreateSlider(SecFootsteps, "Blur Intensity", _G.BlurSize, 1, 25, false, function(val)
    _G.BlurSize = val
    UpdateBlur()
end)
CreateToggle(SecFootsteps, "Hit / Kill Screen Flash", true, function(st)
    _G.KillFlashActive = st
end)

local SecWorldFog = CreateSection(Tabs["Visuals"], "World Fog & Atmosphere")
CreateToggle(SecWorldFog, "Custom Fog Color", false, function(st)
    _G.FogColorActive = st
    if not st then
        Lighting.FogColor = OriginalLighting.FogColor
        Lighting.FogStart = OriginalLighting.FogStart
        Lighting.FogEnd = OriginalLighting.FogEnd
    end
end)
CreateDropdown(SecWorldFog, "Fog Color Preset", {"Blood Red", "Purple Night", "Cyber Cyan", "Midnight Black", "Neon Green", "Toxic Orange", "Deep Violet", "Pure White"}, "Blood Red", function(selected)
    _G.SelectedFogColor = selected
end)
CreateSlider(SecWorldFog, "Fog Start Dist", _G.FogStart, 0, 300, false, function(val) _G.FogStart = val end)
CreateSlider(SecWorldFog, "Fog End (Density)", _G.FogEnd, 30, 1200, false, function(val) _G.FogEnd = val end)
CreateToggle(SecWorldFog, "Override Time of Day", false, function(st)
    _G.TimeOfDayActive = st
    if not st then
        Lighting.ClockTime = OriginalLighting.ClockTime
    end
end)
CreateSlider(SecWorldFog, "Time (Clock Hours)", _G.TimeOfDayValue, 0, 24, false, function(val) _G.TimeOfDayValue = val end)

local SecSkyLighting = CreateSection(Tabs["Visuals"], "Skybox & World Lighting")
CreateToggle(SecSkyLighting, "Custom Skybox", false, function(st)
    _G.CustomSkyActive = st
    if st then
        ApplySkyPreset(_G.SelectedSkyPreset)
    else
        RemoveSkyPreset()
    end
end)
CreateDropdown(SecSkyLighting, "Skybox Preset", {"Purple Galaxy", "Red Blood Moon", "Cyberpunk City", "Dark Space", "Pure Void (Black)"}, "Purple Galaxy", function(selected)
    _G.SelectedSkyPreset = selected
    if _G.CustomSkyActive then
        ApplySkyPreset(selected)
    end
end)
CreateToggle(SecSkyLighting, "World Ambient Color", false, function(st)
    _G.AmbientActive = st
    if not st then
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end
end)
CreateDropdown(SecSkyLighting, "Ambient Preset", {"Blood Red", "Purple Twilight", "Cold Cyan", "Night Warm", "Pure White"}, "Blood Red", function(selected)
    _G.SelectedAmbient = selected
end)
CreateToggle(SecSkyLighting, "Fullbright (No Shadows)", false, function(st)
    _G.FullbrightActive = st
    if not st then
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end
end)
CreateToggle(SecSkyLighting, "Color Correction Filter", false, function(st)
    _G.ColorCorrectionActive = st
    UpdateColorCorrection()
end)
CreateSlider(SecSkyLighting, "Saturation Boost", _G.SaturationBoost, -1, 4, true, function(val)
    _G.SaturationBoost = val
    UpdateColorCorrection()
end)
CreateSlider(SecSkyLighting, "Contrast Boost", _G.ContrastBoost, 0, 2, true, function(val)
    _G.ContrastBoost = val
    UpdateColorCorrection()
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
CreateDropdown(SecModels, "Select Model", {"angel", "spiderman", "donkey", "pig", "la vaca saturnita"}, _G.SelectedCustomModel, function(selected)
    _G.SelectedCustomModel = selected
    if _G.CustomModelsActive then
        ApplyCustomModel(selected)
    end
end)
CreateSlider(SecModels, "Model Scale Size", _G.CustomModelScale, 0.3, 2.5, true, function(val)
    _G.CustomModelScale = val
    if _G.CustomModelsActive then
        ApplyCustomModel(_G.SelectedCustomModel)
    end
end)
CreateSlider(SecModels, "Height Offset (Y)", _G.CustomModelHeightOffset, -3.0, 3.0, true, function(val)
    _G.CustomModelHeightOffset = val
    if _G.CustomModelsActive then
        ApplyCustomModel(_G.SelectedCustomModel)
    end
end)
CreateSlider(SecModels, "Rotation Offset (Y)", _G.CustomModelRotation, 0, 360, false, function(val)
    _G.CustomModelRotation = val
    if _G.CustomModelsActive then
        ApplyCustomModel(_G.SelectedCustomModel)
    end
end)

local SecMoreVisuals = CreateSection(Tabs["Visuals"], "HvH Aesthetics & Crosshair")
CreateToggle(SecMoreVisuals, "Custom HvH Crosshair", false, function(st) _G.CustomCrosshairActive = st end)
CreateDropdown(SecMoreVisuals, "Crosshair Color", {"Blood Red", "Cyber Cyan", "Purple HvH", "Pure White", "Rainbow RGB"}, "Blood Red", function(selected)
    _G.SelectedCrosshairColor = selected
end)
CreateSlider(SecMoreVisuals, "Crosshair Size", _G.CrosshairSize, 4, 20, false, function(val) _G.CrosshairSize = val end)
CreateSlider(SecMoreVisuals, "Crosshair Gap", _G.CrosshairGap, 1, 10, false, function(val) _G.CrosshairGap = val end)
CreateToggle(SecMoreVisuals, "Player Snaplines (Трейсеры)", false, function(st) _G.SnaplinesActive = st end)
CreateToggle(SecMoreVisuals, "Head Dot ESP (Точка головы)", false, function(st) _G.HeadDotActive = st end)
CreateToggle(SecMoreVisuals, "Rainbow RGB Menu Sync", false, function(st)
    _G.RGBSyncActive = st
    if not st then
        UIStrokeMain.Color = Color3.fromRGB(220, 35, 45)
        HeaderLine.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
    end
end)

-- 3. COMBAT TAB
local SecCombat = CreateSection(Tabs["Combat"], "Aimbot & Prediction")
CreateToggle(SecCombat, "Camera Lock Aimbot", false, function(st) _G.CameraAimActive = st end)
CreateDropdown(SecCombat, "Aim Target Bone", {"Head", "Torso"}, "Head", function(b) _G.AimBone = b end)
CreateToggle(SecCombat, "Show FOV Circle", true, function(st) _G.ShowFOVCircle = st end)
CreateSlider(SecCombat, "FOV Circle Radius", _G.FOVCircleRadius, 40, 350, false, function(val) _G.FOVCircleRadius = val end)
CreateDropdown(SecCombat, "FOV Circle Color", FOVColorOptionNames, _G.SelectedFOVColor, function(b) _G.SelectedFOVColor = b end)
CreateSlider(SecCombat, "FOV Transparency", math.round((_G.FOVTransparency or 0) * 100), 0, 90, false, function(val) _G.FOVTransparency = val / 100 end)
CreateSlider(SecCombat, "FOV Thickness", _G.FOVThickness or 1.2, 1, 5, false, function(val) _G.FOVThickness = val end)
CreateSlider(SecCombat, "Aimbot Smoothness", _G.AimSmoothness, 1, 10, false, function(val) _G.AimSmoothness = val end)
CreateToggle(SecCombat, "Always Aim (No Click Req)", false, function(st) _G.AlwaysAim = st end)
CreateToggle(SecCombat, "Real Invisible Silent Aim", false, function(st) _G.RealSilentAimActive = st end)
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

-- 4. HVH TAB
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

-- 5. SETTINGS TAB
local SecTheme = CreateSection(Tabs["Settings"], "Menu Theme & Appearance")
CreateDropdown(SecTheme, "Menu Accent Color", ColorOptionNames, _G.SelectedThemeColor, function(val)
    _G.SelectedThemeColor = val
    ApplyMenuTheme()
end)

CreateDropdown(SecTheme, "Menu Background Theme", MenuBgOptionNames, _G.SelectedMenuBgTheme, function(val)
    _G.SelectedMenuBgTheme = val
    ApplyMenuTheme()
end)

CreateSlider(SecTheme, "Menu Transparency", math.round((_G.MenuTransparency or 0) * 100), 0, 85, false, function(val)
    _G.MenuTransparency = val / 100
    ApplyMenuTheme()
end)

CreateSlider(SecTheme, "Section Transparency", math.round((_G.SectionTransparency or 0) * 100), 0, 85, false, function(val)
    _G.SectionTransparency = val / 100
    ApplyMenuTheme()
end)

CreateToggle(SecTheme, "Rainbow Sync (RGB Everything)", _G.RGBSyncActive, function(st)
    _G.RGBSyncActive = st
    if not st then ApplyMenuTheme() end
end)

local SecCombatColors = CreateSection(Tabs["Settings"], "Aimbot & FOV Colors")
CreateDropdown(SecCombatColors, "FOV Circle Color", FOVColorOptionNames, _G.SelectedFOVColor, function(val)
    _G.SelectedFOVColor = val
end)

CreateSlider(SecCombatColors, "FOV Transparency", math.round((_G.FOVTransparency or 0) * 100), 0, 90, false, function(val)
    _G.FOVTransparency = val / 100
end)

CreateSlider(SecCombatColors, "FOV Circle Thickness", _G.FOVThickness or 1.2, 1, 5, false, function(val)
    _G.FOVThickness = val
end)

local SecVisualColors = CreateSection(Tabs["Settings"], "ESP & Chams Custom Colors")
CreateDropdown(SecVisualColors, "Weapon Chams Color", ColorOptionNames, _G.SelectedWeaponChamColor, function(val)
    _G.SelectedWeaponChamColor = val
end)

CreateDropdown(SecVisualColors, "Dropped Gun ESP Color", ColorOptionNames, _G.SelectedDroppedGunColor, function(val)
    _G.SelectedDroppedGunColor = val
end)

CreateDropdown(SecVisualColors, "Murderer ESP Color", ColorOptionNames, _G.SelectedMurdererColor, function(val)
    _G.SelectedMurdererColor = val
    if UpdateRoleColors then UpdateRoleColors() end
    ClearAllChams()
end)

CreateDropdown(SecVisualColors, "Sheriff ESP Color", ColorOptionNames, _G.SelectedSheriffColor, function(val)
    _G.SelectedSheriffColor = val
    if UpdateRoleColors then UpdateRoleColors() end
    ClearAllChams()
end)

CreateDropdown(SecVisualColors, "Innocent ESP Color", ColorOptionNames, _G.SelectedInnocentColor, function(val)
    _G.SelectedInnocentColor = val
    if UpdateRoleColors then UpdateRoleColors() end
    ClearAllChams()
end)

CreateSlider(SecVisualColors, "Chams Fill Transparency", math.round((_G.ChamsFillTransparency or 0.35) * 100), 0, 90, false, function(val)
    _G.ChamsFillTransparency = val / 100
end)

CreateSlider(SecVisualColors, "Chams Outline Transparency", math.round((_G.ChamsOutlineTransparency or 0) * 100), 0, 90, false, function(val)
    _G.ChamsOutlineTransparency = val / 100
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
    
    ApplyMenuTheme()
    MainFrame.Visible = true
end)

------------------------------------------------------------------------
-- ИГРОВАЯ ЛОГИКА MM2 + СИСТЕМА ПРЕДИКТА (MOVEMENT PREDICTION)
------------------------------------------------------------------------
local RoleColors = {
    Murderer = Color3.fromRGB(255, 35, 45),
    Sheriff  = Color3.fromRGB(30, 140, 255),
    Hero     = Color3.fromRGB(255, 215, 0),
    Innocent = Color3.fromRGB(30, 255, 100)
}

function UpdateRoleColors()
    RoleColors.Murderer = (_G.SelectedMurdererColor == "Rainbow RGB" and _G.RainbowColor) 
        or (ColorPresets[_G.SelectedMurdererColor] or Color3.fromRGB(255, 35, 45))
    RoleColors.Sheriff  = (_G.SelectedSheriffColor == "Rainbow RGB" and _G.RainbowColor) 
        or (ColorPresets[_G.SelectedSheriffColor] or Color3.fromRGB(30, 140, 255))
    RoleColors.Innocent = (_G.SelectedInnocentColor == "Rainbow RGB" and _G.RainbowColor) 
        or (ColorPresets[_G.SelectedInnocentColor] or Color3.fromRGB(30, 255, 100))
    RoleColors.Hero     = Color3.fromRGB(255, 215, 0)
end
UpdateRoleColors()

local ChamColorPresets = ColorPresets

local function ClearAllChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, obj in ipairs(player.Character:GetDescendants()) do
                if obj.Name == "MM2_BoxCham" or obj.Name == "MM2_PlayerHighlight" or 
                   obj.Name == "MM2_SelfCham" or obj.Name == "MM2_SelfHighlight" or 
                   obj.Name == "MM2_WeaponCham" or obj.Name == "MM2_WeaponHighlight" then
                    obj:Destroy()
                end
            end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "MM2_GunCham" or obj.Name == "MM2_GunHighlight" or 
           obj.Name == "MM2_WeaponCham" or obj.Name == "MM2_WeaponHighlight" then
            obj:Destroy()
        end
    end
end

local function ApplyHighlightCham(targetInstance, color, chamName, isOutlineOnly)
    if not targetInstance then return nil end
    local hl = targetInstance:FindFirstChild(chamName)
    if not hl or not hl:IsA("Highlight") then
        if hl then hl:Destroy() end
        hl = Instance.new("Highlight")
        hl.Name = chamName
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = targetInstance
    end
    hl.Adornee = targetInstance
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = isOutlineOnly and 1 or (_G.ChamsFillTransparency or 0.35)
    hl.OutlineTransparency = _G.ChamsOutlineTransparency or 0
    return hl
end

local function ApplyBoxCham(part, color, chamName)
    if not part or not part:IsA("BasePart") then return nil end
    local box = part:FindFirstChild(chamName)
    if not box or not box:IsA("BoxHandleAdornment") then
        if box then box:Destroy() end
        box = Instance.new("BoxHandleAdornment")
        box.Name = chamName
        box.Size = part.Size + Vector3.new(0.04, 0.04, 0.04)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Adornee = part
        box.Parent = part
    end
    box.Color3 = color
    box.Transparency = _G.ChamsFillTransparency or 0.35
    return box
end

local function CreateBoxCham(part, color, chamName)
    return ApplyBoxCham(part, color, chamName)
end

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

-- ФУНКЦИИ ВЫБОРА КОСТИ И ПРЕДИКТА (С ПОЛНЫМ ФИКСОМ НАВОДКИ В НОГИ)
local function GetAimbotBone(char)
    if not char then return nil end
    if _G.AimBone == "Torso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    else
        return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    end
end

-- ФУНКЦИЯ РАСЧЕТА ПРЕДИКТА (Фильтрация гравитации Y, чтобы прицел не падал в пятки)
local function GetPredictedPosition(targetPart)
    if not targetPart then return Vector3.new(0, 0, 0) end
    local basePos = targetPart.Position
    
    -- Фикс: если передали HRP, смещаем вверх на уровень груди/головы (+1.6 стадса)
    if targetPart.Name == "HumanoidRootPart" or targetPart.Name == "LowerTorso" then
        basePos = basePos + Vector3.new(0, 1.6, 0)
    end
    
    if _G.PredictionActive then
        local char = targetPart.Parent
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or targetPart)
        if root then
            local vel = root.Velocity
            -- Ограничиваем вертикальную скорость, предотвращая смещение в пол
            local predY = math.clamp(vel.Y, -2, 7)
            local horizontalVel = Vector3.new(vel.X, predY, vel.Z)
            return basePos + (horizontalVel * _G.PredictionAmount)
        end
    end
    return basePos
end

-- ФУНКЦИЯ ПРОВЕРКИ AWALL И РАСЧЕТА ДИСТАНЦИИ
local function CheckAwallRay(targetPart)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return false, 999 
    end
    
    local startPos = Camera.CFrame.Position
    local endPos = targetPart and GetPredictedPosition(targetPart) or (Camera.CFrame.Position + Camera.CFrame.LookVector * 100)
    local direction = (endPos - startPos)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(startPos, direction, raycastParams)
    
    if result then
        if targetPart and targetPart.Parent and result.Instance:IsDescendantOf(targetPart.Parent) then
            return true, result.Distance
        else
            return false, result.Distance
        end
    end
    return true, 100
end

-- РЕНДЕР СНАПЛАЙНОВ, ТОЧЕК НА ГОЛОВЕ И КАСТОМНОГО ПРИЦЕЛА
local SnaplinePool = {}
local function UpdateSnaplines()
    if not _G.SnaplinesActive then
        SnaplinesContainer.Visible = false
        return
    end
    SnaplinesContainer.Visible = true
    
    local lineIndex = 0
    local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen and screenPos.Z > 0 then
                    lineIndex = lineIndex + 1
                    local line = SnaplinePool[lineIndex]
                    if not line then
                        line = Instance.new("Frame")
                        line.AnchorPoint = Vector2.new(0, 0.5)
                        line.BorderSizePixel = 0
                        line.Parent = SnaplinesContainer
                        SnaplinePool[lineIndex] = line
                    end
                    
                    local role = GetRole(player)
                    line.BackgroundColor3 = RoleColors[role] or Color3.fromRGB(220, 35, 45)
                    local target2D = Vector2.new(screenPos.X, screenPos.Y)
                    local length = (target2D - origin).Magnitude
                    local angle = math.deg(math.atan2(target2D.Y - origin.Y, target2D.X - origin.X))
                    
                    line.Size = UDim2.new(0, length, 0, 1.5)
                    line.Position = UDim2.new(0, origin.X, 0, origin.Y)
                    line.Rotation = angle
                    line.Visible = true
                end
            end
        end
    end
    
    for i = lineIndex + 1, #SnaplinePool do
        SnaplinePool[i].Visible = false
    end
end

local function UpdateHeadDots()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local dot = head:FindFirstChild("MM2_HeadDot")
                if _G.HeadDotActive then
                    local role = GetRole(player)
                    local col = RoleColors[role] or Color3.fromRGB(220, 35, 45)
                    if not dot then
                        dot = Instance.new("SphereHandleAdornment")
                        dot.Name = "MM2_HeadDot"
                        dot.Radius = 0.55
                        dot.AlwaysOnTop = true
                        dot.ZIndex = 8
                        dot.Adornee = head
                        dot.Color3 = col
                        dot.Transparency = 0.25
                        dot.Parent = head
                    else
                        dot.Color3 = col
                    end
                else
                    if dot then dot:Destroy() end
                end
            end
        end
    end
end

local function UpdateCrosshair()
    if not _G.CustomCrosshairActive then
        CrosshairCenter.Visible = false
        return
    end
    CrosshairCenter.Visible = true
    
    local col = RopeColorPresets[_G.SelectedCrosshairColor] or Color3.fromRGB(255, 45, 55)
    if _G.SelectedCrosshairColor == "Rainbow RGB" then
        local hue = (tick() * 0.6) % 1
        col = Color3.fromHSV(hue, 1, 1)
    end
    CrosshairCenter.BackgroundColor3 = col
    
    local size = _G.CrosshairSize or 8
    local gap = _G.CrosshairGap or 3
    
    -- Up
    chBars[1].Size = UDim2.new(0, 2, 0, size)
    chBars[1].Position = UDim2.new(0.5, -1, 0, -(gap + size))
    chBars[1].BackgroundColor3 = col
    -- Down
    chBars[2].Size = UDim2.new(0, 2, 0, size)
    chBars[2].Position = UDim2.new(0.5, -1, 1, gap)
    chBars[2].BackgroundColor3 = col
    -- Left
    chBars[3].Size = UDim2.new(0, size, 0, 2)
    chBars[3].Position = UDim2.new(0, -(gap + size), 0.5, -1)
    chBars[3].BackgroundColor3 = col
    -- Right
    chBars[4].Size = UDim2.new(0, size, 0, 2)
    chBars[4].Position = UDim2.new(1, gap, 0.5, -1)
    chBars[4].BackgroundColor3 = col
end

-- РЕНДЕР ДИНАМИЧЕСКОГО КВАДРАТА AWALL И ВИЗУАЛОВ (FOV, CROSSHAIR, SNAPLINES)
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
    
    -- Отрисовка круга FOV прицела
    if _G.ShowFOVCircle then
        FOVCircle.Visible = true
        local r = _G.FOVCircleRadius or 130
        FOVCircle.Size = UDim2.new(0, r * 2, 0, r * 2)
        local fovCol
        if _G.SelectedFOVColor == "Rainbow RGB" or _G.RGBSyncActive then
            fovCol = _G.RainbowColor or Color3.fromRGB(220, 35, 45)
        elseif _G.SelectedFOVColor == "Theme Match" then
            fovCol = GetThemeAccentColor()
        else
            fovCol = ColorPresets[_G.SelectedFOVColor] or Color3.fromRGB(220, 35, 45)
        end
        fovStroke.Color = fovCol
        fovStroke.Transparency = _G.FOVTransparency or 0
        fovStroke.Thickness = _G.FOVThickness or 1.2
    else
        FOVCircle.Visible = false
    end
    
    -- Обновление снаплайнов, прицела и точек на голове
    UpdateSnaplines()
    UpdateCrosshair()
    UpdateHeadDots()
    
    -- Радужный синхрон интерфейса
    local hue = (tick() * 0.3) % 1
    _G.RainbowColor = Color3.fromHSV(hue, 0.85, 1)
    
    if _G.SelectedThemeColor == "Rainbow RGB" or _G.RGBSyncActive then
        local rgbCol = _G.RainbowColor
        UIStrokeMain.Color = rgbCol
        HeaderLine.BackgroundColor3 = rgbCol
        Badge.TextColor3 = rgbCol
        for _, circle in ipairs(UmbrellaCircles) do
            circle.BackgroundColor3 = rgbCol
        end
        for _, stroke in ipairs(AllDropdownStrokes) do
            stroke.Color = rgbCol
        end
        for _, fill in ipairs(AllSliderFills) do
            fill.BackgroundColor3 = rgbCol
        end
        for _, toggleData in ipairs(AllToggles) do
            if toggleData.GetState() then
                toggleData.Button.BackgroundColor3 = rgbCol
            end
        end
        for _, title in ipairs(AllSectionTitles) do
            title.TextColor3 = rgbCol
        end
        for _, scroller in ipairs(AllSectionScrollbars) do
            scroller.ScrollBarImageColor3 = rgbCol
        end
        for _, tabScroller in pairs(Tabs) do
            tabScroller.ScrollBarImageColor3 = rgbCol
        end
        if CurrentActiveTab and TabButtons[CurrentActiveTab] then
            local stroke = TabButtons[CurrentActiveTab]:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = rgbCol end
        end
    end
    
    if _G.SelectedMurdererColor == "Rainbow RGB" or _G.SelectedSheriffColor == "Rainbow RGB" or _G.SelectedInnocentColor == "Rainbow RGB" then
        UpdateRoleColors()
    end
end)

------------------------------------------------------------------------
-- 4. HVH HIT SYSTEM: HIT LOGS, SOUNDS, TRACERS, HITMARKERS
------------------------------------------------------------------------

local HitSoundAssets = {
    ["Skeet"]      = "rbxassetid://4817809188",
    ["Neverlose"]  = "rbxassetid://6607204501",
    ["Bell"]       = "rbxassetid://6534947240",
    ["Bubble"]     = "rbxassetid://6534947588",
    ["COD"]        = "rbxassetid://131961136",
    ["Rust"]       = "rbxassetid://5043539502"
}

local function PlayHitSound()
    if not _G.HitSoundsActive then return end
    local assetId = HitSoundAssets[_G.SelectedHitSound] or HitSoundAssets["Skeet"]
    local sound = Instance.new("Sound")
    sound.SoundId = assetId
    sound.Volume = math.clamp((_G.HitSoundVolume or 3) * 0.25, 0.1, 5)
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    task.delay(1.5, function()
        if sound and sound.Parent then sound:Destroy() end
    end)
end

local function ShowScreenHitmarker()
    if not _G.HitmarkersActive then return end
    for _, l in ipairs(hmLines) do
        l.BackgroundTransparency = 0
    end
    task.spawn(function()
        task.wait(0.08)
        for i = 1, 8 do
            task.wait(0.02)
            for _, l in ipairs(hmLines) do
                l.BackgroundTransparency = i / 8
            end
        end
    end)
end

local function CreateBulletTracer(startPos, endPos)
    if not _G.TracersActive then return end
    local dist = (endPos - startPos).Magnitude
    if dist < 0.5 then return end
    
    local tracer = Instance.new("Part")
    tracer.Name = "Umbrella_Tracer"
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = Color3.fromRGB(220, 35, 45)
    tracer.Size = Vector3.new(0.12, 0.12, dist)
    tracer.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -dist / 2)
    tracer.Transparency = 0.1
    tracer.Parent = workspace
    
    task.spawn(function()
        for i = 1, 10 do
            task.wait(0.03)
            if tracer and tracer.Parent then
                tracer.Transparency = 0.1 + (0.9 * (i / 10))
            end
        end
        if tracer and tracer.Parent then tracer:Destroy() end
    end)
end

local function Create3DHitEffect(hitPos)
    if not _G.HitEffectActive then return end
    local ring = Instance.new("Part")
    ring.Name = "Umbrella_HitImpact"
    ring.Shape = Enum.PartType.Ball
    ring.Size = Vector3.new(0.8, 0.8, 0.8)
    ring.Color = Color3.fromRGB(255, 45, 55)
    ring.Material = Enum.Material.Neon
    ring.Anchored = true
    ring.CanCollide = false
    ring.CFrame = CFrame.new(hitPos)
    ring.Transparency = 0.2
    ring.Parent = workspace
    
    task.spawn(function()
        for i = 1, 8 do
            task.wait(0.025)
            if ring and ring.Parent then
                ring.Size = ring.Size + Vector3.new(0.35, 0.35, 0.35)
                ring.Transparency = 0.2 + (0.8 * (i / 8))
            end
        end
        if ring and ring.Parent then ring:Destroy() end
    end)
end

local function AddHitLog(targetName, role, hitPart, dist)
    if not _G.HitLogsActive then return end
    
    local LogFrame = Instance.new("Frame")
    LogFrame.Parent = HitLogsContainer
    LogFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
    LogFrame.Size = UDim2.new(0, 345, 0, 24)
    LogFrame.BackgroundTransparency = 0.15
    LogFrame.ClipsDescendants = true
    
    Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke", LogFrame)
    stroke.Color = Color3.fromRGB(220, 35, 45)
    stroke.Thickness = 1
    
    local Accent = Instance.new("Frame", LogFrame)
    Accent.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
    Accent.Size = UDim2.new(0, 3, 1, 0)
    Accent.BorderSizePixel = 0
    
    local roleHex = "#ff232d"
    if role == "Sheriff" then roleHex = "#1e8cff" elseif role == "Innocent" then roleHex = "#1eff64" end
    
    local Label = Instance.new("TextLabel")
    Label.Parent = LogFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.Size = UDim2.new(1, -12, 1, 0)
    Label.Font = Enum.Font.SourceSansBold
    Label.RichText = true
    Label.Text = string.format(
        '[<font color="#dc232d">UMBRELLA</font>] Hit <font color="%s">%s</font> (%s) in <font color="#ffffff">%s</font> [dist: %dm]',
        roleHex, targetName, role, hitPart or "Torso", math.round(dist or 0)
    )
    Label.TextColor3 = Color3.fromRGB(225, 230, 240)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    task.spawn(function()
        task.wait(3.5)
        local fadeTween = TweenService:Create(LogFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        })
        TweenService:Create(Label, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(Accent, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        fadeTween:Play()
        fadeTween.Completed:Wait()
        LogFrame:Destroy()
    end)
end

local lastHitRecord = {}
local function OnHitRegistered(targetPlayer, hitPos, partName)
    local targetName = targetPlayer and targetPlayer.Name or "Target"
    local now = tick()
    if lastHitRecord[targetName] and (now - lastHitRecord[targetName]) < 0.16 then
        return
    end
    lastHitRecord[targetName] = now
    
    local char = LocalPlayer.Character
    local gun = char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or char:FindFirstChild("Knife"))
    local startPos = (gun and gun:FindFirstChild("Handle") and gun.Handle.Position) or (char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position) or Camera.CFrame.Position
    local dist = (startPos - hitPos).Magnitude
    local role = targetPlayer and GetRole(targetPlayer) or "Innocent"
    
    PlayHitSound()
    ShowScreenHitmarker()
    TriggerScreenFlash()
    CreateBulletTracer(startPos, hitPos)
    Create3DHitEffect(hitPos)
    AddHitLog(targetName, role, partName or "Torso", dist)
end

-- Автоматический трекинг урона по игрокам
local function SetupDamageListener(player)
    if player == LocalPlayer then return end
    local function ConnectChar(char)
        local hum = char:WaitForChild("Humanoid", 6)
        if not hum then return end
        local lastHp = hum.Health
        hum.HealthChanged:Connect(function(newHp)
            if newHp < lastHp then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
                    local myHrp = myChar.HumanoidRootPart
                    local enemyHrp = char.HumanoidRootPart
                    if (myHrp.Position - enemyHrp.Position).Magnitude <= 120 then
                        OnHitRegistered(player, enemyHrp.Position, "HumanoidRootPart")
                    end
                end
            end
            lastHp = newHp
        end)
    end
    if player.Character then ConnectChar(player.Character) end
    player.CharacterAdded:Connect(ConnectChar)
end

for _, p in ipairs(Players:GetPlayers()) do SetupDamageListener(p) end
Players.PlayerAdded:Connect(SetupDamageListener)

-- ПОТОК WATERMARK И FPS
task.spawn(function()
    local lastTime = tick()
    local frameCount = 0
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 1 then
            local fps = frameCount
            frameCount = 0
            lastTime = now
            if _G.WatermarkActive then
                Watermark.Visible = true
                WatermarkLabel.Text = string.format('UMBRELLA <font color="#dc232d">SUPREMACY</font> | %d FPS | MM2 HvH', fps)
            else
                Watermark.Visible = false
            end
        end
    end)
end)

------------------------------------------------------------------------
-- 5. HVH ДВИЖЕНИЕ: AUTO-STRAFE, FLY, FAST STOP, HIGH/LONG JUMP
------------------------------------------------------------------------

-- 1. AUTO-STRAFE (Синхронизация воздушного ускорения с направлением взгляда)
RunService.RenderStepped:Connect(function()
    if _G.AutoStrafeActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp and humanoid.FloorMaterial == Enum.Material.Air then
            if humanoid.MoveDirection.Magnitude > 0 then
                local camLook = Camera.CFrame.LookVector
                local forward = Vector3.new(camLook.X, 0, camLook.Z).Unit
                local right = Vector3.new(-forward.Z, 0, forward.X)
                
                local w = UserInputService:IsKeyDown(Enum.KeyCode.W)
                local s = UserInputService:IsKeyDown(Enum.KeyCode.S)
                local a = UserInputService:IsKeyDown(Enum.KeyCode.A)
                local d = UserInputService:IsKeyDown(Enum.KeyCode.D)
                
                local wishDir = (forward * (w and 1 or (s and -1 or 0))) + (right * (d and 1 or (a and -1 or 0)))
                if wishDir.Magnitude > 0 then
                    wishDir = wishDir.Unit
                    local curVel = hrp.Velocity
                    local flatVel = Vector3.new(curVel.X, 0, curVel.Z)
                    local targetSpeed = math.max(flatVel.Magnitude, _G.SpeedValue or 35)
                    local newFlat = (flatVel + (wishDir * 3.5)).Unit * targetSpeed
                    hrp.Velocity = Vector3.new(newFlat.X, curVel.Y, newFlat.Z)
                end
            end
        end
    end
end)

-- 2. PRO FLY HACK (Идеально плавный полет через BodyVelocity + BodyGyro + Noclip)
local flyBV = nil
local flyBG = nil

local function StopSmoothFly()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    if LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p.Name == "Umbrella_FlyVelocity" or p.Name == "Umbrella_FlyGyro" then
                p:Destroy()
            end
        end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
end

local function StartSmoothFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    
    StopSmoothFly()
    
    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "Umbrella_FlyVelocity"
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Parent = hrp
    
    flyBG = Instance.new("BodyGyro")
    flyBG.Name = "Umbrella_FlyGyro"
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 9e4
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp
end

RunService.RenderStepped:Connect(function()
    if _G.FlyActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            if not flyBV or not flyBV.Parent or not flyBG or not flyBG.Parent then
                StartSmoothFly()
            end
            
            -- Держит персонажа ровно по направлению камеры без заваливания
            flyBG.CFrame = Camera.CFrame
            
            local camCF = Camera.CFrame
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            if moveDir.Magnitude > 0 then
                flyBV.Velocity = moveDir.Unit * _G.FlySpeed
            else
                flyBV.Velocity = Vector3.new(0, 0, 0)
            end
            
            -- Автоматический noclip во время полета сквозь любые препятствия
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    else
        if flyBV or flyBG then
            StopSmoothFly()
        end
    end
end)

-- 3. FAST STOP (Мгновенное погашение инерции при отпускании клавиш движения)
RunService.Heartbeat:Connect(function()
    if _G.FastStopActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp and humanoid.FloorMaterial ~= Enum.Material.Air then
            if humanoid.MoveDirection.Magnitude == 0 then
                hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- 4. HIGH JUMP BOOST И LONG JUMP BOOST
UserInputService.JumpRequest:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if _G.HighJumpActive and humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = _G.JumpBoostPower
        end
        
        if _G.LongJumpActive and hrp and humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            local camLook = Camera.CFrame.LookVector
            local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
            hrp.Velocity = hrp.Velocity + (flatLook * _G.LongJumpPower)
        end
    end
end)

------------------------------------------------------------------------
-- СУЩЕСТВУЮЩИЕ ФУНКЦИИ И ХУКИ MM2
------------------------------------------------------------------------

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
        task.wait(0.3)
        if _G.WeaponChamsActive then
            local isBox = (_G.ChamsStyle == "Boxes")
            local isOutline = (_G.ChamsStyle == "Outline Only")
            local wColor = (_G.SelectedWeaponChamColor == "Rainbow RGB" and _G.RainbowColor) 
                or (_G.SelectedWeaponChamColor == "Theme Match" and GetThemeAccentColor())
                or (ColorPresets[_G.SelectedWeaponChamColor] or Color3.fromRGB(255, 200, 30))
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    for _, tool in ipairs(player.Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                            if isBox then
                                local hl = tool:FindFirstChild("MM2_WeaponHighlight")
                                if hl then hl:Destroy() end
                                if handle then
                                    ApplyBoxCham(handle, wColor, "MM2_WeaponCham")
                                end
                            else
                                if handle and handle:FindFirstChild("MM2_WeaponCham") then
                                    handle.MM2_WeaponCham:Destroy()
                                end
                                ApplyHighlightCham(tool, wColor, "MM2_WeaponHighlight", isOutline)
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
        task.wait(0.3)
        if _G.DroppedGunEspActive then
            local isBox = (_G.ChamsStyle == "Boxes")
            local isOutline = (_G.ChamsStyle == "Outline Only")
            local gunCol = (_G.SelectedDroppedGunColor == "Rainbow RGB" and _G.RainbowColor) 
                or (_G.SelectedDroppedGunColor == "Theme Match" and GetThemeAccentColor())
                or (ColorPresets[_G.SelectedDroppedGunColor] or Color3.fromRGB(0, 240, 255))
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                    if isBox then
                        local hl = obj:FindFirstChild("MM2_GunHighlight")
                        if hl then hl:Destroy() end
                        ApplyBoxCham(obj, gunCol, "MM2_GunCham")
                    else
                        local box = obj:FindFirstChild("MM2_GunCham")
                        if box then box:Destroy() end
                        ApplyHighlightCham(obj, gunCol, "MM2_GunHighlight", isOutline)
                    end
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
                                OnHitRegistered(player, targetHrp.Position, "Torso")
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

-- 6. HVH: AUTO SHOOT MURDERER FOR SHERIFF
task.spawn(function()
    while true do
        task.wait(0.05)
        if _G.AutoShootSheriff and (GetRole(LocalPlayer) == "Sheriff" or GetRole(LocalPlayer) == "Innocent") and LocalPlayer.Character then
            local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Revolver")
            if not gun then
                local bpack = LocalPlayer:FindFirstChild("Backpack")
                if bpack then
                    local bgun = bpack:FindFirstChild("Gun") or bpack:FindFirstChild("Revolver")
                    if bgun then bgun.Parent = LocalPlayer.Character gun = bgun end
                end
            end
            if gun then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and GetRole(player) == "Murderer" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHrp = player.Character.HumanoidRootPart
                        local isVisible, _ = CheckAwallRay(targetHrp)
                        if isVisible then
                            local predPos = GetPredictedPosition(targetHrp)
                            gun:Activate()
                            local shootRemote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("ShootServer")
                            if shootRemote and shootRemote:IsA("RemoteEvent") then
                                shootRemote:FireServer(predPos)
                                OnHitRegistered(player, predPos, "HumanoidRootPart")
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
    "Umbrella Supremacy v11.0 -- No chance!",
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
                                OnHitRegistered(player, targetHrp.Position, "Torso")
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
        task.wait(0.25)
        if _G.ChamsActive then
            local isBox = (_G.ChamsStyle == "Boxes")
            local isOutline = (_G.ChamsStyle == "Outline Only")
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local role = GetRole(player)
                    local color = RoleColors[role] or Color3.fromRGB(30, 255, 100)
                    if isBox then
                        local hl = player.Character:FindFirstChild("MM2_PlayerHighlight")
                        if hl then hl:Destroy() end
                        for _, part in ipairs(player.Character:GetChildren()) do
                            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                ApplyBoxCham(part, color, "MM2_BoxCham")
                            end
                        end
                    else
                        for _, part in ipairs(player.Character:GetChildren()) do
                            local box = part:FindFirstChild("MM2_BoxCham")
                            if box then box:Destroy() end
                        end
                        ApplyHighlightCham(player.Character, color, "MM2_PlayerHighlight", isOutline)
                    end
                end
            end
        end
    end
end)

-- Поток SELF CHAMS (включая кастомные модельки CustomChangerModel)
task.spawn(function()
    while true do
        task.wait(0.25)
        if _G.SelfChamsActive and LocalPlayer.Character then
            local char = LocalPlayer.Character
            local isBox = (_G.ChamsStyle == "Boxes")
            local isOutline = (_G.ChamsStyle == "Outline Only")
            local selfColor = (_G.SelectedSelfChamColor == "Rainbow RGB" and _G.RainbowColor) or (ChamColorPresets[_G.SelectedSelfChamColor] or Color3.fromRGB(255, 20, 147))
            local customModel = char:FindFirstChild("CustomChangerModel")
            
            if isBox then
                local hlChar = char:FindFirstChild("MM2_SelfHighlight")
                if hlChar then hlChar:Destroy() end
                if customModel then
                    local hlMod = customModel:FindFirstChild("MM2_SelfHighlight")
                    if hlMod then hlMod:Destroy() end
                    for _, part in ipairs(customModel:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            ApplyBoxCham(part, selfColor, "MM2_SelfCham")
                        end
                    end
                else
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            ApplyBoxCham(part, selfColor, "MM2_SelfCham")
                        end
                    end
                end
            else
                for _, obj in ipairs(char:GetDescendants()) do
                    if obj.Name == "MM2_SelfCham" then obj:Destroy() end
                end
                if customModel then
                    local hlChar = char:FindFirstChild("MM2_SelfHighlight")
                    if hlChar then hlChar:Destroy() end
                    ApplyHighlightCham(customModel, selfColor, "MM2_SelfHighlight", isOutline)
                else
                    ApplyHighlightCham(char, selfColor, "MM2_SelfHighlight", isOutline)
                end
            end
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

-- ПОТОК BHOP
RunService.RenderStepped:Connect(function()
    if _G.BhopActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
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
                    local char = LocalPlayer.Character
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local touchHandle = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or root
                    
                    if firetouchinterest and touchHandle then
                        firetouchinterest(touchHandle, gunInstance, 0)
                        firetouchinterest(touchHandle, gunInstance, 1)
                    end
                    
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
    local shortestDist = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
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
                local bone = GetAimbotBone(player.Character)
                if bone then
                    local isVisible, _ = CheckAwallRay(bone)
                    if isVisible then
                        local predPos = GetPredictedPosition(bone)
                        local screenPos, onScreen = Camera:WorldToViewportPoint(predPos)
                        if onScreen and screenPos.Z > 0 then
                            local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            local maxAllowed = _G.ShowFOVCircle and _G.FOVCircleRadius or 1200
                            if mouseDist <= maxAllowed and mouseDist < shortestDist then
                                shortestDist = mouseDist
                                closestPlayer = player
                            end
                        end
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

-- 1. CAMERA LOCK AIMBOT (С ИДЕАЛЬНОЙ НАВОДКОЙ НА ГОЛОВУ И ПЛАВНОСТЬЮ)
RunService.RenderStepped:Connect(function()
    if _G.CameraAimActive and (IsHoldingWeapon() or _G.AlwaysAim) then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or _G.AlwaysAim then
            local target = GetClosestTarget()
            if target and target.Character then
                local bone = GetAimbotBone(target.Character)
                if bone then
                    local predPos = GetPredictedPosition(bone)
                    local targetCF = CFrame.new(Camera.CFrame.Position, predPos)
                    if _G.AimSmoothness and _G.AimSmoothness > 1 then
                        local alpha = math.clamp(1 / _G.AimSmoothness, 0.1, 1)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
                    else
                        Camera.CFrame = targetCF
                    end
                end
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
        if target and target.Character then
            local bone = GetAimbotBone(target.Character)
            if bone then
                local predPos = GetPredictedPosition(bone)
                if key == "Hit" then
                    return CFrame.new(predPos)
                elseif key == "Target" then
                    return bone
                end
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
            if target and target.Character then
                local bone = GetAimbotBone(target.Character)
                local predPos = bone and GetPredictedPosition(bone) or (target.Character.PrimaryPart and target.Character.PrimaryPart.Position)
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
                OnHitRegistered(target, predPos, "HumanoidRootPart")
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
