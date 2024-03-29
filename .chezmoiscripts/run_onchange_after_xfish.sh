#!/bin/bash
set -euo pipefail

if [[ "$(basename $(dscl . -read /Users/${USER} UserShell | cut -d' ' -f2))" != "fish" ]]; then
  if [[ -x /usr/local/bin/fish ]]; then
    echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
    chsh -s /usr/local/bin/fish
  elif [[ -x /opt/homebrew/bin/fish ]]; then
    echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
    chsh -s /opt/homebrew/bin/fish
  fi
fi

fish -c "fisher install ilancosman/tide@v5; set -U fish_greeting ''; fish_config theme save Nord"
