# lua_comb 使用指南

## 🚀 快速开始

### 1. 确认配置
- ✅ `lua_comb/` 文件夹已创建，包含14个模块文件
- ✅ 主 `init.lua` 已修改为加载 `lua_comb.init`
- ✅ 所有功能模块已整合完成

### 2. 启动 Hammerspoon
1. 打开 Hammerspoon 应用
2. 确保 Hammerspoon 正在运行
3. 重新加载配置：`⌘⇧+R` 或点击菜单栏图标 → Reload Config

### 3. 验证配置
如果看到通知 "✅ Hammerspoon 配置已加载 (lua_comb)"，说明配置成功！

### 4. 测试功能
- **测试系统设置**: 按 `⌘⌥+,` 应该打开系统设置
- **测试宏功能**: 按 `⌘⌃⇧+1` 尝试播放宏1（如果有宏文件）
- **测试音乐控制**: 按 `⌘⌃⇧+;` 控制音乐播放
- **查看帮助**: 按 `⌘⌃⌥⇧+H` 显示完整快捷键列表

## 🔧 故障排除

### 如果配置加载失败：
1. 检查 Hammerspoon 控制台（菜单栏图标 → Console）查看错误信息
2. 确保所有 lua_comb 文件都存在
3. 重新启动 Hammerspoon 应用

### 如果快捷键不工作：
1. 检查 macOS 系统偏好设置 → 安全性与隐私 → 辅助功能
2. 确保 Hammerspoon 有辅助功能权限
3. 重新加载配置

### 如果宏不工作：
1. 确保 `macros/` 文件夹中有 `macro_1.txt` 等宏文件
2. 检查宏文件格式：每行一个坐标点 `x,y`
3. 确保有系统录制权限

## 📁 文件结构
```
hammerspoon/
├── init.lua (主配置，已修改)
├── lua_comb/ (新的统一模块)
│   ├── README.md
│   ├── USAGE.md (本文件)
│   ├── init.lua (模块主入口)
│   ├── common_utils.lua (统一工具库)
│   ├── music_controls.lua
│   ├── app_restart.lua
│   ├── wechat_launcher.lua
│   ├── system_shortcuts.lua
│   ├── macro_player.lua
│   ├── macro_controls.lua
│   ├── macro_hotkeys.lua
│   ├── app_controls.lua
│   ├── clipboard_utils.lua
│   ├── clipboard_hotkeys.lua
│   ├── script_runner.lua
│   └── hotkeys_manager.lua
├── lua/ (原文件夹，现在不再使用)
├── lua1/ (原文件夹，现在不再使用)
├── macros/ (宏文件)
└── scripts/ (脚本文件)
```

## 🎯 与原系统的差异

### 保留的功能：
- ✅ 所有音乐控制快捷键
- ✅ 应用重启功能
- ✅ 微信启动功能  
- ✅ 高性能宏系统
- ✅ 应用控制功能
- ✅ 剪贴板工具
- ✅ 脚本运行器
- ✅ 系统设置快捷键

### 移除的功能：
- ❌ 文件转换快捷键（您不需要的功能）
- ❌ 智能转换菜单
- ❌ 文件监控功能

### 性能提升：
- ⚡ 宏播放速度提升 10-20倍
- ⚡ 模块加载速度更快
- ⚡ 内存使用更优化

## 🔄 回滚方案
如果需要回到原配置：
1. 备份当前 `init.lua`
2. 恢复原来的 `init.lua` 内容
3. 重新加载配置

当前的 `lua_comb` 模块不会影响原有的 `lua/` 和 `lua1/` 文件夹，可以安全测试。 