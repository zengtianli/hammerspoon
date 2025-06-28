#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title folder_create
# @raycast.mode silent
# @raycast.icon 📁
# @raycast.packageName Custom
# @raycast.description Create a new folder in current Finder location (like macOS default)

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取目标目录（参考 ray_app_terminal.sh 的逻辑）
TARGET_DIR=$(get_finder_current_dir)
LOCATION_DESC="当前位置"

# 设置默认文件夹名称
BASE_NAME="untitled folder"
NEW_FOLDER_NAME="$BASE_NAME"
COUNTER=2

# 如果文件夹已存在，自动添加序号
while [ -e "${TARGET_DIR}/${NEW_FOLDER_NAME}" ]; do
    NEW_FOLDER_NAME="${BASE_NAME} ${COUNTER}"
    COUNTER=$((COUNTER + 1))
done

# 构建新文件夹的完整路径
NEW_FOLDER_PATH="${TARGET_DIR}/${NEW_FOLDER_NAME}"

# 检查文件夹是否已存在
if [ -e "$NEW_FOLDER_PATH" ]; then
    show_error "文件夹 \"$NEW_FOLDER_NAME\" 已存在"
    exit 1
fi

# 创建新文件夹
mkdir -p "$NEW_FOLDER_PATH"

# 在Finder中显示新创建的文件夹
osascript <<EOF
tell application "Finder"
    activate
    select POSIX file "$NEW_FOLDER_PATH"
end tell
EOF

# 显示成功通知
show_success "已在 $LOCATION_DESC 中创建文件夹 \"$NEW_FOLDER_NAME\""
