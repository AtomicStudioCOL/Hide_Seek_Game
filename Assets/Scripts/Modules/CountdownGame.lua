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

playerSeeker = StringValue.new('SeekerPlayer', '')
mustUpdateCountdownHiddenPlayers = BoolValue.new("MustUpdateCountdownHiddenPlayers", true)

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
    countdownStartGame.value = 180
    countdownStartHiddenPlayers.value = 30
    countdown.value = 3
    countdownGoGame.value = 60
end

function StartCountdownHiddenPlayers(uiManager, textWaitStartGame, seekerPlayer)
    if countdownGame then countdownGame:Stop() end
    updateGoGameCountdown:FireServer(false)
    eventFlagPlayersSentGame:FireServer()

    countdownGame = Timer.new(1, function()
        uiManager.SetTextGame(textWaitStartGame)
        uiManager.SetCountdownGame(tostring(countdownStartHiddenPlayers.value))
        
        if playerSeeker.value == '' then
            updateTimerStart:FireServer()
        else
            if game.localPlayer.name == playerSeeker.value then
                updateTimerStart:FireServer()
            end
        end

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
        if game.localPlayer.name == seekerPlayer then
            updateTimerGoGameLobby:FireServer()
        end

        if countdownGoGame.value <= 0 then
            updateGoGameCountdown:FireServer(true)
            countdownGame:Stop()
        end
    end, true)
end

function StartCountdownEndGame(uiManager, seekerPlayer)
    if countdownGame then countdownGame:Stop() end

    countdownEndGame = Timer.new(1, function()
        uiManager.SetTextEndGame('END GAME', tostring(countdown.value))

        if game.localPlayer.name == seekerPlayer then
            updateTimerEndGame:FireServer()
        end

        if countdown.value <= 0 then
            resetAllParametersGame:FireServer()
            uiManager.SetTextEndGame('The game has ended, restarting.', '')
            
            Timer.After(5, function()
                updateStartingCountdownEndGame:FireServer(true)
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
        if playerSeeker.value ~= '' then
            countdownStartHiddenPlayers.value -= 1
        end

        if playerSeeker.value == '' and mustUpdateCountdownHiddenPlayers.value then
            playerSeeker.value = player.name
            countdownStartHiddenPlayers.value -= 1
            mustUpdateCountdownHiddenPlayers.value = false
        end
    end)

    updateTimerGame:Connect(function(player : Player)
        countdownStartGame.value -= 1
    end)

    updateTimerEndGame:Connect(function(player : Player)
        countdown.value -= 1
    end)

    updateTimerGoGameLobby:Connect(function(player : Player)
        countdownGoGame.value -= 1
    end)

    resetAllParametersGame:Connect(function(player : Player)
        resetCountdowns()
    end)
end