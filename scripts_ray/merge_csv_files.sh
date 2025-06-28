#!/bin/bash

# mergecsv.sh - CSV文件合并工具
# 功能: 将目录中的多个CSV文件合并为一个文件
# 版本: 2.0.0
# 作者: tianli
# 更新: 2024-01-01

# 引入通用函数库
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

# 脚本版本信息
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

# 默认输出文件名
readonly DEFAULT_OUTPUT="merged.csv"

# 显示版本信息
show_version() {
    echo "CSV文件合并工具 v$SCRIPT_VERSION"
    echo "作者: $SCRIPT_AUTHOR"
    echo "更新日期: $SCRIPT_UPDATED"
}

# 显示帮助信息
show_help() {
    cat << EOF
CSV文件合并工具 - 将目录中的多个CSV文件合并为一个文件

用法: $0 [选项] [目录] [输出文件]

选项:
    -h, --header     保留第一个文件的标题行
    -s, --skip-empty 跳过空文件
    -f, --force      强制覆盖输出文件
    -v, --verbose    显示详细输出
    --help           显示此帮助信息
    --version        显示版本信息

参数:
    目录            包含CSV文件的目录（默认：当前目录）
    输出文件        合并后的CSV文件名（默认：$DEFAULT_OUTPUT）

示例:
    $0                          # 合并当前目录所有CSV为 $DEFAULT_OUTPUT
    $0 -h                       # 保留标题行合并
    $0 ./data combined.csv      # 合并指定目录到指定文件
    $0 -h -s ./data out.csv     # 保留标题行，跳过空文件

功能:
    - 自动查找目录中的所有CSV文件
    - 可选择保留或去除标题行
    - 跳过空文件或损坏文件
    - 显示合并进度和统计信息
EOF
    exit 0
}

# 检查CSV文件有效性
# 参数: $1 = 文件路径
is_valid_csv() {
    local file="$1"
    
    # 检查文件是否存在且不为空
    if [ ! -s "$file" ]; then
        return 1
    fi
    
    # 简单检查是否包含逗号（基本CSV检测）
    if head -n 1 "$file" | grep -q ","; then
        return 0
    fi
    
    # 检查是否只有一列（无逗号但有内容）
    if [ -s "$file" ]; then
        return 0
    fi
    
    return 1
}

# 获取CSV文件行数
# 参数: $1 = 文件路径
get_csv_line_count() {
    local file="$1"
    wc -l < "$file" 2>/dev/null || echo "0"
}

# 处理单个CSV文件
# 参数: $1 = 文件路径, $2 = 输出文件, $3 = 是否跳过标题行, $4 = 是否第一个文件
process_csv_file() {
    local input_file="$1"
    local output_file="$2"
    local skip_header="$3"
    local is_first_file="$4"
    
    # 验证输入文件
    validate_input_file "$input_file" || return 1
    
    # 检查文件扩展名
    if ! check_file_extension "$input_file" "csv"; then
        show_warning "跳过非CSV文件: $(basename "$input_file")"
        return 1
    fi
    
    # 检查CSV有效性
    if ! is_valid_csv "$input_file"; then
        show_warning "跳过无效或空的CSV文件: $(basename "$input_file")"
        return 1
    fi
    
    local line_count=$(get_csv_line_count "$input_file")
    show_processing "处理文件: $(basename "$input_file") ($line_count 行)"
    
    # 根据条件处理文件内容
    if [ "$is_first_file" = true ] || [ "$skip_header" = false ]; then
        # 第一个文件或不跳过标题行，复制全部内容
        cat "$input_file" >> "$output_file" 2>/dev/null
    else
        # 跳过第一行（标题行）
        if [ "$line_count" -gt 1 ]; then
            tail -n +2 "$input_file" >> "$output_file" 2>/dev/null
        else
            show_warning "文件只有标题行，跳过: $(basename "$input_file")"
            return 1
        fi
    fi
    
    return 0
}

# 合并CSV文件
# 参数: $1 = 源目录, $2 = 输出文件, $3 = 保留标题行, $4 = 跳过空文件, $5 = 强制覆盖
merge_csv_files() {
    local source_dir="${1:-.}"
    local output_file="${2:-$DEFAULT_OUTPUT}"
    local keep_header="$3"
    local skip_empty="$4"
    local force_overwrite="$5"
    
    # 验证源目录
    if [ ! -d "$source_dir" ]; then
        fatal_error "源目录不存在: $source_dir"
    fi
    
    # 检查输出文件是否已存在
    if [ -f "$output_file" ] && [ "$force_overwrite" = false ]; then
        show_error "输出文件已存在: $output_file"
        show_info "使用 -f 选项强制覆盖"
        return 1
    fi
    
    show_info "CSV文件合并"
    show_info "源目录: $source_dir"
    show_info "输出文件: $output_file"
    show_info "保留标题行: $([ "$keep_header" = true ] && echo "是" || echo "否")"
    
    # 查找所有CSV文件
    local csv_files=()
    while IFS= read -r -d '' file; do
        csv_files+=("$file")
    done < <(find "$source_dir" -maxdepth 1 -name "*.csv" -type f -print0 2>/dev/null)
    
    if [ ${#csv_files[@]} -eq 0 ]; then
        show_warning "在目录中未找到CSV文件: $source_dir"
        return 1
    fi
    
    show_info "找到 ${#csv_files[@]} 个CSV文件"
    
    # 清空或创建输出文件
    > "$output_file"
    
    # 统计变量
    local processed_count=0
    local skipped_count=0
    local total_lines=0
    local is_first_file=true
    
    # 处理每个CSV文件
    for file in "${csv_files[@]}"; do
        local file_num=$((processed_count + skipped_count + 1))
        show_progress "$file_num" "${#csv_files[@]}" "$(basename "$file")"
        
        # 跳过输出文件本身
        if [ "$(basename "$file")" = "$(basename "$output_file")" ]; then
            show_warning "跳过输出文件本身: $(basename "$file")"
            ((skipped_count++))
            continue
        fi
        
        # 处理文件
        local skip_header_this_file=false
        if [ "$keep_header" = true ] && [ "$is_first_file" = false ]; then
            skip_header_this_file=true
        fi
        
        if process_csv_file "$file" "$output_file" "$skip_header_this_file" "$is_first_file"; then
            ((processed_count++))
            local file_lines=$(get_csv_line_count "$file")
            if [ "$skip_header_this_file" = true ]; then
                total_lines=$((total_lines + file_lines - 1))
            else
                total_lines=$((total_lines + file_lines))
            fi
            is_first_file=false
        else
            ((skipped_count++))
        fi
    done
    
    # 显示合并统计
    echo ""
    show_info "合并完成"
    echo "✅ 成功处理: $processed_count 个文件"
    if [ $skipped_count -gt 0 ]; then
        echo "⚠️ 跳过文件: $skipped_count 个"
    fi
    echo "📊 总计行数: $total_lines 行"
    echo "📁 输出文件: $output_file"
    
    # 验证输出文件
    if [ -s "$output_file" ]; then
        local output_lines=$(get_csv_line_count "$output_file")
        echo "📋 输出文件行数: $output_lines 行"
        show_success "CSV文件合并完成"
    else
        show_error "输出文件为空，可能所有文件都被跳过"
        return 1
    fi
}

# 主程序
main() {
    # 默认值
    local source_dir="."
    local output_file="$DEFAULT_OUTPUT"
    local keep_header=false
    local skip_empty=false
    local force_overwrite=false
    local verbose=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--header)
                keep_header=true
                shift
                ;;
            -s|--skip-empty)
                skip_empty=true
                shift
                ;;
            -f|--force)
                force_overwrite=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --version)
                show_version
                exit 0
                ;;
            --help)
                show_help
                ;;
            -*)
                show_error "未知选项: $1"
                show_help
                ;;
            *)
                if [ "$source_dir" = "." ]; then
                    source_dir="$1"
                elif [ "$output_file" = "$DEFAULT_OUTPUT" ]; then
                    output_file="$1"
                else
                    show_error "过多参数: $1"
                    show_help
                fi
                shift
                ;;
        esac
    done
    
    # 执行合并
    merge_csv_files "$source_dir" "$output_file" "$keep_header" "$skip_empty" "$force_overwrite"
}

# 设置清理陷阱
cleanup() {
    local exit_code=$?
    # 清理临时文件等
    exit $exit_code
}
trap cleanup EXIT

# 运行主程序
main "$@"
