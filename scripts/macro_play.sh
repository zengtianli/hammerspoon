#!/bin/bash

# 宏播放脚本 - 支持命名宏
# 设置PATH以确保能找到cliclick命令
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

MACRO_DIR="$HOME/.hammerspoon/macros"
OLD_RECORD_FILE="/tmp/hammerspoon_macro.txt"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示使用帮助
show_help() {
    echo -e "${BLUE}用法:${NC}"
    echo "  $0 [宏名称]           # 播放指定宏"
    echo "  $0                    # 显示菜单选择宏"
    echo "  $0 --list             # 列出所有宏"
    echo "  $0 --help             # 显示此帮助"
}

# 列出所有宏
list_macros() {
    echo -e "${BLUE}可用的宏:${NC}"
    
    if [ ! -d "$MACRO_DIR" ] || [ -z "$(ls -A "$MACRO_DIR"/macro_*.txt 2>/dev/null)" ]; then
        echo -e "${YELLOW}没有找到任何宏${NC}"
        return 1
    fi
    
    local index=1
    for macro_file in "$MACRO_DIR"/macro_*.txt; do
        if [ -f "$macro_file" ]; then
            local name=$(basename "$macro_file" .txt | sed 's/^macro_//')
            local count=$(wc -l < "$macro_file")
            local size=$(stat -f%z "$macro_file" 2>/dev/null || stat -c%s "$macro_file" 2>/dev/null)
            local date=$(stat -f%Sm -t%Y-%m-%d\ %H:%M "$macro_file" 2>/dev/null || stat -c%y "$macro_file" 2>/dev/null | cut -d' ' -f1,2 | cut -d':' -f1,2)
            
            echo -e "${CYAN}$index.${NC} ${GREEN}$name${NC} (${count}个位置, $date)"
            ((index++))
        fi
    done
    return 0
}

# 迁移旧宏文件
migrate_old_macro() {
    if [ -f "$OLD_RECORD_FILE" ]; then
        echo -e "${YELLOW}检测到旧的宏文件，是否迁移为 'legacy' 宏? (y/N):${NC}"
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            mkdir -p "$MACRO_DIR"
            cp "$OLD_RECORD_FILE" "$MACRO_DIR/macro_legacy.txt"
            echo -e "${GREEN}已迁移为 'legacy' 宏${NC}"
            rm "$OLD_RECORD_FILE"
        fi
    fi
}

# 选择宏菜单
select_macro_menu() {
    echo -e "${BLUE}请选择要播放的宏:${NC}"
    
    if ! list_macros; then
        return 1
    fi
    
    echo
    echo -e "${BLUE}请输入序号或宏名称:${NC}"
    read -r selection
    
    # 如果是数字，转换为宏名称
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        local index=1
        for macro_file in "$MACRO_DIR"/macro_*.txt; do
            if [ -f "$macro_file" ] && [ "$index" -eq "$selection" ]; then
                echo $(basename "$macro_file" .txt | sed 's/^macro_//')
                return 0
            fi
            ((index++))
        done
        echo -e "${RED}无效的序号: $selection${NC}"
        return 1
    else
        echo "$selection"
        return 0
    fi
}

# 播放指定宏
play_macro() {
    local macro_name="$1"
    local macro_file="$MACRO_DIR/macro_$macro_name.txt"
    
    # 检查宏文件是否存在
    if [ ! -f "$macro_file" ] || [ ! -s "$macro_file" ]; then
        echo -e "${RED}没有找到宏: $macro_name${NC}"
        return 1
    fi
    
    # 记录当前鼠标位置
    ORIGINAL_POS=$(cliclick p)
    echo -e "${GREEN}开始播放宏: $macro_name${NC}"
    echo -e "${BLUE}原始位置: $ORIGINAL_POS${NC}"
    osascript -e "display notification \"开始播放宏: $macro_name\" with title \"宏播放\""
    
    # 获取宏操作数量
    COUNT=$(wc -l < "$macro_file")
    echo -e "${BLUE}共有 $COUNT 个操作${NC}"
    
    # 逐行读取并执行
    LINE_NUM=1
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            X=$(echo "$line" | cut -d',' -f1)
            Y=$(echo "$line" | cut -d',' -f2)
            
            echo -e "${CYAN}执行操作 $LINE_NUM/$COUNT: 移动到 ($X, $Y) 并点击${NC}"
            
            # 移动鼠标并点击
            cliclick m:$X,$Y
            sleep 0.5
            cliclick c:.
            sleep 0.5  # 等待点击完成
            
            LINE_NUM=$((LINE_NUM + 1))
        fi
    done < "$macro_file"
    
    # 等待一下让最后一个操作完成
    sleep 0.5
    
    # 回到播放开始时的原始位置
    echo -e "${GREEN}回到原始位置: $ORIGINAL_POS${NC}"
    ORIG_X=$(echo "$ORIGINAL_POS" | cut -d',' -f1)
    ORIG_Y=$(echo "$ORIGINAL_POS" | cut -d',' -f2)
    cliclick m:$ORIG_X,$ORIG_Y
    
    echo -e "${GREEN}宏播放完成: $macro_name${NC}"
    osascript -e "display notification \"宏播放完成: $macro_name\" with title \"宏播放\""
}

# 主程序
main() {
    # 处理命令行参数
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --list|-l)
            list_macros
            exit 0
            ;;
        "")
            # 没有参数，检查旧文件并显示菜单
            migrate_old_macro
            macro_name=$(select_macro_menu)
            if [ $? -ne 0 ] || [ -z "$macro_name" ]; then
                echo -e "${YELLOW}已取消${NC}"
                exit 1
            fi
            ;;
        *)
            # 直接指定宏名称
            macro_name="$1"
            ;;
    esac
    
    # 播放宏
    play_macro "$macro_name"
}

# 确保宏目录存在
mkdir -p "$MACRO_DIR"

# 运行主程序
main "$@" 