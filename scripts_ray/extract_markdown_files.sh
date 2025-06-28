#!/bin/bash

# extract_md_files.sh - 提取并整理 Markdown 文件
# 功能: 将分散的 .md 文件收集到指定目录，处理文件名冲突
# 版本: 2.0.0
# 作者: tianli
# 更新: 2024-01-01

# 引入通用函数库
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

# 脚本版本信息
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

# 默认目标目录
readonly DEFAULT_TARGET_DIR="mded"

# 显示版本信息
show_version() {
    echo "Markdown文件提取工具 v$SCRIPT_VERSION"
    echo "作者: $SCRIPT_AUTHOR"
    echo "更新日期: $SCRIPT_UPDATED"
}

# 显示帮助信息
show_help() {
    cat << EOF
Markdown文件提取工具 - 提取并整理 Markdown 文件

用法: $0 [选项] [源目录] [目标目录]

选项:
    -f, --force      强制覆盖已存在的文件
    -v, --verbose    显示详细输出
    -h, --help       显示此帮助信息
    --version        显示版本信息

参数:
    源目录          要搜索 Markdown 文件的目录（默认：当前目录）
    目标目录        提取文件的目标目录（默认：$DEFAULT_TARGET_DIR）

示例:
    $0                          # 提取当前目录的所有 .md 文件到 $DEFAULT_TARGET_DIR
    $0 ./docs                   # 提取 docs 目录的 .md 文件
    $0 ./docs ./output          # 提取到指定目录
    $0 -f                       # 强制覆盖已存在的文件

功能:
    - 递归搜索所有 .md 文件
    - 智能处理文件名冲突（添加目录前缀或数字后缀）
    - 保持原始文件不变（复制而非移动）
    - 显示处理统计信息
EOF
    exit 0
}

# 生成唯一的文件名
# 参数: $1 = 目标目录, $2 = 原始文件路径, $3 = 期望文件名
generate_unique_filename() {
    local target_dir="$1"
    local original_file="$2"
    local desired_name="$3"
    local target_path="$target_dir/$desired_name"
    
    # 如果文件不存在，直接返回
    if [ ! -f "$target_path" ]; then
        echo "$desired_name"
        return 0
    fi
    
    # 尝试使用目录前缀
    local rel_path="${original_file#./}"
    local dir_prefix=$(dirname "$rel_path" | tr '/' '_')
    
    if [ "$dir_prefix" != "." ]; then
        local candidate_name="${dir_prefix}_${desired_name}"
        if [ ! -f "$target_dir/$candidate_name" ]; then
            echo "$candidate_name"
            return 0
        fi
    fi
    
    # 使用数字后缀
    local base_name="${desired_name%.md}"
    local counter=1
    
    while [ -f "$target_dir/${base_name}_${counter}.md" ]; do
        ((counter++))
    done
    
    echo "${base_name}_${counter}.md"
}

# 复制单个文件
# 参数: $1 = 源文件路径, $2 = 目标目录, $3 = 是否强制覆盖
copy_md_file() {
    local source_file="$1"
    local target_dir="$2"
    local force_overwrite="$3"
    
    # 验证源文件
    validate_input_file "$source_file" || return 1
    
    # 检查文件类型
    if ! check_file_extension "$source_file" "md"; then
        show_warning "跳过非Markdown文件: $(basename "$source_file")"
        return 1
    fi
    
    local filename=$(basename "$source_file")
    local rel_path="${source_file#./}"
    local target_filename
    
    # 确定目标文件名
    if [ "$force_overwrite" = true ]; then
        target_filename="$filename"
    else
        target_filename=$(generate_unique_filename "$target_dir" "$source_file" "$filename")
    fi
    
    local target_path="$target_dir/$target_filename"
    
    # 检查是否需要跳过
    if [ "$force_overwrite" = false ] && [ -f "$target_path" ] && [ "$target_filename" = "$filename" ]; then
        show_warning "文件已存在，跳过: $filename"
        return 1
    fi
    
    # 执行复制
    if cp "$source_file" "$target_path" 2>/dev/null; then
        if [ "$target_filename" != "$filename" ]; then
            show_success "已复制: $rel_path -> $target_filename"
        else
            show_success "已复制: $rel_path"
        fi
        return 0
    else
        show_error "复制失败: $rel_path"
        return 1
    fi
}

# 提取所有 Markdown 文件
# 参数: $1 = 源目录, $2 = 目标目录, $3 = 是否强制覆盖
extract_markdown_files() {
    local source_dir="${1:-.}"
    local target_dir="${2:-$DEFAULT_TARGET_DIR}"
    local force_overwrite="$3"
    
    # 验证源目录
    if [ ! -d "$source_dir" ]; then
        fatal_error "源目录不存在: $source_dir"
    fi
    
    # 创建目标目录
    ensure_directory "$target_dir" || return 1
    
    show_info "提取 Markdown 文件"
    show_info "源目录: $source_dir"
    show_info "目标目录: $target_dir"
    
    # 统计变量
    local success_count=0
    local failed_count=0
    local total_count=0
    
    # 查找并处理所有 .md 文件（排除目标目录）
    while IFS= read -r -d '' file; do
        ((total_count++))
        show_progress "$total_count" "?" "$(basename "$file")"
        
        if copy_md_file "$file" "$target_dir" "$force_overwrite"; then
            ((success_count++))
        else
            ((failed_count++))
        fi
    done < <(find "$source_dir" -name "*.md" -not -path "./$target_dir/*" -type f -print0 2>/dev/null)
    
    # 显示处理统计
    echo ""
    show_info "提取完成"
    echo "✅ 成功复制: $success_count 个文件"
    if [ $failed_count -gt 0 ]; then
        echo "❌ 复制失败: $failed_count 个文件"
    fi
    echo "📊 总计处理: $total_count 个文件"
    echo "📁 输出目录: $target_dir"
    
    if [ $total_count -eq 0 ]; then
        show_warning "未找到 Markdown 文件"
    else
        local success_rate=$((success_count * 100 / total_count))
        echo "📊 成功率: ${success_rate}%"
    fi
}

# 主程序
main() {
    # 默认值
    local source_dir="."
    local target_dir="$DEFAULT_TARGET_DIR"
    local force_overwrite=false
    local verbose=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
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
            -h|--help)
                show_help
                ;;
            -*)
                show_error "未知选项: $1"
                show_help
                ;;
            *)
                if [ "$source_dir" = "." ]; then
                    source_dir="$1"
                elif [ "$target_dir" = "$DEFAULT_TARGET_DIR" ]; then
                    target_dir="$1"
                else
                    show_error "过多参数: $1"
                    show_help
                fi
                shift
                ;;
        esac
    done
    
    # 执行提取
    extract_markdown_files "$source_dir" "$target_dir" "$force_overwrite"
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
