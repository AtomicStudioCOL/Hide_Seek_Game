local managerGame = require("ManagerGame")

SeekerTexts = {
    ["Intro"] = "Hello, Seeker! You gotta to search for the other players hidden around the map.",
    ["WaintingPlayers"] = "Waiting for players " .. tostring(managerGame.numRespawnPlayerHiding.value) .. "/2",
    ["GoSeeker"] = "Come on, Seeker, find them!",
    ["NumPlayersFound"] = "Players Found: " .. tostring(managerGame.numPlayersFound.value) .. '/' .. tostring(managerGame.numRespawnPlayerHiding.value - 1)
}

HiderTexts = {
    ["Intro"] = "Hello, hiders! Choose a costume from the pedestals, then run and hide around the map.",
    ["PlayerFound"] = "We apologize, but you've been discovered by the Seeker. Feel free to explore the surroundings.",
    ["TryAgain"] = "If you wish to attempt again, please rejoin the game."
}