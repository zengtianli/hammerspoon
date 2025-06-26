local common = require("lua.common_functions")
local M = common.createAppModule("微信工具", "WeChat")

function M.launchWechat()
    -- 直接运行 wechat_launch.sh 脚本，它会处理所有的逻辑
    common.scripts.execute("wechat_launch.sh")
    return true
end

function M.checkDeps()
    return common.checkModule("hs.hotkey") and
        common.checkModule("hs.task")
end

function M.setupHotkeys()
    M:addHotkey({ "ctrl", "alt" }, "w", M.launchWechat, "启动微信")
end

if M.config.enabled then
    M:init()
end

return M
