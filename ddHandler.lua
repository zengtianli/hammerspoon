local ddHandler = {}

-- This variable will keep track of the first 'd' press
local firstDPressed = false

function ddHandler.handle(event)
	local keyCode = event:getKeyCode()

	-- Check for the 'd' key
	if keyCode == hs.keycodes.map["d"] then
		-- If this is the first 'd' press, set the flag and return
		if not firstDPressed then
			firstDPressed = true
			return true
		else
			-- If this is the second 'd' press, execute the delete line command
			hs.eventtap.keyStroke({ "cmd" }, "left")                 -- Move to the start of the line
			hs.eventtap.keyStroke({ "shift", "cmd" }, "right")       -- Select to the end
			hs.eventtap.keyStroke({}, "delete")                      -- Delete selection
			firstDPressed = false                                    -- Reset the flag
			return true
		end
	else
		-- If any other key is pressed after the first 'd', reset the flag
		firstDPressed = false
	end

	return false
end

return ddHandler
