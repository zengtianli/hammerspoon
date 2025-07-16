-- 统一快捷键配置文件
-- 此文件集中定义所有快捷键绑定

local M = {}

-- 应用控制快捷键
M.app_hotkeys = {
    -- 终端和IDE快捷键会在运行时动态生成
    -- 格式: { { "cmd", "ctrl", "shift" }, "t", "Terminal在此处打开", function_reference }

    -- 其他固定快捷键
    { { "cmd", "ctrl", "shift" }, "i", "Nvim在Ghostty中打开文件", nil }, -- 函数引用将在模块加载时设置
    { { "cmd", "shift" }, "n", "创建新文件夹", nil },
}

-- 脚本运行快捷键
M.script_hotkeys = {
    { { "cmd", "ctrl", "shift" }, "s", "运行选中脚本", nil },
    { { "cmd", "ctrl", "shift" }, "r", "并行运行脚本", nil },
}

-- 文件压缩快捷键
M.compression_hotkeys = {
    { { "alt", "ctrl" }, "c", "压缩选中文件", nil },
}

-- 剪贴板快捷键
M.clipboard_hotkeys = {
    { { "cmd", "ctrl", "shift" }, "n", "复制文件名", nil },
    { { "cmd", "ctrl", "shift" }, "b", "复制文件名和内容", nil },
    { { "ctrl", "alt" }, "v", "粘贴到Finder", nil },
}

-- 媒体控制快捷键
M.media_hotkeys = {
    { { "cmd", "ctrl", "shift" }, ";", "音乐播放/暂停", nil },
    { { "cmd", "ctrl", "shift" }, "'", "下一首", nil },
    { { "cmd", "ctrl", "shift" }, "l", "上一首", nil },
    { { "cmd", "ctrl", "shift" }, "z", "Zen Browser媒体控制", nil },
    { { "cmd", "ctrl", "shift" }, "p", "系统媒体播放/暂停", nil },
}

-- 系统控制快捷键
M.system_hotkeys = {
    { { "cmd", "alt" }, ",", "打开系统设置", nil },
    { { "cmd", "shift" }, "q", "重启当前应用", nil },
    { { "cmd", "ctrl", "alt", "shift" }, "h", "显示快捷键帮助", nil },
}

-- 宏控制快捷键
M.macro_record_hotkeys = {
    { { "cmd", "ctrl", "shift" }, "[", "录制/标记宏点", nil },
    { { "cmd", "ctrl", "shift" }, "]", "停止宏录制", nil },
}

-- 宏播放快捷键
M.macro_play_hotkeys = {
    { { "cmd", "ctrl", "shift" }, "1", "播放宏1", nil },
    { { "cmd", "ctrl", "shift" }, "2", "播放宏2", nil },
    { { "cmd", "ctrl", "shift" }, "3", "播放宏3", nil },
    { { "cmd", "ctrl", "shift" }, "4", "播放宏4", nil },
    { { "cmd", "ctrl", "shift" }, "5", "播放宏5", nil },
    { { "cmd", "ctrl", "shift" }, "6", "播放宏6", nil },
    { { "cmd", "ctrl", "shift" }, "7", "播放宏7", nil },
    { { "cmd", "ctrl", "shift" }, "8", "播放宏8", nil },
    { { "cmd", "ctrl", "shift" }, "9", "播放宏9", nil },
    { { "cmd", "ctrl", "shift" }, "0", "播放宏10", nil },
}

-- WeChat快捷键
M.wechat_hotkeys = {
    { { "ctrl", "alt" }, "w", "启动微信", nil },
}

return M
