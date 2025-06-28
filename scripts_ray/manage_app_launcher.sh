#!/bin/bash
# 应用启动管理器
# 功能：根据essential_apps.txt中的应用列表，启动未运行的应用

# 文件路径
ESSENTIAL_APPS="$HOME/Desktop/essential_apps.txt"
RUNNING_APPS="$HOME/Desktop/running_apps.txt"

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# 函数：显示消息
show_info() {
    echo "ℹ️ $1"
}

show_success() {
    echo "✅ $1"
}

show_error() {
    echo "❌ $1"
}

show_warning() {
    echo "⚠️ $1"
}

# 函数：获取当前运行的应用程序列表
get_running_apps() {
    show_info "正在获取当前运行的应用程序列表..."
    
    # 清空运行应用列表文件
    > "$RUNNING_APPS"
    
    # 使用 ps 命令获取当前运行的应用程序
    ps -eo comm | grep -E '\.app/' | sed 's|.*/\([^/]*\.app\)/.*|\1|' | sort | uniq > "$RUNNING_APPS"
    
    # 如果 ps 方法没有找到足够的应用，尝试使用 osascript
    local running_count=$(wc -l < "$RUNNING_APPS" | tr -d ' ')
    if [ "$running_count" -lt 5 ]; then
        show_info "尝试使用 AppleScript 获取运行应用..."
        
        # 使用 osascript 获取可见的应用程序
        osascript -e '
        tell application "System Events"
            set runningApps to name of every application process whose background only is false
        end tell
        return runningApps
        ' 2>/dev/null | tr ',' '\n' | sed 's/^ *//;s/ *$//' | while read -r app_name; do
            if [ -n "$app_name" ]; then
                # 确保应用名称以 .app 结尾
                if [[ "$app_name" != *.app ]]; then
                    echo "$app_name.app" >> "$RUNNING_APPS"
                else
                    echo "$app_name" >> "$RUNNING_APPS"
                fi
            fi
        done
        
        # 去重并排序
        sort "$RUNNING_APPS" | uniq > "${RUNNING_APPS}.tmp" && mv "${RUNNING_APPS}.tmp" "$RUNNING_APPS"
    fi
    
    running_count=$(wc -l < "$RUNNING_APPS" | tr -d ' ')
    show_success "已更新运行应用列表: $RUNNING_APPS (找到 $running_count 个运行应用)"
}

# 函数：检查必需文件是否存在
check_required_files() {
    if [ ! -f "$ESSENTIAL_APPS" ]; then
        show_error "必需应用列表文件不存在: $ESSENTIAL_APPS"
        show_info "请创建该文件并添加需要启动的应用名称（每行一个，格式如：App.app）"
        exit 1
    fi
    
    # 如果 RUNNING_APPS 不存在，创建空文件
    if [ ! -f "$RUNNING_APPS" ]; then
        show_warning "运行应用列表文件不存在，将创建: $RUNNING_APPS"
        touch "$RUNNING_APPS"
    fi
}

# 函数：清理应用名称（提取 .app 名称）
clean_app_name() {
    local app_line="$1"
    # 移除版本号信息，只保留应用名称
    echo "$app_line" | sed 's/ ([^)]*)$//' | sed 's/\.app$/.app/'
}

# 函数：检查应用是否正在运行
is_app_running() {
    local app_name="$1"
    local clean_name=$(clean_app_name "$app_name")
    
    # 在 RUNNING_APPS 文件中查找
    if grep -q "^$clean_name" "$RUNNING_APPS"; then
        return 0  # 应用正在运行
    else
        return 1  # 应用未运行
    fi
}

# 函数：启动应用程序
launch_app() {
    local app_name="$1"
    local clean_name=$(clean_app_name "$app_name")
    
    show_info "正在启动: $clean_name"
    
    # 尝试不同的路径启动应用
    local launched=false
    
    # 1. 尝试 /Applications
    if [ -d "/Applications/$clean_name" ]; then
        if open "/Applications/$clean_name"; then
            launched=true
        fi
    # 2. 尝试用户应用目录
    elif [ -d "$HOME/Applications/$clean_name" ]; then
        if open "$HOME/Applications/$clean_name"; then
            launched=true
        fi
    # 3. 尝试系统应用目录
    elif [ -d "/System/Applications/$clean_name" ]; then
        if open "/System/Applications/$clean_name"; then
            launched=true
        fi
    # 4. 尝试直接用应用名称启动（去掉.app后缀）
    else
        local app_name_only=$(echo "$clean_name" | sed 's/\.app$//')
        if open -a "$app_name_only" 2>/dev/null; then
            launched=true
        fi
    fi
    
    if [ "$launched" = true ]; then
        show_success "成功启动: $clean_name"
        # 等待应用启动
        sleep 2
        return 0
    else
        show_error "无法启动应用: $clean_name"
        return 1
    fi
}

# 函数：更新运行应用列表
update_running_apps() {
    show_info "更新运行应用列表..."
    get_running_apps
}

# 主程序
main() {
    show_info "=== 应用启动管理器 ==="
    
    # 1. 检查必需文件
    check_required_files
    
    # 2. 获取当前运行的应用列表
    get_running_apps
    
    # 3. 读取必需应用列表
    if [ ! -s "$ESSENTIAL_APPS" ]; then
        show_warning "必需应用列表为空: $ESSENTIAL_APPS"
        exit 0
    fi
    
    show_info "读取必需应用列表: $ESSENTIAL_APPS"
    
    # 4. 检查并启动缺失的应用
    local apps_to_launch=()
    local apps_already_running=()
    
    while IFS= read -r app_line; do
        # 跳过空行、注释行、标题行和分隔符行
        [[ -z "$app_line" || "$app_line" =~ ^[[:space:]]*# ]] && continue
        [[ "$app_line" =~ ^[[:space:]]*== ]] && continue
        [[ "$app_line" =~ ^[[:space:]]*-+ ]] && continue
        
        local clean_name=$(clean_app_name "$app_line")
        
        if is_app_running "$clean_name"; then
            apps_already_running+=("$clean_name")
        else
            apps_to_launch+=("$clean_name")
        fi
    done < "$ESSENTIAL_APPS"
    
    # 5. 显示已运行的应用
    if [ ${#apps_already_running[@]} -gt 0 ]; then
        show_info "以下应用已在运行："
        for app in "${apps_already_running[@]}"; do
            echo "  ✓ $app"
        done
    fi
    
    # 6. 启动缺失的应用
    if [ ${#apps_to_launch[@]} -gt 0 ]; then
        show_info "需要启动 ${#apps_to_launch[@]} 个应用："
        
        for app in "${apps_to_launch[@]}"; do
            launch_app "$app"
        done
        
        # 7. 更新运行应用列表
        show_info "等待应用完全启动..."
        sleep 3
        update_running_apps
        
        show_success "应用启动完成！"
    else
        show_success "所有必需的应用都已在运行！"
    fi
    
    show_info "=== 完成 ==="
}

# 运行主程序
main "$@"