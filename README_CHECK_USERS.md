# Check Phone OTP Verified Users in Firebase

This script helps you check if there are any phone-authenticated users in your Firebase project.

## Setup Instructions

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Get Firebase Service Account Key:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project (either `cardealer-eb165` or `car-dealer-00`)
   - Go to Project Settings (gear icon) → Service Accounts
   - Click "Generate new private key"
   - Save the downloaded JSON file as `serviceAccountKey.json` in the project root
   - **IMPORTANT:** Add `serviceAccountKey.json` to `.gitignore` to keep it secure

3. **Run the script:**
   ```bash
   npm run check-users
   ```
   Or directly:
   ```bash
   node check_phone_users.js
   ```

## Alternative: Check via Firebase Console

You can also check manually:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Authentication → Users
4. Look for users with phone numbers or "phone" provider

## Note

The script checks both Firebase projects:
- `cardealer-eb165` (Android/iOS)
- `car-dealer-00` (Web/macOS/Windows)

You may need to run the script separately for each project if they have different service accounts.

