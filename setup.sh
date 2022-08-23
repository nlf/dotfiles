#!/bin/bash
set -euo pipefail

# install homebrew
if ! which -s brew; then
  echo "> Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# activate homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! brew ls --versions chezmoi >/dev/null; then
  echo "> Installing chezmoi..."
  brew update >/dev/null 2>&1
  brew install chezmoi
fi

echo "> Applying chezmoi..."
chezmoi init --apply --verbose https://github.com/nlf/dotfiles.git
