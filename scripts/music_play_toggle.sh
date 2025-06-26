#!/bin/bash

# 检查 Music 应用是否正在运行
if pgrep -f "Music.app" > /dev/null; then
    echo "Music 应用正在运行，检查播放状态..."
    
    # 获取当前播放状态
    player_state=$(osascript -e 'tell application "Music" to return player state as string')
    
    if [ "$player_state" = "playing" ]; then
        echo "当前正在播放，暂停音乐..."
        osascript -e 'tell application "Music" to pause'
    else
        echo "当前已暂停，选择 Favourite Songs 播放列表并开始播放..."
        osascript -e '
        tell application "Music"
            play
        end tell'
    fi
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
fi 
