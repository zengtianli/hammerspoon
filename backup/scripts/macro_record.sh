#!/bin/bash

# 宏录制脚本 - 支持命名宏
# 设置PATH以确保能找到cliclick命令
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

MACRO_DIR="$HOME/.hammerspoon/macros"
STATUS_FILE="/tmp/hammerspoon_macro_recording"

# 确保宏目录存在
mkdir -p "$MACRO_DIR"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 验证宏名称合法性
validate_macro_name() {
    local name="$1"
    if [[ -z "$name" ]]; then
        return 1
    fi
    # 只允许字母、数字、下划线、连字符
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 1
    fi
    return 0
}

# 获取宏名称
get_macro_name() {
    local name="$1"
    
    # 如果没有提供参数，交互式输入
    if [[ -z "$name" ]]; then
        echo -e "${BLUE}请输入宏名称 (只允许字母、数字、下划线、连字符):${NC}"
        read -r name
    fi
    
    # 验证名称
    if ! validate_macro_name "$name"; then
        echo -e "${RED}错误: 宏名称无效${NC}"
        echo "宏名称只能包含字母、数字、下划线和连字符"
        exit 1
    fi
    
    echo "$name"
}

# 检查是否正在录制
if [ -f "$STATUS_FILE" ]; then
    # 正在录制中，记录当前鼠标位置
    CURRENT_MACRO=$(cat "$STATUS_FILE" | tr -d '\n')
    RECORD_FILE="$MACRO_DIR/macro_$CURRENT_MACRO.txt"
    
    MOUSE_POS=$(cliclick p)
    
    # 保存到文件
    echo "$MOUSE_POS" >> "$RECORD_FILE"
    
    # 获取已录制的操作数量
    COUNT=$(wc -l < "$RECORD_FILE")
    echo -e "${GREEN}已记录位置 $COUNT: $MOUSE_POS${NC} (宏: $CURRENT_MACRO)"
    osascript -e "display notification \"已记录位置 $COUNT: $MOUSE_POS\" with title \"宏录制: $CURRENT_MACRO\""
else
    # 开始新录制
    MACRO_NAME=$(get_macro_name "$1")
    RECORD_FILE="$MACRO_DIR/macro_$MACRO_NAME.txt"
    
    # 如果宏已存在，询问是否覆盖
    if [ -f "$RECORD_FILE" ]; then
        echo -e "${YELLOW}宏 '$MACRO_NAME' 已存在，是否覆盖? (y/N):${NC}"
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}录制已取消${NC}"
            exit 0
        fi
    fi
    
    # 开始录制
    echo "$MACRO_NAME" > "$STATUS_FILE"
    echo "" > "$RECORD_FILE"  # 清空文件
    
    echo -e "${GREEN}宏录制已开始: $MACRO_NAME${NC}"
    echo -e "${BLUE}提示: 再次运行此脚本来记录鼠标位置，运行 macro_stop.sh 来结束录制${NC}"
    osascript -e "display notification \"宏录制已开始: $MACRO_NAME\" with title \"宏录制\""
fi 