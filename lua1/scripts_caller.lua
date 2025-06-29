local utils = require("lua1.common_utils")

-- 配置
local config = {
    python_path = "/Users/tianli/miniforge3/bin/python3",
    bash_path = "/bin/bash",
    scripts_dir = hs.configdir .. "/scripts_ray",
}

-- 脚本映射表
local scripts = {
    convert_csv_to_txt = "convert_csv_to_txt.py",
    convert_csv_to_xlsx = "convert_csv_to_xlsx.py",
    convert_txt_to_csv = "convert_txt_to_csv.py",
    convert_txt_to_xlsx = "convert_txt_to_xlsx.py",
    convert_xlsx_to_csv = "convert_xlsx_to_csv.py",
    convert_xlsx_to_txt = "convert_xlsx_to_txt.py",
    convert_docx_to_md = "convert_docx_to_md.sh",
    convert_office_batch = "convert_office_batch.sh",
    convert_pptx_to_md = "convert_pptx_to_md.py",
    extract_images_office = "extract_images_office.py",
    extract_tables_office = "extract_tables_office.py",
    extract_text_tokens = "extract_text_tokens.py",
    manage_app_launcher = "manage_app_launcher.sh",
    manage_pip_packages = "manage_pip_packages.sh",
    file_move_up_level = "file_move_up_level.sh",
    merge_csv_files = "merge_csv_files.sh",
    merge_markdown_files = "merge_markdown_files.sh"
}

-- 通用执行函数
local function execute_script(script_name, args, callback)
    local script_path = config.scripts_dir .. "/" .. scripts[script_name]
    local cmd = script_path:match("%.py$") and config.python_path or config.bash_path
    local arguments = { script_path }

    if args then for _, arg in ipairs(args) do table.insert(arguments, arg) end end

    utils.debug_print("Script Execution",
        { script_name, script_path, cmd, file_exists = hs.fs.attributes(script_path, "mode") ~= nil })

    hs.task.new(cmd, function(exit_code, stdout, stderr)
        if callback then
            callback(exit_code, stdout, stderr)
        elseif exit_code == 0 then
            utils.show_success_notification("脚本执行成功", script_name .. " 执行完成")
        else
            utils.show_error_notification("脚本执行失败", stderr or "未知错误: " .. exit_code)
            utils.log("SCRIPTS_CALLER",
                "Error: " .. script_name .. " Exit: " .. exit_code .. " Stderr: " .. (stderr or ""))
        end
    end, arguments):setWorkingDirectory(config.scripts_dir):start()
end

-- 通用文件处理函数
local function process_files(script_name, files, callback)
    files = files or utils.get_selected_files_newline()
    for _, file in ipairs(files) do execute_script(script_name, { file }, callback) end
end

-- 批量提取函数（支持无文件参数）
local function extract_batch(script_name, files, callback)
    files = files or utils.get_selected_files_newline()
    if #files == 0 then
        execute_script(script_name, {}, callback)
    else
        for _, file in ipairs(files) do execute_script(script_name, { file }, callback) end
    end
end

-- 导出模块
return {
    convert = {
        csv_to_txt = function(files, cb) process_files("convert_csv_to_txt", files, cb) end,
        csv_to_xlsx = function(files, cb) process_files("convert_csv_to_xlsx", files, cb) end,
        txt_to_csv = function(files, cb) process_files("convert_txt_to_csv", files, cb) end,
        txt_to_xlsx = function(files, cb) process_files("convert_txt_to_xlsx", files, cb) end,
        xlsx_to_csv = function(files, cb) process_files("convert_xlsx_to_csv", files, cb) end,
        xlsx_to_txt = function(files, cb) process_files("convert_xlsx_to_txt", files, cb) end,
        docx_to_md = function(files, cb) process_files("convert_docx_to_md", files, cb) end,
        pptx_to_md = function(files, cb) process_files("convert_pptx_to_md", files, cb) end,
        office_batch = function(options, callback)
            local args = {}
            if options then
                for flag, opt in pairs({ all = "-a", recursive = "-r", doc = "-d", excel = "-x", ppt = "-p" }) do
                    if options[flag] then table.insert(args, opt) end
                end
            end
            execute_script("convert_office_batch", args, callback)
        end
    },

    extract = {
        images = function(files, cb) extract_batch("extract_images_office", files, cb) end,
        tables = function(files, cb) extract_batch("extract_tables_office", files, cb) end,
        text_tokens = function(files, cb) process_files("extract_text_tokens", files, cb) end,
    },

    file = {
        move_up_level = function(cb) execute_script("file_move_up_level", {}, cb) end
    },

    merge = {
        csv_files = function(cb) execute_script("merge_csv_files", {}, cb) end,
        markdown_files = function(cb) execute_script("merge_markdown_files", {}, cb) end,
    },

    manage = {
        launch_apps = function(cb) execute_script("manage_app_launcher", {}, cb) end,
        pip_packages = function(cb) execute_script("manage_pip_packages", {}, cb) end,
    },

    utils = {
        get_selected_files = utils.get_selected_files_newline,
        execute_script = execute_script
    }
}
