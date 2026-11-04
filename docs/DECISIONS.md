# Engineering Decisions Log

These are decisions made on the owner's behalf during the production-readiness engagement. Each one lists the alternatives considered and why the choice was made, so it can be reviewed or reversed.

---

### D-01 · Keep the existing stack (Cubit + get_it + Dio + go_router + dartz)
- **Decision:** Don't swap out state management, DI, networking, routing or the `Either` type.
- **Alternatives:** Riverpod; `fpdart` instead of `dartz`; `retrofit`.
- **Why:** The stack works, the team knows it, and swapping it would touch about 200 files with no user-facing gain. The prompt says to respect the existing stack.

### D-02 · Typed failures instead of message strings
- **Decision:** `Failure` gets a `FailureType` (`network`, `timeout`, `unauthorized`, `forbidden`, `notFound`, `validation`, `server`, `parsing`, `cancelled`, `unknown`). The server's own message stays optional. The UI maps the type to localized text via `context.l10n` (`FailureMessages`). The server message is shown only for `validation`/business errors, where the backend's text is meaningful.
- **Alternatives:** Keep strings and translate them by pattern matching; one subclass per error.
- **Why:** A type lets the UI localize, branch (for example, unauthorized means logging out) and test without parsing text. It's backward compatible because `Failure.message` still exists.

### D-03 · One configured `Dio` created in the service locator
- **Decision:** The service locator builds the base `Dio` with `BaseOptions` from `AppConfig`. `DioConsumer` no longer overwrites `dio.options` or clears interceptors.
- **Alternatives:** Give each raw-Dio repository its own `Dio`; move every repository to `ApiConsumer` right away.
- **Why:** It fixes the DI-order bug (AUDIT B2) in one place and keeps the change small. The raw-Dio repositories are migrated to `ApiConsumer` in Phase 3 where that's safe.

### D-04 · Environment config through `--dart-define-from-file`
- **Decision:** Add `config/{development,staging,production}.json` holding `APP_FLAVOR`, `API_BASE_URL`, `CHATBOT_BASE_URL`, `ENABLE_ANALYTICS`, `ENABLE_CRASH_REPORTING`, and an optional `APP_CONFIG_URL`. `AppConfig` reads them with `String.fromEnvironment` and falls back to the current production URLs, so plain `flutter run` keeps working.
- **Alternatives:** `flutter_dotenv` (ships the `.env` as an asset, so not secret-safe); `envied` (codegen).
- **Why:** It's built in, needs no dependency, and is compile-time constant. These values are public endpoints, not secrets, so committing the JSON files is fine.

### D-05 · Keep `dartz`
- **Decision:** Keep `dartz` despite no releases since 2021.
- **Alternatives:** `fpdart`; Dart 3 sealed `Result`.
- **Why:** It's pure Dart with no platform code, so the security and breakage risk is very low. Migrating would touch 28 files for no functional gain. It's recorded as a follow-up.

### D-06 · Session expiry: log out on 401 and send the user to /welcome
- **Decision:** A 401 on an authenticated request clears the session (`SessionManager.expire()`) and refreshes the router, which redirects to `/welcome` with a localized "session expired" message. Auth endpoints (`/api/Auth/*`) are excluded, so a wrong password stays a normal error.
- **Alternatives:** Token refresh.
- **Why:** The backend issues no refresh token. Logging out cleanly is the only correct behaviour available.

### D-07 · Defer major package upgrades that need migrations
- **Decision:** Fix compatibility with the already-resolved lock (Dio 5.11). Don't bump `go_router` 16→18, `flutter_secure_storage` 9→11, `flutter_map` 7→8, `geolocator` 13→14, `firebase_*` majors or `camera` 0.10→0.12 in this engagement.
- **Alternatives:** Upgrade everything now.
- **Why:** Each one needs a migration (secure-storage v10+ changes the Android cipher and data migration, and go_router 17 changes `redirect`/`onExit` semantics), and none of them fixes a known vulnerability. They're tracked in HUMAN_ACTIONS as follow-ups, one major at a time.

### D-08 · App identifiers
- **Decision:** Change the Android `applicationId` and `namespace` from `com.example.auth_app` to **`com.rahhala.app`**, and the iOS bundle ID from `com.example.authApp` to **`com.rahhala.app`**. Flavors keep their `.dev`/`.staging` suffixes.
- **Alternatives:** Keep `com.example` (Play rejects it); ask the owner first.
- **Why:** Store blocker. Nothing has been published under the old ID (it's a placeholder), so this is fully reversible before the first upload. **The owner must confirm the ID before the first store upload** (HUMAN_ACTIONS).

### D-09 · Keep the desktop and web platform folders
- **Decision:** Don't delete `linux/`, `macos/`, `windows/`, `web/`.
- **Why:** They're harmless, they keep `flutter create` parity, and deleting them can't be undone cheaply. CI builds only Android (and iOS on macOS runners).

### D-10 · Lazy tab construction in the home shell
- **Decision:** Build each bottom-nav tab only the first time it's selected, then keep it alive. It's still an `IndexedStack`, so tab state survives switching.
- **Alternatives:** `PageView` with keep-alive.
- **Why:** It removes the startup burst of network calls (and the guest 401 popup) without changing how navigation feels. **Behaviour change:** favourites and profile load on first visit, not at app start.

### D-11 · Splash minimum duration
- **Decision:** Replace the fixed 3 s pre-delay with a 1.2 s minimum display time that runs at the same time as bootstrap.
- **Why:** The brand moment stays and up to about 1.8 s comes off every cold start. **Behaviour change:** the splash is shorter.

### D-12 · Remove the custom-trip POST retry loop
- **Decision:** Delete the string-matched 503 retry around `Generate_Specific_Plan`.
- **Why:** Retrying a non-idempotent generation endpoint can create duplicate plans and triples the wait on failure. Users still get a "try again" button. Idempotent GET retries stay in `RetryInterceptor`.

### D-13 · Chatbot conversation scope
- **Decision:** `ChatBotCubit` stays a singleton, so a conversation survives leaving and re-entering the chat screen, but it's cleared by the session-reset hook on logout, account deletion and session expiry.
- **Alternatives:** A factory cubit per screen (loses the conversation on every exit).
- **Why:** It keeps the current UX and fixes the cross-user privacy leak.

### D-14 · Android backup disabled
- **Decision:** Set `android:allowBackup="false"` and `android:fullBackupContent="false"`, plus `dataExtractionRules` that exclude everything.
- **Why:** Restored EncryptedSharedPreferences can't be decrypted on a new device (it crashes or the token is lost), and the token shouldn't leave the device. **Behaviour change:** settings such as language and theme aren't restored on a new phone.

### D-15 · Force update / maintenance mode via an optional remote JSON
- **Decision:** Add `AppUpdateService`. It fetches `APP_CONFIG_URL` (if configured) returning `{ "minSupportedBuild": int, "latestBuild": int, "maintenance": bool, "message"?: string, "storeUrl"?: string }` and blocks the app at splash when it's below the minimum build or in maintenance. When the URL isn't set it does nothing. Network failures **fail open**: a dead config endpoint never locks users out.
- **Alternatives:** Firebase Remote Config (Firebase isn't configured for this project yet).
- **Why:** It works with any static hosting (even a GitHub Pages JSON) and has no new dependency.

### D-16 · Lint level
- **Decision:** Keep `flutter_lints` as the base and add `strict-inference`, `strict-raw-types` and selected rules (`unawaited_futures`, `cancel_subscriptions`, `close_sinks`, `avoid_print`, `prefer_const_constructors`, …). `strict-casts` was evaluated (see PROGRESS for counts) and turned on only if the resulting fixes stayed mechanical.
- **Why:** `strict-casts` on a 28k-line JSON-heavy codebase produces hundreds of `dynamic` casts. Fixing them all blindly risks behaviour changes in the parsers.

### D-17 · Payments
- **Decision:** No payments are implemented. Trip "costs" are AI-generated display strings.
- **Recommendation (if booking is added later):** Server-side priced checkout through Paymob or Fawry (Egypt market) with integer minor units (piasters) on the server. The client never computes the price.

### D-18 · Commit attribution
- **Decision:** All commits are authored as the repository's existing git identity and contain no AI-attribution trailers, as the engagement brief requires.
