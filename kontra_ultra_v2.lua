-- ============================================================
--   KONTRA ULTRA SCRIPT v2.0
--   Aimbot | ESP | SkinChanger | Radar | Crosshair | NoRecoil
--   Executor: Synapse X / KRNL / Fluxus / Delta / Wave
--   Tuş: RightShift = Menü aç/kapat
-- ============================================================

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local Camera        = workspace.CurrentCamera
local LP            = Players.LocalPlayer
local Mouse         = LP:GetMouse()

-- ============================================================
-- CONFIG (tüm ayarlar burada)
-- ============================================================
local Cfg = {
    Aimbot = {
        Enabled    = true,
        Key        = Enum.KeyCode.Q,
        FOV        = 160,
        Smoothness = 0.13,   -- 0.05 snap | 0.35 smooth
        Part       = "Head", -- "Head" veya "HumanoidRootPart"
        TeamCheck  = true,
        WallCheck  = false,  -- true = duvarın arkasını hedeflemez
        ShowFOV    = true,
        FOVColor   = Color3.fromRGB(255, 80, 80),
        PredictFactor = 0.08, -- düşman hareketi tahmini (0 = kapalı)
    },
    ESP = {
        Enabled      = true,
        Box          = true,
        CornerBox    = false, -- true = köşe box (false = full box)
        Name         = true,
        Distance     = true,
        HealthBar    = true,
        Skeleton     = true,
        Tracer       = false,
        TeamCheck    = true,
        MaxDist      = 2000,
        BoxColor     = Color3.fromRGB(255, 55, 55),
        TeamColor    = Color3.fromRGB(55, 220, 100),
        SkeletonColor= Color3.fromRGB(255, 200, 60),
        TracerColor  = Color3.fromRGB(255, 255, 255),
        FilledBox    = false,
        FilledAlpha  = 0.07,
    },
    SkinChanger = {
        Enabled = true,
        Preset  = "TacticalBlack",
        -- Presetler: "TacticalBlack" | "Ghost" | "Desert" | "Classic" | "Custom"
        Custom  = {
            Head      = "Pastel brown",
            Torso     = "Really black",
            LeftArm   = "Really black",
            RightArm  = "Really black",
            LeftLeg   = "Really black",
            RightLeg  = "Really black",
        },
    },
    NoRecoil = {
        Enabled   = true,
        Strength  = 0.6, -- 0.0 - 1.0
    },
    Radar = {
        Enabled  = true,
        Size     = 160,
        Range    = 250, -- stud yarıçapı
        X        = 20,
        Y        = 20,
        Scale    = 0.7,
    },
    Crosshair = {
        Enabled  = true,
        Size     = 10,
        Gap      = 4,
        Thickness= 1.5,
        Color    = Color3.fromRGB(255, 255, 255),
        Dot      = true,
    },
}

-- ============================================================
-- SKIN PRESETS
-- ============================================================
local SkinPresets = {
    TacticalBlack = { Head="Pastel brown", Torso="Really black", LeftArm="Really black", RightArm="Really black", LeftLeg="Really black", RightLeg="Really black" },
    Ghost         = { Head="White", Torso="White", LeftArm="White", RightArm="White", LeftLeg="White", RightLeg="White" },
    Desert        = { Head="Pastel brown", Torso="Sand yellow", LeftArm="Sand yellow", RightArm="Sand yellow", LeftLeg="Sand yellow", RightLeg="Sand yellow" },
    Classic       = { Head="Pastel brown", Torso="Bright blue", LeftArm="Bright yellow", RightArm="Bright yellow", LeftLeg="Bright blue", RightLeg="Bright blue" },
}

-- ============================================================
-- YARDIMCI FONKSİYONLAR
-- ============================================================
local function IsAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function IsSameTeam(p)
    return p.Team ~= nil and p.Team == LP.Team
end

local function W2S(pos)
    local sp, onscreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), onscreen, sp.Z
end

local function GetDist(p)
    local c = p.Character
    local lc = LP.Character
    if not c or not lc then return math.huge end
    local r  = c:FindFirstChild("HumanoidRootPart")
    local lr = lc:FindFirstChild("HumanoidRootPart")
    if not r or not lr then return math.huge end
    return (r.Position - lr.Position).Magnitude
end

local function GetVelocity(p)
    local c = p.Character
    if not c then return Vector3.zero end
    local r = c:FindFirstChild("HumanoidRootPart")
    return r and r.AssemblyLinearVelocity or Vector3.zero
end

local function HasLOS(pos)
    if not Cfg.Aimbot.WallCheck then return true end
    local lc = LP.Character
    local lr = lc and lc:FindFirstChild("HumanoidRootPart")
    if not lr then return true end
    local origin = lr.Position
    local dir = (pos - origin).Unit * (pos - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LP.Character, workspace.CurrentCamera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, dir, params)
    return result == nil
end

local function GetSkinColors()
    local preset = SkinPresets[Cfg.SkinChanger.Preset]
    return preset or Cfg.SkinChanger.Custom
end

-- ============================================================
-- SKIN CHANGER
-- ============================================================
local function ApplySkin()
    if not Cfg.SkinChanger.Enabled then return end
    local char = LP.Character
    if not char then return end
    local colors = GetSkinColors()
    local map = {
        Head="Head", Torso="Torso",
        LeftArm="Left Arm", RightArm="Right Arm",
        LeftLeg="Left Leg", RightLeg="Right Leg",
        -- R15
        UpperTorso="Torso", LowerTorso="Torso",
        LeftUpperArm="LeftArm", RightUpperArm="RightArm",
        LeftLowerArm="LeftArm", RightLowerArm="RightArm",
        LeftHand="LeftArm", RightHand="RightArm",
        LeftUpperLeg="LeftLeg", RightUpperLeg="RightLeg",
        LeftLowerLeg="LeftLeg", RightLowerLeg="RightLeg",
        LeftFoot="LeftLeg", RightFoot="RightLeg",
    }
    for partName, colorKey in pairs(map) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            local colorName = colors[colorKey] or colors[partName]
            if colorName then
                pcall(function() part.BrickColor = BrickColor.new(colorName) end)
            end
        end
    end
end

LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    ApplySkin()
end)
task.spawn(function() task.wait(1) ApplySkin() end)

-- ============================================================
-- DRAWING OBJECTS SETUP
-- ============================================================

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible  = false
fovCircle.Radius   = Cfg.Aimbot.FOV
fovCircle.Thickness= 1.5
fovCircle.Color    = Cfg.Aimbot.FOVColor
fovCircle.Filled   = false
fovCircle.NumSides = 80

-- Crosshair lines: left, right, top, bottom + dot
local CHLines = {}
for i = 1, 4 do
    local l = Drawing.new("Line")
    l.Visible   = false
    l.Thickness = Cfg.Crosshair.Thickness
    l.Color     = Cfg.Crosshair.Color
    table.insert(CHLines, l)
end
local CHDot = Drawing.new("Circle")
CHDot.Visible   = false
CHDot.Radius    = 1.5
CHDot.Filled    = true
CHDot.Color     = Cfg.Crosshair.Color
CHDot.NumSides  = 8

-- Radar background
local RadarBG    = Drawing.new("Square")
RadarBG.Visible  = false
RadarBG.Filled   = true
RadarBG.Color    = Color3.fromRGB(10, 10, 10)
RadarBG.Transparency = 0.45

local RadarBorder = Drawing.new("Square")
RadarBorder.Visible   = false
RadarBorder.Filled    = false
RadarBorder.Color     = Color3.fromRGB(180, 30, 30)
RadarBorder.Thickness = 1.5

local RadarSelf = Drawing.new("Circle")
RadarSelf.Visible  = false
RadarSelf.Filled   = true
RadarSelf.Color    = Color3.fromRGB(80, 200, 255)
RadarSelf.Radius   = 4
RadarSelf.NumSides = 8

local RadarDots = {} -- table of {dot, player}

-- ESP objects table
local ESPObj = {}

local function NewESP(player)
    local o = {}

    -- Filled box (alpha)
    o.BoxFill = Drawing.new("Square")
    o.BoxFill.Visible = false
    o.BoxFill.Filled  = true
    o.BoxFill.Transparency = Cfg.ESP.FilledAlpha
    o.BoxFill.Color   = Cfg.ESP.BoxColor

    -- Box outline (shadow)
    o.BoxShadow = Drawing.new("Square")
    o.BoxShadow.Visible   = false
    o.BoxShadow.Filled    = false
    o.BoxShadow.Thickness = 3
    o.BoxShadow.Color     = Color3.fromRGB(0,0,0)

    -- Main box
    o.Box = Drawing.new("Square")
    o.Box.Visible   = false
    o.Box.Filled    = false
    o.Box.Thickness = 1.5

    -- Corner lines (8 lines for corner box style)
    o.Corners = {}
    for i = 1, 8 do
        local l = Drawing.new("Line")
        l.Visible   = false
        l.Thickness = 1.8
        table.insert(o.Corners, l)
    end

    -- Name
    o.Name = Drawing.new("Text")
    o.Name.Visible   = false
    o.Name.Size      = 13
    o.Name.Center    = true
    o.Name.Outline   = true
    o.Name.Font      = Drawing.Fonts.Plex

    -- Distance
    o.Dist = Drawing.new("Text")
    o.Dist.Visible   = false
    o.Dist.Size      = 11
    o.Dist.Center    = true
    o.Dist.Outline   = true
    o.Dist.Color     = Color3.fromRGB(200, 200, 200)
    o.Dist.Font      = Drawing.Fonts.Plex

    -- HP bar BG
    o.HBarBG = Drawing.new("Square")
    o.HBarBG.Visible = false
    o.HBarBG.Filled  = true
    o.HBarBG.Color   = Color3.fromRGB(20, 20, 20)

    -- HP bar fill
    o.HBar = Drawing.new("Square")
    o.HBar.Visible = false
    o.HBar.Filled  = true

    -- Tracer
    o.Tracer = Drawing.new("Line")
    o.Tracer.Visible   = false
    o.Tracer.Thickness = 1

    -- Skeleton lines (head-torso, torso-arms, torso-legs)
    o.Skel = {}
    for i = 1, 6 do
        local l = Drawing.new("Line")
        l.Visible   = false
        l.Thickness = 1
        l.Color     = Cfg.ESP.SkeletonColor
        table.insert(o.Skel, l)
    end

    ESPObj[player] = o
end

local function RemoveESP(player)
    local o = ESPObj[player]
    if not o then return end
    for _, v in pairs(o) do
        if type(v) == "table" then
            for _, l in pairs(v) do pcall(function() l:Remove() end) end
        else
            pcall(function() v:Remove() end)
        end
    end
    ESPObj[player] = nil
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then NewESP(p) end
end
Players.PlayerAdded:Connect(function(p) NewESP(p) end)
Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

-- Radar dots setup
local function RefreshRadarDots()
    for _, rd in pairs(RadarDots) do pcall(function() rd.dot:Remove() end) end
    RadarDots = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local d = Drawing.new("Circle")
            d.Visible   = false
            d.Filled    = true
            d.Radius    = 4
            d.NumSides  = 8
            table.insert(RadarDots, {dot=d, player=p})
        end
    end
end
RefreshRadarDots()
Players.PlayerAdded:Connect(function() task.wait(0.5) RefreshRadarDots() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) RefreshRadarDots() end)

-- ============================================================
-- CORNER BOX HELPER
-- ============================================================
local function DrawCornerBox(o, x, y, w, h, color)
    local cLen = math.min(w, h) * 0.25
    -- 4 köşe × 2 çizgi = 8 çizgi
    -- TL
    o.Corners[1].From = Vector2.new(x, y);         o.Corners[1].To = Vector2.new(x+cLen, y)
    o.Corners[2].From = Vector2.new(x, y);         o.Corners[2].To = Vector2.new(x, y+cLen)
    -- TR
    o.Corners[3].From = Vector2.new(x+w, y);       o.Corners[3].To = Vector2.new(x+w-cLen, y)
    o.Corners[4].From = Vector2.new(x+w, y);       o.Corners[4].To = Vector2.new(x+w, y+cLen)
    -- BL
    o.Corners[5].From = Vector2.new(x, y+h);       o.Corners[5].To = Vector2.new(x+cLen, y+h)
    o.Corners[6].From = Vector2.new(x, y+h);       o.Corners[6].To = Vector2.new(x, y+h-cLen)
    -- BR
    o.Corners[7].From = Vector2.new(x+w, y+h);     o.Corners[7].To = Vector2.new(x+w-cLen, y+h)
    o.Corners[8].From = Vector2.new(x+w, y+h);     o.Corners[8].To = Vector2.new(x+w, y+h-cLen)

    for _, l in ipairs(o.Corners) do
        l.Color   = color
        l.Visible = true
    end
end

local function HideCorners(o)
    for _, l in ipairs(o.Corners) do l.Visible = false end
end

-- ============================================================
-- SKELETON HELPER
-- ============================================================
local SkelPairs = {
    {"Head","UpperTorso"},    {"Head","Torso"},
    {"UpperTorso","RightUpperArm"}, {"Torso","Right Arm"},
    {"UpperTorso","LeftUpperArm"},  {"Torso","Left Arm"},
}

local function DrawSkeleton(o, char, color)
    local idx = 1
    -- basit yaklaşım: head -> torso -> iki kol -> iki bacak
    local parts = {
        char:FindFirstChild("Head"),
        char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
        char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
        char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
        char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
        char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
    }
    local torso = parts[2]
    if not torso then
        for _, l in ipairs(o.Skel) do l.Visible = false end
        return
    end

    local connections = {
        {parts[1], parts[2]},  -- head -> torso
        {parts[2], parts[3]},  -- torso -> right arm
        {parts[2], parts[4]},  -- torso -> left arm
        {parts[2], parts[5]},  -- torso -> right leg
        {parts[2], parts[6]},  -- torso -> left leg
    }

    for i, conn in ipairs(connections) do
        local a, b = conn[1], conn[2]
        local sl = o.Skel[i]
        if a and b and sl then
            local pa, aOn = W2S(a.Position)
            local pb, bOn = W2S(b.Position)
            if aOn or bOn then
                sl.From    = pa
                sl.To      = pb
                sl.Color   = color
                sl.Visible = true
            else
                sl.Visible = false
            end
        elseif sl then
            sl.Visible = false
        end
    end
    -- 6. çizgiyi kapat
    if o.Skel[6] then o.Skel[6].Visible = false end
end

-- ============================================================
-- AIMBOT: En yakın hedef
-- ============================================================
local function GetTarget()
    local best    = nil
    local bestDst = Cfg.Aimbot.FOV
    local center  = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if Cfg.Aimbot.TeamCheck and IsSameTeam(p) then continue end
        if not IsAlive(p) then continue end

        local char = p.Character
        local part = char and char:FindFirstChild(Cfg.Aimbot.Part)
        if not part then continue end

        local aimPos = part.Position
        -- Velocity prediction
        if Cfg.Aimbot.PredictFactor > 0 then
            local vel = GetVelocity(p)
            aimPos = aimPos + vel * Cfg.Aimbot.PredictFactor
        end

        if Cfg.Aimbot.WallCheck and not HasLOS(aimPos) then continue end

        local sp, onScreen = W2S(aimPos)
        if not onScreen then continue end

        local d = (sp - center).Magnitude
        if d < bestDst then
            bestDst = d
            best = {player=p, pos=aimPos}
        end
    end

    return best
end

-- ============================================================
-- NO RECOIL (kamera stabilizatörü)
-- ============================================================
local lastCamCF = Camera.CFrame
local function ApplyNoRecoil()
    if not Cfg.NoRecoil.Enabled then
        lastCamCF = Camera.CFrame
        return
    end
    local cur = Camera.CFrame
    -- pitch (yukarı/aşağı) recoil'i azalt
    local lastPitch = math.asin(lastCamCF.LookVector.Y)
    local curPitch  = math.asin(cur.LookVector.Y)
    local delta     = curPitch - lastPitch
    if delta > 0.002 then -- yukarı giden recoil
        local suppress = CFrame.Angles(-delta * Cfg.NoRecoil.Strength, 0, 0)
        Camera.CFrame = cur * suppress
    end
    lastCamCF = Camera.CFrame
end

-- ============================================================
-- MAIN RENDER LOOP
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    local vp     = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)

    -- ── FOV Circle ──
    fovCircle.Position = center
    fovCircle.Visible  = Cfg.Aimbot.Enabled and Cfg.Aimbot.ShowFOV
    fovCircle.Radius   = Cfg.Aimbot.FOV
    fovCircle.Color    = Cfg.Aimbot.FOVColor

    -- ── Crosshair ──
    if Cfg.Crosshair.Enabled then
        local s = Cfg.Crosshair.Size
        local g = Cfg.Crosshair.Gap
        local t = Cfg.Crosshair.Thickness
        local c = Cfg.Crosshair.Color
        -- Left
        CHLines[1].From = Vector2.new(center.X-s-g, center.Y); CHLines[1].To = Vector2.new(center.X-g, center.Y)
        -- Right
        CHLines[2].From = Vector2.new(center.X+g, center.Y);   CHLines[2].To = Vector2.new(center.X+s+g, center.Y)
        -- Top
        CHLines[3].From = Vector2.new(center.X, center.Y-s-g); CHLines[3].To = Vector2.new(center.X, center.Y-g)
        -- Bottom
        CHLines[4].From = Vector2.new(center.X, center.Y+g);   CHLines[4].To = Vector2.new(center.X, center.Y+s+g)
        for _, l in ipairs(CHLines) do
            l.Color     = c
            l.Thickness = t
            l.Visible   = true
        end
        CHDot.Position = center
        CHDot.Color    = c
        CHDot.Visible  = Cfg.Crosshair.Dot
    else
        for _, l in ipairs(CHLines) do l.Visible = false end
        CHDot.Visible = false
    end

    -- ── Aimbot ──
    if Cfg.Aimbot.Enabled and UIS:IsKeyDown(Cfg.Aimbot.Key) then
        local target = GetTarget()
        if target then
            local cur  = Camera.CFrame
            local goal = CFrame.lookAt(cur.Position, target.pos)
            Camera.CFrame = cur:Lerp(goal, Cfg.Aimbot.Smoothness)
        end
    end

    -- ── No Recoil ──
    ApplyNoRecoil()

    -- ── ESP ──
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local o = ESPObj[p]
        if not o then continue end

        local dist  = GetDist(p)
        local show  = Cfg.ESP.Enabled and IsAlive(p) and dist <= Cfg.ESP.MaxDist
        if Cfg.ESP.TeamCheck and IsSameTeam(p) then show = false end

        local hideAll = function()
            o.Box.Visible = false; o.BoxShadow.Visible = false; o.BoxFill.Visible = false
            o.Name.Visible = false; o.Dist.Visible = false
            o.HBar.Visible = false; o.HBarBG.Visible = false
            o.Tracer.Visible = false
            HideCorners(o)
            for _, l in ipairs(o.Skel) do l.Visible = false end
        end

        if not show then hideAll(); continue end

        local char = p.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        if not root or not head then hideAll(); continue end

        local headPos, hOn = W2S(head.Position + Vector3.new(0, 0.75, 0))
        local footPos, fOn = W2S(root.Position - Vector3.new(0, 3.1, 0))
        if not hOn and not fOn then hideAll(); continue end

        local hum     = char:FindFirstChildOfClass("Humanoid")
        local hpRatio = hum and math.clamp(hum.Health / math.max(hum.MaxHealth,1), 0, 1) or 0

        local bH   = math.abs(footPos.Y - headPos.Y)
        local bW   = bH * 0.52
        local bX   = headPos.X - bW/2
        local bY   = headPos.Y
        local eCol = IsSameTeam(p) and Cfg.ESP.TeamColor or Cfg.ESP.BoxColor

        -- ── Box ──
        if Cfg.ESP.Box then
            o.BoxShadow.Size     = Vector2.new(bW+3, bH+3)
            o.BoxShadow.Position = Vector2.new(bX-1.5, bY-1.5)
            o.BoxShadow.Visible  = not Cfg.ESP.CornerBox

            if Cfg.ESP.FilledBox then
                o.BoxFill.Size     = Vector2.new(bW, bH)
                o.BoxFill.Position = Vector2.new(bX, bY)
                o.BoxFill.Color    = eCol
                o.BoxFill.Visible  = not Cfg.ESP.CornerBox
            else
                o.BoxFill.Visible = false
            end

            if Cfg.ESP.CornerBox then
                o.Box.Visible = false
                o.BoxShadow.Visible = false
                DrawCornerBox(o, bX, bY, bW, bH, eCol)
            else
                HideCorners(o)
                o.Box.Size     = Vector2.new(bW, bH)
                o.Box.Position = Vector2.new(bX, bY)
                o.Box.Color    = eCol
                o.Box.Visible  = true
            end
        else
            o.Box.Visible = false; o.BoxShadow.Visible = false; o.BoxFill.Visible = false
            HideCorners(o)
        end

        -- ── HP Bar ──
        if Cfg.ESP.HealthBar then
            local barX = bX - 8
            o.HBarBG.Size     = Vector2.new(4, bH + 2)
            o.HBarBG.Position = Vector2.new(barX, bY - 1)
            o.HBarBG.Visible  = true

            local g = math.floor(hpRatio * 255)
            local r = 255 - g
            o.HBar.Color    = Color3.fromRGB(r, g, 0)
            o.HBar.Size     = Vector2.new(4, (bH+2) * hpRatio)
            o.HBar.Position = Vector2.new(barX, bY - 1 + (bH+2)*(1-hpRatio))
            o.HBar.Visible  = true
        else
            o.HBar.Visible = false; o.HBarBG.Visible = false
        end

        -- ── Name ──
        if Cfg.ESP.Name then
            o.Name.Text     = p.DisplayName
            o.Name.Color    = eCol
            o.Name.Position = Vector2.new(headPos.X, headPos.Y - 18)
            o.Name.Visible  = true
        else
            o.Name.Visible = false
        end

        -- ── Distance ──
        if Cfg.ESP.Distance then
            o.Dist.Text     = string.format("[%.0fm]", dist / 6.5)
            o.Dist.Position = Vector2.new(headPos.X, footPos.Y + 2)
            o.Dist.Visible  = true
        else
            o.Dist.Visible = false
        end

        -- ── Tracer ──
        if Cfg.ESP.Tracer then
            o.Tracer.From    = Vector2.new(center.X, vp.Y)
            o.Tracer.To      = Vector2.new(footPos.X, footPos.Y)
            o.Tracer.Color   = eCol
            o.Tracer.Visible = true
        else
            o.Tracer.Visible = false
        end

        -- ── Skeleton ──
        if Cfg.ESP.Skeleton then
            DrawSkeleton(o, char, Cfg.ESP.SkeletonColor)
        else
            for _, l in ipairs(o.Skel) do l.Visible = false end
        end
    end

    -- ── RADAR ──
    if Cfg.Radar.Enabled then
        local rs  = Cfg.Radar.Size
        local rx  = Cfg.Radar.X
        local ry  = vp.Y - Cfg.Radar.Y - rs  -- sol alt köşe

        RadarBG.Size     = Vector2.new(rs, rs)
        RadarBG.Position = Vector2.new(rx, ry)
        RadarBG.Visible  = true

        RadarBorder.Size     = Vector2.new(rs, rs)
        RadarBorder.Position = Vector2.new(rx, ry)
        RadarBorder.Visible  = true

        RadarSelf.Position = Vector2.new(rx + rs/2, ry + rs/2)
        RadarSelf.Visible  = true

        local lc   = LP.Character
        local lRoot= lc and lc:FindFirstChild("HumanoidRootPart")
        local lCF  = lRoot and lRoot.CFrame or CFrame.new()

        for _, rd in ipairs(RadarDots) do
            local p   = rd.player
            local dot = rd.dot
            if not IsAlive(p) then dot.Visible = false; continue end
            local c    = p.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            if not root then dot.Visible = false; continue end

            local rel = lCF:PointToObjectSpace(root.Position)
            local nx  = rel.X / Cfg.Radar.Range
            local nz  = rel.Z / Cfg.Radar.Range

            if math.abs(nx) > 1 or math.abs(nz) > 1 then
                dot.Visible = false; continue
            end

            -- radar'da yönü düzelt (X=sağ, Z=ileri → radar Y yukarı)
            local dx = nx * (rs/2) * Cfg.Radar.Scale
            local dy = -nz * (rs/2) * Cfg.Radar.Scale
            dot.Position = Vector2.new(rx + rs/2 + dx, ry + rs/2 + dy)
            dot.Color    = IsSameTeam(p) and Cfg.ESP.TeamColor or Color3.fromRGB(255, 55, 55)
            dot.Visible  = true
        end
    else
        RadarBG.Visible = false; RadarBorder.Visible = false; RadarSelf.Visible = false
        for _, rd in ipairs(RadarDots) do rd.dot.Visible = false end
    end
end)

-- ============================================================
-- GUI MENU
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name           = "KontraUltraV2"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = LP.PlayerGui end

-- Ana çerçeve
local MainFrame = Instance.new("Frame")
MainFrame.Size            = UDim2.new(0, 270, 0, 390)
MainFrame.Position        = UDim2.new(0, 15, 0.5, -195)
MainFrame.BackgroundColor3= Color3.fromRGB(12, 12, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Active          = true
MainFrame.Draggable       = true
MainFrame.Visible         = false
MainFrame.ClipsDescendants= true
MainFrame.Parent          = SG

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local ms = Instance.new("UIStroke", MainFrame)
ms.Color     = Color3.fromRGB(200, 35, 35)
ms.Thickness = 1.5

-- Header
local Header = Instance.new("Frame")
Header.Size             = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3 = Color3.fromRGB(200, 35, 35)
Header.BorderSizePixel  = 0
Header.Parent           = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local HeaderPatch = Instance.new("Frame")
HeaderPatch.Size             = UDim2.new(1, 0, 0.5, 0)
HeaderPatch.Position         = UDim2.new(0, 0, 0.5, 0)
HeaderPatch.BackgroundColor3 = Color3.fromRGB(200, 35, 35)
HeaderPatch.BorderSizePixel  = 0
HeaderPatch.Parent           = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size              = UDim2.new(1, -10, 1, 0)
HeaderTitle.Position          = UDim2.new(0, 10, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text              = "⚡  KONTRA ULTRA v2.0"
HeaderTitle.TextColor3        = Color3.fromRGB(255, 255, 255)
HeaderTitle.Font               = Enum.Font.GothamBold
HeaderTitle.TextSize           = 13
HeaderTitle.TextXAlignment     = Enum.TextXAlignment.Left
HeaderTitle.Parent             = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size              = UDim2.new(1, -10, 0, 12)
SubTitle.Position          = UDim2.new(0, 10, 1, 2)
SubTitle.BackgroundTransparency = 1
SubTitle.Text              = "RightShift = Toggle  |  Q = Aimbot"
SubTitle.TextColor3        = Color3.fromRGB(180, 180, 180)
SubTitle.Font               = Enum.Font.Gotham
SubTitle.TextSize           = 10
SubTitle.TextXAlignment     = Enum.TextXAlignment.Left
SubTitle.Parent             = MainFrame

-- Sekme container
local TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(1, -20, 0, 28)
TabBar.Position         = UDim2.new(0, 10, 0, 52)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TabBar.BorderSizePixel  = 0
TabBar.Parent           = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 6)

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size             = UDim2.new(1, -10, 1, -95)
ContentFrame.Position         = UDim2.new(0, 5, 0, 88)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel  = 0
ContentFrame.ScrollBarThickness= 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 35, 35)
ContentFrame.CanvasSize       = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent           = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent          = ContentFrame
UIList.SortOrder       = Enum.SortOrder.LayoutOrder
UIList.Padding         = UDim.new(0, 3)

-- Sekme sistemi
local TabPages   = {}
local TabButtons = {}
local ActiveTab  = nil

local function MakeSectionLabel(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -10, 0, 22)
    lbl.BackgroundColor3  = Color3.fromRGB(200, 35, 35)
    lbl.BackgroundTransparency = 0.7
    lbl.Text              = "  " .. text
    lbl.TextColor3        = Color3.fromRGB(255, 180, 180)
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 11
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.BorderSizePixel   = 0
    lbl.LayoutOrder       = order
    lbl.Parent            = parent
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 4)
    return lbl
end

local function MakeToggle(parent, label, default, order, onChange)
    local row = Instance.new("Frame")
    row.Size              = UDim2.new(1, -10, 0, 28)
    row.BackgroundColor3  = Color3.fromRGB(20, 20, 28)
    row.BorderSizePixel   = 0
    row.LayoutOrder       = order
    row.Parent            = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(0.7, 0, 1, 0)
    lbl.Position          = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = Color3.fromRGB(210, 210, 210)
    lbl.Font              = Enum.Font.Gotham
    lbl.TextSize          = 12
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    local state = default
    local btn = Instance.new("TextButton")
    btn.Size              = UDim2.new(0, 48, 0, 20)
    btn.Position          = UDim2.new(1, -56, 0.5, -10)
    btn.BackgroundColor3  = state and Color3.fromRGB(40, 190, 65) or Color3.fromRGB(100, 22, 22)
    btn.Text              = state and "ON" or "OFF"
    btn.TextColor3        = Color3.fromRGB(255, 255, 255)
    btn.Font              = Enum.Font.GothamBold
    btn.TextSize          = 11
    btn.BorderSizePixel   = 0
    btn.Parent            = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        state = not state
        local on = state
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(40,190,65) or Color3.fromRGB(100,22,22)
        }):Play()
        btn.Text = on and "ON" or "OFF"
        onChange(on)
    end)

    return row
end

local function AddTab(name, emoji)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size              = UDim2.new(1/3, -2, 1, -4)
    tabBtn.Position          = UDim2.new((#TabButtons)/3, 2, 0, 2)
    tabBtn.BackgroundColor3  = Color3.fromRGB(30, 30, 42)
    tabBtn.Text              = emoji .. " " .. name
    tabBtn.TextColor3        = Color3.fromRGB(160, 160, 160)
    tabBtn.Font              = Enum.Font.GothamBold
    tabBtn.TextSize          = 11
    tabBtn.BorderSizePixel   = 0
    tabBtn.Parent            = TabBar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 5)

    local page = Instance.new("Frame")
    page.Size                = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible             = false
    page.Parent              = ContentFrame

    local pl = Instance.new("UIListLayout")
    pl.Parent    = page
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding   = UDim.new(0, 3)

    local pageName = name
    tabBtn.MouseButton1Click:Connect(function()
        for n, pg in pairs(TabPages) do
            pg.Visible = false
            TabButtons[n].BackgroundColor3 = Color3.fromRGB(30, 30, 42)
            TabButtons[n].TextColor3       = Color3.fromRGB(160, 160, 160)
        end
        page.Visible              = true
        tabBtn.BackgroundColor3   = Color3.fromRGB(200, 35, 35)
        tabBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
        ActiveTab = pageName
    end)

    TabPages[name]   = page
    TabButtons[name] = tabBtn
    return page
end

-- Sekmeleri oluştur
local AimPage  = AddTab("Aimbot",  "🎯")
local EspPage  = AddTab("ESP",     "👁")
local MiscPage = AddTab("Misc",    "⚙️")

-- İlk sekmeyi aktif et
do
    TabPages["Aimbot"].Visible           = true
    TabButtons["Aimbot"].BackgroundColor3 = Color3.fromRGB(200,35,35)
    TabButtons["Aimbot"].TextColor3       = Color3.fromRGB(255,255,255)
end

-- ── AIMBOT SAYFASI ──
MakeSectionLabel(AimPage, "AIMBOT AYARLARI", 1)
MakeToggle(AimPage, "Aimbot (Q tuşu)", Cfg.Aimbot.Enabled, 2, function(v) Cfg.Aimbot.Enabled = v end)
MakeToggle(AimPage, "FOV Çemberi", Cfg.Aimbot.ShowFOV, 3, function(v)
    Cfg.Aimbot.ShowFOV = v
    fovCircle.Visible  = v and Cfg.Aimbot.Enabled
end)
MakeToggle(AimPage, "Takım Kontrolü", Cfg.Aimbot.TeamCheck, 4, function(v) Cfg.Aimbot.TeamCheck = v end)
MakeToggle(AimPage, "Duvar Kontrolü (LOS)", Cfg.Aimbot.WallCheck, 5, function(v) Cfg.Aimbot.WallCheck = v end)
MakeToggle(AimPage, "Velocity Predict", Cfg.Aimbot.PredictFactor > 0, 6, function(v)
    Cfg.Aimbot.PredictFactor = v and 0.08 or 0
end)
MakeSectionLabel(AimPage, "NO RECOIL", 7)
MakeToggle(AimPage, "No Recoil", Cfg.NoRecoil.Enabled, 8, function(v) Cfg.NoRecoil.Enabled = v end)

-- ── ESP SAYFASI ──
MakeSectionLabel(EspPage, "ESP AYARLARI", 1)
MakeToggle(EspPage, "ESP", Cfg.ESP.Enabled, 2, function(v) Cfg.ESP.Enabled = v end)
MakeToggle(EspPage, "Box ESP", Cfg.ESP.Box, 3, function(v) Cfg.ESP.Box = v end)
MakeToggle(EspPage, "Köşe Box (Corner)", Cfg.ESP.CornerBox, 4, function(v) Cfg.ESP.CornerBox = v end)
MakeToggle(EspPage, "İsim", Cfg.ESP.Name, 5, function(v) Cfg.ESP.Name = v end)
MakeToggle(EspPage, "Mesafe", Cfg.ESP.Distance, 6, function(v) Cfg.ESP.Distance = v end)
MakeToggle(EspPage, "HP Bar", Cfg.ESP.HealthBar, 7, function(v) Cfg.ESP.HealthBar = v end)
MakeToggle(EspPage, "Skeleton", Cfg.ESP.Skeleton, 8, function(v) Cfg.ESP.Skeleton = v end)
MakeToggle(EspPage, "Tracer", Cfg.ESP.Tracer, 9, function(v) Cfg.ESP.Tracer = v end)
MakeToggle(EspPage, "Takım Rengi Ayrımı", Cfg.ESP.TeamCheck, 10, function(v) Cfg.ESP.TeamCheck = v end)

-- ── MISC SAYFASI ──
MakeSectionLabel(MiscPage, "CROSSHAIR", 1)
MakeToggle(MiscPage, "Custom Crosshair", Cfg.Crosshair.Enabled, 2, function(v)
    Cfg.Crosshair.Enabled = v
    if not v then
        for _, l in ipairs(CHLines) do l.Visible = false end
        CHDot.Visible = false
    end
end)
MakeToggle(MiscPage, "Crosshair Dot", Cfg.Crosshair.Dot, 3, function(v) Cfg.Crosshair.Dot = v end)
MakeSectionLabel(MiscPage, "RADAR", 4)
MakeToggle(MiscPage, "Mini Radar", Cfg.Radar.Enabled, 5, function(v)
    Cfg.Radar.Enabled = v
    if not v then
        RadarBG.Visible = false; RadarBorder.Visible = false; RadarSelf.Visible = false
        for _, rd in ipairs(RadarDots) do rd.dot.Visible = false end
    end
end)
MakeSectionLabel(MiscPage, "SKIN CHANGER", 6)
MakeToggle(MiscPage, "Skin Changer", Cfg.SkinChanger.Enabled, 7, function(v)
    Cfg.SkinChanger.Enabled = v
    if v then ApplySkin() end
end)

-- Preset butonları
local presets = {"TacticalBlack","Ghost","Desert","Classic"}
for i, preset in ipairs(presets) do
    local pb = Instance.new("TextButton")
    pb.Size              = UDim2.new(1, -10, 0, 24)
    pb.BackgroundColor3  = Color3.fromRGB(30, 30, 42)
    pb.Text              = "  › " .. preset
    pb.TextColor3        = Color3.fromRGB(180, 180, 180)
    pb.Font              = Enum.Font.Gotham
    pb.TextSize          = 11
    pb.BorderSizePixel   = 0
    pb.TextXAlignment    = Enum.TextXAlignment.Left
    pb.LayoutOrder       = 7 + i
    pb.Parent            = MiscPage
    Instance.new("UICorner", pb).CornerRadius = UDim.new(0, 4)

    pb.MouseButton1Click:Connect(function()
        Cfg.SkinChanger.Preset  = preset
        Cfg.SkinChanger.Enabled = true
        ApplySkin()
        -- geri bildirim
        local orig = pb.BackgroundColor3
        pb.BackgroundColor3 = Color3.fromRGB(200, 35, 35)
        task.delay(0.4, function() pb.BackgroundColor3 = orig end)
    end)
end

-- ── Toggle menü ──
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ── Başlangıç bildirimi ──
local function Notify(msg, dur)
    local nf = Instance.new("Frame")
    nf.Size             = UDim2.new(0, 260, 0, 40)
    nf.Position         = UDim2.new(0.5, -130, 0, -50)
    nf.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    nf.BorderSizePixel  = 0
    nf.Parent           = SG
    Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 8)
    local ns = Instance.new("UIStroke", nf)
    ns.Color = Color3.fromRGB(200,35,35); ns.Thickness = 1.2
    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1,0,1,0); nl.BackgroundTransparency = 1
    nl.Text = msg; nl.TextColor3 = Color3.fromRGB(255,255,255)
    nl.Font = Enum.Font.Gotham; nl.TextSize = 12; nl.Parent = nf
    TweenService:Create(nf, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position=UDim2.new(0.5,-130,0,15)}):Play()
    task.delay(dur or 3, function()
        TweenService:Create(nf, TweenInfo.new(0.3), {Position=UDim2.new(0.5,-130,0,-55)}):Play()
        task.delay(0.35, function() nf:Destroy() end)
    end)
end

task.delay(1.5, function()
    Notify("⚡ KONTRA ULTRA v2.0 hazır! | RShift = Menü", 4)
end)

print("[KontraUltra v2.0] Aktif | RightShift=Menu | Q=Aim")
