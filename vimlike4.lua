if not hs.myVars then
	hs.myVars = {}
end
hs.myVars.menuBar = hs.menubar.new()
hs.myVars.menuBar:setTitle("Waiting...")

hs.myVars.inNormMode = false -- 用于跟踪是否处于 "norm" 模式

-- Global state buffer
hs.myVars.keyBuffer = ""

-- Assuming you have set up: hs.myVars.inNormMode = false initially

local function handleNormMode(event)
	local keyCode = event:getKeyCode()
	local flags = event:getFlags()
	if keyCode == hs.keycodes.map["d"] and not hs.myVars.deleteFlag then
		hs.myVars.deleteFlag = true
		return true
	end
	-- if hs.myVars.deleteFlag then
	-- 	if keyCode == hs.keycodes.map["d"] then
	-- 		hs.eventtap.keyStroke({ "cmd" }, "left")        -- Move to the beginning of the line
	-- 		hs.eventtap.keyStroke({ "shift", "cmd" }, "right") -- Select to the end of the line
	-- 		hs.eventtap.keyStroke({ "cmd" }, "delete")      -- Cut the selected line
	-- 		hs.myVars.deleteFlag = false
	-- 		return true
	-- 	elseif keyCode == hs.keycodes.map["w"] then
	-- 		hs.eventtap.keyStroke({ "shift", "alt" }, "right") -- select next word
	-- 		hs.eventtap.keyStroke({ "cmd" }, "delete")      -- cut the selection
	-- 		hs.myVars.deleteFlag = false
	-- 		return true
	-- 	elseif keyCode == hs.keycodes.map["L"] then
	-- 		hs.eventtap.keyStroke({ "shift", "cmd" }, "right") -- select till end of line
	-- 		hs.eventtap.keyStroke({ "cmd" }, "delete")      -- cut the selection
	-- 		hs.myVars.deleteFlag = false
	-- 		return true
	-- 	elseif keyCode == hs.keycodes.map["h"] then
	-- 		hs.eventtap.keyStroke({ "shift", "cmd" }, "left") -- select till beginning of line
	-- 		hs.eventtap.keyStroke({ "cmd" }, "delete")     -- cut the selection
	-- 		hs.myVars.deleteFlag = false
	-- 		return true
	-- 	elseif keyCode == hs.keycodes.map["g"] then
	-- 		local flags = event:getFlags()
	-- 		if flags["shift"] then
	-- 			-- Handle "dG"
	-- 			hs.eventtap.keyStroke({ "shift", "cmd" }, "down") -- Select till end of document
	-- 			hs.eventtap.keyStroke({ "cmd" }, "delete")    -- Delete the selection
	-- 		else
	-- 			-- Handle "dgg"
	-- 			-- hs.eventtap.keyStroke({ "shift", "cmd" }, "up") -- Select till start of document
	-- 			hs.eventtap.keyStroke({ "cmd" }, "delete") -- Delete the selection
	-- 		end
	-- 		hs.myVars.deleteFlag = false
	-- 		return true
	-- 	end
	-- end

	-- Other key mappings
	if keyCode == hs.keycodes.map["h"] then
		if event:getFlags()["shift"] then
			hs.eventtap.keyStroke({ "cmd" }, "left")
			return true
		else
			hs.eventtap.keyStroke({}, "left")
			return true
		end
	elseif keyCode == hs.keycodes.map["j"] then
		hs.eventtap.keyStroke({}, "down")
		return true
	elseif keyCode == hs.keycodes.map["k"] then
		hs.eventtap.keyStroke({}, "up")
		return true
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
	elseif keyCode == hs.keycodes.map["w"] then
		hs.eventtap.keyStroke({ "alt" }, "right") -- Move to the next word
		return true
	elseif keyCode == hs.keycodes.map["b"] then
		hs.eventtap.keyStroke({ "alt" }, "left") -- Move to the previous word
		return true
	elseif keyCode == hs.keycodes.map["x"] then
		hs.eventtap.keyStroke({}, "delete") -- Delete character under cursor
		return true
	elseif keyCode == hs.keycodes.map["u"] then
		if event:getFlags()["shift"] then
			-- Handle "U"
			hs.eventtap.keyStroke({ "cmd", "shift" }, "z") -- Redo last undone change
			return true
		else
			-- Handle "u"
			hs.eventtap.keyStroke({ "cmd" }, "z") -- Undo last change
			return true
		end
	elseif keyCode == hs.keycodes.map["a"] then
		hs.myVars.inNormMode = false
		hs.myVars.deleteFlag = false
		hs.alert.show("Exiting norm mode")
		if event:getFlags()["shift"] then
			hs.eventtap.keyStroke({ "cmd" }, "right")
			return true
		end
	elseif keyCode == hs.keycodes.map["i"] then
		hs.myVars.inNormMode = false
		hs.myVars.deleteFlag = false
		hs.alert.show("Exiting norm mode")
		if event:getFlags()["shift"] then
			hs.eventtap.keyStroke({ "cmd" }, "left")
			return true
		end
	elseif keyCode == hs.keycodes.map["o"] then
		hs.myVars.inNormMode = false
		hs.alert.show("Exiting norm mode")
		hs.eventtap.keyStroke({ "cmd" }, "right")
		hs.eventtap.keyStroke({ "shift" }, "return")
		return true
	elseif keyCode == hs.keycodes.map["p"] then
		hs.eventtap.keyStroke({ "cmd" }, "v") -- Paste
		return true
	end

	return false
end


local function applicationChanged(appName, eventType)
	if eventType == hs.application.watcher.activated then
		if hs.myVars.menuBar then
			hs.myVars.menuBar:setTitle(appName)
		end

		if appName == "WeChat" and not hs.myVars.escapeTap then
			hs.myVars.escapeTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
				local keyCode = event:getKeyCode()

				if hs.myVars.inNormMode then
					return handleNormMode(event)
				elseif keyCode == hs.keycodes.map["escape"] then
					hs.myVars.inNormMode = true
					hs.alert.show("norm")
					return true -- 这将消耗事件，所以 Escape 不会有默认行为
				end

				return false
			end)
			hs.myVars.escapeTap:start()
		elseif hs.myVars.escapeTap and appName ~= "WeChat" then
			hs.myVars.escapeTap:stop()
			hs.myVars.escapeTap = nil
			hs.myVars.inNormMode = false
		end
	end
end

hs.myVars.appWatcher = hs.application.watcher.new(applicationChanged)
hs.myVars.appWatcher:start()
