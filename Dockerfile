ARG CADDY_VERSION=latest
FROM caddy:${CADDY_VERSION}-builder AS builder

COPY modules.txt /tmp/modules.txt

RUN xcaddy_args="" && \
    while IFS= read -r module || [ -n "$module" ]; do \
        [[ -z "$module" || "$module" =~ ^# ]] && continue; \
        xcaddy_args="$xcaddy_args --with $module"; \
    done < /tmp/modules.txt && \
    eval "xcaddy build $xcaddy_args"

FROM caddy:${CADDY_VERSION}
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
