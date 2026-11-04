# Production-Readiness Changelog

The work on branch `production-readiness`, phase by phase. Commit hashes refer to that branch.

---

## Phase 1 — Discovery & audit

**Summary.** I read the whole repository, ran the toolchain and wrote `docs/AUDIT.md` (prioritized issue table and plan), `docs/DECISIONS.md`, `docs/HUMAN_ACTIONS.md` and `docs/PROGRESS.md`.

**Commits**
- `768b4ba` chore(deps): commit refreshed lockfile and generated plugin registrants
- `2f0349f` docs: add production-readiness audit, decisions log and action list

**Verification (baseline).** `flutter analyze`: 1 error, so the app didn't compile. `flutter test`: 42 passed, 11 skipped, 2 suites failed to load.

**Behaviour changes.** None.

---

## Phase 2 — Critical fixes & security hardening

**Summary**
- **Build fixed.** The Dio error mapping is now exhaustive (`transformTimeout`). Errors are typed (`FailureType`) and every message is localized (en/ar), so users no longer see `Instance of 'ServerException'`, `TypeError …` or parser internals.
- **One configured API client.** Base URL, timeouts and interceptors are set once. Repositories that used the shared `Dio` directly previously depended on DI resolution order to get a base URL. Image search and trip history now use `ApiConsumer`.
- **Environment config.** `AppConfig` plus `config/{development,staging,production}.json` (`--dart-define-from-file`).
- **Sessions.** A 401 on an authenticated request ends the session. `SessionManager` centralizes logout, account deletion and expiry, resets user-scoped state (the chatbot conversation used to leak to the next user) and refreshes the router guards. Stale iOS Keychain tokens are cleared on a fresh install.
- **Profile.** Account deletion uses an explicit state; it used to match the word "delete" in the server message. Guests no longer trigger a 401 error popup. A cubit leak and an "auto-pop any route" listener are fixed.
- **Auth.** Logins without a token fail clearly. Repositories catch every exception, so there are no more infinite spinners.
- **Chatbot.** Streamed Arabic text is decoded as UTF-8 across chunk boundaries.
- **Custom trip.** No more blind retries of a non-idempotent POST.
- **Crash reporting.** `FlutterError.onError` and `PlatformDispatcher.onError` are routed to the reporter.
- **Startup.** The 3 s splash delay is replaced by a 1.2 s minimum that runs alongside init.
- **Home shell.** Tabs are built lazily, avatars are decoded at display size, and the nav and assistant button have semantic labels and RTL placement.
- **Android.** Application ID `com.rahhala.app` (the stray duplicate activity is removed). Backup is disabled (`allowBackup=false` plus extraction rules). There's a cleartext-blocking network security config, the unneeded `http` intent query is gone, R8 is explicit, and a loud warning prints when release falls back to debug signing. Gradle wrapper 8.12 → 8.14.3, which the current Flutter requires; the build failed without it.
- **iOS.** Bundle ID `com.rahhala.app`, `CFBundleLocalizations` (en, ar), localized permission strings, `ITSAppUsesNonExemptEncryption=false`, and `PrivacyInfo.xcprivacy`.

**Commits**
- `e71f07b` chore(repo): normalize line endings to LF
- `1153fc9` fix(core): typed failures, exhaustive Dio mapping and one configured client
- `c4c0ff3` security(auth): end sessions centrally on logout, deletion and 401
- `cacd225` fix(profile): explicit account-deleted state and guest-safe profile
- `3f6746f` fix(crash): route uncaught errors to the error reporter
- `774142c` perf(startup): run the splash minimum time alongside initialization
- `4b5c17b` perf(home): build shell tabs lazily and decode images at display size
- (see later entries for the platform and test commits)

**Verification.** `flutter analyze`: no issues. `flutter test`: all passing (see the Phase 6 entry for counts).

**Behaviour changes (user-visible)**
- Error messages are now localized and friendlier. Backend messages show only for 4xx business errors.
- An expired session sends the user to the welcome screen with a "session expired" message.
- After deleting the account the app goes to the welcome screen (previously login).
- The splash is shorter (at least 1.2 s instead of at least 3 s).
- Favourites, nearby and profile load when their tab is first opened, not at app start.
- Android: app data (language, theme, session) is no longer included in cloud backup or device transfer.
- A fresh install (iOS) starts signed out even if an old Keychain token exists.
- The Android application ID and iOS bundle ID changed. It installs as a new app next to any old `com.example.auth_app` build.

**Risks / follow-ups**
- The application ID must be confirmed before the first store upload (HUMAN_ACTIONS #1).
- `PrivacyInfo.xcprivacy` and the `InfoPlist.strings` files must be added to the Runner target in Xcode (HUMAN_ACTIONS).
