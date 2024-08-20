-- developer menu. use this to tinker with values and see certain values

function getDevMenu()
	-- implement as a table associated to strings
	-- display data at some spot
	local devMenu = {trackedData = {}, vars = {}, names = {}, editable = {}, setters = {}, buttonsDown = {}, buttonsUp = {} }
	devMenu.incrementor = 0.5
	
	-- allows you to add data to be tracked by the table
	-- you have to add it as a function
	function devMenu:addVariable(getter, name, allowModification, setter)
		table.insert(devMenu.names, name)
		devMenu.trackedData[name] = getter
		devMenu.editable[name] = allowModification
		
		if allowModification == true then
			devMenu.setters[name] = setter
			devMenu.buttonsDown[name] = makeButton(0, 0, 0, 0, devMenu.setters[name])
			devMenu.buttonsUp[name] = makeButton(0, 0, 0, 0)
		end
	end
	
	-- goes into love 2d call back
	function devMenu:handleClicks(x_, y_)
		--iterate over buttons, setting them to clicked if the provided x and y matter
		for k, v in pairs(devMenu.names) do
			devMenu.buttonsDown[v]:click(x_, y_)
			devMenu.buttonsUp[v]:click(x_, y_)
		end
	end

	-- grab current data
	function devMenu:update()
		for k, v in pairs(devMenu.names) do
			devMenu.vars[v] = devMenu.trackedData[v]()
			if(devMenu.buttonsDown[v]:clicked()) then
				devMenu.setters[v](devMenu.trackedData[v]() - devMenu.incrementor)
			end
			if devMenu.buttonsUp[v]:clicked() then
				devMenu.setters[v](devMenu.trackedData[v]() + devMenu.incrementor)
			end
		end
	end
	
	-- displays current data as well as other ui elements
	function devMenu:draw()
		oldFont = love.graphics.getFont()
		love.graphics.setFont(devFont)
		local height = devFont:getHeight()
		
		local x = 0
		local y = 50

		-- update this bad boy
		for k, v in pairs(devMenu.names) do
			x = 0
			love.graphics.print(v, x, y)
			x = devFont:getWidth(v) + 10
			love.graphics.print(devMenu.vars[v], x, y)
			x = x + devFont:getWidth(devMenu.vars[v]) + 10
			devMenu.buttonsDown[v]:reset(x, y, height, height)
			devMenu.buttonsUp[v]:reset(x + height + height, y, height, height)
			devMenu.buttonsDown[v]:draw()
			devMenu.buttonsUp[v]:draw()
			y = y + height + 10
		end
		
		love.graphics.setFont(oldFont)
	end
	
	return devMenu
end













