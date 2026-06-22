# Load homebrew shell variables
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$(brew --prefix rustup)/bin:$PATH"

# Force certain more-secure behaviours from homebrew
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS=--require-sha
export HOMEBREW_DIR=/opt/homebrew
export HOMEBREW_BIN=/opt/homebrew/bin

brew() {
  local priv_commands=("install" "upgrade" "link" "uninstall" "reinstall" "cask")

  # If the command matches and we aren't already admin...
  if [[ " ${priv_commands[*]} " == *" $1 "* ]]; then
    if ! /usr/bin/groups | grep -q -E "\b(admin|wheel)\b"; then
       /Applications/Privileges.app/Contents/MacOS/PrivilegesCLI -a
       # Optional: Add a small sleep to ensure the group membership propagates
       sleep 1
    fi
  fi

  # Run the actual brew command
  command brew "$@"
}
