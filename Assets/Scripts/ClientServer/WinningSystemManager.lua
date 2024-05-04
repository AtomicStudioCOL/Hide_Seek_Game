--Modules
local managerGame = require("ManagerGame")

--Variables
local pointRespawnPlayers : GameObject = nil
local uiManager = nil
local isCreatedCoroutine = false
local countdown = 9
local countdownEndGame = nil

--Events
local startCountdownAllClients = Event.new("StartCountdownEndGame")
local endCountdownAllClients = Event.new("EndCountdownGame")
local resetNetworkValuesGame = Event.new("ResetNetworkValuesGame")
local updateRespawnPlayersHiding = Event.new("UpdateRespawnPlayersHiding")

--Functions
function respawnStartPlayers(character : Character)
    print("Character: ", tostring(character), " of the player: ", tostring(game.localPlayer.name))
    character:Teleport(pointRespawnPlayers.transform.position, function()end)
end

function activateMenuSelectedModelHide(player, namePlayer, numStandCustome)
    if managerGame.playersTag[namePlayer] == "Hiding" then
        managerGame.activateMenuModelHide(true, numStandCustome)
    end
end

function PositionPlayersHiding(charPlayer, namePlayer)
    if managerGame.numRespawnPlayerHiding.value == 3 or managerGame.numRespawnPlayerHiding.value == 4 then
        activateMenuSelectedModelHide(charPlayer, namePlayer, 3)
        managerGame.standCustomePlayers[namePlayer] = 3
    else
        activateMenuSelectedModelHide(charPlayer, namePlayer, managerGame.numRespawnPlayerHiding.value)
        managerGame.standCustomePlayers[namePlayer] = managerGame.numRespawnPlayerHiding.value
    end
end

function RespawnAllPlayersInGame(character, namePlayer)
    local objPlayer = managerGame.objsCustome[namePlayer]
    if objPlayer then
        if namePlayer == managerGame.whoIsSeeker.value then
            pointRespawnPlayers = managerGame.pointRespawnPlayerSeekerGlobal
            uiManager.SetInfoPlayers("Players Found: " .. tostring(managerGame.numPlayersFound.value) .. '/' .. tostring(managerGame.numPlayerHidingCurrently.value))
            respawnStartPlayers(character)

            for namePlayer : string, objPlayer : GameObject in pairs(managerGame.objsCustome) do
                if objPlayer == nil then continue end
                objPlayer:SetActive(true)
            end
        else
            pointRespawnPlayers = managerGame.pointsRespawnPlayerHiderGlobal[managerGame.numRespawnPlayerHiding.value]
            print("Respawn others player hiding: ", namePlayer, " - ", tostring(pointRespawnPlayers))
            PositionPlayersHiding(objPlayer, namePlayer)
            uiManager.DisabledInfoPlayerHiding()
            updateRespawnPlayersHiding:FireServer()
            respawnStartPlayers(character)
        end
    end
end

function StartCountdownEndGame()
    countdownEndGame = Timer.new(1, function()
        uiManager.SetInfoPlayers(tostring(countdown))
        countdown -= 1
        
        if countdown == 0 then
            print("Es hora de reiniciar el juego con los players en escena ", game.localPlayer.character)
            uiManager.SetInfoPlayers('The game has ended, restarting.')

            Timer.After(2, function()
                resetNetworkValuesGame:FireServer()
                RespawnAllPlayersInGame(game.localPlayer.character, game.localPlayer.name)
                countdownEndGame:Stop()
            end)
        end
    end, true)
end

--Unity Functions
function self:ClientAwake()
    uiManager = managerGame.UIManagerGlobal:GetComponent("UI_Hide_Seek")

    startCountdownAllClients:Connect(function()
        uiManager.SetInfoPlayers('10')
        StartCountdownEndGame()
    end)

    endCountdownAllClients:Connect(function()
        if game.localPlayer.name == managerGame.whoIsSeeker.value then
            uiManager.SetInfoPlayers("Players Found: " .. tostring(managerGame.numPlayersFound.value) .. '/' .. tostring(managerGame.numPlayerHidingCurrently.value))
        else
            uiManager.DisabledInfoPlayerHiding()
        end

        countdown = 9
        if countdownEndGame then countdownEndGame:Stop() end
    end)
end

function self:ServerAwake()
    resetNetworkValuesGame:Connect(function(player : Player)
        --managerGame.numRespawnPlayerHiding.value = 1
        managerGame.numPlayersFound.value = 0
    end)

    updateRespawnPlayersHiding:Connect(function(player : Player)
        managerGame.numRespawnPlayerHiding.value += 1

        if managerGame.numRespawnPlayerHiding.value >= 5 then
            managerGame.numRespawnPlayerHiding.value = 1
        end
    end)
end

function self:ServerUpdate()
    if managerGame.numPlayersFound.value == managerGame.numPlayerHidingCurrently.value and not managerGame.isFirstReleaseSeeker.value then
        if not isCreatedCoroutine then
            startCountdownAllClients:FireAllClients()
            isCreatedCoroutine = true
        end
    elseif isCreatedCoroutine and not managerGame.isFirstReleaseSeeker.value then
        endCountdownAllClients:FireAllClients()
        isCreatedCoroutine = false
    end
end