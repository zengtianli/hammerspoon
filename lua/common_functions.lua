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
        task:setWorkingDirectory(M.scripts.basePath)
        task:start()
        return task
    end
}

-- 通知函数
function M.showInfo(msg)
    hs.alert.show("ℹ️ " .. msg, 2)
end

function M.showError(msg)
    hs.alert.show("❌ " .. msg, 3)
end

-- 工具函数
function M.fileExists(path)
    return hs.fs.attributes(path) ~= nil
end

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

-- 创建标准模块
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

return M
