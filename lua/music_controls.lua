local common = require("lua.common_functions")
local M = common.createAppModule("音乐控制", "Music")
function M.togglePlayback()
    local runningApps = hs.application.runningApplications()
    local musicIsRunning = false
    for _, app in ipairs(runningApps) do
        if app:name() == "Music" then
            musicIsRunning = true
            break
        end
    end
    if musicIsRunning then
        M.systemPlayPause()
    else
        common.scripts.execute("run_music.sh")
    end
end

function M.nextTrack()
    return M:menuAction({ "Controls", "Next Track" })
end

function M.previousTrack()
    return M:menuAction({ "Controls", "Previous Track" })
end

function M.systemPlayPause()
    hs.eventtap.event.newSystemKeyEvent("PLAY", true):post()
    hs.eventtap.event.newSystemKeyEvent("PLAY", false):post()
end

function M.checkDeps()
    return common.checkModule("hs.application") and
        common.checkModule("hs.hotkey") and
        common.checkModule("hs.eventtap") and
        common.checkModule("hs.task")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "ctrl", "shift" }, ";", M.togglePlayback, "播放/暂停")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "'", M.nextTrack, "下一首")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "p", M.systemPlayPause, "系统播放控制")
end

if M.config.enabled then
    M:init()
end
return M
