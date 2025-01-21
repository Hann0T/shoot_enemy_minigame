local enemy
local player
local game_window
local bullet_image
local bullet_pool = {}

function bullet_pool.get_bullet(self)
    for i, bullet in ipairs(self) do
        if not bullet.shot then
            return bullet
        end
    end

    bullet_pool:init(bullet_image, player)

    return bullet_pool:get_bullet()
end

function bullet_pool.init(self, image, player)
    for i = 1, 5, 1 do
        table.insert(self, create_bullet(image, player))
    end
end

local function check_collision(a, b)
    local a_right = a.x + a.width
    local a_bottom = a.y + a.height
    local b_right = b.x + b.width
    local b_bottom = b.y + b.height

    return a.x < b_right
        and a_right > b.x
        and a_bottom > b.y
        and a.y < b_bottom
end

function create_player(image)
    local width = image:getWidth()
    local height = image:getHeight()
    return {
        x = 0,
        y = 0,
        width = width,
        height = height,
        sprite = image,
        speed = 500,
    }
end

function set_player(player)
    player.left = function() return love.keyboard.isDown("h") end
    player.right = function() return love.keyboard.isDown("l") end
    player.y = player.y + 10
end

function set_enemy(enemy)
    enemy.y = love.graphics.getHeight() - enemy.height * 1.25
    enemy.speed = 300
    enemy.direction = "right"
end

function get_window()
    return {
        x = 0,
        y = 0,
        width = love.graphics.getWidth(),
        height = love.graphics.getHeight(),
    }
end

function bullet_pool_init(bullet_pool, player)
    for i = 1, 10, 1 do
        table.insert(
            bullet_pool.bullets,
            create_bullet(bullet_pool.sprite, player.x + (player.width / 2), player.y, player.speed)
        )
    end
    bullet_pool.player = player
end

function bullet_pool_shot_bullet(bullet_pool)
    for i, bullet in ipairs(bullet_pool.pool) do
        if not bullet.shot then
            bullet.shot = true
            return bullet
        end
    end

    local player = bullet_pool.player
    local new_bullet = create_bullet(bullet_pool.sprite, player.x + (player.width / 2), player.y, player.speed)

    table.insert(new_bullet.pool, new_bullet)
end

function create_bullet(image, x, y, speed)
    return {
        x = player.x + (player.width / 2),
        y = player.y,
        width = image:getWidth(),
        height = image:getHeight(),
        speed = player.speed,
        sprite = image,
        shot = false
    }
end

function love.load()
    local snake = love.graphics.newImage("snake.png")
    local panda = love.graphics.newImage("panda.png")
    bullet_image = love.graphics.newImage("bullet.png")

    game_window = get_window()

    player = create_player(panda)
    enemy = create_player(snake)
    set_enemy(enemy)
    set_player(player)
    bullet_pool:init(bullet_image, player)
end

function love.draw()
    for i, bullet in ipairs(bullet_pool) do
        if bullet.shot then
            love.graphics.draw(bullet.sprite, bullet.x, bullet.y)
        end
    end

    love.graphics.draw(player.sprite, player.x, player.y)
    love.graphics.draw(enemy.sprite, enemy.x, enemy.y)

    love.graphics.print("bullets: " .. #bullet_pool, 10, 10)
end

function love.update(dt)
    if player.left() and player.x > game_window.x then
        player.x = player.x - player.speed * dt
    end
    if player.right() and (player.x + player.width) <= game_window.width then
        player.x = player.x + player.speed * dt
    end

    if enemy.direction == "right" then
        enemy.x = enemy.x + enemy.speed * dt
    else
        enemy.x = enemy.x - enemy.speed * dt
    end

    if enemy.x <= game_window.x then
        enemy.direction = "right"
    elseif (enemy.x + enemy.width) >= game_window.width then
        enemy.direction = "left"
    end

    for i, bullet in ipairs(bullet_pool) do
        if bullet.shot then
            bullet.y = bullet.y + bullet.speed * dt

            if check_collision(bullet, enemy) then
                enemy.speed = enemy.speed + 5000 * dt
                bullet.shot = false
            end

            if bullet.y >= love.graphics.getHeight() then
                bullet.shot = false
            end
        end
    end
end

function love.keyreleased(key)
    if key == "space" then
        local bullet = bullet_pool:get_bullet()
        bullet.shot = true
        bullet.x = player.x + (player.width / 2)
        bullet.y = player.y
    end
end
