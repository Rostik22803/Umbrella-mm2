--[[
    ========================================================================
    UMBRELLA CORPORATION — MM2 HVH SUPREMACY
    Module: Weapons (Custom Weapon Skins, Models, Auras, Lightsaber)
    ========================================================================
--]]

local Weapons = {}
local Umbrella = _G.Umbrella or {}
local Core = Umbrella.Core or {}
local Services = Core.Services or {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService")
}
local Players = Services.Players
local LocalPlayer = Core.LocalPlayer or Players.LocalPlayer
local RunService = Services.RunService
local TweenService = Services.TweenService
local ColorPresets = Core.ColorPresets or {}
local ChamColorPresets = ColorPresets


-- 1. Custom 3D Character Models Engine
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
                
                -- Configure all parts: Massless = true, CanCollide = false, CanTouch = false, CanQuery = false
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



-- 2. Custom Weapons Engine (Knife & Gun skins, 3D models, FX)
------------------------------------------------------------------------
-- CUSTOM WEAPONS ENGINE (KNIFE & GUN SKINS / 3D MODELS / FX)
------------------------------------------------------------------------
local KnifePresets = {
    ["Default"] = nil,
    ["Corrupt (Ancient Black/Blue)"] = {
        MeshId = "rbxassetid://156092238",
        TextureId = "",
        Scale = Vector3.new(1.05, 1.05, 1.05),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(0, 160, 255)
    },
    ["Harvester (Scythe Ancient)"] = {
        MeshId = "rbxassetid://168119698",
        TextureId = "rbxassetid://168119736",
        Scale = Vector3.new(1.1, 1.1, 1.1),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(40, 40, 45)
    },
    ["Batwing (Ancient)"] = {
        MeshId = "rbxassetid://168119698",
        TextureId = "rbxassetid://168119736",
        Scale = Vector3.new(1.15, 1.15, 1.15),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(160, 20, 240)
    },
    ["Elderwood Scythe (Ancient)"] = {
        MeshId = "rbxassetid://168119698",
        TextureId = "rbxassetid://168119736",
        Scale = Vector3.new(1.2, 1.2, 1.2),
        Material = Enum.Material.Wood,
        Color = Color3.fromRGB(180, 50, 20)
    },
    ["Icebreaker (Ancient)"] = {
        MeshId = "rbxassetid://121944778",
        TextureId = "rbxassetid://161313071",
        Scale = Vector3.new(1.2, 1.2, 1.2),
        Material = Enum.Material.Glass,
        Color = Color3.fromRGB(160, 230, 255)
    },
    ["Candleflame (Godly)"] = {
        MeshId = "rbxassetid://105333894",
        TextureId = "rbxassetid://105334003",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(255, 120, 30)
    },
    ["Swirly Blade (Godly)"] = {
        MeshId = "rbxassetid://121944778",
        TextureId = "rbxassetid://157019835",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(255, 50, 150)
    },
    ["Chroma Fang"] = {
        MeshId = "rbxassetid://117500241",
        TextureId = "rbxassetid://117500388",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        IsChroma = true
    },
    ["Chroma Heat"] = {
        MeshId = "rbxassetid://105333894",
        TextureId = "rbxassetid://105334003",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        IsChroma = true
    },
    ["Chroma Tides"] = {
        MeshId = "rbxassetid://156092238",
        TextureId = "rbxassetid://156092253",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        IsChroma = true
    },
    ["Chroma Deathshard"] = {
        MeshId = "rbxassetid://118269783",
        TextureId = "rbxassetid://118269752",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        IsChroma = true
    },
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
    ["Elderwood Revolver (Ancient)"] = {
        MeshId = "rbxassetid://97886770",
        TextureId = "",
        Scale = Vector3.new(1.15, 1.15, 1.15),
        Material = Enum.Material.Wood,
        Color = Color3.fromRGB(180, 60, 20)
    },
    ["Harvester Gun (Ancient)"] = {
        MeshId = "rbxassetid://97886770",
        TextureId = "",
        Scale = Vector3.new(1.1, 1.1, 1.1),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(45, 45, 50)
    },
    ["Ocean Gun (Godly)"] = {
        MeshId = "rbxassetid://95356090",
        TextureId = "rbxassetid://95387789",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Glass,
        Color = Color3.fromRGB(0, 180, 255)
    },
    ["Waves Gun (Godly)"] = {
        MeshId = "rbxassetid://95356090",
        TextureId = "rbxassetid://95387789",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(30, 255, 200)
    },
    ["Iceblaster (Ancient)"] = {
        MeshId = "rbxassetid://97886770",
        TextureId = "",
        Scale = Vector3.new(1.1, 1.1, 1.1),
        Material = Enum.Material.Glass,
        Color = Color3.fromRGB(170, 240, 255)
    },
    ["Chroma Laser"] = {
        MeshId = "rbxassetid://18265627",
        TextureId = "rbxassetid://18265614",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        IsChroma = true
    },
    ["Chroma Heat Gun"] = {
        MeshId = "rbxassetid://95356090",
        TextureId = "rbxassetid://95387789",
        Scale = Vector3.new(1, 1, 1),
        Material = Enum.Material.Neon,
        IsChroma = true
    },
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

-- ========================================================================
-- CUSTOM 3D WEAPON MODELS ENGINE (AWP, AK-47, M4A1, DEAGLE, SCYTHE, ETC.)
-- ========================================================================
local CustomGunPresets = {
    ["AK-47 (Assault Rifle)"] = {
        Name = "AK-47 (Assault Rifle)",
        AssetIds = { "rbxassetid://5182729442", "rbxassetid://5008064682" },
        BaseScale = 1.0,
        RotationOffset = CFrame.Angles(0, math.rad(-90), 0)
    },
    ["AWP (Dragon Lore / Sniper)"] = {
        Name = "AWP (Dragon Lore / Sniper)",
        AssetIds = { "rbxassetid://5181507328", "rbxassetid://11006944635" },
        BaseScale = 1.0,
        RotationOffset = CFrame.Angles(0, math.rad(-90), 0)
    },
    ["M4A1 (Tactical Carbine)"] = {
        Name = "M4A1 (Tactical Carbine)",
        AssetIds = { "rbxassetid://2778873048", "rbxassetid://134207834008981" },
        BaseScale = 1.0,
        RotationOffset = CFrame.Angles(0, math.rad(-90), 0)
    },
    ["Desert Eagle (.50 Action Express)"] = {
        Name = "Desert Eagle (.50 Action Express)",
        AssetIds = { "rbxassetid://15651280815", "rbxassetid://17767820926" },
        BaseScale = 0.9,
        RotationOffset = CFrame.Angles(0, math.rad(-90), 0)
    },
    ["SPAS-12 (Combat Shotgun)"] = {
        Name = "SPAS-12 (Combat Shotgun)",
        AssetIds = { "rbxassetid://81807416954084", "rbxassetid://90819734964360" },
        BaseScale = 1.0,
        RotationOffset = CFrame.Angles(0, math.rad(-90), 0)
    },
    ["RPG-7 (Rocket Launcher)"] = {
        Name = "RPG-7 (Rocket Launcher)",
        AssetIds = { "rbxassetid://16630906452", "rbxassetid://140655446" },
        BaseScale = 1.0,
        RotationOffset = CFrame.Angles(0, math.rad(-90), 0)
    },
    ["Glock-18 (Automatic)"] = {
        Name = "Glock-18 (Automatic)",
        IsMesh = true,
        MeshId = "rbxassetid://430045961",
        TextureId = "rbxassetid://430046045",
        Scale = Vector3.new(0.9, 0.9, 0.9),
        Material = Enum.Material.Metal
    },
    ["Minigun (Heavy Vulcan)"] = {
        Name = "Minigun (Heavy Vulcan)",
        AssetIds = { "rbxassetid://10154175130", "rbxassetid://590594953" },
        BaseScale = 1.0,
        RotationOffset = CFrame.Angles(0, math.rad(-90), 0)
    },
    ["Alien Raygun"] = {
        Name = "Alien Raygun",
        IsMesh = true,
        MeshId = "rbxassetid://18265627",
        TextureId = "rbxassetid://18265614",
        Scale = Vector3.new(1.1, 1.1, 1.1),
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(0, 255, 255)
    }
}

local CustomMeleePresets = {
    ["Karambit (Fade / Doppler)"] = {
        Name = "Karambit (Fade / Doppler)",
        AssetIds = { "rbxassetid://13290314307", "rbxassetid://345265708" },
        BaseScale = 0.95,
        RotationOffset = CFrame.Angles(0, math.rad(-90), 0)
    },
    ["Butterfly Knife (Balisong)"] = {
        Name = "Butterfly Knife (Balisong)",
        AssetIds = { "rbxassetid://9207811853", "rbxassetid://5021484174" },
        BaseScale = 0.9,
        RotationOffset = CFrame.Angles(0, math.rad(-90), 0)
    },
    ["Muramasa Katana"] = {
        Name = "Muramasa Katana",
        IsMesh = true,
        MeshId = "rbxassetid://86297695",
        TextureId = "rbxassetid://86290910",
        Scale = Vector3.new(1.1, 1.1, 1.1),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(220, 30, 40)
    },
    ["Death Scythe (Grim Reaper)"] = {
        Name = "Death Scythe (Grim Reaper)",
        AssetIds = { "rbxassetid://2664535901", "rbxassetid://2943625227" },
        BaseScale = 1.1,
        RotationOffset = CFrame.Angles(0, math.rad(-90), 0)
    },
    ["Minecraft Diamond Sword"] = {
        Name = "Minecraft Diamond Sword",
        AssetIds = { "rbxassetid://7789318672", "rbxassetid://7004608388" },
        BaseScale = 1.0,
        RotationOffset = CFrame.Angles(0, math.rad(-90), 0)
    },
    ["Nordic Battle Axe"] = {
        Name = "Nordic Battle Axe",
        IsMesh = true,
        MeshId = "rbxassetid://1279013",
        TextureId = "rbxassetid://1279012",
        Scale = Vector3.new(1.1, 1.1, 1.1),
        Material = Enum.Material.Metal
    },
    ["Crowbar (Half-Life)"] = {
        Name = "Crowbar (Half-Life)",
        IsMesh = true,
        MeshId = "rbxassetid://46062744",
        TextureId = "rbxassetid://46062770",
        Scale = Vector3.new(1.0, 1.0, 1.0),
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(220, 40, 40)
    },
    ["Lightsaber (Neon Beam)"] = {
        Name = "Lightsaber (Neon Beam)",
        IsSpecial3D = "Lightsaber",
        Material = Enum.Material.Neon,
        Color = Color3.fromRGB(0, 255, 255)
    }
}

local CustomGunModelNames = {
    "AK-47 (Assault Rifle)",
    "AWP (Dragon Lore / Sniper)",
    "M4A1 (Tactical Carbine)",
    "Desert Eagle (.50 Action Express)",
    "SPAS-12 (Combat Shotgun)",
    "RPG-7 (Rocket Launcher)",
    "Glock-18 (Automatic)",
    "Minigun (Heavy Vulcan)",
    "Alien Raygun"
}

local CustomMeleeModelNames = {
    "Karambit (Fade / Doppler)",
    "Butterfly Knife (Balisong)",
    "Muramasa Katana",
    "Death Scythe (Grim Reaper)",
    "Minecraft Diamond Sword",
    "Nordic Battle Axe",
    "Crowbar (Half-Life)",
    "Lightsaber (Neon Beam)"
}

local KnifeModelNames = {
    "Corrupt (Ancient Black/Blue)",
    "Harvester (Scythe Ancient)",
    "Batwing (Ancient)",
    "Elderwood Scythe (Ancient)",
    "Icebreaker (Ancient)",
    "Candleflame (Godly)",
    "Swirly Blade (Godly)",
    "Chroma Fang",
    "Chroma Heat",
    "Chroma Tides",
    "Chroma Deathshard",
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
    "Chroma Luger (Animated RGB)",
    "Darkbringer Style (Void Glow)",
    "Lightbringer Style (Holy Glow)",
    "Elderwood Revolver (Ancient)",
    "Harvester Gun (Ancient)",
    "Ocean Gun (Godly)",
    "Waves Gun (Godly)",
    "Iceblaster (Ancient)",
    "Sci-Fi Laser Revolver",
    "Phaser (Plasma Gun)",
    "Sheriff .45 Revolver",
    "Chroma Laser",
    "Chroma Heat Gun",
    "Default"
}

local OriginalWeaponData = {}

local function BackupWeapon(tool)
    if not tool or OriginalWeaponData[tool] then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
    OriginalWeaponData[tool] = {
        Grip = tool.Grip,
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

local function ApplyWeaponGrip(tool)
    if not tool or not tool:IsA("Tool") then return end
    BackupWeapon(tool)
    local data = OriginalWeaponData[tool]
    local baseGrip = (data and data.Grip) or CFrame.new()
    
    if _G.CustomWeaponGripActive or _G.CustomGunGripActive then
        local pX = _G.WeaponOffsetX or _G.GunHandPosX or 0
        local pY = _G.WeaponOffsetY or _G.GunHandPosY or 0
        local pZ = _G.WeaponOffsetZ or _G.GunHandPosZ or 0
        local rX = _G.WeaponAnglePitch or _G.GunHandRotX or 0
        local rY = _G.WeaponAngleYaw or _G.GunHandRotY or 0
        local rZ = _G.WeaponAngleRoll or _G.GunHandRotZ or 0
        
        local posOffset = Vector3.new(pX, pY, pZ)
        local rotOffset = CFrame.Angles(
            math.rad(rX),
            math.rad(rY),
            math.rad(rZ)
        )
        tool.Grip = baseGrip * CFrame.new(posOffset) * rotOffset
    else
        tool.Grip = baseGrip
    end
end
local ApplyGunGrip = ApplyWeaponGrip

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

local LoadedWeaponCache = {}

local function LoadWeaponAsset(assetList)
    if not assetList then return nil end
    for _, assetUrl in ipairs(assetList) do
        if LoadedWeaponCache[assetUrl] then
            return LoadedWeaponCache[assetUrl]:Clone()
        end
        local success, objs = pcall(function()
            return game:GetObjects(assetUrl)
        end)
        if success and objs and #objs > 0 then
            local obj = objs[1]
            LoadedWeaponCache[assetUrl] = obj:Clone()
            return obj
        end
    end
    return nil
end

local function RemoveCustomWeaponVisual(tool)
    if not tool then return end
    local old = tool:FindFirstChild("Custom3DWeaponVisual")
    if old then old:Destroy() end
    local oldVis = tool:FindFirstChild("MM2_WeaponVisual")
    if oldVis then oldVis:Destroy() end
    local handle = tool:FindFirstChild("Handle")
    if handle then
        handle.Transparency = 0
        for _, ch in ipairs(handle:GetChildren()) do
            if ch:IsA("Decal") then ch.Transparency = 0 end
        end
    end
end

local function RestoreWeapon(tool)
    if not tool then return end
    RemoveCustomWeaponVisual(tool)
    
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
        if data.Grip then tool.Grip = data.Grip end
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

local function ApplyCustom3DWeapon(tool, preset, isKnife, scaleMult)
    if not tool then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    BackupWeapon(tool)
    
    -- Hide original weapon handle and decals
    handle.Transparency = 1
    for _, ch in ipairs(handle:GetChildren()) do
        if ch:IsA("Decal") then ch.Transparency = 1 end
    end
    
    local existingVisual = tool:FindFirstChild("Custom3DWeaponVisual")
    if existingVisual and existingVisual:GetAttribute("PresetKey") == preset.Name then
        return
    end
    
    if existingVisual then existingVisual:Destroy() end
    
    -- Special 3D: Lightsaber
    if preset.IsSpecial3D == "Lightsaber" then
        local model = Instance.new("Model")
        model.Name = "Custom3DWeaponVisual"
        model:SetAttribute("PresetKey", preset.Name)
        
        local hilt = Instance.new("Part")
        hilt.Name = "Hilt"
        hilt.Size = Vector3.new(0.25, 0.9, 0.25) * scaleMult
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
        blade.Size = Vector3.new(3.0 * scaleMult, 0.22 * scaleMult, 0.22 * scaleMult)
        blade.Material = Enum.Material.Neon
        local bladeCol = preset.Color or Color3.fromRGB(0, 255, 255)
        if _G.CustomWeaponColor ~= "Original" and ChamColorPresets[_G.CustomWeaponColor] then
            bladeCol = ChamColorPresets[_G.CustomWeaponColor]
        end
        blade.Color = bladeCol
        blade.CanCollide = false
        blade.CanTouch = false
        blade.CanQuery = false
        blade.Massless = true
        blade.CFrame = handle.CFrame * CFrame.new(0, 1.6 * scaleMult, 0) * CFrame.Angles(0, 0, math.rad(90))
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
        ApplyWeaponFX(tool, isKnife, blade)
        return
    end
    
    -- Special Mesh: If preset specifies a verified Type 4 Mesh (Glock, Muramasa, Axe, Crowbar, Raygun)
    if preset.IsMesh and preset.MeshId then
        local model = Instance.new("Model")
        model.Name = "Custom3DWeaponVisual"
        model:SetAttribute("PresetKey", preset.Name)
        
        local visPart = Instance.new("Part")
        visPart.Name = "VisualPart"
        visPart.Size = Vector3.new(1, 1, 1)
        visPart.CanCollide = false
        visPart.CanTouch = false
        visPart.CanQuery = false
        visPart.Massless = true
        visPart.Material = preset.Material or Enum.Material.Metal
        visPart.Color = preset.Color or Color3.fromRGB(255, 255, 255)
        visPart.CFrame = handle.CFrame
        visPart.Parent = model
        
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = preset.MeshId
        mesh.TextureId = preset.TextureId or ""
        mesh.Scale = (preset.Scale or Vector3.new(1, 1, 1)) * scaleMult
        mesh.Offset = preset.Offset or Vector3.new(0, 0, 0)
        mesh.Parent = visPart
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = handle
        weld.Part1 = visPart
        weld.Parent = visPart
        
        model.Parent = tool
        ApplyWeaponFX(tool, isKnife, visPart)
        return
    end
    
    -- Full 3D Model: AK-47, AWP, M4A1, Deagle, SPAS-12, RPG-7, Karambit, Balisong, Scythe, Diamond Sword, Minigun
    task.spawn(function()
        local rawObj = LoadWeaponAsset(preset.AssetIds)
        if not rawObj then
            -- Fallback visual indicator
            local model = Instance.new("Model")
            model.Name = "Custom3DWeaponVisual"
            model:SetAttribute("PresetKey", preset.Name)
            local p = Instance.new("Part")
            p.Size = Vector3.new(0.5, 2.5 * scaleMult, 0.5)
            p.Color = Color3.fromRGB(220, 35, 45)
            p.Material = Enum.Material.Neon
            p.CanCollide = false
            p.Massless = true
            p.CFrame = handle.CFrame
            p.Parent = model
            local w = Instance.new("WeldConstraint")
            w.Part0 = handle
            w.Part1 = p
            w.Parent = p
            model.Parent = tool
            return
        end
        
        local newModel = nil
        if rawObj:IsA("Model") or rawObj:IsA("Tool") then
            newModel = rawObj:Clone()
        else
            newModel = Instance.new("Model")
            rawObj:Clone().Parent = newModel
        end
        newModel.Name = "Custom3DWeaponVisual"
        newModel:SetAttribute("PresetKey", preset.Name)
        
        -- Strip unneeded scripts, sounds, touch transmitters
        for _, obj in ipairs(newModel:GetDescendants()) do
            if obj:IsA("LuaSourceContainer") or obj:IsA("Sound") or obj:IsA("TouchTransmitter") or obj:IsA("Humanoid") then
                obj:Destroy()
            end
        end
        
        local primary = newModel.PrimaryPart or newModel:FindFirstChild("Handle") or newModel:FindFirstChildWhichIsA("BasePart")
        if not primary then
            for _, p in ipairs(newModel:GetDescendants()) do
                if p:IsA("BasePart") then primary = p break end
            end
        end
        
        if primary then
            newModel.PrimaryPart = primary
            
            -- Auto-normalize size so weapons aren't 100 studs large or microscopic
            local sBox, sz = pcall(function() return newModel:GetBoundingBox() end)
            if sBox and sz and sz.Magnitude > 0 then
                local maxDim = math.max(sz.X, sz.Y, sz.Z)
                local targetWeaponDim = isKnife and 2.2 or 3.2
                if maxDim > 0 then
                    local autoScale = (targetWeaponDim / maxDim) * (preset.BaseScale or 1.0) * scaleMult
                    pcall(function() newModel:ScaleTo(autoScale) end)
                end
            end
            
            -- Position & Weld all parts
            local rotOffset = preset.RotationOffset or CFrame.new()
            newModel:PivotTo(handle.CFrame * rotOffset)
            
            for _, part in ipairs(newModel:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                    part.CanCollide = false
                    part.CanTouch = false
                    part.CanQuery = false
                    part.Massless = true
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = handle
                    weld.Part1 = part
                    weld.Parent = part
                end
            end
            
            newModel.Parent = tool
            ApplyWeaponFX(tool, isKnife, primary)
        end
    end)
end

local function ApplyCustomKnife(tool)
    if not tool then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    BackupWeapon(tool)
    
    -- Check Column 2 Custom 3D Melee first
    if _G.Custom3DMeleeActive then
        local preset = CustomMeleePresets[_G.SelectedCustomMelee]
        if preset then
            ApplyCustom3DWeapon(tool, preset, true, _G.Custom3DWeaponScale or 1.0)
            return
        end
    end
    
    -- Check Column 1 MM2 Official Skins
    if _G.CustomKnifeActive then
        local preset = KnifePresets[_G.SelectedKnifeModel]
        if not preset then
            RestoreWeapon(tool)
            return
        end
        
        RemoveCustomWeaponVisual(tool)
        
        -- Native MM2 Handle SpecialMesh transformation
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if not mesh then
            mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.Parent = handle
        end
        
        mesh.MeshId = preset.MeshId or ""
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
    else
        RestoreWeapon(tool)
    end
end

local function ApplyCustomGun(tool)
    if not tool then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    BackupWeapon(tool)
    
    -- Check Column 2 Custom 3D Gun first
    if _G.Custom3DGunActive then
        local preset = CustomGunPresets[_G.SelectedCustomGun]
        if preset then
            ApplyCustom3DWeapon(tool, preset, false, _G.Custom3DWeaponScale or 1.0)
            return
        end
    end
    
    -- Check Column 1 MM2 Official Skins
    if _G.CustomGunActive then
        local preset = GunPresets[_G.SelectedGunModel]
        if not preset then
            RestoreWeapon(tool)
            return
        end
        
        RemoveCustomWeaponVisual(tool)
        
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if not mesh then
            mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.Parent = handle
        end
        
        mesh.MeshId = preset.MeshId or ""
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
    else
        RestoreWeapon(tool)
    end
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

-- ========================================================================
-- HANDS & ARMS MANIPULATION ENGINE (R6 & R15 Shoulder Positioning & Tilt)
-- ========================================================================
local origRightShoulderC0 = nil
local origLeftShoulderC0 = nil
local cachedChar = nil

local function GetShoulders(char)
    if not char then return nil, nil end
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return nil, nil end
    
    local rightShoulder = torso:FindFirstChild("Right Shoulder") 
        or (char:FindFirstChild("RightUpperArm") and char.RightUpperArm:FindFirstChild("RightShoulder"))
    local leftShoulder = torso:FindFirstChild("Left Shoulder") 
        or (char:FindFirstChild("LeftUpperArm") and char.LeftUpperArm:FindFirstChild("LeftShoulder"))
    return rightShoulder, leftShoulder
end

local function ResetShoulders()
    if cachedChar then
        local r, l = GetShoulders(cachedChar)
        if r and origRightShoulderC0 then r.C0 = origRightShoulderC0 end
        if l and origLeftShoulderC0 then l.C0 = origLeftShoulderC0 end
    end
    origRightShoulderC0 = nil
    origLeftShoulderC0 = nil
    cachedChar = nil
end

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    if cachedChar ~= char then
        cachedChar = char
        origRightShoulderC0 = nil
        origLeftShoulderC0 = nil
    end
    
    local rightShoulder, leftShoulder = GetShoulders(char)
    if not rightShoulder and not leftShoulder then return end
    
    if rightShoulder and not origRightShoulderC0 then origRightShoulderC0 = rightShoulder.C0 end
    if leftShoulder and not origLeftShoulderC0 then origLeftShoulderC0 = leftShoulder.C0 end
    
    if _G.HandsPositionActive then
        local fwd = _G.HandsStretchForward or 0       -- Руки вперед (+) / назад (-)
        local spread = _G.HandsSpreadLeftRight or 0   -- Руки влево / вправо
        local hgt = _G.HandsHeightUpDown or 0         -- Руки вверх (+) / вниз (-)
        
        local pitch = math.rad(_G.HandsAnglePitch or 0) -- Наклон 45° вверх/вниз
        local yaw = math.rad(_G.HandsAngleYaw or 0)     -- Поворот влево/вправо
        local roll = math.rad(_G.HandsAngleRoll or 0)   -- Крен/наклон
        
        local mode = _G.HandsTarget or "Right Arm (Weapon)"
        
        if rightShoulder and (mode == "Right Arm (Weapon)" or mode == "Both Arms") then
            local offsetCF = CFrame.new(spread, hgt, -fwd) * CFrame.Angles(pitch, yaw, roll)
            rightShoulder.C0 = origRightShoulderC0 * offsetCF
        elseif rightShoulder and origRightShoulderC0 then
            rightShoulder.C0 = origRightShoulderC0
        end
        
        if leftShoulder and (mode == "Left Arm" or mode == "Both Arms") then
            local offsetCF = CFrame.new(-spread, hgt, -fwd) * CFrame.Angles(pitch, -yaw, -roll)
            leftShoulder.C0 = origLeftShoulderC0 * offsetCF
        elseif leftShoulder and origLeftShoulderC0 then
            leftShoulder.C0 = origLeftShoulderC0
        end
    else
        if rightShoulder and origRightShoulderC0 and rightShoulder.C0 ~= origRightShoulderC0 then
            rightShoulder.C0 = origRightShoulderC0
        end
        if leftShoulder and origLeftShoulderC0 and leftShoulder.C0 ~= origLeftShoulderC0 then
            leftShoulder.C0 = origLeftShoulderC0
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    ResetShoulders()
end)

local function UpdateCustomWeapons()
    local knife = GetPlayerKnife()
    if knife then
        if _G.Custom3DMeleeActive or _G.CustomKnifeActive then
            ApplyCustomKnife(knife)
        else
            RestoreWeapon(knife)
        end
        if _G.CustomWeaponGripActive or _G.CustomGunGripActive then
            ApplyWeaponGrip(knife)
        end
    end
    
    local gun = GetPlayerGun()
    if gun then
        if _G.Custom3DGunActive or _G.CustomGunActive then
            ApplyCustomGun(gun)
        else
            RestoreWeapon(gun)
        end
        if _G.CustomWeaponGripActive or _G.CustomGunGripActive then
            ApplyWeaponGrip(gun)
        end
    end
end

-- Periodically maintain weapon skins & effects
task.spawn(function()
    while true do
        task.wait(0.2)
        if _G.CustomKnifeActive or _G.CustomGunActive or _G.Custom3DGunActive or _G.Custom3DMeleeActive or _G.CustomGunGripActive or _G.CustomWeaponGripActive then
            UpdateCustomWeapons()
        end
    end
end)

local function HookBackpackAndChar()
    local bpack = LocalPlayer:FindFirstChild("Backpack")
    if bpack then
        bpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and (_G.CustomKnifeActive or _G.CustomGunActive or _G.Custom3DGunActive or _G.Custom3DMeleeActive) then
                task.wait(0.1)
                UpdateCustomWeapons()
            end
        end)
    end
    if LocalPlayer.Character then
        LocalPlayer.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and (_G.CustomKnifeActive or _G.CustomGunActive or _G.Custom3DGunActive or _G.Custom3DMeleeActive) then
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
    if _G.CustomKnifeActive or _G.CustomGunActive or _G.Custom3DGunActive or _G.Custom3DMeleeActive then
        UpdateCustomWeapons()
    end
end)



Weapons.ApplyCustomModel = ApplyCustomModel
Weapons.RemoveCustomModel = RemoveCustomModel
Weapons.ApplyGunGrip = ApplyGunGrip
Weapons.ApplyWeaponGrip = ApplyWeaponGrip
Weapons.GetShoulders = GetShoulders
Weapons.ResetShoulders = ResetShoulders
Weapons.ApplyCustomKnife = ApplyCustomKnife
Weapons.ApplyCustomGun = ApplyCustomGun
Weapons.UpdateCustomWeapons = UpdateCustomWeapons
Weapons.KnifePresets = KnifePresets
Weapons.GunPresets = GunPresets
Weapons.ModelCandidateList = ModelCandidateList
Weapons.KnifeModelNames = KnifeModelNames
Weapons.GunModelNames = GunModelNames
Weapons.CustomGunPresets = CustomGunPresets
Weapons.CustomMeleePresets = CustomMeleePresets
Weapons.CustomGunModelNames = CustomGunModelNames
Weapons.CustomMeleeModelNames = CustomMeleeModelNames

return Weapons