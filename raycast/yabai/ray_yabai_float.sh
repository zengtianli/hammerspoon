#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Yabai Float
# @raycast.mode silent
# @raycast.icon 🪪
# @raycast.packageName Custom
# @raycast.description Toggle current window floating and center display

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 检查yabai脚本是否存在
YABAI_SCRIPT="$SCRIPTS_DIR/execute/yabai/yabai-float.sh"
if [ ! -f "$YABAI_SCRIPT" ]; then
    show_error "yabai浮动切换脚本不存在: $YABAI_SCRIPT"
    exit 1
fi

# 显示处理信息
show_processing "正在切换窗口浮动/平铺状态..."

# 执行切换窗口浮动/平铺的脚本
if "$YABAI_SCRIPT"; then
    show_success "窗口浮动/平铺状态已切换"
else
    show_error "窗口状态切换失败"
    exit 1
fi
