--Modules
local managerGame = require("ManagerGame")
local audioManager = require("AudioManager")

--Variables
local pointRespawnHiddenPlayers : GameObject = nil
local uiManager = nil
local isCreatedCoroutine = false
local countdown = 9
local countdownEndGame = nil

--Events
local startCountdownAllClients = Event.new("StartCountdownEndGame")
local endCountdownAllClients = Event.new("EndCountdownGame")
local resetNetworkValuesGame = Event.new("ResetNetworkValuesGame")
local updateRespawnPlayersHiding = Event.new("UpdateRespawnPlayersHiding")
local sendRestPlayersRestartServer = Event.new("SendRestPlayersRestartServer")
local sendRestPlayersRestartClient = Event.new("SendRestPlayersRestartClient")

--Functions
function respawnStartPlayers(namePlayer, character : Character, pointRespawnPlayers)
    character:Teleport(pointRespawnPlayers.transform.position, function()end)
end

function activateMenuSelectedModelHide(player, namePlayer, numStandCustome)
    if managerGame.playersTag[namePlayer] == "Hiding" then
        managerGame.activateMenuModelHide(true, numStandCustome)
    end
end

function ActivateMenuSelectedCustomePlayerHiding(charPlayer, namePlayer)
    if managerGame.numRespawnPlayerHiding.value == 3 or managerGame.numRespawnPlayerHiding.value == 4 then
        activateMenuSelectedModelHide(charPlayer, namePlayer, 3)
        managerGame.standCustomePlayers[namePlayer] = 3
    else
        activateMenuSelectedModelHide(charPlayer, namePlayer, managerGame.numRespawnPlayerHiding.value)
        managerGame.standCustomePlayers[namePlayer] = managerGame.numRespawnPlayerHiding.value
    end
end

function SeekerSeeingHiddenPlayersAgain()
    for namePlayer : string, objPlayer : GameObject in pairs(managerGame.objsCustome) do
        if objPlayer == nil and namePlayer == managerGame.whoIsSeeker.value then continue end
        objPlayer:SetActive(true)
    end
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
        managerGame.releasePlayerServer:FireServer(managerGame.whoIsSeeker.value, Vector3.new(0.1, 1.5, -0.6))
    end
end

function RespawnAllPlayersInGame(character, namePlayer)
    local objPlayer = managerGame.objsCustome[namePlayer]

    if objPlayer then
        pointRespawnHiddenPlayers = managerGame.pointsRespawnPlayerHiderGlobal[managerGame.numRespawnPlayerHiding.value]

        if namePlayer == managerGame.whoIsSeeker.value then
            SeekerSeeingHiddenPlayersAgain() --Seeker seeing the hidden players again 
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
                resetNetworkValuesGame:FireServer()
                RespawnAllPlayersInGame(game.localPlayer.character, game.localPlayer.name)
            end)

            if countdownEndGame then countdownEndGame:Stop() end
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
        managerGame.numPlayersFound.value = 0
        managerGame.isFirstReleaseSeeker.value = true
        managerGame.tagPlayerFound = {}
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
end

function self:ServerUpdate()
    if managerGame.numPlayersFound.value == managerGame.numPlayerHidingCurrently.value and not managerGame.isFirstReleaseSeeker.value then
        if not isCreatedCoroutine then
            startCountdownAllClients:FireAllClients()
            audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
            isCreatedCoroutine = true
        end
    elseif isCreatedCoroutine and not managerGame.isFirstReleaseSeeker.value then
        endCountdownAllClients:FireAllClients()
        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
        isCreatedCoroutine = false
    end
end