repeat wait() until game.ContentProvider.RequestQueueSize > 0
if game.PlaceId ~= 6872265039 and game.PlaceId ~= 6872274481 then return end
------------[services]
local plrs = game:GetService("Players");
local rs = game:GetService("RunService");
local repstorage = game:GetService("ReplicatedStorage");
local uis = game:GetService("UserInputService");
local vu = game:GetService("VirtualUser");
local HttpService = game:GetService("HttpService")

local plr = plrs.LocalPlayer;
local plrscripts = plr.PlayerScripts
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/UI-Libraries/main/ESPLibrary.lua"))();

local TS = plrscripts.TS
local rodux = TS.rodux:FindFirstChild("rodux");
local remotefolder = game.ReplicatedStorage:WaitForChild("rbxts_include")["node_modules"]["net"]["out"]["_NetManaged"]
local nodemodules = repstorage.rbxts_include.node_modules
local runtime = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"));
local blockplacement = TS.controllers.game["block-placement-controller"]
local knockbackutil = require(repstorage.TS.damage['knockback-util'])

local mt = getrawmetatable(game);
local old = mt.__namecall;
setreadonly(mt, false);

------------[settings setup]
local settings = {
    cheats = {
        killaura = false,
        karange = 15,
        fastbreak = false,
        nofalldamage = false,
        antikb = false, 
        autopickup = false,
    },
    esp = {
        toggle = false,
        players = true,
        resources = true,
        teamcolor = true,
        tracers = false,
        boxes = true,
        names = true,
    },
    misc = {
        lobby = "Doubles"
    },
    keys = {
        scaffold = "R",
        buywool = "Z",
        nuker = "T"
    },
    filename = 'sauce.client'
}



local function existsFile(name)
    return pcall(function()
        return readfile(name)
    end)
end

function Load()
    if not existsFile(settings.filename) then return end
    local _, Result = pcall(readfile, settings.filename);
    if _ then 
        local _, Table = pcall(HttpService.JSONDecode, HttpService, Result);
        if _ then
            for i, v in pairs(Table) do
                if settings[i] ~= nil  then
                    settings[i] = v;
                    pcall(settings[i], v);
                end
            end
        end
    end
end

function Save()
    if writefile then
        writefile(settings.filename, HttpService:JSONEncode(settings));
    end
end

game.Players.PlayerRemoving:Connect(function(plr)
    if plr == game.Players.LocalPlayer then
        Save()
    end
end)

local lobbies = {
    ["Doubles"] = "bedwars_to2",
    ["Squads"] = "bedwars_to4"
}
local lobbynames = {"Doubles", "Squads"}

local keybinds = {"Q", "R", "T", "Y", "Z", "X", "C", "V"}

ESP:AddObjectListener(workspace.ItemDrops, {
    Type = "Part",
    PrimaryPart = "Handle",
    CustomName = function(obj)
        local spl = string.split(obj.Name, " ")
	    for i,v in pairs(spl) do
	        spl[i] = v:sub(1,1):upper() .. v:sub(2)
	    end
	    local result = table.concat(spl, " ")
        return result
    end,
    Color = function(obj)
        return obj.Handle.Color
    end,
    IsEnabled = "Resources"
})

Load()
ESP:Toggle(settings.esp.toggle)
ESP.Boxes = settings.esp.boxes
ESP.Names = settings.esp.names
ESP.Tracers = settings.esp.tracers
ESP.Players = settings.esp.players
ESP.Resources = settings.esp.resources

------------[actual thingies]
local scaffhold = false
local nukehold = false

func = hookfunction(wait, function(temi) 
    if tostring(getcallingscript(func)) == "rodux" and settings.cheats.fastbreak then 
        return func() 
    end 
    return func(temi) 
end)


mt.__namecall = newcclosure(function(self,...) 
    local args = {...} 
    if getnamecallmethod() == 'FireServer' and self.Name == "RequestSelfDamage" and settings.cheats.nofalldamage then 
         return 
    end
    return old(self,unpack(args)) 
end)

local oldKnockback = knockbackutil.applyKnockback
knockbackutil.applyKnockback = function(...)
    if settings.cheats.antikb then
        return
    end
    return oldKnockback(...)    
end

coroutine.resume((coroutine.create(function()
    while wait(5) do
        if settings.misc.autoqueue and game.PlaceId == 6872265039 then
           remotefolder.JoinQueue:InvokeServer({["queueType"] = lobbies[settings.misc.lobby]}) 
        end
    end
end)))

rs.RenderStepped:Connect(function()
           if settings.cheats.autopickup then
           	    for _,item in pairs(workspace.ItemDrops:GetChildren()) do
				    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 and (item.Position-plr.Character.HumanoidRootPart.Position).magnitude <= 10 then
					    coroutine.wrap(function() remotefolder.PickupItemDrop:InvokeServer({["itemDrop"] = item}) end)()
                    end
                end
            end
            if settings.cheats.killaura then
                for _,player in pairs(game.Players:GetPlayers()) do
			        if player.Character and plr.Character and player.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("HumanoidRootPart") and player.Team ~= plr.Team then
				        local hum,root do
				            hum = player.Character:FindFirstChild("Humanoid")
				            root = player.Character:FindFirstChild("HumanoidRootPart")
				        end
				        if hum and root and hum.Health > 0 and (root.Position - plr.Character.HumanoidRootPart.Position).magnitude <= settings.cheats.karange then
					        remotefolder.SwordHit:InvokeServer({["entityInstance"] = player.Character, ["weapon"] = plr.Character.HandInvItem.Value})
				        end
			        end
                end
            end
            if scaffhold and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local pos = plr.Character.HumanoidRootPart.Position + plr.Character.HumanoidRootPart.Velocity*Vector3.new(1,0,1)/6
    		    for o=-1,1 do
    		        for i=-1,1 do
    				    local x, y, z = pos.X,pos.Y-5.5,pos.Z
    				    coroutine.wrap(function() remotefolder.PlaceBlock:InvokeServer({position = Vector3.new(math.ceil((x/3)-.5),math.ceil((y/3)-.5),math.ceil((z/3)-.5)),blockType = "wool_"..string.lower(plr.Team.Name)}) end)()
    			    end
    		    end
            end
            if nukehold and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                for i,v in pairs(workspace.Map.Blocks:GetChildren()) do
    				if v.Size.magnitude<=10 and (v.Position-plr.Character.HumanoidRootPart.Position).magnitude<=20 and (v.Position-plr.Character.HumanoidRootPart.Position).magnitude>=8 then
    					local x,y,z = math.ceil(v.Position.X/3),math.ceil(v.Position.Y/3),math.ceil(v.Position.Z/3)
    					coroutine.wrap(function() remotefolder.BreakBlock:InvokeServer({blockRef={blockPosition=Vector3.new(x,y,z)},hitPosition=v.Position,hitNormal=Vector3.new(0,0,1)}) end)()
    				end
    			end 
            end
    end)

------------[Keybinds]
uis.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode[settings.keys.scaffold] then
        scaffhold = true
    end
    if input.KeyCode == Enum.KeyCode[settings.keys.nuker] then
        nukehold = true
    end
    if input.KeyCode == Enum.KeyCode[settings.keys.buywool] then
        if plr.Character and plr.Character.Humanoid.Health>0 then
	        remotefolder.BedwarsPurchaseItem:InvokeServer({shopItem={price=8,currency="iron",itemType="wool_white",amount=16}})
	    end
    end
end)

uis.InputEnded:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode[settings.keys.scaffold] then
        scaffhold = false
    end
    if input.KeyCode == Enum.KeyCode[settings.keys.nuker] then
        nukehold = false
    end
end)
------------[GUI MAKING]
local message = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/UI-Libraries/main/MessageMaker.lua"))()
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/UI-Libraries/main/ArrowsUIlib.lua"))() 
_G["Theme"] = {
    ["UI_Position"] = Vector2.new(50, 300),
    ["Text_Size"] = 16,

    ["Category_Text"] = Color3.fromRGB(255, 255, 255),
    ["Category_Back"] = Color3.fromRGB(0, 0, 0),
    ["Category_Back_Transparency"] = 0.75,

    ["Option_Text"] = Color3.fromRGB(255, 255, 255),
    ["Option_Back"] = Color3.fromRGB(0, 0, 0),
    ["Option_Back_Transparency"] = 0.75,
    ["Selected_Color"] = Color3.fromRGB(179,121,33)
}

local Title = library:NewCategory("sauce client", Color3.fromRGB(255,163,26))
--[[
    Title:NewButton("Copy Discord Link", function() -- <string> name, <func> CallBack
        if setclipboard then
            message.Create({
                PrimaryColor = Color3.fromRGB(35, 39, 42),
                SecondaryColor = Color3.fromRGB(114, 137, 218), 
                Texts = {
                    {Text = "Copied Link!", Delay = 1}, 
                }
            })
            setclipboard('https://discord.gg/DnyxZRwQh3')
        end
    end)
]]
--[cheats]
local CheatsCategory = library:NewCategory("Cheats")
    CheatsCategory:NewToggle("Kill Aura", settings.cheats.killaura, function(bool) 
        settings.cheats.killaura = bool
    end)
    
    CheatsCategory:NewSlider("Kill Aura Range", settings.cheats.karange, 1, 0, 200, 2, "", function(newvalue) -- <string> name, <num> default, <num> increment, <num> min, <num> max, <num> decimals, <string> suffix, <func> CallBack
        settings.cheats.karange = tonumber(newvalue)
    end)

    CheatsCategory:NewToggle("Fast Break", settings.cheats.fastbreak, function(bool) 
        settings.cheats.fastbreak = bool
    end)
    
    CheatsCategory:NewToggle("No Fall Damage", settings.cheats.nofalldamage, function(bool) 
        settings.cheats.nofalldamage = bool
    end)
    
    CheatsCategory:NewToggle("Anti Knockback", settings.cheats.antikb, function(bool) 
        settings.cheats.antikb = bool
    end)

    CheatsCategory:NewToggle("Auto Pickup", settings.cheats.autopickup, function(bool) 
        settings.cheats.autopickup = bool
    end)
    
    CheatsCategory:NewDropdown("Buy Wool Key", keybinds, table.find(keybinds, settings.keys.buywool), function(option) 
        settings.keys.buywool = option
    end)

    CheatsCategory:NewDropdown("Scaffold Key", keybinds, table.find(keybinds, settings.keys.scaffold), function(option) 
        settings.keys.scaffold = option
    end)
    
    CheatsCategory:NewDropdown("Nuker Key", keybinds, table.find(keybinds, settings.keys.nuker), function(option) 
        settings.keys.nuker = option
    end)
    
    CheatsCategory:NewButton("Suicide", function() 
        game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.RequestSelfDamage:FireServer({["damageType"] = 1, ["secret"] = "mullet", ["damage"] = 100})
    end)
    
--[esp]
local ESPCategory = library:NewCategory("ESP")
    ESPCategory:NewToggle("ON/OFF", settings.esp.toggle, function(bool) 
        settings.esp.toggle = bool
        ESP:Toggle(bool)
    end)
    
    ESPCategory:NewToggle("Players", settings.esp.players, function(bool) 
        settings.esp.players = bool
        ESP.Players = bool
    end)

    ESPCategory:NewToggle("Resources", settings.esp.players, function(bool) 
        settings.esp.resources = bool
        ESP.Resources = bool
    end)

    ESPCategory:NewToggle("Tracers", settings.esp.tracers, function(bool) 
        settings.esp.resources = bool
        ESP.Tracers = bool
    end)

    ESPCategory:NewToggle("Boxes", settings.esp.boxes, function(bool) 
        settings.esp.boxes = bool
        ESP.Boxes = bool
    end)
    
    ESPCategory:NewToggle("Team Color", settings.esp.teamcolor, function(bool) 
        settings.esp.teamcolor = bool
        ESP.TeamColor = bool
    end)

    ESPCategory:NewColorpicker("Default Color", ESP.Color, function(col) 
        ESP.Color = col
    end)

--[Misc]
local MiscCategory = library:NewCategory("Misc")
    MiscCategory:NewDropdown("Select Mode", lobbynames, table.find(lobbynames, settings.misc.lobby), function(option) 
        settings.misc.lobby = option
    end)

    MiscCategory:NewToggle("Auto Queue", settings.misc.autoqueue, function(bool) 
        settings.misc.autoqueue = bool
    end)
    
    MiscCategory:NewButton("Join Queue", function() -- <string> name, <func> CallBack
        game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.JoinQueue:InvokeServer({["queueType"] = lobbies[settings.misc.lobby]})
    end)

--[Settings]
local SettingsCategory = library:NewCategory("Settings")
    SettingsCategory:NewButton("Save", function() -- <string> name, <func> CallBack
        Save()
    end)