# Flutter Backend Sync Runbook

## 1) Cloud deploy (project `seuoakzowzmqsmbqzznm`)

```bash
set -a
source .env
set +a

npx --yes supabase@latest link --project-ref seuoakzowzmqsmbqzznm --password "$SUPABASE_DB_PASSWORD"
npx --yes supabase@latest db push
npx --yes supabase@latest functions deploy sync-pull
npx --yes supabase@latest functions deploy sync-push
npx --yes supabase@latest functions deploy auth-bootstrap
npx --yes supabase@latest functions deploy leads-estimate-sent
npx --yes supabase@latest functions deploy followup-dispatcher
```

## 2) Preflight check before `flutter run`

```bash
./scripts/flutter_backend_preflight.sh
```

Expected:
- No `scaffold-only` / `not_implemented` responses.
- Auth-gated functions return `401` or `403` for invalid bearer token.
- Required migration file for clients/photos sync is present.

## 3) One-time stale local state reset workflow

1. Sign out in the app.
2. Delete simulator app data (or uninstall/reinstall app).
3. Sign in again.
4. Trigger a manual sync from Settings > Sync Diagnostics.
5. Verify local DB has `sync_cursors` entry for `all` and client rows appear.

SQLite location (iOS simulator):

```text
~/Library/Developer/CoreSimulator/Devices/<DEVICE_ID>/data/Containers/Data/Application/<APP_ID>/Documents/crewcommand.sqlite
```

Quick checks:

```bash
sqlite3 /path/to/crewcommand.sqlite "select entity_type,cursor from sync_cursors;"
sqlite3 /path/to/crewcommand.sqlite "select count(*) from local_clients;"
```
