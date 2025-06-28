#!/usr/bin/env python3
"""
CSV转TXT转换工具 - 将CSV文件转换为制表符分隔的TXT文件
版本: 2.0.0
作者: tianli
更新: 2024-01-01
"""

import sys
import csv
import argparse
from pathlib import Path
from typing import Optional, List

# 引入通用工具模块
from common_utils import (
    show_success, show_error, show_warning, show_info, show_processing,
    validate_input_file, check_file_extension, get_file_basename,
    ProgressTracker, fatal_error, check_python_packages,
    show_version_info, find_files_by_extension
)

# 脚本版本信息
SCRIPT_VERSION = "2.0.0"
SCRIPT_AUTHOR = "tianli"
SCRIPT_UPDATED = "2024-01-01"

def check_dependencies() -> bool:
    """检查依赖"""
    show_info("检查依赖项...")
    
    # CSV模块是Python标准库，无需额外检查
    show_success("依赖检查完成")
    return True

def convert_csv_to_txt_single(input_file: Path, output_file: Optional[Path] = None) -> bool:
    """将单个CSV文件转换为TXT格式"""
    try:
        # 验证输入文件
        if not validate_input_file(input_file):
            return False
        
        # 检查文件扩展名
        if not check_file_extension(input_file, 'csv'):
            show_warning(f"跳过不支持的文件: {input_file.name}")
            return False
        
        # 生成输出文件名
        if output_file is None:
            output_file = input_file.with_suffix('.txt')
        
        show_processing(f"转换: {input_file.name} -> {output_file.name}")
        
        # 执行转换
        with open(input_file, 'r', encoding='utf-8') as f_in, \
             open(output_file, 'w', encoding='utf-8') as f_out:
            reader = csv.reader(f_in)
            for row in reader:
                f_out.write('\t'.join(row) + '\n')
        
        show_success(f"转换完成: {output_file}")
        return True
        
    except Exception as e:
        show_error(f"转换失败: {input_file.name} - {e}")
        return False

def batch_process(directory: Path, recursive: bool = False) -> None:
    """批量处理CSV文件"""
    show_info(f"处理目录: {directory}")
    
    # 查找CSV文件
    files = find_files_by_extension(directory, 'csv', recursive)
    
    if not files:
        show_warning("未找到CSV文件")
        return
    
    show_info(f"找到 {len(files)} 个CSV文件")
    
    # 初始化进度跟踪器
    tracker = ProgressTracker()
    
    # 处理每个文件
    for i, file in enumerate(files, 1):
        show_progress(i, len(files), file.name)
        
        if convert_csv_to_txt_single(file):
            tracker.add_success()
        else:
            tracker.add_failure()
    
    # 显示统计
    tracker.show_summary("文件转换")

def show_version() -> None:
    """显示版本信息"""
    show_version_info(SCRIPT_VERSION, SCRIPT_AUTHOR, SCRIPT_UPDATED)

def show_help() -> None:
    """显示帮助信息"""
    print(f"""
CSV转TXT转换工具 - 将CSV文件转换为制表符分隔的TXT文件

用法:
    python3 {sys.argv[0]} [选项] [输入] [输出]

参数:
    输入            输入CSV文件或目录
    输出            输出TXT文件（可选，仅对单文件有效）

选项:
    -r, --recursive  递归处理子目录
    -h, --help       显示此帮助信息
    --version        显示版本信息

示例:
    python3 {sys.argv[0]} data.csv               # 转换单个文件
    python3 {sys.argv[0]} data.csv output.txt   # 指定输出文件
    python3 {sys.argv[0]} ./data_dir             # 批量转换目录
    python3 {sys.argv[0]} -r ./data_dir          # 递归转换目录

功能:
    - 将CSV文件转换为制表符分隔的TXT文件
    - 支持单文件和批量处理
    - 自动处理编码问题
    """)

def main():
    """主函数"""
    parser = argparse.ArgumentParser(
        description='CSV转TXT转换工具',
        add_help=False
    )
    
    parser.add_argument('input', nargs='?', help='输入CSV文件或目录')
    parser.add_argument('output', nargs='?', help='输出TXT文件')
    parser.add_argument('-r', '--recursive', action='store_true', help='递归处理子目录')
    parser.add_argument('-h', '--help', action='store_true', help='显示帮助信息')
    parser.add_argument('--version', action='store_true', help='显示版本信息')
    
    args = parser.parse_args()
    
    if args.help:
        show_help()
        return
    
    if args.version:
        show_version()
        return
    
    # 检查依赖
    if not check_dependencies():
        sys.exit(1)
    
    # 处理输入
    if not args.input:
        # 默认处理当前目录
        batch_process(Path.cwd())
    else:
        input_path = Path(args.input)
        
        if input_path.is_file():
            # 单文件处理
            output_path = None
            if args.output:
                output_path = Path(args.output)
            
            if not convert_csv_to_txt_single(input_path, output_path):
                sys.exit(1)
        elif input_path.is_dir():
            # 目录处理
            batch_process(input_path, args.recursive)
        else:
            fatal_error(f"输入路径不存在: {input_path}")

if __name__ == "__main__":
    main() 