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

-- 1. Prediction & Line-of-Sight AWALL Calculation
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

-- ФУНКЦИЯ ПРОВЕРКИ AWALL И РАСЧЕТА ДИСТАНЦИИ (Строгая проверка линии огня от персонажа)
local function CheckLineOfSight(targetPart)
    local myChar = LocalPlayer.Character
    if not myChar or not targetPart then return false, 999 end
    
    local myOrigin = (myChar:FindFirstChild("Head") and myChar.Head.Position)
        or (myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0))
        or Camera.CFrame.Position
        
    local endPos = targetPart.Position
    local direction = (endPos - myOrigin)
    local dist = direction.Magnitude
    if dist > 350 then return false, dist end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {myChar, Camera}
    if workspace:FindFirstChild("CoinContainer") then table.insert(ignore, workspace.CoinContainer) end
    if workspace:FindFirstChild("Coins") then table.insert(ignore, workspace.Coins) end
    if workspace:FindFirstChild("Spawns") then table.insert(ignore, workspace.Spawns) end
    raycastParams.FilterDescendantsInstances = ignore
    
    local currentOrigin = myOrigin
    local currentDir = direction
    local maxPasses = 5
    for pass = 1, maxPasses do
        local result = workspace:Raycast(currentOrigin, currentDir, raycastParams)
        if not result then
            -- Reached target without hitting any solid obstacle
            return true, dist
        end
        local hitInst = result.Instance
        if targetPart.Parent and hitInst:IsDescendantOf(targetPart.Parent) then
            return true, result.Distance
        end
        -- Прозрачные не коллизионные объекты (монеты, частицы, стекло, триггеры) не блокируют пули
        if hitInst.CanCollide == false or hitInst.Transparency > 0.85 or hitInst.Name:lower():find("coin") or hitInst.Name:lower():find("trigger") then
            local hitPos = result.Position
            local remainingDir = endPos - hitPos
            if remainingDir.Magnitude < 0.3 then
                return true, dist
            end
            currentOrigin = hitPos + (remainingDir.Unit * 0.1)
            currentDir = endPos - currentOrigin
        else
            -- Стена карты: сервер MM2 гарантированно отклонит урон
            return false, result.Distance
        end
    end
    return false, dist
end

local function CheckAwallRay(targetPart)
    return CheckLineOfSight(targetPart)
end

-- СКАНИРОВАНИЕ КОСТЕЙ: если голова за стеной, находим видимое плечо/туловище для 100% хитрега
local function GetBestVisibleBone(char)
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local rArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
    local lArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
    
    local bones = {}
    if _G.AimBone == "Head" then
        bones = {head, torso, hrp, rArm, lArm}
    else
        bones = {torso, hrp, head, rArm, lArm}
    end
    
    for _, bone in ipairs(bones) do
        if bone then
            local vis, _ = CheckLineOfSight(bone)
            if vis then
                return bone
            end
        end
    end
    
    if _G.SilentAimWallbang then
        return bones[1] or head or hrp
    end
    return nil
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

-- 6. HVH: AUTO SHOOT MURDERER FOR SHERIFF (Strict LoS & 1.1s Revolver Reload Cooldown)
local lastAutoShootTime = 0
task.spawn(function()
    while true do
        task.wait(0.08)
        if _G.AutoShootSheriff and (GetRole(LocalPlayer) == "Sheriff" or GetRole(LocalPlayer) == "Innocent") and LocalPlayer.Character then
            if tick() - lastAutoShootTime >= (_G.AutoShootCooldown or 1.1) then
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
                        if player ~= LocalPlayer and GetRole(player) == "Murderer" and player.Character then
                            local bestBone = GetBestVisibleBone(player.Character)
                            if bestBone then
                                local isVisible, _ = CheckLineOfSight(bestBone)
                                if isVisible then
                                    lastAutoShootTime = tick()
                                    local predPos = GetPredictedPosition(bestBone)
                                    gun:Activate()
                                    
                                    local knifeServer = gun:FindFirstChild("KnifeServer") or gun:FindFirstChild("GunServer")
                                    local shootRemote = (knifeServer and knifeServer:FindFirstChild("ShootGun")) or gun:FindFirstChild("ShootGun")
                                    if shootRemote and shootRemote:IsA("RemoteFunction") then
                                        pcall(function() shootRemote:InvokeServer(1, predPos, "Gun") end)
                                    elseif shootRemote and shootRemote:IsA("RemoteEvent") then
                                        pcall(function() shootRemote:FireServer(1, predPos, "Gun") end)
                                    end
                                    
                                    if Umbrella.HvH and Umbrella.HvH.CreateBulletTracer then
                                        local char = LocalPlayer.Character
                                        local startPos = (char and char:FindFirstChild("Head") and char.Head.Position) or Camera.CFrame.Position
                                        Umbrella.HvH.CreateBulletTracer(startPos, predPos)
                                    end
                                    OnHitRegistered(player, predPos, bestBone.Name)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

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

-- 5. Closest Target & Weapon Checking (With Multi-Bone LoS & Hit Reg Verification)
local function GetClosestTarget()
    local myRole = GetRole(LocalPlayer)
    local closestPlayer = nil
    local bestBoneTarget = nil
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
                local bone = nil
                if _G.SilentAimVisibleOnly or not _G.SilentAimWallbang then
                    bone = GetBestVisibleBone(player.Character)
                else
                    bone = GetAimbotBone(player.Character) or player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
                end
                
                if bone then
                    local predPos = GetPredictedPosition(bone)
                    local screenPos, onScreen = Camera:WorldToViewportPoint(predPos)
                    if onScreen and screenPos.Z > 0 then
                        local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        local maxAllowed = _G.SilentAimFOV or (_G.ShowFOVCircle and _G.FOVCircleRadius or 1200)
                        if mouseDist <= maxAllowed and mouseDist < shortestDist then
                            shortestDist = mouseDist
                            closestPlayer = player
                            bestBoneTarget = bone
                        end
                    end
                end
            end
        end
    end
    return closestPlayer, bestBoneTarget
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
            local target, bone = GetClosestTarget()
            if target and target.Character then
                local aimBone = bone or GetAimbotBone(target.Character)
                if aimBone then
                    local predPos = GetPredictedPosition(aimBone)
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

-- 2. REAL INVISIBLE SILENT AIM (100% Crash-Proof & Delta-Optimized Metamethod Engine)
local CurrentSilentTarget = nil
local CurrentSilentBone = nil
local CurrentSilentPos = nil
local isScanningSilent = false
local isInsideHook = false

-- Asynchronous target scanner (Runs on Heartbeat with 0.05s throttle, never inside metamethods!)
RunService.Heartbeat:Connect(function()
    if not _G.RealSilentAimActive then
        CurrentSilentTarget = nil
        CurrentSilentBone = nil
        CurrentSilentPos = nil
        return
    end
    if isScanningSilent then return end
    isScanningSilent = true
    
    local success, target, bone = pcall(GetClosestTarget)
    if success and target and bone then
        CurrentSilentTarget = target
        CurrentSilentBone = bone
        CurrentSilentPos = GetPredictedPosition(bone)
    else
        CurrentSilentTarget = nil
        CurrentSilentBone = nil
        CurrentSilentPos = nil
    end
    
    isScanningSilent = false
end)

local OldIndex = nil
local OldNamecall = nil

if hookmetamethod then
    -- Safe __index hook: ONLY intercepts Player Mouse instances to prevent global engine lag/crashes
    pcall(function()
        OldIndex = hookmetamethod(game, "__index", function(self, key)
            if not isInsideHook and _G.RealSilentAimActive then
                local isCaller = false
                if checkcaller then
                    pcall(function() isCaller = checkcaller() end)
                end
                
                if not isCaller and CurrentSilentPos and typeof(self) == "Instance" and self:IsA("Mouse") then
                    if key == "Hit" or key == "hit" then
                        return CFrame.new(CurrentSilentPos)
                    elseif key == "Target" or key == "target" then
                        if CurrentSilentBone then
                            return CurrentSilentBone
                        end
                    end
                end
            end
            return OldIndex(self, key)
        end)
    end)

    -- Safe __namecall hook: Intercepts MM2 RemoteEvents & RemoteFunctions (ShootGun, Throw, Shoot)
    pcall(function()
        OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            if isInsideHook or not _G.RealSilentAimActive then
                return OldNamecall(self, ...)
            end
            
            local isCaller = false
            if checkcaller then
                pcall(function() isCaller = checkcaller() end)
            end
            if isCaller then
                return OldNamecall(self, ...)
            end
            
            local method = getnamecallmethod and getnamecallmethod()
            if method == "FireServer" or method == "fireServer" or method == "InvokeServer" or method == "invokeServer" then
                if CurrentSilentPos and CurrentSilentTarget then
                    local remoteName = tostring(self.Name):lower()
                    if remoteName:find("shoot") or remoteName:find("throw") or remoteName:find("knife") or remoteName:find("gun") then
                        isInsideHook = true
                        local args = {...}
                        local replaced = false
                        for i, arg in ipairs(args) do
                            if typeof(arg) == "Vector3" then
                                args[i] = CurrentSilentPos
                                replaced = true
                            elseif typeof(arg) == "CFrame" then
                                args[i] = CFrame.new(arg.Position, CurrentSilentPos)
                                replaced = true
                            end
                        end
                        if not replaced and #args > 0 then
                            args[1] = CurrentSilentPos
                        end
                        
                        -- Draw bullet tracer & hit log
                        if Umbrella.HvH and Umbrella.HvH.CreateBulletTracer then
                            local myChar = LocalPlayer.Character
                            local origin = (myChar and myChar:FindFirstChild("Head") and myChar.Head.Position) or Camera.CFrame.Position
                            Umbrella.HvH.CreateBulletTracer(origin, CurrentSilentPos)
                        end
                        OnHitRegistered(CurrentSilentTarget, CurrentSilentPos, CurrentSilentBone and CurrentSilentBone.Name or "Head")
                        
                        local ret = OldNamecall(self, unpack(args))
                        isInsideHook = false
                        return ret
                    end
                end
            end
            
            return OldNamecall(self, ...)
        end)
    end)
end

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
        
        local target, targetBone = _G.RealSilentAimActive and GetClosestTarget()
        local hitPos = nil
        if target and target.Character then
            local bone = targetBone or GetAimbotBone(target.Character) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
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
Combat.CheckLineOfSight = CheckLineOfSight
Combat.GetBestVisibleBone = GetBestVisibleBone
Combat.GetClosestTarget = GetClosestTarget

return Combat