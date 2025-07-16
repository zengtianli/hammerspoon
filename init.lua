-- Hammerspoon 配置入口文件
-- 重构版本 - 模块化结构

print("🚀 开始加载 Hammerspoon 配置...")

-- 加载用户设置
local config = require("config.settings")
print("✅ 加载用户设置完成")

-- 加载核心模块
local utils = require("modules.core.utils")
local hotkeys = require("modules.core.hotkeys")

-- 初始化快捷键管理器
local total_hotkeys = hotkeys.init()

-- 绑定全局帮助快捷键
hs.hotkey.bind({ "cmd", "ctrl", "alt", "shift" }, "h", "显示快捷键帮助", hotkeys.show_help)

-- 显示加载完成信息
print("✅ Hammerspoon 配置加载完成")
utils.show_success_notification("Hammerspoon", "配置已重新加载，共注册 " .. total_hotkeys .. " 个快捷键")

-- 导出模块
return {
    utils = utils,
    hotkeys = hotkeys,
    show_help = hotkeys.show_help,
    config = config
}
