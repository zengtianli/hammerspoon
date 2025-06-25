local common = require("lua.common_functions")
local M = common.createAppModule("音乐控制", "Music")

function M.togglePlayback()
    local app = M:get()
    if not app then
        hs.application.launchOrFocus("Music")
        app = M:get()
    end
    
    if app then
        local pauseItem = app:findMenuItem({"Controls", "Pause"})
        local playItem = app:findMenuItem({"Controls", "Play"})
        
        if pauseItem then
            app:selectMenuItem({"Controls", "Pause"})
        elseif playItem then
            app:selectMenuItem({"Controls", "Play"})
        end
    end
end

function M.nextTrack()
    return M:menuAction({"Controls", "Next Track"})
end

function M.previousTrack()
    return M:menuAction({"Controls", "Previous Track"})
end

function M.systemPlayPause()
    hs.eventtap.event.newSystemKeyEvent("PLAY", true):post()
    hs.eventtap.event.newSystemKeyEvent("PLAY", false):post()
end

function M.checkDeps()
    return common.checkModule("hs.application") and 
           common.checkModule("hs.hotkey") and 
           common.checkModule("hs.eventtap")
end

function M.setupHotkeys()
    M:addHotkey({"cmd", "ctrl", "shift"}, ";", M.togglePlayback, "播放/暂停")
    M:addHotkey({"cmd", "ctrl", "shift"}, "'", M.nextTrack, "下一首")
    M:addHotkey({"cmd", "ctrl", "shift"}, "p", M.systemPlayPause, "系统播放控制")
end

if M.config.enabled then 
    M:init() 
end

return M
