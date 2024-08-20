function makeButton(x, y, w, h, func)
	local button = {x = x, y = y, w = w, h = h}
button.wasClicked = false
	
	function button:reset(x_, y_, w_, h_)
		button.x = x_
		button.y = y_
		button.w = w_
		button.h = h_
	end
	
	function button:draw()
		local oldR, oldG, oldB, oldA = love.graphics.getColor()
		love.graphics.setColor(.5, 1, .5, .5)
		love.graphics.rectangle("fill", button.x, button.y, button.w, button.h)
		love.graphics.setColor(oldR, oldG, oldB, oldA)
	end
	
	-- put this in the love mouse pressed callback
	function button:click(x_, y_)
		if x_ >= button.x and x_ <= button.x + button.w and y_ >= button.y and y_ <= button.y + button.h then
button.wasClicked = true
		end
	end

function button:clicked()
if button.wasClicked then
button.wasClicked = false
return true
end
end
		













return button
end
	