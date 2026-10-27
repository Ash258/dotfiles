#!/bin/zsh
# MCP wrapper for ARICOMA IDM (identity-management-ai-mcp-idm).
#
# Credentials are cached in macOS Keychain, so starting the server never triggers
# a 1Password prompt. Seed them once (and after every rotation) from Terminal.app:
#   ~/.claude/mcp-wrappers/idm.sh --seed 'op://<vault>/<item>'
# The 1Password item needs fields: endpoint, guid, username, password.

emulate -L zsh
setopt err_exit no_unset pipe_fail

readonly SELF="${0:A}"
readonly SERVER="$HOME/.config/servers/mcp/n/identity-management-ai-mcp-idm/idm_mcp.py"
# Keychain service suffix -> 1Password field
readonly -A FIELDS=(endpoint endpoint guid guid login username password password)

if [[ "${1:-}" == --seed ]]; then
    item="${2:?usage: $SELF --seed 'op://<vault>/<item>'}"
    for key field in "${(@kv)FIELDS}"; do
        value="$(op read "$item/$field")"
        # security reads the value twice (entry + retype) from stdin; printf is a builtin, so it never hits argv
        printf '%s\n%s\n' "$value" "$value" | security add-generic-password -U -a "$USER" -s "idm-mcp-$key" -w >/dev/null 2>&1
        print -u2 "Stored idm-mcp-$key"
    done
    exit 0
fi

kc() { security find-generic-password -a "$USER" -s "idm-mcp-$1" -w 2>/dev/null || { print -u2 "idm-mcp-$1 missing in Keychain, run: $SELF --seed 'op://<vault>/<item>'"; exit 1 } }

# Assign before export, otherwise export masks a failed lookup
IDM_ENDPOINT="$(kc endpoint)"
IDM_GUID_SYSTEM="$(kc guid)"
IDM_LOGIN="$(kc login)"
IDM_PASSWORD="$(kc password)"
export IDM_ENDPOINT IDM_GUID_SYSTEM IDM_LOGIN IDM_PASSWORD
export IDM_DEFAULT_DOMAIN="${IDM_DEFAULT_DOMAIN:-NOTINO}"
# Claude Desktop starts servers with a minimal PATH
export PATH="/opt/homebrew/bin:$PATH"

# No keyring dependency on purpose: the server then uses IDM_PASSWORD instead of its own Keychain lookup
exec mise exec -- uv run --quiet \
    --with requests \
    --with 'fastmcp>=2.13.0' \
    python "$SERVER"
