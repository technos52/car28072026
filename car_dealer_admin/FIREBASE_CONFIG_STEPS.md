# How to Get Firebase Web Configuration

## Your Main App Projects
- **Android/iOS**: `cardealer-eb165`
- **Web**: `car-dealer-00`

The admin panel needs to use the **same project where your Firestore data is stored**.

---

## Method 1: Using FlutterFire CLI (Easiest) ⚡

1. Open terminal in admin panel directory:
   ```bash
   cd car_dealer_admin
   ```

2. Run:
   ```bash
   flutterfire configure
   ```

3. Follow the prompts:
   - Select Firebase project: Choose `cardealer-eb165` (or the project with your data)
   - Select platforms: Press **Space** to select **Web**, then **Enter**
   - Done! The file `lib/firebase_options.dart` is automatically updated

---

## Method 2: From Firebase Console (Manual)

### Step 1: Get to Project Settings

1. Go to: https://console.firebase.google.com/
2. Select your Firebase project (likely `cardealer-eb165`)
3. Click the **⚙️ Settings** icon (gear) next to "Project Overview"
4. Click **"Project settings"**

### Step 2: Add Web App (if not exists)

1. Scroll down to **"Your apps"** section
2. If you see a Web app already, skip to Step 3
3. If not, click **"Add app"** button
4. Click the **Web** icon (</>)
5. Register your app:
   - App nickname: `Admin Panel` (or any name)
   - Firebase Hosting: Leave unchecked (we'll set that separately)
   - Click **"Register app"**

### Step 3: Copy Configuration

You'll see a code snippet like this:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyDk4Uo4Gao0qdeN6QbaU48FbNmZCmGKiS0",
  authDomain: "cardealer-eb165.firebaseapp.com",
  projectId: "cardealer-eb165",
  storageBucket: "cardealer-eb165.firebasestorage.app",
  messagingSenderId: "1073666893011",
  appId: "1:1073666893011:web:abc123def456"
};
```

### Step 4: Update Admin Panel Config

Open `lib/firebase_options.dart` and update the `web` section:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'PASTE_API_KEY_HERE',
  appId: 'PASTE_APP_ID_HERE',
  messagingSenderId: 'PASTE_MESSAGING_SENDER_ID_HERE',
  projectId: 'PASTE_PROJECT_ID_HERE',
  authDomain: 'PASTE_AUTH_DOMAIN_HERE',
  storageBucket: 'PASTE_STORAGE_BUCKET_HERE',
  measurementId: 'PASTE_MEASUREMENT_ID_HERE', // Optional, can be null
);
```

**Map the values:**
- `apiKey` → `apiKey` from Firebase Console
- `appId` → `appId` from Firebase Console
- `messagingSenderId` → `messagingSenderId` from Firebase Console
- `projectId` → `projectId` from Firebase Console
- `authDomain` → `authDomain` from Firebase Console
- `storageBucket` → `storageBucket` from Firebase Console
- `measurementId` → Optional, can be removed if not available

---

## Method 3: Copy from Main App (If Same Project)

If your main app's web config uses the same project, you can copy it:

1. Open `car_dealer/lib/firebase_options.dart`
2. Copy the `web` configuration
3. Paste it into `car_dealer_admin/lib/firebase_options.dart`

**Note:** Make sure both apps use the same Firebase project for data access.

---

## Verify Configuration

After updating, test it:

```bash
flutter run -d chrome
```

If you see Firebase initialization errors, double-check:
- ✅ All values are copied correctly
- ✅ No extra spaces or quotes
- ✅ Using the same Firebase project as your main app


