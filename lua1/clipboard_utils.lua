local clipboard_utils = {}
local utils = require("lua1.common_utils")

-- 复制选中文件的文件名到剪贴板
clipboard_utils.copy_filenames = function()
    local selected_files = utils.get_selected_multiple_files()

    if #selected_files == 0 then
        hs.alert.show("❌ 在Finder中未选择文件")
        return
    end

    local filenames = {}
    for _, file_path in ipairs(selected_files) do
        table.insert(filenames, hs.fs.displayName(file_path))
    end

    local content = table.concat(filenames, "\n")
    hs.pasteboard.setContents(content)

    local message = utils.get_count_message(#selected_files, "复制", "") .. "的名称到剪贴板"
    utils.show_success_notification("文件名复制成功", message)
    utils.log("CLIPBOARD", message)
end

-- 复制选中文件的文件名和内容到剪贴板
clipboard_utils.copy_names_and_content = function()
    local selected_files = utils.get_selected_multiple_files()

    if #selected_files == 0 then
        hs.alert.show("❌ 在Finder中未选择文件")
        return
    end

    local content_parts = {}
    local successful_count = 0

    for _, file_path in ipairs(selected_files) do
        local filename = hs.fs.displayName(file_path)
        local file_attrs = hs.fs.attributes(file_path)

        if not file_attrs or file_attrs.mode ~= "file" then
            utils.log("CLIPBOARD", "⚠️ 跳过非文件项：" .. filename)
            goto continue
        end

        local file = io.open(file_path, "r")
        if not file then
            utils.log("CLIPBOARD", "⚠️ 无法读取文件：" .. filename)
            goto continue
        end

        local file_content = file:read("*all")
        file:close()

        table.insert(content_parts, "文件名：" .. filename)
        table.insert(content_parts, "")
        table.insert(content_parts, file_content)
        table.insert(content_parts, "")
        table.insert(content_parts, "-----------------------------------")
        table.insert(content_parts, "")

        successful_count = successful_count + 1
        ::continue::
    end

    if successful_count == 0 then
        hs.alert.show("❌ 无法读取任何选中的文件")
        return
    end

    local final_content = table.concat(content_parts, "\n")
    hs.pasteboard.setContents(final_content)

    local message = utils.get_count_message(successful_count, "复制", "") .. "的名称和内容到剪贴板"
    utils.show_success_notification("文件名和内容复制成功", message)
    utils.log("CLIPBOARD", message)
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
    if not target_dir then
        target_dir = utils.get_finder_current_dir()
        if not target_dir then
            hs.alert.show("❌ 无法获取Finder当前目录")
            return
        end
    end

    local dir_attrs = hs.fs.attributes(target_dir)
    if not dir_attrs or dir_attrs.mode ~= "directory" then
        hs.alert.show("❌ 目录不存在：" .. (target_dir or ""))
        return
    end

    local clipboard_type = utils.detect_clipboard_type()
    local content_types = hs.pasteboard.contentTypes()

    utils.log("CLIPBOARD", "剪贴板内容类型: " .. table.concat(content_types or {}, ", "))
    utils.log("CLIPBOARD", "检测结果: " .. clipboard_type)

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

    if paste_with_applescript(target_dir) then
        utils.show_success_notification("粘贴成功", "文件已粘贴到 " .. hs.fs.displayName(target_dir))
        utils.log("CLIPBOARD", "文件粘贴完成")
    else
        hs.alert.show("❌ 粘贴失败")
    end
end

print("📋 Clipboard Utils 模块已加载")

return clipboard_utils
