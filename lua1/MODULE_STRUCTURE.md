# Lua1 模块文件结构

## 核心模块

### `scripts_hotkeys.lua` - 主热键配置中心
- **功能**: 注册所有热键，管理转换菜单
- **依赖**: 所有其他模块
- **热键**: 应用控制、宏控制、鼠标控制、脚本运行、智能菜单

### `common_utils.lua` - 公共工具库
- **功能**: Finder操作、文件处理、通知、剪贴板、日志、热键注册
- **依赖**: 无
- **类型**: 基础工具模块，被所有模块使用

## 功能模块

### `app_controls.lua` - 应用控制
- **功能**: 在指定应用中打开目录/文件，创建文件夹
- **热键**: 
  - `⌘⌃⇧+T`: Ghostty在此处打开
  - `⌘⌃⇧+W`: Cursor在此处打开  
  - `⌘⌃⇧+V`: Nvim在Ghostty中打开文件
  - `⌘⇧+N`: 创建新文件夹

### `macro_controls.lua` - 宏控制
- **功能**: 配置驱动的宏播放系统，调用shell脚本
- **配置**: 通过 `macro_config` 表动态映射快捷键到宏名称
- **API**: `macro_play(name)`, `update_macro_config(config)`

### `macro_hotkeys.lua` - 宏快捷键
- **功能**: 独立的宏快捷键管理，方便debug和维护
- **热键**:
  - `⌘⌃⇧⌥+1`: 宏播放(login)
  - `⌘⌃⇧⌥+2`: 宏播放(daily)
  - `⌘⌃⇧⌥+3`: 宏播放(demo)
- **API**: `bind_macro_hotkeys()`, `unbind_macro_hotkeys()`, `rebind_macro_hotkeys()`

### `clipboard_utils.lua` - 剪贴板工具
- **功能**: 复制文件名/内容，智能粘贴文件
- **配置文件**: `clipboard_hotkeys.lua`
- **热键**:
  - `⌘⌃⇧+N`: 复制文件名
  - `⌘⌃⇧+C`: 复制文件名和内容
  - `⌃⌥+V`: 粘贴到Finder

### `mouse_follow_control.lua` - 鼠标跟随
- **功能**: 切换鼠标跟随状态
- **热键**: `⌘⌃⇧⌥+F`: 切换鼠标跟随

### `script_runner.lua` - 脚本运行器
- **功能**: 单个/并行运行选中脚本
- **热键**:
  - `⌘⌃⇧+S`: 运行选中脚本
  - `⌘⌃⇧+R`: 并行运行脚本

### `scripts_caller.lua` - 外部脚本调用器
- **功能**: 封装25个scripts_ray脚本，提供转换API
- **用途**: 为智能菜单提供文件转换功能

## 配置文件

### `clipboard_hotkeys.lua` - 剪贴板热键配置
- **功能**: 独立的剪贴板热键注册
- **依赖**: `clipboard_utils.lua`, `common_utils.lua`

## 调用关系

```
scripts_hotkeys.lua (主控制器)
├── app_controls.lua (应用控制)
├── macro_controls.lua (宏控制) 
├── mouse_follow_control.lua (鼠标控制)
├── script_runner.lua (脚本运行)
├── scripts_caller.lua (外部脚本调用)
└── common_utils.lua (公共工具)

clipboard_hotkeys.lua (独立注册)
├── clipboard_utils.lua (剪贴板工具)
└── common_utils.lua (公共工具)
```

## 智能菜单系统

- **触发**: `⌘⌃⌥+Space`
- **功能**: 根据选中文件类型显示可用转换操作
- **支持**: CSV、TXT、XLSX、DOCX、PPTX转换和内容提取 