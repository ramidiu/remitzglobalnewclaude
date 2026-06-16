# Run this project (with data) on another system

This repo bundles the **full database** (`database/remitz-full.sql.gz` — users, beneficiaries,
transactions, partners, KYC, etc.) and a self-contained Docker stack, so you can clone it on any
machine with Docker and get the exact same running app with the same data.

## Prerequisites
- Docker + Docker Compose
- Git

## Steps
```bash
git clone https://github.com/ramidiu/remitzglobalnewclaude.git
cd remitzglobalnewclaude

# Create your .env from the template and set the Brevo API key (kept out of git).
cp .env.example .env
#   then edit .env and set BREVO_API_KEY=...  (value is in the remitzglobal project's .env)

# Start everything (builds backend+frontend, restores the DB on first boot)
docker compose -f docker-compose.portable.yml up -d --build
```

> `.env` is gitignored so secrets never hit GitHub. The stack still boots without a Brevo
> key — only outbound email is disabled until you set `BREVO_API_KEY`.

First boot takes a few minutes: MySQL imports `database/remitz-full.sql.gz` (~413 MB), then the
backend builds + starts. Watch progress:
```bash
docker compose -f docker-compose.portable.yml logs -f backend
# wait for: "Started RemitzApplication"
```

## URLs
- **Frontend:** http://localhost:8098
- **Backend API:** http://localhost:8097
- MySQL: `localhost:3311` (user `root`, password from `.env`, database `remitz`)

## Login
- **Super Admin:** `admin@remitz.co.uk` / `Admin@123456`
- Other production staff accounts exist but keep their original production passwords.

## Notes
- `.env` (committed) holds the MySQL password, JWT secret, and the **Brevo** email API key/sender,
  so email (demo-access, OTP, etc.) works out of the box. Rotate these for a real deployment.
- The DB only auto-imports on a **fresh** MySQL volume. To re-import after changes:
  ```bash
  docker compose -f docker-compose.portable.yml down -v   # drops volumes (DELETES local data)
  docker compose -f docker-compose.portable.yml up -d --build
  ```
- To refresh the bundled dump from a running stack:
  ```bash
  docker exec remitz-mysql sh -c 'mysqldump -uroot -proot --single-transaction --routines --triggers --events --set-gtid-purged=OFF remitz | gzip' > database/remitz-full.sql.gz
  ```
- Ports 3311/6383/8097/8098 are used so this can coexist with other local stacks.
