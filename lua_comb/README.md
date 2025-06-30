# Lua_Comb 统一模块

## 简介
这是一个统一的 Hammerspoon 配置模块，整合了原来分散在 `lua/` 和 `lua1/` 文件夹中的所有功能。

## 功能模块

### 🔧 核心模块
- `common_utils.lua` - 统一工具库（合并了原来的 common_functions.lua 和 common_utils.lua）
- `init.lua` - 主初始化文件
- `hotkeys_manager.lua` - 统一快捷键管理

### 🎵 音乐控制 (`music_controls.lua`)
- **⌘⌃⇧+;** - 音乐播放/暂停
- **⌘⌃⇧+'** - 下一首
- **⌘⌃⇧+L** - 上一首
- **⌘⌃⇧+Z** - Zen Browser 媒体控制
- **⌘⌃⇧+P** - 系统媒体播放/暂停

### 🎬 宏系统
- `macro_player.lua` - 高性能宏播放引擎（50ms间隔，响应快）
- `macro_controls.lua` - 宏控制和配置管理
- `macro_hotkeys.lua` - 宏快捷键绑定
- **⌘⌃⇧+1/2/3/4/5** - 播放对应编号的宏

### 📱 应用控制 (`app_controls.lua`)
- **⌘⌃⇧+T** - Ghostty在此处打开
- **⌘⌃⇧+W** - Cursor在此处打开
- **⌘⌃⇧+V** - Nvim在Ghostty中打开文件
- **⌘⇧+N** - 创建新文件夹

### 📋 剪贴板工具
- `clipboard_utils.lua` - 剪贴板操作功能
- `clipboard_hotkeys.lua` - 剪贴板快捷键
- **⌘⌃⇧+N** - 复制文件名
- **⌘⌃⇧+C** - 复制文件名和内容
- **⌃⌥+V** - 粘贴到Finder

### 🏃 脚本运行器 (`script_runner.lua`)
- **⌘⌃⇧+S** - 运行选中脚本
- **⌘⌃⇧+R** - 并行运行脚本

### 📱 其他功能
- `app_restart.lua` - **⌘⇧+Q** 重启当前应用
- `wechat_launcher.lua` - **⌃⌥+W** 启动微信
- `system_shortcuts.lua` - **⌘⌥+,** 打开系统设置

### 📚 帮助
- **⌘⌃⌥⇧+H** - 显示快捷键帮助

## 架构特点

### 统一设计
- 所有模块使用统一的 `common_utils.lua` 工具库
- 标准化的模块接口和错误处理
- 统一的快捷键注册和管理

### 高性能宏系统
- 纯 Lua 实现，移除了shell脚本调用开销
- 50ms点击间隔，响应时间 < 100ms
- 支持同步和异步播放模式

### 模块化设计
- 每个功能独立模块，便于维护和调试
- 延迟加载机制避免循环依赖
- 配置驱动的快捷键系统

### 完全替代
- 替代了原来的 `lua/` 和 `lua1/` 文件夹
- 移除了不需要的文件转换功能
- 保留了所有核心功能

## 使用说明

1. 确保 Hammerspoon 正在运行
2. 主 `init.lua` 已经配置为加载 `lua_comb.init`
3. 重新加载 Hammerspoon 配置即可使用所有功能
4. 按 **⌘⌃⌥⇧+H** 查看完整快捷键列表

## 文件依赖关系

```
init.lua (主入口)
├── common_utils.lua (工具库)
├── music_controls.lua
├── app_restart.lua  
├── wechat_launcher.lua
├── system_shortcuts.lua
├── macro_player.lua
├── macro_controls.lua → macro_player.lua
├── macro_hotkeys.lua → macro_controls.lua
├── app_controls.lua
├── clipboard_utils.lua
├── clipboard_hotkeys.lua → clipboard_utils.lua
├── script_runner.lua
└── hotkeys_manager.lua → app_controls.lua, script_runner.lua
```

所有模块已经过优化整合，提供了统一、高效、易维护的 Hammerspoon 配置。 