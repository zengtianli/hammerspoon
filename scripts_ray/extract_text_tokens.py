#!/usr/bin/env python3
"""
计算文件的 token 数量
安装: pip install tiktoken
"""

import tiktoken
import sys
import os

def count_tokens(text, model="gpt-3.5-turbo"):
    """计算文本的 token 数量"""
    encodings = {
        "gpt-4": "cl100k_base",
        "gpt-3.5-turbo": "cl100k_base",
        "text-davinci-003": "p50k_base",
        "text-davinci-002": "p50k_base",
        "davinci": "r50k_base",
    }
    
    encoding_name = encodings.get(model, "cl100k_base")
    encoding = tiktoken.get_encoding(encoding_name)
    
    num_tokens = len(encoding.encode(text))
    return num_tokens

def analyze_file(filename):
    """分析文件的 token 信息"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 计算各种模型的 token 数
        models = ["gpt-3.5-turbo", "gpt-4", "text-davinci-003"]
        
        print(f"\n📄 文件: {filename}")
        print(f"📏 大小: {os.path.getsize(filename) / 1024:.2f} KB")
        print(f"📝 字符数: {len(content):,}")
        print(f"📖 字数(估算): {len(content.split()):,}")
        print("\n🔢 Token 数量:")
        
        for model in models:
            tokens = count_tokens(content, model)
            print(f"  - {model}: {tokens:,} tokens")
            
    except Exception as e:
        print(f"❌ 错误: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("使用方法: python count_tokens.py <文件名>")
        sys.exit(1)
    
    analyze_file(sys.argv[1])

