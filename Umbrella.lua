--[[
    ========================================================================
    UMBRELLA CORPORATION (MURDER MYSTERY 2 HVH SUPREMACY EDITION v11.0)
    Modular Architecture & Dynamic GitHub Bootstrapper
    Repository: https://github.com/Rostik22803/Umbrella-mm2
    ========================================================================
--]]

local BaseUrl = "https://raw.githubusercontent.com/Rostik22803/Umbrella-mm2/main/modules/"

local Umbrella = {
    Version = "11.0",
    Modules = {}
}
_G.Umbrella = Umbrella

-- Dynamic Module Loader with Offline Cache & Anti-Cache HttpGet
local function Import(name)
    local content = nil
    local hasLocal = false
    pcall(function()
        if readfile and isfile and isfile("modules/" .. name .. ".lua") then
            content = readfile("modules/" .. name .. ".lua")
            hasLocal = true
        end
    end)
    
    if not hasLocal or not content or content == "" then
        local url = BaseUrl .. name .. ".lua?t=" .. tick()
        local success, res = pcall(function()
            return game:HttpGet(url)
        end)
        if success and res and res ~= "" then
            content = res
        else
            error("[Umbrella Loader] Failed to fetch module '" .. name .. "' from " .. tostring(url))
        end
    end
    
    local fn, err = loadstring(content)
    if not fn then
        error("[Umbrella Loader] Syntax error in " .. name .. ": " .. tostring(err))
    end
    local successExec, mod = pcall(fn)
    if not successExec then
        error("[Umbrella Loader] Runtime error in " .. name .. ": " .. tostring(mod))
    end
    Umbrella[name] = mod
    Umbrella.Modules[name] = mod
    return mod
end

local Core = Import("Core")

-- 2. Load UI Engine & Components
local UI = Import("UI")

-- 3. Load Feature Modules
local Movement = Import("Movement")
local Visuals = Import("Visuals")
local Weapons = Import("Weapons")
local HvH = Import("HvH")
local Combat = Import("Combat")
local AutoFarm = Import("AutoFarm")

-- Global Shortcuts & Aliases for UI Builder
local Tabs = UI.Tabs
local CreateSection = UI.CreateSection
local CreateToggle = UI.CreateToggle
local CreateSlider = UI.CreateSlider
local CreateDropdown = UI.CreateDropdown
local SwitchTab = UI.SwitchTab
local ApplyMenuTheme = UI.ApplyMenuTheme
local ClearAllChams = Visuals.ClearAllChams

local ChamsStyleOptionNames = UI.ChamsStyleOptionNames
local ColorOptionNames = UI.ColorOptionNames
local FOVColorOptionNames = UI.FOVColorOptionNames
local MenuBgPresets = UI.MenuBgPresets
local MenuBgOptionNames = UI.MenuBgOptionNames
local HeadDotColorOptionNames = UI.HeadDotColorOptionNames
local CrosshairColorOptionNames = UI.CrosshairColorOptionNames

local HitSounds = HvH.HitSounds
local ApplyCustomKnife = Weapons.ApplyCustomKnife
local ApplyCustomGun = Weapons.ApplyCustomGun
local KnifePresets = Weapons.KnifePresets
local GunPresets = Weapons.GunPresets
local KnifeModelNames = Weapons.KnifeModelNames
local GunModelNames = Weapons.GunModelNames
local ModelCandidateList = Weapons.ModelCandidateList
local ApplyCustomModel = Weapons.ApplyCustomModel
local RemoveCustomModel = Weapons.RemoveCustomModel

local ApplyChineseHat = Visuals.ApplyChineseHat
local RemoveChineseHat = Visuals.RemoveChineseHat
local ApplyFootRope = Visuals.ApplyFootRope
local RemoveFootRope = Visuals.RemoveFootRope
local ApplyCharacterTrail = Visuals.ApplyCharacterTrail
local RemoveCharacterTrail = Visuals.RemoveCharacterTrail
local ApplySkyPreset = Visuals.ApplySkyPreset
local RemoveSkyPreset = Visuals.RemoveSkyPreset
local ApplyAtmosphere = Visuals.ApplyAtmosphere
local UpdateColorCorrection = Visuals.UpdateColorCorrection
local UpdateBlur = Visuals.UpdateBlur

local Players = Core.Services.Players
local ScreenGui = UI.ScreenGui
local Watermark = UI.Watermark
local AwallIndicator = UI.AwallIndicator
local HeaderLine = UI.HeaderLine
local UIStrokeMain = UI.UIStrokeMain
local Camera = Core.Camera
local LocalPlayer = Core.LocalPlayer
local Lighting = Core.Services.Lighting
local OriginalLighting = Visuals.OriginalLighting or {
    FieldOfView = 70,
    FogColor = Color3.fromRGB(128, 128, 128),
    FogStart = 0,
    FogEnd = 1000,
    ClockTime = 14,
    Ambient = Color3.fromRGB(128, 128, 128),
    OutdoorAmbient = Color3.fromRGB(128, 128, 128),
    Brightness = 1,
    GlobalShadows = true
}
local UpdateCustomWeapons = Weapons.UpdateCustomWeapons
local UpdateRoleColors = Core.UpdateRoleColors


-- Populate Tabs & Attach UI Controls
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
CreateDropdown(SecESP, "Player Chams Style", ChamsStyleOptionNames, _G.PlayerChamsStyle, function(val)
    _G.PlayerChamsStyle = val
    ClearAllChams()
end)
CreateDropdown(SecESP, "Murderer ESP Color", ColorOptionNames, _G.SelectedMurdererColor, function(val)
    _G.SelectedMurdererColor = val
    if UpdateRoleColors then UpdateRoleColors() end
    ClearAllChams()
end)
CreateDropdown(SecESP, "Sheriff ESP Color", ColorOptionNames, _G.SelectedSheriffColor, function(val)
    _G.SelectedSheriffColor = val
    if UpdateRoleColors then UpdateRoleColors() end
    ClearAllChams()
end)
CreateDropdown(SecESP, "Innocent ESP Color", ColorOptionNames, _G.SelectedInnocentColor, function(val)
    _G.SelectedInnocentColor = val
    if UpdateRoleColors then UpdateRoleColors() end
    ClearAllChams()
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
CreateDropdown(SecESP, "Self Chams Style", ChamsStyleOptionNames, _G.SelfChamsStyle, function(val)
    _G.SelfChamsStyle = val
    ClearAllChams()
end)
CreateDropdown(SecESP, "Self Chams Color", ColorOptionNames, _G.SelectedSelfChamColor, function(col)
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
CreateDropdown(SecESP, "Weapon Chams Style", ChamsStyleOptionNames, _G.WeaponChamsStyle, function(val)
    _G.WeaponChamsStyle = val
    ClearAllChams()
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
CreateDropdown(SecESP, "Dropped Gun Style", ChamsStyleOptionNames, _G.DroppedGunChamsStyle, function(val)
    _G.DroppedGunChamsStyle = val
    ClearAllChams()
end)
CreateDropdown(SecESP, "Dropped Gun Color", ColorOptionNames, _G.SelectedDroppedGunColor, function(col)
    _G.SelectedDroppedGunColor = col
end)

CreateSlider(SecESP, "Chams Fill Transparency", math.round((_G.ChamsFillTransparency or 0.35) * 100), 0, 90, false, function(val)
    _G.ChamsFillTransparency = val / 100
end)
CreateSlider(SecESP, "Chams Outline Transparency", math.round((_G.ChamsOutlineTransparency or 0) * 100), 0, 90, false, function(val)
    _G.ChamsOutlineTransparency = val / 100
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
CreateDropdown(SecHitVisuals, "Tracer Color Preset", {"Blood Red", "Cyber Cyan", "Neon Pink", "Electric Green", "Purple HvH", "Pure White", "Gold Glow", "Rainbow RGB"}, _G.SelectedTracerColor or "Blood Red", function(selected)
    _G.SelectedTracerColor = selected
end)
CreateDropdown(SecHitVisuals, "Tracer Visual Style", {"Dual Pulse (White Core)", "Laser Neon (Solid)"}, _G.TracerStyle or "Dual Pulse (White Core)", function(selected)
    _G.TracerStyle = selected
end)
CreateSlider(SecHitVisuals, "Tracer Thickness", _G.TracerThickness or 0.12, 0.05, 0.4, true, function(val)
    _G.TracerThickness = val
end)
CreateSlider(SecHitVisuals, "Tracer Lifetime", _G.TracerLifetime or 0.5, 0.2, 2.0, true, function(val)
    _G.TracerLifetime = val
end)
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
CreateToggle(SecCustomWeapons, "Custom Gun Hands / Viewmodel Offset", _G.CustomGunGripActive, function(st)
    _G.CustomGunGripActive = st
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomWeapons, "Gun Position X (Left/Right)", _G.GunHandPosX or 0.0, -3.0, 3.0, true, function(val)
    _G.GunHandPosX = val
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomWeapons, "Gun Position Y (Up/Down)", _G.GunHandPosY or 0.0, -3.0, 3.0, true, function(val)
    _G.GunHandPosY = val
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomWeapons, "Gun Position Z (Forward/Back)", _G.GunHandPosZ or 0.0, -3.0, 3.0, true, function(val)
    _G.GunHandPosZ = val
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomWeapons, "Gun Angle Pitch (X)", _G.GunHandRotX or 0, -180, 180, false, function(val)
    _G.GunHandRotX = val
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomWeapons, "Gun Angle Yaw (Y)", _G.GunHandRotY or 0, -180, 180, false, function(val)
    _G.GunHandRotY = val
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomWeapons, "Gun Angle Roll (Z)", _G.GunHandRotZ or 0, -180, 180, false, function(val)
    _G.GunHandRotZ = val
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
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
    local curTrail = Visuals.CharacterTrail or _G.CharacterTrail
    if curTrail and curTrail.Parent then
        curTrail.Lifetime = val
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
    local curRope = Visuals.FootRopeTrail or _G.FootRopeTrail
    if curRope and curRope.Parent then
        curRope.Lifetime = val
    end
end)
CreateSlider(SecTrails, "Rope Thickness", _G.RopeWidth, 0.1, 1.0, true, function(val)
    _G.RopeWidth = val
    local curRope = Visuals.FootRopeTrail or _G.FootRopeTrail
    if curRope and curRope.Parent then
        curRope.WidthScale = NumberSequence.new({
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

local SecCrosshair = CreateSection(Tabs["Visuals"], "Custom HvH Crosshair Engine")
CreateToggle(SecCrosshair, "Enable Custom Crosshair", false, function(st) _G.CustomCrosshairActive = st end)
CreateDropdown(SecCrosshair, "Crosshair Style", {"Classic (+)", "T-Shape", "Dot Only", "Circle Ring", "Cross + Circle", "X-Cross (x)", "Arrow (^)"}, _G.CrosshairStyle, function(val)
    _G.CrosshairStyle = val
end)
CreateDropdown(SecCrosshair, "Crosshair Color", CrosshairColorOptionNames, _G.SelectedCrosshairColor, function(selected)
    _G.SelectedCrosshairColor = selected
end)
CreateSlider(SecCrosshair, "Crosshair Size (Length)", _G.CrosshairSize, 2, 35, false, function(val) _G.CrosshairSize = val end)
CreateSlider(SecCrosshair, "Crosshair Thickness", _G.CrosshairThickness, 1, 8, false, function(val) _G.CrosshairThickness = val end)
CreateSlider(SecCrosshair, "Crosshair Gap", _G.CrosshairGap, 0, 25, false, function(val) _G.CrosshairGap = val end)
CreateSlider(SecCrosshair, "Crosshair Transparency", math.round((_G.CrosshairTransparency or 0) * 100), 0, 90, false, function(val) _G.CrosshairTransparency = val / 100 end)
CreateToggle(SecCrosshair, "Center Dot", _G.CrosshairDot, function(st) _G.CrosshairDot = st end)
CreateSlider(SecCrosshair, "Center Dot Size", _G.CrosshairDotSize, 1, 12, false, function(val) _G.CrosshairDotSize = val end)
CreateDropdown(SecCrosshair, "Center Dot Shape", {"Circle", "Square"}, _G.CrosshairDotShape, function(val) _G.CrosshairDotShape = val end)
CreateToggle(SecCrosshair, "Top Line (T-Shape Control)", _G.CrosshairTopLine, function(st) _G.CrosshairTopLine = st end)
CreateToggle(SecCrosshair, "Rounded Line Caps", _G.CrosshairRoundedBars, function(st) _G.CrosshairRoundedBars = st end)
CreateToggle(SecCrosshair, "Outline (Border)", _G.CrosshairOutline, function(st) _G.CrosshairOutline = st end)
CreateSlider(SecCrosshair, "Outline Thickness", _G.CrosshairOutlineThickness, 1, 4, false, function(val) _G.CrosshairOutlineThickness = val end)
CreateDropdown(SecCrosshair, "Outline Color", {"Pure Black", "Dark Gray", "Deep Crimson", "Inverse"}, _G.CrosshairOutlineColor, function(val) _G.CrosshairOutlineColor = val end)
CreateToggle(SecCrosshair, "Circle Ring Overlay", _G.CrosshairRingActive, function(st) _G.CrosshairRingActive = st end)
CreateSlider(SecCrosshair, "Ring Radius", _G.CrosshairRingRadius, 6, 45, false, function(val) _G.CrosshairRingRadius = val end)
CreateSlider(SecCrosshair, "Ring Thickness", _G.CrosshairRingThickness, 1, 5, false, function(val) _G.CrosshairRingThickness = val end)
CreateToggle(SecCrosshair, "Follow Mouse Cursor", _G.CrosshairFollowMouse, function(st) _G.CrosshairFollowMouse = st end)
CreateToggle(SecCrosshair, "Spin Animation (Rotation)", _G.CrosshairSpin, function(st) _G.CrosshairSpin = st end)
CreateSlider(SecCrosshair, "Spin Speed", _G.CrosshairSpinSpeed, 1, 20, false, function(val) _G.CrosshairSpinSpeed = val end)
CreateToggle(SecCrosshair, "Breathing Pulse", _G.CrosshairPulse, function(st) _G.CrosshairPulse = st end)
CreateToggle(SecCrosshair, "Dynamic Movement Spread", _G.CrosshairDynamicSpread, function(st) _G.CrosshairDynamicSpread = st end)
CreateSlider(SecCrosshair, "Movement Spread Amount", _G.CrosshairSpreadAmount, 2, 20, false, function(val) _G.CrosshairSpreadAmount = val end)
CreateToggle(SecCrosshair, "Target Lock Color React", _G.CrosshairTargetColor, function(st) _G.CrosshairTargetColor = st end)

local SecMoreVisuals = CreateSection(Tabs["Visuals"], "HvH Aesthetics & Extras")
CreateToggle(SecMoreVisuals, "Head Dot ESP (Точка головы)", false, function(st) _G.HeadDotActive = st end)
CreateDropdown(SecMoreVisuals, "Head Dot Color", HeadDotColorOptionNames, _G.SelectedHeadDotColor, function(val)
    _G.SelectedHeadDotColor = val
end)
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
CreateDropdown(SecCombat, "Silent Aim Target", {"Murderer Only", "All Enemies / Players"}, _G.SilentAimTargetMode or "Murderer Only", function(val)
    _G.SilentAimTargetMode = val
end)
CreateToggle(SecCombat, "Silent Aim Wallbang (Through Walls)", _G.SilentAimWallbang, function(st)
    _G.SilentAimWallbang = st
end)
CreateSlider(SecCombat, "Silent Aim FOV Radius", _G.SilentAimFOV or 300, 40, 600, false, function(val)
    _G.SilentAimFOV = val
end)
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



SwitchTab("Main")



-- Start Loading Sequence & Show Menu
UI.FinishLoading()
