--Modules
local managerGame = require("ManagerGame")
local audioManager = require("AudioManager")
local countdownGame = require("CountdownGame")

--Variables
local gameObjectParent = self.gameObject
local scriptPlayersInScene = nil
local detectingCollisions = nil
local pointRespawnHiddenPlayers : GameObject = nil
local uiManager = nil
local isCreatedCoroutine = false

--Events
local startCountdownAllClients = Event.new("StartCountdownEndGame")
local endCountdownAllClients = Event.new("EndCountdownGame")
local resetNetworkValuesGame = Event.new("ResetNetworkValuesGame")
local updateRespawnPlayersHiding = Event.new("UpdateRespawnPlayersHiding")
local sendRestPlayersRestartServer = Event.new("SendRestPlayersRestartServer")
local sendRestPlayersRestartClient = Event.new("SendRestPlayersRestartClient")
local restartGameLeaveSeekerPlayer = Event.new("RestartGameLeaveSeekerPlayer")
local updateWhoIsNewSeeker = Event.new('UpdateWhoIsNewSeeker')
local eventRespawnAllPlayers = Event.new('EventRespawnAllPlayers')
local eventUpdateCountdownBeforeEndGame = Event.new('EventUpdateCountdownBeforeEndGame')

--Functions
function SeekerSeeingHiddenPlayersAgain()
    for namePlayer : string, objPlayer : GameObject in pairs(managerGame.objsCustome) do
        if objPlayer == nil or tostring(objPlayer) == 'null' or namePlayer == managerGame.whoIsSeeker.value then continue end
        objPlayer:SetActive(true)
    end
end

function respawnStartPlayers(namePlayer, character : Character, pointRespawnPlayers)
    if not character or not pointRespawnPlayers then return end
    character:Teleport(pointRespawnPlayers.transform.position, function()end)
    
    if namePlayer ~= managerGame.whoIsSeeker.value then
        if not character.gameObject or tostring(character.gameObject) == 'null' then return end
        if not scriptPlayersInScene.cameraManagerHiding then return end

        local positionPlayerRespawn = character.gameObject.transform.position
        scriptPlayersInScene.cameraManagerHiding.CenterOn(positionPlayerRespawn, 15)
    end
    
    SeekerSeeingHiddenPlayersAgain() --Seeker seeing the hidden players again
    resetNetworkValuesGame:FireServer(namePlayer)
end

function RespawnAllPlayersInGame(character, namePlayer)
    local objPlayer = managerGame.objsCustome[namePlayer]

    if objPlayer then
        pointRespawnHiddenPlayers = managerGame.pointsRespawnPlayerHiderGlobal[managerGame.numRespawnPlayerHiding.value]

        if namePlayer == managerGame.whoIsSeeker.value then     
            managerGame.lockedPlayerSeeker() --Locked player seeker for 10 seconds
            respawnStartPlayers(namePlayer, character, managerGame.pointRespawnPlayerSeekerGlobal)
            sendRestPlayersRestartServer:FireServer(namePlayer, character, "Seeker")
        else
            uiManager.DisabledInfoPlayerHiding()
            updateRespawnPlayersHiding:FireServer()
            scriptPlayersInScene.activateMenuSelectedCustomePlayerHiding(objPlayer, namePlayer)
            
            respawnStartPlayers(namePlayer, character, pointRespawnHiddenPlayers)
            sendRestPlayersRestartServer:FireServer(namePlayer, character, "Hidden")
        end
    end
end

--Unity Functions
function self:ClientAwake()
    uiManager = managerGame.UIManagerGlobal:GetComponent("UI_Hide_Seek")
    scriptPlayersInScene = gameObjectParent:GetComponent('PlayersInScene')
    detectingCollisions = managerGame.playerPetGlobal:GetComponent("DetectingCollisions")
    
    startCountdownAllClients:Connect(function()
        detectingCollisions.ResetFireFlyPlayerSeeker() --Reset the firefly
        detectingCollisions.ResetGhostPlayerSeeker() --Reset the ghost
        countdownGame.StartCountdownEndGame(uiManager, managerGame.whoIsSeeker.value)
    end)

    eventRespawnAllPlayers:Connect(function()
        countdownGame.resetAllParameters()
        uiManager.DisabledInfoPlayerHiding()
        Timer.After(1, function()
            scriptPlayersInScene.countdownWaitReleasePlayer()
        end)
        RespawnAllPlayersInGame(game.localPlayer.character, game.localPlayer.name)
    end)

    --Esto es nuevo y estamos revisando que pasa cuando el seeker sale del juego sea durante el juego o cuando este el contador de fin de juego - Jhalexso
    restartGameLeaveSeekerPlayer:Connect(function(newSeeker)
        eventUpdateCountdownBeforeEndGame:FireServer()
        countdownGame.StopTimerEndGame()

        local saveAllPlayerGame = {}
        local indexPlayer = 1

        for namePlayer : string, objPlayer : GameObject in pairs(managerGame.objsCustome) do
            if objPlayer == nil or tostring(objPlayer) == 'null' then continue end
            
            saveAllPlayerGame[indexPlayer] = namePlayer
            indexPlayer += 1
        end

        if saveAllPlayerGame[newSeeker] == game.localPlayer.name then
            scriptPlayersInScene.selectNewSeeker(saveAllPlayerGame[newSeeker], "Seeker")
        end

        updateWhoIsNewSeeker:FireServer(saveAllPlayerGame[newSeeker])

        RespawnAllPlayersInGame(game.localPlayer.character, game.localPlayer.name)
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
    end)

    sendRestPlayersRestartClient:Connect(function(namePlayer, character, typePlayer)
        if namePlayer ~= game.localPlayer.name then
            if typePlayer == "Seeker" then
                respawnStartPlayers(namePlayer, character, managerGame.pointRespawnPlayerSeekerGlobal)
            elseif typePlayer == "Hidden" then
                respawnStartPlayers(namePlayer, character, pointRespawnHiddenPlayers)
            end
        end
    end)
end

function self:ServerAwake()
    resetNetworkValuesGame:Connect(function(player : Player, namePlayer)
        managerGame.isFirstReleaseSeeker.value = true
        managerGame.tagPlayerFound = {}
        managerGame.numPlayersFound.value = 0
        managerGame.cleanCustomeWhenPlayerLeftGameClient:FireAllClients(namePlayer)

        countdownGame.endCountdownGame.value = false
        countdownGame.startingCountdownEndGame.value = false

        isCreatedCoroutine = false
    end)

    updateRespawnPlayersHiding:Connect(function(player : Player)
        managerGame.numRespawnPlayerHiding.value += 1

        if managerGame.numRespawnPlayerHiding.value == 5 then
            managerGame.numRespawnPlayerHiding.value = 1
        end
    end)

    sendRestPlayersRestartServer:Connect(function(player : Player, namePlayer, character, typePlayer)
        sendRestPlayersRestartClient:FireAllClients(namePlayer, character, typePlayer)
    end)

    --Esto es nuevo y estamos revisando que pasa cuando el seeker sale del juego sea durante el juego o cuando este el contador de fin de juego - Jhalexso
    updateWhoIsNewSeeker:Connect(function(player : Player, seeker)
        managerGame.whoIsSeeker.value = seeker
        if managerGame.numPlayerHidingCurrently.value > 0 then 
            managerGame.numPlayerHidingCurrently.value -= 1
        end
    end)

    eventUpdateCountdownBeforeEndGame:Connect(function(player : Player)
        countdownGame.countdown.value = 10
    end)
end

function self:ServerUpdate()
    if (managerGame.numPlayersFound.value >= managerGame.numPlayerHidingCurrently.value or countdownGame.endCountdownGame.value) and managerGame.hasBeginGame.value and not isCreatedCoroutine then
        startCountdownAllClients:FireAllClients()
        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
        isCreatedCoroutine = true
        managerGame.hasBeginGame.value = false
    elseif managerGame.numPlayersFound.value < managerGame.numPlayerHidingCurrently.value and isCreatedCoroutine and not countdownGame.endCountdownGame.value and not managerGame.hasBeginGame.value then
        endCountdownAllClients:FireAllClients()
        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
        isCreatedCoroutine = false
        managerGame.hasBeginGame.value = true
    end

    --Esto es nuevo y estamos revisando que pasa cuando el seeker sale del juego sea durante el juego o cuando este el contador de fin de juego - Jhalexso
    if managerGame.whoIsSeeker.value == "" and managerGame.hasBeginGame.value then
        local numChooseNewSeeker = math.random(1, managerGame.numPlayerHidingCurrently.value)
        restartGameLeaveSeekerPlayer:FireAllClients(numChooseNewSeeker)
        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
        isCreatedCoroutine = false
    end

    if countdownGame.startingCountdownEndGame.value then
        eventRespawnAllPlayers:FireAllClients()
    end

    if managerGame.numPlayersFound.value < 0 then
        managerGame.numPlayersFound.value = 0
    end
end