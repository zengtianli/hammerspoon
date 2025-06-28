#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title file_run_parallel
# @raycast.mode fullOutput
# @raycast.icon 🚀
# @raycast.packageName Custom
# @raycast.description Run multiple selected shell or python scripts in parallel

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取所有选中的文件
SELECTED_FILES=$(get_finder_selection_multiple)
if [ -z "$SELECTED_FILES" ]; then
    show_error "没有在Finder中选择文件"
    exit 1
fi

# 创建临时目录存储日志文件
TEMP_DIR=$(mktemp -d)
FILE_COUNT=0
VALID_COUNT=0

# 运行单个文件的函数
run_file() {
    local file="$1"
    local file_ext="${file##*.}"
    local log_file="$TEMP_DIR/$(basename "$file").log"
    local success_log="$TEMP_DIR/$(basename "$file").success"
    
    # 检查是否为shell脚本或python文件
    if [ "$file_ext" = "sh" ] || [ "$file_ext" = "py" ]; then
        # For shell scripts, make sure they are executable
        if [ "$file_ext" = "sh" ] && [ ! -x "$file" ]; then
            chmod +x "$file"
        fi
        
        # 获取脚本目录
        local script_dir=$(dirname "$file")
        
        # 在脚本目录中运行并捕获输出
        (
            cd "$script_dir"
            if [ "$file_ext" = "py" ]; then
                # 为PyQt6设置环境变量
                local PYQT_PATH=$("$PYTHON_PATH" -c "
import sys
try:
    import PyQt6
    print(PyQt6.__path__[0])
except ImportError:
    print('')
")
                if [ -n "$PYQT_PATH" ]; then
                    local QT_PATH="$PYQT_PATH/Qt6"
                    export QT_PLUGIN_PATH="$QT_PATH/plugins"
                    export QT_QPA_PLATFORM_PLUGIN_PATH="$QT_PATH/plugins/platforms"
                    echo "Using PyQt6 path: $PYQT_PATH" >> "$log_file"
                    export DYLD_LIBRARY_PATH="$QT_PATH/lib:$DYLD_LIBRARY_PATH"
                    export DYLD_FRAMEWORK_PATH="$QT_PATH/lib:$DYLD_FRAMEWORK_PATH"
                fi
                export QT_DEBUG_PLUGINS=1
                "$PYTHON_PATH" "$file" >> "$log_file" 2>&1
            else
                PATH="$MINIFORGE_BIN:$PATH" "$file" > "$log_file" 2>&1
            fi
            echo $? > "$success_log"
        )
    else
        echo "❌ 文件 $(basename "$file") 不是shell脚本或python文件" > "$log_file"
        echo "1" > "$success_log"
    fi
}

# 分割逗号分隔的文件列表
IFS=',' read -ra FILE_ARRAY <<< "$SELECTED_FILES"

# 处理每个选中的文件
for file in "${FILE_ARRAY[@]}"; do
    FILE_COUNT=$((FILE_COUNT + 1))
    FILE_EXT="${file##*.}"
    
    # 检查是否为有效文件类型
    if [ "$FILE_EXT" = "sh" ] || [ "$FILE_EXT" = "py" ]; then
        VALID_COUNT=$((VALID_COUNT + 1))
        # 在后台运行文件
        run_file "$file" &
    else
        show_warning "文件 $(basename "$file") 不是shell脚本或python文件"
    fi
done

show_processing "开始并行运行 $VALID_COUNT/$FILE_COUNT 个文件..."

# 等待所有后台进程完成
wait

# 显示每个文件的结果
echo ""
echo "📊 运行结果:"
echo "========================================"

for file in "${FILE_ARRAY[@]}"; do
    base_name=$(basename "$file")
    log_file="$TEMP_DIR/$base_name.log"
    success_log="$TEMP_DIR/$base_name.success"
    
    if [ -f "$success_log" ]; then
        exit_code=$(cat "$success_log")
        if [ "$exit_code" = "0" ]; then
            echo "✅ 成功运行 $base_name"
        else
            echo "❌ 运行出错 $base_name"
        fi
        echo "输出:"
        cat "$log_file"
        echo "========================================"
    fi
done

# 清理临时目录
rm -rf "$TEMP_DIR"

# 总结
echo ""
show_success "完成运行 $VALID_COUNT 个文件"
