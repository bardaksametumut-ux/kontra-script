-- ╔══════════════════════════════════════════════════════════════╗
-- ║        BLOXSTRIKE ULTRA v5.0  |  Executor Bağımsız         ║
-- ║  ESP(Billboard) · Aimbot · Chams · Skin · Lighting         ║
-- ║  Tuş: RightShift = Menü  |  Keybind seçilebilir            ║
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
        FOV           = 200,
        Smoothness    = 0.12,
        Part          = "Head",
        TeamCheck     = true,
        WallCheck     = false,
        PredictFactor = 0.06,
        ShowFOV       = true,
    },
    ESP = {
        Enabled   = true,
        Name      = true,
        Distance  = true,
        HealthBar = true,
        TeamCheck = true,
        MaxDist   = 2500,
        BoxColor      = Color3.fromRGB(200, 80, 255),
        TeamColor     = Color3.fromRGB(80, 255, 140),
    },
    NoRecoil   = { Enabled = true, Strength = 0.55 },
    Radar      = { Enabled = true, Size = 160, Range = 350, Scale = 0.70 },
    SkinChanger= { Enabled = true, Preset = "TacticalBlack" },
    Rainbow    = { WeaponEnabled = false, CharEnabled = false, Speed = 2 },
    Chams      = {
        Enabled      = false,
        Color        = Color3.fromRGB(200, 60, 60),
        TeamColor    = Color3.fromRGB(60, 200, 120),
        Transparency = 0.45,
    },
}

-- ════════════════════════════════════════════════════════════════
-- KEYBIND LİSTESİ
-- ════════════════════════════════════════════════════════════════
local KeyNames = {
    Q="Q", E="E", R="R", F="F", G="G", T="T", Z="Z", X="X", C="C", V="V",
    LeftAlt="LAlt", RightAlt="RAlt", LeftControl="LCtrl", RightControl="RCtrl",
    LeftShift="LShift", CapsLock="CapsLock",
    F1="F1",F2="F2",F3="F3",F4="F4",F5="F5",F6="F6",F7="F7",F8="F8",
}
local KeyList = {}
for k,_ in pairs(KeyNames) do table.insert(KeyList, k) end
table.sort(KeyList)

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
local PartMap = {
    Head="Head", Torso="Torso",
    ["Left Arm"]="LA",  ["Right Arm"]="RA",  ["Left Leg"]="LL",  ["Right Leg"]="RL",
    UpperTorso="Torso", LowerTorso="Torso",
    LeftUpperArm="LA",  RightUpperArm="RA",  LeftLowerArm="LA",  RightLowerArm="RA",
    LeftHand="LA",      RightHand="RA",
    LeftUpperLeg="LL",  RightUpperLeg="RL",  LeftLowerLeg="LL",  RightLowerLeg="RL",
    LeftFoot="LL",      RightFoot="RL",
}

-- ════════════════════════════════════════════════════════════════
-- LIGHTING PRESETS
-- ════════════════════════════════════════════════════════════════
local LightPresets = {
    Normal  = {Brightness=1,   Ambient=Color3.fromRGB(70,70,70),    OutdoorAmbient=Color3.fromRGB(140,140,140), FogEnd=100000, FogColor=Color3.fromRGB(191,191,191), ClockTime=14},
    Night   = {Brightness=0,   Ambient=Color3.fromRGB(20,20,50),    OutdoorAmbient=Color3.fromRGB(10,10,40),   FogEnd=500,    FogColor=Color3.fromRGB(10,10,30),     ClockTime=0},
    Day     = {Brightness=2.2, Ambient=Color3.fromRGB(200,200,200), OutdoorAmbient=Color3.fromRGB(230,230,230),FogEnd=100000, FogColor=Color3.fromRGB(191,191,191),   ClockTime=12},
    Sunset  = {Brightness=1.2, Ambient=Color3.fromRGB(180,80,40),   OutdoorAmbient=Color3.fromRGB(200,100,50), FogEnd=700,    FogColor=Color3.fromRGB(200,120,60),    ClockTime=19},
    Fog     = {Brightness=0.7, Ambient=Color3.fromRGB(100,100,120), OutdoorAmbient=Color3.fromRGB(120,120,140),FogEnd=180,    FogColor=Color3.fromRGB(180,180,210),   ClockTime=10},
    Neon    = {Brightness=0.1, Ambient=Color3.fromRGB(50,0,80),     OutdoorAmbient=Color3.fromRGB(30,0,60),    FogEnd=400,    FogColor=Color3.fromRGB(80,0,130),      ClockTime=0},
}
local function ApplyLighting(name)
    local p = LightPresets[name]; if not p then return end
    pcall(function()
        TweenService:Create(Lighting, TweenInfo.new(1.5), {
            Brightness=p.Brightness, Ambient=p.Ambient, OutdoorAmbient=p.OutdoorAmbient,
            FogEnd=p.FogEnd, FogColor=p.FogColor, ClockTime=p.ClockTime,
        }):Play()
    end)
end

-- ════════════════════════════════════════════════════════════════
-- YARDIMCI
-- ════════════════════════════════════════════════════════════════
local function IsAlive(p)
    local ok, r = pcall(function()
        local c = p.Character; if not c then return false end
        local h = c:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end)
    return ok and r
end

local function IsSameTeam(p)
    local ok, r = pcall(function() return p.Team ~= nil and p.Team == LP.Team end)
    return ok and r
end

local function GetDist(p)
    local ok, d = pcall(function()
        local lc = LP.Character; local lr = lc and lc:FindFirstChild("HumanoidRootPart")
        local c  = p.Character;  local r  = c  and c:FindFirstChild("HumanoidRootPart")
        if not r or not lr then return math.huge end
        return (r.Position - lr.Position).Magnitude
    end)
    return ok and d or math.huge
end

local function GetPart(char, name)
    if not char then return nil end
    return char:FindFirstChild(name)
end

-- ════════════════════════════════════════════════════════════════
-- SKIN CHANGER
-- ════════════════════════════════════════════════════════════════
local function ApplySkin(presetName)
    pcall(function()
        if not Cfg.SkinChanger.Enabled then return end
        local char   = LP.Character; if not char then return end
        local colors = SkinPresets[presetName or Cfg.SkinChanger.Preset]; if not colors then return end
        for partName, colorKey in pairs(PartMap) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                local cn = colors[colorKey]
                if cn then pcall(function() part.BrickColor = BrickColor.new(cn) end) end
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
            local char = LP.Character; if not char then return end
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, pp in ipairs(tool:GetDescendants()) do
                        if pp:IsA("BasePart") then pcall(function() pp.Color = rc end) end
                    end
                end
            end
        end)
    end
    if Cfg.Rainbow.CharEnabled then
        pcall(function()
            local char = LP.Character; if not char then return end
            for _, pp in ipairs(char:GetDescendants()) do
                if pp:IsA("BasePart") and pp.Name ~= "HumanoidRootPart" then
                    pcall(function() pp.Color = rc end)
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════
-- CHAMS — Roblox Highlight (executor bağımsız, kesin çalışır)
-- ════════════════════════════════════════════════════════════════
local ChamHL = {}
local function SetChams(p, enable)
    pcall(function()
        if ChamHL[p] then ChamHL[p]:Destroy(); ChamHL[p] = nil end
        if not enable then return end
        local char = p.Character; if not char then return end
        local hl = Instance.new("Highlight")
        hl.FillColor          = IsSameTeam(p) and Cfg.Chams.TeamColor or Cfg.Chams.Color
        hl.OutlineColor       = Color3.fromRGB(255,255,255)
        hl.FillTransparency   = Cfg.Chams.Transparency
        hl.OutlineTransparency= 0.1
        hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee            = char
        hl.Parent             = char
        ChamHL[p]             = hl
    end)
end
local function RefreshChams()
    for p, hl in pairs(ChamHL) do pcall(function() hl:Destroy() end); ChamHL[p]=nil end
    if not Cfg.Chams.Enabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then SetChams(p, true) end
    end
end
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then
        p.CharacterAdded:Connect(function() task.wait(0.5); if Cfg.Chams.Enabled then SetChams(p,true) end end)
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5); if Cfg.Chams.Enabled then SetChams(p,true) end end)
end)
Players.PlayerRemoving:Connect(function(p)
    if ChamHL[p] then pcall(function() ChamHL[p]:Destroy() end); ChamHL[p]=nil end
end)

-- ════════════════════════════════════════════════════════════════
-- BILLBOARD ESP — Executor bağımsız, kesin çalışır
-- ════════════════════════════════════════════════════════════════
local ESPBoards = {}  -- [player] = {billboard, nameLabel, distLabel, hpBar, hpFill, hpBG, conn}

local function MakeBillboard(p)
    if p == LP then return end
    local function create(char)
        pcall(function()
            -- Eski temizle
            if ESPBoards[p] then
                pcall(function() ESPBoards[p].bb:Destroy() end)
                if ESPBoards[p].conn then ESPBoards[p].conn:Disconnect() end
                ESPBoards[p] = nil
            end

            local head = char:WaitForChild("Head", 5)
            local root = char:WaitForChild("HumanoidRootPart", 5)
            local hum  = char:WaitForChild("Humanoid", 5)
            if not head or not root or not hum then return end

            -- BillboardGui
            local bb = Instance.new("BillboardGui")
            bb.Name              = "_BSESP"
            bb.Adornee           = head
            bb.Size              = UDim2.new(0, 140, 0, 52)
            bb.StudsOffset       = Vector3.new(0, 2.8, 0)
            bb.AlwaysOnTop       = true
            bb.ResetOnSpawn      = false
            bb.LightInfluence    = 0
            bb.Parent            = head

            -- İsim
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name              = "NameL"
            nameLabel.Size              = UDim2.new(1,0,0,22)
            nameLabel.Position          = UDim2.new(0,0,0,0)
            nameLabel.BackgroundTransparency= 1
            nameLabel.Text              = p.DisplayName
            nameLabel.TextColor3        = Cfg.ESP.BoxColor
            nameLabel.TextStrokeTransparency= 0
            nameLabel.TextStrokeColor3  = Color3.fromRGB(0,0,0)
            nameLabel.Font              = Enum.Font.GothamBold
            nameLabel.TextSize          = 14
            nameLabel.ZIndex            = 5
            nameLabel.Parent            = bb

            -- Mesafe
            local distLabel = Instance.new("TextLabel")
            distLabel.Name              = "DistL"
            distLabel.Size              = UDim2.new(1,0,0,16)
            distLabel.Position          = UDim2.new(0,0,0,22)
            distLabel.BackgroundTransparency= 1
            distLabel.TextColor3        = Color3.fromRGB(200,200,200)
            distLabel.TextStrokeTransparency= 0
            distLabel.TextStrokeColor3  = Color3.fromRGB(0,0,0)
            distLabel.Font              = Enum.Font.Gotham
            distLabel.TextSize          = 11
            distLabel.ZIndex            = 5
            distLabel.Parent            = bb

            -- HP Bar arka plan
            local hpBG = Instance.new("Frame")
            hpBG.Name              = "HPBG"
            hpBG.Size              = UDim2.new(0.85, 0, 0, 5)
            hpBG.Position          = UDim2.new(0.075, 0, 1, -8)
            hpBG.BackgroundColor3  = Color3.fromRGB(20,20,20)
            hpBG.BorderSizePixel   = 0
            hpBG.ZIndex            = 5
            hpBG.Parent            = bb
            Instance.new("UICorner", hpBG).CornerRadius = UDim.new(1,0)

            -- HP Bar dolgu
            local hpFill = Instance.new("Frame")
            hpFill.Name             = "HPFill"
            hpFill.Size             = UDim2.new(1,0,1,0)
            hpFill.BackgroundColor3 = Color3.fromRGB(50,220,80)
            hpFill.BorderSizePixel  = 0
            hpFill.ZIndex           = 6
            hpFill.Parent           = hpBG
            Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1,0)

            local data = {bb=bb, name=nameLabel, dist=distLabel, hpFill=hpFill, hpBG=hpBG, conn=nil}
            ESPBoards[p] = data

            -- Güncelleme döngüsü
            data.conn = RunService.RenderStepped:Connect(function()
                pcall(function()
                    -- ESP aktif mi, karakter var mı
                    if not Cfg.ESP.Enabled or not char or not char.Parent then
                        bb.Enabled = false; return
                    end
                    if not IsAlive(p) then bb.Enabled = false; return end
                    if Cfg.ESP.TeamCheck and IsSameTeam(p) then bb.Enabled = false; return end

                    local dist = GetDist(p)
                    if dist > Cfg.ESP.MaxDist then bb.Enabled = false; return end

                    bb.Enabled = true

                    local eCol = IsSameTeam(p) and Cfg.ESP.TeamColor or Cfg.ESP.BoxColor

                    -- İsim
                    if Cfg.ESP.Name then
                        nameLabel.Visible = true
                        nameLabel.Text = p.DisplayName
                        nameLabel.TextColor3 = eCol
                    else
                        nameLabel.Visible = false
                    end

                    -- Mesafe
                    if Cfg.ESP.Distance then
                        distLabel.Visible = true
                        distLabel.Text = string.format("[%.0f m]", dist / 6.5)
                    else
                        distLabel.Visible = false
                    end

                    -- HP Bar
                    if Cfg.ESP.HealthBar then
                        hpBG.Visible = true
                        local hpR = math.clamp(hum.Health / math.max(hum.MaxHealth,1), 0, 1)
                        hpFill.Size = UDim2.new(hpR, 0, 1, 0)
                        local g = math.floor(hpR * 255)
                        local r = 255 - g
                        hpFill.BackgroundColor3 = Color3.fromRGB(r, g, 0)
                    else
                        hpBG.Visible = false
                    end
                end)
            end)

            -- Karakter silinince temizle
            char.AncestryChanged:Connect(function(_, par)
                if not par then
                    pcall(function() bb:Destroy() end)
                    if data.conn then data.conn:Disconnect() end
                    if ESPBoards[p] == data then ESPBoards[p] = nil end
                end
            end)
        end)
    end

    p.CharacterAdded:Connect(function(c) task.wait(0.3); create(c) end)
    if p.Character then task.spawn(function() task.wait(0.3); create(p.Character) end) end
end

for _, p in ipairs(Players:GetPlayers()) do MakeBillboard(p) end
Players.PlayerAdded:Connect(MakeBillboard)
Players.PlayerRemoving:Connect(function(p)
    pcall(function()
        if ESPBoards[p] then
            pcall(function() ESPBoards[p].bb:Destroy() end)
            if ESPBoards[p].conn then ESPBoards[p].conn:Disconnect() end
            ESPBoards[p] = nil
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════
-- AIMBOT
-- ════════════════════════════════════════════════════════════════
local function GetTarget()
    local best, bestD = nil, Cfg.Aimbot.FOV
    local vp     = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if Cfg.Aimbot.TeamCheck and IsSameTeam(p) then continue end
        if not IsAlive(p) then continue end

        pcall(function()
            local char = p.Character
            local part = GetPart(char, Cfg.Aimbot.Part)
                      or GetPart(char, "Head")
                      or GetPart(char, "HumanoidRootPart")
            if not part then return end

            local aimPos = part.Position
            if Cfg.Aimbot.PredictFactor > 0 then
                local r = GetPart(char, "HumanoidRootPart")
                if r then aimPos = aimPos + r.AssemblyLinearVelocity * Cfg.Aimbot.PredictFactor end
            end

            if Cfg.Aimbot.WallCheck then
                local lc = LP.Character
                local lr = lc and GetPart(lc,"HumanoidRootPart")
                if lr then
                    local params = RaycastParams.new()
                    params.FilterDescendantsInstances = {LP.Character, Camera}
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    local res = workspace:Raycast(lr.Position, aimPos - lr.Position, params)
                    if res then return end
                end
            end

            local sp, on = Camera:WorldToViewportPoint(aimPos)
            if not on then return end
            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
            if d < bestD then bestD=d; best={player=p, pos=aimPos} end
        end)
    end
    return best
end

-- ════════════════════════════════════════════════════════════════
-- FOV ÇEMBERİ — Drawing varsa çiz, yoksa geç
-- ════════════════════════════════════════════════════════════════
local fovOK = false
local fovCircle = nil
pcall(function()
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible=false; fovCircle.Radius=Cfg.Aimbot.FOV
    fovCircle.Thickness=1.5; fovCircle.Filled=false; fovCircle.NumSides=80
    fovCircle.Color=Color3.fromRGB(160,60,255)
    fovOK = true
end)

-- RADAR — Drawing varsa
local radarOK = false
local RadarBG, RadarBorder, RadarSelf, RadarLabel = nil,nil,nil,nil
local RadarDots = {}
pcall(function()
    RadarBG     = Drawing.new("Square"); RadarBG.Visible=false; RadarBG.Filled=true; RadarBG.Color=Color3.fromRGB(8,8,14); RadarBG.Transparency=0.4
    RadarBorder = Drawing.new("Square"); RadarBorder.Visible=false; RadarBorder.Filled=false; RadarBorder.Thickness=1.5; RadarBorder.Color=Color3.fromRGB(140,50,255)
    RadarLabel  = Drawing.new("Text");   RadarLabel.Visible=false; RadarLabel.Text="RADAR"; RadarLabel.Size=9; RadarLabel.Center=true; RadarLabel.Outline=true; RadarLabel.Color=Color3.fromRGB(140,50,255); RadarLabel.Font=Drawing.Fonts.Plex
    RadarSelf   = Drawing.new("Circle"); RadarSelf.Visible=false; RadarSelf.Filled=true; RadarSelf.Color=Color3.fromRGB(80,180,255); RadarSelf.Radius=4; RadarSelf.NumSides=8
    radarOK = true
end)

local function RefreshRadarDots()
    for _, rd in pairs(RadarDots) do pcall(function() rd.dot:Remove() end) end
    RadarDots = {}
    if not radarOK then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local d = Drawing.new("Circle"); d.Visible=false; d.Filled=true; d.Radius=4; d.NumSides=8
            table.insert(RadarDots, {dot=d, player=p})
        end
    end
end
if radarOK then RefreshRadarDots() end
Players.PlayerAdded:Connect(function() task.wait(1); if radarOK then RefreshRadarDots() end end)
Players.PlayerRemoving:Connect(function() task.wait(0.5); if radarOK then RefreshRadarDots() end end)

-- ════════════════════════════════════════════════════════════════
-- NO RECOIL
-- ════════════════════════════════════════════════════════════════
local lastCF = Camera.CFrame
local function ApplyNoRecoil()
    pcall(function()
        if not Cfg.NoRecoil.Enabled then lastCF=Camera.CFrame; return end
        local cur = Camera.CFrame
        local lp  = math.asin(math.clamp(lastCF.LookVector.Y,-1,1))
        local cp  = math.asin(math.clamp(cur.LookVector.Y,-1,1))
        if cp - lp > 0.002 then Camera.CFrame = cur * CFrame.Angles(-(cp-lp)*Cfg.NoRecoil.Strength,0,0) end
        lastCF = Camera.CFrame
    end)
end

-- ════════════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    pcall(function()
        local vp     = Camera.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)

        -- FOV çemberi
        if fovOK and fovCircle then
            fovCircle.Position = center
            fovCircle.Visible  = Cfg.Aimbot.Enabled and Cfg.Aimbot.ShowFOV
            fovCircle.Radius   = Cfg.Aimbot.FOV
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

        -- Radar
        if radarOK and Cfg.Radar.Enabled then
            local rs=Cfg.Radar.Size; local rx=20; local ry=vp.Y-20-rs
            RadarBG.Size=Vector2.new(rs,rs); RadarBG.Position=Vector2.new(rx,ry); RadarBG.Visible=true
            RadarBorder.Size=Vector2.new(rs,rs); RadarBorder.Position=Vector2.new(rx,ry); RadarBorder.Visible=true
            RadarLabel.Position=Vector2.new(rx+rs/2,ry+rs+3); RadarLabel.Visible=true
            RadarSelf.Position=Vector2.new(rx+rs/2,ry+rs/2); RadarSelf.Visible=true
            local lc=LP.Character; local lr=lc and GetPart(lc,"HumanoidRootPart")
            local lCF=lr and lr.CFrame or CFrame.new()
            for _, rd in ipairs(RadarDots) do
                pcall(function()
                    local pp=rd.player; local dot=rd.dot
                    if not IsAlive(pp) then dot.Visible=false; return end
                    local c2=pp.Character; local r2=c2 and GetPart(c2,"HumanoidRootPart")
                    if not r2 then dot.Visible=false; return end
                    local rel=lCF:PointToObjectSpace(r2.Position)
                    local nx=rel.X/Cfg.Radar.Range; local nz=rel.Z/Cfg.Radar.Range
                    if math.abs(nx)>1 or math.abs(nz)>1 then dot.Visible=false; return end
                    dot.Position=Vector2.new(rx+rs/2+nx*(rs/2)*Cfg.Radar.Scale, ry+rs/2-nz*(rs/2)*Cfg.Radar.Scale)
                    dot.Color=IsSameTeam(pp) and Cfg.ESP.TeamColor or Color3.fromRGB(255,55,55)
                    dot.Visible=true
                end)
            end
        elseif radarOK then
            if RadarBG then RadarBG.Visible=false; RadarBorder.Visible=false; RadarSelf.Visible=false; RadarLabel.Visible=false end
            for _, rd in ipairs(RadarDots) do pcall(function() rd.dot.Visible=false end) end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════
-- GUI — MOR/SİYAH ACCORDION + KEYBIND SEÇİCİ
-- ════════════════════════════════════════════════════════════════
local PURPLE  = Color3.fromRGB(140,50,255)
local PURPLE2 = Color3.fromRGB(90,25,185)
local DARK    = Color3.fromRGB(9,7,16)
local DARK2   = Color3.fromRGB(16,12,28)
local DARK3   = Color3.fromRGB(22,17,38)
local TEXT    = Color3.fromRGB(225,215,255)
local TEXTDIM = Color3.fromRGB(145,125,195)

local SG = Instance.new("ScreenGui")
SG.Name="BSUltraV5"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent=game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent=LP.PlayerGui end

local MF = Instance.new("Frame")
MF.Size=UDim2.new(0,285,0,520); MF.Position=UDim2.new(0,12,0.5,-260)
MF.BackgroundColor3=DARK; MF.BorderSizePixel=0; MF.Active=true; MF.Draggable=true
MF.Visible=false; MF.ClipsDescendants=false; MF.Parent=SG
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,12)
local mfS=Instance.new("UIStroke",MF); mfS.Color=PURPLE; mfS.Thickness=1.8

local Glow=Instance.new("ImageLabel")
Glow.Size=UDim2.new(1,40,1,40); Glow.Position=UDim2.new(0,-20,0,-20)
Glow.BackgroundTransparency=1; Glow.Image="rbxassetid://1316045217"
Glow.ImageColor3=PURPLE2; Glow.ImageTransparency=0.55
Glow.ScaleType=Enum.ScaleType.Slice; Glow.SliceCenter=Rect.new(10,10,118,118); Glow.ZIndex=0; Glow.Parent=MF

local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,50); Header.BackgroundColor3=DARK2; Header.BorderSizePixel=0; Header.Parent=MF
Instance.new("UICorner",Header).CornerRadius=UDim.new(0,12)

local HAcc=Instance.new("Frame"); HAcc.Size=UDim2.new(0,4,0.65,0); HAcc.Position=UDim2.new(0,9,0.175,0)
HAcc.BackgroundColor3=PURPLE; HAcc.BorderSizePixel=0; HAcc.Parent=Header
Instance.new("UICorner",HAcc).CornerRadius=UDim.new(1,0)

local HT=Instance.new("TextLabel"); HT.Size=UDim2.new(1,-20,0,24); HT.Position=UDim2.new(0,20,0,6)
HT.BackgroundTransparency=1; HT.Text="BLOXSTRIKE ULTRA  v5.0"; HT.TextColor3=TEXT
HT.Font=Enum.Font.GothamBold; HT.TextSize=14; HT.TextXAlignment=Enum.TextXAlignment.Left; HT.Parent=Header

local HS=Instance.new("TextLabel"); HS.Size=UDim2.new(1,-20,0,14); HS.Position=UDim2.new(0,20,0,30)
HS.BackgroundTransparency=1; HS.Text="RightShift = Toggle"; HS.TextColor3=TEXTDIM
HS.Font=Enum.Font.Gotham; HS.TextSize=10; HS.TextXAlignment=Enum.TextXAlignment.Left; HS.Parent=Header

local Scroll=Instance.new("ScrollingFrame")
Scroll.Size=UDim2.new(1,-10,1,-58); Scroll.Position=UDim2.new(0,5,0,54)
Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3; Scroll.ScrollBarImageColor3=PURPLE
Scroll.CanvasSize=UDim2.new(0,0,0,0); Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; Scroll.Parent=MF
local SL=Instance.new("UIListLayout"); SL.Parent=Scroll; SL.SortOrder=Enum.SortOrder.LayoutOrder; SL.Padding=UDim.new(0,5)
local SP=Instance.new("UIPadding"); SP.PaddingLeft=UDim.new(0,2); SP.PaddingRight=UDim.new(0,2); SP.PaddingTop=UDim.new(0,4); SP.PaddingBottom=UDim.new(0,8); SP.Parent=Scroll

local secOrd=0
local function MakeSection(title, emoji)
    secOrd=secOrd+1
    local sec=Instance.new("Frame")
    sec.Size=UDim2.new(1,-4,0,40); sec.BackgroundColor3=DARK3; sec.BorderSizePixel=0
    sec.LayoutOrder=secOrd; sec.AutomaticSize=Enum.AutomaticSize.Y; sec.ClipsDescendants=true; sec.Parent=Scroll
    Instance.new("UICorner",sec).CornerRadius=UDim.new(0,9)
    Instance.new("UIStroke",sec).Color=PURPLE2

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

    local cL=Instance.new("UIListLayout"); cL.Parent=content; cL.Padding=UDim.new(0,4)
    local cP=Instance.new("UIPadding"); cP.PaddingLeft=UDim.new(0,7); cP.PaddingRight=UDim.new(0,7)
    cP.PaddingTop=UDim.new(0,5); cP.PaddingBottom=UDim.new(0,8); cP.Parent=content

    local open=false
    hBtn.MouseButton1Click:Connect(function()
        open=not open; content.Visible=open; sec.ClipsDescendants=not open
        TweenService:Create(arrow,TweenInfo.new(0.2),{Rotation=open and 180 or 0}):Play()
        TweenService:Create(hBtn,TweenInfo.new(0.15),{BackgroundColor3=open and DARK3 or DARK2}):Play()
    end)
    hBtn.MouseEnter:Connect(function() if not open then TweenService:Create(hBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(24,18,44)}):Play() end end)
    hBtn.MouseLeave:Connect(function() if not open then TweenService:Create(hBtn,TweenInfo.new(0.12),{BackgroundColor3=DARK2}):Play() end end)
    return content
end

local itmOrd=0
local function MakeToggle(parent, label, default, onChange)
    itmOrd=itmOrd+1
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=DARK; row.BorderSizePixel=0; row.LayoutOrder=itmOrd; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-65,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=TEXT; lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
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
    itmOrd=itmOrd+1
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,30); btn.LayoutOrder=itmOrd
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
    return btn
end

local function MakeDivider(parent, text)
    itmOrd=itmOrd+1
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,0,18); lbl.LayoutOrder=itmOrd
    lbl.BackgroundTransparency=1; lbl.Text="── "..text.." ──"; lbl.TextColor3=TEXTDIM
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Center; lbl.Parent=parent
end

-- KEYBIND PICKER
local waitingForKey = false
local function MakeKeybind(parent, label, getCfg, setCfg)
    itmOrd=itmOrd+1
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=DARK; row.BorderSizePixel=0; row.LayoutOrder=itmOrd; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)

    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0.55,0,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=TEXT
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row

    local kBtn=Instance.new("TextButton"); kBtn.Size=UDim2.new(0,80,0,22); kBtn.Position=UDim2.new(1,-88,0.5,-11)
    kBtn.BackgroundColor3=PURPLE2; kBtn.BorderSizePixel=0; kBtn.Font=Enum.Font.GothamBold; kBtn.TextSize=11
    kBtn.TextColor3=TEXT; kBtn.Text="[ "..getCfg().Name.." ]"; kBtn.Parent=row
    Instance.new("UICorner",kBtn).CornerRadius=UDim.new(0,5)

    local listening=false
    kBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening=true; waitingForKey=true
        kBtn.Text="..."; kBtn.BackgroundColor3=Color3.fromRGB(200,100,30)
        local conn; conn=UIS.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                pcall(function() setCfg(inp.KeyCode) end)
                kBtn.Text="[ "..inp.KeyCode.Name.." ]"
                kBtn.BackgroundColor3=PURPLE2
                listening=false; waitingForKey=false
                conn:Disconnect()
            end
        end)
    end)
end

-- ═══════════════════════
-- BÖLÜMLER
-- ═══════════════════════
local SAim = MakeSection("Aimbot","🎯")
MakeToggle(SAim,"Aimbot Aktif",Cfg.Aimbot.Enabled,function(v) Cfg.Aimbot.Enabled=v end)
MakeToggle(SAim,"FOV Çemberi",Cfg.Aimbot.ShowFOV,function(v) Cfg.Aimbot.ShowFOV=v end)
MakeToggle(SAim,"Takım Kontrolü",Cfg.Aimbot.TeamCheck,function(v) Cfg.Aimbot.TeamCheck=v end)
MakeToggle(SAim,"Duvar Kontrolü",Cfg.Aimbot.WallCheck,function(v) Cfg.Aimbot.WallCheck=v end)
MakeToggle(SAim,"Velocity Predict",Cfg.Aimbot.PredictFactor>0,function(v) Cfg.Aimbot.PredictFactor=v and 0.06 or 0 end)
MakeToggle(SAim,"Head Aim",Cfg.Aimbot.Part=="Head",function(v) Cfg.Aimbot.Part=v and "Head" or "HumanoidRootPart" end)
MakeDivider(SAim,"Tuş Ayarları")
MakeKeybind(SAim,"Aim Tuşu",
    function() return Cfg.Aimbot.Key end,
    function(k) Cfg.Aimbot.Key=k end)
MakeToggle(SAim,"No Recoil",Cfg.NoRecoil.Enabled,function(v) Cfg.NoRecoil.Enabled=v end)

local SEsp = MakeSection("ESP","👁")
MakeToggle(SEsp,"ESP Aktif",Cfg.ESP.Enabled,function(v) Cfg.ESP.Enabled=v end)
MakeToggle(SEsp,"İsim",Cfg.ESP.Name,function(v) Cfg.ESP.Name=v end)
MakeToggle(SEsp,"Mesafe",Cfg.ESP.Distance,function(v) Cfg.ESP.Distance=v end)
MakeToggle(SEsp,"HP Bar",Cfg.ESP.HealthBar,function(v) Cfg.ESP.HealthBar=v end)
MakeToggle(SEsp,"Takım Rengi",Cfg.ESP.TeamCheck,function(v) Cfg.ESP.TeamCheck=v end)

local SChams = MakeSection("Chams","💀")
MakeToggle(SChams,"Chams (Duvardan Gör)",Cfg.Chams.Enabled,function(v) Cfg.Chams.Enabled=v; RefreshChams() end)

local SVis = MakeSection("Radar","📡")
MakeToggle(SVis,"Mini Radar",Cfg.Radar.Enabled,function(v)
    Cfg.Radar.Enabled=v
    if not v and radarOK then
        if RadarBG then RadarBG.Visible=false; RadarBorder.Visible=false; RadarSelf.Visible=false; RadarLabel.Visible=false end
        for _, rd in ipairs(RadarDots) do pcall(function() rd.dot.Visible=false end) end
    end
end)

local SLight = MakeSection("Lighting & Ortam","🌍")
MakeButton(SLight,"☀️  Gündüz",function() ApplyLighting("Day") end)
MakeButton(SLight,"🌙  Gece",function() ApplyLighting("Night") end)
MakeButton(SLight,"🌅  Gün Batımı",function() ApplyLighting("Sunset") end)
MakeButton(SLight,"🌫️  Sisli",function() ApplyLighting("Fog") end)
MakeButton(SLight,"🟣  Neon Mor",function() ApplyLighting("Neon") end)
MakeButton(SLight,"🔄  Normal",function() ApplyLighting("Normal") end)

local SRain = MakeSection("Rainbow Mod","🌈")
MakeToggle(SRain,"Rainbow Silah",Cfg.Rainbow.WeaponEnabled,function(v)
    Cfg.Rainbow.WeaponEnabled=v
    if not v then pcall(function()
        local char=LP.Character; if not char then return end
        for _,t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then for _,pp in ipairs(t:GetDescendants()) do
                if pp:IsA("BasePart") then pcall(function() pp.Color=Color3.fromRGB(163,162,165) end) end
            end end
        end
    end) end
end)
MakeToggle(SRain,"Rainbow Karakter",Cfg.Rainbow.CharEnabled,function(v) Cfg.Rainbow.CharEnabled=v; if not v then ApplySkin() end end)

local SSkin = MakeSection("Skin Changer","🎨")
MakeToggle(SSkin,"Skin Changer",Cfg.SkinChanger.Enabled,function(v) Cfg.SkinChanger.Enabled=v; if v then ApplySkin() end end)
MakeDivider(SSkin,"Presetler")
for _, sk in ipairs({{"TacticalBlack","⬛"},{"Ghost","👻"},{"Desert","🟡"},{"Purple","🟣"},{"Stealth","🖤"},{"Classic","🔵"}}) do
    MakeButton(SSkin,sk[2].."  "..sk[1],function()
        Cfg.SkinChanger.Preset=sk[1]; Cfg.SkinChanger.Enabled=true; Cfg.Rainbow.CharEnabled=false; ApplySkin(sk[1])
    end)
end

-- ════════════════════════════════════════════════════════════════
-- TUŞLAR
-- ════════════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(inp, gp)
    if gp or waitingForKey then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        MF.Visible = not MF.Visible
    end
end)

-- ════════════════════════════════════════════════════════════════
-- BİLDİRİM
-- ════════════════════════════════════════════════════════════════
local function Notify(msg, dur)
    pcall(function()
        local nf=Instance.new("Frame"); nf.Size=UDim2.new(0,300,0,46); nf.Position=UDim2.new(0.5,-150,0,-60)
        nf.BackgroundColor3=DARK2; nf.BorderSizePixel=0; nf.Parent=SG
        Instance.new("UICorner",nf).CornerRadius=UDim.new(0,10)
        local ns=Instance.new("UIStroke",nf); ns.Color=PURPLE; ns.Thickness=1.5
        local acc=Instance.new("Frame"); acc.Size=UDim2.new(0,3,0.65,0); acc.Position=UDim2.new(0,9,0.175,0)
        acc.BackgroundColor3=PURPLE; acc.BorderSizePixel=0; acc.Parent=nf; Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
        local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,-20,1,0); nl.Position=UDim2.new(0,18,0,0)
        nl.BackgroundTransparency=1; nl.Text=msg; nl.TextColor3=TEXT
        nl.Font=Enum.Font.GothamBold; nl.TextSize=12; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=nf
        TweenService:Create(nf,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-150,0,14)}):Play()
        task.delay(dur or 3.5,function()
            TweenService:Create(nf,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-150,0,-65)}):Play()
            task.delay(0.35,function() pcall(function() nf:Destroy() end) end)
        end)
    end)
end

task.delay(1.5,function()
    Notify("⚡ BloxStrike Ultra v5.0  |  RightShift = Menü",4)
end)
print("[BSUltra v5.0] Hazır | ESP=Billboard(Kesin Çalışır) | RShift=Menü | Q=Aim")
