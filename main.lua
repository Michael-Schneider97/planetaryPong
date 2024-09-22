-- Important globals
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
mobile = false
showTutorialOnStart = true
local FORCE_MULTIPLIER = 10400
constForce = 0.3
gameState = {play = 'play', pause = 'pause', menu = 'menu'}

-- libs etc
require 'devMenu'
require 'planet'
require 'ball'
require 'scoreboard'
require 'button' 
require 'physics'
Slab = require 'Slab' -- <- will this work?
local rs = require("resolution_solution")

-- approach 1: return gravity as a constant
-- approach 2: return gravity as a function of velocity


--[[
gravity approach: 
once inside a field, ball moves along with planet
distance between ray and planet center sets goal speed or if planet should blow up
planet gravity releases ball at an angle dependent on distance between ray ans planet
]]

-- love callbacks

function love.update(dt)
    
    

    -- assignment every update cycle is bad but shouldnt impact performance enough to matter
    if currentState == gameState.pause then
        devMenu.show = false
        updateUi(dt)
end

    if currentState == gameState.play then
        devMenu.show = true
        updateGravSim()
    end
end

function love.load()
    math.randomseed(os.time())
    Slab.Initialize()
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
currentState = gameState.pause
end

function love.draw()
    rs.push()
    local old_x, old_y, old_w, old_h = love.graphics.getScissor()
    love.graphics.setScissor(rs.get_game_zone())
    
    -- start drawing 
    local titleText = "GRAVITY PONG"
    love.graphics.clear(.1, .1, .1)

    love.graphics.draw(bkg, 0, 0, 0, WINDOW_WIDTH / bkg:getWidth(), WINDOW_HEIGHT / bkg:getHeight())
    love.graphics.setFont(titleFont)
    love.graphics.printf(titleText, 0, WINDOW_HEIGHT * 0.15, WINDOW_WIDTH, 'center') 
    planet1.draw()   
    planet2.draw()  
    ball.draw()  
    scoreboard:draw()
    
    devMenu:draw()
    if currentState ~= gameState.play then
        Slab.Draw() 
    end 

    -- stop drawing
    love.graphics.setScissor(old_x, old_y, old_w, old_h)
	rs.pop()
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.mousepressed(_x, _y)
	_x, _y = rs.to_game(_x, _y)
	devMenu:handleClicks(_x, _y)
end

-- delegated functions
function updateUi(dt)
    Slab.Update(dt)
    
    if showTutorialOnStart == true then
        doTutorial()
    -- else skip tutorial, go to whatever was next either menu or gameplay 
    else
	    currentState = gameState.play
    end
end

-- handles navigation between tutorials
function doTutorial()
	local tutorials = {tutorial1, tutorial2}
	if cur == nil then
         cur = 1
         endTutorial = false
    end

	
	cur = tutorials[cur]()
	if cur > table.getn(tutorials) then
	    -- tutorial is finished
    endTutorial = true
    cur = nil
	end
	
	if endTutorial == true then
      endTutorial = nil
	    currentState = gameState.play
	end 
end

function tutorial1()
    local tutorial1Str = "Use your gravitational field to slingshot the moon back at your opponent. You score a point when the moon passes your opponent or destroys their planet. "
    local index = 1
    --conditional checks if "dont show again" has been pressed here
    Slab.BeginWindow('Tutorial1',  {Title = "", AutoSizeWindow = false})
    Slab.Textf("Tutorial Part 1")
    Slab.Textf(tutorial1Str)
    if Slab.Button("Next") then
    --replace current tutorial with second tutorial
       index = 2
    end
    Slab.EndWindow()
    return index
end

function tutorial2()
    local tutorial2Str = "Tutorial 2 test string. "
    local index = 2
    --conditional checks if "dont show again" has been pressed here
    Slab.BeginWindow('Tutorial2',  {Title = "", AutoSizeWindow = false})
    Slab.Textf("Tutorial Part 2")
    Slab.Textf(tutorial2Str)
    
    if Slab.CheckBox(Checked, "Don't Show Again") then
		Checked = not Checked 
	end
    
    if Slab.Button("Exit") then
    --replace current tutorial with second tutorial
       endTutorial = true
       index = 3
    end
    Slab.EndWindow()
    if Checked == false then
	    showTutorialOnStart = false
    end
   
    return index
end

-- update stuff
function updateGravSim()
    
    -- handle keyboard input
    if mobile == true then
	    handleTouchInput()
    else
	    handleKeyboardInput()
    end

	planet1:handleGravity()
	planet2:handleGravity()
    
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
    