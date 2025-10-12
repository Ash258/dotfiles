#!/bin/sh

#region functions
mac() {
    echo 'Configuring macOS'
}

arch() {
    # ! TODO: Consolidate with macos in .install-password-manager.sh
    echo 'Configuring Arch Linux'
    echo '    Installing 1password-cli'
    base='https://downloads.1password.com/linux'
    f='support@1password.com-61ddfc31.rsa.pub'
    echo "${base}/alpinelinux/stable/" | sudo tee -a "/etc/apk/repositories"
    dl "${base}/keys/alpinelinux/${f}" | sudo tee "/etc/apk/keys/${f}"
    sudo apk update
    sudo apk add 1password-cli
}

debian() {
    echo 'Configuring Debian-based Linux'
}

fail() {
    echo "Error: ${1}"
    exit 1
}

linux() {
    # TODO: Detect and implement based on arch/debian/containers
    if [ -f /etc/os-release ]; then
        distro=$(grep '^ID=' /etc/os-release | sed 's/ID=//g')
        case "${distro}" in
            arch|alpine) arch ;;
            # debian|ubuntu|linuxmint) debian ;;
            *) fail "unsupported Linux distribution: ${distro}" ;;
        esac
    else
        # TODO: Implement some dpkg/rmp/apk based detection
        fail "unsupported Linux distribution"
    fi
}

dl() {
    if [ "${use_curl}" = true ]; then
        curl -fsSL "${1}"
    else
        wget -qO- "${1}"
    fi
}
#endregion functions

#region main
email="${1:-jakub.cabera@outlook.com}"
use_curl=$(type curl >/dev/null 2>&1 && echo true || echo false)

echo 'Installing chezmoi'
dl "https://get.chezmoi.io" | sh -s

echo 'Initializing chezmoi'
~/bin/chezmoi init ash258

echo 'Creating chezmoi config'
mkdir -p "${HOME}/.config/chezmoi"
cat <<EOT > "${HOME}/.config/chezmoi/chezmoi.toml"
encryption = "age"

[age]
identity = '~/identity.txt'
recipients = "age1l0e9ted62t864dcf0f5x58rcawwq2prmvs89l9wsyqqz5zxpmelsqh289t"

[hooks.read-source-state.pre]
command = ".local/share/chezmoi/.install-password-manager.sh"

[data]
email = "${email}"
EOT

case "$(uname -s)" in
Darwin) mac ;;
Linux) linux ;;
*) fail "unsupported OS" ;;
esac
#endregion main
