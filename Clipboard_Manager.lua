-- Clipboard Manager
local clipboardHistory = {}
-- Update clipboardHistory whenever the clipboard changes
hs.pasteboard.watcher.new(function(contents)
	-- Add the new content to the history
	table.insert(clipboardHistory, contents)
end):start()
function combineWithConfirmation()
	local choicesList = {}
	for _, item in ipairs(clipboardHistory) do
		table.insert(choicesList, { text = item })
	end
	hs.chooser.new(function(choice)
		if not choice then return end
		local combinedString = choice.text
		-- Ask for confirmation
		local shouldCombine = hs.dialog.blockAlert("Confirmation", "Do you want to combine the clipboard histories?", "Yes",
			"No")
		if shouldCombine == "Yes" then
			for _, item in ipairs(clipboardHistory) do
				combinedString = combinedString .. item
			end
			hs.pasteboard.setContents(combinedString)
			hs.alert.show("Combined Clipboard Set!")
		end
	end)
			:choices(choicesList)
			:show()
end

function clearClipboardHistory()
	clipboardHistory = {}
	hs.alert.show("Clipboard History Cleared!")
end

hs.hotkey.bind({ "cmd", "alt" }, "C", combineWithConfirmation)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "C", clearClipboardHistory)
