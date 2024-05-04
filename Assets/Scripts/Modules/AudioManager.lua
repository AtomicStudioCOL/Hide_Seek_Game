--!SerializeField
local soundFoundPlayer : AudioClip = nil
local audioSource : AudioSource = nil
soundFoundPlayerGlobal = nil

--Functions
function playSound(clip)
    if  audioSource == nil then 
        audioSource = self.gameObject:AddComponent(AudioSource)
        audioSource:PlayOneShot(clip)
        audioSource.loop = false
        audioSource.volume = 1.25
    else
        audioSource:PlayOneShot(clip)
        audioSource.loop = false
        audioSource.volume = 1.25
    end
end

--Unity Functions
function self:Start()
    soundFoundPlayerGlobal = soundFoundPlayer
end