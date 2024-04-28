local actionQueue = {}
function runNextAction()
	if #actionQueue > 0 then
		local nextAction = table.remove(actionQueue, 1)
		nextAction()
	end
end

function sendToApp()
	table.insert(actionQueue,
		function()
			hs.eventtap.keyStroke({ "cmd", "ctrl", "shift" }, "x"); hs.timer.doAfter(0.5, runNextAction)
		end)
	table.insert(actionQueue, function()
		hs.eventtap.keyStroke({ "cmd" }, "V"); hs.timer.doAfter(0.5, runNextAction)
	end)
	table.insert(actionQueue, function()
		hs.eventtap.keyStroke({}, "return"); hs.timer.doAfter(0.5, runNextAction)
	end)
	table.insert(actionQueue, function()
		hs.eventtap.keyStroke({ "cmd" }, "tab"); hs.timer.doAfter(0.5, runNextAction)
	end)
	table.insert(actionQueue, function()
		hs.eventtap.keyStroke({}, "return"); hs.timer.doAfter(1, runNextAction)
	end)
	runNextAction()
end

function quickNoteDialog()
	local ok, userInput = hs.osascript.applescript([[
        set userInput to text returned of (display dialog "Quick Note:" default answer linefeed & linefeed & linefeed)
        return userInput
    ]])
	if ok then
		hs.pasteboard.setContents(userInput)
		hs.alert.show("Text added to clipboard!")
		sendToApp()
	end
end

local quickNoteHotkeyEnabled = false
local quickNoteHotkey = hs.hotkey.new({ "cmd", "alt" }, "N", quickNoteDialog)
function toggleHotkey()
	if quickNoteHotkeyEnabled then
		quickNoteHotkey:disable()
		quickNoteHotkeyEnabled = false
		hs.alert.show("Quick Note Hotkey Disabled")
	else
		quickNoteHotkey:enable()
		quickNoteHotkeyEnabled = true
		hs.alert.show("Quick Note Hotkey Enabled")
	end
end

-- bind to hotkey to toggleHotkey is cmd shift alt ctrl N
hs.hotkey.bind({ "cmd", "shift", "alt", "ctrl" }, "N", toggleHotkey)
