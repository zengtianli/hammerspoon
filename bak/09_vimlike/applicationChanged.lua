-- applicationChanged.lua

local function applicationChanged(appName, eventType, hs, handleNormMode)
	local appsToHandleNormMode = {
		-- "WeChat",
		-- "Arc",
	}

	local function isInList(val, list)
		for _, v in ipairs(list) do
			if v == val then
				return true
			end
		end
		return false
	end

	if eventType == hs.application.watcher.activated then
		if hs.myVars.menuBar then
			hs.myVars.menuBar:setTitle(appName)
		end
		if isInList(appName, appsToHandleNormMode) and not hs.myVars.escapeTap then
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
		elseif hs.myVars.escapeTap and not isInList(appName, appsToHandleNormMode) then
			hs.myVars.escapeTap:stop()
			hs.myVars.escapeTap = nil
			hs.myVars.inNormMode = false
		end
	end
end

return applicationChanged
