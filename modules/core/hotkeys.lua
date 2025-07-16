-- 统一快捷键管理模块
local utils = require("modules.core.utils")
local config = require("config.settings")
local hotkey_config = require("config.hotkeys")

local M = {}

-- 动态加载模块
local function lazyRequire(moduleName)
    return setmetatable({}, {
        __index = function(_, key)
            local mod = require(moduleName)
            return mod[key]
        end
    })
end

-- 延迟加载模块
local app_manager = lazyRequire("modules.apps.manager")
local script_runner = lazyRequire("modules.core.script")
local compress_tools = lazyRequire("modules.tools.compress")
local macro_controls = lazyRequire("modules.macro.recorder")
local clipboard = lazyRequire("modules.tools.clipboard")
local media = lazyRequire("modules.media.music")
local system = lazyRequire("modules.tools.system")
local wechat = lazyRequire("modules.apps.wechat")
local macro_hotkeys = lazyRequire("modules.macro.hotkeys")

-- -----------------------------------------------------------------------------
-- 根据用户配置动态生成应用控制快捷键
-- -----------------------------------------------------------------------------

-- 根据配置选择对应的函数
local terminal_actions = {
    Ghostty = { func = app_manager.open_ghostty_here, name = "Ghostty" },
    Warp = { func = app_manager.open_warp_here, name = "Warp" },
    Terminal = { func = app_manager.open_terminal_here, name = "Terminal" },
}

local ide_actions = {
    Cursor = { func = app_manager.open_cursor_here, name = "Cursor" },
    Windsurf = { func = app_manager.open_windsurf_here, name = "Windsurf" },
    VSCode = { func = app_manager.open_vscode_here, name = "VSCode" },
}

-- 根据用户配置选择默认应用
local selected_terminal = terminal_actions[config.preferred_terminal] or terminal_actions.Ghostty
local selected_ide = ide_actions[config.preferred_ide] or ide_actions.Cursor

-- 初始化所有快捷键
function M.init()
    local total_count = 0
    local hotkeys = hotkey_config

    -- 为动态快捷键设置回调函数
    local dynamic_app_hotkeys = {
        { { "cmd", "ctrl", "shift" }, "t", "Term: " .. selected_terminal.name .. " 在此处打开", selected_terminal.func },
        { { "cmd", "ctrl", "shift" }, "w", "IDE: " .. selected_ide.name .. " 在此处打开", selected_ide.func },
    }

    -- 设置应用控制快捷键函数
    for i, hk in ipairs(hotkeys.app_hotkeys) do
        if hk[2] == "i" then
            hk[4] = app_manager.open_file_in_nvim_ghostty
        elseif hk[2] == "n" then
            hk[4] = app_manager.create_folder
        end
    end

    -- 设置脚本运行快捷键函数
    for i, hk in ipairs(hotkeys.script_hotkeys) do
        if hk[2] == "s" then
            hk[4] = script_runner.run_single
        elseif hk[2] == "r" then
            hk[4] = script_runner.run_parallel
        end
    end

    -- 设置文件压缩快捷键函数
    for i, hk in ipairs(hotkeys.compression_hotkeys) do
        if hk[2] == "c" then
            hk[4] = compress_tools.compress_selection
        end
    end

    -- 设置剪贴板快捷键函数
    for i, hk in ipairs(hotkeys.clipboard_hotkeys) do
        if hk[2] == "n" then
            hk[4] = clipboard.copy_filenames
        elseif hk[2] == "b" then
            hk[4] = clipboard.copy_names_and_content
        elseif hk[2] == "v" then
            hk[4] = clipboard.paste_to_finder
        end
    end

    -- 设置媒体控制快捷键函数
    for i, hk in ipairs(hotkeys.media_hotkeys) do
        if hk[2] == ";" then
            hk[4] = media.togglePlayback
        elseif hk[2] == "'" then
            hk[4] = media.nextTrack
        elseif hk[2] == "l" then
            hk[4] = media.previousTrack
        elseif hk[2] == "z" then
            hk[4] = media.zenPlayToggle
        elseif hk[2] == "p" then
            hk[4] = media.systemPlayPause
        end
    end

    -- 设置系统控制快捷键函数
    for i, hk in ipairs(hotkeys.system_hotkeys) do
        if hk[2] == "," then
            hk[4] = system.openSystemSettings
        elseif hk[2] == "q" then
            hk[4] = wechat.launchWechat
        elseif hk[2] == "h" then
            hk[4] = M.show_help
        end
    end

    -- 注册应用控制快捷键
    total_count = total_count + utils.register_hotkeys(dynamic_app_hotkeys)
    total_count = total_count + utils.register_hotkeys(hotkeys.app_hotkeys)

    -- 注册脚本运行快捷键
    total_count = total_count + utils.register_hotkeys(hotkeys.script_hotkeys)

    -- 注册文件压缩快捷键
    total_count = total_count + utils.register_hotkeys(hotkeys.compression_hotkeys)

    -- 注册剪贴板快捷键
    total_count = total_count + utils.register_hotkeys(hotkeys.clipboard_hotkeys)

    -- 注册媒体控制快捷键
    total_count = total_count + utils.register_hotkeys(hotkeys.media_hotkeys)

    -- 注册系统控制快捷键
    total_count = total_count + utils.register_hotkeys(hotkeys.system_hotkeys)

    -- 初始化宏快捷键 (由宏模块自己处理)
    macro_hotkeys.bind_macro_hotkeys()

    utils.log("HotkeysManager", "统一快捷键管理已初始化，共注册 " .. total_count .. " 个快捷键")
    return total_count
end

-- 显示快捷键帮助
function M.show_help()
    local help_text = [[🔥 Hammerspoon 快捷键说明

📱 应用控制:
  ⌘⌃⇧+T: ]] .. selected_terminal.name .. [[在此处打开
  ⌘⌃⇧+W: ]] .. selected_ide.name .. [[在此处打开
  ⌘⌃⇧+I: Nvim在Ghostty中打开文件
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
  ⌘⌃⇧+B: 复制文件名和内容
  ⌃⌥+V: 粘贴到Finder

📦 文件操作:
  ⌘⌃⇧+K: 压缩选中文件/文件夹

📱 应用快捷键:
  ⌘⇧+Q: 重启当前应用
  ⌃⌥+W: 启动微信
  ⌘⌥+,: 打开系统设置]]

    hs.alert.show(help_text, 15)
end

print("🔥 HotKeys Manager 模块已加载")
return M
