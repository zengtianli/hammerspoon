local common = require("lua.common_functions")
local M = common.createStandardModule("位置记录工具")
M.config = common.merge(M.config, { enableClick = true, enableRecord = true, maxPositions = 10 })
M.positions = {}
M.currentIndex = 1
M.originalPosition = nil
function M.getCurrentApp()
    local app = hs.application.frontmostApplication()
    return app and app:name() or "Unknown"
end

function M.recordPosition()
    if not M.config.enableRecord then
        common.showWarning("位置记录功能已禁用"); return false
    end
    local currentApp = M.getCurrentApp()
    local mousePos = hs.mouse.absolutePosition()
    if not M.positions[currentApp] then M.positions[currentApp] = {} end
    local positions = M.positions[currentApp]
    if #positions >= M.config.maxPositions then
        table.remove(positions, 1)
    end
    table.insert(positions, { x = mousePos.x, y = mousePos.y, timestamp = os.time() })
    common.showSuccess("已记录位置 #" .. #positions .. " for " .. currentApp)
    return true
end

function M.clearPositions()
    local currentApp = M.getCurrentApp()
    M.positions[currentApp] = {}
    M.currentIndex = 1
    common.showInfo("已清除 " .. currentApp .. " 的记录位置")
end

function M.moveToPosition(index)
    local currentApp = M.getCurrentApp()
    local positions = M.positions[currentApp]
    if not positions or #positions == 0 then
        common.showWarning("没有记录的位置"); return false
    end
    if index < 1 or index > #positions then
        common.showError("位置索引无效: " .. index); return false
    end
    local pos = positions[index]
    hs.mouse.absolutePosition({ x = pos.x, y = pos.y })
    if M.config.enableClick then
        hs.timer.doAfter(0.1, function() hs.eventtap.leftClick(pos) end)
    end
    common.showInfo("移动到位置 #" .. index)
    return true
end

function M.moveToNext()
    local currentApp = M.getCurrentApp()
    local positions = M.positions[currentApp]
    if not positions or #positions == 0 then return false end
    M.currentIndex = (M.currentIndex % #positions) + 1
    return M.moveToPosition(M.currentIndex)
end

function M.moveToPrevious()
    local currentApp = M.getCurrentApp()
    local positions = M.positions[currentApp]
    if not positions or #positions == 0 then return false end
    M.currentIndex = ((M.currentIndex - 2) % #positions) + 1
    return M.moveToPosition(M.currentIndex)
end

function M.visitAllPositions(returnToOriginal)
    local currentApp = M.getCurrentApp()
    local positions = M.positions[currentApp]
    if not positions or #positions == 0 then
        common.showWarning("没有记录的位置"); return false
    end
    if returnToOriginal then
        M.originalPosition = hs.mouse.absolutePosition()
    end
    local function visitNext(index)
        if index > #positions then
            if returnToOriginal and M.originalPosition then
                hs.timer.doAfter(0.5, function()
                    hs.mouse.absolutePosition(M.originalPosition)
                    common.showInfo("已返回原位置")
                end)
            end
            return
        end
        M.moveToPosition(index)
        hs.timer.doAfter(1.0, function() visitNext(index + 1) end)
    end
    visitNext(1)
    return true
end

function M.updateCurrentPosition()
    local currentApp = M.getCurrentApp()
    local positions = M.positions[currentApp]
    if not positions or #positions == 0 then
        common.showWarning("没有记录的位置"); return false
    end
    local mousePos = hs.mouse.absolutePosition()
    positions[M.currentIndex] = { x = mousePos.x, y = mousePos.y, timestamp = os.time() }
    common.showSuccess("已更新位置 #" .. M.currentIndex)
    return true
end

function M.toggleClick()
    M.config.enableClick = not M.config.enableClick
    common.showInfo("点击功能: " .. (M.config.enableClick and "启用" or "禁用"))
end

function M.toggleRecord()
    M.config.enableRecord = not M.config.enableRecord
    common.showInfo("位置记录: " .. (M.config.enableRecord and "启用" or "禁用"))
end

function M.checkDeps()
    return common.checkModule("hs.mouse") and common.checkModule("hs.eventtap") and common.checkModule("hs.application")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "ctrl", "shift" }, "R", M.recordPosition, "记录位置")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "C", M.clearPositions, "清除位置")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "1", function() M.moveToPosition(1) end, "移动到位置1")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "2", function() M.moveToPosition(2) end, "移动到位置2")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "3", function() M.moveToPosition(3) end, "移动到位置3")
    M:addHotkey({ "alt" }, "`", M.moveToNext, "下一个位置")
    M:addHotkey({ "alt", "shift" }, "`", M.moveToPrevious, "上一个位置")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "V", function() M.visitAllPositions(false) end, "批量访问位置")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "B", function() M.visitAllPositions(true) end, "批量访问位置(返回)")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "U", M.updateCurrentPosition, "更新当前位置")
    M:addHotkey({ "cmd", "ctrl", "shift", "alt" }, "C", M.toggleClick, "切换点击功能")
    M:addHotkey({ "cmd", "ctrl", "shift", "alt" }, "R", M.toggleRecord, "切换记录功能")
    common.showInfo("位置记录工具热键已设置")
end

if M.config.enabled then M:init() end
return M
