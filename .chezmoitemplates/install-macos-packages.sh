#!/bin/sh

# hash: {{ include "Brewfile" | sha256sum }}
brew bundle --file=/dev/stdin <<EOF
{{ include "Brewfile" }}
EOF
