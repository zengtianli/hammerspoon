local isDetectorActive = false
function keyDetectorquicknote(event)
	local flags = event:getFlags()
	local key = event:getCharacters(true)
	local keyCode = event:getKeyCode()
	local keySymbolicName = hs.keycodes.map[keyCode]
	local ok, userInput = hs.osascript.applescript([[
        set userInput to text returned of (display dialog "Quick Note:" default answer "")
        return userInput
    ]])
	if keySymbolicName == "return" then
		key = "<return>"
		hs.pasteboard.setContents(userInput)
	end
	hs.alert.show("You pressed: " .. key)
end

keyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, keyDetectorquicknote)
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

hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "D", toggleKeyDetector)
