-- 高性能宏播放器模块 (Shell 脚本驱动版本)
local utils = require("modules.core.utils")

local M = {}

-- 播放宏 (通过调用外部shell脚本)
function M.play_macro(macro_name)
    if not macro_name or macro_name == "" then
        utils.show_error_notification("宏播放", "宏名称不能为空")
        return false
    end

    utils.log("MacroPlayer", "调用脚本播放宏: " .. macro_name)
    utils.scripts.execute("macro", "macro_play.sh", function(exit_code, stdout, stderr)
        if exit_code ~= 0 then
            utils.log("MacroPlayer", "播放脚本执行失败，退出码: " .. tostring(exit_code))
            utils.debug_print("Macro Play Error", stderr)
        else
            utils.log("MacroPlayer", "播放脚本成功完成")
        end
    end, macro_name)

    return true
end

function M.init()
    print("⚡ 宏播放器模块已加载 (Shell 脚本模式)")
    return true
end

return M
