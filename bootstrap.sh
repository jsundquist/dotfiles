#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Bootstrapping new machine..."
echo ""

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Load Homebrew into this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "==> Homebrew already installed, updating..."
    brew update
fi

# Trust third-party taps so brew bundle runs non-interactively
echo ""
echo "==> Trusting third-party taps..."
brew tap --repair 2>/dev/null || true
for tap in elastic/tap hashicorp/tap; do
    brew trust "$tap" 2>/dev/null || true
done

# Install all packages from Brewfile
echo ""
echo "==> Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# Install VSCode extensions
if command -v code &>/dev/null; then
    echo ""
    "$DOTFILES_DIR/vscode/install-extensions.sh"
fi

# Install Oh My Zsh if not present
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo ""
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Create symlinks
echo ""
"$DOTFILES_DIR/install.sh"

echo ""
echo "==> Bootstrap complete!"
echo ""
echo "Remaining manual steps:"
echo "  1. Copy shell/.zshrc.local.example to ~/.zshrc.local and fill in secrets"
echo "  2. Set up SSH keys (see README.md)"
echo "  3. Authenticate GitHub CLI:  gh auth login"
echo "  4. Run macOS defaults:       bash .macos"
echo "  5. Restart your terminal"
