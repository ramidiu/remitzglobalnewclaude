#!/usr/bin/env bash
# =============================================================================
# redeploy.sh — push the LATEST build to the already-running LIVE server.
# Rebuilds the backend (server-side Maven) + replaces the frontend.
# Does NOT touch the database (data is preserved).
#
# Usage:
#   bash deploy-live/redeploy.sh                 # defaults to root@68.169.55.246
#   bash deploy-live/redeploy.sh root@1.2.3.4    # custom host
#   SRV=root@1.2.3.4 bash deploy-live/redeploy.sh
#
# Prereqs: the LIVE stack already deployed under /opt/remitz-live (mysql/redis/backend),
#          web root /var/www/remitz/data/www/remitz.com, and the local Remitz docker
#          stack running (remitz-frontend-new holds the production build).
# You'll be asked for the server password (set up an SSH key to avoid repeats).
# =============================================================================
set -euo pipefail
SRV="${1:-${SRV:-root@68.169.55.246}}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$(cd "$HERE/.." && pwd)"

echo ">> Target: $SRV"

echo ">> [1/4] Build frontend artifact from the running local container"
rm -rf /tmp/remitz-www && mkdir -p /tmp/remitz-www
docker cp remitz-frontend-new:/usr/share/nginx/html/. /tmp/remitz-www/
tar -czf "$HERE/remitz-frontend.tar.gz" -C /tmp remitz-www
echo "   frontend: $(du -h "$HERE/remitz-frontend.tar.gz" | cut -f1)"

echo ">> [2/4] Package backend source"
tar --exclude='target' --exclude='.git' -czf /tmp/remitz-backend-src.tar.gz -C "$SRC" remitz-backend
echo "   backend src: $(du -h /tmp/remitz-backend-src.tar.gz | cut -f1)"

echo ">> [3/4] Upload to server (/tmp)"
scp -o StrictHostKeyChecking=accept-new \
    /tmp/remitz-backend-src.tar.gz "$HERE/remitz-frontend.tar.gz" "$SRV:/tmp/"

echo ">> [4/4] Server-side: rebuild backend + replace frontend (DB untouched)"
ssh -o StrictHostKeyChecking=accept-new "$SRV" 'bash -s' <<'EOF'
set -e
cd /opt/remitz-live
# refresh backend source
rm -rf remitz-backend.bak && [ -d remitz-backend ] && mv remitz-backend remitz-backend.bak || true
tar -xzf /tmp/remitz-backend-src.tar.gz -C /opt/remitz-live
echo "== rebuild + restart backend (Maven on server) =="
docker compose -f docker-compose.production.yml up -d --build backend
echo "== replace frontend =="
WEB=/var/www/remitz/data/www/remitz.com
tar -xzf /tmp/remitz-frontend.tar.gz -C "$WEB" --strip-components=1
echo "== wait backend health =="
for i in $(seq 1 72); do
  curl -s http://127.0.0.1:8087/actuator/health 2>/dev/null | grep -q UP && { echo BACKEND-UP; break; }
  sleep 5
done
echo -n "health: "; curl -s http://127.0.0.1:8087/actuator/health; echo
docker ps --format '{{.Names}} {{.Status}}' | grep remitz-live
EOF
echo ">> REDEPLOY DONE"
