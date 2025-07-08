#!/bin/bash

# 检查 Zen 是否正在运行
if pgrep -f "Zen" > /dev/null; then
    echo "Zen 正在运行，切换媒体播放状态..."
    
    # 记录当前活动的应用，然后激活 Zen 并发送空格键来切换播放/暂停
    osascript -e '
    -- 获取当前前台应用
    tell application "System Events"
        set frontApp to name of first application process whose frontmost is true
    end tell
    
    -- 激活 Zen
    tell application "Zen"
        activate
    end tell
    delay 0.8
    
    -- 发送空格键
    tell application "System Events"
        key code 49
    end tell
    
    delay 0.2
    
    -- 回到之前的应用
    tell application "System Events"
        tell application process frontApp
            set frontmost to true
        end tell
    end tell'
    
    echo "已发送播放/暂停指令到 Zen，并回到之前的应用"
else
    echo "Zen 未运行，正在启动..."
    # 打开 Ze 
    open -a "Zen"
fi 
