--Modules
local managerGame = require("ManagerGame")

--Variables
local offsetPedestal = {
    [1] = Vector3.new(0, 1.954, 0),
    [2] = Vector3.new(0, 0, 0),
    [3] = Vector3.new(-0.247, 0, -0.357),
    [4] = Vector3.new(0, 1.8, 0),
    [5] = Vector3.new(0, 0.45, 0),
    [6] = Vector3.new(0, 0.4, 0),
}

--Functions
local function addCostumePlayerHiding(numDress : number, localPlayerObj : GameObject, offset : Vector3, rotationCustome, tagPlayer : string)
    managerGame.cleanCustomeAndStopTrackingPlayer(game.localPlayer.name)
    
    managerGame.addCostumePlayers(
        managerGame.customeStorage[numDress],
        localPlayerObj,
        offset,
        rotationCustome,
        tagPlayer,
        game.localPlayer.name
    )

    managerGame.showCustomeAllPlayersServer:FireServer(
        numDress,
        game.localPlayer.name,
        offset,
        rotationCustome
    )
end

local function addCostumePlayer01()
    addCostumePlayerHiding(
        managerGame.customePlayersSelected[1], 
        game.localPlayer.character.gameObject, 
        offsetPedestal[managerGame.customePlayersSelected[1]],
        Vector3.new(90, 230, 0),
        managerGame.playersTag[game.localPlayer.name]
    )
end

local function addCostumePlayer02()
    addCostumePlayerHiding(
        managerGame.customePlayersSelected[2],
        game.localPlayer.character.gameObject,
        offsetPedestal[managerGame.customePlayersSelected[2]],
        Vector3.new(0, 230, 0),
        managerGame.playersTag[game.localPlayer.name]
    )
end

local function addCostumePlayer03()
    addCostumePlayerHiding(
        managerGame.customePlayersSelected[3], 
        game.localPlayer.character.gameObject, 
        offsetPedestal[managerGame.customePlayersSelected[3]],
        Vector3.new(0, 230, 0),
        managerGame.playersTag[game.localPlayer.name]
    )
end

--Unity Function
function self:Awake()
    --Stand Custome 01
    managerGame.btnsObjHides["PointRespawn01"][1].Tapped:Connect(function()
        addCostumePlayer01()
    end)

    managerGame.btnsObjHides["PointRespawn01"][2].Tapped:Connect(function()  
        addCostumePlayer02()
    end)

    managerGame.btnsObjHides["PointRespawn01"][3].Tapped:Connect(function()
        addCostumePlayer03()
    end)

    --Stand Custome 02
    managerGame.btnsObjHides["PointRespawn02"][1].Tapped:Connect(function()
        addCostumePlayer01()
    end)

    managerGame.btnsObjHides["PointRespawn02"][2].Tapped:Connect(function()  
        addCostumePlayer02()
    end)

    managerGame.btnsObjHides["PointRespawn02"][3].Tapped:Connect(function()
        addCostumePlayer03()
    end)

    --Stand Custome 03
    managerGame.btnsObjHides["PointRespawn0304"][1].Tapped:Connect(function()
        addCostumePlayer01()
    end)

    managerGame.btnsObjHides["PointRespawn0304"][2].Tapped:Connect(function()  
        addCostumePlayer02()
    end)

    managerGame.btnsObjHides["PointRespawn0304"][3].Tapped:Connect(function()
        addCostumePlayer03()
    end)
end