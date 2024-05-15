--!Type(UI)
--!Bind
local infoPlayers : UILabel = nil
--!Bind
local countdownGame : UILabel = nil

--Variables
local timeCurrent = ''

function EnabledInfoPlayers()
    infoPlayers.visible = true
    countdownGame.visible = true
end

function SetInfoPlayers(text)
    EnabledInfoPlayers()
    infoPlayers:SetPrelocalizedText(text, false)
    countdownGame:SetPrelocalizedText(timeCurrent, false)
end

function SetTextEndGame(text, timeCountdown)
    EnabledInfoPlayers()
    infoPlayers:SetPrelocalizedText(text, false)
    countdownGame:SetPrelocalizedText(timeCountdown, false)
end

function SetCountdownGame(text)
    countdownGame.visible = true
    countdownGame:SetPrelocalizedText(timeCurrent, false)
    timeCurrent = text
end

function SetTextGame(text)
    infoPlayers.visible = true
    infoPlayers:SetPrelocalizedText(text, false)
end

function DisabledInfoPlayerHiding()
    infoPlayers.visible = false
    countdownGame.visible = false
end