--[[
Credits:
ThisStuff - Instant Reload
casual_degenerate(discord) - quick respawn
=======================================================================
	Join the discord: https://discord.gg/qT4KvqY7
]]
local Players = game:GetService("Players");     
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

local LoadModule = require(ReplicatedStorage.Modules.Load);
local LoadSharedModule = require(ReplicatedStorage.SharedModules.Load);
local Global = require(game:GetService("ReplicatedStorage").SharedModules.Global);
local AnimalModule, BreakableGlassModule, CameraModule, ClientProjectiles, GunItemModule, NetworkModule, PlayerCharacterModule, SharedUtilsModule, UtilsModule; do
AnimalModule = LoadModule("Animal");
BreakableGlassModule = LoadModule("BreakableGlass");
CameraModule = LoadModule("Camera");
ClientProjectiles = LoadModule("ClientProjectiles");
GunItemModule = LoadModule("GunItem");
NetworkModule = LoadSharedModule("Network");
PlayerCharacterModule = LoadModule("PlayerCharacter");
SharedUtilsModule = LoadSharedModule("SharedUtils");
CharRepUtilsModule = LoadSharedModule("CharRepUtils");
UtilsModule = LoadModule("Utils");
end

local library
local radiuscircle = Drawing.new('Circle')
local keyheld = false

local oldLighting = {
    Ambient = Lighting.Ambient,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top
}

local places = {            
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

if _G.Executed then repeat wait() until false end
_G.Executed = true

--====================================={SETTINGS}=====================================--
local afsettings = {}
afsettings.PathColor = Color3.fromRGB(0, 10, 0)
afsettings.bearbool = false
afsettings.orebool = false
afsettings.slots = {}
afsettings.slots.ofarm = "3"
afsettings.slots.bfarm = "1"

local cheatsettings = {}
cheatsettings.sizepulse = false
cheatsettings.ragdollspeed = 1
cheatsettings.antiracist = false
cheatsettings.antiragdoll = false
cheatsettings.nofalldamage = false
cheatsettings.nojumpcooldown = false
cheatsettings.instantbreakfree = false
cheatsettings.instantgetup = false
cheatsettings.infinitestamina = false
cheatsettings.alwaysroll = false
cheatsettings.rollspeed = false
cheatsettings.ragdolldirection = "lookVector"
cheatsettings.nospread = false
cheatsettings.norecoil = false
cheatsettings.nodelay = false
cheatsettings.regeneration = false
cheatsettings.alwaysguns = false
cheatsettings.instantreload = false
cheatsettings.mineaura = false
cheatsettings.mineauradistance = 11

cheatsettings.aim = {}
cheatsettings.aim.aimbot = false
cheatsettings.aim.silentaim = false
cheatsettings.aim.target = "Head"
cheatsettings.aim.visiblecheck = false
cheatsettings.aim.teamcheck = false
cheatsettings.aim.fovcircle = false
cheatsettings.aim.fovcirclecolor = Color3.fromRGB(255,255,255)
cheatsettings.aim.fovcircleradius = 100
cheatsettings.aim.fovcirclethickness = 2
cheatsettings.aim.fovcircletransp = 1

cheatsettings.esp = {}
cheatsettings.esp.toggle = false
cheatsettings.esp.showplayers = false
cheatsettings.esp.showanimals = false
cheatsettings.esp.showores = false
cheatsettings.esp.PlayerColor = Color3.fromRGB(255, 255, 255);
cheatsettings.esp.AnimColor = Color3.fromRGB(0, 255, 255);
cheatsettings.esp.Friendly_Color = Color3.fromRGB(0, 255, 0);
cheatsettings.esp.Enemy_Color = Color3.fromRGB(255, 0, 0);
cheatsettings.esp.ShowLine = false;
cheatsettings.esp.ShowBox = false;
cheatsettings.esp.ShowName = true;
cheatsettings.esp.ShowInfo = true;
cheatsettings.esp.ObstructedInfo = false;
cheatsettings.esp.ShowTeam = false;
cheatsettings.esp.TextShadow = true;
cheatsettings.esp.TextSize = 20;
cheatsettings.esp.Thickness = 2;
cheatsettings.esp.LineTransparency = 0.7;
cheatsettings.esp.TextTransparency = 1;
cheatsettings.keys = {}
cheatsettings.keys.Suicide = "K"
cheatsettings.keys.Harmonica = "N"
cheatsettings.keys.Ragdoll = "L"

--====================================={FUNCTIONS}=====================================-- messy code
local function notify(title,text,dur)
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = title,
        Text = text,
        Duration = dur or 5
    })
end

function FlyTo(cf)
    local destinationPart = Instance.new("Part", workspace)
    destinationPart.Anchored = true
    destination.Transparency = 1
    destinationPart.CFrame = cf
    if not CharRepUtils.IsRagdolled then
        PlayerCharacterModule:Ragdoll(game.Players.LocalPlayer.Character.HumanoidRootPart, true, game.Players.LocalPlayer.Character.HumanoidRootPart.Position, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame[cheatsettings.ragdolldirection], cheatsettings.ragdollspeed)
    end
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
    local maxDist = cheatsettings.aim.fovcircleradius
    for _,v in pairs(Players:GetPlayers()) do
        if v.Character then
            if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild("HumanoidRootPart")  then
                if cheatsettings.aim.teamcheck and v.Team == LocalPlayer.Team then return nil end
                local pos, vis = CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).magnitude
                if dist < maxDist and vis then
                    if cheatsettings.aim.target == "Automatic" then
                        local torsoPos = CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                        local torsoDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(torsoPos.X, torsoPos.Y)).magnitude
                        local headPos = CurrentCamera:WorldToViewportPoint(v.Character.Head.Position)
                        local headDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(headPos.X, headPos.Y)).magnitude
                        if torsoDist > headDist then
                            if cheatsettings.aim.visiblecheck and checkObstructed(CurrentCamera.CFrame.p, v.Character.Head) then return nil end
                            target = v.Character.Head
                        else
                            if cheatsettings.aim.visiblecheck and checkObstructed(CurrentCamera.CFrame.p, v.Character.HumanoidRootPart) then return nil end
                            target = v.Character.HumanoidRootPart
                        end
                    else
                        if cheatsettings.aim.visiblecheck and checkObstructed(CurrentCamera.CFrame.p, v.Character[cheatsettings.aim.target]) then return nil end
                        target = v.Character[cheatsettings.aim.target]
                    end
                    maxDist = dist
                end
            end
        end
    end
    return target
end



local animalnum = 0
local orenum = 0
local plrs = setmetatable({}, {     
    __call = function(self, ...)
        local args = {...}
        local case = args[1]
        if case == "add" then
            local plr = args[2]
            if not self[plr] then
                self[plr] = {}
                self[plr].Line = Drawing.new("Line")
                self[plr].Name = Drawing.new("Text")
                self[plr].Info = Drawing.new("Text")
                
                self[plr].Box = {}
                self[plr].Box.Top = Drawing.new("Line")
                self[plr].Box.Bottom = Drawing.new("Line")
                self[plr].Box.Left = Drawing.new("Line")
                self[plr].Box.Right = Drawing.new("Line")
                
            end
        elseif case == "remove" then
            local plr = args[2]
            if self[plr] then
                self[plr].Line.Visible = false
                self[plr].Name.Visible = false
                self[plr].Info.Visible = false
                
                if not self[plr].Model then
                self[plr].Box.Top.Visible = false
                self[plr].Box.Bottom.Visible = false
                self[plr].Box.Left.Visible = false
                self[plr].Box.Right.Visible = false
                self[plr].Box.Top = nil
                self[plr].Box.Bottom = nil
                self[plr].Box.Left = nil
                self[plr].Box.Right= nil
                self[plr].Box = nil
                end
                
                self[plr].Line = nil
                self[plr].Name = nil
                self[plr].Info = nil
                self[plr] = nil
            end
        
        elseif case == "animal" then
            animalnum = animalnum + 1
            name = 'Animal'.. tostring(animalnum)

            local tag = Instance.new("RayValue", args[2])
                
            if args[2].Health.Value > 200 then
                local ltag = Instance.new("StringValue", args[2])
                ltag.Name = "Legendary"
            end
                
            tag.Name = name
            self[name] = {}
            self[name].Model = args[2]
            self[name].Line = Drawing.new("Line")
            self[name].Name = Drawing.new("Text")
            self[name].Info = Drawing.new("Text")
            
        elseif case == "ore" then
            orenum = orenum + 1
            name = 'Ore'.. tostring(orenum)

            local tag = Instance.new("RayValue", args[2])
                
            tag.Name = name
            self[name] = {}
            self[name].Model = args[2]
            self[name].Line = Drawing.new("Line")
            self[name].Name = Drawing.new("Text")
            self[name].Info = Drawing.new("Text")
        end
    end
})


function setBox(table,typev,value)
    if not table or not value then return end
    for _,val in pairs(table) do
            if _ == "Top" or _ == "Bottom" or _ == "Left" or _ == "Right" then
             val[typev] = value
        end
    end
end


function updateBox(box, CF, Size)
    local top, cansee = box.Top
    local bottom = box.Bottom
    local left = box.Left
    local right = box.Right
    
    if CF and Size then
    local tlPos = WorldToViewport((CF * CFrame.new(Size.X, Size.Y, 0)).p)
    local trPos = WorldToViewport((CF * CFrame.new(-Size.X, Size.Y, 0)).p)
    local blPos = WorldToViewport((CF * CFrame.new(Size.X, -Size.Y, 0)).p)
    local brPos = WorldToViewport((CF * CFrame.new(-Size.X, -Size.Y, 0)).p)
    
    top.From = Vector2.new(tlPos.X, tlPos.Y)
    top.To = Vector2.new(trPos.X, trPos.Y)
    
    right.From = Vector2.new(trPos.X, trPos.Y)
    right.To = Vector2.new(brPos.X, brPos.Y)
    
    left.From = Vector2.new(blPos.X, blPos.Y)
    left.To = Vector2.new(tlPos.X, tlPos.Y)
    
    bottom.From = Vector2.new(brPos.X, brPos.Y)
    bottom.To = Vector2.new(blPos.X, blPos.Y)
    end
    
    if cansee and esp_on == true and cheatsettings.esp.ShowBox == false then
        top.Visible = true
        bottom.Visible = true
        left.Visible = true
        right.Visible = true
        elseif not cansee or esp_on == false or cheatsettings.esp.ShowBox == true then 
        top.Visible = false
        bottom.Visible = false
        left.Visible = false
        right.Visible = false
    end
end


function checkFFA()
    local same = {}
    table.insert(same, LocalPlayer)
    for _,v in pairs(plrs) do
        if not v.Model then
            local actualplr = Players:FindFirstChild(_)
            if not actualplr then return end
        
            if actualplr.Team == LocalPlayer.Team then
                table.insert(same, actualplr)
            end
        end
    end
    
    if #same == #Players:GetPlayers() then
        return true
    else
        return false
    end
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
--==============================={Actual Script}=======================================--
for i, v in next, getgc(true) do
    if type(v) == "table" and rawget(v, "BaseRecoil") then
        weapons.ogvalues[i] = deepCopy(v)
        weapons.realweapons[i] = v
    end
end

spawn(function()
    while RunService.Heartbeat:Wait() do
        if cheatsettings.sizepulse then
            for i = 0.1,1,.1 do
                Global.Network:FireServer("SetThicknessPercent", i);
                Global.Network:FireServer("SetHeightPercent", i);
                RunService.Heartbeat:Wait()
            end
            for i = 1,.1,-.1 do
                Global.Network:FireServer("SetThicknessPercent", i);
                Global.Network:FireServer("SetHeightPercent", i);
                RunService.Heartbeat:Wait()
            end
        end
        if cheatsettings.antiracist then
            for i = 1,10,1 do
                ReplicatedStorage.Communication.Events.SelectSkinColor:FireServer(i)
                RunService.Heartbeat:Wait()
            end
            for i = 10,1,-1 do
                ReplicatedStorage.Communication.Events.SelectSkinColor:FireServer(i)
                RunService.Heartbeat:Wait()
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
    if input.KeyCode == Enum.KeyCode[cheatsettings.keys.Suicide] then
        Global.Network:FireServer("DamageSelf", 100, 'waddup')
    end
    if input.KeyCode == Enum.KeyCode[cheatsettings.keys.Harmonica] then
        Global.PlayerCharacter:EquipItem('Harmonica')
    end
    if input.KeyCode == Enum.KeyCode[cheatsettings.keys.Ragdoll] then
        PlayerCharacterModule:Ragdoll(game.Players.LocalPlayer.Character.HumanoidRootPart, true, game.Players.LocalPlayer.Character.HumanoidRootPart.Position, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame[cheatsettings.ragdolldirection], cheatsettings.ragdollspeed*100)
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
    

Players.PlayerRemoving:Connect(function(player)
    plrs("remove", player.Name)
end)

for i,ore in pairs(game:GetService("Workspace")["WORKSPACE_Interactables"].Mining.OreDeposits:GetDescendants()) do
    if ore:IsA("Model") and ore:FindFirstChild("DepositInfo") and not ore:FindFirstChild("LimestoneOre") then
        plrs("ore", ore)
    end
end

for i,anim in pairs(Entities.Animals:GetChildren()) do
    if not string.match(anim.Name, "Horse") and anim.Name ~= "Cow" and anim:FindFirstChild("Health") then
        plrs("animal", anim)
    end
end

Entities.Animals.ChildAdded:Connect(function(anim)
    if not string.match(anim.Name, "Horse") and anim.Name ~= "Cow" and anim:FindFirstChild("Health") then
        plrs("animal", anim)
    end
end)

Entities.Animals.ChildRemoved:Connect(function(anim)
    if not string.match(anim.Name, "Horse") and anim.Name ~= "Cow" and anim:FindFirstChild("Health") then
        plrs("remove", anim:FindFirstChildOfClass("RayValue").Name)
    end
end)

RunService.RenderStepped:Connect(function()
for _,player in pairs(Players:GetPlayers()) do
    local plr = player.Name
    if plr ~= LocalPlayer.Name then
        plrs("add", plr)
    end
end
for _,ore in next, plrs do
    if cheatsettings.esp.toggle and cheatsettings.esp.showores and ore.Model and ore.Model:FindFirstChild("DepositInfo") then
        local Base = ore.Model:FindFirstChild(ore.Model.Parent.Name.."Base")
        local actualOre = ore.Model:FindFirstChild(ore.Model.Parent.Name.."Ore")
        local humPos, inView = WorldToViewport(Base.Position)
        local Distance = distanceFrom(CurrentCamera.CFrame.p, Base.Position)
        local obstructed
        local oString
        
        ore.Line.From = Vector2.new(CurrentCamera.ViewportSize.x / 2, CurrentCamera.ViewportSize.y / 1.5)
        ore.Line.To =  Vector2.new(humPos.x, humPos.y)
        ore.Line.Thickness = cheatsettings.esp.Thickness
        ore.Line.Color = actualOre.Color
        
        ore.Name.Position = Vector2.new(humPos.x, humPos.y-10)
        ore.Name.Center = true
        ore.Name.Outline = cheatsettings.esp.TextShadow
        ore.Name.Size = cheatsettings.esp.TextSize
        ore.Name.Text = ore.Model.Parent.Name
        ore.Name.Color = actualOre.Color
        
        if cheatsettings.esp.ObstructedInfo then
            obstructed = checkObstructed(CurrentCamera.CFrame.p, Base)
            if obstructed == false then
                oString = "[CLEAR]"
            else
                oString = "[OBSTRUCTED]"
            end
            
            ore.Info.Text = "["..tostring(math.round(Distance)).."m]".. "["..ore.Model.DepositInfo.OreRemaining.Value.." left]".. oString
        else
            ore.Info.Text = "["..tostring(math.round(Distance)).."m]".. "["..ore.Model.DepositInfo.OreRemaining.Value.." left]"
        end 
        
        ore.Info.Position = Vector2.new(humPos.x, humPos.y) + Vector2.new(0,10)--Vector2.new(humPos.x, humPos.y)
        ore.Info.Center = true
        ore.Info.Outline = cheatsettings.esp.TextShadow
        ore.Info.Size = cheatsettings.esp.TextSize - 4
        ore.Info.Color = Color3.new(255,255,255)
        
        for i,v in pairs(ore) do
            if i == "Line" then
                v.Transparency = cheatsettings.esp.LineTransparency
            elseif i ~= "Model" then
                v.Transparency = cheatsettings.esp.TextTransparency
            end
        end
        
        if inView then  
            for i,v in pairs(ore) do
                if i ~= "Model" then
                    v.Visible = cheatsettings.esp["Show"..i]
                end
            end
        else
            for i,v in pairs(ore) do
                if i ~= "Model" then
                    v.Visible = false
                end
            end
        end
    elseif (cheatsettings.esp.toggle == false or cheatsettings.esp.showores == false) and ore.Model and ore.Model:FindFirstChild("DepositInfo") then
        for i,v in pairs(ore) do
            if i ~= "Model"  then
                v.Visible = false
            end
        end
    end
end

for _,anim in next, plrs do
    if cheatsettings.esp.toggle and cheatsettings.esp.showanimals and anim.Model and anim.Model:FindFirstChild("HumanoidRootPart") and anim.Model:FindFirstChild("Health") then
        local animal = anim.Model
        
        local headPos = WorldToViewport(animal.Head.CFrame * (CFrame.new(0, animal.Head.Size.Y, 0) + Vector3.new(0, animal.Head.Size.Y*1.5)).p)
        local humPos, inView = WorldToViewport(animal.HumanoidRootPart.Position)
        local Distance = distanceFrom(CurrentCamera.CFrame.p, animal.HumanoidRootPart.Position)
        local obstructed
        local oString
        
        anim.Line.From = Vector2.new(CurrentCamera.ViewportSize.x / 2, CurrentCamera.ViewportSize.y / 1.5)
        anim.Line.To =  Vector2.new(humPos.x, humPos.y)
        anim.Line.Thickness = cheatsettings.esp.Thickness
        
        anim.Name.Position = Vector2.new(headPos.x, headPos.y)
        anim.Name.Center = true
        anim.Name.Outline = cheatsettings.esp.TextShadow
        anim.Name.Size = cheatsettings.esp.TextSize
        
        if anim.Model:FindFirstChild("Legendary") then
            anim.Name.Text = "Legendary".. animal.Name
            anim.Name.Color = Color3.fromRGB(255,255,0)
            anim.Line.Color = Color3.fromRGB(255,255,0)
        else
            anim.Name.Text = animal.Name
            anim.Name.Color = cheatsettings.esp.AnimColor
            anim.Line.Color = cheatsettings.esp.AnimColor
        end
            
        if cheatsettings.esp.ObstructedInfo then
            obstructed = checkObstructed(CurrentCamera.CFrame.p, animal.HumanoidRootPart)
            if obstructed == false then
                oString = "[CLEAR]"
            else
                oString = "[OBSTRUCTED]"
            end
            
            anim.Info.Text = "["..tostring(math.round(Distance)).."m]".. "["..math.round(animal.Health.Value).."%]".. oString
        else
            anim.Info.Text = "["..tostring(math.round(Distance)).."m]".. "["..math.round(animal.Health.Value).."%]"
        end 
            
        anim.Info.Position = Vector2.new(headPos.x, headPos.y) + Vector2.new(0,10)--Vector2.new(humPos.x, humPos.y)
        anim.Info.Center = true
        anim.Info.Outline = cheatsettings.esp.TextShadow
        anim.Info.Size = cheatsettings.esp.TextSize - 4
        anim.Info.Color = Color3.new(255,255,255)
        
        for i,v in pairs(anim) do
            if i == "Line" then
                v.Transparency = cheatsettings.esp.LineTransparency
            elseif i ~= "Model" then
                v.Transparency = cheatsettings.esp.TextTransparency
            end
        end
        
        if inView then  
            for i,v in pairs(anim) do
                if i ~= "Model" then
                    v.Visible = cheatsettings.esp["Show"..i]
                end
            end
        else
            for i,v in pairs(anim) do
                if i ~= "Model" then
                    v.Visible = false
                end
            end
        end
    elseif (cheatsettings.esp.toggle == false or cheatsettings.esp.showanimals == false) and anim.Model and anim.Model:FindFirstChild("HumanoidRootPart") then
        for i,v in pairs(anim) do
            if i ~= "Model" and i ~= "Animal" then
                v.Visible = false
            end
        end
    end
end

for _,player in pairs(Players:GetPlayers()) do
    local plr = player.Name
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            if cheatsettings.esp.toggle == true and cheatsettings.esp.showplayers and plrs[player.Name] ~= nil then
                local humPos, inView = WorldToViewport(player.Character.HumanoidRootPart.Position)
                local headPos = WorldToViewport(player.Character.Head.CFrame * (CFrame.new(0, player.Character.Head.Size.Y, 0) + Vector3.new(0, player.Character.Head.Size.Y*1.5)).p)   --WorldToViewport(player.Character.Head.Position)
                local Distance = distanceFrom(CurrentCamera.CFrame.p, player.Character.HumanoidRootPart.Position)
                local obstructed
                local oString = " "
                
                plrs[player.Name].Line.From = Vector2.new(CurrentCamera.ViewportSize.x / 2, CurrentCamera.ViewportSize.y / 1.5)
                plrs[player.Name].Line.To =  Vector2.new(humPos.x, humPos.y)
                plrs[player.Name].Line.Thickness = cheatsettings.esp.Thickness
                
                plrs[player.Name].Name.Text = plr
                plrs[player.Name].Name.Position = Vector2.new(headPos.x, headPos.y)
                plrs[player.Name].Name.Center = true
                plrs[player.Name].Name.Outline = cheatsettings.esp.TextShadow
                plrs[player.Name].Name.Size = cheatsettings.esp.TextSize
                
                
            if cheatsettings.esp.ObstructedInfo then
                obstructed = checkObstructed(CurrentCamera.CFrame.p, player.Character.HumanoidRootPart)
                if obstructed == false then
                    oString = "[CLEAR]"
                else
                    oString = "[OBSTRUCTED]"
                end
                plrs[player.Name].Info.Text = "["..tostring(math.round(Distance)).."m] ".. oString
            else
                plrs[player.Name].Info.Text = "["..tostring(math.round(Distance)).."m]"
            end 
            
                plrs[player.Name].Info.Position = Vector2.new(headPos.x, headPos.y) + Vector2.new(0,10)--Vector2.new(humPos.x, humPos.y)
                plrs[player.Name].Info.Center = true
                plrs[player.Name].Info.Outline = cheatsettings.esp.TextShadow
                plrs[player.Name].Info.Size = cheatsettings.esp.TextSize - 4
                plrs[player.Name].Info.Color = Color3.new(255,255,255)
                
                updateBox(plrs[player.Name].Box, player.Character.HumanoidRootPart.CFrame, Vector3.new(2, 3, 0)  * (player.Character.Head.Size.Y or LocalPlayer.Character.Head.Size.Y))
                
                for i,v in pairs(plrs[player.Name]) do
                    if i == "Line" then
                    v.Transparency = cheatsettings.esp.LineTransparency
                        else
                    v.Transparency = cheatsettings.esp.TextTransparency
                    end
                end
                
                setBox(plrs[player.Name].Box, "Transparency", cheatsettings.esp.LineTransparency)
                setBox(plrs[player.Name].Box, "Thickness", cheatsettings.esp.Thickness)
                
                if cheatsettings.esp.ShowTeam == true then
                    plrs[player.Name].Line.Color = player.TeamColor.Color
                    plrs[player.Name].Name.Color = player.TeamColor.Color
                    setBox(plrs[player.Name].Box, "Color", player.TeamColor.Color)
                else
                    plrs[player.Name].Name.Color = cheatsettings.esp.PlayerColor
                    plrs[player.Name].Line.Color = cheatsettings.esp.PlayerColor
                    setBox(plrs[player.Name].Box, "Color", cheatsettings.esp.PlayerColor)
                end
                
                
                if inView then  --checks if player is in view
                    setBox(plrs[player.Name].Box, "Visible", cheatsettings.esp.ShowBox)
                    for i,v in pairs(plrs[player.Name]) do
                        v.Visible = cheatsettings.esp["Show"..i]
                    end
                else
                    setBox(plrs[player.Name].Box, "Visible", false)
                    for i,v in pairs(plrs[player.Name]) do
                        v.Visible = false
                    end
                end
            
            elseif (cheatsettings.esp.toggle == false or cheatsettings.esp.showplayers == false) and plrs[player.Name] ~= nil and plrs[player.Name].Line ~= nil then
                
                for i,v in pairs(plrs[player.Name]) do
                    v.Visible = false
                end
                setBox(plrs[player.Name].Box, "Visible", false)
                updateBox(plrs[player.Name].Box)
            end
        end
    end
end)


RunService.RenderStepped:Connect(function()
    radiuscircle.Position = Vector2.new(Mouse.x, Mouse.y+35)
    radiuscircle.Filled = false
    radiuscircle.Thickness = cheatsettings.aim.fovcirclethickness
    radiuscircle.Visible = cheatsettings.aim.fovcircle
    radiuscircle.Transparency = cheatsettings.aim.fovcircletransp
    radiuscircle.Radius = cheatsettings.aim.fovcircleradius
    radiuscircle.Color = cheatsettings.aim.fovcirclecolor
    radiuscircle.NumSides = 30
    if cheatsettings.aim.aimbot == true then
        local target = getPlayerClosestToMouse()
        if keyheld == true and target then
            local partpos = WorldToViewport(target.Position)
            mousemoverel((partpos.x - Mouse.x) * 0.2, ((partpos.y * 0.93) - Mouse.y) * 0.2)
        end
    end
end)

spawn(function()
    while wait() do
        for i, v in next, weapons.realweapons do
            if cheatsettings.instantreload then
                v.ReloadSpeed =  1000
                v.LoadSpeed =  1000
                v.LoadEndSpeed = 1000
            else
                v.ReloadSpeed =  weapons.ogvalues[i].ReloadSpeed
                v.LoadSpeed =  weapons.ogvalues[i].LoadSpeed
                v.LoadEndSpeed = weapons.ogvalues[i].LoadEndSpeed
            end
        end
        if cheatsettings.mineaura then 
            local item = PlayerCharacterModule:GetEquippedItem()
            if string.match(item.Name, "Pickaxe") then
                for _,ore in next, game:GetService("Workspace")["WORKSPACE_Interactables"].Mining.OreDeposits:GetDescendants() do 
			        if string.match(ore.Name, "Base") and ore.Parent:FindFirstChild("DepositInfo") and ore.Parent.DepositInfo:FindFirstChild("OreRemaining") and ore.Parent.DepositInfo.OreRemaining.Value ~= 0 and LocalPlayer.Character:FindFirstChild("Head") then
			            if (LocalPlayer.Character.Head.Position-ore.Position).Magnitude <  cheatsettings.mineauradistance then
			                item:NetworkActivate("MineDeposit", ore.Parent, ore.Position, LocalPlayer.Character.Head.Position)--Vector3.new(-0.165507436, 0.740951896, -0.65084374))
			            end
			        end
                end
            end
        end
    end
end)

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
if cheatsettings.norecoil then return 0 end;
return OldCalculateRecoil(...);
end


local JumpConnection = LocalPlayer.Character and getconnections(LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("Jump"))[1];
local OldOnCharacterAdded = PlayerCharacterModule.OnCharacterAdded;
PlayerCharacterModule.OnCharacterAdded = function(self)
OldOnCharacterAdded(self);
JumpConnection = getconnections(self.Human:GetPropertyChangedSignal("Jump"))[1];
if (cheatsettings.nojumpcooldown) then
JumpConnection:Disable();
end
end

local OldBreakFree = PlayerCharacterModule.BreakFree;
PlayerCharacterModule.BreakFree = function(self)
if (cheatsettings.instantbreakfree) then
self.BreakFreePerc = 1;
end
return OldBreakFree(self);
end

local OldGetUp = PlayerCharacterModule.GetUp;
PlayerCharacterModule.GetUp = function(self)
if (cheatsettings.instantgetup) then
local a, b = NetworkModule:InvokeServer("AttemptGetUp");
self:OnGetUp(a, b);
return;
end
return OldGetUp(self);
end


local OldIsFirstPerson = CameraModule.IsFirstPerson;
CameraModule.IsFirstPerson = function(self)
if (cheatsettings.aim.silentaim) then
if (getfenv(2) == getfenv(GunItemModule.new)) then
return true;
end
end
return OldIsFirstPerson(self);
end

local OldGetMouseHit = UtilsModule.GetMouseHit;
UtilsModule.GetMouseHit = function(...)
local args = {...};
if (cheatsettings.aim.silentaim) then
if (getfenv(2) == getfenv(GunItemModule.new)) then
local target = getPlayerClosestToMouse()
if (target) then
return target.Position + target.Parent.HumanoidRootPart.Velocity
end
end
end
return OldGetMouseHit(...);
end


local OldGetProjectileSpread = SharedUtilsModule.GetProjectileSpread;
SharedUtilsModule.GetProjectileSpread = function(a, b, c, d)
if (cheatsettings.aim.silentaim or cheatsettings.nospread) then
c.accuracy = 1;
end
return OldGetProjectileSpread(a, b, c, d);
end

local OldDelay = GunItemModule.CanShoot;
GunItemModule.CanShoot = function(...) 
    if (cheatsettings.nodelay) then
        return true 
    end
    return OldDelay(...)
end

local OldSwitchToItem = PlayerCharacterModule.CanSwitchToItem
PlayerCharacterModule.CanSwitchToItem = function(...)
return true end

local OldSleep = PlayerCharacterModule.IsSleeping
PlayerCharacterModule.IsSleeping = function(...)
if cheatsettings.regeneration then return true end
return OldSleep(...);
end

local OldFireServer = NetworkModule.FireServer;
NetworkModule.FireServer = function(self, remote, ...)
    local args = {...}
    if (cheatsettings.infinitestamina and remote == "LowerStamina") then return end;
    if (cheatsettings.nofalldamage and remote == "DamageSelf" and args[2] ~= "waddup") then return end;
    return OldFireServer(self, remote, ...)
end

local mt = getrawmetatable(game)
local old = mt.__namecall 
setreadonly(mt, false) 
mt.__namecall = newcclosure(function(self,...) 
    local args = {...} 
    if getnamecallmethod() == 'FireServer' and self.Name == "ACRoll" and cheatsettings.infinitestamina then --and type(args[1]) == string then
         return 
    end
    return old(self,unpack(args)) 
end)

local OldCharacterRagdoll = PlayerCharacterModule.Ragdoll;
PlayerCharacterModule.Ragdoll = function(...)
    if (cheatsettings.antiragdoll) then return end;
    return OldCharacterRagdoll(...);
end

local OldCanRoll = PlayerCharacterModule.CanRoll
PlayerCharacterModule.CanRoll = function(...)
    if cheatsettings.alwaysroll then
        return true end;
    return OldCanRoll(...);
end

local OldRoll = PlayerCharacterModule.Roll
PlayerCharacterModule.Roll = function(t)
    if cheatsettings.rollspeed then
        spawn(function()
            repeat t.RollSpeed = cheatsettings.rollspeed wait() until cheatsettings.rollspeed == false
        end)
    end
    return OldRoll(t);
end



--===================================={GUI MAKING}====================================--
library = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/scripts/main/drawinglib.lua"))() do
library.new({size = Vector2.new(315,445), name = "yeehaw", mousedisable = true, font = 2, titlecolor = Color3.fromRGB(255,163,26)})
end

-- tabs
local CheatsTab = library.newtab({name = "Cheats"})
--local AFTab = library.newtab({name = "Autofarms"})
local MiscTab = library.newtab({name = "Misc"})

--sections
--[[
ore = library.newsection({name = "Ore Autofarm", tab = AFTab,side = "left", size = 60,})
library.newdropdown({
    name = "Pickaxe Slot",
    options = {"4", "5", "6"},
    tab = AFTab,
    section = ore,
    callback = function(slot) 
       afsettings.slots.ofarm = slot 
    end
})

library.newtoggle({
	name = "ON/OFF",
	section = ore,
	tab = AFTab,
	textcolor = Color3.fromRGB(0,255,0),
	callback = function(bool)
	    if afsettings.bearbool then return notify("no", "already autofarming") end
	    afsettings.bearbool = bool
	end
})


bear = library.newsection({name = "Bear Autofarm", tab = AFTab,side = "right", size = 60,})
library.newdropdown({
    name = "Gun Slot",
    options = {"1", "2"},
    tab = AFTab,
    section = bear,
    callback = function(slot) 
       afsettings.slots.bfarm = slot 
    end
})

library.newtoggle({
	name = "ON/OFF",
	section = bear,
	tab = AFTab,
	textcolor = Color3.fromRGB(0,255,0),
	callback = function(bool)
	    if afsettings.orebool then return notify("no", "already autofarming") end
	    afsettings.bearbool = bool
	end
})


settings = library.newsection({name = "Settings", tab = AFTab,side = "right", size = 125,})
library.newcolorpicker({
	name = "Path Color",
	def = Color3.fromRGB(255,255,255),
	section = settings,
	tab = AFTab,
	transp = 0,
	transparency = true,
	callback = function(color)
	    print(color)
	end
})
]]
--

aim = library.newsection({name = "Aimbot", tab = CheatsTab,side = "left", size = 230,})
    library.newtoggle({
	    name = "Aimbot",
    	section = aim,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.aim.aimbot = bool
    	end
    })


    library.newtoggle({
	    name = "Silent Aim",
	    section = aim,
	    tab = CheatsTab,
	    callback = function(bool)
	       cheatsettings.aim.silentaim = bool
	    end
    })

    library.newdropdown({
        name = "Target Part",
        options = {"Head", "HumanoidRootPart", "Automatic"},
        tab = CheatsTab,
        section = aim,
        callback = function(part) 
            cheatsettings.aim.target = part
        end
    })

    library.newtoggle({
	    name = "Visible Check",
	    section = aim,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.aim.visiblecheck = bool
	    end
    })

    library.newtoggle({
	    name = "Team Check",
	    section = aim,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.aim.teamcheck = bool
	    end
    })

    library.newtoggle({
	    name = "FOV Circle",
	    section = aim,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.aim.fovcircle = bool
	    end
    })

    library.newslider({
	    name = "Circle Radius",
	    ended = false,
	    min = 1,
	    max = 100,
	    def = cheatsettings.aim.fovcircleradius/10,
	    section = aim,
	    tab = CheatsTab,
	    callback = function(num)
	    cheatsettings.aim.fovcircleradius = num*10
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
	        cheatsettings.aim.fovcirclethickness = num
	    end
    })

    library.newslider({
	    name = "Circle Transparency",
	    ended = false,
	    min = 1,
	    max = 10,
	    def = cheatsettings.aim.fovcircletransp,
	    section = aim,
	    tab = CheatsTab,
	    callback = function(num)
	        cheatsettings.aim.fovcircletransp = (10-num)/10
	    end
    })

    library.newcolorpicker({
	    name = "Circle Color",
	    def = cheatsettings.aim.fovcirclecolor,
	    section = aim,
	    tab = CheatsTab,
	    transp = 0,
	    transparency = false,
	    callback = function(color)
	        cheatsettings.aim.fovcirclecolor = Color3.fromHSV(color[1],color[2],color[3])
	    end
    })

esp = library.newsection({name = "ESP", tab = CheatsTab,side = "right", size = 280,})
    library.newtoggle({
	    name = "ON/OFF",
	    section = esp,
	    textcolor = Color3.fromRGB(0,255,0),
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.esp.toggle = bool
	    end
    })

    library.newtoggle({
    	name = "Players",
    	section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.esp.showplayers = bool
    	end
    })

    library.newtoggle({
	    name = "Animals (& Legendary)",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.esp.showanimals = bool
	    end
    })

    library.newtoggle({
	    name = "Ores",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.esp.showores = bool
	    end
    })

    library.newtoggle({
	    name = "Show Team Color",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.esp.ShowTeam = bool
	    end
    })

    library.newtoggle({
	    name = "Tracers",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.esp.ShowLine = bool
    	end
    })

    library.newtoggle({
	    name = "Boxes",
	    section = esp,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.esp.ShowBox = bool
	    end
    })


    library.newtoggle({
    	name = "Visibility",
    	section = esp,
    	def = true,
    	tab = CheatsTab,
    	callback = function(bool)
    	    cheatsettings.esp.ObstructedInfo = bool
    	end
    })

    library.newslider({
	    name = "Line Transparency",
	    ended = false,
	    min = 0,
	    max = 10,
    	def = 0,
	    section = esp,
	    tab = CheatsTab,
	    callback = function(num)
	        cheatsettings.esp.LineTransparency = (10-num)/10
	    end
    })

    library.newslider({
	    name = "Text Transparency",
	    ended = false,
	    min = 0,
	    max = 10,
	    def = 0,
	    section = esp,
	    tab = CheatsTab,
	    callback = function(num)
	        cheatsettings.esp.TextTransparency = (10-num)/10
	    end
    })

    library.newcolorpicker({
	    name = "Player Color",
	    def = cheatsettings.esp.PlayerColor,
	    section = esp,
	    tab = CheatsTab,
	    transp = 0,
	    transparency = false,
	    callback = function(color)
	        cheatsettings.esp.PlayerColor = Color3.fromHSV(color[1],color[2],color[3])
	    end
    })

    library.newcolorpicker({
	    name = "Animal Color",
	    def = cheatsettings.esp.AnimColor,
	    section = esp,
	    tab = CheatsTab,
	    transp = 0,
	    transparency = true,
	    callback = function(color)
	        cheatsettings.esp.AnimColor = Color3.fromHSV(color[1],color[2],color[3])
	    end
    })


charsec = library.newsection({name = "Character", tab = CheatsTab,side = "left", size = 205,})
    library.newtoggle({
	    name = "Infinite Stamina",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.infinitestamina = bool
	    end
    })

    library.newtoggle({
	    name = "No Fall Damage",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.nofalldamage = bool
	    end
    })

    library.newtoggle({
	    name = "No Jump Cooldown",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.nojumpcooldown = bool
	    end
    })

    library.newtoggle({
	    name = "Anti Ragdoll",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.antiragdoll = bool
	    end
    })

    library.newtoggle({
	    name = "Instant Get Up",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.instantgetup = bool
	    end
    })

    library.newtoggle({
	    name = "Instant Break Free",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.instantbreakfree = bool
	    end
    })
    library.newtoggle({
	    name = "Roll Anywhere",
	    section = charsec,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.alwaysroll = bool
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
	            cheatsettings.rollspeed = false
	            return
	        end
	        cheatsettings.rollspeed = num
	    end
    })


guns = library.newsection({name = "Tools", tab = CheatsTab,side = "right", size = 155,})
    library.newtoggle({
	    name = "No Recoil",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.norecoil = bool
	    end
    })
    
    library.newtoggle({
	    name = "No Spread",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.nospread = bool
	    end
    })

    library.newtoggle({
	    name = "No Delay",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.nodelay = bool
	    end
    })

    library.newtoggle({
	    name = "Instant Reload",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.instantreload = bool
	    end
    })

    library.newtoggle({
	    name = "Use In Water, etc.",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.regeneration = bool
	    end
    })

    library.newtoggle({
	    name = "Mine Aura",
	    section = guns,
	    tab = CheatsTab,
	    callback = function(bool)
	        cheatsettings.mineaura = bool
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
	        cheatsettings.mineauradistance = num
	    end
    })



misc = library.newsection({name = "Fun", tab = MiscTab,side = "left", size = 185,})
    library.newkeybind({name = "Suicide", def = "K", section = misc, tab = MiscTab, callback = function(key) cheatsettings.keys.Suicide = key end})
    
    library.newkeybind({name = "Ragdoll", def = "L", section = misc, tab = MiscTab, callback = function(key) cheatsettings.keys.Ragdoll = key end})
    
    library.newkeybind({name = "Equip Harmonica", def = "N", section = misc, tab = MiscTab, callback = function(key) cheatsettings.keys.Harmonica = key end})
    
    library.newslider({
	    name = "Ragdoll Speed",
	    ended = bool,
	    min = 0,
	    max = 20,
	    def = 1,
	    section = misc,
	    tab = MiscTab,
	    callback = function(num)
	        cheatsettings.ragdollspeed = num
	    end
    })

    library.newdropdown({
        name = "Ragdoll Direction",
        options = {"Up", "Right", "Forward"},
        tab = MiscTab,
        section = misc,
        callback = function(direct) 
            if direct == "Up" then
                cheatsettings.ragdolldirection = 'UpVector'
            elseif direct == 'Right' then
                cheatsettings.ragdolldirection = 'RightVector'
            elseif direct == 'Forward' then
                cheatsettings.ragdolldirection = 'LookVector'
            end
        end
    })

    library.newtoggle({
	    name = "Body Size Pulse",
	    section = misc,
	    tab = MiscTab,
	    callback = function(bool)
	        cheatsettings.sizepulse = bool
	    end
    })

    library.newtoggle({
	    name = "Anti Racism",
	    section = misc,
	    tab = MiscTab,
	    callback = function(bool)
	        cheatsettings.antiracist = bool
	    end
    })

    library.newbutton({name = "Equip Broom",section = misc,tab = MiscTab,callback = function()Global.PlayerCharacter:EquipItem('Broom')end})
    
respawns = library.newsection({name = "Quick Respawn", tab = MiscTab,side = "right", size = 165,})
    for i,v in next, places do
        library.newbutton({name = v[1], tab = MiscTab, section = respawns, callback = function() game:GetService("ReplicatedStorage").Communication.Functions.Respawn:InvokeServer(v[2]) end})
    end

mayor = library.newsection({name = "Mayor", tab = MiscTab,side = "left", size = 75,})
    library.newtextbox({
        name = "Pardon Player",
	    section = mayor,
	    lower = true,
	    tab = MiscTab,
	    callback = function(plr)
	        print(plr)
	        game:GetService("ReplicatedStorage").Communication.Events.AttemptPardonPlayer:FireServer(Players:FindFirstChild(plr))
	    end
    })

general = library.newsection({name = "General", tab = MiscTab,side = "right", size = 70,})
    library.newtoggle({
	    name = "Fullbright",
	    section = general,
	    tab = MiscTab,
	    callback = function(bool)
	        Fullbright(bool)
	    end
    })

discord = library.newsection({name = "Discord", tab = MiscTab,side = "right", size = 30,})
    library.newbutton({name = "Copy to Clickboard",section = discord,tab = MiscTab,callback = function()setclipboard('https://discord.gg/qT4KvqY7')end})

library.opentab(CheatsTab)
library.init()
