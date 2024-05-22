--Managers
local managerGame = require('ManagerGame')
local countdownGame = require('CountdownGame')

--Local Variables
local parentObj = self.gameObject
local scriptPlayersInScene = nil
local scriptCreateMapRandomly = nil
local respawnLobby : GameObject = nil
local lobbyRoom : GameObject = nil
local worldRoom : GameObject = nil
local cameraManagerHiding = nil
local cameraManagerSeeker = nil
local uiManager = nil
local localCharacterInstantiatedEvent = nil

--Public Variables
--!SerializeField
local minNumPlayers : number = 3

--Network Value
local amountPlayers = IntValue.new('AmountPlayersLobby', 0)
local hasSentPlayersToGame = BoolValue.new('HasSentPlayersToGame', false)
local chosenPlayer = StringValue.new('ChosenPlayer', '')
local updateSelectNewMap = BoolValue.new('UpdateSelectNewMap', true)

--Event
local eventSendPlayerToLobbyServer = Event.new("EventSendPlayerToLobbyServer")
local eventSendPlayerToLobbyClient = Event.new("EventSendPlayerToLobbyClient")
local timeBeforeStartGameLobby = Event.new("TimeBeforeStartGameLobby")
local stopTimeBeforeStartGame = Event.new("StopTimeBeforeStartGame")
local sendPlayersPointRespawnServer = Event.new("SendPlayersPointRespawnServer")
local sendPlayersPointRespawnClient = Event.new("SendPlayersPointRespawnClient")
local updateHasSentPlayerToGame = Event.new("UpdateHasSentPlayerToGame")
local eventFoundNumPlayersInLobby = Event.new("PlayersInLobby")

local function numPlayersInLobby()
    local numPlayers = 0

    for namePlayer, objPlayer in pairs(managerGame.objsCustome) do
        if not objPlayer and tostring(objPlayer) == 'null' then continue end
        if numPlayers == 0 then chosenPlayer.value = namePlayer end
        numPlayers += 1
    end

    return numPlayers
end

local function textInterface()
    uiManager.timeCurrent = ''
    uiManager.SetInfoPlayers('Waiting for 3 players to start the game')
end

function sendPlayersToLobby(character : Character, namePlayer : string)
    character.gameObject.transform.position = respawnLobby.transform.position
    character:MoveTo(respawnLobby.transform.position, 6, function()end)
end

function settingLobbyPlayer(endGame : boolean)
    lobbyRoom:SetActive(true)
    worldRoom:SetActive(false)
    managerGame.activateNavMeshLobby()

    if localCharacterInstantiatedEvent then
        localCharacterInstantiatedEvent:Disconnect()
        localCharacterInstantiatedEvent = nil
    end

    textInterface()
    eventFoundNumPlayersInLobby:FireServer()
    if hasSentPlayersToGame.value and endGame then
        updateHasSentPlayerToGame:FireServer()
    end
end

function self:ClientAwake()
    scriptPlayersInScene = parentObj:GetComponent("PlayersInScene")
    scriptCreateMapRandomly = parentObj:GetComponent("CreateMapRandomly")
    uiManager = managerGame.UIManagerGlobal:GetComponent("UI_Hide_Seek")
    cameraManagerSeeker = managerGame.CameraManagerGlobal:GetComponent("CameraManager")
    cameraManagerHiding = managerGame.CameraManagerGlobal:GetComponent("MyRTSCam")
    respawnLobby = managerGame.pointRespawnLobbyGlobal
    lobbyRoom = managerGame.lobbyRoomGlobal
    worldRoom = managerGame.worldRoomGlobal

    localCharacterInstantiatedEvent = client.localPlayer.CharacterChanged:Connect(function(player, character)
        if character then
            cameraManagerSeeker.enabled = true
            cameraManagerHiding.enabled = false
            cameraManagerSeeker.charPlayer = character

            settingLobbyPlayer(false)

            eventSendPlayerToLobbyServer:FireServer(character, player.name)
        end
    end)

    eventSendPlayerToLobbyClient:Connect(function(character, namePlayer)
        sendPlayersToLobby(character, namePlayer)
        sendPlayersPointRespawnServer:FireServer(character, game.localPlayer.name)
    end)

    sendPlayersPointRespawnClient:Connect(function(character, namePlayer)
        if game.localPlayer.name ~= namePlayer then
            sendPlayersToLobby(character, namePlayer)
        end
    end)

    timeBeforeStartGameLobby:Connect(function()
        if updateSelectNewMap.value then
            scriptCreateMapRandomly.resetChosenMap:FireServer()
            updateSelectNewMap.value = false
        end
        countdownGame.StartCountdownGoGameLobby(uiManager, chosenPlayer.value)
    end)

    stopTimeBeforeStartGame:Connect(function()
        textInterface()
        countdownGame.StopCountdownGoGameLobby()
    end)
end

function self:ServerAwake()
    eventSendPlayerToLobbyServer:Connect(function(player : Player, character, namePlayer)
        eventSendPlayerToLobbyClient:FireAllClients(character, namePlayer)
    end)

    eventFoundNumPlayersInLobby:Connect(function(player : Player)
        amountPlayers.value = numPlayersInLobby()
    end)

    sendPlayersPointRespawnServer:Connect(function(player : Player, character, namePlayer)
        sendPlayersPointRespawnClient:FireAllClients(character, namePlayer)
    end)

    updateHasSentPlayerToGame:Connect(function(player : Player)
        hasSentPlayersToGame.value = false
    end)

    server.PlayerDisconnected:Connect(function(player : Player)
        amountPlayers.value = numPlayersInLobby()
    end)
end

function self:ServerUpdate()
    if amountPlayers.value >= minNumPlayers and not hasSentPlayersToGame.value and not countdownGame.playersWentSentToGame.value then
        timeBeforeStartGameLobby:FireAllClients()
        hasSentPlayersToGame.value = true
    end

    if amountPlayers.value < minNumPlayers and hasSentPlayersToGame.value and not countdownGame.playersWentSentToGame.value then
        stopTimeBeforeStartGame:FireAllClients()
        countdownGame.resetCountdowns()
        hasSentPlayersToGame.value = false
    end
end

function self:ClientUpdate()
    if countdownGame.endCountdownGoGameLobby.value then
        scriptPlayersInScene.sendInfoAssignRoles(
            game.localPlayer.character, 
            game.localPlayer.name, 
            amountPlayers.value,
            chosenPlayer.value
        )
        scriptCreateMapRandomly.createMap(game.localPlayer.name)
        lobbyRoom:SetActive(true)
        worldRoom:SetActive(true)
        managerGame.lockedPlayerSeeker()
        countdownGame.endCountdownGoGameLobby.value = false
    end
end