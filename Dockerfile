# =============================================================================
# Multi-stage Dockerfile for Railway deployment
# Builds Flutter web app + Serverpod server in a single image
# Uses Caddy as reverse proxy to serve API + web through a single port
# =============================================================================

# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.38.7 AS flutter-build
WORKDIR /app

# Copy all packages (Flutter needs client lib for dependencies)
COPY breakout_butler/breakout_butler_client breakout_butler_client
COPY breakout_butler/breakout_butler_flutter breakout_butler_flutter

# Build Flutter web
WORKDIR /app/breakout_butler_flutter
RUN flutter pub get
RUN flutter build web --base-href /app/ --wasm

# Stage 2: Build Dart server
FROM dart:3.8.0 AS server-build
WORKDIR /app

COPY breakout_butler/breakout_butler_server .

RUN dart pub get
RUN dart compile exe bin/main.dart -o bin/server

# Stage 3: Final runtime image
# Use Debian-based image (not Alpine) because Dart AOT binaries require glibc
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y ca-certificates curl debian-keyring debian-archive-keyring apt-transport-https && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list && \
    apt-get update && \
    apt-get install -y caddy && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled server (Dart AOT executables are self-contained)
COPY --from=server-build /app/bin/server server

# Copy server config and resources
COPY --from=server-build /app/config/ config/
COPY --from=server-build /app/web/ web/
COPY --from=server-build /app/migrations/ migrations/
COPY --from=server-build /app/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

# Copy Flutter web build into Serverpod's web/app/ directory
COPY --from=flutter-build /app/breakout_butler_flutter/build/web/ web/app/

# Copy production Caddyfile
COPY Caddyfile.production /etc/caddy/Caddyfile

EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

# Start both Serverpod and Caddy
# Serverpod runs in background, Caddy in foreground
CMD ./server --mode production --server-id default --logging normal --role monolith & \
    sleep 2 && \
    caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
