repeat wait() until game:IsLoaded()

--=======\Variables\
local Players = game:GetService("Players");     
local Lighting = game:GetService("Lighting");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local CoreGui = game:GetService("CoreGui");
local ScriptContext = game:GetService("ScriptContext");
local VRService = game:GetService("VRService");
local VirtualUser = game:GetService("VirtualUser");
local RunService = game:GetService("RunService");
local HttpService = game:GetService("HttpService");
local UserInputService = game:GetService("UserInputService");
local MarketplaceService = game:GetService("MarketplaceService");
local VirtualInputManager = game:GetService("VirtualInputManager")
local CurrentCamera = workspace.CurrentCamera;

local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Mouse = LocalPlayer:GetMouse();
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(); 

local inGroup = LocalPlayer:IsInGroup(2726951) and true or false
local VIP = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, 2465866) and true or false

local VehicleInformation = ReplicatedStorage:FindFirstChild("VehicleInformation");
local HelicopterContainer = ReplicatedStorage:FindFirstChild("HelicopterContainer")
local CarCollection = workspace:FindFirstChild("CarCollection");
local rF = ReplicatedStorage:FindFirstChild("rF");
local rE = ReplicatedStorage:FindFirstChild("rE");

--\Libraries\
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/UI-Libraries/main/NotificationLib.lua"))()
function err(txt)
    Notification.Notify("Error", txt, "rbxassetid://1491260682", {
        Duration = 3,
        TitleSettings = {
            BackgroundColor3 = Color3.fromRGB(200, 200 , 200),
            TextColor3 = Color3.fromRGB(255, 0, 0),
            TextScaled = true,
            TextWrapped = true,
            TextSize = 14,
            Font = Enum.Font.SourceSansBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        },
        DescriptionSettings = {
            BackgroundColor3 = Color3.fromRGB(200, 200 ,200),
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextScaled = true,
            TextWrapped = true,
            TextSize = 14,
            Font = Enum.Font.SourceSansBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        },
        IconSettings = {
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),               
        },
        GradientSettings = {
            GradientEnabled = false,
            SolidColorEnabled = true,
            SolidColor = Color3.fromRGB(255,0,0),
            Retract = true,
            Extend = false,
        },
        Main = {
            BorderColor3 = Color3.fromRGB(255, 0, 0),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BackgroundTransparency = 0.05,
            Rounding = false,
            BorderSizePixel = 1
        }
    })
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/UI-Libraries/main/hub-lib.lua"))()
library.theme = {
    fontsize = 15,
    font = Enum.Font.Code,
    background = "rbxassetid://0",
    backgroundcolor = Color3.fromRGB(20, 20, 20),
    tabstextcolor = Color3.fromRGB(230, 230, 230),
    bordercolor = Color3.fromRGB(60, 60, 60),
    accentcolor = Color3.fromRGB(160,32,240),
    accentcolor2 = Color3.fromRGB(255, 255, 255),
    outlinecolor = Color3.fromRGB(60, 60, 60),
    outlinecolor2 = Color3.fromRGB(0, 0, 0),
    sectorcolor = Color3.fromRGB(30, 30, 30),
    toptextcolor = Color3.fromRGB(255, 255, 255),
    topheight = 48,
    topcolor = Color3.fromRGB(30, 30, 30),
    topcolor2 = Color3.fromRGB(30, 30, 30), -- Color3.fromRGB(12, 12, 12),
    buttoncolor = Color3.fromRGB(49, 49, 49),
    buttoncolor2 = Color3.fromRGB(39, 39, 39),
    itemscolor = Color3.fromRGB(170, 170, 170),
    itemscolor2 = Color3.fromRGB(200, 200, 200)
}

if not CarCollection or not rF or not rE then return err("Wrong game") else Notification.Notify("Car Crushers 2", "made by saucekid", Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)); wait(1) end -- check

if ReplicatedStorage:FindFirstChild("ClientError") then
    ReplicatedStorage.ClientError:Destroy() -- remove error logging to game devs
end

--\Toggles\
flags = {
    invincible = {},
    autofarm = {},
    silent = {},
    autoescape = {},
    tweentp = {},
    tweenspeed = {value = 500},
    boostspeed = {value = 100}
}

for _,flag in pairs(flags) do 
    if not flag["value"] then flag.value = false end
    setmetatable(flag, { -- im pro
        __call = function(self, b)
            self.value = b
        end
    })
end

--=======\Functions\
function getCar()
    return CarCollection:FindFirstChild(LocalPlayer.Name) and CarCollection[LocalPlayer.Name].Car or false
end

function getbestCar(realname)
    local bestName = ""
    local bestPrice = 0
    for _, car in pairs(VehicleInformation:GetChildren()) do
        if not VIP and car.VipOnly.Value == true then continue end
        if not inGroup and car.GroupOnly.Value == true then continue end
        local name = realname and car:FindFirstChild("Name").Value or car.Name
        local price = car.Price.Value
        if price > bestPrice and price <= LocalPlayer.Money.Value and car.TokenRequirement.Value <= LocalPlayer.leaderstats.Tokens.Value then
            bestName = name
            bestPrice = price
        end
    end
    return bestName
end

function spawnCar()
    local bestCar = getbestCar()
    rF.SpawnVehicle:InvokeServer(bestCar)
end

function flingCar()
    car = getCar()
    if not car then return err("no car currently active") end
    car.PrimaryPart.RotVelocity = Vector3.new(2000,0,0)
end

function bringCar()
    car = getCar()
    if not car then return err("no car currently active") end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return err("you are dead") end
    car.PrimaryPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end

function boost()
    car = getCar()
    if not car then return err("no car currently active") end
    car.PrimaryPart.Velocity = (-car.PrimaryPart.CFrame.lookVector*(car.PrimaryPart.Velocity.Magnitude/70)*flags.boostspeed.value)
end

function destroyCar()
    car = getCar()
    if not car then return err("no car currently active") end
    for i = 1,5 do
        local parts = {}
        local collision
        for i,v in pairs(car:GetDescendants()) do
            if v:IsA("BasePart") then
                if v.Parent == car.Body.HitBoxes and v.Name == "Collision" then collision = v end
                table.insert(parts, v)
            end
        end
        car.PrimaryPart.Velocity = Vector3.new(0,400,0)--car.PrimaryPart.CFrame.lookVector*1000*Vector3.new(1,0,1)
        rF.BreakParts:InvokeServer(parts, collision, car.PrimaryPart.Velocity.Magnitude, "Default", car.PrimaryPart.Velocity, false)
        wait()
    end
end

function getClosestEntrance(part)
    local target = nil
    local maxDist = math.huge
    for _,v in pairs(workspace.Building.Floor.CrusherDecoration:GetDescendants()) do
        if v:IsA("MeshPart") and v.Name == "MeshPart" then
            local dist = (part.Position - v.Position).Magnitude
            if dist < maxDist then
                maxDist = dist
                target = v
            end
        end
    end
    return target
end
    
function removeTags(chr)
    local head = chr:WaitForChild("Head")
    for _,v in pairs(head:GetChildren()) do
        if v:IsA("BillboardGui") then v:Destroy() end
    end
end

function escape(heli)
    wait(1)
    if heli.Name == "Helicopter" then
        local chr = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = chr:WaitForChild("Humanoid")
        local root = chr:WaitForChild("HumanoidRootPart") 
        TP(heli:FindFirstChildOfClass("BasePart").Position)
    end
end

local function TP(destination)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return err("you are dead") end
    if flags.tweentp.value then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
        local speed = flags.tweenspeed.value
        local distance = (root.Position - destination).magnitude
        local time = distance/speed
        local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(destination)})
        tween:Play()
        tween.Completed:Wait()
    else
        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(destination))
    end
end

function joindiscord()
    if not syn then return err("synapse only") end
    local json = {
        ["cmd"] = "INVITE_BROWSER",
            ["args"] = {
            ["code"] = "DnyxZRwQh3"
        },
        ["nonce"] = 'a'
        }
    spawn(function()
        print(syn.request({
            Url = 'http://127.0.0.1:6463/rpc?v=1',
            Method = 'POST',
            Headers = {
                ['Content-Type'] = 'application/json',
                ['Origin'] = 'https://discord.com'
              },
            Body = game:GetService('HttpService'):JSONEncode(json),
        }).Body)
    end)
end
        
LocalPlayer.Idled:connect(function()    --antiafk
    if flags.autofarm.value then
        VirtualUser:Button2Down(Vector2.new(0,0),CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0),CurrentCamera.CFrame)
    end
end)

spawn(function()
    while wait() do
        if flags.autofarm.value then
            local bestCar = getbestCar()
            local car = getCar()
            if not car then
                rE.SaveCustoms:FireServer({true, "Institutional white", "Platinum"}, bestCar)
                wait()
                repeat 
                    rF.SpawnVehicle:InvokeServer(bestCar)
                    car = getCar()
                    wait() 
                until car ~= false or not flags.autofarm.value --until PlayerGui.VehicleMenu.Menu.Background.Background.RespawnLabel.Text == "Respawn vehicle [R]"
            end
            wait(1)
            if not flags.autofarm.value then return end
            if flags.silent.value then car:SetPrimaryPartCFrame(CFrame.new(5999.8056640625, 6.4365487098694, 2861.6376953125)) end
            destroyCar()
            wait(1)
            rE.Delete:FireServer()
        end
    end
end)


local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local args = {...} 
    if not checkcaller() then 
        if Self.Name == "BreakParts" and flags.invincible.value then  return end
    end
    return OldNamecall(Self, unpack(args))
end)

--=======\UI\
local window = library:CreateWindow("Car Crushers 2", Vector2.new(410, 400), Enum.KeyCode.RightShift)
    local mainTab = window:CreateTab("Main")
        local infoSec = mainTab:CreateSector("Info")
            local bestcarstring = "Best Car: "
            bestcar_label = infoSec:AddLabel(bestcarstring)
            spawn(function()
                while wait() do
                    local bestCar = getbestCar(true)
                    bestcar_label:Set(bestcarstring..bestCar)
                end
            end)
            
            local moneystring = "Money Earned: "
            moneymade_label = infoSec:AddLabel(moneystring.. "0")
            
            spawn(function()
                local moneymade = 0
                while true do
                    local money = LocalPlayer.Money
                    local oldvalue = money.Value
                    local value = money.Changed:Wait()
                    moneymade = math.round(moneymade + (value - oldvalue))
                    moneymade_label:Set(moneystring..moneymade)
                end
            end)
            
            local partsstring = "Parts Earned: "
            partsmade_label = infoSec:AddLabel(partsstring.. "0")
            spawn(function()
                local partsmade = 0
                while true do
                    local parts = LocalPlayer.Parts
                    local oldvalue = parts.Value
                    local value = parts.Changed:Wait()
                    partsmade = math.round(partsmade + (value - oldvalue))
                    partsmade_label:Set(partsstring..partsmade)
                end
            end)
            
        local afSec = mainTab:CreateSector("Autofarm", "right")
            afSec:AddLabel("― Car Autofarm")
            af_toggle = afSec:AddToggle("ON/OFF", flags.autofarm.value, flags.autofarm)
            silent_toggle = afSec:AddToggle("Silent", flags.silent.value, flags.silent)
            
            afSec:AddLabel("― Auto Escape/Helicopter")
            local escapeCon
            ae_toggle = afSec:AddToggle("ON/OFF", false, function(bool) 
                if bool then 
                    local heli = HelicopterContainer:FindFirstChild("Helicopter")
                    if heli then escape(heli) end 
                    escapeCon = HelicopterContainer.ChildAdded:Connect(escape) 
                else 
                    if escapeCon then escapeCon:Disconnect() end 
                end
            end)
            
        local carSec = mainTab:CreateSector("Car")
            invincible_toggle = carSec:AddToggle("No Damage", flags.invincible.value, flags.invincible)
            boost_keybind = carSec:AddKeybind("Boost",Enum.KeyCode.C, nil, boost)
            boostspeed_slider = carSec:AddSlider("Boost Speed", 1, flags.boostspeed.value, 1000, 1, flags.boostspeed)
            spawn_button = carSec:AddButton("Spawn Car", spawnCar)
            bring_button = carSec:AddButton("Bring Car", bringCar)
            --fling_button = carSec:AddButton("Fling Car", flingCar)
            destroy_button = carSec:AddButton("Destroy Car", destroyCar)
            
        local charSec = mainTab:CreateSector("Character", "right")
            charSec:AddLabel("― Remove Tags")
            
            local removeCon
            removeTags_button = charSec:AddToggle("ON/OFF", false, function(bool) 
                if bool then 
                    removeTags(LocalPlayer.Character) 
                    removeCon = LocalPlayer.CharacterAdded:Connect(removeTags) 
                else 
                    if removeCon then removeCon:Disconnect() end 
                end 
            end)
        
        local teleSec = mainTab:CreateSector("Teleports", "right")
            if workspace:FindFirstChild("Crusher Parts") then
                local teleports = {}
                local tpNames = {}
                for _,v in pairs(workspace["Crusher Parts"]:GetChildren()) do
                    teleports[v.Name] = v.Entrance.Part
                    table.insert(tpNames, v.Name)
                end
                    
                tp_dropdown = teleSec:AddDropdown("Crushers", tpNames, "Select", function(c) 
                    local entrance = getClosestEntrance(teleports[c])
                    if not entrance then return err("no entrance?") end
                    TP(entrance.Position)
                end)
            end
            
            tweentp_toggle = teleSec:AddToggle("Tween", flags.tweentp.value, flags.tweentp)
            tweenspeed_slider = teleSec:AddSlider("Tween Speed", 1, flags.tweenspeed.value, 1000, 1, flags.tweenspeed)
            
    local settingsTab = window:CreateTab("Settings")
        local serverSector = settingsTab:CreateSector("Servers")
            rejoin_button = serverSector:AddButton("Rejoin", function()
                if #Players:GetPlayers() <= 1 then
	    	        Players.LocalPlayer:Kick("\nRejoining...")
	    	        wait()
        		    game:GetService('TeleportService'):Teleport(game.PlaceId, Players.LocalPlayer)
        	    else
        		    game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
        	    end
            end)
            smallest_button = serverSector:AddButton("Join Smallest Server", function()
                if syn then 
                    coroutine.resume(coroutine.create(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/scripts/main/JoinLowestPlayer.lua"))()  end))
                else
                    err("Sorry, this function is Synapse only")
                end
            end)
            serverhop_button = serverSector:AddButton("Server Hop", function()
                local x = {}
	                for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
         		if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
            			x[#x + 1] = v.id
            		end
            	end
            	if #x > 0 then
            		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
            	else
            		return notify("Couldn't find a server")
            	end
            end)    
            
        local discSector = settingsTab:CreateSector("Discord", "right")
            joindisc_button = discSector:AddButton("Direct Join", joindiscord)
            copydisc_button = discSector:AddButton("Copy to Clipboard", function() if setclipboard then setclipboard('https://discord.gg/DnyxZRwQh3') else print("DnyxZRwQh3") end end)
        
        
    
