-- 系统快捷键模块
local utils = require("lua_comb.common_utils")

local M = {}

-- 打开系统设置
function M.openSystemSettings()
    -- 兼容不同 macOS 版本的设置应用名称
    local success = hs.application.launchOrFocus("System Settings")
    if not success then
        -- 兼容旧版本 macOS
        success = hs.application.launchOrFocus("System Preferences")
    end
    if success then
        hs.alert.show("已打开系统设置")
    else
        hs.alert.show("无法打开系统设置")
    end
end

-- 初始化快捷键
function M.init()
    hs.hotkey.bind({ "cmd", "alt" }, ",", "打开系统设置", M.openSystemSettings)
    utils.log("SystemShortcuts", "系统快捷键已初始化")
end

return M
