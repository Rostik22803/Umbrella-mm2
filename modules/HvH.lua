--[[
    ========================================================================
    UMBRELLA CORPORATION — MM2 HVH SUPREMACY
    Module: HvH (Desync, Orbit Shield, Repel, Trash Talk, Hit System)
    ========================================================================
--]]

local HvH = {}
local Umbrella = _G.Umbrella or {}
local Core = Umbrella.Core or {}
local UI = Umbrella.UI or {}
local Services = Core.Services or {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService"),
    TweenService = game:GetService("TweenService")
}
local Players = Services.Players
local LocalPlayer = Core.LocalPlayer or Players.LocalPlayer
local Camera = Core.Camera or workspace.CurrentCamera
local UserInputService = Services.UserInputService
local RunService = Services.RunService
local SoundService = Services.SoundService
local TweenService = Services.TweenService
local HitLogsContainer = UI.HitLogsContainer
local hmLines = UI.hmLines or {}
local function TriggerScreenFlash(...)
    if Umbrella.Visuals and Umbrella.Visuals.TriggerScreenFlash then
        Umbrella.Visuals.TriggerScreenFlash(...)
    end
end


local GetRole = Core.GetRole or function() return "Innocent" end
local AddHitLog = function(...)
    if Umbrella.UI and Umbrella.UI.AddHitLog then
        Umbrella.UI.AddHitLog(...)
    end
end
local ShowScreenHitmarker = function(...)
    if Umbrella.UI and Umbrella.UI.ShowScreenHitmarker then
        Umbrella.UI.ShowScreenHitmarker(...)
    end
end

-- 1. Murderer Repel Shield
-- 1. MURDERER REPEL SHIELD
RunService.RenderStepped:Connect(function()
    if _G.MurdererRepelActive and GetRole(LocalPlayer) ~= "Murderer" and LocalPlayer.Character then
        local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and GetRole(player) == "Murderer" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local mHrp = player.Character.HumanoidRootPart
                    local dist = (myHrp.Position - mHrp.Position).Magnitude
                    if dist < 22 then
                        local avoidDir = (myHrp.Position - mHrp.Position).Unit
                        myHrp.CFrame = CFrame.new(myHrp.Position + (avoidDir * 2.5), mHrp.Position)
                    end
                end
            end
        end
    end
end)


-- 2. Anti-Murderer Orbit Shield
-- 7. HVH: ANTI-MURDERER ORBIT SHIELD
local orbitAngle = 0
RunService.RenderStepped:Connect(function(dt)
    if _G.AntiMurdererOrbit and LocalPlayer.Character then
        local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and GetRole(player) == "Murderer" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local mHrp = player.Character.HumanoidRootPart
                    orbitAngle = (orbitAngle + (dt * 300)) % 360
                    local offset = Vector3.new(math.cos(math.rad(orbitAngle)) * _G.OrbitDistance, 2, math.sin(math.rad(orbitAngle)) * _G.OrbitDistance)
                    myHrp.CFrame = CFrame.new(mHrp.Position + offset, mHrp.Position)
                end
            end
        end
    end
end)


-- 3. Jitter Yaw Desync & Network Desync Fake Lag
-- 9. HVH: JITTER YAW DESYNC
local jitterToggle = false
RunService.RenderStepped:Connect(function()
    if _G.JitterActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            jitterToggle = not jitterToggle
            local angle = jitterToggle and _G.JitterRange or -_G.JitterRange
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(angle), 0)
        end
    end
end)

-- 10. HVH: NETWORK DESYNC FAKE LAG
local networkCounter = 0
RunService.Heartbeat:Connect(function()
    if _G.NetworkFakeLagActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            networkCounter = networkCounter + 1
            if networkCounter < _G.FakeLagLimit then
                if sethiddenproperty then
                    sethiddenproperty(hrp, "NetworkIsWaitingForDatabase", true)
                end
            else
                networkCounter = 0
                if sethiddenproperty then
                    sethiddenproperty(hrp, "NetworkIsWaitingForDatabase", false)
                end
            end
        end
    end
end)


-- 4. Spinbot Loop
-- ПОТОК SPINBOT
RunService.RenderStepped:Connect(function(dt)
    if _G.SpinbotActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(_G.SpinSpeed), 0)
        end
    end
end)


-- 5. Kill Trash Talk
-- 13. HVH: KILL TRASH TALK
local TrashPhrases = {
    "Umbrella Corp owns you ☂",
    "Ez hit by Umbrella MM2!",
    "L + Ratio + Umbrella Win ☂",
    "Go buy Umbrella MM2 exploit!",
    "Too ez for Umbrella HvH Engine ☂",
    "Sit down kid, Umbrella on top ☂",
    "Imagine missing with aimbot, umbrella better!",
    "Clean tap by Umbrella MM2 ☂",
    "Where is your skill? Powered by Umbrella!",
    "Dodge this? Umbrella Silent Aim active ☂",
    "Cry about it to Roblox support ☂",
    "Umbrella Supremacy v11.0 -- No chance!",
    "Skill issue detected! Install Umbrella ☂",
    "Nice try, but Umbrella is superior ☂",
    "Outplayed & Outsmarted by Umbrella MM2!",
    "You just got deleted by Umbrella ☂",
    "0 ping aim, 100% precision with Umbrella!",
    "Ez win ez game, Umbrella dominating ☂",
    "Is that your best? Umbrella owns MM2!",
    "Better luck next round! Powered by Umbrella ☂"
}

local function SendChatMessage(msg)
    local textChat = game:GetService("TextChatService")
    if textChat.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = textChat.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync(msg) end
    else
        game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer(msg, "All")
    end
end

local lastKillTime = 0
task.spawn(function()
    while true do
        task.wait(_G.KillAuraDelay)
        if _G.KillAuraActive and GetRole(LocalPlayer) == "Murderer" and LocalPlayer.Character then
            local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
            if knife then
                if knife.Parent == LocalPlayer.Backpack then
                    knife.Parent = LocalPlayer.Character
                end
                local handle = knife:FindFirstChild("Handle")
                local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHrp and handle then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local targetHrp = player.Character.HumanoidRootPart
                            local distance = (myHrp.Position - targetHrp.Position).Magnitude
                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            if distance <= _G.KillAuraRange and humanoid and humanoid.Health > 0 then
                                local stabRemote = knife:FindFirstChild("Stab") or knife:FindFirstChild("StabServer")
                                if stabRemote and stabRemote:IsA("RemoteEvent") then
                                    stabRemote:FireServer()
                                end
                                if firetouchinterest then
                                    firetouchinterest(handle, targetHrp, 0)
                                    firetouchinterest(handle, targetHrp, 1)
                                end
                                OnHitRegistered(player, targetHrp.Position, "Torso")
                                if _G.KillTrashTalkActive and tick() - lastKillTime > 3 then
                                    lastKillTime = tick()
                                    SendChatMessage(TrashPhrases[math.random(1, #TrashPhrases)])
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)


-- 6. HvH Hit System (Hit Sounds, Bullet Tracers, 3D Hit Effects, Hit Logs)
-- 4. HVH HIT SYSTEM: HIT LOGS, SOUNDS, TRACERS, HITMARKERS
------------------------------------------------------------------------

local HitSoundAssets = {
    ["Skeet"]      = "rbxassetid://4817809188",
    ["Neverlose"]  = "rbxassetid://6607204501",
    ["Bell"]       = "rbxassetid://6534947240",
    ["Bubble"]     = "rbxassetid://6534947588",
    ["COD"]        = "rbxassetid://131961136",
    ["Rust"]       = "rbxassetid://5043539502"
}

local function PlayHitSound()
    if not _G.HitSoundsActive then return end
    local assetId = HitSoundAssets[_G.SelectedHitSound] or HitSoundAssets["Skeet"]
    local sound = Instance.new("Sound")
    sound.SoundId = assetId
    sound.Volume = math.clamp((_G.HitSoundVolume or 3) * 0.25, 0.1, 5)
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    task.delay(1.5, function()
        if sound and sound.Parent then sound:Destroy() end
    end)
end

local function ShowScreenHitmarker()
    if not _G.HitmarkersActive then return end
    for _, l in ipairs(hmLines) do
        l.BackgroundTransparency = 0
    end
    task.spawn(function()
        task.wait(0.08)
        for i = 1, 8 do
            task.wait(0.02)
            for _, l in ipairs(hmLines) do
                l.BackgroundTransparency = i / 8
            end
        end
    end)
end

local TracerColorPresets = {
    ["Blood Red"]      = Color3.fromRGB(225, 30, 45),
    ["Cyber Cyan"]     = Color3.fromRGB(0, 235, 255),
    ["Neon Pink"]      = Color3.fromRGB(255, 25, 160),
    ["Electric Green"] = Color3.fromRGB(40, 255, 90),
    ["Purple HvH"]     = Color3.fromRGB(160, 45, 255),
    ["Pure White"]     = Color3.fromRGB(255, 255, 255),
    ["Gold Glow"]      = Color3.fromRGB(255, 215, 20)
}

local function CreateBulletTracer(startPos, endPos)
    if not _G.TracersActive then return end
    if not startPos or not endPos then return end
    local dist = (endPos - startPos).Magnitude
    if dist < 0.5 then return end
    
    local tracerCol = Color3.fromRGB(225, 30, 45)
    if _G.SelectedTracerColor == "Rainbow RGB" then
        tracerCol = _G.RainbowColor or Color3.fromRGB(255, 0, 0)
    elseif TracerColorPresets[_G.SelectedTracerColor] then
        tracerCol = TracerColorPresets[_G.SelectedTracerColor]
    end
    
    local thickness = _G.TracerThickness or 0.12
    local lifetime = _G.TracerLifetime or 0.5
    local style = _G.TracerStyle or "Dual Pulse (White Core)"
    
    -- Main colored neon laser beam
    local tracer = Instance.new("Part")
    tracer.Name = "Umbrella_Tracer"
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.CanTouch = false
    tracer.CanQuery = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = tracerCol
    tracer.Size = Vector3.new(thickness, thickness, dist)
    tracer.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -dist / 2)
    tracer.Transparency = 0.05
    tracer.Parent = workspace
    
    -- High-end white inner core (Skeet / Neverlose style)
    local core = nil
    if style == "Dual Pulse (White Core)" then
        core = Instance.new("Part")
        core.Name = "Umbrella_TracerCore"
        core.Anchored = true
        core.CanCollide = false
        core.CanTouch = false
        core.CanQuery = false
        core.Material = Enum.Material.Neon
        core.Color = Color3.fromRGB(255, 255, 255)
        core.Size = Vector3.new(thickness * 0.45, thickness * 0.45, dist)
        core.CFrame = tracer.CFrame
        core.Transparency = 0
        core.Parent = workspace
    end
    
    -- Smooth Tween fade-out
    local tweenInfo = TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(tracer, tweenInfo, {
        Transparency = 1,
        Size = Vector3.new(thickness * 0.1, thickness * 0.1, dist)
    })
    tw:Play()
    if core then
        local twCore = TweenService:Create(core, tweenInfo, {
            Transparency = 1,
            Size = Vector3.new(thickness * 0.05, thickness * 0.05, dist)
        })
        twCore:Play()
    end
    
    task.delay(lifetime + 0.05, function()
        if tracer and tracer.Parent then tracer:Destroy() end
        if core and core.Parent then core:Destroy() end
    end)
end

local function Create3DHitEffect(hitPos)
    if not _G.HitEffectActive then return end
    local ring = Instance.new("Part")
    ring.Name = "Umbrella_HitImpact"
    ring.Shape = Enum.PartType.Ball
    ring.Size = Vector3.new(0.8, 0.8, 0.8)
    ring.Color = Color3.fromRGB(255, 45, 55)
    ring.Material = Enum.Material.Neon
    ring.Anchored = true
    ring.CanCollide = false
    ring.CFrame = CFrame.new(hitPos)
    ring.Transparency = 0.2
    ring.Parent = workspace
    
    task.spawn(function()
        for i = 1, 8 do
            task.wait(0.025)
            if ring and ring.Parent then
                ring.Size = ring.Size + Vector3.new(0.35, 0.35, 0.35)
                ring.Transparency = 0.2 + (0.8 * (i / 8))
            end
        end
        if ring and ring.Parent then ring:Destroy() end
    end)
end

local function AddHitLog(targetName, role, hitPart, dist)
    if not _G.HitLogsActive then return end
    
    local LogFrame = Instance.new("Frame")
    LogFrame.Parent = HitLogsContainer
    LogFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
    LogFrame.Size = UDim2.new(0, 345, 0, 24)
    LogFrame.BackgroundTransparency = 0.15
    LogFrame.ClipsDescendants = true
    
    Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke", LogFrame)
    stroke.Color = Color3.fromRGB(220, 35, 45)
    stroke.Thickness = 1
    
    local Accent = Instance.new("Frame", LogFrame)
    Accent.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
    Accent.Size = UDim2.new(0, 3, 1, 0)
    Accent.BorderSizePixel = 0
    
    local roleHex = "#ff232d"
    if role == "Sheriff" then roleHex = "#1e8cff" elseif role == "Innocent" then roleHex = "#1eff64" end
    
    local Label = Instance.new("TextLabel")
    Label.Parent = LogFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.Size = UDim2.new(1, -12, 1, 0)
    Label.Font = Enum.Font.SourceSansBold
    Label.RichText = true
    Label.Text = string.format(
        '[<font color="#dc232d">UMBRELLA</font>] Hit <font color="%s">%s</font> (%s) in <font color="#ffffff">%s</font> [dist: %dm]',
        roleHex, targetName, role, hitPart or "Torso", math.round(dist or 0)
    )
    Label.TextColor3 = Color3.fromRGB(225, 230, 240)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    task.spawn(function()
        task.wait(3.5)
        local fadeTween = TweenService:Create(LogFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        })
        TweenService:Create(Label, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(Accent, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        fadeTween:Play()
        fadeTween.Completed:Wait()
        LogFrame:Destroy()
    end)
end

local lastHitRecord = {}
local function OnHitRegistered(targetPlayer, hitPos, partName)
    local targetName = targetPlayer and targetPlayer.Name or "Target"
    local now = tick()
    if lastHitRecord[targetName] and (now - lastHitRecord[targetName]) < 0.16 then
        return
    end
    lastHitRecord[targetName] = now
    
    local char = LocalPlayer.Character
    local gun = char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or char:FindFirstChild("Knife"))
    local startPos = (gun and gun:FindFirstChild("Handle") and gun.Handle.Position) or (char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position) or Camera.CFrame.Position
    local dist = (startPos - hitPos).Magnitude
    local role = targetPlayer and GetRole(targetPlayer) or "Innocent"
    
    PlayHitSound()
    ShowScreenHitmarker()
    TriggerScreenFlash()
    CreateBulletTracer(startPos, hitPos)
    Create3DHitEffect(hitPos)
    AddHitLog(targetName, role, partName or "Torso", dist)
end

-- Автоматический трекинг урона по игрокам
local function SetupDamageListener(player)
    if player == LocalPlayer then return end
    local function ConnectChar(char)
        local hum = char:WaitForChild("Humanoid", 6)
        if not hum then return end
        local lastHp = hum.Health
        hum.HealthChanged:Connect(function(newHp)
            if newHp < lastHp then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
                    local myHrp = myChar.HumanoidRootPart
                    local enemyHrp = char.HumanoidRootPart
                    if (myHrp.Position - enemyHrp.Position).Magnitude <= 120 then
                        OnHitRegistered(player, enemyHrp.Position, "HumanoidRootPart")
                    end
                end
            end
            lastHp = newHp
        end)
    end
    if player.Character then ConnectChar(player.Character) end
    player.CharacterAdded:Connect(ConnectChar)
end

for _, p in ipairs(Players:GetPlayers()) do SetupDamageListener(p) end
Players.PlayerAdded:Connect(SetupDamageListener)


HvH.PlayHitSound = PlayHitSound
HvH.CreateBulletTracer = CreateBulletTracer
HvH.Create3DHitEffect = Create3DHitEffect
HvH.OnHitRegistered = OnHitRegistered
HvH.HitSounds = HitSounds

return HvH
