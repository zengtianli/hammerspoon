local common = require("lua.common_functions")
local M = common.createAppModule("鼠标跟随", "MouseFollow")

function M.toggleMouseFollow()
    local scriptPath = common.scripts.getPath("mouse_follow_toggle.sh")
    if not common.fileExists(scriptPath) then
        common.showError("脚本文件不存在")
        return false
    end

    local callback = function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            local output = stdOut or ""
            if output:find("已启用") then
                common.showInfo("鼠标跟随已启用")
            elseif output:find("已禁用") then
                common.showInfo("鼠标跟随已禁用")
            else
                common.showInfo("鼠标跟随状态已切换")
            end
        else
            common.showError("脚本执行失败")
        end
    end

    return common.scripts.execute("mouse_follow_toggle.sh", callback)
end

function M.checkDeps()
    return common.checkModule("hs.hotkey") and
        common.checkModule("hs.task")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "ctrl", "alt", "shift" }, "f", M.toggleMouseFollow, "切换鼠标跟随")
end

if M.config.enabled then
    M:init()
end

return M
