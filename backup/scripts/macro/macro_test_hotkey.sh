#!/bin/bash

# 宏播放测试脚本 - 通过Hammerspoon命令行调用
echo "🎬 通过Hammerspoon命令行调用宏播放功能..."

hs -c "require('lua1.app_controls').macro_play()"

echo "✅ 调用完成" 