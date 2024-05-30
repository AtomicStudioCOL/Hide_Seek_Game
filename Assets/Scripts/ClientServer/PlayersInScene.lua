--Modules
local managerGame = require("ManagerGame")
local countdownGame = require("CountdownGame")
local audioManager = require("AudioManager")

--Variables no publics
local pointRespawnPlayerHider : GameObject = nil
local pointRespawnPlayerSeeker : GameObject = nil
local uiManager = nil
local infoGameModule = nil
local rolPlayer : number = 0
local rolesPlayerGame = {
    [1] = 'Seeker',
    [2] = 'Hiding'
}
local newRoles = {}
local indexPlayer = 1
local numPlayersToGoScene = 0

--Global variables
cameraManagerSeeker = nil
cameraManagerHiding = nil

--Network Values
local player_id = StringValue.new("PlayerId", "")
local chosenSeekerPlayer = BoolValue.new("ChosenSeekerPlayer", false)
local roleRandomly = BoolValue.new("SelectRoleRandomly", true)

--Events
local sendInfoAddZoneSeeker = Event.new("SendInfoAddZoneSeeker")
local sendActivateMenuHide = Event.new("SendActivateMenuHide")
local sendInfoRoles = Event.new("SendInfoRoles")
local eventUpdatePreviousSeeker = Event.new("UpdatePreviousSeeker")

--Functions
local function respawnStartPlayerHiding(character : Character, pointRespawn)
    if not pointRespawn then return end
    character:Teleport(pointRespawn.transform.position, function()end)
    --character.gameObject.transform.position = pointRespawn.transform.position
    --character:MoveTo(pointRespawn.transform.position, 6, function()end)
end

local function dataCountdownStart(txt, playerSelected)
    countdownGame.StartCountdownHiddenPlayers(
        uiManager,
        txt,
        playerSelected
    )
end

local function selectRoleRandomly()
    if managerGame.isFirstPlayer.value then
        rolPlayer = math.random(1, 2)
    else
        rolPlayer = 2
    end
end

local function selectRolePoint(character, namePlayer, totalPlayers, playerSelected)
    if managerGame.previousSeeker.value ~= namePlayer then
        newRoles[indexPlayer] = {
            [1] = character,
            [2] = namePlayer,
            [3] = playerSelected
        }
        indexPlayer += 1
    else
        player_id.value = rolesPlayerGame[2]
        logicSendPlayersGame(character, namePlayer, totalPlayers, playerSelected)
    end
end

local function chosenRolePlayer(character, namePlayer, totalPlayers, playerSelected)
    if managerGame.previousSeeker.value == '' then
        selectRoleRandomly()

        return rolesPlayerGame[rolPlayer]
    else
        local randomSelectNewSeeker = math.random(1, totalPlayers-1)
        selectRolePoint(character, namePlayer, totalPlayers, playerSelected)
        numPlayersToGoScene += 1

        if totalPlayers == numPlayersToGoScene then
            for id, info in pairs(newRoles) do
                if id == randomSelectNewSeeker then
                    player_id.value = rolesPlayerGame[1]
                    logicSendPlayersGame(info[1], info[2], totalPlayers, info[3])
                else
                    player_id.value = rolesPlayerGame[2]
                    logicSendPlayersGame(info[1], info[2], totalPlayers, info[3])
                end
            end

            newRoles = {}
            indexPlayer = 1
            numPlayersToGoScene = 0
        end
    end
end

function countdownWaitReleasePlayer(playerSelected)
    if player_id.value == rolesPlayerGame[1] then
        dataCountdownStart('The wait time for the game to start', playerSelected)
    elseif player_id.value == rolesPlayerGame[2] then
        dataCountdownStart('Hurry up and choose a disguise, then hide in the environment', playerSelected)
    end
end

function sendInfoAssignRoles(character, namePlayer, totalPlayers, playerSelected)
    sendInfoRoles:FireServer(character, namePlayer, totalPlayers, playerSelected)
end

function logicSendPlayersGame(character, namePlayer, totalPlayers, playerSelected)
    managerGame.playersTag[namePlayer] = player_id.value

    if player_id.value == rolesPlayerGame[1] then
        sendInfoAddZoneSeeker:FireAllClients(character, namePlayer, playerSelected)
        managerGame.isFirstPlayer.value = false
        managerGame.whoIsSeeker.value = namePlayer
    elseif player_id.value == rolesPlayerGame[2] then
        managerGame.numPlayerHidingCurrently.value += 1 
        managerGame.numRespawnPlayerHiding.value += 1

        sendActivateMenuHide:FireAllClients(character, namePlayer, playerSelected)
        countdownGame.endCountdownGame.value = false

        if managerGame.numRespawnPlayerHiding.value >= 4 then
            managerGame.numRespawnPlayerHiding.value = 1
        end

        if ((managerGame.numPlayerHidingCurrently.value + 1) == totalPlayers) and managerGame.whoIsSeeker.value == '' then
            roleRandomly.value = false
        end
    end
end

function assignRolePlayers(character, namePlayer, totalPlayers, playerSelected)
    if managerGame.previousSeeker.value ~= '' then 
        chosenRolePlayer(character, namePlayer, totalPlayers, playerSelected)
        return 
    end

    if roleRandomly.value then
        player_id.value = chosenRolePlayer(character, namePlayer, totalPlayers, playerSelected)
    else
        player_id.value = rolesPlayerGame[1]
        roleRandomly.value = true
        managerGame.isFirstPlayer.value = false
    end
    
    logicSendPlayersGame(character, namePlayer, totalPlayers, playerSelected)
end

function activateMenuSelectedCustomePlayerHiding(namePlayer)
    if managerGame.numRespawnPlayerHiding.value == 3 or managerGame.numRespawnPlayerHiding.value == 4 then
        managerGame.activateMenuModelHide(true, 3, managerGame.numRespawnPlayerHiding.value)
        managerGame.standCustomePlayers[namePlayer] = 3
    else
        managerGame.activateMenuModelHide(true, managerGame.numRespawnPlayerHiding.value, managerGame.numRespawnPlayerHiding.value)
        managerGame.standCustomePlayers[namePlayer] = managerGame.numRespawnPlayerHiding.value
    end

    managerGame.roadToPedestalCustom[namePlayer] = managerGame.numRespawnPlayerHiding.value
end

function newPlayerGame(char, namePlayer, id, txt, cameraEnabled)
    managerGame.playersTag[namePlayer] = id
    uiManager.SetInfoPlayers(txt)

    if id == rolesPlayerGame[1] then
        managerGame.activateMenuModelHide(false, 0, 0)
        managerGame.disabledDetectingCollisionsAllPlayersServer:FireServer()
    elseif id == rolesPlayerGame[2] then
        Timer.After(6, function() uiManager.DisabledInfoPlayerHiding() end)
        activateMenuSelectedCustomePlayerHiding(namePlayer)
    end

    cameraManagerSeeker.enabled = cameraEnabled[rolesPlayerGame[1]]
    cameraManagerHiding.enabled = cameraEnabled[rolesPlayerGame[2]]
end

--Unity Functions
function self:ClientAwake()
    uiManager = managerGame.UIManagerGlobal:GetComponent(UI_Hide_Seek)
    cameraManagerSeeker = managerGame.CameraManagerGlobal:GetComponent(CameraManager)
    cameraManagerHiding = managerGame.CameraManagerGlobal:GetComponent(MyRTSCam)
    infoGameModule = managerGame.InfoGameModuleGlobal

    sendInfoAddZoneSeeker:Connect(function (char, namePlayer, playerSelected)
        pointRespawnPlayerSeeker = managerGame.pointRespawnPlayerSeekerGlobal
        respawnStartPlayerHiding(char, pointRespawnPlayerSeeker)
        
        if game.localPlayer.name == namePlayer then
            newPlayerGame(
                char, 
                namePlayer, 
                player_id.value, 
                infoGameModule.SeekerTexts["Intro"], 
                {[rolesPlayerGame[1]] = true, [rolesPlayerGame[2]] = false}
            )

            local position = char.gameObject.transform.position
            cameraManagerSeeker.CenterOn(position)
            countdownWaitReleasePlayer(playerSelected)
        end
    end)

    sendActivateMenuHide:Connect(function (char, namePlayer, playerSelected)
        pointRespawnPlayerHider = managerGame.pointsRespawnPlayerHiderGlobal[managerGame.numRespawnPlayerHiding.value]
        respawnStartPlayerHiding(char, pointRespawnPlayerHider)

        if game.localPlayer.name == namePlayer then
            newPlayerGame(
                char, 
                namePlayer, 
                player_id.value, 
                infoGameModule.HiderTexts["Intro"], 
                {[rolesPlayerGame[1]] = false, [rolesPlayerGame[2]] = true}
            )
            
            local position = char.gameObject.transform.position
            cameraManagerHiding.CenterOn(position)
            countdownWaitReleasePlayer(playerSelected)
        end
    end)
end

function self:ServerAwake()
    sendInfoRoles:Connect(function(player : Player, character, namePlayer, totalPlayers, playerSelected)
        managerGame.cleanCustomeWhenPlayerLeftGameClient:FireAllClients(player.name)
        assignRolePlayers(character, namePlayer, totalPlayers, playerSelected)
    end)
    eventUpdatePreviousSeeker:Connect(function(player : Player)
        managerGame.previousSeeker.value = managerGame.whoIsSeeker.value
    end)
end

function self:Update()
    if countdownGame.endCountdownHiddenPlayers then
        managerGame.previousSeeker.value = managerGame.whoIsSeeker.value
        eventUpdatePreviousSeeker:FireServer()
        managerGame.releasePlayerServer:FireServer(
            managerGame.whoIsSeeker.value, 
            Vector3.new(0.1, 1.5, -0.6), 
            Vector3.new(0, 55, 0)
        )

        if game.localPlayer.name ~= managerGame.whoIsSeeker.value then
            uiManager.DisabledInfoPlayerHiding()
        end

        countdownGame.StartCountdownGame(uiManager, managerGame.whoIsSeeker.value)
        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
        countdownGame.endCountdownHiddenPlayers = false
    end
end