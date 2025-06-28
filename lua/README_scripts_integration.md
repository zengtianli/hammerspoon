# Hammerspoon + Scripts_ray 集成使用说明

## 🎯 项目概述

这个集成将强大的 **scripts_ray 工具集** 与 **Hammerspoon** 结合，通过Lua脚本调用各种文件转换、内容提取、文件管理功能，提供比Raycast更深度的系统集成和自动化能力。

## 🏗️ 架构设计

```
Hammerspoon Lua脚本
       ↓
  scripts_caller.lua (封装调用)
       ↓  
  hs.task 执行外部命令
       ↓
  scripts_ray/* (实际功能脚本)
```

### 核心文件结构

```
hammerspoon/lua/
├── scripts_caller.lua      # 脚本调用封装模块
├── scripts_hotkeys.lua     # 热键配置和智能菜单
└── README_scripts_integration.md  # 本说明文档
```

## ⚡ 快速开始

### 1. 配置路径

在 `scripts_caller.lua` 中确认路径正确：

```lua
local config = {
    python_path = "/Users/tianli/miniforge3/bin/python3",
    scripts_dir = "/Users/tianli/.config/scripts_ray",  -- 修改为你的实际路径
}
```

### 2. 重载Hammerspoon配置

```bash
# 重启Hammerspoon或按 ⌘⌃⇧R 重载配置
```

### 3. 测试功能

1. 在Finder中选择一个CSV文件
2. 按 `⌘⌥⇧ + 2` 转换为Excel格式
3. 查看通知确认转换结果

## 🔥 热键功能清单

### 📄 文件转换 (`⌘⌥⇧` + 键)

| 热键 | 功能 | 说明 |
|------|------|------|
| `⌘⌥⇧ + 1` | CSV→TXT | 将CSV转换为制表符分隔的TXT |
| `⌘⌥⇧ + 2` | CSV→XLSX | 将CSV转换为Excel格式 |
| `⌘⌥⇧ + 3` | TXT→CSV | 将文本转换为CSV格式 |
| `⌘⌥⇧ + 4` | XLSX→CSV | 将Excel转换为CSV格式 |
| `⌘⌥⇧ + D` | DOCX→MD | 将Word文档转换为Markdown |
| `⌘⌥⇧ + P` | PPTX→MD | 将PowerPoint转换为Markdown |
| `⌘⌥⇧ + A` | 批量转换 | 递归转换当前目录所有支持文件 |

### 🎯 内容提取 (`⌘⌃⇧` + 键)

| 热键 | 功能 | 说明 |
|------|------|------|
| `⌘⌃⇧ + I` | 提取图片 | 从Office文档提取所有图片 |
| `⌘⌃⇧ + T` | 提取表格 | 从Office文档提取表格为CSV |
| `⌘⌃⇧ + K` | 计算Tokens | 计算文本文件的Token数量 |

### 📁 文件管理 (`⌘⌃⌥` + 键)

| 热键 | 功能 | 说明 |
|------|------|------|
| `⌘⌃⌥ + U` | 文件上移 | 将文件夹内容移到上级目录 |
| `⌘⌃⌥ + C` | 合并CSV | 合并当前目录所有CSV文件 |
| `⌘⌃⌥ + M` | 合并Markdown | 合并当前目录所有MD文件 |

### ⚙️ 系统管理 (`⌘⌃⇧` + 键)

| 热键 | 功能 | 说明 |
|------|------|------|
| `⌘⌃⇧ + L` | 启动应用 | 启动预定义的应用程序组合 |
| `⌘⌃⇧ + P` | Python包管理 | 更新Python包 |

### 🎛️ 智能功能

| 热键 | 功能 | 说明 |
|------|------|------|
| `⌘⌃⌥ + Space` | 智能转换菜单 | 根据选中文件类型显示可用操作 |
| `⌘⌃⇧ + H` | 显示帮助 | 显示所有快捷键说明 |

## 🎨 智能上下文菜单

### 使用方法

1. 在Finder中选择文件
2. 按 `⌘⌃⌥ + Space`
3. 系统会根据文件类型智能显示可用的转换选项

### 支持的文件类型

- **CSV文件**: 显示转换为TXT、XLSX的选项
- **TXT文件**: 显示转换为CSV、XLSX的选项  
- **Excel文件**: 显示转换为CSV、TXT的选项
- **Word文档**: 显示转换为Markdown的选项
- **PowerPoint**: 显示转换为Markdown的选项
- **Office文档**: 额外显示内容提取选项（图片、表格）

## 🛠️ 高级功能

### 1. 自定义回调处理

```lua
-- 自定义转换完成后的处理
scripts.convert.csv_to_xlsx(nil, function(exit_code, stdout, stderr)
    if exit_code == 0 then
        hs.alert.show("转换成功！")
        -- 可以添加自定义逻辑，如打开转换后的文件
    else
        hs.alert.show("转换失败: " .. (stderr or "未知错误"))
    end
end)
```

### 2. 批量处理特定目录

```lua
-- 转换指定目录的文件
local files = {"/path/to/file1.csv", "/path/to/file2.csv"}
scripts.convert.csv_to_xlsx(files)
```

### 3. 自动化工作流

```lua
-- 示例：下载文件夹监控自动转换
local function auto_convert_downloads()
    local downloads = os.getenv("HOME") .. "/Downloads"
    local watcher = hs.pathwatcher.new(downloads, function(files)
        for _, file in ipairs(files) do
            if file:match("%.csv$") then
                -- 自动转换新下载的CSV文件
                scripts.convert.csv_to_xlsx({file})
            end
        end
    end)
    watcher:start()
end
```

## 🔧 配置定制

### 修改脚本路径

编辑 `scripts_caller.lua` 中的配置：

```lua
local config = {
    python_path = "/your/python/path",
    scripts_dir = "/your/scripts/directory",
    scripts = {
        -- 添加或修改脚本映射
        your_script = "your_script.py"
    }
}
```

### 添加新的热键

在 `scripts_hotkeys.lua` 中添加：

```lua
-- 添加到相应的热键组
local new_hotkeys = {
    {{"cmd", "alt", "shift"}, "n", "新功能", function() 
        scripts.your_module.your_function() 
    end},
}
```

### 自定义智能菜单

修改 `show_context_menu()` 函数，添加新的文件类型支持：

```lua
if file_types.your_extension then
    table.insert(menu_items, {
        title = "你的转换选项",
        fn = function() scripts.your_module.your_function(files) end
    })
end
```

## 📊 与Raycast对比

| 功能 | Raycast | Hammerspoon |
|------|---------|-------------|
| **触发方式** | 命令搜索 | 全局热键 |
| **文件选择** | Finder选择 | Finder选择 + 路径指定 |
| **自动化程度** | 手动触发 | 热键 + 自动监控 |
| **上下文感知** | 基础 | 智能菜单 + 文件类型检测 |
| **工作流集成** | 有限 | 深度集成（应用状态、文件监控等） |
| **自定义能力** | 脚本层面 | Lua编程，更灵活 |

## 🚀 最佳实践

### 1. 工作流建议

1. **文档处理流程**：
   - 选择文件 → `⌘⌃⌥ + Space` → 选择转换选项
   
2. **批量处理**：
   - 进入目标目录 → `⌘⌥⇧ + A` → 批量转换所有文件

3. **内容提取**：
   - 选择Office文档 → `⌘⌃⇧ + I/T` → 提取图片/表格

### 2. 性能优化

- 大文件处理建议使用回调函数监控进度
- 批量处理时可以分批执行避免系统负载过高
- 定期清理转换产生的临时文件

### 3. 故障排除

如果遇到问题：

1. **检查路径配置**：确认Python和scripts_ray路径正确
2. **查看控制台**：Hammerspoon控制台会显示详细错误信息
3. **测试单个脚本**：直接在终端测试scripts_ray脚本是否正常
4. **重载配置**：修改后记得重载Hammerspoon配置

## 📈 扩展可能性

这个集成架构为未来扩展提供了无限可能：

- **窗口管理集成**：结合文件转换和窗口操作
- **网络监控**：监控网络下载，自动处理文件
- **应用状态感知**：根据当前应用自动调整功能
- **时间调度**：定时执行批量处理任务
- **团队协作**：集成云盘同步和版本控制

这个实现真正将脚本工具集提升到了**智能自动化工作站**的层次！🎉 