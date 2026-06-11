# dotfiles

Personal dotfiles for macOS.

## New machine setup

### 0. Set up SSH (prerequisite)

```bash
# Generate a new key
ssh-keygen -t ed25519 -C "your@email.com"

# Copy the public key
cat ~/.ssh/id_ed25519.pub
```

Then add the public key to your [GitHub account](https://github.com/settings/keys).

### 1. Clone the repo

```bash
git clone git@github.com:jsundquist1/dotfiles.git ~/dotfiles
```

### 2. Run bootstrap

```bash
cd ~/dotfiles
bash bootstrap.sh
```

This installs Homebrew, all packages from `Brewfile`, Oh My Zsh, and creates all symlinks.

### 3. Set up secrets

```bash
cp ~/dotfiles/shell/.zshrc.local.example ~/.zshrc.local
# Edit ~/.zshrc.local and fill in your actual tokens/values
```

### 4. Authenticate tools

```bash
gh auth login    # GitHub CLI (choose SSH when prompted)
```

### 5. Apply macOS defaults (optional, restart required)

```bash
bash ~/dotfiles/.macos
```

---

## What's tracked

| Path | Source |
|---|---|
| `~/.zshrc` | `shell/.zshrc` |
| `~/.zprofile` | `shell/.zprofile` |
| `~/.exports` | `shell/.exports` |
| `~/.aliases` | `shell/.aliases` |
| `~/.gitconfig` | `git/.gitconfig` |
| `~/.gitignore_global` | `git/.gitignore_global` |
| `~/.npmrc` | `misc/.npmrc` |
| `~/.ssh/config` | `ssh/config` |
| `~/.config/gh/config.yml` | `config/gh/config.yml` |

## What's NOT tracked

- `~/.zshrc.local` — secrets and machine-specific settings. See `shell/.zshrc.local.example`.
- `~/.ssh/*.pem`, `~/.ssh/id_*` — SSH private and public keys
- `~/.aws/` — AWS credentials
- `~/.netrc` — stored credentials

---

## Adding a new dotfile

1. Move the file into the appropriate directory in `~/dotfiles/`
2. Add a `symlink` line to `install.sh`
3. Run `install.sh` to create the symlink
4. Commit

## Updating packages

```bash
# Add a new package to Brewfile, then:
brew bundle --file=~/dotfiles/Brewfile

# Or to snapshot current state:
brew bundle dump --file=~/dotfiles/Brewfile --force
```
