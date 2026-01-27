# Breakout Butler - Renovation Plan

## Current State Assessment

### What's Working
- **Docker Services**: PostgreSQL (8090) and Redis (8091) running
- **Caddy**: HTTPS reverse proxy running on ports 8443/8444
- **Flutter Dev**: Flutter app running in dev mode
- **Certificates**: mkcert SSL certs in `certs/` folder
- **LAN IP**: `192.168.254.19`

### What's NOT Working
- **Serverpod Server**: NOT running (8080, 8081, 8082 are dead)
- **Network Binding**: Config binds to `localhost` - won't accept LAN connections
- **Flutter API URL**: Points to `http://localhost:8080` - won't work from LAN clients
- **No Flutter Web Build**: Web app not built for Serverpod to serve

---

## Network Architecture (Target State)

```
LAN Clients (192.168.254.x)
         │
         ▼
┌─────────────────────────────────────┐
│  Caddy Reverse Proxy (this machine) │
│  192.168.254.19                     │
│                                     │
│  :8443 → Flutter Web (:8082)        │
│  :8444 → Serverpod API (:8080)      │
│         (HTTPS with mkcert)         │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Serverpod (0.0.0.0 binding)        │
│  :8080 - API Server                 │
│  :8081 - Insights Server            │
│  :8082 - Web Server (Flutter app)   │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Docker Services                    │
│  PostgreSQL :8090                   │
│  Redis :8091                        │
└─────────────────────────────────────┘
```

---

## Fix List

### 1. Fix Serverpod Network Binding
**File**: `breakout_butler_server/config/development.yaml`

Change all `publicHost: localhost` to `publicHost: 192.168.254.19` and update schemes to use the Caddy HTTPS endpoints.

```yaml
apiServer:
  port: 8080
  publicHost: 192.168.254.19
  publicPort: 8444           # Caddy HTTPS port
  publicScheme: https

insightsServer:
  port: 8081
  publicHost: 192.168.254.19
  publicPort: 8081
  publicScheme: http

webServer:
  port: 8082
  publicHost: 192.168.254.19
  publicPort: 8443           # Caddy HTTPS port
  publicScheme: https
```

### 2. Fix Flutter API URL Configuration
**File**: `breakout_butler_flutter/assets/config.json`

```json
{
    "apiUrl": "https://192.168.254.19:8444"
}
```

### 3. Fix server.dart AppConfigRoute
The server dynamically serves config based on `pod.config.apiServer`. After fixing development.yaml, this will auto-serve the correct HTTPS URL.

### 4. Build Flutter Web App
```bash
cd breakout_butler/breakout_butler_flutter
flutter build web --base-href /app/ --wasm
cp -r build/web ../breakout_butler_server/web/app
```

### 5. Run Serverpod Code Generation
```bash
cd breakout_butler/breakout_butler_server
dart run serverpod generate
```

### 6. Apply Database Migrations
```bash
cd breakout_butler/breakout_butler_server
dart run serverpod migrate
```

### 7. Start Serverpod Server
```bash
cd breakout_butler/breakout_butler_server
dart run bin/main.dart
```

### 8. Restart Caddy (if config changed)
```bash
cd breakout_butler
caddy reload --config Caddyfile
```

---

## Client Machine Setup (for LAN testers)

LAN machines need to trust the mkcert root CA to avoid SSL warnings.

### Option A: Install mkcert root CA
1. Copy the mkcert root CA from this machine to client
2. Install it in client's trust store

### Option B: Use Chrome flag (temporary)
```bash
# On client machine
chrome --ignore-certificate-errors
```

### Access URLs (for LAN clients)
- **Flutter App**: `https://192.168.254.19:8443/app/`
- **Create Session**: `https://192.168.254.19:8443/app/`
- **Join as Student**: `https://192.168.254.19:8443/app/{urlTag}/{roomNumber}`

---

## Execution Checklist

- [ ] Stop any existing Serverpod process
- [ ] Update `development.yaml` with LAN-accessible config
- [ ] Update `assets/config.json` with HTTPS API URL
- [ ] Run `dart pub get` in all three packages
- [ ] Run `serverpod generate`
- [ ] Run `serverpod migrate`
- [ ] Build Flutter web (`flutter build web --base-href /app/ --wasm`)
- [ ] Copy build to `web/app/`
- [ ] Start Serverpod (`dart run bin/main.dart`)
- [ ] Verify Caddy is running and proxying correctly
- [ ] Test from LAN client browser

---

## Verification Steps

1. **Server Health**: `curl http://localhost:8080/`
2. **Caddy Proxy**: `curl -k https://192.168.254.19:8444/`
3. **Flutter App**: Open `https://192.168.254.19:8443/app/` in browser
4. **WebSocket Test**: Create a session and verify real-time updates

---

## Known Issues to Watch

1. **Audio Recording**: Requires HTTPS (handled by Caddy)
2. **WebSocket Streaming**: Must go through Caddy HTTPS proxy
3. **CORS**: Serverpod handles this, but verify no issues
4. **Certificate Trust**: LAN clients may see warnings without mkcert CA

---

## Files to Modify

| File | Change |
|------|--------|
| `breakout_butler_server/config/development.yaml` | Update publicHost, publicPort, publicScheme |
| `breakout_butler_flutter/assets/config.json` | Update apiUrl to HTTPS endpoint |

## Commands Summary

```bash
# From repo root
cd breakout_butler

# 1. Update configs (manual edits above)

# 2. Get dependencies
cd breakout_butler_client && dart pub get && cd ..
cd breakout_butler_flutter && flutter pub get && cd ..
cd breakout_butler_server && dart pub get && cd ..

# 3. Generate code
cd breakout_butler_server
dart run serverpod generate

# 4. Run migrations
dart run serverpod migrate

# 5. Build Flutter web
cd ../breakout_butler_flutter
flutter build web --base-href /app/ --wasm
cp -r build/web ../breakout_butler_server/web/app

# 6. Start server
cd ../breakout_butler_server
dart run bin/main.dart

# 7. Verify Caddy
caddy reload --config ../Caddyfile
```

---

## Post-Execution Testing

1. Open `https://192.168.254.19:8443/app/` on LAN machine
2. Create a session with a URL tag (e.g., "test123")
3. Open student room on another device: `https://192.168.254.19:8443/app/test123/1`
4. Test microphone recording and live transcription
5. Test real-time room content sync
6. Test Butler AI Q&A features
