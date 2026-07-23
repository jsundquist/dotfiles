#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

symlink() {
    local src="$1"
    local dst="$2"

    mkdir -p "$(dirname "$dst")"

    if [[ -e "$dst" && ! -L "$dst" ]]; then
        echo "  Backing up: $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi

    ln -sf "$src" "$dst"
    echo "  Linked: $dst"
}

echo "==> Installing dotfiles from $DOTFILES_DIR"
echo ""

# Shell
symlink "$DOTFILES_DIR/shell/.zshrc"            "$HOME/.zshrc"
symlink "$DOTFILES_DIR/shell/.zprofile"         "$HOME/.zprofile"
symlink "$DOTFILES_DIR/shell/.exports"          "$HOME/.exports"
symlink "$DOTFILES_DIR/shell/.aliases"          "$HOME/.aliases"
symlink "$DOTFILES_DIR/shell/.zshrc.local"      "$HOME/.zshrc.local"

# Git
symlink "$DOTFILES_DIR/git/.gitconfig"          "$HOME/.gitconfig"
symlink "$DOTFILES_DIR/git/.gitignore_global"   "$HOME/.gitignore_global"

# Misc
symlink "$DOTFILES_DIR/misc/.npmrc"             "$HOME/.npmrc"

# SSH (config only — never commit private keys)
symlink "$DOTFILES_DIR/ssh/config"              "$HOME/.ssh/config"

# Apps
symlink "$DOTFILES_DIR/config/gh/config.yml"   "$HOME/.config/gh/config.yml"

# Claude
for src in "$DOTFILES_DIR/.claude/"*; do
    symlink "$src" "$HOME/.claude/$(basename "$src")"
done

# VSCode
symlink "$DOTFILES_DIR/vscode/settings.json"   "$HOME/Library/Application Support/Code/User/settings.json"

# Git hooks directory (referenced in .gitconfig)
mkdir -p "$HOME/.git-hooks"

echo ""
echo "==> Done."
echo ""
echo "Next steps:"
echo "  1. Copy shell/.zshrc.local.example to ~/.zshrc.local and fill in secrets"
echo "  2. Reload your shell:  source ~/.zshrc"
