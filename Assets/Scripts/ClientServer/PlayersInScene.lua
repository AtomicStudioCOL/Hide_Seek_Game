--Modules
local managerGame = require("ManagerGame")

--Variables no publics
local pointRespawnPlayerHider : GameObject = nil
local playerPet : GameObject = nil
local charPlayer : GameObject = nil
local uiManager = nil
local cameraManagerHiding = nil
local cameraManagerSeeker = nil
local infoGameModule = nil

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
    if managerGame.numPlayerHidingCurrently.value >= 2 and managerGame.isFirstReleaseSeeker.value then
        managerGame.releasePlayerServer:FireServer(managerGame.whoIsSeeker.value, Vector3.new(0.1, 1.5, -0.6))
    end
end

local function mustWaitForPlayers()
    if managerGame.numPlayerHidingCurrently.value <= 2 then
        uiManager.SetInfoPlayers("Waiting for players: " .. tostring(managerGame.numPlayerHidingCurrently.value))
        
        if managerGame.numPlayerHidingCurrently.value == 2 then
            activateGameWhenExistTwoMorePlayerHiding()
        end
    end
end

--Unity Functions
function self:ClientAwake()
    uiManager = managerGame.UIManagerGlobal:GetComponent("UI_Hide_Seek")
    cameraManagerSeeker = managerGame.CameraManagerGlobal:GetComponent("CameraManager")
    cameraManagerHiding = managerGame.CameraManagerGlobal:GetComponent("RTSCamera")
    infoGameModule = managerGame.InfoGameModuleGlobal

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
            uiManager.SetInfoPlayers(infoGameModule.SeekerTexts["Intro"])

            Timer.After(5, mustWaitForPlayers)

            cameraManagerSeeker.enabled = true
            cameraManagerHiding.enabled = false
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
            uiManager.SetInfoPlayers(infoGameModule.HiderTexts["Intro"])

            Timer.After(10, function() uiManager.DisabledInfoPlayerHiding() end)

            cameraManagerSeeker.enabled = false
            cameraManagerHiding.enabled = true
        end

        if managerGame.whoIsSeeker.value == game.localPlayer.name then
            mustWaitForPlayers()
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
                managerGame.numPlayerHidingCurrently.value += 1 
                sendActivateMenuHide:FireAllClients(character, player.name)
                managerGame.numRespawnPlayerHiding.value += 1

                if managerGame.numRespawnPlayerHiding.value == 5 then
                    managerGame.numRespawnPlayerHiding.value = 1
                end

                if not managerGame.isFirstReleaseSeeker.value then
                    managerGame.updateNumPlayersHiding:FireAllClients()
                end
            end
        end)
    end)
end