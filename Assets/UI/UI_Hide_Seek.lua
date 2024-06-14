--!Type(UI)
--Managers
local managerGame = require('ManagerGame')

--Information of each player in the game
--!Bind
local HideSeek : UILuaView = nil
--!Bind
local infoPlayers : UILabel = nil
--!Bind
local countdownGame : UILabel = nil
--!Bind
local alertSeekerPlayer : UILabel = nil

--UI show information about of the role and winner and lose system
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

--UI show instructions about the game
--!Bind
local Instructions : UILabel = nil
--!Bind
local Info_Instruction : UILabel = nil

--Text of the buttons in the UI
--!Bind
local Txt_Btn_Backward : UILabel = nil
--!Bind
local Txt_Btn_Forward : UILabel = nil
--!Bind
local Txt_Btn_Instructions : UILabel = nil
--!Bind
local Txt_Btn_Select_Seeker : UILabel = nil
--!Bind
local Txt_Btn_Select_Hider : UILabel = nil

--Buttons of the UI
--!Bind
local BTN_Backward : UIButton = nil
--!Bind
local BTN_Forward : UIButton = nil
--!Bind
local Btn_Instructions : UIButton = nil
--!Bind
local Close_Instructions : UIImage = nil
--!Bind
local Btn_Select_Seeker : UIButton = nil
--!Bind
local Btn_Select_Hider : UIButton = nil
--!Bind
local Close_Select_Instruction : UIImage = nil

--Instructions Seeker--
--!Bind
local Instruction_Seeker_01 : UIImage = nil
--!Bind
local Instruction_Seeker_02 : UIImage = nil
--!Bind
local Instruction_Seeker_03 : UIImage = nil
--!Bind
local Instruction_Seeker_04 : UIImage = nil
--!Bind
local Instruction_Seeker_05 : UIImage = nil
--!Bind
local Instruction_Seeker_06 : UIImage = nil
--!Bind
local Instruction_Seeker_07 : UIImage = nil
--!Bind
local Instruction_Seeker_08 : UIImage = nil
--!Bind
local Instruction_Seeker_09 : UIImage = nil

--Instructions Hiding--
--!Bind
local Instruction_Hiding_01 : UIImage = nil
--!Bind
local Instruction_Hiding_02 : UIImage = nil
--!Bind
local Instruction_Hiding_03 : UIImage = nil
--!Bind
local Instruction_Hiding_04 : UIImage = nil
--!Bind
local Instruction_Hiding_05 : UIImage = nil

--Button to shot the flashlight to find the hidden players
--!Bind
local Img_Flashlight : UIImage = nil

--Variables
local associated_all_instruction = {[10] = 1, [11] = 2, [12] = 3, [13] = 4, [14] = 5}
local img_instruction_game = {}
local infoGameModule = nil
local instructionCurrent = 0
local typeCurrentInstructions = ''
Img_Flashlight_Global = nil
timeCurrent = ''

TxtGreetingPLayer:SetPrelocalizedText('Hello')
alertSeekerPlayer:SetPrelocalizedText('')

Txt_Btn_Backward:SetPrelocalizedText('<')
Txt_Btn_Forward:SetPrelocalizedText('>')
Txt_Btn_Instructions:SetPrelocalizedText('Instructions')
Txt_Btn_Select_Seeker:SetPrelocalizedText('Seeker')
Txt_Btn_Select_Hider:SetPrelocalizedText('Hider')

BTN_Backward:Add(Txt_Btn_Backward)
BTN_Forward:Add(Txt_Btn_Forward)
Btn_Instructions:Add(Txt_Btn_Instructions)
Btn_Select_Seeker:Add(Txt_Btn_Select_Seeker)
Btn_Select_Hider:Add(Txt_Btn_Select_Hider)

function IsShowBtnInstructionsGame(status)
    Btn_Instructions.visible = status
    Btn_Select_Hider.visible = not status
    Btn_Select_Seeker.visible = not status
    Close_Select_Instruction.visible = not status
end

function DisableBtnsSelectTypeInstrucction(status)
    Btn_Select_Hider.visible = status
    Btn_Select_Seeker.visible = status
    Close_Select_Instruction.visible = status
end

function DisableAllImgInstructions()
    for role, info in pairs(img_instruction_game) do
        for num, img in pairs(info) do
            img.visible = false
        end
    end
end

function ChangeInfoInstruction(role, numInstruction)
    DisableAllImgInstructions()
    img_instruction_game[role][numInstruction].visible = true
    Info_Instruction:SetPrelocalizedText(infoGameModule.info_instructions[role][numInstruction])
end

function resetInfoInstruction(typeInstruction)
    instructionCurrent = 1
    ChangeInfoInstruction(typeInstruction, instructionCurrent)
end

function IsShowingInfoInstruction(status, typeInstruction)
    Instructions.visible = status
    if not status or typeInstruction == '' then return end

    resetInfoInstruction(typeInstruction)
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
    Img_Flashlight_Global = Img_Flashlight
    typeCurrentInstructions = ''

    img_instruction_game['Seeker'] = {
        [1] = Instruction_Seeker_01,
        [2] = Instruction_Seeker_02,
        [3] = Instruction_Seeker_03,
        [4] = Instruction_Seeker_04,
        [5] = Instruction_Seeker_05,
        [6] = Instruction_Seeker_06,
        [7] = Instruction_Seeker_07,
        [8] = Instruction_Seeker_08,
        [9] = Instruction_Seeker_09,
    }

    img_instruction_game['Hiding'] = {
        [1] = Instruction_Hiding_01,
        [2] = Instruction_Hiding_02,
        [3] = Instruction_Hiding_03,
        [4] = Instruction_Hiding_04,
        [5] = Instruction_Hiding_05,
    }

    DisableAllImgInstructions()
    StatusBtnFlashlightSeeker(false)
    IsShowBtnInstructionsGame(true)
    IsShowingInfoInstruction(false, typeCurrentInstructions)
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
        UIShowInfoRolePlayer(false)
        showTxtGreetingPLayer(false)
    end)

    Btn_Select_Seeker:RegisterPressCallback(function()
        typeCurrentInstructions = 'Seeker'
        DisableBtnsSelectTypeInstrucction(false)
        IsShowingInfoInstruction(true, typeCurrentInstructions)
    end)

    Btn_Select_Hider:RegisterPressCallback(function()
        typeCurrentInstructions = 'Hiding'
        DisableBtnsSelectTypeInstrucction(false)
        IsShowingInfoInstruction(true, typeCurrentInstructions)
    end)

    Close_Select_Instruction:RegisterPressCallback(function()
        typeCurrentInstructions = ''
        IsShowBtnInstructionsGame(true)
        IsShowingInfoInstruction(false, typeCurrentInstructions)
        DisableAllImgInstructions()
    end)

    Close_Instructions:RegisterPressCallback(function()
        typeCurrentInstructions = ''
        IsShowBtnInstructionsGame(true)
        IsShowingInfoInstruction(false, typeCurrentInstructions)
        DisableAllImgInstructions()
    end)

    BTN_Backward:RegisterPressCallback(function()
        if instructionCurrent > 1 then 
            instructionCurrent -= 1 
        end

        ChangeInfoInstruction(typeCurrentInstructions, instructionCurrent)
    end)

    BTN_Forward:RegisterPressCallback(function()
        if typeCurrentInstructions == 'Seeker' then
            if instructionCurrent < 9 then
                instructionCurrent += 1
            end
        elseif typeCurrentInstructions == 'Hiding' then
            if instructionCurrent < 5 then
                instructionCurrent += 1
            end
        end

        ChangeInfoInstruction(typeCurrentInstructions, instructionCurrent)
    end)

    Img_Flashlight:RegisterPressCallback(function()
        managerGame.triggerAreaDetectionSeekerServer:FireServer()
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