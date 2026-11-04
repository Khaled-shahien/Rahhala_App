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
storeFile=app/rahhala-release-key.jks
```

> **Note:** a relative `storeFile` is resolved from the folder that contains `key.properties`. With `android/key.properties` and the keystore in `android/app/`, use `app/rahhala-release-key.jks`. An absolute path also works.

## Step 3: Build the Release Bundle

Always build the `production` flavor with obfuscation, and keep the symbols for crash de-obfuscation:

```bash
flutter build appbundle --flavor production --release \
  --obfuscate --split-debug-info=build/symbols \
  --dart-define-from-file=config/production.json
```

If `key.properties` is missing, Gradle prints a warning and signs with the debug key. Google Play rejects such bundles.

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

1. Loads `key.properties` from the repository root or `android/` if it exists
2. Configures a `release` signing config from those properties
3. If the file is missing or incomplete, prints a **WARNING** and signs the release build with the debug key, so local release builds and CI still work

This means:
- **Debug builds** always work (default debug keystore)
- **Release builds without credentials** succeed but are debug-signed, and **Google Play rejects them**
- **Store uploads** need the real upload key

## Expected Behavior

| Command | Without `key.properties` | With `key.properties` |
|---|---|---|
| `flutter build apk --flavor production --debug` | ✅ Passes | ✅ Passes |
| `flutter build appbundle --flavor production --release` | ⚠️ Passes, debug-signed (not uploadable) | ✅ Passes, upload-signed |

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
    echo "storeFile=app/rahhala-release-key.jks" >> android/key.properties
```

## Troubleshooting

### "Missing android/key.properties"

This error means you have not created the signing configuration. Follow Steps 1-2 above.

### "Keystore was tampered with, or password was incorrect"

Double-check that `storePassword` in `key.properties` matches the password you set when creating the keystore.

### "No key with alias 'rahhala' found in keystore"

Make sure `keyAlias` in `key.properties` matches the `-alias` you used in the `keytool` command.
