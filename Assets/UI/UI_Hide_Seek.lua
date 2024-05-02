--!Type(UI)

--!Bind
local infoPlayerSeeker : UILabel = nil
--!Bind
local infoPlayerHiding : UILabel = nil

function SetInfoSeeker(text)
    infoPlayerSeeker.visible = true
    infoPlayerSeeker:SetPrelocalizedText(text, false)
    infoPlayerHiding.visible = false
end

function SetInfoHider(text)
    infoPlayerHiding.visible = true
    infoPlayerHiding:SetPrelocalizedText(text, false)
    infoPlayerSeeker.visible = false
end