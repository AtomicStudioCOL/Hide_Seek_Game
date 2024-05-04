--!Type(UI)

--!Bind
local infoPlayers : UILabel = nil
--!Bind
local countdownGame : UILabel = nil

function SetInfoPlayers(text)
    infoPlayers.visible = true
    infoPlayers:SetPrelocalizedText(text, false)
    countdownGame.visible = false
end

function DisabledInfoPlayerHiding()
    infoPlayers.visible = false
end