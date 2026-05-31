# Android Release Signing Setup

This document explains how to configure release signing for the Rahhala Android app.

## Prerequisites

- Java Development Kit (JDK) installed (includes `keytool`)
- Flutter SDK installed and configured

## Step 1: Generate a Release Keystore

Run the following command from the project root:

```bash
keytool -genkey -v -keystore android/app/rahhala-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias rahhala
```

You will be prompted to:
- Create a **store password** (remember this)
- Create a **key password** (remember this)
- Enter identity information (name, organization, etc.)

> **Important:** Keep your keystore file safe. If you lose it, you cannot update your app on the Play Store.

## Step 2: Create `key.properties`

Copy the example file:

```bash
cp android/key.properties.example android/key.properties
```

Then edit `android/key.properties` with your real credentials:

```properties
storePassword=REAL_STORE_PASSWORD
keyPassword=REAL_KEY_PASSWORD
keyAlias=rahhala
storeFile=rahhala-release-key.jks
```

> **Note:** `storeFile` is relative to `android/app/`. If you placed your `.jks` file in `android/app/`, just use the filename.

## Step 3: Build Release APK

```bash
flutter build apk --release
```

Or for an App Bundle (recommended for Play Store):

```bash
flutter build appbundle --release
```

## Security Rules

### Files That Must NEVER Be Committed

The following files are already in `.gitignore` and must stay ignored:

| File / Pattern | Purpose |
|---|---|
| `android/key.properties` | Contains real signing passwords |
| `*.jks` | Java Keystore files |
| `*.keystore` | Keystore files |

### What IS Safe to Commit

| File | Purpose |
|---|---|
| `android/key.properties.example` | Template with placeholder values |
| `android/app/build.gradle.kts` | Build config (reads from `key.properties`) |
| This documentation file | Setup instructions |

## How the Build System Works

The `android/app/build.gradle.kts` file:

1. Loads `android/key.properties` if it exists
2. Configures a `release` signing config from those properties
3. **Blocks the release build** with a clear error if `key.properties` is missing

This means:
- **Debug builds** always work (use the default debug keystore)
- **Release builds** require real credentials — this is intentional and production-safe
- There is **no fallback** from release to debug signing

## Expected Behavior

| Command | Without `key.properties` | With `key.properties` |
|---|---|---|
| `flutter build apk --debug` | ✅ Passes | ✅ Passes |
| `flutter build apk --release` | ❌ Fails with clear error | ✅ Passes |
| `flutter build appbundle --release` | ❌ Fails with clear error | ✅ Passes |

## CI/CD Setup

For CI environments, set the keystore and properties as secrets:

1. Base64-encode the `.jks` file and store as a CI secret
2. Store the `key.properties` content as a CI secret
3. Decode and write both files before running `flutter build`

Example (GitHub Actions):

```yaml
- name: Decode keystore
  run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/rahhala-release-key.jks

- name: Create key.properties
  run: |
    echo "storePassword=${{ secrets.STORE_PASSWORD }}" > android/key.properties
    echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
    echo "keyAlias=rahhala" >> android/key.properties
    echo "storeFile=rahhala-release-key.jks" >> android/key.properties
```

## Troubleshooting

### "Missing android/key.properties"

This error means you have not created the signing configuration. Follow Steps 1-2 above.

### "Keystore was tampered with, or password was incorrect"

Double-check that `storePassword` in `key.properties` matches the password you set when creating the keystore.

### "No key with alias 'rahhala' found in keystore"

Make sure `keyAlias` in `key.properties` matches the `-alias` you used in the `keytool` command.
