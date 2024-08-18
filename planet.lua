-- planet class
require 'circle'

function makePlanet(x, y, r, image, gravR, gravImg)
    local planet = {}
    planet.circle = makeCircle(x, y, r, image)
    planet.speed = 0
    planet.gravField = makeCircle(x, y, gravR, gravImg)

    function planet:update()
        if planet.circle.y - planet.circle.r + planet.speed < 0 or planet.circle.y + planet.circle.r + planet.speed > WINDOW_HEIGHT then
            planet.speed = 0
        end
        planet.gravField.y = planet.gravField.y + planet.speed
        planet.circle.y = planet.circle.y + planet.speed
    end

    function planet:draw()
        planet.gravField:draw()
        planet.circle:draw()
    end

    return planet
end