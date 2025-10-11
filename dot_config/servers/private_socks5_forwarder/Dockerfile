FROM alpine:3.22.2

ENV PROXY_PORT=1080

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    apk add \
    curl \
    ca-certificates \
    dante-server \
    envsubst \
    iptables \
    redsocks && \
    update-ca-certificates

COPY danted.conf redsocks.conf.template /etc/
COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

EXPOSE ${PROXY_PORT}

CMD [ "/entrypoint.sh" ]
