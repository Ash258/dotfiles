#!/bin/sh

# hash: {{ include "Brewfile" | sha256sum }}
brew bundle install
