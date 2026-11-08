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

local function ApplyGunGrip(tool)
    if not tool or not tool:IsA("Tool") then return end
    local isGun = (tool.Name == "Gun" or tool.Name == "Revolver" or tool:FindFirstChild("ShootGun") or tool:FindFirstChild("KnifeServer"))
    if not isGun then return end
    BackupWeapon(tool)
    local data = OriginalWeaponData[tool]
    local baseGrip = (data and data.Grip) or CFrame.new()
    if _G.CustomGunGripActive then
        local posOffset = Vector3.new(_G.GunHandPosX or 0, _G.GunHandPosY or 0, _G.GunHandPosZ or 0)
        local rotOffset = CFrame.Angles(
            math.rad(_G.GunHandRotX or 0),
            math.rad(_G.GunHandRotY or 0),
            math.rad(_G.GunHandRotZ or 0)
        )
        tool.Grip = baseGrip * CFrame.new(posOffset) * rotOffset
    else
        tool.Grip = baseGrip
    end
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
    ApplyGunGrip(tool)
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
        if _G.CustomGunGripActive then
            ApplyGunGrip(gun)
        end
    end
end

-- Periodically maintain weapon skins & effects
task.spawn(function()
    while true do
        task.wait(0.2)
        if _G.CustomKnifeActive or _G.CustomGunActive or _G.CustomGunGripActive then
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



Weapons.ApplyCustomModel = ApplyCustomModel
Weapons.RemoveCustomModel = RemoveCustomModel
Weapons.ApplyGunGrip = ApplyGunGrip
Weapons.ApplyCustomKnife = ApplyCustomKnife
Weapons.ApplyCustomGun = ApplyCustomGun
Weapons.UpdateCustomWeapons = UpdateCustomWeapons
Weapons.KnifePresets = KnifePresets
Weapons.GunPresets = GunPresets
Weapons.ModelCandidateList = ModelCandidateList
Weapons.KnifeModelNames = KnifeModelNames
Weapons.GunModelNames = GunModelNames

return Weapons