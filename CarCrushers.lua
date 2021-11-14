_G.Executed = true
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
    flying = {},
    jump = {},
    crashaura = {},
    tankaura = {},
    carspeed = {value = 0},
    tweenspeed = {value = 500},
    boostspeed = {value = 100},
    vflyspeed = {value = 1},
    jumppower = {value = 10},
    crashaurarange = {value = 70},
    tankaurarange = {value = 70},
    bodypaint = {value = "Gold"}
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
    return CarCollection:FindFirstChild(LocalPlayer.Name) and CarCollection[LocalPlayer.Name]:FindFirstChild("Car") or false
end

function getbestCar(realname)
    local bestName = ""
    local bestPrice = 0
    for _, car in pairs(VehicleInformation:GetChildren()) do
        if not VIP and car.VipOnly.Value == true then continue end
        if not inGroup and car.GroupOnly.Value == true then continue end
        local name = realname and car:FindFirstChild("Name").Value or car.Name
        local price = car.Price.Value
        if price >= bestPrice and price <= LocalPlayer.Money.Value and car.TokenRequirement.Value <= LocalPlayer.leaderstats.Tokens.Value then
            bestName = name
            bestPrice = price
        end
    end
    return bestName
end

function spawnCar()
    local bestCar = getbestCar()
    task.spawn(function() rF.SpawnVehicle:InvokeServer(bestCar) end)
end

function bringCar()
    car = getCar()
    if not car then return err("no car currently active") end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return err("you are dead") end
    car.PrimaryPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end

function destroyCar()
    car = getCar()
    if not car then return err("no car currently active") end
    if LocalPlayer.Character and LocalPlayer:FindFirstChildOfClass("Humanoid") then 
        local hum = LocalPlayer:FindFirstChildOfClass("Humanoid")
        hum.Sit = false 
        hum.RootPart.Velocity = Vector3.new(0,0,0)
    end
    --[[
    local bodyPosition = car.PrimaryPart:FindFirstChild("BodyPosition") or Instance.new("BodyPosition", car.PrimaryPart)
    bodyPosition.D = 800
    bodyPosition.P = 999999999
    bodyPosition.MaxForce = Vector3.new(999999999,999999999,999999999)
    bodyPosition.Position = car.PrimaryPart.Position + Vector3.new(0,10,0)
    ]]
    for i = 1,5 do
        local parts = {}
        local collision
        for i,v in pairs(car:GetDescendants()) do
            if v:IsA("BasePart") then
                if v.Parent == car.Body.HitBoxes and v:IsA("BasePart") then collision = v end
                table.insert(parts, v)
            end
        end
        car.PrimaryPart.Velocity = Vector3.new(0,1000,0)--car.PrimaryPart.CFrame.lookVector*1000*Vector3.new(1,0,1)
        rF.BreakParts:InvokeServer(parts, collision, car.PrimaryPart.Velocity.Magnitude, "Default", car.PrimaryPart.Velocity, false)
        wait()
    end
end

function boost()
    car = getCar()
    if not car then return err("no car currently active") end
    for i = 1,50 do
        RunService.Stepped:Wait()
        car.PrimaryPart.Velocity = CFrame.new(car.PrimaryPart.Velocity):Lerp(CFrame.new(-car.PrimaryPart.CFrame.lookVector*(car.PrimaryPart.Velocity.Magnitude/70)*flags.boostspeed.value), 0.02).Position
    end
end

function jump()
    if not flags.jump.value then return end
    car = getCar()
    if not car then return end
    car.PrimaryPart.Velocity = Vector3.new(car.PrimaryPart.Velocity.X,flags.jumppower.value*10,car.PrimaryPart.Velocity.Z)
end

function tankCrash()
    for _,v in pairs(CarCollection:GetChildren()) do
        if v.Name ~= LocalPlayer.Name and v:FindFirstChild("Car") then
            if not v.Car.PrimaryPart then continue end
            for _,part in pairs(v.Car.Body.HitBoxes:GetChildren()) do
                if part:IsA("BasePart") then
                    task.spawn(function() 
                        for i = 1,3 do
                            rF.TankInvoke:InvokeServer("Fire", Vector3.new(0,0,0), part) 
                        end
                    end)
                end
            end
        end
    end
    CurrentCamera.CameraSubject = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
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

function getClosestCar(maxd)
    local car = getCar()
    if not car then return end
    local target = nil
    local maxDist = maxd
    local parts = {}
    for _,v in pairs(CarCollection:GetChildren()) do
        if v.Name ~= LocalPlayer.Name and v:FindFirstChild("Car") then
            if not v.Car.PrimaryPart or not car.PrimaryPart then continue end
            local dist = (car.PrimaryPart.Position - v.Car.PrimaryPart.Position).Magnitude
            if dist < maxDist then
                maxDist = dist
                target = v
                table.insert(parts, {v, dist})
            end
        end
    end
    local sortedParts = table.sort(parts, function(a,b)
    	return a[2] < b[2]
    end)
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
        print("escaping")
        local chr = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = chr:WaitForChild("Humanoid")
        local root = chr:WaitForChild("HumanoidRootPart") 
        TP(heli.Seats:FindFirstChildOfClass("Seat").Position)
    end
end

local function TP(destination)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return err("you are dead") end
    local car = getCar()
    local hum = LocalPlayer.Character:WaitForChild("Humanoid")
    local root = hum.Sit and car and car.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
    if flags.tweentp.value then
        speed = flags.tweenspeed.value
        distance = (root.Position - destination).magnitude
        time = distance/speed
        tween = game:GetService("TweenService"):Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(destination)})
        tween:Play()
        tween.Completed:Wait()
    else
        root.CFrame = CFrame.new(destination)
    end
end


QEfly = true
flyspeed = 1
function sFLY(vfly)
    local car = getCar()
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
    if vfly and not car then return end

	local T = car.PrimaryPart
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		flags.flying(true)
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.cframe = T.CFrame
		BV.velocity = Vector3.new(0, 0, 0)
		BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
		spawn(function()
			repeat wait()
				if not vfly and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
					Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
				end
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
				else
					BV.velocity = Vector3.new(0, 0, 0)
				end
				CurrentCamera.CameraSubject = car
				BG.cframe = BG.cframe:Lerp(workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(0,math.rad(180),0), .5)
			until not flags.flying.value
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			CurrentCamera.CameraSubject = LocalPlayer.Character
			if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
				LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
			end
		end)
	end
	flyKeyDown = Mouse.KeyDown:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = (vfly and flags.vflyspeed.value or flyspeed)
		elseif KEY:lower() == 's' then
			CONTROL.B = - (vfly and flags.vflyspeed.value or flyspeed)
		elseif KEY:lower() == 'a' then
			CONTROL.L = - (vfly and flags.vflyspeed.value or flyspeed)
		elseif KEY:lower() == 'd' then 
			CONTROL.R = (vfly and flags.vflyspeed.value or flyspeed)
		elseif QEfly and KEY:lower() == 'e' then
			CONTROL.Q = (vfly and flags.vflyspeed.value or flyspeed)*2
		elseif QEfly and KEY:lower() == 'q' then
			CONTROL.E = -(vfly and flags.vflyspeed.value or flyspeed)*2
		end
		pcall(function() CurrentCamera.CameraType = Enum.CameraType.Track end)
	end)
	flyKeyUp = Mouse.KeyUp:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = 0
		elseif KEY:lower() == 's' then
			CONTROL.B = 0
		elseif KEY:lower() == 'a' then
			CONTROL.L = 0
		elseif KEY:lower() == 'd' then
			CONTROL.R = 0
		elseif KEY:lower() == 'e' then
			CONTROL.Q = 0
		elseif KEY:lower() == 'q' then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function spawnFLY(collection)
    wait(1)
    if collection.Name == LocalPlayer.Character.Name then
        local car = collection:WaitForChild("Car")
        sFLY(true)
    end
end

function NOFLY()
	flags.flying(false)
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

function hover()
    local car = getCar()
    if not car then return end
    local root = car.PrimaryPart
    
    local mass = 0
    for i,v in pairs(car:GetDescendants()) do
        if v:IsA("BasePart") then
            mass = mass + (v:GetMass() * workspace.Gravity)
        end
    end
    
    local bodyPosition = Instance.new("BodyPosition", root)
    local bodyGyro = Instance.new("BodyGyro", root)
    
    height = 10
    FLOOR_CHECK	= 10
    floor= Vector3.new(0, 5, 0)
    
    while RunService.Stepped:wait() do
    	local floorRay	= Ray.new(root.Position, -floor.Unit * FLOOR_CHECK)
        local hit, position, normal	= Workspace:FindPartOnRayWithIgnoreList(floorRay, {car})
    	if hit then
    		bodyPosition.MaxForce = Vector3.new(mass / 5, math.huge, mass / 5)
    		bodyPosition.Position = (CFrame.new(position, position + normal) * CFrame.new(0, 0, -height + 0.5)).p
    		bodyGyro.MaxTorque = Vector3.new(math.huge, 0, math.huge)
    		bodyGyro.CFrame = CFrame.new(position, position + normal) * CFrame.Angles(-math.pi/2, 0, 0)
    	end
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
    task.spawn(function()
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

task.spawn(function()
    while wait() do
        if flags.autofarm.value then
            local bestCar = getbestCar()
            local car = getCar()
            if not car then
                rE.SaveCustoms:FireServer({
	                ["BodyPaint"] = {
		                ["Paint"] = {
			                ["Material"] = flags.bodypaint.value
		                }
	                },
	                ["Scraps"] = 100000
                }, bestCar)
                wait()
                repeat 
                    pcall(function() rF.SpawnVehicle:InvokeServer(bestCar) end)
                    car = getCar()
                    wait() 
                until car ~= false or not flags.autofarm.value
            end
            wait(1)
            if not flags.autofarm.value then return end
            if flags.silent.value then car:SetPrimaryPartCFrame(CFrame.new(5999, 6, 2860)) end
            destroyCar()
            wait(5)
            rE.Delete:FireServer()
        end
    end
end)

local AccDir = 0
RunService.Stepped:Connect(function()
    local car = getCar()
    if car then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position.Y < -100 then
            rF.TeleportPlr:InvokeServer("LobbySpawn")
        end
        if AccDir == 1 and flags.carspeed.value ~= 0 then
            car.PrimaryPart.Velocity = CFrame.new(car.PrimaryPart.Velocity):Lerp(CFrame.new(-car.PrimaryPart.CFrame.lookVector*car.Parent.Speed.Value*(flags.carspeed.value)), 0.001).Position
        end
    end
end)

task.spawn(function()
    while wait(.1) do
        local car = getCar()
        if car then
            if flags.tankaura.value then
                local closestCar = getClosestCar(flags.tankaurarange.value)
                if closestCar then
                    for _,part in pairs(closestCar.Car.Body.HitBoxes:GetChildren()) do
                        if part:IsA("BasePart") then
                            task.spawn(function() 
                                for i = 1,3 do
                                    rF.TankInvoke:InvokeServer("Fire", Vector3.new(0,0,0), part) 
                                end
                            end)
                        end
                    end
                end
            end
            if flags.crashaura.value then
                local closestCar = getClosestCar(flags.crashaurarange.value)
                if closestCar then
                    for _,part in pairs(car.Body.HitBoxes:GetChildren()) do
                        if part:IsA("BasePart") then
                            task.spawn(function() rE.DamageVehicle:FireServer(part or car.Body.HitBoxes:FindFirstChild("Back"), CFrame.new(0,0,0), closestCar, car.PrimaryPart.Velocity.Magnitude) end)
                        end
                    end
                end
            end
        end
    end
end)

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local args = {...} 
    if not checkcaller() then 
        if Self.Name == "BreakParts" and flags.invincible.value then return end
        if Self.Name == "VehicleInfo" and args[1] == "AccDir" then AccDir = args[2] end
    end
    return OldNamecall(Self, unpack(args))
end)

--=======\UI\
local window = library:CreateWindow("Car Crushers 2", Vector2.new(450,330), Enum.KeyCode.RightShift)
    local afTab = window:CreateTab("Autofarm")
        local infoSec = afTab:CreateSector("Info", 'left')
            local bestcarstring = "Best Car: "
            bestcar_label = infoSec:AddLabel(bestcarstring)
            task.spawn(function()
                while wait() do
                    local bestCar = getbestCar(true)
                    bestcar_label:Set(bestcarstring..bestCar)
                end
            end)

            local moneystring = "Money Earned: "
            moneymade_label = infoSec:AddLabel(moneystring.. "0")
            task.spawn(function()
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
            task.spawn(function()
                local partsmade = 0
                while true do
                    local parts = LocalPlayer.Parts
                    local oldvalue = parts.Value
                    local value = parts.Changed:Wait()
                    partsmade = math.round(partsmade + (value - oldvalue))
                    partsmade_label:Set(partsstring..partsmade)
                end
            end)
            
        local afSec = afTab:CreateSector("Vehicle Autofarm", "right")
            af_toggle = afSec:AddToggle("ON/OFF", flags.autofarm.value, flags.autofarm)
            silent_toggle = afSec:AddToggle("Silent", flags.silent.value, flags.silent)
            paint_dropdown = afSec:AddDropdown("Body Paint", {"Neon", "Silver", "Gold", "Platinum"}, "You must own it", flags.bodypaint)
            
        local amiscSec = afTab:CreateSector("Misc", 'left')
            local escapeCon
            ae_toggle = amiscSec:AddToggle("Auto Escape/Helicopter", false, function(bool) 
                if bool then 
                    local heli = HelicopterContainer:FindFirstChild("Helicopter")
                    if heli then escape(heli) end 
                    escapeCon = HelicopterContainer.ChildAdded:Connect(escape) 
                else 
                    if escapeCon then escapeCon:Disconnect() end 
                end
            end)
    
    
    local vTab = window:CreateTab("Vehicle")
        local flySec = vTab:CreateSector("Fly", 'left'); local flyCon
            vfly_toggle = flySec:AddToggle("ON/OFF", flags.invincible.value, function(b) 
                if flyCon then flyCon:Disconnect() end
                if b then
                    flyCon = CarCollection.ChildAdded:Connect(spawnFLY)
                    sFLY(true)
                else
                    NOFLY()
                end
            end)
            vfly_toggle:AddKeybind()
            vflyspeed_slider = flySec:AddSlider("Speed", 1, flags.vflyspeed.value, 100, 1, flags.vflyspeed)
            
        local speedSec = vTab:CreateSector("Speed", 'right')
            carspeed_slider = speedSec:AddSlider("Amount", 0, flags.carspeed.value, 50, 1, flags.carspeed)
            
        local boostSec = vTab:CreateSector("Boost", 'left')
            boost_keybind = boostSec:AddKeybind("Boost Key",Enum.KeyCode.C, nil, boost)
            boostspeed_slider = boostSec:AddSlider("Amount", 1, flags.boostspeed.value, 200, 1, flags.boostspeed)
            
        local jumpSec = vTab:CreateSector("Jump", 'right')
            jump_toggle = jumpSec:AddToggle("ON/OFF", flags.jump.value, flags.jump)
            jump_keybind = jumpSec:AddKeybind("Jump Key",Enum.KeyCode.G, nil, jump)
            jumppower_slider = jumpSec:AddSlider("Amount", 0, flags.jumppower.value, 50, 1, flags.jumppower)
            
        local miscSec = vTab:CreateSector("Misc", 'left')
            invincible_toggle = miscSec:AddToggle("No Damage", flags.invincible.value, flags.invincible)
            spawn_button = miscSec:AddButton("Spawn Car", spawnCar)
            bring_button = miscSec:AddButton("Bring Car", bringCar)
            destroy_button = miscSec:AddButton("Destroy Car", destroyCar)
            
        local pvpSec = vTab:CreateSector("PVP", 'right')
            ca_toggle = pvpSec:AddToggle("Crash Aura", flags.crashaura.value, flags.crashaura)
            carange_slider = pvpSec:AddSlider("Range", 1, flags.crashaurarange.value, 1000, 1, flags.crashaurarange)
            ta_toggle = pvpSec:AddToggle("Tank Aura", flags.tankaura.value, flags.tankaura)
            tarange_slider = pvpSec:AddSlider("Range", 1, flags.tankaurarange.value, 1000, 1, flags.tankaurarange)
            tankcrash_button = pvpSec:AddButton("Kill All (Tank Only)", tankCrash)
            
    local miscTab = window:CreateTab("Misc")
        local teleSec = miscTab:CreateSector("Teleports", "right")
            tpspawn_button = teleSec:AddButton("Spawn", function() rF.TeleportPlr:InvokeServer("LobbySpawn") end)
            if workspace:FindFirstChild("Crusher Parts") then
                local teleports = {}
                local tpNames = {}
                for _,v in pairs(workspace["Crusher Parts"]:GetChildren()) do
                    teleports[v.Name] = v.Entrance:FindFirstChildOfClass("Part")
                    table.insert(tpNames, v.Name)
                end
                tp_dropdown = teleSec:AddDropdown("Crushers", tpNames, "Select", function(c) 
                    local entrance = getClosestEntrance(teleports[c])
                    if not entrance then return err("no entrance?") end
                    TP(entrance.Position)
                end)
            end
            teleSec:AddLabel("― Settings")
            tweentp_toggle = teleSec:AddToggle("Tween", flags.tweentp.value, flags.tweentp)
            tweenspeed_slider = teleSec:AddSlider("Tween Speed", 1, flags.tweenspeed.value, 1000, 1, flags.tweenspeed)
            
        local charSec = miscTab:CreateSector("Character", "right")
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
            
        local serverSector = miscTab:CreateSector("Servers", 'left')
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


        local discSector = miscTab:CreateSector("Discord", 'left')
            joindisc_button = discSector:AddButton("Direct Join", joindiscord)
            copydisc_button = discSector:AddButton("Copy to Clipboard", function() if setclipboard then setclipboard('https://discord.gg/DnyxZRwQh3') else print("DnyxZRwQh3") end end)
                
        local changeSector = miscTab:CreateSector("Changelogs", 'left')
            changeSector:AddLabel("• Crash Aura")
            changeSector:AddLabel("• Tank Aura")         
            changeSector:AddLabel("• Tank Kill All")
        
    
