-- On load, fetch saved positions for all apps from Hammerspoon settings
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
local function moveToRecordedPositionsAndClickForApp()
	local appName = getCurrentAppName()
	local positionsForApp = recordedAppPositions[appName] or {}
	if #positionsForApp > 0 then
		local delay = 0
		for i, pos in ipairs(positionsForApp) do
			hs.timer.doAfter(delay, function()
				hs.mouse.absolutePosition(pos)
				hs.alert.show("Moved to position " .. i)
				hs.eventtap.leftClick(pos)
			end)
			delay = delay + 1
		end
		hs.doAfter(#positionsForApp, function()
			hs.alert.show("Finished moving to positions for " .. appName)
		end)
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
		hs.eventtap.leftClick(pos)

		hs.alert.show("Moved to position " .. lastMovedIndexForApp[appName] .. " for " .. appName)
	else
		hs.alert.show("No positions recorded for " .. appName)
	end
end

-- Keybindings
local currentActivePosition = nil
-- hs.hotkey.bind({ "alt" }, "tab", moveToNextRecordedPositionForApp)
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
		hs.eventtap.leftClick(pos)
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
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "U", updateCurrentActivePositionForApp)

-- Keybindings
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "1", function() moveToSpecifiedPositionForApp(1) end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "2", function() moveToSpecifiedPositionForApp(2) end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "3", function() moveToSpecifiedPositionForApp(3) end)
hs.hotkey.bind({ "alt" }, "tab", function() moveToAdjacentRecordedPositionForApp("next") end)
hs.hotkey.bind({ "alt", "shift" }, "tab", function() moveToAdjacentRecordedPositionForApp("previous") end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "R", recordMousePositionForApp)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "v", moveToRecordedPositionsAndClickForApp)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "C", clearRecordedPositionsForApp)
