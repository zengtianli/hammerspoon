-- 微信启动模块
local utils = require("lua_comb.common_utils")
local M = utils.createAppModule("微信工具", "WeChat")

function M.launchWechat()
    utils.scripts.execute("wechat_launch.sh")
    return true
end

function M.checkDeps()
    return utils.checkModule("hs.hotkey") and
        utils.checkModule("hs.task")
end

function M.setupHotkeys()
    M:addHotkey({ "ctrl", "alt" }, "w", M.launchWechat, "启动微信")
end

return M
