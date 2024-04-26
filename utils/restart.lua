-- Restart the frontmost application by pressing Shift+Cmd+Q
hs.hotkey.bind({"cmd", "shift"}, "Q", function()
  local frontmostApp = hs.application.frontmostApplication()
  local appName = frontmostApp:name()
-- show a notification of app name
  frontmostApp:kill()
  -- Wait for the application to quit
  hs.timer.doAfter(1, function()
    hs.application.launchOrFocus(appName)
  end)
end)

