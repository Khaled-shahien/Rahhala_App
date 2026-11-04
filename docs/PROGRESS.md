# Production-Readiness Progress

Branch: `production-readiness` (from `Developer`). To resume: read this file first, then `docs/AUDIT.md` §8.

| Phase | Status |
|---|---|
| 1 — Discovery & audit | ✅ done (`docs/AUDIT.md`) |
| 2 — Critical fixes & security | ⏳ in progress |
| 3 — Architecture alignment | ☐ |
| 4 — Performance | ☐ |
| 5 — UI/UX | ☐ |
| 6 — Testing & CI | ☐ |
| 7 — Release readiness | ☐ |

## Current task
Phase 2: fix the build (B1), then the network and error layer.

## Remaining (Phase 2)
- [ ] B1 exhaustive Dio mapping + typed `Failure`
- [ ] B2 one configured Dio + `AppConfig` (dart-define-from-file)
- [ ] B4/B19 localized failure messages, no raw `e.toString()` in the UI
- [ ] B6/B7 repo catch-alls, token-less login rejected
- [ ] B5 401 → session expiry
- [ ] B3 account-deleted state
- [ ] B8 guest-safe shell / lazy tabs
- [ ] B9 session-reset hook
- [ ] B16 global error handlers
- [ ] S1/S2/S3/S10/S11/S12 release hardening
- [ ] A2 unused deps, files, dead code
