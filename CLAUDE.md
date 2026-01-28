# Breakout Butler

## Project Structure

Serverpod monorepo with three packages:
- `breakout_butler_server` - Dart backend (Serverpod framework)
- `breakout_butler_client` - Generated client library
- `breakout_butler_flutter` - Flutter web frontend

## Development Environment

**IMPORTANT: Do NOT run local servers.** The only dev environment is Railway:
- Dev URL: `https://serverpod-butler-dev.up.railway.app/app`
- To deploy: build Flutter, commit pre-built files, push to `dev` branch
- Railway auto-deploys on push to `dev`

## LAN Deployment & Networking (Legacy)

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

**IMPORTANT: Pre-built workflow.** Flutter web output is committed to git so
Railway doesn't have to install the Flutter SDK and rebuild from scratch on
every push. The Dockerfile does NOT build Flutter — it copies the pre-built
files from `breakout_butler_server/web/app/`.

After ANY Flutter code change, you MUST rebuild and commit the output:
```bash
cd breakout_butler/breakout_butler_flutter
flutter build web --base-href /app/ --wasm
cp -r build/web/* ../breakout_butler_server/web/app/
git add breakout_butler/breakout_butler_server/web/app/
```
If you skip this step, Railway will deploy stale frontend code.

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
