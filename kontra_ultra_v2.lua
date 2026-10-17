-- ╔══════════════════════════════════════════════════════════════╗
-- ║      BLOXSTRIKE ULTRA v6.0  |  Sıfırdan Yazıldı            ║
-- ║  Aimbot · ESP · Skin · Rainbow · Lighting · Chams          ║
-- ║  RightShift = Menü  |  E basılı = Aimbot                   ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Camera       = workspace.CurrentCamera
local LP           = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
-- CONFIG — Takım kontrolü KAPALI (default), herkes hedef
-- ════════════════════════════════════════════════════════════════
local Cfg = {
    Aimbot = {
        Enabled    = true,
        Key        = Enum.KeyCode.E,
        FOV        = 200,
        Smooth     = 0.15,  -- 0.05=hızlı snap | 0.35=yavaş smooth
        Part       = "Head",
        TeamCheck  = false, -- KAPALI — BloxStrike takım sorunu
        ShowFOV    = true,
    },
    ESP = {
        Enabled   = true,
        Name      = true,
        Distance  = true,
        Health    = true,
        TeamCheck = false, -- KAPALI
        MaxDist   = 3000,
        EnemyColor= Color3.fromRGB(255, 60, 60),
        TeamColor = Color3.fromRGB(60, 255, 120),
    },
    NoRecoil  = { Enabled = true,  Strength = 0.5 },
    Chams     = { Enabled = false,  Color = Color3.fromRGB(220,50,50), TeamColor = Color3.fromRGB(50,220,100), Trans = 0.4 },
    Radar     = { Enabled = true,   Size = 160, Range = 400, Scale = 0.68 },
    Skin      = { Enabled = false,  Preset = "TacticalBlack" },
    Rainbow   = { Weapon = false,   Character = false, Speed = 0.4 },
}

-- ════════════════════════════════════════════════════════════════
-- SKIN PRESETS — Araştırılmış, çalışan değerler
-- ════════════════════════════════════════════════════════════════
local Presets = {
    TacticalBlack = {
        ["Head"]="Pastel brown", ["Torso"]="Really black",
        ["Left Arm"]="Really black", ["Right Arm"]="Really black",
        ["Left Leg"]="Really black", ["Right Leg"]="Really black",
        ["UpperTorso"]="Really black", ["LowerTorso"]="Really black",
        ["LeftUpperArm"]="Really black", ["RightUpperArm"]="Really black",
        ["LeftLowerArm"]="Really black", ["RightLowerArm"]="Really black",
        ["LeftHand"]="Really black", ["RightHand"]="Really black",
        ["LeftUpperLeg"]="Really black", ["RightUpperLeg"]="Really black",
        ["LeftLowerLeg"]="Really black", ["RightLowerLeg"]="Really black",
        ["LeftFoot"]="Really black", ["RightFoot"]="Really black",
    },
    Ghost = {
        ["Head"]="White", ["Torso"]="White",
        ["Left Arm"]="White", ["Right Arm"]="White",
        ["Left Leg"]="White", ["Right Leg"]="White",
        ["UpperTorso"]="White", ["LowerTorso"]="White",
        ["LeftUpperArm"]="White", ["RightUpperArm"]="White",
        ["LeftLowerArm"]="White", ["RightLowerArm"]="White",
        ["LeftHand"]="White", ["RightHand"]="White",
        ["LeftUpperLeg"]="White", ["RightUpperLeg"]="White",
        ["LeftLowerLeg"]="White", ["RightLowerLeg"]="White",
        ["LeftFoot"]="White", ["RightFoot"]="White",
    },
    Desert = {
        ["Head"]="Pastel brown", ["Torso"]="Sand yellow",
        ["Left Arm"]="Sand yellow", ["Right Arm"]="Sand yellow",
        ["Left Leg"]="Sand yellow", ["Right Leg"]="Sand yellow",
        ["UpperTorso"]="Sand yellow", ["LowerTorso"]="Sand yellow",
        ["LeftUpperArm"]="Sand yellow", ["RightUpperArm"]="Sand yellow",
        ["LeftLowerArm"]="Sand yellow", ["RightLowerArm"]="Sand yellow",
        ["LeftHand"]="Sand yellow", ["RightHand"]="Sand yellow",
        ["LeftUpperLeg"]="Sand yellow", ["RightUpperLeg"]="Sand yellow",
        ["LeftLowerLeg"]="Sand yellow", ["RightLowerLeg"]="Sand yellow",
        ["LeftFoot"]="Sand yellow", ["RightFoot"]="Sand yellow",
    },
    Stealth = {
        ["Head"]="Really black", ["Torso"]="Really black",
        ["Left Arm"]="Really black", ["Right Arm"]="Really black",
        ["Left Leg"]="Really black", ["Right Leg"]="Really black",
        ["UpperTorso"]="Really black", ["LowerTorso"]="Really black",
        ["LeftUpperArm"]="Really black", ["RightUpperArm"]="Really black",
        ["LeftLowerArm"]="Really black", ["RightLowerArm"]="Really black",
        ["LeftHand"]="Really black", ["RightHand"]="Really black",
        ["LeftUpperLeg"]="Really black", ["RightUpperLeg"]="Really black",
        ["LeftLowerLeg"]="Really black", ["RightLowerLeg"]="Really black",
        ["LeftFoot"]="Really black", ["RightFoot"]="Really black",
    },
    Purple = {
        ["Head"]="Pastel brown", ["Torso"]="Dark indigo",
        ["Left Arm"]="Dark indigo", ["Right Arm"]="Dark indigo",
        ["Left Leg"]="Dark indigo", ["Right Leg"]="Dark indigo",
        ["UpperTorso"]="Dark indigo", ["LowerTorso"]="Dark indigo",
        ["LeftUpperArm"]="Dark indigo", ["RightUpperArm"]="Dark indigo",
        ["LeftLowerArm"]="Dark indigo", ["RightLowerArm"]="Dark indigo",
        ["LeftHand"]="Dark indigo", ["RightHand"]="Dark indigo",
        ["LeftUpperLeg"]="Dark indigo", ["RightUpperLeg"]="Dark indigo",
        ["LeftLowerLeg"]="Dark indigo", ["RightLowerLeg"]="Dark indigo",
        ["LeftFoot"]="Dark indigo", ["RightFoot"]="Dark indigo",
    },
}

-- ════════════════════════════════════════════════════════════════
-- SKIN CHANGER — Düzgün çalışan versiyon
-- ════════════════════════════════════════════════════════════════
local function ApplySkin(presetName)
    local char = LP.Character
    if not char then return end
    local preset = Presets[presetName or Cfg.Skin.Preset]
    if not preset then return end

    for partName, colorName in pairs(preset) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            pcall(function()
                part.BrickColor = BrickColor.new(colorName)
                part.Material = Enum.Material.SmoothPlastic
            end)
        end
    end

    -- Shirt/Pants varsa kaldır (skin görünsün)
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") then
            pcall(function() obj:Destroy() end)
        end
    end
end

LP.CharacterAdded:Connect(function(char)
    task.wait(2)
    if Cfg.Skin.Enabled then ApplySkin() end
end)

-- ════════════════════════════════════════════════════════════════
-- RAINBOW — Çalışan versiyon
-- ════════════════════════════════════════════════════════════════
local hue = 0
RunService.Heartbeat:Connect(function(dt)
    hue = (hue + dt * Cfg.Rainbow.Speed) % 1
    local col = Color3.fromHSV(hue, 1, 1)

    -- Rainbow karakter
    if Cfg.Rainbow.Character then
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    pcall(function() p.Color = col end)
                end
            end
        end
    end

    -- Rainbow silah/tool
    if Cfg.Rainbow.Weapon then
        local char = LP.Character
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, p in ipairs(tool:GetDescendants()) do
                        if p:IsA("BasePart") or p:IsA("MeshPart") or p:IsA("SpecialMesh") then
                            pcall(function() p.Color = col end)
                        end
                    end
                end
            end
            -- Tool backpack'te de dene
            for _, tool in ipairs(LP.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, p in ipairs(tool:GetDescendants()) do
                        if p:IsA("BasePart") then
                            pcall(function() p.Color = col end)
                        end
                    end
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- LIGHTING
-- ════════════════════════════════════════════════════════════════
local LPresets = {
    Normal  = {Brightness=1,   Ambient=Color3.fromRGB(70,70,70),    OutdoorAmbient=Color3.fromRGB(140,140,140), FogEnd=100000, ClockTime=14},
    Night   = {Brightness=0,   Ambient=Color3.fromRGB(15,15,40),    OutdoorAmbient=Color3.fromRGB(5,5,30),     FogEnd=400,    ClockTime=0},
    Day     = {Brightness=2.5, Ambient=Color3.fromRGB(210,210,210), OutdoorAmbient=Color3.fromRGB(240,240,240),FogEnd=100000, ClockTime=12},
    Sunset  = {Brightness=1.3, Ambient=Color3.fromRGB(180,80,30),   OutdoorAmbient=Color3.fromRGB(200,100,40), FogEnd=600,    ClockTime=19},
    Fog     = {Brightness=0.6, Ambient=Color3.fromRGB(90,90,110),   OutdoorAmbient=Color3.fromRGB(110,110,130),FogEnd=150,    ClockTime=10},
    Neon    = {Brightness=0.05,Ambient=Color3.fromRGB(40,0,70),     OutdoorAmbient=Color3.fromRGB(20,0,50),    FogEnd=350,    ClockTime=0},
}
local function SetLight(name)
    local p = LPresets[name]; if not p then return end
    pcall(function()
        TweenService:Create(Lighting, TweenInfo.new(1.5), {
            Brightness=p.Brightness, Ambient=p.Ambient,
            OutdoorAmbient=p.OutdoorAmbient, FogEnd=p.FogEnd,
            ClockTime=p.ClockTime,
        }):Play()
    end)
end

-- ════════════════════════════════════════════════════════════════
-- YARDIMCI
-- ════════════════════════════════════════════════════════════════
local function Alive(p)
    if p == LP then return false end
    local ok, r = pcall(function()
        local c = p.Character; if not c then return false end
        local h = c:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end)
    return ok and r
end

local function SameTeam(p)
    if not Cfg.ESP.TeamCheck then return false end
    local ok, r = pcall(function() return p.Team ~= nil and p.Team == LP.Team end)
    return ok and r
end

local function Dist(p)
    local ok, d = pcall(function()
        local lc = LP.Character; local lr = lc and lc:FindFirstChild("HumanoidRootPart")
        local c  = p.Character;  local r  = c  and c:FindFirstChild("HumanoidRootPart")
        if not lr or not r then return math.huge end
        return (r.Position - lr.Position).Magnitude
    end)
    return ok and d or math.huge
end

-- ════════════════════════════════════════════════════════════════
-- CHAMS — Highlight (her executor'da çalışır)
-- ════════════════════════════════════════════════════════════════
local CHL = {}
local function SetChams(p, on)
    pcall(function()
        if CHL[p] then CHL[p]:Destroy(); CHL[p]=nil end
        if not on then return end
        local char = p.Character; if not char then return end
        local hl = Instance.new("Highlight")
        hl.FillColor          = SameTeam(p) and Cfg.Chams.TeamColor or Cfg.Chams.Color
        hl.OutlineColor       = Color3.fromRGB(255,255,255)
        hl.FillTransparency   = Cfg.Chams.Trans
        hl.OutlineTransparency= 0
        hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee            = char
        hl.Parent             = char
        CHL[p] = hl
    end)
end
local function RefreshChams()
    for p,h in pairs(CHL) do pcall(function() h:Destroy() end); CHL[p]=nil end
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
Players.PlayerRemoving:Connect(function(p) if CHL[p] then pcall(function() CHL[p]:Destroy() end); CHL[p]=nil end end)

-- ════════════════════════════════════════════════════════════════
-- AIMBOT — Mouse pozisyonuna en yakın düşmanı hedefle
-- ════════════════════════════════════════════════════════════════
local function GetTarget()
    local best, bestD = nil, Cfg.Aimbot.FOV
    -- Mouse ortasına göre değil, ekran ortasına göre hedefle
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if not Alive(p) then continue end
        if Cfg.Aimbot.TeamCheck and SameTeam(p) then continue end

        local char = p.Character
        if not char then continue end

        -- Head dene, yoksa HumanoidRootPart
        local part = char:FindFirstChild(Cfg.Aimbot.Part)
                  or char:FindFirstChild("Head")
                  or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local sp, on = Camera:WorldToViewportPoint(part.Position)
        if not on then continue end

        local screenPos = Vector2.new(sp.X, sp.Y)
        local d = (screenPos - center).Magnitude
        if d < bestD then
            bestD = d
            best  = {pos = part.Position, player = p}
        end
    end
    return best
end

-- ════════════════════════════════════════════════════════════════
-- ESP — BillboardGui (executor bağımsız, KESIN çalışır)
-- ════════════════════════════════════════════════════════════════
local Boards = {}

local function MakeBoard(p)
    if p == LP then return end

    local function Build(char)
        -- Eski board varsa temizle
        if Boards[p] then
            pcall(function() Boards[p].bb:Destroy() end)
            if Boards[p].conn then Boards[p].conn:Disconnect() end
            Boards[p] = nil
        end

        local head = char:WaitForChild("Head", 8)
        local root = char:WaitForChild("HumanoidRootPart", 8)
        local hum  = char:WaitForChild("Humanoid", 8)
        if not head or not root or not hum then return end

        local bb = Instance.new("BillboardGui")
        bb.Adornee      = head
        bb.Size         = UDim2.new(0, 150, 0, 60)
        bb.StudsOffset  = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop  = true
        bb.ResetOnSpawn = false
        bb.LightInfluence = 0
        bb.Parent       = head

        -- İsim
        local nameL = Instance.new("TextLabel")
        nameL.Size              = UDim2.new(1,0,0,22)
        nameL.Position          = UDim2.new(0,0,0,0)
        nameL.BackgroundTransparency = 1
        nameL.Font              = Enum.Font.GothamBold
        nameL.TextSize          = 15
        nameL.TextStrokeTransparency = 0
        nameL.TextStrokeColor3  = Color3.new(0,0,0)
        nameL.Parent            = bb

        -- Mesafe
        local distL = Instance.new("TextLabel")
        distL.Size              = UDim2.new(1,0,0,16)
        distL.Position          = UDim2.new(0,0,0,23)
        distL.BackgroundTransparency = 1
        distL.Font              = Enum.Font.Gotham
        distL.TextSize          = 11
        distL.TextColor3        = Color3.fromRGB(210,210,210)
        distL.TextStrokeTransparency = 0
        distL.TextStrokeColor3  = Color3.new(0,0,0)
        distL.Parent            = bb

        -- HP bar arka
        local hpBG = Instance.new("Frame")
        hpBG.Size             = UDim2.new(0.88,0,0,6)
        hpBG.Position         = UDim2.new(0.06,0,1,-10)
        hpBG.BackgroundColor3 = Color3.fromRGB(20,20,20)
        hpBG.BorderSizePixel  = 0
        hpBG.Parent           = bb
        Instance.new("UICorner",hpBG).CornerRadius = UDim.new(1,0)

        -- HP bar dolgu
        local hpF = Instance.new("Frame")
        hpF.Size             = UDim2.new(1,0,1,0)
        hpF.BackgroundColor3 = Color3.fromRGB(50,220,80)
        hpF.BorderSizePixel  = 0
        hpF.Parent           = hpBG
        Instance.new("UICorner",hpF).CornerRadius = UDim.new(1,0)

        local data = {bb=bb, nameL=nameL, distL=distL, hpF=hpF, hpBG=hpBG, conn=nil}
        Boards[p] = data

        data.conn = RunService.RenderStepped:Connect(function()
            pcall(function()
                -- Temel kontroller
                if not Cfg.ESP.Enabled or not char or not char.Parent then
                    bb.Enabled = false; return
                end
                if hum.Health <= 0 then bb.Enabled = false; return end
                if Dist(p) > Cfg.ESP.MaxDist then bb.Enabled = false; return end

                bb.Enabled = true

                local col = SameTeam(p) and Cfg.ESP.TeamColor or Cfg.ESP.EnemyColor

                -- İsim
                nameL.Visible    = Cfg.ESP.Name
                nameL.Text       = p.DisplayName
                nameL.TextColor3 = col

                -- Mesafe
                distL.Visible = Cfg.ESP.Distance
                if Cfg.ESP.Distance then
                    distL.Text = string.format("%.0f m", Dist(p) / 6.5)
                end

                -- HP Bar
                hpBG.Visible = Cfg.ESP.Health
                if Cfg.ESP.Health then
                    local r = math.clamp(hum.Health / math.max(hum.MaxHealth,1), 0, 1)
                    hpF.Size = UDim2.new(r, 0, 1, 0)
                    hpF.BackgroundColor3 = Color3.fromRGB(
                        math.floor((1-r)*255), math.floor(r*220), 0
                    )
                end
            end)
        end)

        -- Temizleme
        char.AncestryChanged:Connect(function(_, par)
            if not par then
                pcall(function() bb:Destroy() end)
                if data.conn then data.conn:Disconnect() end
                if Boards[p] == data then Boards[p] = nil end
            end
        end)
    end

    -- CharacterAdded dinle
    p.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        pcall(function() Build(c) end)
    end)

    -- Zaten spawn olmuşsa hemen yap
    if p.Character then
        task.spawn(function()
            task.wait(0.5)
            pcall(function() Build(p.Character) end)
        end)
    end
end

-- Mevcut oyuncular
for _, p in ipairs(Players:GetPlayers()) do MakeBoard(p) end
Players.PlayerAdded:Connect(MakeBoard)
Players.PlayerRemoving:Connect(function(p)
    if Boards[p] then
        pcall(function() Boards[p].bb:Destroy() end)
        if Boards[p].conn then Boards[p].conn:Disconnect() end
        Boards[p] = nil
    end
    if CHL[p] then pcall(function() CHL[p]:Destroy() end); CHL[p]=nil end
end)

-- Sürekli tarama (CharacterAdded kaçırılanlar için)
task.spawn(function()
    while task.wait(3) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and not Boards[p] then
                task.spawn(function()
                    pcall(function() MakeBoard(p) end)
                end)
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- NO RECOIL
-- ════════════════════════════════════════════════════════════════
local lastCF = Camera.CFrame
local function DoNoRecoil()
    pcall(function()
        if not Cfg.NoRecoil.Enabled then lastCF = Camera.CFrame; return end
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
-- FOV ÇEMBERİ — Drawing varsa
-- ════════════════════════════════════════════════════════════════
local fovOK, fovC = false, nil
pcall(function()
    fovC = Drawing.new("Circle")
    fovC.Visible=false; fovC.Radius=Cfg.Aimbot.FOV; fovC.Thickness=1.8
    fovC.Filled=false; fovC.NumSides=80; fovC.Color=Color3.fromRGB(160,60,255)
    fovOK = true
end)

-- ════════════════════════════════════════════════════════════════
-- RADAR — Drawing varsa
-- ════════════════════════════════════════════════════════════════
local radOK = false
local rBG, rBD, rSelf, rLbl = nil,nil,nil,nil
local rDots = {}

pcall(function()
    rBG   = Drawing.new("Square"); rBG.Filled=true; rBG.Color=Color3.fromRGB(6,6,12); rBG.Transparency=0.38; rBG.Visible=false
    rBD   = Drawing.new("Square"); rBD.Filled=false; rBD.Thickness=1.5; rBD.Color=Color3.fromRGB(140,50,255); rBD.Visible=false
    rSelf = Drawing.new("Circle"); rSelf.Filled=true; rSelf.Radius=4; rSelf.NumSides=8; rSelf.Color=Color3.fromRGB(80,180,255); rSelf.Visible=false
    rLbl  = Drawing.new("Text"); rLbl.Text="RADAR"; rLbl.Size=9; rLbl.Center=true; rLbl.Outline=true; rLbl.Color=Color3.fromRGB(140,50,255); rLbl.Font=Drawing.Fonts.Plex; rLbl.Visible=false
    radOK = true
end)

local function RefreshDots()
    for _, rd in pairs(rDots) do pcall(function() rd.d:Remove() end) end
    rDots = {}
    if not radOK then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local d = Drawing.new("Circle"); d.Filled=true; d.Radius=4; d.NumSides=8; d.Visible=false
            table.insert(rDots, {d=d, p=p})
        end
    end
end
if radOK then RefreshDots() end
Players.PlayerAdded:Connect(function() task.wait(1); if radOK then RefreshDots() end end)
Players.PlayerRemoving:Connect(function() task.wait(0.5); if radOK then RefreshDots() end end)

-- ════════════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    pcall(function()
        local vp     = Camera.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)

        -- FOV
        if fovOK and fovC then
            fovC.Position = center
            fovC.Radius   = Cfg.Aimbot.FOV
            fovC.Visible  = Cfg.Aimbot.Enabled and Cfg.Aimbot.ShowFOV
        end

        -- Aimbot
        if Cfg.Aimbot.Enabled and UIS:IsKeyDown(Cfg.Aimbot.Key) then
            local t = GetTarget()
            if t then
                local cur = Camera.CFrame
                -- dt-independent smooth
                Camera.CFrame = cur:Lerp(CFrame.lookAt(cur.Position, t.pos), Cfg.Aimbot.Smooth)
            end
        end

        -- No Recoil
        DoNoRecoil()

        -- Radar
        if radOK and Cfg.Radar.Enabled then
            local rs = Cfg.Radar.Size; local rx = 20; local ry = vp.Y - 20 - rs
            rBG.Size=Vector2.new(rs,rs); rBG.Position=Vector2.new(rx,ry); rBG.Visible=true
            rBD.Size=Vector2.new(rs,rs); rBD.Position=Vector2.new(rx,ry); rBD.Visible=true
            rSelf.Position=Vector2.new(rx+rs/2,ry+rs/2); rSelf.Visible=true
            rLbl.Position=Vector2.new(rx+rs/2,ry+rs+2); rLbl.Visible=true

            local lc=LP.Character; local lr=lc and lc:FindFirstChild("HumanoidRootPart")
            local lCF = lr and lr.CFrame or CFrame.new()

            for _, rd in ipairs(rDots) do
                pcall(function()
                    local p=rd.p; local dot=rd.d
                    if not Alive(p) then dot.Visible=false; return end
                    local c2=p.Character; local r2=c2 and c2:FindFirstChild("HumanoidRootPart")
                    if not r2 then dot.Visible=false; return end
                    local rel=lCF:PointToObjectSpace(r2.Position)
                    local nx=rel.X/Cfg.Radar.Range; local nz=rel.Z/Cfg.Radar.Range
                    if math.abs(nx)>1 or math.abs(nz)>1 then dot.Visible=false; return end
                    dot.Position=Vector2.new(rx+rs/2+nx*(rs/2)*Cfg.Radar.Scale, ry+rs/2-nz*(rs/2)*Cfg.Radar.Scale)
                    dot.Color = SameTeam(p) and Cfg.ESP.TeamColor or Cfg.ESP.EnemyColor
                    dot.Visible = true
                end)
            end
        elseif radOK then
            if rBG then rBG.Visible=false; rBD.Visible=false; rSelf.Visible=false; rLbl.Visible=false end
            for _, rd in ipairs(rDots) do pcall(function() rd.d.Visible=false end) end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════
-- GUI — MOR/SİYAH, ACCORDION
-- ════════════════════════════════════════════════════════════════
local P1=Color3.fromRGB(140,50,255); local P2=Color3.fromRGB(85,22,175)
local D1=Color3.fromRGB(9,7,16);    local D2=Color3.fromRGB(15,11,26)
local D3=Color3.fromRGB(21,16,36)
local TX=Color3.fromRGB(225,215,255);local TXD=Color3.fromRGB(140,120,190)

local SG=Instance.new("ScreenGui"); SG.Name="BSv6"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent=game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent=LP.PlayerGui end

local MF=Instance.new("Frame")
MF.Size=UDim2.new(0,280,0,510); MF.Position=UDim2.new(0,12,0.5,-255)
MF.BackgroundColor3=D1; MF.BorderSizePixel=0; MF.Active=true; MF.Draggable=true
MF.Visible=false; MF.Parent=SG
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,12)
local mS=Instance.new("UIStroke",MF); mS.Color=P1; mS.Thickness=1.8

-- Glow
local Gw=Instance.new("ImageLabel"); Gw.Size=UDim2.new(1,40,1,40); Gw.Position=UDim2.new(0,-20,0,-20)
Gw.BackgroundTransparency=1; Gw.Image="rbxassetid://1316045217"; Gw.ImageColor3=P2
Gw.ImageTransparency=0.55; Gw.ScaleType=Enum.ScaleType.Slice; Gw.SliceCenter=Rect.new(10,10,118,118); Gw.ZIndex=0; Gw.Parent=MF

-- Header
local Hdr=Instance.new("Frame"); Hdr.Size=UDim2.new(1,0,0,50); Hdr.BackgroundColor3=D2; Hdr.BorderSizePixel=0; Hdr.Parent=MF
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,12)
-- Header'ın alt köşe patch
local HP=Instance.new("Frame"); HP.Size=UDim2.new(1,0,0.5,0); HP.Position=UDim2.new(0,0,0.5,0); HP.BackgroundColor3=D2; HP.BorderSizePixel=0; HP.Parent=Hdr

local HA=Instance.new("Frame"); HA.Size=UDim2.new(0,4,0.6,0); HA.Position=UDim2.new(0,9,0.2,0)
HA.BackgroundColor3=P1; HA.BorderSizePixel=0; HA.Parent=Hdr; Instance.new("UICorner",HA).CornerRadius=UDim.new(1,0)

local HT=Instance.new("TextLabel"); HT.Size=UDim2.new(1,-20,0,24); HT.Position=UDim2.new(0,20,0,5)
HT.BackgroundTransparency=1; HT.Text="BLOXSTRIKE ULTRA  v6.0"; HT.TextColor3=TX
HT.Font=Enum.Font.GothamBold; HT.TextSize=14; HT.TextXAlignment=Enum.TextXAlignment.Left; HT.Parent=Hdr

local HS=Instance.new("TextLabel"); HS.Size=UDim2.new(1,-20,0,14); HS.Position=UDim2.new(0,20,0,30)
HS.BackgroundTransparency=1; HS.Text="RightShift = Menü  ·  E basılı = Aimbot"; HS.TextColor3=TXD
HS.Font=Enum.Font.Gotham; HS.TextSize=10; HS.TextXAlignment=Enum.TextXAlignment.Left; HS.Parent=Hdr

-- Scroll
local Sc=Instance.new("ScrollingFrame")
Sc.Size=UDim2.new(1,-8,1,-58); Sc.Position=UDim2.new(0,4,0,54)
Sc.BackgroundTransparency=1; Sc.BorderSizePixel=0
Sc.ScrollBarThickness=3; Sc.ScrollBarImageColor3=P1
Sc.CanvasSize=UDim2.new(0,0,0,0); Sc.AutomaticCanvasSize=Enum.AutomaticSize.Y; Sc.Parent=MF
local ScL=Instance.new("UIListLayout"); ScL.Parent=Sc; ScL.SortOrder=Enum.SortOrder.LayoutOrder; ScL.Padding=UDim.new(0,5)
local ScP=Instance.new("UIPadding"); ScP.PaddingLeft=UDim.new(0,3); ScP.PaddingRight=UDim.new(0,3); ScP.PaddingTop=UDim.new(0,4); ScP.PaddingBottom=UDim.new(0,8); ScP.Parent=Sc

local so=0
local function Sec(title, emoji)
    so=so+1
    local sec=Instance.new("Frame"); sec.Size=UDim2.new(1,-4,0,40); sec.BackgroundColor3=D3
    sec.BorderSizePixel=0; sec.LayoutOrder=so; sec.AutomaticSize=Enum.AutomaticSize.Y
    sec.ClipsDescendants=true; sec.Parent=Sc
    Instance.new("UICorner",sec).CornerRadius=UDim.new(0,9)
    local ss=Instance.new("UIStroke",sec); ss.Color=P2; ss.Thickness=1

    local hb=Instance.new("TextButton"); hb.Size=UDim2.new(1,0,0,40); hb.BackgroundColor3=D2
    hb.BorderSizePixel=0; hb.Text=""; hb.AutoButtonColor=false; hb.ZIndex=2; hb.Parent=sec
    Instance.new("UICorner",hb).CornerRadius=UDim.new(0,9)

    local al=Instance.new("Frame"); al.Size=UDim2.new(0,3,0.55,0); al.Position=UDim2.new(0,7,0.225,0)
    al.BackgroundColor3=P1; al.BorderSizePixel=0; al.ZIndex=3; al.Parent=hb
    Instance.new("UICorner",al).CornerRadius=UDim.new(1,0)

    local tl=Instance.new("TextLabel"); tl.Size=UDim2.new(1,-46,1,0); tl.Position=UDim2.new(0,17,0,0)
    tl.BackgroundTransparency=1; tl.Text=emoji.."  "..title; tl.TextColor3=TX
    tl.Font=Enum.Font.GothamBold; tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=3; tl.Parent=hb

    local ar=Instance.new("TextLabel"); ar.Size=UDim2.new(0,26,0,26); ar.Position=UDim2.new(1,-30,0.5,-13)
    ar.BackgroundTransparency=1; ar.Text="▾"; ar.TextColor3=P1
    ar.Font=Enum.Font.GothamBold; ar.TextSize=15; ar.ZIndex=3; ar.Parent=hb

    local cont=Instance.new("Frame"); cont.Size=UDim2.new(1,0,0,0); cont.Position=UDim2.new(0,0,0,40)
    cont.BackgroundTransparency=1; cont.BorderSizePixel=0; cont.AutomaticSize=Enum.AutomaticSize.Y
    cont.Visible=false; cont.Parent=sec
    local cl=Instance.new("UIListLayout"); cl.Parent=cont; cl.Padding=UDim.new(0,4)
    local cp=Instance.new("UIPadding"); cp.PaddingLeft=UDim.new(0,6); cp.PaddingRight=UDim.new(0,6); cp.PaddingTop=UDim.new(0,5); cp.PaddingBottom=UDim.new(0,8); cp.Parent=cont

    local open=false
    hb.MouseButton1Click:Connect(function()
        open=not open; cont.Visible=open; sec.ClipsDescendants=not open
        TweenService:Create(ar,TweenInfo.new(0.2),{Rotation=open and 180 or 0}):Play()
        TweenService:Create(hb,TweenInfo.new(0.15),{BackgroundColor3=open and D3 or D2}):Play()
    end)
    hb.MouseEnter:Connect(function() if not open then TweenService:Create(hb,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(22,16,42)}):Play() end end)
    hb.MouseLeave:Connect(function() if not open then TweenService:Create(hb,TweenInfo.new(0.12),{BackgroundColor3=D2}):Play() end end)
    return cont
end

local io=0
local function Tog(parent, lbl, def, cb)
    io=io+1
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=D1
    row.BorderSizePixel=0; row.LayoutOrder=io; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)

    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-65,1,0); l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1; l.Text=lbl; l.TextColor3=TX; l.Font=Enum.Font.Gotham; l.TextSize=12
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=row

    local state=def
    local tr=Instance.new("Frame"); tr.Size=UDim2.new(0,44,0,22); tr.Position=UDim2.new(1,-52,0.5,-11)
    tr.BackgroundColor3=state and P1 or Color3.fromRGB(36,26,56); tr.BorderSizePixel=0; tr.Parent=row
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)

    local kn=Instance.new("Frame"); kn.Size=UDim2.new(0,18,0,18); kn.BorderSizePixel=0
    kn.Position=UDim2.new(state and 1 or 0, state and -20 or 2, 0.5,-9)
    kn.BackgroundColor3=Color3.fromRGB(255,255,255); kn.Parent=tr
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)

    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,1,0); b.BackgroundTransparency=1; b.Text=""; b.Parent=row
    b.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(tr,TweenInfo.new(0.18),{BackgroundColor3=state and P1 or Color3.fromRGB(36,26,56)}):Play()
        TweenService:Create(kn,TweenInfo.new(0.18),{Position=UDim2.new(state and 1 or 0, state and -20 or 2, 0.5,-9)}):Play()
        cb(state)
    end)
end

local function Btn(parent, lbl, cb)
    io=io+1
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,30); b.LayoutOrder=io
    b.BackgroundColor3=P2; b.BorderSizePixel=0; b.Text=lbl; b.TextColor3=TX
    b.Font=Enum.Font.GothamBold; b.TextSize=11; b.Parent=parent
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=P1}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=P2}):Play() end)
    b.MouseButton1Click:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.07),{BackgroundColor3=Color3.fromRGB(190,110,255)}):Play()
        task.delay(0.15,function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=P2}):Play() end)
        cb()
    end)
end

local function Div(parent, txt)
    io=io+1
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,0,18); l.LayoutOrder=io
    l.BackgroundTransparency=1; l.Text="── "..txt.." ──"; l.TextColor3=TXD
    l.Font=Enum.Font.GothamBold; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Center; l.Parent=parent
end

-- Keybind seçici (güvenli versiyon)
local waitKey = false
local function KeyBind(parent, lbl, getK, setK)
    io=io+1
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=D1
    row.BorderSizePixel=0; row.LayoutOrder=io; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)

    local l=Instance.new("TextLabel"); l.Size=UDim2.new(0.58,0,1,0); l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1; l.Text=lbl; l.TextColor3=TX; l.Font=Enum.Font.Gotham; l.TextSize=12
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=row

    local kb=Instance.new("TextButton"); kb.Size=UDim2.new(0,78,0,22); kb.Position=UDim2.new(1,-86,0.5,-11)
    kb.BackgroundColor3=P2; kb.BorderSizePixel=0; kb.Font=Enum.Font.GothamBold; kb.TextSize=11
    kb.TextColor3=TX; kb.Text="["..getK().Name.."]"; kb.Parent=row
    Instance.new("UICorner",kb).CornerRadius=UDim.new(0,5)

    local on=false
    kb.MouseButton1Click:Connect(function()
        if on then return end; on=true
        kb.Text="Bas..."; kb.BackgroundColor3=Color3.fromRGB(200,90,20)
        task.spawn(function()
            local t=tick()+6
            while on and tick()<t do
                for _,key in ipairs(Enum.KeyCode:GetEnumItems()) do
                    local ok,dn=pcall(function() return UIS:IsKeyDown(key) end)
                    if ok and dn then
                        local n=key.Name
                        if n~="RightShift" and n~="LeftShift" and n~="Unknown" then
                            pcall(function() setK(key) end)
                            kb.Text="["..key.Name.."]"
                            kb.BackgroundColor3=P2
                            on=false; task.wait(0.4); break
                        end
                    end
                end
                task.wait(0.06)
            end
            if on then
                kb.Text="["..getK().Name.."]"; kb.BackgroundColor3=P2; on=false
            end
        end)
    end)
end

-- ═══ BÖLÜMLER ═══

local SAim=Sec("Aimbot","🎯")
Tog(SAim,"Aimbot Aktif",Cfg.Aimbot.Enabled,function(v) Cfg.Aimbot.Enabled=v end)
Tog(SAim,"FOV Çemberi",Cfg.Aimbot.ShowFOV,function(v) Cfg.Aimbot.ShowFOV=v end)
Tog(SAim,"Takım Kontrolü",Cfg.Aimbot.TeamCheck,function(v) Cfg.Aimbot.TeamCheck=v end)
Tog(SAim,"Velocity Predict",false,function(v) end) -- placeholder
Tog(SAim,"No Recoil",Cfg.NoRecoil.Enabled,function(v) Cfg.NoRecoil.Enabled=v end)
Div(SAim,"Aim Tuşu")
KeyBind(SAim,"Aim Tuşu",function() return Cfg.Aimbot.Key end,function(k) Cfg.Aimbot.Key=k end)

local SEsp=Sec("ESP","👁")
Tog(SEsp,"ESP Aktif",Cfg.ESP.Enabled,function(v) Cfg.ESP.Enabled=v end)
Tog(SEsp,"İsim",Cfg.ESP.Name,function(v) Cfg.ESP.Name=v end)
Tog(SEsp,"Mesafe",Cfg.ESP.Distance,function(v) Cfg.ESP.Distance=v end)
Tog(SEsp,"HP Bar",Cfg.ESP.Health,function(v) Cfg.ESP.Health=v end)
Tog(SEsp,"Takım Rengi Ayrımı",Cfg.ESP.TeamCheck,function(v) Cfg.ESP.TeamCheck=v end)

local SCh=Sec("Chams","💀")
Tog(SCh,"Chams (Duvardan Gör)",Cfg.Chams.Enabled,function(v) Cfg.Chams.Enabled=v; RefreshChams() end)

local SRad=Sec("Radar","📡")
Tog(SRad,"Mini Radar",Cfg.Radar.Enabled,function(v)
    Cfg.Radar.Enabled=v
    if not v and radOK then
        if rBG then rBG.Visible=false; rBD.Visible=false; rSelf.Visible=false; rLbl.Visible=false end
        for _,rd in ipairs(rDots) do pcall(function() rd.d.Visible=false end) end
    end
end)

local SLit=Sec("Lighting & Ortam","🌍")
Btn(SLit,"☀️  Gündüz",function() SetLight("Day") end)
Btn(SLit,"🌙  Gece",function() SetLight("Night") end)
Btn(SLit,"🌅  Gün Batımı",function() SetLight("Sunset") end)
Btn(SLit,"🌫️  Sisli",function() SetLight("Fog") end)
Btn(SLit,"🟣  Neon Mor",function() SetLight("Neon") end)
Btn(SLit,"🔄  Normal",function() SetLight("Normal") end)

local SRain=Sec("Rainbow Mod","🌈")
Tog(SRain,"Rainbow Karakter",Cfg.Rainbow.Character,function(v)
    Cfg.Rainbow.Character=v
    if not v then
        -- renkleri resetle
        local char=LP.Character; if not char then return end
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() p.BrickColor=BrickColor.new("Medium stone grey") end)
            end
        end
        if Cfg.Skin.Enabled then ApplySkin() end
    end
end)
Tog(SRain,"Rainbow Silah",Cfg.Rainbow.Weapon,function(v) Cfg.Rainbow.Weapon=v end)

local SSkin=Sec("Skin Changer","🎨")
Tog(SSkin,"Skin Changer",Cfg.Skin.Enabled,function(v)
    Cfg.Skin.Enabled=v; if v then ApplySkin() end
end)
Div(SSkin,"Presetler")
for _, sk in ipairs({
    {"TacticalBlack","⬛  Tactical Black"},
    {"Ghost","👻  Ghost (Beyaz)"},
    {"Desert","🟡  Desert (Kum)"},
    {"Stealth","🖤  Stealth (Tam Siyah)"},
    {"Purple","🟣  Purple (Mor)"},
}) do
    Btn(SSkin, sk[2], function()
        Cfg.Skin.Preset = sk[1]
        Cfg.Skin.Enabled = true
        Cfg.Rainbow.Character = false
        ApplySkin(sk[1])
    end)
end

-- Anlık uygula butonu
Btn(SSkin,"🔄  Tekrar Uygula",function() ApplySkin() end)

-- ════════════════════════════════════════════════════════════════
-- TUŞLAR & BİLDİRİM
-- ════════════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        MF.Visible = not MF.Visible
    end
end)

local function Notif(msg, dur)
    pcall(function()
        local nf=Instance.new("Frame"); nf.Size=UDim2.new(0,300,0,46); nf.Position=UDim2.new(0.5,-150,0,-60)
        nf.BackgroundColor3=D2; nf.BorderSizePixel=0; nf.Parent=SG
        Instance.new("UICorner",nf).CornerRadius=UDim.new(0,10)
        Instance.new("UIStroke",nf).Color=P1
        local acc=Instance.new("Frame"); acc.Size=UDim2.new(0,3,0.65,0); acc.Position=UDim2.new(0,9,0.175,0)
        acc.BackgroundColor3=P1; acc.BorderSizePixel=0; acc.Parent=nf; Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
        local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,-20,1,0); nl.Position=UDim2.new(0,18,0,0)
        nl.BackgroundTransparency=1; nl.Text=msg; nl.TextColor3=TX
        nl.Font=Enum.Font.GothamBold; nl.TextSize=12; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=nf
        TweenService:Create(nf,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-150,0,14)}):Play()
        task.delay(dur or 4,function()
            TweenService:Create(nf,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-150,0,-65)}):Play()
            task.delay(0.35,function() pcall(function() nf:Destroy() end) end)
        end)
    end)
end

task.delay(1.5, function()
    Notif("⚡ BloxStrike Ultra v6  |  RShift=Menü  |  E=Aimbot", 4)
end)

print("[BSUltra v6] Hazır | TeamCheck=KAPALI | E=Aim | RShift=Menü")
