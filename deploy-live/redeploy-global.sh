#!/usr/bin/env bash
# =============================================================================
# redeploy-global.sh — re-deploy this project to the global.remitz.co.uk server
# (containerised backend + frontend under /opt/remitz-global). Rebuilds both
# containers from the latest source. Does NOT touch the database or the server
# .env / docker-compose.global.yml.
#
# Usage:  bash deploy-live/redeploy-global.sh [root@host]
#         default host: root@77.68.125.96
# You'll be prompted for the server password (set up an SSH key to avoid repeats).
# =============================================================================
set -euo pipefail
SRV="${1:-${SRV:-root@77.68.125.96}}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$(cd "$HERE/.." && pwd)"
APP=/opt/remitz-global

echo ">> Target: $SRV  ($APP)"
echo ">> [1/3] package source"
tar --exclude='target' --exclude='.git' -czf /tmp/g-backend.tar.gz -C "$SRC" remitz-backend
tar --exclude='node_modules' --exclude='www' --exclude='.angular' --exclude='.git' --exclude='dist' \
    -czf /tmp/g-frontend.tar.gz -C "$SRC" remitzmoneytransfernew

echo ">> [2/3] upload"
scp -o StrictHostKeyChecking=accept-new /tmp/g-backend.tar.gz /tmp/g-frontend.tar.gz "$SRV:/tmp/"

echo ">> [3/3] server: replace source + rebuild containers (DB preserved)"
ssh -o StrictHostKeyChecking=accept-new "$SRV" "APP=$APP bash -s" <<'EOF'
set -e
cd "$APP"
TS=$(date +%Y%m%d-%H%M%S)
[ -d remitz-backend ] && mv remitz-backend "remitz-backend.bak-$TS"
[ -d remitzmoneytransfernew ] && mv remitzmoneytransfernew "remitzmoneytransfernew.bak-$TS"
tar -xzf /tmp/g-backend.tar.gz  -C "$APP"
tar -xzf /tmp/g-frontend.tar.gz -C "$APP"
echo "== rebuild backend + frontend (Maven + Angular on server) =="
docker compose -f docker-compose.global.yml up -d --build backend frontend
echo "== wait backend health (8094) =="
for i in $(seq 1 90); do
  curl -s http://127.0.0.1:8094/actuator/health 2>/dev/null | grep -q UP && { echo BACKEND-UP; break; }
  sleep 5
done
echo -n "backend health: "; curl -s http://127.0.0.1:8094/actuator/health; echo
echo -n "frontend (8099): "; curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8099/
docker ps --format '{{.Names}} {{.Status}}' | grep remitz-global
# keep only the most recent 2 backups
ls -dt "$APP"/remitz-backend.bak-* 2>/dev/null | tail -n +3 | xargs -r rm -rf
ls -dt "$APP"/remitzmoneytransfernew.bak-* 2>/dev/null | tail -n +3 | xargs -r rm -rf
EOF
echo ">> REDEPLOY-GLOBAL DONE"
