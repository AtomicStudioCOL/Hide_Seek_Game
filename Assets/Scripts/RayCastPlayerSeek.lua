local rayLenght : number = 10.0
local playerClient : GameObject = nil

function self:Update()
    local rayLight : Ray = Ray.new(self.transform.position, Vector3.forward)
    local hit : RaycastHit
    local physicsRay = Physics.Raycast(rayLight, 20, 10)

    if Physics.Raycast(rayLight, 20, 10) then
        print(hit.collider)
        if hit.collider ~= nil then
            print("Collider Ray: ", hit.collider.name)
        end
    end
end