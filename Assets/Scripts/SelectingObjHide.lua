--Modules
local managerGame = require("ManagerGame")

--Functions
local function addCostumePlayerHiding(numDress : number, localPlayerObj : GameObject, offset : Vector3, tagPlayer : string)
    if managerGame.customePlayers[game.localPlayer.name] then
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

    managerGame.showCustomeAllPlayersServer:FireServer(
        numDress,
        game.localPlayer.name,
        offset
    )
end

local function addCostumePlayer01()
    addCostumePlayerHiding(
        1, 
        game.localPlayer.character.gameObject, 
        Vector3.new(0, 1.579, 0), 
        managerGame.playersTag[game.localPlayer.name]
    )
end

local function addCostumePlayer02()
    addCostumePlayerHiding(
        2,
        game.localPlayer.character.gameObject,
        Vector3.new(0, 0, 0),
        managerGame.playersTag[game.localPlayer.name]
    )
end

local function addCostumePlayer03()
    addCostumePlayerHiding(
        3, 
        game.localPlayer.character.gameObject, 
        Vector3.new(0, 0, 0),
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