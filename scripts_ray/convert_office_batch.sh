#!/bin/bash

# convert_all.sh - 文档格式转换综合工具
# 功能：
#   - doc -> docx -> md
#   - xls -> xlsx -> csv
#   - pptx -> md

# 引入通用函数库
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

# 脚本版本信息
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

# 定义各脚本的路径
readonly DOC2DOCX_SCRIPT="${DOC2DOCX_SCRIPT:-$SCRIPTS_DIR/doc2docx.sh}"
readonly DOCX2MD_SCRIPT="${DOCX2MD_SCRIPT:-$SCRIPTS_DIR/convert_docx_to_md.sh}"
readonly PPTX2MD_SCRIPT="${PPTX2MD_SCRIPT:-$SCRIPTS_DIR/convert_pptx_to_md.py}"
readonly XLS2XLSX_SCRIPT="${XLS2XLSX_SCRIPT:-$SCRIPTS_DIR/xls2xlsx.sh}"
readonly XLSX2CSV_SCRIPT="${XLSX2CSV_SCRIPT:-$SCRIPTS_DIR/convert_xlsx_to_csv.py}"

# 定义输出目录
readonly OUTPUT_DIR="${OUTPUT_DIR:-./converted}"
readonly MD_OUTPUT_DIR="$OUTPUT_DIR/md"
readonly CSV_OUTPUT_DIR="$OUTPUT_DIR/csv"

# 转换统计
CONVERT_COUNT_DOC_TO_DOCX=0
CONVERT_COUNT_XLS_TO_XLSX=0
CONVERT_COUNT_DOCX_TO_MD=0
CONVERT_COUNT_XLSX_TO_CSV=0
CONVERT_COUNT_PPTX_TO_MD=0

# 显示版本信息
show_version() {
    echo "脚本版本: $SCRIPT_VERSION"
    echo "作者: $SCRIPT_AUTHOR"
    echo "更新日期: $SCRIPT_UPDATED"
}

# 显示使用帮助
show_help() {
    cat << EOF
文档格式转换综合工具

用法: $0 [选项]

选项:
    -d, --doc      转换所有 .doc 文件为 .docx，然后转为 .md
    -x, --excel    转换所有 .xls 文件为 .xlsx，然后转为 .csv
    -p, --ppt      转换所有 .pptx 文件为 .md
    -a, --all      执行所有转换（doc、excel、ppt）
    -r, --recursive 递归处理子目录
    -v, --verbose   显示详细输出
    -h, --help      显示此帮助信息
    --version       显示版本信息

单独转换选项:
    --doc-only     仅转换 doc 到 docx
    --docx-only    仅转换 docx 到 md
    --xls-only     仅转换 xls 到 xlsx
    --xlsx-only    仅转换 xlsx 到 csv
    --xlsx-single-sheet 对xlsx文件只转换默认工作表，而不转换所有工作表
    
示例:
    $0 -a          # 转换当前目录下所有支持的文件
    $0 -a -r       # 递归转换所有子目录
    $0 -d -r       # 递归转换所有 doc 文件
    $0 -x          # 转换所有 Excel 文件
    
EOF
    exit 0
}

# 检查必要的工具和脚本
check_dependencies() {
    local missing_deps=0
    
    show_info "检查依赖项..."
    
    # 检查 Python
    if ! check_python_env; then
        missing_deps=1
    fi
    
    # 检查 markitdown
    if ! check_command_exists markitdown; then
        show_warning "未找到 markitdown，请先安装：pip install markitdown"
        missing_deps=1
    fi
    
    # 检查各个转换脚本
    local scripts=("$DOC2DOCX_SCRIPT" "$DOCX2MD_SCRIPT" "$XLS2XLSX_SCRIPT")
    for script in "${scripts[@]}"; do
        if [ ! -f "$script" ]; then
            show_warning "未找到脚本: $script"
            missing_deps=1
        else
            chmod +x "$script"
        fi
    done
    
    if [ ! -f "$PPTX2MD_SCRIPT" ]; then
        show_warning "未找到脚本: $PPTX2MD_SCRIPT"
        missing_deps=1
    fi
    
    # 检查 Microsoft Office 应用
    if ! run_applescript 'tell application "Microsoft Word" to name' &> /dev/null; then
        show_warning "未找到 Microsoft Word，doc 转换功能将不可用"
    fi
    
    if ! run_applescript 'tell application "Microsoft Excel" to name' &> /dev/null; then
        show_warning "未找到 Microsoft Excel，xls 转换功能将不可用"
    fi
    
    if [ $missing_deps -eq 1 ]; then
        fatal_error "缺少必要的依赖项，请先解决上述问题"
    fi
    
    show_success "依赖检查完成"
}

# 处理单个文件转换
# 参数: $1 = 文件路径, $2 = 转换类型, $3 = 输出目录
process_single_file() {
    local file="$1"
    local convert_type="$2"
    local output_dir="$3"
    
    # 验证输入文件
    validate_input_file "$file" || return 1
    
    local base_name=$(get_file_basename "$file")
    local file_ext=$(get_file_extension "$file")
    
    case "$convert_type" in
        "docx2md")
            if check_file_extension "$file" "docx"; then
                ensure_directory "$output_dir" || return 1
                if retry_command "$DOCX2MD_SCRIPT" "$file" "$output_dir"; then
                    show_success "已转换: $(basename "$file") -> $base_name.md"
                    ((CONVERT_COUNT_DOCX_TO_MD++))
                    return 0
                fi
            fi
            ;;
        "xlsx2csv")
            if check_file_extension "$file" "xlsx"; then
                ensure_directory "$output_dir" || return 1
                if [ "$XLSX_CSV_SINGLE_SHEET" = true ]; then
                    if retry_command "$PYTHON_PATH" "$XLSX2CSV_SCRIPT" -d -o "$output_dir/$base_name.csv" "$file"; then
                        show_success "已转换: $(basename "$file") [默认工作表] -> $base_name.csv"
                        ((CONVERT_COUNT_XLSX_TO_CSV++))
                        return 0
                    fi
                else
                    local file_dir=$(dirname "$file")
                    safe_cd "$file_dir" || return 1
                    
                    # 清理可能存在的同名CSV文件
                    rm -f "${base_name}"_*.csv 2>/dev/null
                    
                    if retry_command "$PYTHON_PATH" "$XLSX2CSV_SCRIPT" "$file"; then
                        # 移动生成的CSV文件
                        local found_csv=false
                        for csv_file in "${base_name}"_*.csv; do
                            if [ -f "$csv_file" ]; then
                                found_csv=true
                                mv "$csv_file" "$output_dir/" && show_success "已移动: $(basename "$csv_file") 到 $output_dir/"
                                ((CONVERT_COUNT_XLSX_TO_CSV++))
                            fi
                        done
                        
                        if [ "$found_csv" = false ]; then
                            recoverable_error "转换失败: $file"
                            return 1
                        fi
                        return 0
                    fi
                fi
            fi
            ;;
        "pptx2md")
            if check_file_extension "$file" "pptx"; then
                local file_dir=$(dirname "$file")
                safe_cd "$file_dir" || return 1
                
                if [ "$VERBOSE" = true ]; then
                    retry_command "$PYTHON_PATH" "$PPTX2MD_SCRIPT" "$file" -v
                else
                    retry_command "$PYTHON_PATH" "$PPTX2MD_SCRIPT" "$file"
                fi
                
                ((CONVERT_COUNT_PPTX_TO_MD++))
                
                # 检查是否生成了同名文件夹
                if [ -d "$base_name" ]; then
                    ensure_directory "$output_dir" || return 1
                    [ -d "$output_dir/$base_name" ] && rm -rf "$output_dir/$base_name"
                    mv "$base_name" "$output_dir/"
                    show_success "已移动文件夹: $base_name 到 $output_dir/"
                    return 0
                else
                    recoverable_error "未找到生成的文件夹: $base_name"
                    return 1
                fi
            fi
            ;;
    esac
    
    return 1
}

# 转换 doc 文件
convert_doc_files() {
    show_info "开始处理 Word 文档..."
    
    # 第一步：doc -> docx
    if [ "$DOC_ONLY" = true ] || [ "$DOC_ONLY" != true ] && [ "$DOCX_ONLY" != true ]; then
        show_processing "转换 .doc 到 .docx ..."
        if [ "$RECURSIVE" = true ]; then
            retry_command "$DOC2DOCX_SCRIPT" -r
            local found_count=$(find . -name "*.doc" -not -name "*.docx" -type f 2>/dev/null | wc -l)
            CONVERT_COUNT_DOC_TO_DOCX=$((CONVERT_COUNT_DOC_TO_DOCX + found_count))
        else
            retry_command "$DOC2DOCX_SCRIPT"
            local found_count=$(ls -1 *.doc 2>/dev/null | grep -v "\.docx$" | wc -l)
            CONVERT_COUNT_DOC_TO_DOCX=$((CONVERT_COUNT_DOC_TO_DOCX + found_count))
        fi
    fi
    
    # 第二步：docx -> md
    if [ "$DOCX_ONLY" = true ] || [ "$DOC_ONLY" != true ] && [ "$DOCX_ONLY" != true ]; then
        show_processing "转换 .docx 到 .md ..."
        
        if [ "$RECURSIVE" = true ]; then
            find . -name "*.docx" -type f | while read -r file; do
                show_progress "$(basename "$file")"
                process_single_file "$file" "docx2md" "$MD_OUTPUT_DIR"
            done
        else
            for file in *.docx; do
                if [ -f "$file" ]; then
                    show_progress "$(basename "$file")"
                    process_single_file "$file" "docx2md" "$MD_OUTPUT_DIR"
                fi
            done
        fi
    fi
    
    show_success "Word 文档处理完成"
}

# 转换 Excel 文件
convert_excel_files() {
    show_info "开始处理 Excel 文档..."
    
    # 第一步：xls -> xlsx
    if [ "$XLS_ONLY" = true ] || [ "$XLS_ONLY" != true ] && [ "$XLSX_ONLY" != true ]; then
        show_processing "转换 .xls 到 .xlsx ..."
        if [ "$RECURSIVE" = true ]; then
            retry_command "$XLS2XLSX_SCRIPT" -r
            local found_count=$(find . -name "*.xls" -not -name "*.xlsx" -type f 2>/dev/null | wc -l)
            CONVERT_COUNT_XLS_TO_XLSX=$((CONVERT_COUNT_XLS_TO_XLSX + found_count))
        else
            retry_command "$XLS2XLSX_SCRIPT"
            local found_count=$(ls -1 *.xls 2>/dev/null | grep -v "\.xlsx$" | wc -l)
            CONVERT_COUNT_XLS_TO_XLSX=$((CONVERT_COUNT_XLS_TO_XLSX + found_count))
        fi
    fi
    
    # 第二步：xlsx -> csv
    if [ "$XLSX_ONLY" = true ] || [ "$XLS_ONLY" != true ] && [ "$XLSX_ONLY" != true ]; then
        show_processing "转换 .xlsx 到 .csv ..."
        
        if [ "$RECURSIVE" = true ]; then
            find . -name "*.xlsx" -type f | while read -r file; do
                show_progress "$(basename "$file")"
                process_single_file "$file" "xlsx2csv" "$CSV_OUTPUT_DIR"
            done
        else
            for file in *.xlsx; do
                if [ -f "$file" ]; then
                    show_progress "$(basename "$file")"
                    process_single_file "$file" "xlsx2csv" "$CSV_OUTPUT_DIR"
                fi
            done
        fi
    fi
    
    show_success "Excel 文档处理完成"
}

# 转换 PowerPoint 文件
convert_ppt_files() {
    show_info "开始处理 PowerPoint 文档..."
    
    if [ "$RECURSIVE" = true ]; then
        find . -name "*.pptx" -type f | while read -r file; do
            show_progress "$(basename "$file")"
            process_single_file "$file" "pptx2md" "$MD_OUTPUT_DIR"
        done
    else
        for file in *.pptx; do
            if [ -f "$file" ]; then
                show_progress "$(basename "$file")"
                process_single_file "$file" "pptx2md" "$MD_OUTPUT_DIR"
            fi
        done
    fi
    
    show_success "PowerPoint 文档处理完成"
}

# 统计文件数量
count_files() {
    local doc_count=0
    local docx_count=0
    local xls_count=0
    local xlsx_count=0
    local pptx_count=0
    
    if [ "$RECURSIVE" = true ]; then
        doc_count=$(find . -name "*.doc" -not -name "*.docx" -type f 2>/dev/null | wc -l)
        docx_count=$(find . -name "*.docx" -type f 2>/dev/null | wc -l)
        xls_count=$(find . -name "*.xls" -not -name "*.xlsx" -type f 2>/dev/null | wc -l)
        xlsx_count=$(find . -name "*.xlsx" -type f 2>/dev/null | wc -l)
        pptx_count=$(find . -name "*.pptx" -type f 2>/dev/null | wc -l)
    else
        doc_count=$(ls *.doc 2>/dev/null | grep -v "\.docx$" | wc -l)
        docx_count=$(ls *.docx 2>/dev/null | wc -l)
        xls_count=$(ls *.xls 2>/dev/null | grep -v "\.xlsx$" | wc -l)
        xlsx_count=$(ls *.xlsx 2>/dev/null | wc -l)
        pptx_count=$(ls *.pptx 2>/dev/null | wc -l)
    fi
    
    echo -e "\n${BLUE}文件统计:${NC}"
    echo "  .doc 文件:  $doc_count"
    echo "  .docx 文件: $docx_count"
    echo "  .xls 文件:  $xls_count"
    echo "  .xlsx 文件: $xlsx_count"
    echo "  .pptx 文件: $pptx_count"
    local total_count=$((doc_count + docx_count + xls_count + xlsx_count + pptx_count))
    echo "  需要转换的文件总数: $total_count"
    echo ""
}

# 显示转换统计
show_conversion_stats() {
    echo -e "\n${BLUE}转换统计:${NC}"
    echo "  doc -> docx: $CONVERT_COUNT_DOC_TO_DOCX"
    echo "  xls -> xlsx: $CONVERT_COUNT_XLS_TO_XLSX"
    echo "  docx -> md:  $CONVERT_COUNT_DOCX_TO_MD"
    echo "  xlsx -> csv: $CONVERT_COUNT_XLSX_TO_CSV"
    echo "  pptx -> md:  $CONVERT_COUNT_PPTX_TO_MD"
    local total_md_csv=$((CONVERT_COUNT_DOCX_TO_MD + CONVERT_COUNT_XLSX_TO_CSV + CONVERT_COUNT_PPTX_TO_MD))
    echo "  converted md and csv: $total_md_csv"
    echo ""
}

# 主程序
main() {
    # 默认值
    CONVERT_DOC=false
    CONVERT_EXCEL=false
    CONVERT_PPT=false
    CONVERT_ALL=false
    RECURSIVE=false
    VERBOSE=false
    DOC_ONLY=false
    DOCX_ONLY=false
    XLS_ONLY=false
    XLSX_ONLY=false
    XLSX_CSV_SINGLE_SHEET=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--doc)
                CONVERT_DOC=true
                shift
                ;;
            -x|--excel)
                CONVERT_EXCEL=true
                shift
                ;;
            -p|--ppt)
                CONVERT_PPT=true
                shift
                ;;
            -a|--all)
                CONVERT_ALL=true
                shift
                ;;
            -r|--recursive)
                RECURSIVE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --doc-only)
                DOC_ONLY=true
                CONVERT_DOC=true
                shift
                ;;
            --docx-only)
                DOCX_ONLY=true
                CONVERT_DOC=true
                shift
                ;;
            --xls-only)
                XLS_ONLY=true
                CONVERT_EXCEL=true
                shift
                ;;
            --xlsx-only)
                XLSX_ONLY=true
                CONVERT_EXCEL=true
                shift
                ;;
            --xlsx-single-sheet)
                XLSX_CSV_SINGLE_SHEET=true
                shift
                ;;
            --version)
                show_version
                exit 0
                ;;
            -h|--help)
                show_help
                ;;
            *)
                show_error "未知选项: $1"
                show_help
                ;;
        esac
    done
    
    # 如果没有指定任何转换选项，显示帮助
    if [ "$CONVERT_DOC" = false ] && [ "$CONVERT_EXCEL" = false ] && [ "$CONVERT_PPT" = false ] && [ "$CONVERT_ALL" = false ]; then
        show_warning "未指定任何转换选项"
        show_help
    fi
    
    # 创建输出目录
    ensure_directory "$OUTPUT_DIR" || fatal_error "无法创建输出目录"
    ensure_directory "$MD_OUTPUT_DIR" || fatal_error "无法创建MD输出目录"
    ensure_directory "$CSV_OUTPUT_DIR" || fatal_error "无法创建CSV输出目录"
    
    # 检查依赖
    check_dependencies
    
    # 显示文件统计
    count_files
    
    # 如果选择了全部转换
    if [ "$CONVERT_ALL" = true ]; then
        CONVERT_DOC=true
        CONVERT_EXCEL=true
        CONVERT_PPT=true
    fi
    
    # 记录开始时间
    local start_time=$(date +%s)
    
    # 执行转换
    if [ "$CONVERT_DOC" = true ]; then
        convert_doc_files
    fi
    
    if [ "$CONVERT_EXCEL" = true ]; then
        convert_excel_files
    fi
    
    if [ "$CONVERT_PPT" = true ]; then
        convert_ppt_files
    fi
    
    # 计算耗时
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo -e "\n${GREEN}=== 转换完成 ===${NC}"
    echo "总耗时: ${duration} 秒"
    
    # 再次显示文件统计，查看转换结果
    if [ "$VERBOSE" = true ]; then
        count_files
    fi
    
    show_conversion_stats
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
