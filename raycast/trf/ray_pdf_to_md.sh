#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title pdf_to_md
# @raycast.mode silent
# @raycast.icon 📄
# @raycast.packageName Custom
# @raycast.description Convert selected PDF files to markdown using marker_single

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILES=$(get_finder_selection_multiple)
if [ -z "$SELECTED_FILES" ]; then
    show_error "没有在 Finder 中选择任何文件"
    exit 1
fi

# Split the comma-separated list of files
IFS=',' read -ra FILE_ARRAY <<< "$SELECTED_FILES"

# Counter for successful conversions
SUCCESS_COUNT=0

# 处理每个文件
for SELECTED_FILE in "${FILE_ARRAY[@]}"; do
    # 获取文件目录
    FILE_DIR=$(dirname "$SELECTED_FILE")
    
    # 检查是否为PDF文件
    if ! check_file_extension "$SELECTED_FILE" "pdf"; then
        show_warning "跳过: $(basename "$SELECTED_FILE") - 不是 PDF 文件"
        continue
    fi
    
    # 切换到文件目录
    if ! safe_cd "$FILE_DIR"; then
        continue
    fi
    
    # 使用marker_single执行转换
    show_processing "正在将 $(basename "$SELECTED_FILE") 转换为 Markdown..."
    
    # 检查命令是否存在
    if ! check_command_exists "marker_single"; then
        # 尝试使用完整路径
        if [ -x "$MINIFORGE_BIN/marker_single" ]; then
            "$MINIFORGE_BIN/marker_single" "$SELECTED_FILE" --output_dir "$FILE_DIR"
        else
            show_error "marker_single命令不存在"
            continue
        fi
    else
        marker_single "$SELECTED_FILE" --output_dir "$FILE_DIR"
    fi
    
    # Increment success counter
    ((SUCCESS_COUNT++))
done

# 显示成功通知
if [ $SUCCESS_COUNT -eq 0 ]; then
    show_warning "没有文件被转换"
elif [ $SUCCESS_COUNT -eq 1 ]; then
    show_success "成功转换了 1 个 PDF 文件为 Markdown"
else
    show_success "成功转换了 $SUCCESS_COUNT 个 PDF 文件为 Markdown"
fi
