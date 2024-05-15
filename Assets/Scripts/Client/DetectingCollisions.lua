--Modules
local managerGame = require('ManagerGame')
local audioManager = require('AudioManager')

--Variable publics
--!SerializeField
local vfxFoundPlayer : GameObject = nil
--!SerializeField
local ghostFoundFirstPlayer : GameObject = nil

--Local Variables
local seekerPlayer : GameObject = nil
local tagSeeker : string = "Seeker"
local playerSeeker : GameObject = nil
local uiManager = nil
local infoGameModule = nil

--Global Variables
ghost = nil
isAddedGhost = false
ghostFollowingSeeker = false

--Functions
local function followingToTarget(current, target, maxDistanceDelta, positionOffset)
    if not current or not target then return end
    
    current.transform.position = Vector3.MoveTowards(
        current.transform.position, 
        target.transform.position + positionOffset, 
        maxDistanceDelta
    )
end

local function AddGhostFollowingSeeker(seeker, ghostFollow)
    ghost = Object.Instantiate(ghostFollow)
    playerSeeker = seeker

    local posGhost = playerSeeker.transform.position + Vector3.new(-0.1, 1.5, 0.6)

    ghost.transform.position = posGhost
    ghost:SetActive(true)
    ghostFollowingSeeker = true
end

function ResetFireFlyPlayerSeeker()
    if not managerGame.playerPetGlobal then return end
    managerGame.playerPetGlobal:SetActive(false)
end

function ResetFireFlyCollision(status)
    if not managerGame.playerPetGlobal then return end
    managerGame.playerPetGlobal:GetComponent("DetectingCollisions")
end

function ResetGhostPlayerSeeker()
    if ghost then ghost:SetActive(false) end
    isAddedGhost = false
    ghostFollowingSeeker = false
end

--Unity Functions
function self:Awake()
    uiManager = managerGame.UIManagerGlobal:GetComponent("UI_Hide_Seek")
    infoGameModule = managerGame.InfoGameModuleGlobal

    if managerGame.playersTag[game.localPlayer.name] == tagSeeker then
        seekerPlayer = managerGame.playerObjTag[game.localPlayer.name]
    end
end

function self:OnCollisionEnter(collision : Collision)
    local collidedObj = collision.collider.gameObject -- Obj with the what the player collided
    local seeker = game.localPlayer.character.gameObject
    if seekerPlayer == collidedObj then return end -- Return why the player is colliding whit the same
    if collidedObj == managerGame.objsCustome[managerGame.whoIsSeeker.value] then return end

    if seeker ~= collidedObj and collidedObj.name == seeker.name and game.localPlayer.name == managerGame.whoIsSeeker.value then
        --VFX and SFX when the seeker find a player
        local vfx = Object.Instantiate(vfxFoundPlayer)
        local posVfx = vfx.transform.position
        vfx.transform.parent = seeker.transform
        vfx.transform.position = seeker.transform.position + Vector3.new(0, 1.5, 0)
        audioManager.playSound(audioManager.soundFoundPlayerGlobal)

        collidedObj.SetActive(collidedObj, false)
        for namePlayer, objPlayer in pairs(managerGame.objsCustome) do
            if objPlayer == collidedObj then
                managerGame.deleteCustomePlayerFoundServer:FireServer(namePlayer)
                managerGame.tagPlayerFound[namePlayer] = "Found"
            end
        end

        if not isAddedGhost then
            AddGhostFollowingSeeker(seeker, ghostFoundFirstPlayer)
            isAddedGhost = true
            managerGame.updateNumPlayersFound:FireServer()
        else
            managerGame.updateNumPlayersFound:FireServer()
        end
        
        --Delete VFX add
        Timer.After(2, function()
            if not vfx then return end
            Object.Destroy(vfx)
        end)

        audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
    end
end

function self:Update()
    if ghostFollowingSeeker then 
        followingToTarget(
            ghost,
            playerSeeker,
            5 * Time.deltaTime,
            Vector3.new(-0.1, 1.5, 0.6)
        )
    end
end