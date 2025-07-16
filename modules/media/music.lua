-- 音乐控制模块
local utils = require("modules.core.utils")

local M = {}

-- 音乐应用专门的播放/暂停控制
function M.togglePlayback()
    utils.scripts.execute("media", "music_play_toggle.sh")
end

function M.nextTrack()
    utils.scripts.execute("media", "music_next.sh")
end

function M.previousTrack()
    utils.scripts.execute("media", "music_previous.sh")
end

-- Zen Browser 媒体控制
function M.zenPlayToggle()
    utils.scripts.execute("media", "zen_play_toggle.sh")
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
    utils.createSafeHotkey({ "cmd", "ctrl", "shift" }, ";", M.togglePlayback, "音乐播放/暂停")
    utils.createSafeHotkey({ "cmd", "ctrl", "shift" }, "'", M.nextTrack, "下一首")
    utils.createSafeHotkey({ "cmd", "ctrl", "shift" }, "l", M.previousTrack, "上一首")
    utils.createSafeHotkey({ "cmd", "ctrl", "shift" }, "z", M.zenPlayToggle, "Zen Browser 媒体控制")
    utils.createSafeHotkey({ "cmd", "ctrl", "shift" }, "p", M.systemPlayPause, "系统媒体播放/暂停")
end

-- 初始化函数
function M.init()
    if M.checkDeps() then
        M.setupHotkeys()
        print("🎵 音乐控制模块已加载")
        return true
    end
    return false
end

return M
