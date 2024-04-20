--Events
local eventToServer = Event.new("SendInfoServer")
local eventToClient = Event.new("SendInfoClient")

local target : GameObject = nil
local moveToPlayer : boolean = false
local isFirstPlayer : number = 1
--local rayLength : number = 10.0

function self:ClientAwake()
    local objHidden : GameObject = self.gameObject -- GameObject.FindWithTag("Player_Hidden")
    print("Obj Hidden: ", objHidden.name)
    local tapHandlerObj : TapHandler = objHidden:GetComponent(TapHandler)

    print("Tap Handler: ", tapHandlerObj.name)

    if tapHandlerObj == nil then
        print("Adding Tap Handler")
        objHidden:AddComponent(TapHandler)
        tapHandlerObj = objHidden:GetComponent(TapHandler)
    end

    tapHandlerObj.Tapped:Connect(function(hit)
        --Sending information to the server
        print("Input Tapped: ", tostring(hit))
        eventToServer:FireServer()
    end)

    eventToClient:Connect(function ()
        print("Type Player: ", self.gameObject.name, " received data from Server.")
        print("Client - Player: ", client.localPlayer.name)
        if self.gameObject.name == "Player_Hidden" then
            target = client.localPlayer.character.gameObject
            tapHandlerObj.enabled = false
            moveToPlayer = true
        end
    end) 
end

function self:ServerAwake()
    --Setting up events for client
    eventToServer:Connect(function(player)
        print("Player: ", player.name, " || ", player.id)
        eventToClient:FireAllClients()
    end)
end

function self:Update()
    --[[ local ray : Ray = Ray.new(client.localPlayer.character.gameObject.transform.position, client.localPlayer.character.gameObject.transform.forward) --Creating a Ray
    local hit : RaycastHit

    if (Physics.Raycast(ray, hit.distance, rayLength)) then
        if hit.collider ~= nil then
            print("Collider Ray: ", hit.collider.name)
        end
    end --]]

    if moveToPlayer then
        local dis = Vector3.Distance(self.transform.position, target.transform.position)
        
        if dis >= 1.5 then
            self.transform.position = Vector3.MoveTowards(self.transform.position, target.transform.position, 5 * Time.deltaTime)
        end
    end
end

--[[ 
scene.PlayerJoined:Connect(function (scene, player : Player)
    if isFirstPlayer == 1 then
        print(player.name, " joined the game")
        print("Tag Player: ", player.character)
        --player.character.tag = "Seek"
        --isFirstPlayer += 1
    else
        player.character.tag = "Player_Hidden"
    end
end)

client.PlayerConnected:Connect(function (player)
    if isFirstPlayer == 1 then
        print(player.name, " joined the game")
        print("Tag Player: ", player.character)
        --player.character.tag = "Seek"
        --isFirstPlayer += 1
    else
        player.character.tag = "Player_Hidden"
    end
end)   
--]]