function requireAllFromDirectory(directory)
    local path = hs.configdir .. '/' .. directory
    if not hs.fs.attributes(path, "mode") then
        hs.alert.show('目录不存在: ' .. path)
        return
    end
    local iter, dir_obj = hs.fs.dir(path)
    if not iter then
        hs.alert.show('无法打开目录: ' .. path)
        return
    end
    for file in iter, dir_obj do
        if file:sub(-4) == ".lua" then
            local module = directory .. '.' .. file:sub(1, -5)
            require(module)
        end
    end
end

-- requireAllFromDirectory("03_launcher")
-- requireAllFromDirectory("10_yabai")
-- requireAllFromDirectory("08_utils")
requireAllFromDirectory("lua")
-- requireAllFromDirectory("temp")
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

myWatcher = hs.pathwatcher.new(hs.configdir .. "/", reloadConfig):start()
hs.alert.show("Config Loaded")
