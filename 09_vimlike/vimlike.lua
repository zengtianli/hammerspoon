if not hs.myVars then
	hs.myVars = {}
end

hs.myVars.menuBar = hs.menubar.new()
hs.myVars.menuBar:setTitle("Waiting...")
hs.myVars.keyBuffer = ""
hs.myVars.inNormMode = false
hs.myVars.operationFlag = nil
local operations = require("vimlike.operations")
local motions = require("vimlike.motions")
local applicationChanged = require("vimlike.applicationChanged")
-- local ddHandler = require("ddHandler")

local function handleNormMode(event)
	local keyCode = event:getKeyCode()
	local flags = event:getFlags()
	if flags["cmd"] and flags["ctrl"] and flags["shift"] then
		return false
	end

	-- if ddHandler.handle(event) then
	-- 	return true
	-- end
	if operations.handleOperation(event) then
		return true
	end

	if hs.myVars.operationFlag then
		-- Handle operation-based motion here
		if keyCode == hs.keycodes.map["h"] then
			if hs.myVars.operationFlag == "delete" then
				if event:getFlags()["shift"] then
					hs.eventtap.keyStroke({ "cmd" }, "delete")
				else
					hs.eventtap.keyStroke({}, "delete") -- Delete character
				end
			end
		elseif keyCode == hs.keycodes.map["j"] then
			-- Delete line below if "d" was pressed before "j"
			if hs.myVars.operationFlag == "delete" then
				hs.eventtap.keyStroke({}, "down")
				hs.eventtap.keyStroke({ "cmd" }, "left")       -- Start of the line
				hs.eventtap.keyStroke({ "shift", "cmd" }, "right") -- Select to the end
				hs.eventtap.keyStroke({}, "delete")            -- Delete selection
			end
		elseif keyCode == hs.keycodes.map["k"] then
			-- Delete line above if "d" was pressed before "k"
			if hs.myVars.operationFlag == "delete" then
				hs.eventtap.keyStroke({}, "up")
				hs.eventtap.keyStroke({ "cmd" }, "left")       -- Start of the line
				hs.eventtap.keyStroke({ "shift", "cmd" }, "right") -- Select to the end
				hs.eventtap.keyStroke({}, "delete")            -- Delete selection
			end
		elseif keyCode == hs.keycodes.map["l"] then
			if hs.myVars.operationFlag == "delete" then
				if event:getFlags()["shift"] then
					hs.eventtap.keyStroke({ "shift", "cmd" }, "right") -- Select next character
					hs.eventtap.keyStroke({}, "delete")           -- Delete selection
				else
					hs.eventtap.keyStroke({ "shift" }, "right")   -- Select next character
					hs.eventtap.keyStroke({}, "delete")           -- Delete selection
				end
			end
		elseif keyCode == hs.keycodes.map["g"] then
			if hs.myVars.operationFlag == "delete" then
				if event:getFlags()["shift"] then
					hs.eventtap.keyStroke({ "shift", "cmd" }, "down") -- Select next character
					hs.eventtap.keyStroke({}, "delete")          -- Delete selection
					hs.myVars.operationFlag = nil
					firstDPressed = false
					return true
				else
					if not firstGPressed then
						firstGPressed = true
						return true
					else
						hs.eventtap.keyStroke({ "shift", "cmd" }, "up") -- Select next character
						hs.eventtap.keyStroke({}, "delete")       -- Delete selection
						hs.myVars.operationFlag = nil
						firstDPressed = false
						firstGPressed = false -- Reset the flag
					end
				end
				return true
			end
		end

		-- Clear the operationFlag after handling it
		hs.myVars.operationFlag = nil

		return true
	else
		-- motion
		if motions.handleMotion(event) then
			return true
		end
	end

	return false
end

hs.myVars.appWatcher = hs.application.watcher.new(function(appName, eventType)
	-- We pass in hs and handleNormMode as they are used within the function
	applicationChanged(appName, eventType, hs, handleNormMode)
end)
hs.myVars.appWatcher:start()
