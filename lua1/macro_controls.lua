local utils = require("lua1.common_utils")

-- 宏控制模块
local macro_controls = {}

-- 宏播放控制 (播放demo宏)
macro_controls.macro_play = function()
    local script_path = os.getenv("HOME") .. "/.config/hammerspoon/scripts/macro_play.sh"
    local macro_name = "demo"

    -- 检查脚本文件是否存在
    if not hs.fs.attributes(script_path, "mode") then
        utils.show_error_notification("宏播放", "脚本文件不存在: " .. script_path)
        return
    end

    utils.show_success_notification("宏播放", "正在播放宏: " .. macro_name)
    utils.debug_print("宏播放", "脚本路径: " .. script_path)
    utils.debug_print("宏播放", "开始播放宏: " .. macro_name)

    hs.task.new("/bin/bash", function(exit_code, stdout, stderr)
        utils.debug_print("宏播放", "退出代码: " .. tostring(exit_code))
        if stdout and stdout ~= "" then
            utils.debug_print("宏播放", "输出: " .. stdout)
        end
        if stderr and stderr ~= "" then
            utils.debug_print("宏播放", "错误: " .. stderr)
        end

        if exit_code == 0 then
            utils.show_success_notification("宏播放", "宏播放完成: " .. macro_name)
        else
            utils.show_error_notification("宏播放", "播放失败(代码:" .. tostring(exit_code) .. "): " .. (stderr or "未知错误"))
        end
    end, { script_path, macro_name }):start()
end

print("🎬 Macro Controls 模块已加载")
return macro_controls
