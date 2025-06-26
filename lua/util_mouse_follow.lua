local common = require("lua.common_functions")
local M = common.createAppModule("鼠标跟随工具", "MouseFollow")

function M.toggleMouseFollow()
    -- 直接运行 mouse_follow_toggle.sh 脚本
    common.showInfo("正在切换鼠标跟随...")

    -- 先检查脚本文件是否存在
    local scriptPath = common.scripts.getPath("mouse_follow_toggle.sh")
    if not common.fileExists(scriptPath) then
        common.showError("脚本文件不存在: " .. scriptPath)
        return false
    end

    -- 添加调试回调来查看脚本执行结果
    local callback = function(exitCode, stdOut, stdErr)
        print("🐛 脚本执行完成 - 退出码:", exitCode)
        print("🐛 标准输出:", stdOut or "无")
        print("🐛 标准错误:", stdErr or "无")

        if exitCode == 0 then
            local output = stdOut or ""
            if output:find("已启用") then
                common.showInfo("✅ 鼠标跟随已启用")
            elseif output:find("已禁用") then
                common.showInfo("❌ 鼠标跟随已禁用")
            else
                common.showInfo("🔄 鼠标跟随状态已切换")
            end
        else
            common.showError("脚本执行失败 (退出码: " .. exitCode .. ")")
            if stdErr and stdErr ~= "" then
                print("❌ 错误详情:", stdErr)
            end
        end
    end

    -- 执行脚本
    local task = common.scripts.execute("mouse_follow_toggle.sh", callback)
    if task then
        common.showInfo("🚀 脚本已启动执行")
        return true
    else
        common.showError("❌ 脚本启动失败")
        return false
    end
end

function M.checkDeps()
    return common.checkModule("hs.hotkey") and
        common.checkModule("hs.task")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "ctrl" }, "F", M.toggleMouseFollow, "切换鼠标跟随")
end

if M.config.enabled then
    M:init()
end

return M
