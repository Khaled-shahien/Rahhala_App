# Actions That Need the Owner

These steps can't be done from the codebase: they need console access, credentials, store accounts or business decisions. Everything that *could* be done in code has already been done.

> No committed secrets were found (`key.properties`, keystores, `google-services.json` and `.env` are all absent or gitignored), so there is **no URGENT credential rotation**.

## Release blockers

1. **Confirm the app identifiers** (DECISIONS D-08). The code now uses `com.rahhala.app` on Android (with `.dev`/`.staging` suffixes) and iOS. Once an app is uploaded to Google Play under an ID, that ID can never change. If you want a different ID, change `applicationId`/`namespace` in `android/app/build.gradle.kts`, the Kotlin package folder of `MainActivity.kt`, and `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner.xcodeproj/project.pbxproj`.
2. **Create the Android upload keystore** and `key.properties` (see `docs/android_release_signing.md`). Without it, release builds fall back to the debug key, which Play rejects. The Gradle build now prints a warning when that happens.
3. **Enable Firebase (Crashlytics and Analytics)** if you want production crash reports:
   1. Create a Firebase project, then add Android apps `com.rahhala.app`, `com.rahhala.app.dev` and `com.rahhala.app.staging`, and an iOS app.
   2. Run `dart pub global activate flutterfire_cli`, then `flutterfire configure`. This generates `lib/firebase_options.dart` and the platform files.
   3. Add the `com.google.gms.google-services` and `com.google.firebase.crashlytics` Gradle plugins (FlutterFire CLI does this).
   4. In `lib/core/di/service_locator.dart`, pass `options: DefaultFirebaseOptions.currentPlatform` to `Firebase.initializeApp`.
   5. Set `"ENABLE_CRASH_REPORTING": true` (and `ENABLE_ANALYTICS` once you have consent copy) in `config/production.json`.
   6. Upload the obfuscation symbols for each release: `firebase crashlytics:symbols:upload --app=<APP_ID> build/symbols`.
4. **Privacy policy and terms URLs.** `AppConstants.privacyPolicyUrl` points to `https://rahhala.com/privacy`, which must actually exist before store submission. Both stores require a live privacy-policy URL.
5. **Google Play Data Safety form.** Declare: email, name, phone, country, birth date, gender, profile photo (account management); approximate and precise location (app functionality, not stored per the client, so verify on the backend); photos (image search, sent to the server); chat messages (sent to the chatbot backend); crash logs (if Crashlytics is enabled). Data is encrypted in transit (HTTPS). In-app account deletion exists (Profile → Delete account).
6. **App Store privacy "nutrition label"** with the same data. `ios/Runner/PrivacyInfo.xcprivacy` has been added; re-check it with Xcode's privacy report after `pod install`.
7. **iOS signing:** set the Development Team in Xcode, register the bundle ID `com.rahhala.app`, and create provisioning profiles. This can't be done on Windows. Build on a Mac with `flutter build ipa --obfuscate --split-debug-info=build/symbols`.
7a. **iOS: add new files to the Runner target (Xcode, about 2 minutes).** Open `ios/Runner.xcworkspace`, then drag into the Runner group with "Add to target: Runner" ticked:
   - `ios/Runner/PrivacyInfo.xcprivacy`
   - `ios/Runner/en.lproj/InfoPlist.strings` and `ios/Runner/ar.lproj/InfoPlist.strings`. Select the file and use *Localize…* in the File inspector so both languages appear as one localized resource.

   These files were created on a Windows machine, where the Xcode project can't be safely edited.
7b. **iOS flavors.** `pubspec.yaml` sets `default-flavor: production`, which Android uses, but the iOS project has only the default `Runner` scheme. Either create Xcode schemes and build configurations named `development`, `staging` and `production` (see https://docs.flutter.dev/deployment/flavors-ios), or remove `default-flavor` before building iOS. Until then the CI iOS job is marked informational (`continue-on-error`).

## Backend (API owner)

8. **Move the OTP and email out of query strings** for `POST /api/Auth/forgot-password` and `POST /api/Auth/verify-otp` (AUDIT S4). The client code already has TODOs; change it to send the request body once the API accepts it.
9. **Verify server-side authorization** (AUDIT S15). The client can't prove these:
   - `PUT/DELETE /api/Home/Reviews/{id}` must only allow the review's author.
   - `GET /api/gemini/My_Trips/{id}` and `Regenerate_Trip` must only return or modify the caller's own trips (no IDOR).
   - `DELETE /api/User/DeleteProfile` must delete or anonymize all of the user's data (store requirement).
   - Rate-limit `Login`, `forgot-password` and `verify-otp` (brute force on a 6-digit OTP).
   - JWT expiry: return **401** (not 200 with an error body) for expired tokens. The app now logs users out on 401.
10. **Chatbot backend** (`express-js-on-vercel-ten-roan-21.vercel.app`) is unauthenticated and on a generic Vercel subdomain. Add auth (the user's JWT) and rate limiting, and move it to a domain you own. Then update `CHATBOT_BASE_URL` in `config/*.json`.
11. **Optional force-update endpoint** (DECISIONS D-15): host a JSON file such as `{"minSupportedBuild":1,"latestBuild":1,"maintenance":false}` and set `APP_CONFIG_URL` in `config/production.json`.
12. **Staging environment:** `config/staging.json` points to the production API because no staging API exists. Create one and update the file.

## Recommended follow-ups (not blockers)

13. Upgrade the deferred majors one at a time, each with a full regression pass (DECISIONS D-07): `go_router` 18, `flutter_secure_storage` 11 (read the Android migration notes, since stored tokens may need re-login), `flutter_map` 8, `geolocator` 14, `firebase_*` majors, `camera` 0.12.
14. Switch to the **stable** Flutter channel for release builds. This machine is on beta 3.48.0-0.5.pre; CI pins stable.
15. Run a profile-mode session on a mid-range Android device (Phase 4 metrics that need hardware): `flutter run --profile --flavor development --dart-define-from-file=config/development.json`, then record frame times on Home, Trip Details and Trip History Detail in DevTools.
16. Replace the 1.39 MB `assets/images/logo.svg` (it embeds a raster image) with a true vector or an optimized PNG/WebP export from the designer.
