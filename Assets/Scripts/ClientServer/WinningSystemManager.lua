--Modules
local managerGame = require("ManagerGame")
local audioManager = require("AudioManager")

--Variables
local pointRespawnHiddenPlayers : GameObject = nil
local uiManager = nil
local isCreatedCoroutine = false
local countdown = 9
local countdownEndGame : Timer = nil
local cameraManagerHiding = nil

--Events
local startCountdownAllClients = Event.new("StartCountdownEndGame")
local endCountdownAllClients = Event.new("EndCountdownGame")
local resetNetworkValuesGame = Event.new("ResetNetworkValuesGame")
local updateRespawnPlayersHiding = Event.new("UpdateRespawnPlayersHiding")
local sendRestPlayersRestartServer = Event.new("SendRestPlayersRestartServer")
local sendRestPlayersRestartClient = Event.new("SendRestPlayersRestartClient")
local restartGameLeaveSeekerPlayer = Event.new("RestartGameLeaveSeekerPlayer")
local updateWhoIsNewSeeker = Event.new('UpdateWhoIsNewSeeker')

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

        local positionPlayerRespawn = character.gameObject.transform.position
        cameraManagerHiding.CenterOn(positionPlayerRespawn)
    end
    
    SeekerSeeingHiddenPlayersAgain() --Seeker seeing the hidden players again
    resetNetworkValuesGame:FireServer()
end

function activateMenuSelectedModelHide(player, namePlayer, numStandCustome, numRoad)
    if managerGame.playersTag[namePlayer] == "Hiding" then
        managerGame.activateMenuModelHide(true, numStandCustome, numRoad)
    end
end

function ActivateMenuSelectedCustomePlayerHiding(charPlayer, namePlayer)
    if managerGame.numRespawnPlayerHiding.value == 3 or managerGame.numRespawnPlayerHiding.value == 4 then
        activateMenuSelectedModelHide(charPlayer, namePlayer, 3, managerGame.numRespawnPlayerHiding.value)
        managerGame.standCustomePlayers[namePlayer] = 3
    else
        activateMenuSelectedModelHide(charPlayer, namePlayer, managerGame.numRespawnPlayerHiding.value, managerGame.numRespawnPlayerHiding.value)
        managerGame.standCustomePlayers[namePlayer] = managerGame.numRespawnPlayerHiding.value
    end

    managerGame.roadToPedestalCustom[namePlayer] = managerGame.numRespawnPlayerHiding.value
end

function ResetFireFlyPlayerSeeker()
    managerGame.playerPetGlobal:SetActive(false)
    managerGame.playerPetGlobal:GetComponent("DetectingCollisions").enabled = false
end

function ResetGhostPlayerSeeker()
    managerGame.playerPetGlobal:GetComponent("DetectingCollisions").ghost:SetActive(false)
    managerGame.playerPetGlobal:GetComponent("DetectingCollisions").isAddedGhost = false
    managerGame.playerPetGlobal:GetComponent("DetectingCollisions").ghostFollowingSeeker = false
end

function ReleasePlayerSeeker()
    if managerGame.numPlayerHidingCurrently.value >= 2 and managerGame.isFirstReleaseSeeker.value then
        managerGame.releasePlayerServer:FireServer(
            managerGame.whoIsSeeker.value, 
            Vector3.new(0.1, 1.5, -0.6),
            Vector3.new(0, 55, 0)
        )
    end
end

function RespawnAllPlayersInGame(character, namePlayer)
    local objPlayer = managerGame.objsCustome[namePlayer]

    if objPlayer then
        pointRespawnHiddenPlayers = managerGame.pointsRespawnPlayerHiderGlobal[managerGame.numRespawnPlayerHiding.value]

        if namePlayer == managerGame.whoIsSeeker.value then 
            ResetFireFlyPlayerSeeker() --Reset the firefly
            ResetGhostPlayerSeeker() --Reset the ghost
            
            managerGame.lockedPlayerSeeker() --Locked player seeker for 10 seconds

            respawnStartPlayers(namePlayer, character, managerGame.pointRespawnPlayerSeekerGlobal)
            sendRestPlayersRestartServer:FireServer(namePlayer, character, "Seeker")
            
            Timer.After(20, ReleasePlayerSeeker) --Release player seeker
        else
            uiManager.DisabledInfoPlayerHiding()
            updateRespawnPlayersHiding:FireServer()
            ActivateMenuSelectedCustomePlayerHiding(objPlayer, namePlayer)
            
            respawnStartPlayers(namePlayer, character, pointRespawnHiddenPlayers)
            sendRestPlayersRestartServer:FireServer(namePlayer, character, "Hidden")
        end
    end
end

function StartCountdownEndGame()
    countdownEndGame = Timer.new(1, function()
        uiManager.SetInfoPlayers(tostring(countdown))
        countdown -= 1
        
        if countdown == 0 then
            uiManager.SetInfoPlayers('The game has ended, restarting.')

            Timer.After(2, function()
                RespawnAllPlayersInGame(game.localPlayer.character, game.localPlayer.name)
            end)

            countdown = 9
            if countdownEndGame then countdownEndGame:Stop() end
        end
    end, true)
end

--Unity Functions
function self:ClientAwake()
    uiManager = managerGame.UIManagerGlobal:GetComponent("UI_Hide_Seek")
    cameraManagerHiding = managerGame.CameraManagerGlobal:GetComponent("MyRTSCam")

    startCountdownAllClients:Connect(function()
        uiManager.SetInfoPlayers('10')
        StartCountdownEndGame()
    end)

    --Esto es nuevo y estamos revisando que pasa cuando el seeker sale del juego sea durante el juego o cuando este el contador de fin de juego - Jhalexso
    restartGameLeaveSeekerPlayer:Connect(function(newSeeker)
        local saveAllPlayerGame = {}
        local indexPlayer = 1

        for namePlayer : string, objPlayer : GameObject in pairs(managerGame.objsCustome) do
            if objPlayer == nil or tostring(objPlayer) == 'null' then continue end
            
            saveAllPlayerGame[indexPlayer] = namePlayer
            indexPlayer += 1
        end

        local scriptPlayersInScene = self.gameObject:GetComponent('PlayersInScene')
        scriptPlayersInScene.selectNewSeeker(saveAllPlayerGame[newSeeker], 'Seeker')

        updateWhoIsNewSeeker:FireServer(saveAllPlayerGame[newSeeker])

        RespawnAllPlayersInGame(game.localPlayer.character, game.localPlayer.name)

        countdown = 9
        if countdownEndGame then countdownEndGame:Stop() end
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
    resetNetworkValuesGame:Connect(function(player : Player)
        managerGame.isFirstReleaseSeeker.value = true
        managerGame.tagPlayerFound = {}
        managerGame.numPlayersFound.value = 0
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
        managerGame.numPlayerHidingCurrently.value -= 1
    end)
end

function self:ServerUpdate()
    if managerGame.numPlayersFound.value >= managerGame.numPlayerHidingCurrently.value and managerGame.hasBeginGame.value and not isCreatedCoroutine then
        startCountdownAllClients:FireAllClients()
        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
        managerGame.hasBeginGame.value = false
        isCreatedCoroutine = true
    elseif managerGame.numPlayersFound.value < managerGame.numPlayerHidingCurrently.value and isCreatedCoroutine then
        endCountdownAllClients:FireAllClients()
        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
        isCreatedCoroutine = false
    end

    --Esto es nuevo y estamos revisando que pasa cuando el seeker sale del juego sea durante el juego o cuando este el contador de fin de juego - Jhalexso
    if managerGame.whoIsSeeker.value == "" and managerGame.hasBeginGame.value then
        local numChooseNewSeeker = math.random(1, managerGame.numPlayerHidingCurrently.value)
        restartGameLeaveSeekerPlayer:FireAllClients(numChooseNewSeeker)
        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
        isCreatedCoroutine = false
    end
end