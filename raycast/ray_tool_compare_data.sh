#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title tool_compare_excel_data
# @raycast.mode fullOutput
# @raycast.icon 📊
# @raycast.packageName Custom
# @raycast.description 精确比较两个选中的Excel文件的数据差异

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILES=$(get_finder_selection_multiple)

# 检查是否选择了恰好两个文件
if [ -z "$SELECTED_FILES" ]; then
    show_error "请在Finder中选择恰好两个Excel文件"
    exit 1
fi

# 将选中的文件分割为数组
IFS=',' read -ra FILES_ARRAY <<< "$SELECTED_FILES"

# 检查文件数量
if [ ${#FILES_ARRAY[@]} -ne 2 ]; then
    show_error "请选择恰好两个Excel文件进行比较"
    exit 1
fi

# 验证文件扩展名
for file in "${FILES_ARRAY[@]}"; do
    if ! (check_file_extension "$file" "xlsx" || check_file_extension "$file" "xls"); then
        show_error "只支持 .xlsx 和 .xls 格式的Excel文件: $(basename "$file")"
        exit 1
    fi
done

show_processing "正在比较Excel文件数据..."

# 运行Python脚本
if "$PYTHON_PATH" "$SCRIPTS_DIR/execute/compare/compare_excel_data.py" "${FILES_ARRAY[0]}" "${FILES_ARRAY[1]}"; then
    show_success "Excel数据比较完成"
    echo "✓ 文件1: $(basename "${FILES_ARRAY[0]}")"
    echo "✓ 文件2: $(basename "${FILES_ARRAY[1]}")"
else
    show_error "Excel数据比较失败"
    exit 1
fi
