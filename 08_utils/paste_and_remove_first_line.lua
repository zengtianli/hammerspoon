local filePath = "/Users/tianli/bendownloads/temp/copylist.txt" -- File path

-- Function to read the first line of the file and delete it
local function pasteAndRemoveFirstLine()
    local lines = {}
    local firstLine = nil
    local file = io.open(filePath, "r") -- Open file in read mode

    if file then
        -- Read all lines and store them in a table
        for line in file:lines() do
            if not firstLine then
                firstLine = line -- Capture the first line
            else
                table.insert(lines, line) -- Collect other lines
            end
        end
        file:close()
    end

    if firstLine then
        hs.pasteboard.setContents(firstLine) -- Set the clipboard to the first line
        -- Rewrite the file without the first line
        file = io.open(filePath, "w")
        for i, line in ipairs(lines) do
            file:write(line .. "\n")
        end
        file:close()
    end
end

-- Keybinding to trigger the function
hs.hotkey.bind({"ctrl", "cmd"}, "v", function()
    pasteAndRemoveFirstLine()
    hs.alert.show("Pasted and removed the first line")
		-- simulate past action like cmd v
end)

