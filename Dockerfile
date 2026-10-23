ARG CADDY_VERSION=latest
FROM caddy:${CADDY_VERSION}-builder AS builder

# Kopiujemy listę wtyczek do wnętrza kontenera
COPY modules.txt /tmp/modules.txt

# Budujemy Caddy dynamicznie przy użyciu pętli w czystym skrypcie sh
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    echo 'set -e' > /tmp/build.sh && \
    echo 'cmd="xcaddy build"' >> /tmp/build.sh && \
    while read -r line || [ -n "$line" ]; do \
        # Usuwamy znaki powrotu karetki \r i zbędne spacje
        clean=$(echo "$line" | tr -d '\r' | xargs); \
        # Pomijamy linie puste i komentarze
        case "$clean" in \
            ""|#*) continue ;; \
        esac; \
        # Doklejamy flagę z ukośnikiem na końcu (symulacja zapisu wielolinijkowego)
        cmd="$cmd \\\n  --with $clean"; \
    done < /tmp/modules.txt && \
    echo -e "Generowane polecenie:\n$cmd" && \
    printf "$cmd\n" > /tmp/run.sh && \
    sh /tmp/run.sh

FROM caddy:${CADDY_VERSION}

# Kopiujemy dedykowany plik binarny Caddy
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Domyślne polecenie startowe serwera Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
