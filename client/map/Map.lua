sti = require 'lib.sti'

Map = Class()

local function createSolids(world, gameMap)
    local solid
    for _, obj in ipairs(gameMap.layers['solids'].objects) do
        solid = world:newRectangleCollider(
            obj.x,
            obj.y,
            obj.width,
            obj.height
        )
        solid:setCollisionClass('solids')
        solid:setType('static')
    end
end

function Map:init(world)
    self.gameMap = sti("map/design.lua")
    createSolids(world, self.gameMap)
end

function Map:draw()
    self.gameMap:drawLayer(self.gameMap.layers["ground"])
    self.gameMap:drawLayer(self.gameMap.layers["assets"])
end


