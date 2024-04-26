-- Define the input source IDs
local us_keyboard = "com.apple.keylayout.US"
local sogou_pinyin = "com.sogou.inputmethod.sogou.pinyin"

-- Function to switch input method
local function switch_input_method()
  local current_input = hs.keycodes.currentSourceID()
  
  if current_input == us_keyboard then
    hs.keycodes.currentSourceID(sogou_pinyin)
  elseif current_input == sogou_pinyin then
    hs.keycodes.currentSourceID(us_keyboard)
  end
  -- Show the current input source
  hs.alert.show(hs.keycodes.currentSourceID())
end

-- Check if the current window belongs to PyCharm
local function isPyCharmActive()
  local frontmostApp = hs.application.frontmostApplication()
  return frontmostApp and frontmostApp:bundleID() == 'com.jetbrains.pycharm'
end

local hotkey = hs.hotkey.new({"ctrl"}, "space", function()
  if not isPyCharmActive() then
    switch_input_method()
  end
end)

-- Monitor applications to enable/disable the hotkey appropriately
local watcher = hs.application.watcher.new(function(name, event, app)
    if name == "PyCharm" then
        if event == hs.application.watcher.activated then
            -- When PyCharm is focused, disable the hotkey
            hotkey:disable()
        elseif event == hs.application.watcher.deactivated then
            -- When PyCharm is not focused, re-enable the hotkey
            hotkey:enable()
        end
    end
end)

watcher:start()

-- Enable the hotkey initially
hotkey:enable()

