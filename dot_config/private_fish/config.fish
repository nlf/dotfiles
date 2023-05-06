set -gx SSH_AUTH_SOCK "$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
set -gx SHELL (status fish-path)

if status is-interactive
  set -gx CLICOLOR 1
end
