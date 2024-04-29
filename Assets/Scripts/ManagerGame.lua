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
objsCustome = {}
customePlayers = {} -- Players whit its custome [NamePlayer -> {["Dress"] = Custome, ["Offset"] = Vector3.new()}]

--Variables locals
local dressWear = nil
local playerCurrent = nil
local beforeDress = nil
local posDress = Vector3.new(0, 0, 0)
local posOffset = Vector3.new(0, 0, 0)
local isFollowingAlways = false

--Events
showCustomeAllPlayersServer = Event.new("ShowCustomeAllPlayersServer")
showCustomeAllPlayersClient = Event.new("ShowCustomeAllPlayersClient")

--Local Functions
local function followingToTarget(current, target, maxDistanceDelta, positionOffset)
    if not current or not target then 
        print("Siguiendo -> Disfraz: ", tostring(current), " Target: ", tostring(target))
        return 
    end

    print("Siguiendo y moviendo -> Disfraz: ", tostring(current), " Target: ", tostring(target))
    
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
function addCostumePlayers(dress : GameObject, player : GameObject,  positionOffset : Vector3, typeCharacter : string)
    if typeCharacter == "Hiding" then 
        dressWear = Object.Instantiate(dress)
        disableAllDresses() 

        --[[ if beforeDress ~= nil and beforeDress.name ~= dressWear.name then
            print("Destruyendo dress anterior")
            print("Name Before Dress: ", beforeDress.name, " - Name New Dress: ", dressWear.name)
            Object.Destroy(beforeDress) -- Destroy the last dress
        end --]]
        beforeDress = dressWear
    elseif typeCharacter == "Seeker" then
        dressWear = dress
    end
    
    playerCurrent = player
    posOffset = positionOffset
    posDress = playerCurrent.transform.position + posOffset

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

    customeStorage[1] = objHide01
    customeStorage[2] = objHide02
    customeStorage[3] = objHide03

    showCustomeAllPlayersClient:Connect(function(numDress, namePlayer, offset)
        --Replied to all clients except sender
        if namePlayer ~= game.localPlayer.name then
            print("Replied in: ", game.localPlayer.name, " what is a: ", playersTag[game.localPlayer.name], " from: ", namePlayer, " with obj: ", tostring(playerObjTag[namePlayer]), " or ", tostring(objsCustome[namePlayer]))
            print("Offset: ", tostring(offset), " Dress: ", tostring(customeStorage[numDress]), " Tag player: ", tostring(playersTag[namePlayer]))
            print("*******************************************************************************")
            
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
            addCostumePlayers(
                customeStorage[numDress], 
                objsCustome[namePlayer], 
                offset, 
                "Hiding"
            )
        end
    end)
end

function self:ServerAwake()
    showCustomeAllPlayersServer:Connect(function(player : Player, numDress, namePlayer, offset)
        showCustomeAllPlayersClient:FireAllClients(numDress, namePlayer, offset)
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
end

scene.PlayerJoined:Connect(function(scene : WorldScene, player : Player)
    player.CharacterChanged:Connect(function (player : Player, character : Character)
        objsCustome[player.name] = character.gameObject
    end)
end)