--Local Variables
local countdownGame : Timer = nil
local countdownEndGame : Timer = nil
local minutes : string = ''
local seconds : string = ''

--Global Variables
countdownStartHiddenPlayers = IntValue.new('CountdownStartHiddenPlayers', 30) 
countdownStartGame = IntValue.new('CountdownStartGame', 180) 
countdown = IntValue.new('Countdown', 10) 
endCountdownHiddenPlayers = false
endCountdownGame = BoolValue.new("CountdownGameHideAndSeek", false)
startingCountdownEndGame = BoolValue.new("StartingCountdownEndGame", false)

--Event
local updateEndGameCountdown = Event.new("UpdateEndGame")
local updateStartingCountdownEndGame = Event.new("UpdateStartingCountdownEndGame")
local updateTimerGame = Event.new("UpdateTimerGame")
local updateTimerStart = Event.new("UpdateTimerStart")
local updateTimerEndGame = Event.new("UpdateTimerEndGame")
local resetAllParametersGame = Event.new('ResetAllParametersGame')

function resetAllParameters()
    resetAllParametersGame:FireServer()
    endCountdownHiddenPlayers = false
end

function StartCountdownHiddenPlayers(uiManager, textWaitStartGame, seekerPlayer)
    if countdownGame then countdownGame:Stop() end

    countdownGame = Timer.new(1, function()
        uiManager.SetTextGame(textWaitStartGame)
        uiManager.SetCountdownGame(tostring(countdownStartHiddenPlayers.value))
        
        if game.localPlayer.name == seekerPlayer then
            updateTimerStart:FireServer()
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

function StartCountdownEndGame(uiManager, seekerPlayer)
    countdownGame:Stop()

    countdownEndGame = Timer.new(1, function()
        uiManager.SetTextEndGame('END GAME', tostring(countdown.value))

        if game.localPlayer.name == seekerPlayer then
            updateTimerEndGame:FireServer()
        end

        if countdown.value <= 0 then
            resetAllParametersGame:FireServer()
            uiManager.SetTextEndGame('The game has ended, restarting.', '')
            Timer.After(2, function()
                updateStartingCountdownEndGame:FireServer()
            end)
            countdownEndGame:Stop()
        end
    end, true)
end

function StopTimerEndGame()
    if countdownEndGame then
        countdownEndGame:Stop()
    end
end

function self:ServerAwake()
    updateEndGameCountdown:Connect(function(player : Player)
        endCountdownGame.value = true
    end)

    updateStartingCountdownEndGame:Connect(function(player : Player)
        startingCountdownEndGame.value = true
    end)

    updateTimerStart:Connect(function(player : Player)
        countdownStartHiddenPlayers.value -= 1
    end)

    updateTimerGame:Connect(function(player : Player)
        countdownStartGame.value -= 1
    end)

    updateTimerEndGame:Connect(function(player : Player)
        countdown.value -= 1
    end)

    resetAllParametersGame:Connect(function(player : Player)
        countdownStartGame.value = 180
        countdownStartHiddenPlayers.value = 30
        countdown.value = 10
    end)
end