local motions = {}

function motions.handleMotion(event)
	local keyCode = event:getKeyCode()
	local flags = event:getFlags()

	if keyCode == hs.keycodes.map["h"] then
		if event:getFlags()["shift"] then
			hs.eventtap.keyStroke({ "cmd" }, "left")
			return true
		else
			hs.eventtap.keyStroke({}, "left")
			return true
		end
	elseif keyCode == hs.keycodes.map["l"] then
		if event:getFlags()["shift"] then
			hs.eventtap.keyStroke({ "cmd" }, "right")
			return true
		else
			hs.eventtap.keyStroke({}, "right")
			return true
		end
	elseif keyCode == hs.keycodes.map["g"] then
		if flags["shift"] then
			hs.eventtap.keyStroke({ "cmd" }, "down") -- Handle "G"
			return true
		else
			hs.eventtap.keyStroke({ "cmd" }, "up") -- Handle "gg"
			return true
		end
	elseif keyCode == hs.keycodes.map["j"] then
		hs.eventtap.keyStroke({}, "down")
		return true
	elseif keyCode == hs.keycodes.map["k"] then
		hs.eventtap.keyStroke({}, "up")
		return true
	elseif keyCode == hs.keycodes.map["w"] then
		hs.eventtap.keyStroke({ "alt" }, "right") -- Move to the next word
		return true
	elseif keyCode == hs.keycodes.map["b"] then
		hs.eventtap.keyStroke({ "alt" }, "left") -- Move to the previous word
		return true
	end

	return false
end

return motions
