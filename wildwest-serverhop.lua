----[variable]
local httpservice = game:GetService("HttpService");
local runservice = game:GetService("RunService");
local players = game:GetService("Players");
local LocalPlayer = Players;
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
error = {PrimaryColor = Color3.fromRGB(0,0,0), SecondaryColor = Color3.fromRGB(255,0,0), Texts = {{Text = "nothing", Delay = .1}}}

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/UI-Libraries/main/ESPLibrary.lua"))();
ESP.Players = options.ShowPlayers 
ESP.Tracers = options.Tracers

----[functions]
function existsFile(name)
    if not readfile then return end
    return pcall(function()
        return readfile(name)
    end)
end

function load()
    if not existsFile("serverhop.json") then return end
    local _, Result = pcall(readfile, "serverhop.json");
    if _ then 
        local _, Table = pcall(httpservice.JSONDecode, httpservice, Result);
        if _ then
            for i, v in pairs(Table) do
                if options[i] ~= nil  then
                    options[i] = v;
                    pcall(options[i], v);
                end
            end
        end
    end
end

function save()
    if writefile then
        writefile("serverhop.json", httpservice:JSONEncode(options));
    end
end

function serverhop()
    local x = {}
	for _, v in ipairs(httpservice:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
		if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
			x[#x + 1] = v.id
		end
	end
	if #x > 0 then
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
	end
end

function write(input,color)
    spawn(function()
        rconsoleprint(color and "@@".. string.upper(color).. "@@" or "@@WHITE@@")
        rconsoleprint(input.."\n")
        runservice.RenderStepped:Wait()
        rconsoleprint("@@WHITE@@")
    end)
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

--couldve used getgenv() but krnl not have :(
save()
load()  

if options.Console then 
    if not rconsoleprint or not rconsoleclear then return message.Create({PrimaryColor = Color3.fromRGB(0,0,0), SecondaryColor = Color3.fromRGB(255,0,0), Texts = {{Text = "Console is Synapse only", Delay = 2}}}) end
    rconsoleclear()
    write([[
                          _   _ ___________ 
                         | | | |  _  | ___ \
 ___  __ _ _   _  ___ ___| |_| | | | | |_/ /
/ __|/ _` | | | |/ __/ _ \  _  | | | |  __/ 
\__ \ (_| | |_| | (_|  __/ | | \ \_/ / |    
|___/\__,_|\__,_|\___\___\_| |_/\___/\_|    
]].. "\n", "magenta")
    write("Waiting for game to load... \n")
end

repeat wait() until game:IsLoaded() and game.PlaceId == 2317712696 

----[get legendry and thunder]
local things = {}

for _,anim in pairs(animals:GetChildren()) do
    local health = anim:WaitForChild("Health")
    if health and health.Value > 200 then
        if options.Console then write("Legendary ".. anim.Name.. " Found!", "yellow") end
        ESP:Add(anim, {Name = "Legendary ".. anim.Name, Color = Color3.new(255,255,0)})
        table.insert(things, anim.PrimaryPart)
    end
end

for _,particle in pairs(geometry:GetDescendants()) do
   if particle:IsA("ParticleEmitter") and particle.Name == "Strike2" then
       if options.Console then write("Thunderstruck Tree Found!", "yellow") end
       ESP:Add(particle.Parent.Parent, {Name = "Thunderstruck Tree", Color = Color3.new(255,255,0)})
       table.insert(things, particle.Parent)
   end
end

----[yay or noooo]
if #things <= 0 then
    if options.Console then
        write("Nothing Found :(", "red")
        wait()
        write("Hopping...")
    else
        message.Create(error) 
        wait(1)
    end
    serverhop()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/scripts/main/wildwest-serverhop.lua"))()
end

closestspawn = getClosestSpawn(things[1].Position)
game:GetService("ReplicatedStorage").Communication.Functions.Respawn:InvokeServer(closestspawn)

if not options.Console then
    message.Create({PrimaryColor = Color3.fromRGB(0,0,0), SecondaryColor = Color3.fromRGB(255,255,0), Texts = {{Text = tostring(#things).. " found", Delay = 2}}})
end

ESP:Toggle(true)
playsound("rbxassetid://".. tostring(options.SoundId), options.Volume or 2, 3)

if options.LaunchYeehaw then loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/scripts/main/yeehaw.lua"))() end
