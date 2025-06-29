local utils = require("lua1.common_utils")

-- 鼠标跟随控制模块
local mouse_follow_control = {}

-- 配置
local config = {
    script_path = hs.configdir .. "/scripts/mouse_follow_toggle.sh"
}

-- 创建bash执行器
local bash_executor = utils.create_task_executor("/bin/bash")

-- 切换鼠标跟随功能
mouse_follow_control.toggle = function()
    local script_path = config.script_path

    -- 检查脚本文件是否存在
    if not utils.file_exists(script_path) then
        utils.show_error_notification("脚本不存在", "❌ 找不到 mouse_follow_toggle.sh")
        return
    end

    -- 确保脚本可执行
    utils.make_executable(script_path)

    hs.alert.show("🖱️ 切换鼠标跟随状态...")

    -- 执行脚本
    hs.task.new("/bin/bash", function(exit_code, stdout, stderr)
        if exit_code == 0 then
            -- 脚本执行成功
            if stdout and stdout ~= "" then
                hs.alert.show(stdout:gsub("\n", ""))
                utils.debug_print("鼠标跟随", stdout)
            else
                hs.alert.show("✅ 鼠标跟随状态已切换")
            end
        else
            -- 脚本执行失败
            utils.show_error_notification("鼠标跟随切换失败", "❌ 退出码: " .. exit_code)
            utils.debug_print("鼠标跟随错误", {
                stderr = stderr,
                stdout = stdout,
                exit_code = exit_code
            })
        end
    end, { script_path }):start()
end

-- 检查鼠标跟随状态
mouse_follow_control.get_status = function()
    local status_file = "/tmp/mouse_follow_status"
    return utils.file_exists(status_file)
end

-- 显示当前状态
mouse_follow_control.show_status = function()
    local is_enabled = mouse_follow_control.get_status()
    local status_text = is_enabled and "🟢 鼠标跟随：已启用" or "🔴 鼠标跟随：已禁用"
    hs.alert.show(status_text)
    return is_enabled
end

print("🖱️ Mouse Follow Control 模块已加载")
return mouse_follow_control
