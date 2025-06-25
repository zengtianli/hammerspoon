for app in "Finder" "Reminders" "Notes" "Arc"; do
  for window_id in $(yabai -m query --windows | jq -r ".[] | select(.app == \"$app\") | .id"); do
    first_space_id=$(yabai -m query --displays --display 1 | jq -r '.spaces[0]')
    yabai -m window "$window_id" --space "$first_space_id"
		yabai -m window "$window_id" --focus
  done
done

for app in "Warp" "QSpace Pro"; do
  for window_id in $(yabai -m query --windows | jq -r ".[] | select(.app == \"$app\") | .id"); do
    first_space_id=$(yabai -m query --displays --display 2 | jq -r '.spaces[0]')
    yabai -m window "$window_id" --space "$first_space_id"
		yabai -m window "$window_id" --focus
  done
done

for app in "Music" "DingTalk" "WeChat" "Messages"; do
  for window_id in $(yabai -m query --windows | jq -r ".[] | select(.app == \"$app\") | .id"); do
    first_space_id=$(yabai -m query --displays --display 3 | jq -r '.spaces[0]')
    yabai -m window "$window_id" --space "$first_space_id"
		yabai -m window "$window_id" --focus
  done
done

