-- 应用重启模块
local utils = require("modules.core.utils")
local M = {}

function M.restartApp()
    utils.scripts.execute("apps", "app_restart.sh")
end

function M.checkDeps()
    return utils.checkModule("hs.hotkey") and
        utils.checkModule("hs.task")
end

function M.setupHotkeys()
    utils.createSafeHotkey({ "cmd", "shift" }, "q", M.restartApp, "重启当前应用")
end

function M.init()
    if M.checkDeps() then
        M.setupHotkeys()
        print("♻️ 应用重启模块已加载")
        return true
    end
    return false
end

return M
