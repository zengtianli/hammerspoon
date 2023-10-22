if not hs.myVars then
	hs.myVars = {}
end
hs.myVars.menuBar = hs.menubar.new()
hs.myVars.menuBar:setTitle("Waiting...")
hs.myVars.keyBuffer = ""
hs.myVars.inNormMode = false
hs.myVars.operationFlag = nil
local doubleKeyTimer = nil
local operations = require("operations")
local motions = require("motions")

local function handleNormMode(event)
	local keyCode = event:getKeyCode()
	local flags = event:getFlags()

	if operations.handleOperation(event) then
		return true
	end

	if hs.myVars.operationFlag then
		if keyCode == hs.keycodes.map["d"] then
			if hs.myVars.operationFlag == "delete" and doubleKeyTimer then
				doubleKeyTimer:stop()
				doubleKeyTimer = nil
				hs.alert.show("dd")
				hs.myVars.operationFlag = nil
				return true
			else
				hs.myVars.operationFlag = "delete"
				doubleKeyTimer = hs.timer.doAfter(0.5, function()
					doubleKeyTimer = nil
					hs.myVars.operationFlag = nil
				end)
				return true
			end
		end
		hs.myVars.operationFlag = nil
		return true
	end

	if motions.handleMotion(event) then
		return true
	end

	if doubleKeyTimer and keyCode ~= hs.keycodes.map["d"] then
		doubleKeyTimer:stop()
		doubleKeyTimer = nil
		hs.myVars.operationFlag = nil
	end
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
					return true
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

