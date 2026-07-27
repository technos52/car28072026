# Car Dealer Admin Panel

Admin panel for managing the Car Dealer application. Built with Flutter and deployed on Firebase Hosting.

## Features

- **Dashboard**: Overview statistics including total users, cars, KYC status, etc.
- **User Management**: View and manage all users, their shops, cars, and KYC documents
- **Car Management**: View, filter, and manage all cars in the system
- **KYC Verification**: Review and verify user KYC documents (PAN, Aadhaar, Address Proof)

## Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure Firebase:
   
   **Easiest Method (Recommended):**
   ```bash
   flutterfire configure
   ```
   - Select your Firebase project (same as main app: `cardealer-eb165`)
   - Select platform: **Web**
   - Done! Config is updated automatically.
   
   **Manual Method:**
   - See `QUICK_SETUP.md` or `SETUP_GUIDE.md` for detailed instructions
   - The admin panel must connect to the same Firebase project as your main app

3. Set up Admin Users:
   
   **Quick Steps:**
   1. Go to Firebase Console → **Authentication** → **Users**
   2. Click on a user → Copy their **User UID**
   3. Go to **Firestore Database** → Create collection: **`admins`**
   4. Add document with **Document ID = User UID** (no fields needed)
   5. Repeat for each admin user
   
   **Detailed Guide:** See `QUICK_SETUP.md` or `SETUP_GUIDE.md`

## Running Locally

```bash
flutter run -d chrome
```

## Building for Web

```bash
flutter build web --release
```

## Deploying to Firebase Hosting

1. Build the web app:
```bash
flutter build web --release
```

2. Deploy to Firebase:
```bash
firebase deploy --only hosting
```

The admin panel will be available at your Firebase Hosting URL.

## Admin Authentication

- Only users whose UID exists in the `admins` Firestore collection can access the admin panel
- Admin users must sign in with their Firebase Auth email and password
- The app checks admin status on login and redirects unauthorized users

### Setting up Admin Users

1. Go to Firebase Console > Firestore Database
2. Create a collection named `admins` (if it doesn't exist)
3. For each admin user:
   - Create a document with the Firebase Auth UID as the document ID
   - No fields are required in the document (just the document ID is enough)
   - Example: Document ID = `abc123xyz` (the user's Firebase Auth UID)

## Project Structure

```
lib/
├── app/
│   ├── modules/
│   │   ├── login/          # Login page
│   │   ├── dashboard/      # Dashboard with statistics
│   │   ├── users/          # User management pages
│   │   ├── cars/           # Car management page
│   │   └── kyc/            # KYC verification page
│   └── routes/             # App routing configuration
├── core/
│   ├── services/           # Admin and Auth services
│   └── middleware/         # Route protection middleware
└── main.dart               # App entry point
```

## Notes

- The admin panel connects to the same Firebase project as the main app
- All data is read from Firestore collections: `users`, `cars`, `admin_notifications`
- Admin actions (KYC verification, car status updates) are written back to Firestore
