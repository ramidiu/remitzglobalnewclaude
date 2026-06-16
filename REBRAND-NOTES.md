# RemitM → Remitz Rebrand — What Was Done

This project (`remitzglobalnewclaude`) was previously branded **RemitM** (itself a copy of the
Layla money-transfer codebase). It has now been fully rebranded to **Remitz**, adopting the visual
identity of the `remitzglobal` (ForexBridge) project. Backend logic, APIs, DB schema *structure*,
auth, business rules, payment flows and integrations were left functionally unchanged — only
branding, presentation and theme were modified.

## 1. Deep rename (RemitM → Remitz)
Applied case-aware across the entire repo (`RemitM`/`Remitm`→`Remitz`, `REMITM`→`REMITZ`,
`remitm`→`remitz`):
- **Java package** `com.remitm` → `com.remitz` (directories moved; classes
  `RemitmApplication/RemitmException/RemitmPermissionEvaluator` → `Remitz*`, files renamed to match).
- **Database schema** `remitm` → `remitz` (JDBC URL in `application.yml`, `MYSQL_DATABASE` in compose).
- **Domains** `remitm.com` → `remitz.com`; company/brand strings, admin emails, email/PDF templates,
  i18n (`en.json`/`ar.json`), landing + legal copy, configs, docs and comments.
- **Folders:** `remitm-backend`→`remitz-backend`, `remitm-migration`→`remitz-migration`,
  `remitmmoneytransfernew`→`remitzmoneytransfernew`.
- **Files:** `docker-compose.remitm.yml`→`docker-compose.remitz.yml`,
  `remitmai-design-tokens.scss`→`remitzai-design-tokens.scss`, all `remitm-logo*`→`remitz-logo*`,
  deploy vhost confs/service, migration `V545__rebrand_remitz_to_remitz.sql`.
- Verified: **0** occurrences of `remitm` (any case) remain in source or filenames.

## 2. Design system — adopted the Remitz identity from `remitzglobal`
- **Palette** swapped from RemitM navy/green to the Remitz scheme in
  `remitzai-design-tokens.scss` (`$fb-*` tokens, names kept for compatibility), and cascaded to all
  hardcoded hex/rgb across SCSS/HTML/TS and `index.html` `theme-color`:
  | Role | Old (RemitM) | New (Remitz) |
  |------|-------------|--------------|
  | Primary navy | `#003377` | `#1B3571` |
  | Primary shade | `#002A66` | `#0A2342` |
  | Primary tint | `#0A4A99` | `#2B4C9F` |
  | Secondary | `#5DBB52` (green) | `#9AACE6` (periwinkle) |
  | Secondary shade | `#4A9E40` | `#7A8FCE` |
  | Secondary tint | `#7FCB6F` | `#BCC9EE` |
- **Logos:** the SVG wordmark logos already render "Remitz" in the new palette. Raster logos
  (`remitz-logo.png`, `remitz-logo.webp` favicon, `remitz-logo-white.png`, backend
  `remitz-logo-email.png`, `deploy/remitz-logo.png`) were replaced with the authentic Remitz logo
  art from `remitzglobal/forexbridge-ui/src/assets/images/`.

## 3. Validation performed (static — offline)
- 0 `remitm`/`RemitM`/`REMITM` strings or filenames remain.
- 0 references to the old palette hexes/rgb.
- Build contexts (`./remitz-backend`, `./remitzmoneytransfernew`), JDBC schema (`/remitz`),
  `groupId com.remitz`, package name `remitz-money-transfer`, Dockerfiles, SCSS `@import`s and every
  referenced logo asset all resolve consistently.

## Manual follow-ups (require tooling not available offline)
1. **Build** — no Maven/`node_modules` here. Run:
   - Backend: `cd remitz-backend && mvn clean package -DskipTests`
   - Frontend: `cd remitzmoneytransfernew && npm install && npm run build`
2. **True WebP favicon** — `remitz-logo.webp` currently holds PNG bytes (renders via browser
   sniffing). Regenerate a real `.webp` if desired.
3. **Production infra** (DNS, SSL certs, server paths for remitz.com) was renamed in config text
   only — actual domain/cert cutover is a separate ops task.
