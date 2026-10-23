ARG CADDY_VERSION=latest
FROM caddy:${CADDY_VERSION}-builder AS builder

# Kopiujemy listę wtyczek do wnętrza kontenera budującego
COPY modules.txt /tmp/modules.txt

# Korzystamy z oficjalnego mechanizmu cache oraz dynamicznej budowy argumentów z pliku
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    xcaddy_args="" && \
    while read -r line || [ -n "$line" ]; do \
        clean_line=$(echo "$line" | tr -d '\r' | awk '{$1=$1;print}'); \
        case "$clean_line" in \
            ""|#*) continue ;; \
        esac; \
        xcaddy_args="$xcaddy_args --with $clean_line"; \
    done < /tmp/modules.txt && \
    eval "xcaddy build \$xcaddy_args"

FROM caddy:${CADDY_VERSION}

# Kopiujemy nowo skompilowany plik binarny Caddy z modułami
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Definiujemy domyślne polecenie uruchamiania serwera Caddy z Twoją konfiguracją
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
