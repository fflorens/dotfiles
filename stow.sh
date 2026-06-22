#!/bin/bash
DOTFILES="$(cd "$(dirname "$0")" && pwd)"
echo "Stowing dotfiles..."
while IFS= read -r pkg || [ -n "$pkg" ]; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  stow --dir="$DOTFILES" --target="$HOME" -R "$pkg"
done < "$DOTFILES/packages"
