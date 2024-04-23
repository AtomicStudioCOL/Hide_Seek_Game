--Variable publics
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

--Variables
local customeStorage = {}
local isFollowingAlwaysHider = false
local dressWear = nil
local playerCurrent = nil
local posOffset = Vector3.new(0, 0, 0)

--Functions
function followingToTarget(current, target, maxDistanceDelta, positionOffset)
    current.transform.position = Vector3.MoveTowards(
        current.transform.position, 
        target.transform.position + positionOffset, 
        maxDistanceDelta
    )
end

function disableAllDresses()
    for _,dress in ipairs(customeStorage) do
        dress.SetActive(dress, false)
    end
end

function addCostumePlayerHider(dress : GameObject, player : GameObject,  positionOffset : Vector3)
    dressWear = dress
    playerCurrent = player
    posOffset = positionOffset
    local posDress = playerCurrent.transform.position + posOffset

    dressWear.transform.position = posDress
    
    disableAllDresses()
    dressWear.SetActive(dressWear, true)
    isFollowingAlwaysHider = true
end

function self:ClientAwake()
    --Storage dress
    customeStorage[1] = objHide01
    customeStorage[2] = objHide02
    customeStorage[3] = objHide03

    btnObjHide01.Tapped:Connect(function()
        print("Disfraz 01")
        addCostumePlayerHider(
            customeStorage[1], 
            game.localPlayer.character.gameObject,
            Vector3.new(0, 1.579, 0)   
        )
    end)

    btnObjHide02.Tapped:Connect(function()
        print("Disfraz 02")
        addCostumePlayerHider(
            customeStorage[2], 
            game.localPlayer.character.gameObject, 
            Vector3.new(0, 0, 0)
        )
    end)

    btnObjHide03.Tapped:Connect(function()
        print("Disfraz 03")
        addCostumePlayerHider(
            customeStorage[3], 
            game.localPlayer.character.gameObject, 
            Vector3.new(0, 0, 0)
        )
    end)
end

function self:Update()
    if isFollowingAlwaysHider then 
        followingToTarget(
            dressWear,
            playerCurrent,
            5 * Time.deltaTime,
            posOffset
        )
    end
end