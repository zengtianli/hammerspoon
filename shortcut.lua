hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "A", function() hs.application.open("Arc") end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "D", function() hs.application.open("DingTalk") end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "F", function() hs.application.open("Finder") end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "K", function() hs.application.open("Keyboard Maestro") end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "o", function() hs.application.open("Microsoft Word") end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "i", function() hs.application.open("MindNode") end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "m", function() hs.application.open("Music") end) -- U for mUsic
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "n", function() hs.application.open("Notes") end) -- T for noTes
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "P", function() hs.application.open("Parallels Desktop") end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "Q", function() hs.application.open("QSpace Pro") end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, ".", function() hs.application.open("Visual Studio Code") end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "W", function() hs.application.open("Warp") end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "x", function() hs.application.open("WeChat") end)
hs.hotkey.bind({ "cmd", "option" }, ",", function() hs.application.open("System Settings") end) -- S for System

hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "g", function()
	hs.application.open("ClashX Pro") -- Assuming "ClashX Pro" is the exact name of the app
	hs.timer.doAfter(0.5, function() -- Delay to give app time to focus
		hs.eventtap.keyStroke({ "cmd", "ctrl", "alt", "shift" }, "2")
	end)
end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "l", function()
	hs.application.open("ClashX Pro") -- Assuming "ClashX Pro" is the exact name of the app
	hs.timer.doAfter(0.5, function() -- Delay to give app time to focus
		hs.eventtap.keyStroke({ "cmd", "ctrl", "alt", "shift" }, "1")
	end)
end)
