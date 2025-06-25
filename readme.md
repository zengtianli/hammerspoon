# Hammerspoon 配置项目
一个功能丰富、安全可靠的 Hammerspoon 配置系统，采用模块化设计，支持热重载和错误恢复。
## 🎯 核心特性
- ✅ **安全加载机制** - 单个模块出错不影响整体功能
- 🔄 **热重载支持** - 修改文件后自动安全重载
- 🛡️ **错误隔离** - 模块间互不影响，出错自动恢复备份
- 🎮 **丰富的功能** - 音乐控制、应用管理、按键检测等
- ⚡ **快捷键优化** - 统一的热键管理和冲突避免
## 📁 项目结构
```
.hammerspoon/
├── init.lua                      # 主配置文件
├── lua/                          # 模块目录
│   ├── common_functions.lua      # 通用函数库 🛠️
│   ├── safe_loader.lua           # 安全加载器 🛡️
│   ├── music_controls.lua        # 音乐控制器 🎵
│   ├── util_app_restart.lua      # 应用重启工具 🔄
│   ├── util_wechat.lua           # 微信工具 💬
│   ├── util_mouse_follow.lua     # 鼠标跟随工具 🖱️
│   └── util_position_recorder.lua # 位置记录工具 📍
├── ROBUST_LOADING_GUIDE.md       # 安全加载使用指南
└── test_config.lua               # 配置测试脚本
```
## 🚀 模块功能详解
### 📜 `init.lua` - 主配置文件
项目的入口文件，负责：
- 加载通用函数库和安全加载器
- 使用安全机制加载所有模块
- 提供紧急恢复和状态查看功能
- 设置全局热键绑定
### 🛠️ `common_functions.lua` - 通用函数库
提供项目中所有模块共用的功能：
**消息显示模块：**
- `showSuccess()` - 显示成功消息
- `showError()` - 显示错误消息  
- `showWarning()` - 显示警告消息
- `showInfo()` - 显示信息消息
**文件操作模块：**
- `fileExists()` - 检查文件是否存在
- `directoryExists()` - 检查目录是否存在
- `loadConfigFile()` - 加载配置文件
**应用管理模块：**
- `launchApplication()` - 安全启动应用
- `checkApplication()` - 检查应用状态
**热键管理模块：**
- `createSafeHotkey()` - 创建安全热键
- `createHotkeyGroup()` - 创建热键组
**实用工具模块：**
- `deepCopy()` - 深度复制表
- `mergeTable()` - 合并表
- `safeExecute()` - 安全执行命令
### 🛡️ `safe_loader.lua` - 安全加载器
项目的核心安全机制：
**核心功能：**
- 模块安全加载，出错时自动恢复备份
- 文件变化监控，支持热重载
- 模块状态管理和错误跟踪
- 批量模块加载和管理
**紧急功能：**
- `Cmd+Ctrl+Shift+Alt+R` - 紧急恢复所有模块
- `Cmd+Ctrl+Shift+Alt+S` - 查看模块状态
- `Cmd+Ctrl+Shift+Alt+L` - 重新加载所有模块
### 🎵 `music_controls.lua` - 音乐控制器
统一的音乐播放控制系统：
**播放控制：**
- `Cmd+Ctrl+Shift+;` - 播放/暂停
- `Cmd+Ctrl+Shift+'` - 下一首
- `Cmd+Ctrl+Shift+[` - 上一首
- `Cmd+Ctrl+Shift+P` - 系统播放控制
**高级功能：**
- `Cmd+Ctrl+Shift+L` - AirPods 噪音控制切换
- 支持 Apple Music 应用控制
- 需要外部 AppleScript 支持
### 🔄 `util_app_restart.lua` - 应用重启工具
快速重启应用的实用工具：
**主要功能：**
- `Cmd+Shift+Q` - 重启当前前台应用
- 支持优雅关闭和强制重启
- 自动延迟重启，确保应用完全关闭
**使用场景：**
- 应用卡死需要重启
- 开发时快速重启测试应用
- 清理应用状态
### 💬 `util_wechat.lua` - 微信工具
微信快速启动和自动化工具：
**主要功能：**
- `Ctrl+Alt+W` - 快速启动微信
- 自动发送回车键确认
- 检查微信运行状态
**应用场景：**
- 快速启动微信应用
- 自动处理启动确认对话框
### 🖱️ `util_mouse_follow.lua` - 鼠标跟随工具
窗口焦点自动鼠标跟随功能：
**主要功能：**
- `Cmd+Ctrl+F` - 切换鼠标跟随功能
- 当窗口获得焦点时，自动将鼠标移到窗口中心
- 提高多窗口操作效率
**注意：** 此模块尚未升级到 2.0 标准。
### 📍 `util_position_recorder.lua` - 位置记录工具
强大的鼠标位置记录和回放系统：
**位置记录：**
- `Cmd+Ctrl+Shift+R` - 记录当前鼠标位置
- `Cmd+Ctrl+Shift+C` - 清除当前应用的记录位置
- 按应用分别保存位置信息
**位置导航：**
- `Cmd+Ctrl+Shift+1/2/3` - 移动到指定位置
- `Alt+Tab` - 移动到下一个记录位置
- `Alt+Shift+Tab` - 移动到上一个记录位置
**批量操作：**
- `Cmd+Ctrl+Shift+V` - 依次访问所有位置（不返回原位置）
- `Cmd+Ctrl+Shift+B` - 依次访问所有位置（返回原位置）
**高级功能：**
- `Cmd+Ctrl+Shift+U` - 更新当前活动位置
- `Cmd+Ctrl+Shift+Alt+C` - 切换点击功能
- `Cmd+Ctrl+Shift+Alt+R` - 切换位置记录功能
**注意：** 此模块尚未升级到 2.0 标准。
## 🎮 快捷键总览
### 系统级热键
| 热键 | 功能 | 模块 |
|------|------|------|
| `Cmd+Ctrl+Shift+Alt+R` | 紧急恢复 | safe_loader |
| `Cmd+Ctrl+Shift+Alt+S` | 查看状态 | safe_loader |
| `Cmd+Ctrl+Shift+Alt+L` | 重新加载 | safe_loader |
### 音乐控制
| 热键 | 功能 | 模块 |
|------|------|------|
| `Cmd+Ctrl+Shift+;` | 播放/暂停 | music_controls |
| `Cmd+Ctrl+Shift+'` | 下一首 | music_controls |
| `Cmd+Ctrl+Shift+[` | 上一首 | music_controls |
| `Cmd+Ctrl+Shift+P` | 系统播放控制 | music_controls |
| `Cmd+Ctrl+Shift+L` | AirPods噪音控制 | music_controls |
### 应用管理
| 热键 | 功能 | 模块 |
|------|------|------|
| `Cmd+Shift+Q` | 重启前台应用 | util_app_restart |
| `Ctrl+Alt+W` | 启动微信 | util_wechat |
### 位置记录
| 热键 | 功能 | 模块 |
|------|------|------|
| `Cmd+Ctrl+Shift+R` | 记录位置 | util_position_recorder |
| `Cmd+Ctrl+Shift+1/2/3` | 移动到位置 | util_position_recorder |
| `Alt+Tab` | 下一个位置 | util_position_recorder |
| `Cmd+Ctrl+Shift+V` | 批量访问位置 | util_position_recorder |
## 🔧 安装和配置
### 1. 基本安装
```bash
# 备份现有配置（如果有）
mv ~/.hammerspoon ~/.hammerspoon.backup
# 克隆或复制配置到 Hammerspoon 目录
cp -r this_config ~/.hammerspoon
# 重载 Hammerspoon 配置
# 在 Hammerspoon 控制台执行: hs.reload()
```
### 2. 依赖检查
项目会自动检查依赖，如果缺少某些功能：
**对于音乐控制模块：**
```bash
# 需要在 ~/useful_scripts/ 目录下放置：
# - music.applescript (音乐控制脚本)
# - airpods.scpt (AirPods 控制脚本)
```
### 3. 配置调整
每个模块都有配置选项，可以在模块文件顶部的 `config` 部分调整：
```lua
M.config = {
    enabled = true,    -- 是否启用模块
    debug = false,     -- 是否显示调试信息
    -- 其他模块特定配置...
}
```
## 🛡️ 安全特性
### 错误隔离
- 单个模块出错不会影响其他模块
- 自动备份机制，出错时恢复到上一可用状态
- 详细的错误日志和状态监控
### 热重载
- 文件修改后自动安全重载
- 只重载修改的模块，其他功能保持运行
- 加载失败时自动回滚
### 紧急恢复
- 多重紧急恢复机制
- 全局热键随时可用
- 控制台命令备用方案
## 🔍 故障排除
### 常见问题
**1. 模块加载失败**
```bash
# 查看模块状态
按 Cmd+Ctrl+Shift+Alt+S
# 或在 Hammerspoon 控制台执行
showModuleStatus()
```
**2. 热键不响应**
- 检查是否有热键冲突
- 确认模块已正确加载
- 查看 Hammerspoon 控制台错误信息
**3. 功能部分失效**
```bash
# 紧急恢复
按 Cmd+Ctrl+Shift+Alt+R
# 重新加载所有模块
按 Cmd+Ctrl+Shift+Alt+L
```
### 调试模式
在任何模块中启用调试模式：
```lua
M.config.debug = true
```
## 📈 版本信息
- **项目版本**: 2.0.0
- **最后更新**: 2024-12-24
- **兼容性**: Hammerspoon 0.9.x+
## 🎉 特色亮点
1. **开发友好** - 编辑脚本时不会失去所有功能
2. **功能丰富** - 涵盖音乐、应用、输入等多个方面
3. **高度安全** - 多重保护机制，确保稳定运行
4. **易于扩展** - 模块化设计，方便添加新功能
5. **统一管理** - 通用函数库提供一致的体验
这个配置系统让 Hammerspoon 使用更加安全、高效和愉快！🚀 
