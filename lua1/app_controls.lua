local app_controls = {}
local utils = require("lua1.common_utils")

-- ===== 通用函数 =====

-- 在 Ghostty 中执行命令
local function run_in_ghostty(command)
    local ghostty_app = utils.ensure_app_running("Ghostty", 1)
    if not ghostty_app then
        hs.timer.doAfter(1, function() run_in_ghostty(command) end)
        return
    end

    ghostty_app:activate()
    hs.timer.doAfter(0.2, function()
        hs.eventtap.keyStroke({ "cmd" }, "n") -- 新标签页
        hs.timer.doAfter(0.3, function()
            utils.safe_clipboard_operation(command, function()
                hs.eventtap.keyStroke({ "cmd" }, "v")
                hs.timer.doAfter(0.1, function()
                    hs.eventtap.keyStroke({}, "return")
                end)
            end)
        end)
    end)
end

-- 在 Terminal 中执行命令
local function run_in_terminal(command)
    local terminal_app = utils.ensure_app_running("Terminal", 1)
    if not terminal_app then
        hs.timer.doAfter(1, function() run_in_terminal(command) end)
        return
    end

    terminal_app:activate()
    hs.timer.doAfter(0.2, function()
        hs.eventtap.keyStroke({ "cmd" }, "t") -- 新标签页
        hs.timer.doAfter(0.3, function()
            utils.safe_clipboard_operation(command, function()
                hs.eventtap.keyStroke({ "cmd" }, "v")
                hs.timer.doAfter(0.1, function()
                    hs.eventtap.keyStroke({}, "return")
                end)
            end)
        end)
    end)
end

-- ===== 导出的应用控制功能 =====

-- 在 Ghostty 中打开当前 Finder 目录
app_controls.open_ghostty_here = function()
    local current_dir = utils.get_finder_current_dir()
    local command = string.format('cd "%s"', current_dir)
    run_in_ghostty(command)
    utils.show_success_notification("Ghostty", "已在 " .. hs.fs.displayName(current_dir) .. " 中打开")
end

-- 在 Terminal 中打开当前 Finder 目录
app_controls.open_terminal_here = function()
    local current_dir = utils.get_finder_current_dir()
    local command = string.format('cd "%s"', current_dir)
    run_in_terminal(command)
    utils.show_success_notification("Terminal", "已在 " .. hs.fs.displayName(current_dir) .. " 中打开")
end

-- 在 VS Code 中打开当前 Finder 目录
app_controls.open_vscode_here = function()
    local current_dir = utils.get_finder_current_dir()

    hs.task.new("/usr/local/bin/code", function(exit_code, stdout, stderr)
        if exit_code == 0 then
            utils.show_success_notification("VS Code", "已在 " .. hs.fs.displayName(current_dir) .. " 中打开")
        else
            hs.task.new("/opt/homebrew/bin/code", function(exit_code2, stdout2, stderr2)
                if exit_code2 == 0 then
                    utils.show_success_notification("VS Code", "已在 " .. hs.fs.displayName(current_dir) .. " 中打开")
                else
                    utils.show_error_notification("VS Code", "未找到 code 命令，请确保 VS Code 已安装")
                end
            end, { current_dir }):start()
        end
    end, { current_dir }):start()
end

-- 在 Cursor 中打开当前 Finder 目录
app_controls.open_cursor_here = function()
    local current_dir = utils.get_finder_current_dir()

    hs.task.new("/usr/local/bin/cursor", function(exit_code, stdout, stderr)
        if exit_code == 0 then
            utils.show_success_notification("Cursor", "已在 " .. hs.fs.displayName(current_dir) .. " 中打开")
        else
            hs.application.open("Cursor")
            utils.show_success_notification("Cursor", "已启动 Cursor（请手动打开目录）")
        end
    end, { current_dir }):start()
end

-- 在 Ghostty 中用 nvim 打开选中的文件
app_controls.open_file_in_nvim_ghostty = function()
    local selected_file = utils.get_selected_single_file()

    if not selected_file then
        hs.alert.show("❌ 没有在Finder中选择文件")
        return
    end

    local file_dir = utils.get_file_directory(selected_file) or "."
    local command = string.format('cd "%s" && nvim "%s"', file_dir, selected_file)

    run_in_ghostty(command)
    utils.show_success_notification("Nvim in Ghostty", "已在 Ghostty 中用 Nvim 打开 " .. hs.fs.displayName(selected_file))
end

-- 在当前 Finder 位置创建新文件夹
app_controls.create_folder = function()
    local current_dir = utils.get_finder_current_dir()

    if not current_dir then
        hs.alert.show("❌ 无法获取当前 Finder 目录")
        return
    end

    local base_name = "untitled folder"
    local new_folder_name = base_name
    local counter = 2

    -- 如果文件夹已存在，自动添加序号
    while hs.fs.attributes(current_dir .. "/" .. new_folder_name, "mode") do
        new_folder_name = base_name .. " " .. counter
        counter = counter + 1
    end

    local new_folder_path = current_dir .. "/" .. new_folder_name
    local success = hs.fs.mkdir(new_folder_path)

    if success then
        local script = string.format([[
            tell application "Finder"
                activate
                set originalWindow to front window
                select POSIX file "%s"
                delay 0.1
                set index of originalWindow to 1
            end tell
        ]], new_folder_path)

        hs.osascript.applescript(script)
        utils.show_success_notification("文件夹创建成功", "已在当前位置创建文件夹 \"" .. new_folder_name .. "\"")
    else
        hs.alert.show("❌ 创建文件夹失败")
    end
end

-- 通用函数，供其他模块使用
app_controls.utils = {
    get_finder_current_dir = utils.get_finder_current_dir,
    get_selected_single_file = utils.get_selected_single_file,
    run_in_ghostty = run_in_ghostty,
    run_in_terminal = run_in_terminal
}

print("📱 App Controls 模块已加载")

return app_controls
