--!Type(UI)
--Managers
local managerGame = require('ManagerGame')

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
local Img_Instruction_Backward : UIImage = nil
--!Bind
local Img_Instruction_Forward : UIImage = nil
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
--!Bind
local Img_Flashlight : UIImage = nil

--Variables
local infoGameModule = nil
local instructionCurrent = 0
timeCurrent = ''

TxtGreetingPLayer:SetPrelocalizedText('Hello')
alertSeekerPlayer:SetPrelocalizedText('')

Txt_Btn_Backward:SetPrelocalizedText('<')
Txt_Btn_Forward:SetPrelocalizedText('>')
Txt_Btn_Instructions:SetPrelocalizedText('Instructions')

BTN_Backward:Add(Txt_Btn_Backward)
BTN_Forward:Add(Txt_Btn_Forward)
Btn_Instructions:Add(Txt_Btn_Instructions)

function IsShowBtnInstructionsGame(status)
    Btn_Instructions.visible = status
end

function activateZoneCurrentImgInstruction(isForwards)
    Img_Instruction_Backward.visible = not isForwards
    Img_Instruction_Forward.visible = isForwards
end

function ChangeInfoInstruction(className, role, numInstruction, isForwards)
    if isForwards then
        activateZoneCurrentImgInstruction(isForwards)
        Img_Instruction_Forward:AddToClassList(className)
    else
        activateZoneCurrentImgInstruction(isForwards)
        Img_Instruction_Backward:AddToClassList(className)
    end

    Info_Instruction:SetPrelocalizedText(infoGameModule.info_instructions[role][numInstruction])
end

function resetInfoInstruction()
    instructionCurrent = 1

    if managerGame.playersTag[game.localPlayer.name] == 'Seeker' then
        ChangeInfoInstruction(`seekerInstruction1`, 'Seeker', instructionCurrent, true)
    elseif managerGame.playersTag[game.localPlayer.name] == 'Hiding' then
        ChangeInfoInstruction(`hidersInstruction1`, 'Hiding', instructionCurrent, true)
    end
end

function IsShowingInfoInstruction(status)
    Instructions.visible = status
    
    if not status then 
        Img_Instruction_Backward.visible = false
        Img_Instruction_Forward.visible = false
        return
    end

    resetInfoInstruction()
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

function StatusBtnFlashlightSeeker(status)
    Img_Flashlight.visible = status
    Img_Flashlight:SetEnabled(true)
end

function self:ClientAwake()
    local screenWidth = Screen.width
    infoGameModule = managerGame.InfoGameModuleGlobal

    StatusBtnFlashlightSeeker(false)
    IsShowBtnInstructionsGame(false)
    IsShowingInfoInstruction(false)
    UIShowInfoRolePlayer(false)
    
    ClosePopup:RegisterPressCallback(function()
        UIShowInfoRolePlayer(false)
        showTxtGreetingPLayer(false)
    end)
    
    if screenWidth <= 800 then
        print('xxsmall-screen')
        addClassScreenCurrent('xxsmall-screen')
    elseif screenWidth >= 801 and screenWidth <= 1023 then
        print('xsmall-screen')
        addClassScreenCurrent('xsmall-screen')
    elseif screenWidth >= 1024 and screenWidth <= 1280 then
        print('small-screen')
        addClassScreenCurrent('small-screen')
    elseif screenWidth >= 1281 and screenWidth <= 1600 then
        print('medium-screen')
        addClassScreenCurrent('medium-screen')
    elseif screenWidth >= 1601 and screenWidth <= 2047 then
        print('xmedium-screen')
        addClassScreenCurrent('xmedium-screen')
    elseif screenWidth >= 2048 and screenWidth <= 2880 then
        print('large-screen')
        addClassScreenCurrent('large-screen')
    elseif screenWidth >= 2881 and screenWidth <= 7680 then
        print('xlarge-screen')
        addClassScreenCurrent('xlarge-screen')
    end

    Btn_Instructions:RegisterPressCallback(function()
        IsShowBtnInstructionsGame(false)
        IsShowingInfoInstruction(true)
        UIShowInfoRolePlayer(false)
        showTxtGreetingPLayer(false)
    end)

    Close_Instructions:RegisterPressCallback(function()
        IsShowBtnInstructionsGame(true)
        IsShowingInfoInstruction(false)
    end)

    BTN_Backward:RegisterPressCallback(function()
        if instructionCurrent > 1 then 
            instructionCurrent -= 1 
        end

        if managerGame.playersTag[game.localPlayer.name] == 'Seeker' then
            ChangeInfoInstruction(`seekerInstruction{instructionCurrent}`, 'Seeker', instructionCurrent, false)
        elseif managerGame.playersTag[game.localPlayer.name] == 'Hiding' then
            ChangeInfoInstruction(`hidersInstruction{instructionCurrent}`, 'Hiding', instructionCurrent, false)
        end
    end)

    BTN_Forward:RegisterPressCallback(function()
        if managerGame.playersTag[game.localPlayer.name] == 'Seeker' then
            if instructionCurrent < 8 then
                instructionCurrent += 1
            end

            ChangeInfoInstruction(`seekerInstruction{instructionCurrent}`, 'Seeker', instructionCurrent, true)
        elseif managerGame.playersTag[game.localPlayer.name] == 'Hiding' then
            if instructionCurrent < 5 then
                instructionCurrent += 1
            end
            
            ChangeInfoInstruction(`hidersInstruction{instructionCurrent}`, 'Hiding', instructionCurrent, true)
        end
    end)

    Img_Flashlight:RegisterPressCallback(function()
        local petSeeker : GameObject = managerGame.playerPetGlobal
        local colliderCapsule : CapsuleCollider = petSeeker:GetComponent(CapsuleCollider)
        local areaBigPet : GameObject = managerGame.fireFlyLightColor02Global
        
        Timer.After(0.2, function()
            areaBigPet.transform.localScale = Vector3.new(35, 0.01, 35)
            colliderCapsule.radius = 10
            Img_Flashlight:SetEnabled(false)
        end)

        Timer.After(0.4, function()
            areaBigPet.transform.localScale = Vector3.new(53, 0.01, 53)
            colliderCapsule.radius = 10
        end)
        
        Timer.After(0.6, function()
            areaBigPet.transform.localScale = Vector3.new(70, 0.01, 70)
            colliderCapsule.radius = 10
        end)

        Timer.After(0.8, function()
            areaBigPet.transform.localScale = Vector3.new(53, 0.01, 53)
            colliderCapsule.radius = 10
        end)

        Timer.After(1, function()
            areaBigPet.transform.localScale = Vector3.new(35, 0.01, 35)
            colliderCapsule.radius = 10
        end)
        
        Timer.After(1.25, function()
            areaBigPet.transform.localScale = Vector3.new(44, 0.01, 44)
            colliderCapsule.radius = 18
        end)

        Timer.After(1.5, function()
            areaBigPet.transform.localScale = Vector3.new(53, 0.01, 53)
            colliderCapsule.radius = 25
        end)
        
        Timer.After(1.75, function()
            areaBigPet.transform.localScale = Vector3.new(62, 0.01, 62)
            colliderCapsule.radius = 34
        end)

        Timer.After(2, function()
            areaBigPet.transform.localScale = Vector3.new(70, 0.01, 70)
            colliderCapsule.radius = 40
        end)

        Timer.After(2.2, function()
            Img_Flashlight:SetEnabled(true)
            colliderCapsule.radius = 10
            areaBigPet.transform.localScale = Vector3.new(35, 0.01, 35)
        end)
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