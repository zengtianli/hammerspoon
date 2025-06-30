-- 音乐控制模块
local utils = require("lua_comb.common_utils")
local M = utils.createAppModule("音乐控制", "Music")

-- 音乐应用专门的播放/暂停控制
function M.togglePlayback()
    utils.scripts.execute("music_play_toggle.sh")
end

function M.nextTrack()
    utils.scripts.execute("music_next.sh")
end

function M.previousTrack()
    utils.scripts.execute("music_previous.sh")
end

-- Zen Browser 媒体控制
function M.zenPlayToggle()
    utils.scripts.execute("zen_play_toggle.sh")
end

-- 系统层面的播放/暂停控制（可控制任何媒体应用）
function M.systemPlayPause()
    hs.eventtap.event.newSystemKeyEvent("PLAY", true):post()
    hs.eventtap.event.newSystemKeyEvent("PLAY", false):post()
end

function M.checkDeps()
    return utils.checkModule("hs.hotkey") and
        utils.checkModule("hs.task") and
        utils.checkModule("hs.eventtap")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "ctrl", "shift" }, ";", M.togglePlayback, "音乐播放/暂停")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "'", M.nextTrack, "下一首")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "l", M.previousTrack, "上一首")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "z", M.zenPlayToggle, "Zen Browser 媒体控制")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "p", M.systemPlayPause, "系统媒体播放/暂停")
end

return M
