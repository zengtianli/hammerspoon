#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title manage_app_launcher
# @raycast.mode silent
# @raycast.icon 🚀
# @raycast.packageName Custom
# @raycast.description 根据桌面上的essential_apps.txt列表启动必要的应用程序

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 调用manage_app_launcher.sh脚本
SCRIPT_PATH="$SCRIPTS_DIR/execute/manage_app_launcher.sh"

# 检查脚本是否存在
if [ ! -f "$SCRIPT_PATH" ]; then
    show_error "脚本文件不存在: $SCRIPT_PATH"
    exit 1
fi

# 执行脚本
OUTPUT=$("$SCRIPT_PATH" 2>&1)
EXIT_STATUS=$?

# 检查执行结果
if [ $EXIT_STATUS -eq 0 ]; then
    # 成功执行
    LAUNCHED_COUNT=$(echo "$OUTPUT" | grep "✅ 成功启动:" | wc -l | tr -d ' ')
    ALREADY_RUNNING_COUNT=$(echo "$OUTPUT" | grep "✓" | wc -l | tr -d ' ')
    
    if [ "$LAUNCHED_COUNT" -gt 0 ]; then
        show_success "已成功启动 $LAUNCHED_COUNT 个应用程序"
        if [ "$ALREADY_RUNNING_COUNT" -gt 0 ]; then
            show_info "另有 $ALREADY_RUNNING_COUNT 个应用程序已在运行"
        fi
    else
        show_success "所有必要应用程序已经在运行 ($ALREADY_RUNNING_COUNT 个)"
    fi
else
    # 执行失败
    ERROR_MSG=$(echo "$OUTPUT" | grep "错误:" | head -1)
    if [ -z "$ERROR_MSG" ]; then
        ERROR_MSG="未知错误"
    fi
    show_error "$ERROR_MSG"
    exit 1
fi
