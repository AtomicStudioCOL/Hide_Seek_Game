function self:Update()
    if not game.localPlayer.character then return end
    if not game.localPlayer.character.gameObject then return end
    
    local newPosition = (scene.mainCamera.transform.position+game.localPlayer.character.gameObject.transform.position)/2
    self.transform.position = newPosition
end