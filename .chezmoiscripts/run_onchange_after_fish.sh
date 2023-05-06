#!/bin/bash
set -euo pipefail

if [[ -x /usr/local/bin/fish ]]; then
  chsh -s /usr/local/bin/fish
elif [[ -x /opt/homebrew/bin/fish ]]; then
  chsh -s /opt/homebrew/bin/fish
fi

fish -c "fisher install ilancosman/tide@v5"
