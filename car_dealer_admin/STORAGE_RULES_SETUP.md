# Firebase Storage Rules Setup for Carousel Images

## Problem
If you're getting an "unauthorized" error when uploading carousel images, you need to update your Firebase Storage security rules.

## Solution

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **cardealer-eb165**
3. Navigate to **Storage** → **Rules** tab
4. Replace the rules with the following:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated admins to upload/manage carousel images
    match /carousel_images/{imageId} {
      // Allow read access to everyone (for displaying on home page)
      allow read: if true;
      
      // Allow write access only to authenticated users who are admins
      allow write: if request.auth != null 
                   && exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    // Keep your existing rules for other paths
    // Add other rules below as needed
  }
}
```

## Alternative: More Permissive Rules (for testing)

If you want to allow all authenticated users to upload carousel images (less secure):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /carousel_images/{imageId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## How to Verify Admin Status

The rules check if the user's UID exists in the `admins` Firestore collection:
- Collection: `admins`
- Document ID: User's Firebase Auth UID
- No fields required in the document

## After Updating Rules

1. Click **Publish** to save the rules
2. Rules take effect immediately
3. Try uploading an image again from the admin panel

## Troubleshooting

- **Still getting unauthorized?** 
  - Make sure you're logged in as an admin
  - Verify your UID exists in the `admins` collection in Firestore
  - Check that the Storage rules were published successfully

- **Rules not working?**
  - Wait a few seconds for rules to propagate
  - Clear browser cache and try again
  - Check Firebase Console → Storage → Rules to confirm they're saved

