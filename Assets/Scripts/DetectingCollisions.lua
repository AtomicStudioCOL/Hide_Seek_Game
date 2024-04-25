function self:OnCollisionEnter(collision : Collision)
    print("Collision! ", tostring(collision.gameObject.name))
    print("Collision Transform Parent: ", tostring(collision.collider.name), " || ", tostring(collision.collider.gameObject.name))
    
    local collisionCharacter = collision.collider.gameObject
    local nameClientCurrent = game.localPlayer.character.gameObject
    --[[ myCharacter = self.transform.parent.gameObject:GetComponent(Character)
    myPlayer = myCharacter.player

    print("My Character: ", tostring(myCharacter))
    print("My Player: ", tostring(myPlayer)) ]]
    print("Client Player: ", client.localPlayer.name, " || ", tostring(client.localPlayer.character))
    print("Game Local: ", game.localPlayer.name, " || ", tostring(game.localPlayer.character))
    print("Ref Obj es igual: ", tostring(nameClientCurrent == collisionCharacter))
    print("Ref Obj no es igual: ", tostring(nameClientCurrent ~= collisionCharacter))

    -- Only Register locally if the owner of the trigger is the local player, Only managing when some steps into your own trigger
    if(nameClientCurrent ~= collisionCharacter)then
        print("Hemos encontrado un jugador que se esconde")
        print("Destruir ese jugador")
    end
end