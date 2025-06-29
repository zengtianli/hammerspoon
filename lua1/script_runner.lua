local utils = require("lua1.common_utils")

-- 脚本运行器模块
local script_runner = {}

-- 配置
local config = {
    python_path = "/Users/tianli/miniforge3/bin/python3",
    temp_dir = os.getenv("HOME") .. "/.hammerspoon_temp"
}

-- 创建任务执行器
local python_executor = utils.create_task_executor(config.python_path)
local bash_executor = utils.create_task_executor("/bin/bash")

-- 单个脚本运行
script_runner.run_single = function()
    local file = utils.get_selected_single_file()
    if not file then return hs.alert.show("❌ 没有在Finder中选择文件") end
    if not utils.is_executable_script(file) then return hs.alert.show("❌ 选中的文件不是shell脚本或python文件") end

    hs.alert.show("🚀 正在运行 " .. hs.fs.displayName(file))
    utils.make_executable(file)

    local script_dir = utils.get_file_directory(file)
    local cmd = utils.get_file_extension(file) == "py" and config.python_path or "/bin/bash"

    hs.task.new(cmd, function(exit_code, stdout, stderr)
        local filename = hs.fs.displayName(file)
        if exit_code == 0 then
            utils.show_success_notification("脚本执行成功", "✅ " .. filename)
            if stdout and stdout ~= "" then utils.debug_print(filename .. " 输出", stdout) end
        else
            utils.show_error_notification("脚本执行失败", "❌ " .. filename .. " (退出码: " .. exit_code .. ")")
            utils.debug_print(filename .. " 错误", { stderr = stderr, stdout = stdout, exit_code = exit_code })
        end
    end, { file }):setWorkingDirectory(script_dir):start()
end

-- 并行脚本运行
script_runner.run_parallel = function()
    local files = utils.get_selected_multiple_files()
    if #files == 0 then return hs.alert.show("❌ 没有在Finder中选择文件") end

    local executable_files = {}
    for _, file in ipairs(files) do
        if utils.is_executable_script(file) then table.insert(executable_files, file) end
    end

    if #executable_files == 0 then return hs.alert.show("❌ 选中的文件中没有可执行的脚本") end

    hs.alert.show(string.format("🚀 开始并行运行 %d 个脚本...", #executable_files))
    utils.ensure_directory(config.temp_dir)

    local tasks = {}
    for _, file in ipairs(executable_files) do
        utils.make_executable(file)
        local script_dir = utils.get_file_directory(file)
        local executor = utils.get_file_extension(file) == "py" and python_executor or bash_executor

        table.insert(tasks, function()
            return executor({ file }, script_dir)
        end)
    end

    utils.execute_task_with_stats(tasks, "并行脚本执行")
end

-- 快速Python脚本执行
script_runner.run_python_here = function()
    local current_dir = utils.get_finder_current_dir()

    hs.dialog.textPrompt("Python 脚本执行", "请输入要执行的Python代码:", "", "执行", "取消", function(text)
        if text then
            local temp_file = config.temp_dir .. "/temp_script.py"
            utils.ensure_directory(config.temp_dir)

            local file = io.open(temp_file, "w")
            if file then
                file:write(text)
                file:close()

                hs.alert.show("🐍 执行Python代码...")

                hs.task.new(config.python_path, function(exit_code, stdout, stderr)
                    if exit_code == 0 then
                        utils.show_success_notification("Python代码执行成功", "✅ 代码执行完成")
                        if stdout and stdout ~= "" then utils.debug_print("Python输出", stdout) end
                    else
                        utils.show_error_notification("Python代码执行失败", "❌ 退出码: " .. exit_code)
                        utils.debug_print("Python错误", { stderr = stderr, stdout = stdout, exit_code = exit_code })
                    end
                    os.remove(temp_file)
                end, { temp_file }):setWorkingDirectory(current_dir):start()
            else
                hs.alert.show("❌ 无法创建临时文件")
            end
        end
    end)
end

print("🏃 Script Runner 模块已加载")
return script_runner
