# Quick Setup Guide

## 🔥 Step 1: Configure Firebase (Choose ONE method)

### Method 1: Automatic (Recommended) ⚡

Run this command in the admin panel directory:
```bash
cd car_dealer_admin
flutterfire configure
```

- Select your Firebase project: **`cardealer-eb165`** (or the project where your data is stored)
- Select platform: **Web** (press Space, then Enter)
- Done! The config will be updated automatically.

### Method 2: Manual from Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select project: **`cardealer-eb165`** (or your data project)
3. Click ⚙️ **Settings** → **Project settings**
4. Scroll to **"Your apps"** → Click **"Add app"** → Select **Web** (</>)
5. Register app (name: "Admin Panel")
6. Copy the config values
7. Update `lib/firebase_options.dart` with the values

---

## 👥 Step 2: Create Admin Users

### Quick Steps:

1. **Get User UID:**
   - Go to Firebase Console → **Authentication** → **Users**
   - Click on the user you want to make admin
   - Copy the **User UID** (long string like `abc123xyz...`)

2. **Add to Admins Collection:**
   - Go to Firebase Console → **Firestore Database**
   - Click **"Start collection"** (or **"Add collection"**)
   - Collection ID: **`admins`** (exactly, lowercase)
   - Click **"Next"**
   - Document ID: **Paste the User UID** you copied
   - **Leave fields empty** (no fields needed)
   - Click **"Save"**

3. **Repeat** for each admin user you want to add

### Visual Guide:

```
Firestore Database
└── admins (collection)
    ├── abc123xyz456... (document ID = User UID)
    ├── def789uvw012... (document ID = User UID)
    └── ghi345rst678... (document ID = User UID)
```

**Important:** Only the document ID (User UID) is needed. No fields required!

---

## ✅ Step 3: Test

1. Run the admin panel:
   ```bash
   flutter run -d chrome
   ```

2. Login with admin user's email and password
3. If successful, you'll see the dashboard!

---

## 🚀 Step 4: Deploy to Firebase Hosting

```bash
flutter build web --release
firebase deploy --only hosting
```

Or use the script:
```bash
.\deploy.ps1
```

---

## ❓ Troubleshooting

**"Access Denied" error?**
- ✅ Check: User UID exists in `admins` collection
- ✅ Check: Using correct email/password
- ✅ Check: User exists in Firebase Authentication

**Can't see data?**
- ✅ Check: Admin panel uses same Firebase project as main app
- ✅ Check: Firestore has data in `users`, `cars` collections

**Need help?**
- See detailed guide: `SETUP_GUIDE.md`


