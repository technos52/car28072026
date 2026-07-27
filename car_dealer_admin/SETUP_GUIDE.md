# Admin Panel Setup Guide

## Step 1: Get Firebase Web Configuration

Your main app uses Firebase project: **`cardealer-eb165`** (for Android/iOS) and **`car-dealer-00`** (for web).

### Option A: Using FlutterFire CLI (Recommended)

1. Open terminal in the admin panel directory:
   ```bash
   cd car_dealer_admin
   ```

2. Run FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

3. Select your Firebase project (choose the one that has your data - likely `cardealer-eb165`)
4. Select platforms: **Web** (press Space to select, Enter to confirm)
5. The CLI will automatically update `lib/firebase_options.dart`

### Option B: Manual Configuration from Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (the one with your data - likely `cardealer-eb165`)
3. Click the **⚙️ Settings** icon (gear icon) next to "Project Overview"
4. Scroll down to "Your apps" section
5. If you don't have a Web app, click **"Add app"** and select **Web** (</> icon)
6. Register your app with a nickname (e.g., "Admin Panel")
7. Copy the Firebase configuration object that looks like this:
   ```javascript
   const firebaseConfig = {
     apiKey: "AIzaSy...",
     authDomain: "your-project.firebaseapp.com",
     projectId: "your-project-id",
     storageBucket: "your-project.appspot.com",
     messagingSenderId: "123456789",
     appId: "1:123456789:web:abc123"
   };
   ```

8. Update `lib/firebase_options.dart` with these values:
   ```dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'YOUR_API_KEY',
     appId: 'YOUR_APP_ID',
     messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
     projectId: 'YOUR_PROJECT_ID',
     authDomain: 'YOUR_AUTH_DOMAIN',
     storageBucket: 'YOUR_STORAGE_BUCKET',
     measurementId: 'YOUR_MEASUREMENT_ID', // Optional, can be removed if not available
   );
   ```

## Step 2: Create Admin Users Collection

### Method 1: Using Firebase Console (Easiest)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your Firebase project
3. Click on **Firestore Database** in the left sidebar
4. Click **"Start collection"** (if it's a new database) or click **"Add collection"**
5. Collection ID: Type **`admins`** (exactly as shown, lowercase)
6. Click **"Next"**
7. For the first admin user:
   - **Document ID**: Enter the Firebase Auth UID of the admin user
     - To find a user's UID: Go to **Authentication** > **Users** in Firebase Console
     - Copy the UID (it's a long string like `abc123xyz456...`)
   - **Fields**: Leave empty (no fields needed, just the document ID)
   - Click **"Save"**
8. Repeat step 7 for each admin user you want to add

### Method 2: Using Firebase CLI

1. Create a file `add_admin.js`:
   ```javascript
   const admin = require('firebase-admin');
   const serviceAccount = require('./serviceAccountKey.json');

   admin.initializeApp({
     credential: admin.credential.cert(serviceAccount)
   });

   const db = admin.firestore();

   // Add admin user (replace with actual UID)
   const adminUID = 'USER_FIREBASE_AUTH_UID_HERE';
   
   db.collection('admins').doc(adminUID).set({})
     .then(() => {
       console.log('Admin added successfully!');
       process.exit(0);
     })
     .catch((error) => {
       console.error('Error adding admin:', error);
       process.exit(1);
     });
   ```

2. Download service account key from Firebase Console:
   - Go to Project Settings > Service Accounts
   - Click "Generate new private key"
   - Save as `serviceAccountKey.json` in admin panel directory

3. Run: `node add_admin.js`

### Method 3: Direct Firestore Rules (Not Recommended for Production)

You can also add admins directly via Firestore console by creating documents manually.

## Step 3: Get User UID for Admin Access

To find a user's Firebase Auth UID:

1. Go to Firebase Console > **Authentication** > **Users**
2. Find the user you want to make an admin
3. Click on the user
4. Copy the **User UID** (it's displayed at the top)
5. Use this UID as the document ID in the `admins` collection

## Step 4: Test Admin Access

1. Build and run the admin panel:
   ```bash
   flutter run -d chrome
   ```

2. Try logging in with the admin user's email and password
3. If the UID exists in the `admins` collection, you'll be granted access
4. If not, you'll see an "Access Denied" message

## Important Notes

- **Same Firebase Project**: The admin panel MUST use the same Firebase project as your main app to access the same data
- **Admin Collection**: The `admins` collection only needs document IDs (UIDs), no fields required
- **Security**: Only users whose UID exists in the `admins` collection can access the admin panel
- **Multiple Admins**: You can add multiple admin users by creating multiple documents in the `admins` collection

## Troubleshooting

**Problem**: "Access Denied" even with correct credentials
- **Solution**: Make sure the user's UID exists as a document ID in the `admins` collection

**Problem**: Can't see data in admin panel
- **Solution**: Verify the admin panel is using the same Firebase project as your main app

**Problem**: Firebase configuration errors
- **Solution**: Use `flutterfire configure` to automatically set up the configuration


