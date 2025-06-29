-- 加载剪贴板工具模块
local clipboard_utils = require("lua1.clipboard_utils")

-- 热键配置
local clipboard_hotkeys = {}

-- 复制选中文件的文件名到剪贴板
-- 热键：⌘⌃⇧ + C
clipboard_hotkeys.copy_filenames = hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "n", function()
    clipboard_utils.copy_filenames()
end)

-- 复制选中文件的文件名和内容到剪贴板
-- 热键：⌘⌃⇧ + c
clipboard_hotkeys.copy_names_and_content = hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "c", function()
    clipboard_utils.copy_names_and_content()
end)

-- 粘贴到Finder当前目录
-- 热键：⌘⌃⇧ + v
clipboard_hotkeys.paste_to_finder = hs.hotkey.bind({ "ctrl", "alt" }, "v", function()
    clipboard_utils.paste_to_finder()
end)

print("📋 剪贴板热键已配置:")
print("   ⌘⌃⇧ + n: 复制文件名")
print("   ⌘⌃⇧ + c: 复制文件名和内容")
print("   ⌘⌃⇧ + v: 粘贴到Finder")

return clipboard_hotkeys
