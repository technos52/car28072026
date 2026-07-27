# Firebase Phone Authentication Setup Instructions

## Issue Fixed
✅ Removed "Enter phone number to send one time Password" text from phone screen
✅ Fixed app ID mismatch in `firebase_options.dart`

## Required: Register SHA-256 Fingerprint

The error "This request is missing a valid app identifier" occurs because the SHA-256 fingerprint is not registered in Firebase Console. Firebase Phone Authentication requires SHA-256 for Play Integrity checks.

### Your SHA-256 Fingerprint:
```
C6:A1:38:37:02:99:DB:F1:7A:17:5B:A3:3F:AD:A1:17:3E:16:31:3C:49:C3:D0:C1:6D:20:F3:52:90:13:92:61
```

### Steps to Register:

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Select your project: `cardealer-eb165`

2. **Navigate to Project Settings**
   - Click the gear icon ⚙️ next to "Project Overview"
   - Select "Project settings"

3. **Add SHA-256 Fingerprint**
   - Scroll down to "Your apps" section
   - Find your Android app with package name: `com.car.dealer`
   - Click "Add fingerprint" button
   - Paste this SHA-256 (without spaces):
     ```
     C6A138370299DBF17A175BA33FADA1173E16313C49C3D0C16D20F35290139261
     ```
   - Click "Save"

4. **For Release Builds**
   - When you create a release keystore, you'll need to register its SHA-256 fingerprint as well
   - Get it using: `keytool -list -v -keystore <your-release-keystore>`

### Important Notes:

- The SHA-256 fingerprint is required for **Play Integrity API** which Firebase uses for phone authentication
- After adding the fingerprint, wait a few minutes for changes to propagate
- Make sure you're using the correct package name: `com.car.dealer`
- You may need to rebuild the app after registering the fingerprint

### Verify Setup:

After registering, try sending an OTP again. The error should be resolved.

## Current Configuration:

- **Package Name**: `com.car.dealer`
- **App ID**: `1:1073666893011:android:cee520f85f2665ade66026`
- **Project ID**: `cardealer-eb165`
- **SHA-1**: `CB:AC:78:A4:E5:70:48:35:49:BE:A6:20:05:D3:48:08:9F:53:C3:A7` (already registered)
- **SHA-256**: `C6:A1:38:37:02:99:DB:F1:7A:17:5B:A3:3F:AD:A1:17:3E:16:31:3C:49:C3:D0:C1:6D:20:F3:52:90:13:92:61` (needs to be registered)

