#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Updating dotfiles..."
echo ""

# Pull latest changes from remote
echo "==> Pulling latest changes..."
git -C "$DOTFILES_DIR" pull

# Sync Brewfile with currently installed packages (excluding VSCode extensions)
echo ""
echo "==> Syncing Brewfile..."
brew bundle dump --file="$DOTFILES_DIR/Brewfile" --force
sed -i '' '/^vscode /d' "$DOTFILES_DIR/Brewfile"

# Install anything in Brewfile not yet on this machine
echo ""
echo "==> Installing missing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# Sync VSCode extensions list
if command -v code &>/dev/null; then
    echo ""
    echo "==> Syncing VSCode extensions..."
    code --list-extensions > "$DOTFILES_DIR/vscode/extensions.txt"
fi

# Commit and push if anything changed
if ! git -C "$DOTFILES_DIR" diff --quiet Brewfile vscode/extensions.txt; then
    echo ""
    echo "==> Changes detected, committing..."
    git -C "$DOTFILES_DIR" add Brewfile vscode/extensions.txt
    git -C "$DOTFILES_DIR" commit -m "update Brewfile and VSCode extensions"
    git -C "$DOTFILES_DIR" push
else
    echo ""
    echo "==> Nothing changed, nothing to commit."
fi

echo ""
echo "==> Done."
