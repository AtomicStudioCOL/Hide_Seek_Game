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
local uiManager = nil
local isEnabledBtnFlashlight = false

-- functions --
local function TableLenght(table)
    local length : number = 0
    for i, _ in ipairs(table) do
        length += 1
    end
    return length
end

local function closestHider()
    for name, obj in pairs(managerGame.objsCustome) do
        if name ~= managerGame.whoIsSeeker.value then
            if tostring(obj) == 'null' or not obj then continue end
            if not seeker or not seeker.transform then continue end

            if math.abs(obj.transform.position.x - seeker.transform.position.x) < distanceToRed
            and
            math.abs(obj.transform.position.z - seeker.transform.position.z) < distanceToRed
            and
            managerGame.tagPlayerFound[name] ~= 'Found'
            then
                colorIndex = 2
                break
            elseif math.abs(obj.transform.position.x - seeker.transform.position.x) < distanceToYellow
            and
            math.abs(obj.transform.position.z - seeker.transform.position.z) < distanceToYellow
            and
            managerGame.tagPlayerFound[name] ~= 'Found'
            then
                colorIndex = 1
                break
            else
                colorIndex = 0
            end
        end
    end
end

function updateSeeker()
    uiManager = managerGame.UIManagerGlobal:GetComponent(UI_Hide_Seek)
    seeker = managerGame.objsCustome[managerGame.whoIsSeeker.value]
end

--Unity Functions
function self:Update()
    if game.localPlayer.name == managerGame.whoIsSeeker.value then
        closestHider()
    end
    
    if colorIndex == 0 then
        thisObject:GetComponent(Renderer).material = blue
        if game.localPlayer.name == managerGame.whoIsSeeker.value then
            uiManager.alertHiddenPlayerNearby('', false)
            audioManager.pauseAlertPlayerSeeker(audio, 0)
            
            if isEnabledBtnFlashlight then
                isEnabledBtnFlashlight = false
                uiManager.StatusBtnFlashlightSeeker(isEnabledBtnFlashlight)
            end
        end
    elseif colorIndex == 1 then
        thisObject:GetComponent(Renderer).material = yellow
        if game.localPlayer.name == managerGame.whoIsSeeker.value then
            uiManager.alertHiddenPlayerNearby('Alert! A hidden player is nearby', true)
            audioManager.playAlertPlayerSeeker(audio, 0.5)
            
            if not isEnabledBtnFlashlight then
                isEnabledBtnFlashlight = true
                uiManager.StatusBtnFlashlightSeeker(isEnabledBtnFlashlight)
            end
        end
    elseif colorIndex == 2 then
        thisObject:GetComponent(Renderer).material = red
        if game.localPlayer.name == managerGame.whoIsSeeker.value then
            uiManager.alertHiddenPlayerNearby('Alert! A hidden player is nearby', true)
            audioManager.playAlertPlayerSeeker(audio, 1)

            if not isEnabledBtnFlashlight then
                isEnabledBtnFlashlight = true
                uiManager.StatusBtnFlashlightSeeker(isEnabledBtnFlashlight)
            end
        end
    end
end