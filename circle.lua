--[[
    Circle geometric object 
    * Uses x and y coordinates as center 
    * Collision can be handled using radi 
    * Scale is calculated from radius 
]]


function makeCircle(x, y, r, image, scr_hght)
    local circle = {x = x, y = y, r = r, image = image, scale = 0.0, doCollision = false}

    function circle:setScale()
        circle.scale = 2 * circle.r / image:getWidth()
        return circle.scale
    end

    circle:setScale()

    -- tests if its out of bounds
    -- this magic number is the screen height
    function circle:bound()
        if circle.y - circle.r < 0 or circle.y + circle.r > 720 then
            return true
        end
        return false
    end

    function circle:draw()
        love.graphics.draw(circle.image, circle.x - circle.r, circle.y - circle.r, 0, circle.scale)
    end

    -- returns true if the circles are intersecting at any point
    function circle:collide(otherCircle)
        return distance(circle.x, circle.y, otherCircle.x, otherCircle.y) < (circle.r + otherCircle.r)
    end

    return circle
end
