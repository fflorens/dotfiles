#!/bin/bash

echo "Installing Dependencies"

# Install xCode cli tools
echo "Installing commandline tools..."
xcode-select --install

# Fonts
HOMEBREW_CASK_OPTS="" brew install --cask sf-symbols
HOMEBREW_CASK_OPTS="" brew install font-sf-mono font-sf-pro
brew install --cask font-hack-nerd-font
brew install --cask font-fira-code-nerd-font


brew install stow

brew install sleepwatcher

# Build and install brightness
echo "Building brightness..."
mkdir -p "$HOME/.local/bin"
cc -target arm64-apple-macos11 \
  -framework IOKit \
  -framework ApplicationServices \
  -framework CoreDisplay \
  -F /System/Library/PrivateFrameworks \
  -framework DisplayServices \
  -Wl,-U,_CoreDisplay_Display_SetUserBrightness \
  -Wl,-U,_CoreDisplay_Display_GetUserBrightness \
  -Wl,-U,_DisplayServicesCanChangeBrightness \
  -Wl,-U,_DisplayServicesBrightnessChanged \
  -Wl,-U,_DisplayServicesGetBrightness \
  -Wl,-U,_DisplayServicesSetBrightness \
  "$(dirname "$0")/sleepwatcher/brightness.c" -o "$HOME/.local/bin/brightness"
chmod 0755 "$HOME/.local/bin/brightness"

brew tap nikitabobko/tap
brew trust --formula nikitabobko/tap/aerospace
brew install --cask nikitabobko/tap/aerospace

brew tap FelixKratz/formulae
brew trust --formula felixkratz/formulae/borders felixkratz/formulae/sketchybar
brew install sketchybar
brew install borders

brew install switchaudio-osx
brew install --cask ghostty

# Essentials
brew install lua luarocks
brew install wget
brew install jq
brew install fzf

# Nice to have
brew install --cask btop
brew install nowplaying-cli
brew install background-music
brew install htop
brew install pyenv rbenv direnv

# Terminal
brew install neovim ripgrep


curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.25/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

# SbarLua
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

# Stow dotfiles
echo "Stowing dotfiles..."
DOTFILES="$(dirname "$0")"
${DOTFILES}/stow.sh

# Start Services
echo "Starting Services (grant permissions)..."
brew services start sketchybar
brew services start borders
