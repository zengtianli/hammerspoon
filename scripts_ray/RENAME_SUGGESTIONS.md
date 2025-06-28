# 文件重命名建议

## 重命名原则

1. **功能前缀**: 使用动词表示主要功能 (convert, extract, merge, list, manage, file)
2. **对象描述**: 明确处理的对象类型 (csv, docx, images, etc.)
3. **转换方向**: 对于转换类，明确 from_to 关系
4. **下划线分隔**: 统一使用下划线而非驼峰命名
5. **描述性强**: 从文件名就能理解功能

## 具体重命名方案

### 🔄 转换类工具 (convert_*)

| 原文件名 | 建议新名称 | 功能说明 |
|---------|-----------|----------|
| `convert_all.sh` | `convert_office_batch.sh` | 批量Office文档转换 |
| `convert_wmf.py` | `convert_wmf_to_png.py` | WMF转PNG转换器 |
| `csv2xls.py` | `convert_csv_to_xlsx.py` | CSV转Excel转换器 |
| `d2t_pandoc.sh` | `convert_doc_to_text.sh` | 文档转纯文本 |
| `markitdown_docx2md.sh` | `convert_docx_to_md.sh` | DOCX转Markdown |
| `markitdown_docx2pdf.sh` | `convert_docx_to_pdf.sh` | DOCX转PDF |
| `wmf2png.sh` | `convert_wmf_to_png.sh` | WMF转PNG (Shell版) |
| `pptx2md.py` | `convert_pptx_to_md.py` | PPTX转Markdown |

### 📤 提取类工具 (extract_*)

| 原文件名 | 建议新名称 | 功能说明 |
|---------|-----------|----------|
| `ext_img_dp.py` | `extract_images_office.py` | 从Office文档提取图片 |
| `ext_tab_dp.py` | `extract_tables_office.py` | 从Office文档提取表格 |
| `extract_md_files.sh` | `extract_markdown_files.sh` | 提取Markdown文件 |
| `gettoken.py` | `extract_text_tokens.py` | 提取文本token数量 |

### 🔗 链接/绑定类工具 (link_*)

| 原文件名 | 建议新名称 | 功能说明 |
|---------|-----------|----------|
| `ext2alias.sh` | `link_create_aliases.sh` | 创建文件别名链接 |
| `ext2bind.py` | `link_bind_files.py` | 文件绑定监控系统 |
| `pics_all.sh` | `link_images_central.sh` | 集中链接所有图片 |

### 🔄 合并类工具 (merge_*)

| 原文件名 | 建议新名称 | 功能说明 |
|---------|-----------|----------|
| `mergecsv.sh` | `merge_csv_files.sh` | 合并多个CSV文件 |
| `mergemd.sh` | `merge_markdown_files.sh` | 合并Markdown文件 |

### 📋 管理类工具 (manage_*,list_*)

| 原文件名 | 建议新名称 | 功能说明 |
|---------|-----------|----------|
| `list_app.sh` | `list_applications.sh` | 列出系统应用程序 |
| `launch_mis.sh` | `manage_app_launcher.sh` | 应用程序启动管理 |
| `pip_update.sh` | `manage_pip_packages.sh` | Python包管理更新 |

### 🗂️ 文件操作类工具 (file_*)

| 原文件名 | 建议新名称 | 功能说明 |
|---------|-----------|----------|
| `move_files_up.sh` | `file_move_up_level.sh` | 文件上移到父目录 |

## 重命名的好处

### 1. **功能分类清晰**
- 转换类：一目了然是格式转换工具
- 提取类：明确是提取特定内容
- 链接类：处理文件链接和别名
- 合并类：合并多个文件
- 管理类：系统管理和维护

### 2. **搜索友好**
- 按功能前缀搜索：`convert_*`、`extract_*`
- 按对象类型搜索：`*_csv_*`、`*_office_*`
- 按转换关系搜索：`*_to_*`

### 3. **维护性提升**
- 新工具命名有规可循
- 功能归类更清晰
- 减少记忆负担

## 实施建议

### 阶段性重命名
1. **第一阶段**: 重命名核心转换工具
2. **第二阶段**: 重命名提取和合并工具  
3. **第三阶段**: 重命名管理和文件操作工具

### 兼容性考虑
- 保留原文件作为软链接
- 更新相关脚本中的引用
- 更新README文档

### 批量重命名脚本
```bash
#!/bin/bash
# 批量重命名脚本示例

# 转换类
mv convert_all.sh convert_office_batch.sh
mv convert_wmf.py convert_wmf_to_png.py
mv csv2xls.py convert_csv_to_xlsx.py
# ... 其他重命名操作

# 创建向后兼容的软链接
ln -s convert_office_batch.sh convert_all.sh
ln -s convert_wmf_to_png.py convert_wmf.py
# ... 其他链接操作
```

## 命名规范总结

- **前缀动词**: convert, extract, merge, list, manage, file
- **连接符**: 统一使用下划线 `_`
- **对象名**: 使用完整单词而非缩写
- **转换格式**: 使用 `from_to` 模式
- **描述性**: 文件名应该自解释功能

这样的命名规范既保持了一致性，又提高了可读性和可维护性。 