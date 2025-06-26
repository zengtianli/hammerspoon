-- 应用重启功能
-- 快捷键: Cmd+Shift+Q

local common = require("lua.common_functions")
local M = common.createAppModule("应用重启", "AppRestart")

function M.restartApp()
    common.scripts.execute("app_restart.sh")
end

function M.checkDeps()
    return common.checkModule("hs.hotkey") and
        common.checkModule("hs.task")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "shift" }, "q", M.restartApp, "重启当前应用")
end

if M.config.enabled then
    M:init()
end

return M
