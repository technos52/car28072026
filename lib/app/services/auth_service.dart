import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/constants/firebase_config.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isGuest => _auth.currentUser?.isAnonymous ?? false;

  Future<bool> isExistingUser(User user) async {
    try {
      print('Checking if user ${user.uid} is existing...');
      final db = FirebaseConfig.firestoreDatabaseId != null
          ? FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: FirebaseConfig.firestoreDatabaseId!,
            )
          : FirebaseFirestore.instance;

      // Check if user document exists
      final userDoc = await db.collection('users').doc(user.uid).get();
      print('User document exists: ${userDoc.exists}');
      
      // Check if user has completed onboarding by checking for shop data in the correct subcollection path
      final shopDoc = await db
          .collection('users')
          .doc(user.uid)
          .collection('shops')
          .doc('${user.uid}_shop')
          .get();
      print('Shop document exists in correct subcollection: ${shopDoc.exists}');

      // User is considered "existing" only if they have both user profile AND shop data
      if (userDoc.exists && shopDoc.exists) {
        print('User ${user.uid} exists and has complete shop profile.');
        return true;
      }

      // If they don't have user profile or shop data, check if they have a phone number to migrate from an old UID
      String? rawPhone = user.phoneNumber;
      if (rawPhone != null && rawPhone.isNotEmpty) {
        String phoneDigits = rawPhone.replaceAll(RegExp(r"[^0-9]"), "");
        if (phoneDigits.length >= 10) {
          phoneDigits = phoneDigits.substring(phoneDigits.length - 10);
        }
        
        print('Querying Firestore users for phone: $phoneDigits to check if we can migrate data...');
        final querySnap = await db
            .collection('users')
            .where('phone', isEqualTo: phoneDigits)
            .get();

        if (querySnap.docs.isNotEmpty) {
          final oldDoc = querySnap.docs.first;
          final oldUid = oldDoc.id;
          if (oldUid != user.uid) {
            print('Found existing user with same phone under old UID: $oldUid. Migrating all data to new UID: ${user.uid}');
            await _migrateUserData(oldUid, user.uid, phoneDigits);
            
            // Re-check after migration
            final newUserDoc = await db.collection('users').doc(user.uid).get();
            final newShopDoc = await db
                .collection('users')
                .doc(user.uid)
                .collection('shops')
                .doc('${user.uid}_shop')
                .get();
            final migratedSuccessfully = newUserDoc.exists && newShopDoc.exists;
            print('Migration check result: $migratedSuccessfully');
            return migratedSuccessfully;
          }
        }
      }

      final isExisting = userDoc.exists && shopDoc.exists;
      print('Final isExisting result: $isExisting');
      return isExisting;
    } catch (e) {
      print('Error checking existing user: $e');
      return false;
    }
  }

  Future<void> _migrateUserData(String oldUid, String newUid, String phone) async {
    try {
      print('Starting user data migration from $oldUid to $newUid');
      final db = FirebaseConfig.firestoreDatabaseId != null
          ? FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: FirebaseConfig.firestoreDatabaseId!,
            )
          : FirebaseFirestore.instance;

      final batch = db.batch();

      // 1. Migrate user document
      final oldUserDoc = await db.collection('users').doc(oldUid).get();
      if (oldUserDoc.exists) {
        final data = oldUserDoc.data() ?? {};
        batch.set(db.collection('users').doc(newUid), data, SetOptions(merge: true));
      }

      // 2. Migrate shop document
      final oldShopDoc = await db
          .collection('users')
          .doc(oldUid)
          .collection('shops')
          .doc('${oldUid}_shop')
          .get();
      if (oldShopDoc.exists) {
        final data = oldShopDoc.data() ?? {};
        batch.set(
          db.collection('users').doc(newUid).collection('shops').doc('${newUid}_shop'),
          data,
          SetOptions(merge: true),
        );
      }

      // 3. Migrate cars subcollection and public cars
      final carsSnap = await db
          .collection('users')
          .doc(oldUid)
          .collection('cars')
          .get();
      for (var carDoc in carsSnap.docs) {
        final carData = carDoc.data();
        // Update local car doc under new user
        batch.set(
          db.collection('users').doc(newUid).collection('cars').doc(carDoc.id),
          carData,
          SetOptions(merge: true),
        );
        // Update public car doc userId field
        batch.update(db.collection('cars').doc(carDoc.id), {'userId': newUid});
      }

      // 4. Migrate wishlist
      final wishlistSnap = await db
          .collection('users')
          .doc(oldUid)
          .collection('wishlist')
          .get();
      for (var wishDoc in wishlistSnap.docs) {
        batch.set(
          db.collection('users').doc(newUid).collection('wishlist').doc(wishDoc.id),
          wishDoc.data(),
          SetOptions(merge: true),
        );
      }

      // 5. Migrate kyc_documents
      final kycSnap = await db
          .collection('users')
          .doc(oldUid)
          .collection('kyc_documents')
          .get();
      for (var kycDoc in kycSnap.docs) {
        batch.set(
          db.collection('users').doc(newUid).collection('kyc_documents').doc(kycDoc.id),
          kycDoc.data(),
          SetOptions(merge: true),
        );
      }

      // Commit the copy batch
      await batch.commit();
      print('Migration copy phase successfully committed.');

      // Now delete the old user's subcollections and user doc
      final deleteBatch = db.batch();

      // Delete old user doc
      deleteBatch.delete(db.collection('users').doc(oldUid));

      // Delete old shop doc
      deleteBatch.delete(
        db.collection('users').doc(oldUid).collection('shops').doc('${oldUid}_shop'),
      );

      // Delete old cars subcollection docs
      for (var carDoc in carsSnap.docs) {
        deleteBatch.delete(
          db.collection('users').doc(oldUid).collection('cars').doc(carDoc.id),
        );
      }

      // Delete old wishlist docs
      for (var wishDoc in wishlistSnap.docs) {
        deleteBatch.delete(
          db.collection('users').doc(oldUid).collection('wishlist').doc(wishDoc.id),
        );
      }

      // Delete old kyc docs
      for (var kycDoc in kycSnap.docs) {
        deleteBatch.delete(
          db.collection('users').doc(oldUid).collection('kyc_documents').doc(kycDoc.id),
        );
      }

      await deleteBatch.commit();
      print('Migration delete phase successfully completed. Old data cleaned up.');
    } catch (e) {
      print('Error during migration of user data: $e');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      clientId: kIsWeb ? FirebaseConfig.googleWebClientId : null,
      serverClientId: FirebaseConfig.googleWebClientId,
      scopes: ['email', 'profile'],
    ).signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'canceled',
        message: 'Google sign-in canceled',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    if (googleAuth.idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message:
            'Failed to get ID token from Google Sign-In. Please ensure SHA-256 fingerprint is registered in Firebase Console. Current package: com.shailesh.DealMatee',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    final AuthorizationCredentialAppleID appleCredential =
        await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    return await _auth.signInWithCredential(oauthCredential);
  }

  Future<ConfirmationResult> sendOtpWeb(String phoneNumber) async {
    return await _auth.signInWithPhoneNumber(phoneNumber);
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(FirebaseAuthException error) verificationFailed,
    required Function(String verificationId) codeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
    );
  }

  Future<UserCredential> signInWithSmsCode(
    String verificationId,
    String smsCode,
  ) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await GoogleSignIn(
        clientId: kIsWeb ? FirebaseConfig.googleWebClientId : null,
      ).signOut();
    } catch (_) {}
  }

  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    final db = FirebaseConfig.firestoreDatabaseId != null
        ? FirebaseFirestore.instanceFor(
            app: Firebase.app(),
            databaseId: FirebaseConfig.firestoreDatabaseId!,
          )
        : FirebaseFirestore.instance;

    // 1. Delete all Firestore data for this user instantly
    try {
      // Delete cars in subcollection and public collection
      final carsSnap =
          await db.collection('users').doc(uid).collection('cars').get();
      for (var doc in carsSnap.docs) {
        try {
          await db.collection('cars').doc(doc.id).delete();
        } catch (_) {}
        try {
          await doc.reference.delete();
        } catch (_) {}
      }

      // Delete shop
      try {
        await db
            .collection('users')
            .doc(uid)
            .collection('shops')
            .doc('${uid}_shop')
            .delete();
      } catch (_) {}

      // Delete wishlist
      try {
        final wishlistSnap =
            await db.collection('users').doc(uid).collection('wishlist').get();
        for (var doc in wishlistSnap.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      // Delete kyc_documents
      try {
        final kycSnap = await db
            .collection('users')
            .doc(uid)
            .collection('kyc_documents')
            .get();
        for (var doc in kycSnap.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      // Delete main user document
      try {
        await db.collection('users').doc(uid).delete();
      } catch (_) {}

      print('All user Firestore documents deleted successfully.');
    } catch (e) {
      print('Error during Firestore data deletion: $e');
    }

    // 2. Try deleting Firebase Auth user (ignore error if token expired so logout proceeds)
    try {
      await user.delete();
      print('Firebase Auth user deleted.');
    } catch (e) {
      print('Auth delete caught (proceeding to sign out): $e');
    }

    // 3. Sign out completely
    try {
      await signOut();
    } catch (_) {}
  }
}
