# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- 添加测试套件
- 支持更多文档格式
- 添加图形化界面
- 跨平台支持(Linux/Windows)

## [2.1.0] - 2024-01-20

### Added
- 📋 **Execute脚本代码规范文档 v2.0**
  - 统一Shell和Python脚本的设计模式
  - 建立完整的编码规范体系
  - 定义标准代码结构模板
  - 规范错误处理和安全性要求
- 🔄 **文件重命名标准化**
  - 执行了21个脚本的批量重命名
  - 统一了文件命名规范（功能前缀_对象_转换方向）
  - 创建向后兼容的软链接
  - 更新了相关脚本中的引用路径

### Changed
- 🏗️ **重构通用函数库**
  - `common_functions.sh` - 专为execute脚本优化
  - `common_utils.py` - Python脚本通用工具模块
  - 移除了Raycast相关的特定功能
  - 增强了文件操作和错误处理能力
- 📝 **更新项目文档**
  - `COMMON_FUNCTIONS_USAGE.md` - 详细的使用指南
  - `RENAME_SUGGESTIONS.md` - 完整的重命名方案
  - `CODE_STANDARDS.md` - execute脚本专用代码规范

### Enhanced
- ⚡ **脚本功能增强**
  - 所有脚本支持标准化的参数处理
  - 统一的进度显示和错误处理
  - 完善的依赖检查机制
  - 改进的用户体验和消息显示

## [2.0.0] - 2024-01-20

### Added
- 🎉 **Shell脚本代码规范文档 v2.0**
  - 增强了安全性验证函数
  - 添加了重试机制和性能优化指南
  - 完善了错误处理和用户体验
  - 新增子目录脚本组织规范
- 📚 **完整的项目文档体系**
  - README.md - 项目主要说明
  - CONTRIBUTING.md - 贡献指南
  - LICENSE.md - MIT许可证
  - 其他标准项目文档
- ⚡ **Raycast集成优化**
  - 统一使用common_functions.sh
  - 删除重复代码定义
  - 优化脚本执行效率

### Changed
- 🔧 **重构多个Raycast脚本**
  - `ray_ap_nvimGh.sh` - 添加Ghostty支持
  - `ray_yabai_*.sh` - 统一消息显示函数
  - `ray_ap_runfile*.sh` - 删除重复路径定义
- 📝 **更新所有README文档**
  - raycast/README.md - 主要功能文档
  - raycast/trf/README.md - 文件转换工具
  - raycast/yabai/README.md - 窗口管理工具

### Fixed
- 🐛 修复common_functions.sh路径引用问题
- 🐛 修复重复变量定义导致的冲突
- 🐛 修复部分脚本的错误处理逻辑

## [1.5.0] - 2024-01-15

### Added
- 📄 **PowerPoint转换增强** (`pptx2md.py`)
  - 支持提取图片和表格
  - 改进文本格式化
  - 添加幻灯片备注支持
  - 生成文档目录
- 🔄 **综合转换工具** (`convert_all.sh`)
  - 支持批量文档转换
  - DOC → DOCX → Markdown 转换链
  - Excel文件处理优化
  - 递归目录处理

### Changed
- 🎯 优化文件提取工具性能
- 📊 改进转换进度显示
- 🔧 增强错误处理和用户提示

### Fixed
- 🐛 修复WMF图片转换问题
- 🐛 解决大文件处理内存问题
- 🐛 修复路径空格处理bug

## [1.4.0] - 2024-01-10

### Added
- 🖼️ **文档内容提取工具**
  - `ext_img_dp.py` - 从DOCX/PPTX提取图片
  - `ext_tab_dp.py` - 从文档提取表格
  - `ext2alias.sh` - 创建内容符号链接
  - `ext2bind.py` - 文件绑定管理系统
- 🔧 **系统管理工具**
  - `launch_mis.sh` - 应用程序启动管理
  - `list_app.sh` - 运行应用程序列表
  - `pip_update.sh` - Python包批量更新

### Changed
- 🎨 改进输出格式和颜色显示
- 📁 优化文件组织结构
- 🔄 增强批处理能力

## [1.3.0] - 2024-01-05

### Added
- 📊 **表格处理工具集**
  - `csvtxtxlsx/` - 表格格式转换工具目录
  - `csv2xls.py` - CSV转Excel工具
  - `splitsheets.py` - Excel工作表分离
  - `mergecsv.sh` - CSV文件智能合并
- 🔤 **文档处理增强**
  - `gettoken.py` - 文本Token数量计算
  - `extract_md_files.sh` - Markdown文件提取
  - `mergemd.sh` - Markdown文件合并

### Changed
- 🚀 提升脚本执行效率
- 📝 改进命令行参数处理
- 🛡️ 增强文件安全检查

## [1.2.0] - 2024-01-01

### Added
- 🪟 **Yabai窗口管理集成**
  - `yabai/` - 完整的窗口管理脚本集
  - 支持窗口切换、空间管理、布局切换
  - 集成到Raycast快捷命令
- 🎯 **Raycast脚本集合**
  - `raycast/` - Raycast集成脚本目录
  - 快速文件转换、应用启动等功能

### Changed
- 🔧 重构脚本目录结构
- 📚 完善脚本内置帮助信息
- 🎨 统一脚本输出格式

## [1.1.0] - 2023-12-25

### Added
- 📄 **文档转换基础工具**
  - `markitdown_docx2md.sh` - DOCX转Markdown
  - `markitdown_docx2pdf.sh` - DOCX转PDF
  - `d2t_pandoc.sh` - 文档转文本(使用Pandoc)
- 🖼️ **图片处理工具**
  - `wmf2png.sh` - WMF格式图片转PNG
  - `convert_wmf.py` - Python版WMF转换工具
  - `pics_all.sh` - 图片文件符号链接管理

### Fixed
- 🐛 修复文件路径包含空格的处理问题
- 🐛 解决某些Office版本兼容性问题

## [1.0.0] - 2023-12-20

### Added
- 🎉 **项目初始版本**
- 📁 **文件管理工具**
  - `move_files_up.sh` - 文件向上层目录移动
  - `list/` - 文件列表管理工具集
- 🔧 **基础实用工具**
  - 脚本权限管理
  - 基本文件操作功能

---

## 版本说明

- **Major版本 (X.0.0)**: 重大功能变更或架构重构
- **Minor版本 (0.X.0)**: 新功能添加或重要改进
- **Patch版本 (0.0.X)**: Bug修复或小幅优化

## 图例

- 🎉 新项目/重大里程碑
- ✨ 新功能
- 🔧 工具改进
- 📄 文档相关
- 🖼️ 图片/媒体处理
- 📊 数据/表格处理
- 🪟 界面/窗口管理
- ⚡ 性能优化
- 🐛 Bug修复
- 🛡️ 安全性改进
- 📚 文档更新
- 🎨 UI/UX改进
- 🔄 重构
- 🚀 性能提升 