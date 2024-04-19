-- Define a table of app hotkeys configurations
local ScriptsDir = "/Users/tianli/.hammerspoon/scripts"
local appBindings = {
    -- { mods = {"cmd", "ctrl", "shift"}, key = "A", app = "Arc" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "D", app = "DingTalk" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "F", app = "Finder" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "K", app = "Keyboard Maestro" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "o", app = "Microsoft Word" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "i", app = "MindNode" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "m", app = "Music" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "n", app = "Notes" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "u", app = "AutoCAD 2024" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "P", app = "Parallels Desktop" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "Q", app = "QSpace Pro" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = ".", app = "Visual Studio Code" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "W", app = "Warp" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "x", app = "WeChat" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "p", app = "PicGo" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "/", app = "Obsidian" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "G", app = "Google Chrome" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "M", app = "Mail" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "O", app = "Microsoft Outlook" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "S", app = "Slack" },
    -- { mods = {"cmd", "ctrl", "shift"}, key = "T", app = "Terminal" },
		{ mods = {"cmd", "ctrl", "shift"}, key = "t", app = ScriptsDir .. "/warp.sh", isExecute = true },
    { mods = {"cmd", "ctrl", "alt", "shift"}, key = "o", app =ScriptsDir .. "/obs.sh", isExecute = true },
    { mods = {"cmd", "option"}, key = ",", app = "System Settings" },
    { mods = {"cmd", "ctrl", "shift"}, key = "l", app = "ClashX Pro", mode = "rule" },
    { mods = {"cmd", "ctrl", "shift"}, key = "g", app = "ClashX Pro", mode = "global" }
}
-- Function to create and manage hotkeys
local appHotkeys = {}
for _, binding in ipairs(appBindings) do
    local hotkeyFunction
    if binding.isExecute then
        hotkeyFunction = function() hs.execute(binding.app, true) end
    elseif binding.mode then
        hotkeyFunction = function()
            hs.application.open(binding.app)
            hs.alert.show("ClashX Pro " .. binding.mode .. " mode")
            hs.timer.doAfter(0.5, function()
                hs.eventtap.keyStroke({"cmd", "ctrl", "alt", "shift"}, binding.mode == "rule" and "1" or "2")
            end)
        end
    else
        hotkeyFunction = function() hs.application.open(binding.app) end
    end
    table.insert(appHotkeys, hs.hotkey.new(binding.mods, binding.key, hotkeyFunction))
end
-- Function to toggle the hotkeys
local hotkeysEnabled = false
function toggleAppHotkeys()
    if hotkeysEnabled then
        for _, hotkey in ipairs(appHotkeys) do
            hotkey:disable()
        end
        hotkeysEnabled = false
    else
        for _, hotkey in ipairs(appHotkeys) do
            hotkey:enable()
        end
        hotkeysEnabled = true
    end
end
-- Default is appHotkeys enabled
toggleAppHotkeys()
-- Bind a hotkey to toggle all app hotkeys
hs.hotkey.bind({"cmd", "ctrl", "shift", "alt"}, "t", toggleAppHotkeys)
