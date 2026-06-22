source $HOME/.config/zsh/brew.zsh
source $HOME/.config/zsh/env.zsh
source $HOME/.config/zsh/completion.zsh
source $HOME/.config/zsh/path.zsh
source $HOME/.config/zsh/docker.zsh
source $HOME/.config/zsh/alias.zsh
source $HOME/.config/zsh/func.zsh

# Work-specific configs dropped in by work stow
for f in $HOME/.config/zsh/local/*.zsh(N); do source "$f"; done
