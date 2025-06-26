#!/bin/bash

# 鼠标跟随守护进程
STATUS_FILE="/tmp/mouse_follow_status"
# 获取脚本的绝对路径
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 记录当前活动应用
last_app=""

while [ -f "$STATUS_FILE" ]; do
    # 获取当前活动应用信息（只关注应用，不关注窗口）
    current_app=$(osascript -e '
    try
        tell application "System Events"
            set frontApp to first application process whose frontmost is true
            return name of frontApp
        end tell
    on error
        return ""
    end try')
    
    # 如果应用发生变化，移动鼠标到中心
    if [ "$current_app" != "$last_app" ] && [ "$current_app" != "" ]; then
        "$SCRIPT_DIR/mouse_center.sh" > /dev/null 2>&1
        last_app="$current_app"
    fi
    
    # 等待0.1秒再检查
    sleep 0.1
done

echo "鼠标跟随守护进程已停止" 