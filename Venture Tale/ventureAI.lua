
--[[
    ventureAI 
    
    by saucekid (https://discord.gg/eX5k7TKN4F)
    
    CREDITS:
    - sukaretto#8874 (https://discord.gg/PFuQMWMhQQ)
    - ObscureScapter (https://v3rmillion.net/member.php?action=profile&uid=387561)
--]]

_G.safemode = _G.safemode or true

repeat wait() until game:IsLoaded() 
if executed then
    MessageBox.Show({Position = UDim2.new(0.5,0,0.5,0), Text = "ventureUI", Description = "Already executed!!", MessageBoxIcon = "Warning", MessageBoxButtons = "OK"})
    return;
end; getgenv().executed = true

local game = game;
local httpGet = game.HttpGet;

local quick = loadstring(httpGet(game, 'https://raw.githubusercontent.com/Belkworks/quick/master/init.lua'))();
local broom = loadstring(httpGet(game, 'https://raw.githubusercontent.com/Belkworks/broom/master/init.lua'))();
local pathing = loadstring(httpGet(game, 'https://raw.githubusercontent.com/V3N0M-Z/RBLX-SimplePath/main/src/SimplePath.lua'))(); pathing.Visualize = true;

-- services.
local s = quick.Service;
local workspace = s.Workspace;
local replicatedStorage = s.ReplicatedStorage;
local runService = s.RunService;

-- indexing.
local cf, v3 = CFrame.new, Vector3.new;

local findFirstChild, waitForChild = game.FindFirstChild, game.WaitForChild;
local getChildren, getPartsByRadius = game.GetChildren, workspace.GetPartBoundsInRadius;

local create, destroy = Instance.new, game.Destroy;
local fire, fireServer = create'BindableEvent'.Fire, create'RemoteEvent'.FireServer;

local string_find = string.find;
local string_format = string.format;

local jsonE, jsonD = function(o) return game.HttpService:JSONEncode(o) end, function(o) return game.HttpService:JSONDecode(o) end

local c = game.Loaded;
local connect, cwait = c.Connect, c.Wait;
local render, step = runService.RenderStepped, runService.Stepped;

local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

-- client.
local client = quick.User;
local character = client.Character or cwait(client.CharacterAdded);
local root = waitForChild(character, 'HumanoidRootPart');
local gyro = waitForChild(root, 'BodyGyro')
local humanoid = waitForChild(character, 'Humanoid');

local distanceFromCharacter = client.DistanceFromCharacter;
local characterPathing = pathing.new(character, {AgentRadius = 2, AgentHeight = 4, AgentCanJump = true, WaypointSpacing = 4.2}, {
    Costs = {
        Water = math.huge,
        Neon = math.huge
    }}, {
    TIME_VARIANCE = 0.07,
    COMPARISON_CHECKS = 2,
    JUMP_WHEN_STUCK = true
});

for i,v in pairs(getconnections(client.Idled)) do
    v:Disable()
end

if _G.safemode and game.PlaceVersion > 923 then client:Kick("\nGame Updated.\nWait For Script Update!") return end

-- things.
local map = workspace.Map;
local projectiles = workspace.Projectiles;
local rangeIndicators = workspace.RangeIndicators
local IPDFunctions = require(replicatedStorage.Modules.IPDFunctions)
local clientEquipped = client.stats.Equipped;

-- remotes&attacking.
local remotes = replicatedStorage.Remotes;
local action = remotes.Action;

local attackRemotes = {
    Melee = action.MeleeAttack,
    Magic = action.MagicAttack,
    Bow = action.BowAttack
}
local useAbility =  action.ActivateAbility;
local dungeonVoting = remotes.UI.EndDungeon.EndOfDungeonVote;

-- weapon calculation.
local Weapons = {
    [1] = { hitDelay = 1.2, range = 110 }, 
    [2] = { hitDelay = 1.2, range = 100 },

    Types = {
        Melee = {
            "Hammer",
            "Dagger",
            "Axe",
            "Spear",
            "Sword",
            "Rapier",
            "Polearm",
            "Greatsword",
            "Katana",
        },
        Bow = {
            "Bow",
            "Crossbow",
        },
        Magic   = {
            "Staff",
            "Wand",
            "Book",
        }
    }
} do 
    function Weapons.getWeaponCooldown(weapon, weaponData)
        local Tags = findFirstChild(weaponData, "Tags");
        local attackBoost = IPDFunctions:GetBoostValue(character, "AttackSpeedBoost");
        
        if Tags  then
            for q, c in next, getChildren(Tags) do
                attackBoost = attackBoost + IPDFunctions:GetBoostValue(character, c.Name .. "AttackSpeedBoost")
            end
        end
        
        return weaponData:FindFirstChild("NoAttack") and 1.2 or 1 / (weaponData.AttackSpeed.Value * 1.03 ^ (weapon.Rarity.Value - weaponData.BaseRarity.Value) * (1 + attackBoost / 100))
    end
    
    function Weapons.calculate(weapon)
        local weaponType = weapon.ItemType.Value;
        local weaponIndex = weapon.Name:gsub("Wep", "")
        
        local weaponTypeFolder = replicatedStorage.ItemData[weaponType];
        local weaponData = quick.find(getChildren(weaponTypeFolder), function(w) return w.Name == weapon.ItemID.Value end);
                
        local attackType 
        for i,class in pairs(Weapons.Types) do
            if table.find(class, weaponType) then
                attackType = i
            end
        end
        
        local equippedWeapon = Weapons[tonumber(weaponIndex)]
        local otherWeapon = tonumber(weaponIndex) == 1 and Weapons[2] or Weapons[1]
        if weaponData and attackType then
            equippedWeapon.Type = attackType
            equippedWeapon.weapon = weapon
            equippedWeapon.data = weaponData
            equippedWeapon.remote = attackRemotes[attackType]
            equippedWeapon.range = findFirstChild(weaponData, "Range") and weaponData.Range.Value or equippedWeapon.range;
            equippedWeapon.Ranged = (attackType == "Magic" or attackType == "Bow") and true or false;
            
            if not otherWeapon.remote then
                for i,v in pairs(equippedWeapon) do
                    otherWeapon[i] = v
                end
            end
        else
            equippedWeapon.remote = nil
        end;
    end;

    local function weaponChanged(w)
        Weapons.calculate(w);
        connect(w.ItemID.Changed, function() Weapons.calculate(w) end);
    end;
    
    quick.each(getChildren(clientEquipped), function(v) if string_find(v.Name, 'Wep') then weaponChanged(v) end end);
    connect(clientEquipped.ChildAdded, function(v)
        if string_find(v.Name, 'Wep') then
            weaponChanged(v);
        end;
    end);
end;

-- classes.
local hostile = ({params=(function()
    local _ = OverlapParams.new()
        _.FilterDescendantsInstances = { workspace.NPCS }
        _.FilterType = Enum.RaycastFilterType.Whitelist;
    
    return _;
end)(), filtered = {
    ['GoblinBashWatermelon'] = true
}}); do
    function hostile:group()
        local parts = quick.map(getPartsByRadius(workspace, root.Position, Weapons[1].range, self.params), function(p)
            return p.Parent;
        end);
        
        return quick.uniq(quick.filter(parts, function(p) return not self.filtered[p.Name] and p.Parent == workspace.NPCS end));
    end;
    
    function hostile:behindWall(hostile)
        local CF = CFrame.new(hostile.HumanoidRootPart.Position, character["Wep1"]:GetPivot().p);
        local _ = RaycastParams.new();
            _.IgnoreWater = true
            _.FilterDescendantsInstances = { workspace.NPCS, character, workspace.DeadNPCS, workspace.Projectiles, damageIndicators, workspace.Map:findFirstChild("Throne") };
            _.FilterType = Enum.RaycastFilterType.Blacklist;
        return workspace:Raycast(CF.p, CF.LookVector * (hostile.HumanoidRootPart.Position - root.Position).magnitude, _)
    end
    
    function hostile:nearest()
        local nearestVis = {behindWall = false, distance = math.huge}
        local nearest = {behindWall = true, distance = math.huge}

        for _, v in next, getChildren(workspace.NPCS) do
            if self.filtered[v.Name] or (not findFirstChild(v, 'HumanoidRootPart')) then continue end;
            
            local wall = self:behindWall(v)
            local magnitude = distanceFromCharacter(client, v.HumanoidRootPart.Position);
            if wall then
                if magnitude < nearest.distance then
                    nearest.instance = v
                    nearest.distance = magnitude
                end
            else
                if magnitude < nearestVis.distance then
                    nearestVis.instance = v
                    nearestVis.distance = magnitude
                end
            end
        end;
        
        local selected = nearestVis.instance and nearestVis or nearest
        return selected.instance, selected.distance, selected.behindWall;
    end;
end;


local ability = {} do
    ability.items = {
    }
    ability.wrapper = {
        ["1"] = 3,
        ["2"] = 4,
        ["3"] = 5,
        ["4"] = 6
    }
    function ability.register(item)
        local itemType = item.ItemType.Value;
        local itemIndex = item.Name:gsub("Item", "")
        
        local itemTypeFolder = replicatedStorage.ItemData[itemType];
        local itemData = quick.find(getChildren(itemTypeFolder), function(i) return i.Name == item.ItemID.Value end);
        
        if itemType == "Spell" or item.ItemID.Value:find("Potion") then
            local abilityType = item.ItemID.Value:find("Roll") and "Roll" or item.ItemID.Value:find("Potion") and "Potion" or "Spell"
            ability.items[tonumber(itemIndex)] = {
                Type = abilityType,
                remote = ability.wrapper[itemIndex],
                potion = (abilityType == "Potion" and item.ItemID.Value:find("Heal")) and "Heal" or (abilityType == "Potion" and item.ItemID.Value:find("Mana")) and "Mana" or false
            }
        else
            ability.items[tonumber(itemIndex)] = nil
        end
    end
    
    function ability.cooldown(a)
        local attributes = findFirstChild(character, 'Attributes');
        return attributes and findFirstChild(attributes.Value, 'Cooldowns') and findFirstChild((attributes.Value).Cooldowns, string_format('Wep%dAbilityCD', a)) ~= nil;
    end;
    
    function ability.getMana()
        local mana = findFirstChild(character, 'Mana')
        return mana.Value, mana and mana.Max.Value
    end
    
    function ability:use(a)
        if (not self.cooldown(a)) then
            task.spawn(fireServer, useAbility, a);
            return true;
        end;
        return false;
    end;
    
    function ability:getAbility(itemType)
        local abilities  = {}
        for _, item in pairs(self.items) do
            if item.Type == itemType then
                table.insert(abilities, item)
            end
        end
        return abilities
    end
    
    -- potion
    function ability.potion()
        local potions = ability:getAbility("Potion")
        local mana, maxMana = ability.getMana()
        if potions then
            for _,potion in pairs(potions) do
                if potion.potion == "Heal" and humanoid.Health <= humanoid.MaxHealth/2 then
                    return ability:use(potion.remote)
                elseif potion.potion == "Mana" and mana <= maxMana/2 then
                    return ability:use(potion.remote)
                end
            end
        end
    end
    
    -- spells
    function ability:castSpells()
        local spells = self:getAbility("Spell")
        local mana, maxMana = ability.getMana()
        if spells then
            for _,spell in pairs(spells) do
                if mana >= maxMana*0.75 then
                    local success = ability:use(spell.remote)
                end
            end
        end
    end
    
    -- roll
    function ability.canRoll()
        local roll = ability:getAbility("Roll")
        if roll then
            return not ability.cooldown(roll[1].remote) 
        end
        return false
    end

    function ability.roll()
        local roll = ability:getAbility("Roll")
        if roll then
            return ability:use(roll[1].remote)
        end
    end
        
    
    -- dash
    function ability.dash()
        return ability:use(999)
    end
    
    function ability.canDash()
        return not ability.cooldown(999)
    end
    
    local function itemChanged(w)
        ability.register(w);
        connect(w.ItemID.Changed, function() ability.register(w) end);
    end;
    
    quick.each(getChildren(clientEquipped), function(v) if string_find(v.Name, 'Item') then itemChanged(v) end end);
    connect(clientEquipped.ChildAdded, function(v)
        if string_find(v.Name, 'Item') then
            itemChanged(v);
        end;
    end);   
end;

local function attack(group)
    local targetMap = #group > 0 and quick.map(group, function(v)
        return { TargetCharacter = v, KnockbackDirection = cf(v3(root.Position.X, v.HumanoidRootPart.Position.Y, root.Position.Z), v.HumanoidRootPart.Position).LookVector }
    end);
    
    if not targetMap then return end;
    for i = 1, 2 do
        local w = Weapons[i]
        if w.remote then
            w.remote:FireServer(i, { Targets = targetMap })
            ability:use(i);
        end
    end;
end;


-- file system.
local folderpath = [[ventureAI/]]

if makefolder then
	makefolder("ventureAI")
end

local function existsFile(name)
	if not readfile then return end
	return pcall(function()
		return readfile(folderpath .. name)
	end)
end

function load(name, settings)
	if not existsFile(name) then return end
	local _, Result = pcall(readfile, folderpath .. name);
	if _ then
		local _, Loaded = pcall(game.HttpService.JSONDecode, game.HttpService, Result);
		if _ then
	        for i, v in pairs(Loaded) do
                settings[i] = v;
                pcall(settings[i], v);
            end
		end
	end
end

function save(table, name)
	if writefile then
		writefile(folderpath .. name, jsonE(table));
	end
end

getgenv().MessageBox = loadstring(httpGet(game,"https://raw.githubusercontent.com/xHeptc/NotificationGUI/main/source.lua"))()
if not existsFile("executed.once") then
    MessageBox.Show({Position = UDim2.new(0.5,0,0.5,0), Text = "ventureUI", Description = "Use the arrows keys to navigate the GUI", MessageBoxIcon = "Question", MessageBoxButtons = "OK", Result = function(res)
        if (res == "OK") then
           writefile(folderpath .. "executed.once", "")
       end
    end})
end

-- flags.
local autoDungeon, ignore = create'BindableEvent';
    
local flags = {
    pathFind = true,
    killAura = true,
    autoDungeon = false,
    autoPotion = true,
    autoDodge = true,
    autoSpell = true,
    anims = false,
    dashWarp = true,
    jumping = true,
    gateTeleport = true,
    keepDistance = false,
    distanceAway = 30
}; load("dungeon.json", flags)


-- auto execute.
client.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started and syn then
        queueteleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/saucekid/scripts/main/Venture%20Tale/ventureAI.lua"))()]])
    end
end)


-- lib.
local lib = loadstring(httpGet(game, 'https://raw.githubusercontent.com/saucekid/UI-Libraries/main/ArrowsUIlib.lua'))(); do
    _G["Theme"] = {
        ["UI_Position"] = Vector2.new(50, 200),
        ["Text_Size"] = 16,
    
        ["Category_Text"] = Color3.fromRGB(255, 255, 255),
        ["Category_Back"] = Color3.fromRGB(0, 0, 0),
        ["Category_Back_Transparency"] = 0.5,
    
        ["Option_Text"] = Color3.fromRGB(255, 255, 255),
        ["Option_Back"] = Color3.fromRGB(0, 0, 0),
        ["Option_Back_Transparency"] = 0,
        ["Selected_Color"] = Color3.fromRGB(128,128,128)
    }
    
    
    if game.PlaceId == 4809447488 then 
        flags = {
            selectedDungeon = "Goblin Cave", 
            selectedDifficulty = "Easy", 
            hardCore = false,
            autoStart = false,
        }; load("lobby.json", flags)
        
        local dungeons, realDungeons, difficulties = 
        {"Goblin Cave", "Enchanted Forest", "Bandit Castle"}, 
        {
            ["Goblin Cave"] = "GoblinCave",
            ["Enchanted Forest"] = "EnchantedForest",
            ["Bandit Castle"] = "BanditCastle",
        }, 
        {"Easy", "Normal", "Hard", "Raid", "Endless"}
        
        local dungeonTab = lib:NewCategory("Lobby"); do
            dungeonTab:NewButton(
                'Start Solo',
                function()
                    remotes.UI.Lobby.StartLobby:FireServer(realDungeons[flags.selectedDungeon], flags.selectedDifficulty, flags.hardCore, "Solo")
                end
            );
            
            dungeonTab:NewButton(
                'Create Lobby',
                function()
                    remotes.UI.Lobby.CreateLobby:FireServer(realDungeons[flags.selectedDungeon], flags.selectedDifficulty, flags.hardCore)
                end
            );
        
            dungeonTab:NewToggle(
                'Auto Start',
                flags.autoStart,
                function(state)
                    flags.autoStart = state
                    coroutine.wrap(function()
                        local countDown 
                        for i = 5,1,-1 do
                            if countDown then countDown:Remove() end
                            if not flags.autoStart then return end
                            countDown = Drawing.new("Text")
                            countDown.Text = tostring(i)
                            countDown.Color = Color3.new(1,1,1)
                            countDown.Outline = true
                            countDown.OutlineColor = Color3.new(0,0,0)
                            countDown.Size = 50
                            countDown.Center = true
                            countDown.Visible = true
                            countDown.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2  - (game.GuiService:GetGuiInset().Y/2))
                            wait(1)
                        end
                        countDown:Remove()
                        remotes.UI.Lobby.StartLobby:FireServer(realDungeons[flags.selectedDungeon], flags.selectedDifficulty, flags.hardCore, "Solo")
                    end)()
                end
            );
        
            dungeonTab:NewDropdown("Dungeon", dungeons, table.find(dungeons, flags.selectedDungeon), function(option) 
                flags.selectedDungeon = option
            end)
            
            dungeonTab:NewDropdown("Difficulty", difficulties, table.find(difficulties, flags.selectedDifficulty), function(option) 
                flags.selectedDifficulty = option
            end)
            
            dungeonTab:NewToggle(
                'Hardcore',
                flags.hardCore,
                function(state)
                    flags.hardCore = state
                end
            );
        end
        
        local miscTab = lib:NewCategory("Misc.") do
            miscTab:NewButton(
                'Rejoin',
                function()
                    game.TeleportService:Teleport(4809447488, client)
                end
            );
        
            miscTab:NewButton(
                'Join Discord',
                function()
                    local json = {
                        ["cmd"] = "INVITE_BROWSER",
                        ["args"] = {
                            ["code"] = "eX5k7TKN4F"
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
            );
        end
        
        connect(game.Players.PlayerRemoving, function(plr)
            if plr == client then
                save(flags, "lobby.json")
            end
        end)
        return
    end

    local adTab = lib:NewCategory("ventureAI"); do
        adTab:NewToggle(
            'on/off',
            flags.autoDungeon,
            function(state)
                flags.autoDungeon = state
                fire(autoDungeon, state);
            end
        );
    end
    
    local settingsTab = lib:NewCategory("Settings"); do
        settingsTab:NewToggle(
            'Kill Aura',
            flags.killAura,
            function(state)
                flags.killAura = state;
                coroutine.wrap(function()
                    while flags.killAura do
                        local cooldown = Weapons.getWeaponCooldown(Weapons[1].weapon, Weapons[1].data)
                        local hostiles = hostile:group();
                        attack(hostiles);
                        task.wait((#hostiles == 0 and 0) or cooldown);
                    end;
                end)()
            end
        );
    
        settingsTab:NewToggle(
            'Auto Potion',
            flags.autoPotion,
            function(state)
                flags.autoPotion = state
            end
        );
    
        settingsTab:NewToggle(
            'Auto Dodge',
            flags.autoDodge,
            function(state)
                flags.autoDodge = state
            end
        );
    
        settingsTab:NewToggle(
            'Auto Cast Spell',
            flags.autoSpell,
            function(state)
                flags.autoSpell = state
            end
        );
    
        settingsTab:NewToggle(
            'Animations',
            flags.anims,
            function(state)
                flags.anims = state
            end
        );
    
    
        settingsTab:NewToggle(
            'Teleport to gates',
            flags.gateTeleport,
            function(state)
                flags.gateTeleport = state
            end
        );
    
        settingsTab:NewToggle(
            'Teleport if stuck',
            flags.dashWarp,
            function(state)
                flags.dashWarp = state
            end
        );
    
        settingsTab:NewToggle(
            'Smart Jump',
            flags.jumping,
            function(state)
                flags.jumping = state
                characterPathing._settings.JUMP_WHEN_STUCK = state
            end
        );
        
        if Weapons[1].Ranged then
            settingsTab:NewToggle(
                'Keep Distance with Ranged',
                flags.keepDistance,
                function(state)
                    flags.keepDistance = state
                end
            );
    
            settingsTab:NewSlider(
                'Distance',
                flags.distanceAway,
                1, 0, 100, 2, " studs",
                function(num)
                    flags.distanceAway = num
                end
            );
        else
            flags.keepDistance = false
        end
    
        adTab:NewToggle(
            'Visualize Path',
            pathing.Visualize,
            function(state)
                pathing.Visualize = state
            end);
    end


    local miscTab = lib:NewCategory("Misc.") do
        miscTab:NewButton(
            'Join Lobby',
            function()
                game.TeleportService:Teleport(4809447488, client)
            end
        );
    
        miscTab:NewButton(
            'Join Discord',
            function()
                local json = {
                    ["cmd"] = "INVITE_BROWSER",
                    ["args"] = {
                        ["code"] = "eX5k7TKN4F"
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
        );
    end
end

do
    local autoDungeon_broom = broom();
    
    local mousePos
    local faceCF
    local behindWall
    
    local function inAttackRadius()
        for _,indicator in next, getChildren(rangeIndicators) do
            if indicator.Name == "LingeringSpear" then continue end
            if indicator:IsA("Folder") then indicator = findFirstChild(indicator, 'Main') or indicator:FindFirstChildOfClass("BasePart") end
            
            indicator.Position = Vector3.new(indicator.Position.X, root.Position.Y, indicator.Position.Z)
            if not findFirstChild(indicator, "TouchInterest") then
                indicator.Touched:Connect(function() end) 
            end
            local touching = indicator:GetTouchingParts()
            for i,v in pairs(touching) do
		        if v.Parent == character then
		        	return indicator
		        end
	        end
        end
		return false
    end
    
    local function dashWarp(cf)
        if not flags.dashWarp then return end
        local res = ability:use(999);
        if res then
            task.wait(0.165);
            character:PivotTo(cf);
            root:GetPropertyChangedSignal("Position"):Wait()
        end;
    end;

    connect(autoDungeon.Event, function(state)
        if not state then return autoDungeon_broom:clean() end;

        for _,v in pairs(map.Segments:GetDescendants()) do
            if v:IsA("BasePart") and v.Transparency < 1 and (v.Parent.Name == "Balustrade1_Angled_Variant1" or v.Parent.Name == "Balustrade1_Straight_Variant2" or not v.Name:find("Wall") and not v.Name:find("Bricks") and not v.Name:find("Floor") and not v.Parent.Name:find("Floor") and not v.Name:lower():find("coin")) then
                v.CanCollide = false
            end
        end
        
        gyro.P = 3000
        autoDungeon_broom:GiveTask(connect(gyro:GetPropertyChangedSignal("CFrame"), function()
             pcall(function() gyro.CFrame = CFrame.new(root.Position, faceCF) end)
        end))
        
        local stuck = 0
        autoDungeon_broom:GiveTask(connect(render, function()
            if not root or (humanoid and humanoid.Health == 0) then return end;

            local hostile, distance, _ = hostile:nearest(); behindWall = _
            local potion = (flags.autoPotion) and ability.potion()
            local dodge = flags.autoDodge and (inAttackRadius() or (findFirstChild(projectiles, "Pebble") or (not Weapons[1].Ranged and findFirstChild(projectiles, "Arrow"))))
            local gate, loot = (findFirstChild(projectiles, 'WaitingForPlayers') or findFirstChild(projectiles, 'BossWaitingForPlayers')), findFirstChild(map, 'LootPrompt', true);
            local boss, dungeonFailed = replicatedStorage.ControlSettings.CurrentBoss.Value, replicatedStorage.ControlSettings.Failed.Value;
            
            faceCF = ((hostile and not behindWall) or (hostile and dodge)) and hostile.HumanoidRootPart.Position or behindWall and humanoid.WalkToPoint or client:GetMouse().Hit.Position
            
            if gate then
                if flags.gateTeleport then
                    root.CFrame = gate.CFrame + Vector3.yAxis;
                else
                    local gatePath = gate.Name == "BossWaitingForPlayers"  and characterPathing:Run(gate.Position + gate.CFrame.lookVector * -40) or characterPathing:Run(gate.Position + gate.CFrame.rightVector * 5);
                end
                return;
            elseif loot or dungeonFailed then
                if loot then 
                    fireproximityprompt(loot); 
                end
                fireServer(dungeonVoting, 'ReplayDungeon');
            elseif dodge then
                characterPathing._settings.JUMP_WHEN_STUCK = flags.jumping and false
                characterPathing:Run(root.Position + root.CFrame.rightVector * -8);
                if dodge.Parent == damageIndicators and (ability.canRoll() or ability.canDash()) then
                    mousePos = root.Position + root.CFrame.rightVector * -8
                    ability.roll()
                    ability.dash()
                    return
                end
                mousePos = hostile and hostile.HumanoidRootPart.Position
            elseif hostile then
                local hostilePos = findFirstChild(hostile, 'Waiting' .. hostile.Name) and Vector3.new(hostile.HumanoidRootPart.Position.X, root.Position.Y, hostile.HumanoidRootPart.Position.Z) or hostile.HumanoidRootPart.Position
                                
                mousePos = behindWall and humanoid.WalkToPoint or hostile.HumanoidRootPart.Position
                humanoid.MaxSlopeAngle = math.huge;
                characterPathing._settings.COMPARISON_CHECKS = (distance < 10 and flags.jumping) and 1 or 2
                
                local castSpells = flags.autoSpell and ability:castSpells()
                
                if distance <= flags.distanceAway and flags.keepDistance and not behindWall then
                    if distance >= 15 then
                        characterPathing._settings.JUMP_WHEN_STUCK = flags.jumping and false
                        characterPathing:Run(root.Position + root.CFrame.lookVector * -7);
                    else
                        characterPathing:Run(hostilePos + hostile.HumanoidRootPart.CFrame.lookVector * -10);
                    end
                    return
                elseif distance > flags.distanceAway and distance < Weapons[1].range and flags.keepDistance and not behindWall then
                    return
                end
            
                characterPathing._settings.JUMP_WHEN_STUCK = flags.jumping and true
                local pathEnemy = characterPathing:Run(hostilePos + hostile.HumanoidRootPart.CFrame.lookVector * -math.clamp(Weapons[1].range, 0, 10));
                if not pathEnemy and not humanoid.Jump then
                    stuck = stuck + 1
                    if stuck > 100 then
                        stuck = 0
                        dashWarp(hostile.HumanoidRootPart.CFrame)
                    end
                    return 
                elseif pathEnemy then
                    stuck = 0
                end
                
                if behindWall then
                    ability.dash()
                    ability.roll()
                end
            end;
        end));
    end);

    connect(client.CharacterAdded, function(newCharacter)
        character = newCharacter;
        root = waitForChild(newCharacter, 'HumanoidRootPart');
        gyro = waitForChild(root, "BodyGyro"); gyro.P = 3000
        humanoid = waitForChild(newCharacter, 'Humanoid');
        characterPathing = pathing.new(newCharacter, {AgentRadius = 2, AgentHeight = 4, AgentCanJump = true, WaypointSpacing = 4.2}, {
            Costs = {
                Water = math.huge,
                Neon = math.huge
            }}, {
            TIME_VARIANCE = 0.07,
            COMPARISON_CHECKS = 2,
            JUMP_WHEN_STUCK = true
        });
        if flags.autoDungeon then
            autoDungeon_broom:GiveTask(connect(gyro:GetPropertyChangedSignal("CFrame"), function()
                pcall(function() gyro.CFrame = CFrame.new(root.Position, faceCF)  end)
            end))
        end
    end);
    
    fire(autoDungeon, flags.autoDungeon);

    connect(game.Players.PlayerRemoving, function(plr)
        if plr == client then
            save(flags, "dungeon.json")
        end
    end)
    
    local DungeonGui = client.PlayerGui.DungeonClear
    connect(DungeonGui.DungeonClearLabel:GetPropertyChangedSignal("Visible"), function()
        if DungeonGui.DungeonClearLabel.Visible then
            fireServer(dungeonVoting, 'ReplayDungeon');
        end
    end)
    
    oldNamecall = hookfunction(getrawmetatable(game).__namecall, newcclosure(function(self, ...)
        local Args   = {...}
        local callMethod = getnamecallmethod()
        if callMethod == "FireServer" then
            if self.Name == "UpdateMouseDirection" and flags.autoDungeon then
                Args[1]  = mousePos;
            end
            if attackRemotes[self.Name:gsub("Attack", "")] then
                if checkcaller() then
                    if behindWall then
                        return;
                    end
                    if flags.anims then
                        coroutine.wrap(function()
                            mouse2press()
                            task.wait(.2)
                            mouse2release()
                        end)()
                    end
                else
                    if flags.autoDungeon then
                        return;
                    end
                end
            end
        end
        return oldNamecall(self, unpack(Args))
    end))
end;

