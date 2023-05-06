#!/bin/bash
set -euo pipefail

platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

if [[ "$platform" == "darwin" ]]; then
  ## touchid support for sudo
  if ls /usr/lib/pam/pam_tid.so* >/dev/null 2>&1; then
    if ! grep -q pam_tid.so /etc/pam.d/sudo; then
      firstline="# sudo: auth account password session"
      newline="auth       sufficient     pam_tid.so"
      sudo --reset-timestamp
      sudo sed -i .bak -e "s/${firstline}/${firstline}\n${newline}/" /etc/pam.d/sudo
      sudo rm /etc/pam.d/sudo.bak
      unset firstline
      unset newline
    fi
  fi

  ## make sure disk encryption is on
  if ! fdesetup status | grep -q -E 'FileVault is (On|Off, but will be enabled after the next restart).'; then
    sudo fdesetup enable -user "$USER" | tee "${HOME}/Desktop/FileVault Recovery Key.txt"
  fi

  ## helper for changing plist settings
  _defaults_write() {
    set +e
    local domain=$1
    local key=$2
    local kind=$3
    local value=$4

    local needsupdate=0
    local actual=$(defaults read $domain $key || echo "UNSET")
    if [[ $kind == "-bool" ]]; then
      local expected
      [[ $value == "true" ]] && expected=1 || expected=0
      [[ $actual -ne $expected ]] && needsupdate=1
    else
      [[ "$actual" != "$value" ]] && needsupdate=1
    fi

    if [[ $needsupdate -eq 1 ]]; then
      local result
      defaults write $domain $key $kind $value
      result=$?
      set -e
      [[ $result -ne 0 ]] && return $result
      return -1
    fi

    set -e
    return 0
  }

  ## enable firewall
  # _defaults_write /Library/Preferences/com.apple.alf globalstate -int 1
  # if [[ $? -eq -1 ]]; then
  #   sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
  # fi

  ## configure screensaver to ask for password immediately
  _defaults_write com.apple.screensaver askForPassword -int 1
  # _defaults_write com.apple.screensaver askForPasswordDelay -int 1

  ## configure bottom left corner to start the screensaver
  _defaults_write com.apple.dock wvous-bl-corner -int 5
  _defaults_write com.apple.dock wvous-bl-modifier -int 0

  ## set clock to digital
  # _defaults_write com.apple.menuextra.clock IsAnalog -bool false

  ## hide date
  _defaults_write com.apple.menuextra.clock ShowDate -int 2
  _defaults_write com.apple.menuextra.clock ShowDayOfMonth -int 0
  _defaults_write com.apple.menuextra.clock ShowDayOfWeek -int 0

  ## dark mode
  _defaults_write -globalDomain AppleInterfaceStyle -string Dark

  ## disable auto capitalization and other spelling magic
  _defaults_write -globalDomain NSAutomaticCapitalizationEnabled -int 0
  _defaults_write -globalDomain NSAutomaticDashSubstituionEnabled -int 0
  _defaults_write -globalDomain NSAutomaticPeriodSubstitutionEnabled -int 0
  _defaults_write -globalDomain NSAutomaticQuoteSubstitutionEnabled -int 0
  _defaults_write -globalDomain NSAutomaticSpellingCorrectionEnabled -int 0
  _defaults_write -globalDomain WebAutomaticSpellingCorrectionEnabled -int 0

  ## touchpad settings (tap to click)
  _defaults_write com.apple.AppleMultitouchTrackpad Clicking -int 1
  _defaults_write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 2
  _defaults_write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 2

  ## dock settings
  _defaults_write com.apple.dock autohide -int 1
  _defaults_write com.apple.dock mineffect -string scale
  _defaults_write com.apple.dock minimize-to-application -int 1
  _defaults_write com.apple.dock show-recents -int 0
  _defaults_write com.apple.dock tilesize -int 44

  ## finder open home
  _defaults_write com.apple.finder NewWindowTarget -string PfHm
  _defaults_write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

  ## safari
  _defaults_write com.apple.Safari UniversalSearchEnabled -bool false
  _defaults_write com.apple.Safari SuppressSearchSuggestions -bool true
  _defaults_write com.apple.Safari AutoOpenSafeDownloads -bool false

  unset _defaults_write
fi
