#!/usr/bin/env python3
"""
WMF 转换工具 - 使用 LibreOffice 转换 WMF 文件为 PNG
版本: 2.0.0
作者: tianli
更新: 2024-01-01
"""

import subprocess
import sys
from pathlib import Path
from typing import List, Optional

# 脚本版本信息
SCRIPT_VERSION = "2.0.0"
SCRIPT_AUTHOR = "tianli"
SCRIPT_UPDATED = "2024-01-01"

# LibreOffice 路径
SOFFICE_PATH = "/Applications/LibreOffice.app/Contents/MacOS/soffice"

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

def show_progress(current: int, total: int, item: str = "文件") -> None:
    """显示进度"""
    percentage = (current * 100) // total
    print(f"🔄 处理中 ({current}/{total} - {percentage}%): {item}")

def validate_file_path(file_path: Path) -> bool:
    """验证文件路径安全性"""
    try:
        # 解析路径，检查是否包含危险字符
        resolved_path = file_path.resolve()
        if ".." in str(resolved_path) or "|" in str(resolved_path):
            show_error(f"不安全的文件路径: {file_path}")
            return False
        return True
    except Exception as e:
        show_error(f"路径验证失败: {file_path} - {e}")
        return False

def validate_input_file(file_path: Path) -> bool:
    """验证输入文件"""
    # 检查文件是否存在
    if not file_path.exists():
        show_error(f"文件不存在: {file_path}")
        return False
    
    # 检查文件是否可读
    if not file_path.is_file():
        show_error(f"不是有效文件: {file_path}")
        return False
    
    # 验证路径安全性
    if not validate_file_path(file_path):
        return False
    
    return True

def check_libreoffice() -> bool:
    """检查 LibreOffice 是否可用"""
    if not Path(SOFFICE_PATH).exists():
        show_error("未找到 LibreOffice")
        show_info("请安装 LibreOffice: https://www.libreoffice.org/download/")
        return False
    return True

def convert_single_wmf(wmf_file: Path, output_dir: Optional[Path] = None) -> bool:
    """转换单个 WMF 文件"""
    try:
        # 验证输入文件
        if not validate_input_file(wmf_file):
            return False
        
        # 确定输出目录
        if output_dir is None:
            output_dir = wmf_file.parent
        else:
            output_dir.mkdir(parents=True, exist_ok=True)
        
        # 构建命令
        cmd = [
            SOFFICE_PATH,
            "--headless",
            "--convert-to", "png",
            "--outdir", str(output_dir),
            str(wmf_file)
        ]
        
        # 执行转换
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            output_file = output_dir / f"{wmf_file.stem}.png"
            if output_file.exists():
                show_success(f"转换成功: {wmf_file.name} → {output_file.name}")
                return True
            else:
                show_warning(f"转换完成但未找到输出文件: {wmf_file.name}")
                return False
        else:
            show_error(f"转换失败: {wmf_file.name}")
            if result.stderr:
                show_error(f"错误详情: {result.stderr.strip()}")
            return False
            
    except subprocess.TimeoutExpired:
        show_error(f"转换超时: {wmf_file.name}")
        return False
    except Exception as e:
        show_error(f"处理失败: {wmf_file.name} - {e}")
        return False

def find_wmf_files(directory: Path = None) -> List[Path]:
    """查找 WMF 文件"""
    if directory is None:
        directory = Path.cwd()
    
    try:
        wmf_files = list(directory.glob("*.wmf"))
        wmf_files.extend(directory.glob("*.WMF"))  # 大写扩展名
        
        # 去重并排序
        wmf_files = sorted(list(set(wmf_files)))
        
        return wmf_files
    except Exception as e:
        show_error(f"搜索 WMF 文件失败: {e}")
        return []

def convert_wmf_with_libreoffice(input_dir: Optional[Path] = None, 
                                output_dir: Optional[Path] = None) -> None:
    """使用 LibreOffice 转换 WMF 到 PNG"""
    
    # 检查 LibreOffice
    if not check_libreoffice():
        sys.exit(1)
    
    # 确定输入目录
    if input_dir is None:
        input_dir = Path.cwd()
    
    show_info(f"正在搜索 WMF 文件: {input_dir}")
    
    # 查找 WMF 文件
    wmf_files = find_wmf_files(input_dir)
    
    if not wmf_files:
        show_warning("未找到 WMF 文件")
        return
    
    show_info(f"找到 {len(wmf_files)} 个 WMF 文件")
    
    # 统计转换结果
    success_count = 0
    failed_count = 0
    
    # 转换每个文件
    for i, wmf_file in enumerate(wmf_files, 1):
        show_progress(i, len(wmf_files), wmf_file.name)
        
        if convert_single_wmf(wmf_file, output_dir):
            success_count += 1
        else:
            failed_count += 1
    
    # 显示转换统计
    print("\n" + "="*50)
    show_info(f"转换完成!")
    print(f"✅ 成功转换: {success_count} 个文件")
    if failed_count > 0:
        print(f"❌ 转换失败: {failed_count} 个文件")
    print(f"📊 成功率: {(success_count * 100) // len(wmf_files)}%")

def show_version() -> None:
    """显示版本信息"""
    print(f"WMF 转换工具 v{SCRIPT_VERSION}")
    print(f"作者: {SCRIPT_AUTHOR}")
    print(f"更新日期: {SCRIPT_UPDATED}")

def show_help() -> None:
    """显示帮助信息"""
    print("""
WMF 转换工具 - 使用 LibreOffice 转换 WMF 文件为 PNG

用法:
    python3 convert_wmf.py [选项] [输入目录] [输出目录]

参数:
    输入目录    要搜索 WMF 文件的目录（默认：当前目录）
    输出目录    PNG 文件的输出目录（默认：与输入文件相同目录）

选项:
    -h, --help      显示此帮助信息
    -v, --version   显示版本信息

示例:
    python3 convert_wmf.py                    # 转换当前目录的所有 WMF 文件
    python3 convert_wmf.py ./images           # 转换指定目录的 WMF 文件
    python3 convert_wmf.py ./images ./output  # 转换并保存到指定输出目录

依赖:
    - LibreOffice (macOS Application)
    """)

def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="WMF 转换工具 - 使用 LibreOffice 转换 WMF 文件为 PNG",
        add_help=False
    )
    
    parser.add_argument('input_dir', nargs='?', type=Path, 
                       help='输入目录（默认：当前目录）')
    parser.add_argument('output_dir', nargs='?', type=Path, 
                       help='输出目录（默认：与输入文件相同目录）')
    parser.add_argument('-h', '--help', action='store_true', 
                       help='显示帮助信息')
    parser.add_argument('-v', '--version', action='store_true', 
                       help='显示版本信息')
    
    args = parser.parse_args()
    
    if args.help:
        show_help()
        return
    
    if args.version:
        show_version()
        return
    
    try:
        convert_wmf_with_libreoffice(args.input_dir, args.output_dir)
    except KeyboardInterrupt:
        show_warning("用户中断操作")
        sys.exit(1)
    except Exception as e:
        show_error(f"程序执行失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
