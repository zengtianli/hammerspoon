local clipboard_utils = {}

-- 获取当前选中的多个文件
local function get_selected_multiple_files()
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
            local trimmed = file:gsub("^%s*(.-)%s*$", "%1")
            if trimmed ~= "" then
                table.insert(files, trimmed)
            end
        end
        return files
    else
        return {}
    end
end

-- 复制选中文件的文件名到剪贴板
clipboard_utils.copy_filenames = function()
    local selected_files = get_selected_multiple_files()

    if #selected_files == 0 then
        hs.alert.show("❌ 在Finder中未选择文件")
        return
    end

    local filenames = {}

    -- 处理每个选中的文件
    for _, file_path in ipairs(selected_files) do
        -- 获取文件名（不含路径）
        local filename = hs.fs.displayName(file_path)
        table.insert(filenames, filename)
    end

    -- 将所有文件名用换行符连接
    local content = table.concat(filenames, "\n")

    -- 复制到剪贴板
    hs.pasteboard.setContents(content)

    -- 显示通知
    local count = #selected_files
    local message
    if count == 1 then
        message = "已复制 1 个文件的名称到剪贴板"
    else
        message = string.format("已复制 %d 个文件的名称到剪贴板", count)
    end

    hs.notify.new({
        title = "文件名复制成功",
        informativeText = message,
        withdrawAfter = 3
    }):send()

    print("📋 " .. message)
end

-- 复制选中文件的文件名和内容到剪贴板
clipboard_utils.copy_names_and_content = function()
    local selected_files = get_selected_multiple_files()

    if #selected_files == 0 then
        hs.alert.show("❌ 在Finder中未选择文件")
        return
    end

    local content_parts = {}
    local successful_count = 0

    -- 处理每个选中的文件
    for _, file_path in ipairs(selected_files) do
        -- 获取文件名（不含路径）
        local filename = hs.fs.displayName(file_path)

        -- 检查文件是否可读
        local file_attrs = hs.fs.attributes(file_path)
        if not file_attrs or file_attrs.mode ~= "file" then
            print("⚠️ 跳过非文件项：" .. filename)
            goto continue
        end

        -- 尝试读取文件内容
        local file = io.open(file_path, "r")
        if not file then
            print("⚠️ 无法读取文件：" .. filename)
            goto continue
        end

        local file_content = file:read("*all")
        file:close()

        -- 构建文件名和内容
        table.insert(content_parts, "文件名：" .. filename)
        table.insert(content_parts, "") -- 空行
        table.insert(content_parts, file_content)
        table.insert(content_parts, "") -- 空行
        table.insert(content_parts, "-----------------------------------")
        table.insert(content_parts, "") -- 空行

        successful_count = successful_count + 1

        ::continue::
    end

    if successful_count == 0 then
        hs.alert.show("❌ 无法读取任何选中的文件")
        return
    end

    -- 将所有内容连接
    local final_content = table.concat(content_parts, "\n")

    -- 复制到剪贴板
    hs.pasteboard.setContents(final_content)

    -- 显示通知
    local message
    if successful_count == 1 then
        message = "已复制 1 个文件的名称和内容到剪贴板"
    else
        message = string.format("已复制 %d 个文件的名称和内容到剪贴板", successful_count)
    end

    hs.notify.new({
        title = "文件名和内容复制成功",
        informativeText = message,
        withdrawAfter = 3
    }):send()

    print("📋 " .. message)
end

-- 获取Finder当前目录
local function get_finder_current_directory()
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
        return result:gsub("^%s*(.-)%s*$", "%1") -- 去除首尾空白
    else
        return nil
    end
end

-- 检测剪贴板内容类型
local function detect_clipboard_type()
    -- 获取剪贴板中所有的内容类型
    local content_types = hs.pasteboard.contentTypes()

    if not content_types or #content_types == 0 then
        return "empty"
    end

    -- 检查是否包含文件相关的类型
    for _, content_type in ipairs(content_types) do
        -- macOS 文件复制时的常见类型
        if content_type == "public.file-url" or
            content_type == "public.url" or
            content_type == "CorePasteboardFlavorType 0x6675726C" or -- 'furl'
            content_type:match("file") then
            return "files"
        end
    end

    -- 如果没有文件类型，检查是否有文本内容
    local clipboard_content = hs.pasteboard.getContents()
    if clipboard_content and clipboard_content ~= "" then
        return "text"
    end

    return "empty"
end

-- 使用AppleScript方式粘贴（推荐方式）
local function paste_with_applescript(target_dir)
    local script = string.format([[
        tell application "Finder"
            activate
            set targetFolder to POSIX file "%s" as alias
            open targetFolder
            delay 0.8
        end tell

        -- 直接发送粘贴命令
        tell application "System Events"
            delay 0.5
            keystroke "v" using command down
        end tell
    ]], target_dir)

    local ok, result = hs.osascript.applescript(script)
    return ok
end

-- 粘贴到Finder的主要功能（仅支持文件粘贴）
clipboard_utils.paste_to_finder = function(target_dir)
    -- 如果没有指定目标目录，使用Finder当前目录
    if not target_dir then
        target_dir = get_finder_current_directory()
        if not target_dir then
            hs.alert.show("❌ 无法获取Finder当前目录")
            return
        end
    end

    -- 验证目标目录
    local dir_attrs = hs.fs.attributes(target_dir)
    if not dir_attrs or dir_attrs.mode ~= "directory" then
        hs.alert.show("❌ 目录不存在：" .. (target_dir or ""))
        return
    end

    -- 检查剪贴板内容
    local clipboard_type = detect_clipboard_type()

    -- 调试信息：显示剪贴板内容类型
    local content_types = hs.pasteboard.contentTypes()
    print("📋 剪贴板内容类型: " .. table.concat(content_types or {}, ", "))
    print("📋 检测结果: " .. clipboard_type)

    if clipboard_type == "empty" then
        hs.alert.show("❌ 剪贴板为空")
        return
    end

    if clipboard_type ~= "files" then
        local debug_info = "类型: " .. table.concat(content_types or {}, ", ")
        hs.alert.show("❌ 剪贴板不包含文件，仅支持文件粘贴\n" .. debug_info)
        return
    end

    hs.alert.show("📋 正在粘贴到 " .. hs.fs.displayName(target_dir) .. "...")

    -- 文件内容，使用AppleScript粘贴
    if paste_with_applescript(target_dir) then
        hs.notify.new({
            title = "粘贴成功",
            informativeText = "文件已粘贴到 " .. hs.fs.displayName(target_dir),
            withdrawAfter = 3
        }):send()
        print("📋 文件粘贴完成")
    else
        hs.alert.show("❌ 粘贴失败")
    end
end

print("📋 Clipboard Utils 模块已加载")

return clipboard_utils
