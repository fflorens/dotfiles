#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Pulling latest personal dotfiles..."
git -C "$DOTFILES" pull --ff-only 2>/dev/null || echo "  (no remote configured yet, skipping pull)"

echo "Restowing personal dotfiles..."
"$DOTFILES/stow.sh"
