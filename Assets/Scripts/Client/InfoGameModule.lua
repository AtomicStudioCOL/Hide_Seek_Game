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
        [2] = `Players can disguise and blend in on the map. Watch out, don't be fooled by their camouflage!`,
        [3] = `When the firefly's light is blue, it indicates that you are very far from your target.`,
        [4] = `When the firefly's light is yellow, it indicates that you are near your target.`,
        [5] = `When the firefly's light is red, it indicates that you are very close to your target.`,
        [6] = `Finding a hidden player triggers an explosive VFX and SFX to signal their discovery.`,
        [7] = `The seeker’s progress is shown on-screen: players found/total hidden. Found the player's ghosts follow the seeker.`,
        [8] = `When time runs out, the UI shows win or loss. Seekers win by finding all players; lose if any remain hidden.`
    },
    ['Hiding'] = {
        [1] = `The hidden player has 30 seconds to blend in before the seeker starts searching.`,
        [2] = `When the seeker player finds the hidden player, the hidden player will become a ghost.`,
        [3] = `The hidden player can choose a disguise on the pedestal to hide in the surroundings.`,
        [4] = `The hidden player selects a costume and it turns into a magic book.`,
        [5] = `Hidden players win if undiscovered; lose if all found by seeker at game's end.`,
    }
}