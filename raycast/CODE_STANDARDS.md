# Shell 脚本代码规范文档 v2.0

## 目标
统一所有 Raycast 脚本的代码风格和实现方式，提高代码的可维护性、可读性、安全性和一致性。

## 核心原则
1. **DRY (Don't Repeat Yourself)**: 相同功能使用统一的实现
2. **一致性**: 相同场景使用相同的代码模式
3. **健壮性**: 所有操作都需要错误处理和重试机制
4. **可读性**: 代码结构清晰，注释完整
5. **安全性**: 验证输入，防止路径注入
6. **性能**: 考虑大文件和批量操作的性能影响

## 1. 必须引入的通用函数库

在每个脚本开头，必须引入以下通用函数库：

```bash
#!/bin/bash

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"
```

### 通用函数库内容 (common_functions.sh)

```bash
#!/bin/bash

# ===== 常量定义 =====
readonly PYTHON_PATH="/Users/tianli/miniforge3/bin/python3"
readonly MINIFORGE_BIN="/Users/tianli/miniforge3/bin"
readonly SCRIPTS_DIR="/Users/tianli/useful_scripts"

# ===== 通用函数 =====

# 获取 Finder 中选中的单个文件/文件夹
# 返回: 文件路径或空字符串
get_finder_selection_single() {
    osascript <<'EOF'
tell application "Finder"
    if (count of (selection as list)) > 0 then
        POSIX path of (item 1 of (selection as list) as alias)
    else
        ""
    end if
end tell
EOF
}

# 获取 Finder 中选中的多个文件/文件夹
# 返回: 逗号分隔的路径列表
get_finder_selection_multiple() {
    osascript <<'EOF'
tell application "Finder"
    set selectedItems to selection as list
    set posixPaths to {}
    
    if (count of selectedItems) > 0 then
        repeat with i from 1 to count of selectedItems
            set thisItem to item i of selectedItems
            set end of posixPaths to POSIX path of (thisItem as alias)
        end repeat
        
        set AppleScript's text item delimiters to ","
        set pathsText to posixPaths as text
        set AppleScript's text item delimiters to ""
        return pathsText
    else
        return ""
    end if
end tell
EOF
}

# 获取当前 Finder 目录或选中项目的目录
get_finder_current_dir() {
    osascript <<'EOF'
tell application "Finder"
    if (count of (selection as list)) > 0 then
        set firstItem to item 1 of (selection as list)
        if class of firstItem is folder then
            POSIX path of (firstItem as alias)
        else
            POSIX path of (container of firstItem as alias)
        end if
    else
        POSIX path of (insertion location as alias)
    end if
end tell
EOF
}

# 检查文件扩展名
# 参数: $1 = 文件路径, $2 = 期望的扩展名（不带点）
# 返回: 0 = 匹配, 1 = 不匹配
check_file_extension() {
    local file="$1"
    local expected_ext="$2"
    local actual_ext="${file##*.}"
    
    [[ "$(echo "$actual_ext" | tr '[:upper:]' '[:lower:]')" == "$(echo "$expected_ext" | tr '[:upper:]' '[:lower:]')" ]]
}

# 在 Ghostty 中执行命令
# 参数: $1 = 要执行的命令
run_in_ghostty() {
    local command="$1"
    local command_escaped=$(printf "%s" "$command" | sed 's/"/\\"/g')
    
    osascript <<EOF
tell application "Ghostty"
    activate
    tell application "System Events"
        keystroke "n" using command down
    end tell
end tell
EOF
    
    sleep 1
    
    osascript <<EOF
tell application "Ghostty"
    activate
    delay 0.2
    set the clipboard to "$command_escaped"
    tell application "System Events"
        keystroke "v" using command down
        delay 0.1
        key code 36
    end tell
end tell
EOF
}

# 显示成功消息
# 参数: $1 = 消息内容
show_success() {
    echo "✅ $1"
}

# 显示错误消息
# 参数: $1 = 消息内容
show_error() {
    echo "❌ $1"
}

# 显示警告消息
# 参数: $1 = 消息内容
show_warning() {
    echo "⚠️ $1"
}

# 显示处理中消息
# 参数: $1 = 消息内容
show_processing() {
    echo "🔄 $1"
}

# 安全切换目录
# 参数: $1 = 目标目录
# 返回: 0 = 成功, 1 = 失败
safe_cd() {
    local target_dir="$1"
    if cd "$target_dir" 2>/dev/null; then
        return 0
    else
        show_error "无法进入目录: $target_dir"
        return 1
    fi
}

# 检查命令是否存在
# 参数: $1 = 命令名称
check_command_exists() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        show_error "$cmd 未安装"
        return 1
    fi
    return 0
}

# 验证文件路径安全性
# 参数: $1 = 文件路径
# 返回: 0 = 安全, 1 = 不安全
validate_file_path() {
    local path="$1"
    # 检查路径是否包含恶意字符
    if [[ "$path" =~ \.\./|\||\; ]]; then
        show_error "不安全的文件路径: $path"
        return 1
    fi
    return 0
}

# 检查文件大小
# 参数: $1 = 文件路径, $2 = 最大大小(MB,可选,默认100)
# 返回: 0 = 文件大小正常, 1 = 文件过大
check_file_size() {
    local file="$1"
    local max_size_mb=${2:-100}
    local size_mb=$(du -m "$file" 2>/dev/null | cut -f1)
    
    if [ -z "$size_mb" ]; then
        show_error "无法获取文件大小: $file"
        return 1
    fi
    
    if [ $size_mb -gt $max_size_mb ]; then
        show_warning "文件较大 (${size_mb}MB)，处理可能需要较长时间"
        return 1
    fi
    return 0
}

# 带重试机制的命令执行
# 参数: $@ = 要执行的命令
# 返回: 命令执行结果
retry_command() {
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if "$@"; then
            return 0
        fi
        show_warning "第 $attempt 次尝试失败，正在重试..."
        ((attempt++))
        sleep 1
    done
    
    show_error "命令执行失败，已重试 $max_attempts 次"
    return 1
}

# 运行AppleScript
# 参数: $1 = AppleScript代码
run_applescript() {
    local script="$1"
    osascript <<EOF
$script
EOF
}
```

## 2. Raycast 参数头部规范

### 2.1 标准头部模板

```bash
#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title 脚本标题
# @raycast.mode silent|compact|fullOutput
# @raycast.icon 📄
# @raycast.packageName Custom
# @raycast.description 脚本功能的详细描述
```

### 2.2 模式选择指南

- **silent**: 简单操作，无需显示输出，只显示通知
- **compact**: 需要显示简短结果或状态信息
- **fullOutput**: 需要显示详细输出、日志或错误信息

### 2.3 图标选择建议

```bash
📄 # 文档/PDF相关
📊 # Excel/数据相关
📁 # 文件夹/目录操作
🔄 # 转换/处理操作
🚀 # 运行/执行脚本
🪟 # 窗口管理
👻 # 终端/命令行
📋 # 复制/剪贴板
🔍 # 搜索/查找
⚙️  # 配置/设置
```

## 3. 标准代码模式

### 3.1 单文件处理模式

```bash
#!/bin/bash
# Raycast parameters...

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILE=$(get_finder_selection_single)
if [ -z "$SELECTED_FILE" ]; then
    show_error "没有在 Finder 中选择任何文件"
    exit 1
fi

# 验证文件路径安全性
validate_file_path "$SELECTED_FILE" || exit 1

# 检查文件类型
if ! check_file_extension "$SELECTED_FILE" "pdf"; then
    show_error "选中的不是 PDF 文件"
    exit 1
fi

# 检查文件大小（可选）
check_file_size "$SELECTED_FILE" 50 || {
    show_warning "文件较大，是否继续？"
    # 这里可以添加用户确认逻辑
}

# 获取文件目录并切换
FILE_DIR=$(dirname "$SELECTED_FILE")
safe_cd "$FILE_DIR" || exit 1

# 显示处理信息
show_processing "正在处理 $(basename "$SELECTED_FILE")..."

# 执行主要操作
if retry_command "$PYTHON_PATH" "$SCRIPTS_DIR/execute/script.py" "$SELECTED_FILE"; then
    show_success "处理完成: $(basename "$SELECTED_FILE")"
else
    show_error "处理失败"
    exit 1
fi
```

### 3.2 批量处理模式

```bash
#!/bin/bash
# Raycast parameters...

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILES=$(get_finder_selection_multiple)
if [ -z "$SELECTED_FILES" ]; then
    show_error "没有在 Finder 中选择任何文件"
    exit 1
fi

# 转换为数组
IFS=',' read -ra FILE_ARRAY <<< "$SELECTED_FILES"

# 计数器初始化
SUCCESS_COUNT=0
SKIPPED_COUNT=0
TOTAL_COUNT=${#FILE_ARRAY[@]}

# 处理每个文件
for FILE_PATH in "${FILE_ARRAY[@]}"; do
    # 跳过空条目
    if [ -z "$FILE_PATH" ]; then
        continue
    fi
    
    # 验证文件路径
    if ! validate_file_path "$FILE_PATH"; then
        ((SKIPPED_COUNT++))
        continue
    fi
    
    # 检查文件类型
    if ! check_file_extension "$FILE_PATH" "txt"; then
        show_warning "跳过: $(basename "$FILE_PATH") - 不是 TXT 文件"
        ((SKIPPED_COUNT++))
        continue
    fi
    
    # 处理单个文件
    show_processing "正在处理 $(basename "$FILE_PATH") ($((SUCCESS_COUNT + SKIPPED_COUNT + 1))/$TOTAL_COUNT)"
    
    if process_single_file "$FILE_PATH"; then
        ((SUCCESS_COUNT++))
    else
        ((SKIPPED_COUNT++))
    fi
done

# 显示处理统计
if [ $TOTAL_COUNT -eq 0 ]; then
    show_error "没有找到有效文件"
elif [ $SUCCESS_COUNT -eq 0 ]; then
    show_warning "没有文件被成功处理"
elif [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    show_success "已成功处理所有 $SUCCESS_COUNT 个文件"
else
    show_warning "已处理 $SUCCESS_COUNT/$TOTAL_COUNT 个文件，跳过 $SKIPPED_COUNT 个"
fi
```

### 3.3 应用程序启动模式

```bash
#!/bin/bash
# Raycast parameters...

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取当前目录
CURRENT_DIR=$(get_finder_current_dir)

# 验证目录
if [ ! -d "$CURRENT_DIR" ]; then
    show_error "无效的目录: $CURRENT_DIR"
    exit 1
fi

# 切换到目录
safe_cd "$CURRENT_DIR" || exit 1

# 启动应用程序
show_processing "正在启动应用程序..."
if open -a "Application Name" .; then
    show_success "应用程序已在 $(basename "$CURRENT_DIR") 中启动"
else
    show_error "启动应用程序失败"
    exit 1
fi
```

## 4. 临时文件管理规范

### 4.1 创建和清理临时文件

```bash
# 创建临时目录
TEMP_DIR=$(mktemp -d)

# 设置清理陷阱
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# 创建临时文件
TEMP_FILE=$(mktemp "$TEMP_DIR/prefix.XXXXXX")
```

### 4.2 日志文件管理

```bash
# 为并行执行创建日志系统
create_log_system() {
    local temp_dir="$1"
    local file="$2"
    local base_name=$(basename "$file")
    
    echo "$temp_dir/${base_name}.log"
}

# 使用示例
LOG_FILE=$(create_log_system "$TEMP_DIR" "$FILE_PATH")
echo "Processing: $FILE_PATH" > "$LOG_FILE"
```

## 5. 错误处理和用户体验

### 5.1 错误级别定义

```bash
# 致命错误 - 立即退出
fatal_error() {
    show_error "$1"
    exit 1
}

# 可恢复错误 - 记录但继续
recoverable_error() {
    show_warning "$1"
    return 1
}

# 信息提示
info_message() {
    echo "ℹ️ $1"
}
```

### 5.2 进度显示

```bash
# 简单进度显示
show_progress() {
    local current="$1"
    local total="$2"
    local item="$3"
    show_processing "处理中 ($current/$total): $item"
}

# 百分比进度
show_percentage() {
    local current="$1"
    local total="$2"
    local percentage=$((current * 100 / total))
    echo "📊 进度: $percentage% ($current/$total)"
}
```

## 6. 子目录脚本组织规范

### 6.1 目录结构

```
raycast/
├── common_functions.sh
├── README.md
├── trf/                    # 文件格式转换
│   ├── ray_trf_*.sh
│   └── README.md
├── yabai/                  # 窗口管理
│   ├── ray_yabai_*.sh
│   └── README.md
└── [其他功能脚本]
```

### 6.2 命名规范

```bash
# 主目录脚本
ray_[功能]_[具体操作].sh

# 子目录脚本
ray_[子目录名]_[具体功能].sh

# 示例:
ray_ap_cursor.sh           # 应用程序启动
ray_trf_pdf2md.sh         # 文件转换
ray_yabai_toggle.sh       # 窗口管理
```

### 6.3 子目录README模板

```markdown
# [功能模块名] 工具集

## 功能概览
- 工具1: 描述
- 工具2: 描述

## 依赖要求
- 列出特定依赖

## 使用说明
详细的使用方法

## 故障排除
常见问题和解决方案
```

## 7. 性能优化指南

### 7.1 大文件处理

```bash
# 处理大文件前的检查
handle_large_file() {
    local file="$1"
    local max_size=100  # MB
    
    if ! check_file_size "$file" $max_size; then
        show_warning "文件较大，建议在后台处理"
        # 可以选择后台处理或询问用户
        return 1
    fi
    return 0
}
```

### 7.2 并行处理优化

```bash
# 控制并发数量
MAX_CONCURRENT_JOBS=4
CURRENT_JOBS=0

start_background_job() {
    while [ $CURRENT_JOBS -ge $MAX_CONCURRENT_JOBS ]; do
        wait -n  # 等待任一后台任务完成
        ((CURRENT_JOBS--))
    done
    
    "$@" &
    ((CURRENT_JOBS++))
}
```

### 7.3 缓存机制

```bash
# 简单的结果缓存
CACHE_DIR="$HOME/.raycast_cache"
mkdir -p "$CACHE_DIR"

get_cached_result() {
    local key="$1"
    local cache_file="$CACHE_DIR/${key}.cache"
    
    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -f %m "$cache_file"))) -lt 3600 ]; then
        cat "$cache_file"
        return 0
    fi
    return 1
}

set_cached_result() {
    local key="$1"
    local value="$2"
    echo "$value" > "$CACHE_DIR/${key}.cache"
}
```

## 8. 安全考虑

### 8.1 输入验证

```bash
# 文件路径验证
validate_input_file() {
    local file="$1"
    
    # 检查文件是否存在
    if [ ! -f "$file" ]; then
        show_error "文件不存在: $file"
        return 1
    fi
    
    # 检查文件是否可读
    if [ ! -r "$file" ]; then
        show_error "文件不可读: $file"
        return 1
    fi
    
    # 验证路径安全性
    validate_file_path "$file" || return 1
    
    return 0
}
```

### 8.2 权限检查

```bash
# 检查脚本执行权限
check_script_permissions() {
    local script="$1"
    
    if [ ! -x "$script" ]; then
        show_warning "脚本没有执行权限，正在添加..."
        chmod +x "$script" || {
            show_error "无法添加执行权限: $script"
            return 1
        }
    fi
    return 0
}
```

## 9. 测试和调试

### 9.1 调试模式

```bash
# 在脚本开头添加调试选项
DEBUG=${DEBUG:-false}

debug_log() {
    if [ "$DEBUG" = "true" ]; then
        echo "🐛 DEBUG: $1" >&2
    fi
}

# 使用方法: DEBUG=true ray_script.sh
```

### 9.2 函数测试

```bash
# 测试函数模板
test_function() {
    local function_name="$1"
    echo "Testing $function_name..."
    
    # 测试正常情况
    # 测试边界情况
    # 测试错误情况
    
    echo "✅ $function_name tests passed"
}
```

## 10. 版本控制和文档

### 10.1 脚本版本管理

```bash
# 在脚本中添加版本信息
SCRIPT_VERSION="1.0.0"
SCRIPT_AUTHOR="作者名"
SCRIPT_UPDATED="2024-01-01"

show_version() {
    echo "脚本版本: $SCRIPT_VERSION"
    echo "作者: $SCRIPT_AUTHOR"
    echo "更新日期: $SCRIPT_UPDATED"
}
```

### 10.2 变更日志格式

```bash
# 每个脚本应包含简短的变更历史
# 格式: [日期] 版本号 - 变更描述
# [2024-01-01] v1.0.0 - 初始版本
# [2024-01-15] v1.1.0 - 添加批量处理支持
# [2024-02-01] v1.2.0 - 增强错误处理
```

## 11. 检查清单

修改每个脚本时，确保：

### 基础要求
- [ ] 引入了通用函数库
- [ ] Raycast 参数头部完整
- [ ] 使用统一的 Finder 选择函数
- [ ] 使用统一的消息输出函数
- [ ] 使用常量代替硬编码路径

### 安全性
- [ ] 验证所有输入文件路径
- [ ] 检查文件权限和存在性
- [ ] 防止路径注入攻击
- [ ] 处理特殊字符和空格

### 健壮性
- [ ] 适当的错误处理
- [ ] 重试机制（如需要）
- [ ] 临时文件清理
- [ ] 进度反馈和状态显示

### 性能
- [ ] 大文件检查
- [ ] 并发控制（批量处理）
- [ ] 缓存机制（如适用）

### 用户体验
- [ ] 清晰的成功/失败反馈
- [ ] 有意义的错误消息
- [ ] 进度显示（长时间操作）
- [ ] 操作结果统计

### 代码质量
- [ ] 代码风格一致（缩进、空格等）
- [ ] 注释清晰明了
- [ ] 函数职责单一
- [ ] 变量命名规范

## 12. 迁移指南

### 从v1.0升级到v2.0的步骤：

1. **更新common_functions.sh**: 添加新的安全和性能函数
2. **修复路径**: 确保所有路径指向正确位置
3. **添加安全检查**: 为所有文件操作添加验证
4. **增强错误处理**: 使用新的错误处理模式
5. **优化性能**: 添加大文件检查和并发控制
6. **更新文档**: 为每个子目录添加README
7. **测试验证**: 确保所有修改后的脚本正常工作


