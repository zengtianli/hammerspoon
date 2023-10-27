local shellScripts = {
	toggleYabai = "/Users/tianli/.config/yabai/toggle-yabai.sh",
	closeWindow = "yabai -m window --close",
	toggleFullscreen = "yabai -m window --toggle zoom-fullscreen",
	toggleSplit = "yabai -m window --toggle split ,",
	toggleFloatingTiling = "~/.config/yabai/toggle-window-floating-tiling.sh",
	swapNextOrFirst = "yabai -m window --swap next || yabai -m window --swap first",
	focusNextOrFirst = "yabai -m window --focus next || yabai -m window --focus first",
}
function runShellCommand(command, alertMessage)
	local envPath = "/opt/homebrew/bin:" .. os.getenv("PATH")
	local fullCommand = "export PATH=" .. envPath .. " && /bin/bash -c '" .. command .. "'"
	local success, output, exitCode = hs.execute(fullCommand)
	if output == nil or output == "" then output = "nil" end
	if success then
		exitCode = "success"
	else
		exitCode = tostring(exitCode)
	end
	hs.alert.show("Alert: " .. alertMessage .. ", Output: " .. output .. "\nExit code: " .. exitCode)
end

hs.hotkey.bind({ "cmd", "shift" }, "y", function() runShellCommand(shellScripts.toggleYabai, "toggleYabai") end)
hs.hotkey.bind({ "cmd", "shift" }, "w", function() runShellCommand(shellScripts.closeWindow, "closeWindow") end)
hs.hotkey.bind({ "cmd", "shift" }, "l",
	function() runShellCommand(shellScripts.toggleFloatingTiling, "toggleFloatingTiling") end)
hs.hotkey.bind({ "cmd", "shift" }, "j", function() runShellCommand(shellScripts.swapNextOrFirst, "swapNextOrFirst") end)
hs.hotkey.bind({ "cmd", "ctrl" }, "f", function() runShellCommand(shellScripts.toggleFullscreen, "toggleFullscreen") end)
hs.hotkey.bind({ "cmd" }, "j", function() runShellCommand(shellScripts.focusNextOrFirst, "focusNextOrFirst") end)
-- split
hs.hotkey.bind({ "cmd", "shift" }, "s", function() runShellCommand(shellScripts.toggleSplit, "toggleSplit") end)
