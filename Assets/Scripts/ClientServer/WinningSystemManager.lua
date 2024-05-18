--Modules
local managerGame = require("ManagerGame")
local audioManager = require("AudioManager")
local countdownGame = require("CountdownGame")

--Variables
local gameObjectParent = self.gameObject
local scriptPlayersInScene = nil
local detectingCollisions = nil
local uiManager = nil
local isCreatedCoroutine = false

--Events
local startCountdownAllClients = Event.new("StartCountdownEndGame") -- Event for when the game to finished
local endCountdownAllClients = Event.new("EndCountdownGame") -- Event for when the end game has been stopped
local resetNetworkValuesGame = Event.new("ResetNetworkValuesGame") -- Event for reset all network values before start the game
local sendRestPlayersRestartServer = Event.new("SendRestPlayersRestartServer") -- Event to the server for indicate to the rest players where respawn the player current
local sendRestPlayersRestartClient = Event.new("SendRestPlayersRestartClient") -- Event to the client for indicate to the rest players where respawn the player current
local restartGameLeaveSeekerPlayer = Event.new("RestartGameLeaveSeekerPlayer") -- Event to restart the game when the seeker player leave the game
local eventRespawnAllPlayers = Event.new('EventRespawnAllPlayers') -- Event fired when the end game time has finished, respawn all players to the lobby
local eventUpdateCountdownBeforeEndGame = Event.new('EventUpdateCountdownBeforeEndGame') -- Event to update end game countdown to the finish the game

--Functions
function SeekerSeeingHiddenPlayersAgain()
    for namePlayer : string, objPlayer : GameObject in pairs(managerGame.objsCustome) do
        if objPlayer == nil or tostring(objPlayer) == 'null' or namePlayer == managerGame.whoIsSeeker.value then continue end
        objPlayer:SetActive(true)
    end
end

function respawnStartPlayers(namePlayer, character : Character)
    character.gameObject.transform.position = managerGame.pointRespawnLobbyGlobal.transform.position
    character:MoveTo(managerGame.pointRespawnLobbyGlobal.transform.position, 6, function()end)
    
    scriptPlayersInScene.cameraManagerSeeker.enabled = true
    scriptPlayersInScene.cameraManagerHiding.enabled = false
end

function RespawnAllPlayersInGame(character, namePlayer)
    self.gameObject:GetComponent('PlayersToLobby').settingLobbyPlayer(true)
    respawnStartPlayers(namePlayer, character)
    SeekerSeeingHiddenPlayersAgain()
    sendRestPlayersRestartServer:FireServer(namePlayer, character)
end

--Unity Functions
function self:ClientAwake()
    uiManager = managerGame.UIManagerGlobal:GetComponent("UI_Hide_Seek")
    scriptPlayersInScene = gameObjectParent:GetComponent('PlayersInScene')
    detectingCollisions = managerGame.playerPetGlobal:GetComponent("DetectingCollisions")

    startCountdownAllClients:Connect(function()
        managerGame.playerPetGlobal:SetActive(true)
        if game.localPlayer.name == managerGame.whoIsSeeker.value then
            detectingCollisions.ResetGhostPlayerSeeker() --Reset the ghost
            detectingCollisions.ResetFireFlyPlayerSeeker() --Reset the firefly
        else
            detectingCollisions.enabled = true
            Timer.After(0.15, function()
                detectingCollisions.ResetGhostPlayerSeeker() --Reset the ghost
                detectingCollisions.ResetFireFlyPlayerSeeker() --Reset the firefly
                detectingCollisions.enabled = false
            end)
        end

        countdownGame.StartCountdownEndGame(uiManager, managerGame.whoIsSeeker.value)
        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
    end)

    eventRespawnAllPlayers:Connect(function()
        RespawnAllPlayersInGame(game.localPlayer.character, game.localPlayer.name)
    end)

    restartGameLeaveSeekerPlayer:Connect(function(newSeeker)
        resetNetworkValuesGame:FireServer(game.localPlayer.name)
        managerGame.playerPetGlobal:SetActive(false)
        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
    end)

    endCountdownAllClients:Connect(function()
        if game.localPlayer.name == managerGame.whoIsSeeker.value then
            uiManager.SetInfoPlayers("Players Found: " .. tostring(managerGame.numPlayersFound.value) .. '/' .. tostring(managerGame.numPlayerHidingCurrently.value))
        else
            uiManager.DisabledInfoPlayerHiding()
        end
        
        managerGame.playerPetGlobal:SetActive(true)
        eventUpdateCountdownBeforeEndGame:FireServer()
        countdownGame.StopTimerEndGame()
        countdownGame.StartCountdownGame(uiManager, managerGame.whoIsSeeker.value)
        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
    end)

    sendRestPlayersRestartClient:Connect(function(namePlayer, character)
        if namePlayer ~= game.localPlayer.name then
            respawnStartPlayers(namePlayer, character)
        end
    end)
end

function self:ServerAwake()
    resetNetworkValuesGame:Connect(function(player : Player, namePlayer)
        managerGame.isFirstReleaseSeeker.value = true
        managerGame.tagPlayerFound = {}
        managerGame.playersTag = {}
        managerGame.playerObjTag = {}
        managerGame.numPlayersFound.value = 0
        managerGame.numPlayerHidingCurrently.value = 0
        managerGame.wasCalculatedRandomMap.value = false
        managerGame.opcMap.value = 1
        managerGame.cleanCustomeWhenPlayerLeftGameClient:FireAllClients(namePlayer)

        countdownGame.endCountdownGame.value = false
        countdownGame.playersWentSentToGame.value = false
        managerGame.hasBeginGame.value = false
        managerGame.whoIsSeeker.value = ''

        isCreatedCoroutine = false
        eventRespawnAllPlayers:FireAllClients()
    end)

    sendRestPlayersRestartServer:Connect(function(player : Player, namePlayer, character)
        sendRestPlayersRestartClient:FireAllClients(namePlayer, character)
    end)

    eventUpdateCountdownBeforeEndGame:Connect(function(player : Player)
        countdownGame.countdown.value = 10
    end)
end

function self:ServerUpdate()
    if (managerGame.numPlayersFound.value >= managerGame.numPlayerHidingCurrently.value or countdownGame.endCountdownGame.value) and managerGame.hasBeginGame.value and not isCreatedCoroutine then
        print(`Comienzo del fin de juego`)
        startCountdownAllClients:FireAllClients()
        isCreatedCoroutine = true
        managerGame.hasBeginGame.value = false
    elseif managerGame.numPlayersFound.value < managerGame.numPlayerHidingCurrently.value and isCreatedCoroutine and not countdownGame.endCountdownGame.value and not managerGame.hasBeginGame.value then
        print(`Nuevo jugador ingresando al juego`)
        endCountdownAllClients:FireAllClients()
        isCreatedCoroutine = false
        managerGame.hasBeginGame.value = true
    end

    if (managerGame.whoIsSeeker.value == "" or managerGame.numPlayerHidingCurrently.value <= 0)  and (managerGame.hasBeginGame.value or countdownGame.playersWentSentToGame.value) then
        print(`Reiniciando el juego - todos al lobby`)
        restartGameLeaveSeekerPlayer:FireAllClients()
        managerGame.hasBeginGame.value = false
    end

    if managerGame.numPlayersFound.value < 0 then
        managerGame.numPlayersFound.value = 0
    end
end

function self:ClientUpdate()
    if countdownGame.startingCountdownEndGame.value then
        print(`Comienzo del fin de juego - Enviado a todos al lobby`)
        resetNetworkValuesGame:FireServer(game.localPlayer.name)
        countdownGame.startingCountdownEndGame.value = false
    end
end