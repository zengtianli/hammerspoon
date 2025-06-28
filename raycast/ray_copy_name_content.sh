#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title copy_name_content
# @raycast.mode silent
# @raycast.icon 📋
# @raycast.packageName Custom
# @raycast.description Copy selected file's filename and content to clipboard

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILES=$(get_finder_selection_multiple)
if [ -z "$SELECTED_FILES" ]; then
    show_error "在Finder中未选择文件"
    exit 1
fi

# 临时文件用于存储所有内容
TEMP_FILE=$(mktemp)

# 计数器
FILE_COUNT=0

# 分割逗号分隔的文件列表
IFS=',' read -ra FILE_ARRAY <<< "$SELECTED_FILES"

# 处理每个选中的文件
for FILE_PATH in "${FILE_ARRAY[@]}"; do
    # 获取文件名（不含路径）
    FILENAME=$(basename "$FILE_PATH")
    
    # 检查文件是否可读
    if [ ! -r "$FILE_PATH" ]; then
        show_warning "无法读取文件：$FILENAME"
        continue
    fi
    
    # 将文件名和内容添加到临时文件
    echo -e "文件名：$FILENAME\n" >> "$TEMP_FILE"
    cat "$FILE_PATH" >> "$TEMP_FILE"
    echo -e "\n-----------------------------------\n" >> "$TEMP_FILE"
    
    FILE_COUNT=$((FILE_COUNT+1))
done

# 将临时文件内容复制到粘贴板
cat "$TEMP_FILE" | pbcopy

# 删除临时文件
rm -f "$TEMP_FILE"

# 显示通知
if [ $FILE_COUNT -eq 1 ]; then
    show_success "已复制 1 个文件的名称和内容到粘贴板"
else
    show_success "已复制 $FILE_COUNT 个文件的名称和内容到粘贴板"
fi
