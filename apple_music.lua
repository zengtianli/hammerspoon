-- This manually toggles play/pause on Apple Music.app
function apple_music_playback()
	hs.application.launchOrFocus("Music")
	local aapl_music = hs.appfinder.appFromName("Music")

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

hs.hotkey.bind({}, 'f8', apple_music_playback)

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


-- This manually toggles play/pause on Amazon Music HD as of 10/2020
function amazon_music_playback()
	hs.application.launchOrFocus("Amazon Music")
	local amzn_music = hs.appfinder.appFromName("Amazon Music")

	local str_pause = { "Playback", "Pause" }
	local str_play_and_pause = { "Playback", "Play and Pause" }

	local pause = amzn_music:findMenuItem(str_pause)
	local play_and_pause = amzn_music:findMenuItem(str_play_and_pause)

	if (pause) then
		amzn_music:selectMenuItem(str_pause)
	end
	if (play_and_pause) then
		amzn_music:selectMenuItem(str_play_and_pause)
	end
end

-- hs.hotkey.bind({}, 'f8', amazon_music_playback)

-- Volume Control in Amazon Music.app
function amazon_music_volume(direction)
	return function()
		hs.application.launchOrFocus("Amazon Music")
		local amzn_music = hs.appfinder.appFromName("Amazon Music")
		amzn_music:selectMenuItem({ "Playback", direction })
	end
end

-- hs.hotkey.bind({"cmd", "ctrl"}, 'up', amazon_music_volume("Volume Up"))
-- hs.hotkey.bind({"cmd", "ctrl"}, 'down', amazon_music_volume("Volume Down"))


-- This manually toggles play/pause on Amazon Music HD as of 10/2020
function spotify_music_playback()
	hs.application.launchOrFocus("Spotify")
	local spotify_music = hs.appfinder.appFromName("Spotify")

	local str_pause = { "Playback", "Pause" }
	local str_play_and_pause = { "Playback", "Play" }

	local pause = spotify_music:findMenuItem(str_pause)
	local play_and_pause = spotify_music:findMenuItem(str_play_and_pause)

	if (pause) then
		spotify_music:selectMenuItem(str_pause)
	end
	if (play_and_pause) then
		spotify_music:selectMenuItem(str_play_and_pause)
	end
end

-- hs.hotkey.bind({}, 'f8', spotify_music_playback)

-- Volume Control in Amazon Music.app
function spotify_music_volume(direction)
	return function()
		hs.application.launchOrFocus("Spotify")
		local spotify_music = hs.appfinder.appFromName("Spotify")
		spotify_music:selectMenuItem({ "Playback", direction })
	end
end

-- hs.hotkey.bind({"cmd", "ctrl"}, 'up', spotify_music_volume("Volume Up"))
-- hs.hotkey.bind({"cmd", "ctrl"}, 'down', spotify_music_volume("Volume Down"))


-- This manually toggles play/pause on Amazon Music HD as of 10/2020
function tidal_music_playback()
	hs.application.launchOrFocus("TIDAL")
	local tidal_music = hs.appfinder.appFromName("TIDAL")

	local str_pause = { "Playback", "Pause" }
	local str_play_and_pause = { "Playback", "Play" }

	local pause = tidal_music:findMenuItem(str_pause)
	local play_and_pause = tidal_music:findMenuItem(str_play_and_pause)

	if (pause) then
		tidal_music:selectMenuItem(str_pause)
	end
	if (play_and_pause) then
		tidal_music:selectMenuItem(str_play_and_pause)
	end
end

-- hs.hotkey.bind({}, 'f8', tidal_music_playback)

-- Volume Control in Amazon Music.app
function tidal_music_volume(direction)
	return function()
		hs.application.launchOrFocus("TIDAL")
		local tidal_music = hs.appfinder.appFromName("TIDAL")
		tidal_music:selectMenuItem({ "Playback", direction })
	end
end

-- hs.hotkey.bind({"cmd", "ctrl"}, 'up', tidal_music_volume("Volume up"))
-- hs.hotkey.bind({"cmd", "ctrl"}, 'down', tidal_music_volume("Volume down"))


-- window tiling

function tile(x_pos, y_pos)
	return function()
		local win = hs.window.focusedWindow()
		local f = win:frame()
		local screen = win:screen()
		local max = screen:frame()
		local new_width = max.w / 3
		local new_height = max.h / 2

		f.x = new_width * x_pos
		f.y = new_height * y_pos + (y_pos > 0 and 26 or 0)
		f.w = new_width
		f.h = new_height
		win:setFrame(f, 0)
		-- hs.window.setShadows(false)    -- this doesn't work in Catalina
		-- hs.window.setFrameCOrrectness(true)
		-- hs.alert.show(f)
	end
end

hs.hotkey.bind({ "alt" }, "4", tile(0, 0))
hs.hotkey.bind({ "alt" }, "5", tile(1, 0))
hs.hotkey.bind({ "alt" }, "6", tile(2, 0))
hs.hotkey.bind({ "alt" }, "1", tile(0, 1))
hs.hotkey.bind({ "alt" }, "2", tile(1, 1))
hs.hotkey.bind({ "alt" }, "3", tile(2, 1))



-- -- local hyper     = {"ctrl", "alt", "cmd"}
-- -- local lesshyper = {"ctrl", "alt"}
-- hs.loadSpoon("GlobalMute")
-- spoon.GlobalMute:bindHotkeys({
--   -- unmute = {lesshyper, "u"},
--   -- mute   = {lesshyper, "m"},
--   toggle = {{"cmd", "shift"}, "r"}
-- })
-- spoon.GlobalMute:configure({
--   -- unmute_background = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png',
--   -- mute_background   = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png',
--   enforce_desired_state = true,
--   stop_sococo_for_zoom  = true,
--   unmute_title = "<---- THEY CAN HEAR YOU -----",
--   mute_title = "<-- MUTE",
--   -- change_screens = "SCREENNAME1, SCREENNAME2"  -- This will only change the background of the specific screens.  string.find()
-- })
-- spoon.GlobalMute._logger.level = 3
