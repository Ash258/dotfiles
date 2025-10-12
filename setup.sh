#!/bin/sh

#region functions
mac() {
    echo 'Configuring macOS'
}

arch() {
    # ! TODO: Consolidate with macos in .install-password-manager.sh
    echo 'Configuring Arch Linux'
    sudo apk update
    sudo apk add curl git
    echo '    Installing 1password-cli'
    # https://developer.1password.com/docs/cli/install-server
    ARCH="$(uname -m | sed 's/^aarch/arm/g')"
    OP_VERSION="v$(dl 'https://app-updates.agilebits.com/check/1/0/CLI2/en/2.0.0/N' | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"
    curl -fsSLo op.zip "https://cache.agilebits.com/dist/1P/op2/pkg/${OP_VERSION}/op_linux_${ARCH}_${OP_VERSION}.zip"
    sudo unzip -od /usr/local/bin/ op.zip
    rm op.zip
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
branch="${CH_BRANCH:-main}"
email="${CH_EMAIL:-jakub.cabera@outlook.com}"
email="${1:-${email}}"
use_curl=$(type curl >/dev/null 2>&1 && echo true || echo false)

echo 'Installing chezmoi'
dl "https://get.chezmoi.io" | sh -s

echo 'Initializing chezmoi'
~/bin/chezmoi init ash258 --branch "${branch}"

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
