--[Variables]
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local sethiddenprop = (sethiddenproperty or set_hidden_property or sethiddenprop or set_hidden_prop);
local setsimulationrad = setsimulationradius or set_simulation_radius or function(Radius) sethiddenprop(PlayerInstance, "SimulationRadius", Radius) end

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:FindFirstChildOfClass("Humanoid")
local CurrentCamera = workspace.CurrentCamera
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/UI-Libraries/main/NotificationLib.lua"))()
local oldGravity = workspace.Gravity

local R15 = Humanoid.RigType == Enum.HumanoidRigType.R15 and true or false

if AUTOCHOOSE then
    for _, hat in pairs(Character:GetChildren()) do
        if hat:IsA("Accessory") and (string.find(hat.Name:lower(), "skateboard") or hat.Name == "MeshPartAccessory") then
            SKATEBOARD_HAT = hat.Name
        end
    end
end
SKATEBOARD_HAT = Character:FindFirstChild(SKATEBOARD_HAT)
if not SKATEBOARD_HAT then 
    return Notification.WallNotification("Oops", "Skateboard hat not found!")
end
SKATEBOARD_HAT.Handle.AccessoryWeld:Destroy()

local BP = SKATEBOARD_HAT:FindFirstChildOfClass("BodyPosition") or Instance.new("BodyPosition", SKATEBOARD_HAT)
BP.MaxForce = Vector3.new(9e9,9e9,9e9)
BP.P = 9e9

settings().Physics.AllowSleep = false
settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
RunService.Stepped:Connect(function() --old net
    sethiddenprop(LocalPlayer, "MaximumSimulationRadius", math.huge)
    sethiddenprop(LocalPlayer, "SimulationRadius", math.huge)
    setsimulationrad(math.huge)
end)

local velocityCon
velocityCon = RunService.Heartbeat:connect(function()
    if not SKATEBOARD_HAT or not SKATEBOARD_HAT:FindFirstChild("Handle") then disconnect(velocityCon) else
        SKATEBOARD_HAT.Handle.AssemblyLinearVelocity = Vector3.new(1.00049, -32.4221, 1.00049)
    end
end)

--[functions]
function disconnect(...)
    local connections = {...}
    for i,con in pairs(connections) do
        if con ~= nil then con:Disconnect() end
    end
end

function Lerp(a, b, t)
    return a + (b - a) * t
end

function GetMassOfModel(model)
    local mass = 0
    for i, v in pairs(model:GetDescendants()) do
        if v:IsA('BasePart') or v:IsA('Union') then
            mass = mass + v:GetMass()
        end
    end
    return mass
end

local function align(a, b, pos, rot, resp)
    local a1
    local att0 =  a:IsA("Accessory") and Instance.new("Attachment", a.Handle) or Instance.new("Attachment", a);
    local att1 = Instance.new("Attachment", b);
    att1.Position = pos or Vector3.new(0,0,0); att1.Orientation = rot or Vector3.new(0,0,0);

    local Handle = a:IsA("Accessory") and a.Handle or a;
    Handle.Massless = true;
    Handle.CanCollide = false;

    if a:IsA("Accessory") then Handle.AccessoryWeld:Destroy() end

    al = Instance.new("AlignPosition", Handle);
    al.Attachment0 = att0; al.Attachment1 = att1;
    al.RigidityEnabled = true;
    al.ReactionForceEnabled = false;
    al.ApplyAtCenterOfMass = true;
    al.MaxForce = 10000000;
    al.MaxVelocity = math.huge/9e110;
    al.Responsiveness = resp or 200;

    local ao = Instance.new("AlignOrientation", Handle);
    ao.Attachment0 = att0; ao.Attachment1 = att1;
    ao.RigidityEnabled = false;
    ao.ReactionTorqueEnabled = true;
    ao.PrimaryAxisOnly = false;
    ao.MaxTorque = 10000000;
    ao.MaxAngularVelocity = math.huge/9e110;
    ao.Responsiveness = 200;
    return att1, a1
end

function Motor6D(part0, part1, c0, c1, name)
    part1.Massless = true
    local motor = Instance.new("Motor6D", part1); motor.Name = name or "Motor6D"; motor.Part0 = part0; motor.Part1 = part1; motor.C0 = c0 or CFrame.new(0,0,0); motor.C1 = c1 or CFrame.new(0,0,0);
    return motor, motor.C0
end

function SetTween(SPart,CFr,MoveStyle2,outorin2,AnimTime)
    local MoveStyle = Enum.EasingStyle[MoveStyle2]
    local outorin = Enum.EasingDirection[outorin2]

    local dahspeed=1

    local tweeningInformation = TweenInfo.new(
    	AnimTime/dahspeed,	
    	MoveStyle,
    	outorin,
    	0,
    	false,
    	0
    )
    local MoveCF = CFr
    local tweenanim = TweenService:Create(SPart,tweeningInformation,MoveCF)
    tweenanim:Play()
end

--[Animations]
if workspace:FindFirstChild("Animations") then workspace.Animations:Destroy() end
Anims = game:GetObjects("rbxassetid://7260697029")[1]; Anims.Parent = workspace
R6Anims = Anims:WaitForChild("R6")	
R15Anims = Anims:WaitForChild("R15")

Animations = {
	R6 = {
		BoardKick = R6Anims:WaitForChild("BoardKick"),
		CoastingPose = R6Anims:WaitForChild("CoastingPose"),
		LeftTurn = R6Anims:WaitForChild("LeftTurn"),
		RightTurn = R6Anims:WaitForChild("RightTurn"),
		Ollie = R6Anims:WaitForChild("Ollie")
	},
	R15 = {
		BoardKick = R15Anims:WaitForChild("BoardKick"),
		CoastingPose = R15Anims:WaitForChild("CoastingPose"),
		LeftTurn = R15Anims:WaitForChild("LeftTurn"),
		RightTurn = R15Anims:WaitForChild("RightTurn"),
		Ollie = R15Anims:WaitForChild("Ollie")
	}
}

ActiveAnimations = {}

function GetAnimation(AnimName)
	if not Humanoid then
		return
	end
	local RigType = Humanoid.RigType
	if RigType == Enum.HumanoidRigType.R15 then
		return Animations["R15"][AnimName]
	else
		return Animations["R6"][AnimName]
	end
end

function SetAnimation(Mode, Value)
	if Mode == "Play" then
		for i, v in pairs(ActiveAnimations) do
			if v.Animation == Value.Animation then
				v.AnimationTrack:Stop()
				table.remove(ActiveAnimations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(Value.Animation)
		table.insert(ActiveAnimations, {Animation = Value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(Value.FadeTime, Value.Weight, Value.Speed)
	elseif Mode == "Stop" and Value then
		for i, v in pairs(ActiveAnimations) do
			if v.Animation == Value.Animation then
				v.AnimationTrack:Stop(Value.FadeTime)
				table.remove(ActiveAnimations, i)
			end
		end
	end
end

--[skateboard]
function createTool()
    local alignCon
    
    local fakeHat = SKATEBOARD_HAT:Clone()
    fakeHat.Parent = Character
    fakeHat.Handle.Transparency = 1
    
    local tool = Instance.new("Tool", LocalPlayer.Backpack)
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    tool.Name = "Skateboard"

    local handle = Instance.new("Part", tool)
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Massless = true
    handle.Transparency = 1

    local positions = {
        forward = tool.GripForward,
        pos = tool.GripPos,
        right = tool.GripRight,
        up = tool.GripUp
    }
    
    local hold = false
    tool.Equipped:connect(function()
        hold = true
    end)
    
    tool.Unequipped:connect(function()
       hold = false
    end)
    
    tool.Activated:connect(function()
        disconnect(alignCon)
        dropBoard()
        tool:Destroy()
    end)
    
    local torso = R15 and Character['UpperTorso'] or Character["Torso"]
    alignCon = game:GetService("RunService").Heartbeat:connect(function()
        if not SKATEBOARD_HAT or not SKATEBOARD_HAT:FindFirstChild("Handle") or not BP then disconnect(alignCon) end
        if hold then
            BP.Position = handle.Position
            SKATEBOARD_HAT.Handle.CFrame = handle.CFrame
        else
            BP.Position = (torso.CFrame * CFrame.new(torso.Size.Z,-.2,0)).Position
            SKATEBOARD_HAT.Handle.CFrame = (torso.CFrame * CFrame.new(torso.Size.Z,-.2,0)) * HOLD_OFFSET
        end
    end)
end

function dropBoard()
    local alignCon, controlCon, touchedCon, noclipCon
    
    local BOARD, FORCE, BG, BV, fakeChar, SKATEMODEL = Instance.new("Part", workspace), Instance.new("VectorForce") do
        SKATEMODEL = Instance.new("Model", workspace); SKATEMODEL.Name = "Skateboard"
        
        BOARD.Name = "Platform"
        BOARD.Transparency = 1
        BOARD.RootPriority = 12
        BOARD.Parent = SKATEMODEL
        BOARD.Size = Vector3.new(1.5, 0.13, 5)
        BOARD.Anchored = false
        BOARD.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-6)
        BOARD.CustomPhysicalProperties = PhysicalProperties.new(100, GRIP, 0, 10, 10)

        local frontl = Instance.new("Part", SKATEMODEL)
        frontl.Transparency = 1
        --frontl.Shape = "Cylinder"
        frontl.Massless = true
        frontl.Size = Vector3.new(0.4, 0.4, 0.4)
        frontl.CustomPhysicalProperties = PhysicalProperties.new(0.2, GRIP, 0, 10, 10)
        Motor6D(frontl, BOARD, CFrame.new(.6,.2,1.1))

        local frontr = Instance.new("Part", SKATEMODEL)
        frontr.Transparency = 1
        --frontr.Shape = "Cylinder"
        frontr.Massless = true
        frontr.Size = Vector3.new(0.4, 0.4, 0.4)
        frontr.CustomPhysicalProperties = PhysicalProperties.new(0.2, GRIP, 0, 10, 10)
        Motor6D(frontr, BOARD, CFrame.new(-.6,.2,1.1))

        local backl = Instance.new("Part", SKATEMODEL)
        backl.Transparency = 1
        --backl.Shape = "Cylinder"
        backl.Massless = true
        backl.Size = Vector3.new(0.4, 0.4, 0.4)
        backl.CustomPhysicalProperties = PhysicalProperties.new(0.2, GRIP, 0, 10, 10)
        Motor6D(backl, BOARD, CFrame.new(.6,.2,-1.1))

        local backr = Instance.new("Part", SKATEMODEL)
        backr.Transparency = 1
        --backr.Shape = "Cylinder"
        backr.Massless = true
        backr.Size = Vector3.new(0.4, 0.4, 0.4)
        backr.CustomPhysicalProperties = PhysicalProperties.new(0.2, GRIP, 0, 10, 10)
        Motor6D(backr, BOARD, CFrame.new(-.6,.2,-1.1))
        local Center = Instance.new("Attachment", BOARD)
        FORCE.Parent = BOARD
        FORCE.Attachment0 = Center
        FORCE.ApplyAtCenterOfMass = true
        FORCE.RelativeTo = Enum.ActuatorRelativeTo.World
        FORCE.Enabled = false
        
        Character.Archivable = true
        fakeChar = Character:Clone()
        fakeChar.Parent = SKATEMODEL
        fakeChar.Humanoid.PlatformStand = true
        fakeChar.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame + Vector3.new(100,100,0)
        fakeChar.HumanoidRootPart.Anchored = true
        for i, v in pairs(fakeChar:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 1
                v.Massless = true 
                v.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
            end
            if v:IsA("Decal") then
               v:Destroy()
            end
            if v:IsA("SpecialMesh") then
               v.MeshId = "rbxassetid://0" 
            end
            if v:IsA("ForceField") then
               v:Destroy()
            end
        end
    end

    local trickdb = false
    local trickCF = CFrame.new()
    alignCon = RunService.Heartbeat:connect(function()
        if not SKATEBOARD_HAT or not SKATEBOARD_HAT:FindFirstChild("Handle") then alignCon:Disconnect() else 
            SKATEBOARD_HAT.Handle.CFrame = (BOARD.CFrame * OFFSET) * trickCF
            BP.Position = BOARD.Position
        end
    end)
    
    local MASS			= GetMassOfModel(SKATEMODEL)
    local FLOOR_CHECK	= 10
    local HEIGHT		= 3

    local floor				= Vector3.new(0, .5, 0)
    local targetVelocity	= Vector3.new()
    local targetRotation    = Vector3.new()
    local grounded			= false
    
    local rideCF            = (BOARD.CFrame * CFrame.new(0,3,0)) * CFrame.Angles(0,math.rad(-90),0)
    
    local rot = 90
    local pos = 0
    
    local pushing = false
    local pushed = 1
    
    function rideBoard(deltaTime)
        if not Character or not BOARD or not SKATEBOARD_HAT or not SKATEBOARD_HAT:FindFirstChild("Handle") then RunService:UnbindFromRenderStep("Control") end
        workspace.Gravity = 96
        CurrentCamera.CameraSubject = fakeChar
        Character.Humanoid.PlatformStand = true
        Character.HumanoidRootPart.CFrame = rideCF--(BOARD.CFrame * CFrame.new(0,3,0)) * CFrame.Angles(0,math.rad(-90),0)

        local floorRay				= Ray.new(BOARD.Position, -floor.Unit * FLOOR_CHECK)
        local hit, position, normal	= Workspace:FindPartOnRayWithIgnoreList(floorRay, {BOARD, Character})
        local floorDistance			= (position - BOARD.Position).Magnitude
        
        if floorDistance <= HEIGHT then
            grounded = true
        else
            grounded = false
        end

        if hit then
            if grounded then
                floor = normal
            else
                floor = floor:Lerp(normal, math.min(deltaTime * 5, 1))
            end
        else
            floor = floor:Lerp(Vector3.new(0, 1, 0), math.min(deltaTime, 1))
        end

        local lookVector	= BOARD.CFrame.lookVector
        lookVector			= Vector3.new(lookVector.X, 0, lookVector.Z).Unit
        local floorCFrame	= CFrame.new(Vector3.new(), lookVector)
        local localFloor	= floorCFrame:vectorToObjectSpace(floor)

        local x, y	= math.atan2(-localFloor.X, localFloor.Y), math.atan2(localFloor.Z, localFloor.Y)
        local cfA	= CFrame.Angles(y, 0, 0) * CFrame.Angles(0, 0, x)
        local cfB	= CFrame.Angles(0, 0, x) * CFrame.Angles(y, 0, 0)

        floorCFrame	= floorCFrame * cfA:Lerp(cfB, 0.5)

        if not UserInputService:GetFocusedTextBox() then
            local input	= Vector3.new()

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                input= input + Vector3.new(0, 0, -1)
                if pushing == false then
                    pushing = true; pushed = tick()
                    SetAnimation("Play", {Animation = GetAnimation("BoardKick"), FadeTime = 0.5, Speed = 1.1, Weight = 2,})
		            SetAnimation("Stop", {Animation = GetAnimation("LeftTurn"), FadeTime = 0.5})
		            SetAnimation("Stop", {Animation = GetAnimation("RightTurn"), FadeTime = 0.5})
		        elseif not R15 and  tick() - pushed > 0.6 then
                    pushing = "Pause"
                    SetAnimation("Stop", {Animation = GetAnimation("BoardKick"), FadeTime = 0.5})
                end
            else
                SetAnimation("Stop", {Animation = GetAnimation("BoardKick"), FadeTime = 0.5})
                pushing = false
            end
            --print(tick()-pushed > 1)
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                if R15 then pushing = "Pause" end
                SetAnimation("Stop", {Animation = GetAnimation("BoardKick")})
		        SetAnimation("Stop", {Animation = GetAnimation("Ollie")})
		        SetAnimation("Stop", {Animation = GetAnimation("RightTurn"), FadeTime = 0.5})
		        SetAnimation("Play", {Animation = GetAnimation("LeftTurn"), FadeTime = 0.5})
                input	= input + Vector3.new(-STEERABILITY, 0, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                if R15 then pushing = "Pause" end
                SetAnimation("Stop", {Animation = GetAnimation("BoardKick")})
		        SetAnimation("Stop", {Animation = GetAnimation("LeftTurn"), FadeTime = 0.5})
		        SetAnimation("Stop", {Animation = GetAnimation("Ollie")})
		        SetAnimation("Play", {Animation = GetAnimation("RightTurn"), FadeTime = 0.5})
                input	= input + Vector3.new(STEERABILITY, 0, 0)
            end
            
            targetRotation = input.Magnitude > 0  and (BOARD.CFrame * CFrame.new(input)).Position or (BOARD.CFrame * CFrame.new(Vector3.new(0,0,-1).Unit)).Position
            targetVelocity = math.abs(input.Z) > 0 and floorCFrame:vectorToWorldSpace(Vector3.new(0,0,-1).Unit * SPEED) or floorCFrame:vectorToWorldSpace(Vector3.new(0,0,0) * SPEED)
        end
        
        if pushing == true then
            rot = Lerp(rot, 0, 0.05)
            pos = Lerp(pos, 1.2, 0.02)
            rideCF = BOARD.CFrame * CFrame.new(R15 and 0 or pos,3,0) * CFrame.Angles(0,math.rad(rot),0)
        else
            rot = Lerp(rot, -90, 0.05)
            pos = Lerp(pos, 0, 0.1)
            rideCF = BOARD.CFrame * CFrame.new(R15 and 0 or pos,3,0) * CFrame.Angles(0,math.rad(rot),0)
        end
        --rideCF = R15 and targetVelocity.Magnitude <= 0 and Character.HumanoidRootPart.CFrame:Lerp(BOARD.CFrame * CFrame.new(0,3,0), .5) or Character.HumanoidRootPart.CFrame:Lerp((BOARD.CFrame * CFrame.new(0,3,0)) * CFrame.Angles(0,math.rad(-90),0), 0.5)
            
        if grounded then
            BG.MaxTorque = Vector3.new(0,20,0)
            FORCE.Force	= (targetVelocity - BOARD.Velocity) * MASS * ACCELERATION

            position = targetRotation--BOARD.Position + CurrentCamera.CFrame.LookVector
            BG.CFrame = CFrame.lookAt(BOARD.Position, Vector3.new(position.X, BOARD.Position.Y, position.Z)) * CFrame.new(1, 0, 1)
        else
            BG.MaxTorque = Vector3.new(200,20,200)
            FORCE.Force	= Vector3.new()
        end
    end
    
    function controls(inputObject, processed)
        if not processed then
            if inputObject.KeyCode == Enum.KeyCode.Space then
                if grounded then
                    if not R15 then pushing = "Pause" end
                    SetAnimation("Stop", {Animation = GetAnimation("BoardKick")})
                    SetAnimation("Stop", {Animation = GetAnimation("LeftTurn"), FadeTime = 0.5})
                    SetAnimation("Stop", {Animation = GetAnimation("RightTurn"), FadeTime = 0.5})
                    SetAnimation("Play", {Animation = GetAnimation("Ollie"), FadeTime = 0, Weight = 1, Speed = 4})
                    BOARD.Velocity = BOARD.Velocity + floor * JUMP
                end
            elseif inputObject.KeyCode == Enum.KeyCode.Z then
                for i = 1, 7 do
                    BG.MaxTorque = Vector3.new(3000,3000,3000)
                    BG.cframe = BG.cframe * CFrame.fromEulerAnglesXYZ(0, math.pi / 7, 0)
                    wait()
                end
            elseif inputObject.KeyCode == Enum.KeyCode.X then
                for i = 1, 7 do
                    BG.MaxTorque = Vector3.new(3000,3000,3000)
                    BG.cframe = BG.cframe * CFrame.fromEulerAnglesXYZ(0, math.pi / -7, 0)
                    wait()
                end
            elseif inputObject.KeyCode == Enum.KeyCode.C then
                for i = 1, 4 do
                    BG.MaxTorque = Vector3.new(3000,3000,3000)
                    BG.cframe = BG.cframe * CFrame.fromEulerAnglesXYZ(math.pi / 20, 0, 0)
                    wait()
                end
            elseif inputObject.KeyCode == Enum.KeyCode.V then
                for i = 1, 4 do
                    BG.MaxTorque = Vector3.new(3000,3000,3000)
                    BG.cframe = BG.cframe * CFrame.fromEulerAnglesXYZ(math.pi / -20, 0, 0)
                    wait()
                end
                wait()
            elseif inputObject.KeyCode == Enum.KeyCode.Q and not grounded then
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(30), math.rad(-25), math.rad(-50))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(40), math.rad(-50), math.rad(-100))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(20), math.rad(-75), math.rad(-150))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(15), math.rad(-100), math.rad(-200))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(10), math.rad(-125), math.rad(-250))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(5), math.rad(-150), math.rad(-300))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, math.rad(-175), math.rad(-350))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, 0, 0)
            elseif inputObject.KeyCode == Enum.KeyCode.E and not grounded then
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(30), math.rad(25), math.rad(50))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(40), math.rad(50), math.rad(100))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(20), math.rad(75), math.rad(150))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(15), math.rad(100), math.rad(200))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(10), math.rad(125), math.rad(250))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(5), math.rad(150), math.rad(300))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, math.rad(175), math.rad(350))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, 0, 0)
            elseif inputObject.KeyCode == Enum.KeyCode.F and not grounded then
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(30), 0, 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(40), 0, math.rad(-50))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(20), 0, math.rad(-100))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(15), 0, math.rad(-150))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(10), 0, math.rad(-200))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(5), 0, math.rad(-250))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(-300))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(-350))
                wait(0.0125)
                trickCF = CFrame.new()
            elseif inputObject.KeyCode == Enum.KeyCode.G and not grounded then
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(30), 0, 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(40), 0, math.rad(50))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(20), 0, math.rad(100))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(15), 0, math.rad(150))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(10), 0, math.rad(200))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(5), 0, math.rad(250))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(300))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(350))
            elseif inputObject.KeyCode == Enum.KeyCode.R and not grounded then
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(30), math.rad(25), 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(40), math.rad(50), 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(20), math.rad(75), 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(15), math.rad(100), 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(10), math.rad(125), 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(5), math.rad(150), 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, math.rad(175), 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, 0, 0)
            elseif inputObject.KeyCode == Enum.KeyCode.Y and not grounded then
                SetAnimation("Play", {Animation = GetAnimation("BoardKick"), Speed = 4})
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(30), math.rad(50), math.rad(50))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(35), math.rad(75), math.rad(75))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(40), math.rad(100), math.rad(100))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(30), math.rad(-125), math.rad(-125))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(20), math.rad(150), math.rad(150))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(17.5), math.rad(175), math.rad(175))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(15), math.rad(200), math.rad(200))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(15), math.rad(225), math.rad(225))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(10), math.rad(250), math.rad(250))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(5), math.rad(300), math.rad(300))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, math.rad(350), math.rad(350))
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(0, 0, 0)
            elseif inputObject.KeyCode == Enum.KeyCode.T and not grounded then
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(40), 0, 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(50), 0, 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(100), 0, 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(150), 0, 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(200), 0, 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(250), 0, 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(300), 0, 0)
                wait(0.0125)
                trickCF = CFrame.new(0, 0.2, 0) * CFrame.fromEulerAnglesXYZ(math.rad(350), 0, 0)
            elseif inputObject.KeyCode == Enum.KeyCode.H and not grounded then
                SetAnimation("Play", {Animation = GetAnimation("BoardKick"), Speed = 4})
                trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(30),0,0)
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(50),0,math.rad(-50))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.3,0) * CFrame.fromEulerAnglesXYZ(math.rad(75),0,math.rad(-75))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.4,0) * CFrame.fromEulerAnglesXYZ(math.rad(100),0,math.rad(-100))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.6,0) * CFrame.fromEulerAnglesXYZ(math.rad(150),0,math.rad(-150))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.7,0) * CFrame.fromEulerAnglesXYZ(math.rad(175),0,math.rad(-175))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.8,0) * CFrame.fromEulerAnglesXYZ(math.rad(200),0,math.rad(-200))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(10),0,0)
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(0,0,0)
            elseif inputObject.KeyCode == Enum.KeyCode.B and not grounded then
                trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(30),math.rad(-50),math.rad(-50))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(35),math.rad(-75),math.rad(-75))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(40),math.rad(-100),math.rad(-100))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(30),math.rad(-125),math.rad(-125))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(20),math.rad(-150),math.rad(-150))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(17.5),math.rad(-175),math.rad(-175))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(15),math.rad(-200),math.rad(-200))
		        wait(0.0125)
		        trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(15),math.rad(-225),math.rad(-225))
		        wait(0.0125)
	        	trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(10),math.rad(-250),math.rad(-250))
	        	wait(0.0125)
	        	trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(math.rad(5),math.rad(-300),math.rad(-300))
	        	wait(0.0125)
	        	trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(0,math.rad(-350),math.rad(-350))
	        	wait(0.0125)
	        	trickCF = CFrame.new(0,0.2,0) * CFrame.fromEulerAnglesXYZ(0,0,0)
            elseif inputObject.KeyCode == Enum.KeyCode.J then
                BG.P = 100000
                BG.MaxTorque = Vector3.new(100000,20,100000)
                wait(1)
                BG.P = 3000
                BG.MaxTorque = Vector3.new(200,20,200)
            elseif inputObject.KeyCode == Enum.KeyCode.Backspace then
                CurrentCamera.CameraSubject = Character
                
                workspace.Gravity = oldGravity
                Character.Humanoid.PlatformStand = false
                BV:Destroy()
                SKATEMODEL:Destroy()
        
                SetAnimation("Stop", {Animation = GetAnimation("BoardKick")})
                SetAnimation("Stop", {Animation = GetAnimation("LeftTurn"), FadeTime = 0.5})
                SetAnimation("Stop", {Animation = GetAnimation("Ollie")})
                SetAnimation("Stop", {Animation = GetAnimation("RightTurn"), FadeTime = 0.5})
                SetAnimation("Stop", {Animation = GetAnimation("CoastingPose")})

                RunService:UnbindFromRenderStep("Control")
                createTool()
                disconnect(controlCon, alignCon, noclipCon)
                wait()
                Humanoid.Jump = true
            end
        end
    end
    
    touchedCon = BOARD.Touched:Connect(function(part)
        if part.Parent:FindFirstChildOfClass("Humanoid") and Players:GetPlayerFromCharacter(part.Parent) == LocalPlayer then
            
            BG = Instance.new("BodyGyro", BOARD)
            BG.MaxTorque = Vector3.new(50,20000,50)
            BG.P = 3000
            
            BV = Instance.new("BodyVelocity", R15 and Character["LeftFoot"] or Character["Left Arm"])
            BV.Velocity = Vector3.new(0,0,0)
            BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            BV.P = 9000
        
            fakeChar.HumanoidRootPart.Anchored = false
            
            Motor6D(BOARD, R15 and fakeChar["UpperTorso"] or fakeChar.Torso, CFrame.new(), CFrame.new(0,-3.3,0) * CFrame.Angles(0,math.rad(90),0))
            
            SetAnimation("Play", {Animation = GetAnimation("CoastingPose")})
            
            FORCE.Enabled = true
            
            
            RunService:BindToRenderStep("Control", Enum.RenderPriority.Character.Value, rideBoard)
            
            controlCon = UserInputService.InputBegan:connect(controls)
            
            noclipCon = RunService.Stepped:Connect(function()
                for i,v in pairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide == true then
                    v.CanCollide = false
                    end
                end
            end)
            
            disconnect(touchedCon)
        end
    end)
    
    Humanoid.Died:Connect(function()
        workspace.Gravity = oldGravity
        CurrentCamera.CameraSubject = Character
        if SKATEMODEL then SKATEMODEL:Destroy() end
        RunService:UnbindFromRenderStep("Control")
        disconnect(controlCon, alignCon)
    end)
end

createTool()
