--Managers
local managerGame = require('ManagerGame')

--Pedestal 01
--!SerializeField
local woodenCoffin01 : GameObject = nil
--!SerializeField
local pumpkin01 : GameObject = nil
--!SerializeField
local spookyTree01 : GameObject = nil
--!SerializeField
local bookMagical01 : GameObject = nil
--!SerializeField
local stumpPossesed01 : GameObject = nil
--!SerializeField
local witchHat01 : GameObject = nil

--Pedestal 02
--!SerializeField
local woodenCoffin02 : GameObject = nil
--!SerializeField
local pumpkin02 : GameObject = nil
--!SerializeField
local spookyTree02 : GameObject = nil
--!SerializeField
local bookMagical02 : GameObject = nil
--!SerializeField
local stumpPossesed02 : GameObject = nil
--!SerializeField
local witchHat02 : GameObject = nil

--Pedestal 0304
--!SerializeField
local woodenCoffin03 : GameObject = nil
--!SerializeField
local pumpkin03 : GameObject = nil
--!SerializeField
local spookyTree03 : GameObject = nil
--!SerializeField
local bookMagical03 : GameObject = nil
--!SerializeField
local stumpPossesed03 : GameObject = nil
--!SerializeField
local witchHat03 : GameObject = nil

--Variables
local disguisePedestal = {}
local pedestal = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 1,
    [5] = 2,
    [6] = 3
}

--Functions
local function disableStandCustomePlayer()
    for stand, customes in pairs(disguisePedestal) do
        for index, custome in pairs(customes) do
            custome:SetActive(false)
        end
    end
end

function selectWhatCustomePlayerShow(numPedestal)
    disableStandCustomePlayer()

    local numDisguise = 1
    local disguiseSelected = {}

    while numDisguise <= 3 do
        local custome = math.random(1, 6)

        if not disguiseSelected[pedestal[custome]] then
            disguisePedestal[numPedestal][custome]:SetActive(true)
            managerGame.customePlayersSelected[pedestal[custome]] = custome
            disguiseSelected[pedestal[custome]] = true
            numDisguise += 1
        end
    end
end

--Unity Functions
function self:Awake()
    disguisePedestal[1] = {
        [1] = woodenCoffin01,
        [2] = pumpkin01,
        [3] = spookyTree01,
        [4] = bookMagical01,
        [5] = witchHat01,
        [6] = stumpPossesed01
    } 
    disguisePedestal[2] = {
        [1] = woodenCoffin02,
        [2] = pumpkin02,
        [3] = spookyTree02,
        [4] = bookMagical02,
        [5] = witchHat02,
        [6] = stumpPossesed02
    } 
    disguisePedestal[3] = {
        [1] = woodenCoffin03,
        [2] = pumpkin03,
        [3] = spookyTree03,
        [4] = bookMagical03,
        [5] = witchHat03,
        [6] = stumpPossesed03
    } 
end