local common = require("lua.common_functions")
local M = common.createAppModule("音乐控制", "Music")

-- 音乐应用专门的播放/暂停控制
function M.togglePlayback()
    if M:isRunning() then
        -- 使用 AppleScript 直接控制播放/暂停
        common.scripts.execute("music_toggle.applescript")
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

-- 系统层面的播放/暂停控制（可控制任何媒体应用）
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
    M:addHotkey({ "cmd", "ctrl", "shift" }, ";", M.togglePlayback, "音乐应用播放/暂停")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "'", M.nextTrack, "下一首")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "p", M.systemPlayPause, "系统媒体播放/暂停")
end

if M.config.enabled then
    M:init()
end
return M
