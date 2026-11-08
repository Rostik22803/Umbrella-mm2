--[[
    ========================================================================
    UMBRELLA CORPORATION — MM2 HVH SUPREMACY
    Module: Combat (Aimbot, Silent Aim, Prediction, AWALL, Reach, AutoShoot)
    ========================================================================
--]]

local Combat = {}
local Umbrella = _G.Umbrella or {}
local Core = Umbrella.Core or {}
local HvH = Umbrella.HvH or {}
local Services = Core.Services or {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService")
}
local Players = Services.Players
local LocalPlayer = Core.LocalPlayer or Players.LocalPlayer
local Camera = Core.Camera or workspace.CurrentCamera
local UserInputService = Services.UserInputService
local RunService = Services.RunService

local GetRole = Core.GetRole or function() return "Innocent" end
local IsHoldingWeapon = Core.IsHoldingWeapon or function() return false end
local OnHitRegistered = function(...)
    if Umbrella.HvH and Umbrella.HvH.OnHitRegistered then
        Umbrella.HvH.OnHitRegistered(...)
    end
end

-- 1. Prediction & AWALL Calculation
local function GetAimbotBone(char)
    if not char then return nil end
    if _G.AimBone == "Torso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    else
        return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    end
end

-- ФУНКЦИЯ РАСЧЕТА ПРЕДИКТА (Фильтрация гравитации Y, чтобы прицел не падал в пятки)
local function GetPredictedPosition(targetPart)
    if not targetPart then return Vector3.new(0, 0, 0) end
    local basePos = targetPart.Position
    
    -- Фикс: если передали HRP, смещаем вверх на уровень груди/головы (+1.6 стадса)
    if targetPart.Name == "HumanoidRootPart" or targetPart.Name == "LowerTorso" then
        basePos = basePos + Vector3.new(0, 1.6, 0)
    end
    
    if _G.PredictionActive then
        local char = targetPart.Parent
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or targetPart)
        if root then
            local vel = root.Velocity
            -- Ограничиваем вертикальную скорость, предотвращая смещение в пол
            local predY = math.clamp(vel.Y, -2, 7)
            local horizontalVel = Vector3.new(vel.X, predY, vel.Z)
            return basePos + (horizontalVel * _G.PredictionAmount)
        end
    end
    return basePos
end

-- ФУНКЦИЯ ПРОВЕРКИ AWALL И РАСЧЕТА ДИСТАНЦИИ
local function CheckAwallRay(targetPart)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return false, 999 
    end
    
    local startPos = Camera.CFrame.Position
    local endPos = targetPart and GetPredictedPosition(targetPart) or (Camera.CFrame.Position + Camera.CFrame.LookVector * 100)
    local direction = (endPos - startPos)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(startPos, direction, raycastParams)
    
    if result then
        if targetPart and targetPart.Parent and result.Instance:IsDescendantOf(targetPart.Parent) then
            return true, result.Distance
        else
            return false, result.Distance
        end
    end
    return true, 100
end


-- 2. Knife Reach, Fast Automatic Gun, Auto Shoot Sheriff
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
                                OnHitRegistered(player, targetHrp.Position, "Torso")
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
                                OnHitRegistered(player, predPos, "HumanoidRootPart")
                            end
                        end
                    end
                end
            end
        end
    end
end)


-- 3. Backstab Teleport
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


-- 4. Hitbox Expander
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


-- 5. Closest Target & Weapon Checking
local function GetClosestTarget()
    local myRole = GetRole(LocalPlayer)
    local closestPlayer = nil
    local shortestDist = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetIsMurderer = false
            if Core.IsMurderer then
                targetIsMurderer = Core.IsMurderer(player)
            else
                targetIsMurderer = (GetRole(player) == "Murderer")
                    or (player.Character and (player.Character:FindFirstChild("Knife") or player.Character:FindFirstChild("Slash")))
                    or (player:FindFirstChild("Backpack") and (player.Backpack:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Slash")))
            end
            
            local validTarget = false
            if _G.SilentAimTargetMode == "All Enemies / Players" then
                validTarget = true
            elseif myRole == "Murderer" then
                validTarget = not targetIsMurderer
            else
                validTarget = targetIsMurderer
            end
            
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if validTarget and humanoid and humanoid.Health > 0 then
                local bone = GetAimbotBone(player.Character) or player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
                if bone then
                    local canHit = true
                    if not _G.SilentAimWallbang and _G.AwallCheckActive then
                        canHit = CheckAwallRay(bone)
                    end
                    if canHit then
                        local predPos = GetPredictedPosition(bone)
                        local screenPos, onScreen = Camera:WorldToViewportPoint(predPos)
                        if onScreen and screenPos.Z > 0 then
                            local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            local maxAllowed = _G.SilentAimFOV or (_G.ShowFOVCircle and _G.FOVCircleRadius or 1200)
                            if mouseDist <= maxAllowed and mouseDist < shortestDist then
                                shortestDist = mouseDist
                                closestPlayer = player
                            end
                        end
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


-- 6. Camera Lock Aimbot & Metamethod Silent Aim Hooks
-- 1. CAMERA LOCK AIMBOT (С ИДЕАЛЬНОЙ НАВОДКОЙ НА ГОЛОВУ И ПЛАВНОСТЬЮ)
RunService.RenderStepped:Connect(function()
    if _G.CameraAimActive and (IsHoldingWeapon() or _G.AlwaysAim) then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or _G.AlwaysAim then
            local target = GetClosestTarget()
            if target and target.Character then
                local bone = GetAimbotBone(target.Character)
                if bone then
                    local predPos = GetPredictedPosition(bone)
                    local targetCF = CFrame.new(Camera.CFrame.Position, predPos)
                    if _G.AimSmoothness and _G.AimSmoothness > 1 then
                        local alpha = math.clamp(1 / _G.AimSmoothness, 0.1, 1)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
                    else
                        Camera.CFrame = targetCF
                    end
                end
            end
        end
    end
end)

-- 2. REAL INVISIBLE SILENT AIM (MM2 Specialized Hook for Shoot/Stab/Throw Remotes & Index/Namecall)
local Mouse = LocalPlayer:GetMouse()
local OldIndex = nil
OldIndex = hookmetamethod(game, "__index", function(self, key)
    if _G.RealSilentAimActive and not checkcaller() then
        if key == "Hit" or key == "hit" then
            local target = GetClosestTarget()
            if target and target.Character then
                local bone = GetAimbotBone(target.Character) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                if bone then
                    local predPos = GetPredictedPosition(bone)
                    return CFrame.new(predPos)
                end
            end
        elseif key == "Target" or key == "target" then
            local target = GetClosestTarget()
            if target and target.Character then
                local bone = GetAimbotBone(target.Character) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                if bone then
                    return bone
                end
            end
        end
    end
    return OldIndex(self, key)
end)

local OldNamecall = nil
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if _G.RealSilentAimActive and not checkcaller() then
        -- 1. Intercept workspace:Raycast
        if method == "Raycast" then
            local target = GetClosestTarget()
            if target and target.Character then
                local bone = GetAimbotBone(target.Character) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                if bone then
                    local predPos = GetPredictedPosition(bone)
                    local origin = args[1]
                    if typeof(origin) == "Vector3" then
                        args[2] = (predPos - origin).Unit * 1000
                        if Umbrella.HvH and Umbrella.HvH.CreateBulletTracer then
                            Umbrella.HvH.CreateBulletTracer(origin, predPos)
                        end
                        OnHitRegistered(target, predPos, bone.Name)
                        return OldNamecall(self, unpack(args))
                    end
                end
            end
        -- 2. Intercept FindPartOnRay methods
        elseif method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
            local target = GetClosestTarget()
            if target and target.Character then
                local bone = GetAimbotBone(target.Character) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                if bone then
                    local predPos = GetPredictedPosition(bone)
                    local ray = args[1]
                    if typeof(ray) == "Ray" then
                        args[1] = Ray.new(ray.Origin, (predPos - ray.Origin).Unit * 1000)
                        if Umbrella.HvH and Umbrella.HvH.CreateBulletTracer then
                            Umbrella.HvH.CreateBulletTracer(ray.Origin, predPos)
                        end
                        OnHitRegistered(target, predPos, bone.Name)
                        return OldNamecall(self, unpack(args))
                    end
                end
            end
        -- 3. Intercept Viewport rays
        elseif method == "ScreenPointToRay" or method == "ViewportPointToRay" then
            local target = GetClosestTarget()
            if target and target.Character then
                local bone = GetAimbotBone(target.Character) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                if bone then
                    local predPos = GetPredictedPosition(bone)
                    local origin = Camera.CFrame.Position
                    return Ray.new(origin, (predPos - origin).Unit * 1000)
                end
            end
        -- 4. Intercept Remote Events & Remote Functions
        elseif method == "FireServer" or method == "fireServer" or method == "InvokeServer" or method == "invokeServer" then
            local remoteName = tostring(self.Name)
            local target = GetClosestTarget()
            if target and target.Character then
                local bone = GetAimbotBone(target.Character) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                local predPos = bone and GetPredictedPosition(bone) or (target.Character.PrimaryPart and target.Character.PrimaryPart.Position)
                if predPos then
                    local replaced = false
                    for i, arg in ipairs(args) do
                        if typeof(arg) == "Vector3" then
                            args[i] = predPos
                            replaced = true
                        elseif typeof(arg) == "CFrame" then
                            args[i] = CFrame.new(arg.Position, predPos)
                            replaced = true
                        end
                    end
                    if replaced or remoteName == "Shoot" or remoteName == "ShootServer" or remoteName == "ShootGun" or remoteName == "Throw" or remoteName == "KnifeServer" then
                        if not replaced and #args > 0 then
                            args[1] = predPos
                        end
                        local char = LocalPlayer.Character
                        local startPos = (char and char:FindFirstChild("Head") and char.Head.Position) or Camera.CFrame.Position
                        if Umbrella.HvH and Umbrella.HvH.CreateBulletTracer then
                            Umbrella.HvH.CreateBulletTracer(startPos, predPos)
                        end
                        OnHitRegistered(target, predPos, bone and bone.Name or "HumanoidRootPart")
                        return OldNamecall(self, unpack(args))
                    end
                end
            end
        end
    end
    
    return OldNamecall(self, ...)
end)

-- Auto-tracer & Active Shoot Listener for held weapons
local function HookToolTracer(tool)
    if not tool or not tool:IsA("Tool") then return end
    if tool:GetAttribute("UmbrellaTracerBound") then return end
    tool:SetAttribute("UmbrellaTracerBound", true)
    
    tool.Activated:Connect(function()
        if not _G.TracersActive then return end
        local isGun = (tool.Name == "Gun" or tool.Name == "Revolver" or tool:FindFirstChild("ShootGun") or tool:FindFirstChild("KnifeServer"))
        if not isGun then return end
        
        local handle = tool:FindFirstChild("Handle")
        local startPos = (handle and handle.Position) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character.Head.Position) or Camera.CFrame.Position
        
        local target = _G.RealSilentAimActive and GetClosestTarget()
        local hitPos = nil
        if target and target.Character then
            local bone = GetAimbotBone(target.Character) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if bone then hitPos = GetPredictedPosition(bone) end
        end
        if not hitPos then
            local mouse = LocalPlayer:GetMouse()
            hitPos = (mouse and mouse.Hit and mouse.Hit.Position) or (startPos + Camera.CFrame.LookVector * 250)
        end
        
        if Umbrella.HvH and Umbrella.HvH.CreateBulletTracer then
            Umbrella.HvH.CreateBulletTracer(startPos, hitPos)
        end
    end)
end

if LocalPlayer.Character then
    for _, t in ipairs(LocalPlayer.Character:GetChildren()) do
        if t:IsA("Tool") then HookToolTracer(t) end
    end
    LocalPlayer.Character.ChildAdded:Connect(function(c)
        if c:IsA("Tool") then HookToolTracer(c) end
    end)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(c)
        if c:IsA("Tool") then HookToolTracer(c) end
    end)
end)


Combat.GetPredictedPosition = GetPredictedPosition
Combat.GetAimbotBone = GetAimbotBone
Combat.CheckAwallRay = CheckAwallRay
Combat.GetClosestTarget = GetClosestTarget

return Combat