-- ╔══════════════════════════════════════════════════════════════╗
-- ║     KONTRA ULTRA v2.0 | Tam Düzeltilmiş Build              ║
-- ║     ESP · Aimbot · SkinChanger · Radar · No Recoil         ║
-- ║     RightShift = Menü | E basılı = Aimbot                  ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local Camera       = workspace.CurrentCamera
local LP           = Players.LocalPlayer
local SAVE_FILE    = "KontraUltra_settings.json"

-- ════════════════════════════════════════════════════════════════
-- AYAR KAYDET / YÜKLE
-- ════════════════════════════════════════════════════════════════
local function SaveSettings(cfg)
    pcall(function()
        local data = {
            AimbotEnabled = cfg.Aimbot.Enabled,
            AimbotFOV     = cfg.Aimbot.FOV,
            AimbotSmooth  = cfg.Aimbot.Smooth,
            AimbotKey     = cfg.Aimbot.Key.Name,
            ShowFOV       = cfg.Aimbot.ShowFOV,
            NoRecoil      = cfg.NoRecoil.Enabled,
            ESPEnabled    = cfg.ESP.Enabled,
            ESPName       = cfg.ESP.Name,
            ESPDist       = cfg.ESP.Distance,
            ESPHealth     = cfg.ESP.Health,
            ESPBox        = cfg.ESP.Box,
            ESPTracer     = cfg.ESP.Tracer,
            RadarEnabled  = cfg.Radar.Enabled,
            SkinEnabled   = cfg.Skin.Enabled,
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
    Aimbot   = { Enabled=true,  Key=Enum.KeyCode.E, FOV=180, Smooth=0.12, Part="Head", ShowFOV=true },
    ESP      = { Enabled=true,  Name=true, Distance=true, Health=true, Box=true, Tracer=true, MaxDist=3000,
                 EnemyColor=Color3.fromRGB(255,60,60), TeamColor=Color3.fromRGB(60,220,120) },
    NoRecoil = { Enabled=true,  Strength=0.45 },
    Radar    = { Enabled=true,  Size=160, Range=400, Scale=0.68 },
    Skin     = { Enabled=false },
}

local saved = LoadSettings()
if saved then
    pcall(function()
        Cfg.Aimbot.Enabled    = saved.AimbotEnabled
        Cfg.Aimbot.FOV        = saved.AimbotFOV     or 180
        Cfg.Aimbot.Smooth     = saved.AimbotSmooth  or 0.12
        Cfg.Aimbot.ShowFOV    = saved.ShowFOV
        Cfg.NoRecoil.Enabled  = saved.NoRecoil
        Cfg.ESP.Enabled       = saved.ESPEnabled
        Cfg.ESP.Name          = saved.ESPName
        Cfg.ESP.Distance      = saved.ESPDist
        Cfg.ESP.Health        = saved.ESPHealth
        Cfg.ESP.Box           = saved.ESPBox
        Cfg.ESP.Tracer        = saved.ESPTracer
        Cfg.Radar.Enabled     = saved.RadarEnabled
        Cfg.Skin.Enabled      = saved.SkinEnabled
        if saved.AimbotKey then
            local k = Enum.KeyCode[saved.AimbotKey]
            if k then Cfg.Aimbot.Key = k end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- KARAKTER YARDIMCILARI
-- DÜZELTİLDİ: IsAlive artık Humanoid olmasa da çalışır
-- DÜZELTİLDİ: GetCharBounds düzgün baş/ayak pozisyonu hesaplar
-- ════════════════════════════════════════════════════════════════
local function GetMyChar()
    return LP.Character
end

-- DÜZELTİLDİ: Humanoid kontrolü gevşetildi, sadece parent+part kontrolü
local function IsAlive(char)
    if not char or not char.Parent then return false end
    -- En az bir BasePart olması yeterli
    local anyPart = char:FindFirstChildWhichIsA("BasePart")
    if not anyPart then return false end
    -- Humanoid varsa HP kontrol et
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        return hum.Health > 0
    end
    -- Humanoid yoksa canlı say (bazı oyunlar özel HP sistemi kullanır)
    -- Ama character.Parent nil ise ölü
    return char.Parent ~= nil
end

local function GetHP(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    -- Özel HP value arama
    for _, v in ipairs(char:GetDescendants()) do
        if (v.Name == "Health" or v.Name == "HP") and
           (v:IsA("NumberValue") or v:IsA("IntValue")) then
            return v.Value, 100
        end
    end
    return 100, 100
end

-- DÜZELTİLDİ: Karakterin gerçek baş ve ayak pozisyonunu hesapla
local function GetCharBounds(char)
    local head = char:FindFirstChild("Head")
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local feet = char:FindFirstChild("HumanoidRootPart") -- ayak için

    local headPos, feetPos

    if head then
        headPos = head.Position + Vector3.new(0, head.Size.Y * 0.5 + 0.2, 0)
    elseif hrp then
        headPos = hrp.Position + Vector3.new(0, 2.8, 0)
    else
        local topPart = nil
        local maxY = -math.huge
        for _, p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") and p.Position.Y > maxY then
                maxY = p.Position.Y
                topPart = p
            end
        end
        if topPart then
            headPos = topPart.Position + Vector3.new(0, topPart.Size.Y * 0.5, 0)
        end
    end

    if hrp then
        -- Kontra karakteri genellikle HumanoidRootPart merkezde, ayaklar ~3 birim aşağıda
        feetPos = hrp.Position - Vector3.new(0, 3.0, 0)
    elseif head then
        feetPos = head.Position - Vector3.new(0, 5.0, 0)
    else
        local botPart = nil
        local minY = math.huge
        for _, p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") and p.Position.Y < minY then
                minY = p.Position.Y
                botPart = p
            end
        end
        if botPart then
            feetPos = botPart.Position - Vector3.new(0, botPart.Size.Y * 0.5, 0)
        end
    end

    return headPos, feetPos
end

local function GetRootPos(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position end
    local head = char:FindFirstChild("Head")
    if head then return head.Position - Vector3.new(0, 1.5, 0) end
    local p = char:FindFirstChildWhichIsA("BasePart")
    if p then return p.Position end
    return nil
end

local function GetHeadPart(char)
    return char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChildWhichIsA("BasePart")
end

local function GetDist(char)
    local myChar = GetMyChar()
    if not myChar then return 0 end
    local a = GetRootPos(myChar)
    local b = GetRootPos(char)
    if not a or not b then return 0 end
    return (b - a).Magnitude
end

-- ════════════════════════════════════════════════════════════════
-- TAKIM / DÜŞMAN TESPİTİ
-- DÜZELTİLDİ: Çoklu takım tespit yöntemi, önce LP.Team,
-- sonra takım rengi, son çare herkesi düşman say
-- ════════════════════════════════════════════════════════════════
local function IsEnemy(player)
    if player == LP then return false end
    -- LP.Team üzerinden kontrol
    if LP.Team and player.Team then
        return LP.Team ~= player.Team
    end
    -- Takım rengi üzerinden kontrol
    if LP.TeamColor and player.TeamColor then
        return LP.TeamColor ~= player.TeamColor
    end
    -- Hiç takım bilgisi yoksa herkesi düşman say
    return true
end

local function GetEnemies()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local char = p.Character
            if char and IsAlive(char) then
                -- DÜZELTİLDİ: IsEnemy başarısız olsa bile listeye ekle
                -- (takım atanmamışsa herkes görünsün)
                local enemy = IsEnemy(p)
                if enemy then
                    table.insert(list, { char=char, name=p.Name, player=p })
                end
            end
        end
    end
    -- Liste boşsa (takım tespiti yapılamadı) LP dışı herkesi döndür
    if #list == 0 then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and IsAlive(p.Character) then
                table.insert(list, { char=p.Character, name=p.Name, player=p })
            end
        end
    end
    return list
end

local function GetTeammates()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and not IsEnemy(p) and p.Character and IsAlive(p.Character) then
            table.insert(list, { char=p.Character, name=p.Name })
        end
    end
    return list
end

-- ════════════════════════════════════════════════════════════════
-- SKIN CHANGER
-- ════════════════════════════════════════════════════════════════
local SkinData  = {}
local SkinCases = {
    "Skin Case 1","Skin Case 2","Skin Case 3",
    "Spooky Skin Case","Festive Skin Case",
    "Community Skin Case","Classic Skin Case","Other",
    "Skins","WeaponSkins","Cases","Cosmetics","ViewModels",
}

local function FindViewModelsFolder()
    local function searchIn(root)
        if not root then return nil end
        local vm = root:FindFirstChild("ViewModels", true)
        if vm then return vm end
        local assets = root:FindFirstChild("Assets")
        if assets then
            vm = assets:FindFirstChild("ViewModels")
            if vm then return vm end
        end
        return nil
    end
    local ps = LP:FindFirstChild("PlayerScripts")
    local vm = searchIn(ps)
    if vm then return vm end
    vm = searchIn(game:GetService("ReplicatedStorage"))
    if vm then return vm end
    return Camera
end

local function BuildSkinList()
    SkinData = {}
    pcall(function()
        local vmRoot = FindViewModelsFolder()
        if not vmRoot then return end
        local function scanFolder(folder)
            if not folder then return end
            for _, item in ipairs(folder:GetChildren()) do
                local name = item.Name
                local sep  = name:find(" | ")
                if sep then
                    local weapon = name:sub(1,sep-1):gsub("%s+",""):upper()
                    local skin   = name:sub(sep+3)
                    if not SkinData[weapon] then SkinData[weapon]={} end
                    SkinData[weapon][skin] = item
                elseif name:find("_") then
                    local parts = name:split("_")
                    if #parts >= 2 then
                        local weapon = parts[1]:upper()
                        local skin   = table.concat(parts,"_",2)
                        if not SkinData[weapon] then SkinData[weapon]={} end
                        SkinData[weapon][skin] = item
                    end
                end
            end
        end
        for _, caseName in ipairs(SkinCases) do
            local cf = vmRoot:FindFirstChild(caseName, true)
            if cf then scanFolder(cf) end
        end
        scanFolder(vmRoot)
    end)
end

local function FindActiveViewModel(weaponKeyword)
    local wk = weaponKeyword:upper():gsub("%s+","")
    for _, obj in ipairs(Camera:GetChildren()) do
        local n = obj.Name:upper():gsub("%s+","")
        if n:find(wk,1,true) or wk:find(n:sub(1,4),1,true) then
            return obj
        end
    end
    return nil
end

local function ApplySkin(weaponKey, skinName)
    pcall(function()
        if not SkinData[weaponKey] then return end
        local skinModel = SkinData[weaponKey][skinName]
        if not skinModel then return end
        local vm = FindActiveViewModel(weaponKey)
        if not vm then return end
        local old = vm:FindFirstChild("_KontraSkin")
        if old then old:Destroy() end
        for _, p in ipairs(vm:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("MeshPart") then
                pcall(function() p.Transparency=1 end)
            end
            if p:IsA("Texture") or p:IsA("Decal") then
                pcall(function() p.Transparency=1 end)
            end
        end
        local clone = skinModel:Clone()
        clone.Name = "_KontraSkin"
        for _, p in ipairs(clone:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide=false; p.Anchored=false; p.CastShadow=false
                p.CanTouch=false; p.CanQuery=false
            end
        end
        clone.Parent = vm
        local root = vm:FindFirstChildWhichIsA("BasePart")
        if root then
            for _, p in ipairs(clone:GetDescendants()) do
                if p:IsA("BasePart") then
                    local wc=Instance.new("WeldConstraint")
                    wc.Part0=root; wc.Part1=p; wc.Parent=p
                end
            end
        end
    end)
end

local function ResetSkin(weaponKey)
    pcall(function()
        local vm = FindActiveViewModel(weaponKey)
        if not vm then return end
        local old = vm:FindFirstChild("_KontraSkin")
        if old then old:Destroy() end
        for _, p in ipairs(vm:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("MeshPart") then
                pcall(function() p.Transparency=0 end)
            end
            if p:IsA("Texture") or p:IsA("Decal") then
                pcall(function() p.Transparency=0 end)
            end
        end
    end)
end

task.spawn(function() task.wait(5); BuildSkinList() end)

-- ════════════════════════════════════════════════════════════════
-- ESP — Drawing API
-- DÜZELTİLDİ: WorldToViewportPoint z kontrolü eklendi
-- DÜZELTİLDİ: Kutu boyutu hesabı GetCharBounds ile düzeltildi
-- DÜZELTİLDİ: Minimum kutu yüksekliği garantisi eklendi
-- ════════════════════════════════════════════════════════════════
local drawOK = false
pcall(function()
    local t = Drawing.new("Line"); t:Remove(); drawOK=true
end)

local ESPDrawings = {}

local function CreateESPDraw(name)
    if ESPDrawings[name] then return end
    local d = {}
    -- İsim
    d.name = Drawing.new("Text")
    d.name.Size=14; d.name.Center=true; d.name.Outline=true
    d.name.Font=Drawing.Fonts.Plex; d.name.Visible=false
    d.name.Color=Cfg.ESP.EnemyColor
    -- Mesafe + HP text
    d.info = Drawing.new("Text")
    d.info.Size=12; d.info.Center=true; d.info.Outline=true
    d.info.Font=Drawing.Fonts.Plex; d.info.Visible=false
    d.info.Color=Color3.fromRGB(210,210,210)
    -- HP bar arka plan
    d.hpBg = Drawing.new("Line")
    d.hpBg.Thickness=4; d.hpBg.Visible=false
    d.hpBg.Color=Color3.fromRGB(20,20,20)
    -- HP bar dolu kısım
    d.hpFill = Drawing.new("Line")
    d.hpFill.Thickness=3; d.hpFill.Visible=false
    d.hpFill.Color=Color3.fromRGB(50,220,80)
    -- Box çizgileri (4 kenar)
    d.boxT = Drawing.new("Line"); d.boxT.Thickness=1.5; d.boxT.Visible=false; d.boxT.Color=Cfg.ESP.EnemyColor
    d.boxB = Drawing.new("Line"); d.boxB.Thickness=1.5; d.boxB.Visible=false; d.boxB.Color=Cfg.ESP.EnemyColor
    d.boxL = Drawing.new("Line"); d.boxL.Thickness=1.5; d.boxL.Visible=false; d.boxL.Color=Cfg.ESP.EnemyColor
    d.boxR = Drawing.new("Line"); d.boxR.Thickness=1.5; d.boxR.Visible=false; d.boxR.Color=Cfg.ESP.EnemyColor
    -- Tracer
    d.tracer = Drawing.new("Line")
    d.tracer.Thickness=1; d.tracer.Visible=false
    d.tracer.Color=Cfg.ESP.EnemyColor; d.tracer.Transparency=0.4
    ESPDrawings[name] = d
end

local function HideESP(d)
    if not d then return end
    pcall(function()
        d.name.Visible=false; d.info.Visible=false
        d.hpBg.Visible=false; d.hpFill.Visible=false
        d.boxT.Visible=false; d.boxB.Visible=false
        d.boxL.Visible=false; d.boxR.Visible=false
        d.tracer.Visible=false
    end)
end

local function RemoveESPDraw(name)
    local d = ESPDrawings[name]
    if not d then return end
    pcall(function()
        d.name:Remove(); d.info:Remove()
        d.hpBg:Remove(); d.hpFill:Remove()
        d.boxT:Remove(); d.boxB:Remove()
        d.boxL:Remove(); d.boxR:Remove()
        d.tracer:Remove()
    end)
    ESPDrawings[name] = nil
end

local function UpdateESP()
    if not drawOK then return end

    local vp     = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y)

    if not Cfg.ESP.Enabled then
        for _, d in pairs(ESPDrawings) do HideESP(d) end
        return
    end

    local enemies = GetEnemies()
    local active  = {}

    for _, e in ipairs(enemies) do
        active[e.name] = true

        if not IsAlive(e.char) then
            HideESP(ESPDrawings[e.name])
            continue
        end

        -- DÜZELTİLDİ: GetCharBounds ile gerçek baş/ayak pozisyonu
        local headPos, feetPos = GetCharBounds(e.char)
        if not headPos or not feetPos then
            HideESP(ESPDrawings[e.name])
            continue
        end

        -- DÜZELTİLDİ: Z derinliği kontrolü — kameranın arkasındaki nesneleri atla
        local spHead = Camera:WorldToViewportPoint(headPos)
        local spFeet = Camera:WorldToViewportPoint(feetPos)

        -- Z > 0 ise kameranın önünde
        if spHead.Z <= 0 then
            HideESP(ESPDrawings[e.name])
            continue
        end

        local dist = GetDist(e.char)
        if dist > Cfg.ESP.MaxDist then
            HideESP(ESPDrawings[e.name])
            continue
        end

        CreateESPDraw(e.name)
        local d = ESPDrawings[e.name]
        if not d then continue end

        local hp, maxHp = GetHP(e.char)
        local hpR = math.clamp(hp / math.max(maxHp,1), 0, 1)

        local sHead = Vector2.new(spHead.X, spHead.Y)
        local sFeet = Vector2.new(spFeet.X, spFeet.Y)

        -- DÜZELTİLDİ: Minimum kutu yüksekliği garantisi (en az 20px)
        local rawH = math.abs(sFeet.Y - sHead.Y)
        local boxH = math.max(rawH, 20)
        local boxW = math.max(boxH * 0.55, 14)

        -- Yukarı/aşağı yön garantisi
        local topY    = math.min(sHead.Y, sFeet.Y)
        local bottomY = math.max(sHead.Y, sFeet.Y)
        local centerX = sHead.X

        -- İsim
        if Cfg.ESP.Name then
            d.name.Text     = e.name
            d.name.Position = Vector2.new(centerX, topY - 16)
            d.name.Color    = Cfg.ESP.EnemyColor
            d.name.Visible  = true
        else d.name.Visible = false end

        -- Mesafe + HP info
        local info = ""
        if Cfg.ESP.Distance then
            info = string.format("[%.0fm]", dist)
        end
        if Cfg.ESP.Health then
            if info ~= "" then info = info.." " end
            info = info..string.format("HP:%.0f", hp)
        end
        if info ~= "" then
            d.info.Text     = info
            d.info.Position = Vector2.new(centerX, topY - 4)
            d.info.Visible  = true
        else d.info.Visible = false end

        -- HP bar (sol tarafa dikey)
        if Cfg.ESP.Health then
            local barX = centerX - boxW/2 - 6
            d.hpBg.From    = Vector2.new(barX, topY)
            d.hpBg.To      = Vector2.new(barX, bottomY)
            d.hpBg.Visible = true
            local fillEnd = bottomY - (bottomY - topY) * hpR
            d.hpFill.From    = Vector2.new(barX, bottomY)
            d.hpFill.To      = Vector2.new(barX, fillEnd)
            d.hpFill.Color   = Color3.fromRGB(
                math.floor((1-hpR)*255),
                math.floor(hpR*220), 0)
            d.hpFill.Visible = true
        else
            d.hpBg.Visible=false; d.hpFill.Visible=false
        end

        -- Box
        if Cfg.ESP.Box then
            local L = centerX - boxW/2
            local R = centerX + boxW/2
            d.boxT.From=Vector2.new(L,topY);    d.boxT.To=Vector2.new(R,topY);    d.boxT.Color=Cfg.ESP.EnemyColor; d.boxT.Visible=true
            d.boxB.From=Vector2.new(L,bottomY); d.boxB.To=Vector2.new(R,bottomY); d.boxB.Color=Cfg.ESP.EnemyColor; d.boxB.Visible=true
            d.boxL.From=Vector2.new(L,topY);    d.boxL.To=Vector2.new(L,bottomY); d.boxL.Color=Cfg.ESP.EnemyColor; d.boxL.Visible=true
            d.boxR.From=Vector2.new(R,topY);    d.boxR.To=Vector2.new(R,bottomY); d.boxR.Color=Cfg.ESP.EnemyColor; d.boxR.Visible=true
        else
            d.boxT.Visible=false; d.boxB.Visible=false
            d.boxL.Visible=false; d.boxR.Visible=false
        end

        -- Tracer (ekran altından ayaklara)
        if Cfg.ESP.Tracer then
            d.tracer.From    = center
            d.tracer.To      = Vector2.new(centerX, bottomY)
            d.tracer.Color   = Cfg.ESP.EnemyColor
            d.tracer.Visible = true
        else d.tracer.Visible = false end
    end

    -- Artık aktif olmayan ESP'leri gizle
    for name, d in pairs(ESPDrawings) do
        if not active[name] then HideESP(d) end
    end
end

-- ════════════════════════════════════════════════════════════════
-- AIMBOT
-- DÜZELTİLDİ: Hedef tespiti Z kontrolü eklendi
-- ════════════════════════════════════════════════════════════════
local function GetTarget()
    local best, bestD = nil, Cfg.Aimbot.FOV
    local vp     = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)

    for _, e in ipairs(GetEnemies()) do
        if not IsAlive(e.char) then continue end

        local headPart = GetHeadPart(e.char)
        if not headPart then continue end

        local sp = Camera:WorldToViewportPoint(headPart.Position)
        -- DÜZELTİLDİ: Z > 0 kontrolü
        if sp.Z <= 0 then continue end

        local d = (Vector2.new(sp.X,sp.Y) - center).Magnitude
        if d < bestD then
            bestD = d
            best  = { pos = headPart.Position }
        end
    end
    return best
end

-- ════════════════════════════════════════════════════════════════
-- FOV ÇEMBERİ + RADAR
-- ════════════════════════════════════════════════════════════════
local fovC
pcall(function()
    fovC = Drawing.new("Circle")
    fovC.Visible=false; fovC.Radius=Cfg.Aimbot.FOV
    fovC.Thickness=1.8; fovC.Filled=false; fovC.NumSides=80
    fovC.Color=Color3.fromRGB(160,60,255)
end)

local rBG, rBD, rSelf, rLbl
pcall(function()
    rBG  = Drawing.new("Square"); rBG.Filled=true;  rBG.Color=Color3.fromRGB(6,6,12);    rBG.Transparency=0.38; rBG.Visible=false
    rBD  = Drawing.new("Square"); rBD.Filled=false; rBD.Thickness=1.5; rBD.Color=Color3.fromRGB(140,50,255); rBD.Visible=false
    rSelf= Drawing.new("Circle"); rSelf.Filled=true; rSelf.Radius=4; rSelf.NumSides=8; rSelf.Color=Color3.fromRGB(80,180,255); rSelf.Visible=false
    rLbl = Drawing.new("Text");   rLbl.Text="RADAR"; rLbl.Size=9; rLbl.Center=true; rLbl.Outline=true
    rLbl.Color=Color3.fromRGB(140,50,255); rLbl.Font=Drawing.Fonts.Plex; rLbl.Visible=false
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
        local lp  = math.asin(math.clamp(lastCF.LookVector.Y,-1,1))
        local cp  = math.asin(math.clamp(cur.LookVector.Y,-1,1))
        if cp - lp > 0.002 then
            Camera.CFrame = cur * CFrame.Angles(-(cp-lp)*Cfg.NoRecoil.Strength,0,0)
        end
        lastCF = Camera.CFrame
    end)
end

-- ════════════════════════════════════════════════════════════════
-- ANA LOOP
-- ════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    pcall(function()
        local vp     = Camera.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)

        -- FOV çemberi
        if fovC then
            fovC.Position = center
            fovC.Radius   = Cfg.Aimbot.FOV
            fovC.Visible  = Cfg.Aimbot.Enabled and Cfg.Aimbot.ShowFOV
        end

        -- Aimbot
        if Cfg.Aimbot.Enabled and UIS:IsKeyDown(Cfg.Aimbot.Key) then
            local t = GetTarget()
            if t then
                local cur = Camera.CFrame
                Camera.CFrame = cur:Lerp(
                    CFrame.lookAt(cur.Position, t.pos),
                    Cfg.Aimbot.Smooth)
            end
        end

        DoNoRecoil()
        UpdateESP()

        -- Radar
        if rBG and Cfg.Radar.Enabled then
            local rs = Cfg.Radar.Size
            local rx = 20
            local ry = vp.Y - 20 - rs
            rBG.Size=Vector2.new(rs,rs);    rBG.Position=Vector2.new(rx,ry);    rBG.Visible=true
            rBD.Size=Vector2.new(rs,rs);    rBD.Position=Vector2.new(rx,ry);    rBD.Visible=true
            rSelf.Position=Vector2.new(rx+rs/2, ry+rs/2);                       rSelf.Visible=true
            rLbl.Position=Vector2.new(rx+rs/2, ry+rs+2);                        rLbl.Visible=true

            local myChar = GetMyChar()
            local lr = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head"))
            local lCF = lr and lr.CFrame or CFrame.new()

            for _, rd in pairs(rDots) do pcall(function() rd:Remove() end) end
            rDots = {}

            local function addDot(pos, col)
                local rel = lCF:PointToObjectSpace(pos)
                local nx  = rel.X / Cfg.Radar.Range
                local nz  = rel.Z / Cfg.Radar.Range
                if math.abs(nx)>1 or math.abs(nz)>1 then return end
                local dot = Drawing.new("Circle")
                dot.Filled=true; dot.Radius=4; dot.NumSides=8; dot.Color=col
                dot.Position=Vector2.new(
                    rx+rs/2+nx*(rs/2)*Cfg.Radar.Scale,
                    ry+rs/2-nz*(rs/2)*Cfg.Radar.Scale)
                dot.Visible=true
                table.insert(rDots, dot)
            end

            for _, e in ipairs(GetEnemies()) do
                pcall(function()
                    if not IsAlive(e.char) then return end
                    local r = e.char:FindFirstChild("HumanoidRootPart") or e.char:FindFirstChild("Head")
                    if r then addDot(r.Position, Cfg.ESP.EnemyColor) end
                end)
            end
            for _, t in ipairs(GetTeammates()) do
                pcall(function()
                    if not IsAlive(t.char) then return end
                    local r = t.char:FindFirstChild("HumanoidRootPart") or t.char:FindFirstChild("Head")
                    if r then addDot(r.Position, Cfg.ESP.TeamColor) end
                end)
            end
        elseif rBG then
            rBG.Visible=false; rBD.Visible=false; rSelf.Visible=false; rLbl.Visible=false
            for _, rd in pairs(rDots) do pcall(function() rd:Remove() end) end
            rDots = {}
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════════════
local P1  = Color3.fromRGB(140,50,255)
local P2  = Color3.fromRGB(85,22,175)
local D1  = Color3.fromRGB(9,7,16)
local D2  = Color3.fromRGB(15,11,26)
local D3  = Color3.fromRGB(21,16,36)
local TX  = Color3.fromRGB(225,215,255)
local TXD = Color3.fromRGB(140,120,190)

local SG = Instance.new("ScreenGui")
SG.Name="KontraUltra"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = LP.PlayerGui end

local MF = Instance.new("Frame")
MF.Size=UDim2.new(0,295,0,580); MF.Position=UDim2.new(0,12,0.5,-290)
MF.BackgroundColor3=D1; MF.BorderSizePixel=0; MF.Active=true; MF.Draggable=true
MF.Visible=false; MF.Parent=SG
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,12)
local mS=Instance.new("UIStroke",MF); mS.Color=P1; mS.Thickness=1.8

local Hdr=Instance.new("Frame"); Hdr.Size=UDim2.new(1,0,0,52); Hdr.BackgroundColor3=D2; Hdr.BorderSizePixel=0; Hdr.Parent=MF
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,12)
local HFix=Instance.new("Frame"); HFix.Size=UDim2.new(1,0,0.5,0); HFix.Position=UDim2.new(0,0,0.5,0); HFix.BackgroundColor3=D2; HFix.BorderSizePixel=0; HFix.Parent=Hdr
local HA=Instance.new("Frame"); HA.Size=UDim2.new(0,4,0.6,0); HA.Position=UDim2.new(0,9,0.2,0); HA.BackgroundColor3=P1; HA.BorderSizePixel=0; HA.Parent=Hdr; Instance.new("UICorner",HA).CornerRadius=UDim.new(1,0)
local HT=Instance.new("TextLabel"); HT.Size=UDim2.new(1,-20,0,24); HT.Position=UDim2.new(0,20,0,5); HT.BackgroundTransparency=1; HT.Text="KONTRA ULTRA v2.0"; HT.TextColor3=TX; HT.Font=Enum.Font.GothamBold; HT.TextSize=13; HT.TextXAlignment=Enum.TextXAlignment.Left; HT.Parent=Hdr
local HS=Instance.new("TextLabel"); HS.Size=UDim2.new(1,-20,0,14); HS.Position=UDim2.new(0,20,0,32); HS.BackgroundTransparency=1; HS.Text="RightShift = Menü · E = Aimbot (değiştirilebilir)"; HS.TextColor3=TXD; HS.Font=Enum.Font.Gotham; HS.TextSize=9; HS.TextXAlignment=Enum.TextXAlignment.Left; HS.Parent=Hdr

local Sc=Instance.new("ScrollingFrame"); Sc.Size=UDim2.new(1,-8,1,-60); Sc.Position=UDim2.new(0,4,0,56)
Sc.BackgroundTransparency=1; Sc.BorderSizePixel=0; Sc.ScrollBarThickness=3; Sc.ScrollBarImageColor3=P1
Sc.CanvasSize=UDim2.new(0,0,0,0); Sc.AutomaticCanvasSize=Enum.AutomaticSize.Y; Sc.Parent=MF
local ScL=Instance.new("UIListLayout"); ScL.Parent=Sc; ScL.SortOrder=Enum.SortOrder.LayoutOrder; ScL.Padding=UDim.new(0,5)
local ScP=Instance.new("UIPadding"); ScP.PaddingLeft=UDim.new(0,3); ScP.PaddingRight=UDim.new(0,3); ScP.PaddingTop=UDim.new(0,4); ScP.PaddingBottom=UDim.new(0,8); ScP.Parent=Sc

local so=0
local function Sec(title, emoji)
    so=so+1
    local sec=Instance.new("Frame"); sec.Size=UDim2.new(1,-4,0,40); sec.BackgroundColor3=D3; sec.BorderSizePixel=0; sec.LayoutOrder=so; sec.AutomaticSize=Enum.AutomaticSize.Y; sec.ClipsDescendants=true; sec.Parent=Sc
    Instance.new("UICorner",sec).CornerRadius=UDim.new(0,9); Instance.new("UIStroke",sec).Color=P2
    local hb=Instance.new("TextButton"); hb.Size=UDim2.new(1,0,0,40); hb.BackgroundColor3=D2; hb.BorderSizePixel=0; hb.Text=""; hb.AutoButtonColor=false; hb.ZIndex=2; hb.Parent=sec
    Instance.new("UICorner",hb).CornerRadius=UDim.new(0,9)
    local al=Instance.new("Frame"); al.Size=UDim2.new(0,3,0.55,0); al.Position=UDim2.new(0,7,0.225,0); al.BackgroundColor3=P1; al.BorderSizePixel=0; al.ZIndex=3; al.Parent=hb; Instance.new("UICorner",al).CornerRadius=UDim.new(1,0)
    local tl=Instance.new("TextLabel"); tl.Size=UDim2.new(1,-46,1,0); tl.Position=UDim2.new(0,17,0,0); tl.BackgroundTransparency=1; tl.Text=emoji.." "..title; tl.TextColor3=TX; tl.Font=Enum.Font.GothamBold; tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=3; tl.Parent=hb
    local ar=Instance.new("TextLabel"); ar.Size=UDim2.new(0,26,0,26); ar.Position=UDim2.new(1,-30,0.5,-13); ar.BackgroundTransparency=1; ar.Text="▾"; ar.TextColor3=P1; ar.Font=Enum.Font.GothamBold; ar.TextSize=15; ar.ZIndex=3; ar.Parent=hb
    local cont=Instance.new("Frame"); cont.Size=UDim2.new(1,0,0,0); cont.Position=UDim2.new(0,0,0,40); cont.BackgroundTransparency=1; cont.BorderSizePixel=0; cont.AutomaticSize=Enum.AutomaticSize.Y; cont.Visible=false; cont.Parent=sec
    local cl=Instance.new("UIListLayout"); cl.Parent=cont; cl.Padding=UDim.new(0,4)
    local cp=Instance.new("UIPadding"); cp.PaddingLeft=UDim.new(0,6); cp.PaddingRight=UDim.new(0,6); cp.PaddingTop=UDim.new(0,5); cp.PaddingBottom=UDim.new(0,8); cp.Parent=cont
    local open=false
    hb.MouseButton1Click:Connect(function()
        open=not open; cont.Visible=open; sec.ClipsDescendants=not open
        TweenService:Create(ar,TweenInfo.new(0.2),{Rotation=open and 180 or 0}):Play()
    end)
    return cont
end

local io=0
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
    b.MouseButton1Click:Connect(function() cb() end)
end

local function Lbl(parent, txt)
    io=io+1
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,0,16); l.LayoutOrder=io; l.BackgroundTransparency=1; l.Text=txt; l.TextColor3=TXD; l.Font=Enum.Font.Gotham; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Center; l.TextWrapped=true; l.Parent=parent
end

local function KeyBind(parent, lbl, getK, setK)
    io=io+1
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=D1; row.BorderSizePixel=0; row.LayoutOrder=io; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-100,1,0); l.Position=UDim2.new(0,10,0,0); l.BackgroundTransparency=1; l.Text=lbl; l.TextColor3=TX; l.Font=Enum.Font.Gotham; l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=row
    local kb=Instance.new("TextButton"); kb.Size=UDim2.new(0,85,0,22); kb.Position=UDim2.new(1,-92,0.5,-11); kb.BackgroundColor3=P2; kb.BorderSizePixel=0; kb.Text="["..getK().Name.."]"; kb.TextColor3=TX; kb.Font=Enum.Font.GothamBold; kb.TextSize=11; kb.Parent=row
    Instance.new("UICorner",kb).CornerRadius=UDim.new(0,5)
    local listening=false
    kb.MouseButton1Click:Connect(function()
        if listening then return end
        listening=true; kb.Text="[...]"
        local conn; conn=UIS.InputBegan:Connect(function(inp,gp)
            if gp then return end
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                setK(inp.KeyCode); kb.Text="["..inp.KeyCode.Name.."]"
                conn:Disconnect(); listening=false
            end
        end)
    end)
end

local function Slider(parent, lbl, min, max, default, cb)
    io=io+1
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,44); row.BackgroundColor3=D1; row.BorderSizePixel=0; row.LayoutOrder=io; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lT=Instance.new("TextLabel"); lT.Size=UDim2.new(1,-60,0,18); lT.Position=UDim2.new(0,10,0,3); lT.BackgroundTransparency=1; lT.Text=lbl; lT.TextColor3=TX; lT.Font=Enum.Font.Gotham; lT.TextSize=12; lT.TextXAlignment=Enum.TextXAlignment.Left; lT.Parent=row
    local vT=Instance.new("TextLabel"); vT.Size=UDim2.new(0,50,0,18); vT.Position=UDim2.new(1,-58,0,3); vT.BackgroundTransparency=1; vT.Text=tostring(default); vT.TextColor3=P1; vT.Font=Enum.Font.GothamBold; vT.TextSize=12; vT.TextXAlignment=Enum.TextXAlignment.Right; vT.Parent=row
    local bg=Instance.new("Frame"); bg.Size=UDim2.new(1,-20,0,6); bg.Position=UDim2.new(0,10,0,28); bg.BackgroundColor3=Color3.fromRGB(36,26,56); bg.BorderSizePixel=0; bg.Parent=row
    Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame"); fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3=P1; fill.BorderSizePixel=0; fill.Parent=bg
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,14,0,14); knob.AnchorPoint=Vector2.new(0.5,0.5); knob.Position=UDim2.new((default-min)/(max-min),0,0.5,0); knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.ZIndex=2; knob.Parent=bg
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local drag=Instance.new("TextButton"); drag.Size=UDim2.new(1,0,3,0); drag.Position=UDim2.new(0,0,-1,0); drag.BackgroundTransparency=1; drag.Text=""; drag.ZIndex=3; drag.Parent=bg
    local dragging=false
    drag.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
    end)
    drag.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local mx=UIS:GetMouseLocation().X
        local abs=bg.AbsolutePosition; local siz=bg.AbsoluteSize
        local pct=math.clamp((mx-abs.X)/siz.X,0,1)
        local val=math.floor(min+(max-min)*pct)
        fill.Size=UDim2.new(pct,0,1,0); knob.Position=UDim2.new(pct,0,0.5,0)
        vT.Text=tostring(val); cb(val)
    end)
end

-- ════════════════════════════════════════════════════════════════
-- BÖLÜMLER
-- ════════════════════════════════════════════════════════════════
local aimS = Sec("Aimbot", "🎯")
Tog(aimS, "Aimbot Aktif",       Cfg.Aimbot.Enabled,   function(v) Cfg.Aimbot.Enabled=v;   SaveSettings(Cfg) end)
Tog(aimS, "FOV Çemberi Göster", Cfg.Aimbot.ShowFOV,   function(v) Cfg.Aimbot.ShowFOV=v;   SaveSettings(Cfg) end)
Tog(aimS, "No Recoil",          Cfg.NoRecoil.Enabled, function(v) Cfg.NoRecoil.Enabled=v; SaveSettings(Cfg) end)
KeyBind(aimS, "Aimbot Tuşu",
    function() return Cfg.Aimbot.Key end,
    function(k) Cfg.Aimbot.Key=k; SaveSettings(Cfg) end)
Slider(aimS, "FOV",    50, 500, Cfg.Aimbot.FOV,
    function(v) Cfg.Aimbot.FOV=v end)
Slider(aimS, "Smooth", 1,  30,  math.floor(Cfg.Aimbot.Smooth*100),
    function(v) Cfg.Aimbot.Smooth=v/100 end)

local espS = Sec("ESP / Wallhack", "👁")
Tog(espS, "ESP Aktif",      Cfg.ESP.Enabled,  function(v) Cfg.ESP.Enabled=v;  SaveSettings(Cfg) end)
Tog(espS, "İsim",           Cfg.ESP.Name,     function(v) Cfg.ESP.Name=v;     SaveSettings(Cfg) end)
Tog(espS, "Mesafe",         Cfg.ESP.Distance, function(v) Cfg.ESP.Distance=v; SaveSettings(Cfg) end)
Tog(espS, "Can Barı",       Cfg.ESP.Health,   function(v) Cfg.ESP.Health=v;   SaveSettings(Cfg) end)
Tog(espS, "Kutu (Box)",     Cfg.ESP.Box,      function(v) Cfg.ESP.Box=v;      SaveSettings(Cfg) end)
Tog(espS, "Tracer Çizgisi", Cfg.ESP.Tracer,   function(v) Cfg.ESP.Tracer=v;   SaveSettings(Cfg) end)

local radS = Sec("Radar", "🗺")
Tog(radS, "Radar Aktif", Cfg.Radar.Enabled, function(v) Cfg.Radar.Enabled=v; SaveSettings(Cfg) end)

-- SKIN CHANGER
local skinS = Sec("Skin Changer", "🎨")
Tog(skinS, "Skin Changer Aktif", Cfg.Skin.Enabled, function(v) Cfg.Skin.Enabled=v end)
Lbl(skinS, "Oyuna gir → Yükle → Silah seç → Uygula")

local selectedWeapon=nil; local selectedSkin=nil; local skinStatusLbl=nil

io=io+1
local weaponDropFrame=Instance.new("Frame"); weaponDropFrame.Size=UDim2.new(1,0,0,0); weaponDropFrame.LayoutOrder=io; weaponDropFrame.BackgroundTransparency=1; weaponDropFrame.AutomaticSize=Enum.AutomaticSize.Y; weaponDropFrame.Parent=skinS
Instance.new("UIListLayout",weaponDropFrame).Padding=UDim.new(0,3)

io=io+1
local skinDropFrame=Instance.new("Frame"); skinDropFrame.Size=UDim2.new(1,0,0,0); skinDropFrame.LayoutOrder=io; skinDropFrame.BackgroundTransparency=1; skinDropFrame.AutomaticSize=Enum.AutomaticSize.Y; skinDropFrame.Parent=skinS
Instance.new("UIListLayout",skinDropFrame).Padding=UDim.new(0,3)

io=io+1
skinStatusLbl=Instance.new("TextLabel"); skinStatusLbl.Size=UDim2.new(1,0,0,32); skinStatusLbl.LayoutOrder=io; skinStatusLbl.BackgroundTransparency=1
skinStatusLbl.Text="'Skin Listesini Yükle' butonuna bas."; skinStatusLbl.TextColor3=TXD; skinStatusLbl.Font=Enum.Font.Gotham; skinStatusLbl.TextSize=10; skinStatusLbl.TextXAlignment=Enum.TextXAlignment.Center; skinStatusLbl.TextWrapped=true; skinStatusLbl.Parent=skinS

local function MakeSmallBtn(parent, txt, cb)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,24); b.BackgroundColor3=D2; b.BorderSizePixel=0; b.Text=txt; b.TextColor3=TX; b.Font=Enum.Font.Gotham; b.TextSize=10; b.TextTruncate=Enum.TextTruncate.AtEnd; b.Parent=parent
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    b.MouseButton1Click:Connect(cb); return b
end

local function PopulateSkins(weaponKey)
    for _, c in ipairs(skinDropFrame:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    selectedSkin=nil
    if not SkinData[weaponKey] then skinStatusLbl.Text="Bu silah için skin bulunamadı."; return end
    skinStatusLbl.Text=weaponKey.." skinleri:"
    for skinName in pairs(SkinData[weaponKey]) do
        local sn=skinName
        MakeSmallBtn(skinDropFrame, sn, function()
            selectedSkin=sn; skinStatusLbl.Text="Seçildi: "..weaponKey.." | "..sn
        end)
    end
end

local function PopulateWeapons()
    for _, c in ipairs(weaponDropFrame:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    local count=0
    for weaponKey in pairs(SkinData) do
        local wk=weaponKey; count=count+1
        MakeSmallBtn(weaponDropFrame, wk, function()
            selectedWeapon=wk; skinStatusLbl.Text="Silah: "..wk; PopulateSkins(wk)
        end)
    end
    if count==0 then
        skinStatusLbl.Text="Skin bulunamadı. Oyun Early Alpha olduğu için skinler ViewModels'ta olmayabilir."
    else
        skinStatusLbl.Text="Silah seç:"
    end
end

Btn(skinS, "🔄 Skin Listesini Yükle", function()
    skinStatusLbl.Text="Yükleniyor..."
    task.spawn(function() BuildSkinList(); task.wait(0.5); PopulateWeapons() end)
end)
Btn(skinS, "✅ Seçilen Skini Uygula", function()
    if not Cfg.Skin.Enabled then skinStatusLbl.Text="Önce Skin Changer'ı aç!"; return end
    if not selectedWeapon or not selectedSkin then skinStatusLbl.Text="Silah ve skin seç!"; return end
    ApplySkin(selectedWeapon, selectedSkin)
    skinStatusLbl.Text="Uygulandı: "..selectedWeapon.." | "..selectedSkin
end)
Btn(skinS, "↩️ Skini Sıfırla", function()
    if selectedWeapon then ResetSkin(selectedWeapon); skinStatusLbl.Text="Sıfırlandı: "..selectedWeapon end
end)

local saveS = Sec("Ayarlar", "💾")
Btn(saveS, "💾 Ayarları Kaydet", function() SaveSettings(Cfg) end)

-- ════════════════════════════════════════════════════════════════
-- MENU AÇMA — RightShift
-- ════════════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then
        MF.Visible=not MF.Visible
    end
end)

print("[KontraUltra v2.0] Yüklendi. RightShift = Menü, E = Aimbot")
