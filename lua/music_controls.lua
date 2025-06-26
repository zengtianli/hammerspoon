local common = require("lua.common_functions")
local M = common.createAppModule("音乐控制", "Music")

-- 音乐应用专门的播放/暂停控制
function M.togglePlayback()
    -- 直接运行 music_play_toggle.sh 脚本，它会处理所有的逻辑
    common.scripts.execute("music_play_toggle.sh")
end

function M.nextTrack()
    -- 直接运行 music_next.sh 脚本
    common.scripts.execute("music_next.sh")
end

function M.previousTrack()
    -- 直接运行 music_previous.sh 脚本
    common.scripts.execute("music_previous.sh")
end

-- Zen Browser 媒体控制
function M.zenPlayToggle()
    -- 直接运行 zen_play_toggle.sh 脚本
    common.scripts.execute("zen_play_toggle.sh")
end

-- 系统层面的播放/暂停控制（可控制任何媒体应用）
function M.systemPlayPause()
    hs.eventtap.event.newSystemKeyEvent("PLAY", true):post()
    hs.eventtap.event.newSystemKeyEvent("PLAY", false):post()
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "ctrl", "shift" }, ";", M.togglePlayback, "音乐应用播放/暂停")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "'", M.nextTrack, "下一首")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "l", M.previousTrack, "上一首")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "z", M.zenPlayToggle, "Zen Browser 媒体控制")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "p", M.systemPlayPause, "系统媒体播放/暂停")
end

if M.config.enabled then
    M:init()
end
return M
