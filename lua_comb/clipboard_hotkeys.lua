-- 剪贴板快捷键模块
local clipboard_utils = require("lua_comb.clipboard_utils")
local utils = require("lua_comb.common_utils")

local M = {}

-- 剪贴板热键配置
local hotkeys = {
	{ { "cmd", "ctrl", "shift" }, "n", "复制文件名", clipboard_utils.copy_filenames },
	{ { "cmd", "ctrl", "shift" }, "b", "复制文件名和内容", clipboard_utils.copy_names_and_content },
	{ { "ctrl", "alt" }, "v", "粘贴到Finder", clipboard_utils.paste_to_finder },
}

-- 初始化快捷键
function M.init()
	utils.register_hotkeys(hotkeys)
	print("📋 剪贴板热键已配置:")
	print("   ⌘⌃⇧ + N: 复制文件名   ⌘⌃⇧ + C: 复制文件名和内容   ⌃⌥ + V: 粘贴到Finder")
end

return M
