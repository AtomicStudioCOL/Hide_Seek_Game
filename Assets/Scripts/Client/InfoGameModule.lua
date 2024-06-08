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
        [1] = `The seeker player needs to wait 30 seconds before starting to search for the hidden players.`,
        [2] = `Players hiding on the map can choose a disguise from the pedestal and blend in with the environment. Be careful not to be fooled!`,
        [3] = `When the firefly's light is blue, it indicates that you are very far from your target.`,
        [4] = `When the firefly's light is yellow, it indicates that you are near your target.`,
        [5] = `When the firefly's light is red, it indicates that you are very close to your target.`,
        [6] = `When you find a hidden player, they immediately explode, accompanied by visual and sound effects (VFX and SFX) to indicate the event.`,
        [7] = `The seeker player can see their progress at the top of the screen: the first number shows how many players they have found, and the second number indicates the total number of hidden players. Additionally, when a hidden player is found, a ghost follows the seeker around the map.`,
        [8] = `When the time runs out and the game concludes, a user interface (UI) appears, indicating whether you have won or lost. As a seeker, you win by finding all the hidden players, and you lose if you haven't found all the players within the allocated time.`
    },
    ['Hiding'] = {
        [1] = `The hidden player has 30 seconds to blend into the environment before the seeking player begins searching for them.`,
        [2] = `When the hidden player is found by the player who was looking for him, the hidden player will become a ghost.`,
        [3] = `The hidden player can choose a disguise on the pedestal to hide in the surroundings.`,
        [4] = `The hidden player selects a costume and it turns into a magic book.`,
        [5] = `When the game is over, a hidden player wins if they manage to survive without being found. They lose if the seeker finds all the hidden players.`,
    }
}