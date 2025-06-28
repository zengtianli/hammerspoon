#!/bin/bash

# ====================================================
# pip_update.sh
# 自动更新所有已安装的pip包的脚本
# 适用于macOS
# ====================================================

# 设置终端颜色
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # 无颜色

# 显示标题
echo -e "${YELLOW}====================================${NC}"
echo -e "${YELLOW}    开始更新所有 Python 包    ${NC}"
echo -e "${YELLOW}====================================${NC}"

# 获取 Python 版本
PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}使用 ${PYTHON_VERSION}${NC}"

# 检查pip是否已安装
if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}错误: pip3 未安装。请先安装 pip。${NC}"
    exit 1
fi

# 更新 pip 本身
echo -e "\n${YELLOW}[1/3] 正在更新 pip 本身...${NC}"
python3 -m pip install --upgrade pip

# 检查上一个命令是否成功
if [ $? -ne 0 ]; then
    echo -e "${RED}更新 pip 失败，请检查网络连接或权限设置。${NC}"
    exit 1
fi

# 获取所有已安装的包列表
echo -e "\n${YELLOW}[2/3] 获取已安装的包列表...${NC}"
# 跳过标题行，只获取包名(第一列)
OUTDATED_PACKAGES=$(pip3 list --outdated | tail -n +3 | awk '{print $1}')

# 检查是否有可更新的包
if [ -z "$OUTDATED_PACKAGES" ]; then
    echo -e "${GREEN}太好了！所有包都是最新的。${NC}"
    echo -e "\n${GREEN}✅ 更新完成！${NC}"
    exit 0
fi

# 计算待更新的包数量
PACKAGE_COUNT=$(echo "$OUTDATED_PACKAGES" | wc -l | tr -d ' ')
echo -e "${YELLOW}发现 $PACKAGE_COUNT 个可更新的包${NC}"

# 更新所有过时的包
echo -e "\n${YELLOW}[3/3] 正在更新所有过时的包...${NC}"

# 设置计数器
UPDATED=0
FAILED=0

# 逐个更新包以便更好地显示进度和处理错误
for package in $OUTDATED_PACKAGES; do
    echo -e "\n${YELLOW}正在更新 ($((UPDATED+FAILED+1))/$PACKAGE_COUNT): $package ${NC}"
    if pip3 install --upgrade "$package"; then
        echo -e "${GREEN}✓ $package 更新成功${NC}"
        UPDATED=$((UPDATED+1))
    else
        echo -e "${RED}✗ $package 更新失败${NC}"
        FAILED=$((FAILED+1))
    fi
done

# 显示更新摘要
echo -e "\n${YELLOW}====================================${NC}"
echo -e "${YELLOW}           更新摘要           ${NC}"
echo -e "${YELLOW}====================================${NC}"
echo -e "${GREEN}成功更新: $UPDATED 个包${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}更新失败: $FAILED 个包${NC}"
fi

# 检查是否所有包都已更新
if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✅ 所有包都已更新成功！${NC}"
else
    echo -e "\n${YELLOW}⚠️ 部分包更新失败，请检查错误信息。${NC}"
fi

# 设置脚本执行权限
chmod +x "$0"

exit 0
