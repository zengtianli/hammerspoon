#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title tool_split_excel
# @raycast.mode silent
# @raycast.icon 📂
# @raycast.packageName Custom
# @raycast.description Split the selected Excel file into separate sheets

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILE=$(get_finder_selection_single)

# 检查是否选择了一个文件
if [ -z "$SELECTED_FILE" ]; then
    show_error "请在Finder中选择一个Excel文件"
    exit 1
fi

# 检查是否为Excel文件
if ! (check_file_extension "$SELECTED_FILE" "xlsx" || check_file_extension "$SELECTED_FILE" "xls"); then
    show_error "选中的不是Excel文件"
    exit 1
fi

# 获取文件目录
FILE_DIR=$(dirname "$SELECTED_FILE")

# 切换到文件目录
safe_cd "$FILE_DIR" || exit 1

# 运行splitsheets.py脚本
if "$PYTHON_PATH" "$SCRIPTS_DIR/execute/splitsheets.py" "$SELECTED_FILE"; then
    show_success "Excel工作表拆分完成: $(basename "$SELECTED_FILE")"
else
    show_error "Excel工作表拆分失败"
    exit 1
fi

