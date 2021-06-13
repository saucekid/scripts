
--[[

▓██   ██▓▓█████ ▓█████  ██░ ██  ▄▄▄       █     █░
 ▒██  ██▒▓█   ▀ ▓█   ▀ ▓██░ ██▒▒████▄    ▓█░ █ ░█░
  ▒██ ██░▒███   ▒███   ▒██▀▀██░▒██  ▀█▄  ▒█░ █ ░█ 
  ░ ▐██▓░▒▓█  ▄ ▒▓█  ▄ ░▓█ ░██ ░██▄▄▄▄██ ░█░ █ ░█ 
  ░ ██▒▓░░▒████▒░▒████▒░▓█▒░██▓ ▓█   ▓██▒░░██▒██▓ 
   ██▒▒▒ ░░ ▒░ ░░░ ▒░ ░ ▒ ░░▒░▒ ▒▒   ▓▒█░░ ▓░▒ ▒  
 ▓██ ░▒░  ░ ░  ░ ░ ░  ░ ▒ ░▒░ ░  ▒   ▒▒ ░  ▒ ░ ░  
 ▒ ▒ ░░     ░      ░    ░  ░░ ░  ░   ▒     ░   ░  
 ░ ░        ░  ░   ░  ░ ░  ░  ░      ░  ░    ░    
 ░ ░        
Credits:
ThisStuff - Instant Reload and TP bypass
casual_degenerate(discord) - quick respawn 
=======================================================================
	Join the discord: https://discord.gg/DnyxZRwQh3
]]--

if _G.Executed1 then repeat wait() until false end
_G.Executed1 = true

local Players = game:GetService("Players");     ----------------------sorry for messy code
local Lighting = game:GetService("Lighting");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ScriptContext = game:GetService("ScriptContext");
local VirtualUser = game:GetService("VirtualUser");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();
local CurrentCamera = workspace.CurrentCamera;
local Entities = game.workspace:FindFirstChild("WORKSPACE_Entities");

for _, connection in ipairs(getconnections(ScriptContext.Error)) do
connection:Disable();
end

loadstring(game:HttpGet("https://irisapp.ca/api/Scripts/IrisBetterCompat.lua"))()
local LoadModule = require(ReplicatedStorage.Modules.Load);
local LoadSharedModule = require(ReplicatedStorage.SharedModules.Load);
local Global = require(game:GetService("ReplicatedStorage").SharedModules.Global);
local AnimalModule, BreakableGlassModule, CameraModule, ClientProjectiles, GunItemModule, NetworkModule, PlayerCharacterModule, SharedUtilsModule, UtilsModule, PlayerDataModule, UIHandlerModule, SharedUtilsModule, ProjectileHandlerModule; do
AnimalModule = LoadModule("Animal");
BreakableGlassModule = LoadModule("BreakableGlass");
CameraModule = LoadModule("Camera");
ClientProjectiles = LoadModule("ClientProjectiles");
GunItemModule = LoadModule("GunItem");
NetworkModule = LoadSharedModule("Network");
PlayerCharacterModule = LoadModule("PlayerCharacter");
PlayerDataModule = LoadModule("PlayerData");
SharedUtilsModule = LoadSharedModule("SharedUtils");
CharRepUtilsModule = LoadSharedModule("CharRepUtils");
UtilsModule = LoadModule("Utils");
SharedUtilsModule = LoadSharedModule("SharedUtils");
UIHandlerModule = LoadModule("UIHandler");
ContainerUIModule = LoadModule("ContainerUI");
ProjectileHandlerModule = LoadModule("ProjectileHandler");
end

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/UI-Libraries/main/ESPLibrary.lua"))();
local library
local radiuscircle = Drawing.new('Circle')
local keyheld = false

local oldLighting = {
    Ambient = Lighting.Ambient,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top
}

local places = {                --thanks casualdegenerate
	{"Bronze City","Bronze"},
	{"Puerto Dorado","Dorado"},
	{"Tribal Village","Tribal"},
	{"Callahan Manor","Delores"},
	{"Howling Peak","HowlingPeak"},
	{"Windmill Camp(+5)","WindmillCamp"},
	{"Outlaw's Perch(+5)","CanyonCamp"}
}

local weapons = {}
weapons.ogvalues = {}
weapons.realweapons = {}

local horses = {}


--====================================={SETTINGS}=====================================--
local afsettings = {}
afsettings.PathColor = Color3.fromRGB(0, 10, 0)
afsettings.bearbool = false
afsettings.orebool = false
afsettings.slots = {}
afsettings.slots.ofarm = "3"
afsettings.slots.bfarm = "1"

local settings = {}
settings.sizepulse = false;
settings.ragdollspeed = 1;
settings.antiracist = false;
settings.antiragdoll = false;
settings.nofalldamage = false;
settings.nojumpcooldown = false;
settings.instantbreakfree = false;
settings.instantgetup = false;
settings.infinitestamina = false;
settings.alwaysroll = false;
settings.rollspeed = false;
settings.ragdolldirection = "lookVector";
settings.nospread = false;
settings.norecoil = false;
settings.nodelay = false;
settings.alwaysguns = false;
settings.instantreload = false;
settings.infinitepenetration = false;
settings.mineaura = false;
settings.semiautosell = false;
settings.mineauradistance = 11;
settings.ragdollwalk = false;

settings.aim = {}
settings.aim.aimbot = false;
settings.aim.silentaim = false;
settings.aim.smoothness = 0.5;
settings.aim.target = "Head";
settings.aim.mode = "Player";
settings.aim.visiblecheck = false;
settings.aim.teamcheck = false;
settings.aim.fovcircle = false;
settings.aim.fovcirclecolor = Color3.fromRGB(255,255,255);
settings.aim.fovcircleradius = 100;
settings.aim.fovcirclethickness = 2;
settings.aim.fovcircletransp = 1;

settings.esp = {}
settings.esp.toggle = false;
settings.esp.players = false;
settings.esp.animals = false;
settings.esp.thunderstruck = false;
settings.esp.ores = false;
settings.esp.items = false
settings.esp.moneybags = false;
settings.esp.legendary = false;
settings.esp.PlayerColor = Color3.fromRGB(255, 255, 255);
settings.esp.AnimColor = Color3.fromRGB(0, 255, 255);
settings.esp.tracers = false;
settings.esp.boxes = false;
settings.esp.names = true;
settings.esp.teamcolor = false;
settings.keys = {}
settings.keys.Suicide = "K"
settings.keys.Harmonica = "N"
settings.keys.Ragdoll = "L"
settings.keys.ragdollfly = "Z"
settings.keys.silentaim = "P"
settings.keys.callhorse = "J"

settings.horse = {}
settings.horse.infiniteboost = false
settings.horse.nohorseragdoll = false
settings.horse.horsenames = {}
settings.horse.speed = 50
settings.horse.editspeed = false
if Global.PlayerData:GetSortedHorses()[1] then
    settings.horse.horseid = Global.PlayerData:GetSortedHorses()[1].Id
end

ESP:AddObjectListener(Entities.Animals, {
    Type = "Model",
    PrimaryPart = "HumanoidRootPart",
    CustomName = function(obj)
        return obj.Name
    end,
    Color = function(obj)
        return settings.esp.AnimColor
    end,
    Validator = function(obj)
        if obj.Name ~= "Cow" and not string.find(obj.Name, "Horse") then
            local health = obj:WaitForChild("Health");
            if health and obj.Health.Value <= 200 then
                return true
            end
        end
        return false
    end,
    IsEnabled = "Animals"
})

ESP:AddObjectListener(Entities.Animals, {
    Type = "Model",
    PrimaryPart = "HumanoidRootPart",
    CustomName = function(obj)
        return "Legendary ".. obj.Name
    end,
    Color = function(obj)
        return Color3.fromRGB(255,255,0)
    end,
    Validator = function(obj)
        local health = obj:WaitForChild("Health");
        if health and obj.Health.Value > 200 then
            return true
        end
        return false
    end,
    IsEnabled = "Legendary"
})

ESP:AddObjectListener(game:GetService("Workspace")["WORKSPACE_Geometry"], {
    Recursive = true,
    Type = "Model",
    CustomName = "Thunderstruck Tree",
    PrimaryPart = function(obj)
        if obj.PrimaryPart.Name == "TreePivot" then
           return obj.Trunk 
        end
    end,
    Color = Color3.new(255,255,0),
    Validator = function(obj)
        if (obj.Name:find("Tree") or obj.Name:find("Wood"))  and obj.PrimaryPart.Name == "TreePivot" and obj.Trunk:FindFirstChild("Strike2") then
            return true
        end
        return false
    end,
    IsEnabled = "Thunderstruck"
})
    
ESP:AddObjectListener(game:GetService("Workspace")["WORKSPACE_Interactables"].Mining.OreDeposits, {
    Recursive = true,
    Type = "Model",
    PrimaryPart = function(obj)
       return obj.PrimaryPart
    end,
    CustomName = function(obj)
        return obj.Parent.Name
    end,
    Color = function(obj)
        local ore
        for i,v in pairs(obj:GetChildren()) do
            if string.find(v.Name, "Ore") then
                ore = v
            end
        end
        return ore.Color
    end,
    IsEnabled = "Ores"
})

ESP:AddObjectListener(workspace.Ignore, {
    Type = "Model",
    PrimaryPart = "Bag",
    CustomName = "Money Bag",
    Color = Color3.fromRGB(0,255,0),
    IsEnabled = "Moneybags"
})

ESP:AddObjectListener(workspace.Ignore, {
    Type = "Model",
    PrimaryPart = function(obj)
        return obj.PrimaryPart
    end,
    CustomName = function(obj)
    	local SplitLocation = string.find(obj.Name,"%l%u") 
	    local FirstString = string.sub(obj.Name,0,SplitLocation) 
	    local SecondString = string.sub(obj.Name,SplitLocation + 1) 
	    local FinalString = FirstString .. " " .. SecondString
	    return FinalString
    end,
    Color = Color3.fromRGB(0,255,0),
    Validator = function(obj)
        if obj.PrimaryPart and string.find(obj.PrimaryPart.Name, "Meshes/") then
            return true
        end
        return false
    end,
    IsEnabled = "Items"
})


ESP:Toggle(settings.esp.toggle)
ESP.Animals = settings.esp.animals
ESP.Players = settings.esp.players
ESP.Ores = settings.esp.ores
ESP.Thunderstruck = settings.esp.thunderstruck
ESP.Legendary = settings.esp.legendary
ESP.Moneybags = settings.esp.moneybags
ESP.Items = settings.esp.items
ESP.TeamColor = settings.esp.teamcolor
ESP.Tracers = settings.esp.tracers
ESP.Boxes = settings.esp.boxes
ESP.Color = settings.esp.PlayerColor
ESP.Health = false
--====================================={FUNCTIONS}=====================================--
local function notify(title,text,dur)
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = title,
        Text = text,
        Duration = dur or 5
    })
end

local function gamenotify(text,color)
        UIHandlerModule:GiveNotification({
        text = text,
        textcolor = color,
        center = true
    });
end

local function playsound(soundid, volume, dur)
    local sound = Instance.new("Sound", game.SoundService)
    sound.SoundId = soundid
    sound.Volume = volume
    local duration = dur or sound.TimeLength
    sound:Play()
    spawn(function()
        wait(duration)
        for i = 1,100 do
            sound.Volume = sound.Volume - (volume/100)
            wait()
        end
        sound:Destroy()
    end)
end

function PathFind(pos)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(plr.Character.HumanoidRootPart.Position, pos)
    local waypoints = path:GetWaypoints()
    for i, waypoint in ipairs(waypoints) do
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):MoveTo(waypoint.Position)
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Jump = true
        end
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveToFinished:Wait()
    end
end
    
function WorldToViewport(pos)
    return CurrentCamera:WorldToViewportPoint(pos)
end

function DistanceFromMouse(part)
    local screenPos, inView = WorldToViewport(part.Position)
    if inView then
        return (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
    end
end

function distanceFrom(a, b, unit)
    if unit == false or not unit then
    return (a - b).Magnitude
    elseif unit == true then
    return (a - b).Unit
    end
end

local partBlacklist = {}
function checkObstructed(from, to, dist, unit)
    local obstructed = false
    local dist = distanceFrom(CurrentCamera.CFrame.p, to.Position)
    local unit = distanceFrom(to.Position, CurrentCamera.CFrame.p, true)
    local list = {to.Parent, LocalPlayer.Character, unpack(partBlacklist)}
    local ray = Ray.new(from, unit * dist)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, list)
    if hit then
        obstructed = true
        if hit.Transparency >= .3 or not hit.CanCollide and hit.ClassName ~= Terrain then 
            partBlacklist[#partBlacklist + 1] = hit;
        end
    end
    return obstructed
end

function getPlayerClosestToMouse()
    local target = nil
    local maxDist = settings.aim.fovcircleradius
    for _,v in pairs(Players:GetPlayers()) do
        if v.Character and v ~= LocalPlayer then
            if v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") then
                if settings.aim.teamcheck and v.Team == LocalPlayer.Team then continue end
                local pos, vis = CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).magnitude
                if dist < maxDist and vis then
                    if settings.aim.target == "Automatic" then
                        local torsoPos = CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                        local torsoDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(torsoPos.X, torsoPos.Y)).magnitude
                        local headPos = CurrentCamera:WorldToViewportPoint(v.Character.Head.Position)
                        local headDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(headPos.X, headPos.Y)).magnitude
                        if torsoDist > headDist then
                            if settings.aim.visiblecheck and checkObstructed(CurrentCamera.CFrame.p, v.Character.Head) then return nil end
                            target = v.Character.Head
                        else
                            if settings.aim.visiblecheck and checkObstructed(CurrentCamera.CFrame.p, v.Character.HumanoidRootPart) then return nil end
                            target = v.Character.HumanoidRootPart
                        end
                    else
                        if settings.aim.visiblecheck and checkObstructed(CurrentCamera.CFrame.p, v.Character[settings.aim.target]) then return nil end
                        target = v.Character[settings.aim.target]
                    end
                    maxDist = dist
                end
            end
        end
    end
    return target
end


local function deepCopy(original) 
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end



local flying = false
local ctrl = {f = 0, b = 0, l = 0, r = 0} 
local lastctrl = {f = 0, b = 0, l = 0, r = 0} 
local maxspeed = 55
local speed = 55
function Fly() 
local torso = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if not torso then return end
local bg = Instance.new("BodyGyro", torso) 
bg.P = 9e4 
bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) 
bg.cframe = torso.CFrame 
local bv = Instance.new("BodyVelocity", torso) 
bv.velocity = Vector3.new(0,0.1,0) 
bv.maxForce = Vector3.new(9e9, 9e9, 9e9) 
repeat wait() 
LocalPlayer.Character.Humanoid.PlatformStand = true 
if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then 
speed = speed+.5+(speed/maxspeed) 
if speed > maxspeed then 
speed = maxspeed 
end 
elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then 
speed = speed-1 
if speed < 0 then 
speed = 0 
end 
end 
if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then 
bv.velocity = ((CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - CurrentCamera.CoordinateFrame.p))*speed 
lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r} 
elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then 
bv.velocity = ((CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - CurrentCamera.CoordinateFrame.p))*speed 
else 
bv.velocity = Vector3.new(0,0.1,0) 
end 
bg.cframe = CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0) 
until not flying 
ctrl = {f = 0, b = 0, l = 0, r = 0} 
lastctrl = {f = 0, b = 0, l = 0, r = 0} 
speed = 0 
bg:Destroy() 
bv:Destroy() 
LocalPlayer.Character.Humanoid.PlatformStand = false 
end 
Mouse.KeyDown:connect(function(key) 
if key:upper() == settings.keys.ragdollfly then 
if flying then flying = false 
    Global.PlayerCharacter:GetUp(game.Players.LocalPlayer.Character.HumanoidRootPart)
else 
flying = true 
 PlayerCharacterModule:Ragdoll(game.Players.LocalPlayer.Character.HumanoidRootPart, true, game.Players.LocalPlayer.Character.HumanoidRootPart.Position, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame[settings.ragdolldirection], settings.ragdollspeed*100, 'waddup')
Fly() 
end 
elseif key:lower() == "w" then 
ctrl.f = 1 
elseif key:lower() == "s" then 
ctrl.b = -1 
elseif key:lower() == "a" then 
ctrl.l = -1 
elseif key:lower() == "d" then 
ctrl.r = 1 
end 
end) 
Mouse.KeyUp:connect(function(key) 
if key:lower() == "w" then 
ctrl.f = 0 
elseif key:lower() == "s" then 
ctrl.b = 0 
elseif key:lower() == "a" then 
ctrl.l = 0 
elseif key:lower() == "d" then 
ctrl.r = 0 
end 
end)


function getAnimalClosestToMouse()
    local target = nil
    local maxDist = settings.aim.fovcircleradius
    for _,v in pairs(Entities.Animals:GetChildren()) do
        if v and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Health") and v.Name ~= "Cow" and not v.Name:find("Horse") then
            if v.Health.Value ~= 0 then
                local pos, vis = CurrentCamera:WorldToViewportPoint(v.HumanoidRootPart.Position)
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).magnitude
                if dist < maxDist and vis then
                    if settings.aim.target == "Automatic" then
                        local torsoPos = CurrentCamera:WorldToViewportPoint(v.HumanoidRootPart.Position)
                        local torsoDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(torsoPos.X, torsoPos.Y)).magnitude
                        local headPos = CurrentCamera:WorldToViewportPoint(v.Head.Position)
                        local headDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(headPos.X, headPos.Y)).magnitude
                        if torsoDist > headDist then
                            if settings.aim.visiblecheck and checkObstructed(CurrentCamera.CFrame.p, v.Head) then return nil end
                            target = v.Head
                        else
                            if settings.aim.visiblecheck and checkObstructed(CurrentCamera.CFrame.p, v.HumanoidRootPart) then return nil end
                            target = v.HumanoidRootPart
                        end
                    else
                        if settings.aim.visiblecheck and checkObstructed(CurrentCamera.CFrame.p, v[settings.aim.target]) then return nil end
                        target = v[settings.aim.target]
                    end
                    maxDist = dist
                end
            end
        end
    end
    return target
end

--==============================={Actual Script}=======================================--
for i, v in next, getgc(true) do
    if type(v) == "table" and rawget(v, "BaseRecoil") then
        weapons.ogvalues[i] = deepCopy(v)
        weapons.realweapons[i] = v
    end
end


for i, v in next, Global.PlayerData:GetSortedHorses() do
    table.insert(settings.horse.horsenames, v.Breed)
end

spawn(function()
    while RunService.RenderStepped:Wait() do
        if settings.sizepulse then
            for i = 0.1,1,.1 do
                Global.Network:FireServer("SetThicknessPercent", i);
                Global.Network:FireServer("SetHeightPercent", i);
                RunService.RenderStepped:Wait()
            end
            for i = 1,.1,-.1 do
                Global.Network:FireServer("SetThicknessPercent", i);
                Global.Network:FireServer("SetHeightPercent", i);
                RunService.RenderStepped:Wait()
            end
        end
        if settings.antiracist then
            for i = 1,10,1 do
                ReplicatedStorage.Communication.Events.SelectSkinColor:FireServer(i)
                RunService.RenderStepped:Wait()
            end
            for i = 10,1,-1 do
                ReplicatedStorage.Communication.Events.SelectSkinColor:FireServer(i)
                RunService.RenderStepped:Wait()
            end
        end
    end
end)


closed = false
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if closed == false then
            library.closeui()
            closed = not closed
        else
            library.openui()
            closed = not closed
        end
    end
    if input.KeyCode == Enum.KeyCode[settings.keys.callhorse] then
        if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            PlayerCharacterModule:Whistle()
            game:GetService("ReplicatedStorage").Communication.Events.CallAnimal:FireServer(settings.horse.horseid, LocalPlayer.Character.HumanoidRootPart.Position)
        end
    end
    if input.KeyCode == Enum.KeyCode[settings.keys.Suicide] then
        Global.Network:FireServer("DamageSelf", 100, 'waddup')
    end
    if input.KeyCode == Enum.KeyCode[settings.keys.Harmonica] then
        Global.PlayerCharacter:EquipItem('Harmonica')
    end
    if input.KeyCode == Enum.KeyCode[settings.keys.Ragdoll] then
        PlayerCharacterModule:Ragdoll(game.Players.LocalPlayer.Character.HumanoidRootPart, true, game.Players.LocalPlayer.Character.HumanoidRootPart.Position, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame[settings.ragdolldirection], settings.ragdollspeed*100, 'waddup')
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        keyheld = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        keyheld = false
    end
end)
 

RunService.RenderStepped:Connect(function()
    radiuscircle.Position = Vector2.new(Mouse.x, Mouse.y+35)
    radiuscircle.Filled = false
    radiuscircle.Thickness = settings.aim.fovcirclethickness
    radiuscircle.Visible = settings.aim.fovcircle
    radiuscircle.Transparency = settings.aim.fovcircletransp
    radiuscircle.Radius = settings.aim.fovcircleradius
    radiuscircle.Color = settings.aim.fovcirclecolor
    radiuscircle.NumSides = 30
    if settings.aim.aimbot == true then
        local target = (settings.aim.mode == "Player" and getPlayerClosestToMouse()) or (settings.aim.mode == "Animal" and getAnimalClosestToMouse())
        if keyheld == true and target then
            local first = (target.Position + (target.Velocity*Vector3.new(1,0,1)/6))
            local second = Vector3.new(first.X, first.Y + ((target.Position - LocalPlayer.Character[target.Name].Position).Magnitude / 100), first.Z)
            local partpos = settings.aim.mode == "Animal" and WorldToViewport(target.Position) or WorldToViewport(second)
            mousemoverel((partpos.x - Mouse.x) * settings.aim.smoothness, ((partpos.y * 0.93) - Mouse.y) * settings.aim.smoothness)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local horse = Global.WildLife:GetRidingAnimal()
    if horse then
        if settings.horse.editspeed then
            horse.WalkSpeed = settings.horse.speed
            horse.CanterSpeed = settings.horse.speed 
            horse.MaxSpeed = settings.horse.speed
        end
    end
    if settings.ragdollwalk then
		if LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").MoveDirection.Magnitude > 0 and Global.PlayerCharacter:IsRagdolled(game.Players.LocalPlayer.Character.HumanoidRootPart) then
		    LocalPlayer.Character:TranslateBy(LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").MoveDirection)
		end
    end
end)

spawn(function()
    while wait() do
        for i, v in next, weapons.realweapons do
            if settings.nospread or settings.aim.silentaim then
                v.FanAccuracy =  1
                v.ProjectileAccuracy =  1
            else
                v.FanAccuracy =  weapons.ogvalues[i].FanAccuracy
                v.ProjectileAccuracy =  weapons.ogvalues[i].ProjectileAccuracy
            end
            if settings.instantreload then
                v.ReloadSpeed =  1000
                v.LoadSpeed =  1000
                v.LoadEndSpeed = 1000
            else
                v.ReloadSpeed =  weapons.ogvalues[i].ReloadSpeed
                v.LoadSpeed =  weapons.ogvalues[i].LoadSpeed
                v.LoadEndSpeed = weapons.ogvalues[i].LoadEndSpeed
            end
        end
        if settings.mineaura then 
            local item = PlayerCharacterModule:GetEquippedItem()
            if string.match(item.Name, "Pickaxe") then
                for _,ore in next, game:GetService("Workspace")["WORKSPACE_Interactables"].Mining.OreDeposits:GetDescendants() do 
			        if string.match(ore.Name, "Ore") and ore.Parent:FindFirstChild("DepositInfo") and ore.Parent.DepositInfo:FindFirstChild("OreRemaining") and ore.Parent.DepositInfo.OreRemaining.Value ~= 0 and LocalPlayer.Character:FindFirstChild("Head") and not ore:IsA("RayValue") then
			            if (LocalPlayer.Character.Head.Position-ore.Position).Magnitude <  settings.mineauradistance then
			                item:NetworkActivate("MineDeposit", ore.Parent, ore.Position, LocalPlayer.Character.Head.Position)--Vector3.new(-0.165507436, 0.740951896, -0.65084374))
			            end
			        end
                end
            end
        end
        if settings.semiautosell then
            for _,item in pairs(PlayerDataModule:GetContainer("Inventory").Items) do
                if string.match(item.Type, "Ore") or string.match(item.Type, "Ruby") or string.match(item.Type, "Sapphire") or string.match(item.Type, "Emerald") or string.match(item.Type, "Diamond") or string.match(item.Type, "Meat") or string.match(item.Type, "Pelt") or string.match(item.Type, "Tooth") or string.match(item.Type, "Claw") or string.match(item.Type, "Skin") then
                    local vendor = SharedUtilsModule.GetNearestShopVendor(LocalPlayer.Character.HumanoidRootPart.Position)
                    if vendor and (LocalPlayer.Character.HumanoidRootPart.Position -vendor.HumanoidRootPart.Position).Magnitude < 13 then
                        game:GetService("ReplicatedStorage").Communication.Events.ContainerSellItem:FireServer("Inventory", item.Id)
                    end
                end
            end
        end
    end
end)


local JumpConnection = LocalPlayer.Character and getconnections(LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("Jump"))[1];
local OldOnCharacterAdded = PlayerCharacterModule.OnCharacterAdded;
PlayerCharacterModule.OnCharacterAdded = function(self)
OldOnCharacterAdded(self);
JumpConnection = getconnections(self.Human:GetPropertyChangedSignal("Jump"))[1];
if (settings.nojumpcooldown) then
JumpConnection:Disable();
end
end

local LightingChangedConnection;
local Fullbright = function(state)
    if (state) then
        LightingChangedConnection = Lighting.Changed:Connect(function()
            local color = Color3.new(1, 1, 1);
            Lighting.Ambient = color;
            Lighting.ColorShift_Bottom = color;
            Lighting.ColorShift_Top = color;
        end)
    else
        LightingChangedConnection:Disconnect();
        for i,v in next, oldLighting do
            Lighting[i] = v
        end
    end
end

local OldCalculateRecoil = GunItemModule.CalculateRecoil;
GunItemModule.CalculateRecoil = function(...)
if settings.norecoil then return 0 end;
return OldCalculateRecoil(...);
end

local OldOnHit = ClientProjectiles.Projectiles.GunProjectile.OnHit;
ClientProjectiles.Projectiles.GunProjectile.OnHit = function(self, ...)
if (settings.infinitepenetration) then
local OldCheckPenetration = self.CheckPenetration;
self.CheckPenetration = function(self)
self.PenetrationLeft = 999999;
return OldCheckPenetration(self);
end
end
return OldOnHit(self, ...);
end


local OldBreakFree = PlayerCharacterModule.BreakFree;
PlayerCharacterModule.BreakFree = function(self)
if (settings.instantbreakfree) then
self.BreakFreePerc = 1;
end
return OldBreakFree(self);
end

local OldGetUp = PlayerCharacterModule.GetUp;
PlayerCharacterModule.GetUp = function(self)
if (settings.instantgetup) then
local a, b = NetworkModule:InvokeServer("AttemptGetUp");
self:OnGetUp(a, b);
return;
end
return OldGetUp(self);
end

local OldInitProjectiles
OldInitProjectiles = hookfunction(ProjectileHandlerModule.InitProjectiles, function(c, Value, Data, Other, Callback)
    if settings.nospread then
        Other.accuracy = Random.new():NextNumber(0.9, 1)
    end
    return OldInitProjectiles(c, Value, Data, Other, Callback)
end)

local OldHorseBackAccMod = ProjectileHandlerModule.GetHorseBackAccMod
ProjectileHandlerModule.GetHorseBackAccMod = function(...)
    if settings.nospread then
        return 1.3
    end
    return OldHorseBackAccMod(...)
end

local OldIsFirstPerson = CameraModule.IsFirstPerson;
CameraModule.IsFirstPerson = function(self)
if (settings.aim.silentaim) then
if (getfenv(2) == getfenv(GunItemModule.new)) then
return true;
end
end
return OldIsFirstPerson(self);
end

local OldGetMouseHit = UtilsModule.GetMouseHit;
UtilsModule.GetMouseHit = function(...)
local args = {...};
if (settings.aim.silentaim) then
if (getfenv(2) == getfenv(GunItemModule.new)) then
local target = (settings.aim.mode == "Player" and getPlayerClosestToMouse()) or (settings.aim.mode == "Animal" and getAnimalClosestToMouse())
if (target) then
return settings.aim.mode == "Animal" and target.Position or target.Position + (target.Velocity*Vector3.new(1,0,1)/6)
end
end
end
return OldGetMouseHit(...);
end


local OldDelay = GunItemModule.CanShoot;
GunItemModule.CanShoot = function(...) 
    if (settings.nodelay) then
        return true 
    end
    return OldDelay(...)
end

local OldReload = GunItemModule.CanLoad;
GunItemModule.CanLoad = function(...) 
    if (settings.instantreload) then
        return true 
    end
    return OldReload(...)
end

local OldSwitchToItem = PlayerCharacterModule.CanSwitchToItem
PlayerCharacterModule.CanSwitchToItem = function(...)
if settings.alwaysguns then return true end
return OldSwitchToItem(...);
end


local OldFireServer = NetworkModule.FireServer;
NetworkModule.FireServer = function(self, remote, ...)
    local args = {...}
    if (settings.infinitestamina and remote == "LowerStamina") then return end;
    if (settings.nofalldamage and remote == "DamageSelf" and args[2] ~= "waddup") then return end;
    return OldFireServer(self, remote, ...)
end

local mt = getrawmetatable(game)
local old = mt.__namecall 
setreadonly(mt, false) 
mt.__namecall = newcclosure(function(self,...) 
    local args = {...} 
    if getnamecallmethod() == 'FireServer' and self.Name == "ACRoll" and settings.infinitestamina then --and type(args[1]) == string then
         return 
    end
    return old(self,unpack(args)) 
end)

local OldCharacterRagdoll = PlayerCharacterModule.Ragdoll;
PlayerCharacterModule.Ragdoll = function(...)
    local args = {...}
    if (settings.antiragdoll and args[#args] ~= "waddup") then return end;
    return OldCharacterRagdoll(...);
end

local OldCanRoll = PlayerCharacterModule.CanRoll
PlayerCharacterModule.CanRoll = function(...)
    if settings.alwaysroll then
        return true end;
    return OldCanRoll(...);
end

local OldRoll = PlayerCharacterModule.Roll
PlayerCharacterModule.Roll = function(t)
    if settings.rollspeed then
        spawn(function()
            repeat t.RollSpeed = settings.rollspeed wait() until settings.rollspeed == false
        end)
    end
    return OldRoll(t);
end

local OldAnimalRagdoll = AnimalModule.Ragdoll;
AnimalModule.Ragdoll = function(self, ...)
if (settings.horse.nohorseragdoll) then return end;
return OldAnimalRagdoll(self, ...);
end

local OldAnimalBoost = AnimalModule.Boost;
AnimalModule.Boost = function(self)
OldAnimalBoost(self);
if (settings.horse.infiniteboost) then
self.Boosts = self.MaxBoosts;
end
end


local BreakableGlass = {}; do
for k, v in next, debug.getupvalue(BreakableGlassModule.GetBreakableGlass, 1) do
if (type(k) == "userdata") then
table.insert(BreakableGlass, v.Id);
end
end
end
local BreakAllGlass = function()
for _, id in ipairs(BreakableGlass) do
NetworkModule:FireServer("BreakGlass", id, Vector3.new());
end
end
--===================================={GUI MAKING}====================================--
library = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/UI-Libraries/main/drawinglib.lua"))() do
library.new({size = Vector2.new(315,515), name = "yeehaw", mousedisable = false, font = 2, titlecolor = Color3.fromRGB(255,163,26)})
end


-- tabs
local CheatsTab = library.newtab({name = "Cheats"})
local MiscTab = library.newtab({name = "Misc"})

--sections
aim = library.newsection({name = "Aimbot", tab = CheatsTab,side = "left", size = 275,})
    library.newtoggle({
	    name = "Aimbot",
    	section = aim,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.aim.aimbot = bool
    	end
    })


    library.newtoggle({
	    name = "Silent Aim",
	    section = aim,
	    tab = CheatsTab,
	    callback = function(bool)
	       settings.aim.silentaim = bool
	    end
    })

    library.newdropdown({
        name = "Mode",
        options = {"Player", "Animal"},
        tab = CheatsTab,
        section = aim,
        callback = function(mode) 
            settings.aim.mode = mode
        end
    })
    library.newdropdown({
        name = "Target Part",
        options = {"Head", "HumanoidRootPart", "Automatic"},
        tab = CheatsTab,
        section = aim,
        callback = function(part) 
            settings.aim.target = part
        end
    })

    library.newslider({
	    name = "Aim Smoothness",
	    ended = false,
	    min = 1,
	    max = 10,
	    def = settings.aim.smoothness*10,
	    section = aim,
	    tab = CheatsTab,
	    callback = function(num)
	    settings.aim.smoothness = num/10
	end
    })

    library.newtoggle({
	    name = "Visible Check",
	    section = aim,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.aim.visiblecheck = bool
	    end
    })

    library.newtoggle({
	    name = "Team Check",
	    section = aim,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.aim.teamcheck = bool
	    end
    })

    library.newtoggle({
	    name = "FOV Circle",
	    section = aim,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.aim.fovcircle = bool
	    end
    })

    library.newslider({
	    name = "Circle Radius",
	    ended = false,
	    min = 1,
	    max = 100,
	    def = settings.aim.fovcircleradius/10,
	    section = aim,
	    tab = CheatsTab,
	    callback = function(num)
	    settings.aim.fovcircleradius = num*10
	end
    })

    library.newslider({
	    name = "Circle Thickness",
	    ended = false,
	    min = 1,
	    max = 10,
	    def = 2,
	    section = aim,
	    tab = CheatsTab,
	    callback = function(num)
	        settings.aim.fovcirclethickness = num
	    end
    })

    library.newslider({
	    name = "Circle Transparency",
	    ended = false,
	    min = 1,
	    max = 10,
	    def = settings.aim.fovcircletransp,
	    section = aim,
	    tab = CheatsTab,
	    callback = function(num)
	        settings.aim.fovcircletransp = (10-num)/10
	    end
    })

    library.newcolorpicker({
	    name = "Circle Color",
	    def = settings.aim.fovcirclecolor,
	    section = aim,
	    tab = CheatsTab,
	    transp = 0,
	    transparency = false,
	    callback = function(color)
	        settings.aim.fovcirclecolor = Color3.fromHSV(color[1],color[2],color[3])
	    end
    })

esp = library.newsection({name = "ESP", tab = CheatsTab,side = "right", size = 300,})
    library.newtoggle({
	    name = "ON/OFF",
	    section = esp,
	    --textcolor = Color3.fromRGB(0,255,0),
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.toggle = bool
	        ESP:Toggle(bool)
	    end
    })

    library.newtoggle({
    	name = "Players",
    	section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.players = bool
	        ESP.Players = bool
    	end
    })

    library.newtoggle({
	    name = "Animals",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.animals = bool
	        ESP.Animals = bool
	    end
    })

    library.newtoggle({
	    name = "Legendary Animals",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.legendary = bool
	        ESP.Legendary = bool
	    end
    })

    library.newtoggle({
	    name = "Thunderstruck",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.thunderstruck = bool
	        ESP.Thunderstruck = bool
	    end
    })

    library.newtoggle({
	    name = "Ores",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.ores = bool
	        ESP.Ores = bool
	    end
    })

    library.newtoggle({
	    name = "Items",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.items = bool
	        ESP.Items = bool
	    end
    })

    library.newtoggle({
	    name = "Money Bags",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.moneybags = bool
	        ESP.Moneybags = bool
	    end
    })

    library.newtoggle({
	    name = "Show Team Color",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.teamcolor = bool
	        ESP.TeamColor = bool
	    end
    })

    library.newtoggle({
	    name = "Tracers",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.tracers = bool
	        ESP.Tracers = bool
    	end
    })

    library.newtoggle({
	    name = "Boxes",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.boxes = bool
	        ESP.Boxes = bool
	    end
    })

    library.newtoggle({
	    name = "Names",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.esp.names = bool
	        ESP.Names = bool
	    end
    })

    library.newcolorpicker({
	    name = "Default Color",
	    def = settings.esp.PlayerColor,
	    section = esp,
	    tab = CheatsTab,
	    transp = 0,
	    transparency = false,
	    callback = function(color)
	        settings.esp.PlayerColor = Color3.fromHSV(color[1],color[2],color[3])
	        ESP.Color = settings.esp.PlayerColor
	    end
    })

    library.newcolorpicker({
	    name = "Animal Color",
	    def = settings.esp.AnimColor,
	    section = esp,
	    tab = CheatsTab,
	    transp = 0,
	    transparency = true,
	    callback = function(color)
	        settings.esp.AnimColor = Color3.fromHSV(color[1],color[2],color[3])
	    end
    })


charsec = library.newsection({name = "Character", tab = CheatsTab,side = "left", size = 225,})
    library.newkeybind({name = "Ragdoll Fly", def = settings.keys.ragdollfly, section = charsec, tab = CheatsTab, callback = function(key) settings.keys.ragdollfly = key end})

    library.newtoggle({
	    name = "TP Bypass/Invisible",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        if bool == true then
	            getconnections(ReplicatedStorage.Communication.Events.ACTrigger.OnClientEvent)[1]:Disable()
	        else
	            getconnections(ReplicatedStorage.Communication.Events.ACTrigger.OnClientEvent)[1]:Enable()
	        end
	    end
    })


    library.newtoggle({
	    name = "Infinite Stamina",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.infinitestamina = bool
	    end
    })

    library.newtoggle({
	    name = "No Fall Damage",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.nofalldamage = bool
	    end
    })

    library.newtoggle({
	    name = "No Jump Cooldown",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.nojumpcooldown = bool
	        if JumpConnection then
                if bool then
                    JumpConnection:Disable();
                else
                    JumpConnection:Enable();
                end
            end
	    end
    })

    library.newtoggle({
	    name = "Anti Ragdoll",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.antiragdoll = bool
	    end
    })

    library.newtoggle({
	    name = "Instant Get Up",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.instantgetup = bool
	    end
    })

    library.newtoggle({
	    name = "Instant Break Free",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.instantbreakfree = bool
	    end
    })
    library.newtoggle({
	    name = "Roll Anywhere",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.alwaysroll = bool
	    end
    })
    library.newslider({
	    name = "Roll Speed",
	    ended = true,
	    min = 0,
	    max = 5,
	    def = 0,
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(num)
	        if num == 0 then
	            settings.rollspeed = false
	            return
	        end
	        settings.rollspeed = num
	    end
    })


guns = library.newsection({name = "Tools", tab = CheatsTab,side = "right", size = 180,})
    library.newtoggle({
	    name = "No Recoil",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.norecoil = bool
	    end
    })
    
    library.newtoggle({
	    name = "No Spread",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.nospread = bool
	    end
    })

    library.newtoggle({
	    name = "No Delay",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.nodelay = bool
	    end
    })

    library.newtoggle({
	    name = "Instant Reload",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.instantreload = bool
	    end
    })

    library.newtoggle({
	    name = "Wallbang",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.infinitepenetration = bool
	    end
    })

    library.newtoggle({
	    name = "Use In Water, etc.",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.alwaysguns = bool
	    end
    })

    library.newtoggle({
	    name = "Mine Aura",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        settings.mineaura = bool
	        if bool == true then
	           notify("Mine Aura Activated", "Equip your pickaxe and go up to an ore") 
	        end
	    end
    })

    library.newslider({
	    name = "Mine Aura Range",
	    ended = bool,
	    min = 5,
	    max = 13,
	    def = 11,
	    section = guns,
	    tab = CheatsTab,
	    callback = function(num)
	        settings.mineauradistance = num
	    end
    })



misc = library.newsection({name = "Fun", tab = MiscTab,side = "left", size = 205,})
    library.newkeybind({name = "Suicide", def = settings.keys.Suicide, section = misc, tab = MiscTab, callback = function(key) settings.keys.Suicide = key end})
    
    library.newkeybind({name = "Ragdoll", def = settings.keys.Ragdoll , section = misc, tab = MiscTab, callback = function(key) settings.keys.Ragdoll = key end})
    
    library.newkeybind({name = "Equip Harmonica", def = settings.keys.Harmonica, section = misc, tab = MiscTab, callback = function(key) settings.keys.Harmonica = key end})
    
    library.newslider({
	    name = "Ragdoll Speed",
	    ended = bool,
	    min = 0,
	    max = 20,
	    def = 1,
	    section = misc,
	    tab = MiscTab,
	    callback = function(num)
	        settings.ragdollspeed = num
	    end
    })

    library.newdropdown({
        name = "Ragdoll Direction",
        options = {"Up", "Right", "Forward"},
        tab = MiscTab,
        section = misc,
        callback = function(direct) 
            if direct == "Up" then
                settings.ragdolldirection = 'UpVector'
            elseif direct == 'Right' then
                settings.ragdolldirection = 'RightVector'
            elseif direct == 'Forward' then
                settings.ragdolldirection = 'LookVector'
            end
        end
    })

    library.newtoggle({
	    name = "Body Size Pulse",
	    section = misc,
	    tab = MiscTab,
	    callback = function(bool)
	        settings.sizepulse = bool
	    end
    })

    library.newtoggle({
	    name = "Anti Racism",
	    section = misc,
	    tab = MiscTab,
	    callback = function(bool)
	        settings.antiracist = bool
	    end
    })

    library.newtoggle({
	    name = "Ragdoll Walk",
	    section = misc,
	    tab = MiscTab,
	    callback = function(bool)
	        settings.ragdollwalk = bool
	    end
    })

    library.newbutton({name = "Equip Broom",section = misc,tab = MiscTab,callback = function()Global.PlayerCharacter:EquipItem('Broom')end})
    
respawns = library.newsection({name = "Quick Respawn", tab = MiscTab,side = "right", size = 165,})
    for i,v in next, places do
        library.newbutton({name = v[1], tab = MiscTab, section = respawns, callback = function() game:GetService("ReplicatedStorage").Communication.Functions.Respawn:InvokeServer(v[2]) end})
    end

mayor = library.newsection({name = "Mayor", tab = MiscTab,side = "left", size = 30,})
    library.newtextbox({
        name = "Pardon Player",
	    section = mayor,
	    lower = true,
	    tab = MiscTab,
	    callback = function(plr)
	        for i,v in pairs(Players:GetPlayers()) do
	            if string.lower(v.Name) == plr then
	                game:GetService("ReplicatedStorage").Communication.Events.AttemptPardonPlayer:FireServer(v)
	            end
	        end
	    end
    })

general = library.newsection({name = "General", tab = MiscTab,side = "right", size = 140,})
    library.newtoggle({
	    name = "Fullbright",
	    section = general,
	    tab = MiscTab,
	    callback = function(bool)
	        Fullbright(bool)
	    end
    })
    
    library.newtoggle({
	    name = "Semi Auto Sell",
	    section = general,
	    tab = MiscTab,
	    callback = function(bool)
	        settings.semiautosell = bool
	    end
    })

    library.newbutton({name = "Break All Glass",section = general,tab = MiscTab,callback = BreakAllGlass})
    
    library.newbutton({name = "Join Smallest Server",section = general,tab = MiscTab,callback = function(...) 
        if syn then
            coroutine.resume((coroutine.create(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/scripts/main/JoinLowestPlayer.lua"))()  end)))
        else
            notify("Exploit Not Compatible!", "Sorry, this function is Synapse only")
        end
    end})
    
    library.newbutton({name = "Server Hop",section = general,tab = MiscTab,callback = function(...) 
    local x = {}
	for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
		if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
			x[#x + 1] = v.id
		end
	end
	if #x > 0 then
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
	else
		return notify("Serverhop","Couldn't find a server.")
	end
    end})
    
    library.newbutton({name = "Rejoin",section = general,tab = MiscTab,callback = function(...) 
        if #Players:GetPlayers() <= 1 then
		    Players.LocalPlayer:Kick("\nRejoining...")
		    wait()
		    game:GetService('TeleportService'):Teleport(game.PlaceId, Players.LocalPlayer)
	    else
		    game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
	    end
    end})
    
horse = library.newsection({name = "Horse", tab = MiscTab,side = "left", size = 150,})
    library.newtoggle({
	    name = "Infinite Boosts",
	    section = horse,
	    tab = MiscTab,
	    callback = function(bool)
	        settings.horse.infiniteboost = bool
	    end
    })

    library.newtoggle({
	    name = "No Ragdoll",
	    section = horse,
	    tab = MiscTab,
	    callback = function(bool)
	        settings.horse.nohorseragdoll = bool
	    end
    })

    library.newtoggle({
	    name = "Edit Speed",
    	section = horse,
	    tab = MiscTab,
	    callback = function(bool)
	        settings.horse.editspeed = bool
    	end
    })

    library.newslider({
	    name = "Speed",
	    ended = false,
	    min = 1,
	    max = 100,
	    def = settings.horse.speed,
	    section = horse,
	    tab = MiscTab,
	    callback = function(num)
	    settings.horse.speed = num
	end
    })


    library.newdropdown({
        name = "Horse",
        options = settings.horse.horsenames,
        tab = MiscTab,
        section = horse,
        callback = function(horsename) 
            for i, v in next, Global.PlayerData:GetSortedHorses() do
               if v.Breed == horsename then
                   settings.horse.horseid = v.Id
               end
            end
        end
    })


library.newkeybind({name = "Call Horse", def = settings.keys.callhorse, section = horse, tab = MiscTab, callback = function(key) settings.keys.callhorse = key end})

discord = library.newsection({name = "Discord", tab = MiscTab,side = "right", size = 30,})
    library.newbutton({name = "Copy to Clipboard",section = discord,tab = MiscTab,callback = function()setclipboard('https://discord.gg/qT4KvqY7')end})

library.opentab(CheatsTab)
library.init()
