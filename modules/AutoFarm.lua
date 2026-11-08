--[[
    ========================================================================
    UMBRELLA CORPORATION — MM2 HVH SUPREMACY
    Module: AutoFarm (MM2 Coin Auto Collection Engine)
    ========================================================================
--]]

local AutoFarm = {}
local Umbrella = _G.Umbrella or {}
local Core = Umbrella.Core or {}
local Services = Core.Services or {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}
local Players = Services.Players
local LocalPlayer = Core.LocalPlayer or Players.LocalPlayer
local GetRole = Core.GetRole or function() return "Innocent" end

-- АВТОПОДБОР ПИСТОЛЕТА (ДВА РЕЖИМА: ТЕЛЕПОРТ И НА РАССТОЯНИИ BBOX/TOUCH)
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoPickupActive and GetRole(LocalPlayer) ~= "Murderer" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local gunInstance = nil
            local drop = workspace:FindFirstChild("GunDrop")
            if drop then
                gunInstance = drop
            else
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == "GunDrop" or (obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent.Name == "LeftHand") then
                        if obj:IsA("BasePart") then
                            gunInstance = obj
                            break
                        elseif obj.Parent:IsA("BasePart") then
                            gunInstance = obj.Parent
                            break
                        end
                    end
                end
            end
            
            if gunInstance and gunInstance:IsA("BasePart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                
                if _G.PickupMode == "Distance" or _G.PickupMode == "Reach" then
                    local char = LocalPlayer.Character
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local touchHandle = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or root
                    
                    if firetouchinterest and touchHandle then
                        firetouchinterest(touchHandle, gunInstance, 0)
                        firetouchinterest(touchHandle, gunInstance, 1)
                    end
                    
                    if (root.Position - gunInstance.Position).Magnitude < 100 then
                        if gunInstance:FindFirstChildOfClass("TouchTransmitter") then
                            local oldCFrame = gunInstance.CFrame
                            gunInstance.CFrame = root.CFrame
                            task.wait(0.05)
                            if gunInstance and gunInstance.Parent then
                                gunInstance.CFrame = oldCFrame
                            end
                        end
                    end
                else
                    local oldCFrame = hrp.CFrame
                    local checkTime = 0
                    while gunInstance and gunInstance.Parent and checkTime < 0.3 do
                        hrp.CFrame = gunInstance.CFrame
                        RunService.Heartbeat:Wait()
                        checkTime = checkTime + game:GetService("RunService").Heartbeat:Wait()
                    end
                    hrp.CFrame = oldCFrame
                    task.wait(0.5)
                end
            end
        end
    end
end)


return AutoFarm
