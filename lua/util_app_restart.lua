local common = require("lua.common_functions")
local M = common.createStandardModule("应用重启工具")
M.config.restartDelay = 1.0

function M.restartFrontmostApp()
    local frontmostApp = hs.application.frontmostApplication()
    if not frontmostApp then
        common.showError("无法获取前台应用"); return false
    end
    local appName = frontmostApp:name()
    if not common.validateApp(appName) then return false end
    common.showProcessing("正在重启: " .. appName)
    if not frontmostApp:kill() then
        common.showError("无法终止: " .. appName); return false
    end
    hs.timer.doAfter(M.config.restartDelay, function()
        local ok = hs.application.launchOrFocus(appName); common[ok and "showSuccess" or "showError"](ok and
            "已重启: " .. appName or "重启失败: " .. appName)
    end)
    return true
end

function M.safeRestartApp(appName)
    if not common.validateApp(appName) then return false end
    local app = hs.application.get(appName)
    if not app then
        common.showWarning("应用未运行: " .. appName); return false
    end
    common.showProcessing("正在安全重启: " .. appName); app:terminate()
    hs.timer.doAfter(M.config.restartDelay * 2, function()
        local stillRunning = hs.application.get(appName)
        if stillRunning then
            stillRunning:kill(); hs.timer.doAfter(0.5, function()
                hs.application.launchOrFocus(appName); common.showSuccess("已强制重启: " .. appName)
            end)
        else
            hs.application.launchOrFocus(appName); common.showSuccess("已重启: " .. appName)
        end
    end)
    return true
end

function M.checkDeps()
    return common.checkModule("hs.application") and common.checkModule("hs.hotkey") and common.checkModule("hs.timer")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "shift" }, "Q", M.restartFrontmostApp, "重启前台应用"); common.showInfo("应用重启工具热键已设置")
end

if M.config.enabled then M:init() end
return M
