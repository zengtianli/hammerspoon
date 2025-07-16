-- 微信启动器模块
local utils = require("modules.core.utils")
local M = {}

function M.launchWechat()
    utils.scripts.execute("apps", "wechat_launch.sh")
    return true
end

function M.checkDeps()
    return utils.checkModule("hs.hotkey") and
        utils.checkModule("hs.task")
end

function M.setupHotkeys()
    utils.createSafeHotkey({ "ctrl", "alt" }, "w", M.launchWechat, "启动微信")
end

function M.init()
    if M.checkDeps() then
        M.setupHotkeys()
        print("📱 微信启动器模块已加载")
        return true
    end
    return false
end

return M
