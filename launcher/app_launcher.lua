local appHotkeys = {
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "A", function() hs.application.open("Arc") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "D", function() hs.application.open("DingTalk") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "F", function() hs.application.open("Finder") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "K", function() hs.application.open("Keyboard Maestro") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "o", function() hs.application.open("Microsoft Word") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "i", function() hs.application.open("MindNode") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "m", function() hs.application.open("Music") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "n", function() hs.application.open("Notes") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "u", function() hs.application.open("AutoCAD 2024") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "P", function() hs.application.open("Parallels Desktop") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "Q", function() hs.application.open("QSpace Pro") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, ".", function() hs.application.open("Visual Studio Code") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "W", function() hs.application.open("Warp") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "x", function() hs.application.open("WeChat") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "p", function() hs.application.open("PicGo") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "/", function() hs.application.open("Obsidian") end),
	hs.hotkey.new({ "cmd", "ctrl", "alt", "shift" }, "o",
		function() hs.execute("/Users/tianli/.hammerspoon/scripts/obs.sh", true) end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "t",
		function() hs.execute("/Users/tianli/.hammerspoon/scripts/warp.sh", true) end),
	hs.hotkey.new({ "cmd", "option" }, ",", function() hs.application.open("System Settings") end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "l", function()
		hs.application.open("ClashX Pro")
		hs.alert.show("ClashX Pro rule mode")
		hs.timer.doAfter(0.5, function()
			hs.eventtap.keyStroke({ "cmd", "ctrl", "alt", "shift" }, "1")
		end)
	end),
	hs.hotkey.new({ "cmd", "ctrl", "shift" }, "g", function()
		hs.application.open("ClashX Pro")
		hs.alert.show("ClashX Pro global mode")
		hs.timer.doAfter(0.5, function()
			hs.eventtap.keyStroke({ "cmd", "ctrl", "alt", "shift" }, "2")
		end)
	end)
}

local hotkeysEnabled = false
function toggleAppHotkeys()
	if hotkeysEnabled then
		for _, hotkey in ipairs(appHotkeys) do
			hotkey:disable()
		end
		hotkeysEnabled = false
		-- hs.alert.show("App hotkeys disabled")
	else
		for _, hotkey in ipairs(appHotkeys) do
			hotkey:enable()
		end
		hotkeysEnabled = true
		-- hs.alert.show("App hotkeys enabled")
	end
end

-- default is appHotkeys enabled
toggleAppHotkeys()

hs.hotkey.bind({ "cmd", "ctrl", "shift", "alt" }, "t", toggleAppHotkeys)
