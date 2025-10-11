#!/bin/sh

atuin login \
    --username "$(op read 'op://NEW/4m5rld2glwnxvfrz2f4vmond3y/username' || true)" \
    --password "$(op read 'op://NEW/4m5rld2glwnxvfrz2f4vmond3y/password' || true)" \
    --key "$(op read 'op://NEW/4m5rld2glwnxvfrz2f4vmond3y/atuin key' || true)"
