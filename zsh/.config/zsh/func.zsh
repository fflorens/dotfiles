# Reset kitty keyboard protocol after returning from a suspended job (e.g. vim bg'd).
# Without this, Ctrl+C prints "9;5u" and Escape prints "u".
function _reset_kbd() { printf '\e[<u' }
add-zsh-hook precmd _reset_kbd
