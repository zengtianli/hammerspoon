# Execute脚本代码规范文档 v2.0

## 目标
统一execute目录下所有脚本的代码风格和实现方式，提高代码的可维护性、可读性、安全性和一致性。适用于Shell脚本和Python脚本的统一规范。

## 核心原则
1. **DRY (Don't Repeat Yourself)**: 相同功能使用统一的实现
2. **双语言统一**: Shell和Python脚本遵循统一的设计模式
3. **健壮性**: 完善的错误处理和验证机制
4. **可读性**: 代码结构清晰，注释完整
5. **安全性**: 输入验证，防止安全问题
6. **兼容性**: 保持向后兼容性

## 1. 通用函数库引入规范

### 1.1 Shell脚本必须引入

```bash
#!/bin/bash

# 脚本描述、功能说明
# 版本: 2.0.0
# 作者: tianli
# 更新: 2024-01-01

# 引入通用函数库
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

# 脚本版本信息
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"
```

### 1.2 Python脚本必须引入

```python
#!/usr/bin/env python3
"""
脚本描述、功能说明
版本: 2.0.0
作者: tianli
更新: 2024-01-01
"""

import sys
import argparse
from pathlib import Path
from typing import Optional, List

# 引入通用工具模块
from common_utils import (
    show_success, show_error, show_warning, show_info, show_processing,
    validate_input_file, check_file_extension, get_file_basename,
    ProgressTracker, fatal_error, check_python_packages
)

# 脚本版本信息
SCRIPT_VERSION = "2.0.0"
SCRIPT_AUTHOR = "tianli"
SCRIPT_UPDATED = "2024-01-01"
```

## 2. 标准代码结构

### 2.1 Shell脚本结构模板

```bash
#!/bin/bash

# 头部信息标准化
# [脚本描述]
# 功能: [详细功能说明]
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
    show_version_template  # 使用模板函数
}

# 显示帮助信息
show_help() {
    show_help_header "$0" "脚本功能描述"
    echo "    -r, --recursive  递归处理子目录"
    echo "    -v, --verbose    显示详细输出"
    show_help_footer
    exit 0
}

# 检查依赖
check_dependencies() {
    show_info "检查依赖项..."
    
    # 检查必要的命令
    check_command_exists "required_command" || return 1
    
    # 检查Python包（如果需要）
    # check_python_packages package1 package2 || return 1
    
    show_success "依赖检查完成"
    return 0
}

# 处理单个文件的函数
process_single_file() {
    local file="$1"
    
    # 验证输入文件
    validate_input_file "$file" || return 1
    
    # 检查文件类型
    if ! check_file_extension "$file" "expected_ext"; then
        show_warning "跳过不支持的文件: $(basename "$file")"
        return 1
    fi
    
    show_processing "处理: $(basename "$file")"
    
    # 执行实际处理
    if retry_command some_command "$file"; then
        show_success "已处理: $(basename "$file")"
        return 0
    else
        show_error "处理失败: $(basename "$file")"
        return 1
    fi
}

# 批量处理函数
batch_process() {
    local target_dir="${1:-.}"
    local recursive="$2"
    
    # 验证目录
    if [ ! -d "$target_dir" ]; then
        fatal_error "目录不存在: $target_dir"
    fi
    
    show_info "处理目录: $target_dir"
    
    # 统计变量
    local success_count=0
    local failed_count=0
    local total_count=0
    
    # 查找和处理文件
    local find_cmd="find '$target_dir' -maxdepth 1"
    if [ "$recursive" = true ]; then
        find_cmd="find '$target_dir'"
    fi
    
    while IFS= read -r -d '' file; do
        ((total_count++))
        show_progress "$total_count" "?" "$(basename "$file")"
        
        if process_single_file "$file"; then
            ((success_count++))
        else
            ((failed_count++))
        fi
    done < <(eval "$find_cmd -name '*.ext' -type f -print0" 2>/dev/null)
    
    # 显示统计
    echo ""
    show_info "处理完成"
    echo "✅ 成功处理: $success_count 个文件"
    if [ $failed_count -gt 0 ]; then
        echo "❌ 处理失败: $failed_count 个文件"
    fi
    echo "📊 总计: $total_count 个文件"
}

# 主程序
main() {
    # 默认值
    local target_dir="."
    local recursive=false
    local verbose=false
    
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
                target_dir="$1"
                shift
                ;;
        esac
    done
    
    # 检查依赖
    check_dependencies || exit 1
    
    # 执行主要功能
    batch_process "$target_dir" "$recursive"
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
```

### 2.2 Python脚本结构模板

```python
#!/usr/bin/env python3
"""
[脚本描述] - [详细功能说明]
版本: 2.0.0
作者: tianli
更新: 2024-01-01
"""

import sys
import argparse
from pathlib import Path
from typing import Optional, List

# 引入通用工具模块
from common_utils import (
    show_success, show_error, show_warning, show_info, show_processing,
    validate_input_file, check_file_extension, get_file_basename,
    ProgressTracker, fatal_error, check_python_packages,
    show_version_info, find_files_by_extension
)

# 脚本版本信息
SCRIPT_VERSION = "2.0.0"
SCRIPT_AUTHOR = "tianli"
SCRIPT_UPDATED = "2024-01-01"

def check_dependencies() -> bool:
    """检查依赖"""
    show_info("检查依赖项...")
    
    # 检查必要的Python包
    if not check_python_packages(['required_package']):
        return False
    
    show_success("依赖检查完成")
    return True

def process_single_file(input_file: Path, output_file: Optional[Path] = None) -> bool:
    """处理单个文件"""
    try:
        # 验证输入文件
        if not validate_input_file(input_file):
            return False
        
        # 检查文件扩展名
        if not check_file_extension(input_file, 'expected_ext'):
            show_warning(f"跳过不支持的文件: {input_file.name}")
            return False
        
        show_processing(f"处理: {input_file.name}")
        
        # 执行实际处理逻辑
        # ... 具体处理代码 ...
        
        show_success(f"已处理: {input_file.name}")
        return True
        
    except Exception as e:
        show_error(f"处理失败: {input_file.name} - {e}")
        return False

def batch_process(directory: Path, recursive: bool = False) -> None:
    """批量处理文件"""
    show_info(f"处理目录: {directory}")
    
    # 查找目标文件
    files = find_files_by_extension(directory, 'target_ext', recursive)
    
    if not files:
        show_warning("未找到目标文件")
        return
    
    show_info(f"找到 {len(files)} 个文件")
    
    # 初始化进度跟踪器
    tracker = ProgressTracker()
    
    # 处理每个文件
    for i, file in enumerate(files, 1):
        show_progress(i, len(files), file.name)
        
        if process_single_file(file):
            tracker.add_success()
        else:
            tracker.add_failure()
    
    # 显示统计
    tracker.show_summary("文件处理")

def show_version() -> None:
    """显示版本信息"""
    show_version_info(SCRIPT_VERSION, SCRIPT_AUTHOR, SCRIPT_UPDATED)

def show_help() -> None:
    """显示帮助信息"""
    print(f"""
[脚本名称] - [脚本功能描述]

用法:
    python3 {sys.argv[0]} [选项] [输入] [输出]

参数:
    输入            输入文件或目录
    输出            输出文件或目录（可选）

选项:
    -r, --recursive  递归处理子目录
    -h, --help       显示此帮助信息
    --version        显示版本信息

示例:
    python3 {sys.argv[0]} input.txt              # 处理单个文件
    python3 {sys.argv[0]} ./data_dir             # 批量处理目录
    python3 {sys.argv[0]} -r ./data_dir          # 递归处理目录

依赖:
    - required_package
    """)

def main():
    """主函数"""
    parser = argparse.ArgumentParser(
        description='[脚本功能描述]',
        add_help=False
    )
    
    parser.add_argument('input', nargs='?', help='输入文件或目录')
    parser.add_argument('output', nargs='?', help='输出文件或目录')
    parser.add_argument('-r', '--recursive', action='store_true', help='递归处理子目录')
    parser.add_argument('-h', '--help', action='store_true', help='显示帮助信息')
    parser.add_argument('--version', action='store_true', help='显示版本信息')
    
    args = parser.parse_args()
    
    if args.help:
        show_help()
        return
    
    if args.version:
        show_version()
        return
    
    # 检查依赖
    if not check_dependencies():
        sys.exit(1)
    
    # 处理输入
    if not args.input:
        # 默认处理当前目录
        batch_process(Path.cwd())
    else:
        input_path = Path(args.input)
        
        if input_path.is_file():
            # 单文件处理
            output_path = None
            if args.output:
                output_path = Path(args.output)
            
            if process_single_file(input_path, output_path):
                show_success("处理完成")
            else:
                sys.exit(1)
        
        elif input_path.is_dir():
            # 目录处理
            batch_process(input_path, args.recursive)
        
        else:
            fatal_error(f"输入路径不存在: {input_path}")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        show_warning("用户中断操作")
        sys.exit(1)
    except Exception as e:
        show_error(f"程序执行失败: {e}")
        sys.exit(1)
```

## 3. 必须遵循的编码规范

### 3.1 文件命名规范
- **功能前缀**: 使用动词表示主要功能 (`convert_`, `extract_`, `merge_`, `list_`, `manage_`, `file_`)
- **对象描述**: 明确处理的对象类型 (`csv`, `docx`, `images` 等)
- **转换方向**: 对于转换类，使用 `from_to` 格式 (`csv_to_xlsx`)
- **下划线分隔**: 统一使用下划线而非驼峰命名

### 3.2 版本信息规范
所有脚本必须包含统一的版本信息：
- **版本号**: `SCRIPT_VERSION="2.0.0"`
- **作者**: `SCRIPT_AUTHOR="tianli"`
- **更新日期**: `SCRIPT_UPDATED="2024-01-01"`

### 3.3 消息显示规范
必须使用统一的消息显示函数：
- `show_success()` - 成功操作
- `show_error()` - 错误信息
- `show_warning()` - 警告信息
- `show_processing()` - 处理中状态
- `show_info()` - 一般信息
- `show_progress()` - 进度显示

### 3.4 错误处理规范
- **输入验证**: 使用 `validate_input_file()` 验证所有输入文件
- **路径安全**: 使用 `validate_file_path()` 防止路径注入
- **命令检查**: 使用 `check_command_exists()` 验证依赖
- **重试机制**: 使用 `retry_command()` 增强稳定性
- **优雅退出**: 使用 `fatal_error()` 处理致命错误

### 3.5 文件操作规范
- **扩展名检查**: 使用 `check_file_extension()` 验证文件类型
- **文件大小检查**: 使用 `check_file_size()` 防止资源耗尽
- **目录操作**: 使用 `safe_cd()` 和 `ensure_directory()` 安全操作
- **临时文件**: 使用 `create_temp_dir()` 和 `cleanup_temp_dir()` 管理

## 4. 参数处理规范

### 4.1 Shell脚本参数处理

```bash
# 标准参数解析模式
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
        -f|--force)
            force=true
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
            # 位置参数处理
            if [ -z "$input_arg" ]; then
                input_arg="$1"
            elif [ -z "$output_arg" ]; then
                output_arg="$1"
            else
                show_error "过多参数: $1"
                show_help
            fi
            shift
            ;;
    esac
done
```

### 4.2 Python脚本参数处理

```python
parser = argparse.ArgumentParser(
    description='脚本功能描述',
    add_help=False  # 使用自定义帮助
)

parser.add_argument('input', nargs='?', help='输入文件或目录')
parser.add_argument('output', nargs='?', help='输出文件或目录')
parser.add_argument('-r', '--recursive', action='store_true', 
                   help='递归处理子目录')
parser.add_argument('-v', '--verbose', action='store_true', 
                   help='显示详细输出')
parser.add_argument('-f', '--force', action='store_true', 
                   help='强制覆盖已存在的文件')
parser.add_argument('-h', '--help', action='store_true', 
                   help='显示帮助信息')
parser.add_argument('--version', action='store_true', 
                   help='显示版本信息')
```

## 5. 统计和进度显示规范

### 5.1 Shell脚本统计显示

```bash
# 统计变量初始化
success_count=0
failed_count=0
total_count=0

# 处理过程中更新计数
if process_file "$file"; then
    ((success_count++))
else
    ((failed_count++))
fi

# 最终统计显示
echo ""
show_info "处理完成"
echo "✅ 成功处理: $success_count 个文件"
if [ $failed_count -gt 0 ]; then
    echo "❌ 处理失败: $failed_count 个文件"
fi
echo "📊 总计: $total_count 个文件"

if [ $total_count -gt 0 ]; then
    local success_rate=$((success_count * 100 / total_count))
    echo "📊 成功率: ${success_rate}%"
fi
```

### 5.2 Python脚本进度跟踪

```python
# 使用ProgressTracker类
tracker = ProgressTracker()

for file in files:
    if process_file(file):
        tracker.add_success()
    else:
        tracker.add_failure()

# 显示最终统计
tracker.show_summary("文件处理")
```

## 6. 依赖管理规范

### 6.1 Shell脚本依赖检查

```bash
check_dependencies() {
    show_info "检查依赖项..."
    
    # 检查系统命令
    local commands=("pandoc" "markitdown" "libreoffice")
    for cmd in "${commands[@]}"; do
        check_command_exists "$cmd" || return 1
    done
    
    # 检查Python环境
    check_python_env || return 1
    
    # 检查Python包
    check_python_packages package1 package2 || return 1
    
    show_success "依赖检查完成"
    return 0
}
```

### 6.2 Python脚本依赖检查

```python
def check_dependencies() -> bool:
    """检查依赖"""
    show_info("检查依赖项...")
    
    # 检查必要的Python包
    required_packages = ['pandas', 'openpyxl', 'python-docx']
    if not check_python_packages(required_packages):
        return False
    
    show_success("依赖检查完成")
    return True
```

## 7. 安全性规范

### 7.1 输入验证
```bash
# 所有文件输入必须验证
validate_input_file "$file" || continue

# 所有路径必须安全检查
validate_file_path "$path" || exit 1

# 文件大小检查
check_file_size "$file" 100 || {
    show_warning "文件过大，谨慎处理"
}
```

### 7.2 临时文件管理
```bash
# 创建临时目录
temp_dir=$(create_temp_dir)

# 设置清理陷阱
cleanup() {
    cleanup_temp_dir "$temp_dir"
}
trap cleanup EXIT
```

## 8. 文档规范

### 8.1 帮助信息必须包含
- 功能描述
- 用法示例
- 参数说明
- 选项说明
- 依赖要求
- 示例命令

### 8.2 注释规范
- 函数必须有功能说明注释
- 复杂逻辑必须有行内注释
- 重要变量必须有说明注释

## 9. 测试和验证

### 9.1 基本测试检查点
- [ ] 无参数运行不报错
- [ ] 帮助信息显示正确
- [ ] 版本信息显示正确
- [ ] 错误输入有合适的错误提示
- [ ] 依赖检查功能正常
- [ ] 文件验证功能正常

### 9.2 边界条件测试
- [ ] 大文件处理
- [ ] 空目录处理
- [ ] 特殊字符文件名
- [ ] 权限不足的情况
- [ ] 磁盘空间不足的情况

## 10. 迁移和兼容性

### 10.1 向后兼容原则
- 保持原有的基本功能接口
- 新增功能使用可选参数
- 废弃功能给出明确的警告提示

### 10.2 软链接支持
- 为重命名的脚本创建软链接
- 保持旧的调用方式可用
- 在文档中说明新旧命名的对应关系

## 版本历史

### v2.0.0 (2024-01-01)
- 初始版本，基于重构后的execute脚本
- 建立Shell和Python双语言统一规范
- 完善错误处理和安全性规范
- 建立统一的通用函数库体系 