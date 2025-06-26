#!/bin/bash

# 状态文件路径
STATUS_FILE="/tmp/mouse_follow_status"
SCRIPT_DIR="$(dirname "$0")"
# 获取脚本的绝对路径
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 检查当前状态
if [ -f "$STATUS_FILE" ]; then
    # 如果状态文件存在，说明跟随功能已启用，需要关闭
    rm "$STATUS_FILE"
    
    # 杀死可能正在运行的监听进程
    pkill -f "mouse_follow_daemon"
    
    echo "鼠标跟随已禁用"
    osascript -e 'display notification "鼠标跟随已禁用" with title "鼠标跟随"'
else
    # 如果状态文件不存在，说明跟随功能未启用，需要开启
    touch "$STATUS_FILE"
    
    # 启动后台监听进程
    nohup "$SCRIPT_DIR/mouse_follow_daemon.sh" > /dev/null 2>&1 &
    
    echo "鼠标跟随已启用"
    osascript -e 'display notification "鼠标跟随已启用" with title "鼠标跟随"'
fi 