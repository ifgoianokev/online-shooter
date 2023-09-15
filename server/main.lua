Class = require 'lib.class'
Timer = require 'lib.timer'
sock = require 'lib.sock'
bitser = require "lib.bitser"

math.randomseed(os.time())
TILE_SIZE = 64
MAP_WIDTH, MAP_HEIGHT = TILE_SIZE*50, TILE_SIZE*40

local world = require 'world'
require 'sprites'
require 'map.Map'
require 'player'
require 'bullet'

map = Map(world)
players = {}
bullets = {}
bullet_counter = 0
timer = Timer()


server = sock.newServer('0.0.0.0', 22122, 10)
server:setSerialization(bitser.dumps, bitser.loads)


--envia o estado de todas as balas pra todo mundo
timer:every(.1, function ()
    for idx, bullet in pairs(bullets) do
        server:sendToAll('updateBullet', {
            idx,
            bullet.collider:getX(),
            bullet.collider:getY()
        })
    end
end)

--envia o estado de todos os players para todo mundo
timer:every(1/30, function ()
    for idx, player in pairs(players) do
        client = server:getClientByIndex(idx)
        server:sendToAllBut(client, 'updatePlayer', {
            idx,
            player.collider:getX(),
            player.collider:getY(),
            player.rotation
        })
    end
end)

server:on("connect", function (data, client)
    local idx = client:getIndex()
    print("Player ".. idx .." conneted")
    local x = math.random(0, MAP_WIDTH-100)
    local y = math.random(0, MAP_HEIGHT-100)
    players[idx] = Player(x, y, world, idx)
    client:send("initPlayer", {idx, x, y})
end)

server:on("disconnect", function (data, client)
    local idx = client:getIndex()
    print("Player ".. idx .." disconneted")
    players[idx].collider:destroy()
    players[idx] = nil
    server:sendToAll("tomeidc", idx)
end)


server:setSchema("playerMove", {
    "x",
    "y",
})

server:on("playerMove", function (pos, client)
    local player = players[client:getIndex()]
    if player.dead then return end
    local x = player.collider:getX()
    local y = player.collider:getY()
    local acceptedDistance = 30
    if distance_two_points(x,y, pos.x, pos.y) <= acceptedDistance then
        player:move(pos.x, pos.y)
    end
end)



server:on("playerRotate", function (r, client)
    local player = players[client:getIndex()]
    if not player.dead then
        player.rotation = r
    end
end)


server:setSchema("shootBullet", {
    "x",
    "y",
    "rotation"
})

server:on("shootBullet", function (bulletInfo, client)
    print("bullet")
    local validDistance = 70
    local p = players[client:getIndex()]
    if p.dead then
        return
    end
    local distance = distance_two_points(
        p.collider:getX(),
        p.collider:getY(),
        bulletInfo.x,
        bulletInfo.y
    )
    if distance <= validDistance then
        bullet_counter = (bullet_counter + 1) % 500
        bullets[bullet_counter] = Bullet(bulletInfo, world)
        server:sendToAll("shootBullet", {
            bullet_counter,
            bulletInfo.x,
            bulletInfo.y,
            bulletInfo.rotation
        })
    end
end)


server:on('respawn', function (data, client)
    local idx = client:getIndex()
    local x = math.random(0, MAP_WIDTH-100)
    local y = math.random(0, MAP_HEIGHT-100)
    players[idx].dead = false
    players[idx].collider:setX(x)
    players[idx].collider:setY(y)
    server:sendToAll("respawned", {idx, x, y})
end)


function love.update(dt)
    server:update()
    world:update(dt)
    timer:update(dt)
    for idx, bullet in pairs(bullets) do
        bullet:update(dt)
        if bullet.destroyed then
            server:sendToAll("destroyBullet", idx)
            bullet.collider:destroy()
            bullets[idx] = nil
        end
    end
end



function distance_two_points(x1, y1, x2, y2)
    return math.sqrt( math.pow(x2 - x1 ,2) + math.pow(y2 - y1, 2))
end






