local common = require("lua.common_functions")
local M = common.createAppModule("宏控制", "MacroControls")

function M.startRecord()
    -- show info
    common.scripts.execute("macro_record.sh")
end

function M.recordPosition()
    common.scripts.execute("macro_record.sh")
end

function M.stopRecord()
    common.scripts.execute("macro_stop.sh")
end

function M.playMacro()
    common.scripts.execute("macro_play.sh")
end

function M.checkDeps()
    return common.checkModule("hs.hotkey") and
        common.checkModule("hs.task")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "shift" }, "r", M.recordPosition, "录制位置/开始录制")
    M:addHotkey({ "cmd", "shift" }, "t", M.stopRecord, "停止录制")
    M:addHotkey({ "cmd", "shift" }, "p", M.playMacro, "播放宏")
end

if M.config.enabled then
    M:init()
end

return M
