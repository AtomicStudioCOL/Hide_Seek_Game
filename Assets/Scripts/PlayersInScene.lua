--Variables publics
--!SerializeField
local zoneDetectingSeeker : GameObject = nil
--!SerializeField
local objsHides : GameObject = nil

--Variables no publics
local tagZone : GameObject = nil
local playersTag = {} -- Storage all player in the scene
local isFirstPlayer = true -- If it's first player or not
local isFollowingAlwaysSeeker = false -- Start follow to the seeker is off

--Network Values
local player_id = StringValue.new("PlayerId", "")

--Events
local sendInfoAddZoneSeeker = Event.new("SendInfoAddZoneSeeker")
local sendActivateMenuHide = Event.new("SendActivateMenuHide")

function followingToTarget(current, target, maxDistanceDelta)
    current.transform.position = Vector3.MoveTowards(
        current.transform.position, 
        target.transform.position + Vector3.new(0, 1.5, 0), 
        maxDistanceDelta
    )
end

function addZoneDetectionSeeker(target)
    tagZone = GameObject.Find(tostring(target) .. "(Clone)")
    local posZone = tagZone.transform.position + Vector3.new(0, 1.5, 0)

    zoneDetectingSeeker.transform.position = posZone
    zoneDetectingSeeker.SetActive(zoneDetectingSeeker, true)
    isFollowingAlwaysSeeker = true
end

function activateMenuSelectedModelHide(namePlayer)
    if playersTag[namePlayer] == "Hiding" then
        objsHides.SetActive(objsHides, true)
    end
end

function self:ClientAwake()
    sendInfoAddZoneSeeker:Connect(function (args, namePlayer)
        if not playersTag[namePlayer] and client.localPlayer.name == namePlayer then
            playersTag[namePlayer] = player_id.value
            objsHides.SetActive(objsHides, false)
            addZoneDetectionSeeker(args)
        end
    end)

    sendActivateMenuHide:Connect(function (namePlayer)
        if not playersTag[namePlayer] and client.localPlayer.name == namePlayer then
            playersTag[namePlayer] = player_id.value
            activateMenuSelectedModelHide(namePlayer)
        end
    end)
end

function self:ServerAwake()
    server.PlayerConnected:Connect(function(player : Player)
        player.CharacterChanged:Connect(function(player : Player, character : Character)
            if isFirstPlayer then
                player_id.value = "Seeker"

                local target = player.character.gameObject.name
                sendInfoAddZoneSeeker:FireAllClients(target, player.name)
                
                isFirstPlayer = false
            else
                player_id.value = "Hiding"
                sendActivateMenuHide:FireAllClients(player.name)
            end
        end)
    end)

    server.PlayerDisconnected:Connect(function(player)
        playersTag[player.name] = nil
    end)
end

function self:Update()
    if isFollowingAlwaysSeeker then 
        followingToTarget(
            zoneDetectingSeeker,
            tagZone,
            5 * Time.deltaTime
        )
    end
end