#!/bin/bash

# 停止宏录制脚本 - 支持命名宏
MACRO_DIR="$HOME/.hammerspoon/macros"
STATUS_FILE="/tmp/hammerspoon_macro_recording"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ -f "$STATUS_FILE" ]; then
    # 获取当前录制的宏名称
    CURRENT_MACRO=$(cat "$STATUS_FILE" | tr -d '\n')
    RECORD_FILE="$MACRO_DIR/macro_$CURRENT_MACRO.txt"
    
    # 停止录制
    rm "$STATUS_FILE"
    
    if [ -f "$RECORD_FILE" ]; then
        COUNT=$(wc -l < "$RECORD_FILE")
        if [ "$COUNT" -gt 0 ]; then
            echo -e "${GREEN}宏录制已停止: $CURRENT_MACRO${NC}"
            echo -e "${BLUE}共录制了 $COUNT 个位置${NC}"
            echo -e "${BLUE}宏文件: $RECORD_FILE${NC}"
            osascript -e "display notification \"宏 '$CURRENT_MACRO' 录制完成，共 $COUNT 个位置\" with title \"宏录制\""
        else
            echo -e "${YELLOW}宏录制已停止: $CURRENT_MACRO (未记录任何位置)${NC}"
            # 删除空文件
            rm "$RECORD_FILE"
            osascript -e "display notification \"宏 '$CURRENT_MACRO' 录制已取消\" with title \"宏录制\""
        fi
    else
        echo -e "${YELLOW}宏录制已停止: $CURRENT_MACRO${NC}"
        osascript -e "display notification \"宏 '$CURRENT_MACRO' 录制已停止\" with title \"宏录制\""
    fi
else
    echo -e "${RED}当前没有正在进行的录制${NC}"
    osascript -e 'display notification "当前没有正在进行的录制" with title "宏录制"'
fi 