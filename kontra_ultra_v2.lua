-- ╔══════════════════════════════════════════════════════════════╗
-- ║     BLOXSTRIKE ULTRA v10.0  |  Drawing ESP Build           ║
-- ║  ESP · Aimbot · SkinChanger · BigHead · Ayar Kaydet        ║
-- ║  RightShift = Menü  |  E basılı = Aimbot                   ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RS           = game:GetService("ReplicatedStorage")
local HttpService  = game:GetService("HttpService")
local Camera       = workspace.CurrentCamera
local LP           = Players.LocalPlayer
local SAVE_FILE    = "BSUltra_settings.json"

-- ════════════════════════════════════════════════════════════════
-- AYAR KAYDET / YÜKLE
-- ════════════════════════════════════════════════════════════════
local function SaveSettings(cfg)
    pcall(function()
        local data = {
            AimbotEnabled = cfg.Aimbot.Enabled, AimbotFOV = cfg.Aimbot.FOV,
            AimbotSmooth = cfg.Aimbot.Smooth, AimbotKey = cfg.Aimbot.Key.Name,
            ShowFOV = cfg.Aimbot.ShowFOV, NoRecoil = cfg.NoRecoil.Enabled,
            ESPEnabled = cfg.ESP.Enabled, ESPName = cfg.ESP.Name,
            ESPDist = cfg.ESP.Distance, ESPHealth = cfg.ESP.Health,
            WallhackEnabled = cfg.Wallhack.Enabled,
            RadarEnabled = cfg.Radar.Enabled,
            SkinEnabled = cfg.Skin.Enabled, SkinPreset = cfg.Skin.Preset,
            RainbowChar = cfg.Rainbow.Character, RainbowWeapon = cfg.Rainbow.Weapon,
            BigHead = cfg.BigHead.Enabled, BigHeadScale = cfg.BigHead.Scale,
        }
        local ok, json = pcall(function() return HttpService:JSONEncode(data) end)
        if ok then writefile(SAVE_FILE, json) end
    end)
end

local function LoadSettings()
    local ok, content = pcall(function() return readfile(SAVE_FILE) end)
    if not ok or not content or content == "" then return nil end
    local ok2, data = pcall(function() return HttpService:JSONDecode(content) end)
    return ok2 and data or nil
end

-- ════════════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════════════
local Cfg = {
    Aimbot   = { Enabled=true, Key=Enum.KeyCode.E, FOV=200, Smooth=0.15, Part="Head", ShowFOV=true },
    ESP      = { Enabled=true, Name=true, Distance=true, Health=true, MaxDist=3000,
                 EnemyColor=Color3.fromRGB(255,60,60), TeamColor=Color3.fromRGB(60,255,120) },
    NoRecoil = { Enabled=true, Strength=0.5 },
    Radar    = { Enabled=true, Size=160, Range=400, Scale=0.68 },
    Skin     = { Enabled=false, Preset="TacticalBlack" },
    Rainbow  = { Weapon=false, Character=false, Speed=0.4 },
    Wallhack = {
        Enabled      = false,
        EnemyFill    = Color3.fromRGB(220, 40, 40),
        EnemyOutline = Color3.fromRGB(255, 255, 255),
        TeamFill     = Color3.fromRGB(40, 220, 80),
        TeamOutline  = Color3.fromRGB(255, 255, 255),
        FillTrans    = 0.45,
        OutlineTrans = 0.0,
    },
    BigHead  = { Enabled=false, Scale=3.5 },
}

local saved = LoadSettings()
if saved then
    pcall(function()
        Cfg.Aimbot.Enabled    = saved.AimbotEnabled
        Cfg.Aimbot.FOV        = saved.AimbotFOV or 200
        Cfg.Aimbot.Smooth     = saved.AimbotSmooth or 0.15
        Cfg.Aimbot.ShowFOV    = saved.ShowFOV
        Cfg.NoRecoil.Enabled  = saved.NoRecoil
        Cfg.ESP.Enabled       = saved.ESPEnabled
        Cfg.ESP.Name          = saved.ESPName
        Cfg.ESP.Distance      = saved.ESPDist
        Cfg.ESP.Health        = saved.ESPHealth
        Cfg.Wallhack.Enabled  = saved.WallhackEnabled
        Cfg.Radar.Enabled     = saved.RadarEnabled
        Cfg.Skin.Enabled      = saved.SkinEnabled
        Cfg.Skin.Preset       = saved.SkinPreset or "TacticalBlack"
        Cfg.Rainbow.Character = saved.RainbowChar
        Cfg.Rainbow.Weapon    = saved.RainbowWeapon
        Cfg.BigHead.Enabled   = saved.BigHead
        Cfg.BigHead.Scale     = saved.BigHeadScale or 3.5
        if saved.AimbotKey then
            local k = Enum.KeyCode[saved.AimbotKey]
            if k then Cfg.Aimbot.Key = k end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- BLOXSTRIKE KARAKTER YAPISI
-- workspace.Characters.Terrorists / Counter-Terrorists
-- ════════════════════════════════════════════════════════════════
local CharFolder, TFolder, CTFolder
local myTeamFolder = nil

task.spawn(function()
    CharFolder = workspace:WaitForChild("Characters", 25)
    if CharFolder then
        TFolder  = CharFolder:WaitForChild("Terrorists", 15)
        CTFolder = CharFolder:WaitForChild("Counter-Terrorists", 15)
        print("[v10] workspace.Characters bulundu ✅")
        print("[v10] T:", TFolder and "✅" or "❌", "CT:", CTFolder and "✅" or "❌")
    else
        print("[v10] workspace.Characters yok — standart Players modu")
    end
end)

local function GetMyChar()
    if TFolder then
        local f = TFolder:FindFirstChild(LP.Name)
        if f then myTeamFolder = "T"; return f end
    end
    if CTFolder then
        local f = CTFolder:FindFirstChild(LP.Name)
        if f then myTeamFolder = "CT"; return f end
    end
    local c = LP.Character
    if c and c.Parent then return c end
    return nil
end

local function GetMyTeam()
    if TFolder and TFolder:FindFirstChild(LP.Name) then return "T" end
    if CTFolder and CTFolder:FindFirstChild(LP.Name) then return "CT" end
    if LP.Team then
        local tn = LP.Team.Name:lower()
        if tn:find("terror") and not tn:find("counter") then return "T" end
        if tn:find("counter") then return "CT" end
    end
    return nil
end

local function GetEnemyFolder()
    local team = GetMyTeam()
    if team == "T" then return CTFolder end
    if team == "CT" then return TFolder end
    return nil
end

local function GetEnemies()
    local list = {}
    if TFolder and CTFolder then
        local enemyFolder = GetEnemyFolder()
        if enemyFolder then
            for _, char in ipairs(enemyFolder:GetChildren()) do
                if char.Name ~= LP.Name then
                    table.insert(list, {char=char, name=char.Name})
                end
            end
        else
            local function scanF(f)
                if not f then return end
                for _, char in ipairs(f:GetChildren()) do
                    if char.Name ~= LP.Name then
                        table.insert(list, {char=char, name=char.Name})
                    end
                end
            end
            scanF(TFolder); scanF(CTFolder)
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local sameTeam = LP.Team and p.Team and LP.Team == p.Team
                if not sameTeam and p.Character then
                    table.insert(list, {char=p.Character, name=p.Name})
                end
            end
        end
    end
    return list
end

local function GetTeammates()
    local list = {}
    local myTeam = GetMyTeam()
    if myTeam == "T" and TFolder then
        for _, c in ipairs(TFolder:GetChildren()) do
            if c.Name ~= LP.Name then table.insert(list, {char=c, name=c.Name}) end
        end
    elseif myTeam == "CT" and CTFolder then
        for _, c in ipairs(CTFolder:GetChildren()) do
            if c.Name ~= LP.Name then table.insert(list, {char=c, name=c.Name}) end
        end
    end
    return list
end

local function IsAlive(char)
    if not char or not char.Parent then return false end
    local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                 or char:FindFirstChildWhichIsA("BasePart")
    if not part then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    return true
end

local function GetHP(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    local hp = char:FindFirstChild("Health") or char:FindFirstChild("HP")
    if hp and hp:IsA("NumberValue") or hp and hp:IsA("IntValue") then
        return hp.Value, 100
    end
    return 100, 100
end

local function GetHeadPos(char)
    local head = char:FindFirstChild("Head")
    if head then return head.Position + Vector3.new(0, 1.5, 0) end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position + Vector3.new(0, 3, 0) end
    local p = char:FindFirstChildWhichIsA("BasePart")
    if p then return p.Position + Vector3.new(0, 2, 0) end
    return nil
end

local function GetRootPos(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position end
    local head = char:FindFirstChild("Head")
    if head then return head.Position end
    local p = char:FindFirstChildWhichIsA("BasePart")
    if p then return p.Position end
    return nil
end

local function GetDist(char)
    local myChar = GetMyChar()
    if not myChar then return 0 end
    local myPos = GetRootPos(myChar)
    local theirPos = GetRootPos(char)
    if not myPos or not theirPos then return 0 end
    return (theirPos - myPos).Magnitude
end

-- ════════════════════════════════════════════════════════════════
-- BIG HEAD
-- ════════════════════════════════════════════════════════════════
local function ApplyBigHeadToEnemies()
    if not Cfg.BigHead.Enabled then return end
    for _, e in ipairs(GetEnemies()) do
        pcall(function()
            local head = e.char:FindFirstChild("Head")
            if head then
                local mesh = head:FindFirstChildOfClass("SpecialMesh")
                if not mesh then
                    mesh = Instance.new("SpecialMesh")
                    mesh.MeshType = Enum.MeshType.Head
                    mesh.Parent = head
                end
                mesh.Scale = Vector3.new(Cfg.BigHead.Scale, Cfg.BigHead.Scale, Cfg.BigHead.Scale)
            end
        end)
    end
end

local function ResetBigHead()
    local function resetFolder(f)
        if not f then return end
        for _, char in ipairs(f:GetChildren()) do
            pcall(function()
                local head = char:FindFirstChild("Head")
                if head then
                    local mesh = head:FindFirstChildOfClass("SpecialMesh")
                    if mesh then mesh.Scale = Vector3.new(1,1,1) end
                end
            end)
        end
    end
    if TFolder then resetFolder(TFolder) end
    if CTFolder then resetFolder(CTFolder) end
end

-- ════════════════════════════════════════════════════════════════
-- SKIN CHANGER
-- ════════════════════════════════════════════════════════════════
local KnifeNames = {"Karambit","Butterfly Knife","M9 Bayonet","Flip Knife","Gut Knife","Default Knife"}

local function ApplyKnifeSkin(knifeName)
    pcall(function()
        local existingKnife = Camera:FindFirstChild("T Knife") or Camera:FindFirstChild("CT Knife")
        if not existingKnife then return end
        local assetsFolder = RS:FindFirstChild("Assets")
        if not assetsFolder then return end
        local weaponsFolder = assetsFolder:FindFirstChild("Weapons")
        if not weaponsFolder then return end
        local knifeAsset = weaponsFolder:FindFirstChild(knifeName)
        if not knifeAsset then return end
        for _, part in ipairs(existingKnife:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                pcall(function() part.Transparency = 1 end)
            end
            if part:IsA("Texture") or part:IsA("Decal") then
                pcall(function() part.Transparency = 1 end)
            end
        end
        local oldSkin = existingKnife:FindFirstChild("_SkinKnife")
        if oldSkin then oldSkin:Destroy() end
        local newKnife = knifeAsset:Clone()
        newKnife.Name = "_SkinKnife"
        for _, part in ipairs(newKnife:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Anchored = false
                part.CastShadow = false
                part.CanTouch = false
                part.CanQuery = false
            end
        end
        newKnife.Parent = existingKnife
        local root = existingKnife:FindFirstChild("Handle") or existingKnife.PrimaryPart
        if root then
            for _, part in ipairs(newKnife:GetDescendants()) do
                if part:IsA("BasePart") then
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = root
                    weld.Part1 = part
                    weld.Parent = part
                end
            end
        end
    end)
end

local BodyPresets = {
    TacticalBlack = {body="Really black",  face="Pastel brown"},
    Ghost         = {body="White",         face="White"},
    Desert        = {body="Sand yellow",   face="Pastel brown"},
    Stealth       = {body="Really black",  face="Really black"},
    Purple        = {body="Dark indigo",   face="Pastel brown"},
    NeonGreen     = {body="Lime green",    face="Pastel brown"},
    Red           = {body="Really red",    face="Pastel brown"},
    Navy          = {body="Navy blue",     face="Pastel brown"},
    Orange        = {body="Bright orange", face="Pastel brown"},
    Gold          = {body="Bright yellow", face="Pastel brown"},
}

local function ApplyBodySkin(presetName)
    local char = GetMyChar()
    if not char then return end
    local preset = BodyPresets[presetName or Cfg.Skin.Preset]
    if not preset then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
            pcall(function() obj:Destroy() end)
        end
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function()
                if part.Name == "Head" then
                    part.BrickColor = BrickColor.new(preset.face)
                else
                    part.BrickColor = BrickColor.new(preset.body)
                end
                part.Material = Enum.Material.SmoothPlastic
                for _, child in ipairs(part:GetChildren()) do
                    if child:IsA("Texture") or child:IsA("Decal") then
                        if child.Name ~= "face" then
                            pcall(function() child.Transparency = 1 end)
                        end
                    end
                end
            end)
        end
    end
end

task.spawn(function()
    task.wait(3)
    local function watchMyChar()
        if TFolder then
            TFolder.ChildAdded:Connect(function(c)
                if c.Name == LP.Name then
                    task.wait(1)
                    if Cfg.Skin.Enabled then ApplyBodySkin(Cfg.Skin.Preset) end
                end
            end)
        end
        if CTFolder then
            CTFolder.ChildAdded:Connect(function(c)
                if c.Name == LP.Name then
                    task.wait(1)
                    if Cfg.Skin.Enabled then ApplyBodySkin(Cfg.Skin.Preset) end
                end
            end)
        end
    end
    watchMyChar()
    LP.CharacterAdded:Connect(function(c)
        task.wait(1.5)
        if Cfg.Skin.Enabled then ApplyBodySkin(Cfg.Skin.Preset) end
    end)
end)

-- ════════════════════════════════════════════════════════════════
-- RAINBOW
-- ════════════════════════════════════════════════════════════════
local hue = 0
RunService.Heartbeat:Connect(function(dt)
    hue = (hue + dt * Cfg.Rainbow.Speed) % 1
    local col = Color3.fromHSV(hue, 1, 1)
    if Cfg.Rainbow.Character then
        local char = GetMyChar()
        if char then
            for _, obj in ipairs(char:GetChildren()) do
                if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
                    pcall(function() obj:Destroy() end)
                end
            end
            for _, p in ipairs(char:GetDescendants()) do
                if (p:IsA("BasePart") or p:IsA("MeshPart")) and p.Name ~= "HumanoidRootPart" then
                    pcall(function()
                        p.Color = col
                        p.Material = Enum.Material.Neon
                        for _, child in ipairs(p:GetChildren()) do
                            if child:IsA("Texture") or child:IsA("Decal") then
                                if child.Name ~= "face" then
                                    pcall(function() child.Transparency = 1 end)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
    if Cfg.Rainbow.Weapon then
        for _, obj in ipairs(Camera:GetChildren()) do
            for _, p in ipairs(obj:GetDescendants()) do
                if p:IsA("BasePart") or p:IsA("MeshPart") then
                    pcall(function() p.Color = col; p.Material = Enum.Material.Neon end)
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
            Brightness=p.Brightness, Ambient=p.Ambient, OutdoorAmbient=p.OutdoorAmbient,
            FogEnd=p.FogEnd, ClockTime=p.ClockTime,
        }):Play()
    end)
end

-- ════════════════════════════════════════════════════════════════
-- WALLHACK (Highlight, AlwaysOnTop)
-- ════════════════════════════════════════════════════════════════
local WH_Active = {}

local function WH_Set(char, name, isEnemy)
    if WH_Active[name] then
        pcall(function() WH_Active[name]:Destroy() end)
        WH_Active[name] = nil
    end
    if not Cfg.Wallhack.Enabled or not char then return end
    local hl = Instance.new("Highlight")
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor           = isEnemy and Cfg.Wallhack.EnemyFill    or Cfg.Wallhack.TeamFill
    hl.OutlineColor        = isEnemy and Cfg.Wallhack.EnemyOutline or Cfg.Wallhack.TeamOutline
    hl.FillTransparency    = Cfg.Wallhack.FillTrans
    hl.OutlineTransparency = Cfg.Wallhack.OutlineTrans
    hl.Adornee             = char
    hl.Parent              = char
    WH_Active[name]        = hl
end

local function WH_ClearAll()
    for name, hl in pairs(WH_Active) do
        pcall(function() hl:Destroy() end)
    end
    WH_Active = {}
end

local function WH_Update()
    if not Cfg.Wallhack.Enabled then
        WH_ClearAll()
        return
    end

    local wanted = {}

    for _, e in ipairs(GetEnemies()) do
        if IsAlive(e.char) then
            wanted[e.name] = {char = e.char, isEnemy = true}
        end
    end

    for _, t in ipairs(GetTeammates()) do
        if IsAlive(t.char) then
            wanted[t.name] = {char = t.char, isEnemy = false}
        end
    end

    for name, info in pairs(wanted) do
        if not WH_Active[name] then
            WH_Set(info.char, name, info.isEnemy)
        end
    end

    for name, hl in pairs(WH_Active) do
        if not wanted[name] then
            pcall(function() hl:Destroy() end)
            WH_Active[name] = nil
        end
    end
end

-- ════════════════════════════════════════════════════════════════
-- ESP — Drawing API
-- ════════════════════════════════════════════════════════════════
local drawOK = false
pcall(function()
    local test = Drawing.new("Line")
    test:Remove()
    drawOK = true
end)

local ESPDrawings = {}

local function CreateESPDraw(playerName)
    if ESPDrawings[playerName] then return end
    local d = {}
    d.name = Drawing.new("Text")
    d.name.Size = 14; d.name.Center = true; d.name.Outline = true
    d.name.Font = Drawing.Fonts.Plex; d.name.Visible = false
    d.name.Color = Cfg.ESP.EnemyColor

    d.info = Drawing.new("Text")
    d.info.Size = 12; d.info.Center = true; d.info.Outline = true
    d.info.Font = Drawing.Fonts.Plex; d.info.Visible = false
    d.info.Color = Color3.fromRGB(210,210,210)

    d.hpBg = Drawing.new("Line")
    d.hpBg.Thickness = 4; d.hpBg.Visible = false
    d.hpBg.Color = Color3.fromRGB(20,20,20)

    d.hpFill = Drawing.new("Line")
    d.hpFill.Thickness = 3; d.hpFill.Visible = false
    d.hpFill.Color = Color3.fromRGB(50,220,80)

    d.boxTL = Drawing.new("Line"); d.boxTL.Thickness=1; d.boxTL.Visible=false; d.boxTL.Color=Cfg.ESP.EnemyColor
    d.boxTR = Drawing.new("Line"); d.boxTR.Thickness=1; d.boxTR.Visible=false; d.boxTR.Color=Cfg.ESP.EnemyColor
    d.boxBL = Drawing.new("Line"); d.boxBL.Thickness=1; d.boxBL.Visible=false; d.boxBL.Color=Cfg.ESP.EnemyColor
    d.boxBR = Drawing.new("Line"); d.boxBR.Thickness=1; d.boxBR.Visible=false; d.boxBR.Color=Cfg.ESP.EnemyColor

    d.tracer = Drawing.new("Line")
    d.tracer.Thickness = 1; d.tracer.Visible = false
    d.tracer.Color = Cfg.ESP.EnemyColor; d.tracer.Transparency = 0.5

    ESPDrawings[playerName] = d
end

local function HideESPDraw(d)
    if not d then return end
    pcall(function()
        d.name.Visible = false
        d.info.Visible = false
        d.hpBg.Visible = false
        d.hpFill.Visible = false
        d.boxTL.Visible = false; d.boxTR.Visible = false
        d.boxBL.Visible = false; d.boxBR.Visible = false
        d.tracer.Visible = false
    end)
end

local function RemoveESPDraw(playerName)
    local d = ESPDrawings[playerName]
    if not d then return end
    pcall(function()
        d.name:Remove(); d.info:Remove()
        d.hpBg:Remove(); d.hpFill:Remove()
        d.boxTL:Remove(); d.boxTR:Remove()
        d.boxBL:Remove(); d.boxBR:Remove()
        d.tracer:Remove()
    end)
    ESPDrawings[playerName] = nil
end

local function UpdateESP()
    if not drawOK then return end
    if not Cfg.ESP.Enabled then
        for name, d in pairs(ESPDrawings) do HideESPDraw(d) end
        return
    end

    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y)
    local enemies = GetEnemies()
    local activeNames = {}

    for _, e in ipairs(enemies) do
        activeNames[e.name] = true
        if not IsAlive(e.char) then
            HideESPDraw(ESPDrawings[e.name])
            continue
        end

        local headPos = GetHeadPos(e.char)
        local rootPos = GetRootPos(e.char)
        if not headPos or not rootPos then
            HideESPDraw(ESPDrawings[e.name])
            continue
        end

        local sp, onScreen = Camera:WorldToViewportPoint(headPos)
        local spFeet, _ = Camera:WorldToViewportPoint(rootPos - Vector3.new(0, 3, 0))

        if not onScreen then
            HideESPDraw(ESPDrawings[e.name])
            continue
        end

        local dist = GetDist(e.char)
        if dist > Cfg.ESP.MaxDist then
            HideESPDraw(ESPDrawings[e.name])
            continue
        end

        CreateESPDraw(e.name)
        local d = ESPDrawings[e.name]
        if not d then continue end

        local hp, maxHp = GetHP(e.char)
        local hpRatio = math.clamp(hp / math.max(maxHp, 1), 0, 1)
        local screenHead = Vector2.new(sp.X, sp.Y)
        local screenFeet = Vector2.new(spFeet.X, spFeet.Y)
        local boxH = math.abs(screenFeet.Y - screenHead.Y)
        local boxW = boxH * 0.55

        if Cfg.ESP.Name then
            d.name.Text = e.name
            d.name.Position = Vector2.new(sp.X, sp.Y - 18)
            d.name.Color = Cfg.ESP.EnemyColor
            d.name.Visible = true
        else
            d.name.Visible = false
        end

        local infoText = ""
        if Cfg.ESP.Distance then
            infoText = string.format("[%.0fm]", dist)
        end
        if Cfg.ESP.Health then
            if infoText ~= "" then infoText = infoText .. " " end
            infoText = infoText .. string.format("HP:%.0f", hp)
        end
        if infoText ~= "" then
            d.info.Text = infoText
            d.info.Position = Vector2.new(sp.X, sp.Y - 5)
            d.info.Visible = true
        else
            d.info.Visible = false
        end

        if Cfg.ESP.Health then
            local barX = sp.X - boxW/2 - 6
            local barTop = screenHead.Y
            local barBot = screenFeet.Y
            d.hpBg.From = Vector2.new(barX, barTop)
            d.hpBg.To   = Vector2.new(barX, barBot)
            d.hpBg.Visible = true
            local fillBot = barBot - (barBot - barTop) * hpRatio
            d.hpFill.From = Vector2.new(barX, barBot)
            d.hpFill.To   = Vector2.new(barX, fillBot)
            d.hpFill.Color = Color3.fromRGB(
                math.floor((1-hpRatio)*255),
                math.floor(hpRatio*220), 0)
            d.hpFill.Visible = true
        else
            d.hpBg.Visible = false
            d.hpFill.Visible = false
        end

        local topL = Vector2.new(sp.X - boxW/2, screenHead.Y)
        local topR = Vector2.new(sp.X + boxW/2, screenHead.Y)
        local botL = Vector2.new(sp.X - boxW/2, screenFeet.Y)
        local botR = Vector2.new(sp.X + boxW/2, screenFeet.Y)

        d.boxTL.From=topL; d.boxTL.To=topR; d.boxTL.Color=Cfg.ESP.EnemyColor; d.boxTL.Visible=true
        d.boxTR.From=topR; d.boxTR.To=botR; d.boxTR.Color=Cfg.ESP.EnemyColor; d.boxTR.Visible=true
        d.boxBL.From=botL; d.boxBL.To=botR; d.boxBL.Color=Cfg.ESP.EnemyColor; d.boxBL.Visible=true
        d.boxBR.From=topL; d.boxBR.To=botL; d.boxBR.Color=Cfg.ESP.EnemyColor; d.boxBR.Visible=true

        d.tracer.From = center
        d.tracer.To   = Vector2.new(spFeet.X, spFeet.Y)
        d.tracer.Color = Cfg.ESP.EnemyColor
        d.tracer.Visible = true
    end

    for name, d in pairs(ESPDrawings) do
        if not activeNames[name] then HideESPDraw(d) end
    end
end

-- ════════════════════════════════════════════════════════════════
-- AIMBOT
-- ════════════════════════════════════════════════════════════════
local function GetTarget()
    local best, bestD = nil, Cfg.Aimbot.FOV
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    for _, e in ipairs(GetEnemies()) do
        if not IsAlive(e.char) then continue end
        local part = e.char:FindFirstChild(Cfg.Aimbot.Part)
                  or e.char:FindFirstChild("Head")
                  or e.char:FindFirstChild("HumanoidRootPart")
                  or e.char:FindFirstChildWhichIsA("BasePart")
        if not part then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d < bestD then bestD=d; best={pos=part.Position} end
    end
    return best
end

-- ════════════════════════════════════════════════════════════════
-- FOV ÇEMBER + RADAR
-- ════════════════════════════════════════════════════════════════
local fovOK, fovC = false, nil
pcall(function()
    fovC = Drawing.new("Circle")
    fovC.Visible=false; fovC.Radius=Cfg.Aimbot.FOV; fovC.Thickness=1.8
    fovC.Filled=false; fovC.NumSides=80; fovC.Color=Color3.fromRGB(160,60,255)
    fovOK = true
end)

local radOK = false
local rBG, rBD, rSelf, rLbl = nil, nil, nil, nil
pcall(function()
    rBG   = Drawing.new("Square"); rBG.Filled=true; rBG.Color=Color3.fromRGB(6,6,12); rBG.Transparency=0.38; rBG.Visible=false
    rBD   = Drawing.new("Square"); rBD.Filled=false; rBD.Thickness=1.5; rBD.Color=Color3.fromRGB(140,50,255); rBD.Visible=false
    rSelf = Drawing.new("Circle"); rSelf.Filled=true; rSelf.Radius=4; rSelf.NumSides=8; rSelf.Color=Color3.fromRGB(80,180,255); rSelf.Visible=false
    rLbl  = Drawing.new("Text"); rLbl.Text="RADAR"; rLbl.Size=9; rLbl.Center=true; rLbl.Outline=true
           rLbl.Color=Color3.fromRGB(140,50,255); rLbl.Font=Drawing.Fonts.Plex; rLbl.Visible=false
    radOK = true
end)

local rDots = {}

-- ════════════════════════════════════════════════════════════════
-- NO RECOIL
-- ════════════════════════════════════════════════════════════════
local lastCF = Camera.CFrame
local function DoNoRecoil()
    pcall(function()
        if not Cfg.NoRecoil.Enabled then lastCF=Camera.CFrame; return end
        local cur = Camera.CFrame
        local lp  = math.asin(math.clamp(lastCF.LookVector.Y, -1, 1))
        local cp  = math.asin(math.clamp(cur.LookVector.Y,    -1, 1))
        if cp-lp > 0.002 then
            Camera.CFrame = cur * CFrame.Angles(-(cp-lp)*Cfg.NoRecoil.Strength, 0, 0)
        end
        lastCF = Camera.CFrame
    end)
end

-- ════════════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    pcall(function()
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)

        if fovOK and fovC then
            fovC.Position = center
            fovC.Radius   = Cfg.Aimbot.FOV
            fovC.Visible  = Cfg.Aimbot.Enabled and Cfg.Aimbot.ShowFOV
        end

        if Cfg.Aimbot.Enabled and UIS:IsKeyDown(Cfg.Aimbot.Key) then
            local t = GetTarget()
            if t then
                local cur = Camera.CFrame
                Camera.CFrame = cur:Lerp(CFrame.lookAt(cur.Position, t.pos), Cfg.Aimbot.Smooth)
            end
        end

        DoNoRecoil()
        UpdateESP()
        WH_Update()

        if Cfg.BigHead.Enabled then ApplyBigHeadToEnemies() end

        if radOK and Cfg.Radar.Enabled then
            local rs = Cfg.Radar.Size
            local rx = 20
            local ry = vp.Y - 20 - rs
            rBG.Size=Vector2.new(rs,rs); rBG.Position=Vector2.new(rx,ry); rBG.Visible=true
            rBD.Size=Vector2.new(rs,rs); rBD.Position=Vector2.new(rx,ry); rBD.Visible=true
            rSelf.Position=Vector2.new(rx+rs/2, ry+rs/2); rSelf.Visible=true
            rLbl.Position=Vector2.new(rx+rs/2, ry+rs+2); rLbl.Visible=true

            local myChar = GetMyChar()
            local lr = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head"))
            local lCF = lr and lr.CFrame or CFrame.new()

            for _,rd in pairs(rDots) do pcall(function() rd:Remove() end) end
            rDots = {}

            for _, e in ipairs(GetEnemies()) do
                pcall(function()
                    if not IsAlive(e.char) then return end
                    local r2 = e.char:FindFirstChild("HumanoidRootPart") or e.char:FindFirstChild("Head")
                             or e.char:FindFirstChildWhichIsA("BasePart")
                    if not r2 then return end
                    local rel = lCF:PointToObjectSpace(r2.Position)
                    local nx = rel.X / Cfg.Radar.Range
                    local nz = rel.Z / Cfg.Radar.Range
                    if math.abs(nx)>1 or math.abs(nz)>1 then return end
                    local dot = Drawing.new("Circle")
                    dot.Filled=true; dot.Radius=4; dot.NumSides=8
                    dot.Color = Cfg.ESP.EnemyColor
                    dot.Position = Vector2.new(
                        rx + rs/2 + nx * (rs/2) * Cfg.Radar.Scale,
                        ry + rs/2 - nz * (rs/2) * Cfg.Radar.Scale)
                    dot.Visible = true
                    table.insert(rDots, dot)
                end)
            end

            for _, t in ipairs(GetTeammates()) do
                pcall(function()
                    if not IsAlive(t.char) then return end
                    local r2 = t.char:FindFirstChild("HumanoidRootPart") or t.char:FindFirstChild("Head")
                             or t.char:FindFirstChildWhichIsA("BasePart")
                    if not r2 then return end
                    local rel = lCF:PointToObjectSpace(r2.Position)
                    local nx = rel.X / Cfg.Radar.Range
                    local nz = rel.Z / Cfg.Radar.Range
                    if math.abs(nx)>1 or math.abs(nz)>1 then return end
                    local dot = Drawing.new("Circle")
                    dot.Filled=true; dot.Radius=3; dot.NumSides=8
                    dot.Color = Cfg.ESP.TeamColor
                    dot.Position = Vector2.new(
                        rx + rs/2 + nx * (rs/2) * Cfg.Radar.Scale,
                        ry + rs/2 - nz * (rs/2) * Cfg.Radar.Scale)
                    dot.Visible = true
                    table.insert(rDots, dot)
                end)
            end
        elseif radOK then
            if rBG then rBG.Visible=false; rBD.Visible=false; rSelf.Visible=false; rLbl.Visible=false end
            for _,rd in pairs(rDots) do pcall(function() rd:Remove() end) end
            rDots = {}
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════════════
local P1 = Color3.fromRGB(140,50,255)
local P2 = Color3.fromRGB(85,22,175)
local D1 = Color3.fromRGB(9,7,16)
local D2 = Color3.fromRGB(15,11,26)
local D3 = Color3.fromRGB(21,16,36)
local TX = Color3.fromRGB(225,215,255)
local TXD= Color3.fromRGB(140,120,190)
local GREEN = Color3.fromRGB(60,220,100)

local SG = Instance.new("ScreenGui")
SG.Name="BSv10"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = LP.PlayerGui end

local MF = Instance.new("Frame")
MF.Size=UDim2.new(0,285,0,520); MF.Position=UDim2.new(0,12,0.5,-260)
MF.BackgroundColor3=D1; MF.BorderSizePixel=0; MF.Active=true; MF.Draggable=true
MF.Visible=false; MF.Parent=SG
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,12)
local mS=Instance.new("UIStroke",MF); mS.Color=P1; mS.Thickness=1.8

local Hdr=Instance.new("Frame"); Hdr.Size=UDim2.new(1,0,0,52); Hdr.BackgroundColor3=D2; Hdr.BorderSizePixel=0; Hdr.Parent=MF
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,12)
local HFix=Instance.new("Frame"); HFix.Size=UDim2.new(1,0,0.5,0); HFix.Position=UDim2.new(0,0,0.5,0); HFix.BackgroundColor3=D2; HFix.BorderSizePixel=0; HFix.Parent=Hdr
local HA=Instance.new("Frame"); HA.Size=UDim2.new(0,4,0.6,0); HA.Position=UDim2.new(0,9,0.2,0); HA.BackgroundColor3=P1; HA.BorderSizePixel=0; HA.Parent=Hdr; Instance.new("UICorner",HA).CornerRadius=UDim.new(1,0)
local HT=Instance.new("TextLabel"); HT.Size=UDim2.new(1,-20,0,24); HT.Position=UDim2.new(0,20,0,5); HT.BackgroundTransparency=1; HT.Text="BLOXSTRIKE ULTRA  v10.0"; HT.TextColor3=TX; HT.Font=Enum.Font.GothamBold; HT.TextSize=14; HT.TextXAlignment=Enum.TextXAlignment.Left; HT.Parent=Hdr
local HS=Instance.new("TextLabel"); HS.Size=UDim2.new(1,-20,0,14); HS.Position=UDim2.new(0,20,0,32); HS.BackgroundTransparency=1; HS.Text="RightShift = Menü  ·  E = Aimbot"; HS.TextColor3=TXD; HS.Font=Enum.Font.Gotham; HS.TextSize=10; HS.TextXAlignment=Enum.TextXAlignment.Left; HS.Parent=Hdr

local Sc=Instance.new("ScrollingFrame"); Sc.Size=UDim2.new(1,-8,1,-60); Sc.Position=UDim2.new(0,4,0,56)
Sc.BackgroundTransparency=1; Sc.BorderSizePixel=0; Sc.ScrollBarThickness=3; Sc.ScrollBarImageColor3=P1
Sc.CanvasSize=UDim2.new(0,0,0,0); Sc.AutomaticCanvasSize=Enum.AutomaticSize.Y; Sc.Parent=MF
local ScL=Instance.new("UIListLayout"); ScL.Parent=Sc; ScL.SortOrder=Enum.SortOrder.LayoutOrder; ScL.Padding=UDim.new(0,5)
local ScP=Instance.new("UIPadding"); ScP.PaddingLeft=UDim.new(0,3); ScP.PaddingRight=UDim.new(0,3); ScP.PaddingTop=UDim.new(0,4); ScP.PaddingBottom=UDim.new(0,8); ScP.Parent=Sc

local so = 0
local function Sec(title, emoji)
    so=so+1
    local sec=Instance.new("Frame"); sec.Size=UDim2.new(1,-4,0,40); sec.BackgroundColor3=D3; sec.BorderSizePixel=0; sec.LayoutOrder=so; sec.AutomaticSize=Enum.AutomaticSize.Y; sec.ClipsDescendants=true; sec.Parent=Sc
    Instance.new("UICorner",sec).CornerRadius=UDim.new(0,9); Instance.new("UIStroke",sec).Color=P2
    local hb=Instance.new("TextButton"); hb.Size=UDim2.new(1,0,0,40); hb.BackgroundColor3=D2; hb.BorderSizePixel=0; hb.Text=""; hb.AutoButtonColor=false; hb.ZIndex=2; hb.Parent=sec
    Instance.new("UICorner",hb).CornerRadius=UDim.new(0,9)
    local al=Instance.new("Frame"); al.Size=UDim2.new(0,3,0.55,0); al.Position=UDim2.new(0,7,0.225,0); al.BackgroundColor3=P1; al.BorderSizePixel=0; al.ZIndex=3; al.Parent=hb; Instance.new("UICorner",al).CornerRadius=UDim.new(1,0)
    local tl=Instance.new("TextLabel"); tl.Size=UDim2.new(1,-46,1,0); tl.Position=UDim2.new(0,17,0,0); tl.BackgroundTransparency=1; tl.Text=emoji.."  "..title; tl.TextColor3=TX; tl.Font=Enum.Font.GothamBold; tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=3; tl.Parent=hb
    local ar=Instance.new("TextLabel"); ar.Size=UDim2.new(0,26,0,26); ar.Position=UDim2.new(1,-30,0.5,-13); ar.BackgroundTransparency=1; ar.Text="▾"; ar.TextColor3=P1; ar.Font=Enum.Font.GothamBold; ar.TextSize=15; ar.ZIndex=3; ar.Parent=hb
    local cont=Instance.new("Frame"); cont.Size=UDim2.new(1,0,0,0); cont.Position=UDim2.new(0,0,0,40); cont.BackgroundTransparency=1; cont.BorderSizePixel=0; cont.AutomaticSize=Enum.AutomaticSize.Y; cont.Visible=false; cont.Parent=sec
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

local io = 0
local function Tog(parent, lbl, def, cb)
    io=io+1
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=D1; row.BorderSizePixel=0; row.LayoutOrder=io; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-65,1,0); l.Position=UDim2.new(0,10,0,0); l.BackgroundTransparency=1; l.Text=lbl; l.TextColor3=TX; l.Font=Enum.Font.Gotham; l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=row
    local state=def
    local tr=Instance.new("Frame"); tr.Size=UDim2.new(0,44,0,22); tr.Position=UDim2.new(1,-52,0.5,-11); tr.BackgroundColor3=state and P1 or Color3.fromRGB(36,26,56); tr.BorderSizePixel=0; tr.Parent=row
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
    local kn=Instance.new("Frame"); kn.Size=UDim2.new(0,18,0,18); kn.BorderSizePixel=0; kn.Position=UDim2.new(state and 1 or 0,state and -20 or 2,0.5,-9); kn.BackgroundColor3=Color3.fromRGB(255,255,255); kn.Parent=tr
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,1,0); b.BackgroundTransparency=1; b.Text=""; b.Parent=row
    b.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(tr,TweenInfo.new(0.18),{BackgroundColor3=state and P1 or Color3.fromRGB(36,26,56)}):Play()
        TweenService:Create(kn,TweenInfo.new(0.18),{Position=UDim2.new(state and 1 or 0,state and -20 or 2,0.5,-9)}):Play()
        cb(state)
    end)
end

local function Btn(parent, lbl, cb)
    io=io+1
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,30); b.LayoutOrder=io; b.BackgroundColor3=P2; b.BorderSizePixel=0; b.Text=lbl; b.TextColor3=TX; b.Font=Enum.Font.GothamBold; b.TextSize=11; b.Parent=parent
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=P1}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=P2}):Play() end)
    b.MouseButton1Click:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.07),{BackgroundColor3=Color3.fromRGB(190,110,255)}):Play()
        task.delay(0.15, function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=P2}):Play() end)
        cb()
    end)
end

local function Div(parent, txt)
    io=io+1
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,0,18); l.LayoutOrder=io; l.BackgroundTransparency=1; l.Text="── "..txt.." ──"; l.TextColor3=TXD; l.Font=Enum.Font.GothamBold; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Center; l.Parent=parent
end

local function KeyBind(parent, lbl, getK, setK)
    io=io+1
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=D1; row.BorderSizePixel=0; row.LayoutOrder=io; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(0.58,0,1,0); l.Position=UDim2.new(0,10,0,0); l.BackgroundTransparency=1; l.Text=lbl; l.TextColor3=TX; l.Font=Enum.Font.Gotham; l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=row
    local kb=Instance.new("TextButton"); kb.Size=UDim2.new(0,78,0,22); kb.Position=UDim2.new(1,-86,0.5,-11); kb.BackgroundColor3=P2; kb.BorderSizePixel=0; kb.Font=Enum.Font.GothamBold; kb.TextSize=11; kb.TextColor3=TX; kb.Text="["..getK().Name.."]"; kb.Parent=row
    Instance.new("UICorner",kb).CornerRadius=UDim.new(0,5)
    local on=false
    kb.MouseButton1Click:Connect(function()
        if on then return end; on=true; kb.Text="Bas..."; kb.BackgroundColor3=Color3.fromRGB(200,90,20)
        task.spawn(function()
            local t=tick()+6
            while on and tick()<t do
                for _,key in ipairs(Enum.KeyCode:GetEnumItems()) do
                    local ok,dn=pcall(function() return UIS:IsKeyDown(key) end)
                    if ok and dn then
                        local n=key.Name
                        if n~="RightShift" and n~="LeftShift" and n~="Unknown" then
                            pcall(function() setK(key) end); kb.Text="["..key.Name.."]"
                            kb.BackgroundColor3=P2; on=false; task.wait(0.4); break
                        end
                    end
                end
                task.wait(0.06)
            end
            if on then kb.Text="["..getK().Name.."]"; kb.BackgroundColor3=P2; on=false end
        end)
    end)
end

-- ═══ BÖLÜMLER ═══
local SAim = Sec("Aimbot","🎯")
Tog(SAim,"Aimbot Aktif",Cfg.Aimbot.Enabled,function(v) Cfg.Aimbot.Enabled=v end)
Tog(SAim,"FOV Çemberi",Cfg.Aimbot.ShowFOV,function(v) Cfg.Aimbot.ShowFOV=v end)
Tog(SAim,"No Recoil",Cfg.NoRecoil.Enabled,function(v) Cfg.NoRecoil.Enabled=v end)
Div(SAim,"Aim Tuşu")
KeyBind(SAim,"Aim Tuşu",function() return Cfg.Aimbot.Key end,function(k) Cfg.Aimbot.Key=k end)

local SEsp = Sec("ESP","👁")
Tog(SEsp,"ESP Aktif",Cfg.ESP.Enabled,function(v) Cfg.ESP.Enabled=v end)
Tog(SEsp,"İsim",Cfg.ESP.Name,function(v) Cfg.ESP.Name=v end)
Tog(SEsp,"Mesafe",Cfg.ESP.Distance,function(v) Cfg.ESP.Distance=v end)
Tog(SEsp,"HP Bar",Cfg.ESP.Health,function(v) Cfg.ESP.Health=v end)

local SWH = Sec("Wallhack","🧱")
Tog(SWH,"Wallhack (Duvardan Gör)",Cfg.Wallhack.Enabled,function(v)
    Cfg.Wallhack.Enabled = v
    if not v then WH_ClearAll() end
end)

local SRad = Sec("Radar","📡")
Tog(SRad,"Mini Radar",Cfg.Radar.Enabled,function(v)
    Cfg.Radar.Enabled=v
    if not v and radOK then
        if rBG then rBG.Visible=false; rBD.Visible=false; rSelf.Visible=false; rLbl.Visible=false end
        for _,rd in pairs(rDots) do pcall(function() rd:Remove() end) end
        rDots = {}
    end
end)

local SLit = Sec("Lighting","🌍")
Btn(SLit,"☀️  Gündüz",function() SetLight("Day") end)
Btn(SLit,"🌙  Gece",function() SetLight("Night") end)
Btn(SLit,"🌅  Gün Batımı",function() SetLight("Sunset") end)
Btn(SLit,"🌫️  Sisli",function() SetLight("Fog") end)
Btn(SLit,"🟣  Neon Mor",function() SetLight("Neon") end)
Btn(SLit,"🔄  Normal",function() SetLight("Normal") end)

local SRain = Sec("Rainbow Mod","🌈")
Tog(SRain,"Rainbow Karakter",Cfg.Rainbow.Character,function(v) Cfg.Rainbow.Character=v end)
Tog(SRain,"Rainbow Silah",Cfg.Rainbow.Weapon,function(v) Cfg.Rainbow.Weapon=v end)

local SSkin = Sec("Skin Changer","🎨")
Tog(SSkin,"Skin Aktif",Cfg.Skin.Enabled,function(v) Cfg.Skin.Enabled=v; if v then ApplyBodySkin() end end)
Div(SSkin,"Renk Presetleri")
for _, sk in ipairs({
    {"TacticalBlack","⬛  Tactical Black"},{"Ghost","👻  Ghost (Beyaz)"},
    {"Desert","🟡  Desert (Kum)"},{"Stealth","🖤  Stealth"},
    {"Purple","🟣  Purple"},{"NeonGreen","💚  Neon Yeşil"},
    {"Red","🔴  Red"},{"Navy","🔵  Navy Blue"},{"Orange","🟠  Orange"},{"Gold","🟡  Gold"},
}) do
    Btn(SSkin,sk[2],function()
        Cfg.Skin.Preset=sk[1]; Cfg.Skin.Enabled=true; Cfg.Rainbow.Character=false
        ApplyBodySkin(sk[1])
    end)
end

local SKnife = Sec("Knife Skin","🔪")
for _, k in ipairs(KnifeNames) do
    Btn(SKnife,"🔪  "..k,function() ApplyKnifeSkin(k) end)
end

local SBH = Sec("Big Head","🦣")
Tog(SBH,"Big Head (Düşman)",Cfg.BigHead.Enabled,function(v)
    Cfg.BigHead.Enabled=v
    if not v then ResetBigHead() end
end)
Btn(SBH,"S (2x)",function() Cfg.BigHead.Scale=2 end)
Btn(SBH,"M (3.5x)",function() Cfg.BigHead.Scale=3.5 end)
Btn(SBH,"L (5x)",function() Cfg.BigHead.Scale=5 end)
Btn(SBH,"XL (8x)",function() Cfg.BigHead.Scale=8 end)

local SSet = Sec("Ayarları Kaydet","💾")
Btn(SSet,"💾  Ayarları Kaydet",function()
    SaveSettings(Cfg)
    local nf=Instance.new("Frame"); nf.Size=UDim2.new(0,250,0,38); nf.Position=UDim2.new(0.5,-125,0,-50); nf.BackgroundColor3=Color3.fromRGB(20,80,30); nf.BorderSizePixel=0; nf.Parent=SG
    Instance.new("UICorner",nf).CornerRadius=UDim.new(0,8)
    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,1,0); nl.BackgroundTransparency=1; nl.Text="✅  Ayarlar kaydedildi!"; nl.TextColor3=Color3.fromRGB(100,255,120); nl.Font=Enum.Font.GothamBold; nl.TextSize=12; nl.Parent=nf
    TweenService:Create(nf,TweenInfo.new(0.3,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-125,0,14)}):Play()
    task.delay(2.5,function() TweenService:Create(nf,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-125,0,-55)}):Play(); task.delay(0.35,function() pcall(function() nf:Destroy() end) end) end)
end)
Btn(SSet,"🔄  Varsayılana Sıfırla",function() pcall(function() delfile(SAVE_FILE) end) end)

-- Menü toggle
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then MF.Visible = not MF.Visible end
end)

-- Bildirim fonksiyonu
local function Notif(msg, dur, col)
    pcall(function()
        local nf=Instance.new("Frame"); nf.Size=UDim2.new(0,320,0,46); nf.Position=UDim2.new(0.5,-160,0,-60); nf.BackgroundColor3=D2; nf.BorderSizePixel=0; nf.Parent=SG
        Instance.new("UICorner",nf).CornerRadius=UDim.new(0,10)
        Instance.new("UIStroke",nf).Color=col or P1
        local acc=Instance.new("Frame"); acc.Size=UDim2.new(0,3,0.65,0); acc.Position=UDim2.new(0,9,0.175,0); acc.BackgroundColor3=col or P1; acc.BorderSizePixel=0; acc.Parent=nf; Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
        local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,-20,1,0); nl.Position=UDim2.new(0,18,0,0); nl.BackgroundTransparency=1; nl.Text=msg; nl.TextColor3=TX; nl.Font=Enum.Font.GothamBold; nl.TextSize=12; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=nf
        TweenService:Create(nf,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-160,0,14)}):Play()
        task.delay(dur or 4, function()
            TweenService:Create(nf,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-160,0,-65)}):Play()
            task.delay(0.35, function() pcall(function() nf:Destroy() end) end)
        end)
    end)
end

task.delay(1.5, function()
    Notif("⚡ BloxStrike Ultra v10  |  Drawing ESP  |  RShift=Menü", 4, P1)
    if saved then
        task.delay(4.5, function() Notif("💾 Önceki ayarlar yüklendi!", 3, GREEN) end)
    end
end)

task.delay(8, function()
    local team = GetMyTeam()
    local myChar = GetMyChar()
    local enemies = GetEnemies()
    Notif("✅ Takım: "..(team or "?").."  |  Düşman: "..#enemies.."  |  Char: "..(myChar and "✅" or "❌"), 5, GREEN)
end)

task.spawn(function()
    task.wait(3)
    if Cfg.Skin.Enabled then ApplyBodySkin(Cfg.Skin.Preset) end
end)

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "BSv10" then
        for name, d in pairs(ESPDrawings) do RemoveESPDraw(name) end
        WH_ClearAll()
        if fovC then pcall(function() fovC:Remove() end) end
        for _,rd in pairs(rDots) do pcall(function() rd:Remove() end) end
        if rBG then pcall(function() rBG:Remove(); rBD:Remove(); rSelf:Remove(); rLbl:Remove() end) end
    end
end)

print("[BSUltra v10] ✅ Wallhack entegre — Chams kaldırıldı")
print("[v10] Takım:", GetMyTeam(), "| Char:", GetMyChar() and "✅" or "❌")
