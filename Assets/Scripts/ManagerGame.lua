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
objHide01Global = nil
objHide02Global = nil
objHide03Global = nil
btnObjHide01Global = nil
btnObjHide02Global = nil
btnObjHide03Global = nil
playerObjTag = {}
playersTag = {} -- Storage all player in the scene

--Variables locals
local dressWear = nil
local playerCurrent = nil
local posOffset = Vector3.new(0, 0, 0)
local isFollowingAlways = false

--Events
local deleteCustomePlayerServer = Event.new("DeleteCustomePlayerServer")
local deleteCustomePlayerClient = Event.new("DeleteCustomePlayerClient")

--Local Functions
local function followingToTarget(current, target, maxDistanceDelta, positionOffset)
    if not current or not target then return end
    
    current.transform.position = Vector3.MoveTowards(
        current.transform.position, 
        target.transform.position + positionOffset, 
        maxDistanceDelta
    )
end

local function disableAllDresses(customeStorage)
    for _,dress in ipairs(customeStorage) do
        dress.SetActive(dress, false)
    end
end

--Global Functions
function addCostumePlayers(dress : GameObject, player : GameObject,  positionOffset : Vector3, typeCharacter : string, customeStorage)
    dressWear = dress
    playerCurrent = player
    posOffset = positionOffset
    local posDress = playerCurrent.transform.position + posOffset

    dressWear.transform.position = posDress
    
    if typeCharacter == "Hiding" then disableAllDresses(customeStorage) end

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
    objHide01Global = objHide01
    objHide02Global = objHide02
    objHide03Global = objHide03
    btnObjHide01Global = btnObjHide01
    btnObjHide02Global = btnObjHide02
    btnObjHide03Global = btnObjHide03
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