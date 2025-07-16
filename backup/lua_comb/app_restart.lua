-- 应用重启模块
local utils = require("lua_comb.common_utils")
local M = utils.createAppModule("应用重启", "AppRestart")

function M.restartApp()
    utils.scripts.execute("app_restart.sh")
end

function M.checkDeps()
    return utils.checkModule("hs.hotkey") and
        utils.checkModule("hs.task")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "shift" }, "q", M.restartApp, "重启当前应用")
end

return M
