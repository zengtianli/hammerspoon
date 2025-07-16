#!/bin/bash

# 检查 Music 应用是否正在运行
if pgrep -f "Music.app" > /dev/null; then
    echo "Music 应用正在运行，播放上一首..."
    
    # 播放上一首歌曲
    osascript -e 'tell application "Music" to previous track'
    echo "已切换到上一首歌曲"
else
    echo "Music 应用未运行，正在启动并播放 Favourite Songs..."
    # 打开 Music 应用并播放 Favourite Songs 播放列表
    osascript -e '
    tell application "Music"
        activate
        delay 2
        try
            set favouritePlaylist to playlist "Favourite Songs"
            play favouritePlaylist
        on error
            -- 如果找不到 Favourite Songs 播放列表，就正常播放
            play
        end try
    end tell'
    echo "Music 应用已启动并播放 Favourite Songs"
fi 