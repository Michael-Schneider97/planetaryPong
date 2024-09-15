-- gravity, vector math, physics functions

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

-- finds the point where a pair of lines intersect
function getIntersect(line1y1, line1y2, line2y1, line2y2)
	local line1Slope = getSlope(0, line1y1, WINDOW_WIDTH, line1y2)
	local line2Slope = getSlope(0, line2y1, WINDOW_WIDTH, line2y2)
	local x = ( line2y1 - line1y1 ) / (line1Slope - line2Slope)
	local y = line1Slope * x + line1y1
	-- we should handle the case where there is no intersect 
	return x, y
end

-- gets the y intercepts at the edges of the window for a
-- moving object
-- im not actually 100% sure this works, mathematically speaking
function getYIntercepts(x, y, deltaX, deltaY)
	local yInter = y - ((deltaY / deltaX) * x) 
	return yInter, (deltaY / deltaX) * WINDOW_WIDTH + yInter
end

-- returns the slope of a line
function getSlope(x1, y1, x2, y2)
	if x1 == x2 then
		return math.huge
	end 
	
	return (y2 - y1) / (x2 - x1)
end


-- returns direction from point 1 to point 2
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

-- Returns the angle in degrees between a pair of vectors
-- If only one vector is supplied, returns the angle between that and {x = 1, y = 0}
function vectToDeg(dx1, dy1, dx2, dy2)
	if dx2 == nil then
		dx2, dy2 = getDir(0, 0, 1, 0)
	else
		dx2, dy2 = getDir(0, 0, dx2, dy2)
	end
	
	dx1, dy1 = getDir(0, 0, dx1, dy1)
	
	local vect1Dist = distance(0, 0, dx1, dy1)
	local vect2Dist = distance(0, 0, dx2, dy2)
	local distBetween = distance(dx1, dy1, dx2, dy2)
	
	return math.deg(math.acos((vect1Dist * vect1Dist + vect2Dist * vect2Dist - distBetween * distBetween) / (2 * vect1Dist * vect2Dist)))
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
