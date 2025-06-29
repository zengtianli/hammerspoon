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

print("🔧 Common Utils 模块已加载")

return common_utils
