--[[
    ========================================================================
    UMBRELLA CORPORATION (MURDER MYSTERY 2 HVH SUPREMACY EDITION v11.0)
    Modular Architecture & Dynamic GitHub Bootstrapper
    Repository: https://github.com/Rostik22803/Umbrella-mm2
    ========================================================================
--]]

if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
    print(string.format("[%s] %s", title, text))
end

Notify("Umbrella MM2", "Initializing supremacy engine...", 2)

local BaseUrl = "https://raw.githubusercontent.com/Rostik22803/Umbrella-mm2/main/modules/"

local Umbrella = {
    Version = "11.0",
    Modules = {}
}
_G.Umbrella = Umbrella

-- Dynamic Module Loader with Anti-Cache HttpGet & Auto Retry
local function Import(name)
    local content = nil
    local lastErr = nil
    
    -- Primary: Fetch latest from GitHub with anti-cache
    for attempt = 1, 3 do
        local url = BaseUrl .. name .. ".lua?t=" .. tick()
        local success, res = pcall(function()
            return game:HttpGet(url)
        end)
        if success and res and res ~= "" then
            content = res
            break
        else
            lastErr = res
            task.wait(0.3)
        end
    end
    
    -- Fallback: Local file cache if available
    if not content or content == "" then
        pcall(function()
            if readfile and isfile and isfile("modules/" .. name .. ".lua") then
                content = readfile("modules/" .. name .. ".lua")
            end
        end)
    end
    
    if not content or content == "" then
        local msg = "Failed to fetch module '" .. name .. "': " .. tostring(lastErr)
        Notify("Umbrella Error", msg, 5)
        error(msg)
    end
    
    local fn, err = loadstring(content)
    if not fn then
        local msg = "Syntax error in " .. name .. ": " .. tostring(err)
        Notify("Umbrella Error", msg, 5)
        error(msg)
    end
    local successExec, mod = pcall(fn)
    if not successExec then
        local msg = "Runtime error in " .. name .. ": " .. tostring(mod)
        Notify("Umbrella Error", msg, 5)
        error(msg)
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
local CustomGunModelNames = Weapons.CustomGunModelNames or {}
local CustomMeleeModelNames = Weapons.CustomMeleeModelNames or {}
local ModelCandidateList = Weapons.ModelCandidateList
local ApplyCustomModel = Weapons.ApplyCustomModel
local RemoveCustomModel = Weapons.RemoveCustomModel

local ApplyChineseHat = Visuals.ApplyChineseHat
local RemoveChineseHat = Visuals.RemoveChineseHat
local ApplyCharacterTrail = Visuals.ApplyCharacterTrail
local RemoveCharacterTrail = Visuals.RemoveCharacterTrail
local ApplyFootstepRope = Visuals.ApplyFootstepRope
local RemoveFootstepRope = Visuals.RemoveFootstepRope
local UpdateColorCorrection = Visuals.UpdateColorCorrection
local ApplySkyPreset = Visuals.ApplySkyPreset
local RemoveSkyPreset = Visuals.RemoveSkyPreset
local OriginalLighting = Visuals.OriginalLighting

local AwallIndicator = UI.AwallIndicator
local Watermark = UI.Watermark
local UIStrokeMain = UI.UIStrokeMain
local HeaderLine = UI.HeaderLine

------------------------------------------------------------------------
-- ПОСТРОЕНИЕ ВКЛАДОК МЕНЮ
------------------------------------------------------------------------

-- 1. MAIN TAB
local SecLocal = CreateSection(Tabs["Main"], "Local Player Supremacy")
CreateToggle(SecLocal, "Noclip Engine", false, function(st) _G.NoclipActive = st end)
CreateToggle(SecLocal, "Anti-Fling Physics Shield", false, function(st) _G.AntiFlingActive = st end)
CreateToggle(SecLocal, "Infinite Jump (No Cooldown)", false, function(st) _G.InfiniteJumpActive = st end)
CreateToggle(SecLocal, "Auto Pickup Dropped Gun", false, function(st) _G.AutoPickupActive = st end)
CreateDropdown(SecLocal, "Pickup Mode", {"Teleport", "Distance Touch"}, "Teleport", function(m) _G.PickupMode = m end)
CreateToggle(SecLocal, "Speed Engine (WalkSpeed)", false, function(st) _G.SpeedActive = st end)
CreateSlider(SecLocal, "Speed Value", _G.SpeedValue, 16, 120, false, function(val) _G.SpeedValue = val end)
CreateToggle(SecLocal, "Bunny Hop (Bhop)", false, function(st) _G.BhopActive = st end)
CreateToggle(SecLocal, "Spinbot 360 Engine", false, function(st) _G.SpinbotActive = st end)
CreateSlider(SecLocal, "Spin Speed", _G.SpinSpeed, 5, 80, false, function(val) _G.SpinSpeed = val end)

local SecAutoFarm = CreateSection(Tabs["Main"], "MM2 Auto Farm & Coins")
CreateToggle(SecAutoFarm, "Auto Farm Coins (Smart Safe TP)", false, function(st)
    AutoFarm.SetAutoFarmCoins(st)
end)
CreateSlider(SecAutoFarm, "Coin Teleport Speed", AutoFarm.CoinSpeed or 22, 10, 50, false, function(val)
    AutoFarm.CoinSpeed = val
end)
CreateToggle(SecAutoFarm, "Auto Next Round Spawn", false, function(st)
    AutoFarm.SetAutoRoundSpawn(st)
end)

local SecAdvMovement = CreateSection(Tabs["Main"], "HvH Advanced Movement")
CreateToggle(SecAdvMovement, "Auto Strafe Engine", false, function(st) _G.AutoStrafeActive = st end)
CreateToggle(SecAdvMovement, "Flight Mode (Noclip Fly)", false, function(st) _G.FlyActive = st end)
CreateSlider(SecAdvMovement, "Flight Speed", _G.FlySpeed, 20, 150, false, function(val) _G.FlySpeed = val end)
CreateToggle(SecAdvMovement, "Fast Stop (Instant Deceleration)", false, function(st) _G.FastStopActive = st end)
CreateToggle(SecAdvMovement, "High Jump Engine", false, function(st) _G.HighJumpActive = st end)
CreateSlider(SecAdvMovement, "Jump Boost Power", _G.JumpBoostPower, 50, 300, false, function(val) _G.JumpBoostPower = val end)
CreateToggle(SecAdvMovement, "Long Jump (Forward Boost)", false, function(st) _G.LongJumpActive = st end)
CreateSlider(SecAdvMovement, "Long Jump Distance", _G.LongJumpPower, 20, 150, false, function(val) _G.LongJumpPower = val end)

local SecSoundsFX = CreateSection(Tabs["Main"], "Footsteps & Camera FX")
CreateToggle(SecSoundsFX, "Custom Footstep Sounds", false, function(st) _G.CustomFootstepsActive = st end)
CreateDropdown(SecSoundsFX, "Footstep Sound Preset", {"Minecraft Stone", "Minecraft Wood", "Metal Heavy", "Squid Game", "Anime Slap", "Roblox Classic"}, "Minecraft Stone", function(s) _G.SelectedFootstep = s end)
CreateSlider(SecSoundsFX, "Footstep Sound Volume", _G.FootstepsVolume, 1, 10, false, function(val) _G.FootstepsVolume = val end)
CreateToggle(SecSoundsFX, "Custom Field of View (FOV)", false, function(st)
    _G.CustomFOVActive = st
    if not st then Camera.FieldOfView = 70 end
end)
CreateSlider(SecSoundsFX, "Camera FOV Value", _G.CustomFOVValue, 50, 120, false, function(val)
    _G.CustomFOVValue = val
    if _G.CustomFOVActive then Camera.FieldOfView = val end
end)
CreateToggle(SecSoundsFX, "Motion Blur Effect", false, function(st) _G.BlurActive = st end)
CreateSlider(SecSoundsFX, "Blur Intensity", _G.BlurSize, 2, 24, false, function(val) _G.BlurSize = val end)
CreateToggle(SecSoundsFX, "Kill Flash Screen FX", true, function(st) _G.KillFlashActive = st end)

-- 2. VISUALS TAB
local SecESP = CreateSection(Tabs["Visuals"], "Player ESP & Outlines")
CreateToggle(SecESP, "Role ESP & Chams", false, function(st)
    _G.ChamsActive = st
    if not st then ClearAllChams() end
end)
CreateDropdown(SecESP, "Player Chams Style", ChamsStyleOptionNames, _G.PlayerChamsStyle or "Fill / Glow", function(selected)
    _G.PlayerChamsStyle = selected
    _G.ChamsStyle = selected
    if not _G.ChamsActive then ClearAllChams() end
end)
CreateSlider(SecESP, "Fill Transparency", math.round((_G.ChamsFillTransparency or 0.35) * 100), 0, 100, false, function(val)
    _G.ChamsFillTransparency = val / 100
end)
CreateSlider(SecESP, "Outline Transparency", math.round((_G.ChamsOutlineTransparency or 0.0) * 100), 0, 100, false, function(val)
    _G.ChamsOutlineTransparency = val / 100
end)
CreateDropdown(SecESP, "Murderer Color", ColorOptionNames, _G.SelectedMurdererColor or "Blood Crimson", function(selected)
    _G.SelectedMurdererColor = selected
    Core.UpdateRoleColors()
end)
CreateDropdown(SecESP, "Sheriff Color", ColorOptionNames, _G.SelectedSheriffColor or "Sky Blue", function(selected)
    _G.SelectedSheriffColor = selected
    Core.UpdateRoleColors()
end)
CreateDropdown(SecESP, "Innocent Color", ColorOptionNames, _G.SelectedInnocentColor or "Acid Green", function(selected)
    _G.SelectedInnocentColor = selected
    Core.UpdateRoleColors()
end)
CreateToggle(SecESP, "Dropped Gun ESP", false, function(st) _G.DroppedGunEspActive = st end)
CreateDropdown(SecESP, "Dropped Gun Color", ColorOptionNames, _G.SelectedDroppedGunColor or "Cyber Cyan", function(selected)
    _G.SelectedDroppedGunColor = selected
end)
CreateDropdown(SecESP, "Dropped Gun Chams Style", ChamsStyleOptionNames, _G.DroppedGunChamsStyle or "Fill / Glow", function(selected)
    _G.DroppedGunChamsStyle = selected
end)
CreateToggle(SecESP, "Murderer Proximity Repel Shield", false, function(st) _G.MurdererRepelActive = st end)
CreateToggle(SecESP, "Snaplines to Targets", false, function(st) _G.SnaplinesActive = st end)

local SecSelfChams = CreateSection(Tabs["Visuals"], "Self & Weapon Chams")
CreateToggle(SecSelfChams, "Self Chams (Local Character)", false, function(st) _G.SelfChamsActive = st end)
CreateDropdown(SecSelfChams, "Self Chams Style", ChamsStyleOptionNames, _G.SelfChamsStyle or "Fill / Glow", function(selected)
    _G.SelfChamsStyle = selected
end)
CreateDropdown(SecSelfChams, "Self Cham Color", ColorOptionNames, _G.SelectedSelfChamColor, function(selected)
    _G.SelectedSelfChamColor = selected
end)
CreateToggle(SecSelfChams, "In-Hand Weapon Chams", false, function(st) _G.WeaponChamsActive = st end)
CreateDropdown(SecSelfChams, "Weapon Chams Style", ChamsStyleOptionNames, _G.WeaponChamsStyle or "Fill / Glow", function(selected)
    _G.WeaponChamsStyle = selected
end)
CreateDropdown(SecSelfChams, "Weapon Cham Color", ColorOptionNames, _G.SelectedWeaponChamColor or "Sunset Gold", function(selected)
    _G.SelectedWeaponChamColor = selected
end)

local SecHitVisuals = CreateSection(Tabs["Visuals"], "HvH Hit Visuals & Tracers")
CreateToggle(SecHitVisuals, "HvH Hit Logs (Damage Feed)", true, function(st) _G.HitLogsActive = st end)
CreateToggle(SecHitVisuals, "HvH Hitmarkers", true, function(st) _G.HitmarkersActive = st end)
CreateToggle(SecHitVisuals, "HvH Hit Sounds", true, function(st) _G.HitSoundsActive = st end)
CreateDropdown(SecHitVisuals, "Select Hit Sound", {"Skeet", "Neverlose", "Bell", "Bubble", "Bonk (Meme)", "Bespolezno (Russian)", "Hitmarker CS:GO"}, "Skeet", function(s)
    _G.SelectedHitSound = s
    pcall(function()
        local testSound = Instance.new("Sound")
        testSound.SoundId = HitSounds[s] or HitSounds["Skeet"]
        testSound.Volume = _G.HitSoundVolume or 3
        testSound.Parent = SoundService
        testSound:Play()
        task.delay(1.5, function() testSound:Destroy() end)
    end)
end)
CreateSlider(SecHitVisuals, "Hit Sound Volume", _G.HitSoundVolume or 3, 1, 10, false, function(val) _G.HitSoundVolume = val end)
CreateToggle(SecHitVisuals, "Bullet Tracers (HvH Beams)", true, function(st) _G.TracersActive = st end)
CreateDropdown(SecHitVisuals, "Tracer Color Preset", ColorOptionNames, _G.SelectedTracerColor or "Blood Red", function(selected)
    _G.SelectedTracerColor = selected
end)
CreateDropdown(SecHitVisuals, "Tracer Style", {"Dual Pulse (White Core)", "Solid Neon Laser", "Lightning Spark (Twitch)", "Rainbow Sine"}, _G.TracerStyle or "Dual Pulse (White Core)", function(selected)
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

local SecHands = CreateSection(Tabs["Visuals"], "Hands Positioning (Вытянуть руки)")
CreateToggle(SecHands, "Hands Positioning (Вытянуть руки)", false, function(st)
    _G.HandsPositionActive = st
end)
CreateDropdown(SecHands, "Hands Target Arm", {"Right Arm (Weapon)", "Both Arms", "Left Arm"}, _G.HandsTarget or "Right Arm (Weapon)", function(val)
    _G.HandsTarget = val
end)
CreateSlider(SecHands, "Hands Forward / Back (Вытянуть)", _G.HandsStretchForward or 0.0, -5.0, 5.0, true, function(val)
    _G.HandsStretchForward = val
end)
CreateSlider(SecHands, "Hands Left / Right (Spread)", _G.HandsSpreadLeftRight or 0.0, -5.0, 5.0, true, function(val)
    _G.HandsSpreadLeftRight = val
end)
CreateSlider(SecHands, "Hands Height (Up / Down)", _G.HandsHeightUpDown or 0.0, -5.0, 5.0, true, function(val)
    _G.HandsHeightUpDown = val
end)
CreateSlider(SecHands, "Hands Angle Pitch (Наклон 45°)", _G.HandsAnglePitch or 0, -90, 90, false, function(val)
    _G.HandsAnglePitch = val
end)
CreateSlider(SecHands, "Hands Angle Yaw (Поворот)", _G.HandsAngleYaw or 0, -180, 180, false, function(val)
    _G.HandsAngleYaw = val
end)
CreateSlider(SecHands, "Hands Angle Roll (Крен)", _G.HandsAngleRoll or 0, -180, 180, false, function(val)
    _G.HandsAngleRoll = val
end)

-- ========================================================================
-- 3. SKINS TAB (COLUMN 1: MM2 SKINS & GODLIES | COLUMN 2: CUSTOM 3D MODELS)
-- ========================================================================
-- COLUMN 1: MM2 OFFICIAL SKINS & GODLIES
local SecMM2Skins = CreateSection(Tabs["Skins"], "MM2 Official Skins (Column 1)")
CreateToggle(SecMM2Skins, "Enable MM2 Knife Skin", false, function(st)
    _G.CustomKnifeActive = st
    UpdateCustomWeapons()
end)
CreateDropdown(SecMM2Skins, "MM2 Knife Skin", KnifeModelNames, _G.SelectedKnifeModel, function(val)
    _G.SelectedKnifeModel = val
    if _G.CustomKnifeActive then UpdateCustomWeapons() end
end)
CreateToggle(SecMM2Skins, "Enable MM2 Gun Skin", false, function(st)
    _G.CustomGunActive = st
    UpdateCustomWeapons()
end)
CreateDropdown(SecMM2Skins, "MM2 Gun Skin", GunModelNames, _G.SelectedGunModel, function(val)
    _G.SelectedGunModel = val
    if _G.CustomGunActive then UpdateCustomWeapons() end
end)
CreateDropdown(SecMM2Skins, "Weapon Material", {"Default", "Neon Glow", "ForceField", "Glass", "Chrome Metal"}, _G.CustomWeaponMaterial, function(val)
    _G.CustomWeaponMaterial = val
    if _G.CustomKnifeActive or _G.CustomGunActive then UpdateCustomWeapons() end
end)
CreateDropdown(SecMM2Skins, "Weapon Color Tint", {"Original", "Blood Red", "Cyber Cyan", "Neon Pink", "Gold", "Lime Green", "Rainbow RGB"}, _G.CustomWeaponColor, function(val)
    _G.CustomWeaponColor = val
    if _G.CustomKnifeActive or _G.CustomGunActive then UpdateCustomWeapons() end
end)
CreateDropdown(SecMM2Skins, "Weapon Aura (FX)", {"None", "Fire Flames", "Void Smoke", "Cyber Sparks", "Golden Haze", "Blood Drip"}, _G.CustomWeaponAura, function(val)
    _G.CustomWeaponAura = val
    if _G.CustomKnifeActive or _G.CustomGunActive then UpdateCustomWeapons() end
end)
CreateToggle(SecMM2Skins, "Knife Blade Trail", false, function(st)
    _G.WeaponTrailActive = st
    if _G.CustomKnifeActive then UpdateCustomWeapons() end
end)
CreateDropdown(SecMM2Skins, "Blade Trail Color", {"Rainbow RGB", "Blood Red", "Cyber Cyan", "Gold Glow", "Pure White"}, _G.SelectedWeaponTrailColor, function(val)
    _G.SelectedWeaponTrailColor = val
    if _G.CustomKnifeActive then UpdateCustomWeapons() end
end)

-- COLUMN 2: CUSTOM 3D WEAPON MODELS (AWP, AK-47, M4A1, DEAGLE, SCYTHE, ETC.)
local SecCustomModels = CreateSection(Tabs["Skins"], "Custom 3D Models: AWP, AK-47... (Column 2)")
CreateToggle(SecCustomModels, "Enable Custom 3D Gun (AWP/AK/M4)", false, function(st)
    _G.Custom3DGunActive = st
    UpdateCustomWeapons()
end)
CreateDropdown(SecCustomModels, "Custom Gun Model", CustomGunModelNames, _G.SelectedCustomGun or "AK-47 (Assault Rifle)", function(val)
    _G.SelectedCustomGun = val
    if _G.Custom3DGunActive then UpdateCustomWeapons() end
end)
CreateToggle(SecCustomModels, "Enable Custom 3D Melee (Karambit/Scythe)", false, function(st)
    _G.Custom3DMeleeActive = st
    UpdateCustomWeapons()
end)
CreateDropdown(SecCustomModels, "Custom Melee Model", CustomMeleeModelNames, _G.SelectedCustomMelee or "Karambit (Fade / Doppler)", function(val)
    _G.SelectedCustomMelee = val
    if _G.Custom3DMeleeActive then UpdateCustomWeapons() end
end)
CreateSlider(SecCustomModels, "Model Scale Size", _G.Custom3DWeaponScale or 1.0, 0.4, 2.5, true, function(val)
    _G.Custom3DWeaponScale = val
    if _G.Custom3DGunActive or _G.Custom3DMeleeActive then UpdateCustomWeapons() end
end)

CreateToggle(SecCustomModels, "Weapon In-Hand Angle & Grip", _G.CustomWeaponGripActive, function(st)
    _G.CustomWeaponGripActive = st
    _G.CustomGunGripActive = st
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomModels, "Weapon Angle Pitch (Вверх/Вниз)", _G.WeaponAnglePitch or 0, -180, 180, false, function(val)
    _G.WeaponAnglePitch = val
    _G.GunHandRotX = val
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomModels, "Weapon Angle Yaw (Влево/Вправо)", _G.WeaponAngleYaw or 0, -180, 180, false, function(val)
    _G.WeaponAngleYaw = val
    _G.GunHandRotY = val
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomModels, "Weapon Angle Roll (Гангстер боком)", _G.WeaponAngleRoll or 0, -180, 180, false, function(val)
    _G.WeaponAngleRoll = val
    _G.GunHandRotZ = val
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomModels, "Weapon Offset X (Left/Right)", _G.WeaponOffsetX or 0.0, -3.0, 3.0, true, function(val)
    _G.WeaponOffsetX = val
    _G.GunHandPosX = val
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomModels, "Weapon Offset Y (Up/Down)", _G.WeaponOffsetY or 0.0, -3.0, 3.0, true, function(val)
    _G.WeaponOffsetY = val
    _G.GunHandPosY = val
    if Weapons.UpdateCustomWeapons then Weapons.UpdateCustomWeapons() end
end)
CreateSlider(SecCustomModels, "Weapon Offset Z (Forward/Back)", _G.WeaponOffsetZ or 0.0, -3.0, 3.0, true, function(val)
    _G.WeaponOffsetZ = val
    _G.GunHandPosZ = val
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
CreateToggle(SecTrails, "Ground Footstep Rope", false, function(st)
    _G.FootRopeActive = st
    if st then
        ApplyFootstepRope()
    else
        RemoveFootstepRope()
    end
end)
CreateDropdown(SecTrails, "Ground Rope Color", {"Blood Red", "Purple HvH", "Cyber Cyan", "Electric Green", "Pure White", "Gold Glow", "Rainbow RGB"}, "Blood Red", function(selected)
    _G.SelectedRopeColor = selected
    if _G.FootRopeActive then
        ApplyFootstepRope()
    end
end)
CreateSlider(SecTrails, "Ground Rope Lifetime", _G.RopeLifetime, 0.3, 3.0, true, function(val)
    _G.RopeLifetime = val
end)
CreateSlider(SecTrails, "Ground Rope Width", _G.RopeWidth, 0.1, 1.5, true, function(val)
    _G.RopeWidth = val
end)

local SecSkyLighting = CreateSection(Tabs["Visuals"], "Skybox, Fog & Ambience")
CreateToggle(SecSkyLighting, "Atmospheric Fog", false, function(st)
    _G.FogColorActive = st
    if not st then
        Lighting.FogColor = OriginalLighting.FogColor
        Lighting.FogStart = OriginalLighting.FogStart
        Lighting.FogEnd = OriginalLighting.FogEnd
    end
end)
CreateDropdown(SecSkyLighting, "Fog Color Preset", {"Blood Red", "Purple HvH", "Cyber Cyan", "Electric Green", "Pitch Black", "Pure White"}, "Blood Red", function(selected)
    _G.SelectedFogColor = selected
end)
CreateSlider(SecSkyLighting, "Fog Distance End", _G.FogEnd, 50, 800, false, function(val)
    _G.FogEnd = val
end)
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
CreateToggle(SecCombat, "Silent Aim: Visible Only (100% Hit Reg)", true, function(st)
    _G.SilentAimVisibleOnly = st
end)
CreateToggle(SecCombat, "Silent Aim: Multi-Bone Scan (Head/Body/Arms)", true, function(st)
    _G.MultiBoneScan = st
end)
CreateToggle(SecCombat, "Allow Wallbang (Unchecked Shots)", false, function(st)
    _G.SilentAimWallbang = st
end)
CreateDropdown(SecCombat, "Silent Aim Target", {"Murderer Only", "All Enemies / Players"}, _G.SilentAimTargetMode or "Murderer Only", function(val)
    _G.SilentAimTargetMode = val
end)
CreateSlider(SecCombat, "Silent Aim FOV Radius", _G.SilentAimFOV or 300, 40, 600, false, function(val)
    _G.SilentAimFOV = val
end)
CreateToggle(SecCombat, "Auto Shoot (Sheriff Triggerbot)", _G.AutoShootSheriff, function(st)
    _G.AutoShootSheriff = st
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
Notify("Umbrella MM2", "v11.0 Loaded! Tap Umbrella button or press RCtrl to toggle", 4)
