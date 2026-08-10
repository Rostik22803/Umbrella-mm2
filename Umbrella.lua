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
    Grid.CellSize = UDim2.new(0, 260, 0, 270)
    Grid.CellPadding = UDim2.new(0, 12, 0, 12)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    
    Tabs[name] = Page
    return Page
end

CreateTabPage("Main")
CreateTabPage("Visuals")
CreateTabPage("Combat")
CreateTabPage("HvH")
CreateTabPage("Skins")
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
AddTabButton("Skins", "🔪", 5)
AddTabButton("Settings", "⚙", 6)

------------------------------------------------------------------------
-- КОМПОНЕНТЫ ИНТЕРФЕЙСА
------------------------------------------------------------------------
local function CreateSection(parentPage, title)
    local Section = Instance.new("Frame")
    Section.Parent = parentPage
    Section.BackgroundColor3 = Color3.fromRGB(18, 19, 25)
    Section.Size = UDim2.new(0, 260, 0, 270)
    
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

------------------------------------------------------------------------
-- НАПОЛНЕНИЕ ВКЛАДОК И НАСТРОЙКА HVH ФУНКЦИЙ
------------------------------------------------------------------------
_G.ChamsActive = false
_G.SelfChamsActive = false
_G.WeaponChamsActive = false
_G.DroppedGunEspActive = false
_G.MurdererRepelActive = false

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

-- 1. MAIN
local SecMovement = CreateSection(Tabs["Main"], "Movement Mods")
CreateToggle(SecMovement, "Speedhack", false, function(st) _G.SpeedActive = st end)
CreateSlider(SecMovement, "Walk Speed", _G.SpeedValue, 16, 150, false, function(val) _G.SpeedValue = val end)
CreateToggle(SecMovement, "Bhop (Auto Jump)", false, function(st) _G.BhopActive = st end)
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
local SecESP = CreateSection(Tabs["Visuals"], "Player ESP & Weapon Chams")
CreateToggle(SecESP, "Role Box Chams (Players)", false, function(st)
    _G.ChamsActive = st
    if not st then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, obj in ipairs(player.Character:GetDescendants()) do
                    if obj.Name == "MM2_BoxCham" then obj:Destroy() end
                end
            end
        end
    end
end)

CreateToggle(SecESP, "Self Chams (Neon Pink)", false, function(st)
    _G.SelfChamsActive = st
    if not st and LocalPlayer.Character then
        for _, obj in ipairs(LocalPlayer.Character:GetDescendants()) do
            if obj.Name == "MM2_SelfCham" then obj:Destroy() end
        end
    end
end)

CreateToggle(SecESP, "Weapon Chams (Gold Glow)", false, function(st)
    _G.WeaponChamsActive = st
    if not st then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "MM2_WeaponCham" then obj:Destroy() end
        end
    end
end)

CreateToggle(SecESP, "Dropped Gun ESP (Cyan Highlight)", false, function(st)
    _G.DroppedGunEspActive = st
    if not st then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "MM2_GunCham" then obj:Destroy() end
        end
    end
end)

-- 3. COMBAT
local SecCombat = CreateSection(Tabs["Combat"], "Aimbot & Prediction")
CreateToggle(SecCombat, "Camera Lock Aimbot (LKM)", false, function(st) _G.CameraAimActive = st end)
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

-- 5. SKINS (SKINCHANGER & INVENTORY)
_G.SelectedKnifeSkin = "Harvester"
_G.SelectedGunSkin = "Harvester"
_G.EnableSkinChanger = true
_G.ChromaSkinActive = false
_G.ModifyInventoryUI = true

local SecKnifeSkins = CreateSection(Tabs["Skins"], "Knife SkinChanger")
CreateToggle(SecKnifeSkins, "Enable SkinChanger", true, function(st) _G.EnableSkinChanger = st end)
CreateToggle(SecKnifeSkins, "Chroma Rainbow Effect", false, function(st) _G.ChromaSkinActive = st end)
CreateToggle(SecKnifeSkins, "Spoof Inventory UI", true, function(st) _G.ModifyInventoryUI = st end)

local SecSkinChoice = CreateSection(Tabs["Skins"], "Select Preset Skins")
local PresetKnives = {"Harvester", "Corrupt", "Icebreaker", "Chroma Candleflame", "Bat", "Nikilis Scythe", "Swirly Blade"}
local PresetGuns = {"Harvester", "Icebeam", "Swirly Gun", "Chroma Laser", "Luger", "Raygun", "Ocean"}

for _, kName in ipairs(PresetKnives) do
    CreateToggle(SecSkinChoice, "Knife: " .. kName, kName == "Harvester", function(st)
        if st then _G.SelectedKnifeSkin = kName end
    end)
end

for _, gName in ipairs(PresetGuns) do
    CreateToggle(SecSkinChoice, "Gun: " .. gName, gName == "Harvester", function(st)
        if st then _G.SelectedGunSkin = gName end
    end)
end

-- 6. SETTINGS
local SecColors = CreateSection(Tabs["Settings"], "Theme & Menu")
local ColorInfo = Instance.new("TextLabel")
ColorInfo.Parent = SecColors
ColorInfo.BackgroundTransparency = 1
ColorInfo.Size = UDim2.new(1, 0, 0, 40)
ColorInfo.Font = Enum.Font.SourceSans
ColorInfo.Text = "Umbrella MM2 Edition Supremacy v10.0 Loaded Successfully."
ColorInfo.TextColor3 = Color3.fromRGB(150, 155, 165)
ColorInfo.TextSize = 12
ColorInfo.TextWrapped = true

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

local function CreateBoxCham(part, color, chamName)
    if part:FindFirstChild(chamName) then return end
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
                                CreateBoxCham(handle, Color3.fromRGB(255, 215, 0), "MM2_WeaponCham")
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
                    CreateBoxCham(obj, Color3.fromRGB(0, 255, 255), "MM2_GunCham")
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
                    for _, part in ipairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            local existingCham = part:FindFirstChild("MM2_BoxCham")
                            if existingCham then 
                                existingCham.Color3 = color 
                            else 
                                CreateBoxCham(part, color, "MM2_BoxCham") 
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Поток SELF CHAMS
task.spawn(function()
    while true do
        task.wait(0.3)
        if _G.SelfChamsActive and LocalPlayer.Character then
            local pinkColor = Color3.fromRGB(255, 20, 147)
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    local existingCham = part:FindFirstChild("MM2_SelfCham")
                    if existingCham then
                        existingCham.Color3 = pinkColor
                    else
                        CreateBoxCham(part, pinkColor, "MM2_SelfCham")
                    end
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
    
    ------------------------------------------------------------------------
-- ЛОГИКА SKINCHANGER И СПУФИНГА ИНВЕНТАРЯ
------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function GetWeaponModelFromDB(weaponName)
    local db = ReplicatedStorage:FindFirstChild("Database") or ReplicatedStorage:FindFirstChild("Weapons")
    if db then
        local found = db:FindFirstChild(weaponName, true)
        if found then return found end
    end
    return nil
end

local function ApplySkinToTool(tool, skinName)
    if not _G.EnableSkinChanger or not tool then return end
    
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    local dbSkinModel = GetWeaponModelFromDB(skinName)
    if dbSkinModel then
        local skinHandle = dbSkinModel:FindFirstChild("Handle") or dbSkinModel
        if skinHandle then
            local mesh = handle:FindFirstChildOfClass("SpecialMesh") or handle:FindFirstChildOfClass("Mesh")
            local skinMesh = skinHandle:FindFirstChildOfClass("SpecialMesh") or skinHandle:FindFirstChildOfClass("Mesh")
            
            if mesh and skinMesh then
                mesh.MeshId = skinMesh.MeshId
                mesh.TextureId = skinMesh.TextureId
                mesh.Scale = skinMesh.Scale
            end
        end
    end
end

-- Прослушивание взятия оружия в руки
local function SetupSkinChangerForCharacter(char)
    if not char then return end
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            if child.Name == "Knife" then
                ApplySkinToTool(child, _G.SelectedKnifeSkin)
            elseif child.Name == "Gun" or child.Name == "Revolver" then
                ApplySkinToTool(child, _G.SelectedGunSkin)
            end
        end
    end)
    
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            if child.Name == "Knife" then
                ApplySkinToTool(child, _G.SelectedKnifeSkin)
            elseif child.Name == "Gun" or child.Name == "Revolver" then
                ApplySkinToTool(child, _G.SelectedGunSkin)
            end
        end
    end
end

if LocalPlayer.Character then SetupSkinChangerForCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetupSkinChangerForCharacter)

-- Chroma Rainbow Effect Loop
task.spawn(function()
    local hue = 0
    while true do
        task.wait(0.03)
        if _G.ChromaSkinActive and LocalPlayer.Character then
            hue = (hue + 0.01) % 1
            local chromaColor = Color3.fromHSV(hue, 1, 1)
            
            for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
                if item:IsA("Tool") and item:FindFirstChild("Handle") then
                    local mesh = item.Handle:FindFirstChildOfClass("SpecialMesh")
                    if mesh then
                        mesh.VertexColor = Vector3.new(chromaColor.R, chromaColor.G, chromaColor.B)
                    else
                        item.Handle.Color = chromaColor
                    end
                end
            end
        end
    end
end)

-- Спуфинг визуального инвентаря в GUI MM2
local function SpoofInventoryUI()
    if not _G.ModifyInventoryUI then return end
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return end
    
    local mainGui = pGui:FindFirstChild("MainGUI") or pGui:FindFirstChild("ScreenGui")
    if mainGui then
        local invFrame = mainGui:FindFirstChild("Inventory", true) or mainGui:FindFirstChild("Weapons", true)
        if invFrame then
            local container = invFrame:FindFirstChild("Container", true) or invFrame:FindFirstChild("Items", true)
            if container then
                -- Визуально проставляем скины в сетке инвентаря
                for _, skinName in ipairs({_G.SelectedKnifeSkin, _G.SelectedGunSkin}) do
                    if not container:FindFirstChild("Fake_" .. skinName) then
                        local fakeCard = Instance.new("Frame")
                        fakeCard.Name = "Fake_" .. skinName
                        fakeCard.Size = UDim2.new(0, 75, 0, 75)
                        fakeCard.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                        fakeCard.Parent = container
                        
                        local title = Instance.new("TextLabel", fakeCard)
                        title.Size = UDim2.new(1, 0, 0, 20)
                        title.Position = UDim2.new(0, 0, 1, -20)
                        title.Text = skinName
                        title.TextColor3 = Color3.fromRGB(255, 215, 0)
                        title.TextSize = 10
                        title.BackgroundTransparency = 1
                        
                        Instance.new("UICorner", fakeCard).CornerRadius = UDim.new(0, 6)
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if _G.ModifyInventoryUI then
        pcall(SpoofInventoryUI)
    end
end)

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

