--Modules
local managerGame = require("ManagerGame")

--Variables no publics
local pointRespawnPlayerHider : GameObject = nil
local playerPet : GameObject = nil
local charPlayer : GameObject = nil
local uiManager = nil

--Network Values
local player_id = StringValue.new("PlayerId", "")

--Events
local sendInfoAddZoneSeeker = Event.new("SendInfoAddZoneSeeker")
local sendActivateMenuHide = Event.new("SendActivateMenuHide")

--Functions
local function respawnStartPlayerHiding(character : Character)
    character:Teleport(pointRespawnPlayerHider.transform.position, function()end)
end

local function activateMenuSelectedModelHide(player, namePlayer, numStandCustome)
    if managerGame.playersTag[namePlayer] == "Hiding" then
        managerGame.playerObjTag[namePlayer] = player
        managerGame.activateMenuModelHide(true, numStandCustome)
    end
end

local function activateGameWhenExistTwoMorePlayerHiding()
    if managerGame.numRespawnPlayerHiding.value >= 2 and managerGame.isFirstReleaseSeeker.value then
        managerGame.releasePlayerServer:FireServer(managerGame.whoIsSeeker.value, Vector3.new(0.1, 1.5, -0.6))
        managerGame.isFirstReleaseSeeker.value = false
    end
end

--Unity Functions
function self:ClientAwake()
    uiManager = managerGame.UIManagerGlobal:GetComponent("UI_Hide_Seek")

    sendInfoAddZoneSeeker:Connect(function (char, namePlayer)
        if not managerGame.playersTag[namePlayer] and client.localPlayer.name == namePlayer then
            playerPet = managerGame.playerPetGlobal
            pointRespawnPlayerHider = managerGame.pointsRespawnPlayerHiderGlobal[managerGame.numRespawnPlayerHiding.value]
            charPlayer = char.gameObject

            managerGame.playersTag[namePlayer] = player_id.value
            managerGame.activateMenuModelHide(false, 0)
            managerGame.playerObjTag[namePlayer] = charPlayer
            managerGame.disabledDetectingCollisionsAllPlayersServer:FireServer()

            activateGameWhenExistTwoMorePlayerHiding()
            uiManager.SetInfoPlayers('Hello, Seeker! You gotta to search for the other players hidden around the map.')

            Timer.After(10, function()
                if managerGame.numRespawnPlayerHiding.value < 2 then
                    uiManager.SetInfoPlayers('Waiting for players to begin the search for those in hiding. There must be at least two players hiding on the stage.')
                end
            end)
        end
    end)

    sendActivateMenuHide:Connect(function (char, namePlayer)
        pointRespawnPlayerHider = managerGame.pointsRespawnPlayerHiderGlobal[managerGame.numRespawnPlayerHiding.value]

        if game.localPlayer.name == namePlayer then
            charPlayer = char.gameobject
            managerGame.playersTag[namePlayer] = player_id.value
            
            if managerGame.numRespawnPlayerHiding.value == 3 or managerGame.numRespawnPlayerHiding.value == 4 then
                activateMenuSelectedModelHide(charPlayer, namePlayer, 3)
                managerGame.standCustomePlayers[namePlayer] = 3
            else
                activateMenuSelectedModelHide(charPlayer, namePlayer, managerGame.numRespawnPlayerHiding.value)
                managerGame.standCustomePlayers[namePlayer] = managerGame.numRespawnPlayerHiding.value
            end

            activateGameWhenExistTwoMorePlayerHiding()
            uiManager.SetInfoPlayers('Hello, hiders! Choose a costume from the pedestals, then run and hide around the map.')
        end
        
        respawnStartPlayerHiding(char)
    end)
end

function self:ServerAwake()
    server.PlayerConnected:Connect(function(player : Player)
        player.CharacterChanged:Connect(function(player : Player, character : Character)
            if managerGame.isFirstPlayer.value then
                player_id.value = "Seeker"
                sendInfoAddZoneSeeker:FireAllClients(character, player.name)
                managerGame.isFirstPlayer.value = false
                managerGame.whoIsSeeker.value = player.name
            else
                player_id.value = "Hiding"
                sendActivateMenuHide:FireAllClients(character, player.name)
                managerGame.numRespawnPlayerHiding.value += 1

                if managerGame.numRespawnPlayerHiding.value == 5 then
                    managerGame.numRespawnPlayerHiding.value = 1
                end
            end
        end)
    end)
end