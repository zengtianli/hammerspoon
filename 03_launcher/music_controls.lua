function apple_music_playback()
	local aapl_music = hs.appfinder.appFromName("Music")
	if not aapl_music then
		hs.application.launchOrFocus("Music")
	end
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

-- hs.hotkey.bind({ "cmd", "ctrl", "shift" }, 'l', apple_music_previous_track)

-- hs.hotkey.bind({}, 'f8', apple_music_playback)
-- hs.hotkey.new({ "cmd", "ctrl", "shift" }, "p", function() hs.application.open("PicGo") end)
-- Volume Control in Apple Music.app
function apple_music_volume(direction)
	return function()
		hs.application.launchOrFocus("Music")
		local aapl_music = hs.appfinder.appFromName("Music")
		aapl_music:selectMenuItem({ "Controls", direction })
	end
end

hs.hotkey.bind({ "cmd", "ctrl" }, 'up', apple_music_volume("Increase Volume"))
hs.hotkey.bind({ "cmd", "ctrl" }, 'down', apple_music_volume("Decrease Volume"))
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "p", function()
    hs.eventtap.event.newSystemKeyEvent("PLAY", true):post()
    hs.eventtap.event.newSystemKeyEvent("PLAY", false):post()
end)

