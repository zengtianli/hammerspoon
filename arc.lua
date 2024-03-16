-- 记录当前活动应用并激活Safari发送按键，然后返回之前的应用
-- 记录当前活动应用并激活Safari发送按键，然后返回之前的应用
function activateArcSendKeyAndReturn(key)
    local previousApp = hs.application.frontmostApplication()
    hs.application.launchOrFocus("Arc")
    hs.timer.doAfter(0.1, function()
        hs.eventtap.keyStroke({}, key)
        hs.timer.doAfter(0.1, function() previousApp:activate() end)
    end)
end

-- 绑定快捷键"cmd ctrl shift ,"来切换到Safari并输入左箭头，之后返回之前的应用
hs.hotkey.bind({"cmd", "ctrl", "shift"}, ",", function()
    activateArcSendKeyAndReturn("left")
end)

-- 绑定快捷键"cmd ctrl shift ."来切换到Safari并输入右箭头，之后返回之前的应用
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "/", function()
    activateArcSendKeyAndReturn("right")
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, ".", function()
    activateArcSendKeyAndReturn("space")
end)
-- 存储快捷键绑定引用
local weChatHotkey = hs.hotkey.bind({"ctrl", "alt"}, "W", function()
    -- 检查微信是否已经运行
    local wechat = hs.application.find("WeChat")
        hs.application.launchOrFocus("WeChat")
    -- 如果微信已经在运行，则不执行任何操作
end)

