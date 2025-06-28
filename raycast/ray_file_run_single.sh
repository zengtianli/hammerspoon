#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title file_run_single
# @raycast.mode silent
# @raycast.icon 🚀
# @raycast.packageName Custom
# @raycast.description Run selected shell or python script

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILE=$(get_finder_selection_single)
if [ -z "$SELECTED_FILE" ]; then
    show_error "没有在Finder中选择文件"
    exit 1
fi

# 获取文件扩展名
FILE_EXT="${SELECTED_FILE##*.}"

# Check if it's a shell script or python file
if [ "$FILE_EXT" = "sh" ] || [ "$FILE_EXT" = "py" ]; then
    # For shell scripts, make sure they are executable
    if [ "$FILE_EXT" = "sh" ] && [ ! -x "$SELECTED_FILE" ]; then
        chmod +x "$SELECTED_FILE"
    fi
    
    # Get the directory of the script
    SCRIPT_DIR=$(dirname "$SELECTED_FILE")
    
    # Change to the script's directory and run it
    safe_cd "$SCRIPT_DIR" || exit 1
    if [ "$FILE_EXT" = "py" ]; then
        output=$("$PYTHON_PATH" "$SELECTED_FILE" 2>&1)
    else
        output=$("$SELECTED_FILE" 2>&1)
    fi
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        show_success "成功运行了 $(basename "$SELECTED_FILE")"
        echo "输出:"
        echo "$output"
    else
        show_error "运行失败: $(basename "$SELECTED_FILE")"
        echo "错误输出:"
        echo "$output"
        exit 1
    fi
else
    show_error "选中的文件不是shell脚本或python文件"
    exit 1
fi
