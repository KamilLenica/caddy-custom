# Globalny ARG odbierający czystą wersję bez 'v' (np. 2.11.7) przekazaną z CADDY_DOCKER
ARG CADDY_DOCKER=latest

# --- ETAP BUDOWANIA ---
FROM caddy:${CADDY_DOCKER}-builder AS builder

# Deklarujemy argumenty budowania wewnątrz etapu
ARG CADDY_VERSION
ARG XCADDY_MODULES

# Czysta kompilacja bez użycia pamięci podręcznej (cache)
RUN xcaddy build ${XCADDY_MODULES}


# --- ETAP FINALNY ---
FROM caddy:${CADDY_DOCKER}

# Podmieniamy standardowy plik binarny naszym customowym
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Domyślne polecenie startowe serwera Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
