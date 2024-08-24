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

    function planet:draw()
        planet.gravField:draw()
        planet.circle:draw()
    end

    return planet
end