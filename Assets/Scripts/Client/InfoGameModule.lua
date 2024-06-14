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

info_instructions = {
    ['Seeker'] = {
        [1] = `The seeker must wait 30 seconds before searching for the hidden players.`,
        [2] = `Players can disguise themselves and blend into the map. Watch out, and don't be fooled by their camouflage!`,
        [3] = `If the firefly's light is blue, it means you're far from the targets.`,
        [4] = `If the firefly's light is yellow, it means you're getting closer to a target.`,
        [5] = `If the firefly's light is red, it means you're very close to a target.`,
        [6] = `The flashlight button appears when you're near a hider. Clicking on it shoots a beam of light. If a hider gets shone by the light, they'll be caught.`,
        [7] = `When a hider is found, they'll turn into a ghost and follow you around.`,
        [8] = `Number of players found and remaining can be seen at the top of the screen.`,
        [9] = `Seekers win by finding all players before the timer runs out.`,
    },
    ['Hiding'] = {
        [1] = `The hider has 30 seconds to choose a costume and hide before the seeker begins the search.`,
        [2] = `When seekers catch hiders, the hider turns into a ghost.`,
        [3] = `The hider can choose a costume from the pedestal to blend into the surroundings.`,
        [4] = `When a costume is chosen, the hider is transformed into the costume selected.`,
        [5] = `Hiders win by staying hidden until the timer runs out, avoiding capture by the Seekers.`,
    }
}