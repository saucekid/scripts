repeat wait() until game:IsLoaded() and game.PlaceId == 2317712696 

----[variable]
local runservice = game:GetService("RunService");
local players = game:GetService("Players");
local LocalPlayer = Players
local entities = game:GetService("Workspace")["WORKSPACE_Entities"];
local geometry = game:GetService("Workspace")["WORKSPACE_Geometry"];
local animals = entities.Animals;

local spawnlocations = {
    ["Bronze"] = Vector3.new(753, 38, -842);
    ["Dorado"] = Vector3.new(1403, 122, 1855);
    ["Tribal"] = Vector3.new(-1347, 141, -898);
    ["Delores"] = Vector3.new(543, 39, 460);
    ["HowlingPeak"] = Vector3.new(1681, 330, 1503)
}

local message = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/UI-Libraries/main/MessageCreate.lua"))();
error = {PrimaryColor = Color3.fromRGB(0,0,0), SecondaryColor = Color3.fromRGB(255,0,0), Texts = {{Text = "nothing here", Delay = 1}}}

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/UI-Libraries/main/ESPLibrary.lua"))();
ESP.Players = _G.ShowPlayers 
ESP.Tracers = _G.Tracers

----[functions]
function serverhop()
    local x = {}
	for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
		if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
			x[#x + 1] = v.id
		end
	end
	if #x > 0 then
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
	end
end

function getClosestSpawn(pos)
    local target = nil
    local maxDist = math.huge
    for i,v in pairs(spawnlocations) do
        local mag = (pos - v).magnitude
        if mag < maxDist then
            maxDist = mag
            target = i
        end
    end
    return target
end

function playsound(soundid, volume, dur)
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

----[get legendry and thunder]
local things = {}

for _,anim in pairs(animals:GetChildren()) do
    local health = anim:WaitForChild("Health")
    if health and health.Value > 200 then
        ESP:Add(anim.PrimaryPart, {Name = "Legendary ".. anim.Name, Color = Color3.new(255,255,0)})
        table.insert(things, anim.PrimaryPart)
    end
end

for _,particle in pairs(geometry:GetDescendants()) do
   if particle:IsA("ParticleEmitter") and particle.Name == "Strike2" then
       ESP:Add(particle.Parent, {Name = "Thunderstruck Tree", Color = Color3.new(255,255,0)})
       table.insert(things, particle.Parent)
   end
end

----[yay or noooo]
if #things <= 0 then message.Create(error) wait(2) return serverhop() end

closestspawn = getClosestSpawn(things[1].Position)
game:GetService("ReplicatedStorage").Communication.Functions.Respawn:InvokeServer(closestspawn)

message.Create({PrimaryColor = Color3.fromRGB(0,0,0), SecondaryColor = Color3.fromRGB(255,255,0), Texts = {{Text = tostring(#things).. " found", Delay = 2}}})
ESP:Toggle(true)
playsound("rbxassetid://".. tostring(_G.SoundId), _G.Volume or 2, 3)

if _G.LaunchYeehaw then loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/scripts/main/yeehaw.lua"))() end
