-- ====================================================================
-- ADVANCED MM2 SKIN CHANGER WITH GUI MENU
-- ====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Текущие выбранные скины
local SelectedSkins = {
    Knife = nil,
    Gun = nil
}

-- Поиск базы предметов MM2
local Database = ReplicatedStorage:FindFirstChild("Database") or ReplicatedStorage:FindFirstChild("Items")

-- ====================================================================
-- ФУНКЦИИ ПОДМЕНЫ СКИНОВ (SKIN CHANGER LOGIC)
-- ====================================================================

-- Извлечение MeshId и TextureId из предмета в базе
local function getSkinVisuals(skinName, weaponType)
    if not Database then return nil, nil end
    
    local category = Database:FindFirstChild(weaponType .. "s") or Database:FindFirstChild(weaponType) or Database
    local skinItem = category:FindFirstChild(skinName, true) or Database:FindFirstChild(skinName, true)
    
    if not skinItem then return nil, nil end
    
    local meshId, textureId = nil, nil
    
    -- Ищем модель / текстуру в объекте скина
    local mesh = skinItem:FindFirstChildWhichIsA("SpecialMesh", true)
    if mesh then
        meshId = mesh.MeshId
        textureId = mesh.TextureId
    end
    
    if not textureId and skinItem:FindFirstChild("TextureId") then
        textureId = skinItem.TextureId.Value
    end
    
    return meshId, textureId
end

-- Применение скина к инструменту (Tool)
local function applySkinToTool(tool, skinName)
    if not tool or not skinName then return end
    
    local isKnife = tool.Name == "Knife" or tool:FindFirstChild("Stab") or tool:FindFirstChild("Lock")
    local isGun = tool.Name == "Gun" or tool:FindFirstChild("Shoot")
    
    local weaponType = isKnife and "Knife" or (isGun and "Gun" or nil)
    if not weaponType then return end
    
    local meshId, textureId = getSkinVisuals(skinName, weaponType)
    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
    
    if handle then
        if handle:IsA("MeshPart") then
            if textureId and textureId ~= "" then handle.TextureID = textureId end
            if meshId and meshId ~= "" then handle.MeshId = meshId end
        else
            local specialMesh = handle:FindFirstChildWhichIsA("SpecialMesh") or Instance.new("SpecialMesh", handle)
            if meshId and meshId ~= "" then specialMesh.MeshId = meshId end
            if textureId and textureId ~= "" then specialMesh.TextureId = textureId end
        end
    end
end

-- Хук/отслеживание появившегося оружия у игрока
local function hookCharacter(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.05)
            if child.Name == "Knife" and SelectedSkins.Knife then
                applySkinToTool(child, SelectedSkins.Knife)
            elseif child.Name == "Gun" and SelectedSkins.Gun then
                applySkinToTool(child, SelectedSkins.Gun)
            end
        end
    end)
end

if LocalPlayer.Character then hookCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookCharacter)

-- Подмена в Backpack
local function updateBackpackSkins()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                if tool.Name == "Knife" and SelectedSkins.Knife then
                    applySkinToTool(tool, SelectedSkins.Knife)
                elseif tool.Name == "Gun" and SelectedSkins.Gun then
                    applySkinToTool(tool, SelectedSkins.Gun)
                end
            end
        end
    end
end

-- ====================================================================
-- ИНТЕРФЕЙС (GUI MENU CREATION)
-- ====================================================================

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2SkinChangerGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MM2 Skin Changer"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Табы (Knives / Guns)
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -30, 0, 35)
TabFrame.Position = UDim2.new(0, 15, 0, 45)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local KnifeTab = Instance.new("TextButton")
KnifeTab.Size = UDim2.new(0.48, 0, 1, 0)
KnifeTab.Position = UDim2.new(0, 0, 0, 0)
KnifeTab.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
KnifeTab.Text = "🔪 Ножи (Knives)"
KnifeTab.TextColor3 = Color3.fromRGB(255, 255, 255)
KnifeTab.Font = Enum.Font.GothamMedium
KnifeTab.TextSize = 14
KnifeTab.Parent = TabFrame
Instance.new("UICorner", KnifeTab).CornerRadius = UDim.new(0, 6)

local GunTab = Instance.new("TextButton")
GunTab.Size = UDim2.new(0.48, 0, 1, 0)
GunTab.Position = UDim2.new(0.52, 0, 0, 0)
GunTab.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
GunTab.Text = "🔫 Пистолеты (Guns)"
GunTab.TextColor3 = Color3.fromRGB(180, 180, 180)
GunTab.Font = Enum.Font.GothamMedium
GunTab.TextSize = 14
GunTab.Parent = TabFrame
Instance.new("UICorner", GunTab).CornerRadius = UDim.new(0, 6)

-- Скролл со скинами
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -30, 1, -100)
Scroll.Position = UDim2.new(0, 15, 0, 90)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 5
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = MainFrame

local UIGrid = Instance.new("UIGridLayout")
UIGrid.CellSize = UDim2.new(0, 135, 0, 40)
UIGrid.CellPadding = UDim2.new(0, 10, 0, 10)
UIGrid.Parent = Scroll

UIGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIGrid.AbsoluteContentSize.Y + 10)
end)

-- Популярный список скинов для быстрого выбора (на случай если база MM2 зашифрована)
local PresetSkins = {
    Knives = {"Corrupt", "Candy", "Harvester", "Icebreaker", "Chroma Heat", "Bat", "Nikilis Scythe", "Makeshift", "Default Knife"},
    Guns = {"Luger", "Chroma Luger", "Ocean", "Makeshift", "Laser", "Icebeam", "Icepiercer", "Blaster", "Default Gun"}
}

local currentCategory = "Knives"

local function loadSkins(category)
    -- Очистка
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local skinList = PresetSkins[category] or {}

    for _, skinName in ipairs(skinList) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 135, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
        btn.Text = skinName
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = Scroll
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            if category == "Knives" then
                SelectedSkins.Knife = skinName
                print("[SkinChanger]: Выбран нож -> " .. skinName)
            else
                SelectedSkins.Gun = skinName
                print("[SkinChanger]: Выбран пистолет -> " .. skinName)
            end
            updateBackpackSkins()
        end)
    end
end

-- Переключение табов
KnifeTab.MouseButton1Click:Connect(function()
    currentCategory = "Knives"
    KnifeTab.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    KnifeTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    GunTab.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    GunTab.TextColor3 = Color3.fromRGB(180, 180, 180)
    loadSkins("Knives")
end)

GunTab.MouseButton1Click:Connect(function()
    currentCategory = "Guns"
    GunTab.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    GunTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    KnifeTab.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    KnifeTab.TextColor3 = Color3.fromRGB(180, 180, 180)
    loadSkins("Guns")
end)

-- Перетаскивание окна (Drag)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Загрузка по умолчанию
loadSkins("Knives")

-- Горячая клавиша открытия/закрытия меню (Клавиша 'K' или кнопка)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
