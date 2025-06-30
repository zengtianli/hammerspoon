-- Hammerspoon 主配置文件 (使用 lua_comb 统一模块)

-- 加载 lua_comb 统一模块
print("🚀 开始加载 Hammerspoon 配置...")
local lua_comb = require("lua_comb.init")

-- 配置文件自动重载功能
function reloadConfig(files)
    local doReload = false
    for _, file in ipairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
            break
        end
    end
    if doReload then
        hs.reload()
    end
end

-- 监听配置文件变化
myWatcher = hs.pathwatcher.new(hs.configdir .. "/", reloadConfig):start()

-- Enable IPC for command line access
hs.ipc.cliInstall()

-- 显示加载完成信息
hs.alert.show("✅ Hammerspoon 配置已加载 (lua_comb)")
print("✅ Hammerspoon 配置加载完成，按 ⌘⌃⌥⇧+H 查看快捷键帮助")

-- 导出主模块供调试使用
return lua_comb
