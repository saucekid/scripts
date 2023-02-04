--[[
	mineassist 
    saucekid
    2/4/23
]]

local game = game
local GetService = game.GetService
if (not game.IsLoaded(game)) then
    local Loaded = game.Loaded
    Loaded.Wait(Loaded);
end


if not sweeperMaid then
    local Maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/Quenty/NevermoreEngine/version2/Modules/Shared/Events/Maid.lua"))()
    getgenv().sweeperMaid = Maid.new()
else
    sweeperMaid:DoCleaning()
end

-- vars
local Services = {
    Workspace = GetService(game, "Workspace");
    UserInputService = GetService(game, "UserInputService");
    ReplicatedStorage = GetService(game, "ReplicatedStorage");
    StarterPlayer = GetService(game, "StarterPlayer");
    StarterPack = GetService(game, "StarterPack");
    StarterGui = GetService(game, "StarterGui");
    TeleportService = GetService(game, "TeleportService");
    CoreGui = GetService(game, "CoreGui");
    TweenService = GetService(game, "TweenService");
    HttpService = GetService(game, "HttpService");
    TextService = GetService(game, "TextService");
    MarketplaceService = GetService(game, "MarketplaceService");
    Chat = GetService(game, "Chat");
    Teams = GetService(game, "Teams");
    SoundService = GetService(game, "SoundService");
    Lighting = GetService(game, "Lighting");
    ScriptContext = GetService(game, "ScriptContext");
    Stats = GetService(game, "Stats");
}


local GetChildren, GetDescendants = game.GetChildren, game.GetDescendants
local IsA = game.IsA
local FindFirstChild, FindFirstChildOfClass, FindFirstChildWhichIsA, WaitForChild = 
    game.FindFirstChild,
    game.FindFirstChildOfClass,
    game.FindFirstChildWhichIsA,
    game.WaitForChild

local lower, upper, Sfind, split, sub, format, len, match, gmatch, gsub, byte = 
    string.lower,
    string.upper,
    string.find,
    string.split, 
    string.sub,
    string.format,
    string.len,
    string.match,
    string.gmatch,
    string.gsub,
    string.byte


local random, floor, round, abs, atan, cos, sin, rad, clamp = 
    math.random,
    math.floor,
    math.round,
    math.abs,
    math.atan,
    math.cos,
    math.sin,
    math.rad,
    math.clamp

local Camera = Services.Workspace.CurrentCamera
local Players = Services.Players

local Lobby = FindFirstChild(Services.Workspace, "Lobby")
local Casino = FindFirstChild(Lobby, "Casino")
local Machines = FindFirstChild(Casino, "Machines")
local Sweeper = FindFirstChild(Machines, "Sweeper")
local Button = Sweeper.Button.Buy
local Slots = Sweeper.Machine.Slots.Boxes

-- slot calculating
local maxBombs = 9

local partData = {{},{},{},{},{}} do -- get the slot parts
    local xPos, yPos = {-252,-249,-245,-242,-238}, {9,13,16,20,23}
    for _,slot in pairs(GetChildren(Slots)) do
        local slotX, slotY = table.find(xPos, round(slot.Position.Z)), table.find(yPos, round(slot.Position.Y)) 
        slot:SetAttribute("X", slotX); slot:SetAttribute("Y", slotY)
        partData[slotX][slotY] = slot
    end
end

local boardData = { -- store the values of the board
    {-1,-1,-1,-1,-1},
    {-1,-1,-1,-1,-1},
    {-1,-1,-1,-1,-1},
    {-1,-1,-1,-1,-1},
    {-1,-1,-1,-1,-1},
}

local dataValues = {
    [5] = {"Confirmed", Color3.fromRGB(0,255,0)}, 
    [-3] = {"Bomb", Color3.fromRGB(255,0,0)},
    [-2] = {"Unsure", Color3.fromRGB(255,100,0)},
    [-1] = {"Regular", BrickColor.Gray()},

    ["Info"] = {0,4},
    ["Bags"] = {0,5},
    ["Not Bags"] = {-3,-1},
    ["Default"] = {-2,-1}
}

local adjacencyData = { -- tiles with these amounts of bombs have no bags surrounding them
    {2,3,3,3,2},
    {3,4,4,4,3},
    {3,4,4,4,3},
    {3,4,4,4,3},
    {2,3,3,3,2}
}

function getCurrentPlayer()
    local text = Button.SurfaceGui.TextLabel.Text
    text = text:gsub("CASH OUT", "")
    return text
end

function getAdjacencyData(slot)
    return adjacencyData[slot[1]][slot[2]]
end

function getBoardData(slot)
    return boardData[slot[1]][slot[2]]
end

function getBombsFromPart(part)
    return #part.SurfaceGui.BombCount.Text > 0 and tonumber(part.SurfaceGui.BombCount.Text) or 0
end

function getSlotFromPart(part)
    if (part:IsA("BasePart") and part.Parent == Slots) then
        return {part:GetAttribute("X"), part:GetAttribute("Y")}
    end
end

function getPartFromSlot(slot)
    return partData[slot[1]][slot[2]]
end

function checkSlot(slot, value)
    local slotData = getBoardData(slot)
    if dataValues[value] ~= nil then
        return math.clamp(slotData, dataValues[value][1], dataValues[value][2]) == slotData
    end

    for val,t in pairs(boardData) do
        if val == slotData and t[1] == value then
            return true
        end
    end

    return false
end

function setSlot(slot, value, part)
    local num = value do
        if type(value) == "string" then
            for w,v in pairs(dataValues) do
                if v[1] == value then
                    num = w
                end
            end
        end
    end
    
    boardData[slot[1]][slot[2]] = num
    
    if part then
        part.Color = dataValues[num][2]
    end
end

function getAllSlots(slotType)
    local slots = {}
    for x,T in pairs(boardData) do
        for y,v in pairs(T) do
            local slot = {x,y}
            if not slotType or checkSlot(slot, slotType) then
                table.insert(slots, slot)
            end
        end
    end
    return slots
end


function resetSlots()
    boardData = {
        {-1,-1,-1,-1,-1},
        {-1,-1,-1,-1,-1},
        {-1,-1,-1,-1,-1},
        {-1,-1,-1,-1,-1},
        {-1,-1,-1,-1,-1},
    }
end

function updateSlots(times)
    for i = 1, times do
        for _,slot in pairs(getAllSlots("Info")) do
            local bombs = getBoardData(slot)

            updateSlot(slot, bombs)
        end
        task.wait()
    end
end

function getCornerSlots(slot)
    local corner = {}
    local moveSet = {-1,1}
    for _,moveX in pairs(moveSet) do
        for _,moveY in pairs(moveSet) do
            pcall(function()
                table.insert(corner, boardData[slot[1]+moveX][slot[2]+moveY] and {slot[1]+moveX, slot[2]+moveY})
            end)
        end
    end
    return corner
end

function getAdjacentSlots(slot)
    local adjacent = {}
    local bombs = {}
    local moveSet = {-1,1}
    for _,move in pairs(moveSet) do
        pcall(function()
            local adjSlot = {slot[1]+move, slot[2]}
            if adjSlot and not checkSlot(adjSlot, "Bags") and boardData[slot[1]+move][slot[2]] then
                local adjSlotPart = getPartFromSlot(adjSlot)
                table.insert(adjacent, {slot[1]+move, slot[2]})
                if checkSlot(adjSlot, "Bomb") or adjSlotPart.Color == Color3.fromRGB(255,0,0)  then
                    table.insert(bombs, {slot[1]+move, slot[2]})
                end
            end
        end)
        pcall(function()
            local adjSlot = {slot[1], slot[2]+move}
            if adjSlot and not checkSlot(adjSlot, "Bags") and boardData[slot[1]][slot[2]+move] then
                local adjSlotPart = getPartFromSlot(adjSlot)
                table.insert(adjacent, {slot[1], slot[2]+move})
                if checkSlot(adjSlot, "Bomb") or adjSlotPart.Color == Color3.fromRGB(255,0,0) then
                    table.insert(bombs, {slot[1], slot[2]+move})
                end
            end
        end)
    end
    return adjacent, bombs
end

function updateSlot(slot, bombs, refresh)
    setSlot(slot, bombs)

    local slotPart = getPartFromSlot(slot)
    local adjacency = getAdjacencyData(slot)
    local adjacentSlots, bombSlots = getAdjacentSlots(slot)
    local cornerSlots = getCornerSlots(slot) 
    

    if bombs == 0 then --if no bombs then set set all adjacent as confirmed bags
        for _,adjacentSlot in pairs(adjacentSlots) do
            local adjacentPart = getPartFromSlot(adjacentSlot)
            if checkSlot(adjacentSlot, "Default") then
                setSlot(adjacentSlot, "Confirmed", adjacentPart)
            end
        end
    elseif bombs == adjacency then --if tile matches adjacencyData then set all adjacent as bombs
        for _,adjacentSlot in pairs(adjacentSlots) do
            local adjacentPart = getPartFromSlot(adjacentSlot)
            if checkSlot(adjacentSlot, "Default") then
                setSlot(adjacentSlot, "Bomb", adjacentPart)
            end
        end
    elseif not refresh or bombs ~= adjacency or bombs ~= 0 then
        for _,adjacentSlot in pairs(adjacentSlots) do
            local adjacentPart = getPartFromSlot(adjacentSlot)

            if bombs == #bombSlots and checkSlot(adjacentSlot, "Default") then
                setSlot(adjacentSlot, "Confirmed", adjacentPart)
            elseif bombs == #adjacentSlots then
                setSlot(adjacentSlot, "Bomb", adjacentPart)
            else
                if checkSlot(adjacentSlot, "Default") then
                    setSlot(adjacentSlot, "Unsure", adjacentPart)
                    
                    local text = FindFirstChild(adjacentPart.SurfaceGui, "Text")
                    if not text then
                        text = FindFirstChild(adjacentPart.SurfaceGui, "BombCount"):Clone()
                        text.Name = "Text"
                        text.Parent = adjacentPart.SurfaceGui
                        text.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end

                    text.Text = tostring(round((bombs/(#adjacentSlots))*100)).. "%"
                    text.Visible = true
                end
            end
        end
    end

    --check for guaranteed splits
    for _, cornerSlot in pairs(cornerSlots) do
        local cornerData = getBoardData(cornerSlot)
        if checkSlot(cornerSlot, "Info") and cornerData == 1 then
            local adjCornerSlots = getAdjacentSlots(cornerSlot)

            if #adjCornerSlots == 2  then
                local sharedSlots = {}
                local savedData = {
                    {1,1,1,1,1},
                    {1,1,1,1,1},
                    {1,1,1,1,1},
                    {1,1,1,1,1},
                    {1,1,1,1,1},
                }

                for _,adjCornerSlot in pairs(adjCornerSlots) do
                    savedData[adjCornerSlot[1]][adjCornerSlot[2]] = 0
                end

                for _,adjacentSlot in pairs(adjacentSlots) do
                    if checkSlot(adjacentSlot, "Default") then
                        if savedData[adjacentSlot[1]][adjacentSlot[2]] == 0 then
                            table.insert(sharedSlots, adjacentSlot)
                        end
                    end
                end
                
                if #sharedSlots == 2 then
                    for _,adjacentSlot in pairs(adjacentSlots) do
                        if checkSlot(adjacentSlot, "Default") and savedData[adjacentSlot[1]][adjacentSlot[2]] == 1 then
                            local adjacentPart = getPartFromSlot(adjacentSlot)
                            if bombs == 1 then
                                setSlot(adjacentSlot, "Confirmed", adjacentPart)
                            else
                                if #adjacentSlots - 1 == bombs then
                                    setSlot(adjacentSlot, "Bomb", adjacentPart)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

                        
    --set all slots to confirmed bags if all bombs are found 
    local bombsFound = #getAllSlots("Bomb")
    local bagsFound = #getAllSlots("Bags")

    if bombsFound >= maxBombs then
        for _,slot in pairs(getAllSlots("Default")) do
            setSlot(slot, "Confirmed")
        end
    end

    -- refresh board
    if refresh then
        updateSlots(2)
    end
end

--connect sweeper
for i,part in pairs(GetChildren(Slots)) do
    if part.BrickColor == BrickColor.new("New Yeller") then
        local slot, bombs = getSlotFromPart(part), getBombsFromPart(part)
        setSlot(slot, bombs)
    end
end

local fail = false
for i,part in pairs(GetChildren(Slots)) do
    task.wait()

    if part.BrickColor == BrickColor.new("New Yeller") then
        local slot, bombs = getSlotFromPart(part), getBombsFromPart(part)
        
        updateSlot(slot, bombs, true)
    end
    
    sweeperMaid:GiveTask(part:GetPropertyChangedSignal("Color"):Connect(function()
        local text = FindFirstChild(part.SurfaceGui, "Text")
        local color = part.BrickColor

        if text then
            text:Destroy()
        end

        task.wait()

        if color == BrickColor.new("New Yeller") and not fail then            
            fail = part.SurfaceGui.Bomb.Visible

            if not fail then
                local slot, bombs = getSlotFromPart(part), getBombsFromPart(part)

                updateSlot(slot, bombs, true)
            else
                Services.StarterGui:SetCore('SendNotification', {
                    Title = "Oops!",
                    Text = "mine was triggered by ".. getCurrentPlayer(),
                    Icon = 'rbxassetid://6459666422',
                    Duration = 5,
                })

                task.delay(2, function()
                    fail = false
                end)
            end
        elseif part.BrickColor == BrickColor.new("Black") then
            resetSlots()
        end
    end))
end

--Create load notification.
function joinDiscord()
    syn.request({
        Url = 'http://127.0.0.1:6463/rpc?v=1',
        Method = 'POST',
        Headers = {
            ['Content-Type'] = 'application/json',
            ['Origin'] = 'https://discord.com'
        },
        Body = game:GetService('HttpService'):JSONEncode({
            ["cmd"] = "INVITE_BROWSER",
            ["args"] = {
                ["code"] = "eX5k7TKN4F"
            },
            ["nonce"] = 'a'
        }),
    })
end

local Bindable = Instance.new("BindableFunction")
Bindable.OnInvoke = function(answer)
    if answer:find("Discord") then
        task.spawn(joinDiscord)
    end
end

Services.StarterGui:SetCore('SendNotification', {
        Title = "mineassist",
        Text = "successfully loaded! \n by saucekid",
        Icon = 'rbxassetid://6459666422',
        Duration = 5,
        Callback = Bindable,
        Button1 = 'Join Discord',
        Button2 = 'Okay'
    }
)