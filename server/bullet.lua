Bullet = Class()


function Bullet:init(bulletInfo, world)
    local player_dirx = math.cos(bulletInfo.rotation)
    local player_diry = math.sin(bulletInfo.rotation)
    self.sprite = sprites.bullet
    self.dirx = player_dirx
    self.diry = player_diry
    self.rotation = bulletInfo.rotation
    self.width, self.height = self.sprite:getDimensions()
    self.destroyed = false
    self.speed = 500

    self.collider = world:newRectangleCollider(
        bulletInfo.x,
        bulletInfo.y,
        self.width,
        self.height,
        {collision_class =  'bullet'}
    )

end



function Bullet:update(dt)
    local x = self.collider:getX()
    local y = self.collider:getY()
    x = x + self.dirx * self.speed * dt
    y = y + self.diry * self.speed * dt
    self.collider:setX(x)
    self.collider:setY(y)
    local hit_wall, hit_player
    hit_player = self.collider:enter('player')
    hit_wall = self.collider:enter('solids')
    if hit_player or hit_wall then
        self.destroyed = true
        if hit_player then
            local data = self.collider:getEnterCollisionData('player')
            local player = data.collider:getObject()
            player.dead = true
            server:sendToAll("playerDead", player.index)
        end
    end
end