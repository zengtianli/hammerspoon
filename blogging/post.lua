function runInWarp(command, postCmds)
	hs.application.launchOrFocus("Warp")
	hs.timer.usleep(500000) -- 0.5 seconds
	hs.eventtap.keyStrokes(command)
	hs.timer.usleep(200000) -- 0.2 seconds
	hs.eventtap.keyStroke({}, "return")
	if postCmds then
		for _, cmd in ipairs(postCmds) do
			if cmd == "shift+g" then
				hs.eventtap.keyStroke({ "shift" }, "G")
			elseif cmd == "o" then
				hs.eventtap.keyStroke({}, "o")
			elseif cmd == "cmd+v" then
				hs.eventtap.keyStroke({ "cmd" }, "v")
			elseif cmd == "esc" then
				hs.eventtap.keyStroke({}, "escape")
			elseif cmd == ":wq" then
				hs.eventtap.keyStrokes(";wq")
			elseif cmd == "\n" then
				hs.eventtap.keyStrokes("\n")
			else
				hs.eventtap.keyStrokes(cmd)
			end
			hs.timer.usleep(200000) -- 0.2 seconds delay between commands
		end
	end
end

function getBlogDetails()
	local titleDefaultResponse = "some post"
	local contentDefaultResponse = "Enter your blog content here..."

	local wasClicked, title = hs.dialog.textPrompt(
		"New Blog Post",
		"Please enter the post title:",
		titleDefaultResponse,
		"OK",
		"Cancel"
	)

	if wasClicked ~= "OK" then
		return nil, nil
	end

	local wasClickedContent, content = hs.dialog.textPrompt(
		"Blog Content",
		"Please enter the content for '" .. title .. "':",
		contentDefaultResponse,
		"OK",
		"Cancel"
	)

	if wasClickedContent ~= "OK" then
		return title, nil
	end

	return title, content
end

hs.hotkey.bind({ "cmd", "alt" }, "1", function()
	hs.timer.usleep(500000)          -- 0.5 seconds
	title, content = getBlogDetails() -- Get the title and content from the user

	if title and title ~= "" then
		hexoCommand = "hexo new '" .. title .. "'"
		filename = string.gsub(title, " ", "-") .. ".md"
		nvimCommand = "nvim " .. filename

		runInWarp("z" .. " post")
		hs.timer.usleep(500000) -- 0.5 seconds
		runInWarp(hexoCommand)
		hs.timer.usleep(500000) -- 0.5 seconds
		-- Now, instead of pasting (cmd+v), we type the content directly
		runInWarp(nvimCommand, { "shift+g", "o", content, "esc", ":wq", "\n" })
	else
		hs.alert.show("No title provided. Operation canceled.")
	end
end)
