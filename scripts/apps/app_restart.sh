#!/bin/bash

# 获取前台应用名称
APP_NAME=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

if [ -z "$APP_NAME" ]; then
    echo "无法获取前台应用"
    osascript -e 'display notification "无法获取前台应用" with title "应用重启"'
    exit 1
fi

echo "正在重启: $APP_NAME"
osascript -e "display notification \"正在重启: $APP_NAME\" with title \"应用重启\""

# 杀死应用
osascript -e "tell application \"$APP_NAME\" to quit"
sleep 0.2

# 重新启动应用
open -a "$APP_NAME"

echo "已重启: $APP_NAME"
osascript -e "display notification \"已重启: $APP_NAME\" with title \"应用重启\"" 