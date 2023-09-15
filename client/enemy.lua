Enemy = Class()

function Enemy:init(x, y)
    self.sprite = sprites.player
    self.x = x
    self.y = y
    self.width, self.height = self.sprite:getDimensions()
    self.rotation = 0
    self.dead = false
end

function Enemy:draw()
    love.graphics.draw(
        self.sprite,
        self.x,
        self.y,
        self.rotation,
        1,
        1,
        self.width/2,
        self.height/2
    )
end
