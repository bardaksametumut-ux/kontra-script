-- ============================================================
--  BloxStrike | CHEAT v1.0
--  Engine   : Roblox (Luau) — Synapse X / KRNL / Delta / Fluxus
--  Target   : PlaceID 114234929420007
--  Features : ESP (tam) + Aimbot + Skin Changer
--  AC Notes : BloxStrike sunucu taraflı hareket doğrulama kullanıyor.
--             Bu script tamamen client-side visual + kamera işlemi.
--             Hiçbir RemoteEvent tetiklenmiyor → düşük ban riski.
-- ============================================================

-- ============================================================
-- AC BYPASS STRATEJİSİ
-- BloxStrike'ın anticheat'i şunlara bakıyor:
--   1. RemoteEvent spam / beklenmedik fire
--   2. Humanoid property ani değişimleri
--   3. Script injection string pattern taraması
-- Bypass:
--   • Tüm işlem client visual (Drawing API)
--   • Camera manipülasyonu sadece RenderStepped'de
--   • Hiçbir game remote'a dokunulmuyor
--   • ScreenGui gethui() ile CoreGui dışına yerleşiyor
--   • Değişken isimleri obfuscate edilmiş
-- ============================================================

local _svc = game.GetService
local Plr  = _svc(game,"Players")
local RS   = _svc(game,"RunService")
local UIS  = _svc(game,"UserInputService")
local TS   = _svc(game,"TweenService")
local WS   = _svc(game,"Workspace")
local Cam  = WS.CurrentCamera
local LP   = Plr.LocalPlayer

-- ============================================================
-- BLOXSTRIKE SİLAH & BıÇAK LİSTESİ
-- Oyun CS2'den ilham almış, bu silahlar mevcut:
-- Skin ID'leri runtime'da tool model üzerinden taranıyor.
-- ============================================================
local WEAPONS = {
    -- Tüfekler
    "AK-47","M4A4","M4A1-S","AWP","SSG 08","AUG","SG 553","FAMAS","Galil AR",
    -- Tabancalar
    "Glock-18","USP-S","P2000","P250","Desert Eagle","Five-SeveN","Tec-9",
    "CZ75-Auto","Dual Berettas","R8 Revolver",
    -- SMG
    "MP9","MP7","MAC-10","P90","UMP-45","PP-Bizon","MP5-SD",
    -- Ağır
    "Nova","XM1014","MAG-7","Sawed-Off","M249","Negev",
    -- Bıçaklar
    "Karambit","Butterfly Knife","Bayonet","M9 Bayonet","Huntsman Knife",
    "Falchion Knife","Flip Knife","Gut Knife","Shadow Daggers","Bowie Knife",
    "Stiletto Knife","Ursus Knife","Navaja Knife","Talon Knife","Skeleton Knife",
    "Paracord Knife","Survival Knife","Nomad Knife","Classic Knife","Kukri Knife",
}

-- CS2 skin isimleri — BloxStrike bunları kendi TextureId ile implement ediyor
local SKINS = {
    -- AK-47
    {weapon="AK-47",   name="Asiimov",        color=Color3.fromRGB(255,140,0)},
    {weapon="AK-47",   name="Vulcan",          color=Color3.fromRGB(180,200,220)},
    {weapon="AK-47",   name="Redline",         color=Color3.fromRGB(180,20,20)},
    {weapon="AK-47",   name="Fire Serpent",    color=Color3.fromRGB(200,80,0)},
    {weapon="AK-47",   name="Wild Lotus",      color=Color3.fromRGB(100,180,80)},
    {weapon="AK-47",   name="Neon Revolution", color=Color3.fromRGB(0,255,180)},
    {weapon="AK-47",   name="Case Hardened",   color=Color3.fromRGB(100,120,200)},
    {weapon="AK-47",   name="Bloodsport",      color=Color3.fromRGB(200,0,30)},
    -- M4A4
    {weapon="M4A4",    name="Howl",            color=Color3.fromRGB(200,50,0)},
    {weapon="M4A4",    name="Asiimov",         color=Color3.fromRGB(255,140,0)},
    {weapon="M4A4",    name="The Emperor",     color=Color3.fromRGB(200,160,0)},
    {weapon="M4A4",    name="Temukau",         color=Color3.fromRGB(220,100,180)},
    {weapon="M4A4",    name="Desolate Space",  color=Color3.fromRGB(40,60,120)},
    {weapon="M4A4",    name="Neo-Noir",        color=Color3.fromRGB(240,200,210)},
    -- M4A1-S
    {weapon="M4A1-S",  name="Hyper Beast",     color=Color3.fromRGB(180,80,200)},
    {weapon="M4A1-S",  name="Knight",          color=Color3.fromRGB(220,200,150)},
    {weapon="M4A1-S",  name="Printstream",     color=Color3.fromRGB(240,240,240)},
    {weapon="M4A1-S",  name="Icarus Fell",     color=Color3.fromRGB(120,140,200)},
    -- AWP
    {weapon="AWP",     name="Dragon Lore",     color=Color3.fromRGB(180,140,60)},
    {weapon="AWP",     name="Asiimov",         color=Color3.fromRGB(255,140,0)},
    {weapon="AWP",     name="Lightning Strike", color=Color3.fromRGB(100,160,255)},
    {weapon="AWP",     name="Atheris",         color=Color3.fromRGB(80,160,80)},
    {weapon="AWP",     name="Neo-Noir",        color=Color3.fromRGB(240,200,210)},
    {weapon="AWP",     name="Oni Taiji",       color=Color3.fromRGB(200,60,80)},
    -- Glock
    {weapon="Glock-18",name="Fade",            color=Color3.fromRGB(255,120,200)},
    {weapon="Glock-18",name="Water Elemental", color=Color3.fromRGB(80,180,255)},
    {weapon="Glock-18",name="Neo-Noir",        color=Color3.fromRGB(240,200,210)},
    -- USP-S
    {weapon="USP-S",   name="Kill Confirmed",  color=Color3.fromRGB(255,60,60)},
    {weapon="USP-S",   name="Cortex",          color=Color3.fromRGB(180,120,80)},
    {weapon="USP-S",   name="Printstream",     color=Color3.fromRGB(240,240,240)},
    -- Desert Eagle
    {weapon="Desert Eagle",name="Blaze",       color=Color3.fromRGB(255,100,0)},
    {weapon="Desert Eagle",name="Hand Cannon", color=Color3.fromRGB(200,140,80)},
    {weapon="Desert Eagle",name="Printstream", color=Color3.fromRGB(240,240,240)},
    -- Karambit
    {weapon="Karambit",name="Fade",            color=Color3.fromRGB(255,120,200)},
    {weapon="Karambit",name="Doppler",         color=Color3.fromRGB(100,0,200)},
    {weapon="Karambit",name="Tiger Tooth",     color=Color3.fromRGB(255,180,0)},
    {weapon="Karambit",name="Marble Fade",     color=Color3.fromRGB(0,180,255)},
    {weapon="Karambit",name="Crimson Web",     color=Color3.fromRGB(160,0,0)},
    {weapon="Karambit",name="Lore",            color=Color3.fromRGB(180,140,60)},
    {weapon="Karambit",name="Autotronic",      color=Color3.fromRGB(200,0,0)},
    -- Butterfly Knife
    {weapon="Butterfly Knife",name="Fade",     color=Color3.fromRGB(255,120,200)},
    {weapon="Butterfly Knife",name="Doppler",  color=Color3.fromRGB(100,0,200)},
    {weapon="Butterfly Knife",name="Tiger Tooth",color=Color3.fromRGB(255,180,0)},
    {weapon="Butterfly Knife",name="Marble Fade",color=Color3.fromRGB(0,180,255)},
    {weapon="Butterfly Knife",name="Slaughter",color=Color3.fromRGB(220,40,40)},
    -- Bayonet
    {weapon="Bayonet",  name="Doppler",        color=Color3.fromRGB(100,0,200)},
    {weapon="Bayonet",  name="Fade",           color=Color3.fromRGB(255,120,200)},
    {weapon="Bayonet",  name="Tiger Tooth",    color=Color3.fromRGB(255,180,0)},
    {weapon="Bayonet",  name="Lore",           color=Color3.fromRGB(180,140,60)},
    -- M9 Bayonet
    {weapon="M9 Bayonet",name="Fade",          color=Color3.fromRGB(255,120,200)},
    {weapon="M9 Bayonet",name="Doppler",       color=Color3.fromRGB(100,0,200)},
    {weapon="M9 Bayonet",name="Tiger Tooth",   color=Color3.fromRGB(255,180,0)},
    {weapon="M9 Bayonet",name="Autotronic",    color=Color3.fromRGB(200,0,0)},
    -- Huntsman
    {weapon="Huntsman Knife",name="Fade",      color=Color3.fromRGB(255,120,200)},
    {weapon="Huntsman Knife",name="Doppler",   color=Color3.fromRGB(100,0,200)},
    {weapon="Huntsman Knife",name="Marble Fade",color=Color3.fromRGB(0,180,255)},
    -- Flip Knife
    {weapon="Flip Knife",name="Fade",          color=Color3.fromRGB(255,120,200)},
    {weapon="Flip Knife",name="Tiger Tooth",   color=Color3.fromRGB(255,180,0)},
    {weapon="Flip Knife",name="Marble Fade",   color=Color3.fromRGB(0,180,255)},
    -- Shadow Daggers
    {weapon="Shadow Daggers",name="Fade",      color=Color3.fromRGB(255,120,200)},
    {weapon="Shadow Daggers",name="Doppler",   color=Color3.fromRGB(100,0,200)},
    -- Bowie
    {weapon="Bowie Knife",name="Fade",         color=Color3.fromRGB(255,120,200)},
    {weapon="Bowie Knife",name="Doppler",      color=Color3.fromRGB(100,0,200)},
    {weapon="Bowie Knife",name="Tiger Tooth",  color=Color3.fromRGB(255,180,0)},
    -- Talon
    {weapon="Talon Knife",name="Fade",         color=Color3.fromRGB(255,120,200)},
    {weapon="Talon Knife",name="Doppler",      color=Color3.fromRGB(100,0,200)},
    -- Skeleton
    {weapon="Skeleton Knife",name="Fade",      color=Color3.fromRGB(255,120,200)},
    {weapon="Skeleton Knife",name="Crimson Web",color=Color3.fromRGB(160,0,0)},
    -- P90
    {weapon="P90",     name="Asiimov",         color=Color3.fromRGB(255,140,0)},
    {weapon="P90",     name="Death Grip",      color=Color3.fromRGB(40,40,40)},
    -- SSG 08
    {weapon="SSG 08",  name="Blood in the Water",color=Color3.fromRGB(180,0,40)},
    {weapon="SSG 08",  name="Dragonfire",      color=Color3.fromRGB(255,80,0)},
}

-- ============================================================
-- STATE
-- ============================================================
local S = {
    -- ESP
    esp_on=false, esp_boxes=true, esp_skeletons=false,
    esp_names=true, esp_health=true, esp_dist=true,
    esp_tracer=false, esp_tracer_orig="Bottom",
    esp_thickness=2, esp_filled=false, esp_fill_op=15,
    esp_color_mode="Team",  -- "Team"|"Static"|"Health"
    esp_static=Color3.fromRGB(255,80,80),
    esp_max_dist=2000, esp_arrows=false, esp_vis=false,
    esp_chams=false,

    -- Aimbot
    aim_on=false, aim_key=Enum.KeyCode.RightAlt,
    aim_fov=150, aim_smooth=15, aim_part="Head",
    aim_fov_show=true, aim_vis=false, aim_pred=false,
    aim_pred_ms=60,

    -- Skin Changer
    skin_on=false,
    skin_weapon="AK-47",
    skin_name="Asiimov",

    menu_key=Enum.KeyCode.Insert,
}

-- ============================================================
-- TEAM RENK (CT=Mavi, T=Sarı)
-- BloxStrike'ta takım bilgisi Team attribute veya Folder ile tutulur
-- ============================================================
local function GetTeam(p)
    -- Yaygın pattern: char içinde "Team" StringValue veya p.Team
    local char=p.Character
    if not char then return "Unknown" end
    local tv=char:FindFirstChild("Team") or p:FindFirstChild("Team")
    if tv then return tv.Value or tostring(tv) end
    -- Folder pattern
    if p.Team then return tostring(p.Team.Name) end
    return "Unknown"
end

local function TeamColor(p)
    local t=GetTeam(p)
    if t:lower():find("counter") or t:lower():find("ct") or t:lower():find("blue") then
        return Color3.fromRGB(80,150,255)
    elseif t:lower():find("terror") or t:lower():find("^t$") or t:lower():find("yellow") then
        return Color3.fromRGB(255,200,50)
    end
    return Color3.fromRGB(255,80,80)
end

local function ESPColor(p)
    if S.esp_color_mode=="Static" then return S.esp_static end
    if S.esp_color_mode=="Health" then
        local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        if h then
            local r=1-h.Health/h.MaxHealth
            return Color3.fromRGB(math.floor(r*255),math.floor((1-r)*200),50)
        end
    end
    -- Team (default)
    return TeamColor(p)
end

-- ============================================================
-- RAYCAST
-- ============================================================
local RP=RaycastParams.new()
RP.FilterType=Enum.RaycastFilterType.Exclude
local function UpdateRayFilter(char) RP.FilterDescendantsInstances={char} end
LP.CharacterAdded:Connect(UpdateRayFilter)
if LP.Character then UpdateRayFilter(LP.Character) end

local function IsVis(origin,tgt)
    local r=WS:Raycast(origin,(tgt-origin),RP)
    if not r then return true end
    return r.Instance and r.Instance.Parent and
           Plr:GetPlayerFromCharacter(r.Instance.Parent)~=nil
end

-- ============================================================
-- DRAWING
-- ============================================================
local _d={}
local function D(c) local x=Drawing.new(c); table.insert(_d,x); return x end

local EC={}
local function GC(p)
    if EC[p] then return EC[p] end
    local t={box=D("Square"),fill=D("Square"),name=D("Text"),
             hp=D("Text"),dist=D("Text"),tracer=D("Line"),
             arrow=D("Triangle"),bones={},healthbar=D("Square"),healthfill=D("Square")}
    for i=1,15 do t.bones[i]=D("Line") end
    EC[p]=t; return t
end
Plr.PlayerRemoving:Connect(function(p)
    local c=EC[p]; if not c then return end
    c.box:Remove();c.fill:Remove();c.name:Remove()
    c.hp:Remove();c.dist:Remove();c.tracer:Remove();c.arrow:Remove()
    c.healthbar:Remove();c.healthfill:Remove()
    for _,b in ipairs(c.bones) do b:Remove() end
    EC[p]=nil
end)
local function HA(c)
    c.box.Visible=false;c.fill.Visible=false;c.name.Visible=false
    c.hp.Visible=false;c.dist.Visible=false;c.tracer.Visible=false
    c.arrow.Visible=false;c.healthbar.Visible=false;c.healthfill.Visible=false
    for _,b in ipairs(c.bones) do b.Visible=false end
end

-- ============================================================
-- ESP
-- ============================================================
local function RE_()
    for _,p in ipairs(Plr:GetPlayers()) do
        if p==LP then continue end
        local cache=GC(p)
        local char=p.Character
        if not S.esp_on or not char then HA(cache); continue end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then HA(cache); continue end
        local cp=Cam.CFrame.Position
        local dist=(cp-hrp.Position).Magnitude
        if dist>S.esp_max_dist then HA(cache); continue end
        if S.esp_vis and not IsVis(cp,hrp.Position) then HA(cache); continue end
        local col=ESPColor(p)
        local function W(pos)
            local s,v=Cam:WorldToViewportPoint(pos)
            return Vector2.new(s.X,s.Y),v
        end
        local tP,tV=W(hrp.Position+Vector3.new(0,3.2,0))
        local bP,bV=W(hrp.Position+Vector3.new(0,-3.2,0))
        if not(tV and bV) then
            cache.arrow.Visible=false
            if S.esp_arrows then
                local vp=Cam.ViewportSize
                local cen=Vector2.new(vp.X/2,vp.Y/2)
                local dir=tP-cen; local m=dir.Magnitude
                if m>0 then dir=dir/m
                    local ex=math.clamp(cen.X+dir.X*260,20,vp.X-20)
                    local ey=math.clamp(cen.Y+dir.Y*260,20,vp.Y-20)
                    cache.arrow.Visible=true
                    cache.arrow.PointA=Vector2.new(ex,ey)
                    cache.arrow.PointB=Vector2.new(ex-dir.X*11-dir.Y*6,ey-dir.Y*11+dir.X*6)
                    cache.arrow.PointC=Vector2.new(ex-dir.X*11+dir.Y*6,ey-dir.Y*11-dir.X*6)
                    cache.arrow.Color=col; cache.arrow.Filled=true; cache.arrow.Transparency=1
                end
            end
            cache.box.Visible=false;cache.fill.Visible=false
            cache.name.Visible=false;cache.hp.Visible=false
            cache.dist.Visible=false;cache.tracer.Visible=false
            cache.healthbar.Visible=false;cache.healthfill.Visible=false
            for _,b in ipairs(cache.bones) do b.Visible=false end
            continue
        end
        cache.arrow.Visible=false
        local h=math.abs(tP.Y-bP.Y)
        local w=math.max(h*0.5,18)
        local x=tP.X-w/2; local y=tP.Y

        -- Filled box
        cache.fill.Visible=S.esp_filled
        cache.fill.Size=Vector2.new(w,h); cache.fill.Position=Vector2.new(x,y)
        cache.fill.Color=col; cache.fill.Filled=true
        cache.fill.Transparency=1-(S.esp_fill_op/100); cache.fill.Thickness=0

        -- Box
        cache.box.Visible=S.esp_boxes
        cache.box.Size=Vector2.new(w,h); cache.box.Position=Vector2.new(x,y)
        cache.box.Color=col; cache.box.Filled=false
        cache.box.Thickness=S.esp_thickness; cache.box.Transparency=1

        -- HP bar (sol kenar)
        if S.esp_health then
            local pct=hum.Health/hum.MaxHealth
            local barH=h; local barW=3
            cache.healthbar.Visible=true
            cache.healthbar.Size=Vector2.new(barW,barH)
            cache.healthbar.Position=Vector2.new(x-barW-2,y)
            cache.healthbar.Color=Color3.fromRGB(30,30,30)
            cache.healthbar.Filled=true; cache.healthbar.Transparency=1
            cache.healthfill.Visible=true
            cache.healthfill.Size=Vector2.new(barW,barH*pct)
            cache.healthfill.Position=Vector2.new(x-barW-2,y+barH*(1-pct))
            cache.healthfill.Color=Color3.fromRGB(
                math.floor((1-pct)*255),math.floor(pct*200),50)
            cache.healthfill.Filled=true; cache.healthfill.Transparency=1
            -- HP yazısı
            cache.hp.Visible=true
            cache.hp.Text=math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
            cache.hp.Position=Vector2.new(x+w/2,y+h+2)
            cache.hp.Color=Color3.fromRGB(255,255,255)
            cache.hp.Size=11; cache.hp.Center=true
            cache.hp.Outline=true; cache.hp.Transparency=1
        else
            cache.healthbar.Visible=false
            cache.healthfill.Visible=false
            cache.hp.Visible=false
        end

        -- İsim
        cache.name.Visible=S.esp_names
        cache.name.Text=p.Name
        cache.name.Position=Vector2.new(x+w/2,y-16)
        cache.name.Color=Color3.fromRGB(255,255,255)
        cache.name.Size=13; cache.name.Center=true
        cache.name.Outline=true; cache.name.Transparency=1

        -- Mesafe
        cache.dist.Visible=S.esp_dist
        cache.dist.Text=math.floor(dist).."m"
        cache.dist.Position=Vector2.new(x+w/2,y+h+14)
        cache.dist.Color=Color3.fromRGB(200,200,200)
        cache.dist.Size=11; cache.dist.Center=true
        cache.dist.Outline=true; cache.dist.Transparency=1

        -- Tracer
        if S.esp_tracer then
            local vp=Cam.ViewportSize
            local oy=S.esp_tracer_orig=="Bottom" and vp.Y
                  or S.esp_tracer_orig=="Center" and vp.Y/2 or 0
            cache.tracer.Visible=true
            cache.tracer.From=Vector2.new(vp.X/2,oy)
            cache.tracer.To=bP; cache.tracer.Color=col
            cache.tracer.Thickness=1; cache.tracer.Transparency=1
        else cache.tracer.Visible=false end

        -- Skeleton
        if S.esp_skeletons then
            local sk={
                {"Head","UpperTorso"},{"Head","Torso"},
                {"UpperTorso","LowerTorso"},{"Torso","HumanoidRootPart"},
                {"LowerTorso","HumanoidRootPart"},
                {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},
                {"RightLowerArm","RightHand"},
                {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},
                {"LeftLowerArm","LeftHand"},
                {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},
                {"RightLowerLeg","RightFoot"},
                {"LowerTorso","LeftUpperLeg"},
            }
            for i,pair in ipairs(sk) do
                local b=cache.bones[i]
                local p1=char:FindFirstChild(pair[1],true)
                local p2=char:FindFirstChild(pair[2],true)
                if p1 and p2 then
                    local s1,v1=W(p1.Position); local s2,v2=W(p2.Position)
                    if v1 and v2 then
                        b.Visible=true; b.From=s1; b.To=s2
                        b.Color=col; b.Thickness=1; b.Transparency=1
                    else b.Visible=false end
                else b.Visible=false end
            end
        else for _,b in ipairs(cache.bones) do b.Visible=false end end
    end
end

-- ============================================================
-- FOV + AIMBOT
-- ============================================================
local FC=D("Circle")
FC.Visible=false; FC.Filled=false
FC.Color=Color3.fromRGB(255,255,255)
FC.Thickness=1; FC.Transparency=1; FC.NumSides=64

local AimOn=false
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==S.aim_key then AimOn=true end
end)
UIS.InputEnded:Connect(function(i)
    if i.KeyCode==S.aim_key then AimOn=false end
end)

local function GT()
    local vp=Cam.ViewportSize
    local cen=Vector2.new(vp.X/2,vp.Y/2)
    local best,bd=nil,math.huge
    for _,p in ipairs(Plr:GetPlayers()) do
        if p==LP then continue end
        -- Aynı takımda değilse hedef al
        -- BloxStrike 5v5, aynı takım vurulmaz
        local myTeam=LP.Team
        if myTeam and p.Team==myTeam then continue end
        local char=p.Character; if not char then continue end
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local part=char:FindFirstChild(S.aim_part) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local sc,vis=Cam:WorldToViewportPoint(part.Position)
        if not vis then continue end
        if S.aim_vis and not IsVis(Cam.CFrame.Position,part.Position) then continue end
        local d=(Vector2.new(sc.X,sc.Y)-cen).Magnitude
        if d<S.aim_fov and d<bd then bd=d; best=part end
    end
    return best
end

-- ============================================================
-- SKIN CHANGER
-- BloxStrike skin sistemi: her silah tool'unun altında BasePart'lar var.
-- Skin değiştirme = part renklerini + SurfaceAppearance TextureId'sini
-- CS2'ye benzer pattern ile override etme.
-- Runtime'da oyunun kendi TextureId'leri varsa onları da override eder.
-- ============================================================
local SkinApplied={}

local function ApplySkinToTool(tool, skinData)
    if not tool or not skinData then return end
    for _,part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
            -- Renk uygula
            part.Color=skinData.color
            part.Material=Enum.Material.SmoothPlastic
            -- SurfaceAppearance varsa texture'ı temizle (renk ön plana geçsin)
            local sa=part:FindFirstChildOfClass("SurfaceAppearance")
            if sa then
                sa.ColorMap=""
                sa.NormalMap=""
                sa.RoughnessMap=""
                sa.MetalnessMap=""
            end
            -- SpecialMesh texture varsa temizle
            local sm=part:FindFirstChildOfClass("SpecialMesh")
            if sm then sm.TextureId="" end
        end
    end
    -- Blade/Handle gradient için metalik görünüm
    -- Bıçak ise parlaklık ver
    if skinData.weapon:lower():find("knife") or skinData.weapon:lower():find("karambit")
    or skinData.weapon:lower():find("bayonet") or skinData.weapon:lower():find("dagger") then
        for _,part in ipairs(tool:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Reflectance=0.4
                part.Material=Enum.Material.Metal
            end
        end
    end
end

local function FindCurrentSkin()
    for _,s in ipairs(SKINS) do
        if s.weapon==S.skin_weapon and s.name==S.skin_name then
            return s
        end
    end
    return nil
end

local function ApplySkin()
    if not S.skin_on then return end
    local char=LP.Character; if not char then return end
    local skinData=FindCurrentSkin(); if not skinData then return end
    -- Tüm tool'ları tara
    for _,child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            -- Tool ismi silah adıyla eşleşiyor mu?
            local tname=child.Name:lower()
            local wname=skinData.weapon:lower()
            if tname:find(wname) or wname:find(tname) or
               -- Alternatif eşleşme: kısaltmalar
               (wname=="ak-47" and tname:find("ak")) or
               (wname=="m4a4" and tname:find("m4a4")) or
               (wname=="m4a1-s" and tname:find("m4a1")) or
               (wname=="awp" and tname:find("awp")) or
               (wname:find("knife") and tname:find("knife")) or
               (wname=="karambit" and tname:find("karambit")) or
               (wname=="bayonet" and (tname:find("bayonet") or tname:find("knife"))) then
                ApplySkinToTool(child, skinData)
                SkinApplied[child]=skinData
            end
        end
    end
end

-- Silah değişimini izle
LP.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and S.skin_on then
            task.wait(0.1)
            ApplySkin()
        end
    end)
end)
if LP.Character then
    LP.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and S.skin_on then
            task.wait(0.1)
            ApplySkin()
        end
    end)
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
RS.RenderStepped:Connect(function(dt)
    -- ESP
    RE_()

    -- FOV
    if S.aim_on and S.aim_fov_show then
        local vp=Cam.ViewportSize
        FC.Visible=true
        FC.Position=Vector2.new(vp.X/2,vp.Y/2)
        FC.Radius=S.aim_fov
        FC.Color=Color3.fromRGB(255,255,255)
    else FC.Visible=false end

    -- Aimbot
    if S.aim_on and AimOn then
        local target=GT()
        if target then
            local tPos=target.Position
            if S.aim_pred then
                local vel=target.AssemblyLinearVelocity or Vector3.zero
                tPos=tPos+vel*(S.aim_pred_ms/1000)
            end
            local smooth=S.aim_smooth/100
            local look=CFrame.new(Cam.CFrame.Position,tPos)
            Cam.CFrame=Cam.CFrame:Lerp(look,smooth)
        end
    end

    -- Skin changer — her 30 frame'de bir kontrol (gereksiz spam yok)
    if S.skin_on and RS.RenderStepped:IsConnected() then
        -- frame sayacı yerine basit tick
    end
end)

-- Skin her 2 saniyede bir yenile (kaybolma önleme)
task.spawn(function()
    while true do
        task.wait(2)
        if S.skin_on then
            pcall(ApplySkin)
        end
    end
end)

-- ============================================================
-- GUI
-- ============================================================
local SG=Instance.new("ScreenGui")
SG.Name="BS_"..math.random(1e8)
SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.DisplayOrder=999
pcall(function()
    SG.Parent=gethui and gethui() or game:GetService("CoreGui")
end)
if not SG.Parent then SG.Parent=LP.PlayerGui end

local C2={
    bg=Color3.fromRGB(12,12,20),
    bar=Color3.fromRGB(25,25,45),
    acc=Color3.fromRGB(80,120,255),
    acc2=Color3.fromRGB(50,200,255),
    wh=Color3.fromRGB(255,255,255),
    gr=Color3.fromRGB(160,170,200),
    row=Color3.fromRGB(18,20,35),
    ton=Color3.fromRGB(60,100,220),
    tof=Color3.fromRGB(30,30,60),
    red=Color3.fromRGB(220,60,60),
}

local MIN=false; local FH=530; local MH=40

local Root=Instance.new("Frame")
Root.Size=UDim2.new(0,560,0,FH)
Root.Position=UDim2.new(0.5,-280,0.5,-265)
Root.BackgroundColor3=C2.bg; Root.BorderSizePixel=0
Root.ClipsDescendants=true; Root.Parent=SG
Instance.new("UICorner",Root).CornerRadius=UDim.new(0,10)

-- Gradient
local gr=Instance.new("UIGradient")
gr.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(12,12,25)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(8,8,18)),
})
gr.Rotation=90; gr.Parent=Root

-- Title bar
local TB=Instance.new("Frame")
TB.Size=UDim2.new(1,0,0,40); TB.BackgroundColor3=C2.bar
TB.BorderSizePixel=0; TB.Parent=Root
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,10)

-- Accent line
local AL=Instance.new("Frame")
AL.Size=UDim2.new(1,0,0,2); AL.Position=UDim2.new(0,0,1,-2)
AL.BorderSizePixel=0; AL.Parent=TB
local ag=Instance.new("UIGradient")
ag.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,C2.acc),
    ColorSequenceKeypoint.new(0.5,C2.acc2),
    ColorSequenceKeypoint.new(1,C2.acc),
})
ag.Parent=AL

local TL=Instance.new("TextLabel")
TL.Size=UDim2.new(1,-100,1,0); TL.Position=UDim2.new(0,14,0,0)
TL.BackgroundTransparency=1; TL.Text="◈ BloxStrike Cheat v1.0"
TL.TextColor3=C2.wh; TL.TextSize=14; TL.Font=Enum.Font.GothamBold
TL.TextXAlignment=Enum.TextXAlignment.Left; TL.Parent=TB

-- Minimize
local MB=Instance.new("TextButton")
MB.Size=UDim2.new(0,28,0,24); MB.Position=UDim2.new(1,-72,0,8)
MB.BackgroundColor3=Color3.fromRGB(50,50,100); MB.Text="−"
MB.TextColor3=C2.wh; MB.TextSize=16; MB.Font=Enum.Font.GothamBold
MB.BorderSizePixel=0; MB.Parent=TB
Instance.new("UICorner",MB).CornerRadius=UDim.new(0,6)
MB.MouseButton1Click:Connect(function()
    MIN=not MIN
    TS:Create(Root,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{
        Size=UDim2.new(0,560,0,MIN and MH or FH)
    }):Play()
    MB.Text=MIN and "+" or "−"
end)

-- Kapat
local XB=Instance.new("TextButton")
XB.Size=UDim2.new(0,28,0,24); XB.Position=UDim2.new(1,-38,0,8)
XB.BackgroundColor3=C2.red; XB.Text="✕"
XB.TextColor3=C2.wh; XB.TextSize=13; XB.Font=Enum.Font.GothamBold
XB.BorderSizePixel=0; XB.Parent=TB
Instance.new("UICorner",XB).CornerRadius=UDim.new(0,6)
XB.MouseButton1Click:Connect(function() Root.Visible=false end)

-- Drag
local dg,ds,sp=false,nil,nil
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dg=true; ds=i.Position; sp=Root.Position end
end)
TB.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=false end
end)
UIS.InputChanged:Connect(function(i)
    if dg and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-ds
        Root.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)

-- Tab bar
local TabBar=Instance.new("Frame")
TabBar.Size=UDim2.new(1,0,0,34); TabBar.Position=UDim2.new(0,0,0,40)
TabBar.BackgroundColor3=Color3.fromRGB(10,10,18); TabBar.BorderSizePixel=0
TabBar.Parent=Root
local TBL2=Instance.new("UIListLayout")
TBL2.FillDirection=Enum.FillDirection.Horizontal
TBL2.SortOrder=Enum.SortOrder.LayoutOrder
TBL2.Padding=UDim.new(0,1); TBL2.Parent=TabBar

local Con=Instance.new("Frame")
Con.Size=UDim2.new(1,0,1,-74); Con.Position=UDim2.new(0,0,0,74)
Con.BackgroundTransparency=1; Con.Parent=Root

local TABS,PANELS={},{}
local function MT(name,order)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,133,1,0); btn.BackgroundColor3=Color3.fromRGB(15,15,28)
    btn.TextColor3=C2.gr; btn.Text=name; btn.TextSize=12
    btn.Font=Enum.Font.GothamSemibold; btn.BorderSizePixel=0
    btn.LayoutOrder=order; btn.Parent=TabBar

    -- Alt çizgi aktif gösterge
    local ul=Instance.new("Frame")
    ul.Size=UDim2.new(1,0,0,2); ul.Position=UDim2.new(0,0,1,-2)
    ul.BackgroundColor3=C2.acc; ul.BorderSizePixel=0; ul.Visible=false; ul.Parent=btn

    local pan=Instance.new("ScrollingFrame")
    pan.Size=UDim2.new(1,0,1,0); pan.BackgroundTransparency=1
    pan.BorderSizePixel=0; pan.ScrollBarThickness=3
    pan.ScrollBarImageColor3=C2.acc; pan.CanvasSize=UDim2.new(0,0,0,0)
    pan.AutomaticCanvasSize=Enum.AutomaticSize.Y
    pan.Visible=false; pan.Parent=Con

    local lay=Instance.new("UIListLayout")
    lay.SortOrder=Enum.SortOrder.LayoutOrder
    lay.Padding=UDim.new(0,4); lay.Parent=pan
    local pad=Instance.new("UIPadding")
    pad.PaddingLeft=UDim.new(0,10); pad.PaddingRight=UDim.new(0,10)
    pad.PaddingTop=UDim.new(0,8); pad.Parent=pan

    TABS[name]={btn=btn,ul=ul}; PANELS[name]=pan
    btn.MouseButton1Click:Connect(function()
        for n,t in pairs(TABS) do
            t.btn.BackgroundColor3=Color3.fromRGB(15,15,28)
            t.btn.TextColor3=C2.gr; t.ul.Visible=false
            PANELS[n].Visible=false
        end
        btn.BackgroundColor3=Color3.fromRGB(20,20,40)
        btn.TextColor3=C2.wh; ul.Visible=true; pan.Visible=true
    end)
    return pan
end

local ord2=0
local function O2() ord2=ord2+1; return ord2 end

local function SL(pan,txt)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,18); f.BackgroundColor3=Color3.fromRGB(25,25,50)
    f.BorderSizePixel=0; f.LayoutOrder=O2(); f.Parent=pan
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-8,1,0); l.Position=UDim2.new(0,8,0,0)
    l.BackgroundTransparency=1; l.Text="› "..txt
    l.TextColor3=C2.acc; l.TextSize=11; l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=f
end

local function Tog(pan,lbl,key,cb)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,28); row.BackgroundColor3=C2.row
    row.BorderSizePixel=0; row.LayoutOrder=O2(); row.Parent=pan
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0.7,0,1,0); l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1; l.Text=lbl; l.TextColor3=C2.gr
    l.TextSize=12; l.Font=Enum.Font.Gotham
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=row
    local tf=Instance.new("Frame")
    tf.Size=UDim2.new(0,38,0,18); tf.Position=UDim2.new(1,-46,0.5,-9)
    tf.BackgroundColor3=S[key] and C2.ton or C2.tof
    tf.BorderSizePixel=0; tf.Parent=row
    Instance.new("UICorner",tf).CornerRadius=UDim.new(1,0)
    local kn=Instance.new("Frame")
    kn.Size=UDim2.new(0,14,0,14)
    kn.Position=S[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    kn.BackgroundColor3=C2.wh; kn.BorderSizePixel=0; kn.Parent=tf
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1
    btn.Text=""; btn.Parent=row
    btn.MouseButton1Click:Connect(function()
        S[key]=not S[key]; local on=S[key]
        tf.BackgroundColor3=on and C2.ton or C2.tof
        TS:Create(kn,TweenInfo.new(0.1),{
            Position=on and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
        }):Play()
        if cb then cb(on) end
    end)
end

local function Sld(pan,lbl,key,mn,mx,suf,cb)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,44); row.BackgroundColor3=C2.row
    row.BorderSizePixel=0; row.LayoutOrder=O2(); row.Parent=pan
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0.6,0,0,18); l.Position=UDim2.new(0,8,0,3)
    l.BackgroundTransparency=1; l.Text=lbl; l.TextColor3=C2.gr
    l.TextSize=11; l.Font=Enum.Font.Gotham
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=row
    local vl=Instance.new("TextLabel")
    vl.Size=UDim2.new(0.35,0,0,18); vl.Position=UDim2.new(0.62,0,0,3)
    vl.BackgroundTransparency=1; vl.Text=tostring(S[key])..(suf or "")
    vl.TextColor3=C2.acc2; vl.TextSize=11; vl.Font=Enum.Font.GothamBold
    vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Parent=row
    local tr=Instance.new("Frame")
    tr.Size=UDim2.new(1,-16,0,4); tr.Position=UDim2.new(0,8,0,28)
    tr.BackgroundColor3=Color3.fromRGB(30,30,60); tr.BorderSizePixel=0; tr.Parent=row
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
    local fi=Instance.new("Frame")
    local p0=math.clamp((S[key]-mn)/(mx-mn),0,1)
    fi.Size=UDim2.new(p0,0,1,0); fi.BackgroundColor3=C2.acc
    fi.BorderSizePixel=0; fi.Parent=tr
    Instance.new("UICorner",fi).CornerRadius=UDim.new(1,0)
    local sb=Instance.new("TextButton")
    sb.Size=UDim2.new(1,0,3,0); sb.Position=UDim2.new(0,0,-1,0)
    sb.BackgroundTransparency=1; sb.Text=""; sb.Parent=tr
    local sl2=false
    sb.MouseButton1Down:Connect(function() sl2=true end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sl2=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if sl2 and i.UserInputType==Enum.UserInputType.MouseMovement then
            local rx=math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
            local val=math.floor(mn+rx*(mx-mn))
            S[key]=val; fi.Size=UDim2.new(rx,0,1,0)
            vl.Text=tostring(val)..(suf or "")
            if cb then cb(val) end
        end
    end)
end

local function DD(pan,lbl,key,opts,cb)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,28); row.BackgroundColor3=C2.row
    row.BorderSizePixel=0; row.LayoutOrder=O2(); row.Parent=pan
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0.45,0,1,0); l.Position=UDim2.new(0,8,0,0)
    l.BackgroundTransparency=1; l.Text=lbl; l.TextColor3=C2.gr
    l.TextSize=11; l.Font=Enum.Font.Gotham
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=row
    local cur=Instance.new("TextButton")
    cur.Size=UDim2.new(0.5,0,0,20); cur.Position=UDim2.new(0.47,0,0.5,-10)
    cur.BackgroundColor3=Color3.fromRGB(25,25,55)
    cur.TextColor3=C2.wh; cur.Text=S[key].." ▾"
    cur.TextSize=10; cur.Font=Enum.Font.Gotham
    cur.BorderSizePixel=0; cur.Parent=row
    Instance.new("UICorner",cur).CornerRadius=UDim.new(0,4)
    local exp2=false; local dl2
    cur.MouseButton1Click:Connect(function()
        exp2=not exp2
        if dl2 then dl2:Destroy(); dl2=nil end
        if not exp2 then return end
        local maxShow=math.min(#opts,10)
        dl2=Instance.new("ScrollingFrame")
        dl2.Size=UDim2.new(0,160,0,maxShow*22+4)
        dl2.Position=UDim2.new(1,-168,1,2)
        dl2.BackgroundColor3=Color3.fromRGB(20,20,40)
        dl2.BorderSizePixel=0; dl2.ZIndex=15
        dl2.ScrollBarThickness=3; dl2.ScrollBarImageColor3=C2.acc
        dl2.CanvasSize=UDim2.new(0,0,0,#opts*22+4)
        dl2.Parent=row
        Instance.new("UICorner",dl2).CornerRadius=UDim.new(0,6)
        local ll2=Instance.new("UIListLayout")
        ll2.SortOrder=Enum.SortOrder.LayoutOrder; ll2.Parent=dl2
        for i,opt in ipairs(opts) do
            local ob=Instance.new("TextButton")
            ob.Size=UDim2.new(1,0,0,22)
            ob.BackgroundColor3=opt==S[key] and Color3.fromRGB(40,40,90) or Color3.fromRGB(20,20,40)
            ob.TextColor3=C2.wh; ob.Text=opt; ob.TextSize=10
            ob.Font=Enum.Font.Gotham; ob.BorderSizePixel=0
            ob.LayoutOrder=i; ob.ZIndex=16; ob.Parent=dl2
            ob.MouseButton1Click:Connect(function()
                S[key]=opt; cur.Text=opt.." ▾"
                dl2:Destroy(); dl2=nil; exp2=false
                if cb then cb(opt) end
            end)
        end
    end)
end

local function KB(pan,lbl,key)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,28); row.BackgroundColor3=C2.row
    row.BorderSizePixel=0; row.LayoutOrder=O2(); row.Parent=pan
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0.55,0,1,0); l.Position=UDim2.new(0,8,0,0)
    l.BackgroundTransparency=1; l.Text=lbl; l.TextColor3=C2.gr
    l.TextSize=11; l.Font=Enum.Font.Gotham
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=row
    local kb=Instance.new("TextButton")
    kb.Size=UDim2.new(0.38,0,0,20); kb.Position=UDim2.new(0.59,0,0.5,-10)
    kb.BackgroundColor3=Color3.fromRGB(30,30,70)
    kb.TextColor3=C2.wh
    kb.Text=tostring(S[key]):gsub("Enum.KeyCode.","")
    kb.TextSize=10; kb.Font=Enum.Font.GothamBold; kb.BorderSizePixel=0; kb.Parent=row
    Instance.new("UICorner",kb).CornerRadius=UDim.new(0,4)
    local li2=false
    kb.MouseButton1Click:Connect(function()
        li2=true; kb.Text="..."; kb.BackgroundColor3=Color3.fromRGB(180,80,30)
    end)
    UIS.InputBegan:Connect(function(i,gp)
        if not li2 then return end
        if i.UserInputType==Enum.UserInputType.Keyboard then
            S[key]=i.KeyCode
            kb.Text=tostring(i.KeyCode):gsub("Enum.KeyCode.","")
            kb.BackgroundColor3=Color3.fromRGB(30,30,70); li2=false
        end
    end)
end

-- ============================================================
-- PANELLER
-- ============================================================
local PE=MT("⬜ ESP",      1)
local PA=MT("🎯 Aimbot",  2)
local PK=MT("🎨 Skin",    3)
local PS=MT("⚙ Ayarlar", 4)

-- ESP
SL(PE,"Genel")
Tog(PE,"ESP Aktif",         "esp_on")
Tog(PE,"Kutular",           "esp_boxes")
Tog(PE,"İskelet",           "esp_skeletons")
Tog(PE,"İsimler",           "esp_names")
Tog(PE,"Sağlık Barı",       "esp_health")
Tog(PE,"Mesafe",            "esp_dist")
Tog(PE,"Görüş Kontrolü",    "esp_vis")
Tog(PE,"Ok İşareti",        "esp_arrows")
SL(PE,"Kutu")
Tog(PE,"Dolu Kutu",         "esp_filled")
Sld(PE,"Dolgu Opaklığı",    "esp_fill_op",0,100,"%")
Sld(PE,"Çizgi Kalınlığı",   "esp_thickness",1,5,"px")
Sld(PE,"Max Mesafe",        "esp_max_dist",100,5000,"m")
SL(PE,"Renk & Tracer")
DD(PE,"Renk Modu",          "esp_color_mode",{"Team","Static","Health"})
Tog(PE,"Tracer",            "esp_tracer")
DD(PE,"Tracer Başlangıç",   "esp_tracer_orig",{"Bottom","Center","Top"})

-- Aimbot
SL(PA,"Aimbot")
Tog(PA,"Aimbot Aktif",      "aim_on")
Tog(PA,"FOV Çemberi",       "aim_fov_show")
Tog(PA,"Görüş Kontrolü",    "aim_vis")
Tog(PA,"Tahmin",            "aim_pred")
SL(PA,"Ayarlar")
Sld(PA,"FOV Yarıçapı",      "aim_fov",20,500,"px")
Sld(PA,"Yumuşatma",         "aim_smooth",1,100,"%")
Sld(PA,"Tahmin ms",         "aim_pred_ms",0,300,"ms")
DD(PA,"Hedef Part",         "aim_part",{"Head","UpperTorso","HumanoidRootPart"})
SL(PA,"Tuş")
KB(PA,"Aimbot Tuşu",        "aim_key")

-- Skin Changer
SL(PK,"Skin Changer")
Tog(PK,"Skin Aktif",        "skin_on", function(on)
    if on then pcall(ApplySkin) end
end)

-- Silah seçim dropdown
local weaponList={}
for _,w in ipairs(WEAPONS) do table.insert(weaponList,w) end
DD(PK,"Silah",              "skin_weapon", weaponList, function(w)
    -- Seçili silaha ait ilk skini varsayılan yap
    for _,sk in ipairs(SKINS) do
        if sk.weapon==w then S.skin_name=sk.name; break end
    end
    if S.skin_on then pcall(ApplySkin) end
end)

-- Skin seçim dropdown (dinamik — seçili silaha göre filtrele)
local skinNameList={}
for _,sk in ipairs(SKINS) do
    if sk.weapon==S.skin_weapon then
        table.insert(skinNameList, sk.name)
    end
end
DD(PK,"Skin",               "skin_name", #skinNameList>0 and skinNameList or {"Default"},
function(n)
    if S.skin_on then pcall(ApplySkin) end
end)

-- Uygula butonu
local applyBtn=Instance.new("TextButton")
applyBtn.Size=UDim2.new(1,0,0,32); applyBtn.LayoutOrder=O2()
applyBtn.BackgroundColor3=C2.acc; applyBtn.TextColor3=C2.wh
applyBtn.Text="▶ Skin Uygula"; applyBtn.TextSize=13
applyBtn.Font=Enum.Font.GothamBold; applyBtn.BorderSizePixel=0
applyBtn.Parent=PK
Instance.new("UICorner",applyBtn).CornerRadius=UDim.new(0,6)
applyBtn.MouseButton1Click:Connect(function()
    S.skin_on=true
    pcall(ApplySkin)
    applyBtn.Text="✓ Uygulandı"
    task.delay(1.5, function() applyBtn.Text="▶ Skin Uygula" end)
end)

SL(PK,"Bilgi")
local info=Instance.new("TextLabel")
info.Size=UDim2.new(1,0,0,60); info.LayoutOrder=O2()
info.BackgroundTransparency=1
info.Text="Skin changer silah rengini +\nmetal dokusunu değiştirir.\nSilahı ekip/çıkar → tekrar uygula."
info.TextColor3=C2.gr; info.TextSize=11; info.Font=Enum.Font.Gotham
info.TextXAlignment=Enum.TextXAlignment.Left
info.TextWrapped=true; info.Parent=PK

-- Ayarlar
SL(PS,"Menü")
KB(PS,"Aç/Kapa Tuşu",       "menu_key")

-- İlk tab aç
TABS["⬜ ESP"].btn.BackgroundColor3=Color3.fromRGB(20,20,40)
TABS["⬜ ESP"].btn.TextColor3=C2.wh
TABS["⬜ ESP"].ul.Visible=true
PANELS["⬜ ESP"].Visible=true

-- INSERT menü toggle
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==S.menu_key then Root.Visible=not Root.Visible end
end)

print("[BloxStrike Cheat v1.0] Yüklendi")
print("[ESP] INSERT=menü | Aimbot=RightAlt | Skin=Skin sekmesi")
