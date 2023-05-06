if test (which brew >/dev/null) $status -ne 0
  if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
  else if test -x /usr/local/bin/brew
    /usr/local/bin/brew shellenv | source
  else
    echo "Homebrew not found!"
    exit 1
  end
end

if test (which exa >/dev/null) $status -eq 0
  alias ls='exa -F --group-directories-first'
end

if test (which bat >/dev/null) $status -eq 0
  alias cat=bat
end

if test (which nvim >/dev/null) $status -eq 0
  alias vi=nvim
  alias vim=nvim
  set -gx EDITOR nvim
end

if test (which kitty >/dev/null) $status -eq 0
  alias ssh='kitty +kitten ssh'
end
