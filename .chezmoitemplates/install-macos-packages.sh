#!/bin/sh

brew bundle --file=/dev/stdin <<EOF
{{ template "Brewfile.tmpl" . }}
EOF
