#!/bin/sh

conf='/etc/redsocks.conf'
envsubst < "${conf}.template" > "${conf}"

# Start redsocks
redsocks -c "${conf}" &

# Configure iptables to redirect traffic from Dante to redsocks
iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-ports "${REDSOCKS_PORT}"
iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDIRECT --to-ports "${REDSOCKS_PORT}"

# Start Dante server
sockd -f /etc/danted.conf
