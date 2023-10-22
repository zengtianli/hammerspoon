local weChatVimMode = hs.hotkey.modal.new()
local appWatcher = nil
local escapeWatcher = nil

local function activateVimMode()
	if hs.application.frontmostApplication():name() == "WeChat" then
		weChatVimMode:enter()
	else
		weChatVimMode:exit()
	end
end

-- Listen to Escape key
escapeWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
	local keyCode = event:getKeyCode()
	local appName = hs.application.frontmostApplication():name()

	if keyCode == hs.keycodes.map["escape"] and appName == "WeChat" then
		-- Your Vim mode activation code here.
		activateVimMode()
		return true     -- Consume the escape key event
	end

	return false
end)

escapeWatcher:start()

-- Show app name on switch
local function applicationChanged(appName, eventType)
	if eventType == hs.application.watcher.activated then
		hs.alert.show(appName)
	end
end

appWatcher = hs.application.watcher.new(applicationChanged)
appWatcher:start()

-- Normal mode bindings for WeChat Vim mode
weChatVimMode:bind({}, 'i', function()
	weChatVimMode:exit()
	-- Insert mode actions or other necessary actions go here
end)

-- etc...
