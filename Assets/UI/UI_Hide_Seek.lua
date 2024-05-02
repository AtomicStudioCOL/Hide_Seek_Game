--!Type(UI)

--!Bind
local infoPlayers : UILabel = nil
--!Bind
local infoPlayerHiding : UILabel = nil

function SetInfoPlayers(text)
    infoPlayers.visible = true
    infoPlayers:SetPrelocalizedText(text, false)
    infoPlayerHiding.visible = false
end

function SetInfoHider(text)
    --infoPlayerHiding.visible = true
    infoPlayerHiding:SetPrelocalizedText(text, false)
    --infoPlayers.visible = false
end