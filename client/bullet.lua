Bullet = Class()

-- function later(player, world)
--     local gun_posx, gun_posy
--     local rotation_to_find_gun = player.rotation + math.pi/2
--     local dirx_find_gun, diry_find_gun = math.cos(rotation_to_find_gun), math.sin(rotation_to_find_gun)
--     local player_dirx = math.cos(player.rotation)
--     local player_diry = math.sin(player.rotation)
--     gun_posx = player.x + player.width/2 * player_dirx
--     gun_posy = player.y + player.width/2 * player_diry
--     gun_posx = gun_posx + player.height/4 * dirx_find_gun
--     gun_posy = gun_posy + player.height/4 * diry_find_gun

--     self.sprite = sprites.bullet
--     self.x = gun_posx
--     self.y = gun_posy
--     self.dirx = player_dirx
--     self.diry = player_diry
--     self.rotation = player.rotation
--     self.width, self.height = self.sprite:getDimensions()
--     self.destroyed = false
--     self.speed = 500

--     self.collider = world:newRectangleCollider(
--         self.x,
--         self.y,
--         self.width,
--         self.height,
--         {collision_class =  'bullet'}
--     )

-- end


function Bullet:init(x, y, rotation)
    self.sprite = sprites.bullet
    self.x = x
    self.y = y
    self.width, self.height = self.sprite:getDimensions()
    self.dirx = math.cos(rotation)
    self.diry = math.sin(rotation)
    self.rotation = rotation
    self.speed = 500
end

function Bullet:draw()
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

function Bullet:update(dt)
    self.x = self.x + self.dirx * self.speed * dt
    self.y = self.y + self.diry * self.speed * dt
end