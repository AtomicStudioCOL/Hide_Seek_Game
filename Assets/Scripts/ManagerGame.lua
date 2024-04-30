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
--!SerializeField
local infoSeeker : GameObject = nil
--!SerializeField
local infoHiding : GameObject = nil
--!SerializeField
local infoIntro : GameObject = nil

--Variables Globals
playerPetGlobal = nil
pointRespawnPlayerHiderGlobal = nil
objsHidesGlobal = nil
btnObjHide01Global = nil
btnObjHide02Global = nil
btnObjHide03Global = nil
infoSeekerGlobal = nil
infoHidingGlobal = nil
infoIntroGlobal = nil
playerObjTag = {} -- Storage the gameobject joined to the player [NamePlayer - GameObject]
playersTag = {} -- Storage all player in the scene [NamePlayer - TypePlayer]
customeStorage = {} -- Storage all costumes
objsCustome = {}
customePlayers = {} -- Players whit its custome [NamePlayer -> {["Dress"] = Custome, ["Offset"] = Vector3.new()}]

--Variables locals
local dressWear = nil
local playerCurrent = nil
local beforeDress = nil
local posDress = Vector3.new(0, 0, 0)
local posOffset = Vector3.new(0, 0, 0)
--local isFollowingAlways = false

--Events
showCustomeAllPlayersServer = Event.new("ShowCustomeAllPlayersServer")
showCustomeAllPlayersClient = Event.new("ShowCustomeAllPlayersClient")
showFlyFireAllPlayersServer = Event.new("ShowFlyFireAllPlayersServer")
showFlyFireAllPlayersClient = Event.new("ShowFlyFireAllPlayersClient")
deleteCustomePlayerFoundServer = Event.new("DeleteCustomePlayerFoundServer")
deleteCustomePlayerFoundClient = Event.new("DeleteCustomePlayerFoundClient")

--Local Functions
function followingToTarget(current, target, maxDistanceDelta, positionOffset)
    if not current or not target then 
        --print("Siguiendo -> Disfraz: ", tostring(current), " Target: ", tostring(target))
        return 
    end

    --print("Siguiendo y moviendo -> Disfraz: ", tostring(current), " Target: ", tostring(target), " Player: ", game.localPlayer.id)
    
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

        --[[ if beforeDress ~= nil and beforeDress.name ~= dressWear.name then
            print("Destruyendo dress anterior")
            print("Name Before Dress: ", beforeDress.name, " - Name New Dress: ", dressWear.name)
            Object.Destroy(beforeDress) -- Destroy the last dress
        end --]]
        --beforeDress = dressWear
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

--Unity Functions
function self:ClientAwake()
    playerPetGlobal = playerPet
    pointRespawnPlayerHiderGlobal = pointRespawnPlayerHider
    objsHidesGlobal = objsHides
    btnObjHide01Global = btnObjHide01
    btnObjHide02Global = btnObjHide02
    btnObjHide03Global = btnObjHide03
    infoSeekerGlobal = infoSeeker
    infoHidingGlobal = infoHiding
    infoIntroGlobal = infoIntro

    customeStorage[1] = objHide01
    customeStorage[2] = objHide02
    customeStorage[3] = objHide03

    playerPet:GetComponent("DetectingCollisions").enabled = false

    showCustomeAllPlayersClient:Connect(function(numDress, namePlayer, offset)
        --Replied to all clients except sender
        if namePlayer ~= game.localPlayer.name then
            --print("Replied in: ", game.localPlayer.name, " what is a: ", playersTag[game.localPlayer.name], " from: ", namePlayer, " with obj: ", tostring(playerObjTag[namePlayer]), " or ", tostring(objsCustome[namePlayer]))
            --print("Offset: ", tostring(offset), " Dress: ", tostring(customeStorage[numDress]), " Tag player: ", tostring(playersTag[namePlayer]))
            --print("*******************************************************************************")
            
            --[[ if customePlayers[game.localPlayer.name] then
                print("Dress: ", tostring(customePlayers[game.localPlayer.name]["Dress"]))
                print("Offset: ", tostring(customePlayers[game.localPlayer.name]["Offset"]))
                
                addCostumePlayers(
                    customePlayers[game.localPlayer.name]["Dress"], 
                    objsCustome[game.localPlayer.name], 
                    customePlayers[game.localPlayer.name]["Offset"], 
                    "Hiding"
                )
                --showCustomeAllPlayersServer:FireServer()
            end --]]

            -- aca validar el seeker
            --print("Player quien se puso el disfraz: ", objsCustome[namePlayer])
            if customePlayers[namePlayer] then
                --print("Player: ", namePlayer, " destruye anterior disfraz: ", tostring(customePlayers[namePlayer]["Dress"]))
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
        --[[ if namePlayer ~= game.localPlayer.name then
        end ]]
        --print("Player firefly: ", game.localPlayer.name)
        --print("Player seeker: ", tostring(objsCustome[namePlayer]))
        --print("Pet: ", tostring(playerPet))
        addCostumePlayers(
            playerPet, 
            objsCustome[namePlayer], 
            offset, 
            "Seeker",
            namePlayer
        )

        Timer.After(2, function()
            playerPet:GetComponent("DetectingCollisions").enabled = true
        end)
    end)

    deleteCustomePlayerFoundClient:Connect(function(namePlayer)
        print("Collided: ", tostring(namePlayer), " with local player: ", game.localPlayer.name)
        
        if customePlayers[namePlayer] then
            --print("Player: ", namePlayer, " destruye anterior disfraz: ", tostring(customePlayers[namePlayer]["Dress"]))
            Object.Destroy(customePlayers[namePlayer]["Dress"])
            customePlayers[namePlayer] = nil
            isFollowingAlways = false
        end
    end)
end

function self:ServerAwake()
    showCustomeAllPlayersServer:Connect(function(player : Player, numDress, namePlayer, offset)
        customePlayers[player.name] = {
            ["Dress"] = customeStorage[numDress],
            ["Player"] = player.character.gameObject,
            ["Offset"] = offset
        }
        showCustomeAllPlayersClient:FireAllClients(numDress, namePlayer, offset)
    end)

    showFlyFireAllPlayersServer:Connect(function(player : Player, namePlayer, offset)
        --print("Se comunico con el server")
        showFlyFireAllPlayersClient:FireAllClients(namePlayer, offset)
    end)

    deleteCustomePlayerFoundServer:Connect(function(player : Player, namePlayer)
        deleteCustomePlayerFoundClient:FireAllClients(namePlayer)
    end)
end

function self:Update()
    if isFollowingAlways then 
        --print("Player quien se puso el disfraz: ", playerCurrent)
        followingToTarget(
            dressWear,
            playerCurrent,
            5 * Time.deltaTime,
            posOffset
        )
    end

    for player, info in pairs (customePlayers) do
        --print("Player: ", tostring(info["Player"]), "Dress: ", tostring(info["Dress"]), "Offset: ", tostring(info["Offset"]))
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