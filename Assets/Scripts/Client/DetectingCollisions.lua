--Modules
local managerGame = require('ManagerGame')
local audioManager = require('AudioManager')

--Variable publics
--!SerializeField
local vfxFoundPlayer : GameObject = nil
--!SerializeField
local ghostFoundFirstPlayer : GameObject = nil

--Local Variables
local playerSeeker : GameObject = nil
local uiManager = nil
local infoGameModule = nil

--Global Variables
ghostHiddenPlayer = nil
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

function AddVFXFoundHiddenPlayer(seeker)
    local vfx = Object.Instantiate(vfxFoundPlayer)
    local posVfx = vfx.transform.position
    
    vfx.transform.parent = seeker.transform
    vfx.transform.position = seeker.transform.position + Vector3.new(0, 1.5, 0)
    audioManager.playSound(audioManager.soundFoundPlayerGlobal)

    return vfx
end

function DeleteVFXFoundHiddenPlayer(vfx)
    Timer.After(2, function()
        if not vfx then return end
        Object.Destroy(vfx)
    end)
end

function ResetFireFlyPlayerSeeker()
    if not managerGame.playerPetGlobal then return end
    managerGame.playerPetGlobal:SetActive(false)
end

function ResetGhostPlayerSeeker()
    if ghost then Object.Destroy(ghost) end
    isAddedGhost = false
    ghostFollowingSeeker = false
end

--Unity Functions
function self:Awake()
    uiManager = managerGame.UIManagerGlobal:GetComponent(UI_Hide_Seek)
    infoGameModule = managerGame.InfoGameModuleGlobal
    ghostHiddenPlayer = ghostFoundFirstPlayer
end

function self:OnCollisionEnter(collision : Collision)
    local collidedObj = collision.collider.gameObject -- Obj with the what the player collided
    local seeker = game.localPlayer.character.gameObject
    local colliderCapsule = self.gameObject:GetComponent(CapsuleCollider)

    if collidedObj == managerGame.objsCustome[managerGame.whoIsSeeker.value] then return end
    if seeker == collidedObj then return end
    
    for namePlayer, objPlayer in pairs(managerGame.objsCustome) do
        if objPlayer ~= collidedObj then continue end
        managerGame.reviewIfClientInGame:FireServer(namePlayer)
        break
    end
    
    Timer.After(0.2, function()
        if game.localPlayer.name == managerGame.whoIsSeeker.value and managerGame.hasCollidedWithPlayerInGame.value then
            local vfx = AddVFXFoundHiddenPlayer(seeker) -- VFX and SFX when the seeker find a player
            
            collidedObj:SetActive(false)
            for namePlayer, objPlayer in pairs(managerGame.objsCustome) do
                if objPlayer == collidedObj then
                    managerGame.deleteCustomePlayerFoundServer:FireServer(namePlayer, game.localPlayer.name)
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
            
            DeleteVFXFoundHiddenPlayer(vfx) -- Delete VFX add
            
            audioManager.pauseAlertPlayerSeeker(audioManager.audioAlertPlayerSeeker, 0)
            colliderCapsule.radius = 10
            managerGame.fireFlyLightColor02Global.transform.localScale = Vector3.new(35, 0.01, 35)
        end
    end)
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