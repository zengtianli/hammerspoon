# Raycast 脚本与 Scripts 目录文件调用关系映射

## 概述

本文档详细说明了 `raycast/` 目录下的 Raycast 集成脚本如何调用 `scripts/` 目录下的实际执行脚本。Raycast 脚本主要作为用户界面和参数处理层，而 scripts 目录下的脚本负责实际的业务逻辑执行。

## 🗂️ 目录结构关系

```
useful_scripts/execute/
├── raycast/                    # Raycast 集成脚本（用户界面层）
│   ├── common_functions.sh     # Raycast 专用通用函数库
│   ├── trf/                    # 文件转换 Raycast 脚本
│   ├── yabai/                  # 窗口管理 Raycast 脚本
│   └── [其他 Raycast 脚本]
└── scripts_ray/                # 实际执行脚本（业务逻辑层）
    ├── common_functions.sh     # Scripts 专用通用函数库
    ├── common_utils.py         # Python 通用工具模块
    └── [各种功能脚本]
```

## 🔄 文件转换脚本映射

### CSV 相关转换

| Raycast 脚本 | 调用的 Scripts 脚本 | 功能描述 |
|-------------|-------------------|---------|
| `raycast/trf/ray_csv_to_txt.sh` | `scripts/convert_csv_to_txt.py` | CSV 转 TXT 格式 |
| `raycast/trf/ray_csv_to_xlsx.sh` | `scripts/convert_csv_to_xlsx.py` | CSV 转 Excel 格式 |
| `raycast/trf/ray_txt_to_csv.sh` | `scripts/convert_txt_to_csv.py` | TXT 转 CSV 格式 |
| `raycast/trf/ray_xlsx_to_csv.sh` | `scripts/convert_xlsx_to_csv.py` | Excel 转 CSV 格式 |

### Office 文档转换

| Raycast 脚本 | 调用的 Scripts 脚本 | 功能描述 |
|-------------|-------------------|---------|
| `raycast/trf/ray_docx_to_md.sh` | `scripts/convert_docx_to_md.sh` | DOCX 转 Markdown |
| `raycast/trf/ray_doc_to_docx.sh` | `scripts/convert_doc_to_text.sh` | DOC 转换处理 |
| `raycast/trf/ray_pdf_to_md.sh` | `scripts/convert_docx_to_md.sh` | PDF 转 Markdown（通过中间转换） |

### Excel 相关转换

| Raycast 脚本 | 调用的 Scripts 脚本 | 功能描述 |
|-------------|-------------------|---------|
| `raycast/trf/ray_txt_to_xlsx.sh` | `scripts/convert_txt_to_xlsx.py` | TXT 转 Excel 格式 |
| `raycast/trf/ray_xlsx_to_txt.sh` | `scripts/convert_xlsx_to_txt.py` | Excel 转 TXT 格式 |
| `raycast/trf/ray_xls_to_xlsx.sh` | `scripts/convert_office_batch.sh` | XLS 转 XLSX 格式 |

### 综合转换工具

| Raycast 脚本 | 调用的 Scripts 脚本 | 功能描述 |
|-------------|-------------------|---------|
| `raycast/ray_tool_split_excel.sh` | `scripts/splitsheets.py` | Excel 工作表分离 |
| （批量转换） | `scripts/convert_office_batch.sh` | 综合文档转换工具 |

## 🛠️ 应用管理脚本映射

| Raycast 脚本 | 调用的 Scripts 脚本 | 功能描述 |
|-------------|-------------------|---------|
| `raycast/ray_launch_mis.sh` | `scripts/manage_app_launcher.sh` | 应用程序启动管理 |
| `raycast/ray_manage_app_launcher.sh` | `scripts/manage_app_launcher.sh` | 应用程序管理 |
| `raycast/ray_manage_terminate_python.sh` | `scripts/manage_pip_packages.sh` | Python 包管理 |

## 📁 文件操作脚本映射

| Raycast 脚本 | 调用的 Scripts 脚本 | 功能描述 |
|-------------|-------------------|---------|
| `raycast/ray_folder_move_up_remove.sh` | `scripts/file_move_up_level.sh` | 文件上移操作 |
| `raycast/ray_copy_name_content.sh` | `scripts/extract_text_tokens.py` | 文本内容提取 |

## 🔍 内容提取脚本映射

| Raycast 脚本 | 调用的 Scripts 脚本 | 功能描述 |
|-------------|-------------------|---------|
| （图片提取） | `scripts/extract_images_office.py` | 从 Office 文档提取图片 |
| （表格提取） | `scripts/extract_tables_office.py` | 从 Office 文档提取表格 |
| （Markdown提取） | `scripts/extract_markdown_files.sh` | 提取 Markdown 文件 |

## 🔗 调用方式详解

### 1. 标准调用模式

```bash
# 在 Raycast 脚本中的典型调用方式
#!/bin/bash
# Raycast parameters...

# 引入 Raycast 专用通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中文件
SELECTED_FILE=$(get_finder_selection_single)

# 调用 scripts 目录下的实际执行脚本（使用预定义变量）
"$PYTHON_PATH" "$CONVERT_CSV_TO_TXT" "$SELECTED_FILE"
```

✅ **优化设计**: 所有脚本路径都在 `raycast/common_functions.sh` 中统一定义，raycast 脚本直接引用预定义变量，实现统一管理。

### 2. 路径配置

在 `raycast/common_functions.sh` 中定义的关键路径和脚本变量：

```bash
# 基础路径
readonly PYTHON_PATH="/Users/tianli/miniforge3/bin/python3"
readonly SCRIPTS_DIR="/Users/tianli/useful_scripts"
readonly EXECUTE_DIR="/Users/tianli/useful_scripts/execute"
readonly EXECUTE_SCRIPTS_DIR="/Users/tianli/useful_scripts/execute/scripts_ray"

# 文件转换脚本变量（示例）
readonly CONVERT_CSV_TO_TXT="$EXECUTE_SCRIPTS_DIR/convert_csv_to_txt.py"
readonly CONVERT_XLSX_TO_CSV="$EXECUTE_SCRIPTS_DIR/convert_xlsx_to_csv.py"
readonly CONVERT_DOCX_TO_MD="$EXECUTE_SCRIPTS_DIR/convert_docx_to_md.sh"
# ... 其他脚本变量
```

在 `scripts_ray/common_functions.sh` 中定义的关键路径：

```bash
readonly SCRIPTS_DIR="/Users/tianli/useful_scripts"
readonly EXECUTE_DIR="/Users/tianli/useful_scripts/execute"
```

### 3. Python 脚本调用

```bash
# 调用 Python 转换脚本（使用预定义变量）
"$PYTHON_PATH" "$CONVERT_CSV_TO_XLSX" "$SELECTED_FILE"

# 带参数的调用
"$PYTHON_PATH" "$CONVERT_XLSX_TO_CSV" -r "$SELECTED_DIRECTORY"
```

### 4. Shell 脚本调用

```bash
# 调用 Shell 转换脚本（使用预定义变量）
"$CONVERT_DOCX_TO_MD" "$SELECTED_FILE" "$OUTPUT_DIR"

# 批量处理调用
"$CONVERT_OFFICE_BATCH" -a -r
```

## 📋 参数传递规范

### 1. 文件路径传递

```bash
# Raycast 脚本负责：
# - 获取 Finder 选中的文件
# - 验证文件路径安全性
# - 传递给 scripts 脚本

SELECTED_FILE=$(get_finder_selection_single)
validate_file_path "$SELECTED_FILE"
"$PYTHON_PATH" "$CONVERT_SCRIPT_VARIABLE" "$SELECTED_FILE"
```

### 2. 选项参数传递

```bash
# 递归处理
"$PYTHON_PATH" "$CONVERT_SCRIPT_VARIABLE" -r "$DIRECTORY"

# 详细输出
"$PYTHON_PATH" "$CONVERT_SCRIPT_VARIABLE" -v "$FILE"

# 强制覆盖
"$PYTHON_PATH" "$CONVERT_SCRIPT_VARIABLE" -f "$FILE"
```

## 🔧 依赖关系

### 1. 通用函数库依赖

- **Raycast 脚本** 依赖 `raycast/common_functions.sh`
- **Scripts 脚本** 依赖 `scripts/common_functions.sh` 或 `scripts/common_utils.py`

### 2. Python 环境依赖

```bash
# 所有 Python 脚本调用都使用统一的 Python 路径
PYTHON_PATH="/Users/tianli/miniforge3/bin/python3"
```

### 3. 系统工具依赖

- markitdown (文档转换)
- pandoc (文档转换)
- LibreOffice (图片转换)
- Microsoft Office (DOC/XLS 转换)

## ⚡ 执行流程

### 典型的文件转换流程

1. **用户操作**: 在 Finder 中选中文件，运行 Raycast 命令
2. **Raycast 脚本**: 
   - 获取选中文件路径
   - 验证文件类型和安全性
   - 显示处理状态
3. **Scripts 脚本**:
   - 执行实际的转换逻辑
   - 处理错误和异常
   - 返回结果状态
4. **结果反馈**: Raycast 显示成功或失败消息

### 批量处理流程

1. **Raycast 脚本**: 获取多个选中文件
2. **参数处理**: 验证每个文件
3. **Scripts 调用**: 传递文件列表给 scripts 脚本
4. **批量执行**: Scripts 脚本处理所有文件
5. **统计反馈**: 显示处理统计信息

## 🧹 维护说明

### 1. 添加新的转换功能

1. 在 `scripts_ray/` 目录创建新的执行脚本
2. 在 `raycast/common_functions.sh` 中添加新脚本的变量定义
3. 在 `raycast/trf/` 目录创建对应的 Raycast 接口脚本（使用预定义变量）
4. 更新本映射文档

### 2. 修改路径配置

- **基础路径变更**: 只需修改 `EXECUTE_SCRIPTS_DIR` 变量
- **单个脚本路径**: 更新对应的具体变量定义
- **辅助配置**: 更新 `scripts/common_functions.sh` 中的路径常量（如需要）
- **层次化优势**: 基础目录变更时，所有脚本变量自动更新

**路径维护示例**:

```bash
# 如果 scripts_ray 目录迁移，只需修改一处：
readonly EXECUTE_SCRIPTS_DIR="/new/path/to/scripts_ray"

# 所有脚本变量自动使用新路径：
readonly CONVERT_CSV_TO_TXT="$EXECUTE_SCRIPTS_DIR/convert_csv_to_txt.py"
readonly CONVERT_XLSX_TO_CSV="$EXECUTE_SCRIPTS_DIR/convert_xlsx_to_csv.py"
# ... 其他变量自动更新
```

### 3. 版本兼容性

- 保持 Raycast 接口脚本的向后兼容性
- Scripts 脚本可以独立升级
- 通过版本标识管理兼容性

## ✅ 路径统一管理完成

### 🎯 设计优化

所有脚本路径现在统一在 `raycast/common_functions.sh` 中定义：

- **统一管理**: 所有 scripts 脚本路径在一个文件中维护
- **层次化变量**: 使用 `EXECUTE_SCRIPTS_DIR` 作为基础目录，避免重复路径
- **语义化调用**: raycast 脚本使用有意义的变量名而非硬编码路径
- **易于维护**: 路径变更只需修改一个或两个变量

### 📋 预定义脚本变量

当前已定义的脚本变量包括：

**文件转换类**:
- `$CONVERT_CSV_TO_TXT`, `$CONVERT_CSV_TO_XLSX`
- `$CONVERT_TXT_TO_CSV`, `$CONVERT_TXT_TO_XLSX`
- `$CONVERT_XLSX_TO_CSV`, `$CONVERT_XLSX_TO_TXT`
- `$CONVERT_DOCX_TO_MD`, `$CONVERT_PPTX_TO_MD`

**内容提取类**:
- `$EXTRACT_IMAGES_OFFICE`, `$EXTRACT_TABLES_OFFICE`
- `$EXTRACT_MARKDOWN_FILES`, `$EXTRACT_TEXT_TOKENS`

**管理工具类**:
- `$MANAGE_APP_LAUNCHER`, `$MANAGE_PIP_PACKAGES`
- `$LIST_APPLICATIONS`, `$SPLITSHEETS`

### 📋 完整变量定义 (基于 EXECUTE_SCRIPTS_DIR)

当前在 `raycast/common_functions.sh` 中定义的所有脚本变量：

```bash
# 基础目录
readonly EXECUTE_SCRIPTS_DIR="/Users/tianli/useful_scripts/execute/scripts_ray"

# 文件转换类 (11个)
readonly CONVERT_CSV_TO_TXT="$EXECUTE_SCRIPTS_DIR/convert_csv_to_txt.py"
readonly CONVERT_CSV_TO_XLSX="$EXECUTE_SCRIPTS_DIR/convert_csv_to_xlsx.py"
readonly CONVERT_TXT_TO_CSV="$EXECUTE_SCRIPTS_DIR/convert_txt_to_csv.py"
readonly CONVERT_TXT_TO_XLSX="$EXECUTE_SCRIPTS_DIR/convert_txt_to_xlsx.py"
readonly CONVERT_XLSX_TO_CSV="$EXECUTE_SCRIPTS_DIR/convert_xlsx_to_csv.py"
readonly CONVERT_XLSX_TO_TXT="$EXECUTE_SCRIPTS_DIR/convert_xlsx_to_txt.py"
readonly CONVERT_DOCX_TO_MD="$EXECUTE_SCRIPTS_DIR/convert_docx_to_md.sh"
readonly CONVERT_DOC_TO_TEXT="$EXECUTE_SCRIPTS_DIR/convert_doc_to_text.sh"
readonly CONVERT_PPTX_TO_MD="$EXECUTE_SCRIPTS_DIR/convert_pptx_to_md.py"
readonly CONVERT_WMF_TO_PNG="$EXECUTE_SCRIPTS_DIR/convert_wmf_to_png.py"
readonly CONVERT_OFFICE_BATCH="$EXECUTE_SCRIPTS_DIR/convert_office_batch.sh"

# 内容提取类 (4个)
readonly EXTRACT_IMAGES_OFFICE="$EXECUTE_SCRIPTS_DIR/extract_images_office.py"
readonly EXTRACT_TABLES_OFFICE="$EXECUTE_SCRIPTS_DIR/extract_tables_office.py"
readonly EXTRACT_MARKDOWN_FILES="$EXECUTE_SCRIPTS_DIR/extract_markdown_files.sh"
readonly EXTRACT_TEXT_TOKENS="$EXECUTE_SCRIPTS_DIR/extract_text_tokens.py"

# 文件操作类 (4个)
readonly FILE_MOVE_UP_LEVEL="$EXECUTE_SCRIPTS_DIR/file_move_up_level.sh"
readonly LINK_CREATE_ALIASES="$EXECUTE_SCRIPTS_DIR/link_create_aliases.sh"
readonly LINK_BIND_FILES="$EXECUTE_SCRIPTS_DIR/link_bind_files.py"
readonly LINK_IMAGES_CENTRAL="$EXECUTE_SCRIPTS_DIR/link_images_central.sh"

# 合并工具类 (2个)
readonly MERGE_CSV_FILES="$EXECUTE_SCRIPTS_DIR/merge_csv_files.sh"
readonly MERGE_MARKDOWN_FILES="$EXECUTE_SCRIPTS_DIR/merge_markdown_files.sh"

# 管理工具类 (3个)
readonly MANAGE_APP_LAUNCHER="$EXECUTE_SCRIPTS_DIR/manage_app_launcher.sh"
readonly MANAGE_PIP_PACKAGES="$EXECUTE_SCRIPTS_DIR/manage_pip_packages.sh"
readonly LIST_APPLICATIONS="$EXECUTE_SCRIPTS_DIR/list_applications.sh"

# 其他工具类 (1个)
readonly SPLITSHEETS="$EXECUTE_SCRIPTS_DIR/splitsheets.py"
```

**统计**: 25 个脚本变量，全部基于 `EXECUTE_SCRIPTS_DIR` 基础变量构建

## 🔍 故障排除

### 常见问题

1. **路径不存在**: 检查 `SCRIPTS_DIR` 和 `EXECUTE_DIR` 配置
2. **权限错误**: 确保脚本有执行权限 `chmod +x`
3. **Python 包缺失**: 检查 `requirements.txt` 中的依赖
4. **编码问题**: 确保文件使用 UTF-8 编码
5. **⚠️ 路径错误**: 如果出现"文件不存在"错误，检查是否使用了更新后的路径

### 调试方法

```bash
# 开启调试模式
DEBUG=true raycast_script.sh

# 检查路径变量层次
echo "Python路径: $PYTHON_PATH"
echo "Scripts_ray目录: $EXECUTE_SCRIPTS_DIR"
echo "转换脚本: $CONVERT_CSV_TO_TXT"

# 测试 Python 脚本
"$PYTHON_PATH" "$CONVERT_CSV_TO_TXT" --version

# 检查变量是否正确定义
set | grep "EXECUTE_SCRIPTS_DIR"
set | grep "CONVERT_"
```

## 📊 调用关系总结

### 成功完成的工作

1. ✅ **文件重新组织**: 所有执行脚本已移动到 `scripts_ray/` 目录
2. ✅ **路径配置更新**: `common_functions.sh` 和 `common_utils.py` 中的路径已更新
3. ✅ **层次化变量设计**: 引入 `EXECUTE_SCRIPTS_DIR` 基础变量，简化路径定义
4. ✅ **Raycast脚本统一**: 所有 raycast 脚本使用预定义变量调用
5. ✅ **映射文档创建**: 完整的调用关系映射已建立（25个脚本变量）

### 调用架构

```
用户操作 (Finder选择文件)
    ↓
Raycast 脚本 (raycast/trf/*.sh)
    ↓ 调用
实际执行脚本 (scripts_ray/*.py 或 scripts_ray/*.sh)
    ↓ 依赖
通用函数库 (scripts_ray/common_functions.sh, scripts_ray/common_utils.py)
```

### 核心功能分类统计

- **文件转换类**: 11 个脚本变量 (CSV、Office、格式转换等)
- **内容提取类**: 4 个脚本变量 (图片、表格、文本提取等)
- **文件操作类**: 4 个脚本变量 (移动、链接、别名等)
- **合并工具类**: 2 个脚本变量 (CSV、Markdown合并)
- **管理工具类**: 3 个脚本变量 (应用、包管理等)
- **其他工具类**: 1 个脚本变量 (Excel分离等)

**总计**: 25 个完整的调用映射关系

### 🏗️ 层次化变量设计

**变量层次结构**:

```
基础路径变量
├── SCRIPTS_DIR="/Users/tianli/useful_scripts"
├── EXECUTE_DIR="/Users/tianli/useful_scripts/execute"  
└── EXECUTE_SCRIPTS_DIR="/Users/tianli/useful_scripts/execute/scripts_ray"

功能脚本变量 (基于 EXECUTE_SCRIPTS_DIR)
├── CONVERT_CSV_TO_TXT="$EXECUTE_SCRIPTS_DIR/convert_csv_to_txt.py"
├── CONVERT_XLSX_TO_CSV="$EXECUTE_SCRIPTS_DIR/convert_xlsx_to_csv.py"
└── [其他 20+ 个脚本变量...]
```

**维护优势**:
- 📂 目录迁移：修改 1 个基础变量，20+ 个脚本变量自动更新
- 🔧 单个脚本：只需修改对应的具体变量
- 🎯 语义清晰：变量名直接表达功能和文件类型

### 🏗️ 设计原则

**统一管理原则**: 所有脚本路径在 `raycast/common_functions.sh` 中集中定义，实现了：

1. **层次化管理**: 使用 `EXECUTE_SCRIPTS_DIR` 基础变量，避免重复路径片段
2. **单点维护**: scripts 目录位置变更只需修改一个基础变量
3. **语义化调用**: raycast 脚本使用有意义的变量名
4. **类型分组**: 按功能类型组织脚本变量
5. **易于扩展**: 新增脚本只需添加一个变量定义

**示例对比**:

```bash
# 旧方式（需要在每个脚本中维护完整路径）
"$PYTHON_PATH" "$SCRIPTS_DIR/execute/scripts_ray/convert_csv_to_txt.py"

# 优化方式（使用预定义变量，简洁且语义化）
"$PYTHON_PATH" "$CONVERT_CSV_TO_TXT"
```

**路径变量层次**:

```bash
# 第一层：基础目录变量
EXECUTE_SCRIPTS_DIR="/Users/tianli/useful_scripts/execute/scripts_ray"

# 第二层：具体脚本变量
CONVERT_CSV_TO_TXT="$EXECUTE_SCRIPTS_DIR/convert_csv_to_txt.py"

# 最终调用：简洁明了
"$PYTHON_PATH" "$CONVERT_CSV_TO_TXT"
```

---

**注意**: 本文档需要随着脚本的添加、修改或重命名而及时更新，以确保映射关系的准确性。 