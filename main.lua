local enemy
local player
local game_window
local bullet_image
local current_bullet = nil

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

function create_bullet(image, player)
    return {
        x = player.x + (player.width / 2),
        y = player.y,
        width = image:getWidth(),
        height = image:getHeight(),
        speed = player.speed,
        sprite = image,
    }
end

function destroy_bullet()
    current_bullet = nil
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
end

function love.draw()
    if current_bullet then
        love.graphics.draw(current_bullet.sprite, current_bullet.x, current_bullet.y)
    end

    love.graphics.draw(player.sprite, player.x, player.y)
    love.graphics.draw(enemy.sprite, enemy.x, enemy.y)
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

    if current_bullet then
        current_bullet.y = current_bullet.y + current_bullet.speed * dt
        if current_bullet.y >= game_window.height then
            destroy_bullet()
        end

        if check_collision(current_bullet, enemy) then
            enemy.speed = enemy.speed + 10
            destroy_bullet()
        end
    end
end

function love.keyreleased(key)
    if key == "space" then
        current_bullet = create_bullet(bullet_image, player)
    end
end
