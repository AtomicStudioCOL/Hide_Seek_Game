local rayLenght : number = 10.0
local playerClient : GameObject = nil

function self:Update()
    local rayLight : Ray = Ray.new(self.transform.position, self.transform.forward)
    local success, hit = Physics.Raycast(rayLight, math.huge, 0)

    print("RayCast success: ", tostring(success))
    print("RayCast hit: ", tostring(hit.collider))
    if success then
        if hit.collider ~= nil then
            print("Collider Ray: ", hit.collider.name)
        end
    end
end