-- 统一工具库模块
local M = {}

-- 加载配置
M.config = require("config.settings")
M.scripts_dir = M.config.scripts_dir or (hs.configdir .. "/scripts")

-- ===== 脚本执行 =====
M.scripts = {
    getPath = function(category, scriptName)
        if category then
            return M.scripts_dir .. "/" .. category .. "/" .. scriptName
        else
            return M.scripts_dir .. "/" .. scriptName
        end
    end,

    execute = function(category, scriptName, callback)
        local scriptPath = M.scripts.getPath(category, scriptName)
        if not M.fileExists(scriptPath) then
            M.showError("脚本文件不存在: " .. (category and (category .. "/") or "") .. scriptName)
            return false
        end

        local task = hs.task.new("/bin/bash", callback, { scriptPath })
        task:setWorkingDirectory(M.scripts_dir)
        task:start()
        return task
    end
}

-- ===== 通知和提示函数 =====
function M.showInfo(msg)
    hs.alert.show("ℹ️ " .. msg, 2)
end

function M.showError(msg)
    hs.alert.show("❌ " .. msg, 3)
end

function M.show_success_notification(title, message, duration)
    hs.notify.new({
        title = title,
        informativeText = message,
        withdrawAfter = duration or 3
    }):send()
end

function M.show_error_notification(title, message, duration)
    hs.notify.new({
        title = title,
        informativeText = message,
        withdrawAfter = duration or 5
    }):send()
end

-- ===== 文件系统操作 =====
function M.fileExists(path)
    return hs.fs.attributes(path) ~= nil
end

function M.get_file_extension(file_path)
    return file_path:match("%.([^%.]+)$")
end

function M.get_file_directory(file_path)
    return file_path:match("(.*/)")
end

function M.ensure_directory(dir_path)
    hs.fs.mkdir(dir_path)
    return dir_path
end

function M.make_executable(file_path)
    if file_path:match("%.sh$") then
        hs.task.new("/bin/chmod", nil, { "+x", file_path }):start()
    end
end

function M.is_executable_script(file_path)
    local ext = file_path:match("%.([^%.]+)$")
    return ext and (ext:lower() == "sh" or ext:lower() == "py")
end

-- ===== Finder 操作函数 =====
function M.get_finder_current_dir()
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

function M.get_selected_single_file()
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

function M.get_selected_multiple_files()
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
        for file in result:gmatch("[^,]+") do
            local trimmed = M.trim_string(file)
            if trimmed ~= "" then
                table.insert(files, trimmed)
            end
        end
        return files
    else
        return {}
    end
end

-- ===== 字符串处理 =====
function M.trim_string(str)
    if not str then return "" end
    return str:gsub("^%s*(.-)%s*$", "%1")
end

-- ===== 应用控制 =====
function M.ensure_app_running(app_name, startup_delay)
    local app = hs.application.find(app_name)
    if not app then
        hs.application.open(app_name)
        if startup_delay then
            hs.timer.usleep(startup_delay * 1000000) -- 转换为微秒
        end
        app = hs.application.find(app_name)
    end
    return app
end

function M.send_keystroke_to_app(app, modifiers, key, delay)
    if app then
        app:activate()
        if delay then
            hs.timer.doAfter(delay, function()
                hs.eventtap.keyStroke(modifiers, key)
            end)
        else
            hs.eventtap.keyStroke(modifiers, key)
        end
    end
end

function M.run_command_in_app(app_name, command, keystroke_sequence)
    local app = M.ensure_app_running(app_name, 1)
    if not app then
        hs.timer.doAfter(1, function() M.run_command_in_app(app_name, command, keystroke_sequence) end)
        return
    end

    app:activate()
    hs.timer.doAfter(0.2, function()
        if keystroke_sequence then
            hs.eventtap.keyStroke(keystroke_sequence[1], keystroke_sequence[2])
        end
        hs.timer.doAfter(0.3, function()
            M.safe_clipboard_operation(command, function()
                hs.eventtap.keyStroke({ "cmd" }, "v")
                hs.timer.doAfter(0.1, function()
                    hs.eventtap.keyStroke({}, "return")
                end)
            end)
        end)
    end)
end

-- ===== 剪贴板操作 =====
function M.safe_clipboard_operation(content, operation_callback)
    local old_clipboard = hs.pasteboard.getContents()
    hs.pasteboard.setContents(content)

    if operation_callback then
        hs.timer.doAfter(0.1, function()
            operation_callback()
            -- 恢复原剪贴板内容
            if old_clipboard then
                hs.timer.doAfter(0.1, function()
                    hs.pasteboard.setContents(old_clipboard)
                end)
            end
        end)
    end
end

function M.detect_clipboard_type()
    local content_types = hs.pasteboard.contentTypes()

    if not content_types or #content_types == 0 then
        return "empty"
    end

    -- 检查是否包含文件相关的类型
    for _, content_type in ipairs(content_types) do
        if content_type == "public.file-url" or
            content_type == "public.url" or
            content_type == "CorePasteboardFlavorType 0x6675726C" or
            content_type:match("file") then
            return "files"
        end
    end

    -- 检查是否有文本内容
    local clipboard_content = hs.pasteboard.getContents()
    if clipboard_content and clipboard_content ~= "" then
        return "text"
    end

    return "empty"
end

-- ===== 模块和热键管理 =====
function M.checkModule(moduleName)
    local ok, module = pcall(require, moduleName)
    if not ok then
        M.showError("模块不可用: " .. moduleName)
        return false
    end
    return true, module
end

function M.createSafeHotkey(mods, key, fn, description)
    local hotkey = hs.hotkey.new(mods, key, fn)
    if hotkey then
        hotkey:enable()
        return hotkey
    else
        M.showError("热键绑定失败: " .. (description or key))
        return nil
    end
end

function M.register_hotkeys(hotkeys_table)
    local count = 0
    for _, hk in ipairs(hotkeys_table) do
        if hk[4] then -- 确保回调函数存在
            hs.hotkey.bind(hk[1], hk[2], hk[3], hk[4])
            count = count + 1
        end
    end
    return count
end

-- ===== AppleScript 执行 =====
function M.execute_applescript(script, success_msg, error_msg)
    local ok, result = hs.osascript.applescript(script)
    if ok then
        if success_msg then M.show_success_notification("操作成功", success_msg) end
        return result
    else
        if error_msg then hs.alert.show("❌ " .. error_msg) end
        return nil
    end
end

-- ===== 调试和日志 =====
function M.log(module_name, message)
    print(string.format("[%s] %s", module_name, message))
end

function M.debug_print(title, data)
    print("=== " .. title .. " ===")
    if type(data) == "table" then
        for i, item in ipairs(data) do
            print(string.format("%d: %s", i, tostring(item)))
        end
    else
        print(tostring(data))
    end
    print("=== " .. title .. " 结束 ===")
end

-- ===== 创建标准模块 =====
function M.createAppModule(name, appName)
    local module = {
        name = name,
        appName = appName,
        config = { enabled = true },
        hotkeys = {},

        addHotkey = function(self, mods, key, fn, desc)
            local hotkey = M.createSafeHotkey(mods, key, fn, desc)
            if hotkey then
                table.insert(self.hotkeys, hotkey)
            end
            return hotkey
        end,

        init = function(self)
            if self.checkDeps and not self:checkDeps() then
                M.showError(self.name .. " 依赖检查失败")
                return false
            end
            if self.setupHotkeys then
                self:setupHotkeys()
            end
            print(self.name .. " 已加载")
            return true
        end
    }
    return module
end

-- ===== 工具函数 =====
function M.get_count_message(count, single_text, plural_text)
    if count == 1 then
        return string.format("已%s 1 个%s", single_text, "文件")
    else
        return string.format("已%s %d 个%s", single_text, count, "文件")
    end
end

print("🔧 核心工具模块已加载")
return M
