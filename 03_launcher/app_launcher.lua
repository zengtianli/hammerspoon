-- Define a table of app hotkeys configurations
local ScriptsDir = "/Users/tianli/.hammerspoon/05_scripts"
local UserfulDir = "/Users/tianli/useful_scripts"
local appBindings = {
    { mods = {"cmd", "ctrl", "shift"}, key = "t", app = ScriptsDir .. "/warp.sh", isExecute = true },
    { mods = {"cmd", "ctrl", "shift"}, key = "f", app = UserfulDir .. "/toggle_fn_keys.sh", isExecute = true },
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
        hotkeyFunction = function()
            hs.execute(binding.app, true)
            hs.alert.show("Executed: " .. binding.app)
        end
    elseif binding.mode then
        hotkeyFunction = function()
            hs.application.open(binding.app)
            hs.alert.show("ClashX Pro " .. binding.mode .. " mode")
            hs.timer.doAfter(0.5, function()
                hs.eventtap.keyStroke({"cmd", "ctrl", "alt", "shift"}, binding.mode == "rule" and "1" or "2")
            end)
        end
    else
        hotkeyFunction = function()
            hs.application.open(binding.app)
            hs.alert.show("Opened: " .. binding.app)
        end
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
        hs.alert.show("App hotkeys disabled")
    else
        for _, hotkey in ipairs(appHotkeys) do
            hotkey:enable()
        end
        hotkeysEnabled = true
        hs.alert.show("App hotkeys enabled")
    end
end

-- Default is appHotkeys enabled
toggleAppHotkeys()

-- Bind a hotkey to toggle all app hotkeys
hs.hotkey.bind({"cmd", "ctrl", "shift", "alt"}, "t", function()
    toggleAppHotkeys()
    hs.alert.show("Toggled app hotkeys")
end)

