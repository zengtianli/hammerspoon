-- 鼠标跟随功能的状态变量
local mouseFollowEnabled = false

-- 鼠标跟随功能的实现
local function toggleMouseFollow()
    if mouseFollowEnabled then
        -- 如果当前已启用，则取消订阅事件并禁用功能
        hs.window.filter.default:unsubscribe(hs.window.filter.windowFocused)
        mouseFollowEnabled = false
        hs.alert.show("Mouse Follow Disabled")
    else
        -- 如果当前未启用，则订阅事件并启用功能
        hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function(window)
            local frame = window:frame()
            local center = hs.geometry.rectMidPoint(frame)
            hs.mouse.setAbsolutePosition(center)
        end)
        mouseFollowEnabled = true
        hs.alert.show("Mouse Follow Enabled")
    end
end

-- 绑定快捷键，例如 Cmd+Ctrl+F 来切换鼠标跟随功能
hs.hotkey.bind({"cmd", "ctrl"}, "F", toggleMouseFollow)

