#!/bin/bash

# ===== 常量定义 =====
readonly PYTHON_PATH="/Users/tianli/miniforge3/bin/python3"
readonly MINIFORGE_BIN="/Users/tianli/miniforge3/bin"
readonly SCRIPTS_DIR="/Users/tianli/useful_scripts"
readonly EXECUTE_SCRIPTS_DIR="/Users/tianli/useful_scripts/execute/scripts_ray"
readonly EXECUTE_DIR="/Users/tianli/useful_scripts/execute"

# ===== Scripts 脚本路径定义 =====
# 文件转换脚本
readonly CONVERT_CSV_TO_TXT="$EXECUTE_SCRIPTS_DIR/convert_csv_to_txt.py"
readonly CONVERT_CSV_TO_XLSX="$EXECUTE_SCRIPTS_DIR/convert_csv_to_xlsx.py" 
readonly CONVERT_TXT_TO_CSV="$EXECUTE_SCRIPTS_DIR/convert_txt_to_csv.py"
readonly CONVERT_TXT_TO_XLSX="$EXECUTE_SCRIPTS_DIR/convert_txt_to_xlsx.py"
readonly CONVERT_XLSX_TO_CSV="$EXECUTE_SCRIPTS_DIR/convert_xlsx_to_csv.py"
readonly CONVERT_XLSX_TO_TXT="$EXECUTE_SCRIPTS_DIR/convert_xlsx_to_txt.py"
readonly CONVERT_DOCX_TO_MD="$EXECUTE_SCRIPTS_DIR/convert_docx_to_md.sh"
readonly CONVERT_DOC_TO_TEXT="$EXECUTE_SCRIPTS_DIR/convert_doc_to_text.sh"
readonly CONVERT_PPTX_TO_MD="$EXECUTE_SCRIPTS_DIR/convert_pptx_to_md.py"
readonly CONVERT_WMF_TO_PNG="$EXECUTE_SCRIPTS_DIR/convert_wmf_to_png.py"
readonly CONVERT_OFFICE_BATCH="$EXECUTE_SCRIPTS_DIR/convert_office_batch.sh"

# 内容提取脚本
readonly EXTRACT_IMAGES_OFFICE="$EXECUTE_SCRIPTS_DIR/extract_images_office.py"
readonly EXTRACT_TABLES_OFFICE="$EXECUTE_SCRIPTS_DIR/extract_tables_office.py"
readonly EXTRACT_MARKDOWN_FILES="$EXECUTE_SCRIPTS_DIR/extract_markdown_files.sh"
readonly EXTRACT_TEXT_TOKENS="$EXECUTE_SCRIPTS_DIR/extract_text_tokens.py"

# 文件操作脚本
readonly FILE_MOVE_UP_LEVEL="$EXECUTE_SCRIPTS_DIR/file_move_up_level.sh"
readonly LINK_CREATE_ALIASES="$EXECUTE_SCRIPTS_DIR/link_create_aliases.sh"
readonly LINK_BIND_FILES="$EXECUTE_SCRIPTS_DIR/link_bind_files.py"
readonly LINK_IMAGES_CENTRAL="$EXECUTE_SCRIPTS_DIR/link_images_central.sh"

# 合并工具脚本
readonly MERGE_CSV_FILES="$EXECUTE_SCRIPTS_DIR/merge_csv_files.sh"
readonly MERGE_MARKDOWN_FILES="$EXECUTE_SCRIPTS_DIR/merge_markdown_files.sh"

# 管理工具脚本
readonly MANAGE_APP_LAUNCHER="$EXECUTE_SCRIPTS_DIR/manage_app_launcher.sh"
readonly MANAGE_PIP_PACKAGES="$EXECUTE_SCRIPTS_DIR/manage_pip_packages.sh"
readonly LIST_APPLICATIONS="$EXECUTE_SCRIPTS_DIR/list_applications.sh"

# 其他工具脚本
readonly SPLITSHEETS="$EXECUTE_SCRIPTS_DIR/splitsheets.py"

# ===== 通用函数 =====

# 获取 Finder 中选中的单个文件/文件夹
# 返回: 文件路径或空字符串
get_finder_selection_single() {
    osascript <<'EOF'
tell application "Finder"
    if (count of (selection as list)) > 0 then
        POSIX path of (item 1 of (selection as list) as alias)
    else
        ""
    end if
end tell
EOF
}

# 获取 Finder 中选中的多个文件/文件夹
# 返回: 逗号分隔的路径列表
get_finder_selection_multiple() {
    osascript <<'EOF'
tell application "Finder"
    set selectedItems to selection as list
    set posixPaths to {}
    
    if (count of selectedItems) > 0 then
        repeat with i from 1 to count of selectedItems
            set thisItem to item i of selectedItems
            set end of posixPaths to POSIX path of (thisItem as alias)
        end repeat
        
        set AppleScript's text item delimiters to ","
        set pathsText to posixPaths as text
        set AppleScript's text item delimiters to ""
        return pathsText
    else
        return ""
    end if
end tell
EOF
}

# 获取当前 Finder 目录或选中项目的目录
get_finder_current_dir() {
    osascript <<'EOF'
tell application "Finder"
    if (count of (selection as list)) > 0 then
        set firstItem to item 1 of (selection as list)
        if class of firstItem is folder then
            POSIX path of (firstItem as alias)
        else
            POSIX path of (container of firstItem as alias)
        end if
    else
        POSIX path of (insertion location as alias)
    end if
end tell
EOF
}

# 检查文件扩展名
# 参数: $1 = 文件路径, $2 = 期望的扩展名（不带点）
# 返回: 0 = 匹配, 1 = 不匹配
check_file_extension() {
    local file="$1"
    local expected_ext="$2"
    local actual_ext="${file##*.}"
    
    [[ "$(echo "$actual_ext" | tr '[:upper:]' '[:lower:]')" == "$(echo "$expected_ext" | tr '[:upper:]' '[:lower:]')" ]]
}

# 在 Ghostty 中执行命令
# 参数: $1 = 要执行的命令
run_in_ghostty() {
    local command="$1"
    local command_escaped=$(printf "%s" "$command" | sed 's/"/\\"/g')
    
    osascript <<EOF
tell application "Ghostty"
    activate
    tell application "System Events"
        keystroke "n" using command down
    end tell
end tell
EOF
    
    sleep 1
    
    osascript <<EOF
tell application "Ghostty"
    activate
    delay 0.2
    set the clipboard to "$command_escaped"
    tell application "System Events"
        keystroke "v" using command down
        delay 0.1
        key code 36
    end tell
end tell
EOF
}

# 显示成功消息
# 参数: $1 = 消息内容
show_success() {
    echo "✅ $1"
}

# 显示错误消息
# 参数: $1 = 消息内容
show_error() {
    echo "❌ $1"
}

# 显示警告消息
# 参数: $1 = 消息内容
show_warning() {
    echo "⚠️ $1"
}

# 显示处理中消息
# 参数: $1 = 消息内容
show_processing() {
    echo "🔄 $1"
}

# 安全切换目录
# 参数: $1 = 目标目录
# 返回: 0 = 成功, 1 = 失败
safe_cd() {
    local target_dir="$1"
    if cd "$target_dir" 2>/dev/null; then
        return 0
    else
        show_error "无法进入目录: $target_dir"
        return 1
    fi
}

# 检查命令是否存在
# 参数: $1 = 命令名称
check_command_exists() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        show_error "$cmd 未安装"
        return 1
    fi
    return 0
}
