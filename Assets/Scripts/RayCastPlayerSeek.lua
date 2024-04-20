local rayLenght : number = 10.0
local playerClient : GameObject = nil

function self:ClientStart()
    print("Start: ", client.localPlayer.character.gameObject.name)
    playerClient = client.localPlayer.character.gameObject

    Input.Tapped:Connect(function (hit : TapEvent)
        print("Input Tapped: ", tostring(hit.position))
        print(Input.Tapped.name, " ", tostring(hit.startFrame))
    end)
end

function self:ClientUpdate()
    --local orig : Vector3 = playerClient.transform.position
    --local dir : Vector3 = playerClient.transform.TransformDirection(self, Vector3.forward)
    local rayLight : Ray = Ray.new(self.transform.position, self.transform.forward)
    local hit : RaycastHit

    --print(tostring(orig))
    --print(tostring(dir))
    --print(tostring(playerClient.transform.forward))
    --print(tostring(hit))
    --print(tostring(rayLight))
    if Physics.Raycast(rayLight, 20, 0) then
        print(hit.collider)
        if hit.collider ~= nil then
            print("Collider Ray: ", hit.collider.name)
        end
    end
end