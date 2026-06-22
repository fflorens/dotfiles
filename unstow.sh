#!/bin/bash
DOTFILES="$(cd "$(dirname "$0")" && pwd)"
echo "Unstowing dotfiles..."
while IFS= read -r pkg || [ -n "$pkg" ]; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  stow --dir="$DOTFILES" --target="$HOME" -D "$pkg"
done < "$DOTFILES/packages"
