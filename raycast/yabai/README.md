# Raycast Yabai 窗口管理工具集

这是一个用于Raycast的Yabai窗口管理工具集，提供了完整的窗口管理和工作空间操作功能。

## 功能概览

### 🪟 窗口操作
- **Yabai Float** (`ray_yabai_float.sh`): 切换当前窗口的浮动/平铺状态
- **Yabai Window Move Previous** (`ray_yabai_win_pr.sh`): 移动窗口到上一个空间
- **Yabai Window Move Next** (`ray_yabai_win_nx.sh`): 移动窗口到下一个空间
- **Yabai Org** (`ray_yabai_org.sh`): 根据预定义规则自动整理窗口

### 🖥️ 空间管理
- **Yabai Create Space** (`ray_yabai_sp_cr.sh`): 创建新的工作空间
- **Yabai Destroy Space** (`ray_yabai_sp_ds.sh`): 销毁当前工作空间

### ⚙️ 服务管理
- **Yabai Toggle** (`ray_yabai_toggle.sh`): 切换Yabai服务的启动/停止状态

## 使用方法

### 基本操作
1. 启动Raycast (⌘ + Space)
2. 输入对应的命令名称
3. 按回车执行操作

### 具体功能说明

#### 窗口操作

**🔄 Yabai Float** 
- **功能**: 在浮动窗口和平铺窗口之间切换
- **使用场景**: 当需要让某个窗口脱离平铺布局独立显示时
- **操作**: 焦点在目标窗口上时执行

**⬅️ Yabai Window Move Previous**
- **功能**: 将当前窗口移动到上一个工作空间
- **快捷操作**: 快速整理窗口到不同空间

**➡️ Yabai Window Move Next**
- **功能**: 将当前窗口移动到下一个工作空间
- **快捷操作**: 快速整理窗口到不同空间

**🗂️ Yabai Org**
- **功能**: 根据预定义规则自动整理所有窗口
- **使用场景**: 
  - 工作空间混乱时一键整理
  - 按应用类型分配到指定显示器
  - 恢复预设的窗口布局
- **依赖**: 需要配置 `org_windows.sh` 规则文件

#### 空间管理

**➕ Yabai Create Space**
- **功能**: 创建一个新的工作空间
- **使用场景**: 需要更多工作区域时

**🗑️ Yabai Destroy Space**
- **功能**: 销毁当前工作空间
- **注意**: 空间中的窗口会被移动到相邻空间

#### 服务管理

**🔄 Yabai Toggle**
- **功能**: 启动或停止Yabai窗口管理服务
- **使用场景**: 
  - 临时禁用窗口管理
  - 重启Yabai服务
  - 调试配置问题

## 依赖要求

### 系统要求
- **macOS**: 支持的版本
- **Yabai**: 已安装并配置的Yabai窗口管理器
- **SIP**: 部分功能可能需要关闭系统完整性保护

### 依赖脚本
工具集依赖以下核心脚本，需确保它们存在于正确位置：

```
execute/yabai/
├── yabai-float.sh          # 窗口浮动切换
├── window_mv_prev.sh       # 窗口移动到上一空间
├── window_mv_next.sh       # 窗口移动到下一空间
├── org_windows.sh          # 窗口整理规则
├── space_create.sh         # 创建空间
├── space_destroy.sh        # 销毁空间
└── toggle-yabai.sh         # Yabai服务切换
```

### 配置文件
确保Yabai配置文件已正确设置：
- `~/.yabairc`: Yabai主配置文件
- 窗口整理规则配置（在org_windows.sh中定义）

## 安装配置

### 1. 安装Yabai
```bash
# 使用Homebrew安装
brew install koekeishiya/formulae/yabai

# 启动Yabai服务
brew services start yabai
```

### 2. 配置Yabai
```bash
# 创建配置文件
touch ~/.yabairc
chmod +x ~/.yabairc

# 编辑配置文件
nano ~/.yabairc
```

### 3. 部署脚本
确保所有依赖脚本文件已放置在正确位置，并具有执行权限：
```bash
chmod +x execute/yabai/*.sh
```

### 4. Raycast配置
将脚本文件添加到Raycast扩展目录，然后在Raycast中刷新扩展列表。

## 使用技巧

### 高效工作流程
1. **晨间设置**: 使用 `Yabai Org` 快速整理工作环境
2. **窗口调度**: 使用 `Window Move Next/Previous` 快速分配窗口
3. **专注模式**: 使用 `Yabai Float` 突出重要窗口
4. **空间管理**: 根据项目创建专用空间

### 最佳实践
- **预设规则**: 在 `org_windows.sh` 中配置常用应用的分配规则
- **快捷键**: 为常用操作设置Raycast快捷键
- **显示器配置**: 多显示器环境下合理分配应用程序

## 故障排除

### 常见问题

**❌ Yabai服务未启动**
```bash
# 检查服务状态
brew services list | grep yabai

# 手动启动
yabai --start-service
```

**❌ 权限问题**
- 检查脚本文件执行权限
- 确认Yabai有必要的系统权限
- 检查macOS安全设置

**❌ 窗口操作无效**
- 确认当前窗口支持Yabai管理
- 检查应用程序是否在排除列表中
- 验证Yabai配置文件语法

**❌ 脚本路径错误**
- 检查 `SCRIPTS_DIR` 路径配置
- 确认依赖脚本文件存在
- 验证文件路径权限

### 调试方法
```bash
# 查看Yabai日志
tail -f /tmp/yabai_$USER.out.log
tail -f /tmp/yabai_$USER.err.log

# 测试Yabai连接
yabai -m query --windows

# 检查空间信息
yabai -m query --spaces
```

## 更新日志

- **v1.0**: 初始版本，包含基础窗口和空间管理功能
- 添加了统一的错误处理和消息显示
- 集成common_functions.sh公共函数库
- 优化了脚本执行效率和用户反馈 