-- lua_comb 统一初始化文件
print("🚀 开始加载 lua_comb 模块...")

-- 加载工具库
local utils = require("lua_comb.common_utils")
print("✅ 工具库已加载")

-- 加载并初始化各个模块
local modules = {}

-- 音乐控制
modules.music = require("lua_comb.music_controls")
if modules.music.config.enabled then
    modules.music:init()
end

-- 应用重启
modules.app_restart = require("lua_comb.app_restart")
if modules.app_restart.config.enabled then
    modules.app_restart:init()
end

-- 微信启动
modules.wechat = require("lua_comb.wechat_launcher")
if modules.wechat.config.enabled then
    modules.wechat:init()
end

-- 系统快捷键
modules.system = require("lua_comb.system_shortcuts")
modules.system.init()

-- 宏系统（依次加载）
modules.macro_player = require("lua_comb.macro_player")
modules.macro_controls = require("lua_comb.macro_controls")
modules.macro_hotkeys = require("lua_comb.macro_hotkeys")
modules.macro_hotkeys.bind_macro_hotkeys()

-- 应用控制
modules.app_controls = require("lua_comb.app_controls")

-- 文件压缩
modules.compress_controls = require("lua_comb.compress_controls")

-- 剪贴板工具
modules.clipboard_utils = require("lua_comb.clipboard_utils")
modules.clipboard_hotkeys = require("lua_comb.clipboard_hotkeys")
modules.clipboard_hotkeys.init()

-- 脚本运行器
modules.script_runner = require("lua_comb.script_runner")

-- 统一快捷键管理
modules.hotkeys_manager = require("lua_comb.hotkeys_manager")
local total_hotkeys = modules.hotkeys_manager.init()

-- 显示加载完成信息
print("✅ lua_comb 所有模块已加载完成")
utils.show_success_notification("Hammerspoon", "配置已重新加载，共注册 " .. total_hotkeys .. " 个快捷键")

-- 导出模块
local M = {
    utils = utils,
    modules = modules,
    show_help = modules.hotkeys_manager.show_help
}

-- 绑定帮助快捷键
hs.hotkey.bind({ "cmd", "ctrl", "alt", "shift" }, "h", "显示快捷键帮助", M.show_help)

return M
