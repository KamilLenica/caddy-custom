FROM caddy:2-builder AS builder
# Deklarujemy argumenty budowania przekazane z GitHub Actions
ARG CADDY_VERSION
ARG XCADDY_MODULES

# Uruchamiamy kompilację składając bazę z przekazanym stringiem modułów
RUN xcaddy build ${XCADDY_MODULES}

# Etap finalny - czysty obraz produkcyjny
FROM caddy:2

# Podmieniamy standardowy plik binarny naszym customowym
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Domyślne polecenie startowe serwera Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
