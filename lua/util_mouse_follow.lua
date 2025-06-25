local common = require("lua.common_functions")
local M = common.createStandardModule("鼠标跟随工具")
M.config.enabled = false
M.windowFilter = nil

function M.moveMouseToWindowCenter()
    local focusedWindow = hs.window.focusedWindow()
    if not focusedWindow then return end
    
    local frame = focusedWindow:frame()
    local centerX = frame.x + frame.w / 2
    local centerY = frame.y + frame.h / 2
    hs.mouse.absolutePosition({x = centerX, y = centerY})
end

function M.toggleMouseFollow()
    if M.config.enabled then
        -- 禁用
        if M.windowFilter then
            M.windowFilter:unsubscribeAll()
            M.windowFilter = nil
        end
        M.config.enabled = false
        common.showInfo("鼠标跟随已禁用")
    else
        -- 启用
        M.windowFilter = hs.window.filter.new()
        M.windowFilter:subscribe(hs.window.filter.windowFocused, M.moveMouseToWindowCenter)
        M.config.enabled = true
        common.showInfo("鼠标跟随已启用")
    end
end

function M.checkDeps()
    return common.checkModule("hs.window") and 
           common.checkModule("hs.mouse") and 
           common.checkModule("hs.window.filter")
end

function M.setupHotkeys()
    M:addHotkey({"cmd", "ctrl"}, "F", M.toggleMouseFollow, "切换鼠标跟随")
end

if M.config.enabled then 
    M:init() 
end

return M
