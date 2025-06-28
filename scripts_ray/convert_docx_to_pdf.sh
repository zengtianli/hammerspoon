#!/bin/bash
# 将所有docx文件转换为PDF
convert_all_docx_to_pdf() {
    local dir="${1:-.}"  # 默认为当前目录，或使用提供的参数
    find "$dir" -type f -name "*.docx" | while read -r file; do
        local output_file="${file%.docx}.pdf"
        echo "Converting $file to $output_file"
        markitdown "$file" > "$output_file"
    done
}

# 执行转换函数，使用传入的第一个参数作为目录，如果没有参数则使用当前目录
convert_all_docx_to_pdf "$@"

