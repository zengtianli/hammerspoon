local tailsPattern = {
    "\n\n作者：.-\n链接：https://leetcode%.cn/.-\n来源：力扣（LeetCode）\n著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。",
    "\n\n来源：力扣（LeetCode）\n链接：https://leetcode%.cn/.-\n著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。",
    -- 可以在这里添加更多需要移除的尾巴模式
}

local function cleanClipboard()
    local currentChange = hs.pasteboard.changeCount()
    if currentChange == lastChange then
        return  -- 剪贴板没有变化，直接返回
    end
    lastChange = currentChange

    local clipboardContents = hs.pasteboard.getContents()
    if clipboardContents then
        print("Original clipboard content:", clipboardContents)
        local originalLength = #clipboardContents
        local cleaned = false
        for _, pattern in ipairs(tailsPattern) do
            local newContent, count = string.gsub(clipboardContents, pattern, "")
            if count > 0 then
                clipboardContents = newContent
                cleaned = true
                break  -- 如果找到匹配的模式，就停止循环
            end
        end
        -- 移除尾部的空白字符
        clipboardContents = clipboardContents:gsub("%s+$", "")
        print("Processed clipboard content:", clipboardContents)
        if cleaned or #clipboardContents ~= originalLength then
            hs.pasteboard.setContents(clipboardContents)
            hs.alert.show("Clipboard content has been cleaned")
        end
    else
        print("Clipboard is empty or contains non-text content")
    end
end

-- 使用 hs.timer 创建剪切板观察器
local clipboardWatcher = hs.timer.new(0.5, cleanClipboard)
clipboardWatcher:start()

hs.alert.show("Clipboard watcher has been started")
print("Clipboard watcher has been started")
