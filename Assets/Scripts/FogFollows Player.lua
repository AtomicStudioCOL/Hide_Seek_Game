function self:Update()
    local newPosition = (scene.mainCamera.transform.position+game.localPlayer.character.gameObject.transform.position)/4
    self.transform.position = newPosition
end