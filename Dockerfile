# =============================================================================
# Multi-stage Dockerfile for Railway deployment
# Compiles Serverpod server + copies pre-built Flutter web app
# Uses Caddy as reverse proxy to serve API + web through a single port
#
# IMPORTANT: Flutter web is PRE-BUILT locally and committed to git.
# This avoids installing Flutter SDK in Docker (saves ~5min per deploy).
# After changing Flutter code, rebuild and commit:
#   cd breakout_butler/breakout_butler_flutter
#   flutter build web --base-href / --no-tree-shake-icons
#   cp -r build/web/* ../breakout_butler_server/web/app/
#   git add -f breakout_butler/breakout_butler_server/web/app/
# =============================================================================

# Stage 1: Build Dart server
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

# Flutter web build is pre-built and committed at web/app/ in the server package
# Copy to /app/flutter for Caddy to serve directly (not through Serverpod web server)
COPY --from=server-build /app/web/app/ flutter/

# Copy production Caddyfile
COPY Caddyfile.production /etc/caddy/Caddyfile

EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

# Start both Serverpod and Caddy
# Serverpod runs in background, Caddy in foreground
CMD ./server --mode production --server-id default --logging normal --role monolith --apply-migrations & \
    sleep 5 && \
    caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
