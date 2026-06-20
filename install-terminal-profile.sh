#!/usr/bin/env bash
set -e

PROFILE_PATH="$HOME/dotfiles/terminal/MyProfile.terminal"
PROFILE_NAME="MyProfile"

open "$PROFILE_PATH"

# Wait for Terminal to register the new settings set (up to 10s)
for i in {1..10}; do
    if osascript -e "tell application \"Terminal\" to get name of settings set \"$PROFILE_NAME\"" &>/dev/null 2>&1; then
        break
    fi
    sleep 1
done

osascript -e "
tell application \"Terminal\"
  set default settings to settings set \"$PROFILE_NAME\"
end tell"
