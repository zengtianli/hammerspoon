local clipboard_utils, utils = require("lua1.clipboard_utils"), require("lua1.common_utils")

-- 剪贴板热键配置
local hotkeys = {
    { { "cmd", "ctrl", "shift" }, "n", "复制文件名", clipboard_utils.copy_filenames },
    { { "cmd", "ctrl", "shift" }, "c", "复制文件名和内容", clipboard_utils.copy_names_and_content },
    { { "ctrl", "alt" }, "v", "粘贴到Finder", clipboard_utils.paste_to_finder },
}

-- 注册热键
utils.register_hotkeys(hotkeys)

print("📋 剪贴板热键已配置:")
print("   ⌘⌃⇧ + n: 复制文件名   ⌘⌃⇧ + c: 复制文件名和内容   ⌘⌃⇧ + v: 粘贴到Finder")

return { hotkeys = hotkeys }
