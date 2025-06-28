#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title csv_to_xlsx
# @raycast.mode silent
# @raycast.icon 📂
# @raycast.packageName Custom
# @raycast.description Convert csv files to xlsx in current Finder directory

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILE=$(get_finder_selection_single)
if [ -z "$SELECTED_FILE" ]; then
    show_error "没有在 Finder 中选择任何文件"
    exit 1
fi

# 检查文件类型
if ! check_file_extension "$SELECTED_FILE" "csv"; then
    show_error "选中的不是 CSV 文件"
    exit 1
fi

# 获取文件目录
FILE_DIR=$(dirname "$SELECTED_FILE")

# 切换到文件目录
safe_cd "$FILE_DIR" || exit 1

# 显示处理信息
show_processing "正在将 $(basename "$SELECTED_FILE") 转换为 XLSX 格式..."

# 执行Python脚本
if "$PYTHON_PATH" "$CONVERT_CSV_TO_XLSX" "$SELECTED_FILE"; then
    show_success "已将 $(basename "$SELECTED_FILE") 转换为 XLSX 格式，保存在 $(basename "$FILE_DIR")"
else
    show_error "转换失败"
    exit 1
fi
