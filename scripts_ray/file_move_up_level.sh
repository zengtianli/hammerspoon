#!/bin/bash

# move_files_up.sh - 文件上移工具
# 功能: 将子目录中的文件移动到上级目录
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
    echo "文件上移工具 v$SCRIPT_VERSION"
    echo "作者: $SCRIPT_AUTHOR"
    echo "更新日期: $SCRIPT_UPDATED"
}

# 显示帮助信息
show_help() {
    cat << EOF
文件上移工具 - 将子目录中的文件移动到上级目录

用法: $0 [选项] [目录]

选项:
    -r, --remove-empty  移动后删除空目录
    -f, --force         强制覆盖同名文件
    -d, --dry-run       预览模式，不实际执行操作
    -v, --verbose       显示详细输出
    -h, --help          显示此帮助信息
    --version           显示版本信息

参数:
    目录               要处理的目录（默认：当前目录）

示例:
    $0                      # 处理当前目录
    $0 -r                   # 移动文件并删除空目录
    $0 -d ./folder          # 预览模式检查指定目录
    $0 -f -r ./docs         # 强制覆盖并删除空目录

功能:
    - 将所有子目录中的文件移动到父目录
    - 自动处理文件名冲突
    - 可选择删除空目录
    - 支持预览模式
EOF
    exit 0
}

# 生成唯一文件名
# 参数: $1 = 目标目录, $2 = 原始文件名
generate_unique_name() {
    local target_dir="$1"
    local original_name="$2"
    local base_name="${original_name%.*}"
    local extension="${original_name##*.}"
    local target_path="$target_dir/$original_name"
    
    # 如果文件不存在，直接返回原名
    if [ ! -e "$target_path" ]; then
        echo "$original_name"
        return 0
    fi
    
    # 生成带数字后缀的文件名
    local counter=1
    while true; do
        if [ "$base_name" = "$extension" ]; then
            # 没有扩展名的文件
            local new_name="${base_name}_${counter}"
        else
            local new_name="${base_name}_${counter}.${extension}"
        fi
        
        if [ ! -e "$target_dir/$new_name" ]; then
            echo "$new_name"
            return 0
        fi
        
        ((counter++))
    done
}

# 移动单个文件
# 参数: $1 = 源文件, $2 = 目标目录, $3 = 强制覆盖, $4 = 预览模式
move_single_file() {
    local source_file="$1"
    local target_dir="$2"
    local force_overwrite="$3"
    local dry_run="$4"
    
    # 验证源文件
    validate_input_file "$source_file" || return 1
    
    local filename=$(basename "$source_file")
    local target_file="$target_dir/$filename"
    
    # 处理文件名冲突
    if [ -e "$target_file" ]; then
        if [ "$force_overwrite" = true ]; then
            target_file="$target_dir/$filename"
        else
            local unique_name=$(generate_unique_name "$target_dir" "$filename")
            target_file="$target_dir/$unique_name"
            show_warning "文件名冲突，重命名为: $unique_name"
        fi
    fi
    
    # 预览模式
    if [ "$dry_run" = true ]; then
        show_info "[预览] 移动: $source_file -> $target_file"
        return 0
    fi
    
    # 执行移动
    if mv "$source_file" "$target_file" 2>/dev/null; then
        show_success "已移动: $(basename "$source_file") -> $(basename "$target_file")"
        return 0
    else
        show_error "移动失败: $(basename "$source_file")"
        return 1
    fi
}

# 检查目录是否为空
# 参数: $1 = 目录路径
is_directory_empty() {
    local dir="$1"
    [ -d "$dir" ] && [ -z "$(ls -A "$dir" 2>/dev/null)" ]
}

# 处理单个子目录
# 参数: $1 = 子目录路径, $2 = 父目录, $3 = 强制覆盖, $4 = 预览模式, $5 = 删除空目录
process_subdirectory() {
    local subdir="$1"
    local parent_dir="$2"
    local force_overwrite="$3"
    local dry_run="$4"
    local remove_empty="$5"
    
    if [ ! -d "$subdir" ]; then
        show_warning "跳过非目录: $(basename "$subdir")"
        return 1
    fi
    
    local subdir_name=$(basename "$subdir")
    show_processing "处理子目录: $subdir_name"
    
    local moved_count=0
    local failed_count=0
    
    # 处理子目录中的所有文件
    while IFS= read -r -d '' file; do
        if move_single_file "$file" "$parent_dir" "$force_overwrite" "$dry_run"; then
            ((moved_count++))
        else
            ((failed_count++))
        fi
    done < <(find "$subdir" -maxdepth 1 -type f -print0 2>/dev/null)
    
    # 递归处理子目录的子目录中的文件
    while IFS= read -r -d '' nested_file; do
        if move_single_file "$nested_file" "$parent_dir" "$force_overwrite" "$dry_run"; then
            ((moved_count++))
        else
            ((failed_count++))
        fi
    done < <(find "$subdir" -mindepth 2 -type f -print0 2>/dev/null)
    
    # 删除空目录（如果需要）
    if [ "$remove_empty" = true ] && [ "$dry_run" = false ]; then
        if is_directory_empty "$subdir"; then
            if rmdir "$subdir" 2>/dev/null; then
                show_success "已删除空目录: $subdir_name"
            else
                show_warning "无法删除目录: $subdir_name"
            fi
        else
            show_info "目录非空，保留: $subdir_name"
        fi
    elif [ "$remove_empty" = true ] && [ "$dry_run" = true ]; then
        if is_directory_empty "$subdir"; then
            show_info "[预览] 将删除空目录: $subdir_name"
        fi
    fi
    
    echo "  📊 子目录统计: 成功移动 $moved_count 个文件，失败 $failed_count 个"
    return $moved_count
}

# 移动文件到上级目录
# 参数: $1 = 源目录, $2 = 强制覆盖, $3 = 预览模式, $4 = 删除空目录
move_files_up() {
    local source_dir="${1:-.}"
    local force_overwrite="$2"
    local dry_run="$3"
    local remove_empty="$4"
    
    # 验证源目录
    if [ ! -d "$source_dir" ]; then
        fatal_error "源目录不存在: $source_dir"
    fi
    
    # 切换到源目录
    safe_cd "$source_dir" || return 1
    
    show_info "文件上移操作"
    show_info "工作目录: $(pwd)"
    show_info "预览模式: $([ "$dry_run" = true ] && echo "是" || echo "否")"
    show_info "强制覆盖: $([ "$force_overwrite" = true ] && echo "是" || echo "否")"
    show_info "删除空目录: $([ "$remove_empty" = true ] && echo "是" || echo "否")"
    
    # 查找所有子目录
    local subdirs=()
    while IFS= read -r -d '' dir; do
        subdirs+=("$dir")
    done < <(find . -maxdepth 1 -type d -not -path "." -print0 2>/dev/null)
    
    if [ ${#subdirs[@]} -eq 0 ]; then
        show_warning "未找到子目录"
        return 0
    fi
    
    show_info "找到 ${#subdirs[@]} 个子目录"
    
    # 统计变量
    local total_moved=0
    local processed_dirs=0
    
    # 处理每个子目录
    for subdir in "${subdirs[@]}"; do
        ((processed_dirs++))
        show_progress "$processed_dirs" "${#subdirs[@]}" "$(basename "$subdir")"
        
        local moved_count
        moved_count=$(process_subdirectory "$subdir" "." "$force_overwrite" "$dry_run" "$remove_empty")
        total_moved=$((total_moved + moved_count))
    done
    
    # 显示最终统计
    echo ""
    show_info "操作完成"
    echo "📁 处理目录: ${#subdirs[@]} 个"
    echo "📄 移动文件: $total_moved 个"
    
    if [ "$dry_run" = true ]; then
        show_info "这是预览模式，未实际执行任何操作"
        show_info "使用不带 -d 选项的命令来实际执行操作"
    fi
}

# 主程序
main() {
    # 默认值
    local target_dir="."
    local remove_empty=false
    local force_overwrite=false
    local dry_run=false
    local verbose=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--remove-empty)
                remove_empty=true
                shift
                ;;
            -f|--force)
                force_overwrite=true
                shift
                ;;
            -d|--dry-run)
                dry_run=true
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
                target_dir="$1"
                shift
                ;;
        esac
    done
    
    # 执行文件移动
    move_files_up "$target_dir" "$force_overwrite" "$dry_run" "$remove_empty"
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
