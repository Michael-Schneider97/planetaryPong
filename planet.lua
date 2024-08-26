-- planet class
require 'circle'

function makePlanet(x, y, r, image, gravR, gravImg)
    local planet = {}
    planet.circle = makeCircle(x, y, r, image)
    planet.speed = 10
    planet.gravField = makeCircle(x, y, gravR, gravImg)
    planet.dx = 0
    planet.dy = 0
    -- these are used as 
    planet.outerBarrier = ((planet.gravField.r - planet.circle.r) * 2/3) + planet.circle.r
    planet.innerBarrier = ((planet.gravField.r - planet.circle.r) / 3) + planet.circle.r

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
			-- get raycast data
			planet.ballLeftY, planet.ballRightY = getYIntercepts(ball.circle.x, ball.circle.y, ball.dx, ball.dy)
			if planet.ballLeftY ~= nil then 
				-- get perpendicular y's
				planet.perpLeftY, planet.perpRightY = getYIntercepts(planet.circle.x, planet.circle.y, translateDir(ball.dx, ball.dy, 90))
				-- then find intersect
				planet.interX, planet.interY = getIntersect(planet.ballLeftY, planet.ballRightY, planet.perpLeftY, planet.perpRightY)
				-- then find distance from planet to intersect
				planet.distToBall = distance(planet.circle.x, planet.circle.y, planet.interX, planet.interY)
				-- then compare to sentinels and modify G and ball speed accordingly
				if planet.distToBall >= planet.outerBarrier then
					-- ball goes slower
					ball.goalSpeed = 5
constForce = 0.3
				elseif planet.distToBall >= planet.innerBarrier and planet.distToBall < planet.outerBarrier then
					-- ball goes medium speed
					ball.goalSpeed = 7
constForce = 0.5
				elseif planet.distToBall < planet.innerBarrier and planet.distToBall > planet.circle.r then
					--ball goes faster
					ball.goalSpeed = 9
constForce = 0.7
				elseif planet.distToBall < planet.circle.r then
					-- ball kills planet
				end
			end 
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