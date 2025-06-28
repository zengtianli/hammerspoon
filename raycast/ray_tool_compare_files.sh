#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title tool_compare_files
# @raycast.mode fullOutput
# @raycast.icon 📁
# @raycast.packageName Custom
# @raycast.description 比较两个选中的文件或文件夹的差异

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILES=$(get_finder_selection_multiple)

# 检查是否选择了恰好两个文件/文件夹
if [ -z "$SELECTED_FILES" ]; then
    show_error "请在Finder中选择恰好两个文件或文件夹"
    exit 1
fi

# 将选中的文件分割为数组
IFS=',' read -ra FILES_ARRAY <<< "$SELECTED_FILES"

# 检查文件数量
if [ ${#FILES_ARRAY[@]} -ne 2 ]; then
    show_error "请选择恰好两个文件或文件夹进行比较"
    exit 1
fi

# 验证路径存在性
for path in "${FILES_ARRAY[@]}"; do
    if [ ! -e "$path" ]; then
        show_error "路径不存在: $(basename "$path")"
        exit 1
    fi
    
    if [ ! -r "$path" ]; then
        show_error "路径不可读: $(basename "$path")"
        exit 1
    fi
done

# 显示比较信息
show_processing "正在比较文件/文件夹..."

ITEM1="${FILES_ARRAY[0]}"
ITEM2="${FILES_ARRAY[1]}"

echo "📋 比较项目:"
if [ -f "$ITEM1" ]; then
    echo "  📄 文件1: $(basename "$ITEM1")"
elif [ -d "$ITEM1" ]; then
    echo "  📁 文件夹1: $(basename "$ITEM1")"
fi

if [ -f "$ITEM2" ]; then
    echo "  📄 文件2: $(basename "$ITEM2")"
elif [ -d "$ITEM2" ]; then
    echo "  📁 文件夹2: $(basename "$ITEM2")"
fi

echo ""

# 运行Python脚本
if "$PYTHON_PATH" "$SCRIPTS_DIR/execute/compare/compare_files_folders.py" "$ITEM1" "$ITEM2"; then
    echo ""
    show_success "文件/文件夹比较完成"
else
    show_error "文件/文件夹比较失败"
    exit 1
fi 