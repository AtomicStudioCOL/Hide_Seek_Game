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

--Unity Functions
function self:ClientAwake()
    zones[1] = managerGame.zoneGreenGlobal
    zones[2] = managerGame.zoneOrangeGlobal
    doorsClosedZoneGreen = managerGame.doorsClosedZoneGreenGlobal
    doorsOpenZoneGreen = managerGame.doorsOpenZoneGreenGlobal
    doorsClosedZoneOrange = managerGame.doorsClosedZoneOrangeGlobal
    doorsOpenZoneOrange = managerGame.doorsOpenZoneOrangeGlobal

    doorsClosedZoneGreen:SetActive(true)
    doorsOpenZoneGreen:SetActive(false)
    doorsClosedZoneOrange:SetActive(false)
    doorsOpenZoneOrange:SetActive(false)

    createMapClient:Connect(function(namePlayer)
        if namePlayer == game.localPlayer.name then    
            for _,zone in ipairs(opcMapRandomly[managerGame.opcMap.value]) do
                if not zones[zone] then continue end
                zones[zone]:SetActive(true)
                
                if managerGame.opcMap.value == 2 then
                    doorsClosedZoneGreen:SetActive(false)
                    doorsOpenZoneGreen:SetActive(true)
                    doorsClosedZoneOrange:SetActive(true)
                    doorsOpenZoneOrange:SetActive(false)
                elseif managerGame.opcMap.value == 3 then
                    doorsClosedZoneGreen:SetActive(false)
                    doorsOpenZoneGreen:SetActive(true)
                    doorsClosedZoneOrange:SetActive(false)
                    doorsOpenZoneOrange:SetActive(true)
                end
            end
        end
    end)
end

function self:ServerAwake()
    server.PlayerConnected:Connect(function(player : Player)
        player.CharacterChanged:Connect(function(player : Player, character : Character)
            if player.name == managerGame.whoIsSeeker.value then
                managerGame.opcMap.value = math.random(1, 3)
            end

            createMapClient:FireAllClients(player.name)        
        end)
    end)
end