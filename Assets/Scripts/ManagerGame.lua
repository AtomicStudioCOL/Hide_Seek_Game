--Variables publics
--!SerializeField
local playerPet : GameObject = nil
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

--Variables Globals
CameraManagerGlobal = nil
UIManagerGlobal = nil
playerPetGlobal = nil
pointsRespawnPlayerHiderGlobal = {} -- Storage all points respawn. {[n] = point_respawn}
objsHidesGlobal = {} -- Storage all stand custome. {[n] = stand_custome}
btnsObjHides = {} -- Storage all buttons of the hides objects. {["Point Respawn"] = {[n] = btn}}
playerObjTag = {} -- Storage the gameobject joined to the player [NamePlayer - GameObject]
playersTag = {} -- Storage all player in the scene [NamePlayer - TypePlayer]
customeStorage = {} -- Storage all costumes
objsCustome = {} -- Storage the gameobject joined to the player globally [NamePlayer - GameObject]
customePlayers = {} -- Players whit its custome [NamePlayer -> {["Dress"] = Custome, ["Offset"] = Vector3.new()}]
standCustomePlayers = {} -- Players whit its stand custome {[NamePlayer] = num_stand_custome}
isFirstPlayer = BoolValue.new("IsFirstPlayer", true) -- Verified if is the first client and assign the seeker's role
whoIsSeeker = StringValue.new("WhoIsSeeker", "") -- Storage the seeker's name
numRespawnPlayerHiding = IntValue.new("NumRespawnPlayerHiding", 1)
isFirstReleaseSeeker = BoolValue.new("IsFirstReleaseSeeker", true)

--Variables locals
local dressWear = nil
local playerCurrent = nil
local posDress = Vector3.new(0, 0, 0)
local posOffset = Vector3.new(0, 0, 0)
local isFollowingAlways = false
local uiManager = nil

--Events
local cleanCustomeWhenPlayerLeftGameClient = Event.new("CleanCustomeWhenPlayerLeftGameClient")
showCustomeAllPlayersServer = Event.new("ShowCustomeAllPlayersServer")
showCustomeAllPlayersClient = Event.new("ShowCustomeAllPlayersClient")
deleteCustomePlayerFoundServer = Event.new("DeleteCustomePlayerFoundServer")
deleteCustomePlayerFoundClient = Event.new("DeleteCustomePlayerFoundClient")
disabledDetectingCollisionsAllPlayersServer = Event.new("DisabledDetectingCollisionsAllPlayersServer")
disabledDetectingCollisionsAllPlayersClient = Event.new("DisabledDetectingCollisionsAllPlayersClient")
releasePlayerServer = Event.new("ReleasePlayerServer")
releasePlayerClient = Event.new("ReleasePlayerClient")

--Local Functions
function followingToTarget(current, target, maxDistanceDelta, positionOffset)
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
function addCostumePlayers(dress : GameObject, player : GameObject,  positionOffset : Vector3, typeCharacter : string, namePlayer)
    if typeCharacter == "Hiding" then 
        dressWear = Object.Instantiate(dress)
        disableAllDresses() 

        customePlayers[namePlayer] = {
            ["Dress"] = dressWear,
            ["Player"] = objsCustome[namePlayer],
            ["Offset"] = positionOffset
        }
    elseif typeCharacter == "Seeker" then
        dressWear = dress

        customePlayers[namePlayer] = {
            ["Dress"] = dressWear,
            ["Player"] = objsCustome[namePlayer],
            ["Offset"] = positionOffset
        }
    end

    playerCurrent = player
    posOffset = positionOffset
    posDress = player.transform.position + positionOffset

    dressWear.transform.position = posDress
    dressWear.SetActive(dressWear, true)
    isFollowingAlways = true
end

function activateMenuModelHide(visible, standCustome)
    if standCustome == 0 then return end
    objsHidesGlobal[standCustome]:SetActive(visible)
end

function cleanCustomeAndStopTrackingPlayer(namePlayer)
    if customePlayers[namePlayer] then
        Object.Destroy(customePlayers[namePlayer]["Dress"])
        customePlayers[namePlayer] = nil
        isFollowingAlways = false
    end
end

--Unity Functions
function self:ClientAwake()
    playerPetGlobal = playerPet -- Player pet
    UIManagerGlobal = UIManager
    CameraManagerGlobal = CameraManager
    uiManager = UIManagerGlobal:GetComponent("UI_Hide_Seek")

    --Points respawn
    pointsRespawnPlayerHiderGlobal[1] = pointRespawnPlayerHider01
    pointsRespawnPlayerHiderGlobal[2] = pointRespawnPlayerHider02
    pointsRespawnPlayerHiderGlobal[3] = pointRespawnPlayerHider03
    pointsRespawnPlayerHiderGlobal[4] = pointRespawnPlayerHider04
    
    --Stand custome
    objsHidesGlobal[1] = objsHides01
    objsHidesGlobal[2] = objsHides02
    objsHidesGlobal[3] = objsHides0304

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
    
    navMeshAgentWithoutHiders:SetActive(true)
    navMeshAgentWithHiders:SetActive(false)
    doorSeeker:SetActive(true)

    releasePlayerClient:Connect(function(namePlayer, offset)
        navMeshAgentWithoutHiders:SetActive(false)
        navMeshAgentWithHiders:SetActive(true)
        doorSeeker:SetActive(false)

        if not playerPet.activeSelf then
            addCostumePlayers(
                playerPet, 
                objsCustome[namePlayer], 
                offset, 
                "Seeker",
                namePlayer
            )
    
            if playersTag[game.localPlayer.name] == "Seeker" then
                Timer.After(5, function()
                    uiManager.SetInfoPlayers('There are enough players on stage for you to start the search; go get them.')
                    
                    Timer.After(3, function()
                        playerPet:GetComponent("DetectingCollisions").enabled = true
                        uiManager.SetInfoPlayers('Players Found: 0')
                    end)
                end)

            end
        end
    end)

    disabledDetectingCollisionsAllPlayersClient:Connect(function()
        playerPet:GetComponent("DetectingCollisions").enabled = false
    end)

    showCustomeAllPlayersClient:Connect(function(numDress, namePlayer, offset)
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
                "Hiding",
                namePlayer
            )
        end
    end)

    deleteCustomePlayerFoundClient:Connect(function(namePlayer)
        if game.localPlayer.name == namePlayer then
            activateMenuModelHide(false, standCustomePlayers[namePlayer])
            uiManager.SetInfoPlayers("We're sorry, you've been found by the seeker. You're free to explore the world. If you'd like to try again, please re-enter the game.")
        end

        cleanCustomeAndStopTrackingPlayer(namePlayer)
    end)

    cleanCustomeWhenPlayerLeftGameClient:Connect(function(namePlayer)
        cleanCustomeAndStopTrackingPlayer(namePlayer)
    end)
end

function self:ServerAwake()
    showCustomeAllPlayersServer:Connect(function(player : Player, numDress, namePlayer, offset)
        showCustomeAllPlayersClient:FireAllClients(numDress, namePlayer, offset)
    end)

    deleteCustomePlayerFoundServer:Connect(function(player : Player, namePlayer)
        deleteCustomePlayerFoundClient:FireAllClients(namePlayer)
    end)

    disabledDetectingCollisionsAllPlayersServer:Connect(function(player : Player)
        disabledDetectingCollisionsAllPlayersClient:FireAllClients()
    end)

    releasePlayerServer:Connect(function(player : Player, namePlayer, offset)
        releasePlayerClient:FireAllClients(namePlayer, offset)
    end)

    server.PlayerDisconnected:Connect(function(player : Player)
        if whoIsSeeker.value == player.name then
            isFirstPlayer.value = true
            playersTag[whoIsSeeker.value] = nil
            isFirstReleaseSeeker.value = true
        else
            numRespawnPlayerHiding.value -= 1
            isFirstReleaseSeeker.value = true
        end

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
        followingToTarget(
            info["Dress"],
            info["Player"],
            5 * Time.deltaTime,
            info["Offset"]
        )
    end
end

scene.PlayerJoined:Connect(function(scene : WorldScene, player : Player)
    player.CharacterChanged:Connect(function (player : Player, character : Character)
        objsCustome[player.name] = character.gameObject
    end)
end)