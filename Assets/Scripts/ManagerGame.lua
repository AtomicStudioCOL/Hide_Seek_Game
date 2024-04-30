--Variables publics
--!SerializeField
local playerPet : GameObject = nil
--!SerializeField
local pointRespawnPlayerHider : GameObject = nil
--!SerializeField
local objsHides : GameObject = nil
--!SerializeField
local objHide01 : GameObject = nil
--!SerializeField
local objHide02 : GameObject = nil
--!SerializeField
local objHide03 : GameObject = nil
--!SerializeField
local btnObjHide01 : TapHandler = nil
--!SerializeField
local btnObjHide02 : TapHandler = nil
--!SerializeField
local btnObjHide03 : TapHandler = nil

--Variables Globals
playerPetGlobal = nil
pointRespawnPlayerHiderGlobal = nil
objsHidesGlobal = nil
btnObjHide01Global = nil
btnObjHide02Global = nil
btnObjHide03Global = nil
playerObjTag = {} -- Storage the gameobject joined to the player [NamePlayer - GameObject]
playersTag = {} -- Storage all player in the scene [NamePlayer - TypePlayer]
customeStorage = {} -- Storage all costumes
objsCustome = {} -- Storage the gameobject joined to the player globally [NamePlayer - GameObject]
customePlayers = {} -- Players whit its custome [NamePlayer -> {["Dress"] = Custome, ["Offset"] = Vector3.new()}]
isFirstPlayer = BoolValue.new("IsFirstPlayer", true) -- Verified if is the first client and assign the seeker's role
whoIsSeeker = StringValue.new("WhoIsSeeker", "") -- Storage the seeker's name

--Variables locals
local dressWear = nil
local playerCurrent = nil
local posDress = Vector3.new(0, 0, 0)
local posOffset = Vector3.new(0, 0, 0)
local isFollowingAlways = false

--Events
local cleanCustomeWhenPlayerLeftGameClient = Event.new("CleanCustomeWhenPlayerLeftGameClient")
showCustomeAllPlayersServer = Event.new("ShowCustomeAllPlayersServer")
showCustomeAllPlayersClient = Event.new("ShowCustomeAllPlayersClient")
showFlyFireAllPlayersServer = Event.new("ShowFlyFireAllPlayersServer")
showFlyFireAllPlayersClient = Event.new("ShowFlyFireAllPlayersClient")
deleteCustomePlayerFoundServer = Event.new("DeleteCustomePlayerFoundServer")
deleteCustomePlayerFoundClient = Event.new("DeleteCustomePlayerFoundClient")
disabledDetectingCollisionsAllPlayersServer = Event.new("DisabledDetectingCollisionsAllPlayersServer")
disabledDetectingCollisionsAllPlayersClient = Event.new("DisabledDetectingCollisionsAllPlayersClient")

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

function activateMenuModelHide(visible)
    objsHidesGlobal.SetActive(objsHidesGlobal, visible)
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
    playerPetGlobal = playerPet
    pointRespawnPlayerHiderGlobal = pointRespawnPlayerHider
    objsHidesGlobal = objsHides
    btnObjHide01Global = btnObjHide01
    btnObjHide02Global = btnObjHide02
    btnObjHide03Global = btnObjHide03

    customeStorage[1] = objHide01
    customeStorage[2] = objHide02
    customeStorage[3] = objHide03

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

    showFlyFireAllPlayersClient:Connect(function(namePlayer, offset)
        addCostumePlayers(
            playerPet, 
            objsCustome[namePlayer], 
            offset, 
            "Seeker",
            namePlayer
        )
        
        if playersTag[game.localPlayer.name] == "Seeker" then
            Timer.After(2, function()
                playerPet:GetComponent("DetectingCollisions").enabled = true
            end)
        end
    end)

    deleteCustomePlayerFoundClient:Connect(function(namePlayer)
        if game.localPlayer.name == namePlayer then
            activateMenuModelHide(false)
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

    showFlyFireAllPlayersServer:Connect(function(player : Player, namePlayer, offset)
        showFlyFireAllPlayersClient:FireAllClients(namePlayer, offset)
    end)

    deleteCustomePlayerFoundServer:Connect(function(player : Player, namePlayer)
        deleteCustomePlayerFoundClient:FireAllClients(namePlayer)
    end)

    disabledDetectingCollisionsAllPlayersServer:Connect(function(player : Player)
        disabledDetectingCollisionsAllPlayersClient:FireAllClients()
    end)

    server.PlayerDisconnected:Connect(function(player : Player)
        if whoIsSeeker.value == player.name then
            isFirstPlayer.value = true
            playersTag[whoIsSeeker.value] = nil
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