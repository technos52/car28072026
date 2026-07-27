const admin = require('firebase-admin');
const serviceAccount = require('c:/Users/LENOVO/Desktop/projects to be delivered/car_dealer/car_dealer/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function checkNotifications() {
  try {
    const db = admin.firestore();
    const snapshot = await db.collection('admin_notifications')
      .where('type', '==', 'car_inquiry')
      .limit(3)
      .get();
    
    console.log(`Found ${snapshot.docs.length} car_inquiry notifications`);
    snapshot.forEach(doc => {
      console.log(`ID: ${doc.id}`);
      console.log(JSON.stringify(doc.data(), null, 2));
      console.log('----------------------------');
    });
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

checkNotifications();
