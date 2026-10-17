-- ╔══════════════════════════════════════════════════════════════╗
-- ║         BLOXSTRIKE ULTRA v4.0  |  KontraScript             ║
-- ║   Aimbot · ESP · Skin · Lighting · Rainbow · Chams         ║
-- ║   Executor: Synapse X / KRNL / Fluxus / Delta / Wave       ║
-- ║   Tuş: RightShift = Menü  |  Q = Aimbot                   ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ════════════════════════════════════════════════════════════════
-- EXECUTOR KONTROL — Drawing API var mı?
-- ════════════════════════════════════════════════════════════════
local drawingOK = pcall(function()
    local t = Drawing.new("Square"); t:Remove()
end)

-- Eğer Drawing yoksa, sahte (dummy) objeler oluştur — hata vermesin
if not drawingOK then
    local dummyMt = {__index=function() return function() end end, __newindex=function() end}
    Drawing = setmetatable({}, {__index=function(_, k)
        if k=="new" then
            return function()
                return setmetatable({Remove=function()end,Visible=false},dummyMt)
            end
        elseif k=="Fonts" then return {Plex=1,UI=2,Monospace=3} end
    end})
    warn("[BloxStrikeUltra] Drawing API bulunamadı — ESP devre dışı. Başka executor dene.")
end

-- ════════════════════════════════════════════════════════════════
-- SERVİSLER
-- ════════════════════════════════════════════════════════════════
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
        FOV           = 180,
        Smoothness    = 0.13,
        Part          = "Head",
        TeamCheck     = true,
        WallCheck     = false,
        ShowFOV       = true,
        FOVColor      = Color3.fromRGB(160, 60, 255),
        PredictFactor = 0.07,
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
        MaxDist    = 2500,
        BoxColor   = Color3.fromRGB(160, 60, 255),
        TeamColor  = Color3.fromRGB(60, 255, 140),
        SkelColor  = Color3.fromRGB(255, 200, 60),
    },
    NoRecoil   = { Enabled = true, Strength = 0.55 },
    Crosshair  = {
        Enabled   = true, Size = 10, Gap = 4,
        Thickness = 1.5, Color = Color3.fromRGB(200, 100, 255), Dot = true,
    },
    Radar = {
        Enabled = true, Size = 165, Range = 350, Scale = 0.72,
    },
    SkinChanger = { Enabled = true, Preset = "TacticalBlack" },
    Rainbow     = { WeaponEnabled = false, CharEnabled = false, Speed = 2 },
    Chams       = {
        Enabled = false,
        Color   = Color3.fromRGB(200, 60, 60),
        TeamColor = Color3.fromRGB(60, 200, 120),
        Transparency = 0.45,
    },
}

-- ════════════════════════════════════════════════════════════════
-- SKIN PRESETS
-- ════════════════════════════════════════════════════════════════
local SkinPresets = {
    TacticalBlack = {Head="Pastel brown",Torso="Really black",LA="Really black",RA="Really black",LL="Really black",RL="Really black"},
    Ghost         = {Head="White",Torso="White",LA="White",RA="White",LL="White",RL="White"},
    Desert        = {Head="Pastel brown",Torso="Sand yellow",LA="Sand yellow",RA="Sand yellow",LL="Sand yellow",RL="Sand yellow"},
    Purple        = {Head="Pastel brown",Torso="Dark indigo",LA="Dark indigo",RA="Dark indigo",LL="Dark indigo",RL="Dark indigo"},
    Stealth       = {Head="Really black",Torso="Really black",LA="Really black",RA="Really black",LL="Really black",RL="Really black"},
    Classic       = {Head="Pastel brown",Torso="Bright blue",LA="Bright yellow",RA="Bright yellow",LL="Bright blue",RL="Bright blue"},
}

-- R6 ve R15 için part → preset key mapping
local PartMap = {
    -- R6
    Head        = "Head",
    Torso       = "Torso",
    ["Left Arm"]  = "LA",  ["Right Arm"]  = "RA",
    ["Left Leg"]  = "LL",  ["Right Leg"]  = "RL",
    -- R15
    UpperTorso    = "Torso", LowerTorso = "Torso",
    LeftUpperArm  = "LA",   RightUpperArm = "RA",
    LeftLowerArm  = "LA",   RightLowerArm = "RA",
    LeftHand      = "LA",   RightHand     = "RA",
    LeftUpperLeg  = "LL",   RightUpperLeg = "RL",
    LeftLowerLeg  = "LL",   RightLowerLeg = "RL",
    LeftFoot      = "LL",   RightFoot     = "RL",
}

-- ════════════════════════════════════════════════════════════════
-- LIGHTING PRESETS
-- ════════════════════════════════════════════════════════════════
local LightPresets = {
    Normal  = {Brightness=1,   Ambient=Color3.fromRGB(70,70,70),   OutdoorAmbient=Color3.fromRGB(140,140,140), FogEnd=100000, FogColor=Color3.fromRGB(191,191,191), ClockTime=14},
    Night   = {Brightness=0,   Ambient=Color3.fromRGB(20,20,50),   OutdoorAmbient=Color3.fromRGB(10,10,40),   FogEnd=500,    FogColor=Color3.fromRGB(10,10,30),     ClockTime=0},
    Day     = {Brightness=2.2, Ambient=Color3.fromRGB(200,200,200),OutdoorAmbient=Color3.fromRGB(230,230,230),FogEnd=100000, FogColor=Color3.fromRGB(191,191,191),   ClockTime=12},
    Sunset  = {Brightness=1.2, Ambient=Color3.fromRGB(180,80,40),  OutdoorAmbient=Color3.fromRGB(200,100,50), FogEnd=700,    FogColor=Color3.fromRGB(200,120,60),    ClockTime=19},
    Fog     = {Brightness=0.7, Ambient=Color3.fromRGB(100,100,120),OutdoorAmbient=Color3.fromRGB(120,120,140),FogEnd=180,    FogColor=Color3.fromRGB(180,180,210),   ClockTime=10},
    Neon    = {Brightness=0.1, Ambient=Color3.fromRGB(50,0,80),    OutdoorAmbient=Color3.fromRGB(30,0,60),    FogEnd=400,    FogColor=Color3.fromRGB(80,0,130),      ClockTime=0},
}

local function ApplyLighting(name)
    local p = LightPresets[name]
    if not p then return end
    pcall(function()
        TweenService:Create(Lighting, TweenInfo.new(1.5), {
            Brightness=p.Brightness, Ambient=p.Ambient,
            OutdoorAmbient=p.OutdoorAmbient, FogEnd=p.FogEnd,
            FogColor=p.FogColor, ClockTime=p.ClockTime,
        }):Play()
    end)
end

-- ════════════════════════════════════════════════════════════════
-- YARDIMCI
-- ════════════════════════════════════════════════════════════════
local function IsAlive(p)
    local ok, result = pcall(function()
        local c = p.Character
        if not c then return false end
        local h = c:FindFirstChildOfClass("Humanoid")
        return h ~= nil and h.Health > 0
    end)
    return ok and result
end

local function IsSameTeam(p)
    local ok, result = pcall(function()
        return p.Team ~= nil and p.Team == LP.Team
    end)
    return ok and result
end

local function W2S(pos)
    local ok, sp, on = pcall(function()
        return Camera:WorldToViewportPoint(pos)
    end)
    if not ok then return Vector2.zero, false, 0 end
    return Vector2.new(sp.X, sp.Y), on, sp.Z
end

local function GetDist(p)
    local ok, dist = pcall(function()
        local c   = p.Character
        local lc  = LP.Character
        if not c or not lc then return math.huge end
        local r   = c:FindFirstChild("HumanoidRootPart")
        local lr  = lc:FindFirstChild("HumanoidRootPart")
        if not r or not lr then return math.huge end
        return (r.Position - lr.Position).Magnitude
    end)
    return ok and dist or math.huge
end

-- Karakter parçalarını bul — R6 ve R15 her ikisini dene
local function GetCharPart(char, name)
    if not char then return nil end
    return char:FindFirstChild(name)
end

local function GetHead(char)
    return GetCharPart(char, "Head")
end

local function GetRoot(char)
    return GetCharPart(char, "HumanoidRootPart")
end

local function GetTorso(char)
    return GetCharPart(char, "UpperTorso")
        or GetCharPart(char, "Torso")
end

-- ════════════════════════════════════════════════════════════════
-- SKIN CHANGER
-- ════════════════════════════════════════════════════════════════
local function ApplySkin(presetName)
    pcall(function()
        if not Cfg.SkinChanger.Enabled then return end
        local char   = LP.Character
        if not char  then return end
        local colors = SkinPresets[presetName or Cfg.SkinChanger.Preset]
        if not colors then return end
        for partName, colorKey in pairs(PartMap) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                local cn = colors[colorKey]
                if cn then
                    pcall(function() part.BrickColor = BrickColor.new(cn) end)
                end
            end
        end
    end)
end

LP.CharacterAdded:Connect(function() task.wait(1.5); ApplySkin() end)
task.spawn(function() task.wait(1); ApplySkin() end)

-- ════════════════════════════════════════════════════════════════
-- RAINBOW
-- ════════════════════════════════════════════════════════════════
local rainHue = 0
RunService.Heartbeat:Connect(function(dt)
    rainHue = (rainHue + dt * Cfg.Rainbow.Speed / 6) % 1
    local rc = Color3.fromHSV(rainHue, 1, 1)

    if Cfg.Rainbow.WeaponEnabled then
        pcall(function()
            local char = LP.Character
            if not char then return end
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, part in ipairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("UnionOperation") then
                            pcall(function() part.Color = rc end)
                        end
                    end
                end
            end
        end)
    end

    if Cfg.Rainbow.CharEnabled then
        pcall(function()
            local char = LP.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    pcall(function() part.Color = rc end)
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════
-- CHAMS (Highlight — executor'dan bağımsız çalışır)
-- ════════════════════════════════════════════════════════════════
local ChamHL = {} -- [player] = Highlight instance

local function SetChams(player, enable)
    pcall(function()
        if ChamHL[player] then
            ChamHL[player]:Destroy()
            ChamHL[player] = nil
        end
        if not enable then return end
        local char = player.Character
        if not char then return end

        local hl = Instance.new("Highlight")
        hl.FillColor       = IsSameTeam(player) and Cfg.Chams.TeamColor or Cfg.Chams.Color
        hl.OutlineColor    = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency= Cfg.Chams.Transparency
        hl.OutlineTransparency = 0
        hl.DepthMode       = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee         = char
        hl.Parent          = char
        ChamHL[player]     = hl
    end)
end

local function RefreshChams()
    for p, hl in pairs(ChamHL) do
        pcall(function() hl:Destroy() end)
        ChamHL[p] = nil
    end
    if not Cfg.Chams.Enabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then SetChams(p, true) end
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Cfg.Chams.Enabled then SetChams(p, true) end
        end)
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Cfg.Chams.Enabled then SetChams(p, true) end
    end)
end)
Players.PlayerRemoving:Connect(function(p)
    if ChamHL[p] then pcall(function() ChamHL[p]:Destroy() end); ChamHL[p] = nil end
end)

-- ════════════════════════════════════════════════════════════════
-- DRAWING OBJECTS
-- ════════════════════════════════════════════════════════════════
local function SafeDraw(type_)
    local ok, obj = pcall(function() return Drawing.new(type_) end)
    if ok then return obj end
    return setmetatable({},{__index=function() return function() end end, __newindex=function() end})
end

-- FOV Circle
local fovCircle = SafeDraw("Circle")
pcall(function()
    fovCircle.Visible  = false
    fovCircle.Radius   = Cfg.Aimbot.FOV
    fovCircle.Thickness= 1.5
    fovCircle.Filled   = false
    fovCircle.NumSides = 80
end)

-- Crosshair
local CHLines = {}
for i = 1, 4 do
    local l = SafeDraw("Line")
    pcall(function() l.Visible=false; l.Thickness=1.5 end)
    table.insert(CHLines, l)
end
local CHDot = SafeDraw("Circle")
pcall(function() CHDot.Visible=false; CHDot.Radius=1.8; CHDot.Filled=true; CHDot.NumSides=8 end)

-- Radar
local RadarBG     = SafeDraw("Square")
local RadarBorder = SafeDraw("Square")
local RadarLabel  = SafeDraw("Text")
local RadarSelf   = SafeDraw("Circle")
pcall(function()
    RadarBG.Visible=false; RadarBG.Filled=true
    RadarBG.Color=Color3.fromRGB(8,8,14); RadarBG.Transparency=0.4
    RadarBorder.Visible=false; RadarBorder.Filled=false; RadarBorder.Thickness=1.5
    RadarBorder.Color=Color3.fromRGB(140,50,255)
    RadarLabel.Visible=false; RadarLabel.Text="RADAR"; RadarLabel.Size=9
    RadarLabel.Center=true; RadarLabel.Outline=true
    RadarLabel.Color=Color3.fromRGB(140,50,255); RadarLabel.Font=Drawing.Fonts.Plex
    RadarSelf.Visible=false; RadarSelf.Filled=true
    RadarSelf.Color=Color3.fromRGB(80,180,255); RadarSelf.Radius=4; RadarSelf.NumSides=8
end)

-- ESP objects
local ESPObj    = {}
local RadarDots = {}

local function NewESP(p)
    if p == LP then return end
    local o = {}
    pcall(function()
        o.BoxShadow = SafeDraw("Square"); o.BoxShadow.Visible=false; o.BoxShadow.Filled=false; o.BoxShadow.Thickness=3; o.BoxShadow.Color=Color3.fromRGB(0,0,0)
        o.Box       = SafeDraw("Square"); o.Box.Visible=false; o.Box.Filled=false; o.Box.Thickness=1.8
        o.BoxFill   = SafeDraw("Square"); o.BoxFill.Visible=false; o.BoxFill.Filled=true; o.BoxFill.Transparency=0.82
        o.Corners   = {}
        for i=1,8 do local l=SafeDraw("Line"); pcall(function() l.Visible=false; l.Thickness=2 end); table.insert(o.Corners,l) end
        o.Name      = SafeDraw("Text"); o.Name.Visible=false; o.Name.Size=13; o.Name.Center=true; o.Name.Outline=true; o.Name.Font=Drawing.Fonts.Plex
        o.Dist      = SafeDraw("Text"); o.Dist.Visible=false; o.Dist.Size=11; o.Dist.Center=true; o.Dist.Outline=true; o.Dist.Color=Color3.fromRGB(200,200,200); o.Dist.Font=Drawing.Fonts.Plex
        o.HBarBG    = SafeDraw("Square"); o.HBarBG.Visible=false; o.HBarBG.Filled=true; o.HBarBG.Color=Color3.fromRGB(15,15,15)
        o.HBar      = SafeDraw("Square"); o.HBar.Visible=false; o.HBar.Filled=true
        o.Tracer    = SafeDraw("Line"); o.Tracer.Visible=false; o.Tracer.Thickness=1
        o.Skel      = {}
        for i=1,5 do local l=SafeDraw("Line"); pcall(function() l.Visible=false; l.Thickness=1 end); table.insert(o.Skel,l) end
    end)
    ESPObj[p] = o
end

local function RemoveESP(p)
    local o = ESPObj[p]
    if not o then return end
    for _, v in pairs(o) do
        if type(v) == "table" then
            for _, l in pairs(v) do pcall(function() l:Remove() end) end
        else
            pcall(function() v:Remove() end)
        end
    end
    ESPObj[p] = nil
end

for _, p in ipairs(Players:GetPlayers()) do NewESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(0.5); NewESP(p) end)
Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

local function RefreshRadarDots()
    for _, rd in pairs(RadarDots) do pcall(function() rd.dot:Remove() end) end
    RadarDots = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local d = SafeDraw("Circle")
            pcall(function() d.Visible=false; d.Filled=true; d.Radius=4; d.NumSides=8 end)
            table.insert(RadarDots, {dot=d, player=p})
        end
    end
end
RefreshRadarDots()
Players.PlayerAdded:Connect(function() task.wait(1); RefreshRadarDots() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5); RefreshRadarDots() end)

-- ════════════════════════════════════════════════════════════════
-- CORNER BOX
-- ════════════════════════════════════════════════════════════════
local function DrawCornerBox(o, x, y, w, h, col)
    local cL = math.min(w, h) * 0.22
    local pts = {
        {Vector2.new(x,y),      Vector2.new(x+cL,y)},
        {Vector2.new(x,y),      Vector2.new(x,y+cL)},
        {Vector2.new(x+w,y),    Vector2.new(x+w-cL,y)},
        {Vector2.new(x+w,y),    Vector2.new(x+w,y+cL)},
        {Vector2.new(x,y+h),    Vector2.new(x+cL,y+h)},
        {Vector2.new(x,y+h),    Vector2.new(x,y+h-cL)},
        {Vector2.new(x+w,y+h),  Vector2.new(x+w-cL,y+h)},
        {Vector2.new(x+w,y+h),  Vector2.new(x+w,y+h-cL)},
    }
    for i, pt in ipairs(pts) do
        pcall(function()
            o.Corners[i].From=pt[1]; o.Corners[i].To=pt[2]
            o.Corners[i].Color=col; o.Corners[i].Visible=true
        end)
    end
end

local function HideCorners(o)
    for _, l in ipairs(o.Corners or {}) do pcall(function() l.Visible=false end) end
end

-- ════════════════════════════════════════════════════════════════
-- SKELETON
-- ════════════════════════════════════════════════════════════════
local function DrawSkeleton(o, char, col)
    local parts = {
        GetHead(char),
        GetTorso(char),
        GetCharPart(char,"RightUpperArm") or GetCharPart(char,"Right Arm"),
        GetCharPart(char,"LeftUpperArm")  or GetCharPart(char,"Left Arm"),
        GetCharPart(char,"RightUpperLeg") or GetCharPart(char,"Right Leg"),
        GetCharPart(char,"LeftUpperLeg")  or GetCharPart(char,"Left Leg"),
    }
    local conns = {{1,2},{2,3},{2,4},{2,5},{2,6}}
    for i, conn in ipairs(conns) do
        pcall(function()
            local a, b = parts[conn[1]], parts[conn[2]]
            local sl   = o.Skel[i]
            if not sl then return end
            if a and b then
                local pa, aOn = W2S(a.Position)
                local pb, bOn = W2S(b.Position)
                if aOn or bOn then
                    sl.From=pa; sl.To=pb; sl.Color=col; sl.Visible=true
                    return
                end
            end
            sl.Visible = false
        end)
    end
end

-- ════════════════════════════════════════════════════════════════
-- AIMBOT
-- ════════════════════════════════════════════════════════════════
local function GetTarget()
    local best, bestDist = nil, Cfg.Aimbot.FOV
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if Cfg.Aimbot.TeamCheck and IsSameTeam(p) then continue end
        if not IsAlive(p) then continue end

        pcall(function()
            local char = p.Character
            local part = GetCharPart(char, Cfg.Aimbot.Part)
                      or GetCharPart(char, "Head")
                      or GetCharPart(char, "HumanoidRootPart")
            if not part then return end

            local aimPos = part.Position

            -- Velocity prediction
            if Cfg.Aimbot.PredictFactor > 0 then
                local root = GetRoot(char)
                if root then
                    aimPos = aimPos + root.AssemblyLinearVelocity * Cfg.Aimbot.PredictFactor
                end
            end

            -- Wall check
            if Cfg.Aimbot.WallCheck then
                local lc = LP.Character
                local lr = lc and GetRoot(lc)
                if lr then
                    local dir = aimPos - lr.Position
                    local params = RaycastParams.new()
                    params.FilterDescendantsInstances = {LP.Character, Camera}
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    local res = workspace:Raycast(lr.Position, dir, params)
                    if res then return end
                end
            end

            local sp, on = W2S(aimPos)
            if not on then return end
            local d = (sp - center).Magnitude
            if d < bestDist then
                bestDist = d
                best = {player=p, pos=aimPos}
            end
        end)
    end

    return best
end

-- ════════════════════════════════════════════════════════════════
-- NO RECOIL
-- ════════════════════════════════════════════════════════════════
local lastCF = Camera.CFrame
local function ApplyNoRecoil()
    pcall(function()
        if not Cfg.NoRecoil.Enabled then lastCF=Camera.CFrame; return end
        local cur = Camera.CFrame
        local lp  = math.asin(math.clamp(lastCF.LookVector.Y, -1, 1))
        local cp  = math.asin(math.clamp(cur.LookVector.Y, -1, 1))
        if cp - lp > 0.002 then
            Camera.CFrame = cur * CFrame.Angles(-(cp-lp) * Cfg.NoRecoil.Strength, 0, 0)
        end
        lastCF = Camera.CFrame
    end)
end

-- ════════════════════════════════════════════════════════════════
-- MAIN RENDER LOOP
-- ════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    pcall(function()
        local vp     = Camera.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)

        -- FOV
        pcall(function()
            fovCircle.Position = center
            fovCircle.Visible  = Cfg.Aimbot.Enabled and Cfg.Aimbot.ShowFOV
            fovCircle.Color    = Cfg.Aimbot.FOVColor
            fovCircle.Radius   = Cfg.Aimbot.FOV
        end)

        -- Crosshair
        pcall(function()
            if Cfg.Crosshair.Enabled then
                local s,g,t,c = Cfg.Crosshair.Size, Cfg.Crosshair.Gap, Cfg.Crosshair.Thickness, Cfg.Crosshair.Color
                CHLines[1].From=Vector2.new(center.X-s-g,center.Y); CHLines[1].To=Vector2.new(center.X-g,center.Y)
                CHLines[2].From=Vector2.new(center.X+g,center.Y);   CHLines[2].To=Vector2.new(center.X+s+g,center.Y)
                CHLines[3].From=Vector2.new(center.X,center.Y-s-g); CHLines[3].To=Vector2.new(center.X,center.Y-g)
                CHLines[4].From=Vector2.new(center.X,center.Y+g);   CHLines[4].To=Vector2.new(center.X,center.Y+s+g)
                for _, l in ipairs(CHLines) do l.Color=c; l.Thickness=t; l.Visible=true end
                CHDot.Position=center; CHDot.Color=c; CHDot.Visible=Cfg.Crosshair.Dot
            else
                for _, l in ipairs(CHLines) do l.Visible=false end; CHDot.Visible=false
            end
        end)

        -- Aimbot
        pcall(function()
            if Cfg.Aimbot.Enabled and UIS:IsKeyDown(Cfg.Aimbot.Key) then
                local target = GetTarget()
                if target then
                    local cur  = Camera.CFrame
                    local goal = CFrame.lookAt(cur.Position, target.pos)
                    Camera.CFrame = cur:Lerp(goal, Cfg.Aimbot.Smoothness)
                end
            end
        end)

        -- No Recoil
        ApplyNoRecoil()

        -- ESP
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            local o = ESPObj[p]
            if not o then continue end

            pcall(function()
                local show = Cfg.ESP.Enabled and IsAlive(p) and GetDist(p) <= Cfg.ESP.MaxDist
                if Cfg.ESP.TeamCheck and IsSameTeam(p) then show = false end

                local function hide()
                    pcall(function()
                        o.Box.Visible=false; o.BoxShadow.Visible=false; o.BoxFill.Visible=false
                        o.Name.Visible=false; o.Dist.Visible=false
                        o.HBar.Visible=false; o.HBarBG.Visible=false; o.Tracer.Visible=false
                        HideCorners(o)
                        for _, l in ipairs(o.Skel or {}) do l.Visible=false end
                    end)
                end

                if not show then hide(); return end

                local char = p.Character
                if not char then hide(); return end

                local head = GetHead(char)
                local root = GetRoot(char)
                if not head or not root then hide(); return end

                local headPos, hOn = W2S(head.Position + Vector3.new(0, 0.75, 0))
                local footPos, fOn = W2S(root.Position - Vector3.new(0, 3.2, 0))
                if not hOn and not fOn then hide(); return end

                local hum   = char:FindFirstChildOfClass("Humanoid")
                local hpR   = hum and math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1) or 0
                local bH    = math.abs(footPos.Y - headPos.Y)
                if bH < 5 then hide(); return end -- çok küçük → büyük ihtimalle off-screen

                local bW    = bH * 0.52
                local bX    = headPos.X - bW/2
                local bY    = headPos.Y
                local eCol  = IsSameTeam(p) and Cfg.ESP.TeamColor or Cfg.ESP.BoxColor

                -- Box
                if Cfg.ESP.Box then
                    if Cfg.ESP.CornerBox then
                        o.Box.Visible=false; o.BoxShadow.Visible=false; o.BoxFill.Visible=false
                        DrawCornerBox(o, bX, bY, bW, bH, eCol)
                    else
                        HideCorners(o)
                        o.BoxShadow.Size=Vector2.new(bW+3,bH+3); o.BoxShadow.Position=Vector2.new(bX-1.5,bY-1.5); o.BoxShadow.Visible=true
                        o.Box.Size=Vector2.new(bW,bH); o.Box.Position=Vector2.new(bX,bY); o.Box.Color=eCol; o.Box.Visible=true
                        o.BoxFill.Size=Vector2.new(bW,bH); o.BoxFill.Position=Vector2.new(bX,bY); o.BoxFill.Color=eCol; o.BoxFill.Visible=true
                    end
                else
                    o.Box.Visible=false; o.BoxShadow.Visible=false; o.BoxFill.Visible=false; HideCorners(o)
                end

                -- HP Bar
                if Cfg.ESP.HealthBar then
                    local bx = bX - 9
                    o.HBarBG.Size=Vector2.new(4,bH+2); o.HBarBG.Position=Vector2.new(bx,bY-1); o.HBarBG.Visible=true
                    o.HBar.Color=Color3.fromRGB(math.floor((1-hpR)*255), math.floor(hpR*255), 0)
                    o.HBar.Size=Vector2.new(4,(bH+2)*hpR); o.HBar.Position=Vector2.new(bx, bY-1+(bH+2)*(1-hpR)); o.HBar.Visible=true
                else o.HBar.Visible=false; o.HBarBG.Visible=false end

                -- Name
                if Cfg.ESP.Name then
                    o.Name.Text=p.DisplayName; o.Name.Color=eCol
                    o.Name.Position=Vector2.new(headPos.X, headPos.Y-18); o.Name.Visible=true
                else o.Name.Visible=false end

                -- Distance
                if Cfg.ESP.Distance then
                    o.Dist.Text=string.format("[%.0fm]", GetDist(p)/6.5)
                    o.Dist.Position=Vector2.new(headPos.X, footPos.Y+2); o.Dist.Visible=true
                else o.Dist.Visible=false end

                -- Tracer
                if Cfg.ESP.Tracer then
                    o.Tracer.From=Vector2.new(center.X,vp.Y); o.Tracer.To=Vector2.new(footPos.X,footPos.Y)
                    o.Tracer.Color=eCol; o.Tracer.Visible=true
                else o.Tracer.Visible=false end

                -- Skeleton
                if Cfg.ESP.Skeleton then DrawSkeleton(o, char, Cfg.ESP.SkelColor)
                else for _, l in ipairs(o.Skel or {}) do l.Visible=false end end
            end)
        end

        -- Radar
        pcall(function()
            if Cfg.Radar.Enabled then
                local rs = Cfg.Radar.Size
                local rx = 20
                local ry = vp.Y - 20 - rs
                RadarBG.Size=Vector2.new(rs,rs); RadarBG.Position=Vector2.new(rx,ry); RadarBG.Visible=true
                RadarBorder.Size=Vector2.new(rs,rs); RadarBorder.Position=Vector2.new(rx,ry); RadarBorder.Visible=true
                RadarLabel.Position=Vector2.new(rx+rs/2, ry+rs+3); RadarLabel.Visible=true
                RadarSelf.Position=Vector2.new(rx+rs/2, ry+rs/2); RadarSelf.Visible=true

                local lc = LP.Character
                local lr = lc and GetRoot(lc)
                local lCF = lr and lr.CFrame or CFrame.new()

                for _, rd in ipairs(RadarDots) do
                    pcall(function()
                        local pp = rd.player; local dot = rd.dot
                        if not IsAlive(pp) then dot.Visible=false; return end
                        local c2 = pp.Character
                        local r2 = c2 and GetRoot(c2)
                        if not r2 then dot.Visible=false; return end
                        local rel = lCF:PointToObjectSpace(r2.Position)
                        local nx = rel.X/Cfg.Radar.Range; local nz = rel.Z/Cfg.Radar.Range
                        if math.abs(nx)>1 or math.abs(nz)>1 then dot.Visible=false; return end
                        dot.Position=Vector2.new(rx+rs/2+nx*(rs/2)*Cfg.Radar.Scale, ry+rs/2-nz*(rs/2)*Cfg.Radar.Scale)
                        dot.Color=IsSameTeam(pp) and Cfg.ESP.TeamColor or Color3.fromRGB(255,55,55)
                        dot.Visible=true
                    end)
                end
            else
                RadarBG.Visible=false; RadarBorder.Visible=false
                RadarSelf.Visible=false; RadarLabel.Visible=false
                for _, rd in ipairs(RadarDots) do pcall(function() rd.dot.Visible=false end) end
            end
        end)
    end)
end)

-- ════════════════════════════════════════════════════════════════
-- GUI — MOR/SİYAH ACCORDION MENÜ
-- ════════════════════════════════════════════════════════════════
local PURPLE  = Color3.fromRGB(140, 50, 255)
local PURPLE2 = Color3.fromRGB(90, 25, 185)
local DARK    = Color3.fromRGB(9, 7, 16)
local DARK2   = Color3.fromRGB(16, 12, 28)
local DARK3   = Color3.fromRGB(22, 17, 38)
local TEXT    = Color3.fromRGB(225, 215, 255)
local TEXTDIM = Color3.fromRGB(145, 125, 195)

local SG = Instance.new("ScreenGui")
SG.Name="BSUltraV4"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent=game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent=LP.PlayerGui end

local MF = Instance.new("Frame")
MF.Size=UDim2.new(0,285,0,540); MF.Position=UDim2.new(0,12,0.5,-270)
MF.BackgroundColor3=DARK; MF.BorderSizePixel=0; MF.Active=true; MF.Draggable=true
MF.Visible=false; MF.ClipsDescendants=false; MF.Parent=SG
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,12)
local mfS=Instance.new("UIStroke",MF); mfS.Color=PURPLE; mfS.Thickness=1.8

-- Glow shadow
local Glow=Instance.new("ImageLabel")
Glow.Size=UDim2.new(1,40,1,40); Glow.Position=UDim2.new(0,-20,0,-20)
Glow.BackgroundTransparency=1; Glow.Image="rbxassetid://1316045217"
Glow.ImageColor3=PURPLE2; Glow.ImageTransparency=0.55
Glow.ScaleType=Enum.ScaleType.Slice; Glow.SliceCenter=Rect.new(10,10,118,118); Glow.ZIndex=0; Glow.Parent=MF

-- Header
local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,50); Header.BackgroundColor3=DARK2; Header.BorderSizePixel=0; Header.Parent=MF
Instance.new("UICorner",Header).CornerRadius=UDim.new(0,12)
Instance.new("Frame",Header).Size=UDim2.new(1,0,0.5,0); Header:FindFirstChildOfClass("Frame").Position=UDim2.new(0,0,0.5,0); Header:FindFirstChildOfClass("Frame").BackgroundColor3=DARK2; Header:FindFirstChildOfClass("Frame").BorderSizePixel=0

local HAcc=Instance.new("Frame"); HAcc.Size=UDim2.new(0,4,0.65,0); HAcc.Position=UDim2.new(0,9,0.175,0)
HAcc.BackgroundColor3=PURPLE; HAcc.BorderSizePixel=0; HAcc.Parent=Header
Instance.new("UICorner",HAcc).CornerRadius=UDim.new(1,0)

local HT=Instance.new("TextLabel"); HT.Size=UDim2.new(1,-20,0,24); HT.Position=UDim2.new(0,20,0,6)
HT.BackgroundTransparency=1; HT.Text="BLOXSTRIKE ULTRA  v4.0"; HT.TextColor3=TEXT
HT.Font=Enum.Font.GothamBold; HT.TextSize=14; HT.TextXAlignment=Enum.TextXAlignment.Left; HT.Parent=Header

local HS=Instance.new("TextLabel"); HS.Size=UDim2.new(1,-20,0,14); HS.Position=UDim2.new(0,20,0,30)
HS.BackgroundTransparency=1; HS.Text="RightShift = Toggle  ·  Q = Aimbot"; HS.TextColor3=TEXTDIM
HS.Font=Enum.Font.Gotham; HS.TextSize=10; HS.TextXAlignment=Enum.TextXAlignment.Left; HS.Parent=Header

-- Scroll area
local Scroll=Instance.new("ScrollingFrame")
Scroll.Size=UDim2.new(1,-10,1,-58); Scroll.Position=UDim2.new(0,5,0,54)
Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3; Scroll.ScrollBarImageColor3=PURPLE
Scroll.CanvasSize=UDim2.new(0,0,0,0); Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; Scroll.Parent=MF

local SList=Instance.new("UIListLayout"); SList.Parent=Scroll; SList.SortOrder=Enum.SortOrder.LayoutOrder; SList.Padding=UDim.new(0,5)
local SPad=Instance.new("UIPadding"); SPad.PaddingLeft=UDim.new(0,2); SPad.PaddingRight=UDim.new(0,2); SPad.PaddingTop=UDim.new(0,4); SPad.PaddingBottom=UDim.new(0,8); SPad.Parent=Scroll

-- ── HELPERS ────────────────────────────────────────────────────
local secOrder = 0
local function MakeSection(title, emoji)
    secOrder = secOrder + 1
    local sec=Instance.new("Frame")
    sec.Size=UDim2.new(1,-4,0,40); sec.BackgroundColor3=DARK3; sec.BorderSizePixel=0
    sec.LayoutOrder=secOrder; sec.AutomaticSize=Enum.AutomaticSize.Y; sec.ClipsDescendants=true; sec.Parent=Scroll
    Instance.new("UICorner",sec).CornerRadius=UDim.new(0,9)
    local ss=Instance.new("UIStroke",sec); ss.Color=PURPLE2; ss.Thickness=1

    local hBtn=Instance.new("TextButton")
    hBtn.Size=UDim2.new(1,0,0,40); hBtn.BackgroundColor3=DARK2; hBtn.BorderSizePixel=0
    hBtn.Text=""; hBtn.AutoButtonColor=false; hBtn.ZIndex=2; hBtn.Parent=sec
    Instance.new("UICorner",hBtn).CornerRadius=UDim.new(0,9)

    local hAL=Instance.new("Frame"); hAL.Size=UDim2.new(0,3,0.55,0); hAL.Position=UDim2.new(0,7,0.225,0)
    hAL.BackgroundColor3=PURPLE; hAL.BorderSizePixel=0; hAL.ZIndex=3; hAL.Parent=hBtn
    Instance.new("UICorner",hAL).CornerRadius=UDim.new(1,0)

    local hL=Instance.new("TextLabel"); hL.Size=UDim2.new(1,-45,1,0); hL.Position=UDim2.new(0,18,0,0)
    hL.BackgroundTransparency=1; hL.Text=emoji.."  "..title; hL.TextColor3=TEXT
    hL.Font=Enum.Font.GothamBold; hL.TextSize=12; hL.TextXAlignment=Enum.TextXAlignment.Left; hL.ZIndex=3; hL.Parent=hBtn

    local arrow=Instance.new("TextLabel"); arrow.Size=UDim2.new(0,26,0,26); arrow.Position=UDim2.new(1,-30,0.5,-13)
    arrow.BackgroundTransparency=1; arrow.Text="▾"; arrow.TextColor3=PURPLE
    arrow.Font=Enum.Font.GothamBold; arrow.TextSize=15; arrow.ZIndex=3; arrow.Parent=hBtn

    local content=Instance.new("Frame")
    content.Size=UDim2.new(1,0,0,0); content.Position=UDim2.new(0,0,0,40)
    content.BackgroundTransparency=1; content.BorderSizePixel=0
    content.AutomaticSize=Enum.AutomaticSize.Y; content.Visible=false; content.Parent=sec

    local cL2=Instance.new("UIListLayout"); cL2.Parent=content; cL2.Padding=UDim.new(0,4)
    local cP=Instance.new("UIPadding"); cP.PaddingLeft=UDim.new(0,7); cP.PaddingRight=UDim.new(0,7)
    cP.PaddingTop=UDim.new(0,5); cP.PaddingBottom=UDim.new(0,8); cP.Parent=content

    local open=false
    hBtn.MouseButton1Click:Connect(function()
        open=not open
        content.Visible=open
        sec.ClipsDescendants=not open
        TweenService:Create(arrow,TweenInfo.new(0.2),{Rotation=open and 180 or 0}):Play()
        TweenService:Create(hBtn,TweenInfo.new(0.15),{BackgroundColor3=open and DARK3 or DARK2}):Play()
    end)
    hBtn.MouseEnter:Connect(function() if not open then TweenService:Create(hBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(24,18,44)}):Play() end end)
    hBtn.MouseLeave:Connect(function() if not open then TweenService:Create(hBtn,TweenInfo.new(0.12),{BackgroundColor3=DARK2}):Play() end end)

    return content
end

local itemOrder = 0
local function MakeToggle(parent, label, default, onChange)
    itemOrder = itemOrder + 1
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=DARK; row.BorderSizePixel=0; row.LayoutOrder=itemOrder; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)

    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-65,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=TEXT
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row

    local state=default
    local track=Instance.new("Frame"); track.Size=UDim2.new(0,44,0,22); track.Position=UDim2.new(1,-52,0.5,-11)
    track.BackgroundColor3=state and PURPLE or Color3.fromRGB(38,28,58); track.BorderSizePixel=0; track.Parent=row
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,18,0,18); knob.BorderSizePixel=0
    knob.Position=UDim2.new(state and 1 or 0, state and -20 or 2, 0.5,-9)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=row
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(track,TweenInfo.new(0.18),{BackgroundColor3=state and PURPLE or Color3.fromRGB(38,28,58)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.18),{Position=UDim2.new(state and 1 or 0, state and -20 or 2, 0.5,-9)}):Play()
        onChange(state)
    end)
end

local function MakeButton(parent, label, onClick)
    itemOrder = itemOrder + 1
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,30); btn.LayoutOrder=itemOrder
    btn.BackgroundColor3=PURPLE2; btn.BorderSizePixel=0; btn.Text=label
    btn.TextColor3=TEXT; btn.Font=Enum.Font.GothamBold; btn.TextSize=11; btn.Parent=parent
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=PURPLE}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=PURPLE2}):Play() end)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.06),{BackgroundColor3=Color3.fromRGB(190,110,255)}):Play()
        task.delay(0.15,function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=PURPLE2}):Play() end)
        onClick()
    end)
end

local function MakeDivider(parent, text)
    itemOrder = itemOrder + 1
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,0,18); lbl.LayoutOrder=itemOrder
    lbl.BackgroundTransparency=1; lbl.Text="── "..text.." ──"; lbl.TextColor3=TEXTDIM
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Center; lbl.Parent=parent
end

-- ════════════════════════════════════════════════════════════════
-- BÖLÜMLER
-- ════════════════════════════════════════════════════════════════
local SAim  = MakeSection("Aimbot","🎯")
MakeToggle(SAim,"Aimbot Aktif",Cfg.Aimbot.Enabled,function(v) Cfg.Aimbot.Enabled=v end)
MakeToggle(SAim,"FOV Çemberi",Cfg.Aimbot.ShowFOV,function(v) Cfg.Aimbot.ShowFOV=v end)
MakeToggle(SAim,"Takım Kontrolü",Cfg.Aimbot.TeamCheck,function(v) Cfg.Aimbot.TeamCheck=v end)
MakeToggle(SAim,"Duvar Kontrolü",Cfg.Aimbot.WallCheck,function(v) Cfg.Aimbot.WallCheck=v end)
MakeToggle(SAim,"Velocity Predict",Cfg.Aimbot.PredictFactor>0,function(v) Cfg.Aimbot.PredictFactor=v and 0.07 or 0 end)
MakeToggle(SAim,"Head Aim",Cfg.Aimbot.Part=="Head",function(v) Cfg.Aimbot.Part=v and "Head" or "HumanoidRootPart" end)
MakeToggle(SAim,"No Recoil",Cfg.NoRecoil.Enabled,function(v) Cfg.NoRecoil.Enabled=v end)

local SEsp  = MakeSection("ESP","👁")
MakeToggle(SEsp,"ESP Aktif",Cfg.ESP.Enabled,function(v) Cfg.ESP.Enabled=v end)
MakeToggle(SEsp,"Box ESP",Cfg.ESP.Box,function(v) Cfg.ESP.Box=v end)
MakeToggle(SEsp,"Köşe Box (Corner)",Cfg.ESP.CornerBox,function(v) Cfg.ESP.CornerBox=v end)
MakeToggle(SEsp,"İsim",Cfg.ESP.Name,function(v) Cfg.ESP.Name=v end)
MakeToggle(SEsp,"Mesafe",Cfg.ESP.Distance,function(v) Cfg.ESP.Distance=v end)
MakeToggle(SEsp,"HP Bar",Cfg.ESP.HealthBar,function(v) Cfg.ESP.HealthBar=v end)
MakeToggle(SEsp,"Skeleton",Cfg.ESP.Skeleton,function(v) Cfg.ESP.Skeleton=v end)
MakeToggle(SEsp,"Tracer",Cfg.ESP.Tracer,function(v) Cfg.ESP.Tracer=v end)
MakeToggle(SEsp,"Takım Rengi Ayrımı",Cfg.ESP.TeamCheck,function(v) Cfg.ESP.TeamCheck=v end)

local SChams = MakeSection("Chams","💀")
MakeToggle(SChams,"Chams (Duvardan Gör)",Cfg.Chams.Enabled,function(v) Cfg.Chams.Enabled=v; RefreshChams() end)

local SVis  = MakeSection("Crosshair & Radar","🎮")
MakeToggle(SVis,"Custom Crosshair",Cfg.Crosshair.Enabled,function(v)
    Cfg.Crosshair.Enabled=v
    if not v then for _,l in ipairs(CHLines) do pcall(function() l.Visible=false end) end; pcall(function() CHDot.Visible=false end) end
end)
MakeToggle(SVis,"Crosshair Dot",Cfg.Crosshair.Dot,function(v) Cfg.Crosshair.Dot=v end)
MakeToggle(SVis,"Mini Radar",Cfg.Radar.Enabled,function(v)
    Cfg.Radar.Enabled=v
    if not v then pcall(function()
        RadarBG.Visible=false; RadarBorder.Visible=false; RadarSelf.Visible=false; RadarLabel.Visible=false
    end) end
end)

local SLight = MakeSection("Lighting & Ortam","🌍")
MakeDivider(SLight,"Işık Modu")
MakeButton(SLight,"☀️  Gündüz",function() ApplyLighting("Day") end)
MakeButton(SLight,"🌙  Gece",function() ApplyLighting("Night") end)
MakeButton(SLight,"🌅  Gün Batımı",function() ApplyLighting("Sunset") end)
MakeButton(SLight,"🌫️  Sisli",function() ApplyLighting("Fog") end)
MakeButton(SLight,"🟣  Neon Mor",function() ApplyLighting("Neon") end)
MakeButton(SLight,"🔄  Sıfırla",function() ApplyLighting("Normal") end)

local SRain  = MakeSection("Rainbow Mod","🌈")
MakeToggle(SRain,"Rainbow Silah",Cfg.Rainbow.WeaponEnabled,function(v)
    Cfg.Rainbow.WeaponEnabled=v
    if not v then pcall(function()
        local char=LP.Character; if not char then return end
        for _,t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then
                for _,pp in ipairs(t:GetDescendants()) do
                    if pp:IsA("BasePart") then pcall(function() pp.Color=Color3.fromRGB(163,162,165) end) end
                end
            end
        end
    end) end
end)
MakeToggle(SRain,"Rainbow Karakter",Cfg.Rainbow.CharEnabled,function(v)
    Cfg.Rainbow.CharEnabled=v
    if not v then ApplySkin() end
end)

local SSkin  = MakeSection("Skin Changer","🎨")
MakeToggle(SSkin,"Skin Changer",Cfg.SkinChanger.Enabled,function(v)
    Cfg.SkinChanger.Enabled=v; if v then ApplySkin() end
end)
MakeDivider(SSkin,"Presetler")
local skList = {{"TacticalBlack","⬛"},{"Ghost","👻"},{"Desert","🟡"},{"Purple","🟣"},{"Stealth","🖤"},{"Classic","🔵"}}
for _, sk in ipairs(skList) do
    MakeButton(SSkin, sk[2].."  "..sk[1], function()
        Cfg.SkinChanger.Preset=sk[1]; Cfg.SkinChanger.Enabled=true; Cfg.Rainbow.CharEnabled=false
        ApplySkin(sk[1])
    end)
end

-- ════════════════════════════════════════════════════════════════
-- TOGGLE KEY
-- ════════════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        MF.Visible = not MF.Visible
    end
end)

-- ════════════════════════════════════════════════════════════════
-- BİLDİRİM
-- ════════════════════════════════════════════════════════════════
local function Notify(msg, dur)
    pcall(function()
        local nf=Instance.new("Frame"); nf.Size=UDim2.new(0,290,0,46); nf.Position=UDim2.new(0.5,-145,0,-60)
        nf.BackgroundColor3=DARK2; nf.BorderSizePixel=0; nf.Parent=SG
        Instance.new("UICorner",nf).CornerRadius=UDim.new(0,10)
        local ns=Instance.new("UIStroke",nf); ns.Color=PURPLE; ns.Thickness=1.5
        local acc=Instance.new("Frame"); acc.Size=UDim2.new(0,3,0.65,0); acc.Position=UDim2.new(0,9,0.175,0)
        acc.BackgroundColor3=PURPLE; acc.BorderSizePixel=0; acc.Parent=nf
        Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
        local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,-20,1,0); nl.Position=UDim2.new(0,18,0,0)
        nl.BackgroundTransparency=1; nl.Text=msg; nl.TextColor3=TEXT
        nl.Font=Enum.Font.GothamBold; nl.TextSize=12; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=nf
        TweenService:Create(nf,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-145,0,14)}):Play()
        task.delay(dur or 3.5, function()
            TweenService:Create(nf,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-145,0,-65)}):Play()
            task.delay(0.35,function() pcall(function() nf:Destroy() end) end)
        end)
    end)
end

task.delay(1.5, function()
    Notify("⚡ BloxStrike Ultra v4.0  |  RightShift = Menü", 4)
    if not drawingOK then
        task.delay(4.5, function()
            Notify("⚠️  Drawing API yok — farklı executor dene!", 5)
        end)
    end
end)

print("[BloxStrikeUltra v4.0] Yüklendi | Drawing: "..(drawingOK and "✓" or "✗").." | RShift=Menü | Q=Aim")
