--Modules
local managerGame = require("ManagerGame")

--Variables no publics
local pointRespawnPlayerHider : GameObject = nil
local playerPet : GameObject = nil
local isFirstPlayer = true -- If it's first player or not
local charPlayer : GameObject = nil

--Network Values
local player_id = StringValue.new("PlayerId", "")

--Events
local sendInfoAddZoneSeeker = Event.new("SendInfoAddZoneSeeker")
local sendActivateMenuHide = Event.new("SendActivateMenuHide")

--Functions
local function addZoneDetectionSeeker(target, namePlayer)
    managerGame.playerObjTag[namePlayer] = target

    managerGame.addCostumePlayers(
        playerPet, 
        target,
        Vector3.new(0.1, 1.5, -0.6), 
        managerGame.playersTag[namePlayer]
    )
end

local function respawnStartPlayerHiding(character : Character)
    character:Teleport(pointRespawnPlayerHider.transform.position, function()end)
end

local function activateMenuSelectedModelHide(player, namePlayer)
    if managerGame.playersTag[namePlayer] == "Hiding" then
        managerGame.playerObjTag[namePlayer] = player
        managerGame.activateMenuModelHide(true)
    end
end

--Unity Functions
function self:ClientAwake()
    sendInfoAddZoneSeeker:Connect(function (char, namePlayer)
        if not managerGame.playersTag[namePlayer] and client.localPlayer.name == namePlayer then
            playerPet = managerGame.playerPetGlobal
            pointRespawnPlayerHider = managerGame.pointRespawnPlayerHiderGlobal
            charPlayer = char.gameObject

            managerGame.playersTag[namePlayer] = player_id.value
            managerGame.activateMenuModelHide(false)
            addZoneDetectionSeeker(charPlayer, namePlayer)
        end
    end)

    sendActivateMenuHide:Connect(function (char, namePlayer)
        if not managerGame.playersTag[namePlayer] and client.localPlayer.name == namePlayer then
            pointRespawnPlayerHider = managerGame.pointRespawnPlayerHiderGlobal
            charPlayer = char.gameObject
            
            managerGame.playersTag[namePlayer] = player_id.value
            activateMenuSelectedModelHide(charPlayer, namePlayer)
        end
        respawnStartPlayerHiding(char)
    end)
end

function self:ServerAwake()
    isFirstPlayer = true

    server.PlayerConnected:Connect(function(player : Player)
        player.CharacterChanged:Connect(function(player : Player, character : Character)
            if isFirstPlayer then
                player_id.value = "Seeker"
                sendInfoAddZoneSeeker:FireAllClients(character, player.name)
                isFirstPlayer = false
            else
                player_id.value = "Hiding"
                sendActivateMenuHide:FireAllClients(character, player.name)
            end
        end)
    end)

    server.PlayerDisconnected:Connect(function(player : Player)
        managerGame.playersTag[player.name] = nil
        --Cuando se salga un jugador si es el buscador se debe terminar el juego, o que se reinicie el juego para elegir otro buscador
    end)
end