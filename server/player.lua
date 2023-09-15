Player = Class()

function Player:init(x, y, world, index)
    self.index = index
    self.sprite = sprites.player
    self.width, self.height = self.sprite:getDimensions()
    self.collider = world:newCircleCollider(
        x,
        y,
        self.height/2,
        {collision_class = 'player'}
    )
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)
    self.rotation = 0
    self.dead = false
end


function Player:move(x, y)
    self.collider:setX(x)
    self.collider:setY(y)
end

