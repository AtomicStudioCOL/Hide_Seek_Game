--Manager
local managerGame = require("ManagerGame")

--Variables 
local zones = {}
local doorsClosedZoneGreen : GameObject = nil
local doorsOpenZoneGreen : GameObject = nil
local doorsClosedZoneOrange : GameObject = nil
local doorsOpenZoneOrange : GameObject = nil
local opcMapRandomly = {
    [1] = {},
    [2] = {1},
    [3] = {1, 2},
}

--Events
local createMapServer = Event.new("CreateMapServer")
local createMapClient = Event.new("CreateMapClient")


--Functions
local function enableDoorsZoneMap(statusDoor)
    doorsClosedZoneGreen:SetActive(statusDoor['doorClosedZG'])
    doorsOpenZoneGreen:SetActive(statusDoor['doorOpenZG'])
    doorsClosedZoneOrange:SetActive(statusDoor['doorClosedZO'])
    doorsOpenZoneOrange:SetActive(statusDoor['doorOpenZO'])
end

local function enableZoneMapChosen()
    for _,zone in ipairs(opcMapRandomly[managerGame.opcMap.value]) do
        if not zones[zone] then continue end
        zones[zone]:SetActive(true)
        
        if managerGame.opcMap.value == 2 then
            enableDoorsZoneMap({
                ['doorClosedZG'] = false,
                ['doorOpenZG'] = true,
                ['doorClosedZO'] = true,
                ['doorOpenZO'] = false
            })
        elseif managerGame.opcMap.value == 3 then
            enableDoorsZoneMap({
                ['doorClosedZG'] = false,
                ['doorOpenZG'] = true,
                ['doorClosedZO'] = false,
                ['doorOpenZO'] = true
            })
        end
    end
end

--Unity Functions
function self:ClientAwake()
    zones[1] = managerGame.zoneGreenGlobal
    zones[2] = managerGame.zoneOrangeGlobal
    doorsClosedZoneGreen = managerGame.doorsClosedZoneGreenGlobal
    doorsOpenZoneGreen = managerGame.doorsOpenZoneGreenGlobal
    doorsClosedZoneOrange = managerGame.doorsClosedZoneOrangeGlobal
    doorsOpenZoneOrange = managerGame.doorsOpenZoneOrangeGlobal

    enableDoorsZoneMap({
        ['doorClosedZG'] = true,
        ['doorOpenZG'] = false,
        ['doorClosedZO'] = false,
        ['doorOpenZO'] = false
    })

    createMapClient:Connect(function(namePlayer)
        if namePlayer == game.localPlayer.name then
            enableZoneMapChosen()
        end
    end)
end

function createMap(namePlayer)
    createMapServer:FireServer(namePlayer)
end

function self:ServerAwake()
    createMapServer:Connect(function(player : Player, namePlayer)
        if namePlayer == managerGame.whoIsSeeker.value then
            managerGame.opcMap.value = math.random(1, 3)
        end
        createMapClient:FireAllClients(player.name) 
    end)
end