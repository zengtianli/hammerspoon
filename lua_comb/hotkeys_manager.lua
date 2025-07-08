-- 统一快捷键管理模块
local utils = require("lua_comb.common_utils")
local app_controls = require("lua_comb.app_controls")
local script_runner = require("lua_comb.script_runner")
local compress_controls = require("lua_comb.compress_controls")
local macro_controls = require("lua_comb.macro_controls")

local M = {}

-- 应用控制快捷键
local app_hotkeys = {
    { { "cmd", "ctrl", "shift" }, "t", "Ghostty在此处打开", app_controls.open_ghostty_here },
    { { "cmd", "ctrl", "shift" }, "w", "Cursor在此处打开", app_controls.open_cursor_here },
    { { "cmd", "ctrl", "shift" }, "i", "Nvim在Ghostty中打开文件", app_controls.open_file_in_nvim_ghostty },
    { { "cmd", "shift" }, "n", "创建新文件夹", app_controls.create_folder },
}

-- 脚本运行快捷键
local script_hotkeys = {
    { { "cmd", "ctrl", "shift" }, "s", "运行选中脚本", script_runner.run_single },
    { { "cmd", "ctrl", "shift" }, "r", "并行运行脚本", script_runner.run_parallel },
}

-- 文件压缩快捷键
local compression_hotkeys = {
    { { "alt", "ctrl" }, "c", "压缩选中文件", compress_controls.compress_selection },
}

-- 宏录制快捷键
local macro_recording_hotkeys = {
    { { "cmd", "ctrl", "shift" }, "[", "录制/标记宏点", macro_controls.record_step },
    { { "cmd", "ctrl", "shift" }, "]", "停止宏录制", macro_controls.stop_recording },
}


-- 初始化所有快捷键
function M.init()
    local total_count = 0

    -- 注册应用控制快捷键
    total_count = total_count + utils.register_hotkeys(app_hotkeys)

    -- 注册脚本运行快捷键
    total_count = total_count + utils.register_hotkeys(script_hotkeys)

    -- 注册文件压缩快捷键
    total_count = total_count + utils.register_hotkeys(compression_hotkeys)

    -- 注册宏录制快捷键
    total_count = total_count + utils.register_hotkeys(macro_recording_hotkeys)

    utils.log("HotkeysManager", "统一快捷键管理已初始化，共注册 " .. total_count .. " 个快捷键")
    return total_count
end

-- 显示快捷键帮助
function M.show_help()
    local help_text = [[🔥 Hammerspoon 快捷键说明

📱 应用控制:
  ⌘⌃⇧+T: Ghostty在此处打开
  ⌘⌃⇧+W: Cursor在此处打开
  ⌘⌃⇧+V: Nvim在Ghostty中打开文件
  ⌘⇧+N: 创建新文件夹

🏃 脚本运行:
  ⌘⌃⇧+S: 运行选中脚本
  ⌘⌃⇧+R: 并行运行脚本

🎵 音乐控制:
  ⌘⌃⇧+;: 音乐播放/暂停
  ⌘⌃⇧+': 下一首
  ⌘⌃⇧+L: 上一首
  ⌘⌃⇧+Z: Zen Browser媒体控制
  ⌘⌃⇧+P: 系统媒体播放/暂停

🎬 宏控制:
  录制/标记点: ⌘⌃⇧+[
  停止录制:    ⌘⌃⇧+]
  ⌘⌃⇧+1: 播放宏1      ⌘⌃⇧+6: 播放宏6
  ⌘⌃⇧+2: 播放宏2      ⌘⌃⇧+7: 播放宏7
  ⌘⌃⇧+3: 播放宏3      ⌘⌃⇧+8: 播放宏8
  ⌘⌃⇧+4: 播放宏4      ⌘⌃⇧+9: 播放宏9
  ⌘⌃⇧+5: 播放宏5      ⌘⌃⇧+0: 播放宏10

📋 剪贴板工具:
  ⌘⌃⇧+N: 复制文件名
  ⌘⌃⇧+C: 复制文件名和内容
  ⌃⌥+V: 粘贴到Finder

📦 文件操作:
  ⌘⌃⇧+K: 压缩选中文件/文件夹

📱 应用快捷键:
  ⌘⇧+Q: 重启当前应用
  ⌃⌥+W: 启动微信
  ⌘⌥+,: 打开系统设置]]

    hs.alert.show(help_text, 15)
end

return M
