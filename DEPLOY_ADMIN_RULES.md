# Deploy Admin Firestore Rules

## Quick Deploy via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **cardealer-eb165**
3. Click on **Firestore Database** in the left menu
4. Click on the **Rules** tab
5. Copy the contents of `firestore.rules` file
6. Paste it into the rules editor
7. Click **Publish**

## What Changed

The rules now include:
- ✅ **Admins collection**: Users can check if they are admin (read their own document)
- ✅ **Admin access**: Admins can read/write all users, cars, KYC documents, etc.
- ✅ **Helper function**: `isAdmin()` checks if user's UID exists in admins collection

## After Deploying

1. Try logging into the admin panel again
2. The permission error should be resolved
3. You should be able to access the dashboard

