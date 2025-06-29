local utils = require("lua1.common_utils")

-- 应用控制模块
local app_controls = {}

-- 在终端应用中打开目录
app_controls.open_ghostty_here = function()
    local dir = utils.get_finder_current_dir()
    utils.run_command_in_app("Ghostty", string.format('cd "%s"', dir), { "cmd", "n" })
    utils.show_success_notification("Ghostty", "已在 " .. hs.fs.displayName(dir) .. " 中打开")
end

app_controls.open_terminal_here = function()
    local dir = utils.get_finder_current_dir()
    utils.run_command_in_app("Terminal", string.format('cd "%s"', dir), { "cmd", "t" })
    utils.show_success_notification("Terminal", "已在 " .. hs.fs.displayName(dir) .. " 中打开")
end

-- 在编辑器中打开目录
app_controls.open_vscode_here = function()
    local dir = utils.get_finder_current_dir()
    local paths = { "/usr/local/bin/code", "/opt/homebrew/bin/code" }

    for _, path in ipairs(paths) do
        hs.task.new(path, function(exit_code)
            if exit_code == 0 then
                utils.show_success_notification("VS Code", "已在 " .. hs.fs.displayName(dir) .. " 中打开")
            end
        end, { dir }):start()
        return
    end
    utils.show_error_notification("VS Code", "未找到 code 命令")
end

app_controls.open_cursor_here = function()
    local dir = utils.get_finder_current_dir()
    hs.task.new("/usr/local/bin/cursor", function(exit_code)
        if exit_code ~= 0 then hs.application.open("Cursor") end
        utils.show_success_notification("Cursor", "已启动 Cursor")
    end, { dir }):start()
end

-- 在Ghostty中用nvim打开文件
app_controls.open_file_in_nvim_ghostty = function()
    local file = utils.get_selected_single_file()
    if not file then return hs.alert.show("❌ 没有在Finder中选择文件") end

    local dir = utils.get_file_directory(file) or "."
    utils.run_command_in_app("Ghostty", string.format('cd "%s" && nvim "%s"', dir, file), { "cmd", "n" })
    utils.show_success_notification("Nvim in Ghostty", "已用 Nvim 打开 " .. hs.fs.displayName(file))
end

-- 创建新文件夹
app_controls.create_folder = function()
    local dir = utils.get_finder_current_dir()
    if not dir then return hs.alert.show("❌ 无法获取当前 Finder 目录") end

    local base_name, counter = "untitled folder", 2
    local new_folder_name = base_name

    while hs.fs.attributes(dir .. "/" .. new_folder_name, "mode") do
        new_folder_name = base_name .. " " .. counter
        counter = counter + 1
    end

    local new_folder_path = dir .. "/" .. new_folder_name
    if hs.fs.mkdir(new_folder_path) then
        utils.execute_applescript(string.format([[
            tell application "Finder"
                activate
                set originalWindow to front window
                select POSIX file "%s"
                delay 0.1
                set index of originalWindow to 1
            end tell
        ]], new_folder_path), "已创建文件夹 \"" .. new_folder_name .. "\"")
    else
        hs.alert.show("❌ 创建文件夹失败")
    end
end

-- 宏录制控制
app_controls.macro_record = function()
    local record_file = "/tmp/hammerspoon_macro.txt"
    local status_file = "/tmp/hammerspoon_macro_recording"

    -- 检查是否正在录制
    if hs.fs.attributes(status_file, "mode") then
        -- 正在录制中，记录当前鼠标位置
        local mouse_pos = hs.mouse.getAbsolutePosition()
        local pos_string = string.format("%.0f,%.0f", mouse_pos.x, mouse_pos.y)

        -- 保存到文件
        local file = io.open(record_file, "a")
        if file then
            file:write(pos_string .. "\n")
            file:close()

            -- 获取已录制的操作数量
            local count = 0
            local count_file = io.open(record_file, "r")
            if count_file then
                for _ in count_file:lines() do
                    count = count + 1
                end
                count_file:close()
            end

            local message = string.format("已记录位置 %d: %s", count, pos_string)
            utils.show_success_notification("宏录制", message)
            utils.debug_print("宏录制", message)
        else
            utils.show_error_notification("宏录制", "❌ 无法写入录制文件")
        end
    else
        -- 开始录制
        local file = io.open(status_file, "w")
        if file then file:close() end

        -- 清空之前的录制
        local file = io.open(record_file, "w")
        if file then file:close() end

        utils.show_success_notification("宏录制", "宏录制已开始")
        utils.debug_print("宏录制", "宏录制已开始")
    end
end

print("📱 App Controls 模块已加载")
return app_controls
