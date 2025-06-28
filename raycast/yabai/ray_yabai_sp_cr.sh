#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Yabai Create Space
# @raycast.mode silent
# @raycast.icon 🪪
# @raycast.packageName Custom
# @raycast.description Create a new space in Yabai

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 检查创建空间脚本是否存在
SPACE_SCRIPT="$SCRIPTS_DIR/execute/yabai/space_create.sh"
if [ ! -f "$SPACE_SCRIPT" ]; then
    show_error "yabai创建空间脚本不存在: $SPACE_SCRIPT"
    exit 1
fi

# 显示处理信息
show_processing "正在创建新空间..."

# 执行创建空间脚本
if "$SPACE_SCRIPT"; then
    show_success "新空间已创建"
else
    show_error "创建空间失败"
    exit 1
fi
