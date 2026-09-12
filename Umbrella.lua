--[[
    Ocel-hub | MM2 Script — v3 (Delta-compatible)
    Author: [N]yx

    v3 fixes:
      - Watermark ALWAYS visible from boot (menu can be closed/opened)
      - Delta-safe gui parenting (no gethui dependency)
      - Watermark is a floating round button, tap = toggle menu
      - Menu opens centered; watermark can be dragged anywhere

    v3 new modules:
      Combat:  Kill All, Reach, Fast Throw, Auto Knife Throw
      Visuals: Custom Crosshair, Time Changer, Skybox Changer, Remove Fog
      Move:    Infinite Jump, Mouse TP (click-to-teleport), Platform Stand
      Auto:    Auto Pickup Knife, Auto Queue, Rejoin on Death
      Misc:    Anti Kill (auto-flee), Spectate, TP All To Me, Sound Spam, Anti-Lag
--]]

--============================================================
-- SERVICES
--============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local StarterGui        = game:GetService("StarterGui")
local VirtualUser       = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local SoundService      = game:GetService("SoundService")

local LP  = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

--============================================================
-- STATE
--============================================================
local State = {
    -- combat
    SilentAim=false, SilentHitbox="Head", SilentFOV=120,
    Aimbot=false, AimbotSmooth=0.15, AimbotFOV=90, AimbotPrediction=true,
    HitboxOverride=false,
    Triggerbot=false, TriggerDelay=0.05,
    KnifeAura=false, KnifeRange=8,
    KillAll=false,
    Reach=false, ReachDist=20,
    FastThrow=false,
    AutoKnifeThrow=false,
    BreakGun=false, AntiBackstab=false, Backtrack=false,
    AutoShoot=false, AutoReload=false, AutoDodge=false, DodgeRange=15,

    -- visuals
    ESP=false, ESPNames=true, ESPDistance=true, ESPGun=true,
    ESPTracers=false, ESPBox=true, ESPHeadDot=false, ESPSkeleton=false,
    ESPRainbow=false, Chams=false, XRay=false,
    Freecam=false, FreecamSpeed=1.5,
    Fullbright=false, GunESP=true,
    HitSound=false, HitMarker=false, KillNotify=true,
    MurdererAlert=false, MurdererDist=60,
    CustomCrosshair=false, CrosshairColor=Color3.fromRGB(0,255,120),
    TimeChanger=false, TimeValue=14,
    SkyboxChanger=false, SkyboxId="",
    RemoveFog=false,
    ColorMurderer=Color3.fromRGB(255,40,40),
    ColorSheriff=Color3.fromRGB(60,130,255),
    ColorInnocent=Color3.fromRGB(80,220,90),
    ColorGun=Color3.fromRGB(255,200,40),

    -- cosmetics
    SkinChanger=false, SkinId="",
    WeaponSkin=false, WeaponSkinId="",
    EffectChanger=false, EffectId="",
    EmoteChanger=false, EmoteId="",
    RadioChanger=false, RadioId="",
    ViewmodelFOV=70,

    -- movement
    WalkSpeed=16, JumpPower=50,
    AutoJump=false, Bhop=false,
    InfiniteJump=false,
    Fly=false, FlySpeed=60,
    Noclip=false, AntiVoid=false,
    PlatformStand=false,
    MouseTP=false,

    -- hvH
    Spinbot=false, SpinSpeed=15,
    Jitter=false, Desync=false,
    FakeLag=false, FakeLagAmount=0.15,
    AntiFling=false,

    -- automation
    AutoFarm=false, AutoGrabGun=false,
    AutoPickupKnife=false,
    AutoRole=true, AntiAFK=true,
    AutoWin=false,
    AutoQueue=false,
    RejoinOnDeath=false,
    ChatSpam=false, ChatSpamText="Ocel-hub on top", ChatSpamDelay=2,

    -- misc
    PingSpoof=false, Fling=false, PlayerInfo=false,
    AntiKill=false, AntiKillDist=30,
    Spectate="None",
    SoundSpam=false,
    AntiLag=false,

    -- ui / keys
    Open=true,
    ToggleUI="RightShift", Panic="End",
    TpRand="None", TpSpawn="None", ServerHop="None",
}

local Connections = {}
local ESPSprites  = {}
local ChamsCache  = {}
local ConfigPath  = "OcelHub_MM2.json"

--============================================================
-- HELPERS
--============================================================
local function conn(sig, fn)
    local c = sig:Connect(fn); table.insert(Connections, c); return c
end
local function cleanup()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    Connections = {}
    for _, obj in pairs(ESPSprites) do
        pcall(function() for _, v in pairs(obj) do v:Remove() end end)
    end
    ESPSprites = {}
end
local function isAlive(plr)
    plr = plr or LP
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end
local function getRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    if plr.Character:FindFirstChild("Knife") then return "Murderer" end
    if (plr.Backpack and plr.Backpack:FindFirstChild("Gun"))
       or plr.Character:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end
local function worldToScreen(pos)
    local sp, onScreen = Cam:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), onScreen, sp.Z
end
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification",
            {Title=title, Text=text, Duration=dur or 3})
    end)
end

--============================================================
-- CONFIG
--============================================================
local Config = {}
function Config.save()
    if not writefile then return end
    local ok, enc = pcall(function() return HttpService:JSONEncode(State) end)
    if ok then pcall(writefile, ConfigPath, enc) end
end
function Config.load()
    if not (isfile and readfile) then return end
    if not isfile(ConfigPath) then return end
    local ok, data = pcall(readfile, ConfigPath)
    if not ok then return end
    local ok2, dec = pcall(function() return HttpService:JSONDecode(data) end)
    if ok2 and type(dec) == "table" then
        for k, v in pairs(dec) do
            if State[k] ~= nil then
                if typeof(State[k]) == "Color3" and type(v) == "table" then
                    State[k] = Color3.new(v.R or v[1], v.G or v[2], v.B or v[3])
                else
                    State[k] = v
                end
            end
        end
    end
end

--============================================================
-- GUI PARENT — Delta-safe
--============================================================
local function parentGui(gui)
    -- try in order of preference
    if gethui then
        local ok = pcall(function() gui.Parent = gethui() end)
        if ok and gui.Parent then return end
    end
    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(gui) end)
    end
    if protect_gui then
        pcall(function() protect_gui(gui) end)
    end
    local ok = pcall(function() gui.Parent = CoreGui end)
    if ok and gui.Parent then return end
    gui.Parent = LP:WaitForChild("PlayerGui")
end

--============================================================
-- UI BASE
--============================================================
local function new(c, p, par)
    local o = Instance.new(c)
    for k, v in pairs(p or {}) do o[k] = v end
    o.Parent = par; return o
end
local function corner(o, r) new("UICorner", {CornerRadius=UDim.new(0,r or 6)}, o) end
local function stroke(o, col, th)
    new("UIStroke", {Color=col or Color3.fromRGB(45,45,55),
        Thickness=th or 1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, o)
end

local ScreenGui = new("ScreenGui", {
    Name = "OcelHub", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
})
parentGui(ScreenGui)

--============ WATERMARK (always visible, mobile-friendly) ============
local Watermark = new("TextButton", {
    Name = "Watermark",
    Size = UDim2.fromOffset(170, 50),            -- big tap target
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundColor3 = Color3.fromRGB(22,22,30),
    BackgroundTransparency = 0.05,
    Text = "◈ Ocel-hub",
    TextColor3 = Color3.fromRGB(235,235,245),
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    AutoButtonColor = false,
    Visible = true,                               -- ALWAYS VISIBLE
    Parent = ScreenGui,
})
corner(Watermark, 12)
stroke(Watermark, Color3.fromRGB(90,90,130), 1.5)

-- glowing accent bar on watermark
local Accent = new("Frame", {
    Size = UDim2.new(0, 4, 0.7, 0),
    Position = UDim2.new(0, 6, 0.15, 0),
    BackgroundColor3 = Color3.fromRGB(110,140,255),
    Parent = Watermark,
})
corner(Accent, 2)

-- pulse animation on watermark (helps visibility)
task.spawn(function()
    while Watermark.Parent do
        TweenService:Create(Accent, TweenInfo.new(1.2, Enum.EasingStyle.Sine),
            {BackgroundColor3 = Color3.fromRGB(160,120,255)}):Play()
        task.wait(1.2)
        TweenService:Create(Accent, TweenInfo.new(1.2, Enum.EasingStyle.Sine),
            {BackgroundColor3 = Color3.fromRGB(110,140,255)}):Play()
        task.wait(1.2)
    end
end)

-- drag watermark with finger/mouse (but not click)
local wmDragging, wmWasDrag = false, false
local wmStart, wmPos
Watermark.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        wmDragging = true; wmWasDrag = false
        wmStart = i.Position; wmPos = Watermark.Position
    end
end)
conn(UserInputService.InputChanged, function(i)
    if wmDragging and (i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = i.Position - wmStart
        if d.Magnitude > 8 then wmWasDrag = true end
        Watermark.Position = UDim2.new(wmPos.X.Scale, wmPos.X.Offset + d.X,
                                       wmPos.Y.Scale, wmPos.Y.Offset + d.Y)
    end
end)
conn(UserInputService.InputEnded, function(i)
    if i.UserInputType == Enum.UserInputType.Touch
    or i.UserInputType == Enum.UserInputType.MouseButton1 then
        wmDragging = false
    end
end)

--============ MAIN WINDOW ============
local Main = new("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(640, 460),
    Position = UDim2.new(0.5, -320, 0.5, -230),
    BackgroundColor3 = Color3.fromRGB(14,14,20),
    BorderSizePixel = 0,
    Visible = false,                              -- start closed, watermark opens it
    Parent = ScreenGui,
})
corner(Main, 12); stroke(Main, Color3.fromRGB(70,70,100), 1.5)

local TopBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(20,20,28),
    BorderSizePixel = 0, Parent = Main,
})
corner(TopBar, 12)

new("TextLabel", {
    Size = UDim2.new(0, 260, 1, 0), Position = UDim2.fromOffset(18, 0),
    BackgroundTransparency = 1, Text = "◈ Ocel-hub",
    TextColor3 = Color3.fromRGB(235,235,245),
    Font = Enum.Font.GothamBold, TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar,
})

local CloseBtn = new("TextButton", {
    Size = UDim2.fromOffset(40, 40), Position = UDim2.new(1, -46, 0, 1),
    BackgroundColor3 = Color3.fromRGB(34,34,44),
    Text = "—", TextColor3 = Color3.fromRGB(220,220,230),
    Font = Enum.Font.GothamBold, TextSize = 22, Parent = TopBar,
})
corner(CloseBtn, 10)

-- Tab list
local TabList = new("ScrollingFrame", {
    Size = UDim2.new(0, 148, 1, -52), Position = UDim2.fromOffset(8, 48),
    BackgroundColor3 = Color3.fromRGB(18,18,26),
    BorderSizePixel = 0, Parent = Main,
    CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(60,60,90),
})
corner(TabList, 10)
new("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder, Parent=TabList})
new("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,6),
    PaddingRight=UDim.new(0,6), PaddingBottom=UDim.new(0,8)}, TabList)

local Content = new("Frame", {
    Size = UDim2.new(1, -166, 1, -52), Position = UDim2.fromOffset(164, 48),
    BackgroundTransparency = 1, Parent = Main,
})

local TabFrames = {}
local function makeTab(name)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(24,24,32), Text = name,
        TextColor3 = Color3.fromRGB(185,185,200),
        Font = Enum.Font.GothamSemibold, TextSize = 14,
        AutoButtonColor = false, Parent = TabList,
    })
    corner(btn, 8)

    local page = new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(70,70,110),
        Visible = false, Parent = Content,
    })
    new("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder, Parent=page})
    new("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8),
        PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}, page)

    TabFrames[name] = {btn=btn, page=page}
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(TabFrames) do
            t.page.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(24,24,32)
            t.btn.TextColor3 = Color3.fromRGB(185,185,200)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(55,55,85)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
    end)
    return page
end

--============ COMPONENTS ============
local function addToggle(page, label, key, cb)
    local row = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(22,22,30), Text = "",
        AutoButtonColor = false, Parent = page,
    })
    corner(row, 8)
    new("TextLabel", {
        Size = UDim2.new(1, -76, 1, 0), Position = UDim2.fromOffset(14, 0),
        BackgroundTransparency = 1, Text = label,
        TextColor3 = Color3.fromRGB(215,215,225),
        Font = Enum.Font.Gotham, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local box = new("Frame", {
        Size = UDim2.fromOffset(44, 24), Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = State[key] and Color3.fromRGB(90,130,230) or Color3.fromRGB(48,48,60),
        Parent = row,
    })
    corner(box, 12)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(20, 20),
        Position = State[key] and UDim2.new(1, -22, 0.5, -10) or UDim2.fromOffset(2, 2),
        BackgroundColor3 = Color3.fromRGB(235,235,245), Parent = box,
    })
    corner(knob, 10)
    row.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        TweenService:Create(box, TweenInfo.new(0.15), {
            BackgroundColor3 = State[key] and Color3.fromRGB(90,130,230) or Color3.fromRGB(48,48,60)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = State[key] and UDim2.new(1,-22,0.5,-10) or UDim2.fromOffset(2,2)}):Play()
        if cb then cb(State[key]) end
        Config.save()
    end)
end

local function addSlider(page, label, key, min, max, cb)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = Color3.fromRGB(22,22,30), Parent = page,
    })
    corner(row, 8)
    local lbl = new("TextLabel", {
        Size = UDim2.new(1, -28, 0, 24), Position = UDim2.fromOffset(14, 4),
        BackgroundTransparency = 1, Text = label .. ": " .. tostring(State[key]),
        TextColor3 = Color3.fromRGB(215,215,225),
        Font = Enum.Font.Gotham, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local barBg = new("Frame", {
        Size = UDim2.new(1, -28, 0, 12), Position = UDim2.new(0, 14, 1, -18),
        BackgroundColor3 = Color3.fromRGB(46,46,60), Parent = row,
    })
    corner(barBg, 6)
    local fill = new("Frame", {
        Size = UDim2.new((State[key]-min)/(max-min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(90,130,230), Parent = barBg,
    })
    corner(fill, 6)
    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = min + rel * (max - min)
        val = (max - min > 20) and math.floor(val) or math.floor(val*100)/100
        State[key] = val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = label .. ": " .. tostring(val)
        if cb then cb(val) end
    end
    barBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; setFromX(i.Position.X)
        end
    end)
    conn(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then setFromX(i.Position.X) end
    end)
    conn(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            if dragging then Config.save() end
            dragging = false
        end
    end)
end

local function addDropdown(page, label, key, options, cb)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(22,22,30), Parent = page,
    })
    corner(row, 8)
    local lbl = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = label .. ": " .. tostring(State[key]),
        TextColor3 = Color3.fromRGB(215,215,225),
        Font = Enum.Font.Gotham, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    new("UIPadding", {PaddingLeft=UDim.new(0,14)}, lbl)
    local open = false
    local list = new("Frame", {
        Size = UDim2.new(1, 0, 0, #options * 32),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Color3.fromRGB(18,18,26),
        Visible = false, ZIndex = 5, Parent = row,
    })
    corner(list, 8)
    new("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Parent=list})
    for _, opt in ipairs(options) do
        local ob = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Color3.fromRGB(18,18,26),
            Text = tostring(opt), TextColor3 = Color3.fromRGB(205,205,220),
            Font = Enum.Font.Gotham, TextSize = 13, ZIndex = 5, Parent = list,
        })
        ob.MouseButton1Click:Connect(function()
            State[key] = opt
            lbl.Text = label .. ": " .. tostring(opt)
            list.Visible = false; open = false
            if cb then cb(opt) end
            Config.save()
        end)
    end
    lbl.MouseButton1Click:Connect(function()
        open = not open; list.Visible = open
    end)
end

local function addKeybind(page, label, key, cb)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(22,22,30), Parent = page,
    })
    corner(row, 8)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = label .. ": " .. tostring(State[key] or "None"),
        TextColor3 = Color3.fromRGB(215,215,225),
        Font = Enum.Font.Gotham, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    new("UIPadding", {PaddingLeft=UDim.new(0,14)}, btn)
    local listening = false
    btn.MouseButton1Click:Connect(function()
        listening = true; btn.Text = label .. ": ..."
    end)
    conn(UserInputService.InputBegan, function(input, gp)
        if listening and not gp then
            State[key] = input.KeyCode.Name
            btn.Text = label .. ": " .. input.KeyCode.Name
            listening = false; Config.save()
        elseif not listening and State[key] and State[key] ~= "None"
               and input.KeyCode.Name == State[key] and not gp then
            if cb then cb() end
        end
    end)
end

local function addColorPicker(page, label, key)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(22,22,30), Parent = page,
    })
    corner(row, 8)
    new("TextLabel", {
        Size = UDim2.new(1, -76, 1, 0), Position = UDim2.fromOffset(14, 0),
        BackgroundTransparency = 1, Text = label,
        TextColor3 = Color3.fromRGB(215,215,225),
        Font = Enum.Font.Gotham, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local sw = new("TextButton", {
        Size = UDim2.fromOffset(44, 24), Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = State[key], Text = "", Parent = row,
    })
    corner(sw, 6)
    local open = false
    local panel = new("Frame", {
        Size = UDim2.fromOffset(220, 120), Position = UDim2.new(1, -230, 1, 6),
        BackgroundColor3 = Color3.fromRGB(18,18,26), Visible = false,
        ZIndex = 6, Parent = row,
    })
    corner(panel, 8)
    local vals = {State[key].R, State[key].G, State[key].B}
    for i = 1, 3 do
        local bar = new("Frame", {
            Size = UDim2.new(1, -24, 0, 14), Position = UDim2.fromOffset(12, 14 + (i-1)*32),
            BackgroundColor3 = Color3.fromRGB(46,46,60), ZIndex = 6, Parent = panel,
        })
        corner(bar, 7)
        local f = new("Frame", {Size = UDim2.new(vals[i],0,1,0),
            BackgroundColor3 = Color3.fromRGB(90,130,230), ZIndex = 6, Parent = bar})
        corner(f, 7)
        local drag = false
        bar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then drag = true end
        end)
        conn(UserInputService.InputChanged, function(inp)
            if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch) then
                local rel = math.clamp((inp.Position.X - bar.AbsolutePosition.X)
                    / bar.AbsoluteSize.X, 0, 1)
                vals[i] = rel
                f.Size = UDim2.new(rel,0,1,0)
                State[key] = Color3.new(vals[1], vals[2], vals[3])
                sw.BackgroundColor3 = State[key]
                Config.save()
            end
        end)
        conn(UserInputService.InputEnded, function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then drag = false end
        end)
    end
    sw.MouseButton1Click:Connect(function() open = not open; panel.Visible = open end)
end

local function addButton(page, label, cb, color)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = color or Color3.fromRGB(46,80,160),
        Text = label, TextColor3 = Color3.fromRGB(240,240,250),
        Font = Enum.Font.GothamBold, TextSize = 13, Parent = page,
    })
    corner(btn, 8)
    btn.MouseButton1Click:Connect(cb)
end

--============ TABS ============
local combat     = makeTab("Combat")
local visuals    = makeTab("Visuals")
local cosmetics  = makeTab("Cosmetics")
local movement   = makeTab("Movement")
local hvh        = makeTab("HvH")
local automation = makeTab("Automation")
local misc       = makeTab("Misc")
local info       = makeTab("Info")
local settings   = makeTab("Settings")

TabFrames["Combat"].btn.BackgroundColor3 = Color3.fromRGB(55,55,85)
TabFrames["Combat"].btn.TextColor3 = Color3.fromRGB(255,255,255)
combat.Visible = true

-- Combat
addToggle(combat, "Silent Aim", "SilentAim")
addDropdown(combat, "Silent Hitbox", "SilentHitbox",
    {"Head","Torso","UpperTorso","LowerTorso","HumanoidRootPart"})
addSlider(combat, "Silent FOV", "SilentFOV", 30, 360)
addToggle(combat, "Aimbot (hold RMB)", "Aimbot")
addSlider(combat, "Aimbot Smooth", "AimbotSmooth", 0.01, 1)
addSlider(combat, "Aimbot FOV", "AimbotFOV", 30, 360)
addToggle(combat, "Aimbot Prediction", "AimbotPrediction")
addToggle(combat, "Hitbox Override", "HitboxOverride")
addToggle(combat, "Triggerbot", "Triggerbot")
addSlider(combat, "Trigger Delay", "TriggerDelay", 0, 0.5)
addToggle(combat, "Auto Shoot (Sheriff)", "AutoShoot")
addToggle(combat, "Auto Reload", "AutoReload")
addToggle(combat, "Auto Knife Throw", "AutoKnifeThrow")
addToggle(combat, "Fast Throw", "FastThrow")
addToggle(combat, "Reach", "Reach")
addSlider(combat, "Reach Distance", "ReachDist", 10, 60)
addToggle(combat, "Knife Aura", "KnifeAura")
addSlider(combat, "Knife Range", "KnifeRange", 3, 20)
addToggle(combat, "Kill All (murderer spam)", "KillAll")
addToggle(combat, "Break Gun", "BreakGun")
addToggle(combat, "Anti-Backstab", "AntiBackstab")
addToggle(combat, "Backtrack", "Backtrack")
addToggle(combat, "Auto Dodge Knife", "AutoDodge")
addSlider(combat, "Dodge Range", "DodgeRange", 5, 40)

-- Visuals
addToggle(visuals, "ESP", "ESP")
addToggle(visuals, "Names", "ESPNames")
addToggle(visuals, "Distance", "ESPDistance")
addToggle(visuals, "Gun ESP on Players", "ESPGun")
addToggle(visuals, "Box ESP", "ESPBox")
addToggle(visuals, "Head Dot", "ESPHeadDot")
addToggle(visuals, "Skeleton ESP", "ESPSkeleton")
addToggle(visuals, "Rainbow ESP", "ESPRainbow")
addToggle(visuals, "Tracers", "ESPTracers")
addToggle(visuals, "Chams", "Chams")
addToggle(visuals, "X-Ray", "XRay")
addToggle(visuals, "Freecam", "Freecam")
addSlider(visuals, "Freecam Speed", "FreecamSpeed", 0.5, 8)
addToggle(visuals, "Fullbright", "Fullbright")
addToggle(visuals, "Dropped Gun ESP", "GunESP")
addToggle(visuals, "Kill Notify", "KillNotify")
addToggle(visuals, "Murderer Alert", "MurdererAlert")
addSlider(visuals, "Alert Distance", "MurdererDist", 20, 200)
addToggle(visuals, "Custom Crosshair", "CustomCrosshair")
addColorPicker(visuals, "Crosshair Color", "CrosshairColor")
addToggle(visuals, "Time Changer", "TimeChanger")
addSlider(visuals, "Time (hours)", "TimeValue", 0, 24)
addToggle(visuals, "Remove Fog", "RemoveFog")
addToggle(visuals, "Skybox Changer", "SkyboxChanger")
addColorPicker(visuals, "Murderer Color", "ColorMurderer")
addColorPicker(visuals, "Sheriff Color", "ColorSheriff")
addColorPicker(visuals, "Innocent Color", "ColorInnocent")
addColorPicker(visuals, "Gun Color", "ColorGun")

-- Cosmetics
addToggle(cosmetics, "Skin Changer", "SkinChanger")
addToggle(cosmetics, "Weapon Skin", "WeaponSkin")
addToggle(cosmetics, "Effect Changer", "EffectChanger")
addToggle(cosmetics, "Emote Changer", "EmoteChanger")
addToggle(cosmetics, "Radio Changer", "RadioChanger")
addSlider(cosmetics, "Viewmodel FOV", "ViewmodelFOV", 40, 120, function(v)
    pcall(function() Cam.FieldOfView = v end)
end)

-- Movement
addSlider(movement, "WalkSpeed", "WalkSpeed", 8, 200, function(v)
    if isAlive() then LP.Character.Humanoid.WalkSpeed = v end
end)
addSlider(movement, "JumpPower", "JumpPower", 30, 200, function(v)
    if isAlive() then LP.Character.Humanoid.JumpPower = v end
end)
addToggle(movement, "Auto Jump", "AutoJump")
addToggle(movement, "Infinite Jump", "InfiniteJump")
addToggle(movement, "Bhop", "Bhop")
addToggle(movement, "Fly", "Fly")
addSlider(movement, "Fly Speed", "FlySpeed", 20, 300)
addToggle(movement, "Noclip", "Noclip")
addToggle(movement, "Anti-Void", "AntiVoid")
addToggle(movement, "Platform Stand", "PlatformStand")
addToggle(movement, "Mouse TP (click)", "MouseTP")
addKeybind(movement, "TP Random Player", "TpRand", function()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and isAlive(p) then table.insert(t, p) end
    end
    if #t > 0 and isAlive() then
        local p = t[math.random(1, #t)]
        LP.Character.HumanoidRootPart.CFrame =
            p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end)
addKeybind(movement, "TP Spawn", "TpSpawn", function()
    if isAlive() then
        local s = Workspace:FindFirstChildOfClass("SpawnLocation")
        if s then LP.Character.HumanoidRootPart.CFrame = s.CFrame + Vector3.new(0,4,0) end
    end
end)

-- HvH
addToggle(hvh, "Spinbot", "Spinbot")
addSlider(hvh, "Spin Speed", "SpinSpeed", 5, 60)
addToggle(hvh, "Jitter", "Jitter")
addToggle(hvh, "Desync / Fake Angles", "Desync")
addToggle(hvh, "Fake Lag", "FakeLag")
addSlider(hvh, "Fake Lag Amount", "FakeLagAmount", 0.05, 0.5)
addToggle(hvh, "Anti-Fling", "AntiFling")

-- Automation
addToggle(automation, "Auto Farm Coins", "AutoFarm")
addToggle(automation, "Auto Grab Gun", "AutoGrabGun")
addToggle(automation, "Auto Pickup Knife", "AutoPickupKnife")
addToggle(automation, "Notify Role", "AutoRole")
addToggle(automation, "Anti-AFK", "AntiAFK")
addToggle(automation, "Auto Win (tasks)", "AutoWin")
addToggle(automation, "Auto Queue", "AutoQueue")
addToggle(automation, "Rejoin on Death", "RejoinOnDeath")
addToggle(automation, "Chat Spam", "ChatSpam")

-- Misc
addToggle(misc, "Ping Spoof", "PingSpoof")
addToggle(misc, "Fling", "Fling")
addToggle(misc, "Anti-Kill (auto flee)", "AntiKill")
addSlider(misc, "Flee Range", "AntiKillDist", 10, 100)
addToggle(misc, "Sound Spam", "SoundSpam")
addToggle(misc, "Anti-Lag (clean parts)", "AntiLag")
addToggle(misc, "Player Info Panel", "PlayerInfo")
addDropdown(misc, "Spectate", "Spectate", {"None", "__refresh__"}, function(opt)
    -- repopulated below on open
end)
addButton(misc, "TP All To Me", function()
    if not isAlive() then return end
    local hrp = LP.Character.HumanoidRootPart
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and isAlive(p) then
            pcall(function()
                p.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
            end)
        end
    end
end)
addButton(misc, "Refresh Spectate List", function()
    local names = {"None"}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(names, p.Name) end
    end
    State.Spectate = "None"
    notify("Ocel-hub", "Spectate list refreshed ("..#names-1.." players)")
end)
addKeybind(misc, "Server Hop", "ServerHop", function()
    local req = (syn and syn.request) or (http and http.request) or http_request
    if not req then return end
    local ok, res = pcall(function()
        return req({Url="https://games.roblox.com/v1/games/"..game.PlaceId
            .."/servers/Public?sortOrder=Asc&limit=100", Method="GET"})
    end)
    if ok and res and res.Body then
        local data = HttpService:JSONDecode(res.Body)
        if data.data then
            for _, s in ipairs(data.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                    return
                end
            end
        end
    end
end)

-- Info tab
local InfoLabel = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
    Text = "", TextColor3 = Color3.fromRGB(220,220,230),
    Font = Enum.Font.Code, TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Parent = info,
})

-- Settings
addKeybind(settings, "Toggle UI", "ToggleUI", function()
    Main.Visible = not Main.Visible
end)
addKeybind(settings, "Panic", "Panic", function()
    for k, v in pairs(State) do
        if type(v) == "boolean" then State[k] = false end
    end
    notify("Ocel-hub", "Panic — all off")
end)
addButton(settings, "Save Config", function() Config.save() end,
    Color3.fromRGB(45,90,190))
addButton(settings, "Load Config", function()
    Config.load()
    notify("Ocel-hub", "Config loaded")
end, Color3.fromRGB(65,130,65))
addButton(settings, "Reset UI Position", function()
    Main.Position = UDim2.new(0.5, -320, 0.5, -230)
    Watermark.Position = UDim2.new(0, 12, 0, 12)
end, Color3.fromRGB(130,80,60))

--============ WATERMARK ↔ MENU WIRING ============
local function toggleMenu()
    Main.Visible = not Main.Visible
end

-- Tap on watermark toggles menu (only if it wasn't a drag)
Watermark.MouseButton1Click:Connect(function()
    if wmWasDrag then wmWasDrag = false; return end
    toggleMenu()
end)

-- Close btn hides menu (watermark stays visible)
CloseBtn.MouseButton1Click:Connect(toggleMenu)

-- drag main window
do
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = Main.Position
        end
    end)
    conn(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                     startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    conn(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

--============================================================
-- CUSTOM CROSSHAIR
--============================================================
local crosshairDots = {}
local function updateCrosshair()
    if not State.CustomCrosshair then
        for _, d in ipairs(crosshairDots) do pcall(function() d:Remove() end) end
        crosshairDots = {}
        return
    end
    if #crosshairDots == 0 then
        for i = 1, 4 do
            local l = Drawing.new("Line")
            l.Thickness = 2
            table.insert(crosshairDots, l)
        end
    end
    local cx = Cam.ViewportSize.X / 2
    local cy = Cam.ViewportSize.Y / 2
    local len = 8
    crosshairDots[1].From = Vector2.new(cx - len, cy); crosshairDots[1].To = Vector2.new(cx - 2, cy)
    crosshairDots[2].From = Vector2.new(cx + 2, cy); crosshairDots[2].To = Vector2.new(cx + len, cy)
    crosshairDots[3].From = Vector2.new(cx, cy - len); crosshairDots[3].To = Vector2.new(cx, cy - 2)
    crosshairDots[4].From = Vector2.new(cx, cy + 2); crosshairDots[4].To = Vector2.new(cx, cy + len)
    for _, l in ipairs(crosshairDots) do
        l.Color = State.CrosshairColor
        l.Visible = true
    end
end

--============================================================
-- ESP
--============================================================
local function getEspFor(plr)
    if not ESPSprites[plr] then
        ESPSprites[plr] = {
            name=Drawing.new("Text"), dist=Drawing.new("Text"),
            box=Drawing.new("Square"), tracer=Drawing.new("Line"),
            headDot=Drawing.new("Circle"), skeleton={},
        }
        local e = ESPSprites[plr]
        e.name.Center=true; e.name.Outline=true; e.name.Font=2; e.name.Size=14
        e.dist.Center=true; e.dist.Outline=true; e.dist.Font=2; e.dist.Size=12
        e.box.Thickness=1; e.box.Filled=false
        e.tracer.Thickness=1
        e.headDot.Radius=4; e.headDot.Filled=true; e.headDot.Thickness=1
        for i = 1, 15 do
            local l = Drawing.new("Line"); l.Thickness=1; l.Visible=false
            table.insert(e.skeleton, l)
        end
    end
    return ESPSprites[plr]
end
local function hideEsp(plr)
    local e = ESPSprites[plr]; if not e then return end
    for k, v in pairs(e) do
        if k == "skeleton" then
            for _, l in ipairs(v) do pcall(function() l.Visible = false end) end
        else pcall(function() v.Visible = false end) end
    end
end
local function destroyEsp(plr)
    local e = ESPSprites[plr]; if not e then return end
    for k, v in pairs(e) do
        if k == "skeleton" then
            for _, l in ipairs(v) do pcall(function() l:Remove() end) end
        else pcall(function() v:Remove() end) end
    end
    ESPSprites[plr] = nil
end

local function setChams(plr)
    if not plr.Character then return end
    for _, part in ipairs(plr.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if not ChamsCache[part] then ChamsCache[part] = part.Material end
            part.Material = Enum.Material.ForceField
            part.LocalTransparencyModifier = 0.5
        end
    end
end
local function clearChams()
    for part, mat in pairs(ChamsCache) do
        pcall(function() part.Material = mat; part.LocalTransparencyModifier = 0 end)
    end
    ChamsCache = {}
end

-- silent aim hook
local function getClosestToCursor(fov)
    local mouse = UserInputService:GetMouseLocation()
    local best, bestDist = nil, fov
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and isAlive(p) then
            local part = p.Character:FindFirstChild(State.SilentHitbox)
            if part then
                local sp, onScreen = worldToScreen(part.Position)
                if onScreen then
                    local d = (sp - mouse).Magnitude
                    if d < bestDist then best, bestDist = part, d end
                end
            end
        end
    end
    return best
end

do
    local ok = pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and State.SilentAim
               and (method == "Raycast" or method == "FindPartOnRay"
               or method == "FindPartOnRayWithIgnoreList"
               or method == "FindPartOnRayWithWhitelist") then
                local target = getClosestToCursor(State.SilentFOV)
                if target then
                    local args = {...}
                    if method == "Raycast" then
                        local origin = args[1]
                        if typeof(origin) == "Vector3" then
                            args[2] = (target.Position - origin)
                        elseif typeof(origin) == "Ray" then
                            args[1] = Ray.new(origin.Origin, target.Position - origin.Origin)
                        elseif typeof(origin) == "CFrame" then
                            args[1] = CFrame.new(origin.Position, target.Position)
                        end
                    elseif method:find("FindPartOnRay") then
                        local ray = args[1]
                        if typeof(ray) == "Ray" then
                            args[1] = Ray.new(ray.Origin, target.Position - ray.Origin)
                        end
                    end
                    return oldNamecall(self, table.unpack(args))
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
    if not ok then
        -- Delta doesn't have hookmetamethod, use namecall fallback
        pcall(function()
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if not checkcaller() and State.SilentAim
                   and (method == "Raycast" or method:find("FindPartOnRay")) then
                    local target = getClosestToCursor(State.SilentFOV)
                    if target then
                        local args = {...}
                        if typeof(args[1]) == "Ray" then
                            args[1] = Ray.new(args[1].Origin, target.Position - args[1].Origin)
                        end
                        return old(self, table.unpack(args))
                    end
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end)
    end
end

--============================================================
-- RENDER LOOPS
--============================================================
conn(RunService.RenderStepped, function()
    -- ESP
    local hue = tick() % 5 / 5
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local e = getEspFor(plr)
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if not State.ESP or not hrp or not hum or hum.Health <= 0 then
                hideEsp(plr)
            else
                local role = getRole(plr)
                local color = role == "Murderer" and State.ColorMurderer
                           or role == "Sheriff" and State.ColorSheriff
                           or State.ColorInnocent
                if State.ESPRainbow then color = Color3.fromHSV(hue, 1, 1) end

                local pos, onScreen, depth = worldToScreen(hrp.Position)
                local headPos = worldToScreen(head and head.Position or hrp.Position)

                if onScreen and depth > 0 then
                    if State.ESPBox then
                        local h = math.abs(pos.Y - headPos.Y) * 2
                        local w = h * 0.5
                        e.box.Size = Vector2.new(w, h)
                        e.box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                        e.box.Color = color
                        e.box.Visible = true
                    else e.box.Visible = false end

                    if State.ESPNames then
                        e.name.Text = plr.Name .. " [" .. role .. "]"
                        e.name.Position = Vector2.new(pos.X, pos.Y - 40)
                        e.name.Color = color
                        e.name.Visible = true
                    else e.name.Visible = false end

                    if State.ESPDistance then
                        local dist = (Cam.CFrame.Position - hrp.Position).Magnitude
                        e.dist.Text = string.format("[%d]", math.floor(dist))
                        e.dist.Position = Vector2.new(pos.X, pos.Y - 26)
                        e.dist.Color = color
                        e.dist.Visible = true
                    else e.dist.Visible = false end

                    if State.ESPTracers then
                        e.tracer.From = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y)
                        e.tracer.To = Vector2.new(pos.X, pos.Y + 20)
                        e.tracer.Color = color
                        e.tracer.Visible = true
                    else e.tracer.Visible = false end

                    if State.ESPHeadDot and head then
                        local hp = worldToScreen(head.Position)
                        e.headDot.Position = hp
                        e.headDot.Color = color
                        e.headDot.Visible = true
                    else e.headDot.Visible = false end

                    if State.ESPSkeleton then
                        local bones = {
                            {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
                            {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},
                            {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},
                            {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
                            {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},
                        }
                        for i, pair in ipairs(bones) do
                            local l = e.skeleton[i]; if not l then break end
                            local a = char:FindFirstChild(pair[1])
                            local b = char:FindFirstChild(pair[2])
                            if a and b then
                                l.From = worldToScreen(a.Position)
                                l.To = worldToScreen(b.Position)
                                l.Color = color; l.Visible = true
                            else l.Visible = false end
                        end
                        for i = #bones+1, #e.skeleton do e.skeleton[i].Visible = false end
                    else
                        for _, l in ipairs(e.skeleton) do l.Visible = false end
                    end
                else hideEsp(plr) end

                if State.Chams then setChams(plr) end
            end
        end
    end

    -- Crosshair
    updateCrosshair()

    -- Aimbot
    if State.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local mouse = UserInputService:GetMouseLocation()
        local best, bestDist = nil, State.AimbotFOV
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and isAlive(p) then
                local part = p.Character:FindFirstChild("Head")
                if part then
                    local sp, onScreen = worldToScreen(part.Position)
                    if onScreen then
                        local d = (sp - mouse).Magnitude
                        if d < bestDist then best, bestDist = part, d end
                    end
                end
            end
        end
        if best then
            local target = best.Position
            if State.AimbotPrediction then
                target = target + (best.AssemblyLinearVelocity or Vector3.zero) * 0.15
            end
            Cam.CFrame = Cam.CFrame:Lerp(
                CFrame.new(Cam.CFrame.Position, target), State.AimbotSmooth)
        end
    end

    -- Freecam
    if State.Freecam then
        Cam.CFrame = Cam.CFrame -- placeholder; see Heartbeat
    end

    -- Spinbot / desync
    if isAlive() and not State.Freecam then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if State.Spinbot then
                local sp = tick() * State.SpinSpeed * 60
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(sp % 360), 0)
            elseif State.Jitter then
                if math.random() > 0.5 then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(180), 0)
                end
            elseif State.Desync then
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(90), 0)
            end
        end
    end
end)

-- gun esp
local gunEspDraw
conn(RunService.RenderStepped, function()
    if not State.GunESP then
        if gunEspDraw then
            for _, d in pairs(gunEspDraw) do pcall(function() d:Remove() end) end
            gunEspDraw = nil
        end
        return
    end
    gunEspDraw = gunEspDraw or {name=Drawing.new("Text"), box=Drawing.new("Square")}
    gunEspDraw.name.Center=true; gunEspDraw.name.Outline=true; gunEspDraw.name.Size=14
    gunEspDraw.box.Filled=false; gunEspDraw.box.Thickness=1
    local gun = Workspace:FindFirstChild("Gun") or Workspace:FindFirstChild("GunDrop")
    if gun and gun:IsA("BasePart") then
        local pos, onScreen, depth = worldToScreen(gun.Position)
        if onScreen and depth > 0 then
            gunEspDraw.name.Text = "Gun"
            gunEspDraw.name.Position = Vector2.new(pos.X, pos.Y - 20)
            gunEspDraw.name.Color = State.ColorGun
            gunEspDraw.name.Visible = true
            gunEspDraw.box.Size = Vector2.new(40, 40)
            gunEspDraw.box.Position = Vector2.new(pos.X - 20, pos.Y - 20)
            gunEspDraw.box.Color = State.ColorGun
            gunEspDraw.box.Visible = true
        else
            gunEspDraw.name.Visible = false; gunEspDraw.box.Visible = false
        end
    else
        gunEspDraw.name.Visible = false; gunEspDraw.box.Visible = false
    end
end)

--============================================================
-- HEARTBEAT — movement, aura, automation
--============================================================
local lastTrigger = 0
local auraCooldown = 0
local farmCooldown = 0
local notifiedRole = false
local alertCooldown = 0

conn(RunService.Heartbeat, function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    local alive = hum.Health > 0

    -- Movement / noclip / fly
    if alive then
        if State.AutoJump then hum.Jump = true end
        if State.InfiniteJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        if State.Bhop and hum.FloorMaterial ~= Enum.Material.Air then hum.Jump = true end
        if State.PlatformStand then hum.PlatformStand = true
        else hum.PlatformStand = false end

        if State.Noclip then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end

        if State.Fly then
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
            hrp.Velocity = move.Magnitude > 0 and (move.Unit * State.FlySpeed) or Vector3.zero
        end

        if State.AutoDodge then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and isAlive(p) and getRole(p) == "Murderer" then
                    local thrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if thrp and (thrp.Position - hrp.Position).Magnitude < State.DodgeRange then
                        local dir = (hrp.Position - thrp.Position).Unit
                        hrp.CFrame = CFrame.new(hrp.Position + dir * 4)
                    end
                end
            end
        end

        if State.AntiVoid and hrp.Position.Y < -50 then
            local s = Workspace:FindFirstChildOfClass("SpawnLocation")
            if s then hrp.CFrame = s.CFrame + Vector3.new(0,4,0) end
        end

        if State.AntiKill then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and isAlive(p) and getRole(p) == "Murderer" then
                    local thrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if thrp and (thrp.Position - hrp.Position).Magnitude < State.AntiKillDist then
                        local dir = (hrp.Position - thrp.Position).Unit
                        hrp.CFrame = CFrame.new(hrp.Position + dir * 8)
                    end
                end
            end
        end

        if State.AntiFling and hrp.AssemblyAngularVelocity.Magnitude > 50 then
            hrp.AssemblyAngularVelocity = Vector3.zero
        end

        if State.FakeLag then
            hrp.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
        end

        if State.PingSpoof then
            hrp.CustomPhysicalProperties = PhysicalProperties.new(0.1,0.1,0.1,0.1,0.1)
        end

        if State.MouseTP and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local m = UserInputService:GetMouseLocation()
            local ray = Cam:ViewportPointToRay(m.X, m.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {LP.Character}
            local res = Workspace:Raycast(ray.Origin, ray.Direction * 500, params)
            if res then hrp.CFrame = CFrame.new(res.Position + Vector3.new(0,3,0)) end
        end
    end

    -- Triggerbot
    if State.Triggerbot and alive and tick() - lastTrigger >= State.TriggerDelay then
        local m = UserInputService:GetMouseLocation()
        local ray = Cam:ViewportPointToRay(m.X, m.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LP.Character}
        local res = Workspace:Raycast(ray.Origin, ray.Direction * 500, params)
        if res and res.Instance then
            local model = res.Instance:FindFirstAncestorOfClass("Model")
            if model and Players:GetPlayerFromCharacter(model) then
                lastTrigger = tick()
                pcall(function()
                    VirtualUser:Button1Down(Vector2.new(0,0))
                    task.wait(0.02)
                    VirtualUser:Button1Up(Vector2.new(0,0))
                end)
            end
        end
    end

    -- Auto shoot (sheriff)
    if State.AutoShoot and alive then
        local gun = char:FindFirstChild("Gun")
        if gun then
            local closest, dist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and isAlive(p) and getRole(p) == "Murderer" then
                    local thrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if thrp then
                        local d = (thrp.Position - hrp.Position).Magnitude
                        if d < dist then closest, dist = thrp, d end
                    end
                end
            end
            if closest and dist < 200 then pcall(function() gun:Activate() end) end
        end
    end

    -- Auto reload
    if State.AutoReload and alive then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name == "Gun" then
                pcall(function() t:Activate() end)
            end
        end
    end

    -- Auto knife throw / fast throw
    if (State.AutoKnifeThrow or State.FastThrow) and alive then
        local knife = char:FindFirstChild("Knife")
        if knife then
            local closest, dist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and isAlive(p) then
                    local thrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if thrp then
                        local d = (thrp.Position - hrp.Position).Magnitude
                        if d < dist then closest, dist = thrp, d end
                    end
                end
            end
            if closest and dist < (State.FastThrow and 500 or 40) then
                pcall(function() knife:Activate() end)
            end
        end
    end

    -- Knife Aura
    if State.KnifeAura and alive and tick() - auraCooldown >= 0.1 then
        local knife = char:FindFirstChild("Knife")
            or (LP.Backpack and LP.Backpack:FindFirstChild("Knife"))
        if knife then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and isAlive(p) then
                    local thrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if thrp and (hrp.Position - thrp.Position).Magnitude <= State.KnifeRange then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            auraCooldown = tick()
                            pcall(function() tool:Activate() end)
                        end
                        break
                    end
                end
            end
        end
    end

    -- Kill All (murderer spams knife activates)
    if State.KillAll and alive then
        local knife = char:FindFirstChild("Knife")
        if knife then
            pcall(function() knife:Activate() end)
        end
    end

    -- Anti backstab
    if State.AntiBackstab and alive then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and isAlive(p) then
                local thrp = p.Character:FindFirstChild("HumanoidRootPart")
                if thrp and (hrp.Position - thrp.Position).Magnitude < 4 then
                    local dir = (hrp.Position - thrp.Position).Unit
                    hrp.CFrame = CFrame.new(hrp.Position + dir * 0.5)
                end
            end
        end
    end

    -- Break gun
    if State.BreakGun and alive then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name == "Gun" then
                pcall(function() t:Activate() end)
            end
        end
    end

    -- Auto Farm
    if State.AutoFarm and alive and tick() - farmCooldown >= 0.3 then
        local folder = Workspace:FindFirstChild("CoinContainer") or Workspace
        for _, c in ipairs(folder:GetChildren()) do
            if c.Name == "Coin" and c:IsA("BasePart") then
                farmCooldown = tick()
                hrp.CFrame = c.CFrame + Vector3.new(0, 2, 0)
                break
            end
        end
    end

    -- Auto Grab Gun
    if State.AutoGrabGun and alive and not char:FindFirstChild("Gun") then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.Name == "Gun" and obj:IsA("BasePart") then
                hrp.CFrame = obj.CFrame
                break
            end
        end
    end

    -- Auto Pickup Knife
    if State.AutoPickupKnife and alive and not char:FindFirstChild("Knife") then
        local parent = Workspace
        for _, obj in ipairs(parent:GetChildren()) do
            if obj.Name == "Knife" and obj:IsA("BasePart") then
                hrp.CFrame = obj.CFrame
                break
            end
        end
    end

    -- Auto Win (fire prompts)
    if State.AutoWin and alive then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled and obj.Parent then
                local pp = obj.Parent
                if pp and pp:IsA("BasePart")
                   and (pp.Position - hrp.Position).Magnitude < 10 then
                    pcall(function() fireproximityprompt(pp) end)
                end
            end
        end
    end

    -- Anti Kill notify / murderer alert
    if State.MurdererAlert and alive and tick() - alertCooldown > 5 then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and isAlive(p) and getRole(p) == "Murderer" then
                local thrp = p.Character:FindFirstChild("HumanoidRootPart")
                if thrp and (thrp.Position - hrp.Position).Magnitude <= State.MurdererDist then
                    alertCooldown = tick()
                    notify("⚠ Murderer Near",
                        "Distance: " .. math.floor((thrp.Position - hrp.Position).Magnitude).."m", 3)
                    break
                end
            end
        end
    end

    -- Auto role notify
    if State.AutoRole and alive and not notifiedRole then
        notifiedRole = true
        notify("Ocel-hub", "Your role: " .. getRole(LP), 4)
    end

    -- Spectate
    if State.Spectate and State.Spectate ~= "None" then
        local target = Players:FindFirstChild(State.Spectate)
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, target.Character.Head.Position)
        end
    end

    -- Fullbright
    if State.Fullbright then
        Lighting.Ambient = Color3.fromRGB(180,180,180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
        Lighting.Brightness = 3
    end

    -- Time changer
    if State.TimeChanger then
        Lighting.ClockTime = State.TimeValue
    end

    -- Remove fog
    if State.RemoveFog then
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 1e6
    end

    -- X-Ray
    if State.XRay then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = 0.6
                        part.Material = Enum.Material.ForceField
                    end
                end
            end
        end
    end

    -- Anti Lag: clean non-essential parts
    if State.AntiLag then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
               or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                pcall(function() obj.Enabled = false end)
            end
        end
    end

    -- Fling
    if State.Fling and alive then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and isAlive(p) then
                local thrp = p.Character:FindFirstChild("HumanoidRootPart")
                if thrp and (hrp.Position - thrp.Position).Magnitude < 5 then
                    hrp.AssemblyAngularVelocity = Vector3.new(
                        math.random(-999,999), math.random(-999,999), math.random(-999,999))
                    hrp.CFrame = thrp.CFrame
                end
            end
        end
    end

    -- Anti-AFK
    if State.AntiAFK then
        -- handled by Idled
    end
end)

-- Freecam (RenderStepped for smoothness)
local freecamCF = nil
conn(RunService.RenderStepped, function(dt)
    if State.Freecam then
        freecamCF = freecamCF or Cam.CFrame
        local speed = State.FreecamSpeed * 20 * dt
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += freecamCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= freecamCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= freecamCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += freecamCF.RightVector end
        if move.Magnitude > 0 then freecamCF = freecamCF + move.Unit * speed end
        Cam.CFrame = freecamCF
    else
        freecamCF = nil
    end
end)

-- Chat spam loop
task.spawn(function()
    while true do
        task.wait(math.max(1, State.ChatSpamDelay or 2))
        if State.ChatSpam then
            pcall(function()
                local ev = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if ev and ev:FindFirstChild("SayMessageRequest") then
                    ev.SayMessageRequest:FireServer(State.ChatSpamText, "All")
                end
            end)
        end
    end
end)

-- Sound spam loop
local originalSounds = {}
task.spawn(function()
    while true do
        task.wait(0.1)
        if State.SoundSpam then
            for _, s in ipairs(SoundService:GetDescendants()) do
                if s:IsA("Sound") and s.IsPlaying then
                    pcall(function()
                        s.TimePosition = math.random(0, math.max(0, s.TimeLength - 0.1))
                    end)
                end
            end
        end
    end
end)

-- Info panel loop
local function updateInfo()
    if not State.PlayerInfo then
        InfoLabel.Text = ""
        return
    end
    local lines = {"=== Ocel-hub | " .. #Players:GetPlayers() .. " players ==="}
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = LP.Character.HumanoidRootPart
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and isAlive(p) then
                local role = getRole(p)
                local dist = math.floor((p.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude)
                table.insert(lines, string.format("%-16s | %-8s | %4dm", p.Name, role, dist))
            end
        end
    end
    InfoLabel.Text = table.concat(lines, "\n")
    InfoLabel.Size = UDim2.new(1, 0, 0, math.max(24, #lines * 20))
end
conn(RunService.Heartbeat, updateInfo)

--============================================================
-- PLAYER LIFECYCLE
--============================================================
conn(Players.PlayerRemoving, function(p)
    destroyEsp(p)
end)
conn(Players.PlayerAdded, function(p)
    p.CharacterRemoving:Connect(function() hideEsp(p) end)
end)
conn(LP.CharacterAdded, function()
    if not State.Chams then clearChams() end
    notifiedRole = false
    task.wait(0.5)
    if isAlive() then
        LP.Character.Humanoid.WalkSpeed = State.WalkSpeed
        LP.Character.Humanoid.JumpPower = State.JumpPower
    end
    -- Rejoin on death
    if State.RejoinOnDeath then
        task.wait(3)
        local req = (syn and syn.request) or (http and http.request) or http_request
        if req then
            pcall(function()
                req({Url="roblox://experiences/start?placeId="..game.PlaceId,
                    Method="GET"})
            end)
        end
    end
end)

-- Anti-AFK
conn(LP.Idled, function()
    if not State.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- Auto Queue
task.spawn(function()
    while true do
        task.wait(2)
        if State.AutoQueue then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("TextButton") and (obj.Text:lower():find("play")
                   or obj.Text:lower():find("ready")) then
                    pcall(function()
                        obj.MouseButton1Click:Fire()
                        obj.MouseButton1Down:Fire()
                    end)
                end
                if obj:IsA("ProximityPrompt") and obj.ActionText
                   and obj.ActionText:lower():find("queue") then
                    pcall(function() fireproximityprompt(obj) end)
                end
            end
        end
    end
end)

--============================================================
-- AUTOSAVE + BOOT
--============================================================
local lastSave = 0
conn(RunService.Heartbeat, function()
    if tick() - lastSave > 30 then
        lastSave = tick(); Config.save()
    end
end)

Config.load()
notify("Ocel-hub", "Loaded. Tap the watermark button to open menu.", 5)
LP.OnTeleport:Connect(cleanup)
