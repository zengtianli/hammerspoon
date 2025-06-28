#!/bin/bash

# 停止宏录制脚本
RECORD_FILE="/tmp/hammerspoon_macro.txt"
STATUS_FILE="/tmp/hammerspoon_macro_recording"

if [ -f "$STATUS_FILE" ]; then
    # 停止录制
    rm "$STATUS_FILE"
    
    if [ -f "$RECORD_FILE" ]; then
        COUNT=$(wc -l < "$RECORD_FILE")
        echo "宏录制已停止，共录制了 $COUNT 个位置"
        osascript -e "display notification \"宏录制已停止，共录制了 $COUNT 个位置\" with title \"宏录制\""
    else
        echo "宏录制已停止"
        osascript -e 'display notification "宏录制已停止" with title "宏录制"'
    fi
else
    echo "当前没有正在进行的录制"
    osascript -e 'display notification "当前没有正在进行的录制" with title "宏录制"'
fi 