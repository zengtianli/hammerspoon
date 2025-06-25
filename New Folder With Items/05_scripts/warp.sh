#!/usr/bin/env bash
current_space_index=$(yabai -m query --spaces --space mouse | jq -r .index)
# Activate Warp and create a new window
osascript -e 'tell application "Warp" to activate' -e 'tell application "System Events" to keystroke "n" using {command down}'
# Wait for a short time to ensure the new window is created
sleep 0.1
# Get the current space index
# Get the Warp window ID
warp_window_id=$(yabai -m query --windows --window | jq -r '.id')
# Move the Warp window to the current space
yabai -m window --space $current_space_index $warp_window_id
# Focus the current space
yabai -m space --focus $current_space_index
# Apply the toggle-display-center-floating-tiling script to the Warp window
source ~/.config/yabai/toggle-display-center-floating-tiling.sh
