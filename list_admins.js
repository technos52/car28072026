const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function listAdmins() {
  try {
    const db = admin.firestore();
    const adminsSnapshot = await db.collection('admins').get();
    
    console.log('--- ADMINS IN FIRESTORE ---');
    const uids = [];
    adminsSnapshot.forEach(doc => {
      console.log(`Admin UID: ${doc.id}`);
      uids.push(doc.id);
    });
    console.log(`Total admins in Firestore: ${uids.length}\n`);

    console.log('--- FETCHING DETAILS FROM AUTH ---');
    for (const uid of uids) {
      try {
        const userRecord = await admin.auth().getUser(uid);
        console.log(`UID: ${uid}`);
        console.log(`Email: ${userRecord.email}`);
        console.log(`Phone: ${userRecord.phoneNumber}`);
        console.log(`Display Name: ${userRecord.displayName}`);
        console.log('------------------------');
      } catch (authError) {
        console.log(`UID: ${uid} - Failed to fetch from Auth: ${authError.message}`);
      }
    }
    process.exit(0);
  } catch (error) {
    console.error('Error listing admins:', error);
    process.exit(1);
  }
}

listAdmins();
