#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title yabai Org
# @raycast.mode fullOutput
# @raycast.icon 🪪
# @raycast.packageName Custom
# @raycast.description 根据预定义的规则自动将应用程序窗口整理到指定的显示器/工作区

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 检查窗口整理脚本是否存在
ORG_SCRIPT="$SCRIPTS_DIR/execute/yabai/org_windows.sh"
if [ ! -f "$ORG_SCRIPT" ]; then
    show_error "yabai窗口整理脚本不存在: $ORG_SCRIPT"
    exit 1
fi

# 显示处理信息
show_processing "正在根据规则整理窗口..."

# 调用窗口整理脚本
if "$ORG_SCRIPT"; then
    show_success "窗口整理完成"
else
    show_error "窗口整理失败"
    exit 1
fi
