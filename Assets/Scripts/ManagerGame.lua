--Variables publics
--!SerializeField
local zoneDetectingSeeker : GameObject = nil
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
zoneDetectingSeekerGlobal = nil
objsHidesGlobal = nil
objHide01Global = nil
objHide02Global = nil
objHide03Global = nil
btnObjHide01Global = nil
btnObjHide02Global = nil
btnObjHide03Global = nil
playerObjTag = {}
playerActivateCustome = StringValue.new("PlayerActivateCustom", "")

--Variables locals
local dressWear = nil
local playerCurrent = nil
local posOffset = Vector3.new(0, 0, 0)
local isFollowingAlways = false

--Events
local showCustomeAllPlayersServer = Event.new("ShowCustomeAllPlayersServer")
local showCustomeAllPlayersClient = Event.new("ShowCustomeAllPlayersClient")

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
    --[[ showCustomeAllPlayersServer:FireServer()
    showCustomeAllPlayersClient:Connect(function()
    end) ]]
    print("Cliente actual: ", game.localPlayer.name)
    dressWear = dress
    playerCurrent = player
    posOffset = positionOffset
    local posDress = playerCurrent.transform.position + posOffset

    dressWear.transform.position = posDress
    
    if typeCharacter == "Hiding" then disableAllDresses(customeStorage) end

    dressWear.SetActive(dressWear, true)
    isFollowingAlways = true
    print("Dress: ", tostring(GameObject.Find(dressWear.name)))
end

function activateMenuModelHide(visible)
    objsHidesGlobal.SetActive(objsHidesGlobal, visible)
end

--Unity Functions
function self:ClientAwake()
    zoneDetectingSeekerGlobal = zoneDetectingSeeker
    objsHidesGlobal = objsHides
    objHide01Global = objHide01
    objHide02Global = objHide02
    objHide03Global = objHide03
    btnObjHide01Global = btnObjHide01
    btnObjHide02Global = btnObjHide02
    btnObjHide03Global = btnObjHide03
end

--[[ function self:ServerAwake()
    showCustomeAllPlayersServer:Connect(function(player : Player)
        showCustomeAllPlayersClient:FireAllClients()
    end)
end ]]

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