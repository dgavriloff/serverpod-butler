# Breakout Butler

## Project Structure
Serverpod monorepo:
- `breakout_butler_server` - Dart backend
- `breakout_butler_client` - Generated client library
- `breakout_butler_flutter` - Flutter web frontend

## Development
- Dev URL: `https://serverpod-butler-dev.up.railway.app/`
- Push to `dev` branch only (not `main` unless told)
- Railway auto-deploys on push

## Build & Deploy Flutter
Pre-built workflow - Flutter output is committed to git.

After ANY Flutter change:
```bash
cd breakout_butler/breakout_butler_flutter
flutter build web --base-href / --wasm
cp -r build/web/* ../breakout_butler_server/web/app/
git add -f breakout_butler/breakout_butler_server/web/app/
```

## Serverpod Commands
```bash
serverpod generate        # After model changes
serverpod create-migration # After model changes
```

## Gotchas
- Stale `LiveSession` rows can cause 500 errors: `UPDATE live_session SET "isActive" = false WHERE "isActive" = true;`
