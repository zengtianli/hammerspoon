-- 宏控制模块
local utils = require("lua_comb.common_utils")
local macro_player = require("lua_comb.macro_player")

local macro_controls = {}

-- 宏配置表 - 快捷键编号到宏名称的映射
local macro_config = {
    ["1"] = "1",  -- ⌘⌃⇧+1 播放1宏
    ["2"] = "2",  -- ⌘⌃⇧+2 播放2宏
    ["3"] = "3",  -- ⌘⌃⇧+3 播放3宏
    ["4"] = "4",  -- ⌘⌃⇧+4 播放4宏
    ["5"] = "5",  -- ⌘⌃⇧+5 播放5宏
    ["6"] = "6",  -- ⌘⌃⇧+6 播放6宏
    ["7"] = "7",  -- ⌘⌃⇧+7 播放7宏
    ["8"] = "8",  -- ⌘⌃⇧+8 播放8宏
    ["9"] = "9",  -- ⌘⌃⇧+9 播放9宏
    ["0"] = "10", -- ⌘⌃⇧+0 播放10宏
}

-- 宏播放控制 (由 macro_player 模块驱动)
macro_controls.macro_play = function(macro_name)
    if not macro_name or macro_name == "" then
        utils.show_error_notification("宏播放", "宏名称不能为空")
        return
    end

    utils.debug_print("宏播放", "请求播放宏: " .. macro_name)
    macro_player.play_macro(macro_name)
end

-- 调用脚本录制宏的一个步骤（或开始录制）
macro_controls.record_step = function()
    local script_path = hs.configdir .. "/scripts/macro_record.sh"
    utils.log("MacroControls", "调用脚本录制宏步骤")
    hs.task.new("/bin/bash", nil, { script_path }):start()
end

-- 调用脚本停止宏录制
macro_controls.stop_recording = function()
    local script_path = hs.configdir .. "/scripts/macro_stop.sh"
    utils.log("MacroControls", "调用脚本停止宏录制")
    hs.task.new("/bin/bash", nil, { script_path }):start()
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
