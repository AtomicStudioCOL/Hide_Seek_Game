--Local Variables
local countdownGame : Timer = nil
local countdownEndGame : Timer = nil
local minutes : string = ''
local seconds : string = ''

--Global Variables
countdownStartHiddenPlayers = IntValue.new('CountdownStartHiddenPlayers', 30)
countdownStartGame = IntValue.new('CountdownStartGame', 180)
countdown = IntValue.new('Countdown', 3)
countdownGoGame = IntValue.new('CountdownGoGame', 60)
endCountdownHiddenPlayers = false
endCountdownGame = BoolValue.new("CountdownGameHideAndSeek", false)
startingCountdownEndGame = BoolValue.new("StartingCountdownEndGame", false)
endCountdownGoGameLobby = BoolValue.new("CountdownGoGameLobby", false)
playersWentSentToGame = BoolValue.new("PlayersWentSentToGame", false)

--Countdown Before Start Game
playerSeeker = StringValue.new('SeekerPlayer', '')
mustUpdateCountdownHiddenPlayers = BoolValue.new("MustUpdateCountdownHiddenPlayers", true)

--Countdown Send the player to the game
playerMain = StringValue.new('PlayerMain', '')
mustUpdateCountdownGoGameLobby = BoolValue.new("MustUpdateCountdownGoGameLobby", true)

--Countdown End Game
playerEndGame = StringValue.new('PlayerEndGame', '')
mustUpdateCountdownEndGame = BoolValue.new("MustUpdateCountdownEndGame", true)

--Event
local updateEndGameCountdown = Event.new("UpdateEndGame")
local updateStartingCountdownEndGame = Event.new("UpdateStartingCountdownEndGame")
local updateGoGameCountdown = Event.new("UpdateGoGameCountdown")
local eventFlagPlayersSentGame = Event.new("FlagPlayersSentGame")
local updateTimerGame = Event.new("UpdateTimerGame")
local updateTimerGoGameLobby = Event.new("UpdateTimerGoGameLobby")
local updateTimerStart = Event.new("UpdateTimerStart")
local updateTimerEndGame = Event.new("UpdateTimerEndGame")
local resetAllParametersGame = Event.new('ResetAllParametersGame')

function resetCountdowns()
    playerSeeker.value = ''
    mustUpdateCountdownHiddenPlayers.value = true
    playerMain.value = ''
    mustUpdateCountdownGoGameLobby.value = true
    playerEndGame.value = ''
    mustUpdateCountdownEndGame.value = true
    countdownStartGame.value = 180
    countdownStartHiddenPlayers.value = 30
    countdown.value = 3
    countdownGoGame.value = 60
end

function selectMainPlayer(mainClient, namePlayer, countdownCurrent, canUpdate)
    if mainClient.value ~= '' and namePlayer == mainClient.value then
        countdownCurrent.value -= 1
    end

    if mainClient.value == '' and canUpdate.value then
        mainClient.value = namePlayer
        canUpdate.value = false
    end
end

function StartCountdownHiddenPlayers(uiManager, textInfoRolePlayer, seekerPlayer)
    if countdownGame then countdownGame:Stop() end
    updateGoGameCountdown:FireServer(false)
    eventFlagPlayersSentGame:FireServer()

    countdownGame = Timer.new(1, function()
        uiManager.SetCountdownGame(tostring(countdownStartHiddenPlayers.value))
        
        updateTimerStart:FireServer()
        
        if countdownStartHiddenPlayers.value <= 0 then
            endCountdownHiddenPlayers = true
            countdownGame:Stop()
        end
    end, true)
end

function StartCountdownGame(uiManager, seekerPlayer)
    if countdownGame then countdownGame:Stop() end

    countdownGame = Timer.new(1, function()
        minutes = tostring(math.floor(countdownStartGame.value/60))
        seconds = tostring(countdownStartGame.value%60)

        if tonumber(minutes) < 10 then
            minutes = `0{minutes}`
        end

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        uiManager.SetCountdownGame(minutes .. ':' .. seconds)
        if game.localPlayer.name == seekerPlayer then
            updateTimerGame:FireServer()
        end

        if countdownStartGame.value <= 0 then
            updateEndGameCountdown:FireServer()
            countdownGame:Stop()
        end
    end, true)
end

function StartCountdownGoGameLobby(uiManager, seekerPlayer)
    if countdownGame then countdownGame:Stop() end
    updateStartingCountdownEndGame:FireServer(false)

    countdownGame = Timer.new(1, function()
        minutes = tostring(math.floor(countdownGoGame.value/60))
        seconds = tostring(countdownGoGame.value%60)

        if tonumber(minutes) < 10 then
            minutes = `0{minutes}`
        end

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        uiManager.SetCountdownGame(minutes .. ':' .. seconds)
        updateTimerGoGameLobby:FireServer()

        if countdownGoGame.value <= 0 then
            updateGoGameCountdown:FireServer(true)
            countdownGame:Stop()
        end
    end, true)
end

function StartCountdownEndGame(uiManager, seekerPlayer, txt)
    if countdownGame then countdownGame:Stop() end

    countdownEndGame = Timer.new(1, function()
        uiManager.SetTextEndGame('END GAME', tostring(countdown.value))
        updateTimerEndGame:FireServer()

        if countdown.value <= 0 then
            resetAllParametersGame:FireServer()
            uiManager.showTxtGreetingPLayer(false)
            uiManager.UIShowInfoRolePlayer(true)
            uiManager.SetTextRolePlayer(txt)
            
            Timer.After(5, function()
                updateStartingCountdownEndGame:FireServer(true)
                uiManager.UIShowInfoRolePlayer(false)
            end)

            endCountdownHiddenPlayers = false
            countdownEndGame:Stop()
        end
    end, true)
end

function StopTimerEndGame()
    if countdownEndGame then
        countdownEndGame:Stop()
    end
end

function StopCountdownGoGameLobby()
    if countdownGame then
        countdownGame:Stop()
    end
end

function self:ServerAwake()
    updateEndGameCountdown:Connect(function(player : Player)
        endCountdownGame.value = true
    end)

    updateGoGameCountdown:Connect(function(player : Player, status)
        endCountdownGoGameLobby.value = status
        mustUpdateCountdownHiddenPlayers.value = true
    end)

    eventFlagPlayersSentGame:Connect(function(player : Player)
        playersWentSentToGame.value = true
    end)

    updateStartingCountdownEndGame:Connect(function(player : Player, status)
        startingCountdownEndGame.value = status
    end)

    updateTimerStart:Connect(function(player : Player)
        selectMainPlayer(
            playerSeeker, 
            player.name, 
            countdownStartHiddenPlayers, 
            mustUpdateCountdownHiddenPlayers
        )
    end)

    updateTimerGame:Connect(function(player : Player)
        countdownStartGame.value -= 1
    end)

    updateTimerEndGame:Connect(function(player : Player)
        selectMainPlayer(playerEndGame, player.name, countdown, mustUpdateCountdownEndGame)
    end)

    updateTimerGoGameLobby:Connect(function(player : Player)
        selectMainPlayer(playerMain, player.name, countdownGoGame, mustUpdateCountdownGoGameLobby)
    end)

    resetAllParametersGame:Connect(function(player : Player)
        resetCountdowns()
    end)
end