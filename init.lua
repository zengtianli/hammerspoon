-- init.lua
require "app_launcher"
require "yabai"
require "vimlike.vimlike"
require "recordedPosition"
-- require "Clipboard_Manager"
require "quicknote"
require "post"
require "apple_music"
require "arc"

function reloadConfig(files)
	doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end

--------------------------------
-- START VIM CONFIG
--------------------------------
local VimMode = hs.loadSpoon("VimMode")
local vim = VimMode:new()

vim
		:disableForApp('Warp')
		:disableForApp('Code')
		:disableForApp('iTerm2')
		:disableForApp('Terminal')

-- If you want the screen to dim (a la Flux) when you enter normal mode
-- flip this to true.
vim:shouldDimScreenInNormalMode(false)

-- If you want to show an on-screen alert when you enter normal mode, set
-- this to true
vim:shouldShowAlertInNormalMode(true)

-- You can configure your on-screen alert font
vim:setAlertFont("Courier New")


-- vim:bindHotKeys({ enter = { { 'cmd', 'shift', 'ctrl' }, 'escape' } })

--------------------------------
-- END VIM CONFIG
--------------------------------

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

require("rcmd")
