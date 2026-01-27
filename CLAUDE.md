# Breakout Butler

## Project Structure

Serverpod monorepo with three packages:
- `breakout_butler_server` - Dart backend (Serverpod framework)
- `breakout_butler_client` - Generated client library
- `breakout_butler_flutter` - Flutter web frontend

## LAN Deployment & Networking

### Architecture
```
Browser (HTTPS) -> Caddy (TLS termination) -> Serverpod (HTTP)
```

### Ports
| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| Serverpod API | 8080 | HTTP | API endpoint methods |
| Serverpod Insights | 8081 | HTTP | Serverpod insights API |
| Serverpod Web | 8082 | HTTP | Serves Flutter web build from `web/app/` |
| Caddy (app) | 8443 | HTTPS | Proxies to :8082, serves Flutter app |
| Caddy (API) | 8444 | HTTPS | Proxies to :8080, API calls from Flutter |
| PostgreSQL | 8090 | TCP | Database |
| Redis | 8091 | TCP | Serverpod cache/messaging |

### TLS Setup (mkcert)
```bash
mkcert -install
mkcert localhost 127.0.0.1 <LAN_IP>
# Place certs in breakout_butler/certs/
```

### Caddy Configuration
- Caddyfile is at `breakout_butler/Caddyfile`
- Uses mkcert certificates from `breakout_butler/certs/`
- Reload: `cd breakout_butler && caddy reload --config Caddyfile`

### Flutter Web Config
- `breakout_butler_flutter/assets/config.json` contains `apiUrl`
- For LAN: set to `https://<LAN_IP>:8444`
- For localhost: set to `http://localhost:8080`

### Build & Deploy Flutter Web
```bash
cd breakout_butler/breakout_butler_flutter
flutter build web --base-href /app/ --wasm
cp -r build/web/* ../breakout_butler_server/web/app/
```

### Serverpod Development Config
- `breakout_butler_server/config/development.yaml`
- Set `apiServer.publicHost` and `webServer.publicHost` to LAN IP for LAN access
- Database and Redis run in Docker via `docker compose up`

### Key Commands
```bash
# Generate Serverpod code after model changes
serverpod generate

# Create migration after model changes
serverpod create-migration

# Start server
cd breakout_butler/breakout_butler_server && dart run bin/main.dart

# Dependencies
cd breakout_butler/breakout_butler_server && dart pub get
```

### Gotchas
- `serverpod` CLI may not be on PATH; use `$HOME/.pub-cache/bin/serverpod`
- Browser needs mkcert root CA installed for HTTPS without warnings
- Stale active `LiveSession` rows in DB can cause 500 errors on session creation (deactivate via: `UPDATE live_session SET "isActive" = false WHERE "isActive" = true;`)
- psql is accessed via Docker: `docker exec <postgres_container> psql -U postgres -d breakout_butler`
