-- 系统工具模块
local utils = require("modules.core.utils")

local M = {}

-- 打开系统设置
function M.openSystemSettings()
    -- 兼容不同 macOS 版本的设置应用名称
    local success = hs.application.launchOrFocus("System Settings")
    if not success then
        -- 兼容旧版本 macOS
        success = hs.application.launchOrFocus("System Preferences")
    end
end

-- 初始化函数
function M.init()
    hs.hotkey.bind({ "cmd", "alt" }, ",", "打开系统设置", M.openSystemSettings)
    print("🔧 系统工具模块已加载")
    return true
end

return M
