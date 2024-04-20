function self:Start()
    print("Ejecutando Script Detecting Collisions")
end

function self:OnTriggerEnter(other : Collider)
    local enteringGameObject = other.gameObject
    print(enteringGameObject.name .. " has entered the trigger")
end

function self:OnTriggerExit(other : Collider)
    local exitingGameObject = other.gameObject
    print(exitingGameObject.name .. " has left the trigger")
end

function self:OnCollisionEnter(other : Collision)
    print("I collided with a collider named " .. other.gameObject.name)
end

function self:OnCollisionExit(other : Collision)
    print("I stopped colliding with and touching a collider named " .. other.gameObject.name)
end