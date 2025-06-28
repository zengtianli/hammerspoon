local script_runner = {}

-- ===== 配置 =====
local config = {
    python_path = "/Users/tianli/miniforge3/bin/python3",
    miniforge_bin = "/Users/tianli/miniforge3/bin",
    temp_dir = os.getenv("HOME") .. "/.hammerspoon_temp"
}

-- ===== 通用函数 =====

-- 获取当前选中的单个文件
local function get_selected_single_file()
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
        -- 按逗号分割文件路径（和原Raycast脚本一致）
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

-- 检查文件是否为可执行脚本
local function is_executable_script(file_path)
    local ext = file_path:match("%.([^%.]+)$")
    return ext and (ext:lower() == "sh" or ext:lower() == "py")
end

-- 确保临时目录存在
local function ensure_temp_dir()
    local ok = hs.fs.mkdir(config.temp_dir)
    return config.temp_dir
end

-- 设置脚本执行权限
local function make_executable(file_path)
    if file_path:match("%.sh$") then
        hs.task.new("/bin/chmod", nil, { "+x", file_path }):start()
    end
end

-- ===== 单个脚本运行 =====

script_runner.run_single = function()
    local selected_file = get_selected_single_file()

    if not selected_file then
        hs.alert.show("❌ 没有在Finder中选择文件")
        return
    end

    if not is_executable_script(selected_file) then
        hs.alert.show("❌ 选中的文件不是shell脚本或python文件")
        return
    end

    hs.alert.show("🚀 正在运行 " .. hs.fs.displayName(selected_file))

    -- 确保脚本有执行权限
    make_executable(selected_file)

    -- 获取脚本目录
    local script_dir = selected_file:match("(.*/)")
    local file_ext = selected_file:match("%.([^%.]+)$"):lower()

    -- 构建执行命令
    local cmd, args
    if file_ext == "py" then
        cmd = config.python_path
        args = { selected_file }
    else
        cmd = "/bin/bash"
        args = { selected_file }
    end

    -- 创建并执行任务
    local task = hs.task.new(cmd, function(exit_code, stdout, stderr)
        local filename = hs.fs.displayName(selected_file)

        if exit_code == 0 then
            -- 成功
            hs.notify.new({
                title = "脚本执行成功",
                informativeText = "✅ " .. filename,
                withdrawAfter = 3
            }):send()

            -- 如果有输出，显示在控制台
            if stdout and stdout ~= "" then
                print("=== " .. filename .. " 输出 ===")
                print(stdout)
                print("=== 输出结束 ===")
            end
        else
            -- 失败
            hs.notify.new({
                title = "脚本执行失败",
                informativeText = "❌ " .. filename .. " (退出码: " .. exit_code .. ")",
                withdrawAfter = 5
            }):send()

            -- 显示错误信息
            print("=== " .. filename .. " 错误 ===")
            if stderr and stderr ~= "" then
                print("错误输出:")
                print(stderr)
            end
            if stdout and stdout ~= "" then
                print("标准输出:")
                print(stdout)
            end
            print("=== 错误结束 ===")
        end
    end, args)

    -- 设置工作目录
    if script_dir then
        task:setWorkingDirectory(script_dir)
    end

    task:start()
end

-- ===== 并行脚本运行 =====

script_runner.run_parallel = function()
    local selected_files = get_selected_multiple_files()

    print("=== 并行运行调试信息 ===")
    print("选中文件数量: " .. #selected_files)
    for i, file in ipairs(selected_files) do
        print("文件" .. i .. ": " .. file)
    end
    print("========================")

    if #selected_files == 0 then
        hs.alert.show("❌ 没有在Finder中选择文件")
        return
    end

    -- 筛选出可执行脚本
    local executable_files = {}
    for _, file in ipairs(selected_files) do
        if is_executable_script(file) then
            table.insert(executable_files, file)
        end
    end

    if #executable_files == 0 then
        hs.alert.show("❌ 选中的文件中没有可执行的脚本")
        return
    end

    hs.alert.show(string.format("🚀 开始并行运行 %d 个脚本...", #executable_files))

    -- 确保临时目录存在
    local temp_dir = ensure_temp_dir()

    -- 运行结果统计
    local total_count = #executable_files
    local completed_count = 0
    local success_count = 0
    local results = {}

    -- 处理单个脚本完成的回调
    local function on_script_complete(file_path, exit_code, stdout, stderr)
        completed_count = completed_count + 1
        local filename = hs.fs.displayName(file_path)

        if exit_code == 0 then
            success_count = success_count + 1
        end

        -- 保存结果
        results[file_path] = {
            filename = filename,
            exit_code = exit_code,
            stdout = stdout,
            stderr = stderr
        }

        print(string.format("📋 [%d/%d] %s %s",
            completed_count, total_count,
            exit_code == 0 and "✅" or "❌",
            filename
        ))

        -- 所有脚本完成后显示总结
        if completed_count == total_count then
            hs.notify.new({
                title = "并行脚本执行完成",
                informativeText = string.format("完成 %d/%d，成功 %d 个",
                    completed_count, total_count, success_count),
                withdrawAfter = 5
            }):send()

            -- 详细结果输出
            print("\n📊 === 并行运行结果总结 ===")
            for file_path, result in pairs(results) do
                print(string.format("%s %s",
                    result.exit_code == 0 and "✅" or "❌",
                    result.filename
                ))

                if result.stdout and result.stdout ~= "" then
                    print("  输出: " .. result.stdout:gsub("\n", "\n  "))
                end

                if result.exit_code ~= 0 and result.stderr and result.stderr ~= "" then
                    print("  错误: " .. result.stderr:gsub("\n", "\n  "))
                end
                print("  " .. string.rep("-", 40))
            end
            print("=== 总结结束 ===\n")
        end
    end

    -- 启动所有脚本
    for _, file_path in ipairs(executable_files) do
        -- 确保脚本有执行权限
        make_executable(file_path)

        local script_dir = file_path:match("(.*/)")
        local file_ext = file_path:match("%.([^%.]+)$"):lower()

        -- 构建执行命令
        local cmd, args
        if file_ext == "py" then
            cmd = config.python_path
            args = { file_path }
        else
            cmd = "/bin/bash"
            args = { file_path }
        end

        -- 创建并执行任务
        local task = hs.task.new(cmd, function(exit_code, stdout, stderr)
            on_script_complete(file_path, exit_code, stdout, stderr)
        end, args)

        -- 设置工作目录
        if script_dir then
            task:setWorkingDirectory(script_dir)
        end

        task:start()
    end
end

-- ===== 快速Python脚本执行 =====

script_runner.run_python_here = function()
    -- 创建一个临时Python文件并在当前目录执行
    local current_dir = get_finder_current_dir() or os.getenv("HOME")

    hs.dialog.textPrompt("Python 脚本执行", "请输入要执行的Python代码:", "", "执行", "取消", function(text)
        if text then
            -- 创建临时文件
            local temp_file = config.temp_dir .. "/temp_script.py"
            ensure_temp_dir()

            local file = io.open(temp_file, "w")
            if file then
                file:write(text)
                file:close()

                hs.alert.show("🐍 执行Python代码...")

                local task = hs.task.new(config.python_path, function(exit_code, stdout, stderr)
                    if exit_code == 0 then
                        hs.notify.new({
                            title = "Python代码执行成功",
                            informativeText = "✅ 代码执行完成",
                            withdrawAfter = 3
                        }):send()

                        if stdout and stdout ~= "" then
                            print("=== Python输出 ===")
                            print(stdout)
                            print("=== 输出结束 ===")
                        end
                    else
                        hs.notify.new({
                            title = "Python代码执行失败",
                            informativeText = "❌ 退出码: " .. exit_code,
                            withdrawAfter = 5
                        }):send()

                        print("=== Python错误 ===")
                        if stderr then print("错误: " .. stderr) end
                        if stdout then print("输出: " .. stdout) end
                        print("=== 错误结束 ===")
                    end

                    -- 清理临时文件
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

-- 获取Finder当前目录的辅助函数
function get_finder_current_dir()
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
        return result:gsub("%s+$", "")
    else
        return os.getenv("HOME")
    end
end

print("🏃 Script Runner 模块已加载")

return script_runner
