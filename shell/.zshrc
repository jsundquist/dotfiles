export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

DISABLE_MAGIC_FUNCTIONS=true

plugins=(git)

source $ZSH/oh-my-zsh.sh
unset zle_bracketed_paste

# Source dotfiles
[[ -f ~/.exports ]] && source ~/.exports
[[ -f ~/.aliases ]] && source ~/.aliases

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Local overrides: secrets and machine-specific settings (not tracked in git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
