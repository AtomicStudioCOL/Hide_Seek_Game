--!SerializeField
local objHide01 : GameObject = nil
--!SerializeField
local objHide02 : GameObject = nil
--!SerializeField
local objHide03 : GameObject = nil

--!SerializeField
local btnObjHide01 : TapHandler = nil
--!SerializeField
local btnObjHide02 : TapHandler = nil
--!SerializeField
local btnObjHide03 : TapHandler = nil

--local buttonTapRequest = Event.new("ButtonTapRequest")
--local buttonTapEvent = Event.new("ButtonTapEvent")

function self:ClientAwake()
    btnObjHide01.Tapped:Connect(function()
        -- Insert code to execute locally when the button is tapped
        --buttonTapRequest:FireServer() -- Send a Request to the Server
        print("Button 01")
        objHide01.SetActive(objHide01, true)
        objHide02.SetActive(objHide02, false)
        objHide03.SetActive(objHide03, false)
    end)

    btnObjHide02.Tapped:Connect(function()
        print("Button 02")
        objHide01.SetActive(objHide01, false)
        objHide02.SetActive(objHide02, true)
        objHide03.SetActive(objHide03, false)
    end)

    btnObjHide03.Tapped:Connect(function()
        print("Button 03")
        objHide01.SetActive(objHide01, false)
        objHide02.SetActive(objHide02, false)
        objHide03.SetActive(objHide03, true)
    end)

    --[[ buttonTapEvent:Connect(function()
        -- Insert code to execute on all clients when the button is tapped by any one
        print("Hello World")
        --To show which client is saying hello world you can concatenate 'Hello World' with client.localPlayer.name
        print(client.localPlayer.name .. ": Hello World")
    end) --]]
end

--[[ function self:ServerAwake()
    buttonTapRequest:Connect(function()
        buttonTapEvent:FireAllClients() -- Send an Event to all Clients
    end)
end-- ]]