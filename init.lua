-- require("./shortcut.lua")
dofile(hs.configdir .. "/shortcut.lua")
require "vimlike.vimlike"

-- dofile(hs.configdir .. "/vimlike.lua")
-- dofile(hs.configdir .. "/vimlike1.lua")aaaa
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

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
