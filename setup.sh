#!/bin/sh

email="${1:-jakub.cabera@outlook.com}"

echo 'Installing chezmoi'
sh -c "$(curl -fsLS get.chezmoi.io || true)"

echo 'Initializing chezmoi'
~/bin/chezmoi init ash258

echo 'Creating chezmoi config'
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

mac() {
    echo 'Configuring macOS'
    # TODO: Test if xcode-select --install is good idea
    # xcode-select --install
}

arch() {
    echo 'Configuring Arch Linux'
}

debian() {
    echo 'Configuring Debian-based Linux'
}

case "$(uname -s)" in
Darwin)
    mac
    ;;
Linux)
    # TODO: Detect and implement based on arch/debian/containers
    arch
    debin
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
