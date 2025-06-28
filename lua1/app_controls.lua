local app_controls = {}

-- ===== 通用函数 =====

-- 获取当前 Finder 目录或选中项目的目录
local function get_finder_current_dir()
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
        return result:gsub("%s+$", "") -- 去除末尾空白
    else
        return os.getenv("HOME")       -- fallback to home directory
    end
end

-- 在 Ghostty 中执行命令
local function run_in_ghostty(command)
    local ghostty_app = hs.application.find("Ghostty")

    if not ghostty_app then
        hs.application.open("Ghostty")
        hs.timer.doAfter(1, function()
            run_in_ghostty(command)
        end)
        return
    end

    -- 激活 Ghostty
    ghostty_app:activate()

    hs.timer.doAfter(0.2, function()
        -- 创建新标签页
        hs.eventtap.keyStroke({ "cmd" }, "n")

        hs.timer.doAfter(0.3, function()
            -- 将命令复制到剪贴板并粘贴
            local old_clipboard = hs.pasteboard.getContents()
            hs.pasteboard.setContents(command)

            hs.timer.doAfter(0.1, function()
                hs.eventtap.keyStroke({ "cmd" }, "v")
                hs.timer.doAfter(0.1, function()
                    hs.eventtap.keyStroke({}, "return")
                    -- 恢复原剪贴板内容
                    if old_clipboard then
                        hs.timer.doAfter(0.1, function()
                            hs.pasteboard.setContents(old_clipboard)
                        end)
                    end
                end)
            end)
        end)
    end)
end

-- 在 Terminal 中执行命令
local function run_in_terminal(command)
    local terminal_app = hs.application.find("Terminal")

    if not terminal_app then
        hs.application.open("Terminal")
        hs.timer.doAfter(1, function()
            run_in_terminal(command)
        end)
        return
    end

    terminal_app:activate()

    hs.timer.doAfter(0.2, function()
        -- 创建新标签页
        hs.eventtap.keyStroke({ "cmd" }, "t")

        hs.timer.doAfter(0.3, function()
            local old_clipboard = hs.pasteboard.getContents()
            hs.pasteboard.setContents(command)

            hs.timer.doAfter(0.1, function()
                hs.eventtap.keyStroke({ "cmd" }, "v")
                hs.timer.doAfter(0.1, function()
                    hs.eventtap.keyStroke({}, "return")
                    if old_clipboard then
                        hs.timer.doAfter(0.1, function()
                            hs.pasteboard.setContents(old_clipboard)
                        end)
                    end
                end)
            end)
        end)
    end)
end

-- ===== 导出的应用控制功能 =====

-- 在 Ghostty 中打开当前 Finder 目录
app_controls.open_ghostty_here = function()
    local current_dir = get_finder_current_dir()
    local command = string.format('cd "%s"', current_dir)

    run_in_ghostty(command)

    -- 显示通知
    hs.notify.new({
        title = "Ghostty",
        informativeText = "已在 " .. hs.fs.displayName(current_dir) .. " 中打开",
        withdrawAfter = 3
    }):send()
end

-- 在 Terminal 中打开当前 Finder 目录
app_controls.open_terminal_here = function()
    local current_dir = get_finder_current_dir()
    local command = string.format('cd "%s"', current_dir)

    run_in_terminal(command)

    hs.notify.new({
        title = "Terminal",
        informativeText = "已在 " .. hs.fs.displayName(current_dir) .. " 中打开",
        withdrawAfter = 3
    }):send()
end

-- 在 VS Code 中打开当前 Finder 目录
app_controls.open_vscode_here = function()
    local current_dir = get_finder_current_dir()

    hs.task.new("/usr/local/bin/code", function(exit_code, stdout, stderr)
        if exit_code == 0 then
            hs.notify.new({
                title = "VS Code",
                informativeText = "已在 " .. hs.fs.displayName(current_dir) .. " 中打开",
                withdrawAfter = 3
            }):send()
        else
            -- 尝试备用路径
            hs.task.new("/opt/homebrew/bin/code", function(exit_code2, stdout2, stderr2)
                if exit_code2 == 0 then
                    hs.notify.new({
                        title = "VS Code",
                        informativeText = "已在 " .. hs.fs.displayName(current_dir) .. " 中打开",
                        withdrawAfter = 3
                    }):send()
                else
                    hs.notify.new({
                        title = "VS Code",
                        informativeText = "未找到 code 命令，请确保 VS Code 已安装",
                        withdrawAfter = 5
                    }):send()
                end
            end, { current_dir }):start()
        end
    end, { current_dir }):start()
end

-- 在 Cursor 中打开当前 Finder 目录
app_controls.open_cursor_here = function()
    local current_dir = get_finder_current_dir()

    hs.task.new("/usr/local/bin/cursor", function(exit_code, stdout, stderr)
        if exit_code == 0 then
            hs.notify.new({
                title = "Cursor",
                informativeText = "已在 " .. hs.fs.displayName(current_dir) .. " 中打开",
                withdrawAfter = 3
            }):send()
        else
            -- 尝试通过应用程序包启动
            hs.application.open("Cursor")
            hs.notify.new({
                title = "Cursor",
                informativeText = "已启动 Cursor（请手动打开目录）",
                withdrawAfter = 3
            }):send()
        end
    end, { current_dir }):start()
end

-- 获取选中的单个文件
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

-- 在 Ghostty 中用 nvim 打开选中的文件
app_controls.open_file_in_nvim_ghostty = function()
    local selected_file = get_selected_single_file()

    if not selected_file then
        hs.alert.show("❌ 没有在Finder中选择文件")
        return
    end

    -- 获取文件目录
    local file_dir = selected_file:match("(.*/)")
    if not file_dir then
        file_dir = "."
    end

    -- 构建命令：cd 到文件目录并用 nvim 打开文件
    local command = string.format('cd "%s" && nvim "%s"', file_dir, selected_file)

    run_in_ghostty(command)

    -- 显示通知
    hs.notify.new({
        title = "Nvim in Ghostty",
        informativeText = "已在 Ghostty 中用 Nvim 打开 " .. hs.fs.displayName(selected_file),
        withdrawAfter = 3
    }):send()
end

-- 在当前 Finder 位置创建新文件夹
app_controls.create_folder = function()
    local current_dir = get_finder_current_dir()

    if not current_dir then
        hs.alert.show("❌ 无法获取当前 Finder 目录")
        return
    end

    -- 设置默认文件夹名称
    local base_name = "untitled folder"
    local new_folder_name = base_name
    local counter = 2

    -- 如果文件夹已存在，自动添加序号
    while hs.fs.attributes(current_dir .. "/" .. new_folder_name, "mode") do
        new_folder_name = base_name .. " " .. counter
        counter = counter + 1
    end

    -- 构建新文件夹的完整路径
    local new_folder_path = current_dir .. "/" .. new_folder_name

    -- 创建新文件夹
    local success = hs.fs.mkdir(new_folder_path)

    if success then
        -- 记录当前窗口，创建文件夹，然后回到原窗口
        local script = string.format([[
            tell application "Finder"
                activate
                -- 记录当前活跃窗口
                set originalWindow to front window
                -- 短暂选中新创建的文件夹
                select POSIX file "%s"
                delay 0.1
                -- 回到原来的窗口
                set index of originalWindow to 1
            end tell
        ]], new_folder_path)

        hs.osascript.applescript(script)

        -- 显示成功通知
        hs.notify.new({
            title = "文件夹创建成功",
            informativeText = "已在当前位置创建文件夹 \"" .. new_folder_name .. "\"",
            withdrawAfter = 3
        }):send()
    else
        hs.alert.show("❌ 创建文件夹失败")
    end
end

-- 通用函数，供其他模块使用
app_controls.utils = {
    get_finder_current_dir = get_finder_current_dir,
    get_selected_single_file = get_selected_single_file,
    run_in_ghostty = run_in_ghostty,
    run_in_terminal = run_in_terminal
}

print("📱 App Controls 模块已加载")

return app_controls
