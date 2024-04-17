以下是根据您的 `.hammerspoon` 目录结构和各 Lua 脚本的功能，重新编写的中文版 `readme.md` 文件。这个文档旨在帮助您快速回忆每个脚本的作用，并了解整个配置的布局。

# Hammerspoon 配置文档

## 介绍

这个仓库包含了一系列为 macOS 自动化工具 Hammerspoon 构建的实用函数。这些功能允许您管理剪贴板历史记录，控制鼠标位置，执行自定义的快捷键命令等。通过这些工具，您可以提高生产力，使您的 macOS 使用体验更加流畅和高效。

## 目录结构

- **Spoons/**: 存放 Hammerspoon 的 Spoon 插件。
- **blogging/**: 包含与博客发布相关的脚本。
- **clipboard/**: 管理剪贴板历史记录的脚本。
- **launcher/**: 应用程序启动器相关脚本。
- **notes/**: 快速笔记相关的脚本。
- **scripts/**: 存放一些常用的 Shell 脚本。
- **text/**: 文本片段自动扩展的脚本。
- **utils/**: 包含多种实用工具脚本，如鼠标跟随和键位检测。
- **vimlike/**: 提供 Vim 风格操作的脚本。
- **yabai/**: 与 Yabai 窗口管理器交互的脚本。

## 文件功能

- **init.lua**: 主配置文件，负责加载所有模块。
- **clipboard/manager.lua**: 管理剪贴板历史，允许用户访问和使用之前的剪贴板项。
- **launcher/app_launcher.lua**: 定义快捷键以快速启动应用程序。
- **launcher/music_controls.lua**: 控制音乐播放，如播放、暂停和切歌。
- **notes/quicknote.lua**: 提供快速记录笔记并通过快捷键保存的功能。
- **text/snippets.lua**: 自动扩展预设的文本片段，提高打字效率。
- **utils/arc.lua**: 管理和激活 Arc 应用的快捷键。
- **utils/key_detection.lua**: 检测键盘活动，并执行相关动作。
- **utils/mouse_follow.lua**: 鼠标跟随功能，使鼠标自动移动到活动窗口的中心位置。
- **utils/recordedPosition.lua**: 记录和恢复鼠标在不同应用中的位置。
- **yabai/controls.lua**: 与 Yabai 窗口管理器进行交互，如切换窗口或调整布局。

## 使用方法

每个脚本或模块文件夹中的 README.md 将提供更详细的使用说明和快捷键绑定信息。

## 安装

克隆仓库并将脚本移动到 Hammerspoon 的配置目录:

```bash
git clone https://github.com/zengtianli/hammerspoon.git
cd ~/.hammerspoon/
```

重载 Hammerspoon 配置以应用更改。

## 贡献

欢迎贡献! 如果您发现了错误或希望添加新功能，请创建问题或开放拉取请求。

## 许可

本项目采用 MIT 许可证。详情请查阅 [LICENSE](./LICENSE) 文件。

## 常见问题解答

关于如何开始使用 Hammerspoon 的更多信息，请参阅[官方 Hammerspoon 文档](https://www.hammerspoon.org/docs/)。

## 已知问题

一些脚本在多显示器或虚拟桌面上可能无法正确工作，请确保应用在

同一屏幕上进行记录。
