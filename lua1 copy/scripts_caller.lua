local scripts_caller = {}

-- 配置路径
local config = {
    python_path = "/Users/tianli/miniforge3/bin/python3",
    bash_path = "/bin/bash",                      -- 添加bash完整路径
    scripts_dir = hs.configdir .. "/scripts_ray", -- 使用当前Hammerspoon目录下的scripts_ray

    -- 定义脚本路径
    scripts = {
        -- 转换类脚本
        convert_csv_to_txt = "convert_csv_to_txt.py",
        convert_csv_to_xlsx = "convert_csv_to_xlsx.py",
        convert_txt_to_csv = "convert_txt_to_csv.py",
        convert_txt_to_xlsx = "convert_txt_to_xlsx.py",
        convert_xlsx_to_csv = "convert_xlsx_to_csv.py",
        convert_xlsx_to_txt = "convert_xlsx_to_txt.py",
        convert_docx_to_md = "convert_docx_to_md.sh",
        convert_office_batch = "convert_office_batch.sh",
        convert_pptx_to_md = "convert_pptx_to_md.py",

        -- 提取类脚本
        extract_images_office = "extract_images_office.py",
        extract_tables_office = "extract_tables_office.py",
        extract_text_tokens = "extract_text_tokens.py",

        -- 管理类脚本
        manage_app_launcher = "manage_app_launcher.sh",
        manage_pip_packages = "manage_pip_packages.sh",

        -- 文件操作类脚本
        file_move_up_level = "file_move_up_level.sh",

        -- 合并类脚本
        merge_csv_files = "merge_csv_files.sh",
        merge_markdown_files = "merge_markdown_files.sh"
    }
}

-- 通用执行函数
local function execute_script(script_name, args, callback)
    local script_path
    local cmd

    -- 确定脚本路径和执行命令
    if script_name:match("%.py$") then
        script_path = config.scripts_dir .. "/" .. script_name
        cmd = config.python_path
    else
        script_path = config.scripts_dir .. "/" .. script_name
        cmd = config.bash_path
    end

    -- 调试信息
    print("=== Script Execution Debug ===")
    print("Script name: " .. script_name)
    print("Script path: " .. script_path)
    print("Command: " .. cmd)
    print("Working directory: " .. config.scripts_dir)

    -- 检查文件是否存在
    local file_exists = hs.fs.attributes(script_path, "mode")
    print("File exists: " .. tostring(file_exists ~= nil))
    if file_exists then
        print("File mode: " .. file_exists)
    end

    -- 构建参数列表
    local arguments = { script_path }
    if args then
        for _, arg in ipairs(args) do
            table.insert(arguments, arg)
        end
    end

    -- 打印完整命令
    local full_cmd = cmd .. " " .. table.concat(arguments, " ")
    print("Full command: " .. full_cmd)
    print("==============================")

    -- 执行任务，设置工作目录为scripts_ray目录
    local task = hs.task.new(cmd, function(exit_code, stdout, stderr)
        if callback then
            callback(exit_code, stdout, stderr)
        else
            -- 默认处理
            if exit_code == 0 then
                hs.notify.new({
                    title = "脚本执行成功",
                    informativeText = script_name .. " 执行完成",
                    withdrawAfter = 3
                }):send()
            else
                hs.notify.new({
                    title = "脚本执行失败",
                    informativeText = stderr or "未知错误: " .. tostring(exit_code),
                    withdrawAfter = 5
                }):send()
                print("Error executing script: " .. script_name)
                print("Exit code: " .. tostring(exit_code))
                print("Stderr: " .. tostring(stderr))
            end
        end
    end, arguments)

    -- 设置工作目录
    task:setWorkingDirectory(config.scripts_dir)

    return task:start()
end

-- 获取当前选中的文件
local function get_selected_files()
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
        -- 确保result是字符串类型
        local result_str = tostring(result)
        if result_str and result_str ~= "" then
            for file in result_str:gmatch("[^\r\n]+") do
                local trimmed = file:gsub("^%s*(.-)%s*$", "%1") -- trim
                if trimmed ~= "" then
                    table.insert(files, trimmed)
                end
            end
        end
        return files
    else
        print("Failed to get selected files from Finder")
        return {}
    end
end

-- 文件转换功能
scripts_caller.convert = {
    -- CSV转换
    csv_to_txt = function(files, callback)
        files = files or get_selected_files()
        for _, file in ipairs(files) do
            execute_script(config.scripts.convert_csv_to_txt, { file }, callback)
        end
    end,

    csv_to_xlsx = function(files, callback)
        files = files or get_selected_files()
        for _, file in ipairs(files) do
            execute_script(config.scripts.convert_csv_to_xlsx, { file }, callback)
        end
    end,

    txt_to_csv = function(files, callback)
        files = files or get_selected_files()
        for _, file in ipairs(files) do
            execute_script(config.scripts.convert_txt_to_csv, { file }, callback)
        end
    end,

    xlsx_to_csv = function(files, callback)
        files = files or get_selected_files()
        for _, file in ipairs(files) do
            execute_script(config.scripts.convert_xlsx_to_csv, { file }, callback)
        end
    end,

    -- 文档转换
    docx_to_md = function(files, callback)
        files = files or get_selected_files()
        for _, file in ipairs(files) do
            execute_script(config.scripts.convert_docx_to_md, { file }, callback)
        end
    end,

    pptx_to_md = function(files, callback)
        files = files or get_selected_files()
        for _, file in ipairs(files) do
            execute_script(config.scripts.convert_pptx_to_md, { file }, callback)
        end
    end,

    -- 批量转换
    office_batch = function(options, callback)
        local args = {}
        if options and options.all then table.insert(args, "-a") end
        if options and options.recursive then table.insert(args, "-r") end
        if options and options.doc then table.insert(args, "-d") end
        if options and options.excel then table.insert(args, "-x") end
        if options and options.ppt then table.insert(args, "-p") end

        execute_script(config.scripts.convert_office_batch, args, callback)
    end
}

-- 内容提取功能
scripts_caller.extract = {
    images = function(files, callback)
        files = files or get_selected_files()
        if #files == 0 then
            execute_script(config.scripts.extract_images_office, {}, callback)
        else
            for _, file in ipairs(files) do
                execute_script(config.scripts.extract_images_office, { file }, callback)
            end
        end
    end,

    tables = function(files, callback)
        files = files or get_selected_files()
        if #files == 0 then
            execute_script(config.scripts.extract_tables_office, {}, callback)
        else
            for _, file in ipairs(files) do
                execute_script(config.scripts.extract_tables_office, { file }, callback)
            end
        end
    end,

    text_tokens = function(files, callback)
        files = files or get_selected_files()
        for _, file in ipairs(files) do
            execute_script(config.scripts.extract_text_tokens, { file }, callback)
        end
    end
}

-- 文件管理功能
scripts_caller.file = {
    move_up_level = function(callback)
        execute_script(config.scripts.file_move_up_level, {}, callback)
    end
}

-- 合并功能
scripts_caller.merge = {
    csv_files = function(callback)
        execute_script(config.scripts.merge_csv_files, {}, callback)
    end,

    markdown_files = function(callback)
        execute_script(config.scripts.merge_markdown_files, {}, callback)
    end
}

-- 管理功能
scripts_caller.manage = {
    launch_apps = function(callback)
        execute_script(config.scripts.manage_app_launcher, {}, callback)
    end,

    pip_packages = function(callback)
        execute_script(config.scripts.manage_pip_packages, {}, callback)
    end
}

-- 工具函数
scripts_caller.utils = {
    get_selected_files = get_selected_files,
    execute_script = execute_script
}

return scripts_caller
