--[[
    ========================================================================
    UMBRELLA CORPORATION — MM2 HVH SUPREMACY
    Module: Visuals (ESP, Chams, Crosshair, Skybox, Trails, Chinese Hat)
    ========================================================================
--]]

local Visuals = {}
local Umbrella = _G.Umbrella or {}
local Core = Umbrella.Core or {}
local UI = Umbrella.UI or {}
local Services = Core.Services or {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    Lighting = game:GetService("Lighting")
}
local Players = Services.Players
local LocalPlayer = Core.LocalPlayer or Players.LocalPlayer
local Camera = Core.Camera or workspace.CurrentCamera
local UserInputService = Services.UserInputService
local RunService = Services.RunService
local TweenService = Services.TweenService
local ColorPresets = Core.ColorPresets or {}
local ChamColorPresets = ColorPresets
local RopeColorPresets = ColorPresets
local UpdateRoleColors = Core.UpdateRoleColors or function() end
local Lighting = Core.Services.Lighting or game:GetService("Lighting")
local SoundService = Core.Services.SoundService or game:GetService("SoundService")

local ScreenGui = UI.ScreenGui
local HeaderLine = UI.HeaderLine
local UIStrokeMain = UI.UIStrokeMain
local AwallIndicator = UI.AwallIndicator
local UmbrellaCircles = UI.UmbrellaCircles or {}
local AllDropdownStrokes = UI.AllDropdownStrokes or {}
local AllSliderFills = UI.AllSliderFills or {}
local AllToggles = UI.AllToggles or {}
local AllSectionTitles = UI.AllSectionTitles or {}
local AllSectionScrollbars = UI.AllSectionScrollbars or {}
local Tabs = UI.Tabs or {}
local TabButtons = UI.TabButtons or {}
local CurrentActiveTab = UI.CurrentActiveTab or "Main"

local crosshairSpinAngle = 0
local function CheckAwallRay(...)
    if Umbrella.Combat and Umbrella.Combat.CheckAwallRay then
        return Umbrella.Combat.CheckAwallRay(...)
    end
    return false, 999
end
local function UpdateHeadDots() end

local Lighting = Services.Lighting

local GetRole = Core.GetRole or function() return "Innocent" end
local RoleColors = Core.RoleColors or {}
local ColorPresets = UI.ColorPresets or {}
local GetThemeAccentColor = UI.GetThemeAccentColor or function() return Color3.fromRGB(220, 35, 45) end
local AwallIndicator = UI.AwallIndicator

Visuals.FootRopeTrail = nil
Visuals.CharacterTrail = nil

-- 1. FOV Circle & Crosshair Drawing Setup

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

local chDotCorner = Instance.new("UICorner", CrosshairCenter)
chDotCorner.CornerRadius = UDim.new(1, 0)

local chDotStroke = Instance.new("UIStroke", CrosshairCenter)
chDotStroke.Thickness = 1
chDotStroke.Color = Color3.fromRGB(0, 0, 0)
chDotStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
chDotStroke.Enabled = false

local chBars = {}
local chBarCorners = {}
local chBarStrokes = {}
for i = 1, 4 do
    local bar = Instance.new("Frame")
    bar.Parent = CrosshairCenter
    bar.BorderSizePixel = 0
    bar.BackgroundColor3 = Color3.fromRGB(255, 45, 55)
    
    local c = Instance.new("UICorner", bar)
    c.CornerRadius = UDim.new(0, 0)
    chBarCorners[i] = c
    
    local s = Instance.new("UIStroke", bar)
    s.Thickness = 1
    s.Color = Color3.fromRGB(0, 0, 0)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Enabled = false
    chBarStrokes[i] = s
    
    chBars[i] = bar
end

local CrosshairRing = Instance.new("Frame")
CrosshairRing.Name = "CrosshairRing"
CrosshairRing.Parent = CrosshairCenter
CrosshairRing.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairRing.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairRing.BackgroundTransparency = 1
CrosshairRing.BorderSizePixel = 0
CrosshairRing.Visible = false
Instance.new("UICorner", CrosshairRing).CornerRadius = UDim.new(1, 0)

local CrosshairRingStroke = Instance.new("UIStroke")
CrosshairRingStroke.Parent = CrosshairRing
CrosshairRingStroke.Color = Color3.fromRGB(255, 45, 55)
CrosshairRingStroke.Thickness = 1.5
CrosshairRingStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border





-- 2. Chams Helpers
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


-- 3. Crosshair Logic & Drawing Render Loop
local function GetCrosshairColor()
    if _G.SelectedCrosshairColor == "Rainbow RGB" then
        local hue = (tick() * 0.6) % 1
        return Color3.fromHSV(hue, 1, 1)
    elseif _G.SelectedCrosshairColor == "Pulsing Glow" then
        local p = (math.sin(tick() * 5) + 1) * 0.5
        return Color3.fromRGB(math.floor(180 + 75 * p), math.floor(30 + 30 * p), math.floor(40 + 40 * p))
    elseif _G.SelectedCrosshairColor == "Theme Match" then
        return GetThemeAccentColor()
    else
        return ColorPresets[_G.SelectedCrosshairColor] or RopeColorPresets[_G.SelectedCrosshairColor] or Color3.fromRGB(220, 35, 45)
    end
end

local function UpdateCrosshair()
    if not _G.CustomCrosshairActive then
        CrosshairCenter.Visible = false
        return
    end
    CrosshairCenter.Visible = true
    
    -- Позиция (Центр экрана или привязка к мыши)
    if _G.CrosshairFollowMouse then
        local mPos = UserInputService:GetMouseLocation()
        CrosshairCenter.Position = UDim2.new(0, mPos.X, 0, mPos.Y)
    else
        CrosshairCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
    end
    
    local style = _G.CrosshairStyle or "Classic (+)"
    
    -- Вращение / Spin
    if _G.CrosshairSpin then
        local spd = _G.CrosshairSpinSpeed or 5
        crosshairSpinAngle = (crosshairSpinAngle + spd * 0.8) % 360
        CrosshairCenter.Rotation = crosshairSpinAngle
    elseif style == "X-Cross (x)" then
        CrosshairCenter.Rotation = 45
    else
        CrosshairCenter.Rotation = 0
    end
    
    -- Базовый цвет и реакция на прицеливание в противника (Target Lock)
    local col = GetCrosshairColor()
    if _G.CrosshairTargetColor then
        local checkPos = _G.CrosshairFollowMouse and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
        local unitRay = Camera:ViewportPointToRay(checkPos.X, checkPos.Y)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        if LocalPlayer.Character then
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
        end
        local hitRes = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)
        if hitRes and hitRes.Instance and hitRes.Instance.Parent then
            local hitChar = hitRes.Instance.Parent
            if hitChar:FindFirstChildOfClass("Humanoid") then
                local p = Players:GetPlayerFromCharacter(hitChar)
                if p and p ~= LocalPlayer then
                    col = Color3.fromRGB(40, 255, 90)
                end
            end
        end
    end
    
    -- Динамический зазор (Dynamic Gap & Movement Spread)
    local gap = _G.CrosshairGap or 4
    if _G.CrosshairDynamicSpread and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity or hrp.Velocity
            local spd = Vector3.new(vel.X, 0, vel.Z).Magnitude
            local factor = math.clamp(spd / 16, 0, 1.5)
            if math.abs(vel.Y) > 2 then factor = factor + 0.6 end
            gap = gap + math.floor(factor * (_G.CrosshairSpreadAmount or 6))
        end
    end
    if _G.CrosshairPulse then
        gap = gap + math.floor((math.sin(tick() * 6) + 1) * 1.5)
    end
    
    local size = _G.CrosshairSize or 8
    local thick = _G.CrosshairThickness or 2
    local trans = _G.CrosshairTransparency or 0
    local rounded = _G.CrosshairRoundedBars or false
    
    -- Контур (Outline)
    local outlineOn = _G.CrosshairOutline == true
    local outThick = _G.CrosshairOutlineThickness or 1
    local outCol = Color3.fromRGB(0, 0, 0)
    if _G.CrosshairOutlineColor == "Dark Gray" then
        outCol = Color3.fromRGB(40, 40, 45)
    elseif _G.CrosshairOutlineColor == "Deep Crimson" then
        outCol = Color3.fromRGB(90, 10, 20)
    elseif _G.CrosshairOutlineColor == "Inverse" then
        outCol = Color3.fromRGB(255 - math.floor(col.R * 255), 255 - math.floor(col.G * 255), 255 - math.floor(col.B * 255))
    end
    
    -- Центральная точка (Center Dot)
    local dotSize = _G.CrosshairDotSize or 4
    local showDot = (_G.CrosshairDot ~= false) or (style == "Dot Only")
    CrosshairCenter.Size = UDim2.new(0, dotSize, 0, dotSize)
    CrosshairCenter.BackgroundColor3 = col
    CrosshairCenter.BackgroundTransparency = showDot and trans or 1
    chDotCorner.CornerRadius = (_G.CrosshairDotShape == "Square") and UDim.new(0, 0) or UDim.new(1, 0)
    chDotStroke.Enabled = showDot and outlineOn
    chDotStroke.Thickness = outThick
    chDotStroke.Color = outCol
    chDotStroke.Transparency = trans
    
    -- Видимость линий по стилю
    local showBars = (style ~= "Dot Only" and style ~= "Circle Ring")
    local showTop = showBars and (style ~= "T-Shape") and (_G.CrosshairTopLine ~= false)
    local showBottom = showBars and (style ~= "Arrow (^)")
    local showLeft = showBars
    local showRight = showBars
    
    local halfThick = math.floor(thick / 2)
    
    -- Up
    chBars[1].Visible = showTop
    chBars[1].Size = UDim2.new(0, thick, 0, size)
    chBars[1].Position = UDim2.new(0.5, -halfThick, 0, -(gap + size))
    -- Down
    chBars[2].Visible = showBottom
    chBars[2].Size = UDim2.new(0, thick, 0, size)
    chBars[2].Position = UDim2.new(0.5, -halfThick, 1, gap)
    -- Left
    chBars[3].Visible = showLeft
    chBars[3].Size = UDim2.new(0, size, 0, thick)
    chBars[3].Position = UDim2.new(0, -(gap + size), 0.5, -halfThick)
    -- Right
    chBars[4].Visible = showRight
    chBars[4].Size = UDim2.new(0, size, 0, thick)
    chBars[4].Position = UDim2.new(1, gap, 0.5, -halfThick)
    
    for i = 1, 4 do
        chBars[i].BackgroundColor3 = col
        chBars[i].BackgroundTransparency = trans
        chBarCorners[i].CornerRadius = rounded and UDim.new(0.5, 0) or UDim.new(0, 0)
        chBarStrokes[i].Enabled = outlineOn
        chBarStrokes[i].Thickness = outThick
        chBarStrokes[i].Color = outCol
        chBarStrokes[i].Transparency = trans
    end
    
    -- Кольцо (Circle Ring)
    local ringActive = (_G.CrosshairRingActive == true) or (style == "Circle Ring") or (style == "Cross + Circle")
    CrosshairRing.Visible = ringActive
    if ringActive then
        local rDiam = (_G.CrosshairRingRadius or 14) * 2
        CrosshairRing.Size = UDim2.new(0, rDiam, 0, rDiam)
        CrosshairRingStroke.Color = col
        CrosshairRingStroke.Thickness = _G.CrosshairRingThickness or 1.5
        CrosshairRingStroke.Transparency = trans
    end
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
    
    -- Обновление прицела и точек на голове
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



-- 4. Weapon Chams & Dropped Gun ESP
-- 2. WEAPON CHAMS
task.spawn(function()
    while true do
        task.wait(0.3)
        if _G.WeaponChamsActive then
            local isBox = (_G.WeaponChamsStyle == "Boxes")
            local isOutline = (_G.WeaponChamsStyle == "Outline Only")
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
            local isBox = (_G.DroppedGunChamsStyle == "Boxes")
            local isOutline = (_G.DroppedGunChamsStyle == "Outline Only")
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


-- 5. Player Chams & Self Chams
-- Поток PLAYERS CHAMS
task.spawn(function()
    while true do
        task.wait(0.25)
        if _G.ChamsActive then
            local isBox = (_G.PlayerChamsStyle == "Boxes")
            local isOutline = (_G.PlayerChamsStyle == "Outline Only")
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
            local isBox = (_G.SelfChamsStyle == "Boxes")
            local isOutline = (_G.SelfChamsStyle == "Outline Only")
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


-- 6. World, Atmosphere, Skybox, Chinese Hat, Trails, Footsteps & Camera FX
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
    Visuals.FootRopeTrail = FootRopeTrail
    _G.FootRopeTrail = FootRopeTrail
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
    Visuals.CharacterTrail = CharacterTrail
    _G.CharacterTrail = CharacterTrail
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



Visuals.ClearAllChams = ClearAllChams
Visuals.ApplyHighlightCham = ApplyHighlightCham
Visuals.ApplyBoxCham = ApplyBoxCham
Visuals.ApplyChineseHat = ApplyChineseHat
Visuals.RemoveChineseHat = RemoveChineseHat
Visuals.ApplyFootRope = ApplyFootRope
Visuals.RemoveFootRope = RemoveFootRope
Visuals.ApplyCharacterTrail = ApplyCharacterTrail
Visuals.RemoveCharacterTrail = RemoveCharacterTrail
Visuals.TriggerScreenFlash = TriggerScreenFlash
Visuals.ApplySkyPreset = ApplySkyPreset
Visuals.RemoveSkyPreset = RemoveSkyPreset
Visuals.ApplyAtmosphere = ApplyAtmosphere
Visuals.UpdateColorCorrection = UpdateColorCorrection
Visuals.UpdateBlur = UpdateBlur

Visuals.OriginalLighting = OriginalLighting
return Visuals
