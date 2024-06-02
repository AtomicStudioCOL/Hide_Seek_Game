--!Type(UI)
--!Bind
local infoPlayers : UILabel = nil
--!Bind
local countdownGame : UILabel = nil
--!Bind
local alertSeekerPlayer : UILabel = nil
--!Bind
local HideSeek : UILuaView = nil
--!Bind
local UIInfoPlayers : UILabel = nil
--!Bind
local RolePlayer : UIImage = nil
--!Bind
local TxtGreetingPLayer : UILabel = nil
--!Bind
local DescriptionRolePlayer : UILabel = nil
--!Bind
local ClosePopup : UIImage = nil

--Variables
timeCurrent = ''

TxtGreetingPLayer:SetPrelocalizedText('Hello', false)
alertSeekerPlayer:SetPrelocalizedText('', false)

function addClassScreenCurrent(className)
    HideSeek:AddToClassList(className)
    TxtGreetingPLayer:AddToClassList(className)
    DescriptionRolePlayer:AddToClassList(className)
end

function UIShowInfoRolePlayer(isVisible)
    UIInfoPlayers.visible = isVisible
end

function showTxtGreetingPLayer(isVisible)
    TxtGreetingPLayer.visible = isVisible
end

function ChangeImgRolePlayer(className)
    RolePlayer:AddToClassList(className)
end

function self:ClientAwake()
    local screenWidth = Screen.width

    UIShowInfoRolePlayer(false)
    ClosePopup:RegisterPressCallback(function()
        UIShowInfoRolePlayer(false)
        showTxtGreetingPLayer(false)
    end)
    
    if screenWidth <= 800 then
        addClassScreenCurrent('xxsmall-screen')
    elseif screenWidth >= 801 and screenWidth <= 1023 then
        addClassScreenCurrent('xsmall-screen')
    elseif screenWidth >= 1024 and screenWidth <= 1280 then
        addClassScreenCurrent('small-screen')
    elseif screenWidth >= 1281 and screenWidth <= 1600 then
        addClassScreenCurrent('medium-screen')
    elseif screenWidth >= 1601 and screenWidth <= 2047 then
        addClassScreenCurrent('xmedium-screen')
    elseif screenWidth >= 2048 and screenWidth <= 2880 then
        addClassScreenCurrent('large-screen')
    elseif screenWidth >= 2881 and screenWidth <= 7680 then
        addClassScreenCurrent('xlarge-screen')
    end
end

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

function alertHiddenPlayerNearby(text, isVisible)
    alertSeekerPlayer.visible = isVisible
    alertSeekerPlayer:SetPrelocalizedText(text, false)
end

function SetTextRolePlayer(text)
    DescriptionRolePlayer:SetPrelocalizedText(text, false)
end

function DisabledInfoPlayerHiding()
    infoPlayers.visible = false
    countdownGame.visible = false
    alertSeekerPlayer.visible = false
end