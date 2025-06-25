local common = require("lua.common_functions")
local M = common.createAppModule("音乐控制", "Music")
M.config.scriptsDir = os.getenv("HOME") .. "/useful_scripts"

local function launchMusic()
    local scriptPath = M.config.scriptsDir .. "/music.applescript"
    if common.fileExists(scriptPath) then
        hs.osascript.applescriptFromFile(scriptPath); hs.timer.usleep(500000); return M:get()
    end
    common.showWarning("音乐脚本不存在: " .. scriptPath); return nil
end

function M.togglePlayback()
    local app = M:get() or launchMusic()
    if not app then
        common.showError("无法启动音乐应用"); return
    end
    local pauseItem, playItem = app:findMenuItem({ "Controls", "Pause" }), app:findMenuItem({ "Controls", "Play" })
    if pauseItem then
        app:selectMenuItem({ "Controls", "Pause" }); common.showInfo("音乐已暂停")
    elseif playItem then
        app:selectMenuItem({ "Controls", "Play" }); common.showInfo("音乐已播放")
    else
        common.showWarning("播放控制不可用")
    end
end

function M.nextTrack() return M:menuAction({ "Controls", "Next Track" }, "下一首") end

function M.previousTrack() return M:menuAction({ "Controls", "Previous Track" }, "上一首") end

function M.volumeControl(direction)
    return function()
        hs.application.launchOrFocus("Music")
        local app = M:get()
        if app then
            app:selectMenuItem({ "Controls", direction }); common.showInfo("音量" .. direction)
        else
            common.showError("音乐应用不可用")
        end
    end
end

function M.systemPlayPause()
    hs.eventtap.event.newSystemKeyEvent("PLAY", true):post()
    hs.eventtap.event.newSystemKeyEvent("PLAY", false):post()
    common.showInfo("系统播放/暂停")
end

function M.toggleAirpodsNoise()
    local scriptPath = M.config.scriptsDir .. "/airpods.scpt"
    if not common.fileExists(scriptPath) then
        common.showError("AirPods脚本不存在: " .. scriptPath); return false
    end
    local output, status = hs.osascript.applescriptFromFile(scriptPath)
    if status then
        common.showSuccess("切换到: " .. (output or "未知模式")); return true
    end
    common.showError("AirPods噪音控制切换失败"); return false
end

function M.checkDeps()
    return common.checkModule("hs.appfinder") and common.checkModule("hs.hotkey") and
        common.checkModule("hs.osascript")
end

function M.setupHotkeys()
    M:addHotkey({ "cmd", "ctrl", "shift" }, ';', M.togglePlayback, "播放/暂停")
    M:addHotkey({ "cmd", "ctrl", "shift" }, '\'', M.nextTrack, "下一首")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "p", M.systemPlayPause, "系统播放控制")
    M:addHotkey({ "cmd", "ctrl", "shift" }, "l", M.toggleAirpodsNoise, "AirPods噪音控制")
    common.showInfo("音乐控制热键已设置")
end

if M.config.enabled then M:init() end
return M
