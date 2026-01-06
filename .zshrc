# --- ENVIROMENT ---
export EDITOR='nano' # Change to nvim if you aren't a coward
export PATH=$HOME/bin:/usr/local/bin:$PATH

# --- PLUGINS (Manual & Fast) ---
# We use the system-installed fzf and zoxide
source <(fzf --zsh)
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# --- KEYBINDINGS ---
bindkey -e # Emacs mode because we aren't savages
bindkey '^[[A' up-line-or-search # Up arrow searches history
bindkey '^[[B' down-line-or-search

# --- ALIASES (The Git & Nav shortcuts) ---
# Git - Fast and dirty
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --all'
alias gd='git diff'
alias gco='git checkout'
alias ggpush='git push origin'
alias ggpull='git pull origin'

# Navigation & UI
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --grid'
alias la='eza -lah --icons'
alias cat='bat --paging=never'
alias ..='cd ..'
alias ...='cd ../..'

# Personal touches
alias ag="antigravity"
alias reload="source ~/.zshrc"

# --- FUZZY FUNCTIONS ---
# Fast directory jump with fzf + zoxide
unalias zi 2>/dev/null
zi() {
  result=$(zoxide query -l | fzf --height 40% --reverse --header="Jump to:")
  [ -n "$result" ] && cd "$result"
}

# Search through command history with fzf and execute
fh() {
  eval $(history | fzf +s --tac | sed 's/^[ ]*[0-9]*[ ]*//')
}

# --- COMPLETION SYSTEM ---
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # Case insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Colors in completion

# bun completions
[ -s "/home/malm/.bun/_bun" ] && source "/home/malm/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
