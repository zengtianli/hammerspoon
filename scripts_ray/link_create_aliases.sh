#!/bin/bash

# ext2alias.sh - 创建文件别名链接工具
# 功能: 为提取的图片和表格文件创建符号链接到统一目录
# 版本: 2.0.0
# 作者: tianli
# 更新: 2024-01-01

# 引入通用函数库
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

# 脚本版本信息
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

# 默认别名目录
readonly DEFAULT_ALIAS_DIR="alias_folder"

# 显示版本信息
show_version() {
    echo "文件别名链接工具 v$SCRIPT_VERSION"
    echo "作者: $SCRIPT_AUTHOR"
    echo "更新日期: $SCRIPT_UPDATED"
}

# 显示帮助信息
show_help() {
    cat << EOF
文件别名链接工具 - 为提取的图片和表格文件创建符号链接

用法: $0 [选项] [源目录] [别名目录]

选项:
    -c, --clean      清理现有链接后重新创建
    -f, --force      强制覆盖已存在的链接
    -v, --verbose    显示详细输出
    -h, --help       显示此帮助信息
    --version        显示版本信息

参数:
    源目录          要搜索文件的目录（默认：当前目录）
    别名目录        创建链接的目录（默认：$DEFAULT_ALIAS_DIR）

示例:
    $0                      # 创建当前目录文件的链接到 $DEFAULT_ALIAS_DIR
    $0 -c                   # 清理现有链接后重新创建
    $0 ./docs ./links       # 指定源目录和别名目录

功能:
    - 为 *_img 目录中的图片文件创建链接
    - 为 *_tables 目录中的表格文件创建链接
    - 自动处理文件名冲突
    - 支持清理和重新创建链接
EOF
    exit 0
}

# 清理现有符号链接
# 参数: $1 = 别名目录
clean_existing_links() {
    local alias_dir="$1"
    
    if [ ! -d "$alias_dir" ]; then
        return 0
    fi
    
    show_processing "清理现有符号链接..."
    
    local removed_count=0
    
    # 查找并删除符号链接
    while IFS= read -r -d '' link; do
        if [ -L "$link" ]; then
            rm -f "$link" && ((removed_count++))
        fi
    done < <(find "$alias_dir" -type l -print0 2>/dev/null)
    
    if [ $removed_count -gt 0 ]; then
        show_success "已清理 $removed_count 个现有链接"
    else
        show_info "没有找到需要清理的链接"
    fi
}

# 创建单个文件的符号链接
# 参数: $1 = 源文件路径, $2 = 别名目录, $3 = 是否强制覆盖
create_single_link() {
    local source_file="$1"
    local alias_dir="$2"
    local force_overwrite="$3"
    
    # 验证源文件
    validate_input_file "$source_file" || return 1
    
    local filename=$(basename "$source_file")
    local link_path="$alias_dir/$filename"
    local source_abs_path=$(realpath "$source_file")
    
    # 检查是否已存在
    if [ -e "$link_path" ]; then
        if [ "$force_overwrite" = true ]; then
            rm -f "$link_path"
        else
            show_warning "链接已存在，跳过: $filename"
            return 1
        fi
    fi
    
    # 创建符号链接
    if ln -s "$source_abs_path" "$link_path" 2>/dev/null; then
        show_success "已创建链接: $filename"
        return 0
    else
        show_error "创建链接失败: $filename"
        return 1
    fi
}

# 处理指定类型的目录
# 参数: $1 = 目录模式, $2 = 类型名称, $3 = 别名目录, $4 = 是否强制覆盖
process_directory_type() {
    local dir_pattern="$1"
    local type_name="$2"
    local alias_dir="$3"
    local force_overwrite="$4"
    
    local success_count=0
    local skipped_count=0
    local total_count=0
    
    show_processing "处理${type_name}文件..."
    
    # 查找匹配的目录
    for dir in $dir_pattern; do
        if [ -d "$dir" ]; then
            show_info "扫描目录: $dir"
            
            # 处理目录中的所有文件
            while IFS= read -r -d '' file; do
                ((total_count++))
                show_progress "$total_count" "?" "$(basename "$file")"
                
                if create_single_link "$file" "$alias_dir" "$force_overwrite"; then
                    ((success_count++))
                else
                    ((skipped_count++))
                fi
            done < <(find "$dir" -type f -print0 2>/dev/null)
        fi
    done
    
    # 显示类型统计
    if [ $total_count -gt 0 ]; then
        echo "  ✅ ${type_name}: 成功 $success_count, 跳过 $skipped_count, 总计 $total_count"
    else
        echo "  ⚠️ ${type_name}: 未找到文件"
    fi
    
    return $success_count
}

# 创建所有别名链接
# 参数: $1 = 源目录, $2 = 别名目录, $3 = 是否清理, $4 = 是否强制覆盖
create_alias_links() {
    local source_dir="${1:-.}"
    local alias_dir="${2:-$DEFAULT_ALIAS_DIR}"
    local clean_first="$3"
    local force_overwrite="$4"
    
    # 验证源目录
    if [ ! -d "$source_dir" ]; then
        fatal_error "源目录不存在: $source_dir"
    fi
    
    # 切换到源目录
    safe_cd "$source_dir" || return 1
    
    # 创建别名目录
    ensure_directory "$alias_dir" || return 1
    
    show_info "创建文件别名链接"
    show_info "源目录: $(pwd)"
    show_info "别名目录: $alias_dir"
    
    # 清理现有链接（如果需要）
    if [ "$clean_first" = true ]; then
        clean_existing_links "$alias_dir"
    fi
    
    local total_success=0
    
    # 处理图片文件
    local img_success
    img_success=$(process_directory_type "*_img" "图片" "$alias_dir" "$force_overwrite")
    total_success=$((total_success + img_success))
    
    # 处理表格文件
    local table_success
    table_success=$(process_directory_type "*_tables" "表格" "$alias_dir" "$force_overwrite")
    total_success=$((total_success + table_success))
    
    # 显示最终统计
    echo ""
    show_info "链接创建完成"
    echo "📊 总计成功: $total_success 个链接"
    echo "📁 别名目录: $alias_dir"
    
    # 显示别名目录内容统计
    local link_count=$(find "$alias_dir" -type l 2>/dev/null | wc -l)
    echo "🔗 目录中共有: $link_count 个符号链接"
    
    if [ $total_success -eq 0 ]; then
        show_warning "未创建任何链接，请检查是否存在 *_img 或 *_tables 目录"
    fi
}

# 主程序
main() {
    # 默认值
    local source_dir="."
    local alias_dir="$DEFAULT_ALIAS_DIR"
    local clean_first=false
    local force_overwrite=false
    local verbose=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--clean)
                clean_first=true
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
                elif [ "$alias_dir" = "$DEFAULT_ALIAS_DIR" ]; then
                    alias_dir="$1"
                else
                    show_error "过多参数: $1"
                    show_help
                fi
                shift
                ;;
        esac
    done
    
    # 执行链接创建
    create_alias_links "$source_dir" "$alias_dir" "$clean_first" "$force_overwrite"
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
