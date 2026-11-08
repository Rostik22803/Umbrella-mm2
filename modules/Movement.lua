--[[
    ========================================================================
    UMBRELLA CORPORATION — MM2 HVH SUPREMACY
    Module: Movement (Speedhack, Fly, Bhop, Noclip, Anti-Fling, Strafe)
    ========================================================================
--]]

local Movement = {}
local Umbrella = _G.Umbrella or {}
local Core = Umbrella.Core or {}
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

-- 1. Auto-Strafe, Pro Fly Hack, Fast Stop, High & Long Jump
------------------------------------------------------------------------
-- 5. HVH ДВИЖЕНИЕ: AUTO-STRAFE, FLY, FAST STOP, HIGH/LONG JUMP
------------------------------------------------------------------------

-- 1. AUTO-STRAFE (Синхронизация воздушного ускорения с направлением взгляда)
RunService.RenderStepped:Connect(function()
    if _G.AutoStrafeActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp and humanoid.FloorMaterial == Enum.Material.Air then
            if humanoid.MoveDirection.Magnitude > 0 then
                local camLook = Camera.CFrame.LookVector
                local forward = Vector3.new(camLook.X, 0, camLook.Z).Unit
                local right = Vector3.new(-forward.Z, 0, forward.X)
                
                local w = UserInputService:IsKeyDown(Enum.KeyCode.W)
                local s = UserInputService:IsKeyDown(Enum.KeyCode.S)
                local a = UserInputService:IsKeyDown(Enum.KeyCode.A)
                local d = UserInputService:IsKeyDown(Enum.KeyCode.D)
                
                local wishDir = (forward * (w and 1 or (s and -1 or 0))) + (right * (d and 1 or (a and -1 or 0)))
                if wishDir.Magnitude > 0 then
                    wishDir = wishDir.Unit
                    local curVel = hrp.Velocity
                    local flatVel = Vector3.new(curVel.X, 0, curVel.Z)
                    local targetSpeed = math.max(flatVel.Magnitude, _G.SpeedValue or 35)
                    local newFlat = (flatVel + (wishDir * 3.5)).Unit * targetSpeed
                    hrp.Velocity = Vector3.new(newFlat.X, curVel.Y, newFlat.Z)
                end
            end
        end
    end
end)

-- 2. PRO FLY HACK (Идеально плавный полет через BodyVelocity + BodyGyro + Noclip)
local flyBV = nil
local flyBG = nil

local function StopSmoothFly()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    if LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p.Name == "Umbrella_FlyVelocity" or p.Name == "Umbrella_FlyGyro" then
                p:Destroy()
            end
        end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
end

local function StartSmoothFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    
    StopSmoothFly()
    
    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "Umbrella_FlyVelocity"
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Parent = hrp
    
    flyBG = Instance.new("BodyGyro")
    flyBG.Name = "Umbrella_FlyGyro"
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 9e4
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp
end

RunService.RenderStepped:Connect(function()
    if _G.FlyActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            if not flyBV or not flyBV.Parent or not flyBG or not flyBG.Parent then
                StartSmoothFly()
            end
            
            -- Держит персонажа ровно по направлению камеры без заваливания
            flyBG.CFrame = Camera.CFrame
            
            local camCF = Camera.CFrame
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            if moveDir.Magnitude > 0 then
                flyBV.Velocity = moveDir.Unit * _G.FlySpeed
            else
                flyBV.Velocity = Vector3.new(0, 0, 0)
            end
            
            -- Автоматический noclip во время полета сквозь любые препятствия
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    else
        if flyBV or flyBG then
            StopSmoothFly()
        end
    end
end)

-- 3. FAST STOP (Мгновенное погашение инерции при отпускании клавиш движения)
RunService.Heartbeat:Connect(function()
    if _G.FastStopActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp and humanoid.FloorMaterial ~= Enum.Material.Air then
            if humanoid.MoveDirection.Magnitude == 0 then
                hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- 4. HIGH JUMP BOOST И LONG JUMP BOOST
UserInputService.JumpRequest:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if _G.HighJumpActive and humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = _G.JumpBoostPower
        end
        
        if _G.LongJumpActive and hrp and humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            local camLook = Camera.CFrame.LookVector
            local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
            hrp.Velocity = hrp.Velocity + (flatLook * _G.LongJumpPower)
        end
    end
end)



-- 2. Infinite Jump
-- 12. HVH: INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJumpActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)


-- 3. Bhop
-- ПОТОК BHOP
RunService.RenderStepped:Connect(function()
    if _G.BhopActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)


-- 4. Noclip
-- Поток NOCLIP
RunService.Stepped:Connect(function()
    if _G.NoclipActive and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)


-- 5. Anti-Fling
-- ANTI-FLING
RunService.Heartbeat:Connect(function()
    if _G.AntiFlingActive and LocalPlayer.Character then
        local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            if myHrp.Velocity.Magnitude > 75 or myHrp.RotVelocity.Magnitude > 75 then
                myHrp.Velocity = Vector3.new(0, 0, 0)
                myHrp.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Velocity = Vector3.new(0, 0, 0)
                        part.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end
end)


-- 6. Speedhack
-- ПОТОК SPEEDHACK
RunService.Heartbeat:Connect(function()
    if _G.SpeedActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = _G.SpeedValue
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid.WalkSpeed ~= 16 then
                humanoid.WalkSpeed = 16
            end
        end
    end
end)


Movement.StartSmoothFly = StartSmoothFly
Movement.StopSmoothFly = StopSmoothFly

return Movement
