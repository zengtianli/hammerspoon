#!/bin/bash

# 宏列表脚本 - 显示所有宏的详细信息
MACRO_DIR="$HOME/.hammerspoon/macros"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 确保宏目录存在
mkdir -p "$MACRO_DIR"

echo -e "${BLUE}=== 宏管理 - 宏列表 ===${NC}\n"

# 检查是否有宏文件
if [ ! -d "$MACRO_DIR" ] || [ -z "$(ls -A "$MACRO_DIR"/macro_*.txt 2>/dev/null)" ]; then
    echo -e "${YELLOW}没有找到任何宏${NC}"
    echo -e "${BLUE}使用 'macro_record.sh [宏名称]' 来录制新宏${NC}"
    exit 0
fi

# 显示统计信息
total_macros=$(ls -1 "$MACRO_DIR"/macro_*.txt 2>/dev/null | wc -l)
total_size=$(du -sh "$MACRO_DIR" 2>/dev/null | cut -f1)
echo -e "${GREEN}总计: $total_macros 个宏，占用空间: $total_size${NC}\n"

# 显示表头
printf "%-3s %-20s %-8s %-16s %-s\n" "序号" "宏名称" "操作数" "创建时间" "文件路径"
echo -e "${BLUE}$(printf '%.80s' "$(printf '%*s' 80 '' | tr ' ' '-')")${NC}"

# 列出所有宏
index=1
for macro_file in "$MACRO_DIR"/macro_*.txt; do
    if [ -f "$macro_file" ]; then
        name=$(basename "$macro_file" .txt | sed 's/^macro_//')
        count=$(wc -l < "$macro_file")
        date=$(stat -f%Sm -t%Y-%m-%d\ %H:%M "$macro_file" 2>/dev/null || stat -c%y "$macro_file" 2>/dev/null | cut -d' ' -f1,2 | cut -d':' -f1,2)
        
        # 颜色化输出
        printf "${CYAN}%-3s${NC} ${GREEN}%-20s${NC} %-8s %-16s %-s\n" \
            "$index." "$name" "${count}个" "$date" "$macro_file"
        
        ((index++))
    fi
done

echo -e "\n${BLUE}使用说明:${NC}"
echo "  macro_play.sh [宏名称]     # 播放指定宏"
echo "  macro_play.sh             # 交互式选择播放"
echo "  macro_delete.sh [宏名称]  # 删除指定宏"
echo "  macro_record.sh [宏名称]  # 录制新宏" 