# Rahhala App Refactor Sprint Report

Date: 2026-04-04
Scope: Security, maintainability, performance, testing, accessibility, and code quality improvements without breaking existing behavior.

## Executive Summary
This sprint implemented high-impact, low-risk changes across security, networking robustness, logging quality, analyzer settings, modularization of a large UI screen, and critical Cubit testing.

The architecture remains unchanged:
- Feature-first + Clean Architecture
- Cubit/BLoC state management
- GetIt dependency injection
- go_router routing

## What Has Been Completed

### 1) Security (Critical)
Status: Completed

Implemented:
- Migrated sensitive user/session storage from SharedPreferences to flutter_secure_storage.
- Kept the TokenStorage public API stable to avoid behavior regressions across existing callers.
- Added migration logic to move legacy values from SharedPreferences into secure storage on initialization.
- Ensured clear/logout flows still clear all sensitive keys.

Edited files:
- lib/core/utils/token_storage.dart
- lib/core/di/service_locator.dart
- lib/core/constants/app_constants.dart
- pubspec.yaml

Notes:
- SharedPreferences is still used for non-sensitive flags such as onboarding state, which is acceptable.

---

### 2) Dependency Cleanup
Status: Completed

Implemented:
- Removed auto_route dependency (project uses go_router).
- Kept go_router as routing solution.
- Improved pubspec project description to a production-ready description.
- Added logger and flutter_secure_storage dependencies.
- Added bloc_test and mocktail for deterministic unit tests.

Edited files:
- pubspec.yaml
- pubspec.lock

---

### 3) Logging Cleanup
Status: Completed

Implemented:
- Introduced centralized logger utility.
- Replaced print/debugPrint in production paths touched during this sprint.
- Removed verbose Dio body/header logging from central networking setup to reduce risk of sensitive data leakage.

Edited files:
- lib/core/logging/app_logger.dart
- lib/features/trip_history/data/repositories/trip_history_repository_impl.dart
- lib/features/image_search/data/repositories/image_search_repository_impl.dart
- lib/features/image_search/presentation/pages/pinterest_camera_screen.dart
- lib/features/ai_recommendation/data/repositories/gemini_repository_impl.dart
- lib/core/network/dio_consumer.dart
- lib/core/di/service_locator.dart

---

### 4) Analyzer and Lint Safety
Status: Completed (baseline hardening)

Implemented:
- Stopped ignoring use_build_context_synchronously.
- Promoted dangerous ignores into visible diagnostics (warnings/info) for incremental cleanup.

Edited file:
- analysis_options.yaml

Notes:
- Existing legacy warnings still exist across unrelated files; they are now visible for planned cleanup.

---

### 5) Large File Refactor (trip_details_screen)
Status: Completed

Implemented:
- Split large screen into focused reusable widgets while preserving behavior and visual design.
- Introduced section-level components and centralized constants/strings for localization-ready structure.
- Added Semantics labels for key interactive controls and major visual elements.

Edited/new files:
- lib/features/ai_recommendation/presentation/pages/trip_details_screen.dart
- lib/features/ai_recommendation/presentation/widgets/trip_details/trip_details_theme.dart
- lib/features/ai_recommendation/presentation/widgets/trip_details/trip_details_header.dart
- lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart
- lib/features/ai_recommendation/presentation/widgets/trip_details/trip_info_sections.dart
- lib/features/ai_recommendation/presentation/widgets/trip_details/trip_save_button.dart

---

### 6) API/Network Robustness
Status: Completed

Implemented:
- Tightened validateStatus behavior (no longer accepts all status codes blindly).
- Added safe retry interceptor for transient failures only and for idempotent methods only (GET/HEAD/OPTIONS).
- Added bounded retry attempts with incremental backoff.

Edited/new files:
- lib/core/network/dio_consumer.dart
- lib/core/network/retry_interceptor.dart
- lib/core/di/service_locator.dart

Notes:
- Unsafe operations are intentionally not retried blindly.

---

### 7) State Management Quality
Status: Completed (targeted)

Implemented:
- Improved async handling in ProfileCubit to avoid unawaited writes and reduce race-condition risk in profile cache updates.

Edited file:
- lib/features/profile/domain/profile/profile_cubit.dart

---

### 8) Testing
Status: Completed (critical Cubits)

Implemented:
- Removed irrelevant default counter smoke test and replaced with meaningful sanity test.
- Added deterministic unit tests for:
  - LoginCubit
  - RegisterCubit
  - ProfileCubit
- Tests use bloc_test and mocktail with repository/service mocking.

Edited/new files:
- test/widget_test.dart
- test/features/auth/login_cubit_test.dart
- test/features/auth/register_cubit_test.dart
- test/features/profile/profile_cubit_test.dart

Validation:
- Focused critical tests pass.

---

### 9) Localization and Accessibility
Status: Partially Completed

Implemented:
- Refactored visible hardcoded strings in trip details flow into centralized constants as a localization-ready first step.
- Added Semantics labels to key actions/buttons and major image sections in refactored trip details components.

Edited files:
- lib/features/ai_recommendation/presentation/widgets/trip_details/trip_details_theme.dart
- lib/features/ai_recommendation/presentation/widgets/trip_details/trip_details_header.dart
- lib/features/ai_recommendation/presentation/widgets/trip_details/trip_save_button.dart

---

### 10) Serialization/Model Quality
Status: Partially Completed

Implemented:
- No broad migration to json_serializable/freezed in this sprint to avoid excessive churn.
- Existing critical model parsing paths preserved and stabilized where touched.

Notes:
- Full serialization migration is deferred as a dedicated track.

## Verification Results

Executed:
- flutter pub get -> Passed
- flutter analyze -> Runs successfully with existing project warnings/info (no blocking compile errors from this sprint)
- flutter test test/features/auth/login_cubit_test.dart test/features/auth/register_cubit_test.dart test/features/profile/profile_cubit_test.dart test/widget_test.dart -> Passed

Observation:
- Full flutter test includes external integration tests that may fail due to remote API quotas/rate limits and non-deterministic backend responses.

## What Is Still Pending

### High Priority Pending
1. use_build_context_synchronously remediation in auth/profile flows
- Files reported by analyzer include:
  - lib/features/auth/presentation/pages/login_page.dart
  - lib/features/auth/presentation/pages/signup_page.dart

2. Legacy warning cleanup across UI layer
- withOpacity deprecation migration across remaining files not touched in this sprint.

3. Chatbot integration test stabilization
- Convert external-network tests into tagged integration profile and/or add resilient mocking for CI stability.

### Medium Priority Pending
4. Wider localization rollout
- Replace hardcoded strings across additional feature screens with full localization pipeline (ARB + generated localizations).

5. Accessibility expansion
- Add Semantics coverage for remaining major flows (auth, profile, chatbot, custom trip flow).

6. Error mapping standardization
- Audit repositories to ensure consistent backend failure mapping patterns everywhere.

### Optional / Future
7. Serialization modernization track
- Gradual migration of selected high-change models to json_serializable (or freezed where justified), starting from auth/profile/network-critical models.

8. Network observability improvements
- Add request correlation IDs and sanitized structured logging metadata.

## Risk Register

- Integration tests relying on external APIs remain flaky due to rate limits and server-side behavior.
- Legacy analyzer warnings still present in untouched modules; current state is safer because critical ignores were removed.
- Any broad lint tightening beyond current baseline should be phased to avoid large merge conflicts.

## Suggested Next Sprint Plan

1. Fix context-after-await warnings in auth/profile screens.
2. Stabilize and separate external integration tests from core unit test gate.
3. Expand localization foundation from trip details flow into onboarding/auth/profile.
4. Run a focused deprecation cleanup batch (.withOpacity and deprecated APIs).

## Reproduction Commands

- flutter pub get
- dart format .
- flutter analyze
- flutter test
- flutter test test/features/auth/login_cubit_test.dart test/features/auth/register_cubit_test.dart test/features/profile/profile_cubit_test.dart test/widget_test.dart
