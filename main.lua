WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
mobile = false

require 'devMenu'
require 'planet'
require 'ball'
require 'scoreboard'
require 'button' 
local rs = require("resolution_solution")

-- approach 1: return gravity as a constant
-- approach 2: return gravity as a function of velocity


--[[
gravity approach: 
once inside a field, ball moves along with planet
distance between ray and planet center sets goal speed or if planet should blow up
planet gravity releases ball at an angle dependent on distance between ray ans planet
]]


local FORCE_MULTIPLIER = 10400
constForce = 0.4

-- update stuff
function love.update(dt)
    
    -- handle keyboard input
    if mobile == true then
	    handleTouchInput()
    else
	    handleKeyboardInput()
    end

handleGravity()
    
	-- handle score events
    local id = ball:score()
    if id ~= 0 then 
        scoreboard:score(id)
    end
	
	
    -- update positions
    ball.update()
    planet1.update(dt)
    planet2.update(dt)
    devMenu.update()
end

-- the way I setup the planet code is
-- a violation of DRY. 
function handleGravity()
    if planet1.gravField:collide(ball.circle) then
        --change line below for testing behavior 
        inField = true
        if doGravity == true then
            ball:addForce(getGravForce(planet1.circle, ball.circle, FORCE_MULTIPLIER))
        end

        if inField == true and wasInField == false then
			doGravity = true 

            -- get angle
            dirX, dirY = getDir(0, 0, ball.dx, ball.dy)
            -- calc exit angle
            dirX, dirY = translateDir(dirX, dirY, 180, true)
			--reduction = reduction + 0.01
        end

        if inField == true and wasInField == true then
            ballDirX, ballDirY = getDir(0, 0, ball.dx, ball.dy)
            local diff = 0.1
            if math.abs(ballDirX - dirX) < diff and math.abs(ballDirY - dirY) < diff then
                -- code to stop gravity here
				doGravity = false
            end
        end
    else
        inField = false
    end

    wasInField = inField
end

function love.load()
    math.randomseed(os.time())
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        resizable = false,
        vsync = true
    })
  
    -- phone setup
    local os = love.system.getOS() 
    if os == "Android" or os == "iOS" then
	    mobile = true
	end
    
    setupObjects()
    love.graphics.setFont(titleFont)
end

function love.draw()
    rs.push()
    local old_x, old_y, old_w, old_h = love.graphics.getScissor()
    love.graphics.setScissor(rs.get_game_zone())
    
    -- start drawing
    local titleText = "GRAVITY PONG"
    love.graphics.clear(.1, .1, .1)

    love.graphics.draw(bkg, 0, 0, 0, WINDOW_WIDTH / bkg:getWidth(), WINDOW_HEIGHT / bkg:getHeight())
    love.graphics.printf(titleText, 0, WINDOW_HEIGHT * 0.15, WINDOW_WIDTH, 'center') 
    planet1.draw()   
    planet2.draw()  
    ball.draw()  
    scoreboard:draw()
    devMenu:draw()
    
    -- stop drawing
    love.graphics.setScissor(old_x, old_y, old_w, old_h)
	rs.pop()
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

-- making these global isnt the best but I'm keeping them all in this one function to make keeping track easier
function setupObjects()
    local SIZE_SAFE_ZONE = WINDOW_WIDTH / 80
    local BALL_SIZE = WINDOW_WIDTH / 80
    local PLANET_SIZE = WINDOW_WIDTH / 30
    local GRAV_FIELD_SIZE = WINDOW_WIDTH / 8
    
    rs.conf({game_width = WINDOW_WIDTH, game_height = WINDOW_HEIGHT, scale_mode = rs.ASPECT_MODE})
    rs.setMode(rs.game_width, rs.game_height, {resizable = true})
    love.resize = function(w, h)
		rs.resize(w, h)
	end
    titleFont = love.graphics.newFont('asset/titlefont.ttf', 36)
    devFont = love.graphics.newFont('asset/titlefont.ttf', 24)
    planet1Img = love.graphics.newImage('asset/planet1.PNG')
    planet2Img = love.graphics.newImage('asset/planet2.PNG')
    ballImg = love.graphics.newImage('asset/ball.PNG')
    gravityFieldImg = love.graphics.newImage('asset/gravField.PNG')
    bkg = love.graphics.newImage('asset/background.PNG')
    scoreboard = makeScoreboard()
    ball = makeBall(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, WINDOW_WIDTH / 80, ballImg)
    planet1 = makePlanet(GRAV_FIELD_SIZE + SIZE_SAFE_ZONE, WINDOW_HEIGHT / 2, PLANET_SIZE, planet1Img, GRAV_FIELD_SIZE , gravityFieldImg)
    planet2 = makePlanet(WINDOW_WIDTH - (GRAV_FIELD_SIZE + SIZE_SAFE_ZONE), WINDOW_HEIGHT / 2, PLANET_SIZE, planet2Img, GRAV_FIELD_SIZE, gravityFieldImg)
    devMenu = getDevMenu()
    devMenu:addVariable(getBallSpeed, "Ball Speed: ", true, setBallSpeed)
    devMenu:addVariable(getBallGoalSpd, "Ball Goal Speed: ", true, setBallGoalSpd)
    devMenu:addVariable(getGravCoef, "Gravity Coef: ", true, setGravCoef)
end

-- returns the force of gravity as a vector dx / dy format
-- remember that order matters, circle1 is your planet, circle2 is your ball
function getGravForce(circle1, circle2, forceMultiplier)
    local BALL_MASS = 1
    local DIST = distance(circle1.x, circle1.y, circle2.x, circle2.y)
    local deltaX, deltaY = getDir(circle1.x, circle1.y, circle2.x, circle2.y)
    local force = calcForce(DIST) -- reduction
    --(forceMultiplier * BALL_MASS) / ( (DIST + circle1.r + circle2.r) * (DIST) )  -- this idea was to control gravity as a matter of surface distance
    return deltaX * force, deltaY * force
end

function calcForce(x)
    return constForce
end

-- if this doesnt get directionality right, mess with delta()
-- returns a unit vector
function getDir(x1, y1, x2, y2)
    local deltaX, deltaY = delta(x1, y1, x2, y2)
    return normalizeVect(deltaX, deltaY)
end

function translateDir(dx, dy, degrees, clockwise)
	if clockwise == nil then
		clockwise = true
	end
	
	local radians = math.rad(degrees)
	
	if clockwise == false then
		radians = -radians
	end
	
	return (dx * math.cos(radians) - dy * math.sin(radians)) , (dx * math.sin(radians) + dy * math.cos(radians))
end

-- makes any vector into a unit vector
function normalizeVect(dx, dy)
    dist = distance(0, 0, dx, dy)
    return dx / dist, dy / dist
end

-- returns vector of the given coordinates
-- might need to adjust how this works to handle directionality
-- first coordinate pair is the destination (direction to go towards)
-- second pair is the source (starting point)
function delta(x1, y1, x2, y2)
    return x1 - x2, y1 - y2
end

-- returns the distance between two points
function distance(x1, y1, x2, y2)
    local deltaX, deltaY = delta(x1, y1, x2, y2) 
    return math.sqrt(deltaX * deltaX + deltaY * deltaY)
end 

-- takes a deltax/y vector as an argument as well as a minumum speed and maximum speed
-- and returns a vector in the same direction with the speed constrained between the given
-- speeds
function normalizeSpeed(deltaX, deltaY, max, min)
    local currentSpeed = distance(0, 0, deltaX, deltaY)
    if currentSpeed < min then
        return setSpeed(deltaX, deltaY, min)
    elseif currentSpeed > max then 
        return setSpeed(deltaX, deltaY, max)
    else
        return deltaX, deltaY
    end
end

-- sets the speed of the inputted vector to the inputted speed then
-- returns the new vector at that speed
function setSpeed(deltaX, deltaY, speed)
    dXNorm, dYNorm = normalizeVect(deltaX, deltaY)
    return speed * dXNorm, speed * dYNorm
end

function getSpeed(deltX, deltY)
	return distance(0, 0, deltX, deltY)
end

function getGravForceArcade(ballCircle, bodyCircle)

end

-- moved here to clean up the update function
function handleKeyboardInput()
	if love.keyboard.isDown('w') then
        planet1.speed = -10
    elseif love.keyboard.isDown('s') then
        planet1.speed = 10
    else
        planet1.speed = 0
    end 

    if love.keyboard.isDown('up') then
        planet2.speed = -10
    elseif love.keyboard.isDown('down') then
        planet2.speed = 10
    else 
        planet2.speed = 0
    end
end

function handleTouchInput()
local stopPlanet1 = true
local stopPlanet2 = true
local buffer = 25
	local planet1VertBoundary = WINDOW_WIDTH / 3
	local planet2VertBoundary = WINDOW_WIDTH * 2 / 3
	local touches = love.touch.getTouches()

	for i, id in ipairs(touches) do
		local x, y = love.touch.getPosition(id)
		x, y = rs.to_game(x, y)
		
		-- this might bug out for multiple touches at once
		if x < planet1VertBoundary and distance(planet1.circle.x, planet1.circle.y, x, y) > buffer then
			planet1:setDir(getDir(planet1.circle.x, planet1.circle.y, x, y))
stopPlanet1 = false
		end

        if x > planet2VertBoundary and distance(planet2.circle.x, planet2.circle.y, x, y) > buffer then
            planet2:setDir(getDir(planet2.circle.x, planet2.circle.y, x, y))
stopPlanet2 = false
end
	end

if stopPlanet1 then
planet1:stop()
end

if stopPlanet2 then
planet2:stop()
end

end


function love.mousepressed(_x, _y)
	_x, _y = rs.to_game(_x, _y)
	devMenu:handleClicks(_x, _y)
end

--[[
dev menu functions
This is a hacky solution but the dev menu doesnt need to follow best practices.
Additionally this allows me to have finer control over the dev menu without creating
an esoteric abstraction that only makes maintaining the codebasw harder.]]

function getBallSpeed()
	return getSpeed(ball.dx, ball.dy)
end

function setBallSpeed(newSpd)
	ball.dx, ball.dy = setSpeed(ball.dx, ball.dy, newSpd) 
end

function getBallGoalSpd()
	return ball.goalSpeed
end

function setBallGoalSpd(newSpd)
	ball.goalSpeed = newSpd
end

-- for using constants for gravity calcs
function getGravCoef()
	return constForce
end

function setGravCoef(newCoef)
	constForce = newCoef
end


-- alternative algorithm for calculating ball gravity physics
--[[ 1. the instant the ball collides with a field hit box, we take a snapshot of the following
        a. the current direction
        b. the current speed in that direction
        c. the distance of a raytrace in the direction to either the surface of the center of the relevant body
    2. Using the data above we perform logic as follows
        a. we set an exit speed which scales positively or negatively from the distance calced in c
        b. if c is less than some number, we let the ball hit the planet and do the relevant logic for that
        c. now knowing the exit speed we scale down the total speed until it hits 0 within some distance of the edge of the field
            i. specifically, the higher c is, the longer it should take to scale this
            ii. we treat this as a sort of rotated coordinate plane allowing us to control speed in two different directions
            iii, why? for better control over the 'look'
            iv. the lateral speed too should then be relative to what c is

current limitation: how we figure out the angle and do the math accordingly
maybe we can re-rotate the rotated plane relative to c, and then scale on these new x and y's
    1. getDir()
    2. getSpeed()
    3. getLateralToRay()
    4. newSpeed = getSpeed() + setSpeedByLateral() -- the exit speed should reach this
    5. scaleRotatedSpeed(dir) -- increment from original speed to 0 on the plane of original direction
    6. scaleRotatedSpeed(-dir) -- increment from 0 to -newSpeed
    7. -- at the same time
    8. scaleLateralSpeed() -- all this stuff depends on your lateral to ray
    9.--]]
    