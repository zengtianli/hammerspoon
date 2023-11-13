local shouldClick = false -- Default behavior is to click
local recordedAppPositions = hs.settings.get("recordedAppMousePositions") or {}
local function getCurrentAppName()
	local app = hs.application.frontmostApplication()
	return app and app:name() or "unknown"
end
local function recordMousePositionForApp()
	local currentPos = hs.mouse.absolutePosition()
	local appName = getCurrentAppName()
	if not recordedAppPositions[appName] then
		recordedAppPositions[appName] = {}
	end
	table.insert(recordedAppPositions[appName], currentPos)
	hs.settings.set("recordedAppMousePositions", recordedAppPositions) -- Save to persistent storage
	hs.alert.show("Recorded position for " .. appName .. " at position " .. #recordedAppPositions[appName])
end
local function moveToRecordedPositionsAndClickForApp(returnToOriginal)
	local returnToOriginal = returnToOriginal or false -- Default is true if not provided
	local appName = getCurrentAppName()
	local positionsForApp = recordedAppPositions[appName] or {}
	local originalPosition = hs.mouse.absolutePosition() -- Capture the original mouse position
	if #positionsForApp > 0 then
		local delay = 0
		for i, pos in ipairs(positionsForApp) do
			hs.timer.doAfter(delay, function()
				hs.mouse.absolutePosition(pos)
				hs.alert.show("Moved to position " .. i)
				if shouldClick then hs.eventtap.leftClick(pos) end
			end)
			delay = delay + 1
		end
		if returnToOriginal then
			hs.timer.doAfter(#positionsForApp, function()
				hs.alert.show("original Mode Finished moving to positions for " .. appName)
				hs.mouse.absolutePosition(originalPosition) -- Return to the original position only if returnToOriginal is true
			end)
		else
			hs.timer.doAfter(#positionsForApp, function()
				hs.alert.show("norma Mode Finished moving to positions for " .. appName)
			end)
		end
	else
		hs.alert.show("No positions recorded for " .. appName)
	end
end
local lastMovedIndexForApp = {}
local function moveToAdjacentRecordedPositionForApp(direction)
	local appName = getCurrentAppName()
	local positionsForApp = recordedAppPositions[appName] or {}
	if not lastMovedIndexForApp[appName] then
		lastMovedIndexForApp[appName] = 0
	end
	if #positionsForApp > 0 then
		if direction == "next" then
			lastMovedIndexForApp[appName] = (lastMovedIndexForApp[appName] % #positionsForApp) + 1
		else
			lastMovedIndexForApp[appName] = (lastMovedIndexForApp[appName] - 2 + #positionsForApp) % #positionsForApp + 1
		end
		local pos = positionsForApp[lastMovedIndexForApp[appName]]
		hs.mouse.absolutePosition(pos)
		hs.timer.usleep(500000) -- sleep for 0.5 seconds to observe the movement
		if shouldClick then hs.eventtap.leftClick(pos) end
		hs.alert.show("Moved to position " .. lastMovedIndexForApp[appName] .. " for " .. appName)
	else
		hs.alert.show("No positions recorded for " .. appName)
	end
end
local currentActivePosition = nil
local function clearRecordedPositionsForApp()
	local appName = getCurrentAppName()
	recordedAppPositions[appName] = {}
	hs.settings.set("recordedAppMousePositions", recordedAppPositions) -- Save updated data to persistent storage
	hs.alert.show("Cleared recorded positions for " .. appName)
end
local function moveToSpecifiedPositionForApp(positionIndex)
	local appName = getCurrentAppName()
	local positionsForApp = recordedAppPositions[appName] or {}
	if positionsForApp[positionIndex] then
		local pos = positionsForApp[positionIndex]
		hs.mouse.absolutePosition(pos)
		hs.timer.usleep(500000) -- sleep for 0.5 seconds to observe the movement
		if shouldClick then hs.eventtap.leftClick(pos) end
		currentActivePosition = positionIndex
		hs.alert.show("Moved to position " .. positionIndex .. " for " .. appName)
	else
		hs.alert.show("Position " .. positionIndex .. " not recorded for " .. appName)
	end
end
local function updateCurrentActivePositionForApp()
	if currentActivePosition then
		local appName = getCurrentAppName()
		local currentPos = hs.mouse.absolutePosition()
		recordedAppPositions[appName][currentActivePosition] = currentPos
		hs.alert.show("Updated position " .. currentActivePosition .. " for " .. appName)
	else
		hs.alert.show("No active position selected.")
	end
end
local appHotkeys = {
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "1", function() moveToSpecifiedPositionForApp(1) end),
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "2", function() moveToSpecifiedPositionForApp(2) end),
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "3", function() moveToSpecifiedPositionForApp(3) end),
	hs.hotkey.bind({ "alt" }, "tab", function() moveToAdjacentRecordedPositionForApp("next") end),
	hs.hotkey.bind({ "alt", "shift" }, "tab", function() moveToAdjacentRecordedPositionForApp("previous") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "U", updateCurrentActivePositionForApp),
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "R", recordMousePositionForApp),
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "C", clearRecordedPositionsForApp),
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "v", function() moveToRecordedPositionsAndClickForApp(false) end),
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "b", function() moveToRecordedPositionsAndClickForApp(true) end),
	hs.hotkey.bind({ "cmd", "ctrl", "shift", "alt" }, "c",
		function()
			shouldClick = not shouldClick
			local status = shouldClick and "enabled" or "disabled"
			hs.alert.show("Click functionality " .. status)
		end),
}
local hotkeysEnabled = true
function toggleAppHotkeys()
	if hotkeysEnabled then
		for _, hotkey in ipairs(appHotkeys) do
			hotkey:disable()
		end
		hotkeysEnabled = false
		-- hs.alert.show("recorded position disabled")
	else
		for _, hotkey in ipairs(appHotkeys) do
			hotkey:enable()
		end
		hotkeysEnabled = true
		-- hs.alert.show("recorded position enabled")
	end
end

-- run toggleAppHotkeys
toggleAppHotkeys()
hs.hotkey.bind({ "cmd", "ctrl", "shift", "alt" }, "r", toggleAppHotkeys)
