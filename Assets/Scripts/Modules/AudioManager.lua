--!SerializeField
local soundFoundPlayer : AudioClip = nil
local audioSource : AudioSource = nil
soundFoundPlayerGlobal = nil
audioAlertPlayerSeeker = nil

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

function playAlertPlayerSeeker(source : AudioSource, vol : number)
    if tostring(source) ~= "null" and source ~= nil then
        if not source.isPlaying then
            audioAlertPlayerSeeker = source
            source:Play()
            source.volume = vol
        end
    end
end

function pauseAlertPlayerSeeker(source : AudioSource, vol : number)
    if tostring(source) ~= "null" and source ~= nil then
        if source.isPlaying then
            audioAlertPlayerSeeker = source
            source:Pause()
            source.volume = vol
        end
    end
end

--Unity Functions
function self:Start()
    soundFoundPlayerGlobal = soundFoundPlayer
end