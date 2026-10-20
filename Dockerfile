ARG CADDY_VERSION
FROM caddy:${CADDY_VERSION}-builder AS builder
ARG CADDY_VERSION
ARG XCADDY_WITH
RUN xcaddy build v${CADDY_VERSION} ${XCADDY_WITH}

FROM caddy:${CADDY_VERSION}
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
