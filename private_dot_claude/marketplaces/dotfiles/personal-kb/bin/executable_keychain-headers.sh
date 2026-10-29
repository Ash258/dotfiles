#!/bin/zsh
# MCP headersHelper: prints the Authorization header for a personal-kb MCP server.
#
# The token comes from macOS Keychain, seeded from 1Password by chezmoi
# (.chezmoiscripts/run_onchange_after_seed-mcp-keychain.sh.tmpl), so connecting
# never triggers a 1Password prompt.
#   usage: keychain-headers.sh <keychain service> <auth scheme>

emulate -L zsh
setopt err_exit no_unset pipe_fail

service="${1:?usage: $0 <keychain service> <auth scheme>}"
scheme="${2:?usage: $0 <keychain service> <auth scheme>}"

# Claude Desktop starts helpers with a minimal environment
token="$(security find-generic-password -a "${USER:-$(id -un)}" -s "$service" -w 2>/dev/null)" \
    || { print -u2 "$service missing in Keychain, run: chezmoi apply"; exit 1 }

# The token goes into the JSON unescaped, so refuse anything that would break it
[[ "$token" != *[\"\\]* ]] || { print -u2 "$service contains characters that need JSON escaping"; exit 1 }

printf '{"Authorization": "%s %s"}\n' "$scheme" "$token"
