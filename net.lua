--[[
 ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ 
||n |||e |||t |||       |||b |||y |||p |||a |||s |||s ||
||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__||
|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|

]]--

local sethiddenprop = (sethiddenproperty or set_hidden_property or sethiddenprop or set_hidden_prop)
local setsimulationrad = setsimulationradius or set_simulation_radius or function(Radius) sethiddenprop(PlayerInstance, "SimulationRadius", Radius) end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
Player = Players.LocalPlayer

settings().Physics.AllowSleep = false 
settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled 
RunService.Stepped:Connect(function() --old net
    sethiddenprop(Player, "MaximumSimulationRadius", math.huge)
    setsimulationrad(math.huge)
end)

for i,v in next, game:GetService("Players").LocalPlayer.Character:GetDescendants() do --netless
  if v:IsA("BasePart") then
    game:GetService("RunService").Heartbeat:connect(function()
      v.Velocity = Vector3.new(45,0,0)
    end)
  end
end
