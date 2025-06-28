#!/bin/bash

# 获取当前工作目录（绝对路径）
CURRENT_DIR=$(pwd)

# 确保目标文件夹存在
mkdir -p "$CURRENT_DIR/pics_all"

# 查找所有以pics开头的文件夹
PICS_DIRS=$(find "$CURRENT_DIR" -type d -name "pics*" -not -path "$CURRENT_DIR/pics_all")

# 遍历每个找到的文件夹
for dir in $PICS_DIRS; do
    # 获取文件夹中的所有文件
    FILES=$(find "$dir" -type f)
    
    # 为每个文件创建符号链接到pics_all目录，使用绝对路径
    for file in $FILES; do
        filename=$(basename "$file")
        ln -sf "$file" "$CURRENT_DIR/pics_all/$filename"
        echo "Created symlink for $file in pics_all"
    done
done

echo "All symlinks created in pics_all successfully!"

