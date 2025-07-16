#!/bin/bash

# 快速宏播放脚本 - 性能优化版本
# 设置PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

MACRO_DIR="$HOME/.hammerspoon/macros"

# 快速播放指定宏
play_macro_fast() {
    local macro_name="$1"
    local macro_file="$MACRO_DIR/macro_$macro_name.txt"
    
    # 检查宏文件是否存在
    if [ ! -f "$macro_file" ] || [ ! -s "$macro_file" ]; then
        echo "ERROR: 宏文件不存在: $macro_name" >&2
        return 1
    fi
    
    # 记录原始位置
    ORIGINAL_POS=$(cliclick p)
    
    # 批量读取宏文件并快速执行
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            X=$(echo "$line" | cut -d',' -f1)
            Y=$(echo "$line" | cut -d',' -f2)
            
            # 快速移动并点击，无延迟
            cliclick m:$X,$Y c:.
        fi
    done < "$macro_file"
    
    # 小延迟确保最后操作完成
    sleep 0.1
    
    # 回到原始位置
    ORIG_X=$(echo "$ORIGINAL_POS" | cut -d',' -f1)
    ORIG_Y=$(echo "$ORIGINAL_POS" | cut -d',' -f2)
    cliclick m:$ORIG_X,$ORIG_Y
    
    echo "SUCCESS: $macro_name"
}

# 主程序 - 直接播放，无菜单
if [ -z "$1" ]; then
    echo "ERROR: 需要指定宏名称" >&2
    exit 1
fi

mkdir -p "$MACRO_DIR"
play_macro_fast "$1" 