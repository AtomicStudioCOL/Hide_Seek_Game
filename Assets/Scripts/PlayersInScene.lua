--Modules
local managerGame = require("ManagerGame")

--Variables no publics
local zoneDetectingSeeker : GameObject = nil
local playersTag = {} -- Storage all player in the scene
local tagZone : GameObject = nil
local isFirstPlayer = true -- If it's first player or not
local isFollowingAlwaysSeeker = false -- Start follow to the seeker is off
local charPlayer : GameObject = nil

--Network Values
local player_id = StringValue.new("PlayerId", "")

--Events
local sendInfoAddZoneSeeker = Event.new("SendInfoAddZoneSeeker")
local sendActivateMenuHide = Event.new("SendActivateMenuHide")

--Functions
local function addZoneDetectionSeeker(target, namePlayer)
    tagZone = target
    managerGame.playerObjTag[namePlayer] = tagZone

    managerGame.addCostumePlayers(
        zoneDetectingSeeker, 
        tagZone,
        Vector3.new(0, 1.5, 0), 
        playersTag[namePlayer],
        {}
    )
end

local function activateMenuSelectedModelHide(player, namePlayer)
    if playersTag[namePlayer] == "Hiding" then
        managerGame.playerObjTag[namePlayer] = player
        managerGame.activateMenuModelHide(true)
    end
end

--Unity Functions
function self:ClientAwake()
    sendInfoAddZoneSeeker:Connect(function (char, namePlayer)
        if not playersTag[namePlayer] and client.localPlayer.name == namePlayer then
            zoneDetectingSeeker = managerGame.zoneDetectingSeekerGlobal
            charPlayer = char.gameObject

            playersTag[namePlayer] = player_id.value
            managerGame.activateMenuModelHide(false)
            addZoneDetectionSeeker(charPlayer, namePlayer)
        end
    end)

    sendActivateMenuHide:Connect(function (char, namePlayer)
        if not playersTag[namePlayer] and client.localPlayer.name == namePlayer then
            playersTag[namePlayer] = player_id.value
            charPlayer = char.gameObject
            activateMenuSelectedModelHide(charPlayer, namePlayer)
        end
    end)
end

function self:ServerAwake()
    server.PlayerConnected:Connect(function(player : Player)
        player.CharacterChanged:Connect(function(player : Player, character : Character)
            if isFirstPlayer then
                player_id.value = "Seeker"
                sendInfoAddZoneSeeker:FireAllClients(character, player.name)
                isFirstPlayer = false
            else
                player_id.value = "Hiding"
                sendActivateMenuHide:FireAllClients(character, player.name)
            end
        end)
    end)

    server.PlayerDisconnected:Connect(function(player : Player)
        playersTag[player.name] = nil
    end)
end