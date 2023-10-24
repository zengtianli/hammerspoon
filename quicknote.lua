-- Queue to hold the functions to execute
local actionQueue = {}
-- Function to run the next action in the queue
function runNextAction()
	if #actionQueue > 0 then
		local nextAction = table.remove(actionQueue, 1)
		nextAction()
	end
end

-- Pushing the actions to the queue
function sendToApp()
	-- Add the actions to the action queue
	table.insert(actionQueue,
		function()
			hs.eventtap.keyStroke({ "cmd", "ctrl", "shift" }, "x"); hs.timer.doAfter(0.5, runNextAction)
		end) -- for wechat app
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
	-- Start the queue by running the first action
	runNextAction()
end

function quickNoteDialog()
	local ok, userInput = hs.osascript.applescript([[
        set userInput to text returned of (display dialog "Quick Note:" default answer "")
        return userInput
    ]])
	if ok then
		hs.pasteboard.setContents(userInput)
		hs.alert.show("Text added to clipboard!")
		sendToApp()
	end
end

hs.hotkey.bind({ "cmd", "alt" }, "N", quickNoteDialog)
