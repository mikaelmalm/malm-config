# malm-config

This repository contains my personal configuration files (dotfiles) for various applications and settings.

## Installation

I use a `bootstrap.sh` script to automate the setup process. This script handles:

1.  **Installing Dependencies**: `stow`, `git`, `zsh`, `starship`, `ghostty`/`alacritty`, `fzf`, `zoxide` (via Brew on Mac, Pacman/Apt on Linux).
2.  **Installing Fonts**: Downloads and installs JetBrainsMono Nerd Font.
3.  **Setting up Zsh Plugins**: Clones `autosuggestions`, `syntax-highlighting`, and `completions`.
4.  **Symlinking Configs**: Uses GNU Stow to link dotfiles to your home directory.

### Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/mikaelmalm/malm-config.git ~/code/malm-config

# 2. Enter directory
cd ~/code/malm-config

# 3. Run bootstrap
./bootstrap.sh
```

## Structure

Configuration files are organized into "packages" (folders) for GNU Stow.

- `zsh/`: `.zshrc` and zsh-related configs.
- `nvim/`: Neovim configuration (`init.lua`, etc).
- `git/`: Global `.gitconfig`.
- `starship/`: `starship.toml` prompt config.
- `ghostty/` (Mac): Ghostty terminal config.
- `alacritty/` (Linux): Alacritty terminal config.
