--Variables
local playersTag = {} -- Storage all player in the scene
local isFirstPlayer = true -- If it's first player or not

--Network Values
local player_id = StringValue.new("PlayerId", "")

function self:ServerAwake()
    server.PlayerConnected:Connect(function(player : Player)
        player.CharacterChanged:Connect(function(player : Player, character : Character)
            if isFirstPlayer then
                player_id.value = "Seeker"
                playersTag[player.name] = player_id.value
                isFirstPlayer = false
            else
                player_id.value = "Hiding"
                playersTag[player.name] = player_id.value
            end
        end)
    end)

    server.PlayerDisconnected:Connect(function(player)
        playersTag[player.name] = nil
    end)
end