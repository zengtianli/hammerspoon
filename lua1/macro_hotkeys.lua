local utils = require("lua1.common_utils")
local macro = require("lua1.macro_controls")

-- 宏快捷键模块
local macro_hotkeys = {}

-- 宏快捷键配置表 (延迟绑定函数)
local macro_hotkey_configs = {
    { { "cmd", "ctrl", "shift" }, "1", "宏播放1", "macro_play_1" },
    { { "cmd", "ctrl", "shift" }, "2", "宏播放2", "macro_play_2" },
    { { "cmd", "ctrl", "shift" }, "3", "宏播放3", "macro_play_3" },
    { { "cmd", "ctrl", "shift" }, "4", "宏播放4", "macro_play_4" },
}

-- 存储已绑定的快捷键对象
local bound_hotkeys = {}

-- 绑定宏快捷键
macro_hotkeys.bind_macro_hotkeys = function()
    utils.debug_print("宏快捷键", "开始绑定宏快捷键...")

    for i, config in ipairs(macro_hotkey_configs) do
        local modifiers, key, description, func_name = config[1], config[2], config[3], config[4]

        local hotkey = hs.hotkey.bind(modifiers, key, function()
            utils.debug_print("宏快捷键", "触发: " .. description)

            -- 动态获取函数
            local callback = macro[func_name]
            if callback and type(callback) == "function" then
                callback()
            else
                utils.show_error_notification("宏快捷键", "函数未找到: " .. func_name)
                -- 列出可用函数
                local available_funcs = {}
                for k, v in pairs(macro or {}) do
                    if type(v) == "function" then
                        table.insert(available_funcs, k)
                    end
                end
                utils.debug_print("宏快捷键", "可用函数: " .. table.concat(available_funcs, ", "))
            end
        end)

        table.insert(bound_hotkeys, hotkey)
        utils.debug_print("宏快捷键", "已绑定: " .. description .. " (⌘⌃⇧⌥+" .. key .. ") -> " .. func_name)
    end

    utils.show_success_notification("宏快捷键", "已绑定 " .. #macro_hotkey_configs .. " 个宏快捷键")
end

-- 解绑宏快捷键
macro_hotkeys.unbind_macro_hotkeys = function()
    utils.debug_print("宏快捷键", "开始解绑宏快捷键...")

    for i, hotkey in ipairs(bound_hotkeys) do
        if hotkey then
            hotkey:delete()
        end
    end

    bound_hotkeys = {}
    utils.debug_print("宏快捷键", "所有宏快捷键已解绑")
end

-- 重新绑定宏快捷键 (用于配置更新后)
macro_hotkeys.rebind_macro_hotkeys = function()
    macro_hotkeys.unbind_macro_hotkeys()
    macro_hotkeys.bind_macro_hotkeys()
end

-- 获取宏快捷键配置信息
macro_hotkeys.get_hotkey_info = function()
    local info = {}
    for i, config in ipairs(macro_hotkey_configs) do
        local modifiers, key, description = config[1], config[2], config[3]
        table.insert(info, {
            key = "⌘⌃⇧⌥+" .. key,
            description = description,
            modifiers = modifiers,
            keycode = key
        })
    end
    return info
end

-- 更新宏快捷键配置 (动态配置时使用)
macro_hotkeys.update_hotkey_config = function(new_configs)
    macro_hotkey_configs = new_configs
    macro_hotkeys.rebind_macro_hotkeys()
    utils.show_success_notification("宏快捷键", "快捷键配置已更新")
end

-- 显示宏快捷键帮助信息
macro_hotkeys.show_help = function()
    local help_text = "🎬 宏快捷键帮助:\n"
    for i, config in ipairs(macro_hotkey_configs) do
        local modifiers, key, description = config[1], config[2], config[3]
        help_text = help_text .. "  ⌘⌃⇧⌥+" .. key .. ": " .. description .. "\n"
    end
    hs.alert.show(help_text, 5)
end

print("🎬 Macro Hotkeys 模块已加载")
utils.debug_print("宏快捷键", "配置了 " .. #macro_hotkey_configs .. " 个宏快捷键")

return macro_hotkeys
