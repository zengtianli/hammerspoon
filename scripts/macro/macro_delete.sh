#!/bin/bash

# 宏删除脚本 - 删除指定宏
MACRO_DIR="$HOME/.hammerspoon/macros"

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
    echo "  $0 [宏名称]           # 删除指定宏"
    echo "  $0                    # 交互式选择删除"
    echo "  $0 --help             # 显示此帮助"
}

# 列出所有宏（用于选择）
list_macros_for_selection() {
    echo -e "${BLUE}可删除的宏:${NC}"
    
    if [ ! -d "$MACRO_DIR" ] || [ -z "$(ls -A "$MACRO_DIR"/macro_*.txt 2>/dev/null)" ]; then
        echo -e "${YELLOW}没有找到任何宏${NC}"
        return 1
    fi
    
    local index=1
    for macro_file in "$MACRO_DIR"/macro_*.txt; do
        if [ -f "$macro_file" ]; then
            local name=$(basename "$macro_file" .txt | sed 's/^macro_//')
            local count=$(wc -l < "$macro_file")
            local date=$(stat -f%Sm -t%Y-%m-%d\ %H:%M "$macro_file" 2>/dev/null || stat -c%y "$macro_file" 2>/dev/null | cut -d' ' -f1,2 | cut -d':' -f1,2)
            
            echo -e "${CYAN}$index.${NC} ${GREEN}$name${NC} (${count}个位置, $date)"
            ((index++))
        fi
    done
    return 0
}

# 选择要删除的宏
select_macro_for_deletion() {
    echo -e "${RED}警告: 此操作将永久删除宏文件！${NC}"
    
    if ! list_macros_for_selection; then
        return 1
    fi
    
    echo
    echo -e "${BLUE}请输入要删除的宏序号或名称 (输入 'q' 取消):${NC}"
    read -r selection
    
    # 检查是否取消
    if [[ "$selection" == "q" ]] || [[ "$selection" == "Q" ]]; then
        echo -e "${YELLOW}已取消删除${NC}"
        return 1
    fi
    
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

# 删除指定宏
delete_macro() {
    local macro_name="$1"
    local macro_file="$MACRO_DIR/macro_$macro_name.txt"
    
    # 检查宏文件是否存在
    if [ ! -f "$macro_file" ]; then
        echo -e "${RED}宏不存在: $macro_name${NC}"
        return 1
    fi
    
    # 显示宏信息
    local count=$(wc -l < "$macro_file")
    local date=$(stat -f%Sm -t%Y-%m-%d\ %H:%M "$macro_file" 2>/dev/null || stat -c%y "$macro_file" 2>/dev/null | cut -d' ' -f1,2 | cut -d':' -f1,2)
    
    echo -e "${YELLOW}宏信息:${NC}"
    echo -e "  名称: ${GREEN}$macro_name${NC}"
    echo -e "  操作数: $count 个位置"
    echo -e "  创建时间: $date"
    echo -e "  文件路径: $macro_file"
    echo
    
    # 确认删除
    echo -e "${RED}确定要删除这个宏吗? (y/N):${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm "$macro_file"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}宏 '$macro_name' 已删除${NC}"
            osascript -e "display notification \"宏 '$macro_name' 已删除\" with title \"宏管理\""
            return 0
        else
            echo -e "${RED}删除失败${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}已取消删除${NC}"
        return 1
    fi
}

# 主程序
main() {
    # 确保宏目录存在
    mkdir -p "$MACRO_DIR"
    
    # 处理命令行参数
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        "")
            # 没有参数，显示选择菜单
            macro_name=$(select_macro_for_deletion)
            if [ $? -ne 0 ] || [ -z "$macro_name" ]; then
                exit 1
            fi
            ;;
        *)
            # 直接指定宏名称
            macro_name="$1"
            ;;
    esac
    
    # 删除宏
    delete_macro "$macro_name"
}

# 运行主程序
main "$@" 