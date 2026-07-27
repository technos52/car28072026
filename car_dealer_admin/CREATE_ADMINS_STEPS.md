# How to Create Admin Users Collection

## Quick Overview

You need to create a Firestore collection named `admins` and add documents where:
- **Document ID** = Firebase Auth User UID
- **No fields needed** (empty document is fine)

---

## Step-by-Step Guide

### Step 1: Get User UID

1. Go to: https://console.firebase.google.com/
2. Select your Firebase project
3. Click **"Authentication"** in the left sidebar
4. Click **"Users"** tab
5. Find the user you want to make an admin
6. Click on the user's email/row
7. You'll see the user details. At the top, you'll see:
   - **User UID**: `abc123xyz456def789...` (long string)
8. **Copy this UID** (you'll need it in the next step)

### Step 2: Create Admins Collection

1. Still in Firebase Console, click **"Firestore Database"** in the left sidebar
2. If you see "Start in production mode" or "Start in test mode", choose one (doesn't matter for this)
3. Click **"Start collection"** button (or **"Add collection"** if collections already exist)

### Step 3: Add Collection

1. **Collection ID**: Type exactly: **`admins`** (lowercase, no spaces)
2. Click **"Next"**

### Step 4: Add First Admin Document

1. **Document ID**: 
   - Option A: Click "Auto-ID" to generate one, then delete it
   - Option B: Click "Custom ID" or just start typing
   - **Paste the User UID** you copied in Step 1
   
2. **Fields**: 
   - **Leave empty!** You don't need any fields
   - Just click **"Save"**

### Step 5: Add More Admins (Optional)

1. Click **"Add document"** button
2. **Document ID**: Paste another user's UID
3. **Fields**: Leave empty
4. Click **"Save"**
5. Repeat for each admin user

---

## Visual Example

Your Firestore structure should look like this:

```
Firestore Database
└── admins (collection)
    ├── abc123xyz456def789... (document - User UID #1)
    ├── def456uvw789ghi012... (document - User UID #2)
    └── ghi789rst012jkl345... (document - User UID #3)
```

**Important:**
- Collection name: `admins` (exactly, lowercase)
- Document IDs: User UIDs (from Authentication)
- Fields: None needed (empty documents work fine)

---

## Verify It Works

1. Make sure you've added at least one admin UID
2. Run the admin panel:
   ```bash
   flutter run -d chrome
   ```
3. Try logging in with that user's email and password
4. If successful, you'll see the dashboard
5. If you see "Access Denied", check:
   - ✅ UID is correct (no typos)
   - ✅ Document exists in `admins` collection
   - ✅ User exists in Authentication

---

## Common Mistakes

❌ **Wrong Collection Name**
- Using `admin` instead of `admins`
- Using `Admins` (capital A)
- Using spaces: `admin users`

✅ **Correct**: `admins` (lowercase, plural)

❌ **Wrong Document ID**
- Using email instead of UID
- Using display name instead of UID
- Adding fields when not needed

✅ **Correct**: User UID from Authentication (long string)

❌ **Adding Fields**
- Adding `isAdmin: true`
- Adding `email: "user@example.com"`
- Adding any other fields

✅ **Correct**: Empty document (just the document ID)

---

## Need to Remove an Admin?

1. Go to Firestore Database → `admins` collection
2. Click on the document (User UID)
3. Click the **trash icon** or **"Delete"** button
4. Confirm deletion

---

## Troubleshooting

**"Access Denied" even with correct credentials?**
- Double-check the UID in `admins` collection matches exactly
- Check for extra spaces or characters
- Verify user exists in Authentication

**Can't find User UID?**
- Go to Authentication → Users
- Click on the user
- UID is displayed at the top of the user details

**Collection not showing?**
- Make sure you're in the correct Firebase project
- Refresh the Firestore Database page
- Check you're looking at the right database (if you have multiple)


