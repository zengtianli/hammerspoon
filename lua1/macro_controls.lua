local utils = require("lua1.common_utils")

-- 宏控制模块
local macro_controls = {}

-- 宏配置表 - 快捷键编号到宏名称的映射
local macro_config = {
    ["1"] = "1", -- ⌘⌃⇧⌥+1 播放1宏
    ["2"] = "2", -- ⌘⌃⇧⌥+2 播放2宏
    ["3"] = "3", -- ⌘⌃⇧⌥+3 播放3宏
    ["4"] = "4", -- ⌘⌃⇧⌥+4 播放4宏
}

-- 宏播放控制 (通用函数)
macro_controls.macro_play = function(macro_name)
    if not macro_name or macro_name == "" then
        utils.show_error_notification("宏播放", "宏名称不能为空")
        return
    end

    local script_path = os.getenv("HOME") .. "/.config/hammerspoon/scripts/macro_play.sh"

    -- 检查脚本文件是否存在
    if not hs.fs.attributes(script_path, "mode") then
        utils.show_error_notification("宏播放", "脚本文件不存在: " .. script_path)
        return
    end

    utils.show_success_notification("宏播放", "正在播放宏: " .. macro_name)
    utils.debug_print("宏播放", "脚本路径: " .. script_path)
    utils.debug_print("宏播放", "开始播放宏: " .. macro_name)

    hs.task.new("/bin/bash", function(exit_code, stdout, stderr)
        utils.debug_print("宏播放", "退出代码: " .. tostring(exit_code))
        if stdout and stdout ~= "" then
            utils.debug_print("宏播放", "输出: " .. stdout)
        end
        if stderr and stderr ~= "" then
            utils.debug_print("宏播放", "错误: " .. stderr)
        end

        if exit_code == 0 then
            utils.show_success_notification("宏播放", "宏播放完成: " .. macro_name)
        else
            utils.show_error_notification("宏播放", "播放失败(代码:" .. tostring(exit_code) .. "): " .. (stderr or "未知错误"))
        end
    end, { script_path, macro_name }):start()
end

-- 根据快捷键编号播放宏的工厂函数
local function create_macro_player(key_number)
    return function()
        local macro_name = macro_config[tostring(key_number)]
        if macro_name then
            macro_controls.macro_play(macro_name)
        else
            utils.show_error_notification("宏播放", "快捷键 " .. key_number .. " 未配置宏")
        end
    end
end

-- 动态生成快捷键播放函数
for key, macro_name in pairs(macro_config) do
    local func_name = "macro_play_" .. key
    macro_controls[func_name] = create_macro_player(key)
    utils.debug_print("宏配置", "已创建函数: " .. func_name .. " -> " .. macro_name)
end

-- 宏选择播放菜单
macro_controls.macro_play_menu = function()
    local script_path = os.getenv("HOME") .. "/.config/hammerspoon/scripts/macro_play.sh"

    -- 调用 macro_play.sh 不带参数来显示选择菜单
    hs.task.new("/bin/bash", function(exit_code, stdout, stderr)
        if exit_code ~= 0 and stderr then
            utils.show_error_notification("宏播放菜单", "菜单显示失败: " .. stderr)
        end
    end, { script_path }):start()
end

-- 获取宏配置信息 (调试用)
macro_controls.get_macro_config = function()
    return macro_config
end

-- 更新宏配置 (动态修改)
macro_controls.update_macro_config = function(new_config)
    for key, value in pairs(new_config) do
        macro_config[key] = value
        local func_name = "macro_play_" .. key
        macro_controls[func_name] = create_macro_player(key)
        utils.debug_print("宏配置", "已更新: " .. func_name .. " -> " .. value)
    end
end

print("🎬 Macro Controls 模块已加载")
if hs and hs.inspect then
    print("📋 宏配置: " .. hs.inspect(macro_config))
else
    print("📋 宏配置: 已加载 " .. tostring(table.getn and table.getn(macro_config) or "多个") .. " 个快捷键")
end
return macro_controls
