--!SerializeField
local zoom : number = 15
--!SerializeField
local zoomMin : number = 10
--!SerializeField
local zoomMax : number = 50
--!SerializeField
local fov : number = 30
--!SerializeField
local pitch : number = 30
--!SerializeField
local yaw : number = 45
--!SerializeField
local centerOnCharacterWhenSpawned : boolean = true

local camera = self.gameObject:GetComponent(Camera)
if not camera then return end
local cameraRig : Transform = camera.transform -- quick reference to the camera's transform

local inertiaVelocity : Vector3 = Vector3.zero;  -- the current velocity of the camera fom inertia
local inertiaMagnitude : number = 0;             -- the magnitude of the current InertiaVelocity (this is an optimization to avoid calculating it every frame)
local inertiaDampeningFactor : number = 0.93     -- The multiplier used to scale the inertia force back over time.

local rotation : Vector3 = Vector3.zero          -- the rotation of the camera (.y can be thought of it as the "swivel" of the camera around the Target)
local target = Vector3.zero                      -- the point the camera is looking at
local offset = Vector3.zero                      -- the offset from the Target

charPlayer = nil
local localCharacterInstantiatedEvent = nil
local InertiaMinVelocity = 0.5; -- prevents the infinite slow drag at the end of inertia
local InertiaStepDuration = 1 / 60; -- each "inertia step" is normalized to 60fps

--Functions
function CenterOn(newTarget, newZoom)
    zoom = newZoom or zoom

    target = newTarget
    zoom = Mathf.Clamp(zoom, zoomMin, zoomMax)
    offset = Vector3.new(0, 0, offset.z)
end

function IsActive()
    return camera ~= nil and camera.isActiveAndEnabled
end

if centerOnCharacterWhenSpawned then
    function OnLocalCharacter(player, character)
        localCharacterInstantiatedEvent:Disconnect()
        localCharacterInstantiatedEvent = nil

       local position = character.gameObject.transform.position
       CenterOn(position)
    end

    localCharacterInstantiatedEvent = client.localPlayer.CharacterChanged:Connect(function(player, character)
        if character then
            charPlayer = character
            OnLocalCharacter(player, character)
        end
    end)
end

function UpdateInertia()
    if not Input.isMouseInput and inertiaMagnitude > InertiaMinVelocity then
        local stepReduction = (1.0 - inertiaDampeningFactor) / (InertiaStepDuration / Time.deltaTime)
        local velocityDampener = 1.0 - math.min(math.max(stepReduction, 0), 1)
        inertiaVelocity = inertiaVelocity * velocityDampener
        inertiaMagnitude = inertiaMagnitude * velocityDampener
        target = target + (inertiaVelocity * Time.deltaTime)
    end
end

function UpdatePosition()
    local rotation = Quaternion.Euler(
        pitch + rotation.x,
        yaw + rotation.y,
        0
    )

    local frustumHeight = zoom
    local distance = (frustumHeight * 0.5) / math.tan(fov * 0.5 * Mathf.Deg2Rad)
    camera.fieldOfView = fov

    local cameraPos = Vector3.back * distance
    cameraPos = rotation * cameraPos
    cameraPos = cameraPos + target
    local cameraOffset = cameraRig.rotation * offset
    
    cameraRig.position = cameraPos
    cameraRig:LookAt(target)

    if not charPlayer.gameObject or not charPlayer then return end
    cameraRig.position = cameraRig.position + (charPlayer.gameObject.transform.position + cameraOffset)
end

function self:Update()
    if not IsActive() then return end

    UpdateInertia()
    UpdatePosition()
end