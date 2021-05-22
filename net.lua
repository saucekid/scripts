settings().Physics.AllowSleep = false 
settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled 
spawn(function()
    while wait() do
        game.Players.LocalPlayer.MaximumSimulationRadius = math.huge;
        setsimulationradius(math.huge);
    end
end)
for i,v in next, game:GetService("Players").LocalPlayer.Character:GetDescendants() do
  if v:IsA("BasePart") then
    game:GetService("RunService").Heartbeat:connect(function()
      v.Velocity = Vector3.new(45,0,0)
    end)
  end
end
