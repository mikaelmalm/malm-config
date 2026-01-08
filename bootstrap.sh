#!/bin/bash
set -e

# ==============================================================================
# CONFIG PATHS & VARS
# ==============================================================================
PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
OS="$(uname -s)"
DOTFILES_DIR="$( pwd )" # Assumes you run this from inside the repo

echo -e "\033[1;34m[INFO]\033[0m Detected OS: $OS"

# ==============================================================================
# 1. PACKAGE MANAGER & CORE INSTALLS
# ==============================================================================
install_core() {
    if [ "$OS" = "Darwin" ]; then
        if ! command -v brew &> /dev/null; then
            echo -e "\033[1;31m[ERR]\033[0m Homebrew not found. Install it first."
            exit 1
        fi
        echo " >> Installing core tools via Brew..."
        brew install stow git zsh starship ghostty fzf zoxide
    elif [ "$OS" = "Linux" ]; then
        # Check if Arch or Debian/Ubuntu based
        if [ -f /etc/arch-release ]; then
            echo " >> Installing core tools via Pacman..."
            sudo pacman -S --noconfirm stow git zsh starship fzf zoxide unzip curl
        else
            echo " >> Installing core tools via Apt..."
            sudo apt-get update
            sudo apt-get install -y stow git zsh fzf unzip curl
            # Install Starship manually on Ubuntu/Debian if not in repo
            if ! command -v starship &> /dev/null; then
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
            # Attempt to install zoxide (might fail on old apt, but okay)
            if ! command -v zoxide &> /dev/null; then
                 echo " >> Zoxide not found, attempting apt install..."
                 sudo apt-get install -y zoxide || echo " >> Zoxide apt install failed. Install manually."
            fi
        fi
    fi
}

install_core

# ==============================================================================
# 2. FONTS (JetBrainsMono Nerd Font)
# ==============================================================================
install_fonts() {
    echo -e "\033[1;34m[INFO]\033[0m Installing Fonts..."

    if [ "$OS" = "Darwin" ]; then
        # Check if cask exists (basic check), otherwise attempt install
        if brew list --cask | grep -q "font-jetbrains-mono-nerd-font"; then
            echo " >> JetBrainsMono Nerd Font already installed."
        else
            echo " >> Installing JetBrainsMono Nerd Font via Brew..."
            brew install --cask font-jetbrains-mono-nerd-font
        fi

    elif [ "$OS" = "Linux" ]; then
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"
        
        # Check if we already have it (simple filename check)
        if ls "$FONT_DIR"/JetBrainsMonoNerdFont-Regular.ttf 1> /dev/null 2>&1; then
             echo " >> JetBrainsMono Nerd Font appears to be installed."
        else
             echo " >> Downloading JetBrainsMono Nerd Font..."
             VERSION="v3.1.1"
             ZIP_FILE="JetBrainsMono.zip"
             URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}/${ZIP_FILE}"
             
             # Use a generic /tmp location
             curl -L "$URL" -o "/tmp/$ZIP_FILE"
             
             echo " >> Extracting..."
             unzip -o "/tmp/$ZIP_FILE" -d "$FONT_DIR"
             rm "/tmp/$ZIP_FILE"
             
             echo " >> Refreshing font cache..."
             # Check if fc-cache exists
             if command -v fc-cache &> /dev/null; then
                fc-cache -fv
             else
                echo -e "\033[1;33m[WARN]\033[0m fc-cache not found. You may need to restart or install fontconfig."
             fi
        fi
    fi
}

install_fonts

# ==============================================================================
# 2. ZSH PLUGINS (No Oh-My-Zsh bloat)
# ==============================================================================
echo -e "\033[1;34m[INFO]\033[0m Setting up Zsh plugins..."
mkdir -p "$PLUGIN_DIR"

declare -a PLUGINS=(
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-completions"
)

for repo in "${PLUGINS[@]}"; do
    plugin_name=$(basename "$repo")
    target="$PLUGIN_DIR/$plugin_name"
    
    if [ ! -d "$target" ]; then
        echo "   -> Cloning $plugin_name..."
        git clone --depth 1 "https://github.com/$repo.git" "$target"
    fi
done

# ==============================================================================
# 3. SYMLINKING (GNU STOW)
# ==============================================================================
echo -e "\033[1;34m[INFO]\033[0m Linking dotfiles..."

# Common packages for ALL systems
STOW_PACKAGES=( "zsh" "nvim" "git" "starship" )

# OS-Specific Logic
if [ "$OS" = "Darwin" ]; then
    # MAC: Use Ghostty
    STOW_PACKAGES+=( "ghostty" )
    echo " >> Mac detected: Linking Ghostty config."
else
    # LINUX/WSL: Use Alacritty
    STOW_PACKAGES+=( "alacritty" )
    echo " >> Linux detected: Linking Alacritty config."
fi

# Execution
for pkg in "${STOW_PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        stow -v -R -t "$HOME" "$pkg"
    else
        echo -e "\033[1;33m[WARN]\033[0m Folder '$pkg' not found. Skipping."
    fi
done

# ==============================================================================
# 4. POST-INSTALL MESSAGE
# ==============================================================================
echo -e "\n\033[1;32m[SUCCESS]\033[0m Done."
echo "Ensure your .zshrc has the following lines to load plugins & starship:"
echo "----------------------------------------------------------------------"
echo 'eval "$(starship init zsh)"'
echo 'eval "$(zoxide init zsh)"'
echo 'source <(fzf --zsh)'
echo "----------------------------------------------------------------------"