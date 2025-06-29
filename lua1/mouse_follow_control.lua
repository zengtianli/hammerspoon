local utils = require("lua1.common_utils")

local M = {}

-- 切换鼠标跟随状态
function M.toggle_mouse_follow()
    local script_path = hs.configdir .. "/scripts/mouse_follow_toggle.sh"

    -- 检查脚本是否存在
    local file = io.open(script_path, "r")
    if not file then
        utils.show_error_notification("鼠标跟随", "脚本文件不存在: " .. script_path)
        return
    end
    file:close()

    -- 确保脚本可执行
    utils.make_executable(script_path)

    -- 执行脚本
    local output, status = hs.execute(script_path, true)

    if status then
        utils.log("mouse_follow_control", "鼠标跟随切换成功")
    else
        utils.show_error_notification("鼠标跟随", "脚本执行失败")
        utils.log("mouse_follow_control", "鼠标跟随切换失败: " .. tostring(output))
    end
end

return M
