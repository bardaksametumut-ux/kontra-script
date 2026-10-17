-- ╔══════════════════════════════════════════════════════════════╗
-- ║          KONTRA ULTRA v3.0  |  by KontraScript             ║
-- ║   Aimbot · ESP · Skin · Lighting · Rainbow · Chams         ║
-- ║   Executor: Synapse X / KRNL / Fluxus / Delta / Wave       ║
-- ║   Tuş: RightShift = Menü  |  Q = Aimbot                   ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Camera       = workspace.CurrentCamera
local LP           = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════════════
local Cfg = {
    Aimbot = {
        Enabled       = true,
        Key           = Enum.KeyCode.Q,
        FOV           = 160,
        Smoothness    = 0.13,
        Part          = "Head",
        TeamCheck     = true,
        WallCheck     = false,
        ShowFOV       = true,
        FOVColor      = Color3.fromRGB(180, 80, 255),
        PredictFactor = 0.08,
    },
    ESP = {
        Enabled    = true,
        Box        = true,
        CornerBox  = false,
        Name       = true,
        Distance   = true,
        HealthBar  = true,
        Skeleton   = true,
        Tracer     = false,
        TeamCheck  = true,
        MaxDist    = 2000,
        BoxColor   = Color3.fromRGB(180, 80, 255),
        TeamColor  = Color3.fromRGB(80, 255, 160),
        SkelColor  = Color3.fromRGB(255, 200, 80),
    },
    NoRecoil = { Enabled = true, Strength = 0.6 },
    Crosshair = {
        Enabled   = true,
        Size      = 10,
        Gap       = 4,
        Thickness = 1.5,
        Color     = Color3.fromRGB(200, 100, 255),
        Dot       = true,
    },
    Radar = {
        Enabled = true,
        Size    = 160,
        Range   = 300,
        Scale   = 0.7,
    },
    SkinChanger = {
        Enabled = true,
        Preset  = "TacticalBlack",
    },
    Lighting = {
        Mode         = "Normal", -- "Normal" | "Night" | "Day" | "Sunset" | "Fog" | "Neon"
        Brightness   = 1,
        FogEnabled   = false,
        FogColor     = Color3.fromRGB(180, 180, 255),
        FogEnd       = 300,
        Ambient      = Color3.fromRGB(70, 70, 70),
    },
    Rainbow = {
        WeaponEnabled   = false,  -- silah parçaları rainbow
        CharEnabled     = false,  -- karakter rainbow
        Speed           = 2,      -- hız (saniye başı tur)
        Saturation      = 1,
        Brightness      = 1,
    },
    Chams = {
        Enabled     = false,  -- duvardan görünen renkli model
        Color       = Color3.fromRGB(255, 80, 80),
        TeamColor   = Color3.fromRGB(80, 255, 160),
        Transparency= 0.5,
    },
    Environment = {
        SkyEnabled    = false,
        TimeOfDay     = "14:00:00",
    },
}

-- ════════════════════════════════════════════════════════════════
-- SKIN PRESETS
-- ════════════════════════════════════════════════════════════════
local SkinPresets = {
    TacticalBlack = {Head="Pastel brown",Torso="Really black",LeftArm="Really black",RightArm="Really black",LeftLeg="Really black",RightLeg="Really black"},
    Ghost         = {Head="White",Torso="White",LeftArm="White",RightArm="White",LeftLeg="White",RightLeg="White"},
    Desert        = {Head="Pastel brown",Torso="Sand yellow",LeftArm="Sand yellow",RightArm="Sand yellow",LeftLeg="Sand yellow",RightLeg="Sand yellow"},
    Purple        = {Head="Pastel brown",Torso="Dark indigo",LeftArm="Dark indigo",RightArm="Dark indigo",LeftLeg="Dark indigo",RightLeg="Dark indigo"},
    Stealth       = {Head="Really black",Torso="Really black",LeftArm="Really black",RightArm="Really black",LeftLeg="Really black",RightLeg="Really black"},
    Classic       = {Head="Pastel brown",Torso="Bright blue",LeftArm="Bright yellow",RightArm="Bright yellow",LeftLeg="Bright blue",RightLeg="Bright blue"},
}

-- ════════════════════════════════════════════════════════════════
-- LIGHTING PRESETS
-- ════════════════════════════════════════════════════════════════
local LightingPresets = {
    Normal = {
        Brightness = 1, Ambient = Color3.fromRGB(70,70,70),
        OutdoorAmbient = Color3.fromRGB(140,140,140),
        FogEnd = 100000, FogColor = Color3.fromRGB(191,191,191),
        ClockTime = 14,
    },
    Night = {
        Brightness = 0, Ambient = Color3.fromRGB(30,30,60),
        OutdoorAmbient = Color3.fromRGB(20,20,50),
        FogEnd = 600, FogColor = Color3.fromRGB(10,10,30),
        ClockTime = 0,
    },
    Day = {
        Brightness = 2, Ambient = Color3.fromRGB(180,180,180),
        OutdoorAmbient = Color3.fromRGB(220,220,220),
        FogEnd = 100000, FogColor = Color3.fromRGB(191,191,191),
        ClockTime = 12,
    },
    Sunset = {
        Brightness = 1.2, Ambient = Color3.fromRGB(180,80,40),
        OutdoorAmbient = Color3.fromRGB(200,100,50),
        FogEnd = 800, FogColor = Color3.fromRGB(200,120,60),
        ClockTime = 19,
    },
    Fog = {
        Brightness = 0.7, Ambient = Color3.fromRGB(100,100,120),
        OutdoorAmbient = Color3.fromRGB(120,120,140),
        FogEnd = 200, FogColor = Color3.fromRGB(180,180,200),
        ClockTime = 10,
    },
    Neon = {
        Brightness = 0.2, Ambient = Color3.fromRGB(60,0,80),
        OutdoorAmbient = Color3.fromRGB(40,0,60),
        FogEnd = 500, FogColor = Color3.fromRGB(80,0,120),
        ClockTime = 0,
    },
}

local function ApplyLighting(preset)
    local p = LightingPresets[preset]
    if not p then return end
    TweenService:Create(Lighting, TweenInfo.new(1.5), {
        Brightness      = p.Brightness,
        Ambient         = p.Ambient,
        OutdoorAmbient  = p.OutdoorAmbient,
        FogEnd          = p.FogEnd,
        FogColor        = p.FogColor,
        ClockTime       = p.ClockTime,
    }):Play()
    Cfg.Lighting.Mode = preset
end

-- ════════════════════════════════════════════════════════════════
-- YARDIMCI FONKSİYONLAR
-- ════════════════════════════════════════════════════════════════
local function IsAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function IsSameTeam(p) return p.Team ~= nil and p.Team == LP.Team end

local function W2S(pos)
    local sp, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), on, sp.Z
end

local function GetDist(p)
    local c,lc = p.Character, LP.Character
    if not c or not lc then return math.huge end
    local r  = c:FindFirstChild("HumanoidRootPart")
    local lr = lc:FindFirstChild("HumanoidRootPart")
    if not r or not lr then return math.huge end
    return (r.Position-lr.Position).Magnitude
end

-- ════════════════════════════════════════════════════════════════
-- SKIN CHANGER
-- ════════════════════════════════════════════════════════════════
local function ApplySkin(presetName)
    if not Cfg.SkinChanger.Enabled then return end
    local char = LP.Character
    if not char then return end
    local colors = SkinPresets[presetName or Cfg.SkinChanger.Preset]
    if not colors then return end
    local map = {
        Head="Head",Torso="Torso",
        ["Left Arm"]="LeftArm",["Right Arm"]="RightArm",
        ["Left Leg"]="LeftLeg",["Right Leg"]="RightLeg",
        UpperTorso="Torso",LowerTorso="Torso",
        LeftUpperArm="LeftArm",RightUpperArm="RightArm",
        LeftLowerArm="LeftArm",RightLowerArm="RightArm",
        LeftHand="LeftArm",RightHand="RightArm",
        LeftUpperLeg="LeftLeg",RightUpperLeg="RightLeg",
        LeftLowerLeg="LeftLeg",RightLowerLeg="RightLeg",
        LeftFoot="LeftLeg",RightFoot="RightLeg",
    }
    for partName, colorKey in pairs(map) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            local cn = colors[colorKey]
            if cn then pcall(function() part.BrickColor = BrickColor.new(cn) end) end
        end
    end
end

LP.CharacterAdded:Connect(function() task.wait(1.5) ApplySkin() end)
task.spawn(function() task.wait(1) ApplySkin() end)

-- ════════════════════════════════════════════════════════════════
-- RAINBOW LOOP
-- ════════════════════════════════════════════════════════════════
local rainbowHue = 0
RunService.Heartbeat:Connect(function(dt)
    rainbowHue = (rainbowHue + dt * Cfg.Rainbow.Speed / 6) % 1
    local rainbowColor = Color3.fromHSV(rainbowHue, Cfg.Rainbow.Saturation, Cfg.Rainbow.Brightness)

    -- Rainbow Silah
    if Cfg.Rainbow.WeaponEnabled then
        local char = LP.Character
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, part in ipairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("UnionOperation") then
                            pcall(function() part.Color = rainbowColor end)
                        end
                    end
                end
            end
        end
    end

    -- Rainbow Karakter
    if Cfg.Rainbow.CharEnabled then
        local char = LP.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    pcall(function() part.Color = rainbowColor end)
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- CHAMS (duvardan görünen model)
-- ════════════════════════════════════════════════════════════════
local ChamObjects = {} -- [player] = {highlight}

local function ApplyChams(player, enable)
    -- Highlight instance kullan (Roblox'un kendi API'si, local)
    local existing = ChamObjects[player]
    if existing then
        existing:Destroy()
        ChamObjects[player] = nil
    end
    if not enable then return end
    local char = player.Character
    if not char then return end
    local hl = Instance.new("SelectionBox")
    hl.Adornee         = char
    hl.Color3          = IsSameTeam(player) and Cfg.Chams.TeamColor or Cfg.Chams.Color
    hl.LineThickness   = 0.07
    hl.SurfaceColor3   = IsSameTeam(player) and Cfg.Chams.TeamColor or Cfg.Chams.Color
    hl.SurfaceTransparency = Cfg.Chams.Transparency
    hl.Parent          = workspace
    ChamObjects[player] = hl
end

local function RefreshChams()
    for p, hl in pairs(ChamObjects) do
        hl:Destroy()
        ChamObjects[p] = nil
    end
    if not Cfg.Chams.Enabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then ApplyChams(p, true) end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Cfg.Chams.Enabled then ApplyChams(p, true) end
    end)
end)
Players.PlayerRemoving:Connect(function(p)
    if ChamObjects[p] then ChamObjects[p]:Destroy(); ChamObjects[p] = nil end
end)

-- ════════════════════════════════════════════════════════════════
-- DRAWING SETUP
-- ════════════════════════════════════════════════════════════════
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false; fovCircle.Radius = Cfg.Aimbot.FOV
fovCircle.Thickness = 1.5; fovCircle.Filled = false; fovCircle.NumSides = 80

local CHLines = {}
for i = 1,4 do
    local l = Drawing.new("Line"); l.Visible = false
    l.Thickness = 1.5; table.insert(CHLines, l)
end
local CHDot = Drawing.new("Circle")
CHDot.Visible = false; CHDot.Radius = 1.8; CHDot.Filled = true; CHDot.NumSides = 8

local RadarBG     = Drawing.new("Square"); RadarBG.Visible = false; RadarBG.Filled = true
RadarBG.Color     = Color3.fromRGB(8,8,12); RadarBG.Transparency = 0.4
local RadarBorder = Drawing.new("Square"); RadarBorder.Visible = false
RadarBorder.Filled = false; RadarBorder.Thickness = 1.5
RadarBorder.Color  = Color3.fromRGB(160, 60, 255)
local RadarLabel  = Drawing.new("Text"); RadarLabel.Visible = false
RadarLabel.Text = "RADAR"; RadarLabel.Size = 10; RadarLabel.Center = true
RadarLabel.Outline = true; RadarLabel.Color = Color3.fromRGB(160,60,255)
RadarLabel.Font = Drawing.Fonts.Plex
local RadarSelf   = Drawing.new("Circle"); RadarSelf.Visible = false
RadarSelf.Filled = true; RadarSelf.Color = Color3.fromRGB(100,200,255)
RadarSelf.Radius = 4; RadarSelf.NumSides = 8

local ESPObj   = {}
local RadarDots= {}

local function NewESP(p)
    local o = {}
    o.BoxFill   = Drawing.new("Square"); o.BoxFill.Visible=false; o.BoxFill.Filled=true; o.BoxFill.Transparency=0.85
    o.BoxShadow = Drawing.new("Square"); o.BoxShadow.Visible=false; o.BoxShadow.Filled=false; o.BoxShadow.Thickness=3; o.BoxShadow.Color=Color3.fromRGB(0,0,0)
    o.Box       = Drawing.new("Square"); o.Box.Visible=false; o.Box.Filled=false; o.Box.Thickness=1.5
    o.Corners   = {}
    for i=1,8 do local l=Drawing.new("Line"); l.Visible=false; l.Thickness=2; table.insert(o.Corners,l) end
    o.Name      = Drawing.new("Text"); o.Name.Visible=false; o.Name.Size=13; o.Name.Center=true; o.Name.Outline=true; o.Name.Font=Drawing.Fonts.Plex
    o.Dist      = Drawing.new("Text"); o.Dist.Visible=false; o.Dist.Size=11; o.Dist.Center=true; o.Dist.Outline=true; o.Dist.Color=Color3.fromRGB(200,200,200); o.Dist.Font=Drawing.Fonts.Plex
    o.HBarBG    = Drawing.new("Square"); o.HBarBG.Visible=false; o.HBarBG.Filled=true; o.HBarBG.Color=Color3.fromRGB(15,15,15)
    o.HBar      = Drawing.new("Square"); o.HBar.Visible=false; o.HBar.Filled=true
    o.Tracer    = Drawing.new("Line"); o.Tracer.Visible=false; o.Tracer.Thickness=1
    o.Skel      = {}
    for i=1,5 do local l=Drawing.new("Line"); l.Visible=false; l.Thickness=1; table.insert(o.Skel,l) end
    ESPObj[p] = o
end

local function RemoveESP(p)
    local o = ESPObj[p]
    if not o then return end
    for _,v in pairs(o) do
        if type(v)=="table" then for _,l in pairs(v) do pcall(function() l:Remove() end) end
        else pcall(function() v:Remove() end) end
    end
    ESPObj[p] = nil
end

for _,p in ipairs(Players:GetPlayers()) do if p~=LP then NewESP(p) end end
Players.PlayerAdded:Connect(NewESP)
Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

local function RefreshRadarDots()
    for _,rd in pairs(RadarDots) do pcall(function() rd.dot:Remove() end) end
    RadarDots = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            local d = Drawing.new("Circle")
            d.Visible=false; d.Filled=true; d.Radius=4; d.NumSides=8
            table.insert(RadarDots,{dot=d,player=p})
        end
    end
end
RefreshRadarDots()
Players.PlayerAdded:Connect(function() task.wait(0.5) RefreshRadarDots() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) RefreshRadarDots() end)

-- ════════════════════════════════════════════════════════════════
-- CORNER BOX + SKELETON
-- ════════════════════════════════════════════════════════════════
local function DrawCornerBox(o,x,y,w,h,col)
    local cL = math.min(w,h)*0.22
    local pts = {
        {Vector2.new(x,y),Vector2.new(x+cL,y)},{Vector2.new(x,y),Vector2.new(x,y+cL)},
        {Vector2.new(x+w,y),Vector2.new(x+w-cL,y)},{Vector2.new(x+w,y),Vector2.new(x+w,y+cL)},
        {Vector2.new(x,y+h),Vector2.new(x+cL,y+h)},{Vector2.new(x,y+h),Vector2.new(x,y+h-cL)},
        {Vector2.new(x+w,y+h),Vector2.new(x+w-cL,y+h)},{Vector2.new(x+w,y+h),Vector2.new(x+w,y+h-cL)},
    }
    for i,pt in ipairs(pts) do
        o.Corners[i].From=pt[1]; o.Corners[i].To=pt[2]; o.Corners[i].Color=col; o.Corners[i].Visible=true
    end
end
local function HideCorners(o) for _,l in ipairs(o.Corners) do l.Visible=false end end

local function DrawSkeleton(o,char,col)
    local parts = {
        char:FindFirstChild("Head"),
        char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
        char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
        char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
        char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
        char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
    }
    local conns = {{1,2},{2,3},{2,4},{2,5},{2,6}}
    for i,conn in ipairs(conns) do
        local a,b = parts[conn[1]], parts[conn[2]]
        local sl = o.Skel[i]
        if a and b and sl then
            local pa,aOn = W2S(a.Position)
            local pb,bOn = W2S(b.Position)
            if aOn or bOn then sl.From=pa; sl.To=pb; sl.Color=col; sl.Visible=true
            else sl.Visible=false end
        elseif sl then sl.Visible=false end
    end
end

-- ════════════════════════════════════════════════════════════════
-- AIMBOT
-- ════════════════════════════════════════════════════════════════
local function GetTarget()
    local best,bestD = nil, Cfg.Aimbot.FOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        if Cfg.Aimbot.TeamCheck and IsSameTeam(p) then continue end
        if not IsAlive(p) then continue end
        local char = p.Character
        local part = char and char:FindFirstChild(Cfg.Aimbot.Part)
        if not part then continue end
        local aimPos = part.Position
        if Cfg.Aimbot.PredictFactor > 0 then
            local r = char:FindFirstChild("HumanoidRootPart")
            if r then aimPos = aimPos + r.AssemblyLinearVelocity * Cfg.Aimbot.PredictFactor end
        end
        if Cfg.Aimbot.WallCheck then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {LP.Character, Camera}
            params.FilterType = Enum.RaycastFilterType.Exclude
            local lc = LP.Character
            local lr = lc and lc:FindFirstChild("HumanoidRootPart")
            if lr then
                local dir = aimPos - lr.Position
                local res = workspace:Raycast(lr.Position, dir, params)
                if res then continue end
            end
        end
        local sp,on = W2S(aimPos)
        if not on then continue end
        local d = (sp-center).Magnitude
        if d < bestD then bestD=d; best={player=p,pos=aimPos} end
    end
    return best
end

-- ════════════════════════════════════════════════════════════════
-- NO RECOIL
-- ════════════════════════════════════════════════════════════════
local lastCF = Camera.CFrame
local function ApplyNoRecoil()
    if not Cfg.NoRecoil.Enabled then lastCF=Camera.CFrame; return end
    local cur = Camera.CFrame
    local lp  = math.asin(math.clamp(lastCF.LookVector.Y,-1,1))
    local cp  = math.asin(math.clamp(cur.LookVector.Y,-1,1))
    if cp - lp > 0.002 then
        Camera.CFrame = cur * CFrame.Angles(-(cp-lp)*Cfg.NoRecoil.Strength,0,0)
    end
    lastCF = Camera.CFrame
end

-- ════════════════════════════════════════════════════════════════
-- MAIN RENDER LOOP
-- ════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function(dt)
    local vp     = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)

    -- FOV Circle
    fovCircle.Position = center
    fovCircle.Visible  = Cfg.Aimbot.Enabled and Cfg.Aimbot.ShowFOV
    fovCircle.Color    = Cfg.Aimbot.FOVColor
    fovCircle.Radius   = Cfg.Aimbot.FOV

    -- Crosshair
    if Cfg.Crosshair.Enabled then
        local s,g,t,c = Cfg.Crosshair.Size, Cfg.Crosshair.Gap, Cfg.Crosshair.Thickness, Cfg.Crosshair.Color
        CHLines[1].From=Vector2.new(center.X-s-g,center.Y); CHLines[1].To=Vector2.new(center.X-g,center.Y)
        CHLines[2].From=Vector2.new(center.X+g,center.Y);   CHLines[2].To=Vector2.new(center.X+s+g,center.Y)
        CHLines[3].From=Vector2.new(center.X,center.Y-s-g); CHLines[3].To=Vector2.new(center.X,center.Y-g)
        CHLines[4].From=Vector2.new(center.X,center.Y+g);   CHLines[4].To=Vector2.new(center.X,center.Y+s+g)
        for _,l in ipairs(CHLines) do l.Color=c; l.Thickness=t; l.Visible=true end
        CHDot.Position=center; CHDot.Color=c; CHDot.Visible=Cfg.Crosshair.Dot
    else
        for _,l in ipairs(CHLines) do l.Visible=false end; CHDot.Visible=false
    end

    -- Aimbot
    if Cfg.Aimbot.Enabled and UIS:IsKeyDown(Cfg.Aimbot.Key) then
        local t = GetTarget()
        if t then
            local cur = Camera.CFrame
            Camera.CFrame = cur:Lerp(CFrame.lookAt(cur.Position, t.pos), Cfg.Aimbot.Smoothness)
        end
    end

    -- No Recoil
    ApplyNoRecoil()

    -- ESP
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local o = ESPObj[p]
        if not o then continue end
        local show = Cfg.ESP.Enabled and IsAlive(p) and GetDist(p)<=Cfg.ESP.MaxDist
        if Cfg.ESP.TeamCheck and IsSameTeam(p) then show=false end
        local function hideAll()
            o.Box.Visible=false; o.BoxShadow.Visible=false; o.BoxFill.Visible=false
            o.Name.Visible=false; o.Dist.Visible=false
            o.HBar.Visible=false; o.HBarBG.Visible=false; o.Tracer.Visible=false
            HideCorners(o); for _,l in ipairs(o.Skel) do l.Visible=false end
        end
        if not show then hideAll(); continue end
        local char = p.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        if not root or not head then hideAll(); continue end
        local headPos,hOn = W2S(head.Position+Vector3.new(0,0.75,0))
        local footPos,fOn = W2S(root.Position-Vector3.new(0,3.1,0))
        if not hOn and not fOn then hideAll(); continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hpR = hum and math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1) or 0
        local bH  = math.abs(footPos.Y-headPos.Y)
        local bW  = bH*0.52
        local bX  = headPos.X-bW/2
        local bY  = headPos.Y
        local eCol= IsSameTeam(p) and Cfg.ESP.TeamColor or Cfg.ESP.BoxColor

        if Cfg.ESP.Box then
            if Cfg.ESP.CornerBox then
                o.Box.Visible=false; o.BoxShadow.Visible=false; o.BoxFill.Visible=false
                DrawCornerBox(o,bX,bY,bW,bH,eCol)
            else
                HideCorners(o)
                o.BoxShadow.Size=Vector2.new(bW+3,bH+3); o.BoxShadow.Position=Vector2.new(bX-1.5,bY-1.5); o.BoxShadow.Visible=true
                o.Box.Size=Vector2.new(bW,bH); o.Box.Position=Vector2.new(bX,bY); o.Box.Color=eCol; o.Box.Visible=true
                o.BoxFill.Size=Vector2.new(bW,bH); o.BoxFill.Position=Vector2.new(bX,bY); o.BoxFill.Color=eCol; o.BoxFill.Visible=true
            end
        else
            o.Box.Visible=false; o.BoxShadow.Visible=false; o.BoxFill.Visible=false; HideCorners(o)
        end

        if Cfg.ESP.HealthBar then
            local bx=bX-8
            o.HBarBG.Size=Vector2.new(4,bH+2); o.HBarBG.Position=Vector2.new(bx,bY-1); o.HBarBG.Visible=true
            o.HBar.Color=Color3.fromRGB(math.floor((1-hpR)*255),math.floor(hpR*255),0)
            o.HBar.Size=Vector2.new(4,(bH+2)*hpR); o.HBar.Position=Vector2.new(bx,bY-1+(bH+2)*(1-hpR)); o.HBar.Visible=true
        else o.HBar.Visible=false; o.HBarBG.Visible=false end

        if Cfg.ESP.Name then o.Name.Text=p.DisplayName; o.Name.Color=eCol; o.Name.Position=Vector2.new(headPos.X,headPos.Y-18); o.Name.Visible=true
        else o.Name.Visible=false end

        if Cfg.ESP.Distance then o.Dist.Text=string.format("[%.0fm]",GetDist(p)/6.5); o.Dist.Position=Vector2.new(headPos.X,footPos.Y+2); o.Dist.Visible=true
        else o.Dist.Visible=false end

        if Cfg.ESP.Tracer then
            o.Tracer.From=Vector2.new(center.X,vp.Y); o.Tracer.To=Vector2.new(footPos.X,footPos.Y); o.Tracer.Color=eCol; o.Tracer.Visible=true
        else o.Tracer.Visible=false end

        if Cfg.ESP.Skeleton then DrawSkeleton(o,char,Cfg.ESP.SkelColor)
        else for _,l in ipairs(o.Skel) do l.Visible=false end end
    end

    -- Radar
    if Cfg.Radar.Enabled then
        local rs = Cfg.Radar.Size
        local rx = 20
        local ry = vp.Y - 20 - rs
        RadarBG.Size=Vector2.new(rs,rs); RadarBG.Position=Vector2.new(rx,ry); RadarBG.Visible=true
        RadarBorder.Size=Vector2.new(rs,rs); RadarBorder.Position=Vector2.new(rx,ry); RadarBorder.Visible=true
        RadarLabel.Position=Vector2.new(rx+rs/2, ry+rs+2); RadarLabel.Visible=true
        RadarSelf.Position=Vector2.new(rx+rs/2,ry+rs/2); RadarSelf.Visible=true
        local lc=LP.Character; local lr=lc and lc:FindFirstChild("HumanoidRootPart")
        local lCF = lr and lr.CFrame or CFrame.new()
        for _,rd in ipairs(RadarDots) do
            local pp=rd.player; local dot=rd.dot
            if not IsAlive(pp) then dot.Visible=false; continue end
            local c2=pp.Character; local r2=c2 and c2:FindFirstChild("HumanoidRootPart")
            if not r2 then dot.Visible=false; continue end
            local rel=lCF:PointToObjectSpace(r2.Position)
            local nx=rel.X/Cfg.Radar.Range; local nz=rel.Z/Cfg.Radar.Range
            if math.abs(nx)>1 or math.abs(nz)>1 then dot.Visible=false; continue end
            dot.Position=Vector2.new(rx+rs/2+nx*(rs/2)*Cfg.Radar.Scale, ry+rs/2-nz*(rs/2)*Cfg.Radar.Scale)
            dot.Color=IsSameTeam(pp) and Cfg.ESP.TeamColor or Color3.fromRGB(255,55,55); dot.Visible=true
        end
    else
        RadarBG.Visible=false; RadarBorder.Visible=false; RadarSelf.Visible=false; RadarLabel.Visible=false
        for _,rd in ipairs(RadarDots) do rd.dot.Visible=false end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- GUI — MOR/SİYAH TEMA, ACCORDION MENÜ
-- ════════════════════════════════════════════════════════════════
local PURPLE  = Color3.fromRGB(140, 50, 255)
local PURPLE2 = Color3.fromRGB(100, 30, 200)
local DARK    = Color3.fromRGB(10, 8, 18)
local DARK2   = Color3.fromRGB(18, 14, 30)
local DARK3   = Color3.fromRGB(25, 20, 42)
local TEXT    = Color3.fromRGB(220, 210, 255)
local TEXTDIM = Color3.fromRGB(150, 130, 200)

local SG = Instance.new("ScreenGui")
SG.Name="KontraUltraV3"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent=game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent=LP.PlayerGui end

-- Ana frame
local MF = Instance.new("Frame")
MF.Size=UDim2.new(0,280,0,520); MF.Position=UDim2.new(0,12,0.5,-260)
MF.BackgroundColor3=DARK; MF.BorderSizePixel=0; MF.Active=true; MF.Draggable=true
MF.Visible=false; MF.ClipsDescendants=false; MF.Parent=SG
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,12)
local mfStroke=Instance.new("UIStroke",MF); mfStroke.Color=PURPLE; mfStroke.Thickness=1.8

-- Glow efekti (shadow)
local Shadow=Instance.new("ImageLabel")
Shadow.Size=UDim2.new(1,30,1,30); Shadow.Position=UDim2.new(0,-15,0,-15)
Shadow.BackgroundTransparency=1
Shadow.Image="rbxassetid://1316045217"
Shadow.ImageColor3=PURPLE2; Shadow.ImageTransparency=0.6; Shadow.ScaleType=Enum.ScaleType.Slice
Shadow.SliceCenter=Rect.new(10,10,118,118); Shadow.ZIndex=0; Shadow.Parent=MF

-- Header
local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,48); Header.BackgroundColor3=DARK2; Header.BorderSizePixel=0; Header.ZIndex=2; Header.Parent=MF
Instance.new("UICorner",Header).CornerRadius=UDim.new(0,12)
local HPatch=Instance.new("Frame"); HPatch.Size=UDim2.new(1,0,0.5,0); HPatch.Position=UDim2.new(0,0,0.5,0); HPatch.BackgroundColor3=DARK2; HPatch.BorderSizePixel=0; HPatch.Parent=Header

-- Header accent line
local HAccent=Instance.new("Frame")
HAccent.Size=UDim2.new(0,4,0.7,0); HAccent.Position=UDim2.new(0,8,0.15,0)
HAccent.BackgroundColor3=PURPLE; HAccent.BorderSizePixel=0; HAccent.Parent=Header
Instance.new("UICorner",HAccent).CornerRadius=UDim.new(1,0)

local HTitle=Instance.new("TextLabel"); HTitle.Size=UDim2.new(1,-20,0,22); HTitle.Position=UDim2.new(0,20,0,5)
HTitle.BackgroundTransparency=1; HTitle.Text="KONTRA ULTRA  v3.0"; HTitle.TextColor3=TEXT
HTitle.Font=Enum.Font.GothamBold; HTitle.TextSize=14; HTitle.TextXAlignment=Enum.TextXAlignment.Left; HTitle.Parent=Header

local HSub=Instance.new("TextLabel"); HSub.Size=UDim2.new(1,-20,0,14); HSub.Position=UDim2.new(0,20,0,26)
HSub.BackgroundTransparency=1; HSub.Text="RightShift = Toggle  ·  Q = Aimbot"; HSub.TextColor3=TEXTDIM
HSub.Font=Enum.Font.Gotham; HSub.TextSize=10; HSub.TextXAlignment=Enum.TextXAlignment.Left; HSub.Parent=Header

-- Scroll
local Scroll=Instance.new("ScrollingFrame")
Scroll.Size=UDim2.new(1,-10,1,-56); Scroll.Position=UDim2.new(0,5,0,52)
Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3; Scroll.ScrollBarImageColor3=PURPLE
Scroll.CanvasSize=UDim2.new(0,0,0,0); Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
Scroll.Parent=MF

local SList=Instance.new("UIListLayout"); SList.Parent=Scroll; SList.SortOrder=Enum.SortOrder.LayoutOrder; SList.Padding=UDim.new(0,4)
local SPad=Instance.new("UIPadding"); SPad.PaddingLeft=UDim.new(0,2); SPad.PaddingRight=UDim.new(0,2); SPad.Parent=Scroll

-- ── ACCORDION SECTION ──────────────────────────────────────────
local sectionOrder = 0
local function MakeSection(title, emoji)
    sectionOrder = sectionOrder + 1
    local sec = Instance.new("Frame")
    sec.Size=UDim2.new(1,-4,0,36); sec.BackgroundColor3=DARK3; sec.BorderSizePixel=0
    sec.LayoutOrder=sectionOrder; sec.AutomaticSize=Enum.AutomaticSize.Y; sec.ClipsDescendants=false
    sec.Parent=Scroll
    Instance.new("UICorner",sec).CornerRadius=UDim.new(0,8)
    local secStroke=Instance.new("UIStroke",sec); secStroke.Color=PURPLE2; secStroke.Thickness=1

    -- Header butonu
    local hBtn=Instance.new("TextButton")
    hBtn.Size=UDim2.new(1,0,0,36); hBtn.BackgroundColor3=DARK2; hBtn.BorderSizePixel=0
    hBtn.Text=""; hBtn.AutoButtonColor=false; hBtn.ZIndex=2; hBtn.Parent=sec
    Instance.new("UICorner",hBtn).CornerRadius=UDim.new(0,8)

    local hAccLine=Instance.new("Frame")
    hAccLine.Size=UDim2.new(0,3,0.6,0); hAccLine.Position=UDim2.new(0,6,0.2,0)
    hAccLine.BackgroundColor3=PURPLE; hAccLine.BorderSizePixel=0; hAccLine.ZIndex=3; hAccLine.Parent=hBtn
    Instance.new("UICorner",hAccLine).CornerRadius=UDim.new(1,0)

    local hLbl=Instance.new("TextLabel")
    hLbl.Size=UDim2.new(1,-40,1,0); hLbl.Position=UDim2.new(0,16,0,0)
    hLbl.BackgroundTransparency=1; hLbl.Text=emoji.."  "..title; hLbl.TextColor3=TEXT
    hLbl.Font=Enum.Font.GothamBold; hLbl.TextSize=12; hLbl.TextXAlignment=Enum.TextXAlignment.Left; hLbl.ZIndex=3; hLbl.Parent=hBtn

    local arrow=Instance.new("TextLabel")
    arrow.Size=UDim2.new(0,24,0,24); arrow.Position=UDim2.new(1,-28,0.5,-12)
    arrow.BackgroundTransparency=1; arrow.Text="▾"; arrow.TextColor3=PURPLE
    arrow.Font=Enum.Font.GothamBold; arrow.TextSize=14; arrow.ZIndex=3; arrow.Parent=hBtn

    -- İçerik frame
    local content=Instance.new("Frame")
    content.Size=UDim2.new(1,0,0,0); content.Position=UDim2.new(0,0,0,36)
    content.BackgroundTransparency=1; content.BorderSizePixel=0
    content.AutomaticSize=Enum.AutomaticSize.Y; content.Visible=false; content.Parent=sec

    local cList=Instance.new("UIListLayout"); cList.Parent=content; cList.Padding=UDim.new(0,3)
    local cPad=Instance.new("UIPadding"); cPad.PaddingLeft=UDim.new(0,6); cPad.PaddingRight=UDim.new(0,6); cPad.PaddingTop=UDim.new(0,4); cPad.PaddingBottom=UDim.new(0,6); cPad.Parent=content

    local open=false
    hBtn.MouseButton1Click:Connect(function()
        open=not open
        content.Visible=open
        TweenService:Create(arrow,TweenInfo.new(0.2),{Rotation=open and 180 or 0}):Play()
        TweenService:Create(hBtn,TweenInfo.new(0.15),{BackgroundColor3=open and DARK3 or DARK2}):Play()
    end)

    hBtn.MouseEnter:Connect(function() if not open then TweenService:Create(hBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(28,22,48)}):Play() end end)
    hBtn.MouseLeave:Connect(function() if not open then TweenService:Create(hBtn,TweenInfo.new(0.15),{BackgroundColor3=DARK2}):Play() end end)

    return content
end

-- ── TOGGLE ────────────────────────────────────────────────────
local itemOrder=0
local function MakeToggle(parent, label, default, onChange)
    itemOrder=itemOrder+1
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,30); row.BackgroundColor3=DARK; row.BorderSizePixel=0; row.LayoutOrder=itemOrder; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-60,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=TEXT
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row

    local state=default
    local track=Instance.new("Frame")
    track.Size=UDim2.new(0,42,0,20); track.Position=UDim2.new(1,-50,0.5,-10)
    track.BackgroundColor3=state and PURPLE or Color3.fromRGB(40,30,60)
    track.BorderSizePixel=0; track.Parent=row
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(state and 1 or 0, state and -18 or 2, 0.5,-8)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=row

    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(track,TweenInfo.new(0.2),{BackgroundColor3=state and PURPLE or Color3.fromRGB(40,30,60)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.2),{Position=UDim2.new(state and 1 or 0, state and -18 or 2, 0.5,-8)}):Play()
        onChange(state)
    end)
end

-- ── BUTTON ────────────────────────────────────────────────────
local function MakeButton(parent, label, onClick)
    itemOrder=itemOrder+1
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,28); btn.LayoutOrder=itemOrder
    btn.BackgroundColor3=PURPLE2; btn.BorderSizePixel=0; btn.Text=label
    btn.TextColor3=TEXT; btn.Font=Enum.Font.GothamBold; btn.TextSize=11; btn.Parent=parent
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)

    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=PURPLE}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=PURPLE2}):Play() end)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.05),{BackgroundColor3=Color3.fromRGB(180,100,255)}):Play()
        task.delay(0.12,function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=PURPLE2}):Play() end)
        onClick()
    end)
end

-- ── LABEL ─────────────────────────────────────────────────────
local function MakeLabel(parent, text)
    itemOrder=itemOrder+1
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,0,20); lbl.LayoutOrder=itemOrder
    lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=TEXTDIM
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=parent
end

-- ════════════════════════════════════════════════════════════════
-- MENÜ DOLDURMA
-- ════════════════════════════════════════════════════════════════

-- 🎯 AIMBOT
local Aim = MakeSection("Aimbot","🎯")
MakeToggle(Aim,"Aimbot Aktif",Cfg.Aimbot.Enabled,function(v) Cfg.Aimbot.Enabled=v end)
MakeToggle(Aim,"FOV Çemberi",Cfg.Aimbot.ShowFOV,function(v) Cfg.Aimbot.ShowFOV=v end)
MakeToggle(Aim,"Takım Kontrolü",Cfg.Aimbot.TeamCheck,function(v) Cfg.Aimbot.TeamCheck=v end)
MakeToggle(Aim,"Duvar Kontrolü",Cfg.Aimbot.WallCheck,function(v) Cfg.Aimbot.WallCheck=v end)
MakeToggle(Aim,"Velocity Predict",Cfg.Aimbot.PredictFactor>0,function(v) Cfg.Aimbot.PredictFactor=v and 0.08 or 0 end)
MakeToggle(Aim,"Head Aim",Cfg.Aimbot.Part=="Head",function(v) Cfg.Aimbot.Part=v and "Head" or "HumanoidRootPart" end)
MakeToggle(Aim,"No Recoil",Cfg.NoRecoil.Enabled,function(v) Cfg.NoRecoil.Enabled=v end)

-- 👁 ESP
local Esp = MakeSection("ESP","👁")
MakeToggle(Esp,"ESP Aktif",Cfg.ESP.Enabled,function(v) Cfg.ESP.Enabled=v end)
MakeToggle(Esp,"Box",Cfg.ESP.Box,function(v) Cfg.ESP.Box=v end)
MakeToggle(Esp,"Köşe Box (Corner)",Cfg.ESP.CornerBox,function(v) Cfg.ESP.CornerBox=v end)
MakeToggle(Esp,"İsim",Cfg.ESP.Name,function(v) Cfg.ESP.Name=v end)
MakeToggle(Esp,"Mesafe",Cfg.ESP.Distance,function(v) Cfg.ESP.Distance=v end)
MakeToggle(Esp,"HP Bar",Cfg.ESP.HealthBar,function(v) Cfg.ESP.HealthBar=v end)
MakeToggle(Esp,"Skeleton (İskelet)",Cfg.ESP.Skeleton,function(v) Cfg.ESP.Skeleton=v end)
MakeToggle(Esp,"Tracer",Cfg.ESP.Tracer,function(v) Cfg.ESP.Tracer=v end)
MakeToggle(Esp,"Takım Rengi Ayrımı",Cfg.ESP.TeamCheck,function(v) Cfg.ESP.TeamCheck=v end)

-- 💀 CHAMS
local ChamsS = MakeSection("Chams","💀")
MakeToggle(ChamsS,"Chams (Duvar Görüş)",Cfg.Chams.Enabled,function(v) Cfg.Chams.Enabled=v; RefreshChams() end)

-- 🎮 GÖRÜNÜM
local Visual = MakeSection("Crosshair & Radar","🎮")
MakeToggle(Visual,"Custom Crosshair",Cfg.Crosshair.Enabled,function(v)
    Cfg.Crosshair.Enabled=v
    if not v then for _,l in ipairs(CHLines) do l.Visible=false end; CHDot.Visible=false end
end)
MakeToggle(Visual,"Crosshair Dot",Cfg.Crosshair.Dot,function(v) Cfg.Crosshair.Dot=v end)
MakeToggle(Visual,"Mini Radar",Cfg.Radar.Enabled,function(v)
    Cfg.Radar.Enabled=v
    if not v then RadarBG.Visible=false; RadarBorder.Visible=false; RadarSelf.Visible=false; RadarLabel.Visible=false end
end)

-- 🌍 LİGHTING / ORTAM
local Lights = MakeSection("Lighting & Ortam","🌍")
MakeLabel(Lights,"   — Gece / Gündüz Modu —")
MakeButton(Lights,"☀️  Gündüz",function() ApplyLighting("Day") end)
MakeButton(Lights,"🌙  Gece",function() ApplyLighting("Night") end)
MakeButton(Lights,"🌅  Gün Batımı",function() ApplyLighting("Sunset") end)
MakeButton(Lights,"🌫️  Sisli",function() ApplyLighting("Fog") end)
MakeButton(Lights,"🟣  Neon (Mor)",function() ApplyLighting("Neon") end)
MakeButton(Lights,"🔄  Normal",function() ApplyLighting("Normal") end)

-- 🌈 RAINBOW
local Rain = MakeSection("Rainbow Mod","🌈")
MakeToggle(Rain,"Rainbow Silah",Cfg.Rainbow.WeaponEnabled,function(v)
    Cfg.Rainbow.WeaponEnabled=v
    if not v then
        local char=LP.Character
        if char then
            for _,tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    for _,p in ipairs(tool:GetDescendants()) do
                        if p:IsA("BasePart") then pcall(function() p.Color=Color3.fromRGB(163,162,165) end) end
                    end
                end
            end
        end
    end
end)
MakeToggle(Rain,"Rainbow Karakter",Cfg.Rainbow.CharEnabled,function(v)
    Cfg.Rainbow.CharEnabled=v
    if not v then ApplySkin() end
end)

-- 🎨 SKIN CHANGER
local SkinS = MakeSection("Skin Changer","🎨")
MakeToggle(SkinS,"Skin Changer",Cfg.SkinChanger.Enabled,function(v) Cfg.SkinChanger.Enabled=v; if v then ApplySkin() end end)
MakeLabel(SkinS,"   — Skin Presetleri —")
local skinList={"TacticalBlack","Ghost","Desert","Purple","Stealth","Classic"}
local skinEmoji={"⬛","👻","🟡","🟣","🖤","🔵"}
for i,sk in ipairs(skinList) do
    MakeButton(SkinS,skinEmoji[i].."  "..sk,function()
        Cfg.SkinChanger.Preset=sk; Cfg.SkinChanger.Enabled=true; Cfg.Rainbow.CharEnabled=false
        ApplySkin(sk)
    end)
end

-- ════════════════════════════════════════════════════════════════
-- TOGGLE MENU KEY
-- ════════════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then
        MF.Visible = not MF.Visible
    end
end)

-- ════════════════════════════════════════════════════════════════
-- BAŞLANGIÇ BİLDİRİMİ
-- ════════════════════════════════════════════════════════════════
local function Notify(msg, dur)
    local nf=Instance.new("Frame")
    nf.Size=UDim2.new(0,280,0,44); nf.Position=UDim2.new(0.5,-140,0,-55)
    nf.BackgroundColor3=DARK2; nf.BorderSizePixel=0; nf.Parent=SG
    Instance.new("UICorner",nf).CornerRadius=UDim.new(0,10)
    local ns=Instance.new("UIStroke",nf); ns.Color=PURPLE; ns.Thickness=1.5
    local acc=Instance.new("Frame"); acc.Size=UDim2.new(0,3,0.7,0); acc.Position=UDim2.new(0,8,0.15,0)
    acc.BackgroundColor3=PURPLE; acc.BorderSizePixel=0; acc.Parent=nf
    Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,-20,1,0); nl.Position=UDim2.new(0,18,0,0)
    nl.BackgroundTransparency=1; nl.Text=msg; nl.TextColor3=TEXT
    nl.Font=Enum.Font.GothamBold; nl.TextSize=12; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=nf
    TweenService:Create(nf,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-140,0,12)}):Play()
    task.delay(dur or 3.5, function()
        TweenService:Create(nf,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-140,0,-60)}):Play()
        task.delay(0.35,function() nf:Destroy() end)
    end)
end

task.delay(1.5, function() Notify("⚡ KONTRA ULTRA v3.0  |  RightShift = Menü", 4) end)
print("[KontraUltra v3.0] Yüklendi | RShift=Menü | Q=Aim")
