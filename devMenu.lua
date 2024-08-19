-- developer menu. use this to tinker with values and see certain values

function getDevMenu()
	-- implement as a table associated to strings
	-- display data at some spot
	local devMenu = {trackedData = {}, vars = {}, names = {}, editable = {}, setters = {}}
	
	-- allows you to add data to be tracked by the table
	-- you have to add it as a function
	-- if you dont want a setter just pass as nil
	function devMenu:addVariable(getter, name, allowModification, setter)
		table.insert(devMenu.names, name)
		devMenu.trackedData[name] = getter
		devMenu.editable[name] = allowModification
		
		if allowModification == true then
			devMenu.setters[name] = setter
		end
	end
	
	-- grab current data
	function devMenu:update()
		for k, v in pairs(devMenu.names) do
			devMenu.vars[v] = devMenu.trackedData[v]()
		end
	end
	
	-- displays current data as well as other ui elements
	function devMenu:draw()
oldFont = love.graphics.getFont()
love.graphics.setFont(devFont)
		-- bkg 
		-- list of items
		-- if applicable, modification fields
		local x = 0
		local y = 0
		-- get current font size
-- set font smaller

		-- update this bad boy
		for k, v in pairs(devMenu.names) do
			x = 0
love.graphics.print(v, x, y)
x = devFont:getWidth(v) + 10
love.graphics.print(devMenu.vars[v], x, y)
end
			love.graphics.setFont(oldFont)
		end
		
	
	return devMenu
end

