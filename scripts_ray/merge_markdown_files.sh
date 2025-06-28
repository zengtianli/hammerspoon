#!/bin/bash

# 使用方法: ./merge_md.sh [输出文件名]
# 默认输出文件名: merged_output.md

output_file="${1:-merged_output.md}"

# 清空或创建输出文件
> "$output_file"

# 添加标题
echo "# Merged Documents" >> "$output_file"
echo "" >> "$output_file"
echo "Generated on: $(date)" >> "$output_file"
echo "" >> "$output_file"
echo "## Table of Contents" >> "$output_file"
echo "" >> "$output_file"

# 生成目录
i=1
for file in *.md; do
    if [ "$file" != "$output_file" ] && [ -f "$file" ]; then
        echo "$i. [${file%.md}](#$(echo ${file%.md} | sed 's/ /-/g' | tr '[:upper:]' '[:lower:]'))" >> "$output_file"
        ((i++))
    fi
done

echo "" >> "$output_file"
echo "---" >> "$output_file"
echo "" >> "$output_file"

# 合并文件
for file in *.md; do
    if [ "$file" != "$output_file" ] && [ -f "$file" ]; then
        echo "## ${file%.md}" >> "$output_file"
        echo "" >> "$output_file"
        echo "\`File: $file\`" >> "$output_file"
        echo "" >> "$output_file"
        cat "$file" >> "$output_file"
        echo "" >> "$output_file"
        echo "---" >> "$output_file"
        echo "" >> "$output_file"
    fi
done

echo "✅ Merged $(ls *.md | grep -v "$output_file" | wc -l) files into: $output_file"

