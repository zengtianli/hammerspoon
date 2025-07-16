#!/bin/bash

# 移动鼠标到当前活动窗口中心
# 使用更简单的方法避免权限问题
osascript -e '
tell application "System Events"
    try
        set frontApp to first application process whose frontmost is true
        set frontWindow to first window of frontApp
        set windowPosition to position of frontWindow
        set windowSize to size of frontWindow
        
        set centerX to (item 1 of windowPosition) + (item 1 of windowSize) / 2
        set centerY to (item 2 of windowPosition) + (item 2 of windowSize) / 2
        
        -- 转换为整数坐标避免小数点问题
        set centerXInt to round centerX
        set centerYInt to round centerY
        
        -- 使用 cliclick 移动鼠标
        do shell script "cliclick m:" & centerXInt & "," & centerYInt
        return "success"
    on error errMsg
        return "error: " & errMsg
    end try
end tell'

echo "鼠标移动脚本执行完成" 
