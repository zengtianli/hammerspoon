local pasteboard = require("hs.pasteboard")
local lastChange = pasteboard.changeCount() -- Keeps track of the last clipboard change
local isRecording = false -- Toggle state
local filePath = "/Users/tianli/bendownloads/temp/copylist.txt" -- File path

-- Function to append copied text to the file
local function appendToFile(content)
    local file = io.open(filePath, "a") -- Open file in append mode
    if file then
        file:write(content .. "\n") -- Append new content with a newline
        file:close() -- Close the file after writing
    end
end

-- Clipboard watcher that checks for changes and appends new content if recording is enabled
local clipboardWatcher = pasteboard.watcher.new(function()
    if not isRecording then return end
    local currentChange = pasteboard.changeCount()
    if currentChange ~= lastChange then
        lastChange = currentChange
        local content = pasteboard.getContents()
        if content then appendToFile(content) end
    end
end)

clipboardWatcher:start() -- Start the clipboard watcher

-- Keybinding to toggle the recording state
hs.hotkey.bind({"ctrl", "cmd"}, "c", function()
    isRecording = not isRecording
    hs.alert.show(isRecording and "Recording Copied Content" or "Stopped Recording Copied Content")
end)

