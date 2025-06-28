#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title txt_to_xlsx
# @raycast.mode silent
# @raycast.icon 📊
# @raycast.packageName Custom
# @raycast.description Convert txt files to xlsx in current Finder directory

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILES=$(get_finder_selection_multiple)
if [ -z "$SELECTED_FILES" ]; then
    show_error "没有在 Finder 中选择任何文件"
    exit 1
fi

# 将选中的文件分割为数组
IFS=',' read -ra FILES_ARRAY <<< "$SELECTED_FILES"

# 计数器初始化
SUCCESS_COUNT=0
TOTAL_COUNT=0

# 处理每个选中的文件
for FILE_PATH in "${FILES_ARRAY[@]}"
do
    # 跳过空条目（可能是因为分隔符在末尾）
    if [ -z "$FILE_PATH" ]; then
        continue
    fi

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    
    # 检查文件是否为TXT文件
    if ! check_file_extension "$FILE_PATH" "txt"; then
        show_warning "跳过: $(basename "$FILE_PATH") - 不是 TXT 文件"
        continue
    fi
    
    # 获取文件所在目录
    FILE_DIR=$(dirname "$FILE_PATH")
    
    # 获取文件所在目录
    FILE_DIR=$(dirname "$FILE_PATH")
    
    # 切换到文件目录
    if ! safe_cd "$FILE_DIR"; then
        show_error "无法进入目录: $FILE_DIR"
        continue
    fi
    
    # 显示处理信息
    show_processing "正在将 $(basename "$FILE_PATH") 转换为 XLS 格式..."
    
    # 执行Python脚本处理单个文件
    if "$PYTHON_PATH" "$CONVERT_TXT_TO_XLSX" "$FILE_PATH"; then
        show_success "已将 $(basename "$FILE_PATH") 转换为 XLS 格式"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        show_error "转换失败: $(basename "$FILE_PATH")"
    fi
done

# 显示处理统计
if [ $TOTAL_COUNT -eq 0 ]; then
    show_error "没有找到有效文件"
elif [ $SUCCESS_COUNT -eq 0 ]; then
    show_warning "没有文件被成功转换"
elif [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    show_success "已成功转换所有 $SUCCESS_COUNT 个 TXT 文件到 XLS 格式"
else
    show_warning "已转换 $SUCCESS_COUNT/$TOTAL_COUNT 个 TXT 文件到 XLS 格式"
fi
