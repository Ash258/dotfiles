# Personal dotfiles

## Initial setup

1. `xcode-select --install`
1. Use setup:
   1. `curl -fsSLo- https://raw.githubusercontent.com/Ash258/dotfiles/refs/heads/main/setup.sh | sh -s -- '<email>'`
   1. `wget -qO- https://raw.githubusercontent.com/Ash258/dotfiles/refs/heads/main/setup.sh | sh -s -- '<email>'`
1. Login to 1password using QR code
   1. Get identity file using `op`
1. `bin/chezmoi apply`
