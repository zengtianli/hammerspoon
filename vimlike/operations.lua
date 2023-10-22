local operations = {}
function operations.handleOperation(event)
	local keyCode = event:getKeyCode()
	if keyCode == hs.keycodes.map["d"] then
		if not firstDPressed then
			-- If this is the first 'd' press
			firstDPressed = true
			hs.myVars.operationFlag = "delete"
			return true
		else
			hs.eventtap.keyStroke({ "cmd" }, "left")        -- Move to the start of the line
			hs.eventtap.keyStroke({ "shift", "cmd" }, "right") -- Select to the end
			hs.eventtap.keyStroke({}, "delete")             -- Delete selection
			firstDPressed = false                           -- Reset the flag
			hs.myVars.operationFlag = nil                   -- Clear the operation flag
			return true
		end
		-- for c similar to d but with insert
	elseif keyCode == hs.keycodes.map["c"] then
		if not firstCPressed then
			-- If this is the first 'c' press
			firstCPressed = true
			hs.myVars.operationFlag = "change"
			return true
		else
			hs.eventtap.keyStroke({ "cmd" }, "left")        -- Move to the start of the line
			hs.eventtap.keyStroke({ "shift", "cmd" }, "right") -- Select to the end
			hs.eventtap.keyStroke({}, "delete")             -- Delete selection
			hs.myVars.inNormMode = false
			hs.alert.show("insert")
			firstCPressed = false      -- Reset the flag
			hs.myVars.operationFlag = nil -- Clear the operation flag
			return true
		end
		-- for y
	elseif keyCode == hs.keycodes.map["x"] then
		hs.eventtap.keyStroke({}, "delete")
		return true
	elseif keyCode == hs.keycodes.map["u"] then
		if event:getFlags()["shift"] then
			hs.eventtap.keyStroke({ "shift", "cmd" }, "z")
			return true
		else
			hs.eventtap.keyStroke({ "cmd" }, "z")
			return true
		end
	elseif keyCode == hs.keycodes.map["a"] then
		if event:getFlags()["shift"] then
			hs.myVars.inNormMode = false
			hs.eventtap.keyStroke({ "cmd" }, "right")
			hs.alert.show("insert")
			return true
		else
			hs.eventtap.keyStroke({}, "right")
			hs.myVars.inNormMode = false
			hs.alert.show("insert")
			return true
		end
		-- for i
	elseif keyCode == hs.keycodes.map["i"] then
		if event:getFlags()["shift"] then
			hs.myVars.inNormMode = false
			hs.alert.show("insert")
			return true
		else
			hs.myVars.inNormMode = false
			hs.alert.show("insert")
			return true
		end
		-- for o
	elseif keyCode == hs.keycodes.map["o"] then
		hs.eventtap.keyStroke({}, "right")
		hs.eventtap.keyStroke({ "shift" }, "return")
		hs.myVars.inNormMode = false
		hs.alert.show("insert")
		return true
	end
end

return operations
