#!/bin/sh

# hash: {{ include "Brewfile" | sha256sum }}
brew bundle --file <<EOF
{{ include "Brewfile" }}
EOF
