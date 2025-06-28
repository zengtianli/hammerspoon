# Useful Scripts Collection

一个实用脚本集合，包含文档转换、文件管理、系统自动化等各种工具，主要适用于 macOS 系统。

## 🚀 项目概述

本项目旨在提供一系列实用的脚本工具，帮助用户自动化日常工作流程，包括：

- **文档转换**：支持 DOC/DOCX/PPTX/PDF/Markdown 等格式之间的转换
- **表格处理**：CSV/XLS/XLSX 格式转换和数据处理
- **文件管理**：批量文件操作、提取、合并等功能
- **系统自动化**：Raycast 集成、Yabai 窗口管理、应用程序管理
- **实用工具**：文本处理、Token 计算、图片转换等

## 📁 项目结构

```
useful_scripts/
├── 📄 文档转换工具
│   ├── convert_all.sh          # 综合文档转换工具
│   ├── markitdown_docx2md.sh   # DOCX 转 Markdown
│   ├── pptx2md.py             # PowerPoint 转 Markdown
│   └── d2t_pandoc.sh          # DOC/DOCX 转文本
│
├── 📊 表格处理工具
│   ├── csv2xls.py             # CSV 转 Excel
│   ├── splitsheets.py         # Excel 工作表分离
│   ├── mergecsv.sh           # CSV 文件合并
│   └── csvtxtxlsx/           # 表格格式转换工具集
│
├── 🗂️ 文件管理工具
│   ├── ext_img_dp.py         # 从文档提取图片
│   ├── ext_tab_dp.py         # 从文档提取表格
│   ├── extract_md_files.sh   # 提取 Markdown 文件
│   ├── move_files_up.sh      # 文件向上移动
│   └── list/                 # 文件列表管理工具
│
├── ⚡ Raycast 集成
│   └── raycast/              # Raycast 快捷脚本集合
│       ├── trf/              # 文件转换脚本
│       └── yabai/            # 窗口管理脚本
│
├── 🖥️ 系统工具
│   ├── yabai/                # Yabai 窗口管理器配置
│   ├── launch_mis.sh         # 应用程序管理
│   ├── list_app.sh          # 运行应用列表
│   └── pip_update.sh        # Python 包更新
│
└── 🛠️ 实用工具
    ├── gettoken.py          # Token 数量计算
    ├── wmf2png.sh          # WMF 图片转换
    └── others/             # 其他实用脚本
```

## 🎯 主要功能

### 1. 文档转换
- **一键批量转换**：支持 DOC → DOCX → Markdown 的完整转换链
- **PowerPoint 转换**：将 PPTX 转换为结构化的 Markdown，保留图片和表格
- **格式保留**：尽可能保持原文档的格式和结构

### 2. 表格处理
- **多格式支持**：CSV、XLS、XLSX 之间的相互转换
- **工作表分离**：将多工作表的 Excel 文件分离成单独文件
- **数据合并**：智能合并多个 CSV 文件

### 3. 内容提取
- **图片提取**：从 DOCX/PPTX 文档中提取所有图片，支持 WMF 转 PNG
- **表格提取**：提取文档中的表格并转换为 CSV/Markdown 格式
- **内容管理**：创建符号链接便于统一管理提取的内容

### 4. Raycast 集成
- **快速转换**：通过 Raycast 快速执行文件格式转换
- **窗口管理**：集成 Yabai 的窗口操作命令
- **应用启动**：快速启动常用应用程序

## 🔧 系统要求

- **操作系统**：macOS 10.15 或更高版本
- **Python**：3.7+ (推荐使用 Miniforge)
- **依赖工具**：
  - Microsoft Office (用于 DOC/XLS 转换)
  - LibreOffice (用于 WMF 图片转换)
  - Pandoc (用于文档转换)
  - markitdown (用于 Markdown 转换)

## 📦 安装

### 1. 克隆项目
```bash
git clone https://github.com/your-username/useful_scripts.git
cd useful_scripts
```

### 2. 安装 Python 依赖
```bash
# 安装基础依赖
pip install pandas openpyxl python-docx python-pptx tiktoken markitdown

# 或使用 requirements.txt (如果存在)
pip install -r requirements.txt
```

### 3. 安装系统工具
```bash
# 安装 Homebrew (如果未安装)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 Pandoc
brew install pandoc

# 安装 LibreOffice (用于图片转换)
brew install --cask libreoffice
```

### 4. 配置脚本权限
```bash
# 给所有 shell 脚本添加执行权限
find . -name "*.sh" -exec chmod +x {} \;
```

## 🚀 快速开始

### 文档转换示例
```bash
# 转换当前目录下所有支持的文档
./convert_all.sh -a

# 只转换 Word 文档
./convert_all.sh -d

# 递归处理子目录
./convert_all.sh -a -r

# 转换单个 PowerPoint 文件
python3 pptx2md.py presentation.pptx
```

### 表格处理示例
```bash
# 合并当前目录下所有 CSV 文件
./mergecsv.sh

# 分离 Excel 工作表
python3 splitsheets.py workbook.xlsx

# CSV 转 Excel
python3 csv2xls.py data.csv
```

### 内容提取示例
```bash
# 从所有 Office 文档提取图片
python3 ext_img_dp.py

# 从所有 Office 文档提取表格
python3 ext_tab_dp.py

# 创建提取内容的符号链接
./ext2alias.sh
```

## 📚 详细文档

- [安装指南](INSTALL.md) - 详细的安装和配置说明
- [问题排查](TROUBLESHOOTING.md) - 常见问题及解决方案
- [贡献指南](CONTRIBUTING.md) - 如何为项目贡献代码
- [代码规范](Shell脚本代码规范文档.md) - Shell 脚本编写规范

## 🤝 贡献

欢迎贡献代码、报告问题或提出建议！请查看 [贡献指南](CONTRIBUTING.md) 了解详细信息。

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE.md)。

## 🆘 支持

如果遇到问题，请：
1. 查看 [问题排查指南](TROUBLESHOOTING.md)
2. 搜索 [Issues](../../issues) 中是否有类似问题
3. 创建新的 Issue 并提供详细信息

## 🏷️ 版本历史

查看 [CHANGELOG.md](CHANGELOG.md) 了解版本更新历史。

---

**⭐ 如果这个项目对你有帮助，请给个 Star！** 