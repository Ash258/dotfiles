#!/bin/sh

# hash: {{ include "dot_config/mise/config.toml" | sha256sum }}
MISE_AQUA_COSIGN=false mise install cosign
mise install
