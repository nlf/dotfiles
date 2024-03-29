#!/bin/bash
set -euo pipefail

platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

if [[ "$platform" == "darwin" ]]; then
  if ! defaults read net.kovidgoyal.kitty NSUserKeyEquivalents | grep -q 'Hide kitty'; then
    defaults write net.kovidgoyal.kitty NSUserKeyEquivalents -dict-add 'Hide kitty' '~^$\\U00a7'
  fi

  if ! defaults read net.kovidgoyal.kitty NSUserKeyEquivalents | grep -q 'Hide Others'; then
    defaults write net.kovidgoyal.kitty NSUserKeyEquivalents -dict-add 'Hide Others' '~^$\\U00a8'
  fi
fi
