local yabaiScriptsDir = "/Users/tianli/.config/yabai"

local shellScripts = {
	toggleYabai = yabaiScriptsDir .. "/toggle-yabai.sh",
	increase_window = yabaiScriptsDir .. "/increase_window.sh",
	decrease_window = yabaiScriptsDir .. "/decrease_window.sh",
	toggleFloatingTiling = yabaiScriptsDir .. "/toggle-display-center-floating-tiling3.sh",
	displayNextOrFirst = yabaiScriptsDir .. "/swap_display.sh",
	closeWindow = "yabai -m window --close",
	restartyabai = "yabai --restart-service; sleep 2; yabai -m rule --apply",
	toggleFullscreen = "yabai -m window --toggle zoom-fullscreen",
	toggleSplit = "yabai -m window --toggle split",
	swapNextOrFirst = "yabai -m window --swap next || yabai -m window --swap first",
	focusNextOrFirst = "yabai -m window --focus next || yabai -m window --focus first",
}

function runShellCommand(command)
	local envPath = "/opt/homebrew/bin:" .. os.getenv("PATH")
	local fullCommand = "export PATH=" .. envPath .. " && /bin/bash -c '" .. command .. "'"
	local success, output, exitCode = hs.execute(fullCommand)
	output = output or "nil"  -- Provides a default value if output is nil or empty
	return success, output, exitCode  -- Returning the values for possible debugging use
end

local hotkeyConfig = {
    { mods = { "cmd", "shift" }, key = "y", script = shellScripts.toggleYabai },
    { mods = { "cmd", "shift" }, key = "r", script = shellScripts.restartyabai },
    { mods = { "cmd", "shift" }, key = "=", script = shellScripts.increase_window },
    { mods = { "cmd", "shift" }, key = "-", script = shellScripts.decrease_window },
    { mods = { "cmd", "shift" }, key = "w", script = shellScripts.closeWindow },
    { mods = { "cmd", "shift" }, key = "l", script = shellScripts.toggleFloatingTiling },
    { mods = { "cmd", "shift" }, key = "j", script = shellScripts.swapNextOrFirst },
    { mods = { "cmd", "shift" }, key = "k", script = shellScripts.displayNextOrFirst },
    { mods = { "cmd", "alt" }, key = "f", script = shellScripts.toggleFullscreen },
    { mods = { "cmd", "alt" }, key = "j", script = shellScripts.focusNextOrFirst },
    { mods = { "cmd", "shift" }, key = "s", script = shellScripts.toggleSplit }
}

-- Function to create hotkeys from the configuration
local shellHotkeys = {}
for _, config in ipairs(hotkeyConfig) do
    table.insert(shellHotkeys, hs.hotkey.new(config.mods, config.key, function()
        runShellCommand(config.script)
    end))
end

local shellHotkeysEnabled = false
function toggleYabaiHotkeys()
	if shellHotkeysEnabled then
		for _, hotkey in ipairs(shellHotkeys) do
			hotkey:disable()
		end
		shellHotkeysEnabled = false
	else
		for _, hotkey in ipairs(shellHotkeys) do
			hotkey:enable()
		end
		shellHotkeysEnabled = true
	end
end
toggleYabaiHotkeys()
hs.hotkey.bind({ "cmd", "ctrl", "shift", "alt" }, "y", toggleYabaiHotkeys)

