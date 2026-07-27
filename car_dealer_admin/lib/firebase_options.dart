import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCNe8Obag-lELDI0tK_6uAZ0dZpAjlLGJ8',
    appId: '1:1073666893011:web:af51cb811070d1d9e66026',
    messagingSenderId: '1073666893011',
    projectId: 'cardealer-eb165',
    authDomain: 'cardealer-eb165.firebaseapp.com',
    storageBucket: 'cardealer-eb165.firebasestorage.app',
    measurementId: 'G-PF2L6V0CX3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBShwEjinbjukRSDXHu8MRFqJdL4YJYKmA',
    appId: '1:1073666893011:android:cee520f85f2665ade66026',
    messagingSenderId: '1073666893011',
    projectId: 'cardealer-eb165',
    storageBucket: 'cardealer-eb165.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAESykTky1Vjcg1xNb1Hs_g35eIQYnjRQ',
    appId: '1:1073666893011:ios:35fa5b6ec243009ae66026',
    messagingSenderId: '1073666893011',
    projectId: 'cardealer-eb165',
    storageBucket: 'cardealer-eb165.firebasestorage.app',
    iosBundleId: 'com.example.carDealer',
  );
}
