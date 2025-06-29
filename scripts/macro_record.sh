#!/bin/bash

# 宏录制脚本 - 记录当前鼠标位置
RECORD_FILE="/tmp/hammerspoon_macro.txt"
STATUS_FILE="/tmp/hammerspoon_macro_recording"

# 检查是否正在录制
if [ -f "$STATUS_FILE" ]; then
    # 正在录制中，记录当前鼠标位置
    MOUSE_POS=$(cliclick p)
    
    # 保存到文件
    echo "$MOUSE_POS" >> "$RECORD_FILE"
    
    # 获取已录制的操作数量
    COUNT=$(wc -l < "$RECORD_FILE")
    echo "已记录位置 $COUNT: $MOUSE_POS"
    osascript -e "display notification \"已记录位置 $COUNT: $MOUSE_POS\" with title \"宏录制\""
else
    # 开始录制
    touch "$STATUS_FILE"
    echo "" > "$RECORD_FILE"  # 清空之前的录制
    
    echo "宏录制已开始"
    osascript -e 'display notification "宏录制已开始" with title "宏录制"'
fi 