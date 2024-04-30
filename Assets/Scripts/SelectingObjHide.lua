--Modules
local managerGame = require("ManagerGame")

local dressWear : GameObject = nil
local playerCurrent = nil
local posOffset = Vector3.new(0, 0, 0)
local isFollowingAlways01 = false
local isFollowingAlways02 = false
local isFollowingAlways03 = false

--Functions
local function disableAllDresses()
    for _,dress in ipairs(managerGame.customeStorage) do
        dress.SetActive(dress, false)
    end
end

local function addCostumePlayerHiding(numDress : number, localPlayerObj : GameObject, offset : Vector3, tagPlayer : string)
    if managerGame.customePlayers[game.localPlayer.name] then
        --print("Player: ", game.localPlayer.name, " destruye anterior disfraz: ", tostring(managerGame.customePlayers[game.localPlayer.name]["Dress"]))
        Object.Destroy(managerGame.customePlayers[game.localPlayer.name]["Dress"])
        managerGame.customePlayers[game.localPlayer.name] = nil
    end
    
    managerGame.addCostumePlayers(
        managerGame.customeStorage[numDress],
        localPlayerObj,
        offset,
        tagPlayer,
        game.localPlayer.name
    )
    --[[ dressWear = managerGame.customeStorage[numDress]
    playerCurrent = localPlayerObj
    posOffset = offset
    disableAllDresses()

    local posDress = playerCurrent.transform.position + posOffset
    dressWear.transform.position = posDress
    dressWear.SetActive(dressWear, true) ]]
    --[[ managerGame.customePlayers[game.localPlayer.name] = {
        ["Dress"] = managerGame.customeStorage[numDress],
        ["Player"] = game.localPlayer.character.gameObject,
        ["Offset"] = offset
    } ]]
    managerGame.showCustomeAllPlayersServer:FireServer(
        numDress,
        game.localPlayer.name,
        offset
    )
end

--Unity Function
function self:Awake()
    managerGame.btnObjHide01Global.Tapped:Connect(function()
        print("Disfraz 01")
        addCostumePlayerHiding(
            1, 
            game.localPlayer.character.gameObject, 
            Vector3.new(0, 1.579, 0), 
            managerGame.playersTag[game.localPlayer.name]
        )
        isFollowingAlways01 = true
        isFollowingAlways02 = false
        isFollowingAlways03 = false
    end)

    managerGame.btnObjHide02Global.Tapped:Connect(function()
        print("Disfraz 02")
        addCostumePlayerHiding(
            2,
            game.localPlayer.character.gameObject,
            Vector3.new(0, 0, 0),
            managerGame.playersTag[game.localPlayer.name]
        )

        isFollowingAlways01 = false
        isFollowingAlways02 = true
        isFollowingAlways03 = false
    end)

    managerGame.btnObjHide03Global.Tapped:Connect(function()
        print("Disfraz 03")
        addCostumePlayerHiding(
            3, 
            game.localPlayer.character.gameObject, 
            Vector3.new(0, 0, 0),
            managerGame.playersTag[game.localPlayer.name]
        )

        isFollowingAlways01 = false
        isFollowingAlways02 = false
        isFollowingAlways03 = true
    end)
end

function self:Update()
    if isFollowingAlways01 then 
        --revisar si hay otro player con disfraz y moverlo
        managerGame.followingToTarget(
            dressWear,
            playerCurrent,
            5 * Time.deltaTime,
            posOffset
        )
    end

    if isFollowingAlways02 then 
        managerGame.followingToTarget(
            dressWear,
            playerCurrent,
            5 * Time.deltaTime,
            posOffset
        )
    end

    if isFollowingAlways03 then 
        managerGame.followingToTarget(
            dressWear,
            playerCurrent,
            5 * Time.deltaTime,
            posOffset
        )
    end
end