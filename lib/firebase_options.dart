// Firebase Configuration for blood-bank-app-9c6db
// Auto-generated — DO NOT edit manually unless updating Firebase project details.

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
    apiKey: 'AIzaSyB0YRf5qvoGjtxfFANgkJ3PBmXp47V3ouY',
    appId: '1:864651264460:web:8f1e5490fd8878431f5d69',
    messagingSenderId: '864651264460',
    projectId: 'blood-bank-app-9c6db',
    authDomain: 'blood-bank-app-9c6db.firebaseapp.com',
    storageBucket: 'blood-bank-app-9c6db.firebasestorage.app',
    measurementId: 'G-D0MC7RX5BZ',
  );

  // NOTE: The android appId below uses the web appId as a fallback because
  // explicit FirebaseOptions (not google-services.json) are used for initialization.
  // Firebase Auth and Firestore work correctly with this approach on Android.
  // If you add a proper Android app in Firebase Console and download
  // google-services.json, replace this appId with the android-specific one.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0YRf5qvoGjtxfFANgkJ3PBmXp47V3ouY',
    appId: '1:864651264460:android:8f1e5490fd8878431f5d69',
    messagingSenderId: '864651264460',
    projectId: 'blood-bank-app-9c6db',
    storageBucket: 'blood-bank-app-9c6db.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0YRf5qvoGjtxfFANgkJ3PBmXp47V3ouY',
    appId: '1:864651264460:ios:8f1e5490fd8878431f5d69',
    messagingSenderId: '864651264460',
    projectId: 'blood-bank-app-9c6db',
    storageBucket: 'blood-bank-app-9c6db.firebasestorage.app',
    iosBundleId: 'com.ailifevault.aiLifeVault',
  );
}
