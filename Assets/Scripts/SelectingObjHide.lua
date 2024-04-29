--Modules
local managerGame = require("ManagerGame")

--Functions
local function addCostumePlayerHiding(numDress : number, localPlayerObj : GameObject, offset : Vector3, tagPlayer : string)
    managerGame.addCostumePlayers(
        managerGame.customeStorage[numDress],
        localPlayerObj,
        offset,
        tagPlayer
    )

    managerGame.customePlayers[game.localPlayer.name] = {
        ["Dress"] = managerGame.customeStorage[numDress],
        ["Offset"] = offset
    }
    managerGame.showCustomeAllPlayersServer:FireServer(
        numDress,
        game.localPlayer.name,
        offset
    )
end

--Unity Function
function self:ClientAwake()
    managerGame.btnObjHide01Global.Tapped:Connect(function()
        print("Disfraz 01")
        addCostumePlayerHiding(
            1, 
            game.localPlayer.character.gameObject, 
            Vector3.new(0, 1.579, 0), 
            managerGame.playersTag[game.localPlayer.name]
        )
    end)

    managerGame.btnObjHide02Global.Tapped:Connect(function()
        print("Disfraz 02")
        addCostumePlayerHiding(
            2,
            game.localPlayer.character.gameObject,
            Vector3.new(0, 0, 0),
            managerGame.playersTag[game.localPlayer.name]
        )
    end)

    managerGame.btnObjHide03Global.Tapped:Connect(function()
        print("Disfraz 03")
        addCostumePlayerHiding(
            3, 
            game.localPlayer.character.gameObject, 
            Vector3.new(0, 0, 0),
            managerGame.playersTag[game.localPlayer.name]
        )
    end)
end