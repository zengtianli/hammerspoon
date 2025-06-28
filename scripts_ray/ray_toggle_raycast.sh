#!/bin/sh

if pgrep -q "Raycast"; then
  osascript -e 'quit app "Raycast"'
else
  open -a "Raycast"
fi
