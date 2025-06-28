#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title docx_to_md
# @raycast.mode silent
# @raycast.icon 📂
# @raycast.packageName Custom
# @raycast.description 将选中的Docx文件或文件夹转换为Markdown

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 检查原始转换脚本是否存在
CONVERT_SCRIPT="$CONVERT_DOCX_TO_MD"
if [ ! -f "$CONVERT_SCRIPT" ]; then
    show_error "找不到原始脚本: $CONVERT_SCRIPT"
    exit 1
fi

# 获取Finder中选中的文件或文件夹
SELECTED_ITEMS=$(get_finder_selection_multiple)
if [ -z "$SELECTED_ITEMS" ]; then
    show_error "没有在 Finder 中选择任何文件或文件夹"
    exit 1
fi

# 分割逗号分隔的列表
IFS=',' read -ra ITEM_ARRAY <<< "$SELECTED_ITEMS"

# 计数器
SUCCESS_COUNT=0
FILE_COUNT=0
DIR_COUNT=0

# 处理每个选中的项目
for SELECTED_ITEM in "${ITEM_ARRAY[@]}"; do
    # 检查是文件还是目录
    if [ -d "$SELECTED_ITEM" ]; then
        show_processing "处理文件夹: $(basename "$SELECTED_ITEM")"
        ((DIR_COUNT++))
        
        # 调用原始脚本处理文件夹
        bash "$CONVERT_SCRIPT" "$SELECTED_ITEM"
        
        # 计算转换文件数
        CONVERTED_FILES=$(find "$SELECTED_ITEM" -type f -name "*.md" -newer "$SELECTED_ITEM")
        CONVERTED_COUNT=$(echo "$CONVERTED_FILES" | grep -c "^")
        SUCCESS_COUNT=$((SUCCESS_COUNT + CONVERTED_COUNT))
        
    elif [ -f "$SELECTED_ITEM" ]; then
        ((FILE_COUNT++))
        
        # 检查是否为docx文件
        if ! check_file_extension "$SELECTED_ITEM" "docx"; then
            show_warning "跳过: $(basename "$SELECTED_ITEM") - 不是docx文件"
            continue
        fi
        
        # 获取文件目录
        FILE_DIR=$(dirname "$SELECTED_ITEM")
        # 切换到文件目录
        safe_cd "$FILE_DIR" || continue
        
        # 运行转换
        output_file="${SELECTED_ITEM%.docx}.md"
        show_processing "正在转换: $(basename "$SELECTED_ITEM") -> $(basename "$output_file")"
        
        # 检查命令是否存在
        check_command_exists "markitdown" || continue
        
        # 执行转换
        if markitdown "$SELECTED_ITEM" > "$output_file" 2>/dev/null; then
            show_success "转换完成: $(basename "$output_file")"
            ((SUCCESS_COUNT++))
        else
            show_error "转换失败: $(basename "$SELECTED_ITEM")"
        fi
    fi
done

# 显示成功通知
if [ $FILE_COUNT -gt 0 ] && [ $DIR_COUNT -gt 0 ]; then
    show_success "成功转换了 $SUCCESS_COUNT 个文件 (来自 $FILE_COUNT 个文件和 $DIR_COUNT 个文件夹)"
elif [ $DIR_COUNT -gt 0 ]; then
    show_success "成功转换了 $SUCCESS_COUNT 个文件 (来自 $DIR_COUNT 个文件夹)"
elif [ $SUCCESS_COUNT -eq 0 ]; then
    show_warning "没有文件被转换"
elif [ $SUCCESS_COUNT -eq 1 ]; then
    show_success "成功转换了 1 个文件"
else
    show_success "成功转换了 $SUCCESS_COUNT 个文件"
fi

