-- 鼠标跟随切换功能
-- 绑定快捷键: Cmd+Shift+M

-- 获取脚本路径
local script_path = hs.configdir .. "/scripts/mouse_follow_toggle.sh"

-- 切换鼠标跟随功能
local function toggleMouseFollow()
    hs.execute("bash " .. script_path)
end

-- 绑定快捷键 Cmd+Shift+M
hs.hotkey.bind({ "cmd", "shift" }, "m", toggleMouseFollow)

print("鼠标跟随切换功能已加载，快捷键: Cmd+Shift+M")
