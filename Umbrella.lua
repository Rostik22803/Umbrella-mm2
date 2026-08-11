-- ====================================================================
-- MM2 WEAPON & SKIN SPAWNER / AUTO-EQUIPPER (Client-side Testing)
-- ====================================================================
-- Инструкция по настройке:
-- Укажите названия или ID скинов, которые должны применяться к оружию.
-- Модели и текстуры подтягиваются из ReplicatedStorage.Database или 
-- системных ресурсов MM2.

local CONFIG = {
    -- Включить автовыдачу при получении роли Murderer/Sheriff
    AutoGiveOnRole = true,
    
    -- Названия скинов для Ножа и Пистолета (примеры: "Corrupt", "Candy", "Harvester", "Icebreaker", "Chromaguns" и т.д.)
    KnifeSkin = "Corrupt", 
    GunSkin = "Luger",
    
    -- Уведомления в консоли/чате
    DebugMode = true
}

-- Ссылки на сервисы Roblox
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Вспомогательная функция логирования
local function log(message)
    if CONFIG.DebugMode then
        print("[MM2 Spawner]: " .. tostring(message))
    end
end

-- ====================================================================
-- ФУНКЦИИ РАБОТЫ СО СКИНАМИ И ПРЕДМЕТАМИ
-- ====================================================================

-- Поиск базовой модели предмета (Knife / Gun) или шаблона из ReplicatedStorage
local function getBaseTool(toolTypeName)
    -- MM2 хранит шаблоны или в ReplicatedStorage.Tools / Database / Assets
    local possiblePaths = {
        ReplicatedStorage:FindFirstChild("Tools"),
        ReplicatedStorage:FindFirstChild("Database"),
        ReplicatedStorage:FindFirstChild("Assets"),
        ReplicatedStorage
    }

    for _, container in ipairs(possiblePaths) do
        if container then
            local tool = container:FindFirstChild(toolTypeName, true)
            if tool and tool:IsA("Tool") then
                return tool:Clone()
            end
        end
    end

    -- Если шаблон не найден в ReplicatedStorage, создаем базовый Tool с рукояткой (Fallback)
    log("Предупреждение: Оригинальный шаблон " .. toolTypeName .. " не найден в ReplicatedStorage. Создание стандартного Tool.")
    local fallbackTool = Instance.new("Tool")
    fallbackTool.Name = toolTypeName
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 2, 1)
    handle.Parent = fallbackTool

    return fallbackTool
end

-- Применение скина к клонированному Tool
local function applySkinToTool(tool, skinName)
    if not tool or not skinName then return end

    -- Ищем модель/текстуру скина в базе данных предметов MM2
    local database = ReplicatedStorage:FindFirstChild("Database") or ReplicatedStorage:FindFirstChild("Items")
    local skinData = nil

    if database then
        skinData = database:FindFirstChild(skinName, true)
    end

    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")

    if skinData then
        log("Применяем скин: " .. skinName .. " к " .. tool.Name)
        
        -- Если у скина есть собственная Mesh-модель
        local meshModel = skinData:FindFirstChildWhichIsA("SpecialMesh") or skinData:FindFirstChildWhichIsA("MeshPart")
        if meshModel and handle then
            if meshModel:IsA("SpecialMesh") then
                local currentMesh = handle:FindFirstChildWhichIsA("SpecialMesh") or Instance.new("SpecialMesh", handle)
                currentMesh.MeshId = meshModel.MeshId
                currentMesh.TextureId = meshModel.TextureId
                currentMesh.Scale = meshModel.Scale
            end
        end
        
        -- Если у скина есть кастомная текстура
        if skinData:FindFirstChild("TextureId") and handle:IsA("MeshPart") then
            handle.TextureID = skinData.TextureId.Value
        end
    else
        log("Скин '" .. skinName .. "' не найден в базе данных MM2. Оружие создано с базовой моделью.")
    end

    -- Называем инструмент соответственно скину для удобства в инвентаре
    tool.Name = skinName ~= "" and skinName or tool.Name
end

-- Создание и помещение предмета в Backpack игрока
local function spawnItem(toolType, skinName)
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then
        log("Ошибка: Backpack не найден.")
        return
    end

    -- Проверка, нет ли уже такого оружия в инвентаре
    if backpack:FindFirstChild(skinName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(skinName)) then
        log("Предмет " .. skinName .. " уже находится в инвентаре.")
        return
    end

    -- Создаем предмет и настраиваем скин
    local tool = getBaseTool(toolType)
    applySkinToTool(tool, skinName)

    -- Помещаем предмет в Backpack
    tool.Parent = backpack
    log("Успешно выдан предмет: " .. tool.Name .. " в Backpack!")
end

-- ====================================================================
-- АВТОМАТИЧЕСКАЯ ВЫДАЧА ПО РОЛИ (Murderer / Sheriff)
-- ====================================================================

local function checkAndGiveRoleWeapons()
    -- Поиск роли игрока в PlayerGui, PlayerData или атрибутах персонажа MM2
    local playerData = LocalPlayer:FindFirstChild("PlayerData") or ReplicatedStorage:FindFirstChild("PlayerData")
    local role = nil

    -- Способ 1: Прямая проверка атрибутов персонажа/игрока
    if LocalPlayer:FindFirstChild("Role") then
        role = LocalPlayer.Role.Value
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Role") then
        role = LocalPlayer.Character.Role.Value
    end

    -- Способ 2: Проверка элементов GUI роли (стандарт MM2)
    if not role and LocalPlayer:FindFirstChild("PlayerGui") then
        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        if mainGui and mainGui:FindFirstChild("Game") and mainGui.Game:FindFirstChild("RoleExtra") then
            local roleLabel = mainGui.Game.RoleExtra:FindFirstChild("Role")
            if roleLabel and roleLabel.Visible then
                role = roleLabel.Text
            end
        end
    end

    -- Если роль определена — выдаем соответствующее оружие
    if role == "Murderer" or role == "Убийца" then
        log("Обнаружена роль: Murderer! Выдаем нож: " .. CONFIG.KnifeSkin)
        spawnItem("Knife", CONFIG.KnifeSkin)
    elseif role == "Sheriff" or role == "Hero" or role == "Шериф" then
        log("Обнаружена роль: Sheriff! Выдаем пистолет: " .. CONFIG.GunSkin)
        spawnItem("Gun", CONFIG.GunSkin)
    end
end

-- ====================================================================
-- ИНИЦИАЛИЗАЦИЯ И ИВЕНТЫ
-- ====================================================================

-- Выдача при запуске скрипта (для ручного тестирования)
spawnItem("Knife", CONFIG.KnifeSkin)
spawnItem("Gun", CONFIG.GunSkin)

-- Отслеживание спавна персонажа и обновления раундов
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    task.wait(1) -- Задержка для загрузки раунда MM2
    
    if CONFIG.AutoGiveOnRole then
        checkAndGiveRoleWeapons()
    end
end)

-- Циклическая проверка роли во время раунда (если роль выдается не сразу)
if CONFIG.AutoGiveOnRole then
    task.spawn(function()
        while task.wait(2) do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                checkAndGiveRoleWeapons()
            end
        end
    end)
end

log("Скрипт MM2 Weapon Spawner успешно запущен!")
