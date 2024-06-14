--Variables publics
--!SerializeField
local playerPet : GameObject = nil
--!SerializeField
local fireFlyLightColor01 : GameObject = nil
--!SerializeField
local fireFlyLightColor02 : GameObject = nil
--!SerializeField
local pointRespawnLobby : GameObject = nil
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
local custome01 : GameObject = nil -- Custome Player  Wooden Coffin A
--!SerializeField
local custome02 : GameObject = nil -- Custome Player  Pumpkin_C
--!SerializeField
local custome03 : GameObject = nil -- Custome Player  Spooky Tree_A
--!SerializeField
local custome04 : GameObject = nil -- Custome Player  book-magical-eye
--!SerializeField
local custome05 : GameObject = nil -- Custome Player  stump-possesed
--!SerializeField
local custome06 : GameObject = nil -- Custome Player  witch-hat
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
local navMeshLobby : GameObject = nil
--!SerializeField
local lobbyRoom : GameObject = nil
--!SerializeField
local worldRoom : GameObject = nil
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
pointRespawnLobbyGlobal = nil
lobbyRoomGlobal = nil
worldRoomGlobal = nil
fireFlyLightColor02Global = nil
pointsRespawnPlayerHiderGlobal = {} -- Storage all points respawn. {[n] = point_respawn}
objsHidesGlobal = {} -- Storage all stand custome. {[n] = stand_custome}
roadPedestalsGlobal = {} -- Storage the road to the pedestals
btnsObjHides = {} -- Storage all buttons of the hides objects. {["Point Respawn"] = {[n] = btn}}
playersTag = {} -- Storage all player in the scene [NamePlayer - TypePlayer]
customeStorage = {} -- Storage all costumes
objsCustome = {} -- Storage the gameobject joined to the player globally [NamePlayer - GameObject]
previousPlayers = {} -- Storage the character joined to the player globally [NamePlayer - Character]
customePlayers = {} -- Players whit its custome [NamePlayer -> {["Dress"] = Custome, ["Offset"] = Vector3.new()}]
standCustomePlayers = {} -- Players whit its stand custome {[NamePlayer] = num_stand_custome}
roadToPedestalCustom = {} -- Players whit its road to custome pedestal {[NamePlayer] = num_road}
tagPlayerFound = {} -- Player what was found - {[NamePlayer] = "Found" or nil}
customePlayersSelected = {} -- What was the customes player selected 
previousSeeker = StringValue.new('PreviousSeeker', "") -- Storage the previous seeker's name
whoIsSeeker = StringValue.new("WhoIsSeeker", "") -- Storage the seeker's name
numRespawnPlayerHiding = IntValue.new("NumRespawnPlayerHiding", 1) -- Point current of respawn of the new player
numPlayerHidingCurrently = IntValue.new("NumPlayerHidingCurrently", 0) -- Number of players hiding currently
numPlayersFound = IntValue.new("NumPlayersFound", 0) -- Amount of players Found
wasCalculatedRandomMap = BoolValue.new("WasCalculatedRandomMap", false)
hasBeginGame = BoolValue.new("HasBeginGame", false)
opcMap = IntValue.new("MapRandom", 1)
hasCollidedWithPlayerInGame = BoolValue.new("HasCollidedWithPlayerInGame", false)
isFirstPlayer = BoolValue.new("IsFirstPlayer", true) -- Verified if is the first client and assign the seeker's role

--Variables locals
local dressWear = nil
local playerCurrent = nil
local posDress = Vector3.new(0, 0, 0)
local posOffset = Vector3.new(0, 0, 0)
local uiManager = nil
local infoGameModule = nil
local detectingcol = nil
local choosingDisguisesPedestal = nil
isFollowingAlways = false

--Events
local updatePlayersFound = Event.new("UpdatePlayersFound")
local showAllHiddenPlayersYouAreGhostServer = Event.new("ShowAllHiddenPlayersYouAreGhostServer")
local showAllHiddenPlayersYouAreGhostClient = Event.new("ShowAllHiddenPlayersYouAreGhostClient")
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
reviewIfClientInGame = Event.new('ReviewIfClientInGame')
triggerAreaDetectionSeekerServer = Event.new('TriggerAreaDetectionSeekerServer')
triggerAreaDetectionSeekerClient = Event.new('TriggerAreaDetectionSeekerClient')

--Local Functions
function followingToTarget(current : GameObject, target, maxDistanceDelta, positionOffset)
    if not current or not target then return end
    if not current.transform or not target.transform then return end

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
    elseif typeCharacter == "Seeker" or typeCharacter == "Found" then
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
    choosingDisguisesPedestal.selectWhatCustomePlayerShow(standCustome)
end

local function reviewingScenePlayersCustome(nameCustome, namePlayer)
    if GameObject.Find(nameCustome .. '(Clone)') then
        Object.Destroy(GameObject.Find(nameCustome .. '(Clone)'))
        customePlayers[namePlayer] = {}
    end
end

function cleanTrashGame(namePlayer)
    for index, costumes in pairs(customeStorage) do
        if not costumes then continue end
        reviewingScenePlayersCustome(costumes.name, namePlayer)
    end
end

function cleanCustomeAndStopTrackingPlayer(namePlayer)
    if customePlayers[namePlayer] == nil or tostring(customePlayers[namePlayer]) == 'null' then return end
    if customePlayers[namePlayer]["Dress"] == nil or tostring(customePlayers[namePlayer]["Dress"]) == 'null' then return end
    
    if namePlayer ~= whoIsSeeker.value then
        if customePlayers[namePlayer]["Dress"].name == playerPet.name then return end
        Object.Destroy(customePlayers[namePlayer]["Dress"])
        customePlayers[namePlayer] = {}
    end

    isFollowingAlways = false
end

function activateNavMeshLobby()
    navMeshAgentWithoutHiders:SetActive(false)
    navMeshAgentWithHiders:SetActive(false)
    navMeshLobby:SetActive(true)
    doorSeeker:SetActive(false)
end

function lockedPlayerSeeker()
    navMeshAgentWithoutHiders:SetActive(true)
    navMeshAgentWithHiders:SetActive(false)
    navMeshLobby:SetActive(false)
    doorSeeker:SetActive(true)
end

local function addCostumePlayerInAnotherPlayers(dress, offset, rotationCustome, namePlayer)
    if namePlayer ~= game.localPlayer.name then
        cleanCustomeAndStopTrackingPlayer(namePlayer)
        
        addCostumePlayers(
            dress, 
            objsCustome[namePlayer], 
            offset, 
            rotationCustome,
            "Hiding",
            namePlayer
        )
    end
end

local function generateVFXExplosion(waitTime, sizeShader, collider, radiusZone)
    Timer.After(waitTime, function()
        fireFlyLightColor02.transform.localScale = sizeShader
        collider.radius = radiusZone
    end)
end

local function generateAreaDetectionSeeker()
    local colliderCapsule : CapsuleCollider = playerPetGlobal:GetComponent(CapsuleCollider)

    Timer.After(0.2, function()
        fireFlyLightColor02.transform.localScale = Vector3.new(35, 0.01, 35)
        colliderCapsule.enabled = true
        colliderCapsule.radius = 10
        uiManager.Img_Flashlight_Global:SetEnabled(false)
    end)

    generateVFXExplosion(0.4, Vector3.new(53, 0.01, 53), colliderCapsule, 10)
    generateVFXExplosion(0.6, Vector3.new(70, 0.01, 70), colliderCapsule, 10)
    generateVFXExplosion(0.8, Vector3.new(53, 0.01, 53), colliderCapsule, 10)
    generateVFXExplosion(1, Vector3.new(35, 0.01, 35), colliderCapsule, 10)
    generateVFXExplosion(1.25, Vector3.new(44, 0.01, 44), colliderCapsule, 18)
    generateVFXExplosion(1.5, Vector3.new(53, 0.01, 53), colliderCapsule, 25)
    generateVFXExplosion(1.75, Vector3.new(62, 0.01, 62), colliderCapsule, 34)
    generateVFXExplosion(2, Vector3.new(70, 0.01, 70), colliderCapsule, 40)
    
    Timer.After(2.2, function()
        uiManager.Img_Flashlight_Global:SetEnabled(true)
        colliderCapsule.radius = 10
        fireFlyLightColor02.transform.localScale = Vector3.new(35, 0.01, 35)
        colliderCapsule.enabled = false
    end)
end

--Unity Functions
function self:ClientAwake()    
    playerPetGlobal = playerPet
    UIManagerGlobal = UIManager
    CameraManagerGlobal = CameraManager
    zoneGreenGlobal = zoneGreen
    zoneOrangeGlobal = zoneOrange
    doorsClosedZoneGreenGlobal = doorsClosedZoneGreen
    doorsOpenZoneGreenGlobal = doorsOpenZoneGreen
    doorsClosedZoneOrangeGlobal = doorsClosedZoneOrange
    doorsOpenZoneOrangeGlobal = doorsOpenZoneOrange
    uiManager = UIManagerGlobal:GetComponent(UI_Hide_Seek)
    infoGameModule = self.gameObject:GetComponent(InfoGameModule)
    detectingcol = playerPet:GetComponent(DetectingCollisions)
    choosingDisguisesPedestal = self.gameObject:GetComponent(ChoosingCostumesPedestal)
    InfoGameModuleGlobal = infoGameModule
    fireFlyLightColor02Global = fireFlyLightColor02

    --Lobby
    pointRespawnLobbyGlobal = pointRespawnLobby
    lobbyRoomGlobal = lobbyRoom
    worldRoomGlobal = worldRoom

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
    customeStorage[4] = custome04
    customeStorage[5] = custome05
    customeStorage[6] = custome06
    
    lockedPlayerSeeker()

    releasePlayerClient:Connect(function(namePlayer, offset, rotationFireFly)
        if not playersTag[game.localPlayer.name] then return end
        
        navMeshAgentWithoutHiders:SetActive(false)
        navMeshAgentWithHiders:SetActive(true)
        navMeshLobby:SetActive(false)
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
            detectingcol.enabled = true
            uiManager.SetInfoPlayers("Players Found: " .. tostring(numPlayersFound.value) .. '/' .. tostring(numPlayerHidingCurrently.value))
        end

        fireFlyLightColor01:GetComponent(FireflyLightColor).updateSeeker()
        fireFlyLightColor02:GetComponent(FireflyLightColor).updateSeeker()
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
        detectingcol.enabled = false
    end)

    showCustomeAllPlayersClient:Connect(function(numDress, namePlayer, offset, rotationCustome)
        addCostumePlayerInAnotherPlayers(customeStorage[numDress], offset, rotationCustome, namePlayer) --Replied to all clients except sender
    end)

    deleteCustomePlayerFoundClient:Connect(function(namePlayer, seeker)
        cleanCustomeAndStopTrackingPlayer(namePlayer)
        detectingcol.enabled = true

        if game.localPlayer.name == namePlayer then 
            if detectingcol then
                local vfx = detectingcol.AddVFXFoundHiddenPlayer(seeker)
                detectingcol.DeleteVFXFoundHiddenPlayer(vfx)

                showAllHiddenPlayersYouAreGhostServer:FireServer(namePlayer)
            end

            activateMenuModelHide(false, standCustomePlayers[namePlayer], roadToPedestalCustom[namePlayer])
        end
    end)

    showAllHiddenPlayersYouAreGhostClient:Connect(function(namePlayer)
        if game.localPlayer.name ~= whoIsSeeker.value and playersTag[game.localPlayer.name] then
            local ghostDress = Object.Instantiate(detectingcol.ghostHiddenPlayer)
            ghostDress.transform.localScale = Vector3.new(5, 5, 5)
            
            addCostumePlayers(
                ghostDress, 
                objsCustome[namePlayer], 
                Vector3.new(0, 0, 0), 
                Vector3.new(0, -130, 0), 
                'Found',
                namePlayer
            )
        end
    end)

    cleanCustomeWhenPlayerLeftGameClient:Connect(function(namePlayer)
        cleanCustomeAndStopTrackingPlayer(namePlayer)
    end)

    triggerAreaDetectionSeekerClient:Connect(function()
        generateAreaDetectionSeeker()
    end)
end

function self:ServerAwake()
    showCustomeAllPlayersServer:Connect(function(player : Player, numDress, namePlayer, offset, rotationCustome)
        showCustomeAllPlayersClient:FireAllClients(numDress, namePlayer, offset, rotationCustome)
    end)

    deleteCustomePlayerFoundServer:Connect(function(player : Player, namePlayer, seeker)
        deleteCustomePlayerFoundClient:FireAllClients(namePlayer, objsCustome[seeker])
        tagPlayerFound[namePlayer] = "Found"
    end)

    disabledDetectingCollisionsAllPlayersServer:Connect(function(player : Player)
        disabledDetectingCollisionsAllPlayersClient:FireAllClients()
    end)

    releasePlayerServer:Connect(function(player : Player, namePlayer, offset, rotationFireFly)
        releasePlayerClient:FireAllClients(namePlayer, offset, rotationFireFly)
        hasBeginGame.value = true
    end)

    updateNumPlayersFound:Connect(function(player: Player)
        numPlayersFound.value += 1
        updatePlayersFound:FireAllClients()
    end)

    showAllHiddenPlayersYouAreGhostServer:Connect(function(player : Player, namePlayer)
        showAllHiddenPlayersYouAreGhostClient:FireAllClients(namePlayer)
    end)

    reviewIfClientInGame:Connect(function(player : Player, namePlayer)
        if playersTag[namePlayer] then
            hasCollidedWithPlayerInGame.value = true
        else
            hasCollidedWithPlayerInGame.value = false
        end
    end)

    triggerAreaDetectionSeekerServer:Connect(function(player : Player)
        triggerAreaDetectionSeekerClient:FireAllClients()
    end)

    server.PlayerDisconnected:Connect(function(player : Player)
        if whoIsSeeker.value == player.name then
            whoIsSeeker.value = ''
            previousSeeker.value = ''
            isFirstPlayer.value = true
            isFollowingAlways = false
        elseif playersTag[player.name] then
            if numRespawnPlayerHiding.value > 0 then numRespawnPlayerHiding.value -= 1 end
            if numPlayerHidingCurrently.value > 0 then numPlayerHidingCurrently.value -= 1 end
            if tagPlayerFound[player.name] == "Found" then
                if numPlayersFound.value > 0 then numPlayersFound.value -= 1 end
            end
            updateNumPlayersHiding:FireAllClients()
        end
        
        objsCustome[player.name] = nil --Contain the players in scene
        previousPlayers[player.name] = nil
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
        if not customePlayers[player] or customePlayers[player] == {} then continue end
        if not info["Dress"] or tostring(info["Dress"]) == 'null' then continue end
        if not info["Player"] or tostring(info["Player"]) == 'null' then continue end
        if not info["Offset"] or tostring(info["Offset"]) == 'null' then continue end
        
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
        previousPlayers[player.name] = character
    end)
end)