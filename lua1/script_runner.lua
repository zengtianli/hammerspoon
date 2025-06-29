local script_runner = {}
local utils = require("lua1.common_utils")

-- ===== 配置 =====
local config = {
    python_path = "/Users/tianli/miniforge3/bin/python3",
    miniforge_bin = "/Users/tianli/miniforge3/bin",
    temp_dir = os.getenv("HOME") .. "/.hammerspoon_temp"
}

-- ===== 单个脚本运行 =====

script_runner.run_single = function()
    local selected_file = utils.get_selected_single_file()

    if not selected_file then
        hs.alert.show("❌ 没有在Finder中选择文件")
        return
    end

    if not utils.is_executable_script(selected_file) then
        hs.alert.show("❌ 选中的文件不是shell脚本或python文件")
        return
    end

    hs.alert.show("🚀 正在运行 " .. hs.fs.displayName(selected_file))

    utils.make_executable(selected_file)

    local script_dir = utils.get_file_directory(selected_file)
    local file_ext = utils.get_file_extension(selected_file)

    local cmd, args
    if file_ext and file_ext:lower() == "py" then
        cmd = config.python_path
        args = { selected_file }
    else
        cmd = "/bin/bash"
        args = { selected_file }
    end

    local task = hs.task.new(cmd, function(exit_code, stdout, stderr)
        local filename = hs.fs.displayName(selected_file)

        if exit_code == 0 then
            utils.show_success_notification("脚本执行成功", "✅ " .. filename)
            if stdout and stdout ~= "" then
                utils.debug_print(filename .. " 输出", stdout)
            end
        else
            utils.show_error_notification("脚本执行失败", "❌ " .. filename .. " (退出码: " .. exit_code .. ")")
            utils.debug_print(filename .. " 错误", {
                stderr = stderr,
                stdout = stdout,
                exit_code = exit_code
            })
        end
    end, args)

    if script_dir then
        task:setWorkingDirectory(script_dir)
    end
    task:start()
end

-- ===== 并行脚本运行 =====

script_runner.run_parallel = function()
    local selected_files = utils.get_selected_multiple_files()

    utils.debug_print("并行运行调试信息", {
        count = #selected_files,
        files = selected_files
    })

    if #selected_files == 0 then
        hs.alert.show("❌ 没有在Finder中选择文件")
        return
    end

    local executable_files = {}
    for _, file in ipairs(selected_files) do
        if utils.is_executable_script(file) then
            table.insert(executable_files, file)
        end
    end

    if #executable_files == 0 then
        hs.alert.show("❌ 选中的文件中没有可执行的脚本")
        return
    end

    hs.alert.show(string.format("🚀 开始并行运行 %d 个脚本...", #executable_files))

    utils.ensure_directory(config.temp_dir)

    local total_count = #executable_files
    local completed_count = 0
    local success_count = 0
    local results = {}

    local function on_script_complete(file_path, exit_code, stdout, stderr)
        completed_count = completed_count + 1
        local filename = hs.fs.displayName(file_path)

        if exit_code == 0 then
            success_count = success_count + 1
        end

        results[file_path] = {
            filename = filename,
            exit_code = exit_code,
            stdout = stdout,
            stderr = stderr
        }

        utils.log("SCRIPT_RUNNER", string.format("[%d/%d] %s %s",
            completed_count, total_count,
            exit_code == 0 and "✅" or "❌",
            filename))

        if completed_count == total_count then
            utils.show_success_notification("并行脚本执行完成",
                string.format("完成 %d/%d，成功 %d 个", completed_count, total_count, success_count))

            -- 详细结果输出
            local summary = {}
            for file_path, result in pairs(results) do
                table.insert(summary, {
                    status = result.exit_code == 0 and "✅" or "❌",
                    filename = result.filename,
                    stdout = result.stdout,
                    stderr = result.stderr
                })
            end
            utils.debug_print("并行运行结果总结", summary)
        end
    end

    for _, file_path in ipairs(executable_files) do
        utils.make_executable(file_path)

        local script_dir = utils.get_file_directory(file_path)
        local file_ext = utils.get_file_extension(file_path)

        local cmd, args
        if file_ext and file_ext:lower() == "py" then
            cmd = config.python_path
            args = { file_path }
        else
            cmd = "/bin/bash"
            args = { file_path }
        end

        local task = hs.task.new(cmd, function(exit_code, stdout, stderr)
            on_script_complete(file_path, exit_code, stdout, stderr)
        end, args)

        if script_dir then
            task:setWorkingDirectory(script_dir)
        end
        task:start()
    end
end

-- ===== 快速Python脚本执行 =====

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

                local task = hs.task.new(config.python_path, function(exit_code, stdout, stderr)
                    if exit_code == 0 then
                        utils.show_success_notification("Python代码执行成功", "✅ 代码执行完成")
                        if stdout and stdout ~= "" then
                            utils.debug_print("Python输出", stdout)
                        end
                    else
                        utils.show_error_notification("Python代码执行失败", "❌ 退出码: " .. exit_code)
                        utils.debug_print("Python错误", {
                            stderr = stderr,
                            stdout = stdout,
                            exit_code = exit_code
                        })
                    end
                    os.remove(temp_file)
                end, { temp_file })

                task:setWorkingDirectory(current_dir)
                task:start()
            else
                hs.alert.show("❌ 无法创建临时文件")
            end
        end
    end)
end

print("🏃 Script Runner 模块已加载")

return script_runner
