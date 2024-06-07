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
local costumePlayerCurrent = {}

--Public Variables
--!SerializeField
local minNumPlayers : number = 3

--Network Value
local amountPlayers = IntValue.new('AmountPlayersLobby', 0)
local hasSentPlayersToGame = BoolValue.new('HasSentPlayersToGame', false)
local chosenPlayer = StringValue.new('ChosenPlayer', '')

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

function sendPlayersToLobby(character : Character, namePlayer : string, objCharacter : GameObject)
    objCharacter.transform.position = respawnLobby.transform.position
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
    scriptPlayersInScene = parentObj:GetComponent(PlayersInScene)
    scriptCreateMapRandomly = parentObj:GetComponent(CreateMapRandomly)
    uiManager = managerGame.UIManagerGlobal:GetComponent(UI_Hide_Seek)
    cameraManagerSeeker = managerGame.CameraManagerGlobal:GetComponent(CameraManager)
    cameraManagerHiding = managerGame.CameraManagerGlobal:GetComponent(MyRTSCam)
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
        sendPlayersToLobby(character, namePlayer, managerGame.objsCustome[namePlayer])
        sendPlayersPointRespawnServer:FireServer(game.localPlayer.name, namePlayer)
    end)

    sendPlayersPointRespawnClient:Connect(function(namePlayer, namePlayerNew)
        --print(`Name: {namePlayer} - Local: {game.localPlayer.name} - New: {namePlayerNew}`)
        if game.localPlayer.name ~= namePlayer then
            sendPlayersToLobby(managerGame.previousPlayers[namePlayer], namePlayer, managerGame.objsCustome[namePlayer])
        end
        --[[ if namePlayer ~= namePlayerNew and game.localPlayer.name == namePlayerNew then
            print(`Player: {game.localPlayer.name}`)
            print(`Custome: {managerGame.customePlayers[game.localPlayer.name]}`)
            print(`Costume Server: {costumePlayerCurrent[game.localPlayer.name]}`)
            if managerGame.customePlayers[game.localPlayer.name] then 
                print(`Dress: {managerGame.customePlayers[game.localPlayer.name]['Dress']}`)
                managerGame.addCostumePlayers(
                    managerGame.customePlayers[game.localPlayer.name]['Dress'], 
                    game.localPlayer.character.gameObject, 
                    managerGame.customePlayers[game.localPlayer.name]['Offset'], 
                    managerGame.customePlayers[game.localPlayer.name]['Rotation'], 
                    "Hiding",
                    game.localPlayer.name
                )
            end
        end ]]
    end)

    timeBeforeStartGameLobby:Connect(function()
        scriptCreateMapRandomly.resetChosenMap:FireServer()
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

    sendPlayersPointRespawnServer:Connect(function(player : Player, namePlayer, namePlayerNew)
        if managerGame.playersTag[namePlayer] == nil then
            sendPlayersPointRespawnClient:FireAllClients(namePlayer, namePlayerNew)
        end
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