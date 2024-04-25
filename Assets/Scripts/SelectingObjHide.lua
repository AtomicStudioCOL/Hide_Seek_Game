--Modules
local managerGame = require("ManagerGame")

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
local posDress = Vector3.new(0, 0, 0)
local posOffset = Vector3.new(0, 0, 0)
local playerCustomed = StringValue.new("PlayerCustomed", "")
local objsCustome = {}

--Events
local showCustomeAllPlayersServer = Event.new("ShowCustomeAllPlayersServer")
local showCustomeAllPlayersClient = Event.new("ShowCustomeAllPlayersClient")

--Functions
function followingToTarget(current, target, maxDistanceDelta, positionOffset)
    if not current or not target then return end

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
    
    if playerCurrent then
        posDress = playerCurrent.transform.position + posOffset
    end
    
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
        --playerCustomed = game.localPlayer.name
        managerGame.playerActivateCustome.value = game.localPlayer.name
        showCustomeAllPlayersServer:FireServer()

        for name, player in pairs(objsCustome) do
            print("Name player: ", name, " player obj: ", tostring(player))
        end
    end)

    showCustomeAllPlayersClient:Connect(function()
        print("Cliente: ", game.localPlayer.name)
        print("Player que activo el disfraz: ", playerCustomed.value)
        print("Player OBJ Table: ", tostring(objsCustome[playerCustomed.value]))

        addCostumePlayerHider(
            customeStorage[1], 
            objsCustome[playerCustomed.value], 
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

function self:ServerAwake()
    showCustomeAllPlayersServer:Connect(function(player : Player)
        playerCustomed.value = player.name
        showCustomeAllPlayersClient:FireAllClients()
    end)

    --[[ for name, player in pairs(managerGame.playerObjTag) do
        print("Name player: ", name, " player obj: ", tostring(player))
    end ]]
end

scene.PlayerJoined:Connect(function(scene : WorldScene, player : Player)
    player.CharacterChanged:Connect(function (player : Player, character : Character)
        print(tostring(player.name), " joined the scene.")
        print(tostring(player.name), " changed their character to", tostring(character))
        objsCustome[player.name] = character.gameObject
    end)
end)

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