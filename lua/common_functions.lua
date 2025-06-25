local M = {}

-- 脚本配置
M.scripts = {
    basePath = hs.configdir .. "/scripts",
    getPath = function(scriptName)
        return M.scripts.basePath .. "/" .. scriptName
    end,
    execute = function(scriptName, callback)
        local scriptPath = M.scripts.getPath(scriptName)
        if not M.fileExists(scriptPath) then
            M.showError("脚本文件不存在: " .. scriptName)
            return false
        end
        local task = hs.task.new("/bin/bash", callback, { scriptPath })
        task:start()
        return task
    end
}

function M.showSuccess(msg) hs.alert.show("✅ " .. msg, 2) end

function M.showError(msg) hs.alert.show("❌ " .. msg, 3) end

function M.showWarning(msg) hs.alert.show("⚠️ " .. msg, 2.5) end

function M.showInfo(msg) hs.alert.show("ℹ️ " .. msg, 2) end

function M.showDebug(msg, force) if force or M.debug then print("🐛 " .. msg) end end

function M.fileExists(path) return hs.fs.attributes(path) ~= nil end

function M.launchApplication(name)
    local app = hs.application.get(name)
    if app then return app else return hs.application.launchOrFocus(name) and hs.application.get(name) end
end

function M.checkApplication(name) return hs.application.get(name) ~= nil end

function M.createSafeHotkey(mods, key, fn, description)
    local hotkey = hs.hotkey.new(mods, key, fn)
    if hotkey then
        hotkey:enable()
        M.showDebug("热键已绑定: " .. (description or key))
        return hotkey
    else
        M.showError("热键绑定失败: " .. (description or key))
        return nil
    end
end

function M.deepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original, nil do copy[M.deepCopy(key)] = M.deepCopy(value) end
        setmetatable(copy, M.deepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

function M.checkModule(moduleName)
    local ok, module = pcall(require, moduleName)
    if not ok then
        M.showError("模块不可用: " .. moduleName)
        return false
    end
    return true, module
end

function M.createStandardModule(name)
    local module = {
        name = name,
        config = { enabled = true, debug = false },
        hotkeys = {},
        init = function(self)
            if self.checkDeps and not self:checkDeps() then
                M.showError(self.name .. " 依赖检查失败")
                return false
            end
            if self.setupHotkeys then self:setupHotkeys() end
            M.showSuccess(self.name .. " 已初始化")
            return true
        end,
        cleanup = function(self)
            for _, hotkey in ipairs(self.hotkeys) do if hotkey then hotkey:delete() end end
            self.hotkeys = {}
        end,
        addHotkey = function(self, mods, key, fn, desc)
            local hotkey = M.createSafeHotkey(mods, key, fn, desc)
            if hotkey then table.insert(self.hotkeys, hotkey) end
            return hotkey
        end
    }
    return module
end

function M.createAppModule(name, appName)
    local module = M.createStandardModule(name)
    module.appName = appName
    module.get = function(self) return hs.application.get(self.appName) end
    module.launch = function(self) return M.launchApplication(self.appName) end
    module.isRunning = function(self) return M.checkApplication(self.appName) end
    module.menuAction = function(self, menuPath, actionName)
        local app = self:get()
        if not app then
            M.showError(self.name .. " 应用未运行")
            return false
        end
        local menuItem = app:findMenuItem(menuPath)
        if menuItem then
            app:selectMenuItem(menuPath)
            if actionName then M.showInfo(actionName) end
            return true
        else
            M.showWarning("菜单项不可用: " .. table.concat(menuPath, " > "))
            return false
        end
    end
    return module
end

return M
