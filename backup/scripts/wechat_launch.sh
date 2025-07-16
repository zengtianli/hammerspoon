#!/bin/bash

# 检查微信是否正在运行
if pgrep -f "WeChat" > /dev/null; then
    # 激活微信并发送回车键
    osascript -e '
    tell application "WeChat"
        activate
    end tell
    '
else
    echo "微信未运行，正在启动..."
    
    # 启动微信，等待加载后发送回车键
    osascript -e '
    tell application "WeChat"
        activate
    end tell
    delay 0.4
    tell application "System Events"
        key code 36
    end tell
    '
    echo "微信已启动并发送回车键"
fi 
