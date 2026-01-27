# =============================================================================
# Multi-stage Dockerfile for Railway deployment
# Builds Flutter web app + Serverpod server in a single image
# =============================================================================

# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.29.3 AS flutter-build
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
FROM alpine:latest

ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

# Copy Dart runtime dependencies
COPY --from=server-build /runtime/ /

# Copy compiled server
COPY --from=server-build /app/bin/server server

# Copy server config and resources
COPY --from=server-build /app/config/ config/
COPY --from=server-build /app/web/ web/
COPY --from=server-build /app/migrations/ migrations/
COPY --from=server-build /app/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

# Copy Flutter web build into Serverpod's web/app/ directory
COPY --from=flutter-build /app/breakout_butler_flutter/build/web/ web/app/

EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

ENTRYPOINT ./server --mode=$runmode --server-id=$serverid --logging=$logging --role=$role
