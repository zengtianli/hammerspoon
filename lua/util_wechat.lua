local common = require("lua.common_functions")
local M = common.createAppModule("微信工具", "WeChat")

function M.launchWechat()
    if M:isRunning() then
        hs.application.launchOrFocus("WeChat")
        hs.eventtap.keyStroke({}, "return")
        return true
    end
    
    local success = M:launch()
    if success then
        hs.timer.doAfter(1.0, function()
            hs.eventtap.keyStroke({}, "return")
        end)
        return true
    else
        common.showError("微信启动失败")
        return false
    end
end

function M.checkDeps()
    return common.checkModule("hs.application") and 
           common.checkModule("hs.hotkey") and 
           common.checkModule("hs.eventtap")
end

function M.setupHotkeys()
    M:addHotkey({"ctrl", "alt"}, "W", M.launchWechat, "启动微信")
end

if M.config.enabled then 
    M:init() 
end

return M
