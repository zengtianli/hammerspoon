local utils = require("lua1.common_utils")

-- 配置和脚本映射
local config = {
    python_path = "/Users/tianli/miniforge3/bin/python3",
    bash_path = "/bin/bash",
    scripts_dir = hs
        .configdir .. "/scripts_ray"
}
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

    hs.task.new(cmd, callback or function(exit_code, stdout, stderr)
        if exit_code == 0 then
            utils.show_success_notification("脚本执行成功", script_name .. " 执行完成")
        else
            utils.show_error_notification("脚本执行失败", stderr or "未知错误: " .. exit_code)
        end
    end, arguments):setWorkingDirectory(config.scripts_dir):start()
end

-- 创建函数生成器
local function create_converter(script_name)
    return function(files, cb)
        files = files or utils.get_selected_files_newline()
        for _, file in ipairs(files) do execute_script(script_name, { file }, cb) end
    end
end

local function create_extractor(script_name)
    return function(files, cb)
        files = files or utils.get_selected_files_newline()
        if #files == 0 then
            execute_script(script_name, {}, cb)
        else
            for _, file in ipairs(files) do execute_script(script_name, { file }, cb) end
        end
    end
end

local function create_manager(script_name) return function(cb) execute_script(script_name, {}, cb) end end

-- 导出模块
return {
    convert = {
        csv_to_txt = create_converter("convert_csv_to_txt"),
        csv_to_xlsx = create_converter("convert_csv_to_xlsx"),
        txt_to_csv = create_converter("convert_txt_to_csv"),
        txt_to_xlsx = create_converter("convert_txt_to_xlsx"),
        xlsx_to_csv = create_converter("convert_xlsx_to_csv"),
        xlsx_to_txt = create_converter("convert_xlsx_to_txt"),
        docx_to_md = create_converter("convert_docx_to_md"),
        pptx_to_md = create_converter("convert_pptx_to_md"),
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
        images = create_extractor("extract_images_office"),
        tables = create_extractor("extract_tables_office"),
        text_tokens = create_converter("extract_text_tokens")
    },
    file = { move_up_level = create_manager("file_move_up_level") },
    merge = { csv_files = create_manager("merge_csv_files"), markdown_files = create_manager("merge_markdown_files") },
    manage = { launch_apps = create_manager("manage_app_launcher"), pip_packages = create_manager("manage_pip_packages") },
    utils = { get_selected_files = utils.get_selected_files_newline, execute_script = execute_script }
}
