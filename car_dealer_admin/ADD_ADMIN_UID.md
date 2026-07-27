# Quick Guide: Adding Admin UID

## Your Admin UID
`MPmb2LkwsjhQRs3WLID0WB1AIQt2`

## Steps to Make This User an Admin

### Step 1: Add UID to Admins Collection

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project
3. Go to **Firestore Database**
4. Click **"Start collection"** (if no collections exist) or find the **`admins`** collection
5. If `admins` collection doesn't exist:
   - Collection ID: **`admins`**
   - Click **"Next"**
6. Add document:
   - **Document ID**: `MPmb2LkwsjhQRs3WLID0WB1AIQt2` (paste your UID)
   - **Fields**: Leave empty (no fields needed)
   - Click **"Save"**

### Step 2: Get/Create Email and Password

The email/password must be from **Firebase Authentication**, not Firestore.

**Option A: User Already Exists in Authentication**
1. Go to Firebase Console → **Authentication** → **Users**
2. Find the user with UID: `MPmb2LkwsjhQRs3WLID0WB1AIQt2`
3. Use their email and password (if you know it)
4. If you don't know the password, use Option B

**Option B: Create New User or Reset Password**
1. Go to Firebase Console → **Authentication** → **Users**
2. If user exists: Click on the user → **"Reset password"** → Enter email → Send reset link
3. If user doesn't exist: Click **"Add user"** → Enter email/password → Create user
4. **Important**: Make sure the UID matches `MPmb2LkwsjhQRs3WLID0WB1AIQt2`

**Option C: Create User Programmatically (if UID doesn't match)**
If the user in Authentication has a different UID, you need to either:
- Use the existing user's UID and add THAT UID to admins collection, OR
- Create a new user and use their UID

## How It Works

1. User logs in with email/password → Firebase Authentication verifies credentials
2. If login successful → System gets the user's UID
3. System checks if UID exists in `admins` collection
4. If UID found in `admins` → User is granted admin access
5. If UID NOT found → "Access Denied" error

## Quick Checklist

- [ ] User exists in Firebase Authentication with email/password
- [ ] User's UID is `MPmb2LkwsjhQRs3WLID0WB1AIQt2` (or you know the actual UID)
- [ ] UID is added as a document ID in `admins` collection in Firestore
- [ ] You know the email and password for that user

## Need Help?

If the UID doesn't match any user in Authentication, you can:
1. Create a new user in Authentication
2. Get their UID
3. Add that UID to the admins collection

