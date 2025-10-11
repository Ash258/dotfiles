#!/bin/sh

# exit immediately if password-manager-binary is already in $PATH
type op >/dev/null 2>&1 && exit

case "$(uname -s)" in
Darwin)
    if type brew >/dev/null 2>&1; then
        echo 'Installing brew'
        INTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh || true)" </dev/null ## /dev/null skips pressing enter for the installation
    fi
    brew install --casks "1password-cli" "1password@beta"
    echo 'Login to 1password and enable the CLI'
    ;;
Linux)
    # commands to install password-manager-binary on Linux
    # TODO: Implement based on arch/debian/containers
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
