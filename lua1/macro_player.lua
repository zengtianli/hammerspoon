local utils = require("lua1.common_utils")

-- 高性能宏播放器模块
local macro_player = {}

-- 配置
local MACRO_DIR = os.getenv("HOME") .. "/.hammerspoon/macros"

-- 读取宏文件
local function read_macro_file(macro_name)
    local macro_file = MACRO_DIR .. "/macro_" .. macro_name .. ".txt"

    -- 检查文件是否存在
    if not hs.fs.attributes(macro_file, "mode") then
        return nil, "宏文件不存在: " .. macro_name
    end

    -- 读取所有位置
    local positions = {}
    local file = io.open(macro_file, "r")
    if not file then
        return nil, "无法打开宏文件: " .. macro_name
    end

    for line in file:lines() do
        line = line:trim()
        if line and line ~= "" then
            local x, y = line:match("([%d%.%-]+),([%d%.%-]+)")
            if x and y then
                table.insert(positions, { x = tonumber(x), y = tonumber(y) })
            end
        end
    end
    file:close()

    if #positions == 0 then
        return nil, "宏文件为空或格式错误: " .. macro_name
    end

    return positions, nil
end

-- 快速播放宏 (同步版本)
macro_player.play_macro_fast = function(macro_name)
    if not macro_name or macro_name == "" then
        utils.show_error_notification("宏播放", "宏名称不能为空")
        return false
    end

    -- 读取宏文件
    local positions, error_msg = read_macro_file(macro_name)
    if not positions then
        utils.show_error_notification("宏播放", error_msg)
        return false
    end

    -- 记录原始鼠标位置
    local original_pos = hs.mouse.absolutePosition()

    utils.debug_print("宏播放", "开始快速播放: " .. macro_name .. " (" .. #positions .. "个位置)")

    -- 快速执行所有操作
    for i, pos in ipairs(positions) do
        -- 移动鼠标并点击
        hs.mouse.absolutePosition({ x = pos.x, y = pos.y })
        hs.eventtap.leftClick({ x = pos.x, y = pos.y })

        -- 极小延迟，避免点击过快
        hs.timer.usleep(50000) -- 50ms
    end

    -- 回到原始位置
    hs.mouse.absolutePosition(original_pos)

    utils.debug_print("宏播放", "快速播放完成: " .. macro_name)
    return true
end

-- 异步播放宏 (更流畅)
macro_player.play_macro_async = function(macro_name, callback)
    if not macro_name or macro_name == "" then
        utils.show_error_notification("宏播放", "宏名称不能为空")
        if callback then callback(false) end
        return
    end

    -- 读取宏文件
    local positions, error_msg = read_macro_file(macro_name)
    if not positions then
        utils.show_error_notification("宏播放", error_msg)
        if callback then callback(false) end
        return
    end

    -- 记录原始鼠标位置
    local original_pos = hs.mouse.absolutePosition()

    utils.debug_print("宏播放", "开始异步播放: " .. macro_name .. " (" .. #positions .. "个位置)")

    -- 异步执行
    local current_index = 1
    local timer = hs.timer.new(0.05, function() -- 50ms间隔
        if current_index <= #positions then
            local pos = positions[current_index]
            hs.mouse.absolutePosition({ x = pos.x, y = pos.y })
            hs.eventtap.leftClick({ x = pos.x, y = pos.y })
            current_index = current_index + 1
        else
            -- 播放完成，回到原始位置
            hs.mouse.absolutePosition(original_pos)
            utils.debug_print("宏播放", "异步播放完成: " .. macro_name)
            if callback then callback(true) end
            return false -- 停止定时器
        end
    end)

    timer:start()
end

-- 播放宏 (默认使用快速同步版本)
macro_player.play_macro = function(macro_name)
    return macro_player.play_macro_fast(macro_name)
end

-- 获取可用宏列表
macro_player.get_available_macros = function()
    local macros = {}

    -- 确保目录存在
    if not hs.fs.attributes(MACRO_DIR, "mode") then
        return macros
    end

    -- 遍历宏文件
    for file in hs.fs.dir(MACRO_DIR) do
        if file:match("^macro_(.+)%.txt$") then
            local macro_name = file:match("^macro_(.+)%.txt$")
            table.insert(macros, macro_name)
        end
    end

    return macros
end

-- 字符串trim函数
if not string.trim then
    string.trim = function(s)
        return s:match("^%s*(.-)%s*$")
    end
end

print("⚡ Macro Player 模块已加载 (高性能版本)")
return macro_player
