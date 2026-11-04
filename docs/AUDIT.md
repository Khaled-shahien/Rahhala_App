# Rahhala — Production-Readiness Audit (Phase 1)

Audit date: 2026-11-04 · Branch audited: `Developer` @ `e208337` (+ uncommitted `pubspec.lock` refresh) · Work branch: `production-readiness`

Everything below was verified by reading the code or running the tool named. Items marked **(suspected)** were not fully proven; the note explains why.

## 0. Baseline tool results

| Command | Result |
|---|---|
| `flutter --version` | Flutter **3.48.0-0.5.pre (beta channel)**, Dart 3.14.0 beta |
| `flutter pub get` | OK. 90 packages have newer versions that the current constraints don't allow |
| `flutter analyze` | **1 error**: `lib/core/errors/exceptions.dart:12` non-exhaustive `switch` on `DioExceptionType` (Dio 5.11 added `transformTimeout`). **The app does not compile.** |
| `flutter test` | 42 passed, 11 skipped (live-endpoint tests), **2 suites fail to load** because of the compile error above |
| `flutter pub outdated` | See §1.5 |
| `flutter doctor` | Android SDK 36.1 OK. No Xcode (Windows host), so iOS builds can't be checked on this machine |

## 1. Project map

### 1.1 Detected stack

| Concern | Choice |
|---|---|
| Language / SDK | Dart `>=3.3.0 <4.0.0`, built with Flutter beta 3.48 |
| State management | `flutter_bloc` 9 (Cubits only) |
| DI | `get_it` 8, global `sl` service locator (`lib/core/di/service_locator.dart`) |
| Networking | `dio` 5 behind `ApiConsumer`/`DioConsumer`. **Three repositories bypass it and use raw `Dio`** (custom trip, image search, trip history). A second `Dio` is used for the chatbot backend |
| Error model | `dartz` `Either<Failure, T>`; `Failure` holds only a `String message` (no type). Some repos return `Either<String, T>` |
| Backend | ASP.NET Core REST API (`rahhallaweb2026.runasp.net`) + Express chatbot on Vercel. Firebase is only for Analytics and Crashlytics, and both are off by default |
| Local storage | `flutter_secure_storage` (token and profile basics, migrated from `SharedPreferences`); `SharedPreferences` (locale, theme, onboarding flag) |
| Navigation | `go_router` 16 for top-level routes + **31 imperative `Navigator.push` calls** for feature screens |
| Localization | `flutter_localizations` + ARB (`lib/l10n`, en + ar, 283 keys, full parity). Validators, many failure messages and some SnackBars are still hard-coded English |
| Theming | `AppTheme.lightTheme`/`darkTheme` + `ThemeColor`/`AppColors` constants, `flutter_screenutil` |
| Maps / location | `flutter_map` 7, `latlong2`, `geolocator` 13, `flutter_tts` |
| Code generation | Only `gen-l10n`. No `build_runner` |
| Flavors | Android `development`/`staging`/`production` product flavors exist. Dart only reads `APP_FLAVOR`; API URLs are hard-coded in two places (`EndPoints.baseUrl` and `AppConstants.baseUrl`) |

### 1.2 Features

| Feature | Screens | State holders | Data | Notes |
|---|---|---|---|---|
| startup / splash | `SplashScreen` | `AppBootstrapCubit` | `AppBootstrapService` (onboarding flag + token) | Waits a fixed **3 s** before it even starts initializing |
| onboarding | `OnboardingScreen` | `OnboardingCubit` | `SharedPreferencesOnboardingRepository` | `StartupPreferencesService` is a dead duplicate (registered, never used) |
| auth | Welcome, Login, SignUp, ForgotPassword, OTP, ResetPassword, ResetPasswordLoggedIn, `HomePage` shell | Login/Register/ForgotPassword/VerifyOtp/ResetPassword cubits | `AuthRepoImpl` → `ApiConsumer`; `PostLoginSessionUseCase` | No 401/session-expiry handling. Login treats a response with no token as success |
| home | `HomeScreen`, `PlaceDetailsScreen`, `FavouritesScreen` | `HomeCubit` (created with `new` inside the widget), `FavouritesCubit`, `PlaceDetailsCubit`, `ReviewCubit` | `HomeRemoteDataSource` → `ApiConsumer` | Paginated feed with optimistic favourites |
| nearby | `NearbyScreen`, `NearbyPermissionPage`, `NearbyPlacesPage` | `NearbyCubit` | `NearbyRemoteDataSource`, `GeolocatorLocationService` | Guest-gated |
| ai_recommendation | Flow, TripInfo, Budget, Interests, TripSplash, TripDetails | `AiTripCubit`, `TripNavigationCubit`, Budget/Interests/Trib cubits, `NavigationVoiceCubit` | `GeminiRepositoryImpl`, trip options (remote → bundled JSON fallback), route/navigation services | `trip_day_section.dart` is 1,581 lines |
| custom_trip | CustomTripFlow, InputStep, Splash | `CustomTripCubit` | `TripApiService` (**raw Dio**) → `TripRepository` | Retries a POST up to 3× when the error *string* contains "503" |
| trip_history | `TripHistoryScreen`, `TripHistoryDetailScreen` (1,133 lines) | `TripHistoryCubit` | `TripHistoryRepositoryImpl` (**raw Dio**) | |
| image_search | `PinterestCameraScreen`, results | `ImageSearchCubit` | `ImageSearchRepositoryImpl` (**raw Dio**) | |
| chatbot | `ChatBotScreen` | `ChatBotCubit` (**lazy singleton**) | `ChatBotApiService` (own Dio) | The conversation survives logout |
| profile | `ProfilePage`, `EditProfilePage` | `ProfileCubit`, `EditProfileCubit` | `UserRepoImpl` → `ApiConsumer` | Account deletion detected by matching the word "delete" in the server message |
| trip_type_selection | selection screen | — | — | |

### 1.3 Navigation map

`go_router` (`lib/core/routing/app_router.dart`):

```
/                      splash (public)          → redirects by BootstrapResult
/onboarding            public
/welcome, /login, /signup, /forgot-password,
/otp-verification?email, /reset-password?email&otp     public
/home[?guest=true]     needs a token unless guest=true
/profile, /edit-profile, /reset-password-logged-in, /wishlist, /trip-planner   protected → /welcome
/search, /destinations, /destination-details/:id        "coming soon" placeholders (not guarded)
errorBuilder           localized 404 page
```

Guard: `_redirect` reads `AuthSessionService.hasToken` synchronously. There is no `refreshListenable`, so nothing re-runs the guard when the session ends (logout, 401). No deep links are configured in the manifest or Info.plist. Every feature screen below the shell is pushed with `Navigator.push(MaterialPageRoute)`, so those screens can't be deep-linked or restored.

### 1.4 Data flow

```mermaid
flowchart LR
  UI[Widgets / Pages] -->|context.read / sl&lt;Cubit&gt;| C[Cubits]
  C --> UC[Use cases<br/>(auth, profile photo, chatbot)]
  C --> R[Repositories]
  UC --> R
  R -->|ApiConsumer| DC[DioConsumer]
  R -.->|raw Dio — bypasses DioConsumer| D[(Dio singleton)]
  DC --> D
  D --> I1[ApiInterceptors<br/>auth header]
  D --> I2[RetryInterceptor<br/>GET only]
  D --> API[(ASP.NET API)]
  CB[ChatBotApiService] --> D2[(Dio 'chatbot')] --> EXP[(Express chatbot)]
  R --> LS[TokenStorage<br/>secure storage]
  UI -.->|sl&lt;TokenStorage&gt; directly| LS
```

### 1.5 Dependency inventory

| Package | Current | Latest | Used? | Notes |
|---|---|---|---|---|
| dio | 5.11.1 | 5.11.x | yes | The lock upgrade broke compilation (transformTimeout) |
| flutter_bloc | 9.1.x | 9.x | yes | |
| get_it | 8.3.0 | 9.3.0 | yes (1 file) | Major bump available, not required |
| go_router | 16.3.0 | 18.1.2 | yes | Two majors behind. Upgrade deferred (see DECISIONS D-07) |
| dartz | 0.10.1 | 0.10.1 | yes (28 files) | Unmaintained since 2021 but stable. Kept; replacing it is a big refactor (D-05) |
| equatable | 2.1.0 | 3.0.0 | yes | |
| flutter_screenutil | 5.9.3 | 5.9.3 | yes (64 files) | |
| flutter_secure_storage | 9.2.4 | 11.2.0 | yes | `encryptedSharedPreferences` is deprecated in v10+; upgrade needs a migration plan (D-07) |
| shared_preferences | 2.5.5 | 2.5.6 | yes | |
| cached_network_image | 3.4.1 | 4.0.6 | yes | |
| camera | 0.10.6 | 0.12.2 | yes (1 file) | |
| image_picker, photo_manager | 1.2.3 / 3.x | 1.2.4 | yes | |
| flutter_map / latlong2 | 7.0.2 / 0.9.1 | 8.3.2 / 0.10.1 | yes | |
| geolocator | 13.0.4 | 14.1.2 | yes | |
| flutter_tts, url_launcher, lottie, shimmer, smooth_page_indicator, timeago, intl, logger, country_picker, curved_navigation_bar, flutter_svg | — | — | yes | |
| firebase_core / analytics / crashlytics | 4.14 / 12.5 / 5.3 | 5.1 / 13.0 / 6.0 | yes | **No `google-services.json`, no `GoogleService-Info.plist`, no Gradle plugin**, so `Firebase.initializeApp()` can never succeed. Observability is effectively dead |
| **elegant_notification** | 2.5.1 | — | **no** | Unused → remove |
| **cupertino_icons** | 1.0.9 | — | **no** (`CupertinoIcons` never referenced) | Remove (saves ~280 KB font) |
| flutter_lints (dev) | 4.0.0 | 6.0.0 | yes | |
| flutter_launcher_icons (dev) | 0.14.x | — | yes (config in pubspec) | |

## 2. Bugs and correctness

| # | Finding | Evidence |
|---|---|---|
| B1 | **Build is broken.** Non-exhaustive switch on `DioExceptionType` | `flutter analyze`, `lib/core/errors/exceptions.dart:12` |
| B2 | **Raw-`Dio` repositories depend on DI resolution order.** `baseUrl` is only set when `DioConsumer`'s constructor runs (it overwrites `dio.options`). `TripApiService`, `ImageSearchRepositoryImpl` and `TripHistoryRepositoryImpl` post *relative* paths through the same `Dio`. If any of them resolves before `ApiConsumer`, requests go to a relative URL and fail. The same constructor also wipes the 30 s/60 s options set in the service locator | `dio_consumer.dart:11-27`, `service_locator.dart:158-162,259-317` |
| B3 | **Account deletion is detected by string matching.** `ProfilePage` clears the session only if the server's success message contains `"delete"`. Any other wording (or an Arabic message) leaves a deleted user logged in with a dead token. Unrelated success messages that contain "delete" would log the user out | `profile_page.dart:574-578` |
| B4 | **Raw exception text is shown to users.** `HomeCubit` emits `e.toString()` (users see `Instance of 'ServerException'`). The same happens in `NearbyCubit`, `ChatBotCubit` (5×), `ChatBotRepositoryImpl` (5×), `CustomTripCubit`, `TripRepository`, and in `GeminiRepositoryImpl`, which shows `TypeError` details and parser internals | grep `e.toString()` (§ list in table) |
| B5 | **No session-expiry handling.** A 401 from any endpoint becomes an English "Unauthorized" message. The token stays stored and the router guard never re-runs | `exceptions.dart`, `api_interceptors.dart` |
| B6 | **Login accepts a response with no token.** `Login.fromJson` returns `token: null`, the cubit emits `LoginSuccess`, the page calls `go('/home')`, and the guard bounces the user to `/welcome` with no explanation. The `as String?` casts also throw `TypeError` on unexpected types, and the repo only catches `ServerException`, so the cubit stays in `LoginLoading` forever | `login.dart:11-28`, `auth_repository_impl.dart:126` |
| B7 | **Repos only catch `ServerException`.** Parsing (`TypeError`/`FormatException`) escapes from `AuthRepoImpl` and `UserRepoImpl` into cubits that don't catch it (`RegisterCubit`, `ForgotPasswordCubit`, `VerifyOtpCubit`, `ResetPasswordCubit`, `ProfileCubit`). The UI then spins forever | auth/profile repos and cubits |
| B8 | **Guests trigger authenticated calls at startup.** `HomePage` builds all five tabs eagerly in an `IndexedStack`. `ProfilePage(embedded)` calls `fetch()` with no token, gets 401, and pops a red error notification on the guest's first screen. `FavouritesScreen` also fetches | `home_page.dart:58-69`, `profile_page.dart:41-47` |
| B9 | **Logout leaves user-scoped state behind.** `ChatBotCubit` is a lazy singleton, so the previous user's conversation and `contextId` survive logout and appear for the next user (privacy). Logout also doesn't clear the image cache or analytics user id | `service_locator.dart:323`, `profile_page.dart:169-181` |
| B10 | `ProfileCubit` instances are never closed (`ProfilePage` has no `dispose`). Its listener also pops *any* non-current route whenever a non-loading state arrives | `profile_page.dart:37-47,548-556` |
| B11 | **Chatbot streaming corrupts Arabic.** `String.fromCharCodes(chunk)` decodes bytes as Latin-1, so any multi-byte UTF-8 (all Arabic) comes out garbled, and chunks split mid-codepoint. Latent: the screen currently calls `sendMessage`, not `streamMessage` | `chat_bot_api_service.dart:75` |
| B12 | **Custom-trip retry keys off a string.** It retries a non-idempotent POST when `e.toString().contains('503')`; with a 3× backoff that can generate (and save) duplicate plans **(suspected: depends on whether the backend persists on 503)** | `trip_repository.dart:31-52` |
| B13 | Splash waits a fixed 3 s *before* initializing instead of using a minimum display time that runs alongside init | `app_bootstrap_cubit.dart:48` |
| B14 | `HomeCubit` race: `getHomeData()` (pull-to-refresh) can run while a `loadMore()` is in flight, and the stale page then gets appended to the fresh list. Rapid favourite toggles are not de-duplicated | `home_cubit.dart` |
| B15 | `FavouritesCubit` always says "Please log in to view your favourites" on any failure, including network errors for logged-in users | `favourites_cubit.dart:38` |
| B16 | Uncaught framework and async errors are never routed to the crash reporter: no `FlutterError.onError` / `PlatformDispatcher.onError` | `main.dart` |
| B17 | `TripNavigationCubit.close()` awaits `stopNavigation()`, which can throw (TTS), so `close()` throws. The `RoutePollingServiceImpl` `StreamController` is never closed | `trip_navigation_cubit.dart:148-154` |
| B18 | The validators (`AppValidators`) return English-only messages, so Arabic users see English form errors | `app_validators.dart` |
| B19 | `ErrorModel` / `handleDioException` messages are English literals and can't be localized | `exceptions.dart` |
| B20 | `home_page.dart` reads `TokenStorage` in `build`, so the name and avatar don't refresh after an edit until the shell rebuilds **(suspected: depends on `setState` elsewhere)** | `home_page.dart:37-40` |

No money is computed client-side; trip costs are display strings from the backend (`"4000 EGP"`), so the double-arithmetic rule doesn't apply.

## 3. Security (OWASP MASVS)

| # | MASVS | Finding | Severity |
|---|---|---|---|
| S1 | RESILIENCE / PLATFORM | Placeholder IDs: Android `applicationId`/`namespace` is `com.example.auth_app` and iOS is `com.example.authApp`. Google Play rejects `com.example.*`. There's also a stray duplicate `MainActivity` under `com/example/rahhala_app` | High |
| S2 | STORAGE | `android:allowBackup` defaults to `true`. With `flutter_secure_storage` (EncryptedSharedPreferences) a restored backup can't be decrypted on a new device (known crash and data-loss issue), and the backup also copies the `SharedPreferences` files | Medium |
| S3 | NETWORK | No explicit `usesCleartextTraffic="false"` / network security config. targetSdk ≥ 28 already blocks cleartext by default, so this is defence-in-depth only. iOS ATS is at its default (secure). Timeouts are 60 s connect/receive, which is too long | Low |
| S4 | NETWORK | Forgot-password and verify-OTP send email and OTP in the **query string**, where server logs and proxies capture them. This needs a backend change (TODO already in code) | Medium (human action) |
| S5 | STORAGE | The token and PII are in secure storage ✅ (with legacy migration ✅). `KeychainAccessibility.first_unlock` is fine | OK |
| S6 | CODE | No secrets in the repo ✅ (`key.properties`, `*.jks` gitignored; only templates committed). API base URLs are public endpoints, not secrets | OK |
| S7 | AUTH | No token expiry or refresh handling (see B5). The backend issues a JWT with no refresh token, so expiry must log the user out cleanly | High (via B5) |
| S8 | AUTH | Account deletion exists in-app ✅ (store requirement), but the session clean-up after deletion is broken (B3) | High (via B3) |
| S9 | CODE | Logging: `logger` in release uses the default `DevelopmentFilter`, which prints nothing ✅. `GoRouter.debugLogDiagnostics: kDebugMode` ✅. No tokens are logged ✅ | OK |
| S10 | RESILIENCE | Release hardening: R8 is on by default via the Flutter Gradle plugin ✅. Build commands don't document `--obfuscate --split-debug-info`. Release silently falls back to the **debug signing key** when `key.properties` is missing | Medium |
| S11 | PLATFORM | Permissions: INTERNET, FINE+COARSE location, CAMERA, READ_MEDIA_IMAGES, READ_EXTERNAL_STORAGE ≤ 32, all used. `http` VIEW query in `<queries>` is unnecessary | Low |
| S12 | PRIVACY | No iOS `PrivacyInfo.xcprivacy` (required-reason APIs: `UserDefaults` via shared_preferences, file timestamps). No `CFBundleLocalizations` for Arabic. Permission strings are English-only | Medium |
| S13 | PLATFORM | App Check / Play Integrity: N/A, because the backend is a custom ASP.NET API, not Firebase. Documented as a backend recommendation | Info |
| S14 | CODE | Test/integration files call live production endpoints when `RUN_LIVE_CHATBOT_TESTS=true` (off by default ✅) | Low |
| S15 | Backend authorization | No backend code in this repo. Ownership checks (reviews, trips, favourites) have to be verified on the API side → HUMAN_ACTIONS | Human action |

## 4. Performance

| # | Finding |
|---|---|
| P1 | `HomePage` builds all five tabs eagerly (`IndexedStack`), so startup fires the home feed, favourites, profile and nearby work at once |
| P2 | Large decoded images: `ANIS.png` (1.6 MB) renders at 76 px with no `cacheWidth`; `logo.svg` is **1.39 MB** (embedded raster) and is parsed on the UI isolate on splash, login and welcome; `welcome_image.jpg` is 1.2 MB; `app_icon.png` is 1.15 MB (only used by the icon generator, but bundled because the `assets/images/` dir is bundled) |
| P3 | Only 1 of 22 `Image.*`/`NetworkImage` usages sets cache sizing. `CircleAvatar(NetworkImage)` in the shell has no caching or error handling |
| P4 | Splash adds a fixed 3 s to every cold start (B13) |
| P5 | Unused bundled assets: `Container.svg`, `ccc.png` (130 KB). Unused fonts: `Aldhabi-Regular.ttf`, `Cairo-Medium.ttf`, `Cairo-SemiBold.ttf` aren't declared in pubspec, so they're not bundled; they're just repo noise |
| P6 | `trip_day_section.dart` (1,581 lines) and `trip_history_detail_screen.dart` (1,133 lines) are monolithic widgets with `setState` across large subtrees, so they over-rebuild **(suspected — needs a profile-mode trace on a device)** |
| P7 | JSON parsing happens on the UI isolate; trip-plan payloads are moderate (a few KB), so `compute` isn't justified yet |

## 5. UI/UX

| # | Finding |
|---|---|
| U1 | Design-system drift: **129** raw `Color(0x…)` and **431** `Colors.white/black/grey` literals in `features/`. These break dark mode in places (e.g. splash background is hard-coded white) |
| U2 | 13 hard-coded English `Text('…')` strings (trip navigation SnackBars, "Try Again", "Retry", "Go Back") plus all validator and failure messages (B18/B19) |
| U3 | No connectivity awareness or offline banner. Errors say "check your connection" but nothing retries automatically |
| U4 | Bottom nav icons have no semantic labels. The chatbot FAB is positioned with `right:` (not mirrored in RTL) and has no semantics. 40 `left:`/`right:`/`centerLeft` usages need an RTL review |
| U5 | Mixed feedback widgets: custom `showAppNotification` SnackBar plus raw `SnackBar`s |
| U6 | Login and sign-up forms are good: `textInputAction`, autofill hints, visibility toggle, inline validation ✅ |

## 6. Architecture and code quality

- Layering is inconsistent: Cubits live in `domain/` for some features and `presentation/cubit` for others. Some `data/models/*.dart` files are one-line `export`s of domain entities.
- 35 `sl<…>()` calls inside presentation code; `HomeCubit` is built with `new` inside a widget.
- The error model is stringly-typed (`Failure.message`), with no failure *kind*, so the UI can't localize or branch (e.g. on unauthorized).
- `analysis_options.yaml` is the minimal `flutter_lints` 4 set plus one rule. There's no `strict-*` and no `unawaited_futures`.
- Dead code: `StartupPreferencesService`, `NavigationExtension`, `AppConstants.baseUrl` (duplicate), `ErrorMessages`/`SuccessMessages` constants, commented-out blocks (e.g. `login_page.dart:139-195`).

## 7. Repository and DevOps hygiene

- Stray root files: `FULL_APP_REPORT.md` (a previous audit), `rules.md` (an AI-assistant rules file), `test/chatbot_api_postman_collection.json` (not a test), `test/integration/chatbot_simple_verification.dart` (not a test file).
- `assets/screenshots/` is 17 MB in git (README images, not bundled).
- **No CI** (`.github/` absent).
- `linux/`, `macos/`, `windows/`, `web/` platform folders exist, but the targets are Android and iOS. Kept (harmless; see D-09).
- The README's "Current Status" claims production readiness that the build didn't support.

## 8. Prioritized issue table

| ID | Area | Severity | File(s) & line(s) | Problem | Impact | Proposed fix | Effort |
|---|---|---|---|---|---|---|---|
| B1 | Build | **Critical** | core/errors/exceptions.dart:12 | Non-exhaustive Dio switch | App doesn't compile | Handle all types; typed failures | S |
| B2 | Network | **Critical** | core/network/dio_consumer.dart:11; di/service_locator.dart:158 | baseUrl depends on DI order | Custom trip, image search and trip history can fail | Configure Dio once at creation; DioConsumer must not mutate it | S |
| B3 | Profile/Auth | **High** | profile_page.dart:574 | Deletion detected by string match | Deleted users stay logged in | Dedicated `ProfileAccountDeleted` state | S |
| B5/S7 | Auth | **High** | api_interceptors.dart | No 401 handling | Stuck in a broken session | Unauthorized interceptor → clear session → router refresh | M |
| B4 | Errors | **High** | home_cubit.dart:62 + 15 sites | Raw exception text in UI | Leaks internals, unreadable | Typed `Failure` + localized mapping | M |
| B6/B7 | Auth/Profile | **High** | auth_repository_impl.dart, user_repository_impl.dart | Unexpected errors escape; token-less login "succeeds" | Infinite spinners, silent bounce | Catch-all mapping in repos; reject token-less login | S |
| B8 | Guest UX | **High** | home_page.dart:58; profile_page.dart:41 | Guest triggers 401 error popup | First screen shows an error | Skip fetch for guests; guest profile state | S |
| B9 | Privacy | **High** | service_locator.dart:323 | Chat history survives logout | Next user sees previous chat | Session-reset hook clears user-scoped singletons | S |
| S1 | Release | **High** | android/app/build.gradle.kts; ios project | `com.example` IDs | Play rejects upload | Real IDs, remove stray activity | S |
| B16 | Observability | **High** | main.dart | Uncaught errors not reported | Crashes invisible | Wire `FlutterError.onError` + `PlatformDispatcher.onError` | S |
| B18/B19/U2 | i18n | Medium | app_validators.dart; exceptions.dart; trip_day_section.dart | English-only messages | Arabic UX broken in forms/errors | ARB keys + localized mapping | M |
| B10 | Lifecycle | Medium | profile_page.dart:37 | Cubit never closed; pops arbitrary routes | Leak, surprise pops | Dispose; remove blanket pop | S |
| B11 | Chatbot | Medium | chat_bot_api_service.dart:75 | Latin-1 decoding of stream | Garbled Arabic | `utf8.decoder` stream transform | S |
| B12 | Custom trip | Medium | trip_repository.dart:31 | String-matched retry of a POST | Possible duplicate plans, slow failures | Remove the ad-hoc retry; typed errors | S |
| B13/P4 | Startup | Medium | app_bootstrap_cubit.dart:48 | +3 s cold start | Slow launch | Min splash duration run alongside init | S |
| B14 | Home | Medium | home_cubit.dart | Refresh vs load-more race | Duplicated or stale items | Generation token; ignore stale | S |
| B15 | Favourites | Medium | favourites_cubit.dart:38 | Wrong error copy | Misleading | Map by failure type | S |
| S2 | Storage | Medium | AndroidManifest.xml | allowBackup on | Restore crash / data copy | `allowBackup=false`, `fullBackupContent=false` | S |
| S10 | Release | Medium | build.gradle.kts | Silent debug-signing fallback; obfuscation undocumented | Wrong artifact uploaded | Warn loudly; documented obfuscated build | S |
| S12 | Privacy | Medium | ios/Runner | No privacy manifest, no ar localization | App Store rejection risk | Add `PrivacyInfo.xcprivacy`, `CFBundleLocalizations` | S |
| S4 | Security | Medium | auth_repository_impl.dart:175,199 | OTP/email in query string | Logged by proxies | Backend change (human) | — |
| P1 | Perf | Medium | home_page.dart | All tabs built eagerly | Slower start, wasted calls | Lazy tab building | S |
| P2/P3 | Perf | Medium | anis_avatar.dart etc. | Large images decoded at full size | Memory/jank | `cacheWidth`, CachedNetworkImage in shell | S |
| U3 | UX | Medium | — | No offline awareness | Poor offline experience | Connectivity banner (Phase 5) | M |
| B17 | Lifecycle | Low | trip_navigation_cubit.dart:148 | close() may throw; controller not closed | Leak / error on dispose | Guard + dispose | S |
| S3 | Network | Low | DioConsumer | 60 s timeouts; no explicit cleartext block | Long hangs | 20 s connect / 45 s receive, `usesCleartextTraffic=false` | S |
| S11 | Platform | Low | AndroidManifest.xml | Needless `http` query | Minor | Remove | S |
| A1 | Arch | Low | analysis_options.yaml | Weak lint set | Bugs slip through | Stronger rules (Phase 3) | M |
| A2 | Hygiene | Low | pubspec.yaml, root | Unused deps/files/assets, dead code | Size, noise | Clean up | S |
| A3 | DevOps | Medium | — | No CI | Regressions undetected | GitHub Actions | S |
| U1/U4 | UI | Low | features/** | Hard-coded colors; RTL `right:` | Dark-mode/RTL glitches | Incremental theme-token migration | L |

## 9. Phased implementation plan

1. **Phase 2 (critical):** fix the build (B1); centralize Dio configuration (B2) and environment config (dart-define-from-file); typed `Failure` + localized error mapping (B4, B19); repository catch-alls and token validation (B6, B7); 401 → session expiry (B5); account-deleted state (B3); guest-safe shell (B8); session-reset hook (B9); global error handlers (B16); release hardening (S1, S2, S3, S10, S11, S12); clean up unused deps and files (A2).
2. **Phase 3 (architecture):** stronger lints and fixes; move remaining `e.toString()` sites onto the typed failure model; route raw-Dio repos through `ApiConsumer`; delete dead code.
3. **Phase 4 (performance):** lazy tabs (P1), image cache sizing (P2, P3), splash timing (B13), home race fix (B14); measure APK size before and after.
4. **Phase 5 (UI/UX):** localize validators and the remaining literals (B18, U2); offline banner (U3); semantics and RTL fixes on the shell (U4); dark-mode splash.
5. **Phase 6 (tests/CI):** unit tests for the network/error layer, validators, session, cubits; widget tests for login validation and error states; GitHub Actions.
6. **Phase 7 (release):** Crashlytics wiring instructions, privacy manifest, force-update check, README, checklist, final report.
