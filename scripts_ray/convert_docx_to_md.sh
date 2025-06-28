#!/bin/bash

# markitdown_docx2md.sh - 使用 markitdown 将 DOCX 文件转换为 Markdown
# 功能: 将 .docx 文件转换为 .md 格式
# 版本: 2.0.0
# 作者: tianli
# 更新: 2024-01-01

# 引入通用函数库
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

# 脚本版本信息
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

# 显示版本信息
show_version() {
    echo "DOCX转Markdown工具 v$SCRIPT_VERSION"
    echo "作者: $SCRIPT_AUTHOR"
    echo "更新日期: $SCRIPT_UPDATED"
}

# 显示帮助信息
show_help() {
    cat << EOF
DOCX转Markdown工具 - 使用 markitdown 将 DOCX 文件转换为 Markdown

用法: 
    $0 [选项] [目录] [输出目录]
    $0 [选项] <文件.docx> [输出目录]

选项:
    -r, --recursive  递归处理子目录
    -v, --verbose    显示详细输出
    -h, --help       显示此帮助信息
    --version        显示版本信息

参数:
    文件.docx       要转换的单个 DOCX 文件
    目录            要处理的目录（默认：当前目录）
    输出目录        输出 Markdown 文件的目录（可选）

示例:
    $0                              # 转换当前目录的所有 DOCX 文件
    $0 document.docx                # 转换单个文件
    $0 document.docx ./output       # 转换单个文件到指定目录
    $0 -r                           # 递归转换所有子目录
    $0 ./documents ./output         # 转换指定目录到指定输出目录

依赖:
    - markitdown
EOF
    exit 0
}

# 检查依赖
check_dependencies() {
    show_info "检查依赖项..."
    
    if ! check_command_exists markitdown; then
        show_error "未找到 markitdown"
        show_info "请安装 markitdown: pip install markitdown"
        return 1
    fi
    
    show_success "依赖检查完成"
    return 0
}

# 转换单个文件
# 参数: $1 = 文件路径, $2 = 输出目录(可选)
convert_single_docx() {
    local file="$1"
    local output_dir="$2"
    
    # 验证输入文件
    validate_input_file "$file" || return 1
    
    # 检查文件类型
    if ! check_file_extension "$file" "docx"; then
        show_warning "跳过非DOCX文件: $(basename "$file")"
        return 1
    fi
    
    local base_name=$(get_file_basename "$file")
    local output_file
    
    # 确定输出文件路径
    if [ -n "$output_dir" ]; then
        ensure_directory "$output_dir" || return 1
        output_file="$output_dir/$base_name.md"
    else
        output_file="${file%.docx}.md"
    fi
    
    # 检查输出文件是否已存在
    if [ -f "$output_file" ]; then
        show_warning "输出文件已存在，跳过: $(basename "$output_file")"
        return 1
    fi
    
    show_processing "转换: $(basename "$file")"
    
    # 执行转换
    if retry_command markitdown "$file" > "$output_file"; then
        show_success "已转换: $(basename "$file") -> $(basename "$output_file")"
        return 0
    else
        show_error "转换失败: $(basename "$file")"
        # 清理失败的输出文件
        [ -f "$output_file" ] && rm -f "$output_file"
        return 1
    fi
}

# 批量转换目录中的所有 DOCX 文件
# 参数: $1 = 目录路径, $2 = 输出目录, $3 = 是否递归
convert_all_docx_to_md() {
    local target_dir="${1:-.}"
    local output_dir="$2"
    local recursive="$3"
    
    # 验证目录
    if [ ! -d "$target_dir" ]; then
        fatal_error "目录不存在: $target_dir"
    fi
    
    show_info "处理目录: $target_dir"
    
    # 统计变量
    local success_count=0
    local skipped_count=0
    local total_count=0
    
    # 查找文件
    local find_cmd="find '$target_dir' -maxdepth 1"
    if [ "$recursive" = true ]; then
        find_cmd="find '$target_dir'"
    fi
    
    # 处理所有 DOCX 文件
    while IFS= read -r -d '' file; do
        ((total_count++))
        show_progress "$total_count" "?" "$(basename "$file")"
        
        if convert_single_docx "$file" "$output_dir"; then
            ((success_count++))
        else
            ((skipped_count++))
        fi
    done < <(eval "$find_cmd -name '*.docx' -type f -print0" 2>/dev/null)
    
    # 显示处理统计
    echo ""
    show_info "批量转换完成"
    echo "✅ 成功转换: $success_count 个文件"
    if [ $skipped_count -gt 0 ]; then
        echo "⚠️ 跳过文件: $skipped_count 个"
    fi
    echo "📊 总计处理: $total_count 个文件"
    
    if [ $total_count -eq 0 ]; then
        show_warning "未找到 DOCX 文件"
    fi
}

# 主程序
main() {
    # 默认值
    local recursive=false
    local verbose=false
    local target=""
    local output_dir=""
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--recursive)
                recursive=true
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
                if [ -z "$target" ]; then
                    target="$1"
                elif [ -z "$output_dir" ]; then
                    output_dir="$1"
                else
                    show_error "过多参数: $1"
                    show_help
                fi
                shift
                ;;
        esac
    done
    
    # 检查依赖
    check_dependencies || exit 1
    
    # 如果没有指定目标，使用当前目录
    if [ -z "$target" ]; then
        target="."
    fi
    
    # 判断是单文件转换还是目录转换
    if [ -f "$target" ]; then
        # 单文件转换
        if check_file_extension "$target" "docx"; then
            convert_single_docx "$target" "$output_dir"
        else
            fatal_error "不是有效的 DOCX 文件: $target"
        fi
    elif [ -d "$target" ]; then
        # 目录转换
        convert_all_docx_to_md "$target" "$output_dir" "$recursive"
    else
        fatal_error "无效的路径: $target"
    fi
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
