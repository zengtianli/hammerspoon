-- Table to hold snippet trigger and corresponding expansions
local snippets = {
	["!hw"] = "hello world",
	-- Add more snippets here
	-- ["trigger"] = "expansion text",
}

-- Function to check if the last characters typed match any snippet trigger
local function checkForSnippet()
	local focusedElement = hs.uielement.focusedElement()
	if not focusedElement then return false end

	local currentValue = focusedElement:selectedText() or focusedElement:attributeValue("AXValue") or ""
	if currentValue == "" then return false end

	for trigger, expansion in pairs(snippets) do
		if currentValue:sub(- #trigger) == trigger then
			return trigger, expansion
		end
	end
	return false
end

-- Function to replace a trigger with its corresponding snippet
local function replaceSnippet(trigger, expansion)
	local deleteKeystrokes = string.rep(hs.eventtap.keyStroke({}, "delete"), #trigger)
	hs.timer.usleep(200000)   -- Pause briefly to ensure all deletes are registered
	hs.eventtap.keyStrokes(expansion)
end

-- Eventtap to check each keystroke for potential snippet triggers
local snippetWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(ev)
	local trigger, expansion = checkForSnippet()
	if trigger then
		-- Prevent the event from propagating further
		replaceSnippet(trigger, expansion)
		return true     -- indicates that you have handled the event
	end
	return false
end):start()
