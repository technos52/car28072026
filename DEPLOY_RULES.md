# Firebase Security Rules Deployment Guide

This guide will help you deploy the security rules to your Firebase project.

## Option 1: Using Firebase Console (Recommended for Quick Setup)

### Deploy Firestore Rules:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **cardealer-eb165**
3. Click on **Firestore Database** in the left menu
4. Click on the **Rules** tab
5. Copy the contents of `firestore.rules` file
6. Paste it into the rules editor
7. Click **Publish**

### Deploy Storage Rules:

1. In the same Firebase Console
2. Click on **Storage** in the left menu
3. Click on the **Rules** tab
4. Copy the contents of `storage.rules` file
5. Paste it into the rules editor
6. Click **Publish**

## Option 2: Using Firebase CLI (For Advanced Users)

If you have Firebase CLI installed, you can deploy rules directly from the command line:

### Prerequisites:
```bash
npm install -g firebase-tools
firebase login
```

### Deploy Rules:
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# Or deploy both at once
firebase deploy --only firestore:rules,storage
```

## Rules Summary

### Firestore Rules:
- Users can read/write their own user data
- Users can read all cars, but only create/update/delete their own
- All authenticated users can read from the public cars collection
- Only the car owner can modify their cars

### Storage Rules:
- Users can read all uploaded files (for viewing car images)
- Users can only write/delete files in their own user folder
- Users can only modify their own car images
- All other access is denied

## Testing

After deploying, test your app:
1. Try uploading a car image
2. Try viewing cars
3. Verify that you can only edit/delete your own cars

If you encounter permission errors, check:
- User is authenticated (logged in)
- User ID matches the resource owner
- Rules have been published successfully

