#!/usr/bin/env python3
"""
Python脚本通用工具模块
版本: 2.0.0
适用于: execute目录下的所有Python脚本

提供统一的显示函数、文件操作、错误处理等功能
"""

import os
import sys
import shutil
import tempfile
from pathlib import Path
from typing import List, Optional, Union

# ===== 基础配置 =====

# Python路径配置
PYTHON_PATH = "/Users/tianli/miniforge3/bin/python3"
MINIFORGE_BIN = "/Users/tianli/miniforge3/bin"

# 目录路径配置
SCRIPTS_DIR = "/Users/tianli/useful_scripts/execute/scripts"
EXECUTE_DIR = "/Users/tianli/useful_scripts/execute"

# ===== 核心显示函数 =====

def show_success(message: str) -> None:
    """显示成功消息"""
    print(f"✅ {message}")

def show_error(message: str) -> None:
    """显示错误消息"""
    print(f"❌ {message}")

def show_warning(message: str) -> None:
    """显示警告消息"""
    print(f"⚠️ {message}")

def show_processing(message: str) -> None:
    """显示处理中消息"""
    print(f"🔄 {message}")

def show_info(message: str) -> None:
    """显示信息消息"""
    print(f"ℹ️ {message}")

def show_progress(current: int, total: Union[int, str], item: str = "项目") -> None:
    """显示进度"""
    if isinstance(total, int):
        percentage = (current * 100) // total
        show_processing(f"进度: {percentage}% ({current}/{total}) - {item}")
    else:
        show_processing(f"处理中 ({current}): {item}")

# ===== 文件操作函数 =====

def check_file_extension(file_path: Union[str, Path], expected_ext: str) -> bool:
    """检查文件扩展名"""
    file_path = Path(file_path)
    actual_ext = file_path.suffix.lower().lstrip('.')
    expected_ext = expected_ext.lower().lstrip('.')
    return actual_ext == expected_ext

def get_file_basename(file_path: Union[str, Path]) -> str:
    """获取文件基本名称（不含扩展名）"""
    return Path(file_path).stem

def get_file_extension(file_path: Union[str, Path]) -> str:
    """获取文件扩展名（小写）"""
    return Path(file_path).suffix.lower().lstrip('.')

def validate_file_path(path: Union[str, Path]) -> bool:
    """验证文件路径安全性"""
    path_str = str(path)
    if "../" in path_str or "|" in path_str or ";" in path_str:
        show_error(f"不安全的文件路径: {path}")
        return False
    return True

def validate_input_file(file_path: Union[str, Path]) -> bool:
    """验证输入文件"""
    file_path = Path(file_path)
    
    # 检查文件是否存在
    if not file_path.exists():
        show_error(f"文件不存在: {file_path}")
        return False
    
    # 检查是否为文件
    if not file_path.is_file():
        show_error(f"不是有效文件: {file_path}")
        return False
    
    # 检查文件是否可读
    if not os.access(file_path, os.R_OK):
        show_error(f"文件不可读: {file_path}")
        return False
    
    # 验证路径安全性
    return validate_file_path(file_path)

def check_file_size(file_path: Union[str, Path], max_size_mb: int = 100) -> bool:
    """检查文件大小"""
    file_path = Path(file_path)
    try:
        size_mb = file_path.stat().st_size / (1024 * 1024)
        
        if size_mb > max_size_mb:
            show_warning(f"文件较大 ({size_mb:.1f}MB)，处理可能需要较长时间")
            return False
        return True
    except Exception as e:
        show_error(f"无法获取文件大小: {file_path} - {e}")
        return False

# ===== 目录操作函数 =====

def ensure_directory(dir_path: Union[str, Path]) -> bool:
    """确保目录存在"""
    try:
        Path(dir_path).mkdir(parents=True, exist_ok=True)
        return True
    except Exception as e:
        show_error(f"无法创建目录: {dir_path} - {e}")
        return False

def safe_chdir(target_dir: Union[str, Path]) -> bool:
    """安全切换目录"""
    try:
        os.chdir(target_dir)
        return True
    except Exception as e:
        show_error(f"无法进入目录: {target_dir} - {e}")
        return False

# ===== 错误处理函数 =====

def fatal_error(message: str) -> None:
    """致命错误 - 立即退出"""
    show_error(message)
    sys.exit(1)

def recoverable_error(message: str) -> bool:
    """可恢复错误 - 记录但继续"""
    show_warning(message)
    return False

# ===== 命令检查函数 =====

def check_command_exists(command: str) -> bool:
    """检查命令是否存在"""
    if shutil.which(command) is None:
        show_error(f"{command} 未安装")
        return False
    return True

def check_python_packages(packages: List[str]) -> bool:
    """检查必需的Python包"""
    missing_packages = []
    
    for package in packages:
        try:
            __import__(package)
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        show_error(f"缺少Python包: {', '.join(missing_packages)}")
        show_info(f"请运行: pip install {' '.join(missing_packages)}")
        return False
    return True

# ===== 实用工具函数 =====

def create_temp_dir() -> Path:
    """创建临时目录"""
    return Path(tempfile.mkdtemp())

def cleanup_temp_dir(temp_dir: Union[str, Path]) -> None:
    """清理临时文件"""
    temp_dir = Path(temp_dir)
    if temp_dir.exists() and temp_dir.is_dir():
        shutil.rmtree(temp_dir)

def retry_operation(operation, max_attempts: int = 3, *args, **kwargs):
    """带重试机制的操作执行"""
    for attempt in range(1, max_attempts + 1):
        try:
            return operation(*args, **kwargs)
        except Exception as e:
            if attempt < max_attempts:
                show_warning(f"第 {attempt} 次尝试失败，正在重试...")
            else:
                show_error(f"操作失败，已重试 {max_attempts} 次: {e}")
                raise
    return None

# ===== 文件查找函数 =====

def find_files_by_extension(directory: Union[str, Path], 
                          extension: str, 
                          recursive: bool = False) -> List[Path]:
    """根据扩展名查找文件"""
    directory = Path(directory)
    extension = extension.lower().lstrip('.')
    
    if recursive:
        pattern = f"**/*.{extension}"
        files = list(directory.glob(pattern))
        # 也搜索大写扩展名
        files.extend(directory.glob(f"**/*.{extension.upper()}"))
    else:
        pattern = f"*.{extension}"
        files = list(directory.glob(pattern))
        # 也搜索大写扩展名
        files.extend(directory.glob(f"*.{extension.upper()}"))
    
    # 去重并排序
    return sorted(list(set(files)))

def count_files_by_extension(directory: Union[str, Path], 
                           extension: str, 
                           recursive: bool = False) -> int:
    """统计指定扩展名的文件数量"""
    return len(find_files_by_extension(directory, extension, recursive))

# ===== 版本和帮助函数 =====

def show_version_info(script_version: str = "未知", 
                     script_author: str = "未知", 
                     script_updated: str = "未知") -> None:
    """显示版本信息"""
    print(f"脚本版本: {script_version}")
    print(f"作者: {script_author}")
    print(f"更新日期: {script_updated}")

def show_help_header(script_name: str, script_desc: str) -> None:
    """显示帮助信息头部"""
    print(script_desc)
    print()
    print(f"用法: {script_name} [选项] [参数]")
    print()
    print("选项:")

def show_help_footer() -> None:
    """显示帮助信息尾部"""
    print("    -h, --help       显示此帮助信息")
    print("    --version        显示版本信息")
    print()

# ===== 编码检测函数 =====

def detect_file_encoding(file_path: Union[str, Path]) -> str:
    """检测文件编码"""
    try:
        import chardet
        file_path = Path(file_path)
        with open(file_path, 'rb') as f:
            raw_data = f.read()
        result = chardet.detect(raw_data)
        return result.get('encoding', 'utf-8')
    except ImportError:
        show_warning("chardet 包未安装，假设使用 utf-8 编码")
        return 'utf-8'
    except Exception as e:
        show_warning(f"编码检测失败: {e}，假设使用 utf-8 编码")
        return 'utf-8'

def read_file_with_encoding(file_path: Union[str, Path], 
                          encoding: Optional[str] = None) -> str:
    """读取文件并自动检测编码"""
    file_path = Path(file_path)
    
    if encoding is None:
        encoding = detect_file_encoding(file_path)
    
    try:
        with open(file_path, 'r', encoding=encoding) as f:
            return f.read()
    except UnicodeDecodeError:
        # 如果指定编码失败，尝试其他常见编码
        for fallback_encoding in ['utf-8', 'gbk', 'gb2312', 'latin1']:
            if fallback_encoding != encoding:
                try:
                    with open(file_path, 'r', encoding=fallback_encoding) as f:
                        show_warning(f"使用 {fallback_encoding} 编码读取文件: {file_path}")
                        return f.read()
                except UnicodeDecodeError:
                    continue
        
        fatal_error(f"无法读取文件，编码检测失败: {file_path}")

# ===== 进度统计类 =====

class ProgressTracker:
    """进度跟踪器"""
    
    def __init__(self):
        self.success_count = 0
        self.failed_count = 0
        self.skipped_count = 0
        self.total_count = 0
    
    def add_success(self):
        """添加成功计数"""
        self.success_count += 1
        self.total_count += 1
    
    def add_failure(self):
        """添加失败计数"""
        self.failed_count += 1
        self.total_count += 1
    
    def add_skip(self):
        """添加跳过计数"""
        self.skipped_count += 1
        self.total_count += 1
    
    def show_summary(self, operation_name: str = "处理"):
        """显示统计摘要"""
        print()
        show_info(f"{operation_name}完成")
        print(f"✅ 成功: {self.success_count} 个")
        if self.failed_count > 0:
            print(f"❌ 失败: {self.failed_count} 个")
        if self.skipped_count > 0:
            print(f"⚠️ 跳过: {self.skipped_count} 个")
        print(f"📊 总计: {self.total_count} 个")
        
        if self.total_count > 0:
            success_rate = (self.success_count * 100) // self.total_count
            print(f"📊 成功率: {success_rate}%") 