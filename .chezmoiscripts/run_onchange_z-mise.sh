#!/bin/sh

# hash: {{ include "dot_config/mise/config.toml" | sha256sum }}
mise install
