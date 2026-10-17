-- ╔══════════════════════════════════════════════════════════════╗
-- ║     BLOXSTRIKE ULTRA v9.0  |  Fixed Build                  ║
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
            ChamsEnabled = cfg.Chams.Enabled, RadarEnabled = cfg.Radar.Enabled,
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
    Chams    = { Enabled=false, Color=Color3.fromRGB(220,50,50), Trans=0.4 },
    BigHead  = { Enabled=false, Scale=3.5 },
}

local saved = LoadSettings()
if saved then
    pcall(function()
        Cfg.Aimbot.Enabled   = saved.AimbotEnabled
        Cfg.Aimbot.FOV       = saved.AimbotFOV or 200
        Cfg.Aimbot.Smooth    = saved.AimbotSmooth or 0.15
        Cfg.Aimbot.ShowFOV   = saved.ShowFOV
        Cfg.NoRecoil.Enabled = saved.NoRecoil
        Cfg.ESP.Enabled      = saved.ESPEnabled
        Cfg.ESP.Name         = saved.ESPName
        Cfg.ESP.Distance     = saved.ESPDist
        Cfg.ESP.Health       = saved.ESPHealth
        Cfg.Chams.Enabled    = saved.ChamsEnabled
        Cfg.Radar.Enabled    = saved.RadarEnabled
        Cfg.Skin.Enabled     = saved.SkinEnabled
        Cfg.Skin.Preset      = saved.SkinPreset or "TacticalBlack"
        Cfg.Rainbow.Character= saved.RainbowChar
        Cfg.Rainbow.Weapon   = saved.RainbowWeapon
        Cfg.BigHead.Enabled  = saved.BigHead
        Cfg.BigHead.Scale    = saved.BigHeadScale or 3.5
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

-- workspace.Characters klasörünü bekle
task.spawn(function()
    CharFolder = workspace:WaitForChild("Characters", 20)
    if CharFolder then
        TFolder  = CharFolder:WaitForChild("Terrorists", 10)
        CTFolder = CharFolder:WaitForChild("Counter-Terrorists", 10)
        print("[v9] workspace.Characters bulundu ✅")
        print("[v9] T:", TFolder and "✅" or "❌", "CT:", CTFolder and "✅" or "❌")
    else
        print("[v9] workspace.Characters yok — standart Players modu")
    end
end)

-- LP'nin kendi karakterini döndür (BloxStrike'ta LP.Character nil olabilir)
local function GetMyChar()
    -- Önce standart yolu dene
    local c = LP.Character
    if c and c.Parent then return c end
    -- workspace.Characters altında ara
    if TFolder then
        local f = TFolder:FindFirstChild(LP.Name)
        if f then return f end
    end
    if CTFolder then
        local f = CTFolder:FindFirstChild(LP.Name)
        if f then return f end
    end
    -- Fallback: tüm Players
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP and p.Character then return p.Character end
    end
    return nil
end

-- LP'nin hangi takımda olduğunu döndür
local function GetMyTeam()
    -- LP.TeamColor / LP.Team dene
    if LP.Team then
        local tn = LP.Team.Name
        if tn:lower():find("terror") then return "T"
        elseif tn:lower():find("counter") then return "CT"
        end
    end
    -- workspace.Characters klasörlerine bak
    if TFolder and TFolder:FindFirstChild(LP.Name) then return "T" end
    if CTFolder and CTFolder:FindFirstChild(LP.Name) then return "CT" end
    return nil
end

-- Tüm düşmanları döndür
local function GetEnemies()
    local myTeam = GetMyTeam()
    local list = {}

    if TFolder and CTFolder then
        local function scan(folder, team)
            if not folder then return end
            for _, char in ipairs(folder:GetChildren()) do
                -- Kendi karakterimizi atla
                if char.Name ~= LP.Name then
                    -- Eğer takım tespiti yapılabiliyorsa sadece düşmanları al
                    if myTeam == nil or team ~= myTeam then
                        table.insert(list, {char=char, name=char.Name, team=team})
                    end
                end
            end
        end

        if myTeam == "T" then
            scan(CTFolder, "CT")
        elseif myTeam == "CT" then
            scan(TFolder, "T")
        else
            -- Takım tespit edilemedi — herkesi ekle (kendi hariç)
            scan(TFolder, "T")
            scan(CTFolder, "CT")
        end
    else
        -- Fallback: Players listesi
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                -- Team kontrolü
                local sameTeam = false
                if LP.Team and p.Team and LP.Team == p.Team then
                    sameTeam = true
                end
                if not sameTeam then
                    local char = p.Character
                    if char then
                        table.insert(list, {char=char, name=p.Name, team="?"})
                    end
                end
            end
        end
    end
    return list
end

local function IsAlive(char)
    if not char or not char.Parent then return false end
    local h = char:FindFirstChildOfClass("Humanoid")
    return h ~= nil and h.Health > 0
end

-- Mesafeyi hesapla — LP karakter nil olsa bile çalışır
local function GetDist(char)
    local myChar = GetMyChar()
    if not myChar then return 0 end  -- nil ise 0 döndür (göster)
    local lr = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head")
    local r  = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not lr or not r then return 0 end
    return (r.Position - lr.Position).Magnitude
end

-- ════════════════════════════════════════════════════════════════
-- BIG HEAD
-- ════════════════════════════════════════════════════════════════
local bigHeadConns = {}

local function ApplyBigHead(char, scale)
    if not char then return end
    pcall(function()
        local head = char:FindFirstChild("Head")
        if not head then return end
        local mesh = head:FindFirstChildOfClass("SpecialMesh")
        if not mesh then
            mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.Head
            mesh.Parent = head
        end
        mesh.Scale = Vector3.new(scale, scale, scale)
    end)
end

local function ApplyBigHeadAll(enable)
    for _, c in pairs(bigHeadConns) do pcall(function() c:Disconnect() end) end
    bigHeadConns = {}
    if not enable then
        local myChar = GetMyChar()
        if myChar then
            local head = myChar:FindFirstChild("Head")
            if head then
                local mesh = head:FindFirstChildOfClass("SpecialMesh")
                if mesh then mesh.Scale = Vector3.new(1,1,1) end
            end
        end
        return
    end
    local myChar = GetMyChar()
    if myChar then ApplyBigHead(myChar, Cfg.BigHead.Scale) end
    local conn = LP.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        if Cfg.BigHead.Enabled then ApplyBigHead(c, Cfg.BigHead.Scale) end
    end)
    table.insert(bigHeadConns, conn)
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
        end
        local oldSkin = existingKnife:FindFirstChild("_SkinKnife")
        if oldSkin then oldSkin:Destroy() end
        local newKnife = knifeAsset:Clone()
        newKnife.Name = "_SkinKnife"
        newKnife.Parent = existingKnife
        local root = existingKnife:FindFirstChild("Handle") or existingKnife.PrimaryPart
        if root and newKnife.PrimaryPart then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = root; weld.Part1 = newKnife.PrimaryPart
            weld.Parent = newKnife
        end
    end)
end

local BodyPresets = {
    TacticalBlack = {body="Really black",     face="Pastel brown"},
    Ghost         = {body="White",            face="White"},
    Desert        = {body="Sand yellow",      face="Pastel brown"},
    Stealth       = {body="Really black",     face="Really black"},
    Purple        = {body="Dark indigo",      face="Pastel brown"},
    NeonGreen     = {body="Lime green",       face="Pastel brown"},
    Red           = {body="Really red",       face="Pastel brown"},
    Navy          = {body="Navy blue",        face="Pastel brown"},
    Orange        = {body="Bright orange",    face="Pastel brown"},
    Gold          = {body="Bright yellow",    face="Pastel brown"},
}

local function ApplyBodySkin(presetName)
    local char = GetMyChar()
    if not char then return end
    local preset = BodyPresets[presetName or Cfg.Skin.Preset]
    if not preset then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function()
                if part.Name == "Head" then part.BrickColor = BrickColor.new(preset.face)
                else part.BrickColor = BrickColor.new(preset.body) end
                part.Material = Enum.Material.SmoothPlastic
            end)
        end
    end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") then
            pcall(function() obj:Destroy() end)
        end
    end
end

LP.CharacterAdded:Connect(function(c)
    task.wait(1.5)
    if Cfg.Skin.Enabled then ApplyBodySkin(Cfg.Skin.Preset) end
    if Cfg.BigHead.Enabled then ApplyBigHead(c, Cfg.BigHead.Scale) end
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
            for _, p in ipairs(char:GetDescendants()) do
                if (p:IsA("BasePart") or p:IsA("MeshPart")) and p.Name ~= "HumanoidRootPart" then
                    pcall(function() p.Color = col end)
                end
            end
        end
    end
    if Cfg.Rainbow.Weapon then
        for _, obj in ipairs(Camera:GetChildren()) do
            for _, p in ipairs(obj:GetDescendants()) do
                if p:IsA("BasePart") or p:IsA("MeshPart") then
                    pcall(function() p.Color = col end)
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
-- CHAMS
-- ════════════════════════════════════════════════════════════════
local CHL = {}
local function SetChams(char, id, on)
    if CHL[id] then pcall(function() CHL[id]:Destroy() end); CHL[id]=nil end
    if not on or not char then return end
    local hl = Instance.new("Highlight")
    hl.FillColor=Cfg.Chams.Color; hl.OutlineColor=Color3.fromRGB(255,255,255)
    hl.FillTransparency=Cfg.Chams.Trans; hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=char; hl.Parent=char
    CHL[id]=hl
end
local function RefreshChams()
    for id,h in pairs(CHL) do pcall(function() h:Destroy() end); CHL[id]=nil end
    if not Cfg.Chams.Enabled then return end
    for _, e in ipairs(GetEnemies()) do
        if IsAlive(e.char) then SetChams(e.char, e.name, true) end
    end
end

-- ════════════════════════════════════════════════════════════════
-- ESP — BillboardGui
-- ════════════════════════════════════════════════════════════════
local Boards = {}

local function BuildBoard(char, playerName)
    -- Eski board varsa temizle
    if Boards[playerName] then
        pcall(function() Boards[playerName].bb:Destroy() end)
        if Boards[playerName].conn then Boards[playerName].conn:Disconnect() end
        Boards[playerName] = nil
    end

    local head = char:WaitForChild("Head", 10)
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Adornee      = head
    bb.Size         = UDim2.new(0, 170, 0, 68)
    bb.StudsOffset  = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop  = true
    bb.ResetOnSpawn = false
    bb.LightInfluence= 0
    bb.Enabled      = true
    bb.Parent       = head

    -- İsim
    local nameL = Instance.new("TextLabel")
    nameL.Size=UDim2.new(1,0,0,24); nameL.Position=UDim2.new(0,0,0,0)
    nameL.BackgroundTransparency=1; nameL.Font=Enum.Font.GothamBold; nameL.TextSize=15
    nameL.TextStrokeTransparency=0; nameL.TextStrokeColor3=Color3.new(0,0,0)
    nameL.TextColor3=Cfg.ESP.EnemyColor; nameL.Text=playerName; nameL.Parent=bb

    -- HP yazı
    local hpL = Instance.new("TextLabel")
    hpL.Size=UDim2.new(1,0,0,18); hpL.Position=UDim2.new(0,0,0,24)
    hpL.BackgroundTransparency=1; hpL.Font=Enum.Font.Gotham; hpL.TextSize=12
    hpL.TextStrokeTransparency=0; hpL.TextStrokeColor3=Color3.new(0,0,0)
    hpL.TextColor3=Color3.fromRGB(210,210,210); hpL.Parent=bb

    -- HP bar arka plan
    local hpBG = Instance.new("Frame")
    hpBG.Size=UDim2.new(0.92,0,0,6); hpBG.Position=UDim2.new(0.04,0,1,-10)
    hpBG.BackgroundColor3=Color3.fromRGB(20,20,20); hpBG.BorderSizePixel=0; hpBG.Parent=bb
    Instance.new("UICorner",hpBG).CornerRadius=UDim.new(1,0)

    -- HP bar dolu kısım
    local hpF = Instance.new("Frame")
    hpF.Size=UDim2.new(1,0,1,0); hpF.BackgroundColor3=Color3.fromRGB(50,220,80)
    hpF.BorderSizePixel=0; hpF.Parent=hpBG
    Instance.new("UICorner",hpF).CornerRadius=UDim.new(1,0)

    local data = {bb=bb, nameL=nameL, hpL=hpL, hpF=hpF, hpBG=hpBG, conn=nil}
    Boards[playerName] = data

    data.conn = RunService.RenderStepped:Connect(function()
        pcall(function()
            -- Temel kontroller
            if not Cfg.ESP.Enabled then bb.Enabled=false; return end
            if not char or not char.Parent then bb.Enabled=false; return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then bb.Enabled=false; return end

            -- Mesafe kontrolü
            local dist = GetDist(char)
            if dist > Cfg.ESP.MaxDist then bb.Enabled=false; return end

            bb.Enabled = true

            -- İsim
            nameL.Visible   = Cfg.ESP.Name
            nameL.Text      = playerName
            nameL.TextColor3= Cfg.ESP.EnemyColor

            -- HP + mesafe metni
            if Cfg.ESP.Distance then
                hpL.Visible = true
                hpL.Text = string.format("%.0f  HP: %.0f", dist, hum.Health)
            elseif Cfg.ESP.Health then
                hpL.Visible = true
                hpL.Text = string.format("HP: %.0f / %.0f", hum.Health, hum.MaxHealth)
            else
                hpL.Visible = false
            end

            -- HP bar
            hpBG.Visible = Cfg.ESP.Health
            if Cfg.ESP.Health then
                local r = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                hpF.Size = UDim2.new(r, 0, 1, 0)
                hpF.BackgroundColor3 = Color3.fromRGB(
                    math.floor((1-r)*255), math.floor(r*220), 0)
            end
        end)
    end)

    -- Karakter gittiğinde temizle
    char.AncestryChanged:Connect(function(_, par)
        if not par then
            pcall(function() bb:Destroy() end)
            if data.conn then data.conn:Disconnect() end
            if Boards[playerName] == data then Boards[playerName] = nil end
        end
    end)

    print("[v9 ESP] Board oluşturuldu:", playerName)
end

-- Klasörü izle
local function WatchFolder(folder, teamName)
    if not folder then return end
    -- Mevcut karakterler
    for _, char in ipairs(folder:GetChildren()) do
        if char.Name ~= LP.Name then
            task.spawn(function()
                task.wait(0.3)
                if IsAlive(char) then
                    pcall(function() BuildBoard(char, char.Name) end)
                end
            end)
        end
    end
    -- Yeni karakterler
    folder.ChildAdded:Connect(function(char)
        if char.Name ~= LP.Name then
            task.spawn(function()
                task.wait(0.5)
                if IsAlive(char) then
                    pcall(function() BuildBoard(char, char.Name) end)
                end
            end)
        end
    end)
    -- Giden karakterler
    folder.ChildRemoved:Connect(function(char)
        if Boards[char.Name] then
            pcall(function() Boards[char.Name].bb:Destroy() end)
            if Boards[char.Name].conn then Boards[char.Name].conn:Disconnect() end
            Boards[char.Name] = nil
        end
        if CHL[char.Name] then
            pcall(function() CHL[char.Name]:Destroy() end)
            CHL[char.Name] = nil
        end
    end)
end

-- Ana ESP başlatıcı
task.spawn(function()
    local cf = workspace:WaitForChild("Characters", 25)
    if not cf then
        print("[v9] Characters yok — Players fallback")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                task.spawn(function() pcall(function() BuildBoard(p.Character, p.Name) end) end)
            end
        end
        Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(c)
                task.wait(0.5)
                pcall(function() BuildBoard(c, p.Name) end)
            end)
        end)
        return
    end
    CharFolder = cf
    local tf  = cf:WaitForChild("Terrorists", 10)
    local ctf = cf:WaitForChild("Counter-Terrorists", 10)
    TFolder = tf; CTFolder = ctf

    -- Her iki klasörü de izle (takım bilgisi ESP build'e geçmez, GetMyTeam ile kontrol edilir)
    WatchFolder(tf,  "T")
    WatchFolder(ctf, "CT")
end)

-- Periyodik kontrol: yeni düşmanlar kaçırılmış olabilir
task.spawn(function()
    while task.wait(5) do
        for _, e in ipairs(GetEnemies()) do
            if IsAlive(e.char) and not Boards[e.name] then
                task.spawn(function()
                    pcall(function() BuildBoard(e.char, e.name) end)
                end)
            end
        end
        if Cfg.Chams.Enabled then RefreshChams() end
    end
end)

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
        if not part then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d < bestD then bestD=d; best={pos=part.Position} end
    end
    return best
end

-- ════════════════════════════════════════════════════════════════
-- FOV ÇEMBER + RADAR (Drawing API)
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
local rDots = {}
pcall(function()
    rBG   = Drawing.new("Square"); rBG.Filled=true; rBG.Color=Color3.fromRGB(6,6,12); rBG.Transparency=0.38; rBG.Visible=false
    rBD   = Drawing.new("Square"); rBD.Filled=false; rBD.Thickness=1.5; rBD.Color=Color3.fromRGB(140,50,255); rBD.Visible=false
    rSelf = Drawing.new("Circle"); rSelf.Filled=true; rSelf.Radius=4; rSelf.NumSides=8; rSelf.Color=Color3.fromRGB(80,180,255); rSelf.Visible=false
    rLbl  = Drawing.new("Text"); rLbl.Text="RADAR"; rLbl.Size=9; rLbl.Center=true; rLbl.Outline=true
           rLbl.Color=Color3.fromRGB(140,50,255); rLbl.Font=Drawing.Fonts.Plex; rLbl.Visible=false
    radOK = true
end)

local function RefreshDots()
    for _,rd in pairs(rDots) do pcall(function() rd.d:Remove() end) end
    rDots = {}
    if not radOK then return end
    for _, e in ipairs(GetEnemies()) do
        local d = Drawing.new("Circle"); d.Filled=true; d.Radius=4; d.NumSides=8
        d.Color=Cfg.ESP.EnemyColor; d.Visible=false
        table.insert(rDots, {d=d, char=e.char})
    end
end
if radOK then task.delay(6, RefreshDots) end

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
                Camera.CFrame = cur:Lerp(CFrame.lookAt(cur.Position, t.pos), Cfg.Aimbot.Smooth)
            end
        end

        DoNoRecoil()

        -- Radar
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

            for _, rd in ipairs(rDots) do
                pcall(function()
                    local dot  = rd.d
                    local char = rd.char
                    if not IsAlive(char) then dot.Visible=false; return end
                    local r2 = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                    if not r2 then dot.Visible=false; return end
                    local rel = lCF:PointToObjectSpace(r2.Position)
                    local nx = rel.X / Cfg.Radar.Range
                    local nz = rel.Z / Cfg.Radar.Range
                    if math.abs(nx)>1 or math.abs(nz)>1 then dot.Visible=false; return end
                    dot.Position = Vector2.new(
                        rx + rs/2 + nx * (rs/2) * Cfg.Radar.Scale,
                        ry + rs/2 - nz * (rs/2) * Cfg.Radar.Scale)
                    dot.Color = Cfg.ESP.EnemyColor
                    dot.Visible = true
                end)
            end
        elseif radOK then
            if rBG then rBG.Visible=false; rBD.Visible=false; rSelf.Visible=false; rLbl.Visible=false end
            for _,rd in ipairs(rDots) do pcall(function() rd.d.Visible=false end) end
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
SG.Name="BSv9"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
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
local HT=Instance.new("TextLabel"); HT.Size=UDim2.new(1,-20,0,24); HT.Position=UDim2.new(0,20,0,5); HT.BackgroundTransparency=1; HT.Text="BLOXSTRIKE ULTRA  v9.0"; HT.TextColor3=TX; HT.Font=Enum.Font.GothamBold; HT.TextSize=14; HT.TextXAlignment=Enum.TextXAlignment.Left; HT.Parent=Hdr
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

local SCh = Sec("Chams","💀")
Tog(SCh,"Chams (Duvardan Gör)",Cfg.Chams.Enabled,function(v) Cfg.Chams.Enabled=v; RefreshChams() end)

local SRad = Sec("Radar","📡")
Tog(SRad,"Mini Radar",Cfg.Radar.Enabled,function(v)
    Cfg.Radar.Enabled=v
    if not v and radOK then
        if rBG then rBG.Visible=false; rBD.Visible=false; rSelf.Visible=false; rLbl.Visible=false end
        for _,rd in ipairs(rDots) do pcall(function() rd.d.Visible=false end) end
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
Tog(SBH,"Big Head",Cfg.BigHead.Enabled,function(v) Cfg.BigHead.Enabled=v; ApplyBigHeadAll(v) end)
Btn(SBH,"S (2x)",function() Cfg.BigHead.Scale=2; if Cfg.BigHead.Enabled then ApplyBigHeadAll(true) end end)
Btn(SBH,"M (3.5x)",function() Cfg.BigHead.Scale=3.5; if Cfg.BigHead.Enabled then ApplyBigHeadAll(true) end end)
Btn(SBH,"L (5x)",function() Cfg.BigHead.Scale=5; if Cfg.BigHead.Enabled then ApplyBigHeadAll(true) end end)
Btn(SBH,"XL (8x)",function() Cfg.BigHead.Scale=8; if Cfg.BigHead.Enabled then ApplyBigHeadAll(true) end end)

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

-- Başlangıç bildirimleri
task.delay(1.5, function()
    Notif("⚡ BloxStrike Ultra v9  |  RShift=Menü  |  E=Aim", 4, P1)
    if saved then
        task.delay(4.5, function() Notif("💾 Önceki ayarlar yüklendi!", 3, GREEN) end)
    end
end)

-- Takım tespiti bildirimi
task.delay(8, function()
    local team = GetMyTeam()
    local myChar = GetMyChar()
    if team then
        Notif("✅ Takım: "..team.."  |  Karakter: "..(myChar and "✅" or "❌"), 4, GREEN)
    else
        Notif("⚠️  Takım tespit edilemedi — tüm oyuncular hedef", 4, Color3.fromRGB(255,180,30))
    end
end)

-- Başlangıçta skin ve bighead uygula
task.spawn(function()
    task.wait(2.5)
    if Cfg.Skin.Enabled then ApplyBodySkin(Cfg.Skin.Preset) end
    if Cfg.BigHead.Enabled then ApplyBigHeadAll(true) end
end)

print("[BSUltra v9] ✅ Hazır — LP.Character nil sorunu düzeltildi")
print("[v9] Output'u gör: takım ve karakter durumu")
