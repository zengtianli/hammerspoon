#!/bin/bash

# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title manage_terminate_python
# @raycast.mode fullOutput
# @raycast.icon ⏹️
# @raycast.packageName Custom

# Documentation:
# @raycast.description Terminate all running Python processes

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# Kill all Python processes
pkill -f python

# 或者使用更严格的方式:
# pkill -9 -f python

show_success "所有Python进程已终止"

