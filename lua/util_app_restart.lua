local common = require("lua.common_functions")
local M = common.createStandardModule("应用重启工具")

function M.restartFrontmostApp()
    local frontmostApp = hs.application.frontmostApplication()
    if not frontmostApp then
        common.showError("无法获取前台应用")
        return false
    end

    local appName = frontmostApp:name()
    common.showInfo("正在重启: " .. appName)

    -- 终止应用
    frontmostApp:kill()

    -- 等待1秒后重新启动
    hs.timer.doAfter(1, function()
        hs.application.launchOrFocus(appName)
        common.showSuccess("已重启: " .. appName)
    end)

    return true
end

function M.checkDeps()
    return common.checkModule("hs.application") and
        common.checkModule("hs.hotkey") and
        common.checkModule("hs.timer")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "shift" }, "Q", M.restartFrontmostApp, "重启前台应用")
    common.showInfo("应用重启工具热键已设置")
end

if M.config.enabled then
    M:init()
end

return M
