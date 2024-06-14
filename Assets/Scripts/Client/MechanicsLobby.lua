--Managers
local managerGame = require('ManagerGame')

-- Ghost's custome in the Lobby
--!SerializeField
local ghostCustome01 : GameObject = nil
--!SerializeField
local ghostCustome02 : GameObject = nil
--!SerializeField
local ghostCustome03 : GameObject = nil

-- Pedestals of the custome in the lobby
--!SerializeField
local pedestalCustome01Lobby_btn01 : TapHandler = nil -- Button for your disguise of a death box
--!SerializeField
local pedestalCustome01Lobby_btn02 : TapHandler = nil -- Button for your disguise of a pumpkin
--!SerializeField
local pedestalCustome01Lobby_btn03 : TapHandler = nil -- Button for your disguise of a halloween tree
--!SerializeField
local pedestalCustome02Lobby_btn01 : TapHandler = nil -- Button for your disguise of a death box
--!SerializeField
local pedestalCustome02Lobby_btn02 : TapHandler = nil -- Button for your disguise of a pumpkin
--!SerializeField
local pedestalCustome02Lobby_btn03 : TapHandler = nil -- Button for your disguise of a halloween tree
--!SerializeField
local pedestalCustome03Lobby_btn01 : TapHandler = nil -- Button for your disguise of a ghost with a blue hat
--!SerializeField
local pedestalCustome03Lobby_btn02 : TapHandler = nil -- Button for your disguise of a ghost with a red hat
--!SerializeField
local pedestalCustome03Lobby_btn03 : TapHandler = nil -- Button for your disguise of a ghost with a axe in the head

--Functions
local function addCustomePlayerLobby(numDress, goalPlayer, offset, rotationCustome, tagPlayer)
    managerGame.cleanCustomeAndStopTrackingPlayer(game.localPlayer.name)

    managerGame.addCostumePlayers(
        managerGame.customeStorage[numDress], 
        goalPlayer, 
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

local function putCustomePlayerDeathBox()
    addCustomePlayerLobby(
        1, 
        game.localPlayer.character.gameObject, 
        Vector3.new(0, 1.954, 0),
        Vector3.new(90, 230, 0),
        "Hiding"
    )
end

local function putCustomePlayerPumpkin()
    addCustomePlayerLobby(
        2, 
        game.localPlayer.character.gameObject, 
        Vector3.new(0, 0, 0),
        Vector3.new(0, 230, 0),
        "Hiding"
    )
end

local function putCustomePlayerHalloweenTree()
    addCustomePlayerLobby(
        3, 
        game.localPlayer.character.gameObject, 
        Vector3.new(-0.247, 0, -0.357),
        Vector3.new(0, 230, 0),
        "Hiding"
    )
end

local function putCustomePlayerBookMagic()
    addCustomePlayerLobby(
        4, 
        game.localPlayer.character.gameObject, 
        Vector3.new(0, 1.8, 0),
        Vector3.new(90, 230, 0),
        "Hiding"
    )
end

local function putCustomePlayerWitchHat()
    addCustomePlayerLobby(
        5, 
        game.localPlayer.character.gameObject, 
        Vector3.new(0, 0.45, 0),
        Vector3.new(0, 230, 0),
        "Hiding"
    )
end

local function putCustomePlayerStumpPossesed()
    addCustomePlayerLobby(
        6, 
        game.localPlayer.character.gameObject, 
        Vector3.new(0, 0.4, 0),
        Vector3.new(0, 230, 0),
        "Hiding"
    )
end

local function putCustomePlayerGhostBlueHat()
    addCustomePlayerLobby(
        7, 
        game.localPlayer.character.gameObject, 
        Vector3.new(0, 0, 0),
        Vector3.new(0, 230, 0),
        "Hiding"
    )
end

local function putCustomePlayerGhostRedHat()
    addCustomePlayerLobby(
        8, 
        game.localPlayer.character.gameObject, 
        Vector3.new(0, 0, 0),
        Vector3.new(0, 230, 0),
        "Hiding"
    )
end

local function putCustomePlayerGhostAxe()
    addCustomePlayerLobby(
        9, 
        game.localPlayer.character.gameObject, 
        Vector3.new(0, 0, 0),
        Vector3.new(0, 230, 0),
        "Hiding"
    )
end

local function addCustomePlayerGhostStorage()
    managerGame.customeStorage[7] = ghostCustome01
    managerGame.customeStorage[8] = ghostCustome02
    managerGame.customeStorage[9] = ghostCustome03
end

--Unity Functions
function self:Awake()
    addCustomePlayerGhostStorage()

    --> Zone 01 of selecting a disguise
    pedestalCustome01Lobby_btn01.Tapped:Connect(function()
        putCustomePlayerDeathBox()
    end)
    pedestalCustome01Lobby_btn02.Tapped:Connect(function()
        putCustomePlayerPumpkin()
    end)
    pedestalCustome01Lobby_btn03.Tapped:Connect(function()
        putCustomePlayerHalloweenTree()
    end)

    --> Zone 02 of selecting a disguise
    pedestalCustome02Lobby_btn01.Tapped:Connect(function()
        putCustomePlayerBookMagic()
    end)
    pedestalCustome02Lobby_btn02.Tapped:Connect(function()
        putCustomePlayerWitchHat()
    end)
    pedestalCustome02Lobby_btn03.Tapped:Connect(function()
        putCustomePlayerStumpPossesed()
    end)

    --> Zone 03 of selecting a disguise
    pedestalCustome03Lobby_btn01.Tapped:Connect(function()
        putCustomePlayerGhostBlueHat()
    end)
    pedestalCustome03Lobby_btn02.Tapped:Connect(function()
        putCustomePlayerGhostRedHat()
    end)
    pedestalCustome03Lobby_btn03.Tapped:Connect(function()
        putCustomePlayerGhostAxe()
    end)
end