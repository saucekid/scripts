local function js(i)return game:GetService("HttpService"):JSONDecode(i)end
local req = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request

local index = 0
local maxplrs = 30
local lowestID
while index do
    if index == 0 then index = "" end
    local res = req{
        Url = "https://games.roblox.com/v1/games/"..tostring(game.PlaceId).."/servers/Public?sortOrder=Asc&limit=100&cursor="..index,
        Method = "GET"
    }
    for i,v in next, js(res.Body).data do
        if v.playing < maxplrs then
            maxplrs = v.playing
            lowestID = v.id
        end
    end
    index = js(res.Body).nextPageCursor
    wait()
end
wait()
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,tostring(lowestID))
