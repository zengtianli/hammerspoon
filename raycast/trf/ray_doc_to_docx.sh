#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title doc_to_docx
# @raycast.mode silent
# @raycast.icon 📄
# @raycast.packageName Custom
# @raycast.description 将选中的Doc文件转换为Docx格式，如无选择则转换当前目录所有doc文件

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 转换单个文件的函数
convert_single_doc() {
    local file_path="$1"
    local filename=$(basename "$file_path")
    local dir=$(dirname "$file_path")
    local name_without_ext="${filename%.*}"
    local docx_file="$dir/${name_without_ext}.docx"
    
    show_processing "正在转换: $filename"
    
    # 使用 AppleScript 转换文件
    osascript -e "tell application \"Microsoft Word\"
        activate
        open POSIX file \"$file_path\"
        save as active document file name \"$docx_file\" file format format document
        close active window saving no
    end tell" 2>/dev/null
    
    # 检查转换是否成功
    if [ -f "$docx_file" ]; then
        show_success "转换完成: ${name_without_ext}.docx"
        return 0
    else
        show_error "转换失败: $filename"
        return 1
    fi
}

# 获取Finder中选中的文件
SELECTED_FILES=$(get_finder_selection_multiple)

# 计数器
SUCCESS_COUNT=0
SKIPPED_COUNT=0

# 如果有选中文件，只转换选中的文件
if [ -n "$SELECTED_FILES" ]; then
    show_processing "转换选中的文件..."
    
    # 分割逗号分隔的文件列表
    IFS=',' read -ra FILE_ARRAY <<< "$SELECTED_FILES"
    
    # 处理每个选中的文件
    for FILE in "${FILE_ARRAY[@]}"; do
        # 获取文件名
        FILENAME=$(basename "$FILE")
        
        # 检查文件扩展名
        if ! check_file_extension "$FILE" "doc"; then
            show_warning "跳过: $FILENAME - 不是 DOC 文件"
            ((SKIPPED_COUNT++))
            continue
        fi
        
        # 检查是否已经是docx文件
        if check_file_extension "$FILE" "docx"; then
            show_warning "跳过: $FILENAME - 已经是 DOCX 格式"
            ((SKIPPED_COUNT++))
            continue
        fi
        
        # 转换文件
        if convert_single_doc "$FILE"; then
            ((SUCCESS_COUNT++))
        else
            ((SKIPPED_COUNT++))
        fi
    done
    
else
    # 如果没有选中文件，转换当前目录下的所有doc文件
    show_processing "未选择文件，转换当前目录下的所有 .doc 文件..."
    
    # 获取当前目录
    CURRENT_DIR=$(get_finder_current_dir)
    if ! safe_cd "$CURRENT_DIR"; then
        show_error "无法进入当前目录"
        exit 1
    fi
    
    # 查找所有doc文件
    shopt -s nullglob
    DOC_FILES=(*.doc)
    shopt -u nullglob
    
    if [ ${#DOC_FILES[@]} -eq 0 ]; then
        show_warning "当前目录没有 .doc 文件"
        exit 0
    fi
    
    # 转换每个doc文件
    for DOC_FILE in "${DOC_FILES[@]}"; do
        # 跳过已经是docx的文件
        if [[ "$DOC_FILE" == *".docx" ]]; then
            continue
        fi
        
        FILE_PATH="$CURRENT_DIR/$DOC_FILE"
        if convert_single_doc "$FILE_PATH"; then
            ((SUCCESS_COUNT++))
        else
            ((SKIPPED_COUNT++))
        fi
    done
fi

# 显示成功通知
if [ $SUCCESS_COUNT -eq 0 ]; then
    show_warning "没有文件被转换"
elif [ $SUCCESS_COUNT -eq 1 ]; then
    show_success "成功转换了 1 个文件"
else
    show_success "成功转换了 $SUCCESS_COUNT 个文件"
fi

if [ $SKIPPED_COUNT -gt 0 ]; then
    show_warning "跳过了 $SKIPPED_COUNT 个文件"
fi
