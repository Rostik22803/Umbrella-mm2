--[[
    ========================================================================
    UMBRELLA CORPORATION — MM2 HVH SUPREMACY
    Module: UI (Theme Engine, Components, HUD & Window)
    ========================================================================
--]]

local UI = {}
local Umbrella = _G.Umbrella or {}
local Core = Umbrella.Core or {}
local Services = Core.Services or {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    SoundService = game:GetService("SoundService"),
    Lighting = game:GetService("Lighting")
}
local Players = Services.Players
local LocalPlayer = Core.LocalPlayer or Players.LocalPlayer
local Camera = Core.Camera or workspace.CurrentCamera
local UserInputService = Services.UserInputService
local RunService = Services.RunService
local TweenService = Services.TweenService
local SoundService = Services.SoundService
local Lighting = Services.Lighting
local ParentGui = Core.ParentGui or (function()
    if gethui then
        local s, r = pcall(gethui)
        if s and r then return r end
    end
    local p = LocalPlayer or game:GetService("Players").LocalPlayer
    if p then
        local pgui = p:FindFirstChildOfClass("PlayerGui")
        if pgui then return pgui end
    end
    return game:GetService("CoreGui")
end)()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Umbrella_MM2_Edition"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Safe parenting with fallback for mobile executors (Delta, Codex, etc.)
local parentSuccess = pcall(function()
    ScreenGui.Parent = ParentGui
end)
if not parentSuccess then
    pcall(function()
        local p = LocalPlayer or game:GetService("Players").LocalPlayer
        ScreenGui.Parent = p:WaitForChild("PlayerGui", 5)
    end)
end
UI.ScreenGui = ScreenGui

local MainFrame = Instance.new("Frame")
local UICornerMain = Instance.new("UICorner")
local UIStrokeMain = Instance.new("UIStroke")

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
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 680, 0, 440)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = false
MainFrame.Visible = false

local function UpdateMenuResponsiveSize()
    local vp = Camera.ViewportSize
    if vp.X > 0 and vp.Y > 0 then
        local w = math.clamp(vp.X - 24, 460, 680)
        local h = math.clamp(vp.Y - 24, 340, 440)
        MainFrame.Size = UDim2.new(0, w, 0, h)
    end
end
UpdateMenuResponsiveSize()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateMenuResponsiveSize)

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
Sidebar.Position = UDim2.new(0, 0, 0, 44)
Sidebar.Size = UDim2.new(0, 130, 1, -44)
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
ContentArea.Position = UDim2.new(0, 130, 0, 44)
ContentArea.Size = UDim2.new(1, -130, 1, -44)

local Tabs = {}
local TabButtons = {}

local function CreateTabPage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Parent = ContentArea
    Page.BackgroundTransparency = 1
    Page.Position = UDim2.new(0, 8, 0, 8)
    Page.Size = UDim2.new(1, -16, 1, -16)
    Page.Visible = false
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(220, 35, 45)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.BorderSizePixel = 0
    Page.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    Page.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    Page.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    
    local Grid = Instance.new("UIGridLayout")
    Grid.Parent = Page
    Grid.CellSize = UDim2.new(0.5, -6, 0, 280)
    Grid.CellPadding = UDim2.new(0, 8, 0, 10)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    
    Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, Grid.AbsoluteContentSize.Y + 20)
    end)
    
    Tabs[name] = Page
    return Page
end

CreateTabPage("Main")
CreateTabPage("Visuals")
CreateTabPage("Skins")
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

local HeadDotColorOptionNames = {
    "Role Colors",
    "Theme Match",
    "Pure White",
    "Blood Crimson",
    "Cyber Cyan",
    "Electric Purple",
    "Neon Pink",
    "Acid Green",
    "Sunset Gold",
    "Rainbow RGB"
}

local CrosshairColorOptionNames = {
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
    "Pulsing Glow",
    "Rainbow RGB"
}

local ChamsStyleOptionNames = {
    "Fill / Glow",
    "Boxes",
    "Outline Only"
}

_G.SelectedThemeColor = "Umbrella Red"
_G.SelectedMenuBgTheme = "Classic Dark"
_G.MenuTransparency = 0
_G.SectionTransparency = 0
_G.SelectedFOVColor = "Umbrella Red"
_G.FOVTransparency = 0
_G.FOVThickness = 1.2
_G.PlayerChamsStyle = "Fill / Glow"
_G.SelfChamsStyle = "Fill / Glow"
_G.WeaponChamsStyle = "Fill / Glow"
_G.DroppedGunChamsStyle = "Fill / Glow"
_G.SelectedWeaponChamColor = "Sunset Gold"
_G.SelectedDroppedGunColor = "Cyber Cyan"
_G.SelectedHeadDotColor = "Role Colors"
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
AddTabButton("Skins", "🎨", 3)
AddTabButton("Combat", "⚔", 4)
AddTabButton("HvH", "☠", 5)
AddTabButton("Settings", "⚙", 6)



------------------------------------------------------------------------
-- КОМПОНЕНТЫ ИНТЕРФЕЙСА
------------------------------------------------------------------------
local function CreateSection(parentPage, title)
    local Section = Instance.new("Frame")
    Section.Parent = parentPage
    local bgPreset = MenuBgPresets[_G.SelectedMenuBgTheme] or MenuBgPresets["Classic Dark"]
    Section.BackgroundColor3 = bgPreset.Section
    Section.BackgroundTransparency = _G.SectionTransparency or 0
    Section.Size = UDim2.new(0.5, -6, 0, 280)
    
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
    SliderFrame.Size = UDim2.new(1, 0, 0, 34)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = SliderFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Size = UDim2.new(1, 0, 0, 14)
    Label.Font = Enum.Font.SourceSansBold
    Label.Text = text .. ": " .. tostring(defaultVal)
    Label.TextColor3 = Color3.fromRGB(210, 215, 225)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local BarBg = Instance.new("Frame")
    BarBg.Parent = SliderFrame
    local bgPreset = MenuBgPresets[_G.SelectedMenuBgTheme] or MenuBgPresets["Classic Dark"]
    BarBg.BackgroundColor3 = bgPreset.Stroke
    BarBg.Position = UDim2.new(0, 0, 0, 18)
    BarBg.Size = UDim2.new(1, 0, 0, 8)
    Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0, 4)
    
    local Fill = Instance.new("Frame")
    Fill.Parent = BarBg
    Fill.BackgroundColor3 = GetThemeAccentColor()
    local startPercent = (defaultVal - minVal) / (maxVal - minVal)
    Fill.Size = UDim2.new(math.clamp(startPercent, 0, 1), 0, 1, 0)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 4)
    table.insert(AllSliderFills, Fill)
    
    -- Handle кружок (увеличен до 14x14 с контуром для удобного захвата)
    local Handle = Instance.new("Frame")
    Handle.Parent = BarBg
    Handle.Position = UDim2.new(math.clamp(startPercent, 0, 1), -7, 0.5, -7)
    Handle.Size = UDim2.new(0, 14, 0, 14)
    Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Handle.ZIndex = 3
    Instance.new("UICorner", Handle).CornerRadius = UDim.new(1, 0)
    local hStroke = Instance.new("UIStroke", Handle)
    hStroke.Color = Color3.fromRGB(25, 26, 32)
    hStroke.Thickness = 1.5
    
    -- Невидимый расширенный триггер на весь бар и зону вокруг (мгновенный клик и перетаскивание)
    local ClickArea = Instance.new("TextButton")
    ClickArea.Name = "SliderClickArea"
    ClickArea.Parent = SliderFrame
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Position = UDim2.new(0, -6, 0, 10)
    ClickArea.Size = UDim2.new(1, 12, 0, 24)
    ClickArea.ZIndex = 4
    
    local dragging = false
    local function Update(inputX)
        local barX = BarBg.AbsolutePosition.X
        local barW = BarBg.AbsoluteSize.X
        if barW <= 0 then return end
        local rel = math.clamp((inputX - barX) / barW, 0, 1)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Handle.Position = UDim2.new(rel, -7, 0.5, -7)
        
        local val = minVal + (rel * (maxVal - minVal))
        if isDecimal then
            val = math.round(val * 100) / 100
        else
            val = math.round(val)
        end
        Label.Text = text .. ": " .. tostring(val)
        callback(val)
    end
    
    ClickArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input.Position.X)
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



-- Watermark Update Loop
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


-- Minimize Handler
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local vp = Camera.ViewportSize
    local curW = math.clamp(vp.X - 24, 460, 680)
    local curH = math.clamp(vp.Y - 24, 340, 440)
    if isMinimized then
        ContentArea.Visible = false
        Sidebar.Visible = false
        MainFrame:TweenSize(UDim2.new(0, curW, 0, 44), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, curW, 0, curH), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        task.wait(0.15)
        ContentArea.Visible = true
        Sidebar.Visible = true
        MinimizeBtn.Text = "−"
    end
end)

------------------------------------------------------------------------
-- FLOATING MOBILE TOGGLE BUTTON & KEYBIND TOGGLE
------------------------------------------------------------------------
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "Umbrella_MobileToggle"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0, 15, 0.5, -20)
ToggleButton.Size = UDim2.new(0, 42, 0, 42)
ToggleButton.BackgroundColor3 = Color3.fromRGB(18, 19, 25)
ToggleButton.Text = ""
ToggleButton.Active = true
ToggleButton.Draggable = true
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Color = Color3.fromRGB(220, 35, 45)
tbStroke.Thickness = 1.5

local tbLogoHolder = Instance.new("Frame", ToggleButton)
tbLogoHolder.BackgroundTransparency = 1
tbLogoHolder.Position = UDim2.new(0.5, -14, 0.5, -14)
tbLogoHolder.Size = UDim2.new(0, 28, 0, 28)
CreateExactUmbrellaLogo(tbLogoHolder, 28)

local function ToggleMenu()
    MainFrame.Visible = not MainFrame.Visible
end

ToggleButton.MouseButton1Click:Connect(ToggleMenu)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        ToggleMenu()
    end
end)

function UI.FinishLoading()
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


end

-- Export UI Methods, Tables and Objects
UI.MainFrame = MainFrame
UI.Sidebar = Sidebar
UI.ContentArea = ContentArea
UI.Tabs = Tabs
UI.TabButtons = TabButtons
UI.TabButtonsOrder = TabButtonsOrder
UI.AwallIndicator = AwallIndicator
UI.WatermarkFrame = WatermarkFrame
UI.HitLogsFrame = HitLogsFrame
UI.CreateExactUmbrellaLogo = CreateExactUmbrellaLogo
UI.CreateSection = CreateSection
UI.CreateToggle = CreateToggle
UI.CreateSlider = CreateSlider
UI.CreateDropdown = CreateDropdown
UI.GetThemeAccentColor = GetThemeAccentColor
UI.ApplyMenuTheme = ApplyMenuTheme
UI.SwitchTab = SwitchTab
UI.AddHitLog = AddHitLog
UI.ShowScreenHitmarker = ShowScreenHitmarker
UI.ColorPresets = ColorPresets
UI.ColorOptionNames = ColorOptionNames
UI.FOVColorOptionNames = FOVColorOptionNames
UI.MenuBgPresets = MenuBgPresets
UI.MenuBgOptionNames = MenuBgOptionNames
UI.HeadDotColorOptionNames = HeadDotColorOptionNames
UI.CrosshairColorOptionNames = CrosshairColorOptionNames
UI.ChamsStyleOptionNames = { "Boxes", "Highlight", "Outline Only", "Chams (Solid)" }


UI.ScreenGui = ScreenGui
UI.UIStrokeMain = UIStrokeMain
UI.HeaderLine = HeaderLine
UI.AwallIndicator = AwallIndicator
UI.Watermark = Watermark
UI.HitLogsContainer = HitLogsContainer
UI.hmLines = hmLines
UI.Tabs = Tabs
UI.TabButtons = TabButtons
UI.CurrentActiveTab = CurrentActiveTab
UI.AllToggles = AllToggles
UI.AllSliderFills = AllSliderFills
UI.AllDropdownStrokes = AllDropdownStrokes
UI.AllSectionTitles = AllSectionTitles
UI.AllSectionScrollbars = AllSectionScrollbars
UI.UmbrellaCircles = UmbrellaCircles or {}

return UI