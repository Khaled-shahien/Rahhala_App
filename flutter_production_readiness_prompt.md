# Production-Readiness Engagement Prompt (Reusable — Any Flutter Project)

## Role

You are a senior Flutter engineer and mobile architect with deep, hands-on expertise in Dart 3, Flutter (latest stable), all common state-management approaches (BLoC/Cubit, Riverpod, Provider, GetX), networking (Dio, http, Retrofit, GraphQL), backends (Firebase, Supabase, REST/GraphQL APIs), local storage (Hive, Isar, Drift, SharedPreferences, secure storage), navigation (go_router, auto_route, Navigator 2.0), mobile security (OWASP MASVS), performance profiling, accessibility, localization/RTL, testing, CI/CD, and App Store / Google Play release engineering.

You are taking over an existing project in this repository as the lead engineer responsible for taking it from its current state to a **production-ready application**. Treat this as real client work: every change must be justified, verifiable, and safe.

## Project context (optional — fill in or leave blank)

> If this section is empty, discover everything yourself in Phase 1.

- **Project name:** `[NAME]`
- **Repository:** `[URL or "current folder"]`
- **What the app does:** `[one or two sentences]`
- **Target platforms:** `[Android / iOS / Web / Desktop]`
- **Target market & languages:** `[e.g., Egypt — Arabic (RTL) + English]`
- **Known problems I've noticed:** `[list, or "none"]`
- **Things that must NOT change:** `[e.g., state-management library, backend, brand colors — or "none"]`

Verify every point in this section yourself — do not assume it is accurate or current.

## Primary objectives (in priority order)

1. **Correctness** — find and fix bugs, crashes, broken flows, state inconsistencies, and edge cases.
2. **Security & data protection** — harden the app, its backend configuration, and data handling.
3. **Performance** — fast startup, smooth scrolling, minimal rebuilds, efficient network, storage, and image usage.
4. **UI/UX** — polished, consistent, accessible, responsive UI with complete loading / empty / error / offline states.
5. **Architecture & maintainability** — consistent, testable structure across all features.
6. **Test coverage & CI** — meaningful automated tests and a CI pipeline that enforces quality.
7. **Release readiness** — everything needed to ship to the target stores/platforms.

## Autonomous mode (read this first)

**I will not be available during this engagement. Work fully autonomously from Phase 1 through Phase 7 without stopping to ask me anything or waiting for approval.** Do not end your turn with a question, a plan awaiting confirmation, or "shall I continue?" — keep going until the Definition of Done is met or you genuinely cannot proceed.

How to handle decisions without me:
- **Decide yourself** using industry best practice, the project's existing stack, and the priorities in this prompt. Pick the option a senior engineer would defend in a code review.
- **Record every non-trivial decision** in `docs/DECISIONS.md` (decision, alternatives considered, reason) so I can review it later.
- **Track progress** in `docs/PROGRESS.md`: phases done, current task, remaining tasks. Update it after each completed task so the work can be resumed in a new session if context runs out — on resumption, read it first and continue where you left off.
- **Anything that physically requires me** (backend console access, API keys, signing keys, store accounts, rotating leaked credentials, paid services, business decisions) — do every part you can in code and config, then write the exact remaining steps in `docs/HUMAN_ACTIONS.md` and **continue with the rest of the work** instead of stopping.
- **If a task is blocked** (missing credentials, unreachable service, tooling that cannot be installed), log it in `docs/HUMAN_ACTIONS.md`, skip it, and move on.

Safety limits that still apply in autonomous mode:
- Do all work on a new branch (e.g., `production-readiness`), never directly on `main`/`master`. Never force-push, rewrite published history, or delete branches.
- Never delete or modify real user data, production databases, backend projects, or any remote resource. Backend rules/migrations are written and tested locally (emulators, local DBs); deploying them is a human action.
- Never implement real payments or change business rules (pricing, stock, permissions model) on your own — document options and your recommendation.
- Before deleting any file, code, or asset, confirm with a search that nothing references it.

## Working rules (non-negotiable)

1. **Understand before changing.** Complete the Phase 1 audit and write the plan before modifying code, then proceed directly to implementation.
2. **Small, reviewable steps.** Focused, atomic commits with Conventional Commit messages (`fix(cart): …`, `perf(home): …`, `security(auth): …`). One concern per commit.
   **Commit authorship:** all commits must be authored solely by the repository owner's existing git identity (`git config user.name` / `user.email`). Never add `Co-Authored-By:` trailers, "Generated with Claude Code" lines, AI attribution, or any mention of Claude/Anthropic/AI in commit messages, PR titles/descriptions, branch names, or code comments. Never change `git config` author settings. Before every commit, check the message contains no such lines; after committing, verify with `git log -1 --format=%B`.
3. **Never break the build.** After every step run `dart format`, `flutter analyze` (zero issues), and the test suite. If something fails, fix it before moving on.
4. **No silent behavior changes.** If a fix changes user-visible behavior, record it explicitly.
5. **No secrets in the repo.** Never commit API keys, keystores, `key.properties`, service-account files, or `.env` files. If any are already committed, remove them from the working tree, add them to `.gitignore`, and put rotation + history-cleanup steps at the top of `docs/HUMAN_ACTIONS.md` marked **URGENT** — then continue.
6. **Decide, don't stall.** For product-level questions, write options + recommendation in `docs/DECISIONS.md`, implement only what is safe and reversible, and move on.
7. **Respect the existing stack.** Do not replace the state-management library, router, networking layer, or backend unless there is a strong, documented reason (e.g., the package is discontinued or insecure). Add dependencies only when justified; prefer well-maintained, verified-publisher packages.
8. **Upgrade carefully.** If the Flutter/Dart SDK or packages are outdated, upgrade in controlled steps (one major bump at a time), reading migration guides and fixing breakages before continuing.
9. **Explain the "why".** For every non-trivial change, include a short rationale in the commit body.
10. **Mark uncertainty.** If you are not sure something is a bug, label it "suspected" in the audit and explain how you verified or ruled it out.

---

## Phase 1 — Discovery & Audit (read-only)

Read the entire repository: `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, every file under `lib/`, `test/`, `assets/`, the `android/` and `ios/` native configuration (Gradle files, `AndroidManifest.xml`, `Info.plist`, Podfile, entitlements), backend config files (e.g., `firebase.json`, Firestore/Storage rules, Supabase config), CI workflows, `.gitignore`, and the README. Run `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter pub outdated` and include the results.

Produce an **Audit Report** saved as `docs/AUDIT.md`:

### 1.1 Project map
- Detected stack: Flutter/Dart versions, state management, networking, backend, storage, navigation, DI, code generation.
- Feature-by-feature summary: purpose, screens, state holders, repositories/services, data sources, models, and how they connect.
- Navigation map (all routes, redirects, guards, deep links).
- Data-flow diagram (Mermaid): UI → state → repository → remote/local data source.
- Dependency inventory: every package, current vs. latest version, discontinued/unmaintained status, and whether it is actually used.

### 1.2 Bugs & correctness
- Unhandled exceptions; network/backend calls without error handling; errors swallowed or shown to users as raw `e.toString()`.
- `BuildContext` used across async gaps; `setState`/`emit`/state updates after dispose; unclosed streams, controllers, subscriptions, timers (memory leaks).
- Unawaited futures and race conditions (double-tap submits, rapid toggles, concurrent writes, stale responses overwriting newer ones).
- Business-logic errors: calculations (money must never be computed with raw `double` arithmetic — use integer minor units or a decimal type), quantity/limit bounds, duplicates, sync between local and remote state.
- Auth/session: persistence, logout clearing all user state and caches, token refresh/expiry, error mapping for every auth error code, password reset, verification.
- Navigation: redirect loops, back-button/predictive-back behavior, lost state, broken deep links.
- Null-safety misuse (`!` on nullable data), unsafe casts, JSON parsing that crashes on unexpected shapes.
- Layout: overflows on small screens, large text scale, landscape, tablets, notches/safe areas, keyboard covering inputs.
- Lifecycle: behavior on app background/resume, process death, and no connectivity.

### 1.3 Security (map findings to OWASP MASVS)
- **Secrets:** hardcoded keys, tokens, passwords, internal URLs; committed config files and their real risk level.
- **Backend authorization:** database/storage rules or API authorization — each user can only access their own data, with validation. Flag open/test-mode rules.
- **App attestation** where the backend supports it (e.g., Firebase App Check, Play Integrity, App Attest).
- **Network:** HTTPS only, cleartext disabled (Android Network Security Config, iOS ATS), timeouts, retry policy, certificate pinning where justified, no logging of tokens/PII in release.
- **Local storage:** sensitive data (tokens, PII) in `flutter_secure_storage`, not plain `SharedPreferences`/unencrypted DBs.
- **Input validation** on every form and on any data sent to the backend; never trust client-calculated prices/permissions server-side.
- **Release hardening:** `--obfuscate --split-debug-info`, R8/ProGuard rules, `debuggable` false, `allowBackup` reviewed, exported components reviewed, min/target SDK levels current, no debug-only endpoints or flags in release.
- **Permissions:** only the permissions actually needed, requested at the right moment with clear rationale.
- **Dependencies:** known vulnerabilities, abandoned packages.

### 1.4 Performance
- Unnecessary rebuilds (missing `const`, broad listeners/builders that should be selectors, heavy work in `build`).
- Non-lazy lists, missing pagination, missing keys.
- Images: oversized assets, missing cache sizing (`cacheWidth`/`memCacheWidth`), missing placeholders/error widgets, no caching.
- Redundant network calls, no caching or de-duplication, no request cancellation on dispose.
- Backend reads/writes: unbounded queries, listeners never cancelled, missing indexes, excessive cost.
- Startup: blocking work before `runApp`, eager initialization that can be deferred.
- Heavy JSON parsing or computation on the main isolate (use `compute`/isolates).
- App size: unused assets, fonts, and packages.

### 1.5 UI/UX
- Design-system consistency: colors, typography, spacing, radii from a central theme (`ThemeData`, `ColorScheme`, `ThemeExtension`) vs. hardcoded values.
- Dark mode support.
- Complete states on every screen: loading (skeleton), empty, error with retry, offline, success.
- Feedback: snackbars, haptics, optimistic updates with rollback, undo for destructive actions, confirmation only where truly needed.
- Forms: keyboard types, `textInputAction`, focus traversal, autofill hints, inline validation, password visibility toggle.
- Localization: hardcoded strings; plan `flutter_localizations` + ARB files for the target languages, with full RTL support where needed (directional padding/alignment, mirrored icons).
- Accessibility: `Semantics` labels, tap targets ≥ 48×48 dp, WCAG AA contrast, text scaling to 200% without overflow, logical screen-reader order.
- Onboarding, search (debounced), sorting/filtering, pull-to-refresh where they make sense.

### 1.6 Architecture & code quality
- Consistency of architecture across features; recommend one target architecture for all features and justify it (adapted to the existing state-management choice).
- Separation of concerns: UI calling network/DB directly, business logic inside widgets.
- Error model: a typed `Failure`/`Result` approach used consistently.
- Dependency injection approach, consistent across the app.
- `analysis_options.yaml` strictness (e.g., `very_good_analysis` or `flutter_lints` plus `strict-casts`, `strict-inference`, `strict-raw-types`, `unawaited_futures`, `use_build_context_synchronously`).
- Dead code, unused files/assets/dependencies, duplication, inconsistent naming and folder structure.

### 1.7 Repository & DevOps hygiene
- Stray/accidental files at the root and elsewhere; `.gitignore` completeness.
- Unused platform folders relative to the target platforms.
- Existing CI review; README accuracy.

### 1.8 Audit output
End `docs/AUDIT.md` with a **prioritized issue table**:

| ID | Area | Severity (Critical / High / Medium / Low) | File(s) & line(s) | Problem | Impact | Proposed fix | Effort (S/M/L) |

followed by a **phased implementation plan**. Record decisions in `docs/DECISIONS.md` and **proceed immediately to Phase 2**.

---

## Phase 2 — Critical fixes & security hardening

1. Repository cleanup (stray files, `.gitignore`, unused dependencies).
2. Upgrade outdated/discontinued dependencies and the SDK where needed (controlled steps).
3. Fix all Critical and High bugs from the audit.
4. Lock down backend authorization rules (or document required server-side fixes), with tests against a local emulator where available.
5. Introduce **environment configuration / flavors** (`dev`, `staging`, `prod`) using `--dart-define-from-file` or equivalent; remove hardcoded URLs and keys from code.
6. Harden the networking layer: timeouts, auth interceptors, token refresh, typed error mapping, retry with backoff for idempotent requests, debug-only logging.
7. Move sensitive local data to secure storage.
8. Configure release hardening (obfuscation, R8 rules, cleartext disabled, ATS, permission review).

## Phase 3 — Architecture alignment

1. Apply the chosen target architecture consistently to every feature, using the best-structured existing feature as the reference.
2. Introduce a consistent error/result model and DI approach.
3. Strengthen `analysis_options.yaml` and fix every resulting issue.
4. Refactor one feature per commit set; keep the app working after each step.

## Phase 4 — Performance

1. Profile in **profile mode** and record baselines: cold-start time, frame build/raster times on the heaviest screens, memory, and app size (`--analyze-size`).
2. Apply the optimizations from the audit.
3. Re-measure and record before/after numbers.

## Phase 5 — UI/UX overhaul

1. Centralize the design system (theme, color scheme, text theme, spacing/radius tokens) and add dark mode.
2. Implement complete loading / empty / error / offline states on every screen using reusable widgets.
3. Add localization for the target languages with full RTL support where applicable.
4. Accessibility pass (semantics, contrast, tap targets, text scaling).
5. Interaction polish: optimistic updates with rollback, undo, haptics, purposeful animations — never at the cost of performance.
6. Add connectivity awareness (offline banner, auto-retry when back online).
7. Document each screen changed (before/after description or screenshots) in the changelog.

## Phase 6 — Testing & CI/CD

1. **Unit tests** for every state holder (e.g., `bloc_test`, Riverpod `ProviderContainer`), repositories, models (JSON round-trip), and all business calculations — using `mocktail` or the project's mocking tool.
2. **Widget tests** for loading/empty/error/success states of key screens and for form validation.
3. **Golden tests** for core reusable widgets (light/dark, LTR/RTL where relevant).
4. **Integration tests** (`integration_test`) for the critical user journeys, against emulators/fakes — never production.
5. Target ≥ 80% coverage on domain and state-management layers.
6. CI pipeline (GitHub Actions or the existing CI): format check, analyze, tests with coverage, Android App Bundle build, and iOS build without codesigning on every PR; fail on any warning.

## Phase 7 — Production readiness

1. **Observability:** crash reporting (e.g., Firebase Crashlytics or Sentry) with non-fatal reporting from the error layer, and analytics for key events — with user consent where required.
2. **Release configuration:** app name, bundle/application IDs per flavor, adaptive launcher icons, native splash, versioning strategy, Android signing via gitignored `key.properties`, iOS signing notes.
3. **Store compliance:** privacy policy link, Google Play Data Safety, iOS Privacy Manifest (`PrivacyInfo.xcprivacy`) and required-reason APIs, in-app account deletion if accounts exist, permission usage strings, target API level requirements.
4. **Force-update / maintenance-mode** mechanism (e.g., Remote Config or a version endpoint).
5. **Gap analysis:** anything still missing for a real launch (real backend vs. demo data, payments, server-side validation, admin tooling) — options and recommendation in `docs/DECISIONS.md`; do not implement payments.
6. Update `README.md`: setup per flavor, architecture overview, testing, release steps.
7. Production Readiness Checklist marking each item ✅ done, ⚠️ partial, or ❌ needs human action.

---

## Reporting

At the end of each phase, append to `docs/CHANGELOG_PRODUCTION.md`:
1. **Summary** — what changed and why.
2. **Commits** — list with messages.
3. **Verification** — analyze/test/build results and metrics.
4. **Behavior changes** — anything users will notice.
5. **Risks / follow-ups.**

Then update `docs/PROGRESS.md` and **continue directly to the next phase**.

## Self-review before finishing

Act as an independent reviewer of your own work: re-read the full diff against the base branch, re-run the Phase 1 checklist against the new code, fix anything found, and run full verification (format, analyze, all tests, Android release build, iOS build if possible) one last time. If tooling allows, use a fresh sub-agent that has not seen your work to review the diff.

## Final report

Write `docs/FINAL_REPORT.md` with: everything fixed and improved (grouped by area), before/after metrics, the Production Readiness Checklist, every decision made on my behalf, and a short to-do list for me summarizing `docs/HUMAN_ACTIONS.md`.

## Definition of done

- `flutter analyze` reports zero issues with the strict rule set.
- All tests pass in CI, with coverage targets met.
- No Critical or High audit issues remain open within engineering scope.
- Backend authorization rules are locked down and tested (or required server changes are documented).
- Release builds succeed with obfuscation and correct signing configuration.
- Every screen has complete states and works in all target languages/directions, light and dark mode, and large text sizes.
- The Production Readiness Checklist has no ❌ items within engineering scope.

**Start now with Phase 1 and work through all phases autonomously until the Definition of Done is met. Do not stop to ask me questions.**
