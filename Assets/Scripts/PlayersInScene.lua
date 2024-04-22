--Variables publics
--!SerializeField
local zoneDetectingSeeker : GameObject = nil
--!SerializeField
local menuSelecteObjHide : GameObject = nil
--!SerializeField
local objHide01 : GameObject = nil
--!SerializeField
local objHide02 : GameObject = nil
--!SerializeField
local objHide03 : GameObject = nil
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
    print("ARGS: ", target)
    zoneDetectingSeeker.transform.position = posZone
    isFollowingAlwaysSeeker = true
end

function activateMenuSelectedModelHide()
    print("Activating Menu")
    menuSelecteObjHide.SetActive(menuSelecteObjHide, true)
end

function self:ClientAwake()
    sendInfoAddZoneSeeker:Connect(function (args)
        menuSelecteObjHide.SetActive(menuSelecteObjHide, false)
        addZoneDetectionSeeker(args)
    end)

    sendActivateMenuHide:Connect(function (namePlayer)
        print("sendActivateMenuHide: ", namePlayer)
        activateMenuSelectedModelHide()
    end)
end

function self:ServerAwake()
    server.PlayerConnected:Connect(function(player : Player)
        player.CharacterChanged:Connect(function(player : Player, character : Character)
            if isFirstPlayer then
                player_id.value = "Seeker"
                playersTag[player.name] = player_id.value

                local target = player.character.gameObject.name
                sendInfoAddZoneSeeker:FireAllClients(target)
                
                isFirstPlayer = false
            else
                player_id.value = "Hiding"
                playersTag[player.name] = player_id.value

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

--UI
--!SerializeField
local function AddCharacterToPlayer()
    print("Adding Character To Player")
end