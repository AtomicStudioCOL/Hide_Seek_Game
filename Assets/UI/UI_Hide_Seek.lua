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
--!Bind
local Instructions : UILabel = nil
--!Bind
local Info_Instruction : UILabel = nil
--!Bind
local Txt_Btn_Backward : UILabel = nil
--!Bind
local Txt_Btn_Forward : UILabel = nil
--!Bind
local Txt_Btn_Instructions : UILabel = nil
--!Bind
local BTN_Backward : UIButton = nil
--!Bind
local BTN_Forward : UIButton = nil
--!Bind
local Btn_Instructions : UIButton = nil
--!Bind
local Close_Instructions : UIImage = nil

--Variables
timeCurrent = ''

TxtGreetingPLayer:SetPrelocalizedText('Hello')
alertSeekerPlayer:SetPrelocalizedText('')

Info_Instruction:SetPrelocalizedText("This is the space where we'll talk about the game")

Txt_Btn_Backward:SetPrelocalizedText('<')
Txt_Btn_Forward:SetPrelocalizedText('>')
Txt_Btn_Instructions:SetPrelocalizedText('Instructions')

BTN_Backward:Add(Txt_Btn_Backward)
BTN_Forward:Add(Txt_Btn_Forward)
Btn_Instructions:Add(Txt_Btn_Instructions)

function IsShowBtnInstructionsGame(status)
    Btn_Instructions.visible = status
end

function IsShowingInfoInstruction(status)
    Instructions.visible = status
end

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
    RolePlayer:ClearClassList()
    RolePlayer:AddToClassList(className)
end

function self:ClientAwake()
    local screenWidth = Screen.width

    IsShowBtnInstructionsGame(false)
    IsShowingInfoInstruction(false)
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

    Btn_Instructions:RegisterPressCallback(function()
        IsShowBtnInstructionsGame(false)
        IsShowingInfoInstruction(true)
    end)

    Close_Instructions:RegisterPressCallback(function()
        IsShowBtnInstructionsGame(true)
        IsShowingInfoInstruction(false)
    end)
end

function EnabledInfoPlayers()
    infoPlayers.visible = true
    countdownGame.visible = true
end

function SetInfoPlayers(text)
    EnabledInfoPlayers()
    infoPlayers:SetPrelocalizedText(text)
    countdownGame:SetPrelocalizedText(timeCurrent)
end

function SetTextEndGame(text, timeCountdown)
    EnabledInfoPlayers()
    infoPlayers:SetPrelocalizedText(text)
    countdownGame:SetPrelocalizedText(timeCountdown)
end

function SetCountdownGame(text)
    countdownGame.visible = true
    countdownGame:SetPrelocalizedText(timeCurrent)
    timeCurrent = text
end

function SetTextGame(text)
    infoPlayers.visible = true
    infoPlayers:SetPrelocalizedText(text)
end

function alertHiddenPlayerNearby(text, isVisible)
    alertSeekerPlayer.visible = isVisible
    alertSeekerPlayer:SetPrelocalizedText(text)
end

function SetTextRolePlayer(text)
    DescriptionRolePlayer:SetPrelocalizedText(text)
end

function DisabledInfoPlayerHiding()
    infoPlayers.visible = false
    countdownGame.visible = false
    alertSeekerPlayer.visible = false
end