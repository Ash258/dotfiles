#!/usr/bin/env bash

# TODO: Support nu
dest="${HOME}/.zsh/fpath"
_SH='zsh'

function tc() {
    command -v "$1" &> /dev/null
}

function gen() {
    if ! tc "${1}"; then
        return
    fi

    echo "Generating completion for '${1}'"
    "$@" > "${dest}/_${1}.zsh"
}

gen task --completion "${_SH}"
gen xh --generate complete-"${_SH}"
gen ripgrep --generate complete-"${_SH}"
gen atuin gen-completions --shell "${_SH}"
gen doggo completions "${_SH}"
gen rclone completion "${_SH}" -

for tool in \
    "chezmoi" \
    "cosign" \
    "docker" \
    "helm" \
    "k6" \
    "kops" \
    "kubectl" \
    "limactl" \
    "mise" \
    "polaris" \
    "sops" \
    "step" \
    "usql" \
    "yq"; do
    gen "${tool}" completion "${_SH}"
done
