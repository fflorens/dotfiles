# Prefer GNU binaries to Macintosh binaries.
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# Point GOPATH to our go sources
export GOPATH="$HOME/go"

# Add binaries that are go install-ed to PATH
export PATH="$GOPATH/bin:$PATH"

# Created by `pipx` on 2026-02-10 15:48:38
export PATH="/Users/florian.florensa/.local/bin:$PATH"

# Add binaries from cargo bin
export PATH="$HOME/.cargo/bin/:$PATH"
