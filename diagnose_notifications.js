/**
 * Diagnostic: shows first 5 admin_notifications with their carId, sellerId,
 * carImageUrl status, and what's actually stored in the matching /cars doc.
 * Run with: node diagnose_notifications.js
 */

const admin = require('firebase-admin');
const fs = require('fs');

let credential;

// Try service account key first
if (fs.existsSync('./serviceAccountKey.json')) {
  const sa = require('./serviceAccountKey.json');
  credential = admin.credential.cert(sa);
  console.log('Using serviceAccountKey.json');
} else {
  // Try application default credentials (firebase login --reauth sets this up)
  try {
    credential = admin.credential.applicationDefault();
    console.log('Using application default credentials');
  } catch (e) {
    console.error('No credentials found. Please download serviceAccountKey.json from:');
    console.error('https://console.firebase.google.com/project/cardealer-eb165/settings/serviceaccounts/adminsdk');
    process.exit(1);
  }
}

admin.initializeApp({
  credential,
  projectId: 'cardealer-eb165',
});

const db = admin.firestore();

async function diagnose() {
  console.log('\n=== DIAGNOSING admin_notifications ===\n');

  const snap = await db
    .collection('admin_notifications')
    .where('type', '==', 'car_inquiry')
    .limit(5)
    .get();

  console.log(`Total shown: ${snap.docs.length} (limited to 5)\n`);

  for (const doc of snap.docs) {
    const d = doc.data();
    console.log(`--- Notification: ${doc.id} ---`);
    console.log(`  buyerName:    ${d.buyerName}`);
    console.log(`  carName:      ${d.carName} ${d.carModel}`);
    console.log(`  carId:        ${d.carId}`);
    console.log(`  sellerId:     ${d.sellerId}`);
    console.log(`  carImageUrl:  ${d.carImageUrl || '(MISSING)'}`);

    if (d.carId) {
      // Check root /cars collection
      const carDoc = await db.collection('cars').doc(d.carId).get();
      if (carDoc.exists) {
        const cd = carDoc.data();
        console.log(`  /cars/${d.carId}: EXISTS`);
        console.log(`    imageUrl:   ${cd.imageUrl || '(missing)'}`);
        console.log(`    imageUrls:  ${JSON.stringify(cd.imageUrls) || '(missing)'}`);
        console.log(`    imagePaths: ${JSON.stringify(cd.imagePaths) || '(missing)'}`);
      } else {
        console.log(`  /cars/${d.carId}: *** NOT FOUND ***`);

        // Try seller subcollection
        if (d.sellerId) {
          const sellerCarDoc = await db
            .collection('users')
            .doc(d.sellerId)
            .collection('cars')
            .doc(d.carId)
            .get();
          if (sellerCarDoc.exists) {
            const cd = sellerCarDoc.data();
            console.log(`  /users/${d.sellerId}/cars/${d.carId}: EXISTS`);
            console.log(`    imageUrl:   ${cd.imageUrl || '(missing)'}`);
            console.log(`    imageUrls:  ${JSON.stringify(cd.imageUrls) || '(missing)'}`);
          } else {
            console.log(`  /users/${d.sellerId}/cars/${d.carId}: *** NOT FOUND ***`);
          }
        }
      }
    }
    console.log();
  }
  process.exit(0);
}

diagnose().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
