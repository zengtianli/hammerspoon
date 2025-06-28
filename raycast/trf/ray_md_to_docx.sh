#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title md_to_docx
# @raycast.mode silent
# @raycast.icon 📂
# @raycast.packageName Custom
# @raycast.description Convert selected markdown file to docx using docx_styler

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILE=$(get_finder_selection_single)
if [ -z "$SELECTED_FILE" ]; then
    show_error "没有在 Finder 中选择任何文件"
    exit 1
fi

# 检查文件类型
if ! check_file_extension "$SELECTED_FILE" "md"; then
    show_error "选中的不是 Markdown 文件"
    exit 1
fi

# 获取文件目录
FILE_DIR=$(dirname "$SELECTED_FILE")

# 切换到文件目录
if ! safe_cd "$FILE_DIR"; then
    exit 1
fi

# 显示处理信息
show_processing "正在将 $(basename "$SELECTED_FILE") 转换为 DOCX 格式..."

# 执行转换
DOCX_STYLER_PATH="/Users/tianli/bendownloads/docx_styler/main.py"
if [ ! -f "$DOCX_STYLER_PATH" ]; then
    show_error "docx_styler 脚本不存在: $DOCX_STYLER_PATH"
    exit 1
fi

if "$PYTHON_PATH" "$DOCX_STYLER_PATH" "$SELECTED_FILE"; then
    show_success "已将 $(basename "$SELECTED_FILE") 转换为 DOCX 格式，保存在 $(basename "$FILE_DIR")"
else
    show_error "转换失败"
    exit 1
fi
