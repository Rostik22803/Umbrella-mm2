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
        MeshId = "rbxassetid://367801163",
        TextureId = "rbxassetid://367801185",
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
        MeshId = "rbxassetid://367801163",
        TextureId = "rbxassetid://367801185",
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

local function ApplyWeaponFX(tool, isKnife, emitterPart)
    if not emitterPart then return end
    
    -- 1. Aura Particle Emitter
    local existingAura = emitterPart:FindFirstChild("MM2_WeaponAura")
    if _G.CustomWeaponAura and _G.CustomWeaponAura ~= "None" then
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
                att0 = Instance.new("Attachment", emitterPart)
                att0.Name = "MM2_TrailAtt0"
                att0.Position = Vector3.new(0, 0.8, 0)
            end
            if not att1 then
                att1 = Instance.new("Attachment", emitterPart)
                att1.Name = "MM2_TrailAtt1"
                att1.Position = Vector3.new(0, -0.8, 0)
            end
            if not existingTrail then
                existingTrail = Instance.new("Trail")
                existingTrail.Name = "MM2_WeaponTrail"
                existingTrail.Attachment0 = att0
                existingTrail.Attachment1 = att1
                existingTrail.Parent = emitterPart
            end
            existingTrail.Lifetime = 0.35
            existingTrail.LightEmission = 0.9
            existingTrail.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(1, 1)
            })
            
            local trailCol = Color3.fromRGB(220, 35, 45)
            if _G.SelectedWeaponTrailColor == "Rainbow RGB" then
                trailCol = _G.RainbowColor or Color3.fromRGB(255, 255, 255)
            elseif _G.SelectedWeaponTrailColor == "Blood Red" then
                trailCol = Color3.fromRGB(255, 30, 40)
            elseif _G.SelectedWeaponTrailColor == "Cyber Cyan" then
                trailCol = Color3.fromRGB(0, 240, 255)
            elseif _G.SelectedWeaponTrailColor == "Gold Glow" then
                trailCol = Color3.fromRGB(255, 215, 0)
            elseif _G.SelectedWeaponTrailColor == "Pure White" then
                trailCol = Color3.fromRGB(255, 255, 255)
            end
            existingTrail.Color = ColorSequence.new(trailCol)
        else
            if existingTrail then existingTrail:Destroy() end
        end
    end
end

-- УНИВЕРСАЛЬНОЕ НАЛОЖЕНИЕ МАТЕРИАЛА И ЦВЕТА НА ВСЕ ЧАСТИ ОРУЖИЯ (MeshPart, SpecialMesh, BasePart)
local function ApplyMaterialAndColorToPart(part, preset, isKnife)
    if not part or not part:IsA("BasePart") then return end
    
    -- 1. Material
    if _G.CustomWeaponMaterial and _G.CustomWeaponMaterial ~= "Default" then
        if _G.CustomWeaponMaterial == "Neon Glow" then
            part.Material = Enum.Material.Neon
        elseif _G.CustomWeaponMaterial == "ForceField" then
            part.Material = Enum.Material.ForceField
        elseif _G.CustomWeaponMaterial == "Glass" then
            part.Material = Enum.Material.Glass
        elseif _G.CustomWeaponMaterial == "Chrome Metal" then
            part.Material = Enum.Material.Metal
        end
    elseif preset and preset.Material then
        part.Material = preset.Material
    else
        part.Material = Enum.Material.Plastic
    end
    
    -- 2. Color & Chroma
    local mesh = part:FindFirstChildOfClass("SpecialMesh")
    local finalColor = Color3.fromRGB(255, 255, 255)
    
    if _G.CustomWeaponColor and _G.CustomWeaponColor ~= "Original" then
        if _G.CustomWeaponColor == "Rainbow RGB" then
            finalColor = _G.RainbowColor or Color3.fromRGB(255, 0, 0)
        elseif ChamColorPresets[_G.CustomWeaponColor] then
            finalColor = ChamColorPresets[_G.CustomWeaponColor]
        end
    elseif preset and preset.IsChroma then
        finalColor = _G.RainbowColor or Color3.fromRGB(255, 0, 0)
    elseif preset and preset.Color then
        finalColor = preset.Color
    end
    
    part.Color = finalColor
    if mesh then
        mesh.VertexColor = Vector3.new(finalColor.R, finalColor.G, finalColor.B)
        -- Очистка текстуры при Неоне и Форсфилде, иначе текстура перекрывает свечение материала
        if _G.CustomWeaponMaterial == "Neon Glow" or _G.CustomWeaponMaterial == "ForceField" then
            mesh.TextureId = ""
        end
    end
    if part:IsA("MeshPart") then
        if _G.CustomWeaponMaterial == "Neon Glow" or _G.CustomWeaponMaterial == "ForceField" then
            part.TextureID = ""
        end
    end
end

local function ApplyCustomKnife(tool)
    if not tool then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    BackupWeapon(tool)
    RemoveCustomWeaponVisual(tool)
    
    local preset = KnifePresets[_G.SelectedKnifeModel]
    
    -- 1. Если включен скин MM2 и пресет не Default, меняем 3D модель
    if _G.CustomKnifeActive and preset and _G.SelectedKnifeModel ~= "Default" then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if not mesh then
            mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.Parent = handle
        end
        mesh.MeshId = preset.MeshId or ""
        if _G.CustomWeaponMaterial == "Neon Glow" or _G.CustomWeaponMaterial == "ForceField" then
            mesh.TextureId = ""
        else
            mesh.TextureId = preset.TextureId or ""
        end
        mesh.Scale = preset.Scale or Vector3.new(1, 1, 1)
        mesh.Offset = preset.Offset or Vector3.new(0, 0, 0)
    end
    
    handle.Transparency = 0
    
    -- 2. Накладываем кастомный материал, цвет и свечение на ВСЕ детали ножа (Handle, лезвия, части)
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            ApplyMaterialAndColorToPart(part, preset, true)
        end
    end
    
    -- 3. Накладываем ауру и трейл
    ApplyWeaponFX(tool, true, handle)
end

local function ApplyCustomGun(tool)
    if not tool then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    BackupWeapon(tool)
    RemoveCustomWeaponVisual(tool)
    
    local preset = GunPresets[_G.SelectedGunModel]
    
    -- 1. Если включен скин пистолета MM2 и пресет не Default, меняем 3D модель
    if _G.CustomGunActive and preset and _G.SelectedGunModel ~= "Default" then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if not mesh then
            mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.Parent = handle
        end
        mesh.MeshId = preset.MeshId or ""
        if _G.CustomWeaponMaterial == "Neon Glow" or _G.CustomWeaponMaterial == "ForceField" then
            mesh.TextureId = ""
        else
            mesh.TextureId = preset.TextureId or ""
        end
        mesh.Scale = preset.Scale or Vector3.new(1, 1, 1)
        mesh.Offset = preset.Offset or Vector3.new(0, 0, 0)
    end
    
    handle.Transparency = 0
    
    -- 2. Накладываем материал и цвет на ВСЕ детали пистолета (барабан, ствол, рукоять)
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            ApplyMaterialAndColorToPart(part, preset, false)
        end
    end
    
    -- 3. Накладываем ауру
    ApplyWeaponFX(tool, false, handle)
end

-- ========================================================================
-- ДВИЖОК ОРУЖИЯ НА СПИНЕ (HOLSTERED BACK WEAPONS & LOBBY SYSTEM)
-- ========================================================================
local BodyPartNames = {
    ["head"] = true,
    ["torso"] = true,
    ["uppertorso"] = true,
    ["lowertorso"] = true,
    ["humanoidrootpart"] = true,
    ["left arm"] = true,
    ["right arm"] = true,
    ["left leg"] = true,
    ["right leg"] = true,
    ["leftupperarm"] = true,
    ["leftlowerarm"] = true,
    ["lefthand"] = true,
    ["rightupperarm"] = true,
    ["rightlowerarm"] = true,
    ["righthand"] = true,
    ["leftupperleg"] = true,
    ["leftlowerleg"] = true,
    ["leftfoot"] = true,
    ["rightupperleg"] = true,
    ["rightlowerleg"] = true,
    ["rightfoot"] = true,
    ["rootpart"] = true
}

local HiddenGameParts = {}

-- Постоянное удержание прозрачности оригинального оружия в каждом кадре
RunService.RenderStepped:Connect(function()
    for part in pairs(HiddenGameParts) do
        if part and part.Parent then
            part.Transparency = 1
            part.LocalTransparencyModifier = 1
        else
            HiddenGameParts[part] = nil
        end
    end
end)

local function HideOriginalBackWeapon(obj)
    if not obj then return end
    if obj.Name:find("Umbrella_") or obj.Name == "CustomChangerModel" then return end
    
    local function process(item)
        if item:IsA("BasePart") then
            HiddenGameParts[item] = true
            item.Transparency = 1
            item.LocalTransparencyModifier = 1
            item.CastShadow = false
        elseif item:IsA("Decal") or item:IsA("Texture") then
            item.Transparency = 1
        elseif item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Beam") or item:IsA("Fire") or item:IsA("Smoke") or item:IsA("Sparkles") then
            item.Enabled = false
        elseif item:IsA("Light") or item:IsA("PointLight") or item:IsA("SurfaceLight") or item:IsA("SpotLight") then
            item.Enabled = false
        end
    end
    
    process(obj)
    for _, desc in ipairs(obj:GetDescendants()) do
        process(desc)
    end
end

local function IsGameBackWeapon(obj, knifeInHand, gunInHand)
    if not obj then return false, nil end
    if obj.Name:find("Umbrella_") or obj.Name == "CustomChangerModel" then return false, nil end
    if obj == knifeInHand or obj == gunInHand then return false, nil end
    if knifeInHand and obj:IsDescendantOf(knifeInHand) then return false, nil end
    if gunInHand and obj:IsDescendantOf(gunInHand) then return false, nil end
    
    local name = obj.Name:lower()
    if BodyPartNames[name] then return false, nil end
    
    local isKnife = name:find("knife") or name:find("blade") or name:find("sword") or name:find("scythe") or name:find("dagger") or name:find("slash")
    local isGun = name:find("gun") or name:find("revolver") or name:find("luger") or name:find("blaster") or name:find("pistol") or name:find("shoot")
    
    -- Проверка на известные пресеты ножей MM2
    if not isKnife and not isGun then
        for kName, _ in pairs(KnifePresets) do
            if kName ~= "Default" and name:find(kName:lower():sub(1, 6)) then
                isKnife = true
                break
            end
        end
    end
    if not isKnife and not isGun then
        for gName, _ in pairs(GunPresets) do
            if gName ~= "Default" and name:find(gName:lower():sub(1, 6)) then
                isGun = true
                break
            end
        end
    end
    
    -- Проверка на аксессуары спины и пояса
    if obj:IsA("Accessory") then
        local accType = obj.AccessoryType
        local isBackWaist = (accType == Enum.AccessoryType.Back or accType == Enum.AccessoryType.Waist)
        local handle = obj:FindFirstChild("Handle")
        if handle then
            local hName = handle.Name:lower()
            if isKnife or hName:find("knife") or hName:find("blade") or hName:find("sword") or hName:find("scythe") or hName:find("dagger") then
                return true, "Knife"
            elseif isGun or hName:find("gun") or hName:find("revolver") or hName:find("luger") or hName:find("pistol") then
                return true, "Gun"
            elseif isBackWaist then
                for _, att in ipairs(handle:GetChildren()) do
                    if att:IsA("Attachment") then
                        local aName = att.Name:lower()
                        if aName:find("waist") or aName:find("hip") then
                            return true, "Gun"
                        elseif aName:find("back") then
                            return true, "Knife"
                        end
                    end
                end
                return true, "Knife"
            end
        end
    end
    
    if isKnife then return true, "Knife" end
    if isGun then return true, "Gun" end
    
    -- Проверка welds внутри деталей
    local p = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if p then
        for _, w in ipairs(p:GetChildren()) do
            if w:IsA("Weld") or w:IsA("Motor6D") or w:IsA("WeldConstraint") then
                local wName = w.Name:lower()
                if wName:find("knife") or wName:find("back") then
                    return true, "Knife"
                elseif wName:find("gun") or wName:find("waist") or wName:find("holster") then
                    return true, "Gun"
                end
            end
        end
    end
    
    return false, nil
end

local function UpdateBackWeapons()
    local char = LocalPlayer.Character
    if not char then return end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then return end
    
    -- Проверяем, держим ли оружие в руках прямо сейчас
    local knifeInHand = nil
    local gunInHand = nil
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then
            local n = obj.Name:lower()
            if n == "knife" or n:find("knife") or obj:FindFirstChild("KnifeServer") or obj:FindFirstChild("Stab") then
                knifeInHand = obj
            elseif n == "gun" or n == "revolver" or n:find("gun") or n:find("revolver") or obj:FindFirstChild("ShootGun") then
                gunInHand = obj
            end
        end
    end
    
    -- Отображение на спине: активно и в лобби, и в раунде когда оружие не в руках
    local shouldShowBackKnife = (_G.BackKnifeActive ~= false)
    local shouldShowBackGun = (_G.BackGunActive ~= false)
    
    -- 1. ДЕЛАЕМ НЕВИДИМЫМ ВСЕ СТОКОВОЕ ОРУЖИЕ, КОТОРОЕ СТАВИТ ИГРА (И В ЛОББИ, И В КАТКЕ)
    for _, obj in ipairs(char:GetChildren()) do
        local isGameWeapon, wType = IsGameBackWeapon(obj, knifeInHand, gunInHand)
        if isGameWeapon then
            HideOriginalBackWeapon(obj)
        end
    end
    
    -- Сканируем крепления (Weld / Motor6D) на торсе, поставленные игрой
    local origKnifeWeld = nil
    local origGunWeld = nil
    for _, part in ipairs({torso, char:FindFirstChild("LowerTorso"), char:FindFirstChild("HumanoidRootPart")}) do
        if part then
            for _, d in ipairs(part:GetChildren()) do
                if d:IsA("Weld") or d:IsA("Motor6D") or d:IsA("WeldConstraint") then
                    local dName = d.Name:lower()
                    if (dName:find("knife") or dName:find("back")) and d.Name ~= "BackKnifeWeld" then
                        origKnifeWeld = d
                        if d.Part1 and not d.Part1.Name:find("Umbrella_") then
                            HideOriginalBackWeapon(d.Part1)
                            if d.Part1.Parent ~= char then HideOriginalBackWeapon(d.Part1.Parent) end
                        end
                    elseif (dName:find("gun") or dName:find("waist") or dName:find("holster")) and d.Name ~= "BackGunWeld" then
                        origGunWeld = d
                        if d.Part1 and not d.Part1.Name:find("Umbrella_") then
                            HideOriginalBackWeapon(d.Part1)
                            if d.Part1.Parent ~= char then HideOriginalBackWeapon(d.Part1.Parent) end
                        end
                    end
                end
            end
        end
    end
    
    -- 2. КАСТОМНЫЙ НОЖ НА СПИНЕ (СТАВИМ НАШ СКИН И В ЛОББИ, И В КАТКЕ)
    local existingBackKnife = char:FindFirstChild("Umbrella_BackKnife")
    if shouldShowBackKnife then
        if not existingBackKnife then
            existingBackKnife = Instance.new("Part")
            existingBackKnife.Name = "Umbrella_BackKnife"
            existingBackKnife.CanCollide = false
            existingBackKnife.CanTouch = false
            existingBackKnife.CanQuery = false
            existingBackKnife.Massless = true
            existingBackKnife.Size = Vector3.new(0.5, 2.2, 0.4)
            existingBackKnife.Parent = char
            
            local mesh = Instance.new("SpecialMesh")
            mesh.Name = "SpecialMesh"
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.Parent = existingBackKnife
            
            local weld = Instance.new("Motor6D")
            weld.Name = "BackKnifeWeld"
            weld.Part0 = torso
            weld.Part1 = existingBackKnife
            -- Используем C0 игры если доступно, иначе точное диагональное крепление через плечо
            if origKnifeWeld and origKnifeWeld.C0 then
                weld.C0 = origKnifeWeld.C0
            else
                weld.C0 = CFrame.new(-0.25, 0.35, 0.65) * CFrame.Angles(math.rad(15), math.rad(180), math.rad(-45))
            end
            weld.Parent = existingBackKnife
        end
        
        local preset = KnifePresets[_G.SelectedKnifeModel]
        local mesh = existingBackKnife:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            mesh.MeshId = (preset and preset.MeshId) or "rbxassetid://121944778"
            if _G.CustomWeaponMaterial == "Neon Glow" or _G.CustomWeaponMaterial == "ForceField" then
                mesh.TextureId = ""
            else
                mesh.TextureId = (preset and preset.TextureId) or "rbxassetid://121944805"
            end
            mesh.Scale = (preset and preset.Scale) or Vector3.new(1, 1, 1)
            mesh.Offset = (preset and preset.Offset) or Vector3.new(0, 0, 0)
        end
        existingBackKnife.Transparency = 0
        ApplyMaterialAndColorToPart(existingBackKnife, preset, true)
        ApplyWeaponFX(nil, true, existingBackKnife)
    else
        if existingBackKnife then existingBackKnife:Destroy() end
    end
    
    -- 3. КАСТОМНЫЙ ПИСТОЛЕТ НА ПОЯСЕ/СПИНЕ (НАШ СКИН И В ЛОББИ, И В КАТКЕ)
    local existingBackGun = char:FindFirstChild("Umbrella_BackGun")
    if shouldShowBackGun then
        if not existingBackGun then
            existingBackGun = Instance.new("Part")
            existingBackGun.Name = "Umbrella_BackGun"
            existingBackGun.CanCollide = false
            existingBackGun.CanTouch = false
            existingBackGun.CanQuery = false
            existingBackGun.Massless = true
            existingBackGun.Size = Vector3.new(0.6, 1.2, 0.4)
            existingBackGun.Parent = char
            
            local mesh = Instance.new("SpecialMesh")
            mesh.Name = "SpecialMesh"
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.Parent = existingBackGun
            
            local weld = Instance.new("Motor6D")
            weld.Name = "BackGunWeld"
            local hipTorso = char:FindFirstChild("LowerTorso") or torso
            weld.Part0 = hipTorso
            weld.Part1 = existingBackGun
            -- Используем C0 игры если доступно, иначе точная кобура на поясе
            if origGunWeld and origGunWeld.C0 then
                weld.C0 = origGunWeld.C0
            else
                weld.C0 = CFrame.new(0.85, -0.65, 0.15) * CFrame.Angles(0, math.rad(90), math.rad(-15))
            end
            weld.Parent = existingBackGun
        end
        
        local preset = GunPresets[_G.SelectedGunModel]
        local mesh = existingBackGun:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            mesh.MeshId = (preset and preset.MeshId) or "rbxassetid://97886770"
            if _G.CustomWeaponMaterial == "Neon Glow" or _G.CustomWeaponMaterial == "ForceField" then
                mesh.TextureId = ""
            else
                mesh.TextureId = (preset and preset.TextureId) or "rbxassetid://97888197"
            end
            mesh.Scale = (preset and preset.Scale) or Vector3.new(1, 1, 1)
            mesh.Offset = (preset and preset.Offset) or Vector3.new(0, 0, 0)
        end
        existingBackGun.Transparency = 0
        ApplyMaterialAndColorToPart(existingBackGun, preset, false)
        ApplyWeaponFX(nil, false, existingBackGun)
    else
        if existingBackGun then existingBackGun:Destroy() end
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
        ApplyCustomKnife(knife)
        if _G.CustomWeaponGripActive or _G.CustomGunGripActive then
            ApplyWeaponGrip(knife)
        end
    end
    
    local gun = GetPlayerGun()
    if gun then
        ApplyCustomGun(gun)
        if _G.CustomWeaponGripActive or _G.CustomGunGripActive then
            ApplyWeaponGrip(gun)
        end
    end
    
    -- Обновляем оружие на спине и аксессуары
    UpdateBackWeapons()
end

local function ShouldRunWeaponsEngine()
    return true -- Всегда поддерживать оружие на спине и скины как в лобби, так и в катке
end

-- Постоянное поддержание скинов и оружия на спине (Лобби + Матч)
task.spawn(function()
    while true do
        task.wait(0.1)
        if ShouldRunWeaponsEngine() then
            pcall(UpdateCustomWeapons)
        end
    end
end)

local function HookCharacter(char)
    if not char then return end
    char.ChildAdded:Connect(function(child)
        task.wait(0.05)
        pcall(UpdateCustomWeapons)
    end)
    char.DescendantAdded:Connect(function(desc)
        if desc:IsA("Accessory") or desc:IsA("Tool") or desc:IsA("SpecialMesh") or desc:IsA("Weld") or desc:IsA("Motor6D") then
            task.wait(0.05)
            pcall(UpdateCustomWeapons)
        end
    end)
end

local function HookBackpackAndChar()
    local bpack = LocalPlayer:FindFirstChild("Backpack")
    if bpack then
        bpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.05)
                pcall(UpdateCustomWeapons)
            end
        end)
    end
    if LocalPlayer.Character then
        HookCharacter(LocalPlayer.Character)
    end
end

HookBackpackAndChar()
LocalPlayer.CharacterAdded:Connect(function(char)
    HiddenGameParts = {}
    task.wait(0.2)
    HookBackpackAndChar()
    pcall(UpdateCustomWeapons)
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
Weapons.UpdateBackWeapons = UpdateBackWeapons
Weapons.KnifePresets = KnifePresets
Weapons.GunPresets = GunPresets
Weapons.ModelCandidateList = ModelCandidateList
Weapons.KnifeModelNames = KnifeModelNames
Weapons.GunModelNames = GunModelNames


return Weapons
