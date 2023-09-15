Class = require 'lib.class'
Camera = require 'lib.camera'
bitser = require 'lib.bitser'
sock = require 'lib.sock'
Timer = require 'lib.timer'

SCREEN_WIDTH, SCREEN_HEIGHT = love.window.getMode()
--50x40 cada bloco com 64 pixels
MAP_WIDTH, MAP_HEIGHT = 64*50, 64*40
love.graphics.setDefaultFilter('nearest', "nearest")
cam = Camera()
cam:zoom(1)

local world = require 'world'
require 'sprites'
require 'map.Map'
require 'player'
require 'enemy'
require 'bullet'

map = Map(world)
players = {}
bullets = {}
timer = Timer()


client = sock.newClient("127.0.0.1", 22122)

client:on("destroyBullet", function (idx)
    bullets[idx] = nil
end)

client:setSchema("updateBullet", {
    "idx",
    "x",
    "y",
})

client:on("updateBullet", function (bullet)
    bullets[bullet.idx].x = bullet.x
    bullets[bullet.idx].y = bullet.y
end)


client:setSchema("updatePlayer", {
    "idx",
    "x",
    "y",
    "rotation"
})

client:on("updatePlayer", function (player)
    local p = players[player.idx]
    if p ~= nil then
        p.x = player.x
        p.y = player.y
        p.rotation = player.rotation
    else
        players[player.idx] = Enemy(player.x, player.y)
    end
end)

client:setSchema("initPlayer", {
    "idx",
    "x",
    "y",
})

client:on("initPlayer", function (p)
    player = Player(p.x, p.y, world)
    players[p.idx] = player
end)

client:setSchema("shootBullet", {
    "idx",
    "x",
    "y",
    "rotation"
})

client:on("shootBullet", function (bullet)
    bullets[bullet.idx] = Bullet(bullet.x, bullet.y, bullet.rotation)
end)

client:on("playerDead", function (index)
    players[index].dead = true
end)

client:on("tomeidc", function (idx)
    players[idx] = nil
end)


client:setSchema("respawned", {
    "idx",
    "x",
    "y",
})

client:on('respawned', function (data)
    local p = players[data.idx]
    p.dead = false
    p.x = data.x
    p.y = data.y
    if p == player  then
        p.collider:setX(data.x)
        p.collider:setY(data.y)
    end
end)



function love.draw()
    if player and player.dead then
        love.graphics.print("VOCE MORREU, PRESSIONE ESPACO\nPARA NASCER NOVAMENTE")
        return
    end
    cam:attach()

    map:draw()
    for idx, player in pairs(players) do
        if not player.dead then
            player:draw()
        end
    end
    -- world:draw()
    for _, bullet in pairs(bullets) do
        bullet:draw()
    end

    cam:detach()
end


function love.update(dt)
    client:update()
    timer:update(dt)
    world:update(dt)
    if player then
        player:update(dt)
        local x, y = lookAt(player)
        cam:lookAt(x, y)
    end
    for idx, bullet in pairs(bullets) do
        bullet:update(dt)
    end
end






function lookAt(player)
    local x, y
    local halfHeight = (SCREEN_HEIGHT/2)/cam.scale
    local halfWidth = (SCREEN_WIDTH/2)/cam.scale
    x = player.x
    y = player.y
    if x - halfWidth < 0 then
        x = halfWidth
    end
    if x + halfWidth > MAP_WIDTH then
        x = MAP_WIDTH - halfWidth
    end
    if y - halfHeight < 0 then
        y =  halfHeight
    end
    if y + halfHeight > MAP_HEIGHT then
        y = MAP_HEIGHT -  halfHeight
    end
    return x, y
end


function love.mousepressed(x,y, button)
    if button == 1 and player then
        local gun_posx, gun_posy
        local rotation_to_find_gun = player.rotation + math.pi/2
        local dirx_find_gun, diry_find_gun = math.cos(rotation_to_find_gun), math.sin(rotation_to_find_gun)
        local player_dirx = math.cos(player.rotation)
        local player_diry = math.sin(player.rotation)
        gun_posx = player.x + (player.width/1) * player_dirx
        gun_posy = player.y + (player.width/1) * player_diry
        gun_posx = gun_posx + (player.height/3.6) * dirx_find_gun
        gun_posy = gun_posy + (player.height/3.6) * diry_find_gun

        client:send("shootBullet", {gun_posx, gun_posy, player.rotation})
    end
end

function love.keypressed(key)
    if key == 'space' then
        if player.dead then
            client:send("respawn")
        end
    end
end


client:connect()


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