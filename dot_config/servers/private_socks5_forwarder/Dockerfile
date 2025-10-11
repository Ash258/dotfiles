FROM debian:bullseye-slim

ENV PROXY_PORT=1080

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache && \
    apt-get update && \
    apt-get --no-install-recommends install -y \
    curl \
    ca-certificates \
    dante-server \
    gettext-base \
    iptables \
    redsocks && \
    update-ca-certificates

COPY danted.conf redsocks.conf.template /etc/
COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

EXPOSE ${PROXY_PORT}

CMD [ "/entrypoint.sh" ]
