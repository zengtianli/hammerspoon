function apple_music_playback()
    local aapl_music = hs.appfinder.appFromName("Music")
    if not aapl_music then
        -- 运行 ~/useful_scripts/music.applescript 文件
        hs.osascript.applescriptFromFile(os.getenv("HOME") .. "/useful_scripts/music.applescript")
        hs.timer.usleep(500000)  -- 暂停 0.5 秒
        aapl_music = hs.appfinder.appFromName("Music")
    end
    -- 如果 Music 应用现在存在，继续执行原来的逻辑
    if aapl_music then
        local str_pause = { "Controls", "Pause" }
        local str_play_and_pause = { "Controls", "Play" }
        local pause = aapl_music:findMenuItem(str_pause)
        local play_and_pause = aapl_music:findMenuItem(str_play_and_pause)
        if (pause) then
            aapl_music:selectMenuItem(str_pause)
        end
        if (play_and_pause) then
            aapl_music:selectMenuItem(str_play_and_pause)
        end
    end
end
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, ';', apple_music_playback)
function apple_music_next_track()
	local aapl_music = hs.appfinder.appFromName("Music")
	local next_track = { "Controls", "Next Track" }
	local can_go_next = aapl_music:findMenuItem(next_track)
	if (can_go_next) then
		aapl_music:selectMenuItem(next_track)
	end
end
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, '\'', apple_music_next_track)
function apple_music_previous_track()
	local aapl_music = hs.appfinder.appFromName("Music")
	local previous_track = { "Controls", "Previous Track" }
	local can_go_previous = aapl_music:findMenuItem(previous_track)
	if (can_go_previous) then
		aapl_music:selectMenuItem(previous_track)
	end
end
-- Volume Control in Apple Music.app
function apple_music_volume(direction)
	return function()
		hs.application.launchOrFocus("Music")
		local aapl_music = hs.appfinder.appFromName("Music")
		aapl_music:selectMenuItem({ "Controls", direction })
	end
end
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "p", function()
    hs.eventtap.event.newSystemKeyEvent("PLAY", true):post()
    hs.eventtap.event.newSystemKeyEvent("PLAY", false):post()
end)
function toggle_airpods_noise()
    local script_path = os.getenv("HOME") .. "/useful_scripts/airpods.scpt"
    local output, status, type, rc = hs.osascript.applescriptFromFile(script_path)
    if status then
        hs.alert.show("切换到: " .. output)
    else
        hs.alert.show("切换失败")
    end
end

-- 绑定快捷键 Cmd+Ctrl+Shift+A 来切换 AirPods 噪音控制模式
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "l", toggle_airpods_noise) 
