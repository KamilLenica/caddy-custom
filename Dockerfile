ARG CADDY_VERSION=latest
FROM caddy:${CADDY_VERSION}-builder AS builder

# Kopiujemy listę wtyczek do wnętrza kontenera budującego
COPY modules.txt /tmp/modules.txt

# Dynamicznie generujemy flagi dla xcaddy, oczyszczając linie ze spacji i znaków \r
RUN xcaddy_args="" && \
    while IFS= read -r raw_module || [ -n "$raw_module" ]; do \
        module=$(echo "$raw_module" | tr -d '\r' | xargs); \
        if [ -n "$module" ] && [[ ! "$module" =~ ^# ]]; then \
            echo "Dodaję moduł do kompilacji: $module"; \
            xcaddy_args="$xcaddy_args --with $module"; \
        fi; \
    done < /tmp/modules.txt && \
    eval "xcaddy build $xcaddy_args"

FROM caddy:${CADDY_VERSION}
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
