#!/usr/bin/env bash

dest="${HOME}/.zsh/plugins"
test -d "${dest}" || mkdir -p "${dest}"

for repo in "zsh-syntax-highlighting" "zsh-autosuggestions" "zsh-history-substring-search"; do
    if [[ -d "${dest}/${repo}" ]]; then
        git -C "${dest}/${repo}" pull --ff-only
    else
        git clone "https://github.com/zsh-users/${repo}.git" "${dest}/${repo}"
    fi
done
