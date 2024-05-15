--Variables publics
--!SerializeField
local playerPet : GameObject = nil
--!SerializeField
local pointRespawnPlayerSeeker : GameObject = nil
--!SerializeField
local pointRespawnPlayerHider01 : GameObject = nil
--!SerializeField
local pointRespawnPlayerHider02 : GameObject = nil
--!SerializeField
local pointRespawnPlayerHider03 : GameObject = nil
--!SerializeField
local pointRespawnPlayerHider04 : GameObject = nil
--!SerializeField
local objsHides01 : GameObject = nil
--!SerializeField
local objsHides02 : GameObject = nil
--!SerializeField
local objsHides0304 : GameObject = nil
--!SerializeField
local roadPedestal01 : GameObject = nil
--!SerializeField
local roadPedestal02 : GameObject = nil
--!SerializeField
local roadPedestal03 : GameObject = nil
--!SerializeField
local roadPedestal04 : GameObject = nil
--!SerializeField
local custome01 : GameObject = nil
--!SerializeField
local custome02 : GameObject = nil
--!SerializeField
local custome03 : GameObject = nil
--!SerializeField
local btnObjHide01Point01 : TapHandler = nil
--!SerializeField
local btnObjHide02Point01 : TapHandler = nil
--!SerializeField
local btnObjHide03Point01 : TapHandler = nil
--!SerializeField
local btnObjHide01Point02 : TapHandler = nil
--!SerializeField
local btnObjHide02Point02 : TapHandler = nil
--!SerializeField
local btnObjHide03Point02 : TapHandler = nil
--!SerializeField
local btnObjHide01Point0304 : TapHandler = nil
--!SerializeField
local btnObjHide02Point0304 : TapHandler = nil
--!SerializeField
local btnObjHide03Point0304 : TapHandler = nil
--!SerializeField
local navMeshAgentWithoutHiders : GameObject = nil
--!SerializeField
local navMeshAgentWithHiders : GameObject = nil
--!SerializeField
local doorSeeker : GameObject = nil
--!SerializeField
local UIManager : GameObject = nil
--!SerializeField
local CameraManager : GameObject = nil
--!SerializeField
local zoneGreen : GameObject = nil
--!SerializeField
local zoneOrange : GameObject = nil
--!SerializeField
local doorsClosedZoneGreen : GameObject = nil
--!SerializeField
local doorsOpenZoneGreen : GameObject = nil
--!SerializeField
local doorsClosedZoneOrange : GameObject = nil
--!SerializeField
local doorsOpenZoneOrange : GameObject = nil

--Variables Globals
CameraManagerGlobal = nil
UIManagerGlobal = nil
InfoGameModuleGlobal = nil
playerPetGlobal = nil
pointRespawnPlayerSeekerGlobal = nil
zoneGreenGlobal = nil
zoneOrangeGlobal = nil
doorsClosedZoneGreenGlobal = nil
doorsOpenZoneGreenGlobal = nil
doorsClosedZoneOrangeGlobal = nil
doorsOpenZoneOrangeGlobal = nil
pointsRespawnPlayerHiderGlobal = {} -- Storage all points respawn. {[n] = point_respawn}
objsHidesGlobal = {} -- Storage all stand custome. {[n] = stand_custome}
roadPedestalsGlobal = {} -- Storage the road to the pedestals
btnsObjHides = {} -- Storage all buttons of the hides objects. {["Point Respawn"] = {[n] = btn}}
playerObjTag = {} -- Storage the gameobject joined to the player [NamePlayer - GameObject]
playersTag = {} -- Storage all player in the scene [NamePlayer - TypePlayer]
customeStorage = {} -- Storage all costumes
objsCustome = {} -- Storage the gameobject joined to the player globally [NamePlayer - GameObject]
customePlayers = {} -- Players whit its custome [NamePlayer -> {["Dress"] = Custome, ["Offset"] = Vector3.new()}]
standCustomePlayers = {} -- Players whit its stand custome {[NamePlayer] = num_stand_custome}
roadToPedestalCustom = {} -- Players whit its road to custome pedestal {[NamePlayer] = num_road}
tagPlayerFound = {} -- Player what was found - {[NamePlayer] = "Found" or nil}
isFirstPlayer = BoolValue.new("IsFirstPlayer", true) -- Verified if is the first client and assign the seeker's role
whoIsSeeker = StringValue.new("WhoIsSeeker", "") -- Storage the seeker's name
numRespawnPlayerHiding = IntValue.new("NumRespawnPlayerHiding", 1) -- Point current of respawn of the new player
numPlayerHidingCurrently = IntValue.new("NumPlayerHidingCurrently", 0) -- Number of players hiding currently
numPlayersFound = IntValue.new("NumPlayersFound", 0) -- Amount of players Found
isFirstReleaseSeeker = BoolValue.new("IsFirstReleaseSeeker", true)
wasCalculatedRandomMap = BoolValue.new("WasCalculatedRandomMap", false)
hasBeginGame = BoolValue.new("HasBeginGame", false)
opcMap = IntValue.new("MapRandom", 1)

--Variables locals
local dressWear = nil
local playerCurrent = nil
local posDress = Vector3.new(0, 0, 0)
local posOffset = Vector3.new(0, 0, 0)
local isFollowingAlways = false
local uiManager = nil
local infoGameModule = nil

--Events
local updatePlayersFound = Event.new("UpdatePlayersFound")
cleanCustomeWhenPlayerLeftGameClient = Event.new("CleanCustomeWhenPlayerLeftGameClient")
showCustomeAllPlayersServer = Event.new("ShowCustomeAllPlayersServer")
showCustomeAllPlayersClient = Event.new("ShowCustomeAllPlayersClient")
deleteCustomePlayerFoundServer = Event.new("DeleteCustomePlayerFoundServer")
deleteCustomePlayerFoundClient = Event.new("DeleteCustomePlayerFoundClient")
disabledDetectingCollisionsAllPlayersServer = Event.new("DisabledDetectingCollisionsAllPlayersServer")
disabledDetectingCollisionsAllPlayersClient = Event.new("DisabledDetectingCollisionsAllPlayersClient")
releasePlayerServer = Event.new("ReleasePlayerServer")
releasePlayerClient = Event.new("ReleasePlayerClient")
updateNumPlayersHiding = Event.new("UpdateNumPlayersHiding")
updateNumPlayersFound = Event.new("UpdateNumPlayersFound")

--Local Functions
function followingToTarget(current : GameObject, target, maxDistanceDelta, positionOffset)
    if not current or not target then return end

    current.transform.position = Vector3.MoveTowards(
        current.transform.position, 
        target.transform.position + positionOffset, 
        maxDistanceDelta
    )
end

local function disableAllDresses()
    for _,dress in ipairs(customeStorage) do
        dress.SetActive(dress, false)
    end
end

--Global Functions
function addCostumePlayers(dress : GameObject, player : GameObject,  positionOffset : Vector3, rotationCustome, typeCharacter : string, namePlayer)
    if typeCharacter == "Hiding" then 
        dressWear = Object.Instantiate(dress)
        disableAllDresses() 

        customePlayers[namePlayer] = {
            ["Dress"] = dressWear,
            ["Player"] = objsCustome[namePlayer],
            ["Offset"] = positionOffset,
            ["Rotation"] = rotationCustome
        }
    elseif typeCharacter == "Seeker" then
        dressWear = dress

        customePlayers[namePlayer] = {
            ["Dress"] = dressWear,
            ["Player"] = objsCustome[namePlayer],
            ["Offset"] = positionOffset,
            ["Rotation"] = rotationCustome
        }
    end

    playerCurrent = player
    posOffset = positionOffset
    posDress = player.transform.position + positionOffset
    
    dressWear.transform.position = posDress
    dressWear.transform.eulerAngles = rotationCustome
    dressWear.SetActive(dressWear, true)
    isFollowingAlways = true
end

function activateMenuModelHide(visible, standCustome, numRoad)
    if standCustome == 0 and numRoad == 0 then return end

    objsHidesGlobal[standCustome]:SetActive(visible)
    roadPedestalsGlobal[numRoad]:SetActive(visible)
end

function cleanCustomeAndStopTrackingPlayer(namePlayer)
    if customePlayers[namePlayer] then
        if namePlayer == whoIsSeeker.value then return end
        if customePlayers[namePlayer] == nil or tostring(customePlayers[namePlayer]) == 'null' then return end
        if customePlayers[namePlayer]["Dress"] == nil or tostring(customePlayers[namePlayer]["Dress"]) == 'null' then return end
        
        Object.Destroy(customePlayers[namePlayer]["Dress"])
        customePlayers[namePlayer] = nil
        isFollowingAlways = false
    end
end

function lockedPlayerSeeker()
    navMeshAgentWithoutHiders:SetActive(true)
    navMeshAgentWithHiders:SetActive(false)
    doorSeeker:SetActive(true)
end

--Unity Functions
function self:ClientAwake()
    playerPetGlobal = playerPet -- Player pet
    UIManagerGlobal = UIManager
    CameraManagerGlobal = CameraManager
    zoneGreenGlobal = zoneGreen
    zoneOrangeGlobal = zoneOrange
    doorsClosedZoneGreenGlobal = doorsClosedZoneGreen
    doorsOpenZoneGreenGlobal = doorsOpenZoneGreen
    doorsClosedZoneOrangeGlobal = doorsClosedZoneOrange
    doorsOpenZoneOrangeGlobal = doorsOpenZoneOrange
    uiManager = UIManagerGlobal:GetComponent("UI_Hide_Seek")
    infoGameModule = self.gameObject:GetComponent("InfoGameModule")
    InfoGameModuleGlobal = infoGameModule

    --Point respawn Seeker
    pointRespawnPlayerSeekerGlobal = pointRespawnPlayerSeeker

    --Points respawn
    pointsRespawnPlayerHiderGlobal[1] = pointRespawnPlayerHider01
    pointsRespawnPlayerHiderGlobal[2] = pointRespawnPlayerHider02
    pointsRespawnPlayerHiderGlobal[3] = pointRespawnPlayerHider03
    pointsRespawnPlayerHiderGlobal[4] = pointRespawnPlayerHider04
    
    --Stand custome
    objsHidesGlobal[1] = objsHides01
    objsHidesGlobal[2] = objsHides02
    objsHidesGlobal[3] = objsHides0304

    --Road to Pedestals
    roadPedestalsGlobal[1] = roadPedestal01
    roadPedestalsGlobal[2] = roadPedestal02
    roadPedestalsGlobal[3] = roadPedestal03
    roadPedestalsGlobal[4] = roadPedestal04

    --Buttons Select custome
    btnsObjHides["PointRespawn01"] = {
        [1] = btnObjHide01Point01,
        [2] = btnObjHide02Point01,
        [3] = btnObjHide03Point01,
    }
    btnsObjHides["PointRespawn02"] = {
        [1] = btnObjHide01Point02,
        [2] = btnObjHide02Point02,
        [3] = btnObjHide03Point02,
    }
    btnsObjHides["PointRespawn0304"] = {
        [1] = btnObjHide01Point0304,
        [2] = btnObjHide02Point0304,
        [3] = btnObjHide03Point0304,
    }

    --The player custome
    customeStorage[1] = custome01
    customeStorage[2] = custome02
    customeStorage[3] = custome03
    
    lockedPlayerSeeker()

    releasePlayerClient:Connect(function(namePlayer, offset, rotationFireFly)
        navMeshAgentWithoutHiders:SetActive(false)
        navMeshAgentWithHiders:SetActive(true)
        doorSeeker:SetActive(false)

        addCostumePlayers(
            playerPet, 
            objsCustome[namePlayer], 
            offset,
            rotationFireFly, 
            "Seeker",
            namePlayer
        )

        if playersTag[game.localPlayer.name] == "Seeker" then
            uiManager.SetInfoPlayers(infoGameModule.SeekerTexts["GoSeeker"])
            Timer.After(2, function() 
                playerPet:GetComponent("DetectingCollisions").enabled = true
                uiManager.SetInfoPlayers("Players Found: " .. tostring(numPlayersFound.value) .. '/' .. tostring(numPlayerHidingCurrently.value))
            end)
        end
    end)

    updateNumPlayersHiding:Connect(function()
        if playersTag[game.localPlayer.name] == "Seeker" then
            uiManager.SetInfoPlayers("Players Found: " .. tostring(numPlayersFound.value) .. '/' .. tostring(numPlayerHidingCurrently.value))
        end
    end)

    updatePlayersFound:Connect(function()
        if playersTag[game.localPlayer.name] == "Seeker" then
            uiManager.SetInfoPlayers("Players Found: " .. tostring(numPlayersFound.value) .. '/' .. tostring(numPlayerHidingCurrently.value))
        end
    end)

    disabledDetectingCollisionsAllPlayersClient:Connect(function()
        playerPet:GetComponent("DetectingCollisions").enabled = false
    end)

    showCustomeAllPlayersClient:Connect(function(numDress, namePlayer, offset, rotationCustome)
        --Replied to all clients except sender
        if namePlayer ~= game.localPlayer.name then
            if customePlayers[namePlayer] then
                Object.Destroy(customePlayers[namePlayer]["Dress"])
                customePlayers[namePlayer] = nil
            end

            addCostumePlayers(
                customeStorage[numDress], 
                objsCustome[namePlayer], 
                offset, 
                rotationCustome,
                "Hiding",
                namePlayer
            )
        end
    end)

    deleteCustomePlayerFoundClient:Connect(function(namePlayer)
        if game.localPlayer.name == namePlayer then
            activateMenuModelHide(false, standCustomePlayers[namePlayer], roadToPedestalCustom[namePlayer])
            uiManager.SetInfoPlayers(infoGameModule.HiderTexts["PlayerFound"])
            
            Timer.After(5, function()
                uiManager.SetInfoPlayers(infoGameModule.HiderTexts["TryAgain"])
                Timer.After(3, function() uiManager.DisabledInfoPlayerHiding() end)
            end)
        end

        cleanCustomeAndStopTrackingPlayer(namePlayer)
    end)

    cleanCustomeWhenPlayerLeftGameClient:Connect(function(namePlayer)
        cleanCustomeAndStopTrackingPlayer(namePlayer)
    end)
end

function self:ServerAwake()
    showCustomeAllPlayersServer:Connect(function(player : Player, numDress, namePlayer, offset, rotationCustome)
        showCustomeAllPlayersClient:FireAllClients(numDress, namePlayer, offset, rotationCustome)
    end)

    deleteCustomePlayerFoundServer:Connect(function(player : Player, namePlayer)
        deleteCustomePlayerFoundClient:FireAllClients(namePlayer)
    end)

    disabledDetectingCollisionsAllPlayersServer:Connect(function(player : Player)
        disabledDetectingCollisionsAllPlayersClient:FireAllClients()
    end)

    releasePlayerServer:Connect(function(player : Player, namePlayer, offset, rotationFireFly)
        releasePlayerClient:FireAllClients(namePlayer, offset, rotationFireFly)
        isFirstReleaseSeeker.value = false
        hasBeginGame.value = true
    end)

    updateNumPlayersFound:Connect(function(player: Player)
        numPlayersFound.value += 1
        updatePlayersFound:FireAllClients()
    end)

    server.PlayerDisconnected:Connect(function(player : Player)
        if whoIsSeeker.value == player.name then
            isFirstPlayer.value = true
            playersTag[whoIsSeeker.value] = nil
            isFirstReleaseSeeker.value = true
            whoIsSeeker.value = ""
        else
            if numRespawnPlayerHiding.value > 0 then numRespawnPlayerHiding.value -= 1 end
            if numPlayerHidingCurrently.value > 0 then numPlayerHidingCurrently.value -= 1 end
            if numPlayersFound.value > 0 then numPlayersFound.value -= 1 end
            isFirstReleaseSeeker.value = true
            updateNumPlayersHiding:FireAllClients()
        end

        objsCustome[player.name] = nil --Contain the players in scene
        cleanCustomeWhenPlayerLeftGameClient:FireAllClients(player.name)
    end)
end

function self:Update()
    if isFollowingAlways then
        followingToTarget(
            dressWear,
            playerCurrent,
            5 * Time.deltaTime,
            posOffset
        )
    end

    for player, info in pairs (customePlayers) do
        if not customePlayers[player] then continue end

        followingToTarget(
            info["Dress"],
            info["Player"],
            5 * Time.deltaTime,
            info["Offset"]
        )
    end
end

scene.PlayerJoined:Connect(function(scene, player : Player)
    player.CharacterChanged:Connect(function (player : Player, character : Character)
        objsCustome[player.name] = character.gameObject
    end)
end)