#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title xls_to_xlsx
# @raycast.mode silent
# @raycast.icon 📊
# @raycast.packageName Custom
# @raycast.description 将选中的Xls文件转换为Xlsx格式

# 获取脚本的绝对路径
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

# 检查原始脚本是否存在
ORIGINAL_SCRIPT="$SCRIPT_DIR/xls2xlsx.sh"
if [ ! -f "$ORIGINAL_SCRIPT" ]; then
    echo "❌ 找不到原始脚本: $ORIGINAL_SCRIPT"
    exit 1
fi

# 获取Finder中选中的文件
SELECTED_FILES=$(osascript <<'EOF'
tell application "Finder"
    set selectedItems to selection as list
    set posixPaths to {}
    
    if (count of selectedItems) > 0 then
        repeat with i from 1 to count of selectedItems
            set thisItem to item i of selectedItems
            set the_path to POSIX path of (thisItem as alias)
            set end of posixPaths to the_path
        end repeat
        
        set AppleScript's text item delimiters to ","
        set pathsText to posixPaths as text
        set AppleScript's text item delimiters to ""
        return pathsText
    end if
end tell
EOF
)

if [ -z "$SELECTED_FILES" ]; then
    echo "❌ 没有选中文件"
    exit 1
fi

# 分割逗号分隔的文件列表
IFS=',' read -ra FILE_ARRAY <<< "$SELECTED_FILES"

# 计数器
SUCCESS_COUNT=0
SKIPPED_COUNT=0

# 处理每个选中的文件
for FILE in "${FILE_ARRAY[@]}"; do
    # 获取文件名和目录
    FILENAME=$(basename "$FILE")
    DIR=$(dirname "$FILE")
    
    # 检查文件扩展名
    if [[ "$FILENAME" != *".xls" ]]; then
        echo "⚠️ 跳过: $FILENAME - 不是XLS文件"
        ((SKIPPED_COUNT++))
        continue
    fi
    
    # 检查是否已经是xlsx文件
    if [[ "$FILENAME" == *".xlsx" ]]; then
        echo "⚠️ 跳过: $FILENAME - 已经是XLSX格式"
        ((SKIPPED_COUNT++))
        continue
    fi
    
    echo "🔄 正在转换: $FILENAME"
    
    # 切换到文件所在目录
    cd "$DIR"
    
    # 创建 AppleScript 文件
    cat > "${HOME}/.convert_excel.scpt" << 'EOF'
on run argv
    set inputFile to POSIX file (item 1 of argv)
    set outputFile to POSIX file ((text 1 thru -4 of (item 1 of argv)) & "xlsx")
    
    tell application "Microsoft Excel"
        open inputFile
        save workbook as active workbook filename outputFile file format Excel XML file format
        close active workbook saving no
    end tell
end run
EOF
    
    # 直接实现convert_xls_to_xlsx函数的功能，而不依赖原始脚本
    echo "正在转换: $FILE -> ${FILE%.*}.xlsx"
    osascript "${HOME}/.convert_excel.scpt" "$FILE"
    echo "转换完成: ${FILE%.*}.xlsx"
    
    # 获取转换后的文件名
    XLSX_FILE="${FILENAME%.*}.xlsx"
    
    # 检查转换是否成功
    if [ -f "$XLSX_FILE" ]; then
        echo "✅ 转换完成: $XLSX_FILE"
        ((SUCCESS_COUNT++))
    else
        echo "❌ 转换失败: $FILENAME"
        ((SKIPPED_COUNT++))
    fi
done

# 显示成功通知
if [ $SUCCESS_COUNT -eq 0 ]; then
    echo "⚠️ 没有文件被转换"
elif [ $SUCCESS_COUNT -eq 1 ]; then
    echo "✅ 成功转换了 1 个文件"
else
    echo "✅ 成功转换了 $SUCCESS_COUNT 个文件"
fi

if [ $SKIPPED_COUNT -gt 0 ]; then
    echo "⚠️ 跳过了 $SKIPPED_COUNT 个文件"
fi
