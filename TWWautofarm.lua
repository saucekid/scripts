_G.maxitems = 22 --keep around 20 or it might break
_G.walkspeed = 26 --keep around 25 or u will get teleported back

----===========================================----
local autofarm = false
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting");
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService('PathfindingService')
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService");
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera;
local Entities = game.workspace:FindFirstChild("WORKSPACE_Entities")

local LoadModule = require(ReplicatedStorage.Modules.Load);
local LoadSharedModule = require(ReplicatedStorage.SharedModules.Load);
local Global = require(game:GetService("ReplicatedStorage").SharedModules.Global);
local AnimalModule, BreakableGlassModule, CameraModule, ClientProjectiles, GunItemModule, NetworkModule, PlayerCharacterModule, SharedUtilsModule, UtilsModule, PlayerDataModule, UIHandlerModule, SharedUtilsModule, HorseShopModule; do
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
    SharedUtilsModule= LoadSharedModule("SharedUtils");
    UIHandlerModule = LoadModule("UIHandler")
    ContainerUIModule = LoadModule("ContainerUI");
    HorseShopModule = LoadModule("HorseShop")
end

local oldLighting = {
    Ambient = Lighting.Ambient,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top
}

for i,v in pairs(workspace:GetDescendants()) do
    if string.match(v.Name, "Door") and not string.match(v.Name, "Fort") and (v:IsA("Model") or v:IsA("BasePart")) then
        v:Destroy()
    end
end

local function notify(txt, color)
    UIHandlerModule:GiveNotification({
        text = txt,
        textcolor = color,
        center = true
    });
end

function getClosestVendor()
    local target = nil
    local maxDist = math.huge
    for i,v in pairs(game:GetService("Workspace").WORKSPACE_Interactables.NPCs:GetChildren()) do
        if (string.find(v.Name, "General") or string.find(v.Name, "Store")) and not string.find(v.Name, "Outlaw") then
            TargetHRP = v.HumanoidRootPart
            local mag = (LocalPlayer.Character.HumanoidRootPart.Position - TargetHRP.Position).magnitude
            if mag < maxDist then
                maxDist = mag
                target = TargetHRP
            end
        end
    end
    return target
end
local vendorHRP = getClosestVendor()

function PathFind(pos)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, pos)
    local waypoints = path:GetWaypoints()
    for i, waypoint in ipairs(waypoints) do
        if not autofarm then return end
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):MoveTo(waypoint.Position)
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Jump = true
        end
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveToFinished:Wait()
    end
end

function Fullbright(state)
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

function startautofarm()
    local failednum = 0
    while autofarm do
        RunService.RenderStepped:Wait()
        if #PlayerDataModule:GetContainer("Inventory").Items == _G.maxitems then
            if vendorHRP then
                notify("Selling Loot", "Gold")
                PlayerCharacterModule.AnimationHandler:PlayTrack("RunDefault", 0.1, 1, 1.5)
                PathFind(vendorHRP.Position)
                PlayerCharacterModule.AnimationHandler:StopTrack("RunDefault", 0.1)
                for _,item in pairs(PlayerDataModule:GetContainer("Inventory").Items) do
                    if string.match(item.Type, "Ore") or string.match(item.Type, "Ruby") or string.match(item.Type, "Sapphire") or string.match(item.Type, "Emerald") or string.match(item.Type, "Diamond") or string.match(item.Type, "Meat") or string.match(item.Type, "Pelt") or string.match(item.Type, "Tooth") or string.match(item.Type, "Claw") or string.match(item.Type, "Skin") then
                        game:GetService("ReplicatedStorage").Communication.Events.ContainerSellItem:FireServer("Inventory", item.Id)
                    end
                end
            end
        end
        for _,ore in next, game:GetService("Workspace")["WORKSPACE_Interactables"].Mining.OreDeposits:GetDescendants() do
            if #PlayerDataModule:GetContainer("Inventory").Items ~= _G.maxitems then
                if not autofarm then return end
                if string.match(ore.Name, "Ore") and ore.Parent:FindFirstChild("DepositInfo") and ore.Parent.DepositInfo:FindFirstChild("OreRemaining") and ore.Parent.DepositInfo.OreRemaining.Value ~= 0 and LocalPlayer.Character:FindFirstChild("Head") then
                    if (LocalPlayer.Character.Head.Position-ore.Position).Magnitude < (900 - failednum) and ore.Position.Y > LocalPlayer.Character.HumanoidRootPart.Position.Y - (15 + failednum)  then
                        PlayerCharacterModule.AnimationHandler:PlayTrack("RunDefault", 0.1, 1, 1.5)
                        PathFind(ore.Position)
                        PlayerCharacterModule.AnimationHandler:StopTrack("RunDefault", 0.1)
                        repeat
                            local item = PlayerCharacterModule:GetEquippedItem()
                            if string.match(item.Name, "Pickaxe") then
                                VirtualUser:Button1Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                                item:NetworkActivate("MineDeposit", ore.Parent, ore.Position, LocalPlayer.Character.Head.Position)
                            end
                            if (LocalPlayer.Character.Head.Position-ore.Position).Magnitude < 12 then
                                failednum = 0
                            else
                                failednum = failednum - 5
                            end
                            wait(.4)
                        until ore.Parent.DepositInfo.OreRemaining.Value == 0 or (LocalPlayer.Character.Head.Position-ore.Position).Magnitude > 12 or #PlayerDataModule:GetContainer("Inventory").Items == _G.maxitems
                        VirtualUser:Button1Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                    else
                        failednum = failednum + 1
                    end
                end
            end
        end
    end
end

local GC = getconnections or get_signal_cons
if GC then
    for i,v in pairs(GC(Players.LocalPlayer.Idled)) do
        if v["Disable"] then
            v["Disable"](v)
        elseif v["Disconnect"] then
            v["Disconnect"](v)
        end
    end
end

local OldCharacterRagdoll = PlayerCharacterModule.Ragdoll;
PlayerCharacterModule.Ragdoll = function(...)
    local args = {...}
    if (autofarm) then return end;
    return OldCharacterRagdoll(...);
end

local OldFireServer = NetworkModule.FireServer;
NetworkModule.FireServer = function(self, remote, ...)
    local args = {...}
    if (autofarm and remote == "DamageSelf") then return end;
    if (autofarm and remote == "LowerStamina") then return end;
    return OldFireServer(self, remote, ...)
end

local OldSwitchToItem = PlayerCharacterModule.CanSwitchToItem
PlayerCharacterModule.CanSwitchToItem = function(...)
    if autofarm then return true end
    return OldSwitchToItem(...);
end

local OldSleep = PlayerCharacterModule.IsSleeping
PlayerCharacterModule.IsSleeping = function(...)
    if autofarm then return true end
    return OldSleep(...);
end


for i,v in next, getprotos(PlayerCharacterModule.OnCharacterAdded) do
    if table.find(getconstants(v), "Jumping")  then
        function JumpFunction()
            PlayerCharacterModule:LowerStamina(20)
            return 0
        end
        setconstant(v, 4, JumpFunction)
    end
end



local FREEZE_ACTION = "freezeMovement"
local oldhh = LocalPlayer.Character:FindFirstChildOfClass("Humanoid").HipHeight
RunService.Heartbeat:Connect(function()
    if autofarm then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = _G.walkspeed
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").HipHeight = 0.5
        ContextActionService:BindAction(
            FREEZE_ACTION,
            function()
                return Enum.ContextActionResult.Sink
            end,
            false,
            unpack(Enum.PlayerActions:GetEnumItems())
        )
    else
        ContextActionService:UnbindAction(FREEZE_ACTION)
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").HipHeight = oldhh
    end
end)


spawn(function()
    while RunService.RenderStepped:Wait() do
        if autofarm then
            for i = 0.1,1,.1 do
                Global.Network:FireServer("SetHeightPercent", i);
                RunService.RenderStepped:Wait()
            end
            for i = 1,.1,-.1 do
                Global.Network:FireServer("SetHeightPercent", i);
                RunService.RenderStepped:Wait()
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if input.KeyCode == Enum.KeyCode.L then
        if autofarm then
            PlayerCharacterModule.AnimationHandler:StopTrack("RunDefault", 0.1)
            autofarm = false
            notify("Autofarm - OFF", "Red")
            Fullbright(false)
        else
            PlayerCharacterModule.AnimationHandler:PlayTrack("RunDefault", 0.1, 1, 1.5)
            autofarm = true
            notify("Autofarm - ON", "Green")
            Fullbright(true)
            startautofarm()
        end
    end
end)

notify("Autofarm by saucekid, paper", "White")
wait(1)
notify("Take out your pickaxe and press L", "White")
