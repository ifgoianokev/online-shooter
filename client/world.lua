wf = require 'lib.windfield'
local world = wf.newWorld(0,0, false)
world:addCollisionClass('solids')
world:addCollisionClass('player')
world:addCollisionClass('bullet')

return world