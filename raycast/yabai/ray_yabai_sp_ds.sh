#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Yabai Destroy Space
# @raycast.mode silent
# @raycast.icon 🪪
# @raycast.packageName Custom
# @raycast.description Destroy current space in Yabai

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 检查销毁空间脚本是否存在
SPACE_SCRIPT="$SCRIPTS_DIR/execute/yabai/space_destroy.sh"
if [ ! -f "$SPACE_SCRIPT" ]; then
    show_error "yabai销毁空间脚本不存在: $SPACE_SCRIPT"
    exit 1
fi

# 显示处理信息
show_processing "正在销毁当前空间..."

# 执行销毁空间脚本
if "$SPACE_SCRIPT"; then
    show_success "当前空间已销毁"
else
    show_error "销毁空间失败"
    exit 1
fi
