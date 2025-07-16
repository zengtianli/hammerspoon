-- 脚本运行器模块
local utils = require("modules.core.utils")

local M = {}

-- 配置
local config = {
    python_path = "/Users/tianli/miniforge3/bin/python3",
    temp_dir = os.getenv("HOME") .. "/.hammerspoon_temp"
}

-- 单个脚本运行
M.run_single = function()
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
M.run_parallel = function()
    local files = utils.get_selected_multiple_files()
    if #files == 0 then return hs.alert.show("❌ 没有在Finder中选择文件") end

    local executable_files = {}
    for _, file in ipairs(files) do
        if utils.is_executable_script(file) then table.insert(executable_files, file) end
    end

    if #executable_files == 0 then return hs.alert.show("❌ 选中的文件中没有可执行的脚本") end

    hs.alert.show(string.format("🚀 开始并行运行 %d 个脚本...", #executable_files))
    utils.ensure_directory(config.temp_dir)

    local completed_count = 0
    local success_count = 0

    for _, file in ipairs(executable_files) do
        utils.make_executable(file)
        local script_dir = utils.get_file_directory(file)
        local cmd = utils.get_file_extension(file) == "py" and config.python_path or "/bin/bash"

        hs.task.new(cmd, function(exit_code, stdout, stderr)
            completed_count = completed_count + 1
            if exit_code == 0 then
                success_count = success_count + 1
            end

            -- 所有脚本完成后显示结果
            if completed_count == #executable_files then
                local msg = string.format("并行执行完成: %d/%d 成功", success_count, #executable_files)
                utils.show_success_notification("脚本执行完成", msg)
            end
        end, { file }):setWorkingDirectory(script_dir):start()
    end
end

print("🏃 脚本执行器模块已加载")
return M
