#!/bin/bash

# 宏播放脚本
RECORD_FILE="/tmp/hammerspoon_macro.txt"

# 检查是否有录制的宏
if [ ! -f "$RECORD_FILE" ] || [ ! -s "$RECORD_FILE" ]; then
    echo "没有找到录制的宏"
    osascript -e 'display notification "没有找到录制的宏" with title "宏播放"'
    exit 1
fi

# 记录当前鼠标位置
ORIGINAL_POS=$(cliclick p)
echo "开始播放宏，原始位置: $ORIGINAL_POS"
osascript -e 'display notification "开始播放宏" with title "宏播放"'

# 获取宏操作数量
COUNT=$(wc -l < "$RECORD_FILE")
echo "共有 $COUNT 个操作"

# 逐行读取并执行
LINE_NUM=1
while IFS= read -r line; do
    if [ -n "$line" ]; then
        X=$(echo "$line" | cut -d',' -f1)
        Y=$(echo "$line" | cut -d',' -f2)
        
        echo "执行操作 $LINE_NUM/$COUNT: 移动到 ($X, $Y) 并点击"
        
        # 移动鼠标并点击
        cliclick m:$X,$Y
        sleep 0.5
        cliclick c:.
        sleep 0.5  # 等待点击完成
        
        LINE_NUM=$((LINE_NUM + 1))
    fi
done < "$RECORD_FILE"

# 等待一下让最后一个操作完成
sleep 0.5

# 回到播放开始时的原始位置
echo "回到原始位置: $ORIGINAL_POS"
ORIG_X=$(echo "$ORIGINAL_POS" | cut -d',' -f1)
ORIG_Y=$(echo "$ORIGINAL_POS" | cut -d',' -f2)
cliclick m:$ORIG_X,$ORIG_Y

echo "宏播放完成"
osascript -e 'display notification "宏播放完成" with title "宏播放"' 