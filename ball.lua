-- encapsulation of ball behavior
require 'circle'

-- rewrite w/o class 

function makeBall(x, y, r, image)
    local ball = {}
    ball.circle = makeCircle(x, y, r, image)
    ball.dx = -5
    ball.dy = 0

    function ball:respawn()
        ball.circle.x = WINDOW_WIDTH / 2 
        ball.circle.y = WINDOW_HEIGHT / 2  
        ball.dy = 0
        ball.dx = -5
    end

    function ball:update()
        love.graphics.print('ball x = ' .. tostring(ball.circle.x))
        ball.circle.x = ball.circle.x + ball.dx 
        ball.circle.y = ball.circle.y + ball.dy
        if ball.circle:bound() then  
            ball.dy = -ball.dy
        end
    end

    function ball:addForce(deltaX, deltaY)
        ball.dx = ball.dx + deltaX
        ball.dy = ball.dy + deltaY
    end

    function ball:draw()
        ball.circle:draw()
    end 

    -- returns id of player who should score once the ball is out of bounds
    -- else returns 0
    function ball:score()
        local buffer = 100
        if ball.circle.x < 0 - buffer then 
            ball:respawn()
            return 2
        elseif ball.circle.x > WINDOW_WIDTH + buffer then 
            ball:respawn()
            return 1
        end

        return 0
    end


    return ball
end
