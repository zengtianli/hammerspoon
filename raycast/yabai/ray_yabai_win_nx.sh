#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Yabai Window Move Next
# @raycast.mode silent
# @raycast.icon 🪟
# @raycast.packageName Custom
# @raycast.description Move window to next space in Yabai

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 执行窗口移动到下一个空间脚本
/Users/tianli/useful_scripts/execute/yabai/window_mv_next.sh

show_success "窗口已移动到下一个空间"
