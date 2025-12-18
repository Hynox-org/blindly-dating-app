# Blindly App - Handover Setup Guide

This guide details the manual steps required to complete the infrastructure initialization.

## 1. SSL/TLS Pinning Setup
**Purpose**: Protects the app from Man-in-the-Middle (MITM) attacks by ensuring it only connects to the trusted Supabase server.

1.  **Get the Certificate Hash**:
    You need the SHA-256 hash of the `supabase.co` certificate (or your custom domain).
    *   **Option A (Git Bash / WSL - Recommended)**:
        Run this command in a Unix-like shell (Git Bash, WSL, or Mac/Linux terminal):
        ```bash
        openssl s_client -connect icvncmawahwbpiohrcxv.supabase.co:443 -servername icvncmawahwbpiohrcxv.supabase.co < /dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
        ```
    *   **Option B (Windows PowerShell)**:
        If you have `openssl` installed but are on PowerShell, use this syntax (requires OpenSSL in PATH):
        ```powershell
        echo | openssl s_client -connect icvncmawahwbpiohrcxv.supabase.co:443 -servername icvncmawahwbpiohrcxv.supabase.co | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
        ```
        *Note: If 'openssl' is not found, use Git Bash (included with Git for Windows).*

    *   **Option C (Online Tool)**:
        1. Go to [ssllabs.com/ssltest/](https://www.ssllabs.com/ssltest/)
        2. Enter `icvncmawahwbpiohrcxv.supabase.co`
        3. Look for the "Pin SHA256" in the results.

2.  **Update Config**:
    - Open `lib/core/security/security_config.dart`.
    - Replace the string in `_pinnedHashes` with the output from above.

## 2. Firebase App Check
**Purpose**: Prevents bots and unauthorized clients from accessing your backend.

1.  **Firebase Console**:
    - Go to [console.firebase.google.com](https://console.firebase.google.com/).
    - Create a project or use an existing one.
    - Navigate to **Build** -> **App Check**.

2.  **Register Apps**:
    - **Android**: Register your SHA-256 SHA fingerprint (from `keytool` or Google Play app signing). Enable **Play Integrity**.
    - **iOS**: Enable **DeviceCheck** and/or **App Attest**.

3.  **Enable in Code**:
    - Open `lib/core/security/security_config.dart`.
    - Uncomment the code inside `initializeAppCheck()`.
    - Ensure you have the `firebase_core` and `firebase_app_check` packages installed (add them if missing).

## 3. Supabase Database Migration
**Purpose**: Creates the necessary tables and security policies in your remote database.

1.  **Supabase Dashboard**:
    - Go to [supabase.com/dashboard](https://supabase.com/dashboard).
    - Select your project.
    - Click on the **SQL Editor** icon (sidebar).

2.  **Run Migration**:
    - Open the file `base/supabase/migrations/v1__schema.sql` from this repo.
    - Copy the entire SQL content.
    - Paste it into the Supabase SQL Editor.
    - Click **RUN**.
    - Check the **Table Editor** to confirm `profiles`, `matches`, and `swipes` tables exist.

## 4. Environment Variables
**Purpose**: Keep credentials safe and out of version control.

1.  **Create File**:
    - Create a new file named `.env` in the root of the Flutter project (same level as `pubspec.yaml`).

2.  **Add Keys**:
    - Copy the content from `.env.template` (created below) into `.env`.
    - Fill in your actual keys from Supabase and Sentry dashboards.

3.  **Usage**:
    - The app is configured to load these using `flutter_dotenv`.
