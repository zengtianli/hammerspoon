-- Key Detector
local isDetectorActive = false

function keyDetector(event)
	local flags = event:getFlags()
	local key = event:getCharacters(true)
	local keyCode = event:getKeyCode()
	local isCmd = flags['cmd']
	local keySymbolicName = hs.keycodes.map[keyCode]

	if keySymbolicName == "return" then
		key = "<return>"
	elseif keySymbolicName == "delete" then
		key = "<delete>"
	elseif keySymbolicName == "tab" then
		key = "<tab>"
	elseif keySymbolicName == "space" then
		key = "<space>"
	elseif keySymbolicName == "escape" then
		key = "<escape>"
	elseif keySymbolicName == "up" then
		key = "<up>"
	elseif keySymbolicName == "down" then
		key = "<down>"
	elseif keySymbolicName == "left" then
		key = "<left>"
	elseif keySymbolicName == "right" then
		key = "<right>"
	end

	if isCmd then
		hs.alert.show("You pressed: Cmd + " .. key)
	else
		hs.alert.show("You pressed: " .. key)
	end
end

-- Watch for keyDown events
keyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, keyDetector)

function toggleKeyDetector()
	if isDetectorActive then
		keyTap:stop()
		isDetectorActive = false
		hs.alert.show("Key Detector Deactivated")
	else
		keyTap:start()
		isDetectorActive = true
		hs.alert.show("Key Detector Activated")
	end
end

-- Bind to Cmd + Alt + D (You can change this combination as per your liking)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "D", toggleKeyDetector)
