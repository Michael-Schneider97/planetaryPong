-- planet class
require 'circle'

function makePlanet(x, y, r, image, gravR, gravImg)
    local planet = {}
    planet.circle = makeCircle(x, y, r, image)
    planet.speed = 10
    planet.gravField = makeCircle(x, y, gravR, gravImg)
    planet.dx = 0
    planet.dy = 0

    function planet:update(dt)
        planet.circle.x = planet.circle.x + planet.dx
        planet.gravField.x = planet.gravField.x + planet.dx
        planet.circle.y = planet.circle.y + planet.dy
        planet.gravField.y = planet.gravField.y + planet.dy
    end

    function planet:stop()
        planet.dx = 0
        planet.dy = 0
    end

    function planet:setDir(dx, dy)
        dx, dy = getDir(0, 0, dx, dy)
        planet.dx, planet.dy = setSpeed(dx, dy, planet.speed)
    end

    function planet:handleGravity()
    if planet.gravField:collide(ball.circle) then
        --change line below for testing behavior 
        planet.inField = true
        if planet.doGravity == true then
            ball:addForce(getGravForce(planet.circle, ball.circle, FORCE_MULTIPLIER))
        end

        if planet.inField == true and planet.wasInField == false then
			planet.doGravity = true 

            -- get angle
            planet.dirX, planet.dirY = getDir(0, 0, ball.dx, ball.dy)
            -- calc exit angle
            planet.dirX, planet.dirY = translateDir(planet.dirX, planet.dirY, 180, true)
			--reduction = reduction + 0.01
        end

        if planet.inField == true and planet.wasInField == true then
            planet.ballDirX, planet.ballDirY = getDir(0, 0, ball.dx, ball.dy)
            planet.diff = 0.1
            if math.abs(planet.ballDirX - planet.dirX) < planet.diff and math.abs(planet.ballDirY - planet.dirY) < planet.diff then
                -- code to stop gravity here
				planet.doGravity = false
            end
        end
    else
        planet.inField = false
    end

    planet.wasInField = planet.inField
end

    function planet:draw()
        planet.gravField:draw()
        planet.circle:draw()
    end

    return planet
end