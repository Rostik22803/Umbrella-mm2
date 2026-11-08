--[[
    ========================================================================
    UMBRELLA CORPORATION — MM2 HVH SUPREMACY
    Module: Core (Services, Roles, Defaults & Global State)
    ========================================================================
--]]

local Core = {}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

Core.Services = {
    Players = Players,
    LocalPlayer = LocalPlayer,
    Camera = Camera,
    UserInputService = UserInputService,
    RunService = RunService,
    TweenService = TweenService,
    SoundService = SoundService,
    Lighting = Lighting,
    HttpService = HttpService
}

Core.LocalPlayer = LocalPlayer
Core.Camera = Camera

-- Safe CoreGui / PlayerGui Resolution
local ParentGui = game:GetService("CoreGui")
if not pcall(function() local x = ParentGui.Name end) then
    ParentGui = LocalPlayer:WaitForChild("PlayerGui")
end
Core.ParentGui = ParentGui

-- Destroy previous UI instances
for _, old in ipairs(ParentGui:GetChildren()) do
    if old.Name == "Umbrella_MM2_Edition" then
        old:Destroy()
    end
end

-- Color Presets & Palette
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
Core.ColorPresets = ColorPresets

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
    "Muted Gray",
    "Rainbow RGB"
}
Core.ColorOptionNames = ColorOptionNames
local ChamColorPresets = ColorPresets

-- Role Colors
------------------------------------------------------------------------
local RoleColors = {
    Murderer = Color3.fromRGB(255, 35, 45),
    Sheriff  = Color3.fromRGB(30, 140, 255),
    Hero     = Color3.fromRGB(255, 215, 0),
    Innocent = Color3.fromRGB(30, 255, 100)
}

function UpdateRoleColors()
    RoleColors.Murderer = (_G.SelectedMurdererColor == "Rainbow RGB" and _G.RainbowColor) 
        or (ColorPresets[_G.SelectedMurdererColor] or Color3.fromRGB(255, 35, 45))
    RoleColors.Sheriff  = (_G.SelectedSheriffColor == "Rainbow RGB" and _G.RainbowColor) 
        or (ColorPresets[_G.SelectedSheriffColor] or Color3.fromRGB(30, 140, 255))
    RoleColors.Innocent = (_G.SelectedInnocentColor == "Rainbow RGB" and _G.RainbowColor) 
        or (ColorPresets[_G.SelectedInnocentColor] or Color3.fromRGB(30, 255, 100))
    RoleColors.Hero     = Color3.fromRGB(255, 215, 0)
end
UpdateRoleColors()

local ChamColorPresets = ColorPresets


-- MM2 Role Detection
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



-- Weapon Holding Detection
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


function Core.IsAlive(player)
    local p = player or LocalPlayer
    return p and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and p.Character:FindFirstChild("HumanoidRootPart") ~= nil
end

Core.RoleColors = RoleColors
Core.UpdateRoleColors = UpdateRoleColors
local function IsMurderer(player)
    if not player then return false end
    if GetRole(player) == "Murderer" then return true end
    if player.Character then
        if player.Character:FindFirstChild("Knife") or player.Character:FindFirstChild("Slash") then return true end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild("Slash")) then return true end
    return false
end
Core.IsMurderer = IsMurderer
Core.GetRole = GetRole
Core.IsHoldingWeapon = IsHoldingWeapon

-- Initialize Default Global Flags (_G)
------------------------------------------------------------------------
_G.ChamsActive = false
_G.ChamsStyle = "Fill / Glow"
_G.SelfChamsActive = false
_G.SelectedSelfChamColor = "Neon Pink"
_G.WeaponChamsActive = false
_G.DroppedGunEspActive = false
_G.MurdererRepelActive = false

_G.CustomModelsActive = false
_G.SelectedCustomModel = "angel"
_G.CustomModelScale = 1.0
_G.CustomModelHeightOffset = 0.0
_G.CustomModelRotation = 0

-- Custom Weapons (Knife & Gun Skins / 3D Models)
_G.CustomKnifeActive = false
_G.SelectedKnifeModel = "Luger Blade / Heat"
_G.CustomGunActive = false
_G.CustomGunGripActive = false
_G.GunHandPosX = 0.0
_G.GunHandPosY = 0.0
_G.GunHandPosZ = 0.0
_G.GunHandRotX = 0
_G.GunHandRotY = 0
_G.GunHandRotZ = 0
_G.SelectedTracerColor = "Blood Red"
_G.TracerThickness = 0.12
_G.TracerLifetime = 0.5
_G.TracerStyle = "Dual Pulse (White Core)"
_G.SilentAimTargetMode = "Murderer Only"
_G.SilentAimWallbang = true
_G.SilentAimFOV = 300
_G.SelectedGunModel = "Golden Luger"
_G.CustomWeaponMaterial = "Default"
_G.CustomWeaponColor = "Original"
_G.CustomWeaponAura = "None"
_G.WeaponTrailActive = false
_G.SelectedWeaponTrailColor = "Rainbow RGB"

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

-- HvH Advanced Movement Features
_G.AutoStrafeActive = false
_G.FlyActive = false
_G.FlySpeed = 50
_G.FastStopActive = false
_G.HighJumpActive = false
_G.JumpBoostPower = 100
_G.LongJumpActive = false
_G.LongJumpPower = 60

-- HvH Hit Visuals & Sounds
_G.HitLogsActive = true
_G.HitSoundsActive = true
_G.SelectedHitSound = "Skeet"
_G.HitSoundVolume = 3
_G.HitmarkersActive = true
_G.TracersActive = true
_G.HitEffectActive = true
_G.WatermarkActive = true

-- World, Fog & Atmospheric Visuals
_G.FogColorActive = false
_G.SelectedFogColor = "Blood Red"
_G.FogStart = 0
_G.FogEnd = 300

_G.CustomSkyActive = false
_G.SelectedSkyPreset = "Purple Galaxy"

_G.TimeOfDayActive = false
_G.TimeOfDayValue = 0

_G.AmbientActive = false
_G.SelectedAmbient = "Blood Red"

_G.FullbrightActive = false

_G.ColorCorrectionActive = false
_G.SaturationBoost = 1.2
_G.ContrastBoost = 0.3

-- Chinese Hat Visuals
_G.ChineseHatActive = false
_G.SelectedHatColor = "Blood Red"
_G.HatSpinActive = true
_G.HatHeight = 1.15
_G.HatScale = 1.2

-- Neon Trails & Ground Rope
_G.PlayerTrailActive = false
_G.SelectedTrailColor = "Blood Red"
_G.TrailLifetime = 0.6
_G.FootRopeActive = false
_G.SelectedRopeColor = "Blood Red"
_G.RopeLifetime = 0.9
_G.RopeWidth = 0.35

-- Custom Footstep Sounds & Camera FX
_G.CustomFootstepsActive = false
_G.SelectedFootstep = "Minecraft Stone"
_G.FootstepsVolume = 4
_G.CustomFOVActive = false
_G.CustomFOVValue = 70
_G.BlurActive = false
_G.BlurSize = 6
_G.KillFlashActive = true

-- Aimbot Precision & Smoothing Fix
_G.AimBone = "Head"
_G.AimSmoothness = 1
_G.ShowFOVCircle = true
_G.FOVCircleRadius = 130
_G.AlwaysAim = false

-- HvH Aesthetics & Visuals
_G.CustomCrosshairActive = false
_G.CrosshairStyle = "Classic (+)"
_G.SelectedCrosshairColor = "Blood Crimson"
_G.CrosshairSize = 8
_G.CrosshairThickness = 2
_G.CrosshairGap = 4
_G.CrosshairDot = true
_G.CrosshairDotSize = 4
_G.CrosshairDotShape = "Circle"
_G.CrosshairTopLine = true
_G.CrosshairOutline = true
_G.CrosshairOutlineThickness = 1
_G.CrosshairOutlineColor = "Pure Black"
_G.CrosshairTransparency = 0
_G.CrosshairRoundedBars = false
_G.CrosshairFollowMouse = false
_G.CrosshairSpin = false
_G.CrosshairSpinSpeed = 5
_G.CrosshairPulse = false
_G.CrosshairDynamicSpread = false
_G.CrosshairSpreadAmount = 6
_G.CrosshairTargetColor = false
_G.CrosshairRingActive = false
_G.CrosshairRingRadius = 14
_G.CrosshairRingThickness = 1
_G.SnaplinesActive = false
_G.HeadDotActive = false
_G.RGBSyncActive = false

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



return Core