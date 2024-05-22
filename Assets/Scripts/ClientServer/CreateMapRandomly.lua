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

--Network Values
chosenMap = BoolValue.new("ChosenMap", false)

--Events
local createMapServer = Event.new("CreateMapServer")
local createMapClient = Event.new("CreateMapClient")
resetChosenMap = Event.new("ResetSelectedMap")

--Functions
local function enableDoorsZoneMap(statusDoor)
    doorsClosedZoneGreen:SetActive(statusDoor['doorClosedZG'])
    doorsOpenZoneGreen:SetActive(statusDoor['doorOpenZG'])
    doorsClosedZoneOrange:SetActive(statusDoor['doorClosedZO'])
    doorsOpenZoneOrange:SetActive(statusDoor['doorOpenZO'])
end

local function enableZoneMapChosen()
    if managerGame.opcMap.value == 1 then
        zones[1]:SetActive(false)
        zones[2]:SetActive(false)
    end

    for _,zone in ipairs(opcMapRandomly[managerGame.opcMap.value]) do
        if not zones[zone] then continue end
        zones[zone]:SetActive(true)
        
        if managerGame.opcMap.value == 2 then
            zones[2]:SetActive(false)
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
        enableZoneMapChosen()
    end)
end

function createMap(namePlayer)
    createMapServer:FireServer(namePlayer)
end

function self:ServerAwake()
    createMapServer:Connect(function(player : Player, namePlayer)
        if not chosenMap.value then
            managerGame.opcMap.value = math.random(1, 3)
            chosenMap.value = true
        end

        createMapClient:FireAllClients(player.name) 
    end)

    resetChosenMap:Connect(function(player : Player)
        chosenMap.value = false
    end)
end