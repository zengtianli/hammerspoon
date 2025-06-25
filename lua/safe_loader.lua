-- 安全模块加载器 - 提供健壮的模块管理和热重载功能
-- 版本: 2.0.0
-- 作者: tianli
-- 更新: 2024-12-24

local common = require("lua.common_functions")
local M = common.createStandardModule("安全加载器")
M.config = common.merge(M.config, { enableHotReload = true, maxRetries = 3, retryDelay = 1.0, enableBackup = true })

M.loadedModules, M.moduleBackups, M.moduleErrors, M.fileWatchers = {}, {}, {}, {}

local function safeLoadModule(modulePath, moduleName)
    moduleName = moduleName or modulePath
    if M.loadedModules[moduleName] and M.config.enableBackup then
        M.moduleBackups[moduleName] = M.loadedModules[moduleName]
    end

    local ok, result = pcall(function()
        package.loaded[modulePath] = nil; return require(modulePath)
    end)

    if ok then
        M.loadedModules[moduleName] = result
        M.moduleErrors[moduleName] = nil
        common.showSuccess("模块加载成功: " .. moduleName)
        return result, nil
    else
        local errorMsg = tostring(result)
        M.moduleErrors[moduleName] = errorMsg
        if M.moduleBackups[moduleName] and M.config.enableBackup then
            M.loadedModules[moduleName] = M.moduleBackups[moduleName]
            common.showWarning("加载失败，已恢复备份: " .. moduleName)
            return M.moduleBackups[moduleName], errorMsg
        else
            common.showError("加载失败: " .. moduleName .. " - " .. errorMsg)
            return nil, errorMsg
        end
    end
end

function M.loadModules(moduleList)
    local successCount, failureCount, results = 0, 0, {}
    common.showInfo("开始加载 " .. #moduleList .. " 个模块...")

    for i, moduleInfo in ipairs(moduleList) do
        local modulePath, moduleName
        if type(moduleInfo) == "string" then
            modulePath = moduleInfo
            moduleName = moduleInfo:match("([^%.]+)$")
        else
            modulePath, moduleName = moduleInfo.path, moduleInfo.name or moduleInfo.path
        end

        local module, error = safeLoadModule(modulePath, moduleName)
        if module then
            results[moduleName] = module; successCount = successCount + 1
        else
            failureCount = failureCount + 1
        end

        if M.config.debug then common.showDebug("[" .. i .. "/" .. #moduleList .. "] 已处理: " .. moduleName, true) end
    end

    common.showInfo("加载完成")
    common.showSuccess("✅ 成功: " .. successCount .. " 个")
    if failureCount > 0 then common.showError("❌ 失败: " .. failureCount .. " 个") end
    return results, successCount, failureCount
end

function M.reloadModule(moduleName)
    if not M.loadedModules[moduleName] then
        common.showError("模块未加载: " .. moduleName); return false
    end
    common.showProcessing("重新加载: " .. moduleName)

    local modulePath = nil
    for path, _ in pairs(package.loaded) do
        if path:match(moduleName .. "$") then
            modulePath = path; break
        end
    end

    if not modulePath then
        common.showError("无法找到模块路径: " .. moduleName); return false
    end
    local module, error = safeLoadModule(modulePath, moduleName)
    return module ~= nil, error
end

function M.getModuleStatus(moduleName)
    if moduleName then
        return {
            loaded = M.loadedModules[moduleName] ~= nil,
            hasBackup = M.moduleBackups[moduleName] ~= nil,
            hasError =
                M.moduleErrors[moduleName] ~= nil,
            error = M.moduleErrors[moduleName]
        }
    else
        local status, allModules = { total = 0, loaded = 0, errors = 0, withBackup = 0 }, {}
        for name, _ in pairs(M.loadedModules) do allModules[name] = true end
        for name, _ in pairs(M.moduleBackups) do allModules[name] = true end
        for name, _ in pairs(M.moduleErrors) do allModules[name] = true end
        for name, _ in pairs(allModules) do
            status.total = status.total + 1; if M.loadedModules[name] then status.loaded = status.loaded + 1 end; if M.moduleBackups[name] then
                status.withBackup =
                    status.withBackup + 1
            end; if M.moduleErrors[name] then status.errors = status.errors + 1 end
        end
        return status
    end
end

function M.showStatus()
    local status, loadedList, errorList, allModules = M.getModuleStatus(), {}, {}, {}
    for name, _ in pairs(M.loadedModules) do
        allModules[name] = true; if M.loadedModules[name] then table.insert(loadedList, name) end
    end
    for name, _ in pairs(M.moduleBackups) do allModules[name] = true end
    for name, error in pairs(M.moduleErrors) do
        allModules[name] = true; if error then table.insert(errorList, name) end
    end
    local statusText = string.format("模块状态: %d个总计", status.total)
    if #loadedList > 0 then
        statusText = statusText ..
            "\n✅ 已加载(" .. #loadedList .. "): " .. table.concat(loadedList, ", ")
    end
    if #errorList > 0 then statusText = statusText .. "\n❌ 错误(" .. #errorList .. "): " .. table.concat(errorList, ", ") end
    if status.withBackup > 0 then statusText = statusText .. "\n💾 有备份: " .. status.withBackup .. "个" end
    hs.alert.show(statusText, 5)
    return status
end

function M.emergencyRecover()
    common.showWarning("执行紧急恢复...")
    local recoveredCount = 0
    for name, backup in pairs(M.moduleBackups) do
        if backup then
            M.loadedModules[name] = backup; M.moduleErrors[name] = nil; recoveredCount = recoveredCount + 1
        end
    end
    if recoveredCount > 0 then
        common.showSuccess("已恢复 " .. recoveredCount .. " 个模块到备份状态")
    else
        common.showWarning(
            "没有可恢复的备份")
    end
    return recoveredCount
end

function M.requireAllFromDirectory(directory)
    local path = hs.configdir .. '/' .. directory
    if not hs.fs.attributes(path, "mode") then
        common.showError('目录不存在: ' .. path); return {}
    end

    local iter, dir_obj = hs.fs.dir(path)
    if not iter then
        common.showError('无法打开目录: ' .. path); return {}
    end

    local moduleList = {}
    for file in iter, dir_obj do
        if file:sub(-4) == ".lua" and file ~= "common_functions.lua" and file ~= "safe_loader.lua" then
            local modulePath, moduleName = directory .. '.' .. file:sub(1, -5), file:sub(1, -5)
            table.insert(moduleList, { path = modulePath, name = moduleName })
        end
    end

    if #moduleList > 0 then
        local results = M.loadModules(moduleList)
        M.setupFileWatcher(path)
        return results
    else
        common.showWarning("目录中没有找到模块: " .. directory)
        return {}
    end
end

function M.setupFileWatcher(directory)
    if not M.config.enableHotReload then return end

    local function onFileChange(files)
        for _, file in ipairs(files) do
            if file:match("%.lua$") then
                local moduleName = file:match("([^/]+)%.lua$")
                if moduleName and M.loadedModules[moduleName] then
                    common.showInfo("检测到文件变化: " .. file)
                    hs.timer.doAfter(0.5, function() M.reloadModule(moduleName) end)
                end
            end
        end
    end

    local watcher = hs.pathwatcher.new(directory, onFileChange)
    watcher:start()
    M.fileWatchers[directory] = watcher
    common.showInfo("已启用热重载监控: " .. directory)
end

function M.cleanup()
    for _, watcher in pairs(M.fileWatchers) do watcher:stop() end
    M.fileWatchers = {}
    for name, module in pairs(M.loadedModules) do
        if module and type(module.cleanup) == "function" then pcall(module.cleanup) end
    end
    common.showInfo("安全加载器已清理")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "ctrl", "shift", "alt" }, "L",
        function() for name, _ in pairs(M.loadedModules) do M.reloadModule(name) end end, "重新加载所有模块")
    M:addHotkey({ "cmd", "ctrl", "shift", "alt" }, "R", M.emergencyRecover, "紧急恢复")
    M:addHotkey({ "cmd", "ctrl", "shift", "alt" }, "S", M.showStatus, "查看状态")
end

if M.config.enabled then M:init() end
common.showInfo("安全模块加载器已初始化")
return M
