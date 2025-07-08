-- 剪贴板工具模块
local utils = require("lua_comb.common_utils")

local clipboard_utils = {}

-- 复制选中文件的文件名到剪贴板
clipboard_utils.copy_filenames = function()
    local files = utils.get_selected_multiple_files()
    if #files == 0 then return hs.alert.show("❌ 在Finder中未选择文件") end

    local filenames = {}
    for _, file_path in ipairs(files) do
        table.insert(filenames, hs.fs.displayName(file_path))
    end

    hs.pasteboard.setContents(table.concat(filenames, "\n"))
    utils.show_success_notification("文件名复制成功", utils.get_count_message(#files, "复制", "") .. "的名称到剪贴板")
end

-- 复制选中文件的文件名和内容到剪贴板
clipboard_utils.copy_names_and_content = function()
    local files = utils.get_selected_multiple_files()
    if #files == 0 then return hs.alert.show("❌ 在Finder中未选择文件") end

    local content_parts, successful_count = {}, 0

    for _, file_path in ipairs(files) do
        local filename = hs.fs.displayName(file_path)
        local file_attrs = hs.fs.attributes(file_path)

        if file_attrs and file_attrs.mode == "file" then
            local file = io.open(file_path, "r")
            if file then
                local file_content = file:read("*all")
                file:close()
                table.insert(content_parts, "文件名：" .. filename)
                table.insert(content_parts, "")
                table.insert(content_parts, file_content)
                table.insert(content_parts, "\n-----------------------------------\n")
                successful_count = successful_count + 1
            end
        end
    end

    if successful_count == 0 then return hs.alert.show("❌ 无法读取任何选中的文件") end

    hs.pasteboard.setContents(table.concat(content_parts, "\n"))
    utils.show_success_notification("文件名和内容复制成功", utils.get_count_message(successful_count, "复制", "") .. "的名称和内容到剪贴板")
end

-- 粘贴到Finder的功能，通过调用外部shell脚本实现
clipboard_utils.paste_to_finder = function(target_dir)
    local script_path = hs.configdir .. "/scripts_ray/finder_paste.sh"
    local command_args = { script_path }

    -- 如果提供了目标目录，则将其作为参数传递给脚本
    if target_dir then
        table.insert(command_args, target_dir)
    end

    -- 脚本会自己处理成功或失败的通知，这里我们只在后台记录日志
    hs.task.new("/bin/bash", function(exit_code, stdout, stderr)
        if exit_code ~= 0 then
            utils.log("PasteToFinder", "脚本执行失败: " .. (stderr or stdout))
        else
            utils.log("PasteToFinder", "脚本执行成功")
        end
    end, command_args):start()
end

print("📋 Clipboard Utils 模块已加载")
return clipboard_utils
