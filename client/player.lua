Player = Class()

function Player:init(x, y, world)
    self.sprite = sprites.player
    self.x = x
    self.y = y
    self.width, self.height = self.sprite:getDimensions()
    self.collider = world:newCircleCollider(
        self.x,
        self.y,
        self.height/2,
        {collision_class = 'player'}
    )
    self.collider:setFixedRotation(true)
    self.rotation = 0
    self.speed = 200
    self.dead = false
end

function Player:draw()
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

function Player:updatePosition(dt)
    local x, y
    local dirx, diry = 0, 0
    self.x, self.y = self.collider:getX(), self.collider:getY()
    local cima = love.keyboard.isDown('w', 'up')
    local baixo = love.keyboard.isDown('s', 'down')
    local esq = love.keyboard.isDown('a', 'left')
    local dir = love.keyboard.isDown('d', 'right')
    if cima then
        diry = diry - 1
    end
    if  baixo then
        diry = diry + 1
    end
    if esq then
        dirx = dirx - 1
    end
    if dir then
        dirx = dirx + 1
    end
    if cima or baixo or esq or dir then
        --se esta movendo na diagonal
        if (cima or baixo) and (esq or dir) then
            dirx = dirx * .7
            diry = diry * .7
        end
        x = self.x + dirx*self.speed * dt
        y = self.y + diry*self.speed * dt
        self.collider:setX(x)
        self.collider:setY(y)
        client:send("playerMove", {x, y})
    end
end

function Player:updateRotation()
    local mx, my = cam:mousePosition()
    self.rotation = math.atan2(
        my - self.y,
        mx - self.x
    )
    client:send("playerRotate", self.rotation)
end


function Player:update(dt)
    self:updatePosition(dt)
    self:updateRotation()
end