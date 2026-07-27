/**
 * Backfill script: adds 'carImageUrl' field to existing admin_notifications
 * that were created before this fix was deployed.
 *
 * Usage:
 *   1. Place your serviceAccountKey.json in this directory
 *   2. Run: node backfill_car_images.js
 */

const admin = require('firebase-admin');
const fs = require('fs');

// Check if serviceAccountKey.json exists
if (!fs.existsSync('./serviceAccountKey.json')) {
  console.error('❌ serviceAccountKey.json not found!');
  console.log('\nTo get the service account key:');
  console.log('1. Go to https://console.firebase.google.com/project/cardealer-eb165/settings/serviceaccounts/adminsdk');
  console.log('2. Click "Generate new private key"');
  console.log('3. Save as "serviceAccountKey.json" in this directory');
  console.log('4. Run this script again\n');
  process.exit(1);
}

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

/**
 * Extracts the first image URL from a car Firestore document.
 */
function extractImageUrl(carData) {
  if (!carData) return null;

  // Try imageUrls array
  if (Array.isArray(carData.imageUrls) && carData.imageUrls.length > 0) {
    return carData.imageUrls[0];
  }

  // Try imageUrls as JSON string
  if (typeof carData.imageUrls === 'string' && carData.imageUrls.startsWith('[')) {
    try {
      const parsed = JSON.parse(carData.imageUrls);
      if (Array.isArray(parsed) && parsed.length > 0) return parsed[0];
    } catch (_) {}
  }

  // Try imageUrl string
  if (typeof carData.imageUrl === 'string' && carData.imageUrl.length > 0) {
    const raw = carData.imageUrl;
    if (raw.startsWith('[')) {
      try {
        const parsed = JSON.parse(raw);
        if (Array.isArray(parsed) && parsed.length > 0) return parsed[0];
      } catch (_) {}
    } else {
      return raw;
    }
  }

  // Try imagePaths array
  if (Array.isArray(carData.imagePaths) && carData.imagePaths.length > 0) {
    return carData.imagePaths[0];
  }

  return null;
}

async function backfill() {
  console.log('🚀 Starting backfill of carImageUrl in admin_notifications...\n');

  const notificationsSnap = await db
    .collection('admin_notifications')
    .where('type', '==', 'car_inquiry')
    .get();

  console.log(`📋 Found ${notificationsSnap.docs.length} car_inquiry notifications`);

  let updated = 0;
  let skipped = 0;
  let failed = 0;

  for (const doc of notificationsSnap.docs) {
    const data = doc.data();

    // Skip if already has carImageUrl
    if (data.carImageUrl && data.carImageUrl.length > 0) {
      console.log(`  ⏭️  SKIP: ${doc.id} — already has carImageUrl`);
      skipped++;
      continue;
    }

    const carId = data.carId;
    const sellerId = data.sellerId;

    if (!carId) {
      console.log(`  ❌ SKIP: ${doc.id} — no carId`);
      skipped++;
      continue;
    }

    let imageUrl = null;

    // Try root cars collection
    try {
      const carDoc = await db.collection('cars').doc(carId).get();
      if (carDoc.exists) {
        imageUrl = extractImageUrl(carDoc.data());
        if (imageUrl) {
          console.log(`  ✅ Found image in /cars/${carId}`);
        }
      }
    } catch (e) {
      console.log(`  ⚠️  Error reading /cars/${carId}: ${e.message}`);
    }

    // Fallback: try seller subcollection
    if (!imageUrl && sellerId) {
      try {
        const sellerCarDoc = await db
          .collection('users')
          .doc(sellerId)
          .collection('cars')
          .doc(carId)
          .get();
        if (sellerCarDoc.exists) {
          imageUrl = extractImageUrl(sellerCarDoc.data());
          if (imageUrl) {
            console.log(`  ✅ Found image in /users/${sellerId}/cars/${carId}`);
          }
        }
      } catch (e) {
        console.log(`  ⚠️  Error reading /users/${sellerId}/cars/${carId}: ${e.message}`);
      }
    }

    if (imageUrl) {
      try {
        await doc.ref.update({ carImageUrl: imageUrl });
        console.log(`  💾 UPDATED: ${doc.id} — buyer: ${data.buyerName}, car: ${data.carName} ${data.carModel}`);
        updated++;
      } catch (e) {
        console.log(`  ❌ FAILED to update ${doc.id}: ${e.message}`);
        failed++;
      }
    } else {
      console.log(`  ⚠️  NO IMAGE FOUND for ${doc.id} — car: ${data.carName} ${data.carModel}, carId: ${carId}`);
      failed++;
    }
  }

  console.log('\n--- BACKFILL COMPLETE ---');
  console.log(`✅ Updated: ${updated}`);
  console.log(`⏭️  Skipped: ${skipped}`);
  console.log(`❌ No image found: ${failed}`);
  process.exit(0);
}

backfill().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});
