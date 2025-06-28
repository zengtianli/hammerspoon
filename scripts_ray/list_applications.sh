#!/bin/bash

# list_app.sh - 应用程序列表工具
# 功能: 列出系统中已安装的应用程序
# 版本: 2.0.0
# 作者: tianli
# 更新: 2024-01-01

# 引入通用函数库
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

# 脚本版本信息
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

# 应用程序目录
readonly APP_DIRS=(
    "/Applications"
    "/System/Applications"
    "/System/Library/CoreServices/Applications"
    "$HOME/Applications"
)

# 显示版本信息
show_version() {
    echo "应用程序列表工具 v$SCRIPT_VERSION"
    echo "作者: $SCRIPT_AUTHOR"
    echo "更新日期: $SCRIPT_UPDATED"
}

# 显示帮助信息
show_help() {
    cat << EOF
应用程序列表工具 - 列出系统中已安装的应用程序

用法: $0 [选项] [搜索关键词]

选项:
    -a, --all        显示所有应用程序（包括系统应用）
    -s, --sort       按名称排序显示
    -c, --count      仅显示应用程序数量
    -o, --output     输出到文件
    -f, --format     输出格式 (list|csv|json)
    -v, --verbose    显示详细信息
    -h, --help       显示此帮助信息
    --version        显示版本信息

参数:
    搜索关键词      过滤应用程序名称（支持正则表达式）

示例:
    $0                          # 列出用户应用程序
    $0 -a                       # 列出所有应用程序
    $0 -s safari                # 搜索并排序显示Safari相关应用
    $0 -f csv -o apps.csv       # 输出CSV格式到文件
    $0 -c                       # 仅显示应用程序数量

输出格式:
    list - 简单列表（默认）
    csv  - CSV格式（名称,版本,路径）
    json - JSON格式
EOF
    exit 0
}

# 获取应用程序信息
# 参数: $1 = 应用程序路径
get_app_info() {
    local app_path="$1"
    local app_name=$(basename "$app_path" .app)
    local version=""
    local bundle_id=""
    
    # 获取版本信息
    local info_plist="$app_path/Contents/Info.plist"
    if [ -f "$info_plist" ]; then
        version=$(defaults read "$info_plist" CFBundleShortVersionString 2>/dev/null || echo "未知")
        bundle_id=$(defaults read "$info_plist" CFBundleIdentifier 2>/dev/null || echo "未知")
    else
        version="未知"
        bundle_id="未知"
    fi
    
    echo "$app_name|$version|$bundle_id|$app_path"
}

# 搜索应用程序
# 参数: 前面是目录列表，最后两个参数是搜索模式和是否显示系统应用
find_applications() {
    local args=("$@")
    local arg_count=${#args[@]}
    
    # 提取最后两个参数
    local search_pattern=""
    local show_system="false"
    
    if [ $arg_count -ge 2 ]; then
        search_pattern="${args[$((arg_count-2))]}"
        show_system="${args[$((arg_count-1))]}"
    fi
    
    # 构建目录数组（排除最后两个参数）
    local directories=()
    for ((i=0; i<arg_count-2; i++)); do
        directories+=("${args[$i]}")
    done
    
    local apps=()
    local total_found=0
    
    # 搜索每个目录
    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            continue
        fi
        
        # 判断是否为系统目录
        local is_system_dir=false
        if [[ "$dir" == "/System"* ]]; then
            is_system_dir=true
        fi
        
        # 跳过系统目录（如果不显示系统应用）
        if [ "$is_system_dir" = true ] && [ "$show_system" = false ]; then
            continue
        fi
        
        show_processing "搜索目录: $dir"
        
        # 查找 .app 文件
        while IFS= read -r -d '' app; do
            local app_name=$(basename "$app" .app)
            
            # 应用搜索过滤
            if [ -n "$search_pattern" ]; then
                if ! echo "$app_name" | grep -qi "$search_pattern"; then
                    continue
                fi
            fi
            
            apps+=("$app")
            ((total_found++))
        done < <(find "$dir" -maxdepth 1 -name "*.app" -type d -print0 2>/dev/null)
    done
    
    # 返回找到的应用程序
    printf '%s\n' "${apps[@]}"
    return $total_found
}

# 输出应用程序列表
# 参数: $1 = 格式, $2 = 输出文件, $3 = 应用程序数组
output_applications() {
    local format="$1"
    local output_file="$2"
    shift 2
    local apps=("$@")
    
    local output_stream
    if [ -n "$output_file" ]; then
        output_stream="$output_file"
        > "$output_file"  # 清空文件
    else
        output_stream="/dev/stdout"
    fi
    
    case "$format" in
        "csv")
            echo "名称,版本,Bundle ID,路径" > "$output_stream"
            for app in "${apps[@]}"; do
                local info=$(get_app_info "$app")
                echo "$info" | tr '|' ',' >> "$output_stream"
            done
            ;;
        "json")
            echo '{"applications": [' > "$output_stream"
            local first=true
            for app in "${apps[@]}"; do
                local info=$(get_app_info "$app")
                IFS='|' read -r name version bundle_id path <<< "$info"
                
                if [ "$first" = false ]; then
                    echo "," >> "$output_stream"
                fi
                
                cat << EOF >> "$output_stream"
  {
    "name": "$name",
    "version": "$version", 
    "bundle_id": "$bundle_id",
    "path": "$path"
  }
EOF
                first=false
            done
            echo ']' >> "$output_stream"
            echo '}' >> "$output_stream"
            ;;
        "list"|*)
            for app in "${apps[@]}"; do
                local info=$(get_app_info "$app")
                IFS='|' read -r name version bundle_id path <<< "$info"
                echo "$name ($version)" >> "$output_stream"
            done
            ;;
    esac
}

# 主程序
main() {
    # 默认值
    local show_all=false
    local sort_output=false
    local count_only=false
    local output_file=""
    local format="list"
    local search_pattern=""
    local verbose=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                show_all=true
                shift
                ;;
            -s|--sort)
                sort_output=true
                shift
                ;;
            -c|--count)
                count_only=true
                shift
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -f|--format)
                format="$2"
                if [[ ! "$format" =~ ^(list|csv|json)$ ]]; then
                    show_error "无效的输出格式: $format"
                    show_help
                fi
                shift 2
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
                search_pattern="$1"
                shift
                ;;
        esac
    done
    
    show_info "扫描应用程序..."
    
    # 查找应用程序
    local apps=()
    while IFS= read -r -d '' app; do
        if [ -n "$app" ]; then
            apps+=("$app")
        fi
    done < <(find_applications "${APP_DIRS[@]}" "$search_pattern" "$show_all" | tr '\n' '\0')
    
    local app_count=${#apps[@]}
    
    # 如果只显示数量
    if [ "$count_only" = true ]; then
        echo "找到 $app_count 个应用程序"
        exit 0
    fi
    
    if [ $app_count -eq 0 ]; then
        if [ -n "$search_pattern" ]; then
            show_warning "未找到匹配 '$search_pattern' 的应用程序"
        else
            show_warning "未找到任何应用程序"
        fi
        exit 0
    fi
    
    # 排序（如果需要）
    if [ "$sort_output" = true ]; then
        # 按应用程序名称排序
        IFS=$'\n' apps=($(printf '%s\n' "${apps[@]}" | sort))
    fi
    
    show_info "找到 $app_count 个应用程序"
    
    # 输出结果
    output_applications "$format" "$output_file" "${apps[@]}"
    
    if [ -n "$output_file" ]; then
        show_success "结果已输出到: $output_file"
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

