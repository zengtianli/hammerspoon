# 通用函数库使用说明

## 概述

本项目重构了通用函数库，分为两个部分：
- `common_functions.sh` - Shell脚本通用函数库
- `common_utils.py` - Python脚本通用工具模块

## Shell脚本 (common_functions.sh)

### 引入方式

```bash
#!/bin/bash
# 引入通用函数库
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"
```

### 主要功能

#### 1. 显示函数
```bash
show_success "操作成功"
show_error "操作失败"
show_warning "注意事项"
show_processing "正在处理..."
show_info "信息提示"
show_progress 3 10 "文件名"  # 显示进度: 30% (3/10) - 文件名
```

#### 2. 文件操作
```bash
# 检查文件扩展名
if check_file_extension "$file" "txt"; then
    echo "是文本文件"
fi

# 获取文件信息
basename=$(get_file_basename "$file")    # 获取不含扩展名的文件名
ext=$(get_file_extension "$file")        # 获取小写扩展名

# 验证文件
if validate_input_file "$file"; then
    echo "文件有效"
fi
```

#### 3. 目录操作
```bash
# 安全切换目录
if safe_cd "/target/directory"; then
    echo "切换成功"
fi

# 确保目录存在
ensure_directory "/path/to/create"
```

#### 4. 错误处理
```bash
# 致命错误（会退出程序）
fatal_error "严重错误，程序退出"

# 可恢复错误（记录但继续）
recoverable_error "出现警告，但继续执行"
```

#### 5. 命令执行
```bash
# 检查命令是否存在
if check_command_exists "pandoc"; then
    echo "pandoc 已安装"
fi

# 带重试的命令执行
retry_command some_command arg1 arg2
```

### 完整示例

```bash
#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/common_functions.sh"

# 脚本版本信息
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_AUTHOR="tianli"
readonly SCRIPT_UPDATED="2024-01-01"

show_version() {
    show_version_template  # 使用模板函数
}

main() {
    show_info "开始处理文件"
    
    for file in *.txt; do
        if validate_input_file "$file"; then
            show_processing "处理文件: $(basename "$file")"
            
            if some_operation "$file"; then
                show_success "处理完成: $(basename "$file")"
            else
                show_error "处理失败: $(basename "$file")"
            fi
        fi
    done
}

main "$@"
```

## Python脚本 (common_utils.py)

### 引入方式

```python
from common_utils import (
    show_success, show_error, show_warning, show_info,
    validate_input_file, check_file_extension,
    ProgressTracker, fatal_error
)
```

### 主要功能

#### 1. 显示函数
```python
show_success("操作成功")
show_error("操作失败")
show_warning("注意事项")
show_processing("正在处理...")
show_info("信息提示")
show_progress(3, 10, "文件名")  # 显示进度: 30% (3/10) - 文件名
```

#### 2. 文件操作
```python
from pathlib import Path

# 检查文件扩展名
if check_file_extension(file_path, 'txt'):
    print("是文本文件")

# 获取文件信息
basename = get_file_basename(file_path)    # 获取不含扩展名的文件名
ext = get_file_extension(file_path)        # 获取小写扩展名

# 验证文件
if validate_input_file(file_path):
    print("文件有效")

# 查找文件
txt_files = find_files_by_extension(Path('.'), 'txt', recursive=True)
```

#### 3. 进度跟踪
```python
tracker = ProgressTracker()

for file in files:
    if process_file(file):
        tracker.add_success()
    else:
        tracker.add_failure()

tracker.show_summary("文件处理")  # 显示统计信息
```

#### 4. 错误处理
```python
# 致命错误（会退出程序）
fatal_error("严重错误，程序退出")

# 可恢复错误（记录但继续）
if not recoverable_error("出现警告，但继续执行"):
    # 处理错误情况
    pass
```

#### 5. 编码处理
```python
# 自动检测编码
encoding = detect_file_encoding(file_path)

# 智能读取文件
content = read_file_with_encoding(file_path)
```

### 完整示例

```python
#!/usr/bin/env python3
"""
示例脚本 - 使用通用工具模块
"""

import sys
from pathlib import Path
from common_utils import (
    show_success, show_error, show_info, show_processing,
    validate_input_file, find_files_by_extension,
    ProgressTracker, check_python_packages,
    show_version_info
)

# 脚本信息
SCRIPT_VERSION = "2.0.0"
SCRIPT_AUTHOR = "tianli"
SCRIPT_UPDATED = "2024-01-01"

def check_dependencies():
    """检查依赖"""
    show_info("检查依赖项...")
    return check_python_packages(['pandas', 'openpyxl'])

def process_files(directory: Path):
    """处理文件"""
    show_info(f"处理目录: {directory}")
    
    files = find_files_by_extension(directory, 'txt')
    if not files:
        show_warning("未找到文本文件")
        return
    
    tracker = ProgressTracker()
    
    for i, file in enumerate(files, 1):
        show_processing(f"处理 ({i}/{len(files)}): {file.name}")
        
        if validate_input_file(file):
            # 执行处理逻辑
            if process_single_file(file):
                tracker.add_success()
            else:
                tracker.add_failure()
        else:
            tracker.add_skip()
    
    tracker.show_summary("文件处理")

def main():
    """主函数"""
    if not check_dependencies():
        sys.exit(1)
    
    try:
        process_files(Path.cwd())
        show_success("所有操作完成")
    except KeyboardInterrupt:
        show_warning("用户中断操作")
        sys.exit(1)
    except Exception as e:
        show_error(f"程序执行失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## 迁移指南

### 从旧版本迁移

1. **Shell脚本迁移**
   - 移除 Raycast 相关函数调用
   - 使用新的 `show_progress` 函数替代旧的进度显示
   - 使用模板函数简化版本和帮助信息

2. **Python脚本迁移**
   - 替换直接的 print 语句为统一的显示函数
   - 使用 `ProgressTracker` 类统一进度跟踪
   - 使用 `validate_input_file` 替代手动文件检查

### 最佳实践

1. **统一错误处理**
   ```bash
   # Shell
   validate_input_file "$file" || return 1
   
   # Python
   if not validate_input_file(file_path):
       return False
   ```

2. **统一进度显示**
   ```bash
   # Shell
   show_progress "$current" "$total" "$(basename "$file")"
   
   # Python
   show_progress(current, total, file.name)
   ```

3. **统一依赖检查**
   ```bash
   # Shell
   check_command_exists "pandoc" || exit 1
   
   # Python
   if not check_python_packages(['pandas']):
       sys.exit(1)
   ```

## 注意事项

1. **路径处理**: 所有路径都应该使用相对路径或安全的绝对路径
2. **编码处理**: Python脚本应该使用 `detect_file_encoding` 自动检测文件编码
3. **错误处理**: 区分致命错误和可恢复错误，合理使用相应的函数
4. **依赖检查**: 所有脚本都应该在开始时检查必要的依赖
5. **版本信息**: 所有脚本都应该提供版本信息和帮助文档

## 支持的功能

### Shell脚本支持
- ✅ 文件验证和安全检查
- ✅ 统一的消息显示
- ✅ 目录操作
- ✅ 命令存在性检查
- ✅ 重试机制
- ✅ Python环境检查

### Python脚本支持
- ✅ 文件验证和安全检查
- ✅ 统一的消息显示
- ✅ 进度跟踪
- ✅ 编码自动检测
- ✅ 文件查找和筛选
- ✅ 依赖包检查
- ✅ 错误处理机制 