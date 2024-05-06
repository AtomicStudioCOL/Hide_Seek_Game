local managerGame = require("ManagerGame")

SeekerTexts = {
    ["Intro"] = "You're on the Seeker's team! You have to search for other players hidden around the maps as Props.",
    ["WaintingPlayers"] = "Waiting for players: " .. tostring(managerGame.numRespawnPlayerHiding.value),
    ["GoSeeker"] = "Come on, Seeker, find them!",
    ["NumPlayersFound"] = "Players Found: " .. tostring(managerGame.numPlayersFound.value) .. '/' .. tostring(managerGame.numRespawnPlayerHiding.value - 1)
}

HiderTexts = {
    ["Intro"] = "You're on the Hider's team! Choose a costume from the pedestals, then run and hide around the map.",
    ["PlayerFound"] = "Someone has discovered you. You are free to explore the surroundings.",
    ["TryAgain"] = "If you want to try again, please rejoin the game."
}