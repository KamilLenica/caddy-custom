ARG CADDY_VERSION=latest
FROM caddy:${CADDY_VERSION}-builder AS builder

# Kopiujemy listę wtyczek do wnętrza kontenera budującego
COPY modules.txt /tmp/modules.txt

# Używamy xargs do bezpiecznego wygenerowania i uruchomienia pełnego polecenia xcaddy
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    tr -d '\r' < /tmp/modules.txt | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*$' | xargs -I {} echo "--with {}" | tr '\n' ' ' | xargs xcaddy build

FROM caddy:${CADDY_VERSION}

# Kopiujemy nowo skompilowany plik binarny Caddy z modułami
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Definiujemy domyślne polecenie uruchamiania serwera Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
