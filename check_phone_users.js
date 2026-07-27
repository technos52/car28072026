const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function listPhoneUsers() {
  try {
    console.log('Fetching all users from Firebase Authentication...\n');
    
    let nextPageToken;
    let phoneUsers = [];
    let totalUsers = 0;
    
    do {
      const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
      
      listUsersResult.users.forEach((user) => {
        totalUsers++;
        
        const phoneNumber = user.phoneNumber;
        const providers = user.providerData.map(provider => provider.providerId);
        
        if (phoneNumber || providers.includes('phone')) {
          phoneUsers.push({
            uid: user.uid,
            phoneNumber: phoneNumber || 'N/A',
            email: user.email || 'N/A',
            displayName: user.displayName || 'N/A',
            creationTime: user.metadata.creationTime,
            lastSignInTime: user.metadata.lastSignInTime || 'Never',
            providers: providers,
            emailVerified: user.emailVerified || false,
            disabled: user.disabled || false
          });
        }
      });
      
      nextPageToken = listUsersResult.pageToken;
    } while (nextPageToken);
    
    console.log(`Total users in Firebase: ${totalUsers}`);
    console.log(`Phone-authenticated users: ${phoneUsers.length}\n`);
    
    if (phoneUsers.length > 0) {
      console.log('=== Phone-Authenticated Users ===\n');
      phoneUsers.forEach((user, index) => {
        console.log(`${index + 1}. UID: ${user.uid}`);
        console.log(`   Phone: ${user.phoneNumber}`);
        console.log(`   Email: ${user.email}`);
        console.log(`   Display Name: ${user.displayName}`);
        console.log(`   Created: ${user.creationTime}`);
        console.log(`   Last Sign In: ${user.lastSignInTime}`);
        console.log(`   Providers: ${user.providers.join(', ')}`);
        console.log(`   Email Verified: ${user.emailVerified}`);
        console.log(`   Disabled: ${user.disabled}`);
        console.log('');
      });
    } else {
      console.log('No phone-authenticated users found.');
    }
    
    process.exit(0);
  } catch (error) {
    console.error('Error listing users:', error);
    process.exit(1);
  }
}

listPhoneUsers();

