--Modules
local managerGame = require("ManagerGame")
local countdownGame = require("CountdownGame")

--Variables no publics
local pointRespawnPlayerHider : GameObject = nil
local playerPet : GameObject = nil
local charPlayer : GameObject = nil
local uiManager = nil
local infoGameModule = nil
local rolPlayer : number = 0
local rolesPlayerGame = {
    [1] = 'Seeker',
    [2] = 'Hiding'
}

--Global variables
cameraManagerSeeker = nil
cameraManagerHiding = nil

--Network Values
local player_id = StringValue.new("PlayerId", "")

--Events
local sendInfoAddZoneSeeker = Event.new("SendInfoAddZoneSeeker")
local sendActivateMenuHide = Event.new("SendActivateMenuHide")

--Functions
local function respawnStartPlayerHiding(character : Character)
    character:Teleport(pointRespawnPlayerHider.transform.position, function()end)
end

local function activateMenuSelectedModelHide(player, namePlayer, numStandCustome, numRoad)
    if managerGame.playersTag[namePlayer] == "Hiding" then
        managerGame.playerObjTag[namePlayer] = player
        managerGame.activateMenuModelHide(true, numStandCustome, numRoad)
    end
end

local function dataCountdownStart(txt)
    countdownGame.StartCountdownHiddenPlayers(
        uiManager,
        txt,
        managerGame.whoIsSeeker.value
    )
end

function countdownWaitReleasePlayer()
    if game.localPlayer.name == managerGame.whoIsSeeker.value then
        dataCountdownStart('The wait time for the game to start')
    else
        dataCountdownStart('Hurry up and choose a disguise, then hide in the environment')
    end
end

function activateGameWhenExistTwoMorePlayerHiding()
    if managerGame.numPlayerHidingCurrently.value >= 2 and managerGame.isFirstReleaseSeeker.value then
        countdownWaitReleasePlayer()
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

local function assignRolePlayers(character, namePlayer)
    if managerGame.isFirstPlayer.value then
        player_id.value = "Seeker"
        sendInfoAddZoneSeeker:FireAllClients(character, namePlayer)
        managerGame.isFirstPlayer.value = false
        managerGame.whoIsSeeker.value = namePlayer
    else
        player_id.value = "Hiding"
        managerGame.numPlayerHidingCurrently.value += 1 
        sendActivateMenuHide:FireAllClients(character, namePlayer)
        managerGame.numRespawnPlayerHiding.value += 1
        countdownGame.endCountdownGame.value = false

        if managerGame.numRespawnPlayerHiding.value == 5 then
            managerGame.numRespawnPlayerHiding.value = 1
        end

        if not managerGame.isFirstReleaseSeeker.value then
            managerGame.updateNumPlayersHiding:FireAllClients()
        end
    end
end

--Esto es nuevo y estamos revisando que pasa cuando el seeker sale del juego sea durante el juego o cuando este el contador de fin de juego - Jhalexso
function selectNewSeeker(namePlayer, id)
    managerGame.playersTag[namePlayer] = id
    managerGame.activateMenuModelHide(false, 0, 0)
    managerGame.disabledDetectingCollisionsAllPlayersServer:FireServer()

    uiManager.SetInfoPlayers(infoGameModule.SeekerTexts["Intro"])
    cameraManagerSeeker.enabled = true
    cameraManagerHiding.enabled = false
end

function activateMenuSelectedCustomePlayerHiding(charPlayer, namePlayer)
    if managerGame.numRespawnPlayerHiding.value == 3 or managerGame.numRespawnPlayerHiding.value == 4 then
        activateMenuSelectedModelHide(
            charPlayer, 
            namePlayer, 
            3, 
            managerGame.numRespawnPlayerHiding.value
        )
        managerGame.standCustomePlayers[namePlayer] = 3
    else
        activateMenuSelectedModelHide(
            charPlayer, 
            namePlayer, 
            managerGame.numRespawnPlayerHiding.value, 
            managerGame.numRespawnPlayerHiding.value
        )
        managerGame.standCustomePlayers[namePlayer] = managerGame.numRespawnPlayerHiding.value
    end

    managerGame.roadToPedestalCustom[namePlayer] = managerGame.numRespawnPlayerHiding.value
end

--Unity Functions
function self:ClientAwake()
    uiManager = managerGame.UIManagerGlobal:GetComponent("UI_Hide_Seek")
    cameraManagerSeeker = managerGame.CameraManagerGlobal:GetComponent("CameraManager")
    cameraManagerHiding = managerGame.CameraManagerGlobal:GetComponent("MyRTSCam")
    infoGameModule = managerGame.InfoGameModuleGlobal

    sendInfoAddZoneSeeker:Connect(function (char, namePlayer)
        if game.localPlayer.name == namePlayer then --not managerGame.playersTag[namePlayer] and client.localPlayer.name == namePlayer
            playerPet = managerGame.playerPetGlobal
            pointRespawnPlayerHider = managerGame.pointsRespawnPlayerHiderGlobal[managerGame.numRespawnPlayerHiding.value]
            charPlayer = char.gameObject
            
            selectNewSeeker(namePlayer, player_id.value)
            managerGame.playerObjTag[namePlayer] = charPlayer
        end

        Timer.After(5, mustWaitForPlayers)
    end)

    sendActivateMenuHide:Connect(function (char, namePlayer)
        pointRespawnPlayerHider = managerGame.pointsRespawnPlayerHiderGlobal[managerGame.numRespawnPlayerHiding.value]
        
        if game.localPlayer.name == namePlayer then
            charPlayer = char.gameobject
            managerGame.playersTag[namePlayer] = player_id.value
            
            activateMenuSelectedCustomePlayerHiding(charPlayer, namePlayer)
            uiManager.SetInfoPlayers(infoGameModule.HiderTexts["Intro"])

            Timer.After(6, function() uiManager.DisabledInfoPlayerHiding() end)
            cameraManagerSeeker.enabled = false
            cameraManagerHiding.enabled = true
        end

        activateGameWhenExistTwoMorePlayerHiding()

        if managerGame.whoIsSeeker.value == game.localPlayer.name then
            mustWaitForPlayers()
        end
        
        respawnStartPlayerHiding(char)
    end)
end

function self:ServerAwake()
    server.PlayerConnected:Connect(function(player : Player)
        player.CharacterChanged:Connect(function(player : Player, character : Character)
            assignRolePlayers(character, player.name)
        end)
    end)
end

function self:Update()
    if countdownGame.endCountdownHiddenPlayers then
        managerGame.releasePlayerServer:FireServer(
            managerGame.whoIsSeeker.value, 
            Vector3.new(0.1, 1.5, -0.6), 
            Vector3.new(0, 55, 0)
        )

        if game.localPlayer.name ~= managerGame.whoIsSeeker.value then
            uiManager.DisabledInfoPlayerHiding()
        end

        countdownGame.StartCountdownGame(uiManager, managerGame.whoIsSeeker.value)
        countdownGame.endCountdownHiddenPlayers = false
    end
end