local common_utils = {}

-- ===== Finder 文件操作函数 =====

-- 获取当前 Finder 目录或选中项目的目录
function common_utils.get_finder_current_dir()
    local script = [[
        tell application "Finder"
            if (count of (selection as list)) > 0 then
                set firstItem to item 1 of (selection as list)
                if class of firstItem is folder then
                    POSIX path of (firstItem as alias)
                else
                    POSIX path of (container of firstItem as alias)
                end if
            else
                POSIX path of (insertion location as alias)
            end if
        end tell
    ]]

    local ok, result = hs.osascript.applescript(script)
    if ok and result then
        return result:gsub("%s+$", "") -- 去除末尾空白
    else
        return os.getenv("HOME")       -- fallback to home directory
    end
end

-- 获取选中的单个文件
function common_utils.get_selected_single_file()
    local script = [[
        tell application "Finder"
            if (count of (selection as list)) > 0 then
                POSIX path of (item 1 of (selection as list) as alias)
            else
                ""
            end if
        end tell
    ]]

    local ok, result = hs.osascript.applescript(script)
    if ok and result and result ~= "" then
        return result:gsub("%s+$", "")
    else
        return nil
    end
end

-- 获取选中的多个文件（逗号分割版本）
function common_utils.get_selected_multiple_files()
    local script = [[
        tell application "Finder"
            set selectedItems to selection as list
            set posixPaths to {}

            if (count of selectedItems) > 0 then
                repeat with i from 1 to count of selectedItems
                    set thisItem to item i of selectedItems
                    set end of posixPaths to POSIX path of (thisItem as alias)
                end repeat

                set AppleScript's text item delimiters to ","
                set pathsText to posixPaths as text
                set AppleScript's text item delimiters to ""
                return pathsText
            else
                return ""
            end if
        end tell
    ]]

    local ok, result = hs.osascript.applescript(script)
    if ok and result and result ~= "" then
        local files = {}
        -- 按逗号分割文件路径
        for file in result:gmatch("[^,]+") do
            local trimmed = common_utils.trim_string(file)
            if trimmed ~= "" then
                table.insert(files, trimmed)
            end
        end
        return files
    else
        return {}
    end
end

-- 获取选中的多个文件（换行分割版本，兼容scripts_caller）
function common_utils.get_selected_files_newline()
    local script = [[
        tell application "Finder"
            set selectedItems to selection
            set filePaths to {}
            repeat with anItem in selectedItems
                set end of filePaths to POSIX path of (anItem as alias)
            end repeat
            return filePaths
        end tell
    ]]

    local ok, result = hs.osascript.applescript(script)
    if ok and result then
        local files = {}
        local result_str = tostring(result)
        if result_str and result_str ~= "" then
            for file in result_str:gmatch("[^\r\n]+") do
                local trimmed = common_utils.trim_string(file)
                if trimmed ~= "" then
                    table.insert(files, trimmed)
                end
            end
        end
        return files
    else
        return {}
    end
end

-- ===== 字符串处理函数 =====

-- 去除首尾空白
function common_utils.trim_string(str)
    if not str then return "" end
    return str:gsub("^%s*(.-)%s*$", "%1")
end

-- ===== 文件操作函数 =====

-- 检查文件是否为可执行脚本
function common_utils.is_executable_script(file_path)
    local ext = file_path:match("%.([^%.]+)$")
    return ext and (ext:lower() == "sh" or ext:lower() == "py")
end

-- 确保目录存在
function common_utils.ensure_directory(dir_path)
    local ok = hs.fs.mkdir(dir_path)
    return dir_path
end

-- 设置脚本执行权限
function common_utils.make_executable(file_path)
    if file_path:match("%.sh$") then
        hs.task.new("/bin/chmod", nil, { "+x", file_path }):start()
    end
end

-- ===== 通知和提示函数 =====

-- 显示成功通知
function common_utils.show_success_notification(title, message, duration)
    hs.notify.new({
        title = title,
        informativeText = message,
        withdrawAfter = duration or 3
    }):send()
end

-- 显示错误通知
function common_utils.show_error_notification(title, message, duration)
    hs.notify.new({
        title = title,
        informativeText = message,
        withdrawAfter = duration or 5
    }):send()
end

-- 显示带计数的结果消息
function common_utils.get_count_message(count, single_text, plural_text)
    if count == 1 then
        return string.format("已%s 1 个%s", single_text, "文件")
    else
        return string.format("已%s %d 个%s", single_text, count, "文件")
    end
end

-- ===== 应用控制函数 =====

-- 检查应用是否运行，未运行则启动
function common_utils.ensure_app_running(app_name, startup_delay)
    local app = hs.application.find(app_name)
    if not app then
        hs.application.open(app_name)
        if startup_delay then
            hs.timer.usleep(startup_delay * 1000000) -- 转换为微秒
        end
        app = hs.application.find(app_name)
    end
    return app
end

-- 在应用中执行键盘快捷键
function common_utils.send_keystroke_to_app(app, modifiers, key, delay)
    if app then
        app:activate()
        if delay then
            hs.timer.doAfter(delay, function()
                hs.eventtap.keyStroke(modifiers, key)
            end)
        else
            hs.eventtap.keyStroke(modifiers, key)
        end
    end
end

-- ===== 剪贴板操作函数 =====

-- 安全的剪贴板操作（保存和恢复原内容）
function common_utils.safe_clipboard_operation(content, operation_callback)
    local old_clipboard = hs.pasteboard.getContents()
    hs.pasteboard.setContents(content)

    if operation_callback then
        hs.timer.doAfter(0.1, function()
            operation_callback()
            -- 恢复原剪贴板内容
            if old_clipboard then
                hs.timer.doAfter(0.1, function()
                    hs.pasteboard.setContents(old_clipboard)
                end)
            end
        end)
    end
end

-- 检测剪贴板内容类型
function common_utils.detect_clipboard_type()
    local content_types = hs.pasteboard.contentTypes()

    if not content_types or #content_types == 0 then
        return "empty"
    end

    -- 检查是否包含文件相关的类型
    for _, content_type in ipairs(content_types) do
        if content_type == "public.file-url" or
            content_type == "public.url" or
            content_type == "CorePasteboardFlavorType 0x6675726C" or
            content_type:match("file") then
            return "files"
        end
    end

    -- 检查是否有文本内容
    local clipboard_content = hs.pasteboard.getContents()
    if clipboard_content and clipboard_content ~= "" then
        return "text"
    end

    return "empty"
end

-- ===== 路径处理函数 =====

-- 获取文件扩展名
function common_utils.get_file_extension(file_path)
    return file_path:match("%.([^%.]+)$")
end

-- 获取文件目录
function common_utils.get_file_directory(file_path)
    return file_path:match("(.*/)")
end

-- ===== 调试和日志函数 =====

-- 带模块名的打印
function common_utils.log(module_name, message)
    print(string.format("[%s] %s", module_name, message))
end

-- 调试信息打印
function common_utils.debug_print(title, data)
    print("=== " .. title .. " ===")
    if type(data) == "table" then
        for i, item in ipairs(data) do
            print(string.format("%d: %s", i, tostring(item)))
        end
    else
        print(tostring(data))
    end
    print("=== " .. title .. " 结束 ===")
end

-- ===== 抽象的高级函数 =====

-- 批量注册热键
function common_utils.register_hotkeys(hotkeys_table, extra_hotkeys)
    for _, hk in ipairs(hotkeys_table) do
        hs.hotkey.bind(hk[1], hk[2], hk[3], hk[4])
    end
    if extra_hotkeys then
        for _, hk in ipairs(extra_hotkeys) do
            hs.hotkey.bind(hk[1], hk[2], hk[3], hk[4])
        end
    end
    return #hotkeys_table + (extra_hotkeys and #extra_hotkeys or 0)
end

-- 分析文件类型
function common_utils.analyze_file_types(files)
    local file_types = {}
    for _, file in ipairs(files) do
        local ext = file:match("%.([^%.]+)$")
        if ext then file_types[ext:lower()] = true end
    end
    return file_types
end

-- 构建转换菜单项
function common_utils.build_menu_item(config, files)
    local item = { title = config.title }
    if config.menu then
        item.menu = {}
        for _, conv in ipairs(config.menu) do
            table.insert(item.menu, { title = conv.title, fn = function() conv.fn(files) end })
        end
    else
        item.fn = function() config.fn(files) end
    end
    return item
end

-- 显示弹出菜单
function common_utils.show_popup_menu(menu_items, title)
    if #menu_items > 0 then
        local menu = hs.menubar.new():setTitle(title or "📁"):setMenu(menu_items)
        menu:removeFromMenuBar()
        hs.alert.show("右键点击菜单栏图标选择操作")
        hs.timer.doAfter(0.1, function() menu:popupMenu(hs.mouse.getAbsolutePosition()) end)
        return true
    else
        hs.alert.show("选中的文件类型暂不支持转换")
        return false
    end
end

-- 执行任务并统计
function common_utils.execute_task_with_stats(tasks, operation_name)
    local success_count, failed_count, total_count = 0, 0, #tasks

    for i, task_func in ipairs(tasks) do
        common_utils.show_progress(i, total_count, operation_name)
        if task_func() then
            success_count = success_count + 1
        else
            failed_count = failed_count + 1
        end
    end

    print("")
    common_utils.show_info(operation_name .. "完成")
    print("✅ 成功: " .. success_count .. " 个")
    if failed_count > 0 then print("❌ 失败: " .. failed_count .. " 个") end
    print("📊 总计: " .. total_count .. " 个")

    return { success = success_count, failed = failed_count, total = total_count }
end

-- 创建任务执行器
function common_utils.create_task_executor(cmd, callback)
    return function(args, working_dir)
        return hs.task.new(cmd, callback or function() end, args):setWorkingDirectory(working_dir or "."):start()
    end
end

-- 在应用中运行命令
function common_utils.run_command_in_app(app_name, command, keystroke_sequence)
    local app = common_utils.ensure_app_running(app_name, 1)
    if not app then
        hs.timer.doAfter(1, function() common_utils.run_command_in_app(app_name, command, keystroke_sequence) end)
        return
    end

    app:activate()
    hs.timer.doAfter(0.2, function()
        if keystroke_sequence then
            hs.eventtap.keyStroke(keystroke_sequence[1], keystroke_sequence[2])
        end
        hs.timer.doAfter(0.3, function()
            common_utils.safe_clipboard_operation(command, function()
                hs.eventtap.keyStroke({ "cmd" }, "v")
                hs.timer.doAfter(0.1, function()
                    hs.eventtap.keyStroke({}, "return")
                end)
            end)
        end)
    end)
end

-- 执行AppleScript并处理结果
function common_utils.execute_applescript(script, success_msg, error_msg)
    local ok, result = hs.osascript.applescript(script)
    if ok then
        if success_msg then common_utils.show_success_notification("操作成功", success_msg) end
        return result
    else
        if error_msg then hs.alert.show("❌ " .. error_msg) end
        return nil
    end
end

print("🔧 Common Utils 模块已加载")

return common_utils
