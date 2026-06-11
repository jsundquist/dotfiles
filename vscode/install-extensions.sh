#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v code &>/dev/null; then
    echo "Error: 'code' CLI not found. Install VSCode and add it to PATH."
    exit 1
fi

echo "==> Installing VSCode extensions..."
while IFS= read -r ext || [[ -n "$ext" ]]; do
    [[ -z "$ext" || "$ext" == \#* ]] && continue
    code --install-extension "$ext" --force
done < "$SCRIPT_DIR/extensions.txt"
echo "==> Done."
