-- requiered scripts --
local managerGame = require("ManagerGame")
local audioManager = require("AudioManager")

-- serialized variables --
--!SerializeField
local blue : Material = nil
--!SerializeField
local yellow : Material = nil
--!SerializeField
local red : Material = nil
--!SerializeField
local colorIndex : number = 0
--!SerializeField
local distanceToYellow : number = 2
--!SerializeField
local distanceToRed : number = 1

-- variables --
local thisObject = self.gameObject
local seeker = managerGame.objsCustome[managerGame.whoIsSeeker.value]
local audio = thisObject:GetComponent(AudioSource)

-- functions --

local function TableLenght(table)
    local length : number = 0
    for i, _ in ipairs(table) do
        length += 1
    end
    return length
end

function updateSeeker()
    seeker = managerGame.objsCustome[managerGame.whoIsSeeker.value]
end

---[[
local function ClosestHider()
    for key, value in pairs(managerGame.objsCustome) do
        if tostring(value) == 'null' or not value then continue end
        
        if key ~= managerGame.whoIsSeeker.value then --and managerGame.tagPlayerFound[key] ~= "Found"
            if not seeker then continue end
            if not seeker.transform or not value.transform then continue end
            
            if math.abs(value.transform.position.x - seeker.transform.position.x) < distanceToRed
            and
            math.abs(value.transform.position.z - seeker.transform.position.z) < distanceToRed
            then
                colorIndex = 2
                break
            elseif math.abs(value.transform.position.x - seeker.transform.position.x) < distanceToYellow
            and
            math.abs(value.transform.position.z - seeker.transform.position.z) < distanceToYellow
            then
               colorIndex = 1
               break
            else
                colorIndex = 0
            end
        end
    end
end
--]]

function self:Update()
    ClosestHider()

    if colorIndex == 0 then
        thisObject:GetComponent(Renderer).material = blue
        audioManager.pauseAlertPlayerSeeker(audio, 0)
    elseif colorIndex == 1 then
        thisObject:GetComponent(Renderer).material = yellow
        audioManager.playAlertPlayerSeeker(audio, 0.5)
    elseif colorIndex == 2 then
        thisObject:GetComponent(Renderer).material = red
        audioManager.playAlertPlayerSeeker(audio, 1)
    end
end


-- event calls --